local Widget = require("widget")
local Lfs = require("lfs")
local Json = require( "json" )

local xCenter, yCenter = display.contentCenterX, display.contentCenterY
local wScreen, hScreen = display.actualContentWidth, display.actualContentHeight
local list = {
	Emitter = {
		maxParticles = {max = 500, min = 1},
		angle = {max = 360, min = -360},
		angleVariance = {max = 360, min = -360},
		emitterType = {max = 1},
		absolutePosition = {},
		duration = {max = 100, min = -1},
	},
	Shape = {
		speed = {max = 1000, min = -1000},
		speedVariance = {max = 1000, min = -1000},
		sourcePositionVariancex = {max = 1000, min = -1000},
		sourcePositionVariancey = {max = 1000, min = -1000},
		gravityx = {max = 1000, min = -1000},
		gravityy = {max = 1000, min = -1000},
		radialAcceleration = {max = 1000, min = -1000},
		radialAccelVariance = {max = 1000, min = -1000},
		tangentialAcceleration = {max = 1000, min = -1000},
		tangentialAccelVariance = {max = 1000, min = -1000},
	},
	Radial = {
		maxRadius = {max = 1000, min = -1000},
		maxRadiusVariance = {max = 1000, min = -1000},
		minRadius = {max = 1000, min = -1000},
		minRadiusVariance = {max = 1000, min = -1000},
		rotatePerSecond = {max = 1000, min = -1000},
		rotatePerSecondVariance = {max = 1000, min = -1000},
	},
	Particles = {
		particleLifespan = {max = 1000, min = -1000},
		particleLifespanVariance = {max = 1000, min = -1000},
		startParticleSize = {max = 1000},
		startParticleSizeVariance = {max = 1000, min = -1000},
		finishParticleSize = {max = 1000, min = -1000},
		finishParticleSizeVariance = {max = 1000, min = -1000},
		rotationStart = {max = 1000, min = -1000},
		rotationStartVariance = {max = 1000, min = -1000},
		rotationEnd = {max = 1000, min = -1000},
		rotationEndVariance = {max = 1000, min = -1000},
		-- blendFuncSource = {max = 1000, min = -1000},
		-- blendFuncDestination = {max = 1000, min = -1000},
	},
	Color = {
		startColorRed = {max = 1},
		startColorGreen = {max = 1},
		startColorBlue = {max = 1},
		startColorAlpha = {max = 1},
		startColorVarianceRed = {max = 1},
		startColorVarianceGreen = {max = 1},
		startColorVarianceBlue = {max = 1},
		startColorVarianceAlpha = {max = 1},
		finishColorRed = {max = 1},
		finishColorGreen = {max = 1},
		finishColorBlue = {max = 1},
		finishColorAlpha = {max = 1},
		finishColorVarianceRed = {max = 1},
		finishColorVarianceGreen = {max = 1},
		finishColorVarianceBlue = {max = 1},
		finishColorVarianceAlpha = {max = 1}
	}

}

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

local rightSheet, rightSheet, middleSheet
local page
local fileManager = {}

function makeSheet(params)
	local sheet = display.newGroup()
	sheet.background = display.newRect( sheet, 0, 0, params.width, params.height )
	sheet.background:setFillColor(params.color[1], params.color[2], params.color[3])
	sheet.x, sheet.y = params.x, params.y
	return sheet
end

