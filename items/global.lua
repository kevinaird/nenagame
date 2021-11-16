local composer = require( "composer" )
local inspect = require("inspect")
local async = require("async")

local Inventory = require("engine.inventory")
local msg = require("engine.narrator")
local options = require("engine.options")

return function(item)
    if item.name == "Battery" then
        async.waterfall({
            function(next) msg("What should I do with this battery?",next) end,
            function(next) 
                local choices = {}
                if Inventory:hasItem("Outdoor Oodie") then
                    table.insert(choices,{
                        label="Put it in the outdoor oodie",
                        fn=function()
                            async.waterfall({
                                function(next) msg("...Nothing happened!",next) end,
                                function(next) msg("...That didn't really make any sense now that I think about it.",next) end,
                            })
                        end
                    })
                end
                if Inventory:hasItem("Tile") then
                    table.insert(choices,{
                        label="Put it in the tile",
                        fn=function()
                            composer.setVariable("tileHasBattery",true)
                            async.waterfall({
                                function(next) msg("Looks like this battery fits the tile perfectly!",next) end,
                                function(next) Inventory:removeItem(battery,next) end,
                            })
                        end
                    })
                end
                options(choices)
            end,
        })
        return true
    end
    return false
end