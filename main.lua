local lovely = require("lovely")
local nativefs = require("nativefs")

BUMod = {}
BUMod.INITIALIZED = true
BUMod.VER = "v1.2.0"
BUMod.PATH = nil
BUMod.UPDATE = true

local mod_dir = lovely.mod_dir -- Cache the base directory
local found = false
local search_str = "bumod"

for _, item in ipairs(nativefs.getDirectoryItems(mod_dir)) do
	local itemPath = mod_dir .. "/" .. item
	-- Check if the item is a directory and contains the search string
	if nativefs.getInfo(itemPath, "directory") and string.lower(item):find(search_str) then
		BUMod.PATH = itemPath
		found = true
		break
	end
end

-- Raise an error if the directory wasn't found
if not found then
	error("ERROR: Unable to locate BuMod directory.")
end

--- @generic T
--- @generic S
--- @param target T
--- @param source S
--- @param ... any
--- @return T | S
function BUMod.table_merge(target, source, ...)
	assert(type(target) == "table", "Target is not a table")
	local tables_to_merge = { source, ... }
	if #tables_to_merge == 0 then
		return target
	end

	for k, t in ipairs(tables_to_merge) do
		assert(type(t) == "table", string.format("Expected a table as parameter %d", k))
	end

	for i = 1, #tables_to_merge do
		local from = tables_to_merge[i]
		for k, v in pairs(from) do
			if type(v) == "table" then
				if v.__override then
					v.__override = nil
					target[k] = v
				else
					target[k] = target[k] or {}
					target[k] = BUMod.table_merge(target[k], v)
				end
			else
				target[k] = v
			end
		end
	end

	return target
end

---------
---------

BUMod.language_buffer = nil
function BUMod.get_localization()
	return assert(loadstring(nativefs.read(BUMod.PATH .. "/loc_files/madi.lua")))()
end
function BUMod.setup_language()
	G.LANGUAGES["madi"] = {
		font = 1,
		label = "Madi",
		key = "madi",
		beta = nil,
		button = "Language Feedback",
		warning = {
			"This language is silly.",
			"Click again to confirm",
		},
	}
end
local game_set_language_ref = Game.set_language
function Game:set_language(...)
	-- Store initially loaded language
	BUMod.language_buffer = G.SETTINGS.language

	-- Load english localization if BU is selected
	if G.SETTINGS.language == "madi" then
		G.SETTINGS.language = "en-us"
	end

	return game_set_language_ref(self, ...)
end
local init_localization_ref = init_localization
function init_localization(...)
	-- If initially loaded language is BU, select it
	if BUMod.language_buffer == "madi" then
		G.SETTINGS.language = "madi"
		G.LANG = G.LANGUAGES["madi"]
	end
	BUMod.language_buffer = nil

	-- If current language is BU, apply it
	if G.SETTINGS.language == "madi" then
		G.localization = BUMod.table_merge({}, G.localization, BUMod.get_localization())
	end
	BUMod.setup_collabs_localization()

	return init_localization_ref(...)
end

local use_and_sell_buttons_ref = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
	local buttons = use_and_sell_buttons_ref(card)
	if G.SETTINGS.language ~= "bu" then
		return buttons
	end

	local set_loc_text = function(loc_text, consumeable_size, booster_pack_size)
		local is_in_booster = card.area and card.area == G.pack_cards
		local text_container = is_in_booster and buttons.nodes[2] or buttons.nodes[1].nodes[2].nodes[1].nodes[1]
		local line_size = is_in_booster and (booster_pack_size or 0.3) or (consumeable_size or 0.35)

		local result_nodes = {}
		for i, text in ipairs(loc_text) do
			table.insert(result_nodes, {
				n = G.UIT.R,
				config = {
					align = "cm",
				},
				nodes = {
					{
						n = G.UIT.T,
						config = {
							text = text,
							colour = G.C.UI.TEXT_LIGHT,
							scale = line_size,
							shadow = true,
						},
					},
				},
			})
		end

		text_container.nodes = {
			{
				n = G.UIT.C,
				config = {},
				nodes = result_nodes,
			},
		}
	end

	local center_name = card.config.center.key or card.config.center.name

	if center_name == "Immolate" or center_name == "c_immolate" then
		set_loc_text(localize("k_bu_immolate_use"))
	elseif center_name == "The Hanged Man" or center_name == "c_hanged_man" then
		set_loc_text(localize("k_bu_hanged_man_use"), 0.4)
	end

	return buttons