function makeSlider(params)
	local group = display.newGroup()
	group.max = params.max or 100
	group.min = params.min or 0
	group.slider = Widget.newSlider{
		x = -20,
		y = params.y or 0,
		width = wScreen * 0.15,
		value = ((emitterParams[params.name] or 0) - group.min) / (group.max - group.min) * 100 or 0,
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
	group.text = display.newText(group, params.name, 0, (params.y or 0) -20, native.systemFont, 16)
	group.field = native.newTextField( wScreen * 0.08 + 20,  (params.y or 0) , 40, 20 )
	group.field.inputType = "number"
	group.field.size = 10
	group.field.text = tostring(emitterParams[params.name] or 0)
	group.field:addEventListener("userInput", function(event)
		if event.phase == "ended" or event.phase == "submitted" then
			realValue = tonumber(group.field.text)
			updateEmitter{
				name = params.name,
				value = realValue
			}
			group.slider:setValue((realValue - group.min) / (group.max - group.min) * 100 or 0)
		end
	end)
	group:insert(group.field)
	return group
end

function updateEmitter(params)
	emitter:stop()
	if emitterParams[params.name] then
		emitterParams[params.name] = params.value
		display.remove(emitter)
		emitter = display.newEmitter(emitterParams)
		middleSheet:insert(emitter)
	end
	emitter:start()
end

function showPage(name)
	display.remove(page)
	page = display.newGroup()
	local vCount = 1
	for k, v in pairs(list[name]) do
		local slider = makeSlider{
			name = k,
			max = v.max or 100,
			min = v.min or 0,
			y = -280 + (vCount - 1) * 40
		}			
		page:insert(slider)
		vCount = vCount + 1
	end
	rightSheet:insert(page)
end

function makeFileManager(files, params, extension)
	local group = display.newGroup()

	local picker = Widget.newPickerWheel{
		x = params.x,
		y = params.y,
		fontSize = 16,
		columns = {
			{
		        align = "left",
		        width = 126,
		        startIndex = 1,
		        labels = files
		    },
		},
		style = "resizable",
		width = 127,
	    rowHeight = 20,
	}
	group:insert(picker)

	local button = Widget.newButton{
		x = params.x,
		y = params.y + 70,
        label = "Chose",
		onEvent = function(event)
			if event.phase == "ended" then
				loadData(picker:getValues()[1].value, extension)
			end
		end,
		shape = "roundedRect",
		width = 100,
        height = 30,        
        fillColor = {default = {1,1,1}, over = {0.5, 0.5, 0.5}},
	}
	group:insert(button)
 	print(extension)
	local text = display.newText(group, extension == "png" and "Texture:" or "Script:", params.x, params.y - 70, native.systemFont, 16)

	leftSheet:insert(group)

	return group
end


function loadData(name, extension)
	print(name, extension)
	if extension == "png" then

	elseif extension == "json" then
		local path = system.pathForFile( "Texture/" .. name, system.ResourceDirectory )
		local file, errorString = io.open( path, "r" )		 
		if not file then
		    print( "File error: " .. errorString )
		else
			local contents = file:read( "*a" )
			local t = Json.decode( contents )
			for k, v in pairs(t) do
				print(k, v)
			end
			io.close( file )
		    -- for line in file:lines() do
		    --     print( line )		        
		    -- end
		    -- io.close( file )

		end		 
		file = nil
	end
end

function refreshFileManager()
	local path = system.pathForFile("Texture", system.ResourceDirectory)
 	local pngList = {}
 	local jsonList = {}

 	local function getExtension(str)
 		local dotPos = str:find( "%.")
 		return str:sub(dotPos + 1)
 	end

	for file in Lfs.dir(path) do
		if getExtension(file) == "png" then
			pngList[#pngList + 1] = file
		elseif getExtension(file) == "json" then
			jsonList[#jsonList + 1] = file
		end
	end
	fileManager.png = makeFileManager(pngList, {x = -80, y = 200}, "png")
	fileManager.json = makeFileManager(jsonList, {x = 80, y = 200}, "json")
end








 
function init()
	rightSheet = makeSheet{
		width = wScreen * 0.25,
		height = hScreen,
		x = wScreen - wScreen * 0.25 / 2,
		y = yCenter,
		color = {0.3, 0.3, 0.5}
	}

	leftSheet = makeSheet{
		width = wScreen * 0.25,
		height = hScreen,
		x = wScreen * 0.25 / 2,
		y = yCenter,
		color = {0.4, 0.1, 0.1}
	}

	middleSheet = makeSheet{
		width = wScreen - (rightSheet.background.width + rightSheet.background.width),
		height = hScreen,
		x = xCenter,
		y = yCenter,
		color = {0.2, 0.2, 0.2}
	}

	middleSheet:insert(emitter)

	local pageManager = Widget.newSegmentedControl{
		x = 0,
		y = -350,
		segmentWidth = wScreen * 0.05,
		segments = {"Emitter", "Shape", "Radial", "Particles", "Color"},
		defaultSegment = 1,
		onPress = function(event)
			showPage(event.target.segmentLabel)
		end
	}
	rightSheet:insert(pageManager)
	showPage("Emitter")
	
	refreshFileManager()
end

init()
