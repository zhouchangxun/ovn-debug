
ovnnb="tcp:192.168.133.71:6641 "
ovnsb="tcp:192.168.133.71:6642 "
export NBCTL="ovn-nbctl --db=$ovnnb"
export SBCTL="ovn-nbctl --db=$ovnsb"
export OVNTRACE="ovn-trace --db=$ovnsb"

