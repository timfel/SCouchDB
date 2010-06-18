Number extend [

    asCouchDocument [
	<category: '*SCouchDB-Core'>
	^(JsonObject new)
	    at: 'sq_class' put: self class name;
	    at: 'sq_value' put: self;
	    yourself
    ]

]

