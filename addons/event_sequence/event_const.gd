@tool
class_name EventConst

#region EventItem constants

# EventItem run response types
enum ItemResponseType {
	OK,
	SKIP_CHILDREN,
	JUMP,
	JUMP_AND_RETURN,
	LOOP_FOR,
	LOOP_WHILE,
	TERMINATE,
}

# EventItem dictionary keys
const item_key_self: String = "s"
const item_key_child: String = "c"

const item_key_name: String = "n"
const item_key_script: String = "src"
const item_key_instance: String = "inst"
const item_key_macro: String = "m"
const item_key_variable: String = "v"
const item_key_userdata: String = "u"
const item_key_userdata_generic: String = "i"

const item_key_flag_macro: String = "f_macro"
const item_key_flag_label: String = "f_label"

#endregion

#region Editor Constants

# Folders to scan for scripts in the "add tree item" dialog
const ScriptScanFolders: Array[String] = [
	"res://addons/event_sequence/item/general/",
	"res://addons/event_sequence/item/var/",
	"res://addons/event_sequence/item/set/",
	"res://addons/event_sequence/item/method/",
	"res://addons/event_sequence/item/flow/",
]

const ScriptMacroFolder: String = "res://addons/event_sequence/macro/"

# Editor add new tree item dialog
enum EditorDialogTab {
	General,
	Variable,
	Set,
	Method,
	Flow,
}

# Editor tree columns
enum EditorColumn {
	NAME,
	VARIABLE,
	USERDATA,
}

#endregion
