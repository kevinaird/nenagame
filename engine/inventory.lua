local Button = require("engine.button")
local InventoryItem = require("engine.inventoryitem")

local Inventory = { currentMenu=false, menuIdx=0, items={}, itemCount=0, itemIndex=1, pageSize=5 }
Inventory.__index = Inventory

function Inventory:new(opts)
    o = opts or {}
    setmetatable(o, self)
    self.__index = self

    if (self.currentMenu) then return self.currentMenu end

    o.toggleBtn = Button:new({
        label="Inventory",
        x=40,
        y=display.contentHeight - 25,
        width=60,
        height=30
    },o.toggle)

    o.menuBtn = Button:new({
        label="Menu",
        x=40,
        y=display.contentHeight - 65,
        width=60,
        height=30
    },function()
        options({
            {
                label="Return to Game",
                fn=function() end,
            },
            {
                label="Save Game",
                fn=function()
                    require("engine.savegame")()
                end,
            },
            {
                label="Load Game",
                fn=function()
                    require("engine.loadgame")()
                end,
            },
            -- {
            --     label="New Game",
            --     fn=function()
            --         local composer = require("composer")
            --         for k in pairs(composer.variables) do composer.variables[k] = nil end
            --         composer.removeHidden()
            --         composer.removeScene( composer.getSceneName( "current" ) )
            --         composer.gotoScene( "scenes.nenasapartment" )
            --      end,
            -- },
        })
    end)

    o.showing =  false
    o.itemObjects = {}

    self.currentMenu = o

    Runtime:addEventListener("dialogOpen",function()
        Inventory.currentMenu:hide()
        Inventory.currentMenu.toggleBtn.isVisible = false
        Inventory.currentMenu.menuBtn.isVisible = false
    end)
    Runtime:addEventListener("dialogClosed",function()
        Inventory.currentMenu:hide()
        Inventory.currentMenu.toggleBtn.isVisible = true
        Inventory.currentMenu.menuBtn.isVisible = true
    end)
    Runtime:addEventListener("playerMove",function()
        Inventory.currentMenu:hide()
    end)
    Runtime:addEventListener("giveItemTo",function() 
        Inventory.currentMenu:hide()
    end)
    Runtime:addEventListener("useItemOn",function() 
        Inventory.currentMenu:hide()
    end)
    Runtime:addEventListener("actionMenuOpen",function() 
        Inventory.currentMenu:hide()
    end)

    return o
end

function Inventory:toggle()
    if (Inventory.currentMenu.showing) then
        Inventory.currentMenu:hide()
    else
        Inventory.currentMenu:show()
    end
end

function Inventory:show(readonly, nextFn)
    print("SHOW INVENTORY itemCount="..Inventory.currentMenu.itemCount)

    Inventory.currentMenu.menuIdx = Inventory.currentMenu.menuIdx + 1

    local group = display.newGroup() -- this will hold our world
    group.anchorX = 0
    group.anchorY = 0

    local back = display.newRoundedRect(group, 80, display.contentHeight - 80, 20, 75, 10 )
    back.anchorX=0
    back.anchorY=0
    back:setFillColor( 0, 0.8 )

    transition.to(back,{
        width=(display.contentWidth - 90),
        time=200,
        onComplete=function()
            local border = display.newRoundedRect(group, 85, display.contentHeight - 75, display.contentWidth - 105, 60, 5 )
            border.anchorX=0
            border.anchorY=0
            border.strokeWidth = 3
            border:setFillColor( 0, 0 )
            border:setStrokeColor( 1, 1, 1 )
            Inventory.currentMenu.border = border

            local pageSize = 6 --math.floor((display.contentWidth - 160)/50)-1
            Inventory.currentMenu.pageSize = pageSize

            for i=Inventory.currentMenu.itemIndex,math.min(Inventory.currentMenu.itemIndex+pageSize-1,Inventory.currentMenu.itemCount) do
                local itemSpec = Inventory.currentMenu.items[i]
                if (itemSpec) then 
                    local item = InventoryItem:new({
                        name=itemSpec.name,
                        filename=itemSpec.filename,
                        parent=group,
                        index=i,
                        x=(80 + ((i-Inventory.currentMenu.itemIndex+1) * 55)),
                        y=(display.contentHeight - 42),
                        readonly=readonly
                    })
                    table.insert(Inventory.currentMenu.itemObjects,item)
                end
            end

            if (Inventory.currentMenu.itemIndex+pageSize-1<Inventory.currentMenu.itemCount) then
                Inventory.currentMenu.nextBtn = Button:new({
                    label=">",
                    x=display.contentWidth-20,
                    y=display.contentHeight - 42,
                    width=20,
                    height=20
                },Inventory.currentMenu.nextPage)
            end

            if (Inventory.currentMenu.itemIndex>1) then
                Inventory.currentMenu.prevBtn = Button:new({
                    label="<",
                    x=90,
                    y=display.contentHeight - 42,
                    width=20,
                    height=20
                },Inventory.currentMenu.prevPage)
            end

            Runtime:dispatchEvent({ name="inventoryShown"})
            if nextFn then nextFn() end
        end
    })

    Inventory.currentMenu.back = back
    Inventory.currentMenu.group = group
    Inventory.currentMenu.showing = true
