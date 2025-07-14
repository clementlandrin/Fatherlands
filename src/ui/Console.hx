package ui;

class Console {
	var console : h2d.Console;

	public function new() {
		var font = hxd.Res.monda_regular.toSdfFont(12, h2d.Font.SDFChannel.MultiChannel, 0.45, 0.2);
		console = new h2d.Console(font, Game.inst.s2d);
		initCommands();
	}

	function initCommands() {
		console.add("debug", function() {
			var r = cast(Game.inst.s3d.renderer, gfx.Renderer);
			r.displayMode = r.displayMode == Debug ? Pbr : Debug;
		});

		console.add("voxels", function() {
			Main.PREFS.DEBUG_VOXEL = !Main.PREFS.DEBUG_VOXEL;
			if ( Main.PREFS.DEBUG_VOXEL )
				Game.inst.curRoom.voxels.debug();
			else
				Game.inst.curRoom.voxels.removeDebug();
		});
	}
}