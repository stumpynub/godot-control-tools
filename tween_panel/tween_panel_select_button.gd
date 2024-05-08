@tool
extends Button

class_name TweenPanelSelectButton

@export var panel_index = 0
@export var manager: TweenPanelManager = null 

func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if manager != null: 
		panel_index = clamp(panel_index, 0,  manager.panels.size())
		
func _pressed(): 
	if !manager: return
	if manager.panels[panel_index - 1] == null: return 
	
	var panel: TweenPanel = manager.panels[panel_index] 
	
	if panel.is_hidden: 
		panel.show_panel()
	else: 
		panel.hide_panel()
		
	
