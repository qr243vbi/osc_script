#!/bin/bash
url="${url:-https://src.fedoraproject.org/rpms/perl-$1.git}"
osc mkpac "perl-$1"
(
cd "perl-$1"
osc update
cat << EOF > "_service"
<services>
  <service name="obs_scm">
    <param name="filename">$1</param>
    <param name="scm">git</param>
    <param name="url">$url</param>
    <param name="extract">*.*</param>
    <param name="revision">rawhide</param>
    <param name="without-version">enable</param>
  </service>
  <service name="download_files">
  </service>
</services>
EOF
osc add *
osc ci -m update
osc build
)
