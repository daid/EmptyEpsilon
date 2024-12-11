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
            for func in self.db.filter(params):
                self.output_file.write(data.replace("{{name}}", html.escape(func.name)).replace("{{doc}}", html.escape("\n".join(func.doc))))
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
