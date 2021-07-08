AddCSLuaFile("shared.lua")

include("shared.lua")

sfad_sentient_idle_lines_male = {	
	"vo/npc/male01/pain01.wav",
	"vo/npc/male01/pain02.wav",
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain04.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav",
	"vo/npc/male01/help01.wav",
	"vo/npc/Barney/ba_pain01.wav",
	"vo/npc/Barney/ba_pain02.wav",
	"vo/npc/Barney/ba_pain03.wav",
	"vo/npc/Barney/ba_pain04.wav",
	"vo/npc/Barney/ba_pain05.wav",
	"vo/npc/Barney/ba_pain06.wav",
	"vo/npc/Barney/ba_pain07.wav",
	"vo/npc/Barney/ba_pain08.wav",
	"vo/npc/Barney/ba_pain09.wav",
	"vo/npc/Barney/ba_pain10.wav",
	"vo/npc/male01/finally.wav",
	"vo/npc/male01/gethellout.wav",
	"vo/npc/male01/goodgod.wav",
	"vo/npc/male01/hi01.wav",
	"vo/npc/male01/hi02.wav",
	"vo/npc/male01/hitingut01.wav",
	"vo/npc/male01/hitingut02.wav",
	"vo/npc/male01/imhurt01.wav",
	"vo/npc/male01/imhurt02.wav",
	"vo/npc/male01/moan01.wav",
	"vo/npc/male01/moan02.wav",
	"vo/npc/male01/moan03.wav",
	"vo/npc/male01/moan04.wav",
	"vo/npc/male01/moan05.wav",
	"vo/npc/male01/myarm01.wav",
	"vo/npc/male01/myarm02.wav",
	"vo/npc/male01/mygut02.wav",
	"vo/npc/male01/myleg01.wav",
	"vo/npc/male01/myleg02.wav",
	"vo/npc/male01/no01.wav",
	"vo/npc/male01/no02.wav",
	"vo/npc/male01/ohno.wav",
	"vo/npc/male01/overhere01.wav",
	"vo/npc/male01/ow01.wav",
	"vo/npc/male01/ow02.wav",
	"vo/npc/male01/runforyourlife01.wav",
	"vo/npc/male01/runforyourlife02.wav",
	"vo/npc/male01/runforyourlife03.wav",
	"vo/npc/male01/sorry01.wav",
	"vo/npc/male01/sorry02.wav",
	"vo/npc/male01/sorry03.wav",
	"vo/npc/male01/startle01.wav",
	"vo/npc/male01/startle02.wav",
	"vo/npc/male01/uhoh.wav",
	"vo/npc/male01/wetrustedyou01.wav",
	"vo/npc/male01/wetrustedyou02.wav",
	"vo/npc/male01/whoops01.wav"
};

sfad_sentient_idle_lines_female = {	
	"vo/npc/female01/pain01.wav",
	"vo/npc/female01/pain02.wav",
	"vo/npc/female01/pain03.wav",
	"vo/npc/female01/pain04.wav",
	"vo/npc/female01/pain05.wav",
	"vo/npc/female01/pain06.wav",
	"vo/npc/female01/pain07.wav",
	"vo/npc/female01/pain08.wav",
	"vo/npc/female01/pain09.wav",
	"vo/npc/female01/help01.wav",
	"vo/npc/Alyx/hurt04.wav",
	"vo/npc/Alyx/hurt05.wav",
	"vo/npc/Alyx/hurt06.wav",
	"vo/npc/Alyx/hurt08.wav",
	"vo/npc/female01/headsup01.wav",
	"vo/npc/female01/headsup02.wav",
	"vo/npc/female01/hi01.wav",
	"vo/npc/female01/hi02.wav",
	"vo/npc/female01/hitingut01.wav",
	"vo/npc/female01/hitingut02.wav",
	"vo/npc/female01/moan01.wav",
	"vo/npc/female01/moan02.wav",
	"vo/npc/female01/moan03.wav",
	"vo/npc/female01/moan04.wav",
	"vo/npc/female01/moan05.wav",
	"vo/npc/female01/myarm01.wav",
	"vo/npc/female01/myarm02.wav",
	"vo/npc/female01/mygut02.wav",
	"vo/npc/female01/myleg01.wav",
	"vo/npc/female01/myleg02.wav",
	"vo/npc/female01/no01.wav",
	"vo/npc/female01/no02.wav",
	"vo/npc/female01/overhere01.wav",
	"vo/npc/female01/ow01.wav",
	"vo/npc/female01/ow02.wav",
	"vo/npc/female01/runforyourlife01.wav",
	"vo/npc/female01/runforyourlife02.wav",
	"vo/npc/female01/sorry01.wav",
	"vo/npc/female01/sorry02.wav",
	"vo/npc/female01/sorry03.wav",
	"vo/npc/female01/startle01.wav",
	"vo/npc/female01/startle02.wav",
	"vo/npc/female01/wetrustedyou01.wav",
	"vo/npc/female01/wetrustedyou02.wav"
};

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
	self:SetMaterial("models/flesh")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetFriction(0)
	self:SetColor(Color(math.random(128,255),math.random(0,128),math.random(0,128)))
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(10);
		phys:SetMaterial("models/flesh")
		phys:EnableDrag(false)
		if (!GetConVar("sfad_frisbee_self_collisions"):GetBool()) then self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS) end
	end
	self:SetHealth(math.Round(math.random(100,150)))
	self.sfad_rainbow_frisbee = false;
	if (math.random(0,1000) > 999) then
		self.sfad_rainbow_frisbee = true;
	end
	self:SetUseType(SIMPLE_USE);
	self.sfad_evil_frisbee = false;
	self.sfad_gender = math.Round(math.random(0,1));
	self.sfad_move_timer = math.Round(math.random(10,25));
	local sfad_player = ents.FindByClass("Player");
	cleanup.Add(sfad_player[math.random(1,#sfad_player)],"ent_frisbee",self)
end

function ENT:Think()
	if (self.sfad_rainbow_frisbee) then
		self:SetColor(Color(math.random(128,255),math.random(0,128),math.random(0,128)))
	end

	if (math.random(1,100) >= 99) then 
		if (self.sfad_gender == 1) then
			sound.Play(sfad_sentient_idle_lines_male[math.random(1,#sfad_sentient_idle_lines_male)],self:GetPos(),78,math.random(30,100),1)
		else
			sound.Play(sfad_sentient_idle_lines_female[math.random(1,#sfad_sentient_idle_lines_female)],self:GetPos(),78,math.random(30,100),1)
		end
	end

	self.sfad_move_timer = self.sfad_move_timer - 1;
	if (self.sfad_move_timer <= 0) then
		self.sfad_move_timer = math.Round(math.random(10,25));
		self:GetPhysicsObject():ApplyForceCenter(Vector(math.random(-50,50),math.random(-50,50),math.random(-50,50)) * self:GetPhysicsObject():GetMass()*2);
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
	if (self.sfad_gender == 1) then
		sound.Play("vo/npc/male01/pain0" .. tostring(math.Round(math.random(1,9))) .. ".wav",self:GetPos(),78,math.random(30,100),1)
	else
		sound.Play("vo/npc/female01/pain0" .. tostring(math.Round(math.random(1,9))) ..".wav",self:GetPos(),78,math.random(30,100),1)
	end
	local sfad_ble = EffectData();
	sfad_ble:SetOrigin(dmg:GetDamagePosition());
	util.Effect("BloodImpact",sfad_ble);
	if (self:Health() <= 0) then
		self:Remove();
	end
end

function ENT:Starttouch(ent)
	
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