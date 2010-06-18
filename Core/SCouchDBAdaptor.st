Object subclass: SCouchDBAdaptor [
    | host port resolvedHost httpResponseClass |
    
    <import: SCouchHTTPCodes>
    <category: 'SCouchDB-Core'>
    <comment: nil>

    activeTasks [
	<category: 'db api'>
	^self getJson: '/_active_tasks'
    ]

    config [
	<category: 'db api'>
	^self getJson: '/_config'
    ]

    createDatabase: aName [
	<category: 'db api'>
	| result |
	aName do: 
		[:c | 
		('abcdefghijklmnopqrstuvwxyz0123456789_$()+-/`' includes: c) 
		    ifFalse: [^self error: 'Invalid database name']].
	result := self put: '/' , aName encodeForHTTP , '/'.
	result code = SCouchHTTPCodes httpCreated 
	    ifTrue: [^self newDatabase name: aName].
	^self couchDBError: (self readJsonFrom: result)
    ]

    databases [
	<category: 'db api'>
	| response |
	response := self get: '/_all_dbs'.
	^self readJsonFrom: response
    ]

    deleteDatabase: aName [
	<category: 'db api'>
	| header result |
	header := self formRequestHeader: 'DELETE'
		    path: '/' , aName encodeForHTTP , '/'.
	result := self connectUsingHeader: header.
	result code = SCouchHTTPCodes httpOk 
	    ifFalse: [^self couchDBError: (self readJsonFrom: result)]
    ]

    ensureDatabase: aName [
	"Either create new or answer an existing database."

	<category: 'db api'>
	(self hasDatabase: aName) ifFalse: [^self createDatabase: aName].
	^self newDatabase name: aName
    ]

    hasDatabase: aName [
	<category: 'db api'>
	^self databases includes: aName
    ]

    statistics [
	<category: 'db api'>
	^self getJson: '/_stats'
    ]

    uuids [
	<category: 'db api'>
	^self getJson: '/_uuids'
    ]

    uuids: aNumber [
	<category: 'db api'>
	^self getJson: '/_uuids?count=' , aNumber printString
    ]

    connectUsingHeader: aHeader [
	<category: '!!private!!'>
	^self connectUsingHeader: aHeader content: nil
    ]

    connectUsingHeader: aHeader content: aContent [
	<category: '!!private!!'>
	| stream line response lines |
	stream := SocketStream openConnectionToHost: self resolvedHost
		    port: self port.
	stream nextPutAll: aHeader.
	aContent ifNotNil: [:foo | stream nextPutAll: aContent].
	stream flush.
	line := stream nextLineCrLf.
	(line startsWith: 'HTTP/1.1') 
	    ifFalse: [^self error: 'Malformed response header'].
	response := self newHttpResponse.

	"Integer readFrom: ('HTTP/1.1 200 OK' readStream upTo: $ ;yourself)"
	response 
	    code: (Integer readFrom: ((line readStream)
			    upTo: Character space;
			    yourself)).
	lines := OrderedCollection new.
	[(line := stream nextLineCrLf) notEmpty] whileTrue: [lines add: line].
	response parseHeaderLines: lines.
	response contentStream: stream.
	^response
    ]

    formRequestHeader: type path: aPath [
	<category: '!!private!!'>
	^self 
	    formRequestHeader: type
	    path: aPath
	    content: nil
    ]

    formRequestHeader: type path: aPath content: content [
	<category: '!!private!!'>
	^String streamContents: 
		[:str | 
		str
		    nextPutAll: type;
		    space;
		    nextPutAll: aPath;
		    space;
		    nextPutAll: 'HTTP/1.1';
		    crlf;
		    nextPutAll: 'Host: ' , host , ':' , port asString;
		    crlf;
		    nextPutAll: 'Accept: application/json';
		    crlf;
		    nextPutAll: 'Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7';
		    crlf.
		content ifNotNil: 
			[:foo | 
			str
			    nextPutAll: 'Content-length: ' , content size asString;
			    crlf;
			    nextPutAll: 'Content-Type: application/json; charset=utf-8';
			    crlf].
		str crlf]
    ]

    readJsonFrom: response [
	<category: '!!private!!'>
	| result |
	('*application/json*' match: response contentType) 
	    ifFalse: [self error: 'response is not json'].
	result := Json readFrom: (SCouchUTF8Stream on: response readStream).
	"close steam after use"
	response closeStream.
	^result
    ]

    resolvedHost [
	<category: '!!private!!'>
	^resolvedHost 
	    ifNil: [resolvedHost := NetNameResolver addressForName: self host]
    ]

    couchDBError: jobject [
	<category: 'error handling'>
	^SCouchDBError signal: 'Error: ' , (jobject at: 'error') , ' reason: ' 
		    , (jobject at: 'reason')
    ]

    get: path [
	<category: 'http api'>
	^self connectUsingHeader: (self formRequestHeader: 'GET' path: path)
    ]

    getJson: path [
	"read a single json document"

	<category: 'http api'>
	^self readJsonFrom: (self get: path)
    ]

    post: path content: aContent [
	<category: 'http api'>
	^self connectUsingHeader: (self 
		    formRequestHeader: 'POST'
		    path: path
		    content: aContent)
	    content: aContent
    ]

    put: path [
	<category: 'http api'>
	^self put: path content: nil
    ]

    put: path content: aContent [
	<category: 'http api'>
	^self connectUsingHeader: (self 
		    formRequestHeader: 'PUT'
		    path: path
		    content: aContent)
	    content: aContent
    ]

    host [
	<category: 'accessing'>
	^host
    ]

    newDatabase [
	"Answer a new instance of couch database wrapper"

	<category: 'accessing'>
	^SCouchDatabase new adaptor: self
    ]

    newUUID [
	<category: 'accessing'>
	^(self uuids at: 'uuids') at: 1
    ]

    newUUIDs: aNumber [
	<category: 'accessing'>
	^(self uuids: aNumber) at: 'uuids'
    ]

    port [
	<category: 'accessing'>
	^port
    ]

    host: aHost [
	<category: 'initialize-release'>
	^self host: aHost port: 5984
    ]

    host: aHost port: aPort [
	<category: 'initialize-release'>
	host := aHost.
	port := aPort.
	resolvedHost := nil
    ]

    httpResponseClass: aResponseClass [
	<category: 'streaming mode'>
	httpResponseClass := aResponseClass
    ]

    newHttpResponse [
	<category: 'streaming mode'>
	^(httpResponseClass ifNil: [SCouchHTTPResponse]) new
    ]
]

