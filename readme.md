# picobloc

an archetype and userdata-based ecs library for picotron

very much work in progress!

entities are just integer ids, components are sorted into archetypes based on their components,
component fields are in struct-of-arrays-style in picotron userdata for fast processing

it can also be used without picotron, in which case it stores component fields in lua tables (still 0-based)

## example usage

```lua
include 'picobloc.lua'
local w = World ()

-- define the components you're going to use
w:component ('position',     { x = 'f64', y = 'f64' })
w:component ('velocity',     { x = 'f64', y = 'f64' })
w:component ('acceleration', { x = 'f64', y = 'f64' })
w:component ('sprite',       { size = 'f64' })

-- create some entities
for i = 1, 4000 do
  w:add_entity {
    position = { x = rnd (480), y = rnd (270) },
    velocity = { x = rnd(1)-0.5, y = rnd(1)-0.5 },
    acceleration = { x = 0, y = 0.1 },
    sprite   = { size = 1 },
  }
end

function _update ()
  -- query all entities with a velocity and an acceleration
  w:query ({'velocity', 'acceleration'}, function (ids, velocities, accelerations)
    -- apply acceleration using bulk userdata operations
    velocities.x:add (accelerations.x, true, 0, 0, ids.count)
    velocities.y:add (accelerations.y, true, 0, 0, ids.count)
  end)

  -- query all entities with a position and a velocity
  w:query ({'position', 'velocity'}, function (ids, positions, velocities)
    -- apply motion using bulk userdata operations
    positions.x:add (velocities.x, true, 0, 0, ids.count)
    positions.x:mod (480, true, 0, 0, ids.count)
    positions.y:add (velocities.y, true, 0, 0, ids.count)
  end)

  w:query ({'position', 'velocity'}, function (ids, positions, velocities)
    -- when you can't use bulk operations, loop through the entities.
    --
    -- note that unlike regular lua tables, `ids` and the field buffers use zero-based indices.
    -- use ids.count to know how many items to process
    for i = 0, ids.count-1 do
      if positions.y[i] >= 270 then
        positions.y[i] = -1
        velocities.y[i] = rnd(1)
      end
    end
  end)
end

function _draw ()
  cls ()
  -- query all entities with a position and a sprite
  w:query ({'position', 'sprite'}, function (ids, positions, sprites)
    -- draw all the sprites
    for i = 0, ids.count-1 do
      circ (positions.x[i], positions.y[i], sprites.size[i], 7)
    end
  end)
end
```

the same example is presented in more structured way in the example/ folder

## api

todo

## other picotron ecs libraries

these two model entities as lua tables rather than integer ids, so are probably easier to use
if you aren't planning on using block userdata operations:

- [pecs](https://github.com/jesstelford/pecs/) - ecs for pico-8 and picotron in very few tokens
- [picotron-ECS-framework](https://github.com/abledbody/picotron-ECS-framework/) - ecs for picotron

## further reading

- [require function for loading lua modules](https://www.lexaloffle.com/bbs/?tid=140784) - used in `example/compat.lua`
- [picotron_userdata.txt](https://www.lexaloffle.com/dl/docs/picotron_userdata.html) - has information on block userdata operations
- [Picotron User Manual](https://www.lexaloffle.com/dl/docs/picotron_manual.html) - more up-to-date picotron info
