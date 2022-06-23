extends Reference
class_name operation

export var statement : String
export var output : String
# The position in the parent statement
export var position : int
# we allow this to be a Variant type
# but our coding contract will expect it to be either:
# int (singular result)
# Array (multiple results)
var result
