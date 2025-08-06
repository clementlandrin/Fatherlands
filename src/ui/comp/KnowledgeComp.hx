package ui.comp;

@:uiComp("knowledgeComp")
class KnowledgeComp extends BaseElement {
	static var SRC =
	<knowledgeComp>
		<text id="text"/>
	</knowledgeComp>

	var knowledgeNode : st.KnowledgeNode;
	var win : KnowledgeWindow;
	var g : h2d.Graphics;

	public function new(win : KnowledgeWindow, k : st.KnowledgeNode, ?parent) {
		super(parent);
		this.win = win;
		this.knowledgeNode = k;
		initComponent();
		text.text = knowledgeNode.id.toString();
		text.textAlign = Center;
		if ( k.discovered )
			dom.addClass("discovered");
	}

	override function sync(ctx : h2d.RenderContext) {
		super.sync(ctx);

		if ( knowledgeNode.level == 0 ) {
			x = 0.0;
			y = 0.0;
		} else {
			var index = knowledgeNode.getIndex();
			var theta = Math.PI - index / knowledgeNode.parent.children.length * 2.0 * Math.PI;
			var size = Math.pow(0.25 * win.zoom, knowledgeNode.level); 
			x = Math.sin(theta) * ctx.scene.width * size;
			y = Math.cos(theta) * ctx.scene.height * size;
		}
		
		drawLinks(ctx);
	}

	function drawLinks(ctx : h2d.RenderContext) {
		if ( knowledgeNode.children.length == 0 )
			return;
		if ( g == null ) {
			g = new h2d.Graphics();
			win.addChild(g);
		}
		g.clear();
		g.lineStyle(10.0, knowledgeNode.level == 0 ? 0xFF00FF : 0xFF0000);
		for ( c in children ) {
			var k = Std.downcast(c, KnowledgeComp);
			if ( k == null )
				continue;
			
			g.moveTo(0.0, 0.0);
			g.lineTo(c.x, c.y);
		}
	}
}