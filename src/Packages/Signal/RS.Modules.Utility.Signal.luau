--[[
	forked GoodSignal by @stravant w/ typechecking
	https://gist.github.com/stravant/b75a322e0919d60dde8a0316d1f09d2f
]]

-- The currently idle thread to run the next handler on
local freeRunnerThread: thread?

-- Function which acquires the currently idle handler runner thread, runs the
-- function fn on it, and then releases the thread, returning it to being the
-- currently idle one.
-- If there was a currently idle runner thread already, that's okay, that old
-- one will just get thrown and eventually GCed.
local function acquireRunnerThreadAndCallEventHandler(fn, ...)
	local acquiredRunnerThread = freeRunnerThread
	freeRunnerThread = nil
	fn(...)
	-- The handler finished running, this runner thread is free again.
	freeRunnerThread = acquiredRunnerThread
end

-- Coroutine runner that we create coroutines of. The coroutine can be 
-- repeatedly resumed with functions to run followed by the argument to run
-- them with.
local function runEventHandlerInFreeThread()
	-- Note: We cannot use the initial set of arguments passed to
	-- runEventHandlerInFreeThread for a call to the handler, because those
	-- arguments would stay on the stack for the duration of the thread's
	-- existence, temporarily leaking references. Without access to raw bytecode
	-- there's no way for us to clear the "..." references from the stack.
	while true do
		acquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

type callback<T...> = (T...) -> ()
export type Connection<T...> = {
	Disconnect: (self: Connection<T...>) -> (),

	_Connected: boolean,
	_Signal: Signal<T...>,
	_Callback: callback<T...>,
	_Next: Connection<T...> | false,
}
export type Signal<T...> = {
	Connect: (self: Signal<T...>, callback<T...>) -> (Connection<T...>),
	Once: (self: Signal<T...>, callback<T...>) -> (Connection<T...>),
	Wait: (self: Signal<T...>) -> (T...),
	Fire: (self: Signal<T...>, T...) -> (),
	Destroy: (self: Signal<T...>) -> (),

	_HandlerListHead: Connection<T...> | false,	
}

local Connection = {}
Connection.__index = Connection

function Connection.new<T...>(ParentSignal: Signal<T...>, callback: callback<T...>)
	return (setmetatable({
		_Connected = true,
		_Signal = ParentSignal,
		_Callback = callback,
		_Next = false,
	}, Connection):: unknown):: Connection<T...>
end
function Connection.Disconnect<T...>(self: Connection<T...>)
	self._Connected = false


	--[[
		Unhook the node, but DON'T clear it. That way any fire calls that are
		currently sitting on this node will be able to iterate forwards off of
		it, but any subsequent fire calls will not hit it, and it will be GCed
		when no more fire calls are sitting on it.
		
		Removing linked list node
	]]
	--
	if self._Signal._HandlerListHead == self then
		self._Signal._HandlerListHead = self._Next
	else
		local Prev = self._Signal._HandlerListHead
		while Prev and (Prev:: Connection<T...>)._Next ~= self do
			Prev = (Prev:: Connection<T...>)._Next
		end
		if Prev then
			(Prev:: Connection<T...>)._Next = self._Next
		end
	end
end


local Signal = {}
Signal.__index = Signal

function Signal.new<T...>()
	return (setmetatable({
		_HandlerListHead = false,
	}, Signal):: unknown):: Signal<T...>
end
function Signal.Connect<T...>(self: Signal<T...>, callback: callback<T...>)
	local NewConnection = Connection.new(self, callback)
	if self._HandlerListHead then
		NewConnection._Next = self._HandlerListHead
		self._HandlerListHead = NewConnection
	else
		self._HandlerListHead = NewConnection
	end
	return NewConnection
end
function Signal.Fire<T...>(self: Signal<T...>, ...)
	local Conn = self._HandlerListHead
	task.defer(function(...)
		while Conn do
			if Conn._Connected then
				if not freeRunnerThread then
					freeRunnerThread = coroutine.create(runEventHandlerInFreeThread)
					-- Get the freeRunnerThread to the first yield
					coroutine.resume(freeRunnerThread)
				end
				task.spawn(freeRunnerThread, Conn._Callback, ...)
			end
			Conn = Conn._Next
		end
	end, ...)
end
function Signal.Wait<T...>(self: Signal<T...>)
	local waitingCoroutine = coroutine.running()
	local SignalConnection;
	SignalConnection = self:Connect(function(...)
		SignalConnection:Disconnect()
		task.spawn(waitingCoroutine, ...)
	end)
	return coroutine.yield()
end
function Signal.Once<T...>(self: Signal<T...>, callback: callback<T...>)
	local SignalConnection;
	SignalConnection = self:Connect(function(...)
		if SignalConnection._Connected then
			SignalConnection:Disconnect()
		end
		callback(...)
	end)
	return SignalConnection
end
function Signal.Destroy<T...>(self: Signal<T...>)
	self._HandlerListHead = false
end

return Signal