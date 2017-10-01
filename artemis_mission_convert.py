import xml.etree.ElementTree
import os.path
import traceback
import sys
import fnmatch
import tokenize
import io

class UnknownArtemisTagError(Exception):
    def __init__(self, node):
        super().__init__('%s: %s' % (node.tag, node.attrib))

def convertString(s):
    return s.replace('\n', '\\n').replace('\'', '\\\'').replace('"', '\\"').replace('^', '\\n').strip()

def convertFloat(f):
    try:
        return str(float(eval(str(f), {}, {})))
    except NameError:
        pass
    result = '('
    for token in tokenize.tokenize(io.BytesIO(str(f).encode('UTF-8')).readline):
        if token.type == tokenize.ENCODING or token.type == tokenize.ENDMARKER:
            pass
        elif token.type == tokenize.NAME:
            result += 'variable_%s' % (convertName(token.string))
        elif token.type == tokenize.OP:
            result += '%s' % (token.string)
        elif token.type == tokenize.NUMBER:
            result += '%s' % (token.string)
        else:
            raise ValueError(token)
    result += ')'
    return result

def convertPosition(x, z):
    return convertFloat('20000-(%s)' % (x)), convertFloat('(%s)-100000' % (z))

def convertName(name):
    prefix = ''
    try:
        if int(name[0]) in range(10):
            prefix = 'object_'
    except ValueError:
        pass
    return '%s%s' % (prefix, name.replace(' ', '_')
                                 .replace('-', '_')
                                 .replace('*', 'X')
                                 .replace('.', '__')
                                 .replace('/', '___')
                                 .replace('=', 'equals')
                                 .replace('\'', '____'))

def convertRaceKeys(node, default=None):
    keys = node.get('raceKeys', default)
    keys = keys.lower().split(' ')
    if 'biomech' in keys:
        return "Ghosts"
    elif 'friendly' in keys:
        return "Human Navy"
    elif 'enemy' in keys:
        return "Kraylor"
    elif 'neutral' in keys:
        return "Independent"
    raise UnknownArtemisTagError(node)

def convertComparator(node):
    comparator = node.get('comparator').lower()
    if comparator == "equals" or comparator == "=":
        return "=="
    elif comparator == "not" or comparator == "!=":
        return "~="
    elif comparator == "greater" or comparator == ">":
        return ">"
    elif comparator == "less" or comparator == "<":
        return "<"
    elif comparator == "greater_equal" or comparator == "<=":
        return ">="
    elif comparator == "less_equal" or comparator == ">=":
        return "<="
    raise UnknownArtemisTagError(node)

def convertSystemName(node):
    system = node.get('systemType')
    if system == 'systemBeam':
        return 'beamweapons'
    elif system == 'systemTorpedo':
        return 'missilesystem'
    elif system == 'systemTactical': # Sensors, we map it to reactor, as we don't have sensor power/damage
        return 'reactor'
    elif system == 'systemTurning':
        return 'maneuver'
    elif system == 'systemImpulse':
        return 'impulse'
    elif system == 'systemWarp':
        return 'warp'
    elif system == 'systemFrontShield':
        return 'frontshield'
    elif system == 'systemBackShield':
        return 'rearshield'
        
    raise UnknownArtemisTagError(node)

def convertSystemState(system_state):
    if system_state == 'shieldStateFront':
        return ['FrontShield']
    elif system_state == 'shieldStateBack':
        return ['RearShield']
    elif system_state == 'shieldMaxStateFront':
        return ['FrontShieldMax']
    elif system_state == 'shieldMaxStateBack':
        return ['RearShieldMax']
    elif system_state == 'systemDamageBeam':
        return ['beamweapons']
    elif system_state == 'systemDamageTorpedo':
        return ['missilesystem']
    elif system_state == 'systemDamageTactical':
        return ['reactor']
    elif system_state == 'systemDamageTurning':
        return ['maneuver']
    elif system_state == 'systemDamageImpulse':
        return ['impulse']
    elif system_state == 'systemDamageWarp':
        return ['warp', 'jumpdrive']
    elif system_state == 'systemDamageFrontShield':
        return ['frontshield']
    elif system_state == 'systemDamageBackShield':
        return ['rearshield']
    return None


