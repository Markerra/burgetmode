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
            HideSelect("spawn_hero_select");
            spawnButton.state = 0;
            HideSelect("give_item_select");
            spawnButton.state = 0;
        })
    }
});


// спавн бота >>

const spawnButton = $("#spawn_bot_button")
spawnButton.state = 0

const giveButton = $("#give_item_button")
giveButton.state = 0

HideSelect("spawn_hero_select")
spawnButton.SetPanelEvent("onactivate", function() {

    if (spawnButton.state === 0) {
        HideSelect("give_item_select");
        giveButton.state = 0;
        mouse_over.style.width = "46%";

        ShowSelect("spawn_hero_select");
        spawnButton.state = 1;
        mouse_over.style.width = "95%";
    }
    else {
        HideSelect("spawn_hero_select");
        spawnButton.state = 0;
        mouse_over.style.width = "46%";
    }
})

function SpawnHero(heroName) {
    if (!heroName) {
        $.Msg("No hero name provided!");
        return;
    }

    var playerID = Game.GetLocalPlayerID();
    GameEvents.SendCustomGameEventToServer("spawn_bot_admin", { hero: heroName, id: playerID });
    Game.EmitSound("General.ButtonClick");
    $.Msg("Requested spawn for hero: " + heroName);
}

// выдать предмет >>

HideSelect("give_item_select");
giveButton.SetPanelEvent("onactivate", function() {
    HideSelect("spawn_hero_select");

    if (giveButton.state === 0) {
        HideSelect("spawn_hero_select");
        spawnButton.state = 0;
        mouse_over.style.width = "46%";
        
        ShowSelect("give_item_select");
        giveButton.state = 1;
        mouse_over.style.width = "95%";
    }
    else {
        HideSelect("give_item_select");
        giveButton.state = 0;
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

    Game.EmitSound("General.ButtonClick");
}

// режим WTF >>

function WTF_Toggle() {
    GameEvents.SendCustomGameEventToServer("wtf_mode_admin", {});
    Game.EmitSound("General.ButtonClick");
}

const wtfButton = $("#wtf_mode_button")
wtfButton.style.border = "2px solid white";
wtfButton.SetPanelEvent("onactivate", function() {
    WTF_Toggle();
    $.Msg(wtfButton.style.border);
    if (wtfButton.style.border == "solidsolidsolidsolid/ 2.0px 2.0px 2.0px 2.0px / #FFFFFFFF #FFFFFFFF #FFFFFFFF #FFFFFFFF ") {
        wtfButton.style.border = "2px solid black";
    } else if (wtfButton.style.border == "solidsolidsolidsolid/ 2.0px 2.0px 2.0px 2.0px / #000000FF #000000FF #000000FF #000000FF ") {
        wtfButton.style.border = "2px solid white";
    }
})

// Обновить скиллы >>

function Refresh() {
    var playerID = Game.GetLocalPlayerID();
    GameEvents.SendCustomGameEventToServer("refresh_admin", { id: playerID });
    Game.EmitSound("General.ButtonClick");
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

    Game.EmitSound("General.ButtonClick");
}

// Выдать золото >>

const networthIcon = $("#gold-icon")

function GiveGold(amt) {
    var playerID = Game.GetLocalPlayerID();

    var entities = Players.GetSelectedEntities( playerID );
    $.Msg( "Entities = " + entities );

    GameEvents.SendCustomGameEventToServer("gold_admin", { amout: amt, ent: entities });
    $.Msg("Requested " + amt + " gold for entities: " + entities);

    Game.EmitSound("General.ButtonClick");
}

function checkPlayerID() {
    GameEvents.SendCustomGameEventToServer("admin_steamID", {});
    checkPlayerID2()
}

GameEvents.Subscribe("admin_steamID", checkPlayerID2);

function checkPlayerID2(data) {
    if (data && data.allowedIDs) {
        // Получаем все значения из объекта allowedIDs
        var allowedSteamIDs = Object.values(data.allowedIDs);
        var steamID = Game.GetLocalPlayerInfo().player_steamid;

        var panel = $.GetContextPanel().FindChildInLayoutFile("debug_panel");

        if (panel) {
            // Проверяем, есть ли steamID в массиве allowedSteamIDs
            if (allowedSteamIDs.includes(steamID)) {
                //ShowDebugPanel();
                isAllowed = true;
                $.Msg("+++ Admin Panel for player with #" + Game.GetLocalPlayerID() + " playerID");
            } else {
                HideDebugPanel();
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
        Game.EmitSound("Shop.PanelUp")
    }
}

function ShowSelect(name)
{   
    let main = $.GetContextPanel().FindChildTraverse(name)

    if (main && main.BHasClass("DebugPanel_hidden"))
    {
        main.RemoveClass("DebugPanel_hidden")
        main.RemoveClass("DebugPanel_hide")
        main.AddClass("DebugPanel_show")
        Game.EmitSound("Shop.PanelUp")
    }
}


function HideSelect(name)
{
    let main = $.GetContextPanel().FindChildTraverse(name)

    if (main && main.BHasClass("DebugPanel_show"))
    {
        main.RemoveClass("DebugPanel_show")
        main.AddClass("DebugPanel_hide")
        Game.EmitSound("Shop.PanelDown")
        $.Schedule(0.1, function ()
        {   
            main.AddClass("DebugPanel_hidden")
        })
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
        Game.EmitSound("Shop.PanelDown")
        $.Schedule(0.1, function ()
        {   
            main.AddClass("DebugPanel_hidden")
        })
    }

}
$.Schedule(1.0, function ()
    { HideDebugPanel() })