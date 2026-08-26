
class QueryResults:
  def __init__(self, name):
    self.name = name
    self.num     = 0
    self.total   = 0
    self.names   = []
    self.paths   = []
    self.types   = []
    self.sizes   = []
    self.modds   = []

  def add(self, name, path, is_folder, size, modification_date):
    self.names.append(name)
    self.paths.append(path)
    self.types.append(is_folder)
    self.sizes.append(size)
    self.modds.append(modification_date)

  def check(self):
    l_n = len(self.names)
    l_p = len(self.paths)
    l_t = len(self.types)
    l_s = len(self.sizes)
    l_m = len(self.modds)
    v_n = self.num != l_n
    v_p = self.num != l_p
    v_t = self.num != l_t
    v_s = self.num != l_s
    v_m = self.num != l_m
    if (v_n or v_p or v_t or v_s or v_m):
      print(f"Invalid results from Everything ({self.name}): {self.num}, {l_n}, {l_p}, {l_t}, {l_s}, {l_m}")

  def reset(self):
    self.num     = 0
    self.total   = 0
    self.names   = []
    self.paths   = []
    self.types   = []
    self.sizes   = []
    self.modds   = []
