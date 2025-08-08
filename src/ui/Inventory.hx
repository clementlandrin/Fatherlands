package ui;

class Inventory extends Window {
	static var SRC =
	<inventory>
		<text id="text"/>
	</inventory>

	public function new(?parent) {
		super(parent);
		initComponent();
	}

	override function sync(ctx : h2d.RenderContext) {
		super.sync(ctx);

		var itemId = Game.inst.player.item?.id.toString();
		text.text = itemId != null ? itemId : "aucun objet en main";
	}
}