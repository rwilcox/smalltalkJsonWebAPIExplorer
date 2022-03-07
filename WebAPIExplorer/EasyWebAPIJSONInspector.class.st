Class {
	#name : #EasyWebAPIJSONInspector,
	#superclass : #GLMCompositePresentation,
	#instVars : [
		'cachedHashes'
	],
	#category : #WebAPIExplorer
}

{ #category : #'private building' }
EasyWebAPIJSONInspector >> basicVariableValuePairsFor: anObject [

	self subclassResponsibility 
]

{ #category : #building }
EasyWebAPIJSONInspector >> compose [
	self title: 'Eval'.
	self tabulator
		with: [ :browser | 
			browser row: #evaluator.
			browser transmit
				to: #evaluator;
				andShow: [ :a | self evaluatorIn: a ].
			browser transmit
				from: #evaluator;
				toOutsidePort: #selection ]
]

{ #category : #'private building' }
EasyWebAPIJSONInspector >> evaluatorIn: composite [
	^ composite pharoScript
		doItReceiver: [ :object | object ];
		smalltalkClass: [ :object | object class ];
		display: [ :object | 
			String
				streamContents: [ :stream | 
					stream
						nextPutAll: '"Do and Go"';
						cr;
						nextPutAll: (GTSnippets snippetAt: object class)
					"nextPutAll: (self printStringOf: object);
					cr;" ] ];
		onChangeOfPort: #text
			act: [ :textPresentation :object | 
			GTSnippets
				snippetAt: object class
				put: (self stringWithoutInitialCommentFrom: textPresentation text asString).
			textPresentation clearUserEdits ];
		installDefaultSelectionActions
]

{ #category : #'private - updating' }
EasyWebAPIJSONInspector >> generateCacheFor: anObject [
	| valuesCache |
	
	valuesCache := OrderedDictionary new.
	((self basicVariableValuePairsFor: anObject) do: [ :assoc | 
		valuesCache 
			at: assoc key 
			put: (self generateHashFor: assoc value) ]).
	
	^ valuesCache
]

{ #category : #'private - updating' }
EasyWebAPIJSONInspector >> generateHashFor: anObject [ 

	^ (self basicVariableValuePairsFor: anObject)
		inject: anObject gtInspectorHash
		into: [ :hashValue :assoc | hashValue bitXor: assoc value gtInspectorHash ].
	
	
]

{ #category : #'private building' }
EasyWebAPIJSONInspector >> iconFor: anObject [
		
	^ [ (anObject iconOrThumbnailOfSize: 16)
		ifNil: [ anObject class systemIcon ] ]
			on: Error do: [ :error |
			self iconFor: anObject error: error ]
]

{ #category : #'private building' }
EasyWebAPIJSONInspector >> iconFor: anEyeElement error: error [
	^ Smalltalk ui icons smallWarningIcon
]

{ #category : #'private building' }
EasyWebAPIJSONInspector >> printStringOf: anObject [
	self subclassResponsibility
]

{ #category : #'private - updating' }
EasyWebAPIJSONInspector >> rebuildCacheFor: anObject [

	cachedHashes := self generateCacheFor: anObject
]

{ #category : #'private - updating' }
EasyWebAPIJSONInspector >> shouldRefresh [
	|newCache result|

	newCache := self generateCacheFor: self entity.
	result := cachedHashes ~= newCache.
	cachedHashes := newCache.
	^ result
]

{ #category : #'private building' }
EasyWebAPIJSONInspector >> stringWithoutInitialCommentFrom: aString [
	^ (aString trimLeft isEmpty not and: [ aString trimLeft first = $" ])
		ifFalse: [ aString trimRight ]
		ifTrue: [|startIndex doubleQuoteCounter|
			startIndex := aString findAnySubstring: '"' startingAt: (aString indexOf: $") + 1.
			doubleQuoteCounter := 1.
			"we need to iterate over the whole string queuing quotes to support nested double quotes"
			[ startIndex <= aString size
				and: [ doubleQuoteCounter % 2 = 1
					or: [ (aString at: startIndex) = $"
						or: [ (aString at: startIndex) isSeparator ] ] ] ]
			whileTrue: [ 
				(aString at: startIndex) = $" ifTrue: [ 
					doubleQuoteCounter := doubleQuoteCounter + 1 ].
				startIndex := startIndex + 1 ].
	
			(startIndex >= (aString size + 1)) ifTrue: [ "No content if a comment cannot be identified. " ^ '' ].
			(aString
				copyFrom: startIndex
				to: aString size) trimBoth ]
]

{ #category : #'private building' }
EasyWebAPIJSONInspector >> updateInstanceVariable: aSymbol from: anObject basedOn: aString [
	|result|

	(anObject class hasInstVarNamed: aSymbol) 
		ifFalse: [ ^ self ].
	result := anObject class compiler
			source: aString;
			context: nil;
			receiver: anObject;
			failBlock: [ ^ self ];
			evaluate.
						
	anObject writeSlotNamed: aSymbol value: result.
	
]

{ #category : #'private building' }
EasyWebAPIJSONInspector >> variableValuePairsFor: anObject [

	^ (self basicVariableValuePairsFor: anObject) asOrderedCollection 
		addFirst: 'self' -> anObject; 
		yourself
]

{ #category : #'private building' }
EasyWebAPIJSONInspector >> variablesIn: composite [
	^ composite table
		showOnly: 50;
		shouldValidate: false;
		allowsRecursiveSearch: false;
		children: [ :assoc | 
			assoc key = 'self'
				ifTrue: [ #() ]
				ifFalse: [ self variableValuePairsFor: assoc value ] ];
		icon: [ :assoc | self iconFor: assoc value ];
		display: [ :anObject | 
			self rebuildCacheFor: anObject.
			self variableValuePairsFor: anObject ];
		column: 'Variable' 
			evaluated: [:assoc | '  ', (GTObjectPrinter new asNonTruncatedTextFrom: assoc key) ];
		column: 'Value' 
			evaluated: [:assoc | GTObjectPrinter new asTruncatedTextFrom: assoc value ]
			modified: [:newValue :assoc :presentation | 
				self updateInstanceVariable: assoc key from: presentation entity basedOn: newValue.
				presentation update ];
		morphicSelectionAct: [:list | list selection value browse ] 
			icon: GLMUIThemeExtraIcons glamorousBrowse 
			on: $b 
			entitled: 'Browse';
		morphicSelectionAct: [:list | list selection value inspect ] 
			icon: GLMUIThemeExtraIcons glamorousInspect 
			on: $i 
			entitled: 'Inspect';
		selectionAct: [:list | 
			((list selection pointersToExcept: { list selection })
									reject: [ :each | each pointsOnlyWeaklyTo: list selection ]) inspect ] 
			on: $t
			entitled: 'Open pointers to';
		dynamicActionsOnSelection: [ :presentation |
			(presentation entity class hasInstVarNamed: presentation rawSelection key)
				ifTrue: [ 
					{
						GLMGenericAction new 
								action: [:list | self systemNavigation browseAllAccessesTo: list rawSelection key from: list entity class ]; 
								title: 'List methods using this variable'.
						GLMGenericAction new 
								action: [:list | self systemNavigation browseAllStoresInto: list rawSelection key from: list entity class ]; 
								title: 'List methods storing into this variable'.		
					}
					]
				ifFalse: [ #() ] ]
]
