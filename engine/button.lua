
local Button = { }
Button.__index = Button

function Button:new(opts, actionFn)
    local g = display.newGroup()
    g.x = opts.x
    g.y = opts.y
    g.label = opts.label

    local b = display.newRect( g, 0, 0, opts.width, opts.height )
    if (opts.nobg~=true) then
        b.strokeWidth = 3
        b:setFillColor( 0, 0.8 )
        b:setStrokeColor( 1, 1, 1 )
    else
        b:setFillColor(0,0.01)
    end
    b.label = opts.label
    b.about = opts.about

    local textArgs = { 
        parent=g, 
        x=0, y=0, 
        text=opts.label,
        fontSize=12
    }
    if opts.wrap then
        textArgs.width = opts.width - 2 
        textArgs.height = opts.height - 2
    end

    display.newText(textArgs)

    local function fireAction(event)
        local thisButton = event.target
        print(("fireAction! %s - %s"):format(thisButton.label,event.phase))

        if ( event.phase == "began") then 
            display.getCurrentStage():setFocus( thisButton )
            thisButton.isFocus = true
        elseif ( thisButton.isFocus ) then
            if ( event.phase == "ended" and actionFn) then
                actionFn(thisButton)
            end

            if ( event.phase == "ended" or event.phase == "cancelled" ) then
                display.getCurrentStage():setFocus( nil )
                thisButton.isFocus = nil
            end
        end
        
        return true
    end
    b:addEventListener( "touch", fireAction )

    return g
end

return Button