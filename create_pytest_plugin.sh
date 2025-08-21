#!/bin/sh
osc mkpac "python-pytest-$1"
cp python-pytest-repeat/_service "python-pytest-$1/"
(
cd "python-pytest-$1"
sed -i "s/repeat/$1/g;" "_service"
obs_service_build "-Dpythons python311" -bb
mv .osc.temp/_output_dir/*.spec ./ ||:
)
