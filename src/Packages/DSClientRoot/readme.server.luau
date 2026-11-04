--[[

Name: DSClientRoot
Summary: The client root. Install this package to run any client code.
Version: 2.0
Author: Waynely (coocoocrazyhead)

The framework never runs client code on its own. Components prefixed with C. / Client. are staged
under ServerScriptService.Root.Client, and this package supplies:

- S.Client: the client root script (RunContext = Client). Once released, it requires every
  top-level ModuleScript in Client.Graphics, Client.Backend and Client, then prints "Client ready".
- S.ClientMover: waits for the Players module (DSPlayers), then moves Root.Client to
  config.destination (ReplicatedStorage). Copies left over from Edit-mode loading are merged
  with the fresh version winning.

Any package that ships C. components should list "DSClientRoot" in its requirements.

]]
