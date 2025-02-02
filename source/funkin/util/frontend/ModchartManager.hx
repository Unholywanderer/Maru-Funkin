package funkin.util.frontend;
import funkin.objects.note.StrumLineGroup;
import funkin.util.frontend.CutsceneManager;

class ModchartManager extends EventHandler {
    private var strumLines:Map<Int, StrumLineGroup> = [];
    
    public function new():Void {
        super();
        strumLines = new Map<Int, StrumLineGroup>();
    }

    override function destroy():Void {
        super.destroy();
        strumLines = null;
    }

    public static function makeManager():ModchartManager {
        return new ModchartManager();
    }

    inline public function setStrumLine(id:Int = 0, strumline:StrumLineGroup):Void {
        strumLines.set(id, strumline);
    }

    inline public function getStrumLine(id:Int = 0):StrumLineGroup {
        return strumLines.get(id);
    }

    inline public function getStrum(strumlineID:Int = 0, strumID:Int = 0):NoteStrum {
        return getStrumLine(strumlineID)?.members[strumID] ?? null;
    }

    inline public function setStrumPos(l:Int = 0, s:Int = 0, ?X:Float, ?Y:Float):Void {
        getStrum(l,s).setPosition(X,Y);
    }

    inline public function tweenStrum(l:Int = 0, s:Int = 0, ?values:Dynamic, time:Float = 1.0, ?settings:Dynamic) {
        return FlxTween.tween(getStrum(l, s), values, time, settings);
    }

    inline public function tweenStrumPos(l:Int = 0, s:Int = 0, X:Float = 0, Y:Float = 0, time:Float = 1.0, ?ease:Dynamic) {
        return tweenStrum(l,s, {x: X, y:Y}, time, {ease: ease ?? FlxEase.linear});
    }

    inline public function setStrumLineSin(l:Int = 0, offPerNote:Float = 0.0, size:Float = 50.0, ?startY:Float) {
        for (i in 0... getStrumLine(l).members.length)
            setStrumSin(l, i, offPerNote * i, size, startY);
    }

    inline public function setStrumLineCos(l:Int = 0, offPerNote:Float = 0.0, size:Float = 50.0, ?startX:Float) {
        for (i in 0... getStrumLine(l).members.length)
            setStrumCos(l, i, offPerNote * i, size, startX);
    }

    // Requires the manager to be added to the state to work

    inline public function setStrumSin(l:Int = 0, s:Int = 0, off:Float = 0.0, size:Float = 50.0, ?startY:Float) {
        final strum = getStrum(l, s);
        sinStrums.remove(strum);

        strum.modchart.startY = startY ?? strum.y;
        strum.modchart.sinOff = off;
        strum.modchart.sinSize = size;
        sinStrums.push(strum);
    }

    inline public function setStrumCos(l:Int = 0, s:Int = 0, off:Float = 0.0, size:Float = 50.0, ?startX:Float) {
        final strum = getStrum(l, s);
        cosStrums.remove(strum);

        strum.modchart.startX = startX ?? strum.x;
        strum.modchart.cosOff = off;
        strum.modchart.cosSize = size;
        cosStrums.push(strum);
    }

    var sinStrums:Array<NoteStrum> = [];
    var cosStrums:Array<NoteStrum> = [];
    
    var timeElapsed:Float = 0.0;
    var speed:Float = 1.0;

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        timeElapsed += elapsed * speed;
        timeElapsed %= CoolUtil.DOUBLE_PI;

        if (sinStrums.length > 0 || cosStrums.length > 0) {
            for (i in sinStrums)
                i.y = (i.modchart.startY) + (CoolUtil.sin(timeElapsed + (i.modchart.sinOff)) * (i.modchart.sinSize));

            for (i in cosStrums)
                i.x = (i.modchart.startX) + (CoolUtil.cos(timeElapsed + (i.modchart.cosOff)) * (i.modchart.cosSize));
        }
    }
}