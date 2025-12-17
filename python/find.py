import os
import shutil
import subprocess
from enum import Enum 

class FindResults:
  def __init__(self, name):
    self.name = name
    self.num     = 0
    self.total   = 0
    self.names   = []
    self.paths   = []
    self.results = []
    self.types   = []

  def check(self):
    l_n = len(self.names)
    l_p = len(self.paths)
    l_r = len(self.results)
    l_t = len(self.types)
    v_n = self.num != l_n
    v_p = self.num != l_p
    v_r = self.num != l_r
    v_t = self.num != l_t
    if (v_n or v_p or v_r or v_t):
      print(f"Invalid results from Everything ({self.name}): {self.num}, {l_n}, {l_p}, {l_r}, {l_t}")

  def reset(self):
    self.num     = 0
    self.total   = 0
    self.names   = []
    self.paths   = []
    self.results = []
    self.types   = []

class Find:
  def __init__(self):
    self.mode = 0
    self.query = FindResults("Query")

  def setMode(self, mode):
      self.mode = mode

  # max is ignored here as fd or rg don't return data in the same way Everything does
  def search(self, text, type = 0, offset = 0, max = 10):
    self.reset()

    text = self.normalize(text)

    name = ""
    path = "."

    if (len(text)):
      name, path = self.splitNamePath(text)

    query = self.queryFd(name, path, type)

    if (self.mode == 1):
      query = self.queryRg(name, path, type)

    if (query == ""):
      return 0

    output = ""
    try:
      output = subprocess.check_output(query, shell=True, stdin=subprocess.PIPE)
    except:
     output = ""

    self.filter(output, max)

    return 1

  def queryFd(self, name, path, type):

    if (not self.exists("fd")):
        return ""

    query = "fd -i -a "

    if (type == 1):
      query += "-t f "

    if (type == 2):
      query += "-t d "

    if (len(name) == 0):
      name = "''" 

    query += f"{name} {path}"
    return query

  def queryRg(self, name, path, type):

    if (not self.exists("rg")):
        return ""

    if (len(name) == 0):
      name = "*"

    cmd = "rg --files {}".format(path)
    args = "| rg {}".format(name)

    return self.printQuery(cmd, args)

  def exists(self, name):
    return shutil.which(name) is not None

  def splitNamePath(self, text):

    name = text
    path = "."

    path_start = text.find("~")
    if (path_start == -1):
      path_start = text.find("/")

    if (path_start > -1):

      path = text[path_start:]

      last_marker = path.rfind("/")
      path_end = path.find(" ", last_marker, len(path))

      path = path[:path_end if path_end > -1 else len(text)].strip()
      name = text.replace(path, "").strip()

    return name, path
  
  def normalize(self, text):
    return text.replace("\\", "/").replace("|", "")

  def printQuery(self, cmd, args):
    text = "{} {}".format(cmd, args)
    return text

  def filter(self, results, max):

    if (len(results) == 0):
      return

    results = results.decode('utf-8').split("\n")
    self.query.total = len(results)

    for i in range(0, self.query.total):

      r = results[i]

      if (len(r)):

        self.query.num += 1
        
        name = os.path.basename(r)
        path = r.replace(name, "")

        self.query.names.append(name)
        self.query.paths.append(path)

        self.query.results.append((name, path))

        is_folder = os.path.isdir(r)
        self.query.types.append(1 if is_folder else 0)

  def printResults(self):
    print(f"Total Results: {self.query.total}")
    print(f"Names: {self.query.names}")
    print(f"Paths: {self.query.paths}")
    print(f"Results: {self.query.results}")
    print(f"File Types: {self.query.types}")
  
  def reset(self):
    self.query.reset()
