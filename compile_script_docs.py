# Python script that generates the documentation for script functions.
# This parses the codeblocks for to find all the source files, then parses all the source files for script macros.
# Finally it outputs all the documentation to stdout so it can be stored on disk.
# This script should run in both python2 and python3
import re
import os
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

class ScriptClass(object):
	def __init__(self, name):
		self.name = name
		self.parent_name = None
		self.parent = None
		self.description = ""
		self.children = []
		self.create = True
		self.functions = []
		self.callbacks = []
	
	def addFunction(self, function_name):
		self.functions.append(ScriptFunction(function_name))
		return self.functions[-1]

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
	
	def outputClassTree(self):
		print('<li><a href="#class_%s">%s</a>' % (self.name, self.name))
		if len(self.children) > 0:
			print('<ul>')
			for c in self.children:
				c.outputClassTree()
			print('</ul>')

class DocumentationGenerator(object):
    def __init__(self):
        self._definitions = []
        self._function_info = []
        self._files = set()
    
    def addFile(self, filename):
        if filename in self._files:
            return
        if not os.path.isfile(filename):
            return
        
        self._files.add(filename)
        ext = os.path.splitext(filename)[1].lower()
        if ext == '.cbp':
            xml = ElementTree.parse(filename)
            for project in xml.findall('Project'):
                for unit in project.findall('Unit'):
                    self.addFile(unit.attrib['filename'])
        elif ext == '.c' or ext == '.cpp' or ext == '.h':
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
                    res = re.search('^ *class ([a-zA-Z0-9]+)', line)
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
                    f = definition.addFunction('typeName')
                    f.parameters = ''
                    f.description = 'Returns the class name of this object.'
                    f = definition.addFunction('destroy')
                    f.parameters = ''
                    f.description = 'Removes this object from the game.'

    def generateDocs(self):
        print('<!doctype html><html lang="us"><head><meta charset="utf-8"><title>EmptyEpsilon - Scripting documentation</title>')
        print('<link href="http://daid.github.io/EmptyEpsilon/jquery-ui.min.css" rel="stylesheet">')
        print('<link href="http://daid.github.io/EmptyEpsilon/main.css" rel="stylesheet">')
        print('</head>')
        print('<body>')

        print('<div class="ui-widget ui-widget-content ui-corner-all">')
        print('<h1>Info</h1>')
        print('This is the EmptyEpsilon script reference for this version of EmptyEpsilon. By no means this is a guide to help you scripting, you should check <a href="http://emptyepsilon.org/">emptyepsilon.org</a> for the guide on scripting.')
        print('As well as check the already existing scenario and ship data files on how to get started.')
        print('</div>')

        print('<div class="ui-widget ui-widget-content ui-corner-all">')
        print('<h2>Objects</h2>')
        print('<ul>')
        for d in self._definitions:
            if isinstance(d, ScriptClass) and d.parent is None:
                d.outputClassTree()
        print('</ul>')
        print('</div>')

        print('<div class="ui-widget ui-widget-content ui-corner-all">')
        print('<h2>Functions</h2>')
        print('<ul>')
        for d in self._definitions:
            if isinstance(d, ScriptFunction):
                print('<li>%s' % (d.name))
                print('<dd>%s</dd>' % (d.description.replace('<', '&lt;')))
        print('</ul>')
        print('</div>')

        for d in self._definitions:
            if isinstance(d, ScriptClass):
                print('<div class="ui-widget ui-widget-content ui-corner-all">')
                print('<h2><a name="class_%s">%s</a></h2>' % (d.name, d.name))
                print('<div>%s</div>' % (d.description.replace('<', '&lt;')))
                if d.parent is not None:
                    print('Subclass of: <a href="#class_%s">%s</a>' % (d.parent.name, d.parent.name))
                print('<dl>')
                for func in d.functions:
                    if func.parameters is None:
                        print('<dt>%s:%s [ERROR]</dt>' % (d.name, func.name))
                    else:
                        print('<dt>%s:%s(%s)</dt>' % (d.name, func.name, func.parameters.replace('<', '&lt;')))
                    print('<dd>%s</dd>' % (func.description.replace('<', '&lt;')))
                print('</dl>')
                print('</div>')

        print('<script src="http://daid.github.io/EmptyEpsilon/jquery.min.js"></script>')
        print('<script src="http://daid.github.io/EmptyEpsilon/jquery-ui.min.js"></script>')
        print('</body>')
        print('</html>')

if __name__ == "__main__":
    dg = DocumentationGenerator()
    dg.addFile("EmptyEpsilon.cbp")
    dg.readFunctionInfo()
    dg.readScriptDefinitions()
    dg.linkFunctions()
    dg.linkParents()
    dg.generateDocs()
