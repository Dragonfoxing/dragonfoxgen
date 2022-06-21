extends Node
class_name intents

# the intent flags are based on values found in:
# https://discord-intents-calculator.vercel.app/

const flags = {
	# Required for any Guild use (so basically always)
	"guild" : 1,
	# guild member requires privileged intent in portal settings
	# you always receive information when:
	# slash commands are used
	# the bot is mentioned
	# the bot is DM'd
	"guild_member" : 2,
	# Only useful for administration bots.
	"guild_bans" : 4,
	"guild_emoji_and_stickers" : 8,
	# This allows bots to see what other bots are around
	# and get information on how to interact with them.
	"guild_integrations" : 16,
	"guild_webhooks" : 32,
	"guild_invites" : 64,
	"guild_voice_states" : 128,
	# presences requires privileged intent in portal settings
	# this is not necessary for setting the bot's own presence
	"guild_presences" : 256,
	"guild_messages" : 512,
	"guild_message_reactions" : 1024,
	"guild_message_typing" : 2048,
	"direct_messages" : 4096,
	"direct_message_reactions" : 8192,
	"direct_message_typing" : 16384,
	# message content requires privileged intent in portal settings
	# message content is always available to bots when:
	# slash command is used
	# mentioned in server
	# accessed in DMs
	"message_content" : 32768,
	"guild_scheduled_events" : 65536
}

static func build_intent(_intents : Array) -> int:
	# initialize the intent integer
	var intent = 0
	
	# for every intent argument, see if an intent exists
	# add it to the intent if it does
	for _i in _intents:
		if flags.has(_i):
			intent += flags[_i]
			
	# return the intent for use with bot.intent
	return intent
