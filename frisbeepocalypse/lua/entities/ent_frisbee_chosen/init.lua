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
	self:SetMaterial("models/wireframe")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetFriction(0)
	self:SetColor(Color(math.random(128,255),math.random(0,128),math.random(0,128)))
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(100);
		phys:SetMaterial("models/wireframe")
		phys:EnableGravity(false);
		phys:EnableDrag(false)
		if (!GetConVar("sfad_frisbee_self_collisions"):GetBool()) then self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS) end
	end
	self:SetHealth(50)
	self.sfad_rainbow_frisbee = false;
	if (math.random(0,1000) > 999) then
		self.sfad_rainbow_frisbee = true;
	end
	self:SetUseType(SIMPLE_USE);
	self.sfad_evil_frisbee = false;
	self.sfad_gender = math.Round(math.random(0,1));
	self.sfad_move_timer = math.Round(math.random(4,12));
	self.sfad_teleport_range = math.random(50,100);
	local sfad_player = ents.FindByClass("Player");
	cleanup.Add(sfad_player[math.random(1,#sfad_player)],"ent_frisbee",self)
end

function ENT:Think()
	if (self.sfad_rainbow_frisbee) then
		self:SetColor(Color(math.random(128,255),math.random(0,128),math.random(0,128)))
	end

	local sfad_phys = self:GetPhysicsObject();
	if (IsValid(sfad_phys)) then
		sfad_phys:AddAngleVelocity(Vector(math.random(-1,1),math.random(-1,1),math.random(-1,1))*2);
		
		self.sfad_move_timer = self.sfad_move_timer - 1;
		if (self:IsPlayerHolding()) then self.sfad_move_timer = 10 end
		if (self.sfad_move_timer <= 0) then
			self.sfad_move_timer = math.Round(math.random(4,12));
			local sfad_original_pos = self:GetPos();
			local sfad_original_vel = self:GetVelocity();
			self:SetPos(self:GetPos() + Vector(math.random(-self.sfad_teleport_range,self.sfad_teleport_range),math.random(-self.sfad_teleport_range,self.sfad_teleport_range),math.random(-self.sfad_teleport_range,self.sfad_teleport_range*0.75)))
			if (!self:IsInWorld()) then
				self:SetPos(sfad_original_pos);
			end
			self:GetPhysicsObject():SetVelocity(sfad_original_vel * Vector(1,1,0.1));
		end
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

function ENT:StartTouch(ent)
	if ((ent and IsValid(ent) and !ent:IsWorld() and (ent ~= self)) and (ent:IsPlayer() or ent:IsNPC() or ent:IsVehicle() or (string.find(ent:GetClass(),"prop_physics") ~= nil) or (string.find(ent:GetClass(),"prop_ragdoll") ~= nil))) then
		if (ent:IsNPC() or ent:IsPlayer()) then
			if (ent:Health() > 0) then
				local sfad_fg = ents.Create("ent_frisbee_chosen")
				sfad_fg:SetPos(ent:GetPos() + Vector(0,0,8));
				sfad_fg:Spawn();
				sfad_fg:GetPhysicsObject():SetVelocityInstantaneous(Vector(math.random(-5,5),math.random(-5,5),math.random(-5,5))*sfad_fg:GetPhysicsObject():GetMass())
				if (ent:IsPlayer()) then ent:KillSilent() else ent:Remove() end;
			end
		else
			local sfad_fg = ents.Create("ent_frisbee_chosen")
			sfad_fg:SetPos(ent:GetPos() + Vector(0,0,8));
			sfad_fg:Spawn();
			sfad_fg:GetPhysicsObject():SetVelocityInstantaneous(Vector(math.random(-5,5),math.random(-5,5),math.random(-5,5))*sfad_fg:GetPhysicsObject():GetMass())
			ent:Remove();
		end
	else
		if (IsValid(ent:GetColor())) then
			ent:SetColor(Color(math.random(0,255),math.random(0,255),math.random(0,255)));
		end
	end
end

function ENT:PhysicsUpdate()
	local sfad_frisbee_physobj = self:GetPhysicsObject();
	if (IsValid(sfad_frisbee_physobj)) then
		--sfad_frisbee_physobj:SetVelocity(Vector(math.Clamp(sfad_frisbee_physobj:GetVelocity().x,-100,100),math.Clamp(sfad_frisbee_physobj:GetVelocity().y,-100,100),math.Clamp(sfad_frisbee_physobj:GetVelocity().z,-100,100)))
		local sfad_frisbee_velocity = sfad_frisbee_physobj:GetVelocity();
		local sfad_frisbee_angle = sfad_frisbee_physobj:GetAngles();
		local sfad_frisbee_angular_velocity = sfad_frisbee_physobj:GetAngleVelocity();
		sfad_frisbee_physobj:SetVelocityInstantaneous(Vector(sfad_frisbee_velocity.x,sfad_frisbee_velocity.y,sfad_frisbee_z_vector_equation(sfad_frisbee_velocity,sfad_frisbee_angle)));
	end
end