//function ShowAchievement(title, tier) {
//    const panel = $('#AchievementPopup');
//
//    $('#AchievementTitle').text = $.Localize("#" + title + "_" + tier);
//    $('#AchievementDescription').text = $.Localize("#" + title + "_desc_" + tier);
//
//    const path = 'file://{resources}/images/custom_game/' + title + '.png';
//
//    $("#AchievementImage").style.backgroundImage = 'url("' + path + '")';
//    $.Msg('url("' + path + '")');
//
//    $("#AchievementImage").style.backgroundSize = "100%";
//
//    panel.RemoveClass('Hidden');
//    panel.AddClass('Visible');
//
//    $.Schedule(14.0, function () {
//        panel.RemoveClass('Visible');
//        $.Schedule(0.3, () => panel.AddClass('Hidden'));
//    });
//}

function ShowAchievement(title, tier) {
    const container = $("#AchievementContainer");

    const achievementPanel = $.CreatePanel("Panel", container, "");
    achievementPanel.BLoadLayoutSnippet("AchievementPopup");

    achievementPanel.FindChildTraverse("AchievementTitle").text = $.Localize("#" + title + "_" + tier);
    achievementPanel.FindChildTraverse("AchievementDescription").text = $.Localize("#" + title + "_desc_" + tier);

    const path = 'file://{resources}/images/custom_game/' + title + '.png';
    const imagePanel = achievementPanel.FindChildTraverse("AchievementImage");
    imagePanel.style.backgroundImage = 'url("' + path + '")';
    imagePanel.style.backgroundSize = "100%";

    achievementPanel.AddClass("Visible");

    $.Schedule(4.0, () => {
        achievementPanel.RemoveClass("Visible");
        $.Schedule(0.3, () => {
            if (achievementPanel.IsValid()) {
                achievementPanel.DeleteAsync(0);
            }
        });
    });
}


ShowAchievement("arsen_achievement_pianist", 3);
 
// добавить subscribe на гейм ивент и вызвать его в луа