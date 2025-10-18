import os
import subprocess

class Find:
  def __init__(self):
    self.total_results = 0
    self.num_results = 0
    self.file_names = [] 
    self.file_paths = [] 
    self.results = []
    self.file_types = []

  def search(self, text, offset = 0, max = 10):
    self.reset()

    text = self.normalize(text)

    name = ""
    path = "."

    if (len(text)):
      name, path = self.splitNamePath(text)

    cmd = "rg --files {}".format(path)
    args = "| rg {}".format(name)

    query = self.printQuery(cmd, args)

    output = ""
    try:
      output = subprocess.check_output(query, shell=True, stdin=subprocess.PIPE)
    except:
     output = ""

    self.filter(output)

    return 1

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

    if (len(name) == 0):
      name = "*"

    return name, path
  
  def normalize(self, text):
    return text.replace("\\", "/").replace("|", "")

  def printQuery(self, cmd, args):
    text = "{} {}".format(cmd, args)
    return text

  def filter(self, results, max = 10):
    if (len(results) == 0):
      return

    results = results.decode('utf-8').split("\n")
    self.total_results = len(results)

    for i in range(0, min(max, self.total_results)):
      r = results[i]
      if (len(r)):
        self.num_results += 1
        name = os.path.basename(r)
        path = r.replace(name, "")
        self.file_names.append(name)
        self.file_paths.append(path)
        self.results.append((name, path))
        is_folder = os.path.isdir(r)
        self.file_types.append(1 if is_folder else 0)

  def printResults(self):
    print(f"Total Results: {self.total_results}")
    print(f"Names: {self.file_names}")
    print(f"Paths: {self.file_paths}")
    print(f"Results: {self.results}")
    print(f"File Types: {self.file_types}")
  
  def reset(self):
    self.total_results = 0
    self.num_results = 0
    self.file_names = [] 
    self.file_paths = [] 
    self.results = []
    self.file_types = []
