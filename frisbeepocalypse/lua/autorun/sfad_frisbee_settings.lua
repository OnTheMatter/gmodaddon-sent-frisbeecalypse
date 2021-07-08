AddCSLuaFile()

if SERVER then return end

hook.Add("PopulateToolMenu", "sfad_frisbee_settings_no_conflicts_pretty_please", function()
	spawnmenu.AddToolMenuOption("Utilities", "Squeed Fingars", "Frisbeecalypse", "Frisbeecalypse", "", "", SFAD_FRISBEECALYPSE_SETTINGS_PANEL_INIT)
end)

function SFAD_FRISBEECALYPSE_SETTINGS_PANEL_INIT(panel)
	panel:Help("The Frisbeecalypse is upon us.")
	panel:TextEntry("Frisbee Model","sfad_frisbee_model");
	local sfad_menu_cb = panel:ComboBox("Frisbee Model","sfad_frisbee_model")
	sfad_menu_cb:AddChoice("models/props_junk/sawblade001a.mdl")
	sfad_menu_cb:AddChoice("models/props_c17/playground_carousel01.mdl")
	sfad_menu_cb:AddChoice("models/props_phx/construct/metal_plate1.mdl")
	sfad_menu_cb:AddChoice("models/props_phx/gears/spur24.mdl")
	sfad_menu_cb:AddChoice("models/props_phx/normal_tire.mdl")
	sfad_menu_cb:AddChoice("models/props_phx/construct/metal_angle360.mdl")
	sfad_menu_cb:AddChoice("models/props_c17/playground_swingset_seat01a.mdl")
	sfad_menu_cb:AddChoice("models/props_c17/consolebox01a.mdl")
	sfad_menu_cb:AddChoice("models/mechanics/wheels/wheel_spike_24.mdl")
	sfad_menu_cb:AddChoice("models/props_junk/wood_pallet001a.mdl")
	panel:Help("Most models really do not work well as frisbees, they're all either too small or too big. If you have found a better model though then just copy and paste it into here and that model will be used instead. Erase the text for the default sawblade model.")
	panel:NumSlider("Max Frisbees","sfad_frisbee_max",-1,2000,0);
	panel:CheckBox("Frisbees Collide with other Frisbees?","sfad_frisbee_self_collisions")
	panel:CheckBox("Frisbee Rifts can spawn Electrofrisbeenetic Bombs?","sfad_frisbee_rift_frisbeeinate")
	panel:Help("This makes the rifts less annoying. Keep this on for an authentic Frisbeecalypse.")
	local sfad_p = panel:Button("Reset to Default", nil, nil)
	function sfad_p:DoClick()
		if (LocalPlayer():IsValid() and LocalPlayer():IsSuperAdmin()) then
			net.Start("SFAD_FRISBEE_RESET_BUTTON")
			net.SendToServer()
		end
	end
end