DateTime class extend [

    fromCouchDBString: aString [
	"Parse a string representation like:
	 
	 DateAndTime fromCouchDBString: '2008/06/09 13:52:11 -0130'
	 
	 This is not proper ISO8601 (which uses yyyy-mm-dd) but it can easily
	 be used from javascript to create a Date instance."

	<category: '*SCouchDB-Core'>
	| date time stream offset instance sign |
	stream := aString readStream.
	stream skipSeparators.
	"note, #readFrom:pattern: may be missing"
	date := Date readFrom: stream pattern: 'yyyy/mm/dd'.
	stream skipSeparators.
	time := Time readFrom: stream.
	stream skipSeparators.
	sign := stream next.
	offset := (stream next: 2) asInteger hours 
		    + (stream next: 2) asInteger minutes.
	sign = $- ifTrue: [offset := offset negated].
	instance := self date: date time: time.
	^offset = 0 ifTrue: [instance] ifFalse: [instance offset: offset]
    ]

]

