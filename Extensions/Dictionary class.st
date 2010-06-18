Dictionary class extend [

    instantiateFromCouchDocument: aJson [
	"Translate a json object, a couch document, into an instance of receiver.
	 See #asCouchDocument."

	<category: '*SCouchDB-Core'>
	| associations dict |
	associations := aJson at: 'sq_values'.
	dict := self new.
	associations do: [:each | dict at: (each at: 'k') put: (each at: 'v')].
	^dict
    ]

]

