return function (world)
  world:query ({'position', 'velocity'}, function (ids, positions, velocities)
    -- when you can't use bulk operations, loop through the entities.
    --
    -- note that unlike regular lua tables, `ids` and the field buffers use zero-based indices.
    -- use ids.first and ids.last to loop over the indices.
    for i = ids.first, ids.last do
      if positions.y[i] >= 270 then
        positions.y[i] = -1
        velocities.y[i] = rnd(1)
      end
    end
  end)
end
