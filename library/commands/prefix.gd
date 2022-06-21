extends Node
class_name prefix

const help_text = "`prefix [pre]` - lets you change the prefix"

static func do(b : DiscordBot, message : Message, raw : String = "", channel := {}) -> void:
	# ensure the user receives feedback
	var tok = tokens.generate(raw)
	b.reply(message, "Setting prefix to " + tok[0])
	
	#change the guild prefix
	prefixes.add_or_change_prefix(message.guild_id, tok[0])
