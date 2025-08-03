package ent;

class Interactible extends Entity {

	var dialog : ui.Dialog;

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
			Game.inst.knowledgeRoot.iter(function(n) {
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

	override function getTooltipText() {
		return "Press F to discuss.";
	}
}