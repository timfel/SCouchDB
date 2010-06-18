SharedPool subclass: #SCouchHTTPCodes
	instanceVariableNames: ''
	classVariableNames: 'HTTPCreated HTTPErrorConflict HTTPOK'
	poolDictionaries: ''
	category: 'SCouchDB-Core'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SCouchHTTPCodes class
	instanceVariableNames: ''!

!SCouchHTTPCodes class methodsFor: 'as yet unclassified' stamp: 'Igor.Stasenko 1/9/2010 17:01'!
initialize
	" self initialize "
	HTTPOK := 200.
	HTTPCreated := 201.
	
	HTTPErrorConflict := 409.! !


SCouchHTTPCodes initialize!
