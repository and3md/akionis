import ../../base_types
import math
from raylib as ray import nil

type
  BorderLayoutPosition* {.pure.} = enum
    Center
    Right
    Bottom
    Left
    Top

  BorderLayoutPositions = set[BorderLayoutPosition]

  BorderLayout = ref object of UiComponent
    ## The layout that the first child takes as the center, the next as the right side,
    ## the next as the bottom side, the next as the left side, the next as the top side,
    ##
    ## To skip any side insert child with isExisting = false
    spacing: int32 ## Space between components
    usedWidth: int32 = 0 ## Width used by minimal size
    usedHeight: int32 = 0 ## Height used by minimal size
    heightFactorSum: int32 = 0 ## Sum of height factors
    widthFactorSum: int32 = 0 ## Sum of height factors

proc newBorderLayout*(name: string): BorderLayout =
  result = new (BorderLayout)
  initUiComponent(result, name)
  result.spacing = 2

proc spacing*(comp: BorderLayout): int32 =
  return comp.spacing

proc `spacing=`*(comp: BorderLayout, newSpacingValue: int32) =
  if comp.spacing == newSpacingValue:
    return
  comp.spacing = newSpacingValue
  comp.uiNeedsLayoutUpdate

method draw*(comp: BorderLayout, camera: Camera) =
  discard

method calculateMinSize*(comp: BorderLayout) =
  # Reset values
  comp.usedWidth = 0
  comp.usedHeight = 0
  comp.heightFactorSum = 0
  comp.widthFactorSum = 0

  var newSize = Size(width: 0, height: 0)
  let parent = comp.parent

  # Phase 1: Calculate children min size
  if parent.isNil:
    # no parent Node so just return
    return

  var currentPos: BorderLayoutPosition = BorderLayoutPosition.Center
  var childrenArray: array[BorderLayoutPosition, tuple[node: Node, comp: UiComponent]]
  var availablePositions: BorderLayoutPositions
  for r in parent.getChildrenWithUi:
    childrenArray[currentPos] = r
    availablePositions.incl(currentPos)
    if currentPos == high BorderLayoutPosition:
      break
    inc currentPos
    if r.comp.isExisting:
      r.comp.calculateMinSize

  # calculate used width
  comp.usedWidth = comp.padding.left
  var wasFirst = false
  for pos in @[
    BorderLayoutPosition.Left, BorderLayoutPosition.Center, BorderLayoutPosition.Right
  ]:
    if pos in availablePositions:
      if wasFirst:
        comp.usedWidth += comp.spacing
      else:
        wasFirst = true
    comp.usedWidth += childrenArray[pos].comp.minSize.width
    comp.widthFactorSum += childrenArray[pos].comp.widthFactor
  comp.usedWidth += comp.padding.right

  # calculate used height
  comp.usedHeight = comp.padding.top
  wasFirst = false
  for pos in @[
    BorderLayoutPosition.Top, BorderLayoutPosition.Center, BorderLayoutPosition.Bottom
  ]:
    if pos in availablePositions:
      if wasFirst:
        comp.usedHeight += comp.spacing
      else:
        wasFirst = true
    comp.usedHeight += childrenArray[pos].comp.minSize.height
    comp.heightFactorSum += childrenArray[pos].comp.heightFactor
  comp.usedHeight += comp.padding.bottom

  newSize.width = comp.usedWidth
  newSize.height = comp.usedHeight
  comp.minSize = newSize

