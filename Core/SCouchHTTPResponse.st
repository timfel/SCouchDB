Object subclass: SCouchHTTPResponse [
    | header code content cstream |
    
    <category: 'SCouchDB-Core'>
    <comment: nil>

    closeStream [
	"close an external connection, useful only for streaming response"

	<category: 'accessing'>
	cstream close
    ]

    code [
	"Answer the value of code"

	<category: 'accessing'>
	^code
    ]

    code: anObject [
	"Set the value of code"

	<category: 'accessing'>
	code := anObject
    ]

    content [
	<category: 'accessing'>
	^content ifNil: 
		[| len |
		content := (len := self contentLength) ifNil: 
				["unknown content length"

				cstream upToEnd]
			    ifNotNil: [:foo | cstream next: len asNumber].
		cstream close.
		content]
    ]

    contentLength [
	<category: 'accessing'>
	^header at: 'content-length' ifAbsent: [nil]
    ]

    contentType [
	<category: 'accessing'>
	^header at: 'content-type' ifAbsent: [nil]
    ]

    header [
	"Answer the value of header"

	<category: 'accessing'>
	^header
    ]

    readStream [
	<category: 'accessing'>
	^cstream
    ]

    transferEncoding [
	<category: 'accessing'>
	^header at: 'transfer-encoding' ifAbsent: [nil]
    ]

    contentStream: aStream [
	"use an appropriate content reader"

	<category: 'initialize-release'>
	cstream := self isChunked 
		    ifTrue: [SCouchChunkedContentStream on: aStream]
		    ifFalse: [aStream]
    ]

    parseHeaderLines: lines [
	"divide into basic lines"

	<category: 'initialize-release'>
	"fold lines that start with spaces into the previous line"

	| foldedLines i |
	foldedLines := OrderedCollection new.
	lines do: 
		[:line | 
		line first isSeparator 
		    ifTrue: [foldedLines at: foldedLines size put: foldedLines last , line]
		    ifFalse: [foldedLines add: line]].

	"make a dictionary mapping headers to header contents"
	header := Dictionary new.
	foldedLines do: 
		[:line | 
		i := line indexOf: $:.
		i > 0 
		    ifTrue: 
			[header at: (line copyFrom: 1 to: i - 1) asLowercase
			    put: (line copyFrom: i + 1 to: line size) withBlanksTrimmed]]
    ]

    isChunked [
	<category: 'testing'>
	^self transferEncoding = 'chunked'
    ]
]

