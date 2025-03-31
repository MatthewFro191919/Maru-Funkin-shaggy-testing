package funkin.util.frontend;

using flixel.util.FlxColorTransformUtil;

/*
 	Normal FlxColor doesnt work in Hscript sooooooo yeah
*/
class FlxColorFix {
	public static var TRANSPARENT:FlxColor = 0x00000000;
	public static var WHITE:FlxColor = 0xFFFFFFFF;
	public static var GRAY:FlxColor = 0xFF808080;
	public static var BLACK:FlxColor = 0xFF000000;

	public static var GREEN:FlxColor = 0xFF008000;
	public static var LIME:FlxColor = 0xFF00FF00;
	public static var YELLOW:FlxColor = 0xFFFFFF00;
	public static var ORANGE:FlxColor = 0xFFFFA500;
	public static var RED:FlxColor = 0xFFFF0000;
	public static var PURPLE:FlxColor = 0xFF800080;
	public static var BLUE:FlxColor = 0xFF0000FF;
	public static var BROWN:FlxColor = 0xFF8B4513;
	public static var PINK:FlxColor = 0xFFFFC0CB;
	public static var MAGENTA:FlxColor = 0xFFFF00FF;
	public static var CYAN:FlxColor = 0xFF00FFFF;

	// Taken (stolen) from Psych :3
	inline public static function fromString(color:String):FlxColor {
		var color:String = ~/[\t\n\r]/.split(color).join('').trim();
		if(color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if (colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum ?? WHITE;
	}

    public static function fromRGB(red:Int, green:Int, blue:Int, alpha:Int = 255):FlxColor {
		return FlxColor.fromRGB(red, green, blue, alpha);
	}

	public static function interpolate(color1:Int, color2:Int, factor:Float = 0.5, smooth:Bool = false):FlxColor {
		return FlxColor.interpolate(color1, color2, smooth ? CoolUtil.getLerp(factor) : factor);
	}

	public static function fromInt(value:Int):FlxColor {
		return FlxColor.fromInt(value);
	}

	public var R:Float = 0;
	public var G:Float = 0;
	public var B:Float = 0;
	public var A:Float = 0;

	public function new(R:Float = 255, G:Float = 255, B:Float = 255, A:Float = 255) {
		set(R, G, B, A);
	}

	public static inline function fromFlxColor(c:FlxColor) {
		return new FlxColorFix(c.red, c.green, c.blue, c.alpha);
	}

	public function set(R:Float = 255, G:Float = 255, B:Float = 255, A:Float = 255) {
		this.R = R;
		this.G = G;
		this.B = B;
		this.A = A;
	}

	public inline function colorSprite(sprite:FlxSprite):Void {
		sprite.colorTransform.setMultipliers(
			R * COLOR_DIV,
			G * COLOR_DIV,
			B * COLOR_DIV,
			A * COLOR_DIV
		);
	}
	
	public inline function get():FlxColor {
		return FlxColor.fromRGB(Std.int(R), Std.int(G), Std.int(B), Std.int(A));
	}

	public function lerp(target:FlxColor, factor:Float = 0.5, smooth:Bool = false):FlxColor {
		R = CoolUtil.resolveLerp(R, target.red, factor, smooth);
		G = CoolUtil.resolveLerp(G, target.green, factor, smooth);
		B = CoolUtil.resolveLerp(B, target.blue, factor, smooth);
		return get();
	}

	public static inline var COLOR_DIV:Float = 1 / 255;

	public static inline function toRGBA(color:FlxColor) {
		return [(color >> 16 & 0xFF), (color >> 8 & 0xFF), (color & 0xFF), (color & 0xFF) << 24, ((color & 0xFF) << 24)];
	}
	
	public static inline function toRGBAFloat(color:FlxColor) {
		return [(color >> 16 & 0xFF) * COLOR_DIV, (color >> 8 & 0xFF) * COLOR_DIV, (color & 0xFF) * COLOR_DIV, ((color & 0xFF) << 24) * COLOR_DIV];
	}
}