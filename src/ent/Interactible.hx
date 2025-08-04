package ent;

class Interactible extends Entity {

	public function new() {
		super();
		interact = true;
	}

	override function onTrigger() {
		if ( inf.dialog != null ) {
			new ui.Dialog(this, game.baseUI.root);
		}
		if ( inf.knowledgeId != null ) {
			var k = null;
			Game.inst.state.knowledgeRoot.iter(function(n) {
				if ( inf.knowledgeId == n.id )
					k = n;
			});
			k.discovered = true;
		}
		if ( inf.unlockArtefact )
			Game.inst.player.unlockedSkill = true;
		if ( tooltip != null )
			removeTooltip();
	}

	override function setTooltip() {
		var windows = @:privateAccess game.baseUI.windows;
		for ( w in windows ) {
			if ( Std.isOfType(w, ui.Dialog) )
				return;
		}
		super.setTooltip();
	}

	override function getTooltipText() {
		return "Press F to discuss.";
	}
}