end

function Inventory:hide()
    print("HIDE INVENTORY")

    if (Inventory.currentMenu.group) then 
        local idx = Inventory.currentMenu.menuIdx
        -- if Inventory.currentMenu.border then Inventory.currentMenu.border:removeSelf() end
        transition.to(Inventory.currentMenu.back,{
            width=20,
            time=200,
            onComplete=function()
                if (idx == Inventory.currentMenu.menuIdx) then
                    Inventory.currentMenu.remove()
                end
            end
        })
    end

    Inventory.currentMenu.showing = false

    Runtime:dispatchEvent({ name="inventoryHidden "})
end

function Inventory:remove()
    if (Inventory.currentMenu.group ~= nil) then
        Inventory.currentMenu.group:removeSelf()
        Inventory.currentMenu.group = nil
        Inventory.currentMenu.border = nil
        Inventory.currentMenu.back = nil
    end
    if (Inventory.currentMenu.nextBtn ~= nil) then
        Inventory.currentMenu.nextBtn:removeSelf()
        Inventory.currentMenu.nextBtn = nil
    end
    if (Inventory.currentMenu.prevBtn ~= nil) then
        Inventory.currentMenu.prevBtn:removeSelf()
        Inventory.currentMenu.prevBtn = nil
    end
    for i in pairs(Inventory.currentMenu.itemObjects) do
        local item = Inventory.currentMenu.itemObjects[i]
        item:remove()
        Inventory.currentMenu.itemObjects[i] = nil
    end
end

function Inventory:nextPage()
    Inventory.currentMenu:remove()
    Inventory.currentMenu.itemIndex = Inventory.currentMenu.itemIndex + Inventory.currentMenu.pageSize
    Inventory.currentMenu:show()
end

function Inventory:prevPage()
    Inventory.currentMenu:remove()
    Inventory.currentMenu.itemIndex = math.max(1,Inventory.currentMenu.itemIndex - Inventory.currentMenu.pageSize)
    Inventory.currentMenu:show()
end

function Inventory:hasItem(itemName) 
    for i, v in ipairs (Inventory.currentMenu.items) do 
        if (v.name == itemName) then
            return true
        end
    end
    return false
end

function Inventory:addItem(item, nextFn)
    table.insert(Inventory.currentMenu.items,item) 

    Inventory.currentMenu.itemCount = Inventory.currentMenu.itemCount + 1
    Inventory.currentMenu.itemIndex = math.floor((Inventory.currentMenu.itemCount-1) / Inventory.currentMenu.pageSize) * Inventory.currentMenu.pageSize + 1
    print("addItem itemCount="..Inventory.currentMenu.itemCount)
    print("addItem itemIndex="..Inventory.currentMenu.itemIndex)

    Inventory.currentMenu:remove()
    

    if (nextFn) then
        Inventory.currentMenu:show(true, function()
            local lastIdx = Inventory.currentMenu.itemCount - Inventory.currentMenu.itemIndex + 1
            print(("lastIdx=%d, itemCount=%d, itemIndex=%d"):format(lastIdx,Inventory.currentMenu.itemCount,Inventory.currentMenu.itemIndex))
    
            local lastItem = Inventory.currentMenu.itemObjects[lastIdx]
            local y = lastItem.img.y
    
            transition.to(lastItem.img,{
                y=y-40,
                time=80,
                onComplete=function()
                    transition.to(lastItem.img,{
                        y=y,
                        time=60
                    })
                end
            })
        end)
        
        timer.performWithDelay( 800, function()
            Inventory.currentMenu:hide()
            nextFn()
        end)
    else
        Inventory.currentMenu:show()
    end

end

function Inventory:removeItem(item, nextFn)
    for i, v in ipairs (Inventory.currentMenu.items) do 
        if (v.name == item.name) then
            table.remove(Inventory.currentMenu.items, i)
            Inventory.currentMenu.itemCount = Inventory.currentMenu.itemCount - 1
            break
        end
    end

    if nextFn then nextFn() end
end

return Inventory