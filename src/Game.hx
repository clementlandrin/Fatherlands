import h3d.Camera;

enum TimeMode {
	None;
	Present;
	Past;
	Common;
}

class Game extends hxd.App {

	public static var inst : Game;

	public var player : ent.Player;
	public var curRoom : ent.Room;
	public var entities : Array<ent.Entity>;
	public var modelCache : h3d.prim.ModelCache;

	public var pastShader : prefab.TemporalShader.Temporal;
	public var presentShader : prefab.TemporalShader.Temporal;

	public var pastWindowShader : prefab.TemporalWindowShader.TemporalWindow;

	var lighting : h3d.scene.Object;
	var modeMake : TimeMode = Common;

	var presentRenderer : gfx.Renderer;
	var pastRenderer : gfx.Renderer;

	public function new() {
		super();
		inst = this;
		modelCache = new h3d.prim.ModelCache();
		pastShader = new prefab.TemporalShader.Temporal();
		pastShader.PAST = true;
		presentShader = new prefab.TemporalShader.Temporal();

		pastWindowShader = new prefab.TemporalWindowShader.TemporalWindow();
	}

	override function init() {
		new ui.Console();
		
		presentRenderer = new gfx.Renderer(h3d.scene.pbr.Environment.getDefault());
		presentRenderer.timeMode = Present;
		pastRenderer = new gfx.Renderer(h3d.scene.pbr.Environment.getDefault());
		pastRenderer.timeMode = Past;

		pastWindowShader.tex = h3d.mat.Texture.fromColor(0xFF00FF);

		s3d.renderer = pastRenderer;

		entities = [];
		player = new ent.Player();

		var sh = new hrt.prefab.ContextShared(s3d);
		sh.customMake = customMake;
		var p = hxd.Res.world.load().clone(sh);
		p.make();

		var cam = s3d.camera;
		cam.orthoBounds = new h3d.col.Bounds();

		for ( e in entities )
			e.start();
	}

	var pastTexCopy : h3d.mat.Texture;
	var pastDepthCopy : h3d.mat.Texture;
	override function render(e:h3d.Engine) {
		s3d.renderer = pastRenderer;
		for ( e in entities ) {
			e.setMode(Past);	
		}
		s3d.render(e);
		var pastTex = @:privateAccess pastRenderer.textures.ldr;
		if ( pastTexCopy != null && (pastTexCopy.width != pastTex.width || pastTexCopy.height != pastTex.height) )
			pastTexCopy.dispose();
		if ( pastTexCopy == null || pastTexCopy.isDisposed() )
			pastTexCopy = new h3d.mat.Texture(pastTex.width, pastTex.height, [Target], pastTex.format);
		h3d.pass.Copy.run(pastTex, pastTexCopy);
		var pastDepth = @:privateAccess pastRenderer.textures.depth;
		if ( pastDepthCopy != null && (pastDepthCopy.width != pastDepth.width || pastDepthCopy.height != pastDepth.height) )
			pastDepthCopy.dispose();
		if ( pastDepthCopy == null || pastDepthCopy.isDisposed() )
			pastDepthCopy = new h3d.mat.Texture(pastDepth.width, pastDepth.height, [Target], pastDepth.format);
		h3d.pass.Copy.run(pastDepth, pastDepthCopy);
		pastWindowShader.tex = pastTexCopy;
		pastWindowShader.depth = pastDepthCopy;
		s3d.renderer = presentRenderer;
		for ( e in entities ) {
			e.setMode(Present);
		}

		// prevent syncRec twice.
		s3d.fixedPosition = true;
		s3d.render(e);
		s3d.fixedPosition = false;
		s2d.render(e);
	}

	public function applyRenderer(p : hrt.prefab.RenderProps) {
		if ( lighting != null )
			lighting.remove();
		lighting = new h3d.scene.Object(s3d);
		p.make(lighting); // p.clone()?
		p.applyProps(s3d.renderer);
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
				n.navmeshMode = modeMake;
				e = n;
			case Ladder:
				var l = new ent.Ladder();
				e = l;
			}
			p.make();
			for ( m in obj3d.local3d.getMaterials() )
				m.refreshProps();
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
				return;
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
		case "past":
			curRoom.pastPrefab = obj3d;
			modeMake = Common;
		case "present":
			curRoom.presentPrefab = obj3d;
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
			defaultCamera();
		}
		var Y = s3d.camera.orthoBounds.xMax / s3d.camera.screenRatio;
		s3d.camera.orthoBounds.yMax = Y;
		s3d.camera.orthoBounds.yMin = -Y;

		if ( hxd.Key.isPressed(hxd.Key.F5) )
			Main.reload();
	}

	public function moveTo(door : ent.Door) {
		var newRoom = door.room;
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
			var offset = door.getEnteringDirection().scaled(1.0);
			player.x = door.x + offset.x;
			player.y = door.y + offset.y;
			player.z = door.z + offset.z;
		}
		newRoom.enter();
	}

	function defaultCamera() {
		var cam = s3d.camera;
		cam.target = new h3d.col.Point(curRoom.x, curRoom.y, curRoom.z);
		cam.pos.x = Const.get(DefaultCameraX);
		cam.pos.y = Const.get(DefaultCameraY);
		cam.pos.z = Const.get(DefaultCameraZ);
		var X = Const.get(DefaultCameraWidth) * 0.5;
		var Z = Const.get(DefaultCameraDepth) * 0.5;
		cam.orthoBounds.xMax = X;
		cam.orthoBounds.xMin = -X;
		cam.orthoBounds.zMax = Z;
		cam.orthoBounds.zMin = -Z;
	}

	public function onCdbReload() {
	}
}