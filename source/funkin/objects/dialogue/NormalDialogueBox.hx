package funkin.objects.dialogue;

// TODO: rewrite dialogue shit
class NormalDialogueBox extends DialogueBoxBase
{
    public var speechBubble:FunkinSprite;
    public var swagDialogue:TypedAlphabet;
    public var blackBG:FlxSpriteExt;

    public var portraitGroup:FlxSpriteGroup;
	public var portraitDad:NormalPortrait;
	public var portraitBf:NormalPortrait;
    public var portraitGf:NormalPortrait;

    public function new():Void {
        super();
        blackBG = new FlxSpriteExt(-100,-100).makeRect(FlxG.width*2, FlxG.height*2, FlxColor.BLACK);
        blackBG.alpha = 0;
        add(blackBG);

        portraitGroup = new FlxSpriteGroup();
		add(portraitGroup);

        portraitDad = new NormalPortrait(dialogueChars[0]);
        portraitDad.flipX = true;
		portraitBf = new NormalPortrait(dialogueChars[1], true);
		portraitGroup.add(portraitDad);
		portraitGroup.add(portraitBf);

        portraitGf = new NormalPortrait(dialogueChars[2]);
        portraitGroup.add(portraitGf);

        portraitGroup.members.fastForEach((member, i) -> member.visible = false);

        speechBubble = new FunkinSprite('speechBubble', [0, FlxG.height*0.5], [0,0]);
        speechBubble.addAnim('open-normal', 'normal-open');
        speechBubble.addAnim('idle-normal', 'normal-idle', 24, true);
        speechBubble.addAnim('open-loud', 'loud-open');
        speechBubble.addAnim('idle-loud', 'loud-idle', 24, true, null, [50,75]);
        speechBubble.playAnim('open-normal');
        speechBubble.screenCenter(X);
        speechBubble.x += 25;
        add(speechBubble);

        swagDialogue = new TypedAlphabet(speechBubble.x + 75, speechBubble.y + 125, "", false, 1220);
        swagDialogue.scale.scale(0.8, 0.8);
        swagDialogue.sounds = ['pixelText'];
        add(swagDialogue);

        skipCallback = () -> swagDialogue.skip();
        endCallback = () -> FlxG.sound.play(Paths.sound('clickText'), 0.8);
        nextCallback = () -> FlxG.sound.play(Paths.sound('clickText'), 0.8);
    }

    override public function update(elapsed:Float):Void {
        textFinished = swagDialogue.text.length == targetDialogue.length;

        if (!isEnding)
            portraitGf.screenCenter(X);

        var curAnim = speechBubble.animation.curAnim;
        if (curAnim != null) if (curAnim.finished) if (curAnim.name.startsWith("open")) {
            FlxTween.tween(blackBG, {alpha: 0.4}, 0.5, {ease: FlxEase.circIn,});
            speechBubble.playAnim('idle-normal');
            dialogueOpened = true;
        }

		super.update(elapsed);
    }

    override public function startDialogue():Void  {
        super.startDialogue();

        speechBubble.playAnim('idle-$curBubbleType');

        swagDialogue.resetText(targetDialogue);
		swagDialogue.start(0.04);

        portraitDad.talking = portraitBf.talking = portraitGf.talking = false;

        switch (curCharData) {
			case 0:
                portraitDad.talkAnim = curTalkAnim;
                portraitDad.talking = portraitDad.visible = speechBubble.flipX = true;
			case 1:
                portraitBf.talkAnim = curTalkAnim;
                portraitBf.talking = portraitBf.visible = true;
                speechBubble.flipX = false;
            case 2:
                portraitGf.talkAnim = curTalkAnim;
                portraitGf.talking = portraitGf.visible = true;
                speechBubble.flipX = false;
		}
    }

    override public function endDialogue():Void  {
        super.endDialogue();
        if (!isEnding) return;

        FlxTween.tween(blackBG, {alpha: 0}, 1, {ease: FlxEase.circIn,});
        FlxTween.tween(speechBubble, {y: speechBubble.y + 1000}, 1, {ease: FlxEase.circIn});
        FlxTween.tween(swagDialogue, {y: swagDialogue.y + 1000}, 1, {ease: FlxEase.circIn});

        FlxTween.tween(portraitDad, {x: portraitDad.x - 1000}, 1, {ease: FlxEase.circIn});
        FlxTween.tween(portraitBf, {x: portraitBf.x + 1000}, 1, {ease: FlxEase.circIn});
        FlxTween.tween(portraitGf, {x: portraitGf.x + 1000}, 1, {ease: FlxEase.circIn});
    }
}

typedef PortraitJson = {
    var offset:Array<Float>;
    var bigScale:Float;
    var smallScale:Float;
} & SpriteJson;

class NormalPortrait extends FlxSpriteExt {
    public var talkAnim:String = 'talk';
    public var talking:Bool = false;
    public var faceJsonData:PortraitJson;

    public function new(path:String, isPlayer:Bool = false):Void {
		super(0, 0);

        scrollFactor.set();
        loadImage('portraits/$path');
        
        var path = 'images/portraits/$path.json';
        faceJsonData = Json.parse(CoolUtil.getFileContent(Paths.getPath(path, TEXT, null)));

        x = -faceJsonData.offset[0];
        y = -faceJsonData.offset[1];

        if (isPlayer)
            x += FlxG.width * 0.7;

        faceJsonData.anims.fastForEach((anim, i) ->
            addAnim(anim.animName, anim.animFile, anim.framerate, anim.loop, anim.indices, anim.offsets)
        );

        setScale(faceJsonData.smallScale, false);
        color = FlxColor.GRAY;
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        var anim:String = 'idle';
        var targetColor:Int = FlxColor.GRAY;
        var targetScale:Float = faceJsonData.smallScale;
        var targetY:Float = -(faceJsonData.offset[1] - (height * faceJsonData.smallScale) / 2);

        if (talking) {
            anim = talkAnim;
            targetColor = FlxColor.WHITE;
            targetScale = faceJsonData.bigScale;
            targetY = -faceJsonData.offset[1];
        }

        playAnim(anim);
        color = FlxColor.interpolate(color, targetColor, CoolUtil.getLerp(0.3));
        final scaleLerp = CoolUtil.coolLerp(scale.x, targetScale, 0.3);
        setScale(scaleLerp, false);
        y = CoolUtil.coolLerp(y, targetY, 0.3);
        updateHitbox();
    }
}