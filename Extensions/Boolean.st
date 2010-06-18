Boolean extend [

    asCouchDocument [
	<category: '*SCouchDB-Core'>
	^(JsonObject new)
	    at: 'sq_class' put: self class name;
	    yourself
    ]

]

