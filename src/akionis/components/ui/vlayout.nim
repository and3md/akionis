import ../../base_types
import ../../colors
import ../../matrices
import math
import sequtils
from raylib as ray import nil

type VLayout = ref object of UiComponent
  usedHeight: int32

method draw*(comp: VLayout, camera: Camera) =
  discard

method updateSize*(comp: VLayout, availableArea: Rect) =
  ## Method to update size with children, we runt this only on root ui node
  ## Children are calculated recursively
  var newSize = comp.calculatedMinSize
  applyMinMaxSize(newSize, comp.minSize, comp.maxSize)
  let parent = comp.parent

  # Phase 1: Update children size
  if parent.isNil:
    # no parent Node o just return 
    return

  var children: seq[tuple[node: Node, comp: UiComponent]]
  for r in parent.getChildrenWithUi:
    if r.comp.isExisting:
      children.add(r)
      comp.updateSize(availableArea)

  var usedSpace: int32 = 0
  var heightFactorSum: int32 = 0
  var x: int32 = 0
  # Phase 2: Set position and calculate used space without 
  for r in children:
    r.node.x = float32(x + usedSpace)
    r.node.y = 0'f32 # temporary simplification
    usedSpace += r.comp.calculatedMinSize.height

  # Phase 3: Expand children to use remaining space - TODO

  newSize.height = usedSpace

  if comp.size == newSize:
    return
  comp.size = newSize
  parent.makeDirty
