package ent;

class Memo extends Entity {

	override function getTooltipText() {
		return inf.dialog;
	}

	override function cull() {
		super.cull();
		if ( tooltip != null )
			tooltip.visible = tooltip.visible && Main.PREFS.memo;
	}
}