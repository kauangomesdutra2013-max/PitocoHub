--[[
    ═══════════════════════════════════════
         PITOCO HUB - Steal Egg
              by @KAUAN66yy
    ═══════════════════════════════════════
]]

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local CONFIG = {
    NomeDoOvo = "Egg",
    DistanciaMax = 500,
    AutoColetar = true,
    VelocidadeTeleporte = 0.1
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PitocoEgg"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 120)
Frame.Position = UDim2.new(0, 20, 0.5, -60)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = Frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(138, 43, 226)
stroke.Thickness = 2
stroke.Parent = Frame

local Titulo = Instance.new("TextLabel")
Titulo.Size = UDim2.new(1, 0, 0, 30)
Titulo.Position = UDim2.new(0, 0, 0, 5)
Titulo.BackgroundTransparency = 1
Titulo.Text = "🥚 PITOCO HUB - Egg"
Titulo.TextColor3 = Color3.fromRGB(138, 43, 226)
Titulo.TextScaled = true
Titulo.Font = Enum.Font.GothamBold
Titulo.Parent = Frame

local StatusTxt = Instance.new("TextLabel")
StatusTxt.Size = UDim2.new(1, 0, 0, 20)
StatusTxt.Position = UDim2.new(0, 0, 0, 35)
StatusTxt.BackgroundTransparency = 1
StatusTxt.Text = "Procurando ovos..."
StatusTxt.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusTxt.TextScaled = true
StatusTxt.Font = Enum.Font.Gotham
StatusTxt.Parent = Frame

local Botao = Instance.new("TextButton")
Botao.Size = UDim2.new(0.8, 0, 0, 35)
Botao.Position = UDim2.new(0.1, 0, 0, 70)
Botao.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
Botao.Text = "🔴 ATIVAR"
Botao.TextColor3 = Color3.fromRGB(255, 255, 255)
Botao.TextScaled = true
Botao.Font = Enum.Font.GothamBold
Botao.Parent = Frame

local botaoCorner = Instance.new("UICorner")
botaoCorner.CornerRadius = UDim.new(0, 8)
botaoCorner.Parent = Botao

local ativo = false

local function encontrarOvo()
    local maisProximo = nil
    local menorDist = CONFIG.DistanciaMax
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local nome = string.lower(obj.Name)
            if nome:find(string.lower(CONFIG.NomeDoOvo)) or nome:find("egg") or nome:find("ovo") then
                local posicao
                if obj:IsA("BasePart") then
                    posicao = obj.Position
                else
                    local prim = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if prim then posicao = prim.Position end
                end
                
                if posicao then
                    local dist = (posicao - hrp.Position).Magnitude
                    if dist < menorDist then
                        menorDist = dist
                        maisProximo = obj
                    end
                end
            end
        end
    end
    
    return maisProximo
end

local function teleportarPara(objeto)
    local posicao
    if objeto:IsA("BasePart") then
        posicao = objeto.Position
    else
        local prim = objeto.PrimaryPart or objeto:FindFirstChildWhichIsA("BasePart")
        if prim then posicao = prim.Position end
    end
    
    if posicao then
        hrp.CFrame = CFrame.new(posicao + Vector3.new(0, 3, 0))
    end
end

Botao.MouseButton1Click:Connect(function()
    ativo = not ativo
    
    if ativo then
        Botao.Text = "🟢 ATIVO"
        Botao.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        
        task.spawn(function()
            while ativo do
                local ovo = encontrarOvo()
                
                if ovo then
                    StatusTxt.Text = "🥚 Achou: " .. ovo.Name
                    StatusTxt.TextColor3 = Color3.fromRGB(0, 255, 100)
                    teleportarPara(ovo)
                    task.wait(CONFIG.VelocidadeTeleporte)
                    
                    local prompt = ovo:FindFirstChildOfClass("ProximityPrompt")
                    if not prompt then
                        for _, d in pairs(ovo:GetDescendants()) do
                            if d:IsA("ProximityPrompt") then
                                prompt = d
                                break
                            end
                        end
                    end
                    
                    if prompt then
                        fireproximityprompt(prompt)
                    end
                else
                    StatusTxt.Text = "❌ Nenhum ovo encontrado"
                    StatusTxt.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
                
                task.wait(0.5)
            end
        end)
    else
        Botao.Text = "🔴 ATIVAR"
        Botao.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
        StatusTxt.Text = "Desativado"
        StatusTxt.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

local dragging = false
local dragStart, startPos

Titulo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("[PITOCO HUB] Steal Egg carregado!")
