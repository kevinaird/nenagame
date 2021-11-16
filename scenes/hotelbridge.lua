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
potion = require("items.potion")

 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
    local backgroundMusic = audio.loadStream( "music/sclubparty.mp3" )
    audio.play( backgroundMusic )
    self.backgroundMusic = backgroundMusic

    local world = createWorld(sceneGroup)
    self.world = world

    map = Map:new(world,{
        width=845,
        height=338,
        filename="art/hotel-bridge.png",
        obstructfile="art/hotel-bridge-collision.png",
        foreground="art/hotel-bridge-foreground.png",
        scaleFn=(function (x, y) 
            if ( y >= 25 ) then 
               return 0.5 + 0.4*(y-25)/16;
            else
               return 0.5
            end
        end)
    })

    nena = Character:new(world,map,{
        name="player",
        spec=defaultChar,
        startX=83,
        startY=26,
        giveItemTo=function(item)
            if require("items.global")(item) then return end
            msg("I already have this!")
        end
    })
    self.nena = nena

    player = Player:new(world,map,nena)

    elevator1 = Interactable:new(world,{
        name="elevator1",
        x=622,
        y=59,
        width=81,
        height=132,
        actions={
            Use=function()
                composer.setVariable( "lastScene", "hotelbridge" )
                async.waterfall({
                    function(next) nena:moveTo(83,25,next) end,
                    function(next) composer.gotoScene( "scenes.hotel" ) end,
                })
            end
        }
    })

    elevator2 = Interactable:new(world,{
        name="elevator2",
        x=733,
        y=59,
        width=81,
        height=132,
        actions={
            Use=function()
                composer.setVariable( "lastScene", "hotelbridge" )
                async.waterfall({
                    function(next) nena:moveTo(98,25,next) end,
                    function(next) composer.gotoScene( "scenes.hotelhallway") end,
                })
            end
        }
    })

    bridge = Interactable:new(world,{
        name="bridge",
        x=80,
        y=0,
        width=98,
        height=190,
        actions={
            walk=function()
                async.waterfall({
                    function(next) nena:moveTo(18,23,next) end,
                    function(next) composer.gotoScene( "scenes.tvstudio") end,
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

        if (lastScene == "hotel") then
            nena:setXY(83,26)
        elseif (lastScene == "hotelhallway") then
            nena:setXY(98,26)
        elseif (lastScene == "tvstudio") then
            nena:setXY(18,23)
        end
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        if (lastScene == "tvstudio") then
            nena:moveTo(21,29)
        end
 
        composer.setVariable( "lastScene", "hotelbridge" )
    end

end
 
 
-- hide()
function scene:hide( event )
 
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