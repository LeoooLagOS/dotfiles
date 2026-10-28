-- aa-report.lua: title block and section numbers for the A&A practice report template.
--
-- Frontmatter read:
--   title, title-en (or subtitle), author (list of names or {name, affiliation, location, email}),
--   affiliations (optional list; then author.affiliation is a number), abstract, keywords,
--   number-sections (default true)
-- The paragraphs use the "AA ..." styles defined in reference.docx.

local stringify = pandoc.utils.stringify

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function as_list(value)
  if value == nil then return {} end
  if pandoc.utils.type(value) == "List" then return value end
  return { value }
end

local function join(items, sep)
  local out = pandoc.Inlines({})
  for i, item in ipairs(items) do
    if i > 1 then out:extend(pandoc.Inlines(sep)) end
    out:extend(item)
  end
  return out
end

local function title_block(meta)
  local blocks = {}

  if meta.title then
    table.insert(blocks, styled("AA Titulo", meta.title))
  end
  local title_en = meta["title-en"] or meta.subtitle
  if title_en then
    table.insert(blocks, styled("AA Title EN", title_en))
  end

  -- Authors: affiliations are numbered in order of first appearance,
  -- or taken from the explicit "affiliations" list
  local affiliations = {}
  for _, a in ipairs(as_list(meta.affiliations)) do
    table.insert(affiliations, stringify(a))
  end
  local explicit = #affiliations > 0
  local names, emails = {}, {}

  for _, author in ipairs(as_list(meta.author)) do
    local name, number
    if pandoc.utils.type(author) == "table" and author.name then
      name = pandoc.Inlines(author.name)
      if author.email then table.insert(emails, stringify(author.email)) end
      if author.affiliation then
        if explicit then
          number = tonumber(stringify(author.affiliation))
        else
          local text = stringify(author.affiliation)
          if author.location then text = text .. ", " .. stringify(author.location) end
          for i, known in ipairs(affiliations) do
            if known == text then number = i end
          end
          if not number then
            table.insert(affiliations, text)
            number = #affiliations
          end
        end
      end
    else
      name = pandoc.Inlines(author)
    end
    if number then
      name:insert(pandoc.Superscript(tostring(number)))
    end
    table.insert(names, name)
  end

  if #names > 0 then
    table.insert(blocks, styled("AA Autores", join(names, { pandoc.Str(","), pandoc.Space() })))
  end
  for i, text in ipairs(affiliations) do
    table.insert(blocks, styled("AA Afiliacion", { pandoc.Superscript(tostring(i)), pandoc.Str(text) }))
  end
  if #emails > 0 then
    table.insert(blocks, styled("AA Correo", { pandoc.Str(table.concat(emails, ", ") .. ".") }))
  end

  if meta.abstract then
    table.insert(blocks, styled("AA Resumen Titulo", { pandoc.Str("Resumen") }))
    local abstract = meta.abstract
    if pandoc.utils.type(abstract) == "Inlines" then abstract = { pandoc.Para(abstract) } end
    table.insert(blocks, pandoc.Div(abstract, { ["custom-style"] = "AA Resumen" }))
  end

  if meta.keywords then
    local words = {}
    for _, k in ipairs(as_list(meta.keywords)) do table.insert(words, stringify(k)) end
    local line = styled("AA Separador", { pandoc.Str("_____________________") })
    table.insert(blocks, line)
    table.insert(blocks, styled("AA Keywords", {
      pandoc.Str("Keywords"), pandoc.Space(), pandoc.Str("and"), pandoc.Space(), pandoc.Str("phrases:"),
      pandoc.Space(), pandoc.Str(table.concat(words, ", ") .. "."),
    }))
    table.insert(blocks, line)
  end

  return blocks
end

-- "1 Introducción", "1.1 Objetivo", ... as in the course template
local function number_headers(blocks)
  local counters = {}
  return blocks:walk({
    Header = function(h)
      if h.classes:includes("unnumbered") then return nil end
      counters[h.level] = (counters[h.level] or 0) + 1
      for level = h.level + 1, 6 do counters[level] = nil end
      local parts = {}
      for level = 1, h.level do table.insert(parts, tostring(counters[level] or 0)) end
      h.content:insert(1, pandoc.Space())
      h.content:insert(1, pandoc.Str(table.concat(parts, ".")))
      return h
    end,
  })
end

-- "Figura 1. ..." and "Tabla 1. ..." caption prefixes, as in the course template
local function prefix_caption(caption, label)
  local long = caption.long
  if #long == 0 then return end
  local first = long[1]
  if first.t == "Plain" or first.t == "Para" then
    first.content:insert(1, pandoc.Space())
    first.content:insert(1, pandoc.Str(label))
  end
end

local function number_captions(blocks)
  local figures, tables = 0, 0
  return blocks:walk({
    Figure = function(fig)
      figures = figures + 1
      prefix_caption(fig.caption, "Figura " .. figures .. ".")
      return fig
    end,
    Table = function(tbl)
      if #tbl.caption.long == 0 then return nil end
      tables = tables + 1
      prefix_caption(tbl.caption, "Tabla " .. tables .. ".")
      return tbl
    end,
  })
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = doc.blocks

  local numbered = meta["number-sections"] == nil or meta["number-sections"] == true
  if numbered then blocks = number_headers(blocks) end
  blocks = number_captions(blocks)

  local new_blocks = pandoc.Blocks(title_block(meta))
  new_blocks:extend(blocks)

  -- The filter writes the title block itself; keep Pandoc from adding its own
  for _, key in ipairs({ "title", "title-en", "subtitle", "author", "abstract", "date" }) do
    meta[key] = nil
  end
  if meta["reference-section-title"] == nil then
    meta["reference-section-title"] = pandoc.Inlines({ pandoc.Str("Referencias") })
  end

  return pandoc.Pandoc(new_blocks, meta)
end
