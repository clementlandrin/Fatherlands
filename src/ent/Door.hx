package ent;

class Door extends Entity {

	public var to : Door;
	public var room : Room;
	var direction : h3d.col.Point;

	public function new() {
		super();
		this.room = game.curRoom;
		game.curRoom.doors.push(this);
	}

	override function set_enabled(v : Bool) {
		var res = super.set_enabled(v);
		obj.culled = true;
		return res;
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
	}

	override function start() {
		super.start();

		direction = new h3d.col.Point(0.0,-1.0, 0.0).transformed3x3(obj.getAbsPos()).normalized();

		searchConnection();
	}

	function searchConnection() {

		var curPos = getPos();
		var minDist = hxd.Math.POSITIVE_INFINITY;

		for ( e in game.entities ) {
			var door = Std.downcast(e, Door);
			if ( door == null || door.room == null || door.room == this.room )
				continue;
			var pos = door.getPos();
			var diff = pos.sub(curPos);
			var diffNorm = diff.normalized();
			var dot = diffNorm.dot(direction);
			var angle = Math.acos(dot);
			var threshold = Const.get(DoorMaxAngle) * Math.PI / 180.0;
			if ( angle > threshold || dot < 0.0 )
				continue;

			var dist = diff.lengthSq();
			if ( dist < minDist ) {
				minDist = dist;
				to = door;
			}
		}

		// debugConnection();
	}

	function debugConnection() {
		var pos = getPos();
		var g = new h3d.scene.Graphics(game.s3d);
		g.lineStyle(10.0, 0x0000FF);
		g.drawLine(pos, pos.add(direction));
		if ( to != null ) {
			g.lineStyle(10.0, 0x00FF00);
			g.drawLine(to.getPos(), pos);

			var up = new h3d.Vector(0.0, 0.0, 1.0);
			var dir = to.getPos().sub(pos).normalized();
			var right = up.cross(dir).normalized();
			var leftOffset = right.scaled(-1.0).add(dir.scaled(-1.0)).normalized();
			g.drawLine(to.getPos(), to.getPos().add(leftOffset));
			var rightOffset = right.add(dir.scaled(-1.0)).normalized();
			g.drawLine(to.getPos(), to.getPos().add(rightOffset));
		}
		else {
			g.lineStyle(10.0, 0xFF0000);
			var crossSize = 0.5;
			g.drawLine(pos.add(new h3d.Vector(-crossSize, -crossSize, 0.0)), pos.add(new h3d.Vector(crossSize, crossSize, 0.0)));
			g.drawLine(pos.add(new h3d.Vector(-crossSize, crossSize, 0.0)), pos.add(new h3d.Vector(crossSize, -crossSize, 0.0)));
		}
	}

	function enters() {
		if ( to == null || !enabled )
			return;
		game.moveTo(to);
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