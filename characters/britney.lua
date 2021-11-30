return {
    spritesheet="art/britney-character-spritesheet.png",
    sheetOptions = {
        width = 274,
        height = 219,
        numFrames = 21
    },
    sequences = {
        -- standing
        {
            name = "stand",
            start = 1,
            count = 7,
            time = 800,
            loopCount = 0,
            loopDirection = "forward"
        },
        -- walking
        {
            name = "walk",
            start = 8,
            count = 7,
            time = 800,
            loopCount = 0,
            loopDirection = "forward"
        }
    },
    collision = {
        width = 80,
        height = 182,
        anchorY = 0.9
    }
}