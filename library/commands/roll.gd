extends Node
class_name roll

const help_text := "`roll [_f] [desc]` - Rolls the _f including dice rolls.  Has `kh` and `kl` for advantage and disadvantage.  Single spaces between _f parts are supported."
const alias_text := "Aliases: r, roll"

# \s?(\d*d\d+(?:kh|kl)?)|\s?\d|\s?[+\-\*/%^)(]
const _f_reg := "\\s?(\\d*d\\d+(?:kh|kl)?)|\\s?\\d|\\s?[+\\-\\*/%^)(]"
# ((?:\s?[+\-/*%])|(\s?\d*d{1}\d+(?:kl|kh)?)|(?:\s?\d)|(?:\s?[\(\)][\s?\d?]))
# [\s?\d?] doesn't work b/c it interprets ? as the character
const _f_reg_2 := "((?:\\s?[+\\-/*%])|(\\s?\\d*d{1}\\d+(?:kl|kh)?)|(?:\\s?\\d)|(?:\\s?[\\(\\)]\\s?\\d?))"
const short_reg := "(\\d*d\\d*(?:kh|kl)?)"

static func do(b : DiscordBot, message : Message, raw : String = "", channel := {}):
	
	if raw == "" or not raw:
		b.reply(message,"You didn't pass in anything to roll.")
		return
		
	# set up the final result string
	var _out := ""
	
	# get our formula
	Global.regex.compile(_f_reg_2)
	
	var regres = Global.regex.search_all(raw)
	
	if regres.size() < 1:
		b.reply(message,"You didn't pass in anything to roll.")
		return
		
	var frm = formula.new()
	
	# recombine the formula
	for r in regres:
		frm.statement += r.get_string()
		
	# strip all spaces
	frm.statement = frm.statement.replace(" ", "")
	
	# standardize case (for KH, KL)
	frm.statement = frm.statement.to_lower()
	
	# temp varible for not
	var _f : String = frm.statement
	
	# Divide by zero error checking.
	if _f.find("/0") > -1:
		b.reply(message, "Your formula would divide by zero.  Here is your formula: " + frm.statement)
		return
	
	# get the desc (everything after the formula and trailing space)
	var desc = raw.replace(_f + " ", "") + ": "
		
	# slot hte _f in for now
	_out = _f
	
	# prepare to parse individual d?? rolls
	Global.regex.compile(short_reg)
	
	# get all matches
	regres = Global.regex.search_all(_f)
	
	# take all of the special results and stuff them in their own operations.
	if regres.size() > 0:
		for r in regres:
			"""
			var op : operation = operation.new()
			op.statement = r.get_string()
			op.position = r.get_start()
			frm.operations.append(op)
			"""
	"""
	for op in frm.operations:
		op = op as operation
		var flag = 0
		if op.statement.find("kh") > -1:
			flag = 1
		elif op.statement.find("kl") > -1:
			flag = -1
		op.statement = op.statement.lstrip("khl")
		
		var args = op.statement.split("d")
	"""	
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
			var nums : PoolIntArray = []
			
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
				
			# replace items in the _f with appropriate totals
			var p_start = _f.find(s)
			_f.erase(p_start, len(s))
			_f = _f.insert(p_start,str(total))
			
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
		
	print(_f)
	
	# phase 2: parse and execute expression
	var err = Global.expression.parse(_f)
	if err != OK:
		# reply with an error message here
		b.reply(message, "Your formula has errors.  Here was your formula: " + _f)
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
