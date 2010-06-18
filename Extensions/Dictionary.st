Dictionary extend [

    asCouchDocument [
	<category: '*SCouchDB-Core'>
	| associations |
	associations := self associations collect: 
			[:each | 
			(JsonObject new)
			    at: 'k' put: each key;
			    at: 'v' put: each value;
			    yourself].
	^(JsonObject new)
	    at: 'sq_class' put: self class name;
	    at: 'sq_values' put: associations;
	    yourself
    ]

]

