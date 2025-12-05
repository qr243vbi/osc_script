#!/bin/bash
url="${url:-https://salsa.debian.org/perl-team/modules/packages/lib$1-perl.git}"
osc mkpac "perl-$1"
(
cd "perl-$1"
osc update
sd="(cd $1; dzil build; ); mv $1/*-*.tar.gz"' "${outdir}"'
cat << EOF > "_service"
<services>
  <service name="obs_scm">
    <param name="filename">$1</param>
    <param name="scm">git</param>
    <param name="url">$url</param>
    <param name="without-version">enable</param>
  </service>
  <service name="run" mode="buildtime">
    <param name="command">$sd</param>
  </service>
  <service name="cpanspec" mode="buildtime">
    <param name="source">*.tar.gz</param>
  </service>
</services>
EOF
obs_service_run
cp .osc.temp/_output_dir/*.spec ./
#rm -Rf .osc/*_dir
osc add *
osc ci -m update
)
