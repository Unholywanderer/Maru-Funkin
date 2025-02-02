package funkin.objects;

class RatingGroup extends TypedSpriteGroup<RemoveRating> {
    public var targetSpr:FlxObject = null;
    public var _offset:FlxPoint;

    public function new(?targetSpr:FlxSprite):Void {
        super();
        this.targetSpr = targetSpr;
        _offset = FlxPoint.get();
        if (targetSpr is FlxSprite)
            _offset.set(targetSpr.frameWidth * targetSpr.scale.x, targetSpr.frameHeight * targetSpr.scale.y);
    }

    override function destroy() {
        super.destroy();
        _offset = FlxDestroyUtil.put(_offset);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        if (targetSpr != null) {
            setPosition(targetSpr.x - _offset.x * 0.5, targetSpr.y - _offset.y * 0.5);
        }
    }

    public function drawCombo(combo:Int):Void {
        if (combo < 10) return;

        final isVanilla = Preferences.getPref('vanilla-ui');
        if (!isVanilla) {
            final comboSpr:ComboRating = cast(recycle(ComboRating), ComboRating);
            comboSpr.init();
            addTop(comboSpr);
        }

        final numSplit:Array<String> = Std.string(combo).split('');
        numSplit.reverse();

        numSplit.fastForEach((str, i) -> {
            final num:NumRating = cast(recycle(NumRating), NumRating);
            num.init(str, i);
            addTop(num);
        });
    }

    public function drawJudgement(judgement:String):Void {
        final judgeSpr:JudgeRating = cast(recycle(JudgeRating), JudgeRating);
        judgeSpr.init(judgement);
        addTop(judgeSpr);
    }

    public function drawComplete(judgement:String, combo:Int) {
        drawJudgement(judgement);
        drawCombo(combo);
    }

    function addTop(spr:RemoveRating) {
        add(spr);
        remove(spr, true);
        insert(members.length, spr);
    }
}

class JudgeRating extends RemoveRating {
    public static var judgeRatings:Array<String> = ['shit', 'bad', 'good', 'sick'];
    var animated:Bool = true;
    public function new() {
        super();
        judgeRatings.fastForEach((i, _) -> {
            var oldJudge = Paths.png('skins/${SkinUtil.curSkin}/ratings/$i');
            if (Paths.exists(oldJudge, IMAGE)) {
                animated = false; // Backwards compatibility ???
                break;
            }
        });

        if (animated) {
            var imagePath = 'skins/${SkinUtil.curSkin}/ratings/ratings';
            loadImage(imagePath, false, null, null, lodLevel);

            var length = CoolUtil.returnJudgements.length + 1;
            loadGraphic(graphic, true, Std.int(width / length / lodScale), Std.int(height / lodScale));
            for (i in 0...length)
                animation.add(judgeRatings[i], [i], 1);
        }
    }

    public function init(judgement:String) {
        setPosition();
        animated ? animation.play(judgement, true) : loadImage('skins/${SkinUtil.curSkin}/ratings/$judgement', false, null, null, lodLevel);
        updateHitbox();
        start(Conductor.crochet * 0.001, Conductor.stepCrochet * 0.025);
        jump();
    }
}

class ComboRating extends RemoveRating {
    public function new() {
        super();
        loadImage('skins/${SkinUtil.curSkin}/ratings/combo', false, null, null, lodLevel);
    }

    public function init() {
        setPosition(50, 100);
        updateHitbox();
        start(Conductor.crochet * 0.001 * 2, Conductor.stepCrochet * 0.025);
        jump(0.8);
    }
}

class NumRating extends RemoveRating {
    public var initScale:Float = 1;
    
    public function new() {
        super();
        final path:String = 'skins/${SkinUtil.curSkin}/ratings/nums';
        loadImage(path, false, null, null, lodLevel);
        
        loadGraphic(graphic, true, Std.int(width * 0.1 / lodScale), Std.int(height / lodScale));
        for (i in 0...10)
            animation.add(Std.string(i), [i], 1);
        
        setScale(scale.x);
        initScale = scale.x;
    }

    public function init(num:String, id:Int = 0) {
        setPosition(0, 100);
        animation.play(num, true);
        updateHitbox();
        start(Conductor.crochetMills * 2, Conductor.stepCrochet * 0.025);
        jump(0.8);
        offset.x = width * lodScale * id;
    }
}

class RemoveRating extends FlxSpriteExt
{
    public var lifeTime:Float = 1;
    public var alphaSpeed:Float = 1;
    var lodLevel:Null<LodLevel>;

    public function new() {
        super();
        var skinData = SkinUtil.getSkinData(SkinUtil.curSkin);
        setScale(skinData.scale);
        lodLevel = skinData.allowLod ? null : HIGH;
        antialiasing = skinData.antialiasing ? Preferences.getPref('antialiasing') : false;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (lifeTime > 0) lifeTime -= elapsed; 
        else if (alive) {
            if (alpha > 0)  alpha -= elapsed * alphaSpeed;
            else            kill();
        }
    }

    public function start(lifeTime:Float = 1, alphaSpeed:Float = 1) {
        this.lifeTime = lifeTime;
        this.alphaSpeed = alphaSpeed;
        alpha = 1;
    }

    public function jump(randomness:Float = 1) {
        acceleration.y = FlxG.random.float(200 * randomness, 300 * randomness);
        velocity.y = FlxG.random.float(-140 * randomness, -160 * randomness);
        velocity.x = FlxG.random.float(-5 * randomness, 5 * randomness);
    }
}