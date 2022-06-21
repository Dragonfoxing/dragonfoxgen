extends Node

func _ready() -> void:
	if OS.has_environment("DATABASE_URL"):
		print("We're on Heroku.  Switching to PostgreSQL.")
	else:
		print("We're on local data.  Switching to SQLite.")
