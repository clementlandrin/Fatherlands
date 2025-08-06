package ui;

class Console {
	var console : h2d.Console;
	var game : Game;

	public function new() {
		game = Game.inst;
		var font = hxd.Res.monda_regular.toSdfFont(12, h2d.Font.SDFChannel.MultiChannel, 0.45, 0.2);
		console = new h2d.Console(font, game.s2d);
		initCommands();
	}

	function initCommands() {
		console.add("debug", function() {
			var r = cast(game.s3d.renderer, gfx.Renderer);
			r.displayMode = r.displayMode == Debug ? Pbr : Debug;
		});

		console.add("voxels", function() {
			Main.PREFS.voxelDebug = !Main.PREFS.voxelDebug;
			if ( Main.PREFS.voxelDebug )
				game.curRoom.voxels.debug();
			else
				game.curRoom.voxels.removeDebug();
			Main.savePrefs();
		});

		console.add("doors", function() {
			Main.PREFS.doorDebug = !Main.PREFS.doorDebug;
			Main.savePrefs();
		});

		console.add("memo", function() {
			Main.PREFS.memo = !Main.PREFS.memo;
			Main.savePrefs();
		});

		console.add("prof", function(arg:String) {
			// https://github.com/HaxeFoundation/hashlink/wiki/Profiler
			switch (arg) {
			case "start":
				hl.Gc.enable(false);
				hl.Profile.event(-7,"10000"); // setup
				hl.Profile.event(-3); // clear data
				hl.Profile.event(-5); // resume all
			case "stop":
				hl.Profile.event(-4); // pause all
			case "dump":
				hl.Profile.event(-6); // save dump
				if( Sys.command(".vscode\\post_profile.bat") != 0 )
					throw "Could not post process profile dump : missing profiler.hl compilation?";
				hl.Profile.event(-4); // pause all
				hl.Profile.event(-3); // clear data
				hl.Gc.enable(true);
			}
		});

		console.add("memprof", function(?cmd: String) {
			function start() {
				var tmp = hl.Profile.globalBits;
				tmp.set(Alloc);
				hl.Profile.globalBits = tmp;
				hl.Profile.reset();
			}
			function dump() {
				hl.Profile.dump("memprofSize.txt", true, false);
				hl.Profile.dump("memprofCount.txt", false, true);
			}
			if (cmd != null) {
				switch (cmd) {
				case "start":
					start();
				case "dump", "stop":
					dump();
				default:
					var time = Std.parseFloat(cmd);
					if (!Math.isNaN(time)) {
						start();
						haxe.Timer.delay(function() {
							dump();
						}, Math.round(time * 1000.0));
					}
				}
			}
		});
	}
}