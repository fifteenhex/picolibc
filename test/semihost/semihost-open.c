/*
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Copyright © 2020 Keith Packard
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials provided
 *    with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdlib.h>
#include <semihost.h>

#ifndef TEST_FILE_NAME
#define TEST_FILE_NAME	"SEMIOPEN.TXT"
#endif

int
main(void)
{
	int		fd;
	int		code = 0;
	int		ret;

	fd = sys_semihost_open(TEST_FILE_NAME, SH_OPEN_W);
	if (fd < 0) {
		printf("open %s failed\n", TEST_FILE_NAME);
		exit(1);
	}
	ret = sys_semihost_close(fd);
	fd = -1;
	if (ret != 0) {
		printf("close failed %d %d\n", ret, sys_semihost_errno());
		code = 2;
		goto bail1;
	}
	fd = sys_semihost_open(TEST_FILE_NAME, SH_OPEN_R);
	if (fd < 0) {
		printf("open %s failed\n", TEST_FILE_NAME);
		code = 3;
		goto bail1;
	}
bail1:
	if (fd >= 0)
		(void) sys_semihost_close(fd);
	(void) sys_semihost_remove(TEST_FILE_NAME);
	exit(code);
}
