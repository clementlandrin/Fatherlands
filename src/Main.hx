class Main extends hxd.App {

	public static var PREFS = hxd.Save.load({
		voxelDebug : false,
		doorDebug : false,
	});

	static function main() {
		#if hlsdl
		h3d.impl.GlDriver.enableComputeShaders();
		#end
		hxd.res.Resource.LIVE_UPDATE = true;
		hxd.Res.initLocal();

		var level = null;
		var args = Sys.args();
		while ( args.length > 0 ) {
			var arg = args.shift();
			switch(arg) {
			case "--level":
				level = args.shift();
			}
		}

		gfx.MaterialSetup.set();

		Data.load(hxd.Res.data.entry.getText());
		hxd.Res.data.watch(function() {
			Data.load(hxd.Res.data.entry.getText(), true);
			if( Game.inst != null ) @:privateAccess Game.inst.onCdbReload();
		});

		PREFS = hxd.Save.load(PREFS, "prefs", true);

		new Game(level);
	}

	public static function savePrefs() {
		try hxd.Save.save(PREFS, "prefs", true) catch( e : Dynamic ) { trace(e); };
	}

	public static function reload() {
		Game.inst.dispose();
		new Game();
	}
}