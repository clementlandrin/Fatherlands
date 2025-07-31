package ent;

class Ladder extends Entity {

	public var bottom : h3d.scene.Object;
	public var top : h3d.scene.Object;
	public var bottomOut : h3d.scene.Object;
	public var topOut : h3d.scene.Object;

	public var door(default, null) : Door;

	var bounds : h3d.col.Bounds;
	public function new() {
		super();
		bounds = createUnitBounds();
		if ( room != null )
			room.ladders.push(this);
	}

	override function setObject(obj) {
		super.setObject(obj);

		try {
			bottom = obj.find(o -> o.name.toLowerCase() == "bottom" ? o : null);
		} catch ( e: Dynamic) {}
		if ( bottom != null )
			bottomOut = bottom.find(o -> o.name.toLowerCase() == "out" ? o : null);

		try {
			top = obj.find(o -> o.name.toLowerCase() == "top" ? o : null);
		} catch ( e : Dynamic ) {}
		if ( top != null )
			topOut = top.find(o -> o.name.toLowerCase() == "out" ? o : null);
		
	}

	override function start() {
		super.start();

		if ( bottom == null && top == null )
			throw "ladder without top and without bottom";

		if ( bottom == null || top == null ) {
			var wantedDir = new h3d.Vector(0.0, 0.0, top == null ? 1.0 : -1.0);
			var maxDot = 0.0;
			for ( d in room.doors ) {
				var dir = d.getLeavingDirection();
				var dot = dir.dot(wantedDir);
				if ( dot > maxDot ) {
					door = d;
					maxDot = dot;
				}
			}
		}
	}

	function playerInBounds(obj : h3d.scene.Object) {
		var pos = new h3d.col.Point(game.player.x, game.player.y, game.player.z);
		var localPos = pos.transformed(obj.getAbsPos().getInverse());
		return bounds.contains(localPos);
	}

	override function update(dt : Float) {
		super.update(dt);

		if ( !game.player.isClimbing() ) {
			if ( bottom != null && playerInBounds(bottom) )
				game.player.enterLadder(this, bottom.getAbsPos().getPosition());
			else if ( top != null && playerInBounds(top) )
				game.player.enterLadder(this, top.getAbsPos().getPosition());
		}
	}

	public function tryLeaveTop() {
		if ( top == null || !playerInBounds(top) )
			return;
		game.player.leaveLadder(top.getAbsPos().getPosition(), topOut.getAbsPos().getPosition());
	}

	public function tryLeaveBottom() {
		if ( bottom == null || !playerInBounds(bottom) )
			return;
		game.player.leaveLadder(bottom.getAbsPos().getPosition(), bottomOut.getAbsPos().getPosition());
	}
}