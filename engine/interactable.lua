
local Interactable = { count=0 }
Interactable.__index = Interactable

function Interactable:new(world, opts)
    o = opts or {}
    setmetatable(o, self)
    self.__index = self
    
    o.world = world

    Interactable.count = Interactable.count + 1
    local idx = Interactable.count
    local name = opts.name or ("interactable_"..idx)
    o.name = name

    local sprite = display.newImage( world, "art/empty.png")
    o.sprite = sprite
    o.sprite.width, o.sprite.height = opts.width, opts.height
    o.sprite.x = opts.x
    o.sprite.y = opts.y
    o.sprite.anchorX = 0
    o.sprite.anchorY = 0
    o.sprite.name = name
    o.sprite.kind = "interactable"

    local function enableDebug()
        sprite.strokeWidth = 3
        sprite:setStrokeColor( 1, 0, 0 )
        sprite:setFillColor( 0 )
    end
    Runtime:addEventListener("enableDebug", enableDebug)

    local function disableDebug()
        sprite.strokeWidth = 0
        sprite:setStrokeColor( 0, 0, 0 )
        sprite:setFillColor( 0 )
    end
    Runtime:addEventListener("disableDebug", disableDebug)

    if world.debugMode then enableDebug() end

    -- attach an actions menu
    local ActionMenu = require("engine.actionmenu")
    ActionMenu:attach(o.sprite, o.actions)

    Runtime:addEventListener("useItemOn", function(event)
        if (event.interactable.name == name) then 
            if (opts.useItemOn) then 
                opts.useItemOn(event.item)
            else
                local msg = require("engine.narrator")
                msg("I can't use this on "..name)
            end
        end
    end)

    table.insert(world.interactables, o)

    return o
end

function Interactable:disable()
    self.sprite.disableActionMenu = true
end

function Interactable:enable()
    self.sprite.disableActionMenu = false
end

return Interactable