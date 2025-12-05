#!/bin/sh
osc mkpac "python-$1"
cp python-rospkg/_service "python-$1/"
(
cd "python-$1"
sed -i "s/rospkg/$1/g;" "_service"
obs_service_build "-Dpythons python311" -bb
mv .osc.temp/_output_dir/*.spec ./ ||:
)
