XIncludeFile "../WindowsToastNotification.pbi"

Toast = CreateToast("My App")
TextTitle = CreateToastTextComponent("Hello World !", 0, 1)
TextMessage = CreateToastTextComponent("Lorem ipsum dolor sit amet, consectetur adipiscing elit. "+
                                       "Quisque eu odio imperdiet eros suscipit bibendum. In ut ex neque.", 0, 1)

If InsertToastCoreComponent(Toast, TextTitle) And InsertToastCoreComponent(Toast, TextMessage)
	Debug "Good"
	
	
	
Else
	MessageRequester("Error", "Couldn't insert a component inside a Toast notification !")
	End 1
EndIf

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 11
; EnableXP
; CompileSourceDirectory
; EnableCompileCount = 3
; EnableBuildCount = 0