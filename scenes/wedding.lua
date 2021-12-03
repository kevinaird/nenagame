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
local cutscene = require("engine.cutscene")
local BGM = require("engine.bgm")

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
        avatar="art/kevin.png",
        spec=require("characters.kevin"),
        startX=35,
        startY=30
    })

    neve = Character:new(world,map,{
        name="Nev",
        avatar="art/nev.png",
        spec=require("characters.nev"),
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
 
        bgm = BGM:new()
        bgm:play( "music/IntoTheMystic.mp3" )
    
        composer.setVariable( "lastScene", "wedding" )
        Runtime:dispatchEvent( { name="dialogOpen" } )

        async.waterfall({
            function(next) nena:moveTo1(38,42,false,next) end,
            function(next) nena:moveTo1(43,30,false,next) end,
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
            function(next) msg("This reality!? Wait - What did you do!?",next) end,
            function(next) msg(kevin,"This happened and then that happened and then yadda yadda yadda - I'm here now to marry you!",next) end,
            function(next) msg("That explanation was extremely sketchy and I'm suddenly having massive doubts about going through with this...",next) end,
            function(next) msg(kevin,"Look - I know it may seem a bit sketchy. But picture a world where I didn't go to prison",next) end,
            function(next) msg(kevin,"And instead we went on that first date. And you told me about your love for Maury and I offered to PVR the show for you!",next) end,
            function(next) msg(kevin,"And every year I would try to make you a crazy cake on your birthday even though I was only a survival chef when we met!",next) end,
            function(next) msg(kevin,"And we always would hang out and play crazy puzzle games and watch your favourite reality tv shows together!",next) end,
            function(next) msg(kevin,"And 1 day we would move in together--",next) end,
            function(next) msg("That wouldn't happen. I'd make you move next door",next) end,
            function(next) msg(kevin,"Well maybe you warmed up to the idea and when we moved in together you actually liked it!",next) end,
            function(next) msg(kevin,"And even if it was a global pandemic we would have fun together because we were together!",next) end,
            function(next) msg("Global pandemic?",next) end,
            function(next) msg(kevin,"Anyways - In that reality I would love you so much and want to spend the rest of my life with you",next) end,
            function(next) msg("I'm not convinced.",next) end,
            function(next) msg(kevin,"OK - Look I had a feeling I wouldn't be able to convince you. So I got some help! Cue the video!",next) end,
            function(next) bgm:stop(next) end,
            function(next) 
                Runtime:dispatchEvent( { name="dialogOpen" } )
                blackness = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth*3, display.contentHeight*3 )
                blackness:setFillColor( 0, 0, 0 )
                blackness.alpha = 0 
                transition.to(blackness, { time=500, alpha=1, onComplete=function() next() end})
            end,
            -- 1. Slide show of our pics
            function(next) bgm:play( "music/Foreigner.mp3" ) next() end,
            function(next) cutscene("NenaAndKev.MP4",false,next) end,
            -- 2. Yammy fake out video
            function(next) bgm:stop(next) end,
            function(next) 
                yammySheet = graphics.newImageSheet( "art/yammy.png", {
                    width = 505,
                    height = 480,
                    numFrames = 12
                } )
                yammy = display.newSprite( yammySheet, {
                    {
                        name = "talk",
                        --start = 1,
                        --count = 12,
                        frames={
                            --        500MS             1400MS                    2.8s   3.1s       3.6      4.1
                            --        NEENAAA           NEENARAEE                THIISIS YAGIRL     YAAMENEKASAAUNNDDERS
                            6,6,6,6,6,3,1,1,1,6,6,6,6,6,3,1,1,1,1,6,6,6,6,6,6,6,6,9,1,10,1,11,11,11,10,3,1,6,4,1,10,3,11,6,6,6,
                        --  5s     5.4        6s        6.5s            7.3                         8.7   9  9.2        9.8
                        --  THECOMEDIANFRAMERICA           ASYOUCANTELLACCENT                       I HER YA BOYFREND   KEVIN
                            9,11,8,1,7,1,6,1,1,6,6,6,6,6,6,1,11,4,1,5,5,1,1,8,8,8,6,6,6,6,6,6,6,6,6,1,8,6,1,1,2,8,8,3,3,4,1,3,4,4,4,
                        --  10.4                11.2          11.8                       13                    14          14.5      
                        --  LOVESYOUVERYMUCCCCH               ANDTHAT  YOU  TOLD HIM     HE COULD NOT PROPOSE
                            5,11,11,7,8,11,11,11,6,6,6,6,6,6,6,1,1,9,1,11,11,2,2,1,6,6,6,1,11,11,1,1,2,2,1,2,2,11,1,8,5,10,1,1,1,6,6,
                        -- 15                     16                 17                 18          18.6        19.2
                        --  SOMEHOW
                            10,11,11,6,1,2,2,6,11,3,11,5,6,6,6,6,6,6,1,2,2,1,1,8,8,1,1,1,6,6,6,6,6,6,1,1,2,2,1,1,6,6,6,6,6,6,6,
                        -- 19.8          20.5     20.9      21.4      21.8          22.5               23.1            23.8        24.4
                            5,5,8,1,1,1,6,6,6,6,6,8,8,8,8,5,6,6,6,6,6,3,1,6,8,4,10,4,6,6,6,6,6,6,6,6,6,1,2,2,1,2,2,1,1,6,6,6,6,6,6,6

                        },
                        time = 24450,
                        loopCount = 0,
                        loopDirection = "forward"
                    },
                })
                yammy:setSequence( "talk" )
                yammy.x = display.contentCenterX
                yammy.y = display.contentCenterY
                yammy.yScale = 0.6
                yammy.xScale = 0.6
                yammy:play()
                --timer.performWithDelay(27*1000,function() next() end);
                local yammyAudio = audio.loadStream( "music/yammy.mp3" )
                local yammyChannel = audio.play( yammyAudio, { onComplete=function() next() end} )
                audio.setVolume(1,{ channel=yammyChannel })
            end,
            function(next) yammy:removeSelf(); next() end,
            -- 3. Nikki Real video
            function(next) cutscene("cameo1.mp4",false,next) end,
            -- 4. Buck Real video
            function(next) cutscene("cameo2.mp4",false,next) end,
            -- 5. Proposal
            function(next) msg(kevin,"HoboPro - Will you marry me?",next) end,
            function(next) 
                local function showOptions()
                    options({
                        {
                            label="Yes!",
                            fn=function() next() end,
                        },
                        {
                            label="No.",
                            fn=function()
                                async.waterfall({
                                    function(next) msg(kevin,"Wrong answer!!",next) end,
                                    function(next) msg(kevin,"HoboPro - Will you marry me?",next) end,
                                    function(next) showOptions() end,
                                })
                            end,
                        }
                    })
                end
                showOptions()
            end,
            -- The End!
            function(next) msg(kevin,"Woohhooooo!!!!",next) end,
            function(next) composer.gotoScene("scenes.startup") end,
        })
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