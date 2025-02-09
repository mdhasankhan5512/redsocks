module("luci.controller.redsocks", package.seeall)

function index()
    entry({"admin", "services", "redsocks"}, cbi("redsocks"), "Redsocks Config", 10).dependent = true
end
