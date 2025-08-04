package st;

class State implements hxbit.Serializable {

	var game : Game;
	public var name(default, null) : String;

	public var enabled : Bool = true;
	
	public function new() {
		game = Game.inst;
		game.states.push(this);
	}

	public function start() {
	}

	public function update(dt : Float) {
	}

	public function dispose() {
		game.states.remove(this);
	}
}