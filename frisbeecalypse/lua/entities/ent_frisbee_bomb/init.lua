AddCSLuaFile("shared.lua")

include("shared.lua")

function sfad_frisbee_explode(ent)
	util.BlastDamage(ent,ent,ent:GetPos(),128,math.random(50,100))
	local sfad_boom_data = EffectData()
	sfad_boom_data:SetOrigin(ent:GetPos())
	util.Effect( "Explosion", sfad_boom_data )
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
	if (#ents.FindByClass("ent_frisbee*") > GetConVar("sfad_frisbee_max"):GetInt()) and (GetConVar("sfad_frisbee_max"):GetInt() ~= -1) then self:Remove() end
	self:SetModel(GetConVar("sfad_frisbee_model"):GetString());
	if (!util.IsValidProp(self:GetModel())) then
		self:SetModel("models/props_junk/sawblade001a.mdl")
	end
	self:SetMaterial("phoenix_storms/metalset_1-2")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetFriction(0)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(20);
		phys:SetMaterial("phoenix_storms/metalset_1-2")
		phys:EnableDrag(false)
		if (!GetConVar("sfad_frisbee_self_collisions"):GetBool()) then self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS) end
	end
	self.sfad_rainbow_frisbee = false;
	self:SetUseType(SIMPLE_USE);
	self.sfad_frisbee_held = false;
	self.sfad_evil_frisbee = false;
	self.sfad_activated = false;
	self.sfad_activated_timer = 2;
	self.sfad_boomed = false;
	local sfad_player = ents.FindByClass("Player");
	cleanup.Add(sfad_player[math.random(1,#sfad_player)],"ent_frisbee",self)
end

function ENT:StartTouch(ent)
	if (ent:IsValid() and !ent:IsWorld()) then
		if (!self:IsPlayerHolding() and self.sfad_activated) then
			sfad_frisbee_explode(self);
			self:Remove();
		end
	end
end

function ENT:Think()

	if (!self.sfad_activated and self:IsPlayerHolding()) then
		self.sfad_activated = true;
		sound.Play("buttons/button3.wav",self:GetPos(),75,100,1)
	end

	if (self.sfad_activated) then
		self.sfad_activated_timer = self.sfad_activated_timer - 1;
		if (self.sfad_activated_timer <= 0) then
			sound.Play("hl1/fvox/beep.wav",self:GetPos(),65,100,1)
			self.sfad_activated_timer = 2;
		end
		
	end

	if (self.sfad_rainbow_frisbee) then
		self:SetColor(Color(math.random(0,255),math.random(0,255),math.random(0,255)))
	end

end

function ENT:GravGunPickupAllowed(ply)
	return true;
end

function ENT:OnTakeDamage(dmg)
	self:GetPhysicsObject():ApplyForceOffset(dmg:GetDamageForce()*0.1,dmg:GetDamagePosition());

	if (!self.sfad_activated) then
		self.sfad_activated = true;
		sound.Play("buttons/button3.wav",self:GetPos(),75,100,1)
	elseif(self.sfad_activated and !self.sfad_boomed and (math.random(1,3) >= 2)) then
		self.sfad_boomed = true;
		sfad_frisbee_explode(self);
		self:Remove();
	end

	
end

function ENT:Use( activator, caller, useType, value )
	if (activator:IsPlayer() and !self:GetPhysicsObject():IsAsleep()) then
		activator:PickupObject(self);
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