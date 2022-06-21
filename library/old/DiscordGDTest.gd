extends Node2D

var bot : DiscordBot

var PREFIX := "%"

onready var expression = Expression.new()
onready var regex = RegEx.new()
onready var rng = RandomNumberGenerator.new()

# this is to use the bot under DragonfoxTest
var test_token := "Nzk1NzUwMjUxMDYyNjI0Mjc2.X_N6LA.9WNePP0nQgXF_zDzwZygshudMfM"

# this is for the actual bot app DragonfoxGen
var live_token := "OTg3NDgxODkxODU2ODc1NjEw.Gdcp__.b-HQHvt0K1Oa7qm3mjKmQfjHv1sIVnpLYu3QFA"

func _ready():
	# guarantees a random seed
	rng.randomize()
	
	# set up the bot
	bot = $DiscordBot
	# by default the INTENTS is 513.  This is INTENT.GUILD and INTENT.GUILD_MESSAGES
	# I put this here for posterity, b/c we should always declare our intents.
	#bot.INTENTS = 513
	# we want DMs as well, so we add INTENT.DIRECT_MESSAGES
	# I used https://discord-intents-calculator.vercel.app/ for this.
	# TODO: Make an intents helper.
	bot.INTENTS = 4609
	bot.connect("bot_ready", self, "_on_bot_ready")
	bot.connect("message_create", self, "_message_received")
	bot.connect("interaction_create", self, "_interaction_received")
	bot.TOKEN = live_token
	bot.login()
	
func _on_bot_ready(b : DiscordBot):
	b.set_presence({
		"status": "online",
		"afk": "false",
		"activity": {
			"type": "game",
			"name": "%r to roll some dice uwu"
		}
	})

func _interaction_received(b : DiscordBot, inter : DiscordInteraction):
	print("Received an interaction.")
	
func _message_received(b : DiscordBot, message : Message, channel : Dictionary):
	# Don't respond to other bots, ideally.
	# Or do and make a meme of it.
	if message.author.bot:
		return
		
	# make sure this is actually a command.
	if not message.content.begins_with(PREFIX):
		return
		
	# pop the prefix off the content
	var raw_content = message.content.lstrip(PREFIX)
	
	var tokens = generate_tokens(raw_content)
	
	var cmd = tokens[0].to_lower()
	
	tokens.remove(0)
	
	var args = tokens
	
	handle_command(b, message, channel, cmd, args)

func generate_tokens(raw_content: String):
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
	
func handle_command(b : DiscordBot, message: Message, channel: Dictionary, cmd : String, args : Array):
	
	#print(message.member)
	match cmd:
		"ping":
			# The ping command will send the latency of the bot
			# Example Usage: gd.ping

			var starttime = OS.get_ticks_msec() # Get the current epoch

			# Send a message and wait for the response
			var msg = yield(b.reply(message, "Ping.."), "completed")

			# Get the latency of the bot
			var latency = str(OS.get_ticks_msec() - starttime)

			# Edit the sent message with the latency
			b.edit(msg, "Pong! Latency is " + latency + "ms.")

		"say":
			# The say command will repeat whatever the user typed

			# We get the arguments joined using a whitespace characters
			print(args)
			var to_say = PoolStringArray(args).join(" ")

			b.reply(message, "You said \"" + to_say + "\"")
		"r":
			parse_roll(bot, message, channel, args)
		"roll":
			parse_roll(bot, message, channel, args)
		"rr":
			b.reply(message, "This command isn't implemented yet, I'm sorry uwu")
		"src":
			b.reply(message, "This command isn't implemented yet, I'm sorry uwu")
		"blp":
			b.reply(message, "Bad luck protection is coming soon.")
		"glp":
			b.reply(message, "Good luck protection is coming soon.")
		"help":
			b.reply(message, "The default prefix for this bot is " + PREFIX + " and the commands you can use are:"
			+ "\n`r or roll: interprets a formula including dice, akin to Avrae and similar bots.`"
			+ "\n> Usage: %r formula description"
			+ "\n\nFeatures coming to this bot include:"
			+ "\n- %rr (reroll) command a la Avrae"
			+ "\n- Good Luck & Bad Luck Protection"
			+ "\n- Prefix Change & Slash Commands"
			+ "\n- Use of alternate RNG algorithms")
			
# INPUT: %r XdYY[+-*/]n1[+-*/]n2.. desc
# OUTPUT: desc: z
# SAMPLE: "perception: 25"

func parse_roll(b : DiscordBot, message : Message, channel : Dictionary, args : Array):
	# The first arg after we pop the command should be the actual roll.
	var roll_str = args[0]
	args.remove(0)
	# set up the final result string
	var _str = str(roll_str)
	# All remaining args are description of the roll.
	var desc := ""
	for i in args:
		desc += str(i)
		# this will cap off the description text.
		if args[args.size()-1] == i:
			desc += ": "
		else: desc += " "
		
	# phase 1: prepare expression
	regex.compile("(\\d*d\\d*(?:kh|kl)?)")
	var regres = regex.search_all(roll_str)
	if regres.size() > 0:
		rng.randomize()
		#print("We caught some fish in the dice pool.")
		# loop through the matches
		for m in regres:
			# KH = 1, KL = 2, normal = 0
			var _flag = 0
			# get the capture string
			var s = m.strings[0]
			#print("Die roll: " +s)
			# get the string as split by the d
			var a = s.split("d")
			# number of Times to roll
			var t = int(a[0])
			if t < 1:
				t+=1
			# Die type & flag
			var d = a[1]
			# catch and pop flag if exists
			if d.find("kh") > -1:
				_flag = 1
				d = int(d.replace("kh",""))
				#print("Rolling with advantage.")
			elif d.find("kl") > -1:
				_flag = 2
				d = int(d.replace("kl",""))
				#print("Rolling with disadvantage.")
			else: d = int(d)
			
			
			# set up the number array
			var nums = []
			# set up the final total to use in the expression
			var total = 0
			
			# do the dice rolls, cast to int, store in nums[]
			for i in t:
				nums.append(rng.randi_range(1,d))
				#rng.randomize()
				#total += nums[i]
			
			# set up the verbose string
			var _s = "`" + str(t) + "d" + str(d)
			
			# check what the total should be
			# reminder: 1 = KH, 2 = KL, 0 = normal
			match _flag:
				0:
					for i in nums:
						total += i
				1:
					for i in nums:
						if total == 0 or total < i:
							total = i
					_s += "KH"
				2:
					for i in nums:
						if total == 0 or total > i:
							total = i
					_s += "KL"
				
			
			# replace string with value
			roll_str = roll_str.replace(s,str(total))
			
			_s += "`" + str(nums)
			#print(_s)
			_str = _str.replace(s,_s)
		
	#print(roll_str)
	# phase 2: parse and execute expression
	var err = expression.parse(roll_str)
	if err != OK:
		# reply with an error message here
		b.reply(message, "Your formula has errors.  Here was your formula: " + roll_str)
		return
		
	var res = expression.execute()
	if expression.has_execute_failed():
		# Reply with an error message.
		b.reply(message, "Encountered an internal error.  Please try again.")
		return
		
	if _str.length() > 512:
		_str = _str.substr(0, 512) + " **...** "
	#_str = _str.substr(0, 1000)
		
	desc += _str + " **= " +str(res) + "**"
	# testing - send what we received for desc
	b.reply(message, desc)
	pass
