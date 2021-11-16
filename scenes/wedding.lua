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
 
    local backgroundMusic = audio.loadStream( "music/sclubparty.mp3" )
    audio.play( backgroundMusic )
    self.backgroundMusic = backgroundMusic

    local world = createWorld(sceneGroup)
    self.world = world

    map = Map:new(world,{
        width=612,
        height=1105,
        filename="art/wedding.png",
        obstructfile="art/wedding-collision.png",
        foreground="art/wedding-foreground.png",
        blendMode="screen",
        scaleFn=(function (x, y) 
            return 0.5
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
        startX=38,
        startY=137,
        giveItemTo=function(item)
            if require("items.global")(item) then return end
            msg("I already have this!")
        end
    })
    self.nena = nena

    player = Player:new(world,map,nena)

    kevin = Character:new(world,map,{
        name="Kevin",
        avatar="art/avatar1.png",
        spec=defaultChar,
        startX=35,
        startY=30
    })

    neve = Character:new(world,map,{
        name="Neve",
        avatar="art/avatar1.png",
        spec=defaultChar,
        startX=38,
        startY=26
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
 
        composer.setVariable( "lastScene", "wedding" )

        async.waterfall({
            function(next) nena:moveTo(38,42,next) end,
            function(next) nena:moveTo(43,30,next) end,
            function(next) nena:setFacing(-1); next() end,
            function(next) msg("Do I know you?",next) end,
            function(next) msg(kevin,"Hey Nena - It's me Kevin!",next) end,
            function(next) msg("Who?",next) end,
            function(next) msg(kevin,"Remember 5 years ago we were talking on Match.com? We were talking for a long time but then we never went on a date",next) end,
            function(next) msg("Ya I remember! You never asked me out!!",next) end,
            function(next) msg("Aren't you supposed to be a catfish?",next) end,
            function(next) msg(kevin,"Yes but every now and then the catfish turns out to be the person from the pics right? That's me!",next) end,
            function(next) msg("What about the 'after lockup' part of this show? Are you fresh out of prison?",next) end,
            function(next) msg(kevin,"I am! In this reality we never went on a date and instead I did hard time until just now!",next) end,
            function(next) msg("This reality? Wait - What did you do!?",next) end,
            function(next) msg(kevin,"This happened and then that happened and then yadda yadda yadda - I'm here now to marry you!",next) end,
            function(next) msg("That explanation was extremely sketchy and I'm suddenly having massive doubts about going through with this...",next) end,
            function(next) msg(kevin,"Look - I know I may seem a bit sketchy. But picture a world where I didn't go to prison",next) end,
            function(next) msg(kevin,"And instead we went on that first date. And you told me about your love for Maury and I offered to PVR the show for you!",next) end,
            function(next) msg(kevin,"And every year I would try to make you a crazy cake on your birthday even though I'm only a survival chef!",next) end,
            function(next) msg(kevin,"And we always would hang out and play crazy puzzle games and watch your favourite reality tv shows together!",next) end,
            function(next) msg(kevin,"And 1 day we would move in together--",next) end,
            function(next) msg("That wouldn't happen. I'd make you move next door",next) end,
            function(next) msg(kevin,"Well maybe you warmed up to the idea and when we moved in together you actually liked it!",next) end,
            function(next) msg(kevin,"And even if it was a global pandemic we would have fun together because we were together!",next) end,
            function(next) msg("Global pandemic?",next) end,
            function(next) msg(kevin,"Anyways - In that reality I would love you so much and want to spend the rest of my life with you",next) end,
            function(next) msg("I'm not convinced.",next) end,
            function(next) msg(kevin,"OK - Look I had a feeling I wouldn't be able to convince you. So I got some help! Cue the video!",next) end,
            function(next) 

            end,
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