end

-- Rejected by DrSpectred, but let's keep it here just in case

-- local can_discard_ref = G.FUNCS.can_discard
-- function G.FUNCS.can_discard(e, ...)
-- 	if G.SETTINGS.language == "bu" then
-- 		local new_label = nil
-- 		if G.GAME.current_round.discards_used == 0 and next(find_joker("Trading Card")) and #G.hand.highlighted < 2 then
-- 			new_label = localize("b_bu_snap_off")
-- 		else
-- 			new_label = localize("b_discard")
-- 		end
-- 		local button_label = e.children[1].children[1]
-- 		if button_label.config.text ~= new_label then
-- 			button_label.config.text = new_label
-- 			button_label:update_text()
-- 			button_label.UIBox:recalculate()
-- 		end
-- 	end
-- 	return can_discard_ref(e, ...)
-- end

---------

BUMod.is_collabs_injected = false
BUMod.collabs_index_map = {
	Clubs = {},
	Diamonds = {},
	Hearts = {},
	Spades = {},
}
function BUMod.load_asset(asset)
	local file_data =
		assert(nativefs.newFileData(asset.path), ("Failed to collect file data for Atlas %s"):format(asset.name))
	local image_data =
		assert(love.image.newImageData(file_data), ("Failed to initialize image data for Atlas %s"):format(asset.name))
	local image = love.graphics.newImage(image_data, { mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling })

	G.ASSET_ATLAS[asset.name] = {
		name = asset.name,
		image = image,
		type = asset.type,
		px = asset.px,
		py = asset.py,
	}
end
function BUMod.setup_sprites()
	-- Don't do anything if SMODS present
	if SMODS and SMODS.can_load then
		return
	end

	local assets_to_load = {
		{
			name = "Joker",
			path = BUMod.PATH .. "/assets/" .. G.SETTINGS.GRAPHICS.texture_scaling .. "x/Jokers.png",
			px = 71,
			py = 95,
		},
		{
			name = "Tarot",
			path = BUMod.PATH .. "/assets/" .. G.SETTINGS.GRAPHICS.texture_scaling .. "x/Tarots.png",
			px = 71,
			py = 95,
		},
	}

	for _, asset in ipairs(assets_to_load) do
		BUMod.load_asset(asset)
	end
end
function BUMod.setup_collabs()
	if SMODS and SMODS.can_load then
		return
	end

	for _, asset in ipairs(BUMod.COLLABS) do
		BUMod.load_asset({
			name = "bumod_" .. asset.key .. "_1",
			path = BUMod.PATH
				.. "/assets/"
				.. G.SETTINGS.GRAPHICS.texture_scaling
				.. "x/collabs/"
				.. asset.key
				.. "_1.png",
			px = 71,
			py = 95,
		})
		BUMod.load_asset({
			name = "bumod_" .. asset.key .. "_2",
			path = BUMod.PATH
				.. "/assets/"
				.. G.SETTINGS.GRAPHICS.texture_scaling
				.. "x/collabs/"
				.. asset.key
				.. "_2.png",
			px = 71,
			py = 95,
		})
	end

	if not BUMod.is_collabs_injected then
		BUMod.is_collabs_injected = true
		for _, collab in pairs(BUMod.COLLABS) do
			local next_index = #G.COLLABS.options[collab.suit] + 1
			G.COLLABS.options[collab.suit][next_index] = "bumod_" .. collab.key
			BUMod.collabs_index_map[collab.suit]["bumod_" .. collab.key] = next_index
		end
		BUMod.setup_collabs_localization()
	end
end

function BUMod.setup_collabs_localization()
	if SMODS and SMODS.can_load then
		return
	end
	if not G.localization then
		return
	end
	for _, collab in ipairs(BUMod.COLLABS) do
		local index = BUMod.collabs_index_map[collab.suit]["bumod_" .. collab.key]
		if index then
			G.localization.misc.collabs[collab.suit][tostring(index)] = collab.loc_txt
		end
	end
end
