
;ms-winsoundevent:Notification[.Looping].[Mail/...]
;https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/adaptive-interactive-toasts

#TOAST_SOUND_SILENT$   = "Silent" ; Could be #Null$, this one is not important since it won't be added to the xml file.
#TOAST_SOUND_DEFAULT$  = "Default"
#TOAST_SOUND_IM$       = "IM"
#TOAST_SOUND_MAIL$     = "Mail"
#TOAST_SOUND_REMINDER$ = "Reminder"
#TOAST_SOUND_SMS$      = "SMS"
#TOAST_SOUND_ALARM$    = "Alarm"
#TOAST_SOUND_ALARM2$   = "Alarm2"
#TOAST_SOUND_ALARM3$   = "Alarm3"
#TOAST_SOUND_ALARM4$   = "Alarm4"
#TOAST_SOUND_ALARM5$   = "Alarm5"
#TOAST_SOUND_ALARM6$   = "Alarm6"
#TOAST_SOUND_ALARM7$   = "Alarm7"
#TOAST_SOUND_ALARM8$   = "Alarm8"
#TOAST_SOUND_ALARM9$   = "Alarm9"
#TOAST_SOUND_ALARM10$  = "Alarm10"
#TOAST_SOUND_CALL$     = "Call"
#TOAST_SOUND_CALL2$    = "Call2"
#TOAST_SOUND_CALL3$    = "Call3"
#TOAST_SOUND_CALL4$    = "Call4"
#TOAST_SOUND_CALL5$    = "Call5"
#TOAST_SOUND_CALL6$    = "Call6"
#TOAST_SOUND_CALL7$    = "Call7"
#TOAST_SOUND_CALL8$    = "Call8"
#TOAST_SOUND_CALL9$    = "Call9"
#TOAST_SOUND_CALL10$   = "Call10"

;{
; Enumeration ToastSoundType
; 	#TOAST_SOUND_SILENT
; 	#TOAST_SOUND_DEFAULT
; 	#TOAST_SOUND_IM
; 	#TOAST_SOUND_MAIL
; 	#TOAST_SOUND_REMINDER
; 	#TOAST_SOUND_SMS
; 	#TOAST_SOUND_ALARM
; 	#TOAST_SOUND_ALARM2
; 	#TOAST_SOUND_ALARM3
; 	#TOAST_SOUND_ALARM4
; 	#TOAST_SOUND_ALARM5
; 	#TOAST_SOUND_ALARM6
; 	#TOAST_SOUND_ALARM7
; 	#TOAST_SOUND_ALARM8
; 	#TOAST_SOUND_ALARM9
; 	#TOAST_SOUND_ALARM10
; 	#TOAST_SOUND_CALL
; 	#TOAST_SOUND_CALL2
; 	#TOAST_SOUND_CALL3
; 	#TOAST_SOUND_CALL4
; 	#TOAST_SOUND_CALL5
; 	#TOAST_SOUND_CALL6
; 	#TOAST_SOUND_CALL7
; 	#TOAST_SOUND_CALL8
; 	#TOAST_SOUND_CALL9
; 	#TOAST_SOUND_CALL10
; EndEnumeration
;}

EnumerationBinary ToastComponentTypes ; The name is good enough...
	#TOAST_COMPONENT_TYPE_TEXT
	#TOAST_COMPONENT_TYPE_IMAGE
; 	#TOAST_COMPONENT_TYPE_IMAGE_LOGO
; 	#TOAST_COMPONENT_TYPE_IMAGE_HERO
; 	#TOAST_COMPONENT_TYPE_IMAGE_INLINE
	#TOAST_COMPONENT_TYPE_PROGRESS_BAR
EndEnumeration

EnumerationBinary ToastComponentFlags
	;#TOAST_IMAGE_PLACEMENT_HERO   ; = "hero"
	;#TOAST_IMAGE_PLACEMENT_LOGO   ; = "appLogoOverride"
	;#TOAST_IMAGE_PLACEMENT_INLINE ; = "_INLINE"
	;#TOAST_IMAGE_CROPPING_NORMAL
	;#TOAST_IMAGE_CROPPING_CIRCLE
	
	#TOAST_TEXT_PLACEMENT_DEFAULT
	#TOAST_TEXT_PLACEMENT_ATTRIBUTION ; = "attribution"
	
	#TOAST_TEXT_STYLE_DEFAULT
	#TOAST_TEXT_STYLE_BASE           ; hint-style="base"
	#TOAST_TEXT_STYLE_CAPTION_SUBTLE ; hint-style="captionSubtle"
	
	#TOAST_TEXT_ALIGN_DEFAULT
	#TOAST_TEXT_ALIGN_RIGHT ; hint-align="right"
	
	#TOAST_DURATION_SHORT ; = "short"
	#TOAST_DURATION_LONG  ; = "long"
	
	#TOAST_SOUND_NORMAL
	#TOAST_SOUND_MUTED
	#TOAST_SOUND_LOOP
