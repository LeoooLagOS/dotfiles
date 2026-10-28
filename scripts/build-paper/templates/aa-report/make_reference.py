#!/usr/bin/env python3
"""Builds reference.docx for the aa-report template from plantilla_original.docx.

The course template formats its text by hand (no Word styles), so Pandoc cannot
reproduce it as-is. This script keeps the template's page setup, headers, footers
and logo, empties the body, and defines the styles Pandoc writes (Body Text,
Heading 1-3, captions, bibliography...) with the look of the template.

Header/footer text is replaced by placeholders that build_paper.py fills from
the Markdown frontmatter: {{AREA}}, {{HEADER_MATERIA}}, {{PERIODO}}.

Run it again only if plantilla_original.docx changes.
"""
import re
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
SOURCE = HERE / "plantilla_original.docx"
TARGET = HERE / "reference.docx"

TIMES = '<w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>'
MONO = '<w:rFonts w:ascii="Consolas" w:hAnsi="Consolas" w:cs="Consolas"/>'


def pstyle(sid, name, ppr="", rpr="", based="Normal", nxt=None, ui=None):
    nxt_xml = f'<w:next w:val="{nxt}"/>' if nxt else ""
    ui_xml = f'<w:uiPriority w:val="{ui}"/>' if ui is not None else ""
    return (
        f'<w:style w:type="paragraph" w:customStyle="1" w:styleId="{sid}">'
        f'<w:name w:val="{name}"/><w:basedOn w:val="{based}"/>{nxt_xml}{ui_xml}<w:qFormat/>'
        f"<w:pPr>{ppr}</w:pPr><w:rPr>{rpr}</w:rPr></w:style>"
    )


def cstyle(sid, name, rpr):
    return (
        f'<w:style w:type="character" w:customStyle="1" w:styleId="{sid}">'
        f'<w:name w:val="{name}"/><w:rPr>{rpr}</w:rPr></w:style>'
    )


JUSTIFY = '<w:jc w:val="both"/>'
CENTER = '<w:jc w:val="center"/>'
KEEP = "<w:keepNext/><w:keepLines/>"

# Measures taken from plantilla_original.docx (sizes are half-points)
STYLES = [
    # Body: Calibri 11, justified, 8 pt after (template's direct formatting)
    pstyle("BodyText", "Body Text", JUSTIFY + '<w:spacing w:after="160" w:line="259" w:lineRule="auto"/>'),
    pstyle("FirstParagraph", "First Paragraph", based="BodyText", nxt="BodyText"),
    pstyle("Compact", "Compact", '<w:spacing w:before="36" w:after="36"/>', based="BodyText"),
    # Section titles: bold 12, numbered by the Lua filter ("1 Introducción")
    pstyle("Heading1", "heading 1", KEEP + '<w:spacing w:before="240" w:after="120"/><w:outlineLvl w:val="0"/>',
           "<w:b/><w:bCs/><w:sz w:val=\"24\"/><w:szCs w:val=\"24\"/>", nxt="BodyText", ui=9),
    # "1.1 Objetivo de la práctica.": bold italic 11
    pstyle("Heading2", "heading 2", KEEP + '<w:spacing w:before="160" w:after="80"/><w:outlineLvl w:val="1"/>',
           "<w:b/><w:bCs/><w:i/><w:iCs/>", nxt="BodyText", ui=9),
    # "2.1 E-learning": plain 11
    pstyle("Heading3", "heading 3", KEEP + '<w:spacing w:before="120" w:after="80"/><w:outlineLvl w:val="2"/>',
           "<w:i/><w:iCs/>", nxt="BodyText", ui=9),
    pstyle("Heading4", "heading 4", KEEP + '<w:spacing w:before="120" w:after="60"/><w:outlineLvl w:val="3"/>',
           "<w:i/>", nxt="BodyText", ui=9),
    # Figures and captions: "Figura 1. ..." centered
    pstyle("CaptionedFigure", "Captioned Figure", CENTER + KEEP + '<w:spacing w:after="60"/>'),
    pstyle("Figure", "Figure", CENTER + '<w:spacing w:after="60"/>'),
    pstyle("Caption", "caption", CENTER + '<w:spacing w:after="200" w:line="240" w:lineRule="auto"/>'),
    pstyle("ImageCaption", "Image Caption", based="Caption"),
    pstyle("TableCaption", "Table Caption", CENTER + KEEP + '<w:spacing w:before="120" w:after="60"/>', based="Caption"),
    # References: "[1] ..." single spaced, 6 pt after
    pstyle("Bibliography", "Bibliography", '<w:spacing w:after="120" w:line="240" w:lineRule="auto"/>'),
    # Code
    pstyle("SourceCode", "Source Code", '<w:spacing w:after="120" w:line="240" w:lineRule="auto"/><w:shd w:val="clear" w:color="auto" w:fill="F2F2F2"/>',
           MONO + '<w:sz w:val="18"/><w:szCs w:val="18"/>'),
    pstyle("BlockText", "Block Text", '<w:ind w:left="567" w:right="567"/>' + JUSTIFY, "<w:i/>"),
    # Title block (written by aa-report.lua)
    pstyle("AATitulo", "AA Titulo", CENTER + '<w:spacing w:after="160"/>',
           TIMES + '<w:b/><w:bCs/><w:sz w:val="28"/><w:szCs w:val="28"/>'),
    pstyle("AATitleEN", "AA Title EN", CENTER + '<w:spacing w:after="160"/>',
           TIMES + '<w:b/><w:bCs/><w:sz w:val="28"/><w:szCs w:val="28"/><w:lang w:val="en-US"/>'),
    pstyle("AAAutores", "AA Autores", CENTER + '<w:spacing w:before="360" w:after="40"/>',
           '<w:sz w:val="24"/><w:szCs w:val="24"/>'),
    pstyle("AAAfiliacion", "AA Afiliacion", CENTER + '<w:spacing w:after="40"/>',
           '<w:sz w:val="24"/><w:szCs w:val="24"/>'),
    pstyle("AACorreo", "AA Correo", CENTER + '<w:spacing w:before="120" w:after="160"/>',
           '<w:sz w:val="24"/><w:szCs w:val="24"/>'),
    pstyle("AAResumenTitulo", "AA Resumen Titulo", CENTER + KEEP + '<w:spacing w:before="360" w:after="160"/>',
           TIMES + '<w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/>'),
    pstyle("AAResumen", "AA Resumen", JUSTIFY),
    pstyle("AASeparador", "AA Separador", '<w:spacing w:after="160"/>'),
    pstyle("AAKeywords", "AA Keywords", JUSTIFY, '<w:sz w:val="20"/><w:szCs w:val="20"/>'),
    cstyle("VerbatimChar", "Verbatim Char", MONO + '<w:sz w:val="20"/>'),
    cstyle("Hyperlink", "Hyperlink", '<w:color w:val="0563C1"/><w:u w:val="single"/>'),
]

