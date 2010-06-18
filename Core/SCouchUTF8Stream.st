Object subclass: #SCouchUTF8Stream
	instanceVariableNames: 'stream peekChar'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SCouchDB-Core'!
!SCouchUTF8Stream commentStamp: 'Igor.Stasenko 4/7/2010 01:52' prior: 0!
This is a converter stream, which reads from raw stream
and returns a utf8-decoded characters.

(Currently, used mainly for reading JSon, hence supports only 
#next
#peek
and 
#peelFor:
)!


!SCouchUTF8Stream methodsFor: 'as yet unclassified' stamp: 'Igor.Stasenko 4/7/2010 01:15'!
next

	^ peekChar ifNil: [ self nextUTF8Char ]
		ifNotNil: [:c | peekChar := nil. c ]  
! !

!SCouchUTF8Stream methodsFor: 'as yet unclassified' stamp: 'Igor.Stasenko 4/7/2010 01:11'!
nextByte
	"Answer a byte, not character.
	It would be more efficient to switch stream into binary mode,
	but requires more effort"
	^ stream next asciiValue
! !

!SCouchUTF8Stream methodsFor: 'as yet unclassified' stamp: 'Igor.Stasenko 4/7/2010 01:14'!
nextUTF8Char

	| value1 value2 value3 value4 |
	(value1 := self nextByte) ifNil: [^ self endOfStreamAction value].
	value1 <= 127 ifTrue: [
		"1-byte character"
		^ Character value: value1
	].

	"at least 2-byte character"
	(value2 := self nextByte) ifNil: [^self errorMalformedInput].
	value1 <= 2r11011111 ifTrue: [
		^ Unicode charFromUnicode: ((value1 bitAnd: 31) bitShift: 6) + (value2 bitAnd: 63).
	].

	"at least 3-byte character"
	(value3 := self nextByte) ifNil: [^self errorMalformedInput].
	(value1 <= 2r11101111) ifTrue: [
		^ Unicode charFromUnicode: ((value1 bitAnd: 15) bitShift: 12) + ((value2 bitAnd: 63) bitShift: 6)
				+ (value3 bitAnd: 63).
	].

	"4-byte character"
	(value1 <= 2r11110111) ifTrue: [
		(value4 := self nextByte) ifNil: [^self errorMalformedInput].
		^ Unicode charFromUnicode: ((value1 bitAnd: 16r7) bitShift: 18) +
					((value2 bitAnd: 63) bitShift: 12) + 
					((value3 bitAnd: 63) bitShift: 6) +
					(value4 bitAnd: 63).
	].

	^self errorMalformedInput
! !

!SCouchUTF8Stream methodsFor: 'as yet unclassified' stamp: 'Igor.Stasenko 4/7/2010 01:16'!
peek
	^ peekChar ifNil: [ peekChar := self nextUTF8Char ]! !

!SCouchUTF8Stream methodsFor: 'as yet unclassified' stamp: 'Igor.Stasenko 4/7/2010 01:32'!
peekFor: anObject
	"Answer false and do not move over the next element if it is not equal to 
	the argument, anObject, or if the receiver is at the end. Answer true 
	and increment the position for accessing elements, if the next element is 
	equal to anObject."

	^ (self peek = anObject) and: [ self next. true ]! !

!SCouchUTF8Stream methodsFor: 'as yet unclassified' stamp: 'Igor.Stasenko 3/16/2010 04:29'!
stream: aStream
	stream := aStream! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SCouchUTF8Stream class
	instanceVariableNames: ''!

!SCouchUTF8Stream class methodsFor: 'as yet unclassified' stamp: 'Igor.Stasenko 3/16/2010 09:31'!
on: aStream
	^ self new stream: aStream! !
