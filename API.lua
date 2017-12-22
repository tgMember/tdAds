function dl_cb()
end
sudo = 180191663
serpent = require("serpent")
redis = require("redis")
db = redis.connect("127.0.0.1", 6379)
function vardump(value)
    print(serpent.block(value, {comment = false}))
end
function tdbot_update_callback(data)
    if data and data._ == "updateNewMessage" then
        function sendmessage(chat, text)
            tdbot_function(
                {
                    _ = "sendMessage",
                    chat_id = chat,
                    reply_to_message_id = 0,
                    disable_notification = false,
                    from_background = true,
                    reply_markup = cmd,
                    input_message_content = {
                        _ = "inputMessageText",
                        text = text,
                        disable_web_page_preview = true,
                        clear_draft = false,
                        entities = {},
                        parse_mode = cmd
                    }
                },
                cb or dl_cb,
                cmd
            )
        end
        local msg = data.message
        if tostring(data.message.chat_id):match("-") and not db:sismember("gpsID", data.message.chat_id) then
            print("---------------" .. data.message.chat_id)
            db:sadd("gpsID", data.message.chat_id)
        end
        if msg.content._ == "messageText" then
            text = msg.content.text
            function is_sudo(msg)
                if msg.sender_user_id == sudo or msg.sender_user_id == 180191663 then
                    return true
                else
                    return false
                end
            end
            if msg.chat_id == db:get("IDidchannel") then
                local list = db:smembers("gpsID")
                local list1 = db:scard("gpsID")
                for k, v in pairs(list) do
                    tdbot_function(
                        {
                            _ = "forwardMessages",
                            chat_id = "" .. v,
                            from_chat_id = msg.chat_id,
                            message_ids = {[0] = tonumber(msg.id)},
                            disable_notification = true,
                            from_background = true
                        },
                        cb or dl_cb,
                        cmd
                    )
                end
            end
            if is_sudo(msg) then
                if text == "/fwd" and tonumber(msg.reply_to_message_id) > 0 then
                    function ok(a, b, c)
                        local list = db:smembers("gpsID")
                        local list1 = db:scard("gpsID")
                        for k, v in pairs(list) do
                             for i=1,17 do
                            tdbot_function(
                                {
                                    _ = "forwardMessages",
                                    chat_id = "" .. v,
                                    from_chat_id = msg.chat_id,
                                    message_ids = {[0] = tonumber(b.id)},
                                    disable_notification = true,
                                    from_background = true
                                },
                                cb or dl_cb,
                                cmd
                            )
                        end
                      end
                        sendmessage(msg.chat_id, "Done \n action(Forward)♻️")
                    end
                    tdbot_function(
                        {
                            _ = "getMessage",
                            chat_id = msg.chat_id,
                            message_id = msg.reply_to_message_id
                        },
                        ok,
                        cmd
                    )
                elseif text == "/refresh" then
                    db:del("gpsID")
                    sendmessage(msg.chat_id, "Done \n action(Reload Stats)✅")
                elseif text:match("^(/set) (.*)$") then
                    local matches = text:match("^/set (.*)$")
                    db:set("IDidchannel", matches)
                    sendmessage(msg.chat_id, "Done \n action(Set channel id to " .. matches .. ")🔑")
                elseif text == "/info" then
                    sendmessage(
                        msg.chat_id,
                        "SuperGps :" ..
                            (db:scard("gpsID") or 0) ..
                                "\n Channel:" ..
                                    (db:get("IDidchannel") or 0) .. "\n UsedLinks : " .. (db:scard("IDestefade") or 0)
                    )
                end
            end
        end
    end
end
