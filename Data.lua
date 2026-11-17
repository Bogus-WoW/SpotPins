-- SpotPins: Data.lua
--
-- Built-in pin sets. Coordinates are map percentages (0-100) on the zone
-- map, worked out from the vanilla 1.12 spawn data and checked against
-- known NPC positions in each zone. W4 may have moved things; add your own
-- pins with /pins add if a spot turns out to be different.

local addonName, ns = ...

ns.SETS = {
	traps = {
		label = "Shellfish Traps",
		zone = "Desolace",
		color = "yellow",
		note = "Big Iron Fishing Pole (1.5%)",
		pins = {
			{ 20.0, 73.6 }, { 20.7, 75.0 }, { 19.8, 76.1 }, { 18.0, 76.2 },
			{ 18.9, 77.2 }, { 23.3, 77.1 }, { 24.3, 77.4 }, { 20.2, 79.1 },
			{ 23.1, 80.9 }, { 19.4, 81.9 }, { 20.9, 82.6 },
		},
	},
	water = {
		label = "Patch of Elemental Water",
		zone = "Azshara",
		color = "green",
		note = "Globe of Water / Essence of Water",
		pins = {
			{ 54.6, 39.0 }, { 60.1, 39.7 }, { 55.6, 51.1 },
			{ 79.2, 54.4 }, { 66.3, 68.5 }, { 74.6, 72.6 },
		},
	},
	deviate = {
		label = "School of Deviate Fish",
		zone = "The Barrens",
		color = "red",
		note = "Deviate Fish",
		pins = {
			{ 45.0, 22.2 }, { 45.4, 22.7 }, { 44.6, 23.6 }, { 45.1, 23.7 },
			{ 46.3, 37.6 }, { 46.0, 37.7 }, { 46.4, 38.5 }, { 45.8, 39.8 },
			{ 48.0, 40.0 }, { 46.3, 40.2 }, { 47.4, 40.4 },
			{ 55.2, 41.8 }, { 55.8, 42.4 }, { 55.2, 42.8 }, { 56.0, 43.0 }, { 55.5, 43.3 },
		},
	},
}

-- Horde flight masters (vanilla positions, from pfQuest's database).
-- Each pin carries its own zone. W4's new flight points (Riverglades
-- etc.) aren't included -- add them with /pins add when you find them.
ns.SETS.flight = {
	label = "Horde Flight Path",
	color = "flight",
	note = "Wind rider master",
	pins = {
		{ 45.1, 63.9, "Orgrimmar", "Orgrimmar" },
		{ 47.0, 49.8, "Thunder Bluff", "Thunder Bluff" },
		{ 39.4, 27.0, "Mulgore", "Thunder Bluff" },
		{ 63.3, 48.6, "Undercity", "Undercity" },
		{ 51.5, 30.3, "The Barrens", "The Crossroads" },
		{ 44.4, 59.2, "The Barrens", "Camp Taurajo" },
		{ 63.1, 37.2, "The Barrens", "Ratchet (neutral)" },
		{ 45.1, 59.8, "Stonetalon Mountains", "Sun Rock Retreat" },
		{ 73.2, 61.6, "Ashenvale", "Splintertree Post" },
		{ 12.2, 33.8, "Ashenvale", "Zoram'gar Outpost" },
		{ 22.0, 49.6, "Azshara", "Valormok" },
		{ 45.1, 49.1, "Thousand Needles", "Freewind Post" },
		{ 21.6, 74.1, "Desolace", "Shadowprey Village" },
		{ 35.6, 31.9, "Dustwallow Marsh", "Brackenwall Village" },
		{ 75.4, 44.4, "Feralas", "Camp Mojache" },
		{ 51.6, 25.4, "Tanaris", "Gadgetzan" },
		{ 45.2, 5.8, "Un'Goro Crater", "Marshal's Refuge (neutral)" },
		{ 34.4, 53.9, "Felwood", "Bloodvenom Post" },
		{ 60.5, 36.3, "Winterspring", "Everlook" },
		{ 32.1, 66.6, "Moonglade", "Moonglade" },
		{ 48.7, 36.7, "Silithus", "Cenarion Hold" },
		{ 45.6, 42.6, "Silverpine Forest", "The Sepulcher" },
		{ 60.1, 18.6, "Hillsbrad Foothills", "Tarren Mill" },
		{ 73.0, 32.7, "Arathi Highlands", "Hammerfall" },
		{ 81.7, 81.8, "The Hinterlands", "Revantusk Village" },
		{ 4.0, 44.8, "Badlands", "Kargath" },
		{ 34.8, 30.9, "Searing Gorge", "Thorium Point" },
		{ 65.7, 24.2, "Burning Steppes", "Flame Crest" },
		{ 46.1, 54.8, "Swamp of Sorrows", "Stonard" },
		{ 32.5, 29.4, "Stranglethorn Vale", "Grom'gol Base Camp" },
		{ 26.9, 77.1, "Stranglethorn Vale", "Booty Bay" },
		{ 80.2, 57.0, "Eastern Plaguelands", "Light's Hope Chapel" },
	},
}

