#!/bin/sh

# Package
PACKAGE="sabnzbd-testing"
DNAME="SABnzbd Testing"

# Others
INSTALL_DIR="/usr/local/${PACKAGE}"
PYTHON_DIR="/usr/local/python"
PATH="${INSTALL_DIR}/bin:${INSTALL_DIR}/env/bin:${PYTHON_DIR}/bin:${PATH}"
USER="sabnzbd-testing"
PYTHON="${INSTALL_DIR}/env/bin/python"
SABNZBD="${INSTALL_DIR}/share/SABnzbd/SABnzbd.py"
CFG_FILE="${INSTALL_DIR}/var/config.ini"
LOG_FILE="${INSTALL_DIR}/var/logs/sabnzbd.log"
PID_FILE="${INSTALL_DIR}/var/sabnzbd.pid"
LANGUAGE="env LANG=en_US.UTF-8"


start_daemon ()
{
    su ${USER} -c "PATH=${PATH} ${LANGUAGE} ${PYTHON} ${SABNZBD} -f ${CFG_FILE} --pidfile ${PID_FILE} -d"
}

stop_daemon ()
{
    kill `cat ${PID_FILE}`
    wait_for_status 1 20
    kill -9 `cat ${PID_FILE}`
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
    status)
        if daemon_status; then
            echo ${DNAME} is running
            exit 0
        else
            echo ${DNAME} is not running
            exit 1
        fi
        ;;
    log)
        echo ${LOG_FILE}
        exit 0
        ;;
    *)
        exit 1
        ;;
esac
