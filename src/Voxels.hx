class Voxels {

    public static function getVoxelSize() {
        return Const.get(VoxelSize);
    }
    
    public var size : h3d.col.IPoint;

    var values : haxe.io.Bytes;
    var minPos : h3d.col.Point;
    var room : ent.Room;
    var debugObj : h3d.scene.Object;

    public function new(room : ent.Room) {
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
        
        return new h3d.col.IPoint(ifloor(pos.x), ifloor(pos.y), hxd.Math.iclamp(ifloor(pos.z), 0, size.z - 1));
    }

    public function get(pos : h3d.col.Point) {
        return getByCoord(getVoxelCoord(pos));
    }

    public function getByCoord(coord : h3d.col.IPoint) {
        return getById(getVoxelId(coord.x, coord.y, coord.z));
    }

    public function getById(id : Int) {
        return values.get(id);
    }

    public function collideValue(v : Int, mode : Game.TimeMode) {
        if ( !isValid(v) )
            return false;
        var v = v & ((1 << 7) - 1);
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

    public function isValid(voxelValue : Int) {
        return (voxelValue & (1 << 7)) != 0;
    }

    public function isInside(pos : h3d.col.Point) {
        var relPos = pos.sub(minPos);
        if ( relPos.x < 0.0 || relPos.y < 0.0 )
            return false;
        if ( relPos.x > (size.x-1) * getVoxelSize() || relPos.y > (size.y-1) * getVoxelSize() )
            return false;
        // return true;
        return isValid(get(pos));
    }

    public inline function getVoxelId(x : Int, y : Int, z : Int) {
        return x + y * size.x + z * size.x * size.y;
    }

    public function getPos(ipos : h3d.col.IPoint) {
        return new h3d.col.Point(minPos.x + (ipos.x+0.5) * getVoxelSize(), minPos.y + (ipos.y+0.5) * getVoxelSize(), minPos.z + (ipos.z+0.5) * getVoxelSize());
    }

    public function set(voxelId : Int, value : Int) {
        values.set(voxelId, value);
    }

    function build(room : ent.Room) {
        for ( n in room.navmeshes )
            n.fillVoxel(this);
        for ( i in 0...size.x ) {
            for ( j in 0...size.y ) {
                var isValid = false;
                for ( k in 0...size.z ) {
                    var curId = getVoxelId(i,j,k);
                    var curValue = getById(curId);
                    if ( curValue != 0 )
                        isValid = true;
                    if ( isValid ) {
                        var newValue = curValue | (1 << 7);
                        set(curId, newValue);
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
                    var voxelMode = Game.TimeMode.createByIndex(value & 7);
                    var alpha = 1.0;
                    switch(voxelMode) {
                    case None:
                        shader.color.set(0.0, 0.0, 0.0, 0.0);
                    case Past:
                        shader.color.set(0.0, 1.0, 1.0, alpha);
                    case Present:
                        shader.color.set(0.0, 0.0 , 1.0,alpha);
                    case Common:
                        shader.color.set(0.0, 1.0, 1.0, alpha);
                    default:
                        shader.color.set(1.0, 0.0, 1.0, alpha);  
                    }
                    if ( value & 7 == 0 )
                        shader.color.set(1.0, 0.0, 0.0, alpha);

                    batch.worldPosition.initScale(getVoxelSize(), getVoxelSize(), getVoxelSize());
                    batch.worldPosition.translate(pos.x, pos.y, pos.z);
                    batch.emitInstance();
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