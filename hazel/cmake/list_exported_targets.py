##############################################################################
#
# Hazel Build System
# Copyright 2020 Timo Röhling <timo@gaussglocke.de>
#
# Copying and distribution of this file, with or without modification, are
# permitted in any medium without royalty, provided the copyright notice and
# this notice are preserved. This file is offered as-is, without any warranty.
#
##############################################################################
import sys
import re

targets = set()
with open(sys.argv[1], "r") as f:
    for line in f:
        mo = re.search(r"add_(?:library|executable) *\( *([^ ]+).*IMPORTED", line)
        if mo:
            targets.add(mo.group(1))
print(";".join(targets))
