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
battery = require("items.battery")

 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
    local bgm = BGM:new()
    bgm:play( "music/sclubparty.mp3" )

    local world = createWorld(sceneGroup)
    self.world = world

    map = Map:new(world,{
        width=845,
        height=338,
        filename="art/dave-and-busters.png",
        obstructfile="art/dave-and-busters-collision.png",
        foreground="art/dave-and-busters-foreground.png",
        scaleFn=(function (x, y) 
            -- return 0.6
            if ( y >= 42 ) then 
               return 0.6 + 0.4*(y-42)/26;
            else
               return 0.6
            end
        end)
    })

    nena = Character:new(world,map,{
        name="player",
        spec=nenaChar,
        startX=74,
        startY=25,
        giveItemTo=function(item)
            if require("items.global")(item) then return end
            msg("I already have this!")
        end
    })
    self.nena = nena

    player = Player:new(world,map,nena)

    rupaul = Character:new(world,map,{
        name="Rupaul",
        avatar="art/rupaul.png",
        spec=require("characters.rupaul"),
        startX=64,
        startY=41,
        giveItemTo=function(item) 
            if item.name == "Video Camera" and composer.getVariable("rupaulWillEndorse") and not composer.getVariable("haveRupaulEndorsement") then
                composer.setVariable("haveRupaulEndorsement",true)
                async.waterfall({
                    function(next) nena:moveTo(72,38,next) end,
                    function(next) msg(nena, "Hi Run! Can you please let me record you giving an endorsement for Redbox Mac n Cheese?", next) end,
                    function(next) msg(rupaul, "Sure - Let's do it!", next) end,
                    function(next) msg(nena, "Thank you so much!",next) end,
                })
            elseif item.name == "Video Camera" and composer.getVariable("rupaulWillEndorse") and composer.getVariable("haveRupaulEndorsement") then
                msg(nena,"Thanks for the endorsement Ru!")
            else
                msg("I can't give that to Ru!")
            end
        end,
        actions={
            Look=function()
                msg("Is that... OMG.. It's Rupaul!!!!")
            end,
            Talk=function()
                async.waterfall({
                    function(next) nena:moveTo(72,38,next) end,
                    function(next) nena:setFacing(-1) next() end,
                    function(next) msg("OMG Hi Ru - I'm a big fan!",next) end,
                    function(next) msg(rupaul,"We’re all born naked and the rest is drag!",next) end,
                    function(next)
                        local function showOptions()
                            local choices = {}
                            table.insert(choices, { 
                                label="Ask what Ru is doing here", 
                                fn=function() 
                                    async.waterfall({
                                        function(next) msg(nena, "This is amazing! What brings you to town Ru?", next) end,
                                        function(next) msg(rupaul, "We're having a Rupaul's Drag Race Trivia show today! All tea and all shade!", next) end,
                                        function(next) showOptions() end,
                                    })
                                end
                            })
                            if composer.getVariable("knowsSnacksAreMissing") and not Inventory:hasItem("Mac N Cheese")  then
                                table.insert(choices, { 
                                    label="Ask about Redbox Mac n Cheese", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena, "By any chance do you know where I can get a box of Red box Mac N Cheese?", next) end,
                                            function(next) msg(rupaul, "Ain’t nobody got time for that", next) end,
                                            function(next) showOptions() end,
                                        })
                                    end
                                });
                            end
                            if composer.getVariable("knowsSnacksAreMissing") and not Inventory:hasItem("J Lohr")  then
                                table.insert(choices, { 
                                    label="Ask about J Lohr", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena, "Do you know where I can get a bottle of J Lohr?", next) end,
                                            function(next) msg(rupaul, "Ain’t nobody got time for that", next) end,
                                            function(next) showOptions() end,
                                        })
                                    end
                                });
                            end
                            if composer.getVariable("knowsSnacksAreMissing") and not Inventory:hasItem("Truffle Chips")  then
                                table.insert(choices, { 
                                    label="Ask about Truffle Chips", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena, "Do you know where I can get a bag of Truffle Chips?", next) end,
                                            function(next) msg(rupaul, "Ain’t nobody got time for that", next) end,
                                            function(next) showOptions() end,
                                        })
                                    end
                                });
                            end
                            if composer.getVariable("amberWantsOodie") and not Inventory:hasItem("Extra Oodie") and not Inventory:hasItem("J Lohr") then
                                table.insert(choices, { 
                                    label="Ask about an Oodie", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena, "Do you know where I can get another Oodie?", next) end,
                                            function(next) msg(rupaul, "I love this oodie you're wearing child. When you become the image of your own imagination, it’s the most powerful thing you could ever do.", next) end,
                                            function(next) msg(rupaul, "But no - I can't help", next) end,
                                            function(next) showOptions() end,
                                        })
                                    end
                                });
                            end
                            if composer.getVariable("needsMacNCheeseEndorsements") and not composer.getVariable("haveRupaulEndorsement") then
                                table.insert(choices, { 
                                    label="Ask for an endorsement", 
                                    fn=function() 

                                        local function lost()
                                            msg(rupaul,"Sorry child. I guess you're not a true Drag Race fan.")
                                        end

                                        local function playTrivia()
                                            async.waterfall({
                                                function(next) msg(rupaul,"Which queen became the winner of \"RuPaul's Drag Race\" season 1?",next) end,
                                                function(next)
                                                    options({
                                                        { label="Nina Flowers", fn=lost },
                                                        { label="Shannel", fn=lost },
                                                        { label="BeBe Zahara Benet", fn=next },
                                                        { label="Rebecca Glasscock", fn=lost },
                                                    })
                                                end,
                                                function(next) msg(rupaul,"Which queen became the winner of \"RuPaul's Drag Race\" All Stars?",next) end,
                                                function(next)
                                                    options({
                                                        { label="Raven", fn=lost },
                                                        { label="Shannel", fn=lost },
                                                        { label="Jujubee", fn=lost },
                                                        { label="Chad Michaels", fn=next },
                                                    })
                                                end,
                                                function(next) msg(rupaul,"Which two contestants were brought back within their season, only to be eliminated in the same episode they were brought back in?",next) end,
                                                function(next)
                                                    options({
                                                        { label="Shangela and Kenya Michaels", fn=lost },
                                                        { label="Carmen Carrera and Kenya Michaels", fn=next },
                                                        { label="Pandora Boxx and Mimi Imfurst", fn=lost },
                                                        { label="Shangela and Mimi Imfurst", fn=lost },
                                                    })
                                                end,
                                                function(next) msg(rupaul,"Which queen faced Lip-Sync For Your Life the most times as of All-Stars?",next) end,
                                                function(next)
                                                    options({
                                                        { label="Jujubee", fn=lost },
                                                        { label="Raven", fn=next },
                                                        { label="Latrice Royale", fn=lost },
                                                        { label="Akashia", fn=lost },
                                                    })
                                                end,
                                                function(next) msg(rupaul,"Rupaul credits Atlanta for her start in drag. Which of these country songs has NOT been used in a Lip-Sync For Your Life?",next) end,
                                                function(next)
                                                    options({
                                                        { label="\"Mi Vida Loca\" by Pam Tillis", fn=lost },
                                                        { label="\"Stand By Your Man\" by Tammy Wynette", fn=next },
                                                        { label="\"I Hear You Knockin'\" by Wynonna Judd", fn=lost },
                                                        { label="\"No One Else on Earth\" by Wynonna Judd", fn=lost },
                                                    })
                                                end,
                                                function(next) 
                                                    composer.setVariable("rupaulWillEndorse",true);
                                                    msg(rupaul,"Great job!!! You won!!",next) 
                                                end,
                                                function(next) msg(nena,"Wow! Does this mean you'll give me an endorsement for redbox Mac n Cheese?",next) end,
                                                function(next) msg(rupaul,"It sure does! Do you have a camera or something to record the endorsement with?",next) end
                                            })
                                        end

                                        if composer.getVariable("rupaulWillEndorse") then
                                            msg(rupaul,"Great job! Do you have a camera or something to record the endorsement with?")
                                        elseif not composer.getVariable("playRuTrivia") then 
                                            composer.setVariable("playRuTrivia",true)
                                            async.waterfall({
                                                function(next) msg(nena, "Would you be able to give me an endorsement for Redbox Mac n Cheese?", next) end,
                                                function(next) msg(rupaul, "An endorsement?! For redbox Mac n Cheese?!", next) end,
                                                function(next) msg(nena, "Please PUH-LEAAASEEE!!", next) end,
                                                function(next) msg(rupaul, "Look I'll do it - But I'll only do this if you can prove you're a true fan!", next) end,
                                                function(next) msg(rupaul, "Win at Drag Race trivia night and I'll give you an endorsement!", next) end,
                                                function(next) msg(nena, "OK - I'll do it!", next) end,
                                                function(next) playTrivia() end,
                                            })
                                        else
                                            async.waterfall({
                                                function(next) msg(nena,"Can I try again? PUH-LEEAAASSEE!",next) end,
                                                function(next) msg(rupaul,"OK!",next) end,
                                                function(next) playTrivia() end,
                                            })
                                        end
                                    end
                                });
                            end
                            table.insert(choices, { 
                                label="That's all", 
                                fn=function() next() end
                            });
                            options(choices,next)
                        end
                        showOptions()
                    end,
                })
            end
        }
    })

    queen1 = Character:new(world,map,{
        name="Shangela",
        avatar="art/shangela.png",
        spec=require("characters.shangela"),
        startX=87,
        startY=33,
        actions={
            Look=function()
                msg("OMG - It's Shangela!! She's my favourite queen!!")
            end,
            Talk=function()
                async.waterfall({
                    function(next) nena:moveTo(80,33,next) end,
                    function(next) nena:setFacing(1) next() end,
                    function(next) msg("OMG! Hi Shangela!! You're my favourite queen!", next) end,
                    function(next) msg(queen1,"Life is about putting forth your best effort and showing up!") end,
                })
            end,
        }
    })

    queen2 = Character:new(world,map,{
        name="Bob the Drag Queen",
        avatar="art/bob.png",
        spec=require("characters.bob"),
        startX=51,
        startY=33,
        actions={
            Look=function()
                msg("It's Bob the Drag Queen!!")
            end,
            Talk=function()
                async.waterfall({
                    function(next) nena:moveTo(60,33,next) end,
                    function(next) nena:setFacing(-1) next() end,
                    function(next) msg("Hi Bob!!", next) end,
                    function(next) msg(queen2,"Purse first! Purse first! Walk into the room purse first! Clack!") end,
                })
            end,
        }
    })

    queen3 = Character:new(world,map,{
        name="Eureka O'Hara",
        avatar="art/eureka.png",
        spec=require("characters.eureka"),
        startX=15,
        startY=41,
        actions={
            Look=function()
                msg("It's Eureka O'Hara!!")
            end,
            Talk=function()
                async.waterfall({
                    function(next) nena:moveTo(23,41,next) end,
                    function(next) nena:setFacing(-1) next() end,
                    function(next) msg("Hi Eureka!!", next) end,
                    function(next) msg(queen3,"Feeling PHAT, with a PH, Pretty Hot And Tasty!") end,
                })
            end,
        }
    })

    door = Interactable:new(world,{
        name="Door",
        x=559,
        y=64,
        width=64,
        height=125,
        actions={
            Exit=function()
                async.waterfall({
                    function(next) nena:moveTo(74,25,next) end,
                    function(next) composer.gotoScene( "scenes.commercialdistrict" ) end,
                })
            end
        }
    })

    craneGame = Interactable:new(world,{
        name="Crane Game",
        x=313,
        y=72,
        width=64,
        height=123,
        actions={
            Look=function()
                async.waterfall({
                    function(next) nena:moveTo(43,26,next) end,
                    function(next) msg("It's a crane game! These things are so difficult.",next) end,
                })
            end,
            Play=function()
                async.waterfall({
                    function(next) nena:moveTo(43,26,next) end,
                    function(next) msg("It's a crane game! Let's see if I can win...",next) end,
                    function(next) 
                        local attempts = composer.getVariable("craneGameAttempts")
                        if not attempts then attempts = 1
                        else attempts = attempts + 1 end
                        composer.setVariable("craneGameAttempts",attempts)

                        if attempts == 3 then
                            async.waterfall({
                                function(next) msg("OMG! I won!!!",next) end,
                                function(next) Inventory:addItem(battery,next) end,
                                function(next) msg("...I won a battery?",next) end,
                            })
                        else 
                            msg("I lost...",next)
                        end
                    end,
                })
            end
        }
    })

    skeeBall = Interactable:new(world,{
        name="Skee Ball",
        x=100,
        y=127,
        width=75,
        height=75,
        actions={
            Look=function()
                async.waterfall({
                    function(next) nena:moveTo(32,17,next) end,
                    function(next) msg("It's skee ball!",next) end,
                })
            end,
        }
    })

    spaceInvaders = Interactable:new(world,{
        name="Space Invaders",
        x=198,
        y=74,
        width=69,
        height=123,
        actions={
            Look=function()
                async.waterfall({
                    function(next) nena:moveTo(33,33,next) end,
                    function(next) msg("It's Space Invaders!",next) end,
                })
            end,
        }
    })

    darts = Interactable:new(world,{
        name="Darts",
        x=487,
        y=74,
        width=48,
        height=124,
        actions={
            Look=function()
                async.waterfall({
                    function(next) nena:moveTo(65,26,next) end,
                    function(next) msg("It's Darts!",next) end,
                })
            end,
        }
    })

    basketball = Interactable:new(world,{
        name="Basketball",
        x=18,
        y=131,
        width=76,
        height=110,
        actions={
            Look=function()
                async.waterfall({
                    function(next) nena:moveTo(22,36,next) end,
                    function(next) msg("It's Basketball!",next) end,
                })
            end,
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
 
        composer.setVariable( "lastScene", "daveandbusters" )
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