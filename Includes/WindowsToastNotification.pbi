; ﻿╔═══════════════════════════════════════════════════════════════════╦════════╗
; ║ Purebasic Utils - Windows Toast Notification                      ║ v0.0.0 ║
; ╠═══════════════════════════════════════════════════════════════════╩════════╣
; ║                                                                            ║
; ║   [Add something here...]                                                  ║
; ║                                                                            ║
; ╟────────────────────────────────────────────────────────────────────────────╢
; ║ Requirements: PB v5.62+ (Not tested on previous versions)                  ║
; ║               Windows 8+ (Preferably W10)                                  ║
; ╟────────────────────────────────────────────────────────────────────────────╢
; ║ Documentation: NOT DONE !!!                                                ║
; ╟────────────────────────────────────────────────────────────────────────────╢
; ║ License: MIT                                                               ║
; ╚════════════════════════════════════════════════════════════════════════════╝

;EnableExplicit

;- Notes and stuff
;{

; NOTE: The windows version check are not gonne be done here, the programmer will have to do it, but I will add a 2nd pbi for that.

;ms-winsoundevent:Notification[.Looping].[Mail/...] ; ???
;https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/adaptive-interactive-toasts

; TODO: Add a speed comparaison between pure powershell and min ps&cli-exe ans the go one

; TODO: check if separating into vars/procs/gens is a good idea.

; Universal Dismiss
; https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/universal-dismiss
; Requires mirroring !

;}
;- Constants & Enums
;{

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

EnumerationBinary ToastVisualTypes ; The name is good enough...
	#TOAST_VISUAL_TYPE_TEXT
	#TOAST_VISUAL_TYPE_IMAGE
; 	#TOAST_VISUAL_TYPE_IMAGE_LOGO
; 	#TOAST_VISUAL_TYPE_IMAGE_HERO
; 	#TOAST_VISUAL_TYPE_IMAGE_INLINE
	#TOAST_VISUAL_TYPE_PROGRESS_BAR
EndEnumeration

EnumerationBinary ToastFlags
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
	
	#TOAST_PROGRESS_DETERMINATE
	#TOAST_PROGRESS_INDETERMINATE
	
	#TOAST_DURATION_SHORT ; = "short"
	#TOAST_DURATION_LONG  ; = "long"
	
	#TOAST_SOUND_NORMAL
	#TOAST_SOUND_CUSTOM ; ms-winsoundevent:Notification[.Looping].[Mail/...] won't be added to given path or somthing like that
	#TOAST_SOUND_MUTED
	#TOAST_SOUND_LOOP
	
	; PS1 Related flags
	#TOAST_DEFAULT
	
	#TOAST_VISIBLE ; Default
	#TOAST_HIDDEN ; Will only be shown in the action center (ONLY ON W10+, can cause errors on W8 because microsoft...)
	
	#TOAST_MIRRORING_ALLOWED ; Default
	#TOAST_MIRRORING_DISABLED
	
	#TOAST_PRIORITY_NORMAL ; Default
	#TOAST_PRIORITY_HIGH
EndEnumeration

; Used for easy detection of changed param
#TOAST_MASK_TEXT_PLACEMENT = #TOAST_TEXT_PLACEMENT_DEFAULT | #TOAST_TEXT_PLACEMENT_ATTRIBUTION
#TOAST_MASK_TEXT_STYLE     = #TOAST_TEXT_STYLE_DEFAULT | #TOAST_TEXT_STYLE_BASE | #TOAST_TEXT_STYLE_CAPTION_SUBTLE
#TOAST_MASK_TEXT_ALIGN     = #TOAST_TEXT_ALIGN_DEFAULT | #TOAST_TEXT_ALIGN_RIGHT

;#TOAST_GHOST = #TOAST_HIDDEN

; ???
; EnumerationBinary
; 	#TOAST_INSERT_REPLACE
; 	#TOAST_INSERT_FREE
; EndEnumeration


;}
;- Structures
;{

; See: https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/toast-headers
Structure ToastHeader
	Id$
	Title$
	Arguments$
EndStructure

Structure ToastTextVisualData
	Content$
	MaxLinesHint.i ; Max=2 for title, else 4
EndStructure

;  addImageQuery 
; https://docs.microsoft.com/en-us/uwp/schemas/tiles/tilesschema/element-visual?branch=live
Structure ToastImageVisualData
	Src$
EndStructure

Structure ToastProgressBarVisualData
	Title$
	Value.d
	StringOverride$
	Status$
EndStructure

Structure ToastVisual
	;Id.i ; ??? 
	
	Type.l
	Flags.l
	
	*Text.ToastTextVisualData
	*Image.ToastImageVisualData
	*ProgressBar.ToastProgressBarVisualData
EndStructure

Structure ToastContentSubgroup ; ~= Group Column
	List *Visuals.ToastVisual()
EndStructure

Structure ToastContentGroup
	SubgroupCount.i
	List *Subgroups.ToastContentSubgroup()
EndStructure

; Even this isn't complete, fucking hell
;https://docs.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-toast

Structure ToastNotification
	AppID$
	Flags.i
	Timestamp.l ; ISO 8601 format in xml
	
	*Header.ToastHeader
	
	List *CoreVisuals.ToastVisual()
	
	List *Groups.ToastContentGroup()
	
; ; 	Sound.s
; ; 	
; ; 	ActivationType.s
; ; 	Launch.s
; 	
; 	Duration.i
	
	;  scenario ??? ; https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/adaptive-interactive-toasts#alarms-reminders-and-incoming-calls
EndStructure


; TEMP




; !!!!!!!
; In that Case, you have a single image resource And its name (As an absolute path) is /Assets/Images/welcome.png. 
;Here’s how you use that name in your template.
; 
; XML
; Copy
; <image id="1" src="ms-appx:///Assets/Images/welcome.png"/>
; Notice how in this example URI the scheme ("ms-appx") is followed by "://" which 
; is followed by an absolute path (an absolute path begins With "/").


Structure ActionButton
	Content$
	Arguments$
	ActivationType$ ; foreground/background ?
	
	; Optional
	ImageSrc$
	Placement$
	
	;hint-inputId="textBox" ; Can have an image too (seperated)
	;<input id="textBox" type="text" placeHolderContent="Type a reply"/>
EndStructure
;You can only have up to 5 buttons (including context menu items which we discuss later).
; <action
;     content="Dismiss"
;     imageUri="Assets/ToastButtonIcons/Dismiss.png"
;     arguments="dismiss"
;     activationType="background"/>

;  <input id="textBox" type="text" placeHolderContent="Type a reply"/>
; 
;         <action
;             content="Send"
;             arguments="action=reply&amp;convId=9318"
;             activationType="background"
;             hint-inputId="textBox"
;             imageUri="Assets/Reply.png"/>

; <input id="time" type="selection" defaultInput="lunch">
;             <selection id="breakfast" content="Breakfast" />
;             <selection id="lunch" content="Lunch" />
;             <selection id="dinner" content="Dinner" />
;         </input>



; System snooze & dismiss
; <toast scenario="reminder" launch="action=viewEvent&amp;eventId=1983">
;    
;   ...
;  
;   <actions>
;      
;     <input id="snoozeTime" type="selection" defaultInput="15">
;       <selection id="1" content="1 minute"/>
;       <selection id="15" content="15 minutes"/>
;       <selection id="60" content="1 hour"/>
;       <selection id="240" content="4 hours"/>
;       <selection id="1440" content="1 day"/>
;     </input>
;  
;     <action activationType="system" arguments="snooze" hint-inputId="snoozeTime" content="" />
;  
;     <action activationType="system" arguments="dismiss" content=""/>
;      
;   </actions>
;    
; </toast>


;}
;- Macros
;{

; ???

;}
;- Procedures
;
;- > Creators
;

