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
defaultChar = require("characters.default")
nenaChar = require("characters.nena")
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
        width=847,
        height=331,
        filename="art/sharp-entertainment.png",
        obstructfile="art/sharp-entertainment-collisions.png",
        foreground="art/sharp-entertainment-foreground.png",
        scaleFn=(function (x, y) 
            return 0.9
            -- if ( y >= 42 ) then 
            --    return 0.6 + 0.4*(y-42)/26;
            -- else
            --    return 0.6
            -- end
        end)
    })

    nena = Character:new(world,map,{
        name="player",
        spec=nenaChar,
        startX=5,
        startY=39,
        giveItemTo=function(item)
            if require("items.global")(item) then return end
            msg("I already have this!")
        end
    })
    self.nena = nena

    player = Player:new(world,map,nena)

    matt = Character:new(world,map,{
        name="Matt Sharp",
        avatar="art/avatar1.png",
        spec=defaultChar,
        startX=79,
        startY=40,
        actions={
            Talk=function()
                async.waterfall({
                    function(next) nena:moveTo(63,40,next) end,
                    function(next) msg(nena,"Hey you! I have a lot I need to say to you!",next) end,
                    function(next) nena:setFacing(1); matt:setFacing(-1); next() end,
                    function(next) msg(matt,"You! You were just on the Maury set!!",next) end,
                    function(next) msg(matt,"You walked right onto the set wearing an Oodie and claimed to be a some sort of therapist!",next) end,
                    function(next) msg(matt,"It was the craziest thing I've ever seen!",next) end,
                    function(next) msg(matt,"........And the ratings went through the roof! You're a star!!",next) end,
                    function(next) msg(nena,"Well... obvy!",next) end,
                    function(next) msg(matt,"You and you're oodie are a hit!!! A hit I say!! You must let me cast you in one of my shows!",next) end,
                    function(next) msg(matt,"Which one do you like best? Pet Psychic Encounters? Lady Hoggers? Celerity Nightmares Decoded?",next) end,
                    function(next) msg(nena,"My favourite is the one you just cancelled! 90 day MAFS-Fish after lockup AU!!",next) end,
                    function(next) msg(matt,"Done! I'm uncancelling the show and casting you in it right away!!!",next) end,
                    function(next)
                        tvscreen1 = display.newImage("art/90day-mafs-fish-cancelled.png")
                        tvscreen1.x, tvscreen1.y = display.contentCenterX, display.contentCenterY
                        tvscreen1.width, tvscreen1.height = 480,320
                        timer.performWithDelay( 800, function() next() end)
                    end,
                    function(next)
                        tvscreen1:removeSelf()
                        tvscreen2 = display.newImage("art/90day-mafs-fish.png")
                        tvscreen2.x, tvscreen2.y = display.contentCenterX, display.contentCenterY
                        tvscreen2.width, tvscreen2.height = 480,320
                        timer.performWithDelay( 800, function() next() end)
                    end,
                    function(next) msg("Woo hoo!! It's back!",next) end, 
                    function(next) 
                        tvscreen2:removeSelf()
                        composer.gotoScene( "scenes.bachelorette" )
                    end,
                })
            end,
        }
    })

    door = Interactable:new(world,{
        name="exit",
        x=0,
        y=122,
        width=46,
        height=176,
        actions={
            Exit=function()
                async.waterfall({
                    function(next) nena:moveTo(5,39,next) end,
                    function(next) composer.gotoScene( "scenes.tvstudio" ) end,
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

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
        composer.setVariable( "lastScene", "sharpentertainment" )
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

