package ent;

class Navmesh extends Entity {

    public var bounds : h3d.col.Bounds;
    public var navmeshMode : Game.TimeMode;
    
    var polygon : hrt.prefab.l3d.Polygon;
    var box : hrt.prefab.l3d.Box;

    public function new() {
        super();
		game.curRoom.navmeshes.push(this);
    }

    override function setObject(obj:h3d.scene.Object) {
        super.setObject(obj);
        bounds = obj.getBounds();
    }

    public function setPolygon(polygon : hrt.prefab.l3d.Polygon) {
        this.polygon = polygon;
    }

    public function setBox(box : hrt.prefab.l3d.Box) {
        this.box = box;
    }

    public function containsTime(p : h3d.col.Point) : Game.TimeMode {
        return contains(p) ? navmeshMode : None;
    }

    public function contains(p : h3d.col.Point) {
        var center = new h3d.col.Point(x,y,z);

        var localPos = p.transformed(obj.getAbsPos().getInverse());

        if ( polygon != null ) {
            switch(polygon.shape) {
            case Sphere(_,_):
                return center.distance(p) < 1.0;
            case Quad(_):
                return polygon.getPolygonBounds().contains(localPos.to2D()) && Math.abs(localPos.z * obj.getAbsPos().getScale().z) < ent.Voxels.getVoxelSize();
            default:
                throw "";
            }
        } else if ( box != null ) {
            var boxBounds = createUnitBounds();
            return boxBounds.contains(localPos);
        } else {
            throw "";
            return false;
        }
        
    }
}