#include <stdint.h>
#include <stdlib.h>

static inline unsigned clz(uint32_t x)
{
    int n = 32, c = 16;
    do
    {
        uint32_t y = x >> c;
        if (y)
        {
            n -= c;
            x = y;
        }
        c >>= 1;
    } while (c);
    return n - x;
}

int *singleNumber(int *nums, int numsSize, int *returnSize)
{
    // This is Step 1
    long xor_val = 0;
    for (int i = 0; i < numsSize; i++)
    {
        xor_val ^= nums[i];
    }

    // This is Step 2
    int shift = 31 - clz((uint32_t)xor_val);
    unsigned int mask = 1U << shift;

    // This is Step 3
    int a = 0, b = 0;
    for (int i = 0; i < numsSize; i++)
    {
        if (nums[i] & mask)
            a ^= nums[i];
        else
            b ^= nums[i];
    }

    // This is Step 4
    int *res = (int *)malloc(2 * sizeof(int));
    res[0] = a;
    res[1] = b;
    *returnSize = 2;
    return res;
}
