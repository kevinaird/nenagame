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
    print("park create")
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
    local bgm = BGM:new()
    bgm:play( "music/sclubparty.mp3" )

    local world = createWorld(sceneGroup)
    self.world = world

    map = Map:new(world,{
        width=966,
        height=564,
        filename="art/park.png",
        obstructfile="art/park-collision.png",
        foreground="art/park-foreground.png",
        scaleFn=(function (x, y) 
            -- return 0.6
            if ( y >= 56 ) then 
               return 0.7 + 0.3*(y-56)/13;
            else
               return 0.7
            end
        end)
    })

    nena = Character:new(world,map,{
        name="player",
        spec=nenaChar,
        startX=38,
        startY=60,
        giveItemTo=function(item)
            if require("items.global")(item) then return end
            msg("I already have this!")
        end
    })
    self.nena = nena

    player = Player:new(world,map,nena)

    mom = Character:new(world,map,{
        name="mom",
        spec=require("characters.winsome"),
        avatar="art/winsome.png",
        startX=95,
        startY=57,
        giveItemTo=function(item)
            async.waterfall({
                function(next) nena:moveTo(85,57,next) end,
                function(next) msg("Hi Mommy! Do you want this?",next) end,
                function(next) msg(mom,"No thanks Neens",next) end,
            })
        end,
        actions={
            Look=function()
                msg("It's my mom!")
            end,
            Talk=function()
                if composer.getVariable("needsIDProof") and not Inventory:hasItem("Photo Album") then 
                    async.waterfall({
                        function(next) nena:moveTo(85,57,next) end,
                        function(next) msg("Mommy! I need photographic proof that I'm who I say I am!",next) end,
                        function(next) msg(mom,"Nena-Rae! Did you lose your wallet again?",next) end,
                        function(next) msg("I did... But its at the Lost and Found and the Lost and Found clerk won't give it to me without photographic proof!",next) end,
                        function(next) msg(mom,"We probably have something that can help at our house",next) end,
                    })
                else
                    if not composer.getVariable("momSteps") then
                        composer.setVariable("momSteps",20000)
                    else
                        composer.setVariable("momSteps",composer.getVariable("momSteps")+8000)
                    end
                    async.waterfall({
                        function(next) nena:moveTo(85,57,next) end,
                        function(next) msg("Hi Mommy! What are you doing?",next) end,
                        function(next) msg(mom,("Hi Neens - I'm getting my steps! I'm already at %d steps!"):format(composer.getVariable("momSteps")),next) end,
                        function(next) msg("That's great!",next) end,
                    })
                end
            end
        }
    })
    self.mom = mom

    churroStand = Interactable:new(world,{
        name="Churro Stand",
        avatar="art/cashier.png",
        x=85,
        y=308,
        width=114,
        height=69,
        actions={
            Talk=function()
                async.waterfall({
                    function(next) nena:moveTo(27,59,next) end,
                    function(next) nena:setFacing(-1) next() end,
                    function(next) 
                        if not composer.getVariable("gotFreeChurro") then 
                            async.waterfall({
                                function(next) msg(churroStand,"Hello - Welcome to Free Churro day! Would you like a free churro?",next) end,
                                function(next) options({
                                    {
                                        label="Yes!",
                                        fn=function()
                                            composer.setVariable("gotFreeChurro",true)
                                            Inventory:addItem(churro,next)
                                        end
                                    },
                                    {
                                        label="No",
                                        fn=function() next() end
                                    }
                                }) end,
                            })
                        else
                            msg(churroStand,"Hi - Welcome back! Please spread the word about Free Churro Day!")
                        end
                    end
                })
            end
        }
    })

    exitToNenas = Interactable:new(world,{
        name="go left",
        x=0,
        y=356,
        width=41,
        height=208,
        actions={
            Exit=function()
                async.waterfall({
                    function(next) nena:moveTo(2,63,next) end,
                    function(next) composer.gotoScene( "scenes.outsidenenas" ) end,
                })
            end
        }
    })

    exitToCity = Interactable:new(world,{
        name="go right",
        x=924,
        y=362,
        width=42,
        height=202,
        actions={
            Exit=function()
                async.waterfall({
                    function(next) nena:moveTo(119,61,next) end,
                    function(next) composer.gotoScene( "scenes.commercialdistrict" ) end,
                })
            end
        }
    })

    Inventory:new()
end
 
 
-- show()
function scene:show( event )
    print("park show")
 
    local sceneGroup = self.view
    local phase = event.phase
    local lastScene = composer.getVariable("lastScene")
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        nena = self.nena
        world = self.world

        self.nena:reinit()

        if ( lastScene == "outsidenenas") then
            nena:setXY(8,60)
        elseif ( lastScene == "commercialdistrict" ) then
            nena:setXY(119,61)
        end

        if not composer.getVariable("knowsMAFSCancelled") then
            self.mom:setXY(95,57)
        else
            self.mom:setXY(-99,57)
        end

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
        if ( lastScene == "outsidenenas") then
            nena:moveTo(12,60)
        elseif ( lastScene == "commercialdistrict" ) then
            nena:moveTo(113,61)
        end


        composer.setVariable( "lastScene", "park" )
        
        if not composer.getVariable("knowsMAFSCancelled") then
            loopFn = function(mom)
                if composer.getVariable("lastScene") ~= "park" then return end
                async.waterfall({
                    function(next) mom:moveTo(111,57,next) end,
                    function(next) mom:moveTo(70,57,next) end,
                    function(next) loopFn(mom) end
                })
            end
            loopFn(self.mom)
        end
    end

end
 
 
-- hide()
function scene:hide( event )
    print("park hide")
 
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
    print("park destroy")
 
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