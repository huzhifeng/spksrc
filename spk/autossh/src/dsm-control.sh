#!/bin/sh

# Package
PACKAGE="autossh"
DNAME="AutoSSH"

# Others
INSTALL_DIR="/usr/local/${PACKAGE}"
. ${INSTALL_DIR}/var/autossh.conf
PATH="${INSTALL_DIR}/bin:${PATH}"
AUTOSSH="${INSTALL_DIR}/bin/autossh"
PID_FILE="${INSTALL_DIR}${AUTOSSH_PIDFILE}"
LOG_FILE="${INSTALL_DIR}${AUTOSSH_LOGFILE}"

start_daemon ()
{
    AUTOSSH_LOGFILE=${LOG_FILE} AUTOSSH_PIDFILE=${PID_FILE} ${AUTOSSH} -f \
        -M ${AUTOSSH_PORT} -R ${AUTOSSH_REMOTE_PORT}:localhost:${AUTOSSH_LOCAL_PORT} \
        -N -T ${AUTOSSH_EXTRAS_OPTS} -i ${AUTOSSH_IDENTITY_FILE} \
        ${AUTOSSH_USERNAME}@${AUTOSSH_REMOTE_HOST}
}

stop_daemon ()
{
    kill `cat ${PID_FILE}`
    wait_for_status 1 20 || kill -9 `cat ${PID_FILE}`
    rm -f ${PID_FILE}
}

daemon_status ()
{
    if [ -f ${PID_FILE} ] && kill -0 `cat ${PID_FILE}` > /dev/null 2>&1; then
        return
    fi
    rm -f ${PID_FILE}
    return 1
}

wait_for_status ()
{
    counter=$2
    while [ ${counter} -gt 0 ]; do
        daemon_status
        [ $? -eq $1 ] && return
        let counter=counter-1
        sleep 1
    done
    return 1
}


case $1 in
    start)
        if daemon_status; then
            echo ${DNAME} is already running
            exit 0
        else
            echo Starting ${DNAME} ...
            start_daemon
            exit $?
        fi
        ;;
    stop)
        if daemon_status; then
            echo Stopping ${DNAME} ...
            stop_daemon
            exit $?
        else
            echo ${DNAME} is not running
            exit 0
        fi
        ;;
    restart)
        stop_daemon
        start_daemon
        exit $?
        ;;
    status)
        if daemon_status; then
            echo ${DNAME} is running
            exit 0
        else
            echo ${DNAME} is not running
            exit 1
        fi
        ;;
    *)
        exit 1
        ;;
esac
