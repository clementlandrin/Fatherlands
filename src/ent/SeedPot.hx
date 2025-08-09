package ent;

class SeedPot extends Chest {

    function getSeed() {
        return item != null ? cast(item, ent.Seed) : null;
    }

    override function filterItem(i : ent.Entity) {
        return Std.isOfType(i, Seed);
    }
    
    override function getTriggerText() {
        return "Press F to plant.";
    }

    override function update(dt : Float) {
        super.update(dt);

        var s = getSeed();
        if ( s != null ) {
            s.grow(dt);
        }
    }
}