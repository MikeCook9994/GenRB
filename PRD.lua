PRD = {
    width = 320,
    height = 25,
    x = 1,
    y = -225,
    container = nil,
    currentSpecKey = nil,
    selectedConfig = nil,
    debugEnabled = true,
    frameUpdates = {},
    configurations = {},
    bars = {},
}

PRD.positionAndSizeConfig = {
    primary = {
        anchorPoint = "LEFT",
        tickWidth = 3,
        height = PRD.height,
        width = PRD.width,
        yOffset = 0,
        inverseFill = false
    },
    top = {
        anchorPoint = "TOP",
        tickWidth = 2,
        height = PRD.height / 4,
        yOffset = PRD.height / 4,
        width = PRD.width,
        inverseFill = false
    },
    top_left = {
        anchorPoint = "TOPLEFT",
        tickWidth = 2,
        height = PRD.height / 4,
        width = PRD.width / 2,
        yOffset = PRD.height / 4,
        inverseFill = true
    },
    top_right = {
        anchorPoint = "TOPRIGHT",
        tickWidth = 2,
        height = PRD.height / 4,
        width = PRD.width / 2,
        yOffset = PRD.height / 4,
        inverseFill = false
    },
    bottom = {
        tickWidth = 2,
        anchorPoint = "BOTTOM",
        height = PRD.height / 4,
        width = PRD.width,
        yOffset = (-1 * (PRD.height / 4)),
        inverseFill = false
    },
    bottom_left = {
        tickWidth = 2,
        anchorPoint = "BOTTOMLEFT",
        height = PRD.height / 4,
        width = PRD.width / 2,
        yOffset = (-1 * (PRD.height / 4)),
        inverseFill = true
    },
    bottom_right = {
        tickWidth = 2,
        anchorPoint = "BOTTOMRIGHT",
        height = PRD.height / 4,
        width = PRD.width / 2,
        yOffset = (-1 * (PRD.height / 4)),
        inverseFill = false
    }
}