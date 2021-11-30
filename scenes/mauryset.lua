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
tableChar = require("characters.table")

lieDetectorResults = require("items.liedetectorresults")

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
    local bgm = BGM:new()
    bgm:play( "music/maury.mp3" )

    local world = createWorld(sceneGroup)
    self.world = world

    map = Map:new(world,{
        width=604,
        height=338,
        filename="art/maury-set.png",
        obstructfile="art/maury-set-collision.png",
        foreground="art/maury-set-foreground.png",
        scaleFn=(function (x, y) 
            --return 1.0
            if ( y >= 29 ) then 
                return 0.5 + 0.3*(y-29)/12;
            else
                return 0.5
            end
        end)
    })

    nena = Character:new(world,map,{
        name="player",
        spec=nenaChar,
        startX=75,
        startY=38,
        giveItemTo=function(item)
            if require("items.global")(item) then return end
            msg("I already have this!")
        end
    })
    self.nena = nena

    player = Player:new(world,map,nena)

    mauryTable = Character:new(world,map,{
        name="table",
        spec=tableChar,
        startX=20,
        startY=40,
        actions={
            Look=function()
                if not composer.getVariable("tookLieDetectorResults") then 
                    msg("It's the lie detector results!!")
                else
                    msg("The table is empty now")
                end
            end,
            Take=function()
                if not composer.getVariable("tookLieDetectorResults") then 
                    if not composer.getVariable("mauryLeft") then 
                        if composer.getVariable("mauryTherapist")=="plants" then 
                            msg(maury,"Excuse me miss - Can you please only work with the plants? Since you're a plant therapist and all")
                        elseif composer.getVariable("mauryTherapist")=="guests" then 
                            msg(maury,"You can talk directly to the guests")
                        end
                    else
                        composer.setVariable("tookLieDetectorResults",true)
                        mauryTable.sprite:setSequence( "stand2" )
                        mauryTable.sprite:play()
                        Inventory:addItem(lieDetectorResults)
                    end
                else
                    msg("The table is empty now")
                end
            end
        }
    })
    self.mauryTable = mauryTable

    security1 = Character:new(world,map,{
        name="Security Guy 1",
        avatar="art/guard.png",
        spec=require("characters.guard"),
        startX=-10,
        startY=36,
        actions={
            Look=function() msg("They look busy") end,
            Talk=function() msg(security1,"Not right now ma'am") end,
        }
    })
    security1.speed = 0.4
    self.security1 = security1

    security2 = Character:new(world,map,{
        name="Security Guy 2",
        avatar="art/guard.png",
        spec=require("characters.guard"),
        startX=90,
        startY=36,
        actions={
            Look=function() msg("They look busy") end,
            Talk=function() msg(security2,"Not right now ma'am") end,
        }
    })
    security2.speed = 0.4
    self.security2 = security2

    local function causeFight()
        if not composer.getVariable("davidMad") then return end
        if not composer.getVariable("annieMad") then return end
        if not composer.getVariable("andreaMad") then return end
        if not composer.getVariable("lamarMad") then return end

        composer.setVariable("guestsFighting",true)

        async.waterfall({
            function(next) msg(andrea,"That's it - Everybody in here gon' die!!!",next) end,
            function(next) 
                loopFn = function(person)
                    if not composer.getVariable("guestsFighting") then return end
                    person.speed = 0.5
                    async.waterfall({
                        function(next) person:moveTo(56,30,next) end,
                        function(next) 
                            if not composer.getVariable("guestsFighting") then return end
                            person:moveTo(18,32,next) 
                        end,
                        function(next) loopFn(person) end
                    })
                end
                loopFn(david)
                loopFn(annie)
                loopFn(andrea)
                loopFn(lamar)

                timer.performWithDelay(2000, function() next() end)
            end,
            function(next) msg(maury,"uh oh... security!!!",next) end,
            function(next) 
                maury.speed=0.5 
                maury:moveTo(1,40,next)
            end,
            function(next) 
                maury:setXY(-10,40)
                composer.setVariable("mauryLeft",true)
                security1:moveTo(28,35)
                security2:moveTo(48,35,next) 
            end,
            function(next) msg(security1,"Break it up peope!",next) end,
        })


    end

    david = Character:new(world,map,{
        name="David",
        avatar="art/david.png",
        spec=require("characters.david"),
        startX=22,
        startY=31,
        actions={
            Look=function()
                msg("It's David from 90 Day Fiance! I hate his shirts!")
            end,
            Talk=function()
                if composer.getVariable("mauryTherapist")=="plants" then 
                    msg(maury,"Excuse me miss - Can you please only work with the plants? Since you're a plant therapist and all")
                    return
                end
                if composer.getVariable("davidMad") then
                    msg(david,"I can't even talk anymore Doc! I'm so mad!!")
                    return
                end
                async.waterfall({
                    function(next) msg("Hi David!",next) end,
                    function(next) msg(david,"Hi Doc - Can you help?",next) end,
                    function(next) 
                        options({
                            {
                                label="Tell David that Annie loves him",
                                fn=function() 
                                    msg(david,"Well thanks Doc. That's good to hear atleast")
                                end
                            },
                            {
                                label="Tell David that Lamar is sorry",
                                fn=function() 
                                    msg(david,"Well thanks Doc. That's good to hear atleast")
                                end
                            },
                            {
                                label="Tell David that Andrea hates his shirt",
                                fn=function() 
                                    composer.setVariable("davidMad",true)
                                    async.waterfall({
                                        function(next) msg(david,"That makes me really angry!",next) end,
                                        function(next) causeFight() end,
                                    })
                                end
                            }
                        })
                    end
                })
            end
        }
    })
    david:setFacing(1)
    self.david = david

    
    annie = Character:new(world,map,{
        name="Annie",
        avatar="art/annie.png",
        spec=require("characters.annie"),
        startX=33,
        startY=31,
        actions={
            Look=function()
                msg("It's Annie from 90 Day Fiance!")
            end,
            Talk=function()
                if composer.getVariable("mauryTherapist")=="plants" then 
                    msg(maury,"Excuse me miss - Can you please only work with the plants? Since you're a plant therapist and all")
                    return
                end
                if composer.getVariable("annieMad") then
                    msg(annie,"I can't talk Doctor! I so mad!!")
                    return
                end
                async.waterfall({
                    function(next) msg("Hi Annie!",next) end,
                    function(next) msg(annie,"Hi Doctor!",next) end,
                    function(next) 
                        options({
                            {
                                label="Tell Annie that David forgives her",
                                fn=function() 
                                    msg(annie,"That's good to hear. I'm so sorry.")
                                end
                            },
                            {
                                label="Tell Annie that Andrea wants to be friends",
                                fn=function() 
                                    msg(annie,"That's sounds too good to be true")
                                end
                            },
                            {
                                label="Tell Annie that Andrea said she's a beeyotch",
                                fn=function() 
                                    composer.setVariable("annieMad",true) 
                                    async.waterfall({
                                        function(next) msg(annie,"That makes me really angry!",next) end,
                                        function(next) causeFight() end,
                                    })
                                end
                            }
                        })
                    end
                })
            end
        }
    })
    annie:setFacing(1)
    self.annie = annie
    
    andrea = Character:new(world,map,{
        name="Andrea",
        avatar="art/andrea.png",
        spec=require("characters.andrea"),
        startX=43,
        startY=31,
        actions={
            Look=function()
                msg("It's Andrea from Love after lockup!")
            end,
            Talk=function()
                if composer.getVariable("mauryTherapist")=="plants" then 
                    msg(maury,"Excuse me miss - Can you please only work with the plants? Since you're a plant therapist and all")
                    return
                end
                if composer.getVariable("andreaMad") then
                    msg(andrea,"I'm seeing red! May christ have mercy on your souls!!!!")
                    return
                end
                async.waterfall({
                    function(next) msg("Hi Andrea!",next) end,
                    function(next) msg(andrea,"I'm about to cut everybody in here",next) end,
                    function(next) 
                        options({
                            {
                                label="Tell Andrea that Annie apologizes profusely",
                                fn=function() 
                                    msg(andrea,"She better! Or else I'll have to cut her!")
                                end
                            },
                            {
                                label="Tell Andrea that Lamar couldn't see life without her",
                                fn=function() 
                                    msg(andrea,"I know he won't! I'll make sure of it! In Jesus's name.")
                                end
                            },
                            {
                                label="Tell Andrea that Lamar is blowing kisses at Annie",
                                fn=function() 
                                    composer.setVariable("andreaMad",true) 
                                    async.waterfall({
                                        function(next) msg(andrea,"Lord forgive me for the sins I'm about to commit",next) end,
                                        function(next) causeFight() end,
                                    })
                                end
                            }
                        })
                    end
                })
            end
        }
    })
    andrea:setFacing(-1)
    self.andrea = andrea
    
    lamar = Character:new(world,map,{
        name="Lamar",
        avatar="art/lamar.png",
        spec=require("characters.lamar"),
        startX=53,
        startY=31,
        actions={
            Look=function()
                msg("It's Lamar from Love after lockup!")
            end,
            Talk=function()
                if composer.getVariable("mauryTherapist")=="plants" then 
                    msg(maury,"Excuse me miss - Can you please only work with the plants? Since you're a plant therapist and all")
                    return
                end
                if composer.getVariable("lamarMad") then
                    msg(lamar,"I can't even talk anymore yo! I'm heated!!")
                    return
                end
                async.waterfall({
                    function(next) msg("Hi Lamar!",next) end,
                    function(next) msg(lamar,"Sup?",next) end,
                    function(next) 
                        options({
                            {
                                label="Tell Lamar that David just wants peace",
                                fn=function() 
                                    msg(lamar,"I agree - I'm all about that love and peace")
                                end
                            },
                            {
                                label="Tell Lamar that Andrea can get past this",
                                fn=function() 
                                    msg(lamar,"I agree - We can all get past this")
                                end
                            },
                            {
                                label="Tell Lamar that Andrea wants to mount Annie's head on her wall",
                                fn=function() 
                                    composer.setVariable("lamarMad",true) 
                                    async.waterfall({
                                        function(next) msg(lamar,"Oh hell naw!!",next) end,
                                        function(next) causeFight() end,
                                    })
                                end
                            }
                        })
                    end
                })
            end
        }
    })
    lamar:setFacing(-1)
    self.lamar = lamar
    
    maury = Character:new(world,map,{
        name="Maury",
        avatar="art/maury.png",
        spec=require("characters.maury"),
        startX=28,
        startY=40,
        actions={
            Look=function()
                msg("OMG - It's Maury! I love this show!!")
            end,
            Talk=function()
                if composer.getVariable("mauryTherapist")=="plants" then 
                    msg(maury,"Excuse me miss - Can you please only work with the plants? Since you're a plant therapist and all")
                elseif composer.getVariable("mauryTherapist")=="guests" then 
                    msg(maury,"You can talk directly to the guests")
                end
            end
        }
    })
    maury:setFacing(1)
    self.maury = maury
    
    plants = Interactable:new(world,{
        name="Plants",
        x=36,
        y=178,
        width=81,
        height=41,
        useItemOn=function(item) 
            if item.name == "Lie Detector Results" then
                async.waterfall({
                    function(next) nena:moveTo(11,31,next) end,
                    function(next) 
                        Inventory:removeItem(lieDetectorResults)
                        composer.setVariable("hidLieDetectorResultsInPlants",true)
                        msg("I'll put them here. Just for now",next)
                    end,
                })
            end
        end,
        actions={
            Look=function() msg("Those plants look like they've seen better days") end,
            Touch=function()
                async.waterfall({
                    function(next) nena:moveTo(11,31,next) end,
                    function(next) 
                        if composer.getVariable("mauryTherapist")=="guests" and not composer.getVariable("mauryLeft") then 
                            msg(maury,"Hi Doctor - Don't worry about the plants. You can talk directly to the guests")
                        elseif composer.getVariable("hidLieDetectorResultsInPlants") then 
                            composer.setVariable("hidLieDetectorResultsInPlants",false)
                            Inventory:addItem(lieDetectorResults)
                        else 
                            msg("I don't want to touch these plants")
                        end
                    end,
                })
            end
        }
    })

    door = Interactable:new(world,{
        name="exit",
        x=576,
        y=97,
        width=29,
        height=241,
        actions={
            Exit=function()
                async.waterfall({
                    function(next) nena:moveTo(75,38,next) end,
                    function(next) 
                        if composer.getVariable("mauryLeft") and Inventory:hasItem("Lie Detector Results") then 
                            async.waterfall({
                                function(next) msg(security1,"Hey you! Put the lie detector results back!",next) end,
                                function(next) 
                                    Runtime:dispatchEvent( { name="dialogOpen" } )
                                    nena:moveTo1(28,40,false,next) 
                                end,
                                function(next) 
                                    Inventory:removeItem(lieDetectorResults)
                                    composer.setVariable("tookLieDetectorResults",false)
                                    mauryTable.sprite:setSequence( "stand" )
                                    mauryTable.sprite:play()
                                    nena:moveTo1(75,38,false,next)
                                end,
                                function(next) 
                                    Runtime:dispatchEvent( { name="dialogClosed" } )
                                    composer.setVariable("davidMad",false)
                                    composer.setVariable("annieMad",false)
                                    composer.setVariable("andreaMad",false)
                                    composer.setVariable("lamarMad",false)
                                    composer.setVariable("mauryLeft",false)
                                    composer.setVariable("guestsFighting",false)
                                    composer.gotoScene( "scenes.tvstudio" ) 
                                end, 
                            })
                        else
                            composer.setVariable("davidMad",false)
                            composer.setVariable("annieMad",false)
                            composer.setVariable("andreaMad",false)
                            composer.setVariable("lamarMad",false)
                            composer.setVariable("mauryLeft",false)
                            composer.setVariable("guestsFighting",false)
                            composer.gotoScene( "scenes.tvstudio" ) 
                        end
                    end,
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
        self.nena:setXY(75,38)

        self.security1:setXY(-10,36)
        self.security2:setXY(90,36)
        self.david:setXY(22,31)
        self.david:setFacing(1)
        self.annie:setXY(33,31)
        self.annie:setFacing(1)      
        self.andrea:setXY(43,31)
        self.andrea:setFacing(-1)
        self.lamar:setXY(53,31)
        self.lamar:setFacing(-1)
        self.maury:setXY(28,40)
        self.maury:setFacing(1)

        maury = self.maury
        print("maury="..maury.name)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

        if not composer.getVariable("tookLieDetectorResults") then 
            self.mauryTable.sprite:setSequence( "stand" )
            self.mauryTable.sprite:play()
        else
            self.mauryTable.sprite:setSequence( "stand2" )
            self.mauryTable.sprite:play()
        end

        local function mauryAsksNena()
            async.waterfall({
                function(next) msg(maury,"Hey and someone in an oodie just entered the set - Can you tell me who you are?",next) end,
                function(next) msg(nena,"Who me?",next) end,
                function(next) 
                    options({
                        {
                            label="Say you're the security guard",
                            fn=function()
                                async.waterfall({
                                    function(next) msg(nena,"I'm a new security guard!",next) end,
                                    function(next) msg(maury,"Oh ok. They really are getting relaxed with the dress code for you guys. Can you come back when.. I mean if.. a fight breaks out? Thanks",next) end, 
                                    function(next) nena:moveTo(75,38,next) end,
                                    function(next) composer.gotoScene( "scenes.tvstudio" ) end,
                                })
                            end
                        },
                        {
                            label="Say you're the sexy decoy",
                            fn=function()
                                async.waterfall({
                                    function(next) msg(nena,"I'm the sexy decoy!",next) end,
                                    function(next) msg(maury,"Oh ok. But the sexy decoy isn't needed until the next story. Can you come back then? Thanks",next) end, 
                                    function(next) nena:moveTo(75,38,next) end,
                                    function(next) composer.gotoScene( "scenes.tvstudio" ) end,
                                })
                            end
                        },
                        {
                            label="Say you're a new producer",
                            fn=function()
                                async.waterfall({
                                    function(next) msg(nena,"I'm a new producer!",next) end,
                                    function(next) msg(maury,"Oh ok. Can you come back after the show finishes taping? I'll introduce you to everyone who works on the show! Thanks",next) end, 
                                    function(next) nena:moveTo(75,38,next) end,
                                    function(next) composer.gotoScene( "scenes.tvstudio" ) end,
                                })
                            end
                        },
                        {
                            label="Say you're a studio guest therapist",
                            fn=function()
                                composer.setVariable("mauryTherapist","guests")
                                async.waterfall({
                                    function(next) msg(nena,"I'm a new studo guest therapist!",next) end,
                                    function(next) msg(maury,"Oh right! We discussed this at the last staff meeting. Come on in!",next) end, 
                                })
                            end
                        },
                        {
                            label="Say you're a studio plant therapist",
                            fn=function()
                                composer.setVariable("mauryTherapist","plants")
                                async.waterfall({
                                    function(next) msg(nena,"I'm a new studo plant therapist!",next) end,
                                    function(next) msg(maury,"Thank GOD! Do you see these studio plants? It's an emergency. Please come right in. We'll shoot the show around you.",next) end, 
                                })
                            end
                        },
                        {
                            label="Say you're a studio host therapist",
                            fn=function()
                                async.waterfall({
                                    function(next) msg(nena,"I'm the new studio host therapist",next) end,
                                    function(next) msg(maury,"It's about time! I really need help doc. But can you come back at the commercial break? Thanks",next) end,                                    
                                    function(next) nena:moveTo(75,38,next) end,
                                    function(next) composer.gotoScene( "scenes.tvstudio" ) end,
                                })
                            end
                        }
                    })
                end,
            })
        end

        if composer.getVariable("notFirstTimeOnMaurySet") then 
            async.waterfall({
                function(next) nena:moveTo(68,38,next) end,
                function(next) msg(maury,"David tell us how it felt went Annie cheated on you with Lamar!",next) end,
                function(next) msg(david,"Not very good at all!",next) end,
                function(next) mauryAsksNena() end,
            })
        else 
            composer.setVariable("notFirstTimeOnMaurySet",true)
            async.waterfall({
                function(next) nena:moveTo(68,38,next) end,
                function(next) msg(maury,"Welcome back to another episode of Maury! Today we have quite a situation unfolding",next) end,
                function(next) msg(maury,"David and Annie are a couple who got married after 90 days on the K1 visa",next) end,
                function(next) msg(maury,"and Lamar and Andrea are couple who found love together after Lamar came home from several years locked up!",next) end,
                function(next) msg(maury,"And it looks like Annie and Lamar have a secret they want to tell David and Andrea!",next) end,
                function(next) msg(david,"Say what?",next) end,
                function(next) msg(andrea,"Lord jesus I pray for forgiveness cause I may have to cut a bitch",next) end,
                function(next) mauryAsksNena() end,
            })
        end
        composer.setVariable( "lastScene", "mauryset" )
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