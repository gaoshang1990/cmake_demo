#define _USE_MATH_DEFINES
#include <math.h>

#include "utils_power.h"


/* 复数结构体 */
typedef struct {
    double real;
    double imag;
} Complex;

/* 复数运算 */
static Complex complex_add(Complex a, Complex b)
{
    return (Complex){a.real + b.real, a.imag + b.imag};
}

static Complex complex_mul(Complex a, Complex b)
{
    return (Complex){a.real * b.real - a.imag * b.imag, a.real * b.imag + a.imag * b.real};
}

static Complex polar_to_complex(double mag, double ang_deg)
{
    double ang_rad = ang_deg * M_PI / 180.0;
    return (Complex){mag * cos(ang_rad), mag * sin(ang_rad)};
}

static void complex_to_polar(Complex c, double* mag, double* ang_deg)
{
    *mag     = sqrt(c.real * c.real + c.imag * c.imag);
    *ang_deg = atan2(c.imag, c.real) * 180.0 / M_PI;

    /* 将角度归一化到 [-180, 180] */
    while (*ang_deg > 180.0)
        *ang_deg -= 360.0;
    while (*ang_deg < -180.0)
        *ang_deg += 360.0;
}

/* α算子: 1∠120° */
static const Complex ALPHA = {-0.5, 0.866025403784439};
/* α²算子: 1∠240° */
static const Complex ALPHA_SQR = {-0.5, -0.866025403784439};

SeqComp sym_seq(double mag_a, double ang_a, double mag_b, double ang_b, double mag_c, double ang_c)
{
    SeqComp result = {0};

    /* 将极坐标形式转换为复数形式 */
    Complex va = polar_to_complex(mag_a, ang_a);
    Complex vb = polar_to_complex(mag_b, ang_b);
    Complex vc = polar_to_complex(mag_c, ang_c);

    /* 计算正序分量: V1 = (Va + αVb + α²Vc) / 3 */
    Complex v_pos = complex_add(va, complex_add(complex_mul(ALPHA, vb), complex_mul(ALPHA_SQR, vc)));
    v_pos.real /= 3.0;
    v_pos.imag /= 3.0;

    /* 计算负序分量: V2 = (Va + α²Vb + αVc) / 3 */
    Complex v_neg = complex_add(va, complex_add(complex_mul(ALPHA_SQR, vb), complex_mul(ALPHA, vc)));
    v_neg.real /= 3.0;
    v_neg.imag /= 3.0;

    /* 计算零序分量: V0 = (Va + Vb + Vc) / 3 */
    Complex v_zero = complex_add(va, complex_add(vb, vc));
    v_zero.real /= 3.0;
    v_zero.imag /= 3.0;

    /* 转换回极坐标形式 */
    complex_to_polar(v_pos, &result.pos.mag, &result.pos.ang);
    complex_to_polar(v_neg, &result.neg.mag, &result.neg.ang);
    complex_to_polar(v_zero, &result.zero.mag, &result.zero.ang);

    return result;
}
