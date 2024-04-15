return function (w)
  w:component ('position',     { x = 'f64', y = 'f64' })
  w:component ('velocity',     { x = 'f64', y = 'f64' })
  w:component ('acceleration', { x = 'f64', y = 'f64' })
  w:component ('sprite',       { size = 'f64' })
end
