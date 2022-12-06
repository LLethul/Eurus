local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local function GetNewUIInstance()
    local a=Instance.new("ScreenGui")local b=Instance.new("Frame")local c=Instance.new("Frame")local d=Instance.new("TextBox")local e=Instance.new("Frame")
    local f=Instance.new("UIGradient")local g=Instance.new("Frame")local h=Instance.new("TextLabel")local i=Instance.new("UICorner")a.Name="EurusBar"
    a.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;b.Name="Mainframe"b.Parent=a;b.BackgroundColor3=Color3.fromRGB(30,30,30)b.BackgroundTransparency=1.000;b
    .BorderColor3=Color3.fromRGB(255,255,255)b.BorderSizePixel=0;b.Size=UDim2.new(1,0,1,0)c.Name="Commandbar"c.Parent=b;c.AnchorPoint=Vector2.new(0.5,0.5)c
    .BackgroundColor3=Color3.fromRGB(30,30,30)c.BackgroundTransparency=1.000;c.BorderColor3=Color3.fromRGB(255,255,255)c.BorderSizePixel=0;c
    .Position=UDim2.new(0.5,0,1.2,0)c.Size=UDim2.new(0,700,0,35)d.Name="Input"d.Parent=c;d.BackgroundColor3=Color3.fromRGB(30,30,30)d
    .BorderColor3=Color3.fromRGB(255,255,255)d.BorderSizePixel=0;d.Position=UDim2.new(-4.35965397e-08,0,-0.0571428575,0)d.Size=UDim2.new(1.00042856,0,1.00000048,0)
    d.ClearTextOnFocus=false;d.Font=Enum.Font.Code;d.PlaceholderColor3=Color3.fromRGB(255,255,255)d.PlaceholderText="Insert command.."d.Text=""d.TextColor3=Color3.fromRGB(255,255,255)d.TextSize=22.000;
    d.TextStrokeColor3=Color3.fromRGB(255,255,255)d.TextWrapped=true;d.TextXAlignment=Enum.TextXAlignment.Left;e.Name="UnderlineColor"e.Parent=c;e
    .BackgroundColor3=Color3.fromRGB(255,255,255)e.BorderColor3=Color3.fromRGB(255,255,255)e.BorderSizePixel=0;e.Position=UDim2.new(0,0,0.942857146,0)e
    .Size=UDim2.new(1,0,0.0571428575,3)d.ClearTextOnFocus=false;f.Color=ColorSequence.new{ColorSequenceKeypoint.new(0.00,Color3.fromRGB(9,0,104)),ColorSequenceKeypoint.new(
    0.49,Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(1.00,Color3.fromRGB(8,0,255))}f.Name="Rainbowify"f.Parent=e;g.Name="SmartPredict"g
    .Parent=c;g.BackgroundColor3=Color3.fromRGB(0,0,0)g.BackgroundTransparency=0.500;g.BorderSizePixel=0;g
    .Position=UDim2.new(-4.35965397e-08,0,-0.714285731,0)g.Size=UDim2.new(0,700,0,31)g.Visible=false;g.ZIndex=0;h.Name="CmdName"h.Parent=g;h
    .BackgroundColor3=Color3.fromRGB(255,255,255)h.BackgroundTransparency=1.000;h.Size=UDim2.new(0,392,0,25)h.Font=Enum.Font.SourceSans;h
    .Text=" test"h.TextColor3=Color3.fromRGB(255,255,255)h.TextScaled=true;h.TextSize=14.000;h.TextWrapped=true;h.TextXAlignment=Enum.TextXAlignment.Left;h
    .TextYAlignment=Enum.TextYAlignment.Bottom;i.Parent=g;return a;
end

local Player = Players.LocalPlayer

local UI = GetNewUIInstance()
local MF: Frame = UI.Mainframe;
local CB: Frame = MF.Commandbar;
UI.Parent = Player.PlayerGui;

local UIState = {
    Open = false;
}

local UIFuncs = {
    Open = function()
        CB:TweenPosition(UDim2.new(0.5,0,1.2,0),nil,nil, 0.5, true, function()
            UIState.Open = true;
        end)
    end;

    Close = function()
        CB:TweenPosition(UDim2.new(0.5,0,0.9,0),nil,nil, 0.5, true, function()
            UIState.Open = false;
        end)
    end;
}

local BaseFuncs = {
    FindPlayer = function(Text)
        for _, Player in pairs(Players:GetPlayers()) do
            if (Player.Name:lower():find(Text:lower()) or Player.DisplayName:lower():find(Text:lower())) then
                return Player
            end
        end
    end;

    StartsWith = function(str,pref)
        return string.sub(str,1,string.len(pref))==pref
    end
}

local State = {
    Admins = {
        [Player.UserId] = {
            Rank = 10;
            BlockedCommands = {}
        }
    };
    Prefix = ";";

    ReadProfs = {};

    CommandInstances = {}
}

local function ParseMessage(sender, msg)
    if BaseFuncs.StartsWith(msg, State.Prefix) then
        local Args = msg:split(" ")
        local Cmd = Args[1]:gsub(State.Prefix, ""):lower()
        table.remove(Args,1)

        --// Try and find command instance
        if State.CommandInstances[Cmd] then
            --// Success! Command instance found. Woohoo!
            local cmdInstance = State.CommandInstances[Cmd]
            
            --// Now, go through args, and see if they match required types.
            local builtArgs = {}
            for argIter, argRaw in pairs(Args) do
                local reqType = cmdInstance.argTypeList[argIter]

                if reqType:lower() == "player" then
                    if argRaw:lower() == "me" then
                        builtArgs[argIter] = {sender}
                        continue;
                    end

                    if argRaw:lower() == "all" then
                        builtArgs[argIter] = Players:GetPlayers()
                        continue;
                    end

                    if argRaw:lower() == "random" then
                        builtArgs[argIter] = {Players:GetPlayers()[math.random(1,#Players:GetPlayers())]}
                        continue;
                    end

                    if argRaw:lower() == "others" then
                        local tbl = {}
                        for l,m in pairs(Players:GetPlayers()) do
                            if m == sender then continue; end
                            table.insert(tbl,m)
                        end

                        builtArgs[argIter] = tbl
                        continue;
                    end

                    local pInstance = BaseFuncs.FindPlayer(argRaw)

                    if pInstance then
                        builtArgs[argIter] = {pInstance}
                        continue;
                    else
                        error("Eurus: required arg type of \"player\" on arg #"..argIter..". got \""..argRaw.."\"")
                        continue;
                    end
                end

                if reqType:lower() == "number" then
                    if tonumber(argRaw) ~= nil then
                        builtArgs[argIter] = tonumber(argRaw)
                        continue;
                    else
                        error("Eurus: required arg type of \"number\" on arg #"..argIter..". got \""..argRaw.."\"")
                    end
                end

                builtArgs[argIter] = argRaw

            end

            cmdInstance.Run(sender, builtArgs)
        else
            --// Error! Command instance not found. Aw man.
            error("Command \""..Cmd.."\" not found.")
        end
    end
end

--// Update for when an admin is added.
local function UpdateAdmins()
    for UID, AdminProfile in pairs(State.Admins) do
        if table.find(State.ReadProfs, UID) then return end
        table.insert(State.ReadProfs, UID)
    
        --// Get the player.
        local APlayer = Players:GetPlayerByUserId(UID)

        if APlayer then
            --// Player is in game!
            Players.PlayerRemoving:Connect(function(player)
                if player == APlayer then
                    --// Player is leaving.
                    State.Admins[UID] = nil;
                end
            end)

            APlayer.Chatted:Connect(function(message, recipient)
                --// Message sent! Hand it off to Eurus:ParseMessage().
                ParseMessage(APlayer, message)
            end)
        end
    end
end

CB.Input.FocusLost:Connect(function(ep)
    if ep then
        ParseMessage(Player, State.Prefix..CB.Input.Text)
        CB.Input.Text = ""
    end
end)

UpdateAdmins()

local Eurus = {}

function Eurus:AddCommand(info, run)
    info['Run'] = run
    State.CommandInstances[info.Name] = info
end

function Eurus:SetPrefix(prefix)
    State.Prefix = prefix
end

return Eurus;