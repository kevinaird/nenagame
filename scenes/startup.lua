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
local options = require("engine.options")
local msg = require("engine.narrator")
local cutscene = require("engine.cutscene")

 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
    local backgroundMusic = audio.loadStream( "music/toxic.mp3" )
    self.backgroundMusicChannel = audio.play( backgroundMusic )

    local rect = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
    rect:setFillColor(0,0,0)
    local menuIsShowing = false

    local txt = display.newEmbossedText({
        parent=sceneGroup, 
        text="A 'Kevin doing crazy things for Nena' Production...",
        x=display.contentCenterX,
        y=display.contentCenterY,
        fontSize=18
    })
    txt.alpha = 0

    local b = display.newImage(sceneGroup, "art/startup.jpg")
    local r = 3024/4032
    b.width = display.contentWidth
    b.height = display.contentWidth * r
    b.x, b.y = display.contentCenterX, display.contentCenterY
    b.alpha = 0
    self.background = b

    async.waterfall({
        function(next)
            rect:addEventListener("touch", function() 
                if menuIsShowing then return end
                next("Skip")
            end)

            transition.to(txt,{
                alpha=1,
                time=2000,
                onComplete=function() next() end
            })
        end,
        function(next)
            timer.performWithDelay(1000,function() next() end)
        end,
        function(next)
            transition.to(txt,{
                alpha=0,
                time=2000,
                onComplete=function() next() end
            })
        end,
        function (next) 
            txt.text = "In collaboration with 'Duate helped me' Productions..."
            transition.to(txt,{
                alpha=1,
                time=2000,
                onComplete=function() next() end
            })
        end,
        function(next)
            timer.performWithDelay(1000,function() next() end)
        end,
        function(next)
            transition.to(txt,{
                alpha=0,
                time=2000,
                onComplete=function() next() end
            })
        end,
        function(next)

            transition.to(b,{
                alpha=1,
                time=3000,
                onComplete=function() next() end
            })
        end,
        function(next)
            timer.performWithDelay(3000,function() next() end)
        end,
    }, function()
        if txt then txt.alpha = 0 end
        b.alpha = 1
        if menuIsShowing then return end
        menuIsShowing = true
        self:showMenu()
    end)

end

function scene:showMenu()
    options({
        { 
            label="New Game", 
            fn=function() 

                async.waterfall({
                    function(next)
                        audio.fadeOut({ channel=self.backgroundMusicChannel, time=2000 })
                        transition.to(self.background,{
                            alpha=0,
                            time=2000,
                            onComplete=function() next() end
                        })
                    end,
                    function(next)
                        audio.stop(self.backgroundMusicChannel)
                        audio.setVolume( 1 , { channel=self.backgroundMusicChannel })

                        -- cutscene("yammy.mp4",true,next)
                        next()

                    end
                }, function()
                    composer.gotoScene( "scenes.nenasapartment" )
                end)
            end 
        },
        { 
            label="Load Game", 
            fn=function() 
                require("engine.loadgame")()
                -- async.waterfall({
                --     function(next) msg("Whoops. That doesn't work yet.",next) end,
                --     function(next) self:showMenu() end
                -- })
            end 
        },
    })
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
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