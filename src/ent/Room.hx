package ent;

class Room extends Entity {

    public var doors : Array<Door> = [];
    public var navmeshes : Array<Navmesh> = [];
	public var voxels : Voxels;
	public var camera : hrt.prefab.l3d.Camera;

	public var presentRenderProps : hrt.prefab.RenderProps;
	public var pastRenderProps : hrt.prefab.RenderProps;

	public var pastPrefab : hrt.prefab.Object3D;
	public var presentPrefab : hrt.prefab.Object3D;

	override function set_enabled(v : Bool) {
		super.set_enabled(v);
		for ( d in doors )
			d.enabled = enabled;
		for ( n in navmeshes )
			n.enabled = enabled;
		return enabled;
	}
	
	override function start() {
		super.start();
		if ( name == "start" )
			game.moveTo(this);
	}

	public function enter() {
		if ( voxels != null )
			voxels.dispose();
		voxels = new Voxels(this);
		enabled = true;
		game.curRoom = this;
		if ( camera != null )
			camera.applyTo(game.s3d.camera);
		if ( presentRenderProps != null )
			game.applyRenderer(presentRenderProps);
		else
			game.applyRenderer(hxd.Res.lighting._default.load().clone().find(hrt.prefab.RenderProps));
	}

	public function leave() {
		if ( voxels != null )
			voxels.dispose();
		voxels = null;
		enabled = false;
	}

	public function setCamera(camera : hrt.prefab.l3d.Camera) {
		this.camera = camera;
	}

	public function getDoorFrom(prevRoom : Room) {
		var dir = new h2d.col.Point(x - prevRoom.x, y - prevRoom.y).normalized();
		var maxDot = hxd.Math.NEGATIVE_INFINITY;
		var enteringDoor = null;
		for ( d in doors ) {
			var dot = d.getEnteringDirection().dot(dir);
			if ( dot > maxDot ) {
				maxDot = dot;
				enteringDoor = d;
			}
		}
		return enteringDoor;
	}

	override function setMode(mode : Game.TimeMode) {
		super.setMode(mode);
		if ( presentPrefab != null )
			for ( p in presentPrefab.findAll(hrt.prefab.Object3D, true) )
				if ( p.local3d != null )
					p.local3d.visible = mode == Present || mode == Common;
		if ( pastPrefab != null ) {
			for ( p in pastPrefab.findAll(hrt.prefab.Object3D, true) )
				if ( p.local3d != null )
					p.local3d.visible = mode == Past || mode == Common;
		}
	}
}