package ent;

class SeedPot extends Entity {

    var seed : Seed = null;

    override function hasSpecificInteraction() {
        return game.player.item != null && Std.isOfType(game.player.item, Seed);
    }

    override function getTriggerText() {
        return "Press F to plant.";
    }

    override function onTrigger() {
        super.onTrigger();
        seed = cast(game.player.item, Seed);
        game.player.dropItem();
    }

    override function update(dt : Float) {
        super.update(dt);

        if ( seed != null ) {
            seed.setPos(getPos());
            seed.grow(dt);
            // player picked seed
            if ( game.player.item == seed )
                seed = null;
        }
    }
}