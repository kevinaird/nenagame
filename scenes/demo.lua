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
        width=1920,
        height=564,
        filename="art/ian-fox-castle-makeshift-kitchen.jpg",
        obstructfile="art/ian-fox-castle-makeshift-kitchen-obstruct.png",
        foreground="art/ian-fox-castle-makeshift-kitchen-foreground.png",
        scaleFn=(function (x, y) 
            if ( x >=95 ) then 
                return 1.0
            elseif ( y <= 35 ) then 
                return 0.5
            elseif (y <= 46) then
                return 0.5 + 0.5*(y-35)/11;
            else
                return 1.0
            end
        end)
    })

    char = Character:new(world,map,{
        name="player",
        spec=defaultChar,
        startX=137,
        startY=51,
        giveItemTo=function(item)
            msg("I already have this!")
        end
    })

    player = Player:new(world,map,char)

    npc = Character:new(world,map,{
        name="npc1",
        spec=defaultChar,
        startX=50,
        startY=48,
        avatar="art/avatar2.png",
        giveItemTo=function(item)
            msg(npc,"Thanks for the "..item.name)
            Inventory:removeItem(item)
        end
    })

    npc2 = Character:new(world,map,{
        name="npc2",
        spec=defaultChar,
        startX=70,
        startY=39,
        avatar="art/avatar2.png",
        actions={
            Look=function()
                async.waterfall({
                    function(next) msg("Looks like npc2",next) end,
                    function(next) msg(npc2,"What are you looking at?", next) end,
                })
            end,
            Talk=function()
                async.waterfall({
                    function(next) msg("Talking to npc2",next) end,
                    function(next) msg(npc2,"You talking to me?",next) end,
                })
            end
        }
    })

    object1 = Interactable:new(world,{
        name="object1",
        x=1138,
        y=260,
        width=43,
        height=53,
        actions={
            Look=function()
                msg("Looks like object1")
            end,
            Talk=function()
                msg("Talking to object1")
            end,
            Open=function()
                options({
                    { label="option 1: what happens when you have a really long set of text????? people wanna know!! what happens when you have a really long set of text????? people wanna know!! what happens when you have a really long set of text????? people wanna know!!", 
                        fn=function() 
                            async.waterfall({
                                function(next) msg("We are having a conversation", next) end,
                                function(next) msg("I found a potion!", next) end,
                                function(next) Inventory:addItem(potion, next) end,
                                function(next) msg("That's cool!", next) end,
                            })
                        end },
                    { label="option 2" },
                    { label="option 3" },
                    { label="option 4" },
                    { label="option 5" },
                    { label="option 6" },
                    { label="option 7" },
                    { label="option 8" },
                }, function(op)
                    msg(op.label)
                end)
            end
        }
    })

    Inventory:new()
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        world = self.world
        
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
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