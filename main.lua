local leftSheet = display.newGroup()
local RightSheet = display.newGroup()
local xCenter, yCenter = display.contentCenterX, display.contentCenterY
local wScreen, hScreen = display.actualContentWidth, display.actualContentHeight

leftSheet.background = display.newRect( leftSheet, 0, 0, wScreen * 0.3, hScreen )
leftSheet.background
leftSheet.x, leftSheet.y = wScreen - leftSheet.background.width / 2, yCenter
