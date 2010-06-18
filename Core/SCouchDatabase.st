Object subclass: SCouchDatabase [
    | adaptor name |
    
    <import: SCouchHTTPCodes>
    <category: 'SCouchDB-Core'>
    <comment: nil>

    adaptor [
	"Answer the value of adaptor"

	<category: 'accessing'>
	^adaptor
    ]

    adaptor: anObject [
	"Set the value of adaptor"

	<category: 'accessing'>
	adaptor := anObject
    ]

    all [
	<category: 'accessing'>
	| json |
	json := self allDocuments.
	self halt
    ]

    allDocuments [
	<category: 'accessing'>
	| result |
	result := self getJson: '_all_docs?include_docs=true'.
	^(result at: 'rows') collect: [:row | row at: 'doc']
    ]

    allDocumentsAs: aClass [
	<category: 'accessing'>
	| result |
	result := self getJson: '_all_docs?include_docs=true'.
	^(result at: 'rows') 
	    collect: [:row | aClass fromCouchDocument: (row at: 'doc')]
    ]

    at: id [
	<category: 'accessing'>
	^self at: id ifAbsent: [self error: 'Document with given id not found']
    ]

    at: id ifAbsent: aBlock [
	<category: 'accessing'>
	^self documentToObject: (self documentAt: id ifAbsent: [^aBlock value])
    ]

    at: key put: object [
	<category: 'accessing'>
	^self documentAt: key put: object asCouchDocument
    ]

    documentAt: id [
	"read a single json document"

	<category: 'accessing'>
	| response result |
	response := adaptor get: self namePrefix , id asString encodeForHTTP.
	result := adaptor readJsonFrom: response.
	response code = HTTPOK ifTrue: [^result].
	^adaptor couchDBError: result
    ]

    documentAt: id ifAbsent: aBlock [
	"read a single json document"

	<category: 'accessing'>
	| response |
	response := adaptor get: self namePrefix , id asString encodeForHTTP.
	response code = HTTPOK ifTrue: [^adaptor readJsonFrom: response].
	^aBlock value
    ]

    documentAt: key ifAbsentPut: aBlockWithJsonObject [
	"read a single json document"

	<category: 'accessing'>
	| response |
	response := adaptor get: self namePrefix , key asString encodeForHTTP.
	response code = HTTPOK ifTrue: [^adaptor readJsonFrom: response].
	^self documentAt: key put: aBlockWithJsonObject value
    ]

    documentAt: id put: jsonObject [
	<category: 'accessing'>
	| response code content |
	content := self utf8Encode: jsonObject asJsonString.
	response := self put: id asString encodeForHTTP content: content.
	code := response code.
	code = HTTPCreated ifTrue: [^adaptor readJsonFrom: response].
	code = HTTPOK ifTrue: [^adaptor readJsonFrom: response].
	code = HTTPErrorConflict 
	    ifTrue: 
		["document already exists"

		| oldDoc |
		response closeStream.
		oldDoc := self documentAt: id.
		jsonObject at: '_rev' put: (oldDoc at: '_rev').

		"retry"
		^self documentAt: id put: jsonObject].
	self error: 'Boom'
    ]

    documentAt: id rev: rev [
	<category: 'accessing'>
	| response result |
	response := adaptor 
		    get: self namePrefix , id asString encodeForHTTP , '?rev=' 
			    , rev asString encodeForHTTP.
	result := adaptor readJsonFrom: response.
	response code = HTTPOK ifTrue: [^result].
	^adaptor couchDBError: result
    ]

    documentPut: jsonObject [
	<category: 'accessing'>
	| response code content |
	content := self utf8Encode: jsonObject asJsonString.
	response := self post: content.
	code := response code.
	code = HTTPCreated ifTrue: [^adaptor readJsonFrom: response].
	code = HTTPOK ifTrue: [^adaptor readJsonFrom: response].
	self error: 'Boom'
    ]

    documentToObject: json [
	<category: 'accessing'>
	| className binding |
	className := json at: 'sq_class'.

	"we're intentionally avoid using any globals here, such as Smalltalk"
	binding := self class environment bindingOf: className asSymbol.
	binding ifNil: [^self error: 'unable to instantiate - class not found'].
	^binding value instantiateFromCouchDocument: json
    ]

    info [
	"retrieve my info from server"

	<category: 'accessing'>
	^adaptor getJson: self namePrefix
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: aString [
	<category: 'accessing'>
	name := aString
    ]

    namePrefix [
	"path prefix for db name ,
	 could be optimized later to use lazy-initialized ivar"

	<category: 'accessing'>
	^'/' , self name , '/'
    ]

    put: object [
	<category: 'accessing'>
	^self documentPut: object asCouchDocument
    ]

    utf8Encode: aString [
	<category: 'accessing'>
	^ByteString 
	    streamContents: [:str | aString do: [:ch | self utf8Encode: ch to: str]]
    ]

    utf8Encode: aChar to: aStream [
	<category: 'accessing'>
	| u |
	u := aChar asUnicode.
	u < 128 ifTrue: [^aStream nextPut: aChar].
	u < 2048 
	    ifTrue: 
		[^aStream
		    nextPut: (Character value: 192 + (u >> 6));
		    nextPut: (Character value: 128 + (u bitAnd: 63))].
	u < 65536 
	    ifTrue: 
		[^aStream
		    nextPut: (Character value: 224 + (u >> 12));
		    nextPut: (Character value: 128 + (u >> 6 bitAnd: 63));
		    nextPut: (Character value: 128 + (u bitAnd: 63))].
	u <= 1114111 
	    ifTrue: 
		[^aStream
		    nextPut: (Character value: 240 + (u >> 18));
		    nextPut: (Character value: 128 + (u >> 12 bitAnd: 63));
		    nextPut: (Character value: 128 + (u >> 6 bitAnd: 63));
		    nextPut: (Character value: 128 + (u bitAnd: 63))].
	self error: 'Invalid utf-8 value'
    ]

    getJson: path [
	^adaptor getJson: self namePrefix , path
    ]

    post: aContent [
	^adaptor post: self namePrefix content: aContent
    ]

    put: aReq content: aContent [
	^adaptor put: self namePrefix , aReq content: aContent
    ]
]

