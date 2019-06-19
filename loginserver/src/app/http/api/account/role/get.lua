---获取角色
--@author sundream
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/role/get
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=签名
--      appid       [required] type=string help=appid
--      roleid      [required] type=number help=角色ID
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=返回码
--      message =   [required] type=string help=返回码说明
--      data = {
--          role =  [optional] type=table help=存在则返回该角色
--                  role格式见/api/account/role/add
--                  另外返回的角色数据中还带有以下字段
--                  roleid = 角色ID
--                  createtime = 创建时间
--                  create_serverid = 创建所在服
--                  now_serverid = 当前所在服
--                  online = 是否在线
--                  lv = 等级
--                  gold = 金币
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:8885/api/account/role/get' -d '{"sign":"debug","appid":"appid","roleid":1000000}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        roleid = {type="number"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.response_json(linkobj.linkid,200,response)
        return
    end
    local appid = request.appid
    local roleid = request.roleid
    local app = util.get_app(appid)
    if not app then
        httpc.response_json(linkobj.linkid,200,httpc.answer.response(httpc.answer.code.APPID_NOEXIST))
        return
    end
    local appkey = app.appkey
    if not httpc.check_signature(args.sign,args,appkey) then
        httpc.response_json(linkobj.linkid,200,httpc.answer.response(httpc.answer.code.SIGN_ERR))
        return
    end
    local role = accountmgr.getrole(appid,roleid)
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = {role=role}
    httpc.response_json(linkobj.linkid,200,response)
    return
end

function handler.POST(linkobj,header,query,body)
    local args = cjson.decode(body)
    handler.exec(linkobj,header,args)
end

function __hotfix(module)
    gg.hotfix("app.net.net")
end

return handler
