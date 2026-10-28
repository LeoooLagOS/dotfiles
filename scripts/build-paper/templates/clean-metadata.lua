-- clean-metadata.lua: runs first for every template.
-- An empty "bibliography:" (left blank in a starter) makes citeproc look for a file
-- with no name and fail; drop it so the note builds without references.

function Meta(meta)
  local bib = meta.bibliography
  if bib ~= nil and pandoc.utils.stringify(bib) == "" then
    meta.bibliography = nil
    return meta
  end
end
