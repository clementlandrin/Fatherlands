package ui;

class KnowledgeWindow extends Window {
	static var SRC =
	<knowledge-window>
		<text id="title"/>
		<flow id="content"/>
	</knowledge-window>

	public var zoom : Float = 1.0;

	public function new(?parent) {
		super(parent);
		preventControl = true;
		initComponent();
		title.text = "Knowledge graph";
		var root = Game.inst.knowledgeRoot;
		var rootComp = new ui.comp.KnowledgeComp(this, root, content);
		function rec(n : st.KnowledgeNode, comp : ui.comp.KnowledgeComp) {
			for ( c in n.children ) {
				var newRootComp = new ui.comp.KnowledgeComp(this, c, comp);
				rec(c, newRootComp);
			}
		}
		rec(root, rootComp);
		Game.inst.s2d.addEventListener(onEvent);
	}

	function onEvent(e : hxd.Event) {
		switch ( e.kind ) {
		case EWheel:
			zoom *= (1.0 - 0.1 * e.wheelDelta);
		default:
		}
	}

	override function isUnique() {
		return true;
	}
}