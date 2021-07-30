AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("sfad_frisbee_model");
util.AddNetworkString("sfad_frisbee_max");
util.AddNetworkString("sfad_frisbee_self_collisions");
util.AddNetworkString("sfad_frisbee_rift_frisbeeinate")
util.AddNetworkString("SFAD_FRISBEE_RESET_BUTTON");

function sfad_frisbee_z_vector_equation(sfad_vector,sfad_angle)
	return sfad_vector.z*(1+math.min(-math.min(math.abs(sfad_vector.x/500),0.05)-math.min(math.abs(sfad_vector.y/500),0.05),0.1));
end

function ENT:SpawnFunction(ply,trace,classname)
	if (!trace.Hit) then return end

    local sfad_frisbee_spawn = ents.Create(classname);

    if (!sfad_frisbee_spawn:IsValid()) then return; end
    sfad_frisbee_spawn:SetModel(GetConVar("sfad_frisbee_model"):GetString());
	if (!util.IsValidProp(sfad_frisbee_spawn:GetModel())) then
		sfad_frisbee_spawn:SetModel("models/props_junk/sawblade001a.mdl")
	end
    local min, max = sfad_frisbee_spawn:GetModelBounds();
    local center = max - min;
    center = center + (center / 2);

    sfad_frisbee_spawn:SetPos(trace.HitPos + trace.HitNormal * center:Length() / 4);
    sfad_frisbee_spawn:Spawn();
    sfad_frisbee_spawn:Activate();
    sfad_frisbee_spawn.OriginPlayer = ply;
    
    ply:AddCleanup("ent_frisbee", sfad_frisbee_spawn);

    return sfad_frisbee_spawn;
end

function ENT:Initialize()
	if (#ents.FindByClass("ent_frisbee*") > GetConVar("sfad_frisbee_max"):GetInt()) then self:Remove() end
	self:SetModel(GetConVar("sfad_frisbee_model"):GetString());
	if (!util.IsValidProp(self:GetModel())) then
		self:SetModel("models/props_junk/sawblade001a.mdl")
	end
	self:SetMaterial("phoenix_storms/wood")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetFriction(0)
	self:SetColor(Color(math.random(0,255),math.random(0,255),math.random(0,255)))
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(5);
		phys:SetMaterial("phoenix_storms/wood")
		phys:EnableDrag(false)
		if (!GetConVar("sfad_frisbee_self_collisions"):GetBool()) then self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS) end
	end
	self:SetHealth(150);
	self.sfad_rainbow_frisbee = false;
	if (math.random(0,1000) > 999) then
		self.sfad_rainbow_frisbee = true;
	end
	self:SetUseType(SIMPLE_USE);
	self.sfad_evil_frisbee = false;
	local sfad_player = ents.FindByClass("Player");
	cleanup.Add(sfad_player[math.random(1,#sfad_player)],"ent_frisbee",self)
end

function ENT:Think()
	if (self.sfad_rainbow_frisbee) then
		self:SetColor(Color(math.random(0,255),math.random(0,255),math.random(0,255)))
	end
end

function ENT:GravGunPickupAllowed(ply)
	return true;
end

function ENT:Use( activator, caller, useType, value )
	if (activator:IsPlayer() and !self:GetPhysicsObject():IsAsleep()) then
		activator:PickupObject(self);
	end
end

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage());
	self:GetPhysicsObject():ApplyForceOffset(dmg:GetDamageForce(),dmg:GetDamagePosition());
	if (self:Health() <= 0) then
		self:Remove();
	end
end

function ENT:PhysicsUpdate()
	local sfad_frisbee_physobj = self:GetPhysicsObject();
	if (IsValid(sfad_frisbee_physobj)) then
		local sfad_frisbee_velocity = sfad_frisbee_physobj:GetVelocity();
		local sfad_frisbee_angle = sfad_frisbee_physobj:GetAngles();
		local sfad_frisbee_angular_velocity = sfad_frisbee_physobj:GetAngleVelocity();
		sfad_frisbee_physobj:SetVelocityInstantaneous(Vector(sfad_frisbee_velocity.x,sfad_frisbee_velocity.y,sfad_frisbee_z_vector_equation(sfad_frisbee_velocity,sfad_frisbee_angle)));
	end
end