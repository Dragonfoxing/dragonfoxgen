extends Node
class_name tokens

static func generate(raw_content: String) -> Array:
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
