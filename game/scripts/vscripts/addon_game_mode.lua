if GameMode == nil then
	_G.GameMode = class({})
end

require("game-mode/game_mode_init")
require("precache")

function Precache( context )

	for _, particle in ipairs(particles) do
		PrecacheResource("particle", particle, context)
	end

	for _, soundfiles in ipairs(soundfile) do
		PrecacheResource("soundfile", soundfile, context)
	end

	for _, models in ipairs(model) do
		PrecacheModel(model, context)
	end

	for _, model_folders in ipairs(model_folder) do
		PrecacheResource("model_folder", model_folder, context)
	end

	for _, particle_folders in ipairs(particle_folder) do
		PrecacheResource("particle_folder", particle_folder, context)
	end

end

-- Create the game mode when we activate
function Activate()
	GameMode:Init()
	GameMode:SetupColors()

	if IsInToolsMode() then

		GameMode:InitFast() -- быстрый пик героев (для тестов)
		GameMode:GiveAdminItems() -- выдать админ-предметы

	end

end