def convertWeaponName(weapon):
    if weapon == 'countHoming' or weapon == 'missileStoresHoming':
        return 'MW_Homing'
    if weapon == 'countNuke' or weapon == 'missileStoresNuke':
        return 'MW_Nuke'
    if weapon == 'countMine' or weapon == 'missileStoresMine':
        return 'MW_Mine'
    elif weapon == 'countECM' or weapon == 'missileStoresECM':
        return 'MW_EMP'
    #return None #'MW_HVLI'
    return None


def convert_positions(node):
    positions = set()
    if node.get("consoles") == None: #if consoles is empty no position will be returned
        return []
    if 'C' in node.get("consoles"):
        positions.add("relayOfficer")
        #positions.add("operationsOfficer")
        #positions.add("singlePilot")
    if 'H' in node.get("consoles"):
        positions.add("helmsOfficer")
        #positions.add("tacticalOfficer")
        #positions.add("singlePilot")
    if 'W' in node.get("consoles"):
        positions.add("weaponsOfficer")
        #positions.add("tacticalOfficer")
        #positions.add("singlePilot")
    if 'E' in node.get("consoles"):
        positions.add("engineering")
        #positions.add("engineeringAdvanced")
        #positions.add("singlePilot")
    if 'S' in node.get("consoles"):
        positions.add("scienceOfficer")
        #positions.add("operationsOfficer")
        #positions.add("singlePilot")

    return positions

def setSystemHealth(obj, property_name, value):
    _value = float(value)
    if 'shield' in property_name and 'State' in property_name:
        _value /= 100.0

    format_string = '%s:setSystemHealth("%s", %f)'
    return_string = ''

    property_list = convertSystemState(property_name)

    if property_list is not None:
        for item in property_list:
            return_string += format_string % (obj, item, _value)
            return_string += '\n'

    if return_string.endswith('\n'):
        return return_string[:-2]

    return return_string


def getSystemHealth(obj, property_name):
    return '%s:getSystemHealth("%s")' % (obj, convertSystemState(property_name))


