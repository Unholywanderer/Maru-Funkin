package funkin.substates;

class GameOverSubstate extends MusicBeatSubstate {
	static var instance:GameOverSubstate;
	var char:Character;
	var camFollow:FlxObject;

	var skinFolder:String = 'default';
	var deathSound:FlxSound = null;
	var lockedOn:Bool = false;

	public static function cacheSounds() {
		var _skin = PlayState.instance.boyfriend.gameOverSuffix;
		_skin = (_skin != "") ? 'skins/$_skin/' : 'skins/default/';
		Paths.sound(_skin + "fnf_loss_sfx");
		Paths.music(_skin + "gameOverEnd");
		Paths.music(_skin + "gameOver");
	}

	public function new(x:Float, y:Float):Void {
		super();
		instance = this;

		FlxG.camera.bgColor = FlxColor.BLACK;
		if (FlxG.sound.music != null) FlxG.sound.music.stop();
		if (PlayState.instance.startTimer != null) {
			PlayState.instance.startTimer.cancel();
		}

		final charName = PlayState?.instance?.boyfriend?.gameOverChar ?? "bf-dead";
		skinFolder = PlayState.instance.boyfriend.gameOverSuffix;
		skinFolder = (skinFolder != "") ? 'skins/$skinFolder/' : 'skins/default/';

		char = new Character(x, y, charName, true);
		PlayState.instance.boyfriend.stageOffsets.copyTo(char.stageOffsets);
		char.setXY(x,y);
		add(char);
		
		camFollow = new FlxObject(char.getGraphicMidpoint().x - char.camOffsets.x, char.getGraphicMidpoint().y - char.camOffsets.y, 1, 1);
		add(camFollow);

		Conductor.songPosition = 0;
		Conductor.bpm = 100;

		deathSound = CoolUtil.playSound('${skinFolder}fnf_loss_sfx');
		char.playAnim('firstDeath');

		ModdingUtil.addCall('startGameOver');
	}

	function lockCamToChar() {
		PlayState.instance.camGame.follow(camFollow, LOCKON, 0.01);
		lockedOn = true;
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (char.animation.curAnim != null) {
			if (char.animation.curAnim.name == 'firstDeath') {
				if (char.animation.curAnim.curFrame == 12) {
					lockCamToChar();
				}
		
				if (char.animation.curAnim.finished) {
					CoolUtil.playMusic('${skinFolder}gameOver');
					musicBeat.targetSound = FlxG.sound.music;
					gameOverDance();
					ModdingUtil.addCall('musicGameOver');
				}
			}
		}

		if (getKey('ACCEPT', JUST_PRESSED)) {
			restartSong();
		}
 
		if (getKey('BACK', JUST_PRESSED)) {
			if (FlxG.sound.music != null) FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.clearCache = true;
			ModdingUtil.addCall('exitGameOver');
			CoolUtil.switchState((PlayState.isStoryMode) ? new StoryMenuState(): new FreeplayState());
		}

		if (exitTimer > 0) {
			exitTimer -= elapsed;
			if (exitTimer <= 0) {
				PlayState.clearCache = false;
				SkinUtil.setCurSkin('default');
				FlxG.resetState();
			}
		}
	}

	override function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);
		ModdingUtil.addCall('beatHitGameOver', [curBeat]);

		if (!isEnding) {
			gameOverDance();
		}
	}

	function gameOverDance():Void {
		if (char.animOffsets.exists('deathLoopRight') && char.animOffsets.exists('deathLoopLeft')) {
			char.danced = !char.danced;
			char.playAnim((char.danced) ? 'deathLoopRight' : 'deathLoopLeft');
		}
		else if (char.animOffsets.exists('deathLoop')) {
			char.playAnim('deathLoop');
		}
	}

	var isEnding:Bool = false;
	var exitTimer:Float = 0;

	function restartSong():Void {
		if (!isEnding) {
			isEnding = true;
			char.playAnim('deathConfirm', true);
			if (FlxG.sound.music != null) FlxG.sound.music.stop();

			final endSound = new FlxSound().loadEmbedded(Paths.music('${skinFolder}gameOverEnd'));
			endSound.play();
			deathSound.stop();

			if (!lockedOn) lockCamToChar();

			new FlxTimer().start(0.7, function(tmr:FlxTimer) {
				exitTimer = 2;
				PlayState.instance.camGame.fade(FlxColor.BLACK, 2);
			});

			ModdingUtil.addCall('resetGameOver');
		}
	}

	override function destroy() {
		super.destroy();
		if (instance == this)
			instance = null;
	}
}
