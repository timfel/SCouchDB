Object subclass: #SCouchDBAdaptor
	instanceVariableNames: 'host port resolvedHost httpResponseClass'
	classVariableNames: ''
	poolDictionaries: 'SCouchHTTPCodes'
	category: 'SCouchDB-Core'!

!SCouchDBAdaptor methodsFor: 'db api' stamp: 'Igor.Stasenko 12/27/2009 09:57'!
activeTasks
	^ self getJson: '/_active_tasks'! !

!SCouchDBAdaptor methodsFor: 'db api' stamp: 'Igor.Stasenko 12/27/2009 09:52'!
config
	^ self getJson: '/_config'! !

!SCouchDBAdaptor methodsFor: 'db api' stamp: 'Igor.Stasenko 4/8/2010 12:00'!
createDatabase: aName
	| result |
	aName do: [ :c | ('abcdefghijklmnopqrstuvwxyz0123456789_$()+-/`' includes: c)  
		ifFalse: [ ^ self error: 'Invalid database name' ]].

	result := self put: '/' , aName encodeForHTTP , '/'.
	
	result code = HTTPCreated ifTrue: [
		^ self newDatabase name: aName
		].
	
	^ self couchDBError: (self readJsonFrom: result)
	! !

!SCouchDBAdaptor methodsFor: 'db api' stamp: 'Igor.Stasenko 12/27/2009 07:05'!
databases
	| response |
	response := self get: '/_all_dbs'.
	
	^ self readJsonFrom: response	! !

!SCouchDBAdaptor methodsFor: 'db api' stamp: 'Igor.Stasenko 4/8/2010 12:00'!
deleteDatabase: aName
	| header result |
	header := self formRequestHeader: 'DELETE' path: '/', aName encodeForHTTP , '/'.
	result := self connectUsingHeader: header.
	(result code = HTTPOK )
		ifFalse: [  ^ self couchDBError: (self readJsonFrom: result) ].

! !

!SCouchDBAdaptor methodsFor: 'db api' stamp: 'gk 5/20/2010 16:25'!
ensureDatabase: aName
	"Either create new or answer an existing database."
	
	(self hasDatabase: aName) ifFalse: [ ^self createDatabase: aName ].
	^ self newDatabase name: aName! !

!SCouchDBAdaptor methodsFor: 'db api' stamp: 'gk 5/20/2010 16:24'!
hasDatabase: aName
	
	^self databases includes: aName! !

!SCouchDBAdaptor methodsFor: 'db api' stamp: 'Igor.Stasenko 12/27/2009 09:55'!
statistics
	^ self getJson: '/_stats'! !

!SCouchDBAdaptor methodsFor: 'db api' stamp: 'ZekeriyaKoc 4/7/2010 17:06'!
uuids
	^ self getJson: '/_uuids'! !

!SCouchDBAdaptor methodsFor: 'db api' stamp: 'ZekeriyaKoc 4/8/2010 09:51'!
uuids: aNumber
	^ self getJson: '/_uuids?count=', aNumber printString! !


!SCouchDBAdaptor methodsFor: '!!!!private!!!!'!
connectUsingHeader: aHeader

	^ self connectUsingHeader: aHeader content: nil! !

!SCouchDBAdaptor methodsFor: '!!!!private!!!!'!
connectUsingHeader: aHeader content: aContent
	| stream line response lines |
	stream := SocketStream openConnectionToHost: self resolvedHost port: self port.
	stream nextPutAll: aHeader.
	aContent ifNotNil: [ stream nextPutAll: aContent].
	stream flush.
	
	line := stream nextLineCrLf.
	(line beginsWith: 'HTTP/1.1') ifFalse: [
		^ self error: 'Malformed response header' ].

	response := self newHttpResponse.

	"  Integer readFrom: ('HTTP/1.1 200 OK' readStream upTo: $ ;yourself) "
	response code: ( 
		Integer readFrom: (line readStream upTo: Character space; yourself)).

	lines := OrderedCollection new.
	[ (line := stream nextLineCrLf) notEmpty ] whileTrue: [
		lines add: line ].
	
	response parseHeaderLines: lines.
	response contentStream: stream.
	^ response
! !

!SCouchDBAdaptor methodsFor: '!!!!private!!!!'!
formRequestHeader: type path: aPath

	^ self formRequestHeader: type path: aPath content: nil! !

