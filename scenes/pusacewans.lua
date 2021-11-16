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
truffeChips = require("items.trufflechips")
macNCheese = require("items.macncheese")
videoCamera = require("items.videocamera")
 
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
        width=1146,
        height=564,
        filename="art/pusacewans.png",
        obstructfile="art/pusacewans-collision.png",
        foreground="art/pusacewans-foreground.png",
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
        startX=67,
        startY=42,
        giveItemTo=function(item)
            if require("items.global")(item) then return end
            msg("I already have this!")
        end
    })
    self.nena = nena

    clerk = Character:new(world,map,{
        name="clerk",
        spec=defaultChar,
        avatar="art/avatar1.png",
        startX=103,
        startY=49,
        giveItemTo=function(item)
            if item.name=="Video Camera" and composer.getVariable("needsMacNCheeseEndorsements") and composer.getVariable("haveVladEndorsement") and composer.getVariable("havePhoebeEndorsement") and composer.getVariable("haveRupaulEndorsement") then 
                async.waterfall({
                    function(next) nena:moveTo(114,50,next) end,
                    function(next) msg("Here you go - I have 3 celebrity endorsements recorded for Redbox Mac n Cheese!",next) end,
                    function(next) msg(clerk,"Amazing! This is just what I need to convince Mark PusaCewan!",next) end,
                    function(next) msg(clerk,"None of the celebrities are dentists right?",next) end,
                    function(next) msg("...No.. No dentists included",next) end,
                    function(next) msg(clerk,"OK - Not like it makes a difference..... Anyways here's my Redbox Mac n cheese!",next) end,
                    function(next) 
                        Inventory:removeItem(videoCamera,next) 
                        Inventory:addItem(macNCheese,next) 
                    end,
                })
            elseif item.name=="Video Camera" and composer.getVariable("needsMacNCheeseEndorsements") then 
                msg("I don't have all 3 endorsements yet - But i'll be back!")
            else
                msg(clerk,"No thanks!")
            end
        end,
        actions={
            Look=function()
                msg("It's a pusacewans clerk")
            end,
            Talk=function()
                async.waterfall({
                    function(next) nena:moveTo(114,50,next) end,
                    function(next) msg(clerk,"Welcome to PusaCewans! How may I help you today?.",next) end,
                    function(next) 
                        local function showOptions()
                            local choices = {}

                            table.insert(choices, { 
                                label="Ask if he knows Mark PusaCewan", 
                                fn=function() 
                                    async.waterfall({
                                        function(next) msg(nena, "Hi - Do you know Mark PusaCewan?", next) end,
                                        function(next) msg(clerk, "Ya I know Mark! He's a genius chef. No one can beat him on the food network.", next) end,
                                        function(next) msg(clerk, "But he can be a real stickler about what food goes on the shelves here. He keeps discontinuing my favourite foods!", next) end,
                                        function(next) showOptions() end,
                                    })
                                end
                            });
                            table.insert(choices, { 
                                label="Ask about Mark PusaCewan anti-dentite scandal", 
                                fn=function() 
                                    async.waterfall({
                                        function(next) msg(nena, "Do you remember that scandal in the news Mark was in?", next) end,
                                        function(next) msg(clerk, "Ya that was a real witch hunt! I mean some of Marks best friends are dentists!", next) end,
                                        function(next) showOptions() end,
                                    })
                                end
                            });
                            if composer.getVariable("knowsSnacksAreMissing") and not Inventory:hasItem("J Lohr")  then
                                table.insert(choices, { 
                                    label="Ask about J Lohr", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena, "Does this store carry J Lohr wine?", next) end,
                                            function(next) msg(clerk, "Unfortunately no. We don't sell any alcohol here.", next) end,
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
                                            function(next) msg(nena, "Does this store have any Truffle Chips?", next) end,
                                            function(next) msg(clerk, "Absolutely! You can find them just to the right on the shelf over there!", next) end,
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
                                            function(next) msg(nena, "Does this store have any oodies?", next) end,
                                            function(next) msg(clerk, "Is that a cereal?", next) end,
                                            function(next) msg(nena, "No - An oodie! Like what I'm wearing", next) end,
                                            function(next) msg(clerk, "... Uh... We only sell food here.", next) end,
                                            function(next) showOptions() end,
                                        })
                                    end
                                });
                            end
                            if composer.getVariable("knowsSnacksAreMissing") and not Inventory:hasItem("Mac N Cheese")  then
                                table.insert(choices, { 
                                    label="Ask about Redbox Mac n Cheese", 
                                    fn=function() 
                                        if not composer.getVariable("knowsClerkHasMacNCheese") then 
                                            composer.setVariable("knowsClerkHasMacNCheese",true);
                                            async.waterfall({
                                                function(next) msg(nena, "Does this store carry any Red box Mac N Cheese?", next) end,
                                                function(next) msg(clerk, "OMG! I love Red box Mac n Cheese!!! My absolute favourite. Mark said no one would miss it when he discontinued it!", next) end,
                                                function(next) msg(clerk, "I can't wait to tell him a customer asked for it!", next) end,
                                                function(next) msg(nena, "Discontinued? So you don't have any?", next) end,
                                                function(next) msg(clerk, "Well I love it - So as soon as I heard Mark was removing it from the shelves I bought the last crate", next) end,
                                                function(next) msg(clerk, "I bring a box of it every day for my lunch break now!", next) end,
                                                function(next) showOptions() end,
                                            })
                                        elseif not composer.getVariable("needsMacNCheeseEndorsements") then 
                                            composer.setVariable("needsMacNCheeseEndorsements",true)
                                            async.waterfall({
                                                function(next) msg(nena, "Can I buy the Mac N Cheese from your lunch off you? It's urgent!", next) end,
                                                function(next) msg(clerk, "No can do! I gotta have my lunch.", next) end,
                                                function(next) msg(nena, "Please? PUHHH-LEEEAAAASE!!", next) end,
                                                function(next) msg(clerk, "Look maybe we can help each other. I don't want to give this box away since I know my supply is limited.", next) end,
                                                function(next) msg(clerk, "But if you can help me get endorsements from some high profile people - That would help me convince Mark to re-stock the redboxes!", next) end,
                                                function(next) msg(nena, "I can do that!", next) end,
                                                function(next) msg(clerk, "Great! Get me 3 endorsements for Red box Mac n Cheese and my lunch is yours!", next) end,
                                                function(next) showOptions() end,
                                            })
                                        else 
                                            async.waterfall({
                                                function(next) msg(clerk, "If you can help me get 3 endorsements from some high profile people for Red box Mac n Cheese - my lunch is yours!", next) end,
                                                function(next) msg(nena, "Leave it to me!", next) end,
                                                function(next) showOptions() end,
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
            end,
        }
    })

    player = Player:new(world,map,nena)

    door = Interactable:new(world,{
        name="Door",
        x=412,
        y=173,
        width=235,
        height=152,
        actions={
            Exit=function()
                async.waterfall({
                    function(next) nena:moveTo(67,42,next) end,
                    function(next) 
                        if Inventory:hasItem(truffeChips.name) and not composer.getVariable("paidForChips") then
                            async.waterfall({
                                function(next) msg(clerk,"Excuse me... Lady in the large oversized oodie... You have to pay for those chips",next) end,
                                function(next) msg("Oh right... I'll put them back.",next) end,
                                function(next) nena:moveTo(125,45,next) end,
                                function(next) Inventory:removeItem(truffeChips,next) end,
                            })
                        else
                            next()
                        end
                    end,
                    function(next) composer.gotoScene( "scenes.commercialdistrict" ) end,
                })
            end
        }
    })

    chips = Interactable:new(world,{
        name="Chips",
        x=932,
        y=219,
        width=98,
        height=26,
        actions={
            Take=function()
                async.waterfall({
                    function(next) nena:moveTo(125,44,next) end,
                    function(next) 
                        if Inventory:hasItem(truffeChips.name) then
                            msg("I already have Truffle Chips!")
                        else
                            msg("Truffle chips!!!",next) 
                        end
                    end,
                    function(next) Inventory:addItem(truffeChips,next) end,
                })
            end
        }
    })

    cashier = Interactable:new(world,{
        name="Cashier",
        avatar="art/avatar2.png",
        x=157,
        y=274,
        width=91,
        height=119,
        actions={
            Talk=function()
                async.waterfall({
                    function(next) nena:moveTo(29,63,next) end,
                    function(next) 
                        if Inventory:hasItem(truffeChips.name) and not composer.getVariable("paidForChips") then
                            async.waterfall({
                                function(next) msg(cashier,"Hello! One bag of truffle chips. Were you able to find everything you were looking for today?",next) end,
                                function(next)
                                    showOptions = function()
                                        options({
                                            { 
                                                label="Ask about Redbox Mac n Cheese", 
                                                fn=function() 
                                                    async.waterfall({
                                                        function(next) msg(nena, "Actually no - I was looking for Redbox Mac n Cheese", next) end,
                                                        function(next) msg(cashier, "Redbox? Is that a brand?", next) end,
                                                        function(next) msg(nena, "No.. I don't remember the brand... it comes in a red box!", next) end,
                                                        function(next) msg(cashier, "... I don't think we carry that", next) end,
                                                        function(next) showOptions() end,
                                                    })
                                                end
                                            },
                                            { 
                                                label="Ask about J Lohr", 
                                                fn=function() 
                                                    async.waterfall({
                                                        function(next) msg(nena, "I was looking for a bottle of JLohr as well", next) end,
                                                        function(next) msg(cashier, "We don't carry alcohol here. Maybe try the LCBO?", next) end,
                                                        function(next) showOptions() end,
                                                    })
                                                end
                                            },
                                            { 
                                                label="Just checkout", 
                                                fn=function() next() end
                                            }
                                        },next)
                                    end
                                    showOptions()
                                end,
                                function(next) msg(cashier,"And that will be $4.99",next) end,
                                function(next) 
                                    if Inventory:hasItem("Wallet") then 
                                        composer.setVariable("paidForChips",true);
                                        msg(cashier,"Thank you. Have a nice day!",next)
                                    else
                                        composer.setVariable("walletIsMissing",true);
                                        async.waterfall({
                                            function(next) msg(nena,"Oh no.... Where's my wallet??? I can't find it......",next) end,
                                            function(next) msg(cashier,"Oh my god.. Did you misplace your wallet? That's so horrible. A real once in a lifetime event!",next) end,
                                            function(next) msg(nena,"It really is horrible! Last week when this exact same thing happened I was so upset!",next) end,
                                            function(next) msg(cashier,"......ok. Well the Truffle Chips will be right here when you find your wallet.", next) end,
                                            function(next) Inventory:removeItem(truffeChips) end
                                        })
                                    end
                                end
                            })
                            
                        else
                            async.waterfall({
                                function(next) msg(cashier,"May I help you?",next) end,
                                function(next) msg(nena, "No not really", next) end
                            })
                        end
                    end,
                    function(next) Inventory:addItem(truffeChips,next) end,
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

        if not composer.getVariable("visitedPusacewans") then
            composer.setVariable("visitedPusacewans",true);
            async.waterfall({
                function(next) msg(clerk,"Welcome to PusaCewans Fine Foods!",next) end,
                function(next) 
                    if composer.getVariable("knowsSnacksAreMissing") then
                        async.waterfall({
                            function(next) msg("This is the store by famous chef Mark PusaCewan!",next) end,
                            function(next) msg("I know him from food network shows like the 'Ultimate Top Chop Chef' and 'Beat Mark PusaCewan'!",next) end,
                            function(next) msg("Interestingly, Mark was caught in a scandal involving his flippant use of anti-dentite slurs late last year...",next) end,
                            function(next) msg("This place must have Truffle chips and Redbox Mac and Cheese!!",next) end,
                        })
                    end
                end
            })
        end
 
        composer.setVariable( "lastScene", "pusacewans" )
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