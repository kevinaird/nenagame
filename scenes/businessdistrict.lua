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
defaultChar = require("characters.default")
nenaChar = require("characters.nena")
videoCamera = require("items.videocamera")

 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
    print("business district create")
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
    local bgm = BGM:new()
    bgm:play( "music/sclubparty.mp3" )

    local world = createWorld(sceneGroup)
    self.world = world

    map = Map:new(world,{
        width=1299,
        height=1123,
        filename="art/business-district.png",
        obstructfile="art/business-district-collision.png",
        foreground="art/business-district-foreground.png",
        scaleFn=(function (x, y) 
            return 0.37 + 0.33*(y-123)/17
        end)
    })

    nena = Character:new(world,map,{
        name="player",
        spec=nenaChar,
        startX=3,
        startY=125,
        giveItemTo=function(item)
            if require("items.global")(item) then return end
            msg("I already have this!")
        end
    })
    self.nena = nena

    player = Player:new(world,map,nena)

    bouncer = Character:new(world,map,{
        name="Bouncer",
        avatar="art/guard.png",
        spec=require("characters.guard"),
        startX=35,
        startY=123,
        actions={
            Look=function() 
                msg("That person looks scary")
            end,
            Talk=function() 
                async.waterfall({
                    function(next) nena:moveTo(28,124,next) end,
                    function(next) msg(bouncer,"Please move along ma'am",next) end,
                    function(next) 
                        if composer.getVariable("knowsMAFSCancelled") then 
                            async.waterfall({
                                function(next) msg(nena,"Is this where Sharp Entertainment is located?",next) end,
                                function(next) msg(bouncer,"Yes it is",next) end,
                                function(next) msg(nena,"I have to go inside!",next) end,
                                function(next) msg(bouncer,"Sorry lady - That's not happening",next) end,
                            })
                        end
                    end,
                })
            end
        }
    })

    bellhop = Character:new(world,map,{
        name="Bell Hop",
        avatar="art/bellhop.png",
        spec=require("characters.bellhop"),
        startX=128,
        startY=123,
        actions={
            Look=function() 
                msg("It's a Bell Hop who works for the Hotel")
            end,
            Talk=function() 
                async.waterfall({
                    function(next) nena:moveTo(122,125,next) end,
                    function(next) msg(nena,"Hello!",next) end,
                    function(next) msg(bellhop,"Hello ma'am",next) end,
                    function(next) 
                        if composer.getVariable("knowsMAFSCancelled") then 
                            async.waterfall({
                                function(next) msg(nena,"Hey - Do you know if the TV Studio next door is where Sharp Entertainment is located?",next) end,
                                function(next) msg(bellhop,"Yes it is - It's pretty cool right? They make alot of quality television",next) end,
                                function(next) msg(nena,"Do you know any way I could get inside?",next) end,
                                function(next) msg(bellhop,"Well you definately can't go in the front door. But did you know this hotel is connected to the tv studio?",next) end,
                                function(next) msg(nena,"Really??",next) end,
                                function(next) msg(bellhop,"Yes!! There's a passageway you can take. Use the right-most elevator twice and you'll get there!",next) end,
                            })
                        end
                    end,
                })
            end
        }
    })

    videoCameraPic = display.newImage(world,"art/video-camera.png")
    videoCameraPic.x, videoCameraPic.y = 365, 1033  
    videoCameraPic.width, videoCameraPic.height = 45, 45
    videoCameraPic.isVisible = false
    
    videoCameraItem = Interactable:new(world,{
        name="Video Camera",
        x=365-25,
        y=1033-25,
        width=50,
        height=50,
        actions={
            Look=function()
                async.waterfall({
                    function(next) msg("Woah. Someone left a video camera in the street.", next) end,
                })
            end,
            Take=function()
                async.waterfall({
                    function(next) nena:moveTo(46,129,next) end,
                    function(next) 
                        Inventory:addItem(videoCamera)
                        videoCameraPic.isVisible = false
                        videoCameraItem:disable()
                        composer.setVariable("gotCamera",true);
                    end
                })
            end
        }
    })
    videoCameraItem:disable()

    exitToCity = Interactable:new(world,{
        name="go left",
        x=0,
        y=848,
        width=48,
        height=279,
        actions={
            Exit=function()
                async.waterfall({
                    function(next) nena:moveTo(3,125,next) end,
                    function(next) composer.gotoScene( "scenes.commercialdistrict" ) end,
                })
            end
        }
    })

    door1 = Interactable:new(world,{
        name="studio door",
        x=161,
        y=879,
        width=99,
        height=100,
        actions={
            Enter=function()
                async.waterfall({
                    function(next) nena:moveTo(26,124,next) end,
                    --function(next) composer.gotoScene( "scenes.park" ) end,
                })
            end
        }
    })

    door2 = Interactable:new(world,{
        name="hotel door",
        x=1101,
        y=884,
        width=130,
        height=95,
        actions={
            Enter=function()
                async.waterfall({
                    function(next) nena:moveTo(145,123,next) end,
                    function(next) composer.gotoScene( "scenes.hotel" ) end,
                })
            end
        }
    })

    Inventory:new()
end
 
 
-- show()
function scene:show( event )
    print("business district show")
 
    local sceneGroup = self.view
    local phase = event.phase
    local lastScene = composer.getVariable("lastScene")
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        nena = self.nena
        world = self.world
        
        self.nena:reinit()

        if not composer.getVariable("gotCamera") then
            videoCameraItem:enable()
            videoCameraPic.isVisible = true
        end

        if ( lastScene == "commercialdistrict") then
            nena:setXY(3,125)
        elseif (lastScene == "hotel") then 
            nena:setXY(146,125)
        end

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
        if ( lastScene == "commercialdistrict") then
            nena:moveTo(9,125)
        end

        composer.setVariable( "lastScene", "businessdistrict" )
    end

end
 
 
-- hide()
function scene:hide( event )
    print("business district hide")
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        if self.nena then self.nena:deinit() end
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
    print("business district destroy")
 
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