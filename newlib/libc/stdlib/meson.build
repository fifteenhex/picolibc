#
# SPDX-License-Identifier: BSD-3-Clause
#
# Copyright © 2019 Keith Packard
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the following
#    disclaimer in the documentation and/or other materials provided
#    with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
#
nano_malloc_srcs_stdlib = [
  'nano-calloc.c',
  'nano-free.c',
  'nano-getpagesize.c',
  'nano-mallinfo.c',
  'nano-malloc.c',
  'nano-malloc-stats.c',
  'nano-malloc-usable-size.c',
  'nano-mallopt.c',
  'nano-memalign.c',
  'nano-posix-memalign.c',
  'nano-pvalloc.c',
  'nano-realloc.c',
  'nano-valloc.c',
]

std_malloc_srcs_stdlib = [
  'malloc-calloc.c',
  'malloc-cfree.c',
  'malloc-free.c',
  'malloc-mallinfo.c',
  'malloc-malloc.c',
  'malloc-malloc_stats.c',
  'malloc-malloc_usable_size.c',
  'malloc-mallopt.c',
  'malloc-memalign.c',
  'malloc-posix_memalign.c',
  'malloc-pvalloc.c',
  'malloc-realloc.c',
  'malloc-valloc.c',
]

pico_exit_srcs_stdlib = [
  'pico-atexit.c',
  'pico-exit.c',
  'pico-onexit.c',
  'pico-cxa-atexit.c',
  'pico-exitprocs.c',
]

newlib_exit_srcs_stdlib = [
  '__atexit.c',
  '__call_atexit.c',
  'atexit.c',
  'cxa_atexit.c',
  'cxa_finalize.c',
  'exit.c',
  'on_exit.c',
  'quick_exit.c',
]

srcs_stdlib = [
    'a64l.c',
    'abort.c',
    'abs.c',
    'aligned_alloc.c',
    'arc4random.c',
    'arc4random_uniform.c',
    'assert.c',
    'assert_func.c',
    'assert_no_arg.c',
    'atof.c',
    'atoff.c',
    'atoi.c',
    'atol.c',
    'atoll.c',
    'btowc.c',
    'div.c',
    'drand48.c',
    'environ.c',
    'eprintf.c',
    'erand48.c',
    '_Exit.c',
    'getenv.c',
    'getenv_r.c',
    'getopt.c',
    'getsubopt.c',
    'imaxabs.c',
    'imaxdiv.c',
    'itoa.c',
    'jrand48.c',
    'l64a.c',
    'labs.c',
    'lcong48.c',
    'ldiv.c',
    'llabs.c',
    'lldiv.c',
    'lrand48.c',
    'mblen.c',
    'mbrlen.c',
    'mbrtowc.c',
    'mbsinit.c',
    'mbsnrtowcs.c',
    'mbsrtowcs.c',
    'mbstowcs.c',
    'mbtowc.c',
    'mbtowc_r.c',
    'mrand48.c',
    'nrand48.c',
    'putenv.c',
    'rand48.c',
    'rand.c',
    'random.c',
    'rand_r.c',
    'reallocarray.c',
    'reallocf.c',
    'rpmatch.c',
    'sb_charsets.c',
    'seed48.c',
    'setenv.c',
    'srand.c',
    'srand48.c',
    'srandom.c',
    'system.c',
    'utoa.c',
    'wcrtomb.c',
    'wcsnrtombs.c',
    'wcsrtombs.c',
    'wcstombs.c',
    'wctob.c',
    'wctomb.c',
    'wctomb_r.c',
    'set_constraint_handler_s.c',
    'ignore_handler_s.c',
]

srcs_stdlib_stdio = [
    'dtoa.c',
    'ecvtbuf.c',
    'efgcvt.c',
    'gdtoa-gethex.c',
    'gdtoa-hexnan.c',
    'ldtoa.c',
    'mprec.c',
    'strtod.c',
    'strtodg.c',
    'strtol.c',
    'strtoul.c',
    'strtoll.c',
    'strtoull.c',
    'strtoimax.c',
    'strtoumax.c',
    'strtold.c',
    'strtorx.c',
    'wcstod.c',
    'wcstol.c',
    'wcstold.c',
    'wcstoul.c',
    'wcstoimax.c',
    'wcstoll.c',
    'wcstoull.c',
    'wcstoumax.c',
]

if not tinystdio
  srcs_stdlib += srcs_stdlib_stdio
endif

if picoexit
  srcs_stdlib += pico_exit_srcs_stdlib
else
  srcs_stdlib += newlib_exit_srcs_stdlib
endif

hdrs_stdlib = [
    'arc4random.h',
    'atexit.h',
    'chacha_private.h',
    'gd_qnan.h',
    'gdtoa.h',
    'local.h',
    'mbctype.h',
    'mprec.h',
    'rand48.h',
    'std.h',
]

srcs_stdlib_use = []
foreach file : srcs_stdlib
  s_file = fs.replace_suffix(file, '.S')
  if file in srcs_machine
    message('libc/stdlib/' + file + ': machine overrides generic')
  elif s_file in srcs_machine
    message('libc/stdlib/' + s_file + ': machine overrides generic')
  else
    srcs_stdlib_use += file
  endif
endforeach

src_stdlib = files(srcs_stdlib_use)

if enable_malloc
  # Work around compiler optimizing calls involving malloc/free

  c_args_malloc = []
  if cc.has_argument('-fno-builtin-malloc')
    c_args_malloc += ['-fno-builtin-malloc']
  endif

  if cc.has_argument('-fno-builtin-free')
    c_args_malloc += ['-fno-builtin-free']
  endif

  if newlib_nano_malloc
    srcs_stdlib_malloc = nano_malloc_srcs_stdlib
  else
    srcs_stdlib_malloc = std_malloc_srcs_stdlib
  endif

  srcs_stdlib_malloc_use = []
  foreach file : srcs_stdlib_malloc
    s_file = fs.replace_suffix(file, '.S')
    if file in srcs_machine
      message('libc/stdlib/' + file + ': machine overrides generic')
    elif s_file in srcs_machine
      message('libc/stdlib/' + s_file + ': machine overrides generic')
    else
      srcs_stdlib_malloc_use += file
    endif
  endforeach

  foreach params : targets
    target = params['name']
    target_dir = params['dir']
    target_c_args = params['c_args']
    target_lib_prefix = params['lib_prefix']

    # Have to build a sub-library to get custom c_args for malloc
    set_variable('lib_stdlib' + target,
	         static_library('stdlib_malloc' + target,
			        srcs_stdlib_malloc_use,
			        pic: false,
			        include_directories: inc,
			        c_args: target_c_args + c_args + c_args_malloc))

  endforeach
endif
