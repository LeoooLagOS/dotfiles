--[[
keep-with-table.lua (build-paper, LaTeX output)

Problem: the template's \Needspace runs when a longtable starts, so when a
table doesn't fit, the table moves to the next page and the paragraph that
introduces it ("**Cliente**", "Las relaciones son:") stays behind, alone at
the bottom of the page. Short tables also split across two pages.

Fix: before a table or code block, ask LaTeX for enough free space for the
introducing paragraph plus (an estimate of) the block. If there isn't, the
page breaks before the paragraph, so both move together. Blocks taller than
MAX_LINES still break across pages, as they must.
--]]

if not FORMAT:match("latex") then
  return {}
end

local MAX_LINES = 34      -- about 3/4 of a page; longer blocks may still split
local INTRO_LINES = 3     -- room for the introducing paragraph

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

local function block_lines(block)
  if not block then
    return nil
  elseif block.t == "Table" then
    return table_lines(block)
  elseif block.t == "CodeBlock" then
    return code_lines(block)
  end
  return nil
end

local function needspace(lines)
  lines = math.min(lines, MAX_LINES)
  -- \Needspace comes from the template's needspace package; skip it if absent.
  return pandoc.RawBlock("latex",
    string.format("\\ifdefined\\Needspace\\Needspace{%d\\baselineskip}\\fi", lines))
end

local function is_intro(block)
  return block and (block.t == "Para" or block.t == "Plain")
end

function Blocks(blocks)
  local out = pandoc.Blocks({})
  for i, block in ipairs(blocks) do
    local next_lines = block_lines(blocks[i + 1])
    local own_lines = block_lines(block)

    if is_intro(block) and next_lines then
      -- paragraph introducing a table or code block: keep them together
      out:insert(needspace(next_lines + INTRO_LINES))
    elseif own_lines and not is_intro(blocks[i - 1]) then
      -- table or code block with no introduction: keep short ones whole
      out:insert(needspace(own_lines))
    end
    out:insert(block)
  end
  return out
end
