local Types = {
	Hostile = require(script.Hostile);
	Neutral = require(script.Neutral);
	Passive = require(script.Passive);
}


return Types:: {[string]: (mob: any) -> ()} & typeof(Types)