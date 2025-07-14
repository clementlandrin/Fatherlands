package ent;

class Door extends Entity {

	public var to : Room;
	var direction : h2d.col.Point;

	public function new() {
		super();
		game.curRoom.doors.push(this);
	}

	public function getLeavingDirection() {
		return direction.clone();
	}

	public function getEnteringDirection() {
		return direction.scaled(-1.0);
	}
	
	override function setObject(obj) {
		super.setObject(obj);
		obj.culled = true;
        obj.inheritCulled = true;
		interactive = new h3d.scene.Interactive(obj.getBounds(obj), obj);
		interactive.showDebug = true;
		interactive.onClick = onClick;
	}

	override function start() {
		super.start();

		var minDist = hxd.Math.POSITIVE_INFINITY;
		direction = new h2d.col.Point(0.0,-1.0).transformed2x2(obj.getAbsPos().toMatrix2D()).normalized();

		for ( e in game.entities ) {
			var r = Std.downcast(e, Room);
			if ( r == null )
				continue;
			var pos = new h2d.col.Point(r.x, r.y);
			var diff = pos.sub(new h2d.col.Point(x,y));
			var diffNorm = diff.normalized();
			var dot = diffNorm.dot(direction);
			var angle = Math.acos(dot);
			var threshold = 45.0 * Math.PI / 180.0;
			if ( angle > threshold )
				continue;

			var dist = diff.lengthSq();
			if ( dist < minDist ) {
				minDist = dist;
				to = r;
			}
		}
	}

	function enters() {
		if ( to == null || !enabled )
			return;
		game.moveTo(to);
	}

	function onClick(e:hxd.Event) {
		// if( e.button == 0 )
		// 	enters();
	}

	override function update(dt : Float) {
		super.update(dt);
		if ( enabled ) {
			var playerPos = new h3d.col.Point(game.player.x,game.player.y,game.player.z);
			if ( obj.getBounds().contains(playerPos) )
				enters();
		}
	}
}