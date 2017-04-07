-- UTILITY FUNCTIONS --

-- Returns the distance between two vectors
local function dist(x1, y1, x2, y2)
    local v1 = (x1 - x2) * (x1 - x2)
    local v2 = (y1 - y2) * (y1 - y2)
    return math.sqrt(v1 + v2)
end

-- Returns if the two rooms are overlapping
local function overlaps(a, b)
    return (a.x < b.x + b.w and
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
    r.x = math.random(-1, 1)
    r.y = math.random(-1, 1)
    -- NOTE: the +1's are required, as the algo shrinks rooms by 1 later
    r.w = math.random(sizeMin + 1, sizeMax + 1)
    r.h = math.random(sizeMin + 1, sizeMax + 1)
    r.cx = r.x + r.w/2
    r.cy = r.y + r.y/2
    return r
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
                            a.x = b.x - a.w
                        -- Reposition to right side
                        else
                            a.x = b.x + b.w
                        end
                    else
                        -- Reposition to top side
                        if a.y <= 0 then
                            a.y = b.y - a.h
                        -- Reposition to bottom side
                        else
                            a.y = b.y + b.h
                        end
                    end
                    -- Break, as the B room has been found and dealt with
                    break
                end
            end
        end
    end

    -- To stop rooms from touching, decrease their width and height by 1
    for _, r in ipairs(d.rooms) do
        r.w = r.w - 1
        r.h = r.h - 1
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
    local newRooms = {}
    for i, r in ipairs(d.rooms) do
        newRooms[i] = {}
        newRooms[i].w = r.w
        newRooms[i].h = r.h
        newRooms[i].x = r.x + -left + 1
        newRooms[i].y = r.y + -top + 1
    end
    d.rooms = newRooms

    return d
end

-- Returns a 2D number array where 0 = walkable and 1 = non-walkable
-- TODO: Move a lot of this to :new() somehow!
-- Every time getArray is called it carves out hallways etc
-- Obviously this causes problemos
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
                a[x][y] = 0
            end
        end
    end

    -- Make up for the array creation and move all rooms +1 on both axis
    -- Without this, Dungeon.getRooms() room coordinates would be off by 1!
    -- Read this function's initial comment for why this is inactive
    -- IDEA: Maybe move all rooms -1 before carving then +1 again after? iunno
    -- FIXME
    --for i, r in ipairs(self.rooms) do
        --r.x = r.x + 1
        --r.y = r.y + 1
    --end

    -- Sort room array by distance to TOP LEFT (0, 0)
    for _ = 1, (#self.rooms * #self.rooms) do
        for i, r in ipairs(self.rooms) do
            if i <= #self.rooms - 2 then
                local this = dist(self.rooms[i].x, self.rooms[i].y, 0, 0)
                local next = dist(self.rooms[i+1].x, self.rooms[i+1].y, 0, 0)
                if this < next then
                    local temp = self.rooms[i]
                    self.rooms[i] = self.rooms[i+1]
                    self.rooms[i+1] = temp
                end
            end
        end
    end

    -- Carve out hallways to all of the rooms
    -- IDEA: carveHorizontal() and carveVertical() functions?
    -- Cause let's be honest, this is really ugly redundant code
    for i = 1, #self.rooms-1 do
        local ra = self.rooms[i]
        local racx = ra.x + math.floor(ra.w/2)
        local racy = ra.y + math.floor(ra.h/2)
        local rb = self.rooms[i+1]
        local rbcx = rb.x + math.floor(rb.w/2)
        local rbcy = rb.y + math.floor(rb.h/2)
        -- Start right
        if racx < rbcx then
            local lastX = 0
            for x = racx, rbcx do
                a[x][racy] = 0
                lastX = x
            end
            -- Go down
            if racy < rbcy then
                for y = racy, rbcy do
                    a[lastX][y] = 0
                end
            -- Go up
            else
                for y = rbcy, racy do
                    a[lastX][y] = 0
                end
            end
        -- Start left
        else
            local lastX = 0
            for x = rbcx, racx do
                a[x][rbcy] = 0
                lastX = x
            end
            -- Go down
            if racy < rbcy then
                for y = racy, rbcy do
                    a[lastX][y] = 0
                end
            -- Go up
            else
                for y = rbcy, racy do
                    a[lastX][y] = 0
                end
            end
        end
    end

    return a
end
