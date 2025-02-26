let isAllowed = false

const mouse_over = $.GetContextPanel().FindChildTraverse("mouse_over")
const spawnSelect_menu = $("#spawn_hero_select")
const giveSelect_menu = $("#give_item_select")

mouse_over.SetPanelEvent('onmouseover', function() {
    if (isAllowed) {
        ShowDebugPanel()
    }
});

mouse_over.SetPanelEvent('onmouseout', function() {
    if (isAllowed) {
        HideDebugPanel()
        $.Schedule(0.1, function (){   
            if (giveSelect_menu.style.visibility === "visible") {
                giveSelect_menu.style.visibility = "collapse";
                mouse_over.style.width = "46%";
            }
            if (spawnSelect_menu && spawnSelect_menu.style.visibility === "visible") {
                spawnSelect_menu.style.visibility = "collapse";
                mouse_over.style.width = "46%";
            }
        })
    }
});


// спавн бота >>

const spawnButton = $("#spawn_bot_button")

spawnSelect_menu.style.visibility = "collapse";
spawnButton.SetPanelEvent("onactivate", function() {
    if (spawnSelect_menu && spawnSelect_menu.style.visibility === "visible") {
        spawnSelect_menu.style.visibility = "collapse";
        mouse_over.style.width = "46%";
    }
    else {
        spawnSelect_menu.style.visibility = "visible";
        mouse_over.style.width = "95%";
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

giveSelect_menu.style.visibility = "collapse";

giveButton.SetPanelEvent("onactivate", function() {
    if (giveSelect_menu.style.visibility === "visible") {
        giveSelect_menu.style.visibility = "collapse";
        mouse_over.style.width = "46%";
    }
    else {
        giveSelect_menu.style.visibility = "visible";
        mouse_over.style.width = "95%";
    }
    if (spawnSelect_menu.style.visibility === "visible") {
        spawnSelect_menu.style.visibility = "collapse";
        mouse_over.style.width = "46%";
    }
    
})

function GiveItem(itemName) {
    if (!itemName) {
        $.Msg("No item name provided!");
        return;
    }

    var playerID = Game.GetLocalPlayerID();

    var entities = Players.GetSelectedEntities( playerID );
    $.Msg( "Entities = " + entities );

    var numEntities = Object.keys( entities ).length;
    $.Msg( "Num entities = " + numEntities );

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
    var playerID = Game.GetLocalPlayerID();

    var entities = Players.GetSelectedEntities( playerID );
    $.Msg( "Entities = " + entities );

    var numEntities = Object.keys( entities ).length;
    $.Msg( "Num entities = " + numEntities );

    GameEvents.SendCustomGameEventToServer("lvlup_admin", { lvl: level, ent: entities });
    $.Msg("Requested lvlup for player " + playerID);
}

// Выдать золото >>

const networthIcon = $("#gold-icon")

function GiveGold(amt) {
    var playerID = Game.GetLocalPlayerID();

    var entities = Players.GetSelectedEntities( playerID );
    $.Msg( "Entities = " + entities );

    GameEvents.SendCustomGameEventToServer("gold_admin", { amout: amt, ent: entities });
    $.Msg("Requested " + amt + " gold for entities: " + entities);
}

//networthIcon.SetImage("s2r://panorama/images/hud/reborn/gold_small_psd.vtex");

// закрыть / открыть панель >>
//const rootPanel = $.GetContextPanel().FindChildTraverse("buttons_panel");
//const toggleMenuButton = $("#close_menu_button")
//const toggleMenuText = toggleMenuButton.FindChildTraverse("close_menu_button_text"); 
//toggleMenuButton.SetPanelEvent("onactivate", function() {
//    if (rootPanel && rootPanel.BHasClass("DebugPanel_show")) {
//        HideDebugPanel()
//        toggleMenuText.text = ">"
//    }
//    else {
//        ShowDebugPanel()
//        toggleMenuText.text = "<"
//    }
//})

function checkPlayerID() {

    //const id = Game.GetLocalPlayerID();

    GameEvents.SendCustomGameEventToServer("admin_steamID", {}); // {playerID: id});

    checkPlayerID2()

}

GameEvents.Subscribe("admin_steamID", checkPlayerID2);

function checkPlayerID2(data) {

    if (data && data.allowedID) {

        var allowedSteamID = data.allowedID;
        var steamID = Game.GetLocalPlayerInfo().player_steamid
    
        var panel = $.GetContextPanel().FindChildInLayoutFile("debug_panel");
    
    
        if (panel) {
            if (steamID == allowedSteamID) {
                ShowDebugPanel()
                isAllowed = true
                $.Msg("+++ Admin Panel for player with #" + Game.GetLocalPlayerID() + " playerID")
            } else {
                HideDebugPanel()
            }
        }

    }
}

$.Schedule(5, checkPlayerID);

function ShowDebugPanel()
{
    let main = $.GetContextPanel().FindChildTraverse("debug_panel")

    if (main && main.BHasClass("DebugPanel_hidden"))
    {
        $.Msg("DebugPanel_hidden")
        main.RemoveClass("DebugPanel_hidden")
        main.RemoveClass("DebugPanel_hide")
        main.AddClass("DebugPanel_show")
    }
}

function ShowSelect()
{
    let main = $.GetContextPanel().FindChildTraverse("spawn_hero_select")

    if (main && main.BHasClass("Select_hidden"))
    {
        main.RemoveClass("Select_hidden")
        main.RemoveClass("Select_hide")
        main.AddClass("Select_show")
    }
}


function HideSelect()
{
    let main = $.GetContextPanel().FindChildTraverse("spawn_hero_select")

    if (main && main.BHasClass("Select_show"))
    {
        main.RemoveClass("Select_hidden")
        main.RemoveClass("Select_hide")
        main.AddClass("Select_show")
    }
}

function HideDebugPanel()
{

    let main = $.GetContextPanel().FindChildTraverse("debug_panel")
    if (main && main.BHasClass("DebugPanel_show"))
    {
        $.Msg("DebugPanel_show")
        main.RemoveClass("DebugPanel_show")
        main.AddClass("DebugPanel_hide")

        $.Schedule(0.1, function ()
        {   
            main.AddClass("DebugPanel_hidden")
        })
    }

}
$.Schedule(1.0, function ()
    { HideDebugPanel() })