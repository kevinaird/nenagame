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
    print("outsidenenas create")
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
    local world = createWorld(sceneGroup)
    self.world = world

    map = Map:new(world,{
        width=1244,
        height=558,
        filename="art/OutsideNenasApartment.png",
        obstructfile="art/OutsideNenasApartment-collision.png",
        foreground="art/OutsideNenasApartment-foreground.png",
        scaleFn=(function (x, y) 
            -- return 1.0
            if ( y >= 59 ) then 
               return 0.3 + 0.4*(y-59)/10;
            else
               return 0.3
            end
        end)
    })

    nena = Character:new(world,map,{
        name="player",
        spec=defaultChar,
        startX=38,
        startY=60,
        giveItemTo=function(item)
            if require("items.global")(item) then return end
            msg("I already have this123!")
        end
    })
    self.nena = nena

    player = Player:new(world,map,nena)

    exitToParents = Interactable:new(world,{
        name="go left",
        x=0,
        y=391,
        width=32,
        height=172,
        actions={
            Exit=function()
                async.waterfall({
                    function(next) nena:moveTo(2,61,next) end,
                    function(next) composer.gotoScene( "scenes.outsideparents" ) end,
                })
            end
        }
    })

    exitRight = Interactable:new(world,{
        name="go right",
        x=1206,
        y=374,
        width=38,
        height=187,
        actions={
            Exit=function()
                async.waterfall({
                    function(next) nena:moveTo(150,67,next) end,
                    function(next) composer.gotoScene( "scenes.park" ) end,
                })
            end
        }
    })

    nenasApt = Interactable:new(world,{
        name="Nena's Apartment",
        x=268,
        y=407,
        width=37,
        height=59,
        actions={
            Exit=function()
                async.waterfall({
                    function(next) nena:moveTo(37,60,next) end,
                    function(next) composer.gotoScene( "scenes.nenasapartment" ) end,
                })
            end
        }
    })

    Inventory:new()
end
 
 
-- show()
function scene:show( event )
    print("outsidenenas show")
 
    local sceneGroup = self.view
    local phase = event.phase
    local lastScene = composer.getVariable("lastScene")
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        nena = self.nena
        world = self.world

        self.nena:reinit()

        if ( lastScene == "outsideparents") then
            nena:setXY(8,60)
        elseif (lastScene == "nenasapartment") then
            nena:setXY(37,60)
        elseif (lastScene == "park") then
            nena:setXY(150,67)
        end

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
        local bgm = BGM:new()
        bgm:play( "music/sclubparty.mp3" )
    
        if ( lastScene == "outsideparents") then
            nena:moveTo(12,60)
        elseif (lastScene == "park") then
            nena:moveTo(144,67)
        end

        composer.setVariable( "lastScene", "outsidenenas" )
    end

end
 
 
-- hide()
function scene:hide( event )
    print("outsidenenas hide")
 
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
    print("outsidenenas destroy")
 
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