-- table-captions.lua: table captions for templates that turn longtable into
-- tabular/supertabular (std-report, ieee), where \caption is not allowed.
-- Moves each caption above its table as \captionof{table}{...} (capt-of package).

if not FORMAT:match("latex") then return {} end

function Table(tbl)
  if #tbl.caption.long == 0 then return nil end
  local caption = pandoc.write(pandoc.Pandoc(tbl.caption.long), "latex"):gsub("%s+$", "")
  tbl.caption.long = {}
  return {
    -- A group, not a center environment: center adds space before the table too
    pandoc.RawBlock("latex", "{\\centering\\captionof{table}{" .. caption .. "}\\par}"),
    tbl,
  }
end
