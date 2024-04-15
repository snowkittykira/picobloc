return function (w)
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
