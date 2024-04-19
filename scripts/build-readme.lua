local src = io.open ('picobloc.lua', 'r')
local dst = io.open ('readme.md', 'w')
for line in src:lines () do
  line = line:match '^%-%- ?(.*)$'
  if not line then
    break
  end
  dst:write (line .. '\n')
end

dst:write '\n## api\n'

local add_newline = true
for line in src:lines () do
  -- ignore section dividers
  if not line:match '^%-%-%-%-' then
    -- search for documentation comments
    line = line:match '^%-%-%-%s?(.*)$'
    if line then
      dst:write (add_newline and '\n' or '')
      dst:write (line .. '\n')
      add_newline = false
    else
      add_newline = true
    end
  end
end
