# Python script that generates the documentation for script functions.
#
# This parses the codeblocks to find all the source files, then parses
# all of the source files for script macros.
#
# It then outputs all the documentation (comments starting with `///`)
# as HTML to stdout so it can be stored on disk.
#
# The optional command-line argument is used as target file,
# e.g. `python compile_script_docs.py script_reference.html`.
#
# This script should run in both Python 2 and 3.
import re
import os
import sys

# Use io.open instead of open to ignore text encoding errors in both
# Python 2 and 3.
import io

try:
    from xml.etree import cElementTree as ElementTree
except:
    from xml.etree import ElementTree


class ScriptFunction(object):
    def __init__(self, name):
        self.name = name
        self.description = ""
        self.origin_class = None
        self.return_type = None
        self.parameters = None

    def get_parameters(self):
        if self.parameters is None: return []

        ret = []

        current_arg = ""
        bracket_counter = 0

        for letter in self.parameters:
            if letter == "," and bracket_counter == 0:
                current_arg = current_arg.strip()
                last_space = current_arg.rindex(' ')
                name = current_arg[last_space:].strip()
                c_type = current_arg[:(last_space + 1)].strip()
                ret.append((translate_type(c_type, name), name))
                current_arg = ""
                continue

            current_arg += letter
            if letter == '<': bracket_counter += 1
            if letter == '>': bracket_counter -= 1

        current_arg = current_arg.strip()
        if current_arg != "":
            last_space = current_arg.rindex(' ')
            name = current_arg[last_space:].strip()
            c_type = current_arg[:(last_space + 1)].strip()
            ret.append((translate_type(c_type, name), name))

        return ret

    def __repr__(self):
        ret = self.name
        return "%s" % (ret)


class ScriptMember(object):
    def __init__(self, name):
        self.name = name
        self.description = ""
        self.origin_class = None

    def __repr__(self):
        ret = self.name
        return "%s" % (ret)


class ScriptClass(object):
    def __init__(self, name):
        self.name = name
        self.parent_name = None
        self.parent = None
        self.description = ""
        self.children = []
        self.create = True
        self.functions = []
        self.members = []
        self.callbacks = []

    def addFunction(self, function_name):
        self.functions.append(ScriptFunction(function_name))
        return self.functions[-1]

    def addMember(self, member_name):
        self.members.append(ScriptMember(member_name))
        return self.members[-1]

    def addCallback(self, callback_name):
        self.callbacks.append(callback_name)
        return self.callbacks[-1]

    def __repr__(self):
        ret = self.name
        if self.parent is not None:
            ret += "(%s)" % (self.parent.name)
        for func in self.functions:
            ret += ":%s" % (func)
        return "{%s}" % (ret)


class ClassType(object):
    def __init__(self, name):
        self.name = name


class ListType(object):
    def __init__(self, base_type):
        self.base_type = base_type


class TupleType(object):
    def __init__(self, type_name_pairs):
        self.type_name_pairs = type_name_pairs


class OptionalType(object):
    def __init__(self, base_type):
        self.base_type = base_type


class VariadicType(object):
    def __init__(self, base_type):
        self.base_type = base_type


class TableType(object):
    def __init__(self, key, value):
        self.key = key
        self.value = value


class EnumType(object):
    def __init__(self, name):
        self.name = name


VEC2 = TupleType([("number", "x"), ("number", "y")])
VEC3 = TupleType([("number", "x"), ("number", "y"), ("number", "z")])
COLVEC3 = TupleType([("number", "r"), ("number", "g"), ("number", "b")])


