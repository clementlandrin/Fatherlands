package ui;

class Dialog extends ui.comp.BaseElement {
	static var SRC =
	<dialog>
		<text id="speechText"/>
	</dialog>

	var entity : ent.Entity;
	public function new(entity : ent.Entity, ?parent) {
		super(parent);
		this.entity = entity;
		initComponent();
		dom.applyStyle(baseUI.style);
		speechText.text = "titi";
	}
}