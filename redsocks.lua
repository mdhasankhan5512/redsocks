local m, s, btn_start, btn_stop, btn_restart, btn_disable, btn_enable, btn_update, status

m = Map("redsocks", "Redsocks Configuration", "After saving and applying config click the button Click TO Update Redsocks Config to update the config")

s = m:section(TypedSection, "redsocks", "Redsocks Proxy")
s.addremove = false
s.anonymous = true

local instruction = s:option(DummyValue, "instruction", "")
instruction.rawhtml = true
instruction.default = "<h1 style='color: green; font-weight: bold;'>After saving and applying config, click the button below <i>Update Redsocks Config</i> to update the redsocks config in the file and then run it</h1>"

-- Redsocks status button at the top
status = s:option(DummyValue, "_status", "Redsocks Status")
status.rawhtml = true
status.size = "large" -- Increase font size
function status.cfgvalue(self, section)
    local handle = io.popen([[if [ -e /var/run/redsocks.pid ]; then echo "redsocks is already running"; else echo "redsocks is not running"; fi]])
    local result = handle:read("*all")
    handle:close()

    if result:match("redsocks is already running") then
        return "<b><span style='color: green; font-size: 20px;'>Running</span></b>"
    else
        return "<b><span style='color: red; font-size: 20px;'>Stopped</span></b>"
    end
end

-- Server Address, Port
s:option(Value, "host", "Server Address").datatype = "ipaddr"
s:option(Value, "port", "Server Port").datatype = "port"

-- Authentication checkbox
local enable_auth = s:option(Flag, "authentication", "Enable Authentication", "Check this box to enable authentication for Redsocks.")
enable_auth.default = 0  -- Disabled by default

-- Username and Password fields, initially hidden
local username = s:option(Value, "username", "Username")
username:depends("authentication", 1)  -- Show when authentication is enabled
username.hidden = true  -- Initially hidden

local password = s:option(Value, "password", "Password")
password.password = true
password:depends("authentication", 1)  -- Show when authentication is enabled
password.hidden = true  -- Initially hidden

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

-- Add Update Redsocks button
btn_update = s:option(Button, "update", "Update Redsocks Config", "Click to update Redsocks configuration.")
btn_update.inputstyle = "apply"
function btn_update.write(self, section)
    os.execute("sh /root/update_redsocks.sh &")
    luci.sys.call("sleep 1")
    luci.http.redirect(luci.dispatcher.build_url("admin/services/redsocks"))
end
-- Add instruction text with green color, bold, H1 size

-- Bottom hyperlinks with green color, italic font, H1 size, and Facebook profile links
local footer = s:option(DummyValue, "footer", "")
footer.rawhtml = true
footer.default = "<p style='text-align:center;'><a href='https://www.facebook.com/xapaosha' target='_blank' style='color: green; font-style: italic; font-size: 32px;'>Original Creator of Redsocks File: Md Rabby Sheikh</a></p>"
footer.default = footer.default .. "<p style='text-align:center;'><a href='https://www.facebook.com/ddaduvai' target='_blank' style='color: green; font-style: italic; font-size: 32px;'>Original Creator of Redsocks WebUI: Md Hasan Khan</a></p>"

return m
