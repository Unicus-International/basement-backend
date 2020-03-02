#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

import BasementDriver

setbuf(stdout, nil);

try BasementDriver.run()
