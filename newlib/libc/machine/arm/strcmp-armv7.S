/*
 * Copyright (c) 2012-2014 ARM Ltd
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the company may not be used to endorse or promote
 *    products derived from this software without specific prior written
 *    permission.
 *
 * THIS SOFTWARE IS PROVIDED BY ARM LTD ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL ARM LTD BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

	/* Implementation of strcmp for ARMv7 when DSP instructions are
	   available.  Use ldrd to support wider loads, provided the data
	   is sufficiently aligned.  Use saturating arithmetic to optimize
	   the compares.  */

	/* Build Options:
	   STRCMP_NO_PRECHECK: Don't run a quick pre-check of the first
	   byte in the string.  If comparing completely random strings
	   the pre-check will save time, since there is a very high
	   probability of a mismatch in the first character: we save
	   significant overhead if this is the common case.  However,
	   if strings are likely to be identical (eg because we're
	   verifying a hit in a hash table), then this check is largely
	   redundant.  */

	/* This version uses Thumb-2 code.  */
#include <picolibc.h>

	.thumb
	.syntax unified

#include "arm_asm.h"

/* Parameters and result.  */
#define src1		r0
#define src2		r1
#define result		r0	/* Overlaps src1.  */

/* Internal variables.  */
#define tmp1		r4
#define tmp2		r5
#define const_m1	r12

/* Additional internal variables for 64-bit aligned data.  */
#define data1a		r2
#define data1b		r3
#define data2a		r6
#define data2b		r7
#define syndrome_a	tmp1
#define syndrome_b	tmp2

/* Additional internal variables for 32-bit aligned data.  */
#define data1		r2
#define data2		r3
#define syndrome	tmp2


	/* Macro to compute and return the result value for word-aligned
	   cases.  */
	.macro strcmp_epilogue_aligned synd d1 d2 restore_r6
