package funkin.graphics;

import flixel.FlxBasic;

// Just flixel groups with unsafe gets for performance

typedef Group = TypedGroup<FlxBasic>;

class TypedGroup<T:FlxBasic> extends FlxTypedGroup<T>
{
    @:noCompletion
	override function get_camera():FlxCamera @:privateAccess {
		if (_cameras != null) if (_cameras.length != 0) return _cameras[0];
		return FlxCamera._defaultCameras[0];
	}

	@:noCompletion
    override inline function set_camera(Value:FlxCamera):FlxCamera {
		if (_cameras == null) _cameras = [Value];
		else _cameras[0] = Value;
		return Value;
	}

    @:noCompletion
	override inline function get_cameras():Array<FlxCamera> {
        @:privateAccess
		return (_cameras == null) ? FlxCamera._defaultCameras : _cameras;
	}

	@:noCompletion
	override inline function set_cameras(Value:Array<FlxCamera>):Array<FlxCamera> {
		return _cameras = Value;
	}

	public inline function setNull(object:T) {
		var index:Int = members.indexOf(object);
		if (index != -1) {
			members[index] = null;
		}
	}

	public function insertTop(object:T) {
		var index:Int = members.length;
		while (index > 0) {
			index--;
			if (members[index] == null) {
				members[index] = object;
				return;
			}
		}

		members.push(object);
	}

	public function insertBelow(object:T) {
		var index:Int = 0;
		while (index < members.length) {
			index++;
			if (members[index] == null) {
				members[index] = object;
				return;
			}
		}

		members.insert(0, object);
	}

    override inline function getFirstNull():Int {
        return members.indexOf(null);
    }

	override function forEachAlive(func:T -> Void, recurse:Bool = false) {
		members.fastForEach((basic, i) -> {
			if (basic != null) if (basic.exists) if (basic.alive)
				func(basic);
		});
	}

	override public function draw():Void @:privateAccess
	{
		final oldDefaultCameras = FlxCamera._defaultCameras;
		if (cameras != null)
			FlxCamera._defaultCameras = cameras;

		members.fastForEach((basic, i) -> {
			final basic:FlxBasic = basic;
			if (basic != null) if (basic.exists) if (basic.visible)
				basic.draw();
		});

		FlxCamera._defaultCameras = oldDefaultCameras;
	}

	override public function update(elapsed:Float):Void
	{
		members.fastForEach((basic, i) -> {
			final basic:FlxBasic = basic;
			if (basic != null) if (basic.exists) if (basic.active)
				basic.update(elapsed);
		});
	}
}

typedef SpriteGroup = TypedSpriteGroup<FlxSprite>;

class TypedSpriteGroup<T:FlxSprite> extends FlxTypedSpriteGroup<T>
{
	public function new(x:Float = 0, y:Float = 0, maxSize:Int = 0) {
		super(x, y, maxSize);
		group.destroy();

		group = new TypedGroup<T>(maxSize);
		_sprites = cast group.members;
	}
}

/*class TypedSpriteGroup<T:FlxSprite> extends FlxObject {
	public var group:TypedGroup<T>; // Group containing everything
	override inline function get_camera():FlxCamera return group.camera;
    override inline function set_camera(Value:FlxCamera):FlxCamera return group.camera = Value;
	override inline function get_cameras():Array<FlxCamera> return group.cameras;
	override inline function set_cameras(Value:Array<FlxCamera>):Array<FlxCamera> return group.cameras = Value;

	public var members(get, never):Array<T>;
	inline function get_members():Array<T> return group.members;
	
	inline public function add(basic:T):T return group.add(basic);
	inline public function recycle(?basicClass:Class<T>):T return group.recycle(basicClass);

	public var offset(default, null):FlxPoint;
	public var origin(default, null):FlxPoint;
	var _cos(default, null):Float = 1.0;
	var _sin(default, null):Float = 0.0;

	override function set_angle(value:Float):Float {
		if (angle != value) {
			var rads:Float = value * CoolUtil.TO_RADS;
			_cos = CoolUtil.cos(rads);
			_sin = CoolUtil.sin(rads);
		}
		return angle = value;
	}

	public var alpha:Float = 1.0;
	public var color(default, set):FlxColor = FlxColor.WHITE;

	function set_color(value:FlxColor):FlxColor {
		if (value != color) {
			for (basic in members)
				basic.color = value;
		}
		return color = value;
	}

	override function get_width():Float {
		var w:Float = 0.0;
		for (member in members) {
			if (member == null || !member.alive) continue;
			
			var value = member.x + member.width;
			if (value > w) w = value;
		}
		return w;
	}

	override function get_height():Float {
		var h:Float = 0.0;
		for (member in members) {
			if (member == null || !member.alive) continue;
			
			var value = member.y + member.height;
			if (value > h) h = value;
		}
		return h;
	}

	public function new (X:Float = 0, Y:Float = 0, ?maxSize:Int) {
		super();
		group = new TypedGroup<T>(maxSize);
		offset = FlxPoint.get();
		origin = FlxPoint.get();
	}

	override function destroy() {
		super.destroy();
		group = FlxDestroyUtil.destroy(group);
		offset = FlxDestroyUtil.put(offset);
		origin = FlxDestroyUtil.put(origin);
	}

	override function update(elapsed:Float) {
		group.update(elapsed);
	}

	override function draw() {
		@:privateAccess {
			final oldDefaultCameras = FlxCamera._defaultCameras;
			if (group.cameras != null) FlxCamera._defaultCameras = group.cameras;

			var point = CoolUtil.point;
			point.set(x, y);
			point.subtract(offset.x, offset.y);
	
			for (basic in members) {
				var basicX = basic.x; var basicY = basic.y; var basicAngle = basic.angle; var basicAlpha = basic.alpha;
				CoolUtil.positionWithTrig(basic, basic.x - origin.x, basic.y - origin.y, _cos, _sin);
				
				basic.x += point.x + origin.x;
				basic.y += point.y + origin.y;
				basic.angle += angle;
				basic.alpha *= alpha;

				if (basic != null && basic.exists && basic.visible) {
					basic.draw();
				}

				basic.x = basicX;
				basic.y = basicY;
				basic.angle = basicAngle;
				basic.alpha = basicAlpha;
			}
	
			FlxCamera._defaultCameras = oldDefaultCameras;
		}
	}
}*/

