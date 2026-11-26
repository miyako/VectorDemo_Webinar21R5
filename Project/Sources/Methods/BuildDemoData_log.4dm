//%attributes = {"invisible":true}
#DECLARE($message : Text)

If (Application info.headless)
	LOG EVENT(Into system standard outputs; "BuildDemoData: "+$message+"\n")
Else 
	MESSAGE($message+"\r")
End if 
