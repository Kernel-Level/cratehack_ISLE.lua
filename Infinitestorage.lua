local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Infinite Storage UI", HidePremium = false, SaveConfig = true, ConfigFolder = "InfStorage"})

-- Variables
local InfStorage = false
local yes = Instance.new("BoolValue")
local Hook

-- Function to toggle infinite storage
local function ToggleInfiniteStorage()
    InfStorage = true

    yes:GetPropertyChangedSignal("Value"):Connect(function()
        if yes.Value == true then
            -- Move tools from Backpack to Character
            for _, tool in pairs(game.Players.LocalPlayer:FindFirstChildOfClass("Backpack"):GetChildren()) do
                tool.Parent = game.Players.LocalPlayer.Character
            end
            wait(0.5)
            -- Move tools back from Character to Backpack
            for _, tool in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    tool.Parent = game.Players.LocalPlayer.Backpack
                end
            end
        end
    end)

    -- Hook function to monitor tool pickup
    Hook = hookfunction(getrawmetatable(game).__namecall, newcclosure(function(self, ...)
        local args = {...}
        if getnamecallmethod() == "InvokeServer" and self.Name == "PickupTool" then
            yes.Value = true
            yes.Value = false
        end
        return Hook(self, ...) -- Return the original function to avoid breaking functionality
    end))
end

-- UI Setup
local Tab = Window:MakeTab({
    Name = "Infinite Storage",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

Tab:AddButton({
    Name = "Enable Infinite Storage",
    Callback = function()
        ToggleInfiniteStorage()
        OrionLib:MakeNotification({
            Name = "Infinite Storage",
            Content = "Infinite Storage enabled successfully!",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

OrionLib:Init()
