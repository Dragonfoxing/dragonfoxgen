extends Node
class_name prefixes

# Guild IDs come in string form
# We will also store the prefix as a string.
# So keys
const guild_prefix = {}
const standard_prefix = "gd."

static func add_or_change_prefix(gid : String, pre : String):
	guild_prefix[gid] = pre
	print("Guild ID " + gid + " changed its prefix to " + pre)

static func get_guild_prefix(gid : String) -> String:
	if guild_prefix.has(gid):
		return guild_prefix[gid]
	else:
		return standard_prefix
