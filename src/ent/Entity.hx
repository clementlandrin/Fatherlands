package ent;

class Entity extends st.State {

	public var room(default, null) : Room;
	public var inf : Data.Element_props;
	var interactive : h3d.scene.Interactive;
	var outlineShader : shaders.OutlineShader;
	var interact : Bool;
	var tooltip : ui.Tooltip;
	var timeMode : Game.TimeMode;

	public var obj : h3d.scene.Object;
	
	@:s public var x(default, set) : Float;
	public function set_x(v) {
		if ( obj != null )
			obj.x = v;
		return x = v;
	}
	@:s public var y(default, set) : Float;
	public function set_y(v) {
		if ( obj != null )
			obj.y = v;
		return y = v;
	}
	@:s public var z(default, set) : Float;
	public function set_z(v) {
		if ( obj != null )
			obj.z = v;
		return z = v;
	}
	
	override function init() {
		super.init();
		if ( game.state != null )
			room = game.state.curRoom;
		timeMode = @:privateAccess game.modeMake;
		game.entities.push(this);
	}

	public function canBeTp() {
		return inf != null && inf.canTp;
	}

	public function getPos() {
		return new h3d.col.Point(x,y,z);
	}

	public function setPos(pos : h3d.Vector) {
		x = pos.x;
		y = pos.y;
		z = pos.z;
	}

	public function getPos2D() {
		return getPos().to2D();
	}

	public function setObject(obj : h3d.scene.Object) {
		this.obj = obj;
		obj.inheritCulled = true;
		this.name = obj.name;
		if ( isMemo() )
			setTooltip();
		// not point and click for now
		// if ( interact ) {
		// 	initInteractive();
		// }
	}

	public function posFromObj() {
		var pos = obj.getAbsPos().getPosition();
		@:bypassAccessor x = pos.x;
		@:bypassAccessor y = pos.y;
		@:bypassAccessor z = pos.z;
	}

	function initInteractive() {
		interactive = new h3d.scene.Interactive(obj.getBounds(null, obj));
		obj.addChild(interactive);
		interactive.onClick = function(e : hxd.Event) {
			if ( e.button == 0 )
				trigger();
		}
		interactive.onOver = function(e : hxd.Event) {
			onOver();
		}
		interactive.onOut = function(e : hxd.Event) {
			onOut();
		}
	}

	function isMemo() {
		return inf != null && inf.memo;
	}

	function onOver() {
		setOutline(true);
		setTooltip();
	}

	function onOut() {
		setOutline(false);
		removeTooltip();
	}

	final function trigger() {
		if ( game.canControl() )
			onTrigger();
	}

	final function secondTrigger() {
		if ( game.canControl() )
			onSecondTrigger();
	}

	function onTrigger() {

	}

	function onSecondTrigger() {

	}

	override function start() {
		super.start();
		if ( obj != null ) {
			var newTransform = new h3d.Matrix();
			newTransform.multiply3x4inline(obj.getTransform(), obj.parent.getAbsPos());
			obj.setTransform(newTransform);
			game.s3d.addChild(obj);
		}
	}

	public function createUnitBounds() {
		var boxBounds = new h3d.col.Bounds();
		boxBounds.xMin = -0.5;
		boxBounds.yMin = -0.5;
		boxBounds.zMin = -0.5;
		boxBounds.xSize = 1.0;
		boxBounds.ySize = 1.0;
		boxBounds.zSize = 1.0;
		return boxBounds;
	}

	override function update(dt : Float) {
		super.update(dt);
		if ( interact ) {
			var player = game.player;
			var inRange = player.getPos().distance(getPos()) < Const.get(InteractibleRadius);
			switch ( timeMode ) {
			case Common:
			case Past:
				inRange = inRange && getPos().distance(player.getTemporalPos()) < player.getTemporalRadius();
			case Present:
				inRange = inRange && getPos().distance(player.getTemporalPos()) > player.getTemporalRadius();
			case None:
				throw "assert";
			}
			if ( inRange ) {
				onOver();
				if ( hxd.Key.isPressed(hxd.Key.F) )
					trigger();
				if ( hxd.Key.isPressed(hxd.Key.E) )
					secondTrigger();
			} else {
				onOut();
			}
		}
	}

	public function cull() {
		var culled = !enabled || (room != null && !room.enabled);
		obj.culled = culled;
		if ( tooltip != null )
			tooltip.visible = !culled;
	}

	public function setMode(mode : Game.TimeMode) {

	}

	public function setOutline(b : Bool) {
		if ( b ) {
			if ( outlineShader == null ) {
				outlineShader = new shaders.OutlineShader();
				outlineShader.color.setColor(Const.getColor(OutlineColor));
				outlineShader.size = Const.get(OutlineSize);
				var mainStencil = new h3d.mat.Stencil();
				mainStencil.setFunc(Always, Const.STENCIL_OUTLINE, Const.STENCIL_OUTLINE, Const.STENCIL_OUTLINE);
				mainStencil.setOp(Keep, Keep, Replace);
				var outlineStencil = new h3d.mat.Stencil();
				outlineStencil.setFunc(Equal, 0, Const.STENCIL_OUTLINE, Const.STENCIL_OUTLINE);
				outlineStencil.setOp(Keep, Keep, Keep);
				for ( m in obj.getMaterials() ) {
					m.mainPass.stencil = mainStencil;
					var p = m.allocPass("afterTonemapping");
					p.addShader(outlineShader);
					p.stencil = outlineStencil;
				}
			}
			// if (obj != null) {
			// 	for( m in obj.getMeshes() ) {
			// 		var p = Std.downcast(m.primitive, h3d.prim.HMDModel);
			// 		if( p == null )
			// 			continue;
			// 		if( !p.hasInput("logicNormal") )
			// 			p.recomputeNormals("logicNormal");
			// 	}
			// }
		} else {
			if ( outlineShader != null ) {
				outlineShader = null;
				for ( m in obj.getMaterials() ) {
					m.mainPass.stencil = null;
					var p = m.getPass("afterTonemapping");
					if ( p != null )
						m.removePass(p);
				}
			}
		}
	}

	function setTooltip() {
		if ( tooltip != null )
			return;
		tooltip = new ui.Tooltip(this, game.baseUI.root);
	}

	function removeTooltip() {
		if ( !isMemo() && tooltip != null ) {
			tooltip.remove();
			tooltip = null;
		}
	}

	public function getTooltipText() {
		return "default tooltip";
	}

	override function dispose() {
		super.dispose();
		obj.remove();
		if ( tooltip != null )
			tooltip.remove();
		game.entities.remove(this);
	}
}