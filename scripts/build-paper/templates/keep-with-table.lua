--[[
keep-with-table.lua (build-paper, LaTeX output)

Problem: the template's \Needspace runs when a longtable starts, so when a
table doesn't fit, the table moves to the next page and the paragraph that
introduces it ("**Cliente**", "Las relaciones son:") stays behind, alone at
the bottom of the page. Short tables also split across two pages.

Figures have the same problem, worse: they are placed with [H], so a figure
that doesn't fit jumps to the next page and leaves its heading and
introducing paragraph alone, followed by blank space. A tall (portrait)
image at width=100% can't even fit on a page together with its heading.

Fix: before a table, code block or figure, ask LaTeX for enough free space
for the introducing paragraph plus (an estimate of) the block. If there
isn't, the page breaks before the paragraph, so both move together. When
that paragraph comes right after a heading, the request goes before the
heading, so the heading never stays behind either. Blocks taller than
MAX_LINES still break across pages, as they must.

Figures are capped at MAX_FIG_HEIGHT of the text height (unless the image
sets its own height), and their real height is computed from the image's
pixel size, so the reserved space matches what LaTeX will draw.
--]]

if not FORMAT:match("latex") then
  return {}
end

local MAX_LINES = 34          -- about 3/4 of a page; longer blocks may still split
local INTRO_LINES = 3         -- minimum room for the introducing paragraph
local HEADING_LINES = 3       -- a heading plus the space around it
local CHARS_PER_LINE = 90     -- to estimate how many lines a paragraph takes
local MAX_FIG_HEIGHT = 0.65   -- figures: at most this fraction of \textheight
local CAPTION_LINES = 3       -- figure caption plus skips
local MAX_REQUEST = 0.70      -- no request asks for more than this fraction of
                              -- \textheight: a bigger one can't be met on a fresh
                              -- page either, and only leaves a near-empty page behind

-- Figures --------------------------------------------------------------

local function figure_image(fig)
  local img
  fig.content:walk({ Image = function(i) img = img or i end })
  return img
end

local function percent(value)
  local n = value and value:match("^([%d%.]+)%%$")
  return n and tonumber(n) / 100 or nil
end

-- height / width of the image file, or nil if it can't be read
local function aspect_ratio(img)
  local ok, size = pcall(function()
    local _, contents = pandoc.mediabag.fetch(img.src)
    return pandoc.image.size(contents)
  end)
  if ok and size and size.width and size.width > 0 then
    return size.height / size.width
  end
  return nil
end

-- keepaspectratio, local to the figure environment (a group): with both a
-- width and a height, LaTeX then uses whichever limit is smaller instead of
-- stretching the image. Pandoc doesn't add it on its own.
local KEEP_ASPECT = pandoc.RawInline("latex", "\\setkeys{Gin}{keepaspectratio}")

function Figure(fig)
  local capped = false
  fig.content = fig.content:walk({
    Image = function(img)
      if not img.attributes.height then
        img.attributes.height = string.format("%d%%", MAX_FIG_HEIGHT * 100)
        capped = true
        return img
      end
    end,
  })
  if capped then
    fig.content = fig.content:walk({
      Plain = function(p)
        p.content:insert(1, KEEP_ASPECT)
        return p
      end,
    })
  end
  return fig
end

-- LaTeX length for the space a figure takes, inside a \dimexpr
local function figure_space(fig)
  local img = figure_image(fig)
  local caption = string.format("%d\\baselineskip", CAPTION_LINES)
  local cap = string.format("%.3f\\textheight", MAX_FIG_HEIGHT)
  local fixed = img and percent(img.attributes.height)
  local ratio = img and aspect_ratio(img)

  if fixed and fixed < MAX_FIG_HEIGHT then
    cap = string.format("%.3f\\textheight", fixed)
  end
  if not ratio then
    return string.format("%s+%s", cap, caption)
  end
  local width = (img and percent(img.attributes.width)) or 1
  local natural = string.format("%.3f\\linewidth", width * ratio)
  return string.format("\\ifdim%s>%s %s\\else %s\\fi+%s",
    natural, cap, cap, natural, caption)
end

-- Tables and code blocks -------------------------------------------------

local function table_lines(tbl)
  local rows = #tbl.head.rows
  for _, body in ipairs(tbl.bodies) do
    rows = rows + #body.body
  end
  -- rules and caption, plus ~2 lines per row (cells usually wrap)
  return 4 + rows * 2
end

local function code_lines(code)
  local _, newlines = code.text:gsub("\n", "")
  return newlines + 3
end

