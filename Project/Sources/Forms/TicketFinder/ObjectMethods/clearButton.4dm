If (FORM Event.code=On Clicked)
	Form.queryText:=""
	Form.queryVector:=Null
	Form.tickets:=ds.Tickets.newSelection()
	Form.summary:=""
	Form.samples.index:=0
	GOTO OBJECT(*; "queryInput")
End if 
