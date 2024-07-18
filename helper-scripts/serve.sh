#!/usr/bin/env bash
set -eou pipefail

script_dir=$(cd "$(dirname "$0")"; pwd)
base_dir=$(cd "$script_dir"/..; pwd)
script_dir=$(basename "$script_dir")
cd "$base_dir"
echo "Current dir: $PWD"

script=$(basename $0 .sh)
ok_file=$script_dir/$script.requirements.ok
log_file=$script_dir/$script.log
pid_file=$script_dir/$script.pid
conf_file=$script_dir/$script.conf
script=$script_dir/$script.sh

source ./.env 2> /dev/null || :
source ./"$conf_file" 2> /dev/null || \
  source ./"$conf_file".example 2> /dev/null

if [ ! -f $ok_file ]
then
  ok=true
  echo "Verifying the requirements to run $script ..."
  command -v serve &> /dev/null || { \
    echo "serve not found. Install it! (npm install -g serve)"
    ok=false
  }
  $ok || exit
  > $ok_file
fi

serve_pid=$([ -f $pid_file ] && \
  echo -n $(<$pid_file) || \
  echo -n "not-found")

# "stop" argument passed:
if [[ $# = 1 && ${1:-} = stop ]]
then
  if [ "$serve_pid" != "not-found" ]
  then
    if ! ps -p $serve_pid > /dev/null
    then
      echo "Process $serve_pid is not running!"
    elif kill $serve_pid
    then
      echo "Process $serve_pid was killed ..."
    fi
    echo "Removing file $pid_file ..."
    rm -f $pid_file
  else
    echo "File $pid_file not found!"
  fi
  exit 0
fi

# default option (no arguments passed)
if [ "$serve_pid" = "not-found" ]
then
  serve -l $PORT $dir &>> $log_file &
  echo $! > $pid_file
  echo "$script started! (PID $(<$pid_file))"
else
  echo "$script is already running! (PID $serve_pid)"
fi
echo "dir: $dir"
echo "PORT: $PORT"
echo "log_file: $log_file"
