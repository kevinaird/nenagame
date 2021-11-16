local Button = require("engine.button")

function cutscene(videoFname, skippable, next)

    if (system.getInfo("environment") == "simulator" or system.getInfo("platform") == "win32") then
        print("Skipped video: "..videoFname)
        return next()
   end

   hasEnded = false
   
   video = native.newVideo( display.contentCenterX, display.contentCenterY, display.contentWidth*0.82, display.contentHeight*0.82 )

   local stopAndNext = function()
        if hasEnded then return end
        hasEnded = true
        video:removeSelf()
        if bttn then bttn:removeSelf() end
        next()
   end
   
   if skippable then
    bttn = Button:new({
        label="Skip",
        width=50,
        height=24,
        x=display.contentWidth-52,
        y=display.contentHeight-26
        },stopAndNext)
    end

   local function videoListener( event )
       print( "Event phase: " .. event.phase )
       if (event.phase == "ended") then 
            stopAndNext()
       end
   end
   
   local hostname = "192.168.86.32" 
   --local hostname = "clipsmatic1.ddns.net"

   local url = ("http://%s/NenaGame/%s"):format(hostname,videoFname)
   video:load(url, media.RemoteSource )

   video:addEventListener( "video", videoListener )
   video:play()


end


return cutscene