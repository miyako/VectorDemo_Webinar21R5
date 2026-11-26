//%attributes = {"invisible":true}
var $notMeasured:=Localized string("Search_NotMeasured")
var $indexed : Text:=(Form.timings.indexed=Null) ? $notMeasured : String(Form.timings.indexed; "###,###,##0")
var $scan : Text:=(Form.timings.scan=Null) ? $notMeasured : String(Form.timings.scan; "###,###,##0")
var $text:=Localized string("Search_Comparison")
$text:=Replace string($text; "{indexed}"; $indexed)
$text:=Replace string($text; "{scan}"; $scan)
Form.timingsText:=$text
