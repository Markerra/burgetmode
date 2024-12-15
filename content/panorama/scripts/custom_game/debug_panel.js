const button = $("#spawn_bot_button")

button.SetPanelEvent("onactivate", function() {
	GameEvents.GameEvents.SendCustomGameEventToClient("spawn_bot_admin", {})
})