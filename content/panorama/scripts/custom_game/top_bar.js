GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_BACKGROUND, false );
 
(function () {
    // Подписка на событие "update_top_bar"
    GameEvents.Subscribe("update_top_bar", function(data) {
        $.Msg("Received data:", data);  // Выводим полученные данные для отладки

        // Задержка на 0.5 секунды, чтобы интерфейс успел загрузиться
        $.Schedule(0.5, function() {
            // Находим контейнер с классом TopBarContainer
            const topBarContainer = $.GetContextPanel().FindChildInLayoutFile("TopBarContainer");

            // Проверяем, существует ли контейнер
            if (!topBarContainer) {
                $.Msg("Не удалось найти контейнер TopBarContainer");
                return;
            }

            topBarContainer.RemoveAndDeleteChildren();  // Очищаем контейнер перед добавлением новых элементов

            // Перебираем игроков
            if (data.players && Object.keys(data.players).length > 0) {
                for (let playerID in data.players) {
                    if (data.players.hasOwnProperty(playerID)) {
                        const player = data.players[playerID];
                        
                        $.Msg("Добавляем панель для игрока", player);  // Отладочное сообщение

                        const heroPanel = $.CreatePanel("Panel", topBarContainer, "");
                        heroPanel.AddClass("HeroPanel");

                        const heroIcon = $.CreatePanel("DOTAHeroImage", heroPanel, "HeroIcon");
                        heroIcon.heroname = player.hero;
                        heroIcon.AddClass("HeroIcon");

                        const heroGold = $.CreatePanel("Label", heroPanel, "HeroGold");
                        heroGold.text = player.gold;
                        heroGold.AddClass("HeroGold");
                    }
                }
            }
        });
    });
})();
