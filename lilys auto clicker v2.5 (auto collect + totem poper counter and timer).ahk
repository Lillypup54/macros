;please if you change anything pls keep the names of peapoel that have helped code this
;lily(denoscar23)
global stop := false
global times_totom_pop := 0
global selected_slots := []
global slot_checkboxes := []
global slot_totem_inputs := []
global shown_help := false
global collect_only := false

; Separate totem count variables
global slot1_totem_lot := 0
global slot2_totem_lot := 0
global slot3_totem_lot := 0
global slot4_totem_lot := 0
global slot5_totem_lot := 0

myGui := Gui()
myGui.Title := "Control Panel"

myGui.Add("Text", , "Controls:")
stopBtn := myGui.Add("Button", "x10", "Stop")
stopBtn.OnEvent("Click", StopScript)

killBtn := myGui.Add("Button", "x+10", "Kill")
killBtn.OnEvent("Click", KillScript)


myGui.Add("Text", , "Select Totem Slots (1-5) and Totem Count:")

Loop 5 {
    index := A_Index
    cb := myGui.Add("Checkbox", "x10 y+" . (index = 1 ? "10" : "0"), "Slot " . index)
    cb.OnEvent("Click", UpdateSlotList)
    slot_checkboxes.Push(cb)

    tb := myGui.Add("Edit", "w50 x+10", "0")
    slot_totem_inputs.Push(tb)
}

discordCheck := myGui.Add("Checkbox", "x10 y+20", "Discord Setup?")

; Collect-only mode toggle checkbox + status text
collectOnlyCheck := myGui.Add("Checkbox", "x10 y+10", "Collect-Only Mode")
collectOnlyCheck.OnEvent("Click", ToggleCollectOnly)
collectStatusText := myGui.Add("Text", "x+10 yp", "")  ; shows "Running auto collect..."

; Show GUI with G
Hotkey("g", ShowGui)
ShowGui(*) {
    global shown_help
    if (!shown_help) {
        MsgBox("F = Start script`nG = Open Control Panel`nSelect totem slots and counts`nScript stops when all totems are gone or 'stop' is found in 'totems_popped.txt'`n'Collect-Only Mode' skips totem use and just presses 'E' every second")
        shown_help := true
    }
    myGui.Show()
}

; Toggle collect-only mode
ToggleCollectOnly(*) {
    global collect_only, collectOnlyCheck, collectStatusText
    collect_only := collectOnlyCheck.Value
    collectStatusText.Text := collect_only ? "Running auto collect..." : ""
}

; Start automation with F
Hotkey("f", StartAutomation)
StartAutomation(*) {
    global stop, times_totom_pop, selected_slots, collect_only
    global slot1_totem_lot, slot2_totem_lot, slot3_totem_lot, slot4_totem_lot, slot5_totem_lot
    stop := false
    times_totom_pop := 0
    index := 1
    selected_slots := []

    ; Update totem counts
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

    ; Ensure the file exists
    if !FileExist("totems_popped.txt") {
        FileAppend("Total popped: 0`nSlot1: 0`nSlot2: 0`nSlot3: 0`nSlot4: 0`nSlot5: 0`nRuntime (s): 0`n", "totems_popped.txt")
    }
    startTime := A_TickCount

    if (collect_only) {
        Loop {
            if stop
                return
            checkText := FileRead("totems_popped.txt")
            if InStr(checkText, "stop")
                return
            Send("{e down}")
            Sleep(50)
            Send("{e up}")
            elapsed := A_TickCount - startTime
            hours := Floor(elapsed / 3600000)
            minutes := Floor(Mod(elapsed, 3600000) / 60000)
            seconds := Floor(Mod(elapsed, 60000) / 1000)
            ToolTip("Time: " . Format("{:02}:{:02}:{:02}", hours, minutes, seconds))
            runtime := Floor((A_TickCount - startTime) / 1000)
            FileDelete("totems_popped.txt")
            FileAppend("Total popped: 0`n", "totems_popped.txt")
            FileAppend("Slot1: " slot1_totem_lot "`n", "totems_popped.txt")
            FileAppend("Slot2: " slot2_totem_lot "`n", "totems_popped.txt")
            FileAppend("Slot3: " slot3_totem_lot "`n", "totems_popped.txt")
            FileAppend("Slot4: " slot4_totem_lot "`n", "totems_popped.txt")
            FileAppend("Slot5: " slot5_totem_lot "`n", "totems_popped.txt")
            FileAppend("Runtime (s): " runtime "`n", "totems_popped.txt")
            Sleep(1000)
        }
    }

    if (selected_slots.Length = 0) {
        MsgBox("Please select at least one slot with at least 1 totem.")
        return
    }

    while (!stop) {
        checkText := FileRead("totems_popped.txt")
        if InStr(checkText, "stop")
            return

        current_slot := selected_slots[index]

        Send(current_slot)
        Sleep(150)
        MouseGetPos(&x, &y)
        Click x, y
        times_totom_pop++

        varname := "slot" current_slot "_totem_lot"
        %varname% -= 1
        remaining := %varname%

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
                return
            }
            if (index > selected_slots.Length)
                index := 1
            continue
        }

        duration := 10 ; cooldown
        Loop duration {
            if stop
                return
            checkText := FileRead("totems_popped.txt")
            if InStr(checkText, "stop")
                return

            timeLeft := duration - A_Index
            tooltipText := "Times popped: " . times_totom_pop
                . "`nCooldown: " Format("{:02}:{:02}", Floor(timeLeft / 60), Mod(timeLeft, 60))
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
}

UpdateSlotList(*) {
    ; GUI-only logic
}
KillScript(*) {
    ToolTip()
    ExitApp
}
