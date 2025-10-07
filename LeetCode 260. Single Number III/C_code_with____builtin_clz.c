int *singleNumber(int *nums, int numsSize, int *returnSize)
{
    int xor_val = 0;
    for (int i = 0; i < numsSize; i++)
    {
        xor_val ^= nums[i];
    }

    int shift = 31 - __builtin_clz((unsigned int)xor_val);
    unsigned int mask = 1U << shift;

    int a = 0, b = 0;
    for (int i = 0; i < numsSize; i++)
    {
        if (nums[i] & mask)
            a ^= nums[i];
        else
            b ^= nums[i];
    }

    int *res = (int *)malloc(2 * sizeof(int));
    res[0] = a;
    res[1] = b;
    *returnSize = 2;
    return res;
}
