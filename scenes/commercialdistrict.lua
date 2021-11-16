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

-- Content 
defaultChar = require("characters.nena")
carChar = require("characters.car")
potion = require("items.potion")

 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
    print("commercial district create")
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
    local backgroundMusic = audio.loadStream( "music/sclubparty.mp3" )
    audio.play( backgroundMusic )
    self.backgroundMusic = backgroundMusic

    local world = createWorld(sceneGroup)
    self.world = world

    map = Map:new(world,{
        width=2823,
        height=1128,
        filename="art/commercial-district.png",
        obstructfile="art/commercial-district-collision.png",
        foreground="art/commercial-district-foreground.png",
        scaleFn=(function (x, y) 
            return 0.37 + 0.33*(y-123)/17
        end)
    })

    nena = Character:new(world,map,{
        name="player",
        spec=defaultChar,
        startX=9,
        startY=123,
        giveItemTo=function(item)
            if require("items.global")(item) then return end
            msg("I already have this!")
        end
    })
    self.nena = nena

    player = Player:new(world,map,nena)

    car = Character:new(world,map,{
        name="car",
        spec=carChar,
        startX=37,
        startY=128,
        actions={
            Look=function()
                msg("That's a fancy looking car")
            end
        }
    })
    car.sprite.width = 170
    car.sprite.height = 80
    car.sprite.xScale = 1
    car.sprite.yScale = 0.7

    exitToPark = Interactable:new(world,{
        name="go left",
        x=0,
        y=835,
        width=35,
        height=293,
        actions={
            Exit=function()
                async.waterfall({
                    function(next) nena:moveTo(1,123,next) end,
                    function(next) composer.gotoScene( "scenes.park" ) end,
                })
            end
        }
    })

    exitToCity = Interactable:new(world,{
        name="go right",
        x=2793,
        y=872,
        width=30,
        height=256,
        actions={
            Exit=function()
                async.waterfall({
                    function(next) nena:moveTo(351,125,next) end,
                    function(next) composer.gotoScene( "scenes.businessdistrict" ) end,
                })
            end
        }
    })

    door1 = Interactable:new(world,{
        name="door1",
        x=148,
        y=890,
        width=48,
        height=83,
        actions={
            Enter=function()
                async.waterfall({
                    function(next) nena:moveTo(21,123,next) end,
                    function(next) composer.gotoScene( "scenes.9mag" ) end,
                })
            end
        }
    })

    door2 = Interactable:new(world,{
        name="door2",
        x=480,
        y=898,
        width=50,
        height=72,
        actions={
            Enter=function()
                async.waterfall({
                    function(next) nena:moveTo(62,124,next) end,
                    --function(next) composer.gotoScene( "scenes.park" ) end,
                })
            end
        }
    })

    door3 = Interactable:new(world,{
        name="door3",
        x=743,
        y=893,
        width=80,
        height=77,
        actions={
            Enter=function()
                async.waterfall({
                    function(next) nena:moveTo(99,123,next) end,
                    --function(next) composer.gotoScene( "scenes.park" ) end,
                })
            end
        }
    })

    door4 = Interactable:new(world,{
        name="door4",
        x=1058,
        y=911,
        width=78,
        height=63,
        actions={
            Enter=function()
                async.waterfall({
                    function(next) nena:moveTo(137,123,next) end,
                    function(next) composer.gotoScene( "scenes.pusacewans" ) end,
                })
            end
        }
    })

    door5 = Interactable:new(world,{
        name="door5",
        x=1623,
        y=903,
        width=39,
        height=78,
        actions={
            Enter=function()
                async.waterfall({
                    function(next) nena:moveTo(206,124,next) end,
                    function(next) composer.gotoScene( "scenes.daveandbusters" ) end,
                })
            end
        }
    })

    door6 = Interactable:new(world,{
        name="door6",
        x=2016,
        y=927,
        width=27,
        height=58,
        actions={
            Enter=function()
                async.waterfall({
                    function(next) nena:moveTo(254,124,next) end,
                    --function(next) composer.gotoScene( "scenes.park" ) end,
                })
            end
        }
    })

    door7 = Interactable:new(world,{
        name="door7",
        x=2440,
        y=911,
        width=39,
        height=73,
        actions={
            Enter=function()
                async.waterfall({
                    function(next) nena:moveTo(308,124,next) end,
                    function(next) composer.gotoScene( "scenes.lostandfound" ) end,
                })
            end
        }
    })

    door8 = Interactable:new(world,{
        name="door8",
        x=2664,
        y=902,
        width=54,
        height=83,
        actions={
            Enter=function()
                async.waterfall({
                    function(next) nena:moveTo(337,124,next) end,
                    function(next) composer.gotoScene( "scenes.jaysstore" ) end,
                })
            end
        }
    })

    Inventory:new()
end
 
 
-- show()
function scene:show( event )
    print("commercial district show")
 
    local sceneGroup = self.view
    local phase = event.phase
    local lastScene = composer.getVariable("lastScene")
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        nena = self.nena
        world = self.world
        
        self.nena:reinit()

        if ( lastScene == "park") then
            nena:setXY(3,123)
        elseif ( lastScene == "businessdistrict") then 
            nena:setXY(350,125)
        elseif ( lastScene == "9mag" ) then
            nena:setXY(21,123)
        elseif ( lastScene == "pusacewans") then
            nena:setXY(137,123)
        elseif ( lastScene == "jaysstore") then
            nena:setXY(337,125)
        elseif ( lastScene == "daveandbusters") then
            nena:setXY(206,125)
        elseif ( lastScene == "lostandfound") then
            nena:setXY(308,124)
        end

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
        if ( lastScene == "park") then
            nena:moveTo(9,123)
        elseif ( lastScene == "businessdistrict") then 
            nena:moveTo(340,125)
        end

        composer.setVariable( "lastScene", "commercialdistrict" )
    end

end
 
 
-- hide()
function scene:hide( event )
    print("commercial district hide")
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        audio.fadeOut()
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        if self.nena then self.nena:deinit() end
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
    print("commercial district destroy")
 
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