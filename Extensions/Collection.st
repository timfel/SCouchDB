
!Collection methodsFor: '*SCouchDB-Core' stamp: 'Igor.Stasenko 1/12/2010 00:21'!
asCouchDocument

	^ JsonObject new
		at: 'sq_class' put: self class name;
		at: 'sq_values' put: self;
		yourself! !
instantiateFromCouchDocument:
	** ERROR!  THIS SCRIPT IS MISSING ** 

  