#!/usr/bin/python3

# This script is based on tothi's script on the same subject (https://github.com/tothi/dll-hijack-by-proxying)

import pefile
import argparse
import os

parser = argparse.ArgumentParser(description="DLL Export Viewer")
parser.add_argument("file", help="File path")
parser.add_argument("--system32", help="specifies that the DLL is from C:\\Windows\\System32", action="store_true")
args = parser.parse_args()

filenameExt = os.path.basename(args.file)
filename = filenameExt[:len(filenameExt) - 4]
dllFile = pefile.PE(args.file)


for export in dllFile.DIRECTORY_ENTRY_EXPORT.symbols:
	if export.name:
		if args.system32:
			print('#pragma comment(linker,\"export:{}=C:\\\\Windows\\\\System32\\\\{}.dll.{},@{}\")'.format(export.name.decode(), filename, export.name.decode(), export.ordinal))
		else:
			print('#pragma comment(linker,\"export:{}={}_orig.{},@{}\")'.format(export.name.decode(), filename, export.name.decode(), export.ordinal))
