//%attributes = {"invisible":true}
// Runs in the Ticket Finder window (CALL FORM) when the embedding model status changes.
#DECLARE($payload : Object)

If (Form=Null)
	return 
End if 

Form.model:=$payload

Case of 
	: ($payload.status="ready")
		Form.modelStatus:=Localized string("Model_Ready")
	: ($payload.status="downloading")
		Form.modelStatus:=Replace string(Localized string("Model_Downloading"); "{percent}"; String(Num($payload.percent); "##0"))
	: ($payload.status="loading")
		Form.modelStatus:=Localized string("Model_Loading")
	: ($payload.status="stopped")
		Form.modelStatus:=Localized string("Model_Stopped")
	Else 
		Form.modelStatus:=Localized string("Model_Error")+" "+String($payload.message)
End case 

OBJECT SET ENABLED(*; "searchButton"; $payload.status="ready")
