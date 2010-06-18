
!String methodsFor: '*SCouchDB-Core' stamp: 'Igor.Stasenko 1/12/2010 00:46'!
asCouchDocument

	^ JsonObject new
		at: 'sq_class' put: self class name;
		at: 'sq_value' put: self;
		yourself! !
instantiateFromCouchDocument:
	** ERROR!  THIS SCRIPT IS MISSING ** 

  