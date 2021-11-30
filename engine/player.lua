
local Player = {}
Player.__index = Player

function Player:new(world, map, character, opts)
    o = {}
    setmetatable(o, self)
    o.__index = self

    o.world = world
    o.map = map
    o.character = character

    local canMove = true
    local isClosing = false
    Runtime:addEventListener("dialogOpen",function() 
        print("dialogOpen")
        canMove=false 
        isClosing = false
    end)
    Runtime:addEventListener("dialogClosed",function() 
        print("dialogClosed")
        isClosing = true
        timer.performWithDelay(100, function()
            if isClosing then canMove=true end
        end)
    end)

    local function onTouch(event)
        local thisSprite = event.target
        if ( event.phase == "ended" and thisSprite.name=="map" and canMove ) then 
            print(('onTouch "%s" move to x: %d - y: %d'):format(thisSprite.name,event.x, event.y))
            print(('world x: %d - y: %d'):format(world.x, world.y))
    
            local x, y = map:coord2GridX(event.x - world.x), map:coord2GridY(event.y - world.y)
            character:moveTo(x, y)
            
            local event = { name="playerMove", target=thisSprite, x=x, y=y }
            Runtime:dispatchEvent( event )

            return true
        end
    end
    map.background:addEventListener( "touch", onTouch )

    local function enterFrame(event)
        if character == nil then return end
        if character.sprite == nil then return end
        if not character.hasInit then return end

        pcall(function()
            -- easiest way to scroll a map based on a character
            -- find the difference between the hero and the display center
            -- and move the world to compensate
            local hx, hy = character.sprite:localToContent(0,0)
            hx, hy = display.contentCenterX - hx, display.contentCenterY - hy
        
            -- print(("world.x=%d world.y=%d hx=%d hy=%d"):format(world.x,world.y,hx,hy))
            -- print(("x=%d y=%d"):format(-background.width +display.contentCenterX,-background.height+display.contentCenterY))
            world.x, world.y = 
                math.max(-map.background.width -map.background.x+display.contentWidth,math.min(0,world.x + hx)), 
                math.max(-map.background.height-map.background.y+display.contentHeight,math.min(0,world.y + hy))
        end)
    end
    Runtime:addEventListener("enterFrame", enterFrame)

    return o
end


return Player