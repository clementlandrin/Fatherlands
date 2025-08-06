package ent;

class Teleport extends Entity {

	@:s public var activated : Bool = true;

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
		color = isHub() ? null : inf.color;
		if ( color == null ) {
			for ( e in game.entities ) {
				var t = Std.downcast(e, Teleport);
				if ( t == null || t == this )
					continue;
				if ( t.isHub() )
					throw "duplicate teleport pillar hub. should be unique.";
			}
		}
		if ( inf != null && inf.deactivated )
			activated = false;
		updateColor();
	}

	public function isHub() {
		return inf == null || inf.color == null;
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
			if ( matches(t) ) {
				if ( !t.activated ) {
					var s = new h3d.shader.ColorMult();
					s.color.setColor(0);
					for ( m in obj.getMaterials() )
						m.mainPass.addShader(s);
					game.globalEvent.wait(0.1, function() {
						for ( m in obj.getMaterials() )
							m.mainPass.removeShader(s);
					});
					break;
				}
				var toTp = [];
				for ( e in game.entities ) {
					if ( e.canBeTp() ) {
						var d = e.getPos().to2D().distance(getPos().to2D());
						if ( d < Const.get(PillarRadiusEffect) )
							toTp.push(e);
					}
				}
				t.teleport(toTp);
				break;
			}
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

	function teleport(toTp : Array<Entity>) {
		var teleportCb = function() {
			var outPos = new h3d.col.Point();
			var outRadius = 1.0;
			for ( i => e in toTp ) {
				var theta = 2.0 * Math.PI * i / toTp.length;
				outPos.load(getPos());
				outPos.x += Math.cos(theta) * outRadius;
				outPos.y += Math.sin(theta) * outRadius;
				e.x = outPos.x;
				e.y = outPos.y;
				e.z = outPos.z;
				e.room = room;
			}
		};
		game.moveTo(room, [teleportCb]);
	}
	
	override function getTooltipText() {
		var text = "Press F to teleport";
		if ( color == null )
			text += " Press E to change color.";
		return text;
	}
}