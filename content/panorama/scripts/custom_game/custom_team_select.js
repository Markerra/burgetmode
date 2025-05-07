(function () {
    $("#AutoAssignButton").SetPanelEvent("onactivate", function () {
        Game.AutoAssignPlayersToTeams();
    });
})();
