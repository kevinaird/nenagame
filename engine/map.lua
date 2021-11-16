local inspect = require("inspect")

local Map = {}
Map.__index = Map

function Map:new(world, opts)
    o = opts or {}
    setmetatable(o, self)
    self.__index = self

    o.background = display.newImageRect(
        world, 
        opts.filename, --"art/ian-fox-castle-makeshift-kitchen.jpg", 
        opts.width, --1920, 
        opts.height --564
    )
    o.background.name="map"
    o.background.kind="map"
    o.background.x = 0
    o.background.y = 0 
    o.background.anchorX = 0
    o.background.anchorY = 0
    
    if opts.foreground then
        o.foreground = display.newImageRect(
            world, 
            opts.foreground, --"art/ian-fox-castle-makeshift-kitchen.jpg", 
            opts.width, --1920, 
            opts.height --564
        )
        o.foreground.name="foreground"
        o.foreground.kind="map"
        o.foreground.x = 0
        o.foreground.y = 0 
        o.foreground.anchorX = 0
        o.foreground.anchorY = 0
        if opts.blendMode then o.foreground.blendMode = opts.blendMode end
    end

    o.tileSize = 8
    o.mapWidth = math.floor(o.background.width/o.tileSize)
    o.mapHeight = math.floor(o.background.height/o.tileSize)
    print(('mapWidth: %d, mapHeight: %d'):format(o.mapWidth, o.mapHeight))


    if system.getInfo("platform") ~= 'html5' then
        -- load obstruction image and built an obstruction map based on alpha layer
        local byteMap = require( "plugin.Bytemap" )
        local collisions = byteMap.loadTexture( { 
            width=o.background.width,
            height=o.background.height,
            type="image", 
            filename=opts.obstructfile, --"art/ian-fox-castle-makeshift-kitchen-obstruct.png",
            format="rgba"
        } )
        o.collisions_alpha = collisions:GetBytes{ format = "alpha" } 

    end
    
    local map = o:makeGrid(o.mapWidth, o.mapHeight)
    local map2 = o:makeGrid(o.mapWidth, o.mapHeight, true)
    
    local obstructJsonfile = system.pathForFile(opts.obstructfile,system.ResourceDirectory) .. ".json"
    print(obstructJsonfile)

    local json = require("json")
    if system.getInfo("platform") ~= 'html5' then
        print(("writing to... %s"):format(obstructJsonfile))
        local file, errorString = io.open( obstructJsonfile, "w" )
        if file then 
            local contents = json.encode(map)
            file:write( contents )
            io.close( file )
            print(("wrote to... %s"):format(obstructJsonfile))
        else
            print(("error opening file... %s"):format(errorString))
        end
        file = nil
    else 
        print(("opening... %s"):format(obstructJsonfile))
        local file, errorString = io.open( obstructJsonfile, "r" )
        if file then
            local contents = file:read( "*a" )
            io.close( file )
            --print(contents)
            map = json.decode(contents)
            print(("opened... %s"):format(obstructJsonfile))
            --print(inspect(map))
        else
            print(("error opening file... %s"):format(errorString))
        end
        file = nil
    end

    -- Value for walkable tiles
    local walkable = 0
    
    -- Library setup
    local Grid = require ("jumper.grid") -- The grid class
    local Pathfinder = require ("jumper.pathfinder") -- The pathfinder lass
    
    -- Creates a grid object
    local grid = Grid(map) 
    local grid2 = Grid(map2) 
    
    -- Creates a pathfinder object using Jump Point Search
    o.finder = Pathfinder(grid, 'JPS', walkable) 
    o.finder:setMode("DIAGONAL")
    
    -- Create a second pathfinder object that does not use obstruction map
    o.finder2 = Pathfinder(grid2, 'JPS', walkable) 
    o.finder2:setMode("ORTHOGONAL")

    world.map = o

    return o
end

function Map:charScale(x, y)
    if (self.scaleFn) then 
        -- print("using scale fn")
        return self.scaleFn(x,y) 
    end
    -- print("using default scale")
    return 1.0
end

function Map:coord2Grid(p) 
    return 1+math.max(0,math.floor(p / self.tileSize))
end

function Map:coord2GridX(p) 
    return math.min(self.mapWidth-1,self:coord2Grid(p))
end

function Map:coord2GridY(p) 
    return math.min(self.mapHeight-1,self:coord2Grid(p))
end

function Map:grid2coord(p) 
    return (p-1)*self.tileSize;
end

function Map:collissionTest(x1, y1) 
    if not (self.collisions_alpha) then return 0 end
    local x, y = self:grid2coord(x1), self:grid2coord(y1)
    local index = (y - 1) * self.background.width + x 
    return self.collisions_alpha:byte(index) 
end 

function Map:makeGrid(w, h, unobstructed) 
    grid = {}
    for i = 1, h do
        grid[i] = {}

        for j = 1, w do
            local a = self:collissionTest( j, i )
            if (unobstructed) then a=0 end
            grid[i][j] = a -- Fill the values here
        end
    end
    return grid
end

return Map