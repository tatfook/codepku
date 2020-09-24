NPL.load("./MainSceneUIButtons.lua");
NPL.load("(gl)script/apps/Aries/Creator/WorldCommon.lua");
NPL.load("(gl)Mod/CodePku/cellar/GUI/Home/HomeManage.lua")
local HomeManage = commonlib.gettable("Mod.CodePku.Common.HomeManage")
local AdaptWindow = commonlib.gettable("Mod.CodePku.GUI.Window.AdaptWindow")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager")
local MainSceneUIButtons = commonlib.gettable("Mod.CodePku.Common.TouchMiniButtons.MainSceneUIButtons");

NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/TouchController.lua");

-- CommonFunc = NPL.load("(gl)Mod/CodePku/cellar/Common/CommonFunc/CommonFunc.lua")
CommonFunc = commonlib.gettable("Mod.CodePku.Common.CommonFunc")

local TouchController = commonlib.gettable("MyCompany.Aries.Game.GUI.TouchController");

local MainUIButtons = NPL.export();

MainUIButtons.hasshown = false

MainUIButtons.common_window = nil
MainUIButtons.function_window = nil
MainUIButtons.dialog_window = nil
MainUIButtons.money_window = nil
MainUIButtons.open_function = nil
MainUIButtons.open_common = nil
MainUIButtons.account_up = nil
MainUIButtons.user_asset = nil
MainUIButtons.home_window = nil

MainUIButtons.isIOSApproval = CommonFunc.isIOSApproval()

function MainUIButtons.show_common_ui(flag)

	if MainUIButtons.common_window then
		MainUIButtons.common_window:CloseWindow()
		MainUIButtons.common_window = nil
	end

	-- ios渠道屏蔽Q群
	local open_width = 0
	if MainUIButtons.isIOSApproval then
		open_width = 643
	else
		open_width = 904
	end
	local open_height = 178
	local close_width = 82
	local close_height = 178

	local params = {
		open = {
			url="Mod/CodePku/cellar/Common/TouchMiniButtons/MainUIButtons_common.html", 
			alignment="_lt", left = 0, top = 0, width = open_width, height = open_height, click_through = true,
		},
		close = {
			url="Mod/CodePku/cellar/Common/TouchMiniButtons/MainUIButtons_common.html", 
			alignment="_lt", left = 0, top = 0, width = close_width, height = close_height, click_through = true,
		}
	}
	if("close" == flag)then
		MainUIButtons.open_common = false
	else
		MainUIButtons.open_common = true
	end
	if(flag ~= nil)then
		MainUIButtons.common_window = AdaptWindow:QuickWindow(params['close'])
	else
		MainUIButtons.common_window = AdaptWindow:QuickWindow(params["open"])
	end
	
end

function MainUIButtons.show_function_ui(flag)	--flag == true,工具栏展开
	-- 华为渠道屏蔽排行榜
	MainUIButtons.isHuaweiApproval = CommonFunc.isHuaweiApproval()

	if MainUIButtons.function_window then
		MainUIButtons.function_window:CloseWindow()
		MainUIButtons.function_window = nil
	end
	local params = {}
	if MainUIButtons.isHuaweiApproval then
		params = {
			open = {
				url="Mod/CodePku/cellar/Common/TouchMiniButtons/MainUIButtons_function.html", 
				alignment="_rb", left = -547, top = -178, width = 547, height = 178,
				click_through = true,
			},
			close = {
				url="Mod/CodePku/cellar/Common/TouchMiniButtons/MainUIButtons_function.html", 
				alignment="_rb", left = -85, top = -178, width = 85, height = 178,
				click_through = true,
			}
		}
	else 
		params = {
			open = {
				url="Mod/CodePku/cellar/Common/TouchMiniButtons/MainUIButtons_function.html", 
				alignment="_rb", left = -678, top = -178, width = 678, height = 178,
				click_through = true,
			},
			close = {
				url="Mod/CodePku/cellar/Common/TouchMiniButtons/MainUIButtons_function.html", 
				alignment="_rb", left = -85, top = -178, width = 85, height = 178,
				click_through = true,
			}	
		}	
	end

	if("close" == flag)then
		MainUIButtons.open_function = false
	else
		MainUIButtons.open_function = true
	end
	
	if(flag ~= nil)then
		MainUIButtons.function_window = AdaptWindow:QuickWindow(params[flag])
	else
		MainUIButtons.function_window = AdaptWindow:QuickWindow(params["open"])
	end
end

function MainUIButtons.show_dialog_ui(bshow)
	if MainUIButtons.isIOSApproval then
		return
	else
		MainUIButtons.dialog_window = MainSceneUIButtons.show_dialog_ui(bshow, 0)
	end
end

MainUIButtons.money = {goldcoin=0, wanxuecoin=0};

