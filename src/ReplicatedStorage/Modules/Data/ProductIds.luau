local id = {}

id.Products = {}

id.Products["Spin1"] 				= 3267517274

id.Gamepasses = {}

id.Gamepasses["FireExt"]			= 1243897864
id.Gamepasses["VIP"]				= 1234685050
id.Gamepasses["DoubleSize"] 		= 1165574983
id.Gamepasses["DoubleCash"] 		= 1233829275
id.Gamepasses["DoubleSpeed"] 		= 1234192414
-- correspondence test
--for i, v in id.Gamepasses do local e = game:GetService("MarketplaceService"):GetProductInfo(v, Enum.InfoType.GamePass); print(i .. " == " .. e.Name) end
--for i, v in id.Products do local e = game:GetService("MarketplaceService"):GetProductInfo(v, Enum.InfoType.Product); print(i .. " == " .. e.Name) end

return id