import os
import re

class ScriptFunction:
    def __init__(self, name, doc, params):
        self.name = name
        self.doc = []
        self.example = []
        self.params = params
        self.metadata = {}
        doc_example = False
        for doc_line in doc:
            stripped = doc_line.strip()
            if stripped.startswith("@"):
                key, _, value = stripped.partition(" ")
                self.metadata[key[1:].strip()] = value.strip()
            elif stripped.startswith("Example") or doc_example:
                # Break out any example for code-block whitespace preservation
                # and syntax highlighting.
                # Remove the leading Example:/Examples: token
                content = re.sub(r'^Examples?: *', '', stripped)
                if len(content) > 0:
                    # Use the unstripped line for code examples
                    self.example.append(doc_line)
                # All lines after the token are part of the example
                doc_example = True
            else:
                self.doc.append(doc_line)
    
    def check_filters(self, filters):
        for k, v in filters.items():
            if k not in self.metadata:
                return False
            if self.metadata[k] != v:
                return False
        return True

    def __repr__(self):
        return f"<{self.name}({', '.join(self.params)})>"


class ScriptFunctionDatabase:
    def __init__(self, base_path):
        self.__base_path = base_path
        self.__functions = {}
        # Determine repository roots to scan C++ sources for registered globals
        # and enums
        repo_root = os.path.abspath(os.path.join(self.__base_path, ".."))
        self.__cpp_dirs = [os.path.join(repo_root, "src"), os.path.join(repo_root, "..", "SeriousProton", "src")]
        # Map from Lua filename to a creation-type function name.
        # This is brittle
        self._file_category_map = {}
    
    def filter(self, filters):
        for name, func in self.__functions.items():
            if func.check_filters(filters):
                yield func

    def read(self, filename: str):
        print(f"Reading {filename}")
        doc_str = []
        for line in open(os.path.join(self.__base_path, filename), "rt"):
            require = re.match(r'require\("([^"]+)"\)', line)
            if require:
                self.read(require.group(1))
            if line.startswith("---"):
                # Preserve leading whitespace in doc lines
                doc_str.append(line[3:].rstrip("\n"))
            if line.strip() == "end":
                doc_str = []
            func = re.match(r'function\s+([^\()]+)\(([^"))]*)\)', line)
            if func:
                if func.group(1) in self.__functions:
                    print(f"WARNING: Duplicate function: {func.group(1)} {filename} : {self.__functions[func.group(1)]}")
                if not func.group(1).startswith("__") and doc_str:
                    params = [p.strip() for p in func.group(2).split(",") if p.strip() != ""]
                    sf = ScriptFunction(func.group(1), doc_str, params)
                    # Filter Lua functions (Entity:func) as method type
                    if ':' in func.group(1):
                        sf.metadata['type'] = 'method'
                        # Assign category based on file if available
                        if filename in self._file_category_map:
                            sf.metadata['category'] = self._file_category_map[filename]
                    self.__functions[func.group(1)] = sf
                    # Prefer the function name as category
                    if sf.metadata.get('type') == 'creation':
                        self._file_category_map[filename] = sf.name
        # Also scan C++ sources for env.setGlobal registrations and enum strings
        self._scan_cpp_sources()

    def _scan_cpp_sources(self):
        # Use env.setGlobal("name", &function) and /// blocks as docs
        # Probably missing some things
        setglobal_re = re.compile(r'env\.setGlobal\(\s*"([^\"]+)"\s*,\s*&?([A-Za-z0-9_:]+)')
        convert_re = re.compile(r'template<>\s*struct\s*Convert<([^>]+)>')
        pushstring_re = re.compile(r'lua_pushstring\(L,\s*"([^\"]+)"')

        # Walk the C++ files
        for d in self.__cpp_dirs:
            if not os.path.isdir(d):
                continue
            for root, _, files in os.walk(d):
                for fn in files:
                    if not (fn.endswith('.cpp') or fn.endswith('.h') or fn.endswith('.hpp')):
                        continue
                    path = os.path.join(root, fn)
                    try:
                        with open(path, 'rt', errors='ignore') as f:
                            lines = f.readlines()
                    except Exception:
                        continue

                    # Scan for env.setGlobal registrations
                    for idx, line in enumerate(lines):
                        m = setglobal_re.search(line)
                        if m:
                            name = m.group(1)
                            funcptr = m.group(2)
                            # Collect preceding ///-style comments
                            doc_lines = []
                            j = idx - 1
                            while j >= 0:
                                # Preserve leading whitespace in docs
                                m = re.match(r'\s*///(.*)\n?$', lines[j])
                                if m:
                                    doc_lines.insert(0, m.group(1).rstrip('\n'))
                                    j -= 1
                                    continue
                                if lines[j].strip() == '':
                                    j -= 1
                                    continue
                                break
                            # If there is a signature-like first line, try to
                            # extract parameter names
                            # e.g. "string getScenarioSetting(string key)"
                            params = []
                            if doc_lines:
                                sig = doc_lines[0]
                                sigm = re.match(r'.*\s+([A-Za-z0-9_]+)\((.*)\)', sig)
                                if sigm:
                                    plist = sigm.group(2)
                                    params = [p.strip().split()[-1] for p in plist.split(',') if p.strip()]
                            key = name
                            # Don't overwrite Lua-detected functions
                            if key in self.__functions:
                                continue
                            self.__functions[key] = ScriptFunction(name, doc_lines, params)
                            # Filter globals registered in C++
                            self.__functions[key].metadata['type'] = 'global'

                    # Scan for Convert<> enum converters
                    text = ''.join(lines)
                    for cm in convert_re.finditer(text):
                        type_name = cm.group(1).strip()
                        # Search block after this match up to the following '};'
                        start = cm.end()
                        end = text.find('};', start)
                        if end == -1:
                            continue
                        block = text[start:end]
                        values = pushstring_re.findall(block)
                        if not values:
                            continue
                        # Create a doc line describing values
                        doc = [", ".join(values)]
                        short_name = type_name.split('::')[-1]
                        key = f"enum::{short_name}"
                        if key in self.__functions:
                            continue
                        func = ScriptFunction(short_name, doc, [])
                        func.metadata['type'] = 'enum'
                        self.__functions[key] = func

    def dump(self):
        print(f"### Dumping {len(self.__functions)} functions ###")
        for k, v in self.__functions.items():
            print(k, v)
            print("  " + "\n  ".join(v.doc))

