#Makefile for GCC
#
#Tom St Denis

ifeq ($V,1)
silent=
else
silent=@
endif

#default files to install
ifndef LIBNAME
   LIBNAME=libtommath.a
endif

coverage: LIBNAME:=-Wl,--whole-archive $(LIBNAME)  -Wl,--no-whole-archive

include makefile_include.mk

%.o: %.c
ifneq ($V,1)
	@echo "   * ${CC} $@"
endif
	${silent} ${CC} -c ${CFLAGS} $< -o $@

LCOV_ARGS=--directory .

#START_INS
OBJECTS=bncore.o bn_error.o bn_fast_mp_invmod.o bn_fast_mp_montgomery_reduce.o bn_fast_s_mp_mul_digs.o \
bn_fast_s_mp_mul_high_digs.o bn_fast_s_mp_sqr.o bn_mp_2expt.o bn_mp_abs.o bn_mp_add.o bn_mp_add_d.o \
bn_mp_addmod.o bn_mp_and.o bn_mp_clamp.o bn_mp_clear.o bn_mp_clear_multi.o bn_mp_cmp.o bn_mp_cmp_d.o \
bn_mp_cmp_mag.o bn_mp_cnt_lsb.o bn_mp_copy.o bn_mp_count_bits.o bn_mp_div_2.o bn_mp_div_2d.o bn_mp_div_3.o \
bn_mp_div.o bn_mp_div_d.o bn_mp_dr_is_modulus.o bn_mp_dr_reduce.o bn_mp_dr_setup.o bn_mp_exch.o \
bn_mp_export.o bn_mp_expt_d.o bn_mp_expt_d_ex.o bn_mp_exptmod.o bn_mp_exptmod_fast.o bn_mp_exteuclid.o \
bn_mp_fread.o bn_mp_fwrite.o bn_mp_gcd.o bn_mp_get_int.o bn_mp_get_long.o bn_mp_get_long_long.o \
bn_mp_grow.o bn_mp_import.o bn_mp_init.o bn_mp_init_copy.o bn_mp_init_multi.o bn_mp_init_set.o \
bn_mp_init_set_int.o bn_mp_init_size.o bn_mp_invmod.o bn_mp_invmod_slow.o bn_mp_is_square.o \
bn_mp_jacobi.o bn_mp_karatsuba_mul.o bn_mp_karatsuba_sqr.o bn_mp_lcm.o bn_mp_lshd.o bn_mp_mod_2d.o \
bn_mp_mod.o bn_mp_mod_d.o bn_mp_montgomery_calc_normalization.o bn_mp_montgomery_reduce.o \
bn_mp_montgomery_setup.o bn_mp_mul_2.o bn_mp_mul_2d.o bn_mp_mul.o bn_mp_mul_d.o bn_mp_mulmod.o bn_mp_neg.o \
bn_mp_n_root.o bn_mp_n_root_ex.o bn_mp_or.o bn_mp_prime_fermat.o bn_mp_prime_is_divisible.o \
bn_mp_prime_is_prime.o bn_mp_prime_miller_rabin.o bn_mp_prime_next_prime.o \
bn_mp_prime_rabin_miller_trials.o bn_mp_prime_random_ex.o bn_mp_radix_size.o bn_mp_radix_smap.o \
bn_mp_rand.o bn_mp_read_radix.o bn_mp_read_signed_bin.o bn_mp_read_unsigned_bin.o bn_mp_reduce_2k.o \
bn_mp_reduce_2k_l.o bn_mp_reduce_2k_setup.o bn_mp_reduce_2k_setup_l.o bn_mp_reduce.o \
bn_mp_reduce_is_2k.o bn_mp_reduce_is_2k_l.o bn_mp_reduce_setup.o bn_mp_rshd.o bn_mp_set.o bn_mp_set_int.o \
bn_mp_set_long.o bn_mp_set_long_long.o bn_mp_shrink.o bn_mp_signed_bin_size.o bn_mp_sqr.o bn_mp_sqrmod.o \
bn_mp_sqrt.o bn_mp_sqrtmod_prime.o bn_mp_sub.o bn_mp_sub_d.o bn_mp_submod.o bn_mp_toom_mul.o \
bn_mp_toom_sqr.o bn_mp_toradix.o bn_mp_toradix_n.o bn_mp_to_signed_bin.o bn_mp_to_signed_bin_n.o \
bn_mp_to_unsigned_bin.o bn_mp_to_unsigned_bin_n.o bn_mp_unsigned_bin_size.o bn_mp_xor.o bn_mp_zero.o \
bn_prime_tab.o bn_reverse.o bn_s_mp_add.o bn_s_mp_exptmod.o bn_s_mp_mul_digs.o bn_s_mp_mul_high_digs.o \
bn_s_mp_sqr.o bn_s_mp_sub.o

