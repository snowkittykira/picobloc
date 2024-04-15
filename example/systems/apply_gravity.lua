return function (w)
  -- query all entities with a velocity and an acceleration
  w:query ({'velocity', 'acceleration'}, function (ids, velocities, accelerations)
    -- apply acceleration using bulk userdata operations
    velocities.x:add (accelerations.x, true, 0, 0, ids.count)
    velocities.y:add (accelerations.y, true, 0, 0, ids.count)
  end)
end
