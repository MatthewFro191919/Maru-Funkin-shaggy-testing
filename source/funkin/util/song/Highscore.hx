package funkin.util.song;

class Highscore {
	public static var songScores:Map<String, Int>;
	public static var weekUnlocks:Map<String, Bool>;

	public static function saveSongScore(song:String, diff:String, score:Int = 0):Void {
		var daSong:String = formatSave(formatSong(song), diff);
		if (songScores.exists(daSong)) {
			if (songScores.get(daSong) < score) {
				setScore(daSong, score);
				return;
			}
		}
		setScore(daSong, score);
	}

	public static function saveWeekScore(week:String, diff:String, score:Int = 0):Void {
		var daWeek:String = formatSave(formatWeek(week), diff);
		if (songScores.exists(daWeek)) {
			if (songScores.get(daWeek) < score) {
				setScore(daWeek, score);
				return;
			}
		}
		setScore(daWeek, score);
	}

	inline public static function getSongScore(song:String, diff:String):Int {
		var daSong:String = formatSave(formatSong(song), diff);
		if (!songScores.exists(daSong))
			setScore(daSong, 0);
		return songScores.get(daSong);
	}

	inline public static function getWeekScore(week:String, diff:String):Int {
		var daWeek:String = formatSave(formatWeek(week), diff);
		if (!songScores.exists(daWeek))
			setScore(daWeek, 0);
		return songScores.get(daWeek);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSave() BEFORE TOSSING IN SONG VARIABLE
	 */
	inline public static function setScore(song:String, score:Int):Void {
		songScores.set(song,score);
		SaveData.flushData();
	}

	inline public static function load():Void {
		songScores = SaveData.getSave('scores');
		weekUnlocks = SaveData.getSave('weekUnlock');
	}

	inline static function formatSong(song:String):String return 'song-$song';
	inline static function formatWeek(week:String):String return 'week-$week';
	inline static function formatSave(input:String, diff:String):String return '${Song.formatSongFolder(input)}-$diff';

	/**
	 *	STORY MODE WEEK PROGRESSION
	 */
	inline public static function getWeekUnlock(week:String):Bool {
		if (!weekUnlocks.exists(week))
			setWeekUnlock(week, false);
		return weekUnlocks.get(week);
	}
	
	inline public static function setWeekUnlock(week:String, unlocked:Bool = true):Void {
		weekUnlocks.set(week, unlocked);
		SaveData.flushData();
	}

	inline public static function getAccuracyRating(acc:Float):String {
		return acc == 100 ? 'swag' :
			   acc >= 90 ? 	'sick' :
			   acc >= 70 ? 	'good' :
			   acc >= 40 ? 	'bad' :
			   acc >= 25 ? 	'shit' :
			   acc >= 0 ? 	'miss' :
			   '?';
	}

	public static final ratingMap:Map<String, Rating> = [
		"sick" => new Rating(350, 1,    0),
		"good" => new Rating(200, 0.8,  0),
		"bad"  => new Rating(100, 0.5,  0.06),
		"shit" => new Rating(50,  0.25, 0.1)
	];
}

class Rating
{
	public var score:Int;
	public var noteGain:Float;
	public var ghostLoss:Float;

	public function new(score:Int, noteGain:Float, ghostLoss:Float) {
		this.score = score;
		this.noteGain = noteGain;
		this.ghostLoss = ghostLoss;
	}
}