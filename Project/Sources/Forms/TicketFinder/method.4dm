Case of 
	: (FORM Event.code=On Load)
		
		Form.queryText:=""
		Form.indexedSearch:=True
		// ruri-v3 cosine similarities between related texts are high; 0.87 keeps every sample query non-empty but focused
		Form.threshold:=0.87
		Form.tickets:=ds.Tickets.newSelection()
		Form.timings:={indexed: Null; scan: Null}
		Form.summary:=""
		TicketFinder_showTimings
		
		// sample questions are in Japanese, like the ticket data
		Form.samples:={\
			values: [Localized string("TicketFinder_Samples"); \
			"VPN がすぐ切れて仕事にならない"; \
			"パスワードを変えてからログインできない"; \
			"プリンターで印刷できない"; \
			"Teams の会議で声が途切れる"; \
			"共有フォルダーに保存できない"; \
			"請求書の金額が合わない"]; \
			index: 0}
		
		OBJECT SET ENABLED(*; "searchButton"; False)
		Use (Storage)
			Storage.embedding:=New shared object("window"; Current form window)
		End use 
		cs.EmbeddingModel.new().start()
		
	: (FORM Event.code=On Unload)
		
		Use (Storage)
			Storage.embedding:=Null
		End use 
		
End case 
