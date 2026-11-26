// Local embedding model (ruri-v3-310m, 768 dimensions) served by llama.cpp.
// The model file is downloaded once from Hugging Face into ~/.GGUF and reused offline.

property port : Integer
property repository : Text
property fileName : Text
property folder : 4D.Folder
property modelName : Text
property queryPrefix : Text
property documentPrefix : Text

Class constructor()
	
	This.port:=18083
	// this conversion keeps ruri's SentencePiece (Unigram) vocabulary; a WordPiece-labelled conversion breaks Japanese tokens
	This.repository:="Targoyle/ruri-v3-310m-GGUF"
	This.fileName:="ruri-v3-310m-q8_0.gguf"
	This.folder:=Folder(fk home folder).folder(".GGUF/ruri-v3-310m-GGUF")
	This.modelName:="ruri-v3-310m"
	// ruri v3 expects a task prefix on every input
	This.queryPrefix:="検索クエリ: "
	This.documentPrefix:="検索文書: "
	
Function get modelFile() : 4D.File
	
	return This.folder.file(This.fileName)
	
Function get baseURL() : Text
	
	return "http://127.0.0.1:"+String(This.port)+"/v1"
	
Function get client() : cs.AIKit.OpenAI
	
	// llama-server needs no key, but AI Kit needs one to build the client
	return cs.AIKit.OpenAI.new({baseURL: This.baseURL; apiKey: "local"})
	
Function isReady() : Boolean
	
	var $request:=4D.HTTPRequest.new("http://127.0.0.1:"+String(This.port)+"/health"; {method: "GET"; timeout: 2})
	$request.wait(3)
	return ($request.response#Null) && ($request.response.status=200)
	
Function start()
	
	// Status changes are reported through ModelStatus, which forwards them to the Ticket Finder window
	If (This.isReady())
		ModelStatus("ready")
		return 
	End if 
	
	var $event:=cs.event.event.new()
	$event.onError:=Formula(ModelStatus("error"; {message: $2.message}))
	$event.onSuccess:=Formula(ModelStatus("loading"))
	$event.onData:=Formula(ModelStatus("downloading"; {percent: (This.range.end/This.range.length)*100}))
	$event.onTerminate:=Formula(ModelStatus("stopped"))
	
	var $options:={\
		embeddings: True; \
		pooling: "mean"; \
		ctx_size: 8192; \
		batch_size: 8192; \
		ubatch_size: 8192; \
		parallel: 4; \
		threads: 4; \
		threads_batch: 4; \
		threads_http: 4; \
		n_gpu_layers: -1; \
		log_disable: True}
	
	var $huggingfaces : cs.event.huggingfaces
	If (This.modelFile.exists)
		// already downloaded: start offline from the local file
		$options.model:=This.modelFile
		$huggingfaces:=cs.event.huggingfaces.new([])
		ModelStatus("loading")
	Else 
		$huggingfaces:=cs.event.huggingfaces.new([cs.event.huggingface.new(This.folder; This.repository; This.fileName)])
		ModelStatus("downloading"; {percent: 0})
	End if 
	
	cs.llama.llama.new(This.port; $huggingfaces; This.folder.parent; $options; $event)
	
Function stop()
	
	If (This.isReady())
		cs.llama.llama.new(This.port).terminate()
	End if 
	
Function embedQuery($text : Text; $parameters : Object) : cs.AIKit.OpenAIEmbeddingsResult
	
	return This.client.embeddings.create(This.queryPrefix+$text; This.modelName; $parameters)
	
Function embedDocuments($texts : Collection) : Collection
	
	var $inputs:=$texts.map(Formula($2+$1.value); This.documentPrefix)
	var $result:=This.client.embeddings.create($inputs; This.modelName)
	If (Not($result.success))
		throw(1; $result.errors.length>0 ? String($result.errors[0].message) : "embeddings failed")
	End if 
	return $result.embeddings.orderBy("index asc").extract("embedding")
