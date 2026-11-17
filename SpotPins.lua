-- SpotPins: SpotPins.lua
--
-- Draws pins for the sets in Data.lua (and your own /pins add spots) on
-- the world map and the minimap. No TomTom or other library needed.
--
--   World map: pins are placed on the map canvas by zone-map percentage.
--   Minimap:   map coordinates are converted to world yards with
--              C_Map.GetWorldPosFromMapPos, so pins sit at the right
--              distance/direction from you, and stick to the minimap edge
--              when they're out of range.

local addonName, ns = ...

local DB

local MINIMAP_SIZE = { -- yards across the minimap at each zoom level
	outdoor = { [0] = 466 + 2 / 3, 400, 333 + 1 / 3, 266 + 2 / 3, 200, 133 + 1 / 3 },
	indoor = { [0] = 300, 240, 180, 120, 80, 50 },
}

local function Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffSpotPins|r: " .. tostring(msg))
end

local function Clean(v)
	if issecretvalue and issecretvalue(v) then
		return nil
	end
	return v
end

--------------------------------------------------------------------------
-- Data access
--------------------------------------------------------------------------

local function InitDB()
	SpotPinsDB = SpotPinsDB or {}
	DB = SpotPinsDB
	DB.hidden = DB.hidden or {}
	DB.custom = DB.custom or {}
	if DB.minimap == nil then DB.minimap = true end
	if DB.worldmap == nil then DB.worldmap = true end
end

-- Pins per zone are rebuilt only when something changes (toggles, your
-- own pins, the mining filter), not on every minimap tick.
local pinCache, cacheVersion, cachedVersion = {}, 1, 0
local function InvalidatePins()
	cacheVersion = cacheVersion + 1
end
ns.InvalidatePins = InvalidatePins

