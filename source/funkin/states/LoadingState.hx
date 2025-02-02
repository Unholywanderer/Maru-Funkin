package funkin.states;

class LoadingState extends MusicBeatState
{
    var stageAssets:Array<LoadImage>;
    var charAssets:Array<LoadImage>;
    var songAssets:Array<String>;

    public var onComplete:()->Void;

    public function init(stage:StageJson, characters:Array<String>, song:String)
    {
        var addedAssets:Array<String> = []; // Prevent repeating assets

        stageAssets = Stage.getStageAssets(stage);
        charAssets = [];
        songAssets = [];

        characters.fastForEach((char, i) -> {
            if (char != null) if (!addedAssets.contains(char))
            {
                var json = Character.getCharData(char);
                
                var path:String = json.imagePath;
                if (!path.startsWith('characters/')) path = 'characters/$path';
                var lod:Null<LodLevel> = json.allowLod ? null : HIGH;

                charAssets.push({
                    path: Paths.png(path),
                    lod: lod
                });

                addedAssets.push(char);
            }
        });

        var inst = Paths.instPath(song);
        var voices = Paths.voicesPath(song);

        songAssets.push(inst);
        if (Paths.exists(voices, MUSIC))
            songAssets.push(voices);
    }

    public var onStart:()->Void;

    public function start()
    {
        var start = openfl.Lib.getTimer();

        if (onStart != null)
            onStart();

        AssetManager.loadAsync({
            stageImages: stageAssets,
            charImages: charAssets,
            songSounds: songAssets
        },
        function () {
            trace("finished loading!", (openfl.Lib.getTimer() - start) / 1000);

            if (onComplete != null)
                onComplete();
        });
    }

    var started:Bool = false;

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        if (!started) {
            start();
            started = true;
        }
    }
}