EndEnumeration

; Used for easy detection of changed param
#TOAST_MASK_TEXT_PLACEMENT = #TOAST_TEXT_PLACEMENT_DEFAULT | #TOAST_TEXT_PLACEMENT_ATTRIBUTION
#TOAST_MASK_TEXT_STYLE     = #TOAST_TEXT_STYLE_DEFAULT | #TOAST_TEXT_STYLE_BASE | #TOAST_TEXT_STYLE_CAPTION_SUBTLE
#TOAST_MASK_TEXT_ALIGN     = #TOAST_TEXT_ALIGN_DEFAULT | #TOAST_TEXT_ALIGN_RIGHT

Structure ToastTextComponentData
	Content$
	MaxLinesHint.i ; Max=2 for title, else 4
EndStructure

Structure ToastImageComponentData
	Src$
EndStructure

; Structure ProgressBarComponentData
; 	Content$
; EndStructure

Structure ToastComponent
	Type.l
	Flags.l
	
	*Text.ToastTextComponentData
	*Image.ToastImageComponentData
	;*ProgressBar.ProgressBarComponentData
EndStructure

Structure ToastContentSubgroup ; ~= Group Column
	List *Components.ToastComponent()
EndStructure

Structure ToastContentGroup
	SubgroupCount.i
	List *Subgroups.ToastContentSubgroup()
EndStructure

Structure ToastNotification
	AppID$
	Timestamp.l
	
	List *CoreComponents.ToastComponent()
	
	List *Groups.ToastContentGroup()
	
; ; 	Sound.s
; ; 	
; ; 	ActivationType.s
; ; 	Launch.s
; 	
; 	Duration.i
EndStructure



Procedure.s GenerateUUID4()
	Define.b i
	Define.s UUID
	Dim _UUID4Bytes.b(16)
	
	For i=0 To 16-1
		_UUID4Bytes(i)=Random(255)
	Next
	_UUID4Bytes(6)=64+Random(15)
	_UUID4Bytes(8)=128+Random(63)
	
	For i=0 To 16-1
		If i=4 Or i=6 Or i=8 Or i=10
			UUID.s+"-"
		EndIf
		UUID.s+RSet(Hex(_UUID4Bytes(i)&$FF),2,"0")
	Next
	
	FreeArray(_UUID4Bytes())
	ProcedureReturn UUID.s
EndProcedure

Procedure.i CreateToast(AppID$ = "Microsoft App")
	Protected *Toast.ToastNotification = AllocateMemory(SizeOf(ToastNotification))
	
	If *Toast
		InitializeStructure(*Toast, ToastNotification)
		
		*Toast\AppID$ = AppID$
	EndIf
	
	ProcedureReturn *Toast
EndProcedure

Procedure.i CreateToastComponent(ComponentType.l, ComponentFlags.l)
	Protected *Component.ToastComponent = AllocateMemory(SizeOf(ToastComponent))
	
	If *Component
		;InitializeStructure(*Component, ToastComponent) ; Pointless here
		*Component\Type = ComponentType
		*Component\Flags = ComponentFlags
	EndIf
	
	ProcedureReturn *Component
EndProcedure