local function AddMiningPins(out, zone)
	local list = ns.MINING and ns.MINING[zone]
	if not list or DB.hidden.mining then
		return
	end
	local minBit = DB.miningMinBit or 1
	for i = 1, #list, 3 do
		local mask = list[i + 2]
		-- Show the spot if any ore that can appear there is at/above the filter.
		local top, names = nil, {}
		for _, ore in ipairs(ns.ORES) do
			if bit.band(mask, ore.bit) ~= 0 then
				names[#names + 1] = ("%s (%d)"):format(ore.name, ore.skill)
				top = ore
			end
		end
		if top and top.bit >= minBit then
			out[#out + 1] = {
				x = list[i], y = list[i + 1],
				label = "Mining node",
				note = "Can be: " .. table.concat(names, ", "),
				color = "ore_" .. top.key,
				small = true,
				worldOnly = true, -- world map only: keeps the minimap clear for the real tracking icons
			}
		end
	end
end

-- Every visible pin for a zone name: { x, y, label, color, note }
local function PinsForZone(zone)
	if cachedVersion ~= cacheVersion then
		wipe(pinCache)
		cachedVersion = cacheVersion
	end
	if zone and pinCache[zone] then
		return pinCache[zone]
	end
	local out = {}
	if not zone then
		return out
	end
	pinCache[zone] = out
	AddMiningPins(out, zone)
	for _, key in ipairs(ns.SET_ORDER) do
		local set = ns.SETS[key]
		-- guide sets only show while their route is on
		local visible = not DB.hidden[key] and (not set.guide or DB.route == set.guide)
		if visible then
			for i, p in ipairs(set.pins) do
				-- A pin may name its own zone (p[3]), label (p[4]) and note (p[5]).
				if (p[3] or set.zone) == zone then
					local color = set.color
					if p[4] and p[4]:find("Rite of Cunning", 1, true) then color = "red" end
					out[#out + 1] = {
						x = p[1], y = p[2],
						label = p[4] and (set.label .. ": " .. p[4]) or ("%s #%d"):format(set.label, i),
						color = color, note = p[5] or set.note,
					}
				end
			end
		end
	end
	local route = ns.ActiveRoute and ns.ActiveRoute(zone)
	if route and not route.open then
		out[#out + 1] = { x = route.pts[1], y = route.pts[2], label = route.label .. ": start",
			color = "blue", note = route.note .. " Follow the yellow line on your map and minimap." }
	end
	if not DB.hidden.custom then
		for i, p in ipairs(DB.custom) do
			if p.zone == zone then
				out[#out + 1] = { x = p.x, y = p.y, label = p.label or ("My pin #" .. i), color = "blue", note = "Your pin (#" .. i .. ")" }
			end
		end
	end
	return out
end

local function MapName(mapID)
	local info = mapID and C_Map.GetMapInfo(mapID)
	return info and info.name, info
end

-- Walks up from mapID until a map with the given name is found.
local function FindZoneMap(mapID, zone)
	local guard = 0
	while mapID and guard < 10 do
		local name, info = MapName(mapID)
		if name == zone then
			return mapID
		end
		mapID = info and info.parentMapID
		guard = guard + 1
	end
end

local function ApplyColor(tex, color)
	local c = ns.COLORS[color] or ns.COLORS.yellow
	tex:SetTexture(c[1])
	if not tex:GetTexture() then
		tex:SetColorTexture(c[2], c[3], c[4], 1)
	elseif c.tint then
		tex:SetVertexColor(c[2], c[3], c[4], 1)
	else
		tex:SetVertexColor(1, 1, 1, 1)
	end
end

local function ShowTooltip(self)
	local p = self.pin
	if not p then
		return
	end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(p.label)
	if p.note then
		GameTooltip:AddLine(p.note, 0.8, 0.8, 0.8)
	end
	GameTooltip:AddLine(("%.1f, %.1f"):format(p.x, p.y), 0.6, 0.6, 0.6)
	if self.distance then
		GameTooltip:AddLine(("%d yards away"):format(self.distance), 0.6, 0.6, 0.6)
	end
	GameTooltip:Show()
end

local function MakePin(parent, size)
	local f = CreateFrame("Frame", nil, parent)
	f:SetSize(size, size)
	f.tex = f:CreateTexture(nil, "OVERLAY")
	f.tex:SetAllPoints()
	f:EnableMouse(true)
	f:SetScript("OnEnter", ShowTooltip)
	f:SetScript("OnLeave", function() GameTooltip:Hide() end)
	f:Hide()
	return f
end

--------------------------------------------------------------------------
-- Route lines (a loop through a zone, drawn on the world map and minimap)
--------------------------------------------------------------------------

local ROUTE_COLOR = { 1, 0.82, 0.1, 0.85 }

-- The shown route's points in this zone: a route has one zone (r.zone +
-- r.pts) or a leg per zone (r.zones). Open routes aren't closed into a loop.
local function ActiveRoute(zone)
	local r = DB and DB.route and ns.ROUTES and ns.ROUTES[DB.route]
	if not r then return end
	if r.zones then
		local pts = r.zones[zone]
		if pts then return { pts = pts, open = r.open, label = r.label, note = r.note } end
	elseif r.zone == zone then
		return r
	end
end
ns.ActiveRoute = ActiveRoute

local function RoutePoints(r)
	local n = 0
	if r.zones then
		for _, pts in pairs(r.zones) do n = n + #pts / 2 end
	else
		n = #r.pts / 2
	end
	return n
end

local function GetLine(pool, parent, i)
	local line = pool[i]
	if not line then
		line = parent:CreateLine(nil, "OVERLAY")
		line:SetColorTexture(ROUTE_COLOR[1], ROUTE_COLOR[2], ROUTE_COLOR[3], ROUTE_COLOR[4])
		pool[i] = line
	end
	return line
end

local function HideLines(pool, from)
	for i = from or 1, #pool do pool[i]:Hide() end
end

-- Shorten a segment by `gap` at both ends, leaving a hole around each
-- stop so the Find Minerals dot underneath stays visible.
local function Trim(ax, ay, bx, by, gap)
	local dx, dy = bx - ax, by - ay
	local len = math.sqrt(dx * dx + dy * dy)
	if len <= gap * 2 + 1 then return end
	local ux, uy = dx / len * gap, dy / len * gap
	return ax + ux, ay + uy, bx - ux, by - uy
end

local worldLines, worldOverlay = {}, nil

local function DrawWorldRoute(canvas, zone)
	local r = ActiveRoute(zone)
	if not r then
		HideLines(worldLines)
		return
	end
	if not worldOverlay then
		worldOverlay = CreateFrame("Frame", nil, canvas)
	end
	worldOverlay:SetParent(canvas)
	worldOverlay:SetAllPoints(canvas)
	worldOverlay:SetFrameLevel(canvas:GetFrameLevel() + 1990)
	worldOverlay:Show()
	local w, h = canvas:GetWidth(), canvas:GetHeight()
	local thick = 3 / math.max(canvas:GetScale(), 0.01)
	local pts, n = r.pts, #r.pts / 2
	local segs = r.open and n - 1 or n
	for i = 1, segs do
		local j = i % n + 1
		local line = GetLine(worldLines, worldOverlay, i)
		line:SetThickness(thick)
		local ax, ay, bx, by = Trim(pts[2 * i - 1] / 100 * w, pts[2 * i] / 100 * h,
			pts[2 * j - 1] / 100 * w, pts[2 * j] / 100 * h, 7 / math.max(canvas:GetScale(), 0.01))
		if ax then
			line:SetStartPoint("TOPLEFT", canvas, ax, -ay)
			line:SetEndPoint("TOPLEFT", canvas, bx, -by)
			line:Show()
		else
			line:Hide()
		end
	end
	HideLines(worldLines, segs + 1)
end

-- Part of the segment a-b inside a circle of radius R around 0,0 (or nil).
local function ClipToCircle(ax, ay, bx, by, R)
	local dx, dy = bx - ax, by - ay
	local a = dx * dx + dy * dy
	if a == 0 then return end
	local b = 2 * (ax * dx + ay * dy)
	local c = ax * ax + ay * ay - R * R
	local disc = b * b - 4 * a * c
	if disc < 0 then return end
	local sq = math.sqrt(disc)
	local t1, t2 = (-b - sq) / (2 * a), (-b + sq) / (2 * a)
	local tmin, tmax = math.max(0, t1), math.min(1, t2)
	if tmin >= tmax then return end
	return ax + tmin * dx, ay + tmin * dy, ax + tmax * dx, ay + tmax * dy
end

local miniLines, miniOverlay = {}, nil

-- toPx(x, y) -> minimap pixel offset from the centre
local function DrawMiniRoute(zone, toPx, radius)
	local r = ActiveRoute(zone)
	if not (r and toPx) then
		HideLines(miniLines)
		return
	end
	if not miniOverlay then
		miniOverlay = CreateFrame("Frame", nil, Minimap)
		miniOverlay:SetAllPoints(Minimap)
	end
	miniOverlay:SetFrameLevel(Minimap:GetFrameLevel() + 15)
	local pts, n, used = r.pts, #r.pts / 2, 0
	local px, py = {}, {}
	for i = 1, n do
		px[i], py[i] = toPx(pts[2 * i - 1], pts[2 * i])
	end
	for i = 1, (r.open and n - 1 or n) do
		local j = i % n + 1
		local ax, ay, bx, by = Trim(px[i], py[i], px[j], py[j], 8)
		local x1, y1, x2, y2
		if ax then x1, y1, x2, y2 = ClipToCircle(ax, ay, bx, by, radius) end
		if x1 then
			used = used + 1
			local line = GetLine(miniLines, miniOverlay, used)
			line:SetThickness(2)
			line:SetStartPoint("CENTER", Minimap, x1, y1)
			line:SetEndPoint("CENTER", Minimap, x2, y2)
			line:Show()
		end
	end
	HideLines(miniLines, used + 1)
end

--------------------------------------------------------------------------
-- World map
--------------------------------------------------------------------------

local worldPins = {}

local function WorldCanvas()
	return WorldMapFrame and WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.Child
end

local function RefreshWorldMap()
	for _, f in ipairs(worldPins) do
		f:Hide()
	end
	if not (DB and DB.worldmap and WorldMapFrame and WorldMapFrame:IsShown()) then
		HideLines(worldLines)
		return
	end
	local canvas = WorldCanvas()
	if not canvas then
		return
	end
	local zone = MapName(WorldMapFrame:GetMapID())
	DrawWorldRoute(canvas, zone)
	local pins = PinsForZone(zone)
	local w, h = canvas:GetWidth(), canvas:GetHeight()
	local size = 14 / math.max(canvas:GetScale(), 0.01)
	for i, p in ipairs(pins) do
		local f = worldPins[i]
		if not f then
			f = MakePin(canvas, size)
			worldPins[i] = f
		end
		f:SetParent(canvas)
		f:SetFrameLevel(canvas:GetFrameLevel() + 2000)
		local ps = p.small and size * 0.75 or size
		f:SetSize(ps, ps)
		f.pin, f.distance = p, nil
		ApplyColor(f.tex, p.color)
		f:ClearAllPoints()
		f:SetPoint("CENTER", canvas, "TOPLEFT", p.x / 100 * w, -p.y / 100 * h)
		f:Show()
	end
end

--------------------------------------------------------------------------
-- Minimap
--------------------------------------------------------------------------

local miniPins = {}
local zoneMapCache = {}
local lastMiniKey, lastMiniFull = nil, 0 -- skip redraws while nothing has changed

local function WorldXY(mapID, x, y)
	if not (C_Map.GetWorldPosFromMapPos and CreateVector2D) then
		return
	end
	local ok, _, pos = pcall(C_Map.GetWorldPosFromMapPos, mapID, CreateVector2D(x, y))
	if ok and pos then
		local wx, wy = pos:GetXY()
		return Clean(wx), Clean(wy)
	end
end

-- Yards per 100% of the zone map, east-west and north-south, measured from
-- the map's own corners (cached per map).
local zoneSize = {}
local function ZoneYards(mapID)
	local z = zoneSize[mapID]
	if z then
		return z.w, z.h
	end
	local ox, oy = WorldXY(mapID, 0, 0)
	local ex, ey = WorldXY(mapID, 1, 0)
	local sx, sy = WorldXY(mapID, 0, 1)
	if not (ox and ex and sx) then
		return
	end
	local w = math.sqrt((ex - ox) ^ 2 + (ey - oy) ^ 2)
	local h = math.sqrt((sx - ox) ^ 2 + (sy - oy) ^ 2)
	if w == 0 or h == 0 then
		return
	end
	zoneSize[mapID] = { w = w, h = h }
	return w, h
end

local function RefreshMinimap()
	if not (DB and DB.minimap and Minimap) then
		lastMiniKey = nil
		for _, f in ipairs(miniPins) do
			f:Hide()
		end
		HideLines(miniLines)
		return
	end

	-- Which of our zones is the player in, and where on that zone's map?
	local zone = GetRealZoneText()
	local pins = PinsForZone(zone)
	local shown = 0
	local playerMap = #pins > 0 and Clean(C_Map.GetBestMapForUnit("player"))
	local zoneMap = playerMap and (zoneMapCache[zone] or FindZoneMap(playerMap, zone))
	local pos = zoneMap and C_Map.GetPlayerMapPosition(zoneMap, "player")
	local pu, pv
	if pos then
		pu, pv = pos:GetXY()
		pu, pv = Clean(pu), Clean(pv)
	end
	local mapW, mapH
	if pu then
		zoneMapCache[zone] = zoneMap
		mapW, mapH = ZoneYards(zoneMap)
	end

	if mapW then
		local zoomTable = (IsIndoors and IsIndoors()) and MINIMAP_SIZE.indoor or MINIMAP_SIZE.outdoor
		local yardsAcross = zoomTable[Minimap:GetZoom()] or zoomTable[0]
		local radiusPx = Minimap:GetWidth() / 2
		local pxPerYard = radiusPx / (yardsAcross / 2)
		local rangeYards = yardsAcross / 2

		local rotate = GetCVar("rotateMinimap") == "1"
		local facing = rotate and Clean(GetPlayerFacing and GetPlayerFacing()) or 0
		-- Nothing moved, turned, zoomed or changed: the pins are already right.
		-- (A full redraw still happens every 2 seconds, just in case.)
		local key = table.concat({ zone, pu, pv, facing, Minimap:GetZoom(), radiusPx, yardsAcross,
			cacheVersion, DB.route or "", tostring(rotate) }, "|")
		local now = GetTime()
		if key == lastMiniKey and now - lastMiniFull < 2 then
			return
		end
		lastMiniKey, lastMiniFull = key, now

		local cosF, sinF = math.cos(-facing), math.sin(-facing)
		local edge = radiusPx - 6

		DrawMiniRoute(zone, function(x, y)
			local e = (x / 100 - pu) * mapW
			local nn = -(y / 100 - pv) * mapH
			if rotate then
				e, nn = e * cosF - nn * sinF, e * sinF + nn * cosF
			end
			return e * pxPerYard, nn * pxPerYard
		end, radiusPx - 2)

		for _, p in ipairs(pins) do
			-- World-map-only pins (mining) never go on the minimap, so skip
			-- them before doing any maths.
			local east, north, dist
			if not p.worldOnly then
				east = (p.x / 100 - pu) * mapW
				north = -(p.y / 100 - pv) * mapH
				dist = math.sqrt(north * north + east * east)
			end
			if not p.worldOnly and not (p.noEdge and dist > rangeYards) then
				local sx, sy = east, north
				if rotate then
					sx, sy = east * cosF - north * sinF, east * sinF + north * cosF
				end
				sx, sy = sx * pxPerYard, sy * pxPerYard
				local len = math.sqrt(sx * sx + sy * sy)
				local onEdge = len > edge
				if onEdge then
					sx, sy = sx / len * edge, sy / len * edge
				end

				shown = shown + 1
				local f = miniPins[shown]
				if not f then
					f = MakePin(Minimap, 12)
					miniPins[shown] = f
				end
				f:SetFrameLevel(Minimap:GetFrameLevel() + 20)
				f.pin, f.distance = p, math.floor(dist + 0.5)
				ApplyColor(f.tex, p.color)
				f:SetAlpha(onEdge and 0.6 or 1)
				local size = p.small and 10 or (onEdge and 9 or 12)
				f:SetSize(size, size)
				f:ClearAllPoints()
				f:SetPoint("CENTER", Minimap, "CENTER", sx, sy)
				f:Show()
			end
		end
	end
	if not mapW then DrawMiniRoute(zone, nil); lastMiniKey = nil end
	for i = shown + 1, #miniPins do
		miniPins[i]:Hide()
	end
end

--------------------------------------------------------------------------
-- Driver
--------------------------------------------------------------------------

local driver = CreateFrame("Frame")
local elapsed = 0
driver:SetScript("OnUpdate", function(_, dt)
	elapsed = elapsed + dt
	if elapsed < 0.1 then
		return
	end
	elapsed = 0
	if not DB then
		return
	end
	RefreshMinimap()
	if WorldMapFrame and WorldMapFrame:IsShown() then
		RefreshWorldMap()
	end
end)

driver:RegisterEvent("ADDON_LOADED")
driver:RegisterEvent("ZONE_CHANGED_NEW_AREA")
driver:SetScript("OnEvent", function(self, event, arg)
	if event == "ADDON_LOADED" and arg == addonName then
		InitDB()
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		wipe(zoneMapCache)
	end
end)

--------------------------------------------------------------------------
-- Slash commands
--------------------------------------------------------------------------

local function PlayerZonePos()
	local mapID = Clean(C_Map.GetBestMapForUnit("player"))
	local zone = GetRealZoneText()
	local zoneMap = mapID and FindZoneMap(mapID, zone)
	local pos = zoneMap and C_Map.GetPlayerMapPosition(zoneMap, "player")
	if not pos then
		return
	end
	local x, y = pos:GetXY()
	x, y = Clean(x), Clean(y)
	if x then
		return zone, x * 100, y * 100
	end
end

SLASH_SPOTPINS1 = "/pins"
SLASH_SPOTPINS2 = "/spotpins"
SlashCmdList.SPOTPINS = function(msg)
	local cmd, rest = (msg or ""):match("^%s*(%S*)%s*(.-)%s*$")
	cmd = (cmd or ""):lower()

	if cmd == "list" or cmd == "" then
		Print("pin sets (toggle with /pins toggle <name>):")
		for _, key in ipairs(ns.SET_ORDER) do
			local set = ns.SETS[key]
			Print(("  %s - %s in %s, %d pins %s%s"):format(key, set.label, set.zone or "several zones", #set.pins,
				DB.hidden[key] and "|cffff6666(hidden)|r" or "", set.guide and (" (shows with /pins route " .. set.guide .. ")") or ""))
		end
		Print(("  custom - your pins, %d saved %s"):format(#DB.custom, DB.hidden.custom and "|cffff6666(hidden)|r" or ""))
		local minOre = "Iron"
		for _, ore in ipairs(ns.ORES) do
			if ore.bit == (DB.miningMinBit or 1) then minOre = ore.name end
		end
		Print(("  mining - mining nodes, showing %s and above %s"):format(minOre, DB.hidden.mining and "|cffff6666(hidden)|r" or ""))
		Print("Other: /pins mining <iron|gold|mithril|truesilver|darkiron|thorium|richthorium> sets the lowest ore shown")
		Print("Other: /pins route [stonetalon|desolace|desolace_sw|badlands|tanaris|off] draws a mithril loop on the map and minimap")
		Print("Other: /pins route ravenholdt shows the way to Ravenholdt Manor (Rogue quest)")
		Print("Other: /pins add [label], /pins remove <number>, /pins mine, /pins minimap, /pins worldmap")
	elseif cmd == "toggle" then
		local key = rest:lower()
		if ns.SETS[key] or key == "custom" or key == "mining" then
			DB.hidden[key] = not DB.hidden[key] or nil
			Print(key .. (DB.hidden[key] and " hidden." or " shown."))
		else
			Print("unknown set. Try /pins list.")
		end
	elseif cmd == "mining" then
		local want = rest:lower():gsub("%s+", "")
		local found
		for _, ore in ipairs(ns.ORES) do
			if ore.key == want or ore.name:lower():gsub("%s+", "") == want then
				found = ore
			end
		end
		if found then
			DB.miningMinBit = found.bit
			DB.hidden.mining = nil
			Print(("mining pins: showing spots that can hold %s or better."):format(found.name))
		else
			Print("usage: /pins mining <iron|gold|mithril|truesilver|darkiron|thorium|richthorium>")
		end
	elseif cmd == "route" then
		local want = rest:lower()
		if want == "off" then
			DB.route = nil
			Print("route hidden.")
		elseif ns.ROUTES and ns.ROUTES[want] then
			DB.route = want
			local r = ns.ROUTES[want]
			Print(("showing %s (%d stops). %s"):format(r.label, RoutePoints(r), r.note))
			if not r.open then
				Print("Tip: /pins mining mithril hides the iron-only spots so the map only shows the loop's nodes.")
			end
		else
			Print("routes (show one with /pins route <name>, hide with /pins route off):")
			for _, key in ipairs(ns.ROUTE_ORDER or {}) do
				local r = ns.ROUTES[key]
				Print(("  %s - %s, %d stops%s"):format(key, r.label, RoutePoints(r), DB.route == key and " |cff66ff66(showing)|r" or ""))
			end
		end
	elseif cmd == "add" then
		local zone, x, y = PlayerZonePos()
		if not zone then
			Print("can't read your position here.")
			return
		end
		local label = rest ~= "" and rest or ("My pin #" .. (#DB.custom + 1))
		table.insert(DB.custom, { zone = zone, x = x, y = y, label = label })
		Print(("added #%d \"%s\" at %s %.1f, %.1f."):format(#DB.custom, label, zone, x, y))
	elseif cmd == "remove" then
		local n = tonumber(rest)
		if n and DB.custom[n] then
			local p = table.remove(DB.custom, n)
			Print(("removed \"%s\"."):format(p.label or "pin"))
		else
			Print("usage: /pins remove <number> (see /pins mine)")
		end
	elseif cmd == "mine" then
		if #DB.custom == 0 then
			Print("no pins of your own yet. Stand somewhere and type /pins add <label>.")
		end
		for i, p in ipairs(DB.custom) do
			Print(("  #%d %s - %s %.1f, %.1f"):format(i, p.label or "", p.zone, p.x, p.y))
		end
	elseif cmd == "minimap" then
		DB.minimap = not DB.minimap
		Print("minimap pins " .. (DB.minimap and "on." or "off."))
	elseif cmd == "worldmap" then
		DB.worldmap = not DB.worldmap
		Print("world map pins " .. (DB.worldmap and "on." or "off."))
	else
		Print("commands: /pins list, /pins toggle <set>, /pins mining <ore>, /pins route [name|off], /pins add [label], /pins remove <n>, /pins mine, /pins minimap, /pins worldmap")
	end
	InvalidatePins()
	RefreshMinimap()
	RefreshWorldMap()
end
