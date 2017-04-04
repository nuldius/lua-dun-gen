-- UTILITY FUNCTIONS --

-- Returns the distance between two vectors
local function dist(x1, y1, x2, y2)
    local v1 = (x1 - x2) * (x1 - x2)
    local v2 = (y1 - y2) * (y1 - y2)
    return math.sqrt(v1 + v2)
end

-- Returns if the two rooms are overlapping
local function overlaps(a, b)
    return (a.x < b.x + b.w and -- FIXME Error: ./dun-gen.lua:12: attempt to index local 'a' (a number value)
        a.x + a.w > b.x and
        a.y < b.y + b.h and
        a.y + a.h > b.y)
end

-- Returns a bool of whether rooms are done with placement
local function roomsDone(rooms)
    local noOverlaps = true
    for _, a in ipairs(rooms) do
        for _, b in ipairs(rooms) do
            if a ~= b and overlaps(a, b) then
                noOverlaps = false
            end
        end
    end
    return noOverlaps
end

-- Makes and returns a new room struct
local function makeRoom(sizeMin, sizeMax)
    local r = {}
    -- x/y/width/height/centerX/centerY
    r.x = math.random(-2, 2)
    r.y = math.random(-2, 2)
    r.w = math.random(sizeMin, sizeMax)
    r.h = math.random(sizeMin, sizeMax)
    r.cx = r.x + r.w/2
    r.cy = r.y + r.y/2
    return r
end

-- Makes and returns a new hallway struct from roomA to roomB
local function makeHallway(roomA, roomB)
    -- TODO
end

-- DUNGEON CLASS --

Dungeon = {}
Dungeon.__index = Dungeon

-- Generates and returns a new dungeon
function Dungeon:new(roomsMin, roomsMax, sizeMin, sizeMax)
    local d = {}
    setmetatable(d, Dungeon)

    -- Seed random
    math.randomseed(os.time())

    -- Spawn rooms
    d.rooms = {}
    for i = 1, math.random(roomsMin, roomsMax) do
        table.insert(d.rooms, makeRoom(sizeMin, sizeMax))
    end

    -- Position rooms
    while not roomsDone(d.rooms) do
        -- Sort room array by distance to center
        for _ = 1, (#d.rooms * #d.rooms) do
            for i, r in ipairs(d.rooms) do
                if i <= #d.rooms - 2 then
                    local this = dist(d.rooms[i].x, d.rooms[i].y, 0, 0)
                    local next = dist(d.rooms[i+1].x, d.rooms[i+1].y, 0, 0)
                    if this < next then
                        local temp = d.rooms[i]
                        d.rooms[i] = d.rooms[i+1]
                        d.rooms[i+1] = temp
                    end
                end
            end
        end

        -- Systematically reposition the rooms apart
        -- For each room...
        for _, a in ipairs(d.rooms) do
            -- Find the first (closest) overlapping room
            for _, b in ipairs(d.rooms) do
                if a ~= b and overlaps(a, b) then
                    -- Move room A away from room B
                    distX = a.cx - b.cx
                    distY = a.cy - b.cy
                    if math.abs(distX) >= math.abs(distY) then
                        -- Reposition to left side
                        if a.x <= 0 then
                            a.x = b.x - a.w - 1
                        -- Reposition to right side
                        else
                            a.x = b.x + b.w + 1
                        end
                    else
                        -- Reposition to top side
                        if a.y <= 0 then
                            a.y = b.y - a.h - 1
                        -- Reposition to bottom side
                        else
                            a.y = b.y + b.h + 1
                        end
                    end
                    -- Break, as the B room has been found and dealt with
                    break
                end
            end
        end
    end

    -- Use room info to make the dungeon output array's width and height
    local left, right, top, bottom = 0, 0, 0, 0
    for i, r in ipairs(d.rooms) do
        if left > r.x then
            left = r.x
        end
        if right < r.x + r.w then
            right = r.x + r.w
        end
        if top > r.y then
            top = r.y
        end
        if bottom < r.y + r.h then
            bottom = r.y + r.h
        end
    end
    d.arrayWidth = -(left - right)
    d.arrayHeight = -(top - bottom)

    -- Remake room array in positive space rather than central space
    -- NOTE that cx/cy are unneeded and not included in the new room structs
    newRooms = {}
    for i, r in ipairs(d.rooms) do
        newRooms[i] = {}
        newRooms[i].w = r.w
        newRooms[i].h = r.h
        newRooms[i].x = r.x + -left + 1
        newRooms[i].y = r.y + -top + 1
    end
    d.rooms = newRooms

    -- TODO Generate the hallways

    return d
end

-- Returns a 2D number array where 0 = walkable and 1 = non-walkable
function Dungeon:getArray()
    -- Make the base 2D array filled with 1's (walls)
    local a = {}
    for x = 1, self.arrayWidth+2 do
        a[x] = {}
        for y = 1, self.arrayHeight+2 do
            a[x][y] = 1
        end
    end

    -- Using the room rects, carve out 0's in the array
    for i, r in ipairs(self.rooms) do
        for x = r.x + 1, r.x + r.w do
            for y = r.y + 1, r.y + r.h do
                a[x][y] = 0 -- FIXME: trying to index a nil value?
            end
        end
    end

    return a
end

-- Returns details of what tiles are in what rooms
function Dungeon:getRooms()
    -- TODO
end

-- Returns details of what tiles are in what hallways
function Dungeon:getHallways()
    -- TODO
end
