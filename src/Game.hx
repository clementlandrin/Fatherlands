enum TimeMode {
	None;
	Present;
	Past;
	Common;
}

class Game extends hxd.App {

	public static var inst : Game;

	public var player(get, set) : ent.Player;
	public function get_player() {
		return state.player;
	}
	public function set_player(p : ent.Player) {
		return state.player = p;
	}
	public var curRoom(get, set) : ent.Room;
	public function get_curRoom() {
		return state.curRoom;
	}
	public function set_curRoom(r : ent.Room) {
		return state.curRoom = r;
	}
	public var state : st.GameState;
	public var states : Array<st.State>;
	public var entities : Array<ent.Entity>;
	public var modelCache : h3d.prim.ModelCache;

	public var pastShader : prefab.TemporalShader.Temporal;
	public var presentShader : prefab.TemporalShader.Temporal;

	public var pastWindowShader : prefab.TemporalWindowShader.TemporalWindow;
	
	public var baseUI : ui.BaseUI;
	public var globalEvent : hxd.WaitEvent;

	var modeMake : TimeMode = Common;
	
	var presentLighting : h3d.scene.Object;
	var presentRenderer : gfx.Renderer;
	var pastLighting : h3d.scene.Object;
	var pastRenderer : gfx.Renderer;

	var cameraController : CameraController;
	var mainUI : ui.MainUI;
	var knowledgeWindow : ui.KnowledgeWindow;

	var startLevel : String;

	var fadeEffect : hrt.prefab.rfx.Vignetting;
	var fadeDuration = 0.0;
	var curFade = 0.0;

	public function new(?level : String) {
		super();
		inst = this;
		modelCache = new h3d.prim.ModelCache();
		pastShader = new prefab.TemporalShader.Temporal();
		pastShader.PAST = true;
		presentShader = new prefab.TemporalShader.Temporal();

		pastWindowShader = new prefab.TemporalWindowShader.TemporalWindow();

		startLevel = level;
		fadeEffect = new hrt.prefab.rfx.Vignetting(null, null);
		fadeEffect.alpha = 0.0;
		fadeEffect.color = 0;
		fadeEffect.radius = 0.0;
		fadeEffect.softness = 0.0;
	}

