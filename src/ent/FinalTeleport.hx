package ent;

class FinalTeleport extends Teleport {

    var color : h3d.shader.ColorMult;

    override function start() {
        super.start();
        color = new h3d.shader.ColorMult();
    }

    override function isHub() {
        return false;
    }

    override function hasSpecificInteraction() {
        return color.amount >= 1.0;
    }

    override function update(dt : Float) {
        super.update(dt);

        for ( m in obj.getMaterials() ) {
            if ( m.mainPass.getShader(h3d.shader.ColorMult) == null )
                m.mainPass.addShader(color);
        }
        for ( e in game.entities ) {
            var s = Std.downcast(e, Seed);
            if ( s == null || !s.fullyGrown() )
                continue;
            var d = s.getPos().distance(getPos());
            var min = 1.0;
            var max = 4.0;
            var t = (max - d) / (max - min);
            t = hxd.Math.clamp(t);
            if ( t > 0.0 ) {
                color.color.setColor(s.inf.color);
                color.amount = t;
                return;
            }
        }
        color.amount = 0.0;
    }
}