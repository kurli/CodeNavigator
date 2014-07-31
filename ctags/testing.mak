#	$Id$
#
#	Copyright (c) 1996-2002, Darren Hiebert
#
#	Development makefile for Exuberant Ctags, used to build releases.
#	Requires GNU make.

CTAGS_TEST = ./ctags
CTAGS_REF = ./ctags.ref
TEST_OPTIONS = -nu --c-kinds=+lpx

DIFF_OPTIONS = -U 0 -I '^!_TAG'
DIFF = $(call DIFF_BASE,tags.ref,tags.test,$(DIFF_FILE))
DIFF_BASE = if diff $(DIFF_OPTIONS) $1 $2 > $3; then \
		rm -f $1 $2 $3 ; \
		echo "Passed" ; \
		true ; \
	  else \
		echo "FAILED: differences left in $3" ; \
		false ; \
	  fi

.PHONY: test test.include test.fields test.extra test.linedir test.etags test.eiffel test.linux test.units

test: test.include test.fields test.extra test.linedir test.etags test.eiffel test.linux test.units

test.%: DIFF_FILE = $@.diff

REF_INCLUDE_OPTIONS = $(TEST_OPTIONS) --format=1
TEST_INCLUDE_OPTIONS = $(TEST_OPTIONS) --format=1
test.include: $(CTAGS_TEST) $(CTAGS_REF)
	@ echo -n "Testing tag inclusion..."
	@ $(CTAGS_REF) -R $(REF_INCLUDE_OPTIONS) -o tags.ref Test
	@ $(CTAGS_TEST) -R $(TEST_INCLUDE_OPTIONS) -o tags.test Test
	@- $(DIFF)

REF_FIELD_OPTIONS = $(TEST_OPTIONS) --fields=+afmikKlnsSz
TEST_FIELD_OPTIONS = $(TEST_OPTIONS) --fields=+afmikKlnsStz
test.fields: $(CTAGS_TEST) $(CTAGS_REF)
	@ echo -n "Testing extension fields..."
	@ $(CTAGS_REF) -R $(REF_FIELD_OPTIONS) -o tags.ref Test
	@ $(CTAGS_TEST) -R $(TEST_FIELD_OPTIONS) -o tags.test Test
	@- $(DIFF)

REF_EXTRA_OPTIONS = $(TEST_OPTIONS) --extra=+fq --format=1
TEST_EXTRA_OPTIONS = $(TEST_OPTIONS) --extra=+fq --format=1
test.extra: $(CTAGS_TEST) $(CTAGS_REF)
	@ echo -n "Testing extra tags..."
	@ $(CTAGS_REF) -R $(REF_EXTRA_OPTIONS) -o tags.ref Test
	@ $(CTAGS_TEST) -R $(TEST_EXTRA_OPTIONS) -o tags.test Test
	@- $(DIFF)

REF_LINEDIR_OPTIONS = $(TEST_OPTIONS) --line-directives -n
TEST_LINEDIR_OPTIONS = $(TEST_OPTIONS) --line-directives -n
test.linedir: $(CTAGS_TEST) $(CTAGS_REF)
	@ echo -n "Testing line directives..."
	@ $(CTAGS_REF) $(REF_LINEDIR_OPTIONS) -o tags.ref Test/line_directives.c
	@ $(CTAGS_TEST) $(TEST_LINEDIR_OPTIONS) -o tags.test Test/line_directives.c
	@- $(DIFF)

REF_ETAGS_OPTIONS = -e
TEST_ETAGS_OPTIONS = -e
test.etags: $(CTAGS_TEST) $(CTAGS_REF)
	@ echo -n "Testing TAGS output..."
	@ $(CTAGS_REF) -R $(REF_ETAGS_OPTIONS) -o tags.ref Test
	@ $(CTAGS_TEST) -R $(TEST_ETAGS_OPTIONS) -o tags.test Test
	@- $(DIFF)

REF_EIFFEL_OPTIONS = $(TEST_OPTIONS) --format=1 --languages=eiffel
TEST_EIFFEL_OPTIONS = $(TEST_OPTIONS) --format=1 --languages=eiffel
EIFFEL_DIRECTORY = $(ISE_EIFFEL)/library/base
HAVE_EIFFEL := $(shell ls -dtr $(EIFFEL_DIRECTORY) 2>/dev/null)
ifeq ($(HAVE_EIFFEL),)
test.eiffel:
	@ echo "No Eiffel library source found for testing"
else
test.eiffel: $(CTAGS_TEST) $(CTAGS_REF)
	@ echo -n "Testing Eiffel tag inclusion..."
	@ $(CTAGS_REF) -R $(REF_EIFFEL_OPTIONS) -o tags.ref $(EIFFEL_DIRECTORY)
	@ $(CTAGS_TEST) -R $(TEST_EIFFEL_OPTIONS) -o tags.test $(EIFFEL_DIRECTORY)
	@- $(DIFF)
endif

REF_LINUX_OPTIONS = $(TEST_OPTIONS) --fields=k
TEST_LINUX_OPTIONS = $(TEST_OPTIONS) --fields=k
LINUX_KERNELS_DIRECTORY :=
LINUX_DIRECTORY := $(shell find $(LINUX_KERNELS_DIRECTORY) -maxdepth 1 -type d -name 'linux-[1-9]*' 2>/dev/null | tail -1)
ifeq ($(LINUX_DIRECTORY),)
test.linux:
	@ echo "No Linux kernel source found for testing"
else
test.linux: $(CTAGS_TEST) $(CTAGS_REF)
	@ echo -n "Testing Linux tag inclusion..."
	@ $(CTAGS_REF) -R $(REF_LINUX_OPTIONS) -o tags.ref $(LINUX_DIRECTORY)
	@ $(CTAGS_TEST) -R $(TEST_LINUX_OPTIONS) -o tags.test $(LINUX_DIRECTORY)
	@- $(DIFF)
endif


UNITS_ARTIFACTS=Units/*.d/EXPECTED.TMP Units/*.d/OUTPUT.TMP Units/*.d/DIFF.TMP
test.units: $(CTAGS_TEST)
	@ \
	success=true; \
	for input in Units/*.d/input.*; do \
		t=$${input%/input.*}; \
		name=$${t%.d}; \
		\
		expected="$$t"/expected; \
		expectedtmp="$$t"/EXPECTED.TMP; \
		args="$$t"/args; \
		filter="$$t"/filter; \
		output="$$t"/OUTPUT.TMP; \
		diff="$$t"/DIFF.TMP; \
		\
		echo -n "Testing $${name}..."; \
		\
		$(CTAGS_TEST) -o - $$(test -f "$${args}" && cat "$$args") "$$input" |	\
		if test -x "$$filter"; then "$$filter"; else cat; fi > "$${output}";	\
		cp "$$expected" "$$expectedtmp"; \
		$(call DIFF_BASE,"$$expectedtmp","$$output","$$diff"); \
		test $$? -eq 0 || success=false; \
	done; \
	$$success

TEST_ARTIFACTS = test.*.diff tags.ref tags.test $(UNITS_ARTIFACTS)
clean-test:
	rm -f $(TEST_ARTIFACTS)

# vi:ts=4 sw=4
