local Widget = require( "widget" )

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
local emitter = display.newEmitter(emitterParams)

local leftSheet, rightSheet, middleSheet

local function makeSheet(params)
	local sheet = display.newGroup()
	sheet.background = display.newRect( sheet, 0, 0, params.width, params.height )
	sheet.background:setFillColor(params.color[1], params.color[2], params.color[3])
	sheet.x, sheet.y = params.x, params.y
	return sheet
end

local function makeSlider(params)
	local group = display.newGroup()
	group.max = params.max or 100
	group.min = params.min or 0
	group.slider = Widget.newSlider{
		x = -20,
		width = wScreen * 0.15,
		value = emitterParams[params.name] / (group.max - group.min) * 100 or 0,
		listener = function(event)
			realValue = (event.value * (group.max - group.min) / 100) + group.min
			updateEmitter{
				name = params.name,
				value = realValue
			}
			group.field.text = tostring(realValue)
		end,
		top = -10
	}
	group:insert(group.slider)
	group.text = display.newText(group, params.name, 0, -20, native.systemFont, 18)
	group.field = native.newTextField( group.slider.width / 2 + 20,  group.slider.height / 4, 40, 20 )
	group.field.inputType = "number"
	group.field.size = 10
	group.field.text = tostring(emitterParams[params.name])
	-- group.field.
	group:insert(group.field)
	return group
end

function updateEmitter(params)
	emitter:stop()
	emitter[params.name] = 0
	if emitterParams[params.name] then
		emitterParams[params.name] = params.value
		emitter = display.newEmitter(emitterParams)
		middleSheet:insert(emitter)
	end
	emitter:start()
end

local function init()
	leftSheet = makeSheet{
		width = wScreen * 0.25,
		height = hScreen,
		x = wScreen - wScreen * 0.25 / 2,
		y = yCenter,
		color = {0.3, 0.3, 0.5}
	}

	rightSheet = makeSheet{
		width = wScreen * 0.25,
		height = hScreen,
		x = wScreen * 0.25 / 2,
		y = yCenter,
		color = {0.4, 0.1, 0.1}
	}

	middleSheet = makeSheet{
		width = wScreen - (leftSheet.background.width + rightSheet.background.width),
		height = hScreen,
		x = xCenter,
		y = yCenter,
		color = {0.2, 0.2, 0.2}
	}

	middleSheet:insert(emitter)

	local slider = makeSlider{
		name = 'maxParticles',
		max = 500,
		min = 1
	}
	leftSheet:insert(slider)
end

init()
