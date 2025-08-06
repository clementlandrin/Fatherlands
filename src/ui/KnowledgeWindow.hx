package ui;

class KnowledgeWindow extends Window {
	static var SRC =
	<knowledge-window>
		<text id="title"/>
		<flow id="content"/>
	</knowledge-window>

	public var zoom : Float = 1.0;
	public var g : h2d.Graphics;

	public function new(?parent) {
		super(parent);
		preventControl = true;
		initComponent();
		layout = Stack;
		g = new h2d.Graphics();
		this.addChild(g);
		title.text = "Knowledge graph";
		var root = Game.inst.state.knowledgeRoot;
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

	override function sync(ctx : h2d.RenderContext) {
		g.clear();
		g.lineStyle(1.0, 0xFFFFFF);

		super.sync(ctx);

		g.x = ctx.scene.width * 0.5;
		g.y = 0.0;//ctx.scene.height * 0.5;
	}

	override function isUnique() {
		return true;
	}
}