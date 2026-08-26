import os
import shutil
import subprocess
from enum import Enum 
from results import *

class Find:
  def __init__(self):
    self.mode = 0
    self.query = QueryResults("Query")

  def setMode(self, mode):
      self.mode = mode

  # max is ignored here as fd or rg don't return data in the same way Everything does
  def search(self, text, type = 0, offset = 0, max = 10, inc_size = 0, inc_modd = 0):
    self.reset()

    text = self.normalize(text)

    name = ""
    path = "."

    if (len(text)):
      name, path = self.splitNamePath(text)

    query = self.queryFd(name, path, type, offset, max, inc_size, inc_modd)

    if (self.mode == 1):
      query = self.queryRg(name, path, type, offset, max, inc_size, inc_modd)

    if (query == ""):
      return 0

    output = ""
    try:
      output = subprocess.check_output(query, shell=True, stdin=subprocess.PIPE)
    except:
     output = ""

    self.filter(output, offset, max)

    return 1

  def queryFd(self, name, path, type, offset = 0, max = 0, inc_size = 0, inc_modd = 0):

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

  def queryRg(self, name, path, type, offset = 0, max = 0, inc_size = 0, inc_modd = 0):

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
    return text.replace("\\", "/")

  def printQuery(self, cmd, args):
    text = "{} {}".format(cmd, args)
    return text

  def filter(self, results, offset, max):

    if (len(results) == 0):
      return

    results = results.decode('utf-8').split("\n")
    self.query.total = len(results)

    f = offset
    t = min(f + max, self.query.total)

    for i in range(f, t):

      r = results[i]

      if (len(r)):

        self.query.num += 1
        
        name = os.path.basename(r)
        path = r.replace(name, "")

        is_folder = 1 if os.path.isdir(r) else 0

        self.query.add(name, path, is_folder, 0, '')

  def printResults(self):
    print(f"Total Results: {self.query.total}")
    print(f"Names: {self.query.names}")
    print(f"Paths: {self.query.paths}")
    print(f"File Types: {self.query.types}")
  
  def reset(self):
    self.query.reset()
