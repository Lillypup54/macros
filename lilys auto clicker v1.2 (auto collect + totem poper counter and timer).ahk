; made by lily(Denoscar33)
;you can modify but please put names that worked on it

global stop := false
global times_totom_pop := 0

; Create GUI with Stop button
myGui := Gui()
stopBtn := myGui.Add("Button", , "Stop Script")
stopBtn.OnEvent("Click", StopScript)

; Open GUI with G
G:: {
    myGui.Title := "Control Panel"
    myGui.Show()
}

; Hotkey F to start the auto-click loop
F:: {
    stop := false
    times_totom_pop := 0

    while (!stop) {
        ; Click immediately at current mouse position
        MouseGetPos(&x, &y)
        Click("left", x, y)
        times_totom_pop++

        duration := 360  ; 355 seconds = ~6 minutes cooldown
        Loop duration {
            if stop {
                ToolTip()
                Return
            }

            remaining := duration - A_Index
            minutes := Floor(remaining / 60)
            seconds := Mod(remaining, 60)
            countdownText := Format("{:02}:{:02}", minutes, seconds)
            tooltipText := "Times popped: " . times_totom_pop . "`nCooldown: " . countdownText
            ToolTip(tooltipText)

            ; Press E every second
            Send("{e down}")
            Sleep(50)
            Send("{e up}")

            Sleep(1000)
        }
    }
    ToolTip()
}

; Stop script when Stop button clicked
StopScript(*) {
    global stop
    stop := true
    ExitApp()
}
