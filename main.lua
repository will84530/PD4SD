
local RightSheet = display.newGroup()
local MiddleSheet = display.newGroup()
local xCenter, yCenter = display.contentCenterX, display.contentCenterY
local wScreen, hScreen = display.actualContentWidth, display.actualContentHeight
local emitterParams = {
	startColorAlpha = 1,
    startParticleSizeVariance = 53.47,
    startColorGreen = 0.3031555,
    yCoordFlipped = -1,
    blendFuncSource = 770,
    rotatePerSecondVariance = 153.95,
    particleLifespan = 0.7237,
    tangentialAcceleration = -144.74,
    finishColorBlue = 0.3699196,
    finishColorGreen = 0.5443883,
    blendFuncDestination = 1,
    startParticleSize = 50.95,
    startColorRed = 0.8373094,
    textureFileName = "Texture/sample.png",
    startColorVarianceAlpha = 1,
    maxParticles = 256,
    finishParticleSize = 64,
    duration = -1,
    finishColorRed = 1,
    maxRadiusVariance = 72.63,
    finishParticleSizeVariance = 64,
    gravityy = -671.05,
    speedVariance = 90.79,
    tangentialAccelVariance = -92.11,
    angleVariance = -142.62,
    angle = -244.11
}
local emitter = display.newEmitter( emitterParams )

function makeSheet(params)
	local sheet = display.newGroup()
	sheet.background = display.newRect( sheet, 0, 0, params.width, params.height )
	sheet.background:setFillColor(params.color[1], params.color[2], params.color[3])
	sheet.x, sheet.y = params.x, params.y
	return sheet
end

local leftSheet = makeSheet{
	width = wScreen * 0.25,
	height = hScreen,
	x = wScreen - wScreen * 0.25 / 2,
	y = yCenter,
	color = {0.3, 0.3, 0.5}
}

local rightSheet = makeSheet{
	width = wScreen * 0.25,
	height = hScreen,
	x = wScreen * 0.25 / 2,
	y = yCenter,
	color = {0.5, 0.1, 0.1}
}

local middleSheet = makeSheet{
	width = wScreen - (leftSheet.background.width + rightSheet.background.width),
	height = hScreen,
	x = xCenter,
	y = yCenter,
	color = {0.2, 0.2, 0.2}
}

middleSheet:insert(emitter)


