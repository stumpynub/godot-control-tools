extends Control

class_name TweenPanelManager

enum e_mode { 
	single, 
	multiple 
}

@export var mode: e_mode = e_mode.single
var panels: Array[TweenPanel]
func _ready():
	for child in get_children():
		if child is TweenPanel: 
			panels.append(child)
			child.connect("panel_shown", _panel_shown)
			child.connect("panel_hidden", _panel_hidden)
		
func _panel_shown(panel): 
	if mode == e_mode.multiple: return 
	
	for p in panels: 
		if p != panel: 
			p.hide_panel()
	
func _panel_hidden(): 
	pass
