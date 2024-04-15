local src = io.open ('picobloc.lua', 'r')
local dst = io.open ('readme.md', 'w')
for line in src:lines () do
  line = line:match ('^%-%- ?(.*)$')
  if not line then
    break
  end
  dst:write (line .. '\n')
end
