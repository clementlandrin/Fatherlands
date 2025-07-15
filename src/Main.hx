class Prefs {
	public var DEBUG_VOXEL = false;
	
	public function new() {

	}
}

class Main extends hxd.App {

	public static var PREFS : Prefs = new Prefs();
 
	static function main() {

		hxd.res.Resource.LIVE_UPDATE = true;
		hxd.Res.initLocal();

		gfx.MaterialSetup.set();

		Data.load(hxd.Res.data.entry.getText());
		hxd.Res.data.watch(function() {
			Data.load(hxd.Res.data.entry.getText(), true);
			if( Game.inst != null ) @:privateAccess Game.inst.onCdbReload();
		});

		new Game();
	}

	public static function reload() {
		Game.inst.dispose();
		new Game();
	}
}