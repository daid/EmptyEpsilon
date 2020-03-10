# python3 script to update localization files.

import glob
import subprocess
import json
import os

os.makedirs("scripts/locale", exist_ok=True)
for scenario in glob.glob("scripts/scenario_*.lua"):
    output = scenario.replace(".lua", ".en.po").replace("scripts/", "scripts/locale/")
    info = {}
    key = None
    for line in open(scenario):
        if not line.startswith("--"):
            break
        if line.startswith("---"):
            if key is not None:
                info[key] = info[key] + "\n" + line[3:].strip()
        elif ":" in line:
            key, _, value = line[2:].partition(":")
            key = key.strip().lower()
            value = value.strip()
            info[key] = value
    f = open(output, "wt")
    if "name" in info:
        f.write("# Scenario name\n")
        f.write("msgid %s\n" % (json.dumps(info["name"])))
        f.write("msgstr \"\"\n")
    if "description" in info:
        f.write("# Scenario description\n")
        if "\n" in info["description"]:
            f.write("msgid \"\"\n")
            for desc in info["description"].split("\n"):
                f.write("    %s\n" % (json.dumps(desc)))
        else:
            f.write("msgid %s\n" % (json.dumps(info["description"])))
        f.write("msgstr \"\"\n")
    f.close()
    cmd = ["xgettext", "--keyword=_:1c,2", "--keyword=_:1", "--omit-header", "-j", "-d", output[:-3], scenario]
    subprocess.run(cmd, check=True)
