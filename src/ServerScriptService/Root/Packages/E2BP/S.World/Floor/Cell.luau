local Cell = {}
Cell.__index = Cell


export type Cell = {
	Content: string?,
	x: number,
	y: number,
}

local CellClass = {}
CellClass.Class = Cell

function CellClass.new(x,y, content: string?)
	
	return setmetatable({
		Content = content;
		x = x;
		y = y;
	}, Cell)
end

return CellClass