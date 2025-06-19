#ifndef _UTILS_POWER_H___
#define _UTILS_POWER_H___

#include <stdint.h>

/* 极坐标量 */
typedef struct {
    double mag; /* 幅值 */
    double ang; /* 相角(度) */
} PolarQty;

/* 三相序分量计算结果 */
typedef struct {
    PolarQty pos;  /* 正序分量 */
    PolarQty neg;  /* 负序分量 */
    PolarQty zero; /* 零序分量 */
} SeqComp;

/**
 * @brief 计算三相序分量
 * @param mag_a/b/c: A/B/C相幅值
 * @param ang_a/b/c: A/B/C相相角(度)
 * @return 序分量计算结果
 */
SeqComp sym_seq(double mag_a, double ang_a, double mag_b, double ang_b, double mag_c, double ang_c);

#endif /* _UTILS_POWER_H___ */
