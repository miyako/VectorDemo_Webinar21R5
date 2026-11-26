// Opens the Ticket Finder window (one window, owned by worker 1).
#DECLARE($params : Object)

var $title:=Localized string("TicketFinder_WindowTitle")
var $window : Integer

If (Count parameters=0)
	
	ARRAY LONGINT($windows; 0)
	WINDOW LIST($windows)
	var $i : Integer
	For ($i; 1; Size of array($windows))
		$window:=$windows{$i}
		If (Window process($window)=1) && (Get window title($window)=$title)
			var $left; $top; $right; $bottom : Integer
			GET WINDOW RECT($left; $top; $right; $bottom; $window)
			CALL FORM($window; Formula(SET WINDOW RECT($1; $2; $3; $4; $5)); $left; $top; $right; $bottom; $window)
			return 
		End if 
	End for 
	
	CALL WORKER(1; Current method name; {})
	
Else 
	
	SET MENU BAR(1)
	$window:=Open form window("TicketFinder"; Plain form window; Horizontally centered; Vertically centered)
	SET WINDOW TITLE($title; $window)
	DIALOG("TicketFinder"; $params; *)
	
End if 
