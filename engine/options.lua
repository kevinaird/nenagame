local Button = require("engine.button")

function options(optionList, nextFn)
    print(("content w=%d h=%d"):format(display.contentWidth,display.contentHeight))
    Runtime:dispatchEvent( { name="dialogOpen" } )

    local dialog = display.newGroup() -- this will hold our world
    dialog.anchorX = 0
    dialog.anchorY = 0

    local back = display.newRoundedRect(dialog, display.contentWidth/6, display.contentHeight/6, display.contentWidth*2/3, display.contentHeight*2/3, 10 )
    back.anchorX=0
    back.anchorY=0
    back:setFillColor( 0, 0.8 )

    local border = display.newRoundedRect(dialog, display.contentWidth/6+5, display.contentHeight/6+5, display.contentWidth*2/3-15, display.contentHeight*2/3-15, 5 )
    border.anchorX=0
    border.anchorY=0
    border.strokeWidth = 3
    border:setFillColor( 0, 0 )
    border:setStrokeColor( 1, 1, 1 )

    local buttons = {}

    local function clearButtons()
        -- Clear any existing buttons
        for i in ipairs(buttons) do
            buttons[i]:removeSelf()
        end
        buttons = {}
    end

    local total = 0
    for i in pairs(optionList) do
        total = total + 1
    end

    local function showOptions(idx)
        clearButtons()

        -- Create new buttons
        local pageSize = 3
        local h = (display.contentHeight*2/3-45)/pageSize
        for i=1, pageSize do
            local op = optionList[(idx*pageSize)+i]
            if op ~= nil then
                local r = display.newRect( dialog, display.contentWidth/6+22, (display.contentWidth/6+17+(h*(i-1))), 6, 6 )
                r:setFillColor(1)
                table.insert(buttons,r)

                local b = Button:new({
                    nobg=true,
                    wrap=true,
                    width=(display.contentWidth*2/3-25-24),
                    height=h-14,
                    x=display.contentCenterX+12,
                    y=(display.contentWidth/6+30+(h*(i-1))),
                    label=op.label
                },function() 
                    clearButtons()
                    dialog:removeSelf()
                    Runtime:dispatchEvent( { name="dialogClosed" } )
                    if op.fn then op.fn() 
                    elseif nextFn then nextFn(op) end
                end)
                table.insert(buttons,b)
            end
        end

        if idx > 0 then
            local b = Button:new({
                x=display.contentCenterX,
                y=display.contentHeight*1/6,
                width=30,
                height=30,
                label="/\\"
            }, function() showOptions(idx-1) end)
            table.insert(buttons,b)
        end

        print(("idx=%d, pageSize=%d, total=%d"):format(idx,pageSize,total))

        if (idx*pageSize) + pageSize < total then
            local b = Button:new({
                x=display.contentCenterX,
                y=display.contentHeight*5/6,
                width=30,
                height=30,
                label="\\/"
            }, function() showOptions(idx+1) end)
            table.insert(buttons,b)
        end
    end

    showOptions(0)

end


return options
