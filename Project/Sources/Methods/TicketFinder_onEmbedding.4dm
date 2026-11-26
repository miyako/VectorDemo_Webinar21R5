//%attributes = {"invisible":true}
// AI Kit callback (runs in the Ticket Finder process): runs the vector query and times it.
#DECLARE($result : Object)

If (Form=Null)
	return 
End if 

OBJECT SET ENABLED(*; "searchButton"; True)

If (Not(Bool($result.success)))
	var $message:=""
	If ($result.errors#Null) && ($result.errors.length>0)
		$message:=String($result.errors[0].message)
	End if 
	Form.summary:=Localized string("Search_Failed")+" "+$message
	return 
End if 

var $vector : 4D.Vector:=$result.embedding.embedding
var $comparison:={vector: $vector; metric: mk cosine; threshold: Num(Form.threshold)}
var $started:=Milliseconds

If (Form.indexedSearch)
	Form.tickets:=ds.Tickets.query("IndexedVector > :1 order by IndexedVector desc"; $comparison)
Else 
	Form.tickets:=ds.Tickets.query("Vector > :1 order by Vector desc"; $comparison)
End if 

var $elapsed:=Milliseconds-$started
Form.queryVector:=$vector

var $summary:=Localized string(Form.indexedSearch ? "Search_ResultIndexed" : "Search_ResultScan")
$summary:=Replace string($summary; "{count}"; String(Form.tickets.length; "###,###,##0"))
$summary:=Replace string($summary; "{ms}"; String($elapsed; "###,###,##0"))
Form.summary:=$summary

Form.timings[Form.indexedSearch ? "indexed" : "scan"]:=$elapsed
TicketFinder_showTimings