-- Rogue quest "The Manor, Ravenholdt" (level 24). Shown only together with
-- its route: /pins route ravenholdt. NPC positions from pfQuest's vanilla
-- database (given there for both zones); the trail start is the well-known
-- spot from WoWWiki. Each pin: x, y, zone, label, note.
ns.SETS.ravenholdt = {
	label = "Ravenholdt",
	color = "blue",
	guide = "ravenholdt",
	pins = {
		{ 60.1, 18.6, "Hillsbrad Foothills", "0. Tarren Mill", "Fly here. Head east and a little south to the trail start; the trail is in the hills north of Durnholde Keep." },
		{ 75.6, 23.7, "Hillsbrad Foothills", "1. Trail start", "Look for a small V in the rocks; the path up is on the right just before the rise slopes down again. Coming from Durnholde Keep: go straight north, past a lone grave." },
		{ 77.6, 20.0, "Hillsbrad Foothills", "2. Ravenholdt guards", "Gate guards on the trail. Friendly to you once you're on the quest." },
		{ 80.0, 13.7, "Hillsbrad Foothills", "3. Rite of Cunning (cave)", "A trapped chest in the cave. Walk up close to it but DON'T open it: getting near completes the Rite. Opening it spawns Milton Beats (elite) who attacks you." },
		{ 82.7, 18.7, "Hillsbrad Foothills", "4. Fahrad (turn in)", "Hand in the Seal of Ravenholdt. Then talk to the guards outside for what comes next." },
		{ 78.5, 81.8, "Alterac Mountains", "2. Ravenholdt guards", "Gate guards on the trail. Friendly to you once you're on the quest." },
		{ 81.3, 74.6, "Alterac Mountains", "3. Rite of Cunning (cave)", "A trapped chest in the cave. Walk up close to it but DON'T open it: getting near completes the Rite. Opening it spawns Milton Beats (elite) who attacks you." },
		{ 84.4, 80.3, "Alterac Mountains", "4. Fahrad (turn in)", "Hand in the Seal of Ravenholdt. Then talk to the guards outside for what comes next." },
		{ 86.0, 78.9, "Alterac Mountains", "Lord Jorach Ravenholdt", "Leader of Ravenholdt. Later quests." },
		{ 86.1, 79.6, "Alterac Mountains", "Smudge Thunderwood", "Poison vendor (in Classic)." },
		{ 86.0, 80.0, "Alterac Mountains", "Zan Shivsproket", "Engineering vendor (Gnomish Cloaking Device schematic in Classic)." },
	},
}

-- Display order for /pins list
ns.SET_ORDER = { "traps", "water", "deviate", "flight", "ravenholdt" }

ns.COLORS = {
	yellow = { "Interface\\COMMON\\Indicator-Yellow", 1, 0.85, 0.1 },
	green = { "Interface\\COMMON\\Indicator-Green", 0.2, 1, 0.3 },
	red = { "Interface\\COMMON\\Indicator-Red", 1, 0.3, 0.3 },
	blue = { "Interface\\COMMON\\Indicator-Gray", 0.3, 0.7, 1 },
	flight = { "Interface\\Minimap\\Tracking\\FlightMaster", 1, 1, 1 },
	-- Mining pins: the ore icon, tinted by the best ore the spot can hold.
	ore_iron = { "Interface\\Icons\\INV_Ore_Iron_01", 0.75, 0.75, 0.8, tint = true },
	ore_gold = { "Interface\\Icons\\INV_Ore_Iron_01", 1, 0.82, 0.1, tint = true },
	ore_mithril = { "Interface\\Icons\\INV_Ore_Iron_01", 0.3, 1, 0.5, tint = true },
	ore_truesilver = { "Interface\\Icons\\INV_Ore_Iron_01", 0.6, 0.85, 1, tint = true },
	ore_darkiron = { "Interface\\Icons\\INV_Ore_Iron_01", 1, 0.3, 0.25, tint = true },
	ore_thorium = { "Interface\\Icons\\INV_Ore_Iron_01", 0.2, 0.9, 0.9, tint = true },
	ore_richthorium = { "Interface\\Icons\\INV_Ore_Iron_01", 0.8, 0.4, 1, tint = true },
}

-- Mining ores shown by the "mining" pins (data in Mining.lua). Ordered from
-- lowest to highest; bit matches the masks in Mining.lua.
ns.ORES = {
	{ bit = 1, key = "iron", name = "Iron", skill = 125 },
	{ bit = 2, key = "gold", name = "Gold", skill = 155 },
	{ bit = 4, key = "mithril", name = "Mithril", skill = 175 },
	{ bit = 8, key = "truesilver", name = "Truesilver", skill = 230 },
	{ bit = 16, key = "darkiron", name = "Dark Iron", skill = 230 },
	{ bit = 32, key = "thorium", name = "Small Thorium", skill = 245 },
	{ bit = 64, key = "richthorium", name = "Rich Thorium", skill = 275 },
}
