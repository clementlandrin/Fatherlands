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
	
	public var baseUI : ui.BaseUI;

	var modeMake : TimeMode = Common;
	
	var presentLighting : h3d.scene.Object;
	var presentRenderer : gfx.Renderer;
	var pastLighting : h3d.scene.Object;
	var pastRenderer : gfx.Renderer;

	var cameraController : CameraController;
	var mainUI : ui.MainUI;

	var startLevel : String;
	public function new(?level : String) {
		super();
		inst = this;
		modelCache = new h3d.prim.ModelCache();
		pastShader = new prefab.TemporalShader.Temporal();
		pastShader.PAST = true;
		presentShader = new prefab.TemporalShader.Temporal();

		pastWindowShader = new prefab.TemporalWindowShader.TemporalWindow();

		startLevel = level;
	}

	override function init() {
		baseUI = new ui.BaseUI();
		new ui.Console();

		mainUI = new ui.MainUI(baseUI.root);
		
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
		var p = null;
		if ( startLevel == null ) {
			p = hxd.Res.world.load().clone(sh);
		} else {
			p = hxd.res.Loader.currentInstance.load(startLevel).toPrefab().load().clone(sh);
		}
		p.make();
		for ( m in s3d.getMaterials() )
			m.refreshProps();

		cameraController = new CameraController();

		for ( e in entities )
			e.start();

		for ( e in entities ) {
			var r = Std.downcast(e, ent.Room);
			if ( r != null ) {
				moveTo(r);
				break;
			}
		}


		presentLighting = new h3d.scene.Object(s3d);
		pastLighting = new h3d.scene.Object(s3d);
	}

	var pastTexCopy : h3d.mat.Texture;
	var pastDepthCopy : h3d.mat.Texture;
	override function render(e:h3d.Engine) {
		s3d.renderer = pastRenderer;
		presentLighting.visible = false;
		pastLighting.visible = true;
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
		presentLighting.visible = true;
		pastLighting.visible = false;
		for ( e in entities ) {
			e.setMode(Present);
		}

		// prevent syncRec twice.
		s3d.fixedPosition = true;
		s3d.render(e);
		s3d.fixedPosition = false;
		s2d.render(e);
	}

	public function applyRenderer(p : hrt.prefab.RenderProps, mode : TimeMode) {
		switch(mode) {
		case Present:
			if ( presentLighting != null )
				presentLighting.remove();
			presentLighting = new h3d.scene.Object(s3d);
			p.make(presentLighting); // p.clone()?
			p.applyProps(presentRenderer);
		case Past:
			if ( pastLighting != null )
				pastLighting.remove();
			pastLighting = new h3d.scene.Object(s3d);
			p.make(pastLighting); // p.clone()?
			p.applyProps(pastRenderer);
		default:
			throw "invalid mode";
		}
	} 
	
	function customMake(p : hrt.prefab.Prefab) {
		var obj3d = p.to(hrt.prefab.Object3D);
		var source = p.source;
		var e : ent.Entity = null;

		switch(p.name.toLowerCase()) {
		case "past":
			modeMake = Past;
		case "present":
			modeMake = Present;
		default:
		}

		if ( source != null && source.indexOf("content/Room") == 0 ) {
			if ( curRoom != null )
				throw 'room in room. ${source} should not be in room?';
			var r = new ent.Room();
			@:privateAccess r.name = source.split("content/Room/")[1];
			curRoom = r;
			e = r;
		}

		switch ( p.getCdbType() ) {
		case "element":
			var props:Data.Element = cast p.props;
			switch(props.type) {
			case Room:
				curRoom.inf = props.props;
			case Door:
				if ( curRoom == null )
					throw "door outside room";
				var d = new ent.Door();
				e = d;
				e.inf = props.props;
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
				e.inf = props.props;
			case Ladder:
				var l = new ent.Ladder();
				e = l;
				e.inf = props.props;
			case Interactible:
				var i = new ent.Interactible();
				e = i;
				e.inf = props.props;
			case Teleport:
				var t = new ent.Teleport();
				e = t;
				e.inf = props.props;
			}
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
		if ( e != null ) {
			e.setObject(obj3d.local3d);
			// leaving room
			if ( Std.isOfType(e, ent.Room) )
				curRoom = null;
		}
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

		if ( hxd.Key.isPressed(hxd.Key.F5) )
			Main.reload();

		baseUI.update(dt);

		if ( hxd.Key.isDown(hxd.Key.CTRL) && hxd.Key.isPressed(hxd.Key.S) )
			save();
	}

	public function moveTo(newRoom : ent.Room, ?pos : h3d.col.Point) {
		for ( e in entities ) {
			var r = Std.downcast(e, ent.Room);
			if ( r == null )
				continue;
			r.leave();
		}
		if ( pos == null ) {
			pos = new h3d.col.Point();
			pos.x = newRoom.x;
			pos.y = newRoom.y;
			pos.z = newRoom.z;
		}
		player.x = pos.x;
		player.y = pos.y;
		player.z = pos.z;
		newRoom.enter();
		cameraController.enteredRoom(newRoom);
		mainUI.enterRoom(newRoom);
	}

	public function canControl() {
		for ( w in @:privateAccess baseUI.windows ) {
			if ( w.preventControl )
				return false;
		}
		return true;
	}

	public function onCdbReload() {
	}

	public function save(path = "save.sav") {
		var res = hxbit.Serializer.save(player);
		sys.io.File.saveBytes(path, res);
	}

	public function load(path = "save.sav") {
		var bytes = sys.io.File.getBytes(path);
		hxbit.Serializer.load(bytes, ent.Player, function(o) {
			var e = Std.downcast(o, ent.Entity);
			if ( e != null ) {
				trace(e);
			}
		});
	}
}