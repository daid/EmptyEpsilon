import re
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
			

def getScriptDefinitions(filename):
	ret = []
	description = ""
	current_class = None
	with open(filename, "r") as f:
		for line in f:
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
				ret.append(current_class)
			res = re.search('REGISTER_SCRIPT_CLASS_NO_CREATE\(([^\)]*)\)', line)
			if res != None:
				current_class = ScriptClass(res.group(1).strip())
				current_class.create = False
				current_class.description = description
				ret.append(current_class)
			res = re.search('REGISTER_SCRIPT_SUBCLASS\(([^,]*),([^\)]*)\)', line)
			if res != None:
				current_class = ScriptClass(res.group(1).strip())
				current_class.parent_name = res.group(2).strip()
				current_class.description = description
				ret.append(current_class)
			res = re.search('REGISTER_SCRIPT_SUBCLASS_NO_CREATE\(([^,]*),([^\)]*)\)', line)
			if res != None:
				current_class = ScriptClass(res.group(1).strip())
				current_class.parent_name = res.group(2).strip()
				current_class.create = False
				current_class.description = description
				ret.append(current_class)

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
				ret.append(ScriptFunction(res.group(1).strip()))
				ret[-1].description = description
			description = ""
	return ret

def getFunctionInfo(filename):
	if not filename.endswith('.h'):
		return []
	ret = []
	description = ""
	current_class = None
	with open(filename, "r") as f:
		for line in f:
			if line.startswith('#'):
				continue
			res = re.search('([a-zA-Z0-9]+)::([a-zA-Z0-9]+)\(([^\)]*)\)', line)
			if res != None:
				ret.append((res.group(1), res.group(2), res.group(3)))
			res = re.search('^ *class ([a-zA-Z0-9]+)', line)
			if res != None:
				current_class = res.group(1)
			if current_class is not None:
				res = re.search('^ *([a-zA-Z0-9 \:\<\>]+) +([a-zA-Z0-9]+)\(([^\)]*)\)', line)
				if res != None and res.group(2) != '':
					ret.append((current_class, res.group(2), res.group(3)))
	return ret

def generateScriptDocs(filename):
	xml = ElementTree.parse(filename)
	filenames = []
	obj_filenames = []
	include_search_paths = []
	for project in xml.findall('Project'):
		for unit in project.findall('Unit'):
			filenames.append(unit.attrib['filename'])
	
	definitions = []
	function_info = []
	for filename in filenames:
		definitions += getScriptDefinitions(filename)
		function_info += getFunctionInfo(filename)
	for class_name, function_name, parameters in function_info:
		for definition in definitions:
			if isinstance(definition, ScriptClass):
				for func in definition.functions:
					if (func.origin_class == class_name) and func.name == function_name:
						func.parameters = parameters
	for definition in definitions:
		if isinstance(definition, ScriptClass):
			if definition.parent_name is not None:
				for d in definitions:
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

	print('<!doctype html><html lang="us"><head><meta charset="utf-8"><title>EmptyEpsilon - Scripting documentation</title>')
	print('<link href="jquery-ui.min.css" rel="stylesheet">')
	print('<link href="main.css" rel="stylesheet">')
	print('</head>')
	print('<body>')

	print('<div class="ui-widget ui-widget-content ui-corner-all">')
	print('<h2>Objects</h2>')
	print('<ul>')
	for d in definitions:
		if isinstance(d, ScriptClass) and d.parent is None:
			d.outputClassTree()
	print('</ul>')
	print('</div>')
	
	print('<div class="ui-widget ui-widget-content ui-corner-all">')
	print('<h2>Functions</h2>')
	print('<ul>')
	for d in definitions:
		if isinstance(d, ScriptFunction):
			print('<li>%s' % (d.name))
			print('<dd>%s</dd>' % (d.description.replace('<', '&lt;')))
	print('</ul>')
	print('</div>')

	for d in definitions:
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

	print('<script src="jquery.js"></script>')
	print('<script src="jquery-ui.min.js"></script>')
	print('</body>')
	print('</html>')

generateScriptDocs("EmptyEpsilon.cbp")
