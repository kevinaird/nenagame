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
wallet = require("items.wallet")
extraOodie = require("items.extraoodie")
jLohr = require("items.jlohr")
securityTapes = require("items.securitytapes")

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
        width=953,
        height=334,
        filename="art/9mag.png",
        obstructfile="art/9mag-collision.png",
        foreground="art/9mag-foreground.png",
        scaleFn=(function (x, y) 
            return 0.8
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
        startX=111,
        startY=40,
        giveItemTo=function(item)
            if require("items.global")(item) then return end
            msg("I already have this!")
        end
    })
    self.nena = nena

    player = Player:new(world,map,nena)

    securityTapesPic = display.newImage(world,"art/security-tapes.png")
    securityTapesPic.x, securityTapesPic.y = 123, 242  
    securityTapesPic.width, securityTapesPic.height = 45, 45
    securityTapesPic.isVisible = false

    securityTapesItem = Interactable:new(world,{
        name="Security Tapes",
        x=123-25,
        y=242-25,
        width=50,
        height=50,
        actions={
            Look=function()
                async.waterfall({
                    function(next) nena:moveTo(22,39,next) end,
                    function(next) 
                        nena:setFacing(-1)
                        msg("Looks like a stack of video tapes", next) 
                    end,
                })
            end,
            Take=function()
                if not composer.getVariable("vanLeft") then
                    async.waterfall({
                        function(next) nena:moveTo(22,39,next) end,
                        function(next) 
                            nena:setFacing(-1)
                            msg(van,"DON'T TOUCH THOSE!", next) 
                        end,
                        function(next) msg(nena,"AAahhh!", next) end,
                        function(next) msg(van,"Sorry - I just need to get rid of those tapes.", next) end,
                        function(next) msg(van,"All the crazy illegal stuff that happened here over the past few weeks was caught on those tapes!", next) end,
                    })
                else
                    async.waterfall({
                        function(next) nena:moveTo(22,39,next) end,
                        function(next) 
                            nena:setFacing(-1)
                            composer.setVariable("gotTapes",true)
                            Inventory:addItem(securityTapes)
                            securityTapesPic.isVisible = false
                            securityTapesItem:disable()
                        end
                    })
                end
            end
        }
    })
    securityTapesItem:disable()

    van = Character:new(world,map,{
        name="Van",
        spec=require("characters.van"),
        avatar="art/van.png",
        startX=27,
        startY=39,
        speed=0.5,
        actions={
            Look=function()
                msg("Oh wow! It's Van from Black Ink Crew Chicago!")
            end,
            Talk=function()
                async.waterfall({
                    function(next) nena:moveTo(37,37,next) end,
                    function(next) nena:setFacing(-1); next() end,
                    function(next) msg("Hi Van!",next) end,
                    function(next) msg(van,"Hi there - Would you like a tattoo?",next) end,
                    function(next)
                        local function showOptions()
                            local choices = {}
                            table.insert(choices, { 
                                label="Ask about bullet holes", 
                                fn=function() 
                                    composer.setVariable("vanMentionedStory",true);
                                    async.waterfall({
                                        function(next) msg(nena, "Umm... Are those bullet holes on the wall?", next) end,
                                        function(next) msg(van, "Ya the last few weeks have been pretty wild up in here", next) end,
                                        function(next) msg(van, "I gotta get rid of these security tapes! They hold a crazy story....", next) end,
                                    })
                                end
                            });
                            if composer.getVariable("phobeNeedsStory") and composer.getVariable("vanMentionedStory") then 
                                table.insert(choices, { 
                                    label="Ask about crazy story", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena, "You mentioned the past few weeks have been pretty crazy?", next) end,
                                            function(next) msg(van, "Ya it was wild! I'm surprised the police haven't shut this place down", next) end,
                                            function(next) msg(van, "And when the penguins got involved.... Well I shouldn't say anymore", next) end,
                                            function(next) msg(van, "After I get rid of these security tapes it will be like the past few weeks never happened.", next) end,
                                            function(next) msg(van, "They contain all the events of the last few weeks. So I have to get rid of them!", next) end,
                                        })
                                    end
                                });
                            end
                            if composer.getVariable("knowsSnacksAreMissing") and not Inventory:hasItem("Mac N Cheese")  then
                                table.insert(choices, { 
                                    label="Ask about Redbox Mac n Cheese", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena,"By any chance do you know where I can find a box of Red box Mac N Cheese?", next) end,
                                            function(next) msg(van,"Mac n cheese? I can't think about food right now.. I need to get rid of these tapes", next) end,
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
                                            function(next) msg(nena,"By any chance do you know where I can find a bottle of J Lohr?", next) end,
                                            function(next) msg(van,"You're in luck - I think Amber has some", next) end,
                                            function(next) showOptions() end,
                                        })
                                    end,
                                })
                            end
                            if composer.getVariable("knowsSnacksAreMissing") and not Inventory:hasItem("Truffle Chips")  then
                                table.insert(choices, { 
                                    label="Ask about Truffle Chips", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena,"By any chance do you know where I can find a bag of Truffle Chips?", next) end,
                                            function(next) msg(van,"Truffle Chips? I can't think about food right now.. I need to get rid of these tapes", next) end,
                                            function(next) showOptions() end,
                                        })
                                    end
                                });
                            end
                            if composer.getVariable("needsMacNCheeseEndorsements") and not composer.getVariable("haveVladEndorsement") then
                                table.insert(choices, { 
                                    label="Ask for an endorsement", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena, "Hi Van - Can you give me an endorsement for Redbox Mac n Cheese?", next) end,
                                            function(next) msg(van, "Like on camera? I can't be filmed right now. I may need to go into hiding.", next) end,
                                            function(next) showOptions() end,
                                        })
                                    end
                                });
                            end
                            table.insert(choices, { 
                                label="Ask about car", 
                                fn=function() 
                                    async.waterfall({
                                        function(next) msg(nena, "Is that your car outside?", next) end,
                                        function(next) msg(van, "Ya why? IS SOMEBODY MESSING WITH MY CAR AGAIN?!?!?", next) end,
                                        function(next) van:moveTo(111,39,next) end,
                                        function(next) 
                                            van:setXY(-111,-111) 
                                            composer.setVariable("vanLeft",true)
                                        end,
                                    })
                                end
                            });
                            table.insert(choices, {
                                label="That's all",
                                fn=function() next() end,
                            })
                            options(choices,next)
                        end
                        showOptions()
                    end,
                })
            end,
        }
    })

    door = Interactable:new(world,{
        name="exit",
        x=847,
        y=134,
        width=81,
        height=163,
        actions={
            Exit=function()
                async.waterfall({
                    function(next) nena:moveTo(111,39,next) end,
                    function(next) composer.gotoScene( "scenes.commercialdistrict" ) end,
                })
            end
        }
    })

    amber = Interactable:new(world,{
        name="Amber Rose",
        x=364,
        y=146,
        width=115,
        height=115,
        avatar="art/amber.png",
        useItemOn=function(item)
            if item.name == "Extra Oodie" and composer.getVariable("amberWantsOodie") and not Inventory:hasItem("J Lohr") then
                async.waterfall({
                    function(next) nena:moveTo(70,40,next) end,
                    function(next) nena:setFacing(-1); next() end,
                    function(next) msg("Hi Amber - Here's an Oodie. Can we still trade it for a bottle of wine?",next) end,
                    function(next) msg(amber,"Absolutely!",next) end,
                    function(next) Inventory:removeItem(extraOodie,next) end,
                    function(next) Inventory:addItem(jLohr,next) end,
                })
            end
        end,
        actions={
            Look=function()
                async.waterfall({
                    function(next) nena:moveTo(70,40,next) end,
                    function(next) nena:setFacing(-1); next() end,
                    function(next) msg("OMG! Is that... AMBER ROSE?!?! She's my fav",next) end,
                })
            end,
            Talk=function()
                async.waterfall({
                    function(next) nena:moveTo(70,40,next) end,
                    function(next) nena:setFacing(-1); next() end,
                    function(next)
                        if not composer.getVariable("metAmber") then
                            composer.setVariable("metAmber",true);
                            async.waterfall({
                                function(next) msg("OMG!.. Are you Amber Rose!?!?!",next) end,
                                function(next) msg(amber,"Hi There! Wow I love your outfit!",next) end,
                                function(next) msg("Thank you.. I'm a really big fan! I love you!!!",next) end,
                                function(next) msg(amber,"Thanks so much!",next) end,
                            },next)
                        else next() end
                    end,
                    function(next) 
                        local function showOptions()
                            local choices = {}
                            table.insert(choices, {
                                label="Ask Amber what she's doing",
                                fn=function()
                                    async.waterfall({
                                        function(next) msg("So what are you doing here Amber?",next) end,
                                        function(next) msg(amber,"I'm a big fan of 9mag. I'm here to get my next tattoo!",next) end,
                                        function(next) showOptions() end,
                                    })
                                end,
                            })
                            if composer.getVariable("knowsSnacksAreMissing") and not Inventory:hasItem("Mac N Cheese")  then
                                table.insert(choices, { 
                                    label="Ask about Redbox Mac n Cheese", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena,"By any chance do you know where I can find a box of Red box Mac N Cheese?", next) end,
                                            function(next) msg(amber,"Mac n cheese? Sorry I have no idea.", next) end,
                                            function(next) showOptions() end,
                                        })
                                    end
                                });
                            end
                            if composer.getVariable("knowsSnacksAreMissing") and not Inventory:hasItem("J Lohr")  then
                                table.insert(choices, {
                                    label="Ask about J Lohr",
                                    fn=function()
                                        if not composer.getVariable("amberWantsOodie") then
                                            composer.setVariable("amberWantsOodie",true)
                                            async.waterfall({
                                                function(next) msg("By any chance do you know where I can find a bottle of J Lohr",next) end,
                                                function(next) msg(amber,"Oh I love J Lohr. Actually I brought 2 bottles with me. I figured I'd need a drink while getting this tattoo!",next) end,
                                                function(next) msg("Wow! Can I please buy a bottle off you??",next) end,
                                                function(next) msg(amber,"I tell you what - I'll trade you for that amazing hooded garment you're wearing",next) end,
                                                function(next) msg("My oodie? Let me think about this....",next) end,
                                                function(next) showOptions() end,
                                            })
                                        else
                                            async.waterfall({
                                                function(next) msg(amber,"I love your outfit! I'll trade you a bottle of wine for it!",next) end,
                                                function(next) msg("My oodie? Let me think about this....",next) end,
                                                function(next) showOptions() end,
                                            })
                                        end
                                    end,
                                })
                            end
                            if composer.getVariable("knowsSnacksAreMissing") and not Inventory:hasItem("Truffle Chips")  then
                                table.insert(choices, { 
                                    label="Ask about Truffle Chips", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena, "By any chance do you know where I can find  a bag of truffle chips here?", next) end,
                                            function(next) msg(amber, "Ooh I love truffle chips! But I don't know where you can get some", next) end,
                                            function(next) showOptions() end,
                                        })
                                    end
                                });
                            end
                            if composer.getVariable("needsMacNCheeseEndorsements") and not composer.getVariable("haveVladEndorsement") then
                                table.insert(choices, { 
                                    label="Ask for an endorsement", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena, "Can you give me an endorsement for Redbox Mac n Cheese?", next) end,
                                            function(next) msg(amber, "Sorry boo. I don't do endorsements.", next) end,
                                            function(next) showOptions() end,
                                        })
                                    end
                                });
                            end
                            table.insert(choices, {
                                label="That's all",
                                fn=function() next() end,
                            })
                            options(choices)
                        end
                        showOptions()
                    end,
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
        van:setXY(27,39)
        composer.setVariable("vanLeft",false)

        if not composer.getVariable("gotTapes") then 
            securityTapesPic.isVisible = true
            securityTapesItem:enable()
        end

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
        composer.setVariable( "lastScene", "9mag" )
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