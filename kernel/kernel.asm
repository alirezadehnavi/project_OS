
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	98010113          	addi	sp,sp,-1664 # 80007980 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddb4f>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	de278793          	addi	a5,a5,-542 # 80000e62 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	f84a                	sd	s2,48(sp)
    800000d8:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000da:	04c05263          	blez	a2,8000011e <consolewrite+0x4e>
    800000de:	fc26                	sd	s1,56(sp)
    800000e0:	f44e                	sd	s3,40(sp)
    800000e2:	f052                	sd	s4,32(sp)
    800000e4:	ec56                	sd	s5,24(sp)
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	15a020ef          	jal	80002254 <either_copyin>
    800000fe:	03550263          	beq	a0,s5,80000122 <consolewrite+0x52>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	035000ef          	jal	8000093a <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
    80000112:	894e                	mv	s2,s3
    80000114:	74e2                	ld	s1,56(sp)
    80000116:	79a2                	ld	s3,40(sp)
    80000118:	7a02                	ld	s4,32(sp)
    8000011a:	6ae2                	ld	s5,24(sp)
    8000011c:	a039                	j	8000012a <consolewrite+0x5a>
    8000011e:	4901                	li	s2,0
    80000120:	a029                	j	8000012a <consolewrite+0x5a>
    80000122:	74e2                	ld	s1,56(sp)
    80000124:	79a2                	ld	s3,40(sp)
    80000126:	7a02                	ld	s4,32(sp)
    80000128:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    8000012a:	854a                	mv	a0,s2
    8000012c:	60a6                	ld	ra,72(sp)
    8000012e:	6406                	ld	s0,64(sp)
    80000130:	7942                	ld	s2,48(sp)
    80000132:	6161                	addi	sp,sp,80
    80000134:	8082                	ret

0000000080000136 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000136:	711d                	addi	sp,sp,-96
    80000138:	ec86                	sd	ra,88(sp)
    8000013a:	e8a2                	sd	s0,80(sp)
    8000013c:	e4a6                	sd	s1,72(sp)
    8000013e:	e0ca                	sd	s2,64(sp)
    80000140:	fc4e                	sd	s3,56(sp)
    80000142:	f852                	sd	s4,48(sp)
    80000144:	f456                	sd	s5,40(sp)
    80000146:	f05a                	sd	s6,32(sp)
    80000148:	1080                	addi	s0,sp,96
    8000014a:	8aaa                	mv	s5,a0
    8000014c:	8a2e                	mv	s4,a1
    8000014e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000150:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000154:	00010517          	auipc	a0,0x10
    80000158:	82c50513          	addi	a0,a0,-2004 # 8000f980 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	00010497          	auipc	s1,0x10
    80000164:	82048493          	addi	s1,s1,-2016 # 8000f980 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00010917          	auipc	s2,0x10
    8000016c:	8b090913          	addi	s2,s2,-1872 # 8000fa18 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	760010ef          	jal	800018e0 <myproc>
    80000184:	763010ef          	jal	800020e6 <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	521010ef          	jal	80001eae <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	0000f717          	auipc	a4,0xf
    800001a4:	7e070713          	addi	a4,a4,2016 # 8000f980 <cons>
    800001a8:	0017869b          	addiw	a3,a5,1
    800001ac:	08d72c23          	sw	a3,152(a4)
    800001b0:	07f7f693          	andi	a3,a5,127
    800001b4:	9736                	add	a4,a4,a3
    800001b6:	01874703          	lbu	a4,24(a4)
    800001ba:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001be:	4691                	li	a3,4
    800001c0:	04db8663          	beq	s7,a3,8000020c <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001c4:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c8:	4685                	li	a3,1
    800001ca:	faf40613          	addi	a2,s0,-81
    800001ce:	85d2                	mv	a1,s4
    800001d0:	8556                	mv	a0,s5
    800001d2:	038020ef          	jal	8000220a <either_copyout>
    800001d6:	57fd                	li	a5,-1
    800001d8:	04f50863          	beq	a0,a5,80000228 <consoleread+0xf2>
      break;

    dst++;
    800001dc:	0a05                	addi	s4,s4,1
    --n;
    800001de:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001e0:	47a9                	li	a5,10
    800001e2:	04fb8d63          	beq	s7,a5,8000023c <consoleread+0x106>
    800001e6:	6be2                	ld	s7,24(sp)
    800001e8:	b761                	j	80000170 <consoleread+0x3a>
        release(&cons.lock);
    800001ea:	0000f517          	auipc	a0,0xf
    800001ee:	79650513          	addi	a0,a0,1942 # 8000f980 <cons>
    800001f2:	29b000ef          	jal	80000c8c <release>
        return -1;
    800001f6:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800001f8:	60e6                	ld	ra,88(sp)
    800001fa:	6446                	ld	s0,80(sp)
    800001fc:	64a6                	ld	s1,72(sp)
    800001fe:	6906                	ld	s2,64(sp)
    80000200:	79e2                	ld	s3,56(sp)
    80000202:	7a42                	ld	s4,48(sp)
    80000204:	7aa2                	ld	s5,40(sp)
    80000206:	7b02                	ld	s6,32(sp)
    80000208:	6125                	addi	sp,sp,96
    8000020a:	8082                	ret
      if(n < target){
    8000020c:	0009871b          	sext.w	a4,s3
    80000210:	01677a63          	bgeu	a4,s6,80000224 <consoleread+0xee>
        cons.r--;
    80000214:	00010717          	auipc	a4,0x10
    80000218:	80f72223          	sw	a5,-2044(a4) # 8000fa18 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	0000f517          	auipc	a0,0xf
    8000022e:	75650513          	addi	a0,a0,1878 # 8000f980 <cons>
    80000232:	25b000ef          	jal	80000c8c <release>
  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	bf7d                	j	800001f8 <consoleread+0xc2>
    8000023c:	6be2                	ld	s7,24(sp)
    8000023e:	b7f5                	j	8000022a <consoleread+0xf4>

0000000080000240 <consputc>:
{
    80000240:	1141                	addi	sp,sp,-16
    80000242:	e406                	sd	ra,8(sp)
    80000244:	e022                	sd	s0,0(sp)
    80000246:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000248:	10000793          	li	a5,256
    8000024c:	00f50863          	beq	a0,a5,8000025c <consputc+0x1c>
    uartputc_sync(c);
    80000250:	604000ef          	jal	80000854 <uartputc_sync>
}
    80000254:	60a2                	ld	ra,8(sp)
    80000256:	6402                	ld	s0,0(sp)
    80000258:	0141                	addi	sp,sp,16
    8000025a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000025c:	4521                	li	a0,8
    8000025e:	5f6000ef          	jal	80000854 <uartputc_sync>
    80000262:	02000513          	li	a0,32
    80000266:	5ee000ef          	jal	80000854 <uartputc_sync>
    8000026a:	4521                	li	a0,8
    8000026c:	5e8000ef          	jal	80000854 <uartputc_sync>
    80000270:	b7d5                	j	80000254 <consputc+0x14>

0000000080000272 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000272:	1101                	addi	sp,sp,-32
    80000274:	ec06                	sd	ra,24(sp)
    80000276:	e822                	sd	s0,16(sp)
    80000278:	e426                	sd	s1,8(sp)
    8000027a:	1000                	addi	s0,sp,32
    8000027c:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000027e:	0000f517          	auipc	a0,0xf
    80000282:	70250513          	addi	a0,a0,1794 # 8000f980 <cons>
    80000286:	16f000ef          	jal	80000bf4 <acquire>

  switch(c){
    8000028a:	47d5                	li	a5,21
    8000028c:	08f48f63          	beq	s1,a5,8000032a <consoleintr+0xb8>
    80000290:	0297c563          	blt	a5,s1,800002ba <consoleintr+0x48>
    80000294:	47a1                	li	a5,8
    80000296:	0ef48463          	beq	s1,a5,8000037e <consoleintr+0x10c>
    8000029a:	47c1                	li	a5,16
    8000029c:	10f49563          	bne	s1,a5,800003a6 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002a0:	7ff010ef          	jal	8000229e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	0000f517          	auipc	a0,0xf
    800002a8:	6dc50513          	addi	a0,a0,1756 # 8000f980 <cons>
    800002ac:	1e1000ef          	jal	80000c8c <release>
}
    800002b0:	60e2                	ld	ra,24(sp)
    800002b2:	6442                	ld	s0,16(sp)
    800002b4:	64a2                	ld	s1,8(sp)
    800002b6:	6105                	addi	sp,sp,32
    800002b8:	8082                	ret
  switch(c){
    800002ba:	07f00793          	li	a5,127
    800002be:	0cf48063          	beq	s1,a5,8000037e <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002c2:	0000f717          	auipc	a4,0xf
    800002c6:	6be70713          	addi	a4,a4,1726 # 8000f980 <cons>
    800002ca:	0a072783          	lw	a5,160(a4)
    800002ce:	09872703          	lw	a4,152(a4)
    800002d2:	9f99                	subw	a5,a5,a4
    800002d4:	07f00713          	li	a4,127
    800002d8:	fcf766e3          	bltu	a4,a5,800002a4 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002dc:	47b5                	li	a5,13
    800002de:	0cf48763          	beq	s1,a5,800003ac <consoleintr+0x13a>
      consputc(c);
    800002e2:	8526                	mv	a0,s1
    800002e4:	f5dff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002e8:	0000f797          	auipc	a5,0xf
    800002ec:	69878793          	addi	a5,a5,1688 # 8000f980 <cons>
    800002f0:	0a07a683          	lw	a3,160(a5)
    800002f4:	0016871b          	addiw	a4,a3,1
    800002f8:	0007061b          	sext.w	a2,a4
    800002fc:	0ae7a023          	sw	a4,160(a5)
    80000300:	07f6f693          	andi	a3,a3,127
    80000304:	97b6                	add	a5,a5,a3
    80000306:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000030a:	47a9                	li	a5,10
    8000030c:	0cf48563          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000310:	4791                	li	a5,4
    80000312:	0cf48263          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000316:	0000f797          	auipc	a5,0xf
    8000031a:	7027a783          	lw	a5,1794(a5) # 8000fa18 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	0000f717          	auipc	a4,0xf
    80000330:	65470713          	addi	a4,a4,1620 # 8000f980 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	0000f497          	auipc	s1,0xf
    80000340:	64448493          	addi	s1,s1,1604 # 8000f980 <cons>
    while(cons.e != cons.w &&
    80000344:	4929                	li	s2,10
    80000346:	02f70863          	beq	a4,a5,80000376 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	37fd                	addiw	a5,a5,-1
    8000034c:	07f7f713          	andi	a4,a5,127
    80000350:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000352:	01874703          	lbu	a4,24(a4)
    80000356:	03270263          	beq	a4,s2,8000037a <consoleintr+0x108>
      cons.e--;
    8000035a:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000035e:	10000513          	li	a0,256
    80000362:	edfff0ef          	jal	80000240 <consputc>
    while(cons.e != cons.w &&
    80000366:	0a04a783          	lw	a5,160(s1)
    8000036a:	09c4a703          	lw	a4,156(s1)
    8000036e:	fcf71ee3          	bne	a4,a5,8000034a <consoleintr+0xd8>
    80000372:	6902                	ld	s2,0(sp)
    80000374:	bf05                	j	800002a4 <consoleintr+0x32>
    80000376:	6902                	ld	s2,0(sp)
    80000378:	b735                	j	800002a4 <consoleintr+0x32>
    8000037a:	6902                	ld	s2,0(sp)
    8000037c:	b725                	j	800002a4 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000037e:	0000f717          	auipc	a4,0xf
    80000382:	60270713          	addi	a4,a4,1538 # 8000f980 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	68f72623          	sw	a5,1676(a4) # 8000fa20 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea1ff0ef          	jal	80000240 <consputc>
    800003a4:	b701                	j	800002a4 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	ee048fe3          	beqz	s1,800002a4 <consoleintr+0x32>
    800003aa:	bf21                	j	800002c2 <consoleintr+0x50>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e93ff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	0000f797          	auipc	a5,0xf
    800003b6:	5ce78793          	addi	a5,a5,1486 # 8000f980 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	0000f797          	auipc	a5,0xf
    800003da:	64c7a323          	sw	a2,1606(a5) # 8000fa1c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	63a50513          	addi	a0,a0,1594 # 8000fa18 <cons+0x98>
    800003e6:	315010ef          	jal	80001efa <wakeup>
    800003ea:	bd6d                	j	800002a4 <consoleintr+0x32>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c0c58593          	addi	a1,a1,-1012 # 80007000 <etext>
    800003fc:	0000f517          	auipc	a0,0xf
    80000400:	58450513          	addi	a0,a0,1412 # 8000f980 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	0001f797          	auipc	a5,0x1f
    80000410:	70c78793          	addi	a5,a5,1804 # 8001fb18 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d2270713          	addi	a4,a4,-734 # 80000136 <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7179                	addi	sp,sp,-48
    80000432:	f406                	sd	ra,40(sp)
    80000434:	f022                	sd	s0,32(sp)
    80000436:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000438:	c219                	beqz	a2,8000043e <printint+0xe>
    8000043a:	08054063          	bltz	a0,800004ba <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000043e:	4881                	li	a7,0
    80000440:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000444:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000446:	00007617          	auipc	a2,0x7
    8000044a:	38a60613          	addi	a2,a2,906 # 800077d0 <digits>
    8000044e:	883e                	mv	a6,a5
    80000450:	2785                	addiw	a5,a5,1
    80000452:	02b57733          	remu	a4,a0,a1
    80000456:	9732                	add	a4,a4,a2
    80000458:	00074703          	lbu	a4,0(a4)
    8000045c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000460:	872a                	mv	a4,a0
    80000462:	02b55533          	divu	a0,a0,a1
    80000466:	0685                	addi	a3,a3,1
    80000468:	feb773e3          	bgeu	a4,a1,8000044e <printint+0x1e>

  if(sign)
    8000046c:	00088a63          	beqz	a7,80000480 <printint+0x50>
    buf[i++] = '-';
    80000470:	1781                	addi	a5,a5,-32
    80000472:	97a2                	add	a5,a5,s0
    80000474:	02d00713          	li	a4,45
    80000478:	fee78823          	sb	a4,-16(a5)
    8000047c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000480:	02f05963          	blez	a5,800004b2 <printint+0x82>
    80000484:	ec26                	sd	s1,24(sp)
    80000486:	e84a                	sd	s2,16(sp)
    80000488:	fd040713          	addi	a4,s0,-48
    8000048c:	00f704b3          	add	s1,a4,a5
    80000490:	fff70913          	addi	s2,a4,-1
    80000494:	993e                	add	s2,s2,a5
    80000496:	37fd                	addiw	a5,a5,-1
    80000498:	1782                	slli	a5,a5,0x20
    8000049a:	9381                	srli	a5,a5,0x20
    8000049c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	d9dff0ef          	jal	80000240 <consputc>
  while(--i >= 0)
    800004a8:	14fd                	addi	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
    800004ae:	64e2                	ld	s1,24(sp)
    800004b0:	6942                	ld	s2,16(sp)
}
    800004b2:	70a2                	ld	ra,40(sp)
    800004b4:	7402                	ld	s0,32(sp)
    800004b6:	6145                	addi	sp,sp,48
    800004b8:	8082                	ret
    x = -xx;
    800004ba:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004be:	4885                	li	a7,1
    x = -xx;
    800004c0:	b741                	j	80000440 <printint+0x10>

00000000800004c2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c2:	7155                	addi	sp,sp,-208
    800004c4:	e506                	sd	ra,136(sp)
    800004c6:	e122                	sd	s0,128(sp)
    800004c8:	f0d2                	sd	s4,96(sp)
    800004ca:	0900                	addi	s0,sp,144
    800004cc:	8a2a                	mv	s4,a0
    800004ce:	e40c                	sd	a1,8(s0)
    800004d0:	e810                	sd	a2,16(s0)
    800004d2:	ec14                	sd	a3,24(s0)
    800004d4:	f018                	sd	a4,32(s0)
    800004d6:	f41c                	sd	a5,40(s0)
    800004d8:	03043823          	sd	a6,48(s0)
    800004dc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004e0:	0000f797          	auipc	a5,0xf
    800004e4:	5607a783          	lw	a5,1376(a5) # 8000fa40 <pr+0x18>
    800004e8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004ec:	e3a1                	bnez	a5,8000052c <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004ee:	00840793          	addi	a5,s0,8
    800004f2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004f6:	00054503          	lbu	a0,0(a0)
    800004fa:	26050763          	beqz	a0,80000768 <printf+0x2a6>
    800004fe:	fca6                	sd	s1,120(sp)
    80000500:	f8ca                	sd	s2,112(sp)
    80000502:	f4ce                	sd	s3,104(sp)
    80000504:	ecd6                	sd	s5,88(sp)
    80000506:	e8da                	sd	s6,80(sp)
    80000508:	e0e2                	sd	s8,64(sp)
    8000050a:	fc66                	sd	s9,56(sp)
    8000050c:	f86a                	sd	s10,48(sp)
    8000050e:	f46e                	sd	s11,40(sp)
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    8000052a:	a815                	j	8000055e <printf+0x9c>
    acquire(&pr.lock);
    8000052c:	0000f517          	auipc	a0,0xf
    80000530:	4fc50513          	addi	a0,a0,1276 # 8000fa28 <pr>
    80000534:	6c0000ef          	jal	80000bf4 <acquire>
  va_start(ap, fmt);
    80000538:	00840793          	addi	a5,s0,8
    8000053c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000540:	000a4503          	lbu	a0,0(s4)
    80000544:	fd4d                	bnez	a0,800004fe <printf+0x3c>
    80000546:	a481                	j	80000786 <printf+0x2c4>
      consputc(cx);
    80000548:	cf9ff0ef          	jal	80000240 <consputc>
      continue;
    8000054c:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054e:	0014899b          	addiw	s3,s1,1
    80000552:	013a07b3          	add	a5,s4,s3
    80000556:	0007c503          	lbu	a0,0(a5)
    8000055a:	1e050b63          	beqz	a0,80000750 <printf+0x28e>
    if(cx != '%'){
    8000055e:	ff5515e3          	bne	a0,s5,80000548 <printf+0x86>
    i++;
    80000562:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000566:	009a07b3          	add	a5,s4,s1
    8000056a:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000056e:	1e090163          	beqz	s2,80000750 <printf+0x28e>
    80000572:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000576:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000578:	c789                	beqz	a5,80000582 <printf+0xc0>
    8000057a:	009a0733          	add	a4,s4,s1
    8000057e:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000582:	03690763          	beq	s2,s6,800005b0 <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80000586:	05890163          	beq	s2,s8,800005c8 <printf+0x106>
    } else if(c0 == 'u'){
    8000058a:	0d990b63          	beq	s2,s9,80000660 <printf+0x19e>
    } else if(c0 == 'x'){
    8000058e:	13a90163          	beq	s2,s10,800006b0 <printf+0x1ee>
    } else if(c0 == 'p'){
    80000592:	13b90b63          	beq	s2,s11,800006c8 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80000596:	07300793          	li	a5,115
    8000059a:	16f90a63          	beq	s2,a5,8000070e <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000059e:	1b590463          	beq	s2,s5,80000746 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005a2:	8556                	mv	a0,s5
    800005a4:	c9dff0ef          	jal	80000240 <consputc>
      consputc(c0);
    800005a8:	854a                	mv	a0,s2
    800005aa:	c97ff0ef          	jal	80000240 <consputc>
    800005ae:	b745                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005b0:	f8843783          	ld	a5,-120(s0)
    800005b4:	00878713          	addi	a4,a5,8
    800005b8:	f8e43423          	sd	a4,-120(s0)
    800005bc:	4605                	li	a2,1
    800005be:	45a9                	li	a1,10
    800005c0:	4388                	lw	a0,0(a5)
    800005c2:	e6fff0ef          	jal	80000430 <printint>
    800005c6:	b761                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c8:	03678663          	beq	a5,s6,800005f4 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005cc:	05878263          	beq	a5,s8,80000610 <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005d0:	0b978463          	beq	a5,s9,80000678 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	fda797e3          	bne	a5,s10,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	addi	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	4601                	li	a2,0
    800005e6:	45c1                	li	a1,16
    800005e8:	6388                	ld	a0,0(a5)
    800005ea:	e47ff0ef          	jal	80000430 <printint>
      i += 1;
    800005ee:	0029849b          	addiw	s1,s3,2
    800005f2:	bfb1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005f4:	f8843783          	ld	a5,-120(s0)
    800005f8:	00878713          	addi	a4,a5,8
    800005fc:	f8e43423          	sd	a4,-120(s0)
    80000600:	4605                	li	a2,1
    80000602:	45a9                	li	a1,10
    80000604:	6388                	ld	a0,0(a5)
    80000606:	e2bff0ef          	jal	80000430 <printint>
      i += 1;
    8000060a:	0029849b          	addiw	s1,s3,2
    8000060e:	b781                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000610:	06400793          	li	a5,100
    80000614:	02f68863          	beq	a3,a5,80000644 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000618:	07500793          	li	a5,117
    8000061c:	06f68c63          	beq	a3,a5,80000694 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000620:	07800793          	li	a5,120
    80000624:	f6f69fe3          	bne	a3,a5,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4601                	li	a2,0
    80000636:	45c1                	li	a1,16
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	80000430 <printint>
      i += 2;
    8000063e:	0039849b          	addiw	s1,s3,3
    80000642:	b731                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	45a9                	li	a1,10
    80000654:	6388                	ld	a0,0(a5)
    80000656:	ddbff0ef          	jal	80000430 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bdc5                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	dbfff0ef          	jal	80000430 <printint>
    80000676:	bde1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4601                	li	a2,0
    80000686:	45a9                	li	a1,10
    80000688:	6388                	ld	a0,0(a5)
    8000068a:	da7ff0ef          	jal	80000430 <printint>
      i += 1;
    8000068e:	0029849b          	addiw	s1,s3,2
    80000692:	bd75                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	d8bff0ef          	jal	80000430 <printint>
      i += 2;
    800006aa:	0039849b          	addiw	s1,s3,3
    800006ae:	b545                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	d6fff0ef          	jal	80000430 <printint>
    800006c6:	b561                	j	8000054e <printf+0x8c>
    800006c8:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006ca:	f8843783          	ld	a5,-120(s0)
    800006ce:	00878713          	addi	a4,a5,8
    800006d2:	f8e43423          	sd	a4,-120(s0)
    800006d6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006da:	03000513          	li	a0,48
    800006de:	b63ff0ef          	jal	80000240 <consputc>
  consputc('x');
    800006e2:	07800513          	li	a0,120
    800006e6:	b5bff0ef          	jal	80000240 <consputc>
    800006ea:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ec:	00007b97          	auipc	s7,0x7
    800006f0:	0e4b8b93          	addi	s7,s7,228 # 800077d0 <digits>
    800006f4:	03c9d793          	srli	a5,s3,0x3c
    800006f8:	97de                	add	a5,a5,s7
    800006fa:	0007c503          	lbu	a0,0(a5)
    800006fe:	b43ff0ef          	jal	80000240 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0992                	slli	s3,s3,0x4
    80000704:	397d                	addiw	s2,s2,-1
    80000706:	fe0917e3          	bnez	s2,800006f4 <printf+0x232>
    8000070a:	6ba6                	ld	s7,72(sp)
    8000070c:	b589                	j	8000054e <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000070e:	f8843783          	ld	a5,-120(s0)
    80000712:	00878713          	addi	a4,a5,8
    80000716:	f8e43423          	sd	a4,-120(s0)
    8000071a:	0007b903          	ld	s2,0(a5)
    8000071e:	00090d63          	beqz	s2,80000738 <printf+0x276>
      for(; *s; s++)
    80000722:	00094503          	lbu	a0,0(s2)
    80000726:	e20504e3          	beqz	a0,8000054e <printf+0x8c>
        consputc(*s);
    8000072a:	b17ff0ef          	jal	80000240 <consputc>
      for(; *s; s++)
    8000072e:	0905                	addi	s2,s2,1
    80000730:	00094503          	lbu	a0,0(s2)
    80000734:	f97d                	bnez	a0,8000072a <printf+0x268>
    80000736:	bd21                	j	8000054e <printf+0x8c>
        s = "(null)";
    80000738:	00007917          	auipc	s2,0x7
    8000073c:	8d090913          	addi	s2,s2,-1840 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000740:	02800513          	li	a0,40
    80000744:	b7dd                	j	8000072a <printf+0x268>
      consputc('%');
    80000746:	02500513          	li	a0,37
    8000074a:	af7ff0ef          	jal	80000240 <consputc>
    8000074e:	b501                	j	8000054e <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    80000750:	f7843783          	ld	a5,-136(s0)
    80000754:	e385                	bnez	a5,80000774 <printf+0x2b2>
    80000756:	74e6                	ld	s1,120(sp)
    80000758:	7946                	ld	s2,112(sp)
    8000075a:	79a6                	ld	s3,104(sp)
    8000075c:	6ae6                	ld	s5,88(sp)
    8000075e:	6b46                	ld	s6,80(sp)
    80000760:	6c06                	ld	s8,64(sp)
    80000762:	7ce2                	ld	s9,56(sp)
    80000764:	7d42                	ld	s10,48(sp)
    80000766:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000768:	4501                	li	a0,0
    8000076a:	60aa                	ld	ra,136(sp)
    8000076c:	640a                	ld	s0,128(sp)
    8000076e:	7a06                	ld	s4,96(sp)
    80000770:	6169                	addi	sp,sp,208
    80000772:	8082                	ret
    80000774:	74e6                	ld	s1,120(sp)
    80000776:	7946                	ld	s2,112(sp)
    80000778:	79a6                	ld	s3,104(sp)
    8000077a:	6ae6                	ld	s5,88(sp)
    8000077c:	6b46                	ld	s6,80(sp)
    8000077e:	6c06                	ld	s8,64(sp)
    80000780:	7ce2                	ld	s9,56(sp)
    80000782:	7d42                	ld	s10,48(sp)
    80000784:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000786:	0000f517          	auipc	a0,0xf
    8000078a:	2a250513          	addi	a0,a0,674 # 8000fa28 <pr>
    8000078e:	4fe000ef          	jal	80000c8c <release>
    80000792:	bfd9                	j	80000768 <printf+0x2a6>

0000000080000794 <panic>:

void
panic(char *s)
{
    80000794:	1101                	addi	sp,sp,-32
    80000796:	ec06                	sd	ra,24(sp)
    80000798:	e822                	sd	s0,16(sp)
    8000079a:	e426                	sd	s1,8(sp)
    8000079c:	1000                	addi	s0,sp,32
    8000079e:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007a0:	0000f797          	auipc	a5,0xf
    800007a4:	2a07a023          	sw	zero,672(a5) # 8000fa40 <pr+0x18>
  printf("panic: ");
    800007a8:	00007517          	auipc	a0,0x7
    800007ac:	87050513          	addi	a0,a0,-1936 # 80007018 <etext+0x18>
    800007b0:	d13ff0ef          	jal	800004c2 <printf>
  printf("%s\n", s);
    800007b4:	85a6                	mv	a1,s1
    800007b6:	00007517          	auipc	a0,0x7
    800007ba:	86a50513          	addi	a0,a0,-1942 # 80007020 <etext+0x20>
    800007be:	d05ff0ef          	jal	800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007c2:	4785                	li	a5,1
    800007c4:	00007717          	auipc	a4,0x7
    800007c8:	16f72e23          	sw	a5,380(a4) # 80007940 <panicked>
  for(;;)
    800007cc:	a001                	j	800007cc <panic+0x38>

00000000800007ce <printfinit>:
    ;
}

void
printfinit(void)
{
    800007ce:	1101                	addi	sp,sp,-32
    800007d0:	ec06                	sd	ra,24(sp)
    800007d2:	e822                	sd	s0,16(sp)
    800007d4:	e426                	sd	s1,8(sp)
    800007d6:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007d8:	0000f497          	auipc	s1,0xf
    800007dc:	25048493          	addi	s1,s1,592 # 8000fa28 <pr>
    800007e0:	00007597          	auipc	a1,0x7
    800007e4:	84858593          	addi	a1,a1,-1976 # 80007028 <etext+0x28>
    800007e8:	8526                	mv	a0,s1
    800007ea:	38a000ef          	jal	80000b74 <initlock>
  pr.locking = 1;
    800007ee:	4785                	li	a5,1
    800007f0:	cc9c                	sw	a5,24(s1)
}
    800007f2:	60e2                	ld	ra,24(sp)
    800007f4:	6442                	ld	s0,16(sp)
    800007f6:	64a2                	ld	s1,8(sp)
    800007f8:	6105                	addi	sp,sp,32
    800007fa:	8082                	ret

00000000800007fc <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007fc:	1141                	addi	sp,sp,-16
    800007fe:	e406                	sd	ra,8(sp)
    80000800:	e022                	sd	s0,0(sp)
    80000802:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000804:	100007b7          	lui	a5,0x10000
    80000808:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	f8000693          	li	a3,-128
    80000814:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000818:	468d                	li	a3,3
    8000081a:	10000637          	lui	a2,0x10000
    8000081e:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000822:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000826:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000082a:	10000737          	lui	a4,0x10000
    8000082e:	461d                	li	a2,7
    80000830:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000834:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000838:	00006597          	auipc	a1,0x6
    8000083c:	7f858593          	addi	a1,a1,2040 # 80007030 <etext+0x30>
    80000840:	0000f517          	auipc	a0,0xf
    80000844:	20850513          	addi	a0,a0,520 # 8000fa48 <uart_tx_lock>
    80000848:	32c000ef          	jal	80000b74 <initlock>
}
    8000084c:	60a2                	ld	ra,8(sp)
    8000084e:	6402                	ld	s0,0(sp)
    80000850:	0141                	addi	sp,sp,16
    80000852:	8082                	ret

0000000080000854 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	1000                	addi	s0,sp,32
    8000085e:	84aa                	mv	s1,a0
  push_off();
    80000860:	354000ef          	jal	80000bb4 <push_off>

  if(panicked){
    80000864:	00007797          	auipc	a5,0x7
    80000868:	0dc7a783          	lw	a5,220(a5) # 80007940 <panicked>
    8000086c:	e795                	bnez	a5,80000898 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000874:	00074783          	lbu	a5,0(a4)
    80000878:	0207f793          	andi	a5,a5,32
    8000087c:	dfe5                	beqz	a5,80000874 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000087e:	0ff4f513          	zext.b	a0,s1
    80000882:	100007b7          	lui	a5,0x10000
    80000886:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088a:	3ae000ef          	jal	80000c38 <pop_off>
}
    8000088e:	60e2                	ld	ra,24(sp)
    80000890:	6442                	ld	s0,16(sp)
    80000892:	64a2                	ld	s1,8(sp)
    80000894:	6105                	addi	sp,sp,32
    80000896:	8082                	ret
    for(;;)
    80000898:	a001                	j	80000898 <uartputc_sync+0x44>

000000008000089a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000089a:	00007797          	auipc	a5,0x7
    8000089e:	0ae7b783          	ld	a5,174(a5) # 80007948 <uart_tx_r>
    800008a2:	00007717          	auipc	a4,0x7
    800008a6:	0ae73703          	ld	a4,174(a4) # 80007950 <uart_tx_w>
    800008aa:	08f70263          	beq	a4,a5,8000092e <uartstart+0x94>
{
    800008ae:	7139                	addi	sp,sp,-64
    800008b0:	fc06                	sd	ra,56(sp)
    800008b2:	f822                	sd	s0,48(sp)
    800008b4:	f426                	sd	s1,40(sp)
    800008b6:	f04a                	sd	s2,32(sp)
    800008b8:	ec4e                	sd	s3,24(sp)
    800008ba:	e852                	sd	s4,16(sp)
    800008bc:	e456                	sd	s5,8(sp)
    800008be:	e05a                	sd	s6,0(sp)
    800008c0:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c2:	10000937          	lui	s2,0x10000
    800008c6:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008c8:	0000fa97          	auipc	s5,0xf
    800008cc:	180a8a93          	addi	s5,s5,384 # 8000fa48 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	00007497          	auipc	s1,0x7
    800008d4:	07848493          	addi	s1,s1,120 # 80007948 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	00007997          	auipc	s3,0x7
    800008e0:	07498993          	addi	s3,s3,116 # 80007950 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008e4:	00094703          	lbu	a4,0(s2)
    800008e8:	02077713          	andi	a4,a4,32
    800008ec:	c71d                	beqz	a4,8000091a <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ee:	01f7f713          	andi	a4,a5,31
    800008f2:	9756                	add	a4,a4,s5
    800008f4:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008f8:	0785                	addi	a5,a5,1
    800008fa:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008fc:	8526                	mv	a0,s1
    800008fe:	5fc010ef          	jal	80001efa <wakeup>
    WriteReg(THR, c);
    80000902:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000906:	609c                	ld	a5,0(s1)
    80000908:	0009b703          	ld	a4,0(s3)
    8000090c:	fcf71ce3          	bne	a4,a5,800008e4 <uartstart+0x4a>
      ReadReg(ISR);
    80000910:	100007b7          	lui	a5,0x10000
    80000914:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000916:	0007c783          	lbu	a5,0(a5)
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
      ReadReg(ISR);
    8000092e:	100007b7          	lui	a5,0x10000
    80000932:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000934:	0007c783          	lbu	a5,0(a5)
      return;
    80000938:	8082                	ret

000000008000093a <uartputc>:
{
    8000093a:	7179                	addi	sp,sp,-48
    8000093c:	f406                	sd	ra,40(sp)
    8000093e:	f022                	sd	s0,32(sp)
    80000940:	ec26                	sd	s1,24(sp)
    80000942:	e84a                	sd	s2,16(sp)
    80000944:	e44e                	sd	s3,8(sp)
    80000946:	e052                	sd	s4,0(sp)
    80000948:	1800                	addi	s0,sp,48
    8000094a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000094c:	0000f517          	auipc	a0,0xf
    80000950:	0fc50513          	addi	a0,a0,252 # 8000fa48 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	00007797          	auipc	a5,0x7
    8000095c:	fe87a783          	lw	a5,-24(a5) # 80007940 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	00007717          	auipc	a4,0x7
    80000966:	fee73703          	ld	a4,-18(a4) # 80007950 <uart_tx_w>
    8000096a:	00007797          	auipc	a5,0x7
    8000096e:	fde7b783          	ld	a5,-34(a5) # 80007948 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	0000f997          	auipc	s3,0xf
    8000097a:	0d298993          	addi	s3,s3,210 # 8000fa48 <uart_tx_lock>
    8000097e:	00007497          	auipc	s1,0x7
    80000982:	fca48493          	addi	s1,s1,-54 # 80007948 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00007917          	auipc	s2,0x7
    8000098a:	fca90913          	addi	s2,s2,-54 # 80007950 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	518010ef          	jal	80001eae <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	0000f497          	auipc	s1,0xf
    800009ac:	0a048493          	addi	s1,s1,160 # 8000fa48 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	00007797          	auipc	a5,0x7
    800009c0:	f8e7ba23          	sd	a4,-108(a5) # 80007950 <uart_tx_w>
  uartstart();
    800009c4:	ed7ff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    800009c8:	8526                	mv	a0,s1
    800009ca:	2c2000ef          	jal	80000c8c <release>
}
    800009ce:	70a2                	ld	ra,40(sp)
    800009d0:	7402                	ld	s0,32(sp)
    800009d2:	64e2                	ld	s1,24(sp)
    800009d4:	6942                	ld	s2,16(sp)
    800009d6:	69a2                	ld	s3,8(sp)
    800009d8:	6a02                	ld	s4,0(sp)
    800009da:	6145                	addi	sp,sp,48
    800009dc:	8082                	ret
    for(;;)
    800009de:	a001                	j	800009de <uartputc+0xa4>

00000000800009e0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e0:	1141                	addi	sp,sp,-16
    800009e2:	e422                	sd	s0,8(sp)
    800009e4:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e6:	100007b7          	lui	a5,0x10000
    800009ea:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009ec:	0007c783          	lbu	a5,0(a5)
    800009f0:	8b85                	andi	a5,a5,1
    800009f2:	cb81                	beqz	a5,80000a02 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009f4:	100007b7          	lui	a5,0x10000
    800009f8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009fc:	6422                	ld	s0,8(sp)
    800009fe:	0141                	addi	sp,sp,16
    80000a00:	8082                	ret
    return -1;
    80000a02:	557d                	li	a0,-1
    80000a04:	bfe5                	j	800009fc <uartgetc+0x1c>

0000000080000a06 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a06:	1101                	addi	sp,sp,-32
    80000a08:	ec06                	sd	ra,24(sp)
    80000a0a:	e822                	sd	s0,16(sp)
    80000a0c:	e426                	sd	s1,8(sp)
    80000a0e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a10:	54fd                	li	s1,-1
    80000a12:	a019                	j	80000a18 <uartintr+0x12>
      break;
    consoleintr(c);
    80000a14:	85fff0ef          	jal	80000272 <consoleintr>
    int c = uartgetc();
    80000a18:	fc9ff0ef          	jal	800009e0 <uartgetc>
    if(c == -1)
    80000a1c:	fe951ce3          	bne	a0,s1,80000a14 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a20:	0000f497          	auipc	s1,0xf
    80000a24:	02848493          	addi	s1,s1,40 # 8000fa48 <uart_tx_lock>
    80000a28:	8526                	mv	a0,s1
    80000a2a:	1ca000ef          	jal	80000bf4 <acquire>
  uartstart();
    80000a2e:	e6dff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    80000a32:	8526                	mv	a0,s1
    80000a34:	258000ef          	jal	80000c8c <release>
}
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret

0000000080000a42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a42:	1101                	addi	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	e04a                	sd	s2,0(sp)
    80000a4c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	e7a9                	bnez	a5,80000a9c <kfree+0x5a>
    80000a54:	84aa                	mv	s1,a0
    80000a56:	00020797          	auipc	a5,0x20
    80000a5a:	25a78793          	addi	a5,a5,602 # 80020cb0 <end>
    80000a5e:	02f56f63          	bltu	a0,a5,80000a9c <kfree+0x5a>
    80000a62:	47c5                	li	a5,17
    80000a64:	07ee                	slli	a5,a5,0x1b
    80000a66:	02f57b63          	bgeu	a0,a5,80000a9c <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a6a:	6605                	lui	a2,0x1
    80000a6c:	4585                	li	a1,1
    80000a6e:	25a000ef          	jal	80000cc8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a72:	0000f917          	auipc	s2,0xf
    80000a76:	00e90913          	addi	s2,s2,14 # 8000fa80 <kmem>
    80000a7a:	854a                	mv	a0,s2
    80000a7c:	178000ef          	jal	80000bf4 <acquire>
  r->next = kmem.freelist;
    80000a80:	01893783          	ld	a5,24(s2)
    80000a84:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a86:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	200000ef          	jal	80000c8c <release>
}
    80000a90:	60e2                	ld	ra,24(sp)
    80000a92:	6442                	ld	s0,16(sp)
    80000a94:	64a2                	ld	s1,8(sp)
    80000a96:	6902                	ld	s2,0(sp)
    80000a98:	6105                	addi	sp,sp,32
    80000a9a:	8082                	ret
    panic("kfree");
    80000a9c:	00006517          	auipc	a0,0x6
    80000aa0:	59c50513          	addi	a0,a0,1436 # 80007038 <etext+0x38>
    80000aa4:	cf1ff0ef          	jal	80000794 <panic>

0000000080000aa8 <freerange>:
{
    80000aa8:	7179                	addi	sp,sp,-48
    80000aaa:	f406                	sd	ra,40(sp)
    80000aac:	f022                	sd	s0,32(sp)
    80000aae:	ec26                	sd	s1,24(sp)
    80000ab0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab2:	6785                	lui	a5,0x1
    80000ab4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ab8:	00e504b3          	add	s1,a0,a4
    80000abc:	777d                	lui	a4,0xfffff
    80000abe:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	94be                	add	s1,s1,a5
    80000ac2:	0295e263          	bltu	a1,s1,80000ae6 <freerange+0x3e>
    80000ac6:	e84a                	sd	s2,16(sp)
    80000ac8:	e44e                	sd	s3,8(sp)
    80000aca:	e052                	sd	s4,0(sp)
    80000acc:	892e                	mv	s2,a1
    kfree(p);
    80000ace:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad0:	6985                	lui	s3,0x1
    kfree(p);
    80000ad2:	01448533          	add	a0,s1,s4
    80000ad6:	f6dff0ef          	jal	80000a42 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ada:	94ce                	add	s1,s1,s3
    80000adc:	fe997be3          	bgeu	s2,s1,80000ad2 <freerange+0x2a>
    80000ae0:	6942                	ld	s2,16(sp)
    80000ae2:	69a2                	ld	s3,8(sp)
    80000ae4:	6a02                	ld	s4,0(sp)
}
    80000ae6:	70a2                	ld	ra,40(sp)
    80000ae8:	7402                	ld	s0,32(sp)
    80000aea:	64e2                	ld	s1,24(sp)
    80000aec:	6145                	addi	sp,sp,48
    80000aee:	8082                	ret

0000000080000af0 <kinit>:
{
    80000af0:	1141                	addi	sp,sp,-16
    80000af2:	e406                	sd	ra,8(sp)
    80000af4:	e022                	sd	s0,0(sp)
    80000af6:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000af8:	00006597          	auipc	a1,0x6
    80000afc:	54858593          	addi	a1,a1,1352 # 80007040 <etext+0x40>
    80000b00:	0000f517          	auipc	a0,0xf
    80000b04:	f8050513          	addi	a0,a0,-128 # 8000fa80 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00020517          	auipc	a0,0x20
    80000b14:	1a050513          	addi	a0,a0,416 # 80020cb0 <end>
    80000b18:	f91ff0ef          	jal	80000aa8 <freerange>
}
    80000b1c:	60a2                	ld	ra,8(sp)
    80000b1e:	6402                	ld	s0,0(sp)
    80000b20:	0141                	addi	sp,sp,16
    80000b22:	8082                	ret

0000000080000b24 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b24:	1101                	addi	sp,sp,-32
    80000b26:	ec06                	sd	ra,24(sp)
    80000b28:	e822                	sd	s0,16(sp)
    80000b2a:	e426                	sd	s1,8(sp)
    80000b2c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2e:	0000f497          	auipc	s1,0xf
    80000b32:	f5248493          	addi	s1,s1,-174 # 8000fa80 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	0000f517          	auipc	a0,0xf
    80000b46:	f3e50513          	addi	a0,a0,-194 # 8000fa80 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	140000ef          	jal	80000c8c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	172000ef          	jal	80000cc8 <memset>
  return (void*)r;
}
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	60e2                	ld	ra,24(sp)
    80000b5e:	6442                	ld	s0,16(sp)
    80000b60:	64a2                	ld	s1,8(sp)
    80000b62:	6105                	addi	sp,sp,32
    80000b64:	8082                	ret
  release(&kmem.lock);
    80000b66:	0000f517          	auipc	a0,0xf
    80000b6a:	f1a50513          	addi	a0,a0,-230 # 8000fa80 <kmem>
    80000b6e:	11e000ef          	jal	80000c8c <release>
  if(r)
    80000b72:	b7e5                	j	80000b5a <kalloc+0x36>

0000000080000b74 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b74:	1141                	addi	sp,sp,-16
    80000b76:	e422                	sd	s0,8(sp)
    80000b78:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b7a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b7c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b80:	00053823          	sd	zero,16(a0)
}
    80000b84:	6422                	ld	s0,8(sp)
    80000b86:	0141                	addi	sp,sp,16
    80000b88:	8082                	ret

0000000080000b8a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b8a:	411c                	lw	a5,0(a0)
    80000b8c:	e399                	bnez	a5,80000b92 <holding+0x8>
    80000b8e:	4501                	li	a0,0
  return r;
}
    80000b90:	8082                	ret
{
    80000b92:	1101                	addi	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b9c:	6904                	ld	s1,16(a0)
    80000b9e:	527000ef          	jal	800018c4 <mycpu>
    80000ba2:	40a48533          	sub	a0,s1,a0
    80000ba6:	00153513          	seqz	a0,a0
}
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret

0000000080000bb4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bb4:	1101                	addi	sp,sp,-32
    80000bb6:	ec06                	sd	ra,24(sp)
    80000bb8:	e822                	sd	s0,16(sp)
    80000bba:	e426                	sd	s1,8(sp)
    80000bbc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbe:	100024f3          	csrr	s1,sstatus
    80000bc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bcc:	4f9000ef          	jal	800018c4 <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	4f1000ef          	jal	800018c4 <mycpu>
    80000bd8:	5d3c                	lw	a5,120(a0)
    80000bda:	2785                	addiw	a5,a5,1
    80000bdc:	dd3c                	sw	a5,120(a0)
}
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret
    mycpu()->intena = old;
    80000be8:	4dd000ef          	jal	800018c4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bec:	8085                	srli	s1,s1,0x1
    80000bee:	8885                	andi	s1,s1,1
    80000bf0:	dd64                	sw	s1,124(a0)
    80000bf2:	b7cd                	j	80000bd4 <push_off+0x20>

0000000080000bf4 <acquire>:
{
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
    80000bfe:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c00:	fb5ff0ef          	jal	80000bb4 <push_off>
  if(holding(lk))
    80000c04:	8526                	mv	a0,s1
    80000c06:	f85ff0ef          	jal	80000b8a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0a:	4705                	li	a4,1
  if(holding(lk))
    80000c0c:	e105                	bnez	a0,80000c2c <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0e:	87ba                	mv	a5,a4
    80000c10:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c14:	2781                	sext.w	a5,a5
    80000c16:	ffe5                	bnez	a5,80000c0e <acquire+0x1a>
  __sync_synchronize();
    80000c18:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c1c:	4a9000ef          	jal	800018c4 <mycpu>
    80000c20:	e888                	sd	a0,16(s1)
}
    80000c22:	60e2                	ld	ra,24(sp)
    80000c24:	6442                	ld	s0,16(sp)
    80000c26:	64a2                	ld	s1,8(sp)
    80000c28:	6105                	addi	sp,sp,32
    80000c2a:	8082                	ret
    panic("acquire");
    80000c2c:	00006517          	auipc	a0,0x6
    80000c30:	41c50513          	addi	a0,a0,1052 # 80007048 <etext+0x48>
    80000c34:	b61ff0ef          	jal	80000794 <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	485000ef          	jal	800018c4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c44:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c48:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4a:	e78d                	bnez	a5,80000c74 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c4c:	5d3c                	lw	a5,120(a0)
    80000c4e:	02f05963          	blez	a5,80000c80 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c52:	37fd                	addiw	a5,a5,-1
    80000c54:	0007871b          	sext.w	a4,a5
    80000c58:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5a:	eb09                	bnez	a4,80000c6c <pop_off+0x34>
    80000c5c:	5d7c                	lw	a5,124(a0)
    80000c5e:	c799                	beqz	a5,80000c6c <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c68:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c6c:	60a2                	ld	ra,8(sp)
    80000c6e:	6402                	ld	s0,0(sp)
    80000c70:	0141                	addi	sp,sp,16
    80000c72:	8082                	ret
    panic("pop_off - interruptible");
    80000c74:	00006517          	auipc	a0,0x6
    80000c78:	3dc50513          	addi	a0,a0,988 # 80007050 <etext+0x50>
    80000c7c:	b19ff0ef          	jal	80000794 <panic>
    panic("pop_off");
    80000c80:	00006517          	auipc	a0,0x6
    80000c84:	3e850513          	addi	a0,a0,1000 # 80007068 <etext+0x68>
    80000c88:	b0dff0ef          	jal	80000794 <panic>

0000000080000c8c <release>:
{
    80000c8c:	1101                	addi	sp,sp,-32
    80000c8e:	ec06                	sd	ra,24(sp)
    80000c90:	e822                	sd	s0,16(sp)
    80000c92:	e426                	sd	s1,8(sp)
    80000c94:	1000                	addi	s0,sp,32
    80000c96:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c98:	ef3ff0ef          	jal	80000b8a <holding>
    80000c9c:	c105                	beqz	a0,80000cbc <release+0x30>
  lk->cpu = 0;
    80000c9e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca6:	0f50000f          	fence	iorw,ow
    80000caa:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cae:	f8bff0ef          	jal	80000c38 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00006517          	auipc	a0,0x6
    80000cc0:	3b450513          	addi	a0,a0,948 # 80007070 <etext+0x70>
    80000cc4:	ad1ff0ef          	jal	80000794 <panic>

0000000080000cc8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cc8:	1141                	addi	sp,sp,-16
    80000cca:	e422                	sd	s0,8(sp)
    80000ccc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cce:	ca19                	beqz	a2,80000ce4 <memset+0x1c>
    80000cd0:	87aa                	mv	a5,a0
    80000cd2:	1602                	slli	a2,a2,0x20
    80000cd4:	9201                	srli	a2,a2,0x20
    80000cd6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cda:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cde:	0785                	addi	a5,a5,1
    80000ce0:	fee79de3          	bne	a5,a4,80000cda <memset+0x12>
  }
  return dst;
}
    80000ce4:	6422                	ld	s0,8(sp)
    80000ce6:	0141                	addi	sp,sp,16
    80000ce8:	8082                	ret

0000000080000cea <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cea:	1141                	addi	sp,sp,-16
    80000cec:	e422                	sd	s0,8(sp)
    80000cee:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf0:	ca05                	beqz	a2,80000d20 <memcmp+0x36>
    80000cf2:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf6:	1682                	slli	a3,a3,0x20
    80000cf8:	9281                	srli	a3,a3,0x20
    80000cfa:	0685                	addi	a3,a3,1
    80000cfc:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cfe:	00054783          	lbu	a5,0(a0)
    80000d02:	0005c703          	lbu	a4,0(a1)
    80000d06:	00e79863          	bne	a5,a4,80000d16 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0a:	0505                	addi	a0,a0,1
    80000d0c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d0e:	fed518e3          	bne	a0,a3,80000cfe <memcmp+0x14>
  }

  return 0;
    80000d12:	4501                	li	a0,0
    80000d14:	a019                	j	80000d1a <memcmp+0x30>
      return *s1 - *s2;
    80000d16:	40e7853b          	subw	a0,a5,a4
}
    80000d1a:	6422                	ld	s0,8(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret
  return 0;
    80000d20:	4501                	li	a0,0
    80000d22:	bfe5                	j	80000d1a <memcmp+0x30>

0000000080000d24 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d24:	1141                	addi	sp,sp,-16
    80000d26:	e422                	sd	s0,8(sp)
    80000d28:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2a:	c205                	beqz	a2,80000d4a <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d2c:	02a5e263          	bltu	a1,a0,80000d50 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d30:	1602                	slli	a2,a2,0x20
    80000d32:	9201                	srli	a2,a2,0x20
    80000d34:	00c587b3          	add	a5,a1,a2
{
    80000d38:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3a:	0585                	addi	a1,a1,1
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde351>
    80000d3e:	fff5c683          	lbu	a3,-1(a1)
    80000d42:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d46:	feb79ae3          	bne	a5,a1,80000d3a <memmove+0x16>

  return dst;
}
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	addi	sp,sp,16
    80000d4e:	8082                	ret
  if(s < d && s + n > d){
    80000d50:	02061693          	slli	a3,a2,0x20
    80000d54:	9281                	srli	a3,a3,0x20
    80000d56:	00d58733          	add	a4,a1,a3
    80000d5a:	fce57be3          	bgeu	a0,a4,80000d30 <memmove+0xc>
    d += n;
    80000d5e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	fff7c793          	not	a5,a5
    80000d6c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	16fd                	addi	a3,a3,-1
    80000d72:	00074603          	lbu	a2,0(a4)
    80000d76:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7a:	fef71ae3          	bne	a4,a5,80000d6e <memmove+0x4a>
    80000d7e:	b7f1                	j	80000d4a <memmove+0x26>

0000000080000d80 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d80:	1141                	addi	sp,sp,-16
    80000d82:	e406                	sd	ra,8(sp)
    80000d84:	e022                	sd	s0,0(sp)
    80000d86:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d88:	f9dff0ef          	jal	80000d24 <memmove>
}
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	addi	sp,sp,16
    80000d92:	8082                	ret

0000000080000d94 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d94:	1141                	addi	sp,sp,-16
    80000d96:	e422                	sd	s0,8(sp)
    80000d98:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9a:	ce11                	beqz	a2,80000db6 <strncmp+0x22>
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	cf89                	beqz	a5,80000dba <strncmp+0x26>
    80000da2:	0005c703          	lbu	a4,0(a1)
    80000da6:	00f71a63          	bne	a4,a5,80000dba <strncmp+0x26>
    n--, p++, q++;
    80000daa:	367d                	addiw	a2,a2,-1
    80000dac:	0505                	addi	a0,a0,1
    80000dae:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db0:	f675                	bnez	a2,80000d9c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db2:	4501                	li	a0,0
    80000db4:	a801                	j	80000dc4 <strncmp+0x30>
    80000db6:	4501                	li	a0,0
    80000db8:	a031                	j	80000dc4 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000dba:	00054503          	lbu	a0,0(a0)
    80000dbe:	0005c783          	lbu	a5,0(a1)
    80000dc2:	9d1d                	subw	a0,a0,a5
}
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd0:	87aa                	mv	a5,a0
    80000dd2:	86b2                	mv	a3,a2
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	02d05563          	blez	a3,80000e00 <strncpy+0x36>
    80000dda:	0785                	addi	a5,a5,1
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	fee78fa3          	sb	a4,-1(a5)
    80000de4:	0585                	addi	a1,a1,1
    80000de6:	f775                	bnez	a4,80000dd2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000de8:	873e                	mv	a4,a5
    80000dea:	9fb5                	addw	a5,a5,a3
    80000dec:	37fd                	addiw	a5,a5,-1
    80000dee:	00c05963          	blez	a2,80000e00 <strncpy+0x36>
    *s++ = 0;
    80000df2:	0705                	addi	a4,a4,1
    80000df4:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000df8:	40e786bb          	subw	a3,a5,a4
    80000dfc:	fed04be3          	bgtz	a3,80000df2 <strncpy+0x28>
  return os;
}
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e0c:	02c05363          	blez	a2,80000e32 <safestrcpy+0x2c>
    80000e10:	fff6069b          	addiw	a3,a2,-1
    80000e14:	1682                	slli	a3,a3,0x20
    80000e16:	9281                	srli	a3,a3,0x20
    80000e18:	96ae                	add	a3,a3,a1
    80000e1a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e1c:	00d58963          	beq	a1,a3,80000e2e <safestrcpy+0x28>
    80000e20:	0585                	addi	a1,a1,1
    80000e22:	0785                	addi	a5,a5,1
    80000e24:	fff5c703          	lbu	a4,-1(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	fb65                	bnez	a4,80000e1c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e2e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strlen>:

int
strlen(const char *s)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e3e:	00054783          	lbu	a5,0(a0)
    80000e42:	cf91                	beqz	a5,80000e5e <strlen+0x26>
    80000e44:	0505                	addi	a0,a0,1
    80000e46:	87aa                	mv	a5,a0
    80000e48:	86be                	mv	a3,a5
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	fff7c703          	lbu	a4,-1(a5)
    80000e50:	ff65                	bnez	a4,80000e48 <strlen+0x10>
    80000e52:	40a6853b          	subw	a0,a3,a0
    80000e56:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <strlen+0x20>

0000000080000e62 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e6a:	24b000ef          	jal	800018b4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e6e:	00007717          	auipc	a4,0x7
    80000e72:	aea70713          	addi	a4,a4,-1302 # 80007958 <started>
  if(cpuid() == 0){
    80000e76:	c51d                	beqz	a0,80000ea4 <main+0x42>
    while(started == 0)
    80000e78:	431c                	lw	a5,0(a4)
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dff5                	beqz	a5,80000e78 <main+0x16>
      ;
    __sync_synchronize();
    80000e7e:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e82:	233000ef          	jal	800018b4 <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	21050513          	addi	a0,a0,528 # 80007098 <etext+0x98>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000e94:	080000ef          	jal	80000f14 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e98:	538010ef          	jal	800023d0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	3dc040ef          	jal	80005278 <plicinithart>
  }

  scheduler();        
    80000ea0:	675000ef          	jal	80001d14 <scheduler>
    consoleinit();
    80000ea4:	d48ff0ef          	jal	800003ec <consoleinit>
    printfinit();
    80000ea8:	927ff0ef          	jal	800007ce <printfinit>
    printf("\n");
    80000eac:	00006517          	auipc	a0,0x6
    80000eb0:	1cc50513          	addi	a0,a0,460 # 80007078 <etext+0x78>
    80000eb4:	e0eff0ef          	jal	800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000eb8:	00006517          	auipc	a0,0x6
    80000ebc:	1c850513          	addi	a0,a0,456 # 80007080 <etext+0x80>
    80000ec0:	e02ff0ef          	jal	800004c2 <printf>
    printf("\n");
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1b450513          	addi	a0,a0,436 # 80007078 <etext+0x78>
    80000ecc:	df6ff0ef          	jal	800004c2 <printf>
    kinit();         // physical page allocator
    80000ed0:	c21ff0ef          	jal	80000af0 <kinit>
    kvminit();       // create kernel page table
    80000ed4:	2ca000ef          	jal	8000119e <kvminit>
    kvminithart();   // turn on paging
    80000ed8:	03c000ef          	jal	80000f14 <kvminithart>
    procinit();      // process table
    80000edc:	123000ef          	jal	800017fe <procinit>
    trapinit();      // trap vectors
    80000ee0:	4cc010ef          	jal	800023ac <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	4ec010ef          	jal	800023d0 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	376040ef          	jal	8000525e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	38c040ef          	jal	80005278 <plicinithart>
    binit();         // buffer cache
    80000ef0:	333010ef          	jal	80002a22 <binit>
    iinit();         // inode table
    80000ef4:	124020ef          	jal	80003018 <iinit>
    fileinit();      // file table
    80000ef8:	6d1020ef          	jal	80003dc8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	46c040ef          	jal	80005368 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	449000ef          	jal	80001b48 <userinit>
    __sync_synchronize();
    80000f04:	0ff0000f          	fence
    started = 1;
    80000f08:	4785                	li	a5,1
    80000f0a:	00007717          	auipc	a4,0x7
    80000f0e:	a4f72723          	sw	a5,-1458(a4) # 80007958 <started>
    80000f12:	b779                	j	80000ea0 <main+0x3e>

0000000080000f14 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f14:	1141                	addi	sp,sp,-16
    80000f16:	e422                	sd	s0,8(sp)
    80000f18:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f1a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f1e:	00007797          	auipc	a5,0x7
    80000f22:	a427b783          	ld	a5,-1470(a5) # 80007960 <kernel_pagetable>
    80000f26:	83b1                	srli	a5,a5,0xc
    80000f28:	577d                	li	a4,-1
    80000f2a:	177e                	slli	a4,a4,0x3f
    80000f2c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f2e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f32:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret

0000000080000f3c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f3c:	7139                	addi	sp,sp,-64
    80000f3e:	fc06                	sd	ra,56(sp)
    80000f40:	f822                	sd	s0,48(sp)
    80000f42:	f426                	sd	s1,40(sp)
    80000f44:	f04a                	sd	s2,32(sp)
    80000f46:	ec4e                	sd	s3,24(sp)
    80000f48:	e852                	sd	s4,16(sp)
    80000f4a:	e456                	sd	s5,8(sp)
    80000f4c:	e05a                	sd	s6,0(sp)
    80000f4e:	0080                	addi	s0,sp,64
    80000f50:	84aa                	mv	s1,a0
    80000f52:	89ae                	mv	s3,a1
    80000f54:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srli	a5,a5,0x1a
    80000f5a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f5c:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f5e:	02b7fc63          	bgeu	a5,a1,80000f96 <walk+0x5a>
    panic("walk");
    80000f62:	00006517          	auipc	a0,0x6
    80000f66:	14e50513          	addi	a0,a0,334 # 800070b0 <etext+0xb0>
    80000f6a:	82bff0ef          	jal	80000794 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f6e:	060a8263          	beqz	s5,80000fd2 <walk+0x96>
    80000f72:	bb3ff0ef          	jal	80000b24 <kalloc>
    80000f76:	84aa                	mv	s1,a0
    80000f78:	c139                	beqz	a0,80000fbe <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f7a:	6605                	lui	a2,0x1
    80000f7c:	4581                	li	a1,0
    80000f7e:	d4bff0ef          	jal	80000cc8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f82:	00c4d793          	srli	a5,s1,0xc
    80000f86:	07aa                	slli	a5,a5,0xa
    80000f88:	0017e793          	ori	a5,a5,1
    80000f8c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f90:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde347>
    80000f92:	036a0063          	beq	s4,s6,80000fb2 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f96:	0149d933          	srl	s2,s3,s4
    80000f9a:	1ff97913          	andi	s2,s2,511
    80000f9e:	090e                	slli	s2,s2,0x3
    80000fa0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fa2:	00093483          	ld	s1,0(s2)
    80000fa6:	0014f793          	andi	a5,s1,1
    80000faa:	d3f1                	beqz	a5,80000f6e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fac:	80a9                	srli	s1,s1,0xa
    80000fae:	04b2                	slli	s1,s1,0xc
    80000fb0:	b7c5                	j	80000f90 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000fb2:	00c9d513          	srli	a0,s3,0xc
    80000fb6:	1ff57513          	andi	a0,a0,511
    80000fba:	050e                	slli	a0,a0,0x3
    80000fbc:	9526                	add	a0,a0,s1
}
    80000fbe:	70e2                	ld	ra,56(sp)
    80000fc0:	7442                	ld	s0,48(sp)
    80000fc2:	74a2                	ld	s1,40(sp)
    80000fc4:	7902                	ld	s2,32(sp)
    80000fc6:	69e2                	ld	s3,24(sp)
    80000fc8:	6a42                	ld	s4,16(sp)
    80000fca:	6aa2                	ld	s5,8(sp)
    80000fcc:	6b02                	ld	s6,0(sp)
    80000fce:	6121                	addi	sp,sp,64
    80000fd0:	8082                	ret
        return 0;
    80000fd2:	4501                	li	a0,0
    80000fd4:	b7ed                	j	80000fbe <walk+0x82>

0000000080000fd6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fd6:	57fd                	li	a5,-1
    80000fd8:	83e9                	srli	a5,a5,0x1a
    80000fda:	00b7f463          	bgeu	a5,a1,80000fe2 <walkaddr+0xc>
    return 0;
    80000fde:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fe0:	8082                	ret
{
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e406                	sd	ra,8(sp)
    80000fe6:	e022                	sd	s0,0(sp)
    80000fe8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fea:	4601                	li	a2,0
    80000fec:	f51ff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80000ff0:	c105                	beqz	a0,80001010 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000ff2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000ff4:	0117f693          	andi	a3,a5,17
    80000ff8:	4745                	li	a4,17
    return 0;
    80000ffa:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000ffc:	00e68663          	beq	a3,a4,80001008 <walkaddr+0x32>
}
    80001000:	60a2                	ld	ra,8(sp)
    80001002:	6402                	ld	s0,0(sp)
    80001004:	0141                	addi	sp,sp,16
    80001006:	8082                	ret
  pa = PTE2PA(*pte);
    80001008:	83a9                	srli	a5,a5,0xa
    8000100a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000100e:	bfcd                	j	80001000 <walkaddr+0x2a>
    return 0;
    80001010:	4501                	li	a0,0
    80001012:	b7fd                	j	80001000 <walkaddr+0x2a>

0000000080001014 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001014:	715d                	addi	sp,sp,-80
    80001016:	e486                	sd	ra,72(sp)
    80001018:	e0a2                	sd	s0,64(sp)
    8000101a:	fc26                	sd	s1,56(sp)
    8000101c:	f84a                	sd	s2,48(sp)
    8000101e:	f44e                	sd	s3,40(sp)
    80001020:	f052                	sd	s4,32(sp)
    80001022:	ec56                	sd	s5,24(sp)
    80001024:	e85a                	sd	s6,16(sp)
    80001026:	e45e                	sd	s7,8(sp)
    80001028:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000102a:	03459793          	slli	a5,a1,0x34
    8000102e:	e7a9                	bnez	a5,80001078 <mappages+0x64>
    80001030:	8aaa                	mv	s5,a0
    80001032:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001034:	03461793          	slli	a5,a2,0x34
    80001038:	e7b1                	bnez	a5,80001084 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000103a:	ca39                	beqz	a2,80001090 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000103c:	77fd                	lui	a5,0xfffff
    8000103e:	963e                	add	a2,a2,a5
    80001040:	00b609b3          	add	s3,a2,a1
  a = va;
    80001044:	892e                	mv	s2,a1
    80001046:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000104a:	6b85                	lui	s7,0x1
    8000104c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	4605                	li	a2,1
    80001052:	85ca                	mv	a1,s2
    80001054:	8556                	mv	a0,s5
    80001056:	ee7ff0ef          	jal	80000f3c <walk>
    8000105a:	c539                	beqz	a0,800010a8 <mappages+0x94>
    if(*pte & PTE_V)
    8000105c:	611c                	ld	a5,0(a0)
    8000105e:	8b85                	andi	a5,a5,1
    80001060:	ef95                	bnez	a5,8000109c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001062:	80b1                	srli	s1,s1,0xc
    80001064:	04aa                	slli	s1,s1,0xa
    80001066:	0164e4b3          	or	s1,s1,s6
    8000106a:	0014e493          	ori	s1,s1,1
    8000106e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001070:	05390863          	beq	s2,s3,800010c0 <mappages+0xac>
    a += PGSIZE;
    80001074:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001076:	bfd9                	j	8000104c <mappages+0x38>
    panic("mappages: va not aligned");
    80001078:	00006517          	auipc	a0,0x6
    8000107c:	04050513          	addi	a0,a0,64 # 800070b8 <etext+0xb8>
    80001080:	f14ff0ef          	jal	80000794 <panic>
    panic("mappages: size not aligned");
    80001084:	00006517          	auipc	a0,0x6
    80001088:	05450513          	addi	a0,a0,84 # 800070d8 <etext+0xd8>
    8000108c:	f08ff0ef          	jal	80000794 <panic>
    panic("mappages: size");
    80001090:	00006517          	auipc	a0,0x6
    80001094:	06850513          	addi	a0,a0,104 # 800070f8 <etext+0xf8>
    80001098:	efcff0ef          	jal	80000794 <panic>
      panic("mappages: remap");
    8000109c:	00006517          	auipc	a0,0x6
    800010a0:	06c50513          	addi	a0,a0,108 # 80007108 <etext+0x108>
    800010a4:	ef0ff0ef          	jal	80000794 <panic>
      return -1;
    800010a8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010aa:	60a6                	ld	ra,72(sp)
    800010ac:	6406                	ld	s0,64(sp)
    800010ae:	74e2                	ld	s1,56(sp)
    800010b0:	7942                	ld	s2,48(sp)
    800010b2:	79a2                	ld	s3,40(sp)
    800010b4:	7a02                	ld	s4,32(sp)
    800010b6:	6ae2                	ld	s5,24(sp)
    800010b8:	6b42                	ld	s6,16(sp)
    800010ba:	6ba2                	ld	s7,8(sp)
    800010bc:	6161                	addi	sp,sp,80
    800010be:	8082                	ret
  return 0;
    800010c0:	4501                	li	a0,0
    800010c2:	b7e5                	j	800010aa <mappages+0x96>

00000000800010c4 <kvmmap>:
{
    800010c4:	1141                	addi	sp,sp,-16
    800010c6:	e406                	sd	ra,8(sp)
    800010c8:	e022                	sd	s0,0(sp)
    800010ca:	0800                	addi	s0,sp,16
    800010cc:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010ce:	86b2                	mv	a3,a2
    800010d0:	863e                	mv	a2,a5
    800010d2:	f43ff0ef          	jal	80001014 <mappages>
    800010d6:	e509                	bnez	a0,800010e0 <kvmmap+0x1c>
}
    800010d8:	60a2                	ld	ra,8(sp)
    800010da:	6402                	ld	s0,0(sp)
    800010dc:	0141                	addi	sp,sp,16
    800010de:	8082                	ret
    panic("kvmmap");
    800010e0:	00006517          	auipc	a0,0x6
    800010e4:	03850513          	addi	a0,a0,56 # 80007118 <etext+0x118>
    800010e8:	eacff0ef          	jal	80000794 <panic>

00000000800010ec <kvmmake>:
{
    800010ec:	1101                	addi	sp,sp,-32
    800010ee:	ec06                	sd	ra,24(sp)
    800010f0:	e822                	sd	s0,16(sp)
    800010f2:	e426                	sd	s1,8(sp)
    800010f4:	e04a                	sd	s2,0(sp)
    800010f6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010f8:	a2dff0ef          	jal	80000b24 <kalloc>
    800010fc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010fe:	6605                	lui	a2,0x1
    80001100:	4581                	li	a1,0
    80001102:	bc7ff0ef          	jal	80000cc8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001106:	4719                	li	a4,6
    80001108:	6685                	lui	a3,0x1
    8000110a:	10000637          	lui	a2,0x10000
    8000110e:	100005b7          	lui	a1,0x10000
    80001112:	8526                	mv	a0,s1
    80001114:	fb1ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001118:	4719                	li	a4,6
    8000111a:	6685                	lui	a3,0x1
    8000111c:	10001637          	lui	a2,0x10001
    80001120:	100015b7          	lui	a1,0x10001
    80001124:	8526                	mv	a0,s1
    80001126:	f9fff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000112a:	4719                	li	a4,6
    8000112c:	040006b7          	lui	a3,0x4000
    80001130:	0c000637          	lui	a2,0xc000
    80001134:	0c0005b7          	lui	a1,0xc000
    80001138:	8526                	mv	a0,s1
    8000113a:	f8bff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000113e:	00006917          	auipc	s2,0x6
    80001142:	ec290913          	addi	s2,s2,-318 # 80007000 <etext>
    80001146:	4729                	li	a4,10
    80001148:	80006697          	auipc	a3,0x80006
    8000114c:	eb868693          	addi	a3,a3,-328 # 7000 <_entry-0x7fff9000>
    80001150:	4605                	li	a2,1
    80001152:	067e                	slli	a2,a2,0x1f
    80001154:	85b2                	mv	a1,a2
    80001156:	8526                	mv	a0,s1
    80001158:	f6dff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000115c:	46c5                	li	a3,17
    8000115e:	06ee                	slli	a3,a3,0x1b
    80001160:	4719                	li	a4,6
    80001162:	412686b3          	sub	a3,a3,s2
    80001166:	864a                	mv	a2,s2
    80001168:	85ca                	mv	a1,s2
    8000116a:	8526                	mv	a0,s1
    8000116c:	f59ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001170:	4729                	li	a4,10
    80001172:	6685                	lui	a3,0x1
    80001174:	00005617          	auipc	a2,0x5
    80001178:	e8c60613          	addi	a2,a2,-372 # 80006000 <_trampoline>
    8000117c:	040005b7          	lui	a1,0x4000
    80001180:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001182:	05b2                	slli	a1,a1,0xc
    80001184:	8526                	mv	a0,s1
    80001186:	f3fff0ef          	jal	800010c4 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000118a:	8526                	mv	a0,s1
    8000118c:	5da000ef          	jal	80001766 <proc_mapstacks>
}
    80001190:	8526                	mv	a0,s1
    80001192:	60e2                	ld	ra,24(sp)
    80001194:	6442                	ld	s0,16(sp)
    80001196:	64a2                	ld	s1,8(sp)
    80001198:	6902                	ld	s2,0(sp)
    8000119a:	6105                	addi	sp,sp,32
    8000119c:	8082                	ret

000000008000119e <kvminit>:
{
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e406                	sd	ra,8(sp)
    800011a2:	e022                	sd	s0,0(sp)
    800011a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011a6:	f47ff0ef          	jal	800010ec <kvmmake>
    800011aa:	00006797          	auipc	a5,0x6
    800011ae:	7aa7bb23          	sd	a0,1974(a5) # 80007960 <kernel_pagetable>
}
    800011b2:	60a2                	ld	ra,8(sp)
    800011b4:	6402                	ld	s0,0(sp)
    800011b6:	0141                	addi	sp,sp,16
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	715d                	addi	sp,sp,-80
    800011bc:	e486                	sd	ra,72(sp)
    800011be:	e0a2                	sd	s0,64(sp)
    800011c0:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e39d                	bnez	a5,800011ec <uvmunmap+0x32>
    800011c8:	f84a                	sd	s2,48(sp)
    800011ca:	f44e                	sd	s3,40(sp)
    800011cc:	f052                	sd	s4,32(sp)
    800011ce:	ec56                	sd	s5,24(sp)
    800011d0:	e85a                	sd	s6,16(sp)
    800011d2:	e45e                	sd	s7,8(sp)
    800011d4:	8a2a                	mv	s4,a0
    800011d6:	892e                	mv	s2,a1
    800011d8:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011da:	0632                	slli	a2,a2,0xc
    800011dc:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800011e0:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011e2:	6b05                	lui	s6,0x1
    800011e4:	0735ff63          	bgeu	a1,s3,80001262 <uvmunmap+0xa8>
    800011e8:	fc26                	sd	s1,56(sp)
    800011ea:	a0a9                	j	80001234 <uvmunmap+0x7a>
    800011ec:	fc26                	sd	s1,56(sp)
    800011ee:	f84a                	sd	s2,48(sp)
    800011f0:	f44e                	sd	s3,40(sp)
    800011f2:	f052                	sd	s4,32(sp)
    800011f4:	ec56                	sd	s5,24(sp)
    800011f6:	e85a                	sd	s6,16(sp)
    800011f8:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800011fa:	00006517          	auipc	a0,0x6
    800011fe:	f2650513          	addi	a0,a0,-218 # 80007120 <etext+0x120>
    80001202:	d92ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: walk");
    80001206:	00006517          	auipc	a0,0x6
    8000120a:	f3250513          	addi	a0,a0,-206 # 80007138 <etext+0x138>
    8000120e:	d86ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not mapped");
    80001212:	00006517          	auipc	a0,0x6
    80001216:	f3650513          	addi	a0,a0,-202 # 80007148 <etext+0x148>
    8000121a:	d7aff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not a leaf");
    8000121e:	00006517          	auipc	a0,0x6
    80001222:	f4250513          	addi	a0,a0,-190 # 80007160 <etext+0x160>
    80001226:	d6eff0ef          	jal	80000794 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000122a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000122e:	995a                	add	s2,s2,s6
    80001230:	03397863          	bgeu	s2,s3,80001260 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001234:	4601                	li	a2,0
    80001236:	85ca                	mv	a1,s2
    80001238:	8552                	mv	a0,s4
    8000123a:	d03ff0ef          	jal	80000f3c <walk>
    8000123e:	84aa                	mv	s1,a0
    80001240:	d179                	beqz	a0,80001206 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001242:	6108                	ld	a0,0(a0)
    80001244:	00157793          	andi	a5,a0,1
    80001248:	d7e9                	beqz	a5,80001212 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000124a:	3ff57793          	andi	a5,a0,1023
    8000124e:	fd7788e3          	beq	a5,s7,8000121e <uvmunmap+0x64>
    if(do_free){
    80001252:	fc0a8ce3          	beqz	s5,8000122a <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    80001256:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001258:	0532                	slli	a0,a0,0xc
    8000125a:	fe8ff0ef          	jal	80000a42 <kfree>
    8000125e:	b7f1                	j	8000122a <uvmunmap+0x70>
    80001260:	74e2                	ld	s1,56(sp)
    80001262:	7942                	ld	s2,48(sp)
    80001264:	79a2                	ld	s3,40(sp)
    80001266:	7a02                	ld	s4,32(sp)
    80001268:	6ae2                	ld	s5,24(sp)
    8000126a:	6b42                	ld	s6,16(sp)
    8000126c:	6ba2                	ld	s7,8(sp)
  }
}
    8000126e:	60a6                	ld	ra,72(sp)
    80001270:	6406                	ld	s0,64(sp)
    80001272:	6161                	addi	sp,sp,80
    80001274:	8082                	ret

0000000080001276 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001276:	1101                	addi	sp,sp,-32
    80001278:	ec06                	sd	ra,24(sp)
    8000127a:	e822                	sd	s0,16(sp)
    8000127c:	e426                	sd	s1,8(sp)
    8000127e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001280:	8a5ff0ef          	jal	80000b24 <kalloc>
    80001284:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001286:	c509                	beqz	a0,80001290 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001288:	6605                	lui	a2,0x1
    8000128a:	4581                	li	a1,0
    8000128c:	a3dff0ef          	jal	80000cc8 <memset>
  return pagetable;
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret

000000008000129c <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000129c:	7179                	addi	sp,sp,-48
    8000129e:	f406                	sd	ra,40(sp)
    800012a0:	f022                	sd	s0,32(sp)
    800012a2:	ec26                	sd	s1,24(sp)
    800012a4:	e84a                	sd	s2,16(sp)
    800012a6:	e44e                	sd	s3,8(sp)
    800012a8:	e052                	sd	s4,0(sp)
    800012aa:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012ac:	6785                	lui	a5,0x1
    800012ae:	04f67063          	bgeu	a2,a5,800012ee <uvmfirst+0x52>
    800012b2:	8a2a                	mv	s4,a0
    800012b4:	89ae                	mv	s3,a1
    800012b6:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012b8:	86dff0ef          	jal	80000b24 <kalloc>
    800012bc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012be:	6605                	lui	a2,0x1
    800012c0:	4581                	li	a1,0
    800012c2:	a07ff0ef          	jal	80000cc8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012c6:	4779                	li	a4,30
    800012c8:	86ca                	mv	a3,s2
    800012ca:	6605                	lui	a2,0x1
    800012cc:	4581                	li	a1,0
    800012ce:	8552                	mv	a0,s4
    800012d0:	d45ff0ef          	jal	80001014 <mappages>
  memmove(mem, src, sz);
    800012d4:	8626                	mv	a2,s1
    800012d6:	85ce                	mv	a1,s3
    800012d8:	854a                	mv	a0,s2
    800012da:	a4bff0ef          	jal	80000d24 <memmove>
}
    800012de:	70a2                	ld	ra,40(sp)
    800012e0:	7402                	ld	s0,32(sp)
    800012e2:	64e2                	ld	s1,24(sp)
    800012e4:	6942                	ld	s2,16(sp)
    800012e6:	69a2                	ld	s3,8(sp)
    800012e8:	6a02                	ld	s4,0(sp)
    800012ea:	6145                	addi	sp,sp,48
    800012ec:	8082                	ret
    panic("uvmfirst: more than a page");
    800012ee:	00006517          	auipc	a0,0x6
    800012f2:	e8a50513          	addi	a0,a0,-374 # 80007178 <etext+0x178>
    800012f6:	c9eff0ef          	jal	80000794 <panic>

00000000800012fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012fa:	1101                	addi	sp,sp,-32
    800012fc:	ec06                	sd	ra,24(sp)
    800012fe:	e822                	sd	s0,16(sp)
    80001300:	e426                	sd	s1,8(sp)
    80001302:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001304:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001306:	00b67d63          	bgeu	a2,a1,80001320 <uvmdealloc+0x26>
    8000130a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000130c:	6785                	lui	a5,0x1
    8000130e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001310:	00f60733          	add	a4,a2,a5
    80001314:	76fd                	lui	a3,0xfffff
    80001316:	8f75                	and	a4,a4,a3
    80001318:	97ae                	add	a5,a5,a1
    8000131a:	8ff5                	and	a5,a5,a3
    8000131c:	00f76863          	bltu	a4,a5,8000132c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001320:	8526                	mv	a0,s1
    80001322:	60e2                	ld	ra,24(sp)
    80001324:	6442                	ld	s0,16(sp)
    80001326:	64a2                	ld	s1,8(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000132c:	8f99                	sub	a5,a5,a4
    8000132e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001330:	4685                	li	a3,1
    80001332:	0007861b          	sext.w	a2,a5
    80001336:	85ba                	mv	a1,a4
    80001338:	e83ff0ef          	jal	800011ba <uvmunmap>
    8000133c:	b7d5                	j	80001320 <uvmdealloc+0x26>

000000008000133e <uvmalloc>:
  if(newsz < oldsz)
    8000133e:	08b66f63          	bltu	a2,a1,800013dc <uvmalloc+0x9e>
{
    80001342:	7139                	addi	sp,sp,-64
    80001344:	fc06                	sd	ra,56(sp)
    80001346:	f822                	sd	s0,48(sp)
    80001348:	ec4e                	sd	s3,24(sp)
    8000134a:	e852                	sd	s4,16(sp)
    8000134c:	e456                	sd	s5,8(sp)
    8000134e:	0080                	addi	s0,sp,64
    80001350:	8aaa                	mv	s5,a0
    80001352:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001354:	6785                	lui	a5,0x1
    80001356:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001358:	95be                	add	a1,a1,a5
    8000135a:	77fd                	lui	a5,0xfffff
    8000135c:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001360:	08c9f063          	bgeu	s3,a2,800013e0 <uvmalloc+0xa2>
    80001364:	f426                	sd	s1,40(sp)
    80001366:	f04a                	sd	s2,32(sp)
    80001368:	e05a                	sd	s6,0(sp)
    8000136a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000136c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001370:	fb4ff0ef          	jal	80000b24 <kalloc>
    80001374:	84aa                	mv	s1,a0
    if(mem == 0){
    80001376:	c515                	beqz	a0,800013a2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001378:	6605                	lui	a2,0x1
    8000137a:	4581                	li	a1,0
    8000137c:	94dff0ef          	jal	80000cc8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001380:	875a                	mv	a4,s6
    80001382:	86a6                	mv	a3,s1
    80001384:	6605                	lui	a2,0x1
    80001386:	85ca                	mv	a1,s2
    80001388:	8556                	mv	a0,s5
    8000138a:	c8bff0ef          	jal	80001014 <mappages>
    8000138e:	e915                	bnez	a0,800013c2 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001390:	6785                	lui	a5,0x1
    80001392:	993e                	add	s2,s2,a5
    80001394:	fd496ee3          	bltu	s2,s4,80001370 <uvmalloc+0x32>
  return newsz;
    80001398:	8552                	mv	a0,s4
    8000139a:	74a2                	ld	s1,40(sp)
    8000139c:	7902                	ld	s2,32(sp)
    8000139e:	6b02                	ld	s6,0(sp)
    800013a0:	a811                	j	800013b4 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013a2:	864e                	mv	a2,s3
    800013a4:	85ca                	mv	a1,s2
    800013a6:	8556                	mv	a0,s5
    800013a8:	f53ff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013ac:	4501                	li	a0,0
    800013ae:	74a2                	ld	s1,40(sp)
    800013b0:	7902                	ld	s2,32(sp)
    800013b2:	6b02                	ld	s6,0(sp)
}
    800013b4:	70e2                	ld	ra,56(sp)
    800013b6:	7442                	ld	s0,48(sp)
    800013b8:	69e2                	ld	s3,24(sp)
    800013ba:	6a42                	ld	s4,16(sp)
    800013bc:	6aa2                	ld	s5,8(sp)
    800013be:	6121                	addi	sp,sp,64
    800013c0:	8082                	ret
      kfree(mem);
    800013c2:	8526                	mv	a0,s1
    800013c4:	e7eff0ef          	jal	80000a42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013c8:	864e                	mv	a2,s3
    800013ca:	85ca                	mv	a1,s2
    800013cc:	8556                	mv	a0,s5
    800013ce:	f2dff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013d2:	4501                	li	a0,0
    800013d4:	74a2                	ld	s1,40(sp)
    800013d6:	7902                	ld	s2,32(sp)
    800013d8:	6b02                	ld	s6,0(sp)
    800013da:	bfe9                	j	800013b4 <uvmalloc+0x76>
    return oldsz;
    800013dc:	852e                	mv	a0,a1
}
    800013de:	8082                	ret
  return newsz;
    800013e0:	8532                	mv	a0,a2
    800013e2:	bfc9                	j	800013b4 <uvmalloc+0x76>

00000000800013e4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013e4:	7179                	addi	sp,sp,-48
    800013e6:	f406                	sd	ra,40(sp)
    800013e8:	f022                	sd	s0,32(sp)
    800013ea:	ec26                	sd	s1,24(sp)
    800013ec:	e84a                	sd	s2,16(sp)
    800013ee:	e44e                	sd	s3,8(sp)
    800013f0:	e052                	sd	s4,0(sp)
    800013f2:	1800                	addi	s0,sp,48
    800013f4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013f6:	84aa                	mv	s1,a0
    800013f8:	6905                	lui	s2,0x1
    800013fa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013fc:	4985                	li	s3,1
    800013fe:	a819                	j	80001414 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001400:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001402:	00c79513          	slli	a0,a5,0xc
    80001406:	fdfff0ef          	jal	800013e4 <freewalk>
      pagetable[i] = 0;
    8000140a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000140e:	04a1                	addi	s1,s1,8
    80001410:	01248f63          	beq	s1,s2,8000142e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001414:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001416:	00f7f713          	andi	a4,a5,15
    8000141a:	ff3703e3          	beq	a4,s3,80001400 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000141e:	8b85                	andi	a5,a5,1
    80001420:	d7fd                	beqz	a5,8000140e <freewalk+0x2a>
      panic("freewalk: leaf");
    80001422:	00006517          	auipc	a0,0x6
    80001426:	d7650513          	addi	a0,a0,-650 # 80007198 <etext+0x198>
    8000142a:	b6aff0ef          	jal	80000794 <panic>
    }
  }
  kfree((void*)pagetable);
    8000142e:	8552                	mv	a0,s4
    80001430:	e12ff0ef          	jal	80000a42 <kfree>
}
    80001434:	70a2                	ld	ra,40(sp)
    80001436:	7402                	ld	s0,32(sp)
    80001438:	64e2                	ld	s1,24(sp)
    8000143a:	6942                	ld	s2,16(sp)
    8000143c:	69a2                	ld	s3,8(sp)
    8000143e:	6a02                	ld	s4,0(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret

0000000080001444 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001444:	1101                	addi	sp,sp,-32
    80001446:	ec06                	sd	ra,24(sp)
    80001448:	e822                	sd	s0,16(sp)
    8000144a:	e426                	sd	s1,8(sp)
    8000144c:	1000                	addi	s0,sp,32
    8000144e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001450:	e989                	bnez	a1,80001462 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001452:	8526                	mv	a0,s1
    80001454:	f91ff0ef          	jal	800013e4 <freewalk>
}
    80001458:	60e2                	ld	ra,24(sp)
    8000145a:	6442                	ld	s0,16(sp)
    8000145c:	64a2                	ld	s1,8(sp)
    8000145e:	6105                	addi	sp,sp,32
    80001460:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001462:	6785                	lui	a5,0x1
    80001464:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001466:	95be                	add	a1,a1,a5
    80001468:	4685                	li	a3,1
    8000146a:	00c5d613          	srli	a2,a1,0xc
    8000146e:	4581                	li	a1,0
    80001470:	d4bff0ef          	jal	800011ba <uvmunmap>
    80001474:	bff9                	j	80001452 <uvmfree+0xe>

0000000080001476 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001476:	c65d                	beqz	a2,80001524 <uvmcopy+0xae>
{
    80001478:	715d                	addi	sp,sp,-80
    8000147a:	e486                	sd	ra,72(sp)
    8000147c:	e0a2                	sd	s0,64(sp)
    8000147e:	fc26                	sd	s1,56(sp)
    80001480:	f84a                	sd	s2,48(sp)
    80001482:	f44e                	sd	s3,40(sp)
    80001484:	f052                	sd	s4,32(sp)
    80001486:	ec56                	sd	s5,24(sp)
    80001488:	e85a                	sd	s6,16(sp)
    8000148a:	e45e                	sd	s7,8(sp)
    8000148c:	0880                	addi	s0,sp,80
    8000148e:	8b2a                	mv	s6,a0
    80001490:	8aae                	mv	s5,a1
    80001492:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001494:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001496:	4601                	li	a2,0
    80001498:	85ce                	mv	a1,s3
    8000149a:	855a                	mv	a0,s6
    8000149c:	aa1ff0ef          	jal	80000f3c <walk>
    800014a0:	c121                	beqz	a0,800014e0 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800014a2:	6118                	ld	a4,0(a0)
    800014a4:	00177793          	andi	a5,a4,1
    800014a8:	c3b1                	beqz	a5,800014ec <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800014aa:	00a75593          	srli	a1,a4,0xa
    800014ae:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014b2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014b6:	e6eff0ef          	jal	80000b24 <kalloc>
    800014ba:	892a                	mv	s2,a0
    800014bc:	c129                	beqz	a0,800014fe <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014be:	6605                	lui	a2,0x1
    800014c0:	85de                	mv	a1,s7
    800014c2:	863ff0ef          	jal	80000d24 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014c6:	8726                	mv	a4,s1
    800014c8:	86ca                	mv	a3,s2
    800014ca:	6605                	lui	a2,0x1
    800014cc:	85ce                	mv	a1,s3
    800014ce:	8556                	mv	a0,s5
    800014d0:	b45ff0ef          	jal	80001014 <mappages>
    800014d4:	e115                	bnez	a0,800014f8 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    800014d6:	6785                	lui	a5,0x1
    800014d8:	99be                	add	s3,s3,a5
    800014da:	fb49eee3          	bltu	s3,s4,80001496 <uvmcopy+0x20>
    800014de:	a805                	j	8000150e <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    800014e0:	00006517          	auipc	a0,0x6
    800014e4:	cc850513          	addi	a0,a0,-824 # 800071a8 <etext+0x1a8>
    800014e8:	aacff0ef          	jal	80000794 <panic>
      panic("uvmcopy: page not present");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	cdc50513          	addi	a0,a0,-804 # 800071c8 <etext+0x1c8>
    800014f4:	aa0ff0ef          	jal	80000794 <panic>
      kfree(mem);
    800014f8:	854a                	mv	a0,s2
    800014fa:	d48ff0ef          	jal	80000a42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014fe:	4685                	li	a3,1
    80001500:	00c9d613          	srli	a2,s3,0xc
    80001504:	4581                	li	a1,0
    80001506:	8556                	mv	a0,s5
    80001508:	cb3ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000150c:	557d                	li	a0,-1
}
    8000150e:	60a6                	ld	ra,72(sp)
    80001510:	6406                	ld	s0,64(sp)
    80001512:	74e2                	ld	s1,56(sp)
    80001514:	7942                	ld	s2,48(sp)
    80001516:	79a2                	ld	s3,40(sp)
    80001518:	7a02                	ld	s4,32(sp)
    8000151a:	6ae2                	ld	s5,24(sp)
    8000151c:	6b42                	ld	s6,16(sp)
    8000151e:	6ba2                	ld	s7,8(sp)
    80001520:	6161                	addi	sp,sp,80
    80001522:	8082                	ret
  return 0;
    80001524:	4501                	li	a0,0
}
    80001526:	8082                	ret

0000000080001528 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001528:	1141                	addi	sp,sp,-16
    8000152a:	e406                	sd	ra,8(sp)
    8000152c:	e022                	sd	s0,0(sp)
    8000152e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001530:	4601                	li	a2,0
    80001532:	a0bff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80001536:	c901                	beqz	a0,80001546 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001538:	611c                	ld	a5,0(a0)
    8000153a:	9bbd                	andi	a5,a5,-17
    8000153c:	e11c                	sd	a5,0(a0)
}
    8000153e:	60a2                	ld	ra,8(sp)
    80001540:	6402                	ld	s0,0(sp)
    80001542:	0141                	addi	sp,sp,16
    80001544:	8082                	ret
    panic("uvmclear");
    80001546:	00006517          	auipc	a0,0x6
    8000154a:	ca250513          	addi	a0,a0,-862 # 800071e8 <etext+0x1e8>
    8000154e:	a46ff0ef          	jal	80000794 <panic>

0000000080001552 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001552:	cad1                	beqz	a3,800015e6 <copyout+0x94>
{
    80001554:	711d                	addi	sp,sp,-96
    80001556:	ec86                	sd	ra,88(sp)
    80001558:	e8a2                	sd	s0,80(sp)
    8000155a:	e4a6                	sd	s1,72(sp)
    8000155c:	fc4e                	sd	s3,56(sp)
    8000155e:	f456                	sd	s5,40(sp)
    80001560:	f05a                	sd	s6,32(sp)
    80001562:	ec5e                	sd	s7,24(sp)
    80001564:	1080                	addi	s0,sp,96
    80001566:	8baa                	mv	s7,a0
    80001568:	8aae                	mv	s5,a1
    8000156a:	8b32                	mv	s6,a2
    8000156c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000156e:	74fd                	lui	s1,0xfffff
    80001570:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001572:	57fd                	li	a5,-1
    80001574:	83e9                	srli	a5,a5,0x1a
    80001576:	0697ea63          	bltu	a5,s1,800015ea <copyout+0x98>
    8000157a:	e0ca                	sd	s2,64(sp)
    8000157c:	f852                	sd	s4,48(sp)
    8000157e:	e862                	sd	s8,16(sp)
    80001580:	e466                	sd	s9,8(sp)
    80001582:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001584:	4cd5                	li	s9,21
    80001586:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    80001588:	8c3e                	mv	s8,a5
    8000158a:	a025                	j	800015b2 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    8000158c:	83a9                	srli	a5,a5,0xa
    8000158e:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001590:	409a8533          	sub	a0,s5,s1
    80001594:	0009061b          	sext.w	a2,s2
    80001598:	85da                	mv	a1,s6
    8000159a:	953e                	add	a0,a0,a5
    8000159c:	f88ff0ef          	jal	80000d24 <memmove>

    len -= n;
    800015a0:	412989b3          	sub	s3,s3,s2
    src += n;
    800015a4:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800015a6:	02098963          	beqz	s3,800015d8 <copyout+0x86>
    if(va0 >= MAXVA)
    800015aa:	054c6263          	bltu	s8,s4,800015ee <copyout+0x9c>
    800015ae:	84d2                	mv	s1,s4
    800015b0:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800015b2:	4601                	li	a2,0
    800015b4:	85a6                	mv	a1,s1
    800015b6:	855e                	mv	a0,s7
    800015b8:	985ff0ef          	jal	80000f3c <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015bc:	c121                	beqz	a0,800015fc <copyout+0xaa>
    800015be:	611c                	ld	a5,0(a0)
    800015c0:	0157f713          	andi	a4,a5,21
    800015c4:	05971b63          	bne	a4,s9,8000161a <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    800015c8:	01a48a33          	add	s4,s1,s10
    800015cc:	415a0933          	sub	s2,s4,s5
    if(n > len)
    800015d0:	fb29fee3          	bgeu	s3,s2,8000158c <copyout+0x3a>
    800015d4:	894e                	mv	s2,s3
    800015d6:	bf5d                	j	8000158c <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    800015d8:	4501                	li	a0,0
    800015da:	6906                	ld	s2,64(sp)
    800015dc:	7a42                	ld	s4,48(sp)
    800015de:	6c42                	ld	s8,16(sp)
    800015e0:	6ca2                	ld	s9,8(sp)
    800015e2:	6d02                	ld	s10,0(sp)
    800015e4:	a015                	j	80001608 <copyout+0xb6>
    800015e6:	4501                	li	a0,0
}
    800015e8:	8082                	ret
      return -1;
    800015ea:	557d                	li	a0,-1
    800015ec:	a831                	j	80001608 <copyout+0xb6>
    800015ee:	557d                	li	a0,-1
    800015f0:	6906                	ld	s2,64(sp)
    800015f2:	7a42                	ld	s4,48(sp)
    800015f4:	6c42                	ld	s8,16(sp)
    800015f6:	6ca2                	ld	s9,8(sp)
    800015f8:	6d02                	ld	s10,0(sp)
    800015fa:	a039                	j	80001608 <copyout+0xb6>
      return -1;
    800015fc:	557d                	li	a0,-1
    800015fe:	6906                	ld	s2,64(sp)
    80001600:	7a42                	ld	s4,48(sp)
    80001602:	6c42                	ld	s8,16(sp)
    80001604:	6ca2                	ld	s9,8(sp)
    80001606:	6d02                	ld	s10,0(sp)
}
    80001608:	60e6                	ld	ra,88(sp)
    8000160a:	6446                	ld	s0,80(sp)
    8000160c:	64a6                	ld	s1,72(sp)
    8000160e:	79e2                	ld	s3,56(sp)
    80001610:	7aa2                	ld	s5,40(sp)
    80001612:	7b02                	ld	s6,32(sp)
    80001614:	6be2                	ld	s7,24(sp)
    80001616:	6125                	addi	sp,sp,96
    80001618:	8082                	ret
      return -1;
    8000161a:	557d                	li	a0,-1
    8000161c:	6906                	ld	s2,64(sp)
    8000161e:	7a42                	ld	s4,48(sp)
    80001620:	6c42                	ld	s8,16(sp)
    80001622:	6ca2                	ld	s9,8(sp)
    80001624:	6d02                	ld	s10,0(sp)
    80001626:	b7cd                	j	80001608 <copyout+0xb6>

0000000080001628 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001628:	c6a5                	beqz	a3,80001690 <copyin+0x68>
{
    8000162a:	715d                	addi	sp,sp,-80
    8000162c:	e486                	sd	ra,72(sp)
    8000162e:	e0a2                	sd	s0,64(sp)
    80001630:	fc26                	sd	s1,56(sp)
    80001632:	f84a                	sd	s2,48(sp)
    80001634:	f44e                	sd	s3,40(sp)
    80001636:	f052                	sd	s4,32(sp)
    80001638:	ec56                	sd	s5,24(sp)
    8000163a:	e85a                	sd	s6,16(sp)
    8000163c:	e45e                	sd	s7,8(sp)
    8000163e:	e062                	sd	s8,0(sp)
    80001640:	0880                	addi	s0,sp,80
    80001642:	8b2a                	mv	s6,a0
    80001644:	8a2e                	mv	s4,a1
    80001646:	8c32                	mv	s8,a2
    80001648:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000164a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000164c:	6a85                	lui	s5,0x1
    8000164e:	a00d                	j	80001670 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001650:	018505b3          	add	a1,a0,s8
    80001654:	0004861b          	sext.w	a2,s1
    80001658:	412585b3          	sub	a1,a1,s2
    8000165c:	8552                	mv	a0,s4
    8000165e:	ec6ff0ef          	jal	80000d24 <memmove>

    len -= n;
    80001662:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001666:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001668:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000166c:	02098063          	beqz	s3,8000168c <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80001670:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001674:	85ca                	mv	a1,s2
    80001676:	855a                	mv	a0,s6
    80001678:	95fff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    8000167c:	cd01                	beqz	a0,80001694 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000167e:	418904b3          	sub	s1,s2,s8
    80001682:	94d6                	add	s1,s1,s5
    if(n > len)
    80001684:	fc99f6e3          	bgeu	s3,s1,80001650 <copyin+0x28>
    80001688:	84ce                	mv	s1,s3
    8000168a:	b7d9                	j	80001650 <copyin+0x28>
  }
  return 0;
    8000168c:	4501                	li	a0,0
    8000168e:	a021                	j	80001696 <copyin+0x6e>
    80001690:	4501                	li	a0,0
}
    80001692:	8082                	ret
      return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6c02                	ld	s8,0(sp)
    800016aa:	6161                	addi	sp,sp,80
    800016ac:	8082                	ret

00000000800016ae <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800016ae:	c6dd                	beqz	a3,8000175c <copyinstr+0xae>
{
    800016b0:	715d                	addi	sp,sp,-80
    800016b2:	e486                	sd	ra,72(sp)
    800016b4:	e0a2                	sd	s0,64(sp)
    800016b6:	fc26                	sd	s1,56(sp)
    800016b8:	f84a                	sd	s2,48(sp)
    800016ba:	f44e                	sd	s3,40(sp)
    800016bc:	f052                	sd	s4,32(sp)
    800016be:	ec56                	sd	s5,24(sp)
    800016c0:	e85a                	sd	s6,16(sp)
    800016c2:	e45e                	sd	s7,8(sp)
    800016c4:	0880                	addi	s0,sp,80
    800016c6:	8a2a                	mv	s4,a0
    800016c8:	8b2e                	mv	s6,a1
    800016ca:	8bb2                	mv	s7,a2
    800016cc:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800016ce:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016d0:	6985                	lui	s3,0x1
    800016d2:	a825                	j	8000170a <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016d4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800016d8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016da:	37fd                	addiw	a5,a5,-1
    800016dc:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6161                	addi	sp,sp,80
    800016f4:	8082                	ret
    800016f6:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800016fa:	9742                	add	a4,a4,a6
      --max;
    800016fc:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001700:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001704:	04e58463          	beq	a1,a4,8000174c <copyinstr+0x9e>
{
    80001708:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000170a:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000170e:	85a6                	mv	a1,s1
    80001710:	8552                	mv	a0,s4
    80001712:	8c5ff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    80001716:	cd0d                	beqz	a0,80001750 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001718:	417486b3          	sub	a3,s1,s7
    8000171c:	96ce                	add	a3,a3,s3
    if(n > max)
    8000171e:	00d97363          	bgeu	s2,a3,80001724 <copyinstr+0x76>
    80001722:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001724:	955e                	add	a0,a0,s7
    80001726:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001728:	c695                	beqz	a3,80001754 <copyinstr+0xa6>
    8000172a:	87da                	mv	a5,s6
    8000172c:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000172e:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001732:	96da                	add	a3,a3,s6
    80001734:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001736:	00f60733          	add	a4,a2,a5
    8000173a:	00074703          	lbu	a4,0(a4)
    8000173e:	db59                	beqz	a4,800016d4 <copyinstr+0x26>
        *dst = *p;
    80001740:	00e78023          	sb	a4,0(a5)
      dst++;
    80001744:	0785                	addi	a5,a5,1
    while(n > 0){
    80001746:	fed797e3          	bne	a5,a3,80001734 <copyinstr+0x86>
    8000174a:	b775                	j	800016f6 <copyinstr+0x48>
    8000174c:	4781                	li	a5,0
    8000174e:	b771                	j	800016da <copyinstr+0x2c>
      return -1;
    80001750:	557d                	li	a0,-1
    80001752:	b779                	j	800016e0 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001754:	6b85                	lui	s7,0x1
    80001756:	9ba6                	add	s7,s7,s1
    80001758:	87da                	mv	a5,s6
    8000175a:	b77d                	j	80001708 <copyinstr+0x5a>
  int got_null = 0;
    8000175c:	4781                	li	a5,0
  if(got_null){
    8000175e:	37fd                	addiw	a5,a5,-1
    80001760:	0007851b          	sext.w	a0,a5
}
    80001764:	8082                	ret

0000000080001766 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001766:	7139                	addi	sp,sp,-64
    80001768:	fc06                	sd	ra,56(sp)
    8000176a:	f822                	sd	s0,48(sp)
    8000176c:	f426                	sd	s1,40(sp)
    8000176e:	f04a                	sd	s2,32(sp)
    80001770:	ec4e                	sd	s3,24(sp)
    80001772:	e852                	sd	s4,16(sp)
    80001774:	e456                	sd	s5,8(sp)
    80001776:	e05a                	sd	s6,0(sp)
    80001778:	0080                	addi	s0,sp,64
    8000177a:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000177c:	0000e497          	auipc	s1,0xe
    80001780:	75448493          	addi	s1,s1,1876 # 8000fed0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001784:	8b26                	mv	s6,s1
    80001786:	04fa5937          	lui	s2,0x4fa5
    8000178a:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    8000178e:	0932                	slli	s2,s2,0xc
    80001790:	fa590913          	addi	s2,s2,-91
    80001794:	0932                	slli	s2,s2,0xc
    80001796:	fa590913          	addi	s2,s2,-91
    8000179a:	0932                	slli	s2,s2,0xc
    8000179c:	fa590913          	addi	s2,s2,-91
    800017a0:	040009b7          	lui	s3,0x4000
    800017a4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017a6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017a8:	00014a97          	auipc	s5,0x14
    800017ac:	128a8a93          	addi	s5,s5,296 # 800158d0 <tickslock>
    char *pa = kalloc();
    800017b0:	b74ff0ef          	jal	80000b24 <kalloc>
    800017b4:	862a                	mv	a2,a0
    if(pa == 0)
    800017b6:	cd15                	beqz	a0,800017f2 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017b8:	416485b3          	sub	a1,s1,s6
    800017bc:	858d                	srai	a1,a1,0x3
    800017be:	032585b3          	mul	a1,a1,s2
    800017c2:	2585                	addiw	a1,a1,1
    800017c4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017c8:	4719                	li	a4,6
    800017ca:	6685                	lui	a3,0x1
    800017cc:	40b985b3          	sub	a1,s3,a1
    800017d0:	8552                	mv	a0,s4
    800017d2:	8f3ff0ef          	jal	800010c4 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d6:	16848493          	addi	s1,s1,360
    800017da:	fd549be3          	bne	s1,s5,800017b0 <proc_mapstacks+0x4a>
  }
}
    800017de:	70e2                	ld	ra,56(sp)
    800017e0:	7442                	ld	s0,48(sp)
    800017e2:	74a2                	ld	s1,40(sp)
    800017e4:	7902                	ld	s2,32(sp)
    800017e6:	69e2                	ld	s3,24(sp)
    800017e8:	6a42                	ld	s4,16(sp)
    800017ea:	6aa2                	ld	s5,8(sp)
    800017ec:	6b02                	ld	s6,0(sp)
    800017ee:	6121                	addi	sp,sp,64
    800017f0:	8082                	ret
      panic("kalloc");
    800017f2:	00006517          	auipc	a0,0x6
    800017f6:	a0650513          	addi	a0,a0,-1530 # 800071f8 <etext+0x1f8>
    800017fa:	f9bfe0ef          	jal	80000794 <panic>

00000000800017fe <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017fe:	7139                	addi	sp,sp,-64
    80001800:	fc06                	sd	ra,56(sp)
    80001802:	f822                	sd	s0,48(sp)
    80001804:	f426                	sd	s1,40(sp)
    80001806:	f04a                	sd	s2,32(sp)
    80001808:	ec4e                	sd	s3,24(sp)
    8000180a:	e852                	sd	s4,16(sp)
    8000180c:	e456                	sd	s5,8(sp)
    8000180e:	e05a                	sd	s6,0(sp)
    80001810:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001812:	00006597          	auipc	a1,0x6
    80001816:	9ee58593          	addi	a1,a1,-1554 # 80007200 <etext+0x200>
    8000181a:	0000e517          	auipc	a0,0xe
    8000181e:	28650513          	addi	a0,a0,646 # 8000faa0 <pid_lock>
    80001822:	b52ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001826:	00006597          	auipc	a1,0x6
    8000182a:	9e258593          	addi	a1,a1,-1566 # 80007208 <etext+0x208>
    8000182e:	0000e517          	auipc	a0,0xe
    80001832:	28a50513          	addi	a0,a0,650 # 8000fab8 <wait_lock>
    80001836:	b3eff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183a:	0000e497          	auipc	s1,0xe
    8000183e:	69648493          	addi	s1,s1,1686 # 8000fed0 <proc>
      initlock(&p->lock, "proc");
    80001842:	00006b17          	auipc	s6,0x6
    80001846:	9d6b0b13          	addi	s6,s6,-1578 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000184a:	8aa6                	mv	s5,s1
    8000184c:	04fa5937          	lui	s2,0x4fa5
    80001850:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001854:	0932                	slli	s2,s2,0xc
    80001856:	fa590913          	addi	s2,s2,-91
    8000185a:	0932                	slli	s2,s2,0xc
    8000185c:	fa590913          	addi	s2,s2,-91
    80001860:	0932                	slli	s2,s2,0xc
    80001862:	fa590913          	addi	s2,s2,-91
    80001866:	040009b7          	lui	s3,0x4000
    8000186a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000186c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	00014a17          	auipc	s4,0x14
    80001872:	062a0a13          	addi	s4,s4,98 # 800158d0 <tickslock>
      initlock(&p->lock, "proc");
    80001876:	85da                	mv	a1,s6
    80001878:	8526                	mv	a0,s1
    8000187a:	afaff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    8000187e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001882:	415487b3          	sub	a5,s1,s5
    80001886:	878d                	srai	a5,a5,0x3
    80001888:	032787b3          	mul	a5,a5,s2
    8000188c:	2785                	addiw	a5,a5,1
    8000188e:	00d7979b          	slliw	a5,a5,0xd
    80001892:	40f987b3          	sub	a5,s3,a5
    80001896:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001898:	16848493          	addi	s1,s1,360
    8000189c:	fd449de3          	bne	s1,s4,80001876 <procinit+0x78>
  }
}
    800018a0:	70e2                	ld	ra,56(sp)
    800018a2:	7442                	ld	s0,48(sp)
    800018a4:	74a2                	ld	s1,40(sp)
    800018a6:	7902                	ld	s2,32(sp)
    800018a8:	69e2                	ld	s3,24(sp)
    800018aa:	6a42                	ld	s4,16(sp)
    800018ac:	6aa2                	ld	s5,8(sp)
    800018ae:	6b02                	ld	s6,0(sp)
    800018b0:	6121                	addi	sp,sp,64
    800018b2:	8082                	ret

00000000800018b4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018b4:	1141                	addi	sp,sp,-16
    800018b6:	e422                	sd	s0,8(sp)
    800018b8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018ba:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018bc:	2501                	sext.w	a0,a0
    800018be:	6422                	ld	s0,8(sp)
    800018c0:	0141                	addi	sp,sp,16
    800018c2:	8082                	ret

00000000800018c4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018c4:	1141                	addi	sp,sp,-16
    800018c6:	e422                	sd	s0,8(sp)
    800018c8:	0800                	addi	s0,sp,16
    800018ca:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018cc:	2781                	sext.w	a5,a5
    800018ce:	079e                	slli	a5,a5,0x7
  return c;
}
    800018d0:	0000e517          	auipc	a0,0xe
    800018d4:	20050513          	addi	a0,a0,512 # 8000fad0 <cpus>
    800018d8:	953e                	add	a0,a0,a5
    800018da:	6422                	ld	s0,8(sp)
    800018dc:	0141                	addi	sp,sp,16
    800018de:	8082                	ret

00000000800018e0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018e0:	1101                	addi	sp,sp,-32
    800018e2:	ec06                	sd	ra,24(sp)
    800018e4:	e822                	sd	s0,16(sp)
    800018e6:	e426                	sd	s1,8(sp)
    800018e8:	1000                	addi	s0,sp,32
  push_off();
    800018ea:	acaff0ef          	jal	80000bb4 <push_off>
    800018ee:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018f0:	2781                	sext.w	a5,a5
    800018f2:	079e                	slli	a5,a5,0x7
    800018f4:	0000e717          	auipc	a4,0xe
    800018f8:	1ac70713          	addi	a4,a4,428 # 8000faa0 <pid_lock>
    800018fc:	97ba                	add	a5,a5,a4
    800018fe:	7b84                	ld	s1,48(a5)
  pop_off();
    80001900:	b38ff0ef          	jal	80000c38 <pop_off>
  return p;
}
    80001904:	8526                	mv	a0,s1
    80001906:	60e2                	ld	ra,24(sp)
    80001908:	6442                	ld	s0,16(sp)
    8000190a:	64a2                	ld	s1,8(sp)
    8000190c:	6105                	addi	sp,sp,32
    8000190e:	8082                	ret

0000000080001910 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001910:	1141                	addi	sp,sp,-16
    80001912:	e406                	sd	ra,8(sp)
    80001914:	e022                	sd	s0,0(sp)
    80001916:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001918:	fc9ff0ef          	jal	800018e0 <myproc>
    8000191c:	b70ff0ef          	jal	80000c8c <release>

  if (first) {
    80001920:	00006797          	auipc	a5,0x6
    80001924:	fd07a783          	lw	a5,-48(a5) # 800078f0 <first.1>
    80001928:	e799                	bnez	a5,80001936 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000192a:	2bf000ef          	jal	800023e8 <usertrapret>
}
    8000192e:	60a2                	ld	ra,8(sp)
    80001930:	6402                	ld	s0,0(sp)
    80001932:	0141                	addi	sp,sp,16
    80001934:	8082                	ret
    fsinit(ROOTDEV);
    80001936:	4505                	li	a0,1
    80001938:	674010ef          	jal	80002fac <fsinit>
    first = 0;
    8000193c:	00006797          	auipc	a5,0x6
    80001940:	fa07aa23          	sw	zero,-76(a5) # 800078f0 <first.1>
    __sync_synchronize();
    80001944:	0ff0000f          	fence
    80001948:	b7cd                	j	8000192a <forkret+0x1a>

000000008000194a <allocpid>:
{
    8000194a:	1101                	addi	sp,sp,-32
    8000194c:	ec06                	sd	ra,24(sp)
    8000194e:	e822                	sd	s0,16(sp)
    80001950:	e426                	sd	s1,8(sp)
    80001952:	e04a                	sd	s2,0(sp)
    80001954:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001956:	0000e917          	auipc	s2,0xe
    8000195a:	14a90913          	addi	s2,s2,330 # 8000faa0 <pid_lock>
    8000195e:	854a                	mv	a0,s2
    80001960:	a94ff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    80001964:	00006797          	auipc	a5,0x6
    80001968:	f9078793          	addi	a5,a5,-112 # 800078f4 <nextpid>
    8000196c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000196e:	0014871b          	addiw	a4,s1,1
    80001972:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001974:	854a                	mv	a0,s2
    80001976:	b16ff0ef          	jal	80000c8c <release>
}
    8000197a:	8526                	mv	a0,s1
    8000197c:	60e2                	ld	ra,24(sp)
    8000197e:	6442                	ld	s0,16(sp)
    80001980:	64a2                	ld	s1,8(sp)
    80001982:	6902                	ld	s2,0(sp)
    80001984:	6105                	addi	sp,sp,32
    80001986:	8082                	ret

0000000080001988 <proc_pagetable>:
{
    80001988:	1101                	addi	sp,sp,-32
    8000198a:	ec06                	sd	ra,24(sp)
    8000198c:	e822                	sd	s0,16(sp)
    8000198e:	e426                	sd	s1,8(sp)
    80001990:	e04a                	sd	s2,0(sp)
    80001992:	1000                	addi	s0,sp,32
    80001994:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001996:	8e1ff0ef          	jal	80001276 <uvmcreate>
    8000199a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000199c:	cd05                	beqz	a0,800019d4 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000199e:	4729                	li	a4,10
    800019a0:	00004697          	auipc	a3,0x4
    800019a4:	66068693          	addi	a3,a3,1632 # 80006000 <_trampoline>
    800019a8:	6605                	lui	a2,0x1
    800019aa:	040005b7          	lui	a1,0x4000
    800019ae:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019b0:	05b2                	slli	a1,a1,0xc
    800019b2:	e62ff0ef          	jal	80001014 <mappages>
    800019b6:	02054663          	bltz	a0,800019e2 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019ba:	4719                	li	a4,6
    800019bc:	05893683          	ld	a3,88(s2)
    800019c0:	6605                	lui	a2,0x1
    800019c2:	020005b7          	lui	a1,0x2000
    800019c6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019c8:	05b6                	slli	a1,a1,0xd
    800019ca:	8526                	mv	a0,s1
    800019cc:	e48ff0ef          	jal	80001014 <mappages>
    800019d0:	00054f63          	bltz	a0,800019ee <proc_pagetable+0x66>
}
    800019d4:	8526                	mv	a0,s1
    800019d6:	60e2                	ld	ra,24(sp)
    800019d8:	6442                	ld	s0,16(sp)
    800019da:	64a2                	ld	s1,8(sp)
    800019dc:	6902                	ld	s2,0(sp)
    800019de:	6105                	addi	sp,sp,32
    800019e0:	8082                	ret
    uvmfree(pagetable, 0);
    800019e2:	4581                	li	a1,0
    800019e4:	8526                	mv	a0,s1
    800019e6:	a5fff0ef          	jal	80001444 <uvmfree>
    return 0;
    800019ea:	4481                	li	s1,0
    800019ec:	b7e5                	j	800019d4 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019ee:	4681                	li	a3,0
    800019f0:	4605                	li	a2,1
    800019f2:	040005b7          	lui	a1,0x4000
    800019f6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019f8:	05b2                	slli	a1,a1,0xc
    800019fa:	8526                	mv	a0,s1
    800019fc:	fbeff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001a00:	4581                	li	a1,0
    80001a02:	8526                	mv	a0,s1
    80001a04:	a41ff0ef          	jal	80001444 <uvmfree>
    return 0;
    80001a08:	4481                	li	s1,0
    80001a0a:	b7e9                	j	800019d4 <proc_pagetable+0x4c>

0000000080001a0c <proc_freepagetable>:
{
    80001a0c:	1101                	addi	sp,sp,-32
    80001a0e:	ec06                	sd	ra,24(sp)
    80001a10:	e822                	sd	s0,16(sp)
    80001a12:	e426                	sd	s1,8(sp)
    80001a14:	e04a                	sd	s2,0(sp)
    80001a16:	1000                	addi	s0,sp,32
    80001a18:	84aa                	mv	s1,a0
    80001a1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a1c:	4681                	li	a3,0
    80001a1e:	4605                	li	a2,1
    80001a20:	040005b7          	lui	a1,0x4000
    80001a24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a26:	05b2                	slli	a1,a1,0xc
    80001a28:	f92ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a2c:	4681                	li	a3,0
    80001a2e:	4605                	li	a2,1
    80001a30:	020005b7          	lui	a1,0x2000
    80001a34:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a36:	05b6                	slli	a1,a1,0xd
    80001a38:	8526                	mv	a0,s1
    80001a3a:	f80ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001a3e:	85ca                	mv	a1,s2
    80001a40:	8526                	mv	a0,s1
    80001a42:	a03ff0ef          	jal	80001444 <uvmfree>
}
    80001a46:	60e2                	ld	ra,24(sp)
    80001a48:	6442                	ld	s0,16(sp)
    80001a4a:	64a2                	ld	s1,8(sp)
    80001a4c:	6902                	ld	s2,0(sp)
    80001a4e:	6105                	addi	sp,sp,32
    80001a50:	8082                	ret

0000000080001a52 <freeproc>:
{
    80001a52:	1101                	addi	sp,sp,-32
    80001a54:	ec06                	sd	ra,24(sp)
    80001a56:	e822                	sd	s0,16(sp)
    80001a58:	e426                	sd	s1,8(sp)
    80001a5a:	1000                	addi	s0,sp,32
    80001a5c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a5e:	6d28                	ld	a0,88(a0)
    80001a60:	c119                	beqz	a0,80001a66 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a62:	fe1fe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001a66:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a6a:	68a8                	ld	a0,80(s1)
    80001a6c:	c501                	beqz	a0,80001a74 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a6e:	64ac                	ld	a1,72(s1)
    80001a70:	f9dff0ef          	jal	80001a0c <proc_freepagetable>
  p->pagetable = 0;
    80001a74:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a78:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a7c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a80:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a84:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a88:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a8c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a90:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a94:	0004ac23          	sw	zero,24(s1)
}
    80001a98:	60e2                	ld	ra,24(sp)
    80001a9a:	6442                	ld	s0,16(sp)
    80001a9c:	64a2                	ld	s1,8(sp)
    80001a9e:	6105                	addi	sp,sp,32
    80001aa0:	8082                	ret

0000000080001aa2 <allocproc>:
{
    80001aa2:	1101                	addi	sp,sp,-32
    80001aa4:	ec06                	sd	ra,24(sp)
    80001aa6:	e822                	sd	s0,16(sp)
    80001aa8:	e426                	sd	s1,8(sp)
    80001aaa:	e04a                	sd	s2,0(sp)
    80001aac:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aae:	0000e497          	auipc	s1,0xe
    80001ab2:	42248493          	addi	s1,s1,1058 # 8000fed0 <proc>
    80001ab6:	00014917          	auipc	s2,0x14
    80001aba:	e1a90913          	addi	s2,s2,-486 # 800158d0 <tickslock>
    acquire(&p->lock);
    80001abe:	8526                	mv	a0,s1
    80001ac0:	934ff0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    80001ac4:	4c9c                	lw	a5,24(s1)
    80001ac6:	cb91                	beqz	a5,80001ada <allocproc+0x38>
      release(&p->lock);
    80001ac8:	8526                	mv	a0,s1
    80001aca:	9c2ff0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ace:	16848493          	addi	s1,s1,360
    80001ad2:	ff2496e3          	bne	s1,s2,80001abe <allocproc+0x1c>
  return 0;
    80001ad6:	4481                	li	s1,0
    80001ad8:	a089                	j	80001b1a <allocproc+0x78>
  p->pid = allocpid();
    80001ada:	e71ff0ef          	jal	8000194a <allocpid>
    80001ade:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ae0:	4785                	li	a5,1
    80001ae2:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ae4:	840ff0ef          	jal	80000b24 <kalloc>
    80001ae8:	892a                	mv	s2,a0
    80001aea:	eca8                	sd	a0,88(s1)
    80001aec:	cd15                	beqz	a0,80001b28 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001aee:	8526                	mv	a0,s1
    80001af0:	e99ff0ef          	jal	80001988 <proc_pagetable>
    80001af4:	892a                	mv	s2,a0
    80001af6:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001af8:	c121                	beqz	a0,80001b38 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001afa:	07000613          	li	a2,112
    80001afe:	4581                	li	a1,0
    80001b00:	06048513          	addi	a0,s1,96
    80001b04:	9c4ff0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001b08:	00000797          	auipc	a5,0x0
    80001b0c:	e0878793          	addi	a5,a5,-504 # 80001910 <forkret>
    80001b10:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b12:	60bc                	ld	a5,64(s1)
    80001b14:	6705                	lui	a4,0x1
    80001b16:	97ba                	add	a5,a5,a4
    80001b18:	f4bc                	sd	a5,104(s1)
}
    80001b1a:	8526                	mv	a0,s1
    80001b1c:	60e2                	ld	ra,24(sp)
    80001b1e:	6442                	ld	s0,16(sp)
    80001b20:	64a2                	ld	s1,8(sp)
    80001b22:	6902                	ld	s2,0(sp)
    80001b24:	6105                	addi	sp,sp,32
    80001b26:	8082                	ret
    freeproc(p);
    80001b28:	8526                	mv	a0,s1
    80001b2a:	f29ff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b2e:	8526                	mv	a0,s1
    80001b30:	95cff0ef          	jal	80000c8c <release>
    return 0;
    80001b34:	84ca                	mv	s1,s2
    80001b36:	b7d5                	j	80001b1a <allocproc+0x78>
    freeproc(p);
    80001b38:	8526                	mv	a0,s1
    80001b3a:	f19ff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b3e:	8526                	mv	a0,s1
    80001b40:	94cff0ef          	jal	80000c8c <release>
    return 0;
    80001b44:	84ca                	mv	s1,s2
    80001b46:	bfd1                	j	80001b1a <allocproc+0x78>

0000000080001b48 <userinit>:
{
    80001b48:	1101                	addi	sp,sp,-32
    80001b4a:	ec06                	sd	ra,24(sp)
    80001b4c:	e822                	sd	s0,16(sp)
    80001b4e:	e426                	sd	s1,8(sp)
    80001b50:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b52:	f51ff0ef          	jal	80001aa2 <allocproc>
    80001b56:	84aa                	mv	s1,a0
  initproc = p;
    80001b58:	00006797          	auipc	a5,0x6
    80001b5c:	e0a7b823          	sd	a0,-496(a5) # 80007968 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b60:	03400613          	li	a2,52
    80001b64:	00006597          	auipc	a1,0x6
    80001b68:	d9c58593          	addi	a1,a1,-612 # 80007900 <initcode>
    80001b6c:	6928                	ld	a0,80(a0)
    80001b6e:	f2eff0ef          	jal	8000129c <uvmfirst>
  p->sz = PGSIZE;
    80001b72:	6785                	lui	a5,0x1
    80001b74:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001b76:	6cb8                	ld	a4,88(s1)
    80001b78:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001b7c:	6cb8                	ld	a4,88(s1)
    80001b7e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001b80:	4641                	li	a2,16
    80001b82:	00005597          	auipc	a1,0x5
    80001b86:	69e58593          	addi	a1,a1,1694 # 80007220 <etext+0x220>
    80001b8a:	15848513          	addi	a0,s1,344
    80001b8e:	a78ff0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001b92:	00005517          	auipc	a0,0x5
    80001b96:	69e50513          	addi	a0,a0,1694 # 80007230 <etext+0x230>
    80001b9a:	521010ef          	jal	800038ba <namei>
    80001b9e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ba2:	478d                	li	a5,3
    80001ba4:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	8e4ff0ef          	jal	80000c8c <release>
}
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6105                	addi	sp,sp,32
    80001bb4:	8082                	ret

0000000080001bb6 <growproc>:
{
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	e04a                	sd	s2,0(sp)
    80001bc0:	1000                	addi	s0,sp,32
    80001bc2:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bc4:	d1dff0ef          	jal	800018e0 <myproc>
    80001bc8:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bca:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bcc:	01204c63          	bgtz	s2,80001be4 <growproc+0x2e>
  } else if(n < 0){
    80001bd0:	02094463          	bltz	s2,80001bf8 <growproc+0x42>
  p->sz = sz;
    80001bd4:	e4ac                	sd	a1,72(s1)
  return 0;
    80001bd6:	4501                	li	a0,0
}
    80001bd8:	60e2                	ld	ra,24(sp)
    80001bda:	6442                	ld	s0,16(sp)
    80001bdc:	64a2                	ld	s1,8(sp)
    80001bde:	6902                	ld	s2,0(sp)
    80001be0:	6105                	addi	sp,sp,32
    80001be2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001be4:	4691                	li	a3,4
    80001be6:	00b90633          	add	a2,s2,a1
    80001bea:	6928                	ld	a0,80(a0)
    80001bec:	f52ff0ef          	jal	8000133e <uvmalloc>
    80001bf0:	85aa                	mv	a1,a0
    80001bf2:	f16d                	bnez	a0,80001bd4 <growproc+0x1e>
      return -1;
    80001bf4:	557d                	li	a0,-1
    80001bf6:	b7cd                	j	80001bd8 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001bf8:	00b90633          	add	a2,s2,a1
    80001bfc:	6928                	ld	a0,80(a0)
    80001bfe:	efcff0ef          	jal	800012fa <uvmdealloc>
    80001c02:	85aa                	mv	a1,a0
    80001c04:	bfc1                	j	80001bd4 <growproc+0x1e>

0000000080001c06 <fork>:
{
    80001c06:	7139                	addi	sp,sp,-64
    80001c08:	fc06                	sd	ra,56(sp)
    80001c0a:	f822                	sd	s0,48(sp)
    80001c0c:	f04a                	sd	s2,32(sp)
    80001c0e:	e456                	sd	s5,8(sp)
    80001c10:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c12:	ccfff0ef          	jal	800018e0 <myproc>
    80001c16:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c18:	e8bff0ef          	jal	80001aa2 <allocproc>
    80001c1c:	0e050a63          	beqz	a0,80001d10 <fork+0x10a>
    80001c20:	e852                	sd	s4,16(sp)
    80001c22:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c24:	048ab603          	ld	a2,72(s5)
    80001c28:	692c                	ld	a1,80(a0)
    80001c2a:	050ab503          	ld	a0,80(s5)
    80001c2e:	849ff0ef          	jal	80001476 <uvmcopy>
    80001c32:	04054a63          	bltz	a0,80001c86 <fork+0x80>
    80001c36:	f426                	sd	s1,40(sp)
    80001c38:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c3a:	048ab783          	ld	a5,72(s5)
    80001c3e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c42:	058ab683          	ld	a3,88(s5)
    80001c46:	87b6                	mv	a5,a3
    80001c48:	058a3703          	ld	a4,88(s4)
    80001c4c:	12068693          	addi	a3,a3,288
    80001c50:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c54:	6788                	ld	a0,8(a5)
    80001c56:	6b8c                	ld	a1,16(a5)
    80001c58:	6f90                	ld	a2,24(a5)
    80001c5a:	01073023          	sd	a6,0(a4)
    80001c5e:	e708                	sd	a0,8(a4)
    80001c60:	eb0c                	sd	a1,16(a4)
    80001c62:	ef10                	sd	a2,24(a4)
    80001c64:	02078793          	addi	a5,a5,32
    80001c68:	02070713          	addi	a4,a4,32
    80001c6c:	fed792e3          	bne	a5,a3,80001c50 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001c70:	058a3783          	ld	a5,88(s4)
    80001c74:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c78:	0d0a8493          	addi	s1,s5,208
    80001c7c:	0d0a0913          	addi	s2,s4,208
    80001c80:	150a8993          	addi	s3,s5,336
    80001c84:	a831                	j	80001ca0 <fork+0x9a>
    freeproc(np);
    80001c86:	8552                	mv	a0,s4
    80001c88:	dcbff0ef          	jal	80001a52 <freeproc>
    release(&np->lock);
    80001c8c:	8552                	mv	a0,s4
    80001c8e:	ffffe0ef          	jal	80000c8c <release>
    return -1;
    80001c92:	597d                	li	s2,-1
    80001c94:	6a42                	ld	s4,16(sp)
    80001c96:	a0b5                	j	80001d02 <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001c98:	04a1                	addi	s1,s1,8
    80001c9a:	0921                	addi	s2,s2,8
    80001c9c:	01348963          	beq	s1,s3,80001cae <fork+0xa8>
    if(p->ofile[i])
    80001ca0:	6088                	ld	a0,0(s1)
    80001ca2:	d97d                	beqz	a0,80001c98 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ca4:	1a6020ef          	jal	80003e4a <filedup>
    80001ca8:	00a93023          	sd	a0,0(s2)
    80001cac:	b7f5                	j	80001c98 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001cae:	150ab503          	ld	a0,336(s5)
    80001cb2:	4f8010ef          	jal	800031aa <idup>
    80001cb6:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cba:	4641                	li	a2,16
    80001cbc:	158a8593          	addi	a1,s5,344
    80001cc0:	158a0513          	addi	a0,s4,344
    80001cc4:	942ff0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    80001cc8:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001ccc:	8552                	mv	a0,s4
    80001cce:	fbffe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001cd2:	0000e497          	auipc	s1,0xe
    80001cd6:	de648493          	addi	s1,s1,-538 # 8000fab8 <wait_lock>
    80001cda:	8526                	mv	a0,s1
    80001cdc:	f19fe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80001ce0:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	fa7fe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001cea:	8552                	mv	a0,s4
    80001cec:	f09fe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80001cf0:	478d                	li	a5,3
    80001cf2:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001cf6:	8552                	mv	a0,s4
    80001cf8:	f95fe0ef          	jal	80000c8c <release>
  return pid;
    80001cfc:	74a2                	ld	s1,40(sp)
    80001cfe:	69e2                	ld	s3,24(sp)
    80001d00:	6a42                	ld	s4,16(sp)
}
    80001d02:	854a                	mv	a0,s2
    80001d04:	70e2                	ld	ra,56(sp)
    80001d06:	7442                	ld	s0,48(sp)
    80001d08:	7902                	ld	s2,32(sp)
    80001d0a:	6aa2                	ld	s5,8(sp)
    80001d0c:	6121                	addi	sp,sp,64
    80001d0e:	8082                	ret
    return -1;
    80001d10:	597d                	li	s2,-1
    80001d12:	bfc5                	j	80001d02 <fork+0xfc>

0000000080001d14 <scheduler>:
{
    80001d14:	715d                	addi	sp,sp,-80
    80001d16:	e486                	sd	ra,72(sp)
    80001d18:	e0a2                	sd	s0,64(sp)
    80001d1a:	fc26                	sd	s1,56(sp)
    80001d1c:	f84a                	sd	s2,48(sp)
    80001d1e:	f44e                	sd	s3,40(sp)
    80001d20:	f052                	sd	s4,32(sp)
    80001d22:	ec56                	sd	s5,24(sp)
    80001d24:	e85a                	sd	s6,16(sp)
    80001d26:	e45e                	sd	s7,8(sp)
    80001d28:	e062                	sd	s8,0(sp)
    80001d2a:	0880                	addi	s0,sp,80
    80001d2c:	8792                	mv	a5,tp
  int id = r_tp();
    80001d2e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d30:	00779b13          	slli	s6,a5,0x7
    80001d34:	0000e717          	auipc	a4,0xe
    80001d38:	d6c70713          	addi	a4,a4,-660 # 8000faa0 <pid_lock>
    80001d3c:	975a                	add	a4,a4,s6
    80001d3e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d42:	0000e717          	auipc	a4,0xe
    80001d46:	d9670713          	addi	a4,a4,-618 # 8000fad8 <cpus+0x8>
    80001d4a:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d4c:	4c11                	li	s8,4
        c->proc = p;
    80001d4e:	079e                	slli	a5,a5,0x7
    80001d50:	0000ea17          	auipc	s4,0xe
    80001d54:	d50a0a13          	addi	s4,s4,-688 # 8000faa0 <pid_lock>
    80001d58:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d5a:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d5c:	00014997          	auipc	s3,0x14
    80001d60:	b7498993          	addi	s3,s3,-1164 # 800158d0 <tickslock>
    80001d64:	a0a9                	j	80001dae <scheduler+0x9a>
      release(&p->lock);
    80001d66:	8526                	mv	a0,s1
    80001d68:	f25fe0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d6c:	16848493          	addi	s1,s1,360
    80001d70:	03348563          	beq	s1,s3,80001d9a <scheduler+0x86>
      acquire(&p->lock);
    80001d74:	8526                	mv	a0,s1
    80001d76:	e7ffe0ef          	jal	80000bf4 <acquire>
      if(p->state == RUNNABLE) {
    80001d7a:	4c9c                	lw	a5,24(s1)
    80001d7c:	ff2795e3          	bne	a5,s2,80001d66 <scheduler+0x52>
        p->state = RUNNING;
    80001d80:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001d84:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001d88:	06048593          	addi	a1,s1,96
    80001d8c:	855a                	mv	a0,s6
    80001d8e:	5b4000ef          	jal	80002342 <swtch>
        c->proc = 0;
    80001d92:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001d96:	8ade                	mv	s5,s7
    80001d98:	b7f9                	j	80001d66 <scheduler+0x52>
    if(found == 0) {
    80001d9a:	000a9a63          	bnez	s5,80001dae <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d9e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001da2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001da6:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001daa:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dae:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001db2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001db6:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001dba:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dbc:	0000e497          	auipc	s1,0xe
    80001dc0:	11448493          	addi	s1,s1,276 # 8000fed0 <proc>
      if(p->state == RUNNABLE) {
    80001dc4:	490d                	li	s2,3
    80001dc6:	b77d                	j	80001d74 <scheduler+0x60>

0000000080001dc8 <sched>:
{
    80001dc8:	7179                	addi	sp,sp,-48
    80001dca:	f406                	sd	ra,40(sp)
    80001dcc:	f022                	sd	s0,32(sp)
    80001dce:	ec26                	sd	s1,24(sp)
    80001dd0:	e84a                	sd	s2,16(sp)
    80001dd2:	e44e                	sd	s3,8(sp)
    80001dd4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dd6:	b0bff0ef          	jal	800018e0 <myproc>
    80001dda:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001ddc:	daffe0ef          	jal	80000b8a <holding>
    80001de0:	c92d                	beqz	a0,80001e52 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001de2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001de4:	2781                	sext.w	a5,a5
    80001de6:	079e                	slli	a5,a5,0x7
    80001de8:	0000e717          	auipc	a4,0xe
    80001dec:	cb870713          	addi	a4,a4,-840 # 8000faa0 <pid_lock>
    80001df0:	97ba                	add	a5,a5,a4
    80001df2:	0a87a703          	lw	a4,168(a5)
    80001df6:	4785                	li	a5,1
    80001df8:	06f71363          	bne	a4,a5,80001e5e <sched+0x96>
  if(p->state == RUNNING)
    80001dfc:	4c98                	lw	a4,24(s1)
    80001dfe:	4791                	li	a5,4
    80001e00:	06f70563          	beq	a4,a5,80001e6a <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e04:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e08:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e0a:	e7b5                	bnez	a5,80001e76 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e0c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e0e:	0000e917          	auipc	s2,0xe
    80001e12:	c9290913          	addi	s2,s2,-878 # 8000faa0 <pid_lock>
    80001e16:	2781                	sext.w	a5,a5
    80001e18:	079e                	slli	a5,a5,0x7
    80001e1a:	97ca                	add	a5,a5,s2
    80001e1c:	0ac7a983          	lw	s3,172(a5)
    80001e20:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e22:	2781                	sext.w	a5,a5
    80001e24:	079e                	slli	a5,a5,0x7
    80001e26:	0000e597          	auipc	a1,0xe
    80001e2a:	cb258593          	addi	a1,a1,-846 # 8000fad8 <cpus+0x8>
    80001e2e:	95be                	add	a1,a1,a5
    80001e30:	06048513          	addi	a0,s1,96
    80001e34:	50e000ef          	jal	80002342 <swtch>
    80001e38:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e3a:	2781                	sext.w	a5,a5
    80001e3c:	079e                	slli	a5,a5,0x7
    80001e3e:	993e                	add	s2,s2,a5
    80001e40:	0b392623          	sw	s3,172(s2)
}
    80001e44:	70a2                	ld	ra,40(sp)
    80001e46:	7402                	ld	s0,32(sp)
    80001e48:	64e2                	ld	s1,24(sp)
    80001e4a:	6942                	ld	s2,16(sp)
    80001e4c:	69a2                	ld	s3,8(sp)
    80001e4e:	6145                	addi	sp,sp,48
    80001e50:	8082                	ret
    panic("sched p->lock");
    80001e52:	00005517          	auipc	a0,0x5
    80001e56:	3e650513          	addi	a0,a0,998 # 80007238 <etext+0x238>
    80001e5a:	93bfe0ef          	jal	80000794 <panic>
    panic("sched locks");
    80001e5e:	00005517          	auipc	a0,0x5
    80001e62:	3ea50513          	addi	a0,a0,1002 # 80007248 <etext+0x248>
    80001e66:	92ffe0ef          	jal	80000794 <panic>
    panic("sched running");
    80001e6a:	00005517          	auipc	a0,0x5
    80001e6e:	3ee50513          	addi	a0,a0,1006 # 80007258 <etext+0x258>
    80001e72:	923fe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    80001e76:	00005517          	auipc	a0,0x5
    80001e7a:	3f250513          	addi	a0,a0,1010 # 80007268 <etext+0x268>
    80001e7e:	917fe0ef          	jal	80000794 <panic>

0000000080001e82 <yield>:
{
    80001e82:	1101                	addi	sp,sp,-32
    80001e84:	ec06                	sd	ra,24(sp)
    80001e86:	e822                	sd	s0,16(sp)
    80001e88:	e426                	sd	s1,8(sp)
    80001e8a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001e8c:	a55ff0ef          	jal	800018e0 <myproc>
    80001e90:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001e92:	d63fe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    80001e96:	478d                	li	a5,3
    80001e98:	cc9c                	sw	a5,24(s1)
  sched();
    80001e9a:	f2fff0ef          	jal	80001dc8 <sched>
  release(&p->lock);
    80001e9e:	8526                	mv	a0,s1
    80001ea0:	dedfe0ef          	jal	80000c8c <release>
}
    80001ea4:	60e2                	ld	ra,24(sp)
    80001ea6:	6442                	ld	s0,16(sp)
    80001ea8:	64a2                	ld	s1,8(sp)
    80001eaa:	6105                	addi	sp,sp,32
    80001eac:	8082                	ret

0000000080001eae <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001eae:	7179                	addi	sp,sp,-48
    80001eb0:	f406                	sd	ra,40(sp)
    80001eb2:	f022                	sd	s0,32(sp)
    80001eb4:	ec26                	sd	s1,24(sp)
    80001eb6:	e84a                	sd	s2,16(sp)
    80001eb8:	e44e                	sd	s3,8(sp)
    80001eba:	1800                	addi	s0,sp,48
    80001ebc:	89aa                	mv	s3,a0
    80001ebe:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ec0:	a21ff0ef          	jal	800018e0 <myproc>
    80001ec4:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001ec6:	d2ffe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80001eca:	854a                	mv	a0,s2
    80001ecc:	dc1fe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    80001ed0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001ed4:	4789                	li	a5,2
    80001ed6:	cc9c                	sw	a5,24(s1)

  sched();
    80001ed8:	ef1ff0ef          	jal	80001dc8 <sched>

  // Tidy up.
  p->chan = 0;
    80001edc:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001ee0:	8526                	mv	a0,s1
    80001ee2:	dabfe0ef          	jal	80000c8c <release>
  acquire(lk);
    80001ee6:	854a                	mv	a0,s2
    80001ee8:	d0dfe0ef          	jal	80000bf4 <acquire>
}
    80001eec:	70a2                	ld	ra,40(sp)
    80001eee:	7402                	ld	s0,32(sp)
    80001ef0:	64e2                	ld	s1,24(sp)
    80001ef2:	6942                	ld	s2,16(sp)
    80001ef4:	69a2                	ld	s3,8(sp)
    80001ef6:	6145                	addi	sp,sp,48
    80001ef8:	8082                	ret

0000000080001efa <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001efa:	7139                	addi	sp,sp,-64
    80001efc:	fc06                	sd	ra,56(sp)
    80001efe:	f822                	sd	s0,48(sp)
    80001f00:	f426                	sd	s1,40(sp)
    80001f02:	f04a                	sd	s2,32(sp)
    80001f04:	ec4e                	sd	s3,24(sp)
    80001f06:	e852                	sd	s4,16(sp)
    80001f08:	e456                	sd	s5,8(sp)
    80001f0a:	0080                	addi	s0,sp,64
    80001f0c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f0e:	0000e497          	auipc	s1,0xe
    80001f12:	fc248493          	addi	s1,s1,-62 # 8000fed0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f16:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f18:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f1a:	00014917          	auipc	s2,0x14
    80001f1e:	9b690913          	addi	s2,s2,-1610 # 800158d0 <tickslock>
    80001f22:	a801                	j	80001f32 <wakeup+0x38>
      }
      release(&p->lock);
    80001f24:	8526                	mv	a0,s1
    80001f26:	d67fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f2a:	16848493          	addi	s1,s1,360
    80001f2e:	03248263          	beq	s1,s2,80001f52 <wakeup+0x58>
    if(p != myproc()){
    80001f32:	9afff0ef          	jal	800018e0 <myproc>
    80001f36:	fea48ae3          	beq	s1,a0,80001f2a <wakeup+0x30>
      acquire(&p->lock);
    80001f3a:	8526                	mv	a0,s1
    80001f3c:	cb9fe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f40:	4c9c                	lw	a5,24(s1)
    80001f42:	ff3791e3          	bne	a5,s3,80001f24 <wakeup+0x2a>
    80001f46:	709c                	ld	a5,32(s1)
    80001f48:	fd479ee3          	bne	a5,s4,80001f24 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f4c:	0154ac23          	sw	s5,24(s1)
    80001f50:	bfd1                	j	80001f24 <wakeup+0x2a>
    }
  }
}
    80001f52:	70e2                	ld	ra,56(sp)
    80001f54:	7442                	ld	s0,48(sp)
    80001f56:	74a2                	ld	s1,40(sp)
    80001f58:	7902                	ld	s2,32(sp)
    80001f5a:	69e2                	ld	s3,24(sp)
    80001f5c:	6a42                	ld	s4,16(sp)
    80001f5e:	6aa2                	ld	s5,8(sp)
    80001f60:	6121                	addi	sp,sp,64
    80001f62:	8082                	ret

0000000080001f64 <reparent>:
{
    80001f64:	7179                	addi	sp,sp,-48
    80001f66:	f406                	sd	ra,40(sp)
    80001f68:	f022                	sd	s0,32(sp)
    80001f6a:	ec26                	sd	s1,24(sp)
    80001f6c:	e84a                	sd	s2,16(sp)
    80001f6e:	e44e                	sd	s3,8(sp)
    80001f70:	e052                	sd	s4,0(sp)
    80001f72:	1800                	addi	s0,sp,48
    80001f74:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f76:	0000e497          	auipc	s1,0xe
    80001f7a:	f5a48493          	addi	s1,s1,-166 # 8000fed0 <proc>
      pp->parent = initproc;
    80001f7e:	00006a17          	auipc	s4,0x6
    80001f82:	9eaa0a13          	addi	s4,s4,-1558 # 80007968 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f86:	00014997          	auipc	s3,0x14
    80001f8a:	94a98993          	addi	s3,s3,-1718 # 800158d0 <tickslock>
    80001f8e:	a029                	j	80001f98 <reparent+0x34>
    80001f90:	16848493          	addi	s1,s1,360
    80001f94:	01348b63          	beq	s1,s3,80001faa <reparent+0x46>
    if(pp->parent == p){
    80001f98:	7c9c                	ld	a5,56(s1)
    80001f9a:	ff279be3          	bne	a5,s2,80001f90 <reparent+0x2c>
      pp->parent = initproc;
    80001f9e:	000a3503          	ld	a0,0(s4)
    80001fa2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fa4:	f57ff0ef          	jal	80001efa <wakeup>
    80001fa8:	b7e5                	j	80001f90 <reparent+0x2c>
}
    80001faa:	70a2                	ld	ra,40(sp)
    80001fac:	7402                	ld	s0,32(sp)
    80001fae:	64e2                	ld	s1,24(sp)
    80001fb0:	6942                	ld	s2,16(sp)
    80001fb2:	69a2                	ld	s3,8(sp)
    80001fb4:	6a02                	ld	s4,0(sp)
    80001fb6:	6145                	addi	sp,sp,48
    80001fb8:	8082                	ret

0000000080001fba <exit>:
{
    80001fba:	7179                	addi	sp,sp,-48
    80001fbc:	f406                	sd	ra,40(sp)
    80001fbe:	f022                	sd	s0,32(sp)
    80001fc0:	ec26                	sd	s1,24(sp)
    80001fc2:	e84a                	sd	s2,16(sp)
    80001fc4:	e44e                	sd	s3,8(sp)
    80001fc6:	e052                	sd	s4,0(sp)
    80001fc8:	1800                	addi	s0,sp,48
    80001fca:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001fcc:	915ff0ef          	jal	800018e0 <myproc>
    80001fd0:	89aa                	mv	s3,a0
  if(p == initproc)
    80001fd2:	00006797          	auipc	a5,0x6
    80001fd6:	9967b783          	ld	a5,-1642(a5) # 80007968 <initproc>
    80001fda:	0d050493          	addi	s1,a0,208
    80001fde:	15050913          	addi	s2,a0,336
    80001fe2:	00a79f63          	bne	a5,a0,80002000 <exit+0x46>
    panic("init exiting");
    80001fe6:	00005517          	auipc	a0,0x5
    80001fea:	29a50513          	addi	a0,a0,666 # 80007280 <etext+0x280>
    80001fee:	fa6fe0ef          	jal	80000794 <panic>
      fileclose(f);
    80001ff2:	69f010ef          	jal	80003e90 <fileclose>
      p->ofile[fd] = 0;
    80001ff6:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001ffa:	04a1                	addi	s1,s1,8
    80001ffc:	01248563          	beq	s1,s2,80002006 <exit+0x4c>
    if(p->ofile[fd]){
    80002000:	6088                	ld	a0,0(s1)
    80002002:	f965                	bnez	a0,80001ff2 <exit+0x38>
    80002004:	bfdd                	j	80001ffa <exit+0x40>
  begin_op();
    80002006:	271010ef          	jal	80003a76 <begin_op>
  iput(p->cwd);
    8000200a:	1509b503          	ld	a0,336(s3)
    8000200e:	354010ef          	jal	80003362 <iput>
  end_op();
    80002012:	2cf010ef          	jal	80003ae0 <end_op>
  p->cwd = 0;
    80002016:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000201a:	0000e497          	auipc	s1,0xe
    8000201e:	a9e48493          	addi	s1,s1,-1378 # 8000fab8 <wait_lock>
    80002022:	8526                	mv	a0,s1
    80002024:	bd1fe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    80002028:	854e                	mv	a0,s3
    8000202a:	f3bff0ef          	jal	80001f64 <reparent>
  wakeup(p->parent);
    8000202e:	0389b503          	ld	a0,56(s3)
    80002032:	ec9ff0ef          	jal	80001efa <wakeup>
  acquire(&p->lock);
    80002036:	854e                	mv	a0,s3
    80002038:	bbdfe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    8000203c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002040:	4795                	li	a5,5
    80002042:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002046:	8526                	mv	a0,s1
    80002048:	c45fe0ef          	jal	80000c8c <release>
  sched();
    8000204c:	d7dff0ef          	jal	80001dc8 <sched>
  panic("zombie exit");
    80002050:	00005517          	auipc	a0,0x5
    80002054:	24050513          	addi	a0,a0,576 # 80007290 <etext+0x290>
    80002058:	f3cfe0ef          	jal	80000794 <panic>

000000008000205c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000205c:	7179                	addi	sp,sp,-48
    8000205e:	f406                	sd	ra,40(sp)
    80002060:	f022                	sd	s0,32(sp)
    80002062:	ec26                	sd	s1,24(sp)
    80002064:	e84a                	sd	s2,16(sp)
    80002066:	e44e                	sd	s3,8(sp)
    80002068:	1800                	addi	s0,sp,48
    8000206a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000206c:	0000e497          	auipc	s1,0xe
    80002070:	e6448493          	addi	s1,s1,-412 # 8000fed0 <proc>
    80002074:	00014997          	auipc	s3,0x14
    80002078:	85c98993          	addi	s3,s3,-1956 # 800158d0 <tickslock>
    acquire(&p->lock);
    8000207c:	8526                	mv	a0,s1
    8000207e:	b77fe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    80002082:	589c                	lw	a5,48(s1)
    80002084:	01278b63          	beq	a5,s2,8000209a <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002088:	8526                	mv	a0,s1
    8000208a:	c03fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000208e:	16848493          	addi	s1,s1,360
    80002092:	ff3495e3          	bne	s1,s3,8000207c <kill+0x20>
  }
  return -1;
    80002096:	557d                	li	a0,-1
    80002098:	a819                	j	800020ae <kill+0x52>
      p->killed = 1;
    8000209a:	4785                	li	a5,1
    8000209c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000209e:	4c98                	lw	a4,24(s1)
    800020a0:	4789                	li	a5,2
    800020a2:	00f70d63          	beq	a4,a5,800020bc <kill+0x60>
      release(&p->lock);
    800020a6:	8526                	mv	a0,s1
    800020a8:	be5fe0ef          	jal	80000c8c <release>
      return 0;
    800020ac:	4501                	li	a0,0
}
    800020ae:	70a2                	ld	ra,40(sp)
    800020b0:	7402                	ld	s0,32(sp)
    800020b2:	64e2                	ld	s1,24(sp)
    800020b4:	6942                	ld	s2,16(sp)
    800020b6:	69a2                	ld	s3,8(sp)
    800020b8:	6145                	addi	sp,sp,48
    800020ba:	8082                	ret
        p->state = RUNNABLE;
    800020bc:	478d                	li	a5,3
    800020be:	cc9c                	sw	a5,24(s1)
    800020c0:	b7dd                	j	800020a6 <kill+0x4a>

00000000800020c2 <setkilled>:

void
setkilled(struct proc *p)
{
    800020c2:	1101                	addi	sp,sp,-32
    800020c4:	ec06                	sd	ra,24(sp)
    800020c6:	e822                	sd	s0,16(sp)
    800020c8:	e426                	sd	s1,8(sp)
    800020ca:	1000                	addi	s0,sp,32
    800020cc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020ce:	b27fe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    800020d2:	4785                	li	a5,1
    800020d4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020d6:	8526                	mv	a0,s1
    800020d8:	bb5fe0ef          	jal	80000c8c <release>
}
    800020dc:	60e2                	ld	ra,24(sp)
    800020de:	6442                	ld	s0,16(sp)
    800020e0:	64a2                	ld	s1,8(sp)
    800020e2:	6105                	addi	sp,sp,32
    800020e4:	8082                	ret

00000000800020e6 <killed>:

int
killed(struct proc *p)
{
    800020e6:	1101                	addi	sp,sp,-32
    800020e8:	ec06                	sd	ra,24(sp)
    800020ea:	e822                	sd	s0,16(sp)
    800020ec:	e426                	sd	s1,8(sp)
    800020ee:	e04a                	sd	s2,0(sp)
    800020f0:	1000                	addi	s0,sp,32
    800020f2:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800020f4:	b01fe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    800020f8:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800020fc:	8526                	mv	a0,s1
    800020fe:	b8ffe0ef          	jal	80000c8c <release>
  return k;
}
    80002102:	854a                	mv	a0,s2
    80002104:	60e2                	ld	ra,24(sp)
    80002106:	6442                	ld	s0,16(sp)
    80002108:	64a2                	ld	s1,8(sp)
    8000210a:	6902                	ld	s2,0(sp)
    8000210c:	6105                	addi	sp,sp,32
    8000210e:	8082                	ret

0000000080002110 <wait>:
{
    80002110:	715d                	addi	sp,sp,-80
    80002112:	e486                	sd	ra,72(sp)
    80002114:	e0a2                	sd	s0,64(sp)
    80002116:	fc26                	sd	s1,56(sp)
    80002118:	f84a                	sd	s2,48(sp)
    8000211a:	f44e                	sd	s3,40(sp)
    8000211c:	f052                	sd	s4,32(sp)
    8000211e:	ec56                	sd	s5,24(sp)
    80002120:	e85a                	sd	s6,16(sp)
    80002122:	e45e                	sd	s7,8(sp)
    80002124:	e062                	sd	s8,0(sp)
    80002126:	0880                	addi	s0,sp,80
    80002128:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000212a:	fb6ff0ef          	jal	800018e0 <myproc>
    8000212e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002130:	0000e517          	auipc	a0,0xe
    80002134:	98850513          	addi	a0,a0,-1656 # 8000fab8 <wait_lock>
    80002138:	abdfe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    8000213c:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000213e:	4a15                	li	s4,5
        havekids = 1;
    80002140:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002142:	00013997          	auipc	s3,0x13
    80002146:	78e98993          	addi	s3,s3,1934 # 800158d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000214a:	0000ec17          	auipc	s8,0xe
    8000214e:	96ec0c13          	addi	s8,s8,-1682 # 8000fab8 <wait_lock>
    80002152:	a871                	j	800021ee <wait+0xde>
          pid = pp->pid;
    80002154:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002158:	000b0c63          	beqz	s6,80002170 <wait+0x60>
    8000215c:	4691                	li	a3,4
    8000215e:	02c48613          	addi	a2,s1,44
    80002162:	85da                	mv	a1,s6
    80002164:	05093503          	ld	a0,80(s2)
    80002168:	beaff0ef          	jal	80001552 <copyout>
    8000216c:	02054b63          	bltz	a0,800021a2 <wait+0x92>
          freeproc(pp);
    80002170:	8526                	mv	a0,s1
    80002172:	8e1ff0ef          	jal	80001a52 <freeproc>
          release(&pp->lock);
    80002176:	8526                	mv	a0,s1
    80002178:	b15fe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    8000217c:	0000e517          	auipc	a0,0xe
    80002180:	93c50513          	addi	a0,a0,-1732 # 8000fab8 <wait_lock>
    80002184:	b09fe0ef          	jal	80000c8c <release>
}
    80002188:	854e                	mv	a0,s3
    8000218a:	60a6                	ld	ra,72(sp)
    8000218c:	6406                	ld	s0,64(sp)
    8000218e:	74e2                	ld	s1,56(sp)
    80002190:	7942                	ld	s2,48(sp)
    80002192:	79a2                	ld	s3,40(sp)
    80002194:	7a02                	ld	s4,32(sp)
    80002196:	6ae2                	ld	s5,24(sp)
    80002198:	6b42                	ld	s6,16(sp)
    8000219a:	6ba2                	ld	s7,8(sp)
    8000219c:	6c02                	ld	s8,0(sp)
    8000219e:	6161                	addi	sp,sp,80
    800021a0:	8082                	ret
            release(&pp->lock);
    800021a2:	8526                	mv	a0,s1
    800021a4:	ae9fe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    800021a8:	0000e517          	auipc	a0,0xe
    800021ac:	91050513          	addi	a0,a0,-1776 # 8000fab8 <wait_lock>
    800021b0:	addfe0ef          	jal	80000c8c <release>
            return -1;
    800021b4:	59fd                	li	s3,-1
    800021b6:	bfc9                	j	80002188 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021b8:	16848493          	addi	s1,s1,360
    800021bc:	03348063          	beq	s1,s3,800021dc <wait+0xcc>
      if(pp->parent == p){
    800021c0:	7c9c                	ld	a5,56(s1)
    800021c2:	ff279be3          	bne	a5,s2,800021b8 <wait+0xa8>
        acquire(&pp->lock);
    800021c6:	8526                	mv	a0,s1
    800021c8:	a2dfe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    800021cc:	4c9c                	lw	a5,24(s1)
    800021ce:	f94783e3          	beq	a5,s4,80002154 <wait+0x44>
        release(&pp->lock);
    800021d2:	8526                	mv	a0,s1
    800021d4:	ab9fe0ef          	jal	80000c8c <release>
        havekids = 1;
    800021d8:	8756                	mv	a4,s5
    800021da:	bff9                	j	800021b8 <wait+0xa8>
    if(!havekids || killed(p)){
    800021dc:	cf19                	beqz	a4,800021fa <wait+0xea>
    800021de:	854a                	mv	a0,s2
    800021e0:	f07ff0ef          	jal	800020e6 <killed>
    800021e4:	e919                	bnez	a0,800021fa <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021e6:	85e2                	mv	a1,s8
    800021e8:	854a                	mv	a0,s2
    800021ea:	cc5ff0ef          	jal	80001eae <sleep>
    havekids = 0;
    800021ee:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021f0:	0000e497          	auipc	s1,0xe
    800021f4:	ce048493          	addi	s1,s1,-800 # 8000fed0 <proc>
    800021f8:	b7e1                	j	800021c0 <wait+0xb0>
      release(&wait_lock);
    800021fa:	0000e517          	auipc	a0,0xe
    800021fe:	8be50513          	addi	a0,a0,-1858 # 8000fab8 <wait_lock>
    80002202:	a8bfe0ef          	jal	80000c8c <release>
      return -1;
    80002206:	59fd                	li	s3,-1
    80002208:	b741                	j	80002188 <wait+0x78>

000000008000220a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000220a:	7179                	addi	sp,sp,-48
    8000220c:	f406                	sd	ra,40(sp)
    8000220e:	f022                	sd	s0,32(sp)
    80002210:	ec26                	sd	s1,24(sp)
    80002212:	e84a                	sd	s2,16(sp)
    80002214:	e44e                	sd	s3,8(sp)
    80002216:	e052                	sd	s4,0(sp)
    80002218:	1800                	addi	s0,sp,48
    8000221a:	84aa                	mv	s1,a0
    8000221c:	892e                	mv	s2,a1
    8000221e:	89b2                	mv	s3,a2
    80002220:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002222:	ebeff0ef          	jal	800018e0 <myproc>
  if(user_dst){
    80002226:	cc99                	beqz	s1,80002244 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002228:	86d2                	mv	a3,s4
    8000222a:	864e                	mv	a2,s3
    8000222c:	85ca                	mv	a1,s2
    8000222e:	6928                	ld	a0,80(a0)
    80002230:	b22ff0ef          	jal	80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002234:	70a2                	ld	ra,40(sp)
    80002236:	7402                	ld	s0,32(sp)
    80002238:	64e2                	ld	s1,24(sp)
    8000223a:	6942                	ld	s2,16(sp)
    8000223c:	69a2                	ld	s3,8(sp)
    8000223e:	6a02                	ld	s4,0(sp)
    80002240:	6145                	addi	sp,sp,48
    80002242:	8082                	ret
    memmove((char *)dst, src, len);
    80002244:	000a061b          	sext.w	a2,s4
    80002248:	85ce                	mv	a1,s3
    8000224a:	854a                	mv	a0,s2
    8000224c:	ad9fe0ef          	jal	80000d24 <memmove>
    return 0;
    80002250:	8526                	mv	a0,s1
    80002252:	b7cd                	j	80002234 <either_copyout+0x2a>

0000000080002254 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002254:	7179                	addi	sp,sp,-48
    80002256:	f406                	sd	ra,40(sp)
    80002258:	f022                	sd	s0,32(sp)
    8000225a:	ec26                	sd	s1,24(sp)
    8000225c:	e84a                	sd	s2,16(sp)
    8000225e:	e44e                	sd	s3,8(sp)
    80002260:	e052                	sd	s4,0(sp)
    80002262:	1800                	addi	s0,sp,48
    80002264:	892a                	mv	s2,a0
    80002266:	84ae                	mv	s1,a1
    80002268:	89b2                	mv	s3,a2
    8000226a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000226c:	e74ff0ef          	jal	800018e0 <myproc>
  if(user_src){
    80002270:	cc99                	beqz	s1,8000228e <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002272:	86d2                	mv	a3,s4
    80002274:	864e                	mv	a2,s3
    80002276:	85ca                	mv	a1,s2
    80002278:	6928                	ld	a0,80(a0)
    8000227a:	baeff0ef          	jal	80001628 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000227e:	70a2                	ld	ra,40(sp)
    80002280:	7402                	ld	s0,32(sp)
    80002282:	64e2                	ld	s1,24(sp)
    80002284:	6942                	ld	s2,16(sp)
    80002286:	69a2                	ld	s3,8(sp)
    80002288:	6a02                	ld	s4,0(sp)
    8000228a:	6145                	addi	sp,sp,48
    8000228c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000228e:	000a061b          	sext.w	a2,s4
    80002292:	85ce                	mv	a1,s3
    80002294:	854a                	mv	a0,s2
    80002296:	a8ffe0ef          	jal	80000d24 <memmove>
    return 0;
    8000229a:	8526                	mv	a0,s1
    8000229c:	b7cd                	j	8000227e <either_copyin+0x2a>

000000008000229e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000229e:	715d                	addi	sp,sp,-80
    800022a0:	e486                	sd	ra,72(sp)
    800022a2:	e0a2                	sd	s0,64(sp)
    800022a4:	fc26                	sd	s1,56(sp)
    800022a6:	f84a                	sd	s2,48(sp)
    800022a8:	f44e                	sd	s3,40(sp)
    800022aa:	f052                	sd	s4,32(sp)
    800022ac:	ec56                	sd	s5,24(sp)
    800022ae:	e85a                	sd	s6,16(sp)
    800022b0:	e45e                	sd	s7,8(sp)
    800022b2:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022b4:	00005517          	auipc	a0,0x5
    800022b8:	dc450513          	addi	a0,a0,-572 # 80007078 <etext+0x78>
    800022bc:	a06fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022c0:	0000e497          	auipc	s1,0xe
    800022c4:	d6848493          	addi	s1,s1,-664 # 80010028 <proc+0x158>
    800022c8:	00013917          	auipc	s2,0x13
    800022cc:	76090913          	addi	s2,s2,1888 # 80015a28 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022d0:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022d2:	00005997          	auipc	s3,0x5
    800022d6:	fce98993          	addi	s3,s3,-50 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    800022da:	00005a97          	auipc	s5,0x5
    800022de:	fcea8a93          	addi	s5,s5,-50 # 800072a8 <etext+0x2a8>
    printf("\n");
    800022e2:	00005a17          	auipc	s4,0x5
    800022e6:	d96a0a13          	addi	s4,s4,-618 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022ea:	00005b97          	auipc	s7,0x5
    800022ee:	4feb8b93          	addi	s7,s7,1278 # 800077e8 <states.0>
    800022f2:	a829                	j	8000230c <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800022f4:	ed86a583          	lw	a1,-296(a3)
    800022f8:	8556                	mv	a0,s5
    800022fa:	9c8fe0ef          	jal	800004c2 <printf>
    printf("\n");
    800022fe:	8552                	mv	a0,s4
    80002300:	9c2fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002304:	16848493          	addi	s1,s1,360
    80002308:	03248263          	beq	s1,s2,8000232c <procdump+0x8e>
    if(p->state == UNUSED)
    8000230c:	86a6                	mv	a3,s1
    8000230e:	ec04a783          	lw	a5,-320(s1)
    80002312:	dbed                	beqz	a5,80002304 <procdump+0x66>
      state = "???";
    80002314:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002316:	fcfb6fe3          	bltu	s6,a5,800022f4 <procdump+0x56>
    8000231a:	02079713          	slli	a4,a5,0x20
    8000231e:	01d75793          	srli	a5,a4,0x1d
    80002322:	97de                	add	a5,a5,s7
    80002324:	6390                	ld	a2,0(a5)
    80002326:	f679                	bnez	a2,800022f4 <procdump+0x56>
      state = "???";
    80002328:	864e                	mv	a2,s3
    8000232a:	b7e9                	j	800022f4 <procdump+0x56>
  }
}
    8000232c:	60a6                	ld	ra,72(sp)
    8000232e:	6406                	ld	s0,64(sp)
    80002330:	74e2                	ld	s1,56(sp)
    80002332:	7942                	ld	s2,48(sp)
    80002334:	79a2                	ld	s3,40(sp)
    80002336:	7a02                	ld	s4,32(sp)
    80002338:	6ae2                	ld	s5,24(sp)
    8000233a:	6b42                	ld	s6,16(sp)
    8000233c:	6ba2                	ld	s7,8(sp)
    8000233e:	6161                	addi	sp,sp,80
    80002340:	8082                	ret

0000000080002342 <swtch>:
    80002342:	00153023          	sd	ra,0(a0)
    80002346:	00253423          	sd	sp,8(a0)
    8000234a:	e900                	sd	s0,16(a0)
    8000234c:	ed04                	sd	s1,24(a0)
    8000234e:	03253023          	sd	s2,32(a0)
    80002352:	03353423          	sd	s3,40(a0)
    80002356:	03453823          	sd	s4,48(a0)
    8000235a:	03553c23          	sd	s5,56(a0)
    8000235e:	05653023          	sd	s6,64(a0)
    80002362:	05753423          	sd	s7,72(a0)
    80002366:	05853823          	sd	s8,80(a0)
    8000236a:	05953c23          	sd	s9,88(a0)
    8000236e:	07a53023          	sd	s10,96(a0)
    80002372:	07b53423          	sd	s11,104(a0)
    80002376:	0005b083          	ld	ra,0(a1)
    8000237a:	0085b103          	ld	sp,8(a1)
    8000237e:	6980                	ld	s0,16(a1)
    80002380:	6d84                	ld	s1,24(a1)
    80002382:	0205b903          	ld	s2,32(a1)
    80002386:	0285b983          	ld	s3,40(a1)
    8000238a:	0305ba03          	ld	s4,48(a1)
    8000238e:	0385ba83          	ld	s5,56(a1)
    80002392:	0405bb03          	ld	s6,64(a1)
    80002396:	0485bb83          	ld	s7,72(a1)
    8000239a:	0505bc03          	ld	s8,80(a1)
    8000239e:	0585bc83          	ld	s9,88(a1)
    800023a2:	0605bd03          	ld	s10,96(a1)
    800023a6:	0685bd83          	ld	s11,104(a1)
    800023aa:	8082                	ret

00000000800023ac <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023ac:	1141                	addi	sp,sp,-16
    800023ae:	e406                	sd	ra,8(sp)
    800023b0:	e022                	sd	s0,0(sp)
    800023b2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023b4:	00005597          	auipc	a1,0x5
    800023b8:	f3458593          	addi	a1,a1,-204 # 800072e8 <etext+0x2e8>
    800023bc:	00013517          	auipc	a0,0x13
    800023c0:	51450513          	addi	a0,a0,1300 # 800158d0 <tickslock>
    800023c4:	fb0fe0ef          	jal	80000b74 <initlock>
}
    800023c8:	60a2                	ld	ra,8(sp)
    800023ca:	6402                	ld	s0,0(sp)
    800023cc:	0141                	addi	sp,sp,16
    800023ce:	8082                	ret

00000000800023d0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800023d0:	1141                	addi	sp,sp,-16
    800023d2:	e422                	sd	s0,8(sp)
    800023d4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800023d6:	00003797          	auipc	a5,0x3
    800023da:	e2a78793          	addi	a5,a5,-470 # 80005200 <kernelvec>
    800023de:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800023e2:	6422                	ld	s0,8(sp)
    800023e4:	0141                	addi	sp,sp,16
    800023e6:	8082                	ret

00000000800023e8 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800023e8:	1141                	addi	sp,sp,-16
    800023ea:	e406                	sd	ra,8(sp)
    800023ec:	e022                	sd	s0,0(sp)
    800023ee:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800023f0:	cf0ff0ef          	jal	800018e0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023f4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800023f8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023fa:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800023fe:	00004697          	auipc	a3,0x4
    80002402:	c0268693          	addi	a3,a3,-1022 # 80006000 <_trampoline>
    80002406:	00004717          	auipc	a4,0x4
    8000240a:	bfa70713          	addi	a4,a4,-1030 # 80006000 <_trampoline>
    8000240e:	8f15                	sub	a4,a4,a3
    80002410:	040007b7          	lui	a5,0x4000
    80002414:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002416:	07b2                	slli	a5,a5,0xc
    80002418:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000241a:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000241e:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002420:	18002673          	csrr	a2,satp
    80002424:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002426:	6d30                	ld	a2,88(a0)
    80002428:	6138                	ld	a4,64(a0)
    8000242a:	6585                	lui	a1,0x1
    8000242c:	972e                	add	a4,a4,a1
    8000242e:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002430:	6d38                	ld	a4,88(a0)
    80002432:	00000617          	auipc	a2,0x0
    80002436:	11060613          	addi	a2,a2,272 # 80002542 <usertrap>
    8000243a:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000243c:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000243e:	8612                	mv	a2,tp
    80002440:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002442:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002446:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000244a:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000244e:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002452:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002454:	6f18                	ld	a4,24(a4)
    80002456:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000245a:	6928                	ld	a0,80(a0)
    8000245c:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000245e:	00004717          	auipc	a4,0x4
    80002462:	c3e70713          	addi	a4,a4,-962 # 8000609c <userret>
    80002466:	8f15                	sub	a4,a4,a3
    80002468:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000246a:	577d                	li	a4,-1
    8000246c:	177e                	slli	a4,a4,0x3f
    8000246e:	8d59                	or	a0,a0,a4
    80002470:	9782                	jalr	a5
}
    80002472:	60a2                	ld	ra,8(sp)
    80002474:	6402                	ld	s0,0(sp)
    80002476:	0141                	addi	sp,sp,16
    80002478:	8082                	ret

000000008000247a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000247a:	1101                	addi	sp,sp,-32
    8000247c:	ec06                	sd	ra,24(sp)
    8000247e:	e822                	sd	s0,16(sp)
    80002480:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002482:	c32ff0ef          	jal	800018b4 <cpuid>
    80002486:	cd11                	beqz	a0,800024a2 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002488:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000248c:	000f4737          	lui	a4,0xf4
    80002490:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002494:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002496:	14d79073          	csrw	stimecmp,a5
}
    8000249a:	60e2                	ld	ra,24(sp)
    8000249c:	6442                	ld	s0,16(sp)
    8000249e:	6105                	addi	sp,sp,32
    800024a0:	8082                	ret
    800024a2:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024a4:	00013497          	auipc	s1,0x13
    800024a8:	42c48493          	addi	s1,s1,1068 # 800158d0 <tickslock>
    800024ac:	8526                	mv	a0,s1
    800024ae:	f46fe0ef          	jal	80000bf4 <acquire>
    ticks++;
    800024b2:	00005517          	auipc	a0,0x5
    800024b6:	4be50513          	addi	a0,a0,1214 # 80007970 <ticks>
    800024ba:	411c                	lw	a5,0(a0)
    800024bc:	2785                	addiw	a5,a5,1
    800024be:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024c0:	a3bff0ef          	jal	80001efa <wakeup>
    release(&tickslock);
    800024c4:	8526                	mv	a0,s1
    800024c6:	fc6fe0ef          	jal	80000c8c <release>
    800024ca:	64a2                	ld	s1,8(sp)
    800024cc:	bf75                	j	80002488 <clockintr+0xe>

00000000800024ce <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024ce:	1101                	addi	sp,sp,-32
    800024d0:	ec06                	sd	ra,24(sp)
    800024d2:	e822                	sd	s0,16(sp)
    800024d4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024d6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800024da:	57fd                	li	a5,-1
    800024dc:	17fe                	slli	a5,a5,0x3f
    800024de:	07a5                	addi	a5,a5,9
    800024e0:	00f70c63          	beq	a4,a5,800024f8 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800024e4:	57fd                	li	a5,-1
    800024e6:	17fe                	slli	a5,a5,0x3f
    800024e8:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800024ea:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800024ec:	04f70763          	beq	a4,a5,8000253a <devintr+0x6c>
  }
}
    800024f0:	60e2                	ld	ra,24(sp)
    800024f2:	6442                	ld	s0,16(sp)
    800024f4:	6105                	addi	sp,sp,32
    800024f6:	8082                	ret
    800024f8:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800024fa:	5b3020ef          	jal	800052ac <plic_claim>
    800024fe:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002500:	47a9                	li	a5,10
    80002502:	00f50963          	beq	a0,a5,80002514 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002506:	4785                	li	a5,1
    80002508:	00f50963          	beq	a0,a5,8000251a <devintr+0x4c>
    return 1;
    8000250c:	4505                	li	a0,1
    } else if(irq){
    8000250e:	e889                	bnez	s1,80002520 <devintr+0x52>
    80002510:	64a2                	ld	s1,8(sp)
    80002512:	bff9                	j	800024f0 <devintr+0x22>
      uartintr();
    80002514:	cf2fe0ef          	jal	80000a06 <uartintr>
    if(irq)
    80002518:	a819                	j	8000252e <devintr+0x60>
      virtio_disk_intr();
    8000251a:	258030ef          	jal	80005772 <virtio_disk_intr>
    if(irq)
    8000251e:	a801                	j	8000252e <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002520:	85a6                	mv	a1,s1
    80002522:	00005517          	auipc	a0,0x5
    80002526:	dce50513          	addi	a0,a0,-562 # 800072f0 <etext+0x2f0>
    8000252a:	f99fd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    8000252e:	8526                	mv	a0,s1
    80002530:	59d020ef          	jal	800052cc <plic_complete>
    return 1;
    80002534:	4505                	li	a0,1
    80002536:	64a2                	ld	s1,8(sp)
    80002538:	bf65                	j	800024f0 <devintr+0x22>
    clockintr();
    8000253a:	f41ff0ef          	jal	8000247a <clockintr>
    return 2;
    8000253e:	4509                	li	a0,2
    80002540:	bf45                	j	800024f0 <devintr+0x22>

0000000080002542 <usertrap>:
{
    80002542:	1101                	addi	sp,sp,-32
    80002544:	ec06                	sd	ra,24(sp)
    80002546:	e822                	sd	s0,16(sp)
    80002548:	e426                	sd	s1,8(sp)
    8000254a:	e04a                	sd	s2,0(sp)
    8000254c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000254e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002552:	1007f793          	andi	a5,a5,256
    80002556:	ef85                	bnez	a5,8000258e <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002558:	00003797          	auipc	a5,0x3
    8000255c:	ca878793          	addi	a5,a5,-856 # 80005200 <kernelvec>
    80002560:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002564:	b7cff0ef          	jal	800018e0 <myproc>
    80002568:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000256a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000256c:	14102773          	csrr	a4,sepc
    80002570:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002572:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002576:	47a1                	li	a5,8
    80002578:	02f70163          	beq	a4,a5,8000259a <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    8000257c:	f53ff0ef          	jal	800024ce <devintr>
    80002580:	892a                	mv	s2,a0
    80002582:	c135                	beqz	a0,800025e6 <usertrap+0xa4>
  if(killed(p))
    80002584:	8526                	mv	a0,s1
    80002586:	b61ff0ef          	jal	800020e6 <killed>
    8000258a:	cd1d                	beqz	a0,800025c8 <usertrap+0x86>
    8000258c:	a81d                	j	800025c2 <usertrap+0x80>
    panic("usertrap: not from user mode");
    8000258e:	00005517          	auipc	a0,0x5
    80002592:	d8250513          	addi	a0,a0,-638 # 80007310 <etext+0x310>
    80002596:	9fefe0ef          	jal	80000794 <panic>
    if(killed(p))
    8000259a:	b4dff0ef          	jal	800020e6 <killed>
    8000259e:	e121                	bnez	a0,800025de <usertrap+0x9c>
    p->trapframe->epc += 4;
    800025a0:	6cb8                	ld	a4,88(s1)
    800025a2:	6f1c                	ld	a5,24(a4)
    800025a4:	0791                	addi	a5,a5,4
    800025a6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025a8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025ac:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025b0:	10079073          	csrw	sstatus,a5
    syscall();
    800025b4:	248000ef          	jal	800027fc <syscall>
  if(killed(p))
    800025b8:	8526                	mv	a0,s1
    800025ba:	b2dff0ef          	jal	800020e6 <killed>
    800025be:	c901                	beqz	a0,800025ce <usertrap+0x8c>
    800025c0:	4901                	li	s2,0
    exit(-1);
    800025c2:	557d                	li	a0,-1
    800025c4:	9f7ff0ef          	jal	80001fba <exit>
  if(which_dev == 2)
    800025c8:	4789                	li	a5,2
    800025ca:	04f90563          	beq	s2,a5,80002614 <usertrap+0xd2>
  usertrapret();
    800025ce:	e1bff0ef          	jal	800023e8 <usertrapret>
}
    800025d2:	60e2                	ld	ra,24(sp)
    800025d4:	6442                	ld	s0,16(sp)
    800025d6:	64a2                	ld	s1,8(sp)
    800025d8:	6902                	ld	s2,0(sp)
    800025da:	6105                	addi	sp,sp,32
    800025dc:	8082                	ret
      exit(-1);
    800025de:	557d                	li	a0,-1
    800025e0:	9dbff0ef          	jal	80001fba <exit>
    800025e4:	bf75                	j	800025a0 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025e6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800025ea:	5890                	lw	a2,48(s1)
    800025ec:	00005517          	auipc	a0,0x5
    800025f0:	d4450513          	addi	a0,a0,-700 # 80007330 <etext+0x330>
    800025f4:	ecffd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025f8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025fc:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002600:	00005517          	auipc	a0,0x5
    80002604:	d6050513          	addi	a0,a0,-672 # 80007360 <etext+0x360>
    80002608:	ebbfd0ef          	jal	800004c2 <printf>
    setkilled(p);
    8000260c:	8526                	mv	a0,s1
    8000260e:	ab5ff0ef          	jal	800020c2 <setkilled>
    80002612:	b75d                	j	800025b8 <usertrap+0x76>
    yield();
    80002614:	86fff0ef          	jal	80001e82 <yield>
    80002618:	bf5d                	j	800025ce <usertrap+0x8c>

000000008000261a <kerneltrap>:
{
    8000261a:	7179                	addi	sp,sp,-48
    8000261c:	f406                	sd	ra,40(sp)
    8000261e:	f022                	sd	s0,32(sp)
    80002620:	ec26                	sd	s1,24(sp)
    80002622:	e84a                	sd	s2,16(sp)
    80002624:	e44e                	sd	s3,8(sp)
    80002626:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002628:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000262c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002630:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002634:	1004f793          	andi	a5,s1,256
    80002638:	c795                	beqz	a5,80002664 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000263a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000263e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002640:	eb85                	bnez	a5,80002670 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002642:	e8dff0ef          	jal	800024ce <devintr>
    80002646:	c91d                	beqz	a0,8000267c <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002648:	4789                	li	a5,2
    8000264a:	04f50a63          	beq	a0,a5,8000269e <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000264e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002652:	10049073          	csrw	sstatus,s1
}
    80002656:	70a2                	ld	ra,40(sp)
    80002658:	7402                	ld	s0,32(sp)
    8000265a:	64e2                	ld	s1,24(sp)
    8000265c:	6942                	ld	s2,16(sp)
    8000265e:	69a2                	ld	s3,8(sp)
    80002660:	6145                	addi	sp,sp,48
    80002662:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002664:	00005517          	auipc	a0,0x5
    80002668:	d2450513          	addi	a0,a0,-732 # 80007388 <etext+0x388>
    8000266c:	928fe0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    80002670:	00005517          	auipc	a0,0x5
    80002674:	d4050513          	addi	a0,a0,-704 # 800073b0 <etext+0x3b0>
    80002678:	91cfe0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000267c:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002680:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002684:	85ce                	mv	a1,s3
    80002686:	00005517          	auipc	a0,0x5
    8000268a:	d4a50513          	addi	a0,a0,-694 # 800073d0 <etext+0x3d0>
    8000268e:	e35fd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    80002692:	00005517          	auipc	a0,0x5
    80002696:	d6650513          	addi	a0,a0,-666 # 800073f8 <etext+0x3f8>
    8000269a:	8fafe0ef          	jal	80000794 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000269e:	a42ff0ef          	jal	800018e0 <myproc>
    800026a2:	d555                	beqz	a0,8000264e <kerneltrap+0x34>
    yield();
    800026a4:	fdeff0ef          	jal	80001e82 <yield>
    800026a8:	b75d                	j	8000264e <kerneltrap+0x34>

00000000800026aa <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026aa:	1101                	addi	sp,sp,-32
    800026ac:	ec06                	sd	ra,24(sp)
    800026ae:	e822                	sd	s0,16(sp)
    800026b0:	e426                	sd	s1,8(sp)
    800026b2:	1000                	addi	s0,sp,32
    800026b4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800026b6:	a2aff0ef          	jal	800018e0 <myproc>
  switch (n) {
    800026ba:	4795                	li	a5,5
    800026bc:	0497e163          	bltu	a5,s1,800026fe <argraw+0x54>
    800026c0:	048a                	slli	s1,s1,0x2
    800026c2:	00005717          	auipc	a4,0x5
    800026c6:	15670713          	addi	a4,a4,342 # 80007818 <states.0+0x30>
    800026ca:	94ba                	add	s1,s1,a4
    800026cc:	409c                	lw	a5,0(s1)
    800026ce:	97ba                	add	a5,a5,a4
    800026d0:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800026d2:	6d3c                	ld	a5,88(a0)
    800026d4:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800026d6:	60e2                	ld	ra,24(sp)
    800026d8:	6442                	ld	s0,16(sp)
    800026da:	64a2                	ld	s1,8(sp)
    800026dc:	6105                	addi	sp,sp,32
    800026de:	8082                	ret
    return p->trapframe->a1;
    800026e0:	6d3c                	ld	a5,88(a0)
    800026e2:	7fa8                	ld	a0,120(a5)
    800026e4:	bfcd                	j	800026d6 <argraw+0x2c>
    return p->trapframe->a2;
    800026e6:	6d3c                	ld	a5,88(a0)
    800026e8:	63c8                	ld	a0,128(a5)
    800026ea:	b7f5                	j	800026d6 <argraw+0x2c>
    return p->trapframe->a3;
    800026ec:	6d3c                	ld	a5,88(a0)
    800026ee:	67c8                	ld	a0,136(a5)
    800026f0:	b7dd                	j	800026d6 <argraw+0x2c>
    return p->trapframe->a4;
    800026f2:	6d3c                	ld	a5,88(a0)
    800026f4:	6bc8                	ld	a0,144(a5)
    800026f6:	b7c5                	j	800026d6 <argraw+0x2c>
    return p->trapframe->a5;
    800026f8:	6d3c                	ld	a5,88(a0)
    800026fa:	6fc8                	ld	a0,152(a5)
    800026fc:	bfe9                	j	800026d6 <argraw+0x2c>
  panic("argraw");
    800026fe:	00005517          	auipc	a0,0x5
    80002702:	d0a50513          	addi	a0,a0,-758 # 80007408 <etext+0x408>
    80002706:	88efe0ef          	jal	80000794 <panic>

000000008000270a <fetchaddr>:
{
    8000270a:	1101                	addi	sp,sp,-32
    8000270c:	ec06                	sd	ra,24(sp)
    8000270e:	e822                	sd	s0,16(sp)
    80002710:	e426                	sd	s1,8(sp)
    80002712:	e04a                	sd	s2,0(sp)
    80002714:	1000                	addi	s0,sp,32
    80002716:	84aa                	mv	s1,a0
    80002718:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000271a:	9c6ff0ef          	jal	800018e0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000271e:	653c                	ld	a5,72(a0)
    80002720:	02f4f663          	bgeu	s1,a5,8000274c <fetchaddr+0x42>
    80002724:	00848713          	addi	a4,s1,8
    80002728:	02e7e463          	bltu	a5,a4,80002750 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000272c:	46a1                	li	a3,8
    8000272e:	8626                	mv	a2,s1
    80002730:	85ca                	mv	a1,s2
    80002732:	6928                	ld	a0,80(a0)
    80002734:	ef5fe0ef          	jal	80001628 <copyin>
    80002738:	00a03533          	snez	a0,a0
    8000273c:	40a00533          	neg	a0,a0
}
    80002740:	60e2                	ld	ra,24(sp)
    80002742:	6442                	ld	s0,16(sp)
    80002744:	64a2                	ld	s1,8(sp)
    80002746:	6902                	ld	s2,0(sp)
    80002748:	6105                	addi	sp,sp,32
    8000274a:	8082                	ret
    return -1;
    8000274c:	557d                	li	a0,-1
    8000274e:	bfcd                	j	80002740 <fetchaddr+0x36>
    80002750:	557d                	li	a0,-1
    80002752:	b7fd                	j	80002740 <fetchaddr+0x36>

0000000080002754 <fetchstr>:
{
    80002754:	7179                	addi	sp,sp,-48
    80002756:	f406                	sd	ra,40(sp)
    80002758:	f022                	sd	s0,32(sp)
    8000275a:	ec26                	sd	s1,24(sp)
    8000275c:	e84a                	sd	s2,16(sp)
    8000275e:	e44e                	sd	s3,8(sp)
    80002760:	1800                	addi	s0,sp,48
    80002762:	892a                	mv	s2,a0
    80002764:	84ae                	mv	s1,a1
    80002766:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002768:	978ff0ef          	jal	800018e0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000276c:	86ce                	mv	a3,s3
    8000276e:	864a                	mv	a2,s2
    80002770:	85a6                	mv	a1,s1
    80002772:	6928                	ld	a0,80(a0)
    80002774:	f3bfe0ef          	jal	800016ae <copyinstr>
    80002778:	00054c63          	bltz	a0,80002790 <fetchstr+0x3c>
  return strlen(buf);
    8000277c:	8526                	mv	a0,s1
    8000277e:	ebafe0ef          	jal	80000e38 <strlen>
}
    80002782:	70a2                	ld	ra,40(sp)
    80002784:	7402                	ld	s0,32(sp)
    80002786:	64e2                	ld	s1,24(sp)
    80002788:	6942                	ld	s2,16(sp)
    8000278a:	69a2                	ld	s3,8(sp)
    8000278c:	6145                	addi	sp,sp,48
    8000278e:	8082                	ret
    return -1;
    80002790:	557d                	li	a0,-1
    80002792:	bfc5                	j	80002782 <fetchstr+0x2e>

0000000080002794 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002794:	1101                	addi	sp,sp,-32
    80002796:	ec06                	sd	ra,24(sp)
    80002798:	e822                	sd	s0,16(sp)
    8000279a:	e426                	sd	s1,8(sp)
    8000279c:	1000                	addi	s0,sp,32
    8000279e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027a0:	f0bff0ef          	jal	800026aa <argraw>
    800027a4:	c088                	sw	a0,0(s1)
}
    800027a6:	60e2                	ld	ra,24(sp)
    800027a8:	6442                	ld	s0,16(sp)
    800027aa:	64a2                	ld	s1,8(sp)
    800027ac:	6105                	addi	sp,sp,32
    800027ae:	8082                	ret

00000000800027b0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800027b0:	1101                	addi	sp,sp,-32
    800027b2:	ec06                	sd	ra,24(sp)
    800027b4:	e822                	sd	s0,16(sp)
    800027b6:	e426                	sd	s1,8(sp)
    800027b8:	1000                	addi	s0,sp,32
    800027ba:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027bc:	eefff0ef          	jal	800026aa <argraw>
    800027c0:	e088                	sd	a0,0(s1)
}
    800027c2:	60e2                	ld	ra,24(sp)
    800027c4:	6442                	ld	s0,16(sp)
    800027c6:	64a2                	ld	s1,8(sp)
    800027c8:	6105                	addi	sp,sp,32
    800027ca:	8082                	ret

00000000800027cc <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800027cc:	7179                	addi	sp,sp,-48
    800027ce:	f406                	sd	ra,40(sp)
    800027d0:	f022                	sd	s0,32(sp)
    800027d2:	ec26                	sd	s1,24(sp)
    800027d4:	e84a                	sd	s2,16(sp)
    800027d6:	1800                	addi	s0,sp,48
    800027d8:	84ae                	mv	s1,a1
    800027da:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800027dc:	fd840593          	addi	a1,s0,-40
    800027e0:	fd1ff0ef          	jal	800027b0 <argaddr>
  return fetchstr(addr, buf, max);
    800027e4:	864a                	mv	a2,s2
    800027e6:	85a6                	mv	a1,s1
    800027e8:	fd843503          	ld	a0,-40(s0)
    800027ec:	f69ff0ef          	jal	80002754 <fetchstr>
}
    800027f0:	70a2                	ld	ra,40(sp)
    800027f2:	7402                	ld	s0,32(sp)
    800027f4:	64e2                	ld	s1,24(sp)
    800027f6:	6942                	ld	s2,16(sp)
    800027f8:	6145                	addi	sp,sp,48
    800027fa:	8082                	ret

00000000800027fc <syscall>:
[SYS_trigger] sys_trigger,
};

void
syscall(void)
{
    800027fc:	1101                	addi	sp,sp,-32
    800027fe:	ec06                	sd	ra,24(sp)
    80002800:	e822                	sd	s0,16(sp)
    80002802:	e426                	sd	s1,8(sp)
    80002804:	e04a                	sd	s2,0(sp)
    80002806:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002808:	8d8ff0ef          	jal	800018e0 <myproc>
    8000280c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000280e:	05853903          	ld	s2,88(a0)
    80002812:	0a893783          	ld	a5,168(s2)
    80002816:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000281a:	37fd                	addiw	a5,a5,-1
    8000281c:	4755                	li	a4,21
    8000281e:	00f76f63          	bltu	a4,a5,8000283c <syscall+0x40>
    80002822:	00369713          	slli	a4,a3,0x3
    80002826:	00005797          	auipc	a5,0x5
    8000282a:	00a78793          	addi	a5,a5,10 # 80007830 <syscalls>
    8000282e:	97ba                	add	a5,a5,a4
    80002830:	639c                	ld	a5,0(a5)
    80002832:	c789                	beqz	a5,8000283c <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002834:	9782                	jalr	a5
    80002836:	06a93823          	sd	a0,112(s2)
    8000283a:	a829                	j	80002854 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000283c:	15848613          	addi	a2,s1,344
    80002840:	588c                	lw	a1,48(s1)
    80002842:	00005517          	auipc	a0,0x5
    80002846:	bce50513          	addi	a0,a0,-1074 # 80007410 <etext+0x410>
    8000284a:	c79fd0ef          	jal	800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000284e:	6cbc                	ld	a5,88(s1)
    80002850:	577d                	li	a4,-1
    80002852:	fbb8                	sd	a4,112(a5)
  }
}
    80002854:	60e2                	ld	ra,24(sp)
    80002856:	6442                	ld	s0,16(sp)
    80002858:	64a2                	ld	s1,8(sp)
    8000285a:	6902                	ld	s2,0(sp)
    8000285c:	6105                	addi	sp,sp,32
    8000285e:	8082                	ret

0000000080002860 <sys_exit>:
#include "proc.h"
#include "custom_logger.h"

uint64
sys_exit(void)
{
    80002860:	1101                	addi	sp,sp,-32
    80002862:	ec06                	sd	ra,24(sp)
    80002864:	e822                	sd	s0,16(sp)
    80002866:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002868:	fec40593          	addi	a1,s0,-20
    8000286c:	4501                	li	a0,0
    8000286e:	f27ff0ef          	jal	80002794 <argint>
  exit(n);
    80002872:	fec42503          	lw	a0,-20(s0)
    80002876:	f44ff0ef          	jal	80001fba <exit>
  return 0;  // not reached
}
    8000287a:	4501                	li	a0,0
    8000287c:	60e2                	ld	ra,24(sp)
    8000287e:	6442                	ld	s0,16(sp)
    80002880:	6105                	addi	sp,sp,32
    80002882:	8082                	ret

0000000080002884 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002884:	1141                	addi	sp,sp,-16
    80002886:	e406                	sd	ra,8(sp)
    80002888:	e022                	sd	s0,0(sp)
    8000288a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000288c:	854ff0ef          	jal	800018e0 <myproc>
}
    80002890:	5908                	lw	a0,48(a0)
    80002892:	60a2                	ld	ra,8(sp)
    80002894:	6402                	ld	s0,0(sp)
    80002896:	0141                	addi	sp,sp,16
    80002898:	8082                	ret

000000008000289a <sys_fork>:

uint64
sys_fork(void)
{
    8000289a:	1141                	addi	sp,sp,-16
    8000289c:	e406                	sd	ra,8(sp)
    8000289e:	e022                	sd	s0,0(sp)
    800028a0:	0800                	addi	s0,sp,16
  return fork();
    800028a2:	b64ff0ef          	jal	80001c06 <fork>
}
    800028a6:	60a2                	ld	ra,8(sp)
    800028a8:	6402                	ld	s0,0(sp)
    800028aa:	0141                	addi	sp,sp,16
    800028ac:	8082                	ret

00000000800028ae <sys_wait>:

uint64
sys_wait(void)
{
    800028ae:	1101                	addi	sp,sp,-32
    800028b0:	ec06                	sd	ra,24(sp)
    800028b2:	e822                	sd	s0,16(sp)
    800028b4:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800028b6:	fe840593          	addi	a1,s0,-24
    800028ba:	4501                	li	a0,0
    800028bc:	ef5ff0ef          	jal	800027b0 <argaddr>
  return wait(p);
    800028c0:	fe843503          	ld	a0,-24(s0)
    800028c4:	84dff0ef          	jal	80002110 <wait>
}
    800028c8:	60e2                	ld	ra,24(sp)
    800028ca:	6442                	ld	s0,16(sp)
    800028cc:	6105                	addi	sp,sp,32
    800028ce:	8082                	ret

00000000800028d0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800028d0:	7179                	addi	sp,sp,-48
    800028d2:	f406                	sd	ra,40(sp)
    800028d4:	f022                	sd	s0,32(sp)
    800028d6:	ec26                	sd	s1,24(sp)
    800028d8:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800028da:	fdc40593          	addi	a1,s0,-36
    800028de:	4501                	li	a0,0
    800028e0:	eb5ff0ef          	jal	80002794 <argint>
  addr = myproc()->sz;
    800028e4:	ffdfe0ef          	jal	800018e0 <myproc>
    800028e8:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800028ea:	fdc42503          	lw	a0,-36(s0)
    800028ee:	ac8ff0ef          	jal	80001bb6 <growproc>
    800028f2:	00054863          	bltz	a0,80002902 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    800028f6:	8526                	mv	a0,s1
    800028f8:	70a2                	ld	ra,40(sp)
    800028fa:	7402                	ld	s0,32(sp)
    800028fc:	64e2                	ld	s1,24(sp)
    800028fe:	6145                	addi	sp,sp,48
    80002900:	8082                	ret
    return -1;
    80002902:	54fd                	li	s1,-1
    80002904:	bfcd                	j	800028f6 <sys_sbrk+0x26>

0000000080002906 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002906:	7139                	addi	sp,sp,-64
    80002908:	fc06                	sd	ra,56(sp)
    8000290a:	f822                	sd	s0,48(sp)
    8000290c:	f04a                	sd	s2,32(sp)
    8000290e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002910:	fcc40593          	addi	a1,s0,-52
    80002914:	4501                	li	a0,0
    80002916:	e7fff0ef          	jal	80002794 <argint>
  if(n < 0)
    8000291a:	fcc42783          	lw	a5,-52(s0)
    8000291e:	0607c763          	bltz	a5,8000298c <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002922:	00013517          	auipc	a0,0x13
    80002926:	fae50513          	addi	a0,a0,-82 # 800158d0 <tickslock>
    8000292a:	acafe0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    8000292e:	00005917          	auipc	s2,0x5
    80002932:	04292903          	lw	s2,66(s2) # 80007970 <ticks>
  while(ticks - ticks0 < n){
    80002936:	fcc42783          	lw	a5,-52(s0)
    8000293a:	cf8d                	beqz	a5,80002974 <sys_sleep+0x6e>
    8000293c:	f426                	sd	s1,40(sp)
    8000293e:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002940:	00013997          	auipc	s3,0x13
    80002944:	f9098993          	addi	s3,s3,-112 # 800158d0 <tickslock>
    80002948:	00005497          	auipc	s1,0x5
    8000294c:	02848493          	addi	s1,s1,40 # 80007970 <ticks>
    if(killed(myproc())){
    80002950:	f91fe0ef          	jal	800018e0 <myproc>
    80002954:	f92ff0ef          	jal	800020e6 <killed>
    80002958:	ed0d                	bnez	a0,80002992 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    8000295a:	85ce                	mv	a1,s3
    8000295c:	8526                	mv	a0,s1
    8000295e:	d50ff0ef          	jal	80001eae <sleep>
  while(ticks - ticks0 < n){
    80002962:	409c                	lw	a5,0(s1)
    80002964:	412787bb          	subw	a5,a5,s2
    80002968:	fcc42703          	lw	a4,-52(s0)
    8000296c:	fee7e2e3          	bltu	a5,a4,80002950 <sys_sleep+0x4a>
    80002970:	74a2                	ld	s1,40(sp)
    80002972:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002974:	00013517          	auipc	a0,0x13
    80002978:	f5c50513          	addi	a0,a0,-164 # 800158d0 <tickslock>
    8000297c:	b10fe0ef          	jal	80000c8c <release>
  return 0;
    80002980:	4501                	li	a0,0
}
    80002982:	70e2                	ld	ra,56(sp)
    80002984:	7442                	ld	s0,48(sp)
    80002986:	7902                	ld	s2,32(sp)
    80002988:	6121                	addi	sp,sp,64
    8000298a:	8082                	ret
    n = 0;
    8000298c:	fc042623          	sw	zero,-52(s0)
    80002990:	bf49                	j	80002922 <sys_sleep+0x1c>
      release(&tickslock);
    80002992:	00013517          	auipc	a0,0x13
    80002996:	f3e50513          	addi	a0,a0,-194 # 800158d0 <tickslock>
    8000299a:	af2fe0ef          	jal	80000c8c <release>
      return -1;
    8000299e:	557d                	li	a0,-1
    800029a0:	74a2                	ld	s1,40(sp)
    800029a2:	69e2                	ld	s3,24(sp)
    800029a4:	bff9                	j	80002982 <sys_sleep+0x7c>

00000000800029a6 <sys_kill>:

uint64
sys_kill(void)
{
    800029a6:	1101                	addi	sp,sp,-32
    800029a8:	ec06                	sd	ra,24(sp)
    800029aa:	e822                	sd	s0,16(sp)
    800029ac:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800029ae:	fec40593          	addi	a1,s0,-20
    800029b2:	4501                	li	a0,0
    800029b4:	de1ff0ef          	jal	80002794 <argint>
  return kill(pid);
    800029b8:	fec42503          	lw	a0,-20(s0)
    800029bc:	ea0ff0ef          	jal	8000205c <kill>
}
    800029c0:	60e2                	ld	ra,24(sp)
    800029c2:	6442                	ld	s0,16(sp)
    800029c4:	6105                	addi	sp,sp,32
    800029c6:	8082                	ret

00000000800029c8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800029c8:	1101                	addi	sp,sp,-32
    800029ca:	ec06                	sd	ra,24(sp)
    800029cc:	e822                	sd	s0,16(sp)
    800029ce:	e426                	sd	s1,8(sp)
    800029d0:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800029d2:	00013517          	auipc	a0,0x13
    800029d6:	efe50513          	addi	a0,a0,-258 # 800158d0 <tickslock>
    800029da:	a1afe0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    800029de:	00005497          	auipc	s1,0x5
    800029e2:	f924a483          	lw	s1,-110(s1) # 80007970 <ticks>
  release(&tickslock);
    800029e6:	00013517          	auipc	a0,0x13
    800029ea:	eea50513          	addi	a0,a0,-278 # 800158d0 <tickslock>
    800029ee:	a9efe0ef          	jal	80000c8c <release>
  return xticks;
}
    800029f2:	02049513          	slli	a0,s1,0x20
    800029f6:	9101                	srli	a0,a0,0x20
    800029f8:	60e2                	ld	ra,24(sp)
    800029fa:	6442                	ld	s0,16(sp)
    800029fc:	64a2                	ld	s1,8(sp)
    800029fe:	6105                	addi	sp,sp,32
    80002a00:	8082                	ret

0000000080002a02 <sys_trigger>:

uint64 
sys_trigger(void)
{
    80002a02:	1141                	addi	sp,sp,-16
    80002a04:	e406                	sd	ra,8(sp)
    80002a06:	e022                	sd	s0,0(sp)
    80002a08:	0800                	addi	s0,sp,16
  log_message(1, "This is a log to test a new xv6 system call");
    80002a0a:	00005597          	auipc	a1,0x5
    80002a0e:	a2658593          	addi	a1,a1,-1498 # 80007430 <etext+0x430>
    80002a12:	4505                	li	a0,1
    80002a14:	607020ef          	jal	8000581a <log_message>
  return 0;
}
    80002a18:	4501                	li	a0,0
    80002a1a:	60a2                	ld	ra,8(sp)
    80002a1c:	6402                	ld	s0,0(sp)
    80002a1e:	0141                	addi	sp,sp,16
    80002a20:	8082                	ret

0000000080002a22 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002a22:	7179                	addi	sp,sp,-48
    80002a24:	f406                	sd	ra,40(sp)
    80002a26:	f022                	sd	s0,32(sp)
    80002a28:	ec26                	sd	s1,24(sp)
    80002a2a:	e84a                	sd	s2,16(sp)
    80002a2c:	e44e                	sd	s3,8(sp)
    80002a2e:	e052                	sd	s4,0(sp)
    80002a30:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002a32:	00005597          	auipc	a1,0x5
    80002a36:	a2e58593          	addi	a1,a1,-1490 # 80007460 <etext+0x460>
    80002a3a:	00013517          	auipc	a0,0x13
    80002a3e:	eae50513          	addi	a0,a0,-338 # 800158e8 <bcache>
    80002a42:	932fe0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002a46:	0001b797          	auipc	a5,0x1b
    80002a4a:	ea278793          	addi	a5,a5,-350 # 8001d8e8 <bcache+0x8000>
    80002a4e:	0001b717          	auipc	a4,0x1b
    80002a52:	10270713          	addi	a4,a4,258 # 8001db50 <bcache+0x8268>
    80002a56:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002a5a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002a5e:	00013497          	auipc	s1,0x13
    80002a62:	ea248493          	addi	s1,s1,-350 # 80015900 <bcache+0x18>
    b->next = bcache.head.next;
    80002a66:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002a68:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002a6a:	00005a17          	auipc	s4,0x5
    80002a6e:	9fea0a13          	addi	s4,s4,-1538 # 80007468 <etext+0x468>
    b->next = bcache.head.next;
    80002a72:	2b893783          	ld	a5,696(s2)
    80002a76:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002a78:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002a7c:	85d2                	mv	a1,s4
    80002a7e:	01048513          	addi	a0,s1,16
    80002a82:	248010ef          	jal	80003cca <initsleeplock>
    bcache.head.next->prev = b;
    80002a86:	2b893783          	ld	a5,696(s2)
    80002a8a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002a8c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002a90:	45848493          	addi	s1,s1,1112
    80002a94:	fd349fe3          	bne	s1,s3,80002a72 <binit+0x50>
  }
}
    80002a98:	70a2                	ld	ra,40(sp)
    80002a9a:	7402                	ld	s0,32(sp)
    80002a9c:	64e2                	ld	s1,24(sp)
    80002a9e:	6942                	ld	s2,16(sp)
    80002aa0:	69a2                	ld	s3,8(sp)
    80002aa2:	6a02                	ld	s4,0(sp)
    80002aa4:	6145                	addi	sp,sp,48
    80002aa6:	8082                	ret

0000000080002aa8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002aa8:	7179                	addi	sp,sp,-48
    80002aaa:	f406                	sd	ra,40(sp)
    80002aac:	f022                	sd	s0,32(sp)
    80002aae:	ec26                	sd	s1,24(sp)
    80002ab0:	e84a                	sd	s2,16(sp)
    80002ab2:	e44e                	sd	s3,8(sp)
    80002ab4:	1800                	addi	s0,sp,48
    80002ab6:	892a                	mv	s2,a0
    80002ab8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002aba:	00013517          	auipc	a0,0x13
    80002abe:	e2e50513          	addi	a0,a0,-466 # 800158e8 <bcache>
    80002ac2:	932fe0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002ac6:	0001b497          	auipc	s1,0x1b
    80002aca:	0da4b483          	ld	s1,218(s1) # 8001dba0 <bcache+0x82b8>
    80002ace:	0001b797          	auipc	a5,0x1b
    80002ad2:	08278793          	addi	a5,a5,130 # 8001db50 <bcache+0x8268>
    80002ad6:	02f48b63          	beq	s1,a5,80002b0c <bread+0x64>
    80002ada:	873e                	mv	a4,a5
    80002adc:	a021                	j	80002ae4 <bread+0x3c>
    80002ade:	68a4                	ld	s1,80(s1)
    80002ae0:	02e48663          	beq	s1,a4,80002b0c <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002ae4:	449c                	lw	a5,8(s1)
    80002ae6:	ff279ce3          	bne	a5,s2,80002ade <bread+0x36>
    80002aea:	44dc                	lw	a5,12(s1)
    80002aec:	ff3799e3          	bne	a5,s3,80002ade <bread+0x36>
      b->refcnt++;
    80002af0:	40bc                	lw	a5,64(s1)
    80002af2:	2785                	addiw	a5,a5,1
    80002af4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002af6:	00013517          	auipc	a0,0x13
    80002afa:	df250513          	addi	a0,a0,-526 # 800158e8 <bcache>
    80002afe:	98efe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002b02:	01048513          	addi	a0,s1,16
    80002b06:	1fa010ef          	jal	80003d00 <acquiresleep>
      return b;
    80002b0a:	a889                	j	80002b5c <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002b0c:	0001b497          	auipc	s1,0x1b
    80002b10:	08c4b483          	ld	s1,140(s1) # 8001db98 <bcache+0x82b0>
    80002b14:	0001b797          	auipc	a5,0x1b
    80002b18:	03c78793          	addi	a5,a5,60 # 8001db50 <bcache+0x8268>
    80002b1c:	00f48863          	beq	s1,a5,80002b2c <bread+0x84>
    80002b20:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002b22:	40bc                	lw	a5,64(s1)
    80002b24:	cb91                	beqz	a5,80002b38 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002b26:	64a4                	ld	s1,72(s1)
    80002b28:	fee49de3          	bne	s1,a4,80002b22 <bread+0x7a>
  panic("bget: no buffers");
    80002b2c:	00005517          	auipc	a0,0x5
    80002b30:	94450513          	addi	a0,a0,-1724 # 80007470 <etext+0x470>
    80002b34:	c61fd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80002b38:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002b3c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002b40:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002b44:	4785                	li	a5,1
    80002b46:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b48:	00013517          	auipc	a0,0x13
    80002b4c:	da050513          	addi	a0,a0,-608 # 800158e8 <bcache>
    80002b50:	93cfe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002b54:	01048513          	addi	a0,s1,16
    80002b58:	1a8010ef          	jal	80003d00 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002b5c:	409c                	lw	a5,0(s1)
    80002b5e:	cb89                	beqz	a5,80002b70 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002b60:	8526                	mv	a0,s1
    80002b62:	70a2                	ld	ra,40(sp)
    80002b64:	7402                	ld	s0,32(sp)
    80002b66:	64e2                	ld	s1,24(sp)
    80002b68:	6942                	ld	s2,16(sp)
    80002b6a:	69a2                	ld	s3,8(sp)
    80002b6c:	6145                	addi	sp,sp,48
    80002b6e:	8082                	ret
    virtio_disk_rw(b, 0);
    80002b70:	4581                	li	a1,0
    80002b72:	8526                	mv	a0,s1
    80002b74:	1ed020ef          	jal	80005560 <virtio_disk_rw>
    b->valid = 1;
    80002b78:	4785                	li	a5,1
    80002b7a:	c09c                	sw	a5,0(s1)
  return b;
    80002b7c:	b7d5                	j	80002b60 <bread+0xb8>

0000000080002b7e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002b7e:	1101                	addi	sp,sp,-32
    80002b80:	ec06                	sd	ra,24(sp)
    80002b82:	e822                	sd	s0,16(sp)
    80002b84:	e426                	sd	s1,8(sp)
    80002b86:	1000                	addi	s0,sp,32
    80002b88:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002b8a:	0541                	addi	a0,a0,16
    80002b8c:	1f2010ef          	jal	80003d7e <holdingsleep>
    80002b90:	c911                	beqz	a0,80002ba4 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002b92:	4585                	li	a1,1
    80002b94:	8526                	mv	a0,s1
    80002b96:	1cb020ef          	jal	80005560 <virtio_disk_rw>
}
    80002b9a:	60e2                	ld	ra,24(sp)
    80002b9c:	6442                	ld	s0,16(sp)
    80002b9e:	64a2                	ld	s1,8(sp)
    80002ba0:	6105                	addi	sp,sp,32
    80002ba2:	8082                	ret
    panic("bwrite");
    80002ba4:	00005517          	auipc	a0,0x5
    80002ba8:	8e450513          	addi	a0,a0,-1820 # 80007488 <etext+0x488>
    80002bac:	be9fd0ef          	jal	80000794 <panic>

0000000080002bb0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002bb0:	1101                	addi	sp,sp,-32
    80002bb2:	ec06                	sd	ra,24(sp)
    80002bb4:	e822                	sd	s0,16(sp)
    80002bb6:	e426                	sd	s1,8(sp)
    80002bb8:	e04a                	sd	s2,0(sp)
    80002bba:	1000                	addi	s0,sp,32
    80002bbc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002bbe:	01050913          	addi	s2,a0,16
    80002bc2:	854a                	mv	a0,s2
    80002bc4:	1ba010ef          	jal	80003d7e <holdingsleep>
    80002bc8:	c135                	beqz	a0,80002c2c <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002bca:	854a                	mv	a0,s2
    80002bcc:	17a010ef          	jal	80003d46 <releasesleep>

  acquire(&bcache.lock);
    80002bd0:	00013517          	auipc	a0,0x13
    80002bd4:	d1850513          	addi	a0,a0,-744 # 800158e8 <bcache>
    80002bd8:	81cfe0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002bdc:	40bc                	lw	a5,64(s1)
    80002bde:	37fd                	addiw	a5,a5,-1
    80002be0:	0007871b          	sext.w	a4,a5
    80002be4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002be6:	e71d                	bnez	a4,80002c14 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002be8:	68b8                	ld	a4,80(s1)
    80002bea:	64bc                	ld	a5,72(s1)
    80002bec:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002bee:	68b8                	ld	a4,80(s1)
    80002bf0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002bf2:	0001b797          	auipc	a5,0x1b
    80002bf6:	cf678793          	addi	a5,a5,-778 # 8001d8e8 <bcache+0x8000>
    80002bfa:	2b87b703          	ld	a4,696(a5)
    80002bfe:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002c00:	0001b717          	auipc	a4,0x1b
    80002c04:	f5070713          	addi	a4,a4,-176 # 8001db50 <bcache+0x8268>
    80002c08:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002c0a:	2b87b703          	ld	a4,696(a5)
    80002c0e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002c10:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002c14:	00013517          	auipc	a0,0x13
    80002c18:	cd450513          	addi	a0,a0,-812 # 800158e8 <bcache>
    80002c1c:	870fe0ef          	jal	80000c8c <release>
}
    80002c20:	60e2                	ld	ra,24(sp)
    80002c22:	6442                	ld	s0,16(sp)
    80002c24:	64a2                	ld	s1,8(sp)
    80002c26:	6902                	ld	s2,0(sp)
    80002c28:	6105                	addi	sp,sp,32
    80002c2a:	8082                	ret
    panic("brelse");
    80002c2c:	00005517          	auipc	a0,0x5
    80002c30:	86450513          	addi	a0,a0,-1948 # 80007490 <etext+0x490>
    80002c34:	b61fd0ef          	jal	80000794 <panic>

0000000080002c38 <bpin>:

void
bpin(struct buf *b) {
    80002c38:	1101                	addi	sp,sp,-32
    80002c3a:	ec06                	sd	ra,24(sp)
    80002c3c:	e822                	sd	s0,16(sp)
    80002c3e:	e426                	sd	s1,8(sp)
    80002c40:	1000                	addi	s0,sp,32
    80002c42:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002c44:	00013517          	auipc	a0,0x13
    80002c48:	ca450513          	addi	a0,a0,-860 # 800158e8 <bcache>
    80002c4c:	fa9fd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80002c50:	40bc                	lw	a5,64(s1)
    80002c52:	2785                	addiw	a5,a5,1
    80002c54:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002c56:	00013517          	auipc	a0,0x13
    80002c5a:	c9250513          	addi	a0,a0,-878 # 800158e8 <bcache>
    80002c5e:	82efe0ef          	jal	80000c8c <release>
}
    80002c62:	60e2                	ld	ra,24(sp)
    80002c64:	6442                	ld	s0,16(sp)
    80002c66:	64a2                	ld	s1,8(sp)
    80002c68:	6105                	addi	sp,sp,32
    80002c6a:	8082                	ret

0000000080002c6c <bunpin>:

void
bunpin(struct buf *b) {
    80002c6c:	1101                	addi	sp,sp,-32
    80002c6e:	ec06                	sd	ra,24(sp)
    80002c70:	e822                	sd	s0,16(sp)
    80002c72:	e426                	sd	s1,8(sp)
    80002c74:	1000                	addi	s0,sp,32
    80002c76:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002c78:	00013517          	auipc	a0,0x13
    80002c7c:	c7050513          	addi	a0,a0,-912 # 800158e8 <bcache>
    80002c80:	f75fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002c84:	40bc                	lw	a5,64(s1)
    80002c86:	37fd                	addiw	a5,a5,-1
    80002c88:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002c8a:	00013517          	auipc	a0,0x13
    80002c8e:	c5e50513          	addi	a0,a0,-930 # 800158e8 <bcache>
    80002c92:	ffbfd0ef          	jal	80000c8c <release>
}
    80002c96:	60e2                	ld	ra,24(sp)
    80002c98:	6442                	ld	s0,16(sp)
    80002c9a:	64a2                	ld	s1,8(sp)
    80002c9c:	6105                	addi	sp,sp,32
    80002c9e:	8082                	ret

0000000080002ca0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002ca0:	1101                	addi	sp,sp,-32
    80002ca2:	ec06                	sd	ra,24(sp)
    80002ca4:	e822                	sd	s0,16(sp)
    80002ca6:	e426                	sd	s1,8(sp)
    80002ca8:	e04a                	sd	s2,0(sp)
    80002caa:	1000                	addi	s0,sp,32
    80002cac:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002cae:	00d5d59b          	srliw	a1,a1,0xd
    80002cb2:	0001b797          	auipc	a5,0x1b
    80002cb6:	3127a783          	lw	a5,786(a5) # 8001dfc4 <sb+0x1c>
    80002cba:	9dbd                	addw	a1,a1,a5
    80002cbc:	dedff0ef          	jal	80002aa8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002cc0:	0074f713          	andi	a4,s1,7
    80002cc4:	4785                	li	a5,1
    80002cc6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002cca:	14ce                	slli	s1,s1,0x33
    80002ccc:	90d9                	srli	s1,s1,0x36
    80002cce:	00950733          	add	a4,a0,s1
    80002cd2:	05874703          	lbu	a4,88(a4)
    80002cd6:	00e7f6b3          	and	a3,a5,a4
    80002cda:	c29d                	beqz	a3,80002d00 <bfree+0x60>
    80002cdc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002cde:	94aa                	add	s1,s1,a0
    80002ce0:	fff7c793          	not	a5,a5
    80002ce4:	8f7d                	and	a4,a4,a5
    80002ce6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002cea:	711000ef          	jal	80003bfa <log_write>
  brelse(bp);
    80002cee:	854a                	mv	a0,s2
    80002cf0:	ec1ff0ef          	jal	80002bb0 <brelse>
}
    80002cf4:	60e2                	ld	ra,24(sp)
    80002cf6:	6442                	ld	s0,16(sp)
    80002cf8:	64a2                	ld	s1,8(sp)
    80002cfa:	6902                	ld	s2,0(sp)
    80002cfc:	6105                	addi	sp,sp,32
    80002cfe:	8082                	ret
    panic("freeing free block");
    80002d00:	00004517          	auipc	a0,0x4
    80002d04:	79850513          	addi	a0,a0,1944 # 80007498 <etext+0x498>
    80002d08:	a8dfd0ef          	jal	80000794 <panic>

0000000080002d0c <balloc>:
{
    80002d0c:	711d                	addi	sp,sp,-96
    80002d0e:	ec86                	sd	ra,88(sp)
    80002d10:	e8a2                	sd	s0,80(sp)
    80002d12:	e4a6                	sd	s1,72(sp)
    80002d14:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002d16:	0001b797          	auipc	a5,0x1b
    80002d1a:	2967a783          	lw	a5,662(a5) # 8001dfac <sb+0x4>
    80002d1e:	0e078f63          	beqz	a5,80002e1c <balloc+0x110>
    80002d22:	e0ca                	sd	s2,64(sp)
    80002d24:	fc4e                	sd	s3,56(sp)
    80002d26:	f852                	sd	s4,48(sp)
    80002d28:	f456                	sd	s5,40(sp)
    80002d2a:	f05a                	sd	s6,32(sp)
    80002d2c:	ec5e                	sd	s7,24(sp)
    80002d2e:	e862                	sd	s8,16(sp)
    80002d30:	e466                	sd	s9,8(sp)
    80002d32:	8baa                	mv	s7,a0
    80002d34:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002d36:	0001bb17          	auipc	s6,0x1b
    80002d3a:	272b0b13          	addi	s6,s6,626 # 8001dfa8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002d3e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002d40:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002d42:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002d44:	6c89                	lui	s9,0x2
    80002d46:	a0b5                	j	80002db2 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002d48:	97ca                	add	a5,a5,s2
    80002d4a:	8e55                	or	a2,a2,a3
    80002d4c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002d50:	854a                	mv	a0,s2
    80002d52:	6a9000ef          	jal	80003bfa <log_write>
        brelse(bp);
    80002d56:	854a                	mv	a0,s2
    80002d58:	e59ff0ef          	jal	80002bb0 <brelse>
  bp = bread(dev, bno);
    80002d5c:	85a6                	mv	a1,s1
    80002d5e:	855e                	mv	a0,s7
    80002d60:	d49ff0ef          	jal	80002aa8 <bread>
    80002d64:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002d66:	40000613          	li	a2,1024
    80002d6a:	4581                	li	a1,0
    80002d6c:	05850513          	addi	a0,a0,88
    80002d70:	f59fd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80002d74:	854a                	mv	a0,s2
    80002d76:	685000ef          	jal	80003bfa <log_write>
  brelse(bp);
    80002d7a:	854a                	mv	a0,s2
    80002d7c:	e35ff0ef          	jal	80002bb0 <brelse>
}
    80002d80:	6906                	ld	s2,64(sp)
    80002d82:	79e2                	ld	s3,56(sp)
    80002d84:	7a42                	ld	s4,48(sp)
    80002d86:	7aa2                	ld	s5,40(sp)
    80002d88:	7b02                	ld	s6,32(sp)
    80002d8a:	6be2                	ld	s7,24(sp)
    80002d8c:	6c42                	ld	s8,16(sp)
    80002d8e:	6ca2                	ld	s9,8(sp)
}
    80002d90:	8526                	mv	a0,s1
    80002d92:	60e6                	ld	ra,88(sp)
    80002d94:	6446                	ld	s0,80(sp)
    80002d96:	64a6                	ld	s1,72(sp)
    80002d98:	6125                	addi	sp,sp,96
    80002d9a:	8082                	ret
    brelse(bp);
    80002d9c:	854a                	mv	a0,s2
    80002d9e:	e13ff0ef          	jal	80002bb0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002da2:	015c87bb          	addw	a5,s9,s5
    80002da6:	00078a9b          	sext.w	s5,a5
    80002daa:	004b2703          	lw	a4,4(s6)
    80002dae:	04eaff63          	bgeu	s5,a4,80002e0c <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002db2:	41fad79b          	sraiw	a5,s5,0x1f
    80002db6:	0137d79b          	srliw	a5,a5,0x13
    80002dba:	015787bb          	addw	a5,a5,s5
    80002dbe:	40d7d79b          	sraiw	a5,a5,0xd
    80002dc2:	01cb2583          	lw	a1,28(s6)
    80002dc6:	9dbd                	addw	a1,a1,a5
    80002dc8:	855e                	mv	a0,s7
    80002dca:	cdfff0ef          	jal	80002aa8 <bread>
    80002dce:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002dd0:	004b2503          	lw	a0,4(s6)
    80002dd4:	000a849b          	sext.w	s1,s5
    80002dd8:	8762                	mv	a4,s8
    80002dda:	fca4f1e3          	bgeu	s1,a0,80002d9c <balloc+0x90>
      m = 1 << (bi % 8);
    80002dde:	00777693          	andi	a3,a4,7
    80002de2:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002de6:	41f7579b          	sraiw	a5,a4,0x1f
    80002dea:	01d7d79b          	srliw	a5,a5,0x1d
    80002dee:	9fb9                	addw	a5,a5,a4
    80002df0:	4037d79b          	sraiw	a5,a5,0x3
    80002df4:	00f90633          	add	a2,s2,a5
    80002df8:	05864603          	lbu	a2,88(a2)
    80002dfc:	00c6f5b3          	and	a1,a3,a2
    80002e00:	d5a1                	beqz	a1,80002d48 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e02:	2705                	addiw	a4,a4,1
    80002e04:	2485                	addiw	s1,s1,1
    80002e06:	fd471ae3          	bne	a4,s4,80002dda <balloc+0xce>
    80002e0a:	bf49                	j	80002d9c <balloc+0x90>
    80002e0c:	6906                	ld	s2,64(sp)
    80002e0e:	79e2                	ld	s3,56(sp)
    80002e10:	7a42                	ld	s4,48(sp)
    80002e12:	7aa2                	ld	s5,40(sp)
    80002e14:	7b02                	ld	s6,32(sp)
    80002e16:	6be2                	ld	s7,24(sp)
    80002e18:	6c42                	ld	s8,16(sp)
    80002e1a:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002e1c:	00004517          	auipc	a0,0x4
    80002e20:	69450513          	addi	a0,a0,1684 # 800074b0 <etext+0x4b0>
    80002e24:	e9efd0ef          	jal	800004c2 <printf>
  return 0;
    80002e28:	4481                	li	s1,0
    80002e2a:	b79d                	j	80002d90 <balloc+0x84>

0000000080002e2c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002e2c:	7179                	addi	sp,sp,-48
    80002e2e:	f406                	sd	ra,40(sp)
    80002e30:	f022                	sd	s0,32(sp)
    80002e32:	ec26                	sd	s1,24(sp)
    80002e34:	e84a                	sd	s2,16(sp)
    80002e36:	e44e                	sd	s3,8(sp)
    80002e38:	1800                	addi	s0,sp,48
    80002e3a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002e3c:	47ad                	li	a5,11
    80002e3e:	02b7e663          	bltu	a5,a1,80002e6a <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002e42:	02059793          	slli	a5,a1,0x20
    80002e46:	01e7d593          	srli	a1,a5,0x1e
    80002e4a:	00b504b3          	add	s1,a0,a1
    80002e4e:	0504a903          	lw	s2,80(s1)
    80002e52:	06091a63          	bnez	s2,80002ec6 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002e56:	4108                	lw	a0,0(a0)
    80002e58:	eb5ff0ef          	jal	80002d0c <balloc>
    80002e5c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002e60:	06090363          	beqz	s2,80002ec6 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002e64:	0524a823          	sw	s2,80(s1)
    80002e68:	a8b9                	j	80002ec6 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002e6a:	ff45849b          	addiw	s1,a1,-12
    80002e6e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002e72:	0ff00793          	li	a5,255
    80002e76:	06e7ee63          	bltu	a5,a4,80002ef2 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002e7a:	08052903          	lw	s2,128(a0)
    80002e7e:	00091d63          	bnez	s2,80002e98 <bmap+0x6c>
      addr = balloc(ip->dev);
    80002e82:	4108                	lw	a0,0(a0)
    80002e84:	e89ff0ef          	jal	80002d0c <balloc>
    80002e88:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002e8c:	02090d63          	beqz	s2,80002ec6 <bmap+0x9a>
    80002e90:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002e92:	0929a023          	sw	s2,128(s3)
    80002e96:	a011                	j	80002e9a <bmap+0x6e>
    80002e98:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002e9a:	85ca                	mv	a1,s2
    80002e9c:	0009a503          	lw	a0,0(s3)
    80002ea0:	c09ff0ef          	jal	80002aa8 <bread>
    80002ea4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002ea6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002eaa:	02049713          	slli	a4,s1,0x20
    80002eae:	01e75593          	srli	a1,a4,0x1e
    80002eb2:	00b784b3          	add	s1,a5,a1
    80002eb6:	0004a903          	lw	s2,0(s1)
    80002eba:	00090e63          	beqz	s2,80002ed6 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002ebe:	8552                	mv	a0,s4
    80002ec0:	cf1ff0ef          	jal	80002bb0 <brelse>
    return addr;
    80002ec4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002ec6:	854a                	mv	a0,s2
    80002ec8:	70a2                	ld	ra,40(sp)
    80002eca:	7402                	ld	s0,32(sp)
    80002ecc:	64e2                	ld	s1,24(sp)
    80002ece:	6942                	ld	s2,16(sp)
    80002ed0:	69a2                	ld	s3,8(sp)
    80002ed2:	6145                	addi	sp,sp,48
    80002ed4:	8082                	ret
      addr = balloc(ip->dev);
    80002ed6:	0009a503          	lw	a0,0(s3)
    80002eda:	e33ff0ef          	jal	80002d0c <balloc>
    80002ede:	0005091b          	sext.w	s2,a0
      if(addr){
    80002ee2:	fc090ee3          	beqz	s2,80002ebe <bmap+0x92>
        a[bn] = addr;
    80002ee6:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002eea:	8552                	mv	a0,s4
    80002eec:	50f000ef          	jal	80003bfa <log_write>
    80002ef0:	b7f9                	j	80002ebe <bmap+0x92>
    80002ef2:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002ef4:	00004517          	auipc	a0,0x4
    80002ef8:	5d450513          	addi	a0,a0,1492 # 800074c8 <etext+0x4c8>
    80002efc:	899fd0ef          	jal	80000794 <panic>

0000000080002f00 <iget>:
{
    80002f00:	7179                	addi	sp,sp,-48
    80002f02:	f406                	sd	ra,40(sp)
    80002f04:	f022                	sd	s0,32(sp)
    80002f06:	ec26                	sd	s1,24(sp)
    80002f08:	e84a                	sd	s2,16(sp)
    80002f0a:	e44e                	sd	s3,8(sp)
    80002f0c:	e052                	sd	s4,0(sp)
    80002f0e:	1800                	addi	s0,sp,48
    80002f10:	89aa                	mv	s3,a0
    80002f12:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002f14:	0001b517          	auipc	a0,0x1b
    80002f18:	0b450513          	addi	a0,a0,180 # 8001dfc8 <itable>
    80002f1c:	cd9fd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    80002f20:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002f22:	0001b497          	auipc	s1,0x1b
    80002f26:	0be48493          	addi	s1,s1,190 # 8001dfe0 <itable+0x18>
    80002f2a:	0001d697          	auipc	a3,0x1d
    80002f2e:	b4668693          	addi	a3,a3,-1210 # 8001fa70 <log>
    80002f32:	a039                	j	80002f40 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002f34:	02090963          	beqz	s2,80002f66 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002f38:	08848493          	addi	s1,s1,136
    80002f3c:	02d48863          	beq	s1,a3,80002f6c <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002f40:	449c                	lw	a5,8(s1)
    80002f42:	fef059e3          	blez	a5,80002f34 <iget+0x34>
    80002f46:	4098                	lw	a4,0(s1)
    80002f48:	ff3716e3          	bne	a4,s3,80002f34 <iget+0x34>
    80002f4c:	40d8                	lw	a4,4(s1)
    80002f4e:	ff4713e3          	bne	a4,s4,80002f34 <iget+0x34>
      ip->ref++;
    80002f52:	2785                	addiw	a5,a5,1
    80002f54:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002f56:	0001b517          	auipc	a0,0x1b
    80002f5a:	07250513          	addi	a0,a0,114 # 8001dfc8 <itable>
    80002f5e:	d2ffd0ef          	jal	80000c8c <release>
      return ip;
    80002f62:	8926                	mv	s2,s1
    80002f64:	a02d                	j	80002f8e <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002f66:	fbe9                	bnez	a5,80002f38 <iget+0x38>
      empty = ip;
    80002f68:	8926                	mv	s2,s1
    80002f6a:	b7f9                	j	80002f38 <iget+0x38>
  if(empty == 0)
    80002f6c:	02090a63          	beqz	s2,80002fa0 <iget+0xa0>
  ip->dev = dev;
    80002f70:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002f74:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002f78:	4785                	li	a5,1
    80002f7a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002f7e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002f82:	0001b517          	auipc	a0,0x1b
    80002f86:	04650513          	addi	a0,a0,70 # 8001dfc8 <itable>
    80002f8a:	d03fd0ef          	jal	80000c8c <release>
}
    80002f8e:	854a                	mv	a0,s2
    80002f90:	70a2                	ld	ra,40(sp)
    80002f92:	7402                	ld	s0,32(sp)
    80002f94:	64e2                	ld	s1,24(sp)
    80002f96:	6942                	ld	s2,16(sp)
    80002f98:	69a2                	ld	s3,8(sp)
    80002f9a:	6a02                	ld	s4,0(sp)
    80002f9c:	6145                	addi	sp,sp,48
    80002f9e:	8082                	ret
    panic("iget: no inodes");
    80002fa0:	00004517          	auipc	a0,0x4
    80002fa4:	54050513          	addi	a0,a0,1344 # 800074e0 <etext+0x4e0>
    80002fa8:	fecfd0ef          	jal	80000794 <panic>

0000000080002fac <fsinit>:
fsinit(int dev) {
    80002fac:	7179                	addi	sp,sp,-48
    80002fae:	f406                	sd	ra,40(sp)
    80002fb0:	f022                	sd	s0,32(sp)
    80002fb2:	ec26                	sd	s1,24(sp)
    80002fb4:	e84a                	sd	s2,16(sp)
    80002fb6:	e44e                	sd	s3,8(sp)
    80002fb8:	1800                	addi	s0,sp,48
    80002fba:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002fbc:	4585                	li	a1,1
    80002fbe:	aebff0ef          	jal	80002aa8 <bread>
    80002fc2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002fc4:	0001b997          	auipc	s3,0x1b
    80002fc8:	fe498993          	addi	s3,s3,-28 # 8001dfa8 <sb>
    80002fcc:	02000613          	li	a2,32
    80002fd0:	05850593          	addi	a1,a0,88
    80002fd4:	854e                	mv	a0,s3
    80002fd6:	d4ffd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    80002fda:	8526                	mv	a0,s1
    80002fdc:	bd5ff0ef          	jal	80002bb0 <brelse>
  if(sb.magic != FSMAGIC)
    80002fe0:	0009a703          	lw	a4,0(s3)
    80002fe4:	102037b7          	lui	a5,0x10203
    80002fe8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002fec:	02f71063          	bne	a4,a5,8000300c <fsinit+0x60>
  initlog(dev, &sb);
    80002ff0:	0001b597          	auipc	a1,0x1b
    80002ff4:	fb858593          	addi	a1,a1,-72 # 8001dfa8 <sb>
    80002ff8:	854a                	mv	a0,s2
    80002ffa:	1f9000ef          	jal	800039f2 <initlog>
}
    80002ffe:	70a2                	ld	ra,40(sp)
    80003000:	7402                	ld	s0,32(sp)
    80003002:	64e2                	ld	s1,24(sp)
    80003004:	6942                	ld	s2,16(sp)
    80003006:	69a2                	ld	s3,8(sp)
    80003008:	6145                	addi	sp,sp,48
    8000300a:	8082                	ret
    panic("invalid file system");
    8000300c:	00004517          	auipc	a0,0x4
    80003010:	4e450513          	addi	a0,a0,1252 # 800074f0 <etext+0x4f0>
    80003014:	f80fd0ef          	jal	80000794 <panic>

0000000080003018 <iinit>:
{
    80003018:	7179                	addi	sp,sp,-48
    8000301a:	f406                	sd	ra,40(sp)
    8000301c:	f022                	sd	s0,32(sp)
    8000301e:	ec26                	sd	s1,24(sp)
    80003020:	e84a                	sd	s2,16(sp)
    80003022:	e44e                	sd	s3,8(sp)
    80003024:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003026:	00004597          	auipc	a1,0x4
    8000302a:	4e258593          	addi	a1,a1,1250 # 80007508 <etext+0x508>
    8000302e:	0001b517          	auipc	a0,0x1b
    80003032:	f9a50513          	addi	a0,a0,-102 # 8001dfc8 <itable>
    80003036:	b3ffd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000303a:	0001b497          	auipc	s1,0x1b
    8000303e:	fb648493          	addi	s1,s1,-74 # 8001dff0 <itable+0x28>
    80003042:	0001d997          	auipc	s3,0x1d
    80003046:	a3e98993          	addi	s3,s3,-1474 # 8001fa80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000304a:	00004917          	auipc	s2,0x4
    8000304e:	4c690913          	addi	s2,s2,1222 # 80007510 <etext+0x510>
    80003052:	85ca                	mv	a1,s2
    80003054:	8526                	mv	a0,s1
    80003056:	475000ef          	jal	80003cca <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000305a:	08848493          	addi	s1,s1,136
    8000305e:	ff349ae3          	bne	s1,s3,80003052 <iinit+0x3a>
}
    80003062:	70a2                	ld	ra,40(sp)
    80003064:	7402                	ld	s0,32(sp)
    80003066:	64e2                	ld	s1,24(sp)
    80003068:	6942                	ld	s2,16(sp)
    8000306a:	69a2                	ld	s3,8(sp)
    8000306c:	6145                	addi	sp,sp,48
    8000306e:	8082                	ret

0000000080003070 <ialloc>:
{
    80003070:	7139                	addi	sp,sp,-64
    80003072:	fc06                	sd	ra,56(sp)
    80003074:	f822                	sd	s0,48(sp)
    80003076:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003078:	0001b717          	auipc	a4,0x1b
    8000307c:	f3c72703          	lw	a4,-196(a4) # 8001dfb4 <sb+0xc>
    80003080:	4785                	li	a5,1
    80003082:	06e7f063          	bgeu	a5,a4,800030e2 <ialloc+0x72>
    80003086:	f426                	sd	s1,40(sp)
    80003088:	f04a                	sd	s2,32(sp)
    8000308a:	ec4e                	sd	s3,24(sp)
    8000308c:	e852                	sd	s4,16(sp)
    8000308e:	e456                	sd	s5,8(sp)
    80003090:	e05a                	sd	s6,0(sp)
    80003092:	8aaa                	mv	s5,a0
    80003094:	8b2e                	mv	s6,a1
    80003096:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003098:	0001ba17          	auipc	s4,0x1b
    8000309c:	f10a0a13          	addi	s4,s4,-240 # 8001dfa8 <sb>
    800030a0:	00495593          	srli	a1,s2,0x4
    800030a4:	018a2783          	lw	a5,24(s4)
    800030a8:	9dbd                	addw	a1,a1,a5
    800030aa:	8556                	mv	a0,s5
    800030ac:	9fdff0ef          	jal	80002aa8 <bread>
    800030b0:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800030b2:	05850993          	addi	s3,a0,88
    800030b6:	00f97793          	andi	a5,s2,15
    800030ba:	079a                	slli	a5,a5,0x6
    800030bc:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800030be:	00099783          	lh	a5,0(s3)
    800030c2:	cb9d                	beqz	a5,800030f8 <ialloc+0x88>
    brelse(bp);
    800030c4:	aedff0ef          	jal	80002bb0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800030c8:	0905                	addi	s2,s2,1
    800030ca:	00ca2703          	lw	a4,12(s4)
    800030ce:	0009079b          	sext.w	a5,s2
    800030d2:	fce7e7e3          	bltu	a5,a4,800030a0 <ialloc+0x30>
    800030d6:	74a2                	ld	s1,40(sp)
    800030d8:	7902                	ld	s2,32(sp)
    800030da:	69e2                	ld	s3,24(sp)
    800030dc:	6a42                	ld	s4,16(sp)
    800030de:	6aa2                	ld	s5,8(sp)
    800030e0:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800030e2:	00004517          	auipc	a0,0x4
    800030e6:	43650513          	addi	a0,a0,1078 # 80007518 <etext+0x518>
    800030ea:	bd8fd0ef          	jal	800004c2 <printf>
  return 0;
    800030ee:	4501                	li	a0,0
}
    800030f0:	70e2                	ld	ra,56(sp)
    800030f2:	7442                	ld	s0,48(sp)
    800030f4:	6121                	addi	sp,sp,64
    800030f6:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800030f8:	04000613          	li	a2,64
    800030fc:	4581                	li	a1,0
    800030fe:	854e                	mv	a0,s3
    80003100:	bc9fd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    80003104:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003108:	8526                	mv	a0,s1
    8000310a:	2f1000ef          	jal	80003bfa <log_write>
      brelse(bp);
    8000310e:	8526                	mv	a0,s1
    80003110:	aa1ff0ef          	jal	80002bb0 <brelse>
      return iget(dev, inum);
    80003114:	0009059b          	sext.w	a1,s2
    80003118:	8556                	mv	a0,s5
    8000311a:	de7ff0ef          	jal	80002f00 <iget>
    8000311e:	74a2                	ld	s1,40(sp)
    80003120:	7902                	ld	s2,32(sp)
    80003122:	69e2                	ld	s3,24(sp)
    80003124:	6a42                	ld	s4,16(sp)
    80003126:	6aa2                	ld	s5,8(sp)
    80003128:	6b02                	ld	s6,0(sp)
    8000312a:	b7d9                	j	800030f0 <ialloc+0x80>

000000008000312c <iupdate>:
{
    8000312c:	1101                	addi	sp,sp,-32
    8000312e:	ec06                	sd	ra,24(sp)
    80003130:	e822                	sd	s0,16(sp)
    80003132:	e426                	sd	s1,8(sp)
    80003134:	e04a                	sd	s2,0(sp)
    80003136:	1000                	addi	s0,sp,32
    80003138:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000313a:	415c                	lw	a5,4(a0)
    8000313c:	0047d79b          	srliw	a5,a5,0x4
    80003140:	0001b597          	auipc	a1,0x1b
    80003144:	e805a583          	lw	a1,-384(a1) # 8001dfc0 <sb+0x18>
    80003148:	9dbd                	addw	a1,a1,a5
    8000314a:	4108                	lw	a0,0(a0)
    8000314c:	95dff0ef          	jal	80002aa8 <bread>
    80003150:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003152:	05850793          	addi	a5,a0,88
    80003156:	40d8                	lw	a4,4(s1)
    80003158:	8b3d                	andi	a4,a4,15
    8000315a:	071a                	slli	a4,a4,0x6
    8000315c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000315e:	04449703          	lh	a4,68(s1)
    80003162:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003166:	04649703          	lh	a4,70(s1)
    8000316a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000316e:	04849703          	lh	a4,72(s1)
    80003172:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003176:	04a49703          	lh	a4,74(s1)
    8000317a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000317e:	44f8                	lw	a4,76(s1)
    80003180:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003182:	03400613          	li	a2,52
    80003186:	05048593          	addi	a1,s1,80
    8000318a:	00c78513          	addi	a0,a5,12
    8000318e:	b97fd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    80003192:	854a                	mv	a0,s2
    80003194:	267000ef          	jal	80003bfa <log_write>
  brelse(bp);
    80003198:	854a                	mv	a0,s2
    8000319a:	a17ff0ef          	jal	80002bb0 <brelse>
}
    8000319e:	60e2                	ld	ra,24(sp)
    800031a0:	6442                	ld	s0,16(sp)
    800031a2:	64a2                	ld	s1,8(sp)
    800031a4:	6902                	ld	s2,0(sp)
    800031a6:	6105                	addi	sp,sp,32
    800031a8:	8082                	ret

00000000800031aa <idup>:
{
    800031aa:	1101                	addi	sp,sp,-32
    800031ac:	ec06                	sd	ra,24(sp)
    800031ae:	e822                	sd	s0,16(sp)
    800031b0:	e426                	sd	s1,8(sp)
    800031b2:	1000                	addi	s0,sp,32
    800031b4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800031b6:	0001b517          	auipc	a0,0x1b
    800031ba:	e1250513          	addi	a0,a0,-494 # 8001dfc8 <itable>
    800031be:	a37fd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    800031c2:	449c                	lw	a5,8(s1)
    800031c4:	2785                	addiw	a5,a5,1
    800031c6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800031c8:	0001b517          	auipc	a0,0x1b
    800031cc:	e0050513          	addi	a0,a0,-512 # 8001dfc8 <itable>
    800031d0:	abdfd0ef          	jal	80000c8c <release>
}
    800031d4:	8526                	mv	a0,s1
    800031d6:	60e2                	ld	ra,24(sp)
    800031d8:	6442                	ld	s0,16(sp)
    800031da:	64a2                	ld	s1,8(sp)
    800031dc:	6105                	addi	sp,sp,32
    800031de:	8082                	ret

00000000800031e0 <ilock>:
{
    800031e0:	1101                	addi	sp,sp,-32
    800031e2:	ec06                	sd	ra,24(sp)
    800031e4:	e822                	sd	s0,16(sp)
    800031e6:	e426                	sd	s1,8(sp)
    800031e8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800031ea:	cd19                	beqz	a0,80003208 <ilock+0x28>
    800031ec:	84aa                	mv	s1,a0
    800031ee:	451c                	lw	a5,8(a0)
    800031f0:	00f05c63          	blez	a5,80003208 <ilock+0x28>
  acquiresleep(&ip->lock);
    800031f4:	0541                	addi	a0,a0,16
    800031f6:	30b000ef          	jal	80003d00 <acquiresleep>
  if(ip->valid == 0){
    800031fa:	40bc                	lw	a5,64(s1)
    800031fc:	cf89                	beqz	a5,80003216 <ilock+0x36>
}
    800031fe:	60e2                	ld	ra,24(sp)
    80003200:	6442                	ld	s0,16(sp)
    80003202:	64a2                	ld	s1,8(sp)
    80003204:	6105                	addi	sp,sp,32
    80003206:	8082                	ret
    80003208:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000320a:	00004517          	auipc	a0,0x4
    8000320e:	32650513          	addi	a0,a0,806 # 80007530 <etext+0x530>
    80003212:	d82fd0ef          	jal	80000794 <panic>
    80003216:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003218:	40dc                	lw	a5,4(s1)
    8000321a:	0047d79b          	srliw	a5,a5,0x4
    8000321e:	0001b597          	auipc	a1,0x1b
    80003222:	da25a583          	lw	a1,-606(a1) # 8001dfc0 <sb+0x18>
    80003226:	9dbd                	addw	a1,a1,a5
    80003228:	4088                	lw	a0,0(s1)
    8000322a:	87fff0ef          	jal	80002aa8 <bread>
    8000322e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003230:	05850593          	addi	a1,a0,88
    80003234:	40dc                	lw	a5,4(s1)
    80003236:	8bbd                	andi	a5,a5,15
    80003238:	079a                	slli	a5,a5,0x6
    8000323a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000323c:	00059783          	lh	a5,0(a1)
    80003240:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003244:	00259783          	lh	a5,2(a1)
    80003248:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000324c:	00459783          	lh	a5,4(a1)
    80003250:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003254:	00659783          	lh	a5,6(a1)
    80003258:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000325c:	459c                	lw	a5,8(a1)
    8000325e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003260:	03400613          	li	a2,52
    80003264:	05b1                	addi	a1,a1,12
    80003266:	05048513          	addi	a0,s1,80
    8000326a:	abbfd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    8000326e:	854a                	mv	a0,s2
    80003270:	941ff0ef          	jal	80002bb0 <brelse>
    ip->valid = 1;
    80003274:	4785                	li	a5,1
    80003276:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003278:	04449783          	lh	a5,68(s1)
    8000327c:	c399                	beqz	a5,80003282 <ilock+0xa2>
    8000327e:	6902                	ld	s2,0(sp)
    80003280:	bfbd                	j	800031fe <ilock+0x1e>
      panic("ilock: no type");
    80003282:	00004517          	auipc	a0,0x4
    80003286:	2b650513          	addi	a0,a0,694 # 80007538 <etext+0x538>
    8000328a:	d0afd0ef          	jal	80000794 <panic>

000000008000328e <iunlock>:
{
    8000328e:	1101                	addi	sp,sp,-32
    80003290:	ec06                	sd	ra,24(sp)
    80003292:	e822                	sd	s0,16(sp)
    80003294:	e426                	sd	s1,8(sp)
    80003296:	e04a                	sd	s2,0(sp)
    80003298:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000329a:	c505                	beqz	a0,800032c2 <iunlock+0x34>
    8000329c:	84aa                	mv	s1,a0
    8000329e:	01050913          	addi	s2,a0,16
    800032a2:	854a                	mv	a0,s2
    800032a4:	2db000ef          	jal	80003d7e <holdingsleep>
    800032a8:	cd09                	beqz	a0,800032c2 <iunlock+0x34>
    800032aa:	449c                	lw	a5,8(s1)
    800032ac:	00f05b63          	blez	a5,800032c2 <iunlock+0x34>
  releasesleep(&ip->lock);
    800032b0:	854a                	mv	a0,s2
    800032b2:	295000ef          	jal	80003d46 <releasesleep>
}
    800032b6:	60e2                	ld	ra,24(sp)
    800032b8:	6442                	ld	s0,16(sp)
    800032ba:	64a2                	ld	s1,8(sp)
    800032bc:	6902                	ld	s2,0(sp)
    800032be:	6105                	addi	sp,sp,32
    800032c0:	8082                	ret
    panic("iunlock");
    800032c2:	00004517          	auipc	a0,0x4
    800032c6:	28650513          	addi	a0,a0,646 # 80007548 <etext+0x548>
    800032ca:	ccafd0ef          	jal	80000794 <panic>

00000000800032ce <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800032ce:	7179                	addi	sp,sp,-48
    800032d0:	f406                	sd	ra,40(sp)
    800032d2:	f022                	sd	s0,32(sp)
    800032d4:	ec26                	sd	s1,24(sp)
    800032d6:	e84a                	sd	s2,16(sp)
    800032d8:	e44e                	sd	s3,8(sp)
    800032da:	1800                	addi	s0,sp,48
    800032dc:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800032de:	05050493          	addi	s1,a0,80
    800032e2:	08050913          	addi	s2,a0,128
    800032e6:	a021                	j	800032ee <itrunc+0x20>
    800032e8:	0491                	addi	s1,s1,4
    800032ea:	01248b63          	beq	s1,s2,80003300 <itrunc+0x32>
    if(ip->addrs[i]){
    800032ee:	408c                	lw	a1,0(s1)
    800032f0:	dde5                	beqz	a1,800032e8 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800032f2:	0009a503          	lw	a0,0(s3)
    800032f6:	9abff0ef          	jal	80002ca0 <bfree>
      ip->addrs[i] = 0;
    800032fa:	0004a023          	sw	zero,0(s1)
    800032fe:	b7ed                	j	800032e8 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003300:	0809a583          	lw	a1,128(s3)
    80003304:	ed89                	bnez	a1,8000331e <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003306:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000330a:	854e                	mv	a0,s3
    8000330c:	e21ff0ef          	jal	8000312c <iupdate>
}
    80003310:	70a2                	ld	ra,40(sp)
    80003312:	7402                	ld	s0,32(sp)
    80003314:	64e2                	ld	s1,24(sp)
    80003316:	6942                	ld	s2,16(sp)
    80003318:	69a2                	ld	s3,8(sp)
    8000331a:	6145                	addi	sp,sp,48
    8000331c:	8082                	ret
    8000331e:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003320:	0009a503          	lw	a0,0(s3)
    80003324:	f84ff0ef          	jal	80002aa8 <bread>
    80003328:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000332a:	05850493          	addi	s1,a0,88
    8000332e:	45850913          	addi	s2,a0,1112
    80003332:	a021                	j	8000333a <itrunc+0x6c>
    80003334:	0491                	addi	s1,s1,4
    80003336:	01248963          	beq	s1,s2,80003348 <itrunc+0x7a>
      if(a[j])
    8000333a:	408c                	lw	a1,0(s1)
    8000333c:	dde5                	beqz	a1,80003334 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000333e:	0009a503          	lw	a0,0(s3)
    80003342:	95fff0ef          	jal	80002ca0 <bfree>
    80003346:	b7fd                	j	80003334 <itrunc+0x66>
    brelse(bp);
    80003348:	8552                	mv	a0,s4
    8000334a:	867ff0ef          	jal	80002bb0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000334e:	0809a583          	lw	a1,128(s3)
    80003352:	0009a503          	lw	a0,0(s3)
    80003356:	94bff0ef          	jal	80002ca0 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000335a:	0809a023          	sw	zero,128(s3)
    8000335e:	6a02                	ld	s4,0(sp)
    80003360:	b75d                	j	80003306 <itrunc+0x38>

0000000080003362 <iput>:
{
    80003362:	1101                	addi	sp,sp,-32
    80003364:	ec06                	sd	ra,24(sp)
    80003366:	e822                	sd	s0,16(sp)
    80003368:	e426                	sd	s1,8(sp)
    8000336a:	1000                	addi	s0,sp,32
    8000336c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000336e:	0001b517          	auipc	a0,0x1b
    80003372:	c5a50513          	addi	a0,a0,-934 # 8001dfc8 <itable>
    80003376:	87ffd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000337a:	4498                	lw	a4,8(s1)
    8000337c:	4785                	li	a5,1
    8000337e:	02f70063          	beq	a4,a5,8000339e <iput+0x3c>
  ip->ref--;
    80003382:	449c                	lw	a5,8(s1)
    80003384:	37fd                	addiw	a5,a5,-1
    80003386:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003388:	0001b517          	auipc	a0,0x1b
    8000338c:	c4050513          	addi	a0,a0,-960 # 8001dfc8 <itable>
    80003390:	8fdfd0ef          	jal	80000c8c <release>
}
    80003394:	60e2                	ld	ra,24(sp)
    80003396:	6442                	ld	s0,16(sp)
    80003398:	64a2                	ld	s1,8(sp)
    8000339a:	6105                	addi	sp,sp,32
    8000339c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000339e:	40bc                	lw	a5,64(s1)
    800033a0:	d3ed                	beqz	a5,80003382 <iput+0x20>
    800033a2:	04a49783          	lh	a5,74(s1)
    800033a6:	fff1                	bnez	a5,80003382 <iput+0x20>
    800033a8:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800033aa:	01048913          	addi	s2,s1,16
    800033ae:	854a                	mv	a0,s2
    800033b0:	151000ef          	jal	80003d00 <acquiresleep>
    release(&itable.lock);
    800033b4:	0001b517          	auipc	a0,0x1b
    800033b8:	c1450513          	addi	a0,a0,-1004 # 8001dfc8 <itable>
    800033bc:	8d1fd0ef          	jal	80000c8c <release>
    itrunc(ip);
    800033c0:	8526                	mv	a0,s1
    800033c2:	f0dff0ef          	jal	800032ce <itrunc>
    ip->type = 0;
    800033c6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800033ca:	8526                	mv	a0,s1
    800033cc:	d61ff0ef          	jal	8000312c <iupdate>
    ip->valid = 0;
    800033d0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800033d4:	854a                	mv	a0,s2
    800033d6:	171000ef          	jal	80003d46 <releasesleep>
    acquire(&itable.lock);
    800033da:	0001b517          	auipc	a0,0x1b
    800033de:	bee50513          	addi	a0,a0,-1042 # 8001dfc8 <itable>
    800033e2:	813fd0ef          	jal	80000bf4 <acquire>
    800033e6:	6902                	ld	s2,0(sp)
    800033e8:	bf69                	j	80003382 <iput+0x20>

00000000800033ea <iunlockput>:
{
    800033ea:	1101                	addi	sp,sp,-32
    800033ec:	ec06                	sd	ra,24(sp)
    800033ee:	e822                	sd	s0,16(sp)
    800033f0:	e426                	sd	s1,8(sp)
    800033f2:	1000                	addi	s0,sp,32
    800033f4:	84aa                	mv	s1,a0
  iunlock(ip);
    800033f6:	e99ff0ef          	jal	8000328e <iunlock>
  iput(ip);
    800033fa:	8526                	mv	a0,s1
    800033fc:	f67ff0ef          	jal	80003362 <iput>
}
    80003400:	60e2                	ld	ra,24(sp)
    80003402:	6442                	ld	s0,16(sp)
    80003404:	64a2                	ld	s1,8(sp)
    80003406:	6105                	addi	sp,sp,32
    80003408:	8082                	ret

000000008000340a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000340a:	1141                	addi	sp,sp,-16
    8000340c:	e422                	sd	s0,8(sp)
    8000340e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003410:	411c                	lw	a5,0(a0)
    80003412:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003414:	415c                	lw	a5,4(a0)
    80003416:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003418:	04451783          	lh	a5,68(a0)
    8000341c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003420:	04a51783          	lh	a5,74(a0)
    80003424:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003428:	04c56783          	lwu	a5,76(a0)
    8000342c:	e99c                	sd	a5,16(a1)
}
    8000342e:	6422                	ld	s0,8(sp)
    80003430:	0141                	addi	sp,sp,16
    80003432:	8082                	ret

0000000080003434 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003434:	457c                	lw	a5,76(a0)
    80003436:	0ed7eb63          	bltu	a5,a3,8000352c <readi+0xf8>
{
    8000343a:	7159                	addi	sp,sp,-112
    8000343c:	f486                	sd	ra,104(sp)
    8000343e:	f0a2                	sd	s0,96(sp)
    80003440:	eca6                	sd	s1,88(sp)
    80003442:	e0d2                	sd	s4,64(sp)
    80003444:	fc56                	sd	s5,56(sp)
    80003446:	f85a                	sd	s6,48(sp)
    80003448:	f45e                	sd	s7,40(sp)
    8000344a:	1880                	addi	s0,sp,112
    8000344c:	8b2a                	mv	s6,a0
    8000344e:	8bae                	mv	s7,a1
    80003450:	8a32                	mv	s4,a2
    80003452:	84b6                	mv	s1,a3
    80003454:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003456:	9f35                	addw	a4,a4,a3
    return 0;
    80003458:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000345a:	0cd76063          	bltu	a4,a3,8000351a <readi+0xe6>
    8000345e:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003460:	00e7f463          	bgeu	a5,a4,80003468 <readi+0x34>
    n = ip->size - off;
    80003464:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003468:	080a8f63          	beqz	s5,80003506 <readi+0xd2>
    8000346c:	e8ca                	sd	s2,80(sp)
    8000346e:	f062                	sd	s8,32(sp)
    80003470:	ec66                	sd	s9,24(sp)
    80003472:	e86a                	sd	s10,16(sp)
    80003474:	e46e                	sd	s11,8(sp)
    80003476:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003478:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000347c:	5c7d                	li	s8,-1
    8000347e:	a80d                	j	800034b0 <readi+0x7c>
    80003480:	020d1d93          	slli	s11,s10,0x20
    80003484:	020ddd93          	srli	s11,s11,0x20
    80003488:	05890613          	addi	a2,s2,88
    8000348c:	86ee                	mv	a3,s11
    8000348e:	963a                	add	a2,a2,a4
    80003490:	85d2                	mv	a1,s4
    80003492:	855e                	mv	a0,s7
    80003494:	d77fe0ef          	jal	8000220a <either_copyout>
    80003498:	05850763          	beq	a0,s8,800034e6 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000349c:	854a                	mv	a0,s2
    8000349e:	f12ff0ef          	jal	80002bb0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800034a2:	013d09bb          	addw	s3,s10,s3
    800034a6:	009d04bb          	addw	s1,s10,s1
    800034aa:	9a6e                	add	s4,s4,s11
    800034ac:	0559f763          	bgeu	s3,s5,800034fa <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800034b0:	00a4d59b          	srliw	a1,s1,0xa
    800034b4:	855a                	mv	a0,s6
    800034b6:	977ff0ef          	jal	80002e2c <bmap>
    800034ba:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800034be:	c5b1                	beqz	a1,8000350a <readi+0xd6>
    bp = bread(ip->dev, addr);
    800034c0:	000b2503          	lw	a0,0(s6)
    800034c4:	de4ff0ef          	jal	80002aa8 <bread>
    800034c8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800034ca:	3ff4f713          	andi	a4,s1,1023
    800034ce:	40ec87bb          	subw	a5,s9,a4
    800034d2:	413a86bb          	subw	a3,s5,s3
    800034d6:	8d3e                	mv	s10,a5
    800034d8:	2781                	sext.w	a5,a5
    800034da:	0006861b          	sext.w	a2,a3
    800034de:	faf671e3          	bgeu	a2,a5,80003480 <readi+0x4c>
    800034e2:	8d36                	mv	s10,a3
    800034e4:	bf71                	j	80003480 <readi+0x4c>
      brelse(bp);
    800034e6:	854a                	mv	a0,s2
    800034e8:	ec8ff0ef          	jal	80002bb0 <brelse>
      tot = -1;
    800034ec:	59fd                	li	s3,-1
      break;
    800034ee:	6946                	ld	s2,80(sp)
    800034f0:	7c02                	ld	s8,32(sp)
    800034f2:	6ce2                	ld	s9,24(sp)
    800034f4:	6d42                	ld	s10,16(sp)
    800034f6:	6da2                	ld	s11,8(sp)
    800034f8:	a831                	j	80003514 <readi+0xe0>
    800034fa:	6946                	ld	s2,80(sp)
    800034fc:	7c02                	ld	s8,32(sp)
    800034fe:	6ce2                	ld	s9,24(sp)
    80003500:	6d42                	ld	s10,16(sp)
    80003502:	6da2                	ld	s11,8(sp)
    80003504:	a801                	j	80003514 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003506:	89d6                	mv	s3,s5
    80003508:	a031                	j	80003514 <readi+0xe0>
    8000350a:	6946                	ld	s2,80(sp)
    8000350c:	7c02                	ld	s8,32(sp)
    8000350e:	6ce2                	ld	s9,24(sp)
    80003510:	6d42                	ld	s10,16(sp)
    80003512:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003514:	0009851b          	sext.w	a0,s3
    80003518:	69a6                	ld	s3,72(sp)
}
    8000351a:	70a6                	ld	ra,104(sp)
    8000351c:	7406                	ld	s0,96(sp)
    8000351e:	64e6                	ld	s1,88(sp)
    80003520:	6a06                	ld	s4,64(sp)
    80003522:	7ae2                	ld	s5,56(sp)
    80003524:	7b42                	ld	s6,48(sp)
    80003526:	7ba2                	ld	s7,40(sp)
    80003528:	6165                	addi	sp,sp,112
    8000352a:	8082                	ret
    return 0;
    8000352c:	4501                	li	a0,0
}
    8000352e:	8082                	ret

0000000080003530 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003530:	457c                	lw	a5,76(a0)
    80003532:	10d7e063          	bltu	a5,a3,80003632 <writei+0x102>
{
    80003536:	7159                	addi	sp,sp,-112
    80003538:	f486                	sd	ra,104(sp)
    8000353a:	f0a2                	sd	s0,96(sp)
    8000353c:	e8ca                	sd	s2,80(sp)
    8000353e:	e0d2                	sd	s4,64(sp)
    80003540:	fc56                	sd	s5,56(sp)
    80003542:	f85a                	sd	s6,48(sp)
    80003544:	f45e                	sd	s7,40(sp)
    80003546:	1880                	addi	s0,sp,112
    80003548:	8aaa                	mv	s5,a0
    8000354a:	8bae                	mv	s7,a1
    8000354c:	8a32                	mv	s4,a2
    8000354e:	8936                	mv	s2,a3
    80003550:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003552:	00e687bb          	addw	a5,a3,a4
    80003556:	0ed7e063          	bltu	a5,a3,80003636 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000355a:	00043737          	lui	a4,0x43
    8000355e:	0cf76e63          	bltu	a4,a5,8000363a <writei+0x10a>
    80003562:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003564:	0a0b0f63          	beqz	s6,80003622 <writei+0xf2>
    80003568:	eca6                	sd	s1,88(sp)
    8000356a:	f062                	sd	s8,32(sp)
    8000356c:	ec66                	sd	s9,24(sp)
    8000356e:	e86a                	sd	s10,16(sp)
    80003570:	e46e                	sd	s11,8(sp)
    80003572:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003574:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003578:	5c7d                	li	s8,-1
    8000357a:	a825                	j	800035b2 <writei+0x82>
    8000357c:	020d1d93          	slli	s11,s10,0x20
    80003580:	020ddd93          	srli	s11,s11,0x20
    80003584:	05848513          	addi	a0,s1,88
    80003588:	86ee                	mv	a3,s11
    8000358a:	8652                	mv	a2,s4
    8000358c:	85de                	mv	a1,s7
    8000358e:	953a                	add	a0,a0,a4
    80003590:	cc5fe0ef          	jal	80002254 <either_copyin>
    80003594:	05850a63          	beq	a0,s8,800035e8 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003598:	8526                	mv	a0,s1
    8000359a:	660000ef          	jal	80003bfa <log_write>
    brelse(bp);
    8000359e:	8526                	mv	a0,s1
    800035a0:	e10ff0ef          	jal	80002bb0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800035a4:	013d09bb          	addw	s3,s10,s3
    800035a8:	012d093b          	addw	s2,s10,s2
    800035ac:	9a6e                	add	s4,s4,s11
    800035ae:	0569f063          	bgeu	s3,s6,800035ee <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800035b2:	00a9559b          	srliw	a1,s2,0xa
    800035b6:	8556                	mv	a0,s5
    800035b8:	875ff0ef          	jal	80002e2c <bmap>
    800035bc:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800035c0:	c59d                	beqz	a1,800035ee <writei+0xbe>
    bp = bread(ip->dev, addr);
    800035c2:	000aa503          	lw	a0,0(s5)
    800035c6:	ce2ff0ef          	jal	80002aa8 <bread>
    800035ca:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800035cc:	3ff97713          	andi	a4,s2,1023
    800035d0:	40ec87bb          	subw	a5,s9,a4
    800035d4:	413b06bb          	subw	a3,s6,s3
    800035d8:	8d3e                	mv	s10,a5
    800035da:	2781                	sext.w	a5,a5
    800035dc:	0006861b          	sext.w	a2,a3
    800035e0:	f8f67ee3          	bgeu	a2,a5,8000357c <writei+0x4c>
    800035e4:	8d36                	mv	s10,a3
    800035e6:	bf59                	j	8000357c <writei+0x4c>
      brelse(bp);
    800035e8:	8526                	mv	a0,s1
    800035ea:	dc6ff0ef          	jal	80002bb0 <brelse>
  }

  if(off > ip->size)
    800035ee:	04caa783          	lw	a5,76(s5)
    800035f2:	0327fa63          	bgeu	a5,s2,80003626 <writei+0xf6>
    ip->size = off;
    800035f6:	052aa623          	sw	s2,76(s5)
    800035fa:	64e6                	ld	s1,88(sp)
    800035fc:	7c02                	ld	s8,32(sp)
    800035fe:	6ce2                	ld	s9,24(sp)
    80003600:	6d42                	ld	s10,16(sp)
    80003602:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003604:	8556                	mv	a0,s5
    80003606:	b27ff0ef          	jal	8000312c <iupdate>

  return tot;
    8000360a:	0009851b          	sext.w	a0,s3
    8000360e:	69a6                	ld	s3,72(sp)
}
    80003610:	70a6                	ld	ra,104(sp)
    80003612:	7406                	ld	s0,96(sp)
    80003614:	6946                	ld	s2,80(sp)
    80003616:	6a06                	ld	s4,64(sp)
    80003618:	7ae2                	ld	s5,56(sp)
    8000361a:	7b42                	ld	s6,48(sp)
    8000361c:	7ba2                	ld	s7,40(sp)
    8000361e:	6165                	addi	sp,sp,112
    80003620:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003622:	89da                	mv	s3,s6
    80003624:	b7c5                	j	80003604 <writei+0xd4>
    80003626:	64e6                	ld	s1,88(sp)
    80003628:	7c02                	ld	s8,32(sp)
    8000362a:	6ce2                	ld	s9,24(sp)
    8000362c:	6d42                	ld	s10,16(sp)
    8000362e:	6da2                	ld	s11,8(sp)
    80003630:	bfd1                	j	80003604 <writei+0xd4>
    return -1;
    80003632:	557d                	li	a0,-1
}
    80003634:	8082                	ret
    return -1;
    80003636:	557d                	li	a0,-1
    80003638:	bfe1                	j	80003610 <writei+0xe0>
    return -1;
    8000363a:	557d                	li	a0,-1
    8000363c:	bfd1                	j	80003610 <writei+0xe0>

000000008000363e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000363e:	1141                	addi	sp,sp,-16
    80003640:	e406                	sd	ra,8(sp)
    80003642:	e022                	sd	s0,0(sp)
    80003644:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003646:	4639                	li	a2,14
    80003648:	f4cfd0ef          	jal	80000d94 <strncmp>
}
    8000364c:	60a2                	ld	ra,8(sp)
    8000364e:	6402                	ld	s0,0(sp)
    80003650:	0141                	addi	sp,sp,16
    80003652:	8082                	ret

0000000080003654 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003654:	7139                	addi	sp,sp,-64
    80003656:	fc06                	sd	ra,56(sp)
    80003658:	f822                	sd	s0,48(sp)
    8000365a:	f426                	sd	s1,40(sp)
    8000365c:	f04a                	sd	s2,32(sp)
    8000365e:	ec4e                	sd	s3,24(sp)
    80003660:	e852                	sd	s4,16(sp)
    80003662:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003664:	04451703          	lh	a4,68(a0)
    80003668:	4785                	li	a5,1
    8000366a:	00f71a63          	bne	a4,a5,8000367e <dirlookup+0x2a>
    8000366e:	892a                	mv	s2,a0
    80003670:	89ae                	mv	s3,a1
    80003672:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003674:	457c                	lw	a5,76(a0)
    80003676:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003678:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000367a:	e39d                	bnez	a5,800036a0 <dirlookup+0x4c>
    8000367c:	a095                	j	800036e0 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    8000367e:	00004517          	auipc	a0,0x4
    80003682:	ed250513          	addi	a0,a0,-302 # 80007550 <etext+0x550>
    80003686:	90efd0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    8000368a:	00004517          	auipc	a0,0x4
    8000368e:	ede50513          	addi	a0,a0,-290 # 80007568 <etext+0x568>
    80003692:	902fd0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003696:	24c1                	addiw	s1,s1,16
    80003698:	04c92783          	lw	a5,76(s2)
    8000369c:	04f4f163          	bgeu	s1,a5,800036de <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800036a0:	4741                	li	a4,16
    800036a2:	86a6                	mv	a3,s1
    800036a4:	fc040613          	addi	a2,s0,-64
    800036a8:	4581                	li	a1,0
    800036aa:	854a                	mv	a0,s2
    800036ac:	d89ff0ef          	jal	80003434 <readi>
    800036b0:	47c1                	li	a5,16
    800036b2:	fcf51ce3          	bne	a0,a5,8000368a <dirlookup+0x36>
    if(de.inum == 0)
    800036b6:	fc045783          	lhu	a5,-64(s0)
    800036ba:	dff1                	beqz	a5,80003696 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800036bc:	fc240593          	addi	a1,s0,-62
    800036c0:	854e                	mv	a0,s3
    800036c2:	f7dff0ef          	jal	8000363e <namecmp>
    800036c6:	f961                	bnez	a0,80003696 <dirlookup+0x42>
      if(poff)
    800036c8:	000a0463          	beqz	s4,800036d0 <dirlookup+0x7c>
        *poff = off;
    800036cc:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800036d0:	fc045583          	lhu	a1,-64(s0)
    800036d4:	00092503          	lw	a0,0(s2)
    800036d8:	829ff0ef          	jal	80002f00 <iget>
    800036dc:	a011                	j	800036e0 <dirlookup+0x8c>
  return 0;
    800036de:	4501                	li	a0,0
}
    800036e0:	70e2                	ld	ra,56(sp)
    800036e2:	7442                	ld	s0,48(sp)
    800036e4:	74a2                	ld	s1,40(sp)
    800036e6:	7902                	ld	s2,32(sp)
    800036e8:	69e2                	ld	s3,24(sp)
    800036ea:	6a42                	ld	s4,16(sp)
    800036ec:	6121                	addi	sp,sp,64
    800036ee:	8082                	ret

00000000800036f0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800036f0:	711d                	addi	sp,sp,-96
    800036f2:	ec86                	sd	ra,88(sp)
    800036f4:	e8a2                	sd	s0,80(sp)
    800036f6:	e4a6                	sd	s1,72(sp)
    800036f8:	e0ca                	sd	s2,64(sp)
    800036fa:	fc4e                	sd	s3,56(sp)
    800036fc:	f852                	sd	s4,48(sp)
    800036fe:	f456                	sd	s5,40(sp)
    80003700:	f05a                	sd	s6,32(sp)
    80003702:	ec5e                	sd	s7,24(sp)
    80003704:	e862                	sd	s8,16(sp)
    80003706:	e466                	sd	s9,8(sp)
    80003708:	1080                	addi	s0,sp,96
    8000370a:	84aa                	mv	s1,a0
    8000370c:	8b2e                	mv	s6,a1
    8000370e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003710:	00054703          	lbu	a4,0(a0)
    80003714:	02f00793          	li	a5,47
    80003718:	00f70e63          	beq	a4,a5,80003734 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000371c:	9c4fe0ef          	jal	800018e0 <myproc>
    80003720:	15053503          	ld	a0,336(a0)
    80003724:	a87ff0ef          	jal	800031aa <idup>
    80003728:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000372a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000372e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003730:	4b85                	li	s7,1
    80003732:	a871                	j	800037ce <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003734:	4585                	li	a1,1
    80003736:	4505                	li	a0,1
    80003738:	fc8ff0ef          	jal	80002f00 <iget>
    8000373c:	8a2a                	mv	s4,a0
    8000373e:	b7f5                	j	8000372a <namex+0x3a>
      iunlockput(ip);
    80003740:	8552                	mv	a0,s4
    80003742:	ca9ff0ef          	jal	800033ea <iunlockput>
      return 0;
    80003746:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003748:	8552                	mv	a0,s4
    8000374a:	60e6                	ld	ra,88(sp)
    8000374c:	6446                	ld	s0,80(sp)
    8000374e:	64a6                	ld	s1,72(sp)
    80003750:	6906                	ld	s2,64(sp)
    80003752:	79e2                	ld	s3,56(sp)
    80003754:	7a42                	ld	s4,48(sp)
    80003756:	7aa2                	ld	s5,40(sp)
    80003758:	7b02                	ld	s6,32(sp)
    8000375a:	6be2                	ld	s7,24(sp)
    8000375c:	6c42                	ld	s8,16(sp)
    8000375e:	6ca2                	ld	s9,8(sp)
    80003760:	6125                	addi	sp,sp,96
    80003762:	8082                	ret
      iunlock(ip);
    80003764:	8552                	mv	a0,s4
    80003766:	b29ff0ef          	jal	8000328e <iunlock>
      return ip;
    8000376a:	bff9                	j	80003748 <namex+0x58>
      iunlockput(ip);
    8000376c:	8552                	mv	a0,s4
    8000376e:	c7dff0ef          	jal	800033ea <iunlockput>
      return 0;
    80003772:	8a4e                	mv	s4,s3
    80003774:	bfd1                	j	80003748 <namex+0x58>
  len = path - s;
    80003776:	40998633          	sub	a2,s3,s1
    8000377a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000377e:	099c5063          	bge	s8,s9,800037fe <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003782:	4639                	li	a2,14
    80003784:	85a6                	mv	a1,s1
    80003786:	8556                	mv	a0,s5
    80003788:	d9cfd0ef          	jal	80000d24 <memmove>
    8000378c:	84ce                	mv	s1,s3
  while(*path == '/')
    8000378e:	0004c783          	lbu	a5,0(s1)
    80003792:	01279763          	bne	a5,s2,800037a0 <namex+0xb0>
    path++;
    80003796:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003798:	0004c783          	lbu	a5,0(s1)
    8000379c:	ff278de3          	beq	a5,s2,80003796 <namex+0xa6>
    ilock(ip);
    800037a0:	8552                	mv	a0,s4
    800037a2:	a3fff0ef          	jal	800031e0 <ilock>
    if(ip->type != T_DIR){
    800037a6:	044a1783          	lh	a5,68(s4)
    800037aa:	f9779be3          	bne	a5,s7,80003740 <namex+0x50>
    if(nameiparent && *path == '\0'){
    800037ae:	000b0563          	beqz	s6,800037b8 <namex+0xc8>
    800037b2:	0004c783          	lbu	a5,0(s1)
    800037b6:	d7dd                	beqz	a5,80003764 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    800037b8:	4601                	li	a2,0
    800037ba:	85d6                	mv	a1,s5
    800037bc:	8552                	mv	a0,s4
    800037be:	e97ff0ef          	jal	80003654 <dirlookup>
    800037c2:	89aa                	mv	s3,a0
    800037c4:	d545                	beqz	a0,8000376c <namex+0x7c>
    iunlockput(ip);
    800037c6:	8552                	mv	a0,s4
    800037c8:	c23ff0ef          	jal	800033ea <iunlockput>
    ip = next;
    800037cc:	8a4e                	mv	s4,s3
  while(*path == '/')
    800037ce:	0004c783          	lbu	a5,0(s1)
    800037d2:	01279763          	bne	a5,s2,800037e0 <namex+0xf0>
    path++;
    800037d6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800037d8:	0004c783          	lbu	a5,0(s1)
    800037dc:	ff278de3          	beq	a5,s2,800037d6 <namex+0xe6>
  if(*path == 0)
    800037e0:	cb8d                	beqz	a5,80003812 <namex+0x122>
  while(*path != '/' && *path != 0)
    800037e2:	0004c783          	lbu	a5,0(s1)
    800037e6:	89a6                	mv	s3,s1
  len = path - s;
    800037e8:	4c81                	li	s9,0
    800037ea:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800037ec:	01278963          	beq	a5,s2,800037fe <namex+0x10e>
    800037f0:	d3d9                	beqz	a5,80003776 <namex+0x86>
    path++;
    800037f2:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800037f4:	0009c783          	lbu	a5,0(s3)
    800037f8:	ff279ce3          	bne	a5,s2,800037f0 <namex+0x100>
    800037fc:	bfad                	j	80003776 <namex+0x86>
    memmove(name, s, len);
    800037fe:	2601                	sext.w	a2,a2
    80003800:	85a6                	mv	a1,s1
    80003802:	8556                	mv	a0,s5
    80003804:	d20fd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    80003808:	9cd6                	add	s9,s9,s5
    8000380a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000380e:	84ce                	mv	s1,s3
    80003810:	bfbd                	j	8000378e <namex+0x9e>
  if(nameiparent){
    80003812:	f20b0be3          	beqz	s6,80003748 <namex+0x58>
    iput(ip);
    80003816:	8552                	mv	a0,s4
    80003818:	b4bff0ef          	jal	80003362 <iput>
    return 0;
    8000381c:	4a01                	li	s4,0
    8000381e:	b72d                	j	80003748 <namex+0x58>

0000000080003820 <dirlink>:
{
    80003820:	7139                	addi	sp,sp,-64
    80003822:	fc06                	sd	ra,56(sp)
    80003824:	f822                	sd	s0,48(sp)
    80003826:	f04a                	sd	s2,32(sp)
    80003828:	ec4e                	sd	s3,24(sp)
    8000382a:	e852                	sd	s4,16(sp)
    8000382c:	0080                	addi	s0,sp,64
    8000382e:	892a                	mv	s2,a0
    80003830:	8a2e                	mv	s4,a1
    80003832:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003834:	4601                	li	a2,0
    80003836:	e1fff0ef          	jal	80003654 <dirlookup>
    8000383a:	e535                	bnez	a0,800038a6 <dirlink+0x86>
    8000383c:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000383e:	04c92483          	lw	s1,76(s2)
    80003842:	c48d                	beqz	s1,8000386c <dirlink+0x4c>
    80003844:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003846:	4741                	li	a4,16
    80003848:	86a6                	mv	a3,s1
    8000384a:	fc040613          	addi	a2,s0,-64
    8000384e:	4581                	li	a1,0
    80003850:	854a                	mv	a0,s2
    80003852:	be3ff0ef          	jal	80003434 <readi>
    80003856:	47c1                	li	a5,16
    80003858:	04f51b63          	bne	a0,a5,800038ae <dirlink+0x8e>
    if(de.inum == 0)
    8000385c:	fc045783          	lhu	a5,-64(s0)
    80003860:	c791                	beqz	a5,8000386c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003862:	24c1                	addiw	s1,s1,16
    80003864:	04c92783          	lw	a5,76(s2)
    80003868:	fcf4efe3          	bltu	s1,a5,80003846 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    8000386c:	4639                	li	a2,14
    8000386e:	85d2                	mv	a1,s4
    80003870:	fc240513          	addi	a0,s0,-62
    80003874:	d56fd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    80003878:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000387c:	4741                	li	a4,16
    8000387e:	86a6                	mv	a3,s1
    80003880:	fc040613          	addi	a2,s0,-64
    80003884:	4581                	li	a1,0
    80003886:	854a                	mv	a0,s2
    80003888:	ca9ff0ef          	jal	80003530 <writei>
    8000388c:	1541                	addi	a0,a0,-16
    8000388e:	00a03533          	snez	a0,a0
    80003892:	40a00533          	neg	a0,a0
    80003896:	74a2                	ld	s1,40(sp)
}
    80003898:	70e2                	ld	ra,56(sp)
    8000389a:	7442                	ld	s0,48(sp)
    8000389c:	7902                	ld	s2,32(sp)
    8000389e:	69e2                	ld	s3,24(sp)
    800038a0:	6a42                	ld	s4,16(sp)
    800038a2:	6121                	addi	sp,sp,64
    800038a4:	8082                	ret
    iput(ip);
    800038a6:	abdff0ef          	jal	80003362 <iput>
    return -1;
    800038aa:	557d                	li	a0,-1
    800038ac:	b7f5                	j	80003898 <dirlink+0x78>
      panic("dirlink read");
    800038ae:	00004517          	auipc	a0,0x4
    800038b2:	cca50513          	addi	a0,a0,-822 # 80007578 <etext+0x578>
    800038b6:	edffc0ef          	jal	80000794 <panic>

00000000800038ba <namei>:

struct inode*
namei(char *path)
{
    800038ba:	1101                	addi	sp,sp,-32
    800038bc:	ec06                	sd	ra,24(sp)
    800038be:	e822                	sd	s0,16(sp)
    800038c0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800038c2:	fe040613          	addi	a2,s0,-32
    800038c6:	4581                	li	a1,0
    800038c8:	e29ff0ef          	jal	800036f0 <namex>
}
    800038cc:	60e2                	ld	ra,24(sp)
    800038ce:	6442                	ld	s0,16(sp)
    800038d0:	6105                	addi	sp,sp,32
    800038d2:	8082                	ret

00000000800038d4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800038d4:	1141                	addi	sp,sp,-16
    800038d6:	e406                	sd	ra,8(sp)
    800038d8:	e022                	sd	s0,0(sp)
    800038da:	0800                	addi	s0,sp,16
    800038dc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800038de:	4585                	li	a1,1
    800038e0:	e11ff0ef          	jal	800036f0 <namex>
}
    800038e4:	60a2                	ld	ra,8(sp)
    800038e6:	6402                	ld	s0,0(sp)
    800038e8:	0141                	addi	sp,sp,16
    800038ea:	8082                	ret

00000000800038ec <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800038ec:	1101                	addi	sp,sp,-32
    800038ee:	ec06                	sd	ra,24(sp)
    800038f0:	e822                	sd	s0,16(sp)
    800038f2:	e426                	sd	s1,8(sp)
    800038f4:	e04a                	sd	s2,0(sp)
    800038f6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800038f8:	0001c917          	auipc	s2,0x1c
    800038fc:	17890913          	addi	s2,s2,376 # 8001fa70 <log>
    80003900:	01892583          	lw	a1,24(s2)
    80003904:	02892503          	lw	a0,40(s2)
    80003908:	9a0ff0ef          	jal	80002aa8 <bread>
    8000390c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000390e:	02c92603          	lw	a2,44(s2)
    80003912:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003914:	00c05f63          	blez	a2,80003932 <write_head+0x46>
    80003918:	0001c717          	auipc	a4,0x1c
    8000391c:	18870713          	addi	a4,a4,392 # 8001faa0 <log+0x30>
    80003920:	87aa                	mv	a5,a0
    80003922:	060a                	slli	a2,a2,0x2
    80003924:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003926:	4314                	lw	a3,0(a4)
    80003928:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000392a:	0711                	addi	a4,a4,4
    8000392c:	0791                	addi	a5,a5,4
    8000392e:	fec79ce3          	bne	a5,a2,80003926 <write_head+0x3a>
  }
  bwrite(buf);
    80003932:	8526                	mv	a0,s1
    80003934:	a4aff0ef          	jal	80002b7e <bwrite>
  brelse(buf);
    80003938:	8526                	mv	a0,s1
    8000393a:	a76ff0ef          	jal	80002bb0 <brelse>
}
    8000393e:	60e2                	ld	ra,24(sp)
    80003940:	6442                	ld	s0,16(sp)
    80003942:	64a2                	ld	s1,8(sp)
    80003944:	6902                	ld	s2,0(sp)
    80003946:	6105                	addi	sp,sp,32
    80003948:	8082                	ret

000000008000394a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000394a:	0001c797          	auipc	a5,0x1c
    8000394e:	1527a783          	lw	a5,338(a5) # 8001fa9c <log+0x2c>
    80003952:	08f05f63          	blez	a5,800039f0 <install_trans+0xa6>
{
    80003956:	7139                	addi	sp,sp,-64
    80003958:	fc06                	sd	ra,56(sp)
    8000395a:	f822                	sd	s0,48(sp)
    8000395c:	f426                	sd	s1,40(sp)
    8000395e:	f04a                	sd	s2,32(sp)
    80003960:	ec4e                	sd	s3,24(sp)
    80003962:	e852                	sd	s4,16(sp)
    80003964:	e456                	sd	s5,8(sp)
    80003966:	e05a                	sd	s6,0(sp)
    80003968:	0080                	addi	s0,sp,64
    8000396a:	8b2a                	mv	s6,a0
    8000396c:	0001ca97          	auipc	s5,0x1c
    80003970:	134a8a93          	addi	s5,s5,308 # 8001faa0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003974:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003976:	0001c997          	auipc	s3,0x1c
    8000397a:	0fa98993          	addi	s3,s3,250 # 8001fa70 <log>
    8000397e:	a829                	j	80003998 <install_trans+0x4e>
    brelse(lbuf);
    80003980:	854a                	mv	a0,s2
    80003982:	a2eff0ef          	jal	80002bb0 <brelse>
    brelse(dbuf);
    80003986:	8526                	mv	a0,s1
    80003988:	a28ff0ef          	jal	80002bb0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000398c:	2a05                	addiw	s4,s4,1
    8000398e:	0a91                	addi	s5,s5,4
    80003990:	02c9a783          	lw	a5,44(s3)
    80003994:	04fa5463          	bge	s4,a5,800039dc <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003998:	0189a583          	lw	a1,24(s3)
    8000399c:	014585bb          	addw	a1,a1,s4
    800039a0:	2585                	addiw	a1,a1,1
    800039a2:	0289a503          	lw	a0,40(s3)
    800039a6:	902ff0ef          	jal	80002aa8 <bread>
    800039aa:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800039ac:	000aa583          	lw	a1,0(s5)
    800039b0:	0289a503          	lw	a0,40(s3)
    800039b4:	8f4ff0ef          	jal	80002aa8 <bread>
    800039b8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800039ba:	40000613          	li	a2,1024
    800039be:	05890593          	addi	a1,s2,88
    800039c2:	05850513          	addi	a0,a0,88
    800039c6:	b5efd0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    800039ca:	8526                	mv	a0,s1
    800039cc:	9b2ff0ef          	jal	80002b7e <bwrite>
    if(recovering == 0)
    800039d0:	fa0b18e3          	bnez	s6,80003980 <install_trans+0x36>
      bunpin(dbuf);
    800039d4:	8526                	mv	a0,s1
    800039d6:	a96ff0ef          	jal	80002c6c <bunpin>
    800039da:	b75d                	j	80003980 <install_trans+0x36>
}
    800039dc:	70e2                	ld	ra,56(sp)
    800039de:	7442                	ld	s0,48(sp)
    800039e0:	74a2                	ld	s1,40(sp)
    800039e2:	7902                	ld	s2,32(sp)
    800039e4:	69e2                	ld	s3,24(sp)
    800039e6:	6a42                	ld	s4,16(sp)
    800039e8:	6aa2                	ld	s5,8(sp)
    800039ea:	6b02                	ld	s6,0(sp)
    800039ec:	6121                	addi	sp,sp,64
    800039ee:	8082                	ret
    800039f0:	8082                	ret

00000000800039f2 <initlog>:
{
    800039f2:	7179                	addi	sp,sp,-48
    800039f4:	f406                	sd	ra,40(sp)
    800039f6:	f022                	sd	s0,32(sp)
    800039f8:	ec26                	sd	s1,24(sp)
    800039fa:	e84a                	sd	s2,16(sp)
    800039fc:	e44e                	sd	s3,8(sp)
    800039fe:	1800                	addi	s0,sp,48
    80003a00:	892a                	mv	s2,a0
    80003a02:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003a04:	0001c497          	auipc	s1,0x1c
    80003a08:	06c48493          	addi	s1,s1,108 # 8001fa70 <log>
    80003a0c:	00004597          	auipc	a1,0x4
    80003a10:	b7c58593          	addi	a1,a1,-1156 # 80007588 <etext+0x588>
    80003a14:	8526                	mv	a0,s1
    80003a16:	95efd0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003a1a:	0149a583          	lw	a1,20(s3)
    80003a1e:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003a20:	0109a783          	lw	a5,16(s3)
    80003a24:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003a26:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003a2a:	854a                	mv	a0,s2
    80003a2c:	87cff0ef          	jal	80002aa8 <bread>
  log.lh.n = lh->n;
    80003a30:	4d30                	lw	a2,88(a0)
    80003a32:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003a34:	00c05f63          	blez	a2,80003a52 <initlog+0x60>
    80003a38:	87aa                	mv	a5,a0
    80003a3a:	0001c717          	auipc	a4,0x1c
    80003a3e:	06670713          	addi	a4,a4,102 # 8001faa0 <log+0x30>
    80003a42:	060a                	slli	a2,a2,0x2
    80003a44:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003a46:	4ff4                	lw	a3,92(a5)
    80003a48:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003a4a:	0791                	addi	a5,a5,4
    80003a4c:	0711                	addi	a4,a4,4
    80003a4e:	fec79ce3          	bne	a5,a2,80003a46 <initlog+0x54>
  brelse(buf);
    80003a52:	95eff0ef          	jal	80002bb0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003a56:	4505                	li	a0,1
    80003a58:	ef3ff0ef          	jal	8000394a <install_trans>
  log.lh.n = 0;
    80003a5c:	0001c797          	auipc	a5,0x1c
    80003a60:	0407a023          	sw	zero,64(a5) # 8001fa9c <log+0x2c>
  write_head(); // clear the log
    80003a64:	e89ff0ef          	jal	800038ec <write_head>
}
    80003a68:	70a2                	ld	ra,40(sp)
    80003a6a:	7402                	ld	s0,32(sp)
    80003a6c:	64e2                	ld	s1,24(sp)
    80003a6e:	6942                	ld	s2,16(sp)
    80003a70:	69a2                	ld	s3,8(sp)
    80003a72:	6145                	addi	sp,sp,48
    80003a74:	8082                	ret

0000000080003a76 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003a76:	1101                	addi	sp,sp,-32
    80003a78:	ec06                	sd	ra,24(sp)
    80003a7a:	e822                	sd	s0,16(sp)
    80003a7c:	e426                	sd	s1,8(sp)
    80003a7e:	e04a                	sd	s2,0(sp)
    80003a80:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003a82:	0001c517          	auipc	a0,0x1c
    80003a86:	fee50513          	addi	a0,a0,-18 # 8001fa70 <log>
    80003a8a:	96afd0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003a8e:	0001c497          	auipc	s1,0x1c
    80003a92:	fe248493          	addi	s1,s1,-30 # 8001fa70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003a96:	4979                	li	s2,30
    80003a98:	a029                	j	80003aa2 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003a9a:	85a6                	mv	a1,s1
    80003a9c:	8526                	mv	a0,s1
    80003a9e:	c10fe0ef          	jal	80001eae <sleep>
    if(log.committing){
    80003aa2:	50dc                	lw	a5,36(s1)
    80003aa4:	fbfd                	bnez	a5,80003a9a <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003aa6:	5098                	lw	a4,32(s1)
    80003aa8:	2705                	addiw	a4,a4,1
    80003aaa:	0027179b          	slliw	a5,a4,0x2
    80003aae:	9fb9                	addw	a5,a5,a4
    80003ab0:	0017979b          	slliw	a5,a5,0x1
    80003ab4:	54d4                	lw	a3,44(s1)
    80003ab6:	9fb5                	addw	a5,a5,a3
    80003ab8:	00f95763          	bge	s2,a5,80003ac6 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003abc:	85a6                	mv	a1,s1
    80003abe:	8526                	mv	a0,s1
    80003ac0:	beefe0ef          	jal	80001eae <sleep>
    80003ac4:	bff9                	j	80003aa2 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003ac6:	0001c517          	auipc	a0,0x1c
    80003aca:	faa50513          	addi	a0,a0,-86 # 8001fa70 <log>
    80003ace:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003ad0:	9bcfd0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003ad4:	60e2                	ld	ra,24(sp)
    80003ad6:	6442                	ld	s0,16(sp)
    80003ad8:	64a2                	ld	s1,8(sp)
    80003ada:	6902                	ld	s2,0(sp)
    80003adc:	6105                	addi	sp,sp,32
    80003ade:	8082                	ret

0000000080003ae0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003ae0:	7139                	addi	sp,sp,-64
    80003ae2:	fc06                	sd	ra,56(sp)
    80003ae4:	f822                	sd	s0,48(sp)
    80003ae6:	f426                	sd	s1,40(sp)
    80003ae8:	f04a                	sd	s2,32(sp)
    80003aea:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003aec:	0001c497          	auipc	s1,0x1c
    80003af0:	f8448493          	addi	s1,s1,-124 # 8001fa70 <log>
    80003af4:	8526                	mv	a0,s1
    80003af6:	8fefd0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003afa:	509c                	lw	a5,32(s1)
    80003afc:	37fd                	addiw	a5,a5,-1
    80003afe:	0007891b          	sext.w	s2,a5
    80003b02:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003b04:	50dc                	lw	a5,36(s1)
    80003b06:	ef9d                	bnez	a5,80003b44 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003b08:	04091763          	bnez	s2,80003b56 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003b0c:	0001c497          	auipc	s1,0x1c
    80003b10:	f6448493          	addi	s1,s1,-156 # 8001fa70 <log>
    80003b14:	4785                	li	a5,1
    80003b16:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003b18:	8526                	mv	a0,s1
    80003b1a:	972fd0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003b1e:	54dc                	lw	a5,44(s1)
    80003b20:	04f04b63          	bgtz	a5,80003b76 <end_op+0x96>
    acquire(&log.lock);
    80003b24:	0001c497          	auipc	s1,0x1c
    80003b28:	f4c48493          	addi	s1,s1,-180 # 8001fa70 <log>
    80003b2c:	8526                	mv	a0,s1
    80003b2e:	8c6fd0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80003b32:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003b36:	8526                	mv	a0,s1
    80003b38:	bc2fe0ef          	jal	80001efa <wakeup>
    release(&log.lock);
    80003b3c:	8526                	mv	a0,s1
    80003b3e:	94efd0ef          	jal	80000c8c <release>
}
    80003b42:	a025                	j	80003b6a <end_op+0x8a>
    80003b44:	ec4e                	sd	s3,24(sp)
    80003b46:	e852                	sd	s4,16(sp)
    80003b48:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003b4a:	00004517          	auipc	a0,0x4
    80003b4e:	a4650513          	addi	a0,a0,-1466 # 80007590 <etext+0x590>
    80003b52:	c43fc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80003b56:	0001c497          	auipc	s1,0x1c
    80003b5a:	f1a48493          	addi	s1,s1,-230 # 8001fa70 <log>
    80003b5e:	8526                	mv	a0,s1
    80003b60:	b9afe0ef          	jal	80001efa <wakeup>
  release(&log.lock);
    80003b64:	8526                	mv	a0,s1
    80003b66:	926fd0ef          	jal	80000c8c <release>
}
    80003b6a:	70e2                	ld	ra,56(sp)
    80003b6c:	7442                	ld	s0,48(sp)
    80003b6e:	74a2                	ld	s1,40(sp)
    80003b70:	7902                	ld	s2,32(sp)
    80003b72:	6121                	addi	sp,sp,64
    80003b74:	8082                	ret
    80003b76:	ec4e                	sd	s3,24(sp)
    80003b78:	e852                	sd	s4,16(sp)
    80003b7a:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b7c:	0001ca97          	auipc	s5,0x1c
    80003b80:	f24a8a93          	addi	s5,s5,-220 # 8001faa0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003b84:	0001ca17          	auipc	s4,0x1c
    80003b88:	eeca0a13          	addi	s4,s4,-276 # 8001fa70 <log>
    80003b8c:	018a2583          	lw	a1,24(s4)
    80003b90:	012585bb          	addw	a1,a1,s2
    80003b94:	2585                	addiw	a1,a1,1
    80003b96:	028a2503          	lw	a0,40(s4)
    80003b9a:	f0ffe0ef          	jal	80002aa8 <bread>
    80003b9e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003ba0:	000aa583          	lw	a1,0(s5)
    80003ba4:	028a2503          	lw	a0,40(s4)
    80003ba8:	f01fe0ef          	jal	80002aa8 <bread>
    80003bac:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003bae:	40000613          	li	a2,1024
    80003bb2:	05850593          	addi	a1,a0,88
    80003bb6:	05848513          	addi	a0,s1,88
    80003bba:	96afd0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    80003bbe:	8526                	mv	a0,s1
    80003bc0:	fbffe0ef          	jal	80002b7e <bwrite>
    brelse(from);
    80003bc4:	854e                	mv	a0,s3
    80003bc6:	febfe0ef          	jal	80002bb0 <brelse>
    brelse(to);
    80003bca:	8526                	mv	a0,s1
    80003bcc:	fe5fe0ef          	jal	80002bb0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bd0:	2905                	addiw	s2,s2,1
    80003bd2:	0a91                	addi	s5,s5,4
    80003bd4:	02ca2783          	lw	a5,44(s4)
    80003bd8:	faf94ae3          	blt	s2,a5,80003b8c <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003bdc:	d11ff0ef          	jal	800038ec <write_head>
    install_trans(0); // Now install writes to home locations
    80003be0:	4501                	li	a0,0
    80003be2:	d69ff0ef          	jal	8000394a <install_trans>
    log.lh.n = 0;
    80003be6:	0001c797          	auipc	a5,0x1c
    80003bea:	ea07ab23          	sw	zero,-330(a5) # 8001fa9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003bee:	cffff0ef          	jal	800038ec <write_head>
    80003bf2:	69e2                	ld	s3,24(sp)
    80003bf4:	6a42                	ld	s4,16(sp)
    80003bf6:	6aa2                	ld	s5,8(sp)
    80003bf8:	b735                	j	80003b24 <end_op+0x44>

0000000080003bfa <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003bfa:	1101                	addi	sp,sp,-32
    80003bfc:	ec06                	sd	ra,24(sp)
    80003bfe:	e822                	sd	s0,16(sp)
    80003c00:	e426                	sd	s1,8(sp)
    80003c02:	e04a                	sd	s2,0(sp)
    80003c04:	1000                	addi	s0,sp,32
    80003c06:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003c08:	0001c917          	auipc	s2,0x1c
    80003c0c:	e6890913          	addi	s2,s2,-408 # 8001fa70 <log>
    80003c10:	854a                	mv	a0,s2
    80003c12:	fe3fc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003c16:	02c92603          	lw	a2,44(s2)
    80003c1a:	47f5                	li	a5,29
    80003c1c:	06c7c363          	blt	a5,a2,80003c82 <log_write+0x88>
    80003c20:	0001c797          	auipc	a5,0x1c
    80003c24:	e6c7a783          	lw	a5,-404(a5) # 8001fa8c <log+0x1c>
    80003c28:	37fd                	addiw	a5,a5,-1
    80003c2a:	04f65c63          	bge	a2,a5,80003c82 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003c2e:	0001c797          	auipc	a5,0x1c
    80003c32:	e627a783          	lw	a5,-414(a5) # 8001fa90 <log+0x20>
    80003c36:	04f05c63          	blez	a5,80003c8e <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003c3a:	4781                	li	a5,0
    80003c3c:	04c05f63          	blez	a2,80003c9a <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003c40:	44cc                	lw	a1,12(s1)
    80003c42:	0001c717          	auipc	a4,0x1c
    80003c46:	e5e70713          	addi	a4,a4,-418 # 8001faa0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003c4a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003c4c:	4314                	lw	a3,0(a4)
    80003c4e:	04b68663          	beq	a3,a1,80003c9a <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003c52:	2785                	addiw	a5,a5,1
    80003c54:	0711                	addi	a4,a4,4
    80003c56:	fef61be3          	bne	a2,a5,80003c4c <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003c5a:	0621                	addi	a2,a2,8
    80003c5c:	060a                	slli	a2,a2,0x2
    80003c5e:	0001c797          	auipc	a5,0x1c
    80003c62:	e1278793          	addi	a5,a5,-494 # 8001fa70 <log>
    80003c66:	97b2                	add	a5,a5,a2
    80003c68:	44d8                	lw	a4,12(s1)
    80003c6a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003c6c:	8526                	mv	a0,s1
    80003c6e:	fcbfe0ef          	jal	80002c38 <bpin>
    log.lh.n++;
    80003c72:	0001c717          	auipc	a4,0x1c
    80003c76:	dfe70713          	addi	a4,a4,-514 # 8001fa70 <log>
    80003c7a:	575c                	lw	a5,44(a4)
    80003c7c:	2785                	addiw	a5,a5,1
    80003c7e:	d75c                	sw	a5,44(a4)
    80003c80:	a80d                	j	80003cb2 <log_write+0xb8>
    panic("too big a transaction");
    80003c82:	00004517          	auipc	a0,0x4
    80003c86:	91e50513          	addi	a0,a0,-1762 # 800075a0 <etext+0x5a0>
    80003c8a:	b0bfc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80003c8e:	00004517          	auipc	a0,0x4
    80003c92:	92a50513          	addi	a0,a0,-1750 # 800075b8 <etext+0x5b8>
    80003c96:	afffc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    80003c9a:	00878693          	addi	a3,a5,8
    80003c9e:	068a                	slli	a3,a3,0x2
    80003ca0:	0001c717          	auipc	a4,0x1c
    80003ca4:	dd070713          	addi	a4,a4,-560 # 8001fa70 <log>
    80003ca8:	9736                	add	a4,a4,a3
    80003caa:	44d4                	lw	a3,12(s1)
    80003cac:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003cae:	faf60fe3          	beq	a2,a5,80003c6c <log_write+0x72>
  }
  release(&log.lock);
    80003cb2:	0001c517          	auipc	a0,0x1c
    80003cb6:	dbe50513          	addi	a0,a0,-578 # 8001fa70 <log>
    80003cba:	fd3fc0ef          	jal	80000c8c <release>
}
    80003cbe:	60e2                	ld	ra,24(sp)
    80003cc0:	6442                	ld	s0,16(sp)
    80003cc2:	64a2                	ld	s1,8(sp)
    80003cc4:	6902                	ld	s2,0(sp)
    80003cc6:	6105                	addi	sp,sp,32
    80003cc8:	8082                	ret

0000000080003cca <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003cca:	1101                	addi	sp,sp,-32
    80003ccc:	ec06                	sd	ra,24(sp)
    80003cce:	e822                	sd	s0,16(sp)
    80003cd0:	e426                	sd	s1,8(sp)
    80003cd2:	e04a                	sd	s2,0(sp)
    80003cd4:	1000                	addi	s0,sp,32
    80003cd6:	84aa                	mv	s1,a0
    80003cd8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003cda:	00004597          	auipc	a1,0x4
    80003cde:	8fe58593          	addi	a1,a1,-1794 # 800075d8 <etext+0x5d8>
    80003ce2:	0521                	addi	a0,a0,8
    80003ce4:	e91fc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    80003ce8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003cec:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003cf0:	0204a423          	sw	zero,40(s1)
}
    80003cf4:	60e2                	ld	ra,24(sp)
    80003cf6:	6442                	ld	s0,16(sp)
    80003cf8:	64a2                	ld	s1,8(sp)
    80003cfa:	6902                	ld	s2,0(sp)
    80003cfc:	6105                	addi	sp,sp,32
    80003cfe:	8082                	ret

0000000080003d00 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003d00:	1101                	addi	sp,sp,-32
    80003d02:	ec06                	sd	ra,24(sp)
    80003d04:	e822                	sd	s0,16(sp)
    80003d06:	e426                	sd	s1,8(sp)
    80003d08:	e04a                	sd	s2,0(sp)
    80003d0a:	1000                	addi	s0,sp,32
    80003d0c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003d0e:	00850913          	addi	s2,a0,8
    80003d12:	854a                	mv	a0,s2
    80003d14:	ee1fc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    80003d18:	409c                	lw	a5,0(s1)
    80003d1a:	c799                	beqz	a5,80003d28 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003d1c:	85ca                	mv	a1,s2
    80003d1e:	8526                	mv	a0,s1
    80003d20:	98efe0ef          	jal	80001eae <sleep>
  while (lk->locked) {
    80003d24:	409c                	lw	a5,0(s1)
    80003d26:	fbfd                	bnez	a5,80003d1c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003d28:	4785                	li	a5,1
    80003d2a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003d2c:	bb5fd0ef          	jal	800018e0 <myproc>
    80003d30:	591c                	lw	a5,48(a0)
    80003d32:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003d34:	854a                	mv	a0,s2
    80003d36:	f57fc0ef          	jal	80000c8c <release>
}
    80003d3a:	60e2                	ld	ra,24(sp)
    80003d3c:	6442                	ld	s0,16(sp)
    80003d3e:	64a2                	ld	s1,8(sp)
    80003d40:	6902                	ld	s2,0(sp)
    80003d42:	6105                	addi	sp,sp,32
    80003d44:	8082                	ret

0000000080003d46 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003d46:	1101                	addi	sp,sp,-32
    80003d48:	ec06                	sd	ra,24(sp)
    80003d4a:	e822                	sd	s0,16(sp)
    80003d4c:	e426                	sd	s1,8(sp)
    80003d4e:	e04a                	sd	s2,0(sp)
    80003d50:	1000                	addi	s0,sp,32
    80003d52:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003d54:	00850913          	addi	s2,a0,8
    80003d58:	854a                	mv	a0,s2
    80003d5a:	e9bfc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    80003d5e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003d62:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003d66:	8526                	mv	a0,s1
    80003d68:	992fe0ef          	jal	80001efa <wakeup>
  release(&lk->lk);
    80003d6c:	854a                	mv	a0,s2
    80003d6e:	f1ffc0ef          	jal	80000c8c <release>
}
    80003d72:	60e2                	ld	ra,24(sp)
    80003d74:	6442                	ld	s0,16(sp)
    80003d76:	64a2                	ld	s1,8(sp)
    80003d78:	6902                	ld	s2,0(sp)
    80003d7a:	6105                	addi	sp,sp,32
    80003d7c:	8082                	ret

0000000080003d7e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003d7e:	7179                	addi	sp,sp,-48
    80003d80:	f406                	sd	ra,40(sp)
    80003d82:	f022                	sd	s0,32(sp)
    80003d84:	ec26                	sd	s1,24(sp)
    80003d86:	e84a                	sd	s2,16(sp)
    80003d88:	1800                	addi	s0,sp,48
    80003d8a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003d8c:	00850913          	addi	s2,a0,8
    80003d90:	854a                	mv	a0,s2
    80003d92:	e63fc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003d96:	409c                	lw	a5,0(s1)
    80003d98:	ef81                	bnez	a5,80003db0 <holdingsleep+0x32>
    80003d9a:	4481                	li	s1,0
  release(&lk->lk);
    80003d9c:	854a                	mv	a0,s2
    80003d9e:	eeffc0ef          	jal	80000c8c <release>
  return r;
}
    80003da2:	8526                	mv	a0,s1
    80003da4:	70a2                	ld	ra,40(sp)
    80003da6:	7402                	ld	s0,32(sp)
    80003da8:	64e2                	ld	s1,24(sp)
    80003daa:	6942                	ld	s2,16(sp)
    80003dac:	6145                	addi	sp,sp,48
    80003dae:	8082                	ret
    80003db0:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003db2:	0284a983          	lw	s3,40(s1)
    80003db6:	b2bfd0ef          	jal	800018e0 <myproc>
    80003dba:	5904                	lw	s1,48(a0)
    80003dbc:	413484b3          	sub	s1,s1,s3
    80003dc0:	0014b493          	seqz	s1,s1
    80003dc4:	69a2                	ld	s3,8(sp)
    80003dc6:	bfd9                	j	80003d9c <holdingsleep+0x1e>

0000000080003dc8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003dc8:	1141                	addi	sp,sp,-16
    80003dca:	e406                	sd	ra,8(sp)
    80003dcc:	e022                	sd	s0,0(sp)
    80003dce:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003dd0:	00004597          	auipc	a1,0x4
    80003dd4:	81858593          	addi	a1,a1,-2024 # 800075e8 <etext+0x5e8>
    80003dd8:	0001c517          	auipc	a0,0x1c
    80003ddc:	de050513          	addi	a0,a0,-544 # 8001fbb8 <ftable>
    80003de0:	d95fc0ef          	jal	80000b74 <initlock>
}
    80003de4:	60a2                	ld	ra,8(sp)
    80003de6:	6402                	ld	s0,0(sp)
    80003de8:	0141                	addi	sp,sp,16
    80003dea:	8082                	ret

0000000080003dec <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003dec:	1101                	addi	sp,sp,-32
    80003dee:	ec06                	sd	ra,24(sp)
    80003df0:	e822                	sd	s0,16(sp)
    80003df2:	e426                	sd	s1,8(sp)
    80003df4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003df6:	0001c517          	auipc	a0,0x1c
    80003dfa:	dc250513          	addi	a0,a0,-574 # 8001fbb8 <ftable>
    80003dfe:	df7fc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e02:	0001c497          	auipc	s1,0x1c
    80003e06:	dce48493          	addi	s1,s1,-562 # 8001fbd0 <ftable+0x18>
    80003e0a:	0001d717          	auipc	a4,0x1d
    80003e0e:	d6670713          	addi	a4,a4,-666 # 80020b70 <disk>
    if(f->ref == 0){
    80003e12:	40dc                	lw	a5,4(s1)
    80003e14:	cf89                	beqz	a5,80003e2e <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e16:	02848493          	addi	s1,s1,40
    80003e1a:	fee49ce3          	bne	s1,a4,80003e12 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003e1e:	0001c517          	auipc	a0,0x1c
    80003e22:	d9a50513          	addi	a0,a0,-614 # 8001fbb8 <ftable>
    80003e26:	e67fc0ef          	jal	80000c8c <release>
  return 0;
    80003e2a:	4481                	li	s1,0
    80003e2c:	a809                	j	80003e3e <filealloc+0x52>
      f->ref = 1;
    80003e2e:	4785                	li	a5,1
    80003e30:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003e32:	0001c517          	auipc	a0,0x1c
    80003e36:	d8650513          	addi	a0,a0,-634 # 8001fbb8 <ftable>
    80003e3a:	e53fc0ef          	jal	80000c8c <release>
}
    80003e3e:	8526                	mv	a0,s1
    80003e40:	60e2                	ld	ra,24(sp)
    80003e42:	6442                	ld	s0,16(sp)
    80003e44:	64a2                	ld	s1,8(sp)
    80003e46:	6105                	addi	sp,sp,32
    80003e48:	8082                	ret

0000000080003e4a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003e4a:	1101                	addi	sp,sp,-32
    80003e4c:	ec06                	sd	ra,24(sp)
    80003e4e:	e822                	sd	s0,16(sp)
    80003e50:	e426                	sd	s1,8(sp)
    80003e52:	1000                	addi	s0,sp,32
    80003e54:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003e56:	0001c517          	auipc	a0,0x1c
    80003e5a:	d6250513          	addi	a0,a0,-670 # 8001fbb8 <ftable>
    80003e5e:	d97fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003e62:	40dc                	lw	a5,4(s1)
    80003e64:	02f05063          	blez	a5,80003e84 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003e68:	2785                	addiw	a5,a5,1
    80003e6a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003e6c:	0001c517          	auipc	a0,0x1c
    80003e70:	d4c50513          	addi	a0,a0,-692 # 8001fbb8 <ftable>
    80003e74:	e19fc0ef          	jal	80000c8c <release>
  return f;
}
    80003e78:	8526                	mv	a0,s1
    80003e7a:	60e2                	ld	ra,24(sp)
    80003e7c:	6442                	ld	s0,16(sp)
    80003e7e:	64a2                	ld	s1,8(sp)
    80003e80:	6105                	addi	sp,sp,32
    80003e82:	8082                	ret
    panic("filedup");
    80003e84:	00003517          	auipc	a0,0x3
    80003e88:	76c50513          	addi	a0,a0,1900 # 800075f0 <etext+0x5f0>
    80003e8c:	909fc0ef          	jal	80000794 <panic>

0000000080003e90 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003e90:	7139                	addi	sp,sp,-64
    80003e92:	fc06                	sd	ra,56(sp)
    80003e94:	f822                	sd	s0,48(sp)
    80003e96:	f426                	sd	s1,40(sp)
    80003e98:	0080                	addi	s0,sp,64
    80003e9a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003e9c:	0001c517          	auipc	a0,0x1c
    80003ea0:	d1c50513          	addi	a0,a0,-740 # 8001fbb8 <ftable>
    80003ea4:	d51fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003ea8:	40dc                	lw	a5,4(s1)
    80003eaa:	04f05a63          	blez	a5,80003efe <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80003eae:	37fd                	addiw	a5,a5,-1
    80003eb0:	0007871b          	sext.w	a4,a5
    80003eb4:	c0dc                	sw	a5,4(s1)
    80003eb6:	04e04e63          	bgtz	a4,80003f12 <fileclose+0x82>
    80003eba:	f04a                	sd	s2,32(sp)
    80003ebc:	ec4e                	sd	s3,24(sp)
    80003ebe:	e852                	sd	s4,16(sp)
    80003ec0:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003ec2:	0004a903          	lw	s2,0(s1)
    80003ec6:	0094ca83          	lbu	s5,9(s1)
    80003eca:	0104ba03          	ld	s4,16(s1)
    80003ece:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003ed2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003ed6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003eda:	0001c517          	auipc	a0,0x1c
    80003ede:	cde50513          	addi	a0,a0,-802 # 8001fbb8 <ftable>
    80003ee2:	dabfc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    80003ee6:	4785                	li	a5,1
    80003ee8:	04f90063          	beq	s2,a5,80003f28 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003eec:	3979                	addiw	s2,s2,-2
    80003eee:	4785                	li	a5,1
    80003ef0:	0527f563          	bgeu	a5,s2,80003f3a <fileclose+0xaa>
    80003ef4:	7902                	ld	s2,32(sp)
    80003ef6:	69e2                	ld	s3,24(sp)
    80003ef8:	6a42                	ld	s4,16(sp)
    80003efa:	6aa2                	ld	s5,8(sp)
    80003efc:	a00d                	j	80003f1e <fileclose+0x8e>
    80003efe:	f04a                	sd	s2,32(sp)
    80003f00:	ec4e                	sd	s3,24(sp)
    80003f02:	e852                	sd	s4,16(sp)
    80003f04:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80003f06:	00003517          	auipc	a0,0x3
    80003f0a:	6f250513          	addi	a0,a0,1778 # 800075f8 <etext+0x5f8>
    80003f0e:	887fc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    80003f12:	0001c517          	auipc	a0,0x1c
    80003f16:	ca650513          	addi	a0,a0,-858 # 8001fbb8 <ftable>
    80003f1a:	d73fc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80003f1e:	70e2                	ld	ra,56(sp)
    80003f20:	7442                	ld	s0,48(sp)
    80003f22:	74a2                	ld	s1,40(sp)
    80003f24:	6121                	addi	sp,sp,64
    80003f26:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003f28:	85d6                	mv	a1,s5
    80003f2a:	8552                	mv	a0,s4
    80003f2c:	336000ef          	jal	80004262 <pipeclose>
    80003f30:	7902                	ld	s2,32(sp)
    80003f32:	69e2                	ld	s3,24(sp)
    80003f34:	6a42                	ld	s4,16(sp)
    80003f36:	6aa2                	ld	s5,8(sp)
    80003f38:	b7dd                	j	80003f1e <fileclose+0x8e>
    begin_op();
    80003f3a:	b3dff0ef          	jal	80003a76 <begin_op>
    iput(ff.ip);
    80003f3e:	854e                	mv	a0,s3
    80003f40:	c22ff0ef          	jal	80003362 <iput>
    end_op();
    80003f44:	b9dff0ef          	jal	80003ae0 <end_op>
    80003f48:	7902                	ld	s2,32(sp)
    80003f4a:	69e2                	ld	s3,24(sp)
    80003f4c:	6a42                	ld	s4,16(sp)
    80003f4e:	6aa2                	ld	s5,8(sp)
    80003f50:	b7f9                	j	80003f1e <fileclose+0x8e>

0000000080003f52 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003f52:	715d                	addi	sp,sp,-80
    80003f54:	e486                	sd	ra,72(sp)
    80003f56:	e0a2                	sd	s0,64(sp)
    80003f58:	fc26                	sd	s1,56(sp)
    80003f5a:	f44e                	sd	s3,40(sp)
    80003f5c:	0880                	addi	s0,sp,80
    80003f5e:	84aa                	mv	s1,a0
    80003f60:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003f62:	97ffd0ef          	jal	800018e0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003f66:	409c                	lw	a5,0(s1)
    80003f68:	37f9                	addiw	a5,a5,-2
    80003f6a:	4705                	li	a4,1
    80003f6c:	04f76063          	bltu	a4,a5,80003fac <filestat+0x5a>
    80003f70:	f84a                	sd	s2,48(sp)
    80003f72:	892a                	mv	s2,a0
    ilock(f->ip);
    80003f74:	6c88                	ld	a0,24(s1)
    80003f76:	a6aff0ef          	jal	800031e0 <ilock>
    stati(f->ip, &st);
    80003f7a:	fb840593          	addi	a1,s0,-72
    80003f7e:	6c88                	ld	a0,24(s1)
    80003f80:	c8aff0ef          	jal	8000340a <stati>
    iunlock(f->ip);
    80003f84:	6c88                	ld	a0,24(s1)
    80003f86:	b08ff0ef          	jal	8000328e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003f8a:	46e1                	li	a3,24
    80003f8c:	fb840613          	addi	a2,s0,-72
    80003f90:	85ce                	mv	a1,s3
    80003f92:	05093503          	ld	a0,80(s2)
    80003f96:	dbcfd0ef          	jal	80001552 <copyout>
    80003f9a:	41f5551b          	sraiw	a0,a0,0x1f
    80003f9e:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80003fa0:	60a6                	ld	ra,72(sp)
    80003fa2:	6406                	ld	s0,64(sp)
    80003fa4:	74e2                	ld	s1,56(sp)
    80003fa6:	79a2                	ld	s3,40(sp)
    80003fa8:	6161                	addi	sp,sp,80
    80003faa:	8082                	ret
  return -1;
    80003fac:	557d                	li	a0,-1
    80003fae:	bfcd                	j	80003fa0 <filestat+0x4e>

0000000080003fb0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003fb0:	7179                	addi	sp,sp,-48
    80003fb2:	f406                	sd	ra,40(sp)
    80003fb4:	f022                	sd	s0,32(sp)
    80003fb6:	e84a                	sd	s2,16(sp)
    80003fb8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003fba:	00854783          	lbu	a5,8(a0)
    80003fbe:	cfd1                	beqz	a5,8000405a <fileread+0xaa>
    80003fc0:	ec26                	sd	s1,24(sp)
    80003fc2:	e44e                	sd	s3,8(sp)
    80003fc4:	84aa                	mv	s1,a0
    80003fc6:	89ae                	mv	s3,a1
    80003fc8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003fca:	411c                	lw	a5,0(a0)
    80003fcc:	4705                	li	a4,1
    80003fce:	04e78363          	beq	a5,a4,80004014 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003fd2:	470d                	li	a4,3
    80003fd4:	04e78763          	beq	a5,a4,80004022 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003fd8:	4709                	li	a4,2
    80003fda:	06e79a63          	bne	a5,a4,8000404e <fileread+0x9e>
    ilock(f->ip);
    80003fde:	6d08                	ld	a0,24(a0)
    80003fe0:	a00ff0ef          	jal	800031e0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003fe4:	874a                	mv	a4,s2
    80003fe6:	5094                	lw	a3,32(s1)
    80003fe8:	864e                	mv	a2,s3
    80003fea:	4585                	li	a1,1
    80003fec:	6c88                	ld	a0,24(s1)
    80003fee:	c46ff0ef          	jal	80003434 <readi>
    80003ff2:	892a                	mv	s2,a0
    80003ff4:	00a05563          	blez	a0,80003ffe <fileread+0x4e>
      f->off += r;
    80003ff8:	509c                	lw	a5,32(s1)
    80003ffa:	9fa9                	addw	a5,a5,a0
    80003ffc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003ffe:	6c88                	ld	a0,24(s1)
    80004000:	a8eff0ef          	jal	8000328e <iunlock>
    80004004:	64e2                	ld	s1,24(sp)
    80004006:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004008:	854a                	mv	a0,s2
    8000400a:	70a2                	ld	ra,40(sp)
    8000400c:	7402                	ld	s0,32(sp)
    8000400e:	6942                	ld	s2,16(sp)
    80004010:	6145                	addi	sp,sp,48
    80004012:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004014:	6908                	ld	a0,16(a0)
    80004016:	388000ef          	jal	8000439e <piperead>
    8000401a:	892a                	mv	s2,a0
    8000401c:	64e2                	ld	s1,24(sp)
    8000401e:	69a2                	ld	s3,8(sp)
    80004020:	b7e5                	j	80004008 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004022:	02451783          	lh	a5,36(a0)
    80004026:	03079693          	slli	a3,a5,0x30
    8000402a:	92c1                	srli	a3,a3,0x30
    8000402c:	4725                	li	a4,9
    8000402e:	02d76863          	bltu	a4,a3,8000405e <fileread+0xae>
    80004032:	0792                	slli	a5,a5,0x4
    80004034:	0001c717          	auipc	a4,0x1c
    80004038:	ae470713          	addi	a4,a4,-1308 # 8001fb18 <devsw>
    8000403c:	97ba                	add	a5,a5,a4
    8000403e:	639c                	ld	a5,0(a5)
    80004040:	c39d                	beqz	a5,80004066 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004042:	4505                	li	a0,1
    80004044:	9782                	jalr	a5
    80004046:	892a                	mv	s2,a0
    80004048:	64e2                	ld	s1,24(sp)
    8000404a:	69a2                	ld	s3,8(sp)
    8000404c:	bf75                	j	80004008 <fileread+0x58>
    panic("fileread");
    8000404e:	00003517          	auipc	a0,0x3
    80004052:	5ba50513          	addi	a0,a0,1466 # 80007608 <etext+0x608>
    80004056:	f3efc0ef          	jal	80000794 <panic>
    return -1;
    8000405a:	597d                	li	s2,-1
    8000405c:	b775                	j	80004008 <fileread+0x58>
      return -1;
    8000405e:	597d                	li	s2,-1
    80004060:	64e2                	ld	s1,24(sp)
    80004062:	69a2                	ld	s3,8(sp)
    80004064:	b755                	j	80004008 <fileread+0x58>
    80004066:	597d                	li	s2,-1
    80004068:	64e2                	ld	s1,24(sp)
    8000406a:	69a2                	ld	s3,8(sp)
    8000406c:	bf71                	j	80004008 <fileread+0x58>

000000008000406e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000406e:	00954783          	lbu	a5,9(a0)
    80004072:	10078b63          	beqz	a5,80004188 <filewrite+0x11a>
{
    80004076:	715d                	addi	sp,sp,-80
    80004078:	e486                	sd	ra,72(sp)
    8000407a:	e0a2                	sd	s0,64(sp)
    8000407c:	f84a                	sd	s2,48(sp)
    8000407e:	f052                	sd	s4,32(sp)
    80004080:	e85a                	sd	s6,16(sp)
    80004082:	0880                	addi	s0,sp,80
    80004084:	892a                	mv	s2,a0
    80004086:	8b2e                	mv	s6,a1
    80004088:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000408a:	411c                	lw	a5,0(a0)
    8000408c:	4705                	li	a4,1
    8000408e:	02e78763          	beq	a5,a4,800040bc <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004092:	470d                	li	a4,3
    80004094:	02e78863          	beq	a5,a4,800040c4 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004098:	4709                	li	a4,2
    8000409a:	0ce79c63          	bne	a5,a4,80004172 <filewrite+0x104>
    8000409e:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800040a0:	0ac05863          	blez	a2,80004150 <filewrite+0xe2>
    800040a4:	fc26                	sd	s1,56(sp)
    800040a6:	ec56                	sd	s5,24(sp)
    800040a8:	e45e                	sd	s7,8(sp)
    800040aa:	e062                	sd	s8,0(sp)
    int i = 0;
    800040ac:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800040ae:	6b85                	lui	s7,0x1
    800040b0:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800040b4:	6c05                	lui	s8,0x1
    800040b6:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800040ba:	a8b5                	j	80004136 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800040bc:	6908                	ld	a0,16(a0)
    800040be:	1fc000ef          	jal	800042ba <pipewrite>
    800040c2:	a04d                	j	80004164 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800040c4:	02451783          	lh	a5,36(a0)
    800040c8:	03079693          	slli	a3,a5,0x30
    800040cc:	92c1                	srli	a3,a3,0x30
    800040ce:	4725                	li	a4,9
    800040d0:	0ad76e63          	bltu	a4,a3,8000418c <filewrite+0x11e>
    800040d4:	0792                	slli	a5,a5,0x4
    800040d6:	0001c717          	auipc	a4,0x1c
    800040da:	a4270713          	addi	a4,a4,-1470 # 8001fb18 <devsw>
    800040de:	97ba                	add	a5,a5,a4
    800040e0:	679c                	ld	a5,8(a5)
    800040e2:	c7dd                	beqz	a5,80004190 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800040e4:	4505                	li	a0,1
    800040e6:	9782                	jalr	a5
    800040e8:	a8b5                	j	80004164 <filewrite+0xf6>
      if(n1 > max)
    800040ea:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800040ee:	989ff0ef          	jal	80003a76 <begin_op>
      ilock(f->ip);
    800040f2:	01893503          	ld	a0,24(s2)
    800040f6:	8eaff0ef          	jal	800031e0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800040fa:	8756                	mv	a4,s5
    800040fc:	02092683          	lw	a3,32(s2)
    80004100:	01698633          	add	a2,s3,s6
    80004104:	4585                	li	a1,1
    80004106:	01893503          	ld	a0,24(s2)
    8000410a:	c26ff0ef          	jal	80003530 <writei>
    8000410e:	84aa                	mv	s1,a0
    80004110:	00a05763          	blez	a0,8000411e <filewrite+0xb0>
        f->off += r;
    80004114:	02092783          	lw	a5,32(s2)
    80004118:	9fa9                	addw	a5,a5,a0
    8000411a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000411e:	01893503          	ld	a0,24(s2)
    80004122:	96cff0ef          	jal	8000328e <iunlock>
      end_op();
    80004126:	9bbff0ef          	jal	80003ae0 <end_op>

      if(r != n1){
    8000412a:	029a9563          	bne	s5,s1,80004154 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    8000412e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004132:	0149da63          	bge	s3,s4,80004146 <filewrite+0xd8>
      int n1 = n - i;
    80004136:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000413a:	0004879b          	sext.w	a5,s1
    8000413e:	fafbd6e3          	bge	s7,a5,800040ea <filewrite+0x7c>
    80004142:	84e2                	mv	s1,s8
    80004144:	b75d                	j	800040ea <filewrite+0x7c>
    80004146:	74e2                	ld	s1,56(sp)
    80004148:	6ae2                	ld	s5,24(sp)
    8000414a:	6ba2                	ld	s7,8(sp)
    8000414c:	6c02                	ld	s8,0(sp)
    8000414e:	a039                	j	8000415c <filewrite+0xee>
    int i = 0;
    80004150:	4981                	li	s3,0
    80004152:	a029                	j	8000415c <filewrite+0xee>
    80004154:	74e2                	ld	s1,56(sp)
    80004156:	6ae2                	ld	s5,24(sp)
    80004158:	6ba2                	ld	s7,8(sp)
    8000415a:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000415c:	033a1c63          	bne	s4,s3,80004194 <filewrite+0x126>
    80004160:	8552                	mv	a0,s4
    80004162:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004164:	60a6                	ld	ra,72(sp)
    80004166:	6406                	ld	s0,64(sp)
    80004168:	7942                	ld	s2,48(sp)
    8000416a:	7a02                	ld	s4,32(sp)
    8000416c:	6b42                	ld	s6,16(sp)
    8000416e:	6161                	addi	sp,sp,80
    80004170:	8082                	ret
    80004172:	fc26                	sd	s1,56(sp)
    80004174:	f44e                	sd	s3,40(sp)
    80004176:	ec56                	sd	s5,24(sp)
    80004178:	e45e                	sd	s7,8(sp)
    8000417a:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000417c:	00003517          	auipc	a0,0x3
    80004180:	49c50513          	addi	a0,a0,1180 # 80007618 <etext+0x618>
    80004184:	e10fc0ef          	jal	80000794 <panic>
    return -1;
    80004188:	557d                	li	a0,-1
}
    8000418a:	8082                	ret
      return -1;
    8000418c:	557d                	li	a0,-1
    8000418e:	bfd9                	j	80004164 <filewrite+0xf6>
    80004190:	557d                	li	a0,-1
    80004192:	bfc9                	j	80004164 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004194:	557d                	li	a0,-1
    80004196:	79a2                	ld	s3,40(sp)
    80004198:	b7f1                	j	80004164 <filewrite+0xf6>

000000008000419a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000419a:	7179                	addi	sp,sp,-48
    8000419c:	f406                	sd	ra,40(sp)
    8000419e:	f022                	sd	s0,32(sp)
    800041a0:	ec26                	sd	s1,24(sp)
    800041a2:	e052                	sd	s4,0(sp)
    800041a4:	1800                	addi	s0,sp,48
    800041a6:	84aa                	mv	s1,a0
    800041a8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800041aa:	0005b023          	sd	zero,0(a1)
    800041ae:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800041b2:	c3bff0ef          	jal	80003dec <filealloc>
    800041b6:	e088                	sd	a0,0(s1)
    800041b8:	c549                	beqz	a0,80004242 <pipealloc+0xa8>
    800041ba:	c33ff0ef          	jal	80003dec <filealloc>
    800041be:	00aa3023          	sd	a0,0(s4)
    800041c2:	cd25                	beqz	a0,8000423a <pipealloc+0xa0>
    800041c4:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800041c6:	95ffc0ef          	jal	80000b24 <kalloc>
    800041ca:	892a                	mv	s2,a0
    800041cc:	c12d                	beqz	a0,8000422e <pipealloc+0x94>
    800041ce:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800041d0:	4985                	li	s3,1
    800041d2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800041d6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800041da:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800041de:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800041e2:	00003597          	auipc	a1,0x3
    800041e6:	44658593          	addi	a1,a1,1094 # 80007628 <etext+0x628>
    800041ea:	98bfc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    800041ee:	609c                	ld	a5,0(s1)
    800041f0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800041f4:	609c                	ld	a5,0(s1)
    800041f6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800041fa:	609c                	ld	a5,0(s1)
    800041fc:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004200:	609c                	ld	a5,0(s1)
    80004202:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004206:	000a3783          	ld	a5,0(s4)
    8000420a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000420e:	000a3783          	ld	a5,0(s4)
    80004212:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004216:	000a3783          	ld	a5,0(s4)
    8000421a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000421e:	000a3783          	ld	a5,0(s4)
    80004222:	0127b823          	sd	s2,16(a5)
  return 0;
    80004226:	4501                	li	a0,0
    80004228:	6942                	ld	s2,16(sp)
    8000422a:	69a2                	ld	s3,8(sp)
    8000422c:	a01d                	j	80004252 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000422e:	6088                	ld	a0,0(s1)
    80004230:	c119                	beqz	a0,80004236 <pipealloc+0x9c>
    80004232:	6942                	ld	s2,16(sp)
    80004234:	a029                	j	8000423e <pipealloc+0xa4>
    80004236:	6942                	ld	s2,16(sp)
    80004238:	a029                	j	80004242 <pipealloc+0xa8>
    8000423a:	6088                	ld	a0,0(s1)
    8000423c:	c10d                	beqz	a0,8000425e <pipealloc+0xc4>
    fileclose(*f0);
    8000423e:	c53ff0ef          	jal	80003e90 <fileclose>
  if(*f1)
    80004242:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004246:	557d                	li	a0,-1
  if(*f1)
    80004248:	c789                	beqz	a5,80004252 <pipealloc+0xb8>
    fileclose(*f1);
    8000424a:	853e                	mv	a0,a5
    8000424c:	c45ff0ef          	jal	80003e90 <fileclose>
  return -1;
    80004250:	557d                	li	a0,-1
}
    80004252:	70a2                	ld	ra,40(sp)
    80004254:	7402                	ld	s0,32(sp)
    80004256:	64e2                	ld	s1,24(sp)
    80004258:	6a02                	ld	s4,0(sp)
    8000425a:	6145                	addi	sp,sp,48
    8000425c:	8082                	ret
  return -1;
    8000425e:	557d                	li	a0,-1
    80004260:	bfcd                	j	80004252 <pipealloc+0xb8>

0000000080004262 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004262:	1101                	addi	sp,sp,-32
    80004264:	ec06                	sd	ra,24(sp)
    80004266:	e822                	sd	s0,16(sp)
    80004268:	e426                	sd	s1,8(sp)
    8000426a:	e04a                	sd	s2,0(sp)
    8000426c:	1000                	addi	s0,sp,32
    8000426e:	84aa                	mv	s1,a0
    80004270:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004272:	983fc0ef          	jal	80000bf4 <acquire>
  if(writable){
    80004276:	02090763          	beqz	s2,800042a4 <pipeclose+0x42>
    pi->writeopen = 0;
    8000427a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000427e:	21848513          	addi	a0,s1,536
    80004282:	c79fd0ef          	jal	80001efa <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004286:	2204b783          	ld	a5,544(s1)
    8000428a:	e785                	bnez	a5,800042b2 <pipeclose+0x50>
    release(&pi->lock);
    8000428c:	8526                	mv	a0,s1
    8000428e:	9fffc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    80004292:	8526                	mv	a0,s1
    80004294:	faefc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    80004298:	60e2                	ld	ra,24(sp)
    8000429a:	6442                	ld	s0,16(sp)
    8000429c:	64a2                	ld	s1,8(sp)
    8000429e:	6902                	ld	s2,0(sp)
    800042a0:	6105                	addi	sp,sp,32
    800042a2:	8082                	ret
    pi->readopen = 0;
    800042a4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800042a8:	21c48513          	addi	a0,s1,540
    800042ac:	c4ffd0ef          	jal	80001efa <wakeup>
    800042b0:	bfd9                	j	80004286 <pipeclose+0x24>
    release(&pi->lock);
    800042b2:	8526                	mv	a0,s1
    800042b4:	9d9fc0ef          	jal	80000c8c <release>
}
    800042b8:	b7c5                	j	80004298 <pipeclose+0x36>

00000000800042ba <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800042ba:	711d                	addi	sp,sp,-96
    800042bc:	ec86                	sd	ra,88(sp)
    800042be:	e8a2                	sd	s0,80(sp)
    800042c0:	e4a6                	sd	s1,72(sp)
    800042c2:	e0ca                	sd	s2,64(sp)
    800042c4:	fc4e                	sd	s3,56(sp)
    800042c6:	f852                	sd	s4,48(sp)
    800042c8:	f456                	sd	s5,40(sp)
    800042ca:	1080                	addi	s0,sp,96
    800042cc:	84aa                	mv	s1,a0
    800042ce:	8aae                	mv	s5,a1
    800042d0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800042d2:	e0efd0ef          	jal	800018e0 <myproc>
    800042d6:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800042d8:	8526                	mv	a0,s1
    800042da:	91bfc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    800042de:	0b405a63          	blez	s4,80004392 <pipewrite+0xd8>
    800042e2:	f05a                	sd	s6,32(sp)
    800042e4:	ec5e                	sd	s7,24(sp)
    800042e6:	e862                	sd	s8,16(sp)
  int i = 0;
    800042e8:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800042ea:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800042ec:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800042f0:	21c48b93          	addi	s7,s1,540
    800042f4:	a81d                	j	8000432a <pipewrite+0x70>
      release(&pi->lock);
    800042f6:	8526                	mv	a0,s1
    800042f8:	995fc0ef          	jal	80000c8c <release>
      return -1;
    800042fc:	597d                	li	s2,-1
    800042fe:	7b02                	ld	s6,32(sp)
    80004300:	6be2                	ld	s7,24(sp)
    80004302:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004304:	854a                	mv	a0,s2
    80004306:	60e6                	ld	ra,88(sp)
    80004308:	6446                	ld	s0,80(sp)
    8000430a:	64a6                	ld	s1,72(sp)
    8000430c:	6906                	ld	s2,64(sp)
    8000430e:	79e2                	ld	s3,56(sp)
    80004310:	7a42                	ld	s4,48(sp)
    80004312:	7aa2                	ld	s5,40(sp)
    80004314:	6125                	addi	sp,sp,96
    80004316:	8082                	ret
      wakeup(&pi->nread);
    80004318:	8562                	mv	a0,s8
    8000431a:	be1fd0ef          	jal	80001efa <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000431e:	85a6                	mv	a1,s1
    80004320:	855e                	mv	a0,s7
    80004322:	b8dfd0ef          	jal	80001eae <sleep>
  while(i < n){
    80004326:	05495b63          	bge	s2,s4,8000437c <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    8000432a:	2204a783          	lw	a5,544(s1)
    8000432e:	d7e1                	beqz	a5,800042f6 <pipewrite+0x3c>
    80004330:	854e                	mv	a0,s3
    80004332:	db5fd0ef          	jal	800020e6 <killed>
    80004336:	f161                	bnez	a0,800042f6 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004338:	2184a783          	lw	a5,536(s1)
    8000433c:	21c4a703          	lw	a4,540(s1)
    80004340:	2007879b          	addiw	a5,a5,512
    80004344:	fcf70ae3          	beq	a4,a5,80004318 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004348:	4685                	li	a3,1
    8000434a:	01590633          	add	a2,s2,s5
    8000434e:	faf40593          	addi	a1,s0,-81
    80004352:	0509b503          	ld	a0,80(s3)
    80004356:	ad2fd0ef          	jal	80001628 <copyin>
    8000435a:	03650e63          	beq	a0,s6,80004396 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000435e:	21c4a783          	lw	a5,540(s1)
    80004362:	0017871b          	addiw	a4,a5,1
    80004366:	20e4ae23          	sw	a4,540(s1)
    8000436a:	1ff7f793          	andi	a5,a5,511
    8000436e:	97a6                	add	a5,a5,s1
    80004370:	faf44703          	lbu	a4,-81(s0)
    80004374:	00e78c23          	sb	a4,24(a5)
      i++;
    80004378:	2905                	addiw	s2,s2,1
    8000437a:	b775                	j	80004326 <pipewrite+0x6c>
    8000437c:	7b02                	ld	s6,32(sp)
    8000437e:	6be2                	ld	s7,24(sp)
    80004380:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004382:	21848513          	addi	a0,s1,536
    80004386:	b75fd0ef          	jal	80001efa <wakeup>
  release(&pi->lock);
    8000438a:	8526                	mv	a0,s1
    8000438c:	901fc0ef          	jal	80000c8c <release>
  return i;
    80004390:	bf95                	j	80004304 <pipewrite+0x4a>
  int i = 0;
    80004392:	4901                	li	s2,0
    80004394:	b7fd                	j	80004382 <pipewrite+0xc8>
    80004396:	7b02                	ld	s6,32(sp)
    80004398:	6be2                	ld	s7,24(sp)
    8000439a:	6c42                	ld	s8,16(sp)
    8000439c:	b7dd                	j	80004382 <pipewrite+0xc8>

000000008000439e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000439e:	715d                	addi	sp,sp,-80
    800043a0:	e486                	sd	ra,72(sp)
    800043a2:	e0a2                	sd	s0,64(sp)
    800043a4:	fc26                	sd	s1,56(sp)
    800043a6:	f84a                	sd	s2,48(sp)
    800043a8:	f44e                	sd	s3,40(sp)
    800043aa:	f052                	sd	s4,32(sp)
    800043ac:	ec56                	sd	s5,24(sp)
    800043ae:	0880                	addi	s0,sp,80
    800043b0:	84aa                	mv	s1,a0
    800043b2:	892e                	mv	s2,a1
    800043b4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800043b6:	d2afd0ef          	jal	800018e0 <myproc>
    800043ba:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800043bc:	8526                	mv	a0,s1
    800043be:	837fc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800043c2:	2184a703          	lw	a4,536(s1)
    800043c6:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800043ca:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800043ce:	02f71563          	bne	a4,a5,800043f8 <piperead+0x5a>
    800043d2:	2244a783          	lw	a5,548(s1)
    800043d6:	cb85                	beqz	a5,80004406 <piperead+0x68>
    if(killed(pr)){
    800043d8:	8552                	mv	a0,s4
    800043da:	d0dfd0ef          	jal	800020e6 <killed>
    800043de:	ed19                	bnez	a0,800043fc <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800043e0:	85a6                	mv	a1,s1
    800043e2:	854e                	mv	a0,s3
    800043e4:	acbfd0ef          	jal	80001eae <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800043e8:	2184a703          	lw	a4,536(s1)
    800043ec:	21c4a783          	lw	a5,540(s1)
    800043f0:	fef701e3          	beq	a4,a5,800043d2 <piperead+0x34>
    800043f4:	e85a                	sd	s6,16(sp)
    800043f6:	a809                	j	80004408 <piperead+0x6a>
    800043f8:	e85a                	sd	s6,16(sp)
    800043fa:	a039                	j	80004408 <piperead+0x6a>
      release(&pi->lock);
    800043fc:	8526                	mv	a0,s1
    800043fe:	88ffc0ef          	jal	80000c8c <release>
      return -1;
    80004402:	59fd                	li	s3,-1
    80004404:	a8b1                	j	80004460 <piperead+0xc2>
    80004406:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004408:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000440a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000440c:	05505263          	blez	s5,80004450 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004410:	2184a783          	lw	a5,536(s1)
    80004414:	21c4a703          	lw	a4,540(s1)
    80004418:	02f70c63          	beq	a4,a5,80004450 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000441c:	0017871b          	addiw	a4,a5,1
    80004420:	20e4ac23          	sw	a4,536(s1)
    80004424:	1ff7f793          	andi	a5,a5,511
    80004428:	97a6                	add	a5,a5,s1
    8000442a:	0187c783          	lbu	a5,24(a5)
    8000442e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004432:	4685                	li	a3,1
    80004434:	fbf40613          	addi	a2,s0,-65
    80004438:	85ca                	mv	a1,s2
    8000443a:	050a3503          	ld	a0,80(s4)
    8000443e:	914fd0ef          	jal	80001552 <copyout>
    80004442:	01650763          	beq	a0,s6,80004450 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004446:	2985                	addiw	s3,s3,1
    80004448:	0905                	addi	s2,s2,1
    8000444a:	fd3a93e3          	bne	s5,s3,80004410 <piperead+0x72>
    8000444e:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004450:	21c48513          	addi	a0,s1,540
    80004454:	aa7fd0ef          	jal	80001efa <wakeup>
  release(&pi->lock);
    80004458:	8526                	mv	a0,s1
    8000445a:	833fc0ef          	jal	80000c8c <release>
    8000445e:	6b42                	ld	s6,16(sp)
  return i;
}
    80004460:	854e                	mv	a0,s3
    80004462:	60a6                	ld	ra,72(sp)
    80004464:	6406                	ld	s0,64(sp)
    80004466:	74e2                	ld	s1,56(sp)
    80004468:	7942                	ld	s2,48(sp)
    8000446a:	79a2                	ld	s3,40(sp)
    8000446c:	7a02                	ld	s4,32(sp)
    8000446e:	6ae2                	ld	s5,24(sp)
    80004470:	6161                	addi	sp,sp,80
    80004472:	8082                	ret

0000000080004474 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004474:	1141                	addi	sp,sp,-16
    80004476:	e422                	sd	s0,8(sp)
    80004478:	0800                	addi	s0,sp,16
    8000447a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000447c:	8905                	andi	a0,a0,1
    8000447e:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004480:	8b89                	andi	a5,a5,2
    80004482:	c399                	beqz	a5,80004488 <flags2perm+0x14>
      perm |= PTE_W;
    80004484:	00456513          	ori	a0,a0,4
    return perm;
}
    80004488:	6422                	ld	s0,8(sp)
    8000448a:	0141                	addi	sp,sp,16
    8000448c:	8082                	ret

000000008000448e <exec>:

int
exec(char *path, char **argv)
{
    8000448e:	df010113          	addi	sp,sp,-528
    80004492:	20113423          	sd	ra,520(sp)
    80004496:	20813023          	sd	s0,512(sp)
    8000449a:	ffa6                	sd	s1,504(sp)
    8000449c:	fbca                	sd	s2,496(sp)
    8000449e:	0c00                	addi	s0,sp,528
    800044a0:	892a                	mv	s2,a0
    800044a2:	dea43c23          	sd	a0,-520(s0)
    800044a6:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800044aa:	c36fd0ef          	jal	800018e0 <myproc>
    800044ae:	84aa                	mv	s1,a0

  begin_op();
    800044b0:	dc6ff0ef          	jal	80003a76 <begin_op>

  if((ip = namei(path)) == 0){
    800044b4:	854a                	mv	a0,s2
    800044b6:	c04ff0ef          	jal	800038ba <namei>
    800044ba:	c931                	beqz	a0,8000450e <exec+0x80>
    800044bc:	f3d2                	sd	s4,480(sp)
    800044be:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800044c0:	d21fe0ef          	jal	800031e0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800044c4:	04000713          	li	a4,64
    800044c8:	4681                	li	a3,0
    800044ca:	e5040613          	addi	a2,s0,-432
    800044ce:	4581                	li	a1,0
    800044d0:	8552                	mv	a0,s4
    800044d2:	f63fe0ef          	jal	80003434 <readi>
    800044d6:	04000793          	li	a5,64
    800044da:	00f51a63          	bne	a0,a5,800044ee <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800044de:	e5042703          	lw	a4,-432(s0)
    800044e2:	464c47b7          	lui	a5,0x464c4
    800044e6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800044ea:	02f70663          	beq	a4,a5,80004516 <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800044ee:	8552                	mv	a0,s4
    800044f0:	efbfe0ef          	jal	800033ea <iunlockput>
    end_op();
    800044f4:	decff0ef          	jal	80003ae0 <end_op>
  }
  return -1;
    800044f8:	557d                	li	a0,-1
    800044fa:	7a1e                	ld	s4,480(sp)
}
    800044fc:	20813083          	ld	ra,520(sp)
    80004500:	20013403          	ld	s0,512(sp)
    80004504:	74fe                	ld	s1,504(sp)
    80004506:	795e                	ld	s2,496(sp)
    80004508:	21010113          	addi	sp,sp,528
    8000450c:	8082                	ret
    end_op();
    8000450e:	dd2ff0ef          	jal	80003ae0 <end_op>
    return -1;
    80004512:	557d                	li	a0,-1
    80004514:	b7e5                	j	800044fc <exec+0x6e>
    80004516:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004518:	8526                	mv	a0,s1
    8000451a:	c6efd0ef          	jal	80001988 <proc_pagetable>
    8000451e:	8b2a                	mv	s6,a0
    80004520:	2c050b63          	beqz	a0,800047f6 <exec+0x368>
    80004524:	f7ce                	sd	s3,488(sp)
    80004526:	efd6                	sd	s5,472(sp)
    80004528:	e7de                	sd	s7,456(sp)
    8000452a:	e3e2                	sd	s8,448(sp)
    8000452c:	ff66                	sd	s9,440(sp)
    8000452e:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004530:	e7042d03          	lw	s10,-400(s0)
    80004534:	e8845783          	lhu	a5,-376(s0)
    80004538:	12078963          	beqz	a5,8000466a <exec+0x1dc>
    8000453c:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000453e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004540:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004542:	6c85                	lui	s9,0x1
    80004544:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004548:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000454c:	6a85                	lui	s5,0x1
    8000454e:	a085                	j	800045ae <exec+0x120>
      panic("loadseg: address should exist");
    80004550:	00003517          	auipc	a0,0x3
    80004554:	0e050513          	addi	a0,a0,224 # 80007630 <etext+0x630>
    80004558:	a3cfc0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    8000455c:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000455e:	8726                	mv	a4,s1
    80004560:	012c06bb          	addw	a3,s8,s2
    80004564:	4581                	li	a1,0
    80004566:	8552                	mv	a0,s4
    80004568:	ecdfe0ef          	jal	80003434 <readi>
    8000456c:	2501                	sext.w	a0,a0
    8000456e:	24a49a63          	bne	s1,a0,800047c2 <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004572:	012a893b          	addw	s2,s5,s2
    80004576:	03397363          	bgeu	s2,s3,8000459c <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    8000457a:	02091593          	slli	a1,s2,0x20
    8000457e:	9181                	srli	a1,a1,0x20
    80004580:	95de                	add	a1,a1,s7
    80004582:	855a                	mv	a0,s6
    80004584:	a53fc0ef          	jal	80000fd6 <walkaddr>
    80004588:	862a                	mv	a2,a0
    if(pa == 0)
    8000458a:	d179                	beqz	a0,80004550 <exec+0xc2>
    if(sz - i < PGSIZE)
    8000458c:	412984bb          	subw	s1,s3,s2
    80004590:	0004879b          	sext.w	a5,s1
    80004594:	fcfcf4e3          	bgeu	s9,a5,8000455c <exec+0xce>
    80004598:	84d6                	mv	s1,s5
    8000459a:	b7c9                	j	8000455c <exec+0xce>
    sz = sz1;
    8000459c:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045a0:	2d85                	addiw	s11,s11,1
    800045a2:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    800045a6:	e8845783          	lhu	a5,-376(s0)
    800045aa:	08fdd063          	bge	s11,a5,8000462a <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800045ae:	2d01                	sext.w	s10,s10
    800045b0:	03800713          	li	a4,56
    800045b4:	86ea                	mv	a3,s10
    800045b6:	e1840613          	addi	a2,s0,-488
    800045ba:	4581                	li	a1,0
    800045bc:	8552                	mv	a0,s4
    800045be:	e77fe0ef          	jal	80003434 <readi>
    800045c2:	03800793          	li	a5,56
    800045c6:	1cf51663          	bne	a0,a5,80004792 <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800045ca:	e1842783          	lw	a5,-488(s0)
    800045ce:	4705                	li	a4,1
    800045d0:	fce798e3          	bne	a5,a4,800045a0 <exec+0x112>
    if(ph.memsz < ph.filesz)
    800045d4:	e4043483          	ld	s1,-448(s0)
    800045d8:	e3843783          	ld	a5,-456(s0)
    800045dc:	1af4ef63          	bltu	s1,a5,8000479a <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800045e0:	e2843783          	ld	a5,-472(s0)
    800045e4:	94be                	add	s1,s1,a5
    800045e6:	1af4ee63          	bltu	s1,a5,800047a2 <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    800045ea:	df043703          	ld	a4,-528(s0)
    800045ee:	8ff9                	and	a5,a5,a4
    800045f0:	1a079d63          	bnez	a5,800047aa <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800045f4:	e1c42503          	lw	a0,-484(s0)
    800045f8:	e7dff0ef          	jal	80004474 <flags2perm>
    800045fc:	86aa                	mv	a3,a0
    800045fe:	8626                	mv	a2,s1
    80004600:	85ca                	mv	a1,s2
    80004602:	855a                	mv	a0,s6
    80004604:	d3bfc0ef          	jal	8000133e <uvmalloc>
    80004608:	e0a43423          	sd	a0,-504(s0)
    8000460c:	1a050363          	beqz	a0,800047b2 <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004610:	e2843b83          	ld	s7,-472(s0)
    80004614:	e2042c03          	lw	s8,-480(s0)
    80004618:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000461c:	00098463          	beqz	s3,80004624 <exec+0x196>
    80004620:	4901                	li	s2,0
    80004622:	bfa1                	j	8000457a <exec+0xec>
    sz = sz1;
    80004624:	e0843903          	ld	s2,-504(s0)
    80004628:	bfa5                	j	800045a0 <exec+0x112>
    8000462a:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    8000462c:	8552                	mv	a0,s4
    8000462e:	dbdfe0ef          	jal	800033ea <iunlockput>
  end_op();
    80004632:	caeff0ef          	jal	80003ae0 <end_op>
  p = myproc();
    80004636:	aaafd0ef          	jal	800018e0 <myproc>
    8000463a:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000463c:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004640:	6985                	lui	s3,0x1
    80004642:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004644:	99ca                	add	s3,s3,s2
    80004646:	77fd                	lui	a5,0xfffff
    80004648:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000464c:	4691                	li	a3,4
    8000464e:	6609                	lui	a2,0x2
    80004650:	964e                	add	a2,a2,s3
    80004652:	85ce                	mv	a1,s3
    80004654:	855a                	mv	a0,s6
    80004656:	ce9fc0ef          	jal	8000133e <uvmalloc>
    8000465a:	892a                	mv	s2,a0
    8000465c:	e0a43423          	sd	a0,-504(s0)
    80004660:	e519                	bnez	a0,8000466e <exec+0x1e0>
  if(pagetable)
    80004662:	e1343423          	sd	s3,-504(s0)
    80004666:	4a01                	li	s4,0
    80004668:	aab1                	j	800047c4 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000466a:	4901                	li	s2,0
    8000466c:	b7c1                	j	8000462c <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    8000466e:	75f9                	lui	a1,0xffffe
    80004670:	95aa                	add	a1,a1,a0
    80004672:	855a                	mv	a0,s6
    80004674:	eb5fc0ef          	jal	80001528 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004678:	7bfd                	lui	s7,0xfffff
    8000467a:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    8000467c:	e0043783          	ld	a5,-512(s0)
    80004680:	6388                	ld	a0,0(a5)
    80004682:	cd39                	beqz	a0,800046e0 <exec+0x252>
    80004684:	e9040993          	addi	s3,s0,-368
    80004688:	f9040c13          	addi	s8,s0,-112
    8000468c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000468e:	faafc0ef          	jal	80000e38 <strlen>
    80004692:	0015079b          	addiw	a5,a0,1
    80004696:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000469a:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000469e:	11796e63          	bltu	s2,s7,800047ba <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800046a2:	e0043d03          	ld	s10,-512(s0)
    800046a6:	000d3a03          	ld	s4,0(s10)
    800046aa:	8552                	mv	a0,s4
    800046ac:	f8cfc0ef          	jal	80000e38 <strlen>
    800046b0:	0015069b          	addiw	a3,a0,1
    800046b4:	8652                	mv	a2,s4
    800046b6:	85ca                	mv	a1,s2
    800046b8:	855a                	mv	a0,s6
    800046ba:	e99fc0ef          	jal	80001552 <copyout>
    800046be:	10054063          	bltz	a0,800047be <exec+0x330>
    ustack[argc] = sp;
    800046c2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800046c6:	0485                	addi	s1,s1,1
    800046c8:	008d0793          	addi	a5,s10,8
    800046cc:	e0f43023          	sd	a5,-512(s0)
    800046d0:	008d3503          	ld	a0,8(s10)
    800046d4:	c909                	beqz	a0,800046e6 <exec+0x258>
    if(argc >= MAXARG)
    800046d6:	09a1                	addi	s3,s3,8
    800046d8:	fb899be3          	bne	s3,s8,8000468e <exec+0x200>
  ip = 0;
    800046dc:	4a01                	li	s4,0
    800046de:	a0dd                	j	800047c4 <exec+0x336>
  sp = sz;
    800046e0:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800046e4:	4481                	li	s1,0
  ustack[argc] = 0;
    800046e6:	00349793          	slli	a5,s1,0x3
    800046ea:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffde2e0>
    800046ee:	97a2                	add	a5,a5,s0
    800046f0:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800046f4:	00148693          	addi	a3,s1,1
    800046f8:	068e                	slli	a3,a3,0x3
    800046fa:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800046fe:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004702:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004706:	f5796ee3          	bltu	s2,s7,80004662 <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000470a:	e9040613          	addi	a2,s0,-368
    8000470e:	85ca                	mv	a1,s2
    80004710:	855a                	mv	a0,s6
    80004712:	e41fc0ef          	jal	80001552 <copyout>
    80004716:	0e054263          	bltz	a0,800047fa <exec+0x36c>
  p->trapframe->a1 = sp;
    8000471a:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000471e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004722:	df843783          	ld	a5,-520(s0)
    80004726:	0007c703          	lbu	a4,0(a5)
    8000472a:	cf11                	beqz	a4,80004746 <exec+0x2b8>
    8000472c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000472e:	02f00693          	li	a3,47
    80004732:	a039                	j	80004740 <exec+0x2b2>
      last = s+1;
    80004734:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004738:	0785                	addi	a5,a5,1
    8000473a:	fff7c703          	lbu	a4,-1(a5)
    8000473e:	c701                	beqz	a4,80004746 <exec+0x2b8>
    if(*s == '/')
    80004740:	fed71ce3          	bne	a4,a3,80004738 <exec+0x2aa>
    80004744:	bfc5                	j	80004734 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004746:	4641                	li	a2,16
    80004748:	df843583          	ld	a1,-520(s0)
    8000474c:	158a8513          	addi	a0,s5,344
    80004750:	eb6fc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    80004754:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004758:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000475c:	e0843783          	ld	a5,-504(s0)
    80004760:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004764:	058ab783          	ld	a5,88(s5)
    80004768:	e6843703          	ld	a4,-408(s0)
    8000476c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000476e:	058ab783          	ld	a5,88(s5)
    80004772:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004776:	85e6                	mv	a1,s9
    80004778:	a94fd0ef          	jal	80001a0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000477c:	0004851b          	sext.w	a0,s1
    80004780:	79be                	ld	s3,488(sp)
    80004782:	7a1e                	ld	s4,480(sp)
    80004784:	6afe                	ld	s5,472(sp)
    80004786:	6b5e                	ld	s6,464(sp)
    80004788:	6bbe                	ld	s7,456(sp)
    8000478a:	6c1e                	ld	s8,448(sp)
    8000478c:	7cfa                	ld	s9,440(sp)
    8000478e:	7d5a                	ld	s10,432(sp)
    80004790:	b3b5                	j	800044fc <exec+0x6e>
    80004792:	e1243423          	sd	s2,-504(s0)
    80004796:	7dba                	ld	s11,424(sp)
    80004798:	a035                	j	800047c4 <exec+0x336>
    8000479a:	e1243423          	sd	s2,-504(s0)
    8000479e:	7dba                	ld	s11,424(sp)
    800047a0:	a015                	j	800047c4 <exec+0x336>
    800047a2:	e1243423          	sd	s2,-504(s0)
    800047a6:	7dba                	ld	s11,424(sp)
    800047a8:	a831                	j	800047c4 <exec+0x336>
    800047aa:	e1243423          	sd	s2,-504(s0)
    800047ae:	7dba                	ld	s11,424(sp)
    800047b0:	a811                	j	800047c4 <exec+0x336>
    800047b2:	e1243423          	sd	s2,-504(s0)
    800047b6:	7dba                	ld	s11,424(sp)
    800047b8:	a031                	j	800047c4 <exec+0x336>
  ip = 0;
    800047ba:	4a01                	li	s4,0
    800047bc:	a021                	j	800047c4 <exec+0x336>
    800047be:	4a01                	li	s4,0
  if(pagetable)
    800047c0:	a011                	j	800047c4 <exec+0x336>
    800047c2:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800047c4:	e0843583          	ld	a1,-504(s0)
    800047c8:	855a                	mv	a0,s6
    800047ca:	a42fd0ef          	jal	80001a0c <proc_freepagetable>
  return -1;
    800047ce:	557d                	li	a0,-1
  if(ip){
    800047d0:	000a1b63          	bnez	s4,800047e6 <exec+0x358>
    800047d4:	79be                	ld	s3,488(sp)
    800047d6:	7a1e                	ld	s4,480(sp)
    800047d8:	6afe                	ld	s5,472(sp)
    800047da:	6b5e                	ld	s6,464(sp)
    800047dc:	6bbe                	ld	s7,456(sp)
    800047de:	6c1e                	ld	s8,448(sp)
    800047e0:	7cfa                	ld	s9,440(sp)
    800047e2:	7d5a                	ld	s10,432(sp)
    800047e4:	bb21                	j	800044fc <exec+0x6e>
    800047e6:	79be                	ld	s3,488(sp)
    800047e8:	6afe                	ld	s5,472(sp)
    800047ea:	6b5e                	ld	s6,464(sp)
    800047ec:	6bbe                	ld	s7,456(sp)
    800047ee:	6c1e                	ld	s8,448(sp)
    800047f0:	7cfa                	ld	s9,440(sp)
    800047f2:	7d5a                	ld	s10,432(sp)
    800047f4:	b9ed                	j	800044ee <exec+0x60>
    800047f6:	6b5e                	ld	s6,464(sp)
    800047f8:	b9dd                	j	800044ee <exec+0x60>
  sz = sz1;
    800047fa:	e0843983          	ld	s3,-504(s0)
    800047fe:	b595                	j	80004662 <exec+0x1d4>

0000000080004800 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004800:	7179                	addi	sp,sp,-48
    80004802:	f406                	sd	ra,40(sp)
    80004804:	f022                	sd	s0,32(sp)
    80004806:	ec26                	sd	s1,24(sp)
    80004808:	e84a                	sd	s2,16(sp)
    8000480a:	1800                	addi	s0,sp,48
    8000480c:	892e                	mv	s2,a1
    8000480e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004810:	fdc40593          	addi	a1,s0,-36
    80004814:	f81fd0ef          	jal	80002794 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004818:	fdc42703          	lw	a4,-36(s0)
    8000481c:	47bd                	li	a5,15
    8000481e:	02e7e963          	bltu	a5,a4,80004850 <argfd+0x50>
    80004822:	8befd0ef          	jal	800018e0 <myproc>
    80004826:	fdc42703          	lw	a4,-36(s0)
    8000482a:	01a70793          	addi	a5,a4,26
    8000482e:	078e                	slli	a5,a5,0x3
    80004830:	953e                	add	a0,a0,a5
    80004832:	611c                	ld	a5,0(a0)
    80004834:	c385                	beqz	a5,80004854 <argfd+0x54>
    return -1;
  if(pfd)
    80004836:	00090463          	beqz	s2,8000483e <argfd+0x3e>
    *pfd = fd;
    8000483a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000483e:	4501                	li	a0,0
  if(pf)
    80004840:	c091                	beqz	s1,80004844 <argfd+0x44>
    *pf = f;
    80004842:	e09c                	sd	a5,0(s1)
}
    80004844:	70a2                	ld	ra,40(sp)
    80004846:	7402                	ld	s0,32(sp)
    80004848:	64e2                	ld	s1,24(sp)
    8000484a:	6942                	ld	s2,16(sp)
    8000484c:	6145                	addi	sp,sp,48
    8000484e:	8082                	ret
    return -1;
    80004850:	557d                	li	a0,-1
    80004852:	bfcd                	j	80004844 <argfd+0x44>
    80004854:	557d                	li	a0,-1
    80004856:	b7fd                	j	80004844 <argfd+0x44>

0000000080004858 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004858:	1101                	addi	sp,sp,-32
    8000485a:	ec06                	sd	ra,24(sp)
    8000485c:	e822                	sd	s0,16(sp)
    8000485e:	e426                	sd	s1,8(sp)
    80004860:	1000                	addi	s0,sp,32
    80004862:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004864:	87cfd0ef          	jal	800018e0 <myproc>
    80004868:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000486a:	0d050793          	addi	a5,a0,208
    8000486e:	4501                	li	a0,0
    80004870:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004872:	6398                	ld	a4,0(a5)
    80004874:	cb19                	beqz	a4,8000488a <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004876:	2505                	addiw	a0,a0,1
    80004878:	07a1                	addi	a5,a5,8
    8000487a:	fed51ce3          	bne	a0,a3,80004872 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000487e:	557d                	li	a0,-1
}
    80004880:	60e2                	ld	ra,24(sp)
    80004882:	6442                	ld	s0,16(sp)
    80004884:	64a2                	ld	s1,8(sp)
    80004886:	6105                	addi	sp,sp,32
    80004888:	8082                	ret
      p->ofile[fd] = f;
    8000488a:	01a50793          	addi	a5,a0,26
    8000488e:	078e                	slli	a5,a5,0x3
    80004890:	963e                	add	a2,a2,a5
    80004892:	e204                	sd	s1,0(a2)
      return fd;
    80004894:	b7f5                	j	80004880 <fdalloc+0x28>

0000000080004896 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004896:	715d                	addi	sp,sp,-80
    80004898:	e486                	sd	ra,72(sp)
    8000489a:	e0a2                	sd	s0,64(sp)
    8000489c:	fc26                	sd	s1,56(sp)
    8000489e:	f84a                	sd	s2,48(sp)
    800048a0:	f44e                	sd	s3,40(sp)
    800048a2:	ec56                	sd	s5,24(sp)
    800048a4:	e85a                	sd	s6,16(sp)
    800048a6:	0880                	addi	s0,sp,80
    800048a8:	8b2e                	mv	s6,a1
    800048aa:	89b2                	mv	s3,a2
    800048ac:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800048ae:	fb040593          	addi	a1,s0,-80
    800048b2:	822ff0ef          	jal	800038d4 <nameiparent>
    800048b6:	84aa                	mv	s1,a0
    800048b8:	10050a63          	beqz	a0,800049cc <create+0x136>
    return 0;

  ilock(dp);
    800048bc:	925fe0ef          	jal	800031e0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800048c0:	4601                	li	a2,0
    800048c2:	fb040593          	addi	a1,s0,-80
    800048c6:	8526                	mv	a0,s1
    800048c8:	d8dfe0ef          	jal	80003654 <dirlookup>
    800048cc:	8aaa                	mv	s5,a0
    800048ce:	c129                	beqz	a0,80004910 <create+0x7a>
    iunlockput(dp);
    800048d0:	8526                	mv	a0,s1
    800048d2:	b19fe0ef          	jal	800033ea <iunlockput>
    ilock(ip);
    800048d6:	8556                	mv	a0,s5
    800048d8:	909fe0ef          	jal	800031e0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800048dc:	4789                	li	a5,2
    800048de:	02fb1463          	bne	s6,a5,80004906 <create+0x70>
    800048e2:	044ad783          	lhu	a5,68(s5)
    800048e6:	37f9                	addiw	a5,a5,-2
    800048e8:	17c2                	slli	a5,a5,0x30
    800048ea:	93c1                	srli	a5,a5,0x30
    800048ec:	4705                	li	a4,1
    800048ee:	00f76c63          	bltu	a4,a5,80004906 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800048f2:	8556                	mv	a0,s5
    800048f4:	60a6                	ld	ra,72(sp)
    800048f6:	6406                	ld	s0,64(sp)
    800048f8:	74e2                	ld	s1,56(sp)
    800048fa:	7942                	ld	s2,48(sp)
    800048fc:	79a2                	ld	s3,40(sp)
    800048fe:	6ae2                	ld	s5,24(sp)
    80004900:	6b42                	ld	s6,16(sp)
    80004902:	6161                	addi	sp,sp,80
    80004904:	8082                	ret
    iunlockput(ip);
    80004906:	8556                	mv	a0,s5
    80004908:	ae3fe0ef          	jal	800033ea <iunlockput>
    return 0;
    8000490c:	4a81                	li	s5,0
    8000490e:	b7d5                	j	800048f2 <create+0x5c>
    80004910:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004912:	85da                	mv	a1,s6
    80004914:	4088                	lw	a0,0(s1)
    80004916:	f5afe0ef          	jal	80003070 <ialloc>
    8000491a:	8a2a                	mv	s4,a0
    8000491c:	cd15                	beqz	a0,80004958 <create+0xc2>
  ilock(ip);
    8000491e:	8c3fe0ef          	jal	800031e0 <ilock>
  ip->major = major;
    80004922:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004926:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000492a:	4905                	li	s2,1
    8000492c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004930:	8552                	mv	a0,s4
    80004932:	ffafe0ef          	jal	8000312c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004936:	032b0763          	beq	s6,s2,80004964 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    8000493a:	004a2603          	lw	a2,4(s4)
    8000493e:	fb040593          	addi	a1,s0,-80
    80004942:	8526                	mv	a0,s1
    80004944:	eddfe0ef          	jal	80003820 <dirlink>
    80004948:	06054563          	bltz	a0,800049b2 <create+0x11c>
  iunlockput(dp);
    8000494c:	8526                	mv	a0,s1
    8000494e:	a9dfe0ef          	jal	800033ea <iunlockput>
  return ip;
    80004952:	8ad2                	mv	s5,s4
    80004954:	7a02                	ld	s4,32(sp)
    80004956:	bf71                	j	800048f2 <create+0x5c>
    iunlockput(dp);
    80004958:	8526                	mv	a0,s1
    8000495a:	a91fe0ef          	jal	800033ea <iunlockput>
    return 0;
    8000495e:	8ad2                	mv	s5,s4
    80004960:	7a02                	ld	s4,32(sp)
    80004962:	bf41                	j	800048f2 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004964:	004a2603          	lw	a2,4(s4)
    80004968:	00003597          	auipc	a1,0x3
    8000496c:	ce858593          	addi	a1,a1,-792 # 80007650 <etext+0x650>
    80004970:	8552                	mv	a0,s4
    80004972:	eaffe0ef          	jal	80003820 <dirlink>
    80004976:	02054e63          	bltz	a0,800049b2 <create+0x11c>
    8000497a:	40d0                	lw	a2,4(s1)
    8000497c:	00003597          	auipc	a1,0x3
    80004980:	cdc58593          	addi	a1,a1,-804 # 80007658 <etext+0x658>
    80004984:	8552                	mv	a0,s4
    80004986:	e9bfe0ef          	jal	80003820 <dirlink>
    8000498a:	02054463          	bltz	a0,800049b2 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    8000498e:	004a2603          	lw	a2,4(s4)
    80004992:	fb040593          	addi	a1,s0,-80
    80004996:	8526                	mv	a0,s1
    80004998:	e89fe0ef          	jal	80003820 <dirlink>
    8000499c:	00054b63          	bltz	a0,800049b2 <create+0x11c>
    dp->nlink++;  // for ".."
    800049a0:	04a4d783          	lhu	a5,74(s1)
    800049a4:	2785                	addiw	a5,a5,1
    800049a6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800049aa:	8526                	mv	a0,s1
    800049ac:	f80fe0ef          	jal	8000312c <iupdate>
    800049b0:	bf71                	j	8000494c <create+0xb6>
  ip->nlink = 0;
    800049b2:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800049b6:	8552                	mv	a0,s4
    800049b8:	f74fe0ef          	jal	8000312c <iupdate>
  iunlockput(ip);
    800049bc:	8552                	mv	a0,s4
    800049be:	a2dfe0ef          	jal	800033ea <iunlockput>
  iunlockput(dp);
    800049c2:	8526                	mv	a0,s1
    800049c4:	a27fe0ef          	jal	800033ea <iunlockput>
  return 0;
    800049c8:	7a02                	ld	s4,32(sp)
    800049ca:	b725                	j	800048f2 <create+0x5c>
    return 0;
    800049cc:	8aaa                	mv	s5,a0
    800049ce:	b715                	j	800048f2 <create+0x5c>

00000000800049d0 <sys_dup>:
{
    800049d0:	7179                	addi	sp,sp,-48
    800049d2:	f406                	sd	ra,40(sp)
    800049d4:	f022                	sd	s0,32(sp)
    800049d6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800049d8:	fd840613          	addi	a2,s0,-40
    800049dc:	4581                	li	a1,0
    800049de:	4501                	li	a0,0
    800049e0:	e21ff0ef          	jal	80004800 <argfd>
    return -1;
    800049e4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800049e6:	02054363          	bltz	a0,80004a0c <sys_dup+0x3c>
    800049ea:	ec26                	sd	s1,24(sp)
    800049ec:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800049ee:	fd843903          	ld	s2,-40(s0)
    800049f2:	854a                	mv	a0,s2
    800049f4:	e65ff0ef          	jal	80004858 <fdalloc>
    800049f8:	84aa                	mv	s1,a0
    return -1;
    800049fa:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800049fc:	00054d63          	bltz	a0,80004a16 <sys_dup+0x46>
  filedup(f);
    80004a00:	854a                	mv	a0,s2
    80004a02:	c48ff0ef          	jal	80003e4a <filedup>
  return fd;
    80004a06:	87a6                	mv	a5,s1
    80004a08:	64e2                	ld	s1,24(sp)
    80004a0a:	6942                	ld	s2,16(sp)
}
    80004a0c:	853e                	mv	a0,a5
    80004a0e:	70a2                	ld	ra,40(sp)
    80004a10:	7402                	ld	s0,32(sp)
    80004a12:	6145                	addi	sp,sp,48
    80004a14:	8082                	ret
    80004a16:	64e2                	ld	s1,24(sp)
    80004a18:	6942                	ld	s2,16(sp)
    80004a1a:	bfcd                	j	80004a0c <sys_dup+0x3c>

0000000080004a1c <sys_read>:
{
    80004a1c:	7179                	addi	sp,sp,-48
    80004a1e:	f406                	sd	ra,40(sp)
    80004a20:	f022                	sd	s0,32(sp)
    80004a22:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004a24:	fd840593          	addi	a1,s0,-40
    80004a28:	4505                	li	a0,1
    80004a2a:	d87fd0ef          	jal	800027b0 <argaddr>
  argint(2, &n);
    80004a2e:	fe440593          	addi	a1,s0,-28
    80004a32:	4509                	li	a0,2
    80004a34:	d61fd0ef          	jal	80002794 <argint>
  if(argfd(0, 0, &f) < 0)
    80004a38:	fe840613          	addi	a2,s0,-24
    80004a3c:	4581                	li	a1,0
    80004a3e:	4501                	li	a0,0
    80004a40:	dc1ff0ef          	jal	80004800 <argfd>
    80004a44:	87aa                	mv	a5,a0
    return -1;
    80004a46:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004a48:	0007ca63          	bltz	a5,80004a5c <sys_read+0x40>
  return fileread(f, p, n);
    80004a4c:	fe442603          	lw	a2,-28(s0)
    80004a50:	fd843583          	ld	a1,-40(s0)
    80004a54:	fe843503          	ld	a0,-24(s0)
    80004a58:	d58ff0ef          	jal	80003fb0 <fileread>
}
    80004a5c:	70a2                	ld	ra,40(sp)
    80004a5e:	7402                	ld	s0,32(sp)
    80004a60:	6145                	addi	sp,sp,48
    80004a62:	8082                	ret

0000000080004a64 <sys_write>:
{
    80004a64:	7179                	addi	sp,sp,-48
    80004a66:	f406                	sd	ra,40(sp)
    80004a68:	f022                	sd	s0,32(sp)
    80004a6a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004a6c:	fd840593          	addi	a1,s0,-40
    80004a70:	4505                	li	a0,1
    80004a72:	d3ffd0ef          	jal	800027b0 <argaddr>
  argint(2, &n);
    80004a76:	fe440593          	addi	a1,s0,-28
    80004a7a:	4509                	li	a0,2
    80004a7c:	d19fd0ef          	jal	80002794 <argint>
  if(argfd(0, 0, &f) < 0)
    80004a80:	fe840613          	addi	a2,s0,-24
    80004a84:	4581                	li	a1,0
    80004a86:	4501                	li	a0,0
    80004a88:	d79ff0ef          	jal	80004800 <argfd>
    80004a8c:	87aa                	mv	a5,a0
    return -1;
    80004a8e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004a90:	0007ca63          	bltz	a5,80004aa4 <sys_write+0x40>
  return filewrite(f, p, n);
    80004a94:	fe442603          	lw	a2,-28(s0)
    80004a98:	fd843583          	ld	a1,-40(s0)
    80004a9c:	fe843503          	ld	a0,-24(s0)
    80004aa0:	dceff0ef          	jal	8000406e <filewrite>
}
    80004aa4:	70a2                	ld	ra,40(sp)
    80004aa6:	7402                	ld	s0,32(sp)
    80004aa8:	6145                	addi	sp,sp,48
    80004aaa:	8082                	ret

0000000080004aac <sys_close>:
{
    80004aac:	1101                	addi	sp,sp,-32
    80004aae:	ec06                	sd	ra,24(sp)
    80004ab0:	e822                	sd	s0,16(sp)
    80004ab2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004ab4:	fe040613          	addi	a2,s0,-32
    80004ab8:	fec40593          	addi	a1,s0,-20
    80004abc:	4501                	li	a0,0
    80004abe:	d43ff0ef          	jal	80004800 <argfd>
    return -1;
    80004ac2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004ac4:	02054063          	bltz	a0,80004ae4 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004ac8:	e19fc0ef          	jal	800018e0 <myproc>
    80004acc:	fec42783          	lw	a5,-20(s0)
    80004ad0:	07e9                	addi	a5,a5,26
    80004ad2:	078e                	slli	a5,a5,0x3
    80004ad4:	953e                	add	a0,a0,a5
    80004ad6:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004ada:	fe043503          	ld	a0,-32(s0)
    80004ade:	bb2ff0ef          	jal	80003e90 <fileclose>
  return 0;
    80004ae2:	4781                	li	a5,0
}
    80004ae4:	853e                	mv	a0,a5
    80004ae6:	60e2                	ld	ra,24(sp)
    80004ae8:	6442                	ld	s0,16(sp)
    80004aea:	6105                	addi	sp,sp,32
    80004aec:	8082                	ret

0000000080004aee <sys_fstat>:
{
    80004aee:	1101                	addi	sp,sp,-32
    80004af0:	ec06                	sd	ra,24(sp)
    80004af2:	e822                	sd	s0,16(sp)
    80004af4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004af6:	fe040593          	addi	a1,s0,-32
    80004afa:	4505                	li	a0,1
    80004afc:	cb5fd0ef          	jal	800027b0 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004b00:	fe840613          	addi	a2,s0,-24
    80004b04:	4581                	li	a1,0
    80004b06:	4501                	li	a0,0
    80004b08:	cf9ff0ef          	jal	80004800 <argfd>
    80004b0c:	87aa                	mv	a5,a0
    return -1;
    80004b0e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b10:	0007c863          	bltz	a5,80004b20 <sys_fstat+0x32>
  return filestat(f, st);
    80004b14:	fe043583          	ld	a1,-32(s0)
    80004b18:	fe843503          	ld	a0,-24(s0)
    80004b1c:	c36ff0ef          	jal	80003f52 <filestat>
}
    80004b20:	60e2                	ld	ra,24(sp)
    80004b22:	6442                	ld	s0,16(sp)
    80004b24:	6105                	addi	sp,sp,32
    80004b26:	8082                	ret

0000000080004b28 <sys_link>:
{
    80004b28:	7169                	addi	sp,sp,-304
    80004b2a:	f606                	sd	ra,296(sp)
    80004b2c:	f222                	sd	s0,288(sp)
    80004b2e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b30:	08000613          	li	a2,128
    80004b34:	ed040593          	addi	a1,s0,-304
    80004b38:	4501                	li	a0,0
    80004b3a:	c93fd0ef          	jal	800027cc <argstr>
    return -1;
    80004b3e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b40:	0c054e63          	bltz	a0,80004c1c <sys_link+0xf4>
    80004b44:	08000613          	li	a2,128
    80004b48:	f5040593          	addi	a1,s0,-176
    80004b4c:	4505                	li	a0,1
    80004b4e:	c7ffd0ef          	jal	800027cc <argstr>
    return -1;
    80004b52:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b54:	0c054463          	bltz	a0,80004c1c <sys_link+0xf4>
    80004b58:	ee26                	sd	s1,280(sp)
  begin_op();
    80004b5a:	f1dfe0ef          	jal	80003a76 <begin_op>
  if((ip = namei(old)) == 0){
    80004b5e:	ed040513          	addi	a0,s0,-304
    80004b62:	d59fe0ef          	jal	800038ba <namei>
    80004b66:	84aa                	mv	s1,a0
    80004b68:	c53d                	beqz	a0,80004bd6 <sys_link+0xae>
  ilock(ip);
    80004b6a:	e76fe0ef          	jal	800031e0 <ilock>
  if(ip->type == T_DIR){
    80004b6e:	04449703          	lh	a4,68(s1)
    80004b72:	4785                	li	a5,1
    80004b74:	06f70663          	beq	a4,a5,80004be0 <sys_link+0xb8>
    80004b78:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004b7a:	04a4d783          	lhu	a5,74(s1)
    80004b7e:	2785                	addiw	a5,a5,1
    80004b80:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004b84:	8526                	mv	a0,s1
    80004b86:	da6fe0ef          	jal	8000312c <iupdate>
  iunlock(ip);
    80004b8a:	8526                	mv	a0,s1
    80004b8c:	f02fe0ef          	jal	8000328e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004b90:	fd040593          	addi	a1,s0,-48
    80004b94:	f5040513          	addi	a0,s0,-176
    80004b98:	d3dfe0ef          	jal	800038d4 <nameiparent>
    80004b9c:	892a                	mv	s2,a0
    80004b9e:	cd21                	beqz	a0,80004bf6 <sys_link+0xce>
  ilock(dp);
    80004ba0:	e40fe0ef          	jal	800031e0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004ba4:	00092703          	lw	a4,0(s2)
    80004ba8:	409c                	lw	a5,0(s1)
    80004baa:	04f71363          	bne	a4,a5,80004bf0 <sys_link+0xc8>
    80004bae:	40d0                	lw	a2,4(s1)
    80004bb0:	fd040593          	addi	a1,s0,-48
    80004bb4:	854a                	mv	a0,s2
    80004bb6:	c6bfe0ef          	jal	80003820 <dirlink>
    80004bba:	02054b63          	bltz	a0,80004bf0 <sys_link+0xc8>
  iunlockput(dp);
    80004bbe:	854a                	mv	a0,s2
    80004bc0:	82bfe0ef          	jal	800033ea <iunlockput>
  iput(ip);
    80004bc4:	8526                	mv	a0,s1
    80004bc6:	f9cfe0ef          	jal	80003362 <iput>
  end_op();
    80004bca:	f17fe0ef          	jal	80003ae0 <end_op>
  return 0;
    80004bce:	4781                	li	a5,0
    80004bd0:	64f2                	ld	s1,280(sp)
    80004bd2:	6952                	ld	s2,272(sp)
    80004bd4:	a0a1                	j	80004c1c <sys_link+0xf4>
    end_op();
    80004bd6:	f0bfe0ef          	jal	80003ae0 <end_op>
    return -1;
    80004bda:	57fd                	li	a5,-1
    80004bdc:	64f2                	ld	s1,280(sp)
    80004bde:	a83d                	j	80004c1c <sys_link+0xf4>
    iunlockput(ip);
    80004be0:	8526                	mv	a0,s1
    80004be2:	809fe0ef          	jal	800033ea <iunlockput>
    end_op();
    80004be6:	efbfe0ef          	jal	80003ae0 <end_op>
    return -1;
    80004bea:	57fd                	li	a5,-1
    80004bec:	64f2                	ld	s1,280(sp)
    80004bee:	a03d                	j	80004c1c <sys_link+0xf4>
    iunlockput(dp);
    80004bf0:	854a                	mv	a0,s2
    80004bf2:	ff8fe0ef          	jal	800033ea <iunlockput>
  ilock(ip);
    80004bf6:	8526                	mv	a0,s1
    80004bf8:	de8fe0ef          	jal	800031e0 <ilock>
  ip->nlink--;
    80004bfc:	04a4d783          	lhu	a5,74(s1)
    80004c00:	37fd                	addiw	a5,a5,-1
    80004c02:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004c06:	8526                	mv	a0,s1
    80004c08:	d24fe0ef          	jal	8000312c <iupdate>
  iunlockput(ip);
    80004c0c:	8526                	mv	a0,s1
    80004c0e:	fdcfe0ef          	jal	800033ea <iunlockput>
  end_op();
    80004c12:	ecffe0ef          	jal	80003ae0 <end_op>
  return -1;
    80004c16:	57fd                	li	a5,-1
    80004c18:	64f2                	ld	s1,280(sp)
    80004c1a:	6952                	ld	s2,272(sp)
}
    80004c1c:	853e                	mv	a0,a5
    80004c1e:	70b2                	ld	ra,296(sp)
    80004c20:	7412                	ld	s0,288(sp)
    80004c22:	6155                	addi	sp,sp,304
    80004c24:	8082                	ret

0000000080004c26 <sys_unlink>:
{
    80004c26:	7151                	addi	sp,sp,-240
    80004c28:	f586                	sd	ra,232(sp)
    80004c2a:	f1a2                	sd	s0,224(sp)
    80004c2c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004c2e:	08000613          	li	a2,128
    80004c32:	f3040593          	addi	a1,s0,-208
    80004c36:	4501                	li	a0,0
    80004c38:	b95fd0ef          	jal	800027cc <argstr>
    80004c3c:	16054063          	bltz	a0,80004d9c <sys_unlink+0x176>
    80004c40:	eda6                	sd	s1,216(sp)
  begin_op();
    80004c42:	e35fe0ef          	jal	80003a76 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004c46:	fb040593          	addi	a1,s0,-80
    80004c4a:	f3040513          	addi	a0,s0,-208
    80004c4e:	c87fe0ef          	jal	800038d4 <nameiparent>
    80004c52:	84aa                	mv	s1,a0
    80004c54:	c945                	beqz	a0,80004d04 <sys_unlink+0xde>
  ilock(dp);
    80004c56:	d8afe0ef          	jal	800031e0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004c5a:	00003597          	auipc	a1,0x3
    80004c5e:	9f658593          	addi	a1,a1,-1546 # 80007650 <etext+0x650>
    80004c62:	fb040513          	addi	a0,s0,-80
    80004c66:	9d9fe0ef          	jal	8000363e <namecmp>
    80004c6a:	10050e63          	beqz	a0,80004d86 <sys_unlink+0x160>
    80004c6e:	00003597          	auipc	a1,0x3
    80004c72:	9ea58593          	addi	a1,a1,-1558 # 80007658 <etext+0x658>
    80004c76:	fb040513          	addi	a0,s0,-80
    80004c7a:	9c5fe0ef          	jal	8000363e <namecmp>
    80004c7e:	10050463          	beqz	a0,80004d86 <sys_unlink+0x160>
    80004c82:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004c84:	f2c40613          	addi	a2,s0,-212
    80004c88:	fb040593          	addi	a1,s0,-80
    80004c8c:	8526                	mv	a0,s1
    80004c8e:	9c7fe0ef          	jal	80003654 <dirlookup>
    80004c92:	892a                	mv	s2,a0
    80004c94:	0e050863          	beqz	a0,80004d84 <sys_unlink+0x15e>
  ilock(ip);
    80004c98:	d48fe0ef          	jal	800031e0 <ilock>
  if(ip->nlink < 1)
    80004c9c:	04a91783          	lh	a5,74(s2)
    80004ca0:	06f05763          	blez	a5,80004d0e <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004ca4:	04491703          	lh	a4,68(s2)
    80004ca8:	4785                	li	a5,1
    80004caa:	06f70963          	beq	a4,a5,80004d1c <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004cae:	4641                	li	a2,16
    80004cb0:	4581                	li	a1,0
    80004cb2:	fc040513          	addi	a0,s0,-64
    80004cb6:	812fc0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004cba:	4741                	li	a4,16
    80004cbc:	f2c42683          	lw	a3,-212(s0)
    80004cc0:	fc040613          	addi	a2,s0,-64
    80004cc4:	4581                	li	a1,0
    80004cc6:	8526                	mv	a0,s1
    80004cc8:	869fe0ef          	jal	80003530 <writei>
    80004ccc:	47c1                	li	a5,16
    80004cce:	08f51b63          	bne	a0,a5,80004d64 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004cd2:	04491703          	lh	a4,68(s2)
    80004cd6:	4785                	li	a5,1
    80004cd8:	08f70d63          	beq	a4,a5,80004d72 <sys_unlink+0x14c>
  iunlockput(dp);
    80004cdc:	8526                	mv	a0,s1
    80004cde:	f0cfe0ef          	jal	800033ea <iunlockput>
  ip->nlink--;
    80004ce2:	04a95783          	lhu	a5,74(s2)
    80004ce6:	37fd                	addiw	a5,a5,-1
    80004ce8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004cec:	854a                	mv	a0,s2
    80004cee:	c3efe0ef          	jal	8000312c <iupdate>
  iunlockput(ip);
    80004cf2:	854a                	mv	a0,s2
    80004cf4:	ef6fe0ef          	jal	800033ea <iunlockput>
  end_op();
    80004cf8:	de9fe0ef          	jal	80003ae0 <end_op>
  return 0;
    80004cfc:	4501                	li	a0,0
    80004cfe:	64ee                	ld	s1,216(sp)
    80004d00:	694e                	ld	s2,208(sp)
    80004d02:	a849                	j	80004d94 <sys_unlink+0x16e>
    end_op();
    80004d04:	dddfe0ef          	jal	80003ae0 <end_op>
    return -1;
    80004d08:	557d                	li	a0,-1
    80004d0a:	64ee                	ld	s1,216(sp)
    80004d0c:	a061                	j	80004d94 <sys_unlink+0x16e>
    80004d0e:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004d10:	00003517          	auipc	a0,0x3
    80004d14:	95050513          	addi	a0,a0,-1712 # 80007660 <etext+0x660>
    80004d18:	a7dfb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004d1c:	04c92703          	lw	a4,76(s2)
    80004d20:	02000793          	li	a5,32
    80004d24:	f8e7f5e3          	bgeu	a5,a4,80004cae <sys_unlink+0x88>
    80004d28:	e5ce                	sd	s3,200(sp)
    80004d2a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d2e:	4741                	li	a4,16
    80004d30:	86ce                	mv	a3,s3
    80004d32:	f1840613          	addi	a2,s0,-232
    80004d36:	4581                	li	a1,0
    80004d38:	854a                	mv	a0,s2
    80004d3a:	efafe0ef          	jal	80003434 <readi>
    80004d3e:	47c1                	li	a5,16
    80004d40:	00f51c63          	bne	a0,a5,80004d58 <sys_unlink+0x132>
    if(de.inum != 0)
    80004d44:	f1845783          	lhu	a5,-232(s0)
    80004d48:	efa1                	bnez	a5,80004da0 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004d4a:	29c1                	addiw	s3,s3,16
    80004d4c:	04c92783          	lw	a5,76(s2)
    80004d50:	fcf9efe3          	bltu	s3,a5,80004d2e <sys_unlink+0x108>
    80004d54:	69ae                	ld	s3,200(sp)
    80004d56:	bfa1                	j	80004cae <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004d58:	00003517          	auipc	a0,0x3
    80004d5c:	92050513          	addi	a0,a0,-1760 # 80007678 <etext+0x678>
    80004d60:	a35fb0ef          	jal	80000794 <panic>
    80004d64:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004d66:	00003517          	auipc	a0,0x3
    80004d6a:	92a50513          	addi	a0,a0,-1750 # 80007690 <etext+0x690>
    80004d6e:	a27fb0ef          	jal	80000794 <panic>
    dp->nlink--;
    80004d72:	04a4d783          	lhu	a5,74(s1)
    80004d76:	37fd                	addiw	a5,a5,-1
    80004d78:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004d7c:	8526                	mv	a0,s1
    80004d7e:	baefe0ef          	jal	8000312c <iupdate>
    80004d82:	bfa9                	j	80004cdc <sys_unlink+0xb6>
    80004d84:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004d86:	8526                	mv	a0,s1
    80004d88:	e62fe0ef          	jal	800033ea <iunlockput>
  end_op();
    80004d8c:	d55fe0ef          	jal	80003ae0 <end_op>
  return -1;
    80004d90:	557d                	li	a0,-1
    80004d92:	64ee                	ld	s1,216(sp)
}
    80004d94:	70ae                	ld	ra,232(sp)
    80004d96:	740e                	ld	s0,224(sp)
    80004d98:	616d                	addi	sp,sp,240
    80004d9a:	8082                	ret
    return -1;
    80004d9c:	557d                	li	a0,-1
    80004d9e:	bfdd                	j	80004d94 <sys_unlink+0x16e>
    iunlockput(ip);
    80004da0:	854a                	mv	a0,s2
    80004da2:	e48fe0ef          	jal	800033ea <iunlockput>
    goto bad;
    80004da6:	694e                	ld	s2,208(sp)
    80004da8:	69ae                	ld	s3,200(sp)
    80004daa:	bff1                	j	80004d86 <sys_unlink+0x160>

0000000080004dac <sys_open>:

uint64
sys_open(void)
{
    80004dac:	7131                	addi	sp,sp,-192
    80004dae:	fd06                	sd	ra,184(sp)
    80004db0:	f922                	sd	s0,176(sp)
    80004db2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004db4:	f4c40593          	addi	a1,s0,-180
    80004db8:	4505                	li	a0,1
    80004dba:	9dbfd0ef          	jal	80002794 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004dbe:	08000613          	li	a2,128
    80004dc2:	f5040593          	addi	a1,s0,-176
    80004dc6:	4501                	li	a0,0
    80004dc8:	a05fd0ef          	jal	800027cc <argstr>
    80004dcc:	87aa                	mv	a5,a0
    return -1;
    80004dce:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004dd0:	0a07c263          	bltz	a5,80004e74 <sys_open+0xc8>
    80004dd4:	f526                	sd	s1,168(sp)

  begin_op();
    80004dd6:	ca1fe0ef          	jal	80003a76 <begin_op>

  if(omode & O_CREATE){
    80004dda:	f4c42783          	lw	a5,-180(s0)
    80004dde:	2007f793          	andi	a5,a5,512
    80004de2:	c3d5                	beqz	a5,80004e86 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004de4:	4681                	li	a3,0
    80004de6:	4601                	li	a2,0
    80004de8:	4589                	li	a1,2
    80004dea:	f5040513          	addi	a0,s0,-176
    80004dee:	aa9ff0ef          	jal	80004896 <create>
    80004df2:	84aa                	mv	s1,a0
    if(ip == 0){
    80004df4:	c541                	beqz	a0,80004e7c <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004df6:	04449703          	lh	a4,68(s1)
    80004dfa:	478d                	li	a5,3
    80004dfc:	00f71763          	bne	a4,a5,80004e0a <sys_open+0x5e>
    80004e00:	0464d703          	lhu	a4,70(s1)
    80004e04:	47a5                	li	a5,9
    80004e06:	0ae7ed63          	bltu	a5,a4,80004ec0 <sys_open+0x114>
    80004e0a:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004e0c:	fe1fe0ef          	jal	80003dec <filealloc>
    80004e10:	892a                	mv	s2,a0
    80004e12:	c179                	beqz	a0,80004ed8 <sys_open+0x12c>
    80004e14:	ed4e                	sd	s3,152(sp)
    80004e16:	a43ff0ef          	jal	80004858 <fdalloc>
    80004e1a:	89aa                	mv	s3,a0
    80004e1c:	0a054a63          	bltz	a0,80004ed0 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004e20:	04449703          	lh	a4,68(s1)
    80004e24:	478d                	li	a5,3
    80004e26:	0cf70263          	beq	a4,a5,80004eea <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004e2a:	4789                	li	a5,2
    80004e2c:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004e30:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004e34:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004e38:	f4c42783          	lw	a5,-180(s0)
    80004e3c:	0017c713          	xori	a4,a5,1
    80004e40:	8b05                	andi	a4,a4,1
    80004e42:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004e46:	0037f713          	andi	a4,a5,3
    80004e4a:	00e03733          	snez	a4,a4
    80004e4e:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004e52:	4007f793          	andi	a5,a5,1024
    80004e56:	c791                	beqz	a5,80004e62 <sys_open+0xb6>
    80004e58:	04449703          	lh	a4,68(s1)
    80004e5c:	4789                	li	a5,2
    80004e5e:	08f70d63          	beq	a4,a5,80004ef8 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004e62:	8526                	mv	a0,s1
    80004e64:	c2afe0ef          	jal	8000328e <iunlock>
  end_op();
    80004e68:	c79fe0ef          	jal	80003ae0 <end_op>

  return fd;
    80004e6c:	854e                	mv	a0,s3
    80004e6e:	74aa                	ld	s1,168(sp)
    80004e70:	790a                	ld	s2,160(sp)
    80004e72:	69ea                	ld	s3,152(sp)
}
    80004e74:	70ea                	ld	ra,184(sp)
    80004e76:	744a                	ld	s0,176(sp)
    80004e78:	6129                	addi	sp,sp,192
    80004e7a:	8082                	ret
      end_op();
    80004e7c:	c65fe0ef          	jal	80003ae0 <end_op>
      return -1;
    80004e80:	557d                	li	a0,-1
    80004e82:	74aa                	ld	s1,168(sp)
    80004e84:	bfc5                	j	80004e74 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80004e86:	f5040513          	addi	a0,s0,-176
    80004e8a:	a31fe0ef          	jal	800038ba <namei>
    80004e8e:	84aa                	mv	s1,a0
    80004e90:	c11d                	beqz	a0,80004eb6 <sys_open+0x10a>
    ilock(ip);
    80004e92:	b4efe0ef          	jal	800031e0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004e96:	04449703          	lh	a4,68(s1)
    80004e9a:	4785                	li	a5,1
    80004e9c:	f4f71de3          	bne	a4,a5,80004df6 <sys_open+0x4a>
    80004ea0:	f4c42783          	lw	a5,-180(s0)
    80004ea4:	d3bd                	beqz	a5,80004e0a <sys_open+0x5e>
      iunlockput(ip);
    80004ea6:	8526                	mv	a0,s1
    80004ea8:	d42fe0ef          	jal	800033ea <iunlockput>
      end_op();
    80004eac:	c35fe0ef          	jal	80003ae0 <end_op>
      return -1;
    80004eb0:	557d                	li	a0,-1
    80004eb2:	74aa                	ld	s1,168(sp)
    80004eb4:	b7c1                	j	80004e74 <sys_open+0xc8>
      end_op();
    80004eb6:	c2bfe0ef          	jal	80003ae0 <end_op>
      return -1;
    80004eba:	557d                	li	a0,-1
    80004ebc:	74aa                	ld	s1,168(sp)
    80004ebe:	bf5d                	j	80004e74 <sys_open+0xc8>
    iunlockput(ip);
    80004ec0:	8526                	mv	a0,s1
    80004ec2:	d28fe0ef          	jal	800033ea <iunlockput>
    end_op();
    80004ec6:	c1bfe0ef          	jal	80003ae0 <end_op>
    return -1;
    80004eca:	557d                	li	a0,-1
    80004ecc:	74aa                	ld	s1,168(sp)
    80004ece:	b75d                	j	80004e74 <sys_open+0xc8>
      fileclose(f);
    80004ed0:	854a                	mv	a0,s2
    80004ed2:	fbffe0ef          	jal	80003e90 <fileclose>
    80004ed6:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80004ed8:	8526                	mv	a0,s1
    80004eda:	d10fe0ef          	jal	800033ea <iunlockput>
    end_op();
    80004ede:	c03fe0ef          	jal	80003ae0 <end_op>
    return -1;
    80004ee2:	557d                	li	a0,-1
    80004ee4:	74aa                	ld	s1,168(sp)
    80004ee6:	790a                	ld	s2,160(sp)
    80004ee8:	b771                	j	80004e74 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80004eea:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80004eee:	04649783          	lh	a5,70(s1)
    80004ef2:	02f91223          	sh	a5,36(s2)
    80004ef6:	bf3d                	j	80004e34 <sys_open+0x88>
    itrunc(ip);
    80004ef8:	8526                	mv	a0,s1
    80004efa:	bd4fe0ef          	jal	800032ce <itrunc>
    80004efe:	b795                	j	80004e62 <sys_open+0xb6>

0000000080004f00 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004f00:	7175                	addi	sp,sp,-144
    80004f02:	e506                	sd	ra,136(sp)
    80004f04:	e122                	sd	s0,128(sp)
    80004f06:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004f08:	b6ffe0ef          	jal	80003a76 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004f0c:	08000613          	li	a2,128
    80004f10:	f7040593          	addi	a1,s0,-144
    80004f14:	4501                	li	a0,0
    80004f16:	8b7fd0ef          	jal	800027cc <argstr>
    80004f1a:	02054363          	bltz	a0,80004f40 <sys_mkdir+0x40>
    80004f1e:	4681                	li	a3,0
    80004f20:	4601                	li	a2,0
    80004f22:	4585                	li	a1,1
    80004f24:	f7040513          	addi	a0,s0,-144
    80004f28:	96fff0ef          	jal	80004896 <create>
    80004f2c:	c911                	beqz	a0,80004f40 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004f2e:	cbcfe0ef          	jal	800033ea <iunlockput>
  end_op();
    80004f32:	baffe0ef          	jal	80003ae0 <end_op>
  return 0;
    80004f36:	4501                	li	a0,0
}
    80004f38:	60aa                	ld	ra,136(sp)
    80004f3a:	640a                	ld	s0,128(sp)
    80004f3c:	6149                	addi	sp,sp,144
    80004f3e:	8082                	ret
    end_op();
    80004f40:	ba1fe0ef          	jal	80003ae0 <end_op>
    return -1;
    80004f44:	557d                	li	a0,-1
    80004f46:	bfcd                	j	80004f38 <sys_mkdir+0x38>

0000000080004f48 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004f48:	7135                	addi	sp,sp,-160
    80004f4a:	ed06                	sd	ra,152(sp)
    80004f4c:	e922                	sd	s0,144(sp)
    80004f4e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004f50:	b27fe0ef          	jal	80003a76 <begin_op>
  argint(1, &major);
    80004f54:	f6c40593          	addi	a1,s0,-148
    80004f58:	4505                	li	a0,1
    80004f5a:	83bfd0ef          	jal	80002794 <argint>
  argint(2, &minor);
    80004f5e:	f6840593          	addi	a1,s0,-152
    80004f62:	4509                	li	a0,2
    80004f64:	831fd0ef          	jal	80002794 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004f68:	08000613          	li	a2,128
    80004f6c:	f7040593          	addi	a1,s0,-144
    80004f70:	4501                	li	a0,0
    80004f72:	85bfd0ef          	jal	800027cc <argstr>
    80004f76:	02054563          	bltz	a0,80004fa0 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004f7a:	f6841683          	lh	a3,-152(s0)
    80004f7e:	f6c41603          	lh	a2,-148(s0)
    80004f82:	458d                	li	a1,3
    80004f84:	f7040513          	addi	a0,s0,-144
    80004f88:	90fff0ef          	jal	80004896 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004f8c:	c911                	beqz	a0,80004fa0 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004f8e:	c5cfe0ef          	jal	800033ea <iunlockput>
  end_op();
    80004f92:	b4ffe0ef          	jal	80003ae0 <end_op>
  return 0;
    80004f96:	4501                	li	a0,0
}
    80004f98:	60ea                	ld	ra,152(sp)
    80004f9a:	644a                	ld	s0,144(sp)
    80004f9c:	610d                	addi	sp,sp,160
    80004f9e:	8082                	ret
    end_op();
    80004fa0:	b41fe0ef          	jal	80003ae0 <end_op>
    return -1;
    80004fa4:	557d                	li	a0,-1
    80004fa6:	bfcd                	j	80004f98 <sys_mknod+0x50>

0000000080004fa8 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004fa8:	7135                	addi	sp,sp,-160
    80004faa:	ed06                	sd	ra,152(sp)
    80004fac:	e922                	sd	s0,144(sp)
    80004fae:	e14a                	sd	s2,128(sp)
    80004fb0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004fb2:	92ffc0ef          	jal	800018e0 <myproc>
    80004fb6:	892a                	mv	s2,a0
  
  begin_op();
    80004fb8:	abffe0ef          	jal	80003a76 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004fbc:	08000613          	li	a2,128
    80004fc0:	f6040593          	addi	a1,s0,-160
    80004fc4:	4501                	li	a0,0
    80004fc6:	807fd0ef          	jal	800027cc <argstr>
    80004fca:	04054363          	bltz	a0,80005010 <sys_chdir+0x68>
    80004fce:	e526                	sd	s1,136(sp)
    80004fd0:	f6040513          	addi	a0,s0,-160
    80004fd4:	8e7fe0ef          	jal	800038ba <namei>
    80004fd8:	84aa                	mv	s1,a0
    80004fda:	c915                	beqz	a0,8000500e <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80004fdc:	a04fe0ef          	jal	800031e0 <ilock>
  if(ip->type != T_DIR){
    80004fe0:	04449703          	lh	a4,68(s1)
    80004fe4:	4785                	li	a5,1
    80004fe6:	02f71963          	bne	a4,a5,80005018 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004fea:	8526                	mv	a0,s1
    80004fec:	aa2fe0ef          	jal	8000328e <iunlock>
  iput(p->cwd);
    80004ff0:	15093503          	ld	a0,336(s2)
    80004ff4:	b6efe0ef          	jal	80003362 <iput>
  end_op();
    80004ff8:	ae9fe0ef          	jal	80003ae0 <end_op>
  p->cwd = ip;
    80004ffc:	14993823          	sd	s1,336(s2)
  return 0;
    80005000:	4501                	li	a0,0
    80005002:	64aa                	ld	s1,136(sp)
}
    80005004:	60ea                	ld	ra,152(sp)
    80005006:	644a                	ld	s0,144(sp)
    80005008:	690a                	ld	s2,128(sp)
    8000500a:	610d                	addi	sp,sp,160
    8000500c:	8082                	ret
    8000500e:	64aa                	ld	s1,136(sp)
    end_op();
    80005010:	ad1fe0ef          	jal	80003ae0 <end_op>
    return -1;
    80005014:	557d                	li	a0,-1
    80005016:	b7fd                	j	80005004 <sys_chdir+0x5c>
    iunlockput(ip);
    80005018:	8526                	mv	a0,s1
    8000501a:	bd0fe0ef          	jal	800033ea <iunlockput>
    end_op();
    8000501e:	ac3fe0ef          	jal	80003ae0 <end_op>
    return -1;
    80005022:	557d                	li	a0,-1
    80005024:	64aa                	ld	s1,136(sp)
    80005026:	bff9                	j	80005004 <sys_chdir+0x5c>

0000000080005028 <sys_exec>:

uint64
sys_exec(void)
{
    80005028:	7121                	addi	sp,sp,-448
    8000502a:	ff06                	sd	ra,440(sp)
    8000502c:	fb22                	sd	s0,432(sp)
    8000502e:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005030:	e4840593          	addi	a1,s0,-440
    80005034:	4505                	li	a0,1
    80005036:	f7afd0ef          	jal	800027b0 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000503a:	08000613          	li	a2,128
    8000503e:	f5040593          	addi	a1,s0,-176
    80005042:	4501                	li	a0,0
    80005044:	f88fd0ef          	jal	800027cc <argstr>
    80005048:	87aa                	mv	a5,a0
    return -1;
    8000504a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000504c:	0c07c463          	bltz	a5,80005114 <sys_exec+0xec>
    80005050:	f726                	sd	s1,424(sp)
    80005052:	f34a                	sd	s2,416(sp)
    80005054:	ef4e                	sd	s3,408(sp)
    80005056:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005058:	10000613          	li	a2,256
    8000505c:	4581                	li	a1,0
    8000505e:	e5040513          	addi	a0,s0,-432
    80005062:	c67fb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005066:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000506a:	89a6                	mv	s3,s1
    8000506c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000506e:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005072:	00391513          	slli	a0,s2,0x3
    80005076:	e4040593          	addi	a1,s0,-448
    8000507a:	e4843783          	ld	a5,-440(s0)
    8000507e:	953e                	add	a0,a0,a5
    80005080:	e8afd0ef          	jal	8000270a <fetchaddr>
    80005084:	02054663          	bltz	a0,800050b0 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005088:	e4043783          	ld	a5,-448(s0)
    8000508c:	c3a9                	beqz	a5,800050ce <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000508e:	a97fb0ef          	jal	80000b24 <kalloc>
    80005092:	85aa                	mv	a1,a0
    80005094:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005098:	cd01                	beqz	a0,800050b0 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000509a:	6605                	lui	a2,0x1
    8000509c:	e4043503          	ld	a0,-448(s0)
    800050a0:	eb4fd0ef          	jal	80002754 <fetchstr>
    800050a4:	00054663          	bltz	a0,800050b0 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800050a8:	0905                	addi	s2,s2,1
    800050aa:	09a1                	addi	s3,s3,8
    800050ac:	fd4913e3          	bne	s2,s4,80005072 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800050b0:	f5040913          	addi	s2,s0,-176
    800050b4:	6088                	ld	a0,0(s1)
    800050b6:	c931                	beqz	a0,8000510a <sys_exec+0xe2>
    kfree(argv[i]);
    800050b8:	98bfb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800050bc:	04a1                	addi	s1,s1,8
    800050be:	ff249be3          	bne	s1,s2,800050b4 <sys_exec+0x8c>
  return -1;
    800050c2:	557d                	li	a0,-1
    800050c4:	74ba                	ld	s1,424(sp)
    800050c6:	791a                	ld	s2,416(sp)
    800050c8:	69fa                	ld	s3,408(sp)
    800050ca:	6a5a                	ld	s4,400(sp)
    800050cc:	a0a1                	j	80005114 <sys_exec+0xec>
      argv[i] = 0;
    800050ce:	0009079b          	sext.w	a5,s2
    800050d2:	078e                	slli	a5,a5,0x3
    800050d4:	fd078793          	addi	a5,a5,-48
    800050d8:	97a2                	add	a5,a5,s0
    800050da:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    800050de:	e5040593          	addi	a1,s0,-432
    800050e2:	f5040513          	addi	a0,s0,-176
    800050e6:	ba8ff0ef          	jal	8000448e <exec>
    800050ea:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800050ec:	f5040993          	addi	s3,s0,-176
    800050f0:	6088                	ld	a0,0(s1)
    800050f2:	c511                	beqz	a0,800050fe <sys_exec+0xd6>
    kfree(argv[i]);
    800050f4:	94ffb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800050f8:	04a1                	addi	s1,s1,8
    800050fa:	ff349be3          	bne	s1,s3,800050f0 <sys_exec+0xc8>
  return ret;
    800050fe:	854a                	mv	a0,s2
    80005100:	74ba                	ld	s1,424(sp)
    80005102:	791a                	ld	s2,416(sp)
    80005104:	69fa                	ld	s3,408(sp)
    80005106:	6a5a                	ld	s4,400(sp)
    80005108:	a031                	j	80005114 <sys_exec+0xec>
  return -1;
    8000510a:	557d                	li	a0,-1
    8000510c:	74ba                	ld	s1,424(sp)
    8000510e:	791a                	ld	s2,416(sp)
    80005110:	69fa                	ld	s3,408(sp)
    80005112:	6a5a                	ld	s4,400(sp)
}
    80005114:	70fa                	ld	ra,440(sp)
    80005116:	745a                	ld	s0,432(sp)
    80005118:	6139                	addi	sp,sp,448
    8000511a:	8082                	ret

000000008000511c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000511c:	7139                	addi	sp,sp,-64
    8000511e:	fc06                	sd	ra,56(sp)
    80005120:	f822                	sd	s0,48(sp)
    80005122:	f426                	sd	s1,40(sp)
    80005124:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005126:	fbafc0ef          	jal	800018e0 <myproc>
    8000512a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000512c:	fd840593          	addi	a1,s0,-40
    80005130:	4501                	li	a0,0
    80005132:	e7efd0ef          	jal	800027b0 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005136:	fc840593          	addi	a1,s0,-56
    8000513a:	fd040513          	addi	a0,s0,-48
    8000513e:	85cff0ef          	jal	8000419a <pipealloc>
    return -1;
    80005142:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005144:	0a054463          	bltz	a0,800051ec <sys_pipe+0xd0>
  fd0 = -1;
    80005148:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000514c:	fd043503          	ld	a0,-48(s0)
    80005150:	f08ff0ef          	jal	80004858 <fdalloc>
    80005154:	fca42223          	sw	a0,-60(s0)
    80005158:	08054163          	bltz	a0,800051da <sys_pipe+0xbe>
    8000515c:	fc843503          	ld	a0,-56(s0)
    80005160:	ef8ff0ef          	jal	80004858 <fdalloc>
    80005164:	fca42023          	sw	a0,-64(s0)
    80005168:	06054063          	bltz	a0,800051c8 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000516c:	4691                	li	a3,4
    8000516e:	fc440613          	addi	a2,s0,-60
    80005172:	fd843583          	ld	a1,-40(s0)
    80005176:	68a8                	ld	a0,80(s1)
    80005178:	bdafc0ef          	jal	80001552 <copyout>
    8000517c:	00054e63          	bltz	a0,80005198 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005180:	4691                	li	a3,4
    80005182:	fc040613          	addi	a2,s0,-64
    80005186:	fd843583          	ld	a1,-40(s0)
    8000518a:	0591                	addi	a1,a1,4
    8000518c:	68a8                	ld	a0,80(s1)
    8000518e:	bc4fc0ef          	jal	80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005192:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005194:	04055c63          	bgez	a0,800051ec <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005198:	fc442783          	lw	a5,-60(s0)
    8000519c:	07e9                	addi	a5,a5,26
    8000519e:	078e                	slli	a5,a5,0x3
    800051a0:	97a6                	add	a5,a5,s1
    800051a2:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800051a6:	fc042783          	lw	a5,-64(s0)
    800051aa:	07e9                	addi	a5,a5,26
    800051ac:	078e                	slli	a5,a5,0x3
    800051ae:	94be                	add	s1,s1,a5
    800051b0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800051b4:	fd043503          	ld	a0,-48(s0)
    800051b8:	cd9fe0ef          	jal	80003e90 <fileclose>
    fileclose(wf);
    800051bc:	fc843503          	ld	a0,-56(s0)
    800051c0:	cd1fe0ef          	jal	80003e90 <fileclose>
    return -1;
    800051c4:	57fd                	li	a5,-1
    800051c6:	a01d                	j	800051ec <sys_pipe+0xd0>
    if(fd0 >= 0)
    800051c8:	fc442783          	lw	a5,-60(s0)
    800051cc:	0007c763          	bltz	a5,800051da <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800051d0:	07e9                	addi	a5,a5,26
    800051d2:	078e                	slli	a5,a5,0x3
    800051d4:	97a6                	add	a5,a5,s1
    800051d6:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800051da:	fd043503          	ld	a0,-48(s0)
    800051de:	cb3fe0ef          	jal	80003e90 <fileclose>
    fileclose(wf);
    800051e2:	fc843503          	ld	a0,-56(s0)
    800051e6:	cabfe0ef          	jal	80003e90 <fileclose>
    return -1;
    800051ea:	57fd                	li	a5,-1
}
    800051ec:	853e                	mv	a0,a5
    800051ee:	70e2                	ld	ra,56(sp)
    800051f0:	7442                	ld	s0,48(sp)
    800051f2:	74a2                	ld	s1,40(sp)
    800051f4:	6121                	addi	sp,sp,64
    800051f6:	8082                	ret
	...

0000000080005200 <kernelvec>:
    80005200:	7111                	addi	sp,sp,-256
    80005202:	e006                	sd	ra,0(sp)
    80005204:	e40a                	sd	sp,8(sp)
    80005206:	e80e                	sd	gp,16(sp)
    80005208:	ec12                	sd	tp,24(sp)
    8000520a:	f016                	sd	t0,32(sp)
    8000520c:	f41a                	sd	t1,40(sp)
    8000520e:	f81e                	sd	t2,48(sp)
    80005210:	e4aa                	sd	a0,72(sp)
    80005212:	e8ae                	sd	a1,80(sp)
    80005214:	ecb2                	sd	a2,88(sp)
    80005216:	f0b6                	sd	a3,96(sp)
    80005218:	f4ba                	sd	a4,104(sp)
    8000521a:	f8be                	sd	a5,112(sp)
    8000521c:	fcc2                	sd	a6,120(sp)
    8000521e:	e146                	sd	a7,128(sp)
    80005220:	edf2                	sd	t3,216(sp)
    80005222:	f1f6                	sd	t4,224(sp)
    80005224:	f5fa                	sd	t5,232(sp)
    80005226:	f9fe                	sd	t6,240(sp)
    80005228:	bf2fd0ef          	jal	8000261a <kerneltrap>
    8000522c:	6082                	ld	ra,0(sp)
    8000522e:	6122                	ld	sp,8(sp)
    80005230:	61c2                	ld	gp,16(sp)
    80005232:	7282                	ld	t0,32(sp)
    80005234:	7322                	ld	t1,40(sp)
    80005236:	73c2                	ld	t2,48(sp)
    80005238:	6526                	ld	a0,72(sp)
    8000523a:	65c6                	ld	a1,80(sp)
    8000523c:	6666                	ld	a2,88(sp)
    8000523e:	7686                	ld	a3,96(sp)
    80005240:	7726                	ld	a4,104(sp)
    80005242:	77c6                	ld	a5,112(sp)
    80005244:	7866                	ld	a6,120(sp)
    80005246:	688a                	ld	a7,128(sp)
    80005248:	6e6e                	ld	t3,216(sp)
    8000524a:	7e8e                	ld	t4,224(sp)
    8000524c:	7f2e                	ld	t5,232(sp)
    8000524e:	7fce                	ld	t6,240(sp)
    80005250:	6111                	addi	sp,sp,256
    80005252:	10200073          	sret
	...

000000008000525e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000525e:	1141                	addi	sp,sp,-16
    80005260:	e422                	sd	s0,8(sp)
    80005262:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005264:	0c0007b7          	lui	a5,0xc000
    80005268:	4705                	li	a4,1
    8000526a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000526c:	0c0007b7          	lui	a5,0xc000
    80005270:	c3d8                	sw	a4,4(a5)
}
    80005272:	6422                	ld	s0,8(sp)
    80005274:	0141                	addi	sp,sp,16
    80005276:	8082                	ret

0000000080005278 <plicinithart>:

void
plicinithart(void)
{
    80005278:	1141                	addi	sp,sp,-16
    8000527a:	e406                	sd	ra,8(sp)
    8000527c:	e022                	sd	s0,0(sp)
    8000527e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005280:	e34fc0ef          	jal	800018b4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005284:	0085171b          	slliw	a4,a0,0x8
    80005288:	0c0027b7          	lui	a5,0xc002
    8000528c:	97ba                	add	a5,a5,a4
    8000528e:	40200713          	li	a4,1026
    80005292:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005296:	00d5151b          	slliw	a0,a0,0xd
    8000529a:	0c2017b7          	lui	a5,0xc201
    8000529e:	97aa                	add	a5,a5,a0
    800052a0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800052a4:	60a2                	ld	ra,8(sp)
    800052a6:	6402                	ld	s0,0(sp)
    800052a8:	0141                	addi	sp,sp,16
    800052aa:	8082                	ret

00000000800052ac <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800052ac:	1141                	addi	sp,sp,-16
    800052ae:	e406                	sd	ra,8(sp)
    800052b0:	e022                	sd	s0,0(sp)
    800052b2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800052b4:	e00fc0ef          	jal	800018b4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800052b8:	00d5151b          	slliw	a0,a0,0xd
    800052bc:	0c2017b7          	lui	a5,0xc201
    800052c0:	97aa                	add	a5,a5,a0
  return irq;
}
    800052c2:	43c8                	lw	a0,4(a5)
    800052c4:	60a2                	ld	ra,8(sp)
    800052c6:	6402                	ld	s0,0(sp)
    800052c8:	0141                	addi	sp,sp,16
    800052ca:	8082                	ret

00000000800052cc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800052cc:	1101                	addi	sp,sp,-32
    800052ce:	ec06                	sd	ra,24(sp)
    800052d0:	e822                	sd	s0,16(sp)
    800052d2:	e426                	sd	s1,8(sp)
    800052d4:	1000                	addi	s0,sp,32
    800052d6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800052d8:	ddcfc0ef          	jal	800018b4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800052dc:	00d5151b          	slliw	a0,a0,0xd
    800052e0:	0c2017b7          	lui	a5,0xc201
    800052e4:	97aa                	add	a5,a5,a0
    800052e6:	c3c4                	sw	s1,4(a5)
}
    800052e8:	60e2                	ld	ra,24(sp)
    800052ea:	6442                	ld	s0,16(sp)
    800052ec:	64a2                	ld	s1,8(sp)
    800052ee:	6105                	addi	sp,sp,32
    800052f0:	8082                	ret

00000000800052f2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800052f2:	1141                	addi	sp,sp,-16
    800052f4:	e406                	sd	ra,8(sp)
    800052f6:	e022                	sd	s0,0(sp)
    800052f8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800052fa:	479d                	li	a5,7
    800052fc:	04a7ca63          	blt	a5,a0,80005350 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005300:	0001c797          	auipc	a5,0x1c
    80005304:	87078793          	addi	a5,a5,-1936 # 80020b70 <disk>
    80005308:	97aa                	add	a5,a5,a0
    8000530a:	0187c783          	lbu	a5,24(a5)
    8000530e:	e7b9                	bnez	a5,8000535c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005310:	00451693          	slli	a3,a0,0x4
    80005314:	0001c797          	auipc	a5,0x1c
    80005318:	85c78793          	addi	a5,a5,-1956 # 80020b70 <disk>
    8000531c:	6398                	ld	a4,0(a5)
    8000531e:	9736                	add	a4,a4,a3
    80005320:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005324:	6398                	ld	a4,0(a5)
    80005326:	9736                	add	a4,a4,a3
    80005328:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000532c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005330:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005334:	97aa                	add	a5,a5,a0
    80005336:	4705                	li	a4,1
    80005338:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000533c:	0001c517          	auipc	a0,0x1c
    80005340:	84c50513          	addi	a0,a0,-1972 # 80020b88 <disk+0x18>
    80005344:	bb7fc0ef          	jal	80001efa <wakeup>
}
    80005348:	60a2                	ld	ra,8(sp)
    8000534a:	6402                	ld	s0,0(sp)
    8000534c:	0141                	addi	sp,sp,16
    8000534e:	8082                	ret
    panic("free_desc 1");
    80005350:	00002517          	auipc	a0,0x2
    80005354:	35050513          	addi	a0,a0,848 # 800076a0 <etext+0x6a0>
    80005358:	c3cfb0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    8000535c:	00002517          	auipc	a0,0x2
    80005360:	35450513          	addi	a0,a0,852 # 800076b0 <etext+0x6b0>
    80005364:	c30fb0ef          	jal	80000794 <panic>

0000000080005368 <virtio_disk_init>:
{
    80005368:	1101                	addi	sp,sp,-32
    8000536a:	ec06                	sd	ra,24(sp)
    8000536c:	e822                	sd	s0,16(sp)
    8000536e:	e426                	sd	s1,8(sp)
    80005370:	e04a                	sd	s2,0(sp)
    80005372:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005374:	00002597          	auipc	a1,0x2
    80005378:	34c58593          	addi	a1,a1,844 # 800076c0 <etext+0x6c0>
    8000537c:	0001c517          	auipc	a0,0x1c
    80005380:	91c50513          	addi	a0,a0,-1764 # 80020c98 <disk+0x128>
    80005384:	ff0fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005388:	100017b7          	lui	a5,0x10001
    8000538c:	4398                	lw	a4,0(a5)
    8000538e:	2701                	sext.w	a4,a4
    80005390:	747277b7          	lui	a5,0x74727
    80005394:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005398:	18f71063          	bne	a4,a5,80005518 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000539c:	100017b7          	lui	a5,0x10001
    800053a0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800053a2:	439c                	lw	a5,0(a5)
    800053a4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800053a6:	4709                	li	a4,2
    800053a8:	16e79863          	bne	a5,a4,80005518 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800053ac:	100017b7          	lui	a5,0x10001
    800053b0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800053b2:	439c                	lw	a5,0(a5)
    800053b4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800053b6:	16e79163          	bne	a5,a4,80005518 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800053ba:	100017b7          	lui	a5,0x10001
    800053be:	47d8                	lw	a4,12(a5)
    800053c0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800053c2:	554d47b7          	lui	a5,0x554d4
    800053c6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800053ca:	14f71763          	bne	a4,a5,80005518 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800053ce:	100017b7          	lui	a5,0x10001
    800053d2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800053d6:	4705                	li	a4,1
    800053d8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800053da:	470d                	li	a4,3
    800053dc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800053de:	10001737          	lui	a4,0x10001
    800053e2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800053e4:	c7ffe737          	lui	a4,0xc7ffe
    800053e8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fddaaf>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800053ec:	8ef9                	and	a3,a3,a4
    800053ee:	10001737          	lui	a4,0x10001
    800053f2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800053f4:	472d                	li	a4,11
    800053f6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800053f8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800053fc:	439c                	lw	a5,0(a5)
    800053fe:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005402:	8ba1                	andi	a5,a5,8
    80005404:	12078063          	beqz	a5,80005524 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005408:	100017b7          	lui	a5,0x10001
    8000540c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005410:	100017b7          	lui	a5,0x10001
    80005414:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005418:	439c                	lw	a5,0(a5)
    8000541a:	2781                	sext.w	a5,a5
    8000541c:	10079a63          	bnez	a5,80005530 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005420:	100017b7          	lui	a5,0x10001
    80005424:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005428:	439c                	lw	a5,0(a5)
    8000542a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000542c:	10078863          	beqz	a5,8000553c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005430:	471d                	li	a4,7
    80005432:	10f77b63          	bgeu	a4,a5,80005548 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005436:	eeefb0ef          	jal	80000b24 <kalloc>
    8000543a:	0001b497          	auipc	s1,0x1b
    8000543e:	73648493          	addi	s1,s1,1846 # 80020b70 <disk>
    80005442:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005444:	ee0fb0ef          	jal	80000b24 <kalloc>
    80005448:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000544a:	edafb0ef          	jal	80000b24 <kalloc>
    8000544e:	87aa                	mv	a5,a0
    80005450:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005452:	6088                	ld	a0,0(s1)
    80005454:	10050063          	beqz	a0,80005554 <virtio_disk_init+0x1ec>
    80005458:	0001b717          	auipc	a4,0x1b
    8000545c:	72073703          	ld	a4,1824(a4) # 80020b78 <disk+0x8>
    80005460:	0e070a63          	beqz	a4,80005554 <virtio_disk_init+0x1ec>
    80005464:	0e078863          	beqz	a5,80005554 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005468:	6605                	lui	a2,0x1
    8000546a:	4581                	li	a1,0
    8000546c:	85dfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005470:	0001b497          	auipc	s1,0x1b
    80005474:	70048493          	addi	s1,s1,1792 # 80020b70 <disk>
    80005478:	6605                	lui	a2,0x1
    8000547a:	4581                	li	a1,0
    8000547c:	6488                	ld	a0,8(s1)
    8000547e:	84bfb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005482:	6605                	lui	a2,0x1
    80005484:	4581                	li	a1,0
    80005486:	6888                	ld	a0,16(s1)
    80005488:	841fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000548c:	100017b7          	lui	a5,0x10001
    80005490:	4721                	li	a4,8
    80005492:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005494:	4098                	lw	a4,0(s1)
    80005496:	100017b7          	lui	a5,0x10001
    8000549a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000549e:	40d8                	lw	a4,4(s1)
    800054a0:	100017b7          	lui	a5,0x10001
    800054a4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800054a8:	649c                	ld	a5,8(s1)
    800054aa:	0007869b          	sext.w	a3,a5
    800054ae:	10001737          	lui	a4,0x10001
    800054b2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800054b6:	9781                	srai	a5,a5,0x20
    800054b8:	10001737          	lui	a4,0x10001
    800054bc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800054c0:	689c                	ld	a5,16(s1)
    800054c2:	0007869b          	sext.w	a3,a5
    800054c6:	10001737          	lui	a4,0x10001
    800054ca:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800054ce:	9781                	srai	a5,a5,0x20
    800054d0:	10001737          	lui	a4,0x10001
    800054d4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800054d8:	10001737          	lui	a4,0x10001
    800054dc:	4785                	li	a5,1
    800054de:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800054e0:	00f48c23          	sb	a5,24(s1)
    800054e4:	00f48ca3          	sb	a5,25(s1)
    800054e8:	00f48d23          	sb	a5,26(s1)
    800054ec:	00f48da3          	sb	a5,27(s1)
    800054f0:	00f48e23          	sb	a5,28(s1)
    800054f4:	00f48ea3          	sb	a5,29(s1)
    800054f8:	00f48f23          	sb	a5,30(s1)
    800054fc:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005500:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005504:	100017b7          	lui	a5,0x10001
    80005508:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000550c:	60e2                	ld	ra,24(sp)
    8000550e:	6442                	ld	s0,16(sp)
    80005510:	64a2                	ld	s1,8(sp)
    80005512:	6902                	ld	s2,0(sp)
    80005514:	6105                	addi	sp,sp,32
    80005516:	8082                	ret
    panic("could not find virtio disk");
    80005518:	00002517          	auipc	a0,0x2
    8000551c:	1b850513          	addi	a0,a0,440 # 800076d0 <etext+0x6d0>
    80005520:	a74fb0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005524:	00002517          	auipc	a0,0x2
    80005528:	1cc50513          	addi	a0,a0,460 # 800076f0 <etext+0x6f0>
    8000552c:	a68fb0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    80005530:	00002517          	auipc	a0,0x2
    80005534:	1e050513          	addi	a0,a0,480 # 80007710 <etext+0x710>
    80005538:	a5cfb0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    8000553c:	00002517          	auipc	a0,0x2
    80005540:	1f450513          	addi	a0,a0,500 # 80007730 <etext+0x730>
    80005544:	a50fb0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    80005548:	00002517          	auipc	a0,0x2
    8000554c:	20850513          	addi	a0,a0,520 # 80007750 <etext+0x750>
    80005550:	a44fb0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    80005554:	00002517          	auipc	a0,0x2
    80005558:	21c50513          	addi	a0,a0,540 # 80007770 <etext+0x770>
    8000555c:	a38fb0ef          	jal	80000794 <panic>

0000000080005560 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005560:	7159                	addi	sp,sp,-112
    80005562:	f486                	sd	ra,104(sp)
    80005564:	f0a2                	sd	s0,96(sp)
    80005566:	eca6                	sd	s1,88(sp)
    80005568:	e8ca                	sd	s2,80(sp)
    8000556a:	e4ce                	sd	s3,72(sp)
    8000556c:	e0d2                	sd	s4,64(sp)
    8000556e:	fc56                	sd	s5,56(sp)
    80005570:	f85a                	sd	s6,48(sp)
    80005572:	f45e                	sd	s7,40(sp)
    80005574:	f062                	sd	s8,32(sp)
    80005576:	ec66                	sd	s9,24(sp)
    80005578:	1880                	addi	s0,sp,112
    8000557a:	8a2a                	mv	s4,a0
    8000557c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000557e:	00c52c83          	lw	s9,12(a0)
    80005582:	001c9c9b          	slliw	s9,s9,0x1
    80005586:	1c82                	slli	s9,s9,0x20
    80005588:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000558c:	0001b517          	auipc	a0,0x1b
    80005590:	70c50513          	addi	a0,a0,1804 # 80020c98 <disk+0x128>
    80005594:	e60fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    80005598:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000559a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000559c:	0001bb17          	auipc	s6,0x1b
    800055a0:	5d4b0b13          	addi	s6,s6,1492 # 80020b70 <disk>
  for(int i = 0; i < 3; i++){
    800055a4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800055a6:	0001bc17          	auipc	s8,0x1b
    800055aa:	6f2c0c13          	addi	s8,s8,1778 # 80020c98 <disk+0x128>
    800055ae:	a8b9                	j	8000560c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800055b0:	00fb0733          	add	a4,s6,a5
    800055b4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800055b8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800055ba:	0207c563          	bltz	a5,800055e4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800055be:	2905                	addiw	s2,s2,1
    800055c0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800055c2:	05590963          	beq	s2,s5,80005614 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    800055c6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800055c8:	0001b717          	auipc	a4,0x1b
    800055cc:	5a870713          	addi	a4,a4,1448 # 80020b70 <disk>
    800055d0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800055d2:	01874683          	lbu	a3,24(a4)
    800055d6:	fee9                	bnez	a3,800055b0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800055d8:	2785                	addiw	a5,a5,1
    800055da:	0705                	addi	a4,a4,1
    800055dc:	fe979be3          	bne	a5,s1,800055d2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    800055e0:	57fd                	li	a5,-1
    800055e2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800055e4:	01205d63          	blez	s2,800055fe <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800055e8:	f9042503          	lw	a0,-112(s0)
    800055ec:	d07ff0ef          	jal	800052f2 <free_desc>
      for(int j = 0; j < i; j++)
    800055f0:	4785                	li	a5,1
    800055f2:	0127d663          	bge	a5,s2,800055fe <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800055f6:	f9442503          	lw	a0,-108(s0)
    800055fa:	cf9ff0ef          	jal	800052f2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800055fe:	85e2                	mv	a1,s8
    80005600:	0001b517          	auipc	a0,0x1b
    80005604:	58850513          	addi	a0,a0,1416 # 80020b88 <disk+0x18>
    80005608:	8a7fc0ef          	jal	80001eae <sleep>
  for(int i = 0; i < 3; i++){
    8000560c:	f9040613          	addi	a2,s0,-112
    80005610:	894e                	mv	s2,s3
    80005612:	bf55                	j	800055c6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005614:	f9042503          	lw	a0,-112(s0)
    80005618:	00451693          	slli	a3,a0,0x4

  if(write)
    8000561c:	0001b797          	auipc	a5,0x1b
    80005620:	55478793          	addi	a5,a5,1364 # 80020b70 <disk>
    80005624:	00a50713          	addi	a4,a0,10
    80005628:	0712                	slli	a4,a4,0x4
    8000562a:	973e                	add	a4,a4,a5
    8000562c:	01703633          	snez	a2,s7
    80005630:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005632:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005636:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000563a:	6398                	ld	a4,0(a5)
    8000563c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000563e:	0a868613          	addi	a2,a3,168
    80005642:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005644:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005646:	6390                	ld	a2,0(a5)
    80005648:	00d605b3          	add	a1,a2,a3
    8000564c:	4741                	li	a4,16
    8000564e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005650:	4805                	li	a6,1
    80005652:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005656:	f9442703          	lw	a4,-108(s0)
    8000565a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000565e:	0712                	slli	a4,a4,0x4
    80005660:	963a                	add	a2,a2,a4
    80005662:	058a0593          	addi	a1,s4,88
    80005666:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005668:	0007b883          	ld	a7,0(a5)
    8000566c:	9746                	add	a4,a4,a7
    8000566e:	40000613          	li	a2,1024
    80005672:	c710                	sw	a2,8(a4)
  if(write)
    80005674:	001bb613          	seqz	a2,s7
    80005678:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000567c:	00166613          	ori	a2,a2,1
    80005680:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005684:	f9842583          	lw	a1,-104(s0)
    80005688:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000568c:	00250613          	addi	a2,a0,2
    80005690:	0612                	slli	a2,a2,0x4
    80005692:	963e                	add	a2,a2,a5
    80005694:	577d                	li	a4,-1
    80005696:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000569a:	0592                	slli	a1,a1,0x4
    8000569c:	98ae                	add	a7,a7,a1
    8000569e:	03068713          	addi	a4,a3,48
    800056a2:	973e                	add	a4,a4,a5
    800056a4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800056a8:	6398                	ld	a4,0(a5)
    800056aa:	972e                	add	a4,a4,a1
    800056ac:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800056b0:	4689                	li	a3,2
    800056b2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800056b6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800056ba:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800056be:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800056c2:	6794                	ld	a3,8(a5)
    800056c4:	0026d703          	lhu	a4,2(a3)
    800056c8:	8b1d                	andi	a4,a4,7
    800056ca:	0706                	slli	a4,a4,0x1
    800056cc:	96ba                	add	a3,a3,a4
    800056ce:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800056d2:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800056d6:	6798                	ld	a4,8(a5)
    800056d8:	00275783          	lhu	a5,2(a4)
    800056dc:	2785                	addiw	a5,a5,1
    800056de:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800056e2:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800056e6:	100017b7          	lui	a5,0x10001
    800056ea:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800056ee:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800056f2:	0001b917          	auipc	s2,0x1b
    800056f6:	5a690913          	addi	s2,s2,1446 # 80020c98 <disk+0x128>
  while(b->disk == 1) {
    800056fa:	4485                	li	s1,1
    800056fc:	01079a63          	bne	a5,a6,80005710 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005700:	85ca                	mv	a1,s2
    80005702:	8552                	mv	a0,s4
    80005704:	faafc0ef          	jal	80001eae <sleep>
  while(b->disk == 1) {
    80005708:	004a2783          	lw	a5,4(s4)
    8000570c:	fe978ae3          	beq	a5,s1,80005700 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005710:	f9042903          	lw	s2,-112(s0)
    80005714:	00290713          	addi	a4,s2,2
    80005718:	0712                	slli	a4,a4,0x4
    8000571a:	0001b797          	auipc	a5,0x1b
    8000571e:	45678793          	addi	a5,a5,1110 # 80020b70 <disk>
    80005722:	97ba                	add	a5,a5,a4
    80005724:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005728:	0001b997          	auipc	s3,0x1b
    8000572c:	44898993          	addi	s3,s3,1096 # 80020b70 <disk>
    80005730:	00491713          	slli	a4,s2,0x4
    80005734:	0009b783          	ld	a5,0(s3)
    80005738:	97ba                	add	a5,a5,a4
    8000573a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000573e:	854a                	mv	a0,s2
    80005740:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005744:	bafff0ef          	jal	800052f2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005748:	8885                	andi	s1,s1,1
    8000574a:	f0fd                	bnez	s1,80005730 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000574c:	0001b517          	auipc	a0,0x1b
    80005750:	54c50513          	addi	a0,a0,1356 # 80020c98 <disk+0x128>
    80005754:	d38fb0ef          	jal	80000c8c <release>
}
    80005758:	70a6                	ld	ra,104(sp)
    8000575a:	7406                	ld	s0,96(sp)
    8000575c:	64e6                	ld	s1,88(sp)
    8000575e:	6946                	ld	s2,80(sp)
    80005760:	69a6                	ld	s3,72(sp)
    80005762:	6a06                	ld	s4,64(sp)
    80005764:	7ae2                	ld	s5,56(sp)
    80005766:	7b42                	ld	s6,48(sp)
    80005768:	7ba2                	ld	s7,40(sp)
    8000576a:	7c02                	ld	s8,32(sp)
    8000576c:	6ce2                	ld	s9,24(sp)
    8000576e:	6165                	addi	sp,sp,112
    80005770:	8082                	ret

0000000080005772 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005772:	1101                	addi	sp,sp,-32
    80005774:	ec06                	sd	ra,24(sp)
    80005776:	e822                	sd	s0,16(sp)
    80005778:	e426                	sd	s1,8(sp)
    8000577a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000577c:	0001b497          	auipc	s1,0x1b
    80005780:	3f448493          	addi	s1,s1,1012 # 80020b70 <disk>
    80005784:	0001b517          	auipc	a0,0x1b
    80005788:	51450513          	addi	a0,a0,1300 # 80020c98 <disk+0x128>
    8000578c:	c68fb0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005790:	100017b7          	lui	a5,0x10001
    80005794:	53b8                	lw	a4,96(a5)
    80005796:	8b0d                	andi	a4,a4,3
    80005798:	100017b7          	lui	a5,0x10001
    8000579c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000579e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800057a2:	689c                	ld	a5,16(s1)
    800057a4:	0204d703          	lhu	a4,32(s1)
    800057a8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800057ac:	04f70663          	beq	a4,a5,800057f8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    800057b0:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800057b4:	6898                	ld	a4,16(s1)
    800057b6:	0204d783          	lhu	a5,32(s1)
    800057ba:	8b9d                	andi	a5,a5,7
    800057bc:	078e                	slli	a5,a5,0x3
    800057be:	97ba                	add	a5,a5,a4
    800057c0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800057c2:	00278713          	addi	a4,a5,2
    800057c6:	0712                	slli	a4,a4,0x4
    800057c8:	9726                	add	a4,a4,s1
    800057ca:	01074703          	lbu	a4,16(a4)
    800057ce:	e321                	bnez	a4,8000580e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800057d0:	0789                	addi	a5,a5,2
    800057d2:	0792                	slli	a5,a5,0x4
    800057d4:	97a6                	add	a5,a5,s1
    800057d6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800057d8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800057dc:	f1efc0ef          	jal	80001efa <wakeup>

    disk.used_idx += 1;
    800057e0:	0204d783          	lhu	a5,32(s1)
    800057e4:	2785                	addiw	a5,a5,1
    800057e6:	17c2                	slli	a5,a5,0x30
    800057e8:	93c1                	srli	a5,a5,0x30
    800057ea:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800057ee:	6898                	ld	a4,16(s1)
    800057f0:	00275703          	lhu	a4,2(a4)
    800057f4:	faf71ee3          	bne	a4,a5,800057b0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800057f8:	0001b517          	auipc	a0,0x1b
    800057fc:	4a050513          	addi	a0,a0,1184 # 80020c98 <disk+0x128>
    80005800:	c8cfb0ef          	jal	80000c8c <release>
}
    80005804:	60e2                	ld	ra,24(sp)
    80005806:	6442                	ld	s0,16(sp)
    80005808:	64a2                	ld	s1,8(sp)
    8000580a:	6105                	addi	sp,sp,32
    8000580c:	8082                	ret
      panic("virtio_disk_intr status");
    8000580e:	00002517          	auipc	a0,0x2
    80005812:	f7a50513          	addi	a0,a0,-134 # 80007788 <etext+0x788>
    80005816:	f7ffa0ef          	jal	80000794 <panic>

000000008000581a <log_message>:
#include "types.h"
#include "riscv.h"
#include "defs.h"

void log_message(int level, const char* message) {
    8000581a:	1141                	addi	sp,sp,-16
    8000581c:	e406                	sd	ra,8(sp)
    8000581e:	e022                	sd	s0,0(sp)
    80005820:	0800                	addi	s0,sp,16
    80005822:	862e                	mv	a2,a1
  const char* prefix;
  switch (level) {
    80005824:	4789                	li	a5,2
    80005826:	00002597          	auipc	a1,0x2
    8000582a:	f8258593          	addi	a1,a1,-126 # 800077a8 <etext+0x7a8>
    8000582e:	02f50463          	beq	a0,a5,80005856 <log_message+0x3c>
    80005832:	478d                	li	a5,3
    case 1: prefix = "INFO"; break;
    case 2: prefix = "WARN"; break;
    case 3: prefix = "ERROR"; break;
    80005834:	00002597          	auipc	a1,0x2
    80005838:	f7c58593          	addi	a1,a1,-132 # 800077b0 <etext+0x7b0>
  switch (level) {
    8000583c:	00f50d63          	beq	a0,a5,80005856 <log_message+0x3c>
    80005840:	4785                	li	a5,1
    case 1: prefix = "INFO"; break;
    80005842:	00002597          	auipc	a1,0x2
    80005846:	f5e58593          	addi	a1,a1,-162 # 800077a0 <etext+0x7a0>
  switch (level) {
    8000584a:	00f50663          	beq	a0,a5,80005856 <log_message+0x3c>
    default: prefix = "UNKNOWN";
    8000584e:	00002597          	auipc	a1,0x2
    80005852:	f6a58593          	addi	a1,a1,-150 # 800077b8 <etext+0x7b8>
  }
  printf("%s - %s\n", prefix, message);
    80005856:	00002517          	auipc	a0,0x2
    8000585a:	f6a50513          	addi	a0,a0,-150 # 800077c0 <etext+0x7c0>
    8000585e:	c65fa0ef          	jal	800004c2 <printf>
}
    80005862:	60a2                	ld	ra,8(sp)
    80005864:	6402                	ld	s0,0(sp)
    80005866:	0141                	addi	sp,sp,16
    80005868:	8082                	ret
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
