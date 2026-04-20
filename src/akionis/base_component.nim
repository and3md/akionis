# Render component related things included to base_types

proc parent*(comp:Component): Node =
  return comp.parent