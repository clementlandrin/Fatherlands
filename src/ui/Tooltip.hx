package ui;

class Tooltip extends Window {
	static var SRC =
	<tooltip>
		<text id="text"/>
	</tooltip>

	var entity : ent.Entity;
	public function new(entity : ent.Entity, ?parent) {
		super(parent);
		autoRemoved = true;
		this.entity = entity;
		initComponent();
		text.text = entity.getTooltipText();
	}

	override function sync(ctx : h2d.RenderContext) {
		var game = @:privateAccess entity.game;
		var pos = game.s3d.camera.project(entity.x, entity.y, entity.z, game.s2d.width, game.s2d.height);
		x = pos.x;
		y = pos.y;
		super.sync(ctx);
	}
}