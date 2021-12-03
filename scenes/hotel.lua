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
securityTapes = require("items.securitytapes")

 
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
        filename="art/hotel.png",
        obstructfile="art/hotel-collision.png",
        foreground="art/hotel-foreground.png",
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
        spec=nenaChar,
        startX=18,
        startY=26,
        giveItemTo=function(item)
            if require("items.global")(item) then return end
            msg("I already have this!")
        end
    })
    self.nena = nena

    player = Player:new(world,map,nena)

    phoebe = Character:new(world,map,{
        name="Phoebe",
        spec=require("characters.phoebe"),
        avatar="art/phoebe.png",
        startX=46,
        startY=27,
        giveItemTo=function(item)
            print("give item to phoebe item.name="..item.name)
            --print("give item to phoebe phoebeNeedsStory="..composer.getVariable("phoebeNeedsStory"))
            --print("give item to phoebe phoebeWillEndorse="..composer.getVariable("phoebeWillEndorse"))
            if item.name=="Security Tapes" then
                if composer.getVariable("phoebeNeedsStory") then
                    async.waterfall({
                        function(next) nena:moveTo(38,28,next) end,
                        function(next) nena:setFacing(1) next() end,
                        function(next) msg("Hi Phoebe - These tapes are full of illegal activity. Can I trade it for a Redbox Mac N Cheese endorsement?",next) end,
                        function(next) msg(phoebe,"OMG.. Is this from THE 9mag. I'm a huge Black Ink Crew fan. I love Charmaine.",next) end,
                        function(next) msg(phoebe,"OK - I will endorse! Do you have something to record the endorsement with?",next) end,
                        function(next) 
                            Inventory:removeItem(securityTapes,next) 
                            composer.setVariable("phoebeWillEndorse",true)
                        end,
                    })
                else
                    msg(phoebe,"No thanks")
                end
            elseif item.name=="Video Camera" then
                if composer.getVariable("phoebeWillEndorse") and not composer.getVariable("havePhoebeEndorsement") then
                    composer.setVariable("havePhoebeEndorsement",true)
                    async.waterfall({
                        function(next) nena:moveTo(38,28,next) end,
                        function(next) nena:setFacing(1) next() end,
                        function(next) msg(nena, "Hi Phoebe - Can you please let me record you giving an endorsement for Redbox Mac n Cheese?", next) end,
                        function(next) msg(phoebe, "OK - Let's do it!", next) end,
                        function(next) msg(nena, "Thank you so much!",next) end,
                    })
                elseif composer.getVariable("phoebeWillEndorse") and composer.getVariable("havePhoebeEndorsement") then
                    msg("Thanks for the endorsement Phoebe!")
                else
                    msg(phoebe,"No thanks")
                end
            else
                msg(nena,"I can't give that to Phoebe!")
            end
        end,
        actions={
            Look=function()
                msg("Is that...... Phoebe from Criminal and This is love!?!")
            end,
            Talk=function() 
                async.waterfall({
                    function(next) nena:moveTo(38,28,next) end,
                    function(next) nena:setFacing(1) next() end,
                    function(next) msg(phoebe,"Hi. I'm Phoebe. And THIS....... is a hotel lobby.",next) end,
                    function(next)
                        local function showOptions()
                            local choices = {}
                            table.insert(choices, { 
                                label="Ask Phoebe about Criminal", 
                                fn=function() 
                                    async.waterfall({
                                        function(next) msg(nena, "OMG Phoebe! I love your podcast Criminal!", next) end,
                                        function(next) msg(phoebe, "Thank you so much. Criminal has been a lot of hard work to bring out there.", next) end,
                                        function(next) msg(phoebe, "We are always looking out for more quirky crime related stories.", next) end,
                                        function(next) showOptions() end,
                                    })
                                end
                            });
                            if composer.getVariable("knowsSnacksAreMissing") and not Inventory:hasItem("Mac N Cheese")  then
                                table.insert(choices, { 
                                    label="Ask about Redbox Mac n Cheese", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena, "Phoebe - Do you know where I can get redbox Mac n Cheese?", next) end,
                                            function(next) msg(phoebe, "I don't. But imagine a criminal episode that started with Mac n Cheese. That would be a hit!", next) end,
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
                                            function(next) msg(nena, "Phoebe - Do you know where I can get a bottle of J Lohr?", next) end,
                                            function(next) msg(phoebe, "I don't sorry", next) end,
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
                                            function(next) msg(nena, "Phoebe - Do you know where I can get a bag of Truffle Chips?", next) end,
                                            function(next) msg(phoebe, "I don't - But I bet Mark PusaCewan would.", next) end,
                                            function(next) msg(phoebe, "We had him featured in a Criminal episode but then had to cut him out after the anti-dentite scandal last year.", next) end,
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
                                            function(next) msg(nena, "Phoebe - Do you know where I can get another Oodie?", next) end,
                                            function(next) msg(phoebe, "My closet is full of them! I love a good oodie after a long day of podcasting.", next) end,
                                            function(next) showOptions() end,
                                        })
                                    end
                                });
                            end
                            if composer.getVariable("needsMacNCheeseEndorsements") and not composer.getVariable("havePhoebeEndorsement") then
                                table.insert(choices, { 
                                    label="Ask for an endorsement", 
                                    fn=function() 
                                        if not composer.getVariable("phoebeNeedsStory") then 
                                            composer.setVariable("phoebeNeedsStory",true);
                                            async.waterfall({
                                                function(next) msg(nena, "Phoebe can you please give me an endorsement for Redbox Mac n Cheese?", next) end,
                                                function(next) msg(phoebe, "Sorry. I only give endorsements to help the show.",next) end, 
                                                function(next) msg(phoebe, "If you would like to support the show please visit this is criminal dot com slash merch.", next) end,
                                                function(next) msg(nena, "Is there anything else I can do to help the show in exchange for an endorsement?",next) end,
                                                function(next) msg(phoebe, "Well we're really struggling to find our next quirky crime story. If you find one let me know!",next) end,
                                                function(next) showOptions() end,
                                            })
                                        else
                                            async.waterfall({
                                                function(next) msg(nena, "Is there anything I can do to help the show in exchange for an endorsement?",next) end,
                                                function(next) msg(phoebe, "Well we're really struggling to find our next quriky crime story. If you find one let me know!",next) end,
                                                function(next) showOptions() end,
                                            })
                                        end
                                    end
                                });
                            end
                            if composer.getVariable("knowsMAFSCancelled") then 
                                table.insert(choices, { 
                                    label="Ask about TV Studio", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena, "Do you know how I can get into the tv studio next door?", next) end,
                                            function(next) msg(phoebe, "Actually I think I do - Rumour has it that this hotel is connected to the tv studio",next) end, 
                                            function(next) msg(phoebe, "Take the right most elevator twice and that should bring you to where you need to go!", next) end,
                                            function(next) showOptions() end,
                                        })
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
                    end
                })
            end
        }
    })

    door = Interactable:new(world,{
        name="exit",
        x=75,
        y=72,
        width=126,
        height=119,
        actions={
            Exit=function()
                async.waterfall({
                    function(next) nena:moveTo(18,26,next) end,
                    function(next) composer.gotoScene( "scenes.businessdistrict" ) end,
                })
            end
        }
    })

    elevator1 = Interactable:new(world,{
        name="elevator1",
        x=622,
        y=59,
        width=81,
        height=132,
        actions={
            Use=function()
                composer.setVariable( "lastScene", "hotel" )
                async.waterfall({
                    function(next) nena:moveTo(83,25,next) end,
                    function(next) composer.gotoScene( "scenes.hotelhallway" ) end,
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
                composer.setVariable( "lastScene", "hotel2" )
                async.waterfall({
                    function(next) nena:moveTo(98,25,next) end,
                    function(next) composer.gotoScene( "scenes.hotelhallway" ) end,
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

        if (lastScene == "hotelhallway") then
            nena:setXY(83,26)
        elseif (lastScene == "hotelhallway2") then
            nena:setXY(98,26)
        elseif (lastScene == "hotelbridge") then
            nena:setXY(83,26)
        end
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
        local bgm = BGM:new()
        bgm:play( "music/sclubparty.mp3" )
    
        composer.setVariable( "lastScene", "hotel" )
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