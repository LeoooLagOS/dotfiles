#!/usr/bin/env python3
import argparse
import subprocess
import os
import sys
from pathlib import Path

# --- CONFIGURACIÓN DE PLANTILLAS ---
# SoC: Centralizamos aquí la ubicación de tus herramientas académicas
TEMPLATES = {
    "ieee": {
        "type": "latex",
        "path": "ieee",  # Pandoc lo busca en ~/.local/share/pandoc/templates/
        "engine": "xelatex",
    },
    "academia": {
        "type": "odt",
        "path": str(
            Path.home()
            / "Documents/uni/research/ieee-pandoc-template/academia_template.odt"
        ),
        "engine": None,
    },
}


def build_command(input_file, template_name):
    if template_name not in TEMPLATES:
        print(
            f"❌ Error: La plantilla '{template_name}' no está definida en el script."
        )
        return None

    tmpl = TEMPLATES[template_name]
    input_path = Path(input_file)

    # Definir extensión de salida
    output_ext = "pdf" if tmpl["type"] == "latex" else "odt"
    output_file = input_path.stem + f"_{template_name}.{output_ext}"

    # Buscar automáticamente un archivo .bib en la carpeta actual
    bib_files = list(Path(".").glob("*.bib"))
    bib_arg = ["--bibliography", str(bib_files[0])] if bib_files else []

    # Comando base de Pandoc
    cmd = ["pandoc", str(input_path), "--citeproc"] + bib_arg

    if tmpl["type"] == "latex":
        cmd += ["--template", tmpl["path"], "--pdf-engine", tmpl["engine"]]
    else:
        cmd += ["--reference-doc", tmpl["path"]]

    cmd += ["-o", output_file]
    return cmd


def main():
    parser = argparse.ArgumentParser(description="lagOS Academic Build System")
    parser.add_argument("file", help="Archivo Markdown (.md) a compilar")
    parser.add_argument(
        "--type", default="ieee", help="Plantilla a usar (ieee o academia)"
    )
    args = parser.parse_args()

    if not os.path.exists(args.file):
        print(f"❌ Error: El archivo '{args.file}' no existe.")
        sys.exit(1)

    command = build_command(args.file, args.type)
    if command:
        print(f"🏗️  Compilando '{args.file}' usando formato '{args.type}'...")
        try:
            subprocess.run(command, check=True)
            output_name = command[-1]
            print(f"✅ ¡Éxito! Archivo generado: {output_name}")
        except subprocess.CalledProcessError:
            print("❌ Error: Pandoc falló al compilar el documento.")


if __name__ == "__main__":
    main()
