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
	self:SetMaterial("hunter/myplastic")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetFriction(0)
	self:SetColor(Color(120,120,120))
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(15);
		phys:SetMaterial("hunter/myplastic")
		phys:EnableDrag(false)
		if (!GetConVar("sfad_frisbee_self_collisions"):GetBool()) then self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS) end
	end
	self:SetHealth(50);
	self.sfad_rainbow_frisbee = false;
	self:SetUseType(SIMPLE_USE);
	self.sfad_evil_frisbee = false;
	self.sfad_frisbee_active = true;
	local sfad_player = ents.FindByClass("Player");
	cleanup.Add(sfad_player[math.random(1,#sfad_player)],"ent_frisbee",self)
end

function ENT:Think()
	if (self.sfad_rainbow_frisbee) then
		self:SetColor(Color(math.random(0,255),math.random(0,255),math.random(0,255)))
	end
	if (self.sfad_frisbee_active) then
		if (math.random(1,10) < 2) then
			sound.Play("vo/npc/vortigaunt/vortigese02.wav",self:GetPos(),72,100,1)
		end
	end

	if (self:WaterLevel() > 0) then
		sfad_frisbee_explode(self);
		self:TakeDamage(self:Health());
	end

end

function ENT:GravGunPickupAllowed(ply)
	return true;
end

function ENT:Use( activator, caller, useType, value )
	if (activator:IsPlayer() and !self:GetPhysicsObject():IsAsleep()) then
		activator:PickupObject(self);
		self.sfad_frisbee_active = !self.sfad_frisbee_active;
		sound.Play("buttons/button3.wav",self:GetPos(),75,100,1)
	end
end

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage());
	self:GetPhysicsObject():ApplyForceOffset(dmg:GetDamageForce(),dmg:GetDamagePosition());
	self.sfad_frisbee_active = !self.sfad_frisbee_active;
	sound.Play("buttons/button3.wav",self:GetPos(),75,100,1)
	if (self:Health() <= 0) then
		self:Remove();
	end
	
end

function ENT:StartTouch(ent)
	if (ent:IsValid() and !ent:IsWorld()) then
		if (!self:IsPlayerHolding() and self.sfad_frisbee_active) then
			ent:RemoveAllDecals();
		end

		if (ent:GetClass() == "gib") or (ent:GetClass() == "prop_physics" and ent:GetModelRadius() < 7) then
			ent:Remove();
		end
	end
end

function ENT:PhysicsUpdate()
	local sfad_frisbee_physobj = self:GetPhysicsObject();
	if (IsValid(sfad_frisbee_physobj)) then
		local sfad_frisbee_velocity = sfad_frisbee_physobj:GetVelocity();
		local sfad_frisbee_angle = sfad_frisbee_physobj:GetAngles();
		local sfad_frisbee_angular_velocity = sfad_frisbee_physobj:GetAngleVelocity();
		local sfad_frisbee_mass = sfad_frisbee_physobj:GetMass();
		if (self.sfad_frisbee_active) then
			sfad_frisbee_physobj:SetVelocityInstantaneous(Vector(sfad_frisbee_velocity.x + 5*math.random(-sfad_frisbee_mass,sfad_frisbee_mass),sfad_frisbee_velocity.y + 5*math.random(-sfad_frisbee_mass,sfad_frisbee_mass),sfad_frisbee_z_vector_equation(sfad_frisbee_velocity,sfad_frisbee_angle)));
		end
	end
end