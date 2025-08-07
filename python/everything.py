import os
import ctypes
import sys
import time

#defines
EVERYTHING_REQUEST_FILE_NAME                           = 0x00000001
EVERYTHING_REQUEST_PATH                                = 0x00000002
EVERYTHING_REQUEST_FULL_PATH_AND_FILE_NAME             = 0x00000004
EVERYTHING_REQUEST_EXTENSION                           = 0x00000008
EVERYTHING_REQUEST_SIZE                                = 0x00000010
EVERYTHING_REQUEST_DATE_CREATED                        = 0x00000020
EVERYTHING_REQUEST_DATE_MODIFIED                       = 0x00000040
EVERYTHING_REQUEST_DATE_ACCESSED                       = 0x00000080
EVERYTHING_REQUEST_ATTRIBUTES                          = 0x00000100
EVERYTHING_REQUEST_FILE_LIST_FILE_NAME                 = 0x00000200
EVERYTHING_REQUEST_RUN_COUNT                           = 0x00000400
EVERYTHING_REQUEST_DATE_RUN                            = 0x00000800
EVERYTHING_REQUEST_DATE_RECENTLY_CHANGED               = 0x00001000
EVERYTHING_REQUEST_HIGHLIGHTED_FILE_NAME               = 0x00002000
EVERYTHING_REQUEST_HIGHLIGHTED_PATH                    = 0x00004000
EVERYTHING_REQUEST_HIGHLIGHTED_FULL_PATH_AND_FILE_NAME = 0x00008000

EVERYTHING_SORT_NAME_ASCENDING                   = 1
EVERYTHING_SORT_NAME_DESCENDING                  = 2
EVERYTHING_SORT_PATH_ASCENDING                   = 3
EVERYTHING_SORT_PATH_DESCENDING                  = 4
EVERYTHING_SORT_SIZE_ASCENDING                   = 5
EVERYTHING_SORT_SIZE_DESCENDING                  = 6
EVERYTHING_SORT_EXTENSION_ASCENDING              = 7
EVERYTHING_SORT_EXTENSION_DESCENDING             = 8
EVERYTHING_SORT_TYPE_NAME_ASCENDING              = 9
EVERYTHING_SORT_TYPE_NAME_DESCENDING             = 10
EVERYTHING_SORT_DATE_CREATED_ASCENDING           = 11
EVERYTHING_SORT_DATE_CREATED_DESCENDING          = 12
EVERYTHING_SORT_DATE_MODIFIED_ASCENDING          = 13
EVERYTHING_SORT_DATE_MODIFIED_DESCENDING         = 14
EVERYTHING_SORT_ATTRIBUTES_ASCENDING             = 15
EVERYTHING_SORT_ATTRIBUTES_DESCENDING            = 16
EVERYTHING_SORT_FILE_LIST_FILENAME_ASCENDING     = 17
EVERYTHING_SORT_FILE_LIST_FILENAME_DESCENDING    = 18
EVERYTHING_SORT_RUN_COUNT_ASCENDING              = 19
EVERYTHING_SORT_RUN_COUNT_DESCENDING             = 20
EVERYTHING_SORT_DATE_RECENTLY_CHANGED_ASCENDING  = 21
EVERYTHING_SORT_DATE_RECENTLY_CHANGED_DESCENDING = 22
EVERYTHING_SORT_DATE_ACCESSED_ASCENDING          = 23
EVERYTHING_SORT_DATE_ACCESSED_DESCENDING         = 24
EVERYTHING_SORT_DATE_RUN_ASCENDING               = 25
EVERYTHING_SORT_DATE_RUN_DESCENDING              = 26

EVERYTHING_OK                    = 0
EVERYTHING_ERROR_CREATETHREAD    = 1	
EVERYTHING_ERROR_REGISTERCLASSEX = 2
EVERYTHING_ERROR_CREATEWINDOW	 = 3
EVERYTHING_ERROR_IPC	         = 4 
EVERYTHING_ERROR_MEMORY	         = 5
EVERYTHING_ERROR_INVALIDCALL	 = 6

def DebugLog(txt):
  print(txt)

class Everything:
  def __init__(self):
    self.num_results = 0
    self.total_results = 0
    self.result     = []
    self.file_names = []
    self.file_paths = []
    self.file_types = []

    self.dll_name = "Everything32.dll"
    if (sys.maxsize > 2**32):
      self.dll_name = "Everything64.dll"

    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), self.dll_name)
    self.api = ctypes.WinDLL(path, use_last_error=True)
    self.api.Everything_GetResultDateModified.argtypes = [ctypes.c_int,ctypes.POINTER(ctypes.c_ulonglong)]
    self.api.Everything_GetResultSize.argtypes = [ctypes.c_int,ctypes.POINTER(ctypes.c_ulonglong)]

  def search(self, text, offset = 0, max = 10):
    self.reset()

    if (not self.api.Everything_IsDBLoaded()):
      print("VE: Failed to load DB, Is Everything running?")
      return

    flags = EVERYTHING_REQUEST_FILE_NAME | EVERYTHING_REQUEST_PATH
    self.api.Everything_SetRequestFlags(flags)
    self.api.Everything_SetMatchPath(False)
    self.api.Everything_SetMatchWholeWord(False)
    self.api.Everything_SetRegex(False)
    self.api.Everything_SetOffset(offset)
    self.api.Everything_SetMax(max)

    #DebugLog("Query: {}".format(text))
    #DebugLog("Searching Text: {}".format(text))

    self.api.Everything_SetSearchW(text)

    if (not self.api.Everything_QueryW(True)):
      print("VE: Failed when trying to Query")
      self.printEverythingError()
      return False

    self.total_results = self.api.Everything_GetTotFileResults()
    self.num_results   = self.api.Everything_GetNumResults()

    #DebugLog("Total Results: {}, Num Results: {}".format(self.total_results, self.num_results))

    self.file_names = []
    self.file_paths = []
    self.file_types = []
    self.result = [] 
    for i in range(self.num_results):

      name = self.api.Everything_GetResultFileNameW(i)
      is_folder = self.api.Everything_IsFolderResult(name)
      self.file_types.append(is_folder)

      path = ctypes.create_unicode_buffer(260)
      self.api.Everything_GetResultFullPathNameW(i, path, 260)

      name = ctypes.wstring_at(name)
      path = ctypes.wstring_at(path)

      name = str(name)
      path = str(path)
      path = path.replace("\\", "/")
      if (not is_folder):
        path = path[:path.rfind('/')]

      self.file_names.append(name)
      self.file_paths.append(path)
      self.result.append((name, path))

    return True

  def reset(self):
    self.api.Everything_CleanUp()
    self.api.Everything_Reset()

  def printVersion(self):
    print(self.api.Everything_GetBuildNumber())

  def printEverythingError(self):
    error = self.api.Everything_GetLastError()
    if (error == EVERYTHING_OK):
      print("The operation completed successfully.")
    elif (error == EVERYTHING_ERROR_CREATETHREAD):
      print("Failed to create the search query thread.")
    elif(error == EVERYTHING_ERROR_REGISTERCLASSEX):
      print("Failed to register the search query window class.")
    elif(error == EVERYTHING_ERROR_CREATEWINDOW):
      print("Failed to create the search query window.")
    elif(error == EVERYTHING_ERROR_IPC):
      print("IPC is not available. Make sure Everything is running.")
    elif(error == EVERYTHING_ERROR_MEMORY):
      print("Failed to allocate memory for the search query.")
    elif(error == EVERYTHING_ERROR_INVALIDCALL):
      print("Call Everything_SetReplyWindow before calling Everything_Query with bWait set to FALSE.")

