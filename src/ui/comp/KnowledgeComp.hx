package ui.comp;

@:uiComp("knowledgeComp")
class KnowledgeComp extends BaseElement {
	static var SRC =
	<knowledgeComp>
		<text id="text"/>
	</knowledgeComp>

	var knowledgeNode : st.KnowledgeNode;
	var win : KnowledgeWindow;

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

	function getOutAngle() {
		var parentComp = Std.downcast(parent, KnowledgeComp);
		if ( parentComp == null )
			return 0.0;
		return -Math.PI * 0.5 + Math.atan2(y, -x);
	}

	override function sync(ctx : h2d.RenderContext) {
		super.sync(ctx);

		if ( knowledgeNode.level == 0 ) {
			x = 0.0;
			y = 0.0;
		} else {
			var space = switch ( knowledgeNode.level ) {
			case 0: 0.0;
			case 1: 0.25;
			case 2: 0.1;
			default: 0.1;
			}
			var siblingsCount = knowledgeNode.parent.children.length;
			var index = knowledgeNode.getIndex();
			if ( knowledgeNode.parent.parent != null ) {
				siblingsCount++;
				index++;
			}
			var theta = Math.PI - index / siblingsCount * 2.0 * Math.PI;
			theta += cast(parent, KnowledgeComp).getOutAngle();
			x = Math.sin(theta) * ctx.scene.width * space * win.zoom;
			y = Math.cos(theta) * ctx.scene.height * space * win.zoom;
		}
		
		drawLinks(ctx);
	}

	function drawLinks(ctx : h2d.RenderContext) {
		if ( knowledgeNode.children.length == 0 )
			return;
		var g = win.g;
		for ( c in children ) {
			var k = Std.downcast(c, KnowledgeComp);
			if ( k == null )
				continue;
			var absPos = getAbsPos();
			var cAbsPos = c.getAbsPos();
			g.moveTo(absPos.x, absPos.y);
			g.lineTo(cAbsPos.x, cAbsPos.y);
		}
	}
}