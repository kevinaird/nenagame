
local ActionMenu = { currentMenu=false }
ActionMenu.__index = ActionMenu

function closeCurrent()
    if (ActionMenu.currentMenu) then
        ActionMenu.currentMenu.close()
    end
end

function ActionMenu:new(opts)
    o = opts or {}
    setmetatable(o, self)
    self.__index = self

    closeCurrent()

    local x, y = opts.event.x, opts.event.y

    local function sx(x) return math.max(25,math.min(display.contentWidth-50,x)) end
    local function sy(y) return math.max(25,math.min(display.contentHeight-50,y)) end

    local label = display.newText({ 
        x=x, y=y, 
        text=opts.about,
        fontSize=14
     })
    o.label = label

    local buttons = {}
    local buttonCount = 0

    local msg = require("engine.narrator")

    local actions = o.actions or {
        Use=function() msg("I can't use that") end,
        Take=function() msg("I can't take that") end,
        Talk=function() msg("I can't talk to that") end,
        Touch=function() msg("I don't want to touch that") end,
        Look=function() msg("Nothing to see") end,
    }

    local Button = require("engine.button")

    local function createButton(label,actionFn)

        local g = Button:new({
            label=label,
            x=x, y=y,
            width=50, height=50
        },function(thisButton)
            print(("ACTION FIRED! %s !!"):format(thisButton.label))
            
            if (actionFn) then actionFn() end

            local event = { 
                name="actionMenu", 
                target=thisButton, 
                label=thisButton.label,
                about=thisButton.about
            }
            Runtime:dispatchEvent( event )

            closeCurrent()
        end)

        buttonCount = buttonCount + 1
        table.insert(buttons, g)

        return g
    end

    for i in pairs(actions) do
        createButton(i,actions[i])
    end


    o.buttons = buttons

    local buttonPositions = {}

    local r = 80
    for i = 1, buttonCount do
        local angle = i * math.pi / math.max(math.floor((buttonCount+1)/2),1)
        local ptx, pty = x + r * math.cos( angle ), y + r * math.sin( angle )
        local b = buttons[i]
        -- print(("b.x=%s"):format(b.label))
        table.insert(buttonPositions,{ b=b, label=(b.label or "na"), x=sx(ptx), y=sy(pty) })
        -- transition.to( b, { x=sx(ptx), y=sy(pty), time=200 })
    end
    for i = 1, buttonCount do
        local pos = buttonPositions[i]
        local ax1, ay1 = pos.x - 25, pos.y - 25
        local ax2, ay2 = pos.x + 25, pos.y + 25
        local direction = pos.x < display.contentCenterX
        local hasOverlap = true
        local fixAttemptCount = 0

        -- print(("overlap detection... label=%s, ax1=%d, ay1=%d, ax2=%d, ay2=%d"):format(pos.label,ax1,ay1,ax2,ay2))

        while hasOverlap and fixAttemptCount<50 do
            hasOverlap = false
            fixAttemptCount = fixAttemptCount + 1
            for j = 1, buttonCount do
                if (i == j) then
                else
                    local pos2 = buttonPositions[j]
                    local bx1, by1 = pos2.x - 25, pos2.y - 25
                    local bx2, by2 = pos2.x + 25, pos2.y + 25

                    -- print(("overlap detection... label=%s, bx1=%d, by1=%d, bx2=%d, by2=%d"):format(pos2.label,bx1,by1,bx2,by2))

                    if (ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1) then
                        -- print(("overlap detected --> %s vs %s"):format(pos.label,pos2.label))
                        hasOverlap = true
                        if (direction) then pos.x = sx(pos.x + 50)
                        else pos.x = sx(pos.x - 50) end
                        ax1, ay1 = pos.x - 25, pos.y - 25
                        ax2, ay2 = pos.x + 25, pos.y + 25
                    end
                end
            end
        end
        transition.to( pos.b, { x=pos.x, y=pos.y, time=200 })
    end
    
    self.currentMenu = o

    Runtime:dispatchEvent({ name="actionMenuOpen" })

    Runtime:addEventListener("dialogOpen",closeCurrent)
    Runtime:addEventListener("dialogClosed",closeCurrent)
    Runtime:addEventListener("inventoryShown",closeCurrent)
    Runtime:addEventListener("playerMove", closeCurrent)

    return o
end

function ActionMenu:close()
    for b in pairs(ActionMenu.currentMenu.buttons) do
        ActionMenu.currentMenu.buttons[b]:removeSelf()
    end
    ActionMenu.currentMenu.label:removeSelf()
    ActionMenu.currentMenu = false
end

function ActionMenu:attach(obj,actions)
    local canAct = true
    Runtime:addEventListener("dialogOpen",function() canAct=false end)
    Runtime:addEventListener("dialogClosed",function() canAct=true end)

    local function showMenu(event)
        local thisSprite = event.target
        print(("showMenu! %s - %s"):format(thisSprite.name,event.phase))
        if ( thisSprite.name ~= "player" and canAct and thisSprite.disableActionMenu ~= true ) then
            if ( event.phase == "began") then 
                display.getCurrentStage():setFocus( thisSprite )
                thisSprite.isFocus = true
            elseif ( thisSprite.isFocus ) then
                if ( event.phase == "ended") then
                    ActionMenu:new({ 
                        about=thisSprite.name, 
                        event=event, 
                        actions=actions 
                    })
                end

                if ( event.phase == "ended" or event.phase == "cancelled" ) then
                    display.getCurrentStage():setFocus( nil )
                    thisSprite.isFocus = nil
                end
            end
            return true
        end
    end
    obj:addEventListener( "touch", showMenu )
end

return ActionMenu