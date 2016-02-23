db = {}
db.Units = {}
mech_timing = {}
SFM_Data = {}
planes_dmg_properties = {}
planes_dmg_parts = {}
lights_prototypes = {}
exhaust_data = {}
guns_by_wstype = {}
country = {}
country["USA"] = {}


function _(s)
	return s
end

function get_aircraft_ammo_mass(_type)
	return 1
end

function makeAirplaneCanopyGeometry(a, b, c)
	return 1
end

function makeHelicopterCanopyGeometry(a, b, c)
	return 1
end

ed_path = "C:/Program Files/Eagle Dynamics/DCS World"
db_path = ed_path.."/Scripts/Database/"

dofile(db_path.."PlaneConst.lua")
dofile(db_path.."HelicopterConst.lua")
dofile(db_path.."db_units_planes.lua")
dofile(db_path.."db_units_helicopters.lua")
dofile("weapons_map.lua")

print([[
# This file is generated from plane_export.lua

from .weapons_data import Weapons
from . import task


class HelicopterType:
    id = ""
    group_size_max = 4
    large_parking_slot = False
    helicopter = True
    fuel_max = 0
    ammo_type = None
    chaff = 0
    flare = 0
    charge_total = 0
    chaff_charge_size = 1
    flare_charge_size = 2
    category = "Air"

    pylons = {}

    tasks = ['Nothing']

]])
for i in pairs(db.Units.Helicopters.Helicopter) do
	local plane = db.Units.Helicopters.Helicopter[i];
	local safename = plane.Name
	safename = string.gsub(safename, "[-()/., *']", "_")
	safename = string.gsub(safename,"^([0-9])", "_%1")
	print("class "..safename.."(HelicopterType):")
	print('    id = "'..plane.Name..'"')
	if plane.singleInFlight then
		print('    group_size_max = 1')
	end

	print('    fuel_max = '..plane.MaxFuelWeight)
	--print('    ammo_type = '..plane.MaxFuelWeight)
	--print('    gun_max = '..)
	if plane.passivCounterm then
		print('    chaff = '..plane.passivCounterm.chaff.default)
		print('    flare = '..plane.passivCounterm.flare.default)
		print('    charge_total = '..plane.passivCounterm.SingleChargeTotal)
		print('    chaff_charge_size = '..plane.passivCounterm.chaff.chargeSz)
		print('    flare_charge_size = '..plane.passivCounterm.flare.chargeSz)
	end

	if plane.Categories and plane.Categories[1] then
		local s = '    category = "Air"'
		print(s)  -- category
	end

	local pylons = {}

	for j in pairs(plane.Pylons) do
		if #plane.Pylons[j].Launchers > 0 then
			print("")
			table.insert(pylons, j)
			print('    class Pylon'..j..':')
			for k in pairs(plane.Pylons[j].Launchers) do
				if weapons_map[plane.Pylons[j].Launchers[k].CLSID] then
					local name = weapons_map[plane.Pylons[j].Launchers[k].CLSID]
					print('        '..name..' = ('..j..', Weapons.'..name..')')
				else
					print('#ERRR '..plane.Pylons[j].Launchers[k].CLSID)
				end
			end
		end
	end

	print("")
	local s = ''
	for j in pairs(pylons) do
		s = s..tostring(pylons[j])
		if j < #pylons then
			s = s..', '
		end
	end
	print('    pylons = {'..s..'}')

	-- tasks
	print("")
	s = ''
	j = 1
	while j <= #plane.Tasks do
		local objname = string.gsub(plane.Tasks[j].Name, "[-()/., *']", "")
		s = s..'task.'..objname..''
		j = j + 1
		if j <= #plane.Tasks then
			s = s..', '
		end
	end
	print('    tasks = ['..s..']')
	local objname = string.gsub(plane.DefaultTask.Name, "[-()/., *']", "")
	print('    task_default = task.'..objname..'')
	print("")
	print("")
end

print("helicopter_map = {")
for i in pairs(db.Units.Helicopters.Helicopter) do
	local plane = db.Units.Helicopters.Helicopter[i];
	local safename = plane.Name
	safename = string.gsub(safename, "[-()/., *']", "_")
	safename = string.gsub(safename,"^([0-9])", "_%1")
	print('    "'..plane.Name..'": '..safename..',')
end
print("}")