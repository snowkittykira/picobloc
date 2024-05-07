return function (world)
  -- query all entities with a position and a velocity
  world:query ({'position', 'velocity'}, function (ids, positions, velocities)
    -- apply motion using bulk userdata operations
    positions.x:add (velocities.x, true, 0, 0, ids.count)
    positions.x:mod (480, true, 0, 0, ids.count)
    positions.y:add (velocities.y, true, 0, 0, ids.count)
  end)
end
