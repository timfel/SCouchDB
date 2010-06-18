Object subclass: SCouchUTF8Stream [
    | stream peekChar |
    
    <category: 'SCouchDB-Core'>
    <comment: 'This is a converter stream, which reads from raw stream
and returns a utf8-decoded characters.

(Currently, used mainly for reading JSon, hence supports only 
#next
#peek
and 
#peelFor:
)'>

    SCouchUTF8Stream class >> on: aStream [
	^self new stream: aStream
    ]

    next [
	^peekChar ifNil: [self nextUTF8Char]
	    ifNotNil: 
		[:c | 
		peekChar := nil.
		c]
    ]

    nextByte [
	"Answer a byte, not character.
	 It would be more efficient to switch stream into binary mode,
	 but requires more effort"

	^stream next asciiValue
    ]

    nextUTF8Char [
	| value1 value2 value3 value4 |
	(value1 := self nextByte) ifNil: [^self endOfStreamAction value].
	value1 <= 127 
	    ifTrue: 
		["1-byte character"

		^Character value: value1].

	"at least 2-byte character"
	(value2 := self nextByte) ifNil: [^self errorMalformedInput].
	value1 <= 223 
	    ifTrue: 
		[^Unicode 
		    charFromUnicode: ((value1 bitAnd: 31) bitShift: 6) + (value2 bitAnd: 63)].

	"at least 3-byte character"
	(value3 := self nextByte) ifNil: [^self errorMalformedInput].
	value1 <= 239 
	    ifTrue: 
		[^Unicode 
		    charFromUnicode: ((value1 bitAnd: 15) bitShift: 12) 
			    + ((value2 bitAnd: 63) bitShift: 6) + (value3 bitAnd: 63)].

	"4-byte character"
	value1 <= 247 
	    ifTrue: 
		[(value4 := self nextByte) ifNil: [^self errorMalformedInput].
		^Unicode 
		    charFromUnicode: ((value1 bitAnd: 7) bitShift: 18) 
			    + ((value2 bitAnd: 63) bitShift: 12) + ((value3 bitAnd: 63) bitShift: 6) 
			    + (value4 bitAnd: 63)].
	^self errorMalformedInput
    ]

    peek [
	^peekChar ifNil: [peekChar := self nextUTF8Char]
    ]

    peekFor: anObject [
	"Answer false and do not move over the next element if it is not equal to
	 the argument, anObject, or if the receiver is at the end. Answer true
	 and increment the position for accessing elements, if the next element is
	 equal to anObject."

	^self peek = anObject and: 
		[self next.
		true]
    ]

    stream: aStream [
	stream := aStream
    ]
]

