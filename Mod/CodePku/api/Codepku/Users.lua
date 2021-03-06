--[[
Title: Keepwork Users API
Author(s):  big
Date:  2019.11.8
Place: Foshan
use the lib:
------------------------------------------------------------
local KeepworkUsersApi = NPL.load("(gl)Mod/WorldShare/api/Keepwork/Users.lua")
------------------------------------------------------------
]]

local CodePkuBaseApi = NPL.load('./BaseApi.lua')

local CodePkuUsersApi = NPL.export()

local osPlatform = System.os.GetPlatform()

-- url: /users/login
-- method: POST
-- params:
--[[
    account	string 必须 用户名	
    password string 必须 密码
]]
-- return: object
function CodePkuUsersApi:Login(mobile, verifyCode, mobileToken, visitorId, success, error)
    if type(mobile) ~= "string" or type(verifyCode) ~= "string" or type(mobileToken) ~= "string" then
        return false
    end

    local params = {
        mobile = mobile,
        verify_code = verifyCode,
        mobile_token = mobileToken,
        visitor_id = visitorId,
        os_platform = osPlatform
    }

    local AppMarket = ParaEngine.GetAppCommandLineByParam("app_market", nil);

    if AppMarket then
        params['app_market'] = AppMarket;
    end

    CodePkuBaseApi:Post("/users/login", params, nil, success, error, { 503, 400 })
end

-- url: /users/authorizations
-- method: POST
-- params:
--[[
    account	string 必须 用户名
    password string 必须 密码
]]
-- return: object
function CodePkuUsersApi:LoginWithPwd(mobile, password, success, error)
    if type(mobile) ~= "string" or type(password) ~= "string" then
        return false
    end

    local params = {
        mobile = mobile,
        password = password,
        os_platform = osPlatform
    }

    CodePkuBaseApi:Post("/users/authorizations", params, nil, success, error, { 503, 400 })
end

-- url: /users/quicklogin
-- method: POST
-- params:
--[[
    visitor_id 唯一标识符
    app_market 来源标识
]]
-- return: object
function CodePkuUsersApi:QuickLogin(visitor_id, app_market, success, error)
    if type(visitor_id) ~= "string" then
        return false
    end

    local params = {
        visitor_id = visitor_id,
        app_market = app_market,
        os_platform = osPlatform
    }

    CodePkuBaseApi:Post("/users/visitor-login", params, nil, success, error, { 503, 400 })
end

-- url: /users/set-password
-- method: PUT
-- params:
--[[
    token string 必须 token
]]
-- return: object
function CodePkuUsersApi:UpdatePassword(token, params, callback)
    if type(token) ~= "string" and #token == 0 then
        return false
    end
    local headers = { Authorization = format("Bearer %s", token) }
    CodePkuBaseApi:Put('/users/set-password', params, headers, callback, callback, { 503, 400 })
end

-- url: /users/profile
-- method: POST
-- params:
--[[
    token string 必须 token
]]
-- return: object
function CodePkuUsersApi:Profile(token, success, error)
    if type(token) ~= "string" and #token == 0 then
        return false
    end

    local headers = { Authorization = format("Bearer %s", token) }

    CodePkuBaseApi:Get("/users/profile", nil, headers, success, error, 401)
end

function CodePkuUsersApi:LoginWithToken(token, success, error)
    if type(token) ~= "string" and #token == 0 then
        return false
    end

    local headers = { Authorization = format("Bearer %s", token) }
    local params = {
        os_platform = osPlatform
    }
    CodePkuBaseApi:Get("/users/me-with-token", params, headers, success, error, 401)
end

-- url: /users/register
-- method: POST
-- params:
--[[
    token string 必须 token
    username string 必须 username,
    password string 必须 password,
    key string 必须 captchaKey,
    captcha string 必须 captcha,
    channel = 3
]]
-- return: object
function CodePkuUsersApi:Register(params, success, error, noTryStatus)
    CodePkuBaseApi:Post('/users/register', params, { notTokenRequest = true }, success, error, noTryStatus)
end

-- url: /users/cellphone_captcha
-- method: POST
-- params:
--[[
    token string 必须 token
]]
-- return: object
function CodePkuUsersApi:RealName(params, success, error, noTryStatus)
    CodePkuBaseApi:Post('/users/cellphone_captcha', params, nil, success, error, noTryStatus)
end

-- url: /users/svg_captcha?png=true
-- method: GET
-- params:
--[[
    token string 必须 token
]]
-- return: object
function CodePkuUsersApi:FetchCaptcha(success, error)
    CodePkuBaseApi:Get('/users/svg_captcha?png=true', nil, { notTokenRequest = true }, success, error)
end


-- url: /users/cellphone_captcha
-- method: GET
-- params:
--[[
    token string 必须 token
]]
-- return: object
function CodePkuUsersApi:CellphoneCaptcha(phone, success, error)
    if type(phone) ~= 'string' then
        return false
    end

    local url = '/users/cellphone_captcha?cellphone=' .. phone

    CodePkuBaseApi:Get(url, nil, { notTokenRequest = true }, success, error)
end

-- url: /users/cellphone_captcha
-- method: POST
-- params:
--[[
    token string 必须 token
]]
-- return: object
function CodePkuUsersApi:BindPhone(params, success, error)
    CodePkuBaseApi:Post('/users/cellphone_captcha', params , { notTokenRequest = false }, success, error)
end

-- url: /users/email_captcha
-- method: GET
-- params:
--[[
    token string 必须 token
]]
-- return: object
function CodePkuUsersApi:EmailCaptcha(email, success, error)
    local url = '/users/email_captcha?email=' .. email

    CodePkuBaseApi:Get(url, nil, { notTokenRequest = true }, success, error)
end

-- url: /users/email_captcha
-- method: POST
-- params:
--[[
    token string 必须 token
]]
-- return: object
function CodePkuUsersApi:BindEmail(params, success, error)
    CodePkuBaseApi:Post('/users/email_captcha', params, { notTokenRequest = false }, success, error)
end

-- url: /users/reset_password
-- method: POST
-- params:
--[[
    token string 必须 token
]]
-- return: object
function CodePkuUsersApi:ResetPassword(params, success, error, noTryStatus)
    CodePkuBaseApi:Post('/users/reset_password', params, { notTokenRequest = true }, success, error, noTryStatus)
end

function CodePkuUsersApi:GetMobileCode(mobile, success, error)    
    LOG.std(nil, "info", "codepku", type(mobile));
    if type(mobile) ~= "string" then        
        return false
    end
    local params = {
        mobile = mobile
    }
    -- 游客升级账号时获取验证码给服务器传送一个数据，判定是否手机号被绑定
    local isVisitor = commonlib.getfield("System.User.isVisitor")
    if isVisitor then
        params['is_bind'] = 1
    end
    CodePkuBaseApi:Post('/users/mobile-code', params, { notTokenRequest = true }, success, error, {503, 400, 422, 500})
end

function CodePkuUsersApi:GetCourseEntryWorld(success, error)
    LOG.std(nil, "info", "codepku", "user api getCourseEntry")

    CodePkuBaseApi:Get('/worlds/course-entry', nil, { notTokenRequest = false }, success, error, {503, 404, 500})
end