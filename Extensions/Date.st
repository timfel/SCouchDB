Date extend [

    asCouchDBString [
	"Return a suitable string representation that sorts lexicographically:
	 2008/06/09"

	<category: '*SCouchDB-Core'>
	^String 
	    streamContents: [:s | s nextPutAll: (self printFormat: #(3 2 1 $/ 1 1 2))]
    ]

]

