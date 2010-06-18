DateTime extend [

    asCouchDBString [
	"Return a suitable string representation that sorts lexicographically:
	 2008/06/09 13:52:11 +0000
	 
	 This is not proper ISO8601 (which uses yyyy-mm-dd) but it can easily
	 be used from javascript to create a Date instance."

	<category: '*SCouchDB-Core'>
	^String streamContents: 
		[:s | 
		s
		    nextPutAll: (self date printFormat: #(3 2 1 $/ 1 1 2));
		    space;
		    nextPutAll: self time print24;
		    space.
		offset negative ifFalse: [s nextPut: $+].
		s
		    nextPutAll: (offset hours printPaddedWith: $0 to: 2);
		    nextPutAll: (offset minutes printPaddedWith: $0 to: 2)]
    ]

]

