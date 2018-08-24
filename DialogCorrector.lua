local DialogCorrector = ZO_Object:Subclass()

local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

function DialogCorrector:SetupOptions()
	local addonDisplayName = "Dialog Corrector"

	local panelData = {
		type = "panel",
		name = addonDisplayName,
		displayName = addonDisplayName,
		author = "|c0066FFArchitecture|r",
		--version = self.version,
		registerForRefresh = true,
		registerForDefaults = false,
	}

	local optionsTable = {
		{
			type = "header",
			name = "Dialog Interaction Enhancements",
			width = "full",
		},
		{
			type = "checkbox",
			name = "Fix Spacing Inconsistencies",
			tooltip = "Automatically replaces any instances of '.<space><space>' with '.<space>' in dialog interaction content.",
			getFunc = function() return self.sv.enabled end,
			setFunc = function(value) self.sv.enabled = value if (value) then self:HookDialogInteraction() end end,
			width = "full",
		},
	}

	LAM:RegisterAddonPanel(self.name, panelData)
	LAM:RegisterOptionControls(self.name, optionsTable)
end

function DialogCorrector:HookDialogInteraction()
	if (self.hasEnabled) then return end
	self.hasEnabled = true

	local dialogCorrectorOriginalSetTextFn = ZO_InteractWindowTargetAreaBodyText.SetText

	ZO_InteractWindowTargetAreaBodyText.SetText = function (self, bodyText)
		local dialogCorrectorBodyText = bodyText
		if (INTERACTION_DIALOG_CORRECTOR.enabled) then
			dialogCorrectorBodyText = string.gsub(dialogCorrectorBodyText, "\.  ", "\. ")
		end
	    dialogCorrectorOriginalSetTextFn(self, dialogCorrectorBodyText)
	end
end

function DialogCorrector:DefineColors()
	self.color = {}
	self.color.yellow = "|cFFFF00"
	self.color.lightYellow = "|cFFFFCC"
	self.color.green = "|c00FF00"
	self.color.magenta = "|cFF00FF"
	self.color.red = "|cFF0000"
	self.color.darkOrange = "|cFFA500"
	self.color.iconYellow = "|cFFFF33"
	self.color.iconOrange = "|cFF6600"
	self.color.grey = "|c626255"
	self.color.brightOrange = "|cE68A00"
end

function DialogCorrector:Initialize(addonName)
	self:DefineColors()

	self.hasEnabled = false

	self.name = addonName

	self.sv = {}

	local defaults = {
		enabled = true
	}

	self.sv = ZO_SavedVars:NewAccountWide(self.name.."_SavedVariables", 1, nil, defaults)

	self:SetupOptions(self.name)

	if (self.sv.enabled) then
		self:HookDialogInteraction()
	end

end

INTERACTION_DIALOG_CORRECTOR = DialogCorrector:New()

local function DialogCorrector_Init(eventType, addonName)
	if addonName ~= "DialogCorrector" then
		return
	end

	INTERACTION_DIALOG_CORRECTOR:Initialize(addonName)
end

EVENT_MANAGER:RegisterForEvent("DialogCorrectorInit", EVENT_ADD_ON_LOADED, DialogCorrector_Init)