def translate_type(c_type, name):
    if c_type is None: return None

    c_type = c_type.replace('virtual ', '')
    c_type = c_type.replace('unsigned ', '')

    if c_type == "void": return None

    # C++ doesn't really know functions with variadic return, lua does. So we use this to approximate
    # This can only be used if an alternative parameter list is given via comments on the c++ side
    if c_type.endswith("..."):
        return VariadicType(translate_type(c_type[:-3].strip(), name))

    if c_type.startswith("const"):
        return translate_type(c_type[5:].strip(), name)

    res = re.search("^PVector<([^>]+)>$", c_type)
    if res is not None:
        return ListType(translate_type("P<%s>" % (res.group(1).strip()), name))

    res = re.search("^std::optional<([^>]+)>$", c_type)
    if res is not None:
        return OptionalType(translate_type(res.group(1).strip(), name))

    res = re.search("^std::map<([^,>]+),([^,>]+)>$", c_type)
    if res is not None:
        return TableType(translate_type(res.group(1).strip(), name), translate_type(res.group(2).strip(), name))

    res = re.search("^P<([^>]+)>$", c_type)
    if res is not None:
        return ClassType(res.group(1).strip())

    res = re.search("^std::vector<([^>]+)>&?$", c_type)
    if res is not None:
        return VariadicType(translate_type(res.group(1).strip(), name))

    if c_type in ('EAlertLevel', 'ECrewPosition', 'EMissileSizes', 'EMissileWeapons', 'EScannedState', 'ESystem', 'EMainScreenSetting', 'EMainScreenOverlay', 'EDockingState', 'ScriptSimpleCallback'):
        return EnumType(c_type)

    if c_type in ('int', 'float', 'double', 'int32_t', 'int8_t', 'uint32_t', 'uint8_t'):
        return 'number'

    if c_type == "bool":
        return 'boolean'

    if c_type == "glm::vec2" or c_type == "glm::ivec2":
        return VEC2

    if c_type == "glm::vec3":
        if 'color' in name.lower():
            return COLVEC3
        return VEC3

    if c_type == "glm::u8vec4":
        return EnumType("Color")

    if c_type == "std::string_view":
        return 'string'

    return c_type


