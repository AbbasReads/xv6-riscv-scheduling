
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	89010113          	addi	sp,sp,-1904 # 80007890 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04e000ef          	jal	80000064 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002c:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000003a:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000046:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000058:	14d79073          	csrw	stimecmp,a5
}
    8000005c:	60a2                	ld	ra,8(sp)
    8000005e:	6402                	ld	s0,0(sp)
    80000060:	0141                	addi	sp,sp,16
    80000062:	8082                	ret

0000000080000064 <start>:
{
    80000064:	1141                	addi	sp,sp,-16
    80000066:	e406                	sd	ra,8(sp)
    80000068:	e022                	sd	s0,0(sp)
    8000006a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ff9b267>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	e2a78793          	addi	a5,a5,-470 # 80000eae <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a6:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c8:	30200073          	mret
}
    800000cc:	60a2                	ld	ra,8(sp)
    800000ce:	6402                	ld	s0,0(sp)
    800000d0:	0141                	addi	sp,sp,16
    800000d2:	8082                	ret

00000000800000d4 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d4:	7119                	addi	sp,sp,-128
    800000d6:	fc86                	sd	ra,120(sp)
    800000d8:	f8a2                	sd	s0,112(sp)
    800000da:	f4a6                	sd	s1,104(sp)
    800000dc:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000de:	06c05b63          	blez	a2,80000154 <consolewrite+0x80>
    800000e2:	f0ca                	sd	s2,96(sp)
    800000e4:	ecce                	sd	s3,88(sp)
    800000e6:	e8d2                	sd	s4,80(sp)
    800000e8:	e4d6                	sd	s5,72(sp)
    800000ea:	e0da                	sd	s6,64(sp)
    800000ec:	fc5e                	sd	s7,56(sp)
    800000ee:	f862                	sd	s8,48(sp)
    800000f0:	f466                	sd	s9,40(sp)
    800000f2:	f06a                	sd	s10,32(sp)
    800000f4:	8b2a                	mv	s6,a0
    800000f6:	8bae                	mv	s7,a1
    800000f8:	8a32                	mv	s4,a2
  int i = 0;
    800000fa:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000fc:	02000c93          	li	s9,32
    80000100:	02000d13          	li	s10,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000104:	f8040a93          	addi	s5,s0,-128
    80000108:	5c7d                	li	s8,-1
    8000010a:	a025                	j	80000132 <consolewrite+0x5e>
    if(nn > n - i)
    8000010c:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000110:	86ce                	mv	a3,s3
    80000112:	01748633          	add	a2,s1,s7
    80000116:	85da                	mv	a1,s6
    80000118:	8556                	mv	a0,s5
    8000011a:	218020ef          	jal	80002332 <either_copyin>
    8000011e:	03850d63          	beq	a0,s8,80000158 <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000122:	85ce                	mv	a1,s3
    80000124:	8556                	mv	a0,s5
    80000126:	7b4000ef          	jal	800008da <uartwrite>
    i += nn;
    8000012a:	009904bb          	addw	s1,s2,s1
  while(i < n){
    8000012e:	0144d963          	bge	s1,s4,80000140 <consolewrite+0x6c>
    if(nn > n - i)
    80000132:	409a07bb          	subw	a5,s4,s1
    80000136:	893e                	mv	s2,a5
    80000138:	fcfcdae3          	bge	s9,a5,8000010c <consolewrite+0x38>
    8000013c:	896a                	mv	s2,s10
    8000013e:	b7f9                	j	8000010c <consolewrite+0x38>
    80000140:	7906                	ld	s2,96(sp)
    80000142:	69e6                	ld	s3,88(sp)
    80000144:	6a46                	ld	s4,80(sp)
    80000146:	6aa6                	ld	s5,72(sp)
    80000148:	6b06                	ld	s6,64(sp)
    8000014a:	7be2                	ld	s7,56(sp)
    8000014c:	7c42                	ld	s8,48(sp)
    8000014e:	7ca2                	ld	s9,40(sp)
    80000150:	7d02                	ld	s10,32(sp)
    80000152:	a821                	j	8000016a <consolewrite+0x96>
  int i = 0;
    80000154:	4481                	li	s1,0
    80000156:	a811                	j	8000016a <consolewrite+0x96>
    80000158:	7906                	ld	s2,96(sp)
    8000015a:	69e6                	ld	s3,88(sp)
    8000015c:	6a46                	ld	s4,80(sp)
    8000015e:	6aa6                	ld	s5,72(sp)
    80000160:	6b06                	ld	s6,64(sp)
    80000162:	7be2                	ld	s7,56(sp)
    80000164:	7c42                	ld	s8,48(sp)
    80000166:	7ca2                	ld	s9,40(sp)
    80000168:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000016a:	8526                	mv	a0,s1
    8000016c:	70e6                	ld	ra,120(sp)
    8000016e:	7446                	ld	s0,112(sp)
    80000170:	74a6                	ld	s1,104(sp)
    80000172:	6109                	addi	sp,sp,128
    80000174:	8082                	ret

0000000080000176 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000176:	711d                	addi	sp,sp,-96
    80000178:	ec86                	sd	ra,88(sp)
    8000017a:	e8a2                	sd	s0,80(sp)
    8000017c:	e4a6                	sd	s1,72(sp)
    8000017e:	e0ca                	sd	s2,64(sp)
    80000180:	fc4e                	sd	s3,56(sp)
    80000182:	f852                	sd	s4,48(sp)
    80000184:	f05a                	sd	s6,32(sp)
    80000186:	ec5e                	sd	s7,24(sp)
    80000188:	1080                	addi	s0,sp,96
    8000018a:	8b2a                	mv	s6,a0
    8000018c:	8a2e                	mv	s4,a1
    8000018e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000190:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    80000192:	0000f517          	auipc	a0,0xf
    80000196:	6fe50513          	addi	a0,a0,1790 # 8000f890 <cons>
    8000019a:	28f000ef          	jal	80000c28 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	0000f497          	auipc	s1,0xf
    800001a2:	6f248493          	addi	s1,s1,1778 # 8000f890 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	0000f917          	auipc	s2,0xf
    800001aa:	78290913          	addi	s2,s2,1922 # 8000f928 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	776010ef          	jal	80001934 <myproc>
    800001c2:	006020ef          	jal	800021c8 <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	5a9010ef          	jal	80001f74 <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	0000f717          	auipc	a4,0xf
    800001e2:	6b270713          	addi	a4,a4,1714 # 8000f890 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070a9b          	sext.w	s5,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	04da8663          	beq	s5,a3,8000024a <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	855a                	mv	a0,s6
    80000210:	0d8020ef          	jal	800022e8 <either_copyout>
    80000214:	57fd                	li	a5,-1
    80000216:	04f50663          	beq	a0,a5,80000262 <consoleread+0xec>
      break;

    dst++;
    8000021a:	0a05                	addi	s4,s4,1
    --n;
    8000021c:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000021e:	47a9                	li	a5,10
    80000220:	04fa8b63          	beq	s5,a5,80000276 <consoleread+0x100>
    80000224:	7aa2                	ld	s5,40(sp)
    80000226:	b761                	j	800001ae <consoleread+0x38>
        release(&cons.lock);
    80000228:	0000f517          	auipc	a0,0xf
    8000022c:	66850513          	addi	a0,a0,1640 # 8000f890 <cons>
    80000230:	28d000ef          	jal	80000cbc <release>
        return -1;
    80000234:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000236:	60e6                	ld	ra,88(sp)
    80000238:	6446                	ld	s0,80(sp)
    8000023a:	64a6                	ld	s1,72(sp)
    8000023c:	6906                	ld	s2,64(sp)
    8000023e:	79e2                	ld	s3,56(sp)
    80000240:	7a42                	ld	s4,48(sp)
    80000242:	7b02                	ld	s6,32(sp)
    80000244:	6be2                	ld	s7,24(sp)
    80000246:	6125                	addi	sp,sp,96
    80000248:	8082                	ret
      if(n < target){
    8000024a:	0179fa63          	bgeu	s3,s7,8000025e <consoleread+0xe8>
        cons.r--;
    8000024e:	0000f717          	auipc	a4,0xf
    80000252:	6cf72d23          	sw	a5,1754(a4) # 8000f928 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	0000f517          	auipc	a0,0xf
    80000268:	62c50513          	addi	a0,a0,1580 # 8000f890 <cons>
    8000026c:	251000ef          	jal	80000cbc <release>
  return target - n;
    80000270:	413b853b          	subw	a0,s7,s3
    80000274:	b7c9                	j	80000236 <consoleread+0xc0>
    80000276:	7aa2                	ld	s5,40(sp)
    80000278:	b7f5                	j	80000264 <consoleread+0xee>

000000008000027a <consputc>:
{
    8000027a:	1141                	addi	sp,sp,-16
    8000027c:	e406                	sd	ra,8(sp)
    8000027e:	e022                	sd	s0,0(sp)
    80000280:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000282:	10000793          	li	a5,256
    80000286:	00f50863          	beq	a0,a5,80000296 <consputc+0x1c>
    uartputc_sync(c);
    8000028a:	6e4000ef          	jal	8000096e <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	6d6000ef          	jal	8000096e <uartputc_sync>
    8000029c:	02000513          	li	a0,32
    800002a0:	6ce000ef          	jal	8000096e <uartputc_sync>
    800002a4:	4521                	li	a0,8
    800002a6:	6c8000ef          	jal	8000096e <uartputc_sync>
    800002aa:	b7d5                	j	8000028e <consputc+0x14>

00000000800002ac <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ac:	1101                	addi	sp,sp,-32
    800002ae:	ec06                	sd	ra,24(sp)
    800002b0:	e822                	sd	s0,16(sp)
    800002b2:	e426                	sd	s1,8(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	0000f517          	auipc	a0,0xf
    800002bc:	5d850513          	addi	a0,a0,1496 # 8000f890 <cons>
    800002c0:	169000ef          	jal	80000c28 <acquire>

  switch(c){
    800002c4:	47d5                	li	a5,21
    800002c6:	08f48d63          	beq	s1,a5,80000360 <consoleintr+0xb4>
    800002ca:	0297c563          	blt	a5,s1,800002f4 <consoleintr+0x48>
    800002ce:	47a1                	li	a5,8
    800002d0:	0ef48263          	beq	s1,a5,800003b4 <consoleintr+0x108>
    800002d4:	47c1                	li	a5,16
    800002d6:	10f49363          	bne	s1,a5,800003dc <consoleintr+0x130>
  case C('P'):  // Print process list.
    procdump();
    800002da:	0a2020ef          	jal	8000237c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	0000f517          	auipc	a0,0xf
    800002e2:	5b250513          	addi	a0,a0,1458 # 8000f890 <cons>
    800002e6:	1d7000ef          	jal	80000cbc <release>
}
    800002ea:	60e2                	ld	ra,24(sp)
    800002ec:	6442                	ld	s0,16(sp)
    800002ee:	64a2                	ld	s1,8(sp)
    800002f0:	6105                	addi	sp,sp,32
    800002f2:	8082                	ret
  switch(c){
    800002f4:	07f00793          	li	a5,127
    800002f8:	0af48e63          	beq	s1,a5,800003b4 <consoleintr+0x108>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fc:	0000f717          	auipc	a4,0xf
    80000300:	59470713          	addi	a4,a4,1428 # 8000f890 <cons>
    80000304:	0a072783          	lw	a5,160(a4)
    80000308:	09872703          	lw	a4,152(a4)
    8000030c:	9f99                	subw	a5,a5,a4
    8000030e:	07f00713          	li	a4,127
    80000312:	fcf766e3          	bltu	a4,a5,800002de <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000316:	47b5                	li	a5,13
    80000318:	0cf48563          	beq	s1,a5,800003e2 <consoleintr+0x136>
      consputc(c);
    8000031c:	8526                	mv	a0,s1
    8000031e:	f5dff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000322:	0000f717          	auipc	a4,0xf
    80000326:	56e70713          	addi	a4,a4,1390 # 8000f890 <cons>
    8000032a:	0a072683          	lw	a3,160(a4)
    8000032e:	0016879b          	addiw	a5,a3,1
    80000332:	863e                	mv	a2,a5
    80000334:	0af72023          	sw	a5,160(a4)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	9736                	add	a4,a4,a3
    8000033e:	00970c23          	sb	s1,24(a4)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	ff648713          	addi	a4,s1,-10
    80000346:	c371                	beqz	a4,8000040a <consoleintr+0x15e>
    80000348:	14f1                	addi	s1,s1,-4
    8000034a:	c0e1                	beqz	s1,8000040a <consoleintr+0x15e>
    8000034c:	0000f717          	auipc	a4,0xf
    80000350:	5dc72703          	lw	a4,1500(a4) # 8000f928 <cons+0x98>
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	08000713          	li	a4,128
    8000035a:	f8e792e3          	bne	a5,a4,800002de <consoleintr+0x32>
    8000035e:	a075                	j	8000040a <consoleintr+0x15e>
    80000360:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000362:	0000f717          	auipc	a4,0xf
    80000366:	52e70713          	addi	a4,a4,1326 # 8000f890 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000372:	0000f497          	auipc	s1,0xf
    80000376:	51e48493          	addi	s1,s1,1310 # 8000f890 <cons>
    while(cons.e != cons.w &&
    8000037a:	4929                	li	s2,10
    8000037c:	02f70863          	beq	a4,a5,800003ac <consoleintr+0x100>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000380:	37fd                	addiw	a5,a5,-1
    80000382:	07f7f713          	andi	a4,a5,127
    80000386:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000388:	01874703          	lbu	a4,24(a4)
    8000038c:	03270263          	beq	a4,s2,800003b0 <consoleintr+0x104>
      cons.e--;
    80000390:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000394:	10000513          	li	a0,256
    80000398:	ee3ff0ef          	jal	8000027a <consputc>
    while(cons.e != cons.w &&
    8000039c:	0a04a783          	lw	a5,160(s1)
    800003a0:	09c4a703          	lw	a4,156(s1)
    800003a4:	fcf71ee3          	bne	a4,a5,80000380 <consoleintr+0xd4>
    800003a8:	6902                	ld	s2,0(sp)
    800003aa:	bf15                	j	800002de <consoleintr+0x32>
    800003ac:	6902                	ld	s2,0(sp)
    800003ae:	bf05                	j	800002de <consoleintr+0x32>
    800003b0:	6902                	ld	s2,0(sp)
    800003b2:	b735                	j	800002de <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b4:	0000f717          	auipc	a4,0xf
    800003b8:	4dc70713          	addi	a4,a4,1244 # 8000f890 <cons>
    800003bc:	0a072783          	lw	a5,160(a4)
    800003c0:	09c72703          	lw	a4,156(a4)
    800003c4:	f0f70de3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003c8:	37fd                	addiw	a5,a5,-1
    800003ca:	0000f717          	auipc	a4,0xf
    800003ce:	56f72323          	sw	a5,1382(a4) # 8000f930 <cons+0xa0>
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	ea5ff0ef          	jal	8000027a <consputc>
    800003da:	b711                	j	800002de <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003dc:	f00481e3          	beqz	s1,800002de <consoleintr+0x32>
    800003e0:	bf31                	j	800002fc <consoleintr+0x50>
      consputc(c);
    800003e2:	4529                	li	a0,10
    800003e4:	e97ff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003e8:	0000f797          	auipc	a5,0xf
    800003ec:	4a878793          	addi	a5,a5,1192 # 8000f890 <cons>
    800003f0:	0a07a703          	lw	a4,160(a5)
    800003f4:	0017069b          	addiw	a3,a4,1
    800003f8:	8636                	mv	a2,a3
    800003fa:	0ad7a023          	sw	a3,160(a5)
    800003fe:	07f77713          	andi	a4,a4,127
    80000402:	97ba                	add	a5,a5,a4
    80000404:	4729                	li	a4,10
    80000406:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040a:	0000f797          	auipc	a5,0xf
    8000040e:	52c7a123          	sw	a2,1314(a5) # 8000f92c <cons+0x9c>
        wakeup(&cons.r);
    80000412:	0000f517          	auipc	a0,0xf
    80000416:	51650513          	addi	a0,a0,1302 # 8000f928 <cons+0x98>
    8000041a:	3a7010ef          	jal	80001fc0 <wakeup>
    8000041e:	b5c1                	j	800002de <consoleintr+0x32>

0000000080000420 <consoleinit>:

void
consoleinit(void)
{
    80000420:	1141                	addi	sp,sp,-16
    80000422:	e406                	sd	ra,8(sp)
    80000424:	e022                	sd	s0,0(sp)
    80000426:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000428:	00007597          	auipc	a1,0x7
    8000042c:	bd858593          	addi	a1,a1,-1064 # 80007000 <etext>
    80000430:	0000f517          	auipc	a0,0xf
    80000434:	46050513          	addi	a0,a0,1120 # 8000f890 <cons>
    80000438:	766000ef          	jal	80000b9e <initlock>

  uartinit();
    8000043c:	448000ef          	jal	80000884 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	00062797          	auipc	a5,0x62
    80000444:	fc078793          	addi	a5,a5,-64 # 80062400 <devsw>
    80000448:	00000717          	auipc	a4,0x0
    8000044c:	d2e70713          	addi	a4,a4,-722 # 80000176 <consoleread>
    80000450:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000452:	00000717          	auipc	a4,0x0
    80000456:	c8270713          	addi	a4,a4,-894 # 800000d4 <consolewrite>
    8000045a:	ef98                	sd	a4,24(a5)
}
    8000045c:	60a2                	ld	ra,8(sp)
    8000045e:	6402                	ld	s0,0(sp)
    80000460:	0141                	addi	sp,sp,16
    80000462:	8082                	ret

0000000080000464 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000464:	7139                	addi	sp,sp,-64
    80000466:	fc06                	sd	ra,56(sp)
    80000468:	f822                	sd	s0,48(sp)
    8000046a:	f04a                	sd	s2,32(sp)
    8000046c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000046e:	c219                	beqz	a2,80000474 <printint+0x10>
    80000470:	08054163          	bltz	a0,800004f2 <printint+0x8e>
    x = -xx;
  else
    x = xx;
    80000474:	4301                	li	t1,0

  i = 0;
    80000476:	fc840913          	addi	s2,s0,-56
    x = xx;
    8000047a:	86ca                	mv	a3,s2
  i = 0;
    8000047c:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00007817          	auipc	a6,0x7
    80000482:	2a280813          	addi	a6,a6,674 # 80007720 <digits>
    80000486:	88ba                	mv	a7,a4
    80000488:	0017061b          	addiw	a2,a4,1
    8000048c:	8732                	mv	a4,a2
    8000048e:	02b577b3          	remu	a5,a0,a1
    80000492:	97c2                	add	a5,a5,a6
    80000494:	0007c783          	lbu	a5,0(a5)
    80000498:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    8000049c:	87aa                	mv	a5,a0
    8000049e:	02b55533          	divu	a0,a0,a1
    800004a2:	0685                	addi	a3,a3,1
    800004a4:	feb7f1e3          	bgeu	a5,a1,80000486 <printint+0x22>

  if(sign)
    800004a8:	00030c63          	beqz	t1,800004c0 <printint+0x5c>
    buf[i++] = '-';
    800004ac:	fe060793          	addi	a5,a2,-32
    800004b0:	00878633          	add	a2,a5,s0
    800004b4:	02d00793          	li	a5,45
    800004b8:	fef60423          	sb	a5,-24(a2)
    800004bc:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
    800004c0:	02e05463          	blez	a4,800004e8 <printint+0x84>
    800004c4:	f426                	sd	s1,40(sp)
    800004c6:	377d                	addiw	a4,a4,-1
    800004c8:	00e904b3          	add	s1,s2,a4
    800004cc:	197d                	addi	s2,s2,-1
    800004ce:	993a                	add	s2,s2,a4
    800004d0:	1702                	slli	a4,a4,0x20
    800004d2:	9301                	srli	a4,a4,0x20
    800004d4:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    800004d8:	0004c503          	lbu	a0,0(s1)
    800004dc:	d9fff0ef          	jal	8000027a <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x74>
    800004e6:	74a2                	ld	s1,40(sp)
}
    800004e8:	70e2                	ld	ra,56(sp)
    800004ea:	7442                	ld	s0,48(sp)
    800004ec:	7902                	ld	s2,32(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4305                	li	t1,1
    x = -xx;
    800004f8:	bfbd                	j	80000476 <printint+0x12>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	f0ca                	sd	s2,96(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	892a                	mv	s2,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	00007797          	auipc	a5,0x7
    8000051c:	34c7a783          	lw	a5,844(a5) # 80007864 <panicking>
    80000520:	cf9d                	beqz	a5,8000055e <printf+0x64>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	00094503          	lbu	a0,0(s2)
    8000052e:	22050663          	beqz	a0,8000075a <printf+0x260>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	ecce                	sd	s3,88(sp)
    80000536:	e8d2                	sd	s4,80(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	fc5e                	sd	s7,56(sp)
    8000053e:	f862                	sd	s8,48(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4a01                	li	s4,0
    if(cx != '%'){
    80000546:	02500993          	li	s3,37
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000054a:	07500c13          	li	s8,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    8000054e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000552:	07000d93          	li	s11,112
      printint(va_arg(ap, uint64), 10, 0);
    80000556:	4b29                	li	s6,10
    if(c0 == 'd'){
    80000558:	06400b93          	li	s7,100
    8000055c:	a015                	j	80000580 <printf+0x86>
    acquire(&pr.lock);
    8000055e:	0000f517          	auipc	a0,0xf
    80000562:	3da50513          	addi	a0,a0,986 # 8000f938 <pr>
    80000566:	6c2000ef          	jal	80000c28 <acquire>
    8000056a:	bf65                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056c:	d0fff0ef          	jal	8000027a <consputc>
      continue;
    80000570:	84d2                	mv	s1,s4
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000572:	2485                	addiw	s1,s1,1
    80000574:	8a26                	mv	s4,s1
    80000576:	94ca                	add	s1,s1,s2
    80000578:	0004c503          	lbu	a0,0(s1)
    8000057c:	1c050663          	beqz	a0,80000748 <printf+0x24e>
    if(cx != '%'){
    80000580:	ff3516e3          	bne	a0,s3,8000056c <printf+0x72>
    i++;
    80000584:	001a079b          	addiw	a5,s4,1
    80000588:	84be                	mv	s1,a5
    c0 = fmt[i+0] & 0xff;
    8000058a:	00f90733          	add	a4,s2,a5
    8000058e:	00074a83          	lbu	s5,0(a4)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000592:	200a8963          	beqz	s5,800007a4 <printf+0x2aa>
    80000596:	00174683          	lbu	a3,1(a4)
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059a:	1e068c63          	beqz	a3,80000792 <printf+0x298>
    if(c0 == 'd'){
    8000059e:	037a8863          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    800005a2:	f94a8713          	addi	a4,s5,-108
    800005a6:	00173713          	seqz	a4,a4
    800005aa:	f9c68613          	addi	a2,a3,-100
    800005ae:	ee05                	bnez	a2,800005e6 <printf+0xec>
    800005b0:	cb1d                	beqz	a4,800005e6 <printf+0xec>
      printint(va_arg(ap, uint64), 10, 1);
    800005b2:	f8843783          	ld	a5,-120(s0)
    800005b6:	00878713          	addi	a4,a5,8
    800005ba:	f8e43423          	sd	a4,-120(s0)
    800005be:	4605                	li	a2,1
    800005c0:	85da                	mv	a1,s6
    800005c2:	6388                	ld	a0,0(a5)
    800005c4:	ea1ff0ef          	jal	80000464 <printint>
      i += 1;
    800005c8:	002a049b          	addiw	s1,s4,2
    800005cc:	b75d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, int), 10, 1);
    800005ce:	f8843783          	ld	a5,-120(s0)
    800005d2:	00878713          	addi	a4,a5,8
    800005d6:	f8e43423          	sd	a4,-120(s0)
    800005da:	4605                	li	a2,1
    800005dc:	85da                	mv	a1,s6
    800005de:	4388                	lw	a0,0(a5)
    800005e0:	e85ff0ef          	jal	80000464 <printint>
    800005e4:	b779                	j	80000572 <printf+0x78>
    if(c1) c2 = fmt[i+2] & 0xff;
    800005e6:	97ca                	add	a5,a5,s2
    800005e8:	8636                	mv	a2,a3
    800005ea:	0027c683          	lbu	a3,2(a5)
    800005ee:	a2c9                	j	800007b0 <printf+0x2b6>
      printint(va_arg(ap, uint64), 10, 1);
    800005f0:	f8843783          	ld	a5,-120(s0)
    800005f4:	00878713          	addi	a4,a5,8
    800005f8:	f8e43423          	sd	a4,-120(s0)
    800005fc:	4605                	li	a2,1
    800005fe:	45a9                	li	a1,10
    80000600:	6388                	ld	a0,0(a5)
    80000602:	e63ff0ef          	jal	80000464 <printint>
      i += 2;
    80000606:	003a049b          	addiw	s1,s4,3
    8000060a:	b7a5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 10, 0);
    8000060c:	f8843783          	ld	a5,-120(s0)
    80000610:	00878713          	addi	a4,a5,8
    80000614:	f8e43423          	sd	a4,-120(s0)
    80000618:	4601                	li	a2,0
    8000061a:	85da                	mv	a1,s6
    8000061c:	0007e503          	lwu	a0,0(a5)
    80000620:	e45ff0ef          	jal	80000464 <printint>
    80000624:	b7b9                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000626:	f8843783          	ld	a5,-120(s0)
    8000062a:	00878713          	addi	a4,a5,8
    8000062e:	f8e43423          	sd	a4,-120(s0)
    80000632:	4601                	li	a2,0
    80000634:	85da                	mv	a1,s6
    80000636:	6388                	ld	a0,0(a5)
    80000638:	e2dff0ef          	jal	80000464 <printint>
      i += 1;
    8000063c:	002a049b          	addiw	s1,s4,2
    80000640:	bf0d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000642:	f8843783          	ld	a5,-120(s0)
    80000646:	00878713          	addi	a4,a5,8
    8000064a:	f8e43423          	sd	a4,-120(s0)
    8000064e:	4601                	li	a2,0
    80000650:	45a9                	li	a1,10
    80000652:	6388                	ld	a0,0(a5)
    80000654:	e11ff0ef          	jal	80000464 <printint>
      i += 2;
    80000658:	003a049b          	addiw	s1,s4,3
    8000065c:	bf19                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 16, 0);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4601                	li	a2,0
    8000066c:	45c1                	li	a1,16
    8000066e:	0007e503          	lwu	a0,0(a5)
    80000672:	df3ff0ef          	jal	80000464 <printint>
    80000676:	bdf5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	45c1                	li	a1,16
    80000686:	6388                	ld	a0,0(a5)
    80000688:	dddff0ef          	jal	80000464 <printint>
      i += 1;
    8000068c:	002a049b          	addiw	s1,s4,2
    80000690:	b5cd                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000692:	f8843783          	ld	a5,-120(s0)
    80000696:	00878713          	addi	a4,a5,8
    8000069a:	f8e43423          	sd	a4,-120(s0)
    8000069e:	4601                	li	a2,0
    800006a0:	45c1                	li	a1,16
    800006a2:	6388                	ld	a0,0(a5)
    800006a4:	dc1ff0ef          	jal	80000464 <printint>
      i += 2;
    800006a8:	003a049b          	addiw	s1,s4,3
    800006ac:	b5d9                	j	80000572 <printf+0x78>
    800006ae:	f466                	sd	s9,40(sp)
      printptr(va_arg(ap, uint64));
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	0007ba83          	ld	s5,0(a5)
  consputc('0');
    800006c0:	03000513          	li	a0,48
    800006c4:	bb7ff0ef          	jal	8000027a <consputc>
  consputc('x');
    800006c8:	07800513          	li	a0,120
    800006cc:	bafff0ef          	jal	8000027a <consputc>
    800006d0:	4a41                	li	s4,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d2:	00007c97          	auipc	s9,0x7
    800006d6:	04ec8c93          	addi	s9,s9,78 # 80007720 <digits>
    800006da:	03cad793          	srli	a5,s5,0x3c
    800006de:	97e6                	add	a5,a5,s9
    800006e0:	0007c503          	lbu	a0,0(a5)
    800006e4:	b97ff0ef          	jal	8000027a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e8:	0a92                	slli	s5,s5,0x4
    800006ea:	3a7d                	addiw	s4,s4,-1
    800006ec:	fe0a17e3          	bnez	s4,800006da <printf+0x1e0>
    800006f0:	7ca2                	ld	s9,40(sp)
    800006f2:	b541                	j	80000572 <printf+0x78>
    } else if(c0 == 'c'){
      consputc(va_arg(ap, uint));
    800006f4:	f8843783          	ld	a5,-120(s0)
    800006f8:	00878713          	addi	a4,a5,8
    800006fc:	f8e43423          	sd	a4,-120(s0)
    80000700:	4388                	lw	a0,0(a5)
    80000702:	b79ff0ef          	jal	8000027a <consputc>
    80000706:	b5b5                	j	80000572 <printf+0x78>
    } else if(c0 == 's'){
      if((s = va_arg(ap, char*)) == 0)
    80000708:	f8843783          	ld	a5,-120(s0)
    8000070c:	00878713          	addi	a4,a5,8
    80000710:	f8e43423          	sd	a4,-120(s0)
    80000714:	0007ba03          	ld	s4,0(a5)
    80000718:	000a0d63          	beqz	s4,80000732 <printf+0x238>
        s = "(null)";
      for(; *s; s++)
    8000071c:	000a4503          	lbu	a0,0(s4)
    80000720:	e40509e3          	beqz	a0,80000572 <printf+0x78>
        consputc(*s);
    80000724:	b57ff0ef          	jal	8000027a <consputc>
      for(; *s; s++)
    80000728:	0a05                	addi	s4,s4,1
    8000072a:	000a4503          	lbu	a0,0(s4)
    8000072e:	f97d                	bnez	a0,80000724 <printf+0x22a>
    80000730:	b589                	j	80000572 <printf+0x78>
        s = "(null)";
    80000732:	00007a17          	auipc	s4,0x7
    80000736:	8d6a0a13          	addi	s4,s4,-1834 # 80007008 <etext+0x8>
      for(; *s; s++)
    8000073a:	02800513          	li	a0,40
    8000073e:	b7dd                	j	80000724 <printf+0x22a>
    } else if(c0 == '%'){
      consputc('%');
    80000740:	8556                	mv	a0,s5
    80000742:	b39ff0ef          	jal	8000027a <consputc>
    80000746:	b535                	j	80000572 <printf+0x78>
    80000748:	74a6                	ld	s1,104(sp)
    8000074a:	69e6                	ld	s3,88(sp)
    8000074c:	6a46                	ld	s4,80(sp)
    8000074e:	6aa6                	ld	s5,72(sp)
    80000750:	6b06                	ld	s6,64(sp)
    80000752:	7be2                	ld	s7,56(sp)
    80000754:	7c42                	ld	s8,48(sp)
    80000756:	7d02                	ld	s10,32(sp)
    80000758:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    8000075a:	00007797          	auipc	a5,0x7
    8000075e:	10a7a783          	lw	a5,266(a5) # 80007864 <panicking>
    80000762:	c38d                	beqz	a5,80000784 <printf+0x28a>
    release(&pr.lock);

  return 0;
}
    80000764:	4501                	li	a0,0
    80000766:	70e6                	ld	ra,120(sp)
    80000768:	7446                	ld	s0,112(sp)
    8000076a:	7906                	ld	s2,96(sp)
    8000076c:	6129                	addi	sp,sp,192
    8000076e:	8082                	ret
    80000770:	74a6                	ld	s1,104(sp)
    80000772:	69e6                	ld	s3,88(sp)
    80000774:	6a46                	ld	s4,80(sp)
    80000776:	6aa6                	ld	s5,72(sp)
    80000778:	6b06                	ld	s6,64(sp)
    8000077a:	7be2                	ld	s7,56(sp)
    8000077c:	7c42                	ld	s8,48(sp)
    8000077e:	7d02                	ld	s10,32(sp)
    80000780:	6de2                	ld	s11,24(sp)
    80000782:	bfe1                	j	8000075a <printf+0x260>
    release(&pr.lock);
    80000784:	0000f517          	auipc	a0,0xf
    80000788:	1b450513          	addi	a0,a0,436 # 8000f938 <pr>
    8000078c:	530000ef          	jal	80000cbc <release>
  return 0;
    80000790:	bfd1                	j	80000764 <printf+0x26a>
    if(c0 == 'd'){
    80000792:	e37a8ee3          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    80000796:	f94a8713          	addi	a4,s5,-108
    8000079a:	00173713          	seqz	a4,a4
    8000079e:	8636                	mv	a2,a3
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007a0:	4781                	li	a5,0
    800007a2:	a00d                	j	800007c4 <printf+0x2ca>
    } else if(c0 == 'l' && c1 == 'd'){
    800007a4:	f94a8713          	addi	a4,s5,-108
    800007a8:	00173713          	seqz	a4,a4
    c1 = c2 = 0;
    800007ac:	8656                	mv	a2,s5
    800007ae:	86d6                	mv	a3,s5
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007b0:	f9460793          	addi	a5,a2,-108
    800007b4:	0017b793          	seqz	a5,a5
    800007b8:	8ff9                	and	a5,a5,a4
    800007ba:	f9c68593          	addi	a1,a3,-100
    800007be:	e199                	bnez	a1,800007c4 <printf+0x2ca>
    800007c0:	e20798e3          	bnez	a5,800005f0 <printf+0xf6>
    } else if(c0 == 'u'){
    800007c4:	e58a84e3          	beq	s5,s8,8000060c <printf+0x112>
    } else if(c0 == 'l' && c1 == 'u'){
    800007c8:	f8b60593          	addi	a1,a2,-117
    800007cc:	e199                	bnez	a1,800007d2 <printf+0x2d8>
    800007ce:	e4071ce3          	bnez	a4,80000626 <printf+0x12c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800007d2:	f8b68593          	addi	a1,a3,-117
    800007d6:	e199                	bnez	a1,800007dc <printf+0x2e2>
    800007d8:	e60795e3          	bnez	a5,80000642 <printf+0x148>
    } else if(c0 == 'x'){
    800007dc:	e9aa81e3          	beq	s5,s10,8000065e <printf+0x164>
    } else if(c0 == 'l' && c1 == 'x'){
    800007e0:	f8860613          	addi	a2,a2,-120
    800007e4:	e219                	bnez	a2,800007ea <printf+0x2f0>
    800007e6:	e80719e3          	bnez	a4,80000678 <printf+0x17e>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800007ea:	f8868693          	addi	a3,a3,-120
    800007ee:	e299                	bnez	a3,800007f4 <printf+0x2fa>
    800007f0:	ea0791e3          	bnez	a5,80000692 <printf+0x198>
    } else if(c0 == 'p'){
    800007f4:	ebba8de3          	beq	s5,s11,800006ae <printf+0x1b4>
    } else if(c0 == 'c'){
    800007f8:	06300793          	li	a5,99
    800007fc:	eefa8ce3          	beq	s5,a5,800006f4 <printf+0x1fa>
    } else if(c0 == 's'){
    80000800:	07300793          	li	a5,115
    80000804:	f0fa82e3          	beq	s5,a5,80000708 <printf+0x20e>
    } else if(c0 == '%'){
    80000808:	02500793          	li	a5,37
    8000080c:	f2fa8ae3          	beq	s5,a5,80000740 <printf+0x246>
    } else if(c0 == 0){
    80000810:	f60a80e3          	beqz	s5,80000770 <printf+0x276>
      consputc('%');
    80000814:	02500513          	li	a0,37
    80000818:	a63ff0ef          	jal	8000027a <consputc>
      consputc(c0);
    8000081c:	8556                	mv	a0,s5
    8000081e:	a5dff0ef          	jal	8000027a <consputc>
    80000822:	bb81                	j	80000572 <printf+0x78>

0000000080000824 <panic>:

void
panic(char *s)
{
    80000824:	1101                	addi	sp,sp,-32
    80000826:	ec06                	sd	ra,24(sp)
    80000828:	e822                	sd	s0,16(sp)
    8000082a:	e426                	sd	s1,8(sp)
    8000082c:	e04a                	sd	s2,0(sp)
    8000082e:	1000                	addi	s0,sp,32
    80000830:	892a                	mv	s2,a0
  panicking = 1;
    80000832:	4485                	li	s1,1
    80000834:	00007797          	auipc	a5,0x7
    80000838:	0297a823          	sw	s1,48(a5) # 80007864 <panicking>
  printf("panic: ");
    8000083c:	00006517          	auipc	a0,0x6
    80000840:	7dc50513          	addi	a0,a0,2012 # 80007018 <etext+0x18>
    80000844:	cb7ff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000848:	85ca                	mv	a1,s2
    8000084a:	00006517          	auipc	a0,0x6
    8000084e:	7d650513          	addi	a0,a0,2006 # 80007020 <etext+0x20>
    80000852:	ca9ff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000856:	00007797          	auipc	a5,0x7
    8000085a:	0097a523          	sw	s1,10(a5) # 80007860 <panicked>
  for(;;)
    8000085e:	a001                	j	8000085e <panic+0x3a>

0000000080000860 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000860:	1141                	addi	sp,sp,-16
    80000862:	e406                	sd	ra,8(sp)
    80000864:	e022                	sd	s0,0(sp)
    80000866:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000868:	00006597          	auipc	a1,0x6
    8000086c:	7c058593          	addi	a1,a1,1984 # 80007028 <etext+0x28>
    80000870:	0000f517          	auipc	a0,0xf
    80000874:	0c850513          	addi	a0,a0,200 # 8000f938 <pr>
    80000878:	326000ef          	jal	80000b9e <initlock>
}
    8000087c:	60a2                	ld	ra,8(sp)
    8000087e:	6402                	ld	s0,0(sp)
    80000880:	0141                	addi	sp,sp,16
    80000882:	8082                	ret

0000000080000884 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000884:	1141                	addi	sp,sp,-16
    80000886:	e406                	sd	ra,8(sp)
    80000888:	e022                	sd	s0,0(sp)
    8000088a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000088c:	100007b7          	lui	a5,0x10000
    80000890:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000894:	10000737          	lui	a4,0x10000
    80000898:	f8000693          	li	a3,-128
    8000089c:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008a0:	468d                	li	a3,3
    800008a2:	10000637          	lui	a2,0x10000
    800008a6:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008aa:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800008ae:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008b2:	8732                	mv	a4,a2
    800008b4:	461d                	li	a2,7
    800008b6:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008ba:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    800008be:	00006597          	auipc	a1,0x6
    800008c2:	77258593          	addi	a1,a1,1906 # 80007030 <etext+0x30>
    800008c6:	0000f517          	auipc	a0,0xf
    800008ca:	08a50513          	addi	a0,a0,138 # 8000f950 <tx_lock>
    800008ce:	2d0000ef          	jal	80000b9e <initlock>
}
    800008d2:	60a2                	ld	ra,8(sp)
    800008d4:	6402                	ld	s0,0(sp)
    800008d6:	0141                	addi	sp,sp,16
    800008d8:	8082                	ret

00000000800008da <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008da:	715d                	addi	sp,sp,-80
    800008dc:	e486                	sd	ra,72(sp)
    800008de:	e0a2                	sd	s0,64(sp)
    800008e0:	fc26                	sd	s1,56(sp)
    800008e2:	ec56                	sd	s5,24(sp)
    800008e4:	0880                	addi	s0,sp,80
    800008e6:	8aaa                	mv	s5,a0
    800008e8:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008ea:	0000f517          	auipc	a0,0xf
    800008ee:	06650513          	addi	a0,a0,102 # 8000f950 <tx_lock>
    800008f2:	336000ef          	jal	80000c28 <acquire>

  int i = 0;
  while(i < n){ 
    800008f6:	06905063          	blez	s1,80000956 <uartwrite+0x7c>
    800008fa:	f84a                	sd	s2,48(sp)
    800008fc:	f44e                	sd	s3,40(sp)
    800008fe:	f052                	sd	s4,32(sp)
    80000900:	e85a                	sd	s6,16(sp)
    80000902:	e45e                	sd	s7,8(sp)
    80000904:	8a56                	mv	s4,s5
    80000906:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    80000908:	00007497          	auipc	s1,0x7
    8000090c:	f6448493          	addi	s1,s1,-156 # 8000786c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000910:	0000f997          	auipc	s3,0xf
    80000914:	04098993          	addi	s3,s3,64 # 8000f950 <tx_lock>
    80000918:	00007917          	auipc	s2,0x7
    8000091c:	f5090913          	addi	s2,s2,-176 # 80007868 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000920:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80000924:	4b05                	li	s6,1
    80000926:	a005                	j	80000946 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    80000928:	85ce                	mv	a1,s3
    8000092a:	854a                	mv	a0,s2
    8000092c:	648010ef          	jal	80001f74 <sleep>
    while(tx_busy != 0){
    80000930:	409c                	lw	a5,0(s1)
    80000932:	fbfd                	bnez	a5,80000928 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80000934:	000a4783          	lbu	a5,0(s4)
    80000938:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    8000093c:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    80000940:	0a05                	addi	s4,s4,1
    80000942:	015a0563          	beq	s4,s5,8000094c <uartwrite+0x72>
    while(tx_busy != 0){
    80000946:	409c                	lw	a5,0(s1)
    80000948:	f3e5                	bnez	a5,80000928 <uartwrite+0x4e>
    8000094a:	b7ed                	j	80000934 <uartwrite+0x5a>
    8000094c:	7942                	ld	s2,48(sp)
    8000094e:	79a2                	ld	s3,40(sp)
    80000950:	7a02                	ld	s4,32(sp)
    80000952:	6b42                	ld	s6,16(sp)
    80000954:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000956:	0000f517          	auipc	a0,0xf
    8000095a:	ffa50513          	addi	a0,a0,-6 # 8000f950 <tx_lock>
    8000095e:	35e000ef          	jal	80000cbc <release>
}
    80000962:	60a6                	ld	ra,72(sp)
    80000964:	6406                	ld	s0,64(sp)
    80000966:	74e2                	ld	s1,56(sp)
    80000968:	6ae2                	ld	s5,24(sp)
    8000096a:	6161                	addi	sp,sp,80
    8000096c:	8082                	ret

000000008000096e <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000096e:	1101                	addi	sp,sp,-32
    80000970:	ec06                	sd	ra,24(sp)
    80000972:	e822                	sd	s0,16(sp)
    80000974:	e426                	sd	s1,8(sp)
    80000976:	1000                	addi	s0,sp,32
    80000978:	84aa                	mv	s1,a0
  if(panicking == 0)
    8000097a:	00007797          	auipc	a5,0x7
    8000097e:	eea7a783          	lw	a5,-278(a5) # 80007864 <panicking>
    80000982:	cf95                	beqz	a5,800009be <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000984:	00007797          	auipc	a5,0x7
    80000988:	edc7a783          	lw	a5,-292(a5) # 80007860 <panicked>
    8000098c:	ef85                	bnez	a5,800009c4 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000098e:	10000737          	lui	a4,0x10000
    80000992:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000994:	00074783          	lbu	a5,0(a4)
    80000998:	0207f793          	andi	a5,a5,32
    8000099c:	dfe5                	beqz	a5,80000994 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000099e:	0ff4f513          	zext.b	a0,s1
    800009a2:	100007b7          	lui	a5,0x10000
    800009a6:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    800009aa:	00007797          	auipc	a5,0x7
    800009ae:	eba7a783          	lw	a5,-326(a5) # 80007864 <panicking>
    800009b2:	cb91                	beqz	a5,800009c6 <uartputc_sync+0x58>
    pop_off();
}
    800009b4:	60e2                	ld	ra,24(sp)
    800009b6:	6442                	ld	s0,16(sp)
    800009b8:	64a2                	ld	s1,8(sp)
    800009ba:	6105                	addi	sp,sp,32
    800009bc:	8082                	ret
    push_off();
    800009be:	226000ef          	jal	80000be4 <push_off>
    800009c2:	b7c9                	j	80000984 <uartputc_sync+0x16>
    for(;;)
    800009c4:	a001                	j	800009c4 <uartputc_sync+0x56>
    pop_off();
    800009c6:	2a6000ef          	jal	80000c6c <pop_off>
}
    800009ca:	b7ed                	j	800009b4 <uartputc_sync+0x46>

00000000800009cc <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009cc:	1141                	addi	sp,sp,-16
    800009ce:	e406                	sd	ra,8(sp)
    800009d0:	e022                	sd	s0,0(sp)
    800009d2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    800009d4:	100007b7          	lui	a5,0x10000
    800009d8:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009dc:	8b85                	andi	a5,a5,1
    800009de:	cb89                	beqz	a5,800009f0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009e0:	100007b7          	lui	a5,0x10000
    800009e4:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009e8:	60a2                	ld	ra,8(sp)
    800009ea:	6402                	ld	s0,0(sp)
    800009ec:	0141                	addi	sp,sp,16
    800009ee:	8082                	ret
    return -1;
    800009f0:	557d                	li	a0,-1
    800009f2:	bfdd                	j	800009e8 <uartgetc+0x1c>

00000000800009f4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009f4:	1101                	addi	sp,sp,-32
    800009f6:	ec06                	sd	ra,24(sp)
    800009f8:	e822                	sd	s0,16(sp)
    800009fa:	e426                	sd	s1,8(sp)
    800009fc:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009fe:	100007b7          	lui	a5,0x10000
    80000a02:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    80000a06:	0000f517          	auipc	a0,0xf
    80000a0a:	f4a50513          	addi	a0,a0,-182 # 8000f950 <tx_lock>
    80000a0e:	21a000ef          	jal	80000c28 <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000a12:	100007b7          	lui	a5,0x10000
    80000a16:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a1a:	0207f793          	andi	a5,a5,32
    80000a1e:	ef99                	bnez	a5,80000a3c <uartintr+0x48>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000a20:	0000f517          	auipc	a0,0xf
    80000a24:	f3050513          	addi	a0,a0,-208 # 8000f950 <tx_lock>
    80000a28:	294000ef          	jal	80000cbc <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a2c:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a2e:	f9fff0ef          	jal	800009cc <uartgetc>
    if(c == -1)
    80000a32:	02950063          	beq	a0,s1,80000a52 <uartintr+0x5e>
      break;
    consoleintr(c);
    80000a36:	877ff0ef          	jal	800002ac <consoleintr>
  while(1){
    80000a3a:	bfd5                	j	80000a2e <uartintr+0x3a>
    tx_busy = 0;
    80000a3c:	00007797          	auipc	a5,0x7
    80000a40:	e207a823          	sw	zero,-464(a5) # 8000786c <tx_busy>
    wakeup(&tx_chan);
    80000a44:	00007517          	auipc	a0,0x7
    80000a48:	e2450513          	addi	a0,a0,-476 # 80007868 <tx_chan>
    80000a4c:	574010ef          	jal	80001fc0 <wakeup>
    80000a50:	bfc1                	j	80000a20 <uartintr+0x2c>
  }
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret

0000000080000a5c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a5c:	1101                	addi	sp,sp,-32
    80000a5e:	ec06                	sd	ra,24(sp)
    80000a60:	e822                	sd	s0,16(sp)
    80000a62:	e426                	sd	s1,8(sp)
    80000a64:	e04a                	sd	s2,0(sp)
    80000a66:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a68:	00063797          	auipc	a5,0x63
    80000a6c:	b3078793          	addi	a5,a5,-1232 # 80063598 <end>
    80000a70:	00f53733          	sltu	a4,a0,a5
    80000a74:	47c5                	li	a5,17
    80000a76:	07ee                	slli	a5,a5,0x1b
    80000a78:	17fd                	addi	a5,a5,-1
    80000a7a:	00a7b7b3          	sltu	a5,a5,a0
    80000a7e:	8fd9                	or	a5,a5,a4
    80000a80:	ef95                	bnez	a5,80000abc <kfree+0x60>
    80000a82:	84aa                	mv	s1,a0
    80000a84:	03451793          	slli	a5,a0,0x34
    80000a88:	eb95                	bnez	a5,80000abc <kfree+0x60>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a8a:	6605                	lui	a2,0x1
    80000a8c:	4585                	li	a1,1
    80000a8e:	26a000ef          	jal	80000cf8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a92:	0000f917          	auipc	s2,0xf
    80000a96:	ed690913          	addi	s2,s2,-298 # 8000f968 <kmem>
    80000a9a:	854a                	mv	a0,s2
    80000a9c:	18c000ef          	jal	80000c28 <acquire>
  r->next = kmem.freelist;
    80000aa0:	01893783          	ld	a5,24(s2)
    80000aa4:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aa6:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000aaa:	854a                	mv	a0,s2
    80000aac:	210000ef          	jal	80000cbc <release>
}
    80000ab0:	60e2                	ld	ra,24(sp)
    80000ab2:	6442                	ld	s0,16(sp)
    80000ab4:	64a2                	ld	s1,8(sp)
    80000ab6:	6902                	ld	s2,0(sp)
    80000ab8:	6105                	addi	sp,sp,32
    80000aba:	8082                	ret
    panic("kfree");
    80000abc:	00006517          	auipc	a0,0x6
    80000ac0:	57c50513          	addi	a0,a0,1404 # 80007038 <etext+0x38>
    80000ac4:	d61ff0ef          	jal	80000824 <panic>

0000000080000ac8 <freerange>:
{
    80000ac8:	7179                	addi	sp,sp,-48
    80000aca:	f406                	sd	ra,40(sp)
    80000acc:	f022                	sd	s0,32(sp)
    80000ace:	ec26                	sd	s1,24(sp)
    80000ad0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ad2:	6785                	lui	a5,0x1
    80000ad4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad8:	00e504b3          	add	s1,a0,a4
    80000adc:	777d                	lui	a4,0xfffff
    80000ade:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae0:	94be                	add	s1,s1,a5
    80000ae2:	0295e263          	bltu	a1,s1,80000b06 <freerange+0x3e>
    80000ae6:	e84a                	sd	s2,16(sp)
    80000ae8:	e44e                	sd	s3,8(sp)
    80000aea:	e052                	sd	s4,0(sp)
    80000aec:	892e                	mv	s2,a1
    kfree(p);
    80000aee:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af0:	89be                	mv	s3,a5
    kfree(p);
    80000af2:	01448533          	add	a0,s1,s4
    80000af6:	f67ff0ef          	jal	80000a5c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000afa:	94ce                	add	s1,s1,s3
    80000afc:	fe997be3          	bgeu	s2,s1,80000af2 <freerange+0x2a>
    80000b00:	6942                	ld	s2,16(sp)
    80000b02:	69a2                	ld	s3,8(sp)
    80000b04:	6a02                	ld	s4,0(sp)
}
    80000b06:	70a2                	ld	ra,40(sp)
    80000b08:	7402                	ld	s0,32(sp)
    80000b0a:	64e2                	ld	s1,24(sp)
    80000b0c:	6145                	addi	sp,sp,48
    80000b0e:	8082                	ret

0000000080000b10 <kinit>:
{
    80000b10:	1141                	addi	sp,sp,-16
    80000b12:	e406                	sd	ra,8(sp)
    80000b14:	e022                	sd	s0,0(sp)
    80000b16:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b18:	00006597          	auipc	a1,0x6
    80000b1c:	52858593          	addi	a1,a1,1320 # 80007040 <etext+0x40>
    80000b20:	0000f517          	auipc	a0,0xf
    80000b24:	e4850513          	addi	a0,a0,-440 # 8000f968 <kmem>
    80000b28:	076000ef          	jal	80000b9e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00063517          	auipc	a0,0x63
    80000b34:	a6850513          	addi	a0,a0,-1432 # 80063598 <end>
    80000b38:	f91ff0ef          	jal	80000ac8 <freerange>
}
    80000b3c:	60a2                	ld	ra,8(sp)
    80000b3e:	6402                	ld	s0,0(sp)
    80000b40:	0141                	addi	sp,sp,16
    80000b42:	8082                	ret

0000000080000b44 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b44:	1101                	addi	sp,sp,-32
    80000b46:	ec06                	sd	ra,24(sp)
    80000b48:	e822                	sd	s0,16(sp)
    80000b4a:	e426                	sd	s1,8(sp)
    80000b4c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b4e:	0000f517          	auipc	a0,0xf
    80000b52:	e1a50513          	addi	a0,a0,-486 # 8000f968 <kmem>
    80000b56:	0d2000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b5a:	0000f497          	auipc	s1,0xf
    80000b5e:	e264b483          	ld	s1,-474(s1) # 8000f980 <kmem+0x18>
  if(r)
    80000b62:	c49d                	beqz	s1,80000b90 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b64:	609c                	ld	a5,0(s1)
    80000b66:	0000f717          	auipc	a4,0xf
    80000b6a:	e0f73d23          	sd	a5,-486(a4) # 8000f980 <kmem+0x18>
  release(&kmem.lock);
    80000b6e:	0000f517          	auipc	a0,0xf
    80000b72:	dfa50513          	addi	a0,a0,-518 # 8000f968 <kmem>
    80000b76:	146000ef          	jal	80000cbc <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7a:	6605                	lui	a2,0x1
    80000b7c:	4595                	li	a1,5
    80000b7e:	8526                	mv	a0,s1
    80000b80:	178000ef          	jal	80000cf8 <memset>
  return (void*)r;
}
    80000b84:	8526                	mv	a0,s1
    80000b86:	60e2                	ld	ra,24(sp)
    80000b88:	6442                	ld	s0,16(sp)
    80000b8a:	64a2                	ld	s1,8(sp)
    80000b8c:	6105                	addi	sp,sp,32
    80000b8e:	8082                	ret
  release(&kmem.lock);
    80000b90:	0000f517          	auipc	a0,0xf
    80000b94:	dd850513          	addi	a0,a0,-552 # 8000f968 <kmem>
    80000b98:	124000ef          	jal	80000cbc <release>
  if(r)
    80000b9c:	b7e5                	j	80000b84 <kalloc+0x40>

0000000080000b9e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b9e:	1141                	addi	sp,sp,-16
    80000ba0:	e406                	sd	ra,8(sp)
    80000ba2:	e022                	sd	s0,0(sp)
    80000ba4:	0800                	addi	s0,sp,16
  lk->name = name;
    80000ba6:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000ba8:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bac:	00053823          	sd	zero,16(a0)
}
    80000bb0:	60a2                	ld	ra,8(sp)
    80000bb2:	6402                	ld	s0,0(sp)
    80000bb4:	0141                	addi	sp,sp,16
    80000bb6:	8082                	ret

0000000080000bb8 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bb8:	411c                	lw	a5,0(a0)
    80000bba:	e399                	bnez	a5,80000bc0 <holding+0x8>
    80000bbc:	4501                	li	a0,0
  return r;
}
    80000bbe:	8082                	ret
{
    80000bc0:	1101                	addi	sp,sp,-32
    80000bc2:	ec06                	sd	ra,24(sp)
    80000bc4:	e822                	sd	s0,16(sp)
    80000bc6:	e426                	sd	s1,8(sp)
    80000bc8:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bca:	691c                	ld	a5,16(a0)
    80000bcc:	84be                	mv	s1,a5
    80000bce:	547000ef          	jal	80001914 <mycpu>
    80000bd2:	40a48533          	sub	a0,s1,a0
    80000bd6:	00153513          	seqz	a0,a0
}
    80000bda:	60e2                	ld	ra,24(sp)
    80000bdc:	6442                	ld	s0,16(sp)
    80000bde:	64a2                	ld	s1,8(sp)
    80000be0:	6105                	addi	sp,sp,32
    80000be2:	8082                	ret

0000000080000be4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000be4:	1101                	addi	sp,sp,-32
    80000be6:	ec06                	sd	ra,24(sp)
    80000be8:	e822                	sd	s0,16(sp)
    80000bea:	e426                	sd	s1,8(sp)
    80000bec:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bee:	100027f3          	csrr	a5,sstatus
    80000bf2:	84be                	mv	s1,a5
    80000bf4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bf8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bfa:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000bfe:	517000ef          	jal	80001914 <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	50f000ef          	jal	80001914 <mycpu>
    80000c0a:	5d3c                	lw	a5,120(a0)
    80000c0c:	2785                	addiw	a5,a5,1
    80000c0e:	dd3c                	sw	a5,120(a0)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    mycpu()->intena = old;
    80000c1a:	4fb000ef          	jal	80001914 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c1e:	0014d793          	srli	a5,s1,0x1
    80000c22:	8b85                	andi	a5,a5,1
    80000c24:	dd7c                	sw	a5,124(a0)
    80000c26:	b7c5                	j	80000c06 <push_off+0x22>

0000000080000c28 <acquire>:
{
    80000c28:	1101                	addi	sp,sp,-32
    80000c2a:	ec06                	sd	ra,24(sp)
    80000c2c:	e822                	sd	s0,16(sp)
    80000c2e:	e426                	sd	s1,8(sp)
    80000c30:	1000                	addi	s0,sp,32
    80000c32:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c34:	fb1ff0ef          	jal	80000be4 <push_off>
  if(holding(lk))
    80000c38:	8526                	mv	a0,s1
    80000c3a:	f7fff0ef          	jal	80000bb8 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c3e:	4705                	li	a4,1
  if(holding(lk))
    80000c40:	e105                	bnez	a0,80000c60 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c42:	87ba                	mv	a5,a4
    80000c44:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c48:	2781                	sext.w	a5,a5
    80000c4a:	ffe5                	bnez	a5,80000c42 <acquire+0x1a>
  __sync_synchronize();
    80000c4c:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c50:	4c5000ef          	jal	80001914 <mycpu>
    80000c54:	e888                	sd	a0,16(s1)
}
    80000c56:	60e2                	ld	ra,24(sp)
    80000c58:	6442                	ld	s0,16(sp)
    80000c5a:	64a2                	ld	s1,8(sp)
    80000c5c:	6105                	addi	sp,sp,32
    80000c5e:	8082                	ret
    panic("acquire");
    80000c60:	00006517          	auipc	a0,0x6
    80000c64:	3e850513          	addi	a0,a0,1000 # 80007048 <etext+0x48>
    80000c68:	bbdff0ef          	jal	80000824 <panic>

0000000080000c6c <pop_off>:

void
pop_off(void)
{
    80000c6c:	1141                	addi	sp,sp,-16
    80000c6e:	e406                	sd	ra,8(sp)
    80000c70:	e022                	sd	s0,0(sp)
    80000c72:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c74:	4a1000ef          	jal	80001914 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c78:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c7c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c7e:	e39d                	bnez	a5,80000ca4 <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c80:	5d3c                	lw	a5,120(a0)
    80000c82:	02f05763          	blez	a5,80000cb0 <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000c86:	37fd                	addiw	a5,a5,-1
    80000c88:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c8a:	eb89                	bnez	a5,80000c9c <pop_off+0x30>
    80000c8c:	5d7c                	lw	a5,124(a0)
    80000c8e:	c799                	beqz	a5,80000c9c <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c90:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c94:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c98:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c9c:	60a2                	ld	ra,8(sp)
    80000c9e:	6402                	ld	s0,0(sp)
    80000ca0:	0141                	addi	sp,sp,16
    80000ca2:	8082                	ret
    panic("pop_off - interruptible");
    80000ca4:	00006517          	auipc	a0,0x6
    80000ca8:	3ac50513          	addi	a0,a0,940 # 80007050 <etext+0x50>
    80000cac:	b79ff0ef          	jal	80000824 <panic>
    panic("pop_off");
    80000cb0:	00006517          	auipc	a0,0x6
    80000cb4:	3b850513          	addi	a0,a0,952 # 80007068 <etext+0x68>
    80000cb8:	b6dff0ef          	jal	80000824 <panic>

0000000080000cbc <release>:
{
    80000cbc:	1101                	addi	sp,sp,-32
    80000cbe:	ec06                	sd	ra,24(sp)
    80000cc0:	e822                	sd	s0,16(sp)
    80000cc2:	e426                	sd	s1,8(sp)
    80000cc4:	1000                	addi	s0,sp,32
    80000cc6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cc8:	ef1ff0ef          	jal	80000bb8 <holding>
    80000ccc:	c105                	beqz	a0,80000cec <release+0x30>
  lk->cpu = 0;
    80000cce:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cd2:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000cd6:	0310000f          	fence	rw,w
    80000cda:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cde:	f8fff0ef          	jal	80000c6c <pop_off>
}
    80000ce2:	60e2                	ld	ra,24(sp)
    80000ce4:	6442                	ld	s0,16(sp)
    80000ce6:	64a2                	ld	s1,8(sp)
    80000ce8:	6105                	addi	sp,sp,32
    80000cea:	8082                	ret
    panic("release");
    80000cec:	00006517          	auipc	a0,0x6
    80000cf0:	38450513          	addi	a0,a0,900 # 80007070 <etext+0x70>
    80000cf4:	b31ff0ef          	jal	80000824 <panic>

0000000080000cf8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cf8:	1141                	addi	sp,sp,-16
    80000cfa:	e406                	sd	ra,8(sp)
    80000cfc:	e022                	sd	s0,0(sp)
    80000cfe:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d00:	ca19                	beqz	a2,80000d16 <memset+0x1e>
    80000d02:	87aa                	mv	a5,a0
    80000d04:	1602                	slli	a2,a2,0x20
    80000d06:	9201                	srli	a2,a2,0x20
    80000d08:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d0c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d10:	0785                	addi	a5,a5,1
    80000d12:	fee79de3          	bne	a5,a4,80000d0c <memset+0x14>
  }
  return dst;
}
    80000d16:	60a2                	ld	ra,8(sp)
    80000d18:	6402                	ld	s0,0(sp)
    80000d1a:	0141                	addi	sp,sp,16
    80000d1c:	8082                	ret

0000000080000d1e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d1e:	1141                	addi	sp,sp,-16
    80000d20:	e406                	sd	ra,8(sp)
    80000d22:	e022                	sd	s0,0(sp)
    80000d24:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d26:	c61d                	beqz	a2,80000d54 <memcmp+0x36>
    80000d28:	1602                	slli	a2,a2,0x20
    80000d2a:	9201                	srli	a2,a2,0x20
    80000d2c:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000d30:	00054783          	lbu	a5,0(a0)
    80000d34:	0005c703          	lbu	a4,0(a1)
    80000d38:	00e79863          	bne	a5,a4,80000d48 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d3c:	0505                	addi	a0,a0,1
    80000d3e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d40:	fed518e3          	bne	a0,a3,80000d30 <memcmp+0x12>
  }

  return 0;
    80000d44:	4501                	li	a0,0
    80000d46:	a019                	j	80000d4c <memcmp+0x2e>
      return *s1 - *s2;
    80000d48:	40e7853b          	subw	a0,a5,a4
}
    80000d4c:	60a2                	ld	ra,8(sp)
    80000d4e:	6402                	ld	s0,0(sp)
    80000d50:	0141                	addi	sp,sp,16
    80000d52:	8082                	ret
  return 0;
    80000d54:	4501                	li	a0,0
    80000d56:	bfdd                	j	80000d4c <memcmp+0x2e>

0000000080000d58 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d58:	1141                	addi	sp,sp,-16
    80000d5a:	e406                	sd	ra,8(sp)
    80000d5c:	e022                	sd	s0,0(sp)
    80000d5e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d60:	c205                	beqz	a2,80000d80 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d62:	02a5e363          	bltu	a1,a0,80000d88 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d66:	1602                	slli	a2,a2,0x20
    80000d68:	9201                	srli	a2,a2,0x20
    80000d6a:	00c587b3          	add	a5,a1,a2
{
    80000d6e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d70:	0585                	addi	a1,a1,1
    80000d72:	0705                	addi	a4,a4,1
    80000d74:	fff5c683          	lbu	a3,-1(a1)
    80000d78:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d7c:	feb79ae3          	bne	a5,a1,80000d70 <memmove+0x18>

  return dst;
}
    80000d80:	60a2                	ld	ra,8(sp)
    80000d82:	6402                	ld	s0,0(sp)
    80000d84:	0141                	addi	sp,sp,16
    80000d86:	8082                	ret
  if(s < d && s + n > d){
    80000d88:	02061693          	slli	a3,a2,0x20
    80000d8c:	9281                	srli	a3,a3,0x20
    80000d8e:	00d58733          	add	a4,a1,a3
    80000d92:	fce57ae3          	bgeu	a0,a4,80000d66 <memmove+0xe>
    d += n;
    80000d96:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d98:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000d9c:	1782                	slli	a5,a5,0x20
    80000d9e:	9381                	srli	a5,a5,0x20
    80000da0:	fff7c793          	not	a5,a5
    80000da4:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000da6:	177d                	addi	a4,a4,-1
    80000da8:	16fd                	addi	a3,a3,-1
    80000daa:	00074603          	lbu	a2,0(a4)
    80000dae:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000db2:	fee79ae3          	bne	a5,a4,80000da6 <memmove+0x4e>
    80000db6:	b7e9                	j	80000d80 <memmove+0x28>

0000000080000db8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e406                	sd	ra,8(sp)
    80000dbc:	e022                	sd	s0,0(sp)
    80000dbe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dc0:	f99ff0ef          	jal	80000d58 <memmove>
}
    80000dc4:	60a2                	ld	ra,8(sp)
    80000dc6:	6402                	ld	s0,0(sp)
    80000dc8:	0141                	addi	sp,sp,16
    80000dca:	8082                	ret

0000000080000dcc <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dcc:	1141                	addi	sp,sp,-16
    80000dce:	e406                	sd	ra,8(sp)
    80000dd0:	e022                	sd	s0,0(sp)
    80000dd2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dd4:	ce11                	beqz	a2,80000df0 <strncmp+0x24>
    80000dd6:	00054783          	lbu	a5,0(a0)
    80000dda:	cf89                	beqz	a5,80000df4 <strncmp+0x28>
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	00f71a63          	bne	a4,a5,80000df4 <strncmp+0x28>
    n--, p++, q++;
    80000de4:	367d                	addiw	a2,a2,-1
    80000de6:	0505                	addi	a0,a0,1
    80000de8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dea:	f675                	bnez	a2,80000dd6 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000dec:	4501                	li	a0,0
    80000dee:	a801                	j	80000dfe <strncmp+0x32>
    80000df0:	4501                	li	a0,0
    80000df2:	a031                	j	80000dfe <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000df4:	00054503          	lbu	a0,0(a0)
    80000df8:	0005c783          	lbu	a5,0(a1)
    80000dfc:	9d1d                	subw	a0,a0,a5
}
    80000dfe:	60a2                	ld	ra,8(sp)
    80000e00:	6402                	ld	s0,0(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e406                	sd	ra,8(sp)
    80000e0a:	e022                	sd	s0,0(sp)
    80000e0c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e0e:	87aa                	mv	a5,a0
    80000e10:	a011                	j	80000e14 <strncpy+0xe>
    80000e12:	8636                	mv	a2,a3
    80000e14:	02c05863          	blez	a2,80000e44 <strncpy+0x3e>
    80000e18:	fff6069b          	addiw	a3,a2,-1
    80000e1c:	8836                	mv	a6,a3
    80000e1e:	0785                	addi	a5,a5,1
    80000e20:	0005c703          	lbu	a4,0(a1)
    80000e24:	fee78fa3          	sb	a4,-1(a5)
    80000e28:	0585                	addi	a1,a1,1
    80000e2a:	f765                	bnez	a4,80000e12 <strncpy+0xc>
    ;
  while(n-- > 0)
    80000e2c:	873e                	mv	a4,a5
    80000e2e:	01005b63          	blez	a6,80000e44 <strncpy+0x3e>
    80000e32:	9fb1                	addw	a5,a5,a2
    80000e34:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e36:	0705                	addi	a4,a4,1
    80000e38:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e3c:	40e786bb          	subw	a3,a5,a4
    80000e40:	fed04be3          	bgtz	a3,80000e36 <strncpy+0x30>
  return os;
}
    80000e44:	60a2                	ld	ra,8(sp)
    80000e46:	6402                	ld	s0,0(sp)
    80000e48:	0141                	addi	sp,sp,16
    80000e4a:	8082                	ret

0000000080000e4c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e4c:	1141                	addi	sp,sp,-16
    80000e4e:	e406                	sd	ra,8(sp)
    80000e50:	e022                	sd	s0,0(sp)
    80000e52:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e54:	02c05363          	blez	a2,80000e7a <safestrcpy+0x2e>
    80000e58:	fff6069b          	addiw	a3,a2,-1
    80000e5c:	1682                	slli	a3,a3,0x20
    80000e5e:	9281                	srli	a3,a3,0x20
    80000e60:	96ae                	add	a3,a3,a1
    80000e62:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e64:	00d58963          	beq	a1,a3,80000e76 <safestrcpy+0x2a>
    80000e68:	0585                	addi	a1,a1,1
    80000e6a:	0785                	addi	a5,a5,1
    80000e6c:	fff5c703          	lbu	a4,-1(a1)
    80000e70:	fee78fa3          	sb	a4,-1(a5)
    80000e74:	fb65                	bnez	a4,80000e64 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e76:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e7a:	60a2                	ld	ra,8(sp)
    80000e7c:	6402                	ld	s0,0(sp)
    80000e7e:	0141                	addi	sp,sp,16
    80000e80:	8082                	ret

0000000080000e82 <strlen>:

int
strlen(const char *s)
{
    80000e82:	1141                	addi	sp,sp,-16
    80000e84:	e406                	sd	ra,8(sp)
    80000e86:	e022                	sd	s0,0(sp)
    80000e88:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e8a:	00054783          	lbu	a5,0(a0)
    80000e8e:	cf91                	beqz	a5,80000eaa <strlen+0x28>
    80000e90:	00150793          	addi	a5,a0,1
    80000e94:	86be                	mv	a3,a5
    80000e96:	0785                	addi	a5,a5,1
    80000e98:	fff7c703          	lbu	a4,-1(a5)
    80000e9c:	ff65                	bnez	a4,80000e94 <strlen+0x12>
    80000e9e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000ea2:	60a2                	ld	ra,8(sp)
    80000ea4:	6402                	ld	s0,0(sp)
    80000ea6:	0141                	addi	sp,sp,16
    80000ea8:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eaa:	4501                	li	a0,0
    80000eac:	bfdd                	j	80000ea2 <strlen+0x20>

0000000080000eae <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000eae:	1141                	addi	sp,sp,-16
    80000eb0:	e406                	sd	ra,8(sp)
    80000eb2:	e022                	sd	s0,0(sp)
    80000eb4:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000eb6:	24b000ef          	jal	80001900 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eba:	00007717          	auipc	a4,0x7
    80000ebe:	9b670713          	addi	a4,a4,-1610 # 80007870 <started>
  if(cpuid() == 0){
    80000ec2:	c51d                	beqz	a0,80000ef0 <main+0x42>
    while(started == 0)
    80000ec4:	431c                	lw	a5,0(a4)
    80000ec6:	2781                	sext.w	a5,a5
    80000ec8:	dff5                	beqz	a5,80000ec4 <main+0x16>
      ;
    __sync_synchronize();
    80000eca:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000ece:	233000ef          	jal	80001900 <cpuid>
    80000ed2:	85aa                	mv	a1,a0
    80000ed4:	00006517          	auipc	a0,0x6
    80000ed8:	1c450513          	addi	a0,a0,452 # 80007098 <etext+0x98>
    80000edc:	e1eff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000ee0:	080000ef          	jal	80000f60 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee4:	5d2010ef          	jal	800024b6 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee8:	101040ef          	jal	800057e8 <plicinithart>
  }

  scheduler();        
    80000eec:	6eb000ef          	jal	80001dd6 <scheduler>
    consoleinit();
    80000ef0:	d30ff0ef          	jal	80000420 <consoleinit>
    printfinit();
    80000ef4:	96dff0ef          	jal	80000860 <printfinit>
    printf("\n");
    80000ef8:	00006517          	auipc	a0,0x6
    80000efc:	18050513          	addi	a0,a0,384 # 80007078 <etext+0x78>
    80000f00:	dfaff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000f04:	00006517          	auipc	a0,0x6
    80000f08:	17c50513          	addi	a0,a0,380 # 80007080 <etext+0x80>
    80000f0c:	deeff0ef          	jal	800004fa <printf>
    printf("\n");
    80000f10:	00006517          	auipc	a0,0x6
    80000f14:	16850513          	addi	a0,a0,360 # 80007078 <etext+0x78>
    80000f18:	de2ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000f1c:	bf5ff0ef          	jal	80000b10 <kinit>
    kvminit();       // create kernel page table
    80000f20:	2cc000ef          	jal	800011ec <kvminit>
    kvminithart();   // turn on paging
    80000f24:	03c000ef          	jal	80000f60 <kvminithart>
    procinit();      // process table
    80000f28:	11f000ef          	jal	80001846 <procinit>
    trapinit();      // trap vectors
    80000f2c:	566010ef          	jal	80002492 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f30:	586010ef          	jal	800024b6 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f34:	09b040ef          	jal	800057ce <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f38:	0b1040ef          	jal	800057e8 <plicinithart>
    binit();         // buffer cache
    80000f3c:	725010ef          	jal	80002e60 <binit>
    iinit();         // inode table
    80000f40:	476020ef          	jal	800033b6 <iinit>
    fileinit();      // file table
    80000f44:	3a2030ef          	jal	800042e6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	191040ef          	jal	800058d8 <virtio_disk_init>
    userinit();      // first user process
    80000f4c:	4df000ef          	jal	80001c2a <userinit>
    __sync_synchronize();
    80000f50:	0330000f          	fence	rw,rw
    started = 1;
    80000f54:	4785                	li	a5,1
    80000f56:	00007717          	auipc	a4,0x7
    80000f5a:	90f72d23          	sw	a5,-1766(a4) # 80007870 <started>
    80000f5e:	b779                	j	80000eec <main+0x3e>

0000000080000f60 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f60:	1141                	addi	sp,sp,-16
    80000f62:	e406                	sd	ra,8(sp)
    80000f64:	e022                	sd	s0,0(sp)
    80000f66:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f68:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f6c:	00007797          	auipc	a5,0x7
    80000f70:	90c7b783          	ld	a5,-1780(a5) # 80007878 <kernel_pagetable>
    80000f74:	83b1                	srli	a5,a5,0xc
    80000f76:	577d                	li	a4,-1
    80000f78:	177e                	slli	a4,a4,0x3f
    80000f7a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f7c:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f80:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f84:	60a2                	ld	ra,8(sp)
    80000f86:	6402                	ld	s0,0(sp)
    80000f88:	0141                	addi	sp,sp,16
    80000f8a:	8082                	ret

0000000080000f8c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f8c:	7139                	addi	sp,sp,-64
    80000f8e:	fc06                	sd	ra,56(sp)
    80000f90:	f822                	sd	s0,48(sp)
    80000f92:	f426                	sd	s1,40(sp)
    80000f94:	f04a                	sd	s2,32(sp)
    80000f96:	ec4e                	sd	s3,24(sp)
    80000f98:	e852                	sd	s4,16(sp)
    80000f9a:	e456                	sd	s5,8(sp)
    80000f9c:	e05a                	sd	s6,0(sp)
    80000f9e:	0080                	addi	s0,sp,64
    80000fa0:	84aa                	mv	s1,a0
    80000fa2:	89ae                	mv	s3,a1
    80000fa4:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80000fa6:	57fd                	li	a5,-1
    80000fa8:	83e9                	srli	a5,a5,0x1a
    80000faa:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fac:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80000fae:	04b7e263          	bltu	a5,a1,80000ff2 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fb2:	0149d933          	srl	s2,s3,s4
    80000fb6:	1ff97913          	andi	s2,s2,511
    80000fba:	090e                	slli	s2,s2,0x3
    80000fbc:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fbe:	00093483          	ld	s1,0(s2)
    80000fc2:	0014f793          	andi	a5,s1,1
    80000fc6:	cf85                	beqz	a5,80000ffe <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fc8:	80a9                	srli	s1,s1,0xa
    80000fca:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80000fcc:	3a5d                	addiw	s4,s4,-9
    80000fce:	ff5a12e3          	bne	s4,s5,80000fb2 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fd2:	00c9d513          	srli	a0,s3,0xc
    80000fd6:	1ff57513          	andi	a0,a0,511
    80000fda:	050e                	slli	a0,a0,0x3
    80000fdc:	9526                	add	a0,a0,s1
}
    80000fde:	70e2                	ld	ra,56(sp)
    80000fe0:	7442                	ld	s0,48(sp)
    80000fe2:	74a2                	ld	s1,40(sp)
    80000fe4:	7902                	ld	s2,32(sp)
    80000fe6:	69e2                	ld	s3,24(sp)
    80000fe8:	6a42                	ld	s4,16(sp)
    80000fea:	6aa2                	ld	s5,8(sp)
    80000fec:	6b02                	ld	s6,0(sp)
    80000fee:	6121                	addi	sp,sp,64
    80000ff0:	8082                	ret
    panic("walk");
    80000ff2:	00006517          	auipc	a0,0x6
    80000ff6:	0be50513          	addi	a0,a0,190 # 800070b0 <etext+0xb0>
    80000ffa:	82bff0ef          	jal	80000824 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ffe:	020b0263          	beqz	s6,80001022 <walk+0x96>
    80001002:	b43ff0ef          	jal	80000b44 <kalloc>
    80001006:	84aa                	mv	s1,a0
    80001008:	d979                	beqz	a0,80000fde <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    8000100a:	6605                	lui	a2,0x1
    8000100c:	4581                	li	a1,0
    8000100e:	cebff0ef          	jal	80000cf8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001012:	00c4d793          	srli	a5,s1,0xc
    80001016:	07aa                	slli	a5,a5,0xa
    80001018:	0017e793          	ori	a5,a5,1
    8000101c:	00f93023          	sd	a5,0(s2)
    80001020:	b775                	j	80000fcc <walk+0x40>
        return 0;
    80001022:	4501                	li	a0,0
    80001024:	bf6d                	j	80000fde <walk+0x52>

0000000080001026 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001026:	57fd                	li	a5,-1
    80001028:	83e9                	srli	a5,a5,0x1a
    8000102a:	00b7f463          	bgeu	a5,a1,80001032 <walkaddr+0xc>
    return 0;
    8000102e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001030:	8082                	ret
{
    80001032:	1141                	addi	sp,sp,-16
    80001034:	e406                	sd	ra,8(sp)
    80001036:	e022                	sd	s0,0(sp)
    80001038:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000103a:	4601                	li	a2,0
    8000103c:	f51ff0ef          	jal	80000f8c <walk>
  if(pte == 0)
    80001040:	c901                	beqz	a0,80001050 <walkaddr+0x2a>
  if((*pte & PTE_V) == 0)
    80001042:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001044:	0117f693          	andi	a3,a5,17
    80001048:	4745                	li	a4,17
    return 0;
    8000104a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000104c:	00e68663          	beq	a3,a4,80001058 <walkaddr+0x32>
}
    80001050:	60a2                	ld	ra,8(sp)
    80001052:	6402                	ld	s0,0(sp)
    80001054:	0141                	addi	sp,sp,16
    80001056:	8082                	ret
  pa = PTE2PA(*pte);
    80001058:	83a9                	srli	a5,a5,0xa
    8000105a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000105e:	bfcd                	j	80001050 <walkaddr+0x2a>

0000000080001060 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001060:	715d                	addi	sp,sp,-80
    80001062:	e486                	sd	ra,72(sp)
    80001064:	e0a2                	sd	s0,64(sp)
    80001066:	fc26                	sd	s1,56(sp)
    80001068:	f84a                	sd	s2,48(sp)
    8000106a:	f44e                	sd	s3,40(sp)
    8000106c:	f052                	sd	s4,32(sp)
    8000106e:	ec56                	sd	s5,24(sp)
    80001070:	e85a                	sd	s6,16(sp)
    80001072:	e45e                	sd	s7,8(sp)
    80001074:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001076:	03459793          	slli	a5,a1,0x34
    8000107a:	eba1                	bnez	a5,800010ca <mappages+0x6a>
    8000107c:	8a2a                	mv	s4,a0
    8000107e:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001080:	03461793          	slli	a5,a2,0x34
    80001084:	eba9                	bnez	a5,800010d6 <mappages+0x76>
    panic("mappages: size not aligned");

  if(size == 0)
    80001086:	ce31                	beqz	a2,800010e2 <mappages+0x82>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001088:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    8000108c:	80060613          	addi	a2,a2,-2048
    80001090:	00b60933          	add	s2,a2,a1
  a = va;
    80001094:	84ae                	mv	s1,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    80001096:	4b05                	li	s6,1
    80001098:	40b689b3          	sub	s3,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000109c:	6b85                	lui	s7,0x1
    if((pte = walk(pagetable, a, 1)) == 0)
    8000109e:	865a                	mv	a2,s6
    800010a0:	85a6                	mv	a1,s1
    800010a2:	8552                	mv	a0,s4
    800010a4:	ee9ff0ef          	jal	80000f8c <walk>
    800010a8:	c929                	beqz	a0,800010fa <mappages+0x9a>
    if(*pte & PTE_V)
    800010aa:	611c                	ld	a5,0(a0)
    800010ac:	8b85                	andi	a5,a5,1
    800010ae:	e3a1                	bnez	a5,800010ee <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010b0:	013487b3          	add	a5,s1,s3
    800010b4:	83b1                	srli	a5,a5,0xc
    800010b6:	07aa                	slli	a5,a5,0xa
    800010b8:	0157e7b3          	or	a5,a5,s5
    800010bc:	0017e793          	ori	a5,a5,1
    800010c0:	e11c                	sd	a5,0(a0)
    if(a == last)
    800010c2:	05248863          	beq	s1,s2,80001112 <mappages+0xb2>
    a += PGSIZE;
    800010c6:	94de                	add	s1,s1,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010c8:	bfd9                	j	8000109e <mappages+0x3e>
    panic("mappages: va not aligned");
    800010ca:	00006517          	auipc	a0,0x6
    800010ce:	fee50513          	addi	a0,a0,-18 # 800070b8 <etext+0xb8>
    800010d2:	f52ff0ef          	jal	80000824 <panic>
    panic("mappages: size not aligned");
    800010d6:	00006517          	auipc	a0,0x6
    800010da:	00250513          	addi	a0,a0,2 # 800070d8 <etext+0xd8>
    800010de:	f46ff0ef          	jal	80000824 <panic>
    panic("mappages: size");
    800010e2:	00006517          	auipc	a0,0x6
    800010e6:	01650513          	addi	a0,a0,22 # 800070f8 <etext+0xf8>
    800010ea:	f3aff0ef          	jal	80000824 <panic>
      panic("mappages: remap");
    800010ee:	00006517          	auipc	a0,0x6
    800010f2:	01a50513          	addi	a0,a0,26 # 80007108 <etext+0x108>
    800010f6:	f2eff0ef          	jal	80000824 <panic>
      return -1;
    800010fa:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010fc:	60a6                	ld	ra,72(sp)
    800010fe:	6406                	ld	s0,64(sp)
    80001100:	74e2                	ld	s1,56(sp)
    80001102:	7942                	ld	s2,48(sp)
    80001104:	79a2                	ld	s3,40(sp)
    80001106:	7a02                	ld	s4,32(sp)
    80001108:	6ae2                	ld	s5,24(sp)
    8000110a:	6b42                	ld	s6,16(sp)
    8000110c:	6ba2                	ld	s7,8(sp)
    8000110e:	6161                	addi	sp,sp,80
    80001110:	8082                	ret
  return 0;
    80001112:	4501                	li	a0,0
    80001114:	b7e5                	j	800010fc <mappages+0x9c>

0000000080001116 <kvmmap>:
{
    80001116:	1141                	addi	sp,sp,-16
    80001118:	e406                	sd	ra,8(sp)
    8000111a:	e022                	sd	s0,0(sp)
    8000111c:	0800                	addi	s0,sp,16
    8000111e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001120:	86b2                	mv	a3,a2
    80001122:	863e                	mv	a2,a5
    80001124:	f3dff0ef          	jal	80001060 <mappages>
    80001128:	e509                	bnez	a0,80001132 <kvmmap+0x1c>
}
    8000112a:	60a2                	ld	ra,8(sp)
    8000112c:	6402                	ld	s0,0(sp)
    8000112e:	0141                	addi	sp,sp,16
    80001130:	8082                	ret
    panic("kvmmap");
    80001132:	00006517          	auipc	a0,0x6
    80001136:	fe650513          	addi	a0,a0,-26 # 80007118 <etext+0x118>
    8000113a:	eeaff0ef          	jal	80000824 <panic>

000000008000113e <kvmmake>:
{
    8000113e:	1101                	addi	sp,sp,-32
    80001140:	ec06                	sd	ra,24(sp)
    80001142:	e822                	sd	s0,16(sp)
    80001144:	e426                	sd	s1,8(sp)
    80001146:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001148:	9fdff0ef          	jal	80000b44 <kalloc>
    8000114c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000114e:	6605                	lui	a2,0x1
    80001150:	4581                	li	a1,0
    80001152:	ba7ff0ef          	jal	80000cf8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001156:	4719                	li	a4,6
    80001158:	6685                	lui	a3,0x1
    8000115a:	10000637          	lui	a2,0x10000
    8000115e:	85b2                	mv	a1,a2
    80001160:	8526                	mv	a0,s1
    80001162:	fb5ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001166:	4719                	li	a4,6
    80001168:	6685                	lui	a3,0x1
    8000116a:	10001637          	lui	a2,0x10001
    8000116e:	85b2                	mv	a1,a2
    80001170:	8526                	mv	a0,s1
    80001172:	fa5ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001176:	4719                	li	a4,6
    80001178:	040006b7          	lui	a3,0x4000
    8000117c:	0c000637          	lui	a2,0xc000
    80001180:	85b2                	mv	a1,a2
    80001182:	8526                	mv	a0,s1
    80001184:	f93ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001188:	4729                	li	a4,10
    8000118a:	80006697          	auipc	a3,0x80006
    8000118e:	e7668693          	addi	a3,a3,-394 # 7000 <_entry-0x7fff9000>
    80001192:	4605                	li	a2,1
    80001194:	067e                	slli	a2,a2,0x1f
    80001196:	85b2                	mv	a1,a2
    80001198:	8526                	mv	a0,s1
    8000119a:	f7dff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000119e:	4719                	li	a4,6
    800011a0:	00006697          	auipc	a3,0x6
    800011a4:	e6068693          	addi	a3,a3,-416 # 80007000 <etext>
    800011a8:	47c5                	li	a5,17
    800011aa:	07ee                	slli	a5,a5,0x1b
    800011ac:	40d786b3          	sub	a3,a5,a3
    800011b0:	00006617          	auipc	a2,0x6
    800011b4:	e5060613          	addi	a2,a2,-432 # 80007000 <etext>
    800011b8:	85b2                	mv	a1,a2
    800011ba:	8526                	mv	a0,s1
    800011bc:	f5bff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011c0:	4729                	li	a4,10
    800011c2:	6685                	lui	a3,0x1
    800011c4:	00005617          	auipc	a2,0x5
    800011c8:	e3c60613          	addi	a2,a2,-452 # 80006000 <_trampoline>
    800011cc:	040005b7          	lui	a1,0x4000
    800011d0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011d2:	05b2                	slli	a1,a1,0xc
    800011d4:	8526                	mv	a0,s1
    800011d6:	f41ff0ef          	jal	80001116 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011da:	8526                	mv	a0,s1
    800011dc:	5c4000ef          	jal	800017a0 <proc_mapstacks>
}
    800011e0:	8526                	mv	a0,s1
    800011e2:	60e2                	ld	ra,24(sp)
    800011e4:	6442                	ld	s0,16(sp)
    800011e6:	64a2                	ld	s1,8(sp)
    800011e8:	6105                	addi	sp,sp,32
    800011ea:	8082                	ret

00000000800011ec <kvminit>:
{
    800011ec:	1141                	addi	sp,sp,-16
    800011ee:	e406                	sd	ra,8(sp)
    800011f0:	e022                	sd	s0,0(sp)
    800011f2:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011f4:	f4bff0ef          	jal	8000113e <kvmmake>
    800011f8:	00006797          	auipc	a5,0x6
    800011fc:	68a7b023          	sd	a0,1664(a5) # 80007878 <kernel_pagetable>
}
    80001200:	60a2                	ld	ra,8(sp)
    80001202:	6402                	ld	s0,0(sp)
    80001204:	0141                	addi	sp,sp,16
    80001206:	8082                	ret

0000000080001208 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001208:	1101                	addi	sp,sp,-32
    8000120a:	ec06                	sd	ra,24(sp)
    8000120c:	e822                	sd	s0,16(sp)
    8000120e:	e426                	sd	s1,8(sp)
    80001210:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001212:	933ff0ef          	jal	80000b44 <kalloc>
    80001216:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001218:	c509                	beqz	a0,80001222 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000121a:	6605                	lui	a2,0x1
    8000121c:	4581                	li	a1,0
    8000121e:	adbff0ef          	jal	80000cf8 <memset>
  return pagetable;
}
    80001222:	8526                	mv	a0,s1
    80001224:	60e2                	ld	ra,24(sp)
    80001226:	6442                	ld	s0,16(sp)
    80001228:	64a2                	ld	s1,8(sp)
    8000122a:	6105                	addi	sp,sp,32
    8000122c:	8082                	ret

000000008000122e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000122e:	7139                	addi	sp,sp,-64
    80001230:	fc06                	sd	ra,56(sp)
    80001232:	f822                	sd	s0,48(sp)
    80001234:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001236:	03459793          	slli	a5,a1,0x34
    8000123a:	e38d                	bnez	a5,8000125c <uvmunmap+0x2e>
    8000123c:	f04a                	sd	s2,32(sp)
    8000123e:	ec4e                	sd	s3,24(sp)
    80001240:	e852                	sd	s4,16(sp)
    80001242:	e456                	sd	s5,8(sp)
    80001244:	e05a                	sd	s6,0(sp)
    80001246:	8a2a                	mv	s4,a0
    80001248:	892e                	mv	s2,a1
    8000124a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000124c:	0632                	slli	a2,a2,0xc
    8000124e:	00b609b3          	add	s3,a2,a1
    80001252:	6b05                	lui	s6,0x1
    80001254:	0535f963          	bgeu	a1,s3,800012a6 <uvmunmap+0x78>
    80001258:	f426                	sd	s1,40(sp)
    8000125a:	a015                	j	8000127e <uvmunmap+0x50>
    8000125c:	f426                	sd	s1,40(sp)
    8000125e:	f04a                	sd	s2,32(sp)
    80001260:	ec4e                	sd	s3,24(sp)
    80001262:	e852                	sd	s4,16(sp)
    80001264:	e456                	sd	s5,8(sp)
    80001266:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    80001268:	00006517          	auipc	a0,0x6
    8000126c:	eb850513          	addi	a0,a0,-328 # 80007120 <etext+0x120>
    80001270:	db4ff0ef          	jal	80000824 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001274:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001278:	995a                	add	s2,s2,s6
    8000127a:	03397563          	bgeu	s2,s3,800012a4 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    8000127e:	4601                	li	a2,0
    80001280:	85ca                	mv	a1,s2
    80001282:	8552                	mv	a0,s4
    80001284:	d09ff0ef          	jal	80000f8c <walk>
    80001288:	84aa                	mv	s1,a0
    8000128a:	d57d                	beqz	a0,80001278 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    8000128c:	611c                	ld	a5,0(a0)
    8000128e:	0017f713          	andi	a4,a5,1
    80001292:	d37d                	beqz	a4,80001278 <uvmunmap+0x4a>
    if(do_free){
    80001294:	fe0a80e3          	beqz	s5,80001274 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001298:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    8000129a:	00c79513          	slli	a0,a5,0xc
    8000129e:	fbeff0ef          	jal	80000a5c <kfree>
    800012a2:	bfc9                	j	80001274 <uvmunmap+0x46>
    800012a4:	74a2                	ld	s1,40(sp)
    800012a6:	7902                	ld	s2,32(sp)
    800012a8:	69e2                	ld	s3,24(sp)
    800012aa:	6a42                	ld	s4,16(sp)
    800012ac:	6aa2                	ld	s5,8(sp)
    800012ae:	6b02                	ld	s6,0(sp)
  }
}
    800012b0:	70e2                	ld	ra,56(sp)
    800012b2:	7442                	ld	s0,48(sp)
    800012b4:	6121                	addi	sp,sp,64
    800012b6:	8082                	ret

00000000800012b8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012b8:	1101                	addi	sp,sp,-32
    800012ba:	ec06                	sd	ra,24(sp)
    800012bc:	e822                	sd	s0,16(sp)
    800012be:	e426                	sd	s1,8(sp)
    800012c0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800012c2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800012c4:	00b67d63          	bgeu	a2,a1,800012de <uvmdealloc+0x26>
    800012c8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800012ca:	6785                	lui	a5,0x1
    800012cc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012ce:	00f60733          	add	a4,a2,a5
    800012d2:	76fd                	lui	a3,0xfffff
    800012d4:	8f75                	and	a4,a4,a3
    800012d6:	97ae                	add	a5,a5,a1
    800012d8:	8ff5                	and	a5,a5,a3
    800012da:	00f76863          	bltu	a4,a5,800012ea <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800012de:	8526                	mv	a0,s1
    800012e0:	60e2                	ld	ra,24(sp)
    800012e2:	6442                	ld	s0,16(sp)
    800012e4:	64a2                	ld	s1,8(sp)
    800012e6:	6105                	addi	sp,sp,32
    800012e8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012ea:	8f99                	sub	a5,a5,a4
    800012ec:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012ee:	4685                	li	a3,1
    800012f0:	0007861b          	sext.w	a2,a5
    800012f4:	85ba                	mv	a1,a4
    800012f6:	f39ff0ef          	jal	8000122e <uvmunmap>
    800012fa:	b7d5                	j	800012de <uvmdealloc+0x26>

00000000800012fc <uvmalloc>:
  if(newsz < oldsz)
    800012fc:	0ab66163          	bltu	a2,a1,8000139e <uvmalloc+0xa2>
{
    80001300:	715d                	addi	sp,sp,-80
    80001302:	e486                	sd	ra,72(sp)
    80001304:	e0a2                	sd	s0,64(sp)
    80001306:	f84a                	sd	s2,48(sp)
    80001308:	f052                	sd	s4,32(sp)
    8000130a:	ec56                	sd	s5,24(sp)
    8000130c:	e45e                	sd	s7,8(sp)
    8000130e:	0880                	addi	s0,sp,80
    80001310:	8aaa                	mv	s5,a0
    80001312:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001314:	6785                	lui	a5,0x1
    80001316:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001318:	95be                	add	a1,a1,a5
    8000131a:	77fd                	lui	a5,0xfffff
    8000131c:	00f5f933          	and	s2,a1,a5
    80001320:	8bca                	mv	s7,s2
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001322:	08c97063          	bgeu	s2,a2,800013a2 <uvmalloc+0xa6>
    80001326:	fc26                	sd	s1,56(sp)
    80001328:	f44e                	sd	s3,40(sp)
    8000132a:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    8000132c:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000132e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001332:	813ff0ef          	jal	80000b44 <kalloc>
    80001336:	84aa                	mv	s1,a0
    if(mem == 0){
    80001338:	c50d                	beqz	a0,80001362 <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    8000133a:	864e                	mv	a2,s3
    8000133c:	4581                	li	a1,0
    8000133e:	9bbff0ef          	jal	80000cf8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001342:	875a                	mv	a4,s6
    80001344:	86a6                	mv	a3,s1
    80001346:	864e                	mv	a2,s3
    80001348:	85ca                	mv	a1,s2
    8000134a:	8556                	mv	a0,s5
    8000134c:	d15ff0ef          	jal	80001060 <mappages>
    80001350:	e915                	bnez	a0,80001384 <uvmalloc+0x88>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001352:	994e                	add	s2,s2,s3
    80001354:	fd496fe3          	bltu	s2,s4,80001332 <uvmalloc+0x36>
  return newsz;
    80001358:	8552                	mv	a0,s4
    8000135a:	74e2                	ld	s1,56(sp)
    8000135c:	79a2                	ld	s3,40(sp)
    8000135e:	6b42                	ld	s6,16(sp)
    80001360:	a811                	j	80001374 <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    80001362:	865e                	mv	a2,s7
    80001364:	85ca                	mv	a1,s2
    80001366:	8556                	mv	a0,s5
    80001368:	f51ff0ef          	jal	800012b8 <uvmdealloc>
      return 0;
    8000136c:	4501                	li	a0,0
    8000136e:	74e2                	ld	s1,56(sp)
    80001370:	79a2                	ld	s3,40(sp)
    80001372:	6b42                	ld	s6,16(sp)
}
    80001374:	60a6                	ld	ra,72(sp)
    80001376:	6406                	ld	s0,64(sp)
    80001378:	7942                	ld	s2,48(sp)
    8000137a:	7a02                	ld	s4,32(sp)
    8000137c:	6ae2                	ld	s5,24(sp)
    8000137e:	6ba2                	ld	s7,8(sp)
    80001380:	6161                	addi	sp,sp,80
    80001382:	8082                	ret
      kfree(mem);
    80001384:	8526                	mv	a0,s1
    80001386:	ed6ff0ef          	jal	80000a5c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000138a:	865e                	mv	a2,s7
    8000138c:	85ca                	mv	a1,s2
    8000138e:	8556                	mv	a0,s5
    80001390:	f29ff0ef          	jal	800012b8 <uvmdealloc>
      return 0;
    80001394:	4501                	li	a0,0
    80001396:	74e2                	ld	s1,56(sp)
    80001398:	79a2                	ld	s3,40(sp)
    8000139a:	6b42                	ld	s6,16(sp)
    8000139c:	bfe1                	j	80001374 <uvmalloc+0x78>
    return oldsz;
    8000139e:	852e                	mv	a0,a1
}
    800013a0:	8082                	ret
  return newsz;
    800013a2:	8532                	mv	a0,a2
    800013a4:	bfc1                	j	80001374 <uvmalloc+0x78>

00000000800013a6 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013a6:	7179                	addi	sp,sp,-48
    800013a8:	f406                	sd	ra,40(sp)
    800013aa:	f022                	sd	s0,32(sp)
    800013ac:	ec26                	sd	s1,24(sp)
    800013ae:	e84a                	sd	s2,16(sp)
    800013b0:	e44e                	sd	s3,8(sp)
    800013b2:	1800                	addi	s0,sp,48
    800013b4:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013b6:	84aa                	mv	s1,a0
    800013b8:	6905                	lui	s2,0x1
    800013ba:	992a                	add	s2,s2,a0
    800013bc:	a811                	j	800013d0 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    800013be:	00006517          	auipc	a0,0x6
    800013c2:	d7a50513          	addi	a0,a0,-646 # 80007138 <etext+0x138>
    800013c6:	c5eff0ef          	jal	80000824 <panic>
  for(int i = 0; i < 512; i++){
    800013ca:	04a1                	addi	s1,s1,8
    800013cc:	03248163          	beq	s1,s2,800013ee <freewalk+0x48>
    pte_t pte = pagetable[i];
    800013d0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013d2:	0017f713          	andi	a4,a5,1
    800013d6:	db75                	beqz	a4,800013ca <freewalk+0x24>
    800013d8:	00e7f713          	andi	a4,a5,14
    800013dc:	f36d                	bnez	a4,800013be <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800013de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800013e0:	00c79513          	slli	a0,a5,0xc
    800013e4:	fc3ff0ef          	jal	800013a6 <freewalk>
      pagetable[i] = 0;
    800013e8:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013ec:	bff9                	j	800013ca <freewalk+0x24>
    }
  }
  kfree((void*)pagetable);
    800013ee:	854e                	mv	a0,s3
    800013f0:	e6cff0ef          	jal	80000a5c <kfree>
}
    800013f4:	70a2                	ld	ra,40(sp)
    800013f6:	7402                	ld	s0,32(sp)
    800013f8:	64e2                	ld	s1,24(sp)
    800013fa:	6942                	ld	s2,16(sp)
    800013fc:	69a2                	ld	s3,8(sp)
    800013fe:	6145                	addi	sp,sp,48
    80001400:	8082                	ret

0000000080001402 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001402:	1101                	addi	sp,sp,-32
    80001404:	ec06                	sd	ra,24(sp)
    80001406:	e822                	sd	s0,16(sp)
    80001408:	e426                	sd	s1,8(sp)
    8000140a:	1000                	addi	s0,sp,32
    8000140c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000140e:	e989                	bnez	a1,80001420 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001410:	8526                	mv	a0,s1
    80001412:	f95ff0ef          	jal	800013a6 <freewalk>
}
    80001416:	60e2                	ld	ra,24(sp)
    80001418:	6442                	ld	s0,16(sp)
    8000141a:	64a2                	ld	s1,8(sp)
    8000141c:	6105                	addi	sp,sp,32
    8000141e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001420:	6785                	lui	a5,0x1
    80001422:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001424:	95be                	add	a1,a1,a5
    80001426:	4685                	li	a3,1
    80001428:	00c5d613          	srli	a2,a1,0xc
    8000142c:	4581                	li	a1,0
    8000142e:	e01ff0ef          	jal	8000122e <uvmunmap>
    80001432:	bff9                	j	80001410 <uvmfree+0xe>

0000000080001434 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001434:	ca59                	beqz	a2,800014ca <uvmcopy+0x96>
{
    80001436:	715d                	addi	sp,sp,-80
    80001438:	e486                	sd	ra,72(sp)
    8000143a:	e0a2                	sd	s0,64(sp)
    8000143c:	fc26                	sd	s1,56(sp)
    8000143e:	f84a                	sd	s2,48(sp)
    80001440:	f44e                	sd	s3,40(sp)
    80001442:	f052                	sd	s4,32(sp)
    80001444:	ec56                	sd	s5,24(sp)
    80001446:	e85a                	sd	s6,16(sp)
    80001448:	e45e                	sd	s7,8(sp)
    8000144a:	0880                	addi	s0,sp,80
    8000144c:	8b2a                	mv	s6,a0
    8000144e:	8bae                	mv	s7,a1
    80001450:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001452:	4481                	li	s1,0
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001454:	6a05                	lui	s4,0x1
    80001456:	a021                	j	8000145e <uvmcopy+0x2a>
  for(i = 0; i < sz; i += PGSIZE){
    80001458:	94d2                	add	s1,s1,s4
    8000145a:	0554fc63          	bgeu	s1,s5,800014b2 <uvmcopy+0x7e>
    if((pte = walk(old, i, 0)) == 0)
    8000145e:	4601                	li	a2,0
    80001460:	85a6                	mv	a1,s1
    80001462:	855a                	mv	a0,s6
    80001464:	b29ff0ef          	jal	80000f8c <walk>
    80001468:	d965                	beqz	a0,80001458 <uvmcopy+0x24>
    if((*pte & PTE_V) == 0)
    8000146a:	00053983          	ld	s3,0(a0)
    8000146e:	0019f793          	andi	a5,s3,1
    80001472:	d3fd                	beqz	a5,80001458 <uvmcopy+0x24>
    if((mem = kalloc()) == 0)
    80001474:	ed0ff0ef          	jal	80000b44 <kalloc>
    80001478:	892a                	mv	s2,a0
    8000147a:	c11d                	beqz	a0,800014a0 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    8000147c:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char*)pa, PGSIZE);
    80001480:	8652                	mv	a2,s4
    80001482:	05b2                	slli	a1,a1,0xc
    80001484:	8d5ff0ef          	jal	80000d58 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001488:	3ff9f713          	andi	a4,s3,1023
    8000148c:	86ca                	mv	a3,s2
    8000148e:	8652                	mv	a2,s4
    80001490:	85a6                	mv	a1,s1
    80001492:	855e                	mv	a0,s7
    80001494:	bcdff0ef          	jal	80001060 <mappages>
    80001498:	d161                	beqz	a0,80001458 <uvmcopy+0x24>
      kfree(mem);
    8000149a:	854a                	mv	a0,s2
    8000149c:	dc0ff0ef          	jal	80000a5c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014a0:	4685                	li	a3,1
    800014a2:	00c4d613          	srli	a2,s1,0xc
    800014a6:	4581                	li	a1,0
    800014a8:	855e                	mv	a0,s7
    800014aa:	d85ff0ef          	jal	8000122e <uvmunmap>
  return -1;
    800014ae:	557d                	li	a0,-1
    800014b0:	a011                	j	800014b4 <uvmcopy+0x80>
  return 0;
    800014b2:	4501                	li	a0,0
}
    800014b4:	60a6                	ld	ra,72(sp)
    800014b6:	6406                	ld	s0,64(sp)
    800014b8:	74e2                	ld	s1,56(sp)
    800014ba:	7942                	ld	s2,48(sp)
    800014bc:	79a2                	ld	s3,40(sp)
    800014be:	7a02                	ld	s4,32(sp)
    800014c0:	6ae2                	ld	s5,24(sp)
    800014c2:	6b42                	ld	s6,16(sp)
    800014c4:	6ba2                	ld	s7,8(sp)
    800014c6:	6161                	addi	sp,sp,80
    800014c8:	8082                	ret
  return 0;
    800014ca:	4501                	li	a0,0
}
    800014cc:	8082                	ret

00000000800014ce <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014ce:	1141                	addi	sp,sp,-16
    800014d0:	e406                	sd	ra,8(sp)
    800014d2:	e022                	sd	s0,0(sp)
    800014d4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800014d6:	4601                	li	a2,0
    800014d8:	ab5ff0ef          	jal	80000f8c <walk>
  if(pte == 0)
    800014dc:	c901                	beqz	a0,800014ec <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014de:	611c                	ld	a5,0(a0)
    800014e0:	9bbd                	andi	a5,a5,-17
    800014e2:	e11c                	sd	a5,0(a0)
}
    800014e4:	60a2                	ld	ra,8(sp)
    800014e6:	6402                	ld	s0,0(sp)
    800014e8:	0141                	addi	sp,sp,16
    800014ea:	8082                	ret
    panic("uvmclear");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	c5c50513          	addi	a0,a0,-932 # 80007148 <etext+0x148>
    800014f4:	b30ff0ef          	jal	80000824 <panic>

00000000800014f8 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800014f8:	cac5                	beqz	a3,800015a8 <copyinstr+0xb0>
{
    800014fa:	715d                	addi	sp,sp,-80
    800014fc:	e486                	sd	ra,72(sp)
    800014fe:	e0a2                	sd	s0,64(sp)
    80001500:	fc26                	sd	s1,56(sp)
    80001502:	f84a                	sd	s2,48(sp)
    80001504:	f44e                	sd	s3,40(sp)
    80001506:	f052                	sd	s4,32(sp)
    80001508:	ec56                	sd	s5,24(sp)
    8000150a:	e85a                	sd	s6,16(sp)
    8000150c:	e45e                	sd	s7,8(sp)
    8000150e:	0880                	addi	s0,sp,80
    80001510:	8aaa                	mv	s5,a0
    80001512:	84ae                	mv	s1,a1
    80001514:	8bb2                	mv	s7,a2
    80001516:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001518:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000151a:	6a05                	lui	s4,0x1
    8000151c:	a82d                	j	80001556 <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000151e:	00078023          	sb	zero,0(a5)
        got_null = 1;
    80001522:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001524:	0017c793          	xori	a5,a5,1
    80001528:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000152c:	60a6                	ld	ra,72(sp)
    8000152e:	6406                	ld	s0,64(sp)
    80001530:	74e2                	ld	s1,56(sp)
    80001532:	7942                	ld	s2,48(sp)
    80001534:	79a2                	ld	s3,40(sp)
    80001536:	7a02                	ld	s4,32(sp)
    80001538:	6ae2                	ld	s5,24(sp)
    8000153a:	6b42                	ld	s6,16(sp)
    8000153c:	6ba2                	ld	s7,8(sp)
    8000153e:	6161                	addi	sp,sp,80
    80001540:	8082                	ret
    80001542:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    80001546:	9726                	add	a4,a4,s1
      --max;
    80001548:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    8000154c:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    80001550:	04e58463          	beq	a1,a4,80001598 <copyinstr+0xa0>
{
    80001554:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001556:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    8000155a:	85ca                	mv	a1,s2
    8000155c:	8556                	mv	a0,s5
    8000155e:	ac9ff0ef          	jal	80001026 <walkaddr>
    if(pa0 == 0)
    80001562:	cd0d                	beqz	a0,8000159c <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001564:	417906b3          	sub	a3,s2,s7
    80001568:	96d2                	add	a3,a3,s4
    if(n > max)
    8000156a:	00d9f363          	bgeu	s3,a3,80001570 <copyinstr+0x78>
    8000156e:	86ce                	mv	a3,s3
    while(n > 0){
    80001570:	ca85                	beqz	a3,800015a0 <copyinstr+0xa8>
    char *p = (char *) (pa0 + (srcva - va0));
    80001572:	01750633          	add	a2,a0,s7
    80001576:	41260633          	sub	a2,a2,s2
    8000157a:	87a6                	mv	a5,s1
      if(*p == '\0'){
    8000157c:	8e05                	sub	a2,a2,s1
    while(n > 0){
    8000157e:	96a6                	add	a3,a3,s1
    80001580:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001582:	00f60733          	add	a4,a2,a5
    80001586:	00074703          	lbu	a4,0(a4)
    8000158a:	db51                	beqz	a4,8000151e <copyinstr+0x26>
        *dst = *p;
    8000158c:	00e78023          	sb	a4,0(a5)
      dst++;
    80001590:	0785                	addi	a5,a5,1
    while(n > 0){
    80001592:	fed797e3          	bne	a5,a3,80001580 <copyinstr+0x88>
    80001596:	b775                	j	80001542 <copyinstr+0x4a>
    80001598:	4781                	li	a5,0
    8000159a:	b769                	j	80001524 <copyinstr+0x2c>
      return -1;
    8000159c:	557d                	li	a0,-1
    8000159e:	b779                	j	8000152c <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    800015a0:	6b85                	lui	s7,0x1
    800015a2:	9bca                	add	s7,s7,s2
    800015a4:	87a6                	mv	a5,s1
    800015a6:	b77d                	j	80001554 <copyinstr+0x5c>
  int got_null = 0;
    800015a8:	4781                	li	a5,0
  if(got_null){
    800015aa:	0017c793          	xori	a5,a5,1
    800015ae:	40f0053b          	negw	a0,a5
}
    800015b2:	8082                	ret

00000000800015b4 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800015b4:	1141                	addi	sp,sp,-16
    800015b6:	e406                	sd	ra,8(sp)
    800015b8:	e022                	sd	s0,0(sp)
    800015ba:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800015bc:	4601                	li	a2,0
    800015be:	9cfff0ef          	jal	80000f8c <walk>
  if (pte == 0) {
    800015c2:	c119                	beqz	a0,800015c8 <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V){
    800015c4:	6108                	ld	a0,0(a0)
    800015c6:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800015c8:	60a2                	ld	ra,8(sp)
    800015ca:	6402                	ld	s0,0(sp)
    800015cc:	0141                	addi	sp,sp,16
    800015ce:	8082                	ret

00000000800015d0 <vmfault>:
{
    800015d0:	7179                	addi	sp,sp,-48
    800015d2:	f406                	sd	ra,40(sp)
    800015d4:	f022                	sd	s0,32(sp)
    800015d6:	e84a                	sd	s2,16(sp)
    800015d8:	e44e                	sd	s3,8(sp)
    800015da:	1800                	addi	s0,sp,48
    800015dc:	89aa                	mv	s3,a0
    800015de:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800015e0:	354000ef          	jal	80001934 <myproc>
  if (va >= p->sz)
    800015e4:	653c                	ld	a5,72(a0)
    800015e6:	00f96a63          	bltu	s2,a5,800015fa <vmfault+0x2a>
    return 0;
    800015ea:	4981                	li	s3,0
}
    800015ec:	854e                	mv	a0,s3
    800015ee:	70a2                	ld	ra,40(sp)
    800015f0:	7402                	ld	s0,32(sp)
    800015f2:	6942                	ld	s2,16(sp)
    800015f4:	69a2                	ld	s3,8(sp)
    800015f6:	6145                	addi	sp,sp,48
    800015f8:	8082                	ret
    800015fa:	ec26                	sd	s1,24(sp)
    800015fc:	e052                	sd	s4,0(sp)
    800015fe:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    80001600:	77fd                	lui	a5,0xfffff
    80001602:	00f97a33          	and	s4,s2,a5
  if(ismapped(pagetable, va)) {
    80001606:	85d2                	mv	a1,s4
    80001608:	854e                	mv	a0,s3
    8000160a:	fabff0ef          	jal	800015b4 <ismapped>
    return 0;
    8000160e:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001610:	c501                	beqz	a0,80001618 <vmfault+0x48>
    80001612:	64e2                	ld	s1,24(sp)
    80001614:	6a02                	ld	s4,0(sp)
    80001616:	bfd9                	j	800015ec <vmfault+0x1c>
  mem = (uint64) kalloc();
    80001618:	d2cff0ef          	jal	80000b44 <kalloc>
    8000161c:	892a                	mv	s2,a0
  if(mem == 0)
    8000161e:	c905                	beqz	a0,8000164e <vmfault+0x7e>
  mem = (uint64) kalloc();
    80001620:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    80001622:	6605                	lui	a2,0x1
    80001624:	4581                	li	a1,0
    80001626:	ed2ff0ef          	jal	80000cf8 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    8000162a:	4759                	li	a4,22
    8000162c:	86ca                	mv	a3,s2
    8000162e:	6605                	lui	a2,0x1
    80001630:	85d2                	mv	a1,s4
    80001632:	68a8                	ld	a0,80(s1)
    80001634:	a2dff0ef          	jal	80001060 <mappages>
    80001638:	e501                	bnez	a0,80001640 <vmfault+0x70>
    8000163a:	64e2                	ld	s1,24(sp)
    8000163c:	6a02                	ld	s4,0(sp)
    8000163e:	b77d                	j	800015ec <vmfault+0x1c>
    kfree((void *)mem);
    80001640:	854a                	mv	a0,s2
    80001642:	c1aff0ef          	jal	80000a5c <kfree>
    return 0;
    80001646:	4981                	li	s3,0
    80001648:	64e2                	ld	s1,24(sp)
    8000164a:	6a02                	ld	s4,0(sp)
    8000164c:	b745                	j	800015ec <vmfault+0x1c>
    8000164e:	64e2                	ld	s1,24(sp)
    80001650:	6a02                	ld	s4,0(sp)
    80001652:	bf69                	j	800015ec <vmfault+0x1c>

0000000080001654 <copyout>:
  while(len > 0){
    80001654:	cad1                	beqz	a3,800016e8 <copyout+0x94>
{
    80001656:	711d                	addi	sp,sp,-96
    80001658:	ec86                	sd	ra,88(sp)
    8000165a:	e8a2                	sd	s0,80(sp)
    8000165c:	e4a6                	sd	s1,72(sp)
    8000165e:	e0ca                	sd	s2,64(sp)
    80001660:	fc4e                	sd	s3,56(sp)
    80001662:	f852                	sd	s4,48(sp)
    80001664:	f456                	sd	s5,40(sp)
    80001666:	f05a                	sd	s6,32(sp)
    80001668:	ec5e                	sd	s7,24(sp)
    8000166a:	e862                	sd	s8,16(sp)
    8000166c:	e466                	sd	s9,8(sp)
    8000166e:	e06a                	sd	s10,0(sp)
    80001670:	1080                	addi	s0,sp,96
    80001672:	8baa                	mv	s7,a0
    80001674:	8a2e                	mv	s4,a1
    80001676:	8b32                	mv	s6,a2
    80001678:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    8000167a:	7d7d                	lui	s10,0xfffff
    if(va0 >= MAXVA)
    8000167c:	5cfd                	li	s9,-1
    8000167e:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    80001682:	6c05                	lui	s8,0x1
    80001684:	a005                	j	800016a4 <copyout+0x50>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001686:	409a0533          	sub	a0,s4,s1
    8000168a:	0009061b          	sext.w	a2,s2
    8000168e:	85da                	mv	a1,s6
    80001690:	954e                	add	a0,a0,s3
    80001692:	ec6ff0ef          	jal	80000d58 <memmove>
    len -= n;
    80001696:	412a8ab3          	sub	s5,s5,s2
    src += n;
    8000169a:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    8000169c:	01848a33          	add	s4,s1,s8
  while(len > 0){
    800016a0:	040a8263          	beqz	s5,800016e4 <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    800016a4:	01aa74b3          	and	s1,s4,s10
    if(va0 >= MAXVA)
    800016a8:	049ce263          	bltu	s9,s1,800016ec <copyout+0x98>
    pa0 = walkaddr(pagetable, va0);
    800016ac:	85a6                	mv	a1,s1
    800016ae:	855e                	mv	a0,s7
    800016b0:	977ff0ef          	jal	80001026 <walkaddr>
    800016b4:	89aa                	mv	s3,a0
    if(pa0 == 0) {
    800016b6:	e901                	bnez	a0,800016c6 <copyout+0x72>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800016b8:	4601                	li	a2,0
    800016ba:	85a6                	mv	a1,s1
    800016bc:	855e                	mv	a0,s7
    800016be:	f13ff0ef          	jal	800015d0 <vmfault>
    800016c2:	89aa                	mv	s3,a0
    800016c4:	c139                	beqz	a0,8000170a <copyout+0xb6>
    pte = walk(pagetable, va0, 0);
    800016c6:	4601                	li	a2,0
    800016c8:	85a6                	mv	a1,s1
    800016ca:	855e                	mv	a0,s7
    800016cc:	8c1ff0ef          	jal	80000f8c <walk>
    if((*pte & PTE_W) == 0)
    800016d0:	611c                	ld	a5,0(a0)
    800016d2:	8b91                	andi	a5,a5,4
    800016d4:	cf8d                	beqz	a5,8000170e <copyout+0xba>
    n = PGSIZE - (dstva - va0);
    800016d6:	41448933          	sub	s2,s1,s4
    800016da:	9962                	add	s2,s2,s8
    if(n > len)
    800016dc:	fb2af5e3          	bgeu	s5,s2,80001686 <copyout+0x32>
    800016e0:	8956                	mv	s2,s5
    800016e2:	b755                	j	80001686 <copyout+0x32>
  return 0;
    800016e4:	4501                	li	a0,0
    800016e6:	a021                	j	800016ee <copyout+0x9a>
    800016e8:	4501                	li	a0,0
}
    800016ea:	8082                	ret
      return -1;
    800016ec:	557d                	li	a0,-1
}
    800016ee:	60e6                	ld	ra,88(sp)
    800016f0:	6446                	ld	s0,80(sp)
    800016f2:	64a6                	ld	s1,72(sp)
    800016f4:	6906                	ld	s2,64(sp)
    800016f6:	79e2                	ld	s3,56(sp)
    800016f8:	7a42                	ld	s4,48(sp)
    800016fa:	7aa2                	ld	s5,40(sp)
    800016fc:	7b02                	ld	s6,32(sp)
    800016fe:	6be2                	ld	s7,24(sp)
    80001700:	6c42                	ld	s8,16(sp)
    80001702:	6ca2                	ld	s9,8(sp)
    80001704:	6d02                	ld	s10,0(sp)
    80001706:	6125                	addi	sp,sp,96
    80001708:	8082                	ret
        return -1;
    8000170a:	557d                	li	a0,-1
    8000170c:	b7cd                	j	800016ee <copyout+0x9a>
      return -1;
    8000170e:	557d                	li	a0,-1
    80001710:	bff9                	j	800016ee <copyout+0x9a>

0000000080001712 <copyin>:
  while(len > 0){
    80001712:	c6c9                	beqz	a3,8000179c <copyin+0x8a>
{
    80001714:	715d                	addi	sp,sp,-80
    80001716:	e486                	sd	ra,72(sp)
    80001718:	e0a2                	sd	s0,64(sp)
    8000171a:	fc26                	sd	s1,56(sp)
    8000171c:	f84a                	sd	s2,48(sp)
    8000171e:	f44e                	sd	s3,40(sp)
    80001720:	f052                	sd	s4,32(sp)
    80001722:	ec56                	sd	s5,24(sp)
    80001724:	e85a                	sd	s6,16(sp)
    80001726:	e45e                	sd	s7,8(sp)
    80001728:	e062                	sd	s8,0(sp)
    8000172a:	0880                	addi	s0,sp,80
    8000172c:	8baa                	mv	s7,a0
    8000172e:	8aae                	mv	s5,a1
    80001730:	8932                	mv	s2,a2
    80001732:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001734:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001736:	6b05                	lui	s6,0x1
    80001738:	a035                	j	80001764 <copyin+0x52>
    8000173a:	412984b3          	sub	s1,s3,s2
    8000173e:	94da                	add	s1,s1,s6
    if(n > len)
    80001740:	009a7363          	bgeu	s4,s1,80001746 <copyin+0x34>
    80001744:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001746:	413905b3          	sub	a1,s2,s3
    8000174a:	0004861b          	sext.w	a2,s1
    8000174e:	95aa                	add	a1,a1,a0
    80001750:	8556                	mv	a0,s5
    80001752:	e06ff0ef          	jal	80000d58 <memmove>
    len -= n;
    80001756:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000175a:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000175c:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001760:	020a0163          	beqz	s4,80001782 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001764:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001768:	85ce                	mv	a1,s3
    8000176a:	855e                	mv	a0,s7
    8000176c:	8bbff0ef          	jal	80001026 <walkaddr>
    if(pa0 == 0) {
    80001770:	f569                	bnez	a0,8000173a <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001772:	4601                	li	a2,0
    80001774:	85ce                	mv	a1,s3
    80001776:	855e                	mv	a0,s7
    80001778:	e59ff0ef          	jal	800015d0 <vmfault>
    8000177c:	fd5d                	bnez	a0,8000173a <copyin+0x28>
        return -1;
    8000177e:	557d                	li	a0,-1
    80001780:	a011                	j	80001784 <copyin+0x72>
  return 0;
    80001782:	4501                	li	a0,0
}
    80001784:	60a6                	ld	ra,72(sp)
    80001786:	6406                	ld	s0,64(sp)
    80001788:	74e2                	ld	s1,56(sp)
    8000178a:	7942                	ld	s2,48(sp)
    8000178c:	79a2                	ld	s3,40(sp)
    8000178e:	7a02                	ld	s4,32(sp)
    80001790:	6ae2                	ld	s5,24(sp)
    80001792:	6b42                	ld	s6,16(sp)
    80001794:	6ba2                	ld	s7,8(sp)
    80001796:	6c02                	ld	s8,0(sp)
    80001798:	6161                	addi	sp,sp,80
    8000179a:	8082                	ret
  return 0;
    8000179c:	4501                	li	a0,0
}
    8000179e:	8082                	ret

00000000800017a0 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800017a0:	711d                	addi	sp,sp,-96
    800017a2:	ec86                	sd	ra,88(sp)
    800017a4:	e8a2                	sd	s0,80(sp)
    800017a6:	e4a6                	sd	s1,72(sp)
    800017a8:	e0ca                	sd	s2,64(sp)
    800017aa:	fc4e                	sd	s3,56(sp)
    800017ac:	f852                	sd	s4,48(sp)
    800017ae:	f456                	sd	s5,40(sp)
    800017b0:	f05a                	sd	s6,32(sp)
    800017b2:	ec5e                	sd	s7,24(sp)
    800017b4:	e862                	sd	s8,16(sp)
    800017b6:	e466                	sd	s9,8(sp)
    800017b8:	1080                	addi	s0,sp,96
    800017ba:	8aaa                	mv	s5,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800017bc:	0000e497          	auipc	s1,0xe
    800017c0:	5fc48493          	addi	s1,s1,1532 # 8000fdb8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800017c4:	8ca6                	mv	s9,s1
    800017c6:	21a937b7          	lui	a5,0x21a93
    800017ca:	078a                	slli	a5,a5,0x2
    800017cc:	2e178793          	addi	a5,a5,737 # 21a932e1 <_entry-0x5e56cd1f>
    800017d0:	0e2c5937          	lui	s2,0xe2c5
    800017d4:	a6890913          	addi	s2,s2,-1432 # e2c4a68 <_entry-0x71d3b598>
    800017d8:	1902                	slli	s2,s2,0x20
    800017da:	993e                	add	s2,s2,a5
    800017dc:	040009b7          	lui	s3,0x4000
    800017e0:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017e2:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017e4:	4c19                	li	s8,6
    800017e6:	6b85                	lui	s7,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    800017e8:	210b8a13          	addi	s4,s7,528 # 1210 <_entry-0x7fffedf0>
    800017ec:	00057b17          	auipc	s6,0x57
    800017f0:	9ccb0b13          	addi	s6,s6,-1588 # 800581b8 <tickslock>
    char *pa = kalloc();
    800017f4:	b50ff0ef          	jal	80000b44 <kalloc>
    800017f8:	862a                	mv	a2,a0
    if(pa == 0)
    800017fa:	c121                	beqz	a0,8000183a <proc_mapstacks+0x9a>
    uint64 va = KSTACK((int) (p - proc));
    800017fc:	419485b3          	sub	a1,s1,s9
    80001800:	8591                	srai	a1,a1,0x4
    80001802:	032585b3          	mul	a1,a1,s2
    80001806:	05b6                	slli	a1,a1,0xd
    80001808:	6789                	lui	a5,0x2
    8000180a:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000180c:	8762                	mv	a4,s8
    8000180e:	86de                	mv	a3,s7
    80001810:	40b985b3          	sub	a1,s3,a1
    80001814:	8556                	mv	a0,s5
    80001816:	901ff0ef          	jal	80001116 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000181a:	94d2                	add	s1,s1,s4
    8000181c:	fd649ce3          	bne	s1,s6,800017f4 <proc_mapstacks+0x54>
  }
}
    80001820:	60e6                	ld	ra,88(sp)
    80001822:	6446                	ld	s0,80(sp)
    80001824:	64a6                	ld	s1,72(sp)
    80001826:	6906                	ld	s2,64(sp)
    80001828:	79e2                	ld	s3,56(sp)
    8000182a:	7a42                	ld	s4,48(sp)
    8000182c:	7aa2                	ld	s5,40(sp)
    8000182e:	7b02                	ld	s6,32(sp)
    80001830:	6be2                	ld	s7,24(sp)
    80001832:	6c42                	ld	s8,16(sp)
    80001834:	6ca2                	ld	s9,8(sp)
    80001836:	6125                	addi	sp,sp,96
    80001838:	8082                	ret
      panic("kalloc");
    8000183a:	00006517          	auipc	a0,0x6
    8000183e:	91e50513          	addi	a0,a0,-1762 # 80007158 <etext+0x158>
    80001842:	fe3fe0ef          	jal	80000824 <panic>

0000000080001846 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001846:	715d                	addi	sp,sp,-80
    80001848:	e486                	sd	ra,72(sp)
    8000184a:	e0a2                	sd	s0,64(sp)
    8000184c:	fc26                	sd	s1,56(sp)
    8000184e:	f84a                	sd	s2,48(sp)
    80001850:	f44e                	sd	s3,40(sp)
    80001852:	f052                	sd	s4,32(sp)
    80001854:	ec56                	sd	s5,24(sp)
    80001856:	e85a                	sd	s6,16(sp)
    80001858:	e45e                	sd	s7,8(sp)
    8000185a:	0880                	addi	s0,sp,80
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000185c:	00006597          	auipc	a1,0x6
    80001860:	90458593          	addi	a1,a1,-1788 # 80007160 <etext+0x160>
    80001864:	0000e517          	auipc	a0,0xe
    80001868:	12450513          	addi	a0,a0,292 # 8000f988 <pid_lock>
    8000186c:	b32ff0ef          	jal	80000b9e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001870:	00006597          	auipc	a1,0x6
    80001874:	8f858593          	addi	a1,a1,-1800 # 80007168 <etext+0x168>
    80001878:	0000e517          	auipc	a0,0xe
    8000187c:	12850513          	addi	a0,a0,296 # 8000f9a0 <wait_lock>
    80001880:	b1eff0ef          	jal	80000b9e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001884:	0000e497          	auipc	s1,0xe
    80001888:	53448493          	addi	s1,s1,1332 # 8000fdb8 <proc>
      initlock(&p->lock, "proc");
    8000188c:	00006b97          	auipc	s7,0x6
    80001890:	8ecb8b93          	addi	s7,s7,-1812 # 80007178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001894:	8b26                	mv	s6,s1
    80001896:	21a937b7          	lui	a5,0x21a93
    8000189a:	078a                	slli	a5,a5,0x2
    8000189c:	2e178793          	addi	a5,a5,737 # 21a932e1 <_entry-0x5e56cd1f>
    800018a0:	0e2c5937          	lui	s2,0xe2c5
    800018a4:	a6890913          	addi	s2,s2,-1432 # e2c4a68 <_entry-0x71d3b598>
    800018a8:	1902                	slli	s2,s2,0x20
    800018aa:	993e                	add	s2,s2,a5
    800018ac:	040009b7          	lui	s3,0x4000
    800018b0:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018b2:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018b4:	6a05                	lui	s4,0x1
    800018b6:	210a0a13          	addi	s4,s4,528 # 1210 <_entry-0x7fffedf0>
    800018ba:	00057a97          	auipc	s5,0x57
    800018be:	8fea8a93          	addi	s5,s5,-1794 # 800581b8 <tickslock>
      initlock(&p->lock, "proc");
    800018c2:	85de                	mv	a1,s7
    800018c4:	8526                	mv	a0,s1
    800018c6:	ad8ff0ef          	jal	80000b9e <initlock>
      p->state = UNUSED;
    800018ca:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800018ce:	416487b3          	sub	a5,s1,s6
    800018d2:	8791                	srai	a5,a5,0x4
    800018d4:	032787b3          	mul	a5,a5,s2
    800018d8:	07b6                	slli	a5,a5,0xd
    800018da:	6709                	lui	a4,0x2
    800018dc:	9fb9                	addw	a5,a5,a4
    800018de:	40f987b3          	sub	a5,s3,a5
    800018e2:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800018e4:	94d2                	add	s1,s1,s4
    800018e6:	fd549ee3          	bne	s1,s5,800018c2 <procinit+0x7c>
  }
}
    800018ea:	60a6                	ld	ra,72(sp)
    800018ec:	6406                	ld	s0,64(sp)
    800018ee:	74e2                	ld	s1,56(sp)
    800018f0:	7942                	ld	s2,48(sp)
    800018f2:	79a2                	ld	s3,40(sp)
    800018f4:	7a02                	ld	s4,32(sp)
    800018f6:	6ae2                	ld	s5,24(sp)
    800018f8:	6b42                	ld	s6,16(sp)
    800018fa:	6ba2                	ld	s7,8(sp)
    800018fc:	6161                	addi	sp,sp,80
    800018fe:	8082                	ret

0000000080001900 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001900:	1141                	addi	sp,sp,-16
    80001902:	e406                	sd	ra,8(sp)
    80001904:	e022                	sd	s0,0(sp)
    80001906:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001908:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000190a:	2501                	sext.w	a0,a0
    8000190c:	60a2                	ld	ra,8(sp)
    8000190e:	6402                	ld	s0,0(sp)
    80001910:	0141                	addi	sp,sp,16
    80001912:	8082                	ret

0000000080001914 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001914:	1141                	addi	sp,sp,-16
    80001916:	e406                	sd	ra,8(sp)
    80001918:	e022                	sd	s0,0(sp)
    8000191a:	0800                	addi	s0,sp,16
    8000191c:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000191e:	2781                	sext.w	a5,a5
    80001920:	079e                	slli	a5,a5,0x7
  return c;
}
    80001922:	0000e517          	auipc	a0,0xe
    80001926:	09650513          	addi	a0,a0,150 # 8000f9b8 <cpus>
    8000192a:	953e                	add	a0,a0,a5
    8000192c:	60a2                	ld	ra,8(sp)
    8000192e:	6402                	ld	s0,0(sp)
    80001930:	0141                	addi	sp,sp,16
    80001932:	8082                	ret

0000000080001934 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001934:	1101                	addi	sp,sp,-32
    80001936:	ec06                	sd	ra,24(sp)
    80001938:	e822                	sd	s0,16(sp)
    8000193a:	e426                	sd	s1,8(sp)
    8000193c:	1000                	addi	s0,sp,32
  push_off();
    8000193e:	aa6ff0ef          	jal	80000be4 <push_off>
    80001942:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001944:	2781                	sext.w	a5,a5
    80001946:	079e                	slli	a5,a5,0x7
    80001948:	0000e717          	auipc	a4,0xe
    8000194c:	04070713          	addi	a4,a4,64 # 8000f988 <pid_lock>
    80001950:	97ba                	add	a5,a5,a4
    80001952:	7b9c                	ld	a5,48(a5)
    80001954:	84be                	mv	s1,a5
  pop_off();
    80001956:	b16ff0ef          	jal	80000c6c <pop_off>
  return p;
}
    8000195a:	8526                	mv	a0,s1
    8000195c:	60e2                	ld	ra,24(sp)
    8000195e:	6442                	ld	s0,16(sp)
    80001960:	64a2                	ld	s1,8(sp)
    80001962:	6105                	addi	sp,sp,32
    80001964:	8082                	ret

0000000080001966 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001966:	7179                	addi	sp,sp,-48
    80001968:	f406                	sd	ra,40(sp)
    8000196a:	f022                	sd	s0,32(sp)
    8000196c:	ec26                	sd	s1,24(sp)
    8000196e:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001970:	fc5ff0ef          	jal	80001934 <myproc>
    80001974:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001976:	b46ff0ef          	jal	80000cbc <release>

  if (first) {
    8000197a:	00006797          	auipc	a5,0x6
    8000197e:	ed67a783          	lw	a5,-298(a5) # 80007850 <first.1>
    80001982:	cf95                	beqz	a5,800019be <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001984:	4505                	li	a0,1
    80001986:	6ed010ef          	jal	80003872 <fsinit>

    first = 0;
    8000198a:	00006797          	auipc	a5,0x6
    8000198e:	ec07a323          	sw	zero,-314(a5) # 80007850 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001992:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001996:	00005797          	auipc	a5,0x5
    8000199a:	7ea78793          	addi	a5,a5,2026 # 80007180 <etext+0x180>
    8000199e:	fcf43823          	sd	a5,-48(s0)
    800019a2:	fc043c23          	sd	zero,-40(s0)
    800019a6:	fd040593          	addi	a1,s0,-48
    800019aa:	853e                	mv	a0,a5
    800019ac:	04e030ef          	jal	800049fa <kexec>
    800019b0:	6cbc                	ld	a5,88(s1)
    800019b2:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019b4:	6cbc                	ld	a5,88(s1)
    800019b6:	7bb8                	ld	a4,112(a5)
    800019b8:	57fd                	li	a5,-1
    800019ba:	02f70d63          	beq	a4,a5,800019f4 <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800019be:	315000ef          	jal	800024d2 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019c2:	68a8                	ld	a0,80(s1)
    800019c4:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019c6:	04000737          	lui	a4,0x4000
    800019ca:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800019cc:	0732                	slli	a4,a4,0xc
    800019ce:	00004797          	auipc	a5,0x4
    800019d2:	6ce78793          	addi	a5,a5,1742 # 8000609c <userret>
    800019d6:	00004697          	auipc	a3,0x4
    800019da:	62a68693          	addi	a3,a3,1578 # 80006000 <_trampoline>
    800019de:	8f95                	sub	a5,a5,a3
    800019e0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019e2:	577d                	li	a4,-1
    800019e4:	177e                	slli	a4,a4,0x3f
    800019e6:	8d59                	or	a0,a0,a4
    800019e8:	9782                	jalr	a5
}
    800019ea:	70a2                	ld	ra,40(sp)
    800019ec:	7402                	ld	s0,32(sp)
    800019ee:	64e2                	ld	s1,24(sp)
    800019f0:	6145                	addi	sp,sp,48
    800019f2:	8082                	ret
      panic("exec");
    800019f4:	00005517          	auipc	a0,0x5
    800019f8:	79450513          	addi	a0,a0,1940 # 80007188 <etext+0x188>
    800019fc:	e29fe0ef          	jal	80000824 <panic>

0000000080001a00 <allocpid>:
{
    80001a00:	1101                	addi	sp,sp,-32
    80001a02:	ec06                	sd	ra,24(sp)
    80001a04:	e822                	sd	s0,16(sp)
    80001a06:	e426                	sd	s1,8(sp)
    80001a08:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a0a:	0000e517          	auipc	a0,0xe
    80001a0e:	f7e50513          	addi	a0,a0,-130 # 8000f988 <pid_lock>
    80001a12:	a16ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a16:	00006797          	auipc	a5,0x6
    80001a1a:	e3e78793          	addi	a5,a5,-450 # 80007854 <nextpid>
    80001a1e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a20:	0014871b          	addiw	a4,s1,1
    80001a24:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a26:	0000e517          	auipc	a0,0xe
    80001a2a:	f6250513          	addi	a0,a0,-158 # 8000f988 <pid_lock>
    80001a2e:	a8eff0ef          	jal	80000cbc <release>
}
    80001a32:	8526                	mv	a0,s1
    80001a34:	60e2                	ld	ra,24(sp)
    80001a36:	6442                	ld	s0,16(sp)
    80001a38:	64a2                	ld	s1,8(sp)
    80001a3a:	6105                	addi	sp,sp,32
    80001a3c:	8082                	ret

0000000080001a3e <proc_pagetable>:
{
    80001a3e:	1101                	addi	sp,sp,-32
    80001a40:	ec06                	sd	ra,24(sp)
    80001a42:	e822                	sd	s0,16(sp)
    80001a44:	e426                	sd	s1,8(sp)
    80001a46:	e04a                	sd	s2,0(sp)
    80001a48:	1000                	addi	s0,sp,32
    80001a4a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a4c:	fbcff0ef          	jal	80001208 <uvmcreate>
    80001a50:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a52:	cd05                	beqz	a0,80001a8a <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a54:	4729                	li	a4,10
    80001a56:	00004697          	auipc	a3,0x4
    80001a5a:	5aa68693          	addi	a3,a3,1450 # 80006000 <_trampoline>
    80001a5e:	6605                	lui	a2,0x1
    80001a60:	040005b7          	lui	a1,0x4000
    80001a64:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a66:	05b2                	slli	a1,a1,0xc
    80001a68:	df8ff0ef          	jal	80001060 <mappages>
    80001a6c:	02054663          	bltz	a0,80001a98 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a70:	4719                	li	a4,6
    80001a72:	05893683          	ld	a3,88(s2)
    80001a76:	6605                	lui	a2,0x1
    80001a78:	020005b7          	lui	a1,0x2000
    80001a7c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a7e:	05b6                	slli	a1,a1,0xd
    80001a80:	8526                	mv	a0,s1
    80001a82:	ddeff0ef          	jal	80001060 <mappages>
    80001a86:	00054f63          	bltz	a0,80001aa4 <proc_pagetable+0x66>
}
    80001a8a:	8526                	mv	a0,s1
    80001a8c:	60e2                	ld	ra,24(sp)
    80001a8e:	6442                	ld	s0,16(sp)
    80001a90:	64a2                	ld	s1,8(sp)
    80001a92:	6902                	ld	s2,0(sp)
    80001a94:	6105                	addi	sp,sp,32
    80001a96:	8082                	ret
    uvmfree(pagetable, 0);
    80001a98:	4581                	li	a1,0
    80001a9a:	8526                	mv	a0,s1
    80001a9c:	967ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001aa0:	4481                	li	s1,0
    80001aa2:	b7e5                	j	80001a8a <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aa4:	4681                	li	a3,0
    80001aa6:	4605                	li	a2,1
    80001aa8:	040005b7          	lui	a1,0x4000
    80001aac:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aae:	05b2                	slli	a1,a1,0xc
    80001ab0:	8526                	mv	a0,s1
    80001ab2:	f7cff0ef          	jal	8000122e <uvmunmap>
    uvmfree(pagetable, 0);
    80001ab6:	4581                	li	a1,0
    80001ab8:	8526                	mv	a0,s1
    80001aba:	949ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001abe:	4481                	li	s1,0
    80001ac0:	b7e9                	j	80001a8a <proc_pagetable+0x4c>

0000000080001ac2 <proc_freepagetable>:
{
    80001ac2:	1101                	addi	sp,sp,-32
    80001ac4:	ec06                	sd	ra,24(sp)
    80001ac6:	e822                	sd	s0,16(sp)
    80001ac8:	e426                	sd	s1,8(sp)
    80001aca:	e04a                	sd	s2,0(sp)
    80001acc:	1000                	addi	s0,sp,32
    80001ace:	84aa                	mv	s1,a0
    80001ad0:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ad2:	4681                	li	a3,0
    80001ad4:	4605                	li	a2,1
    80001ad6:	040005b7          	lui	a1,0x4000
    80001ada:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001adc:	05b2                	slli	a1,a1,0xc
    80001ade:	f50ff0ef          	jal	8000122e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ae2:	4681                	li	a3,0
    80001ae4:	4605                	li	a2,1
    80001ae6:	020005b7          	lui	a1,0x2000
    80001aea:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001aec:	05b6                	slli	a1,a1,0xd
    80001aee:	8526                	mv	a0,s1
    80001af0:	f3eff0ef          	jal	8000122e <uvmunmap>
  uvmfree(pagetable, sz);
    80001af4:	85ca                	mv	a1,s2
    80001af6:	8526                	mv	a0,s1
    80001af8:	90bff0ef          	jal	80001402 <uvmfree>
}
    80001afc:	60e2                	ld	ra,24(sp)
    80001afe:	6442                	ld	s0,16(sp)
    80001b00:	64a2                	ld	s1,8(sp)
    80001b02:	6902                	ld	s2,0(sp)
    80001b04:	6105                	addi	sp,sp,32
    80001b06:	8082                	ret

0000000080001b08 <freeproc>:
{
    80001b08:	1101                	addi	sp,sp,-32
    80001b0a:	ec06                	sd	ra,24(sp)
    80001b0c:	e822                	sd	s0,16(sp)
    80001b0e:	e426                	sd	s1,8(sp)
    80001b10:	1000                	addi	s0,sp,32
    80001b12:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b14:	6d28                	ld	a0,88(a0)
    80001b16:	c119                	beqz	a0,80001b1c <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001b18:	f45fe0ef          	jal	80000a5c <kfree>
  p->trapframe = 0;
    80001b1c:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b20:	68a8                	ld	a0,80(s1)
    80001b22:	c501                	beqz	a0,80001b2a <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b24:	64ac                	ld	a1,72(s1)
    80001b26:	f9dff0ef          	jal	80001ac2 <proc_freepagetable>
  p->pagetable = 0;
    80001b2a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b2e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b32:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b36:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b3a:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b3e:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b42:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b46:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b4a:	0004ac23          	sw	zero,24(s1)
}
    80001b4e:	60e2                	ld	ra,24(sp)
    80001b50:	6442                	ld	s0,16(sp)
    80001b52:	64a2                	ld	s1,8(sp)
    80001b54:	6105                	addi	sp,sp,32
    80001b56:	8082                	ret

0000000080001b58 <allocproc>:
{
    80001b58:	7179                	addi	sp,sp,-48
    80001b5a:	f406                	sd	ra,40(sp)
    80001b5c:	f022                	sd	s0,32(sp)
    80001b5e:	ec26                	sd	s1,24(sp)
    80001b60:	e84a                	sd	s2,16(sp)
    80001b62:	e44e                	sd	s3,8(sp)
    80001b64:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b66:	0000e497          	auipc	s1,0xe
    80001b6a:	25248493          	addi	s1,s1,594 # 8000fdb8 <proc>
    80001b6e:	6905                	lui	s2,0x1
    80001b70:	21090913          	addi	s2,s2,528 # 1210 <_entry-0x7fffedf0>
    80001b74:	00056997          	auipc	s3,0x56
    80001b78:	64498993          	addi	s3,s3,1604 # 800581b8 <tickslock>
    acquire(&p->lock);
    80001b7c:	8526                	mv	a0,s1
    80001b7e:	8aaff0ef          	jal	80000c28 <acquire>
    if(p->state == UNUSED) {
    80001b82:	4c9c                	lw	a5,24(s1)
    80001b84:	cb89                	beqz	a5,80001b96 <allocproc+0x3e>
      release(&p->lock);
    80001b86:	8526                	mv	a0,s1
    80001b88:	934ff0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b8c:	94ca                	add	s1,s1,s2
    80001b8e:	ff3497e3          	bne	s1,s3,80001b7c <allocproc+0x24>
  return 0;
    80001b92:	4481                	li	s1,0
    80001b94:	a09d                	j	80001bfa <allocproc+0xa2>
  p->pid = allocpid();
    80001b96:	e6bff0ef          	jal	80001a00 <allocpid>
    80001b9a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b9c:	4785                	li	a5,1
    80001b9e:	cc9c                	sw	a5,24(s1)
  initlock(&p->mq.lock, "msgqueue");
    80001ba0:	00005597          	auipc	a1,0x5
    80001ba4:	5f058593          	addi	a1,a1,1520 # 80007190 <etext+0x190>
    80001ba8:	6505                	lui	a0,0x1
    80001baa:	1f850513          	addi	a0,a0,504 # 11f8 <_entry-0x7fffee08>
    80001bae:	9526                	add	a0,a0,s1
    80001bb0:	feffe0ef          	jal	80000b9e <initlock>
  p->mq.head  = 0;
    80001bb4:	6785                	lui	a5,0x1
    80001bb6:	97a6                	add	a5,a5,s1
    80001bb8:	1e07a423          	sw	zero,488(a5) # 11e8 <_entry-0x7fffee18>
  p->mq.tail  = 0;
    80001bbc:	1e07a623          	sw	zero,492(a5)
  p->mq.count = 0;
    80001bc0:	1e07a823          	sw	zero,496(a5)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001bc4:	f81fe0ef          	jal	80000b44 <kalloc>
    80001bc8:	892a                	mv	s2,a0
    80001bca:	eca8                	sd	a0,88(s1)
    80001bcc:	cd1d                	beqz	a0,80001c0a <allocproc+0xb2>
  p->pagetable = proc_pagetable(p);
    80001bce:	8526                	mv	a0,s1
    80001bd0:	e6fff0ef          	jal	80001a3e <proc_pagetable>
    80001bd4:	892a                	mv	s2,a0
    80001bd6:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001bd8:	c129                	beqz	a0,80001c1a <allocproc+0xc2>
  memset(&p->context, 0, sizeof(p->context));
    80001bda:	07000613          	li	a2,112
    80001bde:	4581                	li	a1,0
    80001be0:	06048513          	addi	a0,s1,96
    80001be4:	914ff0ef          	jal	80000cf8 <memset>
  p->context.ra = (uint64)forkret;
    80001be8:	00000797          	auipc	a5,0x0
    80001bec:	d7e78793          	addi	a5,a5,-642 # 80001966 <forkret>
    80001bf0:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001bf2:	60bc                	ld	a5,64(s1)
    80001bf4:	6705                	lui	a4,0x1
    80001bf6:	97ba                	add	a5,a5,a4
    80001bf8:	f4bc                	sd	a5,104(s1)
}
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	70a2                	ld	ra,40(sp)
    80001bfe:	7402                	ld	s0,32(sp)
    80001c00:	64e2                	ld	s1,24(sp)
    80001c02:	6942                	ld	s2,16(sp)
    80001c04:	69a2                	ld	s3,8(sp)
    80001c06:	6145                	addi	sp,sp,48
    80001c08:	8082                	ret
    freeproc(p);
    80001c0a:	8526                	mv	a0,s1
    80001c0c:	efdff0ef          	jal	80001b08 <freeproc>
    release(&p->lock);
    80001c10:	8526                	mv	a0,s1
    80001c12:	8aaff0ef          	jal	80000cbc <release>
    return 0;
    80001c16:	84ca                	mv	s1,s2
    80001c18:	b7cd                	j	80001bfa <allocproc+0xa2>
    freeproc(p);
    80001c1a:	8526                	mv	a0,s1
    80001c1c:	eedff0ef          	jal	80001b08 <freeproc>
    release(&p->lock);
    80001c20:	8526                	mv	a0,s1
    80001c22:	89aff0ef          	jal	80000cbc <release>
    return 0;
    80001c26:	84ca                	mv	s1,s2
    80001c28:	bfc9                	j	80001bfa <allocproc+0xa2>

0000000080001c2a <userinit>:
{
    80001c2a:	1101                	addi	sp,sp,-32
    80001c2c:	ec06                	sd	ra,24(sp)
    80001c2e:	e822                	sd	s0,16(sp)
    80001c30:	e426                	sd	s1,8(sp)
    80001c32:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c34:	f25ff0ef          	jal	80001b58 <allocproc>
    80001c38:	84aa                	mv	s1,a0
  initproc = p;
    80001c3a:	00006797          	auipc	a5,0x6
    80001c3e:	c4a7b323          	sd	a0,-954(a5) # 80007880 <initproc>
  p->cwd = namei("/");
    80001c42:	00005517          	auipc	a0,0x5
    80001c46:	55e50513          	addi	a0,a0,1374 # 800071a0 <etext+0x1a0>
    80001c4a:	162020ef          	jal	80003dac <namei>
    80001c4e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c52:	478d                	li	a5,3
    80001c54:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c56:	8526                	mv	a0,s1
    80001c58:	864ff0ef          	jal	80000cbc <release>
}
    80001c5c:	60e2                	ld	ra,24(sp)
    80001c5e:	6442                	ld	s0,16(sp)
    80001c60:	64a2                	ld	s1,8(sp)
    80001c62:	6105                	addi	sp,sp,32
    80001c64:	8082                	ret

0000000080001c66 <growproc>:
{
    80001c66:	1101                	addi	sp,sp,-32
    80001c68:	ec06                	sd	ra,24(sp)
    80001c6a:	e822                	sd	s0,16(sp)
    80001c6c:	e426                	sd	s1,8(sp)
    80001c6e:	e04a                	sd	s2,0(sp)
    80001c70:	1000                	addi	s0,sp,32
    80001c72:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c74:	cc1ff0ef          	jal	80001934 <myproc>
    80001c78:	892a                	mv	s2,a0
  sz = p->sz;
    80001c7a:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001c7c:	02905963          	blez	s1,80001cae <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001c80:	00b48633          	add	a2,s1,a1
    80001c84:	020007b7          	lui	a5,0x2000
    80001c88:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c8a:	07b6                	slli	a5,a5,0xd
    80001c8c:	02c7ea63          	bltu	a5,a2,80001cc0 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c90:	4691                	li	a3,4
    80001c92:	6928                	ld	a0,80(a0)
    80001c94:	e68ff0ef          	jal	800012fc <uvmalloc>
    80001c98:	85aa                	mv	a1,a0
    80001c9a:	c50d                	beqz	a0,80001cc4 <growproc+0x5e>
  p->sz = sz;
    80001c9c:	04b93423          	sd	a1,72(s2)
  return 0;
    80001ca0:	4501                	li	a0,0
}
    80001ca2:	60e2                	ld	ra,24(sp)
    80001ca4:	6442                	ld	s0,16(sp)
    80001ca6:	64a2                	ld	s1,8(sp)
    80001ca8:	6902                	ld	s2,0(sp)
    80001caa:	6105                	addi	sp,sp,32
    80001cac:	8082                	ret
  } else if(n < 0){
    80001cae:	fe04d7e3          	bgez	s1,80001c9c <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001cb2:	00b48633          	add	a2,s1,a1
    80001cb6:	6928                	ld	a0,80(a0)
    80001cb8:	e00ff0ef          	jal	800012b8 <uvmdealloc>
    80001cbc:	85aa                	mv	a1,a0
    80001cbe:	bff9                	j	80001c9c <growproc+0x36>
      return -1;
    80001cc0:	557d                	li	a0,-1
    80001cc2:	b7c5                	j	80001ca2 <growproc+0x3c>
      return -1;
    80001cc4:	557d                	li	a0,-1
    80001cc6:	bff1                	j	80001ca2 <growproc+0x3c>

0000000080001cc8 <kfork>:
{
    80001cc8:	7139                	addi	sp,sp,-64
    80001cca:	fc06                	sd	ra,56(sp)
    80001ccc:	f822                	sd	s0,48(sp)
    80001cce:	f426                	sd	s1,40(sp)
    80001cd0:	e456                	sd	s5,8(sp)
    80001cd2:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001cd4:	c61ff0ef          	jal	80001934 <myproc>
    80001cd8:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001cda:	e7fff0ef          	jal	80001b58 <allocproc>
    80001cde:	0e050a63          	beqz	a0,80001dd2 <kfork+0x10a>
    80001ce2:	e852                	sd	s4,16(sp)
    80001ce4:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001ce6:	048ab603          	ld	a2,72(s5)
    80001cea:	692c                	ld	a1,80(a0)
    80001cec:	050ab503          	ld	a0,80(s5)
    80001cf0:	f44ff0ef          	jal	80001434 <uvmcopy>
    80001cf4:	04054863          	bltz	a0,80001d44 <kfork+0x7c>
    80001cf8:	f04a                	sd	s2,32(sp)
    80001cfa:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001cfc:	048ab783          	ld	a5,72(s5)
    80001d00:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001d04:	058ab683          	ld	a3,88(s5)
    80001d08:	87b6                	mv	a5,a3
    80001d0a:	058a3703          	ld	a4,88(s4)
    80001d0e:	12068693          	addi	a3,a3,288
    80001d12:	6388                	ld	a0,0(a5)
    80001d14:	678c                	ld	a1,8(a5)
    80001d16:	6b90                	ld	a2,16(a5)
    80001d18:	e308                	sd	a0,0(a4)
    80001d1a:	e70c                	sd	a1,8(a4)
    80001d1c:	eb10                	sd	a2,16(a4)
    80001d1e:	6f90                	ld	a2,24(a5)
    80001d20:	ef10                	sd	a2,24(a4)
    80001d22:	02078793          	addi	a5,a5,32
    80001d26:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d2a:	fed794e3          	bne	a5,a3,80001d12 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d2e:	058a3783          	ld	a5,88(s4)
    80001d32:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001d36:	0d0a8493          	addi	s1,s5,208
    80001d3a:	0d0a0913          	addi	s2,s4,208
    80001d3e:	150a8993          	addi	s3,s5,336
    80001d42:	a831                	j	80001d5e <kfork+0x96>
    freeproc(np);
    80001d44:	8552                	mv	a0,s4
    80001d46:	dc3ff0ef          	jal	80001b08 <freeproc>
    release(&np->lock);
    80001d4a:	8552                	mv	a0,s4
    80001d4c:	f71fe0ef          	jal	80000cbc <release>
    return -1;
    80001d50:	54fd                	li	s1,-1
    80001d52:	6a42                	ld	s4,16(sp)
    80001d54:	a885                	j	80001dc4 <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001d56:	04a1                	addi	s1,s1,8
    80001d58:	0921                	addi	s2,s2,8
    80001d5a:	01348963          	beq	s1,s3,80001d6c <kfork+0xa4>
    if(p->ofile[i])
    80001d5e:	6088                	ld	a0,0(s1)
    80001d60:	d97d                	beqz	a0,80001d56 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d62:	606020ef          	jal	80004368 <filedup>
    80001d66:	00a93023          	sd	a0,0(s2)
    80001d6a:	b7f5                	j	80001d56 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d6c:	150ab503          	ld	a0,336(s5)
    80001d70:	7d8010ef          	jal	80003548 <idup>
    80001d74:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d78:	4641                	li	a2,16
    80001d7a:	158a8593          	addi	a1,s5,344
    80001d7e:	158a0513          	addi	a0,s4,344
    80001d82:	8caff0ef          	jal	80000e4c <safestrcpy>
  pid = np->pid;
    80001d86:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d8a:	8552                	mv	a0,s4
    80001d8c:	f31fe0ef          	jal	80000cbc <release>
  acquire(&wait_lock);
    80001d90:	0000e517          	auipc	a0,0xe
    80001d94:	c1050513          	addi	a0,a0,-1008 # 8000f9a0 <wait_lock>
    80001d98:	e91fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001d9c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001da0:	0000e517          	auipc	a0,0xe
    80001da4:	c0050513          	addi	a0,a0,-1024 # 8000f9a0 <wait_lock>
    80001da8:	f15fe0ef          	jal	80000cbc <release>
  acquire(&np->lock);
    80001dac:	8552                	mv	a0,s4
    80001dae:	e7bfe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001db2:	478d                	li	a5,3
    80001db4:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001db8:	8552                	mv	a0,s4
    80001dba:	f03fe0ef          	jal	80000cbc <release>
  return pid;
    80001dbe:	7902                	ld	s2,32(sp)
    80001dc0:	69e2                	ld	s3,24(sp)
    80001dc2:	6a42                	ld	s4,16(sp)
}
    80001dc4:	8526                	mv	a0,s1
    80001dc6:	70e2                	ld	ra,56(sp)
    80001dc8:	7442                	ld	s0,48(sp)
    80001dca:	74a2                	ld	s1,40(sp)
    80001dcc:	6aa2                	ld	s5,8(sp)
    80001dce:	6121                	addi	sp,sp,64
    80001dd0:	8082                	ret
    return -1;
    80001dd2:	54fd                	li	s1,-1
    80001dd4:	bfc5                	j	80001dc4 <kfork+0xfc>

0000000080001dd6 <scheduler>:
{
    80001dd6:	715d                	addi	sp,sp,-80
    80001dd8:	e486                	sd	ra,72(sp)
    80001dda:	e0a2                	sd	s0,64(sp)
    80001ddc:	fc26                	sd	s1,56(sp)
    80001dde:	f84a                	sd	s2,48(sp)
    80001de0:	f44e                	sd	s3,40(sp)
    80001de2:	f052                	sd	s4,32(sp)
    80001de4:	ec56                	sd	s5,24(sp)
    80001de6:	e85a                	sd	s6,16(sp)
    80001de8:	e45e                	sd	s7,8(sp)
    80001dea:	e062                	sd	s8,0(sp)
    80001dec:	0880                	addi	s0,sp,80
    80001dee:	8792                	mv	a5,tp
  int id = r_tp();
    80001df0:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001df2:	00779b13          	slli	s6,a5,0x7
    80001df6:	0000e717          	auipc	a4,0xe
    80001dfa:	b9270713          	addi	a4,a4,-1134 # 8000f988 <pid_lock>
    80001dfe:	975a                	add	a4,a4,s6
    80001e00:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001e04:	0000e717          	auipc	a4,0xe
    80001e08:	bbc70713          	addi	a4,a4,-1092 # 8000f9c0 <cpus+0x8>
    80001e0c:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001e0e:	4c11                	li	s8,4
        c->proc = p;
    80001e10:	079e                	slli	a5,a5,0x7
    80001e12:	0000ea17          	auipc	s4,0xe
    80001e16:	b76a0a13          	addi	s4,s4,-1162 # 8000f988 <pid_lock>
    80001e1a:	9a3e                	add	s4,s4,a5
        found = 1;
    80001e1c:	4b85                	li	s7,1
    80001e1e:	a091                	j	80001e62 <scheduler+0x8c>
      release(&p->lock);
    80001e20:	8526                	mv	a0,s1
    80001e22:	e9bfe0ef          	jal	80000cbc <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e26:	94ca                	add	s1,s1,s2
    80001e28:	00056797          	auipc	a5,0x56
    80001e2c:	39078793          	addi	a5,a5,912 # 800581b8 <tickslock>
    80001e30:	02f48563          	beq	s1,a5,80001e5a <scheduler+0x84>
      acquire(&p->lock);
    80001e34:	8526                	mv	a0,s1
    80001e36:	df3fe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE) {
    80001e3a:	4c9c                	lw	a5,24(s1)
    80001e3c:	ff3792e3          	bne	a5,s3,80001e20 <scheduler+0x4a>
        p->state = RUNNING;
    80001e40:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001e44:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001e48:	06048593          	addi	a1,s1,96
    80001e4c:	855a                	mv	a0,s6
    80001e4e:	5da000ef          	jal	80002428 <swtch>
        c->proc = 0;
    80001e52:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001e56:	8ade                	mv	s5,s7
    80001e58:	b7e1                	j	80001e20 <scheduler+0x4a>
    if(found == 0) {
    80001e5a:	000a9463          	bnez	s5,80001e62 <scheduler+0x8c>
      asm volatile("wfi");
    80001e5e:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e62:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e66:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e6a:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e6e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001e72:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e74:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001e78:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e7a:	0000e497          	auipc	s1,0xe
    80001e7e:	f3e48493          	addi	s1,s1,-194 # 8000fdb8 <proc>
      if(p->state == RUNNABLE) {
    80001e82:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e84:	6905                	lui	s2,0x1
    80001e86:	21090913          	addi	s2,s2,528 # 1210 <_entry-0x7fffedf0>
    80001e8a:	b76d                	j	80001e34 <scheduler+0x5e>

0000000080001e8c <sched>:
{
    80001e8c:	7179                	addi	sp,sp,-48
    80001e8e:	f406                	sd	ra,40(sp)
    80001e90:	f022                	sd	s0,32(sp)
    80001e92:	ec26                	sd	s1,24(sp)
    80001e94:	e84a                	sd	s2,16(sp)
    80001e96:	e44e                	sd	s3,8(sp)
    80001e98:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e9a:	a9bff0ef          	jal	80001934 <myproc>
    80001e9e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001ea0:	d19fe0ef          	jal	80000bb8 <holding>
    80001ea4:	c935                	beqz	a0,80001f18 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ea6:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001ea8:	2781                	sext.w	a5,a5
    80001eaa:	079e                	slli	a5,a5,0x7
    80001eac:	0000e717          	auipc	a4,0xe
    80001eb0:	adc70713          	addi	a4,a4,-1316 # 8000f988 <pid_lock>
    80001eb4:	97ba                	add	a5,a5,a4
    80001eb6:	0a87a703          	lw	a4,168(a5)
    80001eba:	4785                	li	a5,1
    80001ebc:	06f71463          	bne	a4,a5,80001f24 <sched+0x98>
  if(p->state == RUNNING)
    80001ec0:	4c98                	lw	a4,24(s1)
    80001ec2:	4791                	li	a5,4
    80001ec4:	06f70663          	beq	a4,a5,80001f30 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ec8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001ecc:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001ece:	e7bd                	bnez	a5,80001f3c <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ed0:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001ed2:	0000e917          	auipc	s2,0xe
    80001ed6:	ab690913          	addi	s2,s2,-1354 # 8000f988 <pid_lock>
    80001eda:	2781                	sext.w	a5,a5
    80001edc:	079e                	slli	a5,a5,0x7
    80001ede:	97ca                	add	a5,a5,s2
    80001ee0:	0ac7a983          	lw	s3,172(a5)
    80001ee4:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001ee6:	2781                	sext.w	a5,a5
    80001ee8:	079e                	slli	a5,a5,0x7
    80001eea:	07a1                	addi	a5,a5,8
    80001eec:	0000e597          	auipc	a1,0xe
    80001ef0:	acc58593          	addi	a1,a1,-1332 # 8000f9b8 <cpus>
    80001ef4:	95be                	add	a1,a1,a5
    80001ef6:	06048513          	addi	a0,s1,96
    80001efa:	52e000ef          	jal	80002428 <swtch>
    80001efe:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f00:	2781                	sext.w	a5,a5
    80001f02:	079e                	slli	a5,a5,0x7
    80001f04:	993e                	add	s2,s2,a5
    80001f06:	0b392623          	sw	s3,172(s2)
}
    80001f0a:	70a2                	ld	ra,40(sp)
    80001f0c:	7402                	ld	s0,32(sp)
    80001f0e:	64e2                	ld	s1,24(sp)
    80001f10:	6942                	ld	s2,16(sp)
    80001f12:	69a2                	ld	s3,8(sp)
    80001f14:	6145                	addi	sp,sp,48
    80001f16:	8082                	ret
    panic("sched p->lock");
    80001f18:	00005517          	auipc	a0,0x5
    80001f1c:	29050513          	addi	a0,a0,656 # 800071a8 <etext+0x1a8>
    80001f20:	905fe0ef          	jal	80000824 <panic>
    panic("sched locks");
    80001f24:	00005517          	auipc	a0,0x5
    80001f28:	29450513          	addi	a0,a0,660 # 800071b8 <etext+0x1b8>
    80001f2c:	8f9fe0ef          	jal	80000824 <panic>
    panic("sched RUNNING");
    80001f30:	00005517          	auipc	a0,0x5
    80001f34:	29850513          	addi	a0,a0,664 # 800071c8 <etext+0x1c8>
    80001f38:	8edfe0ef          	jal	80000824 <panic>
    panic("sched interruptible");
    80001f3c:	00005517          	auipc	a0,0x5
    80001f40:	29c50513          	addi	a0,a0,668 # 800071d8 <etext+0x1d8>
    80001f44:	8e1fe0ef          	jal	80000824 <panic>

0000000080001f48 <yield>:
{
    80001f48:	1101                	addi	sp,sp,-32
    80001f4a:	ec06                	sd	ra,24(sp)
    80001f4c:	e822                	sd	s0,16(sp)
    80001f4e:	e426                	sd	s1,8(sp)
    80001f50:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f52:	9e3ff0ef          	jal	80001934 <myproc>
    80001f56:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f58:	cd1fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80001f5c:	478d                	li	a5,3
    80001f5e:	cc9c                	sw	a5,24(s1)
  sched();
    80001f60:	f2dff0ef          	jal	80001e8c <sched>
  release(&p->lock);
    80001f64:	8526                	mv	a0,s1
    80001f66:	d57fe0ef          	jal	80000cbc <release>
}
    80001f6a:	60e2                	ld	ra,24(sp)
    80001f6c:	6442                	ld	s0,16(sp)
    80001f6e:	64a2                	ld	s1,8(sp)
    80001f70:	6105                	addi	sp,sp,32
    80001f72:	8082                	ret

0000000080001f74 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001f74:	7179                	addi	sp,sp,-48
    80001f76:	f406                	sd	ra,40(sp)
    80001f78:	f022                	sd	s0,32(sp)
    80001f7a:	ec26                	sd	s1,24(sp)
    80001f7c:	e84a                	sd	s2,16(sp)
    80001f7e:	e44e                	sd	s3,8(sp)
    80001f80:	1800                	addi	s0,sp,48
    80001f82:	89aa                	mv	s3,a0
    80001f84:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f86:	9afff0ef          	jal	80001934 <myproc>
    80001f8a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001f8c:	c9dfe0ef          	jal	80000c28 <acquire>
  release(lk);
    80001f90:	854a                	mv	a0,s2
    80001f92:	d2bfe0ef          	jal	80000cbc <release>

  // Go to sleep.
  p->chan = chan;
    80001f96:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f9a:	4789                	li	a5,2
    80001f9c:	cc9c                	sw	a5,24(s1)

  sched();
    80001f9e:	eefff0ef          	jal	80001e8c <sched>

  // Tidy up.
  p->chan = 0;
    80001fa2:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001fa6:	8526                	mv	a0,s1
    80001fa8:	d15fe0ef          	jal	80000cbc <release>
  acquire(lk);
    80001fac:	854a                	mv	a0,s2
    80001fae:	c7bfe0ef          	jal	80000c28 <acquire>
}
    80001fb2:	70a2                	ld	ra,40(sp)
    80001fb4:	7402                	ld	s0,32(sp)
    80001fb6:	64e2                	ld	s1,24(sp)
    80001fb8:	6942                	ld	s2,16(sp)
    80001fba:	69a2                	ld	s3,8(sp)
    80001fbc:	6145                	addi	sp,sp,48
    80001fbe:	8082                	ret

0000000080001fc0 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001fc0:	7139                	addi	sp,sp,-64
    80001fc2:	fc06                	sd	ra,56(sp)
    80001fc4:	f822                	sd	s0,48(sp)
    80001fc6:	f426                	sd	s1,40(sp)
    80001fc8:	f04a                	sd	s2,32(sp)
    80001fca:	ec4e                	sd	s3,24(sp)
    80001fcc:	e852                	sd	s4,16(sp)
    80001fce:	e456                	sd	s5,8(sp)
    80001fd0:	e05a                	sd	s6,0(sp)
    80001fd2:	0080                	addi	s0,sp,64
    80001fd4:	8aaa                	mv	s5,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001fd6:	0000e497          	auipc	s1,0xe
    80001fda:	de248493          	addi	s1,s1,-542 # 8000fdb8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001fde:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80001fe0:	4b0d                	li	s6,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fe2:	6905                	lui	s2,0x1
    80001fe4:	21090913          	addi	s2,s2,528 # 1210 <_entry-0x7fffedf0>
    80001fe8:	00056997          	auipc	s3,0x56
    80001fec:	1d098993          	addi	s3,s3,464 # 800581b8 <tickslock>
    80001ff0:	a039                	j	80001ffe <wakeup+0x3e>
      }
      release(&p->lock);
    80001ff2:	8526                	mv	a0,s1
    80001ff4:	cc9fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ff8:	94ca                	add	s1,s1,s2
    80001ffa:	03348263          	beq	s1,s3,8000201e <wakeup+0x5e>
    if(p != myproc()){
    80001ffe:	937ff0ef          	jal	80001934 <myproc>
    80002002:	fe950be3          	beq	a0,s1,80001ff8 <wakeup+0x38>
      acquire(&p->lock);
    80002006:	8526                	mv	a0,s1
    80002008:	c21fe0ef          	jal	80000c28 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000200c:	4c9c                	lw	a5,24(s1)
    8000200e:	ff4792e3          	bne	a5,s4,80001ff2 <wakeup+0x32>
    80002012:	709c                	ld	a5,32(s1)
    80002014:	fd579fe3          	bne	a5,s5,80001ff2 <wakeup+0x32>
        p->state = RUNNABLE;
    80002018:	0164ac23          	sw	s6,24(s1)
    8000201c:	bfd9                	j	80001ff2 <wakeup+0x32>
    }
  }
}
    8000201e:	70e2                	ld	ra,56(sp)
    80002020:	7442                	ld	s0,48(sp)
    80002022:	74a2                	ld	s1,40(sp)
    80002024:	7902                	ld	s2,32(sp)
    80002026:	69e2                	ld	s3,24(sp)
    80002028:	6a42                	ld	s4,16(sp)
    8000202a:	6aa2                	ld	s5,8(sp)
    8000202c:	6b02                	ld	s6,0(sp)
    8000202e:	6121                	addi	sp,sp,64
    80002030:	8082                	ret

0000000080002032 <reparent>:
{
    80002032:	7139                	addi	sp,sp,-64
    80002034:	fc06                	sd	ra,56(sp)
    80002036:	f822                	sd	s0,48(sp)
    80002038:	f426                	sd	s1,40(sp)
    8000203a:	f04a                	sd	s2,32(sp)
    8000203c:	ec4e                	sd	s3,24(sp)
    8000203e:	e852                	sd	s4,16(sp)
    80002040:	e456                	sd	s5,8(sp)
    80002042:	0080                	addi	s0,sp,64
    80002044:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002046:	0000e497          	auipc	s1,0xe
    8000204a:	d7248493          	addi	s1,s1,-654 # 8000fdb8 <proc>
      pp->parent = initproc;
    8000204e:	00006a97          	auipc	s5,0x6
    80002052:	832a8a93          	addi	s5,s5,-1998 # 80007880 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002056:	6905                	lui	s2,0x1
    80002058:	21090913          	addi	s2,s2,528 # 1210 <_entry-0x7fffedf0>
    8000205c:	00056a17          	auipc	s4,0x56
    80002060:	15ca0a13          	addi	s4,s4,348 # 800581b8 <tickslock>
    80002064:	a021                	j	8000206c <reparent+0x3a>
    80002066:	94ca                	add	s1,s1,s2
    80002068:	01448b63          	beq	s1,s4,8000207e <reparent+0x4c>
    if(pp->parent == p){
    8000206c:	7c9c                	ld	a5,56(s1)
    8000206e:	ff379ce3          	bne	a5,s3,80002066 <reparent+0x34>
      pp->parent = initproc;
    80002072:	000ab503          	ld	a0,0(s5)
    80002076:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002078:	f49ff0ef          	jal	80001fc0 <wakeup>
    8000207c:	b7ed                	j	80002066 <reparent+0x34>
}
    8000207e:	70e2                	ld	ra,56(sp)
    80002080:	7442                	ld	s0,48(sp)
    80002082:	74a2                	ld	s1,40(sp)
    80002084:	7902                	ld	s2,32(sp)
    80002086:	69e2                	ld	s3,24(sp)
    80002088:	6a42                	ld	s4,16(sp)
    8000208a:	6aa2                	ld	s5,8(sp)
    8000208c:	6121                	addi	sp,sp,64
    8000208e:	8082                	ret

0000000080002090 <kexit>:
{
    80002090:	7179                	addi	sp,sp,-48
    80002092:	f406                	sd	ra,40(sp)
    80002094:	f022                	sd	s0,32(sp)
    80002096:	ec26                	sd	s1,24(sp)
    80002098:	e84a                	sd	s2,16(sp)
    8000209a:	e44e                	sd	s3,8(sp)
    8000209c:	e052                	sd	s4,0(sp)
    8000209e:	1800                	addi	s0,sp,48
    800020a0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020a2:	893ff0ef          	jal	80001934 <myproc>
    800020a6:	89aa                	mv	s3,a0
  if(p == initproc)
    800020a8:	00005797          	auipc	a5,0x5
    800020ac:	7d87b783          	ld	a5,2008(a5) # 80007880 <initproc>
    800020b0:	0d050493          	addi	s1,a0,208
    800020b4:	15050913          	addi	s2,a0,336
    800020b8:	00a79b63          	bne	a5,a0,800020ce <kexit+0x3e>
    panic("init exiting");
    800020bc:	00005517          	auipc	a0,0x5
    800020c0:	13450513          	addi	a0,a0,308 # 800071f0 <etext+0x1f0>
    800020c4:	f60fe0ef          	jal	80000824 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    800020c8:	04a1                	addi	s1,s1,8
    800020ca:	01248963          	beq	s1,s2,800020dc <kexit+0x4c>
    if(p->ofile[fd]){
    800020ce:	6088                	ld	a0,0(s1)
    800020d0:	dd65                	beqz	a0,800020c8 <kexit+0x38>
      fileclose(f);
    800020d2:	2dc020ef          	jal	800043ae <fileclose>
      p->ofile[fd] = 0;
    800020d6:	0004b023          	sd	zero,0(s1)
    800020da:	b7fd                	j	800020c8 <kexit+0x38>
  begin_op();
    800020dc:	6af010ef          	jal	80003f8a <begin_op>
  iput(p->cwd);
    800020e0:	1509b503          	ld	a0,336(s3)
    800020e4:	61c010ef          	jal	80003700 <iput>
  end_op();
    800020e8:	713010ef          	jal	80003ffa <end_op>
  p->cwd = 0;
    800020ec:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800020f0:	0000e517          	auipc	a0,0xe
    800020f4:	8b050513          	addi	a0,a0,-1872 # 8000f9a0 <wait_lock>
    800020f8:	b31fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    800020fc:	854e                	mv	a0,s3
    800020fe:	f35ff0ef          	jal	80002032 <reparent>
  wakeup(p->parent);
    80002102:	0389b503          	ld	a0,56(s3)
    80002106:	ebbff0ef          	jal	80001fc0 <wakeup>
  acquire(&p->lock);
    8000210a:	854e                	mv	a0,s3
    8000210c:	b1dfe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    80002110:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002114:	4795                	li	a5,5
    80002116:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000211a:	0000e517          	auipc	a0,0xe
    8000211e:	88650513          	addi	a0,a0,-1914 # 8000f9a0 <wait_lock>
    80002122:	b9bfe0ef          	jal	80000cbc <release>
  sched();
    80002126:	d67ff0ef          	jal	80001e8c <sched>
  panic("zombie exit");
    8000212a:	00005517          	auipc	a0,0x5
    8000212e:	0d650513          	addi	a0,a0,214 # 80007200 <etext+0x200>
    80002132:	ef2fe0ef          	jal	80000824 <panic>

0000000080002136 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002136:	7179                	addi	sp,sp,-48
    80002138:	f406                	sd	ra,40(sp)
    8000213a:	f022                	sd	s0,32(sp)
    8000213c:	ec26                	sd	s1,24(sp)
    8000213e:	e84a                	sd	s2,16(sp)
    80002140:	e44e                	sd	s3,8(sp)
    80002142:	e052                	sd	s4,0(sp)
    80002144:	1800                	addi	s0,sp,48
    80002146:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002148:	0000e497          	auipc	s1,0xe
    8000214c:	c7048493          	addi	s1,s1,-912 # 8000fdb8 <proc>
    80002150:	6985                	lui	s3,0x1
    80002152:	21098993          	addi	s3,s3,528 # 1210 <_entry-0x7fffedf0>
    80002156:	00056a17          	auipc	s4,0x56
    8000215a:	062a0a13          	addi	s4,s4,98 # 800581b8 <tickslock>
    acquire(&p->lock);
    8000215e:	8526                	mv	a0,s1
    80002160:	ac9fe0ef          	jal	80000c28 <acquire>
    if(p->pid == pid){
    80002164:	589c                	lw	a5,48(s1)
    80002166:	01278a63          	beq	a5,s2,8000217a <kkill+0x44>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000216a:	8526                	mv	a0,s1
    8000216c:	b51fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002170:	94ce                	add	s1,s1,s3
    80002172:	ff4496e3          	bne	s1,s4,8000215e <kkill+0x28>
  }
  return -1;
    80002176:	557d                	li	a0,-1
    80002178:	a819                	j	8000218e <kkill+0x58>
      p->killed = 1;
    8000217a:	4785                	li	a5,1
    8000217c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000217e:	4c98                	lw	a4,24(s1)
    80002180:	4789                	li	a5,2
    80002182:	00f70e63          	beq	a4,a5,8000219e <kkill+0x68>
      release(&p->lock);
    80002186:	8526                	mv	a0,s1
    80002188:	b35fe0ef          	jal	80000cbc <release>
      return 0;
    8000218c:	4501                	li	a0,0
}
    8000218e:	70a2                	ld	ra,40(sp)
    80002190:	7402                	ld	s0,32(sp)
    80002192:	64e2                	ld	s1,24(sp)
    80002194:	6942                	ld	s2,16(sp)
    80002196:	69a2                	ld	s3,8(sp)
    80002198:	6a02                	ld	s4,0(sp)
    8000219a:	6145                	addi	sp,sp,48
    8000219c:	8082                	ret
        p->state = RUNNABLE;
    8000219e:	478d                	li	a5,3
    800021a0:	cc9c                	sw	a5,24(s1)
    800021a2:	b7d5                	j	80002186 <kkill+0x50>

00000000800021a4 <setkilled>:

void
setkilled(struct proc *p)
{
    800021a4:	1101                	addi	sp,sp,-32
    800021a6:	ec06                	sd	ra,24(sp)
    800021a8:	e822                	sd	s0,16(sp)
    800021aa:	e426                	sd	s1,8(sp)
    800021ac:	1000                	addi	s0,sp,32
    800021ae:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021b0:	a79fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    800021b4:	4785                	li	a5,1
    800021b6:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800021b8:	8526                	mv	a0,s1
    800021ba:	b03fe0ef          	jal	80000cbc <release>
}
    800021be:	60e2                	ld	ra,24(sp)
    800021c0:	6442                	ld	s0,16(sp)
    800021c2:	64a2                	ld	s1,8(sp)
    800021c4:	6105                	addi	sp,sp,32
    800021c6:	8082                	ret

00000000800021c8 <killed>:

int
killed(struct proc *p)
{
    800021c8:	1101                	addi	sp,sp,-32
    800021ca:	ec06                	sd	ra,24(sp)
    800021cc:	e822                	sd	s0,16(sp)
    800021ce:	e426                	sd	s1,8(sp)
    800021d0:	e04a                	sd	s2,0(sp)
    800021d2:	1000                	addi	s0,sp,32
    800021d4:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800021d6:	a53fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    800021da:	549c                	lw	a5,40(s1)
    800021dc:	893e                	mv	s2,a5
  release(&p->lock);
    800021de:	8526                	mv	a0,s1
    800021e0:	addfe0ef          	jal	80000cbc <release>
  return k;
}
    800021e4:	854a                	mv	a0,s2
    800021e6:	60e2                	ld	ra,24(sp)
    800021e8:	6442                	ld	s0,16(sp)
    800021ea:	64a2                	ld	s1,8(sp)
    800021ec:	6902                	ld	s2,0(sp)
    800021ee:	6105                	addi	sp,sp,32
    800021f0:	8082                	ret

00000000800021f2 <kwait>:
{
    800021f2:	715d                	addi	sp,sp,-80
    800021f4:	e486                	sd	ra,72(sp)
    800021f6:	e0a2                	sd	s0,64(sp)
    800021f8:	fc26                	sd	s1,56(sp)
    800021fa:	f84a                	sd	s2,48(sp)
    800021fc:	f44e                	sd	s3,40(sp)
    800021fe:	f052                	sd	s4,32(sp)
    80002200:	ec56                	sd	s5,24(sp)
    80002202:	e85a                	sd	s6,16(sp)
    80002204:	e45e                	sd	s7,8(sp)
    80002206:	0880                	addi	s0,sp,80
    80002208:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    8000220a:	f2aff0ef          	jal	80001934 <myproc>
    8000220e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002210:	0000d517          	auipc	a0,0xd
    80002214:	79050513          	addi	a0,a0,1936 # 8000f9a0 <wait_lock>
    80002218:	a11fe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    8000221c:	4a95                	li	s5,5
        havekids = 1;
    8000221e:	4b05                	li	s6,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002220:	6985                	lui	s3,0x1
    80002222:	21098993          	addi	s3,s3,528 # 1210 <_entry-0x7fffedf0>
    80002226:	00056a17          	auipc	s4,0x56
    8000222a:	f92a0a13          	addi	s4,s4,-110 # 800581b8 <tickslock>
    8000222e:	a879                	j	800022cc <kwait+0xda>
          pid = pp->pid;
    80002230:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002234:	000b8c63          	beqz	s7,8000224c <kwait+0x5a>
    80002238:	4691                	li	a3,4
    8000223a:	02c48613          	addi	a2,s1,44
    8000223e:	85de                	mv	a1,s7
    80002240:	05093503          	ld	a0,80(s2)
    80002244:	c10ff0ef          	jal	80001654 <copyout>
    80002248:	02054a63          	bltz	a0,8000227c <kwait+0x8a>
          freeproc(pp);
    8000224c:	8526                	mv	a0,s1
    8000224e:	8bbff0ef          	jal	80001b08 <freeproc>
          release(&pp->lock);
    80002252:	8526                	mv	a0,s1
    80002254:	a69fe0ef          	jal	80000cbc <release>
          release(&wait_lock);
    80002258:	0000d517          	auipc	a0,0xd
    8000225c:	74850513          	addi	a0,a0,1864 # 8000f9a0 <wait_lock>
    80002260:	a5dfe0ef          	jal	80000cbc <release>
}
    80002264:	854e                	mv	a0,s3
    80002266:	60a6                	ld	ra,72(sp)
    80002268:	6406                	ld	s0,64(sp)
    8000226a:	74e2                	ld	s1,56(sp)
    8000226c:	7942                	ld	s2,48(sp)
    8000226e:	79a2                	ld	s3,40(sp)
    80002270:	7a02                	ld	s4,32(sp)
    80002272:	6ae2                	ld	s5,24(sp)
    80002274:	6b42                	ld	s6,16(sp)
    80002276:	6ba2                	ld	s7,8(sp)
    80002278:	6161                	addi	sp,sp,80
    8000227a:	8082                	ret
            release(&pp->lock);
    8000227c:	8526                	mv	a0,s1
    8000227e:	a3ffe0ef          	jal	80000cbc <release>
            release(&wait_lock);
    80002282:	0000d517          	auipc	a0,0xd
    80002286:	71e50513          	addi	a0,a0,1822 # 8000f9a0 <wait_lock>
    8000228a:	a33fe0ef          	jal	80000cbc <release>
            return -1;
    8000228e:	59fd                	li	s3,-1
    80002290:	bfd1                	j	80002264 <kwait+0x72>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002292:	94ce                	add	s1,s1,s3
    80002294:	03448063          	beq	s1,s4,800022b4 <kwait+0xc2>
      if(pp->parent == p){
    80002298:	7c9c                	ld	a5,56(s1)
    8000229a:	ff279ce3          	bne	a5,s2,80002292 <kwait+0xa0>
        acquire(&pp->lock);
    8000229e:	8526                	mv	a0,s1
    800022a0:	989fe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    800022a4:	4c9c                	lw	a5,24(s1)
    800022a6:	f95785e3          	beq	a5,s5,80002230 <kwait+0x3e>
        release(&pp->lock);
    800022aa:	8526                	mv	a0,s1
    800022ac:	a11fe0ef          	jal	80000cbc <release>
        havekids = 1;
    800022b0:	875a                	mv	a4,s6
    800022b2:	b7c5                	j	80002292 <kwait+0xa0>
    if(!havekids || killed(p)){
    800022b4:	c315                	beqz	a4,800022d8 <kwait+0xe6>
    800022b6:	854a                	mv	a0,s2
    800022b8:	f11ff0ef          	jal	800021c8 <killed>
    800022bc:	ed11                	bnez	a0,800022d8 <kwait+0xe6>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800022be:	0000d597          	auipc	a1,0xd
    800022c2:	6e258593          	addi	a1,a1,1762 # 8000f9a0 <wait_lock>
    800022c6:	854a                	mv	a0,s2
    800022c8:	cadff0ef          	jal	80001f74 <sleep>
    havekids = 0;
    800022cc:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800022ce:	0000e497          	auipc	s1,0xe
    800022d2:	aea48493          	addi	s1,s1,-1302 # 8000fdb8 <proc>
    800022d6:	b7c9                	j	80002298 <kwait+0xa6>
      release(&wait_lock);
    800022d8:	0000d517          	auipc	a0,0xd
    800022dc:	6c850513          	addi	a0,a0,1736 # 8000f9a0 <wait_lock>
    800022e0:	9ddfe0ef          	jal	80000cbc <release>
      return -1;
    800022e4:	59fd                	li	s3,-1
    800022e6:	bfbd                	j	80002264 <kwait+0x72>

00000000800022e8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800022e8:	7179                	addi	sp,sp,-48
    800022ea:	f406                	sd	ra,40(sp)
    800022ec:	f022                	sd	s0,32(sp)
    800022ee:	ec26                	sd	s1,24(sp)
    800022f0:	e84a                	sd	s2,16(sp)
    800022f2:	e44e                	sd	s3,8(sp)
    800022f4:	e052                	sd	s4,0(sp)
    800022f6:	1800                	addi	s0,sp,48
    800022f8:	84aa                	mv	s1,a0
    800022fa:	8a2e                	mv	s4,a1
    800022fc:	89b2                	mv	s3,a2
    800022fe:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002300:	e34ff0ef          	jal	80001934 <myproc>
  if(user_dst){
    80002304:	cc99                	beqz	s1,80002322 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002306:	86ca                	mv	a3,s2
    80002308:	864e                	mv	a2,s3
    8000230a:	85d2                	mv	a1,s4
    8000230c:	6928                	ld	a0,80(a0)
    8000230e:	b46ff0ef          	jal	80001654 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002312:	70a2                	ld	ra,40(sp)
    80002314:	7402                	ld	s0,32(sp)
    80002316:	64e2                	ld	s1,24(sp)
    80002318:	6942                	ld	s2,16(sp)
    8000231a:	69a2                	ld	s3,8(sp)
    8000231c:	6a02                	ld	s4,0(sp)
    8000231e:	6145                	addi	sp,sp,48
    80002320:	8082                	ret
    memmove((char *)dst, src, len);
    80002322:	0009061b          	sext.w	a2,s2
    80002326:	85ce                	mv	a1,s3
    80002328:	8552                	mv	a0,s4
    8000232a:	a2ffe0ef          	jal	80000d58 <memmove>
    return 0;
    8000232e:	8526                	mv	a0,s1
    80002330:	b7cd                	j	80002312 <either_copyout+0x2a>

0000000080002332 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002332:	7179                	addi	sp,sp,-48
    80002334:	f406                	sd	ra,40(sp)
    80002336:	f022                	sd	s0,32(sp)
    80002338:	ec26                	sd	s1,24(sp)
    8000233a:	e84a                	sd	s2,16(sp)
    8000233c:	e44e                	sd	s3,8(sp)
    8000233e:	e052                	sd	s4,0(sp)
    80002340:	1800                	addi	s0,sp,48
    80002342:	8a2a                	mv	s4,a0
    80002344:	84ae                	mv	s1,a1
    80002346:	89b2                	mv	s3,a2
    80002348:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000234a:	deaff0ef          	jal	80001934 <myproc>
  if(user_src){
    8000234e:	cc99                	beqz	s1,8000236c <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002350:	86ca                	mv	a3,s2
    80002352:	864e                	mv	a2,s3
    80002354:	85d2                	mv	a1,s4
    80002356:	6928                	ld	a0,80(a0)
    80002358:	bbaff0ef          	jal	80001712 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000235c:	70a2                	ld	ra,40(sp)
    8000235e:	7402                	ld	s0,32(sp)
    80002360:	64e2                	ld	s1,24(sp)
    80002362:	6942                	ld	s2,16(sp)
    80002364:	69a2                	ld	s3,8(sp)
    80002366:	6a02                	ld	s4,0(sp)
    80002368:	6145                	addi	sp,sp,48
    8000236a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000236c:	0009061b          	sext.w	a2,s2
    80002370:	85ce                	mv	a1,s3
    80002372:	8552                	mv	a0,s4
    80002374:	9e5fe0ef          	jal	80000d58 <memmove>
    return 0;
    80002378:	8526                	mv	a0,s1
    8000237a:	b7cd                	j	8000235c <either_copyin+0x2a>

000000008000237c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000237c:	715d                	addi	sp,sp,-80
    8000237e:	e486                	sd	ra,72(sp)
    80002380:	e0a2                	sd	s0,64(sp)
    80002382:	fc26                	sd	s1,56(sp)
    80002384:	f84a                	sd	s2,48(sp)
    80002386:	f44e                	sd	s3,40(sp)
    80002388:	f052                	sd	s4,32(sp)
    8000238a:	ec56                	sd	s5,24(sp)
    8000238c:	e85a                	sd	s6,16(sp)
    8000238e:	e45e                	sd	s7,8(sp)
    80002390:	e062                	sd	s8,0(sp)
    80002392:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002394:	00005517          	auipc	a0,0x5
    80002398:	ce450513          	addi	a0,a0,-796 # 80007078 <etext+0x78>
    8000239c:	95efe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800023a0:	0000e497          	auipc	s1,0xe
    800023a4:	b7048493          	addi	s1,s1,-1168 # 8000ff10 <proc+0x158>
    800023a8:	00056997          	auipc	s3,0x56
    800023ac:	f6898993          	addi	s3,s3,-152 # 80058310 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023b0:	4b95                	li	s7,5
      state = states[p->state];
    else
      state = "???";
    800023b2:	00005a17          	auipc	s4,0x5
    800023b6:	e5ea0a13          	addi	s4,s4,-418 # 80007210 <etext+0x210>
    printf("%d %s %s", p->pid, state, p->name);
    800023ba:	00005b17          	auipc	s6,0x5
    800023be:	e5eb0b13          	addi	s6,s6,-418 # 80007218 <etext+0x218>
    printf("\n");
    800023c2:	00005a97          	auipc	s5,0x5
    800023c6:	cb6a8a93          	addi	s5,s5,-842 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023ca:	00005c17          	auipc	s8,0x5
    800023ce:	36ec0c13          	addi	s8,s8,878 # 80007738 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    800023d2:	6905                	lui	s2,0x1
    800023d4:	21090913          	addi	s2,s2,528 # 1210 <_entry-0x7fffedf0>
    800023d8:	a821                	j	800023f0 <procdump+0x74>
    printf("%d %s %s", p->pid, state, p->name);
    800023da:	ed86a583          	lw	a1,-296(a3)
    800023de:	855a                	mv	a0,s6
    800023e0:	91afe0ef          	jal	800004fa <printf>
    printf("\n");
    800023e4:	8556                	mv	a0,s5
    800023e6:	914fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800023ea:	94ca                	add	s1,s1,s2
    800023ec:	03348263          	beq	s1,s3,80002410 <procdump+0x94>
    if(p->state == UNUSED)
    800023f0:	86a6                	mv	a3,s1
    800023f2:	ec04a783          	lw	a5,-320(s1)
    800023f6:	dbf5                	beqz	a5,800023ea <procdump+0x6e>
      state = "???";
    800023f8:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023fa:	fefbe0e3          	bltu	s7,a5,800023da <procdump+0x5e>
    800023fe:	02079713          	slli	a4,a5,0x20
    80002402:	01d75793          	srli	a5,a4,0x1d
    80002406:	97e2                	add	a5,a5,s8
    80002408:	6390                	ld	a2,0(a5)
    8000240a:	fa61                	bnez	a2,800023da <procdump+0x5e>
      state = "???";
    8000240c:	8652                	mv	a2,s4
    8000240e:	b7f1                	j	800023da <procdump+0x5e>
  }
}
    80002410:	60a6                	ld	ra,72(sp)
    80002412:	6406                	ld	s0,64(sp)
    80002414:	74e2                	ld	s1,56(sp)
    80002416:	7942                	ld	s2,48(sp)
    80002418:	79a2                	ld	s3,40(sp)
    8000241a:	7a02                	ld	s4,32(sp)
    8000241c:	6ae2                	ld	s5,24(sp)
    8000241e:	6b42                	ld	s6,16(sp)
    80002420:	6ba2                	ld	s7,8(sp)
    80002422:	6c02                	ld	s8,0(sp)
    80002424:	6161                	addi	sp,sp,80
    80002426:	8082                	ret

0000000080002428 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002428:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000242c:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002430:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002432:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002434:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002438:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    8000243c:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002440:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002444:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002448:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000244c:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002450:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002454:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002458:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000245c:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002460:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002464:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002466:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002468:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000246c:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002470:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002474:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002478:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    8000247c:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002480:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002484:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002488:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    8000248c:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002490:	8082                	ret

0000000080002492 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002492:	1141                	addi	sp,sp,-16
    80002494:	e406                	sd	ra,8(sp)
    80002496:	e022                	sd	s0,0(sp)
    80002498:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000249a:	00005597          	auipc	a1,0x5
    8000249e:	dbe58593          	addi	a1,a1,-578 # 80007258 <etext+0x258>
    800024a2:	00056517          	auipc	a0,0x56
    800024a6:	d1650513          	addi	a0,a0,-746 # 800581b8 <tickslock>
    800024aa:	ef4fe0ef          	jal	80000b9e <initlock>
}
    800024ae:	60a2                	ld	ra,8(sp)
    800024b0:	6402                	ld	s0,0(sp)
    800024b2:	0141                	addi	sp,sp,16
    800024b4:	8082                	ret

00000000800024b6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800024b6:	1141                	addi	sp,sp,-16
    800024b8:	e406                	sd	ra,8(sp)
    800024ba:	e022                	sd	s0,0(sp)
    800024bc:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024be:	00003797          	auipc	a5,0x3
    800024c2:	2b278793          	addi	a5,a5,690 # 80005770 <kernelvec>
    800024c6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800024ca:	60a2                	ld	ra,8(sp)
    800024cc:	6402                	ld	s0,0(sp)
    800024ce:	0141                	addi	sp,sp,16
    800024d0:	8082                	ret

00000000800024d2 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800024d2:	1141                	addi	sp,sp,-16
    800024d4:	e406                	sd	ra,8(sp)
    800024d6:	e022                	sd	s0,0(sp)
    800024d8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800024da:	c5aff0ef          	jal	80001934 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024de:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800024e2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024e4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800024e8:	04000737          	lui	a4,0x4000
    800024ec:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800024ee:	0732                	slli	a4,a4,0xc
    800024f0:	00004797          	auipc	a5,0x4
    800024f4:	b1078793          	addi	a5,a5,-1264 # 80006000 <_trampoline>
    800024f8:	00004697          	auipc	a3,0x4
    800024fc:	b0868693          	addi	a3,a3,-1272 # 80006000 <_trampoline>
    80002500:	8f95                	sub	a5,a5,a3
    80002502:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002504:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002508:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000250a:	18002773          	csrr	a4,satp
    8000250e:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002510:	6d38                	ld	a4,88(a0)
    80002512:	613c                	ld	a5,64(a0)
    80002514:	6685                	lui	a3,0x1
    80002516:	97b6                	add	a5,a5,a3
    80002518:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000251a:	6d3c                	ld	a5,88(a0)
    8000251c:	00000717          	auipc	a4,0x0
    80002520:	0fc70713          	addi	a4,a4,252 # 80002618 <usertrap>
    80002524:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002526:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002528:	8712                	mv	a4,tp
    8000252a:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000252c:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002530:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002534:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002538:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000253c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000253e:	6f9c                	ld	a5,24(a5)
    80002540:	14179073          	csrw	sepc,a5
}
    80002544:	60a2                	ld	ra,8(sp)
    80002546:	6402                	ld	s0,0(sp)
    80002548:	0141                	addi	sp,sp,16
    8000254a:	8082                	ret

000000008000254c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000254c:	1141                	addi	sp,sp,-16
    8000254e:	e406                	sd	ra,8(sp)
    80002550:	e022                	sd	s0,0(sp)
    80002552:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80002554:	bacff0ef          	jal	80001900 <cpuid>
    80002558:	cd11                	beqz	a0,80002574 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000255a:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000255e:	000f4737          	lui	a4,0xf4
    80002562:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002566:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002568:	14d79073          	csrw	stimecmp,a5
}
    8000256c:	60a2                	ld	ra,8(sp)
    8000256e:	6402                	ld	s0,0(sp)
    80002570:	0141                	addi	sp,sp,16
    80002572:	8082                	ret
    acquire(&tickslock);
    80002574:	00056517          	auipc	a0,0x56
    80002578:	c4450513          	addi	a0,a0,-956 # 800581b8 <tickslock>
    8000257c:	eacfe0ef          	jal	80000c28 <acquire>
    ticks++;
    80002580:	00005717          	auipc	a4,0x5
    80002584:	30870713          	addi	a4,a4,776 # 80007888 <ticks>
    80002588:	431c                	lw	a5,0(a4)
    8000258a:	2785                	addiw	a5,a5,1
    8000258c:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    8000258e:	853a                	mv	a0,a4
    80002590:	a31ff0ef          	jal	80001fc0 <wakeup>
    release(&tickslock);
    80002594:	00056517          	auipc	a0,0x56
    80002598:	c2450513          	addi	a0,a0,-988 # 800581b8 <tickslock>
    8000259c:	f20fe0ef          	jal	80000cbc <release>
    800025a0:	bf6d                	j	8000255a <clockintr+0xe>

00000000800025a2 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800025a2:	1101                	addi	sp,sp,-32
    800025a4:	ec06                	sd	ra,24(sp)
    800025a6:	e822                	sd	s0,16(sp)
    800025a8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025aa:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800025ae:	57fd                	li	a5,-1
    800025b0:	17fe                	slli	a5,a5,0x3f
    800025b2:	07a5                	addi	a5,a5,9
    800025b4:	00f70c63          	beq	a4,a5,800025cc <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800025b8:	57fd                	li	a5,-1
    800025ba:	17fe                	slli	a5,a5,0x3f
    800025bc:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800025be:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800025c0:	04f70863          	beq	a4,a5,80002610 <devintr+0x6e>
  }
}
    800025c4:	60e2                	ld	ra,24(sp)
    800025c6:	6442                	ld	s0,16(sp)
    800025c8:	6105                	addi	sp,sp,32
    800025ca:	8082                	ret
    800025cc:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800025ce:	24e030ef          	jal	8000581c <plic_claim>
    800025d2:	872a                	mv	a4,a0
    800025d4:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800025d6:	47a9                	li	a5,10
    800025d8:	00f50963          	beq	a0,a5,800025ea <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    800025dc:	4785                	li	a5,1
    800025de:	00f50963          	beq	a0,a5,800025f0 <devintr+0x4e>
    return 1;
    800025e2:	4505                	li	a0,1
    } else if(irq){
    800025e4:	eb09                	bnez	a4,800025f6 <devintr+0x54>
    800025e6:	64a2                	ld	s1,8(sp)
    800025e8:	bff1                	j	800025c4 <devintr+0x22>
      uartintr();
    800025ea:	c0afe0ef          	jal	800009f4 <uartintr>
    if(irq)
    800025ee:	a819                	j	80002604 <devintr+0x62>
      virtio_disk_intr();
    800025f0:	6c2030ef          	jal	80005cb2 <virtio_disk_intr>
    if(irq)
    800025f4:	a801                	j	80002604 <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    800025f6:	85ba                	mv	a1,a4
    800025f8:	00005517          	auipc	a0,0x5
    800025fc:	c6850513          	addi	a0,a0,-920 # 80007260 <etext+0x260>
    80002600:	efbfd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002604:	8526                	mv	a0,s1
    80002606:	236030ef          	jal	8000583c <plic_complete>
    return 1;
    8000260a:	4505                	li	a0,1
    8000260c:	64a2                	ld	s1,8(sp)
    8000260e:	bf5d                	j	800025c4 <devintr+0x22>
    clockintr();
    80002610:	f3dff0ef          	jal	8000254c <clockintr>
    return 2;
    80002614:	4509                	li	a0,2
    80002616:	b77d                	j	800025c4 <devintr+0x22>

0000000080002618 <usertrap>:
{
    80002618:	1101                	addi	sp,sp,-32
    8000261a:	ec06                	sd	ra,24(sp)
    8000261c:	e822                	sd	s0,16(sp)
    8000261e:	e426                	sd	s1,8(sp)
    80002620:	e04a                	sd	s2,0(sp)
    80002622:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002624:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002628:	1007f793          	andi	a5,a5,256
    8000262c:	eba5                	bnez	a5,8000269c <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000262e:	00003797          	auipc	a5,0x3
    80002632:	14278793          	addi	a5,a5,322 # 80005770 <kernelvec>
    80002636:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000263a:	afaff0ef          	jal	80001934 <myproc>
    8000263e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002640:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002642:	14102773          	csrr	a4,sepc
    80002646:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002648:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000264c:	47a1                	li	a5,8
    8000264e:	04f70d63          	beq	a4,a5,800026a8 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002652:	f51ff0ef          	jal	800025a2 <devintr>
    80002656:	892a                	mv	s2,a0
    80002658:	e945                	bnez	a0,80002708 <usertrap+0xf0>
    8000265a:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000265e:	47bd                	li	a5,15
    80002660:	08f70863          	beq	a4,a5,800026f0 <usertrap+0xd8>
    80002664:	14202773          	csrr	a4,scause
    80002668:	47b5                	li	a5,13
    8000266a:	08f70363          	beq	a4,a5,800026f0 <usertrap+0xd8>
    8000266e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002672:	5890                	lw	a2,48(s1)
    80002674:	00005517          	auipc	a0,0x5
    80002678:	c2c50513          	addi	a0,a0,-980 # 800072a0 <etext+0x2a0>
    8000267c:	e7ffd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002680:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002684:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002688:	00005517          	auipc	a0,0x5
    8000268c:	c4850513          	addi	a0,a0,-952 # 800072d0 <etext+0x2d0>
    80002690:	e6bfd0ef          	jal	800004fa <printf>
    setkilled(p);
    80002694:	8526                	mv	a0,s1
    80002696:	b0fff0ef          	jal	800021a4 <setkilled>
    8000269a:	a035                	j	800026c6 <usertrap+0xae>
    panic("usertrap: not from user mode");
    8000269c:	00005517          	auipc	a0,0x5
    800026a0:	be450513          	addi	a0,a0,-1052 # 80007280 <etext+0x280>
    800026a4:	980fe0ef          	jal	80000824 <panic>
    if(killed(p))
    800026a8:	b21ff0ef          	jal	800021c8 <killed>
    800026ac:	ed15                	bnez	a0,800026e8 <usertrap+0xd0>
    p->trapframe->epc += 4;
    800026ae:	6cb8                	ld	a4,88(s1)
    800026b0:	6f1c                	ld	a5,24(a4)
    800026b2:	0791                	addi	a5,a5,4
    800026b4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026b6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800026ba:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026be:	10079073          	csrw	sstatus,a5
    syscall();
    800026c2:	240000ef          	jal	80002902 <syscall>
  if(killed(p))
    800026c6:	8526                	mv	a0,s1
    800026c8:	b01ff0ef          	jal	800021c8 <killed>
    800026cc:	e139                	bnez	a0,80002712 <usertrap+0xfa>
  prepare_return();
    800026ce:	e05ff0ef          	jal	800024d2 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800026d2:	68a8                	ld	a0,80(s1)
    800026d4:	8131                	srli	a0,a0,0xc
    800026d6:	57fd                	li	a5,-1
    800026d8:	17fe                	slli	a5,a5,0x3f
    800026da:	8d5d                	or	a0,a0,a5
}
    800026dc:	60e2                	ld	ra,24(sp)
    800026de:	6442                	ld	s0,16(sp)
    800026e0:	64a2                	ld	s1,8(sp)
    800026e2:	6902                	ld	s2,0(sp)
    800026e4:	6105                	addi	sp,sp,32
    800026e6:	8082                	ret
      kexit(-1);
    800026e8:	557d                	li	a0,-1
    800026ea:	9a7ff0ef          	jal	80002090 <kexit>
    800026ee:	b7c1                	j	800026ae <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026f0:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026f4:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    800026f8:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    800026fa:	00163613          	seqz	a2,a2
    800026fe:	68a8                	ld	a0,80(s1)
    80002700:	ed1fe0ef          	jal	800015d0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002704:	f169                	bnez	a0,800026c6 <usertrap+0xae>
    80002706:	b7a5                	j	8000266e <usertrap+0x56>
  if(killed(p))
    80002708:	8526                	mv	a0,s1
    8000270a:	abfff0ef          	jal	800021c8 <killed>
    8000270e:	c511                	beqz	a0,8000271a <usertrap+0x102>
    80002710:	a011                	j	80002714 <usertrap+0xfc>
    80002712:	4901                	li	s2,0
    kexit(-1);
    80002714:	557d                	li	a0,-1
    80002716:	97bff0ef          	jal	80002090 <kexit>
  if(which_dev == 2)
    8000271a:	4789                	li	a5,2
    8000271c:	faf919e3          	bne	s2,a5,800026ce <usertrap+0xb6>
    yield();
    80002720:	829ff0ef          	jal	80001f48 <yield>
    80002724:	b76d                	j	800026ce <usertrap+0xb6>

0000000080002726 <kerneltrap>:
{
    80002726:	7179                	addi	sp,sp,-48
    80002728:	f406                	sd	ra,40(sp)
    8000272a:	f022                	sd	s0,32(sp)
    8000272c:	ec26                	sd	s1,24(sp)
    8000272e:	e84a                	sd	s2,16(sp)
    80002730:	e44e                	sd	s3,8(sp)
    80002732:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002734:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002738:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000273c:	142027f3          	csrr	a5,scause
    80002740:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002742:	1004f793          	andi	a5,s1,256
    80002746:	c795                	beqz	a5,80002772 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002748:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000274c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000274e:	eb85                	bnez	a5,8000277e <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    80002750:	e53ff0ef          	jal	800025a2 <devintr>
    80002754:	c91d                	beqz	a0,8000278a <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    80002756:	4789                	li	a5,2
    80002758:	04f50a63          	beq	a0,a5,800027ac <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000275c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002760:	10049073          	csrw	sstatus,s1
}
    80002764:	70a2                	ld	ra,40(sp)
    80002766:	7402                	ld	s0,32(sp)
    80002768:	64e2                	ld	s1,24(sp)
    8000276a:	6942                	ld	s2,16(sp)
    8000276c:	69a2                	ld	s3,8(sp)
    8000276e:	6145                	addi	sp,sp,48
    80002770:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002772:	00005517          	auipc	a0,0x5
    80002776:	b8650513          	addi	a0,a0,-1146 # 800072f8 <etext+0x2f8>
    8000277a:	8aafe0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    8000277e:	00005517          	auipc	a0,0x5
    80002782:	ba250513          	addi	a0,a0,-1118 # 80007320 <etext+0x320>
    80002786:	89efe0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000278a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000278e:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002792:	85ce                	mv	a1,s3
    80002794:	00005517          	auipc	a0,0x5
    80002798:	bac50513          	addi	a0,a0,-1108 # 80007340 <etext+0x340>
    8000279c:	d5ffd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    800027a0:	00005517          	auipc	a0,0x5
    800027a4:	bc850513          	addi	a0,a0,-1080 # 80007368 <etext+0x368>
    800027a8:	87cfe0ef          	jal	80000824 <panic>
  if(which_dev == 2 && myproc() != 0)
    800027ac:	988ff0ef          	jal	80001934 <myproc>
    800027b0:	d555                	beqz	a0,8000275c <kerneltrap+0x36>
    yield();
    800027b2:	f96ff0ef          	jal	80001f48 <yield>
    800027b6:	b75d                	j	8000275c <kerneltrap+0x36>

00000000800027b8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800027b8:	1101                	addi	sp,sp,-32
    800027ba:	ec06                	sd	ra,24(sp)
    800027bc:	e822                	sd	s0,16(sp)
    800027be:	e426                	sd	s1,8(sp)
    800027c0:	1000                	addi	s0,sp,32
    800027c2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800027c4:	970ff0ef          	jal	80001934 <myproc>
  switch (n) {
    800027c8:	4795                	li	a5,5
    800027ca:	0497e163          	bltu	a5,s1,8000280c <argraw+0x54>
    800027ce:	048a                	slli	s1,s1,0x2
    800027d0:	00005717          	auipc	a4,0x5
    800027d4:	f9870713          	addi	a4,a4,-104 # 80007768 <states.0+0x30>
    800027d8:	94ba                	add	s1,s1,a4
    800027da:	409c                	lw	a5,0(s1)
    800027dc:	97ba                	add	a5,a5,a4
    800027de:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800027e0:	6d3c                	ld	a5,88(a0)
    800027e2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800027e4:	60e2                	ld	ra,24(sp)
    800027e6:	6442                	ld	s0,16(sp)
    800027e8:	64a2                	ld	s1,8(sp)
    800027ea:	6105                	addi	sp,sp,32
    800027ec:	8082                	ret
    return p->trapframe->a1;
    800027ee:	6d3c                	ld	a5,88(a0)
    800027f0:	7fa8                	ld	a0,120(a5)
    800027f2:	bfcd                	j	800027e4 <argraw+0x2c>
    return p->trapframe->a2;
    800027f4:	6d3c                	ld	a5,88(a0)
    800027f6:	63c8                	ld	a0,128(a5)
    800027f8:	b7f5                	j	800027e4 <argraw+0x2c>
    return p->trapframe->a3;
    800027fa:	6d3c                	ld	a5,88(a0)
    800027fc:	67c8                	ld	a0,136(a5)
    800027fe:	b7dd                	j	800027e4 <argraw+0x2c>
    return p->trapframe->a4;
    80002800:	6d3c                	ld	a5,88(a0)
    80002802:	6bc8                	ld	a0,144(a5)
    80002804:	b7c5                	j	800027e4 <argraw+0x2c>
    return p->trapframe->a5;
    80002806:	6d3c                	ld	a5,88(a0)
    80002808:	6fc8                	ld	a0,152(a5)
    8000280a:	bfe9                	j	800027e4 <argraw+0x2c>
  panic("argraw");
    8000280c:	00005517          	auipc	a0,0x5
    80002810:	b6c50513          	addi	a0,a0,-1172 # 80007378 <etext+0x378>
    80002814:	810fe0ef          	jal	80000824 <panic>

0000000080002818 <fetchaddr>:
{
    80002818:	1101                	addi	sp,sp,-32
    8000281a:	ec06                	sd	ra,24(sp)
    8000281c:	e822                	sd	s0,16(sp)
    8000281e:	e426                	sd	s1,8(sp)
    80002820:	e04a                	sd	s2,0(sp)
    80002822:	1000                	addi	s0,sp,32
    80002824:	84aa                	mv	s1,a0
    80002826:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002828:	90cff0ef          	jal	80001934 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000282c:	653c                	ld	a5,72(a0)
    8000282e:	02f4f663          	bgeu	s1,a5,8000285a <fetchaddr+0x42>
    80002832:	00848713          	addi	a4,s1,8
    80002836:	02e7e463          	bltu	a5,a4,8000285e <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000283a:	46a1                	li	a3,8
    8000283c:	8626                	mv	a2,s1
    8000283e:	85ca                	mv	a1,s2
    80002840:	6928                	ld	a0,80(a0)
    80002842:	ed1fe0ef          	jal	80001712 <copyin>
    80002846:	00a03533          	snez	a0,a0
    8000284a:	40a0053b          	negw	a0,a0
}
    8000284e:	60e2                	ld	ra,24(sp)
    80002850:	6442                	ld	s0,16(sp)
    80002852:	64a2                	ld	s1,8(sp)
    80002854:	6902                	ld	s2,0(sp)
    80002856:	6105                	addi	sp,sp,32
    80002858:	8082                	ret
    return -1;
    8000285a:	557d                	li	a0,-1
    8000285c:	bfcd                	j	8000284e <fetchaddr+0x36>
    8000285e:	557d                	li	a0,-1
    80002860:	b7fd                	j	8000284e <fetchaddr+0x36>

0000000080002862 <fetchstr>:
{
    80002862:	7179                	addi	sp,sp,-48
    80002864:	f406                	sd	ra,40(sp)
    80002866:	f022                	sd	s0,32(sp)
    80002868:	ec26                	sd	s1,24(sp)
    8000286a:	e84a                	sd	s2,16(sp)
    8000286c:	e44e                	sd	s3,8(sp)
    8000286e:	1800                	addi	s0,sp,48
    80002870:	89aa                	mv	s3,a0
    80002872:	84ae                	mv	s1,a1
    80002874:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002876:	8beff0ef          	jal	80001934 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000287a:	86ca                	mv	a3,s2
    8000287c:	864e                	mv	a2,s3
    8000287e:	85a6                	mv	a1,s1
    80002880:	6928                	ld	a0,80(a0)
    80002882:	c77fe0ef          	jal	800014f8 <copyinstr>
    80002886:	00054c63          	bltz	a0,8000289e <fetchstr+0x3c>
  return strlen(buf);
    8000288a:	8526                	mv	a0,s1
    8000288c:	df6fe0ef          	jal	80000e82 <strlen>
}
    80002890:	70a2                	ld	ra,40(sp)
    80002892:	7402                	ld	s0,32(sp)
    80002894:	64e2                	ld	s1,24(sp)
    80002896:	6942                	ld	s2,16(sp)
    80002898:	69a2                	ld	s3,8(sp)
    8000289a:	6145                	addi	sp,sp,48
    8000289c:	8082                	ret
    return -1;
    8000289e:	557d                	li	a0,-1
    800028a0:	bfc5                	j	80002890 <fetchstr+0x2e>

00000000800028a2 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800028a2:	1101                	addi	sp,sp,-32
    800028a4:	ec06                	sd	ra,24(sp)
    800028a6:	e822                	sd	s0,16(sp)
    800028a8:	e426                	sd	s1,8(sp)
    800028aa:	1000                	addi	s0,sp,32
    800028ac:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028ae:	f0bff0ef          	jal	800027b8 <argraw>
    800028b2:	c088                	sw	a0,0(s1)
}
    800028b4:	60e2                	ld	ra,24(sp)
    800028b6:	6442                	ld	s0,16(sp)
    800028b8:	64a2                	ld	s1,8(sp)
    800028ba:	6105                	addi	sp,sp,32
    800028bc:	8082                	ret

00000000800028be <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800028be:	1101                	addi	sp,sp,-32
    800028c0:	ec06                	sd	ra,24(sp)
    800028c2:	e822                	sd	s0,16(sp)
    800028c4:	e426                	sd	s1,8(sp)
    800028c6:	1000                	addi	s0,sp,32
    800028c8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028ca:	eefff0ef          	jal	800027b8 <argraw>
    800028ce:	e088                	sd	a0,0(s1)
}
    800028d0:	60e2                	ld	ra,24(sp)
    800028d2:	6442                	ld	s0,16(sp)
    800028d4:	64a2                	ld	s1,8(sp)
    800028d6:	6105                	addi	sp,sp,32
    800028d8:	8082                	ret

00000000800028da <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800028da:	1101                	addi	sp,sp,-32
    800028dc:	ec06                	sd	ra,24(sp)
    800028de:	e822                	sd	s0,16(sp)
    800028e0:	e426                	sd	s1,8(sp)
    800028e2:	e04a                	sd	s2,0(sp)
    800028e4:	1000                	addi	s0,sp,32
    800028e6:	892e                	mv	s2,a1
    800028e8:	84b2                	mv	s1,a2
  *ip = argraw(n);
    800028ea:	ecfff0ef          	jal	800027b8 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    800028ee:	8626                	mv	a2,s1
    800028f0:	85ca                	mv	a1,s2
    800028f2:	f71ff0ef          	jal	80002862 <fetchstr>
}
    800028f6:	60e2                	ld	ra,24(sp)
    800028f8:	6442                	ld	s0,16(sp)
    800028fa:	64a2                	ld	s1,8(sp)
    800028fc:	6902                	ld	s2,0(sp)
    800028fe:	6105                	addi	sp,sp,32
    80002900:	8082                	ret

0000000080002902 <syscall>:
[SYS_broadcast] sys_broadcast
};

void
syscall(void)
{
    80002902:	1101                	addi	sp,sp,-32
    80002904:	ec06                	sd	ra,24(sp)
    80002906:	e822                	sd	s0,16(sp)
    80002908:	e426                	sd	s1,8(sp)
    8000290a:	e04a                	sd	s2,0(sp)
    8000290c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000290e:	826ff0ef          	jal	80001934 <myproc>
    80002912:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002914:	05853903          	ld	s2,88(a0)
    80002918:	0a893783          	ld	a5,168(s2)
    8000291c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002920:	37fd                	addiw	a5,a5,-1
    80002922:	475d                	li	a4,23
    80002924:	00f76f63          	bltu	a4,a5,80002942 <syscall+0x40>
    80002928:	00369713          	slli	a4,a3,0x3
    8000292c:	00005797          	auipc	a5,0x5
    80002930:	e5478793          	addi	a5,a5,-428 # 80007780 <syscalls>
    80002934:	97ba                	add	a5,a5,a4
    80002936:	639c                	ld	a5,0(a5)
    80002938:	c789                	beqz	a5,80002942 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000293a:	9782                	jalr	a5
    8000293c:	06a93823          	sd	a0,112(s2)
    80002940:	a829                	j	8000295a <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002942:	15848613          	addi	a2,s1,344
    80002946:	588c                	lw	a1,48(s1)
    80002948:	00005517          	auipc	a0,0x5
    8000294c:	a3850513          	addi	a0,a0,-1480 # 80007380 <etext+0x380>
    80002950:	babfd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002954:	6cbc                	ld	a5,88(s1)
    80002956:	577d                	li	a4,-1
    80002958:	fbb8                	sd	a4,112(a5)
  }
}
    8000295a:	60e2                	ld	ra,24(sp)
    8000295c:	6442                	ld	s0,16(sp)
    8000295e:	64a2                	ld	s1,8(sp)
    80002960:	6902                	ld	s2,0(sp)
    80002962:	6105                	addi	sp,sp,32
    80002964:	8082                	ret

0000000080002966 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002966:	1101                	addi	sp,sp,-32
    80002968:	ec06                	sd	ra,24(sp)
    8000296a:	e822                	sd	s0,16(sp)
    8000296c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000296e:	fec40593          	addi	a1,s0,-20
    80002972:	4501                	li	a0,0
    80002974:	f2fff0ef          	jal	800028a2 <argint>
  kexit(n);
    80002978:	fec42503          	lw	a0,-20(s0)
    8000297c:	f14ff0ef          	jal	80002090 <kexit>
  return 0;  // not reached
}
    80002980:	4501                	li	a0,0
    80002982:	60e2                	ld	ra,24(sp)
    80002984:	6442                	ld	s0,16(sp)
    80002986:	6105                	addi	sp,sp,32
    80002988:	8082                	ret

000000008000298a <sys_getpid>:

uint64
sys_getpid(void)
{
    8000298a:	1141                	addi	sp,sp,-16
    8000298c:	e406                	sd	ra,8(sp)
    8000298e:	e022                	sd	s0,0(sp)
    80002990:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002992:	fa3fe0ef          	jal	80001934 <myproc>
}
    80002996:	5908                	lw	a0,48(a0)
    80002998:	60a2                	ld	ra,8(sp)
    8000299a:	6402                	ld	s0,0(sp)
    8000299c:	0141                	addi	sp,sp,16
    8000299e:	8082                	ret

00000000800029a0 <sys_fork>:

uint64
sys_fork(void)
{
    800029a0:	1141                	addi	sp,sp,-16
    800029a2:	e406                	sd	ra,8(sp)
    800029a4:	e022                	sd	s0,0(sp)
    800029a6:	0800                	addi	s0,sp,16
  return kfork();
    800029a8:	b20ff0ef          	jal	80001cc8 <kfork>
}
    800029ac:	60a2                	ld	ra,8(sp)
    800029ae:	6402                	ld	s0,0(sp)
    800029b0:	0141                	addi	sp,sp,16
    800029b2:	8082                	ret

00000000800029b4 <sys_wait>:

uint64
sys_wait(void)
{
    800029b4:	1101                	addi	sp,sp,-32
    800029b6:	ec06                	sd	ra,24(sp)
    800029b8:	e822                	sd	s0,16(sp)
    800029ba:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800029bc:	fe840593          	addi	a1,s0,-24
    800029c0:	4501                	li	a0,0
    800029c2:	efdff0ef          	jal	800028be <argaddr>
  return kwait(p);
    800029c6:	fe843503          	ld	a0,-24(s0)
    800029ca:	829ff0ef          	jal	800021f2 <kwait>
}
    800029ce:	60e2                	ld	ra,24(sp)
    800029d0:	6442                	ld	s0,16(sp)
    800029d2:	6105                	addi	sp,sp,32
    800029d4:	8082                	ret

00000000800029d6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800029d6:	7179                	addi	sp,sp,-48
    800029d8:	f406                	sd	ra,40(sp)
    800029da:	f022                	sd	s0,32(sp)
    800029dc:	ec26                	sd	s1,24(sp)
    800029de:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800029e0:	fd840593          	addi	a1,s0,-40
    800029e4:	4501                	li	a0,0
    800029e6:	ebdff0ef          	jal	800028a2 <argint>
  argint(1, &t);
    800029ea:	fdc40593          	addi	a1,s0,-36
    800029ee:	4505                	li	a0,1
    800029f0:	eb3ff0ef          	jal	800028a2 <argint>
  addr = myproc()->sz;
    800029f4:	f41fe0ef          	jal	80001934 <myproc>
    800029f8:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    800029fa:	fdc42703          	lw	a4,-36(s0)
    800029fe:	4785                	li	a5,1
    80002a00:	02f70763          	beq	a4,a5,80002a2e <sys_sbrk+0x58>
    80002a04:	fd842783          	lw	a5,-40(s0)
    80002a08:	0207c363          	bltz	a5,80002a2e <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002a0c:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    80002a0e:	02000737          	lui	a4,0x2000
    80002a12:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002a14:	0736                	slli	a4,a4,0xd
    80002a16:	02f76a63          	bltu	a4,a5,80002a4a <sys_sbrk+0x74>
    80002a1a:	0297e863          	bltu	a5,s1,80002a4a <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002a1e:	f17fe0ef          	jal	80001934 <myproc>
    80002a22:	fd842703          	lw	a4,-40(s0)
    80002a26:	653c                	ld	a5,72(a0)
    80002a28:	97ba                	add	a5,a5,a4
    80002a2a:	e53c                	sd	a5,72(a0)
    80002a2c:	a039                	j	80002a3a <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002a2e:	fd842503          	lw	a0,-40(s0)
    80002a32:	a34ff0ef          	jal	80001c66 <growproc>
    80002a36:	00054863          	bltz	a0,80002a46 <sys_sbrk+0x70>
  }
  return addr;
}
    80002a3a:	8526                	mv	a0,s1
    80002a3c:	70a2                	ld	ra,40(sp)
    80002a3e:	7402                	ld	s0,32(sp)
    80002a40:	64e2                	ld	s1,24(sp)
    80002a42:	6145                	addi	sp,sp,48
    80002a44:	8082                	ret
      return -1;
    80002a46:	54fd                	li	s1,-1
    80002a48:	bfcd                	j	80002a3a <sys_sbrk+0x64>
      return -1;
    80002a4a:	54fd                	li	s1,-1
    80002a4c:	b7fd                	j	80002a3a <sys_sbrk+0x64>

0000000080002a4e <sys_pause>:

uint64
sys_pause(void)
{
    80002a4e:	7139                	addi	sp,sp,-64
    80002a50:	fc06                	sd	ra,56(sp)
    80002a52:	f822                	sd	s0,48(sp)
    80002a54:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a56:	fcc40593          	addi	a1,s0,-52
    80002a5a:	4501                	li	a0,0
    80002a5c:	e47ff0ef          	jal	800028a2 <argint>
  if(n < 0)
    80002a60:	fcc42783          	lw	a5,-52(s0)
    80002a64:	0607c863          	bltz	a5,80002ad4 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002a68:	00055517          	auipc	a0,0x55
    80002a6c:	75050513          	addi	a0,a0,1872 # 800581b8 <tickslock>
    80002a70:	9b8fe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002a74:	fcc42783          	lw	a5,-52(s0)
    80002a78:	c3b9                	beqz	a5,80002abe <sys_pause+0x70>
    80002a7a:	f426                	sd	s1,40(sp)
    80002a7c:	f04a                	sd	s2,32(sp)
    80002a7e:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002a80:	00005997          	auipc	s3,0x5
    80002a84:	e089a983          	lw	s3,-504(s3) # 80007888 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a88:	00055917          	auipc	s2,0x55
    80002a8c:	73090913          	addi	s2,s2,1840 # 800581b8 <tickslock>
    80002a90:	00005497          	auipc	s1,0x5
    80002a94:	df848493          	addi	s1,s1,-520 # 80007888 <ticks>
    if(killed(myproc())){
    80002a98:	e9dfe0ef          	jal	80001934 <myproc>
    80002a9c:	f2cff0ef          	jal	800021c8 <killed>
    80002aa0:	ed0d                	bnez	a0,80002ada <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002aa2:	85ca                	mv	a1,s2
    80002aa4:	8526                	mv	a0,s1
    80002aa6:	cceff0ef          	jal	80001f74 <sleep>
  while(ticks - ticks0 < n){
    80002aaa:	409c                	lw	a5,0(s1)
    80002aac:	413787bb          	subw	a5,a5,s3
    80002ab0:	fcc42703          	lw	a4,-52(s0)
    80002ab4:	fee7e2e3          	bltu	a5,a4,80002a98 <sys_pause+0x4a>
    80002ab8:	74a2                	ld	s1,40(sp)
    80002aba:	7902                	ld	s2,32(sp)
    80002abc:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002abe:	00055517          	auipc	a0,0x55
    80002ac2:	6fa50513          	addi	a0,a0,1786 # 800581b8 <tickslock>
    80002ac6:	9f6fe0ef          	jal	80000cbc <release>
  return 0;
    80002aca:	4501                	li	a0,0
}
    80002acc:	70e2                	ld	ra,56(sp)
    80002ace:	7442                	ld	s0,48(sp)
    80002ad0:	6121                	addi	sp,sp,64
    80002ad2:	8082                	ret
    n = 0;
    80002ad4:	fc042623          	sw	zero,-52(s0)
    80002ad8:	bf41                	j	80002a68 <sys_pause+0x1a>
      release(&tickslock);
    80002ada:	00055517          	auipc	a0,0x55
    80002ade:	6de50513          	addi	a0,a0,1758 # 800581b8 <tickslock>
    80002ae2:	9dafe0ef          	jal	80000cbc <release>
      return -1;
    80002ae6:	557d                	li	a0,-1
    80002ae8:	74a2                	ld	s1,40(sp)
    80002aea:	7902                	ld	s2,32(sp)
    80002aec:	69e2                	ld	s3,24(sp)
    80002aee:	bff9                	j	80002acc <sys_pause+0x7e>

0000000080002af0 <sys_kill>:

uint64
sys_kill(void)
{
    80002af0:	1101                	addi	sp,sp,-32
    80002af2:	ec06                	sd	ra,24(sp)
    80002af4:	e822                	sd	s0,16(sp)
    80002af6:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002af8:	fec40593          	addi	a1,s0,-20
    80002afc:	4501                	li	a0,0
    80002afe:	da5ff0ef          	jal	800028a2 <argint>
  return kkill(pid);
    80002b02:	fec42503          	lw	a0,-20(s0)
    80002b06:	e30ff0ef          	jal	80002136 <kkill>
}
    80002b0a:	60e2                	ld	ra,24(sp)
    80002b0c:	6442                	ld	s0,16(sp)
    80002b0e:	6105                	addi	sp,sp,32
    80002b10:	8082                	ret

0000000080002b12 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002b12:	1101                	addi	sp,sp,-32
    80002b14:	ec06                	sd	ra,24(sp)
    80002b16:	e822                	sd	s0,16(sp)
    80002b18:	e426                	sd	s1,8(sp)
    80002b1a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b1c:	00055517          	auipc	a0,0x55
    80002b20:	69c50513          	addi	a0,a0,1692 # 800581b8 <tickslock>
    80002b24:	904fe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002b28:	00005797          	auipc	a5,0x5
    80002b2c:	d607a783          	lw	a5,-672(a5) # 80007888 <ticks>
    80002b30:	84be                	mv	s1,a5
  release(&tickslock);
    80002b32:	00055517          	auipc	a0,0x55
    80002b36:	68650513          	addi	a0,a0,1670 # 800581b8 <tickslock>
    80002b3a:	982fe0ef          	jal	80000cbc <release>
  return xticks;
}
    80002b3e:	02049513          	slli	a0,s1,0x20
    80002b42:	9101                	srli	a0,a0,0x20
    80002b44:	60e2                	ld	ra,24(sp)
    80002b46:	6442                	ld	s0,16(sp)
    80002b48:	64a2                	ld	s1,8(sp)
    80002b4a:	6105                	addi	sp,sp,32
    80002b4c:	8082                	ret

0000000080002b4e <enqueue_msg>:
#include "msgqueue.h"

static int
enqueue_msg(struct proc *dst, int sender_pid, char *data, int size)
{
    if (size <= 0 || size > MAX_MSG_SIZE)
    80002b4e:	fff6871b          	addiw	a4,a3,-1 # fff <_entry-0x7ffff001>
    80002b52:	0ff00793          	li	a5,255
    80002b56:	0ae7ed63          	bltu	a5,a4,80002c10 <enqueue_msg+0xc2>
{
    80002b5a:	7139                	addi	sp,sp,-64
    80002b5c:	fc06                	sd	ra,56(sp)
    80002b5e:	f822                	sd	s0,48(sp)
    80002b60:	f426                	sd	s1,40(sp)
    80002b62:	ec4e                	sd	s3,24(sp)
    80002b64:	e852                	sd	s4,16(sp)
    80002b66:	e456                	sd	s5,8(sp)
    80002b68:	e05a                	sd	s6,0(sp)
    80002b6a:	0080                	addi	s0,sp,64
    80002b6c:	84aa                	mv	s1,a0
    80002b6e:	8aae                	mv	s5,a1
    80002b70:	8b32                	mv	s6,a2
    80002b72:	8a36                	mv	s4,a3
        return -1;

    acquire(&dst->mq.lock);
    80002b74:	6985                	lui	s3,0x1
    80002b76:	1f898993          	addi	s3,s3,504 # 11f8 <_entry-0x7fffee08>
    80002b7a:	99aa                	add	s3,s3,a0
    80002b7c:	854e                	mv	a0,s3
    80002b7e:	8aafe0ef          	jal	80000c28 <acquire>

    if (dst->mq.count == MSG_QUEUE_LEN) {
    80002b82:	6785                	lui	a5,0x1
    80002b84:	97a6                	add	a5,a5,s1
    80002b86:	1f07a703          	lw	a4,496(a5) # 11f0 <_entry-0x7fffee10>
    80002b8a:	47c1                	li	a5,16
    80002b8c:	06f70d63          	beq	a4,a5,80002c06 <enqueue_msg+0xb8>
    80002b90:	f04a                	sd	s2,32(sp)
        release(&dst->mq.lock);
        return -1;
    }

    struct message *m = &dst->mq.buf[dst->mq.tail];
    80002b92:	6905                	lui	s2,0x1
    80002b94:	9926                	add	s2,s2,s1
    80002b96:	1ec92703          	lw	a4,492(s2) # 11ec <_entry-0x7fffee14>
    m->sender_pid = sender_pid;
    80002b9a:	00571513          	slli	a0,a4,0x5
    80002b9e:	00e507b3          	add	a5,a0,a4
    80002ba2:	078e                	slli	a5,a5,0x3
    80002ba4:	97a6                	add	a5,a5,s1
    80002ba6:	1757a423          	sw	s5,360(a5)
    m->size       = size;
    80002baa:	1747a623          	sw	s4,364(a5)
    memmove(m->data, data, size);
    80002bae:	953a                	add	a0,a0,a4
    80002bb0:	050e                	slli	a0,a0,0x3
    80002bb2:	17050513          	addi	a0,a0,368
    80002bb6:	8652                	mv	a2,s4
    80002bb8:	85da                	mv	a1,s6
    80002bba:	9526                	add	a0,a0,s1
    80002bbc:	99cfe0ef          	jal	80000d58 <memmove>

    dst->mq.tail  = (dst->mq.tail + 1) % MSG_QUEUE_LEN;
    80002bc0:	1ec92783          	lw	a5,492(s2)
    80002bc4:	2785                	addiw	a5,a5,1
    80002bc6:	41f7d71b          	sraiw	a4,a5,0x1f
    80002bca:	01c7571b          	srliw	a4,a4,0x1c
    80002bce:	9fb9                	addw	a5,a5,a4
    80002bd0:	8bbd                	andi	a5,a5,15
    80002bd2:	9f99                	subw	a5,a5,a4
    80002bd4:	1ef92623          	sw	a5,492(s2)
    dst->mq.count++;
    80002bd8:	1f092783          	lw	a5,496(s2)
    80002bdc:	2785                	addiw	a5,a5,1
    80002bde:	1ef92823          	sw	a5,496(s2)

    wakeup(&dst->mq);
    80002be2:	16848513          	addi	a0,s1,360
    80002be6:	bdaff0ef          	jal	80001fc0 <wakeup>
    release(&dst->mq.lock);
    80002bea:	854e                	mv	a0,s3
    80002bec:	8d0fe0ef          	jal	80000cbc <release>
    return 0;
    80002bf0:	4501                	li	a0,0
    80002bf2:	7902                	ld	s2,32(sp)
}
    80002bf4:	70e2                	ld	ra,56(sp)
    80002bf6:	7442                	ld	s0,48(sp)
    80002bf8:	74a2                	ld	s1,40(sp)
    80002bfa:	69e2                	ld	s3,24(sp)
    80002bfc:	6a42                	ld	s4,16(sp)
    80002bfe:	6aa2                	ld	s5,8(sp)
    80002c00:	6b02                	ld	s6,0(sp)
    80002c02:	6121                	addi	sp,sp,64
    80002c04:	8082                	ret
        release(&dst->mq.lock);
    80002c06:	854e                	mv	a0,s3
    80002c08:	8b4fe0ef          	jal	80000cbc <release>
        return -1;
    80002c0c:	557d                	li	a0,-1
    80002c0e:	b7dd                	j	80002bf4 <enqueue_msg+0xa6>
        return -1;
    80002c10:	557d                	li	a0,-1
}
    80002c12:	8082                	ret

0000000080002c14 <sys_sendmsg>:

uint64
sys_sendmsg(void)
{
    80002c14:	7169                	addi	sp,sp,-304
    80002c16:	f606                	sd	ra,296(sp)
    80002c18:	f222                	sd	s0,288(sp)
    80002c1a:	1a00                	addi	s0,sp,304
    int    target_pid, size;
    uint64 buf_addr;

    argint(0, &target_pid);
    80002c1c:	fdc40593          	addi	a1,s0,-36
    80002c20:	4501                	li	a0,0
    80002c22:	c81ff0ef          	jal	800028a2 <argint>
    argaddr(1, &buf_addr);
    80002c26:	fd040593          	addi	a1,s0,-48
    80002c2a:	4505                	li	a0,1
    80002c2c:	c93ff0ef          	jal	800028be <argaddr>
    argint(2, &size);
    80002c30:	fd840593          	addi	a1,s0,-40
    80002c34:	4509                	li	a0,2
    80002c36:	c6dff0ef          	jal	800028a2 <argint>

    if (size <= 0 || size > MAX_MSG_SIZE)
    80002c3a:	fd842783          	lw	a5,-40(s0)
    80002c3e:	37fd                	addiw	a5,a5,-1
    80002c40:	0ff00713          	li	a4,255
        return -1;
    80002c44:	557d                	li	a0,-1
    if (size <= 0 || size > MAX_MSG_SIZE)
    80002c46:	06f76163          	bltu	a4,a5,80002ca8 <sys_sendmsg+0x94>

    char kbuf[MAX_MSG_SIZE];
    if (copyin(myproc()->pagetable, kbuf, buf_addr, size) < 0)
    80002c4a:	cebfe0ef          	jal	80001934 <myproc>
    80002c4e:	fd842683          	lw	a3,-40(s0)
    80002c52:	fd043603          	ld	a2,-48(s0)
    80002c56:	ed040593          	addi	a1,s0,-304
    80002c5a:	6928                	ld	a0,80(a0)
    80002c5c:	ab7fe0ef          	jal	80001712 <copyin>
    80002c60:	04054b63          	bltz	a0,80002cb6 <sys_sendmsg+0xa2>
    80002c64:	ee26                	sd	s1,280(sp)
        return -1;

    struct proc *target = 0;
    extern struct proc proc[];
    for (struct proc *p = proc; p < &proc[NPROC]; p++) {
        if (p->pid == target_pid && p->state != UNUSED) {
    80002c66:	fdc42683          	lw	a3,-36(s0)
    for (struct proc *p = proc; p < &proc[NPROC]; p++) {
    80002c6a:	0000d497          	auipc	s1,0xd
    80002c6e:	14e48493          	addi	s1,s1,334 # 8000fdb8 <proc>
    80002c72:	6705                	lui	a4,0x1
    80002c74:	21070713          	addi	a4,a4,528 # 1210 <_entry-0x7fffedf0>
    80002c78:	00055617          	auipc	a2,0x55
    80002c7c:	54060613          	addi	a2,a2,1344 # 800581b8 <tickslock>
    80002c80:	a021                	j	80002c88 <sys_sendmsg+0x74>
    80002c82:	94ba                	add	s1,s1,a4
    80002c84:	02c48663          	beq	s1,a2,80002cb0 <sys_sendmsg+0x9c>
        if (p->pid == target_pid && p->state != UNUSED) {
    80002c88:	589c                	lw	a5,48(s1)
    80002c8a:	fed79ce3          	bne	a5,a3,80002c82 <sys_sendmsg+0x6e>
    80002c8e:	4c9c                	lw	a5,24(s1)
    80002c90:	dbed                	beqz	a5,80002c82 <sys_sendmsg+0x6e>
        }
    }
    if (!target)
        return -1;

    return enqueue_msg(target, myproc()->pid, kbuf, size);
    80002c92:	ca3fe0ef          	jal	80001934 <myproc>
    80002c96:	fd842683          	lw	a3,-40(s0)
    80002c9a:	ed040613          	addi	a2,s0,-304
    80002c9e:	590c                	lw	a1,48(a0)
    80002ca0:	8526                	mv	a0,s1
    80002ca2:	eadff0ef          	jal	80002b4e <enqueue_msg>
    80002ca6:	64f2                	ld	s1,280(sp)
}
    80002ca8:	70b2                	ld	ra,296(sp)
    80002caa:	7412                	ld	s0,288(sp)
    80002cac:	6155                	addi	sp,sp,304
    80002cae:	8082                	ret
        return -1;
    80002cb0:	557d                	li	a0,-1
    80002cb2:	64f2                	ld	s1,280(sp)
    80002cb4:	bfd5                	j	80002ca8 <sys_sendmsg+0x94>
        return -1;
    80002cb6:	557d                	li	a0,-1
    80002cb8:	bfc5                	j	80002ca8 <sys_sendmsg+0x94>

0000000080002cba <sys_recvmsg>:

uint64
sys_recvmsg(void)
{
    80002cba:	7139                	addi	sp,sp,-64
    80002cbc:	fc06                	sd	ra,56(sp)
    80002cbe:	f822                	sd	s0,48(sp)
    80002cc0:	f426                	sd	s1,40(sp)
    80002cc2:	f04a                	sd	s2,32(sp)
    80002cc4:	ec4e                	sd	s3,24(sp)
    80002cc6:	0080                	addi	s0,sp,64
    uint64 buf_addr;
    int    size;

    argaddr(0, &buf_addr);
    80002cc8:	fc840593          	addi	a1,s0,-56
    80002ccc:	4501                	li	a0,0
    80002cce:	bf1ff0ef          	jal	800028be <argaddr>
    argint(1, &size);
    80002cd2:	fc440593          	addi	a1,s0,-60
    80002cd6:	4505                	li	a0,1
    80002cd8:	bcbff0ef          	jal	800028a2 <argint>

    struct proc *p = myproc();
    80002cdc:	c59fe0ef          	jal	80001934 <myproc>
    80002ce0:	892a                	mv	s2,a0

    acquire(&p->mq.lock);
    80002ce2:	6485                	lui	s1,0x1
    80002ce4:	1f848493          	addi	s1,s1,504 # 11f8 <_entry-0x7fffee08>
    80002ce8:	94aa                	add	s1,s1,a0
    80002cea:	8526                	mv	a0,s1
    80002cec:	f3dfd0ef          	jal	80000c28 <acquire>

    while (p->mq.count == 0) {
    80002cf0:	6785                	lui	a5,0x1
    80002cf2:	97ca                	add	a5,a5,s2
    80002cf4:	1f07a783          	lw	a5,496(a5) # 11f0 <_entry-0x7fffee10>
    80002cf8:	ef91                	bnez	a5,80002d14 <sys_recvmsg+0x5a>
    80002cfa:	e852                	sd	s4,16(sp)
        sleep(&p->mq, &p->mq.lock);
    80002cfc:	16890a13          	addi	s4,s2,360
    while (p->mq.count == 0) {
    80002d00:	6985                	lui	s3,0x1
    80002d02:	99ca                	add	s3,s3,s2
        sleep(&p->mq, &p->mq.lock);
    80002d04:	85a6                	mv	a1,s1
    80002d06:	8552                	mv	a0,s4
    80002d08:	a6cff0ef          	jal	80001f74 <sleep>
    while (p->mq.count == 0) {
    80002d0c:	1f09a783          	lw	a5,496(s3) # 11f0 <_entry-0x7fffee10>
    80002d10:	dbf5                	beqz	a5,80002d04 <sys_recvmsg+0x4a>
    80002d12:	6a42                	ld	s4,16(sp)
    }

    struct message *m = &p->mq.buf[p->mq.head];
    80002d14:	6785                	lui	a5,0x1
    80002d16:	97ca                	add	a5,a5,s2
    80002d18:	1e87a983          	lw	s3,488(a5) # 11e8 <_entry-0x7fffee18>
    int copy_len = (m->size < size) ? m->size : size;
    80002d1c:	00599793          	slli	a5,s3,0x5
    80002d20:	97ce                	add	a5,a5,s3
    80002d22:	078e                	slli	a5,a5,0x3
    80002d24:	97ca                	add	a5,a5,s2
    80002d26:	fc442703          	lw	a4,-60(s0)
    80002d2a:	16c7a783          	lw	a5,364(a5)
    80002d2e:	86be                	mv	a3,a5
    80002d30:	2781                	sext.w	a5,a5
    80002d32:	00f75363          	bge	a4,a5,80002d38 <sys_recvmsg+0x7e>
    80002d36:	86ba                	mv	a3,a4

    if (copyout(p->pagetable, buf_addr, m->data, copy_len) < 0) {
    80002d38:	00599613          	slli	a2,s3,0x5
    80002d3c:	964e                	add	a2,a2,s3
    80002d3e:	060e                	slli	a2,a2,0x3
    80002d40:	17060613          	addi	a2,a2,368
    80002d44:	2681                	sext.w	a3,a3
    80002d46:	964a                	add	a2,a2,s2
    80002d48:	fc843583          	ld	a1,-56(s0)
    80002d4c:	05093503          	ld	a0,80(s2)
    80002d50:	905fe0ef          	jal	80001654 <copyout>
    80002d54:	04054663          	bltz	a0,80002da0 <sys_recvmsg+0xe6>
        release(&p->mq.lock);
        return -1;
    }

    p->mq.head  = (p->mq.head + 1) % MSG_QUEUE_LEN;
    80002d58:	6705                	lui	a4,0x1
    80002d5a:	974a                	add	a4,a4,s2
    80002d5c:	1e872783          	lw	a5,488(a4) # 11e8 <_entry-0x7fffee18>
    80002d60:	2785                	addiw	a5,a5,1
    80002d62:	41f7d69b          	sraiw	a3,a5,0x1f
    80002d66:	01c6d69b          	srliw	a3,a3,0x1c
    80002d6a:	9fb5                	addw	a5,a5,a3
    80002d6c:	8bbd                	andi	a5,a5,15
    80002d6e:	9f95                	subw	a5,a5,a3
    80002d70:	1ef72423          	sw	a5,488(a4)
    p->mq.count--;
    80002d74:	1f072783          	lw	a5,496(a4)
    80002d78:	37fd                	addiw	a5,a5,-1
    80002d7a:	1ef72823          	sw	a5,496(a4)

    release(&p->mq.lock);
    80002d7e:	8526                	mv	a0,s1
    80002d80:	f3dfd0ef          	jal	80000cbc <release>
    return m->sender_pid;
    80002d84:	00599793          	slli	a5,s3,0x5
    80002d88:	97ce                	add	a5,a5,s3
    80002d8a:	078e                	slli	a5,a5,0x3
    80002d8c:	993e                	add	s2,s2,a5
    80002d8e:	16892503          	lw	a0,360(s2)
}
    80002d92:	70e2                	ld	ra,56(sp)
    80002d94:	7442                	ld	s0,48(sp)
    80002d96:	74a2                	ld	s1,40(sp)
    80002d98:	7902                	ld	s2,32(sp)
    80002d9a:	69e2                	ld	s3,24(sp)
    80002d9c:	6121                	addi	sp,sp,64
    80002d9e:	8082                	ret
        release(&p->mq.lock);
    80002da0:	8526                	mv	a0,s1
    80002da2:	f1bfd0ef          	jal	80000cbc <release>
        return -1;
    80002da6:	557d                	li	a0,-1
    80002da8:	b7ed                	j	80002d92 <sys_recvmsg+0xd8>

0000000080002daa <sys_broadcast>:

uint64
sys_broadcast(void)
{
    80002daa:	714d                	addi	sp,sp,-336
    80002dac:	e686                	sd	ra,328(sp)
    80002dae:	e2a2                	sd	s0,320(sp)
    80002db0:	0a80                	addi	s0,sp,336
    uint64 buf_addr;
    int    size;

    argaddr(0, &buf_addr);
    80002db2:	fb840593          	addi	a1,s0,-72
    80002db6:	4501                	li	a0,0
    80002db8:	b07ff0ef          	jal	800028be <argaddr>
    argint(1, &size);
    80002dbc:	fb440593          	addi	a1,s0,-76
    80002dc0:	4505                	li	a0,1
    80002dc2:	ae1ff0ef          	jal	800028a2 <argint>

    if (size <= 0 || size > MAX_MSG_SIZE)
    80002dc6:	fb442783          	lw	a5,-76(s0)
    80002dca:	37fd                	addiw	a5,a5,-1
    80002dcc:	0ff00713          	li	a4,255
        return -1;
    80002dd0:	557d                	li	a0,-1
    if (size <= 0 || size > MAX_MSG_SIZE)
    80002dd2:	08f76363          	bltu	a4,a5,80002e58 <sys_broadcast+0xae>

    char kbuf[MAX_MSG_SIZE];
    if (copyin(myproc()->pagetable, kbuf, buf_addr, size) < 0)
    80002dd6:	b5ffe0ef          	jal	80001934 <myproc>
    80002dda:	fb442683          	lw	a3,-76(s0)
    80002dde:	fb843603          	ld	a2,-72(s0)
    80002de2:	eb040593          	addi	a1,s0,-336
    80002de6:	6928                	ld	a0,80(a0)
    80002de8:	92bfe0ef          	jal	80001712 <copyin>
    80002dec:	87aa                	mv	a5,a0
        return -1;
    80002dee:	557d                	li	a0,-1
    if (copyin(myproc()->pagetable, kbuf, buf_addr, size) < 0)
    80002df0:	0607c463          	bltz	a5,80002e58 <sys_broadcast+0xae>
    80002df4:	fe26                	sd	s1,312(sp)
    80002df6:	fa4a                	sd	s2,304(sp)
    80002df8:	f64e                	sd	s3,296(sp)
    80002dfa:	f252                	sd	s4,288(sp)
    80002dfc:	ee56                	sd	s5,280(sp)
    80002dfe:	ea5a                	sd	s6,272(sp)

    int sender_pid = myproc()->pid;
    80002e00:	b35fe0ef          	jal	80001934 <myproc>
    80002e04:	03052903          	lw	s2,48(a0)
    int count = 0;
    extern struct proc proc[];

    for (struct proc *p = proc; p < &proc[NPROC]; p++) {
    80002e08:	0000d497          	auipc	s1,0xd
    80002e0c:	fb048493          	addi	s1,s1,-80 # 8000fdb8 <proc>
    int count = 0;
    80002e10:	4a81                	li	s5,0
        if (p->pid != sender_pid && p->state != UNUSED) {
            if (enqueue_msg(p, sender_pid, kbuf, size) == 0)
    80002e12:	eb040b13          	addi	s6,s0,-336
    for (struct proc *p = proc; p < &proc[NPROC]; p++) {
    80002e16:	6985                	lui	s3,0x1
    80002e18:	21098993          	addi	s3,s3,528 # 1210 <_entry-0x7fffedf0>
    80002e1c:	00055a17          	auipc	s4,0x55
    80002e20:	39ca0a13          	addi	s4,s4,924 # 800581b8 <tickslock>
    80002e24:	a021                	j	80002e2c <sys_broadcast+0x82>
    80002e26:	94ce                	add	s1,s1,s3
    80002e28:	03448163          	beq	s1,s4,80002e4a <sys_broadcast+0xa0>
        if (p->pid != sender_pid && p->state != UNUSED) {
    80002e2c:	589c                	lw	a5,48(s1)
    80002e2e:	ff278ce3          	beq	a5,s2,80002e26 <sys_broadcast+0x7c>
    80002e32:	4c9c                	lw	a5,24(s1)
    80002e34:	dbed                	beqz	a5,80002e26 <sys_broadcast+0x7c>
            if (enqueue_msg(p, sender_pid, kbuf, size) == 0)
    80002e36:	fb442683          	lw	a3,-76(s0)
    80002e3a:	865a                	mv	a2,s6
    80002e3c:	85ca                	mv	a1,s2
    80002e3e:	8526                	mv	a0,s1
    80002e40:	d0fff0ef          	jal	80002b4e <enqueue_msg>
    80002e44:	f16d                	bnez	a0,80002e26 <sys_broadcast+0x7c>
                count++;
    80002e46:	2a85                	addiw	s5,s5,1
    80002e48:	bff9                	j	80002e26 <sys_broadcast+0x7c>
        }
    }

    return count;
    80002e4a:	8556                	mv	a0,s5
    80002e4c:	74f2                	ld	s1,312(sp)
    80002e4e:	7952                	ld	s2,304(sp)
    80002e50:	79b2                	ld	s3,296(sp)
    80002e52:	7a12                	ld	s4,288(sp)
    80002e54:	6af2                	ld	s5,280(sp)
    80002e56:	6b52                	ld	s6,272(sp)
}
    80002e58:	60b6                	ld	ra,328(sp)
    80002e5a:	6416                	ld	s0,320(sp)
    80002e5c:	6171                	addi	sp,sp,336
    80002e5e:	8082                	ret

0000000080002e60 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e60:	7179                	addi	sp,sp,-48
    80002e62:	f406                	sd	ra,40(sp)
    80002e64:	f022                	sd	s0,32(sp)
    80002e66:	ec26                	sd	s1,24(sp)
    80002e68:	e84a                	sd	s2,16(sp)
    80002e6a:	e44e                	sd	s3,8(sp)
    80002e6c:	e052                	sd	s4,0(sp)
    80002e6e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e70:	00004597          	auipc	a1,0x4
    80002e74:	53058593          	addi	a1,a1,1328 # 800073a0 <etext+0x3a0>
    80002e78:	00055517          	auipc	a0,0x55
    80002e7c:	35850513          	addi	a0,a0,856 # 800581d0 <bcache>
    80002e80:	d1ffd0ef          	jal	80000b9e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e84:	0005d797          	auipc	a5,0x5d
    80002e88:	34c78793          	addi	a5,a5,844 # 800601d0 <bcache+0x8000>
    80002e8c:	0005d717          	auipc	a4,0x5d
    80002e90:	5ac70713          	addi	a4,a4,1452 # 80060438 <bcache+0x8268>
    80002e94:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e98:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e9c:	00055497          	auipc	s1,0x55
    80002ea0:	34c48493          	addi	s1,s1,844 # 800581e8 <bcache+0x18>
    b->next = bcache.head.next;
    80002ea4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ea6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ea8:	00004a17          	auipc	s4,0x4
    80002eac:	500a0a13          	addi	s4,s4,1280 # 800073a8 <etext+0x3a8>
    b->next = bcache.head.next;
    80002eb0:	2b893783          	ld	a5,696(s2)
    80002eb4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002eb6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002eba:	85d2                	mv	a1,s4
    80002ebc:	01048513          	addi	a0,s1,16
    80002ec0:	328010ef          	jal	800041e8 <initsleeplock>
    bcache.head.next->prev = b;
    80002ec4:	2b893783          	ld	a5,696(s2)
    80002ec8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002eca:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ece:	45848493          	addi	s1,s1,1112
    80002ed2:	fd349fe3          	bne	s1,s3,80002eb0 <binit+0x50>
  }
}
    80002ed6:	70a2                	ld	ra,40(sp)
    80002ed8:	7402                	ld	s0,32(sp)
    80002eda:	64e2                	ld	s1,24(sp)
    80002edc:	6942                	ld	s2,16(sp)
    80002ede:	69a2                	ld	s3,8(sp)
    80002ee0:	6a02                	ld	s4,0(sp)
    80002ee2:	6145                	addi	sp,sp,48
    80002ee4:	8082                	ret

0000000080002ee6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ee6:	7179                	addi	sp,sp,-48
    80002ee8:	f406                	sd	ra,40(sp)
    80002eea:	f022                	sd	s0,32(sp)
    80002eec:	ec26                	sd	s1,24(sp)
    80002eee:	e84a                	sd	s2,16(sp)
    80002ef0:	e44e                	sd	s3,8(sp)
    80002ef2:	1800                	addi	s0,sp,48
    80002ef4:	892a                	mv	s2,a0
    80002ef6:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ef8:	00055517          	auipc	a0,0x55
    80002efc:	2d850513          	addi	a0,a0,728 # 800581d0 <bcache>
    80002f00:	d29fd0ef          	jal	80000c28 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f04:	0005d497          	auipc	s1,0x5d
    80002f08:	5844b483          	ld	s1,1412(s1) # 80060488 <bcache+0x82b8>
    80002f0c:	0005d797          	auipc	a5,0x5d
    80002f10:	52c78793          	addi	a5,a5,1324 # 80060438 <bcache+0x8268>
    80002f14:	02f48b63          	beq	s1,a5,80002f4a <bread+0x64>
    80002f18:	873e                	mv	a4,a5
    80002f1a:	a021                	j	80002f22 <bread+0x3c>
    80002f1c:	68a4                	ld	s1,80(s1)
    80002f1e:	02e48663          	beq	s1,a4,80002f4a <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002f22:	449c                	lw	a5,8(s1)
    80002f24:	ff279ce3          	bne	a5,s2,80002f1c <bread+0x36>
    80002f28:	44dc                	lw	a5,12(s1)
    80002f2a:	ff3799e3          	bne	a5,s3,80002f1c <bread+0x36>
      b->refcnt++;
    80002f2e:	40bc                	lw	a5,64(s1)
    80002f30:	2785                	addiw	a5,a5,1
    80002f32:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f34:	00055517          	auipc	a0,0x55
    80002f38:	29c50513          	addi	a0,a0,668 # 800581d0 <bcache>
    80002f3c:	d81fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002f40:	01048513          	addi	a0,s1,16
    80002f44:	2da010ef          	jal	8000421e <acquiresleep>
      return b;
    80002f48:	a889                	j	80002f9a <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f4a:	0005d497          	auipc	s1,0x5d
    80002f4e:	5364b483          	ld	s1,1334(s1) # 80060480 <bcache+0x82b0>
    80002f52:	0005d797          	auipc	a5,0x5d
    80002f56:	4e678793          	addi	a5,a5,1254 # 80060438 <bcache+0x8268>
    80002f5a:	00f48863          	beq	s1,a5,80002f6a <bread+0x84>
    80002f5e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f60:	40bc                	lw	a5,64(s1)
    80002f62:	cb91                	beqz	a5,80002f76 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f64:	64a4                	ld	s1,72(s1)
    80002f66:	fee49de3          	bne	s1,a4,80002f60 <bread+0x7a>
  panic("bget: no buffers");
    80002f6a:	00004517          	auipc	a0,0x4
    80002f6e:	44650513          	addi	a0,a0,1094 # 800073b0 <etext+0x3b0>
    80002f72:	8b3fd0ef          	jal	80000824 <panic>
      b->dev = dev;
    80002f76:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f7a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f7e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f82:	4785                	li	a5,1
    80002f84:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f86:	00055517          	auipc	a0,0x55
    80002f8a:	24a50513          	addi	a0,a0,586 # 800581d0 <bcache>
    80002f8e:	d2ffd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002f92:	01048513          	addi	a0,s1,16
    80002f96:	288010ef          	jal	8000421e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f9a:	409c                	lw	a5,0(s1)
    80002f9c:	cb89                	beqz	a5,80002fae <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f9e:	8526                	mv	a0,s1
    80002fa0:	70a2                	ld	ra,40(sp)
    80002fa2:	7402                	ld	s0,32(sp)
    80002fa4:	64e2                	ld	s1,24(sp)
    80002fa6:	6942                	ld	s2,16(sp)
    80002fa8:	69a2                	ld	s3,8(sp)
    80002faa:	6145                	addi	sp,sp,48
    80002fac:	8082                	ret
    virtio_disk_rw(b, 0);
    80002fae:	4581                	li	a1,0
    80002fb0:	8526                	mv	a0,s1
    80002fb2:	2ef020ef          	jal	80005aa0 <virtio_disk_rw>
    b->valid = 1;
    80002fb6:	4785                	li	a5,1
    80002fb8:	c09c                	sw	a5,0(s1)
  return b;
    80002fba:	b7d5                	j	80002f9e <bread+0xb8>

0000000080002fbc <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002fbc:	1101                	addi	sp,sp,-32
    80002fbe:	ec06                	sd	ra,24(sp)
    80002fc0:	e822                	sd	s0,16(sp)
    80002fc2:	e426                	sd	s1,8(sp)
    80002fc4:	1000                	addi	s0,sp,32
    80002fc6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fc8:	0541                	addi	a0,a0,16
    80002fca:	2d2010ef          	jal	8000429c <holdingsleep>
    80002fce:	c911                	beqz	a0,80002fe2 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002fd0:	4585                	li	a1,1
    80002fd2:	8526                	mv	a0,s1
    80002fd4:	2cd020ef          	jal	80005aa0 <virtio_disk_rw>
}
    80002fd8:	60e2                	ld	ra,24(sp)
    80002fda:	6442                	ld	s0,16(sp)
    80002fdc:	64a2                	ld	s1,8(sp)
    80002fde:	6105                	addi	sp,sp,32
    80002fe0:	8082                	ret
    panic("bwrite");
    80002fe2:	00004517          	auipc	a0,0x4
    80002fe6:	3e650513          	addi	a0,a0,998 # 800073c8 <etext+0x3c8>
    80002fea:	83bfd0ef          	jal	80000824 <panic>

0000000080002fee <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002fee:	1101                	addi	sp,sp,-32
    80002ff0:	ec06                	sd	ra,24(sp)
    80002ff2:	e822                	sd	s0,16(sp)
    80002ff4:	e426                	sd	s1,8(sp)
    80002ff6:	e04a                	sd	s2,0(sp)
    80002ff8:	1000                	addi	s0,sp,32
    80002ffa:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ffc:	01050913          	addi	s2,a0,16
    80003000:	854a                	mv	a0,s2
    80003002:	29a010ef          	jal	8000429c <holdingsleep>
    80003006:	c125                	beqz	a0,80003066 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80003008:	854a                	mv	a0,s2
    8000300a:	25a010ef          	jal	80004264 <releasesleep>

  acquire(&bcache.lock);
    8000300e:	00055517          	auipc	a0,0x55
    80003012:	1c250513          	addi	a0,a0,450 # 800581d0 <bcache>
    80003016:	c13fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    8000301a:	40bc                	lw	a5,64(s1)
    8000301c:	37fd                	addiw	a5,a5,-1
    8000301e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003020:	e79d                	bnez	a5,8000304e <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003022:	68b8                	ld	a4,80(s1)
    80003024:	64bc                	ld	a5,72(s1)
    80003026:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003028:	68b8                	ld	a4,80(s1)
    8000302a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000302c:	0005d797          	auipc	a5,0x5d
    80003030:	1a478793          	addi	a5,a5,420 # 800601d0 <bcache+0x8000>
    80003034:	2b87b703          	ld	a4,696(a5)
    80003038:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000303a:	0005d717          	auipc	a4,0x5d
    8000303e:	3fe70713          	addi	a4,a4,1022 # 80060438 <bcache+0x8268>
    80003042:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003044:	2b87b703          	ld	a4,696(a5)
    80003048:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000304a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000304e:	00055517          	auipc	a0,0x55
    80003052:	18250513          	addi	a0,a0,386 # 800581d0 <bcache>
    80003056:	c67fd0ef          	jal	80000cbc <release>
}
    8000305a:	60e2                	ld	ra,24(sp)
    8000305c:	6442                	ld	s0,16(sp)
    8000305e:	64a2                	ld	s1,8(sp)
    80003060:	6902                	ld	s2,0(sp)
    80003062:	6105                	addi	sp,sp,32
    80003064:	8082                	ret
    panic("brelse");
    80003066:	00004517          	auipc	a0,0x4
    8000306a:	36a50513          	addi	a0,a0,874 # 800073d0 <etext+0x3d0>
    8000306e:	fb6fd0ef          	jal	80000824 <panic>

0000000080003072 <bpin>:

void
bpin(struct buf *b) {
    80003072:	1101                	addi	sp,sp,-32
    80003074:	ec06                	sd	ra,24(sp)
    80003076:	e822                	sd	s0,16(sp)
    80003078:	e426                	sd	s1,8(sp)
    8000307a:	1000                	addi	s0,sp,32
    8000307c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000307e:	00055517          	auipc	a0,0x55
    80003082:	15250513          	addi	a0,a0,338 # 800581d0 <bcache>
    80003086:	ba3fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    8000308a:	40bc                	lw	a5,64(s1)
    8000308c:	2785                	addiw	a5,a5,1
    8000308e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003090:	00055517          	auipc	a0,0x55
    80003094:	14050513          	addi	a0,a0,320 # 800581d0 <bcache>
    80003098:	c25fd0ef          	jal	80000cbc <release>
}
    8000309c:	60e2                	ld	ra,24(sp)
    8000309e:	6442                	ld	s0,16(sp)
    800030a0:	64a2                	ld	s1,8(sp)
    800030a2:	6105                	addi	sp,sp,32
    800030a4:	8082                	ret

00000000800030a6 <bunpin>:

void
bunpin(struct buf *b) {
    800030a6:	1101                	addi	sp,sp,-32
    800030a8:	ec06                	sd	ra,24(sp)
    800030aa:	e822                	sd	s0,16(sp)
    800030ac:	e426                	sd	s1,8(sp)
    800030ae:	1000                	addi	s0,sp,32
    800030b0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030b2:	00055517          	auipc	a0,0x55
    800030b6:	11e50513          	addi	a0,a0,286 # 800581d0 <bcache>
    800030ba:	b6ffd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    800030be:	40bc                	lw	a5,64(s1)
    800030c0:	37fd                	addiw	a5,a5,-1
    800030c2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030c4:	00055517          	auipc	a0,0x55
    800030c8:	10c50513          	addi	a0,a0,268 # 800581d0 <bcache>
    800030cc:	bf1fd0ef          	jal	80000cbc <release>
}
    800030d0:	60e2                	ld	ra,24(sp)
    800030d2:	6442                	ld	s0,16(sp)
    800030d4:	64a2                	ld	s1,8(sp)
    800030d6:	6105                	addi	sp,sp,32
    800030d8:	8082                	ret

00000000800030da <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800030da:	1101                	addi	sp,sp,-32
    800030dc:	ec06                	sd	ra,24(sp)
    800030de:	e822                	sd	s0,16(sp)
    800030e0:	e426                	sd	s1,8(sp)
    800030e2:	e04a                	sd	s2,0(sp)
    800030e4:	1000                	addi	s0,sp,32
    800030e6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030e8:	00d5d79b          	srliw	a5,a1,0xd
    800030ec:	0005d597          	auipc	a1,0x5d
    800030f0:	7c05a583          	lw	a1,1984(a1) # 800608ac <sb+0x1c>
    800030f4:	9dbd                	addw	a1,a1,a5
    800030f6:	df1ff0ef          	jal	80002ee6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800030fa:	0074f713          	andi	a4,s1,7
    800030fe:	4785                	li	a5,1
    80003100:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80003104:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80003106:	90d9                	srli	s1,s1,0x36
    80003108:	00950733          	add	a4,a0,s1
    8000310c:	05874703          	lbu	a4,88(a4)
    80003110:	00e7f6b3          	and	a3,a5,a4
    80003114:	c29d                	beqz	a3,8000313a <bfree+0x60>
    80003116:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003118:	94aa                	add	s1,s1,a0
    8000311a:	fff7c793          	not	a5,a5
    8000311e:	8f7d                	and	a4,a4,a5
    80003120:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003124:	000010ef          	jal	80004124 <log_write>
  brelse(bp);
    80003128:	854a                	mv	a0,s2
    8000312a:	ec5ff0ef          	jal	80002fee <brelse>
}
    8000312e:	60e2                	ld	ra,24(sp)
    80003130:	6442                	ld	s0,16(sp)
    80003132:	64a2                	ld	s1,8(sp)
    80003134:	6902                	ld	s2,0(sp)
    80003136:	6105                	addi	sp,sp,32
    80003138:	8082                	ret
    panic("freeing free block");
    8000313a:	00004517          	auipc	a0,0x4
    8000313e:	29e50513          	addi	a0,a0,670 # 800073d8 <etext+0x3d8>
    80003142:	ee2fd0ef          	jal	80000824 <panic>

0000000080003146 <balloc>:
{
    80003146:	715d                	addi	sp,sp,-80
    80003148:	e486                	sd	ra,72(sp)
    8000314a:	e0a2                	sd	s0,64(sp)
    8000314c:	fc26                	sd	s1,56(sp)
    8000314e:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80003150:	0005d797          	auipc	a5,0x5d
    80003154:	7447a783          	lw	a5,1860(a5) # 80060894 <sb+0x4>
    80003158:	0e078263          	beqz	a5,8000323c <balloc+0xf6>
    8000315c:	f84a                	sd	s2,48(sp)
    8000315e:	f44e                	sd	s3,40(sp)
    80003160:	f052                	sd	s4,32(sp)
    80003162:	ec56                	sd	s5,24(sp)
    80003164:	e85a                	sd	s6,16(sp)
    80003166:	e45e                	sd	s7,8(sp)
    80003168:	e062                	sd	s8,0(sp)
    8000316a:	8baa                	mv	s7,a0
    8000316c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000316e:	0005db17          	auipc	s6,0x5d
    80003172:	722b0b13          	addi	s6,s6,1826 # 80060890 <sb>
      m = 1 << (bi % 8);
    80003176:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003178:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000317a:	6c09                	lui	s8,0x2
    8000317c:	a09d                	j	800031e2 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000317e:	97ca                	add	a5,a5,s2
    80003180:	8e55                	or	a2,a2,a3
    80003182:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003186:	854a                	mv	a0,s2
    80003188:	79d000ef          	jal	80004124 <log_write>
        brelse(bp);
    8000318c:	854a                	mv	a0,s2
    8000318e:	e61ff0ef          	jal	80002fee <brelse>
  bp = bread(dev, bno);
    80003192:	85a6                	mv	a1,s1
    80003194:	855e                	mv	a0,s7
    80003196:	d51ff0ef          	jal	80002ee6 <bread>
    8000319a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000319c:	40000613          	li	a2,1024
    800031a0:	4581                	li	a1,0
    800031a2:	05850513          	addi	a0,a0,88
    800031a6:	b53fd0ef          	jal	80000cf8 <memset>
  log_write(bp);
    800031aa:	854a                	mv	a0,s2
    800031ac:	779000ef          	jal	80004124 <log_write>
  brelse(bp);
    800031b0:	854a                	mv	a0,s2
    800031b2:	e3dff0ef          	jal	80002fee <brelse>
}
    800031b6:	7942                	ld	s2,48(sp)
    800031b8:	79a2                	ld	s3,40(sp)
    800031ba:	7a02                	ld	s4,32(sp)
    800031bc:	6ae2                	ld	s5,24(sp)
    800031be:	6b42                	ld	s6,16(sp)
    800031c0:	6ba2                	ld	s7,8(sp)
    800031c2:	6c02                	ld	s8,0(sp)
}
    800031c4:	8526                	mv	a0,s1
    800031c6:	60a6                	ld	ra,72(sp)
    800031c8:	6406                	ld	s0,64(sp)
    800031ca:	74e2                	ld	s1,56(sp)
    800031cc:	6161                	addi	sp,sp,80
    800031ce:	8082                	ret
    brelse(bp);
    800031d0:	854a                	mv	a0,s2
    800031d2:	e1dff0ef          	jal	80002fee <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800031d6:	015c0abb          	addw	s5,s8,s5
    800031da:	004b2783          	lw	a5,4(s6)
    800031de:	04faf863          	bgeu	s5,a5,8000322e <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    800031e2:	40dad59b          	sraiw	a1,s5,0xd
    800031e6:	01cb2783          	lw	a5,28(s6)
    800031ea:	9dbd                	addw	a1,a1,a5
    800031ec:	855e                	mv	a0,s7
    800031ee:	cf9ff0ef          	jal	80002ee6 <bread>
    800031f2:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031f4:	004b2503          	lw	a0,4(s6)
    800031f8:	84d6                	mv	s1,s5
    800031fa:	4701                	li	a4,0
    800031fc:	fca4fae3          	bgeu	s1,a0,800031d0 <balloc+0x8a>
      m = 1 << (bi % 8);
    80003200:	00777693          	andi	a3,a4,7
    80003204:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003208:	41f7579b          	sraiw	a5,a4,0x1f
    8000320c:	01d7d79b          	srliw	a5,a5,0x1d
    80003210:	9fb9                	addw	a5,a5,a4
    80003212:	4037d79b          	sraiw	a5,a5,0x3
    80003216:	00f90633          	add	a2,s2,a5
    8000321a:	05864603          	lbu	a2,88(a2)
    8000321e:	00c6f5b3          	and	a1,a3,a2
    80003222:	ddb1                	beqz	a1,8000317e <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003224:	2705                	addiw	a4,a4,1
    80003226:	2485                	addiw	s1,s1,1
    80003228:	fd471ae3          	bne	a4,s4,800031fc <balloc+0xb6>
    8000322c:	b755                	j	800031d0 <balloc+0x8a>
    8000322e:	7942                	ld	s2,48(sp)
    80003230:	79a2                	ld	s3,40(sp)
    80003232:	7a02                	ld	s4,32(sp)
    80003234:	6ae2                	ld	s5,24(sp)
    80003236:	6b42                	ld	s6,16(sp)
    80003238:	6ba2                	ld	s7,8(sp)
    8000323a:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    8000323c:	00004517          	auipc	a0,0x4
    80003240:	1b450513          	addi	a0,a0,436 # 800073f0 <etext+0x3f0>
    80003244:	ab6fd0ef          	jal	800004fa <printf>
  return 0;
    80003248:	4481                	li	s1,0
    8000324a:	bfad                	j	800031c4 <balloc+0x7e>

000000008000324c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000324c:	7179                	addi	sp,sp,-48
    8000324e:	f406                	sd	ra,40(sp)
    80003250:	f022                	sd	s0,32(sp)
    80003252:	ec26                	sd	s1,24(sp)
    80003254:	e84a                	sd	s2,16(sp)
    80003256:	e44e                	sd	s3,8(sp)
    80003258:	1800                	addi	s0,sp,48
    8000325a:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000325c:	47ad                	li	a5,11
    8000325e:	02b7e363          	bltu	a5,a1,80003284 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80003262:	02059793          	slli	a5,a1,0x20
    80003266:	01e7d593          	srli	a1,a5,0x1e
    8000326a:	00b509b3          	add	s3,a0,a1
    8000326e:	0509a483          	lw	s1,80(s3)
    80003272:	e0b5                	bnez	s1,800032d6 <bmap+0x8a>
      addr = balloc(ip->dev);
    80003274:	4108                	lw	a0,0(a0)
    80003276:	ed1ff0ef          	jal	80003146 <balloc>
    8000327a:	84aa                	mv	s1,a0
      if(addr == 0)
    8000327c:	cd29                	beqz	a0,800032d6 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    8000327e:	04a9a823          	sw	a0,80(s3)
    80003282:	a891                	j	800032d6 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003284:	ff45879b          	addiw	a5,a1,-12
    80003288:	873e                	mv	a4,a5
    8000328a:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    8000328c:	0ff00793          	li	a5,255
    80003290:	06e7e763          	bltu	a5,a4,800032fe <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003294:	08052483          	lw	s1,128(a0)
    80003298:	e891                	bnez	s1,800032ac <bmap+0x60>
      addr = balloc(ip->dev);
    8000329a:	4108                	lw	a0,0(a0)
    8000329c:	eabff0ef          	jal	80003146 <balloc>
    800032a0:	84aa                	mv	s1,a0
      if(addr == 0)
    800032a2:	c915                	beqz	a0,800032d6 <bmap+0x8a>
    800032a4:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800032a6:	08a92023          	sw	a0,128(s2)
    800032aa:	a011                	j	800032ae <bmap+0x62>
    800032ac:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800032ae:	85a6                	mv	a1,s1
    800032b0:	00092503          	lw	a0,0(s2)
    800032b4:	c33ff0ef          	jal	80002ee6 <bread>
    800032b8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800032ba:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800032be:	02099713          	slli	a4,s3,0x20
    800032c2:	01e75593          	srli	a1,a4,0x1e
    800032c6:	97ae                	add	a5,a5,a1
    800032c8:	89be                	mv	s3,a5
    800032ca:	4384                	lw	s1,0(a5)
    800032cc:	cc89                	beqz	s1,800032e6 <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800032ce:	8552                	mv	a0,s4
    800032d0:	d1fff0ef          	jal	80002fee <brelse>
    return addr;
    800032d4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800032d6:	8526                	mv	a0,s1
    800032d8:	70a2                	ld	ra,40(sp)
    800032da:	7402                	ld	s0,32(sp)
    800032dc:	64e2                	ld	s1,24(sp)
    800032de:	6942                	ld	s2,16(sp)
    800032e0:	69a2                	ld	s3,8(sp)
    800032e2:	6145                	addi	sp,sp,48
    800032e4:	8082                	ret
      addr = balloc(ip->dev);
    800032e6:	00092503          	lw	a0,0(s2)
    800032ea:	e5dff0ef          	jal	80003146 <balloc>
    800032ee:	84aa                	mv	s1,a0
      if(addr){
    800032f0:	dd79                	beqz	a0,800032ce <bmap+0x82>
        a[bn] = addr;
    800032f2:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800032f6:	8552                	mv	a0,s4
    800032f8:	62d000ef          	jal	80004124 <log_write>
    800032fc:	bfc9                	j	800032ce <bmap+0x82>
    800032fe:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003300:	00004517          	auipc	a0,0x4
    80003304:	10850513          	addi	a0,a0,264 # 80007408 <etext+0x408>
    80003308:	d1cfd0ef          	jal	80000824 <panic>

000000008000330c <iget>:
{
    8000330c:	7179                	addi	sp,sp,-48
    8000330e:	f406                	sd	ra,40(sp)
    80003310:	f022                	sd	s0,32(sp)
    80003312:	ec26                	sd	s1,24(sp)
    80003314:	e84a                	sd	s2,16(sp)
    80003316:	e44e                	sd	s3,8(sp)
    80003318:	e052                	sd	s4,0(sp)
    8000331a:	1800                	addi	s0,sp,48
    8000331c:	892a                	mv	s2,a0
    8000331e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003320:	0005d517          	auipc	a0,0x5d
    80003324:	59050513          	addi	a0,a0,1424 # 800608b0 <itable>
    80003328:	901fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    8000332c:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000332e:	0005d497          	auipc	s1,0x5d
    80003332:	59a48493          	addi	s1,s1,1434 # 800608c8 <itable+0x18>
    80003336:	0005f697          	auipc	a3,0x5f
    8000333a:	02268693          	addi	a3,a3,34 # 80062358 <log>
    8000333e:	a809                	j	80003350 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003340:	e781                	bnez	a5,80003348 <iget+0x3c>
    80003342:	00099363          	bnez	s3,80003348 <iget+0x3c>
      empty = ip;
    80003346:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003348:	08848493          	addi	s1,s1,136
    8000334c:	02d48563          	beq	s1,a3,80003376 <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003350:	449c                	lw	a5,8(s1)
    80003352:	fef057e3          	blez	a5,80003340 <iget+0x34>
    80003356:	4098                	lw	a4,0(s1)
    80003358:	ff2718e3          	bne	a4,s2,80003348 <iget+0x3c>
    8000335c:	40d8                	lw	a4,4(s1)
    8000335e:	ff4715e3          	bne	a4,s4,80003348 <iget+0x3c>
      ip->ref++;
    80003362:	2785                	addiw	a5,a5,1
    80003364:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003366:	0005d517          	auipc	a0,0x5d
    8000336a:	54a50513          	addi	a0,a0,1354 # 800608b0 <itable>
    8000336e:	94ffd0ef          	jal	80000cbc <release>
      return ip;
    80003372:	89a6                	mv	s3,s1
    80003374:	a015                	j	80003398 <iget+0x8c>
  if(empty == 0)
    80003376:	02098a63          	beqz	s3,800033aa <iget+0x9e>
  ip->dev = dev;
    8000337a:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000337e:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003382:	4785                	li	a5,1
    80003384:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003388:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    8000338c:	0005d517          	auipc	a0,0x5d
    80003390:	52450513          	addi	a0,a0,1316 # 800608b0 <itable>
    80003394:	929fd0ef          	jal	80000cbc <release>
}
    80003398:	854e                	mv	a0,s3
    8000339a:	70a2                	ld	ra,40(sp)
    8000339c:	7402                	ld	s0,32(sp)
    8000339e:	64e2                	ld	s1,24(sp)
    800033a0:	6942                	ld	s2,16(sp)
    800033a2:	69a2                	ld	s3,8(sp)
    800033a4:	6a02                	ld	s4,0(sp)
    800033a6:	6145                	addi	sp,sp,48
    800033a8:	8082                	ret
    panic("iget: no inodes");
    800033aa:	00004517          	auipc	a0,0x4
    800033ae:	07650513          	addi	a0,a0,118 # 80007420 <etext+0x420>
    800033b2:	c72fd0ef          	jal	80000824 <panic>

00000000800033b6 <iinit>:
{
    800033b6:	7179                	addi	sp,sp,-48
    800033b8:	f406                	sd	ra,40(sp)
    800033ba:	f022                	sd	s0,32(sp)
    800033bc:	ec26                	sd	s1,24(sp)
    800033be:	e84a                	sd	s2,16(sp)
    800033c0:	e44e                	sd	s3,8(sp)
    800033c2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800033c4:	00004597          	auipc	a1,0x4
    800033c8:	06c58593          	addi	a1,a1,108 # 80007430 <etext+0x430>
    800033cc:	0005d517          	auipc	a0,0x5d
    800033d0:	4e450513          	addi	a0,a0,1252 # 800608b0 <itable>
    800033d4:	fcafd0ef          	jal	80000b9e <initlock>
  for(i = 0; i < NINODE; i++) {
    800033d8:	0005d497          	auipc	s1,0x5d
    800033dc:	50048493          	addi	s1,s1,1280 # 800608d8 <itable+0x28>
    800033e0:	0005f997          	auipc	s3,0x5f
    800033e4:	f8898993          	addi	s3,s3,-120 # 80062368 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800033e8:	00004917          	auipc	s2,0x4
    800033ec:	05090913          	addi	s2,s2,80 # 80007438 <etext+0x438>
    800033f0:	85ca                	mv	a1,s2
    800033f2:	8526                	mv	a0,s1
    800033f4:	5f5000ef          	jal	800041e8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800033f8:	08848493          	addi	s1,s1,136
    800033fc:	ff349ae3          	bne	s1,s3,800033f0 <iinit+0x3a>
}
    80003400:	70a2                	ld	ra,40(sp)
    80003402:	7402                	ld	s0,32(sp)
    80003404:	64e2                	ld	s1,24(sp)
    80003406:	6942                	ld	s2,16(sp)
    80003408:	69a2                	ld	s3,8(sp)
    8000340a:	6145                	addi	sp,sp,48
    8000340c:	8082                	ret

000000008000340e <ialloc>:
{
    8000340e:	7139                	addi	sp,sp,-64
    80003410:	fc06                	sd	ra,56(sp)
    80003412:	f822                	sd	s0,48(sp)
    80003414:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003416:	0005d717          	auipc	a4,0x5d
    8000341a:	48672703          	lw	a4,1158(a4) # 8006089c <sb+0xc>
    8000341e:	4785                	li	a5,1
    80003420:	06e7f063          	bgeu	a5,a4,80003480 <ialloc+0x72>
    80003424:	f426                	sd	s1,40(sp)
    80003426:	f04a                	sd	s2,32(sp)
    80003428:	ec4e                	sd	s3,24(sp)
    8000342a:	e852                	sd	s4,16(sp)
    8000342c:	e456                	sd	s5,8(sp)
    8000342e:	e05a                	sd	s6,0(sp)
    80003430:	8aaa                	mv	s5,a0
    80003432:	8b2e                	mv	s6,a1
    80003434:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003436:	0005da17          	auipc	s4,0x5d
    8000343a:	45aa0a13          	addi	s4,s4,1114 # 80060890 <sb>
    8000343e:	00495593          	srli	a1,s2,0x4
    80003442:	018a2783          	lw	a5,24(s4)
    80003446:	9dbd                	addw	a1,a1,a5
    80003448:	8556                	mv	a0,s5
    8000344a:	a9dff0ef          	jal	80002ee6 <bread>
    8000344e:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003450:	05850993          	addi	s3,a0,88
    80003454:	00f97793          	andi	a5,s2,15
    80003458:	079a                	slli	a5,a5,0x6
    8000345a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000345c:	00099783          	lh	a5,0(s3)
    80003460:	cb9d                	beqz	a5,80003496 <ialloc+0x88>
    brelse(bp);
    80003462:	b8dff0ef          	jal	80002fee <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003466:	0905                	addi	s2,s2,1
    80003468:	00ca2703          	lw	a4,12(s4)
    8000346c:	0009079b          	sext.w	a5,s2
    80003470:	fce7e7e3          	bltu	a5,a4,8000343e <ialloc+0x30>
    80003474:	74a2                	ld	s1,40(sp)
    80003476:	7902                	ld	s2,32(sp)
    80003478:	69e2                	ld	s3,24(sp)
    8000347a:	6a42                	ld	s4,16(sp)
    8000347c:	6aa2                	ld	s5,8(sp)
    8000347e:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003480:	00004517          	auipc	a0,0x4
    80003484:	fc050513          	addi	a0,a0,-64 # 80007440 <etext+0x440>
    80003488:	872fd0ef          	jal	800004fa <printf>
  return 0;
    8000348c:	4501                	li	a0,0
}
    8000348e:	70e2                	ld	ra,56(sp)
    80003490:	7442                	ld	s0,48(sp)
    80003492:	6121                	addi	sp,sp,64
    80003494:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003496:	04000613          	li	a2,64
    8000349a:	4581                	li	a1,0
    8000349c:	854e                	mv	a0,s3
    8000349e:	85bfd0ef          	jal	80000cf8 <memset>
      dip->type = type;
    800034a2:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800034a6:	8526                	mv	a0,s1
    800034a8:	47d000ef          	jal	80004124 <log_write>
      brelse(bp);
    800034ac:	8526                	mv	a0,s1
    800034ae:	b41ff0ef          	jal	80002fee <brelse>
      return iget(dev, inum);
    800034b2:	0009059b          	sext.w	a1,s2
    800034b6:	8556                	mv	a0,s5
    800034b8:	e55ff0ef          	jal	8000330c <iget>
    800034bc:	74a2                	ld	s1,40(sp)
    800034be:	7902                	ld	s2,32(sp)
    800034c0:	69e2                	ld	s3,24(sp)
    800034c2:	6a42                	ld	s4,16(sp)
    800034c4:	6aa2                	ld	s5,8(sp)
    800034c6:	6b02                	ld	s6,0(sp)
    800034c8:	b7d9                	j	8000348e <ialloc+0x80>

00000000800034ca <iupdate>:
{
    800034ca:	1101                	addi	sp,sp,-32
    800034cc:	ec06                	sd	ra,24(sp)
    800034ce:	e822                	sd	s0,16(sp)
    800034d0:	e426                	sd	s1,8(sp)
    800034d2:	e04a                	sd	s2,0(sp)
    800034d4:	1000                	addi	s0,sp,32
    800034d6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800034d8:	415c                	lw	a5,4(a0)
    800034da:	0047d79b          	srliw	a5,a5,0x4
    800034de:	0005d597          	auipc	a1,0x5d
    800034e2:	3ca5a583          	lw	a1,970(a1) # 800608a8 <sb+0x18>
    800034e6:	9dbd                	addw	a1,a1,a5
    800034e8:	4108                	lw	a0,0(a0)
    800034ea:	9fdff0ef          	jal	80002ee6 <bread>
    800034ee:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800034f0:	05850793          	addi	a5,a0,88
    800034f4:	40d8                	lw	a4,4(s1)
    800034f6:	8b3d                	andi	a4,a4,15
    800034f8:	071a                	slli	a4,a4,0x6
    800034fa:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800034fc:	04449703          	lh	a4,68(s1)
    80003500:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003504:	04649703          	lh	a4,70(s1)
    80003508:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000350c:	04849703          	lh	a4,72(s1)
    80003510:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003514:	04a49703          	lh	a4,74(s1)
    80003518:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000351c:	44f8                	lw	a4,76(s1)
    8000351e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003520:	03400613          	li	a2,52
    80003524:	05048593          	addi	a1,s1,80
    80003528:	00c78513          	addi	a0,a5,12
    8000352c:	82dfd0ef          	jal	80000d58 <memmove>
  log_write(bp);
    80003530:	854a                	mv	a0,s2
    80003532:	3f3000ef          	jal	80004124 <log_write>
  brelse(bp);
    80003536:	854a                	mv	a0,s2
    80003538:	ab7ff0ef          	jal	80002fee <brelse>
}
    8000353c:	60e2                	ld	ra,24(sp)
    8000353e:	6442                	ld	s0,16(sp)
    80003540:	64a2                	ld	s1,8(sp)
    80003542:	6902                	ld	s2,0(sp)
    80003544:	6105                	addi	sp,sp,32
    80003546:	8082                	ret

0000000080003548 <idup>:
{
    80003548:	1101                	addi	sp,sp,-32
    8000354a:	ec06                	sd	ra,24(sp)
    8000354c:	e822                	sd	s0,16(sp)
    8000354e:	e426                	sd	s1,8(sp)
    80003550:	1000                	addi	s0,sp,32
    80003552:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003554:	0005d517          	auipc	a0,0x5d
    80003558:	35c50513          	addi	a0,a0,860 # 800608b0 <itable>
    8000355c:	eccfd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    80003560:	449c                	lw	a5,8(s1)
    80003562:	2785                	addiw	a5,a5,1
    80003564:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003566:	0005d517          	auipc	a0,0x5d
    8000356a:	34a50513          	addi	a0,a0,842 # 800608b0 <itable>
    8000356e:	f4efd0ef          	jal	80000cbc <release>
}
    80003572:	8526                	mv	a0,s1
    80003574:	60e2                	ld	ra,24(sp)
    80003576:	6442                	ld	s0,16(sp)
    80003578:	64a2                	ld	s1,8(sp)
    8000357a:	6105                	addi	sp,sp,32
    8000357c:	8082                	ret

000000008000357e <ilock>:
{
    8000357e:	1101                	addi	sp,sp,-32
    80003580:	ec06                	sd	ra,24(sp)
    80003582:	e822                	sd	s0,16(sp)
    80003584:	e426                	sd	s1,8(sp)
    80003586:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003588:	cd19                	beqz	a0,800035a6 <ilock+0x28>
    8000358a:	84aa                	mv	s1,a0
    8000358c:	451c                	lw	a5,8(a0)
    8000358e:	00f05c63          	blez	a5,800035a6 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003592:	0541                	addi	a0,a0,16
    80003594:	48b000ef          	jal	8000421e <acquiresleep>
  if(ip->valid == 0){
    80003598:	40bc                	lw	a5,64(s1)
    8000359a:	cf89                	beqz	a5,800035b4 <ilock+0x36>
}
    8000359c:	60e2                	ld	ra,24(sp)
    8000359e:	6442                	ld	s0,16(sp)
    800035a0:	64a2                	ld	s1,8(sp)
    800035a2:	6105                	addi	sp,sp,32
    800035a4:	8082                	ret
    800035a6:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800035a8:	00004517          	auipc	a0,0x4
    800035ac:	eb050513          	addi	a0,a0,-336 # 80007458 <etext+0x458>
    800035b0:	a74fd0ef          	jal	80000824 <panic>
    800035b4:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035b6:	40dc                	lw	a5,4(s1)
    800035b8:	0047d79b          	srliw	a5,a5,0x4
    800035bc:	0005d597          	auipc	a1,0x5d
    800035c0:	2ec5a583          	lw	a1,748(a1) # 800608a8 <sb+0x18>
    800035c4:	9dbd                	addw	a1,a1,a5
    800035c6:	4088                	lw	a0,0(s1)
    800035c8:	91fff0ef          	jal	80002ee6 <bread>
    800035cc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035ce:	05850593          	addi	a1,a0,88
    800035d2:	40dc                	lw	a5,4(s1)
    800035d4:	8bbd                	andi	a5,a5,15
    800035d6:	079a                	slli	a5,a5,0x6
    800035d8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800035da:	00059783          	lh	a5,0(a1)
    800035de:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800035e2:	00259783          	lh	a5,2(a1)
    800035e6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800035ea:	00459783          	lh	a5,4(a1)
    800035ee:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800035f2:	00659783          	lh	a5,6(a1)
    800035f6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800035fa:	459c                	lw	a5,8(a1)
    800035fc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800035fe:	03400613          	li	a2,52
    80003602:	05b1                	addi	a1,a1,12
    80003604:	05048513          	addi	a0,s1,80
    80003608:	f50fd0ef          	jal	80000d58 <memmove>
    brelse(bp);
    8000360c:	854a                	mv	a0,s2
    8000360e:	9e1ff0ef          	jal	80002fee <brelse>
    ip->valid = 1;
    80003612:	4785                	li	a5,1
    80003614:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003616:	04449783          	lh	a5,68(s1)
    8000361a:	c399                	beqz	a5,80003620 <ilock+0xa2>
    8000361c:	6902                	ld	s2,0(sp)
    8000361e:	bfbd                	j	8000359c <ilock+0x1e>
      panic("ilock: no type");
    80003620:	00004517          	auipc	a0,0x4
    80003624:	e4050513          	addi	a0,a0,-448 # 80007460 <etext+0x460>
    80003628:	9fcfd0ef          	jal	80000824 <panic>

000000008000362c <iunlock>:
{
    8000362c:	1101                	addi	sp,sp,-32
    8000362e:	ec06                	sd	ra,24(sp)
    80003630:	e822                	sd	s0,16(sp)
    80003632:	e426                	sd	s1,8(sp)
    80003634:	e04a                	sd	s2,0(sp)
    80003636:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003638:	c505                	beqz	a0,80003660 <iunlock+0x34>
    8000363a:	84aa                	mv	s1,a0
    8000363c:	01050913          	addi	s2,a0,16
    80003640:	854a                	mv	a0,s2
    80003642:	45b000ef          	jal	8000429c <holdingsleep>
    80003646:	cd09                	beqz	a0,80003660 <iunlock+0x34>
    80003648:	449c                	lw	a5,8(s1)
    8000364a:	00f05b63          	blez	a5,80003660 <iunlock+0x34>
  releasesleep(&ip->lock);
    8000364e:	854a                	mv	a0,s2
    80003650:	415000ef          	jal	80004264 <releasesleep>
}
    80003654:	60e2                	ld	ra,24(sp)
    80003656:	6442                	ld	s0,16(sp)
    80003658:	64a2                	ld	s1,8(sp)
    8000365a:	6902                	ld	s2,0(sp)
    8000365c:	6105                	addi	sp,sp,32
    8000365e:	8082                	ret
    panic("iunlock");
    80003660:	00004517          	auipc	a0,0x4
    80003664:	e1050513          	addi	a0,a0,-496 # 80007470 <etext+0x470>
    80003668:	9bcfd0ef          	jal	80000824 <panic>

000000008000366c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000366c:	7179                	addi	sp,sp,-48
    8000366e:	f406                	sd	ra,40(sp)
    80003670:	f022                	sd	s0,32(sp)
    80003672:	ec26                	sd	s1,24(sp)
    80003674:	e84a                	sd	s2,16(sp)
    80003676:	e44e                	sd	s3,8(sp)
    80003678:	1800                	addi	s0,sp,48
    8000367a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000367c:	05050493          	addi	s1,a0,80
    80003680:	08050913          	addi	s2,a0,128
    80003684:	a021                	j	8000368c <itrunc+0x20>
    80003686:	0491                	addi	s1,s1,4
    80003688:	01248b63          	beq	s1,s2,8000369e <itrunc+0x32>
    if(ip->addrs[i]){
    8000368c:	408c                	lw	a1,0(s1)
    8000368e:	dde5                	beqz	a1,80003686 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003690:	0009a503          	lw	a0,0(s3)
    80003694:	a47ff0ef          	jal	800030da <bfree>
      ip->addrs[i] = 0;
    80003698:	0004a023          	sw	zero,0(s1)
    8000369c:	b7ed                	j	80003686 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000369e:	0809a583          	lw	a1,128(s3)
    800036a2:	ed89                	bnez	a1,800036bc <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800036a4:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800036a8:	854e                	mv	a0,s3
    800036aa:	e21ff0ef          	jal	800034ca <iupdate>
}
    800036ae:	70a2                	ld	ra,40(sp)
    800036b0:	7402                	ld	s0,32(sp)
    800036b2:	64e2                	ld	s1,24(sp)
    800036b4:	6942                	ld	s2,16(sp)
    800036b6:	69a2                	ld	s3,8(sp)
    800036b8:	6145                	addi	sp,sp,48
    800036ba:	8082                	ret
    800036bc:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800036be:	0009a503          	lw	a0,0(s3)
    800036c2:	825ff0ef          	jal	80002ee6 <bread>
    800036c6:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800036c8:	05850493          	addi	s1,a0,88
    800036cc:	45850913          	addi	s2,a0,1112
    800036d0:	a021                	j	800036d8 <itrunc+0x6c>
    800036d2:	0491                	addi	s1,s1,4
    800036d4:	01248963          	beq	s1,s2,800036e6 <itrunc+0x7a>
      if(a[j])
    800036d8:	408c                	lw	a1,0(s1)
    800036da:	dde5                	beqz	a1,800036d2 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800036dc:	0009a503          	lw	a0,0(s3)
    800036e0:	9fbff0ef          	jal	800030da <bfree>
    800036e4:	b7fd                	j	800036d2 <itrunc+0x66>
    brelse(bp);
    800036e6:	8552                	mv	a0,s4
    800036e8:	907ff0ef          	jal	80002fee <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800036ec:	0809a583          	lw	a1,128(s3)
    800036f0:	0009a503          	lw	a0,0(s3)
    800036f4:	9e7ff0ef          	jal	800030da <bfree>
    ip->addrs[NDIRECT] = 0;
    800036f8:	0809a023          	sw	zero,128(s3)
    800036fc:	6a02                	ld	s4,0(sp)
    800036fe:	b75d                	j	800036a4 <itrunc+0x38>

0000000080003700 <iput>:
{
    80003700:	1101                	addi	sp,sp,-32
    80003702:	ec06                	sd	ra,24(sp)
    80003704:	e822                	sd	s0,16(sp)
    80003706:	e426                	sd	s1,8(sp)
    80003708:	1000                	addi	s0,sp,32
    8000370a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000370c:	0005d517          	auipc	a0,0x5d
    80003710:	1a450513          	addi	a0,a0,420 # 800608b0 <itable>
    80003714:	d14fd0ef          	jal	80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003718:	4498                	lw	a4,8(s1)
    8000371a:	4785                	li	a5,1
    8000371c:	02f70063          	beq	a4,a5,8000373c <iput+0x3c>
  ip->ref--;
    80003720:	449c                	lw	a5,8(s1)
    80003722:	37fd                	addiw	a5,a5,-1
    80003724:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003726:	0005d517          	auipc	a0,0x5d
    8000372a:	18a50513          	addi	a0,a0,394 # 800608b0 <itable>
    8000372e:	d8efd0ef          	jal	80000cbc <release>
}
    80003732:	60e2                	ld	ra,24(sp)
    80003734:	6442                	ld	s0,16(sp)
    80003736:	64a2                	ld	s1,8(sp)
    80003738:	6105                	addi	sp,sp,32
    8000373a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000373c:	40bc                	lw	a5,64(s1)
    8000373e:	d3ed                	beqz	a5,80003720 <iput+0x20>
    80003740:	04a49783          	lh	a5,74(s1)
    80003744:	fff1                	bnez	a5,80003720 <iput+0x20>
    80003746:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003748:	01048793          	addi	a5,s1,16
    8000374c:	893e                	mv	s2,a5
    8000374e:	853e                	mv	a0,a5
    80003750:	2cf000ef          	jal	8000421e <acquiresleep>
    release(&itable.lock);
    80003754:	0005d517          	auipc	a0,0x5d
    80003758:	15c50513          	addi	a0,a0,348 # 800608b0 <itable>
    8000375c:	d60fd0ef          	jal	80000cbc <release>
    itrunc(ip);
    80003760:	8526                	mv	a0,s1
    80003762:	f0bff0ef          	jal	8000366c <itrunc>
    ip->type = 0;
    80003766:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000376a:	8526                	mv	a0,s1
    8000376c:	d5fff0ef          	jal	800034ca <iupdate>
    ip->valid = 0;
    80003770:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003774:	854a                	mv	a0,s2
    80003776:	2ef000ef          	jal	80004264 <releasesleep>
    acquire(&itable.lock);
    8000377a:	0005d517          	auipc	a0,0x5d
    8000377e:	13650513          	addi	a0,a0,310 # 800608b0 <itable>
    80003782:	ca6fd0ef          	jal	80000c28 <acquire>
    80003786:	6902                	ld	s2,0(sp)
    80003788:	bf61                	j	80003720 <iput+0x20>

000000008000378a <iunlockput>:
{
    8000378a:	1101                	addi	sp,sp,-32
    8000378c:	ec06                	sd	ra,24(sp)
    8000378e:	e822                	sd	s0,16(sp)
    80003790:	e426                	sd	s1,8(sp)
    80003792:	1000                	addi	s0,sp,32
    80003794:	84aa                	mv	s1,a0
  iunlock(ip);
    80003796:	e97ff0ef          	jal	8000362c <iunlock>
  iput(ip);
    8000379a:	8526                	mv	a0,s1
    8000379c:	f65ff0ef          	jal	80003700 <iput>
}
    800037a0:	60e2                	ld	ra,24(sp)
    800037a2:	6442                	ld	s0,16(sp)
    800037a4:	64a2                	ld	s1,8(sp)
    800037a6:	6105                	addi	sp,sp,32
    800037a8:	8082                	ret

00000000800037aa <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800037aa:	0005d717          	auipc	a4,0x5d
    800037ae:	0f272703          	lw	a4,242(a4) # 8006089c <sb+0xc>
    800037b2:	4785                	li	a5,1
    800037b4:	0ae7fe63          	bgeu	a5,a4,80003870 <ireclaim+0xc6>
{
    800037b8:	7139                	addi	sp,sp,-64
    800037ba:	fc06                	sd	ra,56(sp)
    800037bc:	f822                	sd	s0,48(sp)
    800037be:	f426                	sd	s1,40(sp)
    800037c0:	f04a                	sd	s2,32(sp)
    800037c2:	ec4e                	sd	s3,24(sp)
    800037c4:	e852                	sd	s4,16(sp)
    800037c6:	e456                	sd	s5,8(sp)
    800037c8:	e05a                	sd	s6,0(sp)
    800037ca:	0080                	addi	s0,sp,64
    800037cc:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800037ce:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800037d0:	0005da17          	auipc	s4,0x5d
    800037d4:	0c0a0a13          	addi	s4,s4,192 # 80060890 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800037d8:	00004b17          	auipc	s6,0x4
    800037dc:	ca0b0b13          	addi	s6,s6,-864 # 80007478 <etext+0x478>
    800037e0:	a099                	j	80003826 <ireclaim+0x7c>
    800037e2:	85ce                	mv	a1,s3
    800037e4:	855a                	mv	a0,s6
    800037e6:	d15fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    800037ea:	85ce                	mv	a1,s3
    800037ec:	8556                	mv	a0,s5
    800037ee:	b1fff0ef          	jal	8000330c <iget>
    800037f2:	89aa                	mv	s3,a0
    brelse(bp);
    800037f4:	854a                	mv	a0,s2
    800037f6:	ff8ff0ef          	jal	80002fee <brelse>
    if (ip) {
    800037fa:	00098f63          	beqz	s3,80003818 <ireclaim+0x6e>
      begin_op();
    800037fe:	78c000ef          	jal	80003f8a <begin_op>
      ilock(ip);
    80003802:	854e                	mv	a0,s3
    80003804:	d7bff0ef          	jal	8000357e <ilock>
      iunlock(ip);
    80003808:	854e                	mv	a0,s3
    8000380a:	e23ff0ef          	jal	8000362c <iunlock>
      iput(ip);
    8000380e:	854e                	mv	a0,s3
    80003810:	ef1ff0ef          	jal	80003700 <iput>
      end_op();
    80003814:	7e6000ef          	jal	80003ffa <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003818:	0485                	addi	s1,s1,1
    8000381a:	00ca2703          	lw	a4,12(s4)
    8000381e:	0004879b          	sext.w	a5,s1
    80003822:	02e7fd63          	bgeu	a5,a4,8000385c <ireclaim+0xb2>
    80003826:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000382a:	0044d593          	srli	a1,s1,0x4
    8000382e:	018a2783          	lw	a5,24(s4)
    80003832:	9dbd                	addw	a1,a1,a5
    80003834:	8556                	mv	a0,s5
    80003836:	eb0ff0ef          	jal	80002ee6 <bread>
    8000383a:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000383c:	05850793          	addi	a5,a0,88
    80003840:	00f9f713          	andi	a4,s3,15
    80003844:	071a                	slli	a4,a4,0x6
    80003846:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003848:	00079703          	lh	a4,0(a5)
    8000384c:	c701                	beqz	a4,80003854 <ireclaim+0xaa>
    8000384e:	00679783          	lh	a5,6(a5)
    80003852:	dbc1                	beqz	a5,800037e2 <ireclaim+0x38>
    brelse(bp);
    80003854:	854a                	mv	a0,s2
    80003856:	f98ff0ef          	jal	80002fee <brelse>
    if (ip) {
    8000385a:	bf7d                	j	80003818 <ireclaim+0x6e>
}
    8000385c:	70e2                	ld	ra,56(sp)
    8000385e:	7442                	ld	s0,48(sp)
    80003860:	74a2                	ld	s1,40(sp)
    80003862:	7902                	ld	s2,32(sp)
    80003864:	69e2                	ld	s3,24(sp)
    80003866:	6a42                	ld	s4,16(sp)
    80003868:	6aa2                	ld	s5,8(sp)
    8000386a:	6b02                	ld	s6,0(sp)
    8000386c:	6121                	addi	sp,sp,64
    8000386e:	8082                	ret
    80003870:	8082                	ret

0000000080003872 <fsinit>:
fsinit(int dev) {
    80003872:	1101                	addi	sp,sp,-32
    80003874:	ec06                	sd	ra,24(sp)
    80003876:	e822                	sd	s0,16(sp)
    80003878:	e426                	sd	s1,8(sp)
    8000387a:	e04a                	sd	s2,0(sp)
    8000387c:	1000                	addi	s0,sp,32
    8000387e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003880:	4585                	li	a1,1
    80003882:	e64ff0ef          	jal	80002ee6 <bread>
    80003886:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003888:	02000613          	li	a2,32
    8000388c:	05850593          	addi	a1,a0,88
    80003890:	0005d517          	auipc	a0,0x5d
    80003894:	00050513          	mv	a0,a0
    80003898:	cc0fd0ef          	jal	80000d58 <memmove>
  brelse(bp);
    8000389c:	8526                	mv	a0,s1
    8000389e:	f50ff0ef          	jal	80002fee <brelse>
  if(sb.magic != FSMAGIC)
    800038a2:	0005d717          	auipc	a4,0x5d
    800038a6:	fee72703          	lw	a4,-18(a4) # 80060890 <sb>
    800038aa:	102037b7          	lui	a5,0x10203
    800038ae:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800038b2:	02f71263          	bne	a4,a5,800038d6 <fsinit+0x64>
  initlog(dev, &sb);
    800038b6:	0005d597          	auipc	a1,0x5d
    800038ba:	fda58593          	addi	a1,a1,-38 # 80060890 <sb>
    800038be:	854a                	mv	a0,s2
    800038c0:	648000ef          	jal	80003f08 <initlog>
  ireclaim(dev);
    800038c4:	854a                	mv	a0,s2
    800038c6:	ee5ff0ef          	jal	800037aa <ireclaim>
}
    800038ca:	60e2                	ld	ra,24(sp)
    800038cc:	6442                	ld	s0,16(sp)
    800038ce:	64a2                	ld	s1,8(sp)
    800038d0:	6902                	ld	s2,0(sp)
    800038d2:	6105                	addi	sp,sp,32
    800038d4:	8082                	ret
    panic("invalid file system");
    800038d6:	00004517          	auipc	a0,0x4
    800038da:	bc250513          	addi	a0,a0,-1086 # 80007498 <etext+0x498>
    800038de:	f47fc0ef          	jal	80000824 <panic>

00000000800038e2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800038e2:	1141                	addi	sp,sp,-16
    800038e4:	e406                	sd	ra,8(sp)
    800038e6:	e022                	sd	s0,0(sp)
    800038e8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800038ea:	411c                	lw	a5,0(a0)
    800038ec:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800038ee:	415c                	lw	a5,4(a0)
    800038f0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800038f2:	04451783          	lh	a5,68(a0)
    800038f6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800038fa:	04a51783          	lh	a5,74(a0)
    800038fe:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003902:	04c56783          	lwu	a5,76(a0)
    80003906:	e99c                	sd	a5,16(a1)
}
    80003908:	60a2                	ld	ra,8(sp)
    8000390a:	6402                	ld	s0,0(sp)
    8000390c:	0141                	addi	sp,sp,16
    8000390e:	8082                	ret

0000000080003910 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003910:	457c                	lw	a5,76(a0)
    80003912:	0ed7e663          	bltu	a5,a3,800039fe <readi+0xee>
{
    80003916:	7159                	addi	sp,sp,-112
    80003918:	f486                	sd	ra,104(sp)
    8000391a:	f0a2                	sd	s0,96(sp)
    8000391c:	eca6                	sd	s1,88(sp)
    8000391e:	e0d2                	sd	s4,64(sp)
    80003920:	fc56                	sd	s5,56(sp)
    80003922:	f85a                	sd	s6,48(sp)
    80003924:	f45e                	sd	s7,40(sp)
    80003926:	1880                	addi	s0,sp,112
    80003928:	8b2a                	mv	s6,a0
    8000392a:	8bae                	mv	s7,a1
    8000392c:	8a32                	mv	s4,a2
    8000392e:	84b6                	mv	s1,a3
    80003930:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003932:	9f35                	addw	a4,a4,a3
    return 0;
    80003934:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003936:	0ad76b63          	bltu	a4,a3,800039ec <readi+0xdc>
    8000393a:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    8000393c:	00e7f463          	bgeu	a5,a4,80003944 <readi+0x34>
    n = ip->size - off;
    80003940:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003944:	080a8b63          	beqz	s5,800039da <readi+0xca>
    80003948:	e8ca                	sd	s2,80(sp)
    8000394a:	f062                	sd	s8,32(sp)
    8000394c:	ec66                	sd	s9,24(sp)
    8000394e:	e86a                	sd	s10,16(sp)
    80003950:	e46e                	sd	s11,8(sp)
    80003952:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003954:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003958:	5c7d                	li	s8,-1
    8000395a:	a80d                	j	8000398c <readi+0x7c>
    8000395c:	020d1d93          	slli	s11,s10,0x20
    80003960:	020ddd93          	srli	s11,s11,0x20
    80003964:	05890613          	addi	a2,s2,88
    80003968:	86ee                	mv	a3,s11
    8000396a:	963e                	add	a2,a2,a5
    8000396c:	85d2                	mv	a1,s4
    8000396e:	855e                	mv	a0,s7
    80003970:	979fe0ef          	jal	800022e8 <either_copyout>
    80003974:	05850363          	beq	a0,s8,800039ba <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003978:	854a                	mv	a0,s2
    8000397a:	e74ff0ef          	jal	80002fee <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000397e:	013d09bb          	addw	s3,s10,s3
    80003982:	009d04bb          	addw	s1,s10,s1
    80003986:	9a6e                	add	s4,s4,s11
    80003988:	0559f363          	bgeu	s3,s5,800039ce <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    8000398c:	00a4d59b          	srliw	a1,s1,0xa
    80003990:	855a                	mv	a0,s6
    80003992:	8bbff0ef          	jal	8000324c <bmap>
    80003996:	85aa                	mv	a1,a0
    if(addr == 0)
    80003998:	c139                	beqz	a0,800039de <readi+0xce>
    bp = bread(ip->dev, addr);
    8000399a:	000b2503          	lw	a0,0(s6)
    8000399e:	d48ff0ef          	jal	80002ee6 <bread>
    800039a2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039a4:	3ff4f793          	andi	a5,s1,1023
    800039a8:	40fc873b          	subw	a4,s9,a5
    800039ac:	413a86bb          	subw	a3,s5,s3
    800039b0:	8d3a                	mv	s10,a4
    800039b2:	fae6f5e3          	bgeu	a3,a4,8000395c <readi+0x4c>
    800039b6:	8d36                	mv	s10,a3
    800039b8:	b755                	j	8000395c <readi+0x4c>
      brelse(bp);
    800039ba:	854a                	mv	a0,s2
    800039bc:	e32ff0ef          	jal	80002fee <brelse>
      tot = -1;
    800039c0:	59fd                	li	s3,-1
      break;
    800039c2:	6946                	ld	s2,80(sp)
    800039c4:	7c02                	ld	s8,32(sp)
    800039c6:	6ce2                	ld	s9,24(sp)
    800039c8:	6d42                	ld	s10,16(sp)
    800039ca:	6da2                	ld	s11,8(sp)
    800039cc:	a831                	j	800039e8 <readi+0xd8>
    800039ce:	6946                	ld	s2,80(sp)
    800039d0:	7c02                	ld	s8,32(sp)
    800039d2:	6ce2                	ld	s9,24(sp)
    800039d4:	6d42                	ld	s10,16(sp)
    800039d6:	6da2                	ld	s11,8(sp)
    800039d8:	a801                	j	800039e8 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039da:	89d6                	mv	s3,s5
    800039dc:	a031                	j	800039e8 <readi+0xd8>
    800039de:	6946                	ld	s2,80(sp)
    800039e0:	7c02                	ld	s8,32(sp)
    800039e2:	6ce2                	ld	s9,24(sp)
    800039e4:	6d42                	ld	s10,16(sp)
    800039e6:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800039e8:	854e                	mv	a0,s3
    800039ea:	69a6                	ld	s3,72(sp)
}
    800039ec:	70a6                	ld	ra,104(sp)
    800039ee:	7406                	ld	s0,96(sp)
    800039f0:	64e6                	ld	s1,88(sp)
    800039f2:	6a06                	ld	s4,64(sp)
    800039f4:	7ae2                	ld	s5,56(sp)
    800039f6:	7b42                	ld	s6,48(sp)
    800039f8:	7ba2                	ld	s7,40(sp)
    800039fa:	6165                	addi	sp,sp,112
    800039fc:	8082                	ret
    return 0;
    800039fe:	4501                	li	a0,0
}
    80003a00:	8082                	ret

0000000080003a02 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a02:	457c                	lw	a5,76(a0)
    80003a04:	0ed7eb63          	bltu	a5,a3,80003afa <writei+0xf8>
{
    80003a08:	7159                	addi	sp,sp,-112
    80003a0a:	f486                	sd	ra,104(sp)
    80003a0c:	f0a2                	sd	s0,96(sp)
    80003a0e:	e8ca                	sd	s2,80(sp)
    80003a10:	e0d2                	sd	s4,64(sp)
    80003a12:	fc56                	sd	s5,56(sp)
    80003a14:	f85a                	sd	s6,48(sp)
    80003a16:	f45e                	sd	s7,40(sp)
    80003a18:	1880                	addi	s0,sp,112
    80003a1a:	8aaa                	mv	s5,a0
    80003a1c:	8bae                	mv	s7,a1
    80003a1e:	8a32                	mv	s4,a2
    80003a20:	8936                	mv	s2,a3
    80003a22:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a24:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a28:	00043737          	lui	a4,0x43
    80003a2c:	0cf76963          	bltu	a4,a5,80003afe <writei+0xfc>
    80003a30:	0cd7e763          	bltu	a5,a3,80003afe <writei+0xfc>
    80003a34:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a36:	0a0b0a63          	beqz	s6,80003aea <writei+0xe8>
    80003a3a:	eca6                	sd	s1,88(sp)
    80003a3c:	f062                	sd	s8,32(sp)
    80003a3e:	ec66                	sd	s9,24(sp)
    80003a40:	e86a                	sd	s10,16(sp)
    80003a42:	e46e                	sd	s11,8(sp)
    80003a44:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a46:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a4a:	5c7d                	li	s8,-1
    80003a4c:	a825                	j	80003a84 <writei+0x82>
    80003a4e:	020d1d93          	slli	s11,s10,0x20
    80003a52:	020ddd93          	srli	s11,s11,0x20
    80003a56:	05848513          	addi	a0,s1,88
    80003a5a:	86ee                	mv	a3,s11
    80003a5c:	8652                	mv	a2,s4
    80003a5e:	85de                	mv	a1,s7
    80003a60:	953e                	add	a0,a0,a5
    80003a62:	8d1fe0ef          	jal	80002332 <either_copyin>
    80003a66:	05850663          	beq	a0,s8,80003ab2 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a6a:	8526                	mv	a0,s1
    80003a6c:	6b8000ef          	jal	80004124 <log_write>
    brelse(bp);
    80003a70:	8526                	mv	a0,s1
    80003a72:	d7cff0ef          	jal	80002fee <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a76:	013d09bb          	addw	s3,s10,s3
    80003a7a:	012d093b          	addw	s2,s10,s2
    80003a7e:	9a6e                	add	s4,s4,s11
    80003a80:	0369fc63          	bgeu	s3,s6,80003ab8 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003a84:	00a9559b          	srliw	a1,s2,0xa
    80003a88:	8556                	mv	a0,s5
    80003a8a:	fc2ff0ef          	jal	8000324c <bmap>
    80003a8e:	85aa                	mv	a1,a0
    if(addr == 0)
    80003a90:	c505                	beqz	a0,80003ab8 <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003a92:	000aa503          	lw	a0,0(s5)
    80003a96:	c50ff0ef          	jal	80002ee6 <bread>
    80003a9a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a9c:	3ff97793          	andi	a5,s2,1023
    80003aa0:	40fc873b          	subw	a4,s9,a5
    80003aa4:	413b06bb          	subw	a3,s6,s3
    80003aa8:	8d3a                	mv	s10,a4
    80003aaa:	fae6f2e3          	bgeu	a3,a4,80003a4e <writei+0x4c>
    80003aae:	8d36                	mv	s10,a3
    80003ab0:	bf79                	j	80003a4e <writei+0x4c>
      brelse(bp);
    80003ab2:	8526                	mv	a0,s1
    80003ab4:	d3aff0ef          	jal	80002fee <brelse>
  }

  if(off > ip->size)
    80003ab8:	04caa783          	lw	a5,76(s5)
    80003abc:	0327f963          	bgeu	a5,s2,80003aee <writei+0xec>
    ip->size = off;
    80003ac0:	052aa623          	sw	s2,76(s5)
    80003ac4:	64e6                	ld	s1,88(sp)
    80003ac6:	7c02                	ld	s8,32(sp)
    80003ac8:	6ce2                	ld	s9,24(sp)
    80003aca:	6d42                	ld	s10,16(sp)
    80003acc:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003ace:	8556                	mv	a0,s5
    80003ad0:	9fbff0ef          	jal	800034ca <iupdate>

  return tot;
    80003ad4:	854e                	mv	a0,s3
    80003ad6:	69a6                	ld	s3,72(sp)
}
    80003ad8:	70a6                	ld	ra,104(sp)
    80003ada:	7406                	ld	s0,96(sp)
    80003adc:	6946                	ld	s2,80(sp)
    80003ade:	6a06                	ld	s4,64(sp)
    80003ae0:	7ae2                	ld	s5,56(sp)
    80003ae2:	7b42                	ld	s6,48(sp)
    80003ae4:	7ba2                	ld	s7,40(sp)
    80003ae6:	6165                	addi	sp,sp,112
    80003ae8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003aea:	89da                	mv	s3,s6
    80003aec:	b7cd                	j	80003ace <writei+0xcc>
    80003aee:	64e6                	ld	s1,88(sp)
    80003af0:	7c02                	ld	s8,32(sp)
    80003af2:	6ce2                	ld	s9,24(sp)
    80003af4:	6d42                	ld	s10,16(sp)
    80003af6:	6da2                	ld	s11,8(sp)
    80003af8:	bfd9                	j	80003ace <writei+0xcc>
    return -1;
    80003afa:	557d                	li	a0,-1
}
    80003afc:	8082                	ret
    return -1;
    80003afe:	557d                	li	a0,-1
    80003b00:	bfe1                	j	80003ad8 <writei+0xd6>

0000000080003b02 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b02:	1141                	addi	sp,sp,-16
    80003b04:	e406                	sd	ra,8(sp)
    80003b06:	e022                	sd	s0,0(sp)
    80003b08:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b0a:	4639                	li	a2,14
    80003b0c:	ac0fd0ef          	jal	80000dcc <strncmp>
}
    80003b10:	60a2                	ld	ra,8(sp)
    80003b12:	6402                	ld	s0,0(sp)
    80003b14:	0141                	addi	sp,sp,16
    80003b16:	8082                	ret

0000000080003b18 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b18:	711d                	addi	sp,sp,-96
    80003b1a:	ec86                	sd	ra,88(sp)
    80003b1c:	e8a2                	sd	s0,80(sp)
    80003b1e:	e4a6                	sd	s1,72(sp)
    80003b20:	e0ca                	sd	s2,64(sp)
    80003b22:	fc4e                	sd	s3,56(sp)
    80003b24:	f852                	sd	s4,48(sp)
    80003b26:	f456                	sd	s5,40(sp)
    80003b28:	f05a                	sd	s6,32(sp)
    80003b2a:	ec5e                	sd	s7,24(sp)
    80003b2c:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b2e:	04451703          	lh	a4,68(a0)
    80003b32:	4785                	li	a5,1
    80003b34:	00f71f63          	bne	a4,a5,80003b52 <dirlookup+0x3a>
    80003b38:	892a                	mv	s2,a0
    80003b3a:	8aae                	mv	s5,a1
    80003b3c:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b3e:	457c                	lw	a5,76(a0)
    80003b40:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b42:	fa040a13          	addi	s4,s0,-96
    80003b46:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003b48:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b4c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b4e:	e39d                	bnez	a5,80003b74 <dirlookup+0x5c>
    80003b50:	a8b9                	j	80003bae <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003b52:	00004517          	auipc	a0,0x4
    80003b56:	95e50513          	addi	a0,a0,-1698 # 800074b0 <etext+0x4b0>
    80003b5a:	ccbfc0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    80003b5e:	00004517          	auipc	a0,0x4
    80003b62:	96a50513          	addi	a0,a0,-1686 # 800074c8 <etext+0x4c8>
    80003b66:	cbffc0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b6a:	24c1                	addiw	s1,s1,16
    80003b6c:	04c92783          	lw	a5,76(s2)
    80003b70:	02f4fe63          	bgeu	s1,a5,80003bac <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b74:	874e                	mv	a4,s3
    80003b76:	86a6                	mv	a3,s1
    80003b78:	8652                	mv	a2,s4
    80003b7a:	4581                	li	a1,0
    80003b7c:	854a                	mv	a0,s2
    80003b7e:	d93ff0ef          	jal	80003910 <readi>
    80003b82:	fd351ee3          	bne	a0,s3,80003b5e <dirlookup+0x46>
    if(de.inum == 0)
    80003b86:	fa045783          	lhu	a5,-96(s0)
    80003b8a:	d3e5                	beqz	a5,80003b6a <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003b8c:	85da                	mv	a1,s6
    80003b8e:	8556                	mv	a0,s5
    80003b90:	f73ff0ef          	jal	80003b02 <namecmp>
    80003b94:	f979                	bnez	a0,80003b6a <dirlookup+0x52>
      if(poff)
    80003b96:	000b8463          	beqz	s7,80003b9e <dirlookup+0x86>
        *poff = off;
    80003b9a:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003b9e:	fa045583          	lhu	a1,-96(s0)
    80003ba2:	00092503          	lw	a0,0(s2)
    80003ba6:	f66ff0ef          	jal	8000330c <iget>
    80003baa:	a011                	j	80003bae <dirlookup+0x96>
  return 0;
    80003bac:	4501                	li	a0,0
}
    80003bae:	60e6                	ld	ra,88(sp)
    80003bb0:	6446                	ld	s0,80(sp)
    80003bb2:	64a6                	ld	s1,72(sp)
    80003bb4:	6906                	ld	s2,64(sp)
    80003bb6:	79e2                	ld	s3,56(sp)
    80003bb8:	7a42                	ld	s4,48(sp)
    80003bba:	7aa2                	ld	s5,40(sp)
    80003bbc:	7b02                	ld	s6,32(sp)
    80003bbe:	6be2                	ld	s7,24(sp)
    80003bc0:	6125                	addi	sp,sp,96
    80003bc2:	8082                	ret

0000000080003bc4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003bc4:	711d                	addi	sp,sp,-96
    80003bc6:	ec86                	sd	ra,88(sp)
    80003bc8:	e8a2                	sd	s0,80(sp)
    80003bca:	e4a6                	sd	s1,72(sp)
    80003bcc:	e0ca                	sd	s2,64(sp)
    80003bce:	fc4e                	sd	s3,56(sp)
    80003bd0:	f852                	sd	s4,48(sp)
    80003bd2:	f456                	sd	s5,40(sp)
    80003bd4:	f05a                	sd	s6,32(sp)
    80003bd6:	ec5e                	sd	s7,24(sp)
    80003bd8:	e862                	sd	s8,16(sp)
    80003bda:	e466                	sd	s9,8(sp)
    80003bdc:	e06a                	sd	s10,0(sp)
    80003bde:	1080                	addi	s0,sp,96
    80003be0:	84aa                	mv	s1,a0
    80003be2:	8b2e                	mv	s6,a1
    80003be4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003be6:	00054703          	lbu	a4,0(a0)
    80003bea:	02f00793          	li	a5,47
    80003bee:	00f70f63          	beq	a4,a5,80003c0c <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003bf2:	d43fd0ef          	jal	80001934 <myproc>
    80003bf6:	15053503          	ld	a0,336(a0)
    80003bfa:	94fff0ef          	jal	80003548 <idup>
    80003bfe:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003c00:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003c04:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003c06:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c08:	4b85                	li	s7,1
    80003c0a:	a879                	j	80003ca8 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003c0c:	4585                	li	a1,1
    80003c0e:	852e                	mv	a0,a1
    80003c10:	efcff0ef          	jal	8000330c <iget>
    80003c14:	8a2a                	mv	s4,a0
    80003c16:	b7ed                	j	80003c00 <namex+0x3c>
      iunlockput(ip);
    80003c18:	8552                	mv	a0,s4
    80003c1a:	b71ff0ef          	jal	8000378a <iunlockput>
      return 0;
    80003c1e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c20:	8552                	mv	a0,s4
    80003c22:	60e6                	ld	ra,88(sp)
    80003c24:	6446                	ld	s0,80(sp)
    80003c26:	64a6                	ld	s1,72(sp)
    80003c28:	6906                	ld	s2,64(sp)
    80003c2a:	79e2                	ld	s3,56(sp)
    80003c2c:	7a42                	ld	s4,48(sp)
    80003c2e:	7aa2                	ld	s5,40(sp)
    80003c30:	7b02                	ld	s6,32(sp)
    80003c32:	6be2                	ld	s7,24(sp)
    80003c34:	6c42                	ld	s8,16(sp)
    80003c36:	6ca2                	ld	s9,8(sp)
    80003c38:	6d02                	ld	s10,0(sp)
    80003c3a:	6125                	addi	sp,sp,96
    80003c3c:	8082                	ret
      iunlock(ip);
    80003c3e:	8552                	mv	a0,s4
    80003c40:	9edff0ef          	jal	8000362c <iunlock>
      return ip;
    80003c44:	bff1                	j	80003c20 <namex+0x5c>
      iunlockput(ip);
    80003c46:	8552                	mv	a0,s4
    80003c48:	b43ff0ef          	jal	8000378a <iunlockput>
      return 0;
    80003c4c:	8a4a                	mv	s4,s2
    80003c4e:	bfc9                	j	80003c20 <namex+0x5c>
  len = path - s;
    80003c50:	40990633          	sub	a2,s2,s1
    80003c54:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003c58:	09ac5463          	bge	s8,s10,80003ce0 <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80003c5c:	8666                	mv	a2,s9
    80003c5e:	85a6                	mv	a1,s1
    80003c60:	8556                	mv	a0,s5
    80003c62:	8f6fd0ef          	jal	80000d58 <memmove>
    80003c66:	84ca                	mv	s1,s2
  while(*path == '/')
    80003c68:	0004c783          	lbu	a5,0(s1)
    80003c6c:	01379763          	bne	a5,s3,80003c7a <namex+0xb6>
    path++;
    80003c70:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c72:	0004c783          	lbu	a5,0(s1)
    80003c76:	ff378de3          	beq	a5,s3,80003c70 <namex+0xac>
    ilock(ip);
    80003c7a:	8552                	mv	a0,s4
    80003c7c:	903ff0ef          	jal	8000357e <ilock>
    if(ip->type != T_DIR){
    80003c80:	044a1783          	lh	a5,68(s4)
    80003c84:	f9779ae3          	bne	a5,s7,80003c18 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003c88:	000b0563          	beqz	s6,80003c92 <namex+0xce>
    80003c8c:	0004c783          	lbu	a5,0(s1)
    80003c90:	d7dd                	beqz	a5,80003c3e <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003c92:	4601                	li	a2,0
    80003c94:	85d6                	mv	a1,s5
    80003c96:	8552                	mv	a0,s4
    80003c98:	e81ff0ef          	jal	80003b18 <dirlookup>
    80003c9c:	892a                	mv	s2,a0
    80003c9e:	d545                	beqz	a0,80003c46 <namex+0x82>
    iunlockput(ip);
    80003ca0:	8552                	mv	a0,s4
    80003ca2:	ae9ff0ef          	jal	8000378a <iunlockput>
    ip = next;
    80003ca6:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003ca8:	0004c783          	lbu	a5,0(s1)
    80003cac:	01379763          	bne	a5,s3,80003cba <namex+0xf6>
    path++;
    80003cb0:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cb2:	0004c783          	lbu	a5,0(s1)
    80003cb6:	ff378de3          	beq	a5,s3,80003cb0 <namex+0xec>
  if(*path == 0)
    80003cba:	cf8d                	beqz	a5,80003cf4 <namex+0x130>
  while(*path != '/' && *path != 0)
    80003cbc:	0004c783          	lbu	a5,0(s1)
    80003cc0:	fd178713          	addi	a4,a5,-47
    80003cc4:	cb19                	beqz	a4,80003cda <namex+0x116>
    80003cc6:	cb91                	beqz	a5,80003cda <namex+0x116>
    80003cc8:	8926                	mv	s2,s1
    path++;
    80003cca:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003ccc:	00094783          	lbu	a5,0(s2)
    80003cd0:	fd178713          	addi	a4,a5,-47
    80003cd4:	df35                	beqz	a4,80003c50 <namex+0x8c>
    80003cd6:	fbf5                	bnez	a5,80003cca <namex+0x106>
    80003cd8:	bfa5                	j	80003c50 <namex+0x8c>
    80003cda:	8926                	mv	s2,s1
  len = path - s;
    80003cdc:	4d01                	li	s10,0
    80003cde:	4601                	li	a2,0
    memmove(name, s, len);
    80003ce0:	2601                	sext.w	a2,a2
    80003ce2:	85a6                	mv	a1,s1
    80003ce4:	8556                	mv	a0,s5
    80003ce6:	872fd0ef          	jal	80000d58 <memmove>
    name[len] = 0;
    80003cea:	9d56                	add	s10,s10,s5
    80003cec:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ff9ba68>
    80003cf0:	84ca                	mv	s1,s2
    80003cf2:	bf9d                	j	80003c68 <namex+0xa4>
  if(nameiparent){
    80003cf4:	f20b06e3          	beqz	s6,80003c20 <namex+0x5c>
    iput(ip);
    80003cf8:	8552                	mv	a0,s4
    80003cfa:	a07ff0ef          	jal	80003700 <iput>
    return 0;
    80003cfe:	4a01                	li	s4,0
    80003d00:	b705                	j	80003c20 <namex+0x5c>

0000000080003d02 <dirlink>:
{
    80003d02:	715d                	addi	sp,sp,-80
    80003d04:	e486                	sd	ra,72(sp)
    80003d06:	e0a2                	sd	s0,64(sp)
    80003d08:	f84a                	sd	s2,48(sp)
    80003d0a:	ec56                	sd	s5,24(sp)
    80003d0c:	e85a                	sd	s6,16(sp)
    80003d0e:	0880                	addi	s0,sp,80
    80003d10:	892a                	mv	s2,a0
    80003d12:	8aae                	mv	s5,a1
    80003d14:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d16:	4601                	li	a2,0
    80003d18:	e01ff0ef          	jal	80003b18 <dirlookup>
    80003d1c:	ed1d                	bnez	a0,80003d5a <dirlink+0x58>
    80003d1e:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d20:	04c92483          	lw	s1,76(s2)
    80003d24:	c4b9                	beqz	s1,80003d72 <dirlink+0x70>
    80003d26:	f44e                	sd	s3,40(sp)
    80003d28:	f052                	sd	s4,32(sp)
    80003d2a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d2c:	fb040a13          	addi	s4,s0,-80
    80003d30:	49c1                	li	s3,16
    80003d32:	874e                	mv	a4,s3
    80003d34:	86a6                	mv	a3,s1
    80003d36:	8652                	mv	a2,s4
    80003d38:	4581                	li	a1,0
    80003d3a:	854a                	mv	a0,s2
    80003d3c:	bd5ff0ef          	jal	80003910 <readi>
    80003d40:	03351163          	bne	a0,s3,80003d62 <dirlink+0x60>
    if(de.inum == 0)
    80003d44:	fb045783          	lhu	a5,-80(s0)
    80003d48:	c39d                	beqz	a5,80003d6e <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d4a:	24c1                	addiw	s1,s1,16
    80003d4c:	04c92783          	lw	a5,76(s2)
    80003d50:	fef4e1e3          	bltu	s1,a5,80003d32 <dirlink+0x30>
    80003d54:	79a2                	ld	s3,40(sp)
    80003d56:	7a02                	ld	s4,32(sp)
    80003d58:	a829                	j	80003d72 <dirlink+0x70>
    iput(ip);
    80003d5a:	9a7ff0ef          	jal	80003700 <iput>
    return -1;
    80003d5e:	557d                	li	a0,-1
    80003d60:	a83d                	j	80003d9e <dirlink+0x9c>
      panic("dirlink read");
    80003d62:	00003517          	auipc	a0,0x3
    80003d66:	77650513          	addi	a0,a0,1910 # 800074d8 <etext+0x4d8>
    80003d6a:	abbfc0ef          	jal	80000824 <panic>
    80003d6e:	79a2                	ld	s3,40(sp)
    80003d70:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003d72:	4639                	li	a2,14
    80003d74:	85d6                	mv	a1,s5
    80003d76:	fb240513          	addi	a0,s0,-78
    80003d7a:	88cfd0ef          	jal	80000e06 <strncpy>
  de.inum = inum;
    80003d7e:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d82:	4741                	li	a4,16
    80003d84:	86a6                	mv	a3,s1
    80003d86:	fb040613          	addi	a2,s0,-80
    80003d8a:	4581                	li	a1,0
    80003d8c:	854a                	mv	a0,s2
    80003d8e:	c75ff0ef          	jal	80003a02 <writei>
    80003d92:	1541                	addi	a0,a0,-16
    80003d94:	00a03533          	snez	a0,a0
    80003d98:	40a0053b          	negw	a0,a0
    80003d9c:	74e2                	ld	s1,56(sp)
}
    80003d9e:	60a6                	ld	ra,72(sp)
    80003da0:	6406                	ld	s0,64(sp)
    80003da2:	7942                	ld	s2,48(sp)
    80003da4:	6ae2                	ld	s5,24(sp)
    80003da6:	6b42                	ld	s6,16(sp)
    80003da8:	6161                	addi	sp,sp,80
    80003daa:	8082                	ret

0000000080003dac <namei>:

struct inode*
namei(char *path)
{
    80003dac:	1101                	addi	sp,sp,-32
    80003dae:	ec06                	sd	ra,24(sp)
    80003db0:	e822                	sd	s0,16(sp)
    80003db2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003db4:	fe040613          	addi	a2,s0,-32
    80003db8:	4581                	li	a1,0
    80003dba:	e0bff0ef          	jal	80003bc4 <namex>
}
    80003dbe:	60e2                	ld	ra,24(sp)
    80003dc0:	6442                	ld	s0,16(sp)
    80003dc2:	6105                	addi	sp,sp,32
    80003dc4:	8082                	ret

0000000080003dc6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003dc6:	1141                	addi	sp,sp,-16
    80003dc8:	e406                	sd	ra,8(sp)
    80003dca:	e022                	sd	s0,0(sp)
    80003dcc:	0800                	addi	s0,sp,16
    80003dce:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003dd0:	4585                	li	a1,1
    80003dd2:	df3ff0ef          	jal	80003bc4 <namex>
}
    80003dd6:	60a2                	ld	ra,8(sp)
    80003dd8:	6402                	ld	s0,0(sp)
    80003dda:	0141                	addi	sp,sp,16
    80003ddc:	8082                	ret

0000000080003dde <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003dde:	1101                	addi	sp,sp,-32
    80003de0:	ec06                	sd	ra,24(sp)
    80003de2:	e822                	sd	s0,16(sp)
    80003de4:	e426                	sd	s1,8(sp)
    80003de6:	e04a                	sd	s2,0(sp)
    80003de8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003dea:	0005e917          	auipc	s2,0x5e
    80003dee:	56e90913          	addi	s2,s2,1390 # 80062358 <log>
    80003df2:	01892583          	lw	a1,24(s2)
    80003df6:	02492503          	lw	a0,36(s2)
    80003dfa:	8ecff0ef          	jal	80002ee6 <bread>
    80003dfe:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e00:	02892603          	lw	a2,40(s2)
    80003e04:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e06:	00c05f63          	blez	a2,80003e24 <write_head+0x46>
    80003e0a:	0005e717          	auipc	a4,0x5e
    80003e0e:	57a70713          	addi	a4,a4,1402 # 80062384 <log+0x2c>
    80003e12:	87aa                	mv	a5,a0
    80003e14:	060a                	slli	a2,a2,0x2
    80003e16:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003e18:	4314                	lw	a3,0(a4)
    80003e1a:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003e1c:	0711                	addi	a4,a4,4
    80003e1e:	0791                	addi	a5,a5,4
    80003e20:	fec79ce3          	bne	a5,a2,80003e18 <write_head+0x3a>
  }
  bwrite(buf);
    80003e24:	8526                	mv	a0,s1
    80003e26:	996ff0ef          	jal	80002fbc <bwrite>
  brelse(buf);
    80003e2a:	8526                	mv	a0,s1
    80003e2c:	9c2ff0ef          	jal	80002fee <brelse>
}
    80003e30:	60e2                	ld	ra,24(sp)
    80003e32:	6442                	ld	s0,16(sp)
    80003e34:	64a2                	ld	s1,8(sp)
    80003e36:	6902                	ld	s2,0(sp)
    80003e38:	6105                	addi	sp,sp,32
    80003e3a:	8082                	ret

0000000080003e3c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e3c:	0005e797          	auipc	a5,0x5e
    80003e40:	5447a783          	lw	a5,1348(a5) # 80062380 <log+0x28>
    80003e44:	0cf05163          	blez	a5,80003f06 <install_trans+0xca>
{
    80003e48:	715d                	addi	sp,sp,-80
    80003e4a:	e486                	sd	ra,72(sp)
    80003e4c:	e0a2                	sd	s0,64(sp)
    80003e4e:	fc26                	sd	s1,56(sp)
    80003e50:	f84a                	sd	s2,48(sp)
    80003e52:	f44e                	sd	s3,40(sp)
    80003e54:	f052                	sd	s4,32(sp)
    80003e56:	ec56                	sd	s5,24(sp)
    80003e58:	e85a                	sd	s6,16(sp)
    80003e5a:	e45e                	sd	s7,8(sp)
    80003e5c:	e062                	sd	s8,0(sp)
    80003e5e:	0880                	addi	s0,sp,80
    80003e60:	8b2a                	mv	s6,a0
    80003e62:	0005ea97          	auipc	s5,0x5e
    80003e66:	522a8a93          	addi	s5,s5,1314 # 80062384 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e6a:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003e6c:	00003c17          	auipc	s8,0x3
    80003e70:	67cc0c13          	addi	s8,s8,1660 # 800074e8 <etext+0x4e8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e74:	0005ea17          	auipc	s4,0x5e
    80003e78:	4e4a0a13          	addi	s4,s4,1252 # 80062358 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003e7c:	40000b93          	li	s7,1024
    80003e80:	a025                	j	80003ea8 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003e82:	000aa603          	lw	a2,0(s5)
    80003e86:	85ce                	mv	a1,s3
    80003e88:	8562                	mv	a0,s8
    80003e8a:	e70fc0ef          	jal	800004fa <printf>
    80003e8e:	a839                	j	80003eac <install_trans+0x70>
    brelse(lbuf);
    80003e90:	854a                	mv	a0,s2
    80003e92:	95cff0ef          	jal	80002fee <brelse>
    brelse(dbuf);
    80003e96:	8526                	mv	a0,s1
    80003e98:	956ff0ef          	jal	80002fee <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e9c:	2985                	addiw	s3,s3,1
    80003e9e:	0a91                	addi	s5,s5,4
    80003ea0:	028a2783          	lw	a5,40(s4)
    80003ea4:	04f9d563          	bge	s3,a5,80003eee <install_trans+0xb2>
    if(recovering) {
    80003ea8:	fc0b1de3          	bnez	s6,80003e82 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003eac:	018a2583          	lw	a1,24(s4)
    80003eb0:	013585bb          	addw	a1,a1,s3
    80003eb4:	2585                	addiw	a1,a1,1
    80003eb6:	024a2503          	lw	a0,36(s4)
    80003eba:	82cff0ef          	jal	80002ee6 <bread>
    80003ebe:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003ec0:	000aa583          	lw	a1,0(s5)
    80003ec4:	024a2503          	lw	a0,36(s4)
    80003ec8:	81eff0ef          	jal	80002ee6 <bread>
    80003ecc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003ece:	865e                	mv	a2,s7
    80003ed0:	05890593          	addi	a1,s2,88
    80003ed4:	05850513          	addi	a0,a0,88
    80003ed8:	e81fc0ef          	jal	80000d58 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003edc:	8526                	mv	a0,s1
    80003ede:	8deff0ef          	jal	80002fbc <bwrite>
    if(recovering == 0)
    80003ee2:	fa0b17e3          	bnez	s6,80003e90 <install_trans+0x54>
      bunpin(dbuf);
    80003ee6:	8526                	mv	a0,s1
    80003ee8:	9beff0ef          	jal	800030a6 <bunpin>
    80003eec:	b755                	j	80003e90 <install_trans+0x54>
}
    80003eee:	60a6                	ld	ra,72(sp)
    80003ef0:	6406                	ld	s0,64(sp)
    80003ef2:	74e2                	ld	s1,56(sp)
    80003ef4:	7942                	ld	s2,48(sp)
    80003ef6:	79a2                	ld	s3,40(sp)
    80003ef8:	7a02                	ld	s4,32(sp)
    80003efa:	6ae2                	ld	s5,24(sp)
    80003efc:	6b42                	ld	s6,16(sp)
    80003efe:	6ba2                	ld	s7,8(sp)
    80003f00:	6c02                	ld	s8,0(sp)
    80003f02:	6161                	addi	sp,sp,80
    80003f04:	8082                	ret
    80003f06:	8082                	ret

0000000080003f08 <initlog>:
{
    80003f08:	7179                	addi	sp,sp,-48
    80003f0a:	f406                	sd	ra,40(sp)
    80003f0c:	f022                	sd	s0,32(sp)
    80003f0e:	ec26                	sd	s1,24(sp)
    80003f10:	e84a                	sd	s2,16(sp)
    80003f12:	e44e                	sd	s3,8(sp)
    80003f14:	1800                	addi	s0,sp,48
    80003f16:	84aa                	mv	s1,a0
    80003f18:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003f1a:	0005e917          	auipc	s2,0x5e
    80003f1e:	43e90913          	addi	s2,s2,1086 # 80062358 <log>
    80003f22:	00003597          	auipc	a1,0x3
    80003f26:	5e658593          	addi	a1,a1,1510 # 80007508 <etext+0x508>
    80003f2a:	854a                	mv	a0,s2
    80003f2c:	c73fc0ef          	jal	80000b9e <initlock>
  log.start = sb->logstart;
    80003f30:	0149a583          	lw	a1,20(s3)
    80003f34:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003f38:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003f3c:	8526                	mv	a0,s1
    80003f3e:	fa9fe0ef          	jal	80002ee6 <bread>
  log.lh.n = lh->n;
    80003f42:	4d30                	lw	a2,88(a0)
    80003f44:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003f48:	00c05f63          	blez	a2,80003f66 <initlog+0x5e>
    80003f4c:	87aa                	mv	a5,a0
    80003f4e:	0005e717          	auipc	a4,0x5e
    80003f52:	43670713          	addi	a4,a4,1078 # 80062384 <log+0x2c>
    80003f56:	060a                	slli	a2,a2,0x2
    80003f58:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003f5a:	4ff4                	lw	a3,92(a5)
    80003f5c:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f5e:	0791                	addi	a5,a5,4
    80003f60:	0711                	addi	a4,a4,4
    80003f62:	fec79ce3          	bne	a5,a2,80003f5a <initlog+0x52>
  brelse(buf);
    80003f66:	888ff0ef          	jal	80002fee <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003f6a:	4505                	li	a0,1
    80003f6c:	ed1ff0ef          	jal	80003e3c <install_trans>
  log.lh.n = 0;
    80003f70:	0005e797          	auipc	a5,0x5e
    80003f74:	4007a823          	sw	zero,1040(a5) # 80062380 <log+0x28>
  write_head(); // clear the log
    80003f78:	e67ff0ef          	jal	80003dde <write_head>
}
    80003f7c:	70a2                	ld	ra,40(sp)
    80003f7e:	7402                	ld	s0,32(sp)
    80003f80:	64e2                	ld	s1,24(sp)
    80003f82:	6942                	ld	s2,16(sp)
    80003f84:	69a2                	ld	s3,8(sp)
    80003f86:	6145                	addi	sp,sp,48
    80003f88:	8082                	ret

0000000080003f8a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003f8a:	1101                	addi	sp,sp,-32
    80003f8c:	ec06                	sd	ra,24(sp)
    80003f8e:	e822                	sd	s0,16(sp)
    80003f90:	e426                	sd	s1,8(sp)
    80003f92:	e04a                	sd	s2,0(sp)
    80003f94:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003f96:	0005e517          	auipc	a0,0x5e
    80003f9a:	3c250513          	addi	a0,a0,962 # 80062358 <log>
    80003f9e:	c8bfc0ef          	jal	80000c28 <acquire>
  while(1){
    if(log.committing){
    80003fa2:	0005e497          	auipc	s1,0x5e
    80003fa6:	3b648493          	addi	s1,s1,950 # 80062358 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003faa:	4979                	li	s2,30
    80003fac:	a029                	j	80003fb6 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003fae:	85a6                	mv	a1,s1
    80003fb0:	8526                	mv	a0,s1
    80003fb2:	fc3fd0ef          	jal	80001f74 <sleep>
    if(log.committing){
    80003fb6:	509c                	lw	a5,32(s1)
    80003fb8:	fbfd                	bnez	a5,80003fae <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003fba:	4cd8                	lw	a4,28(s1)
    80003fbc:	2705                	addiw	a4,a4,1
    80003fbe:	0027179b          	slliw	a5,a4,0x2
    80003fc2:	9fb9                	addw	a5,a5,a4
    80003fc4:	0017979b          	slliw	a5,a5,0x1
    80003fc8:	5494                	lw	a3,40(s1)
    80003fca:	9fb5                	addw	a5,a5,a3
    80003fcc:	00f95763          	bge	s2,a5,80003fda <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003fd0:	85a6                	mv	a1,s1
    80003fd2:	8526                	mv	a0,s1
    80003fd4:	fa1fd0ef          	jal	80001f74 <sleep>
    80003fd8:	bff9                	j	80003fb6 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003fda:	0005e797          	auipc	a5,0x5e
    80003fde:	38e7ad23          	sw	a4,922(a5) # 80062374 <log+0x1c>
      release(&log.lock);
    80003fe2:	0005e517          	auipc	a0,0x5e
    80003fe6:	37650513          	addi	a0,a0,886 # 80062358 <log>
    80003fea:	cd3fc0ef          	jal	80000cbc <release>
      break;
    }
  }
}
    80003fee:	60e2                	ld	ra,24(sp)
    80003ff0:	6442                	ld	s0,16(sp)
    80003ff2:	64a2                	ld	s1,8(sp)
    80003ff4:	6902                	ld	s2,0(sp)
    80003ff6:	6105                	addi	sp,sp,32
    80003ff8:	8082                	ret

0000000080003ffa <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003ffa:	7139                	addi	sp,sp,-64
    80003ffc:	fc06                	sd	ra,56(sp)
    80003ffe:	f822                	sd	s0,48(sp)
    80004000:	f426                	sd	s1,40(sp)
    80004002:	f04a                	sd	s2,32(sp)
    80004004:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004006:	0005e497          	auipc	s1,0x5e
    8000400a:	35248493          	addi	s1,s1,850 # 80062358 <log>
    8000400e:	8526                	mv	a0,s1
    80004010:	c19fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80004014:	4cdc                	lw	a5,28(s1)
    80004016:	37fd                	addiw	a5,a5,-1
    80004018:	893e                	mv	s2,a5
    8000401a:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    8000401c:	509c                	lw	a5,32(s1)
    8000401e:	e7b1                	bnez	a5,8000406a <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    80004020:	04091e63          	bnez	s2,8000407c <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    80004024:	0005e497          	auipc	s1,0x5e
    80004028:	33448493          	addi	s1,s1,820 # 80062358 <log>
    8000402c:	4785                	li	a5,1
    8000402e:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004030:	8526                	mv	a0,s1
    80004032:	c8bfc0ef          	jal	80000cbc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004036:	549c                	lw	a5,40(s1)
    80004038:	06f04463          	bgtz	a5,800040a0 <end_op+0xa6>
    acquire(&log.lock);
    8000403c:	0005e517          	auipc	a0,0x5e
    80004040:	31c50513          	addi	a0,a0,796 # 80062358 <log>
    80004044:	be5fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80004048:	0005e797          	auipc	a5,0x5e
    8000404c:	3207a823          	sw	zero,816(a5) # 80062378 <log+0x20>
    wakeup(&log);
    80004050:	0005e517          	auipc	a0,0x5e
    80004054:	30850513          	addi	a0,a0,776 # 80062358 <log>
    80004058:	f69fd0ef          	jal	80001fc0 <wakeup>
    release(&log.lock);
    8000405c:	0005e517          	auipc	a0,0x5e
    80004060:	2fc50513          	addi	a0,a0,764 # 80062358 <log>
    80004064:	c59fc0ef          	jal	80000cbc <release>
}
    80004068:	a035                	j	80004094 <end_op+0x9a>
    8000406a:	ec4e                	sd	s3,24(sp)
    8000406c:	e852                	sd	s4,16(sp)
    8000406e:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004070:	00003517          	auipc	a0,0x3
    80004074:	4a050513          	addi	a0,a0,1184 # 80007510 <etext+0x510>
    80004078:	facfc0ef          	jal	80000824 <panic>
    wakeup(&log);
    8000407c:	0005e517          	auipc	a0,0x5e
    80004080:	2dc50513          	addi	a0,a0,732 # 80062358 <log>
    80004084:	f3dfd0ef          	jal	80001fc0 <wakeup>
  release(&log.lock);
    80004088:	0005e517          	auipc	a0,0x5e
    8000408c:	2d050513          	addi	a0,a0,720 # 80062358 <log>
    80004090:	c2dfc0ef          	jal	80000cbc <release>
}
    80004094:	70e2                	ld	ra,56(sp)
    80004096:	7442                	ld	s0,48(sp)
    80004098:	74a2                	ld	s1,40(sp)
    8000409a:	7902                	ld	s2,32(sp)
    8000409c:	6121                	addi	sp,sp,64
    8000409e:	8082                	ret
    800040a0:	ec4e                	sd	s3,24(sp)
    800040a2:	e852                	sd	s4,16(sp)
    800040a4:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800040a6:	0005ea97          	auipc	s5,0x5e
    800040aa:	2dea8a93          	addi	s5,s5,734 # 80062384 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800040ae:	0005ea17          	auipc	s4,0x5e
    800040b2:	2aaa0a13          	addi	s4,s4,682 # 80062358 <log>
    800040b6:	018a2583          	lw	a1,24(s4)
    800040ba:	012585bb          	addw	a1,a1,s2
    800040be:	2585                	addiw	a1,a1,1
    800040c0:	024a2503          	lw	a0,36(s4)
    800040c4:	e23fe0ef          	jal	80002ee6 <bread>
    800040c8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800040ca:	000aa583          	lw	a1,0(s5)
    800040ce:	024a2503          	lw	a0,36(s4)
    800040d2:	e15fe0ef          	jal	80002ee6 <bread>
    800040d6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800040d8:	40000613          	li	a2,1024
    800040dc:	05850593          	addi	a1,a0,88
    800040e0:	05848513          	addi	a0,s1,88
    800040e4:	c75fc0ef          	jal	80000d58 <memmove>
    bwrite(to);  // write the log
    800040e8:	8526                	mv	a0,s1
    800040ea:	ed3fe0ef          	jal	80002fbc <bwrite>
    brelse(from);
    800040ee:	854e                	mv	a0,s3
    800040f0:	efffe0ef          	jal	80002fee <brelse>
    brelse(to);
    800040f4:	8526                	mv	a0,s1
    800040f6:	ef9fe0ef          	jal	80002fee <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040fa:	2905                	addiw	s2,s2,1
    800040fc:	0a91                	addi	s5,s5,4
    800040fe:	028a2783          	lw	a5,40(s4)
    80004102:	faf94ae3          	blt	s2,a5,800040b6 <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004106:	cd9ff0ef          	jal	80003dde <write_head>
    install_trans(0); // Now install writes to home locations
    8000410a:	4501                	li	a0,0
    8000410c:	d31ff0ef          	jal	80003e3c <install_trans>
    log.lh.n = 0;
    80004110:	0005e797          	auipc	a5,0x5e
    80004114:	2607a823          	sw	zero,624(a5) # 80062380 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004118:	cc7ff0ef          	jal	80003dde <write_head>
    8000411c:	69e2                	ld	s3,24(sp)
    8000411e:	6a42                	ld	s4,16(sp)
    80004120:	6aa2                	ld	s5,8(sp)
    80004122:	bf29                	j	8000403c <end_op+0x42>

0000000080004124 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004124:	1101                	addi	sp,sp,-32
    80004126:	ec06                	sd	ra,24(sp)
    80004128:	e822                	sd	s0,16(sp)
    8000412a:	e426                	sd	s1,8(sp)
    8000412c:	1000                	addi	s0,sp,32
    8000412e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004130:	0005e517          	auipc	a0,0x5e
    80004134:	22850513          	addi	a0,a0,552 # 80062358 <log>
    80004138:	af1fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000413c:	0005e617          	auipc	a2,0x5e
    80004140:	24462603          	lw	a2,580(a2) # 80062380 <log+0x28>
    80004144:	47f5                	li	a5,29
    80004146:	04c7cd63          	blt	a5,a2,800041a0 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000414a:	0005e797          	auipc	a5,0x5e
    8000414e:	22a7a783          	lw	a5,554(a5) # 80062374 <log+0x1c>
    80004152:	04f05d63          	blez	a5,800041ac <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004156:	4781                	li	a5,0
    80004158:	06c05063          	blez	a2,800041b8 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000415c:	44cc                	lw	a1,12(s1)
    8000415e:	0005e717          	auipc	a4,0x5e
    80004162:	22670713          	addi	a4,a4,550 # 80062384 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004166:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004168:	4314                	lw	a3,0(a4)
    8000416a:	04b68763          	beq	a3,a1,800041b8 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    8000416e:	2785                	addiw	a5,a5,1
    80004170:	0711                	addi	a4,a4,4
    80004172:	fef61be3          	bne	a2,a5,80004168 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004176:	060a                	slli	a2,a2,0x2
    80004178:	02060613          	addi	a2,a2,32
    8000417c:	0005e797          	auipc	a5,0x5e
    80004180:	1dc78793          	addi	a5,a5,476 # 80062358 <log>
    80004184:	97b2                	add	a5,a5,a2
    80004186:	44d8                	lw	a4,12(s1)
    80004188:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000418a:	8526                	mv	a0,s1
    8000418c:	ee7fe0ef          	jal	80003072 <bpin>
    log.lh.n++;
    80004190:	0005e717          	auipc	a4,0x5e
    80004194:	1c870713          	addi	a4,a4,456 # 80062358 <log>
    80004198:	571c                	lw	a5,40(a4)
    8000419a:	2785                	addiw	a5,a5,1
    8000419c:	d71c                	sw	a5,40(a4)
    8000419e:	a815                	j	800041d2 <log_write+0xae>
    panic("too big a transaction");
    800041a0:	00003517          	auipc	a0,0x3
    800041a4:	38050513          	addi	a0,a0,896 # 80007520 <etext+0x520>
    800041a8:	e7cfc0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    800041ac:	00003517          	auipc	a0,0x3
    800041b0:	38c50513          	addi	a0,a0,908 # 80007538 <etext+0x538>
    800041b4:	e70fc0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    800041b8:	00279693          	slli	a3,a5,0x2
    800041bc:	02068693          	addi	a3,a3,32
    800041c0:	0005e717          	auipc	a4,0x5e
    800041c4:	19870713          	addi	a4,a4,408 # 80062358 <log>
    800041c8:	9736                	add	a4,a4,a3
    800041ca:	44d4                	lw	a3,12(s1)
    800041cc:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800041ce:	faf60ee3          	beq	a2,a5,8000418a <log_write+0x66>
  }
  release(&log.lock);
    800041d2:	0005e517          	auipc	a0,0x5e
    800041d6:	18650513          	addi	a0,a0,390 # 80062358 <log>
    800041da:	ae3fc0ef          	jal	80000cbc <release>
}
    800041de:	60e2                	ld	ra,24(sp)
    800041e0:	6442                	ld	s0,16(sp)
    800041e2:	64a2                	ld	s1,8(sp)
    800041e4:	6105                	addi	sp,sp,32
    800041e6:	8082                	ret

00000000800041e8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800041e8:	1101                	addi	sp,sp,-32
    800041ea:	ec06                	sd	ra,24(sp)
    800041ec:	e822                	sd	s0,16(sp)
    800041ee:	e426                	sd	s1,8(sp)
    800041f0:	e04a                	sd	s2,0(sp)
    800041f2:	1000                	addi	s0,sp,32
    800041f4:	84aa                	mv	s1,a0
    800041f6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800041f8:	00003597          	auipc	a1,0x3
    800041fc:	36058593          	addi	a1,a1,864 # 80007558 <etext+0x558>
    80004200:	0521                	addi	a0,a0,8
    80004202:	99dfc0ef          	jal	80000b9e <initlock>
  lk->name = name;
    80004206:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000420a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000420e:	0204a423          	sw	zero,40(s1)
}
    80004212:	60e2                	ld	ra,24(sp)
    80004214:	6442                	ld	s0,16(sp)
    80004216:	64a2                	ld	s1,8(sp)
    80004218:	6902                	ld	s2,0(sp)
    8000421a:	6105                	addi	sp,sp,32
    8000421c:	8082                	ret

000000008000421e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000421e:	1101                	addi	sp,sp,-32
    80004220:	ec06                	sd	ra,24(sp)
    80004222:	e822                	sd	s0,16(sp)
    80004224:	e426                	sd	s1,8(sp)
    80004226:	e04a                	sd	s2,0(sp)
    80004228:	1000                	addi	s0,sp,32
    8000422a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000422c:	00850913          	addi	s2,a0,8
    80004230:	854a                	mv	a0,s2
    80004232:	9f7fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004236:	409c                	lw	a5,0(s1)
    80004238:	c799                	beqz	a5,80004246 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    8000423a:	85ca                	mv	a1,s2
    8000423c:	8526                	mv	a0,s1
    8000423e:	d37fd0ef          	jal	80001f74 <sleep>
  while (lk->locked) {
    80004242:	409c                	lw	a5,0(s1)
    80004244:	fbfd                	bnez	a5,8000423a <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004246:	4785                	li	a5,1
    80004248:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000424a:	eeafd0ef          	jal	80001934 <myproc>
    8000424e:	591c                	lw	a5,48(a0)
    80004250:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004252:	854a                	mv	a0,s2
    80004254:	a69fc0ef          	jal	80000cbc <release>
}
    80004258:	60e2                	ld	ra,24(sp)
    8000425a:	6442                	ld	s0,16(sp)
    8000425c:	64a2                	ld	s1,8(sp)
    8000425e:	6902                	ld	s2,0(sp)
    80004260:	6105                	addi	sp,sp,32
    80004262:	8082                	ret

0000000080004264 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004264:	1101                	addi	sp,sp,-32
    80004266:	ec06                	sd	ra,24(sp)
    80004268:	e822                	sd	s0,16(sp)
    8000426a:	e426                	sd	s1,8(sp)
    8000426c:	e04a                	sd	s2,0(sp)
    8000426e:	1000                	addi	s0,sp,32
    80004270:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004272:	00850913          	addi	s2,a0,8
    80004276:	854a                	mv	a0,s2
    80004278:	9b1fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    8000427c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004280:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004284:	8526                	mv	a0,s1
    80004286:	d3bfd0ef          	jal	80001fc0 <wakeup>
  release(&lk->lk);
    8000428a:	854a                	mv	a0,s2
    8000428c:	a31fc0ef          	jal	80000cbc <release>
}
    80004290:	60e2                	ld	ra,24(sp)
    80004292:	6442                	ld	s0,16(sp)
    80004294:	64a2                	ld	s1,8(sp)
    80004296:	6902                	ld	s2,0(sp)
    80004298:	6105                	addi	sp,sp,32
    8000429a:	8082                	ret

000000008000429c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000429c:	7179                	addi	sp,sp,-48
    8000429e:	f406                	sd	ra,40(sp)
    800042a0:	f022                	sd	s0,32(sp)
    800042a2:	ec26                	sd	s1,24(sp)
    800042a4:	e84a                	sd	s2,16(sp)
    800042a6:	1800                	addi	s0,sp,48
    800042a8:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800042aa:	00850913          	addi	s2,a0,8
    800042ae:	854a                	mv	a0,s2
    800042b0:	979fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800042b4:	409c                	lw	a5,0(s1)
    800042b6:	ef81                	bnez	a5,800042ce <holdingsleep+0x32>
    800042b8:	4481                	li	s1,0
  release(&lk->lk);
    800042ba:	854a                	mv	a0,s2
    800042bc:	a01fc0ef          	jal	80000cbc <release>
  return r;
}
    800042c0:	8526                	mv	a0,s1
    800042c2:	70a2                	ld	ra,40(sp)
    800042c4:	7402                	ld	s0,32(sp)
    800042c6:	64e2                	ld	s1,24(sp)
    800042c8:	6942                	ld	s2,16(sp)
    800042ca:	6145                	addi	sp,sp,48
    800042cc:	8082                	ret
    800042ce:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800042d0:	0284a983          	lw	s3,40(s1)
    800042d4:	e60fd0ef          	jal	80001934 <myproc>
    800042d8:	5904                	lw	s1,48(a0)
    800042da:	413484b3          	sub	s1,s1,s3
    800042de:	0014b493          	seqz	s1,s1
    800042e2:	69a2                	ld	s3,8(sp)
    800042e4:	bfd9                	j	800042ba <holdingsleep+0x1e>

00000000800042e6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800042e6:	1141                	addi	sp,sp,-16
    800042e8:	e406                	sd	ra,8(sp)
    800042ea:	e022                	sd	s0,0(sp)
    800042ec:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800042ee:	00003597          	auipc	a1,0x3
    800042f2:	27a58593          	addi	a1,a1,634 # 80007568 <etext+0x568>
    800042f6:	0005e517          	auipc	a0,0x5e
    800042fa:	1aa50513          	addi	a0,a0,426 # 800624a0 <ftable>
    800042fe:	8a1fc0ef          	jal	80000b9e <initlock>
}
    80004302:	60a2                	ld	ra,8(sp)
    80004304:	6402                	ld	s0,0(sp)
    80004306:	0141                	addi	sp,sp,16
    80004308:	8082                	ret

000000008000430a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000430a:	1101                	addi	sp,sp,-32
    8000430c:	ec06                	sd	ra,24(sp)
    8000430e:	e822                	sd	s0,16(sp)
    80004310:	e426                	sd	s1,8(sp)
    80004312:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004314:	0005e517          	auipc	a0,0x5e
    80004318:	18c50513          	addi	a0,a0,396 # 800624a0 <ftable>
    8000431c:	90dfc0ef          	jal	80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004320:	0005e497          	auipc	s1,0x5e
    80004324:	19848493          	addi	s1,s1,408 # 800624b8 <ftable+0x18>
    80004328:	0005f717          	auipc	a4,0x5f
    8000432c:	13070713          	addi	a4,a4,304 # 80063458 <disk>
    if(f->ref == 0){
    80004330:	40dc                	lw	a5,4(s1)
    80004332:	cf89                	beqz	a5,8000434c <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004334:	02848493          	addi	s1,s1,40
    80004338:	fee49ce3          	bne	s1,a4,80004330 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000433c:	0005e517          	auipc	a0,0x5e
    80004340:	16450513          	addi	a0,a0,356 # 800624a0 <ftable>
    80004344:	979fc0ef          	jal	80000cbc <release>
  return 0;
    80004348:	4481                	li	s1,0
    8000434a:	a809                	j	8000435c <filealloc+0x52>
      f->ref = 1;
    8000434c:	4785                	li	a5,1
    8000434e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004350:	0005e517          	auipc	a0,0x5e
    80004354:	15050513          	addi	a0,a0,336 # 800624a0 <ftable>
    80004358:	965fc0ef          	jal	80000cbc <release>
}
    8000435c:	8526                	mv	a0,s1
    8000435e:	60e2                	ld	ra,24(sp)
    80004360:	6442                	ld	s0,16(sp)
    80004362:	64a2                	ld	s1,8(sp)
    80004364:	6105                	addi	sp,sp,32
    80004366:	8082                	ret

0000000080004368 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004368:	1101                	addi	sp,sp,-32
    8000436a:	ec06                	sd	ra,24(sp)
    8000436c:	e822                	sd	s0,16(sp)
    8000436e:	e426                	sd	s1,8(sp)
    80004370:	1000                	addi	s0,sp,32
    80004372:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004374:	0005e517          	auipc	a0,0x5e
    80004378:	12c50513          	addi	a0,a0,300 # 800624a0 <ftable>
    8000437c:	8adfc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    80004380:	40dc                	lw	a5,4(s1)
    80004382:	02f05063          	blez	a5,800043a2 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004386:	2785                	addiw	a5,a5,1
    80004388:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000438a:	0005e517          	auipc	a0,0x5e
    8000438e:	11650513          	addi	a0,a0,278 # 800624a0 <ftable>
    80004392:	92bfc0ef          	jal	80000cbc <release>
  return f;
}
    80004396:	8526                	mv	a0,s1
    80004398:	60e2                	ld	ra,24(sp)
    8000439a:	6442                	ld	s0,16(sp)
    8000439c:	64a2                	ld	s1,8(sp)
    8000439e:	6105                	addi	sp,sp,32
    800043a0:	8082                	ret
    panic("filedup");
    800043a2:	00003517          	auipc	a0,0x3
    800043a6:	1ce50513          	addi	a0,a0,462 # 80007570 <etext+0x570>
    800043aa:	c7afc0ef          	jal	80000824 <panic>

00000000800043ae <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800043ae:	7139                	addi	sp,sp,-64
    800043b0:	fc06                	sd	ra,56(sp)
    800043b2:	f822                	sd	s0,48(sp)
    800043b4:	f426                	sd	s1,40(sp)
    800043b6:	0080                	addi	s0,sp,64
    800043b8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800043ba:	0005e517          	auipc	a0,0x5e
    800043be:	0e650513          	addi	a0,a0,230 # 800624a0 <ftable>
    800043c2:	867fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    800043c6:	40dc                	lw	a5,4(s1)
    800043c8:	04f05a63          	blez	a5,8000441c <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800043cc:	37fd                	addiw	a5,a5,-1
    800043ce:	c0dc                	sw	a5,4(s1)
    800043d0:	06f04063          	bgtz	a5,80004430 <fileclose+0x82>
    800043d4:	f04a                	sd	s2,32(sp)
    800043d6:	ec4e                	sd	s3,24(sp)
    800043d8:	e852                	sd	s4,16(sp)
    800043da:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800043dc:	0004a903          	lw	s2,0(s1)
    800043e0:	0094c783          	lbu	a5,9(s1)
    800043e4:	89be                	mv	s3,a5
    800043e6:	689c                	ld	a5,16(s1)
    800043e8:	8a3e                	mv	s4,a5
    800043ea:	6c9c                	ld	a5,24(s1)
    800043ec:	8abe                	mv	s5,a5
  f->ref = 0;
    800043ee:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800043f2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800043f6:	0005e517          	auipc	a0,0x5e
    800043fa:	0aa50513          	addi	a0,a0,170 # 800624a0 <ftable>
    800043fe:	8bffc0ef          	jal	80000cbc <release>

  if(ff.type == FD_PIPE){
    80004402:	4785                	li	a5,1
    80004404:	04f90163          	beq	s2,a5,80004446 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004408:	ffe9079b          	addiw	a5,s2,-2
    8000440c:	4705                	li	a4,1
    8000440e:	04f77563          	bgeu	a4,a5,80004458 <fileclose+0xaa>
    80004412:	7902                	ld	s2,32(sp)
    80004414:	69e2                	ld	s3,24(sp)
    80004416:	6a42                	ld	s4,16(sp)
    80004418:	6aa2                	ld	s5,8(sp)
    8000441a:	a00d                	j	8000443c <fileclose+0x8e>
    8000441c:	f04a                	sd	s2,32(sp)
    8000441e:	ec4e                	sd	s3,24(sp)
    80004420:	e852                	sd	s4,16(sp)
    80004422:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004424:	00003517          	auipc	a0,0x3
    80004428:	15450513          	addi	a0,a0,340 # 80007578 <etext+0x578>
    8000442c:	bf8fc0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    80004430:	0005e517          	auipc	a0,0x5e
    80004434:	07050513          	addi	a0,a0,112 # 800624a0 <ftable>
    80004438:	885fc0ef          	jal	80000cbc <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000443c:	70e2                	ld	ra,56(sp)
    8000443e:	7442                	ld	s0,48(sp)
    80004440:	74a2                	ld	s1,40(sp)
    80004442:	6121                	addi	sp,sp,64
    80004444:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004446:	85ce                	mv	a1,s3
    80004448:	8552                	mv	a0,s4
    8000444a:	348000ef          	jal	80004792 <pipeclose>
    8000444e:	7902                	ld	s2,32(sp)
    80004450:	69e2                	ld	s3,24(sp)
    80004452:	6a42                	ld	s4,16(sp)
    80004454:	6aa2                	ld	s5,8(sp)
    80004456:	b7dd                	j	8000443c <fileclose+0x8e>
    begin_op();
    80004458:	b33ff0ef          	jal	80003f8a <begin_op>
    iput(ff.ip);
    8000445c:	8556                	mv	a0,s5
    8000445e:	aa2ff0ef          	jal	80003700 <iput>
    end_op();
    80004462:	b99ff0ef          	jal	80003ffa <end_op>
    80004466:	7902                	ld	s2,32(sp)
    80004468:	69e2                	ld	s3,24(sp)
    8000446a:	6a42                	ld	s4,16(sp)
    8000446c:	6aa2                	ld	s5,8(sp)
    8000446e:	b7f9                	j	8000443c <fileclose+0x8e>

0000000080004470 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004470:	715d                	addi	sp,sp,-80
    80004472:	e486                	sd	ra,72(sp)
    80004474:	e0a2                	sd	s0,64(sp)
    80004476:	fc26                	sd	s1,56(sp)
    80004478:	f052                	sd	s4,32(sp)
    8000447a:	0880                	addi	s0,sp,80
    8000447c:	84aa                	mv	s1,a0
    8000447e:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004480:	cb4fd0ef          	jal	80001934 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004484:	409c                	lw	a5,0(s1)
    80004486:	37f9                	addiw	a5,a5,-2
    80004488:	4705                	li	a4,1
    8000448a:	04f76263          	bltu	a4,a5,800044ce <filestat+0x5e>
    8000448e:	f84a                	sd	s2,48(sp)
    80004490:	f44e                	sd	s3,40(sp)
    80004492:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004494:	6c88                	ld	a0,24(s1)
    80004496:	8e8ff0ef          	jal	8000357e <ilock>
    stati(f->ip, &st);
    8000449a:	fb840913          	addi	s2,s0,-72
    8000449e:	85ca                	mv	a1,s2
    800044a0:	6c88                	ld	a0,24(s1)
    800044a2:	c40ff0ef          	jal	800038e2 <stati>
    iunlock(f->ip);
    800044a6:	6c88                	ld	a0,24(s1)
    800044a8:	984ff0ef          	jal	8000362c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800044ac:	46e1                	li	a3,24
    800044ae:	864a                	mv	a2,s2
    800044b0:	85d2                	mv	a1,s4
    800044b2:	0509b503          	ld	a0,80(s3)
    800044b6:	99efd0ef          	jal	80001654 <copyout>
    800044ba:	41f5551b          	sraiw	a0,a0,0x1f
    800044be:	7942                	ld	s2,48(sp)
    800044c0:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800044c2:	60a6                	ld	ra,72(sp)
    800044c4:	6406                	ld	s0,64(sp)
    800044c6:	74e2                	ld	s1,56(sp)
    800044c8:	7a02                	ld	s4,32(sp)
    800044ca:	6161                	addi	sp,sp,80
    800044cc:	8082                	ret
  return -1;
    800044ce:	557d                	li	a0,-1
    800044d0:	bfcd                	j	800044c2 <filestat+0x52>

00000000800044d2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800044d2:	7179                	addi	sp,sp,-48
    800044d4:	f406                	sd	ra,40(sp)
    800044d6:	f022                	sd	s0,32(sp)
    800044d8:	e84a                	sd	s2,16(sp)
    800044da:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800044dc:	00854783          	lbu	a5,8(a0)
    800044e0:	cfd1                	beqz	a5,8000457c <fileread+0xaa>
    800044e2:	ec26                	sd	s1,24(sp)
    800044e4:	e44e                	sd	s3,8(sp)
    800044e6:	84aa                	mv	s1,a0
    800044e8:	892e                	mv	s2,a1
    800044ea:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    800044ec:	411c                	lw	a5,0(a0)
    800044ee:	4705                	li	a4,1
    800044f0:	04e78363          	beq	a5,a4,80004536 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800044f4:	470d                	li	a4,3
    800044f6:	04e78763          	beq	a5,a4,80004544 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800044fa:	4709                	li	a4,2
    800044fc:	06e79a63          	bne	a5,a4,80004570 <fileread+0x9e>
    ilock(f->ip);
    80004500:	6d08                	ld	a0,24(a0)
    80004502:	87cff0ef          	jal	8000357e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004506:	874e                	mv	a4,s3
    80004508:	5094                	lw	a3,32(s1)
    8000450a:	864a                	mv	a2,s2
    8000450c:	4585                	li	a1,1
    8000450e:	6c88                	ld	a0,24(s1)
    80004510:	c00ff0ef          	jal	80003910 <readi>
    80004514:	892a                	mv	s2,a0
    80004516:	00a05563          	blez	a0,80004520 <fileread+0x4e>
      f->off += r;
    8000451a:	509c                	lw	a5,32(s1)
    8000451c:	9fa9                	addw	a5,a5,a0
    8000451e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004520:	6c88                	ld	a0,24(s1)
    80004522:	90aff0ef          	jal	8000362c <iunlock>
    80004526:	64e2                	ld	s1,24(sp)
    80004528:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000452a:	854a                	mv	a0,s2
    8000452c:	70a2                	ld	ra,40(sp)
    8000452e:	7402                	ld	s0,32(sp)
    80004530:	6942                	ld	s2,16(sp)
    80004532:	6145                	addi	sp,sp,48
    80004534:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004536:	6908                	ld	a0,16(a0)
    80004538:	3b0000ef          	jal	800048e8 <piperead>
    8000453c:	892a                	mv	s2,a0
    8000453e:	64e2                	ld	s1,24(sp)
    80004540:	69a2                	ld	s3,8(sp)
    80004542:	b7e5                	j	8000452a <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004544:	02451783          	lh	a5,36(a0)
    80004548:	03079693          	slli	a3,a5,0x30
    8000454c:	92c1                	srli	a3,a3,0x30
    8000454e:	4725                	li	a4,9
    80004550:	02d76963          	bltu	a4,a3,80004582 <fileread+0xb0>
    80004554:	0792                	slli	a5,a5,0x4
    80004556:	0005e717          	auipc	a4,0x5e
    8000455a:	eaa70713          	addi	a4,a4,-342 # 80062400 <devsw>
    8000455e:	97ba                	add	a5,a5,a4
    80004560:	639c                	ld	a5,0(a5)
    80004562:	c78d                	beqz	a5,8000458c <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    80004564:	4505                	li	a0,1
    80004566:	9782                	jalr	a5
    80004568:	892a                	mv	s2,a0
    8000456a:	64e2                	ld	s1,24(sp)
    8000456c:	69a2                	ld	s3,8(sp)
    8000456e:	bf75                	j	8000452a <fileread+0x58>
    panic("fileread");
    80004570:	00003517          	auipc	a0,0x3
    80004574:	01850513          	addi	a0,a0,24 # 80007588 <etext+0x588>
    80004578:	aacfc0ef          	jal	80000824 <panic>
    return -1;
    8000457c:	57fd                	li	a5,-1
    8000457e:	893e                	mv	s2,a5
    80004580:	b76d                	j	8000452a <fileread+0x58>
      return -1;
    80004582:	57fd                	li	a5,-1
    80004584:	893e                	mv	s2,a5
    80004586:	64e2                	ld	s1,24(sp)
    80004588:	69a2                	ld	s3,8(sp)
    8000458a:	b745                	j	8000452a <fileread+0x58>
    8000458c:	57fd                	li	a5,-1
    8000458e:	893e                	mv	s2,a5
    80004590:	64e2                	ld	s1,24(sp)
    80004592:	69a2                	ld	s3,8(sp)
    80004594:	bf59                	j	8000452a <fileread+0x58>

0000000080004596 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004596:	00954783          	lbu	a5,9(a0)
    8000459a:	10078f63          	beqz	a5,800046b8 <filewrite+0x122>
{
    8000459e:	711d                	addi	sp,sp,-96
    800045a0:	ec86                	sd	ra,88(sp)
    800045a2:	e8a2                	sd	s0,80(sp)
    800045a4:	e0ca                	sd	s2,64(sp)
    800045a6:	f456                	sd	s5,40(sp)
    800045a8:	f05a                	sd	s6,32(sp)
    800045aa:	1080                	addi	s0,sp,96
    800045ac:	892a                	mv	s2,a0
    800045ae:	8b2e                	mv	s6,a1
    800045b0:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    800045b2:	411c                	lw	a5,0(a0)
    800045b4:	4705                	li	a4,1
    800045b6:	02e78a63          	beq	a5,a4,800045ea <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800045ba:	470d                	li	a4,3
    800045bc:	02e78b63          	beq	a5,a4,800045f2 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800045c0:	4709                	li	a4,2
    800045c2:	0ce79f63          	bne	a5,a4,800046a0 <filewrite+0x10a>
    800045c6:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800045c8:	0ac05a63          	blez	a2,8000467c <filewrite+0xe6>
    800045cc:	e4a6                	sd	s1,72(sp)
    800045ce:	fc4e                	sd	s3,56(sp)
    800045d0:	ec5e                	sd	s7,24(sp)
    800045d2:	e862                	sd	s8,16(sp)
    800045d4:	e466                	sd	s9,8(sp)
    int i = 0;
    800045d6:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    800045d8:	6b85                	lui	s7,0x1
    800045da:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800045de:	6785                	lui	a5,0x1
    800045e0:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800045e4:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800045e6:	4c05                	li	s8,1
    800045e8:	a8ad                	j	80004662 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800045ea:	6908                	ld	a0,16(a0)
    800045ec:	204000ef          	jal	800047f0 <pipewrite>
    800045f0:	a04d                	j	80004692 <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800045f2:	02451783          	lh	a5,36(a0)
    800045f6:	03079693          	slli	a3,a5,0x30
    800045fa:	92c1                	srli	a3,a3,0x30
    800045fc:	4725                	li	a4,9
    800045fe:	0ad76f63          	bltu	a4,a3,800046bc <filewrite+0x126>
    80004602:	0792                	slli	a5,a5,0x4
    80004604:	0005e717          	auipc	a4,0x5e
    80004608:	dfc70713          	addi	a4,a4,-516 # 80062400 <devsw>
    8000460c:	97ba                	add	a5,a5,a4
    8000460e:	679c                	ld	a5,8(a5)
    80004610:	cbc5                	beqz	a5,800046c0 <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    80004612:	4505                	li	a0,1
    80004614:	9782                	jalr	a5
    80004616:	a8b5                	j	80004692 <filewrite+0xfc>
      if(n1 > max)
    80004618:	2981                	sext.w	s3,s3
      begin_op();
    8000461a:	971ff0ef          	jal	80003f8a <begin_op>
      ilock(f->ip);
    8000461e:	01893503          	ld	a0,24(s2)
    80004622:	f5dfe0ef          	jal	8000357e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004626:	874e                	mv	a4,s3
    80004628:	02092683          	lw	a3,32(s2)
    8000462c:	016a0633          	add	a2,s4,s6
    80004630:	85e2                	mv	a1,s8
    80004632:	01893503          	ld	a0,24(s2)
    80004636:	bccff0ef          	jal	80003a02 <writei>
    8000463a:	84aa                	mv	s1,a0
    8000463c:	00a05763          	blez	a0,8000464a <filewrite+0xb4>
        f->off += r;
    80004640:	02092783          	lw	a5,32(s2)
    80004644:	9fa9                	addw	a5,a5,a0
    80004646:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000464a:	01893503          	ld	a0,24(s2)
    8000464e:	fdffe0ef          	jal	8000362c <iunlock>
      end_op();
    80004652:	9a9ff0ef          	jal	80003ffa <end_op>

      if(r != n1){
    80004656:	02999563          	bne	s3,s1,80004680 <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    8000465a:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    8000465e:	015a5963          	bge	s4,s5,80004670 <filewrite+0xda>
      int n1 = n - i;
    80004662:	414a87bb          	subw	a5,s5,s4
    80004666:	89be                	mv	s3,a5
      if(n1 > max)
    80004668:	fafbd8e3          	bge	s7,a5,80004618 <filewrite+0x82>
    8000466c:	89e6                	mv	s3,s9
    8000466e:	b76d                	j	80004618 <filewrite+0x82>
    80004670:	64a6                	ld	s1,72(sp)
    80004672:	79e2                	ld	s3,56(sp)
    80004674:	6be2                	ld	s7,24(sp)
    80004676:	6c42                	ld	s8,16(sp)
    80004678:	6ca2                	ld	s9,8(sp)
    8000467a:	a801                	j	8000468a <filewrite+0xf4>
    int i = 0;
    8000467c:	4a01                	li	s4,0
    8000467e:	a031                	j	8000468a <filewrite+0xf4>
    80004680:	64a6                	ld	s1,72(sp)
    80004682:	79e2                	ld	s3,56(sp)
    80004684:	6be2                	ld	s7,24(sp)
    80004686:	6c42                	ld	s8,16(sp)
    80004688:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    8000468a:	034a9d63          	bne	s5,s4,800046c4 <filewrite+0x12e>
    8000468e:	8556                	mv	a0,s5
    80004690:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004692:	60e6                	ld	ra,88(sp)
    80004694:	6446                	ld	s0,80(sp)
    80004696:	6906                	ld	s2,64(sp)
    80004698:	7aa2                	ld	s5,40(sp)
    8000469a:	7b02                	ld	s6,32(sp)
    8000469c:	6125                	addi	sp,sp,96
    8000469e:	8082                	ret
    800046a0:	e4a6                	sd	s1,72(sp)
    800046a2:	fc4e                	sd	s3,56(sp)
    800046a4:	f852                	sd	s4,48(sp)
    800046a6:	ec5e                	sd	s7,24(sp)
    800046a8:	e862                	sd	s8,16(sp)
    800046aa:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800046ac:	00003517          	auipc	a0,0x3
    800046b0:	eec50513          	addi	a0,a0,-276 # 80007598 <etext+0x598>
    800046b4:	970fc0ef          	jal	80000824 <panic>
    return -1;
    800046b8:	557d                	li	a0,-1
}
    800046ba:	8082                	ret
      return -1;
    800046bc:	557d                	li	a0,-1
    800046be:	bfd1                	j	80004692 <filewrite+0xfc>
    800046c0:	557d                	li	a0,-1
    800046c2:	bfc1                	j	80004692 <filewrite+0xfc>
    ret = (i == n ? n : -1);
    800046c4:	557d                	li	a0,-1
    800046c6:	7a42                	ld	s4,48(sp)
    800046c8:	b7e9                	j	80004692 <filewrite+0xfc>

00000000800046ca <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800046ca:	7179                	addi	sp,sp,-48
    800046cc:	f406                	sd	ra,40(sp)
    800046ce:	f022                	sd	s0,32(sp)
    800046d0:	ec26                	sd	s1,24(sp)
    800046d2:	e052                	sd	s4,0(sp)
    800046d4:	1800                	addi	s0,sp,48
    800046d6:	84aa                	mv	s1,a0
    800046d8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800046da:	0005b023          	sd	zero,0(a1)
    800046de:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800046e2:	c29ff0ef          	jal	8000430a <filealloc>
    800046e6:	e088                	sd	a0,0(s1)
    800046e8:	c549                	beqz	a0,80004772 <pipealloc+0xa8>
    800046ea:	c21ff0ef          	jal	8000430a <filealloc>
    800046ee:	00aa3023          	sd	a0,0(s4)
    800046f2:	cd25                	beqz	a0,8000476a <pipealloc+0xa0>
    800046f4:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800046f6:	c4efc0ef          	jal	80000b44 <kalloc>
    800046fa:	892a                	mv	s2,a0
    800046fc:	c12d                	beqz	a0,8000475e <pipealloc+0x94>
    800046fe:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004700:	4985                	li	s3,1
    80004702:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004706:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000470a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000470e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004712:	00003597          	auipc	a1,0x3
    80004716:	e9658593          	addi	a1,a1,-362 # 800075a8 <etext+0x5a8>
    8000471a:	c84fc0ef          	jal	80000b9e <initlock>
  (*f0)->type = FD_PIPE;
    8000471e:	609c                	ld	a5,0(s1)
    80004720:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004724:	609c                	ld	a5,0(s1)
    80004726:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000472a:	609c                	ld	a5,0(s1)
    8000472c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004730:	609c                	ld	a5,0(s1)
    80004732:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004736:	000a3783          	ld	a5,0(s4)
    8000473a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000473e:	000a3783          	ld	a5,0(s4)
    80004742:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004746:	000a3783          	ld	a5,0(s4)
    8000474a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000474e:	000a3783          	ld	a5,0(s4)
    80004752:	0127b823          	sd	s2,16(a5)
  return 0;
    80004756:	4501                	li	a0,0
    80004758:	6942                	ld	s2,16(sp)
    8000475a:	69a2                	ld	s3,8(sp)
    8000475c:	a01d                	j	80004782 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000475e:	6088                	ld	a0,0(s1)
    80004760:	c119                	beqz	a0,80004766 <pipealloc+0x9c>
    80004762:	6942                	ld	s2,16(sp)
    80004764:	a029                	j	8000476e <pipealloc+0xa4>
    80004766:	6942                	ld	s2,16(sp)
    80004768:	a029                	j	80004772 <pipealloc+0xa8>
    8000476a:	6088                	ld	a0,0(s1)
    8000476c:	c10d                	beqz	a0,8000478e <pipealloc+0xc4>
    fileclose(*f0);
    8000476e:	c41ff0ef          	jal	800043ae <fileclose>
  if(*f1)
    80004772:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004776:	557d                	li	a0,-1
  if(*f1)
    80004778:	c789                	beqz	a5,80004782 <pipealloc+0xb8>
    fileclose(*f1);
    8000477a:	853e                	mv	a0,a5
    8000477c:	c33ff0ef          	jal	800043ae <fileclose>
  return -1;
    80004780:	557d                	li	a0,-1
}
    80004782:	70a2                	ld	ra,40(sp)
    80004784:	7402                	ld	s0,32(sp)
    80004786:	64e2                	ld	s1,24(sp)
    80004788:	6a02                	ld	s4,0(sp)
    8000478a:	6145                	addi	sp,sp,48
    8000478c:	8082                	ret
  return -1;
    8000478e:	557d                	li	a0,-1
    80004790:	bfcd                	j	80004782 <pipealloc+0xb8>

0000000080004792 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004792:	1101                	addi	sp,sp,-32
    80004794:	ec06                	sd	ra,24(sp)
    80004796:	e822                	sd	s0,16(sp)
    80004798:	e426                	sd	s1,8(sp)
    8000479a:	e04a                	sd	s2,0(sp)
    8000479c:	1000                	addi	s0,sp,32
    8000479e:	84aa                	mv	s1,a0
    800047a0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800047a2:	c86fc0ef          	jal	80000c28 <acquire>
  if(writable){
    800047a6:	02090763          	beqz	s2,800047d4 <pipeclose+0x42>
    pi->writeopen = 0;
    800047aa:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800047ae:	21848513          	addi	a0,s1,536
    800047b2:	80ffd0ef          	jal	80001fc0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800047b6:	2204a783          	lw	a5,544(s1)
    800047ba:	e781                	bnez	a5,800047c2 <pipeclose+0x30>
    800047bc:	2244a783          	lw	a5,548(s1)
    800047c0:	c38d                	beqz	a5,800047e2 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    800047c2:	8526                	mv	a0,s1
    800047c4:	cf8fc0ef          	jal	80000cbc <release>
}
    800047c8:	60e2                	ld	ra,24(sp)
    800047ca:	6442                	ld	s0,16(sp)
    800047cc:	64a2                	ld	s1,8(sp)
    800047ce:	6902                	ld	s2,0(sp)
    800047d0:	6105                	addi	sp,sp,32
    800047d2:	8082                	ret
    pi->readopen = 0;
    800047d4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800047d8:	21c48513          	addi	a0,s1,540
    800047dc:	fe4fd0ef          	jal	80001fc0 <wakeup>
    800047e0:	bfd9                	j	800047b6 <pipeclose+0x24>
    release(&pi->lock);
    800047e2:	8526                	mv	a0,s1
    800047e4:	cd8fc0ef          	jal	80000cbc <release>
    kfree((char*)pi);
    800047e8:	8526                	mv	a0,s1
    800047ea:	a72fc0ef          	jal	80000a5c <kfree>
    800047ee:	bfe9                	j	800047c8 <pipeclose+0x36>

00000000800047f0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800047f0:	7159                	addi	sp,sp,-112
    800047f2:	f486                	sd	ra,104(sp)
    800047f4:	f0a2                	sd	s0,96(sp)
    800047f6:	eca6                	sd	s1,88(sp)
    800047f8:	e8ca                	sd	s2,80(sp)
    800047fa:	e4ce                	sd	s3,72(sp)
    800047fc:	e0d2                	sd	s4,64(sp)
    800047fe:	fc56                	sd	s5,56(sp)
    80004800:	1880                	addi	s0,sp,112
    80004802:	84aa                	mv	s1,a0
    80004804:	8aae                	mv	s5,a1
    80004806:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004808:	92cfd0ef          	jal	80001934 <myproc>
    8000480c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000480e:	8526                	mv	a0,s1
    80004810:	c18fc0ef          	jal	80000c28 <acquire>
  while(i < n){
    80004814:	0d405263          	blez	s4,800048d8 <pipewrite+0xe8>
    80004818:	f85a                	sd	s6,48(sp)
    8000481a:	f45e                	sd	s7,40(sp)
    8000481c:	f062                	sd	s8,32(sp)
    8000481e:	ec66                	sd	s9,24(sp)
    80004820:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004822:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004824:	f9f40c13          	addi	s8,s0,-97
    80004828:	4b85                	li	s7,1
    8000482a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000482c:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004830:	21c48c93          	addi	s9,s1,540
    80004834:	a82d                	j	8000486e <pipewrite+0x7e>
      release(&pi->lock);
    80004836:	8526                	mv	a0,s1
    80004838:	c84fc0ef          	jal	80000cbc <release>
      return -1;
    8000483c:	597d                	li	s2,-1
    8000483e:	7b42                	ld	s6,48(sp)
    80004840:	7ba2                	ld	s7,40(sp)
    80004842:	7c02                	ld	s8,32(sp)
    80004844:	6ce2                	ld	s9,24(sp)
    80004846:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004848:	854a                	mv	a0,s2
    8000484a:	70a6                	ld	ra,104(sp)
    8000484c:	7406                	ld	s0,96(sp)
    8000484e:	64e6                	ld	s1,88(sp)
    80004850:	6946                	ld	s2,80(sp)
    80004852:	69a6                	ld	s3,72(sp)
    80004854:	6a06                	ld	s4,64(sp)
    80004856:	7ae2                	ld	s5,56(sp)
    80004858:	6165                	addi	sp,sp,112
    8000485a:	8082                	ret
      wakeup(&pi->nread);
    8000485c:	856a                	mv	a0,s10
    8000485e:	f62fd0ef          	jal	80001fc0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004862:	85a6                	mv	a1,s1
    80004864:	8566                	mv	a0,s9
    80004866:	f0efd0ef          	jal	80001f74 <sleep>
  while(i < n){
    8000486a:	05495a63          	bge	s2,s4,800048be <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    8000486e:	2204a783          	lw	a5,544(s1)
    80004872:	d3f1                	beqz	a5,80004836 <pipewrite+0x46>
    80004874:	854e                	mv	a0,s3
    80004876:	953fd0ef          	jal	800021c8 <killed>
    8000487a:	fd55                	bnez	a0,80004836 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000487c:	2184a783          	lw	a5,536(s1)
    80004880:	21c4a703          	lw	a4,540(s1)
    80004884:	2007879b          	addiw	a5,a5,512
    80004888:	fcf70ae3          	beq	a4,a5,8000485c <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000488c:	86de                	mv	a3,s7
    8000488e:	01590633          	add	a2,s2,s5
    80004892:	85e2                	mv	a1,s8
    80004894:	0509b503          	ld	a0,80(s3)
    80004898:	e7bfc0ef          	jal	80001712 <copyin>
    8000489c:	05650063          	beq	a0,s6,800048dc <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800048a0:	21c4a783          	lw	a5,540(s1)
    800048a4:	0017871b          	addiw	a4,a5,1
    800048a8:	20e4ae23          	sw	a4,540(s1)
    800048ac:	1ff7f793          	andi	a5,a5,511
    800048b0:	97a6                	add	a5,a5,s1
    800048b2:	f9f44703          	lbu	a4,-97(s0)
    800048b6:	00e78c23          	sb	a4,24(a5)
      i++;
    800048ba:	2905                	addiw	s2,s2,1
    800048bc:	b77d                	j	8000486a <pipewrite+0x7a>
    800048be:	7b42                	ld	s6,48(sp)
    800048c0:	7ba2                	ld	s7,40(sp)
    800048c2:	7c02                	ld	s8,32(sp)
    800048c4:	6ce2                	ld	s9,24(sp)
    800048c6:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800048c8:	21848513          	addi	a0,s1,536
    800048cc:	ef4fd0ef          	jal	80001fc0 <wakeup>
  release(&pi->lock);
    800048d0:	8526                	mv	a0,s1
    800048d2:	beafc0ef          	jal	80000cbc <release>
  return i;
    800048d6:	bf8d                	j	80004848 <pipewrite+0x58>
  int i = 0;
    800048d8:	4901                	li	s2,0
    800048da:	b7fd                	j	800048c8 <pipewrite+0xd8>
    800048dc:	7b42                	ld	s6,48(sp)
    800048de:	7ba2                	ld	s7,40(sp)
    800048e0:	7c02                	ld	s8,32(sp)
    800048e2:	6ce2                	ld	s9,24(sp)
    800048e4:	6d42                	ld	s10,16(sp)
    800048e6:	b7cd                	j	800048c8 <pipewrite+0xd8>

00000000800048e8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800048e8:	711d                	addi	sp,sp,-96
    800048ea:	ec86                	sd	ra,88(sp)
    800048ec:	e8a2                	sd	s0,80(sp)
    800048ee:	e4a6                	sd	s1,72(sp)
    800048f0:	e0ca                	sd	s2,64(sp)
    800048f2:	fc4e                	sd	s3,56(sp)
    800048f4:	f852                	sd	s4,48(sp)
    800048f6:	f456                	sd	s5,40(sp)
    800048f8:	1080                	addi	s0,sp,96
    800048fa:	84aa                	mv	s1,a0
    800048fc:	892e                	mv	s2,a1
    800048fe:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004900:	834fd0ef          	jal	80001934 <myproc>
    80004904:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004906:	8526                	mv	a0,s1
    80004908:	b20fc0ef          	jal	80000c28 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000490c:	2184a703          	lw	a4,536(s1)
    80004910:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004914:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004918:	02f71763          	bne	a4,a5,80004946 <piperead+0x5e>
    8000491c:	2244a783          	lw	a5,548(s1)
    80004920:	cf85                	beqz	a5,80004958 <piperead+0x70>
    if(killed(pr)){
    80004922:	8552                	mv	a0,s4
    80004924:	8a5fd0ef          	jal	800021c8 <killed>
    80004928:	e11d                	bnez	a0,8000494e <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000492a:	85a6                	mv	a1,s1
    8000492c:	854e                	mv	a0,s3
    8000492e:	e46fd0ef          	jal	80001f74 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004932:	2184a703          	lw	a4,536(s1)
    80004936:	21c4a783          	lw	a5,540(s1)
    8000493a:	fef701e3          	beq	a4,a5,8000491c <piperead+0x34>
    8000493e:	f05a                	sd	s6,32(sp)
    80004940:	ec5e                	sd	s7,24(sp)
    80004942:	e862                	sd	s8,16(sp)
    80004944:	a829                	j	8000495e <piperead+0x76>
    80004946:	f05a                	sd	s6,32(sp)
    80004948:	ec5e                	sd	s7,24(sp)
    8000494a:	e862                	sd	s8,16(sp)
    8000494c:	a809                	j	8000495e <piperead+0x76>
      release(&pi->lock);
    8000494e:	8526                	mv	a0,s1
    80004950:	b6cfc0ef          	jal	80000cbc <release>
      return -1;
    80004954:	59fd                	li	s3,-1
    80004956:	a0a5                	j	800049be <piperead+0xd6>
    80004958:	f05a                	sd	s6,32(sp)
    8000495a:	ec5e                	sd	s7,24(sp)
    8000495c:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000495e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004960:	faf40c13          	addi	s8,s0,-81
    80004964:	4b85                	li	s7,1
    80004966:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004968:	05505163          	blez	s5,800049aa <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    8000496c:	2184a783          	lw	a5,536(s1)
    80004970:	21c4a703          	lw	a4,540(s1)
    80004974:	02f70b63          	beq	a4,a5,800049aa <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004978:	1ff7f793          	andi	a5,a5,511
    8000497c:	97a6                	add	a5,a5,s1
    8000497e:	0187c783          	lbu	a5,24(a5)
    80004982:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004986:	86de                	mv	a3,s7
    80004988:	8662                	mv	a2,s8
    8000498a:	85ca                	mv	a1,s2
    8000498c:	050a3503          	ld	a0,80(s4)
    80004990:	cc5fc0ef          	jal	80001654 <copyout>
    80004994:	03650f63          	beq	a0,s6,800049d2 <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004998:	2184a783          	lw	a5,536(s1)
    8000499c:	2785                	addiw	a5,a5,1
    8000499e:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800049a2:	2985                	addiw	s3,s3,1
    800049a4:	0905                	addi	s2,s2,1
    800049a6:	fd3a93e3          	bne	s5,s3,8000496c <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800049aa:	21c48513          	addi	a0,s1,540
    800049ae:	e12fd0ef          	jal	80001fc0 <wakeup>
  release(&pi->lock);
    800049b2:	8526                	mv	a0,s1
    800049b4:	b08fc0ef          	jal	80000cbc <release>
    800049b8:	7b02                	ld	s6,32(sp)
    800049ba:	6be2                	ld	s7,24(sp)
    800049bc:	6c42                	ld	s8,16(sp)
  return i;
}
    800049be:	854e                	mv	a0,s3
    800049c0:	60e6                	ld	ra,88(sp)
    800049c2:	6446                	ld	s0,80(sp)
    800049c4:	64a6                	ld	s1,72(sp)
    800049c6:	6906                	ld	s2,64(sp)
    800049c8:	79e2                	ld	s3,56(sp)
    800049ca:	7a42                	ld	s4,48(sp)
    800049cc:	7aa2                	ld	s5,40(sp)
    800049ce:	6125                	addi	sp,sp,96
    800049d0:	8082                	ret
      if(i == 0)
    800049d2:	fc099ce3          	bnez	s3,800049aa <piperead+0xc2>
        i = -1;
    800049d6:	89aa                	mv	s3,a0
    800049d8:	bfc9                	j	800049aa <piperead+0xc2>

00000000800049da <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800049da:	1141                	addi	sp,sp,-16
    800049dc:	e406                	sd	ra,8(sp)
    800049de:	e022                	sd	s0,0(sp)
    800049e0:	0800                	addi	s0,sp,16
    800049e2:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800049e4:	0035151b          	slliw	a0,a0,0x3
    800049e8:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    800049ea:	8b89                	andi	a5,a5,2
    800049ec:	c399                	beqz	a5,800049f2 <flags2perm+0x18>
      perm |= PTE_W;
    800049ee:	00456513          	ori	a0,a0,4
    return perm;
}
    800049f2:	60a2                	ld	ra,8(sp)
    800049f4:	6402                	ld	s0,0(sp)
    800049f6:	0141                	addi	sp,sp,16
    800049f8:	8082                	ret

00000000800049fa <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800049fa:	de010113          	addi	sp,sp,-544
    800049fe:	20113c23          	sd	ra,536(sp)
    80004a02:	20813823          	sd	s0,528(sp)
    80004a06:	20913423          	sd	s1,520(sp)
    80004a0a:	21213023          	sd	s2,512(sp)
    80004a0e:	1400                	addi	s0,sp,544
    80004a10:	892a                	mv	s2,a0
    80004a12:	dea43823          	sd	a0,-528(s0)
    80004a16:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004a1a:	f1bfc0ef          	jal	80001934 <myproc>
    80004a1e:	84aa                	mv	s1,a0

  begin_op();
    80004a20:	d6aff0ef          	jal	80003f8a <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004a24:	854a                	mv	a0,s2
    80004a26:	b86ff0ef          	jal	80003dac <namei>
    80004a2a:	cd21                	beqz	a0,80004a82 <kexec+0x88>
    80004a2c:	fbd2                	sd	s4,496(sp)
    80004a2e:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004a30:	b4ffe0ef          	jal	8000357e <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004a34:	04000713          	li	a4,64
    80004a38:	4681                	li	a3,0
    80004a3a:	e5040613          	addi	a2,s0,-432
    80004a3e:	4581                	li	a1,0
    80004a40:	8552                	mv	a0,s4
    80004a42:	ecffe0ef          	jal	80003910 <readi>
    80004a46:	04000793          	li	a5,64
    80004a4a:	00f51a63          	bne	a0,a5,80004a5e <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004a4e:	e5042703          	lw	a4,-432(s0)
    80004a52:	464c47b7          	lui	a5,0x464c4
    80004a56:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004a5a:	02f70863          	beq	a4,a5,80004a8a <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004a5e:	8552                	mv	a0,s4
    80004a60:	d2bfe0ef          	jal	8000378a <iunlockput>
    end_op();
    80004a64:	d96ff0ef          	jal	80003ffa <end_op>
  }
  return -1;
    80004a68:	557d                	li	a0,-1
    80004a6a:	7a5e                	ld	s4,496(sp)
}
    80004a6c:	21813083          	ld	ra,536(sp)
    80004a70:	21013403          	ld	s0,528(sp)
    80004a74:	20813483          	ld	s1,520(sp)
    80004a78:	20013903          	ld	s2,512(sp)
    80004a7c:	22010113          	addi	sp,sp,544
    80004a80:	8082                	ret
    end_op();
    80004a82:	d78ff0ef          	jal	80003ffa <end_op>
    return -1;
    80004a86:	557d                	li	a0,-1
    80004a88:	b7d5                	j	80004a6c <kexec+0x72>
    80004a8a:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004a8c:	8526                	mv	a0,s1
    80004a8e:	fb1fc0ef          	jal	80001a3e <proc_pagetable>
    80004a92:	8b2a                	mv	s6,a0
    80004a94:	26050f63          	beqz	a0,80004d12 <kexec+0x318>
    80004a98:	ffce                	sd	s3,504(sp)
    80004a9a:	f7d6                	sd	s5,488(sp)
    80004a9c:	efde                	sd	s7,472(sp)
    80004a9e:	ebe2                	sd	s8,464(sp)
    80004aa0:	e7e6                	sd	s9,456(sp)
    80004aa2:	e3ea                	sd	s10,448(sp)
    80004aa4:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004aa6:	e8845783          	lhu	a5,-376(s0)
    80004aaa:	0e078963          	beqz	a5,80004b9c <kexec+0x1a2>
    80004aae:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ab2:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ab4:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ab6:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004aba:	6c85                	lui	s9,0x1
    80004abc:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004ac0:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004ac4:	6a85                	lui	s5,0x1
    80004ac6:	a085                	j	80004b26 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004ac8:	00003517          	auipc	a0,0x3
    80004acc:	ae850513          	addi	a0,a0,-1304 # 800075b0 <etext+0x5b0>
    80004ad0:	d55fb0ef          	jal	80000824 <panic>
    if(sz - i < PGSIZE)
    80004ad4:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004ad6:	874a                	mv	a4,s2
    80004ad8:	009b86bb          	addw	a3,s7,s1
    80004adc:	4581                	li	a1,0
    80004ade:	8552                	mv	a0,s4
    80004ae0:	e31fe0ef          	jal	80003910 <readi>
    80004ae4:	22a91b63          	bne	s2,a0,80004d1a <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    80004ae8:	009a84bb          	addw	s1,s5,s1
    80004aec:	0334f263          	bgeu	s1,s3,80004b10 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004af0:	02049593          	slli	a1,s1,0x20
    80004af4:	9181                	srli	a1,a1,0x20
    80004af6:	95e2                	add	a1,a1,s8
    80004af8:	855a                	mv	a0,s6
    80004afa:	d2cfc0ef          	jal	80001026 <walkaddr>
    80004afe:	862a                	mv	a2,a0
    if(pa == 0)
    80004b00:	d561                	beqz	a0,80004ac8 <kexec+0xce>
    if(sz - i < PGSIZE)
    80004b02:	409987bb          	subw	a5,s3,s1
    80004b06:	893e                	mv	s2,a5
    80004b08:	fcfcf6e3          	bgeu	s9,a5,80004ad4 <kexec+0xda>
    80004b0c:	8956                	mv	s2,s5
    80004b0e:	b7d9                	j	80004ad4 <kexec+0xda>
    sz = sz1;
    80004b10:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004b14:	2d05                	addiw	s10,s10,1
    80004b16:	e0843783          	ld	a5,-504(s0)
    80004b1a:	0387869b          	addiw	a3,a5,56
    80004b1e:	e8845783          	lhu	a5,-376(s0)
    80004b22:	06fd5e63          	bge	s10,a5,80004b9e <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004b26:	e0d43423          	sd	a3,-504(s0)
    80004b2a:	876e                	mv	a4,s11
    80004b2c:	e1840613          	addi	a2,s0,-488
    80004b30:	4581                	li	a1,0
    80004b32:	8552                	mv	a0,s4
    80004b34:	dddfe0ef          	jal	80003910 <readi>
    80004b38:	1db51f63          	bne	a0,s11,80004d16 <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    80004b3c:	e1842783          	lw	a5,-488(s0)
    80004b40:	4705                	li	a4,1
    80004b42:	fce799e3          	bne	a5,a4,80004b14 <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    80004b46:	e4043483          	ld	s1,-448(s0)
    80004b4a:	e3843783          	ld	a5,-456(s0)
    80004b4e:	1ef4e463          	bltu	s1,a5,80004d36 <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004b52:	e2843783          	ld	a5,-472(s0)
    80004b56:	94be                	add	s1,s1,a5
    80004b58:	1ef4e263          	bltu	s1,a5,80004d3c <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    80004b5c:	de843703          	ld	a4,-536(s0)
    80004b60:	8ff9                	and	a5,a5,a4
    80004b62:	1e079063          	bnez	a5,80004d42 <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004b66:	e1c42503          	lw	a0,-484(s0)
    80004b6a:	e71ff0ef          	jal	800049da <flags2perm>
    80004b6e:	86aa                	mv	a3,a0
    80004b70:	8626                	mv	a2,s1
    80004b72:	85ca                	mv	a1,s2
    80004b74:	855a                	mv	a0,s6
    80004b76:	f86fc0ef          	jal	800012fc <uvmalloc>
    80004b7a:	dea43c23          	sd	a0,-520(s0)
    80004b7e:	1c050563          	beqz	a0,80004d48 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004b82:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004b86:	00098863          	beqz	s3,80004b96 <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004b8a:	e2843c03          	ld	s8,-472(s0)
    80004b8e:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004b92:	4481                	li	s1,0
    80004b94:	bfb1                	j	80004af0 <kexec+0xf6>
    sz = sz1;
    80004b96:	df843903          	ld	s2,-520(s0)
    80004b9a:	bfad                	j	80004b14 <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004b9c:	4901                	li	s2,0
  iunlockput(ip);
    80004b9e:	8552                	mv	a0,s4
    80004ba0:	bebfe0ef          	jal	8000378a <iunlockput>
  end_op();
    80004ba4:	c56ff0ef          	jal	80003ffa <end_op>
  p = myproc();
    80004ba8:	d8dfc0ef          	jal	80001934 <myproc>
    80004bac:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004bae:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004bb2:	6985                	lui	s3,0x1
    80004bb4:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004bb6:	99ca                	add	s3,s3,s2
    80004bb8:	77fd                	lui	a5,0xfffff
    80004bba:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004bbe:	4691                	li	a3,4
    80004bc0:	6609                	lui	a2,0x2
    80004bc2:	964e                	add	a2,a2,s3
    80004bc4:	85ce                	mv	a1,s3
    80004bc6:	855a                	mv	a0,s6
    80004bc8:	f34fc0ef          	jal	800012fc <uvmalloc>
    80004bcc:	8a2a                	mv	s4,a0
    80004bce:	e105                	bnez	a0,80004bee <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004bd0:	85ce                	mv	a1,s3
    80004bd2:	855a                	mv	a0,s6
    80004bd4:	eeffc0ef          	jal	80001ac2 <proc_freepagetable>
  return -1;
    80004bd8:	557d                	li	a0,-1
    80004bda:	79fe                	ld	s3,504(sp)
    80004bdc:	7a5e                	ld	s4,496(sp)
    80004bde:	7abe                	ld	s5,488(sp)
    80004be0:	7b1e                	ld	s6,480(sp)
    80004be2:	6bfe                	ld	s7,472(sp)
    80004be4:	6c5e                	ld	s8,464(sp)
    80004be6:	6cbe                	ld	s9,456(sp)
    80004be8:	6d1e                	ld	s10,448(sp)
    80004bea:	7dfa                	ld	s11,440(sp)
    80004bec:	b541                	j	80004a6c <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004bee:	75f9                	lui	a1,0xffffe
    80004bf0:	95aa                	add	a1,a1,a0
    80004bf2:	855a                	mv	a0,s6
    80004bf4:	8dbfc0ef          	jal	800014ce <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004bf8:	800a0b93          	addi	s7,s4,-2048
    80004bfc:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80004c00:	e0043783          	ld	a5,-512(s0)
    80004c04:	6388                	ld	a0,0(a5)
  sp = sz;
    80004c06:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004c08:	4481                	li	s1,0
    ustack[argc] = sp;
    80004c0a:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004c0e:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004c12:	cd21                	beqz	a0,80004c6a <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004c14:	a6efc0ef          	jal	80000e82 <strlen>
    80004c18:	0015079b          	addiw	a5,a0,1
    80004c1c:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004c20:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004c24:	13796563          	bltu	s2,s7,80004d4e <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004c28:	e0043d83          	ld	s11,-512(s0)
    80004c2c:	000db983          	ld	s3,0(s11)
    80004c30:	854e                	mv	a0,s3
    80004c32:	a50fc0ef          	jal	80000e82 <strlen>
    80004c36:	0015069b          	addiw	a3,a0,1
    80004c3a:	864e                	mv	a2,s3
    80004c3c:	85ca                	mv	a1,s2
    80004c3e:	855a                	mv	a0,s6
    80004c40:	a15fc0ef          	jal	80001654 <copyout>
    80004c44:	10054763          	bltz	a0,80004d52 <kexec+0x358>
    ustack[argc] = sp;
    80004c48:	00349793          	slli	a5,s1,0x3
    80004c4c:	97e6                	add	a5,a5,s9
    80004c4e:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ff9ba68>
  for(argc = 0; argv[argc]; argc++) {
    80004c52:	0485                	addi	s1,s1,1
    80004c54:	008d8793          	addi	a5,s11,8
    80004c58:	e0f43023          	sd	a5,-512(s0)
    80004c5c:	008db503          	ld	a0,8(s11)
    80004c60:	c509                	beqz	a0,80004c6a <kexec+0x270>
    if(argc >= MAXARG)
    80004c62:	fb8499e3          	bne	s1,s8,80004c14 <kexec+0x21a>
  sz = sz1;
    80004c66:	89d2                	mv	s3,s4
    80004c68:	b7a5                	j	80004bd0 <kexec+0x1d6>
  ustack[argc] = 0;
    80004c6a:	00349793          	slli	a5,s1,0x3
    80004c6e:	f9078793          	addi	a5,a5,-112
    80004c72:	97a2                	add	a5,a5,s0
    80004c74:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004c78:	00349693          	slli	a3,s1,0x3
    80004c7c:	06a1                	addi	a3,a3,8
    80004c7e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004c82:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004c86:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004c88:	f57964e3          	bltu	s2,s7,80004bd0 <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004c8c:	e9040613          	addi	a2,s0,-368
    80004c90:	85ca                	mv	a1,s2
    80004c92:	855a                	mv	a0,s6
    80004c94:	9c1fc0ef          	jal	80001654 <copyout>
    80004c98:	f2054ce3          	bltz	a0,80004bd0 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004c9c:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004ca0:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004ca4:	df043783          	ld	a5,-528(s0)
    80004ca8:	0007c703          	lbu	a4,0(a5)
    80004cac:	cf11                	beqz	a4,80004cc8 <kexec+0x2ce>
    80004cae:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004cb0:	02f00693          	li	a3,47
    80004cb4:	a029                	j	80004cbe <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80004cb6:	0785                	addi	a5,a5,1
    80004cb8:	fff7c703          	lbu	a4,-1(a5)
    80004cbc:	c711                	beqz	a4,80004cc8 <kexec+0x2ce>
    if(*s == '/')
    80004cbe:	fed71ce3          	bne	a4,a3,80004cb6 <kexec+0x2bc>
      last = s+1;
    80004cc2:	def43823          	sd	a5,-528(s0)
    80004cc6:	bfc5                	j	80004cb6 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004cc8:	4641                	li	a2,16
    80004cca:	df043583          	ld	a1,-528(s0)
    80004cce:	158a8513          	addi	a0,s5,344
    80004cd2:	97afc0ef          	jal	80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    80004cd6:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004cda:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004cde:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004ce2:	058ab783          	ld	a5,88(s5)
    80004ce6:	e6843703          	ld	a4,-408(s0)
    80004cea:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004cec:	058ab783          	ld	a5,88(s5)
    80004cf0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004cf4:	85ea                	mv	a1,s10
    80004cf6:	dcdfc0ef          	jal	80001ac2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004cfa:	0004851b          	sext.w	a0,s1
    80004cfe:	79fe                	ld	s3,504(sp)
    80004d00:	7a5e                	ld	s4,496(sp)
    80004d02:	7abe                	ld	s5,488(sp)
    80004d04:	7b1e                	ld	s6,480(sp)
    80004d06:	6bfe                	ld	s7,472(sp)
    80004d08:	6c5e                	ld	s8,464(sp)
    80004d0a:	6cbe                	ld	s9,456(sp)
    80004d0c:	6d1e                	ld	s10,448(sp)
    80004d0e:	7dfa                	ld	s11,440(sp)
    80004d10:	bbb1                	j	80004a6c <kexec+0x72>
    80004d12:	7b1e                	ld	s6,480(sp)
    80004d14:	b3a9                	j	80004a5e <kexec+0x64>
    80004d16:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004d1a:	df843583          	ld	a1,-520(s0)
    80004d1e:	855a                	mv	a0,s6
    80004d20:	da3fc0ef          	jal	80001ac2 <proc_freepagetable>
  if(ip){
    80004d24:	79fe                	ld	s3,504(sp)
    80004d26:	7abe                	ld	s5,488(sp)
    80004d28:	7b1e                	ld	s6,480(sp)
    80004d2a:	6bfe                	ld	s7,472(sp)
    80004d2c:	6c5e                	ld	s8,464(sp)
    80004d2e:	6cbe                	ld	s9,456(sp)
    80004d30:	6d1e                	ld	s10,448(sp)
    80004d32:	7dfa                	ld	s11,440(sp)
    80004d34:	b32d                	j	80004a5e <kexec+0x64>
    80004d36:	df243c23          	sd	s2,-520(s0)
    80004d3a:	b7c5                	j	80004d1a <kexec+0x320>
    80004d3c:	df243c23          	sd	s2,-520(s0)
    80004d40:	bfe9                	j	80004d1a <kexec+0x320>
    80004d42:	df243c23          	sd	s2,-520(s0)
    80004d46:	bfd1                	j	80004d1a <kexec+0x320>
    80004d48:	df243c23          	sd	s2,-520(s0)
    80004d4c:	b7f9                	j	80004d1a <kexec+0x320>
  sz = sz1;
    80004d4e:	89d2                	mv	s3,s4
    80004d50:	b541                	j	80004bd0 <kexec+0x1d6>
    80004d52:	89d2                	mv	s3,s4
    80004d54:	bdb5                	j	80004bd0 <kexec+0x1d6>

0000000080004d56 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004d56:	7179                	addi	sp,sp,-48
    80004d58:	f406                	sd	ra,40(sp)
    80004d5a:	f022                	sd	s0,32(sp)
    80004d5c:	ec26                	sd	s1,24(sp)
    80004d5e:	e84a                	sd	s2,16(sp)
    80004d60:	1800                	addi	s0,sp,48
    80004d62:	892e                	mv	s2,a1
    80004d64:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004d66:	fdc40593          	addi	a1,s0,-36
    80004d6a:	b39fd0ef          	jal	800028a2 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004d6e:	fdc42703          	lw	a4,-36(s0)
    80004d72:	47bd                	li	a5,15
    80004d74:	02e7ea63          	bltu	a5,a4,80004da8 <argfd+0x52>
    80004d78:	bbdfc0ef          	jal	80001934 <myproc>
    80004d7c:	fdc42703          	lw	a4,-36(s0)
    80004d80:	00371793          	slli	a5,a4,0x3
    80004d84:	0d078793          	addi	a5,a5,208
    80004d88:	953e                	add	a0,a0,a5
    80004d8a:	611c                	ld	a5,0(a0)
    80004d8c:	c385                	beqz	a5,80004dac <argfd+0x56>
    return -1;
  if(pfd)
    80004d8e:	00090463          	beqz	s2,80004d96 <argfd+0x40>
    *pfd = fd;
    80004d92:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004d96:	4501                	li	a0,0
  if(pf)
    80004d98:	c091                	beqz	s1,80004d9c <argfd+0x46>
    *pf = f;
    80004d9a:	e09c                	sd	a5,0(s1)
}
    80004d9c:	70a2                	ld	ra,40(sp)
    80004d9e:	7402                	ld	s0,32(sp)
    80004da0:	64e2                	ld	s1,24(sp)
    80004da2:	6942                	ld	s2,16(sp)
    80004da4:	6145                	addi	sp,sp,48
    80004da6:	8082                	ret
    return -1;
    80004da8:	557d                	li	a0,-1
    80004daa:	bfcd                	j	80004d9c <argfd+0x46>
    80004dac:	557d                	li	a0,-1
    80004dae:	b7fd                	j	80004d9c <argfd+0x46>

0000000080004db0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004db0:	1101                	addi	sp,sp,-32
    80004db2:	ec06                	sd	ra,24(sp)
    80004db4:	e822                	sd	s0,16(sp)
    80004db6:	e426                	sd	s1,8(sp)
    80004db8:	1000                	addi	s0,sp,32
    80004dba:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004dbc:	b79fc0ef          	jal	80001934 <myproc>
    80004dc0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004dc2:	0d050793          	addi	a5,a0,208
    80004dc6:	4501                	li	a0,0
    80004dc8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004dca:	6398                	ld	a4,0(a5)
    80004dcc:	cb19                	beqz	a4,80004de2 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004dce:	2505                	addiw	a0,a0,1
    80004dd0:	07a1                	addi	a5,a5,8
    80004dd2:	fed51ce3          	bne	a0,a3,80004dca <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004dd6:	557d                	li	a0,-1
}
    80004dd8:	60e2                	ld	ra,24(sp)
    80004dda:	6442                	ld	s0,16(sp)
    80004ddc:	64a2                	ld	s1,8(sp)
    80004dde:	6105                	addi	sp,sp,32
    80004de0:	8082                	ret
      p->ofile[fd] = f;
    80004de2:	00351793          	slli	a5,a0,0x3
    80004de6:	0d078793          	addi	a5,a5,208
    80004dea:	963e                	add	a2,a2,a5
    80004dec:	e204                	sd	s1,0(a2)
      return fd;
    80004dee:	b7ed                	j	80004dd8 <fdalloc+0x28>

0000000080004df0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004df0:	715d                	addi	sp,sp,-80
    80004df2:	e486                	sd	ra,72(sp)
    80004df4:	e0a2                	sd	s0,64(sp)
    80004df6:	fc26                	sd	s1,56(sp)
    80004df8:	f84a                	sd	s2,48(sp)
    80004dfa:	f44e                	sd	s3,40(sp)
    80004dfc:	f052                	sd	s4,32(sp)
    80004dfe:	ec56                	sd	s5,24(sp)
    80004e00:	e85a                	sd	s6,16(sp)
    80004e02:	0880                	addi	s0,sp,80
    80004e04:	892e                	mv	s2,a1
    80004e06:	8a2e                	mv	s4,a1
    80004e08:	8ab2                	mv	s5,a2
    80004e0a:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004e0c:	fb040593          	addi	a1,s0,-80
    80004e10:	fb7fe0ef          	jal	80003dc6 <nameiparent>
    80004e14:	84aa                	mv	s1,a0
    80004e16:	10050763          	beqz	a0,80004f24 <create+0x134>
    return 0;

  ilock(dp);
    80004e1a:	f64fe0ef          	jal	8000357e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004e1e:	4601                	li	a2,0
    80004e20:	fb040593          	addi	a1,s0,-80
    80004e24:	8526                	mv	a0,s1
    80004e26:	cf3fe0ef          	jal	80003b18 <dirlookup>
    80004e2a:	89aa                	mv	s3,a0
    80004e2c:	c131                	beqz	a0,80004e70 <create+0x80>
    iunlockput(dp);
    80004e2e:	8526                	mv	a0,s1
    80004e30:	95bfe0ef          	jal	8000378a <iunlockput>
    ilock(ip);
    80004e34:	854e                	mv	a0,s3
    80004e36:	f48fe0ef          	jal	8000357e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004e3a:	4789                	li	a5,2
    80004e3c:	02f91563          	bne	s2,a5,80004e66 <create+0x76>
    80004e40:	0449d783          	lhu	a5,68(s3)
    80004e44:	37f9                	addiw	a5,a5,-2
    80004e46:	17c2                	slli	a5,a5,0x30
    80004e48:	93c1                	srli	a5,a5,0x30
    80004e4a:	4705                	li	a4,1
    80004e4c:	00f76d63          	bltu	a4,a5,80004e66 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004e50:	854e                	mv	a0,s3
    80004e52:	60a6                	ld	ra,72(sp)
    80004e54:	6406                	ld	s0,64(sp)
    80004e56:	74e2                	ld	s1,56(sp)
    80004e58:	7942                	ld	s2,48(sp)
    80004e5a:	79a2                	ld	s3,40(sp)
    80004e5c:	7a02                	ld	s4,32(sp)
    80004e5e:	6ae2                	ld	s5,24(sp)
    80004e60:	6b42                	ld	s6,16(sp)
    80004e62:	6161                	addi	sp,sp,80
    80004e64:	8082                	ret
    iunlockput(ip);
    80004e66:	854e                	mv	a0,s3
    80004e68:	923fe0ef          	jal	8000378a <iunlockput>
    return 0;
    80004e6c:	4981                	li	s3,0
    80004e6e:	b7cd                	j	80004e50 <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004e70:	85ca                	mv	a1,s2
    80004e72:	4088                	lw	a0,0(s1)
    80004e74:	d9afe0ef          	jal	8000340e <ialloc>
    80004e78:	892a                	mv	s2,a0
    80004e7a:	cd15                	beqz	a0,80004eb6 <create+0xc6>
  ilock(ip);
    80004e7c:	f02fe0ef          	jal	8000357e <ilock>
  ip->major = major;
    80004e80:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80004e84:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80004e88:	4785                	li	a5,1
    80004e8a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004e8e:	854a                	mv	a0,s2
    80004e90:	e3afe0ef          	jal	800034ca <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004e94:	4705                	li	a4,1
    80004e96:	02ea0463          	beq	s4,a4,80004ebe <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004e9a:	00492603          	lw	a2,4(s2)
    80004e9e:	fb040593          	addi	a1,s0,-80
    80004ea2:	8526                	mv	a0,s1
    80004ea4:	e5ffe0ef          	jal	80003d02 <dirlink>
    80004ea8:	06054263          	bltz	a0,80004f0c <create+0x11c>
  iunlockput(dp);
    80004eac:	8526                	mv	a0,s1
    80004eae:	8ddfe0ef          	jal	8000378a <iunlockput>
  return ip;
    80004eb2:	89ca                	mv	s3,s2
    80004eb4:	bf71                	j	80004e50 <create+0x60>
    iunlockput(dp);
    80004eb6:	8526                	mv	a0,s1
    80004eb8:	8d3fe0ef          	jal	8000378a <iunlockput>
    return 0;
    80004ebc:	bf51                	j	80004e50 <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004ebe:	00492603          	lw	a2,4(s2)
    80004ec2:	00002597          	auipc	a1,0x2
    80004ec6:	70e58593          	addi	a1,a1,1806 # 800075d0 <etext+0x5d0>
    80004eca:	854a                	mv	a0,s2
    80004ecc:	e37fe0ef          	jal	80003d02 <dirlink>
    80004ed0:	02054e63          	bltz	a0,80004f0c <create+0x11c>
    80004ed4:	40d0                	lw	a2,4(s1)
    80004ed6:	00002597          	auipc	a1,0x2
    80004eda:	70258593          	addi	a1,a1,1794 # 800075d8 <etext+0x5d8>
    80004ede:	854a                	mv	a0,s2
    80004ee0:	e23fe0ef          	jal	80003d02 <dirlink>
    80004ee4:	02054463          	bltz	a0,80004f0c <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004ee8:	00492603          	lw	a2,4(s2)
    80004eec:	fb040593          	addi	a1,s0,-80
    80004ef0:	8526                	mv	a0,s1
    80004ef2:	e11fe0ef          	jal	80003d02 <dirlink>
    80004ef6:	00054b63          	bltz	a0,80004f0c <create+0x11c>
    dp->nlink++;  // for ".."
    80004efa:	04a4d783          	lhu	a5,74(s1)
    80004efe:	2785                	addiw	a5,a5,1
    80004f00:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004f04:	8526                	mv	a0,s1
    80004f06:	dc4fe0ef          	jal	800034ca <iupdate>
    80004f0a:	b74d                	j	80004eac <create+0xbc>
  ip->nlink = 0;
    80004f0c:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80004f10:	854a                	mv	a0,s2
    80004f12:	db8fe0ef          	jal	800034ca <iupdate>
  iunlockput(ip);
    80004f16:	854a                	mv	a0,s2
    80004f18:	873fe0ef          	jal	8000378a <iunlockput>
  iunlockput(dp);
    80004f1c:	8526                	mv	a0,s1
    80004f1e:	86dfe0ef          	jal	8000378a <iunlockput>
  return 0;
    80004f22:	b73d                	j	80004e50 <create+0x60>
    return 0;
    80004f24:	89aa                	mv	s3,a0
    80004f26:	b72d                	j	80004e50 <create+0x60>

0000000080004f28 <sys_dup>:
{
    80004f28:	7179                	addi	sp,sp,-48
    80004f2a:	f406                	sd	ra,40(sp)
    80004f2c:	f022                	sd	s0,32(sp)
    80004f2e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004f30:	fd840613          	addi	a2,s0,-40
    80004f34:	4581                	li	a1,0
    80004f36:	4501                	li	a0,0
    80004f38:	e1fff0ef          	jal	80004d56 <argfd>
    return -1;
    80004f3c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004f3e:	02054363          	bltz	a0,80004f64 <sys_dup+0x3c>
    80004f42:	ec26                	sd	s1,24(sp)
    80004f44:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004f46:	fd843483          	ld	s1,-40(s0)
    80004f4a:	8526                	mv	a0,s1
    80004f4c:	e65ff0ef          	jal	80004db0 <fdalloc>
    80004f50:	892a                	mv	s2,a0
    return -1;
    80004f52:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004f54:	00054d63          	bltz	a0,80004f6e <sys_dup+0x46>
  filedup(f);
    80004f58:	8526                	mv	a0,s1
    80004f5a:	c0eff0ef          	jal	80004368 <filedup>
  return fd;
    80004f5e:	87ca                	mv	a5,s2
    80004f60:	64e2                	ld	s1,24(sp)
    80004f62:	6942                	ld	s2,16(sp)
}
    80004f64:	853e                	mv	a0,a5
    80004f66:	70a2                	ld	ra,40(sp)
    80004f68:	7402                	ld	s0,32(sp)
    80004f6a:	6145                	addi	sp,sp,48
    80004f6c:	8082                	ret
    80004f6e:	64e2                	ld	s1,24(sp)
    80004f70:	6942                	ld	s2,16(sp)
    80004f72:	bfcd                	j	80004f64 <sys_dup+0x3c>

0000000080004f74 <sys_read>:
{
    80004f74:	7179                	addi	sp,sp,-48
    80004f76:	f406                	sd	ra,40(sp)
    80004f78:	f022                	sd	s0,32(sp)
    80004f7a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f7c:	fd840593          	addi	a1,s0,-40
    80004f80:	4505                	li	a0,1
    80004f82:	93dfd0ef          	jal	800028be <argaddr>
  argint(2, &n);
    80004f86:	fe440593          	addi	a1,s0,-28
    80004f8a:	4509                	li	a0,2
    80004f8c:	917fd0ef          	jal	800028a2 <argint>
  if(argfd(0, 0, &f) < 0)
    80004f90:	fe840613          	addi	a2,s0,-24
    80004f94:	4581                	li	a1,0
    80004f96:	4501                	li	a0,0
    80004f98:	dbfff0ef          	jal	80004d56 <argfd>
    80004f9c:	87aa                	mv	a5,a0
    return -1;
    80004f9e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004fa0:	0007ca63          	bltz	a5,80004fb4 <sys_read+0x40>
  return fileread(f, p, n);
    80004fa4:	fe442603          	lw	a2,-28(s0)
    80004fa8:	fd843583          	ld	a1,-40(s0)
    80004fac:	fe843503          	ld	a0,-24(s0)
    80004fb0:	d22ff0ef          	jal	800044d2 <fileread>
}
    80004fb4:	70a2                	ld	ra,40(sp)
    80004fb6:	7402                	ld	s0,32(sp)
    80004fb8:	6145                	addi	sp,sp,48
    80004fba:	8082                	ret

0000000080004fbc <sys_write>:
{
    80004fbc:	7179                	addi	sp,sp,-48
    80004fbe:	f406                	sd	ra,40(sp)
    80004fc0:	f022                	sd	s0,32(sp)
    80004fc2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004fc4:	fd840593          	addi	a1,s0,-40
    80004fc8:	4505                	li	a0,1
    80004fca:	8f5fd0ef          	jal	800028be <argaddr>
  argint(2, &n);
    80004fce:	fe440593          	addi	a1,s0,-28
    80004fd2:	4509                	li	a0,2
    80004fd4:	8cffd0ef          	jal	800028a2 <argint>
  if(argfd(0, 0, &f) < 0)
    80004fd8:	fe840613          	addi	a2,s0,-24
    80004fdc:	4581                	li	a1,0
    80004fde:	4501                	li	a0,0
    80004fe0:	d77ff0ef          	jal	80004d56 <argfd>
    80004fe4:	87aa                	mv	a5,a0
    return -1;
    80004fe6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004fe8:	0007ca63          	bltz	a5,80004ffc <sys_write+0x40>
  return filewrite(f, p, n);
    80004fec:	fe442603          	lw	a2,-28(s0)
    80004ff0:	fd843583          	ld	a1,-40(s0)
    80004ff4:	fe843503          	ld	a0,-24(s0)
    80004ff8:	d9eff0ef          	jal	80004596 <filewrite>
}
    80004ffc:	70a2                	ld	ra,40(sp)
    80004ffe:	7402                	ld	s0,32(sp)
    80005000:	6145                	addi	sp,sp,48
    80005002:	8082                	ret

0000000080005004 <sys_close>:
{
    80005004:	1101                	addi	sp,sp,-32
    80005006:	ec06                	sd	ra,24(sp)
    80005008:	e822                	sd	s0,16(sp)
    8000500a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000500c:	fe040613          	addi	a2,s0,-32
    80005010:	fec40593          	addi	a1,s0,-20
    80005014:	4501                	li	a0,0
    80005016:	d41ff0ef          	jal	80004d56 <argfd>
    return -1;
    8000501a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000501c:	02054163          	bltz	a0,8000503e <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80005020:	915fc0ef          	jal	80001934 <myproc>
    80005024:	fec42783          	lw	a5,-20(s0)
    80005028:	078e                	slli	a5,a5,0x3
    8000502a:	0d078793          	addi	a5,a5,208
    8000502e:	953e                	add	a0,a0,a5
    80005030:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005034:	fe043503          	ld	a0,-32(s0)
    80005038:	b76ff0ef          	jal	800043ae <fileclose>
  return 0;
    8000503c:	4781                	li	a5,0
}
    8000503e:	853e                	mv	a0,a5
    80005040:	60e2                	ld	ra,24(sp)
    80005042:	6442                	ld	s0,16(sp)
    80005044:	6105                	addi	sp,sp,32
    80005046:	8082                	ret

0000000080005048 <sys_fstat>:
{
    80005048:	1101                	addi	sp,sp,-32
    8000504a:	ec06                	sd	ra,24(sp)
    8000504c:	e822                	sd	s0,16(sp)
    8000504e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005050:	fe040593          	addi	a1,s0,-32
    80005054:	4505                	li	a0,1
    80005056:	869fd0ef          	jal	800028be <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000505a:	fe840613          	addi	a2,s0,-24
    8000505e:	4581                	li	a1,0
    80005060:	4501                	li	a0,0
    80005062:	cf5ff0ef          	jal	80004d56 <argfd>
    80005066:	87aa                	mv	a5,a0
    return -1;
    80005068:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000506a:	0007c863          	bltz	a5,8000507a <sys_fstat+0x32>
  return filestat(f, st);
    8000506e:	fe043583          	ld	a1,-32(s0)
    80005072:	fe843503          	ld	a0,-24(s0)
    80005076:	bfaff0ef          	jal	80004470 <filestat>
}
    8000507a:	60e2                	ld	ra,24(sp)
    8000507c:	6442                	ld	s0,16(sp)
    8000507e:	6105                	addi	sp,sp,32
    80005080:	8082                	ret

0000000080005082 <sys_link>:
{
    80005082:	7169                	addi	sp,sp,-304
    80005084:	f606                	sd	ra,296(sp)
    80005086:	f222                	sd	s0,288(sp)
    80005088:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000508a:	08000613          	li	a2,128
    8000508e:	ed040593          	addi	a1,s0,-304
    80005092:	4501                	li	a0,0
    80005094:	847fd0ef          	jal	800028da <argstr>
    return -1;
    80005098:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000509a:	0c054e63          	bltz	a0,80005176 <sys_link+0xf4>
    8000509e:	08000613          	li	a2,128
    800050a2:	f5040593          	addi	a1,s0,-176
    800050a6:	4505                	li	a0,1
    800050a8:	833fd0ef          	jal	800028da <argstr>
    return -1;
    800050ac:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050ae:	0c054463          	bltz	a0,80005176 <sys_link+0xf4>
    800050b2:	ee26                	sd	s1,280(sp)
  begin_op();
    800050b4:	ed7fe0ef          	jal	80003f8a <begin_op>
  if((ip = namei(old)) == 0){
    800050b8:	ed040513          	addi	a0,s0,-304
    800050bc:	cf1fe0ef          	jal	80003dac <namei>
    800050c0:	84aa                	mv	s1,a0
    800050c2:	c53d                	beqz	a0,80005130 <sys_link+0xae>
  ilock(ip);
    800050c4:	cbafe0ef          	jal	8000357e <ilock>
  if(ip->type == T_DIR){
    800050c8:	04449703          	lh	a4,68(s1)
    800050cc:	4785                	li	a5,1
    800050ce:	06f70663          	beq	a4,a5,8000513a <sys_link+0xb8>
    800050d2:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800050d4:	04a4d783          	lhu	a5,74(s1)
    800050d8:	2785                	addiw	a5,a5,1
    800050da:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050de:	8526                	mv	a0,s1
    800050e0:	beafe0ef          	jal	800034ca <iupdate>
  iunlock(ip);
    800050e4:	8526                	mv	a0,s1
    800050e6:	d46fe0ef          	jal	8000362c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800050ea:	fd040593          	addi	a1,s0,-48
    800050ee:	f5040513          	addi	a0,s0,-176
    800050f2:	cd5fe0ef          	jal	80003dc6 <nameiparent>
    800050f6:	892a                	mv	s2,a0
    800050f8:	cd21                	beqz	a0,80005150 <sys_link+0xce>
  ilock(dp);
    800050fa:	c84fe0ef          	jal	8000357e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800050fe:	854a                	mv	a0,s2
    80005100:	00092703          	lw	a4,0(s2)
    80005104:	409c                	lw	a5,0(s1)
    80005106:	04f71263          	bne	a4,a5,8000514a <sys_link+0xc8>
    8000510a:	40d0                	lw	a2,4(s1)
    8000510c:	fd040593          	addi	a1,s0,-48
    80005110:	bf3fe0ef          	jal	80003d02 <dirlink>
    80005114:	02054b63          	bltz	a0,8000514a <sys_link+0xc8>
  iunlockput(dp);
    80005118:	854a                	mv	a0,s2
    8000511a:	e70fe0ef          	jal	8000378a <iunlockput>
  iput(ip);
    8000511e:	8526                	mv	a0,s1
    80005120:	de0fe0ef          	jal	80003700 <iput>
  end_op();
    80005124:	ed7fe0ef          	jal	80003ffa <end_op>
  return 0;
    80005128:	4781                	li	a5,0
    8000512a:	64f2                	ld	s1,280(sp)
    8000512c:	6952                	ld	s2,272(sp)
    8000512e:	a0a1                	j	80005176 <sys_link+0xf4>
    end_op();
    80005130:	ecbfe0ef          	jal	80003ffa <end_op>
    return -1;
    80005134:	57fd                	li	a5,-1
    80005136:	64f2                	ld	s1,280(sp)
    80005138:	a83d                	j	80005176 <sys_link+0xf4>
    iunlockput(ip);
    8000513a:	8526                	mv	a0,s1
    8000513c:	e4efe0ef          	jal	8000378a <iunlockput>
    end_op();
    80005140:	ebbfe0ef          	jal	80003ffa <end_op>
    return -1;
    80005144:	57fd                	li	a5,-1
    80005146:	64f2                	ld	s1,280(sp)
    80005148:	a03d                	j	80005176 <sys_link+0xf4>
    iunlockput(dp);
    8000514a:	854a                	mv	a0,s2
    8000514c:	e3efe0ef          	jal	8000378a <iunlockput>
  ilock(ip);
    80005150:	8526                	mv	a0,s1
    80005152:	c2cfe0ef          	jal	8000357e <ilock>
  ip->nlink--;
    80005156:	04a4d783          	lhu	a5,74(s1)
    8000515a:	37fd                	addiw	a5,a5,-1
    8000515c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005160:	8526                	mv	a0,s1
    80005162:	b68fe0ef          	jal	800034ca <iupdate>
  iunlockput(ip);
    80005166:	8526                	mv	a0,s1
    80005168:	e22fe0ef          	jal	8000378a <iunlockput>
  end_op();
    8000516c:	e8ffe0ef          	jal	80003ffa <end_op>
  return -1;
    80005170:	57fd                	li	a5,-1
    80005172:	64f2                	ld	s1,280(sp)
    80005174:	6952                	ld	s2,272(sp)
}
    80005176:	853e                	mv	a0,a5
    80005178:	70b2                	ld	ra,296(sp)
    8000517a:	7412                	ld	s0,288(sp)
    8000517c:	6155                	addi	sp,sp,304
    8000517e:	8082                	ret

0000000080005180 <sys_unlink>:
{
    80005180:	7151                	addi	sp,sp,-240
    80005182:	f586                	sd	ra,232(sp)
    80005184:	f1a2                	sd	s0,224(sp)
    80005186:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005188:	08000613          	li	a2,128
    8000518c:	f3040593          	addi	a1,s0,-208
    80005190:	4501                	li	a0,0
    80005192:	f48fd0ef          	jal	800028da <argstr>
    80005196:	14054d63          	bltz	a0,800052f0 <sys_unlink+0x170>
    8000519a:	eda6                	sd	s1,216(sp)
  begin_op();
    8000519c:	deffe0ef          	jal	80003f8a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800051a0:	fb040593          	addi	a1,s0,-80
    800051a4:	f3040513          	addi	a0,s0,-208
    800051a8:	c1ffe0ef          	jal	80003dc6 <nameiparent>
    800051ac:	84aa                	mv	s1,a0
    800051ae:	c955                	beqz	a0,80005262 <sys_unlink+0xe2>
  ilock(dp);
    800051b0:	bcefe0ef          	jal	8000357e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800051b4:	00002597          	auipc	a1,0x2
    800051b8:	41c58593          	addi	a1,a1,1052 # 800075d0 <etext+0x5d0>
    800051bc:	fb040513          	addi	a0,s0,-80
    800051c0:	943fe0ef          	jal	80003b02 <namecmp>
    800051c4:	10050b63          	beqz	a0,800052da <sys_unlink+0x15a>
    800051c8:	00002597          	auipc	a1,0x2
    800051cc:	41058593          	addi	a1,a1,1040 # 800075d8 <etext+0x5d8>
    800051d0:	fb040513          	addi	a0,s0,-80
    800051d4:	92ffe0ef          	jal	80003b02 <namecmp>
    800051d8:	10050163          	beqz	a0,800052da <sys_unlink+0x15a>
    800051dc:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800051de:	f2c40613          	addi	a2,s0,-212
    800051e2:	fb040593          	addi	a1,s0,-80
    800051e6:	8526                	mv	a0,s1
    800051e8:	931fe0ef          	jal	80003b18 <dirlookup>
    800051ec:	892a                	mv	s2,a0
    800051ee:	0e050563          	beqz	a0,800052d8 <sys_unlink+0x158>
    800051f2:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    800051f4:	b8afe0ef          	jal	8000357e <ilock>
  if(ip->nlink < 1)
    800051f8:	04a91783          	lh	a5,74(s2)
    800051fc:	06f05863          	blez	a5,8000526c <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005200:	04491703          	lh	a4,68(s2)
    80005204:	4785                	li	a5,1
    80005206:	06f70963          	beq	a4,a5,80005278 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    8000520a:	fc040993          	addi	s3,s0,-64
    8000520e:	4641                	li	a2,16
    80005210:	4581                	li	a1,0
    80005212:	854e                	mv	a0,s3
    80005214:	ae5fb0ef          	jal	80000cf8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005218:	4741                	li	a4,16
    8000521a:	f2c42683          	lw	a3,-212(s0)
    8000521e:	864e                	mv	a2,s3
    80005220:	4581                	li	a1,0
    80005222:	8526                	mv	a0,s1
    80005224:	fdefe0ef          	jal	80003a02 <writei>
    80005228:	47c1                	li	a5,16
    8000522a:	08f51863          	bne	a0,a5,800052ba <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    8000522e:	04491703          	lh	a4,68(s2)
    80005232:	4785                	li	a5,1
    80005234:	08f70963          	beq	a4,a5,800052c6 <sys_unlink+0x146>
  iunlockput(dp);
    80005238:	8526                	mv	a0,s1
    8000523a:	d50fe0ef          	jal	8000378a <iunlockput>
  ip->nlink--;
    8000523e:	04a95783          	lhu	a5,74(s2)
    80005242:	37fd                	addiw	a5,a5,-1
    80005244:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005248:	854a                	mv	a0,s2
    8000524a:	a80fe0ef          	jal	800034ca <iupdate>
  iunlockput(ip);
    8000524e:	854a                	mv	a0,s2
    80005250:	d3afe0ef          	jal	8000378a <iunlockput>
  end_op();
    80005254:	da7fe0ef          	jal	80003ffa <end_op>
  return 0;
    80005258:	4501                	li	a0,0
    8000525a:	64ee                	ld	s1,216(sp)
    8000525c:	694e                	ld	s2,208(sp)
    8000525e:	69ae                	ld	s3,200(sp)
    80005260:	a061                	j	800052e8 <sys_unlink+0x168>
    end_op();
    80005262:	d99fe0ef          	jal	80003ffa <end_op>
    return -1;
    80005266:	557d                	li	a0,-1
    80005268:	64ee                	ld	s1,216(sp)
    8000526a:	a8bd                	j	800052e8 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    8000526c:	00002517          	auipc	a0,0x2
    80005270:	37450513          	addi	a0,a0,884 # 800075e0 <etext+0x5e0>
    80005274:	db0fb0ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005278:	04c92703          	lw	a4,76(s2)
    8000527c:	02000793          	li	a5,32
    80005280:	f8e7f5e3          	bgeu	a5,a4,8000520a <sys_unlink+0x8a>
    80005284:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005286:	4741                	li	a4,16
    80005288:	86ce                	mv	a3,s3
    8000528a:	f1840613          	addi	a2,s0,-232
    8000528e:	4581                	li	a1,0
    80005290:	854a                	mv	a0,s2
    80005292:	e7efe0ef          	jal	80003910 <readi>
    80005296:	47c1                	li	a5,16
    80005298:	00f51b63          	bne	a0,a5,800052ae <sys_unlink+0x12e>
    if(de.inum != 0)
    8000529c:	f1845783          	lhu	a5,-232(s0)
    800052a0:	ebb1                	bnez	a5,800052f4 <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800052a2:	29c1                	addiw	s3,s3,16
    800052a4:	04c92783          	lw	a5,76(s2)
    800052a8:	fcf9efe3          	bltu	s3,a5,80005286 <sys_unlink+0x106>
    800052ac:	bfb9                	j	8000520a <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800052ae:	00002517          	auipc	a0,0x2
    800052b2:	34a50513          	addi	a0,a0,842 # 800075f8 <etext+0x5f8>
    800052b6:	d6efb0ef          	jal	80000824 <panic>
    panic("unlink: writei");
    800052ba:	00002517          	auipc	a0,0x2
    800052be:	35650513          	addi	a0,a0,854 # 80007610 <etext+0x610>
    800052c2:	d62fb0ef          	jal	80000824 <panic>
    dp->nlink--;
    800052c6:	04a4d783          	lhu	a5,74(s1)
    800052ca:	37fd                	addiw	a5,a5,-1
    800052cc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800052d0:	8526                	mv	a0,s1
    800052d2:	9f8fe0ef          	jal	800034ca <iupdate>
    800052d6:	b78d                	j	80005238 <sys_unlink+0xb8>
    800052d8:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800052da:	8526                	mv	a0,s1
    800052dc:	caefe0ef          	jal	8000378a <iunlockput>
  end_op();
    800052e0:	d1bfe0ef          	jal	80003ffa <end_op>
  return -1;
    800052e4:	557d                	li	a0,-1
    800052e6:	64ee                	ld	s1,216(sp)
}
    800052e8:	70ae                	ld	ra,232(sp)
    800052ea:	740e                	ld	s0,224(sp)
    800052ec:	616d                	addi	sp,sp,240
    800052ee:	8082                	ret
    return -1;
    800052f0:	557d                	li	a0,-1
    800052f2:	bfdd                	j	800052e8 <sys_unlink+0x168>
    iunlockput(ip);
    800052f4:	854a                	mv	a0,s2
    800052f6:	c94fe0ef          	jal	8000378a <iunlockput>
    goto bad;
    800052fa:	694e                	ld	s2,208(sp)
    800052fc:	69ae                	ld	s3,200(sp)
    800052fe:	bff1                	j	800052da <sys_unlink+0x15a>

0000000080005300 <sys_open>:

uint64
sys_open(void)
{
    80005300:	7131                	addi	sp,sp,-192
    80005302:	fd06                	sd	ra,184(sp)
    80005304:	f922                	sd	s0,176(sp)
    80005306:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005308:	f4c40593          	addi	a1,s0,-180
    8000530c:	4505                	li	a0,1
    8000530e:	d94fd0ef          	jal	800028a2 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005312:	08000613          	li	a2,128
    80005316:	f5040593          	addi	a1,s0,-176
    8000531a:	4501                	li	a0,0
    8000531c:	dbefd0ef          	jal	800028da <argstr>
    80005320:	87aa                	mv	a5,a0
    return -1;
    80005322:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005324:	0a07c363          	bltz	a5,800053ca <sys_open+0xca>
    80005328:	f526                	sd	s1,168(sp)

  begin_op();
    8000532a:	c61fe0ef          	jal	80003f8a <begin_op>

  if(omode & O_CREATE){
    8000532e:	f4c42783          	lw	a5,-180(s0)
    80005332:	2007f793          	andi	a5,a5,512
    80005336:	c3dd                	beqz	a5,800053dc <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005338:	4681                	li	a3,0
    8000533a:	4601                	li	a2,0
    8000533c:	4589                	li	a1,2
    8000533e:	f5040513          	addi	a0,s0,-176
    80005342:	aafff0ef          	jal	80004df0 <create>
    80005346:	84aa                	mv	s1,a0
    if(ip == 0){
    80005348:	c549                	beqz	a0,800053d2 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000534a:	04449703          	lh	a4,68(s1)
    8000534e:	478d                	li	a5,3
    80005350:	00f71763          	bne	a4,a5,8000535e <sys_open+0x5e>
    80005354:	0464d703          	lhu	a4,70(s1)
    80005358:	47a5                	li	a5,9
    8000535a:	0ae7ee63          	bltu	a5,a4,80005416 <sys_open+0x116>
    8000535e:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005360:	fabfe0ef          	jal	8000430a <filealloc>
    80005364:	892a                	mv	s2,a0
    80005366:	c561                	beqz	a0,8000542e <sys_open+0x12e>
    80005368:	ed4e                	sd	s3,152(sp)
    8000536a:	a47ff0ef          	jal	80004db0 <fdalloc>
    8000536e:	89aa                	mv	s3,a0
    80005370:	0a054b63          	bltz	a0,80005426 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005374:	04449703          	lh	a4,68(s1)
    80005378:	478d                	li	a5,3
    8000537a:	0cf70363          	beq	a4,a5,80005440 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000537e:	4789                	li	a5,2
    80005380:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005384:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005388:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000538c:	f4c42783          	lw	a5,-180(s0)
    80005390:	0017f713          	andi	a4,a5,1
    80005394:	00174713          	xori	a4,a4,1
    80005398:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000539c:	0037f713          	andi	a4,a5,3
    800053a0:	00e03733          	snez	a4,a4
    800053a4:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800053a8:	4007f793          	andi	a5,a5,1024
    800053ac:	c791                	beqz	a5,800053b8 <sys_open+0xb8>
    800053ae:	04449703          	lh	a4,68(s1)
    800053b2:	4789                	li	a5,2
    800053b4:	08f70d63          	beq	a4,a5,8000544e <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800053b8:	8526                	mv	a0,s1
    800053ba:	a72fe0ef          	jal	8000362c <iunlock>
  end_op();
    800053be:	c3dfe0ef          	jal	80003ffa <end_op>

  return fd;
    800053c2:	854e                	mv	a0,s3
    800053c4:	74aa                	ld	s1,168(sp)
    800053c6:	790a                	ld	s2,160(sp)
    800053c8:	69ea                	ld	s3,152(sp)
}
    800053ca:	70ea                	ld	ra,184(sp)
    800053cc:	744a                	ld	s0,176(sp)
    800053ce:	6129                	addi	sp,sp,192
    800053d0:	8082                	ret
      end_op();
    800053d2:	c29fe0ef          	jal	80003ffa <end_op>
      return -1;
    800053d6:	557d                	li	a0,-1
    800053d8:	74aa                	ld	s1,168(sp)
    800053da:	bfc5                	j	800053ca <sys_open+0xca>
    if((ip = namei(path)) == 0){
    800053dc:	f5040513          	addi	a0,s0,-176
    800053e0:	9cdfe0ef          	jal	80003dac <namei>
    800053e4:	84aa                	mv	s1,a0
    800053e6:	c11d                	beqz	a0,8000540c <sys_open+0x10c>
    ilock(ip);
    800053e8:	996fe0ef          	jal	8000357e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800053ec:	04449703          	lh	a4,68(s1)
    800053f0:	4785                	li	a5,1
    800053f2:	f4f71ce3          	bne	a4,a5,8000534a <sys_open+0x4a>
    800053f6:	f4c42783          	lw	a5,-180(s0)
    800053fa:	d3b5                	beqz	a5,8000535e <sys_open+0x5e>
      iunlockput(ip);
    800053fc:	8526                	mv	a0,s1
    800053fe:	b8cfe0ef          	jal	8000378a <iunlockput>
      end_op();
    80005402:	bf9fe0ef          	jal	80003ffa <end_op>
      return -1;
    80005406:	557d                	li	a0,-1
    80005408:	74aa                	ld	s1,168(sp)
    8000540a:	b7c1                	j	800053ca <sys_open+0xca>
      end_op();
    8000540c:	beffe0ef          	jal	80003ffa <end_op>
      return -1;
    80005410:	557d                	li	a0,-1
    80005412:	74aa                	ld	s1,168(sp)
    80005414:	bf5d                	j	800053ca <sys_open+0xca>
    iunlockput(ip);
    80005416:	8526                	mv	a0,s1
    80005418:	b72fe0ef          	jal	8000378a <iunlockput>
    end_op();
    8000541c:	bdffe0ef          	jal	80003ffa <end_op>
    return -1;
    80005420:	557d                	li	a0,-1
    80005422:	74aa                	ld	s1,168(sp)
    80005424:	b75d                	j	800053ca <sys_open+0xca>
      fileclose(f);
    80005426:	854a                	mv	a0,s2
    80005428:	f87fe0ef          	jal	800043ae <fileclose>
    8000542c:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000542e:	8526                	mv	a0,s1
    80005430:	b5afe0ef          	jal	8000378a <iunlockput>
    end_op();
    80005434:	bc7fe0ef          	jal	80003ffa <end_op>
    return -1;
    80005438:	557d                	li	a0,-1
    8000543a:	74aa                	ld	s1,168(sp)
    8000543c:	790a                	ld	s2,160(sp)
    8000543e:	b771                	j	800053ca <sys_open+0xca>
    f->type = FD_DEVICE;
    80005440:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005444:	04649783          	lh	a5,70(s1)
    80005448:	02f91223          	sh	a5,36(s2)
    8000544c:	bf35                	j	80005388 <sys_open+0x88>
    itrunc(ip);
    8000544e:	8526                	mv	a0,s1
    80005450:	a1cfe0ef          	jal	8000366c <itrunc>
    80005454:	b795                	j	800053b8 <sys_open+0xb8>

0000000080005456 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005456:	7175                	addi	sp,sp,-144
    80005458:	e506                	sd	ra,136(sp)
    8000545a:	e122                	sd	s0,128(sp)
    8000545c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000545e:	b2dfe0ef          	jal	80003f8a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005462:	08000613          	li	a2,128
    80005466:	f7040593          	addi	a1,s0,-144
    8000546a:	4501                	li	a0,0
    8000546c:	c6efd0ef          	jal	800028da <argstr>
    80005470:	02054363          	bltz	a0,80005496 <sys_mkdir+0x40>
    80005474:	4681                	li	a3,0
    80005476:	4601                	li	a2,0
    80005478:	4585                	li	a1,1
    8000547a:	f7040513          	addi	a0,s0,-144
    8000547e:	973ff0ef          	jal	80004df0 <create>
    80005482:	c911                	beqz	a0,80005496 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005484:	b06fe0ef          	jal	8000378a <iunlockput>
  end_op();
    80005488:	b73fe0ef          	jal	80003ffa <end_op>
  return 0;
    8000548c:	4501                	li	a0,0
}
    8000548e:	60aa                	ld	ra,136(sp)
    80005490:	640a                	ld	s0,128(sp)
    80005492:	6149                	addi	sp,sp,144
    80005494:	8082                	ret
    end_op();
    80005496:	b65fe0ef          	jal	80003ffa <end_op>
    return -1;
    8000549a:	557d                	li	a0,-1
    8000549c:	bfcd                	j	8000548e <sys_mkdir+0x38>

000000008000549e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000549e:	7135                	addi	sp,sp,-160
    800054a0:	ed06                	sd	ra,152(sp)
    800054a2:	e922                	sd	s0,144(sp)
    800054a4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800054a6:	ae5fe0ef          	jal	80003f8a <begin_op>
  argint(1, &major);
    800054aa:	f6c40593          	addi	a1,s0,-148
    800054ae:	4505                	li	a0,1
    800054b0:	bf2fd0ef          	jal	800028a2 <argint>
  argint(2, &minor);
    800054b4:	f6840593          	addi	a1,s0,-152
    800054b8:	4509                	li	a0,2
    800054ba:	be8fd0ef          	jal	800028a2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800054be:	08000613          	li	a2,128
    800054c2:	f7040593          	addi	a1,s0,-144
    800054c6:	4501                	li	a0,0
    800054c8:	c12fd0ef          	jal	800028da <argstr>
    800054cc:	02054563          	bltz	a0,800054f6 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800054d0:	f6841683          	lh	a3,-152(s0)
    800054d4:	f6c41603          	lh	a2,-148(s0)
    800054d8:	458d                	li	a1,3
    800054da:	f7040513          	addi	a0,s0,-144
    800054de:	913ff0ef          	jal	80004df0 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800054e2:	c911                	beqz	a0,800054f6 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800054e4:	aa6fe0ef          	jal	8000378a <iunlockput>
  end_op();
    800054e8:	b13fe0ef          	jal	80003ffa <end_op>
  return 0;
    800054ec:	4501                	li	a0,0
}
    800054ee:	60ea                	ld	ra,152(sp)
    800054f0:	644a                	ld	s0,144(sp)
    800054f2:	610d                	addi	sp,sp,160
    800054f4:	8082                	ret
    end_op();
    800054f6:	b05fe0ef          	jal	80003ffa <end_op>
    return -1;
    800054fa:	557d                	li	a0,-1
    800054fc:	bfcd                	j	800054ee <sys_mknod+0x50>

00000000800054fe <sys_chdir>:

uint64
sys_chdir(void)
{
    800054fe:	7135                	addi	sp,sp,-160
    80005500:	ed06                	sd	ra,152(sp)
    80005502:	e922                	sd	s0,144(sp)
    80005504:	e14a                	sd	s2,128(sp)
    80005506:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005508:	c2cfc0ef          	jal	80001934 <myproc>
    8000550c:	892a                	mv	s2,a0
  
  begin_op();
    8000550e:	a7dfe0ef          	jal	80003f8a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005512:	08000613          	li	a2,128
    80005516:	f6040593          	addi	a1,s0,-160
    8000551a:	4501                	li	a0,0
    8000551c:	bbefd0ef          	jal	800028da <argstr>
    80005520:	04054363          	bltz	a0,80005566 <sys_chdir+0x68>
    80005524:	e526                	sd	s1,136(sp)
    80005526:	f6040513          	addi	a0,s0,-160
    8000552a:	883fe0ef          	jal	80003dac <namei>
    8000552e:	84aa                	mv	s1,a0
    80005530:	c915                	beqz	a0,80005564 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005532:	84cfe0ef          	jal	8000357e <ilock>
  if(ip->type != T_DIR){
    80005536:	04449703          	lh	a4,68(s1)
    8000553a:	4785                	li	a5,1
    8000553c:	02f71963          	bne	a4,a5,8000556e <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005540:	8526                	mv	a0,s1
    80005542:	8eafe0ef          	jal	8000362c <iunlock>
  iput(p->cwd);
    80005546:	15093503          	ld	a0,336(s2)
    8000554a:	9b6fe0ef          	jal	80003700 <iput>
  end_op();
    8000554e:	aadfe0ef          	jal	80003ffa <end_op>
  p->cwd = ip;
    80005552:	14993823          	sd	s1,336(s2)
  return 0;
    80005556:	4501                	li	a0,0
    80005558:	64aa                	ld	s1,136(sp)
}
    8000555a:	60ea                	ld	ra,152(sp)
    8000555c:	644a                	ld	s0,144(sp)
    8000555e:	690a                	ld	s2,128(sp)
    80005560:	610d                	addi	sp,sp,160
    80005562:	8082                	ret
    80005564:	64aa                	ld	s1,136(sp)
    end_op();
    80005566:	a95fe0ef          	jal	80003ffa <end_op>
    return -1;
    8000556a:	557d                	li	a0,-1
    8000556c:	b7fd                	j	8000555a <sys_chdir+0x5c>
    iunlockput(ip);
    8000556e:	8526                	mv	a0,s1
    80005570:	a1afe0ef          	jal	8000378a <iunlockput>
    end_op();
    80005574:	a87fe0ef          	jal	80003ffa <end_op>
    return -1;
    80005578:	557d                	li	a0,-1
    8000557a:	64aa                	ld	s1,136(sp)
    8000557c:	bff9                	j	8000555a <sys_chdir+0x5c>

000000008000557e <sys_exec>:

uint64
sys_exec(void)
{
    8000557e:	7105                	addi	sp,sp,-480
    80005580:	ef86                	sd	ra,472(sp)
    80005582:	eba2                	sd	s0,464(sp)
    80005584:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005586:	e2840593          	addi	a1,s0,-472
    8000558a:	4505                	li	a0,1
    8000558c:	b32fd0ef          	jal	800028be <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005590:	08000613          	li	a2,128
    80005594:	f3040593          	addi	a1,s0,-208
    80005598:	4501                	li	a0,0
    8000559a:	b40fd0ef          	jal	800028da <argstr>
    8000559e:	87aa                	mv	a5,a0
    return -1;
    800055a0:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800055a2:	0e07c063          	bltz	a5,80005682 <sys_exec+0x104>
    800055a6:	e7a6                	sd	s1,456(sp)
    800055a8:	e3ca                	sd	s2,448(sp)
    800055aa:	ff4e                	sd	s3,440(sp)
    800055ac:	fb52                	sd	s4,432(sp)
    800055ae:	f756                	sd	s5,424(sp)
    800055b0:	f35a                	sd	s6,416(sp)
    800055b2:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800055b4:	e3040a13          	addi	s4,s0,-464
    800055b8:	10000613          	li	a2,256
    800055bc:	4581                	li	a1,0
    800055be:	8552                	mv	a0,s4
    800055c0:	f38fb0ef          	jal	80000cf8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800055c4:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800055c6:	89d2                	mv	s3,s4
    800055c8:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800055ca:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800055ce:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    800055d0:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800055d4:	00391513          	slli	a0,s2,0x3
    800055d8:	85d6                	mv	a1,s5
    800055da:	e2843783          	ld	a5,-472(s0)
    800055de:	953e                	add	a0,a0,a5
    800055e0:	a38fd0ef          	jal	80002818 <fetchaddr>
    800055e4:	02054663          	bltz	a0,80005610 <sys_exec+0x92>
    if(uarg == 0){
    800055e8:	e2043783          	ld	a5,-480(s0)
    800055ec:	c7a1                	beqz	a5,80005634 <sys_exec+0xb6>
    argv[i] = kalloc();
    800055ee:	d56fb0ef          	jal	80000b44 <kalloc>
    800055f2:	85aa                	mv	a1,a0
    800055f4:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800055f8:	cd01                	beqz	a0,80005610 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800055fa:	865a                	mv	a2,s6
    800055fc:	e2043503          	ld	a0,-480(s0)
    80005600:	a62fd0ef          	jal	80002862 <fetchstr>
    80005604:	00054663          	bltz	a0,80005610 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005608:	0905                	addi	s2,s2,1
    8000560a:	09a1                	addi	s3,s3,8
    8000560c:	fd7914e3          	bne	s2,s7,800055d4 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005610:	100a0a13          	addi	s4,s4,256
    80005614:	6088                	ld	a0,0(s1)
    80005616:	cd31                	beqz	a0,80005672 <sys_exec+0xf4>
    kfree(argv[i]);
    80005618:	c44fb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000561c:	04a1                	addi	s1,s1,8
    8000561e:	ff449be3          	bne	s1,s4,80005614 <sys_exec+0x96>
  return -1;
    80005622:	557d                	li	a0,-1
    80005624:	64be                	ld	s1,456(sp)
    80005626:	691e                	ld	s2,448(sp)
    80005628:	79fa                	ld	s3,440(sp)
    8000562a:	7a5a                	ld	s4,432(sp)
    8000562c:	7aba                	ld	s5,424(sp)
    8000562e:	7b1a                	ld	s6,416(sp)
    80005630:	6bfa                	ld	s7,408(sp)
    80005632:	a881                	j	80005682 <sys_exec+0x104>
      argv[i] = 0;
    80005634:	0009079b          	sext.w	a5,s2
    80005638:	e3040593          	addi	a1,s0,-464
    8000563c:	078e                	slli	a5,a5,0x3
    8000563e:	97ae                	add	a5,a5,a1
    80005640:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005644:	f3040513          	addi	a0,s0,-208
    80005648:	bb2ff0ef          	jal	800049fa <kexec>
    8000564c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000564e:	100a0a13          	addi	s4,s4,256
    80005652:	6088                	ld	a0,0(s1)
    80005654:	c511                	beqz	a0,80005660 <sys_exec+0xe2>
    kfree(argv[i]);
    80005656:	c06fb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000565a:	04a1                	addi	s1,s1,8
    8000565c:	ff449be3          	bne	s1,s4,80005652 <sys_exec+0xd4>
  return ret;
    80005660:	854a                	mv	a0,s2
    80005662:	64be                	ld	s1,456(sp)
    80005664:	691e                	ld	s2,448(sp)
    80005666:	79fa                	ld	s3,440(sp)
    80005668:	7a5a                	ld	s4,432(sp)
    8000566a:	7aba                	ld	s5,424(sp)
    8000566c:	7b1a                	ld	s6,416(sp)
    8000566e:	6bfa                	ld	s7,408(sp)
    80005670:	a809                	j	80005682 <sys_exec+0x104>
  return -1;
    80005672:	557d                	li	a0,-1
    80005674:	64be                	ld	s1,456(sp)
    80005676:	691e                	ld	s2,448(sp)
    80005678:	79fa                	ld	s3,440(sp)
    8000567a:	7a5a                	ld	s4,432(sp)
    8000567c:	7aba                	ld	s5,424(sp)
    8000567e:	7b1a                	ld	s6,416(sp)
    80005680:	6bfa                	ld	s7,408(sp)
}
    80005682:	60fe                	ld	ra,472(sp)
    80005684:	645e                	ld	s0,464(sp)
    80005686:	613d                	addi	sp,sp,480
    80005688:	8082                	ret

000000008000568a <sys_pipe>:

uint64
sys_pipe(void)
{
    8000568a:	7139                	addi	sp,sp,-64
    8000568c:	fc06                	sd	ra,56(sp)
    8000568e:	f822                	sd	s0,48(sp)
    80005690:	f426                	sd	s1,40(sp)
    80005692:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005694:	aa0fc0ef          	jal	80001934 <myproc>
    80005698:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000569a:	fd840593          	addi	a1,s0,-40
    8000569e:	4501                	li	a0,0
    800056a0:	a1efd0ef          	jal	800028be <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800056a4:	fc840593          	addi	a1,s0,-56
    800056a8:	fd040513          	addi	a0,s0,-48
    800056ac:	81eff0ef          	jal	800046ca <pipealloc>
    return -1;
    800056b0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800056b2:	0a054763          	bltz	a0,80005760 <sys_pipe+0xd6>
  fd0 = -1;
    800056b6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800056ba:	fd043503          	ld	a0,-48(s0)
    800056be:	ef2ff0ef          	jal	80004db0 <fdalloc>
    800056c2:	fca42223          	sw	a0,-60(s0)
    800056c6:	08054463          	bltz	a0,8000574e <sys_pipe+0xc4>
    800056ca:	fc843503          	ld	a0,-56(s0)
    800056ce:	ee2ff0ef          	jal	80004db0 <fdalloc>
    800056d2:	fca42023          	sw	a0,-64(s0)
    800056d6:	06054263          	bltz	a0,8000573a <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800056da:	4691                	li	a3,4
    800056dc:	fc440613          	addi	a2,s0,-60
    800056e0:	fd843583          	ld	a1,-40(s0)
    800056e4:	68a8                	ld	a0,80(s1)
    800056e6:	f6ffb0ef          	jal	80001654 <copyout>
    800056ea:	00054e63          	bltz	a0,80005706 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800056ee:	4691                	li	a3,4
    800056f0:	fc040613          	addi	a2,s0,-64
    800056f4:	fd843583          	ld	a1,-40(s0)
    800056f8:	95b6                	add	a1,a1,a3
    800056fa:	68a8                	ld	a0,80(s1)
    800056fc:	f59fb0ef          	jal	80001654 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005700:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005702:	04055f63          	bgez	a0,80005760 <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    80005706:	fc442783          	lw	a5,-60(s0)
    8000570a:	078e                	slli	a5,a5,0x3
    8000570c:	0d078793          	addi	a5,a5,208
    80005710:	97a6                	add	a5,a5,s1
    80005712:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005716:	fc042783          	lw	a5,-64(s0)
    8000571a:	078e                	slli	a5,a5,0x3
    8000571c:	0d078793          	addi	a5,a5,208
    80005720:	97a6                	add	a5,a5,s1
    80005722:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005726:	fd043503          	ld	a0,-48(s0)
    8000572a:	c85fe0ef          	jal	800043ae <fileclose>
    fileclose(wf);
    8000572e:	fc843503          	ld	a0,-56(s0)
    80005732:	c7dfe0ef          	jal	800043ae <fileclose>
    return -1;
    80005736:	57fd                	li	a5,-1
    80005738:	a025                	j	80005760 <sys_pipe+0xd6>
    if(fd0 >= 0)
    8000573a:	fc442783          	lw	a5,-60(s0)
    8000573e:	0007c863          	bltz	a5,8000574e <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    80005742:	078e                	slli	a5,a5,0x3
    80005744:	0d078793          	addi	a5,a5,208
    80005748:	97a6                	add	a5,a5,s1
    8000574a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000574e:	fd043503          	ld	a0,-48(s0)
    80005752:	c5dfe0ef          	jal	800043ae <fileclose>
    fileclose(wf);
    80005756:	fc843503          	ld	a0,-56(s0)
    8000575a:	c55fe0ef          	jal	800043ae <fileclose>
    return -1;
    8000575e:	57fd                	li	a5,-1
}
    80005760:	853e                	mv	a0,a5
    80005762:	70e2                	ld	ra,56(sp)
    80005764:	7442                	ld	s0,48(sp)
    80005766:	74a2                	ld	s1,40(sp)
    80005768:	6121                	addi	sp,sp,64
    8000576a:	8082                	ret
    8000576c:	0000                	unimp
	...

0000000080005770 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005770:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005772:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005774:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005776:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005778:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000577a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000577c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000577e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005780:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005782:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005784:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005786:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005788:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000578a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000578c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000578e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005790:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005792:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005794:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005796:	f91fc0ef          	jal	80002726 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000579a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000579c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000579e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800057a0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800057a2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800057a4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800057a6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800057a8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800057aa:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800057ac:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800057ae:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800057b0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800057b2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800057b4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800057b6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800057b8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800057ba:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800057bc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800057be:	10200073          	sret
    800057c2:	00000013          	nop
    800057c6:	00000013          	nop
    800057ca:	00000013          	nop

00000000800057ce <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800057ce:	1141                	addi	sp,sp,-16
    800057d0:	e406                	sd	ra,8(sp)
    800057d2:	e022                	sd	s0,0(sp)
    800057d4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800057d6:	0c000737          	lui	a4,0xc000
    800057da:	4785                	li	a5,1
    800057dc:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800057de:	c35c                	sw	a5,4(a4)
}
    800057e0:	60a2                	ld	ra,8(sp)
    800057e2:	6402                	ld	s0,0(sp)
    800057e4:	0141                	addi	sp,sp,16
    800057e6:	8082                	ret

00000000800057e8 <plicinithart>:

void
plicinithart(void)
{
    800057e8:	1141                	addi	sp,sp,-16
    800057ea:	e406                	sd	ra,8(sp)
    800057ec:	e022                	sd	s0,0(sp)
    800057ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800057f0:	910fc0ef          	jal	80001900 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800057f4:	0085171b          	slliw	a4,a0,0x8
    800057f8:	0c0027b7          	lui	a5,0xc002
    800057fc:	97ba                	add	a5,a5,a4
    800057fe:	40200713          	li	a4,1026
    80005802:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005806:	00d5151b          	slliw	a0,a0,0xd
    8000580a:	0c2017b7          	lui	a5,0xc201
    8000580e:	97aa                	add	a5,a5,a0
    80005810:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005814:	60a2                	ld	ra,8(sp)
    80005816:	6402                	ld	s0,0(sp)
    80005818:	0141                	addi	sp,sp,16
    8000581a:	8082                	ret

000000008000581c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000581c:	1141                	addi	sp,sp,-16
    8000581e:	e406                	sd	ra,8(sp)
    80005820:	e022                	sd	s0,0(sp)
    80005822:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005824:	8dcfc0ef          	jal	80001900 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005828:	00d5151b          	slliw	a0,a0,0xd
    8000582c:	0c2017b7          	lui	a5,0xc201
    80005830:	97aa                	add	a5,a5,a0
  return irq;
}
    80005832:	43c8                	lw	a0,4(a5)
    80005834:	60a2                	ld	ra,8(sp)
    80005836:	6402                	ld	s0,0(sp)
    80005838:	0141                	addi	sp,sp,16
    8000583a:	8082                	ret

000000008000583c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000583c:	1101                	addi	sp,sp,-32
    8000583e:	ec06                	sd	ra,24(sp)
    80005840:	e822                	sd	s0,16(sp)
    80005842:	e426                	sd	s1,8(sp)
    80005844:	1000                	addi	s0,sp,32
    80005846:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005848:	8b8fc0ef          	jal	80001900 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000584c:	00d5179b          	slliw	a5,a0,0xd
    80005850:	0c201737          	lui	a4,0xc201
    80005854:	97ba                	add	a5,a5,a4
    80005856:	c3c4                	sw	s1,4(a5)
}
    80005858:	60e2                	ld	ra,24(sp)
    8000585a:	6442                	ld	s0,16(sp)
    8000585c:	64a2                	ld	s1,8(sp)
    8000585e:	6105                	addi	sp,sp,32
    80005860:	8082                	ret

0000000080005862 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005862:	1141                	addi	sp,sp,-16
    80005864:	e406                	sd	ra,8(sp)
    80005866:	e022                	sd	s0,0(sp)
    80005868:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000586a:	479d                	li	a5,7
    8000586c:	04a7ca63          	blt	a5,a0,800058c0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005870:	0005e797          	auipc	a5,0x5e
    80005874:	be878793          	addi	a5,a5,-1048 # 80063458 <disk>
    80005878:	97aa                	add	a5,a5,a0
    8000587a:	0187c783          	lbu	a5,24(a5)
    8000587e:	e7b9                	bnez	a5,800058cc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005880:	00451693          	slli	a3,a0,0x4
    80005884:	0005e797          	auipc	a5,0x5e
    80005888:	bd478793          	addi	a5,a5,-1068 # 80063458 <disk>
    8000588c:	6398                	ld	a4,0(a5)
    8000588e:	9736                	add	a4,a4,a3
    80005890:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005894:	6398                	ld	a4,0(a5)
    80005896:	9736                	add	a4,a4,a3
    80005898:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000589c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800058a0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800058a4:	97aa                	add	a5,a5,a0
    800058a6:	4705                	li	a4,1
    800058a8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800058ac:	0005e517          	auipc	a0,0x5e
    800058b0:	bc450513          	addi	a0,a0,-1084 # 80063470 <disk+0x18>
    800058b4:	f0cfc0ef          	jal	80001fc0 <wakeup>
}
    800058b8:	60a2                	ld	ra,8(sp)
    800058ba:	6402                	ld	s0,0(sp)
    800058bc:	0141                	addi	sp,sp,16
    800058be:	8082                	ret
    panic("free_desc 1");
    800058c0:	00002517          	auipc	a0,0x2
    800058c4:	d6050513          	addi	a0,a0,-672 # 80007620 <etext+0x620>
    800058c8:	f5dfa0ef          	jal	80000824 <panic>
    panic("free_desc 2");
    800058cc:	00002517          	auipc	a0,0x2
    800058d0:	d6450513          	addi	a0,a0,-668 # 80007630 <etext+0x630>
    800058d4:	f51fa0ef          	jal	80000824 <panic>

00000000800058d8 <virtio_disk_init>:
{
    800058d8:	1101                	addi	sp,sp,-32
    800058da:	ec06                	sd	ra,24(sp)
    800058dc:	e822                	sd	s0,16(sp)
    800058de:	e426                	sd	s1,8(sp)
    800058e0:	e04a                	sd	s2,0(sp)
    800058e2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800058e4:	00002597          	auipc	a1,0x2
    800058e8:	d5c58593          	addi	a1,a1,-676 # 80007640 <etext+0x640>
    800058ec:	0005e517          	auipc	a0,0x5e
    800058f0:	c9450513          	addi	a0,a0,-876 # 80063580 <disk+0x128>
    800058f4:	aaafb0ef          	jal	80000b9e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800058f8:	100017b7          	lui	a5,0x10001
    800058fc:	4398                	lw	a4,0(a5)
    800058fe:	2701                	sext.w	a4,a4
    80005900:	747277b7          	lui	a5,0x74727
    80005904:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005908:	14f71863          	bne	a4,a5,80005a58 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000590c:	100017b7          	lui	a5,0x10001
    80005910:	43dc                	lw	a5,4(a5)
    80005912:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005914:	4709                	li	a4,2
    80005916:	14e79163          	bne	a5,a4,80005a58 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000591a:	100017b7          	lui	a5,0x10001
    8000591e:	479c                	lw	a5,8(a5)
    80005920:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005922:	12e79b63          	bne	a5,a4,80005a58 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005926:	100017b7          	lui	a5,0x10001
    8000592a:	47d8                	lw	a4,12(a5)
    8000592c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000592e:	554d47b7          	lui	a5,0x554d4
    80005932:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005936:	12f71163          	bne	a4,a5,80005a58 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000593a:	100017b7          	lui	a5,0x10001
    8000593e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005942:	4705                	li	a4,1
    80005944:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005946:	470d                	li	a4,3
    80005948:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000594a:	10001737          	lui	a4,0x10001
    8000594e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005950:	c7ffe6b7          	lui	a3,0xc7ffe
    80005954:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47f9b1c7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005958:	8f75                	and	a4,a4,a3
    8000595a:	100016b7          	lui	a3,0x10001
    8000595e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005960:	472d                	li	a4,11
    80005962:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005964:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005968:	439c                	lw	a5,0(a5)
    8000596a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000596e:	8ba1                	andi	a5,a5,8
    80005970:	0e078a63          	beqz	a5,80005a64 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005974:	100017b7          	lui	a5,0x10001
    80005978:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000597c:	43fc                	lw	a5,68(a5)
    8000597e:	2781                	sext.w	a5,a5
    80005980:	0e079863          	bnez	a5,80005a70 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005984:	100017b7          	lui	a5,0x10001
    80005988:	5bdc                	lw	a5,52(a5)
    8000598a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000598c:	0e078863          	beqz	a5,80005a7c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005990:	471d                	li	a4,7
    80005992:	0ef77b63          	bgeu	a4,a5,80005a88 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005996:	9aefb0ef          	jal	80000b44 <kalloc>
    8000599a:	0005e497          	auipc	s1,0x5e
    8000599e:	abe48493          	addi	s1,s1,-1346 # 80063458 <disk>
    800059a2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800059a4:	9a0fb0ef          	jal	80000b44 <kalloc>
    800059a8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800059aa:	99afb0ef          	jal	80000b44 <kalloc>
    800059ae:	87aa                	mv	a5,a0
    800059b0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800059b2:	6088                	ld	a0,0(s1)
    800059b4:	0e050063          	beqz	a0,80005a94 <virtio_disk_init+0x1bc>
    800059b8:	0005e717          	auipc	a4,0x5e
    800059bc:	aa873703          	ld	a4,-1368(a4) # 80063460 <disk+0x8>
    800059c0:	cb71                	beqz	a4,80005a94 <virtio_disk_init+0x1bc>
    800059c2:	cbe9                	beqz	a5,80005a94 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    800059c4:	6605                	lui	a2,0x1
    800059c6:	4581                	li	a1,0
    800059c8:	b30fb0ef          	jal	80000cf8 <memset>
  memset(disk.avail, 0, PGSIZE);
    800059cc:	0005e497          	auipc	s1,0x5e
    800059d0:	a8c48493          	addi	s1,s1,-1396 # 80063458 <disk>
    800059d4:	6605                	lui	a2,0x1
    800059d6:	4581                	li	a1,0
    800059d8:	6488                	ld	a0,8(s1)
    800059da:	b1efb0ef          	jal	80000cf8 <memset>
  memset(disk.used, 0, PGSIZE);
    800059de:	6605                	lui	a2,0x1
    800059e0:	4581                	li	a1,0
    800059e2:	6888                	ld	a0,16(s1)
    800059e4:	b14fb0ef          	jal	80000cf8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800059e8:	100017b7          	lui	a5,0x10001
    800059ec:	4721                	li	a4,8
    800059ee:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800059f0:	4098                	lw	a4,0(s1)
    800059f2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800059f6:	40d8                	lw	a4,4(s1)
    800059f8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800059fc:	649c                	ld	a5,8(s1)
    800059fe:	0007869b          	sext.w	a3,a5
    80005a02:	10001737          	lui	a4,0x10001
    80005a06:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005a0a:	9781                	srai	a5,a5,0x20
    80005a0c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005a10:	689c                	ld	a5,16(s1)
    80005a12:	0007869b          	sext.w	a3,a5
    80005a16:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005a1a:	9781                	srai	a5,a5,0x20
    80005a1c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005a20:	4785                	li	a5,1
    80005a22:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005a24:	00f48c23          	sb	a5,24(s1)
    80005a28:	00f48ca3          	sb	a5,25(s1)
    80005a2c:	00f48d23          	sb	a5,26(s1)
    80005a30:	00f48da3          	sb	a5,27(s1)
    80005a34:	00f48e23          	sb	a5,28(s1)
    80005a38:	00f48ea3          	sb	a5,29(s1)
    80005a3c:	00f48f23          	sb	a5,30(s1)
    80005a40:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005a44:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a48:	07272823          	sw	s2,112(a4)
}
    80005a4c:	60e2                	ld	ra,24(sp)
    80005a4e:	6442                	ld	s0,16(sp)
    80005a50:	64a2                	ld	s1,8(sp)
    80005a52:	6902                	ld	s2,0(sp)
    80005a54:	6105                	addi	sp,sp,32
    80005a56:	8082                	ret
    panic("could not find virtio disk");
    80005a58:	00002517          	auipc	a0,0x2
    80005a5c:	bf850513          	addi	a0,a0,-1032 # 80007650 <etext+0x650>
    80005a60:	dc5fa0ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005a64:	00002517          	auipc	a0,0x2
    80005a68:	c0c50513          	addi	a0,a0,-1012 # 80007670 <etext+0x670>
    80005a6c:	db9fa0ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    80005a70:	00002517          	auipc	a0,0x2
    80005a74:	c2050513          	addi	a0,a0,-992 # 80007690 <etext+0x690>
    80005a78:	dadfa0ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    80005a7c:	00002517          	auipc	a0,0x2
    80005a80:	c3450513          	addi	a0,a0,-972 # 800076b0 <etext+0x6b0>
    80005a84:	da1fa0ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    80005a88:	00002517          	auipc	a0,0x2
    80005a8c:	c4850513          	addi	a0,a0,-952 # 800076d0 <etext+0x6d0>
    80005a90:	d95fa0ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    80005a94:	00002517          	auipc	a0,0x2
    80005a98:	c5c50513          	addi	a0,a0,-932 # 800076f0 <etext+0x6f0>
    80005a9c:	d89fa0ef          	jal	80000824 <panic>

0000000080005aa0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005aa0:	711d                	addi	sp,sp,-96
    80005aa2:	ec86                	sd	ra,88(sp)
    80005aa4:	e8a2                	sd	s0,80(sp)
    80005aa6:	e4a6                	sd	s1,72(sp)
    80005aa8:	e0ca                	sd	s2,64(sp)
    80005aaa:	fc4e                	sd	s3,56(sp)
    80005aac:	f852                	sd	s4,48(sp)
    80005aae:	f456                	sd	s5,40(sp)
    80005ab0:	f05a                	sd	s6,32(sp)
    80005ab2:	ec5e                	sd	s7,24(sp)
    80005ab4:	e862                	sd	s8,16(sp)
    80005ab6:	1080                	addi	s0,sp,96
    80005ab8:	89aa                	mv	s3,a0
    80005aba:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005abc:	00c52b83          	lw	s7,12(a0)
    80005ac0:	001b9b9b          	slliw	s7,s7,0x1
    80005ac4:	1b82                	slli	s7,s7,0x20
    80005ac6:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005aca:	0005e517          	auipc	a0,0x5e
    80005ace:	ab650513          	addi	a0,a0,-1354 # 80063580 <disk+0x128>
    80005ad2:	956fb0ef          	jal	80000c28 <acquire>
  for(int i = 0; i < NUM; i++){
    80005ad6:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005ad8:	0005ea97          	auipc	s5,0x5e
    80005adc:	980a8a93          	addi	s5,s5,-1664 # 80063458 <disk>
  for(int i = 0; i < 3; i++){
    80005ae0:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005ae2:	5c7d                	li	s8,-1
    80005ae4:	a095                	j	80005b48 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005ae6:	00fa8733          	add	a4,s5,a5
    80005aea:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005aee:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005af0:	0207c563          	bltz	a5,80005b1a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005af4:	2905                	addiw	s2,s2,1
    80005af6:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005af8:	05490c63          	beq	s2,s4,80005b50 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    80005afc:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005afe:	0005e717          	auipc	a4,0x5e
    80005b02:	95a70713          	addi	a4,a4,-1702 # 80063458 <disk>
    80005b06:	4781                	li	a5,0
    if(disk.free[i]){
    80005b08:	01874683          	lbu	a3,24(a4)
    80005b0c:	fee9                	bnez	a3,80005ae6 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    80005b0e:	2785                	addiw	a5,a5,1
    80005b10:	0705                	addi	a4,a4,1
    80005b12:	fe979be3          	bne	a5,s1,80005b08 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005b16:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80005b1a:	01205d63          	blez	s2,80005b34 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b1e:	fa042503          	lw	a0,-96(s0)
    80005b22:	d41ff0ef          	jal	80005862 <free_desc>
      for(int j = 0; j < i; j++)
    80005b26:	4785                	li	a5,1
    80005b28:	0127d663          	bge	a5,s2,80005b34 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b2c:	fa442503          	lw	a0,-92(s0)
    80005b30:	d33ff0ef          	jal	80005862 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005b34:	0005e597          	auipc	a1,0x5e
    80005b38:	a4c58593          	addi	a1,a1,-1460 # 80063580 <disk+0x128>
    80005b3c:	0005e517          	auipc	a0,0x5e
    80005b40:	93450513          	addi	a0,a0,-1740 # 80063470 <disk+0x18>
    80005b44:	c30fc0ef          	jal	80001f74 <sleep>
  for(int i = 0; i < 3; i++){
    80005b48:	fa040613          	addi	a2,s0,-96
    80005b4c:	4901                	li	s2,0
    80005b4e:	b77d                	j	80005afc <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b50:	fa042503          	lw	a0,-96(s0)
    80005b54:	00451693          	slli	a3,a0,0x4

  if(write)
    80005b58:	0005e797          	auipc	a5,0x5e
    80005b5c:	90078793          	addi	a5,a5,-1792 # 80063458 <disk>
    80005b60:	00451713          	slli	a4,a0,0x4
    80005b64:	0a070713          	addi	a4,a4,160
    80005b68:	973e                	add	a4,a4,a5
    80005b6a:	01603633          	snez	a2,s6
    80005b6e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005b70:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005b74:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005b78:	6398                	ld	a4,0(a5)
    80005b7a:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b7c:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005b80:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005b82:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005b84:	6390                	ld	a2,0(a5)
    80005b86:	00d60833          	add	a6,a2,a3
    80005b8a:	4741                	li	a4,16
    80005b8c:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005b90:	4585                	li	a1,1
    80005b92:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005b96:	fa442703          	lw	a4,-92(s0)
    80005b9a:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005b9e:	0712                	slli	a4,a4,0x4
    80005ba0:	963a                	add	a2,a2,a4
    80005ba2:	05898813          	addi	a6,s3,88
    80005ba6:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005baa:	0007b883          	ld	a7,0(a5)
    80005bae:	9746                	add	a4,a4,a7
    80005bb0:	40000613          	li	a2,1024
    80005bb4:	c710                	sw	a2,8(a4)
  if(write)
    80005bb6:	001b3613          	seqz	a2,s6
    80005bba:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005bbe:	8e4d                	or	a2,a2,a1
    80005bc0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005bc4:	fa842603          	lw	a2,-88(s0)
    80005bc8:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005bcc:	00451813          	slli	a6,a0,0x4
    80005bd0:	02080813          	addi	a6,a6,32
    80005bd4:	983e                	add	a6,a6,a5
    80005bd6:	577d                	li	a4,-1
    80005bd8:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005bdc:	0612                	slli	a2,a2,0x4
    80005bde:	98b2                	add	a7,a7,a2
    80005be0:	03068713          	addi	a4,a3,48
    80005be4:	973e                	add	a4,a4,a5
    80005be6:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005bea:	6398                	ld	a4,0(a5)
    80005bec:	9732                	add	a4,a4,a2
    80005bee:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005bf0:	4689                	li	a3,2
    80005bf2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005bf6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005bfa:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005bfe:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005c02:	6794                	ld	a3,8(a5)
    80005c04:	0026d703          	lhu	a4,2(a3)
    80005c08:	8b1d                	andi	a4,a4,7
    80005c0a:	0706                	slli	a4,a4,0x1
    80005c0c:	96ba                	add	a3,a3,a4
    80005c0e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005c12:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005c16:	6798                	ld	a4,8(a5)
    80005c18:	00275783          	lhu	a5,2(a4)
    80005c1c:	2785                	addiw	a5,a5,1
    80005c1e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005c22:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005c26:	100017b7          	lui	a5,0x10001
    80005c2a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005c2e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005c32:	0005e917          	auipc	s2,0x5e
    80005c36:	94e90913          	addi	s2,s2,-1714 # 80063580 <disk+0x128>
  while(b->disk == 1) {
    80005c3a:	84ae                	mv	s1,a1
    80005c3c:	00b79a63          	bne	a5,a1,80005c50 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005c40:	85ca                	mv	a1,s2
    80005c42:	854e                	mv	a0,s3
    80005c44:	b30fc0ef          	jal	80001f74 <sleep>
  while(b->disk == 1) {
    80005c48:	0049a783          	lw	a5,4(s3)
    80005c4c:	fe978ae3          	beq	a5,s1,80005c40 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005c50:	fa042903          	lw	s2,-96(s0)
    80005c54:	00491713          	slli	a4,s2,0x4
    80005c58:	02070713          	addi	a4,a4,32
    80005c5c:	0005d797          	auipc	a5,0x5d
    80005c60:	7fc78793          	addi	a5,a5,2044 # 80063458 <disk>
    80005c64:	97ba                	add	a5,a5,a4
    80005c66:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005c6a:	0005d997          	auipc	s3,0x5d
    80005c6e:	7ee98993          	addi	s3,s3,2030 # 80063458 <disk>
    80005c72:	00491713          	slli	a4,s2,0x4
    80005c76:	0009b783          	ld	a5,0(s3)
    80005c7a:	97ba                	add	a5,a5,a4
    80005c7c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005c80:	854a                	mv	a0,s2
    80005c82:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005c86:	bddff0ef          	jal	80005862 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005c8a:	8885                	andi	s1,s1,1
    80005c8c:	f0fd                	bnez	s1,80005c72 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005c8e:	0005e517          	auipc	a0,0x5e
    80005c92:	8f250513          	addi	a0,a0,-1806 # 80063580 <disk+0x128>
    80005c96:	826fb0ef          	jal	80000cbc <release>
}
    80005c9a:	60e6                	ld	ra,88(sp)
    80005c9c:	6446                	ld	s0,80(sp)
    80005c9e:	64a6                	ld	s1,72(sp)
    80005ca0:	6906                	ld	s2,64(sp)
    80005ca2:	79e2                	ld	s3,56(sp)
    80005ca4:	7a42                	ld	s4,48(sp)
    80005ca6:	7aa2                	ld	s5,40(sp)
    80005ca8:	7b02                	ld	s6,32(sp)
    80005caa:	6be2                	ld	s7,24(sp)
    80005cac:	6c42                	ld	s8,16(sp)
    80005cae:	6125                	addi	sp,sp,96
    80005cb0:	8082                	ret

0000000080005cb2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005cb2:	1101                	addi	sp,sp,-32
    80005cb4:	ec06                	sd	ra,24(sp)
    80005cb6:	e822                	sd	s0,16(sp)
    80005cb8:	e426                	sd	s1,8(sp)
    80005cba:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005cbc:	0005d497          	auipc	s1,0x5d
    80005cc0:	79c48493          	addi	s1,s1,1948 # 80063458 <disk>
    80005cc4:	0005e517          	auipc	a0,0x5e
    80005cc8:	8bc50513          	addi	a0,a0,-1860 # 80063580 <disk+0x128>
    80005ccc:	f5dfa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005cd0:	100017b7          	lui	a5,0x10001
    80005cd4:	53bc                	lw	a5,96(a5)
    80005cd6:	8b8d                	andi	a5,a5,3
    80005cd8:	10001737          	lui	a4,0x10001
    80005cdc:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005cde:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005ce2:	689c                	ld	a5,16(s1)
    80005ce4:	0204d703          	lhu	a4,32(s1)
    80005ce8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005cec:	04f70863          	beq	a4,a5,80005d3c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005cf0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005cf4:	6898                	ld	a4,16(s1)
    80005cf6:	0204d783          	lhu	a5,32(s1)
    80005cfa:	8b9d                	andi	a5,a5,7
    80005cfc:	078e                	slli	a5,a5,0x3
    80005cfe:	97ba                	add	a5,a5,a4
    80005d00:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005d02:	00479713          	slli	a4,a5,0x4
    80005d06:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005d0a:	9726                	add	a4,a4,s1
    80005d0c:	01074703          	lbu	a4,16(a4)
    80005d10:	e329                	bnez	a4,80005d52 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005d12:	0792                	slli	a5,a5,0x4
    80005d14:	02078793          	addi	a5,a5,32
    80005d18:	97a6                	add	a5,a5,s1
    80005d1a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005d1c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005d20:	aa0fc0ef          	jal	80001fc0 <wakeup>

    disk.used_idx += 1;
    80005d24:	0204d783          	lhu	a5,32(s1)
    80005d28:	2785                	addiw	a5,a5,1
    80005d2a:	17c2                	slli	a5,a5,0x30
    80005d2c:	93c1                	srli	a5,a5,0x30
    80005d2e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005d32:	6898                	ld	a4,16(s1)
    80005d34:	00275703          	lhu	a4,2(a4)
    80005d38:	faf71ce3          	bne	a4,a5,80005cf0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005d3c:	0005e517          	auipc	a0,0x5e
    80005d40:	84450513          	addi	a0,a0,-1980 # 80063580 <disk+0x128>
    80005d44:	f79fa0ef          	jal	80000cbc <release>
}
    80005d48:	60e2                	ld	ra,24(sp)
    80005d4a:	6442                	ld	s0,16(sp)
    80005d4c:	64a2                	ld	s1,8(sp)
    80005d4e:	6105                	addi	sp,sp,32
    80005d50:	8082                	ret
      panic("virtio_disk_intr status");
    80005d52:	00002517          	auipc	a0,0x2
    80005d56:	9b650513          	addi	a0,a0,-1610 # 80007708 <etext+0x708>
    80005d5a:	acbfa0ef          	jal	80000824 <panic>
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
    8000609a:	9282                	jalr	t0

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
