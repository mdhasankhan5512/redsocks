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

-- Add JavaScript code to toggle the visibility of username and password fields based on the checkbox status
m.on_init = function(self)
    local js_code = [[
        <script type="text/javascript">
            document.addEventListener("DOMContentLoaded", function() {
                var authCheckbox = document.querySelector('input[name="authentication"]');
                var usernameField = document.querySelector('input[name="username"]');
                var passwordField = document.querySelector('input[name="password"]');
                
                // Function to toggle the visibility of fields based on checkbox status
                authCheckbox.addEventListener('change', function() {
                    if (this.checked) {
                        usernameField.closest("tr").style.display = "";
                        passwordField.closest("tr").style.display = "";
                    } else {
                        usernameField.closest("tr").style.display = "none";
                        passwordField.closest("tr").style.display = "none";
                    }
                });
                
                // Trigger the change event on page load to set initial visibility
                authCheckbox.dispatchEvent(new Event('change'));
            });
        </script>
    ]]

    luci.http.write(js_code)
end

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

-- Add Update Redsocks button
btn_update = s:option(Button, "update", "Update Redsocks Config", "Click to update Redsocks configuration.")
btn_update.inputstyle = "apply"
function btn_update.write(self, section)
    os.execute("sh /root/update_redsocks.sh &")
    
    -- Optionally refresh the page after executing the script
    luci.sys.call("sleep 1")  -- sleep to allow update process to complete
    luci.http.redirect(luci.dispatcher.build_url("admin/services/redsocks"))
end

-- Add instruction text with green color, bold, H1 size

-- Bottom hyperlinks with green color, italic font, H1 size, and Facebook profile links
local footer = s:option(DummyValue, "footer", "")
footer.rawhtml = true
footer.default = "<p style='text-align:center;'><a href='https://www.facebook.com/xapaosha' target='_blank' style='color: green; font-style: italic; font-size: 32px;'>Original Creator of Redsocks File: Md Rabby Sheikh</a></p>"
footer.default = footer.default .. "<p style='text-align:center;'><a href='https://www.facebook.com/ddaduvai' target='_blank' style='color: green; font-style: italic; font-size: 32px;'>Original Creator of Redsocks WebUI: Md Hasan Khan</a></p>"

return m
