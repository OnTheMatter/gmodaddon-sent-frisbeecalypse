AddCSLuaFile("shared.lua")

include("shared.lua")

local function sfad_frisbee_frisbeeinate(myself,sfad_iteration)
	local sfad_local_victims = ents.FindInSphere(myself:GetPos(),320 + sfad_iteration * 64);
	for sfad_i = 1, #sfad_local_victims,1 do
		if ((sfad_local_victims[sfad_i] and IsValid(sfad_local_victims[sfad_i]) and !sfad_local_victims[sfad_i]:IsWorld() and (sfad_local_victims[sfad_i] ~= myself)) and (sfad_local_victims[sfad_i]:IsPlayer() or sfad_local_victims[sfad_i]:IsNPC() or (string.find(sfad_local_victims[sfad_i]:GetClass(),"prop_physics") ~= nil) or (string.find(sfad_local_victims[sfad_i]:GetClass(),"prop_ragdoll") ~= nil))) then
			
			if (sfad_local_victims[sfad_i]:IsNPC() or sfad_local_victims[sfad_i]:IsPlayer()) then
				if (sfad_local_victims[sfad_i]:Health() > 0) then
					local sfad_fs = ents.Create("ent_frisbee_sentient")
					sfad_fs:SetPos(sfad_local_victims[sfad_i]:GetPos() + Vector(0,0,5));
					sfad_fs:SetAngles(sfad_local_victims[sfad_i]:GetAngles());
					sfad_fs:Spawn();
					sfad_fs:GetPhysicsObject():SetVelocityInstantaneous(Vector(math.random(-50,50),math.random(-50,50),math.random(-50,50))*sfad_fs:GetPhysicsObject():GetMass())
					if (sfad_local_victims[sfad_i]:IsPlayer()) then sfad_local_victims[sfad_i]:KillSilent() else sfad_local_victims[sfad_i]:Remove() end;
				end
			else
				local sfad_fg = ents.Create("ent_frisbee_generic")
				sfad_fg:SetPos(sfad_local_victims[sfad_i]:GetPos() + Vector(0,0,5));
				sfad_fg:SetAngles(sfad_local_victims[sfad_i]:GetAngles());
				sfad_fg:Spawn();
				sfad_fg:GetPhysicsObject():SetVelocityInstantaneous(Vector(math.random(-50,50),math.random(-50,50),math.random(-50,50))*sfad_fg:GetPhysicsObject():GetMass())
				sfad_local_victims[sfad_i]:Remove();
			end

			local sfad_part = EffectData();
			sfad_part:SetOrigin(sfad_local_victims[sfad_i]:GetPos() + Vector(0,0,5));
			sfad_part:SetStart(sfad_local_victims[sfad_i]:GetPos() + Vector(0,0,5))
			sfad_part:SetMagnitude(math.random(80,120));
			sfad_part:SetScale(math.random(4,6));
			util.Effect("VortDispel",sfad_part);
		else
			if (IsValid(sfad_local_victims[sfad_i]:GetPhysicsObject())) then
				sfad_local_victims[sfad_i]:GetPhysicsObject():ApplyForceCenter(Vector(math.random(-500,500),math.random(-500,500),math.random(-500,500)) * sfad_local_victims[sfad_i]:GetPhysicsObject():GetMass());
			end
		end
		--print(sfad_local_victims[sfad_i]:GetClass());
	end
	local sfad_part = EffectData();
	sfad_part:SetOrigin(myself:GetPos());
	sfad_part:SetStart(myself:GetPos())
	sfad_part:SetScale(4);
	util.Effect("HelicopterMegaBomb",sfad_part);
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
	self:SetMaterial("phoenix_storms/stripes")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetFriction(0)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(60);
		phys:SetMaterial("phoenix_storms/stripes")
		phys:EnableDrag(false)
		if (!GetConVar("sfad_frisbee_self_collisions"):GetBool()) then self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS) end
	end
	self.sfad_rainbow_frisbee = false;
	self:SetUseType(SIMPLE_USE);
	self.sfad_frisbee_held = false;
	self.sfad_evil_frisbee = false;
	self.sfad_activated = false;
	self.sfad_activated_timer = 5;
	self.sfad_boomed = false;
	local sfad_player = ents.FindByClass("Player");
	cleanup.Add(sfad_player[math.random(1,#sfad_player)],"ent_frisbee",self)
end

function ENT:StartTouch(ent)
	if (ent:IsValid() and !ent:IsWorld()) then
		if (!self:IsPlayerHolding() and self.sfad_activated) then
			sfad_frisbee_frisbeeinate(self,math.random(4,10));
			sound.Play("weapons/mortar/mortar_explode2.wav",self:GetPos(),87,90,1)
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
			sound.Play("hl1/fvox/beep.wav",self:GetPos(),75,65,1)
			self.sfad_activated_timer = 5
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
		sfad_frisbee_frisbeeinate(self,math.random(4,10));
		sound.Play("weapons/mortar/mortar_explode2.wav",self:GetPos(),87,90,1)
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