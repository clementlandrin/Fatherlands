package ent;

class Ladder extends Entity {

	public var bottom : h3d.scene.Object;
	public var top : h3d.scene.Object;
	public var outPos : h3d.scene.Object;

	var bounds : h3d.col.Bounds;
	public function new() {
		super();
		bounds = createUnitBounds();
	}

	override function setObject(obj) {
		super.setObject(obj);

		bottom = obj.find(o -> o.name.toLowerCase() == "bottom" ? o : null);
		top = obj.find(o -> o.name.toLowerCase() == "top" ? o : null);
		outPos = obj.find(o -> o.name.toLowerCase() == "outpos" ? o : null);
	}

	override function update(dt : Float) {
		super.update(dt);

		var pos = new h3d.col.Point(game.player.x, game.player.y, game.player.z);

		function isInBounds(obj : h3d.scene.Object) {
			var localPos = pos.transformed(obj.getAbsPos().getInverse());
			return bounds.contains(localPos);
		}

		if ( !game.player.isClimbing() && isInBounds(bottom) )
			game.player.enterLadder(this);
		
		if ( game.player.isClimbing(this) && isInBounds(top) )
			game.player.leaveLadder();
	}
}