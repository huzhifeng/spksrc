SPK_NAME = autossh
SPK_VERS = 1.4e
SPK_REV = 1
SPK_ICON = src/autossh.png
DSM_UI_DIR = app

DEPENDS = cross/$(SPK_NAME)

MAINTAINER = Carson Harding
DESCRIPTION = Utility to autorestart SSH tunnels
DESCRIPTION_CHS = 监控并自动恢复 SSH 连接的小工具
RELOAD_UI = yes
DISPLAY_NAME = AutoSSH
CHANGELOG = "First release"

HOMEPAGE = http://www.harding.motd.ca/autossh/
LICENSE  = BSD

WIZARDS_DIR = src/wizard/

INSTALLER_SCRIPT = src/installer.sh
SSS_SCRIPT       = src/dsm-control.sh

INSTALL_PREFIX = /usr/local/$(SPK_NAME)

POST_STRIP_TARGET = autossh_extra_install

include ../../mk/spksrc.spk.mk

.PHONY: autossh_extra_install
autossh_extra_install:
	install -m 755 -d $(STAGING_DIR)/var/run
	install -m 755 -d $(STAGING_DIR)/var/log
	install -m 644 src/autossh.conf $(STAGING_DIR)/var/autossh.conf
