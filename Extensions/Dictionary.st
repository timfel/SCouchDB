
!Dictionary methodsFor: '*SCouchDB-Core' stamp: 'Igor.Stasenko 1/14/2010 00:42'!
asCouchDocument
	| associations |
	
	associations := self associations collect: [:each |
		JsonObject new 
			at: 'k' put: each key;
			at: 'v' put: each value;
			yourself
		].
	^ JsonObject new
		at: 'sq_class' put: self class name;
		at: 'sq_values' put: associations;
		yourself! !
instantiateFromCouchDocument:
	** ERROR!  THIS SCRIPT IS MISSING ** 

  