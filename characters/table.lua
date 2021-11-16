return {
    spritesheet="art/maurytable.png",
    sheetOptions = {
        width = 55,
        height = 55,
        --sheetContentWidth = 170,
        --sheetContentHeight = 80,
        numFrames = 2
    },
    sequences = {
        -- standing
        {
            name = "stand",
            start = 1,
            count = 1,
            time = 800,
            loopCount = 0,
            loopDirection = "forward"
        },
        {
            name = "stand2",
            start = 2,
            count = 1,
            time = 800,
            loopCount = 0,
            loopDirection = "forward"
        },
        -- walking
        {
            name = "walk",
            start = 1,
            count = 1,
            time = 800,
            loopCount = 0,
            loopDirection = "forward"
        }
    },
    collision = {
        width = 55,
        height = 55,
        anchorY = 0.9
    }
}