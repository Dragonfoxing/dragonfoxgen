extends Node
class_name gd_sqlite

const SQLITE := preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")

var db := SQLITE.new()
var db_name : String = "test"
var db_path : String = "res://datastore/" + db_name

func _startup() -> void:
	db.path = db_path
	db.open_db()
	_check_prefixes()
	db.close_db()
	
func _check_prefixes() -> void:
	var query : String = """
	SELECT name FROM sqlite_master WHERE type='table' AND name='prefixes';
	"""
	
	if db.query(query) and db.query_result == []:
		print("No prefixes table exists.")
		var table_pre := {}
		table_pre["gid"] = {
			"data_type" : "char(30)",
			"primary_key" : true
		}
		table_pre["prefix"] = {
			"data_type" : "char(5)"
		}
		
		print(db.create_table("prefixes", table_pre))
	else:
		print("Prefixes available.")
		var selected : Array = db.select_rows("prefixes", "", ["*"])
		
		for pre in selected: 
			#prefixes.guild_prefix[pre.gid] = pre.prefix
			prefixes.add_or_change_prefix(pre.gid, pre.prefix)
			#prefixes.guild_prefix[pre.gid] = pre.prefix
		#print(str(selected))
		
func _save_prefixes() -> void:
	db.open_db()
	for pre in prefixes.guild_prefix:
		if db.update_rows("prefixes", "gid = '" + pre+"'", {"prefix":prefixes.guild_prefix[pre]}):
			pass
		else:
			db.insert_row("prefixes", {"gid" : pre, "prefix" : prefixes.guild_prefix[pre]})
	db.close_db()
