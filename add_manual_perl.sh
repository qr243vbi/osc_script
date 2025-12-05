#!/bin/bash
kd="$(echo $1 | sed 's~::~-~g')"
osc mkpac "perl-$kd"
(
cd "perl-$kd"
osc update
sd="$(echo $1 | sed 's~-~::~g')"
cat << EOF > "_service"
<services>
  <service name="cpanspec" mode="manual">
    <param name="source">$sd</param>
    <param name="add-provides">perl($sd)</param>
  </service>
</services>
EOF
osc service mr
osc add *
osc ci -m update
osc rebuild
)
