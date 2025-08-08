package ent;

class Interactible extends Entity {

	override function canInteract() {
		return game.player.item != this;
	}

	override function onTrigger() {
		super.onTrigger();
		if ( inf.dialog != null ) {
			new ui.Dialog(this, game.baseUI.root);
		}
		if ( inf.knowledgeId != null ) {
			var k = null;
			game.state.knowledgeRoot.iter(function(n) {
				if ( inf.knowledgeId == n.id )
					k = n;
			});
			k.discovered = true;
		}
		if ( inf.unlockArtefact )
			game.player.unlockedSkill = true;
		if ( tooltip != null )
			removeTooltip();
		if ( inf.activatorId != null ) {
			for ( e in game.entities ) {
				if ( e.id == inf.activatorId )
					e.activated = true;
			}
		}
		if ( inf.pickableItem )
			game.player.pickItem(this);
	}

	override function setTooltip() {
		if ( inf.dialog == null && !inf.pickableItem )
			return;
		var windows = @:privateAccess game.baseUI.windows;
		for ( w in windows ) {
			if ( Std.isOfType(w, ui.Dialog) )
				return;
		}
		super.setTooltip();
	}

	override function getTooltipText() {
		if ( inf.dialog != null )
			return "Press F to discuss.";
		if ( inf.pickableItem )
			return "Press F to pick.";
		return "Press F to interact.";
	}
}