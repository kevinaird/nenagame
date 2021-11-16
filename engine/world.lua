
function createWorld(_world)
    if _world then world = _world
    else world = display.newGroup() end

    world.anchorX = 0
    world.anchorY = 0

    world.debugMode = false

    world.enableDebug = function()
        world.debugMode = true
        Runtime:dispatchEvent( { name="enableDebug"} )
    end

    world.disableDebug = function()
        world.debugMode = false
        Runtime:dispatchEvent( { name="disableDebug"} )
    end

    Runtime:addEventListener( "key", function(event)
        if ( event.phase == "up" and event.keyName == "d" ) then
            if world.debugMode then 
                world.disableDebug()
            else
                world.enableDebug()
            end
        end
        return false
    end)

    world.characters = {}
    world.interactables = {}

    world.getOrderedLayers = function()
        local children = {}
        local childkeys = {}
        local foreground = nil

        if world.numChildren then 
    
            for i=1,world.numChildren do 
                -- print(("world[%d].name=%s"):format(i,world[i].name))
                if (world[i].name == "foreground") then
                    foreground = world[i]
                elseif (world[i].name ~= "map") then 
                    if not (children[world[i].y]) then table.insert(childkeys,world[i].y) end
                    children[world[i].y] = children[world[i].y] or {}
                    table.insert(children[world[i].y],world[i])
                end
            end
            table.sort(childkeys)

        end

        return {
            children=children,
            childkeys=childkeys,
            foreground=foreground
        }
    end

    -- keep reording the worlds z layer based on y position
    local function reorderWorld()
        local out = world.getOrderedLayers()
        local children = out.children
        local childkeys = out.childkeys
        local foreground = out.foreground
    
        -- print("Children order start ---->")
        for _, y in ipairs(childkeys) do 
            for c in pairs(children[y]) do
                -- print(("Children order: y=%d, name=%s"):format(y, children[y][c].name))
                -- world:insert(children[y][c]) 
                children[y][c]:toFront()
            end
        end
        if foreground then foreground:toFront() end
        -- print("Children order end <----")
    end
    Runtime:addEventListener("enterFrame", reorderWorld)    

    return world
end

return createWorld