class DocumentationGenerator(object):
    def __init__(self):
        self._definitions = []
        self._function_info = []
        self._files = set()

    def addDirectory(self, directory):
        if not os.path.isdir(directory):
            return

        for name in os.listdir(directory):
            name = directory + os.sep + name
            if os.path.isdir(name):
                self.addDirectory(name)
            elif os.path.isfile(name):
                self.addFile(name)

    def addFile(self, filename):
        if filename in self._files:
            return
        if not os.path.isfile(filename):
            return

        self._files.add(filename)
        ext = os.path.splitext(filename)[1].lower()
        if ext == ".c" or ext == ".cpp" or ext == ".h":
            for line in io.open(filename, "r", errors="ignore"):
                m = re.match('^# *include *[<"](.*)[>"]$', line)
                if m is not None:
                    self.addFile(m.group(1))
                    self.addFile(os.path.join(os.path.dirname(filename), m.group(1)))

    def readFunctionInfo(self):
        for filename in sorted(self._files):
            # scriptDataStorage.cpp has no header file. If we start needing this workaround for multiple files,
            # we might want to look for a smarter solution for this
            if not filename.endswith(".h") and not filename.endswith("scriptDataStorage.cpp"):
                continue
            description = ""
            current_class = None
            with io.open(filename, "r", errors="ignore") as f:
                for line in f:
                    if line.startswith("#"):
                        continue
                    res = re.search("([a-zA-Z0-9 \:\<\>_,]+) +([a-zA-Z0-9]+)::([a-zA-Z0-9]+)\(([^\)]*)\)", line)
                    if res != None:
                        self._function_info.append(
                            (res.group(1), res.group(2), res.group(3), res.group(4))
                        )
                    res = re.search("^class ([a-zA-Z0-9]+)", line)
                    if res != None:
                        current_class = res.group(1)
                    if current_class is not None:
                        res = re.search(
                            "^ *([a-zA-Z0-9 \:\<\>_,]+) +([a-zA-Z0-9]+)\(([^\)]*)\)", line
                        )
                        if res != None and res.group(2) != "" and res.group(1) != "return":
                            self._function_info.append(
                                (res.group(1), current_class, res.group(2), res.group(3))
                            )

    def readScriptDefinitions(self):
        for filename in sorted(self._files):
            description = ""
            current_class = None
            # print("Processing: %s" % (filename))
            for line in io.open(filename, "r", errors="ignore"):
                if line.startswith("#"):
                    continue
                res = re.search("///(.*)", line)
                if res != None:
                    if description != "":
                        description += "\n"
                    description += res.group(1)
                    continue
                res = re.search("REGISTER_SCRIPT_CLASS\(([^\)]*)\)", line)
                if res != None:
                    current_class = ScriptClass(res.group(1).strip())
                    current_class.description = description
                    self._definitions.append(current_class)
                res = re.search("REGISTER_SCRIPT_CLASS_NO_CREATE\(([^\)]*)\)", line)
                if res != None:
                    current_class = ScriptClass(res.group(1).strip())
                    current_class.create = False
                    current_class.description = description
                    self._definitions.append(current_class)
                res = re.search("REGISTER_SCRIPT_SUBCLASS\(([^,]*),([^\)]*)\)", line)
                if res != None:
                    current_class = ScriptClass(res.group(1).strip())
                    current_class.parent_name = res.group(2).strip()
                    current_class.description = description
                    self._definitions.append(current_class)
                res = re.search(
                    "REGISTER_SCRIPT_SUBCLASS_NO_CREATE\(([^,]*),([^\)]*)\)", line
                )
                if res != None:
                    current_class = ScriptClass(res.group(1).strip())
                    current_class.parent_name = res.group(2).strip()
                    current_class.create = False
                    current_class.description = description
                    self._definitions.append(current_class)

                res = re.search(
                    "REGISTER_SCRIPT_CLASS_FUNCTION\(([^,]*),([^\)]*)\)", line
                )
                if res != None:
                    func = current_class.addFunction(res.group(2).strip())
                    func.description = description
                    func.origin_class = res.group(1).strip()
                res = re.search(
                    "REGISTER_SCRIPT_CLASS_CALLBACK\(([^,]*),([^\)]*)\)", line
                )
                if res != None:
                    current_class.addCallback(res.group(2).strip())

                res = re.search("REGISTER_SCRIPT_FUNCTION\(([^\)]*)\)", line)
                if res != None:
                    current_class = None
                    name = res.group(1).strip()
                    func = ScriptFunction(name)
                    self._definitions.append(func)

                    if "\n" in description:
                        first_line_break = description.index("\n")
                        first_line = description[:first_line_break].strip()
                        description = description[first_line_break:].strip()
                    else:
                        first_line = description
                        description = ""
                    res_first = re.search("([a-zA-Z0-9 \:\<\>_,]+) " + name + " *\(([^\)]*)\)", first_line)
                    if res_first is None:
                        raise Exception("Lua function `%s` has no parameter description in its comment.\nTry adding "
                                        "`/// return_type %s (parameters)` as the first line of the description before\n"
                                        "the call to `REGISTER_SCRIPT_FUNCTION(%s)` in '%s'" % (name, name, name, filename))
                    func.return_type = res_first.group(1).strip()
                    func.parameters = res_first.group(2).strip()
                    func.description = description
                description = ""

    def linkFunctions(self):
        for return_type, class_name, function_name, parameters in self._function_info:
            for definition in self._definitions:
                if isinstance(definition, ScriptClass):
                    for func in definition.functions:
                        if (
                            func.origin_class == class_name
                        ) and func.name == function_name:
                            func.return_type = return_type
                            func.parameters = parameters

    def linkParents(self):
        for definition in self._definitions:
            if isinstance(definition, ScriptClass):
                if definition.parent_name is not None:
                    for d in self._definitions:
                        if d.name == definition.parent_name:
                            definition.parent = d
                            d.children.append(definition)
                    if definition.parent is None:
                        print("Parent not found for: ", definition)
                else:
                    f = definition.addFunction("isValid")
                    f.parameters = ""
                    f.return_type = "boolean"
                    f.description = "Returns whether this object is still valid. Returns false if this object was destroyed or doesn't exist."
                    f = definition.addFunction("destroy")
                    f.parameters = ""
                    f.description = "Removes this object from the game."
                    f = definition.addMember("typeName")
                    f.description = 'Returns the class name of this object. This is not a function, but a direct member. Example: if object.typeName == "Mine" then print("MINE!") end'

    def generateDocs(self, stream):
        stream.write('<!doctype html><html lang="us"><head><meta charset="utf-8"><title>EmptyEpsilon - Scripting documentation</title>')

        stream.write(
            """
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link
href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:ital,wght@0,400;0,700;1,400&display=swap"
rel="stylesheet"
/>
<link href="https://daid.github.io/EmptyEpsilon/bebasneue.css" rel="stylesheet" />

<style>
  body {
    color: #ffffff;
    background-color: #050505;
    font-size: 12px;
    line-height: 1.7;
    margin: 50px 0;
  }
  
  h1, h2 {
    margin-top: 0;
  }
  
  a {
    color: #ffffff;
  }

  h2 {
    font: 2em bebas_neuebold, Impact, sans-serif;
    padding: 16px 0;
    margin-top: 0;
    margin-bottom: 0;
    position: sticky;
    top: 0;
    background: rgba(16, 19, 23, 0.8);
    scroll-margin-top: 0;
    font-weight: normal;
  }

  .section {
    font-size: 1.3em;
    font-family: "JetBrains Mono", "Courier New", Courier, monospace;
    background: rgba(16, 19, 23, 0.8);
    padding: 2rem 20px;
    margin-bottom: 2rem;
  }

  dl {
    padding-bottom: 2rem;
  }

  ul {
    padding-left: 0;
  }

  ul > li {
    list-style-type: none;
    font-weight: bold;
    line-height: 2.5rem;
    background: rgba(36, 40, 44, 0.8);
    padding-left: 1rem;
    border-top: 1px solid rgba(255, 255, 255, 0.1);
  }

  ul > li > ul {
    background-color: rgba(255, 255, 255, 0.05);
  }

  ul > li > ul > li {
    border: 0;
    background-color: rgba(36, 40, 44, 0.2);
  }

  dt {
    font-weight: bold;
    line-height: 2.5rem;
    background: rgba(36, 40, 44, 0.8);
    padding-left: 1rem;
    border-top: 1px solid rgba(255, 255, 255, 0.1);
  }

  dd {
    margin-left: 0;
    padding-top: 0.5rem;
    padding-left: 2rem;
    padding-bottom: 0.5rem;
    background: rgba(55, 62, 70, 0.2);
  }

  dd:empty {
    display: none;
  }

  li > dd {
    background: rgba(16, 19, 23, 0.8);
    margin-left: -1rem;
  }
</style>
"""
        )

        stream.write("</head>")
        stream.write("<body>")

        stream.write('<div class="section">')
        stream.write("<h1>EmptyEpsilon Scripting Reference</h1>")
        stream.write("<p>This is the EmptyEpsilon script reference for this version of EmptyEpsilon.</p>")
        stream.write('<p>By no means this is a guide to help you scripting, you should check <a href="https://daid.github.io/EmptyEpsilon/#tabs=4">EmptyEpsilon website</a> for the guide on scripting. ')
        stream.write("As well as check the already existing scenario and ship data files on how to get started.</p>")
        stream.write("</div>\n")

        # TODO modify the script and read the constants from the cpp files
        stream.write('<div class="section">')
        stream.write("<p>Some of the types in the parameters:</p>")
        stream.write("<ul>\n")
        stream.write('<li><a name="enum_Color">Color</a>: A string that can either be a hex color code (#rrggbb), three comma-separated rgb integers (rrr,ggg,bbb), or one of the following: "black", "white", "red", "green", "blue", "yellow", "magenta", "cyan". Invalid values default to white.</li>\n')
        stream.write('<li><a name="enum_EAlertLevel">EAlertLevel<a/>: sets "normal", "yellow", "red" (<code>playerSpaceship.hpp</code>), returns "Normal", "YELLOW ALERT", "RED ALERT" (<code>playerSpaceship.cpp</code>)</li>\n')
        stream.write('<li><a name="enum_ECrewPosition">ECrewPosition</a>: "Helms", "Weapons", "Engineering", "Science", "Relay", "Tactical", "Engineering+", "Operations", "Single", "DamageControl", "PowerManagement", "Database", "AltRelay", "CommsOnly", "ShipLog", "ShipWindow" (<code>playerInfo.cpp</code>)</li>\n')
        stream.write('<li><a name="enum_EDockingState">EDockingState</a>: 0 (not docking), 1 (docking), 2 (docked) (<code>spaceship.h</code>)</li>\n')
        stream.write('<li><a name="enum_EMainScreenOverlay">EMainScreenOverlay</a>: "hidecomms", "showcomms" (<code>spaceship.hpp</code>)</li>\n')
        stream.write('<li><a name="enum_EMainScreenSetting">EMainScreenSetting</a>: "front", "back", "left", "right", "target", "tactical", "longrange" (<code>spaceship.hpp</code>)</li>\n')
        stream.write('<li><a name="enum_EMissileSizes">EMissileSizes</a>: "small", "medium", "large" (<code>missileWeaponData.hpp</code>)</li>\n')
        stream.write('<li><a name="enum_EMissileWeapons">EMissileWeapons</a>: "Homing", "Nuke", "Mine", "EMP", "HVLI" (<code>missileWeaponData.hpp</code>)</li>\n')
        stream.write('<li><a name="enum_EScannedState">EScannedState</a>: "notscanned", "friendorfoeidentified", "simplescan", "fullscan" (<code>spaceObject.h</code>)</li>\n')
        stream.write('<li><a name="enum_ESystem">ESystem</a>: "reactor", "beamweapons", "missilesystem", "maneuver", "impulse", "warp", "jumpdrive", "frontshield", "rearshield"</li>\n')
        stream.write('<li><a name="enum_Factions">Factions</a>: "Independent", "Kraylor", "Arlenians", "Exuari", "Ghosts", "Ktlitans", "TSN", "USN", "CUF" (<code>factionInfo.lua</code>)</li>\n')
        stream.write('<li><a name="enum_ScriptSimpleCallback">ScriptSimpleCallback</a> / function: Note that the callback function must reference something global, otherwise you get an error like "??[convert&lt;ScriptSimpleCallback&gt;::param] Upvalue 1 of function is not a table...". Use e.g. `math.abs(0) -- Provides global context for SeriousProton` to do nothing.</li>\n')
        stream.write("</ul>\n")
        stream.write("<p>Note that most <code>SpaceObject</code>s directly switch to fully scanned, only <code>SpaceShip</code>s go through all the states.</p>")
        stream.write("</div>\n")

        stream.write('<div class="section">')
        stream.write("<h2>Objects</h2>\n")
        stream.write("<ul>")
        for d in self._definitions:
            if isinstance(d, ScriptClass) and d.parent is None:
                self.outputClassTree(d, stream)
        stream.write("</ul>")
        stream.write("</div>")

        stream.write('<div class="section">')
        stream.write("<h2>Functions</h2>\n")
        stream.write("<ul>")
        for d in self._definitions:
            if isinstance(d, ScriptFunction):
                stream.write("<li>")
                stream.write(self.print_type(translate_type(d.return_type, d.name), d.name, True))
                stream.write("(")
                first = True
                for (type, name) in d.get_parameters():
                    if not first:
                        stream.write(", ")
                    first = False
                    stream.write(self.print_type(type, name))
                stream.write(")")
                stream.write(
                    "<dd>%s</dd>"
                    % (d.description.replace("<", "&lt;").replace("\n", "<br>"))
                )
        stream.write("</ul>")
        stream.write("</div>")

        for d in self._definitions:
            if isinstance(d, ScriptClass) and d.parent is None:
                self.outputClasses(d, stream)

        stream.write("</body>")
        stream.write("</html>")

    def outputClassTree(self, scriptClass, stream):
        stream.write('<li><a href="#class_%s">%s</a>\n' % (scriptClass.name, scriptClass.name))
        if len(scriptClass.children) > 0:
            sorted_children = sorted(scriptClass.children, key=lambda definition: definition.name)
            stream.write("<ul>")
            for c in sorted_children:
                self.outputClassTree(c, stream)
            stream.write("</ul>\n")

    def outputClasses(self, scriptClass, stream):
        stream.write('<div class="section">\n')
        stream.write('<a name="class_%s"></a><h2>%s</h2>\n' % (scriptClass.name, scriptClass.name))
        stream.write(
            "<div>%s</div>"
            % (scriptClass.description.replace("<", "&lt;").replace("\n", "<br>"))
        )
        if scriptClass.parent is not None:
            stream.write(
                'Subclass of: <a href="#class_%s">%s</a>'
                % (scriptClass.parent.name, scriptClass.parent.name)
            )
        stream.write("<dl>")
        for func in scriptClass.functions:
            if func.parameters is None:
                stream.write(
                    "<dt>%s:%s [NOT FOUND; see SeriousProton]</dt>"
                    % (scriptClass.name, func.name)
                )
                print("Failed to find parameters for %s:%s" % (scriptClass.name, func.name))
            else:
                stream.write("<dt>")
                type = translate_type(func.return_type, func.name)
                member_name = scriptClass.name + ":" + func.name
                if type is None:
                    # Methods returning void automatically return themselves
                    stream.write(self.print_type(ClassType(scriptClass.name), member_name, True))
                    func.description = (func.description + "\nReturns the object it was called on.").strip()
                else:
                    stream.write(self.print_type(type, member_name, True))
                stream.write("(")
                first = True
                for (type, name) in func.get_parameters():
                    if not first:
                        stream.write(", ")
                    first = False
                    stream.write(self.print_type(type, name))
                stream.write(")</dt>")
            stream.write(
                "<dd>%s</dd>"
                % (func.description.replace("<", "&lt;").replace("\n", "<br>"))
            )
        for member in scriptClass.members:
            stream.write("<dt>%s:%s</dt>" % (scriptClass.name, member.name))
            stream.write(
                "<dd>%s</dd>"
                % (member.description.replace("<", "&lt;").replace("\n", "<br>")
                   )
            )
        stream.write("</dl>")
        stream.write("</div>")
        sorted_children = sorted(scriptClass.children, key=lambda definition: definition.name)
        for c in sorted_children:
            self.outputClasses(c, stream)

    def print_type(self, type, name="", return_value=False):
        if type is None: return name
        if isinstance(type, EnumType): return '<a href="#enum_%s">%s</a> %s' % (type.name, type.name, name)
        if isinstance(type, ClassType): return '<a href="#class_%s">%s</a> %s' % (type.name, type.name, name)
        if isinstance(type, ListType): return '%s[] %s' % (self.print_type(type.base_type).strip(), name)
        if isinstance(type, TableType): return 'table<%s, %s> %s' % (self.print_type(type.key), self.print_type(type.value), name)
        if isinstance(type, OptionalType): return '%s=nil' % (self.print_type(type.base_type, name, return_value))
        if isinstance(type, VariadicType): return '%s...' % (self.print_type(type.base_type, name, return_value))
        if isinstance(type, TupleType):
            ret = ""
            for (sub_type, sub_name) in type.type_name_pairs:
                if return_value:
                    ret += "%s %s, " % (self.print_type(sub_type), sub_name)
                else:
                    ret += "%s %s_%s, " % (self.print_type(sub_type), name, sub_name)

            if return_value:
                return ret.strip().strip(",") + " " + name
            else:
                return ret.strip().strip(",")
        return ("%s %s" % (type, name)).strip()

if __name__ == "__main__":
    dg = DocumentationGenerator()
    dg.addDirectory("src")
    dg.addDirectory("../SeriousProton/src")
    dg.readFunctionInfo()
    dg.readScriptDefinitions()
    dg.linkFunctions()
    dg.linkParents()
    if len(sys.argv) > 1:
        dg.generateDocs(open(sys.argv[1], "wt"))
    else:
        dg.generateDocs(sys.stdout)