Procedure.i CreateToastTextComponent(Text$="", ComponentFlags.l = 0, MaxLinesHint.i=-1)
	Protected *Component.ToastComponent = CreateToastComponent(#TOAST_COMPONENT_TYPE_TEXT, ComponentFlags)
	
	If *Component
		*Component\Text = AllocateMemory(SizeOf(ToastTextComponentData))
		
		If *Component\Text
			*Component\Text\Content$ = Text$
			*Component\Text\MaxLinesHint = MaxLinesHint
		Else
			; TODO: Free and cleanup
			;ProcedureReturn 0
		EndIf
	EndIf
	
	ProcedureReturn *Component
EndProcedure


Procedure.i CreateToastImageComponent(Src$="", ComponentFlags.l = 0)
	Protected *Component.ToastComponent = CreateToastComponent(#TOAST_COMPONENT_TYPE_IMAGE, ComponentFlags)
	
	If *Component
		*Component\Image = AllocateMemory(SizeOf(ToastImageComponentData))
		
		If *Component\Image
			*Component\Image\Src$ = Src$
		Else
			; TODO: Free and cleanup
			;ProcedureReturn 0
		EndIf
	EndIf
	
	ProcedureReturn *Component
EndProcedure


; Returns ptr or 0 if malloc error
Procedure.i CreateToastGroup(SubgroupCount.i = 2)
	Protected *Group.ToastContentGroup = AllocateMemory(SizeOf(ToastContentGroup))
	
	If *Group
		InitializeStructure(*Group, ToastContentGroup)
		
		*Group\SubgroupCount = SubgroupCount
		
		Protected i.i
		For i = 0 To SubgroupCount-1
			If Not AddElement(*Group\Subgroups())
				; TODO: FreeStructure(*Group) ; ???
				ProcedureReturn 0
			EndIf
			
			*Group\Subgroups() = #Null
		Next
	EndIf

	ProcedureReturn *Group
EndProcedure

Procedure.i CreateToastSubgroup()
	Protected *Subgroup.ToastContentSubgroup = AllocateMemory(SizeOf(ToastContentSubgroup))
	
	If *Subgroup
		InitializeStructure(*Subgroup, ToastContentSubgroup)
		
		;*Subgroup\TestUUID$ = GenerateUUID4()
	EndIf
	
	ProcedureReturn *Subgroup
EndProcedure

; CollumnIndex is zero indexed
; returns non-zero if added 0 if outside bonds
Procedure.b InsertToastSubgroup(*Group.ToastContentGroup, *Subgroup.ToastContentSubgroup, CollumnIndex.i=0)
	If *Group\SubgroupCount >= CollumnIndex And CollumnIndex >= 0
		SelectElement(*Group\Subgroups(), CollumnIndex)
		*Group\Subgroups() = *Subgroup
		
		ProcedureReturn #True
	EndIf
	
	ProcedureReturn #False
EndProcedure

Procedure.b InsertToastComponentIntoSubgroup(*Subgroup.ToastContentSubgroup, *Component.ToastComponent)
	If *Subgroup And *Component
		LastElement(*Subgroup\Components())
		
		If InsertElement(*Subgroup\Components())
			*Subgroup\Components() = *Component
			ProcedureReturn #True
		EndIf
	EndIf
	
	ProcedureReturn #False
EndProcedure


Procedure.b InsertToastCoreComponent(*Toast.ToastNotification, *Component.ToastComponent)
	If *Toast And *Component
		LastElement(*Toast\CoreComponents())
		
		If InsertElement(*Toast\CoreComponents())
			*Toast\CoreComponents() = *Component
			
			;ProcedureReturn #True
			ProcedureReturn ListSize(*Toast\CoreComponents())
		EndIf
	EndIf
	
	ProcedureReturn #False
EndProcedure


; Overwrite
Procedure.b SetToastComponentFlags(*Component.ToastComponent, ComponentFlags.l = 0)
	
EndProcedure

; Only change what is indicated
Procedure.b UpdateToastComponentFlags(*Component.ToastComponent, ComponentFlags.l = 0)
	
EndProcedure



Procedure.s GenerateToastXML(*Toast.ToastNotification)
	Protected XML$, XMLID = CreateXML(#PB_Any, #PB_UTF8)
	
	If XMLID
		; Creating the basic things
		NodeToast = CreateXMLNode(RootXMLNode(XMLID), "toast")
		
		If ListSize(*Toast\CoreComponents()) Or ListSize(*Toast\Groups())
			NodeVisuals = CreateXMLNode(NodeToast, "visual")
		EndIf
		
		;If ListSize actions ...
		
		FormatXML(XMLID, #PB_XML_WindowsNewline | #PB_XML_ReduceNewline | #PB_XML_ReIndent | #PB_XML_ReFormat)
		XML$ = ComposeXML(XMLID, #PB_XML_NoDeclaration)
		FreeXML(XMLID)
	EndIf
	
	ProcedureReturn XML$
EndProcedure



CompilerIf #PB_Compiler_IsMainFile
	*Toast = CreateToast("Test App")
	*Title = CreateToastTextComponent("Title", 0, 1)
	*Text  = CreateToastTextComponent("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
	
	InsertToastCoreComponent(*Toast, *Title)
	InsertToastCoreComponent(*Toast, *Text)
	
	Debug GenerateToastXML(*Toast)
	
	End
CompilerEndIf


; *A.ToastComponent = CreateToastTextComponent("Hello !", #TOAST_TEXT_STYLE_BASE)
; *B.ToastContentSubgroup = CreateToastSubgroup()
; *C.ToastContentGroup = CreateToastGroup(1)
; 
; If *A And *B And *C
; 	If InsertToastComponentIntoSubgroup(*B, *A) And InsertToastSubgroup(*C, *B)
; 			FirstElement(*C\Subgroups())
; 			FirstElement(*C\Subgroups()\Components())
; 			FirstElement(*B\Components())
; 			
; 			Debug *A\Flags & #TOAST_TEXT_STYLE_BASE
; 			Debug *A\Text\Content$
; 			
; 			Debug *B\Components()\Flags & #TOAST_TEXT_STYLE_BASE
; 			Debug *B\Components()\Text\Content$
; 			
; 			Debug *C\Subgroups()\Components()\Flags & #TOAST_TEXT_STYLE_BASE
; 			Debug *C\Subgroups()\Components()\Text\Content$
; 		EndIf
; 	EndIf
; EndIf
; 
; End


; Procedure.s GenerateToastXML(*Toast.ToastNotification)
; 	Declare *XML
; 	
; 	If CreateXML(0, #PB_UTF8)
; 		
; 		ExportXML(0, *Address, Size [, Flags])
; 		
; 		
; 		*XML = AllocateMemory(ExportXMLSize(0))
; 		
; 		If ExportXML(0, *XML, MemorySize(*XML))
; 			
; 		Else
; 			
; 		EndIf
; 		
; 		;FormatXML(#XML, Flags [, IndentStep]) ;?
; 		
; 		FreeXML(0)
; 	EndIf
; 	
; 	ProcedureReturn *XML\s
; EndProcedure

; *Test.ToastContentGroup = CreateToastGroup()
; 
; *Sub1.ToastContentSubgroup = CreateToastSubgroup()
; Debug *Sub1\Test$
; 
; InsertToastSubgroup(*Test, *Sub1, 1)
; 
; SelectElement(*Test\Subgroups(), 0)
; Debug *Test\Subgroups()
; SelectElement(*Test\Subgroups(), 1)
; Debug *Test\Subgroups()
; 
; Debug *Test\Subgroups()\Test$

;*Sub2.ToastContentSubgroup
;*Sub3.ToastContentSubgroup


; 
; 
; 
; 
; ;
; 
; 
; Global WorkingDirectory$ = GetTemporaryDirectory() + "OcelusSoft\notifications-util\"
; 
; Procedure Toast(Title$, Message$, Icon$, Audio$, Duration$="short", AppId$="OcelusWeatherNotifier")
; 	Args$ = "--app-id " + Chr(34) + AppId$ + Chr(34)
; 	Args$ = Args$ + " --title " + Chr(34) + Title$ + Chr(34)
; 	Args$ = Args$ + " --message " + Chr(34) + Message$ +  Chr(34)
; 	Args$ = Args$ + " --icon " + Chr(34) + Icon$ + Chr(34)
; 	Args$ = Args$ + " --audio " + Chr(34) + Audio$ + Chr(34)
; 	Args$ = Args$ + " --duration " + Chr(34) + Duration$ + Chr(34)
; 	
; 	Debug Args$
; 	
; 	RunProgram(WorkingDirectory$+"toast64-old.exe", Args$, "D:\Developement\Purebasic\notifications\", #PB_Program_Hide)
; EndProcedure
; 
; ;Toast("Test", "a&nbsp;b", "D:\BAK2\Pictures\Icons\W10\pngs\imageres.dll\imageres_14.png", "silent", "short", "CharToastTest")
; 
; 
; Template$ = ""
; 
; If ReadFile(0, "./toastTemplate.xml")
; 	While Eof(0) = 0
; 		Template$ = Template$ + ReadString(0) + #CRLF$
; 	Wend
; 	CloseFile(0)
; Else
; 	MessageRequester("Information","Couldn't open the file!")
; 	End
; EndIf
; 
; OutFilename$ = WorkingDirectory$ + "toast-" + LCase(GenerateUUID4())+".ps1"
; DeleteFile(OutFilename$)
; 
; Template$ = ReplaceString(Template$, "${toast.title}", "I'm the TrashMan !")
; Template$ = ReplaceString(Template$, "${toast.text1}", "I throw trash !")
; Template$ = ReplaceString(Template$, "${toast.text2}", "I eat garbage !")
; Template$ = ReplaceString(Template$, "${toast.text3}", "Gné ?")
; 
; If CreateFile(0, OutFilename$)
; 	WriteString(0, Template$)
; 	CloseFile(0)
; 	
; 	RunProgram("PowerShell", "-ExecutionPolicy Bypass -File "+OutFilename$, WorkingDirectory$, #PB_Program_Wait | #PB_Program_Hide)
; 	
; 	DeleteFile(OutFilename$)
; Else
; 	MessageRequester("Information","Couldn't create the file!")
; 	End
; EndIf
; 
; 
; 
; ; 
; ; Procedure.s ExportToPowerShellScriptString(*Toast.ToastNotification)
; ; 	
; ; EndProcedure
; ; 
; ; Procedure.s ExportToPowerShellScriptFile(*Toast.ToastNotification)
; ; 	
; ; EndProcedure
; ; 
; ; Procedure ExecuteToast(*Toast.ToastNotification)
; ; 	;RunProgram()
; ; EndProcedure

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 353
; FirstLine = 262
; Folding = 9f+
; EnableXP
; CompileSourceDirectory
; EnableCompileCount = 83
; EnableBuildCount = 0