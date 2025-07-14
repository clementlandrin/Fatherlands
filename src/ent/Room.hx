package ent;

class Room extends Entity {

    public var doors : Array<Door> = [];
    public var navmeshes : Array<Navmesh> = [];
	public var voxels : Voxels;

	override function set_enabled(v : Bool) {
		super.set_enabled(v);
		for ( d in doors )
			d.enabled = enabled;
		for ( n in navmeshes )
			n.enabled = enabled;
		return enabled;
	}
	
	override function start() {
		super.start();
		if ( name == "start" )
			game.moveTo(this);

	}

	public function enter() {
		if ( voxels != null )
			voxels.dispose();
		voxels = new Voxels(this);
		enabled = true;
		game.curRoom = this;
	}

	public function leave() {
		if ( voxels != null )
			voxels.dispose();
		voxels = null;
		enabled = false;
	}

	public function getDoorFrom(prevRoom : Room) {
		var dir = new h2d.col.Point(x - prevRoom.x, y - prevRoom.y).normalized();
		var maxDot = hxd.Math.NEGATIVE_INFINITY;
		var enteringDoor = null;
		for ( d in doors ) {
			var dot = d.getEnteringDirection().dot(dir);
			if ( dot > maxDot ) {
				maxDot = dot;
				enteringDoor = d;
			}
		}
		return enteringDoor;
	}
}