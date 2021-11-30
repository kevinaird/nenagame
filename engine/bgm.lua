local async = require("async")

local BGM = { currentBGM=false }
BGM.__index = BGM

function BGM:new(opts)
    o = opts or {}
    setmetatable(o, self)
    self.__index = self

    if (self.currentBGM) then return self.currentBGM end
    self.currentBGM = o
    self.currentPlaying = ""

    return o
end

function BGM:play(fname)
    async.waterfall({
        function(next) 
            print("BGM play currentPlaying="..self.currentPlaying)
            print("BGM play fname="..fname)
            if self.currentPlaying == fname then return 
            else next() end 
        end,
        function(next) 
            if self.currentPlaying ~= "" then self:stop(next) 
            else next() end 
        end,
        function(next)
            self.handle = audio.loadStream( fname )
            self.channel = audio.play( self.handle )
            audio.setVolume(0.7,{ channel=self.channel })
            self.currentPlaying = fname
        end,
    })
end

function BGM:stop(cb) 
    local t = 1000
    audio.fadeOut(t)
    self.currentPlaying = ""
    if cb then timer.performWithDelay(t,function() cb() end); end
end

return BGM