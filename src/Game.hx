import h3d.Camera;

enum TimeMode {
	None;
	Present;
	Past;
	Common;
}

class Game extends hxd.App {

	var pastShader : prefab.TemporalShader.Temporal;
	var presentShader : prefab.TemporalShader.Temporal;
	public static var inst : Game;

	public var player : ent.Player;
	public var curRoom : ent.Room;
	public var entities : Array<ent.Entity>;
	public var modelCache : h3d.prim.ModelCache;

	var cameraController : h3d.scene.CameraController;

	var modeMake : TimeMode = Common;

	public function new() {
		super();
		inst = this;
		modelCache = new h3d.prim.ModelCache();
		pastShader = new prefab.TemporalShader.Temporal();
		pastShader.PAST = true;
		presentShader = new prefab.TemporalShader.Temporal();
	}

	override function init() {
		new ui.Console();
		
		s3d.renderer = new gfx.Renderer(h3d.scene.pbr.Environment.getDefault());

		entities = [];
		player = new ent.Player();

		var sh = new hrt.prefab.ContextShared(s3d);
		sh.customMake = customMake;
		var p = hxd.Res.world.load().clone(sh);
		p.make();

		var cam = s3d.camera;
		cam.orthoBounds = new h3d.col.Bounds();

		cameraController = new h3d.scene.CameraController(Const.get(CameraDistance), s3d);
		cameraController.enableZoom = false;
		cameraController.smooth = 0.0;

		for ( e in entities )
			e.start();
	}

	function customMake(p : hrt.prefab.Prefab) {
		var obj3d = p.to(hrt.prefab.Object3D);

		switch(p.name.toLowerCase()) {
		case "past":
			modeMake = Past;
		case "present":
			modeMake = Present;
		default:
		}

		var e : ent.Entity = null;
		switch ( p.getCdbType() ) {
		case "element":
			var props:Data.Element = cast p.props;
			switch(props.type) {
			case Room:
				if ( curRoom != null )
					throw "room in room";
				var r = new ent.Room();
				curRoom = r;
				e = r;
			case Door:
				if ( curRoom == null )
					throw "door outside room";
				var d = new ent.Door();
				e = d;
			case Navmesh:
				if ( curRoom == null )
					throw "navmesh outside room";
				var n = new ent.Navmesh();
				switch(p.type) {
				case "polygon":
					var polygon = cast(p, hrt.prefab.l3d.Polygon);
					n.setPolygon(polygon);
				case "box":
					var box = cast(p, hrt.prefab.l3d.Box);
					n.setBox(box);
				default:
					throw "unsupported navmesh";
				}
				n.setMode(modeMake);
				e = n;
			case Ladder:
				var l = new ent.Ladder();
				e = l;
			}
			p.make();
			onPrefabMake(p);
			e.setObject(obj3d.local3d);

			// leaving room
			if ( props.type == Room )
				curRoom = null;
			return;
		default:
			switch ( p.type ) {
			case "camera":
				var cam = cast(p, hrt.prefab.l3d.Camera);
				if ( curRoom != null )
					curRoom.setCamera(cam);
			case "renderProps":
				var rp = cast(p, hrt.prefab.RenderProps);
				if ( curRoom != null ) {
					switch(modeMake) {
					case Present: curRoom.presentRenderProps = rp;
					case Past: curRoom.pastRenderProps = rp;
					default:
					}
				}
			}
		}

		p.make();
		onPrefabMake(p);
	}

	function onPrefabMake(p : hrt.prefab.Prefab) {
		var obj3d = p.to(hrt.prefab.Object3D);
		if ( obj3d != null )
			temporalMaterials(obj3d.local3d, modeMake);
		
		// leaving past/present folder
		switch(p.name.toLowerCase()) {
		case "past", "present":
			modeMake = Common;
		default:
		}
	}

	function temporalMaterials(obj : h3d.scene.Object, mode : TimeMode) {
		switch(mode) {
		case Past:
			for ( m in obj.getMaterials() )
				if ( m.mainPass.getShader(prefab.TemporalShader.Temporal) == null )
					m.mainPass.addShader(pastShader);
		case Present:
			for ( m in obj.getMaterials() )
				if ( m.mainPass.getShader(prefab.TemporalShader.Temporal) == null )
					m.mainPass.addShader(presentShader);
		default:
		}
	}

	override function update(dt : Float) {
		super.update(dt);

		for ( e in entities )
			if ( e.enabled )
				e.update(dt);

		if ( curRoom != null && curRoom.camera == null ) {
			cameraController.set(new h3d.col.Point(curRoom.x, curRoom.y, curRoom.z));
			updateCamera(dt);
		}

		if ( hxd.Key.isPressed(hxd.Key.F5) )
			Main.reload();
	}

	public function moveTo(newRoom : ent.Room) {
		for ( e in entities ) {
			var r = Std.downcast(e, ent.Room);
			if ( r == null )
				continue;
			r.leave();
		}
		if ( curRoom == null ) {
			player.x = newRoom.x;
			player.y = newRoom.y;
			player.z = newRoom.z;
		} else {
			var door = newRoom.getDoorFrom(curRoom);
			var dir = door.getEnteringDirection();
			player.x = door.x + dir.x * 1.0;
			player.y = door.y + dir.y * 1.0;
			player.z = door.z;
		}
		newRoom.enter();
	}

	function updateCamera(dt : Float) {
		var cam = s3d.camera;
		var X = Const.get(CameraWidth) * 0.5;
		var Y = X / cam.screenRatio;
		var Z = Const.get(CameraDepth) * 0.5;
		cam.orthoBounds.xMax = X;
		cam.orthoBounds.yMax = Y;
		cam.orthoBounds.xMin = -X;
		cam.orthoBounds.yMin = -Y;
		cam.orthoBounds.zMax = Z;
		cam.orthoBounds.zMin = -Z;
	}

	public function onCdbReload() {
	}
}