package ent;

class UnstableTeleport extends Entity {

	var cd : Float = 0.0;
	override function update(dt : Float) {
		super.update(dt);

		cd -= dt;
		if ( cd <= 0.0 || unstabilityProximity() ) {
			var min = Const.get(UnstableTeleportMinTime);
			var max = Const.get(UnstableTeleportMaxTime);
			var rooms = [];
			for ( e in game.entities ) {
				var r = Std.downcast(e, Room);
				if ( r == null || r == room )
					continue;
				rooms.push(r);
			}
			room = rooms[Std.random(rooms.length)];
			setPos(room.getPos());
			cd = min + hxd.Math.random(max - min);
		}
	}

	function unstabilityProximity() {
		return game.player.unlockedSkill && getPos().distance(game.player.getPos()) < Const.get(UnstableTriggerDistance);
	}

	override function canTrigger() {
		return super.canTrigger() && !unstabilityProximity(); 
	}
}