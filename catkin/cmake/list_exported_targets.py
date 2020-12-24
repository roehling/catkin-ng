import sys
import re

targets = set()
with open(sys.argv[1], "r") as f:
    for line in f:
        mo = re.search(r"add_(?:library|executable) *\( *([^ ]+).*IMPORTED", line)
        if mo:
            targets.add(mo.group(1))
print(";".join(targets))
