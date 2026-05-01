import ../../base_types
import math
from raylib as ray import nil
import alignment

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
    vAlignment: VAlignment
    hAlignment: HAlignment
    usedWidth: int32 = 0 ## Width used by minimal size
    usedHeight: int32 = 0 ## Height used by minimal size
    heightFactorSum: int32 = 0 ## Sum of height factors
    widthFactorSum: int32 = 0 ## Sum of height factors

proc newBorderLayout*(name: string): BorderLayout =
  result = new (BorderLayout)
  initUiComponent(result, name)
  result.spacing = 2

proc vAlignment*(comp: BorderLayout): VAlignment =
  return comp.vAlignment

proc `vAlignment=`*(comp: BorderLayout, newValue: VAlignment) =
  if comp.vAlignment == newValue:
    return
  comp.vAlignment = newValue
  comp.uiNeedsLayoutUpdate

proc hAlignment*(comp: BorderLayout): HAlignment =
  return comp.hAlignment

proc `hAlignment=`*(comp: BorderLayout, newValue: HAlignment) =
  if comp.hAlignment == newValue:
    return
  comp.hAlignment = newValue
  comp.uiNeedsLayoutUpdate

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
      if not childrenArray[pos].comp.isExisting:
        continue
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
      if not childrenArray[pos].comp.isExisting:
        continue
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

method updateLayout*(comp: BorderLayout, availableSize: Size) =
  ## Method to set size, alignment with children, we run this only on root ui node
  ## Children are calculated recursively

  var newSize = availableSize
  applyMinMaxConstraint(newSize, comp.minConstraint, comp.maxConstraint)
  let parent = comp.parent

  # Phase 1: Get excess size
  if parent.isNil:
    # no parent Node so just return
    return

  var remainingWidth = newSize.width - comp.usedWidth
  let spacePerWidthFactor =
    if remainingWidth > 0:
      int32(remainingWidth / comp.widthFactorSum)
    else:
      0

  var x = comp.padding.left
  var haveExpandingWidth = comp.widthFactorSum > 0

  if not haveExpandingWidth and remainingWidth > 0:
    # No expanding so set vertical alignment
    case comp.hAlignment
    of HAlignment.Left:
      discard
    of HAlignment.Center:
      x += (remainingWidth / 2).int32
    of HAlignment.Right:
      x += remainingWidth

  var remainingHeight = newSize.height - comp.usedHeight
  let spacePerHeightFactor =
    if remainingHeight > 0:
      int32(remainingHeight / comp.heightFactorSum)
    else:
      0

  var y = comp.padding.top
  var haveExpandingHeight = comp.heightFactorSum > 0
  if not haveExpandingHeight and remainingHeight > 0:
    # No expanding so set vertical alignment
    case comp.vAlignment
    of VAlignment.Top:
      discard
    of VAlignment.Center:
      x += (remainingHeight / 2).int32
    of VAlignment.Bottom:
      x += remainingHeight

  var currentPos: BorderLayoutPosition = BorderLayoutPosition.Center
  var childrenArray: array[BorderLayoutPosition, tuple[node: Node, comp: UiComponent]]
  var availablePositions: BorderLayoutPositions
  for r in parent.getChildrenWithUi:
    childrenArray[currentPos] = r
    if r.comp.isExisting:
      availablePositions.incl(currentPos)
    if currentPos == high BorderLayoutPosition:
      break
    inc currentPos

  # check there is Left and Top position
  let leftWidthWithSpacing =
    if BorderLayoutPosition.Left in availablePositions:
      childrenArray[BorderLayoutPosition.Left].comp.minSize.width +
        childrenArray[BorderLayoutPosition.Left].comp.widthFactor * spacePerWidthFactor +
        comp.spacing
    else:
      0

  let topHeightWithSopacing =
    if BorderLayoutPosition.Top in availablePositions:
      childrenArray[BorderLayoutPosition.Top].comp.minSize.height +
        childrenArray[BorderLayoutPosition.Top].comp.heightFactor * spacePerHeightFactor +
        comp.spacing
    else:
      0

  # position of left, center, right
  var wasFirst = false
  var startX = x
  for pos in @[
    BorderLayoutPosition.Left, BorderLayoutPosition.Center, BorderLayoutPosition.Right
  ]:
    if pos in availablePositions:
      childrenArray[pos].node.x = x.float32
      childrenArray[pos].node.y = (y + topHeightWithSopacing).float32
      var size = Size(
        height:
          childrenArray[pos].comp.minSize.height +
          childrenArray[pos].comp.heightFactor * spacePerHeightFactor,
        width:
          childrenArray[pos].comp.minSize.width +
          childrenArray[pos].comp.widthFactor * spacePerWidthFactor,
      )
      applyMinMaxConstraint(
        size,
        childrenArray[pos].comp.minConstraint,
        childrenArray[pos].comp.maxConstraint,
      )
      childrenArray[pos].comp.size = size
      childrenArray[pos].comp.updateLayout(size)
      x += size.width
      if wasFirst and pos != BorderLayoutPosition.Right:
        x += comp.spacing
      else:
        wasFirst = true

  # position top:
  if BorderLayoutPosition.Top in availablePositions:
    childrenArray[BorderLayoutPosition.Top].node.x =
      (startX + leftWidthWithSpacing).float32
    childrenArray[BorderLayoutPosition.Top].node.y = y.float32
    var size = Size(
      height:
        childrenArray[BorderLayoutPosition.Top].comp.minSize.height +
        childrenArray[BorderLayoutPosition.Top].comp.heightFactor * spacePerHeightFactor,
      width:
        childrenArray[BorderLayoutPosition.Top].comp.minSize.width +
        childrenArray[BorderLayoutPosition.Top].comp.widthFactor * spacePerWidthFactor,
    )
    applyMinMaxConstraint(
      size,
      childrenArray[BorderLayoutPosition.Top].comp.minConstraint,
      childrenArray[BorderLayoutPosition.Top].comp.maxConstraint,
    )
    childrenArray[BorderLayoutPosition.Top].comp.size = size
    childrenArray[BorderLayoutPosition.Top].comp.updateLayout(size)

  # position bottom:
  if BorderLayoutPosition.Bottom in availablePositions:
    childrenArray[BorderLayoutPosition.Bottom].node.x =
      (startX + leftWidthWithSpacing).float32
    childrenArray[BorderLayoutPosition.Bottom].node.y =
      childrenArray[BorderLayoutPosition.Center].node.y + (
        childrenArray[BorderLayoutPosition.Center].comp.size.height + comp.spacing
      ).float32
    var size = Size(
      height:
        childrenArray[BorderLayoutPosition.Bottom].comp.minSize.height +
        childrenArray[BorderLayoutPosition.Bottom].comp.heightFactor *
        spacePerHeightFactor,
      width:
        childrenArray[BorderLayoutPosition.Bottom].comp.minSize.width +
        childrenArray[BorderLayoutPosition.Bottom].comp.widthFactor * spacePerWidthFactor,
    )
    applyMinMaxConstraint(
      size,
      childrenArray[BorderLayoutPosition.Bottom].comp.minConstraint,
      childrenArray[BorderLayoutPosition.Bottom].comp.maxConstraint,
    )
    childrenArray[BorderLayoutPosition.Bottom].comp.size = size
    childrenArray[BorderLayoutPosition.Bottom].comp.updateLayout(size)

  if comp.size == newSize:
    return
  comp.size = newSize
  parent.makeDirty
