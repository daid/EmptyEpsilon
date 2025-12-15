import os
import re
import warnings
import argparse
import html
from scriptfunctiondb import ScriptFunctionDatabase


class ReferenceBuilder:
    def __init__(self, output_filename):
        self.db = ScriptFunctionDatabase(os.path.join(os.path.dirname(__file__), "..", "scripts"))
        self.db.read("api/all.lua")
        self.output_file = open(output_filename, "wt")

    def process_block(self, data, tag, params):
        if tag == "foreach":
            funcs = list(self.db.filter(params))
            # Group entity functions by category
            if params.get('type') == 'method':
                groups = {}
                for func in funcs:
                    cat = func.metadata.get('category')
                    if not cat:
                        # Derive from file if no name defined
                        from_file = getattr(func, 'from_file', '')
                        base = os.path.splitext(os.path.basename(from_file))[0]
                        parts = re.split(r'[^A-Za-z0-9]+', base)
                        cat = ''.join([p.capitalize() for p in parts if p])
                    groups.setdefault(cat, []).append(func)
                # Set up entity usage function ToC
                for cat in sorted(groups.keys(), key=lambda s: s.lower()):
                    self.output_file.write(f"<li><a href='#category_{html.escape(cat)}'>{html.escape(cat)} functions</a></li>\n")
                self.output_file.write(f"</ul>\n")
                for cat in sorted(groups.keys(), key=lambda s: s.lower()):
                    self.output_file.write(f"<h2 id='category_{html.escape(cat)}'><a href='#entity'>{html.escape(cat)} functions</a></h2><ul>\n")
                    for func in groups[cat]:
                        out = data
                        out = out.replace("{{name}}", html.escape(func.name))
                        out = out.replace("{{doc}}", html.escape("\n".join(func.doc)))
                        out = out.replace("{{docs}}", html.escape("\n".join(func.doc)))
                        out = out.replace("{{example}}", html.escape("\n".join(func.example)))
                        out = out.replace("{{params}}", html.escape(", ".join(func.params)))
                        self.output_file.write(out)
                    self.output_file.write("</ul>\n")
                return
            # Fallback to all functions ungrouped without ToC
            for func in funcs:
                out = data
                out = out.replace("{{name}}", html.escape(func.name))
                out = out.replace("{{doc}}", html.escape("\n".join(func.doc)))
                out = out.replace("{{docs}}", html.escape("\n".join(func.doc)))
                out = out.replace("{{example}}", html.escape("\n".join(func.example)))
                out = out.replace("{{params}}", html.escape(", ".join(func.params)))
                self.output_file.write(out)
        else:
            print(tag, params)

    def process(self):
        input_file = open(os.path.join(os.path.dirname(__file__), "template.html"), "rt").read()
        tags = list(re.finditer(r"{{([a-z]+) *([^{]*)}}", input_file))
        start = 0
        start_tag = None
        for m in tags:
            tag = m.group(1)
            if tag == "foreach":
                self.output_file.write(input_file[start:m.start()])
                start = m.end()
                start_tag = m
            elif tag == "end":
                params = start_tag.group(2)
                params = {p.partition("=")[0]: p.partition("=")[2] for p in params.split()}
                self.process_block(input_file[start:m.start()], start_tag.group(1), params)
                start = m.end()
                start_tag = None
        self.output_file.write(input_file[start:])


def main(args=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("output")
    args = parser.parse_args(args)

    rb = ReferenceBuilder(args.output)
    rb.process()

if __name__ == "__main__":
    main()
