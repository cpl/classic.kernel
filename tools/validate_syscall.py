"""
   Copyright 2018 Alexandru-Paul Copil

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
"""

import sys


ASM_TARGET = sys.argv[1]
C_TARGET = sys.argv[2]


ASM_ENTRIES = {}
C_ENTRIES = {}

if __name__ == "__main__":
    with open(ASM_TARGET, "r") as fp:
        for line in fp.readlines():
            line = line.strip()
            if line.startswith("MACRO_SWI_ENTRY"):
                call, inst = line.split(',')
                call = call[15:].strip()
                inst = inst.strip()
                ASM_ENTRIES[call] = inst

    print("| %-6s | %-16s | %-42s | %-20s |" % ("RETR", "CALL", "ARGS", "ASM"))
    print("+ %-6s + %-16s + %-42s + %-20s +" % ("-"*6, "-"*16, "-"*42, "-"*20))

    with open(C_TARGET, "r") as fp:
        for line in fp.readlines():
            line = line.strip()
            if line.startswith("extern"):
                line = line[7:]
                ret, line = line.split('syscall_')
                ret = ret.strip()
                call, args = line.split('(')
                args = args[:-2].split(',')

                print("| %-6s | %-16s | %-42s | %-20s |" % (ret, call, args, ASM_ENTRIES[call]))
    print("+ %-6s + %-16s + %-42s + %-20s +" % ("-"*6, "-"*16, "-"*42, "-"*20))


