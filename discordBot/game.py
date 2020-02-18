import subprocess
import requests
import config

_process = None


def start(scenario, variation):
    global _process
    if _process is not None:
        return False
    command = ["./EmptyEpsilon"]
    command += ["httpserver=8080"]
    command += ["headless=%s" % (scenario), "variation=%s" % (variation)]
    command += ["headless_password=ee"]
    command += ["headless_internet=1"]
    command += ["startpaused=1"]
    _process = subprocess.Popen(command, cwd="..")
    return True

def pause():
    global _process
    if _process is None:
        return False
    return _lua("pauseGame()") == b''

def unPause():
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
