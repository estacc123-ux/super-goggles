local function printArguments(...)
    local args = {...}
    print("┌── Arguments ───────────────────────────────────────────────────────")
    for i, arg in ipairs(args) do
        print(string.format("│ Argument %d: %s", i, tostring(arg)))
    end
    print("└────────────────────────────────────────────────────────────────────")
end

local function printRemoteCall(remoteType, remoteName, printFunc)
    printFunc("┌────────────────────────────────────────────────────────────────────")
    printFunc(string.format("│ %s fired: %s", remoteType, remoteName))
    printFunc("└────────────────────────────────────────────────────────────────────")
end

local function wrapRemote(remote)
    if remote:IsA("RemoteEvent") then
        remote.OnClientEvent:Connect(function(...)
            printRemoteCall("RemoteEvent", remote.Name, warn)
            printArguments(...)
        end)
        print(string.format("Successfully wrapped RemoteEvent: %s", remote.Name))
    elseif remote:IsA("RemoteFunction") then
        remote.OnClientInvoke = function(...)
            printRemoteCall("RemoteFunction", remote.Name, error)
            printArguments(...)
        end
        print(string.format("Successfully wrapped RemoteFunction: %s", remote.Name))
    else
        warn(string.format("Attempted to wrap an unknown remote type: %s", remote.ClassName))
    end
end

local function bruhhh(folder)
    if not folder then
        warn("Attempted to wrap remotes in an invalid or missing folder")
        return
    end

    local success, err = pcall(function()
        for _, obj in ipairs(folder:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                wrapRemote(obj)
            end
        end
        folder.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") then
                wrapRemote(descendant)
            end
        end)
    end)

    if success then
        print("Successfully wrapped remotes in a folder: " .. folder:GetFullName())
    else
        error("Error wrapping remotes in a folder: " .. folder:GetFullName() .. " - " .. err)
    end
end

local function rw()
    local foldersToMonitor = {
        game:FindFirstChild("ReplicatedStorage"),
        game:FindFirstChild("StarterGui"),
        game:FindFirstChild("StarterPack"),
        game:FindFirstChild("StarterPlayer"),
        game:FindFirstChild("Workspace"),
        game:FindFirstChild("Lighting"),
        game:FindFirstChild("ServerScriptService"),
        game:FindFirstChild("ServerStorage")
    }

    for _, folder in ipairs(foldersToMonitor) do
        bruhhh(folder)
        if folder then
            folder.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") then
                    wrapRemote(descendant)
                end
            end)
        end
    end

    print("Remote wrapping for the these folders:")
    for _, folder in ipairs(foldersToMonitor) do
        if folder then
            print(" - " .. folder:GetFullName())
        else
            warn(" - Invalid or missing folder")
        end
    end
end

rw()
