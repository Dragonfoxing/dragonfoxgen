extends Node
class_name command_handler

const commands := {
	"roll": roll,
	#"prefix": prefix,
	"ping": ping,
	"help": help
}

static func parse(b : DiscordBot, raw : String, message : Message, channel : Dictionary) -> void:
	
	# Get command.
	# match all characters up to the first whitespace.
	Global.regex.compile("^[^\\s]+")
	#print(raw)
	var cmd = Global.regex.search(raw)
	if cmd and cmd.get_string() != "":
		cmd = cmd.get_string().to_lower()
	else:
		# silently fail.
		#b.reply(message, "You didn't supply a command.")
		return
		
	# strip the command and the leading space from the raw data
	# lstrip stripped all characters in the string so let's fix this.
	raw = raw.trim_prefix(cmd + " ")
	# send to the handler
	handle_command(b, message, raw, channel, cmd)
	
### HANDLER ###

static func handle_command(b : DiscordBot, message: Message, raw : String, channel: Dictionary, cmd : String) -> void:
	match cmd:
		"ping":
			ping.do(b,message)
		#"prefix":
			#prefix.do(b,message,raw,{})
		"r":
			roll.do(b,message,raw,{})
		"roll":
			roll.do(b,message,raw,{})
		"help":
			b.reply(message, print_help())
			#help.d9(b,message,{},[])
		_:
			#b.reply(message, "You didn't supply a valid command.")
			# fail silently
			return

static func print_help() -> String:
	var nl := "\n"
	var text := "**= About =**"
	text += nl + nl + "A really cool dice rolling bot.  Now 20% furrier!"
	text += nl + "DragonfoxGen is made and supported by @dragonfoxing"
	text += nl + "The base for the bot icon is by raroberts19 on DA"
	text += nl + nl + "All commands can be used without prefix by pinging the bot, or in DMs."
	text += nl + nl + "**= Command List =**" + nl
	
	for i in commands:
		var o = commands[i]
		if "help_text" in o:
			text += nl + o.help_text
		if "alias_text" in o:
			text += nl + o.alias_text
		text += nl
	
	return text
