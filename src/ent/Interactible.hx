package ent;

class Interactible extends Entity {

	var dialog : ui.Dialog;
	override function setObject(obj : h3d.scene.Object) {
		super.setObject(obj);
		interactive = new h3d.scene.Interactive(obj.getBounds(null, obj));
		obj.addChild(interactive);
		interactive.onClick = onClick;
	}

	function onClick(e : hxd.Event) {
		new ui.Dialog(this, game.baseUI.root);
	}
}