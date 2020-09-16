--[[
Author:zouren
Date: 2020-09-14 16:17:34
Des:
use the lib:
------------------------------------
NPL.load("(gl)Mod/CodePku/cellar/GUI/Home/HomeManage.lua")
local HomeManage = commonlib.gettable("Mod.CodePku.Common.HomeManage")
HomeManage:GetHomeWorld()
HomeManage:SaveHome()
-----------------------------------
]]--
NPL.load("(gl)script/apps/Aries/Creator/WorldCommon.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/GameRules/GameMode.lua")
local request = NPL.load("(gl)Mod/CodePku/api/BaseRequest.lua")

local CodePkuBaseApi = NPL.load("(gl)Mod/CodePku/api/Codepku/BaseApi.lua")
local HttpRequest = NPL.load("(gl)Mod/WorldShare/service/HttpRequest.lua")
local RemoteWorld = commonlib.gettable("MyCompany.Aries.Creator.Game.Login.RemoteWorld")
local InternetLoadWorld = commonlib.gettable("MyCompany.Aries.Creator.Game.Login.InternetLoadWorld")
local DownloadWorld = commonlib.gettable("MyCompany.Aries.Game.MainLogin.DownloadWorld")
local WorldCommon = commonlib.gettable("MyCompany.Aries.Creator.WorldCommon")
local GameMode = commonlib.gettable("MyCompany.Aries.Game.GameLogic.GameMode")

local HomeManage = commonlib.gettable("Mod.CodePku.Common.HomeManage")

-- init default value
function HomeManage:OnInit()
    LOG.std("", "info", "HomeManage", "OnInit");
    GameLogic:Connect("WorldLoaded", HomeManage, HomeManage.OnWorldLoaded, "UniqueConnection");
end

function HomeManage:OnWorldLoaded()
    --如果当前正在进入家园区就在进入世界后设置家园区判定变量为true
    if System.Codepku.isLoadingHome then
        System.Codepku.isHome = true
    else
        System.Codepku.isHome = false
    end
    --判定结束后将正在进入家园区判定变量设置为false
    System.Codepku.isLoadingHome = false
end

function HomeManage:GetHomeWorld()
    --body
    local function LoadWorld(world, refreshMode)
        local url = world:GetLocalFileName()
        DownloadWorld.ShowPage(url)
        local mytimer = commonlib.Timer:new(
            {
                callbackFunc = function(timer)
                    HomeManage:InternetLoadWorld(
                        world,
                        refreshMode or "auto",
                        function(bSucceed, localWorldPath)          
                            DownloadWorld.Close()
                        end
                    )
                end
            }
        );
        -- prevent recursive calls.
        mytimer:Change(1,nil);
    end

    request:get('/house/mime'):next(function (response)
        local url = response and response.data and response.data.my_house and response.data.my_house.file and response.data.my_house.file.file_url

        if not url then
            url = response and response.data and response.data.default_house and response.data.default_house.upload_file and response.data.default_house.upload_file.file_url
            if not url then
                GameLogic.AddBBS(nil, L"获取家园失败", 3000, "255 0 0", 21)
                return false
            end
        end

        local world = RemoteWorld.LoadFromHref(url, "self")
        LoadWorld(world, 'auto')
    end)
end

