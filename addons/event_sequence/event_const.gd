@tool

## List of constants used by EventNodes and the Event Editor
class_name EventConst

#region EventItem constants

## Different responses an EventItem can return to the EventNode
enum ItemResponseType {
	## Nothing the event node should worry about, continue on to the next item
	OK,
	## Skip this item's children and move on to the next item after it
	SKIP_CHILDREN,
	## Jump to a label. Which label to jump to should be set by the EventItem
	JUMP,
	## Jump to a label and return to this item afterwards.
	JUMP_AND_RETURN,
	## Start a for loop over this item's children a specific number of times
	LOOP_FOR,
	## Start a conditional loop over this item's children, repeating until condition is false
	LOOP_WHILE,
	## End EventNode early, stopping all future EventItems from running
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

const item_key_flag_macro: String = "fm"
const item_key_flag_collapsed: String = "fc"
const item_key_flag_label: String = "fl"

#endregion

#region Editor Constants

# Folders to scan for scripts in the "add tree item" dialog
const ScriptScanFolders: Array[String] = [
	"res://addons/event_sequence/item/general/",
	"res://addons/event_sequence/item/var/",
	"res://addons/event_sequence/item/set/",
	"res://addons/event_sequence/item/method/",
	"res://addons/event_sequence/item/flow/",
	"res://addons/event_sequence/item/wait/",
]

const ScriptMacroFolder: String = "res://addons/event_sequence/macro/"

# Editor add new tree item dialog
enum EditorDialogTab {
	General,
	Variable,
	Set,
	Method,
	Flow,
	Wait,
}

# Editor tree columns
enum EditorColumn {
	NAME,
	VARIABLE,
	USERDATA,
}

const userdata_key_name = "name"
const userdata_key_display = "display_name"
const userdata_key_desc = "desc"

const userdata_key_require = "require"
const userdata_key_default = "default"

const userdata_key_type = "type"
const userdata_key_type_hint = "type_hint"
const userdata_key_type_array = "type_array"

#endregion
