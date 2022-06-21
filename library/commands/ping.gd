extends Node
class_name ping

const help_text = "`ping` - Check the bot's latency"
# this is a defualt command from the tutorial code
# I'm processing it into its own file
static func do(b : DiscordBot, message: Message, channel := {}, args := []):
	# The ping command will send the latency of the bot
	# Example Usage: gd.ping

	var starttime = OS.get_ticks_msec() # Get the current epoch

	# Send a message and wait for the response
	var msg = yield(b.reply(message, "Ping.."), "completed")

	# Get the latency of the bot
	var latency = str(OS.get_ticks_msec() - starttime)

	# Edit the sent message with the latency
	b.edit(msg, "Pong! Latency is " + latency + "ms.")
