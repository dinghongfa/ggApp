gg.ignore_modules = {
    "gg%.service%.*",
    "gg%.like_skynet.*",
    "app%.service%.*",
    "app.httpd_main",
}

function gg.hotfix(modname)
    for i,prefix in ipairs({"../src/","gameserver/src/","loginserver/src/","src/"}) do
        if string.startswith(modname,prefix) then
            modname = modname:sub(#prefix+1)
            break
        end
    end
    for i,pat in ipairs(gg.ignore_modules) do
        if modname == string.match(modname,pat) then
            return false,"ignore"
        end
    end
    local address = skynet.address(skynet.self())
    local is_proto = modname:sub(1,5) == "proto"
    -- 只允许游戏逻辑+协议更新
    if is_proto then
        local msg = string.format("op=hotfix,address=%s,module=%s",address,modname)
        logger.logf("info","hotfix",msg)
        print(msg)
        --client.reload_proto()
        return true
    end
    local is_filename
    local replace_cnt
    modname,replace_cnt = string.gsub(modname,"/",".")
    if replace_cnt > 0 then
        is_filename = true
    end
    modname,replace_cnt = string.gsub(modname,"\\",".")
    if replace_cnt > 0 then
        is_filename = true
    end
    local suffix = modname:sub(-4,-1)
    if suffix == ".lua" then
        modname = modname:sub(1,-5)
    elseif is_filename then
        return false,"ignore non lua file"
    end
    local ok,err = gg.reload(modname)
    if not ok then
        local msg = string.format("op=hotfix,address=%s,module=%s,fail=%s",address,modname,err)
        logger.logf("error","hotfix",msg)
        print(msg)
        return false,msg
    end
    local msg = string.format("op=hotfix,address=%s,module=%s",address,modname)
    logger.logf("info","hotfix",msg)
    print(msg)
    return true
end
