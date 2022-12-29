ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS += gitoxide
GITOXIDE_VERSION := 0.20.0
DEB_GITOXIDE_V ?= $(GITOXIDE_VERSION)-1

gitoxide-setup: setup
	$(call GITHUB_ARCHIVE,Bryon,gitoxide,v$(GITOXIDE_VERSION),v$(GITOXIDE_VERSION))
	$(call EXTRACT_TAR,gitoxide-$(gitoxide_VERSION).tar.gz,gitoxide-$(GITOXIDE_VERSION),gitoxide)

ifneq ($(wildcard $(BUILD_WORK)/gitoxide/.build_complete),)
gitoxide:
	@echo "Using previously built gitoxide."
else
gitoxide: gitoxide-setup pcre2
	cd $(BUILD_WORK)/gitoxide && $(DEFAULT_RUST_FLAGS) cargo build \
		--release \
		--target=$(RUST_TARGET) \``
	$(INSTALL) -Dm755 $(BUILD_WORK)/gitoxide/target/$(RUST_TARGET)/release/gix $(BUILD_STAGE)/gitoxide/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/gix	
	$(call AFTER_BUILD)
endif

gitoxide-package: gitoxide-stage
	# gitoxide.mk Package Structure
	rm -rf $(BUILD_DIST)/gitoxide

	# gitoxide.mk Prep gitoxide
	cp -a $(BUILD_STAGE)/gitoxide $(BUILD_DIST)

	# gitoxide.mk Sign
	$(call SIGN,gitoxide,general.xml)

	# gitoxide.mk Make .debs
	$(call PACK,gitoxide,DEB_GITOXIDE_V)

	# gitoxide.mk Build cleanup
	rm -rf $(BUILD_DIST)/gitoxide

.PHONY: gitoxide gitoxide-package
