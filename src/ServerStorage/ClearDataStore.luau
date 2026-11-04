local DataStoreService = game:GetService("DataStoreService")

local function clearData(storeName)
	local ds = DataStoreService:GetDataStore(storeName)
	local pages = ds:ListKeysAsync()

	while true do
		
		local page = pages:GetCurrentPage()
		for _, v: DataStoreKey in page do
			local key = v.KeyName
			local s,r = pcall(function()
				ds:RemoveAsync(key)
			end)
			print("Remove", key, "success?=",s,"feedback=",r)
		end
		local s,r = pcall(function()
			pages:AdvanceToNextPageAsync()
		end)
		if not s then break end
	end
end

