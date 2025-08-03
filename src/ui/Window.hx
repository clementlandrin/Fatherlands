package ui;

class Window extends ui.comp.BaseElement {

	public var preventControl : Bool = false;
	public var unique : Bool = false;

	public function new(?parent) {
		super(parent);
		initComponent();
		var add = true;
		if ( isUnique() ) {
			for ( w in @:privateAccess baseUI.windows ) {
				if ( Std.isOfType(w, KnowledgeWindow) ) {
					add = false;
					this.remove();
				}
			}
		}
		if ( add )
			@:privateAccess baseUI.windows.push(this);
	}

	public function isUnique() {
		return false;
	}

	override function onRemove() {
		super.onRemove();
		@:privateAccess baseUI.windows.remove(this);
	}
}