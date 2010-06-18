
!Object methodsFor: '*SCouchDB-Core' stamp: 'Igor.Stasenko 1/13/2010 12:59'!
asCouchDocument
	" Answer a json object, representing a receiver as couchDB document"
	" A most generic implementation 
	
	 - sq_class holds a class name
	 - any instance variables is stored as name: value pairs
	 - sq_values holds an indexed variables array (if any)
	 - sq_value holds a single literal value (for integers, floats and booleans)
	
	Limitation: any values , held by vars should be able to jsonify (implement #jsonWriteOn: )

	Example: 
	   (1@2) asCouchDocument asJsonString
	   #(1 2 3) asCouchDocument asJsonString

	See also, #instantiateFromCouchDocument: at class side for reverse translation .
	"
	| json |
	json := JsonObject new.
	
	json at: 'sq_class' put: self class name.
	self class allInstVarNames do: [:name |
		json at: name put: (self instVarNamed: name) ].

	self class isVariable ifTrue: [ 
		json at: 'sq_values' put: 
			(( 1 to: self size ) collect: [:i | self at: i ])
	].

	^ json
! !
instantiateFromCouchDocument:
	** ERROR!  THIS SCRIPT IS MISSING ** 

  