TABLE_STYLE = (
    '<w:style w:type="table" w:customStyle="1" w:styleId="Table"><w:name w:val="Table"/>'
    '<w:basedOn w:val="TableNormal"/><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr>'
    '<w:tblPr><w:jc w:val="center"/><w:tblBorders>'
    '<w:top w:val="single" w:sz="8" w:space="0" w:color="000000"/>'
    '<w:bottom w:val="single" w:sz="8" w:space="0" w:color="000000"/>'
    '</w:tblBorders><w:tblCellMar><w:left w:w="108" w:type="dxa"/><w:right w:w="108" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    '<w:tblStylePr w:type="firstRow"><w:rPr><w:b/></w:rPr><w:tcPr><w:tcBorders>'
    '<w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:tcBorders></w:tcPr></w:tblStylePr>'
    "</w:style>"
)


def drop_style(styles, name):
    """Removes any style whose name pandoc would match (e.g. localized 'Body Text')."""
    pattern = re.compile(r'<w:style\b(?:(?!</w:style>).)*?<w:name w:val="' + re.escape(name) + r'"/>.*?</w:style>', re.S)
    return pattern.sub("", styles)


def build():
    files = {}
    with zipfile.ZipFile(SOURCE) as z:
        for item in z.infolist():
            if item.filename.startswith("[trash]"):
                continue
            files[item.filename] = z.read(item.filename)

    # Body: keep only the section properties (page size, margins, headers/footers)
    doc = files["word/document.xml"].decode("utf8")
    sect = re.findall(r"<w:sectPr\b.*?</w:sectPr>", doc, re.S)[-1]
    body_start = doc.index("<w:body>") + len("<w:body>")
    body_end = doc.index("</w:body>")
    doc = doc[:body_start] + "<w:p/>" + sect + doc[body_end:]
    files["word/document.xml"] = doc.encode("utf8")

    styles = files["word/styles.xml"].decode("utf8")
    for name in ["Body Text", "heading 1", "heading 2", "heading 3", "heading 4", "caption", "Hyperlink", "Table"]:
        styles = drop_style(styles, name)
    styles = styles.replace("</w:styles>", "".join(STYLES) + TABLE_STYLE + "</w:styles>")
    files["word/styles.xml"] = styles.encode("utf8")

    # Placeholders filled per document by build_paper.py
    swaps = {
        "word/header2.xml": [(">NOMBRE DE LA MATERIA PERIODO OTOÑO 2025<", ">{{HEADER_MATERIA}}<")],
        "word/header3.xml": [(">Área<", ">{{AREA}}<"), ("> de Redes<", "><")],
        "word/footer1.xml": [(">Otoño 2025<", ">{{PERIODO}}<")],
        "word/footer2.xml": [(">Otoño 2025<", ">{{PERIODO}}<")],
        "word/footer3.xml": [(">Otoño 2025<", ">{{PERIODO}}<")],
    }
    for name, pairs in swaps.items():
        xml = files[name].decode("utf8")
        for old, new in pairs:
            assert xml.count(old) == 1, f"{name}: '{old}' not found once"
            xml = xml.replace(old, new)
        files[name] = xml.encode("utf8")

    with zipfile.ZipFile(TARGET, "w", zipfile.ZIP_DEFLATED) as z:
        # [Content_Types].xml must be first for some readers
        z.writestr("[Content_Types].xml", files.pop("[Content_Types].xml"))
        for name, data in files.items():
            z.writestr(name, data)
    print(f"✅ {TARGET}")


if __name__ == "__main__":
    build()
