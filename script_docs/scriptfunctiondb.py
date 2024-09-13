import os
import re


class ScriptFunction:
    def __init__(self, name, from_file, doc, params):
        self.name = name
        self.doc = []
        self.params = params
        self.metadata = {}
        for doc_line in doc:
            if doc_line.startswith("@"):
                key, _, value = doc_line.partition(" ")
                self.metadata[key[1:].strip()] = value.strip()
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
                doc_str.append(line[3:].strip())
            if line.strip() == "end":
                doc_str = []
            func = re.match(r'function\s+([^\()]+)\(([^\))]*)\)', line)
            if func:
                if func.group(1) in self.__functions:
                    print(f"WARNING: Duplicate function: {func.group(1)} {filename} : {self.__functions[func.group(1)]}")
                if not func.group(1).startswith("__") and doc_str:
                    params = [p.strip() for p in func.group(2).split(",") if p.strip() != ""]
                    self.__functions[func.group(1)] = ScriptFunction(func.group(1), filename, doc_str, params)

    def dump(self):
        print(f"### Dumping {len(self.__functions)} functions ###")
        for k, v in self.__functions.items():
            print(k, v)
            print("  " + "\n  ".join(v.doc))

