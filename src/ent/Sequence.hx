package ent;

class Sequence {

	var onUpdate : Float -> Bool;

	public function new(onUpdate : Float -> Bool) {
		this.onUpdate = onUpdate;
	}

	public function update(dt) {
		return this.onUpdate(dt);
	}
}