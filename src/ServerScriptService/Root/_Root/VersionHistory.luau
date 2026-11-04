-- Using MM/DD/YY
return {
	-- Release
		-- Update
			-- Changes
	{
		{
			[[Added support for loading content in Edit, which allows for type-check and auto-complete]];
		};
		{
			[[Moved Client Root to ReplicatedStorage]];
			[[Moved scripts in RS.Modules.Graphics to Client.Graphics]];
			[[Moved scripts in RS.Modules.ClientUtility to Client.Graphics.Util]];
		};
		{
			[[Added version history; 01/07/26]];
			
		};
		{
			[[Added 'Special' library]];
			[[Added special 'requirements' case for specifying a package's dependencies]];
			[[Added special 'readme' case for package description]];
			[[Added special 'config' case for package configuration]];
			[[Migrated config file loading to method library 'Special' in server Root]];
		};
	};
}
