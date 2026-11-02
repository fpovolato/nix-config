-- Workspace rules. See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- Workspaces 1-5 live on the LG main monitor (DP-2), 6-9 on the ultrawide
-- (DP-3). They are persistent so the Quickshell bar always lists them.

for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "DP-2", default = i == 1, persistent = true })
end

for i = 6, 9 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "DP-3", default = i == 6, persistent = true })
end
