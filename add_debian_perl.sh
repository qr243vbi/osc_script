#!/bin/bash
url="${url:-https://salsa.debian.org/perl-team/modules/packages/lib$1-perl.git}"
osc mkpac "perl-$1"
(
cd "perl-$1"
osc update
sd='"s~\(version:\).*~\1 $(cat *.yml | yq -r .version)~"'
cat << EOF > "_service"
<services>
  <service name="obs_scm">
    <param name="filename">$1</param>
    <param name="scm">git</param>
    <param name="url">$url</param>
    <param name="extract">*META.yml</param>
    <param name="without-version">enable</param>
  </service>
  <service name="run" mode="buildtime">
    <param name="command">sed -i $sd *.obsinfo</param>
  </service>
  <service name="tar" mode="buildtime"/>
  <service name="recompress" mode="buildtime">
    <param name="compression">gz</param>
    <param name="file">*.tar</param>
  </service>
  <service name="cpanspec" mode="buildtime">
    <param name="source">*.tar.gz</param>
  </service>
</services>
EOF
obs_service_run
cp .osc.temp/_output_dir/*.spec ./
#rm -Rf .osc.temp/*_dir
osc add *
osc ci -m update
)
