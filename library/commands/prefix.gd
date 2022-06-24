extends Node
class_name prefix

const help_text = "`prefix [pre]` - lets you change the prefix"

const bad_chars : Array = [
	"~",
	"_",
	"*",
	"`",
	"|",
	"/",
	# new addition - backspace is also an escape char in Discord
	# and I want prefix replacements to be clearly communicated.
	"\\",
	">",
	"<",
	" ",
	":"
]

const reject_chars : Array = [
	"@",
	"#"
]

static func do(b : DiscordBot, message : Message, raw : String = "", channel := {}) -> void:
	# this is being called in DMs and should be ignored
	if message.guild_id == "":
		b.reply(message, "You can't change the global prefix.  Nice try though ;)")
		return
		
	# ensure the user receives feedback
	var tok = tokens.generate(raw)
	
	if not tok or tok.size() < 1 or tok[0] == "":
		b.reply(message, "There's nothing here to change to.")
		return
		
	var pre : String = tok[0]
	print(pre)
	for c in reject_chars:
		if pre.find(c) > -1:
			b.reply(message, "Rejected change, string contains any of the following: `" + str(reject_chars)+"`")
			return
			
	pre = sanitize(pre)
	
	if pre == "":
		b.reply(message, "Rejected change, string contained only the following before sanitization: `" + str(bad_chars) +"`")
		return
	
	b.reply(message, "Setting prefix to " + pre)
	
	#change the guild prefix
	prefixes.add_or_change_prefix(message.guild_id, pre)

static func sanitize(raw : String) -> String:
	for c in bad_chars:
		raw = raw.replace(c, "")
	return raw