!SCouchDBAdaptor methodsFor: '!!!!private!!!!'!
formRequestHeader: type path: aPath content: content

	^ String streamContents: [:str |
		str nextPutAll: type ; space; nextPutAll: aPath; space; nextPutAll: 'HTTP/1.1'; crlf;
			nextPutAll: 'Host: ', host , ':', port asString; crlf;
			nextPutAll: 'Accept: application/json';crlf;
			nextPutAll: 'Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7'; crlf.
			
			content ifNotNil: [
				str nextPutAll: 'Content-length: ' , content size asString; crlf;
					nextPutAll: 'Content-Type: application/json; charset=utf-8'; crlf.
				].
		str crlf.
	]

! !

!SCouchDBAdaptor methodsFor: '!!!!private!!!!'!
readJsonFrom: response	
	| result |
	 ('*application/json*' match: response contentType) ifFalse: [
		self error: 'response is not json'.
		].
	
	result := Json readFrom: (SCouchUTF8Stream on: response readStream).
	" close steam after use "
	response closeStream.
	^ result! !

!SCouchDBAdaptor methodsFor: '!!!!private!!!!'!
resolvedHost 
	^ resolvedHost ifNil: [
		resolvedHost := (NetNameResolver addressForName: self host) ]! !


!SCouchDBAdaptor methodsFor: 'error handling' stamp: 'Igor.Stasenko 1/8/2010 19:38'!
couchDBError: jobject 
	^ SCouchDBError signal: 
		'Error: ', (jobject at: 'error') , ' reason: ', (jobject at: 'reason')! !


!SCouchDBAdaptor methodsFor: 'http api' stamp: 'Igor.Stasenko 12/27/2009 05:27'!
get: path 

	^ self connectUsingHeader: (self formRequestHeader: 'GET' path: path).! !

!SCouchDBAdaptor methodsFor: 'http api' stamp: 'Igor.Stasenko 1/13/2010 22:44'!
getJson: path 
	"read a single json document"

	^ self readJsonFrom: (self get: path)! !

!SCouchDBAdaptor methodsFor: 'http api' stamp: 'rh 2/20/2010 13:20'!
post: path content: aContent

	^ self connectUsingHeader: (self formRequestHeader: 'POST' path: path content: aContent) content: aContent.! !

!SCouchDBAdaptor methodsFor: 'http api' stamp: 'Igor.Stasenko 12/27/2009 07:23'!
put: path 

	^ self put: path content: nil! !

!SCouchDBAdaptor methodsFor: 'http api' stamp: 'Igor.Stasenko 12/27/2009 07:23'!
put: path content: aContent

	^ self connectUsingHeader: (self formRequestHeader: 'PUT' path: path content: aContent) content: aContent.! !


!SCouchDBAdaptor methodsFor: 'accessing' stamp: 'Igor.Stasenko 12/27/2009 06:29'!
host
	^ host! !

!SCouchDBAdaptor methodsFor: 'accessing' stamp: 'Igor.Stasenko 1/8/2010 19:39'!
newDatabase
	"Answer a new instance of couch database wrapper"
	^ SCouchDatabase new adaptor: self! !

!SCouchDBAdaptor methodsFor: 'accessing' stamp: 'ZekeriyaKoc 4/8/2010 10:01'!
newUUID
	^ (self uuids at: 'uuids') at: 1! !

!SCouchDBAdaptor methodsFor: 'accessing' stamp: 'ZekeriyaKoc 4/8/2010 10:00'!
newUUIDs: aNumber
	^ (self uuids: aNumber) at: 'uuids'! !

!SCouchDBAdaptor methodsFor: 'accessing' stamp: 'Igor.Stasenko 12/27/2009 06:29'!
port
	^ port! !


!SCouchDBAdaptor methodsFor: 'initialize-release' stamp: 'gk 1/13/2010 11:52'!
host: aHost
	^self host: aHost port: 5984! !

!SCouchDBAdaptor methodsFor: 'initialize-release' stamp: 'Igor.Stasenko 12/27/2009 07:42'!
host: aHost port: aPort
	host := aHost.
	port := aPort.
	resolvedHost := nil.! !


!SCouchDBAdaptor methodsFor: 'streaming mode' stamp: 'Igor.Stasenko 1/8/2010 20:00'!
httpResponseClass: aResponseClass
	httpResponseClass := aResponseClass! !

!SCouchDBAdaptor methodsFor: 'streaming mode' stamp: 'Igor.Stasenko 1/8/2010 20:02'!
newHttpResponse

	^ (httpResponseClass ifNil: [ SCouchHTTPResponse ]) new! !
