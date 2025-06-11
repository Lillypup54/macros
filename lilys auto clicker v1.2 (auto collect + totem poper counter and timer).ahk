global stop := false
global times_totom_pop := 0
global selected_slots := []
global slot_checkboxes := []
global slot_totem_inputs := []
global shown_help := false

; Separate totem count variables
global slot1_totem_lot := 0
global slot2_totem_lot := 0
global slot3_totem_lot := 0
global slot4_totem_lot := 0
global slot5_totem_lot := 0

myGui := Gui()
myGui.Title := "Control Panel"

myGui.Add("Text", , "Stop Script:")
stopBtn := myGui.Add("Button", , "Stop")
stopBtn.OnEvent("Click", StopScript)

myGui.Add("Text", , "Select Totem Slots (1-5) and Totem Count:")

Loop 5 {
    index := A_Index
    cb := myGui.Add("Checkbox", "x10 y+" . (index = 1 ? "10" : "0"), "Slot " . index)
    cb.OnEvent("Click", UpdateSlotList)
    slot_checkboxes.Push(cb)

    tb := myGui.Add("Edit", "w50 x+10", "0")
    slot_totem_inputs.Push(tb)
}

myGui.Add("Checkbox", "x10 y+20", "Discord Setup?")

; Show GUI with G
Hotkey("g", ShowGui)
ShowGui(*) {
    global shown_help
    if (!shown_help) {
        MsgBox("F = start`nG = open control panel`nTotem slots must be checked and have amounts.`nScript stops when all totems are gone or 'stop' is found in the text file.`nThe cooldown loop ensures a delay between totem uses, displaying a countdown timer.`nTyping 'stop' in the 'totems_popped.txt' file will immediately terminate the script.(however this is discord setup)")
        shown_help := true
    }
    myGui.Show()
}

; Start automation with F
Hotkey("f", StartAutomation)
StartAutomation(*) {
    global stop, times_totom_pop, selected_slots
    global slot1_totem_lot, slot2_totem_lot, slot3_totem_lot, slot4_totem_lot, slot5_totem_lot
    stop := false
    times_totom_pop := 0
    index := 1
    selected_slots := []

    ; Update individual totem count variables
    slot1_totem_lot := slot_totem_inputs[1].Text + 0
    slot2_totem_lot := slot_totem_inputs[2].Text + 0
    slot3_totem_lot := slot_totem_inputs[3].Text + 0
    slot4_totem_lot := slot_totem_inputs[4].Text + 0
    slot5_totem_lot := slot_totem_inputs[5].Text + 0

    Loop 5 {
        if (slot_checkboxes[A_Index].Value) {
            varname := "slot" A_Index "_totem_lot"
            count := %varname%
            if (count > 0)
                selected_slots.Push(A_Index)
        }
    }

    if (selected_slots.Length = 0) {
        MsgBox("Please select at least one slot with at least 1 totem.")
        Return
    }

    ; Ensure the file exists before reading
    if !FileExist("totems_popped.txt") {
        FileAppend("Total popped: 0`nSlot1: 0`nSlot2: 0`nSlot3: 0`nSlot4: 0`nSlot5: 0`nRuntime (s): 0`n", "totems_popped.txt")
    }
    startTime := A_TickCount

    while (!stop) {
        checkText := FileRead("totems_popped.txt")
        if InStr(checkText, "stop") {
            ExitApp
        }

        current_slot := selected_slots[index]

        ; Send the number key for that slot
        Send(current_slot)
        Sleep(150)

        ; Click to use totem
        MouseGetPos(&x, &y)
        Click x, y
        times_totom_pop++

        ; Decrease count
        varname := "slot" current_slot "_totem_lot"
        %varname% -= 1
        remaining := %varname%

        ; Save data
        FileDelete("totems_popped.txt")
        FileAppend("Total popped: " times_totom_pop "`n", "totems_popped.txt")
        FileAppend("Slot1: " slot1_totem_lot "`n", "totems_popped.txt")
        FileAppend("Slot2: " slot2_totem_lot "`n", "totems_popped.txt")
        FileAppend("Slot3: " slot3_totem_lot "`n", "totems_popped.txt")
        FileAppend("Slot4: " slot4_totem_lot "`n", "totems_popped.txt")
        FileAppend("Slot5: " slot5_totem_lot "`n", "totems_popped.txt")
        runtime := Floor((A_TickCount - startTime) / 1000)
        FileAppend("Runtime (s): " runtime "`n", "totems_popped.txt")

        if (remaining <= 0) {
            selected_slots.RemoveAt(index)
            if (selected_slots.Length = 0) {
                MsgBox("All totems used up!")
                ToolTip()
                ExitApp
            }
            if (index > selected_slots.Length)
                index := 1
            continue
        }

        ; Cooldown loop
        duration := 10 ;360 for real use
        Loop duration {
            if stop {
                ToolTip()
                ExitApp
            }

            checkText := FileRead("totems_popped.txt")
            if InStr(checkText, "stop") {
                ExitApp
            }

            timeLeft := duration - A_Index
            minutes := Floor(timeLeft / 60)
            seconds := Mod(timeLeft, 60)
            countdownText := Format("{:02}:{:02}", minutes, seconds)
            tooltipText := "Times popped: " . times_totom_pop
                . "`nCooldown: " . countdownText
                . "`nCurrent Slot: " . current_slot
                . "`nTotems Left: " . remaining
            ToolTip(tooltipText)

            Send("{e down}")
            Sleep(50)
            Send("{e up}")
            Sleep(1000)
        }

        index++
        if (index > selected_slots.Length)
            index := 1
    }

    ToolTip()
}

StopScript(*) {
    global stop
    stop := true
    ToolTip()
    ExitApp
}

UpdateSlotList(*) {
    ; GUI only — full logic runs on start
}
