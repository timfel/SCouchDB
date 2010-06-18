
!Date methodsFor: '*SCouchDB-Core' stamp: 'rh 2/26/2010 23:30'!
asCouchDBString
	"Return a suitable string representation that sorts lexicographically:
		2008/06/09"

	^String streamContents: [:s |
		s nextPutAll: (self printFormat: #(3 2 1 $/ 1 1 2)).
		]
! !
