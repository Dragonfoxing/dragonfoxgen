extends Node
class_name roll_par

# MAIN FUNCTION # 

func _parse(_f : formula, _r : RegEx = RegEx.new(), _e : Expression = Expression.new()) -> int:
	# say we're doing something
	print("<INFO> Parsing Formula: " + _f.processed)
	
	# start by digging in to subformulae
	for op in _f.operations:
		if op.type == 3:
			var err = _parse(op.subformula, RegEx.new(), _e)
			if err != OK:
				print("Something has gone wrong.  Returning.")
				return -1
				
			op.processed = op.subformula.result
	
	# then parse any die rolls
	for op in _f.operations:
		if op.type == 2:
			_process_dice(op)
			
	# then recombine formula with processed information
	_f.processed = ""
	
	for op in _f.operations:
		_f.processed += op.processed
	
	# this worked in the current version.
	#assert(not divide_by_zero(_f.processed))
	if divide_by_zero(_f.processed):
		print("Divide by zero error.  Returning.")
		return -1
		
	print("Statement before expression call: " + _f.processed)
	
	var err = _e.parse(_f.processed)
	
	if err != OK:
		print("Something was wrong with the formula.")
		return -1
		
	var res = _e.execute()
	
	if _e.has_execute_failed():
		print("An unknown error occured while executing expression.")
		return -1
		
	_f.result = res as int
	
	print("Expression result: " + str(res))
	
	return OK
	
# HELPER FUNCTIONS #
	
static func divide_by_zero(s : String) -> bool:
	if s.find("/0") >= 0:
		return true
	elif s.find("%0") >= 0:
		return true
	else: return false
	
func _process_dice(op : operation):
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
	
	if num == "0" or num == "":
		num = "1"
	if size == "0" or num == "":
		size = "1"
	
	print("Parsing roll of " + num + "d" + size)
	
	num = int(num)
	size = int(size)
	
	var res : int = 0
	
	for i in num:
		#print(i)
		var _n = rng.randi_range(1,size)
		match _flag:
			0:
				res += _n
			1:
				res = _n
				if _n == size:
					break
			2:
				res = _n
				if _n == 1:
					break
	
	print("Roll: " + str(num) + "d" + str(size) + " = " + str(res))
	
	op.processed = str(res)