/*
class BaseTypedSpriteGroup<T:FlxSprite> extends TypedGroup<T>
{
	public var x(default, set):Float = 0.0;
	public var y(default, set):Float = 0.0;
	public var offset(default, null):FlxPoint;
	public var scrollFactor(default, null):FlxPoint;

	public inline function setPosition(X:Float = 0, Y:Float = 0) {
		x = X;
		y = Y;
	}

	public inline function screenCenter(axes:FlxAxes = XY) {
		if (axes.x) x = (FlxG.width - width) * .5;
		if (axes.y) y = (FlxG.height - height) * .5;
		return this;
	}

	public var alpha:Float = 1.0;
	public var color(default, set):FlxColor = FlxColor.WHITE;

	function set_color(value:FlxColor):FlxColor {
		if (value != color) {
			for (basic in members)
				basic.color = value;
		}
		return color = value;
	}

	public var angle(default, set):Float = 0.0;
	public var origin(default, null):FlxPoint;
	var _cos(default, null):Float = 1.0;
	var _sin(default, null):Float = 0.0;

	function set_angle(value:Float):Float {
		if (angle != value) {
			var rads:Float = value * CoolUtil.TO_RADS;
			_cos = CoolUtil.cos(rads);
			_sin = CoolUtil.sin(rads);
		}
		return angle = value;
	}

	public var width(get, set):Float;
	public var height(get, set):Float;
	
	function get_width():Float {
		var w:Float = 0.0;
		for (member in members) {
			if (member == null || !member.alive) continue;
			
			var value = member.x + member.width;
			if (value > w) w = value;
		}
		return w;
	}

	function get_height():Float {
		var h:Float = 0.0;
		for (member in members) {
			if (member == null || !member.alive) continue;
			
			var value = member.y + member.height;
			if (value > h) h = value;
		}
		return h;
	}

	public function new(X:Float = 0.0, Y:Float = 0.0, ?maxSize:Int):Void {
		super(maxSize);
		setPosition(X, Y);
		offset = FlxPoint.get();
		origin = FlxPoint.get();
		scrollFactor = new FlxCallbackPoint(function (point:FlxPoint) {
			for (basic in members) {
				basic.scrollFactor.set(point.x, point.y);
			}
		});

		scrollFactor.set(1, 1);
	}

	override function destroy() {
		super.destroy();
		offset = FlxDestroyUtil.put(offset);
		origin = FlxDestroyUtil.put(origin);
		scrollFactor = FlxDestroyUtil.destroy(scrollFactor);
	}

	override function draw():Void {
		@:privateAccess {
			final oldDefaultCameras = FlxCamera._defaultCameras;
			if (cameras != null) FlxCamera._defaultCameras = cameras;

			var point = CoolUtil.point;
			point.set(x, y);
			point.subtract(offset.x, offset.y);
	
			for (basic in members) {
				var basicX = basic.x; var basicY = basic.y; var basicAngle = basic.angle; var basicAlpha = basic.alpha;
				CoolUtil.positionWithTrig(basic, basic.x - origin.x, basic.y - origin.y, _cos, _sin);
				
				basic.x += point.x;
				basic.y += point.y;
				basic.angle += angle;
				basic.alpha *= alpha;

				if (basic != null && basic.exists && basic.visible) {
					basic.draw();
				}

				basic.x = basicX;
				basic.y = basicY;
				basic.angle = basicAngle;
				basic.alpha = basicAlpha;
			}
	
			FlxCamera._defaultCameras = oldDefaultCameras;
		}
	}
}*/