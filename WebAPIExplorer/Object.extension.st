Extension { #name : #Object }

{ #category : #'*WebAPIExplorer' }
Object >> gtInspectorForEvalIn: composite [
	"comment stating purpose of message"

	<gtInspectorPresentationOrder: 1000>
	<gtInspectorTag: #eval>
	^ composite custom: EasyWebAPIJSONInspector new
]
