include 'compat.lua' -- note: this provides 'require'
local picobloc = require 'picobloc' -- make sure picobloc.lua is in the same folder
local w = picobloc.World ()

-- define the components you're going to use
require 'systems.init_components' (w)
-- create some entities
require 'systems.init_entities' (w)


function _update ()
  -- run the update systems
  require 'systems.apply_gravity' (w)
  require 'systems.apply_velocity' (w)
  require 'systems.keep_on_screen' (w)
end

function _draw ()
  cls ()
  -- run the draw systems
  require 'systems.draw_sprites' (w)
end
