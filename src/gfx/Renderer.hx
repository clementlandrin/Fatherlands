package gfx;

class Renderer extends h3d.scene.pbr.Renderer {

	public var timeMode : Game.TimeMode;
	var game : Game;

	public function new(?env) {
		super(env);
		game = Game.inst;
	}

	override function initGlobals() {
		super.initGlobals();

		var player = game.player;
		ctx.setGlobal("playerPos", player.getTemporalPos());
		ctx.setGlobal("temporalRadius", player.getTemporalRadius());
	}

	override function mark(id : String) {
		super.mark(id);
		#if !editor
		if(Game.inst != null)
			Game.inst.measure(id);
		#end
	}
}
