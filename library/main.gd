extends Node

# Store our bot reference.
var bot : DiscordBot

onready var db := bot_db.new()

# Remove this and replace with whatever is required for Heroku/Github secrets.
#var live_token := "OTg3NDgxODkxODU2ODc1NjEw.Gdcp__.b-HQHvt0K1Oa7qm3mjKmQfjHv1sIVnpLYu3QFA"

# build our intent once the scene is loaded
# this ensures all autoloads and consts are loaded by now
onready var _intent : int = intents.build_intent([
	"guild",
	"guild_messages",
	"direct_messages"
])

# OnReady.
func _ready() -> void:
	# check database shit
	db.start()
	
	# set up the bot
	_start_bot()
	
	
func _exit_tree() -> void:
	_set_presence(bot, "offline", "crashing or offline")
	
func _start_bot() -> void:
	# grab bot
	bot = $DiscordBot
	
	# set our token secret
	bot.TOKEN = _get_token()
	
	# set our intents
	bot.INTENTS = _intent
	
	# INTENTS for this bot should be 4609
	# That's guild, guild messages, and direct messages
	#print("Bot intents = " + str(bot.INTENTS))
	# connect our signals.
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
	# connect to the function that will set our status.
	b.connect("bot_ready", self, "_on_bot_ready")
	
	# this is for the bulk of our bot.
	b.connect("message_create", self, "_message_received")
	
### BOT LIFECYCLE ###

func _on_bot_ready(b : DiscordBot) -> void:
	#print("Successfully connected.  Setting presence.")
	_set_presence(b)
	
func _message_received(b : DiscordBot, message : Message, channel : Dictionary) -> void:
	# don't allow responding to bots.
	if message.author.bot:
		return
	
	# grab the raw content
	var raw : String = message.content
	
	# check for the prefix.
	var pre : String = prefixes.get_guild_prefix(message.guild_id)
	
	# if we are in DMs, bypass all of this logic.
	if not message.guild_id == "":
		# Then check if we got pinged.
		if _check_mentioned(b, message):
			# Trim our user ID if necessary.
			raw = raw.trim_prefix("<@"+b.user.id+">")
			raw = raw.trim_prefix(" ")
		else:
			# This is in a server then.  Check if it begins with our prefix.
			if not raw.begins_with(pre):
				return
	
	# trim the prefix, if any.
	# this will trim nothing if there is no prefix.
	raw = raw.trim_prefix(pre)
	
	# send this to the command handler
	command_handler.parse(b, raw, message, channel)

func _check_mentioned(b : DiscordBot, message : Message) -> bool:
	# return early if there are no mentions
	if message.mentions.size() < 0: return false
	# loop through and return early if a mention matches our user id
	else:
		for u in message.mentions:
			if u.id == b.user.id:
				return true
		return false
		
func _set_presence(b : DiscordBot, status : String = "online", activity : String = prefixes.standard_prefix + "help") -> void:
	# set our presence
	# idk why afk is separate from status
	# type = game for almost all integrations
	b.set_presence({
		"status": status,
		"afk": "false",
		"activity": {
			"type": "game",
			# make sure that our standard prefix is used
			# we can't update this presence per server though
			"name": activity
		}
	})
