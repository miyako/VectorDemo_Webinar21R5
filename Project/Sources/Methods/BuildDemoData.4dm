//%attributes = {"invisible":true}
// Rebuilds the Tickets table from Resources/support_tickets_100k.csv:
// imports the rows, embeds "title + description" with the local model,
// stores the vectors in both vector fields and builds the cosine vector index.
// Headless: tool4d --project ... --skip-onstartup --startup-method BuildDemoData --user-param '{"limit":1000}'
#DECLARE($params : Object)

If ($params=Null)
	var $userParam : Text
	var $ignore:=Get database parameter(User param value; $userParam)
	$params:=($userParam="{@") ? JSON Parse($userParam) : {}
End if 

var $model:=cs.EmbeddingModel.new()
var $startedHere:=Not($model.isReady())
If ($startedHere)
	$model.start()
	var $wait : Integer
	For ($wait; 1; 240)
		If ($model.isReady())
			break
		End if 
		DELAY PROCESS(Current process; 30)
	End for 
End if 
If (Not($model.isReady()))
	BuildDemoData_log("embedding model is not available")
	return 
End if 

var $file:=Folder(fk resources folder).file("support_tickets_100k.csv")
var $lines:=Split string($file.getText("UTF-8"; Document with LF); "\n"; sk ignore empty strings)
$lines.remove(0)  // header
If (Num($params.limit)>0)
	$lines:=$lines.slice(0; Num($params.limit))
End if 

ds.Tickets.all().drop()
// import without the vector index, then build it once at the end
DELETE INDEX(->[Tickets]IndexedVector)

var $batchSize:=128
var $started:=Milliseconds
var $i; $j : Integer

For ($i; 0; $lines.length-1; $batchSize)
	
	var $rows:=$lines.slice($i; $i+$batchSize).map(Formula(Split string($1.value; "\t")))
	var $vectors:=$model.embedDocuments($rows.map(Formula($1.value[1]+"\n"+$1.value[2])))
	
	var $records:=[]
	For ($j; 0; $rows.length-1)
		var $row : Collection:=$rows[$j]
		$records.push({\
			Id: $row[0]; \
			Title: $row[1]; \
			Description: $row[2]; \
			Category: $row[3]; \
			Priority: $row[4]; \
			Created_at: $row[5]; \
			Vector: $vectors[$j]; \
			IndexedVector: $vectors[$j]})
	End for 
	ds.Tickets.fromCollection($records)
	
	If ((($i/$batchSize)%20)=0)
		BuildDemoData_log(String($i+$rows.length)+"/"+String($lines.length)+" "+String((Milliseconds-$started)/1000; "#####0.0")+"s")
	End if 
	
End for 

BuildDemoData_log("imported "+String(ds.Tickets.all().length)+" tickets in "+String((Milliseconds-$started)/1000; "#####0.0")+"s")

ARRAY POINTER($fields; 1)
$fields{1}:=->[Tickets]IndexedVector
$started:=Milliseconds
CREATE INDEX([Tickets]; $fields; Vector cosine index; "IndexedVector_cosine")
BuildDemoData_log("cosine index built in "+String((Milliseconds-$started)/1000; "#####0.0")+"s")

If (Bool($params.quit))
	// the server belongs to this process; a server left running would outlive tool4d
	If ($startedHere)
		$model.stop()
	End if 
	QUIT 4D
End if 
