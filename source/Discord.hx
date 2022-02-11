package;

import Sys.sleep;
#if desktop
import discord_rpc.DiscordRpc;
#end

using StringTools;

class DiscordClient
{
	public function new()
	{
		#if desktop
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: "885207099322290226",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
			//trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
		#end
	}

	public static function shutdown()
	{
		#if desktop
		DiscordRpc.shutdown();
		#end
	}

	static function onReady()
	{
		#if desktop
		DiscordRpc.presence({
			details: "Getting Trolled",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "Tails Gets Trolled"
		});
		#end
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		#if desktop
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
		#end
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey : String, ?hasStartTimestamp : Bool, ?endTimestamp: Float)
	{
		#if desktop
		var startTimestamp:Float = if(hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'icon',
			largeImageText: "Andromeda Engine",
			smallImageKey : smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp : Std.int(startTimestamp / 1000),
                        endTimestamp : Std.int(endTimestamp / 1000)
		});
		#end

		//trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}
}
