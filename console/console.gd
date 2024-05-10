@tool
extends TweenPanel

@export var line_edit: LineEdit = null
@export var console_text: RichTextLabel = null
@export var target_label: Label = null

var target_object: Object = self 
var command_string_array: PackedStringArray
var commands = {}


func _ready():
	super()
	
	target_object = get_tree().root
	
	line_edit.text_submitted.connect(_text_submitted)
	line_edit.text_changed.connect(_text_changed)
	
	panel_shown.connect(_panel_shown)
	
	target_label.text = "target object: " + str(target_object)
	
	add_command("help", "shows all commands", func() : 
		add_line("\n")
		add_line("[b]Commands:[/b]")
		for cmd in commands: 
			add_line("[indent]" + str(cmd) + ": " + commands.get(cmd)["description"] + "[/indent]")
	)
	
	add_command("clear", "clears all console text", func() : 
		console_text.text = ""
	)
	
	add_command("tree:", "sets target object to scene tree", func() : 
		set_target_object(get_tree())
	)
	
	add_command("echo", "prints variables to the console", func() : 
		if !target_object is Node: return 
		var args = parse_args("echo")
		
		if args.size() > 0 and target_object.get(args[0]): 
			add_line(str(target_object.get(args[0])))
	)
	
	add_command("ls", "list target object's children", func() : 
		if !target_object is Node: 
			return  
	
		for child in target_object.get_children(true): 
			add_line("----\\" + "[color=White]" + str(child) + "[/color]")
	)
	
	add_command("cd", "traverse the scene tree", func() : 
		if !target_object is Node: return 
		var args = parse_args("cd")
		
		if args.size() > 0 and target_object.has_node(args[0]): 
			var node: Node = self 
			
			if target_object is Node: 
				node = target_object
				
			set_target_object(node.get_node(args[0]))
	)
	
	add_command("ts", "sets the timescale", func() : 
		var args = parse_args("ts")
		if args.size() > 0: 
			Engine.time_scale = float(args[0])
	)
	
	add_command("del", "deletes node from the given path", func(): 
		if !target_object is Node: return 
		var args = parse_args("del")
		
		if args.size() > 0 and target_object.has_node(args[0]): 
			var obj = target_object.get_node(args[0])
			
			if obj == target_object: 
				target_object = get_tree().root
				
			obj.queue_free()
	)
	
	add_command("rl", "reloads current scene", func(): 
		get_tree().reload_current_scene()
	)
	
	add_command("setv", "sets variable on current object", func() : 
		var args = parse_args("setv")
		
		if args.size() > 1 and target_object.get(args[0]): 
			if target_object.get(args[0]) is float: 
				target_object.set(args[0], float(args[1]))
			if target_object.get(args[0]) is int: 
				target_object.set(args[0], int(args[1]))
			if target_object.get(args[0]) is bool: 
				target_object.set(args[0], bool(args[1]))
	)
	
	
func _panel_shown(panel): 
	line_edit.grab_focus.call_deferred()

func _text_changed(text): 
	if text == "`": 
		line_edit.clear()
	
	command_string_array = text.strip_edges().split(" ")
	
	for s in command_string_array: 
		if s == "": 
			var index = command_string_array.find(s)
			command_string_array.remove_at(index)

func try_completion(): 
	var split = line_edit.text.split(" ")
	
	match split.size(): 
		0: 
			var index = 0 
			if commands.keys().has(line_edit.text): 
				index = commands.keys().find(line_edit.text)
				index += 1
			
			if index >= commands.keys().size(): 
				index = 0
				
			line_edit.text = str(commands.keys()[index])
			
		1: 
			var suffix = split[0]
			var potentials = []
			
			for key in commands.keys(): 
				if key.begins_with(suffix) and !line_edit.text.contains(key): 
					line_edit.text = key
					line_edit.caret_column = line_edit.text.length()
					return 
					
			var index = 0 
			if commands.keys().has(line_edit.text): 
				index = commands.keys().find(line_edit.text)
				index += 1
			
			if index >= commands.keys().size(): 
				index = 0
				
			line_edit.text = str(commands.keys()[index])
			
		2: 
			var index = 0 
			
			if !target_object is Node: return 
			
			if split[1] == "": 
				line_edit.text += "./" + str(target_object.get_child(index).name)
			else: 
				for child in target_object.get_children(): 
					if child.name.begins_with(split[1]) and child.name != split[1]: 
						index = child.get_index()
					elif split[1] == child.name: 
						index = child.get_index() + 1
					
				if index >= target_object.get_children().size(): 
					index = 0 
				split[1] = str(target_object.get_child(index).name)
				
				line_edit.text = " ./".join(split)
			
	line_edit.caret_column = line_edit.text.length()
	
func _input(event):
	super(event)
	
	if event.is_action_pressed("ui_focus_next"): 
		try_completion()

func _text_submitted(text: String): 
	add_line( text)
	
	command_string_array = text.strip_edges().split(" ")
	
	for cmd in commands: 
		if valid_command(cmd): 
			var args = parse_args("cmd")
			commands.get(cmd)["action"].call()
	
	if target_object == null: 
		target_object = get_tree().root
	
	line_edit.clear()
	console_text.get_v_scroll_bar().set_deferred("value", console_text.get_v_scroll_bar().max_value)  
	
func set_target_object(obj: Object): 
	target_object = obj
	target_label.text = "target object: " + str(target_object)

func valid_command(command) -> bool: 
	if command_string_array.size() > 0 and command_string_array[0] == command.to_lower():
		return true 
	return false

func parse_args(flag) -> Array[String]: 
	var args: Array[String] = []
	var index = 0 
	
	for i in command_string_array.size(): 
		if flag == command_string_array[i]: 
			index = i
			
	for x in command_string_array.size(): 
		if x > index:
			if !command_string_array[x].begins_with("-"): 
				args.append(command_string_array[x]) 
	return args

func add_line(txt): 
	console_text.text += "\n" + txt

func _process_flags(): 
	
	if !parse_args("-setn").is_empty(): 
		var args = parse_args("-setn")
		
		var obj = target_object.get(args[0].to_lower())
		if args.size() > 0 and obj and obj is Object: 
			set_target_object(target_object.get(args[0]))
	
	if !parse_args("-call").is_empty(): 
		var args = parse_args("-call")
		var callable = Callable(target_object, args[0])
		args.remove_at(0)
		
		callable.callv(args)

func add_command(cmd, description, callable: Callable, args=[]): 
	commands[cmd] = {
		"description": description, 
		"action": callable.bindv(args)
	}
