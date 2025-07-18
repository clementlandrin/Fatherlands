package ent;

class Voxels {

    public static function getVoxelSize() {
        return Const.get(VoxelSize);
    }
    
    public var size : h3d.col.IPoint;

    var values : haxe.io.Bytes;
    var minPos : h3d.col.Point;
    var room : Room;
    var debugObj : h3d.scene.Object;

    public function new(room : Room) {
        this.room = room;
        var bounds = new h3d.col.Bounds();
        for ( n in room.navmeshes ) {
            bounds.add(n.bounds);
        }

        inline function isize(v : Float) {
            return hxd.Math.imax(iceil(v),1);
        }
        size = new h3d.col.IPoint(isize(bounds.xSize), isize(bounds.ySize), isize(bounds.zSize));
        minPos = bounds.getMin();
        var voxelCount = size.x * size.y * size.z;
        values = haxe.io.Bytes.alloc(voxelCount);
        build(room);
        if ( Main.PREFS.voxelDebug )
            debug();
    }

    inline function iceil(v : Float) {
        return Math.ceil(v / getVoxelSize());
    }

    inline function ifloor(v : Float) {
        return Math.floor(v / getVoxelSize());
    }

    public function getVoxelCoord(pos : h3d.col.Point) {
        var pos = pos.clone();
        pos = pos.sub(minPos);
        
        return new h3d.col.IPoint(ifloor(pos.x), ifloor(pos.y), ifloor(pos.z));
    }

    public function get(pos : h3d.col.Point) {
        return getByCoord(getVoxelCoord(pos));
    }

    public function getByCoord(coord : h3d.col.IPoint) {
        return values.get(getVoxelId(coord));
    }

    public function collideValue(v : Int, mode : Game.TimeMode) {
        var voxelMode = Game.TimeMode.createByIndex(v);
        switch ( voxelMode ) {
        case None:
            return false;
        case Present:
            return mode == Present;
        case Past:
            return mode == Past;
        case Common:
            return true;
        }
    }

    public function isInside(pos : h2d.col.Point) {
        var relPos = pos.sub(minPos.to2D());
        if ( relPos.x < 0.0 || relPos.y < 0.0 )
            return false;
        if ( relPos.x > size.x * getVoxelSize() || relPos.y > size.y * getVoxelSize() )
            return false;
        return true;
    }

    public function getVoxelId(coord : h3d.col.IPoint) {
        return coord.x + coord.y * size.x + coord.z * size.x * size.y;
    }

    public function getPos(ipos : h3d.col.IPoint) {
        return new h3d.col.Point(minPos.x + (ipos.x+0.5) * getVoxelSize(), minPos.y + (ipos.y+0.5) * getVoxelSize(), minPos.z + (ipos.z+0.5) * getVoxelSize());
    }

    function build(room : Room) {
        for ( i in 0...size.x ) {
            for ( j in 0...size.y ) {
                for ( k in 0...size.z ) {
                    var pos = getPos(new h3d.col.IPoint(i,j,k));
                    for ( n in room.navmeshes ) {
                        var voxelId = getVoxelId(new h3d.col.IPoint(i,j,k));
                        var voxelMode = n.containsTime(pos);
                        if ( voxelMode != None ) {
                            var curValue = values.get(voxelId);
                            if ( Game.TimeMode.createByIndex(curValue) != Common ) {
                                var newValue = curValue | voxelMode.getIndex();
                                values.set(voxelId, newValue);
                            }
                            
                        }
                        
                    }
                }
            }
        }
    }

    public function debug() {
        removeDebug();
        debugObj = new h3d.scene.Object();
        @:privateAccess room.game.s3d.addChild(debugObj);

        var batch = new h3d.scene.MeshBatch(h3d.prim.Cube.defaultUnitCube(), null, debugObj);
        batch.worldPosition = new h3d.Matrix();
        var shader = new h3d.shader.ColorMult();
        for ( m in batch.getMaterials() ) {
            m.mainPass.setPassName("afterTonemapping");
            m.shadows = false;
            m.mainPass.setBlendMode(Alpha);
            m.mainPass.addShader(shader);
            m.mainPass.wireframe = true;
        }
        batch.begin();
        for ( i in 0...size.x ) {
            for ( j in 0...size.y ) {
                for ( k in 0...size.z ) {
                    var pos = getPos(new h3d.col.IPoint(i,j,k));
                    var value = values.get(i + j * size.x + k * size.x * size.y);
                    var voxelMode = Game.TimeMode.createByIndex(value);
                    if ( voxelMode != None ) {
                        var alpha = 1.0;
                        switch(voxelMode) {
                        case None:
                            throw "assert";
                        case Past:
                            shader.color.set(1.0, 0.0, 0.0, alpha);
                        case Present:
                            shader.color.set(0.0, 1.0 , 0.0,alpha);
                        case Common:
                            shader.color.set(0.0, 0.0, 1.0, alpha);
                        default:
                            shader.color.set(1.0, 0.0, 1.0, alpha);  
                        }

                        batch.worldPosition.initScale(getVoxelSize(), getVoxelSize(), getVoxelSize());
                        batch.worldPosition.translate(pos.x, pos.y, pos.z);
                        batch.emitInstance();
                    }
                }
            }
        }
    }

    public function removeDebug() {
        if ( debugObj != null )
            debugObj.remove();
        debugObj = null;
    }

    public function dispose() {
        if ( debugObj != null )
            debugObj.remove();
        debugObj = null;
        values = null;
    }
}