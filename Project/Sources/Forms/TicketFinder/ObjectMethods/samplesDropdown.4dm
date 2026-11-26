If (FORM Event.code=On Data Change) && (Form.samples.index>0)
	Form.queryText:=Form.samples.currentValue
	TicketFinder_search
End if 
