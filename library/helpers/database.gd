extends Node
class_name bot_db

var gre_db : PostgreSQLClient = PostgreSQLClient.new()
var gre_url : String

var error : int

func start() -> void:
	print("Starting database handler.")
	
	_check_env()
	
func _check_env():
	if OS.has_environment("DATABASE_URL") and OS.has_environment("HEROKU_URL"):
		print("We're on Heroku.  Switching to PostgreSQL.")
		gre_url = OS.get_environment("DATABASE_URL")
		
		_do_setup()
	else:
		print("We're on local data.  Switching to SQLite.")
		
func _do_setup():
	_connect_signals()
	
	error = gre_db.connect_to_host(gre_url)
	
	if error != OK:
		print_debug("We couldn't connect to the postgre database.")
	
func _connect_signals() -> void:
	error = gre_db.connect("authentication_error", self, "_auth_error")
	error = gre_db.connect("connection_established", self, "_connected")
	error = gre_db.connect("connection_closed", self, "_closed")
	
func _setup_postgre_db():
	_setup_postgre_table_prefixes()
	
func _setup_postgre_table_prefixes():
	print("Creating table [prefixes] if it doesn't already exist.")
	var setup := """
	BEGIN;
	CREATE TABLE IF NOT EXISTS prefixes (
		gid varchar(30) PRIMARY KEY NOT NULL,
		prefix varchar(5)
	);
	COMMIT;
	"""
	
	print("Database status: " + str(gre_db.parameter_status))
	
	var info := gre_db.execute(setup)
	

func _connected():
	_setup_postgre_db()
	pass
	
func _auth_error():
	pass
	
func _closed():
	pass
