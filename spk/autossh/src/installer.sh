#!/bin/sh

# Package
PACKAGE="autossh"
DNAME="AutoSSH"

# Others
INSTALL_DIR="/usr/local/${PACKAGE}"
SSS="/var/packages/${PACKAGE}/scripts/start-stop-status"
PATH="${INSTALL_DIR}/bin:${PATH}"
CFG_FILE="${INSTALL_DIR}/var/autossh.conf"
TMP_DIR="${SYNOPKG_PKGDEST}/../../@tmp"

preinst ()
{
    if [ "${SYNOPKG_PKG_STATUS}" == "INSTALL" ]; then
        if [ -n "${wizard_rsa_file}" -a ! -d "${wizard_rsa_file}" ]; then
            echo "RSA file ${wizard_rsa_file} does not exist."
            exit 1
        fi
    fi

    exit 0
}

postinst ()
{
    # Link
    ln -s ${SYNOPKG_PKGDEST} ${INSTALL_DIR}

    if [ "${SYNOPKG_PKG_STATUS}" == "INSTALL" ]; then
        # Edit the configuration according to the wizard
        sed -e "s|@autossh_username@|${wizard_username:=root}|g" \
            -e "s|@autossh_remote_host@|${wizard_remote_host:=example.com}|g" \
            -e "s|@autossh_remote_port@|${wizard_remote_port:=8224}|g" \
            -e "s|@autossh_local_port@|${wizard_local_port:=22}|g" \
            -e "s|@autossh_identity_file@|${wizard_identity_file:=/root/.ssh/id_rsa}|g" \
            -e "s|@autossh_monitor_port@|${wizard_monitor_port:=8324}|g" \
            -e "s|@autossh_extra_opts@|${wizard_extra_opts:=\
-o PubkeyAuthentication=yes -o PasswordAuthentication=no \
-o ServerAliveInterval=6 -o ServerAliveCountMax=3 \
-o StrictHostKeyChecking=no}|g" \
            -i ${CFG_FILE}
    fi

    exit 0
}

preuninst ()
{
    # Stop the package
    ${SSS} stop > /dev/null

    exit 0
}

postuninst ()
{
    # Remove link
    rm -f ${INSTALL_DIR}

    exit 0
}

preupgrade ()
{
    # Stop the package
    ${SSS} stop > /dev/null

    # Save some stuff
    rm -fr ${TMP_DIR}/${PACKAGE}
    mkdir -p ${TMP_DIR}/${PACKAGE}
    mv ${INSTALL_DIR}/var ${TMP_DIR}/${PACKAGE}/

    exit 0
}

postupgrade ()
{
    # Restore some stuff
    rm -fr ${INSTALL_DIR}/var
    mv ${TMP_DIR}/${PACKAGE}/var ${INSTALL_DIR}/
    rm -fr ${TMP_DIR}/${PACKAGE}

    exit 0
}
