
local Character = { count=0 }
Character.__index = Character

function Character:new(world, map, opts)
    o = opts or {}
    setmetatable(o, self)
    self.__index = self

    Character.count = Character.count + 1
    local idx = Character.count
    local name = opts.name or ("character_"..idx)
    o.name = name

    o.map = map
    o.world = world
    o.sheet = graphics.newImageSheet( opts.spec.spritesheet, opts.spec.sheetOptions )
    if o.avatar==nil then o.avatar = o.spec.avatar end

    o.sprite = display.newSprite( world, o.sheet, o.spec.sequences )
    o.sprite.x = map:grid2coord(opts.startX) -- 136) --77) -- math.floor(display.contentCenterX / tileSize) * tileSize
    o.sprite.y = map:grid2coord(opts.startY) --51) -- 24) -- math.floor((display.contentCenterY + (runningCat.height * 0.25)) / tileSize) * tileSize
    o.sprite.anchorY = 0.85 
    o.sprite.name = name
    o.sprite.kind = ""
    o.facing = o.facing or 1
    o.speed = o.speed or 1


    local scale = map:charScale(opts.startX,opts.startY)
    o.sprite.xScale = scale * o.facing
    o.sprite.yScale = scale

    local collision = display.newImage( world, "art/empty.png")
    o.collision = collision
    o.collision.width, o.collision.height = o.spec.collision.width, o.spec.collision.height -- 80, 182
    o.collision.x = o.sprite.x
    o.collision.y = o.sprite.y
    o.collision.kind = "character"
    o.collision.name = o.sprite.name
    o.collision.attachedTo = o.sprite
    o.collision.anchorY = o.spec.collision.anchorY -- 0.9 
    -- o.collision.strokeWidth = 3
    -- o.collision:setStrokeColor( 1, 0, 0 )
    --o.collision:setFillColor( 0 )
    --o.collision.alpha = 0


    local function enableDebug()
        collision.strokeWidth = 3
        collision:setStrokeColor( 1, 0, 0 )
        collision:setFillColor( 0 )
    end
    Runtime:addEventListener("enableDebug", enableDebug)

    local function disableDebug()
        collision.strokeWidth = 0
        collision:setStrokeColor( 0, 0, 0 )
        collision:setFillColor( 0 )
    end
    Runtime:addEventListener("disableDebug", disableDebug)

    if world.debugMode then enableDebug() end


    -- local mask = graphics.newMask( "art/heiva-martin-character-spritesheet-mask.jpg" )
    -- runningCat:setMask( mask )

    -- sprite listener function
    local function spriteListener( event )
    
        local thisSprite = event.target  -- "event.target" references the sprite
    
        if ( event.phase == "ended" ) then 
            -- thisSprite:setSequence( "fastRun" )  -- switch to "fastRun" sequence
            thisSprite:play()  -- play the new sequence
        end
    end
    
    -- add the event listener to the sprite
    o.sprite:addEventListener( "sprite", spriteListener )
    o.sprite:play()

    -- attach an actions menu
    local ActionMenu = require("engine.actionmenu")
    ActionMenu:attach(o.collision, o.actions)

    -- ensure collision object always follows sprite everywhere
    local collision = o.collision
    function collision:enterFrame(event)
        self.x, self.y = self.attachedTo.x, self.attachedTo.y
        self.xScale, self.yScale = self.attachedTo.xScale, self.attachedTo.yScale
    end
    Runtime:addEventListener("enterFrame", o.collision)

    function collision:giveItemTo(event)
        print("character giveItemTo name="..name)
        if (event.interactable.name == name) then 
            if (opts.giveItemTo) then 
                opts.giveItemTo(event.item)
            else
                local msg = require("engine.narrator")
                msg("I can't give this to "..name)
            end
        end
    end
    Runtime:addEventListener("giveItemTo", o.collision)

    o.pathIndex = 0
    o.hasInit = true

    table.insert(world.characters, o)

    return o
end

function Character:reinit() 
    if self.hasInit then return end
    Runtime:addEventListener("giveItemTo",self.collision)
    Runtime:addEventListener("enterFrame", self.collision)
    self.hasInit = true
