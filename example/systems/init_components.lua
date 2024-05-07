return function (world)
  world:component ('position',     { x = 'f64', y = 'f64' })
  world:component ('velocity',     { x = 'f64', y = 'f64' })
  world:component ('acceleration', { x = 'f64', y = 'f64' })
  world:component ('sprite',       { size = 'f64' })
end
