local ui = {}
ui.__index = ui

local uis = require(game:GetService("StarterPlayer").StarterPlayerScripts.Client.uis)

function ui.new(button, instance)
    local new_ui = {}
    setmetatable(new_ui, ui)
    new_ui.instance = instance
    uis[new_ui] = true
    if not button then return new_ui end
    button.Activated:Connect(function()
        for other_ui in pairs(uis) do
            if other_ui == new_ui then continue end
            other_ui:close()
        end
        new_ui:open()
    end)
    return new_ui
end

function ui:open()
    if self.instance.Visible then
        self:close()
        return
    end
    self.instance.Visible = true
end

function ui:close()
    self.instance.Visible = false
end

return ui
