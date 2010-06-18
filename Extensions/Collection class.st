Collection class extend [

    instantiateFromCouchDocument: json [
	"Translate a json object, a couch document, into an instance of receiver.
	 See #asCouchDocument."

	<category: '*SCouchDB-Core'>
	^self withAll: (json at: 'sq_values')
    ]

]

