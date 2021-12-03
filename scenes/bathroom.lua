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

lieDetectorResults = require("items.liedetectorresults")
keyCard = require("items.keycard")
 
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
        width=906,
        height=331,
        filename="art/bathroom.png",
        obstructfile="art/bathroom-collision.png",
        foreground="art/bathroom-foreground.png",
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
        startX=101,
        startY=39,
        giveItemTo=function(item)
            if require("items.global")(item) then return end
            msg("I already have this!")
        end
    })
    self.nena = nena

    player = Player:new(world,map,nena)

    britney = Character:new(world,map,{
        name="Britney",
        avatar="art/britney.png",
        spec=require("characters.britney"),
        startX=14,
        startY=36,
        giveItemTo=function(item)
            if item.name == "Lie Detector Results" then 
                async.waterfall({
                    function(next) nena:moveTo(34,38,next) end,
                    function(next) nena:setFacing(-1) next() end,
                    function(next) msg("Hi Britney - I have the lie detector results!",next) end,
                    function(next) msg(britney,"That's amazing!! Great work! Here's the key card as promised",next) end,
                    function(next) 
                        Inventory:removeItem(lieDetectorResults)
                        Inventory:addItem(keyCard,next)
                    end,
                })
            else
                msg("I can't give Britney that!")
            end
        end,
        actions={
            Look=function()
                msg("OMG It's Britney!")
            end,
            Talk=function()
                async.waterfall({
                    function(next) nena:moveTo(34,38,next) end,
                    function(next) nena:setFacing(-1) next() end,
                    function(next) msg("OMG Hi Britney!!!",next) end,
                    function(next) msg(britney,"Hola!",next) end,
                    function(next)
                        local function showOptions()
                            local choices = {}
                            table.insert(choices, { 
                                label="Ask Britney why she's in the bathroom", 
                                fn=function() 
                                    composer.setVariable("britMentionedLieDetector",true)
                                    async.waterfall({
                                        function(next) msg(nena, "OMG Britney I love you so much. But what are you doing here?", next) end,
                                        function(next) msg(britney, "You know - Just enjoying my new found freedom. Living life!", next) end,
                                        function(next) msg(britney, "Also - Trying to come up with a plan to prevent some lie detector results from being released.", next) end,
                                        function(next) msg(britney, "Just a regular day of the week", next) end,
                                        function(next) showOptions() end,
                                    })
                                end
                            });
                            table.insert(choices, { 
                                label="Ask about studio", 
                                fn=function() 
                                    composer.setVariable("britMentionedLieDetector",true)
                                    async.waterfall({
                                        function(next) msg(nena, "Do you know whats filming next door?", next) end,
                                        function(next) msg(britney, "It's an episode of Maury!", next) end,
                                        function(next) msg(nena, "Really!? I love Maury!", next) end,
                                        function(next) msg(britney, "Ya me too! Right now I gotta stop him from releasing some lie detector results though", next) end,
                                        function(next) msg(britney, "Other then that he's great!", next) end,
                                        function(next) showOptions() end,
                                    })
                                end
                            });
                            if composer.getVariable("britMentionedLieDetector") then
                                table.insert(choices, { 
                                    label="Ask about Lie Detector", 
                                    fn=function() 
                                        async.waterfall({
                                            function(next) msg(nena, "So why do you need to prevent lie detector results from being released", next) end,
                                            function(next) msg(britney, "It's a long story! Involving my friend Susan the psychic medium", next) end,
                                            function(next) msg(britney, "She said \"ya'll have to get those results\" So thats what I'm doing!", next) end,
                                            function(next) showOptions() end,
                                        })
                                    end
                                })
                            end 
                            if composer.getVariable("triedSharpDoor") and not composer.getVariable("sharpOfficeUnlocked") then 
                                table.insert(choices, { 
                                    label="Ask about Sharp Entertainment", 
                                    fn=function() 
                                        if Inventory:hasItem("Key Card") then 
                                            msg(britney,"Thanks again!",showOptions)
                                        elseif not composer.getVariable("britPlanIsSet") then 
                                            composer.setVariable("britPlanIsSet",true)
                                            composer.setVariable("britMentionedLieDetector",true)
                                            async.waterfall({
                                                function(next) msg(nena, "Do you know how to get into the Sharp Entertainment offices?", next) end,
                                                function(next) msg(britney, "Oh ya - I had a meeting there earlier. All you need is a key card like this one I have", next) end,
                                                function(next) msg(nena, "OMG - Can you please give me that key card? PUHH-LEEAAASSSEE!", next) end,
                                                function(next) msg(britney, "Sure - As soon as I figure out how to get Maury's lie detector results its all yours!", next) end,
                                                function(next) msg(nena, "If I get the results for you - Will you trade them for the key card?", next) end,
                                                function(next) msg(britney, "Absolutely! OMG I just came up with a plan for how to get the results!", next) end,
                                                function(next) msg(britney, "I can't go into Maury's studo because everyone would recognize me!", next) end,
                                                function(next) msg(britney, "You may stand out a little - I mean since your wearing an oodie. But maybe you can get them for me!!!", next) end,
                                                function(next) msg(nena, "OK - leave it to me!", next) end,
                                                function(next) showOptions() end,
                                            })
                                        else
                                            async.waterfall({
                                                function(next) msg(britney, "As soon as you get the lie detector results the key card to Sharp Entertainment offices are yours!!", next) end,
                                                function(next) msg(nena, "OK - leave it to me!", next) end,
                                                function(next) showOptions() end,
                                            })
                                        end
                                    end
                                });
                            end
                            table.insert(choices, { 
                                label="That's all", 
                                fn=function() next() end
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
        x=804,
        y=66,
        width=74,
        height=249,
        actions={
            Exit=function()
                async.waterfall({
                    function(next) nena:moveTo(101,39,next) end,
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
 
        local bgm = BGM:new()
        bgm:play( "music/sclubparty.mp3" )
    
        composer.setVariable( "lastScene", "bathroom" )
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