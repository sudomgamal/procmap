#!/bin/bash
# Test cases

PROCMAP=../procmap

die()
{
echo >&2 "FATAL: $*"
exit 1
}

# runcmd
# Parameters
#   $1 ... : params are the command to run
runcmd()
{
	[ $# -eq 0 ] && return
	echo "$@"
	eval "$@"
}

# PUT = Prg Under Test
gen_and_run_put()
{
cat > /tmp/h.c << @EOF@
#include <stdio.h>
#include <unistd.h>
int main()
{
	int x=42;

	printf("Hello, world! The ans is %d\n", x);
	pause();
}
@EOF@
gcc /tmp/h.c -o /tmp/put -Wall
pkill put
/tmp/put >/dev/null &
}

runtest()
{
echo -n "
******************* "
if [[ "$1" = "p" ]] ; then
   echo "Postive testcase $2 *******************"
elif [[ "$1" = "n" ]] ; then
   echo "Negative testcase $2 *******************"
fi
echo
[[ "$1" = "p" ]] && let PTC=PTC+1
[[ "$1" = "n" ]] && let NTC=NTC+1

shift ; shift
runcmd "$*"
}


#--- 'main'
[[ ! -x ${PROCMAP} ]] && die "procmap script not located crrectly? (value = ${PROCMAP})"
gen_and_run_put
PID=$(pgrep --newest put)
[[ -z "${PID}" ]] && PID=1

# Positive Test Cases (PTCs)
PTC=1
runtest p ${PTC} "${PROCMAP} --pid=${PID}"
runtest p ${PTC} "${PROCMAP} -p ${PID}"
pkill put

# Negative Test Cases (NTCs)
NTC=1
runtest n ${NTC} "${PROCMAP} --pid=-100"
runtest n ${NTC} "${PROCMAP} -p -9"
runtest n ${NTC} "${PROCMAP} -p abc0"
runtest n ${NTC} "${PROCMAP} -p 1234567890"

# test cases with all/any options passed

# test cases with all/any 'config' file variations
exit 0
