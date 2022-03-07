Class {
	#name : #JSONTools,
	#superclass : #Object,
	#category : #WebAPIExplorer
}

{ #category : #'as yet unclassified' }
JSONTools class >> finderMenuOn: aBuilder [
	"comment stating purpose of message"

	<worldMenu>
	| jsonItem |
	jsonItem := aBuilder item: #JSON_Utilities ; label: 'JSON Utilities'.
	jsonItem withSeparatorAfter.
	jsonItem
		with: [ (aBuilder
				item: #InspectJSON;
				label: 'Inspect JSON on Clipboard') action: [ JSONTools inspectClipboard ] ]

	"(aBuilder item: #Nautilus) action: [ Nautilus new open ].
			(aBuilder item: #RPWTest) action: [ RPWTest browse ].
			(aBuilder item: #'My Grid Example (code)') action: [ RPWGridExample browse ].
			(aBuilder item: #'My TODO list') action: [ RPWGridExample new open ]"
]

{ #category : #'as yet unclassified' }
JSONTools class >> inspectClipboard [
|jsonObj|
jsonObj := STONJSON fromString: Clipboard clipboardText .

EasyWebAPIExplorer new inspectWithJSONExplorer: jsonObj .

]
