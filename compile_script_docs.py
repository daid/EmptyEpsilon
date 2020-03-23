# Python script that generates the documentation for script functions.
#
# This parses the codeblocks to find all the source files, then parses
# all of the source files for script macros.
#
# It then outputs all the documentation (comments starting with `///`)
# as HTML to stdout so it can be stored on disk.
#
# This script should run in both Python 2 and 3.
import re
import os
import sys
try:
	from xml.etree import cElementTree as ElementTree
except:
	from xml.etree import ElementTree

class ScriptFunction(object):
	def __init__(self, name):
		self.name = name
		self.description = ""
		self.origin_class = None
		self.parameters = None

	def __repr__(self):
		ret = self.name
		return '%s' % (ret)

class ScriptMember(object):
	def __init__(self, name):
		self.name = name
		self.description = ""
		self.origin_class = None

	def __repr__(self):
		ret = self.name
		return '%s' % (ret)

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
			ret += '(%s)' % (self.parent.name)
		for func in self.functions:
			ret += ':%s' % (func)
		return '{%s}' % (ret)
	
	def outputClassTree(self, stream):
		stream.write('<li><a href="#class_%s">%s</a>\n' % (self.name, self.name))
		if len(self.children) > 0:
			stream.write('<ul>')
			for c in self.children:
				c.outputClassTree(stream)
			stream.write('</ul>\n')

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
        if ext == '.c' or ext == '.cpp' or ext == '.h':
            for line in open(filename, "r"):
                m = re.match('^# *include *[<"](.*)[>"]$', line)
                if m is not None:
                    self.addFile(m.group(1))
                    self.addFile(os.path.join(os.path.dirname(filename), m.group(1)))
    
    def readFunctionInfo(self):
        for filename in self._files:
            if not filename.endswith('.h'):
                continue
            description = ""
            current_class = None
            with open(filename, "r") as f:
                for line in f:
                    if line.startswith('#'):
                        continue
                    res = re.search('([a-zA-Z0-9]+)::([a-zA-Z0-9]+)\(([^\)]*)\)', line)
                    if res != None:
                        self._function_info.append((res.group(1), res.group(2), res.group(3)))
                    res = re.search('^class ([a-zA-Z0-9]+)', line)
                    if res != None:
                        current_class = res.group(1)
                    if current_class is not None:
                        res = re.search('^ *([a-zA-Z0-9 \:\<\>]+) +([a-zA-Z0-9]+)\(([^\)]*)\)', line)
                        if res != None and res.group(2) != '':
                            self._function_info.append((current_class, res.group(2), res.group(3)))
    
    def readScriptDefinitions(self):
        for filename in self._files:
            description = ""
            current_class = None
            #print("Processing: %s" % (filename))
            for line in open(filename, "r"):
                if line.startswith('#'):
                    continue
                res = re.search('///(.*)', line)
                if res != None:
                    description += res.group(1)
                    continue
                res = re.search('REGISTER_SCRIPT_CLASS\(([^\)]*)\)', line)
                if res != None:
                    current_class = ScriptClass(res.group(1).strip())
                    current_class.description = description
                    self._definitions.append(current_class)
                res = re.search('REGISTER_SCRIPT_CLASS_NO_CREATE\(([^\)]*)\)', line)
                if res != None:
                    current_class = ScriptClass(res.group(1).strip())
                    current_class.create = False
                    current_class.description = description
                    self._definitions.append(current_class)
                res = re.search('REGISTER_SCRIPT_SUBCLASS\(([^,]*),([^\)]*)\)', line)
                if res != None:
                    current_class = ScriptClass(res.group(1).strip())
                    current_class.parent_name = res.group(2).strip()
                    current_class.description = description
                    self._definitions.append(current_class)
                res = re.search('REGISTER_SCRIPT_SUBCLASS_NO_CREATE\(([^,]*),([^\)]*)\)', line)
                if res != None:
                    current_class = ScriptClass(res.group(1).strip())
                    current_class.parent_name = res.group(2).strip()
                    current_class.create = False
                    current_class.description = description
                    self._definitions.append(current_class)

                res = re.search('REGISTER_SCRIPT_CLASS_FUNCTION\(([^,]*),([^\)]*)\)', line)
                if res != None:
                    func = current_class.addFunction(res.group(2).strip())
                    func.description = description
                    func.origin_class = res.group(1).strip()
                res = re.search('REGISTER_SCRIPT_CLASS_CALLBACK\(([^,]*),([^\)]*)\)', line)
                if res != None:
                    current_class.addCallback(res.group(2).strip())

                res = re.search('REGISTER_SCRIPT_FUNCTION\(([^\)]*)\)', line)
                if res != None:
                    current_class = None
                    self._definitions.append(ScriptFunction(res.group(1).strip()))
                    self._definitions[-1].description = description
                description = ""
    
    def linkFunctions(self):
        for class_name, function_name, parameters in self._function_info:
            for definition in self._definitions:
                if isinstance(definition, ScriptClass):
                    for func in definition.functions:
                        if (func.origin_class == class_name) and func.name == function_name:
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
                    f = definition.addFunction('isValid')
                    f.parameters = ''
                    f.description = 'Check if this is still looking at a valid object. Returns false when the objects that this variable references is destroyed.'
                    f = definition.addFunction('destroy')
                    f.parameters = ''
                    f.description = 'Removes this object from the game.'
                    f = definition.addMember('typeName')
                    f.description = 'Returns the class name of this object, this is not a function, but a direct member: if object.typeName == "Mine" then print("MINE!") end'

    def generateDocs(self, stream):
        stream.write('<!doctype html><html lang="us"><head><meta charset="utf-8"><title>EmptyEpsilon - Scripting documentation</title>')
        stream.write('<link href="http://daid.github.io/EmptyEpsilon/jquery-ui.min.css" rel="stylesheet">')
        stream.write('<link href="http://daid.github.io/EmptyEpsilon/main.css" rel="stylesheet">')
        stream.write('</head>')
        stream.write('<body>')

        stream.write('<div class="ui-widget ui-widget-content ui-corner-all">')
        stream.write('<h1>EmptyEpsilon Scripting Reference</h1>')
        stream.write('This is the EmptyEpsilon script reference for this version of EmptyEpsilon. By no means this is a guide to help you scripting, you should check <a href="http://emptyepsilon.org/">emptyepsilon.org</a> for the guide on scripting.')
        stream.write('As well as check the already existing scenario and ship data files on how to get started.')
        stream.write('</div>')

        stream.write('<div class="ui-widget ui-widget-content ui-corner-all">')
        stream.write('<h2>Objects</h2>\n')
        stream.write('<ul>')
        for d in self._definitions:
            if isinstance(d, ScriptClass) and d.parent is None:
                d.outputClassTree(stream)
        stream.write('</ul>')
        stream.write('</div>')

        stream.write('<div class="ui-widget ui-widget-content ui-corner-all">')
        stream.write('<h2>Functions</h2>\n')
        stream.write('<ul>')
        for d in self._definitions:
            if isinstance(d, ScriptFunction):
                stream.write('<li>%s' % (d.name))
                stream.write('<dd>%s</dd>' % (d.description.replace('<', '&lt;')))
        stream.write('</ul>')
        stream.write('</div>')

        for d in self._definitions:
            if isinstance(d, ScriptClass):
                stream.write('<div class="ui-widget ui-widget-content ui-corner-all">\n')
                stream.write('<h2><a name="class_%s">%s</a></h2>\n' % (d.name, d.name))
                stream.write('<div>%s</div>' % (d.description.replace('<', '&lt;')))
                if d.parent is not None:
                    stream.write('Subclass of: <a href="#class_%s">%s</a>' % (d.parent.name, d.parent.name))
                stream.write('<dl>')
                for func in d.functions:
                    if func.parameters is None:
                        stream.write('<dt>%s:%s [NOT FOUND; see SeriousProton]</dt>' % (d.name, func.name))
                        print("Failed to find parameters for %s:%s" % (d.name, func.name))
                    else:
                        stream.write('<dt>%s:%s(%s)</dt>' % (d.name, func.name, func.parameters.replace('<', '&lt;')))
                    stream.write('<dd>%s</dd>' % (func.description.replace('<', '&lt;')))
                for member in d.members:
                    stream.write('<dt>%s:%s</dt>' % (d.name, member.name))
                    stream.write('<dd>%s</dd>' % (member.description.replace('<', '&lt;')))
                stream.write('</dl>')
                stream.write('</div>')

        stream.write('<script src="http://daid.github.io/EmptyEpsilon/jquery.min.js"></script>')
        stream.write('<script src="http://daid.github.io/EmptyEpsilon/jquery-ui.min.js"></script>')
        stream.write('</body>')
        stream.write('</html>')

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
