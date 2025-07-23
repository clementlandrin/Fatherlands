package ui;

class Dialog extends ui.comp.BaseElement {
	static var SRC =
	<dialog>
		<text id="speechText"/>
		// <button id="button"/>
	</dialog>

	var entity : ent.Entity;
	public function new(entity : ent.Entity, ?parent) {
		super(parent);
		this.entity = entity;
		initComponent();
		speechText.text = entity.inf.dialog;

		// button.onClick = function() {
		// 	this.remove();
		// };

		baseUI.currentDialog = this;
	}

	override function onRemove() {
		super.onRemove();
		baseUI.currentDialog = null;
	}
}