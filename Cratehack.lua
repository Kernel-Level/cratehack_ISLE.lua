local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Crate Hack UI", HidePremium = false, SaveConfig = true, ConfigFolder = "CrateHack"})


local PlayersService = game:GetService("Players")
local LocalPlayer = PlayersService.LocalPlayer
local Services = workspace:WaitForChild("Services")
local ALLOW_FREEZE = true
local theId, ThePart
local Hook


local function CharacterPresent(str, character)
    for i = 1, #str do
        if string.sub(str, i, i) == character then
            return true
        end
    end
    return false
end

local function GetNumber(expression)

end

local function ParseExpression(expression, expectEndParentheses)

end

local function GetDictionaryLength(dictionary)
    local length = 0
    for _, _ in pairs(dictionary) do
        length = length + 1
    end
    return length
end

local function OnHack(expressions, letters, answers)
    local results = {}
    local generatedNumbers = {}
    local lastGeneratedNumbers
    local allowSubmit = true

    for index, expression in ipairs(expressions) do
        local correctAnswer = tonumber(answers[index])
        local result, errorMessage

        repeat
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
                if lastGeneratedNumbers == generatedNumbers then
                    allowSubmit = false
                    task.wait(0.0001)
                    task.spawn(OnHack, expressions, letters, answers)
                    break
                end
                table.clear(generatedNumbers)
            end

            if not ALLOW_FREEZE then
                task.wait()
            end
        until tonumber(result) == correctAnswer

        lastGeneratedNumbers = generatedNumbers
    end

    if allowSubmit then
        Services:WaitForChild("SubmitSolution"):FireServer(theId, generatedNumbers, ThePart)
        table.clear(generatedNumbers)
    end
end


Hook = hookfunction(getrawmetatable(game).__namecall, newcclosure(function(self, ...)
    local args = {...}
    if getnamecallmethod() == "InvokeServer" and self.Name == "BypassRequest" then
        theId = args[1]
        ThePart = args[2]
    end
    return Hook(self, ...)
end))


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
