@tool
extends Tree

# Node references
@onready var editor: Control = $"../../../../../"
@onready var main_tree: Tree = %Tree

func _ready():
	# Setup column expanding for each column
	set_column_expand(EventConst.EditorColumn.NAME, true)
	set_column_expand(EventConst.EditorColumn.VARIABLE, false)
	set_column_expand(EventConst.EditorColumn.USERDATA, false)

func reset_self():
	clear()
	create_item()

func cut():
	copy(true)

func copy(is_cut: bool = false):
	# Ensure the main tree has a selection before copyinh
	if main_tree.get_next_selected(null) == null:
		return
	
	# Duplicate selection into copypaste tree
	duplicate_and_move(main_tree, self, true)
	
	# If cutting from the main tree, iterate through and remove selections
	if is_cut:
		# Iterate through each selection
		var selection: TreeItem = main_tree.get_next_selected(null)
		while selection != null:
			var next: TreeItem = main_tree.get_next_selected(selection)
			
			# If the selection has a parent, go to the parent to remove this child
			var parent: TreeItem = selection.get_parent()
			if parent:
				parent.remove_child(selection)
			
			selection = next

func paste():
	duplicate_and_move(self, main_tree, false)
	editor._tree_refresh()

func duplicate_and_move(source: Tree, target: Tree, is_copying: bool):
	# Reset the copy paste tree if copying new data into it
	if is_copying:
		reset_self()
	
	# Get the current selection in the source tree, or the root if nothing is selected
	var source_item: TreeItem = source.get_next_selected(null)
	if not is_copying and source_item == null:
		source_item = source.get_root().get_child(0)
	
	# Create these variables to store the previous item in the iteration
	var last_source_item: TreeItem = null
	var last_item: TreeItem = null
	
	# If pasting, move the "last time" AKA start point to selection
	if not is_copying and target.get_selected():
		last_item = target.get_selected()
	
	# Scan through every source item
	while source_item != null:
		# Check if this item is a child of the previous item
		var is_child_of_previous: bool = false
		if last_source_item:
			for child in last_source_item.get_children():
				if source_item == child:
					is_child_of_previous = true
					break
		
		# Create a new tree item either below or inside the previous
		var item: TreeItem = null
		if is_child_of_previous or last_item == null:
			item = target.create_item(last_item)
		else:
			item = target.create_item(last_item.get_parent())
		
		if not is_copying and not is_child_of_previous:
			item.move_after(last_item)
		
		# Copy all data from source to target
		item.set_text(0, source_item.get_text(0))
		item.set_metadata(0, source_item.get_metadata(0))
		item.set_text(1, source_item.get_text(1))
		item.set_metadata(1, source_item.get_metadata(1))
		item.set_text(2, source_item.get_text(2))
		item.set_metadata(2, source_item.get_metadata(2))
		
		# Copy all meta over
		for meta in source_item.get_meta_list():
			item.set_meta(meta, source_item.get_meta(meta))
		
		# Update the last item to this item
		last_item = item
		last_source_item = source_item
		
		# Get next item either by selection or regular next
		if is_copying:
			source_item = source.get_next_selected(source_item)
		else:
			source_item = source_item.get_next_in_tree()