Procedure.i CreateToast(AppID$ = "Microsoft App", ToastFlags.i = #TOAST_DEFAULT)
	Protected *Toast.ToastNotification = AllocateMemory(SizeOf(ToastNotification))
	
	If *Toast
		InitializeStructure(*Toast, ToastNotification)
		
		*Toast\AppID$ = AppID$
		*Toast\Flags = ToastFlags
	EndIf
	
	ProcedureReturn *Toast
EndProcedure

Procedure.i CreateToastHeader(Id$="", Title$="", Arguments$="")
	Protected *Header.ToastHeader = AllocateMemory(SizeOf(ToastHeader))
	
	If *Toast
		*Header\Id$ = Id$
		*Header\Title$ = Title$
		*Header\Arguments$ = Arguments$
	EndIf
	
	ProcedureReturn *Header
EndProcedure

Procedure.i CreateToastVisual(VisualType.l, VisualFlags.l)
	Protected *Visual.ToastVisual = AllocateMemory(SizeOf(ToastVisual))
	
	If *Visual
		;InitializeStructure(*Visual, ToastVisual) ; Pointless here
		*Visual\Type = VisualType
		*Visual\Flags = VisualFlags
	EndIf
	
	ProcedureReturn *Visual
EndProcedure

Procedure.i CreateToastTextVisual(Text$="", VisualFlags.l = 0, MaxLinesHint.i=-1)
	Protected *Visual.ToastVisual = CreateToastVisual(#TOAST_Visual_TYPE_TEXT, VisualFlags)
	
	If *Visual
		*Visual\Text = AllocateMemory(SizeOf(ToastTextVisualData))
		
		If *Visual\Text
			*Visual\Text\Content$ = Text$
			*Visual\Text\MaxLinesHint = MaxLinesHint
		Else
			; TODO: Free and cleanup
			;ProcedureReturn 0
		EndIf
	EndIf
	
	ProcedureReturn *Visual
EndProcedure

Procedure.i CreateToastImageVisual(Src$="", VisualFlags.l = 0)
	Protected *Visual.ToastVisual = CreateToastVisual(#TOAST_Visual_TYPE_IMAGE, VisualFlags)
	
	If *Visual
		*Visual\Image = AllocateMemory(SizeOf(ToastImageVisualData))
		
		If *Visual\Image
			*Visual\Image\Src$ = Src$
		Else
			; TODO: Free and cleanup
			;ProcedureReturn 0
		EndIf
	EndIf
	
	ProcedureReturn *Visual
EndProcedure

Procedure.i CreateToastProgressBarVisual(Title$="", Value.d=0.0, StringOverride$="", Status$="")
	Protected *Visual.ToastVisual = CreateToastVisual(#TOAST_VISUAL_TYPE_PROGRESS_BAR, ProgressBarVisualData)
	
	If *Visual
		*Visual\ProgressBar = AllocateMemory(SizeOf(ToastProgressBarVisualData))
		
		If *Visual\ProgressBar
			*Visual\ProgressBar\Title$ = Title$
			*Visual\ProgressBar\Value = Value
			*Visual\ProgressBar\StringOverride$ = StringOverride$
			*Visual\ProgressBar\Status$ = Status$
		Else
			; TODO: Free and cleanup
			;ProcedureReturn 0
		EndIf
	EndIf
	
	ProcedureReturn *Visual
EndProcedure

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
	EndIf
	
	ProcedureReturn *Subgroup
EndProcedure

;
;- > Inserters
; TODO: Add != insertion modes (override, replace, free, if empty, ...)
;

Procedure.b InsertToastHeader(*Toast.ToastNotification, *Header.ToastHeader)
	If *Toast And *Header
		*Toast\Header = *Header
		ProcedureReturn #True
	EndIf
	
	ProcedureReturn #False
EndProcedure

Procedure.b InsertToastCoreVisual(*Toast.ToastNotification, *Visual.ToastVisual)
	If *Toast And *Visual
		LastElement(*Toast\CoreVisuals())
		
		If InsertElement(*Toast\CoreVisuals())
			*Toast\CoreVisuals() = *Visual
			
			;ProcedureReturn #True
			ProcedureReturn ListSize(*Toast\CoreVisuals())
		EndIf
	EndIf
	
	ProcedureReturn #False
EndProcedure

Procedure.b InsertToastGroup(*Toast.ToastNotification, *Group.ToastContentGroup)
	If *Toast And *Group
		LastElement(*Toast\Groups())
		
		If InsertElement(*Toast\Groups())
			*Toast\Groups() = *Group
			
			ProcedureReturn ListSize(*Toast\Groups())
		EndIf
	EndIf
	
	ProcedureReturn #False
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

Procedure.b InsertToastVisualIntoSubgroup(*Subgroup.ToastContentSubgroup, *Visual.ToastVisual)
	If *Subgroup And *Visual
		LastElement(*Subgroup\Visuals())
		
		If InsertElement(*Subgroup\Visuals())
			*Subgroup\Visuals() = *Visual
			ProcedureReturn #True
		EndIf
	EndIf
	
	ProcedureReturn #False
EndProcedure

;
;- > Getters & Setters
;

; Read
Procedure.l GetToastVisualFlags(*Visual.ToastVisual)
	;If 
EndProcedure

; Overwrite
Procedure.b SetToastVisualFlags(*Visual.ToastVisual, VisualFlags.l = 0)
	
EndProcedure

; Only change what is indicated
Procedure.b UpdateToastVisualFlags(*Visual.ToastVisual, VisualFlags.l = 0)
	
EndProcedure

; is compaptible

;
;- > Cleaners
;

; Will be added later.

;
;- > Generators
;

Procedure.b GenerateToastXMLVisualNode(ParentXMLNode, *ToastVisual.ToastVisual)
	Protected NodeVisual
	;Debug "Generating a visual node..."
	
	Select *ToastVisual\Type
		Case #TOAST_VISUAL_TYPE_TEXT
			NodeVisual = CreateXMLNode(ParentXMLNode, "text")
			
			If *ToastVisual\Flags & #TOAST_TEXT_PLACEMENT_ATTRIBUTION
				SetXMLAttribute(NodeVisual, "placement", "attribution")
			EndIf
			
			If *ToastVisual\Flags & #TOAST_TEXT_STYLE_BASE
				SetXMLAttribute(NodeVisual, "hint-style", "base")
			ElseIf *ToastVisual\Flags & #TOAST_TEXT_STYLE_CAPTION_SUBTLE
				SetXMLAttribute(NodeVisual, "hint-style", "captionSubtle")
			EndIf
			
			If *ToastVisual\Flags & #TOAST_TEXT_ALIGN_RIGHT
				SetXMLAttribute(NodeVisual, "hint-align", "right")
			EndIf
			
			If *ToastVisual\Text\MaxLinesHint > 1 ; 2-title 4-text !!!
				SetXMLAttribute(NodeVisual, "hint-maxLines", Str(*ToastVisual\Text\MaxLinesHint))
			EndIf
			
			SetXMLNodeText(NodeVisual, *ToastVisual\Text\Content$)
			
		Case #TOAST_VISUAL_TYPE_IMAGE
			;ProcedureReturn "image"
			;NodeVisual = CreateXMLNode(ParentXMLNode, "image")
			
			
		Case #TOAST_VISUAL_TYPE_PROGRESS_BAR
			;ProcedureReturn "progress"
			;NodeVisual = CreateXMLNode(ParentXMLNode, "progress")
			
		Default
			DebuggerWarning("Wrong visual type selected in GenerateToastXMLVisualNode(...) !")
			ProcedureReturn #False
	EndSelect
	
	ProcedureReturn #True
EndProcedure

; Not explicit compliant
; NOTE: The whole XML thing takes up 100-150kb in the final executable...
;       Nice optimisation from the compiler too when it's no called anywhere...
Procedure.s GenerateToastXML(*Toast.ToastNotification)
	Protected XML$, XMLID = CreateXML(#PB_Any, #PB_UTF8)
	
	If XMLID
		; Creating the basic things
		Protected NodeToast = CreateXMLNode(RootXMLNode(XMLID), "toast")
		
		;displayTimestamp="..."
		
		;If *Toast\Flags & #TOAST_GHOST
		;	SetXMLAttribute(NodeToast, "", "true")
		;EndIf
		
		
		If ListSize(*Toast\CoreVisuals()) Or ListSize(*Toast\Groups())
			;Debug "Generating Visuals..."
			
			Protected NodeVisuals = CreateXMLNode(NodeToast, "visual")
			
			ResetList(*Toast\CoreVisuals())
			While NextElement(*Toast\CoreVisuals())
				GenerateToastXMLVisualNode(NodeVisuals, *Toast\CoreVisuals())
			Wend
			
			; Indented far too much and might not add nodes in the correct order !!
			ResetList(*Toast\Groups())
			While NextElement(*Toast\Groups())
				Protected NodeGroup = CreateXMLNode(NodeVisuals, "group")
				
				ResetList(*Toast\Groups()\Subgroups())
				While NextElement(*Toast\Groups()\Subgroups())
					Protected NodeSubgroup = CreateXMLNode(NodeGroup, "subgroup")
					
					ResetList(*Toast\Groups()\Subgroups()\Visuals())
					While NextElement(*Toast\Groups()\Subgroups()\Visuals())
						GenerateToastXMLVisualNode(NodeSubgroup, *Toast\Groups()\Subgroups()\Visuals())
					Wend
				Wend
			Wend
			
		EndIf
		
		;If ListSize actions ...
		
		; if all good only
		FormatXML(XMLID, #PB_XML_WindowsNewline | #PB_XML_ReduceNewline | #PB_XML_ReIndent | #PB_XML_ReFormat)
		XML$ = ComposeXML(XMLID, #PB_XML_NoDeclaration)
		FreeXML(XMLID)
	EndIf
	
	ProcedureReturn XML$
EndProcedure


; Structure ToastContentSubgroup ; ~= Group Column
; 	List *Visuals.ToastVisual()
; EndStructure
; 
; Structure ToastContentGroup
; 	SubgroupCount.i
; 	List *Subgroups.ToastContentSubgroup()
; EndStructure
; 
; ; Even this isn't complete, fucking hell
; ;https://docs.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-toast
; 
; Structure ToastNotification
; 	AppID$
; 	Flags.i
; 	Timestamp.l ; ISO 8601 format in xml
; 	
; 	*Header.ToastHeader
; 	
; 	List *CoreVisuals.ToastVisual()
; 	
; 	List *Groups.ToastContentGroup()
; 	
; ; ; 	Sound.s
; ; ; 	
; ; ; 	ActivationType.s
; ; ; 	Launch.s
; ; 	
; ; 	Duration.i
; 	
; 	;  scenario ??? ; https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/adaptive-interactive-toasts#alarms-reminders-and-incoming-calls
; EndStructure







; Procedure.s GenerateToastXML$(*Toast.ToastNotification)
; 	;Protected XMLID = GenerateToastXML$()
; 	ProcedureReturn #Null$
; EndProcedure


; <progress
;	title="Weekly playlist"
;	value="0.6"
;	valueStringOverride="15/26 songs"
;	status="Downloading..."/>

; NOTE: Collections should be added in here, i think

Procedure.s GenerateToastPS1(*Toast.ToastNotification)
	Protected Script$, Xml$ = GenerateToastXML(*Toast)
	
	If Xml$ <> #Null$
		Script$ + "[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null" + #CRLF$ +
		          "[Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null" + #CRLF$ +
		          "[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null" + #CRLF$ + #CRLF$
		
		Script$ + "$APP_ID = '" + *Toast\AppID$ + "'" + #CRLF$ + #CRLF$
		Script$ + "$toastXML = @" + Chr(34) + #CRLF$
		Script$ + Xml$ + #CRLF$
		Script$ + Chr(34) + "@"
		
		Script$ + "$xml = New-Object Windows.Data.Xml.Dom.XmlDocument" + #CRLF$
		Script$ + "$xml.LoadXml($template)" + #CRLF$
		Script$ + "$toast = New-Object Windows.UI.Notifications.ToastNotification $xml" + #CRLF$
		
		; if ghost
		;W10+ ONLY !!!
		;Script$ + "$toast.SuppressPopup = $TRUE;" + #CRLF$
		
		; if no mirroring
		;Script$ + "$toast.NotificationMirroring = [Windows.UI.Notifications.NotificationMirroring]::Disabled" + #CRLF$
		
		; if high priority
		; Requires creator update(use VM for that) !
		;Script$ + "$toast.Priority = [Windows.UI.Notifications.ToastNotificationPriority]::High" + #CRLF$
		
		;Group & Tag seem useless
		
		Script$ + "[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($APP_ID).Show($toast)"
	EndIf
	
	ProcedureReturn Script$
EndProcedure



;Debug #PB_Ignore

CompilerIf #PB_Compiler_IsMainFile
	*Toast = CreateToast("Test App")
	*Title = CreateToastTextVisual("Title", 0, 1)
	*Text1  = CreateToastTextVisual("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
	*Text2  = CreateToastTextVisual("Text2")
	*Text3  = CreateToastTextVisual("Text3")
	*Text4  = CreateToastTextVisual("Text4")
	*Text5  = CreateToastTextVisual("Text5")
	
	InsertToastCoreVisual(*Toast, *Title)
	InsertToastCoreVisual(*Toast, *Text1)
	InsertToastCoreVisual(*Toast, *Title)
	InsertToastCoreVisual(*Toast, *Text2)
	
	*Grp1 = CreateToastGroup(2)
	*Grp2 = CreateToastGroup(1)
	*Sgrp1 = CreateToastSubgroup()
	*Sgrp2 = CreateToastSubgroup()
	*Sgrp3 = CreateToastSubgroup()
	InsertToastSubgroup(*Grp1, *Sgrp1, 0)
	InsertToastSubgroup(*Grp1, *Sgrp2, 1)
	InsertToastSubgroup(*Grp2, *Sgrp3, 0)
	
	InsertToastGroup(*Toast, *Grp1)
	InsertToastGroup(*Toast, *Grp2)
	
	InsertToastVisualIntoSubgroup(*Sgrp1, *Text2)
	InsertToastVisualIntoSubgroup(*Sgrp1, *Text3)
	InsertToastVisualIntoSubgroup(*Sgrp2, *Text4)
	InsertToastVisualIntoSubgroup(*Sgrp3, *Text5)
	
	StartTime.q = ElapsedMilliseconds()
	Debug GenerateToastXML(*Toast)
	Debug "XML generation Time: " + Str(ElapsedMilliseconds() - StartTime) + "ms"
	
CompilerEndIf




;
;- Garbage
;{

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



; Global WorkingDirectory$ = GetTemporaryDirectory() + "OcelusSoft\notifications-util\"
; 

; test01:
;

; Template$ = ""
; 
; If ReadFile(0, "./toastTemplate2.xml")
; 	While Eof(0) = 0
; 		Template$ = Template$ + ReadString(0) + #CRLF$
; 	Wend
; 	CloseFile(0)
; Else
; 	MessageRequester("Information","Couldn't open the file!")
; 	End
; EndIf
; 
; OutFilename$ = WorkingDirectory$ + "toast-" + LCase(Str(Date()))+".ps1"
; DeleteFile(OutFilename$)
; 
; If CreateFile(0, OutFilename$)
; 	WriteString(0, Template$)
; 	CloseFile(0)
; 	
; 	mciSendString_("OPEN "+Chr(34)+"..\Examples\Ressources\Doot.mp3"+Chr(34)+" Type MPEGVIDEO ALIAS MP3_0",0,0,0)
; 	mciSendString_("SetAudio MP3_0 volume to 100",0,0,0)
; 	RunProgram("PowerShell", "-ExecutionPolicy Bypass -File "+OutFilename$, WorkingDirectory$, #PB_Program_Wait | #PB_Program_Hide)
; 	mciSendString_("play MP3_0",0,0,0)
; 	Delay(3000) ; Prevents the sound from cutting off
; 	
; 	;PowerShell -ExecutionPolicy Bypass
; 	
; 	DeleteFile(OutFilename$)
; Else
; 	MessageRequester("Information","Couldn't create the file!")
; 	End
; EndIf

;}

; X collections
; X Manipulation
; X Notification listener
; X Custom audio (kinda)

; IDE Options = PureBasic 5.62 (Windows - x64)
; Folding = ---v-
; EnableXP
; Executable = test.exe
; CompileSourceDirectory
; EnableCompileCount = 131
; EnableBuildCount = 6