-- Space a block needs: lines, plus an extra LaTeX length for figures.
-- Returns nil when the block isn't one we keep together.
local function block_space(block)
  if not block then
    return nil
  elseif block.t == "Table" then
    return math.min(table_lines(block), MAX_LINES), nil
  elseif block.t == "CodeBlock" then
    return math.min(code_lines(block), MAX_LINES), nil
  elseif block.t == "Figure" then
    return 0, figure_space(block)
  end
  return nil
end

-- LaTeX length (for a \dimexpr) of `lines` lines plus an optional extra length
local function space(lines, extra)
  local length = string.format("%d\\baselineskip", lines)
  if extra then
    length = string.format("%s+%s", length, extra)
  end
  return length
end

local function needspace(length)
  -- \Needspace comes from the template's needspace package; skip it if absent.
  -- The request is capped at MAX_REQUEST of the page height.
  local cap = string.format("%.2f\\textheight", MAX_REQUEST)
  return pandoc.RawBlock("latex", string.format(
    "\\ifdefined\\Needspace\\Needspace{\\ifdim\\dimexpr %s\\relax>%s %s\\else\\dimexpr %s\\relax\\fi}\\fi",
    length, cap, cap, length))
end

local function is_intro(block)
  return block and (block.t == "Para" or block.t == "Plain")
end

local function intro_lines(block)
  local chars = utf8.len(pandoc.utils.stringify(block)) or 0
  return math.max(INTRO_LINES, math.ceil(chars / CHARS_PER_LINE) + 1)
end

-- Room the template's heading hooks ask for (\bpNeedSection etc. in
-- academic.latex), by heading level. Keep these in sync with the template.
local HEADING_NEED = { 20, 18, 8 }
local MAX_LEAD_LINES = 12     -- "short" text between two headings

-- A heading followed by a short lead-in and another heading ("2. Normalización",
-- one paragraph, "2.1 Primera Forma Normal"): the template checks each heading
-- on its own, so the first one fits, the lead-in uses up the room, and the
-- second heading jumps to the next page, leaving the first one stranded.
-- Ask for room for the whole chain before the first heading instead: the
-- lead-in plus whatever the next heading needs (the template's minimum, or
-- the room already requested for it and its table/figure, if larger).
-- Returns the index of the next heading and the lead-in lines, or nil.
local function heading_chain(blocks, i)
  local lines = HEADING_LINES
  local j = i + 1
  while is_intro(blocks[j]) do
    lines = lines + intro_lines(blocks[j])
    j = j + 1
  end
  local next_heading = blocks[j]
  -- Only a subheading can strand its parent. When the next heading is a
  -- sibling or higher ("2.1 ... / 2.2 ..."), the first one keeps its lead-in
  -- on the page and the second simply starts the next one; chaining siblings
  -- would add up every section's request and ask for more than a page.
  if lines - HEADING_LINES > MAX_LEAD_LINES
      or not next_heading or next_heading.t ~= "Header"
      or next_heading.level <= blocks[i].level then
    return nil
  end
  return j, lines
end

local function heading_need(header)
  return HEADING_NEED[header.level] or HEADING_NEED[#HEADING_NEED]
end

function Blocks(blocks)
  -- room to request before each block (LaTeX lengths), keyed by its index
  local requests = {}

  for i, block in ipairs(blocks) do
    local next_lines, next_extra = block_space(blocks[i + 1])
    local own_lines, own_extra = block_space(block)

    if is_intro(block) and next_lines then
      -- paragraph introducing a kept block: keep them together, and keep
      -- the heading right above the paragraph with them too
      local lines = next_lines + intro_lines(block)
      local at = i
      if blocks[i - 1] and blocks[i - 1].t == "Header" then
        at = i - 1
        lines = lines + HEADING_LINES
      end
      requests[at] = space(math.min(lines, MAX_LINES + 8), next_extra)
    elseif own_lines and not is_intro(blocks[i - 1]) then
      -- kept block with no introduction: keep short ones whole
      requests[i] = space(own_lines, own_extra)
    end
  end

  -- heading chains, from the last one up, so "# A / ## B / ### C" adds up
  for i = #blocks, 1, -1 do
    if blocks[i].t == "Header" then
      local j, lead = heading_chain(blocks, i)
      if j then
        local need = space(heading_need(blocks[j]))
        if requests[j] then
          need = string.format(
            "\\ifdim\\dimexpr %s\\relax<\\dimexpr %s\\relax %s\\else %s\\fi",
            requests[j], need, need, requests[j])
        end
        local chain = space(lead, need)
        requests[i] = requests[i]
          and string.format("\\ifdim\\dimexpr %s\\relax<\\dimexpr %s\\relax %s\\else %s\\fi",
                            requests[i], chain, chain, requests[i])
          or chain
      end
    end
  end

  local out = pandoc.Blocks({})
  for i, block in ipairs(blocks) do
    if requests[i] then
      out:insert(needspace(requests[i]))
    end
    out:insert(block)
  end
  return out
end
