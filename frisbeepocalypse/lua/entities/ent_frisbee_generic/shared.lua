AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Frisbee"
ENT.Spawnable = true
ENT.Category = "Frisbeecalypse"
ENT.Author = "Squeed Fingars"
ENT.AdminOnly = false

cleanup.Register("ent_frisbee");

if !ConVarExists("sfad_frisbee_model") then
    CreateConVar("sfad_frisbee_model", "models/props_junk/sawblade001a.mdl", {FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY})
end

if !ConVarExists("sfad_frisbee_max") then
    CreateConVar("sfad_frisbee_max", "500", {FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY})
end

if !ConVarExists("sfad_frisbee_self_collisions") then
    CreateConVar("sfad_frisbee_self_collisions", "1", {FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY})
end

if !ConVarExists("sfad_frisbee_rift_frisbeeinate") then
    CreateConVar("sfad_frisbee_rift_frisbeeinate", "1", {FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY})
end

if !SERVER then return end
net.Receive("sfad_frisbee_model", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("sfad_frisbee_model", net.ReadString())
	end
end)

net.Receive("sfad_frisbee_max", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("sfad_frisbee_max", net.ReadFloat())
	end
end)

net.Receive("sfad_frisbee_self_collisions", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("sfad_frisbee_self_collisions", net.ReadFloat())
	end
end)

net.Receive("sfad_frisbee_rift_frisbeeinate", function(len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("sfad_frisbee_rift_frisbeeinate", net.ReadFloat())
	end
end)


net.Receive("SFAD_FRISBEE_RESET_BUTTON", function(Len,ply)
	if ply:IsValid() and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand("sfad_frisbee_model", "models/props_junk/sawblade001a.mdl");
		RunConsoleCommand("sfad_frisbee_max", "500");
		RunConsoleCommand("sfad_frisbee_self_collisions", "1");
		RunConsoleCommand("sfad_frisbee_rift_frisbeeinate", "1");

	end
end)