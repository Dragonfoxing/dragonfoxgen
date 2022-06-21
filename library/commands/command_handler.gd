extends Node
class_name command_handler

const commands := {
	"roll": roll,
	"prefix": prefix,
	"ping": ping,
	"help": help
}

static func parse(b : DiscordBot, raw : String, message : Message, channel : Dictionary) -> void:
	# generate varargs
	var tokens = generate_tokens(raw)
	
	# comand is always first argument
	var cmd = tokens[0].to_lower()
	tokens.remove(0)
	
	# send to the handler
	handle_command(b, message, channel, cmd, tokens)
	
static func generate_tokens(raw_content: String) -> Array:
	"""
	This is a helper function which takes a string, and splits it using the space character into an Array
	Eg. "hello hi" -> ["hello", "hi"]
	Eg. "hello      hi" -> ["hello", "hi"]
	"""
	var tokens = []
	var r = RegEx.new()
	r.compile("\\S+") # Negated whitespace character class
	for token in r.search_all(raw_content):
		tokens.append(token.get_string())

	return tokens
	
### HANDLER ###

static func handle_command(b : DiscordBot, message: Message, channel: Dictionary, cmd : String, args : Array) -> void:
	match cmd:
		"ping":
			ping.do(b,message,channel)
		"prefix":
			prefix.do(b,message,{},args)
		"r":
			roll.do(b,message,{},args)
		"roll":
			roll.do(b,message,{},args)
		"help":
			b.reply(message, print_help())
			#help.d9(b,message,{},[])

static func print_help() -> String:
	var nl := "\n"
	var text := "**= About =**"
	text += nl + nl + "A really cool dice rolling bot.  Now 20% furrier!"
	text += nl + "DragonfoxGen is made and supported by @dragonfoxing"
	text += nl + "The base for the bot icon is by raroberts19 on DA"
	text += nl + nl + "**= Command List =**" + nl
	
	for i in commands:
		var o = commands[i]
		if "help_text" in o:
			text += nl + o.help_text
		if "alias_text" in o:
			text += nl + o.alias_text
	
	return text
