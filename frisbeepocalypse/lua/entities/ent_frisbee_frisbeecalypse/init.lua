AddCSLuaFile("shared.lua")

include("shared.lua")

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
	if (#ents.FindByClass("ent_frisbee*") > GetConVar("sfad_frisbee_max"):GetInt()) and (GetConVar("sfad_frisbee_max"):GetInt() ~= -1) then self:Remove() end
	self:SetModel(GetConVar("sfad_frisbee_model"):GetString());
	if (!util.IsValidProp(self:GetModel())) then
		self:SetModel("models/props_junk/sawblade001a.mdl")
	end
	self:SetMaterial("models/props_combine/tprings_globe")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetFriction(0)
	self:SetColor(Color(200,200,200))
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(100);
		phys:SetMaterial("models/props_combine/tprings_globe")
		phys:EnableDrag(false)
		phys:EnableGravity(false);
		if (!GetConVar("sfad_frisbee_self_collisions"):GetBool()) then self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS) end
	end
	self:SetHealth(250);
	self.sfad_rainbow_frisbee = false;
	self:SetUseType(SIMPLE_USE);
	self.sfad_evil_frisbee = false;
	self.sfad_summon_timer = math.random(5,15);
	self.sfad_output_options = {"ent_frisbee_sentient","ent_frisbee_chosen","ent_frisbee_generic","ent_frisbee_bomb","ent_frisbee_death","ent_frisbee_electrofrisbeenetic","ent_frisbee_combat","ent_frisbee_combat_mk2","ent_frisbee_combat_mk3","ent_frisbee_frisbeecalypse"};
	if (!GetConVar("sfad_frisbee_rift_frisbeeinate"):GetBool()) then table.RemoveByValue(self.sfad_output_options,"ent_frisbee_electrofrisbeenetic") end
	local sfad_player = ents.FindByClass("Player");
	cleanup.Add(sfad_player[math.random(1,#sfad_player)],"ent_frisbee",self)
end

function ENT:Think()
	if (self.sfad_rainbow_frisbee) then
		self:SetColor(Color(math.random(0,255),math.random(0,255),math.random(0,255)))
	end

	self.sfad_summon_timer = self.sfad_summon_timer - 1;
	if (self.sfad_summon_timer <= 0) then
		self.sfad_summon_timer = math.random(1,7);
		local sfad_portal_output = ents.Create(self.sfad_output_options[math.random(1,#self.sfad_output_options)]);
		sfad_portal_output:SetPos(self:GetPos() + Vector(math.random(-50,50),math.random(-50,50),math.random(-50,50)));
		sfad_portal_output:Spawn();
		sfad_portal_output:SetHealth(1);
		sfad_portal_output.sfad_activated = true;
		if (sfad_portal_output:GetClass() == "ent_frisbee_frisbeecalypse") then table.RemoveByValue(sfad_portal_output.sfad_output_options,"ent_frisbee_frisbeecalypse") end
		if (!sfad_portal_output:IsInWorld()) then sfad_portal_output:Remove() end
		sfad_portal_output:GetPhysicsObject():ApplyForceCenter(Vector(math.random(-500,500),math.random(-500,500),math.random(-50,50)) * sfad_portal_output:GetPhysicsObject():GetMass());
		constraint.NoCollide(self,sfad_portal_output,0,0);
	end
end

function ENT:GravGunPickupAllowed(ply)
	return true;
end

function ENT:Use( activator, caller, useType, value )
	if (activator:IsPlayer() and !self:GetPhysicsObject():IsAsleep()) then
		local sfad_output_options_use = {"ent_frisbee_sentient","ent_frisbee_generic","ent_frisbee_combat","ent_frisbee_chosen"};
		local sfad_portal_output = ents.Create(sfad_output_options_use[math.random(1,#sfad_output_options_use)]);
		sfad_portal_output:SetPos(self:GetPos());
		sfad_portal_output:Spawn();
		constraint.NoCollide(self,sfad_portal_output,0,0);
		activator:PickupObject(sfad_portal_output);
	end
end

function ENT:OnTakeDamage(dmg)
	dmg:SetDamage(math.log(dmg:GetDamage(),2));
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
		sfad_frisbee_physobj:SetVelocityInstantaneous(Vector(sfad_frisbee_velocity.x * 0.99,sfad_frisbee_velocity.y * 0.99,sfad_frisbee_z_vector_equation(sfad_frisbee_velocity,sfad_frisbee_angle)));
	end
end