--[[

Name: Inventory System
Summary: Communication between client and server to create an environment for players to store items in an inventory
Version: 1.0
Author: Waynely (coocoocrazyhead)

## Features

### Equipment (equippable items)
	- Uses a dictionary, but each key is assigned a number
### General Storage
	- Uses a numerical table
	
### Hotbar
	- The hotbar has two copies in graphics, one displayed during gameplay and one during inventory view
	- Uses a numerical table


## Data Store

### Precautions
Since saving inventory data is done by conversion into JSON, inventories that are saved should be kept
small. Saving large amounts of data could cause API failures due to high traffic.

### Saving
Data is converted from luau into JSON and saved to DataStoreService. Since items are presumed to be moved frequently,
converting to JSON is deemed to have a small negative effect on efficiency.

### Loading
Data is received as JSON and interpreted into luau. The code for this can be found in the  


## Scripts

### Graphics: *.ReplicatedStorage.*.Graphics.Inventory
- Handles the graphics for the inventory system. It picks up user input.
- Static references to container types and sizes (Storage 30, Equipment 6, Hotbar 20). Update these if you add a new container.
- Never modifies what the client's inventory table looks like (only handles graphics-related instances)
- Contains some template items. These can be used to help understand what the unmodified script can work with in terms of keywords and required/recommended instances.

### Class Objects: *.ReplicatedStorage.Modules.Inventory
- Contains some other internal classes with the following purposes:
	- Location is a class for objects that stores a container and a slot.
	- Item is a class for objects that the server and client use to handle items.
	- Container is a class for objects that the server and client uses to simulate containers.
	- KeyContainer is a subclass of Container, except it uses key-value tables instead of numerical tables. KeyContainer is used for containers that only allow a certain type of item in a slot.
- The internal class "Catalog" is important for the system to recognize items.
	- There are 2 options for implementation:
		- Use this path to define and access information about all items
		- Redirect the reference: "return require([different catalog module])"
			- If you choose this option, make sure your items maintain required properties/attributes.
	
### Server Side: ServerScriptService.Root.PlayerInventories
- Implements the essential server components for the inventory system.
- Contains call-safe (client should be able to call them at any time) functions that are used to request interactions a user's own inventory. 

### Server Receiving Communication: ServerScriptService.Root.RemoteReceivers.inv
- Directs RemoteEvent signals to PlayerInventories.clientRequests, which contains all actions that the client can ask the server to perform.
- Uses the "RemoteReceivers" event funnel (for more information check **Implementation**)

### Client Side & Client Receiving Communication: [CLIENT_ROOT].RemoteReceivers.inv
- Determines when to update graphics
- Contains user ContextActionService input detection for toggling inventory view
- Disables CoreGui component "Backpack"
- Uses the "RemoteReceivers" event funnel (for more information check **Implementation**)

## Implementation

To add a new item into the game, go to *.Modules.Inventory.Item.Catalog

Ensure that all required scripts have their references updated and
that all methods called are available and supported. 

For Version 1, any dependencies that cannot be accounted for can be found in the
original package development environment.

This system uses the "RemoteReceivers" RemoteEvent funnel which uses a single RemoteEvent,
which uses the first received argument to determine who the message is for.

Run the following in your 'PlayerAdded':
PlayerInventories.loadJSON(player, [Inventory JSON Reference])

For data associated with items that is unique per item (such as "amount"), use the "dynamic" table.
The dynamic table accepts anything that can be converted into JSON.




]]