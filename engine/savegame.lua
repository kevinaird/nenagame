local composer = require( "composer" )
local inspect = require("inspect")
local async = require("async")
local urlEncode = require("urlencode")
local urlDecode = require("urldecode")
local reversedipairs = require("reversedipairs")
local json = require("json")

local Button = require("engine.button")
local Inventory = require("engine.inventory")

return function()
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

    local textField = native.newTextField( display.contentWidth/2-50-5, display.contentHeight/6+20+16, display.contentWidth*2/3-40-52-52-5, 32 )
    native.setKeyboardFocus( textField )

    local saveBtn = nil
    local closeBtn = nil

    local buttons = {}

    local function clearButtons()
        -- Clear any existing buttons
        for i in ipairs(buttons) do
            buttons[i]:removeSelf()
        end
        buttons = {}
    end

    local closeFn = function() 
        saveBtn:removeSelf()
        closeBtn:removeSelf()
        textField:removeSelf()
        dialog:removeSelf()
        clearButtons()
        Runtime:dispatchEvent( { name="dialogClosed" } )
    end

    local saveFn = function()
        if textField.text == "" then return end
        print("save..."..textField.text)

        local fname = urlEncode(textField.text)..".save"
        local path = system.pathForFile( fname, system.DocumentsDirectory )
        print("writing to..."..path)

        local file, errorString = io.open( path, "w" )
        
        if not file then
            print( "File error: " .. errorString )
        else
            local sceneName = composer.getSceneName( "current" )
            local scene = composer.getScene( sceneName )
            local x, y = scene.nena:getXY()

            local saveData = {
                scene=sceneName,
                nena={ x=x, y=y, facing=scene.nena.facing },
                variables=composer.variables,
                inventory=Inventory.currentMenu.items,
                inventorySize=Inventory.currentMenu.itemCount
            }

            file:write(json.encode(saveData))

            io.close( file )
        end
        
        file = nil

        closeFn()
    end

    textField:addEventListener( "userInput", function(event)
        if ( event.phase == "submitted" ) then
            saveFn()
        end
    end )

    saveBtn = Button:new({
        label="Save",
        x=display.contentWidth*5/6-24-20-44-10,
        y=display.contentHeight/6+20+16,
        width=44,
        height=28
    },saveFn)

    closeBtn = Button:new({
        label="Cancel",
        x=display.contentWidth*5/6-24-20,
        y=display.contentHeight/6+20+16,
        width=44,
        height=28
    },closeFn)

    local savedGames = {}
    local savedGamesMap = {}
    local savedGamesTimes = {}
    local savedGamesCount = 0

    local lfs = require( "lfs" )
 
    -- Get raw path to the app documents directory
    local doc_path = system.pathForFile( "", system.DocumentsDirectory )
    
    for file in lfs.dir( doc_path ) do
        -- "file" is the current file or directory name
        print( "Found file: " .. file )
        local save = string.match(file,"^(.*).save$")
        if save then 
            local f = doc_path..'/'..file
            local attr = lfs.attributes(f)
            local saveTime = attr.modification

            print("saveTime for "..save.." is "..saveTime)

            --
            savedGamesMap[saveTime] = urlDecode(save)
            table.insert(savedGamesTimes,saveTime)
            savedGamesCount = savedGamesCount + 1
        end
    end
    print("savedGamesMap="..inspect(savedGamesMap))
    print("savedGamesTimes="..inspect(savedGamesTimes))

    table.sort(savedGamesTimes)
    for _, y in reversedipairs(savedGamesTimes) do 
        local save = savedGamesMap[y]
        table.insert(savedGames,save) 
    end
    print("savedGames="..inspect(savedGames))

    local currentPage = -1
    local pageSize = 4
    local pageCount = savedGamesCount / pageSize

    local function showPage(idx)
        currentPage = page

        clearButtons()

        -- Create new buttons
        local h = 30
        local top = display.contentHeight/6+20+32+32
        for i=1, pageSize do
            local save = savedGames[(idx*pageSize)+i]
            if save == nil then break end

            print("save="..save)

            local r = display.newRect( dialog, display.contentWidth/6+22, top+(h*(i-1))-8, 6, 6 )
            r:setFillColor(1)
            table.insert(buttons,r)

            local b = Button:new({
                nobg=true,
                wrap=true,
                width=(display.contentWidth*2/3-25-24),
                height=h,
                x=display.contentCenterX+12,
                y=(top+(h*(i-1))),
                label=save
            },function() 
                --closeFn()
                textField.text = save
            end)
            table.insert(buttons,b)
        end

        if idx > 0 then
            local b = Button:new({
                x=display.contentCenterX,
                y=display.contentHeight*1/6,
                width=30,
                height=30,
                label="/\\"
            }, function() showPage(idx-1) end)
            table.insert(buttons,b)
        end

        print(("idx=%d, pageSize=%d, total=%d"):format(idx,pageSize,savedGamesCount))

        if (idx*pageSize) + pageSize < savedGamesCount then
            local b = Button:new({
                x=display.contentCenterX,
                y=display.contentHeight*5/6,
                width=30,
                height=30,
                label="\\/"
            }, function() showPage(idx+1) end)
            table.insert(buttons,b)
        end
    end

    showPage(0)
end