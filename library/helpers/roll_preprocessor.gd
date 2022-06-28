extends Node
class_name roll_pre

# Any special content we should strip from the pattern early.
const strip_patterns : Array = [
	# This is to strip user pings out of the message.
	"(<@\\d+>)",
	# Same but channel slug.
	"(<#\\d+>)",
	# strip any spoiler bars
	"\\|*",
	# strip any italics
	"[_]*",
	# strip any bold
	"\\**"
]

const operation_types : Dictionary = {
	"-1" : "error",
	"0" : "operator",
	"1" : "integer",
	"2" : "dice roll",
	"3" : "sub-operation"
}

# This lookbehind statement lets us capture only the description at the end
# Descriptions at the beginning will likely be ignored.
const desc_pattern : String = "(\\b\\D+)(?<=[^\\s+\\-@/*%()dkhl<>])"
#const desc_pattern : String = "\\B((?:\\s?\\w+)+)"
# This pattern captures operational statements in order.
# Pare = sub-operation, dice = dice roll, digi = integer, oper = operator
const operation_pattern : String = "(?<pare>\\({1}[\\d+\\-/*%()dkhl]+\\){1})|(?<dice>\\d*d{1}\\d+(?:kh|kl)?)|(?<digi>\\d+)|(?<oper>[+\\-/*])"

### PRIMARY FUNCTIONS ###

# we need a formula.
# if a regex isn't supplied, we'll generate one.
# we are trying to avoid memory overhead by doing this.
static func _preprocess_formula(_f : formula, _r : RegEx = RegEx.new()):
	# debug print: say that we're doing something.
	print("<INFO> Pre-processing formula.")
	
	# set up the processed formula
	_f.processed = _f.statement
	
	# strip slugs and other naughty things
	_clean_raw(_f,_r)
	
	# strip the description off the raw input
	_process_desc(_f, _r)
	
	# strip words, because they can still get through
	_strip_words(_f, _r)
	
	# debug print: show our work
	print("Pattern w/o desc: " + _f.processed)

	# strip whitespaces
	_f.processed = _f.processed.replace(" ", "")
	
	# debug print: Look, no whitespaces ma!
	print("Pattern w/o whitespace: " + _f.processed)

	print("<INFO> Processing formula : " + _f.processed)
	
	#_process_formula(_f,_r)
	# parse the formula
	#_parse(_f, _r)
	
static func _process_formula(_f : formula, _r : RegEx = RegEx.new()):
	# compile new regex
	_r.compile(operation_pattern)
	
	# execute regex
	var res = _r.search_all(_f.processed)
	
	# the index we'll use to work through the operations
	var index : int = 0
	
	# guarantee that the formula has an operation to start with
	_f.operations.append(operation.new())
	
	# start looping
	for r in res:
		var op : operation
		# do we need to add a new operation
		if index+1 > _f.operations.size():
			_f.operations.append(operation.new())
			
		# grab the operation at this index
		op = _f.operations[index]
		
		# get the operation statement
		op.statement = r.get_string()
		
		# TODO: Don't do this here.
		op.processed = op.statement
		
		# get the type by named group
		op.type = get_operation_type(r.get_names())
		
		# show our work
		print("<INFO> Operation: " + op.processed + ", " + operation_types[str(op.type)])
		
		
		# if parens, we want to set up a formula that we can recursively work on.
		if op.type == 3:
			# grab a version of the statement for further processing
			var _s := op.statement
			
			# trim the opening and closing parens
			_s = _s.trim_prefix("(")
			_s = _s.trim_suffix(")")
			
			# prep a new formula
			op.subformula = formula.new()
			op.subformula.statement = _s
			
			# prepopulate "processed" string
			op.subformula.processed = op.subformula.statement
			
			# start preprocessing subformula
			print("<INFO> Processing Subformula")
			_process_formula(op.subformula)
			
			# let them know we finished
			print("<INFO> Finished processing Subformula")
		
		# next index please
		# do we really need to track indices?
		index+=1
		
	#print("Processed Formula: " + print_formula(_f))
	
### REQUIRED HELPER FUNCTIONS ###

# CLEANUP #

static func _clean_raw(_f : formula, _r : RegEx = RegEx.new()):
	# debug print: raw in
	#print("Raw input: " + _f.processed)
	
	# for all bad pataterns, strip from text
	for pattern in strip_patterns:
		# compile pattern
		
		if _r.compile(pattern) != OK:
			print("Regex error: " + pattern)
		
		# get results
		var res = _r.search_all(_f.processed)
		
		# process results
		for r in res:
			_f.processed = _f.processed.replace(r.get_string(), "")
			
	# debug print: userid slug removal
	#print("Slug removed: " + _f.processed)

static func _strip_words(_f : formula, _r : RegEx = RegEx.new()):
	# this catches all words of one or more characters.
	# we can check for exact matches after.
	_r.compile("[^d()\\-+*/%\\s\\d]+")
	
	# execute and get result.
	var res = _r.search_all(_f.processed)
	
	for _r in res:
		var _s = _r.get_string()
		print(_s)
		if len(_s) > 2:
			print("replacing long string")
			
			_f.processed = _f.processed.replace(_s, "")
			
		elif _s.find("kh") <0 and _s.find("kl") <0:
			print("replacing extant string")
			
			_f.processed = _f.processed.replace(_s, "")
			
	print("Words stripped.  New statement: " + _f.processed)
	
# OTHER #

static func _process_desc(_f : formula, _r : RegEx = RegEx.new()):
	var find = _f.processed.find(";")
	if find > -1:
		# we have a delimiter.
		_f.desc = _f.processed.substr(find+1).trim_prefix(" ")
		print(_f.desc)
		_f.processed = _f.processed.substr(0, find)
		print(_f.processed)
	"""
	else:
		
		# compile descriptor pattern
		_r.compile(desc_pattern)
		
		# get result
		var rez = _r.search_all(_f.processed)
		var res
		if rez.size() > 0:
			res = rez[rez.size()-1].get_string()
			
		# if result exists and is not empty, process it
		if res and not res == "":
			# process the string further
			_f.processed = _f.processed.replace(res, "")
			
			#store the descriptor
			_f.desc = res.lstrip(" ")
			
			# print description on its own
			print("Description: " + _f.desc)
	"""
	
static func print_formula(_f : formula) -> String:
	var _s = ""
	
	for op in _f.operations:
		_s += op.processed
		
	return _s
	
static func get_operation_type(_n : Dictionary) -> int:
	var keys = _n.keys()
	if "pare" in keys:
		return 3
	elif "dice" in keys:
		return 2
	elif "digi" in keys:
		return 1
	elif "oper" in keys:
		return 0
	else:
		return -1
