return {
    spritesheet="art/car.png",
    sheetOptions = {
        width = 170,
        height = 80,
        sheetContentWidth = 170,
        sheetContentHeight = 80,
        numFrames = 1
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
        width = 165,
        height = 32,
        anchorY = 0.9
    }
}