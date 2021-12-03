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
potion = require("items.potion")

 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
    local world = createWorld(sceneGroup)
    self.world = world

    map = Map:new(world,{
        width=845,
        height=338,
        filename="art/hotel-hallway.png",
        obstructfile="art/hotel-hallway-collision.png",
        foreground="art/hotel-hallway-foreground.png",
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
                composer.setVariable( "lastScene", "hotelhallway" )
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
                async.waterfall({
                    function(next) nena:moveTo(98,25,next) end,
                    function(next) 
                        if composer.getVariable("knowsMAFSCancelled") then 
                            composer.gotoScene( "scenes.hotelbridge") 
                        else
                            composer.setVariable( "lastScene", "hotelhallway2" )
                            composer.gotoScene( "scenes.hotel" )
                        end
                    end,
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
            nena:setXY(83,25)
        elseif (lastScene == "hotel2") then
            nena:setXY(98,25)
        elseif (lastScene == "hotelbridge") then
            nena:setXY(98,25)
        end
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
        local bgm = BGM:new()
        bgm:play( "music/sclubparty.mp3" )
    
        composer.setVariable( "lastScene", "hotelhallway" )
    end

end
 
 
-- hide()
function scene:hide( event )
 
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