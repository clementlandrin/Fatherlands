package lib;

class Macros {

	#if macro
	public static function init() {
		domkit.Macros.registerComponentsPath("$");
		domkit.Macros.registerComponentsPath("ui.$");
		domkit.Macros.registerComponentsPath("ui.comp.$");
	}
	#end
}
