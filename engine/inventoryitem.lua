local inspect = require("inspect")
local reversedipairs = require("reversedipairs")

local InventoryItem = { count=0 }
InventoryItem.__index = InventoryItem

function InventoryItem:new(opts)
    o = opts or {}
    setmetatable(o, self)
    self.__index = self

    InventoryItem.count = InventoryItem.count + 1
    local idx = InventoryItem.count
    local name = opts.name or ("item_"..idx)
    o.name = name

    o.img = display.newImage(o.parent,o.filename)
    o.img.x, o.img.y = o.x, o.y
    o.img.width, o.img.height = 50, 50
    o.img.item = o --function() return o end
    o.img.name = name

    local function onTouch(event)
        local thisItem = event.target
        local p = thisItem.item --()
        -- print("onTouch item = "..p.name)

        if ( event.phase == "began") then 
            display.getCurrentStage():setFocus( thisItem )
            thisItem.isFocus = true

            thisItem.alpha = 0
            thisItem.ghost = display.newImage(p.filename)
            thisItem.ghost.x, thisItem.ghost.y = event.x, event.y
            thisItem.ghost.width, thisItem.ghost.height = 50, 50
            thisItem.ghost.alpha = 0.8
          
        elseif ( thisItem.isFocus ) then

            thisItem.ghost.x, thisItem.ghost.y = event.x, event.y

            if ( event.phase == "ended" or event.phase == "cancelled" ) then
                display.getCurrentStage():setFocus( nil )
                thisItem.isFocus = nil

                local x, y = event.x - world.x, event.y - world.y
                local isMatch = false

                print(("Looking for overlaps.. %d, x=%d, y=%d"):format(world.numChildren,x,y))
                
                local out = world.getOrderedLayers()
                local children = out.children
                local childkeys = out.childkeys

                --for i=1,world.numChildren do
                    --local child = world[i]
                for _, yy in reversedipairs(childkeys) do 
                    for c in pairs(children[yy]) do
                        local child = children[yy][c]
                        
                        local x1, y1 = child.x-(child.anchorX*child.width), child.y-(child.anchorY*child.height)
                        local x2, y2 = x1+child.width, y1+child.height
                        
                        -- print("child="..inspect(child))
                        if child.name then
                            print(("child.name.. %s (%s) x1=%d, y1=%d, x2=%d, y2=%d"):format(child.name,child.kind,x1,y1,x2,y2))
                        end

                        if (x1<x and x2>x and y1<y and y2>y) then
                            print(("found overlap ==> %s (%s)"):format(child.name,child.kind))
                            if (child.kind == "interactable") then
                                print(("USE ITEM ON! %s (%s) item=%s"):format(child.name,child.kind,p.name))
                                Runtime:dispatchEvent({ 
                                    name="useItemOn",
                                    interactable=child,
                                    item=p
                                })
                                isMatch = true
                                break
                            elseif (child.kind == "character") then
                                print(("GIVE ITEM TO! %s (%s) item=%s"):format(child.name,child.kind,p.name))
                                Runtime:dispatchEvent({ 
                                    name="giveItemTo",
                                    interactable=child,
                                    item=p
                                })
                                isMatch = true
                                break
                            end
                        end
                    end
                    if isMatch then break end
                end

                thisItem.ghost:removeSelf()
                thisItem.ghost = nil
                
                if isMatch then thisItem.alpha = 0 
                else 
                    thisItem.alpha = 1 
                    local msg = require("engine.narrator")
                    msg("That doesn't work...")
                end

                
            end
        end
        
        return true
    end

    if (opts.readonly ~= true) then
        o.img:addEventListener( "touch", onTouch )
    end

    return o
end

function InventoryItem:remove()
    --print("InventoryItem:remove!")
    if (self.img ~= nil) then

        if (self.img.ghost ~= nil) then
            --print("ghost:remove!")
            self.img.ghost:removeSelf()
            self.img.ghost = nil
        end

        --print("img:remove!")
        self.img:removeSelf()
        self.img = nil

    end
end

return InventoryItem