class Event:
    def __init__(self, main_node, player = None):
        self._valid = True
        self._body = []
        self._conditions = []
        self._warnings = []
        self._done = {}
        self._ai_info = {}
        self.set_end_tag = False
        self._player = player

        for node in main_node:
            if node.tag == 'big_message':
                message = convertString(node.get('title', ''))
                if node.get('subtitle1') is not None:
                    message += '\\n%s' % (convertString(node.get('subtitle1')))
                if node.get('subtitle2') is not None:
                    message += '\\n%s' % (convertString(node.get('subtitle2')))
                self._body.append('globalMessage("%s");' % (message));
            elif node.tag == 'incoming_comms_text':
                self._body.append('temp_transmission_object:setCallSign("%s"):sendCommsMessage(getPlayerShip(-1), "%s")' % (convertString(node.get('from')), convertString(node.text)));
            elif node.tag == 'warning_popup_message':
                if self._player is None:
                    self.warning('Ignore - no player ready', node)
                if 'M' in node.get("consoles") or 'O' in node.get('consoles'):
                    self.warning('Ignore', node)
                for position in convert_positions(node):
                    self._body.append('%s:addCustomInfo("%s", "%s", "%s")' % (self._player, position, 'warning', node.get('message')))
            elif node.tag == 'start_getting_keypresses_from':
                self.warning('Ignore', node)
            elif node.tag == 'end_getting_keypresses_from':
                self.warning('Ignore', node)
            elif node.tag == 'set_damcon_members':
                self.warning('Ignore', node)
            elif node.tag == 'incoming_message':
                self.warning('Ignore', node)
            elif node.tag == 'set_difficulty_level':
                self.warning('Ignore', node)
            elif node.tag == 'log':
                self._body.append('print("%s")' % (convertString(node.get('text'))));
            
            elif node.tag == 'set_skybox_index':
                pass #We don't have other skyboxes. So ignore this command.
            elif node.tag == 'create':
                self.parseCreate(node)
            elif node.tag == 'clear_ai':
                name = convertName(node.get('name'))
                if name not in self._ai_info:
                    self._ai_info[name] = {}
                self._ai_info[name]['CLEAR'] = True
            elif node.tag == 'add_ai':
                if node.get('name') is None:
                    self.warning('Ignore', node)
                else:
                    name = convertName(node.get('name'))
                    if name not in self._ai_info:
                        self._ai_info[name] = {}
                    self._ai_info[name][node.get('type').upper()] = node.attrib
            elif node.tag == 'set_object_property':
                name = convertName(node.get('name'))
                property = node.get('property')
                self._body.append('if %s ~= nil and %s:isValid() then' % (name, name))
                if property == 'positionX':
                    self._body.append('    local x, y = %s:getPosition()' % (name))
                    x, y = convertPosition(node.get('value'), 0)
                    self._body.append('    %s:setPosition(%s, y)' % (name, x))
                elif property == 'positionY':
                    pass
                elif property == 'positionZ':
                    self._body.append('    local x, y = %s:getPosition()' % (name))
                    x, y = convertPosition(0, node.get('value'))
                    self._body.append('    %s:setPosition(x, %s)' % (name, y))
                elif convertSystemState(property) is not None:
                    self._body.append(setSystemHealth(name, property, node.get('value')))
                elif convertWeaponName(property):
                    self._body.append('    %s:setWeaponStorage("%s", %s)' % (
                        name, convertWeaponName(property), int(float(node.get('value')))))
                elif property == 'willAcceptCommsOrders':
                    self.warning('Ignore', node)
                elif property == 'eliteAIType':
                    self.warning('Ignore', node)
                elif property == 'eliteAbilityBits':
                    bits = int(node.get('value'))
                    if (bits & 8) or (bits & 64):
                        self._body.append('    %s:setJumpDrive(True)' % (name))
                    if bits & 32:
                        self._body.append('    %s:setWarpDrive(True)' % (name))
                else:
                    self.warning('Ignore', node)
                    #raise UnknownArtemisTagError(node)
                self._body.append('end')
            elif node.tag == 'if_object_property':
                self._conditions.append('%s %s %s' % (getSystemHealth(convertName(node.get('name')),
                                                                        node.get('property')),
                                                        convertComparator(node), node.get('value')))
            elif node.tag == 'addto_object_property':
                name = convertName(node.get('name'))
                property = node.get('property')
                if convertWeaponName(property):
                    self._body.append(
                        '    local weapon_count = %s:getWeaponStorage("%s")' % (name, convertWeaponName(property)))
                    self._body.append('    %s:setWeaponStorage("%s", weapon_count + %s)' % (
                        name, convertWeaponName(property), int(float(node.get('value')))))
                else:
                    self.warning('Ignore', node)
            elif node.tag == 'set_fleet_property':
                self.warning('Ignore', node)
            elif node.tag == 'set_timer':
                self._body.append('timers["%s"] = %f' % (convertName(node.get('name')), float(node.get('seconds'))))
            elif node.tag == 'set_variable':
                if node.get('randomIntHigh') is not None:
                    self._body.append('variable_%s = random(%d, %d) --Should be random int...' % (convertName(node.get('name')), int(node.get('randomIntLow')), int(node.get('randomIntHigh'))))
                elif node.get('randomFloatHigh') is not None:
                    self._body.append('variable_%s = random(%d, %d)' % (convertName(node.get('name')), float(node.get('randomFloatLow')), int(node.get('randomFloatHigh'))))
                else:
                    self._body.append('variable_%s = %s' % (convertName(node.get('name')), convertFloat(node.get('value'))))
            elif node.tag == 'set_ship_text':
                self.warning('Ignore', node)
            elif node.tag == 'set_relative_position':
                self._body.append('tmp_x, tmp_y = %s:getPosition()' % (convertName(node.get('name1'))));
                self._body.append('tmp_x2, tmp_y2 = vectorFromAngle(%s:getRotation() + %f, %f)' % (convertName(node.get('name1')), float(node.get('angle')), float(node.get('distance'))));
                self._body.append('%s:setPosition(x, y);' % (convertName(node.get('name2'))));
            elif node.tag == 'end_mission':
                self._body.append('victory("Independent")')
            elif node.tag == 'set_player_grid_damage':
                if convertSystemName(node) == 'warp':
                    self._body.append('getPlayerShip(-1):setSystemHealth("%s", %f)' % ('jumpdrive', 1.0 - float(node.get('value')) * 2.0))
                self._body.append('getPlayerShip(-1):setSystemHealth("%s", %f)' % (convertSystemName(node), 1.0 - float(node.get('value')) * 2.0))
            elif node.tag == 'destroy':
                name = convertName(node.get('name'))
                self._body.append('if %s ~= nil and %s:isValid() then %s:destroy() end' % (name, name, name))
            elif node.tag == 'destroy_near':
                obj_type = node.get('type')
                if obj_type == 'nebulas':
                    obj_type = 'Nebula'
                elif obj_type == 'asteroids':
                    obj_type = 'Asteroid'
                elif obj_type == 'mines':
                    obj_type = 'Mine'
                else:
                    raise UnknownArtemisTagError(node)
                if node.get('name'):
                    name = convertName(node.get('name'))
                    self._body.append('if %s ~= nil and %s:isValid() then' % (name, name))
                    self._body.append('    for _, obj in ipairs(%s:getObjectsInRange(%f)) do' % (name, float(node.get('radius'))))
                    self._body.append('        if obj.typeName == "%s" then obj:destroy() end' % (obj_type))
                    self._body.append('    end')
                    self._body.append('end')
                else:
                    x, y = convertPosition(node.get('centerX', 0), node.get('centerZ', 0))
                    r = float(node.get('radius'))
                    self._body.append('for _, obj in ipairs(getObjectsInRadius(%s, %s, %f)) do' % (x, y, float(node.get('radius'))))
                    self._body.append('    if obj.typeName == "%s" then obj:destroy() end' % (obj_type))
                    self._body.append('end')
            
            elif node.tag == 'if_gm_key':
                self._body.append('addGMFunction("addMissingCaption", function()')
                self.warning('Add missing Caption', node)
                self.set_end_tag = True
            elif node.tag == 'if_client_key':
                self._conditions.append('0')
                self.warning('Ignore', node)
            elif node.tag == 'if_variable':
                self._conditions.append("variable_%s %s (%s)" % (convertName(node.get("name")), convertComparator(node), node.get("value")))
            elif node.tag == 'if_timer_finished':
                self._conditions.append('(timers["%s"] ~= nil and timers["%s"] < 0.0)' % (convertName(node.get("name")), convertName(node.get("name"))))
            elif node.tag == 'if_outside_box':
                x1, y1 = convertPosition(node.get('leastX'), node.get('leastZ'))
                x2, y2 = convertPosition(node.get('mostX'), node.get('mostZ'))
                self._conditions.append('ifOutsideBox(%s, %s, %s, %s, %s)' % (convertName(node.get("name")), x1, y1, x2, y2))
            elif node.tag == 'if_inside_box':
                x1, y1 = convertPosition(node.get('leastX'), node.get('leastZ'))
                x2, y2 = convertPosition(node.get('mostX'), node.get('mostZ'))
                self._conditions.append('ifInsideBox(%s, %s, %s, %s, %s)' % (convertName(node.get("name")), x1, y1, x2, y2))
            elif node.tag == 'if_inside_sphere':
                x1, y1 = convertPosition(node.get('centerX'), node.get('centerZ'))
                r = float(node.get('radius'))
                self._conditions.append('ifInsideSphere(%s, %s, %s, %f)' % (convertName(node.get("name")), x1, y1, r))
            elif node.tag == 'if_outside_sphere':
                x1, y1 = convertPosition(node.get('centerX'), node.get('centerZ'))
                r = float(node.get('radius'))
                self._conditions.append('ifOutsideSphere(%s, %s, %s, %f)' % (convertName(node.get("name")), x1, y1, r))
            elif node.tag == 'if_docked':
                self._conditions.append('ifdocked(%s)' % (convertName(node.get("name"))))
            elif node.tag == 'if_fleet_count':
                self._conditions.append('countFleet(%d) %s %f' % (int(node.get('fleetnumber', 0)), convertComparator(node), float(node.get('value'))))
            elif node.tag == 'if_distance':
                self._conditions.append('(%s ~= nil and %s ~= nil and %s:isValid() and %s:isValid() and distance(%s, %s) %s %f)' % (convertName(node.get('name1')), convertName(node.get('name2')), convertName(node.get('name1')), convertName(node.get('name2')), convertName(node.get('name1')), convertName(node.get('name2')), convertComparator(node), float(node.get('value'))))
            elif node.tag == 'if_exists':
                self._conditions.append('(%s ~= nil and %s:isValid())' % (convertName(node.get('name')), convertName(node.get('name'))))
            elif node.tag == 'if_not_exists':
                self._conditions.append('(%s == nil or not %s:isValid())' % (convertName(node.get('name')), convertName(node.get('name'))))
            elif node.tag == 'if_player_is_targeting':
                self._conditions.append('(%s ~= nil and %s:isValid() and getPlayerShip(-1):getTarget() == %s)' % (convertName(node.get('name')), convertName(node.get('name')), convertName(node.get('name'))))
            elif node.tag == 'if_damcon_members':
                self.damcon_condition += 1
                break
            else:
                raise UnknownArtemisTagError(node)
                self.warning('Ignore', node)

        if self.set_end_tag:
            self._body.append('end)')
            self.set_end_tag = False

        # Convert the AI statements to EE AI.
        for name, ai in self._ai_info.items():
            ai_list = sorted(list(ai.keys()))
            if ai_list == ['ATTACK'] or ai_list == ['ATTACK', 'ELITE_AI'] or ai_list == ['ATTACK', 'CLEAR'] or ai_list == ['ATTACK', 'CHASE_NEUTRAL']:
                self._body.append('%s:orderAttack(%s)' % (name, convertName(ai['ATTACK']['targetName'])))
            elif ai_list == ['POINT_THROTTLE'] or ai_list == ['FOLLOW_COMMS_ORDERS', 'POINT_THROTTLE'] or ai_list == ['CHASE_PLAYER', 'POINT_THROTTLE']:
                x, y = convertPosition(ai['POINT_THROTTLE']['value1'], ai['POINT_THROTTLE']['value3'])
                self._body.append('if %s ~= nil and %s:isValid() then' % (name, name))
                self._body.append('    %s:orderFlyTowards(%s, %s)' % (name, x, y))
                self._body.append('end')
            elif ai_list == ['CLEAR']:
                self._body.append('%s:orderIdle()' % (name))
            elif ai_list == ['ELITE_AI']:
                pass
            else:
                self.warning('Unknown AI: %s: %s' % (name, ai))

    def getPlayer(self):
        return self._player

    def parseCreate(self, node):
        if node.get('use_gm_position') is not None:
            return
        create_type = node.get('type')
        if create_type == 'player':
            name = convertName(node.get('name'))
            x, y = convertPosition(node.get('x'), node.get('z'))
            self._body.append('%s = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Player Cruiser"):setCallSign("%s"):setPosition(%s, %s)' % (name, node.get('name'), x, y))
            self._player = name
        elif create_type == 'neutral':
            name = convertName(node.get('name'))
            x, y = convertPosition(node.get('x'), node.get('z'))
            self._body.append('%s = CpuShip():setTemplate("Tug"):setCallSign("%s"):setFaction("%s"):setPosition(%s, %s):orderRoaming()' % (name, node.get('name'), convertRaceKeys(node, 'neutral'), x, y))
            self.addToFleet(name, node)
        elif create_type == 'enemy':
            name = convertName(node.get('name', 'temp_enemy_name'))
            x, y = convertPosition(node.get('x'), node.get('z'))
            self._body.append('%s = CpuShip():setTemplate("Cruiser"):setCallSign("%s"):setFaction("%s"):setPosition(%s, %s):orderRoaming()' % (name, node.get('name'), convertRaceKeys(node, 'enemy'), x, y))
            self.addToFleet(name, node)
            
            self.addToFleet(name, node, 0) # Add every enemy ship to fleet 0
        elif create_type == 'station':
            name = convertName(node.get('name'))
            x, y = convertPosition(node.get('x'), node.get('z'))
            self._body.append('%s = SpaceStation():setTemplate("Small Station"):setCallSign("%s"):setFaction("%s"):setPosition(%s, %s)' % (name, node.get('name'), convertRaceKeys(node, 'friendly'), x, y))
        elif create_type == 'blackHole':
            name = convertName(node.get('name', 'temp_blackhole_name'))
            x, y = convertPosition(node.get('x'), node.get('z'))
            self._body.append('%s = BlackHole():setPosition(%s, %s)' % (name, x, y))
        elif create_type == 'whale':
            self.warning('Ignore', node)
        elif create_type == 'monster':
            self.warning('Ignore', node)
        elif create_type == 'genericMesh':
            self.warning('Ignore', node)
        elif create_type == 'anomaly':
            # Using a supply drop instead of an anomaly
            output = ""
            if node.get('name') is not None:
                name = convertName(node.get('name'))
                output = "%s = " % (name)
            x, y = convertPosition(node.get('x'), node.get('z'))
            output += 'SupplyDrop():setFaction("Human Navy"):setPosition(%s, %s):setEnergy(500):setWeaponStorage("Nuke", 0):setWeaponStorage("Homing", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)' % (x, y)
            self._body.append(output)
        elif create_type == 'asteroids':
            self.parseCreateCount('Asteroid()', node)
        elif create_type == 'mines':
            self.parseCreateCount('Mine()', node)
        elif create_type == 'nebulas':
            node.set('count', '(%s + 24) / 25' % convertFloat(node.get('count')))
            if node.get('randomRange') is not None:
                node.set('randomRange', '%s - 2500' % convertFloat(node.get('randomRange')))
            self.parseCreateCount('Nebula()', node)
        else:
            raise UnknownArtemisTagError(node)
    
    def parseCreateCount(self, object_create_script, node):
        count = int(eval    (str(node.get('count')), {}, {}))
        x, y = convertPosition(node.get('startX', 0), node.get('startZ', 0))
        if count == 1:
            self._body.append('%s:setPosition(%s, %s)' % (object_create_script, x, y))
        else:
            self._body.append('tmp_count = %s' % (count))
            self._body.append('for tmp_counter=1,tmp_count do')
            if node.get('radius') is not None:
                radius = convertFloat(node.get('radius'))
                start_angle = float(node.get('startAngle', 0)) - 90
                end_angle = float(node.get('endAngle', 360)) - 90
                self._body.append('    tmp_x, tmp_y = vectorFromAngle(%s + (%s - %s) * (tmp_counter - 1) / tmp_count, %s)' % (start_angle, end_angle, start_angle, radius))
                self._body.append('    tmp_x, tmp_y = tmp_x + %s, tmp_y + %s' % (x, y))
            else:
                x2, y2 = convertPosition(node.get('endX'), node.get('endZ'))
                self._body.append('    tmp_x = %s + (%s - %s) * (tmp_counter - 1) / tmp_count' % (x, x2, x))
                self._body.append('    tmp_y = %s + (%s - %s) * (tmp_counter - 1) / tmp_count' % (y, y2, y))
            if node.get('randomRange') is not None:
                random_range = convertFloat(node.get('randomRange', 0))
                self._body.append('    tmp_x2, tmp_y2 = vectorFromAngle(random(0, 360), random(0, %s))' % (random_range))
                self._body.append('    tmp_x, tmp_y = tmp_x + tmp_x2, tmp_y + tmp_y2')
            self._body.append('    %s:setPosition(tmp_x, tmp_y)' % (object_create_script))
            self._body.append('end')


    def addToFleet(self, name, node, fleetnumber=-1):
        if fleetnumber != -1:
            fleetnumber = int(node.get('fleetnumber', -1))
        if fleetnumber > 0:
            if 'fleet_check_%d' % (fleetnumber) not in self._done:
                self._done['fleet_check_%d' % (fleetnumber)] = True
                self._body.append('if fleet[%d] == nil then fleet[%d] = {} end' % (fleetnumber, fleetnumber))
            self._body.append('table.insert(fleet[%d], %s)' % (fleetnumber, name))
    
    def warning(self, *args):
        message = ''
        for arg in args:
            if isinstance(arg, str):
                message += arg + ' '
            elif isinstance(arg, xml.etree.ElementTree.Element):
                message += '<' + arg.tag + '> ' + str(arg.attrib) + ' '
                if arg.text is not None:
                    message += convertString(arg.text)
            else:
                message += str(arg)
        self._body.append('--WARNING: %s' % (message))
        self._warnings.append(args)

    def getBody(self, indent=1):
        body = ''
        for line in self._body:
            body += ('    ' * indent) + line + '\n';
        return body
    
    def getCondition(self):
        return ' and '.join(self._conditions)
    
    def getWarnings(self):
        return self._warnings
    
    def isValid(self):
        return self._valid

