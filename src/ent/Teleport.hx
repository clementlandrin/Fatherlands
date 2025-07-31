package ent;

class Teleport extends Entity {

	public var color : Null<Int>;
	var shader : h3d.shader.ColorMult;
	var targetIndex = 0;

	public function new() {
		super();
		interact = true;
		shader = new h3d.shader.ColorMult();
	}

	override function start() {
		super.start();
		color = (inf != null && inf.color != null) ? inf.color : null;
		updateColor();
	}

	override function setObject(obj) {
		super.setObject(obj);
		for ( m in obj.getMaterials() )
			m.mainPass.addShader(shader);
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

	override function onSecondTrigger() {
		targetIndex++;
		updateColor();
	}

	function updateColor() {
		if ( color != null ) {
			shader.color.setColor(color);
		} else {
			var targets = [];
			for ( e in game.entities ) {
				var t = Std.downcast(e, Teleport);
				if ( t == null || t == this )
					continue;
				targets.push(t);
			}
			var target = targets[targetIndex % targets.length];
			shader.color.setColor(target.color);
		}
	}

	function getTargetColor() {
		if ( color != null )
			throw "assert";
		return shader.color.toColor();
	}

	function matches(t : Teleport) {
		if ( color == null && getTargetColor() == t.color )
			return true;
		if ( color != null && t.color == null )
			return true;
		return false;
	}

	function teleport() {
		game.moveTo(room, getPos().add(new h3d.Vector(1,1)));
	}
	
	override function getTooltipText() {
		var text = "Press F to teleport";
		if ( color == null )
			text += " Press E to change color.";
		return text;
	}

	override function update(dt : Float) {
		super.update(dt);

		if ( color != null )
			trace("should be culled");
	}
}