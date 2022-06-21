extends Node
# autoload Global.gd

# we do these here, in case multiple commands need access.
# COMPONENTS #
# this is for parsing formula
onready var expression = Expression.new()
# this helps find dice rolls
onready var regex = RegEx.new()
# this generates our dice rolls
onready var rng = RandomNumberGenerator.new()
