local function getReplicationBuffer(speed: number): number

	return speed * 0.100 -- 60ms players shouldn't have any problems, but toleration is up to 100 ms
end
return getReplicationBuffer