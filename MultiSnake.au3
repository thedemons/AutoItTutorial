#include <GDIPLus.au3>
#include <Misc.au3>
 
; GDI+
Global $hGraphic, $g_hBitmap, $g_hGfxCtxt
Global $hPen, $hPenRed, $hBrush, $hBrushFood
Global $cBackground = 0xFFFFFFFF
 
 
; snake
Global $startLen = 4
Global $numberSnake = 10
 
Global $Snake[$numberSnake]
Global $Direction[$numberSnake]
Global $State[$numberSnake]
Global $Food[$numberSnake][2]
 
 
; gui
Global $GridSize = 30
Global $GridCount = 30
 
Global $GUI, $GuiW = $GridSize * $GridCount, $GuiH = $GridSize * $GridCount
 
$GUI = GUICreate("", $GuiW, $GuiH)
GUISetState()
 
 
CreateSnake()
 
_Graphic_StartUp()
 
While 1
 
    BotSnake()
    MoveSnake()
    CheckGame()
    Draw()
 
    Switch GUIGetMsg()
        Case -3
            Exit
    EndSwitch
 
WEnd
 
Func BotSnake()
 
    For $i = 0 To $numberSnake - 1
 
        $Position = $Snake[$i]
        $x = $Position[0][0]
        $y = $Position[0][1]
 
        $x_food = $Food[$i][0]
        $y_food = $Food[$i][1]
 
        If Random(0, 1, 1) = 0 Then
 
            If $x <= $x_food Then $iDirection = 2
            If $x > $x_food Then $iDirection = 0
 
        Else
 
            If $y <= $y_food Then $iDirection = 3
            If $y > $y_food Then $iDirection = 1
 
        EndIf
 
        ChangeDirection($i, $iDirection)
 
    Next
 
EndFunc
 
Func ChangeDirection($i, $iDirection)
 
    If $Direction[$i] = 0 And $iDirection = 2 Then Return
    If $Direction[$i] = 1 And $iDirection = 3 Then Return
    If $Direction[$i] = 2 And $iDirection = 0 Then Return
    If $Direction[$i] = 3 And $iDirection = 1 Then Return
 
    $Direction[$i] = $iDirection
 
EndFunc
 
Func CreateSnake()
 
    Local $Position[$startLen][2]
 
    For $i = 0 To $numberSnake - 1
 
        $randomX = Random($startLen - 1, $GridCount, 1)
        $randomY = Random(0, $GridCount, 1)
 
        For $iPos = 0 to $startLen - 1
 
            $Position[$iPos][0] = $randomX - $iPos
            $Position[$iPos][1] = $randomY
 
        Next
 
        $Food[$i][0] = Random(0, $GridCount - 1, 1)
        $Food[$i][1] = Random(0, $GridCount - 1, 1)
 
        $State[$i] = True
        $Direction[$i] = Random(1, 3, 1) ; 0 = left; 1 = up; 2 = right; 3 = down
        $Snake[$i] = $Position
 
    Next
EndFunc
 
Func MoveSnake()
 
    Local $State, $Position
 
    For $i = 0 To $numberSnake - 1
 
        $Position = $Snake[$i]
 
        $x = $Position[0][0]
        $y = $Position[0][1]
 
        __GetDirection($Direction[$i], $x, $y)
 
        ; move snake
 
        For $iPos = UBound($Position) - 1 to 1 step - 1
 
            $Position[$iPos][0] = $Position[$iPos - 1][0]
            $Position[$iPos][1] = $Position[$iPos - 1][1]
        Next
 
        $Position[0][0] = $x
        $Position[0][1] = $y
 
        $Snake[$i] = $Position
 
        $State = CheckSnake($i)
 
        Switch $State
 
            Case -1
                KillSnake($i)
 
            Case 1
                EatFood($i)
 
        EndSwitch
    Next
EndFunc
 
