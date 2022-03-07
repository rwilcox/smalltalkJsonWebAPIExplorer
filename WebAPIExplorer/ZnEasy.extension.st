Extension { #name : #ZnEasy }

{ #category : #'*WebAPIExplorer' }
ZnEasy class >> getJSON: urlObject [
	"Sends Content-Type: application/json to the URL in question"

	^ self client
		beOneShot;
		url: urlObject;
		accept: ZnMimeType applicationJson ;
		
		get;
		response
]

{ #category : #'*WebAPIExplorer' }
ZnEasy class >> getJSON: urlObject headers: dictionaryArray [
	"Wrapper that allows you to pass additional headers into your json call
	
	Example: ZnEasy getJSON: 'http://...' headers: { 'AccessToken' -> 12345 }
	"

	| res headerDict |
	headerDict := Dictionary
		newFrom: dictionaryArray.
	res := self client url: urlObject.
	headerDict keysAndValuesDo: [ :key :value | res headerAt: key put: value ].
	^ res
		beOneShot;
		accept: ZnMimeType applicationJson;
		get;
		response
]

{ #category : #'*WebAPIExplorer' }
ZnEasy class >> getJSON: urlObject headers: dictionaryArray into: block [
	"Wrapper that allows you to pass additional headers into your json call
	
	Example: ZnEasy getJSON: 'http://...' headers: { 'AccessToken' -> 12345 } into: [ :json :response | ... ]
	"
|res jsonOutput|
   res := ZnEasy getJSON: urlObject headers: dictionaryArray .
	
	jsonOutput := NeoJSONObject fromString: res entity.
	block value: jsonOutput value: res
]

{ #category : #'*WebAPIExplorer' }
ZnEasy class >> getJSON: urlObject into: block [
	"Sends Content-Type: application/json to URL in question.
	Auto parses json response. 
	
	Into parameter takes a block whose signature is [ :json :response | ... ],
	allowing you to extract both the processed JSON and the original response.
	"

	| res jsonOutput |
	res := self client
		beOneShot;
		url: urlObject;
		accept: ZnMimeType applicationJson;
	
		get;
		response.
	jsonOutput := NeoJSONObject fromString: res entity.
	block value: jsonOutput value: res
]

{ #category : #'*WebAPIExplorer' }
ZnEasy class >> postJSON: urlObject data: objectForJSONEncoding [
	| jsonStr dataEntity res |
	
	jsonStr := STONJSON toString: objectForJSONEncoding.
	dataEntity := ZnEntity with: jsonStr type: ZnMimeType applicationJson.
	res := ZnEasy post: urlObject data: dataEntity.
	^ NeoJSONObject fromString: res entity
]

{ #category : #'*WebAPIExplorer' }
ZnEasy class >> postJSON: url data: body headers: headers [
	"wrapper that lets you put additional data into your POST call"

	| jsonStr dataEntity res |
	jsonStr := STONJSON toString: body.
	dataEntity := ZnEntity with: jsonStr type: ZnMimeType applicationJson.
	res := self client
		url: url;
		entity: dataEntity.
	headers keysAndValuesDo: [ :key :value | res headerAt: key put: value ].
	^ res
		beOneShot;
		accept: ZnMimeType applicationJson;
		post;
		response
]

{ #category : #'*WebAPIExplorer' }
ZnEasy class >> postJSON: url data: body headers: headers into: block [
	| jsonStr dataEntity res jsonOutput |
	jsonStr := STONJSON toString: body.
	dataEntity := ZnEntity with: jsonStr type: ZnMimeType applicationJson.
		res := self client
		url: url;
		entity: dataEntity.
	headers keysAndValuesDo: [ :key :value | res headerAt: key put: value ].
	res beOneShot; accept: ZnMimeType applicationJson; post; response.
	jsonOutput := NeoJSONObject fromString: res entity.
	block value: jsonOutput value: res
]

{ #category : #'*WebAPIExplorer' }
ZnEasy class >> postJSON: url data: body into: block [
	| jsonStr dataEntity res jsonOutput |
	jsonStr := STONJSON toString: body.
	dataEntity := ZnEntity with: jsonStr type: ZnMimeType applicationJson.
	res := ZnEasy post: url data: dataEntity.
	jsonOutput := NeoJSONObject fromString: res entity.
	block value: jsonOutput value: res
]

{ #category : #'*WebAPIExplorer' }
ZnEasy class >> postJSONWithResultObject: urlObject data: objectForJSONEncoding [
	| jsonStr dataEntity |
	jsonStr := STONJSON toString: objectForJSONEncoding.
	dataEntity := ZnEntity with: jsonStr type: ZnMimeType applicationJson.
	
	^ ZnEasy post: urlObject data: dataEntity
]
