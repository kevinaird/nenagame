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
        filename="art/tv-studio.png",
        obstructfile="art/tv-studio-collision.png",
        foreground="art/tv-studio-foreground.png",
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
        startX=104,
        startY=32,
        giveItemTo=function(item)
            if require("items.global")(item) then return end
            msg("I already have this!")
        end
    })
    self.nena = nena

    player = Player:new(world,map,nena)

    security0 = Character:new(world,map,{
        name="Security Guard",
        spec=require("characters.guard"),
        avatar="art/guard.png",
        startX=52,
        startY=26,
        actions={
            Look=function() 
                msg("It's a security guard")
            end,
            Talk=function() 
                if composer.getVariable("neveDistractSecurity") then
                    return msg("I shouldn't distract the guard right now")
                end
                async.waterfall({
                    function(next) nena:moveTo(44,29,next) end,
                    function(next) 
                        nena:setFacing(1)
                        security0:setFacing(-1)
                        next()
                    end,
                    function(next) msg("Hi - Excuse me. Can I get past you?",next) end,
                    function(next) msg(security0,"Sorry Ma'am - No one can enter the set while the show is filming",next) end,
                })
            end, 
        }
    })
    self.security = security0
    
    neve = Character:new(world,map,{
        name="Nev",
        spec=require("characters.nev"),
        avatar="art/nev.png",
        startX=99,
        startY=28,
        actions={
            Look=function() 
                msg("OMG It's Nev - One of the hosts of 90 day MAFS-Fish")
            end,
            Talk=function() 
                if composer.getVariable("neveDistractSecurity") then
                    return msg("I shouldn't distract Nev right now")
                end
                async.waterfall({
                    function(next) nena:moveTo(92,28,next) end,
                    function(next) nena:setFacing(1) next() end,
                    function(next) msg("OMG Hi Nev!!",next) end,
                    function(next) neve:setFacing(-1) next() end,
                    function(next) msg(neve,"Hi There!",next) end,
                    function(next) 
                        local function showOptions()
                            local choices = {}
                            table.insert(choices, { 
                                label="Ask Nev what he's doing here", 
                                fn=function()
                                    async.waterfall({
                                        function(next) msg(nena, "What are you doing here Nev?", next) end,
                                        function(next) msg(neve, "Just picking up my last pay check. As you may know 90 day MAFS-Fish after lockup AU has been cancelled sadly...", next) end,
                                        function(next) showOptions() end,
                                    })
                                end
                            });
                            table.insert(choices, { 
                                label="Ask abouts MAFS-Fish being cancelled", 
                                fn=function()
                                    async.waterfall({
                                        function(next) msg(nena, "Nev how could 90 day MAFS-Fish after lockup AU be cancelled?!?! It's my favourite show of all time!!", next) end,
                                        function(next) msg(neve, "I have no idea. That Matt Sharp guy is a real jerk. There's no convincing him.", next) end,
                                        function(next) showOptions() end,
                                    })
                                end
                            });
                            table.insert(choices, { 
                                label="Ask Nev where's Cammy", 
                                fn=function()
                                    async.waterfall({
                                        function(next) msg(nena, "Where's Cammy?", next) end,
                                        function(next) msg(neve, "She's coming by later today", next) end,
                                        function(next) showOptions() end,
                                    })
                                end
                            });
                            table.insert(choices, { 
                                label="Ask Nev where's Max", 
                                fn=function()
                                    async.waterfall({
                                        function(next) msg(nena, "Where's Max?", next) end,
                                        function(next) msg(neve, "He's actually working on a movie deal for a script he wrote about a DJ who gets mislead by someone he met online.", next) end,
                                        function(next) showOptions() end,
                                    })
                                end
                            });
                            if composer.getVariable("britPlanIsSet") and not composer.getVariable("neveDistractSecurity") then 
                                table.insert(choices, { 
                                    label="Ask Nev to distract the security guard", 
                                    fn=function()
                                        composer.setVariable("neveDistractSecurity",true)
                                        async.waterfall({
                                            function(next) msg(nena, "Nev I have an elaborate plan to confront Matt Sharp and uncancel MAFS-Fish!!", next) end,
                                            function(next) msg(nena, "Step 1. You distract the guard", next) end,
                                            function(next) msg(nena, "Step 2. I break into the Maury set and steal the lie detector results", next) end,
                                            function(next) msg(nena, "Step 3. Brittney Spears trades the lie detector results for a key card to Matt Sharps office", next) end,
                                            function(next) msg(nena, "Step 4. I confront Matt Sharp!!", next) end,
                                            function(next) msg(neve, "That plan.... sounds so ridiculous.... it might ACTUALLY WORK",next) end,
                                            function(next) msg(neve, "OK - Let me see what I can do",next) end,
                                            function(next) neve:moveTo(61,29,next) end,
                                            function(next)
                                                security0:setFacing(1)
                                                neve:setFacing(-1)
                                                msg(neve,"Excuse me - Can you help me with something over there?",next)
                                            end,
                                            function(next) msg(security0,"Yes sir",next) end, 
                                            function(next) 
                                                neve:moveTo(3,27)
                                                security0:moveTo(5,32)
                                            end
                                        })
                                    end
                                })
                            end
                            table.insert(choices, { 
                                label="That's all", 
                                fn=function() next() end
                            });

                            options(choices, next) 
                        end
                        showOptions()
                    end,
                })
            end,
        }
    })
    self.neve = neve

    exit = Interactable:new(world,{
        name="exit",
        x=821,
        y=0,
        width=24,
        height=336,
        actions={
            Exit=function()
                async.waterfall({
                    function(next) nena:moveTo(104,32,next) end,
                    function(next) composer.gotoScene( "scenes.hotelbridge" ) end,
                })
            end
        }
    })

    officeDoor = Interactable:new(world,{
        name="office door",
        x=69,
        y=64,
        width=64,
        height=125,
        useItemOn=function(item)
            if item.name == "Key Card" then 
                async.waterfall({
                    function(next) nena:moveTo(13,25,next) end,
                    function(next) msg("It's unlocked!",next) end,
                    function(next) 
                        composer.setVariable("sharpOfficeUnlocked",true)
                        composer.gotoScene( "scenes.sharpentertainment" ) 
                    end
                })
            else
                msg("That doesn't work")
            end
        end,
        actions={
            Open=function()
                async.waterfall({
                    function(next) nena:moveTo(13,25,next) end,
                    function(next) 
                        if not composer.getVariable("sharpOfficeUnlocked") then 
                            composer.setVariable("triedSharpDoor",true)
                            msg("It's locked")
                        else
                            composer.gotoScene( "scenes.sharpentertainment" ) 
                        end
                    end,
                })
            end
        }
    })

    setDoor = Interactable:new(world,{
        name="set door",
        x=371,
        y=66,
        width=64,
        height=125,
        actions={
            Open=function()
                if not composer.getVariable("neveDistractSecurity") then
                    async.waterfall({
                        function(next) nena:moveTo(44,29,next) end,
                        function(next) msg(security0,"Sorry Ma'am - No one can enter the set while the show is filming",next) end,
                    })
                else
                    async.waterfall({
                        function(next) nena:moveTo(51,25,next) end,
                        function(next) composer.gotoScene( "scenes.mauryset" ) end,
                    })
                end
            end
        }
    })

    bathroomDoor = Interactable:new(world,{
        name="bathroom door",
        x=654,
        y=66,
        width=64,
        height=125,
        actions={
            Open=function()
                async.waterfall({
                    function(next) nena:moveTo(87,25,next) end,
                    function(next) composer.gotoScene( "scenes.bathroom" ) end,
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
        security0 = self.security
        neve = self.neve
        
        self.nena:reinit()
        self.security:reinit()
        self.neve:reinit()

        if (lastScene == "hotelbridge") then
            nena:setXY(104,32)
        elseif (lastScene == "sharpentertainment") then
            nena:setXY(13,25)
        elseif (lastScene == "bathroom") then
            nena:setXY(87,25)
        elseif (lastScene == "mauryset") then
            nena:setXY(51,25)
        end
        
        if composer.getVariable("neveDistractSecurity") then
            neve:setXY(3,27)
            neve:setFacing(-1)
            security0:setXY(5,32)
            security0:setFacing(-1)
        else 
            security0:setXY(52,26)
        end
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

        local bgm = BGM:new()
        bgm:play( "music/sclubparty.mp3" )

        if (lastScene == "hotelbridge") then
            nena:moveTo(101,32)
        end

        composer.setVariable( "lastScene", "tvstudio" )
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
        if self.security then self.security:deinit() end
        if self.neve then self.neve:deinit() end
 
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