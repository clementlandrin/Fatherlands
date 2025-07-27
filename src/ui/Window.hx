package ui;

class Window extends ui.comp.BaseElement {

	public var preventControl : Bool = false;

	public function new(?parent) {
		super(parent);
		initComponent();
		@:privateAccess baseUI.windows.push(this);
	}

	override function onRemove() {
		super.onRemove();
		@:privateAccess baseUI.windows.remove(this);
	}
}