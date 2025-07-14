class Prefs {
	public var DEBUG_VOXEL = false;
	
	public function new() {

	}
}

class Main extends hxd.App {

	public static var PREFS : Prefs = new Prefs();
 
	static function main() {

		hxd.Res.initLocal();

		gfx.MaterialSetup.set();

		Data.load(hxd.Res.data.entry.getText());
		new Game();
	}

	public static function reload() {
		Game.inst.dispose();
		new Game();
	}
}