Func EatFood($i)
 
    $Position = $Snake[$i]
 
    $len = UBound($Position)
 
    ReDim $Position[$len + 1][2]
 
    ; new tail = tail
    $Position[$len][0] = $Position[$len - 1][0]
    $Position[$len][1] = $Position[$len - 1][1]
 
    ; recreate food
    $Food[$i][0] = Random(0, $GridCount - 1, 1)
    $Food[$i][1] = Random(0, $GridCount - 1, 1)
 
    $Snake[$i] = $Position
 
EndFunc
 
Func KillSnake($i)
 
    $State[$i] = False
 
EndFunc
 
Func CheckGame()
 
    For $i = 0 To $numberSnake - 1
 
        If $State[$i] = True Then Return
    Next
 
    CreateSnake()
 
EndFunc
 
Func CheckSnake($i)
 
    $Position = $Snake[$i]
 
    $x = $Position[0][0]
    $y = $Position[0][1]
 
    If $x < 0 Or $x >= $GridCount Then Return -1
    If $y < 0 Or $y >= $GridCount Then Return -1
 
    For $iPos = 1 To UBound($Position) - 1
 
        If $x = $Position[$iPos][0] And $y = $Position[$iPos][1] Then Return -1
 
    Next
 
    If $x = $Food[$i][0] And $y = $Food[$i][1] Then Return 1
 
EndFunc
 
Func __GetDirection($iDirection, ByRef $x, ByRef $y)
 
    ; get direction
    Switch $iDirection
 
        Case 0 ; left
            $x -= 1
 
        Case 1 ; up
            $y -= 1
 
        Case 2 ; right
            $x += 1
 
        Case 3 ; down
            $y += 1
    EndSwitch
 
EndFunc
 
Func Draw()
 
    _GDIPlus_GraphicsClear($g_hGfxCtxt, $cBackground)
 
    For $i = 0 To $numberSnake - 1
 
        If $State[$i] = False Then ContinueLoop
 
        $Position = $Snake[$i]
 
        For $iPos = 0 To UBound($Position) - 1
 
            $x = $Position[$iPos][0] * $GridSize
            $y = $Position[$iPos][1] * $GridSize
 
            _GDIPlus_GraphicsFillRect($g_hGfxCtxt, $x, $y, $GridSize, $GridSize, $hBrush)
            _GDIPlus_GraphicsDrawRect($g_hGfxCtxt, $x, $y, $GridSize, $GridSize, $hPen)
 
 
        Next
 
        $x_head = $Position[0][0] * $GridSize
        $y_head = $Position[0][1] * $GridSize
        $x_food = $Food[$i][0] * $GridSize
        $y_food = $Food[$i][1] * $GridSize
 
        _GDIPlus_GraphicsFillRect($g_hGfxCtxt, $x_food, $y_food, $GridSize, $GridSize, $hBrushFood)
        _GDIPlus_GraphicsDrawRect($g_hGfxCtxt, $x_food, $y_food, $GridSize, $GridSize, $hPen)
        _GDIPlus_GraphicsDrawLine($g_hGfxCtxt, $x_head + $GridSize / 2, $y_head + $GridSize / 2, $x_food + $GridSize / 2, $y_food + $GridSize / 2, $hPenRed)
 
 
    Next
 
    _GDIPlus_GraphicsDrawImageRect($hGraphic, $g_hBitmap, 0, 0, $GuiW, $GuiH)
 
EndFunc
 
Func _Graphic_StartUp()
 
    _GDIPlus_Startup()
 
    ; install gdi
    $hGraphic = _GDIPlus_GraphicsCreateFromHWND($GUI)
    $g_hBitmap = _GDIPlus_BitmapCreateFromGraphics($GuiW, $GuiH, $hGraphic)
    $g_hGfxCtxt = _GDIPlus_ImageGetGraphicsContext($g_hBitmap)
    _GDIPlus_GraphicsSetSmoothingMode($g_hGfxCtxt, 2)
 
    $hBrush = _GDIPlus_BrushCreateSolid(0xFFFFFFFF)
    $hBrushFood = _GDIPlus_BrushCreateSolid(0xFFFF0000)
    $hPen = _GDIPlus_PenCreate(0xFF000000, 2)
    $hPenRed = _GDIPlus_PenCreate(0xFFFF0000)
 
 
EndFunc
