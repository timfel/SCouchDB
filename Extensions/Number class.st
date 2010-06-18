Number class extend [

    instantiateFromCouchDocument: json [
	"Translate a json object, a couch document, into an instance of receiver.
	 See #asCouchDocument.
	 
	 Number instatiateFromCouchDocument: 123456 asCouchDocument
	 "

	<category: '*SCouchDB-Core'>
	^json at: 'sq_value'
    ]

]

