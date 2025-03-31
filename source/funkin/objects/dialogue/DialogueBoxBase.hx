package funkin.objects.dialogue;

/*
	Helper to create dialogue boxes
	Doesnt contain any graphics stuff, just loads jsons n shit
*/

typedef DialoguePart = {
	var char:Int;
	var ?anim:String;
	var ?bubble:String;
	var text:String;
}

typedef DialogueJson = {
	var lines:Array<DialoguePart>;

	var ?sound:String;
	var ?music:String;

	var ?bf:String;
	var ?dad:String;
	var ?gf:String;
}

class DialogueBoxBase extends Group
{
	public var skipIntro:Bool = false;
	public var dialogueChars:Array<String> = ['senpai-pixel', 'bf-pixel', 'gf-pixel'];
	public var jsonParsed:DialogueJson;

	public var targetDialogue:String = 'coolswag';
	public var curCharData:Int = 0;
	public var curCharName:String = 'senpai-pixel';
	public var curTalkAnim:String = 'talk';
	public var curBubbleType:String = '';

	//	Im too lazy to find better ways
	public var startCallback:()->Void;
	public var skipCallback:()->Void;
	public var nextCallback:()->Void;
	public var endCallback:()->Void;
	public var closeCallback:()->Void;

	public function new():Void {
		super();

		var path = Song.formatSongFolder(PlayState.SONG.song) + '/dialogue.json';
		jsonParsed = Json.parse(CoolUtil.getFileContent(Paths.getPath(path, TEXT, 'songs')));

		final defaultDialogue:DialogueJson = {
			lines: [],
			music: (SkinUtil.curSkin == 'pixel') ? 'skins/pixel/Lunchbox' : 'breakfast',
			bf: 'bf-pixel',
			dad: 'senpai-pixel',
			gf: 'gf-pixel'
		}

		jsonParsed = JsonUtil.checkJson(defaultDialogue, jsonParsed);
		dialogueChars = [jsonParsed.dad,jsonParsed.bf,jsonParsed.gf];
		
		var musicPath = Paths.musicFolder(jsonParsed.music);
		if (Paths.exists(musicPath,  MUSIC)) {
			FlxG.sound.playMusic(Paths.music(jsonParsed.music), 0);
			FlxG.sound.music.fadeIn(1, 0, 0.8);
		}
	}

	public var dialogueOpened:Bool = false;
	public var dialogueStarted:Bool = false;
	public var textFinished:Bool = false;

	override function update(elapsed:Float):Void
	{
		if (dialogueOpened) if (!dialogueStarted) {
			dialogueStarted = true;
			startDialogue();
			if (startCallback != null) startCallback();
			ModdingUtil.addCall('startDialogue');
		}

		if (#if mobile MobileTouch.justPressed() #else getKey('ACCEPT', JUST_PRESSED) #end) if (dialogueStarted) if (!isEnding) {
			if (!textFinished) {
				skipCallback();
				ModdingUtil.addCall('skipDialogueLine', [jsonParsed.lines[0]]);
			}
			else {
				if (jsonParsed.lines[1] == null && jsonParsed.lines[0] != null) {
					endDialogue();
					endCallback();
					ModdingUtil.addCall('endDialogue');
				}
				else {
					jsonParsed.lines.remove(jsonParsed.lines[0]);
					startDialogue();
					nextCallback();
					ModdingUtil.addCall('nextDialogueLine', [jsonParsed.lines[0]]);
				}
			}

		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function endDialogue():Void {
		if (!isEnding) {
			isEnding = true;
			if (FlxG.sound.music != null) {
				FlxG.sound.music.fadeOut(2.2, 0);
			}

			new FlxTimer().start(1.2, (tmr) -> {
				closeCallback();
				destroy();
			});
		}
	}

	function startDialogue():Void {
		targetDialogue = jsonParsed.lines[0].text;
		curCharData = jsonParsed.lines[0].char;
		curCharName = dialogueChars[curCharData];

		curTalkAnim = jsonParsed.lines[0].anim ?? "talk";
		curBubbleType = jsonParsed.lines[0].bubble ?? "normal";
	}
}