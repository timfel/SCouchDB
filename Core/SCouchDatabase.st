Object subclass: #SCouchDatabase
	instanceVariableNames: 'adaptor name'
	classVariableNames: ''
	poolDictionaries: 'SCouchHTTPCodes'
	category: 'SCouchDB-Core'!

!SCouchDatabase methodsFor: 'accessing' stamp: 'Igor.Stasenko 12/27/2009 07:40'!
adaptor
	"Answer the value of adaptor"

	^ adaptor! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'Igor.Stasenko 12/27/2009 07:40'!
adaptor: anObject
	"Set the value of adaptor"

	adaptor := anObject! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'gk 1/13/2010 12:12'!
all

	| json |
	json := self allDocuments.
	self halt.! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'gk 5/20/2010 16:22'!
allDocuments
	| result |
	result := self getJson: '_all_docs?include_docs=true'.
	^ (result at: 'rows') collect: [:row | row at: 'doc']! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'gk 5/20/2010 16:21'!
allDocumentsAs: aClass
	| result |
	result := self getJson: '_all_docs?include_docs=true'.
	^ (result at: 'rows') collect: [:row | aClass fromCouchDocument: (row at: 'doc')]! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'Igor.Stasenko 1/11/2010 23:57'!
at: id 

	^ self at: id ifAbsent: [ self error: 'Document with given id not found' ]! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'gk 1/13/2010 12:09'!
at: id ifAbsent: aBlock
	
	^self documentToObject: (self documentAt: id ifAbsent: [ ^ aBlock value ])! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'Igor.Stasenko 1/9/2010 17:25'!
at: key put: object

	^ self documentAt: key put: object asCouchDocument! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'Igor.Stasenko 4/8/2010 12:05'!
documentAt: id

	"read a single json document"
	| response result |
	response := adaptor get: self namePrefix , id asString encodeForHTTP.

	result := adaptor readJsonFrom: response.
	response code = HTTPOK ifTrue: [ ^ result ].
	
	^ adaptor couchDBError: result! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'Igor.Stasenko 1/13/2010 20:22'!
documentAt: id ifAbsent: aBlock

	"read a single json document"
	| response |
	response := adaptor get: self namePrefix , id asString encodeForHTTP.

	response code = HTTPOK ifTrue: [
		^ adaptor readJsonFrom: response.
		].
	
	^ aBlock value! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'Igor.Stasenko 1/13/2010 13:06'!
documentAt: key ifAbsentPut: aBlockWithJsonObject

	"read a single json document"
	| response |
	response := adaptor get:  self namePrefix , key asString encodeForHTTP.

	response code = HTTPOK ifTrue: [
		^ adaptor readJsonFrom: response 
		].
	
	^self documentAt: key put: aBlockWithJsonObject value.
! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'Igor.Stasenko 5/13/2010 04:44'!
documentAt: id put: jsonObject
	| response code content |
	
	content := self utf8Encode: jsonObject asJsonString.
	response := self put: id asString encodeForHTTP content: content.
	
	code := response code.
	
	code = HTTPCreated ifTrue: [ ^adaptor readJsonFrom:  response ].
	code = HTTPOK ifTrue: [ ^ adaptor readJsonFrom: response ].

	code = HTTPErrorConflict ifTrue: [ 
		"document already exists"
		| oldDoc | 
		response closeStream.
		oldDoc := self documentAt: id.
		jsonObject at: '_rev' put: (oldDoc at: '_rev').
		
		" retry "
		^ self documentAt: id put: jsonObject
	].

	self error: 'Boom'

! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'Igor.Stasenko 4/8/2010 11:56'!
documentAt: id rev: rev

	| response result |
	response := adaptor get: self namePrefix , id asString encodeForHTTP ,
		'?rev=' , rev asString encodeForHTTP.

	result := adaptor readJsonFrom: response.
	response code = HTTPOK ifTrue: [ ^ result ].
	^ adaptor couchDBError: result! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'gk 5/20/2010 16:01'!
documentPut: jsonObject
	| response code content |
	
	content := self utf8Encode: jsonObject asJsonString.
	response := self post: content.
	
	code := response code.
	
	code = HTTPCreated ifTrue: [ ^adaptor readJsonFrom:  response ].
	code = HTTPOK ifTrue: [ ^ adaptor readJsonFrom: response ].

	self error: 'Boom'

! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'gk 1/13/2010 12:08'!
documentToObject: json

	| className binding |

	className := json at: 'sq_class'.

	"we're intentionally avoid using any globals here, such as Smalltalk"
	binding := self class environment bindingOf: className asSymbol.
	
	binding ifNil: [ ^ self error: 'unable to instantiate - class not found' ].
	
	^ binding value instantiateFromCouchDocument: json.
! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'Igor.Stasenko 1/9/2010 17:11'!
info
	"retrieve my info from server"
	
	^ adaptor getJson: self namePrefix! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'Igor.Stasenko 12/27/2009 07:40'!
name
	^ name! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'Igor.Stasenko 12/27/2009 07:40'!
name: aString
	name := aString! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'Igor.Stasenko 1/9/2010 17:10'!
namePrefix
	"path prefix for db name , 
	could be optimized later to use lazy-initialized ivar"
	
	^ '/' , self name , '/'
! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'gk 5/20/2010 16:01'!
put: object

	^ self documentPut: object asCouchDocument! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'Igor.Stasenko 5/13/2010 05:01'!
utf8Encode: aString 

	^ ByteString streamContents: [:str | aString do: [:ch | self utf8Encode: ch to: str ]]

! !

!SCouchDatabase methodsFor: 'accessing' stamp: 'Igor.Stasenko 5/13/2010 05:00'!
utf8Encode: aChar to: aStream
	| u |
	u := aChar asUnicode.
	u < 128 ifTrue: [ ^ aStream nextPut: aChar].
	u < 16r800 ifTrue: [
		^ aStream 
			nextPut: (Character value: (2r11000000 + (u >> 6)));
			nextPut: (Character value: (2r10000000 + (u bitAnd: 2r111111))) ].
	u < 16r10000 ifTrue: [
		^ aStream 
			nextPut: (Character value: (2r11100000 + (u >> 12)));
			nextPut: (Character value: (2r10000000 + ((u >> 6)bitAnd: 2r111111)));
			nextPut: (Character value: (2r10000000 + (u bitAnd: 2r111111))) ].
	u <= 16r10FFFF ifTrue: [
		^ aStream 
			nextPut: (Character value: (2r11110000 + (u >> 18)));
			nextPut: (Character value: (2r10000000 + ((u >> 12)bitAnd: 2r111111)));
			nextPut: (Character value: (2r10000000 + ((u >> 6)bitAnd: 2r111111)));
			nextPut: (Character value: (2r10000000 + (u bitAnd: 2r111111))) ].

	self error: 'Invalid utf-8 value'
! !


!SCouchDatabase methodsFor: 'as yet unclassified' stamp: 'Igor.Stasenko 1/9/2010 17:11'!
getJson: path 

	^ adaptor getJson:  self namePrefix , path! !

!SCouchDatabase methodsFor: 'as yet unclassified' stamp: 'rh 2/20/2010 13:35'!
post: aContent

	^ adaptor post: self namePrefix content: aContent! !

!SCouchDatabase methodsFor: 'as yet unclassified' stamp: 'Igor.Stasenko 1/9/2010 17:11'!
put: aReq content: aContent

	^ adaptor put: self namePrefix, aReq content: aContent! !
