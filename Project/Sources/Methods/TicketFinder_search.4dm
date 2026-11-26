//%attributes = {"invisible":true}
// Vectorises the question asynchronously; the search runs in TicketFinder_onEmbedding.
var $query:=Trim(String(Form.queryText))

If ($query="")
	GOTO OBJECT(*; "queryInput")
	return 
End if 

Form.summary:=Localized string("Search_Embedding")
OBJECT SET ENABLED(*; "searchButton"; False)
cs.EmbeddingModel.new().embedQuery($query; {onTerminate: Formula(TicketFinder_onEmbedding($1))})
