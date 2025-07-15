package ent;

class Player extends Entity {

	var temporalVisual : h3d.scene.Object;
	var temporalRadius : Float = 0.0;
	var sphereActive : Bool = false;
	var skin : h3d.scene.Skin;
	var curLadder : ent.Ladder;
	var idle = false;
	var sequence : Sequence;

	override function start() {
		super.start();
		
		var chara = new h3d.scene.Object(game.s3d);
		hxd.Res.chara.chara.load().make(chara);
		skin = chara.find(o -> Std.downcast(o, h3d.scene.Skin));
		setObject(chara);
		for ( m in obj.getMaterials() )
			m.color.setColor(0xFF0000);

		var temporalPrim = new h3d.prim.Sphere(1.0, 64, 60);
		temporalVisual = new h3d.scene.Mesh(temporalPrim, null, game.s3d);
		for ( m in temporalVisual.getMaterials() ) {
			m.color.set(0.0, 1.0, 0.0, 0.2);
			m.mainPass.setBlendMode(Alpha);
			m.mainPass.setPassName("afterTonemapping");
			m.mainPass.depthWrite = false;
			m.shadows = false;
		}
		temporalVisual.followPositionOnly = true;
		temporalVisual.follow = chara.find(o -> o.name == "sphereCenter" ? o : null);
	}
	
	public function getTemporalRadius() {
		return temporalRadius;
	}

	public function getTemporalPos() {
		return temporalVisual.getAbsPos().getPosition();
	}

	override function update(dt : Float) {
		super.update(dt);

		updateSphere(dt);

		updateMovement(dt);
	}

	function updateSphere(dt : Float) {
		var sphereIncrease = dt * Const.get(SphereMaxRadius) / Const.get(SphereTransitionDuration);
		if ( hxd.Key.isPressed(hxd.Key.SPACE) ) {
			sphereActive = !sphereActive;
		}
		if ( sphereActive ) {
			temporalRadius += sphereIncrease;
		} else {
			temporalRadius -= sphereIncrease;
		}
		temporalRadius = hxd.Math.clamp(temporalRadius, 0.0, Const.get(SphereMaxRadius));

		temporalVisual.setScale(temporalRadius);
	}

