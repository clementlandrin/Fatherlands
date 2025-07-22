package ui;

class BaseUIRoot extends ui.comp.BaseElement {
}

class BaseUI {

	public var root : BaseUIRoot;
	public var style(default, null) : h2d.domkit.Style;

	var s2d : h2d.Scene;

	public function new() {
		Game.inst.baseUI = this;

		s2d = Game.inst.s2d;
		
		style = new h2d.domkit.Style();
		style.allowInspect = true;
		style.onInspectHyperlink = function(url: String) {
			new sys.io.Process('code --goto $url', false).close();
		}

		root = new BaseUIRoot(s2d);
		style.addObject(root);

		loadStyle();
	}

	function loadStyle() {
		style.clear();
		style.load(hxd.Res.ui.style.style);
	}	
}