GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_BACKGROUND, false);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_MENU_BUTTONS, false);

let selectedHero = null;

function CreateOrUpdateTopBar(event) {
    const arrayHeroes = Object.values(event.data);
    arrayHeroes.sort((a, b) => b.networth - a.networth);

    let rootPanel = $.GetContextPanel().FindChildTraverse("HeroTopBar");
    if (!rootPanel) {
        rootPanel = $.CreatePanel("Panel", $.GetContextPanel(), "HeroTopBar");
        rootPanel.BLoadLayoutSnippet("heroSnippet");
    }

    const panelBody = rootPanel.FindChildTraverse("hero_panel");
    if (!panelBody) {
        return;
    }

    arrayHeroes.forEach((element) => {
        let bar = panelBody.FindChildTraverse("Hero_" + element.hero);

        if (!bar) {
            bar = $.CreatePanel("Panel", panelBody, "Hero_" + element.hero, { class: "hero_bar" });

            const hero = $.CreatePanel("DOTAHeroImage", bar, "", {
                class: "HeroIcon",
                heroname: element.hero,
            });

            const heroButton = $.CreatePanel("Button", bar, "", {
                class: "HeroIcon",
            });

            heroButton.SetPanelEvent("onactivate", function () {
                selectedHero = element.hero;
                GetHero(selectedHero);
                UpdateHeroSelection();
            });

            const networth = $.CreatePanel("Label", bar, "", {
                class: "HeroGold",
                text: element.networth,
            });

            const networthIcon = $.CreatePanel("Image", networth, "", { class: "hero_networth_icon" });
            networthIcon.SetImage("s2r://panorama/images/hud/reborn/gold_small_psd.vtex");
        }

        let heroImage = bar.GetChild(0);
        if (element.status === 0) {
            heroImage.style.opacity = "1.0";
        } else if (element.status === 1) {
            heroImage.style.opacity = "0.3";
        }

        let networthLabel = bar.GetChild(2);
        networthLabel.text = element.networth;
    });

    UpdateHeroSelection();
}

// Функция обновления состояния кнопки
function UpdateHeroSelection() {
    const panelBody = $.GetContextPanel().FindChildTraverse("hero_panel");
    if (!panelBody) return;

    panelBody.Children().forEach((bar) => {
        let button = bar.GetChild(1);
        if (button) {
            button.SetHasClass("selected", bar.id === "Hero_" + selectedHero);
        }
    });
}


GameEvents.Subscribe("update_top_bar", CreateOrUpdateTopBar);

function GetHero( data ) {
    GameEvents.SendCustomGameEventToServer("top_bar_select", {ent: data});
}

function SelectHero( data ) {
    $.Msg("index: "+data.index);
    GameUI.SelectUnit(data.index, false);
}

GameEvents.Subscribe("top_bar_select_hero", SelectHero);