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

local emitterParams = {}
local emitter

local rightSheet, rightSheet, middleSheet
local page
local fileManager = {}
local saveContent = {}
local infoText = {}
local loopBtn = {}
local playBtn = {}
local refreshBtn = {}
local loopTimer

function loopPlay(event)
    print( "123123" )
    loopTimer = timer.performWithDelay( 1000, loopPlay )
end

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
	if emitter then emitter:stop() end
	if params then
		print(params.name, params.value)
		emitterParams[params.name] = params.value		
	end
	display.remove(emitter)
	emitter = display.newEmitter(emitterParams)
	middleSheet:insert(emitter)
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
		emitterParams.textureFileName = "Assets/" .. name
		updateEmitter()
		infoText.text = "Read the texture file successfully."
	elseif extension == "json" then
		local path = system.pathForFile( "Assets/" .. name)
		local file, errorString = io.open( path, "r" )		 
		if not file then
		    infoText.text = "Read the setting file failed. Error: " .. errorString
		else
			local contents = file:read( "*a" )
			local t = Json.decode( contents )

			emitterParams = {}
			for k, v in pairs(t) do
				if k == "textureFileName" then
					emitterParams[k] = "Assets/" .. v
				else 
					emitterParams[k] = v
				end
			end
			updateEmitter()
			showPage("Emitter")
			io.close( file )
		end		 
		file = nil
		infoText.text = "Read the setting file successfully."
	end
end

function saveData()
	if not saveContent.field.text then
		infoText.text = "Save file failed. The file name is empty."
	else
	    local path = system.pathForFile( saveContent.field.text .. ".json", system.DocumentsDirectory)
	    local file, errorString = io.open( path, "w" )	 
	    if not file then
	        infoText.text = "Save file failed. Error: " .. errorString
	    else
	    	local name = emitterParams.textureFileName
	    	local dirPos = name:find("/")
	    	emitterParams.textureFileName = name:sub(dirPos + 1)
	        file:write(Json.prettify(emitterParams))
	        io.close(file)
			file = nil
	    	os.execute("explorer " .. system.pathForFile("", system.DocumentsDirectory))
	        infoText.text = "Save file successfully."
	    end
	end
	
end


function refreshFileManager()
	fileManager = {}
	local path = system.pathForFile("Assets", system.ResourceDirectory)
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
	fileManager.png = makeFileManager(pngList, {x = 80, y = -150}, "png")
	fileManager.json = makeFileManager(jsonList, {x = -80, y = -150}, "json")
end

function makeSaveContent()
	local group = display.newGroup()

	group.field = native.newTextField( -10, 0 , 120, 30 )
	group.field.size = 14
	group.field.text = "new_particle"
	group:insert(group.field)

	group.text =  display.newText(group, "File name:", -110, 0, native.systemFont, 16)

	group.button = Widget.newButton{
		x = 110,
		y = 0,
        label = "Save",
		onEvent = function(event)
			if event.phase == "ended" then
				saveData()
			end
		end,
		shape = "roundedRect",
		width = 80,
        height = 30,        
        fillColor = {default = {1,1,1}, over = {0.5, 0.5, 0.5}},
	}
	group:insert(group.button)

	return group
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
	loadData("sample.json", "json")
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

	saveContent = makeSaveContent()
	saveContent.y = 320
	leftSheet:insert(saveContent)

	infoText = display.newText(middleSheet, "Particles Designer for Win10 Version 0.1.0", 0, 340, native.systemFont, 16)

	loopBtn = Widget.newButton{
		x = -60,
		y = -320,
        label = "Loop",
		onEvent = function(event)
			if event.phase == "ended" then
				loopBtn:setFillColor(1, 1, 1)
				playBtn:setFillColor(1, 1, 1)
				timer.cancel(loopTimer)
				infoText.text = "Turn off the Loop mode."
			end
		end,
		shape = "roundedRect",
		width = 100,
        height = 30,        
        fillColor = {default = {1, 1, 0.5}, over = {0.5, 0.5, 0.5}},
	}
	leftSheet:insert(loopBtn)

	playBtn = Widget.newButton{
		x = 60,
		y = -320,
        label = "Play",
		onEvent = function(event)
			if event.phase == "ended" then
				
			end
		end,
		shape = "roundedRect",
		width = 100,
        height = 30,        
        fillColor = {default = {0.5, 0.5, 0.5}, over = {0.5, 0.5, 0.5}},
	}
	leftSheet:insert(playBtn)

	refreshBtn = Widget.newButton{
		x = 0,
		y = -20,
        label = "Refresh files",
		onEvent = function(event)
			if event.phase == "ended" then
				refreshFileManager()
			end
		end,
		shape = "roundedRect",
		width = 150,
        height = 30,        
        fillColor = {default = {1,1,1}, over = {0.5, 0.5, 0.5}},
	}
	leftSheet:insert(refreshBtn)

	loopTimer = timer.performWithDelay( 1000, loopPlay )
end

init()
