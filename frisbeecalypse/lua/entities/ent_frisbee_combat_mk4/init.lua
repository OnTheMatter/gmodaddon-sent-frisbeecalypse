AddCSLuaFile("shared.lua")

include("shared.lua")

local function sfad_frisbee_frisbeeinate2(myself,sfad_iteration)
	local sfad_local_victims = ents.FindInSphere(myself:GetPos(),128 + sfad_iteration * 64);
	for sfad_i = 1, #sfad_local_victims,1 do
		if ((sfad_local_victims[sfad_i] and IsValid(sfad_local_victims[sfad_i]) and !sfad_local_victims[sfad_i]:IsWorld() and (sfad_local_victims[sfad_i] ~= myself)) and (sfad_local_victims[sfad_i]:IsPlayer() or sfad_local_victims[sfad_i]:IsNPC() or (string.find(sfad_local_victims[sfad_i]:GetClass(),"prop_physics") ~= nil) or (string.find(sfad_local_victims[sfad_i]:GetClass(),"prop_ragdoll") ~= nil))) then
			
			if (sfad_local_victims[sfad_i]:IsNPC() or sfad_local_victims[sfad_i]:IsPlayer()) then
				if (sfad_local_victims[sfad_i]:Health() > 0) then
					local sfad_fs = ents.Create("ent_frisbee_combat_mk4")
					sfad_fs:SetPos(sfad_local_victims[sfad_i]:GetPos() + Vector(0,0,5));
					sfad_fs:SetAngles(sfad_local_victims[sfad_i]:GetAngles());
					sfad_fs:Spawn();
					sfad_fs:GetPhysicsObject():SetVelocityInstantaneous(Vector(math.random(-500,500),math.random(-500,500),math.random(-50,50))*sfad_fs:GetPhysicsObject():GetMass())
					if (sfad_local_victims[sfad_i]:IsPlayer()) then sfad_local_victims[sfad_i]:KillSilent() else sfad_local_victims[sfad_i]:Remove() end;
					sfad_fs.sfad_frisbee_soul_count = 2;
					myself.sfad_frisbee_soul_count = 1 + myself.sfad_frisbee_soul_count;
				end
			else
				local sfad_fg = ents.Create("ent_frisbee_combat_mk3")
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
	self:SetMaterial("models/debug/debugwhite")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetFriction(0)
	self:SetColor(Color(200,200,200))
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(1000);
		phys:SetMaterial("phoenix_storms/metalfloor_2-3")
		phys:EnableDrag(false)
		//if (!GetConVar("sfad_frisbee_self_collisions"):GetBool()) then self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS) end
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS);
	end
	self:SetHealth(9999999);
	self.sfad_rainbow_frisbee = true;
	self:SetUseType(SIMPLE_USE);
	self.sfad_evil_frisbee = false;
	self.sfad_frisbee_soul_count = 1;
	self.sfad_frisbee_invisible = true;
	self.sfad_frisbee_chase_timer = 3;
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
	if (self.sfad_frisbee_invisible and (self.sfad_frisbee_chase_timer <= 0))  then
		self.sfad_frisbee_chase_timer = math.ceil(math.random(2,4));
		local sfad_close_objects_list = ents.FindInSphere(sfad_phys:GetPos(),640);
		local sfad_chase_target = sfad_close_objects_list[math.random(1,#sfad_close_objects_list)];
		if (IsValid(sfad_chase_target) and !sfad_chase_target:IsWorld() and (sfad_chase_target ~= self)) then
			sfad_phys:SetVelocityInstantaneous(Vector(0,0,0));
			sfad_frisbee_explode(self);
			sfad_frisbee_frisbeeinate2(self,1);
			sfad_phys:ApplyForceCenter((sfad_chase_target:GetPos()-self:GetPos()):GetNormal()*sfad_phys:GetMass()*45000)
			if (self:GetPos().z < sfad_chase_target:GetPos().z + 30) then
				sfad_phys:ApplyForceCenter(Vector(0,0,500*sfad_phys:GetMass()))
			end

		end


	elseif (self.sfad_frisbee_chase_timer > 0) and (self.sfad_frisbee_invisible) and !self.sfad_stop_beeping then
		sound.Play("vo/ravenholm/madlaugh01.wav",self:GetPos(),72,100 - 5*self.sfad_frisbee_chase_timer,1)
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
	if (IsValid(dmg:GetAttacker()) and dmg:GetAttacker():GetClass() == self:GetClass()) then return end
	self:SetHealth(self:Health() - dmg:GetDamage());
	self:GetPhysicsObject():ApplyForceOffset(dmg:GetDamageForce(),dmg:GetDamagePosition());
	if (IsValid(dmg:GetAttacker())) and (dmg:GetAttacker():IsPlayer() or dmg:GetAttacker():IsNPC()) then
		self:SetPos(dmg:GetAttacker():GetPos() + Vector(0,0,16));
		util.BlastDamage(self,self,self:GetPos(),128,999999999)
		local sfad_boom_data = EffectData()
		sfad_boom_data:SetOrigin(self:GetPos())
		util.Effect( "Explosion", sfad_boom_data )
		self.sfad_frisbee_soul_count = self.sfad_frisbee_soul_count + 1;
	end

	if (self:Health() <= 0) then
		self:Remove();
	end
end

function ENT:PhysicsUpdate()
	local sfad_frisbee_physobj = self:GetPhysicsObject();
	if (IsValid(sfad_frisbee_physobj)) then
		local sfad_frisbee_velocity = sfad_frisbee_physobj:GetVelocity();
		local sfad_frisbee_angle = sfad_frisbee_physobj:GetAngles();
		local sfad_frisbee_mass = sfad_frisbee_physobj:GetMass();
		local sfad_frisbee_angular_velocity = sfad_frisbee_physobj:GetAngleVelocity();
		sfad_frisbee_physobj:SetVelocityInstantaneous(Vector(sfad_frisbee_velocity.x + self.sfad_frisbee_soul_count*math.random(-sfad_frisbee_mass,sfad_frisbee_mass),sfad_frisbee_velocity.y + self.sfad_frisbee_soul_count*math.random(-sfad_frisbee_mass,sfad_frisbee_mass),sfad_frisbee_z_vector_equation(sfad_frisbee_velocity,sfad_frisbee_angle) + math.random(0,sfad_frisbee_mass * 0.01)));
	end
end