local http = require("internet")
local fs = require("filesystem")

function webRequest(url)
    -- Returns entire block from request site
    local response = ""
    for chunk in http.request(url) do
        response = response .. chunk
    end

    return response
end

function parseTagName(jsonString)
    -- Pattern to find the tag_name value
    local pattern = '"tag_name":%s*"(.-)"'

    -- Find and return the tag_name
    local start, stop, value = string.find(jsonString,pattern)
    if value then
        return value
    else
        return nil
    end
end

function updateSystem(version)
    -- updates system to provided version
    local file = open("loader.lua","w")
    
    file:write(webRequest(string.format("https://raw.githubusercontent.com/summitninja/mc-lua-test/%s/loader.lua",version)))
    open(".version","w"):write(version)
    print(string.format("Updated system to version %s",version))

end


-- get the latest release
local r = webRequest("https://api.github.com/repos/summitninja/mc-lua-test/releases/latest")

local release = parseTagName(r)
print(string.format("Latest version is: %s",release))


-- Check if latest release was gotten
if release ~= nil then
-- Try to read and compare it to the .version file
    if fs.exists(".version") then
        local version = io.open(".version","r"):read()
        if version == release then
            print(string.format("Running latest version!\n%s",release))
            return
        end
        updateSystem(release)
    else
        updateSystem(release)
    end
else
    print("There was an issue getting the latest version...")
end
