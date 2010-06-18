WriteStream extend [

    crlf [
        <category: '*SCouchDB-Core'>
        ^ self with: Character cr with: Character lf
    ]

]

