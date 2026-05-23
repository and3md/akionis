import events
from raylib as ray import nil
import matrices
import std/sequtils

type 
  InputAction = ref object of RootObj
    name: string
    ## Future input action to be implemented

  Input* = ref object of RootObj
    ## Gives access to input state with and without ui filtering
    leftClickHandledByUi: bool
    mouseMoveHandledByUi: bool
    pressedKeyshandledByUi: seq[KeyboardKey]
    actions: seq[InputAction]

var instance: Input = nil

proc getInput*(): Input =
  if instance.isNil:
    instance = new(Input)
  return instance

proc reset*(input: Input) =
  ## Resets input state used on frame start
  input.leftClickHandledByUi = false
  input.mouseMoveHandledByUi = false
  input.pressedKeyshandledByUi.setLen(0)


proc getMouseMoveDeltaUnfiltered*(input: Input): Vector2 =
  ## Gets mouse move delta from previous frame without checking was it handled by ui
  return ray.getMouseDelta()

proc isMouseButtonPressedUnfiltered*(input: Input, button: MouseButton): bool =
  ## Was mouse button presed in this frame (without checking was it handled by ui)
  return ray.isMouseButtonReleased(button)

proc isMouseButtonDownUnfiltered*(input: Input, button: MouseButton): bool =
  ## Is mouse button still down (without checking was it handled by ui)? 
  return ray.isMouseButtonDown(button)

proc isMouseButtonUpUnfiltered*(input: Input, button: MouseButton): bool =
  ## Is mouse button still up (without checking was it handled by ui)? 
  return ray.isMouseButtonUp(button)

proc isMouseButtonReleasedUnfiltered*(input: Input, button: MouseButton): bool =
  ## Was mouse button released in this frame (without checking was it handled by ui)
  return ray.isMouseButtonReleased(button)

proc isKeyPressedUnfiltered*(input: Input, key: KeyboardKey): bool =
  ## Was keyboard key pressed in this frame (without checking was it handled by ui)
  return ray.isKeyPressed(key)

proc isKeyDownUnfiltered*(input: Input, key: KeyboardKey): bool =
  ## Is keyboard key still down (without checking was it handled by ui)? 
  return ray.isKeyDown(key)

proc isKeyUpUnfiltered*(input: Input, key: KeyboardKey): bool =
  ## Is mouse button still up (without checking was it handled by ui)? 
  return ray.isKeyUp(key)

proc isKeyReleasedUnfiltered*(input: Input, key: KeyboardKey): bool =
  ## Was keyboard key released in this frame (without checking was it handled by ui)
  return ray.isKeyReleased(key)