#END_INS

$(OBJECTS): $(HEADERS)

$(LIBNAME):  $(OBJECTS)
	$(AR) $(ARFLAGS) $@ $(OBJECTS)
	$(RANLIB) $@

#make a profiled library (takes a while!!!)
#
# This will build the library with profile generation
# then run the test demo and rebuild the library.
#
# So far I've seen improvements in the MP math
profiled:
	make CFLAGS="$(CFLAGS) -fprofile-arcs -DTESTING" timing
	./ltmtest
	rm -f *.a *.o ltmtest
	make CFLAGS="$(CFLAGS) -fbranch-probabilities"

#make a single object profiled library
profiled_single:
	perl gen.pl
	$(CC) $(CFLAGS) -fprofile-arcs -DTESTING -c mpi.c -o mpi.o
	$(CC) $(CFLAGS) -DTESTING -DTIMER demo/timing.c mpi.o -lgcov -o ltmtest
	./ltmtest
	rm -f *.o ltmtest
	$(CC) $(CFLAGS) -fbranch-probabilities -DTESTING -c mpi.c -o mpi.o
	$(AR) $(ARFLAGS) $(LIBNAME) mpi.o
	ranlib $(LIBNAME)

all: all
	$(Q)./etc/slip.sh 1200 "graph"

install: $(LIBNAME)
	install -d $(DESTDIR)$(LIBPATH)
	install -d $(DESTDIR)$(INCPATH)
	install -m 644 $(LIBNAME) $(DESTDIR)$(LIBPATH)
	install -m 644 $(HEADERS_PUB) $(DESTDIR)$(INCPATH)

uninstall:
	rm $(DESTDIR)$(LIBPATH)/$(LIBNAME)
	rm $(HEADERS_PUB:%=$(DESTDIR)$(INCPATH)/%)

test: $(LIBNAME) demo/demo.o
	$(CC) $(CFLAGS) demo/demo.o $(LIBNAME) $(LFLAGS) -o test

test_standalone: $(LIBNAME) demo/demo.o
	$(CC) $(CFLAGS) demo/demo.o $(LIBNAME) $(LFLAGS) -o test

.PHONY: mtest
mtest:
	cd mtest ; $(CC) $(CFLAGS) -O0 mtest.c $(LFLAGS) -o mtest

timing: $(LIBNAME)
	$(CC) $(CFLAGS) -DTIMER demo/timing.c $(LIBNAME) $(LFLAGS) -o ltmtest

# You have to create a file .coveralls.yml with the content "repo_token: <the token>"
# in the base folder to be able to submit to coveralls
coveralls: lcov
	coveralls-lcov

docdvi poster docs mandvi manual:
	$(MAKE) -C doc/ $@ V=$(V)

pretty:
	perl pretty.build

.PHONY: pre_gen
pre_gen:
	perl gen.pl
	sed -e 's/[[:blank:]]*$$//' mpi.c > pre_gen/mpi.c
	rm mpi.c

zipup: clean pre_gen new_file manual poster docs
	@# Update the index, so diff-index won't fail in case the pdf has been created.
	@#   As the pdf creation modifies the tex files, git sometimes detects the
	@#   modified files, but misses that it's put back to its original version.
	@git update-index --refresh
	@git diff-index --quiet HEAD -- || ( echo "FAILURE: uncommited changes or not a git" && exit 1 )
	rm -rf libtommath-$(VERSION) ltm-$(VERSION).*
	@# files/dirs excluded from "git archive" are defined in .gitattributes
	git archive --format=tar --prefix=libtommath-$(VERSION)/ HEAD | tar x
	mkdir -p libtommath-$(VERSION)/doc
	cp doc/bn.pdf doc/tommath.pdf doc/poster.pdf libtommath-$(VERSION)/doc/
	tar -c libtommath-$(VERSION)/ | xz -6e -c - > ltm-$(VERSION).tar.xz
	zip -9rq ltm-$(VERSION).zip libtommath-$(VERSION)
	rm -rf libtommath-$(VERSION)
	gpg -b -a ltm-$(VERSION).tar.xz
	gpg -b -a ltm-$(VERSION).zip

new_file:
	bash updatemakes.sh
	perl dep.pl

perlcritic:
	perlcritic *.pl doc/*.pl

astyle:
	astyle --options=astylerc $(OBJECTS:.o=.c) tommath*.h demo/*.c etc/*.c mtest/mtest.c