#ifdef __ARM_BIG_ENDIAN
	/* If data1 contains a zero byte, then syndrome will contain a 1 in
	   bit 7 of that byte.  Otherwise, the highest set bit in the
	   syndrome will highlight the first different bit.  It is therefore
	   sufficient to extract the eight bits starting with the syndrome
	   bit.  */
	clz	tmp1, \synd
	lsl	r1, \d2, tmp1
	.if \restore_r6
	ldrd	r6, r7, [sp, #8]
	.endif
	.cfi_restore 6
	.cfi_restore 7
	lsl	\d1, \d1, tmp1
	.cfi_remember_state
	lsr	result, \d1, #24
	ldrd	r4, r5, [sp], #16
	.cfi_restore 4
	.cfi_restore 5
	.cfi_adjust_cfa_offset -16
	sub	result, result, r1, lsr #24
	epilogue push_ip=HAVE_PAC_LEAF
#else
	/* To use the big-endian trick we'd have to reverse all three words.
	   that's slower than this approach.  */
	rev	\synd, \synd
	clz	tmp1, \synd
	bic	tmp1, tmp1, #7
	lsr	r1, \d2, tmp1
	.cfi_remember_state
	.if \restore_r6
	ldrd	r6, r7, [sp, #8]
	.endif
	.cfi_restore 6
	.cfi_restore 7
	lsr	\d1, \d1, tmp1
	and	result, \d1, #255
	and	r1, r1, #255
	ldrd	r4, r5, [sp], #16
	.cfi_restore 4
	.cfi_restore 5
	.cfi_adjust_cfa_offset -16
	sub	result, result, r1

	epilogue push_ip=HAVE_PAC_LEAF
#endif
	.endm

	.text
	.p2align	5
def_fn	strcmp
	fnstart
	.cfi_sections .debug_frame
	.cfi_startproc
	prologue push_ip=HAVE_PAC_LEAF
#ifndef STRCMP_NO_PRECHECK
	ldrb	r2, [src1]
	ldrb	r3, [src2]
	cmp	r2, #1
	it	cs
	cmpcs	r2, r3
	bne	.Lfastpath_exit
#endif
	strd	r4, r5, [sp, #-16]!
	.cfi_adjust_cfa_offset 16
	.cfi_rel_offset 4, 0
	.cfi_rel_offset 5, 4
	orr	tmp1, src1, src2
	strd	r6, r7, [sp, #8]
	.cfi_rel_offset 6, 8
	.cfi_rel_offset 7, 12
	mvn	const_m1, #0
	lsl	r2, tmp1, #29
	cbz	r2, .Lloop_aligned8

.Lnot_aligned:
	eor	tmp1, src1, src2
	tst	tmp1, #7
	bne	.Lmisaligned8

	/* Deal with mutual misalignment by aligning downwards and then
	   masking off the unwanted loaded data to prevent a difference.  */
	and	tmp1, src1, #7
	bic	src1, src1, #7
	and	tmp2, tmp1, #3
	bic	src2, src2, #7
	lsl	tmp2, tmp2, #3	/* Bytes -> bits.  */
	ldrd	data1a, data1b, [src1], #16
	tst	tmp1, #4
	ldrd	data2a, data2b, [src2], #16
	/* In thumb code we can't use MVN with a register shift, but
	   we do have ORN.  */
	S2HI	tmp1, const_m1, tmp2
	orn	data1a, data1a, tmp1
	orn	data2a, data2a, tmp1
	beq	.Lstart_realigned8
	orn	data1b, data1b, tmp1
	mov	data1a, const_m1
	orn	data2b, data2b, tmp1
	mov	data2a, const_m1
	b	.Lstart_realigned8

	/* Unwind the inner loop by a factor of 2, giving 16 bytes per
	   pass.  */
	.p2align 5,,12  /* Don't start in the tail bytes of a cache line.  */
	.p2align 2	/* Always word aligned.  */
.Lloop_aligned8:
	ldrd	data1a, data1b, [src1], #16
	ldrd	data2a, data2b, [src2], #16
.Lstart_realigned8:
	uadd8	syndrome_b, data1a, const_m1	/* Only want GE bits,  */
	eor	syndrome_a, data1a, data2a
	sel	syndrome_a, syndrome_a, const_m1
	cbnz	syndrome_a, .Ldiff_in_a
	uadd8	syndrome_b, data1b, const_m1	/* Only want GE bits.  */
	eor	syndrome_b, data1b, data2b
	sel	syndrome_b, syndrome_b, const_m1
	cbnz	syndrome_b, .Ldiff_in_b

	ldrd	data1a, data1b, [src1, #-8]
	ldrd	data2a, data2b, [src2, #-8]
	uadd8	syndrome_b, data1a, const_m1	/* Only want GE bits,  */
	eor	syndrome_a, data1a, data2a
	sel	syndrome_a, syndrome_a, const_m1
	uadd8	syndrome_b, data1b, const_m1	/* Only want GE bits.  */
	eor	syndrome_b, data1b, data2b
	sel	syndrome_b, syndrome_b, const_m1
	/* Can't use CBZ for backwards branch.  */
	orrs	syndrome_b, syndrome_b, syndrome_a /* Only need if s_a == 0 */
	beq	.Lloop_aligned8

.Ldiff_found:
	cbnz	syndrome_a, .Ldiff_in_a

.Ldiff_in_b:
	strcmp_epilogue_aligned syndrome_b, data1b, data2b 1

.Ldiff_in_a:
	.cfi_restore_state
	strcmp_epilogue_aligned syndrome_a, data1a, data2a 1

	.cfi_restore_state
.Lmisaligned8:
	tst	tmp1, #3
	bne	.Lmisaligned4
	ands	tmp1, src1, #3
	bne	.Lmutual_align4

	/* Unrolled by a factor of 2, to reduce the number of post-increment
	   operations.  */
.Lloop_aligned4:
	ldr	data1, [src1], #8
	ldr	data2, [src2], #8
.Lstart_realigned4:
	uadd8	syndrome, data1, const_m1	/* Only need GE bits.  */
	eor	syndrome, data1, data2
	sel	syndrome, syndrome, const_m1
	cbnz	syndrome, .Laligned4_done
	ldr	data1, [src1, #-4]
	ldr	data2, [src2, #-4]
	uadd8	syndrome, data1, const_m1
	eor	syndrome, data1, data2
	sel	syndrome, syndrome, const_m1
	cmp	syndrome, #0
	beq	.Lloop_aligned4

.Laligned4_done:
	strcmp_epilogue_aligned syndrome, data1, data2, 0

.Lmutual_align4:
	.cfi_restore_state
	/* Deal with mutual misalignment by aligning downwards and then
	   masking off the unwanted loaded data to prevent a difference.  */
	lsl	tmp1, tmp1, #3	/* Bytes -> bits.  */
	bic	src1, src1, #3
	ldr	data1, [src1], #8
	bic	src2, src2, #3
	ldr	data2, [src2], #8

	/* In thumb code we can't use MVN with a register shift, but
	   we do have ORN.  */
	S2HI	tmp1, const_m1, tmp1
	orn	data1, data1, tmp1
	orn	data2, data2, tmp1
	b	.Lstart_realigned4

.Lmisaligned4:
	ands	tmp1, src1, #3
	beq	.Lsrc1_aligned
	sub	src2, src2, tmp1
	bic	src1, src1, #3
	lsls	tmp1, tmp1, #31
	ldr	data1, [src1], #4
	beq	.Laligned_m2
	bcs	.Laligned_m1

#ifdef STRCMP_NO_PRECHECK
	ldrb	data2, [src2, #1]
	uxtb	tmp1, data1, ror #BYTE1_OFFSET
	subs	tmp1, tmp1, data2
	bne	.Lmisaligned_exit
	cbz	data2, .Lmisaligned_exit

.Laligned_m2:
	ldrb	data2, [src2, #2]
	uxtb	tmp1, data1, ror #BYTE2_OFFSET
	subs	tmp1, tmp1, data2
	bne	.Lmisaligned_exit
	cbz	data2, .Lmisaligned_exit

.Laligned_m1:
	ldrb	data2, [src2, #3]
	uxtb	tmp1, data1, ror #BYTE3_OFFSET
	subs	tmp1, tmp1, data2
	bne	.Lmisaligned_exit
	add	src2, src2, #4
	cbnz	data2, .Lsrc1_aligned
#else  /* STRCMP_NO_PRECHECK */
	/* If we've done the pre-check, then we don't need to check the
	   first byte again here.  */
	ldrb	data2, [src2, #2]
	uxtb	tmp1, data1, ror #BYTE2_OFFSET
	subs	tmp1, tmp1, data2
	bne	.Lmisaligned_exit
	cbz	data2, .Lmisaligned_exit

.Laligned_m2:
	ldrb	data2, [src2, #3]
	uxtb	tmp1, data1, ror #BYTE3_OFFSET
	subs	tmp1, tmp1, data2
	bne	.Lmisaligned_exit
	cbnz	data2, .Laligned_m1
#endif

.Lmisaligned_exit:
	.cfi_remember_state
	mov	result, tmp1
	ldr	r4, [sp], #16
	.cfi_restore 4
	.cfi_adjust_cfa_offset -16
	epilogue push_ip=HAVE_PAC_LEAF

#ifndef STRCMP_NO_PRECHECK
.Lfastpath_exit:
	.cfi_restore_state
	.cfi_remember_state
	sub	r0, r2, r3
	epilogue push_ip=HAVE_PAC_LEAF

.Laligned_m1:
	.cfi_restore_state
	.cfi_remember_state
	add	src2, src2, #4
#endif
.Lsrc1_aligned:
	.cfi_restore_state
	/* src1 is word aligned, but src2 has no common alignment
	   with it.  */
	ldr	data1, [src1], #4
	lsls	tmp1, src2, #31		/* C=src2[1], Z=src2[0].  */

	bic	src2, src2, #3
	ldr	data2, [src2], #4
	bhi	.Loverlap1		/* C=1, Z=0 => src2[1:0] = 0b11.  */
	bcs	.Loverlap2		/* C=1, Z=1 => src2[1:0] = 0b10.  */

	/* (overlap3) C=0, Z=0 => src2[1:0] = 0b01.  */
.Loverlap3:
	bic	tmp1, data1, #MSB
	uadd8	syndrome, data1, const_m1
	eors	syndrome, tmp1, data2, S2LO #8
	sel	syndrome, syndrome, const_m1
	bne	4f
	cbnz	syndrome, 5f
	ldr	data2, [src2], #4
	eor	tmp1, tmp1, data1
	cmp	tmp1, data2, S2HI #24
	bne	6f
	ldr	data1, [src1], #4
	b	.Loverlap3
4:
	S2LO	data2, data2, #8
	b	.Lstrcmp_tail

5:
	bics	syndrome, syndrome, #MSB
	bne	.Lstrcmp_done_equal

	/* We can only get here if the MSB of data1 contains 0, so
	   fast-path the exit.  */
	ldrb	result, [src2]
	.cfi_remember_state
	ldrd	r4, r5, [sp], #16
	.cfi_restore 4
	.cfi_restore 5
	/* R6/7 Not used in this sequence.  */
	.cfi_restore 6
	.cfi_restore 7
	.cfi_adjust_cfa_offset -16
	neg	result, result
	epilogue push_ip=HAVE_PAC_LEAF

6:
	.cfi_restore_state
	S2LO	data1, data1, #24
	and	data2, data2, #LSB
	b	.Lstrcmp_tail

	.p2align 5,,12	/* Ensure at least 3 instructions in cache line.  */
.Loverlap2:
	and	tmp1, data1, const_m1, S2LO #16
	uadd8	syndrome, data1, const_m1
	eors	syndrome, tmp1, data2, S2LO #16
	sel	syndrome, syndrome, const_m1
	bne	4f
	cbnz	syndrome, 5f
	ldr	data2, [src2], #4
	eor	tmp1, tmp1, data1
	cmp	tmp1, data2, S2HI #16
	bne	6f
	ldr	data1, [src1], #4
	b	.Loverlap2
4:
	S2LO	data2, data2, #16
	b	.Lstrcmp_tail
5:
	ands	syndrome, syndrome, const_m1, S2LO #16
	bne	.Lstrcmp_done_equal

	ldrh	data2, [src2]
	S2LO	data1, data1, #16
#ifdef __ARM_BIG_ENDIAN
	lsl	data2, data2, #16
#endif
	b	.Lstrcmp_tail

6:
	S2LO	data1, data1, #16
	and	data2, data2, const_m1, S2LO #16
	b	.Lstrcmp_tail

	.p2align 5,,12	/* Ensure at least 3 instructions in cache line.  */
.Loverlap1:
	and	tmp1, data1, #LSB
	uadd8	syndrome, data1, const_m1
	eors	syndrome, tmp1, data2, S2LO #24
	sel	syndrome, syndrome, const_m1
	bne	4f
	cbnz	syndrome, 5f
	ldr	data2, [src2], #4
	eor	tmp1, tmp1, data1
	cmp	tmp1, data2, S2HI #8
	bne	6f
	ldr	data1, [src1], #4
	b	.Loverlap1
4:
	S2LO	data2, data2, #24
	b	.Lstrcmp_tail
5:
	tst	syndrome, #LSB
	bne	.Lstrcmp_done_equal
	ldr	data2, [src2]
6:
	S2LO	data1, data1, #8
	bic	data2, data2, #MSB
	b	.Lstrcmp_tail

.Lstrcmp_done_equal:
	mov	result, #0
	.cfi_remember_state
	ldrd	r4, r5, [sp], #16
	.cfi_restore 4
	.cfi_restore 5
	/* R6/7 not used in this sequence.  */
	.cfi_restore 6
	.cfi_restore 7
	.cfi_adjust_cfa_offset -16
	epilogue push_ip=HAVE_PAC_LEAF

.Lstrcmp_tail:
	.cfi_restore_state
#ifndef __ARM_BIG_ENDIAN
	rev	data1, data1
	rev	data2, data2
	/* Now everything looks big-endian...  */
#endif
	uadd8	tmp1, data1, const_m1
	eor	tmp1, data1, data2
	sel	syndrome, tmp1, const_m1
	clz	tmp1, syndrome
	lsl	data1, data1, tmp1
	lsl	data2, data2, tmp1
	lsr	result, data1, #24
	ldrd	r4, r5, [sp], #16
	.cfi_restore 4
	.cfi_restore 5
	/* R6/7 not used in this sequence.  */
	.cfi_restore 6
	.cfi_restore 7
	.cfi_adjust_cfa_offset -16
	sub	result, result, data2, lsr #24
	epilogue push_ip=HAVE_PAC_LEAF
	.cfi_endproc
	cantunwind
	fnend
	.size strcmp, . - strcmp
