@tool
class_name EventConst

const ScriptScanFolders: Array[String] = [
	"res://addons/event_sequence/item/general/",
	"res://addons/event_sequence/item/fetch/",
	"res://addons/event_sequence/item/method/",
	"res://addons/event_sequence/item/flow/",
]

# Editor add new tree item dialog
enum EditorDialogTab {
	General,
	Fetch,
	Method,
	Flow,
}

# Editor tree columns
enum EditorColumn {
	NAME,
	PROPERTY,
}
