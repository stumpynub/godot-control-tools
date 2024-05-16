extends Button

class_name TweenPanelButton

enum e_button_type { 
	show, 
	hide, 
	toggle
}

@export var button_type: e_button_type = e_button_type.hide
@export var panel: TweenPanel = null 

func _ready():
	if get_parent() is TweenPanel: 
		panel = get_parent()

func _pressed(): 
	if !panel: return
	
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
			
	
