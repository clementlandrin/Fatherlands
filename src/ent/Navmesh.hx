package ent;

class Navmesh extends Entity {

    public var bounds : h3d.col.Bounds;
    public var navmeshMode : Game.TimeMode;
    
    var polygon : hrt.prefab.l3d.Polygon;
    var box : hrt.prefab.l3d.Box;
    var invAbsPos : h3d.Matrix;
    var polygonBounds : h2d.col.Polygon;
    var zScale : Float;
    var boxUnitBounds : h3d.col.Bounds;

    public function new() {
        super();
		game.curRoom.navmeshes.push(this);
    }

    override function setObject(obj:h3d.scene.Object) {
        super.setObject(obj);
        bounds = obj.getBounds();
        invAbsPos = obj.getAbsPos().getInverse();
        zScale = obj.getAbsPos().getScale().z;
    }

    public function setPolygon(polygon : hrt.prefab.l3d.Polygon) {
        this.polygon = polygon;
        polygonBounds = polygon.getPolygonBounds();
    }

    public function setBox(box : hrt.prefab.l3d.Box) {
        this.box = box;
        boxUnitBounds = createUnitBounds();
    }

    static var tmp2d : h2d.col.Point;
    public function contains(p : h3d.col.Point) {
        var center = new h3d.col.Point(x,y,z);

        var localPos = p.transformed(invAbsPos);

        if ( polygon != null ) {
            switch(polygon.shape) {
            case Sphere(_,_):
                return center.distanceSq(p) < 1.0;
            case Quad(_):
                tmp2d.load(localPos.to2D());
                return polygonBounds.contains(tmp2d) && Math.abs(localPos.z * zScale) < ent.Voxels.getVoxelSize();
            default:
                throw "";
            }
        } else if ( box != null ) {
            return boxUnitBounds.contains(localPos);
        } else {
            throw "navmesh unsupported shape";
            return false;
        }
    }

    public function fillVoxel(voxels : Voxels) {
        var voxelStart = voxels.getVoxelCoord(bounds.getMin());
        var voxelEnd = voxels.getVoxelCoord(bounds.getMax());
        var worldStart = voxels.getPos(voxelStart);
        var voxelDim = voxelEnd.sub(voxelStart);
        voxelDim.x = hxd.Math.imax(voxelDim.x, 1);
        voxelDim.y = hxd.Math.imax(voxelDim.y, 1);
        voxelDim.z = hxd.Math.imax(voxelDim.z, 1);

        var voxelSize = Voxels.getVoxelSize();
        var curVoxel = new h3d.col.IPoint();
        var curWorld = new h3d.Vector();
        for ( i in 0...voxelDim.x ) {
            for ( j in 0...voxelDim.y ) {
                for ( k in 0...voxelDim.z ) {
                    curWorld.load(worldStart);
                    curWorld.x += i * voxelSize;
                    curWorld.y += j * voxelSize;
                    curWorld.z += k * voxelSize;
                    var curI = voxelStart.x + i;
                    var curJ = voxelStart.y + j;
                    var curK = voxelStart.z + k;
                    curVoxel.set(curI, curJ, curK);
                    // if ( curI < 0 || curI >= voxels.size.x || curJ < 0 || curJ >= voxels.size.y || curK < 0 || curK >= voxels.size.z )
                    //     throw "assert";

                    if ( contains(curWorld) ) {
                        var voxelId = voxels.getVoxelId(curI,curJ,curK);
                        var curValue = voxels.getById(voxelId);
                        if ( Game.TimeMode.createByIndex(curValue) != Common ) {
                            var newValue = curValue | navmeshMode.getIndex();
                            voxels.set(voxelId, newValue);
                        }
                        
                    }
                }
            }
        }
    }
}