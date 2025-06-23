-- Define script URL and config folder
local scriptURL = "https://raw.githubusercontent.com/pot0to/pot0to-SND-Scripts/refs/heads/main/Fate%20Farming/Multi%20Zone%20Farming.lua"
local ConfigFolder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\pot0to\\Fate Farming\\"

-- Check if a file exists
local function FileExists(name)
    local file = io.open(name, "r")
    if file then
        io.close(file)
        LogInfo("[SUCCESS] File exists: " .. name)
        return true
    else
        LogInfo("[ERROR] File does not exist: " .. name)
        yield("/echo [ERROR] File does not exist.")
        return false
    end
end

-- Check if a folder exists
local function FolderExists(path)
    local ok, err, code = os.rename(path, path)
    if ok or code == 13 then
        LogInfo("[SUCCESS] Folder exists: " .. path)
        return true
    else
        LogInfo("[ERROR] Error checking folder existence: " .. err)
        yield("/echo [ERROR] Error checking folder existence.")
        return false
    end
end

-- Ensure a folder exists, create if it doesn't
local function EnsureFolderExists(folderPath)
    if not FolderExists(folderPath) then
        yield("/echo [ERROR] Script folder does not exists.")
        return false
    end
    return true
end

-- Extract version from script content
local function ExtractVersion(scriptContent)
    return scriptContent:match("%*%s+Version%s[%s]?[%W]?[%s]?[%s]?(%d+.%d+.%d+)%s+%*")
end

-- Check if script version matches required version
local function CheckVersion(scriptContent, requiredVersion)
    local scriptVersion = ExtractVersion(scriptContent)
    if scriptVersion == requiredVersion then
        LogInfo("[SUCCESS] Script version matches required version.")
        yield("/echo [SUCCESS] Script version matches required version.")
        return true
    else
        LogInfo("[ERROR] Script version does not match required version.")
        yield("/echo [ERROR] Script version does not match required version.")
        return false
    end
end

-- Execute a Lua script
local function ExecuteLuaScript(filePath)
    local loadedFunction, errorMessage = loadfile(filePath)
    if loadedFunction then
        loadedFunction()
        LogInfo("[SUCCESS] Script loaded and executed successfully.")
    else
        LogInfo("[ERROR] Error loading script:", errorMessage)
    end
end

-- Execute a script from a URL
local function ExecuteScriptFromURL(url, folderPath)
    local fileName = url:match("[^/]+$"):gsub("%%20", " ")
    local filePath = folderPath .. fileName

    if FileExists(filePath) then
        local file = io.open(filePath, "r")
        if file then
            local scriptContent = file:read("*a")
            file:close()
            local urlScriptContent = io.popen("curl -s " .. url):read("*a")
            if CheckVersion(scriptContent, ExtractVersion(urlScriptContent)) then
                ExecuteLuaScript(filePath)
                return
            end
        else
            LogInfo("[ERROR] Unable to open script file:", filePath)
        end
    else
        LogInfo("[ERROR] Script could not be found.")
    end
end

-- Ensure config folder exists and execute script from URL
if EnsureFolderExists(ConfigFolder) then
    ExecuteScriptFromURL(scriptURL, ConfigFolder)
end