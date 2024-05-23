#include <stdio.h>

typedef struct descriptor
{
    unsigned short limit_low;
    unsigned int base_low : 24;
    unsigned char type : 4;
    unsigned char segment : 1;
    unsigned char DPL : 2;
    unsigned char present : 1;
    unsigned char limit_high : 4;
    unsigned char available : 1;
    unsigned char long_mode : 1;
    unsigned char big : 1;
    unsigned char granularity : 1;
    unsigned char base_high;
} __attribute__((packed)) descriptor;

void make_descriptor(descriptor * dest, unsigned int base, unsigned int limit){
    dest->base_low = base & 0xffffff;
    dest->base_high = (base >> 24) & 0xff;
    dest->limit_low = limit & 0xffff;
    dest->base_high = (limit >> 16) & 0xf;
}
int main(){
    descriptor dest;
    make_descriptor(&dest,  0x10000, 0x1000 - 1);
    dest.granularity = 0; // byte
    dest.big = 1;
    dest.long_mode = 0;
    dest.present = 1;
    dest.DPL = 0;
    dest.segment = 1;
    dest.type = 0b0010;



    char * ptr = (char*) &dest;
    unsigned short value16 = *(short *) ptr;
    printf("dw, 0x%x\n", value16);

    ptr += 2; 
    value16 = *(short *) ptr;
    printf("dw, 0x%x\n", value16);

    return 0;
}
