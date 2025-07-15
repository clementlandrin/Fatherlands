package ent;

class Ladder extends Entity {

	public var bottom : h3d.scene.Object;
	public var top : h3d.scene.Object;
	public var bottomOut : h3d.scene.Object;
	public var topOut : h3d.scene.Object;

	var bounds : h3d.col.Bounds;
	public function new() {
		super();
		bounds = createUnitBounds();
	}

	override function setObject(obj) {
		super.setObject(obj);

		bottom = obj.find(o -> o.name.toLowerCase() == "bottom" ? o : null);
		bottomOut = bottom.find(o -> o.name.toLowerCase() == "out" ? o : null);

		top = obj.find(o -> o.name.toLowerCase() == "top" ? o : null);
		topOut = top.find(o -> o.name.toLowerCase() == "out" ? o : null);
	}

	function playerInBounds(obj : h3d.scene.Object) {
		var pos = new h3d.col.Point(game.player.x, game.player.y, game.player.z);
		var localPos = pos.transformed(obj.getAbsPos().getInverse());
		return bounds.contains(localPos);
	}

	override function update(dt : Float) {
		super.update(dt);

		if ( !game.player.isClimbing() ) {
			if ( playerInBounds(bottom) )
				game.player.enterLadder(this, bottom.getAbsPos().getPosition());
			else if ( playerInBounds(top) )
				game.player.enterLadder(this, top.getAbsPos().getPosition());
		}
	}

	public function tryLeaveTop() {
		if ( !playerInBounds(top) )
			return;
		game.player.leaveLadder(topOut.getAbsPos().getPosition());
	}

	public function tryLeaveBottom() {
		if ( !playerInBounds(bottom) )
			return;
		game.player.leaveLadder(bottomOut.getAbsPos().getPosition());
	}
}