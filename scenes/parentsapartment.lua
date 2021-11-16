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
defaultChar = require("characters.nena")
photoAlbum = require("items.photoalbum")

 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
    print("parents apartment create")
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
    local backgroundMusic = audio.loadStream( "music/sclubparty.mp3" )
    audio.play( backgroundMusic )
    self.backgroundMusic = backgroundMusic

    local world = createWorld(sceneGroup)
    self.world = world

    map = Map:new(world,{
        width=791,
        height=338,
        filename="art/parents-apartment.png",
        obstructfile="art/parents-apartment-collision.png",
        foreground="art/parents-apartment-foreground.png",
        scaleFn=(function (x, y) 
            -- return 1.0
            if ( y >= 20 ) then 
                return 0.6 + 0.2*(y-20)/21;
             else
                return 0.6
             end
        end)
    })

    nena = Character:new(world,map,{
        name="player",
        spec=defaultChar,
        startX=92,
        startY=22,
        giveItemTo=function(item)
            if require("items.global")(item) then return end
            msg("I already have this!")
        end
    })
    self.nena = nena

    player = Player:new(world,map,nena)

    photoAlbumPic = display.newImage(world,"art/photo-album.png")
    photoAlbumPic.x, photoAlbumPic.y = 93, 155  
    photoAlbumPic.width, photoAlbumPic.height = 35, 35
    photoAlbumPic.isVisible = false

    photoAlbumItem = Interactable:new(world,{
        name="Photo Album",
        x=93-25,
        y=155-25,
        width=50,
        height=50,
        actions={
            Look=function()
                async.waterfall({
                    function(next) nena:moveTo(23,28,next) end,
                    function(next) msg("It's a Watson family Photo Album!", next) end,
                })
            end,
            Take=function() 
                if not composer.getVariable("needsIDProof") then
                    msg("I don't need that")
                else
                    async.waterfall({
                        function(next) nena:moveTo(23,28,next) end,
                        function(next) 
                            photoAlbumPic.isVisible = false
                            photoAlbumItem:disable()
                            async.waterfall({
                                function(next) nena:moveTo(23,28,next) end,
                                function(next) msg("It's a Watson family Photo Album!", next) end,
                                function(next) Inventory:addItem(photoAlbum,next) end,
                            })
                        end
                    })
                end
            end
        }
    })
    photoAlbumItem:disable()

    exit = Interactable:new(world,{
        name="exit",
        x=700,
        y=4,
        width=75,
        height=146,
        actions={
            Exit=function()
                print("going right")
                async.waterfall({
                    function(next) nena:moveTo(92,22,next) end,
                    function(next) composer.gotoScene( "scenes.outsideparents" ) end,
                })
            end
        }
    })
    Inventory:new()
end
 
 
-- show()
function scene:show( event )
    print("parents apartment show")
 
    local sceneGroup = self.view
    local phase = event.phase
    local lastScene = composer.getVariable("lastScene")
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        nena = self.nena
        world = self.world
        
        self.nena:reinit()
        nena:setXY(92,22)

        if not Inventory:hasItem("Photo Album") then
            photoAlbumPic.isVisible = true
            photoAlbumItem:enable()
        end
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
        composer.setVariable( "lastScene", "parentsapartment" )
    end

end
 
 
-- hide()
function scene:hide( event )
    print("parents apartment hide")
 
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
    print("parents apartment destroy")
 
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