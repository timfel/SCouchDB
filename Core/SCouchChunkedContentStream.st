Stream subclass: SCouchChunkedContentStream [
    | socketstream chunkLen |
    
    <category: 'SCouchDB-Core'>
    <comment: nil>

    SCouchChunkedContentStream class >> on: aSocketStream [
	<category: 'instance creation'>
	^self basicNew on: aSocketStream
    ]

    basicNext [
	<category: 'accessing'>
	^self next
    ]

    isBinary [
	<category: 'accessing'>
	^false
    ]

    next [
	<category: 'accessing'>
	chunkLen = 0 
	    ifTrue: 
		[socketstream skip: 2.	"skip cr/lf"
		self readChunkLength.
		chunkLen ifNil: [^nil]].
	chunkLen := chunkLen - 1.
	^socketstream next
    ]

    peek [
	<category: 'accessing'>
	chunkLen = 0 
	    ifTrue: 
		[socketstream skip: 2.	"skip cr/lf"
		self readChunkLength].
	^socketstream peek
    ]

    peekFor: anObject [
	"Answer false and do not move over the next element if it is not equal to
	 the argument, anObject, or if the receiver is at the end. Answer true
	 and increment the position for accessing elements, if the next element is
	 equal to anObject."

	<category: 'accessing'>
	^self peek = anObject and: 
		[self next.
		true]
    ]

    on: aSocketStream [
	socketstream := aSocketStream.
	self readChunkLength
    ]

    readChunkLength [
	chunkLen := Number readFrom: socketstream nextLineCrLf asUppercase base: 16.
	chunkLen = 0 
	    ifTrue: 
		["we finished"

		socketstream close.
		chunkLen := nil]
    ]
]

