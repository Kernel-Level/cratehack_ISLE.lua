local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Crate Hack UI", HidePremium = false, SaveConfig = true, ConfigFolder = "CrateHack"})

-- Services and variables
local PlayersService = game:GetService("Players")
local LocalPlayer = PlayersService.LocalPlayer
local Services = workspace:WaitForChild("Services")
local ALLOW_FREEZE = true
local MAX_TRIES = 100 -- Limit the number of attempts to solve
local theId, ThePart
local Hook

-- Helper Functions
local function CharacterPresent(str, character)
    for i = 1, #str do
        if string.sub(str, i, i) == character then
            return true
        end
    end
    return false
end

local function GetNumber(expression)
    -- (Implementation remains the same)
end

local function ParseExpression(expression, expectEndParentheses)
    -- (Implementation remains the same)
end

local function GetDictionaryLength(dictionary)
    local length = 0
    for _, _ in pairs(dictionary) do
        length = length + 1
    end
    return length
end

-- Crate Hack Logic with Crash Prevention
local function OnHack(expressions, letters, answers)
    local results = {}
    local generatedNumbers = {}
    local lastGeneratedNumbers
    local allowSubmit = true

    for index, expression in ipairs(expressions) do
        local correctAnswer = tonumber(answers[index])
        local result, errorMessage
        local attempts = 0 -- Track attempts to prevent infinite loops

        repeat
            attempts = attempts + 1
            if attempts > MAX_TRIES then
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Failed to solve expression after " .. MAX_TRIES .. " attempts.",
                    Image = "rbxassetid://4483345998",
                    Time = 5
                })
                allowSubmit = false
                break
            end

            local expressionCopy = expression
            if lastGeneratedNumbers then
                generatedNumbers = lastGeneratedNumbers
            elseif GetDictionaryLength(generatedNumbers) == 0 then
                for _, letter in ipairs(letters) do
                    generatedNumbers[letter] = math.random(0, 9)
                end
            end

            for letter, value in pairs(generatedNumbers) do
                expressionCopy = string.gsub(expressionCopy, letter, value)
            end

            result, errorMessage = ParseExpression(expressionCopy)
            if tonumber(result) ~= correctAnswer then
                table.clear(generatedNumbers)
            end

            if not ALLOW_FREEZE then
                task.wait(0.01) -- Prevent excessive resource usage
            end
        until tonumber(result) == correctAnswer or attempts > MAX_TRIES

        if attempts > MAX_TRIES then
            break
        end
        lastGeneratedNumbers = generatedNumbers
    end

    if allowSubmit then
        Services:WaitForChild("SubmitSolution"):FireServer(theId, generatedNumbers, ThePart)
        OrionLib:MakeNotification({
            Name = "Success",
            Content = "Crate Hack executed successfully!",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
end

-- Hook the NameCall function
Hook = hookfunction(getrawmetatable(game).__namecall, newcclosure(function(self, ...)
    local args = {...}
    if getnamecallmethod() == "InvokeServer" and self.Name == "BypassRequest" then
        theId = args[1]
        ThePart = args[2]
    end
    return Hook(self, ...)
end))

-- UI Setup
local Tab = Window:MakeTab({
    Name = "Crate Hack",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

Tab:AddButton({
    Name = "Start Crate Hack",
    Callback = function()
        local HackReceiver = LocalPlayer.Character:FindFirstChild("@H")
        if HackReceiver then
            HackReceiver.OnClientEvent:Connect(OnHack)
            OrionLib:MakeNotification({
                Name = "Crate Hack",
                Content = "Hack initiated successfully!",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "HackReceiver not found!",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    end
})

OrionLib:Init()
