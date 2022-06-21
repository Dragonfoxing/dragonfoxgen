extends Node
class_name roll

const help_text := "`roll [formula] [desc]` - Rolls the formula including dice rolls.  Has `kh` and `kl` for advantage and disadvantage.  _Warning: Don't use spaces in your formula, the command parser can't handle that (yet?)._"
const alias_text := "Aliases: r, roll"

static func do(b : DiscordBot, message : Message, channel := {}, args := []):
	
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
	Global.regex.compile("(\\d*d\\d*(?:kh|kl)?)")
	var regres = Global.regex.search_all(roll_str)
	if regres.size() > 0:
		Global.rng.randomize()
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
				nums.append(Global.rng.randi_range(1,d))
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
	var err = Global.expression.parse(roll_str)
	if err != OK:
		# reply with an error message here
		b.reply(message, "Your formula has errors.  Here was your formula: " + roll_str)
		return
		
	var res = Global.expression.execute()
	if Global.expression.has_execute_failed():
		# Reply with an error message.
		b.reply(message, "Encountered an internal error.  Please try again.")
		return
		
	if _str.length() > 512:
		_str = _str.substr(0, 512) + " **...** "
	#_str = _str.substr(0, 1000)
		
	desc += _str + " **= " +str(res) + "**"
	# testing - send what we received for desc
	b.reply(message, desc)
