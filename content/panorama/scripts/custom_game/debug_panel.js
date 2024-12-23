// спавн бота >>

const spawnButton = $("#spawn_bot_button")
const spawnSelect_menu = $("#spawn_hero_select")

spawnSelect_menu.style.visibility = "collapse";
spawnButton.SetPanelEvent("onactivate", function() {
    if (spawnSelect_menu.style.visibility === "visible") {
        spawnSelect_menu.style.visibility = "collapse";
        toggleMenuButton.style.marginLeft = "285px";
    }
    else {
        spawnSelect_menu.style.visibility = "visible";
        toggleMenuButton.style.marginLeft = "635px";
    }
    if (giveSelect_menu.style.visibility === "visible") {
        giveSelect_menu.style.visibility = "collapse"
    }
	
})

function SpawnHero(heroName) {
    if (!heroName) {
        $.Msg("No hero name provided!");
        return;
    }

    var playerID = Game.GetLocalPlayerID();
    GameEvents.SendCustomGameEventToServer("spawn_bot_admin", { hero: heroName, id: playerID });
    $.Msg("Requested spawn for hero: " + heroName);
}

// выдать предмет >>

const giveButton = $("#give_item_button")
const giveSelect_menu = $("#give_item_select")

giveSelect_menu.style.visibility = "collapse";

giveButton.SetPanelEvent("onactivate", function() {
    if (giveSelect_menu.style.visibility === "visible") {
        giveSelect_menu.style.visibility = "collapse";
        toggleMenuButton.style.marginLeft = "285px";
    }
    else {
        giveSelect_menu.style.visibility = "visible";
        toggleMenuButton.style.marginLeft = "605px";
    }
    if (spawnSelect_menu.style.visibility === "visible") {
        spawnSelect_menu.style.visibility = "collapse";
    }
    
})

function GiveItem(itemName) {
    if (!itemName) {
        $.Msg("No item name provided!");
        return;
    }

    var entities = Players.GetSelectedEntities( 0 );
    $.Msg( "Entities = " + entities );

    var numEntities = Object.keys( entities ).length;
    $.Msg( "Num entities = " + numEntities );

    var playerID = Game.GetLocalPlayerID();
    GameEvents.SendCustomGameEventToServer("give_item_admin", { item: itemName, ent: entities });
    $.Msg("Requested item: " + itemName);
}

// режим WTF >>

function WTF_Toggle() {
    GameEvents.SendCustomGameEventToServer("wtf_mode_admin", {});
   
}

const wtfButton = $("#wtf_mode_button")
wtfButton.style.border = "2px solid white";
wtfButton.SetPanelEvent("onactivate", function() {
    WTF_Toggle();
    $.Msg(wtfButton.style.border);
    if (wtfButton.style.border == "solidsolidsolidsolid/ 2.0px 2.0px 2.0px 2.0px / #FFFFFFFF #FFFFFFFF #FFFFFFFF #FFFFFFFF ") {
        wtfButton.style.border = "2px solid black";
        $.Msg("NE ZHOPA");
    } else if (wtfButton.style.border == "solidsolidsolidsolid/ 2.0px 2.0px 2.0px 2.0px / #000000FF #000000FF #000000FF #000000FF ") {
        $.Msg("ZHOPA");
        wtfButton.style.border = "2px solid white";
    }
})

// Обновить скиллы >>

function Refresh() {
    var playerID = Game.GetLocalPlayerID();
    GameEvents.SendCustomGameEventToServer("refresh_admin", { id: playerID });
    $.Msg("Requested refresh for player " + playerID);
}

// Повысить уровень >>

function LvlUp(level) {
    var entities = Players.GetSelectedEntities( 0 );
    $.Msg( "Entities = " + entities );

    var numEntities = Object.keys( entities ).length;
    $.Msg( "Num entities = " + numEntities );

    var playerID = Game.GetLocalPlayerID();
    GameEvents.SendCustomGameEventToServer("lvlup_admin", { lvl: level, ent: entities });
    $.Msg("Requested lvlup for player " + playerID);
}

// Выдать золото >>

const networthIcon = $("#gold-icon")

function GiveGold(amt) {
    var entities = Players.GetSelectedEntities( 0 );
    $.Msg( "Entities = " + entities );

    GameEvents.SendCustomGameEventToServer("gold_admin", { amout: amt, ent: entities });
    $.Msg("Requested " + amt + " gold for entities: " + entities);
}

//networthIcon.SetImage("s2r://panorama/images/hud/reborn/gold_small_psd.vtex");

// Закрыть / Открыть панель >>
const rootPanel = $.GetContextPanel().FindChildTraverse("buttons_panel");
const toggleMenuButton = $("#close_menu_button")
const toggleMenuText = toggleMenuButton.FindChildTraverse("close_menu_button_text"); 
toggleMenuButton.SetPanelEvent("onactivate", function() {
    if (rootPanel.style.visibility === "visible") {
        rootPanel.style.visibility = "collapse";
        giveSelect_menu.style.visibility = "collapse";
        spawnSelect_menu.style.visibility = "collapse";
        toggleMenuButton.style.marginLeft = "5px";
        toggleMenuText.text = ">"
    }
    else {
        rootPanel.style.visibility = "visible";
        toggleMenuButton.style.marginLeft = "285px";
        toggleMenuText.text = "<"
    }
})