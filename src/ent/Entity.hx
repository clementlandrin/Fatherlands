package ent;

class Entity implements hxbit.Serializable {

	var game : Game;
	public var name(default, null) : String;
	public var room(default, null) : Room;
	var interactive : h3d.scene.Interactive;
	var outlineShader : shaders.OutlineShader;
	var interact : Bool;
	var tooltip : ui.Tooltip;

	public var enabled : Bool = true;
	
	public var x(default, set) : Float;
	public function set_x(v) {
		return obj.x = x = v;
	}
	public var y(default, set) : Float;
	public function set_y(v) {
		return obj.y = y = v;
	}
	public var z(default, set) : Float;
	public function set_z(v) {
		return obj.z = z = v;
	}
	
	public var obj : h3d.scene.Object;
	public var inf : Data.Element_props;
	
	public function new() {
		game = Game.inst;
		game.entities.push(this);
		room = game.curRoom;
	}

	public function getPos() {
		return new h3d.col.Point(x,y,z);
	}

	public function getPos2D() {
		return getPos().to2D();
	}

	public function setObject(obj : h3d.scene.Object) {
		this.obj = obj;
		obj.inheritCulled = true;
		this.name = obj.name;
		var pos = obj.getAbsPos().getPosition();
		@:bypassAccessor x = pos.x;
		@:bypassAccessor y = pos.y;
		@:bypassAccessor z = pos.z;
		// not point and click for now
		// if ( interact ) {
		// 	initInteractive();
		// }
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

	public function start() {
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

	public function update(dt : Float) {
		if ( interact ) {
			var inRange = game.player.getPos().distance(getPos()) < Const.get(InteractibleRadius);
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
		if ( tooltip != null ) {
			tooltip.remove();
			tooltip = null;
		}
	}

	public function getTooltipText() {
		return "default tooltip";
	}

	public function dispose() {
		obj.remove();
		if ( tooltip != null )
			tooltip.remove();
	}
}