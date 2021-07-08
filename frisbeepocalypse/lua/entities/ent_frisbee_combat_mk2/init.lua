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
	self:SetMaterial("models/XQM/LightLinesRed_tool")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetFriction(0)
	self:SetColor(Color(200,200,200))
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(100);
		phys:SetMaterial("models/XQM/LightLinesRed_tool")
		phys:EnableDrag(false)
		if (!GetConVar("sfad_frisbee_self_collisions"):GetBool()) then self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS) end
	end
	self:SetHealth(250);
	self.sfad_rainbow_frisbee = false;
	self:SetUseType(SIMPLE_USE);
	self.sfad_evil_frisbee = false;
	self.sfad_frisbee_invisible = true;
	self.sfad_frisbee_chase_timer = 25;
	self.sfad_stop_beeping = false;
	local sfad_player = ents.FindByClass("Player");
	cleanup.Add(sfad_player[math.random(1,#sfad_player)],"ent_frisbee",self)
end

function ENT:Think()
	local sfad_phys = self:GetPhysicsObject();
	if (self.sfad_rainbow_frisbee) then
		self:SetColor(Color(math.random(0,255),math.random(0,255),math.random(0,255)))
	end
	
	if (!self:IsPlayerHolding()) then
		self.sfad_frisbee_chase_timer = self.sfad_frisbee_chase_timer - 1;
	end
	if (self.sfad_frisbee_invisible and (self.sfad_frisbee_chase_timer <= 0)) then
		self.sfad_frisbee_chase_timer = math.ceil(math.random(10,30));
		local sfad_close_objects_list = ents.FindInSphere(sfad_phys:GetPos(),400);
		local sfad_chase_target = sfad_close_objects_list[math.random(1,#sfad_close_objects_list)];
		if (IsValid(sfad_chase_target) and !sfad_chase_target:IsWorld() and (sfad_chase_target ~= self)) then
			sfad_phys:ApplyForceCenter((sfad_chase_target:GetPos()-self:GetPos()):GetNormal()*sfad_phys:GetMass()*500)
			if (self:GetPos().z < sfad_chase_target:GetPos().z + 30) then
				sfad_phys:ApplyForceCenter(Vector(0,0,500*sfad_phys:GetMass()))
			end

		end


	elseif (self.sfad_frisbee_chase_timer > 0) and (self.sfad_frisbee_invisible) and !self.sfad_stop_beeping then
		sound.Play("hl1/fvox/beep.wav",self:GetPos(),72,100 - 2*self.sfad_frisbee_chase_timer,1)
	end

	if (self:WaterLevel() > 2) then self:TakeDamage(2,self,self) end
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
	if (dmg:GetDamageType() == DMG_CRUSH) then return end
	self:GetPhysicsObject():ApplyForceOffset(dmg:GetDamageForce(),dmg:GetDamagePosition());
	self:SetHealth(self:Health() - dmg:GetDamage());
	if (self:Health() <= 0) then
		sound.Play("hl1/fvox/beep.wav",self:GetPos(),75,40,1)
		self:Remove();
	end
end


function ENT:PhysicsUpdate()
	local sfad_frisbee_physobj = self:GetPhysicsObject();
	if (IsValid(sfad_frisbee_physobj)) then
		local sfad_frisbee_velocity = sfad_frisbee_physobj:GetVelocity();
		local sfad_frisbee_angle = sfad_frisbee_physobj:GetAngles();
		local sfad_frisbee_angular_velocity = sfad_frisbee_physobj:GetAngleVelocity();
		sfad_frisbee_physobj:SetVelocityInstantaneous(Vector(sfad_frisbee_velocity.x*1.0025,sfad_frisbee_velocity.y*1.0025,sfad_frisbee_z_vector_equation(sfad_frisbee_velocity,sfad_frisbee_angle)));
	end
end