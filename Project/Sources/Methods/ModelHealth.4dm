//%attributes = {"invisible":true,"preemptive":"capable"}
// Polls llama-server /health until the model is loaded (up to 2 minutes).
var $model:=cs.EmbeddingModel.new()
var $attempt : Integer

For ($attempt; 1; 240)
	If ($model.isReady())
		ModelStatus("ready")
		return 
	End if 
	DELAY PROCESS(Current process; 30)
End for 

ModelStatus("error"; {message: "timeout"})
