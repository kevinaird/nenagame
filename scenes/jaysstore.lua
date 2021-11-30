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
churro = require("items.churro")

 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
    print("jays store create")
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
    local bgm = BGM:new()
    bgm:play( "music/sclubparty.mp3" )

    local world = createWorld(sceneGroup)
    self.world = world

    map = Map:new(world,{
        width=845,
        height=338,
        filename="art/jaysstore.png",
        obstructfile="art/jaysstore-collision.png",
        foreground="art/jaysstore-foreground.png",
        scaleFn=(function (x, y) 
            -- return 0.6
            if ( y >= 25 ) then 
               return 0.6 + 0.4*(y-25)/39;
            else
               return 0.6
            end
        end)
    })

    nena = Character:new(world,map,{
        name="player",
        spec=nenaChar,
        startX=70,
        startY=25,
        giveItemTo=function(item)
            if require("items.global")(item) then return end
            msg("I already have this!")
        end
    })
    self.nena = nena

    player = Player:new(world,map,nena)
    
    translator = Character:new(world,map,{
        name="Translator",
        spec=require("characters.guard"),
        avatar="art/guard.png",
        startX=35,
        startY=39,
        actions={
            Talk=function()
                if not composer.getVariable("needsTranslator") then 
                    msg(translator,"Please move along ma'am")
                    return 
                end
                async.waterfall({
                    function(next) nena:moveTo(58,39,next) end,
                    function(next) nena:setFacing(-1) next() end,
                    function(next) msg(translator,"Hi - I can translate anything you would like to say to Vlad",next) end,
                    function(next)
                        local function showOptions()
                            local choices = {} 

                            if not composer.getVariable("vladdyNotHangry") then 
                                table.insert(choices, { 
                                    label="Ask Vladdy what he's doing here", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena, "What is Vladdy doing here?", next) end,
                                            function(next) msg(translator, "He's here shooting a Bluejays commercial - But we're having an issue", next) end,
                                            function(next) msg(nena, "What's wrong?", next) end,
                                            function(next) msg(translator, "We skipped breakfast and lunch and unfortunately..........", next) end,
                                            function(next) msg(translator, "Vladdy is hangry!", next) end,
                                            function(next) msg(nena, "Oh no..", next) end,
                                            function(next) showOptions() end,
                                        })
                                    end
                                });
                                if composer.getVariable("knowsSnacksAreMissing") and not Inventory:hasItem("Mac N Cheese")  then
                                    table.insert(choices, { 
                                        label="Ask about Redbox Mac n Cheese", 
                                        fn=function() 
                                            async.waterfall({
                                                function(next) msg(nena, "Does Vladdy know where I can get a box of Red box Mac N Cheese?", next) end,
                                                function(next) msg(translator, ".... Now is not the time to ask Vladdy about food.", next) end,
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
                                                function(next) msg(nena, "Does Vladdy know where I can get a bottle of J Lohr?", next) end,
                                                function(next) msg(translator, "I'll ask", next) end,
                                                function(next) msg(vladdy, "...", next) end,
                                                function(next) msg(translator, "No he doesnt.", next) end,
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
                                                function(next) msg(nena, "Does Vladdy know where I can get a bag of Truffle Chips?", next) end,
                                                function(next) msg(translator, ".... Now is not the time to ask Vladdy about food.", next) end,
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
                                                function(next) msg(nena, "Does Vladdy know where I can get another Oodie?", next) end,
                                                function(next) msg(translator, "I'll ask", next) end,
                                                function(next) msg(vladdy, "...", next) end,
                                                function(next) msg(translator, "No he doesnt.", next) end,
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
                                                function(next) msg(nena, "Would Vladdy give me an endorsement for Redbox Mac n Cheese?", next) end,
                                                function(next) msg(translator, "I'm sorry. He's starved right now. He won't entertain anything like that right now.", next) end,
                                                function(next) showOptions() end,
                                            })
                                        end
                                    });
                                end
                            else
                                if composer.getVariable("needsMacNCheeseEndorsements") and not composer.getVariable("haveVladEndorsement") then
                                    table.insert(choices, { 
                                        label="Ask for an endorsement", 
                                        fn=function() 
                                            composer.setVariable("vladWillEndorse",true)
                                            async.waterfall({
                                                function(next) msg(nena, "Would Vladdy give me an endorsement for Redbox Mac n Cheese?", next) end,
                                                function(next) msg(translator, "I'll ask.", next) end,
                                                function(next) msg(vladdy, "...", next) end,
                                                function(next) msg(translator, "He says YES! Do you have something you can use to record his endorsement?",next) end,
                                            })
                                        end
                                    });
                                end
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
            end,
        }
    })

    vladdy = Character:new(world,map,{
        name="Vladdy",
        spec=require("characters.vladdy"),
        avatar="art/vlad.png",
        startX=48,
        startY=39,
        giveItemTo=function(item)
            if item.name=="Churro" and not composer.getVariable("vladdyNotHangry") then
                composer.setVariable("vladdyNotHangry",true)
                async.waterfall({
                    function(next) nena:moveTo(58,39,next) end,
                    function(next) msg(nena, "Hi Vladdy - Would you like a churro?", next) end,
                    function(next) msg(vladdy, "...", next) end,
                    function(next) msg(translator, "OMG - Vladdy loves Churros!!! Thank you so much!", next) end,
                    function(next) Inventory:removeItem(churro,next) end,
                })
            elseif item.name=="Video Camera" and composer.getVariable("needsMacNCheeseEndorsements") and not composer.getVariable("haveVladEndorsement") and composer.getVariable("vladWillEndorse") then
                composer.setVariable("haveVladEndorsement",true)
                async.waterfall({
                    function(next) nena:moveTo(58,39,next) end,
                    function(next) msg(nena, "Hi Vladdy - Can you please let me record you giving an endorsement for Redbox Mac n Cheese?", next) end,
                    function(next) msg(translator, "OK - He's ready!", next) end,
                    function(next) msg(vladdy, "...", next) end,
                    function(next) msg(nena, "Thank you so much!",next) end,
                })
            elseif item.name=="Video Camera" and composer.getVariable("haveVladEndorsement") then
                async.waterfall({
                    function(next) nena:moveTo(58,39,next) end,
                    function(next) msg(nena, "Thanks for the endorsement vladdy!", next) end,
                })
            else
                msg(vladdy,"...")
            end
        end,
        actions={
            Look=function()
                msg("O. M. G. It's Vlademir Guerrero Jr!!!!")
            end,
            Talk=function() 
                composer.setVariable("needsTranslator",true)
                async.waterfall({
                    function(next) nena:moveTo(58,39,next) end,
                    function(next) msg("Hi Vladdy - I'm a huge fan",next) end,
                    function(next) msg(vladdy,"...",next) end,
                    function(next) msg(translator,"Hi - I can transalate for you",next) end,
                })
            end,
        }
    })

    exit = Interactable:new(world,{
        name="exit",
        x=528,
        y=62,
        width=64,
        height=126,
        actions={
            Exit=function()
                async.waterfall({
                    function(next) nena:moveTo(70,25,next) end,
                    function(next) composer.gotoScene( "scenes.commercialdistrict" ) end,
                })
            end
        }
    })

    Inventory:new()
end
 
 
-- show()
function scene:show( event )
    print("jays store show")
 
    local sceneGroup = self.view
    local phase = event.phase
    local lastScene = composer.getVariable("lastScene")
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        nena = self.nena
        world = self.world
        
        self.nena:reinit()
        nena:setXY(70,25)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

        composer.setVariable( "lastScene", "jaysstore" )
    end

end
 
 
-- hide()
function scene:hide( event )
    print("jays store hide")
 
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
    print("jays store destroy")
 
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
