package ent;

class Entity {

	var game : Game;
	var name : String;
	var interactive : h3d.scene.Interactive;

	public var enabled(default, set) : Bool;
	public function set_enabled(v : Bool) {
		enabled = v;
		obj.visible = enabled;
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

	public function setObject(obj : h3d.scene.Object) {
		this.obj = obj;
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

	public function update(dt : Float) {

	}

	public function dispose() {
		obj.remove();
	}
}