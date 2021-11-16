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

 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
    local backgroundMusic = audio.loadStream( "music/allornothing1.mp3" )
    audio.play( backgroundMusic )
    self.backgroundMusic = backgroundMusic

    local world = createWorld(sceneGroup)
    self.world = world

    map = Map:new(world,{
        width=1105,
        height=331,
        filename="art/bachelorette.png",
        obstructfile="art/bachelorette-collision.png",
        foreground="art/bachelorette-foreground.png",
        blendMode="screen",
        scaleFn=(function (x, y) 
            return 1.0
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

    amber = Character:new(world,map,{
        name="Amber Rose",
        avatar="art/avatar2.png",
        spec=defaultChar,
        startX=43,
        startY=37
    })
    amber:setFacing(1)

    laura = Character:new(world,map,{
        name="Laura",
        avatar="art/avatar2.png",
        spec=defaultChar,
        startX=56,
        startY=35
    })
    laura:setFacing(1)

    duate = Character:new(world,map,{
        name="Duate",
        avatar="art/avatar2.png",
        spec=defaultChar,
        startX=78,
        startY=35
    })
    duate:setFacing(-1)

    leah = Character:new(world,map,{
        name="Leah",
        avatar="art/avatar2.png",
        spec=defaultChar,
        startX=93,
        startY=37
    })
    leah:setFacing(-1)

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

        composer.setVariable( "lastScene", "bachelorette" )

        async.waterfall({
            function(next) nena:moveTo(69,38,next) end,
            function(next) msg("It's the bachelorette party!",next) end,
            function(next) msg(duate,"Hey boo! What is this party about?",next) end,
            function(next) msg("Guys - I have something to tell you!",next) end,
            function(next) msg("I'm getting married...... to a stranger!",next) end,
            function(next) msg("Who I've been talking to on the internet for too many years and is probably using fake pictures",next) end,
            function(next) msg("And they are fresh out of prison and we have 90 days to decide to stay together!",next) end,
            function(next) msg(leah,"This sounds.....",next) end,
            function(next) msg(laura,"like the premise of 90 Day MAFS-Fish after lockup AU",next) end,
            function(next) msg("That's right! We're on the new season right now!!! Isn't this great????",next) end,
            function(next) msg(duate,"I'm so happy for you boo!",next) end,
            function(next) composer.gotoScene( "scenes.wedding" ) end,
        })

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