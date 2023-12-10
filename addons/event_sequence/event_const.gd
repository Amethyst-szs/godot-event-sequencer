@tool
class_name EventConst

# EventItem run response types
enum ItemResponseType {
	OK,
	SKIP_CHILDREN,
	TERMINATE,
}

# EventItem dictionary keys
const item_key_self: String = "self"
const item_key_child: String = "children"

const item_key_name: String = "name"
const item_key_script: String = "script"
const item_key_variable: String = "v"
const item_key_userdata: String = "u"
const item_key_userdata_generic: String = "input"

# Folders to scan for scripts in the "add tree item" dialog
const ScriptScanFolders: Array[String] = [
	"res://addons/event_sequence/item/general/",
	"res://addons/event_sequence/item/fetch/",
	"res://addons/event_sequence/item/method/",
	"res://addons/event_sequence/item/flow/",
]

const ScriptMacroFolder: String = "res://addons/event_sequence/macro/"

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
	VARIABLE,
	USERDATA,
}
