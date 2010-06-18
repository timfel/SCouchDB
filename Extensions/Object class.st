Object class extend [

    instantiateFromCouchDocument: json [
	"Translate a json object, a couch document, into an instance of receiver.
	 See #asCouchDocument.
	 
	 Point instatiateFromCouchDocument: (1@2) asCouchDocument
	 "

	<category: '*SCouchDB-Core'>
	| instance |
	self isVariable 
	    ifTrue: 
		[| values |
		values := json at: 'sq_values'.
		instance := self basicNew: values size.
		values withIndexDo: [:val :i | instance basicAt: i put: val]]
	    ifFalse: [instance := self basicNew].

	"fill ivars"
	self allInstVarNames 
	    do: [:iname | json at: iname ifPresent: [:val | instance instVarNamed: iname put: val]].
	^instance
    ]

]

