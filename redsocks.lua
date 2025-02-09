local m, s, btn_start, btn_stop, btn_restart, btn_disable, btn_enable, status

m = Map("redsocks", "Redsocks Configuration", "Configure Redsocks proxy settings.")

s = m:section(TypedSection, "redsocks", "Redsocks Proxy")
s.addremove = false
s.anonymous = true

-- Redsocks status button at the top
status = s:option(DummyValue, "_status", "Redsocks Status")
status.rawhtml = true
status.size = "large" -- Increase font size
function status.cfgvalue(self, section)
    -- Check if the redsocks process is running by checking the pid file and running process
    local pid_check = io.popen("if [ -e /var/run/redsocks.pid ]; then ps -p $(cat /var/run/redsocks.pid) > /dev/null; fi")
    local result = pid_check:read("*all")
    pid_check:close()

    if result ~= "" then
        return "<b><span style='color: green; font-size: 20px;'>Running</span></b>"
    else
        return "<b><span style='color: red; font-size: 20px;'>Stopped</span></b>"
    end
end

-- Server Address, Port, and Username
s:option(Value, "host", "Proxy ip").datatype = "ipaddr"
s:option(Value, "port", "Proxy port").datatype = "port"
s:option(Value, "username", "Username")

pass = s:option(Value, "password", "Password")
pass.password = true

-- Start button
btn_start = s:option(Button, "start", "Start", "Start Redsocks service.")
btn_start.inputstyle = "apply"
function btn_start.write(self, section)
  os.execute("service redsocks start &")
end

-- Stop button
btn_stop = s:option(Button, "stop", "Stop", "Stop Redsocks service.")
btn_stop.inputstyle = "reset"
function btn_stop.write(self, section)
  os.execute("service redsocks stop &")
end

-- Restart button
btn_restart = s:option(Button, "restart", "Restart", "Restart Redsocks service.")
btn_restart.inputstyle = "reload"
function btn_restart.write(self, section)
  os.execute("service redsocks restart &")
end

-- Enable/Disable buttons
local enable_check = io.popen("ls /etc/rc.d/ | grep redsocks")
local enable_result = enable_check:read("*all")
enable_check:close()

if enable_result and enable_result:match("S90redsocks") then
    -- Show "Enabled" without box, in green color
    btn_enable = s:option(DummyValue, "enabled", "Enabled")
    btn_enable.rawhtml = true
    btn_enable.default = "<b><span style='color: green;'>Enabled</span></b>"

    -- Disable button
    btn_disable = s:option(Button, "disable", "Disable", "Disable Redsocks service.")
    btn_disable.inputstyle = "remove"
    function btn_disable.write(self, section)
        os.execute("service redsocks disable &")
        
        -- Refresh the page after disabling
        luci.sys.call("sleep 1")  -- sleep to allow disabling process to complete
        luci.http.redirect(luci.dispatcher.build_url("admin/services/redsocks"))
    end
else
    -- Show the "Enable" button if service is disabled
    btn_enable = s:option(Button, "enable", "Enable", "Enable Redsocks service.")
    btn_enable.inputstyle = "apply"
    function btn_enable.write(self, section)
        os.execute("service redsocks enable &")
        
        -- Refresh the page after enabling to reflect the new status
        luci.sys.call("sleep 1")  -- sleep to allow enabling process to complete
        luci.http.redirect(luci.dispatcher.build_url("admin/services/redsocks"))
    end
    
    -- Show the "Disabled" status if service is disabled
    btn_disable = s:option(DummyValue, "disabled", "Disabled")
    btn_disable.rawhtml = true
    btn_disable.default = "<b><span style='color: red;'>Disabled</span></b>"
end

-- Bottom hyperlinks with green color, italic font, H1 size, and Facebook profile links
local footer = s:option(DummyValue, "footer", "")
footer.rawhtml = true
footer.default = "<p style='text-align:center;'><a href='https://www.facebook.com/xapaosha' target='_blank' style='color: green; font-style: italic; font-size: 32px;'>Original Creator of Redsocks File: Md Rabby Sheikh</a></p>"
footer.default = footer.default .. "<p style='text-align:center;'><a href='https://www.facebook.com/ddaduvai' target='_blank' style='color: green; font-style: italic; font-size: 32px;'>Original Creator of Redsocks WebUI: Md Hasan Khan</a></p>"

return m
