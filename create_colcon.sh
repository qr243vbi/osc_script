#!/bin/sh
bl='library-path'
flb='library_path'
osc mkpac "python-colcon-$1"
cp python-colcon-"${bl}"/{_service,file.reg} "python-colcon-$1/"
flg="$(echo $1 | sed 's/-/_/g;')"
(
cd "python-colcon-$1"
sed -i "s/$bl/$1/g;" "_service"
sed -i "s/$flb/$flg/g;" "_service"
sed -i "s/$bl/$1/g;" "file.reg"
sed -i "s/$flb/$flg/g;" "file.reg"
obs_service_build "-Dpythons python311" -bb
mv .osc.temp/_output_dir/*.spec ./ ||:
)