	function updateMovement(dt : Float) {
		if ( sequence != null ) {
			if ( sequence.update(dt) )
				sequence = null;
			return;
		}
		if ( isClimbing() ) {
			updateLadderMovement(dt);
			return;
		}

		var speed = Const.get(PlayerSpeed);
		var displacement = new h2d.col.Point(0.0,0.0);
		if ( hxd.Key.isDown(hxd.Key.LEFT) || hxd.Key.isDown(hxd.Key.Q) ) {
			displacement.x = -dt * speed;
		}
		if ( hxd.Key.isDown(hxd.Key.RIGHT) || hxd.Key.isDown(hxd.Key.D) ) {
			displacement.x = dt * speed;
		}
		if ( hxd.Key.isDown(hxd.Key.UP) || hxd.Key.isDown(hxd.Key.Z) ) {
			displacement.y = dt * speed;
		}
		if ( hxd.Key.isDown(hxd.Key.DOWN) || hxd.Key.isDown(hxd.Key.S) ) {
			displacement.y = -dt * speed;
		}
		
		var camera = game.s3d.camera;
		var front = camera.getForward();
		front.z = 0.0;
		front.normalize();
		var right = camera.getRight();
		right.z = 0.0;
		right.normalize();

		var move = displacement.y * front + displacement.x * right;
		var newPos = new h2d.col.Point(x + move.x, y + move.y);

		if ( move.length() > 0.0 ) {
			var quat = new h3d.Quat();
			quat.initDirection(move.normalized(), new h3d.Vector(0.0, 0.0, 1.0));
			obj.setRotationQuat(quat);

			if ( idle ) {
				idle = false;
				var anim = game.modelCache.loadAnimation(hxd.Res.chara.Anim.Anim_Walk);
				skin.switchToAnimation(anim.createInstance(skin));
			}
		} else {
			if ( !idle ) {
				idle = true;
				var anim = game.modelCache.loadAnimation(hxd.Res.chara.Anim.Anim_Idle);
				skin.switchToAnimation(anim.createInstance(skin));
			}
		}
		
		if ( game.curRoom != null ) {
			var voxels = game.curRoom.voxels;
			if ( voxels.isInside(newPos) ) {
				var stepDist = Voxels.getVoxelSize() / Math.sqrt(2.0);
				var steps = hxd.Math.imax(Math.ceil(move.length() / stepDist), 1);
				var moveStep = move.scaled(1.0 / steps);

				var curPos = new h3d.col.Point(x,y,z);
				var curVoxelCoord = voxels.getVoxelCoord(curPos);
				var speedFall = 1.0;
				var fallDist = dt * speedFall;
				var fallDistStep = fallDist / steps;
				var fallVoxelStep = Math.ceil(fallDistStep / Voxels.getVoxelSize());
				for ( s in 0...steps ) {
					var beforeStepPos = curPos.clone();
					curPos.x += moveStep.x;
					curPos.y += moveStep.y;
					curVoxelCoord = voxels.getVoxelCoord(curPos);
					var blocked = false;

					// fall
					if ( !voxels.collideValue(voxels.getByCoord(curVoxelCoord), getTimeMode())  ) {
						for ( i in 0...fallVoxelStep ) {
							curVoxelCoord.z--;
							if ( voxels.collideValue(voxels.getByCoord(curVoxelCoord), getTimeMode()) )
								break;
						}
					}
					//climb
					else {
						var height = Voxels.getVoxelSize();
						var startVoxelCoord = curVoxelCoord.clone();
						var maxHeight = Const.get(MaxClimbHeight);
						while ( curVoxelCoord.z < voxels.size.z ) {
							var upCoord = curVoxelCoord.clone();
							upCoord.z++;
							if ( !voxels.collideValue(voxels.getByCoord(upCoord), getTimeMode()) )
								break;
							if ( height > maxHeight ) {
								blocked = true;
								break;
							}
							height += Voxels.getVoxelSize();
							curVoxelCoord.load(upCoord);
						}
					}
					if ( blocked ) {
						curPos = beforeStepPos;
						break;
					}

					curPos.z = voxels.getPos(curVoxelCoord).z;
				}

				x = curPos.x;
				y = curPos.y;
				z = curPos.z;
			}
		}
	}

	function moveTo(target : h3d.col.Point, dt : Float) {
		var curPos = new h3d.col.Point(x,y,z);
		var diff = target.sub(curPos);
		var dir = diff.normalized();
		var moveDist = dt * Const.get(PlayerSpeed);
		if ( moveDist > diff.length() ) {
			x = target.x;
			y = target.y;
			z = target.z;
			return true;
		}
		curPos = curPos.add(dir.scaled(moveDist));
		x = curPos.x;
		y = curPos.y;
		z = curPos.z;
		return false;
	}

	function updateLadderMovement(dt : Float) {
		if ( hxd.Key.isDown(hxd.Key.Z) || hxd.Key.isDown(hxd.Key.UP) ) {
			curLadder.tryLeaveTop();
			z += dt * Const.get(ClimbSpeed);
		}
		if ( hxd.Key.isDown(hxd.Key.S) || hxd.Key.isDown(hxd.Key.DOWN) ) {
			curLadder.tryLeaveBottom();
			z -= dt * Const.get(ClimbSpeed);
		}
	}

	public function getTimeMode() : Game.TimeMode {
		return sphereActive ? Past : Present; 
	}

	public function enterLadder(l : ent.Ladder, to : h3d.col.Point) {
		curLadder = l;
		sequence = new Sequence(function (dt : Float) {
			return moveTo(to, dt);
		});
	}

	public function leaveLadder(to : h3d.col.Point) {
		if ( curLadder == null )
			throw "assert";
		var tmpLadder = curLadder;
		sequence = new Sequence(function (dt : Float) {
			var topPos = tmpLadder.top.getAbsPos().getPosition();
			var reached = moveTo(topPos, dt);
			if ( reached ) {
				sequence = new Sequence(function (dt : Float) {
					return moveTo(to, dt);
				});
			}
			return true;
		});
		curLadder = null;
	}

	public function isClimbing(?l : ent.Ladder) {
		if ( l == null )
			return curLadder != null;
		return curLadder == l;
	}
}