extends Node

# Store our bot reference.
var bot : DiscordBot

# Remove this and replace with whatever is required for Heroku/Github secrets.
#var live_token := "OTg3NDgxODkxODU2ODc1NjEw.Gdcp__.b-HQHvt0K1Oa7qm3mjKmQfjHv1sIVnpLYu3QFA"

# build our intent once the scene is loaded
# this ensures all autoloads and consts are loaded by now
onready var _intent : int = intents.build_intent([
	"guild",
	"guild_messages",
	"direct_messages"
])

# necessary componenets



# OnReady.
func _ready() -> void:
	bot = $DiscordBot
	
	bot.TOKEN = _get_token()
	
	bot.INTENTS = _intent
	# INTENTS for this bot should be 4609
	# That's guild, guild messages, and direct messages
	print("Bot intents = " + str(bot.INTENTS))
	_connect_signals(bot)
	
	bot.login()
	
func _get_token() -> String:
	# Try to open file
	var file = File.new()
	var err = file.open("res://secret.token", File.READ)
	# prep token string
	var token := ""
	# try to get the data
	if err == OK:
		token = file.get_as_text()
	# if the data couldn't be read or wasn't available
	# then check for the token in ENV
	if token == null or token == "":
		if OS.has_environment("BOT_TOKEN"):
			token = OS.get_environment("BOT_TOKEN")
		else:
			# scream and shut down
			push_error("Bot TOKEN missing")
	return token

func _connect_signals(b : DiscordBot) -> void:
	b.connect("bot_ready", self, "_on_bot_ready")
	b.connect("message_create", self, "_message_received")
	pass
	
### BOT LIFECYCLE ###

func _on_bot_ready(b : DiscordBot) -> void:
	print("Successfully connected.  Setting presence.")
	_set_presence(b)
	
func _message_received(b : DiscordBot, message : Message, channel : Dictionary) -> void:
	# get the guild prefix
	var g_pre := prefixes.get_guild_prefix(message.guild_id)
	
	# Don't respond to other bots, ideally.
	# Or do and make a meme of it.
	if message.author.bot:
		return
		
	# make sure this is actually a command.
	# also, check against our table of guild specific prefixes.
	if not message.content.begins_with(g_pre):
		return
	
	# pop the prefix off the content
	var raw := message.content.lstrip(g_pre)
	
	# send this to the command handler
	command_handler.parse(b, raw, message, channel)

func _set_presence(b : DiscordBot) -> void:
	b.set_presence({
		"status": "online",
		"afk": "false",
		"activity": {
			"type": "game",
			"name": "%r to roll some dice uwu"
		}
	})
