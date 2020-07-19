SLASH_PERSONALRESOURCEDISPLAY1, SLASH_PERSONALRESOURCEDISPLAY2 = "/prd"

function SlashCmdList.PERSONALRESOURCEDISPLAY(msg, editBox)
    if msg == "reload" then
        PRD:Clean()
        C_Timer.After(.1, function()
            PRD:InitializePersonalResourceDisplay()
        end)
        print('Reloading PRD')
    elseif msg == "hide" then
        print("Hiding PRD")
        _G["prd_bar_container"]:Hide()
    elseif msg == "show" then
        print("Show PRD")
        _G["prd_bar_container"]:Show()
    else
        print('No command provided')
        print('Currently supported Commands:')
        print('"reload" -- reloads the display in case some bug occurs that prevents it from refreshing')
    end
end