#ifndef _UTILS_MATH_H___
#define _UTILS_MATH_H___

#include <stdint.h>
#include <math.h>

#ifdef __cplusplus
extern "C" {
#endif


#define ABS_DIFF(x, y)  ((x) >= (y) ? ((x) - (y)) : ((y) - (x)))
#define UTILS_MAX(x, y) ((x) >= (y) ? (x) : (y))
#define UTILS_MIN(x, y) ((x) <= (y) ? (x) : (y))


/* bit array */
#define BIT_MASK(b)     (1 << ((b) % 8))
#define BIT_SET(a, b)   ((a)[(b) / 8] |= BIT_MASK(b))    /* Set bit b of bit array a to 1 */
#define BIT_CLR(a, b)   ((a)[(b) / 8] &= ~BIT_MASK(b))   /* Set bit b of bit array a to 0 */
#define BIT_GET(a, b)   (!!((a)[(b) / 8] & BIT_MASK(b))) /* Read the value of bit b in bit array a */
#define BYTE_NUM(nb)    ((nb + 8 - 1) / 8)               /* to declare an array of nb bits */


/* return a random nuber: [min, max] */
int  utils_rand(int min, int max);
void utils_rand_n(int* dst, int min, int max, int n);
void utils_rand_split(int* dst, int range_min, int range_max, int n, int min_value);

int utils_ceil(double num);
int utils_floor(double num);
int utils_round(double num);

int shift_decimal_point(char* szNum, int scaler);
int utils_shell_sort(int arr[], int len);


typedef struct _StatUnit_* StatUnit;

StatUnit stat_new(int size);
void     stat_del(StatUnit self);
int      stat_reset(StatUnit self);
int      stat_push(StatUnit self, double item);
double   stat_min(StatUnit self);
double   stat_max(StatUnit self);
double   stat_avg(StatUnit self);
double   stat_sum(StatUnit self);
double   stat_cur(StatUnit self);
double   stat_variance(StatUnit self);


#ifdef __cplusplus
}
#endif

#endif /* _UTILS_MATH_H___ */
