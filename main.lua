--[[
Title: 
Author(s):  
Date: 
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/CodePku/main.lua");
local CodePku = commonlib.gettable("Mod.CodePku");
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/Files.lua")
NPL.load("(gl)script/ide/Encoding.lua")
NPL.load("(gl)script/ide/System/Encoding/sha1.lua")
NPL.load("(gl)script/ide/System/Encoding/base64.lua")
NPL.load("(gl)script/ide/System/Windows/Screen.lua")
NPL.load("(gl)script/apps/Aries/Creator/WorldCommon.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/InternetLoadWorld.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/CreateNewWorld.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/LocalLoadWorld.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/RemoteServerList.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/ShareWorldPage.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/DownloadWorld.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/RemoteWorld.lua")
NPL.load("(gl)script/ide/System/Core/UniString.lua")
NPL.load("(gl)script/ide/System/Core/Event.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/TeacherAgent/TeacherAgent.lua")
NPL.load("(gl)script/ide/System/os/os.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Network/NPLWebServer.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/World/SaveWorldHandler.lua")
NPL.load("(gl)Mod/CodePku/service/SocketService.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Network/NetworkMain.lua")
NPL.load("(gl)script/ide/System/Encoding/guid.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/ParaWorldLessons.lua")
NPL.load("(gl)script/ide/System/Encoding/jwt.lua")

local Store = NPL.load("(gl)Mod/CodePku/store/Store.lua")
local MsgBox = NPL.load("(gl)Mod/CodePku/cellar/Common/MsgBox/MsgBox.lua")
local Utils = NPL.load("(gl)Mod/CodePku/helper/Utils.lua")
local MainLogin = NPL.load("(gl)Mod/CodePku/cellar/MainLogin/MainLogin.lua")

local CodePku = commonlib.inherit(commonlib.gettable("Mod.ModBase"),commonlib.gettable("Mod.CodePku"));

CodePku:Property({"Name", "CodePku", "GetName", "SetName", { auto = true }})

-- register mod global variable
CodePku.Store = Store
CodePku.MsgBox = MsgBox
CodePku.Utils = Utils

LOG.std(nil, "info", "CodePku", "load mod codepku")
function CodePku:ctor()
	
end

-- virtual function get mod name

function CodePku:GetName()
	return "CodePku"
end

-- virtual function get mod description 

function CodePku:GetDesc()
	return "CodePku is a plugin in paracraft"
end

function CodePku:init()
		
	GameLogic.GetFilters():add_filter(
			"ShowLoginModePage",
			function()
				MainLogin:Show()
				LOG.std(nil, "info", "CodePku", "add_filter ShowLoginModePage")
				return false
			end
	)

	-- replace load world page
	GameLogic.GetFilters():add_filter(
        "InternetLoadWorld.ShowPage",
		function(bEnable, bShow)
			    
            return false
        end
	)
	
	LOG.std(nil, "info", "CodePku", "plugin initialized");
end

function CodePku:OnLogin()
end
-- called when a new world is loaded. 

function CodePku:OnWorldLoad()
end
-- called when a world is unloaded. 

function CodePku:OnLeaveWorld()
end

function CodePku:OnDestroy()
end

function CodePku:OnInitDesktop()
	-- we will show our own UI here
	return true;
end
