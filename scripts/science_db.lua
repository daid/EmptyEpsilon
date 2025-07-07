--[[
	Everything in the science database files is just readable data for the science officer.
	This data does not affect the game in any other way and just contributes to the lore.
	For details on ScienceDatabase scripting functions, see the scripting reference.
--]]

-- "Natural" describes space terrain objects
local space_objects = ScienceDatabase():setName(_('Natural'))
space_objects:setLongDescription(_([[This database covers naturally occurring phenomena that spaceborne crews might encounter.

While ship captains are encouraged to avoid unnecessary interactions with these phenomena, knowing their properties can offer an advantage in conflicts near them.]]))

local item = space_objects:addEntry(_('Asteroid'))
item:setLongDescription(_([[An asteroid is a minor planet, usually smaller than a few kilometers. Larger variants are sometimes referred to as planetoids.]]))

local item = space_objects:addEntry(_('Black hole'))
item:setLongDescription(_([[A black hole is a point of supercondensed mass with a gravitational pull so powerful that not even light can escape it. It has no locally detectable features, and can only be seen indirectly by blocking the view and distorting its surroundings, creating a strange circular mirror image of the galaxy. The black disc in the middle marks the event horizon, the boundary where even light can't escape it anymore. 
	
On the sensors, a black hole appears as a disc indicating the zone where the gravitational pull is getting dangerous, and soon will be stronger then the ship's impulse engines. An object that crosses a black hole is drawn toward its center and quickly ripped apart by the gravitational forces.]]))

local item = space_objects:addEntry(_('Nebula'))
item:setLongDescription(_([[Nebulae are the birthing places of new stars. These gas fields, usually created by the death of an old star, slowly form new stars due to the gravitational pull of its gas molecules.

Because of the ever-changing nature of gas nebulae, most radar and scanning technologies are unable to penetrate them. Science officers are therefore advised to rely on probes and visual observations.]]))

local item = space_objects:addEntry(_('Planet'))
item:setLongDescription(_([[A planetary-mass object is large, dense, near-spherical astronomical body comprised of various forms of matter. Most planets are either terrestrial, like Earth, or giants, like the gas giant Jupiter or ice giant Neptune.

Planets often have gaseous atmospheres, and some are orbited by one or more large planetoids typically called moons.]]))

local item = space_objects:addEntry(_('Wormhole'))
item:setLongDescription(_([[A wormhole, also known as an Einstein-Rosen bridge, is a phenomena that connects two points of spacetime. Jump drives operate in a similar fashion, but instead of being created at will, a wormhole occupies a specific location in space. Objects that enter a wormhole instantaneously emerge from the other end, which might be anywhere from a few feet to thousands of light years away. 

Wormholes are rare, and most can move objects in only one direction. Traversable wormholes, which are stable and allow for movement in both directions, are even rarer. All wormholes generate tremendous sensor activity, which an astute science officer can detect even through disruptions such as nebulae.]]))

-- "Technologies" describes non-ship, non-weapon ship features
local technologies = ScienceDatabase():setName(_('Technologies'))
technologies:setLongDescription(_([[This database covers ship systems and technologically created phenomena that spacefaring crews might encounter in densely populated regions of space.

This reference is intended only as a primer. Refer to your ship's technical manuals and training materials for details on maintaining and operating your craft.]]))

local item = technologies:addEntry(_('Beam/shield frequencies'))
item:addKeyValue(_('Unit'), _('Terahertz'))
item:setLongDescription(_([[Ships with shield and beam systems can often configure their terahertz-frequency radiation. By manipulating these frequencies, savvy ship crews can maximize their beam weapon efficiency while reducing their enemies'.

A beam frequency that's resonant with a target's shield frequency can do considerably more damage, and beam frequencies can be quickly modulated. Shield frequencies require time to recalibrate.

If your Science officer fully scans a target, your ship's computer presents them with a detailed analysis of beam and shield frequencies and suggests optimal values for each.]]))

local item = technologies:addEntry(_('Hacking measure'))
item:addKeyValue(_('Interaction'), _('Long-range transmission'))
item:setLongDescription(_([[Thanks to our covert operations teams, we've acquired enough information about our enemies' computer systems to repurpose our long-range communications systems into intrusion and exploitation tools.

While we've managed to create algorithmic attack vectors that you can deploy at range to target and degrade specific ship systems, these exploits still require active human intervention to fully function.

To facilitate successful operations in the field, our software engineers have abstracted the required inputs into common puzzles that even a Relay crew member can successfully complete.]]))

local item = technologies:addEntry(_('Radar signature'))
item:addKeyValue(_('Signature'), _('Related color bands'))
item:addKeyValue(_('Biological'), _('Green'))
item:addKeyValue(_('Electrical'), _('Red'))
item:addKeyValue(_('Gravitational'), _('Blue'))
item:setLongDescription(_([[The outer ring of long-range Science radar screens contain three colored bands that represent raw sensor inputs monitored on that heading. Ships and space phenomena emit energies or exhibit characteristics that your sensor suite translates into icons on your radar, but these raw rings can provide more information to a well-trained eye.

For tactical purposes, heat generated by ship systems is registered in raw thermal sensor data in a similar manner as biological (green) sources. If a ship's systems are under- or over-powered, its electrical (red) readings change accordingly.

A ship warping or preparing to jump exponentially increases its gravitational (blue) output. After completing a jump a ship performs a massive power transfer that raw sensor data reads as an electrical spike.]]))

local item = technologies:addEntry(_('Scan probe'))
item:addKeyValue(_('Radar range'), '5u')
item:addKeyValue(_('Typical lifetime'), _('10 minutes'))
item:addKeyValue(_('Interaction'), _('Systems link'))
item:setImage('radar/probe.png')
item:setModelDataName('SensorBuoyMKI')
item:setLongDescription(_([[Whether your mission involves scientific investigation, deep-space exploration, or military operations, remember to take advantage of any scan probes distributed for your ship.

Your Relay officer can launch a probe to any coordinates in their sector map, which fires its payload at high velocity directly toward the target coordinates. Upon arrival, Relay can then link the probe to the Science officer, who can switch their long-range radar to the probe's short-range radar.

This allows the Science officer to scan objects well outside of your ship's long-range radar range, including regions obfuscated by phenomena like nebulae that occlude your sensors.

Scan probes have a limited energy supply and expire within minutes, and your ship carries a limited number of them that only some stations can or will replenish.]]))

local item = technologies:addEntry(_('Supply drop'))
item:addKeyValue(_('Contents'), _('Weapons, energy'))
item:addKeyValue(_('Interaction'), _('Close-range retrieval'))
item:setImage('radar/blip.png')
item:setModelDataName("ammo_box")
item:setLongDescription(_([[To expedite resupply actions, our engineers have standardized containers for weapons and energy that can be automatically and quickly integrated into your ship's systems.

Commonly known as a supply drop, your ship needs only to enter near-contact range with one of these containers to automatically engage your ship's acquisition and integration systems. Supply drops are cryptographically keyed to respond only to ships of the same faction, so theft isn't possible.]]))

local item = technologies:addEntry(_('Warp jammer'))
item:addKeyValue(_('Interaction'), _('Short-range encounter'))
item:setImage('radar/blip.png')
item:setModelDataName('shield_generator')
item:setLongDescription(_([[Warp and jump technologies rely on technological manipulation of gravitational forces to achieve long-range travel. However, these manipulative forces can be nullified or interdicted by devices that generate electromagnetically simulated gravitational wells. Such devices are colloquially known as warp jammers, even though they can also prevent jumps.

A warping ship that enters a jammer's radius is interdicted and slowed to impulse speeds. A jumping ship is unable to engage its jump drive while within a jammer's radius.

Ship captains who value the option of retreat are advised to either give warp jammers a wide berth or prioritize their destruction.]]))

-- "Weapons" describes ship weapon types
local weapons = ScienceDatabase():setName(_('Weapons'))
weapons:setLongDescription(_([[This database covers only the basic versions of missile weapons used throughout the galaxy.

It has been reported that some battleships started using larger variations of those missiles. Small fighters and even frigates should not have too much trouble dodging them, but space captains of bigger ships should be wary of their doubled damage potential.

Smaller variations of these missiles have become common in the galaxy, too. Fighter pilots praise their speed and maneuverability, because it gives them an edge against small and fast-moving targets. They only deal half the damage of their basic counterparts, but what good is a missile if it does not hit its target.]]))

local item = weapons:addEntry(_('Beam weapons'))
item:addKeyValue(_('Range'), 'Varies')
item:addKeyValue(_('Damage'), 'Varies')
item:setLongDescription(_([[Beam weapons emit an instantaneous, focused burst of energy or matter at a single target within a target arc. Many ships equip beam weapons for their precision and versatility.

Shields are generally effective against energy-based beam weapons. To combat this, a beam's output can be modulated to various frequencies. This allows beam weapons to be tuned to a target's shield frequency to maximize their effectiveness.

Each firing of a beam weapon begins a brief cycle period, during which the beam cannot fire again. Damage to the system increases this delay while also reducing its output. Beam firings also generate heat above and beyond the system's normal operating temperature. In heavy combat situations, a ship's engineers must dissipate this heat to prevent inflicting damage on the system.

On some ships, heavy beam weapons are mounted on turrets that can rotate to cover a wide firing arc, at an expense of targeting speed.]]))

local item = weapons:addEntry(_('Homing missile'))
item:addKeyValue(_('Range'), '5.4u')
item:addKeyValue(_('Damage'), '35')
item:setLongDescription(_([[This target-seeking missile is the workhorse of many space combat arsenals. It's compact enough to be fitted on frigates, and packs enough punch to be used on larger ships, though usually in more than a single missile tube.]]))

local item = weapons:addEntry(_('Nuke'))
item:addKeyValue(_('Range'), '5.4u')
item:addKeyValue(_('Blast radius'), '1u')
item:addKeyValue(_('Damage at center'), '160')
item:addKeyValue(_('Damage at edge'), '30')
item:setLongDescription(_([[A nuclear missile is similar to a homing missile in that it can seek a target, but it moves and turns more slowly and explodes a greatly increased payload. Its nuclear explosion spans 1U of space and can take out multiple ships in a single shot.

Some captains oppose the use of nuclear weapons because their large explosions can lead to 'fragging', or unintentional friendly fire. Shields should protect crews from harmful radiation, but because these weapons are often used in the thick of battle, there's no way of knowing if hull plating or shields can provide enough protection.]]))

local item = weapons:addEntry(_('Mine'))
item:addKeyValue(_('Drop distance'), '1u')
item:addKeyValue(_('Trigger distance'), '0.6u')
item:addKeyValue(_('Blast radius'), '1u')
item:addKeyValue(_('Damage at center'), '160')
item:addKeyValue(_('Damage at edge'), '30')
item:setLongDescription(_([[Mines are often placed in defensive perimeters around stations. There are also old minefields scattered around the galaxy from older wars.

Some fearless captains use mines as offensive weapons, but their delayed detonation and blast radius make this use risky at best.]]))

local item = weapons:addEntry(_('EMP'))
item:addKeyValue(_('Range'), '5.4u')
item:addKeyValue(_('Blast radius'), '1u')
item:addKeyValue(_('Damage at center'), '160')
item:addKeyValue(_('Damage at edge'), '30')
item:setLongDescription(_([[The electromagnetic pulse missile (EMP) reproduces the disruptive effects of a nuclear explosion, but without the destructive properties. This causes it to only affect shields within its blast radius, leaving their hulls intact. The EMP missile is also smaller and easier to store than heavy nukes. Many captains (and pirates) prefer EMPs over nukes for these reasons, and use them to knock out targets' shields before closing to disable them with focused beam fire.]]))

local item = weapons:addEntry(_('HVLI'))
item:addKeyValue(_('Range'), '5.4u')
item:addKeyValue(_('Damage'), _('10 each, 50 total'))
item:addKeyValue(_('Burst'), '5')
item:setLongDescription(_([[A high-velocity lead impactor (HVLI) fires a simple slug of lead at a high velocity. This weapon is usually found in simpler ships since it does not require guidance computers. This also means its projectiles fly in a straight line from its tube and can't pursue a target.

Each shot from an HVLI fires a burst of 5 projectiles, which increases the chance to hit but requires precision aiming to be effective. It reaches its full damage potential at a range of 2u.]]))

local function angleDifference(angle_a, angle_b)
    local ret = (angle_b or 0) - (angle_a or 0)
    while ret > 180 do ret = ret - 360 end
    while ret < -180 do ret = ret + 360 end
    return ret
end

local function directionLabel(direction)
	name = "?"
    if math.abs(angleDifference(0.0, direction)) <= 45 then name = _("database direction", "Front") end
    if math.abs(angleDifference(90.0, direction)) < 45 then name = _("database direction", "Right") end
    if math.abs(angleDifference(-90.0, direction)) < 45 then name = _("database direction", "Left") end
    if math.abs(angleDifference(180.0, direction)) <= 45 then name = _("database direction", "Rear") end
    return name
end

-- Populate default ScienceDatabase entries.
function __fillDefaultDatabaseData()
	-- Populate the Factions top-level entry.
	local faction_database = ScienceDatabase():setName(_("database", "Factions"))
	for name, info in pairs(__faction_info) do
        local entry = faction_database:addEntry(info.components.faction_info.locale_name);
		for name2, info2 in pairs(__faction_info) do
            if info ~= info2 then
				local stance = _("stance", "Neutral");
				for idx, relation in ipairs(info.components.faction_info) do
					if relation.other_faction == info2 then
						if relation.relation == "neutral" then stance = _("stance", "Neutral") end
						if relation.relation == "enemy" then stance = _("stance", "Enemy") end
						if relation.relation == "friendly" then stance = _("stance", "Friendly") end
					end
				end
				entry:addKeyValue(info2.components.faction_info.locale_name, stance);
			end
        end
        entry:setLongDescription(info.components.faction_info.description);
    end

    -- Populate the Ships top-level entry.
    local ship_database = ScienceDatabase():setName(_("database", "Ships"))
    ship_database:setLongDescription(_("Spaceships are vessels capable of withstanding the dangers of travel through deep space. They can fill many functions and vary broadly in size, from small tugs to massive dreadnoughts."));
    -- Populate the Stations top-level entry.
    local stations_database = ScienceDatabase():setName(_("database", "Stations"))
    stations_database:setLongDescription(_("Space stations are permanent, immobile structures ranging in scale from small outposts to city-sized communities. Many provide restocking and repair services to neutral and friendly ships."))

    local class_list = {}
    local class_set = {}
	local template_names = {}

    -- Populate list of ship hull classes
	for name, ship_template in pairs(__ship_templates) do
        if not ship_template.__hidden and ship_template.__type ~= "station" then
			local class_name = _("No class")
			if ship_template.docking_port ~= nil then class_name = ship_template.docking_port.dock_class end

			if class_set[class_name] == nil then
				class_list[#class_list + 1] = class_name
				class_set[class_name] = true
			end
			table.insert(template_names, name)
		end
    end

    table.sort(class_list)
	table.sort(template_names)
    class_database_entries = {}

    -- Populate each ship hull class with members
	for idx, class_name in pairs(class_list) do
        class_database_entries[class_name] = ship_database:addEntry(class_name)
    end

    -- Populate each ship's entry
	for idx, name in ipairs(template_names) do
		ship_template = __ship_templates[name]
        if not ship_template.__hidden then
			local class_name = _("No class")
			local subclass_name = _("No sub-class")
			if ship_template.docking_port ~= nil then class_name = ship_template.docking_port.dock_class subclass_name = ship_template.docking_port.dock_subclass end
        	local entry = nil
			if ship_template.__type == "station" then
				entry = stations_database:addEntry(ship_template.typename.localized);
			else
				entry = class_database_entries[class_name]:addEntry(ship_template.typename.localized);
			end

			if ship_template.__model_data_name then
				entry:setModelDataName(ship_template.__model_data_name)
			end
			if ship_template.radar_trace then
				entry:setImage(ship_template.radar_trace.icon)
			end

			entry:addKeyValue(_("database", "Class"), class_name)
			entry:addKeyValue(_("database", "Sub-class"), subclass_name)
			if ship_template.physics then
				if type(ship_template.physics.size) == "table" then
					entry:addKeyValue(_("database", "Size"), math.floor(ship_template.physics.size[1]))
				else
					entry:addKeyValue(_("database", "Size"), math.floor(ship_template.physics.size))
				end
			end

			if ship_template.shields then
				local shield_info = ""
				for idx, data in ipairs(ship_template.shields) do
					if idx > 1 then
						shield_info = shield_info .. "/"
					end
					shield_info = shield_info .. tostring(math.floor(data.max))
				end
				entry:addKeyValue(_("database", "Shield"), shield_info);
			end

			if ship_template.hull then
				entry:addKeyValue(_("Hull"), math.floor(ship_template.hull.max));
			end

			if ship_template.impulse_engine then
				entry:addKeyValue(_("database", "Move speed"), string.format("%.1f u/min", ship_template.impulse_engine.max_speed_forward * 60 / 1000))
				entry:addKeyValue(_("database", "Reverse move speed"), string.format("%.1f u/min", ship_template.impulse_engine.max_speed_reverse * 60 / 1000))
			end
			if ship_template.maneuvering_thrusters then
				entry:addKeyValue(_("database", "Turn speed"), string.format("%.1f deg/sec", ship_template.maneuvering_thrusters.speed))
			end
			if ship_template.warp_drive then
				entry:addKeyValue(_("database", "Warp speed"), string.format("%.1f u/min", ship_template.warp_drive.speed_per_level * 60 / 1000))
			end
			if ship_template.jump_drive then
				entry:addKeyValue(_("database", "Jump range"), string.format("%.0f - %.0f u", (ship_template.jump_drive.min_distance or 5000) / 1000, (ship_template.jump_drive.max_distance or 20000) / 1000));
			end

			if ship_template.beam_weapons then
				for idx, data in ipairs(ship_template.beam_weapons) do
					if data.range > 0 then
						entry:addKeyValue(
							string.format(_("database", "%s beam weapon"), directionLabel(data.direction)),
							string.format(_("database", "%.1f Dmg / %.1f sec"), data.damage, data.cycle_time)
						)
					end
				end
			end

			if ship_template.missile_tubes then
				for idx, data in ipairs(ship_template.missile_tubes) do
					local key = _("database", "%s tube");
					if data.size == "small" then
						key = _("database", "%s small tube")
					end
					if data.size == "large" then
						key = _("database", "%s large tube")
					end
					entry:addKeyValue(
						string.format(key, directionLabel(data.direction)),
						string.format(_("database", "%.1f sec"), data.load_time)
					)
				end
			end

			--[[ TODO 
			for(int n=0; n < MW_Count; n++)
			{
				if (ship_template->weapon_storage[n] > 0)
				{
					entry:addKeyValue(_("Storage {weapon}").format({{"weapon", getLocaleMissileWeaponName(EMissileWeapons(n))}}), string(ship_template->weapon_storage[n]));
				}
			}
			]]

			if ship_template.__description then
				entry:setLongDescription(ship_template.__description)
			end
		end
    end
--[[
#ifdef DEBUG
    // If debug mode is enabled, populate the ModelData entry.
    P<ScienceDatabase> models_database = new ScienceDatabase();
    models_database->setName("Models (debug)");
    for(string name : ModelData::getModelDataNames())
    {
        P<ScienceDatabase> entry = models_database->addEntry(name);
        entry->setModelDataName(name);
    }
#endif
--]]
end
__fillDefaultDatabaseData()