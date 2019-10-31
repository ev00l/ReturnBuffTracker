local ReturnBuffTracker = LibStub("AceAddon-3.0"):GetAddon("ReturnBuffTracker")

function ReturnBuffTracker:CreateMainFrame()
    local theFrame = CreateFrame("Frame", "ReturnBuffTrackerUI", UIParent)
    
    theFrame:ClearAllPoints()
    if ReturnBuffTracker.db.profile.position then
        theFrame:SetPoint("BOTTOMLEFT", ReturnBuffTracker.db.profile.position.x, ReturnBuffTracker.db.profile.position.y)
    else
        theFrame:SetPoint("CENTER", UIParent)
    end
    
    theFrame:SetHeight(140)
    theFrame:SetWidth(ReturnBuffTracker.db.profile.width)
    theFrame:SetMinResize(100, 0)
    theFrame:SetMaxResize(1000, 1000)
    
    theFrame:SetFrameStrata("BACKGROUND")
    theFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 16,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4},
    })
    theFrame:SetBackdropBorderColor(1.0, 1.0, 1.0)
    theFrame:SetBackdropColor(24 / 255, 24 / 255, 24 / 255)
    
    theFrame:EnableMouse(true)
    theFrame:SetMovable(true)
    theFrame:SetResizable(true)
    
    local resizeButton = CreateFrame("Button", nil, theFrame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT")
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
 
    resizeButton:SetScript("OnMouseDown", function(self, button)
        theFrame:StartSizing("RIGHT")
        theFrame:SetUserPlaced(true)
    end)
    resizeButton:SetScript("OnMouseUp", function(self, button)
        theFrame:StopMovingOrSizing()
        ReturnBuffTracker.db.profile.width = theFrame:GetWidth()
    end)
    
    theFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    theFrame:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
        if not ReturnBuffTracker.db.profile.position then
            ReturnBuffTracker.db.profile.position = {}
        end
        ReturnBuffTracker.db.profile.position.x = theFrame:GetLeft()
        ReturnBuffTracker.db.profile.position.y = theFrame:GetBottom()
    end)
        
    theFrame:Show() 
    ReturnBuffTracker.mainFrame = theFrame
end

function ReturnBuffTracker:SetHeightForBars(numOfBars)
    numOfBars = numOfBars - 1
    if numOfBars <= 0 then numOfBars = 0 end
    local height = 5 + 16 + numOfBars * 16 + 5
    ReturnBuffTracker.mainFrame:SetHeight(height)
end

function ReturnBuffTracker:CreateInfoBar(text, r, g, b)
    local theBar = CreateFrame("Frame", text, ReturnBuffTracker.mainFrame)
    theBar.text = text
    
    theBar:SetHeight(16)
    theBar:SetWidth(120)
    theBar:SetPoint("TOPLEFT", ReturnBuffTracker.mainFrame, "TOPLEFT", 5, -5)
    
    theBar.texture = theBar:CreateTexture(nil, "BACKGROUND")
    theBar.texture:SetPoint("TOPLEFT", ReturnBuffTracker.mainFrame, "TOPLEFT", 5, -5)
    theBar.texture:SetColorTexture(r, g, b, 0.9)
    theBar.texture:SetHeight(16)
    theBar.texture:Hide()
    
    theBar.textString = theBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    theBar.textString:SetPoint("CENTER", ReturnBuffTracker.mainFrame, "TOP", 0, -7)
    theBar.textString:SetText(text)
        
    theBar.SetIndex = function(self, index)
        if index then
            theBar:Show()
            theBar:SetPoint("TOPLEFT", ReturnBuffTracker.mainFrame, "TOPLEFT", 5, -5 - (index * 16))
            theBar.texture:SetPoint("TOPLEFT", ReturnBuffTracker.mainFrame, "TOPLEFT", 5, -5 - (index * 16))
            theBar.textString:SetPoint("TOP", ReturnBuffTracker.mainFrame, "TOP", 0, -7 - (index * 16))
        else
            theBar:Hide()
        end
    end
            
    theBar.Update = function(self, value, maxValue, tooltip)
        local percentage = value / maxValue     
        local totalWidth = ReturnBuffTracker.mainFrame:GetWidth() - 10
        local width = floor(totalWidth * percentage)
        if width > 0 then
            theBar.texture:SetWidth(totalWidth * percentage)        
            theBar.texture:Show()
        else
            theBar.texture:Hide()
        end
        
        theBar:SetWidth(totalWidth) 
        theBar.tooltip = tooltip
    end
    
    theBar:SetScript("OnEnter", function(self)
        GameTooltip:AddLine("Missing " .. self.text .. ": ", 1, 1, 1)
        if self.tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            for k, v in ipairs(self.tooltip) do
                GameTooltip:AddLine(v, 1, 1, 1)
            end
            GameTooltip:Show()
        end
    end)
    theBar:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    theBar:SetScript("OnMouseDown", function(self)
        if IsShiftKeyDown() and self.tooltip then
          local msg = ""
          for k, v in ipairs(self.tooltip) do
            msg = msg .. v
            end
          SendChatMessage(msg ,"RAID");
        else
          
          ReturnBuffTracker.mainFrame:StartMoving()
        end
        end)
    theBar:SetScript("OnMouseUp", function(self)
        ReturnBuffTracker.mainFrame:StopMovingOrSizing()
        if not ReturnBuffTracker.db.profile.position then
            ReturnBuffTracker.db.profile.position = {}
        end
        ReturnBuffTracker.db.profile.position.x = ReturnBuffTracker.mainFrame:GetLeft()
        ReturnBuffTracker.db.profile.position.y = ReturnBuffTracker.mainFrame:GetBottom()
    end)
            
    return theBar
end
