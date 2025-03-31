package;

import funkin.sound.*;
import flixel.system.FlxAssets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import flixel.FlxGame;

#if mobile
import funkin.MobileTouch;
#end

interface IUpdateable {
	public function update(elapsed:Float):Void;
}

// Update shit with a plugin instead of overriding FlxGame update
class FunkGamePlugin extends FlxBasic
{
    public var updateObjects:Array<IUpdateable> = [];

    override function update(elapsed:Float)
    {
        #if mobile
        MobileTouch.touch.update(elapsed);
        #end
        
        #if DEV_TOOLS
        Main.console.update(elapsed);
        #end

        Main.transition.update(elapsed);

        if (FlxG.state.persistentUpdate) if (updateObjects.length > 0) {
            updateObjects.fastForEach((object, i) -> object.update(elapsed));
        }
    }
}

class FlxFunkGame extends FlxGame
{
    public var transition:Transition;
    public var plugin:FunkGamePlugin;

    #if DEV_TOOLS
    public var console:ScriptConsole;
    #end

    #if !mobile
    public var fpsCounter:FPS_Mem;
    #end
    
    public function new(gameWidth:Int = 0, gameHeight:Int = 0, ?initialState:Class<FlxState>, updateFramerate:Int = 60, drawFramerate:Int = 60, skipSplash:Bool = false, startFullscreen:Bool = false)
    {
        super(gameWidth, gameHeight, initialState, updateFramerate, drawFramerate, skipSplash, startFullscreen);
        #if FLX_SOUND_TRAY
        _customSoundTray = FlxFunkSoundTray;
        #end
    }

    override function create(_:openfl.events.Event)
    {
        // Init save data
        SaveData.init();
        Controls.setupBindings();
        Preferences.setupPrefs();

        // Plugins
        FlxG.plugins.addPlugin(FlxFunkSoundGroup.group = new FlxFunkSoundGroup<FlxFunkSound>());
        FlxG.plugins.addPlugin(plugin = new FunkGamePlugin());
        
        super.create(_);

        #if mobile
        addChild(MobileTouch.touch = new MobileTouch());
        #end

        addChild(Main.transition = transition = new Transition());

        #if FLX_SOUND_TRAY
        if (soundTray != null) // Correct layering 
        {
            removeChild(soundTray);
            addChild(soundTray);
        }
        #end

        #if DEV_TOOLS
        addChild(Main.console = console = new ScriptConsole());
        #end

        #if !mobile
        addChild(Main.fpsCounter = fpsCounter = new FPS_Mem(10,10,0xffffff));
        #end

        FlxG.mouse.useSystemCursor = true;
        FlxG.stage.quality = LOW;
        
        Preferences.effectPrefs();
    }
    
    public var enabledSoundTray(default, set):Bool = true;
    inline function set_enabledSoundTray(value:Bool) {
        #if FLX_KEYBOARD
        if (value != enabledSoundTray) {
            if (value) {
                FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
                FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
                FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
            }
            else {
                FlxG.sound.volumeUpKeys = [];
                FlxG.sound.volumeDownKeys = [];
                FlxG.sound.muteKeys = [];
            }
        }
        #end
        return enabledSoundTray = value;
    }
}

#if FLX_SOUND_TRAY
class FlxFunkSoundTray extends flixel.system.ui.FlxSoundTray
{
    var _bar:Bitmap;
    
    public function new() {
        super();
        removeChildren();
        
        final bg = new Bitmap(new BitmapData(80, 25, false, 0xff3f3f3f));
        addChild(bg);

        _bar = new Bitmap(new BitmapData(75, 25, false, 0xffffffff));
        _bar.x = 2.5;
        addChild(_bar);

        final tmp:Bitmap = new Bitmap(openfl.Assets.getBitmapData("assets/images/options/soundtray.png", false), null, true);
        addChild(tmp);
        screenCenter();
        
        tmp.scaleX = 0.5;
        tmp.scaleY = 0.5;
        tmp.x -= tmp.width * 0.2;
        tmp.y -= 5;

        y = -height;
		visible = false;
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed * 4); // hack, sound tray is slow as fuck
    }

    override function show(up:Bool = false) {
        if (!silent) {
            #if desktop
            final sound = FlxAssets.getSound("assets/sounds/volume");
			if (sound != null)
				FlxG.sound.load(sound).play();
            #else
            CoolUtil.playSound("volume");
            #end
		}

		_timer = 4;
		y = 0;
		visible = active = true;
        _bar.scaleX = FlxG.sound.muted ? 0 : FlxG.sound.volume;
    }

    override function screenCenter() {
        _defaultScale = Math.min(FlxG.stage.stageWidth / FlxG.width, FlxG.stage.stageHeight / FlxG.height) * 2;
        super.screenCenter();
    }
}
#end