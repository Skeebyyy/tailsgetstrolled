package;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxState;
import openfl.events.Event;
import openfl.media.Video;
import openfl.net.NetConnection;
import openfl.net.NetStream;
import vlc.VlcBitmap;
import Controls.Control;
import flixel.util.FlxTimer;
import flixel.FlxSprite;

// THIS IS FOR TESTING
// DONT STEAL MY CODE >:(

class MP4Handler
{
	public static var video:Video;
	public static var netStream:NetStream;
	public static var finishCallback:FlxState;
	public var sprite:FlxSprite;
	
	public function new()
	{

		FlxG.autoPause = false;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}
	}

	public function playMP4(path:String, callback:FlxState, ?outputTo:FlxSprite = null, ?repeat:Bool = false, ?isWindow:Bool = false, ?isFullscreen:Bool = false):Void
	{
		#if html5
		FlxG.autoPause = false;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		finishCallback = callback;

		video = new Video();
		video.x = 0;
		video.y = 0;

		FlxG.addChildBelowMouse(video);

		var nc = new NetConnection();
		nc.connect(null);

		netStream = new NetStream(nc);
		netStream.client = {onMetaData: client_onMetaData};

		nc.addEventListener("netStatus", netConnection_onNetStatus);

		netStream.play(path);
		#else
		finishCallback = callback;

		VlcBitmap = new VlcBitmap();
		VlcBitmap.set_height(FlxG.stage.stageHeight);
		VlcBitmap.set_width(FlxG.stage.stageHeight * (16 / 9));

		VlcBitmap.volume = 1;

		trace("Setting width to " + FlxG.stage.stageHeight * (16 / 9));
		trace("Setting height to " + FlxG.stage.stageHeight);

		VlcBitmap.onVideoReady = onVLCVideoReady;
		VlcBitmap.onComplete = onVLCComplete;
		VlcBitmap.onError = onVLCError;

		FlxG.stage.addEventListener(Event.ENTER_FRAME, update);

		if (repeat)
			vlcBitmap.repeat = -1;
		else
			vlcBitmap.repeat = 0;

		VlcBitmap.inWindow = isWindow;
		VlcBitmap.fullscreen = isFullscreen;

		FlxG.addChildBelowMouse(VlcBitmap);
		VlcBitmap.play(checkFile(path));

		if (outputTo != null)
		{
			// lol this is bad kek
			VlcBitmap.alpha = 0;

			sprite = outputTo;
		}
		#end
	}

	#if desktop
	function checkFile(fileName:String):String
	{
		var pDir = "";
		var appDir = "file:///" + Sys.getCwd() + "/";

		if (fileName.indexOf(":") == -1) // Not a path
			pDir = appDir;
		else if (fileName.indexOf("file://") == -1 || fileName.indexOf("http") == -1) // C:, D: etc? ..missing "file:///" ?
			pDir = "file:///";

		return pDir + fileName;
	}

	/////////////////////////////////////////////////////////////////////////////////////

	function onVLCVideoReady()
	{
		trace("video loaded!");
		if (sprite != null)
			sprite.loadGraphic(VlcBitmap.bitmapData);
	}

	public function onVLCComplete()
	{
		FlxG.autoPause = true;
		FlxG.stage.removeEventListener(Event.ENTER_FRAME, update);
		VlcBitmap.stop();

		// Clean player, just in case! Actually no.

		FlxG.camera.fade(FlxColor.BLACK, 0, false);

		new FlxTimer().start(0.3, function (tmr:FlxTimer)
		{
			if (finishCallback != null)
			{
				LoadingState.loadAndSwitchState(finishCallback);
			}
			VlcBitmap.dispose();

			if (FlxG.game.contains(VlcBitmap))
			{
				FlxG.game.removeChild(VlcBitmap);
			}
		});


	}

	function onVLCError()
	{
		if (finishCallback != null)
		{
			LoadingState.loadAndSwitchState(finishCallback);
		}
	}

	function update(e:Event)
	{
		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
		{
			if (VlcBitmap.isPlaying)
			{
				onVLCComplete();
			}
		}
		VlcBitmap.volume = FlxG.sound.volume + 0.3; // shitty volume fix. then make it louder.
		if (FlxG.sound.volume < 0.1) VlcBitmap.volume = 0;
	}
	#end

	/////////////////////////////////////////////////////////////////////////////////////

	function client_onMetaData(path)
	{
		video.attachNetStream(netStream);

		video.width = FlxG.width;
		video.height = FlxG.height;
	}

	function netConnection_onNetStatus(path)
	{
		if (path.info.code == "NetStream.Play.Complete")
		{
			finishVideo();
		}
	}

	function finishVideo()
	{
		netStream.dispose();

		if (FlxG.game.contains(video))
		{
			FlxG.game.removeChild(video);
		}

		if (finishCallback != null)
		{
			LoadingState.loadAndSwitchState(finishCallback);
		}
		else
			LoadingState.loadAndSwitchState(new MainMenuState());
	}

	// old html5 player
	/*
		var nc:NetConnection = new NetConnection();
		nc.connect(null);
		var ns:NetStream = new NetStream(nc);
		var myVideo:Video = new Video();
		myVideo.width = FlxG.width;
		myVideo.height = FlxG.height;
		myVideo.attachNetStream(ns);
		ns.play(path);
		return myVideo;
		ns.close();
	 */
}
