constant float g[] = { [0] = 10.0f, [2] = 20.5f };
constant float* constant gp = g;
global int* constant gp2;

kernel void __attribute__((vec_type_hint(int))) kernel_test(global volatile float *pDst, global int *pSrc1, global int *pSrc2)
{
    const int gid = get_global_id(0);
    const int index = get_local_id(0);
    
    if(gid == 0)
    {
        int4 a = (int4)(0x80000000, 100, -1, 0);
        float4 r1 = (float4)(1.0f, 2.0f, 3.0f, 4.0f);
        float4 r2 = (float4)(-1.0f, -2.0f, -3.0f, -4.0f);
        
        float4 dst = a? r1 : r2;
        pDst[0] = dst.x;
        pDst[1] = dst.y;
        pDst[2] = dst.z;
        pDst[3] = dst.w;
    }
    
    int a = 100;
    a += _Generic(a, int:10, default:0);
    pDst[0] = a;
}

