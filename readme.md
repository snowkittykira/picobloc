# picobloc

an archetype and userdata-based ecs library for the
[picotron fantasy workstation](https://www.lexaloffle.com/picotron.php).

very much work in progress!

entities are just integer ids, their data sorted into archetypes based on their components.
component fields are in struct-of-arrays-style in picotron userdata for fast processing.

it can also be used without picotron, in which case it stores component fields in lua tables (still 0-based).

## example usage

you can see the example running [here](https://www.lexaloffle.com/bbs/?tid=141824).

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

## other picotron ecs libraries

these two model entities as lua tables rather than integer ids, so are probably easier to use
if you aren't planning on using block userdata operations:

- [pecs](https://github.com/jesstelford/pecs/) - ecs for pico-8 and picotron in very few tokens
- [picotron-ECS-framework](https://github.com/abledbody/picotron-ECS-framework/) - ecs for picotron

## further reading

- [require function for loading lua modules](https://www.lexaloffle.com/bbs/?tid=140784) - used in `example/compat.lua`
- [picotron_userdata.txt](https://www.lexaloffle.com/dl/docs/picotron_userdata.html) - has information on block userdata operations
- [Picotron User Manual](https://www.lexaloffle.com/dl/docs/picotron_manual.html) - more up-to-date picotron info

## api

```lua
local world = World()
```

returns a new world object. it contains the rest of the api.

```lua
world.resources
```

not used by picobloc itself, the world contains a `resources` table which
you can use for storing any singletons or global state that needs to be
accessed by systems.

```lua
world:component (name, { field_name = field_type, ... })
```

creates a new component type. valid field types are the picotron userdata
types, or the string `'value'`, which means the field is stored in a plain
lua table instead of a userdata.

```lua
local id = world:add_entity ({ component_name = { component_field = value, ... }, ... })
```

adds an entity with the given components, initializing their fields to the
given values. missing fields are initialized to 0. if done within a query,
this operation will be deferred until the query ends, so don't modify the
passed table after calling this.

```lua
world:remove_entity (id)
```

removes an entity by id. if done within a query, this operation will be
deferred until the query ends.

```lua
world:entity_exists (id)
```

returns true if the entity exists, or false.

```lua
world:add_components (id, { component_name = { component_field = value, ...}, ...})
```

adds components to an existing entity. field values are initialized to the
provided values or to 0. adding a component that is already on the entity 
does nothing (i.e. the component values are not changed). if done within a
query, this operation will be deferred until the query ends, so don't
modify the passed table after calling this.

```lua
world:remove_components (id, { 'component_name', ...})
```

removes the named components from the entity. if done within a query, this
operation will be deferred until the query ends, so don't modify the passed
table after calling this.

```lua
world:query ({'component_query', ...}, function (ids, component_name, ...) ... end)
```

queries all entity archetypes and calls a function for each group that
matches. this is the main way to access entities. `fn` is called with the
following arguments:

- the map of `{index -> entity id}` for all the entities in this archetype.
- the maps of `{field -> buffer}` for the fields of each requested component.
  the buffers will usually be picotron userdata, but can be lua tables
  if the corresponding field type is `'value'` (or if not running in picotron).

note that all of these buffers (userdata or table) are *zero-based*, unlike
typical lua. `ids.count` gives the number of entities in this batch, so to
loop over all the entities, use `for i = 0, ids.count-1 do ... end`.

`'component_query'` can be:

- the name of a component, which will be required, its field buffers given
  as an argument to `fn`.
- a component name followed by `?`, which signals that the component is
  optional. the corresponding argument to `fn` will be `nil` if it isn't present.
- `!` followed by the name of the component, which means the archetype must
  not have the given component. no matching argument will be given to `fn`.

you may remove/add entities and components during a query, using the entity
ids in `ids`, but it won't actually happen until the whole query is done.

```lua
world:query_entity (id, {'component_query', ...}, function (index, component_name, ...) ... end)
```

queries an individual entity. use this to access/change an individual
entity's values. `fn` will be given the entity's index within the provided
buffers. if the entity does not match the given query, `fn` will not be called.

you may remove/add entities and components during a query, but it won't
actually happen until the whole query is done.

```lua
world:get_entity_component_values (id)
```
creates and returns a table containing a map of
`{component_name -> {field_name -> field_value}}`.
this is a copy of the original data, so modifying it has no effect on the
entity. use this when you want to get all the component values, without
knowing in advance which components are present.
