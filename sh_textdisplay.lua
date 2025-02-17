PLUGIN.name = "Text Display"
PLUGIN.author = "forkwork"
PLUGIN.description = "Adds a command to display text on the player's screen."

if SERVER then
    util.AddNetworkString("DisplayText")
    util.AddNetworkString("ClearText")
end

ix.command.Add("text", {
    description = "Displays text on the specified player's screen.",
    arguments = {ix.type.string, ix.type.string, ix.type.number},
    OnRun = function(self, client, steamID, text, wordCount)
        local target = nil
        for _, v in ipairs(player.GetAll()) do
            if v:SteamID() == steamID then
                target = v
                break
            end
        end

        if not target then
            return "No player with this Steam ID was found."
        end

        net.Start("DisplayText")
        net.WriteString(text)
        net.WriteUInt(wordCount, 8)
        net.Send(target)
    end
})

ix.command.Add("cleartext", {
    description = "Removes displayed text from the player's screen.",
    arguments = {ix.type.string},
    OnRun = function(self, client, steamID)
        local target = nil
        for _, v in ipairs(player.GetAll()) do
            if v:SteamID() == steamID then
                target = v
                break
            end
        end

        if not target then
            return "No player with this Steam ID was found."
        end

        net.Start("ClearText")
        net.Send(target)
    end
})

if CLIENT then
    local displayedText = ""
    local wordCount = 1
    local startTime = 0

    net.Receive("DisplayText", function()
        displayedText = net.ReadString()
        wordCount = net.ReadUInt(8)
        startTime = CurTime()
    end)

    net.Receive("ClearText", function()
        displayedText = ""
    end)

    hook.Add("HUDPaint", "DrawTextOnScreen", function()
        if displayedText == "" then return end

        local timeElapsed = CurTime() - startTime
        local alpha = math.abs(math.sin(timeElapsed * 3)) * 255
        local colors = {
            Color(255, 0, 0, alpha),
            Color(0, 255, 0, alpha),
            Color(0, 0, 255, alpha),
            Color(255, 255, 0, alpha),
            Color(255, 0, 255, alpha)
        }

        for i = 1, wordCount do
            local x = math.random(100, ScrW() - 100)
            local y = math.random(100, ScrH() - 100)
            draw.SimpleText(displayedText, "DermaLarge", x, y, colors[i % #colors + 1], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end)
end
