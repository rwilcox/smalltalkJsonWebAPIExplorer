"
Please comment me using the following template inspired by Class Responsibility Collaborator (CRC) design:

For the Class part:  State a one line summary. For example, ""I represent a paragraph of text"".

For the Responsibility part: Three sentences about my main responsibilities - what I do, what I know.

For the Collaborators Part: State my main collaborators and one line about how I interact with them. 

Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.


    Implementation Points
"
Class {
	#name : #EasyWebAPIExplorer,
	#superclass : #Object,
	#category : #WebAPIExplorer
}

{ #category : #examples }
EasyWebAPIExplorer class >> displayJSONInInspector [
	"example of how I did this"

	| res jsonExplorer |
	res := ZnClient new
		beOneShot;
		url: 'https://api.github.com/users/rwilcox/repos';
		contentReader: [ :entity | NeoJSONObject fromString: entity contents ];
		get.
	jsonExplorer := EasyWebAPIExplorer new inspectWithJSONExplorer: res .

	"jsonObject := NeoJSONObject fromString: jsonString."

	"Default presentation filter includes meta inspector, which makes no sense here"
]

{ #category : #'as yet unclassified' }
EasyWebAPIExplorer class >> zneasyJSONMethods [
	"comment stating purpose of message"

	ZnEasy getJSON: 'http://api.coinbase.com/v2/exchange-rates?currency=BTC' headers: { } .
	
	ZnEasy getJSON: 'http://api.coinbase.com/v2/exchange-rates?currency=BTC' headers: { } into: [ :jsonIn :responseIn |
	EasyWebAPIExplorer new inspectWithJSONExplorer: jsonIn
	].

	
	
	
]

{ #category : #'as yet unclassified' }
EasyWebAPIExplorer >> inspectWithJSONExplorer: obj [
|it|
	it := GTInspector new.
	it
		presentationFilter:
			(GTInspectorTagFilter new
				defaultTag: #eval;
				addAndSelectTag: #eval).
	
	it openOn: obj
]
