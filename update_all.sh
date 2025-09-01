#!/bin/bash
job(){
if [[ "$INSTALL_ONLY" == yes ]]; 
then
job_install "${@}"
else

for i in "${@}"
do
 if [[ -d "$i" ]]
 then
  (
  cd "$i"
  osc update
  osc service mr
  osc addremove
  osc ci -m update
  osc service rr
  osc rebuild
  )
 fi
done
fi
}

job_install(){
local f=()
for i in "${@}"
do
 if [[ -d "$i" ]]
 then
  cd "$i"
  f+=($(obs_service_pkg_list))
  cd "$OLDPWD"
 fi
done
obs_pkg_install "${f[@]}"
}


if (( "${#}" ))
then
  job "${@}"
else
  job *
fi
