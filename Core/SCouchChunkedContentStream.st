Stream subclass: #SCouchChunkedContentStream
	instanceVariableNames: 'socketstream chunkLen'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SCouchDB-Core'!

!SCouchChunkedContentStream methodsFor: 'accessing' stamp: 'rh 3/20/2010 18:11'!
basicNext

	^self next! !

!SCouchChunkedContentStream methodsFor: 'accessing' stamp: 'rh 3/20/2010 18:11'!
isBinary

	^false! !

!SCouchChunkedContentStream methodsFor: 'accessing' stamp: 'Igor.Stasenko 1/13/2010 21:32'!
next
	chunkLen = 0 ifTrue: [
		socketstream skip: 2.  "skip cr/lf"
		self readChunkLength.
		chunkLen ifNil: [ ^ nil ].
	].

	chunkLen := chunkLen - 1.	
	^ socketstream next! !

!SCouchChunkedContentStream methodsFor: 'accessing' stamp: 'Igor.Stasenko 1/13/2010 21:31'!
peek
	
	chunkLen = 0 ifTrue: [
		socketstream skip: 2.  "skip cr/lf"
		self readChunkLength.
	].

	^ socketstream peek! !

!SCouchChunkedContentStream methodsFor: 'accessing' stamp: 'Igor.Stasenko 4/7/2010 10:20'!
peekFor: anObject
	"Answer false and do not move over the next element if it is not equal to 
	the argument, anObject, or if the receiver is at the end. Answer true 
	and increment the position for accessing elements, if the next element is 
	equal to anObject."

	^ (self peek = anObject) and: [ self next. true ]! !


!SCouchChunkedContentStream methodsFor: 'as yet unclassified' stamp: 'Igor.Stasenko 1/13/2010 21:22'!
on: aSocketStream
	socketstream := aSocketStream.
	
	self readChunkLength
! !

!SCouchChunkedContentStream methodsFor: 'as yet unclassified' stamp: 'Igor.Stasenko 1/13/2010 21:28'!
readChunkLength

	chunkLen := Number readFrom: socketstream nextLineCrLf asUppercase base: 16.
	
	chunkLen = 0 ifTrue: [
		"we finished"
		socketstream close.
		chunkLen := nil
		].
	! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SCouchChunkedContentStream class
	instanceVariableNames: ''!

!SCouchChunkedContentStream class methodsFor: 'instance creation' stamp: 'Igor.Stasenko 1/13/2010 21:12'!
on: aSocketStream 
	^ self basicNew on: aSocketStream! !
