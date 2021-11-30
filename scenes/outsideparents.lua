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
potion = require("items.potion")

 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
    print("outsideparents create")
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
    local bgm = BGM:new()
    bgm:play( "music/sclubparty.mp3" )

    local world = createWorld(sceneGroup)
    self.world = world

    map = Map:new(world,{
        width=938,
        height=564,
        filename="art/outside-nenas-parents.png",
        obstructfile="art/outside-nenas-parents-collision.png",
        foreground="art/outside-nenas-parents-foreground.png",
        scaleFn=(function (x, y) 
            -- return 1.0
            if ( y >= 59 ) then 
               return 0.2 + 0.4*(y-59)/10;
            else
               return 0.2
            end
        end)
    })
    self.map = map

    nena = Character:new(world,map,{
        name="player",
        spec=nenaChar,
        startX=107,
        startY=61,
        giveItemTo=function(item)
            if require("items.global")(item) then return end
            msg("I already have this!")
        end
    })
    self.nena = nena

    player = Player:new(world,map,nena)

    dad = Character:new(world,map,{
        name="dad",
        spec=require("characters.dennis"),
        avatar="art/dennis.png",
        startX=33,
        startY=66,
        giveItemTo=function(item)
            if item.name=="Outdoor Oodie" then
                if not composer.getVariable("offeredDadAnOodie") then
                    composer.setVariable("offeredDadAnOodie",1)
                else
                    composer.setVariable("offeredDadAnOodie",composer.getVariable("offeredDadAnOodie")+1)
                end
                async.waterfall({
                    function(next) nena:moveTo(42,66,next) end,
                    function(next) nena:setFacing(-1) next() end,
                    function(next) msg("Hi Daddy! Do you want an oodie?",next) end,
                    function(next) 
                        local i = composer.getVariable("offeredDadAnOodie")
                        if i <=1 then msg(dad,"You can't be serious Nena. That's horrendous!",next)
                        elseif i==2 then msg(dad,"Absolutely not!",next)
                        elseif i==3 then msg(dad,"I can't beleive you went to medical school!",next)
                        elseif i>=4 then msg(dad,"NO!",next)
                        end
                    end,
                })
            else
                async.waterfall({
                    function(next) nena:moveTo(42,66,next) end,
                    function(next) nena:setFacing(-1) next() end,
                    function(next) msg("Hi Daddy! Do you want this?",next) end,
                    function(next) msg(dad,"I'd rather jump off a bridge then take that!!",next) end,
                })
            end
        end,
        actions={
            Look=function()
                msg("It's my dad!")
            end,
            Talk=function()
                async.waterfall({
                    function(next) nena:moveTo(42,66,next) end,
                    function(next) nena:setFacing(-1) next() end,
                    function(next) msg("Hi Daddy!",next) end,
                    function(next) msg(dad,"Hi Neens.. OMG. What are you wearing?",next) end,
                    function(next) msg("It's my outdoor Oodie!",next) end,
                    function(next) msg(dad,"You're in public. I'm horrified.",next) end,
                    function(next) msg("Isn't it great?",next) end,
                })
            end
        }
    })
    self.dad = dad

    exitToRight = Interactable:new(world,{
        name="go right",
        x=865,
        y=396,
        width=74,
        height=170,
        actions={
            Exit=function()
                print("going right")
                async.waterfall({
                    function(next) nena:moveTo(107,61,next) end,
                    function(next) composer.gotoScene( "scenes.outsidenenas" ) end,
                })
            end
        }
    })

    enter = Interactable:new(world,{
        name="enter",
        x=639,
        y=423,
        width=40,
        height=46,
        actions={
            Enter=function()
                async.waterfall({
                    function(next) nena:moveTo(83,59,next) end,
                    function(next) msg("This is my parents house! They live so close to me. It's amazing!",next) end,
                    function(next) 
                        if composer.getVariable("parentsHouseUnlocked") then
                            composer.gotoScene( "scenes.parentsapartment" ) 
                        else
                            msg("It's locked... But I have an extra key back at my apartment!",next)
                        end
                    end,
                })
            end
        },
        useItemOn=function(item)
            if Inventory:hasItem("Keys") then 
                msg("Now it's unlocked!")
                composer.setVariable("parentsHouseUnlocked",true)
            else
                msg("That doesn't work")
            end
        end
    })

    Inventory:new()
end
 
 
-- show()
function scene:show( event )
    print("outsideparents show")
 
    local sceneGroup = self.view
    local phase = event.phase
    local lastScene = composer.getVariable("lastScene")
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        nena = self.nena
        world = self.world

        self.nena:reinit()

        if ( lastScene == "outsidenenas") then
            nena:setXY(107,61)
        elseif ( lastScene == "parentsapartment") then
            nena:setXY(83,60)
        end

        if not composer.getVariable("knowsMAFSCancelled") and not composer.getVariable("needsIDProof") then
            self.dad:setXY(33,66)
        else
            self.dad:setXY(-99,66)
        end
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        if ( lastScene == "outsidenenas") then
            nena:moveTo(83,67)
        end
 
        composer.setVariable( "lastScene", "outsideparents" )
    end

end
 
 
-- hide()
function scene:hide( event )
    print("outsideparents hide")
 
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
    print("outsideparents destroy")
 
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