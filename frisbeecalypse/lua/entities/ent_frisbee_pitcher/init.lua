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
	self:SetModel("models/props_lab/kennel_physics.mdl");
	self:SetMaterial("phoenix_storms/wire/pcb_blue")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetFriction(0)
	self:SetColor(Color(60,60,60));
	self.inactive_color = Color(60,60,60);
	self.active_color = Color(math.random(0,255),math.random(0,255),math.random(0,255));
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(100);
		phys:SetMaterial("phoenix_storms/wire/pcb_blue")
	end
	self:SetHealth(10000);
	self.pitch_timer = 10;
	self.pitch_time = 20;
	self.pitching = false;
	self:SetUseType(SIMPLE_USE)
	local sfad_player = ents.FindByClass("Player");
	cleanup.Add(sfad_player[math.random(1,#sfad_player)],"ent_frisbee",self)
end

function ENT:Think()
	if (self.pitching) then
		self.pitch_timer = self.pitch_timer - 1;
		if (self.pitch_timer <= 3) then
			sound.Play("hl1/fvox/beep.wav",self:GetPos(),75,100 - 10*self.pitch_timer,1)
		end
		if (self.pitch_timer <= 0) then
			local sfad_big_phys = self:GetPhysicsObject();
			self.pitch_timer = self.pitch_time;
			local sfad_little_frisbee = ents.Create("ent_frisbee_generic");
			sfad_little_frisbee:SetPos(self:GetPos() + Vector(0,0,self:GetModelRadius()))
			local sfad_player_target = player.GetAll()[math.random(1,player.GetCount())];
			sfad_little_frisbee:Spawn();
			if (IsValid(sfad_player_target) and (sfad_player_target:Health() > 0)) then
				sfad_little_frisbee:GetPhysicsObject():ApplyForceCenter((sfad_player_target:GetPos()-sfad_little_frisbee:GetPos()):GetNormal()*sfad_little_frisbee:GetPhysicsObject():GetMass()*math.random(400,550) * Vector(1,1,0))
			else
				sfad_little_frisbee:GetPhysicsObject():ApplyForceCenter(Vector(math.random(-600,600)*sfad_little_frisbee:GetPhysicsObject():GetMass(),math.random(-600,600)*sfad_little_frisbee:GetPhysicsObject():GetMass(),math.random(100,500)*sfad_little_frisbee:GetPhysicsObject():GetMass()))
			end
		end
	end
end

function ENT:GravGunPickupAllowed(ply)
	return true;
end

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage());
	self:GetPhysicsObject():ApplyForceOffset(dmg:GetDamageForce(),dmg:GetDamagePosition());
	if (self:Health() <= 0) then
		self:Remove();
	end
end

function ENT:Use( activator, caller, useType, value )
	if (!self.pitching) then
		sound.Play("buttons/button3.wav",self:GetPos(),75,100,1)
		self:SetColor(self.active_color);
		self.pitching = true;
		
	else
		sound.Play("buttons/lightswitch2.wav",self:GetPos(),75,100,1)
		self:SetColor(self.inactive_color);
		self.pitching = false;
		self.pitch_timer = self.pitch_time;
	end
end