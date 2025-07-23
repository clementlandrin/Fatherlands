package ent;

class Interactible extends Entity {

	var dialog : ui.Dialog;

	public function new() {
		super();
		interact = true;
	}

	override function onTrigger() {
		if ( game.baseUI.currentDialog == null )
			new ui.Dialog(this, game.baseUI.root);
	}

	override function update(dt : Float) {
		super.update(dt);
		var inRange = game.player.getPos().distance(getPos()) < Const.get(InteractibleRadius);
		if ( inRange ) {
			onOver();
			if ( hxd.Key.isPressed(hxd.Key.F) )
				onTrigger();
		} else {
			onOut();
		}
	}
}