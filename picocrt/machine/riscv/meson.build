#
# SPDX-License-Identifier: BSD-3-Clause
#
# Copyright © 2021 Keith Packard
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
src_picocrt += files('crt0.c')

if cc.compiles('int i;', args: core_c_args + ['-march=rv32imac_zicsr', '-mabi=ilp32'])
  picocrt_march_add='_zicsr'
  new_targets = []
  foreach params : targets
    target = params['name']
    target_dir = params['dir']
    target_c_args = params['c_args']
    target_lib_prefix = params['lib_prefix']
    new_c_args = []
    foreach c_arg : target_c_args
      if c_arg.startswith('-march') and not c_arg.contains(picocrt_march_add)
	c_arg = c_arg + picocrt_march_add
      endif
      new_c_args += c_arg
    endforeach
    target_c_args = new_c_args
    new_targets += {
                  'name': target,
                  'dir': target_dir,
                  'c_args': target_c_args,
                  'lib_prefix': target_lib_prefix,
                }
  endforeach
  targets = new_targets
endif
