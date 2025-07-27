
class CameraController extends h3d.scene.Object {

    var camera : h3d.Camera;
    var game : Game;
    var startCamZ : Float;
    var startPlayerZ : Float;

    public function new() {
        game = Game.inst;
        super(game.s3d);

        camera = game.s3d.camera;
		camera.orthoBounds = new h3d.col.Bounds();
    }

    override function sync(ctx : h3d.scene.RenderContext) {
        super.sync(ctx);

        var curRoom = game.curRoom;
        if ( curRoom != null && curRoom.camera == null )
			defaultCamera();

		if ( curRoom != null && curRoom.inf?.camFollowZ ) {
			camera.target = new h3d.col.Point(curRoom.x, curRoom.y, game.player.z);
            camera.pos.z = startCamZ + (game.player.z - startPlayerZ);
		}

		var Y = camera.orthoBounds.xMax / camera.screenRatio;
		camera.orthoBounds.yMax = Y;
		camera.orthoBounds.yMin = -Y;
    }

    public function enteredRoom(r : ent.Room) {
        startCamZ = camera.pos.z;
        startPlayerZ = game.player.z;
    }

    function defaultCamera() {
		camera.target = new h3d.col.Point(game.curRoom.x, game.curRoom.y, game.curRoom.z);
		camera.pos.x = Const.get(DefaultCameraX);
		camera.pos.y = Const.get(DefaultCameraY);
		camera.pos.z = Const.get(DefaultCameraZ);
		var X = Const.get(DefaultCameraWidth) * 0.5;
		var Z = Const.get(DefaultCameraDepth) * 0.5;
		camera.orthoBounds.xMax = X;
		camera.orthoBounds.xMin = -X;
		camera.orthoBounds.zMax = Z;
		camera.orthoBounds.zMin = -Z;
	}
}