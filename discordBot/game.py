import subprocess
import requests
import config
import os
import time

_process = None

#hacktoberfest comment

def getScenarios():
    result = []
    for filename in sorted(filter(lambda f: f.startswith("scenario_") and f.endswith(".lua"), os.listdir("../scripts/"))):
        result.append(filename)
    return result


def start(scenario, variation):
    global _process
    if _process is not None:
        return False
    command = ["./EmptyEpsilon"]
    command += ["httpserver=8080"]
    command += ["headless=%s" % (scenario), "variation=%s" % (variation)]
    if config.server_password is not None:
        command += ["headless_password=%s" % (config.server_password)]
    command += ["headless_internet=1"]
    command += ["startpaused=1"]
    _process = subprocess.Popen(command, cwd="..")
    time.sleep(2.0)
    if _process.poll() is not None:
        _process = None
        return False
    return True

def pause():
    global _process
    if _process is None:
        return False
    return _lua("pauseGame()") == b''

def unpause():
    global _process
    if _process is None:
        return False
    return _lua("unpauseGame()") == b''

def stop():
    global _process
    if _process is None:
        return False
    if _process.poll() is None:
        _lua("shutdownGame()")
    _process.wait()
    _process = None
    return True

def _lua(script):
    return requests.post('http://127.0.0.1:8080/exec.lua', script).content
