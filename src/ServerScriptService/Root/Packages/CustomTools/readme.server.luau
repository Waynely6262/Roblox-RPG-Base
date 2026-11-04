--[[

**README INCOMPLETE**

API for creating tools (controller distributor module will warn if these aren't defined)

For receiving data from the client
	on_msg: (...) -> ()
	
	
This module doesn't use the Tool Instance class. Any instance with the defined TOOL_IDENTIFIER string will be
recognized when parented to ToolControllers

By detecting when players equip tools, this module will run scripts when said tool is equipped. It is
up to the developer to detect tool.Unequipped and properly clean up the local script environment.

Tools will be given the following information: Player, Character, Tool, 


]]