end

function Character:deinit() 
    if not self.hasInit then return end
    Runtime:removeEventListener("giveItemTo",self.collision)
    Runtime:removeEventListener("enterFrame", self.collision)
    self.hasInit = false
end

function Character:removeSelf() 
    Runtime:removeEventListener("giveItemTo",self.collision)
    Runtime:removeEventListener("enterFrame", self.collision)
    self.sprite:removeSelf()
    self.sprite = nil
    self.collision:removeSelf()
    self.collision = nil
end

-- 1 for right and -1 for left
function Character:setFacing(f)
    self.facing = f
    self.sprite.xScale = math.abs(self.sprite.xScale) * self.facing
end

function Character:setXY(x, y)
    self.sprite.x = map:grid2coord(x)
    self.sprite.y = map:grid2coord(y)
    self.collision.x, self.collision.y = self.sprite.x, self.sprite.y

    local scale = self.map:charScale(x, y)
    self.sprite.xScale = scale * self.facing
    self.sprite.yScale = scale
end

function Character:getXY()
    return map:coord2Grid(self.sprite.x), map:coord2Grid(self.sprite.y)
end

function Character:moveTo(endx, endy,onFinish)
    print(('move to x: %d - y: %d'):format(endx, endy))
    print(('background x: %d - y: %d'):format(self.map.background.x, self.map.background.y))
    print(('sprite x: %d - y: %d'):format(self.sprite.x, self.sprite.y))

    self.sprite:setSequence( "walk" )
    self.sprite:play()

    -- Define start and goal locations coordinates
    local startx, starty = self.map:coord2GridX(self.sprite.x), self.map:coord2GridY(self.sprite.y)

    print(('start: x: %d - y: %d'):format(startx, starty))
    print(('end: x: %d - y: %d'):format(endx, endy))

    self.pathIndex = self.pathIndex + 1
    local currentPathId = self.pathIndex

    local function processNode(nodes,count)
        if currentPathId ~= self.pathIndex then return end

        local node = nodes[count]
        if node == nil then
            self.sprite:setSequence( "stand" )
            self.sprite:play()
            if onFinish then onFinish() end
            return
        end

        local x, y = node:getX(), node:getY()

        print(('Step: %d - x: %d - y: %d'):format(count, x, y))

        if (self.map:collissionTest( x, y ) ~= 0) then
            self.sprite:setSequence( "stand" )
            self.sprite:play()
            if onFinish then onFinish() end
            return
        end

        local targetx = self.map:grid2coord(x)
        local targety = self.map:grid2coord(y)

        if (targetx > self.sprite.x) then
            self.facing = 1
        elseif (targetx < self.sprite.x) then
            self.facing = -1
        end
        self.sprite.xScale = math.abs(self.sprite.xScale) * self.facing

        local distance = math.sqrt(math.pow(self.sprite.x - targetx,2) + math.pow(self.sprite.y - targety,2))
        local scale = self.map:charScale(x, y) 

        -- print(('distance: %d, scale: %0.8f, facing: %d'):format(distance, scale, self.facing))

        transition.to( self.sprite, { 
            x=targetx, 
            y=targety, 
            xScale=scale * self.facing,
            yScale=scale,
            time=5 * distance * 0.75/scale * self.speed, 
            onComplete = function() 
                if (self.onMove) then self.onMove() end
                processNode(nodes,count+1)
            end
        } )
    end

    -- Calculates the path
    local path = self.map.finder:getPath(startx, starty, endx, endy)
    if path then
        print("using path1");
        local nodes = {}
        for node in path:nodes() do table.insert(nodes,node) end

        processNode(nodes,1)

    elseif system.getInfo("platform") ~= 'html5' then
        path = self.map.finder2:getPath(startx, starty, endx, endy)
        if path then
            print("using path2");
            local nodes = {}
            for node in path:nodes() do table.insert(nodes,node) end

            processNode(nodes,1)
        else
            print("no path2");
            self.sprite:setSequence( "stand" )
            self.sprite:play()
        end
    else 
        self.sprite:setSequence( "stand" )
        self.sprite:play()
    end
end


return Character