function MainUIButtons.show_money_ui()
	-- return
	local width = 746
	local height = 89

	local info = Mod.CodePku.Store:Get('user/info');
	local wallets = info.user_wallets or {};
	for _, v in ipairs(wallets) do
		if v.currency_id == 1 then
			MainUIButtons.money.goldcoin = v.amount;
		elseif v.currency_id == 2 then
			MainUIButtons.money.wanxuecoin = v.amount;
		end
	end

	local params = {
		url="Mod/CodePku/cellar/Common/TouchMiniButtons/MainMoney.html", 
		alignment="_lt", left = 1309, top = 0, width = width, height = height,
	}
	
	if MainUIButtons.isHuaweiApproval then
		return
	else 
		MainUIButtons.money_window = AdaptWindow:QuickWindow(params)	
	end
end

function MainUIButtons.show_account_up_ui()
	local params = {
		url = "Mod/CodePku/cellar/Common/TouchMiniButtons/MainUIButtons_account_up.html",
		alignment = "_lt", left = 1027, top = -8, width = 264, height = 127,
	}

	local isVisitor = commonlib.getfield("System.User.isVisitor")

	if isVisitor then
		MainUIButtons.account_up = AdaptWindow:QuickWindow(params)
	end
end

function MainUIButtons.show_home_window_ui()
	local params = {
		url = "Mod/CodePku/cellar/Common/TouchMiniButtons/MainUIButtons_home_window.html",
		alignment = "_lt", left = 1600, top = 493, width = 135, height = 155,
	}

	local isHome = HomeManage:IsMyHome()
	
	if isHome then
		MainUIButtons.home_window = AdaptWindow:QuickWindow(params)
	end
end

function MainUIButtons.JudgeNil()
	if MainUIButtons.common_window ~= nil then
		MainUIButtons.common_window:CloseWindow()
		MainUIButtons.common_window = nil
	end
	if MainUIButtons.function_window ~= nil then
		MainUIButtons.function_window:CloseWindow()
		MainUIButtons.function_window = nil
	end
	if MainUIButtons.dialog_window ~= nil then
		MainUIButtons.dialog_window:CloseWindow()
		MainUIButtons.dialog_window = nil
	end
	if MainUIButtons.money_window ~= nil then
		MainUIButtons.money_window:CloseWindow()
		MainUIButtons.money_window = nil
	end
	if MainUIButtons.account_up ~= nil then
		MainUIButtons.account_up:CloseWindow()
		MainUIButtons.account_up = nil
	end
	if MainUIButtons.home_window ~= nil then
		MainUIButtons.home_window:CloseWindow()
		MainUIButtons.home_window = nil
	end
end


function MainUIButtons.ShowPage()
	MainUIButtons.JudgeNil()

	local hideMenu = false;
	local hideAllMenu = false;
	if (System.Codepku and System.Codepku.Coursewares) then		
		hideMenu = System.Codepku.Coursewares.hide_menu;
		hideAllMenu = System.Codepku.Coursewares.hide_all_menu;
	end
		
	if not hideAllMenu then
		if not hideMenu then 
			MainUIButtons.show_common_ui()
			MainUIButtons.show_dialog_ui(false)
			MainUIButtons.show_money_ui()		
			MainUIButtons.show_function_ui()
			MainUIButtons.show_account_up_ui()
			MainUIButtons.show_home_window_ui()
		else
			MainUIButtons.show_common_ui()
		end
	end
	--进入家园区初始化时隐藏下排按钮
	if HomeManage:IsMyHome() then
		MainUIButtons.show_function_ui("close")
	end
end


local distance = 10
local length_limit = 7

function MainUIButtons.show_interact_ui(obj)
	local x, y, z = obj:GetPosition()
	local px, py, pz = EntityManager.GetPlayer():GetPosition()
	if(math.abs(x-px) > distance or math.abs(y-py) > distance or math.abs(z-pz) > distance) then
		GameLogic.AddBBS("CodeGlobals", L"距离玩家过远，走近点再尝试。", 3000, "#ff0000");
		return
	end
	-- asset
	MainUIButtons.user_asset = obj:GetMainAssetPath();
	
	local username =  obj:GetUserName()
	local displayname = obj:GetDisplayName()
	local pname = username or displayname
	pname = commonlib.utf8.sub(pname,1,length_limit)

	local info = obj:GetPlayerInfo()
	if not info or not info.userinfo then
		return
	end
	local pid = info.userinfo.id
	
	local width = 1920
	local height = 1080

	local params = {
		url = format("Mod/CodePku/cellar/Common/TouchMiniButtons/MainUIButtons_interact.html?pname=%s&pid=%s", pname, pid),
		alignment="_lt", left = 0, top = 0, width = width, height = height,
		click_through = false,
	}
	local window = AdaptWindow:QuickWindow(params)

end