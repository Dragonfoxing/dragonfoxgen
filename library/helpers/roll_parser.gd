extends Node
class_name roll_par

# MAIN FUNCTION # 

# if you divide or modulo by zero, it's a critical error
# and we will hard return on this.
const ERROR_DIVMOD_ZERO : int = 50

# If the formula parse fails, we hard return.
const ERROR_EXPR_PARSE_FAILED : int = 51

# If the expression execution fails, we hard error.
# IDK if this is necesesary when we are already catching divzero,
# but it's possible that there are other errors to catch.
const ERROR_EXPR_EXECUTE_FAILED : int = 52

# Soft error, we had to bump 0d0 to 1d1 or similar.
const ERROR_DICE_TOO_SMALL : int = 53

# Soft error, we had to cap # dice rolled or dice type rolled.
const ERROR_DICE_TOO_HIGH : int = 54

# Soft error, if you were dumb enough to try 100000d0.
# This is fundamentally equal to both the previous errors together.
const ERROR_DICE_DUMBNESS : int = 55

const MAX_DICE : int = 100
const MAX_DICE_TYPE : int = 100

static func _parse(_f : formula, _r : RegEx = RegEx.new(), _e : Expression = Expression.new()) -> int:
	
	var _err = OK
	var err
	
	# say we're doing something
	print("<INFO> Parsing Formula: " + _f.processed)
	
	# start by digging in to subformulae
	for op in _f.operations:
		if op.type == 3:
			err = _parse(op.subformula, RegEx.new(), _e)
			# hard return only if we hit a hard error.
			if err != OK and err != ERROR_DICE_TOO_SMALL and err != ERROR_DICE_TOO_HIGH and err != ERROR_DICE_DUMBNESS:
				return err
				
			op.processed = op.subformula.result
	
	# then parse any die rolls
	for op in _f.operations:
		if op.type == 2:
			_err = _process_dice(op)
			
	# then recombine formula with processed information
	_f.processed = ""
	
	for op in _f.operations:
		_f.processed += op.processed
	
	# this worked in the current version.
	#assert(not divide_by_zero(_f.processed))
	if divide_by_zero(_f.processed):
		#print("Divide by zero error.  Returning.")
		return ERROR_DIVMOD_ZERO
		
	print("Statement before expression call: " + _f.processed)
	
	err = _e.parse(_f.processed)
	
	if err != OK:
		print("Something was wrong with the formula.")
		return ERROR_EXPR_PARSE_FAILED
		
	var res = _e.execute()
	
	if _e.has_execute_failed():
		print("An unknown error occured while executing expression.")
		return ERROR_EXPR_EXECUTE_FAILED
		
	_f.result = res as int
	
	print("Expression result: " + str(res))
	
	return _err
	
# HELPER FUNCTIONS #
	
static func divide_by_zero(s : String) -> bool:
	if s.find("/0") >= 0:
		return true
	elif s.find("%0") >= 0:
		return true
	else: return false
	
static func _process_dice(op : operation) -> int:
	# set up the error.
	# this function can error silently.
	var err := OK
	
	# set up the RNG
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# get the statement
	var _s = op.processed
	
	# check for KH or KL
	var _flag : int = 0
	
	if _s.find("kh") >= 0:
		_flag = 1
	elif _s.find("kl") >= 0:
		_flag = 2
		
	# split the string by d
	var _arr = _s.split("d")
	
	var num = _arr[0]
	
	var size = _arr[1]
	
	num = int(num)
	size = int(size)
	
	if num == 0:
		num += 1
		err = ERROR_DICE_TOO_SMALL
	elif num > MAX_DICE:
		num = MAX_DICE
		err = ERROR_DICE_TOO_HIGH
		
	if size == 0:
		size += 1
		if err == ERROR_DICE_TOO_HIGH:
			err = ERROR_DICE_DUMBNESS
		else:
			err = ERROR_DICE_TOO_SMALL
	elif size > MAX_DICE_TYPE:
		size = MAX_DICE_TYPE
		if err == ERROR_DICE_TOO_SMALL:
			err = ERROR_DICE_DUMBNESS
		else:
			err = ERROR_DICE_TOO_HIGH
	
	var res : int = 0
	
	if num > 1:
		
		op.output = str(num) + "d" + str(size) + "["
		
		var ind = 0
		var ind_max = 10
		if num < ind_max:
			ind_max = num
			
		for i in num:
			ind += 1
			#print(i)
			var _n = rng.randi_range(1,size)
			match _flag:
				0:
					res += _n
					
					op.output += format_num_array(_n, num, ind, ind_max)
				1:
					res = _n
					
					op.output += format_num_array(_n, num, ind, ind_max)
					if _n == size:
						break
				2:
					res = _n
					
					op.output += format_num_array(_n, num, ind, ind_max)
					if _n == 1:
						break
		op.output += "] (" + str(res) + ")"
	else:
		op.output += str(num) + "d" + str(size)
		
		var _n = rng.randi_range(1, size)
		
		op.output += "(" + str(_n) + ")"
		
		res = _n
	print(op.output)
	#print("Roll: " + str(num) + "d" + str(size) + " = " + str(res))
	
	op.processed = str(res)
	
	# format the human readable text
	
	format_dice_output(op)
	
	return err

static func format_dice_output(op : operation):
	pass
	
static func format_num(i : int, m : int) -> String:
	var out : String = ""
	
	if i == 1 or i == m:
		out = "**"+str(i)+"**"
	else:
		out = str(i)
	return out

# i : integer (the rolled #)
# m : max size (20 in d20)
# ind and ind_max - specific to the roll parser
static func format_num_array(i : int, m : int, ind : int, ind_max : int) -> String:
	var out : String = ""
	
	if ind <= ind_max:
		out += format_num(i,m)
	if ind < ind_max:
		out += ", "
	elif ind == ind_max and ind_max < m:
		out += ".."
	return out
