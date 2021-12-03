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
        width=648,
        height=331,
        filename="art/lost-and-found.png",
        obstructfile="art/lost-and-found-collision.png",
        foreground="art/lost-and-found-foreground.png",
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

    door = Interactable:new(world,{
        name="exit",
        x=0,
        y=0,
        width=46,
        height=331,
        actions={
            Exit=function()
                async.waterfall({
                    function(next) nena:moveTo(5,39,next) end,
                    function(next) composer.gotoScene( "scenes.commercialdistrict" ) end,
                })
            end
        }
    })

    clerk = Interactable:new(world,{
        name="Clerk",
        avatar="art/duane.png",
        x=388,
        y=127,
        width=88,
        height=96,
        useItemOn=function(item)
            if item.name == "Photo Album" and composer.getVariable("needsIDProof") and not Inventory:hasItem("Wallet") then 
                async.waterfall({
                    function(next) nena:moveTo(44,40,next) end,
                    function(next) nena:setFacing(1) next() end,
                    function(next) msg(nena,"Hello - Take a look at this photo album",next) end,
                    function(next) msg(nena,"Here's me wearing a Nena-Rae T-shirt",next) end,
                    function(next) msg(nena,"Here's me at the Watson family reunion. Lots of table slams there.",next) end,
                    function(next) msg(nena,"Here's me graduating from medical school",next) end,
                    function(next) msg(clerk,"Look - I need better proof then this",next) end,
                    function(next) msg(nena,"Here's me in a white lab coat and a stethascope",next) end,
                    function(next) msg(clerk,"Well obviously this must mean you are in fact a doctor",next) end,
                    function(next) msg(clerk,"Sorry doctor. I have to be certain I'm returning items to the right owner",next) end,
                    function(next) msg(clerk,"Here's your wallet!",next) end,
                    function(next) Inventory:addItem(wallet) end,
                })
            else
                msg(clerk,"No thank you")
            end
        end,
        actions={
            Talk=function()
                async.waterfall({
                    function(next) nena:moveTo(44,40,next) end,
                    function(next) nena:setFacing(1) next() end,
                    function(next) msg(clerk,"Hello - Welcome to the Lost and Found office. How may I help you?",next) end,
                    function(next)
                        showOptions = function()
                            local choices = {}

                            if composer.getVariable("knowsSnacksAreMissing") and not Inventory:hasItem("Mac N Cheese")  then
                                table.insert(choices, { 
                                    label="Ask about Redbox Mac n Cheese", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena, "Hello has anyone turned in a box of Red box Mac N Cheese?", next) end,
                                            function(next) msg(clerk, ".... No one has brought Mac n Cheese here. People don't usually bring food to the lost and found...", next) end,
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
                                            function(next) msg(nena, "Has anyone brought a bottle of J Lohr here?", next) end,
                                            function(next) msg(clerk, "J what?", next) end,
                                            function(next) msg(nena, "Lohr! It's wine! Cab sav!", next) end,
                                            function(next) msg(clerk, "We definately have no wine here.", next) end,
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
                                            function(next) msg(nena, "Has anyone brought a bag of truffle chips here?", next) end,
                                            function(next) msg(clerk, "No food here ma'am", next) end,
                                            function(next) showOptions() end,
                                        })
                                    end
                                });
                            end
                            if composer.getVariable("walletIsMissing") and not Inventory:hasItem("Wallet") then
                                table.insert(choices, { 
                                    label="Ask about Wallet", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena, "Has anyone turned in a wallet?", next) end,
                                            function(next) msg(clerk, "Yes - We have received a wallet recently. Can you describe it?", next) end,
                                            function(next)
                                                options({
                                                    {
                                                        label="I't grey!",
                                                        fn=function() msg(clerk,"Sorry - We haven't received a grey wallet",showOptions) end
                                                    },
                                                    {
                                                        label="I't black with gold patterns!",
                                                        fn=function() next() end
                                                    },
                                                    {
                                                        label="I't blue with white polkadots!",
                                                        fn=function() msg(clerk,"Sorry - We haven't received a blue wallet",showOptions) end
                                                    },
                                                    {
                                                        label="I't pink with 90 day fiance people on it!",
                                                        fn=function() msg(clerk,"Sorry - We haven't received.... a wallet like that....",showOptions) end
                                                    },
                                                },next)
                                            end,
                                            function(next) msg(clerk, "Yes - And there is a ID inside the wallet. Can you tell me your name?", next) end,
                                            function(next)
                                                options({
                                                    {
                                                        label="Ms. Nena-Rae Watson",
                                                        fn=function() msg(clerk,"Sorry - That's not the name on the ID.",showOptions) end
                                                    },
                                                    {
                                                        label="Mrs. Nena-Rae Watson",
                                                        fn=function() msg(clerk,"Sorry - That's not the name on the ID.",showOptions) end
                                                    },
                                                    {
                                                        label="Captain Nena-Rae Watson",
                                                        fn=function() msg(clerk,"Sorry - That's not the name on the ID.",showOptions) end
                                                    },
                                                    {
                                                        label="Dr. Nena-Rae Watson",
                                                        fn=function() next() end
                                                    },
                                                },next)
                                            end,
                                            function(next) msg(clerk,"Yes. And can you show me some proof that you are Dr. Nena-Rae Watson?",next) end,
                                            function(next) msg(nena,"You mean like my ID? It's in my wallet.",next) end,
                                            function(next) msg(clerk,"Any photographic evidence at all that you are in fact Dr. Nena-Rae Watson will do",next) end,
                                            function(next)
                                                composer.setVariable("needsIDProof",true)
                                                showOptions()
                                            end,
                                        })
                                    end
                                });
                            end
                            if composer.getVariable("amberWantsOodie") and not Inventory:hasItem("Extra Oodie") and not Inventory:hasItem("J Lohr") then
                                table.insert(choices, { 
                                    label="Ask about an Oodie", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena, "Has anyone brought in an oodie?", next) end,
                                            function(next) msg(clerk, "A what?", next) end,
                                            function(next) msg(nena, "An oodie! Like what I'm wearing", next) end,
                                            function(next) msg(clerk, "Oh is that what that's called? Actually someone did bring one in", next) end,
                                            function(next) msg(clerk, "Normally I would need evidence that the... 'oodie' belongs to you... But I don't think anyone else would wear this. So it must be yours.", next) end,
                                            function(next) Inventory:addItem(extraOodie,next) end,
                                            function(next) msg(nena, "Thanks!", next) end,
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
    self.clerk = clerk

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
        clerk = self.clerk
 
        self.nena:reinit()

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
        local bgm = BGM:new()
        bgm:play( "music/sclubparty.mp3" )
    
        composer.setVariable( "lastScene", "lostandfound" )
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