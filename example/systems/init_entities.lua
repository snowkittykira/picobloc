return function (w)
  for i = 1, 4000 do
    w:add_entity {
      position = { x = rnd (480), y = rnd (270) },
      velocity = { x = rnd(1)-0.5, y = rnd(1)-0.5 },
      acceleration = { x = 0, y = 0.1 },
      sprite   = { size = 1 },
    }
  end
end
