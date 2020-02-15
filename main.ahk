#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


DetectHiddenWindows, On


; position de l'interface :
guiX := 0
guiY := 450


Gosub, loadFiles
Gosub, sortPerso

currentPerso := 1

canSkip := 1
nbDead := 0

Gosub, Select

Gosub, checkEndTurn





checkEndTurn:
    if (canSkip = 1) {
        ImageSearch, OutputVarX, OutputVarY, % PosFinTour[1]+(Floor((PosFinTour[3]-PosFinTour[1])/2)), % PosFinTour[2], % PosFinTour[3], % PosFinTour[4], %A_WorkingDir%\files\end.png
        if (ErrorLevel != 1 && ErrorLevel != 2) {
            Sleep, 100
            Gosub, switchRight
            Gosub, Select
            canSkip = 0
            nbDead = 0
        }
    }
    if (canSkip = 0) {
        ImageSearch, OutputVarX, OutputVarY, % PosFinTour[1]+(Floor((PosFinTour[3]-PosFinTour[1])/2)), % PosFinTour[2], % PosFinTour[3], % PosFinTour[4], %A_WorkingDir%\files\actual.png
        if (ErrorLevel != 1 && ErrorLevel != 2) {
            Sleep, 100
            canSkip = 1
            nbDead = 0
        }
    }
    if (nbDead < NbPersos) {
        ImageSearch, OutputVarX, OutputVarY, % PosFinTour[1], % PosFinTour[2], % PosFinTour[1]+Floor((PosFinTour[3]-PosFinTour[1])/2), % PosFinTour[2]+Floor((PosFinTour[4]-PosFinTour[2])/2), %A_WorkingDir%\files\dead.png
        if (ErrorLevel != 1 && ErrorLevel != 2) {
            Sleep, 100
            Gosub, switchRight
            Gosub, Select
            nbDead += 1
        }
    }
    Sleep, 1000
    Gosub, checkEndTurn
Return





!e::
    Gosub, switchRight
    Gosub, Select
Return

!a::
    Gosub, switchLeft
    Gosub, Select
Return






switchLeft:
    currentPerso -= 1
    if (currentPerso < 1)
    {
        currentPerso := NbPersos
    }
Return

switchRight:
    currentPerso += 1
    if (currentPerso > NbPersos)
    {
        currentPerso := 1
    }
Return






SelectFromGui:
    StringTrimLeft, currentPerso, A_GuiControl, 1
    Gosub, Select
Return

Select:
    Gosub, remakeGui
    window := % NomPersos[currentPerso]
    window := StrSplit(window, " ")[1]" "
    WinActivate, %window%
    Sleep, 50
Return






remakeGui:
    Gui, Destroy
    Gosub, makeGui
Return

makeGui:
    Gui, +AlwaysOnTop

    Gosub, setPersos

    for index, element in NomPersos
    {
        perso := % NomPersos[index]
        perso := StrSplit(perso, " ")[1]

        init := % NomPersos[index]
        init := StrSplit(init, " ")[2]

        if (index = currentPerso)
        {
            Gui, Font, s15
        } else {
            Gui, Font, s12
        }
        yPos := (index-1) * 50 + 60
        Gui, Add, Text, x0 y%yPos% w120 Center cBlack vp%index% gSelectFromGui, %perso%

        Gui, Font, s12
        Gui, Add, Text, x120 y%yPos% w40 h24 Center cBlack, %init%
    }

    num := 0

    for index, element in listePersos
    {
        perso := % listePersos[index]" "
        if (WinExist(StrSplit(perso, " ")[1]" ")) {
            yPos := (num) * 50 + 50
            Gui, Add, Button, x160 y%yPos% w20 h20 vm%index% gMoreInit, +
            yPos += 20
            Gui, Add, Button, x160 y%yPos% w20 h20 vl%index% gLessInit, -
            num += 1
        }
    }

    Gui, Add, Button, x130 y10 w60 h24 gReload, reload
    Gui, Add, Button, x10 y10 w60 h24 gSavePositions, save

    height := NbPersos*50 + 50
    Gui, Show, w200 h%height% x%guiX% y%guiY%, game

    WinActivate, game
Return

MoreInit:
    StringTrimLeft, numPerso, A_GuiControl, 1

    line := listePersos[numPerso]
    numberInit := StrSplit(line, " ")[2] + 1

    listePersos[numPerso] := StrSplit(line, " ")[1] " " numberInit
    
    Gosub, remakeGui
return

LessInit:
    StringTrimLeft, numPerso, A_GuiControl, 1

    line := listePersos[numPerso]
    numberInit := StrSplit(line, " ")[2] - 1

    listePersos[numPerso] := StrSplit(line, " ")[1] " " numberInit
    
    Gosub, remakeGui
return

Reload:
    currentPerso := 1
    canSkip := 1
    nbDead := 0
    Gosub, loadFiles
    Gosub, sortPerso
    Gosub, remakeGui
    Gosub, Select
Return

SavePositions:
    Gui, Submit, NoHide
    FileDelete, %A_WorkingDir%\files\persos.ini
    for index, element in listePersos
    {
        FileAppend, %element% `n, %A_WorkingDir%\files\persos.ini
    }
Return

setPersos:
    NomPersos := Array()
    cpt := 0
    for index, element in listePersos
    {
        perso := % listePersos[index]" "
        if (WinExist(StrSplit(perso, " ")[1]" ")) {
            cpt += 1
            NomPersos[cpt] := perso
        }
    }
    NbPersos := % cpt
Return

loadFiles:
    listePersos := Array()
    Loop, Read, %A_WorkingDir%\files\persos.ini
    {
        listePersos.Push(A_LoopReadLine)
    }

    PosFinTour := Array()
    Loop, Read, %A_WorkingDir%\files\barPos.ini
    {
        PosFinTour.Push(A_LoopReadLine)
    }
Return

sortPerso:
    listePersos := sort(listePersos)
    listePersos := reverseArray(listePersos)
return

GuiClose:
ExitApp

; ^Space::
; ExitApp




; TRI

sort(tabl) {
    index1 := 1
    while (index1 < tabl.MaxIndex())
    {
        index2 := % index1 + 1
        positionMin := % index1
        while (index2 < tabl.MaxIndex()+1)
        {
            if (StrSplit(tabl[index2], " ")[2] < StrSplit(tabl[positionMin], " ")[2])
            {
                positionMin = % index2
            }
            index2 += 1
        }
        if (positionMin != index1)
        {
            temp := % tabl[index1]
            tabl[index1] := tabl[positionMin]
            tabl[positionMin] := temp
        }
        index1 += 1
    }
    Return tabl
}

reverseArray(tabl) {
    index1 := 1
    while (index1 < Floor((tabl.MaxIndex()+1) / 2))
    {
        index2 := % tabl.MaxIndex() + 1 - index1

        temp := % tabl[index1]
        tabl[index1] := tabl[index2]
        tabl[index2] := temp
        index1 += 1
    }
    return tabl
}

step(Start, End, Step=1) { ; written by Lexikos
   static base := Object("_NewEnum", "step_enum", "Next", "step_next")
   return Object(1, Start-Step, 2, End, 3, Step, "base", base)
}
step_enum(list) {
   return list
}
step_next(list, ByRef var) {
   return (var := list[1] := list[1] + list[3]) <= list[2]
}