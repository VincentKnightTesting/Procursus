ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS  += make
MAKE_VERSION := 4.4
DEB_MAKE_V   ?= $(MAKE_VERSION)

ifneq (,$(findstring darwin,$(MEMO_TARGET)))
MAKE_CONFIGURE_ARGS := --program-prefix=$(GNU_PREFIX)
endif

make-setup: setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE),https://ftpmirror.gnu.org/make/make-$(MAKE_VERSION).tar.gz{$(comma).sig})
	$(call PGP_VERIFY,make-$(MAKE_VERSION).tar.gz)
	$(call EXTRACT_TAR,make-$(MAKE_VERSION).tar.gz,make-$(MAKE_VERSION),make)

ifneq ($(wildcard $(BUILD_WORK)/make/.build_complete),)
make:
	@echo "Using previously built make."
else
make: make-setup gettext
	cd $(BUILD_WORK)/make && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-guile=no \
		$(MAKE_CONFIGURE_ARGS)
	+$(MAKE) -C $(BUILD_WORK)/make
	+$(MAKE) -C $(BUILD_WORK)/make install \
		DESTDIR="$(BUILD_STAGE)/make"
	$(call AFTER_BUILD)
endif

make-package: make-stage
	# make.mk Package Structure
	rm -rf $(BUILD_DIST)/make
	mkdir -p $(BUILD_DIST)/make/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{bin,include,share/man/man1}

	# make.mk Prep make
	cp -a $(BUILD_STAGE)/make/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{bin,include,share} $(BUILD_DIST)/make/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)

ifneq (,$(findstring darwin,$(MEMO_TARGET)))
	mkdir -p $(BUILD_DIST)/make/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/libexec/gnubin
	for bin in $(BUILD_DIST)/make/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/*; do \
		$(LN_S) $(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/$${bin##*/} $(BUILD_DIST)/make/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/libexec/gnubin/$$(echo $${bin##*/} | cut -c2-); \
	done
endif

	# make.mk Sign
	$(call SIGN,make,general.xml)

	# make.mk Make .debs
	$(call PACK,make,DEB_MAKE_V)

	# make.mk Build cleanup
	rm -rf $(BUILD_DIST)/make

.PHONY: make make-package
