#!/bin/bash
# chkconfig: 345 20 80
# description: Play start/shutdown script
# processname: play
#
# Instalation:
# copy file to /etc/init.d
# chmod +x /etc/init.d/play
# chkconfig --add /etc/init.d/play
# chkconfig play on
#
# Usage: (as root)
# service play start
# service play stop
# service play status
#
# Remember, you need python 2.6 to run the play command, it doesn't come standard with RedHat/Centos 5.5
# Also, you may want to temporarely remove the >/dev/null for debugging purposes

# load play config
if [ -r "/etc/sysconfig/play" ]; then
  . /etc/sysconfig/play
else
  echo "No configuration found at /etc/sysconfig/play"
  exit 2
fi

# Path to the JVM
if [ -z "${JAVA_HOME}" -o -d ${JAVA_HOME} ]; then
  echo "No JAVA_HOME env set"
  exit 2
  JAVA_HOME=/path/to/java_home
fi

export JAVA_HOME

# User running the Play process
USER=play

# Path to the application
APPLICATION_PATH=/opt/PE_HOME/pe_presentation

# source function library
. /etc/init.d/functions
RETVAL=0

start() {
	echo -n "Starting Play service: "
	su $USER -c "${PLAY} start ${APPLICATION_PATH} >/dev/null"
	RETVAL=$?
	
	# You may want to start more applications as follows
	# [ $RETVAL -eq 0 ] && su $USER -c "${PLAY} start application2"
    # RETVAL=$?

	if [ $RETVAL -eq 0 ]; then
		echo_success
	else
		echo_failure
	fi
	echo
}
stop() {
	echo -n "Shutting down Play service: "
	${PLAY} stop ${APPLICATION_PATH} > /dev/null
	# ${PLAY} stop application2 > /dev/null
	
	RETVAL=$?

	if [ $RETVAL -eq 0 ]; then
		echo_success
	else
		echo_failure
	fi
	echo
}
status() {
	${PLAY} status ${APPLICATION_PATH}
	RETVAL=$?
}
clean() {
        rm -f ${APPLICATION_PATH}/server.pid
        #rm -f application2/service.pid
}
case "$1" in
	start)
	clean
	start
	;;
	stop)
	stop
	;;
	restart|reload)
	stop
	sleep 10
	start
	;;
	status)
	status
	;;
	clean)
	clean
	;;
	*)
	echo "Usage: $0 {start|stop|restart|status}"
esac
exit 0