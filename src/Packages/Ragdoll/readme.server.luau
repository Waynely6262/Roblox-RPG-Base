--[[

Name: Ragdoll
Summary: Server-driven character ragdolls.

RS.Remotes.Ragdoll contains RagdollHandler (a client Script) and its RemoteEvent. The RemoteEvent's
RagdollServer script (a server Script) exposes Ragdoll.RagdollCharacter(Character), which tells
the owning player through the RemoteEvent and builds limb constraints from LimbTree.
Both scripts set their RunContext, so they run from ReplicatedStorage without being required.

]]
