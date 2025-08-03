package ui.comp;

@:uiComp("knowledgeComp")
class KnowledgeComp extends BaseElement {
	static var SRC =
	<knowledgeComp>
		<text id="text"/>
	</knowledgeComp>

	var knowledgeNode : KnowledgeNode;
	var win : KnowledgeWindow;

	public function new(win : KnowledgeWindow, k : KnowledgeNode, ?parent) {
		super(parent);
		this.win = win;
		this.knowledgeNode = k;
		initComponent();
		text.text = knowledgeNode.id;
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
		// if ( knowledgeNode.level == 0 ) {
		// } else {
		// 	var level = knowledgeNode.level;
		// 	x = Math.cos(theta) * 0.5;
		// 	y = Math.sin(theta) * 0.5;
		// }
	}
}