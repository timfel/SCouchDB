SharedPool subclass: SCouchHTTPCodes [
    
    <comment: nil>
    <category: 'SCouchDB-Core'>

    HTTPCreated := nil.
    HTTPErrorConflict := nil.
    HTTPOK := nil.

    SCouchHTTPCodes class >> initialize [
	"self initialize"

	HTTPOK := 200.
	HTTPCreated := 201.
	HTTPErrorConflict := 409
    ]
]



Eval [
    SCouchHTTPCodes initialize
]

