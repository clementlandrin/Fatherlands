package ent;

class Interactible extends Entity {

	var dialog : ui.Dialog;

	public function new() {
		super();
		interact = true;
	}

	override function onTrigger() {
		new ui.Dialog(this, game.baseUI.root);
		if ( tooltip != null )
			tooltip.visible = false;
	}

	override function getTooltipText() {
		return "Press F to discuss.";
	}
}