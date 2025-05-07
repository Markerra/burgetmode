let achievementIndex = 1000;

function ShowAchievement(data) {
    const title = data.name
    const tier = data.tier

    $.Msg(title)

    const container = $("#AchievementContainer");

    const achievementPanel = $.CreatePanel("Panel", container, "AchievementPopup");
    achievementPanel.BLoadLayoutSnippet("Achievement");

    achievementIndex = achievementIndex - 1;
    achievementPanel.style.zIndex = achievementIndex;
    $.Msg(achievementIndex)

    achievementPanel.FindChildTraverse("AchievementTitle").text = $.Localize("#" + title + "_" + tier);
    achievementPanel.FindChildTraverse("AchievementDescription").text = $.Localize("#" + title + "_desc_" + tier);

    const path = 'file://{resources}/images/custom_game/achievement/' + title + '.png';
    const imagePanel = achievementPanel.FindChildTraverse("AchievementImage");
    imagePanel.style.backgroundImage = 'url("' + path + '")';
    imagePanel.style.backgroundSize = "100%";

    achievementPanel.RemoveClass("Hidden");
    achievementPanel.AddClass("Visible");

    Game.EmitSound("arsen_achievement_sound")

    $.Schedule(4.0, () => {
        achievementPanel.RemoveClass("Visible");
        $.Schedule(0.3, () => {
            if (achievementPanel.IsValid()) {
                achievementPanel.DeleteAsync(0);
            }
        });
    });
}


//ShowAchievement({});
 
GameEvents.Subscribe("arsen_achievement_popup", ShowAchievement);