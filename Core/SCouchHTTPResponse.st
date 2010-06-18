Object subclass: #SCouchHTTPResponse
	instanceVariableNames: 'header code content cstream'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SCouchDB-Core'!

!SCouchHTTPResponse methodsFor: 'accessing' stamp: 'Igor.Stasenko 1/13/2010 20:42'!
closeStream
	"close an external connection, useful only for streaming response"
	
	cstream close! !

!SCouchHTTPResponse methodsFor: 'accessing' stamp: 'Igor.Stasenko 12/27/2009 06:20'!
code
	"Answer the value of code"

	^ code! !

!SCouchHTTPResponse methodsFor: 'accessing' stamp: 'Igor.Stasenko 12/27/2009 06:20'!
code: anObject
	"Set the value of code"

	code := anObject! !

!SCouchHTTPResponse methodsFor: 'accessing' stamp: 'Igor.Stasenko 1/13/2010 20:46'!
content

	^ content ifNil: [ | len |
		content := (len := self contentLength) 
			"unknown content length"
			ifNil: [ cstream upToEnd ] 
			ifNotNil: [ cstream next: (len asNumber) ].
		cstream close.
		content ]! !

!SCouchHTTPResponse methodsFor: 'accessing' stamp: 'Igor.Stasenko 12/27/2009 06:48'!
contentLength

	^ header at: 'content-length' ifAbsent: [nil]! !

!SCouchHTTPResponse methodsFor: 'accessing' stamp: 'Igor.Stasenko 12/27/2009 06:56'!
contentType

	^ header at: 'content-type' ifAbsent: [nil]! !

!SCouchHTTPResponse methodsFor: 'accessing' stamp: 'Igor.Stasenko 12/27/2009 06:20'!
header
	"Answer the value of header"

	^ header! !

!SCouchHTTPResponse methodsFor: 'accessing' stamp: 'Igor.Stasenko 1/13/2010 20:42'!
readStream
	^ cstream! !

!SCouchHTTPResponse methodsFor: 'accessing' stamp: 'Igor.Stasenko 1/13/2010 20:48'!
transferEncoding
	^ header at: 'transfer-encoding' ifAbsent: [nil ]! !


!SCouchHTTPResponse methodsFor: 'initialize-release' stamp: 'Igor.Stasenko 3/16/2010 04:24'!
contentStream: aStream
	"use an appropriate content reader"
	
	cstream := self isChunked 
		ifTrue: [ SCouchChunkedContentStream on: aStream ]
		ifFalse: [ aStream ]
	! !

!SCouchHTTPResponse methodsFor: 'initialize-release' stamp: 'Igor.Stasenko 12/27/2009 06:45'!
parseHeaderLines: lines

	"divide into basic lines"
	| foldedLines i |

	"fold lines that start with spaces into the previous line"
	foldedLines := OrderedCollection new.
	lines do: [ :line |
		line first isSeparator ifTrue: [
			foldedLines at: foldedLines size  put: (foldedLines last, line) ]
		ifFalse: [ foldedLines add: line ] ].

	"make a dictionary mapping headers to header contents"
	header := Dictionary new.
	foldedLines do: [ :line |
		i := line indexOf: $:.
		i > 0 ifTrue: [
			header 
			at: (line copyFrom: 1 to: i-1) asLowercase 
			put: (line copyFrom: i+1 to: line size) withBlanksTrimmed ] ].
! !


!SCouchHTTPResponse methodsFor: 'testing' stamp: 'Igor.Stasenko 1/13/2010 20:48'!
isChunked
	^ self transferEncoding = 'chunked'! !
