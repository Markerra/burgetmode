if GameMode == nil then
	_G.GameMode = class({})
end

require("game-mode/game_mode_init")
require("precache")

function Precache( context )

	for _, particle in ipairs(particles) do
		PrecacheResource("particle", particle, context)
	end

	for _, soundfile in ipairs(soundfiles) do
		PrecacheResource("soundfile", soundfile, context)
	end

	for _, model in ipairs(models) do
		PrecacheModel(model, context)
	end

	for _, model_folder in ipairs(model_folders) do
		PrecacheResource("model_folder", model_folder, context)
	end

	for _, particle_folder in ipairs(particle_folders) do
		PrecacheResource("particle_folder", particle_folder, context)
	end

end

function Activate()
	GameMode:Init()
	GameMode:SetupColors()

	if IsInToolsMode() then
		GameMode:InitFast() -- быстрый пик героев (для тестов)
		GameMode:GiveAdminItems() -- выдать админ-предметы
	end
end