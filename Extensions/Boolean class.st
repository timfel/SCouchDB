Boolean class extend [

    instantiateFromCouchDocument: json [
	"Translate a json object, a couch document, into an instance of receiver.
	 See #asCouchDocument."

	"answer a sole instance of me"

	<category: '*SCouchDB-Core'>
	^self initializedInstance
    ]

]

