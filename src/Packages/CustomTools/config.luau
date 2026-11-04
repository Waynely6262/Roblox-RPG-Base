local config = {

DO_PREWELD = true;
SERVER_API_REQS = {
	"_equip";
	"_unequip";	
};
CLIENT_API_REQS = {
	"input_began";
	"input_ended";
	"render_stepped";
	"heartbeat";
};

TYPE_NAME = "CTRLR";


DEFAULT_GROUP_KEYWORD = "main";

PreloadedControllers = {
	["_internal_sprint"] = "_sprint";
}


--
}

config.EXTERIOR_PARENT = {
	[config.DEFAULT_GROUP_KEYWORD] = true;
	Offhand = true;
}

return config