/*
 * Copyright (c) 2015-2019, ARM Limited and Contributors. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <stddef.h>
#include <stdint.h>

uint32_t RandSeedTZ = 0x12345;

static uint64_t next = 1;  // Seed value

void srand(uint32_t seed)
{
    next = seed;
}

int rand(void)
{
    // Use LCG parameters
    next = next * 1103515245 + 12345;
    return (uint32_t)(next / 65536) % 32768;
}
