SHELL := /bin/bash

PLIST_LABEL := com.hide.jxa-reminder
SCRIPT_SRC := ReCreateReminderItems2.jxa
PLIST_TEMPLATE := com.hide.jxa-reminder.plist.template

DEPLOY_DIR ?= $(HOME)/Library/Application Support/jxa-reminder
LAUNCH_AGENTS_DIR ?= $(HOME)/Library/LaunchAgents
PLIST_BUILD_DIR ?= .build

SCRIPT_DST := $(DEPLOY_DIR)/$(SCRIPT_SRC)
PLIST_GENERATED := $(PLIST_BUILD_DIR)/$(PLIST_LABEL).plist
PLIST_INSTALLED := $(LAUNCH_AGENTS_DIR)/$(PLIST_LABEL).plist

LAUNCHCTL_TARGET := gui/$(shell id -u)
LAUNCHCTL_JOB := $(LAUNCHCTL_TARGET)/$(PLIST_LABEL)

.PHONY: deploy deploy-copy-script deploy-generate-plist deploy-install-plist deploy-validate deploy-reload deploy-verify status undeploy

deploy: deploy-copy-script deploy-generate-plist deploy-install-plist deploy-validate deploy-reload deploy-verify
	@echo "deploy completed"

deploy-copy-script:
	@echo "[1/6] Copy script to runtime location"
	@mkdir -p "$(DEPLOY_DIR)"
	@install -m 0644 "$(SCRIPT_SRC)" "$(SCRIPT_DST)"

deploy-generate-plist:
	@echo "[2/6] Generate plist for current environment"
	@mkdir -p "$(PLIST_BUILD_DIR)"
	@SCRIPT_ESCAPED=$$(printf '%s\n' "$(SCRIPT_DST)" | sed 's/[&|]/\\&/g'); \
		sed "s|__JXA_SCRIPT_PATH__|$${SCRIPT_ESCAPED}|g" "$(PLIST_TEMPLATE)" > "$(PLIST_GENERATED)"

deploy-install-plist:
	@echo "[3/6] Install plist to LaunchAgents"
	@mkdir -p "$(LAUNCH_AGENTS_DIR)"
	@install -m 0644 "$(PLIST_GENERATED)" "$(PLIST_INSTALLED)"

deploy-validate:
	@echo "[4/6] Validate plist syntax"
	@plutil -lint "$(PLIST_INSTALLED)"

deploy-reload:
	@echo "[5/6] Reload LaunchAgent"
	@launchctl bootout "$(LAUNCHCTL_TARGET)" "$(PLIST_INSTALLED)" >/dev/null 2>&1 || true
	@launchctl bootstrap "$(LAUNCHCTL_TARGET)" "$(PLIST_INSTALLED)"

deploy-verify:
	@echo "[6/6] Kickstart and print status"
	@launchctl kickstart -k "$(LAUNCHCTL_JOB)"
	@launchctl print "$(LAUNCHCTL_JOB)" | sed -n '1,50p'

status:
	@launchctl print "$(LAUNCHCTL_JOB)" | sed -n '1,80p'

undeploy:
	@echo "Removing LaunchAgent and installed artifacts"
	@launchctl bootout "$(LAUNCHCTL_TARGET)" "$(PLIST_INSTALLED)" >/dev/null 2>&1 || true
	@rm -f "$(PLIST_INSTALLED)"
	@rm -f "$(SCRIPT_DST)"
	@echo "undeploy completed"
