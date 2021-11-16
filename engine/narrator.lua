local inspect = require("inspect")

function dialog(who, text, nextFn)
    if type(who)=="string" then
        nextFn = text
        text = who
        who = nil
    end

    print(("content w=%d h=%d"):format(display.contentWidth,display.contentHeight))
    Runtime:dispatchEvent( { name="dialogOpen" } )

    local dialog = display.newGroup() -- this will hold our world
    dialog.anchorX = 0
    dialog.anchorY = 0

    local back = display.newRoundedRect(dialog, 5, display.contentHeight * 2/3, display.contentWidth - 10, display.contentHeight/3 - 10, 10 )
    back.anchorX=0
    back.anchorY=0
    back:setFillColor( 0, 0.8 )

    local border = display.newRoundedRect(dialog, 10, display.contentHeight * 2/3 + 5, display.contentWidth - 25, display.contentHeight/3 - 25, 5 )
    border.anchorX=0
    border.anchorY=0
    border.strokeWidth = 3
    border:setFillColor( 0, 0 )
    border:setStrokeColor( 1, 1, 1 )

    local avatarFile = "art/avatar.png"
    if who and who.avatar then avatarFile = who.avatar end

    print(("using avatar file: %s"):format(avatarFile))

    local avatar = display.newImage(dialog, avatarFile)
    avatar.anchorX = 0
    avatar.anchorY = 0
    avatar.x = 0
    avatar.y = display.contentHeight * 2/3 - 5
    avatar.width = display.contentHeight/3
    avatar.height = display.contentHeight/3

    local textbox = display.newEmbossedText({ 
        parent=dialog,
        text="", 
        x=avatar.width, 
        y=display.contentHeight * 2/3 + 20,
        width=display.contentWidth-avatar.width-30,
        height=display.contentHeight/3 - 50,
        fontSize=16
    })
    textbox.anchorX = 0
    textbox.anchorY = 0
    textbox.strokeWidth = 1
    textbox:setStrokeColor( 1, 1, 1 )

    local textList = mysplit(text," ")
    local mode = 0

    local function loopOverWords(idx)
        if (mode==1) then return end

        local word = textList[idx]

        if not (word) then
            mode = 1
            return
        end

        textbox.text = ("%s%s "):format(textbox.text,word)
        transition.to(textbox,{
            time=150,
            onComplete=function()
                loopOverWords(idx + 1)
            end
        })
    end

    loopOverWords(1)

    local function onTouch(event)
        print(("dialog touch! %s"):format(event.phase))
        if ( event.phase == "ended") then 
            if (mode==0) then
                mode = 1
                textbox.text = text
            else
                dialog:removeSelf()
                Runtime:dispatchEvent( { name="dialogClosed" } )
                Runtime:removeEventListener("touch",onTouch)

                if (nextFn) then nextFn() end
            end
        end
        return true
    end
    Runtime:addEventListener("touch", onTouch)  

end

function mysplit (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

return dialog
