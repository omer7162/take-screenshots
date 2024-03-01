Global ScreenshotIndex := -1
Global LastScreenshotNumber := -1
Global ScreenshotBasePath := "C:\Users\omera\Desktop\Screenshots\"
Global NirCmdPath := "C:\Windows\nircmd\nircmd.exe"

; Ensure the Screenshots directory exists
FileCreateDir, %ScreenshotBasePath%

; Hotkey for regular screenshot without mouse mark
^+F1::CaptureScreenshot(false)

; Hotkey for screenshot with mouse location marked
^+F2::CaptureScreenshot(true)

CaptureScreenshot(MarkMouse) {
	DeleteTempFiles(ScreenshotBasePath)
    If (!MarkMouse) {
        ; Increment for a new screenshot without a mouse click mark
        ScreenshotIndex := IncrementFilename()
        LastScreenshotNumber := ScreenshotIndex
    } Else {
        ; Use the last screenshot number for the click-marked screenshot
        ScreenshotIndex := LastScreenshotNumber
    }
    
    ; Determine the filename
    FileName := (MarkMouse ? ScreenshotIndex "-Temp.png" : ScreenshotIndex ".png")
    
    ; Full path for the screenshot
    FullPath := ScreenshotBasePath . FileName
    
    ; Capture the screenshot using NirCmd
    Run, %NirCmdPath% savescreenshotfull %FullPath%
    Sleep, 1000 ; Wait a bit to ensure the screenshot is saved
    
    ; If marking the mouse, capture mouse position and mark it
    If (MarkMouse) {
        WinGetPos, WinX, WinY, , , A  ; Get active window's top-left corner
		MouseGetPos, MouseX, MouseY, , , 2  ; Get mouse position relative to the active window
		MouseX := WinX + MouseX  ; Calculate absolute X
		MouseY := WinY + MouseY  ; Calculate absolute Y
        ; This function will edit the image at FullPath to add an "X" at (MouseX, MouseY)
        MarkMouseLocation(FullPath, MouseX, MouseY)
    }
    Return
	}

	IncrementFilename() {
		Global ScreenshotIndex
		return ScreenshotIndex + 1
	}

	MarkMouseLocation(ImagePath, X, Y) {
		; Define the path to the overlay image (red_x.png)
		OverlayImagePath := ScreenshotBasePath . "\red_x.png"
		
		X := X - 47 ; Half the width of the overlay image
		Y := Y - 45 ; Half the height of the overlay image

		; Define the output image path
		OutputImagePath := ScreenshotBasePath . ScreenshotIndex . "-Click.png"

		; FFmpeg command to overlay an image on top of another image
		FFmpegCommand := "ffmpeg -y -i """ . ImagePath . """ -i """ . OverlayImagePath . """ -filter_complex """
						. "overlay=" . X . ":" . Y . """ """ . OutputImagePath . """"

		; Execute the FFmpeg command
		Run, %ComSpec% /c %FFmpegCommand%, , Hide
	}


	DeleteTempFiles(Directory) {
		Loop, Files, % Directory "*-Temp.*", F
			FileDelete, %A_LoopFileFullPath%
	}
	