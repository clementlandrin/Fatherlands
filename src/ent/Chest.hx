package ent;

class Chest extends Entity {

    var item : ent.Entity;

    function filterItem(i : ent.Entity) {
        return true;
    }

    override function hasSpecificInteraction() {
        return game.player.item != null && filterItem(game.player.item);
    }

    override function getTriggerText() {
        return "Press F to drop.";
    }

    override function onTrigger() {
        super.onTrigger();
        item = game.player.item;
        game.player.dropItem();
    }

    override function update(dt : Float) {
        super.update(dt);

        if ( item != null ) {
            item.setPos(getPos());
            // player picked item
            if ( game.player.item == item )
                item = null;
        }
    }
}