extends Node
class_name roll

const help_text := "`r formula ; description` - roll a formula.  Can include +-*/, dice rolls (ex 2d20), adv/disadv (2d20kh and 2d20kl, respectively), and parenthesis.  Description optional."
const alias_text := "**Aliases:** r, roll"

static func do(b : DiscordBot, message : Message, raw : String = "", channel := {}):
	
	if raw == "" or not raw:
		b.reply(message,"You didn't pass in anything to roll.")
		return
		
	var _out : String = ""
	
	var _f = formula.new()
	
	_f.statement = raw
	
	roll_pre._preprocess_formula(_f)
	roll_pre._process_formula(_f)
	
	var err = roll_par._parse(_f)
	
	match err:
		roll_par.ERROR_DIVMOD_ZERO:
			b.reply(message, "Error: Divide by zero")
			return
		roll_par.ERROR_EXPR_PARSE_FAILED:
			b.reply(message, "Error: Your formula had issues.")
			return
		roll_par.ERROR_EXPR_EXECUTE_FAILED:
			b.reply(message, "Error: Your formula couldn't be executed.")
			return
			
	# Check for desc and format appropriately
	if "desc" in _f and _f.desc != "":
		_out += "Result (" + _f.desc + "): "
	else:
		_out += "Result: "
		
	#_out = _f.processed + " = " + str(_f.result)
	
	_out += format_output(_f)
	
	if len(_out) > 512:
		_out = _out.substr(0,512) + "**....**"
	
	_out += " **= " + str(_f.result) + "**"
	
	#if err == roll_par.ERROR_DICE_TOO_SMALL or err == roll_par.ERROR_DICE_TOO_HIGH or err == roll_par.ERROR_DICE_DUMBNESS:
		
		#_out += " [Dice rolls were sanitized for this formula]"
	
	b.reply(message, _out)

static func format_output(_f : formula) -> String:
	var _out := ""
	
	for op in _f.operations:
		if "output" in op and op.output != "":
			_out += op.output
		else:
			_out += op.processed
	return _out
