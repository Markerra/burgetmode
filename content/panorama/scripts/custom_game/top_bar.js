GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_BACKGROUND, false);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_MENU_BUTTONS, false);

function CreateOrUpdateTopBar(event) {
    const arrayHeroes = Object.values(event.data);
    arrayHeroes.sort((a, b) => b.networth - a.networth)

    // проверка на существование панели
    let rootPanel = $.GetContextPanel().FindChildTraverse("HeroTopBar");
    if (!rootPanel) {
        // если панели нет, создаем её
        rootPanel = $.CreatePanel("Panel", $.GetContextPanel(), "HeroTopBar");
        rootPanel.BLoadLayoutSnippet("heroSnippet");
    }

    const panelBody = rootPanel.FindChildTraverse("hero_panel");
    if (!panelBody) {
        $.Msg("Не удалось найти контейнер для героев");
        return;
    }

    // очищение панели
    panelBody.RemoveAndDeleteChildren();

    // добавление героев
    arrayHeroes.forEach((element) => {
        const bar = $.CreatePanel("Panel", panelBody, "", { class: "hero_bar" });

        const status = element.status

        const hero = $.CreatePanel("DOTAHeroImage", bar, "", {
            class: "HeroIcon",
            heroname: element.hero,
        });

        const heroButton = $.CreatePanel("Button", bar, "", {
            class: "HeroIcon",
            onactivate: "SelectHero('"+ element.hero +"')", 
        });

        if (status === 0) {
            hero.style.opacity = "1.0"
        }
        else if (status === 1) {
            hero.style.opacity = "0.3"
        }
        else if (status === 2) {

        }

        const networth = $.CreatePanel("Label", bar, "", {
            class: "HeroGold",
            text: element.networth,
        });

        const networthIcon = $.CreatePanel("Image", networth, "", {class: "hero_networth_icon"});
        networthIcon.SetImage("s2r://panorama/images/hud/reborn/gold_small_psd.vtex");
    });
}


function SelectHero(data) {
    var playerID = Game.GetLocalPlayerID();
    var units = Entities.GetAllEntitiesByName(data)
    GameUI.SelectUnit(units[0], false);
}

GameEvents.Subscribe("update_top_bar", CreateOrUpdateTopBar);