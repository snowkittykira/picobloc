return function (w)
  -- query all entities with a position and a sprite
  w:query ({'position', 'sprite'}, function (ids, positions, sprites)
    -- draw all the sprites
    for i = 0, ids.count-1 do
      circ (positions.x[i], positions.y[i], sprites.size[i], 7)
    end
  end)
end
