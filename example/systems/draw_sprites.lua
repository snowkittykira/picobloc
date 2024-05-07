return function (world)
  -- query all entities with a position and a sprite
  world:query ({'position', 'sprite'}, function (ids, positions, sprites)
    -- draw all the sprites
    for i = ids.first, ids.last do
      circ (positions.x[i], positions.y[i], sprites.size[i], 7)
    end
  end)
end
