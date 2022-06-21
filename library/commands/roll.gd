extends Node
class_name roll

const help_text := "`roll [formula] [desc]` - Rolls the formula including dice rolls.  Has `kh` and `kl` for advantage and disadvantage.  Single spaces between formula parts are supported."
const alias_text := "Aliases: r, roll"

# \s?(\d*d\d+(?:kh|kl)?)|\s?\d|\s?[+\-\*/%^)(]
const formula_reg := "\\s?(\\d*d\\d+(?:kh|kl)?)|\\s?\\d|\\s?[+\\-\\*/%^)(]"
const formula_reg_2 := "(?<full>(?:\\s?[+\\-/*%\\(\\)])|(\\s?\\d*d{1}\\d+(?:kl|kh)?)|(?:\\s?\\d))"
const short_reg := "(\\d*d\\d*(?:kh|kl)?)"

static func do(b : DiscordBot, message : Message, raw : String = "", channel := {}):
	
	# store the roll string locally
	var roll_str := raw
	
	# set up the final result string
	var _out := ""
	
	# get our formula
	Global.regex.compile(formula_reg_2)
	var regres = Global.regex.search_all(roll_str)
	var formula := ""
	
	# build the formula
	for i in regres:
		formula += i.get_string()
	
	# get the desc (everything after the formula)
	var desc = raw.replace(formula + " ", "") + ": "
		
	# slot hte formula in for now
	_out = formula
	
	# prepare to parse individual d?? rolls
	Global.regex.compile(short_reg)
	
	# get all matches
	regres = Global.regex.search_all(formula)
	
	# if we match, then we start parsing rolls.
	if regres.size() > 0:
		# every time this function starts parsing rolls,
		# we randomize to make sure the RNG is functioning well.
		Global.rng.randomize()
		
		# loop through the matches
		for m in regres:
			# KH = 1, KL = 2, normal = 0
			var _flag = 0
			
			# get the capture string
			var s = m.strings[0]
			
			# get the string as split by the d
			var a = s.split("d")
			
			# number of Times to roll
			var t = int(a[0])
			
			# if there was no preceding number
			# then we roll once
			if t < 1 or not t:
				t=1
				
			# Die type & flag
			var d = a[1]
			
			# catch and pop flag if exists
			if d.find("kh") > -1:
				_flag = 1
				d = int(d.replace("kh",""))
			elif d.find("kl") > -1:
				_flag = 2
				d = int(d.replace("kl",""))
			else: d = int(d)
			
			# set up the number array
			var nums = []
			
			# set up the final total to use in the expression
			var total = 0
			
			# do the dice rolls, cast to int, store in nums[]
			for i in t:
				nums.append(Global.rng.randi_range(1,d))
			
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
				
			# replace items in the formula with appropriate totals
			var p_start = formula.find(s)
			formula.erase(p_start, len(s))
			formula = formula.insert(p_start,str(total))
			
			# end dice roll formatting.
			_s += "`"
			
			# start number formatting
			_s += " ["
			
			for n in range(nums.size()):
				var i = nums[n]
				
				# format bold if nat 1 or nat crit
				if i == d or i == 1:
					_s += "**"+str(i)+"**"
				# else format normal
				else:
					_s += str(i)
				# if we're not at the end, format correctly
				if n < nums.size()-1:
					_s += ", "
			# end number formatting
			_s += "]"
				
			# Replace items in the output as appropriate
			p_start = _out.find(s)
			_out.erase(p_start,len(s))
			_out = _out.insert(p_start,_s)
		
	print(formula)
	
	# phase 2: parse and execute expression
	var err = Global.expression.parse(formula)
	if err != OK:
		# reply with an error message here
		b.reply(message, "Your formula has errors.  Here was your formula: " + formula)
		return
		
	var res = Global.expression.execute()
	if Global.expression.has_execute_failed():
		# Reply with an error message.
		b.reply(message, "Encountered an internal error.  Please try again.")
		return
		
	# prune the length so that we don't websocket error.
	if _out.length() > 512:
		_out = _out.substr(0, 512) + " **...** "

	# prep final output
	_out = desc + _out + " **= " +str(res) + "**"
	
	# output message response
	b.reply(message, _out)
