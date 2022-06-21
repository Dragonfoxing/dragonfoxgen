extends Node
class_name help

const nl = "\n"
const help_text = "`help` - get information and commands for DragonfoxGen."

static func do(b : DiscordBot, message : Message, channel := {}, args := []):
	#b.reply(message, print_help())
	pass
