extends Node

var current_ids = {}

func get_id(key: Variant, max: int = 99):
	if key in current_ids:
		current_ids[key] += 1
	
	if not key in current_ids or current_ids[key] > max:
		current_ids[key] = 0
	
	return current_ids[key]