--因为原来的的InternetLoadWorld.LoadWorld()中直接就加载了压缩包，这里就重写一下，前面的逻辑完全相同，后面加载世界时先解压
function HomeManage:InternetLoadWorld(world, refreshMode, onDownloadCompleted)
    NPL.load("(gl)script/apps/Aries/Creator/Game/main.lua");
	local Game = commonlib.gettable("MyCompany.Aries.Game")

	if(not world.DownloadRemoteFile) then
		return;
    end
    world:DownloadRemoteFile(function(bSucceed, msg)
		if(onDownloadCompleted) then
			if(onDownloadCompleted(bSucceed, world.worldpath)) then
				return;
			end
		end
		if(bSucceed and world.worldpath) then
			ParaAsset.OpenArchive(world.worldpath, true)
			local output = {}

			commonlib.Files.Find(output, "", 0, 500, ":worldconfig.txt", world.worldpath)
            ParaAsset.CloseArchive(world.worldpath)

            
			if #output == 0 then
                GameLogic.AddBBS(nil, L"世界文件异常，请重新下载", 3000, "255 0 0", 21)
                LOG.std(nil, "warn", "InternetLoadWorld", "invalid downloaded file will be deleted: %s", world.worldpath);
				ParaIO.DeleteFile(world.worldpath)
				return false
            end

            --解压世界zip文件
            local filesOut = {}
            commonlib.Files.Find(filesOut, "", 0, 10000, ":.", world.worldpath);

            local rootDir = world.worldpath:gsub("/[%w%s_]*.zip$", "")
            local worldDir = rootDir.."/"..commonlib.Encoding.DefaultToUtf8(filesOut[1].filename)
            NPL.load("(gl)script/ide/System/Util/ZipFile.lua");
            local ZipFile = commonlib.gettable("System.Util.ZipFile");
            local zipFile = ZipFile:new();
            if(zipFile:open(world.worldpath)) then
                zipFile:unzip(rootDir.."/");
                zipFile:close();
            end


			if(page) then
				page:CloseWindow();
            end
            System.Codepku.isLoadingHome = true -- 设置当前正在进入家园区判定

            Game.Start(worldDir);
		else
            GameLogic.AddBBS(nil, msg, 3000, "255 0 0", 21)
		end
	end, refreshMode)
end

function HomeManage:UploadHomeWorld(zipfile)
    local content = nil
    if ParaIO.DoesFileExist(zipfile, true) then
        local file = ParaIO.open(zipfile, "r")
        if(file:IsValid()) then
            content = file:GetText(0, -1)
            file:close()
        end
    end

	function success()
		GameLogic.AddBBS("CodeGlobals", L"世界上传成功", 3000, "#00FF00");
	end
	
    function error()
        GameLogic.AddBBS("CodeGlobals", L"世界上传失败", 3000, "#FF0000");
    end

    -- CodePkuBaseApi:PostFields("/house/mime", nil, content, success, error)
    local headers = {}
    headers['Content-Type'] = "multipart/form-data";
    local params = {
        file = {file="myhouse", data=content}
    }
    CodePkuBaseApi:Post("/house/mime", params, headers, success, error)
end

function HomeManage:ChangeGameMode()
    if GameLogic.GameMode:IsEditor() then
        GameLogic.RunCommand("/mode game")
    else
        GameLogic.RunCommand("/mode edit")
    end
end

function HomeManage:SaveHome()
    if not System.Codepku.isHome then
        GameLogic.AddBBS(nil, L"这里不是你的家园", 3000, "255 0 0", 21)
        return
    end
    local source = System.world.name;
    local worldpath = source.."/";
    local zipfile = source..".zip";
    local worldname = string.gsub(source, ".*/(.-)$", "%1");

    local function MakeNewZipPackage_()
        if(ParaIO.DoesFileExist(zipfile)) then
            -- close and delete old file.
            ParaAsset.CloseArchive(zipfile);
            ParaIO.DeleteFile(zipfile);
            log("old zip file exist, we will delete it before making a new one\n");
        end

        local writer = ParaIO.CreateZip(zipfile,"");
        writer:AddDirectory(worldname, worldpath.."*.*", 6);
        writer:close();
    end
    NPL.load("(gl)script/apps/Aries/Creator/WorldCommon.lua");
    local WorldCommon = commonlib.gettable("MyCompany.Aries.Creator.WorldCommon")
    -- WorldCommon.SaveWorldAs()
    -- todo 后期加上世界是否被修改的判定，然后提示玩家是否保存并上传
    GameLogic.SaveAll(true)
    MakeNewZipPackage_()

    HomeManage:UploadHomeWorld(zipfile)

    HomeManage:ChangeGameMode()
end