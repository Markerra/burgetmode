if GameMode == nil then
	_G.GameMode = class({})
end

require("game-mode/game_mode_init")
require("game-mode/custom_params")
require("precache")

function Precache( context )

	if CUSTOM_DEBUG_MODE then
	print("====================================PRECACHE START====================================")
	end

	for _, particle in ipairs(particles) do
		if CUSTOM_DEBUG_MODE then print("particle:", particle) end
		PrecacheResource("particle", particle, context)
	end

	for _, soundfile in ipairs(soundfiles) do
		if CUSTOM_DEBUG_MODE then print("soundfile:", soundfile) end
		PrecacheResource("soundfile", soundfile, context)
	end

	for _, model in ipairs(models) do
		if CUSTOM_DEBUG_MODE then print("model:", model) end
		PrecacheModel(model, context)
	end

	for _, model_folder in ipairs(model_folders) do
		if CUSTOM_DEBUG_MODE then print("model_folder:", model_folder) end
		PrecacheResource("model_folder", model_folder, context)
	end

	for _, particle_folder in ipairs(particle_folders) do
		if CUSTOM_DEBUG_MODE then print("particle_folder:", particle_folder) end
		PrecacheResource("particle_folder", particle_folder, context)
	end

	if CUSTOM_DEBUG_MODE then
	print("=====================================PRECACHE END=====================================")
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