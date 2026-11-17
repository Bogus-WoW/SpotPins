-- SpotPins: Routes.lua (generated)
--
-- Mining loops through spots that can hold Mithril (Mining.lua, from Wowhead's
-- Forever data), ordered into a short closed loop starting at the stop closest
-- to the zone's Horde flight path. Stonetalon and Desolace skip spots near mobs
-- whose average level is above 36 (Questie spawn data) and keep the line clear
-- of them and of Alliance towns.
-- Flat list: x1, y1, x2, y2, ...

local addonName, ns = ...

ns.ROUTES = {
	stonetalon = {
		zone = "Stonetalon Mountains",
		label = "Mining loop: Stonetalon (mithril + iron)",
		note = "Start near Sun Rock Retreat (flight path). The mithril and iron spots in the south-west of the zone (Windshear Crag / Charred Vale side). The far spot at 35.4, 46.9 and the spots up by Stonetalon Peak (Alliance) are left out. Mobs are well below 36.",
		pts = { 37.9, 65.2, 34.9, 66.6, 37.4, 69.9, 37.6, 73, 36.3, 76.2, 35.3, 75.2, 33.6, 75.7, 31.8, 75.1, 29, 73.7, 27.4, 71.4, 25.9, 70.9, 26.9, 67, 27.1, 63.2, 28.5, 62.2, 29.7, 66.2, 31.1, 64.3, 30.1, 59.9, 32.6, 58.8, 35.9, 61.3 },
	},
	desolace = {
		zone = "Desolace",
		label = "Mithril loop: Desolace",
		note = "Start by Shadowprey Village (flight path). Gelkis area, then up the middle (east of the Valley of Spears) to the naga coast in the north, and back down the west coast. Spots near mobs above 36 are left out, and the line keeps clear of the Valley of Spears, Mannoroc Coven and Nijel's Point. A few points are just turns in the path, not nodes.",
		pts = { 27.9, 74.1, 23, 65, 22, 50, 27, 35, 32.1, 20.9, 32.2, 15.4, 30.7, 10.2, 34, 14.7, 35.6, 6.2, 36.7, 9.3, 39.6, 10.7, 41.2, 16.4, 39.4, 16.4, 36.8, 15.9, 34.8, 16.8, 35.6, 31.7, 35.8, 37.3, 38.7, 46.5, 42, 66, 35.1, 80.6, 32.4, 82, 36, 86.5, 39.4, 85.4, 38.4, 91, 36.2, 92.4, 24.8, 82.4, 27.2, 78.6 },
	},
	desolace_sw = {
		zone = "Desolace",
		label = "Mithril loop: Desolace (short, Gelkis)",
		note = "The Gelkis centaur area southeast of Shadowprey Village (mobs 32-36), for quick laps.",
		pts = { 27.9, 74.1, 27.2, 78.6, 24.8, 82.4, 36.2, 92.4, 38.4, 91, 39.4, 85.4, 36, 86.5, 35.1, 80.6, 32.4, 82 },
	},
	badlands = {
		zone = "Badlands",
		label = "Mithril loop: Badlands",
		note = "Start near Kargath (flight path). All mithril spots, no level filter: mobs 35-45.",
		pts = { 12.2, 35, 14.3, 39.6, 9.2, 65.4, 7.4, 73.3, 11.4, 77.7, 6.1, 77.5, 3.9, 80.6, 6.4, 90.3, 6.8, 95.4, 8.4, 90.6, 9.4, 88.1, 10.1, 92.7, 15.1, 92.2, 16.3, 87.9, 15.1, 85.9, 15, 81.8, 20.8, 82.3, 23.8, 66.4, 31.7, 72.4, 42, 78.8, 42.2, 82.2, 45.3, 84.6, 56.2, 87.6, 56, 82.1, 64, 68.7, 71.8, 67.1, 72.8, 61.1, 76.1, 66.1, 80.6, 65.7, 82.8, 59.9, 83.8, 54.8, 78.8, 55.4, 78, 48.4, 78.3, 43.9, 82.6, 44.8, 83.6, 39.8, 83.8, 33.1, 79.7, 33.2, 72.3, 34.7, 68.8, 51.1, 63, 56.1, 61.3, 64, 43.4, 74.3, 35.4, 39, 15.8, 32.8 },
	},
	tanaris = {
		zone = "Tanaris",
		label = "Mithril loop: Tanaris",
		note = "Start near Gadgetzan (flight path). All mithril spots, no level filter: mobs 40-50.",
		pts = { 54.2, 24.4, 57.4, 26.3, 67.5, 31.9, 71.9, 47, 69.6, 52.8, 67.2, 55.3, 65.6, 58.6, 62.4, 57.3, 63.1, 59, 63.7, 62.4, 61.9, 63.2, 60, 63.2, 59.2, 67.8, 57.3, 68.7, 56.8, 69.6, 56, 71.4, 57.8, 71.9, 57.9, 74.8, 55.2, 75.9, 55.6, 77.7, 54.7, 77.4, 53.6, 77, 50.7, 79.4, 49.7, 78.8, 47.8, 78.5, 43.8, 77.6, 40.7, 78.9, 41.2, 76.1, 47, 56.2, 45.4, 55.1, 41.4, 58, 41.6, 57, 41.4, 54.4, 37, 51.3, 35.3, 43.3, 35, 42.3, 36.7, 33.3, 40, 33.7, 46.6, 29.7, 48.6, 23.8, 47.1, 23.7, 43.9, 25.9, 38.2, 27.2, 37, 28.2, 34.2, 26.7, 34.2, 32.6, 33.4, 37.5, 34.5, 40.3, 33.4, 41.6, 33.2, 42.7, 33, 44.3, 32, 45.8, 33.3, 45.7, 33.5, 46.6, 33.4, 47.9, 31.9, 48.4, 29.7, 47.6, 28.2, 53.4, 28.2, 62.1, 30.9, 63.4, 31.9, 66.8, 29.7, 68.8, 28.8, 70.7, 34.7, 80.2, 31.6, 79.4, 30.2, 78.8, 28.9, 77.1, 28.2, 74.4, 28.2, 72.2, 53.6, 72.2, 55.5, 69.9, 56.9, 67.7, 59.8, 53.8 },
	},
}
-- Quest guide: an open path (not a loop) with a leg per zone, since the
-- manor sits on the Hillsbrad/Alterac border. Its step pins live in
-- Data.lua (ns.SETS.ravenholdt) and show while this route is on.
ns.ROUTES.ravenholdt = {
	label = "Rogue quest: The Manor, Ravenholdt",
	note = "From Tarren Mill ride east to the trail start in the hills north of Durnholde Keep, follow the trail up past the guards to the cave (walk up to the trapped chest, don't open it), then on to Fahrad in the manor. The trail winds: the line shows the order, not the exact path.",
	open = true,
	zones = {
		["Hillsbrad Foothills"] = { 75.6, 23.7, 77.6, 20.0, 80.0, 13.7, 82.7, 18.7 },
		["Alterac Mountains"] = { 78.5, 81.8, 81.3, 74.6, 84.4, 80.3 },
	},
}

ns.ROUTE_ORDER = { "stonetalon", "desolace", "desolace_sw", "badlands", "tanaris", "ravenholdt" }
