package ent;

class Entity {

	var game : Game;
	var name : String;
	var interactive : h3d.scene.Interactive;

	public var enabled(default, set) : Bool = true;
	public function set_enabled(v : Bool) {
		enabled = v;
		if ( obj != null )
			obj.culled = !v;
		return enabled;
	}

	public var x(default, set) : Float;
	public function set_x(v) {
		return obj.x = x = v;
	}
	public var y(default, set) : Float;
	public function set_y(v) {
		return obj.y = y = v;
	}
	public var z(default, set) : Float;
	public function set_z(v) {
		return obj.z = z = v;
	}

	public var obj : h3d.scene.Object;

	public function new() {
		game = Game.inst;
		game.entities.push(this);
	}

	public function getPos() {
		return new h3d.col.Point(x,y,z);
	}

	public function getPos2D() {
		return getPos().to2D();
	}

	public function setObject(obj : h3d.scene.Object) {
		this.obj = obj;
		obj.inheritCulled = true;
		this.name = obj.name;
		var pos = obj.getAbsPos().getPosition();
		@:bypassAccessor x = pos.x;
		@:bypassAccessor y = pos.y;
		@:bypassAccessor z = pos.z;
	}

	public function start() {
		if ( obj != null ) {
			var newTransform = new h3d.Matrix();
			newTransform.multiply3x4inline(obj.getTransform(), obj.parent.getAbsPos());
			obj.setTransform(newTransform);
			game.s3d.addChild(obj);
		}
	}

	public function createUnitBounds() {
		var boxBounds = new h3d.col.Bounds();
		boxBounds.xMin = -0.5;
		boxBounds.yMin = -0.5;
		boxBounds.zMin = -0.5;
		boxBounds.xSize = 1.0;
		boxBounds.ySize = 1.0;
		boxBounds.zSize = 1.0;
		return boxBounds;
	}

	public function update(dt : Float) {

	}

	public function setMode(mode : Game.TimeMode) {

	}

	public function dispose() {
		obj.remove();
	}
}