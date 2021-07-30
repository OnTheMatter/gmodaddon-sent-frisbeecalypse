include("shared.lua")

function ENT:Draw()
	self:DrawModel()

end

language.Add("ent_frisbee_generic","Frisbee");
language.Add("Cleanup_ent_frisbee", "Frisbees");
language.Add("Cleaned_ent_frisbee", "Removed Frisbees!")