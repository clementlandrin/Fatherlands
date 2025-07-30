package ent;

class Teleport extends Entity {

	var room : Room;
	public var color : Null<Int>;
	public function new() {
		super();
		interact = true;
		room = game.curRoom;
	}

	override function setObject(obj) {
		super.setObject(obj);
		color = (inf != null && inf.color != null) ? inf.color : null;
		if ( color != null ) {
			var s = new h3d.shader.ColorMult();
			s.color.setColor(inf.color);
			for ( m in obj.getMaterials() ) {
				m.mainPass.addShader(s);
			}
		}
	}

	override function update(dt : Float) {
		super.update(dt);
	}

	override function onTrigger() {
		for ( e in game.entities ) {
			var t = Std.downcast(e, Teleport);
			if ( t == null )
				continue;
			if ( matches(t) )
				t.teleport();
		}
	}

	function matches(t : Teleport) {
		if ( t.color == null && color != null )
			return true;
		if ( t.color != null && color == null )
			return true;
		return false;
	}

	function teleport() {
		room.enter();
	}
}