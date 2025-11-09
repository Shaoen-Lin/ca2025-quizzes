int *singleNumber(int *nums, int numsSize, int *returnSize)
{
    // This is Step 1
    int xor_val = 0;
    for (int i = 0; i < numsSize; i++)
        xor_val ^= nums[i];

    // This is Step 2
    unsigned int set_bit = (unsigned int)xor_val & -(unsigned int)xor_val;

    // This is Step 3
    int a = 0, b = 0;
    for (int i = 0; i < numsSize; i++)
    {
        if (nums[i] & set_bit)
            a ^= nums[i];
        else
            b ^= nums[i];
    }

    // This is Step 4
    int *res = malloc(sizeof(int) * 2);
    res[0] = a;
    res[1] = b;
    *returnSize = 2;
    return res;
}
