if(not owner)then
	getfenv(1).owner = script.Parent:IsA("PlayerGui") and script.Parent.Parent or game:GetService('Players'):GetPlayerFromCharacter(script.Parent)
end
wait()
script.Parent = owner.Character
local genv={}
Decode =  function(str,t,props,classes,values,ICList,Model,CurPar,LastIns,split,RemoveAndSplit,InstanceList)
	local tonum,table_remove,inst,parnt,comma,table_foreach = tonumber,table.remove,Instance.new,"Parent",",",
	function(t,f)
		for a,b in pairs(t) do
			f(a,b)
		end
	end
	local Types = {
		Color3 = Color3.new,
		Vector3 = Vector3.new,
		Vector2 = Vector2.new,
		UDim = UDim.new,
		UDim2 = UDim2.new,
		CFrame = CFrame.new,
		Rect = Rect.new,
		NumberRange = NumberRange.new,
		BrickColor = BrickColor.new,
		PhysicalProperties = PhysicalProperties.new,
		NumberSequence = function(...)
			local a = {...}
			local t = {}
			repeat
				t[#t+1] = NumberSequenceKeypoint.new(table_remove(a,1),table_remove(a,1),table_remove(a,1))
			until #a==0
			return NumberSequence.new(t)
		end,
		ColorSequence = function(...)
			local a = {...}
			local t = {}
			repeat
				t[#t+1] = ColorSequenceKeypoint.new(table_remove(a,1),Color3.new(table_remove(a,1),table_remove(a,1),table_remove(a,1)))
			until #a==0
			return ColorSequence.new(t)
		end,
		number = tonumber,
		boolean = function(a)
			return a=="1"
		end
	}
	split = function(str,sep)
		if not str then return end
		local fields = {}
		local ConcatNext = false
		str:gsub(("([^%s]+)"):format(sep),function(c)
			if ConcatNext == true then
				fields[#fields] = fields[#fields]..sep..c
				ConcatNext = false
			else
				fields[#fields+1] = c
			end
			if c:sub(#c)=="\\" then
				c = fields[#fields]
				fields[#fields] = c:sub(1,#c-1)
				ConcatNext = true
			end
		end)
		return fields
	end
	RemoveAndSplit = function(t)
		return split(table_remove(t,1),comma)
	end
	t = split(str,";")
	props = RemoveAndSplit(t)
	classes = RemoveAndSplit(t)
	values = split(table_remove(t,1),'|')
	ICList = RemoveAndSplit(t)
	InstanceList = {}
	Model = inst"Model"
	CurPar = Model
	table_foreach(t,function(ct,c)
		if c=="n" or c=="p" then
			CurPar = c=="n" and LastIns or CurPar[parnt]
		else
			ct = split(c,"|")
			local class = classes[tonum(table_remove(ct,1))]
			if class=="UnionOperation" then
				LastIns = {UsePartColor="1"}
			else
				LastIns = inst(class)
				if LastIns:IsA"Script" then
					s(LastIns)
				elseif LastIns:IsA("ModuleScript") then
					ms(LastIns)
				end
			end

			local function SetProperty(LastIns,p,str,s)
				s = Types[typeof(LastIns[p])]
				if p=="CustomPhysicalProperties" then
					s = PhysicalProperties.new
				end
				if s then
					LastIns[p] = s(unpack(split(str,comma)))
				else
					LastIns[p] = str
				end
			end

			local UnionData
			table_foreach(ct,function(s,p,a,str)
				a = p:find":"
				p,str = props[tonum(p:sub(1,a-1))],values[tonum(p:sub(a+1))]
				if p=="UnionData" then
					UnionData = split(str," ")
					return
				end
				if class=="UnionOperation" then
					LastIns[p] = str
					return
				end
				SetProperty(LastIns,p,str)
			end)

			if UnionData then
				local LI_Data = LastIns
				LastIns = DecodeUnion(UnionData)
				table_foreach(LI_Data,function(p,str)
					SetProperty(LastIns,p,str)
				end)
			end
			table.insert(InstanceList,LastIns)
			LastIns[parnt] = CurPar
		end
	end)
	table_remove(ICList,1)
	table_foreach(ICList,function(a,b)
		b = split(b,">")
		InstanceList[tonum(b[1])][props[tonum(b[2])]] = InstanceList[tonum(b[3])]
	end)

	return Model:GetChildren()
end

local Objects = Decode('Name,ZIndexBehavior,ResetOnSpawn,Position,Size,AnchorPoint,BackgroundColor3,BorderColor3,Font,Text,TextColor3,TextScaled,TextSize,TextWrapped;Part,ScreenGui,Frame,TextBox,TextButton;Part|UI|1|0|0.9319'
	..',0,0.8817,0|0.1029,0,0.2075,0|0.5,0.5|0.2078,0.2078,0.2078|Url|0.4936,0,0.1491,0|0.7782,0,0.1723,0|1,1,1|3| |0,0,0|1|14|Threshold|0.4936,0,0.3771,0|Generate|0.4971,0,0.8653,0|0.6148,0,0.1854,0|Scale|0'
	..'.4936,0,0.6015,0;0;2|1:2|2:3|3:4;n;3|4:5|5:6|6:7|7:8;n;4|1:9|4:10|5:11|6:7|7:8|8:12|9:13|10:14|11:15|12:16|13:17|14:16;4|1:18|4:19|5:11|6:7|7:8|8:12|9:13|10:14|11:15|12:16|13:17|14:16;5|1:20|4:21|5:22'
	..'|6:7|7:8|8:12|9:13|10:20|11:12|12:16|13:17|14:16;4|1:23|4:24|5:11|6:7|7:8|8:12|9:13|10:14|11:15|12:16|13:17|14:16;p;p;')
local UI = Objects[1]
if(owner.PlayerGui:FindFirstChild("ImageGenUniverseInterface"))then
	owner.PlayerGui:FindFirstChild("ImageGenUniverseInterface"):Destroy()
end
UI.Name = "ImageGenUniverseInterface"
UI.Frame.BorderColor3 = Color3.new(1,1,1)
local urltb = UI.Frame.Url
urltb.PlaceholderText = "Url"
urltb.PlaceholderColor3 = Color3.new(1,1,1)
urltb.TextColor3 = Color3.new(1,1,1)
urltb.Text = "Url"
local threshtb = UI.Frame.Threshold
threshtb.PlaceholderText = "Threshold"
threshtb.PlaceholderColor3 = Color3.new(1,1,1)
threshtb.TextColor3 = Color3.new(1,1,1)
threshtb.Text = "Threshold"
local scaletb = UI.Frame.Scale
scaletb.PlaceholderText = "Scale"
scaletb.PlaceholderColor3 = Color3.new(1,1,1)
scaletb.TextColor3 = Color3.new(1,1,1)
scaletb.Text = "Scale"
local generatebutton = UI.Frame.Generate
UI.Parent = owner.PlayerGui

local api_link = "https://atom24.xyz/a/b/c/"

function ball(url, threshold, scale)
	print("loading image", url)
	local data = game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):GetAsync(api_link.."?a=" .. url .. "&b=" .. (threshold or 0.05)))
	print(threshold)
	local scale = scale or 0.1
	local tpos = owner.Character.Torso.Position
	scale = (scale / 2) / 0.08
	local cuboids = data
	local ExamplePart = Instance.new("Part")
	local SurfaceGui = Instance.new("SurfaceGui", ExamplePart)
	local TextLabel = Instance.new("TextBox", SurfaceGui)
	SurfaceGui.Adornee = ExamplePart
	SurfaceGui.Face = "Top"
	TextLabel.Size = UDim2.new(0.5, 0, 0.75, 0)
	TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	TextLabel.Position = UDim2.new(0.5,0,0.5,0)
	TextLabel.BackgroundTransparency = 1
	TextLabel.TextStrokeTransparency = 0
	TextLabel.Font = Enum.Font.Gotham
	TextLabel.TextEditable = false
	TextLabel.Rotation = 90
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.TextScaled = true
	ExamplePart.Anchored = true
	ExamplePart.Size = Vector3.new(data.width * scale, scale + 0.05, data.height * scale) * 0.08
	ExamplePart.Color = Color3.fromHex("000000")
	ExamplePart.Position = tpos + Vector3.new(
		(data.width / 2) * scale, 0, (data.height / 2) * scale
	) * scale
	ExamplePart.CanCollide = false
	ExamplePart.Transparency = 0.5
	ExamplePart.Parent = script
	local Part = Instance.new("SpawnLocation", script)
	Part.CanCollide = false
	Part.CastShadow = false
	Part.CanQuery = false
	Part.CanTouch = false
	Part.Anchored = true
	Part.Enabled = false
	Part.Size = Vector3.new(0.1,0.1,0.1)
	Part.TopSurface = "Smooth"
	local env = getfenv()
	local lp = -1
	print("compressed:", data.width * data.height, "pixels to", data.cuboids, "pixels")
	local cuboids = data.data
	for i,v in pairs(data.data) do
		if i % 15 == 0 then
			task.wait()
			TextLabel.Text = tostring(math.floor((i / data.cuboids) * 100)) .. "%"
		end
		local x = (cuboids[i]["startX"] + cuboids[i]["endX"])/50 --((cuboids[i]["startX"]*2) + (cuboids[i]["endX"]*2)) / 2
		local sizex = ((cuboids[i]["endX"]-cuboids[i]["startX"])*0.08)+0.08
		local z = (cuboids[i]["startZ"] + cuboids[i]["endZ"])/50 --((cuboids[i]["startX"]*2) + (cuboids[i]["endX"]*2)) / 2
		local sizez = ((cuboids[i]["endZ"]-cuboids[i]["startZ"])*0.08)+0.08
		local c = Part:Clone()
		if i == 1 then
			ExamplePart.Position = tpos - Vector3.new(-ExamplePart.Size.X / 2, 0, -ExamplePart.Size.Z / 2)
		end
		c.Parent = script
		c.Position = tpos + Vector3.new(x*2,0,z*2) * scale
		c.Size = Vector3.new(sizex,0.08,sizez) * scale
		c.Color = Color3.new(
			cuboids[i]["color"].R,
			cuboids[i]["color"].G,
			cuboids[i]["color"].B
		)
	end
	ExamplePart:Destroy()
end

if(game:GetService('ReplicatedStorage'):FindFirstChild("imagegen"..owner.Name))then
	game:GetService('ReplicatedStorage'):FindFirstChild("imagegen"..owner.Name):Destroy()
end
local remote = Instance.new("RemoteEvent",game:GetService("ReplicatedStorage"))
remote.Name = "imagegen"..owner.Name
remote.OnServerEvent:Connect(function(player,tbl)
	if(player ~= owner)then
		return
	end
	if(not tbl)then
		return
	end
	ball(tbl.url, tbl.thresh, tbl.scale or 0.05)
end)
local ls = NLS([[
	print(script.Parent)
	local UI = script.Parent:WaitForChild("ImageGenUniverseInterface")
	local urltb = UI.Frame.Url
	urltb.PlaceholderText = "Url"
	urltb.PlaceholderColor3 = Color3.new(1,1,1)
	urltb.TextColor3 = Color3.new(1,1,1)
	urltb.Text = "Url"
	local threshtb = UI.Frame.Threshold
	threshtb.PlaceholderText = "Threshold"
	threshtb.PlaceholderColor3 = Color3.new(1,1,1)
	threshtb.TextColor3 = Color3.new(1,1,1)
	threshtb.Text = "Threshold"
	local scaletb = UI.Frame.Scale
	scaletb.PlaceholderText = "Scale"
	scaletb.PlaceholderColor3 = Color3.new(1,1,1)
	scaletb.TextColor3 = Color3.new(1,1,1)
	scaletb.Text = "Scale"
	local generatebutton = UI.Frame.Generate
	local rem = game:GetService("ReplicatedStorage"):FindFirstChild("imagegen"..owner.Name)
	generatebutton.MouseButton1Click:Connect(function()
		rem:FireServer({url = urltb.Text, thresh = tonumber(threshtb.Text or 0.05), scale = tonumber(scaletb.Text)})
	end)
]],owner.PlayerGui)