class Converter:
    def __init__(self, filename):
        self._data = xml.etree.ElementTree.XML(open(filename, 'rb').read().replace(b'"<="', b'"&lt;="').replace(b'"<"', b'"&lt;"').replace(b'">="', b'"&gt;="').replace(b'">"', b'"&gt;"'))
        
        self._events = []
        self._start_event = Event(self._data.find("start"))
        for node in self._data.findall("event"):
            self._events.append(Event(node, self._start_event.getPlayer()))
    
    def export(self, name, filename):
        f = open(filename, "w")
        f.write('-- Name: %s\n' % (name))
        f.write('-- Description: Converted Artemis mission\n')
        warnings = []
        for line in open("artemis_mission_convert_template.lua", "r"):
            if line.strip() == '###START###':
                f.write(self._start_event.getBody())
                warnings += self._start_event.getWarnings()
            elif line.strip() == '###EVENTS###':
                for event in self._events:
                    if not event.isValid():
                        continue
                    if event.getCondition() != "":
                        f.write("    if %s then\n" % event.getCondition())
                        f.write(event.getBody(2))
                        warnings += event.getWarnings()
                        f.write("    end\n")
                    else:
                        f.write(event.getBody(1))
                        warnings += event.getWarnings()
            else:
                f.write(line)
        print('Written: %s with %d warnings' % (filename, len(warnings)))
        warning_types = {}
        for warning in warnings:
            for item in warning:
                if isinstance(item, xml.etree.ElementTree.Element):
                    if item.tag not in warning_types:
                        warning_types[item.tag] = 0
                    warning_types[item.tag] += 1
        for key, count in warning_types.items():
            print("Warning: %s %dx" % (key, count))
        return len(warning_types) == 0

if __name__ == "__main__":
    count = 0
    success = 0
    for arg in sys.argv[1:]:
        if os.path.isfile(arg):
            filename = arg
            count += 1
            print("========================================================");
            print("Converting: ", filename);
            try:
                c = Converter(filename)
                name = os.path.splitext(os.path.basename(filename))[0].replace("MISS_", "")
                c.export(name, "scripts/scenario_99_%s.lua" % (name))
                success += 1
            except:
                traceback.print_exc()
        for root, dirnames, filenames in os.walk(arg):
            for filename in fnmatch.filter(filenames, '*.xml'):
                filename = os.path.join(root, filename)
                count += 1
                print("========================================================");
                print("Converting: ", filename);
                try:
                    c = Converter(filename)
                    name = os.path.splitext(os.path.basename(filename))[0].replace("MISS_", "")
                    if c.export(name, "scripts/scenario_99_%s.lua" % (name)):
                        sys.exit(1)
                    success += 1
                except:
                    traceback.print_exc()
                    sys.exit(1)
    print("Converted %d of the %d scripts" % (success, count))
