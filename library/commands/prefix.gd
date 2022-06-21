extends Node
class_name prefix

const help_text = "`prefix [pre]` - lets you change the prefix"

static func do(b : DiscordBot, message : Message, channel := {}, args := []) -> void:
	# ensure the user receives feedback
	b.reply(message, "Setting prefix to " + args[0])
	
	#change the guild prefix
	prefixes.add_or_change_prefix(message.guild_id, args[0])
