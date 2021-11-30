local composer = require( "composer" )
 
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Helper libraries
local inspect = require("inspect")
local async = require("async")

-- Game Engine libraries
local createWorld = require("engine.world")
local Map = require("engine.map")
local Character = require("engine.character")
local Player = require("engine.player")
local Interactable = require("engine.interactable")
local Inventory = require("engine.inventory")
local msg = require("engine.narrator")
local options = require("engine.options")
local BGM = require("engine.bgm")

-- Content 
defaultChar = require("characters.nena")
outdoorOodie = require("items.outdooroodie")
tile = require("items.tile")
keys = require("items.keys")
battery = require("items.battery")

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
    local bgm = BGM:new()
    bgm:play( "music/sclubparty.mp3" )

    local world = createWorld(sceneGroup)
    self.world = world

    map = Map:new(world,{
        width=1920*0.6,
        height=564*0.6,
        filename="art/nenas-apartment1.png",
        obstructfile="art/nenas-apartment-collision1.png",
        foreground="art/nenas-apartment-foreground.png",
        scaleFn=(function (x, y) 
            -- return 0.6
            if ( y >= 22 ) then 
               return 0.6 + 0.4*(y-22)/19;
            else
               return 0.6
            end
        end)
    })

    openCloset = display.newImage(world,"art/nenas-apartment-closet.png")
    openCloset.x, openCloset.y = 328, 7
    openCloset.width, openCloset.height = 205, 190
    openCloset.anchorX, openCloset.anchorY = 0, 0
    openCloset.isVisible = false

    outdoorOodiePic = display.newImage(world,"art/outdoor oodie.png")
    outdoorOodiePic.x, outdoorOodiePic.y = 408, 124  
    outdoorOodiePic.width, outdoorOodiePic.height = 45, 20
    --outdoorOodiePic.anchorX, outdoorOodiePic.anchorY = 0, 0
    outdoorOodiePic.isVisible = false
    
    outdoorOodieItem = Interactable:new(world,{
        name="Outdoor Oodie",
        x=408-25,
        y=124-10,
        width=50,
        height=20,
        actions={
            Look=function()
                async.waterfall({
                    function(next) nena:moveTo(55,26,next) end,
                    function(next) msg("That's my outdoor oodie! You can't go outside with your indoor oodie. That's disgusting!", next) end,
                })
            end,
            Take=function()
                if not composer.getVariable("knowsSnacksAreMissing") then
                    msg("I don't need that")
                else
                    async.waterfall({
                        function(next) nena:moveTo(55,26,next) end,
                        function(next) 
                            Inventory:addItem(outdoorOodie)
                            outdoorOodiePic.isVisible = false
                            outdoorOodieItem:disable()
                        end
                    })
                end
            end
        }
    })
    outdoorOodieItem:disable()

    nena = Character:new(world,map,{
        name="player",
        spec=defaultChar,
        startX=137*0.6,
        startY=51*0.6,
        giveItemTo=function(item)
            if require("items.global")(item) then return end
            if item.name == "Tile" then
                if composer.getVariable("tileHasBattery") then
                    audio.pause()
                    local backgroundMusic = audio.loadStream( "music/tile.mp3" )
                    audio.play( backgroundMusic )
                    composer.setVariable("tilePlaying",true)

                    msg("The tile music seems to be coming from the right side of the room!")

                else
                     msg("The tile doesn't seem to be working...")
                end
            else
                msg("I already have this!")
            end
        end
    })
    self.nena = nena

    player = Player:new(world,map,nena)

    closet = Interactable:new(world,{
        name="Closet",
        x=372,
        y=18,
        width=117,
        height=114,
        actions={
            Look=function()
                async.waterfall({
                    function(next) nena:moveTo(55,26,next) end,
                    function(next) msg("It's my closet!",next) end,
                })
            end,
            Talk=function()
                async.waterfall({
                    function(next) nena:moveTo(55,26,next) end,
                    function(next) msg("Helloooooooo closet!!!", next) end,
                    function(next) msg("It did't reply.",next) end,
                })
            end,
            Open=function()
                async.waterfall({
                    function(next) nena:moveTo(55,26,next) end,
                    function(next) 
                        openCloset.isVisible = not openCloset.isVisible 
                        if openCloset.isVisible and not Inventory:hasItem("Outdoor Oodie") then
                            outdoorOodiePic.isVisible = true
                            outdoorOodieItem:enable()
                        else
                            outdoorOodiePic.isVisible = false
                            outdoorOodieItem:disable() 
                        end
                    end
                })
            end
        }
    })

    drawer = Interactable:new(world,{
        name="Top Drawer",
        x=374,
        y=144,
        width=111,
        height=17,
        actions={
            Open=function()
                if not Inventory:hasItem("Tile") then
                    async.waterfall({
                        function(next) nena:moveTo(55,26,next) end,
                        function(next) msg("It's my Tile! What a life saver!", next) end,
                        function(next) Inventory:addItem(tile,next) end,
                    })
                else
                    msg("empty")
                end
            end
        }
    })

    drawer2 = Interactable:new(world,{
        name="Bottom Drawer",
        x=374,
        y=163,
        width=111,
        height=17,
        actions={
            Open=function()
                msg("empty")
            end
        }
    })

    clock = Interactable:new(world,{
        name="Clock",
        x=313,
        y=34,
        width=34,
        height=34,
        actions={
            Look=function()
                async.waterfall({
                    function(next) nena:moveTo(42,23,next) end,
                    function(next) msg("What time is it???!!!", next) end,
                    function(next) msg("OMG - It's time to watch my favourite show!",next) end,
                    function(next) msg("90 day MAFS-Fish after lockup AU",next) end,
                    function(next) msg("So much more dramz then the american version",next) end,
                })
            end
        }
    })

    degrees = Interactable:new(world,{
        name="Degrees",
        x=0,
        y=34,
        width=130,
        height=82,
        actions={
            Look=function()
                async.waterfall({
                    function(next) nena:moveTo(15,28,next) end,
                    function(next) msg("It says: This is to certify that Nena-Rae Watson", next) end,
                    function(next) msg("has fulfilled all necessary requirements",next) end,
                    function(next) msg("to prove she is the most amazing person ever on earth.",next) end,
                    function(next) msg("Obvy!",next) end,
                })
            end
        }
    })

    mirror = Interactable:new(world,{
        name="Mirror",
        x=164,
        y=68,
        width=47,
        height=47,
        actions={
            Look=function()
                async.waterfall({
                    function(next) nena:moveTo(27,23,next) end,
                    function(next) msg("I look great!", next) end,
                    function(next) msg("Obvy!",next) end,
                })
            end
        }
    })

    door = Interactable:new(world,{
        name="Door",
        x=234,
        y=45,
        width=63,
        height=126,
        actions={
            Exit=function()
                
                nena:moveTo(34,23,function()
                    if not composer.getVariable("knowsSnacksAreMissing") then
                        async.waterfall({
                            function(next) msg("What kind of psycho would go outside at this hour? It's almost 7pm!!", next) end,
                            function(next) msg("Besides it's time for me to watch my fav tv show!",next) end,
                            function(next) msg("90 day MAFS-Fish after lockup AU",next) end,
                            function(next) msg("So much more dramz then the american version",next) end
                        })
                    elseif not Inventory:hasItem("Outdoor Oodie") then
                        msg("I can't go outside in this!! This is my indoor oodie!")
                    else
                        composer.gotoScene( "scenes.outsidenenas" )
                    end
                end)

            end
        }
    })

    monstera = Interactable:new(world,{
        name="Monstera",
        x=305,
        y=107,
        width=46,
        height=72,
        actions={
            Talk=function()
                async.waterfall({
                    function(next) nena:moveTo(43,24,next) end,
                    function(next) msg("Hi Noah!!", next) end,
                })
            end,
            Look=function()
                async.waterfall({
                    function(next) nena:moveTo(43,24,next) end,
                    function(next) msg("That's Noah the Monstera", next) end,
                })
            end
        }
    })

    dinnertable = Interactable:new(world,{
        name="Table",
        x=57,
        y=222,
        width=164,
        height=38,
        actions={
            Look=function()
                async.waterfall({
                    function(next) msg("That's where I eat my Wheetabix in the morning!", next) end,
                    function(next) msg("Mmmmmmmmm Wheetabix...", next) end,
                })
            end
        }
    })

    couch = Interactable:new(world,{
        name="Couch",
        x=645,
        y=134,
        width=116,
        height=51,
        actions={
            Look=function()
                if not composer.getVariable("knowsMAFSCancelled") and not composer.getVariable("knowsSnacksAreMissing") then
                    async.waterfall({
                        function(next) nena:moveTo(89,27,next) end,
                        function(next) msg("That is where I'm going to watch my fav show!!!", next) end,
                        function(next) msg("90 day MAFS-Fish after lockup AU",next) end,
                        function(next) msg("So much more dramz then the american version",next) end
                    })
                elseif composer.getVariable("knowsSnacksAreMissing") then
                    async.waterfall({
                        function(next) nena:moveTo(89,27,next) end,
                        function(next) msg("That is where I'm going to watch my fav show!!!", next) end,
                        function(next) msg("90 day MAFS-Fish after lockup AU",next) end,
                        function(next) msg("So much more dramz then the american version",next) end,
                        function(next) msg("But I can't start the show without my fav snacks!",next) end,
                        function(next) msg("I need to get truffle chips, red box mac and cheese and a bottle of J Lohr!",next) end
                    })
                elseif composer.getVariable("knowsMAFSCancelled") then
                    msg("I can't even look at this couch anymore!!")
                end
            end,
            Sit=function()
                if not composer.getVariable("knowsSnacksAreMissing") then
                    async.waterfall({
                        function(next) nena:moveTo(89,27,next) end,
                        function(next) msg("It's time to watch my fav show!!!",next) end,
                        function(next) msg("90 day MAFS-Fish after lockup AU",next) end,
                        function(next) msg("So much more dramz then the american version",next) end,
                        function(next) msg("Wait a minute... Where's my dinner!?",next) end,
                        function(next) msg("If only there was somebody here who would make me Kale chips!",next) end,
                        function(next) msg("I can't enjoy MAFS-fish when i'm hangry! I need a box of red box mac and cheese,",next) end,
                        function(next) msg("a bag of truffle chips, and a bottle of J Lohr. STAT!!!!",next) end,
                        function(next) composer.setVariable("knowsSnacksAreMissing",true) end
                    })
                elseif composer.getVariable("knowsSnacksAreMissing") and not composer.getVariable("knowsMAFSCancelled") and not Inventory:hasItem("Mac N Cheese")  and not Inventory:hasItem("Truffle Chips") and  not Inventory:hasItem("J Lohr") then
                    async.waterfall({
                        function(next) nena:moveTo(89,27,next) end,
                        function(next) msg("I can't enjoy MAFS-fish when i'm hangry! I need a box of red box mac and cheese,",next) end,
                        function(next) msg("a bag of truffle chips, and a bottle of J Lohr. STAT!!!!",next) end,
                    })
                elseif not composer.getVariable("knowsMAFSCancelled") and Inventory:hasItem("Mac N Cheese")  and Inventory:hasItem("Truffle Chips") and Inventory:hasItem("J Lohr") then
                    async.waterfall({
                        function(next) nena:moveTo(89,27,next) end,
                        function(next) msg("I finally have all my prerequisite snacks! Truffle Chips, Redbox Mac N Cheese and a bottle of J Lohr!!",next) end,
                        function(next) msg("And that means it's finally time to watch my fav show!!!",next) end,
                        function(next) msg("90 day MAFS-Fish after lockup AU",next) end,
                        function(next) msg("So much more dramz then the american version",next) end,
                        function(next)
                            tvscreen1 = display.newImage("art/90day-mafs-fish.png")
                            tvscreen1.x, tvscreen1.y = display.contentCenterX, display.contentCenterY
                            tvscreen1.width, tvscreen1.height = 480,320
                            timer.performWithDelay( 800, function() next() end)
                        end,
                        function(next) msg("It's coming on!",next) end,
                        function(next) timer.performWithDelay( 800, function() next() end) end,
                        function(next)
                            tvscreen1:removeSelf()
                            tvscreen2 = display.newImage("art/90day-mafs-fish-cancelled.png")
                            tvscreen2.x, tvscreen2.y = display.contentCenterX, display.contentCenterY
                            tvscreen2.width, tvscreen2.height = 480,320
                            timer.performWithDelay( 800, function() next() end)
                        end,
                        function(next) msg("Huh!?! What's that?",next)  end,
                        function(next) msg("MAFS-Fish is cancelled??? This can't stand!!!",next) end,
                        function(next) msg("Nooooooooo!!! I won't let this happen!!! I have to go directly to the source! SHARP ENTERTAINMENT!",next) end,
                        function(next) 
                            tvscreen2:removeSelf()
                            composer.setVariable("knowsMAFSCancelled",true) 
                        end
                    })
                elseif composer.getVariable("knowsMAFSCancelled") then 
                    async.waterfall({
                        function(next) nena:moveTo(89,27,next) end,
                        function(next) msg("I can't sit down! 90 day MAFS-Fish after lockup AU is being cancelled!!",next) end,
                        function(next) msg("I can't let that happen!!! I have to go directly to the source! SHARP ENTERTAINMENT!",next) end,
                        function(next) composer.setVariable("knowsMAFSCancelled",true) end
                    })
                end
            end
        }
    })

    cushion = Interactable:new(world,{
        name="Cushion",
        x=762,
        y=141,
        width=23,
        height=23,
        actions={
            Look=function()
                async.waterfall({
                    function(next) nena:moveTo(89,27,next) end,
                    function(next) msg("Go Jays!!!", next) end,
                })
            end
        }
    })

    artwork = Interactable:new(world,{
        name="Artwork",
        x=1010,
        y=15,
        width=174,
        height=169,
        actions={
            Look=function()
                async.waterfall({
                    function(next) nena:moveTo(131,26,next) end,
                    function(next) msg("This is my fav art piece! I love sea horses!", next) end,
                })
            end
        }
    })

    zahara = Interactable:new(world,{
        name="Zahara",
        x=950,
        y=93,
        width=28,
        height=87,
        actions={
            Look=function()
                async.waterfall({
                    function(next) nena:moveTo(122,25,next) end,
                    function(next) msg("That's Zahara the ZZ!", next) end,
                    function(next) 
                        if composer.getVariable("tilePlaying") then 
                            async.waterfall({
                                function(next) msg("Wait.. This is where the tile music is coming from!",next) end,
                                function(next) msg("It's my spare keys to my parents house!",next) end,
                                function(next) Inventory:addItem(keys,next) end,
                                function(next) 
                                    audio.pause()
                                    local backgroundMusic = audio.loadStream( "music/sclubparty.mp3" )
                                    audio.play( backgroundMusic )
                                end
                            })
                        end
                    end
                })
            end,
            Talk=function()
                async.waterfall({
                    function(next) nena:moveTo(122,25,next) end,
                    function(next) msg("Hi Zahara!!", next) end,
                })
            end
        }
    })

    Inventory:new()
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
    local lastScene = composer.getVariable("lastScene")
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        nena = self.nena
        world = self.world

        self.nena:reinit()

        if ( lastScene == "outsidenenas") then
            nena:setXY(34,23)
        end
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

        if not lastScene and not composer.getVariable("intro") then
            async.waterfall({
                function(next) msg("Hi I'm Nena!",next) end,
                function(next) msg("I'm finally home after a long day of work!!",next) end,
                function(next) msg("And the only way I can recover from the day is with some hardcore convelescing time in my oodie!!",next) end,
                function(next) composer.setVariable("intro",true) end
            })
        end
 
        composer.setVariable( "lastScene", "nenasapartment" )
    end

end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        composer.setVariable("tilePlaying",false)
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        if self.nena then self.nena:deinit() end
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene