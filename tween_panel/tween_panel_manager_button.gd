extends Button

class_name TweenPanelManagerButton

enum e_button_type { 
	show, 
	hide, 
	toggle
}

@export var button_type: e_button_type = e_button_type.toggle
@export var panel_index = 0
@export var manager: TweenPanelManager = null 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if get_parent() is TweenPanelManager: 
		manager = get_parent()
	
	if manager != null: 
		panel_index = clamp(panel_index, 0,  manager.panels.size())
		
func _pressed(): 
	if !manager: return

	print(manager.panels.size() - 1)
	if panel_index >= manager.panels.size(): return 
	
	var panel: TweenPanel = manager.panels[panel_index] 
	
	match button_type: 
		e_button_type.show: 
			panel.show_panel()
		e_button_type.hide: 
			panel.hide_panel()
		e_button_type.toggle: 
			if panel.is_hidden: 
				panel.show_panel()
			else: 
				panel.hide_panel()
			
	
