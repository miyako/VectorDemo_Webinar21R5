//%attributes = {"invisible":true,"preemptive":"capable"}
// Forwards an embedding-model status change to the Ticket Finder window.
// Called from llama.cpp component callbacks, which may run in any process.
#DECLARE($status : Text; $info : Object)

var $payload:=$info=Null ? {} : OB Copy($info)
$payload.status:=$status

If ($status="loading")
	// the server process is launched; poll /health until the model is loaded
	CALL WORKER("EmbeddingModel_health"; "ModelHealth")
End if 

If (Storage.embedding#Null)
	var $window : Integer:=Num(Storage.embedding.window)
	If ($window#0)
		CALL FORM($window; "TicketFinder_onModel"; $payload)
	End if 
End if 
