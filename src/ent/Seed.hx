package ent;

class Seed extends Entity {

	var growth : Float = 0.0;

	public function grow(dt : Float) {
		var growFactor = dt * 0.1;
		growth += growFactor;
		if ( !fullyGrown() )
			obj.scale(growFactor + 1.0);
	}

	public function fullyGrown() {
		if ( growth >= 1.0 )
			growth = 1.0;
		return growth == 1.0;
	}
}