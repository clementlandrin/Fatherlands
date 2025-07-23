package ui.comp;

@:uiComp("button")
class Button extends BaseElement {

	public function new(?parent) {
		super(parent);
		initComponent();
		enableInteractive = true;
		interactive.onClick = function (e:hxd.Event) {
			if ( e.button == 0 )
				onClick();
		};
	}
}