	override function init() {
		states = [];
		entities = [];

		load();
		if ( state == null ) {
			state = new st.GameState();	
			state.level = startLevel;
		}
		baseUI = new ui.BaseUI();
		new ui.Console();
		globalEvent = new hxd.WaitEvent();

		mainUI = new ui.MainUI(baseUI.root);
		
		presentRenderer = new gfx.Renderer(h3d.scene.pbr.Environment.getDefault());
		presentRenderer.timeMode = Present;
		pastRenderer = new gfx.Renderer(h3d.scene.pbr.Environment.getDefault());
		pastRenderer.timeMode = Past;

		pastWindowShader.tex = h3d.mat.Texture.fromColor(0xFF00FF);

		s3d.renderer = pastRenderer;

		var sh = new hrt.prefab.ContextShared(s3d);
		sh.customMake = customMake;
		var p = null;
		if ( state.level == null )
			p = hxd.Res.world.load().clone(sh);
		else
			p = hxd.res.Loader.currentInstance.load(state.level).toPrefab().load().clone(sh);
		p.make();
		for ( m in s3d.getMaterials() )
			m.refreshProps();

		cameraController = new CameraController();

		for ( s in states )
			s.start();

		for ( e in entities ) {
			var r = Std.downcast(e, ent.Room);
			if ( r == null )
				continue;
			var defaultStartRoom = state.curRoomId == null && r.inf != null && r.inf.startingRoom;
			var roomFromSave = state.curRoomId != null && state.curRoomId == r.name;
			if ( defaultStartRoom || roomFromSave ) {
				var cb = null;
				if ( roomFromSave ) {
					var playerPos = player.getPos();
					cb = function() {
						player.setPos(playerPos);
					}
				}
				moveTo(r, [cb], true);
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
			s3d.renderer = presentRenderer;
			if ( presentLighting != null )
				presentLighting.remove();
			presentLighting = new h3d.scene.Object(s3d);
			var p = p.make(presentLighting); // p.clone()?
			p.applyProps(presentRenderer);
			var env = p.find(hrt.prefab.l3d.Environment);
			if ( env != null )
				env.applyToRenderer(presentRenderer);
		case Past:
			s3d.renderer = pastRenderer;
			if ( pastLighting != null )
				pastLighting.remove();
			pastLighting = new h3d.scene.Object(s3d);
			var p = p.make(pastLighting); // p.clone()?
			p.applyProps(pastRenderer);
			var env = p.find(hrt.prefab.l3d.Environment);
			if ( env != null )
				env.applyToRenderer(pastRenderer);
		default:
			throw "invalid mode";
		}
		s3d.renderer = null;
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
			r.prefab = obj3d;
			@:privateAccess r.name = source;
			curRoom = r;
			e = r;
		}

		switch ( p.getCdbType() ) {
		case "element":
			var props:Data.Element = cast p.props;
			switch(props.type) {
			case Room:
				curRoom.inf = props.props;
				curRoom.id = props.id;
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
			case Interactible:
				if ( props.props != null && props.props.memo ) {
					var m = new ent.Memo();
					e = m;
				} else {
					var i = new ent.Interactible();
					e = i;
				}
			case Teleport:
				var t = new ent.Teleport();
				e = t;
			}
			if ( e != null ) {
				e.inf = props.props;
				e.id = props.id;
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
			e.posFromObj();
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
		globalEvent.update(dt);

		if ( hxd.Key.isPressed(hxd.Key.K) ) {
			new ui.KnowledgeWindow(baseUI.root);
		}

		for ( e in entities )
			e.cull();

		if ( fadeDuration > 0.0 ) {
			var k = 3.0 * curFade / fadeDuration;
			if ( k < 1.0 ) {
				fadeEffect.alpha = k;
			} else if ( k >= 1.0 && k <= 2.0 ) {
				fadeEffect.alpha = 1.0;
			} else {
				fadeEffect.alpha = 3.0 - k;
			}
			curFade += dt;

			if ( curFade > fadeDuration ) {
				curFade = 0.0;
				fadeDuration = 0.0;
				presentRenderer.effects.remove(fadeEffect);
			} else {
				if ( !presentRenderer.effects.contains(fadeEffect) )
					presentRenderer.effects.push(fadeEffect);
			}
			return;
		}

		for ( s in states )
			s.update(dt);

		if ( hxd.Key.isPressed(hxd.Key.F5) )
			Main.reload();

		baseUI.update(dt);

		if ( hxd.Key.isDown(hxd.Key.CTRL) && hxd.Key.isPressed(hxd.Key.S) )
			save();
	}

	public function moveTo(newRoom : ent.Room, cbs : Array<Void -> Void>, fadeOutOnly : Bool = false) {
		var enterCb = function() {
			for ( e in entities ) {
				var r = Std.downcast(e, ent.Room);
				if ( r == null )
					continue;
				r.leave();
			}
			player.x = newRoom.x;
			player.y = newRoom.y;
			player.z = newRoom.z;
			newRoom.enter();
			cameraController.enteredRoom(newRoom);
			mainUI.enterRoom(newRoom);
		};
		fade(Const.get(FadeDurationBetweenRooms), [enterCb].concat(cbs), fadeOutOnly);
		state.curRoomId = newRoom != null ? newRoom.name : null;
	}

	public function canControl() {
		for ( w in @:privateAccess baseUI.windows ) {
			if ( w.preventControl )
				return false;
		}
		return true;
	}

	public function fade(t : Float = 1.0, cbs : Array<Void -> Void>, fadeOutOnly : Bool = false) {
		if ( fadeDuration > 0.0 )
			throw "fade in fade";
		fadeDuration = t;
		if ( fadeOutOnly )
			curFade = 2.0 * t / 3.0;
		presentRenderer.effects.push(fadeEffect);
		for ( cb in cbs ) {
			if ( cb != null ) {
				if ( fadeOutOnly )
					cb();
				else
					globalEvent.wait(t / 3.0, cb);
			}
		}
	}

	public function onCdbReload() {
	}

	public function load(path = "save.sav") {
		if ( !sys.FileSystem.exists(path) )
			return;
		var bytes = sys.io.File.getBytes(path);
		state = hxbit.Serializer.load(bytes, st.GameState, function(o) {
			var s = Std.downcast(o, st.State);
			s.init();
		});
	}

	public function save(path = "save.sav") {
		var res = hxbit.Serializer.save(state);
		sys.io.File.saveBytes(path, res);
	}
}