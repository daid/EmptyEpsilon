import sys
import os
import platform
import shutil
try:
	from xml.etree import cElementTree as ElementTree
except:
	from xml.etree import ElementTree

class DependencyFinder(object):
	def __init__(self, filename, include_search_paths):
		self._include_search_paths = include_search_paths
		self._dependencies = {}
		self._find(filename)
		self._max_modify_time = self._dependencies[filename]
		for value in self._dependencies.values():
			if value:
				self._max_modify_time = max(value, self._max_modify_time)
	
	def _find(self, filename):
		if filename in self._dependencies:
			return
		full_filename = filename
		if not os.path.isfile(full_filename):
			for include_search_path in self._include_search_paths:
				joined_path = os.path.join(include_search_path, filename)
				if os.path.isfile(joined_path):
					full_filename = joined_path
					break
		if not os.path.isfile(full_filename):
			self._dependencies[filename] = False
			return
		for line in open(full_filename):
			if line.strip().startswith('#'):
				if line.strip()[1:].strip().startswith('include'):
					if '<' in line and '>' in line:
						include_name = line[line.find('<')+1:line.find('>')]
						self._find(include_name)
		self._dependencies[filename] = os.stat(full_filename).st_mtime
	
	def getModifyTime(self):
		return self._max_modify_time

def compile(filename, system, for_target='Release'):
	EXECUTABLE = os.path.splitext(filename)[0]
	if system == "Windows":
		EXECUTABLE += '.exe'
	if system == "Darwin":
		#Build a MacOS .app thingy.
		app_dir = '%s.app' % (EXECUTABLE)
		contents_dir = '%s/Contents' % (app_dir)
		frameworks_dir = '%s/Frameworks' % (contents_dir)
		resources_dir = '%s/Resources' % (contents_dir)
		EXECUTABLE = '%s/MacOS/%s' % (contents_dir, EXECUTABLE)
		if os.path.exists(app_dir):
			shutil.rmtree(app_dir)
		os.makedirs(os.path.dirname(EXECUTABLE))
		os.makedirs(frameworks_dir)
		os.makedirs(resources_dir)
		shutil.copytree('/Library/Frameworks/sfml-audio.framework', frameworks_dir + '/sfml-audio.framework')
		shutil.copytree('/Library/Frameworks/sfml-graphics.framework', frameworks_dir + '/sfml-graphics.framework')
		shutil.copytree('/Library/Frameworks/sfml-network.framework', frameworks_dir + '/sfml-network.framework')
		shutil.copytree('/Library/Frameworks/sfml-system.framework', frameworks_dir + '/sfml-system.framework')
		shutil.copytree('/Library/Frameworks/sfml-window.framework', frameworks_dir + '/sfml-window.framework')
		shutil.copytree('/Library/Frameworks/sndfile.framework', frameworks_dir + '/sndfile.framework')
		shutil.copytree('/Library/Frameworks/freetype.framework', frameworks_dir + '/freetype.framework')
		shutil.copytree('resources', resources_dir + '/resources')
		shutil.copytree('packs', resources_dir + '/packs')
	CC = 'gcc'
	CXX = 'g++'
	BUILD_DIR = '_build'
	CFLAGS = '-O3'
	LDFLAGS = ''
	
	if system == "Windows" and platform.system() != "Windows":
		CC = 'i686-w64-mingw32-' + CC
		CXX = 'i686-w64-mingw32-' + CXX
	if system == "Windows" and platform.system() == "Windows":
		CC = 'C:/codeblocks/mingw/bin/mingw32-' + CC
		CXX = 'C:/codeblocks/mingw/bin/mingw32-' + CXX
	
	xml = ElementTree.parse(filename)
	filenames = []
	obj_filenames = []
	include_search_paths = []
	for project in xml.findall('Project'):
		for unit in project.findall('Unit'):
			filenames.append(unit.attrib['filename'])
		for compiler in project.findall('Compiler'):
			for add in compiler.findall('Add'):
				if 'option' in add.attrib:
					CFLAGS += ' %s' % (add.attrib['option'])
				if 'directory' in add.attrib:
					include_search_paths.append(add.attrib['directory'])
					CFLAGS += ' -I%s' % (add.attrib['directory'])
		for linker in project.findall('Linker'):
			for add in linker.findall('Add'):
				if 'option' in add.attrib:
					LDFLAGS += ' %s' % (add.attrib['option'])
				if 'library' in add.attrib:
					LDFLAGS += ' -l%s' % (add.attrib['library'])
				if 'directory' in add.attrib:
					LDFLAGS += ' -L%s' % (add.attrib['directory'])
		for build in project.findall('Build'):
			for target in build.findall('Target'):
				if target.attrib['title'] == for_target:
					for compiler in target.findall('Compiler'):
						for add in compiler.findall('Add'):
							if 'option' in add.attrib:
								CFLAGS += ' %s' % (add.attrib['option'])
							if 'directory' in add.attrib:
								include_search_paths.append(add.attrib['directory'])
								CFLAGS += ' -I%s' % (add.attrib['directory'])
					for linker in target.findall('Linker'):
						for add in linker.findall('Add'):
							if 'option' in add.attrib:
								LDFLAGS += ' %s' % (add.attrib['option'])
							if 'library' in add.attrib:
								LDFLAGS += ' -l%s' % (add.attrib['library'])
							if 'directory' in add.attrib:
								LDFLAGS += ' -L%s' % (add.attrib['directory'])
	if not os.path.isdir(BUILD_DIR):
		os.mkdir(BUILD_DIR)
	
	filenames = filter(lambda f: f.endswith('.c') or f.endswith('.cpp'), filenames)
	for filename in filenames:
		obj_filename = os.path.splitext(os.path.basename(filename))[0] + '.o'
		obj_filenames.append(obj_filename)
		if os.path.splitext(os.path.basename(filename))[1] == '.c':
			cc = CC
		else:
			cc = CXX
		cmd = '%s %s -o %s/%s -c %s' % (cc, CFLAGS, BUILD_DIR, obj_filename, filename)
		print '[%d%%] %s' % (filenames.index(filename) * 100 / len(filenames), cmd)
		if os.path.isfile('%s/%s' % (BUILD_DIR, obj_filename)):
			source_modify_time = DependencyFinder(filename, include_search_paths).getModifyTime()
			binary_modify_time = os.stat('%s/%s' % (BUILD_DIR, obj_filename)).st_mtime
			if source_modify_time > binary_modify_time:
				if os.system(cmd) != 0:
					return
		else:
			if os.system(cmd) != 0:
				return
	
	cmd = '%s -o %s %s %s' % (CXX, EXECUTABLE, ' '.join(map(lambda n: '%s/%s' % (BUILD_DIR, n), obj_filenames)), LDFLAGS)
	print '[Goal] %s' % (cmd)
	if os.system(cmd) != 0:
		return

system = platform.system()
target = "Release"
for arg in sys.argv[1:]:
	if arg == "win32":
		system = "Windows"
	if arg == "debug":
		target = "Debug"

if system == "Windows":
	compile("EmptyEpsilon.cbp", system, target)
if system == "Linux":
	compile("EmptyEpsilon.cbp", system, "Linux %s" % (target))
if system == "Darwin":
	compile("EmptyEpsilon.cbp", system, "MacOS %s" % (target))
