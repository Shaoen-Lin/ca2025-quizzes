#include <stdbool.h>
#include <stdint.h>
#include <string.h>

#define printstr(ptr, length)                          \
    do                                                 \
    {                                                  \
        asm volatile(                                  \
            "add a7, x0, 64\n\t"                       \
            "add a0, x0, 1\n\t" /* stdout */           \
            "mv  a1, %0\n\t"    /* buffer */           \
            "mv  a2, %1\n\t"    /* len   */            \
            "ecall\n\t"                                \
            :                                          \
            : "r"(ptr), "r"(length)                    \
            : "a0", "a1", "a2", "a7", "memory", "cc"); \
    } while (0)

#define TEST_OUTPUT(msg, length) printstr(msg, length)

#define TEST_LOGGER(msg)                     \
    {                                        \
        static const char _msg[] = msg;      \
        TEST_OUTPUT(_msg, sizeof(_msg) - 1); \
    }

extern uint64_t get_cycles(void);
extern uint64_t get_instret(void);
extern void single_number_3(void);
extern void hanoi(void);
extern uint32_t fast_rsqrt(uint32_t x);

/* Bare metal memcpy implementation */
void *memcpy(void *dest, const void *src, size_t n)
{
    uint8_t *d = (uint8_t *)dest;
    const uint8_t *s = (const uint8_t *)src;
    while (n--)
        *d++ = *s++;
    return dest;
}

/* Software division for RV32I (no M extension) */
static unsigned long udiv(unsigned long dividend, unsigned long divisor)
{
    if (divisor == 0)
        return 0;

    unsigned long quotient = 0;
    unsigned long remainder = 0;

    for (int i = 31; i >= 0; i--)
    {
        remainder <<= 1;
        remainder |= (dividend >> i) & 1;

        if (remainder >= divisor)
        {
            remainder -= divisor;
            quotient |= (1UL << i);
        }
    }

    return quotient;
}

static unsigned long umod(unsigned long dividend, unsigned long divisor)
{
    if (divisor == 0)
        return 0;

    unsigned long remainder = 0;

    for (int i = 31; i >= 0; i--)
    {
        remainder <<= 1;
        remainder |= (dividend >> i) & 1;

        if (remainder >= divisor)
        {
            remainder -= divisor;
        }
    }

    return remainder;
}

/* Software multiplication for RV32I (no M extension) */
static uint32_t umul(uint32_t a, uint32_t b)
{
    uint32_t result = 0;
    while (b)
    {
        if (b & 1)
            result += a;
        a <<= 1;
        b >>= 1;
    }
    return result;
}

uint32_t __mulsi3(uint32_t a, uint32_t b)
{
    return umul(a, b);
}

/* Simple integer to hex string conversion */
static void print_hex(unsigned long val)
{
    char buf[20];
    char *p = buf + sizeof(buf) - 1;
    *p = '\n';
    p--;

    if (val == 0)
    {
        *p = '0';
        p--;
    }
    else
    {
        while (val > 0)
        {
            int digit = val & 0xf;
            *p = (digit < 10) ? ('0' + digit) : ('a' + digit - 10);
            p--;
            val >>= 4;
        }
    }

    p++;
    printstr(p, (buf + sizeof(buf) - p));
}

/* Simple integer to decimal string conversion */
static void print_dec(unsigned long val)
{
    char buf[20];
    char *p = buf + sizeof(buf) - 1;
    *p = '\n';
    p--;

    if (val == 0)
    {
        *p = '0';
        p--;
    }
    else
    {
        while (val > 0)
        {
            *p = '0' + umod(val, 10);
            p--;
            val = udiv(val, 10);
        }
    }

    p++;
    printstr(p, (buf + sizeof(buf) - p));
}

/* ============= ADDED print_q16 function ============= */
/* Print fixed-point Q0.16 number in human-readable decimal format */
static void print_q16(uint32_t val)
{
    unsigned long int_part = val >> 16; // Extract integer part (upper 16 bits)

    // Compute fractional part using 64-bit multiplication for precision
    uint64_t tmp = (uint64_t)(val & 0xFFFF) * 1000000ULL; // Scale to 6 decimal digits
    unsigned long frac_part = (unsigned long)(tmp >> 16); // Convert back to 32-bit range (0..999999)

    // Print integer part
    char buf_int[20];
    char *p = buf_int + sizeof(buf_int);
    *--p = '\0';
    unsigned long t = int_part;
    if (t == 0)
        *--p = '0';
    else
    {
        while (t)
        {
            *--p = '0' + umod(t, 10);
            t = udiv(t, 10);
        } // Convert integer digits
    }
    printstr(p, (unsigned)(buf_int + sizeof(buf_int) - 1 - p));

    printstr(".", 1); // Print decimal point

    // Print fractional part (always 6 digits)
    char buf_frac[6];
    for (int i = 5; i >= 0; --i)
    {
        buf_frac[i] = '0' + umod(frac_part, 10);
        frac_part = udiv(frac_part, 10);
    }
    printstr(buf_frac, 6);
    printstr("\n", 1); // New line
}

int main(void)
{
    uint64_t start_cycles, end_cycles, cycles_elapsed;
    uint64_t start_instret, end_instret, instret_elapsed;

    TEST_LOGGER("\n=== LeetCode 260. Single Number III Tests ===\n\n");

    TEST_LOGGER("Test 6: Single Number III\n");
    start_cycles = get_cycles();
    start_instret = get_instret();

    single_number_3();

    end_cycles = get_cycles();
    end_instret = get_instret();
    cycles_elapsed = end_cycles - start_cycles;
    instret_elapsed = end_instret - start_instret;

    TEST_LOGGER("  Cycles: ");
    print_dec((unsigned long)cycles_elapsed);
    TEST_LOGGER("  Instructions: ");
    print_dec((unsigned long)instret_elapsed);
    TEST_LOGGER("\n");

    /*
    TEST_LOGGER("\n=== Quiz2_A Tests ===\n\n");

    TEST_LOGGER("Test 7: Quiz2_A\n");
    start_cycles = get_cycles();
    start_instret = get_instret();

    hanoi();

    end_cycles = get_cycles();
    end_instret = get_instret();
    cycles_elapsed = end_cycles - start_cycles;
    instret_elapsed = end_instret - start_instret;

    TEST_LOGGER("  Cycles: ");
    print_dec((unsigned long) cycles_elapsed);
    TEST_LOGGER("  Instructions: ");
    print_dec((unsigned long) instret_elapsed);
    TEST_LOGGER("\n");


    TEST_LOGGER("\n=== Quiz3_C Tests === \n\n");

    TEST_LOGGER("Test 8: Quiz3_C\n");
    start_cycles = get_cycles();
    start_instret = get_instret();

    uint32_t test[9] = {1, 2, 3, 4, 10, 100, 1000, 10000, 0xFFFFFFFF};

    for (int i = 0; i < 9; i++)
    {
      TEST_LOGGER("Test case ");
      print_dec((unsigned long) (i+1));
      uint32_t inv = fast_rsqrt(test[i]);
      TEST_LOGGER("  Input: ");
      print_dec((unsigned long) test[i]);
      TEST_LOGGER("  rsqrt: ");
      print_q16(inv);
    }

    end_cycles = get_cycles();
    end_instret = get_instret();
    cycles_elapsed = end_cycles - start_cycles;
    instret_elapsed = end_instret - start_instret;

    TEST_LOGGER("  Cycles: ");
    print_dec((unsigned long) cycles_elapsed);
    TEST_LOGGER("  Instructions: ");
    print_dec((unsigned long) instret_elapsed);
    */
    return 0;
}
