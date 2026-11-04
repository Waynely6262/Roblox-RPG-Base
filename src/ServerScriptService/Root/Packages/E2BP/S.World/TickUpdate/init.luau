local Hole = require(script.Hole)

local spawner_functions = require(script.Parent.SpawnerDrawFunctions)

local function tick_update(floor: any)

	for _, spawner in floor.Spawners do
		if spawner.count >= spawner.max then continue end

		local nextPos, cell = floor:findOpenSpace(1, false, spawner.x0, spawner.y0, spawner.x1, spawner.y1)

		if nextPos then
			-- if nextPos isn't nil then cell isn't nil
			spawner.count += 1
			
			local name = spawner_functions[spawner.f](floor.Number)
			
			if rawget(spawner_functions._mobs, spawner.f) then
				local humanoid = floor.EntityGenManager:newMob(nextPos, name)
				
				cell.Content = "t.e-" .. name
				
				humanoid.died:Once(function()
					spawner.count -= 1
					cell.Content = nil
				end)
			else
				local m, chum = floor.EntityGenManager:newStructure(nextPos, name)

				cell.Content = "t.s-" .. name
				if chum then

					chum.died:Once(function()
						spawner.count -= 1
						cell.Content = nil
					end)
				else
					m.Destroying:Once(function()
						spawner.count -= 1
						cell.Content = nil
					end)
				end
			end

			
		else
			break
		end

	end

	if floor.attributes.isUnderworld and not floor.attributes.hole_active then
		-- Hole generation
		local pos, cell = floor:findOpenSpace(0, false, nil, nil, nil, nil)

		if pos then
			local M = Hole(pos, floor.Number + 1)
			
			
			cell.Content = "t.ds-hole"
			
			floor.attributes.hole_active = true
			M.Destroying:Once(function()
				floor.attributes.hole_active = nil
				cell.Content = nil
			end)
			floor.EntityGenManager:register(M)
		end
	end

end
	
return tick_update