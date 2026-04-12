
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000c117          	auipc	sp,0xc
    80000004:	81813103          	ld	sp,-2024(sp) # 8000b818 <_GLOBAL_OFFSET_TABLE_+0x8>
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

// Machine-mode Interrupt Enable
#define MIE_STIE (1L << 5) // supervisor timer
static inline uint64 r_mie() {
  uint64 x;
  asm volatile("csrr %0, mie" : "=r"(x));
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
  return x;
}

static inline void w_mie(uint64 x) { asm volatile("csrw mie, %0" : : "r"(x)); }
    8000002c:	30479073          	csrw	mie,a5

// Machine Environment Configuration Register
static inline uint64 r_menvcfg() {
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4
  return x;
}

static inline void w_menvcfg(uint64 x) {
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    8000003a:	30a79073          	csrw	0x30a,a5
  asm volatile("csrw mcounteren, %0" : : "r"(x));
}

static inline uint64 r_mcounteren() {
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r"(x));
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r"(x));
    80000046:	30679073          	csrw	mcounteren,a5
}

// machine-mode cycle counter
static inline uint64 r_time() {
  uint64 x;
  asm volatile("csrr %0, time" : "=r"(x));
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
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
  asm volatile("csrr %0, mstatus" : "=r"(x));
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ff96b97>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r"(x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r"(x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	e2a78793          	addi	a5,a5,-470 # 80000eae <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r"(x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r"(x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r"(x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r"(x));
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a6:	2207e793          	ori	a5,a5,544
static inline void w_sie(uint64 x) { asm volatile("csrw sie, %0" : : "r"(x)); }
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r"(x));
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
  uint64 x;
  asm volatile("mv %0, tp" : "=r"(x));
  return x;
}

static inline void w_tp(uint64 x) { asm volatile("mv tp, %0" : : "r"(x)); }
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
    8000011a:	33e020ef          	jal	80002458 <either_copyin>
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
    80000192:	00013517          	auipc	a0,0x13
    80000196:	6ce50513          	addi	a0,a0,1742 # 80013860 <cons>
    8000019a:	28f000ef          	jal	80000c28 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	00013497          	auipc	s1,0x13
    800001a2:	6c248493          	addi	s1,s1,1730 # 80013860 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	00013917          	auipc	s2,0x13
    800001aa:	75290913          	addi	s2,s2,1874 # 800138f8 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	7cc010ef          	jal	8000198a <myproc>
    800001c2:	12c020ef          	jal	800022ee <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	6cf010ef          	jal	8000209a <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00013717          	auipc	a4,0x13
    800001e2:	68270713          	addi	a4,a4,1666 # 80013860 <cons>
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
    80000210:	1fe020ef          	jal	8000240e <either_copyout>
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
    80000228:	00013517          	auipc	a0,0x13
    8000022c:	63850513          	addi	a0,a0,1592 # 80013860 <cons>
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
    8000024e:	00013717          	auipc	a4,0x13
    80000252:	6af72523          	sw	a5,1706(a4) # 800138f8 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	00013517          	auipc	a0,0x13
    80000268:	5fc50513          	addi	a0,a0,1532 # 80013860 <cons>
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
    800002b8:	00013517          	auipc	a0,0x13
    800002bc:	5a850513          	addi	a0,a0,1448 # 80013860 <cons>
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
    800002da:	1c8020ef          	jal	800024a2 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	00013517          	auipc	a0,0x13
    800002e2:	58250513          	addi	a0,a0,1410 # 80013860 <cons>
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
    800002fc:	00013717          	auipc	a4,0x13
    80000300:	56470713          	addi	a4,a4,1380 # 80013860 <cons>
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
    80000322:	00013717          	auipc	a4,0x13
    80000326:	53e70713          	addi	a4,a4,1342 # 80013860 <cons>
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
    8000034c:	00013717          	auipc	a4,0x13
    80000350:	5ac72703          	lw	a4,1452(a4) # 800138f8 <cons+0x98>
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	08000713          	li	a4,128
    8000035a:	f8e792e3          	bne	a5,a4,800002de <consoleintr+0x32>
    8000035e:	a075                	j	8000040a <consoleintr+0x15e>
    80000360:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000362:	00013717          	auipc	a4,0x13
    80000366:	4fe70713          	addi	a4,a4,1278 # 80013860 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000372:	00013497          	auipc	s1,0x13
    80000376:	4ee48493          	addi	s1,s1,1262 # 80013860 <cons>
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
    800003b4:	00013717          	auipc	a4,0x13
    800003b8:	4ac70713          	addi	a4,a4,1196 # 80013860 <cons>
    800003bc:	0a072783          	lw	a5,160(a4)
    800003c0:	09c72703          	lw	a4,156(a4)
    800003c4:	f0f70de3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003c8:	37fd                	addiw	a5,a5,-1
    800003ca:	00013717          	auipc	a4,0x13
    800003ce:	52f72b23          	sw	a5,1334(a4) # 80013900 <cons+0xa0>
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
    800003e8:	00013797          	auipc	a5,0x13
    800003ec:	47878793          	addi	a5,a5,1144 # 80013860 <cons>
    800003f0:	0a07a703          	lw	a4,160(a5)
    800003f4:	0017069b          	addiw	a3,a4,1
    800003f8:	8636                	mv	a2,a3
    800003fa:	0ad7a023          	sw	a3,160(a5)
    800003fe:	07f77713          	andi	a4,a4,127
    80000402:	97ba                	add	a5,a5,a4
    80000404:	4729                	li	a4,10
    80000406:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040a:	00013797          	auipc	a5,0x13
    8000040e:	4ec7a923          	sw	a2,1266(a5) # 800138fc <cons+0x9c>
        wakeup(&cons.r);
    80000412:	00013517          	auipc	a0,0x13
    80000416:	4e650513          	addi	a0,a0,1254 # 800138f8 <cons+0x98>
    8000041a:	4cd010ef          	jal	800020e6 <wakeup>
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
    80000428:	00008597          	auipc	a1,0x8
    8000042c:	bd858593          	addi	a1,a1,-1064 # 80008000 <etext>
    80000430:	00013517          	auipc	a0,0x13
    80000434:	43050513          	addi	a0,a0,1072 # 80013860 <cons>
    80000438:	766000ef          	jal	80000b9e <initlock>

  uartinit();
    8000043c:	448000ef          	jal	80000884 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	00066797          	auipc	a5,0x66
    80000444:	69078793          	addi	a5,a5,1680 # 80066ad0 <devsw>
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
    8000047e:	00008817          	auipc	a6,0x8
    80000482:	2c280813          	addi	a6,a6,706 # 80008740 <digits>
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
    80000518:	0000b797          	auipc	a5,0xb
    8000051c:	31c7a783          	lw	a5,796(a5) # 8000b834 <panicking>
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
    8000055e:	00013517          	auipc	a0,0x13
    80000562:	3aa50513          	addi	a0,a0,938 # 80013908 <pr>
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
    800006d2:	00008c97          	auipc	s9,0x8
    800006d6:	06ec8c93          	addi	s9,s9,110 # 80008740 <digits>
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
    80000732:	00008a17          	auipc	s4,0x8
    80000736:	8d6a0a13          	addi	s4,s4,-1834 # 80008008 <etext+0x8>
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
    8000075a:	0000b797          	auipc	a5,0xb
    8000075e:	0da7a783          	lw	a5,218(a5) # 8000b834 <panicking>
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
    80000784:	00013517          	auipc	a0,0x13
    80000788:	18450513          	addi	a0,a0,388 # 80013908 <pr>
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
    80000834:	0000b797          	auipc	a5,0xb
    80000838:	0097a023          	sw	s1,0(a5) # 8000b834 <panicking>
  printf("panic: ");
    8000083c:	00007517          	auipc	a0,0x7
    80000840:	7dc50513          	addi	a0,a0,2012 # 80008018 <etext+0x18>
    80000844:	cb7ff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000848:	85ca                	mv	a1,s2
    8000084a:	00007517          	auipc	a0,0x7
    8000084e:	7d650513          	addi	a0,a0,2006 # 80008020 <etext+0x20>
    80000852:	ca9ff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000856:	0000b797          	auipc	a5,0xb
    8000085a:	fc97ad23          	sw	s1,-38(a5) # 8000b830 <panicked>
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
    80000868:	00007597          	auipc	a1,0x7
    8000086c:	7c058593          	addi	a1,a1,1984 # 80008028 <etext+0x28>
    80000870:	00013517          	auipc	a0,0x13
    80000874:	09850513          	addi	a0,a0,152 # 80013908 <pr>
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
    800008be:	00007597          	auipc	a1,0x7
    800008c2:	77258593          	addi	a1,a1,1906 # 80008030 <etext+0x30>
    800008c6:	00013517          	auipc	a0,0x13
    800008ca:	05a50513          	addi	a0,a0,90 # 80013920 <tx_lock>
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
    800008ea:	00013517          	auipc	a0,0x13
    800008ee:	03650513          	addi	a0,a0,54 # 80013920 <tx_lock>
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
    80000908:	0000b497          	auipc	s1,0xb
    8000090c:	f3448493          	addi	s1,s1,-204 # 8000b83c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000910:	00013997          	auipc	s3,0x13
    80000914:	01098993          	addi	s3,s3,16 # 80013920 <tx_lock>
    80000918:	0000b917          	auipc	s2,0xb
    8000091c:	f2090913          	addi	s2,s2,-224 # 8000b838 <tx_chan>
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
    8000092c:	76e010ef          	jal	8000209a <sleep>
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
    80000956:	00013517          	auipc	a0,0x13
    8000095a:	fca50513          	addi	a0,a0,-54 # 80013920 <tx_lock>
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
    8000097a:	0000b797          	auipc	a5,0xb
    8000097e:	eba7a783          	lw	a5,-326(a5) # 8000b834 <panicking>
    80000982:	cf95                	beqz	a5,800009be <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000984:	0000b797          	auipc	a5,0xb
    80000988:	eac7a783          	lw	a5,-340(a5) # 8000b830 <panicked>
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
    800009aa:	0000b797          	auipc	a5,0xb
    800009ae:	e8a7a783          	lw	a5,-374(a5) # 8000b834 <panicking>
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
    80000a06:	00013517          	auipc	a0,0x13
    80000a0a:	f1a50513          	addi	a0,a0,-230 # 80013920 <tx_lock>
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
    80000a20:	00013517          	auipc	a0,0x13
    80000a24:	f0050513          	addi	a0,a0,-256 # 80013920 <tx_lock>
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
    80000a3c:	0000b797          	auipc	a5,0xb
    80000a40:	e007a023          	sw	zero,-512(a5) # 8000b83c <tx_busy>
    wakeup(&tx_chan);
    80000a44:	0000b517          	auipc	a0,0xb
    80000a48:	df450513          	addi	a0,a0,-524 # 8000b838 <tx_chan>
    80000a4c:	69a010ef          	jal	800020e6 <wakeup>
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
    80000a68:	00067797          	auipc	a5,0x67
    80000a6c:	20078793          	addi	a5,a5,512 # 80067c68 <end>
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
    80000a92:	00013917          	auipc	s2,0x13
    80000a96:	ea690913          	addi	s2,s2,-346 # 80013938 <kmem>
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
    80000abc:	00007517          	auipc	a0,0x7
    80000ac0:	57c50513          	addi	a0,a0,1404 # 80008038 <etext+0x38>
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
    80000b18:	00007597          	auipc	a1,0x7
    80000b1c:	52858593          	addi	a1,a1,1320 # 80008040 <etext+0x40>
    80000b20:	00013517          	auipc	a0,0x13
    80000b24:	e1850513          	addi	a0,a0,-488 # 80013938 <kmem>
    80000b28:	076000ef          	jal	80000b9e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00067517          	auipc	a0,0x67
    80000b34:	13850513          	addi	a0,a0,312 # 80067c68 <end>
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
    80000b4e:	00013517          	auipc	a0,0x13
    80000b52:	dea50513          	addi	a0,a0,-534 # 80013938 <kmem>
    80000b56:	0d2000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b5a:	00013497          	auipc	s1,0x13
    80000b5e:	df64b483          	ld	s1,-522(s1) # 80013950 <kmem+0x18>
  if(r)
    80000b62:	c49d                	beqz	s1,80000b90 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b64:	609c                	ld	a5,0(s1)
    80000b66:	00013717          	auipc	a4,0x13
    80000b6a:	def73523          	sd	a5,-534(a4) # 80013950 <kmem+0x18>
  release(&kmem.lock);
    80000b6e:	00013517          	auipc	a0,0x13
    80000b72:	dca50513          	addi	a0,a0,-566 # 80013938 <kmem>
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
    80000b90:	00013517          	auipc	a0,0x13
    80000b94:	da850513          	addi	a0,a0,-600 # 80013938 <kmem>
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
    80000bce:	59d000ef          	jal	8000196a <mycpu>
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
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000bee:	100027f3          	csrr	a5,sstatus
    80000bf2:	84be                	mv	s1,a5
    80000bf4:	100027f3          	csrr	a5,sstatus
static inline void intr_off() { w_sstatus(r_sstatus() & ~SSTATUS_SIE); }
    80000bf8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80000bfa:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000bfe:	56d000ef          	jal	8000196a <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	565000ef          	jal	8000196a <mycpu>
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
    80000c1a:	551000ef          	jal	8000196a <mycpu>
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
    80000c50:	51b000ef          	jal	8000196a <mycpu>
    80000c54:	e888                	sd	a0,16(s1)
}
    80000c56:	60e2                	ld	ra,24(sp)
    80000c58:	6442                	ld	s0,16(sp)
    80000c5a:	64a2                	ld	s1,8(sp)
    80000c5c:	6105                	addi	sp,sp,32
    80000c5e:	8082                	ret
    panic("acquire");
    80000c60:	00007517          	auipc	a0,0x7
    80000c64:	3e850513          	addi	a0,a0,1000 # 80008048 <etext+0x48>
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
    80000c74:	4f7000ef          	jal	8000196a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r"(x));
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
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000c90:	100027f3          	csrr	a5,sstatus
static inline void intr_on() { w_sstatus(r_sstatus() | SSTATUS_SIE); }
    80000c94:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80000c98:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c9c:	60a2                	ld	ra,8(sp)
    80000c9e:	6402                	ld	s0,0(sp)
    80000ca0:	0141                	addi	sp,sp,16
    80000ca2:	8082                	ret
    panic("pop_off - interruptible");
    80000ca4:	00007517          	auipc	a0,0x7
    80000ca8:	3ac50513          	addi	a0,a0,940 # 80008050 <etext+0x50>
    80000cac:	b79ff0ef          	jal	80000824 <panic>
    panic("pop_off");
    80000cb0:	00007517          	auipc	a0,0x7
    80000cb4:	3b850513          	addi	a0,a0,952 # 80008068 <etext+0x68>
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
    80000cec:	00007517          	auipc	a0,0x7
    80000cf0:	38450513          	addi	a0,a0,900 # 80008070 <etext+0x70>
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
    80000eb6:	2a1000ef          	jal	80001956 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eba:	0000b717          	auipc	a4,0xb
    80000ebe:	98670713          	addi	a4,a4,-1658 # 8000b840 <started>
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
    80000ece:	289000ef          	jal	80001956 <cpuid>
    80000ed2:	85aa                	mv	a1,a0
    80000ed4:	00007517          	auipc	a0,0x7
    80000ed8:	1c450513          	addi	a0,a0,452 # 80008098 <etext+0x98>
    80000edc:	e1eff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000ee0:	080000ef          	jal	80000f60 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee4:	6f8010ef          	jal	800025dc <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee8:	571040ef          	jal	80005c58 <plicinithart>
  }

  scheduler();        
    80000eec:	783000ef          	jal	80001e6e <scheduler>
    consoleinit();
    80000ef0:	d30ff0ef          	jal	80000420 <consoleinit>
    printfinit();
    80000ef4:	96dff0ef          	jal	80000860 <printfinit>
    printf("\n");
    80000ef8:	00007517          	auipc	a0,0x7
    80000efc:	18050513          	addi	a0,a0,384 # 80008078 <etext+0x78>
    80000f00:	dfaff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000f04:	00007517          	auipc	a0,0x7
    80000f08:	17c50513          	addi	a0,a0,380 # 80008080 <etext+0x80>
    80000f0c:	deeff0ef          	jal	800004fa <printf>
    printf("\n");
    80000f10:	00007517          	auipc	a0,0x7
    80000f14:	16850513          	addi	a0,a0,360 # 80008078 <etext+0x78>
    80000f18:	de2ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000f1c:	bf5ff0ef          	jal	80000b10 <kinit>
    kvminit();       // create kernel page table
    80000f20:	2cc000ef          	jal	800011ec <kvminit>
    kvminithart();   // turn on paging
    80000f24:	03c000ef          	jal	80000f60 <kvminithart>
    procinit();      // process table
    80000f28:	177000ef          	jal	8000189e <procinit>
    trapinit();      // trap vectors
    80000f2c:	68c010ef          	jal	800025b8 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f30:	6ac010ef          	jal	800025dc <trapinithart>
    plicinit();      // set up interrupt controller
    80000f34:	50b040ef          	jal	80005c3e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f38:	521040ef          	jal	80005c58 <plicinithart>
    binit();         // buffer cache
    80000f3c:	390020ef          	jal	800032cc <binit>
    iinit();         // inode table
    80000f40:	0e3020ef          	jal	80003822 <iinit>
    fileinit();      // file table
    80000f44:	00f030ef          	jal	80004752 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	601040ef          	jal	80005d48 <virtio_disk_init>
    userinit();      // first user process
    80000f4c:	551000ef          	jal	80001c9c <userinit>
    __sync_synchronize();
    80000f50:	0330000f          	fence	rw,rw
    started = 1;
    80000f54:	4785                	li	a5,1
    80000f56:	0000b717          	auipc	a4,0xb
    80000f5a:	8ef72523          	sw	a5,-1814(a4) # 8000b840 <started>
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
}

// flush the TLB.
static inline void sfence_vma() {
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f68:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f6c:	0000b797          	auipc	a5,0xb
    80000f70:	8dc7b783          	ld	a5,-1828(a5) # 8000b848 <kernel_pagetable>
    80000f74:	83b1                	srli	a5,a5,0xc
    80000f76:	577d                	li	a4,-1
    80000f78:	177e                	slli	a4,a4,0x3f
    80000f7a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
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
    80000ff2:	00007517          	auipc	a0,0x7
    80000ff6:	0be50513          	addi	a0,a0,190 # 800080b0 <etext+0xb0>
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
    800010ca:	00007517          	auipc	a0,0x7
    800010ce:	fee50513          	addi	a0,a0,-18 # 800080b8 <etext+0xb8>
    800010d2:	f52ff0ef          	jal	80000824 <panic>
    panic("mappages: size not aligned");
    800010d6:	00007517          	auipc	a0,0x7
    800010da:	00250513          	addi	a0,a0,2 # 800080d8 <etext+0xd8>
    800010de:	f46ff0ef          	jal	80000824 <panic>
    panic("mappages: size");
    800010e2:	00007517          	auipc	a0,0x7
    800010e6:	01650513          	addi	a0,a0,22 # 800080f8 <etext+0xf8>
    800010ea:	f3aff0ef          	jal	80000824 <panic>
      panic("mappages: remap");
    800010ee:	00007517          	auipc	a0,0x7
    800010f2:	01a50513          	addi	a0,a0,26 # 80008108 <etext+0x108>
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
    80001132:	00007517          	auipc	a0,0x7
    80001136:	fe650513          	addi	a0,a0,-26 # 80008118 <etext+0x118>
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
    8000118a:	80007697          	auipc	a3,0x80007
    8000118e:	e7668693          	addi	a3,a3,-394 # 8000 <_entry-0x7fff8000>
    80001192:	4605                	li	a2,1
    80001194:	067e                	slli	a2,a2,0x1f
    80001196:	85b2                	mv	a1,a2
    80001198:	8526                	mv	a0,s1
    8000119a:	f7dff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000119e:	4719                	li	a4,6
    800011a0:	00007697          	auipc	a3,0x7
    800011a4:	e6068693          	addi	a3,a3,-416 # 80008000 <etext>
    800011a8:	47c5                	li	a5,17
    800011aa:	07ee                	slli	a5,a5,0x1b
    800011ac:	40d786b3          	sub	a3,a5,a3
    800011b0:	00007617          	auipc	a2,0x7
    800011b4:	e5060613          	addi	a2,a2,-432 # 80008000 <etext>
    800011b8:	85b2                	mv	a1,a2
    800011ba:	8526                	mv	a0,s1
    800011bc:	f5bff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011c0:	4729                	li	a4,10
    800011c2:	6685                	lui	a3,0x1
    800011c4:	00006617          	auipc	a2,0x6
    800011c8:	e3c60613          	addi	a2,a2,-452 # 80007000 <_trampoline>
    800011cc:	040005b7          	lui	a1,0x4000
    800011d0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011d2:	05b2                	slli	a1,a1,0xc
    800011d4:	8526                	mv	a0,s1
    800011d6:	f41ff0ef          	jal	80001116 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011da:	8526                	mv	a0,s1
    800011dc:	61e000ef          	jal	800017fa <proc_mapstacks>
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
    800011f8:	0000a797          	auipc	a5,0xa
    800011fc:	64a7b823          	sd	a0,1616(a5) # 8000b848 <kernel_pagetable>
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
    80001268:	00007517          	auipc	a0,0x7
    8000126c:	eb850513          	addi	a0,a0,-328 # 80008120 <etext+0x120>
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
    800013be:	00007517          	auipc	a0,0x7
    800013c2:	d7a50513          	addi	a0,a0,-646 # 80008138 <etext+0x138>
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
    800014ec:	00007517          	auipc	a0,0x7
    800014f0:	c5c50513          	addi	a0,a0,-932 # 80008148 <etext+0x148>
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
    800015e0:	3aa000ef          	jal	8000198a <myproc>
  if (va >= p->sz)
    800015e4:	693c                	ld	a5,80(a0)
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
    80001632:	6ca8                	ld	a0,88(s1)
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

00000000800017a0 <krand>:

extern void forkret(void);

int rand_state = 1;

int krand(void) {
    800017a0:	1141                	addi	sp,sp,-16
    800017a2:	e406                	sd	ra,8(sp)
    800017a4:	e022                	sd	s0,0(sp)
    800017a6:	0800                	addi	s0,sp,16
  rand_state = (rand_state * 1664525 + 1013904223) % (431223);
    800017a8:	0000a697          	auipc	a3,0xa
    800017ac:	05c68693          	addi	a3,a3,92 # 8000b804 <rand_state>
    800017b0:	4298                	lw	a4,0(a3)
    800017b2:	001967b7          	lui	a5,0x196
    800017b6:	60d7879b          	addiw	a5,a5,1549 # 19660d <_entry-0x7fe699f3>
    800017ba:	02e787bb          	mulw	a5,a5,a4
    800017be:	3c6ef537          	lui	a0,0x3c6ef
    800017c2:	35f5051b          	addiw	a0,a0,863 # 3c6ef35f <_entry-0x43910ca1>
    800017c6:	9d3d                	addw	a0,a0,a5
    800017c8:	9b9fe7b7          	lui	a5,0x9b9fe
    800017cc:	f4578793          	addi	a5,a5,-187 # ffffffff9b9fdf45 <end+0xffffffff1b9962dd>
    800017d0:	02f507b3          	mul	a5,a0,a5
    800017d4:	9381                	srli	a5,a5,0x20
    800017d6:	9fa9                	addw	a5,a5,a0
    800017d8:	4127d79b          	sraiw	a5,a5,0x12
    800017dc:	41f5571b          	sraiw	a4,a0,0x1f
    800017e0:	9f99                	subw	a5,a5,a4
    800017e2:	00069737          	lui	a4,0x69
    800017e6:	4777071b          	addiw	a4,a4,1143 # 69477 <_entry-0x7ff96b89>
    800017ea:	02f707bb          	mulw	a5,a4,a5
    800017ee:	9d1d                	subw	a0,a0,a5
    800017f0:	c288                	sw	a0,0(a3)
  return rand_state;
}
    800017f2:	60a2                	ld	ra,8(sp)
    800017f4:	6402                	ld	s0,0(sp)
    800017f6:	0141                	addi	sp,sp,16
    800017f8:	8082                	ret

00000000800017fa <proc_mapstacks>:
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl) {
    800017fa:	711d                	addi	sp,sp,-96
    800017fc:	ec86                	sd	ra,88(sp)
    800017fe:	e8a2                	sd	s0,80(sp)
    80001800:	e4a6                	sd	s1,72(sp)
    80001802:	e0ca                	sd	s2,64(sp)
    80001804:	fc4e                	sd	s3,56(sp)
    80001806:	f852                	sd	s4,48(sp)
    80001808:	f456                	sd	s5,40(sp)
    8000180a:	f05a                	sd	s6,32(sp)
    8000180c:	ec5e                	sd	s7,24(sp)
    8000180e:	e862                	sd	s8,16(sp)
    80001810:	e466                	sd	s9,8(sp)
    80001812:	1080                	addi	s0,sp,96
    80001814:	8aaa                	mv	s5,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001816:	00012497          	auipc	s1,0x12
    8000181a:	57248493          	addi	s1,s1,1394 # 80013d88 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    8000181e:	8ca6                	mv	s9,s1
    80001820:	0fe3c7b7          	lui	a5,0xfe3c
    80001824:	07178793          	addi	a5,a5,113 # fe3c071 <_entry-0x701c3f8f>
    80001828:	70fe4937          	lui	s2,0x70fe4
    8000182c:	c0790913          	addi	s2,s2,-1017 # 70fe3c07 <_entry-0xf01c3f9>
    80001830:	1902                	slli	s2,s2,0x20
    80001832:	993e                	add	s2,s2,a5
    80001834:	040009b7          	lui	s3,0x4000
    80001838:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000183a:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000183c:	4c19                	li	s8,6
    8000183e:	6b85                	lui	s7,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    80001840:	220b8a13          	addi	s4,s7,544 # 1220 <_entry-0x7fffede0>
    80001844:	0005bb17          	auipc	s6,0x5b
    80001848:	d44b0b13          	addi	s6,s6,-700 # 8005c588 <tickslock>
    char *pa = kalloc();
    8000184c:	af8ff0ef          	jal	80000b44 <kalloc>
    80001850:	862a                	mv	a2,a0
    if (pa == 0)
    80001852:	c121                	beqz	a0,80001892 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    80001854:	419485b3          	sub	a1,s1,s9
    80001858:	8595                	srai	a1,a1,0x5
    8000185a:	032585b3          	mul	a1,a1,s2
    8000185e:	05b6                	slli	a1,a1,0xd
    80001860:	6789                	lui	a5,0x2
    80001862:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001864:	8762                	mv	a4,s8
    80001866:	86de                	mv	a3,s7
    80001868:	40b985b3          	sub	a1,s3,a1
    8000186c:	8556                	mv	a0,s5
    8000186e:	8a9ff0ef          	jal	80001116 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001872:	94d2                	add	s1,s1,s4
    80001874:	fd649ce3          	bne	s1,s6,8000184c <proc_mapstacks+0x52>
  }
}
    80001878:	60e6                	ld	ra,88(sp)
    8000187a:	6446                	ld	s0,80(sp)
    8000187c:	64a6                	ld	s1,72(sp)
    8000187e:	6906                	ld	s2,64(sp)
    80001880:	79e2                	ld	s3,56(sp)
    80001882:	7a42                	ld	s4,48(sp)
    80001884:	7aa2                	ld	s5,40(sp)
    80001886:	7b02                	ld	s6,32(sp)
    80001888:	6be2                	ld	s7,24(sp)
    8000188a:	6c42                	ld	s8,16(sp)
    8000188c:	6ca2                	ld	s9,8(sp)
    8000188e:	6125                	addi	sp,sp,96
    80001890:	8082                	ret
      panic("kalloc");
    80001892:	00007517          	auipc	a0,0x7
    80001896:	8c650513          	addi	a0,a0,-1850 # 80008158 <etext+0x158>
    8000189a:	f8bfe0ef          	jal	80000824 <panic>

000000008000189e <procinit>:

// initialize the proc table.
void procinit(void) {
    8000189e:	715d                	addi	sp,sp,-80
    800018a0:	e486                	sd	ra,72(sp)
    800018a2:	e0a2                	sd	s0,64(sp)
    800018a4:	fc26                	sd	s1,56(sp)
    800018a6:	f84a                	sd	s2,48(sp)
    800018a8:	f44e                	sd	s3,40(sp)
    800018aa:	f052                	sd	s4,32(sp)
    800018ac:	ec56                	sd	s5,24(sp)
    800018ae:	e85a                	sd	s6,16(sp)
    800018b0:	e45e                	sd	s7,8(sp)
    800018b2:	0880                	addi	s0,sp,80
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800018b4:	00007597          	auipc	a1,0x7
    800018b8:	8ac58593          	addi	a1,a1,-1876 # 80008160 <etext+0x160>
    800018bc:	00012517          	auipc	a0,0x12
    800018c0:	09c50513          	addi	a0,a0,156 # 80013958 <pid_lock>
    800018c4:	adaff0ef          	jal	80000b9e <initlock>
  initlock(&wait_lock, "wait_lock");
    800018c8:	00007597          	auipc	a1,0x7
    800018cc:	8a058593          	addi	a1,a1,-1888 # 80008168 <etext+0x168>
    800018d0:	00012517          	auipc	a0,0x12
    800018d4:	0a050513          	addi	a0,a0,160 # 80013970 <wait_lock>
    800018d8:	ac6ff0ef          	jal	80000b9e <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    800018dc:	00012497          	auipc	s1,0x12
    800018e0:	4ac48493          	addi	s1,s1,1196 # 80013d88 <proc>
    initlock(&p->lock, "proc");
    800018e4:	00007b97          	auipc	s7,0x7
    800018e8:	894b8b93          	addi	s7,s7,-1900 # 80008178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800018ec:	8b26                	mv	s6,s1
    800018ee:	0fe3c7b7          	lui	a5,0xfe3c
    800018f2:	07178793          	addi	a5,a5,113 # fe3c071 <_entry-0x701c3f8f>
    800018f6:	70fe4937          	lui	s2,0x70fe4
    800018fa:	c0790913          	addi	s2,s2,-1017 # 70fe3c07 <_entry-0xf01c3f9>
    800018fe:	1902                	slli	s2,s2,0x20
    80001900:	993e                	add	s2,s2,a5
    80001902:	040009b7          	lui	s3,0x4000
    80001906:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001908:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    8000190a:	6a05                	lui	s4,0x1
    8000190c:	220a0a13          	addi	s4,s4,544 # 1220 <_entry-0x7fffede0>
    80001910:	0005ba97          	auipc	s5,0x5b
    80001914:	c78a8a93          	addi	s5,s5,-904 # 8005c588 <tickslock>
    initlock(&p->lock, "proc");
    80001918:	85de                	mv	a1,s7
    8000191a:	8526                	mv	a0,s1
    8000191c:	a82ff0ef          	jal	80000b9e <initlock>
    p->state = UNUSED;
    80001920:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001924:	416487b3          	sub	a5,s1,s6
    80001928:	8795                	srai	a5,a5,0x5
    8000192a:	032787b3          	mul	a5,a5,s2
    8000192e:	07b6                	slli	a5,a5,0xd
    80001930:	6709                	lui	a4,0x2
    80001932:	9fb9                	addw	a5,a5,a4
    80001934:	40f987b3          	sub	a5,s3,a5
    80001938:	e4bc                	sd	a5,72(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    8000193a:	94d2                	add	s1,s1,s4
    8000193c:	fd549ee3          	bne	s1,s5,80001918 <procinit+0x7a>
  }
}
    80001940:	60a6                	ld	ra,72(sp)
    80001942:	6406                	ld	s0,64(sp)
    80001944:	74e2                	ld	s1,56(sp)
    80001946:	7942                	ld	s2,48(sp)
    80001948:	79a2                	ld	s3,40(sp)
    8000194a:	7a02                	ld	s4,32(sp)
    8000194c:	6ae2                	ld	s5,24(sp)
    8000194e:	6b42                	ld	s6,16(sp)
    80001950:	6ba2                	ld	s7,8(sp)
    80001952:	6161                	addi	sp,sp,80
    80001954:	8082                	ret

0000000080001956 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid() {
    80001956:	1141                	addi	sp,sp,-16
    80001958:	e406                	sd	ra,8(sp)
    8000195a:	e022                	sd	s0,0(sp)
    8000195c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    8000195e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001960:	2501                	sext.w	a0,a0
    80001962:	60a2                	ld	ra,8(sp)
    80001964:	6402                	ld	s0,0(sp)
    80001966:	0141                	addi	sp,sp,16
    80001968:	8082                	ret

000000008000196a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *mycpu(void) {
    8000196a:	1141                	addi	sp,sp,-16
    8000196c:	e406                	sd	ra,8(sp)
    8000196e:	e022                	sd	s0,0(sp)
    80001970:	0800                	addi	s0,sp,16
    80001972:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001974:	2781                	sext.w	a5,a5
    80001976:	079e                	slli	a5,a5,0x7
  return c;
}
    80001978:	00012517          	auipc	a0,0x12
    8000197c:	01050513          	addi	a0,a0,16 # 80013988 <cpus>
    80001980:	953e                	add	a0,a0,a5
    80001982:	60a2                	ld	ra,8(sp)
    80001984:	6402                	ld	s0,0(sp)
    80001986:	0141                	addi	sp,sp,16
    80001988:	8082                	ret

000000008000198a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *myproc(void) {
    8000198a:	1101                	addi	sp,sp,-32
    8000198c:	ec06                	sd	ra,24(sp)
    8000198e:	e822                	sd	s0,16(sp)
    80001990:	e426                	sd	s1,8(sp)
    80001992:	1000                	addi	s0,sp,32
  push_off();
    80001994:	a50ff0ef          	jal	80000be4 <push_off>
    80001998:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    8000199a:	2781                	sext.w	a5,a5
    8000199c:	079e                	slli	a5,a5,0x7
    8000199e:	00012717          	auipc	a4,0x12
    800019a2:	fba70713          	addi	a4,a4,-70 # 80013958 <pid_lock>
    800019a6:	97ba                	add	a5,a5,a4
    800019a8:	7b9c                	ld	a5,48(a5)
    800019aa:	84be                	mv	s1,a5
  pop_off();
    800019ac:	ac0ff0ef          	jal	80000c6c <pop_off>
  return p;
}
    800019b0:	8526                	mv	a0,s1
    800019b2:	60e2                	ld	ra,24(sp)
    800019b4:	6442                	ld	s0,16(sp)
    800019b6:	64a2                	ld	s1,8(sp)
    800019b8:	6105                	addi	sp,sp,32
    800019ba:	8082                	ret

00000000800019bc <forkret>:
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void) {
    800019bc:	7179                	addi	sp,sp,-48
    800019be:	f406                	sd	ra,40(sp)
    800019c0:	f022                	sd	s0,32(sp)
    800019c2:	ec26                	sd	s1,24(sp)
    800019c4:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    800019c6:	fc5ff0ef          	jal	8000198a <myproc>
    800019ca:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    800019cc:	af0ff0ef          	jal	80000cbc <release>

  if (first) {
    800019d0:	0000a797          	auipc	a5,0xa
    800019d4:	e307a783          	lw	a5,-464(a5) # 8000b800 <first.1>
    800019d8:	cf95                	beqz	a5,80001a14 <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019da:	4505                	li	a0,1
    800019dc:	302020ef          	jal	80003cde <fsinit>

    first = 0;
    800019e0:	0000a797          	auipc	a5,0xa
    800019e4:	e207a023          	sw	zero,-480(a5) # 8000b800 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    800019e8:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019ec:	00006797          	auipc	a5,0x6
    800019f0:	79478793          	addi	a5,a5,1940 # 80008180 <etext+0x180>
    800019f4:	fcf43823          	sd	a5,-48(s0)
    800019f8:	fc043c23          	sd	zero,-40(s0)
    800019fc:	fd040593          	addi	a1,s0,-48
    80001a00:	853e                	mv	a0,a5
    80001a02:	464030ef          	jal	80004e66 <kexec>
    80001a06:	70bc                	ld	a5,96(s1)
    80001a08:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001a0a:	70bc                	ld	a5,96(s1)
    80001a0c:	7bb8                	ld	a4,112(a5)
    80001a0e:	57fd                	li	a5,-1
    80001a10:	02f70d63          	beq	a4,a5,80001a4a <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001a14:	3e5000ef          	jal	800025f8 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001a18:	6ca8                	ld	a0,88(s1)
    80001a1a:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001a1c:	04000737          	lui	a4,0x4000
    80001a20:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001a22:	0732                	slli	a4,a4,0xc
    80001a24:	00005797          	auipc	a5,0x5
    80001a28:	67878793          	addi	a5,a5,1656 # 8000709c <userret>
    80001a2c:	00005697          	auipc	a3,0x5
    80001a30:	5d468693          	addi	a3,a3,1492 # 80007000 <_trampoline>
    80001a34:	8f95                	sub	a5,a5,a3
    80001a36:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001a38:	577d                	li	a4,-1
    80001a3a:	177e                	slli	a4,a4,0x3f
    80001a3c:	8d59                	or	a0,a0,a4
    80001a3e:	9782                	jalr	a5
}
    80001a40:	70a2                	ld	ra,40(sp)
    80001a42:	7402                	ld	s0,32(sp)
    80001a44:	64e2                	ld	s1,24(sp)
    80001a46:	6145                	addi	sp,sp,48
    80001a48:	8082                	ret
      panic("exec");
    80001a4a:	00006517          	auipc	a0,0x6
    80001a4e:	73e50513          	addi	a0,a0,1854 # 80008188 <etext+0x188>
    80001a52:	dd3fe0ef          	jal	80000824 <panic>

0000000080001a56 <allocpid>:
int allocpid() {
    80001a56:	1101                	addi	sp,sp,-32
    80001a58:	ec06                	sd	ra,24(sp)
    80001a5a:	e822                	sd	s0,16(sp)
    80001a5c:	e426                	sd	s1,8(sp)
    80001a5e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a60:	00012517          	auipc	a0,0x12
    80001a64:	ef850513          	addi	a0,a0,-264 # 80013958 <pid_lock>
    80001a68:	9c0ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a6c:	0000a797          	auipc	a5,0xa
    80001a70:	d9c78793          	addi	a5,a5,-612 # 8000b808 <nextpid>
    80001a74:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a76:	0014871b          	addiw	a4,s1,1
    80001a7a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a7c:	00012517          	auipc	a0,0x12
    80001a80:	edc50513          	addi	a0,a0,-292 # 80013958 <pid_lock>
    80001a84:	a38ff0ef          	jal	80000cbc <release>
}
    80001a88:	8526                	mv	a0,s1
    80001a8a:	60e2                	ld	ra,24(sp)
    80001a8c:	6442                	ld	s0,16(sp)
    80001a8e:	64a2                	ld	s1,8(sp)
    80001a90:	6105                	addi	sp,sp,32
    80001a92:	8082                	ret

0000000080001a94 <proc_pagetable>:
pagetable_t proc_pagetable(struct proc *p) {
    80001a94:	1101                	addi	sp,sp,-32
    80001a96:	ec06                	sd	ra,24(sp)
    80001a98:	e822                	sd	s0,16(sp)
    80001a9a:	e426                	sd	s1,8(sp)
    80001a9c:	e04a                	sd	s2,0(sp)
    80001a9e:	1000                	addi	s0,sp,32
    80001aa0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001aa2:	f66ff0ef          	jal	80001208 <uvmcreate>
    80001aa6:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001aa8:	cd05                	beqz	a0,80001ae0 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001aaa:	4729                	li	a4,10
    80001aac:	00005697          	auipc	a3,0x5
    80001ab0:	55468693          	addi	a3,a3,1364 # 80007000 <_trampoline>
    80001ab4:	6605                	lui	a2,0x1
    80001ab6:	040005b7          	lui	a1,0x4000
    80001aba:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001abc:	05b2                	slli	a1,a1,0xc
    80001abe:	da2ff0ef          	jal	80001060 <mappages>
    80001ac2:	02054663          	bltz	a0,80001aee <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001ac6:	4719                	li	a4,6
    80001ac8:	06093683          	ld	a3,96(s2)
    80001acc:	6605                	lui	a2,0x1
    80001ace:	020005b7          	lui	a1,0x2000
    80001ad2:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ad4:	05b6                	slli	a1,a1,0xd
    80001ad6:	8526                	mv	a0,s1
    80001ad8:	d88ff0ef          	jal	80001060 <mappages>
    80001adc:	00054f63          	bltz	a0,80001afa <proc_pagetable+0x66>
}
    80001ae0:	8526                	mv	a0,s1
    80001ae2:	60e2                	ld	ra,24(sp)
    80001ae4:	6442                	ld	s0,16(sp)
    80001ae6:	64a2                	ld	s1,8(sp)
    80001ae8:	6902                	ld	s2,0(sp)
    80001aea:	6105                	addi	sp,sp,32
    80001aec:	8082                	ret
    uvmfree(pagetable, 0);
    80001aee:	4581                	li	a1,0
    80001af0:	8526                	mv	a0,s1
    80001af2:	911ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001af6:	4481                	li	s1,0
    80001af8:	b7e5                	j	80001ae0 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001afa:	4681                	li	a3,0
    80001afc:	4605                	li	a2,1
    80001afe:	040005b7          	lui	a1,0x4000
    80001b02:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b04:	05b2                	slli	a1,a1,0xc
    80001b06:	8526                	mv	a0,s1
    80001b08:	f26ff0ef          	jal	8000122e <uvmunmap>
    uvmfree(pagetable, 0);
    80001b0c:	4581                	li	a1,0
    80001b0e:	8526                	mv	a0,s1
    80001b10:	8f3ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001b14:	4481                	li	s1,0
    80001b16:	b7e9                	j	80001ae0 <proc_pagetable+0x4c>

0000000080001b18 <proc_freepagetable>:
void proc_freepagetable(pagetable_t pagetable, uint64 sz) {
    80001b18:	1101                	addi	sp,sp,-32
    80001b1a:	ec06                	sd	ra,24(sp)
    80001b1c:	e822                	sd	s0,16(sp)
    80001b1e:	e426                	sd	s1,8(sp)
    80001b20:	e04a                	sd	s2,0(sp)
    80001b22:	1000                	addi	s0,sp,32
    80001b24:	84aa                	mv	s1,a0
    80001b26:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b28:	4681                	li	a3,0
    80001b2a:	4605                	li	a2,1
    80001b2c:	040005b7          	lui	a1,0x4000
    80001b30:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b32:	05b2                	slli	a1,a1,0xc
    80001b34:	efaff0ef          	jal	8000122e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b38:	4681                	li	a3,0
    80001b3a:	4605                	li	a2,1
    80001b3c:	020005b7          	lui	a1,0x2000
    80001b40:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b42:	05b6                	slli	a1,a1,0xd
    80001b44:	8526                	mv	a0,s1
    80001b46:	ee8ff0ef          	jal	8000122e <uvmunmap>
  uvmfree(pagetable, sz);
    80001b4a:	85ca                	mv	a1,s2
    80001b4c:	8526                	mv	a0,s1
    80001b4e:	8b5ff0ef          	jal	80001402 <uvmfree>
}
    80001b52:	60e2                	ld	ra,24(sp)
    80001b54:	6442                	ld	s0,16(sp)
    80001b56:	64a2                	ld	s1,8(sp)
    80001b58:	6902                	ld	s2,0(sp)
    80001b5a:	6105                	addi	sp,sp,32
    80001b5c:	8082                	ret

0000000080001b5e <freeproc>:
static void freeproc(struct proc *p) {
    80001b5e:	1101                	addi	sp,sp,-32
    80001b60:	ec06                	sd	ra,24(sp)
    80001b62:	e822                	sd	s0,16(sp)
    80001b64:	e426                	sd	s1,8(sp)
    80001b66:	1000                	addi	s0,sp,32
    80001b68:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b6a:	7128                	ld	a0,96(a0)
    80001b6c:	c119                	beqz	a0,80001b72 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001b6e:	eeffe0ef          	jal	80000a5c <kfree>
  p->trapframe = 0;
    80001b72:	0604b023          	sd	zero,96(s1)
  if (p->pagetable)
    80001b76:	6ca8                	ld	a0,88(s1)
    80001b78:	c501                	beqz	a0,80001b80 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b7a:	68ac                	ld	a1,80(s1)
    80001b7c:	f9dff0ef          	jal	80001b18 <proc_freepagetable>
  if(p->parent)
    80001b80:	60bc                	ld	a5,64(s1)
    80001b82:	c781                	beqz	a5,80001b8a <freeproc+0x2c>
    p->parent->child_count--;
    80001b84:	5fd8                	lw	a4,60(a5)
    80001b86:	377d                	addiw	a4,a4,-1
    80001b88:	dfd8                	sw	a4,60(a5)
  p->pagetable = 0;
    80001b8a:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001b8e:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001b92:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b96:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001b9a:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001b9e:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ba2:	0204a423          	sw	zero,40(s1)
  p->child_limit = -1;
    80001ba6:	57fd                	li	a5,-1
    80001ba8:	dc9c                	sw	a5,56(s1)
  p->child_count = 0;
    80001baa:	0204ae23          	sw	zero,60(s1)
  p->xstate = 0;
    80001bae:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bb2:	0004ac23          	sw	zero,24(s1)
}
    80001bb6:	60e2                	ld	ra,24(sp)
    80001bb8:	6442                	ld	s0,16(sp)
    80001bba:	64a2                	ld	s1,8(sp)
    80001bbc:	6105                	addi	sp,sp,32
    80001bbe:	8082                	ret

0000000080001bc0 <allocproc>:
static struct proc *allocproc(void) {
    80001bc0:	7179                	addi	sp,sp,-48
    80001bc2:	f406                	sd	ra,40(sp)
    80001bc4:	f022                	sd	s0,32(sp)
    80001bc6:	ec26                	sd	s1,24(sp)
    80001bc8:	e84a                	sd	s2,16(sp)
    80001bca:	e44e                	sd	s3,8(sp)
    80001bcc:	1800                	addi	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bce:	00012497          	auipc	s1,0x12
    80001bd2:	1ba48493          	addi	s1,s1,442 # 80013d88 <proc>
    80001bd6:	6905                	lui	s2,0x1
    80001bd8:	22090913          	addi	s2,s2,544 # 1220 <_entry-0x7fffede0>
    80001bdc:	0005b997          	auipc	s3,0x5b
    80001be0:	9ac98993          	addi	s3,s3,-1620 # 8005c588 <tickslock>
    acquire(&p->lock);
    80001be4:	8526                	mv	a0,s1
    80001be6:	842ff0ef          	jal	80000c28 <acquire>
    if (p->state == UNUSED) {
    80001bea:	4c9c                	lw	a5,24(s1)
    80001bec:	cb89                	beqz	a5,80001bfe <allocproc+0x3e>
      release(&p->lock);
    80001bee:	8526                	mv	a0,s1
    80001bf0:	8ccff0ef          	jal	80000cbc <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bf4:	94ca                	add	s1,s1,s2
    80001bf6:	ff3497e3          	bne	s1,s3,80001be4 <allocproc+0x24>
  return 0;
    80001bfa:	4481                	li	s1,0
    80001bfc:	a885                	j	80001c6c <allocproc+0xac>
  p->pid = allocpid();
    80001bfe:	e59ff0ef          	jal	80001a56 <allocpid>
    80001c02:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c04:	4785                	li	a5,1
    80001c06:	cc9c                	sw	a5,24(s1)
  p->tickets = 1;
    80001c08:	d8dc                	sw	a5,52(s1)
  p->child_limit = -1;
    80001c0a:	57fd                	li	a5,-1
    80001c0c:	dc9c                	sw	a5,56(s1)
  p->child_count = 0;
    80001c0e:	0204ae23          	sw	zero,60(s1)
  initlock(&p->mq.lock, "msgqueue");
    80001c12:	00006597          	auipc	a1,0x6
    80001c16:	57e58593          	addi	a1,a1,1406 # 80008190 <etext+0x190>
    80001c1a:	6505                	lui	a0,0x1
    80001c1c:	20850513          	addi	a0,a0,520 # 1208 <_entry-0x7fffedf8>
    80001c20:	9526                	add	a0,a0,s1
    80001c22:	f7dfe0ef          	jal	80000b9e <initlock>
  p->mq.head = 0;
    80001c26:	6785                	lui	a5,0x1
    80001c28:	97a6                	add	a5,a5,s1
    80001c2a:	1e07ac23          	sw	zero,504(a5) # 11f8 <_entry-0x7fffee08>
  p->mq.tail = 0;
    80001c2e:	1e07ae23          	sw	zero,508(a5)
  p->mq.count = 0;
    80001c32:	2007a023          	sw	zero,512(a5)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001c36:	f0ffe0ef          	jal	80000b44 <kalloc>
    80001c3a:	892a                	mv	s2,a0
    80001c3c:	f0a8                	sd	a0,96(s1)
    80001c3e:	cd1d                	beqz	a0,80001c7c <allocproc+0xbc>
  p->pagetable = proc_pagetable(p);
    80001c40:	8526                	mv	a0,s1
    80001c42:	e53ff0ef          	jal	80001a94 <proc_pagetable>
    80001c46:	892a                	mv	s2,a0
    80001c48:	eca8                	sd	a0,88(s1)
  if (p->pagetable == 0) {
    80001c4a:	c129                	beqz	a0,80001c8c <allocproc+0xcc>
  memset(&p->context, 0, sizeof(p->context));
    80001c4c:	07000613          	li	a2,112
    80001c50:	4581                	li	a1,0
    80001c52:	06848513          	addi	a0,s1,104
    80001c56:	8a2ff0ef          	jal	80000cf8 <memset>
  p->context.ra = (uint64)forkret;
    80001c5a:	00000797          	auipc	a5,0x0
    80001c5e:	d6278793          	addi	a5,a5,-670 # 800019bc <forkret>
    80001c62:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c64:	64bc                	ld	a5,72(s1)
    80001c66:	6705                	lui	a4,0x1
    80001c68:	97ba                	add	a5,a5,a4
    80001c6a:	f8bc                	sd	a5,112(s1)
}
    80001c6c:	8526                	mv	a0,s1
    80001c6e:	70a2                	ld	ra,40(sp)
    80001c70:	7402                	ld	s0,32(sp)
    80001c72:	64e2                	ld	s1,24(sp)
    80001c74:	6942                	ld	s2,16(sp)
    80001c76:	69a2                	ld	s3,8(sp)
    80001c78:	6145                	addi	sp,sp,48
    80001c7a:	8082                	ret
    freeproc(p);
    80001c7c:	8526                	mv	a0,s1
    80001c7e:	ee1ff0ef          	jal	80001b5e <freeproc>
    release(&p->lock);
    80001c82:	8526                	mv	a0,s1
    80001c84:	838ff0ef          	jal	80000cbc <release>
    return 0;
    80001c88:	84ca                	mv	s1,s2
    80001c8a:	b7cd                	j	80001c6c <allocproc+0xac>
    freeproc(p);
    80001c8c:	8526                	mv	a0,s1
    80001c8e:	ed1ff0ef          	jal	80001b5e <freeproc>
    release(&p->lock);
    80001c92:	8526                	mv	a0,s1
    80001c94:	828ff0ef          	jal	80000cbc <release>
    return 0;
    80001c98:	84ca                	mv	s1,s2
    80001c9a:	bfc9                	j	80001c6c <allocproc+0xac>

0000000080001c9c <userinit>:
void userinit(void) {
    80001c9c:	1101                	addi	sp,sp,-32
    80001c9e:	ec06                	sd	ra,24(sp)
    80001ca0:	e822                	sd	s0,16(sp)
    80001ca2:	e426                	sd	s1,8(sp)
    80001ca4:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ca6:	f1bff0ef          	jal	80001bc0 <allocproc>
    80001caa:	84aa                	mv	s1,a0
  initproc = p;
    80001cac:	0000a797          	auipc	a5,0xa
    80001cb0:	baa7b223          	sd	a0,-1116(a5) # 8000b850 <initproc>
  p->cwd = namei("/");
    80001cb4:	00006517          	auipc	a0,0x6
    80001cb8:	4ec50513          	addi	a0,a0,1260 # 800081a0 <etext+0x1a0>
    80001cbc:	55c020ef          	jal	80004218 <namei>
    80001cc0:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001cc4:	478d                	li	a5,3
    80001cc6:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cc8:	8526                	mv	a0,s1
    80001cca:	ff3fe0ef          	jal	80000cbc <release>
}
    80001cce:	60e2                	ld	ra,24(sp)
    80001cd0:	6442                	ld	s0,16(sp)
    80001cd2:	64a2                	ld	s1,8(sp)
    80001cd4:	6105                	addi	sp,sp,32
    80001cd6:	8082                	ret

0000000080001cd8 <growproc>:
int growproc(int n) {
    80001cd8:	1101                	addi	sp,sp,-32
    80001cda:	ec06                	sd	ra,24(sp)
    80001cdc:	e822                	sd	s0,16(sp)
    80001cde:	e426                	sd	s1,8(sp)
    80001ce0:	e04a                	sd	s2,0(sp)
    80001ce2:	1000                	addi	s0,sp,32
    80001ce4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001ce6:	ca5ff0ef          	jal	8000198a <myproc>
    80001cea:	892a                	mv	s2,a0
  sz = p->sz;
    80001cec:	692c                	ld	a1,80(a0)
  if (n > 0) {
    80001cee:	02905963          	blez	s1,80001d20 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001cf2:	00b48633          	add	a2,s1,a1
    80001cf6:	020007b7          	lui	a5,0x2000
    80001cfa:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001cfc:	07b6                	slli	a5,a5,0xd
    80001cfe:	02c7ea63          	bltu	a5,a2,80001d32 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d02:	4691                	li	a3,4
    80001d04:	6d28                	ld	a0,88(a0)
    80001d06:	df6ff0ef          	jal	800012fc <uvmalloc>
    80001d0a:	85aa                	mv	a1,a0
    80001d0c:	c50d                	beqz	a0,80001d36 <growproc+0x5e>
  p->sz = sz;
    80001d0e:	04b93823          	sd	a1,80(s2)
  return 0;
    80001d12:	4501                	li	a0,0
}
    80001d14:	60e2                	ld	ra,24(sp)
    80001d16:	6442                	ld	s0,16(sp)
    80001d18:	64a2                	ld	s1,8(sp)
    80001d1a:	6902                	ld	s2,0(sp)
    80001d1c:	6105                	addi	sp,sp,32
    80001d1e:	8082                	ret
  } else if (n < 0) {
    80001d20:	fe04d7e3          	bgez	s1,80001d0e <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d24:	00b48633          	add	a2,s1,a1
    80001d28:	6d28                	ld	a0,88(a0)
    80001d2a:	d8eff0ef          	jal	800012b8 <uvmdealloc>
    80001d2e:	85aa                	mv	a1,a0
    80001d30:	bff9                	j	80001d0e <growproc+0x36>
      return -1;
    80001d32:	557d                	li	a0,-1
    80001d34:	b7c5                	j	80001d14 <growproc+0x3c>
      return -1;
    80001d36:	557d                	li	a0,-1
    80001d38:	bff1                	j	80001d14 <growproc+0x3c>

0000000080001d3a <kfork>:
int kfork(void) {
    80001d3a:	7139                	addi	sp,sp,-64
    80001d3c:	fc06                	sd	ra,56(sp)
    80001d3e:	f822                	sd	s0,48(sp)
    80001d40:	f426                	sd	s1,40(sp)
    80001d42:	e456                	sd	s5,8(sp)
    80001d44:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d46:	c45ff0ef          	jal	8000198a <myproc>
    80001d4a:	8aaa                	mv	s5,a0
  if(p->child_limit!=-1 && p->child_count>= p->child_limit)
    80001d4c:	5d1c                	lw	a5,56(a0)
    80001d4e:	577d                	li	a4,-1
    80001d50:	00e78563          	beq	a5,a4,80001d5a <kfork+0x20>
    80001d54:	5d58                	lw	a4,60(a0)
    80001d56:	10f75763          	bge	a4,a5,80001e64 <kfork+0x12a>
    80001d5a:	ec4e                	sd	s3,24(sp)
  if ((np = allocproc()) == 0) {
    80001d5c:	e65ff0ef          	jal	80001bc0 <allocproc>
    80001d60:	89aa                	mv	s3,a0
    80001d62:	10050363          	beqz	a0,80001e68 <kfork+0x12e>
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001d66:	050ab603          	ld	a2,80(s5)
    80001d6a:	6d2c                	ld	a1,88(a0)
    80001d6c:	058ab503          	ld	a0,88(s5)
    80001d70:	ec4ff0ef          	jal	80001434 <uvmcopy>
    80001d74:	04054863          	bltz	a0,80001dc4 <kfork+0x8a>
    80001d78:	f04a                	sd	s2,32(sp)
    80001d7a:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001d7c:	050ab783          	ld	a5,80(s5)
    80001d80:	04f9b823          	sd	a5,80(s3)
  *(np->trapframe) = *(p->trapframe);
    80001d84:	060ab683          	ld	a3,96(s5)
    80001d88:	87b6                	mv	a5,a3
    80001d8a:	0609b703          	ld	a4,96(s3)
    80001d8e:	12068693          	addi	a3,a3,288
    80001d92:	6388                	ld	a0,0(a5)
    80001d94:	678c                	ld	a1,8(a5)
    80001d96:	6b90                	ld	a2,16(a5)
    80001d98:	e308                	sd	a0,0(a4)
    80001d9a:	e70c                	sd	a1,8(a4)
    80001d9c:	eb10                	sd	a2,16(a4)
    80001d9e:	6f90                	ld	a2,24(a5)
    80001da0:	ef10                	sd	a2,24(a4)
    80001da2:	02078793          	addi	a5,a5,32
    80001da6:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001daa:	fed794e3          	bne	a5,a3,80001d92 <kfork+0x58>
  np->trapframe->a0 = 0;
    80001dae:	0609b783          	ld	a5,96(s3)
    80001db2:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001db6:	0d8a8493          	addi	s1,s5,216
    80001dba:	0d898913          	addi	s2,s3,216
    80001dbe:	158a8a13          	addi	s4,s5,344
    80001dc2:	a831                	j	80001dde <kfork+0xa4>
    freeproc(np);
    80001dc4:	854e                	mv	a0,s3
    80001dc6:	d99ff0ef          	jal	80001b5e <freeproc>
    release(&np->lock);
    80001dca:	854e                	mv	a0,s3
    80001dcc:	ef1fe0ef          	jal	80000cbc <release>
    return -1;
    80001dd0:	54fd                	li	s1,-1
    80001dd2:	69e2                	ld	s3,24(sp)
    80001dd4:	a049                	j	80001e56 <kfork+0x11c>
  for (i = 0; i < NOFILE; i++)
    80001dd6:	04a1                	addi	s1,s1,8
    80001dd8:	0921                	addi	s2,s2,8
    80001dda:	01448963          	beq	s1,s4,80001dec <kfork+0xb2>
    if (p->ofile[i])
    80001dde:	6088                	ld	a0,0(s1)
    80001de0:	d97d                	beqz	a0,80001dd6 <kfork+0x9c>
      np->ofile[i] = filedup(p->ofile[i]);
    80001de2:	1f3020ef          	jal	800047d4 <filedup>
    80001de6:	00a93023          	sd	a0,0(s2)
    80001dea:	b7f5                	j	80001dd6 <kfork+0x9c>
  np->cwd = idup(p->cwd);
    80001dec:	158ab503          	ld	a0,344(s5)
    80001df0:	3c5010ef          	jal	800039b4 <idup>
    80001df4:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001df8:	4641                	li	a2,16
    80001dfa:	160a8593          	addi	a1,s5,352
    80001dfe:	16098513          	addi	a0,s3,352
    80001e02:	84aff0ef          	jal	80000e4c <safestrcpy>
  pid = np->pid;
    80001e06:	0309a483          	lw	s1,48(s3)
  release(&np->lock);
    80001e0a:	854e                	mv	a0,s3
    80001e0c:	eb1fe0ef          	jal	80000cbc <release>
  acquire(&wait_lock);
    80001e10:	00012517          	auipc	a0,0x12
    80001e14:	b6050513          	addi	a0,a0,-1184 # 80013970 <wait_lock>
    80001e18:	e11fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001e1c:	0559b023          	sd	s5,64(s3)
  np->tickets = p->tickets;
    80001e20:	034aa783          	lw	a5,52(s5)
    80001e24:	02f9aa23          	sw	a5,52(s3)
  p->child_count++;
    80001e28:	03caa783          	lw	a5,60(s5)
    80001e2c:	2785                	addiw	a5,a5,1
    80001e2e:	02faae23          	sw	a5,60(s5)
  release(&wait_lock);
    80001e32:	00012517          	auipc	a0,0x12
    80001e36:	b3e50513          	addi	a0,a0,-1218 # 80013970 <wait_lock>
    80001e3a:	e83fe0ef          	jal	80000cbc <release>
  acquire(&np->lock);
    80001e3e:	854e                	mv	a0,s3
    80001e40:	de9fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001e44:	478d                	li	a5,3
    80001e46:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001e4a:	854e                	mv	a0,s3
    80001e4c:	e71fe0ef          	jal	80000cbc <release>
  return pid;
    80001e50:	7902                	ld	s2,32(sp)
    80001e52:	69e2                	ld	s3,24(sp)
    80001e54:	6a42                	ld	s4,16(sp)
}
    80001e56:	8526                	mv	a0,s1
    80001e58:	70e2                	ld	ra,56(sp)
    80001e5a:	7442                	ld	s0,48(sp)
    80001e5c:	74a2                	ld	s1,40(sp)
    80001e5e:	6aa2                	ld	s5,8(sp)
    80001e60:	6121                	addi	sp,sp,64
    80001e62:	8082                	ret
   return -1;
    80001e64:	54fd                	li	s1,-1
    80001e66:	bfc5                	j	80001e56 <kfork+0x11c>
    return -1;
    80001e68:	54fd                	li	s1,-1
    80001e6a:	69e2                	ld	s3,24(sp)
    80001e6c:	b7ed                	j	80001e56 <kfork+0x11c>

0000000080001e6e <scheduler>:
void scheduler(void) {
    80001e6e:	c9010113          	addi	sp,sp,-880
    80001e72:	36113423          	sd	ra,872(sp)
    80001e76:	36813023          	sd	s0,864(sp)
    80001e7a:	34913c23          	sd	s1,856(sp)
    80001e7e:	35213823          	sd	s2,848(sp)
    80001e82:	35313423          	sd	s3,840(sp)
    80001e86:	35413023          	sd	s4,832(sp)
    80001e8a:	33513c23          	sd	s5,824(sp)
    80001e8e:	33613823          	sd	s6,816(sp)
    80001e92:	33713423          	sd	s7,808(sp)
    80001e96:	33813023          	sd	s8,800(sp)
    80001e9a:	31913c23          	sd	s9,792(sp)
    80001e9e:	31a13823          	sd	s10,784(sp)
    80001ea2:	31b13423          	sd	s11,776(sp)
    80001ea6:	1e80                	addi	s0,sp,880
    80001ea8:	8792                	mv	a5,tp
  int id = r_tp();
    80001eaa:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001eac:	00779693          	slli	a3,a5,0x7
    80001eb0:	00012717          	auipc	a4,0x12
    80001eb4:	aa870713          	addi	a4,a4,-1368 # 80013958 <pid_lock>
    80001eb8:	9736                	add	a4,a4,a3
    80001eba:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &winner->context);
    80001ebe:	00012717          	auipc	a4,0x12
    80001ec2:	ad270713          	addi	a4,a4,-1326 # 80013990 <cpus+0x8>
    80001ec6:	9736                	add	a4,a4,a3
    80001ec8:	8dba                	mv	s11,a4
        runnable[count] = p;
    80001eca:	d9040b93          	addi	s7,s0,-624
        cumulative[count] = total + t;
    80001ece:	c9040c13          	addi	s8,s0,-880
      c->proc = winner;
    80001ed2:	00012d17          	auipc	s10,0x12
    80001ed6:	a86d0d13          	addi	s10,s10,-1402 # 80013958 <pid_lock>
    80001eda:	9d36                	add	s10,s10,a3
    80001edc:	a0a1                	j	80001f24 <scheduler+0xb6>
        runnable[count] = p;
    80001ede:	00391713          	slli	a4,s2,0x3
    80001ee2:	975e                	add	a4,a4,s7
    80001ee4:	e304                	sd	s1,0(a4)
        cumulative[count] = total + t;
    80001ee6:	016787bb          	addw	a5,a5,s6
    80001eea:	8b3e                	mv	s6,a5
    80001eec:	00291713          	slli	a4,s2,0x2
    80001ef0:	9762                	add	a4,a4,s8
    80001ef2:	c31c                	sw	a5,0(a4)
        count++;
    80001ef4:	2905                	addiw	s2,s2,1
      release(&p->lock);
    80001ef6:	8526                	mv	a0,s1
    80001ef8:	dc5fe0ef          	jal	80000cbc <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001efc:	94ce                	add	s1,s1,s3
    80001efe:	01448f63          	beq	s1,s4,80001f1c <scheduler+0xae>
      acquire(&p->lock);
    80001f02:	8526                	mv	a0,s1
    80001f04:	d25fe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE) {
    80001f08:	4c9c                	lw	a5,24(s1)
    80001f0a:	ff5796e3          	bne	a5,s5,80001ef6 <scheduler+0x88>
        if (t < 1)
    80001f0e:	58d8                	lw	a4,52(s1)
    80001f10:	87ba                	mv	a5,a4
    80001f12:	2701                	sext.w	a4,a4
    80001f14:	fce045e3          	bgtz	a4,80001ede <scheduler+0x70>
    80001f18:	87e6                	mv	a5,s9
    80001f1a:	b7d1                	j	80001ede <scheduler+0x70>
    if (count == 0) {
    80001f1c:	02091f63          	bnez	s2,80001f5a <scheduler+0xec>
      asm volatile("wfi");
    80001f20:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001f24:	100027f3          	csrr	a5,sstatus
static inline void intr_on() { w_sstatus(r_sstatus() | SSTATUS_SIE); }
    80001f28:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80001f2c:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001f30:	100027f3          	csrr	a5,sstatus
static inline void intr_off() { w_sstatus(r_sstatus() & ~SSTATUS_SIE); }
    80001f34:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80001f36:	10079073          	csrw	sstatus,a5
    int total = 0;
    80001f3a:	4b01                	li	s6,0
    int count = 0;
    80001f3c:	4901                	li	s2,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f3e:	00012497          	auipc	s1,0x12
    80001f42:	e4a48493          	addi	s1,s1,-438 # 80013d88 <proc>
      if (p->state == RUNNABLE) {
    80001f46:	4a8d                	li	s5,3
        if (t < 1)
    80001f48:	4c85                	li	s9,1
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f4a:	6985                	lui	s3,0x1
    80001f4c:	22098993          	addi	s3,s3,544 # 1220 <_entry-0x7fffede0>
    80001f50:	0005aa17          	auipc	s4,0x5a
    80001f54:	638a0a13          	addi	s4,s4,1592 # 8005c588 <tickslock>
    80001f58:	b76d                	j	80001f02 <scheduler+0x94>
    int ticket_no = (krand() % total) + 1;
    80001f5a:	847ff0ef          	jal	800017a0 <krand>
    for (int i = 0; i < count; i++) {
    80001f5e:	fd2053e3          	blez	s2,80001f24 <scheduler+0xb6>
    int ticket_no = (krand() % total) + 1;
    80001f62:	0365663b          	remw	a2,a0,s6
    80001f66:	c9040713          	addi	a4,s0,-880
    for (int i = 0; i < count; i++) {
    80001f6a:	4781                	li	a5,0
      if (cumulative[i] >= ticket_no) {
    80001f6c:	4314                	lw	a3,0(a4)
    80001f6e:	00d64763          	blt	a2,a3,80001f7c <scheduler+0x10e>
    for (int i = 0; i < count; i++) {
    80001f72:	2785                	addiw	a5,a5,1
    80001f74:	0711                	addi	a4,a4,4
    80001f76:	fef91be3          	bne	s2,a5,80001f6c <scheduler+0xfe>
    80001f7a:	b76d                	j	80001f24 <scheduler+0xb6>
        winner = runnable[i];
    80001f7c:	078e                	slli	a5,a5,0x3
    80001f7e:	97de                	add	a5,a5,s7
    80001f80:	6384                	ld	s1,0(a5)
    if (winner == 0)
    80001f82:	d0cd                	beqz	s1,80001f24 <scheduler+0xb6>
    acquire(&winner->lock);
    80001f84:	8526                	mv	a0,s1
    80001f86:	ca3fe0ef          	jal	80000c28 <acquire>
    if (winner->state == RUNNABLE) {
    80001f8a:	4c98                	lw	a4,24(s1)
    80001f8c:	478d                	li	a5,3
    80001f8e:	00f70663          	beq	a4,a5,80001f9a <scheduler+0x12c>
    release(&winner->lock);
    80001f92:	8526                	mv	a0,s1
    80001f94:	d29fe0ef          	jal	80000cbc <release>
    80001f98:	b771                	j	80001f24 <scheduler+0xb6>
      winner->state = RUNNING;
    80001f9a:	4791                	li	a5,4
    80001f9c:	cc9c                	sw	a5,24(s1)
      c->proc = winner;
    80001f9e:	029d3823          	sd	s1,48(s10)
      swtch(&c->context, &winner->context);
    80001fa2:	06848593          	addi	a1,s1,104
    80001fa6:	856e                	mv	a0,s11
    80001fa8:	5a6000ef          	jal	8000254e <swtch>
      c->proc = 0;
    80001fac:	020d3823          	sd	zero,48(s10)
    80001fb0:	b7cd                	j	80001f92 <scheduler+0x124>

0000000080001fb2 <sched>:
void sched(void) {
    80001fb2:	7179                	addi	sp,sp,-48
    80001fb4:	f406                	sd	ra,40(sp)
    80001fb6:	f022                	sd	s0,32(sp)
    80001fb8:	ec26                	sd	s1,24(sp)
    80001fba:	e84a                	sd	s2,16(sp)
    80001fbc:	e44e                	sd	s3,8(sp)
    80001fbe:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fc0:	9cbff0ef          	jal	8000198a <myproc>
    80001fc4:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001fc6:	bf3fe0ef          	jal	80000bb8 <holding>
    80001fca:	c935                	beqz	a0,8000203e <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001fcc:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001fce:	2781                	sext.w	a5,a5
    80001fd0:	079e                	slli	a5,a5,0x7
    80001fd2:	00012717          	auipc	a4,0x12
    80001fd6:	98670713          	addi	a4,a4,-1658 # 80013958 <pid_lock>
    80001fda:	97ba                	add	a5,a5,a4
    80001fdc:	0a87a703          	lw	a4,168(a5)
    80001fe0:	4785                	li	a5,1
    80001fe2:	06f71463          	bne	a4,a5,8000204a <sched+0x98>
  if (p->state == RUNNING)
    80001fe6:	4c98                	lw	a4,24(s1)
    80001fe8:	4791                	li	a5,4
    80001fea:	06f70663          	beq	a4,a5,80002056 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001fee:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001ff2:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001ff4:	e7bd                	bnez	a5,80002062 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001ff6:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001ff8:	00012917          	auipc	s2,0x12
    80001ffc:	96090913          	addi	s2,s2,-1696 # 80013958 <pid_lock>
    80002000:	2781                	sext.w	a5,a5
    80002002:	079e                	slli	a5,a5,0x7
    80002004:	97ca                	add	a5,a5,s2
    80002006:	0ac7a983          	lw	s3,172(a5)
    8000200a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000200c:	2781                	sext.w	a5,a5
    8000200e:	079e                	slli	a5,a5,0x7
    80002010:	07a1                	addi	a5,a5,8
    80002012:	00012597          	auipc	a1,0x12
    80002016:	97658593          	addi	a1,a1,-1674 # 80013988 <cpus>
    8000201a:	95be                	add	a1,a1,a5
    8000201c:	06848513          	addi	a0,s1,104
    80002020:	52e000ef          	jal	8000254e <swtch>
    80002024:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002026:	2781                	sext.w	a5,a5
    80002028:	079e                	slli	a5,a5,0x7
    8000202a:	993e                	add	s2,s2,a5
    8000202c:	0b392623          	sw	s3,172(s2)
}
    80002030:	70a2                	ld	ra,40(sp)
    80002032:	7402                	ld	s0,32(sp)
    80002034:	64e2                	ld	s1,24(sp)
    80002036:	6942                	ld	s2,16(sp)
    80002038:	69a2                	ld	s3,8(sp)
    8000203a:	6145                	addi	sp,sp,48
    8000203c:	8082                	ret
    panic("sched p->lock");
    8000203e:	00006517          	auipc	a0,0x6
    80002042:	16a50513          	addi	a0,a0,362 # 800081a8 <etext+0x1a8>
    80002046:	fdefe0ef          	jal	80000824 <panic>
    panic("sched locks");
    8000204a:	00006517          	auipc	a0,0x6
    8000204e:	16e50513          	addi	a0,a0,366 # 800081b8 <etext+0x1b8>
    80002052:	fd2fe0ef          	jal	80000824 <panic>
    panic("sched RUNNING");
    80002056:	00006517          	auipc	a0,0x6
    8000205a:	17250513          	addi	a0,a0,370 # 800081c8 <etext+0x1c8>
    8000205e:	fc6fe0ef          	jal	80000824 <panic>
    panic("sched interruptible");
    80002062:	00006517          	auipc	a0,0x6
    80002066:	17650513          	addi	a0,a0,374 # 800081d8 <etext+0x1d8>
    8000206a:	fbafe0ef          	jal	80000824 <panic>

000000008000206e <yield>:
void yield(void) {
    8000206e:	1101                	addi	sp,sp,-32
    80002070:	ec06                	sd	ra,24(sp)
    80002072:	e822                	sd	s0,16(sp)
    80002074:	e426                	sd	s1,8(sp)
    80002076:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002078:	913ff0ef          	jal	8000198a <myproc>
    8000207c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000207e:	babfe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80002082:	478d                	li	a5,3
    80002084:	cc9c                	sw	a5,24(s1)
  sched();
    80002086:	f2dff0ef          	jal	80001fb2 <sched>
  release(&p->lock);
    8000208a:	8526                	mv	a0,s1
    8000208c:	c31fe0ef          	jal	80000cbc <release>
}
    80002090:	60e2                	ld	ra,24(sp)
    80002092:	6442                	ld	s0,16(sp)
    80002094:	64a2                	ld	s1,8(sp)
    80002096:	6105                	addi	sp,sp,32
    80002098:	8082                	ret

000000008000209a <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void sleep(void *chan, struct spinlock *lk) {
    8000209a:	7179                	addi	sp,sp,-48
    8000209c:	f406                	sd	ra,40(sp)
    8000209e:	f022                	sd	s0,32(sp)
    800020a0:	ec26                	sd	s1,24(sp)
    800020a2:	e84a                	sd	s2,16(sp)
    800020a4:	e44e                	sd	s3,8(sp)
    800020a6:	1800                	addi	s0,sp,48
    800020a8:	89aa                	mv	s3,a0
    800020aa:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020ac:	8dfff0ef          	jal	8000198a <myproc>
    800020b0:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    800020b2:	b77fe0ef          	jal	80000c28 <acquire>
  release(lk);
    800020b6:	854a                	mv	a0,s2
    800020b8:	c05fe0ef          	jal	80000cbc <release>

  // Go to sleep.
  p->chan = chan;
    800020bc:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800020c0:	4789                	li	a5,2
    800020c2:	cc9c                	sw	a5,24(s1)

  sched();
    800020c4:	eefff0ef          	jal	80001fb2 <sched>

  // Tidy up.
  p->chan = 0;
    800020c8:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020cc:	8526                	mv	a0,s1
    800020ce:	beffe0ef          	jal	80000cbc <release>
  acquire(lk);
    800020d2:	854a                	mv	a0,s2
    800020d4:	b55fe0ef          	jal	80000c28 <acquire>
}
    800020d8:	70a2                	ld	ra,40(sp)
    800020da:	7402                	ld	s0,32(sp)
    800020dc:	64e2                	ld	s1,24(sp)
    800020de:	6942                	ld	s2,16(sp)
    800020e0:	69a2                	ld	s3,8(sp)
    800020e2:	6145                	addi	sp,sp,48
    800020e4:	8082                	ret

00000000800020e6 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void wakeup(void *chan) {
    800020e6:	7139                	addi	sp,sp,-64
    800020e8:	fc06                	sd	ra,56(sp)
    800020ea:	f822                	sd	s0,48(sp)
    800020ec:	f426                	sd	s1,40(sp)
    800020ee:	f04a                	sd	s2,32(sp)
    800020f0:	ec4e                	sd	s3,24(sp)
    800020f2:	e852                	sd	s4,16(sp)
    800020f4:	e456                	sd	s5,8(sp)
    800020f6:	e05a                	sd	s6,0(sp)
    800020f8:	0080                	addi	s0,sp,64
    800020fa:	8aaa                	mv	s5,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800020fc:	00012497          	auipc	s1,0x12
    80002100:	c8c48493          	addi	s1,s1,-884 # 80013d88 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    80002104:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80002106:	4b0d                	li	s6,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80002108:	6905                	lui	s2,0x1
    8000210a:	22090913          	addi	s2,s2,544 # 1220 <_entry-0x7fffede0>
    8000210e:	0005a997          	auipc	s3,0x5a
    80002112:	47a98993          	addi	s3,s3,1146 # 8005c588 <tickslock>
    80002116:	a039                	j	80002124 <wakeup+0x3e>
      }
      release(&p->lock);
    80002118:	8526                	mv	a0,s1
    8000211a:	ba3fe0ef          	jal	80000cbc <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000211e:	94ca                	add	s1,s1,s2
    80002120:	03348263          	beq	s1,s3,80002144 <wakeup+0x5e>
    if (p != myproc()) {
    80002124:	867ff0ef          	jal	8000198a <myproc>
    80002128:	fe950be3          	beq	a0,s1,8000211e <wakeup+0x38>
      acquire(&p->lock);
    8000212c:	8526                	mv	a0,s1
    8000212e:	afbfe0ef          	jal	80000c28 <acquire>
      if (p->state == SLEEPING && p->chan == chan) {
    80002132:	4c9c                	lw	a5,24(s1)
    80002134:	ff4792e3          	bne	a5,s4,80002118 <wakeup+0x32>
    80002138:	709c                	ld	a5,32(s1)
    8000213a:	fd579fe3          	bne	a5,s5,80002118 <wakeup+0x32>
        p->state = RUNNABLE;
    8000213e:	0164ac23          	sw	s6,24(s1)
    80002142:	bfd9                	j	80002118 <wakeup+0x32>
    }
  }
}
    80002144:	70e2                	ld	ra,56(sp)
    80002146:	7442                	ld	s0,48(sp)
    80002148:	74a2                	ld	s1,40(sp)
    8000214a:	7902                	ld	s2,32(sp)
    8000214c:	69e2                	ld	s3,24(sp)
    8000214e:	6a42                	ld	s4,16(sp)
    80002150:	6aa2                	ld	s5,8(sp)
    80002152:	6b02                	ld	s6,0(sp)
    80002154:	6121                	addi	sp,sp,64
    80002156:	8082                	ret

0000000080002158 <reparent>:
void reparent(struct proc *p) {
    80002158:	7139                	addi	sp,sp,-64
    8000215a:	fc06                	sd	ra,56(sp)
    8000215c:	f822                	sd	s0,48(sp)
    8000215e:	f426                	sd	s1,40(sp)
    80002160:	f04a                	sd	s2,32(sp)
    80002162:	ec4e                	sd	s3,24(sp)
    80002164:	e852                	sd	s4,16(sp)
    80002166:	e456                	sd	s5,8(sp)
    80002168:	0080                	addi	s0,sp,64
    8000216a:	89aa                	mv	s3,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000216c:	00012497          	auipc	s1,0x12
    80002170:	c1c48493          	addi	s1,s1,-996 # 80013d88 <proc>
      pp->parent = initproc;
    80002174:	00009a97          	auipc	s5,0x9
    80002178:	6dca8a93          	addi	s5,s5,1756 # 8000b850 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000217c:	6905                	lui	s2,0x1
    8000217e:	22090913          	addi	s2,s2,544 # 1220 <_entry-0x7fffede0>
    80002182:	0005aa17          	auipc	s4,0x5a
    80002186:	406a0a13          	addi	s4,s4,1030 # 8005c588 <tickslock>
    8000218a:	a021                	j	80002192 <reparent+0x3a>
    8000218c:	94ca                	add	s1,s1,s2
    8000218e:	01448b63          	beq	s1,s4,800021a4 <reparent+0x4c>
    if (pp->parent == p) {
    80002192:	60bc                	ld	a5,64(s1)
    80002194:	ff379ce3          	bne	a5,s3,8000218c <reparent+0x34>
      pp->parent = initproc;
    80002198:	000ab503          	ld	a0,0(s5)
    8000219c:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    8000219e:	f49ff0ef          	jal	800020e6 <wakeup>
    800021a2:	b7ed                	j	8000218c <reparent+0x34>
}
    800021a4:	70e2                	ld	ra,56(sp)
    800021a6:	7442                	ld	s0,48(sp)
    800021a8:	74a2                	ld	s1,40(sp)
    800021aa:	7902                	ld	s2,32(sp)
    800021ac:	69e2                	ld	s3,24(sp)
    800021ae:	6a42                	ld	s4,16(sp)
    800021b0:	6aa2                	ld	s5,8(sp)
    800021b2:	6121                	addi	sp,sp,64
    800021b4:	8082                	ret

00000000800021b6 <kexit>:
void kexit(int status) {
    800021b6:	7179                	addi	sp,sp,-48
    800021b8:	f406                	sd	ra,40(sp)
    800021ba:	f022                	sd	s0,32(sp)
    800021bc:	ec26                	sd	s1,24(sp)
    800021be:	e84a                	sd	s2,16(sp)
    800021c0:	e44e                	sd	s3,8(sp)
    800021c2:	e052                	sd	s4,0(sp)
    800021c4:	1800                	addi	s0,sp,48
    800021c6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021c8:	fc2ff0ef          	jal	8000198a <myproc>
    800021cc:	89aa                	mv	s3,a0
  if (p == initproc)
    800021ce:	00009797          	auipc	a5,0x9
    800021d2:	6827b783          	ld	a5,1666(a5) # 8000b850 <initproc>
    800021d6:	0d850493          	addi	s1,a0,216
    800021da:	15850913          	addi	s2,a0,344
    800021de:	00a79b63          	bne	a5,a0,800021f4 <kexit+0x3e>
    panic("init exiting");
    800021e2:	00006517          	auipc	a0,0x6
    800021e6:	00e50513          	addi	a0,a0,14 # 800081f0 <etext+0x1f0>
    800021ea:	e3afe0ef          	jal	80000824 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    800021ee:	04a1                	addi	s1,s1,8
    800021f0:	01248963          	beq	s1,s2,80002202 <kexit+0x4c>
    if (p->ofile[fd]) {
    800021f4:	6088                	ld	a0,0(s1)
    800021f6:	dd65                	beqz	a0,800021ee <kexit+0x38>
      fileclose(f);
    800021f8:	622020ef          	jal	8000481a <fileclose>
      p->ofile[fd] = 0;
    800021fc:	0004b023          	sd	zero,0(s1)
    80002200:	b7fd                	j	800021ee <kexit+0x38>
  begin_op();
    80002202:	1f4020ef          	jal	800043f6 <begin_op>
  iput(p->cwd);
    80002206:	1589b503          	ld	a0,344(s3)
    8000220a:	163010ef          	jal	80003b6c <iput>
  end_op();
    8000220e:	258020ef          	jal	80004466 <end_op>
  p->cwd = 0;
    80002212:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    80002216:	00011517          	auipc	a0,0x11
    8000221a:	75a50513          	addi	a0,a0,1882 # 80013970 <wait_lock>
    8000221e:	a0bfe0ef          	jal	80000c28 <acquire>
  reparent(p);
    80002222:	854e                	mv	a0,s3
    80002224:	f35ff0ef          	jal	80002158 <reparent>
  wakeup(p->parent);
    80002228:	0409b503          	ld	a0,64(s3)
    8000222c:	ebbff0ef          	jal	800020e6 <wakeup>
  acquire(&p->lock);
    80002230:	854e                	mv	a0,s3
    80002232:	9f7fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    80002236:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000223a:	4795                	li	a5,5
    8000223c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002240:	00011517          	auipc	a0,0x11
    80002244:	73050513          	addi	a0,a0,1840 # 80013970 <wait_lock>
    80002248:	a75fe0ef          	jal	80000cbc <release>
  sched();
    8000224c:	d67ff0ef          	jal	80001fb2 <sched>
  panic("zombie exit");
    80002250:	00006517          	auipc	a0,0x6
    80002254:	fb050513          	addi	a0,a0,-80 # 80008200 <etext+0x200>
    80002258:	dccfe0ef          	jal	80000824 <panic>

000000008000225c <kkill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kkill(int pid) {
    8000225c:	7179                	addi	sp,sp,-48
    8000225e:	f406                	sd	ra,40(sp)
    80002260:	f022                	sd	s0,32(sp)
    80002262:	ec26                	sd	s1,24(sp)
    80002264:	e84a                	sd	s2,16(sp)
    80002266:	e44e                	sd	s3,8(sp)
    80002268:	e052                	sd	s4,0(sp)
    8000226a:	1800                	addi	s0,sp,48
    8000226c:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    8000226e:	00012497          	auipc	s1,0x12
    80002272:	b1a48493          	addi	s1,s1,-1254 # 80013d88 <proc>
    80002276:	6985                	lui	s3,0x1
    80002278:	22098993          	addi	s3,s3,544 # 1220 <_entry-0x7fffede0>
    8000227c:	0005aa17          	auipc	s4,0x5a
    80002280:	30ca0a13          	addi	s4,s4,780 # 8005c588 <tickslock>
    acquire(&p->lock);
    80002284:	8526                	mv	a0,s1
    80002286:	9a3fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    8000228a:	589c                	lw	a5,48(s1)
    8000228c:	01278a63          	beq	a5,s2,800022a0 <kkill+0x44>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002290:	8526                	mv	a0,s1
    80002292:	a2bfe0ef          	jal	80000cbc <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002296:	94ce                	add	s1,s1,s3
    80002298:	ff4496e3          	bne	s1,s4,80002284 <kkill+0x28>
  }
  return -1;
    8000229c:	557d                	li	a0,-1
    8000229e:	a819                	j	800022b4 <kkill+0x58>
      p->killed = 1;
    800022a0:	4785                	li	a5,1
    800022a2:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    800022a4:	4c98                	lw	a4,24(s1)
    800022a6:	4789                	li	a5,2
    800022a8:	00f70e63          	beq	a4,a5,800022c4 <kkill+0x68>
      release(&p->lock);
    800022ac:	8526                	mv	a0,s1
    800022ae:	a0ffe0ef          	jal	80000cbc <release>
      return 0;
    800022b2:	4501                	li	a0,0
}
    800022b4:	70a2                	ld	ra,40(sp)
    800022b6:	7402                	ld	s0,32(sp)
    800022b8:	64e2                	ld	s1,24(sp)
    800022ba:	6942                	ld	s2,16(sp)
    800022bc:	69a2                	ld	s3,8(sp)
    800022be:	6a02                	ld	s4,0(sp)
    800022c0:	6145                	addi	sp,sp,48
    800022c2:	8082                	ret
        p->state = RUNNABLE;
    800022c4:	478d                	li	a5,3
    800022c6:	cc9c                	sw	a5,24(s1)
    800022c8:	b7d5                	j	800022ac <kkill+0x50>

00000000800022ca <setkilled>:

void setkilled(struct proc *p) {
    800022ca:	1101                	addi	sp,sp,-32
    800022cc:	ec06                	sd	ra,24(sp)
    800022ce:	e822                	sd	s0,16(sp)
    800022d0:	e426                	sd	s1,8(sp)
    800022d2:	1000                	addi	s0,sp,32
    800022d4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022d6:	953fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    800022da:	4785                	li	a5,1
    800022dc:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022de:	8526                	mv	a0,s1
    800022e0:	9ddfe0ef          	jal	80000cbc <release>
}
    800022e4:	60e2                	ld	ra,24(sp)
    800022e6:	6442                	ld	s0,16(sp)
    800022e8:	64a2                	ld	s1,8(sp)
    800022ea:	6105                	addi	sp,sp,32
    800022ec:	8082                	ret

00000000800022ee <killed>:

int killed(struct proc *p) {
    800022ee:	1101                	addi	sp,sp,-32
    800022f0:	ec06                	sd	ra,24(sp)
    800022f2:	e822                	sd	s0,16(sp)
    800022f4:	e426                	sd	s1,8(sp)
    800022f6:	e04a                	sd	s2,0(sp)
    800022f8:	1000                	addi	s0,sp,32
    800022fa:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800022fc:	92dfe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    80002300:	549c                	lw	a5,40(s1)
    80002302:	893e                	mv	s2,a5
  release(&p->lock);
    80002304:	8526                	mv	a0,s1
    80002306:	9b7fe0ef          	jal	80000cbc <release>
  return k;
}
    8000230a:	854a                	mv	a0,s2
    8000230c:	60e2                	ld	ra,24(sp)
    8000230e:	6442                	ld	s0,16(sp)
    80002310:	64a2                	ld	s1,8(sp)
    80002312:	6902                	ld	s2,0(sp)
    80002314:	6105                	addi	sp,sp,32
    80002316:	8082                	ret

0000000080002318 <kwait>:
int kwait(uint64 addr) {
    80002318:	715d                	addi	sp,sp,-80
    8000231a:	e486                	sd	ra,72(sp)
    8000231c:	e0a2                	sd	s0,64(sp)
    8000231e:	fc26                	sd	s1,56(sp)
    80002320:	f84a                	sd	s2,48(sp)
    80002322:	f44e                	sd	s3,40(sp)
    80002324:	f052                	sd	s4,32(sp)
    80002326:	ec56                	sd	s5,24(sp)
    80002328:	e85a                	sd	s6,16(sp)
    8000232a:	e45e                	sd	s7,8(sp)
    8000232c:	0880                	addi	s0,sp,80
    8000232e:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002330:	e5aff0ef          	jal	8000198a <myproc>
    80002334:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002336:	00011517          	auipc	a0,0x11
    8000233a:	63a50513          	addi	a0,a0,1594 # 80013970 <wait_lock>
    8000233e:	8ebfe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002342:	4a95                	li	s5,5
        havekids = 1;
    80002344:	4b05                	li	s6,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002346:	6985                	lui	s3,0x1
    80002348:	22098993          	addi	s3,s3,544 # 1220 <_entry-0x7fffede0>
    8000234c:	0005aa17          	auipc	s4,0x5a
    80002350:	23ca0a13          	addi	s4,s4,572 # 8005c588 <tickslock>
    80002354:	a879                	j	800023f2 <kwait+0xda>
          pid = pp->pid;
    80002356:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000235a:	000b8c63          	beqz	s7,80002372 <kwait+0x5a>
    8000235e:	4691                	li	a3,4
    80002360:	02c48613          	addi	a2,s1,44
    80002364:	85de                	mv	a1,s7
    80002366:	05893503          	ld	a0,88(s2)
    8000236a:	aeaff0ef          	jal	80001654 <copyout>
    8000236e:	02054a63          	bltz	a0,800023a2 <kwait+0x8a>
          freeproc(pp);
    80002372:	8526                	mv	a0,s1
    80002374:	feaff0ef          	jal	80001b5e <freeproc>
          release(&pp->lock);
    80002378:	8526                	mv	a0,s1
    8000237a:	943fe0ef          	jal	80000cbc <release>
          release(&wait_lock);
    8000237e:	00011517          	auipc	a0,0x11
    80002382:	5f250513          	addi	a0,a0,1522 # 80013970 <wait_lock>
    80002386:	937fe0ef          	jal	80000cbc <release>
}
    8000238a:	854e                	mv	a0,s3
    8000238c:	60a6                	ld	ra,72(sp)
    8000238e:	6406                	ld	s0,64(sp)
    80002390:	74e2                	ld	s1,56(sp)
    80002392:	7942                	ld	s2,48(sp)
    80002394:	79a2                	ld	s3,40(sp)
    80002396:	7a02                	ld	s4,32(sp)
    80002398:	6ae2                	ld	s5,24(sp)
    8000239a:	6b42                	ld	s6,16(sp)
    8000239c:	6ba2                	ld	s7,8(sp)
    8000239e:	6161                	addi	sp,sp,80
    800023a0:	8082                	ret
            release(&pp->lock);
    800023a2:	8526                	mv	a0,s1
    800023a4:	919fe0ef          	jal	80000cbc <release>
            release(&wait_lock);
    800023a8:	00011517          	auipc	a0,0x11
    800023ac:	5c850513          	addi	a0,a0,1480 # 80013970 <wait_lock>
    800023b0:	90dfe0ef          	jal	80000cbc <release>
            return -1;
    800023b4:	59fd                	li	s3,-1
    800023b6:	bfd1                	j	8000238a <kwait+0x72>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800023b8:	94ce                	add	s1,s1,s3
    800023ba:	03448063          	beq	s1,s4,800023da <kwait+0xc2>
      if (pp->parent == p) {
    800023be:	60bc                	ld	a5,64(s1)
    800023c0:	ff279ce3          	bne	a5,s2,800023b8 <kwait+0xa0>
        acquire(&pp->lock);
    800023c4:	8526                	mv	a0,s1
    800023c6:	863fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    800023ca:	4c9c                	lw	a5,24(s1)
    800023cc:	f95785e3          	beq	a5,s5,80002356 <kwait+0x3e>
        release(&pp->lock);
    800023d0:	8526                	mv	a0,s1
    800023d2:	8ebfe0ef          	jal	80000cbc <release>
        havekids = 1;
    800023d6:	875a                	mv	a4,s6
    800023d8:	b7c5                	j	800023b8 <kwait+0xa0>
    if (!havekids || killed(p)) {
    800023da:	c315                	beqz	a4,800023fe <kwait+0xe6>
    800023dc:	854a                	mv	a0,s2
    800023de:	f11ff0ef          	jal	800022ee <killed>
    800023e2:	ed11                	bnez	a0,800023fe <kwait+0xe6>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800023e4:	00011597          	auipc	a1,0x11
    800023e8:	58c58593          	addi	a1,a1,1420 # 80013970 <wait_lock>
    800023ec:	854a                	mv	a0,s2
    800023ee:	cadff0ef          	jal	8000209a <sleep>
    havekids = 0;
    800023f2:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800023f4:	00012497          	auipc	s1,0x12
    800023f8:	99448493          	addi	s1,s1,-1644 # 80013d88 <proc>
    800023fc:	b7c9                	j	800023be <kwait+0xa6>
      release(&wait_lock);
    800023fe:	00011517          	auipc	a0,0x11
    80002402:	57250513          	addi	a0,a0,1394 # 80013970 <wait_lock>
    80002406:	8b7fe0ef          	jal	80000cbc <release>
      return -1;
    8000240a:	59fd                	li	s3,-1
    8000240c:	bfbd                	j	8000238a <kwait+0x72>

000000008000240e <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len) {
    8000240e:	7179                	addi	sp,sp,-48
    80002410:	f406                	sd	ra,40(sp)
    80002412:	f022                	sd	s0,32(sp)
    80002414:	ec26                	sd	s1,24(sp)
    80002416:	e84a                	sd	s2,16(sp)
    80002418:	e44e                	sd	s3,8(sp)
    8000241a:	e052                	sd	s4,0(sp)
    8000241c:	1800                	addi	s0,sp,48
    8000241e:	84aa                	mv	s1,a0
    80002420:	8a2e                	mv	s4,a1
    80002422:	89b2                	mv	s3,a2
    80002424:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002426:	d64ff0ef          	jal	8000198a <myproc>
  if (user_dst) {
    8000242a:	cc99                	beqz	s1,80002448 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000242c:	86ca                	mv	a3,s2
    8000242e:	864e                	mv	a2,s3
    80002430:	85d2                	mv	a1,s4
    80002432:	6d28                	ld	a0,88(a0)
    80002434:	a20ff0ef          	jal	80001654 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002438:	70a2                	ld	ra,40(sp)
    8000243a:	7402                	ld	s0,32(sp)
    8000243c:	64e2                	ld	s1,24(sp)
    8000243e:	6942                	ld	s2,16(sp)
    80002440:	69a2                	ld	s3,8(sp)
    80002442:	6a02                	ld	s4,0(sp)
    80002444:	6145                	addi	sp,sp,48
    80002446:	8082                	ret
    memmove((char *)dst, src, len);
    80002448:	0009061b          	sext.w	a2,s2
    8000244c:	85ce                	mv	a1,s3
    8000244e:	8552                	mv	a0,s4
    80002450:	909fe0ef          	jal	80000d58 <memmove>
    return 0;
    80002454:	8526                	mv	a0,s1
    80002456:	b7cd                	j	80002438 <either_copyout+0x2a>

0000000080002458 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len) {
    80002458:	7179                	addi	sp,sp,-48
    8000245a:	f406                	sd	ra,40(sp)
    8000245c:	f022                	sd	s0,32(sp)
    8000245e:	ec26                	sd	s1,24(sp)
    80002460:	e84a                	sd	s2,16(sp)
    80002462:	e44e                	sd	s3,8(sp)
    80002464:	e052                	sd	s4,0(sp)
    80002466:	1800                	addi	s0,sp,48
    80002468:	8a2a                	mv	s4,a0
    8000246a:	84ae                	mv	s1,a1
    8000246c:	89b2                	mv	s3,a2
    8000246e:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002470:	d1aff0ef          	jal	8000198a <myproc>
  if (user_src) {
    80002474:	cc99                	beqz	s1,80002492 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002476:	86ca                	mv	a3,s2
    80002478:	864e                	mv	a2,s3
    8000247a:	85d2                	mv	a1,s4
    8000247c:	6d28                	ld	a0,88(a0)
    8000247e:	a94ff0ef          	jal	80001712 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002482:	70a2                	ld	ra,40(sp)
    80002484:	7402                	ld	s0,32(sp)
    80002486:	64e2                	ld	s1,24(sp)
    80002488:	6942                	ld	s2,16(sp)
    8000248a:	69a2                	ld	s3,8(sp)
    8000248c:	6a02                	ld	s4,0(sp)
    8000248e:	6145                	addi	sp,sp,48
    80002490:	8082                	ret
    memmove(dst, (char *)src, len);
    80002492:	0009061b          	sext.w	a2,s2
    80002496:	85ce                	mv	a1,s3
    80002498:	8552                	mv	a0,s4
    8000249a:	8bffe0ef          	jal	80000d58 <memmove>
    return 0;
    8000249e:	8526                	mv	a0,s1
    800024a0:	b7cd                	j	80002482 <either_copyin+0x2a>

00000000800024a2 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void) {
    800024a2:	715d                	addi	sp,sp,-80
    800024a4:	e486                	sd	ra,72(sp)
    800024a6:	e0a2                	sd	s0,64(sp)
    800024a8:	fc26                	sd	s1,56(sp)
    800024aa:	f84a                	sd	s2,48(sp)
    800024ac:	f44e                	sd	s3,40(sp)
    800024ae:	f052                	sd	s4,32(sp)
    800024b0:	ec56                	sd	s5,24(sp)
    800024b2:	e85a                	sd	s6,16(sp)
    800024b4:	e45e                	sd	s7,8(sp)
    800024b6:	e062                	sd	s8,0(sp)
    800024b8:	0880                	addi	s0,sp,80
      [UNUSED] = "unused",   [USED] = "used",      [SLEEPING] = "sleep ",
      [RUNNABLE] = "runble", [RUNNING] = "run   ", [ZOMBIE] = "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    800024ba:	00006517          	auipc	a0,0x6
    800024be:	bbe50513          	addi	a0,a0,-1090 # 80008078 <etext+0x78>
    800024c2:	838fe0ef          	jal	800004fa <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    800024c6:	00012497          	auipc	s1,0x12
    800024ca:	a2248493          	addi	s1,s1,-1502 # 80013ee8 <proc+0x160>
    800024ce:	0005a997          	auipc	s3,0x5a
    800024d2:	21a98993          	addi	s3,s3,538 # 8005c6e8 <shmtable+0x148>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024d6:	4b95                	li	s7,5
      state = states[p->state];
    else
      state = "???";
    800024d8:	00006a17          	auipc	s4,0x6
    800024dc:	d38a0a13          	addi	s4,s4,-712 # 80008210 <etext+0x210>
    printf("%d %s %s", p->pid, state, p->name);
    800024e0:	00006b17          	auipc	s6,0x6
    800024e4:	d38b0b13          	addi	s6,s6,-712 # 80008218 <etext+0x218>
    printf("\n");
    800024e8:	00006a97          	auipc	s5,0x6
    800024ec:	b90a8a93          	addi	s5,s5,-1136 # 80008078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024f0:	00006c17          	auipc	s8,0x6
    800024f4:	268c0c13          	addi	s8,s8,616 # 80008758 <states.0>
  for (p = proc; p < &proc[NPROC]; p++) {
    800024f8:	6905                	lui	s2,0x1
    800024fa:	22090913          	addi	s2,s2,544 # 1220 <_entry-0x7fffede0>
    800024fe:	a821                	j	80002516 <procdump+0x74>
    printf("%d %s %s", p->pid, state, p->name);
    80002500:	ed06a583          	lw	a1,-304(a3)
    80002504:	855a                	mv	a0,s6
    80002506:	ff5fd0ef          	jal	800004fa <printf>
    printf("\n");
    8000250a:	8556                	mv	a0,s5
    8000250c:	feffd0ef          	jal	800004fa <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002510:	94ca                	add	s1,s1,s2
    80002512:	03348263          	beq	s1,s3,80002536 <procdump+0x94>
    if (p->state == UNUSED)
    80002516:	86a6                	mv	a3,s1
    80002518:	eb84a783          	lw	a5,-328(s1)
    8000251c:	dbf5                	beqz	a5,80002510 <procdump+0x6e>
      state = "???";
    8000251e:	8652                	mv	a2,s4
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002520:	fefbe0e3          	bltu	s7,a5,80002500 <procdump+0x5e>
    80002524:	02079713          	slli	a4,a5,0x20
    80002528:	01d75793          	srli	a5,a4,0x1d
    8000252c:	97e2                	add	a5,a5,s8
    8000252e:	6390                	ld	a2,0(a5)
    80002530:	fa61                	bnez	a2,80002500 <procdump+0x5e>
      state = "???";
    80002532:	8652                	mv	a2,s4
    80002534:	b7f1                	j	80002500 <procdump+0x5e>
  }
}
    80002536:	60a6                	ld	ra,72(sp)
    80002538:	6406                	ld	s0,64(sp)
    8000253a:	74e2                	ld	s1,56(sp)
    8000253c:	7942                	ld	s2,48(sp)
    8000253e:	79a2                	ld	s3,40(sp)
    80002540:	7a02                	ld	s4,32(sp)
    80002542:	6ae2                	ld	s5,24(sp)
    80002544:	6b42                	ld	s6,16(sp)
    80002546:	6ba2                	ld	s7,8(sp)
    80002548:	6c02                	ld	s8,0(sp)
    8000254a:	6161                	addi	sp,sp,80
    8000254c:	8082                	ret

000000008000254e <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000254e:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002552:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002556:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002558:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000255a:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000255e:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002562:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002566:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000256a:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000256e:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002572:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002576:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000257a:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000257e:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002582:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002586:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000258a:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000258c:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000258e:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002592:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002596:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000259a:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    8000259e:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800025a2:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800025a6:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800025aa:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800025ae:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800025b2:	0685bd83          	ld	s11,104(a1)
        
        ret
    800025b6:	8082                	ret

00000000800025b8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800025b8:	1141                	addi	sp,sp,-16
    800025ba:	e406                	sd	ra,8(sp)
    800025bc:	e022                	sd	s0,0(sp)
    800025be:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800025c0:	00006597          	auipc	a1,0x6
    800025c4:	c9858593          	addi	a1,a1,-872 # 80008258 <etext+0x258>
    800025c8:	0005a517          	auipc	a0,0x5a
    800025cc:	fc050513          	addi	a0,a0,-64 # 8005c588 <tickslock>
    800025d0:	dcefe0ef          	jal	80000b9e <initlock>
}
    800025d4:	60a2                	ld	ra,8(sp)
    800025d6:	6402                	ld	s0,0(sp)
    800025d8:	0141                	addi	sp,sp,16
    800025da:	8082                	ret

00000000800025dc <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800025dc:	1141                	addi	sp,sp,-16
    800025de:	e406                	sd	ra,8(sp)
    800025e0:	e022                	sd	s0,0(sp)
    800025e2:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    800025e4:	00003797          	auipc	a5,0x3
    800025e8:	5fc78793          	addi	a5,a5,1532 # 80005be0 <kernelvec>
    800025ec:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800025f0:	60a2                	ld	ra,8(sp)
    800025f2:	6402                	ld	s0,0(sp)
    800025f4:	0141                	addi	sp,sp,16
    800025f6:	8082                	ret

00000000800025f8 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800025f8:	1141                	addi	sp,sp,-16
    800025fa:	e406                	sd	ra,8(sp)
    800025fc:	e022                	sd	s0,0(sp)
    800025fe:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002600:	b8aff0ef          	jal	8000198a <myproc>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002604:	100027f3          	csrr	a5,sstatus
static inline void intr_off() { w_sstatus(r_sstatus() & ~SSTATUS_SIE); }
    80002608:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000260a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000260e:	04000737          	lui	a4,0x4000
    80002612:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002614:	0732                	slli	a4,a4,0xc
    80002616:	00005797          	auipc	a5,0x5
    8000261a:	9ea78793          	addi	a5,a5,-1558 # 80007000 <_trampoline>
    8000261e:	00005697          	auipc	a3,0x5
    80002622:	9e268693          	addi	a3,a3,-1566 # 80007000 <_trampoline>
    80002626:	8f95                	sub	a5,a5,a3
    80002628:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000262a:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000262e:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    80002630:	18002773          	csrr	a4,satp
    80002634:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002636:	7138                	ld	a4,96(a0)
    80002638:	653c                	ld	a5,72(a0)
    8000263a:	6685                	lui	a3,0x1
    8000263c:	97b6                	add	a5,a5,a3
    8000263e:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002640:	713c                	ld	a5,96(a0)
    80002642:	00000717          	auipc	a4,0x0
    80002646:	0fc70713          	addi	a4,a4,252 # 8000273e <usertrap>
    8000264a:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000264c:	713c                	ld	a5,96(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    8000264e:	8712                	mv	a4,tp
    80002650:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002652:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002656:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000265a:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000265e:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002662:	713c                	ld	a5,96(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002664:	6f9c                	ld	a5,24(a5)
    80002666:	14179073          	csrw	sepc,a5
}
    8000266a:	60a2                	ld	ra,8(sp)
    8000266c:	6402                	ld	s0,0(sp)
    8000266e:	0141                	addi	sp,sp,16
    80002670:	8082                	ret

0000000080002672 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002672:	1141                	addi	sp,sp,-16
    80002674:	e406                	sd	ra,8(sp)
    80002676:	e022                	sd	s0,0(sp)
    80002678:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000267a:	adcff0ef          	jal	80001956 <cpuid>
    8000267e:	cd11                	beqz	a0,8000269a <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    80002680:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002684:	000f4737          	lui	a4,0xf4
    80002688:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000268c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000268e:	14d79073          	csrw	stimecmp,a5
}
    80002692:	60a2                	ld	ra,8(sp)
    80002694:	6402                	ld	s0,0(sp)
    80002696:	0141                	addi	sp,sp,16
    80002698:	8082                	ret
    acquire(&tickslock);
    8000269a:	0005a517          	auipc	a0,0x5a
    8000269e:	eee50513          	addi	a0,a0,-274 # 8005c588 <tickslock>
    800026a2:	d86fe0ef          	jal	80000c28 <acquire>
    ticks++;
    800026a6:	00009717          	auipc	a4,0x9
    800026aa:	1b270713          	addi	a4,a4,434 # 8000b858 <ticks>
    800026ae:	431c                	lw	a5,0(a4)
    800026b0:	2785                	addiw	a5,a5,1
    800026b2:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    800026b4:	853a                	mv	a0,a4
    800026b6:	a31ff0ef          	jal	800020e6 <wakeup>
    release(&tickslock);
    800026ba:	0005a517          	auipc	a0,0x5a
    800026be:	ece50513          	addi	a0,a0,-306 # 8005c588 <tickslock>
    800026c2:	dfafe0ef          	jal	80000cbc <release>
    800026c6:	bf6d                	j	80002680 <clockintr+0xe>

00000000800026c8 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800026c8:	1101                	addi	sp,sp,-32
    800026ca:	ec06                	sd	ra,24(sp)
    800026cc:	e822                	sd	s0,16(sp)
    800026ce:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    800026d0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800026d4:	57fd                	li	a5,-1
    800026d6:	17fe                	slli	a5,a5,0x3f
    800026d8:	07a5                	addi	a5,a5,9
    800026da:	00f70c63          	beq	a4,a5,800026f2 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800026de:	57fd                	li	a5,-1
    800026e0:	17fe                	slli	a5,a5,0x3f
    800026e2:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800026e4:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800026e6:	04f70863          	beq	a4,a5,80002736 <devintr+0x6e>
  }
}
    800026ea:	60e2                	ld	ra,24(sp)
    800026ec:	6442                	ld	s0,16(sp)
    800026ee:	6105                	addi	sp,sp,32
    800026f0:	8082                	ret
    800026f2:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800026f4:	598030ef          	jal	80005c8c <plic_claim>
    800026f8:	872a                	mv	a4,a0
    800026fa:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800026fc:	47a9                	li	a5,10
    800026fe:	00f50963          	beq	a0,a5,80002710 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    80002702:	4785                	li	a5,1
    80002704:	00f50963          	beq	a0,a5,80002716 <devintr+0x4e>
    return 1;
    80002708:	4505                	li	a0,1
    } else if(irq){
    8000270a:	eb09                	bnez	a4,8000271c <devintr+0x54>
    8000270c:	64a2                	ld	s1,8(sp)
    8000270e:	bff1                	j	800026ea <devintr+0x22>
      uartintr();
    80002710:	ae4fe0ef          	jal	800009f4 <uartintr>
    if(irq)
    80002714:	a819                	j	8000272a <devintr+0x62>
      virtio_disk_intr();
    80002716:	20d030ef          	jal	80006122 <virtio_disk_intr>
    if(irq)
    8000271a:	a801                	j	8000272a <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    8000271c:	85ba                	mv	a1,a4
    8000271e:	00006517          	auipc	a0,0x6
    80002722:	b4250513          	addi	a0,a0,-1214 # 80008260 <etext+0x260>
    80002726:	dd5fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    8000272a:	8526                	mv	a0,s1
    8000272c:	580030ef          	jal	80005cac <plic_complete>
    return 1;
    80002730:	4505                	li	a0,1
    80002732:	64a2                	ld	s1,8(sp)
    80002734:	bf5d                	j	800026ea <devintr+0x22>
    clockintr();
    80002736:	f3dff0ef          	jal	80002672 <clockintr>
    return 2;
    8000273a:	4509                	li	a0,2
    8000273c:	b77d                	j	800026ea <devintr+0x22>

000000008000273e <usertrap>:
{
    8000273e:	1101                	addi	sp,sp,-32
    80002740:	ec06                	sd	ra,24(sp)
    80002742:	e822                	sd	s0,16(sp)
    80002744:	e426                	sd	s1,8(sp)
    80002746:	e04a                	sd	s2,0(sp)
    80002748:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000274a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000274e:	1007f793          	andi	a5,a5,256
    80002752:	eba5                	bnez	a5,800027c2 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002754:	00003797          	auipc	a5,0x3
    80002758:	48c78793          	addi	a5,a5,1164 # 80005be0 <kernelvec>
    8000275c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002760:	a2aff0ef          	jal	8000198a <myproc>
    80002764:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002766:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002768:	14102773          	csrr	a4,sepc
    8000276c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    8000276e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002772:	47a1                	li	a5,8
    80002774:	04f70d63          	beq	a4,a5,800027ce <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002778:	f51ff0ef          	jal	800026c8 <devintr>
    8000277c:	892a                	mv	s2,a0
    8000277e:	e945                	bnez	a0,8000282e <usertrap+0xf0>
    80002780:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002784:	47bd                	li	a5,15
    80002786:	08f70863          	beq	a4,a5,80002816 <usertrap+0xd8>
    8000278a:	14202773          	csrr	a4,scause
    8000278e:	47b5                	li	a5,13
    80002790:	08f70363          	beq	a4,a5,80002816 <usertrap+0xd8>
    80002794:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002798:	5890                	lw	a2,48(s1)
    8000279a:	00006517          	auipc	a0,0x6
    8000279e:	b0650513          	addi	a0,a0,-1274 # 800082a0 <etext+0x2a0>
    800027a2:	d59fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800027a6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800027aa:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800027ae:	00006517          	auipc	a0,0x6
    800027b2:	b2250513          	addi	a0,a0,-1246 # 800082d0 <etext+0x2d0>
    800027b6:	d45fd0ef          	jal	800004fa <printf>
    setkilled(p);
    800027ba:	8526                	mv	a0,s1
    800027bc:	b0fff0ef          	jal	800022ca <setkilled>
    800027c0:	a035                	j	800027ec <usertrap+0xae>
    panic("usertrap: not from user mode");
    800027c2:	00006517          	auipc	a0,0x6
    800027c6:	abe50513          	addi	a0,a0,-1346 # 80008280 <etext+0x280>
    800027ca:	85afe0ef          	jal	80000824 <panic>
    if(killed(p))
    800027ce:	b21ff0ef          	jal	800022ee <killed>
    800027d2:	ed15                	bnez	a0,8000280e <usertrap+0xd0>
    p->trapframe->epc += 4;
    800027d4:	70b8                	ld	a4,96(s1)
    800027d6:	6f1c                	ld	a5,24(a4)
    800027d8:	0791                	addi	a5,a5,4
    800027da:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027dc:	100027f3          	csrr	a5,sstatus
static inline void intr_on() { w_sstatus(r_sstatus() | SSTATUS_SIE); }
    800027e0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800027e4:	10079073          	csrw	sstatus,a5
    syscall();
    800027e8:	240000ef          	jal	80002a28 <syscall>
  if(killed(p))
    800027ec:	8526                	mv	a0,s1
    800027ee:	b01ff0ef          	jal	800022ee <killed>
    800027f2:	e139                	bnez	a0,80002838 <usertrap+0xfa>
  prepare_return();
    800027f4:	e05ff0ef          	jal	800025f8 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800027f8:	6ca8                	ld	a0,88(s1)
    800027fa:	8131                	srli	a0,a0,0xc
    800027fc:	57fd                	li	a5,-1
    800027fe:	17fe                	slli	a5,a5,0x3f
    80002800:	8d5d                	or	a0,a0,a5
}
    80002802:	60e2                	ld	ra,24(sp)
    80002804:	6442                	ld	s0,16(sp)
    80002806:	64a2                	ld	s1,8(sp)
    80002808:	6902                	ld	s2,0(sp)
    8000280a:	6105                	addi	sp,sp,32
    8000280c:	8082                	ret
      kexit(-1);
    8000280e:	557d                	li	a0,-1
    80002810:	9a7ff0ef          	jal	800021b6 <kexit>
    80002814:	b7c1                	j	800027d4 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    80002816:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    8000281a:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    8000281e:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002820:	00163613          	seqz	a2,a2
    80002824:	6ca8                	ld	a0,88(s1)
    80002826:	dabfe0ef          	jal	800015d0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000282a:	f169                	bnez	a0,800027ec <usertrap+0xae>
    8000282c:	b7a5                	j	80002794 <usertrap+0x56>
  if(killed(p))
    8000282e:	8526                	mv	a0,s1
    80002830:	abfff0ef          	jal	800022ee <killed>
    80002834:	c511                	beqz	a0,80002840 <usertrap+0x102>
    80002836:	a011                	j	8000283a <usertrap+0xfc>
    80002838:	4901                	li	s2,0
    kexit(-1);
    8000283a:	557d                	li	a0,-1
    8000283c:	97bff0ef          	jal	800021b6 <kexit>
  if(which_dev == 2)
    80002840:	4789                	li	a5,2
    80002842:	faf919e3          	bne	s2,a5,800027f4 <usertrap+0xb6>
    yield();
    80002846:	829ff0ef          	jal	8000206e <yield>
    8000284a:	b76d                	j	800027f4 <usertrap+0xb6>

000000008000284c <kerneltrap>:
{
    8000284c:	7179                	addi	sp,sp,-48
    8000284e:	f406                	sd	ra,40(sp)
    80002850:	f022                	sd	s0,32(sp)
    80002852:	ec26                	sd	s1,24(sp)
    80002854:	e84a                	sd	s2,16(sp)
    80002856:	e44e                	sd	s3,8(sp)
    80002858:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000285a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000285e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    80002862:	142027f3          	csrr	a5,scause
    80002866:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002868:	1004f793          	andi	a5,s1,256
    8000286c:	c795                	beqz	a5,80002898 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000286e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002872:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002874:	eb85                	bnez	a5,800028a4 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    80002876:	e53ff0ef          	jal	800026c8 <devintr>
    8000287a:	c91d                	beqz	a0,800028b0 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    8000287c:	4789                	li	a5,2
    8000287e:	04f50a63          	beq	a0,a5,800028d2 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002882:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002886:	10049073          	csrw	sstatus,s1
}
    8000288a:	70a2                	ld	ra,40(sp)
    8000288c:	7402                	ld	s0,32(sp)
    8000288e:	64e2                	ld	s1,24(sp)
    80002890:	6942                	ld	s2,16(sp)
    80002892:	69a2                	ld	s3,8(sp)
    80002894:	6145                	addi	sp,sp,48
    80002896:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002898:	00006517          	auipc	a0,0x6
    8000289c:	a6050513          	addi	a0,a0,-1440 # 800082f8 <etext+0x2f8>
    800028a0:	f85fd0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    800028a4:	00006517          	auipc	a0,0x6
    800028a8:	a7c50513          	addi	a0,a0,-1412 # 80008320 <etext+0x320>
    800028ac:	f79fd0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800028b0:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800028b4:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800028b8:	85ce                	mv	a1,s3
    800028ba:	00006517          	auipc	a0,0x6
    800028be:	a8650513          	addi	a0,a0,-1402 # 80008340 <etext+0x340>
    800028c2:	c39fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    800028c6:	00006517          	auipc	a0,0x6
    800028ca:	aa250513          	addi	a0,a0,-1374 # 80008368 <etext+0x368>
    800028ce:	f57fd0ef          	jal	80000824 <panic>
  if(which_dev == 2 && myproc() != 0)
    800028d2:	8b8ff0ef          	jal	8000198a <myproc>
    800028d6:	d555                	beqz	a0,80002882 <kerneltrap+0x36>
    yield();
    800028d8:	f96ff0ef          	jal	8000206e <yield>
    800028dc:	b75d                	j	80002882 <kerneltrap+0x36>

00000000800028de <argraw>:
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    return -1;
  return strlen(buf);
}

static uint64 argraw(int n) {
    800028de:	1101                	addi	sp,sp,-32
    800028e0:	ec06                	sd	ra,24(sp)
    800028e2:	e822                	sd	s0,16(sp)
    800028e4:	e426                	sd	s1,8(sp)
    800028e6:	1000                	addi	s0,sp,32
    800028e8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800028ea:	8a0ff0ef          	jal	8000198a <myproc>
  switch (n) {
    800028ee:	4795                	li	a5,5
    800028f0:	0497e163          	bltu	a5,s1,80002932 <argraw+0x54>
    800028f4:	048a                	slli	s1,s1,0x2
    800028f6:	00006717          	auipc	a4,0x6
    800028fa:	e9270713          	addi	a4,a4,-366 # 80008788 <states.0+0x30>
    800028fe:	94ba                	add	s1,s1,a4
    80002900:	409c                	lw	a5,0(s1)
    80002902:	97ba                	add	a5,a5,a4
    80002904:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002906:	713c                	ld	a5,96(a0)
    80002908:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000290a:	60e2                	ld	ra,24(sp)
    8000290c:	6442                	ld	s0,16(sp)
    8000290e:	64a2                	ld	s1,8(sp)
    80002910:	6105                	addi	sp,sp,32
    80002912:	8082                	ret
    return p->trapframe->a1;
    80002914:	713c                	ld	a5,96(a0)
    80002916:	7fa8                	ld	a0,120(a5)
    80002918:	bfcd                	j	8000290a <argraw+0x2c>
    return p->trapframe->a2;
    8000291a:	713c                	ld	a5,96(a0)
    8000291c:	63c8                	ld	a0,128(a5)
    8000291e:	b7f5                	j	8000290a <argraw+0x2c>
    return p->trapframe->a3;
    80002920:	713c                	ld	a5,96(a0)
    80002922:	67c8                	ld	a0,136(a5)
    80002924:	b7dd                	j	8000290a <argraw+0x2c>
    return p->trapframe->a4;
    80002926:	713c                	ld	a5,96(a0)
    80002928:	6bc8                	ld	a0,144(a5)
    8000292a:	b7c5                	j	8000290a <argraw+0x2c>
    return p->trapframe->a5;
    8000292c:	713c                	ld	a5,96(a0)
    8000292e:	6fc8                	ld	a0,152(a5)
    80002930:	bfe9                	j	8000290a <argraw+0x2c>
  panic("argraw");
    80002932:	00006517          	auipc	a0,0x6
    80002936:	a4650513          	addi	a0,a0,-1466 # 80008378 <etext+0x378>
    8000293a:	eebfd0ef          	jal	80000824 <panic>

000000008000293e <fetchaddr>:
int fetchaddr(uint64 addr, uint64 *ip) {
    8000293e:	1101                	addi	sp,sp,-32
    80002940:	ec06                	sd	ra,24(sp)
    80002942:	e822                	sd	s0,16(sp)
    80002944:	e426                	sd	s1,8(sp)
    80002946:	e04a                	sd	s2,0(sp)
    80002948:	1000                	addi	s0,sp,32
    8000294a:	84aa                	mv	s1,a0
    8000294c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000294e:	83cff0ef          	jal	8000198a <myproc>
  if (addr >= p->sz ||
    80002952:	693c                	ld	a5,80(a0)
    80002954:	02f4f663          	bgeu	s1,a5,80002980 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002958:	00848713          	addi	a4,s1,8
  if (addr >= p->sz ||
    8000295c:	02e7e463          	bltu	a5,a4,80002984 <fetchaddr+0x46>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002960:	46a1                	li	a3,8
    80002962:	8626                	mv	a2,s1
    80002964:	85ca                	mv	a1,s2
    80002966:	6d28                	ld	a0,88(a0)
    80002968:	dabfe0ef          	jal	80001712 <copyin>
    8000296c:	00a03533          	snez	a0,a0
    80002970:	40a0053b          	negw	a0,a0
}
    80002974:	60e2                	ld	ra,24(sp)
    80002976:	6442                	ld	s0,16(sp)
    80002978:	64a2                	ld	s1,8(sp)
    8000297a:	6902                	ld	s2,0(sp)
    8000297c:	6105                	addi	sp,sp,32
    8000297e:	8082                	ret
    return -1;
    80002980:	557d                	li	a0,-1
    80002982:	bfcd                	j	80002974 <fetchaddr+0x36>
    80002984:	557d                	li	a0,-1
    80002986:	b7fd                	j	80002974 <fetchaddr+0x36>

0000000080002988 <fetchstr>:
int fetchstr(uint64 addr, char *buf, int max) {
    80002988:	7179                	addi	sp,sp,-48
    8000298a:	f406                	sd	ra,40(sp)
    8000298c:	f022                	sd	s0,32(sp)
    8000298e:	ec26                	sd	s1,24(sp)
    80002990:	e84a                	sd	s2,16(sp)
    80002992:	e44e                	sd	s3,8(sp)
    80002994:	1800                	addi	s0,sp,48
    80002996:	89aa                	mv	s3,a0
    80002998:	84ae                	mv	s1,a1
    8000299a:	8932                	mv	s2,a2
  struct proc *p = myproc();
    8000299c:	feffe0ef          	jal	8000198a <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    800029a0:	86ca                	mv	a3,s2
    800029a2:	864e                	mv	a2,s3
    800029a4:	85a6                	mv	a1,s1
    800029a6:	6d28                	ld	a0,88(a0)
    800029a8:	b51fe0ef          	jal	800014f8 <copyinstr>
    800029ac:	00054c63          	bltz	a0,800029c4 <fetchstr+0x3c>
  return strlen(buf);
    800029b0:	8526                	mv	a0,s1
    800029b2:	cd0fe0ef          	jal	80000e82 <strlen>
}
    800029b6:	70a2                	ld	ra,40(sp)
    800029b8:	7402                	ld	s0,32(sp)
    800029ba:	64e2                	ld	s1,24(sp)
    800029bc:	6942                	ld	s2,16(sp)
    800029be:	69a2                	ld	s3,8(sp)
    800029c0:	6145                	addi	sp,sp,48
    800029c2:	8082                	ret
    return -1;
    800029c4:	557d                	li	a0,-1
    800029c6:	bfc5                	j	800029b6 <fetchstr+0x2e>

00000000800029c8 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip) { *ip = argraw(n); }
    800029c8:	1101                	addi	sp,sp,-32
    800029ca:	ec06                	sd	ra,24(sp)
    800029cc:	e822                	sd	s0,16(sp)
    800029ce:	e426                	sd	s1,8(sp)
    800029d0:	1000                	addi	s0,sp,32
    800029d2:	84ae                	mv	s1,a1
    800029d4:	f0bff0ef          	jal	800028de <argraw>
    800029d8:	c088                	sw	a0,0(s1)
    800029da:	60e2                	ld	ra,24(sp)
    800029dc:	6442                	ld	s0,16(sp)
    800029de:	64a2                	ld	s1,8(sp)
    800029e0:	6105                	addi	sp,sp,32
    800029e2:	8082                	ret

00000000800029e4 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip) { *ip = argraw(n); }
    800029e4:	1101                	addi	sp,sp,-32
    800029e6:	ec06                	sd	ra,24(sp)
    800029e8:	e822                	sd	s0,16(sp)
    800029ea:	e426                	sd	s1,8(sp)
    800029ec:	1000                	addi	s0,sp,32
    800029ee:	84ae                	mv	s1,a1
    800029f0:	eefff0ef          	jal	800028de <argraw>
    800029f4:	e088                	sd	a0,0(s1)
    800029f6:	60e2                	ld	ra,24(sp)
    800029f8:	6442                	ld	s0,16(sp)
    800029fa:	64a2                	ld	s1,8(sp)
    800029fc:	6105                	addi	sp,sp,32
    800029fe:	8082                	ret

0000000080002a00 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max) {
    80002a00:	1101                	addi	sp,sp,-32
    80002a02:	ec06                	sd	ra,24(sp)
    80002a04:	e822                	sd	s0,16(sp)
    80002a06:	e426                	sd	s1,8(sp)
    80002a08:	e04a                	sd	s2,0(sp)
    80002a0a:	1000                	addi	s0,sp,32
    80002a0c:	892e                	mv	s2,a1
    80002a0e:	84b2                	mv	s1,a2
void argaddr(int n, uint64 *ip) { *ip = argraw(n); }
    80002a10:	ecfff0ef          	jal	800028de <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002a14:	8626                	mv	a2,s1
    80002a16:	85ca                	mv	a1,s2
    80002a18:	f71ff0ef          	jal	80002988 <fetchstr>
}
    80002a1c:	60e2                	ld	ra,24(sp)
    80002a1e:	6442                	ld	s0,16(sp)
    80002a20:	64a2                	ld	s1,8(sp)
    80002a22:	6902                	ld	s2,0(sp)
    80002a24:	6105                	addi	sp,sp,32
    80002a26:	8082                	ret

0000000080002a28 <syscall>:
    [SYS_sleep2] sys_sleep2,
    [SYS_signal] sys_signal,
    [SYS_setchildlimit] sys_setchildlimit,
};

void syscall(void) {
    80002a28:	1101                	addi	sp,sp,-32
    80002a2a:	ec06                	sd	ra,24(sp)
    80002a2c:	e822                	sd	s0,16(sp)
    80002a2e:	e426                	sd	s1,8(sp)
    80002a30:	e04a                	sd	s2,0(sp)
    80002a32:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002a34:	f57fe0ef          	jal	8000198a <myproc>
    80002a38:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002a3a:	06053903          	ld	s2,96(a0)
    80002a3e:	0a893783          	ld	a5,168(s2)
    80002a42:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002a46:	37fd                	addiw	a5,a5,-1
    80002a48:	02500713          	li	a4,37
    80002a4c:	00f76f63          	bltu	a4,a5,80002a6a <syscall+0x42>
    80002a50:	00369713          	slli	a4,a3,0x3
    80002a54:	00006797          	auipc	a5,0x6
    80002a58:	d4c78793          	addi	a5,a5,-692 # 800087a0 <syscalls>
    80002a5c:	97ba                	add	a5,a5,a4
    80002a5e:	639c                	ld	a5,0(a5)
    80002a60:	c789                	beqz	a5,80002a6a <syscall+0x42>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002a62:	9782                	jalr	a5
    80002a64:	06a93823          	sd	a0,112(s2)
    80002a68:	a829                	j	80002a82 <syscall+0x5a>
  } else {
    printf("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002a6a:	16048613          	addi	a2,s1,352
    80002a6e:	588c                	lw	a1,48(s1)
    80002a70:	00006517          	auipc	a0,0x6
    80002a74:	91050513          	addi	a0,a0,-1776 # 80008380 <etext+0x380>
    80002a78:	a83fd0ef          	jal	800004fa <printf>
    p->trapframe->a0 = -1;
    80002a7c:	70bc                	ld	a5,96(s1)
    80002a7e:	577d                	li	a4,-1
    80002a80:	fbb8                	sd	a4,112(a5)
  }
}
    80002a82:	60e2                	ld	ra,24(sp)
    80002a84:	6442                	ld	s0,16(sp)
    80002a86:	64a2                	ld	s1,8(sp)
    80002a88:	6902                	ld	s2,0(sp)
    80002a8a:	6105                	addi	sp,sp,32
    80002a8c:	8082                	ret

0000000080002a8e <sys_exit>:
#include "types.h"
#include "vm.h"

extern struct proc proc[NPROC];

uint64 sys_exit(void) {
    80002a8e:	1101                	addi	sp,sp,-32
    80002a90:	ec06                	sd	ra,24(sp)
    80002a92:	e822                	sd	s0,16(sp)
    80002a94:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002a96:	fec40593          	addi	a1,s0,-20
    80002a9a:	4501                	li	a0,0
    80002a9c:	f2dff0ef          	jal	800029c8 <argint>
  kexit(n);
    80002aa0:	fec42503          	lw	a0,-20(s0)
    80002aa4:	f12ff0ef          	jal	800021b6 <kexit>
  return 0; // not reached
}
    80002aa8:	4501                	li	a0,0
    80002aaa:	60e2                	ld	ra,24(sp)
    80002aac:	6442                	ld	s0,16(sp)
    80002aae:	6105                	addi	sp,sp,32
    80002ab0:	8082                	ret

0000000080002ab2 <sys_getpid>:

uint64 sys_getpid(void) { return myproc()->pid; }
    80002ab2:	1141                	addi	sp,sp,-16
    80002ab4:	e406                	sd	ra,8(sp)
    80002ab6:	e022                	sd	s0,0(sp)
    80002ab8:	0800                	addi	s0,sp,16
    80002aba:	ed1fe0ef          	jal	8000198a <myproc>
    80002abe:	5908                	lw	a0,48(a0)
    80002ac0:	60a2                	ld	ra,8(sp)
    80002ac2:	6402                	ld	s0,0(sp)
    80002ac4:	0141                	addi	sp,sp,16
    80002ac6:	8082                	ret

0000000080002ac8 <sys_fork>:

uint64 sys_fork(void) { return kfork(); }
    80002ac8:	1141                	addi	sp,sp,-16
    80002aca:	e406                	sd	ra,8(sp)
    80002acc:	e022                	sd	s0,0(sp)
    80002ace:	0800                	addi	s0,sp,16
    80002ad0:	a6aff0ef          	jal	80001d3a <kfork>
    80002ad4:	60a2                	ld	ra,8(sp)
    80002ad6:	6402                	ld	s0,0(sp)
    80002ad8:	0141                	addi	sp,sp,16
    80002ada:	8082                	ret

0000000080002adc <sys_wait>:

uint64 sys_wait(void) {
    80002adc:	1101                	addi	sp,sp,-32
    80002ade:	ec06                	sd	ra,24(sp)
    80002ae0:	e822                	sd	s0,16(sp)
    80002ae2:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002ae4:	fe840593          	addi	a1,s0,-24
    80002ae8:	4501                	li	a0,0
    80002aea:	efbff0ef          	jal	800029e4 <argaddr>
  return kwait(p);
    80002aee:	fe843503          	ld	a0,-24(s0)
    80002af2:	827ff0ef          	jal	80002318 <kwait>
}
    80002af6:	60e2                	ld	ra,24(sp)
    80002af8:	6442                	ld	s0,16(sp)
    80002afa:	6105                	addi	sp,sp,32
    80002afc:	8082                	ret

0000000080002afe <sys_sbrk>:

uint64 sys_sbrk(void) {
    80002afe:	7179                	addi	sp,sp,-48
    80002b00:	f406                	sd	ra,40(sp)
    80002b02:	f022                	sd	s0,32(sp)
    80002b04:	ec26                	sd	s1,24(sp)
    80002b06:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002b08:	fd840593          	addi	a1,s0,-40
    80002b0c:	4501                	li	a0,0
    80002b0e:	ebbff0ef          	jal	800029c8 <argint>
  argint(1, &t);
    80002b12:	fdc40593          	addi	a1,s0,-36
    80002b16:	4505                	li	a0,1
    80002b18:	eb1ff0ef          	jal	800029c8 <argint>
  addr = myproc()->sz;
    80002b1c:	e6ffe0ef          	jal	8000198a <myproc>
    80002b20:	6924                	ld	s1,80(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002b22:	fdc42703          	lw	a4,-36(s0)
    80002b26:	4785                	li	a5,1
    80002b28:	02f70763          	beq	a4,a5,80002b56 <sys_sbrk+0x58>
    80002b2c:	fd842783          	lw	a5,-40(s0)
    80002b30:	0207c363          	bltz	a5,80002b56 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002b34:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002b36:	02000737          	lui	a4,0x2000
    80002b3a:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002b3c:	0736                	slli	a4,a4,0xd
    80002b3e:	02f76a63          	bltu	a4,a5,80002b72 <sys_sbrk+0x74>
    80002b42:	0297e863          	bltu	a5,s1,80002b72 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002b46:	e45fe0ef          	jal	8000198a <myproc>
    80002b4a:	fd842703          	lw	a4,-40(s0)
    80002b4e:	693c                	ld	a5,80(a0)
    80002b50:	97ba                	add	a5,a5,a4
    80002b52:	e93c                	sd	a5,80(a0)
    80002b54:	a039                	j	80002b62 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002b56:	fd842503          	lw	a0,-40(s0)
    80002b5a:	97eff0ef          	jal	80001cd8 <growproc>
    80002b5e:	00054863          	bltz	a0,80002b6e <sys_sbrk+0x70>
  }
  return addr;
}
    80002b62:	8526                	mv	a0,s1
    80002b64:	70a2                	ld	ra,40(sp)
    80002b66:	7402                	ld	s0,32(sp)
    80002b68:	64e2                	ld	s1,24(sp)
    80002b6a:	6145                	addi	sp,sp,48
    80002b6c:	8082                	ret
      return -1;
    80002b6e:	54fd                	li	s1,-1
    80002b70:	bfcd                	j	80002b62 <sys_sbrk+0x64>
      return -1;
    80002b72:	54fd                	li	s1,-1
    80002b74:	b7fd                	j	80002b62 <sys_sbrk+0x64>

0000000080002b76 <sys_pause>:

uint64 sys_pause(void) {
    80002b76:	7139                	addi	sp,sp,-64
    80002b78:	fc06                	sd	ra,56(sp)
    80002b7a:	f822                	sd	s0,48(sp)
    80002b7c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002b7e:	fcc40593          	addi	a1,s0,-52
    80002b82:	4501                	li	a0,0
    80002b84:	e45ff0ef          	jal	800029c8 <argint>
  if (n < 0)
    80002b88:	fcc42783          	lw	a5,-52(s0)
    80002b8c:	0607c863          	bltz	a5,80002bfc <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002b90:	0005a517          	auipc	a0,0x5a
    80002b94:	9f850513          	addi	a0,a0,-1544 # 8005c588 <tickslock>
    80002b98:	890fe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002b9c:	fcc42783          	lw	a5,-52(s0)
    80002ba0:	c3b9                	beqz	a5,80002be6 <sys_pause+0x70>
    80002ba2:	f426                	sd	s1,40(sp)
    80002ba4:	f04a                	sd	s2,32(sp)
    80002ba6:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002ba8:	00009997          	auipc	s3,0x9
    80002bac:	cb09a983          	lw	s3,-848(s3) # 8000b858 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002bb0:	0005a917          	auipc	s2,0x5a
    80002bb4:	9d890913          	addi	s2,s2,-1576 # 8005c588 <tickslock>
    80002bb8:	00009497          	auipc	s1,0x9
    80002bbc:	ca048493          	addi	s1,s1,-864 # 8000b858 <ticks>
    if (killed(myproc())) {
    80002bc0:	dcbfe0ef          	jal	8000198a <myproc>
    80002bc4:	f2aff0ef          	jal	800022ee <killed>
    80002bc8:	ed0d                	bnez	a0,80002c02 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002bca:	85ca                	mv	a1,s2
    80002bcc:	8526                	mv	a0,s1
    80002bce:	cccff0ef          	jal	8000209a <sleep>
  while (ticks - ticks0 < n) {
    80002bd2:	409c                	lw	a5,0(s1)
    80002bd4:	413787bb          	subw	a5,a5,s3
    80002bd8:	fcc42703          	lw	a4,-52(s0)
    80002bdc:	fee7e2e3          	bltu	a5,a4,80002bc0 <sys_pause+0x4a>
    80002be0:	74a2                	ld	s1,40(sp)
    80002be2:	7902                	ld	s2,32(sp)
    80002be4:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002be6:	0005a517          	auipc	a0,0x5a
    80002bea:	9a250513          	addi	a0,a0,-1630 # 8005c588 <tickslock>
    80002bee:	8cefe0ef          	jal	80000cbc <release>
  return 0;
    80002bf2:	4501                	li	a0,0
}
    80002bf4:	70e2                	ld	ra,56(sp)
    80002bf6:	7442                	ld	s0,48(sp)
    80002bf8:	6121                	addi	sp,sp,64
    80002bfa:	8082                	ret
    n = 0;
    80002bfc:	fc042623          	sw	zero,-52(s0)
    80002c00:	bf41                	j	80002b90 <sys_pause+0x1a>
      release(&tickslock);
    80002c02:	0005a517          	auipc	a0,0x5a
    80002c06:	98650513          	addi	a0,a0,-1658 # 8005c588 <tickslock>
    80002c0a:	8b2fe0ef          	jal	80000cbc <release>
      return -1;
    80002c0e:	557d                	li	a0,-1
    80002c10:	74a2                	ld	s1,40(sp)
    80002c12:	7902                	ld	s2,32(sp)
    80002c14:	69e2                	ld	s3,24(sp)
    80002c16:	bff9                	j	80002bf4 <sys_pause+0x7e>

0000000080002c18 <sys_kill>:

uint64 sys_kill(void) {
    80002c18:	1101                	addi	sp,sp,-32
    80002c1a:	ec06                	sd	ra,24(sp)
    80002c1c:	e822                	sd	s0,16(sp)
    80002c1e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002c20:	fec40593          	addi	a1,s0,-20
    80002c24:	4501                	li	a0,0
    80002c26:	da3ff0ef          	jal	800029c8 <argint>
  return kkill(pid);
    80002c2a:	fec42503          	lw	a0,-20(s0)
    80002c2e:	e2eff0ef          	jal	8000225c <kkill>
}
    80002c32:	60e2                	ld	ra,24(sp)
    80002c34:	6442                	ld	s0,16(sp)
    80002c36:	6105                	addi	sp,sp,32
    80002c38:	8082                	ret

0000000080002c3a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64 sys_uptime(void) {
    80002c3a:	1101                	addi	sp,sp,-32
    80002c3c:	ec06                	sd	ra,24(sp)
    80002c3e:	e822                	sd	s0,16(sp)
    80002c40:	e426                	sd	s1,8(sp)
    80002c42:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002c44:	0005a517          	auipc	a0,0x5a
    80002c48:	94450513          	addi	a0,a0,-1724 # 8005c588 <tickslock>
    80002c4c:	fddfd0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002c50:	00009797          	auipc	a5,0x9
    80002c54:	c087a783          	lw	a5,-1016(a5) # 8000b858 <ticks>
    80002c58:	84be                	mv	s1,a5
  release(&tickslock);
    80002c5a:	0005a517          	auipc	a0,0x5a
    80002c5e:	92e50513          	addi	a0,a0,-1746 # 8005c588 <tickslock>
    80002c62:	85afe0ef          	jal	80000cbc <release>
  return xticks;
}
    80002c66:	02049513          	slli	a0,s1,0x20
    80002c6a:	9101                	srli	a0,a0,0x20
    80002c6c:	60e2                	ld	ra,24(sp)
    80002c6e:	6442                	ld	s0,16(sp)
    80002c70:	64a2                	ld	s1,8(sp)
    80002c72:	6105                	addi	sp,sp,32
    80002c74:	8082                	ret

0000000080002c76 <shmget>:

// Shared memory array
struct sharedmem shmtable[MAX_SHAREDMEM];

int shmget(int id, int size) {
    80002c76:	1101                	addi	sp,sp,-32
    80002c78:	ec06                	sd	ra,24(sp)
    80002c7a:	e822                	sd	s0,16(sp)
    80002c7c:	e426                	sd	s1,8(sp)
    80002c7e:	1000                	addi	s0,sp,32
    80002c80:	84aa                	mv	s1,a0
  for (int i = 0; i < MAX_SHAREDMEM; i++) {
    80002c82:	0005a697          	auipc	a3,0x5a
    80002c86:	b1e68693          	addi	a3,a3,-1250 # 8005c7a0 <locktable>
int shmget(int id, int size) {
    80002c8a:	0005a797          	auipc	a5,0x5a
    80002c8e:	91678793          	addi	a5,a5,-1770 # 8005c5a0 <shmtable>
    80002c92:	a029                	j	80002c9c <shmget+0x26>
  for (int i = 0; i < MAX_SHAREDMEM; i++) {
    80002c94:	02078793          	addi	a5,a5,32
    80002c98:	00d78963          	beq	a5,a3,80002caa <shmget+0x34>
    if (shmtable[i].valid && shmtable[i].id == id)
    80002c9c:	4f98                	lw	a4,24(a5)
    80002c9e:	db7d                	beqz	a4,80002c94 <shmget+0x1e>
    80002ca0:	4398                	lw	a4,0(a5)
    80002ca2:	fe9719e3          	bne	a4,s1,80002c94 <shmget+0x1e>
      return id;
    80002ca6:	8526                	mv	a0,s1
    80002ca8:	a839                	j	80002cc6 <shmget+0x50>
    80002caa:	0005a717          	auipc	a4,0x5a
    80002cae:	90e70713          	addi	a4,a4,-1778 # 8005c5b8 <shmtable+0x18>
  }
  for (int i = 0; i < MAX_SHAREDMEM; i++) {
    80002cb2:	4781                	li	a5,0
    80002cb4:	4641                	li	a2,16
    if (!shmtable[i].valid) {
    80002cb6:	4314                	lw	a3,0(a4)
    80002cb8:	ce81                	beqz	a3,80002cd0 <shmget+0x5a>
  for (int i = 0; i < MAX_SHAREDMEM; i++) {
    80002cba:	2785                	addiw	a5,a5,1
    80002cbc:	02070713          	addi	a4,a4,32
    80002cc0:	fec79be3          	bne	a5,a2,80002cb6 <shmget+0x40>
      shmtable[i].addr = (uint64)kalloc();
      shmtable[i].valid = 1;
      return id;
    }
  }
  return -1;
    80002cc4:	557d                	li	a0,-1
}
    80002cc6:	60e2                	ld	ra,24(sp)
    80002cc8:	6442                	ld	s0,16(sp)
    80002cca:	64a2                	ld	s1,8(sp)
    80002ccc:	6105                	addi	sp,sp,32
    80002cce:	8082                	ret
    80002cd0:	e04a                	sd	s2,0(sp)
      shmtable[i].id = id;
    80002cd2:	0796                	slli	a5,a5,0x5
    80002cd4:	0005a917          	auipc	s2,0x5a
    80002cd8:	8cc90913          	addi	s2,s2,-1844 # 8005c5a0 <shmtable>
    80002cdc:	993e                	add	s2,s2,a5
    80002cde:	00992023          	sw	s1,0(s2)
      shmtable[i].size = size;
    80002ce2:	00b92823          	sw	a1,16(s2)
      shmtable[i].refcount = 0;
    80002ce6:	00092a23          	sw	zero,20(s2)
      shmtable[i].addr = (uint64)kalloc();
    80002cea:	e5bfd0ef          	jal	80000b44 <kalloc>
    80002cee:	00a93423          	sd	a0,8(s2)
      shmtable[i].valid = 1;
    80002cf2:	4785                	li	a5,1
    80002cf4:	00f92c23          	sw	a5,24(s2)
      return id;
    80002cf8:	8526                	mv	a0,s1
    80002cfa:	6902                	ld	s2,0(sp)
    80002cfc:	b7e9                	j	80002cc6 <shmget+0x50>

0000000080002cfe <shmat>:

uint64 shmat(int id) {
    80002cfe:	1101                	addi	sp,sp,-32
    80002d00:	ec06                	sd	ra,24(sp)
    80002d02:	e822                	sd	s0,16(sp)
    80002d04:	e426                	sd	s1,8(sp)
    80002d06:	1000                	addi	s0,sp,32
    80002d08:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d0a:	c81fe0ef          	jal	8000198a <myproc>
    80002d0e:	85aa                	mv	a1,a0
  for (int i = 0; i < MAX_SHAREDMEM; i++) {
    80002d10:	0005a797          	auipc	a5,0x5a
    80002d14:	89078793          	addi	a5,a5,-1904 # 8005c5a0 <shmtable>
    80002d18:	4701                	li	a4,0
    80002d1a:	4641                	li	a2,16
    80002d1c:	a031                	j	80002d28 <shmat+0x2a>
    80002d1e:	2705                	addiw	a4,a4,1
    80002d20:	02078793          	addi	a5,a5,32
    80002d24:	04c70863          	beq	a4,a2,80002d74 <shmat+0x76>
    if (shmtable[i].valid && shmtable[i].id == id) {
    80002d28:	4f94                	lw	a3,24(a5)
    80002d2a:	daf5                	beqz	a3,80002d1e <shmat+0x20>
    80002d2c:	4394                	lw	a3,0(a5)
    80002d2e:	fe9698e3          	bne	a3,s1,80002d1e <shmat+0x20>
    80002d32:	e04a                	sd	s2,0(sp)
      shmtable[i].refcount++;
    80002d34:	0716                	slli	a4,a4,0x5
    80002d36:	0005a797          	auipc	a5,0x5a
    80002d3a:	86a78793          	addi	a5,a5,-1942 # 8005c5a0 <shmtable>
    80002d3e:	97ba                	add	a5,a5,a4
    80002d40:	4bd8                	lw	a4,20(a5)
    80002d42:	2705                	addiw	a4,a4,1
    80002d44:	cbd8                	sw	a4,20(a5)
      // map physical address to process virtual address space
      uint64 va = PGROUNDUP(p->sz);
    80002d46:	892e                	mv	s2,a1
    80002d48:	69a4                	ld	s1,80(a1)
    80002d4a:	6705                	lui	a4,0x1
    80002d4c:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    80002d4e:	94ba                	add	s1,s1,a4
    80002d50:	777d                	lui	a4,0xfffff
    80002d52:	8cf9                	and	s1,s1,a4
      if (mappages(p->pagetable, va, PGSIZE, shmtable[i].addr,
    80002d54:	4759                	li	a4,22
    80002d56:	6794                	ld	a3,8(a5)
    80002d58:	6605                	lui	a2,0x1
    80002d5a:	85a6                	mv	a1,s1
    80002d5c:	05893503          	ld	a0,88(s2)
    80002d60:	b00fe0ef          	jal	80001060 <mappages>
    80002d64:	00054f63          	bltz	a0,80002d82 <shmat+0x84>
                   PTE_R | PTE_W | PTE_U) < 0)
        return -1;
      p->sz = va + PGSIZE;
    80002d68:	6785                	lui	a5,0x1
    80002d6a:	97a6                	add	a5,a5,s1
    80002d6c:	04f93823          	sd	a5,80(s2)
      return va;
    80002d70:	6902                	ld	s2,0(sp)
    80002d72:	a011                	j	80002d76 <shmat+0x78>
    }
  }
  return -1;
    80002d74:	54fd                	li	s1,-1
}
    80002d76:	8526                	mv	a0,s1
    80002d78:	60e2                	ld	ra,24(sp)
    80002d7a:	6442                	ld	s0,16(sp)
    80002d7c:	64a2                	ld	s1,8(sp)
    80002d7e:	6105                	addi	sp,sp,32
    80002d80:	8082                	ret
        return -1;
    80002d82:	54fd                	li	s1,-1
    80002d84:	6902                	ld	s2,0(sp)
    80002d86:	bfc5                	j	80002d76 <shmat+0x78>

0000000080002d88 <shmdt>:

int shmdt(int id) {
    80002d88:	1141                	addi	sp,sp,-16
    80002d8a:	e406                	sd	ra,8(sp)
    80002d8c:	e022                	sd	s0,0(sp)
    80002d8e:	0800                	addi	s0,sp,16
  for (int i = 0; i < MAX_SHAREDMEM; i++) {
    80002d90:	0005a797          	auipc	a5,0x5a
    80002d94:	81078793          	addi	a5,a5,-2032 # 8005c5a0 <shmtable>
    80002d98:	4701                	li	a4,0
    80002d9a:	4641                	li	a2,16
    80002d9c:	a031                	j	80002da8 <shmdt+0x20>
    80002d9e:	2705                	addiw	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ff97399>
    80002da0:	02078793          	addi	a5,a5,32
    80002da4:	02c70263          	beq	a4,a2,80002dc8 <shmdt+0x40>
    if (shmtable[i].valid && shmtable[i].id == id) {
    80002da8:	4f94                	lw	a3,24(a5)
    80002daa:	daf5                	beqz	a3,80002d9e <shmdt+0x16>
    80002dac:	4394                	lw	a3,0(a5)
    80002dae:	fea698e3          	bne	a3,a0,80002d9e <shmdt+0x16>
      shmtable[i].refcount--;
    80002db2:	0716                	slli	a4,a4,0x5
    80002db4:	00059797          	auipc	a5,0x59
    80002db8:	7ec78793          	addi	a5,a5,2028 # 8005c5a0 <shmtable>
    80002dbc:	97ba                	add	a5,a5,a4
    80002dbe:	4bd8                	lw	a4,20(a5)
    80002dc0:	377d                	addiw	a4,a4,-1
    80002dc2:	cbd8                	sw	a4,20(a5)
      return 0;
    80002dc4:	4501                	li	a0,0
    80002dc6:	a011                	j	80002dca <shmdt+0x42>
    }
  }
  return -1;
    80002dc8:	557d                	li	a0,-1
}
    80002dca:	60a2                	ld	ra,8(sp)
    80002dcc:	6402                	ld	s0,0(sp)
    80002dce:	0141                	addi	sp,sp,16
    80002dd0:	8082                	ret

0000000080002dd2 <shmctl>:

int shmctl(int id) {
    80002dd2:	1101                	addi	sp,sp,-32
    80002dd4:	ec06                	sd	ra,24(sp)
    80002dd6:	e822                	sd	s0,16(sp)
    80002dd8:	e426                	sd	s1,8(sp)
    80002dda:	1000                	addi	s0,sp,32
  for (int i = 0; i < MAX_SHAREDMEM; i++) {
    80002ddc:	00059797          	auipc	a5,0x59
    80002de0:	7c478793          	addi	a5,a5,1988 # 8005c5a0 <shmtable>
    80002de4:	4701                	li	a4,0
    80002de6:	4641                	li	a2,16
    80002de8:	a031                	j	80002df4 <shmctl+0x22>
    80002dea:	2705                	addiw	a4,a4,1
    80002dec:	02078793          	addi	a5,a5,32
    80002df0:	02c70863          	beq	a4,a2,80002e20 <shmctl+0x4e>
    if (shmtable[i].valid && shmtable[i].id == id) {
    80002df4:	4f94                	lw	a3,24(a5)
    80002df6:	daf5                	beqz	a3,80002dea <shmctl+0x18>
    80002df8:	4394                	lw	a3,0(a5)
    80002dfa:	fea698e3          	bne	a3,a0,80002dea <shmctl+0x18>
      if (shmtable[i].refcount == 0) {
    80002dfe:	4bc4                	lw	s1,20(a5)
    80002e00:	f4ed                	bnez	s1,80002dea <shmctl+0x18>
    80002e02:	e04a                	sd	s2,0(sp)
        kfree((void *)shmtable[i].addr);
    80002e04:	0716                	slli	a4,a4,0x5
    80002e06:	00059797          	auipc	a5,0x59
    80002e0a:	79a78793          	addi	a5,a5,1946 # 8005c5a0 <shmtable>
    80002e0e:	97ba                	add	a5,a5,a4
    80002e10:	893e                	mv	s2,a5
    80002e12:	6788                	ld	a0,8(a5)
    80002e14:	c49fd0ef          	jal	80000a5c <kfree>
        shmtable[i].valid = 0;
    80002e18:	00092c23          	sw	zero,24(s2)
        return 0;
    80002e1c:	6902                	ld	s2,0(sp)
    80002e1e:	a011                	j	80002e22 <shmctl+0x50>
      }
    }
  }
  return -1;
    80002e20:	54fd                	li	s1,-1
}
    80002e22:	8526                	mv	a0,s1
    80002e24:	60e2                	ld	ra,24(sp)
    80002e26:	6442                	ld	s0,16(sp)
    80002e28:	64a2                	ld	s1,8(sp)
    80002e2a:	6105                	addi	sp,sp,32
    80002e2c:	8082                	ret

0000000080002e2e <sys_shmget>:

uint64 sys_shmget(void) {
    80002e2e:	1101                	addi	sp,sp,-32
    80002e30:	ec06                	sd	ra,24(sp)
    80002e32:	e822                	sd	s0,16(sp)
    80002e34:	1000                	addi	s0,sp,32
  int id, size;
  argint(0, &id);
    80002e36:	fec40593          	addi	a1,s0,-20
    80002e3a:	4501                	li	a0,0
    80002e3c:	b8dff0ef          	jal	800029c8 <argint>
  argint(1, &size);
    80002e40:	fe840593          	addi	a1,s0,-24
    80002e44:	4505                	li	a0,1
    80002e46:	b83ff0ef          	jal	800029c8 <argint>
  return shmget(id, size);
    80002e4a:	fe842583          	lw	a1,-24(s0)
    80002e4e:	fec42503          	lw	a0,-20(s0)
    80002e52:	e25ff0ef          	jal	80002c76 <shmget>
}
    80002e56:	60e2                	ld	ra,24(sp)
    80002e58:	6442                	ld	s0,16(sp)
    80002e5a:	6105                	addi	sp,sp,32
    80002e5c:	8082                	ret

0000000080002e5e <sys_shmat>:

uint64 sys_shmat(void) {
    80002e5e:	1101                	addi	sp,sp,-32
    80002e60:	ec06                	sd	ra,24(sp)
    80002e62:	e822                	sd	s0,16(sp)
    80002e64:	1000                	addi	s0,sp,32
  int id;
  argint(0, &id);
    80002e66:	fec40593          	addi	a1,s0,-20
    80002e6a:	4501                	li	a0,0
    80002e6c:	b5dff0ef          	jal	800029c8 <argint>
  return shmat(id);
    80002e70:	fec42503          	lw	a0,-20(s0)
    80002e74:	e8bff0ef          	jal	80002cfe <shmat>
}
    80002e78:	60e2                	ld	ra,24(sp)
    80002e7a:	6442                	ld	s0,16(sp)
    80002e7c:	6105                	addi	sp,sp,32
    80002e7e:	8082                	ret

0000000080002e80 <sys_shmdt>:

uint64 sys_shmdt(void) {
    80002e80:	1101                	addi	sp,sp,-32
    80002e82:	ec06                	sd	ra,24(sp)
    80002e84:	e822                	sd	s0,16(sp)
    80002e86:	1000                	addi	s0,sp,32
  int id;
  argint(0, &id);
    80002e88:	fec40593          	addi	a1,s0,-20
    80002e8c:	4501                	li	a0,0
    80002e8e:	b3bff0ef          	jal	800029c8 <argint>
  return shmdt(id);
    80002e92:	fec42503          	lw	a0,-20(s0)
    80002e96:	ef3ff0ef          	jal	80002d88 <shmdt>
}
    80002e9a:	60e2                	ld	ra,24(sp)
    80002e9c:	6442                	ld	s0,16(sp)
    80002e9e:	6105                	addi	sp,sp,32
    80002ea0:	8082                	ret

0000000080002ea2 <sys_shmctl>:

uint64 sys_shmctl(void) {
    80002ea2:	1101                	addi	sp,sp,-32
    80002ea4:	ec06                	sd	ra,24(sp)
    80002ea6:	e822                	sd	s0,16(sp)
    80002ea8:	1000                	addi	s0,sp,32
  int id;
  argint(0, &id);
    80002eaa:	fec40593          	addi	a1,s0,-20
    80002eae:	4501                	li	a0,0
    80002eb0:	b19ff0ef          	jal	800029c8 <argint>
  return shmctl(id);
    80002eb4:	fec42503          	lw	a0,-20(s0)
    80002eb8:	f1bff0ef          	jal	80002dd2 <shmctl>
}
    80002ebc:	60e2                	ld	ra,24(sp)
    80002ebe:	6442                	ld	s0,16(sp)
    80002ec0:	6105                	addi	sp,sp,32
    80002ec2:	8082                	ret

0000000080002ec4 <lockinit>:

// Lock table
struct userlock locktable[MAX_LOCKS];

int lockinit(int id) {
    80002ec4:	1141                	addi	sp,sp,-16
    80002ec6:	e406                	sd	ra,8(sp)
    80002ec8:	e022                	sd	s0,0(sp)
    80002eca:	0800                	addi	s0,sp,16
  for (int i = 0; i < MAX_LOCKS; i++) {
    80002ecc:	0005a697          	auipc	a3,0x5a
    80002ed0:	9d468693          	addi	a3,a3,-1580 # 8005c8a0 <bcache>
int lockinit(int id) {
    80002ed4:	0005a797          	auipc	a5,0x5a
    80002ed8:	8cc78793          	addi	a5,a5,-1844 # 8005c7a0 <locktable>
    80002edc:	a021                	j	80002ee4 <lockinit+0x20>
  for (int i = 0; i < MAX_LOCKS; i++) {
    80002ede:	07c1                	addi	a5,a5,16
    80002ee0:	00d78863          	beq	a5,a3,80002ef0 <lockinit+0x2c>
    if (locktable[i].valid && locktable[i].id == id)
    80002ee4:	47d8                	lw	a4,12(a5)
    80002ee6:	df65                	beqz	a4,80002ede <lockinit+0x1a>
    80002ee8:	4398                	lw	a4,0(a5)
    80002eea:	fea71ae3          	bne	a4,a0,80002ede <lockinit+0x1a>
    80002eee:	a831                	j	80002f0a <lockinit+0x46>
    80002ef0:	0005a717          	auipc	a4,0x5a
    80002ef4:	8bc70713          	addi	a4,a4,-1860 # 8005c7ac <locktable+0xc>
      return id;
  }
  for (int i = 0; i < MAX_LOCKS; i++) {
    80002ef8:	4781                	li	a5,0
    80002efa:	4641                	li	a2,16
    if (!locktable[i].valid) {
    80002efc:	4314                	lw	a3,0(a4)
    80002efe:	ca91                	beqz	a3,80002f12 <lockinit+0x4e>
  for (int i = 0; i < MAX_LOCKS; i++) {
    80002f00:	2785                	addiw	a5,a5,1
    80002f02:	0741                	addi	a4,a4,16
    80002f04:	fec79ce3          	bne	a5,a2,80002efc <lockinit+0x38>
      locktable[i].pid = -1;
      locktable[i].valid = 1;
      return id;
    }
  }
  return -1;
    80002f08:	557d                	li	a0,-1
}
    80002f0a:	60a2                	ld	ra,8(sp)
    80002f0c:	6402                	ld	s0,0(sp)
    80002f0e:	0141                	addi	sp,sp,16
    80002f10:	8082                	ret
      locktable[i].id = id;
    80002f12:	0792                	slli	a5,a5,0x4
    80002f14:	00059717          	auipc	a4,0x59
    80002f18:	68c70713          	addi	a4,a4,1676 # 8005c5a0 <shmtable>
    80002f1c:	97ba                	add	a5,a5,a4
    80002f1e:	20a7a023          	sw	a0,512(a5)
      locktable[i].held = 0;
    80002f22:	2007a223          	sw	zero,516(a5)
      locktable[i].pid = -1;
    80002f26:	577d                	li	a4,-1
    80002f28:	20e7a423          	sw	a4,520(a5)
      locktable[i].valid = 1;
    80002f2c:	4705                	li	a4,1
    80002f2e:	20e7a623          	sw	a4,524(a5)
      return id;
    80002f32:	bfe1                	j	80002f0a <lockinit+0x46>

0000000080002f34 <lockacquire>:

int lockacquire(int id) {
    80002f34:	1101                	addi	sp,sp,-32
    80002f36:	ec06                	sd	ra,24(sp)
    80002f38:	e822                	sd	s0,16(sp)
    80002f3a:	e426                	sd	s1,8(sp)
    80002f3c:	1000                	addi	s0,sp,32
  for (int i = 0; i < MAX_LOCKS; i++) {
    80002f3e:	0005a797          	auipc	a5,0x5a
    80002f42:	86278793          	addi	a5,a5,-1950 # 8005c7a0 <locktable>
    80002f46:	4701                	li	a4,0
    80002f48:	4641                	li	a2,16
    80002f4a:	a029                	j	80002f54 <lockacquire+0x20>
    80002f4c:	2705                	addiw	a4,a4,1
    80002f4e:	07c1                	addi	a5,a5,16
    80002f50:	04c70263          	beq	a4,a2,80002f94 <lockacquire+0x60>
    if (locktable[i].valid && locktable[i].id == id) {
    80002f54:	47d4                	lw	a3,12(a5)
    80002f56:	dafd                	beqz	a3,80002f4c <lockacquire+0x18>
    80002f58:	4394                	lw	a3,0(a5)
    80002f5a:	fea699e3          	bne	a3,a0,80002f4c <lockacquire+0x18>
      if (locktable[i].held)
    80002f5e:	00471693          	slli	a3,a4,0x4
    80002f62:	00059797          	auipc	a5,0x59
    80002f66:	63e78793          	addi	a5,a5,1598 # 8005c5a0 <shmtable>
    80002f6a:	97b6                	add	a5,a5,a3
    80002f6c:	2047a483          	lw	s1,516(a5)
    80002f70:	e88d                	bnez	s1,80002fa2 <lockacquire+0x6e>
    80002f72:	e04a                	sd	s2,0(sp)
        return -1;
      locktable[i].held = 1;
    80002f74:	00059797          	auipc	a5,0x59
    80002f78:	62c78793          	addi	a5,a5,1580 # 8005c5a0 <shmtable>
    80002f7c:	00d78933          	add	s2,a5,a3
    80002f80:	4785                	li	a5,1
    80002f82:	20f92223          	sw	a5,516(s2)
      locktable[i].pid = myproc()->pid;
    80002f86:	a05fe0ef          	jal	8000198a <myproc>
    80002f8a:	591c                	lw	a5,48(a0)
    80002f8c:	20f92423          	sw	a5,520(s2)
      return 0;
    80002f90:	6902                	ld	s2,0(sp)
    80002f92:	a011                	j	80002f96 <lockacquire+0x62>
    }
  }
  return -1;
    80002f94:	54fd                	li	s1,-1
}
    80002f96:	8526                	mv	a0,s1
    80002f98:	60e2                	ld	ra,24(sp)
    80002f9a:	6442                	ld	s0,16(sp)
    80002f9c:	64a2                	ld	s1,8(sp)
    80002f9e:	6105                	addi	sp,sp,32
    80002fa0:	8082                	ret
        return -1;
    80002fa2:	54fd                	li	s1,-1
    80002fa4:	bfcd                	j	80002f96 <lockacquire+0x62>

0000000080002fa6 <lockrelease>:

int lockrelease(int id) {
    80002fa6:	1141                	addi	sp,sp,-16
    80002fa8:	e406                	sd	ra,8(sp)
    80002faa:	e022                	sd	s0,0(sp)
    80002fac:	0800                	addi	s0,sp,16
  for (int i = 0; i < MAX_LOCKS; i++) {
    80002fae:	00059797          	auipc	a5,0x59
    80002fb2:	7f278793          	addi	a5,a5,2034 # 8005c7a0 <locktable>
    80002fb6:	4701                	li	a4,0
    80002fb8:	4641                	li	a2,16
    80002fba:	a029                	j	80002fc4 <lockrelease+0x1e>
    80002fbc:	2705                	addiw	a4,a4,1
    80002fbe:	07c1                	addi	a5,a5,16
    80002fc0:	02c70d63          	beq	a4,a2,80002ffa <lockrelease+0x54>
    if (locktable[i].valid && locktable[i].id == id) {
    80002fc4:	47d4                	lw	a3,12(a5)
    80002fc6:	dafd                	beqz	a3,80002fbc <lockrelease+0x16>
    80002fc8:	4394                	lw	a3,0(a5)
    80002fca:	fea699e3          	bne	a3,a0,80002fbc <lockrelease+0x16>
      if (!locktable[i].held)
    80002fce:	00471693          	slli	a3,a4,0x4
    80002fd2:	00059797          	auipc	a5,0x59
    80002fd6:	5ce78793          	addi	a5,a5,1486 # 8005c5a0 <shmtable>
    80002fda:	97b6                	add	a5,a5,a3
    80002fdc:	2047a783          	lw	a5,516(a5)
    80002fe0:	c395                	beqz	a5,80003004 <lockrelease+0x5e>
        return -1;
      locktable[i].held = 0;
    80002fe2:	00059797          	auipc	a5,0x59
    80002fe6:	5be78793          	addi	a5,a5,1470 # 8005c5a0 <shmtable>
    80002fea:	97b6                	add	a5,a5,a3
    80002fec:	2007a223          	sw	zero,516(a5)
      locktable[i].pid = -1;
    80002ff0:	577d                	li	a4,-1
    80002ff2:	20e7a423          	sw	a4,520(a5)
      return 0;
    80002ff6:	4501                	li	a0,0
    80002ff8:	a011                	j	80002ffc <lockrelease+0x56>
    }
  }
  return -1;
    80002ffa:	557d                	li	a0,-1
}
    80002ffc:	60a2                	ld	ra,8(sp)
    80002ffe:	6402                	ld	s0,0(sp)
    80003000:	0141                	addi	sp,sp,16
    80003002:	8082                	ret
        return -1;
    80003004:	557d                	li	a0,-1
    80003006:	bfdd                	j	80002ffc <lockrelease+0x56>

0000000080003008 <locktry>:

int locktry(int id) {
  for (int i = 0; i < MAX_LOCKS; i++) {
    80003008:	00059797          	auipc	a5,0x59
    8000300c:	79878793          	addi	a5,a5,1944 # 8005c7a0 <locktable>
    80003010:	4701                	li	a4,0
    80003012:	4641                	li	a2,16
    80003014:	a835                	j	80003050 <locktry+0x48>
int locktry(int id) {
    80003016:	1101                	addi	sp,sp,-32
    80003018:	ec06                	sd	ra,24(sp)
    8000301a:	e822                	sd	s0,16(sp)
    8000301c:	e426                	sd	s1,8(sp)
    8000301e:	1000                	addi	s0,sp,32
    if (locktable[i].valid && locktable[i].id == id) {
      if (locktable[i].held)
        return 0;
      locktable[i].held = 1;
    80003020:	00059797          	auipc	a5,0x59
    80003024:	58078793          	addi	a5,a5,1408 # 8005c5a0 <shmtable>
    80003028:	00d784b3          	add	s1,a5,a3
    8000302c:	4785                	li	a5,1
    8000302e:	20f4a223          	sw	a5,516(s1)
      locktable[i].pid = myproc()->pid;
    80003032:	959fe0ef          	jal	8000198a <myproc>
    80003036:	591c                	lw	a5,48(a0)
    80003038:	20f4a423          	sw	a5,520(s1)
      return 1;
    8000303c:	4505                	li	a0,1
    }
  }
  return -1;
}
    8000303e:	60e2                	ld	ra,24(sp)
    80003040:	6442                	ld	s0,16(sp)
    80003042:	64a2                	ld	s1,8(sp)
    80003044:	6105                	addi	sp,sp,32
    80003046:	8082                	ret
  for (int i = 0; i < MAX_LOCKS; i++) {
    80003048:	2705                	addiw	a4,a4,1
    8000304a:	07c1                	addi	a5,a5,16
    8000304c:	02c70363          	beq	a4,a2,80003072 <locktry+0x6a>
    if (locktable[i].valid && locktable[i].id == id) {
    80003050:	47d4                	lw	a3,12(a5)
    80003052:	dafd                	beqz	a3,80003048 <locktry+0x40>
    80003054:	4394                	lw	a3,0(a5)
    80003056:	fea699e3          	bne	a3,a0,80003048 <locktry+0x40>
      if (locktable[i].held)
    8000305a:	00471693          	slli	a3,a4,0x4
    8000305e:	00059797          	auipc	a5,0x59
    80003062:	54278793          	addi	a5,a5,1346 # 8005c5a0 <shmtable>
    80003066:	97b6                	add	a5,a5,a3
    80003068:	2047a783          	lw	a5,516(a5)
        return 0;
    8000306c:	4501                	li	a0,0
      if (locktable[i].held)
    8000306e:	d7c5                	beqz	a5,80003016 <locktry+0xe>
}
    80003070:	8082                	ret
  return -1;
    80003072:	557d                	li	a0,-1
    80003074:	8082                	ret

0000000080003076 <lockcheck>:

int lockcheck(int id) {
    80003076:	1141                	addi	sp,sp,-16
    80003078:	e406                	sd	ra,8(sp)
    8000307a:	e022                	sd	s0,0(sp)
    8000307c:	0800                	addi	s0,sp,16
  for (int i = 0; i < MAX_LOCKS; i++) {
    8000307e:	00059797          	auipc	a5,0x59
    80003082:	72278793          	addi	a5,a5,1826 # 8005c7a0 <locktable>
    80003086:	4701                	li	a4,0
    80003088:	4641                	li	a2,16
    8000308a:	a029                	j	80003094 <lockcheck+0x1e>
    8000308c:	2705                	addiw	a4,a4,1
    8000308e:	07c1                	addi	a5,a5,16
    80003090:	02c70063          	beq	a4,a2,800030b0 <lockcheck+0x3a>
    if (locktable[i].valid && locktable[i].id == id)
    80003094:	47d4                	lw	a3,12(a5)
    80003096:	dafd                	beqz	a3,8000308c <lockcheck+0x16>
    80003098:	4394                	lw	a3,0(a5)
    8000309a:	fea699e3          	bne	a3,a0,8000308c <lockcheck+0x16>
      return locktable[i].held;
    8000309e:	0712                	slli	a4,a4,0x4
    800030a0:	00059797          	auipc	a5,0x59
    800030a4:	50078793          	addi	a5,a5,1280 # 8005c5a0 <shmtable>
    800030a8:	97ba                	add	a5,a5,a4
    800030aa:	2047a503          	lw	a0,516(a5)
    800030ae:	a011                	j	800030b2 <lockcheck+0x3c>
  }
  return -1;
    800030b0:	557d                	li	a0,-1
}
    800030b2:	60a2                	ld	ra,8(sp)
    800030b4:	6402                	ld	s0,0(sp)
    800030b6:	0141                	addi	sp,sp,16
    800030b8:	8082                	ret

00000000800030ba <sys_lockinit>:

uint64 sys_lockinit(void) {
    800030ba:	1101                	addi	sp,sp,-32
    800030bc:	ec06                	sd	ra,24(sp)
    800030be:	e822                	sd	s0,16(sp)
    800030c0:	1000                	addi	s0,sp,32
  int id;
  argint(0, &id);
    800030c2:	fec40593          	addi	a1,s0,-20
    800030c6:	4501                	li	a0,0
    800030c8:	901ff0ef          	jal	800029c8 <argint>
  return lockinit(id);
    800030cc:	fec42503          	lw	a0,-20(s0)
    800030d0:	df5ff0ef          	jal	80002ec4 <lockinit>
}
    800030d4:	60e2                	ld	ra,24(sp)
    800030d6:	6442                	ld	s0,16(sp)
    800030d8:	6105                	addi	sp,sp,32
    800030da:	8082                	ret

00000000800030dc <sys_lockacquire>:

uint64 sys_lockacquire(void) {
    800030dc:	1101                	addi	sp,sp,-32
    800030de:	ec06                	sd	ra,24(sp)
    800030e0:	e822                	sd	s0,16(sp)
    800030e2:	1000                	addi	s0,sp,32
  int id;
  argint(0, &id);
    800030e4:	fec40593          	addi	a1,s0,-20
    800030e8:	4501                	li	a0,0
    800030ea:	8dfff0ef          	jal	800029c8 <argint>
  return lockacquire(id);
    800030ee:	fec42503          	lw	a0,-20(s0)
    800030f2:	e43ff0ef          	jal	80002f34 <lockacquire>
}
    800030f6:	60e2                	ld	ra,24(sp)
    800030f8:	6442                	ld	s0,16(sp)
    800030fa:	6105                	addi	sp,sp,32
    800030fc:	8082                	ret

00000000800030fe <sys_lockrelease>:

uint64 sys_lockrelease(void) {
    800030fe:	1101                	addi	sp,sp,-32
    80003100:	ec06                	sd	ra,24(sp)
    80003102:	e822                	sd	s0,16(sp)
    80003104:	1000                	addi	s0,sp,32
  int id;
  argint(0, &id);
    80003106:	fec40593          	addi	a1,s0,-20
    8000310a:	4501                	li	a0,0
    8000310c:	8bdff0ef          	jal	800029c8 <argint>
  return lockrelease(id);
    80003110:	fec42503          	lw	a0,-20(s0)
    80003114:	e93ff0ef          	jal	80002fa6 <lockrelease>
}
    80003118:	60e2                	ld	ra,24(sp)
    8000311a:	6442                	ld	s0,16(sp)
    8000311c:	6105                	addi	sp,sp,32
    8000311e:	8082                	ret

0000000080003120 <sys_locktry>:

uint64 sys_locktry(void) {
    80003120:	1101                	addi	sp,sp,-32
    80003122:	ec06                	sd	ra,24(sp)
    80003124:	e822                	sd	s0,16(sp)
    80003126:	1000                	addi	s0,sp,32
  int id;
  argint(0, &id);
    80003128:	fec40593          	addi	a1,s0,-20
    8000312c:	4501                	li	a0,0
    8000312e:	89bff0ef          	jal	800029c8 <argint>
  return locktry(id);
    80003132:	fec42503          	lw	a0,-20(s0)
    80003136:	ed3ff0ef          	jal	80003008 <locktry>
}
    8000313a:	60e2                	ld	ra,24(sp)
    8000313c:	6442                	ld	s0,16(sp)
    8000313e:	6105                	addi	sp,sp,32
    80003140:	8082                	ret

0000000080003142 <sys_lockcheck>:

uint64 sys_lockcheck(void) {
    80003142:	1101                	addi	sp,sp,-32
    80003144:	ec06                	sd	ra,24(sp)
    80003146:	e822                	sd	s0,16(sp)
    80003148:	1000                	addi	s0,sp,32
  int id;
  argint(0, &id);
    8000314a:	fec40593          	addi	a1,s0,-20
    8000314e:	4501                	li	a0,0
    80003150:	879ff0ef          	jal	800029c8 <argint>
  return lockcheck(id);
    80003154:	fec42503          	lw	a0,-20(s0)
    80003158:	f1fff0ef          	jal	80003076 <lockcheck>
}
    8000315c:	60e2                	ld	ra,24(sp)
    8000315e:	6442                	ld	s0,16(sp)
    80003160:	6105                	addi	sp,sp,32
    80003162:	8082                	ret

0000000080003164 <sys_getprocsinfo>:

uint64 sys_getprocsinfo(void) {
    80003164:	7179                	addi	sp,sp,-48
    80003166:	f406                	sd	ra,40(sp)
    80003168:	f022                	sd	s0,32(sp)
    8000316a:	ec26                	sd	s1,24(sp)
    8000316c:	e84a                	sd	s2,16(sp)
    8000316e:	e44e                	sd	s3,8(sp)
    80003170:	e052                	sd	s4,0(sp)
    80003172:	1800                	addi	s0,sp,48
  struct proc *p;

  printf("PID\tSTATE\tSIZE\n");
    80003174:	00005517          	auipc	a0,0x5
    80003178:	22c50513          	addi	a0,a0,556 # 800083a0 <etext+0x3a0>
    8000317c:	b7efd0ef          	jal	800004fa <printf>

  for (p = proc; p < &proc[NPROC]; p++) {
    80003180:	00011497          	auipc	s1,0x11
    80003184:	c0848493          	addi	s1,s1,-1016 # 80013d88 <proc>
    if (p->state != UNUSED) {
      printf("%d\t%d\t%ld\n", p->pid, p->state, p->sz);
    80003188:	00005a17          	auipc	s4,0x5
    8000318c:	228a0a13          	addi	s4,s4,552 # 800083b0 <etext+0x3b0>
  for (p = proc; p < &proc[NPROC]; p++) {
    80003190:	6905                	lui	s2,0x1
    80003192:	22090913          	addi	s2,s2,544 # 1220 <_entry-0x7fffede0>
    80003196:	00059997          	auipc	s3,0x59
    8000319a:	3f298993          	addi	s3,s3,1010 # 8005c588 <tickslock>
    8000319e:	a021                	j	800031a6 <sys_getprocsinfo+0x42>
    800031a0:	94ca                	add	s1,s1,s2
    800031a2:	01348a63          	beq	s1,s3,800031b6 <sys_getprocsinfo+0x52>
    if (p->state != UNUSED) {
    800031a6:	4c90                	lw	a2,24(s1)
    800031a8:	de65                	beqz	a2,800031a0 <sys_getprocsinfo+0x3c>
      printf("%d\t%d\t%ld\n", p->pid, p->state, p->sz);
    800031aa:	68b4                	ld	a3,80(s1)
    800031ac:	588c                	lw	a1,48(s1)
    800031ae:	8552                	mv	a0,s4
    800031b0:	b4afd0ef          	jal	800004fa <printf>
    800031b4:	b7f5                	j	800031a0 <sys_getprocsinfo+0x3c>
    }
  }

  return 0;
}
    800031b6:	4501                	li	a0,0
    800031b8:	70a2                	ld	ra,40(sp)
    800031ba:	7402                	ld	s0,32(sp)
    800031bc:	64e2                	ld	s1,24(sp)
    800031be:	6942                	ld	s2,16(sp)
    800031c0:	69a2                	ld	s3,8(sp)
    800031c2:	6a02                	ld	s4,0(sp)
    800031c4:	6145                	addi	sp,sp,48
    800031c6:	8082                	ret

00000000800031c8 <sys_getppid>:

uint64 sys_getppid(void) {
    800031c8:	1141                	addi	sp,sp,-16
    800031ca:	e406                	sd	ra,8(sp)
    800031cc:	e022                	sd	s0,0(sp)
    800031ce:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800031d0:	fbafe0ef          	jal	8000198a <myproc>
  if (p->parent)
    800031d4:	613c                	ld	a5,64(a0)
    return p->parent->pid;
  return -1;
    800031d6:	557d                	li	a0,-1
  if (p->parent)
    800031d8:	c391                	beqz	a5,800031dc <sys_getppid+0x14>
    return p->parent->pid;
    800031da:	5b88                	lw	a0,48(a5)
}
    800031dc:	60a2                	ld	ra,8(sp)
    800031de:	6402                	ld	s0,0(sp)
    800031e0:	0141                	addi	sp,sp,16
    800031e2:	8082                	ret

00000000800031e4 <sys_sleep2>:

uint64 sys_sleep2(void) {
    800031e4:	7139                	addi	sp,sp,-64
    800031e6:	fc06                	sd	ra,56(sp)
    800031e8:	f822                	sd	s0,48(sp)
    800031ea:	f04a                	sd	s2,32(sp)
    800031ec:	0080                	addi	s0,sp,64
  int n;
  argint(0, &n);
    800031ee:	fcc40593          	addi	a1,s0,-52
    800031f2:	4501                	li	a0,0
    800031f4:	fd4ff0ef          	jal	800029c8 <argint>

  struct proc *p = myproc();
    800031f8:	f92fe0ef          	jal	8000198a <myproc>
    800031fc:	892a                	mv	s2,a0

  acquire(&tickslock);
    800031fe:	00059517          	auipc	a0,0x59
    80003202:	38a50513          	addi	a0,a0,906 # 8005c588 <tickslock>
    80003206:	a23fd0ef          	jal	80000c28 <acquire>
  uint ticks0 = ticks;

  while (ticks - ticks0 < n) {
    8000320a:	fcc42783          	lw	a5,-52(s0)
    8000320e:	c3a9                	beqz	a5,80003250 <sys_sleep2+0x6c>
    80003210:	f426                	sd	s1,40(sp)
    80003212:	ec4e                	sd	s3,24(sp)
    80003214:	e852                	sd	s4,16(sp)
  uint ticks0 = ticks;
    80003216:	00008a17          	auipc	s4,0x8
    8000321a:	642a2a03          	lw	s4,1602(s4) # 8000b858 <ticks>
    if (p->killed) {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000321e:	00059997          	auipc	s3,0x59
    80003222:	36a98993          	addi	s3,s3,874 # 8005c588 <tickslock>
    80003226:	00008497          	auipc	s1,0x8
    8000322a:	63248493          	addi	s1,s1,1586 # 8000b858 <ticks>
    if (p->killed) {
    8000322e:	02892783          	lw	a5,40(s2)
    80003232:	eb9d                	bnez	a5,80003268 <sys_sleep2+0x84>
    sleep(&ticks, &tickslock);
    80003234:	85ce                	mv	a1,s3
    80003236:	8526                	mv	a0,s1
    80003238:	e63fe0ef          	jal	8000209a <sleep>
  while (ticks - ticks0 < n) {
    8000323c:	409c                	lw	a5,0(s1)
    8000323e:	414787bb          	subw	a5,a5,s4
    80003242:	fcc42703          	lw	a4,-52(s0)
    80003246:	fee7e4e3          	bltu	a5,a4,8000322e <sys_sleep2+0x4a>
    8000324a:	74a2                	ld	s1,40(sp)
    8000324c:	69e2                	ld	s3,24(sp)
    8000324e:	6a42                	ld	s4,16(sp)
  }

  release(&tickslock);
    80003250:	00059517          	auipc	a0,0x59
    80003254:	33850513          	addi	a0,a0,824 # 8005c588 <tickslock>
    80003258:	a65fd0ef          	jal	80000cbc <release>
  return 0;
    8000325c:	4501                	li	a0,0
}
    8000325e:	70e2                	ld	ra,56(sp)
    80003260:	7442                	ld	s0,48(sp)
    80003262:	7902                	ld	s2,32(sp)
    80003264:	6121                	addi	sp,sp,64
    80003266:	8082                	ret
      release(&tickslock);
    80003268:	00059517          	auipc	a0,0x59
    8000326c:	32050513          	addi	a0,a0,800 # 8005c588 <tickslock>
    80003270:	a4dfd0ef          	jal	80000cbc <release>
      return -1;
    80003274:	557d                	li	a0,-1
    80003276:	74a2                	ld	s1,40(sp)
    80003278:	69e2                	ld	s3,24(sp)
    8000327a:	6a42                	ld	s4,16(sp)
    8000327c:	b7cd                	j	8000325e <sys_sleep2+0x7a>

000000008000327e <sys_signal>:

uint64 sys_signal(void) {
    8000327e:	1101                	addi	sp,sp,-32
    80003280:	ec06                	sd	ra,24(sp)
    80003282:	e822                	sd	s0,16(sp)
    80003284:	1000                	addi	s0,sp,32
  uint64 handler;
  argaddr(1, &handler);
    80003286:	fe840593          	addi	a1,s0,-24
    8000328a:	4505                	li	a0,1
    8000328c:	f58ff0ef          	jal	800029e4 <argaddr>

  struct proc *p = myproc();
    80003290:	efafe0ef          	jal	8000198a <myproc>
  p->handler = (void (*)(int))handler;
    80003294:	fe843783          	ld	a5,-24(s0)
    80003298:	16f53823          	sd	a5,368(a0)

  return 0;
}
    8000329c:	4501                	li	a0,0
    8000329e:	60e2                	ld	ra,24(sp)
    800032a0:	6442                	ld	s0,16(sp)
    800032a2:	6105                	addi	sp,sp,32
    800032a4:	8082                	ret

00000000800032a6 <sys_setchildlimit>:

uint sys_setchildlimit(void){
    800032a6:	1101                	addi	sp,sp,-32
    800032a8:	ec06                	sd	ra,24(sp)
    800032aa:	e822                	sd	s0,16(sp)
    800032ac:	1000                	addi	s0,sp,32
  int limit;
  argint(0,&limit);
    800032ae:	fec40593          	addi	a1,s0,-20
    800032b2:	4501                	li	a0,0
    800032b4:	f14ff0ef          	jal	800029c8 <argint>
  myproc()->child_limit=limit;
    800032b8:	ed2fe0ef          	jal	8000198a <myproc>
    800032bc:	fec42783          	lw	a5,-20(s0)
    800032c0:	dd1c                	sw	a5,56(a0)
  return 0;
    800032c2:	4501                	li	a0,0
    800032c4:	60e2                	ld	ra,24(sp)
    800032c6:	6442                	ld	s0,16(sp)
    800032c8:	6105                	addi	sp,sp,32
    800032ca:	8082                	ret

00000000800032cc <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800032cc:	7179                	addi	sp,sp,-48
    800032ce:	f406                	sd	ra,40(sp)
    800032d0:	f022                	sd	s0,32(sp)
    800032d2:	ec26                	sd	s1,24(sp)
    800032d4:	e84a                	sd	s2,16(sp)
    800032d6:	e44e                	sd	s3,8(sp)
    800032d8:	e052                	sd	s4,0(sp)
    800032da:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800032dc:	00005597          	auipc	a1,0x5
    800032e0:	0e458593          	addi	a1,a1,228 # 800083c0 <etext+0x3c0>
    800032e4:	00059517          	auipc	a0,0x59
    800032e8:	5bc50513          	addi	a0,a0,1468 # 8005c8a0 <bcache>
    800032ec:	8b3fd0ef          	jal	80000b9e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800032f0:	00061797          	auipc	a5,0x61
    800032f4:	5b078793          	addi	a5,a5,1456 # 800648a0 <bcache+0x8000>
    800032f8:	00062717          	auipc	a4,0x62
    800032fc:	81070713          	addi	a4,a4,-2032 # 80064b08 <bcache+0x8268>
    80003300:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003304:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003308:	00059497          	auipc	s1,0x59
    8000330c:	5b048493          	addi	s1,s1,1456 # 8005c8b8 <bcache+0x18>
    b->next = bcache.head.next;
    80003310:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003312:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003314:	00005a17          	auipc	s4,0x5
    80003318:	0b4a0a13          	addi	s4,s4,180 # 800083c8 <etext+0x3c8>
    b->next = bcache.head.next;
    8000331c:	2b893783          	ld	a5,696(s2)
    80003320:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003322:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003326:	85d2                	mv	a1,s4
    80003328:	01048513          	addi	a0,s1,16
    8000332c:	328010ef          	jal	80004654 <initsleeplock>
    bcache.head.next->prev = b;
    80003330:	2b893783          	ld	a5,696(s2)
    80003334:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003336:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000333a:	45848493          	addi	s1,s1,1112
    8000333e:	fd349fe3          	bne	s1,s3,8000331c <binit+0x50>
  }
}
    80003342:	70a2                	ld	ra,40(sp)
    80003344:	7402                	ld	s0,32(sp)
    80003346:	64e2                	ld	s1,24(sp)
    80003348:	6942                	ld	s2,16(sp)
    8000334a:	69a2                	ld	s3,8(sp)
    8000334c:	6a02                	ld	s4,0(sp)
    8000334e:	6145                	addi	sp,sp,48
    80003350:	8082                	ret

0000000080003352 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003352:	7179                	addi	sp,sp,-48
    80003354:	f406                	sd	ra,40(sp)
    80003356:	f022                	sd	s0,32(sp)
    80003358:	ec26                	sd	s1,24(sp)
    8000335a:	e84a                	sd	s2,16(sp)
    8000335c:	e44e                	sd	s3,8(sp)
    8000335e:	1800                	addi	s0,sp,48
    80003360:	892a                	mv	s2,a0
    80003362:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003364:	00059517          	auipc	a0,0x59
    80003368:	53c50513          	addi	a0,a0,1340 # 8005c8a0 <bcache>
    8000336c:	8bdfd0ef          	jal	80000c28 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003370:	00061497          	auipc	s1,0x61
    80003374:	7e84b483          	ld	s1,2024(s1) # 80064b58 <bcache+0x82b8>
    80003378:	00061797          	auipc	a5,0x61
    8000337c:	79078793          	addi	a5,a5,1936 # 80064b08 <bcache+0x8268>
    80003380:	02f48b63          	beq	s1,a5,800033b6 <bread+0x64>
    80003384:	873e                	mv	a4,a5
    80003386:	a021                	j	8000338e <bread+0x3c>
    80003388:	68a4                	ld	s1,80(s1)
    8000338a:	02e48663          	beq	s1,a4,800033b6 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    8000338e:	449c                	lw	a5,8(s1)
    80003390:	ff279ce3          	bne	a5,s2,80003388 <bread+0x36>
    80003394:	44dc                	lw	a5,12(s1)
    80003396:	ff3799e3          	bne	a5,s3,80003388 <bread+0x36>
      b->refcnt++;
    8000339a:	40bc                	lw	a5,64(s1)
    8000339c:	2785                	addiw	a5,a5,1
    8000339e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800033a0:	00059517          	auipc	a0,0x59
    800033a4:	50050513          	addi	a0,a0,1280 # 8005c8a0 <bcache>
    800033a8:	915fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    800033ac:	01048513          	addi	a0,s1,16
    800033b0:	2da010ef          	jal	8000468a <acquiresleep>
      return b;
    800033b4:	a889                	j	80003406 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800033b6:	00061497          	auipc	s1,0x61
    800033ba:	79a4b483          	ld	s1,1946(s1) # 80064b50 <bcache+0x82b0>
    800033be:	00061797          	auipc	a5,0x61
    800033c2:	74a78793          	addi	a5,a5,1866 # 80064b08 <bcache+0x8268>
    800033c6:	00f48863          	beq	s1,a5,800033d6 <bread+0x84>
    800033ca:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800033cc:	40bc                	lw	a5,64(s1)
    800033ce:	cb91                	beqz	a5,800033e2 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800033d0:	64a4                	ld	s1,72(s1)
    800033d2:	fee49de3          	bne	s1,a4,800033cc <bread+0x7a>
  panic("bget: no buffers");
    800033d6:	00005517          	auipc	a0,0x5
    800033da:	ffa50513          	addi	a0,a0,-6 # 800083d0 <etext+0x3d0>
    800033de:	c46fd0ef          	jal	80000824 <panic>
      b->dev = dev;
    800033e2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800033e6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800033ea:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800033ee:	4785                	li	a5,1
    800033f0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800033f2:	00059517          	auipc	a0,0x59
    800033f6:	4ae50513          	addi	a0,a0,1198 # 8005c8a0 <bcache>
    800033fa:	8c3fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    800033fe:	01048513          	addi	a0,s1,16
    80003402:	288010ef          	jal	8000468a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003406:	409c                	lw	a5,0(s1)
    80003408:	cb89                	beqz	a5,8000341a <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000340a:	8526                	mv	a0,s1
    8000340c:	70a2                	ld	ra,40(sp)
    8000340e:	7402                	ld	s0,32(sp)
    80003410:	64e2                	ld	s1,24(sp)
    80003412:	6942                	ld	s2,16(sp)
    80003414:	69a2                	ld	s3,8(sp)
    80003416:	6145                	addi	sp,sp,48
    80003418:	8082                	ret
    virtio_disk_rw(b, 0);
    8000341a:	4581                	li	a1,0
    8000341c:	8526                	mv	a0,s1
    8000341e:	2f3020ef          	jal	80005f10 <virtio_disk_rw>
    b->valid = 1;
    80003422:	4785                	li	a5,1
    80003424:	c09c                	sw	a5,0(s1)
  return b;
    80003426:	b7d5                	j	8000340a <bread+0xb8>

0000000080003428 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003428:	1101                	addi	sp,sp,-32
    8000342a:	ec06                	sd	ra,24(sp)
    8000342c:	e822                	sd	s0,16(sp)
    8000342e:	e426                	sd	s1,8(sp)
    80003430:	1000                	addi	s0,sp,32
    80003432:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003434:	0541                	addi	a0,a0,16
    80003436:	2d2010ef          	jal	80004708 <holdingsleep>
    8000343a:	c911                	beqz	a0,8000344e <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000343c:	4585                	li	a1,1
    8000343e:	8526                	mv	a0,s1
    80003440:	2d1020ef          	jal	80005f10 <virtio_disk_rw>
}
    80003444:	60e2                	ld	ra,24(sp)
    80003446:	6442                	ld	s0,16(sp)
    80003448:	64a2                	ld	s1,8(sp)
    8000344a:	6105                	addi	sp,sp,32
    8000344c:	8082                	ret
    panic("bwrite");
    8000344e:	00005517          	auipc	a0,0x5
    80003452:	f9a50513          	addi	a0,a0,-102 # 800083e8 <etext+0x3e8>
    80003456:	bcefd0ef          	jal	80000824 <panic>

000000008000345a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000345a:	1101                	addi	sp,sp,-32
    8000345c:	ec06                	sd	ra,24(sp)
    8000345e:	e822                	sd	s0,16(sp)
    80003460:	e426                	sd	s1,8(sp)
    80003462:	e04a                	sd	s2,0(sp)
    80003464:	1000                	addi	s0,sp,32
    80003466:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003468:	01050913          	addi	s2,a0,16
    8000346c:	854a                	mv	a0,s2
    8000346e:	29a010ef          	jal	80004708 <holdingsleep>
    80003472:	c125                	beqz	a0,800034d2 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80003474:	854a                	mv	a0,s2
    80003476:	25a010ef          	jal	800046d0 <releasesleep>

  acquire(&bcache.lock);
    8000347a:	00059517          	auipc	a0,0x59
    8000347e:	42650513          	addi	a0,a0,1062 # 8005c8a0 <bcache>
    80003482:	fa6fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80003486:	40bc                	lw	a5,64(s1)
    80003488:	37fd                	addiw	a5,a5,-1
    8000348a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000348c:	e79d                	bnez	a5,800034ba <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000348e:	68b8                	ld	a4,80(s1)
    80003490:	64bc                	ld	a5,72(s1)
    80003492:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003494:	68b8                	ld	a4,80(s1)
    80003496:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003498:	00061797          	auipc	a5,0x61
    8000349c:	40878793          	addi	a5,a5,1032 # 800648a0 <bcache+0x8000>
    800034a0:	2b87b703          	ld	a4,696(a5)
    800034a4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800034a6:	00061717          	auipc	a4,0x61
    800034aa:	66270713          	addi	a4,a4,1634 # 80064b08 <bcache+0x8268>
    800034ae:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800034b0:	2b87b703          	ld	a4,696(a5)
    800034b4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800034b6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800034ba:	00059517          	auipc	a0,0x59
    800034be:	3e650513          	addi	a0,a0,998 # 8005c8a0 <bcache>
    800034c2:	ffafd0ef          	jal	80000cbc <release>
}
    800034c6:	60e2                	ld	ra,24(sp)
    800034c8:	6442                	ld	s0,16(sp)
    800034ca:	64a2                	ld	s1,8(sp)
    800034cc:	6902                	ld	s2,0(sp)
    800034ce:	6105                	addi	sp,sp,32
    800034d0:	8082                	ret
    panic("brelse");
    800034d2:	00005517          	auipc	a0,0x5
    800034d6:	f1e50513          	addi	a0,a0,-226 # 800083f0 <etext+0x3f0>
    800034da:	b4afd0ef          	jal	80000824 <panic>

00000000800034de <bpin>:

void
bpin(struct buf *b) {
    800034de:	1101                	addi	sp,sp,-32
    800034e0:	ec06                	sd	ra,24(sp)
    800034e2:	e822                	sd	s0,16(sp)
    800034e4:	e426                	sd	s1,8(sp)
    800034e6:	1000                	addi	s0,sp,32
    800034e8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800034ea:	00059517          	auipc	a0,0x59
    800034ee:	3b650513          	addi	a0,a0,950 # 8005c8a0 <bcache>
    800034f2:	f36fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    800034f6:	40bc                	lw	a5,64(s1)
    800034f8:	2785                	addiw	a5,a5,1
    800034fa:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034fc:	00059517          	auipc	a0,0x59
    80003500:	3a450513          	addi	a0,a0,932 # 8005c8a0 <bcache>
    80003504:	fb8fd0ef          	jal	80000cbc <release>
}
    80003508:	60e2                	ld	ra,24(sp)
    8000350a:	6442                	ld	s0,16(sp)
    8000350c:	64a2                	ld	s1,8(sp)
    8000350e:	6105                	addi	sp,sp,32
    80003510:	8082                	ret

0000000080003512 <bunpin>:

void
bunpin(struct buf *b) {
    80003512:	1101                	addi	sp,sp,-32
    80003514:	ec06                	sd	ra,24(sp)
    80003516:	e822                	sd	s0,16(sp)
    80003518:	e426                	sd	s1,8(sp)
    8000351a:	1000                	addi	s0,sp,32
    8000351c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000351e:	00059517          	auipc	a0,0x59
    80003522:	38250513          	addi	a0,a0,898 # 8005c8a0 <bcache>
    80003526:	f02fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    8000352a:	40bc                	lw	a5,64(s1)
    8000352c:	37fd                	addiw	a5,a5,-1
    8000352e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003530:	00059517          	auipc	a0,0x59
    80003534:	37050513          	addi	a0,a0,880 # 8005c8a0 <bcache>
    80003538:	f84fd0ef          	jal	80000cbc <release>
}
    8000353c:	60e2                	ld	ra,24(sp)
    8000353e:	6442                	ld	s0,16(sp)
    80003540:	64a2                	ld	s1,8(sp)
    80003542:	6105                	addi	sp,sp,32
    80003544:	8082                	ret

0000000080003546 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003546:	1101                	addi	sp,sp,-32
    80003548:	ec06                	sd	ra,24(sp)
    8000354a:	e822                	sd	s0,16(sp)
    8000354c:	e426                	sd	s1,8(sp)
    8000354e:	e04a                	sd	s2,0(sp)
    80003550:	1000                	addi	s0,sp,32
    80003552:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003554:	00d5d79b          	srliw	a5,a1,0xd
    80003558:	00062597          	auipc	a1,0x62
    8000355c:	a245a583          	lw	a1,-1500(a1) # 80064f7c <sb+0x1c>
    80003560:	9dbd                	addw	a1,a1,a5
    80003562:	df1ff0ef          	jal	80003352 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003566:	0074f713          	andi	a4,s1,7
    8000356a:	4785                	li	a5,1
    8000356c:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80003570:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80003572:	90d9                	srli	s1,s1,0x36
    80003574:	00950733          	add	a4,a0,s1
    80003578:	05874703          	lbu	a4,88(a4)
    8000357c:	00e7f6b3          	and	a3,a5,a4
    80003580:	c29d                	beqz	a3,800035a6 <bfree+0x60>
    80003582:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003584:	94aa                	add	s1,s1,a0
    80003586:	fff7c793          	not	a5,a5
    8000358a:	8f7d                	and	a4,a4,a5
    8000358c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003590:	000010ef          	jal	80004590 <log_write>
  brelse(bp);
    80003594:	854a                	mv	a0,s2
    80003596:	ec5ff0ef          	jal	8000345a <brelse>
}
    8000359a:	60e2                	ld	ra,24(sp)
    8000359c:	6442                	ld	s0,16(sp)
    8000359e:	64a2                	ld	s1,8(sp)
    800035a0:	6902                	ld	s2,0(sp)
    800035a2:	6105                	addi	sp,sp,32
    800035a4:	8082                	ret
    panic("freeing free block");
    800035a6:	00005517          	auipc	a0,0x5
    800035aa:	e5250513          	addi	a0,a0,-430 # 800083f8 <etext+0x3f8>
    800035ae:	a76fd0ef          	jal	80000824 <panic>

00000000800035b2 <balloc>:
{
    800035b2:	715d                	addi	sp,sp,-80
    800035b4:	e486                	sd	ra,72(sp)
    800035b6:	e0a2                	sd	s0,64(sp)
    800035b8:	fc26                	sd	s1,56(sp)
    800035ba:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    800035bc:	00062797          	auipc	a5,0x62
    800035c0:	9a87a783          	lw	a5,-1624(a5) # 80064f64 <sb+0x4>
    800035c4:	0e078263          	beqz	a5,800036a8 <balloc+0xf6>
    800035c8:	f84a                	sd	s2,48(sp)
    800035ca:	f44e                	sd	s3,40(sp)
    800035cc:	f052                	sd	s4,32(sp)
    800035ce:	ec56                	sd	s5,24(sp)
    800035d0:	e85a                	sd	s6,16(sp)
    800035d2:	e45e                	sd	s7,8(sp)
    800035d4:	e062                	sd	s8,0(sp)
    800035d6:	8baa                	mv	s7,a0
    800035d8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800035da:	00062b17          	auipc	s6,0x62
    800035de:	986b0b13          	addi	s6,s6,-1658 # 80064f60 <sb>
      m = 1 << (bi % 8);
    800035e2:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035e4:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800035e6:	6c09                	lui	s8,0x2
    800035e8:	a09d                	j	8000364e <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    800035ea:	97ca                	add	a5,a5,s2
    800035ec:	8e55                	or	a2,a2,a3
    800035ee:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800035f2:	854a                	mv	a0,s2
    800035f4:	79d000ef          	jal	80004590 <log_write>
        brelse(bp);
    800035f8:	854a                	mv	a0,s2
    800035fa:	e61ff0ef          	jal	8000345a <brelse>
  bp = bread(dev, bno);
    800035fe:	85a6                	mv	a1,s1
    80003600:	855e                	mv	a0,s7
    80003602:	d51ff0ef          	jal	80003352 <bread>
    80003606:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003608:	40000613          	li	a2,1024
    8000360c:	4581                	li	a1,0
    8000360e:	05850513          	addi	a0,a0,88
    80003612:	ee6fd0ef          	jal	80000cf8 <memset>
  log_write(bp);
    80003616:	854a                	mv	a0,s2
    80003618:	779000ef          	jal	80004590 <log_write>
  brelse(bp);
    8000361c:	854a                	mv	a0,s2
    8000361e:	e3dff0ef          	jal	8000345a <brelse>
}
    80003622:	7942                	ld	s2,48(sp)
    80003624:	79a2                	ld	s3,40(sp)
    80003626:	7a02                	ld	s4,32(sp)
    80003628:	6ae2                	ld	s5,24(sp)
    8000362a:	6b42                	ld	s6,16(sp)
    8000362c:	6ba2                	ld	s7,8(sp)
    8000362e:	6c02                	ld	s8,0(sp)
}
    80003630:	8526                	mv	a0,s1
    80003632:	60a6                	ld	ra,72(sp)
    80003634:	6406                	ld	s0,64(sp)
    80003636:	74e2                	ld	s1,56(sp)
    80003638:	6161                	addi	sp,sp,80
    8000363a:	8082                	ret
    brelse(bp);
    8000363c:	854a                	mv	a0,s2
    8000363e:	e1dff0ef          	jal	8000345a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003642:	015c0abb          	addw	s5,s8,s5
    80003646:	004b2783          	lw	a5,4(s6)
    8000364a:	04faf863          	bgeu	s5,a5,8000369a <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    8000364e:	40dad59b          	sraiw	a1,s5,0xd
    80003652:	01cb2783          	lw	a5,28(s6)
    80003656:	9dbd                	addw	a1,a1,a5
    80003658:	855e                	mv	a0,s7
    8000365a:	cf9ff0ef          	jal	80003352 <bread>
    8000365e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003660:	004b2503          	lw	a0,4(s6)
    80003664:	84d6                	mv	s1,s5
    80003666:	4701                	li	a4,0
    80003668:	fca4fae3          	bgeu	s1,a0,8000363c <balloc+0x8a>
      m = 1 << (bi % 8);
    8000366c:	00777693          	andi	a3,a4,7
    80003670:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003674:	41f7579b          	sraiw	a5,a4,0x1f
    80003678:	01d7d79b          	srliw	a5,a5,0x1d
    8000367c:	9fb9                	addw	a5,a5,a4
    8000367e:	4037d79b          	sraiw	a5,a5,0x3
    80003682:	00f90633          	add	a2,s2,a5
    80003686:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    8000368a:	00c6f5b3          	and	a1,a3,a2
    8000368e:	ddb1                	beqz	a1,800035ea <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003690:	2705                	addiw	a4,a4,1
    80003692:	2485                	addiw	s1,s1,1
    80003694:	fd471ae3          	bne	a4,s4,80003668 <balloc+0xb6>
    80003698:	b755                	j	8000363c <balloc+0x8a>
    8000369a:	7942                	ld	s2,48(sp)
    8000369c:	79a2                	ld	s3,40(sp)
    8000369e:	7a02                	ld	s4,32(sp)
    800036a0:	6ae2                	ld	s5,24(sp)
    800036a2:	6b42                	ld	s6,16(sp)
    800036a4:	6ba2                	ld	s7,8(sp)
    800036a6:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    800036a8:	00005517          	auipc	a0,0x5
    800036ac:	d6850513          	addi	a0,a0,-664 # 80008410 <etext+0x410>
    800036b0:	e4bfc0ef          	jal	800004fa <printf>
  return 0;
    800036b4:	4481                	li	s1,0
    800036b6:	bfad                	j	80003630 <balloc+0x7e>

00000000800036b8 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800036b8:	7179                	addi	sp,sp,-48
    800036ba:	f406                	sd	ra,40(sp)
    800036bc:	f022                	sd	s0,32(sp)
    800036be:	ec26                	sd	s1,24(sp)
    800036c0:	e84a                	sd	s2,16(sp)
    800036c2:	e44e                	sd	s3,8(sp)
    800036c4:	1800                	addi	s0,sp,48
    800036c6:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800036c8:	47ad                	li	a5,11
    800036ca:	02b7e363          	bltu	a5,a1,800036f0 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    800036ce:	02059793          	slli	a5,a1,0x20
    800036d2:	01e7d593          	srli	a1,a5,0x1e
    800036d6:	00b509b3          	add	s3,a0,a1
    800036da:	0509a483          	lw	s1,80(s3)
    800036de:	e0b5                	bnez	s1,80003742 <bmap+0x8a>
      addr = balloc(ip->dev);
    800036e0:	4108                	lw	a0,0(a0)
    800036e2:	ed1ff0ef          	jal	800035b2 <balloc>
    800036e6:	84aa                	mv	s1,a0
      if(addr == 0)
    800036e8:	cd29                	beqz	a0,80003742 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    800036ea:	04a9a823          	sw	a0,80(s3)
    800036ee:	a891                	j	80003742 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800036f0:	ff45879b          	addiw	a5,a1,-12
    800036f4:	873e                	mv	a4,a5
    800036f6:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    800036f8:	0ff00793          	li	a5,255
    800036fc:	06e7e763          	bltu	a5,a4,8000376a <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003700:	08052483          	lw	s1,128(a0)
    80003704:	e891                	bnez	s1,80003718 <bmap+0x60>
      addr = balloc(ip->dev);
    80003706:	4108                	lw	a0,0(a0)
    80003708:	eabff0ef          	jal	800035b2 <balloc>
    8000370c:	84aa                	mv	s1,a0
      if(addr == 0)
    8000370e:	c915                	beqz	a0,80003742 <bmap+0x8a>
    80003710:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003712:	08a92023          	sw	a0,128(s2)
    80003716:	a011                	j	8000371a <bmap+0x62>
    80003718:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000371a:	85a6                	mv	a1,s1
    8000371c:	00092503          	lw	a0,0(s2)
    80003720:	c33ff0ef          	jal	80003352 <bread>
    80003724:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003726:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000372a:	02099713          	slli	a4,s3,0x20
    8000372e:	01e75593          	srli	a1,a4,0x1e
    80003732:	97ae                	add	a5,a5,a1
    80003734:	89be                	mv	s3,a5
    80003736:	4384                	lw	s1,0(a5)
    80003738:	cc89                	beqz	s1,80003752 <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000373a:	8552                	mv	a0,s4
    8000373c:	d1fff0ef          	jal	8000345a <brelse>
    return addr;
    80003740:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003742:	8526                	mv	a0,s1
    80003744:	70a2                	ld	ra,40(sp)
    80003746:	7402                	ld	s0,32(sp)
    80003748:	64e2                	ld	s1,24(sp)
    8000374a:	6942                	ld	s2,16(sp)
    8000374c:	69a2                	ld	s3,8(sp)
    8000374e:	6145                	addi	sp,sp,48
    80003750:	8082                	ret
      addr = balloc(ip->dev);
    80003752:	00092503          	lw	a0,0(s2)
    80003756:	e5dff0ef          	jal	800035b2 <balloc>
    8000375a:	84aa                	mv	s1,a0
      if(addr){
    8000375c:	dd79                	beqz	a0,8000373a <bmap+0x82>
        a[bn] = addr;
    8000375e:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003762:	8552                	mv	a0,s4
    80003764:	62d000ef          	jal	80004590 <log_write>
    80003768:	bfc9                	j	8000373a <bmap+0x82>
    8000376a:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000376c:	00005517          	auipc	a0,0x5
    80003770:	cbc50513          	addi	a0,a0,-836 # 80008428 <etext+0x428>
    80003774:	8b0fd0ef          	jal	80000824 <panic>

0000000080003778 <iget>:
{
    80003778:	7179                	addi	sp,sp,-48
    8000377a:	f406                	sd	ra,40(sp)
    8000377c:	f022                	sd	s0,32(sp)
    8000377e:	ec26                	sd	s1,24(sp)
    80003780:	e84a                	sd	s2,16(sp)
    80003782:	e44e                	sd	s3,8(sp)
    80003784:	e052                	sd	s4,0(sp)
    80003786:	1800                	addi	s0,sp,48
    80003788:	892a                	mv	s2,a0
    8000378a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000378c:	00061517          	auipc	a0,0x61
    80003790:	7f450513          	addi	a0,a0,2036 # 80064f80 <itable>
    80003794:	c94fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    80003798:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000379a:	00061497          	auipc	s1,0x61
    8000379e:	7fe48493          	addi	s1,s1,2046 # 80064f98 <itable+0x18>
    800037a2:	00063697          	auipc	a3,0x63
    800037a6:	28668693          	addi	a3,a3,646 # 80066a28 <log>
    800037aa:	a809                	j	800037bc <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800037ac:	e781                	bnez	a5,800037b4 <iget+0x3c>
    800037ae:	00099363          	bnez	s3,800037b4 <iget+0x3c>
      empty = ip;
    800037b2:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037b4:	08848493          	addi	s1,s1,136
    800037b8:	02d48563          	beq	s1,a3,800037e2 <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800037bc:	449c                	lw	a5,8(s1)
    800037be:	fef057e3          	blez	a5,800037ac <iget+0x34>
    800037c2:	4098                	lw	a4,0(s1)
    800037c4:	ff2718e3          	bne	a4,s2,800037b4 <iget+0x3c>
    800037c8:	40d8                	lw	a4,4(s1)
    800037ca:	ff4715e3          	bne	a4,s4,800037b4 <iget+0x3c>
      ip->ref++;
    800037ce:	2785                	addiw	a5,a5,1
    800037d0:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800037d2:	00061517          	auipc	a0,0x61
    800037d6:	7ae50513          	addi	a0,a0,1966 # 80064f80 <itable>
    800037da:	ce2fd0ef          	jal	80000cbc <release>
      return ip;
    800037de:	89a6                	mv	s3,s1
    800037e0:	a015                	j	80003804 <iget+0x8c>
  if(empty == 0)
    800037e2:	02098a63          	beqz	s3,80003816 <iget+0x9e>
  ip->dev = dev;
    800037e6:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    800037ea:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    800037ee:	4785                	li	a5,1
    800037f0:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    800037f4:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    800037f8:	00061517          	auipc	a0,0x61
    800037fc:	78850513          	addi	a0,a0,1928 # 80064f80 <itable>
    80003800:	cbcfd0ef          	jal	80000cbc <release>
}
    80003804:	854e                	mv	a0,s3
    80003806:	70a2                	ld	ra,40(sp)
    80003808:	7402                	ld	s0,32(sp)
    8000380a:	64e2                	ld	s1,24(sp)
    8000380c:	6942                	ld	s2,16(sp)
    8000380e:	69a2                	ld	s3,8(sp)
    80003810:	6a02                	ld	s4,0(sp)
    80003812:	6145                	addi	sp,sp,48
    80003814:	8082                	ret
    panic("iget: no inodes");
    80003816:	00005517          	auipc	a0,0x5
    8000381a:	c2a50513          	addi	a0,a0,-982 # 80008440 <etext+0x440>
    8000381e:	806fd0ef          	jal	80000824 <panic>

0000000080003822 <iinit>:
{
    80003822:	7179                	addi	sp,sp,-48
    80003824:	f406                	sd	ra,40(sp)
    80003826:	f022                	sd	s0,32(sp)
    80003828:	ec26                	sd	s1,24(sp)
    8000382a:	e84a                	sd	s2,16(sp)
    8000382c:	e44e                	sd	s3,8(sp)
    8000382e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003830:	00005597          	auipc	a1,0x5
    80003834:	c2058593          	addi	a1,a1,-992 # 80008450 <etext+0x450>
    80003838:	00061517          	auipc	a0,0x61
    8000383c:	74850513          	addi	a0,a0,1864 # 80064f80 <itable>
    80003840:	b5efd0ef          	jal	80000b9e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003844:	00061497          	auipc	s1,0x61
    80003848:	76448493          	addi	s1,s1,1892 # 80064fa8 <itable+0x28>
    8000384c:	00063997          	auipc	s3,0x63
    80003850:	1ec98993          	addi	s3,s3,492 # 80066a38 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003854:	00005917          	auipc	s2,0x5
    80003858:	c0490913          	addi	s2,s2,-1020 # 80008458 <etext+0x458>
    8000385c:	85ca                	mv	a1,s2
    8000385e:	8526                	mv	a0,s1
    80003860:	5f5000ef          	jal	80004654 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003864:	08848493          	addi	s1,s1,136
    80003868:	ff349ae3          	bne	s1,s3,8000385c <iinit+0x3a>
}
    8000386c:	70a2                	ld	ra,40(sp)
    8000386e:	7402                	ld	s0,32(sp)
    80003870:	64e2                	ld	s1,24(sp)
    80003872:	6942                	ld	s2,16(sp)
    80003874:	69a2                	ld	s3,8(sp)
    80003876:	6145                	addi	sp,sp,48
    80003878:	8082                	ret

000000008000387a <ialloc>:
{
    8000387a:	7139                	addi	sp,sp,-64
    8000387c:	fc06                	sd	ra,56(sp)
    8000387e:	f822                	sd	s0,48(sp)
    80003880:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003882:	00061717          	auipc	a4,0x61
    80003886:	6ea72703          	lw	a4,1770(a4) # 80064f6c <sb+0xc>
    8000388a:	4785                	li	a5,1
    8000388c:	06e7f063          	bgeu	a5,a4,800038ec <ialloc+0x72>
    80003890:	f426                	sd	s1,40(sp)
    80003892:	f04a                	sd	s2,32(sp)
    80003894:	ec4e                	sd	s3,24(sp)
    80003896:	e852                	sd	s4,16(sp)
    80003898:	e456                	sd	s5,8(sp)
    8000389a:	e05a                	sd	s6,0(sp)
    8000389c:	8aaa                	mv	s5,a0
    8000389e:	8b2e                	mv	s6,a1
    800038a0:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800038a2:	00061a17          	auipc	s4,0x61
    800038a6:	6bea0a13          	addi	s4,s4,1726 # 80064f60 <sb>
    800038aa:	00495593          	srli	a1,s2,0x4
    800038ae:	018a2783          	lw	a5,24(s4)
    800038b2:	9dbd                	addw	a1,a1,a5
    800038b4:	8556                	mv	a0,s5
    800038b6:	a9dff0ef          	jal	80003352 <bread>
    800038ba:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800038bc:	05850993          	addi	s3,a0,88
    800038c0:	00f97793          	andi	a5,s2,15
    800038c4:	079a                	slli	a5,a5,0x6
    800038c6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800038c8:	00099783          	lh	a5,0(s3)
    800038cc:	cb9d                	beqz	a5,80003902 <ialloc+0x88>
    brelse(bp);
    800038ce:	b8dff0ef          	jal	8000345a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800038d2:	0905                	addi	s2,s2,1
    800038d4:	00ca2703          	lw	a4,12(s4)
    800038d8:	0009079b          	sext.w	a5,s2
    800038dc:	fce7e7e3          	bltu	a5,a4,800038aa <ialloc+0x30>
    800038e0:	74a2                	ld	s1,40(sp)
    800038e2:	7902                	ld	s2,32(sp)
    800038e4:	69e2                	ld	s3,24(sp)
    800038e6:	6a42                	ld	s4,16(sp)
    800038e8:	6aa2                	ld	s5,8(sp)
    800038ea:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800038ec:	00005517          	auipc	a0,0x5
    800038f0:	b7450513          	addi	a0,a0,-1164 # 80008460 <etext+0x460>
    800038f4:	c07fc0ef          	jal	800004fa <printf>
  return 0;
    800038f8:	4501                	li	a0,0
}
    800038fa:	70e2                	ld	ra,56(sp)
    800038fc:	7442                	ld	s0,48(sp)
    800038fe:	6121                	addi	sp,sp,64
    80003900:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003902:	04000613          	li	a2,64
    80003906:	4581                	li	a1,0
    80003908:	854e                	mv	a0,s3
    8000390a:	beefd0ef          	jal	80000cf8 <memset>
      dip->type = type;
    8000390e:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003912:	8526                	mv	a0,s1
    80003914:	47d000ef          	jal	80004590 <log_write>
      brelse(bp);
    80003918:	8526                	mv	a0,s1
    8000391a:	b41ff0ef          	jal	8000345a <brelse>
      return iget(dev, inum);
    8000391e:	0009059b          	sext.w	a1,s2
    80003922:	8556                	mv	a0,s5
    80003924:	e55ff0ef          	jal	80003778 <iget>
    80003928:	74a2                	ld	s1,40(sp)
    8000392a:	7902                	ld	s2,32(sp)
    8000392c:	69e2                	ld	s3,24(sp)
    8000392e:	6a42                	ld	s4,16(sp)
    80003930:	6aa2                	ld	s5,8(sp)
    80003932:	6b02                	ld	s6,0(sp)
    80003934:	b7d9                	j	800038fa <ialloc+0x80>

0000000080003936 <iupdate>:
{
    80003936:	1101                	addi	sp,sp,-32
    80003938:	ec06                	sd	ra,24(sp)
    8000393a:	e822                	sd	s0,16(sp)
    8000393c:	e426                	sd	s1,8(sp)
    8000393e:	e04a                	sd	s2,0(sp)
    80003940:	1000                	addi	s0,sp,32
    80003942:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003944:	415c                	lw	a5,4(a0)
    80003946:	0047d79b          	srliw	a5,a5,0x4
    8000394a:	00061597          	auipc	a1,0x61
    8000394e:	62e5a583          	lw	a1,1582(a1) # 80064f78 <sb+0x18>
    80003952:	9dbd                	addw	a1,a1,a5
    80003954:	4108                	lw	a0,0(a0)
    80003956:	9fdff0ef          	jal	80003352 <bread>
    8000395a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000395c:	05850793          	addi	a5,a0,88
    80003960:	40d8                	lw	a4,4(s1)
    80003962:	8b3d                	andi	a4,a4,15
    80003964:	071a                	slli	a4,a4,0x6
    80003966:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003968:	04449703          	lh	a4,68(s1)
    8000396c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003970:	04649703          	lh	a4,70(s1)
    80003974:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003978:	04849703          	lh	a4,72(s1)
    8000397c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003980:	04a49703          	lh	a4,74(s1)
    80003984:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003988:	44f8                	lw	a4,76(s1)
    8000398a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000398c:	03400613          	li	a2,52
    80003990:	05048593          	addi	a1,s1,80
    80003994:	00c78513          	addi	a0,a5,12
    80003998:	bc0fd0ef          	jal	80000d58 <memmove>
  log_write(bp);
    8000399c:	854a                	mv	a0,s2
    8000399e:	3f3000ef          	jal	80004590 <log_write>
  brelse(bp);
    800039a2:	854a                	mv	a0,s2
    800039a4:	ab7ff0ef          	jal	8000345a <brelse>
}
    800039a8:	60e2                	ld	ra,24(sp)
    800039aa:	6442                	ld	s0,16(sp)
    800039ac:	64a2                	ld	s1,8(sp)
    800039ae:	6902                	ld	s2,0(sp)
    800039b0:	6105                	addi	sp,sp,32
    800039b2:	8082                	ret

00000000800039b4 <idup>:
{
    800039b4:	1101                	addi	sp,sp,-32
    800039b6:	ec06                	sd	ra,24(sp)
    800039b8:	e822                	sd	s0,16(sp)
    800039ba:	e426                	sd	s1,8(sp)
    800039bc:	1000                	addi	s0,sp,32
    800039be:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800039c0:	00061517          	auipc	a0,0x61
    800039c4:	5c050513          	addi	a0,a0,1472 # 80064f80 <itable>
    800039c8:	a60fd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    800039cc:	449c                	lw	a5,8(s1)
    800039ce:	2785                	addiw	a5,a5,1
    800039d0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039d2:	00061517          	auipc	a0,0x61
    800039d6:	5ae50513          	addi	a0,a0,1454 # 80064f80 <itable>
    800039da:	ae2fd0ef          	jal	80000cbc <release>
}
    800039de:	8526                	mv	a0,s1
    800039e0:	60e2                	ld	ra,24(sp)
    800039e2:	6442                	ld	s0,16(sp)
    800039e4:	64a2                	ld	s1,8(sp)
    800039e6:	6105                	addi	sp,sp,32
    800039e8:	8082                	ret

00000000800039ea <ilock>:
{
    800039ea:	1101                	addi	sp,sp,-32
    800039ec:	ec06                	sd	ra,24(sp)
    800039ee:	e822                	sd	s0,16(sp)
    800039f0:	e426                	sd	s1,8(sp)
    800039f2:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800039f4:	cd19                	beqz	a0,80003a12 <ilock+0x28>
    800039f6:	84aa                	mv	s1,a0
    800039f8:	451c                	lw	a5,8(a0)
    800039fa:	00f05c63          	blez	a5,80003a12 <ilock+0x28>
  acquiresleep(&ip->lock);
    800039fe:	0541                	addi	a0,a0,16
    80003a00:	48b000ef          	jal	8000468a <acquiresleep>
  if(ip->valid == 0){
    80003a04:	40bc                	lw	a5,64(s1)
    80003a06:	cf89                	beqz	a5,80003a20 <ilock+0x36>
}
    80003a08:	60e2                	ld	ra,24(sp)
    80003a0a:	6442                	ld	s0,16(sp)
    80003a0c:	64a2                	ld	s1,8(sp)
    80003a0e:	6105                	addi	sp,sp,32
    80003a10:	8082                	ret
    80003a12:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003a14:	00005517          	auipc	a0,0x5
    80003a18:	a6450513          	addi	a0,a0,-1436 # 80008478 <etext+0x478>
    80003a1c:	e09fc0ef          	jal	80000824 <panic>
    80003a20:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a22:	40dc                	lw	a5,4(s1)
    80003a24:	0047d79b          	srliw	a5,a5,0x4
    80003a28:	00061597          	auipc	a1,0x61
    80003a2c:	5505a583          	lw	a1,1360(a1) # 80064f78 <sb+0x18>
    80003a30:	9dbd                	addw	a1,a1,a5
    80003a32:	4088                	lw	a0,0(s1)
    80003a34:	91fff0ef          	jal	80003352 <bread>
    80003a38:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a3a:	05850593          	addi	a1,a0,88
    80003a3e:	40dc                	lw	a5,4(s1)
    80003a40:	8bbd                	andi	a5,a5,15
    80003a42:	079a                	slli	a5,a5,0x6
    80003a44:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a46:	00059783          	lh	a5,0(a1)
    80003a4a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a4e:	00259783          	lh	a5,2(a1)
    80003a52:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a56:	00459783          	lh	a5,4(a1)
    80003a5a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a5e:	00659783          	lh	a5,6(a1)
    80003a62:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a66:	459c                	lw	a5,8(a1)
    80003a68:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a6a:	03400613          	li	a2,52
    80003a6e:	05b1                	addi	a1,a1,12
    80003a70:	05048513          	addi	a0,s1,80
    80003a74:	ae4fd0ef          	jal	80000d58 <memmove>
    brelse(bp);
    80003a78:	854a                	mv	a0,s2
    80003a7a:	9e1ff0ef          	jal	8000345a <brelse>
    ip->valid = 1;
    80003a7e:	4785                	li	a5,1
    80003a80:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a82:	04449783          	lh	a5,68(s1)
    80003a86:	c399                	beqz	a5,80003a8c <ilock+0xa2>
    80003a88:	6902                	ld	s2,0(sp)
    80003a8a:	bfbd                	j	80003a08 <ilock+0x1e>
      panic("ilock: no type");
    80003a8c:	00005517          	auipc	a0,0x5
    80003a90:	9f450513          	addi	a0,a0,-1548 # 80008480 <etext+0x480>
    80003a94:	d91fc0ef          	jal	80000824 <panic>

0000000080003a98 <iunlock>:
{
    80003a98:	1101                	addi	sp,sp,-32
    80003a9a:	ec06                	sd	ra,24(sp)
    80003a9c:	e822                	sd	s0,16(sp)
    80003a9e:	e426                	sd	s1,8(sp)
    80003aa0:	e04a                	sd	s2,0(sp)
    80003aa2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003aa4:	c505                	beqz	a0,80003acc <iunlock+0x34>
    80003aa6:	84aa                	mv	s1,a0
    80003aa8:	01050913          	addi	s2,a0,16
    80003aac:	854a                	mv	a0,s2
    80003aae:	45b000ef          	jal	80004708 <holdingsleep>
    80003ab2:	cd09                	beqz	a0,80003acc <iunlock+0x34>
    80003ab4:	449c                	lw	a5,8(s1)
    80003ab6:	00f05b63          	blez	a5,80003acc <iunlock+0x34>
  releasesleep(&ip->lock);
    80003aba:	854a                	mv	a0,s2
    80003abc:	415000ef          	jal	800046d0 <releasesleep>
}
    80003ac0:	60e2                	ld	ra,24(sp)
    80003ac2:	6442                	ld	s0,16(sp)
    80003ac4:	64a2                	ld	s1,8(sp)
    80003ac6:	6902                	ld	s2,0(sp)
    80003ac8:	6105                	addi	sp,sp,32
    80003aca:	8082                	ret
    panic("iunlock");
    80003acc:	00005517          	auipc	a0,0x5
    80003ad0:	9c450513          	addi	a0,a0,-1596 # 80008490 <etext+0x490>
    80003ad4:	d51fc0ef          	jal	80000824 <panic>

0000000080003ad8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003ad8:	7179                	addi	sp,sp,-48
    80003ada:	f406                	sd	ra,40(sp)
    80003adc:	f022                	sd	s0,32(sp)
    80003ade:	ec26                	sd	s1,24(sp)
    80003ae0:	e84a                	sd	s2,16(sp)
    80003ae2:	e44e                	sd	s3,8(sp)
    80003ae4:	1800                	addi	s0,sp,48
    80003ae6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003ae8:	05050493          	addi	s1,a0,80
    80003aec:	08050913          	addi	s2,a0,128
    80003af0:	a021                	j	80003af8 <itrunc+0x20>
    80003af2:	0491                	addi	s1,s1,4
    80003af4:	01248b63          	beq	s1,s2,80003b0a <itrunc+0x32>
    if(ip->addrs[i]){
    80003af8:	408c                	lw	a1,0(s1)
    80003afa:	dde5                	beqz	a1,80003af2 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003afc:	0009a503          	lw	a0,0(s3)
    80003b00:	a47ff0ef          	jal	80003546 <bfree>
      ip->addrs[i] = 0;
    80003b04:	0004a023          	sw	zero,0(s1)
    80003b08:	b7ed                	j	80003af2 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b0a:	0809a583          	lw	a1,128(s3)
    80003b0e:	ed89                	bnez	a1,80003b28 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b10:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b14:	854e                	mv	a0,s3
    80003b16:	e21ff0ef          	jal	80003936 <iupdate>
}
    80003b1a:	70a2                	ld	ra,40(sp)
    80003b1c:	7402                	ld	s0,32(sp)
    80003b1e:	64e2                	ld	s1,24(sp)
    80003b20:	6942                	ld	s2,16(sp)
    80003b22:	69a2                	ld	s3,8(sp)
    80003b24:	6145                	addi	sp,sp,48
    80003b26:	8082                	ret
    80003b28:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b2a:	0009a503          	lw	a0,0(s3)
    80003b2e:	825ff0ef          	jal	80003352 <bread>
    80003b32:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b34:	05850493          	addi	s1,a0,88
    80003b38:	45850913          	addi	s2,a0,1112
    80003b3c:	a021                	j	80003b44 <itrunc+0x6c>
    80003b3e:	0491                	addi	s1,s1,4
    80003b40:	01248963          	beq	s1,s2,80003b52 <itrunc+0x7a>
      if(a[j])
    80003b44:	408c                	lw	a1,0(s1)
    80003b46:	dde5                	beqz	a1,80003b3e <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003b48:	0009a503          	lw	a0,0(s3)
    80003b4c:	9fbff0ef          	jal	80003546 <bfree>
    80003b50:	b7fd                	j	80003b3e <itrunc+0x66>
    brelse(bp);
    80003b52:	8552                	mv	a0,s4
    80003b54:	907ff0ef          	jal	8000345a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b58:	0809a583          	lw	a1,128(s3)
    80003b5c:	0009a503          	lw	a0,0(s3)
    80003b60:	9e7ff0ef          	jal	80003546 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b64:	0809a023          	sw	zero,128(s3)
    80003b68:	6a02                	ld	s4,0(sp)
    80003b6a:	b75d                	j	80003b10 <itrunc+0x38>

0000000080003b6c <iput>:
{
    80003b6c:	1101                	addi	sp,sp,-32
    80003b6e:	ec06                	sd	ra,24(sp)
    80003b70:	e822                	sd	s0,16(sp)
    80003b72:	e426                	sd	s1,8(sp)
    80003b74:	1000                	addi	s0,sp,32
    80003b76:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b78:	00061517          	auipc	a0,0x61
    80003b7c:	40850513          	addi	a0,a0,1032 # 80064f80 <itable>
    80003b80:	8a8fd0ef          	jal	80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b84:	4498                	lw	a4,8(s1)
    80003b86:	4785                	li	a5,1
    80003b88:	02f70063          	beq	a4,a5,80003ba8 <iput+0x3c>
  ip->ref--;
    80003b8c:	449c                	lw	a5,8(s1)
    80003b8e:	37fd                	addiw	a5,a5,-1
    80003b90:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b92:	00061517          	auipc	a0,0x61
    80003b96:	3ee50513          	addi	a0,a0,1006 # 80064f80 <itable>
    80003b9a:	922fd0ef          	jal	80000cbc <release>
}
    80003b9e:	60e2                	ld	ra,24(sp)
    80003ba0:	6442                	ld	s0,16(sp)
    80003ba2:	64a2                	ld	s1,8(sp)
    80003ba4:	6105                	addi	sp,sp,32
    80003ba6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ba8:	40bc                	lw	a5,64(s1)
    80003baa:	d3ed                	beqz	a5,80003b8c <iput+0x20>
    80003bac:	04a49783          	lh	a5,74(s1)
    80003bb0:	fff1                	bnez	a5,80003b8c <iput+0x20>
    80003bb2:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003bb4:	01048793          	addi	a5,s1,16
    80003bb8:	893e                	mv	s2,a5
    80003bba:	853e                	mv	a0,a5
    80003bbc:	2cf000ef          	jal	8000468a <acquiresleep>
    release(&itable.lock);
    80003bc0:	00061517          	auipc	a0,0x61
    80003bc4:	3c050513          	addi	a0,a0,960 # 80064f80 <itable>
    80003bc8:	8f4fd0ef          	jal	80000cbc <release>
    itrunc(ip);
    80003bcc:	8526                	mv	a0,s1
    80003bce:	f0bff0ef          	jal	80003ad8 <itrunc>
    ip->type = 0;
    80003bd2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003bd6:	8526                	mv	a0,s1
    80003bd8:	d5fff0ef          	jal	80003936 <iupdate>
    ip->valid = 0;
    80003bdc:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003be0:	854a                	mv	a0,s2
    80003be2:	2ef000ef          	jal	800046d0 <releasesleep>
    acquire(&itable.lock);
    80003be6:	00061517          	auipc	a0,0x61
    80003bea:	39a50513          	addi	a0,a0,922 # 80064f80 <itable>
    80003bee:	83afd0ef          	jal	80000c28 <acquire>
    80003bf2:	6902                	ld	s2,0(sp)
    80003bf4:	bf61                	j	80003b8c <iput+0x20>

0000000080003bf6 <iunlockput>:
{
    80003bf6:	1101                	addi	sp,sp,-32
    80003bf8:	ec06                	sd	ra,24(sp)
    80003bfa:	e822                	sd	s0,16(sp)
    80003bfc:	e426                	sd	s1,8(sp)
    80003bfe:	1000                	addi	s0,sp,32
    80003c00:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c02:	e97ff0ef          	jal	80003a98 <iunlock>
  iput(ip);
    80003c06:	8526                	mv	a0,s1
    80003c08:	f65ff0ef          	jal	80003b6c <iput>
}
    80003c0c:	60e2                	ld	ra,24(sp)
    80003c0e:	6442                	ld	s0,16(sp)
    80003c10:	64a2                	ld	s1,8(sp)
    80003c12:	6105                	addi	sp,sp,32
    80003c14:	8082                	ret

0000000080003c16 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003c16:	00061717          	auipc	a4,0x61
    80003c1a:	35672703          	lw	a4,854(a4) # 80064f6c <sb+0xc>
    80003c1e:	4785                	li	a5,1
    80003c20:	0ae7fe63          	bgeu	a5,a4,80003cdc <ireclaim+0xc6>
{
    80003c24:	7139                	addi	sp,sp,-64
    80003c26:	fc06                	sd	ra,56(sp)
    80003c28:	f822                	sd	s0,48(sp)
    80003c2a:	f426                	sd	s1,40(sp)
    80003c2c:	f04a                	sd	s2,32(sp)
    80003c2e:	ec4e                	sd	s3,24(sp)
    80003c30:	e852                	sd	s4,16(sp)
    80003c32:	e456                	sd	s5,8(sp)
    80003c34:	e05a                	sd	s6,0(sp)
    80003c36:	0080                	addi	s0,sp,64
    80003c38:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003c3a:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003c3c:	00061a17          	auipc	s4,0x61
    80003c40:	324a0a13          	addi	s4,s4,804 # 80064f60 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003c44:	00005b17          	auipc	s6,0x5
    80003c48:	854b0b13          	addi	s6,s6,-1964 # 80008498 <etext+0x498>
    80003c4c:	a099                	j	80003c92 <ireclaim+0x7c>
    80003c4e:	85ce                	mv	a1,s3
    80003c50:	855a                	mv	a0,s6
    80003c52:	8a9fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003c56:	85ce                	mv	a1,s3
    80003c58:	8556                	mv	a0,s5
    80003c5a:	b1fff0ef          	jal	80003778 <iget>
    80003c5e:	89aa                	mv	s3,a0
    brelse(bp);
    80003c60:	854a                	mv	a0,s2
    80003c62:	ff8ff0ef          	jal	8000345a <brelse>
    if (ip) {
    80003c66:	00098f63          	beqz	s3,80003c84 <ireclaim+0x6e>
      begin_op();
    80003c6a:	78c000ef          	jal	800043f6 <begin_op>
      ilock(ip);
    80003c6e:	854e                	mv	a0,s3
    80003c70:	d7bff0ef          	jal	800039ea <ilock>
      iunlock(ip);
    80003c74:	854e                	mv	a0,s3
    80003c76:	e23ff0ef          	jal	80003a98 <iunlock>
      iput(ip);
    80003c7a:	854e                	mv	a0,s3
    80003c7c:	ef1ff0ef          	jal	80003b6c <iput>
      end_op();
    80003c80:	7e6000ef          	jal	80004466 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003c84:	0485                	addi	s1,s1,1
    80003c86:	00ca2703          	lw	a4,12(s4)
    80003c8a:	0004879b          	sext.w	a5,s1
    80003c8e:	02e7fd63          	bgeu	a5,a4,80003cc8 <ireclaim+0xb2>
    80003c92:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003c96:	0044d593          	srli	a1,s1,0x4
    80003c9a:	018a2783          	lw	a5,24(s4)
    80003c9e:	9dbd                	addw	a1,a1,a5
    80003ca0:	8556                	mv	a0,s5
    80003ca2:	eb0ff0ef          	jal	80003352 <bread>
    80003ca6:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003ca8:	05850793          	addi	a5,a0,88
    80003cac:	00f9f713          	andi	a4,s3,15
    80003cb0:	071a                	slli	a4,a4,0x6
    80003cb2:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003cb4:	00079703          	lh	a4,0(a5)
    80003cb8:	c701                	beqz	a4,80003cc0 <ireclaim+0xaa>
    80003cba:	00679783          	lh	a5,6(a5)
    80003cbe:	dbc1                	beqz	a5,80003c4e <ireclaim+0x38>
    brelse(bp);
    80003cc0:	854a                	mv	a0,s2
    80003cc2:	f98ff0ef          	jal	8000345a <brelse>
    if (ip) {
    80003cc6:	bf7d                	j	80003c84 <ireclaim+0x6e>
}
    80003cc8:	70e2                	ld	ra,56(sp)
    80003cca:	7442                	ld	s0,48(sp)
    80003ccc:	74a2                	ld	s1,40(sp)
    80003cce:	7902                	ld	s2,32(sp)
    80003cd0:	69e2                	ld	s3,24(sp)
    80003cd2:	6a42                	ld	s4,16(sp)
    80003cd4:	6aa2                	ld	s5,8(sp)
    80003cd6:	6b02                	ld	s6,0(sp)
    80003cd8:	6121                	addi	sp,sp,64
    80003cda:	8082                	ret
    80003cdc:	8082                	ret

0000000080003cde <fsinit>:
fsinit(int dev) {
    80003cde:	1101                	addi	sp,sp,-32
    80003ce0:	ec06                	sd	ra,24(sp)
    80003ce2:	e822                	sd	s0,16(sp)
    80003ce4:	e426                	sd	s1,8(sp)
    80003ce6:	e04a                	sd	s2,0(sp)
    80003ce8:	1000                	addi	s0,sp,32
    80003cea:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003cec:	4585                	li	a1,1
    80003cee:	e64ff0ef          	jal	80003352 <bread>
    80003cf2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003cf4:	02000613          	li	a2,32
    80003cf8:	05850593          	addi	a1,a0,88
    80003cfc:	00061517          	auipc	a0,0x61
    80003d00:	26450513          	addi	a0,a0,612 # 80064f60 <sb>
    80003d04:	854fd0ef          	jal	80000d58 <memmove>
  brelse(bp);
    80003d08:	8526                	mv	a0,s1
    80003d0a:	f50ff0ef          	jal	8000345a <brelse>
  if(sb.magic != FSMAGIC)
    80003d0e:	00061717          	auipc	a4,0x61
    80003d12:	25272703          	lw	a4,594(a4) # 80064f60 <sb>
    80003d16:	102037b7          	lui	a5,0x10203
    80003d1a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003d1e:	02f71263          	bne	a4,a5,80003d42 <fsinit+0x64>
  initlog(dev, &sb);
    80003d22:	00061597          	auipc	a1,0x61
    80003d26:	23e58593          	addi	a1,a1,574 # 80064f60 <sb>
    80003d2a:	854a                	mv	a0,s2
    80003d2c:	648000ef          	jal	80004374 <initlog>
  ireclaim(dev);
    80003d30:	854a                	mv	a0,s2
    80003d32:	ee5ff0ef          	jal	80003c16 <ireclaim>
}
    80003d36:	60e2                	ld	ra,24(sp)
    80003d38:	6442                	ld	s0,16(sp)
    80003d3a:	64a2                	ld	s1,8(sp)
    80003d3c:	6902                	ld	s2,0(sp)
    80003d3e:	6105                	addi	sp,sp,32
    80003d40:	8082                	ret
    panic("invalid file system");
    80003d42:	00004517          	auipc	a0,0x4
    80003d46:	77650513          	addi	a0,a0,1910 # 800084b8 <etext+0x4b8>
    80003d4a:	adbfc0ef          	jal	80000824 <panic>

0000000080003d4e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003d4e:	1141                	addi	sp,sp,-16
    80003d50:	e406                	sd	ra,8(sp)
    80003d52:	e022                	sd	s0,0(sp)
    80003d54:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003d56:	411c                	lw	a5,0(a0)
    80003d58:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d5a:	415c                	lw	a5,4(a0)
    80003d5c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003d5e:	04451783          	lh	a5,68(a0)
    80003d62:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003d66:	04a51783          	lh	a5,74(a0)
    80003d6a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003d6e:	04c56783          	lwu	a5,76(a0)
    80003d72:	e99c                	sd	a5,16(a1)
}
    80003d74:	60a2                	ld	ra,8(sp)
    80003d76:	6402                	ld	s0,0(sp)
    80003d78:	0141                	addi	sp,sp,16
    80003d7a:	8082                	ret

0000000080003d7c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d7c:	457c                	lw	a5,76(a0)
    80003d7e:	0ed7e663          	bltu	a5,a3,80003e6a <readi+0xee>
{
    80003d82:	7159                	addi	sp,sp,-112
    80003d84:	f486                	sd	ra,104(sp)
    80003d86:	f0a2                	sd	s0,96(sp)
    80003d88:	eca6                	sd	s1,88(sp)
    80003d8a:	e0d2                	sd	s4,64(sp)
    80003d8c:	fc56                	sd	s5,56(sp)
    80003d8e:	f85a                	sd	s6,48(sp)
    80003d90:	f45e                	sd	s7,40(sp)
    80003d92:	1880                	addi	s0,sp,112
    80003d94:	8b2a                	mv	s6,a0
    80003d96:	8bae                	mv	s7,a1
    80003d98:	8a32                	mv	s4,a2
    80003d9a:	84b6                	mv	s1,a3
    80003d9c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003d9e:	9f35                	addw	a4,a4,a3
    return 0;
    80003da0:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003da2:	0ad76b63          	bltu	a4,a3,80003e58 <readi+0xdc>
    80003da6:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003da8:	00e7f463          	bgeu	a5,a4,80003db0 <readi+0x34>
    n = ip->size - off;
    80003dac:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003db0:	080a8b63          	beqz	s5,80003e46 <readi+0xca>
    80003db4:	e8ca                	sd	s2,80(sp)
    80003db6:	f062                	sd	s8,32(sp)
    80003db8:	ec66                	sd	s9,24(sp)
    80003dba:	e86a                	sd	s10,16(sp)
    80003dbc:	e46e                	sd	s11,8(sp)
    80003dbe:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dc0:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003dc4:	5c7d                	li	s8,-1
    80003dc6:	a80d                	j	80003df8 <readi+0x7c>
    80003dc8:	020d1d93          	slli	s11,s10,0x20
    80003dcc:	020ddd93          	srli	s11,s11,0x20
    80003dd0:	05890613          	addi	a2,s2,88
    80003dd4:	86ee                	mv	a3,s11
    80003dd6:	963e                	add	a2,a2,a5
    80003dd8:	85d2                	mv	a1,s4
    80003dda:	855e                	mv	a0,s7
    80003ddc:	e32fe0ef          	jal	8000240e <either_copyout>
    80003de0:	05850363          	beq	a0,s8,80003e26 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003de4:	854a                	mv	a0,s2
    80003de6:	e74ff0ef          	jal	8000345a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003dea:	013d09bb          	addw	s3,s10,s3
    80003dee:	009d04bb          	addw	s1,s10,s1
    80003df2:	9a6e                	add	s4,s4,s11
    80003df4:	0559f363          	bgeu	s3,s5,80003e3a <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003df8:	00a4d59b          	srliw	a1,s1,0xa
    80003dfc:	855a                	mv	a0,s6
    80003dfe:	8bbff0ef          	jal	800036b8 <bmap>
    80003e02:	85aa                	mv	a1,a0
    if(addr == 0)
    80003e04:	c139                	beqz	a0,80003e4a <readi+0xce>
    bp = bread(ip->dev, addr);
    80003e06:	000b2503          	lw	a0,0(s6)
    80003e0a:	d48ff0ef          	jal	80003352 <bread>
    80003e0e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e10:	3ff4f793          	andi	a5,s1,1023
    80003e14:	40fc873b          	subw	a4,s9,a5
    80003e18:	413a86bb          	subw	a3,s5,s3
    80003e1c:	8d3a                	mv	s10,a4
    80003e1e:	fae6f5e3          	bgeu	a3,a4,80003dc8 <readi+0x4c>
    80003e22:	8d36                	mv	s10,a3
    80003e24:	b755                	j	80003dc8 <readi+0x4c>
      brelse(bp);
    80003e26:	854a                	mv	a0,s2
    80003e28:	e32ff0ef          	jal	8000345a <brelse>
      tot = -1;
    80003e2c:	59fd                	li	s3,-1
      break;
    80003e2e:	6946                	ld	s2,80(sp)
    80003e30:	7c02                	ld	s8,32(sp)
    80003e32:	6ce2                	ld	s9,24(sp)
    80003e34:	6d42                	ld	s10,16(sp)
    80003e36:	6da2                	ld	s11,8(sp)
    80003e38:	a831                	j	80003e54 <readi+0xd8>
    80003e3a:	6946                	ld	s2,80(sp)
    80003e3c:	7c02                	ld	s8,32(sp)
    80003e3e:	6ce2                	ld	s9,24(sp)
    80003e40:	6d42                	ld	s10,16(sp)
    80003e42:	6da2                	ld	s11,8(sp)
    80003e44:	a801                	j	80003e54 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e46:	89d6                	mv	s3,s5
    80003e48:	a031                	j	80003e54 <readi+0xd8>
    80003e4a:	6946                	ld	s2,80(sp)
    80003e4c:	7c02                	ld	s8,32(sp)
    80003e4e:	6ce2                	ld	s9,24(sp)
    80003e50:	6d42                	ld	s10,16(sp)
    80003e52:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003e54:	854e                	mv	a0,s3
    80003e56:	69a6                	ld	s3,72(sp)
}
    80003e58:	70a6                	ld	ra,104(sp)
    80003e5a:	7406                	ld	s0,96(sp)
    80003e5c:	64e6                	ld	s1,88(sp)
    80003e5e:	6a06                	ld	s4,64(sp)
    80003e60:	7ae2                	ld	s5,56(sp)
    80003e62:	7b42                	ld	s6,48(sp)
    80003e64:	7ba2                	ld	s7,40(sp)
    80003e66:	6165                	addi	sp,sp,112
    80003e68:	8082                	ret
    return 0;
    80003e6a:	4501                	li	a0,0
}
    80003e6c:	8082                	ret

0000000080003e6e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e6e:	457c                	lw	a5,76(a0)
    80003e70:	0ed7eb63          	bltu	a5,a3,80003f66 <writei+0xf8>
{
    80003e74:	7159                	addi	sp,sp,-112
    80003e76:	f486                	sd	ra,104(sp)
    80003e78:	f0a2                	sd	s0,96(sp)
    80003e7a:	e8ca                	sd	s2,80(sp)
    80003e7c:	e0d2                	sd	s4,64(sp)
    80003e7e:	fc56                	sd	s5,56(sp)
    80003e80:	f85a                	sd	s6,48(sp)
    80003e82:	f45e                	sd	s7,40(sp)
    80003e84:	1880                	addi	s0,sp,112
    80003e86:	8aaa                	mv	s5,a0
    80003e88:	8bae                	mv	s7,a1
    80003e8a:	8a32                	mv	s4,a2
    80003e8c:	8936                	mv	s2,a3
    80003e8e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003e90:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003e94:	00043737          	lui	a4,0x43
    80003e98:	0cf76963          	bltu	a4,a5,80003f6a <writei+0xfc>
    80003e9c:	0cd7e763          	bltu	a5,a3,80003f6a <writei+0xfc>
    80003ea0:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ea2:	0a0b0a63          	beqz	s6,80003f56 <writei+0xe8>
    80003ea6:	eca6                	sd	s1,88(sp)
    80003ea8:	f062                	sd	s8,32(sp)
    80003eaa:	ec66                	sd	s9,24(sp)
    80003eac:	e86a                	sd	s10,16(sp)
    80003eae:	e46e                	sd	s11,8(sp)
    80003eb0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003eb2:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003eb6:	5c7d                	li	s8,-1
    80003eb8:	a825                	j	80003ef0 <writei+0x82>
    80003eba:	020d1d93          	slli	s11,s10,0x20
    80003ebe:	020ddd93          	srli	s11,s11,0x20
    80003ec2:	05848513          	addi	a0,s1,88
    80003ec6:	86ee                	mv	a3,s11
    80003ec8:	8652                	mv	a2,s4
    80003eca:	85de                	mv	a1,s7
    80003ecc:	953e                	add	a0,a0,a5
    80003ece:	d8afe0ef          	jal	80002458 <either_copyin>
    80003ed2:	05850663          	beq	a0,s8,80003f1e <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ed6:	8526                	mv	a0,s1
    80003ed8:	6b8000ef          	jal	80004590 <log_write>
    brelse(bp);
    80003edc:	8526                	mv	a0,s1
    80003ede:	d7cff0ef          	jal	8000345a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ee2:	013d09bb          	addw	s3,s10,s3
    80003ee6:	012d093b          	addw	s2,s10,s2
    80003eea:	9a6e                	add	s4,s4,s11
    80003eec:	0369fc63          	bgeu	s3,s6,80003f24 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003ef0:	00a9559b          	srliw	a1,s2,0xa
    80003ef4:	8556                	mv	a0,s5
    80003ef6:	fc2ff0ef          	jal	800036b8 <bmap>
    80003efa:	85aa                	mv	a1,a0
    if(addr == 0)
    80003efc:	c505                	beqz	a0,80003f24 <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003efe:	000aa503          	lw	a0,0(s5)
    80003f02:	c50ff0ef          	jal	80003352 <bread>
    80003f06:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f08:	3ff97793          	andi	a5,s2,1023
    80003f0c:	40fc873b          	subw	a4,s9,a5
    80003f10:	413b06bb          	subw	a3,s6,s3
    80003f14:	8d3a                	mv	s10,a4
    80003f16:	fae6f2e3          	bgeu	a3,a4,80003eba <writei+0x4c>
    80003f1a:	8d36                	mv	s10,a3
    80003f1c:	bf79                	j	80003eba <writei+0x4c>
      brelse(bp);
    80003f1e:	8526                	mv	a0,s1
    80003f20:	d3aff0ef          	jal	8000345a <brelse>
  }

  if(off > ip->size)
    80003f24:	04caa783          	lw	a5,76(s5)
    80003f28:	0327f963          	bgeu	a5,s2,80003f5a <writei+0xec>
    ip->size = off;
    80003f2c:	052aa623          	sw	s2,76(s5)
    80003f30:	64e6                	ld	s1,88(sp)
    80003f32:	7c02                	ld	s8,32(sp)
    80003f34:	6ce2                	ld	s9,24(sp)
    80003f36:	6d42                	ld	s10,16(sp)
    80003f38:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003f3a:	8556                	mv	a0,s5
    80003f3c:	9fbff0ef          	jal	80003936 <iupdate>

  return tot;
    80003f40:	854e                	mv	a0,s3
    80003f42:	69a6                	ld	s3,72(sp)
}
    80003f44:	70a6                	ld	ra,104(sp)
    80003f46:	7406                	ld	s0,96(sp)
    80003f48:	6946                	ld	s2,80(sp)
    80003f4a:	6a06                	ld	s4,64(sp)
    80003f4c:	7ae2                	ld	s5,56(sp)
    80003f4e:	7b42                	ld	s6,48(sp)
    80003f50:	7ba2                	ld	s7,40(sp)
    80003f52:	6165                	addi	sp,sp,112
    80003f54:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f56:	89da                	mv	s3,s6
    80003f58:	b7cd                	j	80003f3a <writei+0xcc>
    80003f5a:	64e6                	ld	s1,88(sp)
    80003f5c:	7c02                	ld	s8,32(sp)
    80003f5e:	6ce2                	ld	s9,24(sp)
    80003f60:	6d42                	ld	s10,16(sp)
    80003f62:	6da2                	ld	s11,8(sp)
    80003f64:	bfd9                	j	80003f3a <writei+0xcc>
    return -1;
    80003f66:	557d                	li	a0,-1
}
    80003f68:	8082                	ret
    return -1;
    80003f6a:	557d                	li	a0,-1
    80003f6c:	bfe1                	j	80003f44 <writei+0xd6>

0000000080003f6e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003f6e:	1141                	addi	sp,sp,-16
    80003f70:	e406                	sd	ra,8(sp)
    80003f72:	e022                	sd	s0,0(sp)
    80003f74:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003f76:	4639                	li	a2,14
    80003f78:	e55fc0ef          	jal	80000dcc <strncmp>
}
    80003f7c:	60a2                	ld	ra,8(sp)
    80003f7e:	6402                	ld	s0,0(sp)
    80003f80:	0141                	addi	sp,sp,16
    80003f82:	8082                	ret

0000000080003f84 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003f84:	711d                	addi	sp,sp,-96
    80003f86:	ec86                	sd	ra,88(sp)
    80003f88:	e8a2                	sd	s0,80(sp)
    80003f8a:	e4a6                	sd	s1,72(sp)
    80003f8c:	e0ca                	sd	s2,64(sp)
    80003f8e:	fc4e                	sd	s3,56(sp)
    80003f90:	f852                	sd	s4,48(sp)
    80003f92:	f456                	sd	s5,40(sp)
    80003f94:	f05a                	sd	s6,32(sp)
    80003f96:	ec5e                	sd	s7,24(sp)
    80003f98:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003f9a:	04451703          	lh	a4,68(a0)
    80003f9e:	4785                	li	a5,1
    80003fa0:	00f71f63          	bne	a4,a5,80003fbe <dirlookup+0x3a>
    80003fa4:	892a                	mv	s2,a0
    80003fa6:	8aae                	mv	s5,a1
    80003fa8:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003faa:	457c                	lw	a5,76(a0)
    80003fac:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fae:	fa040a13          	addi	s4,s0,-96
    80003fb2:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003fb4:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003fb8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fba:	e39d                	bnez	a5,80003fe0 <dirlookup+0x5c>
    80003fbc:	a8b9                	j	8000401a <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003fbe:	00004517          	auipc	a0,0x4
    80003fc2:	51250513          	addi	a0,a0,1298 # 800084d0 <etext+0x4d0>
    80003fc6:	85ffc0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    80003fca:	00004517          	auipc	a0,0x4
    80003fce:	51e50513          	addi	a0,a0,1310 # 800084e8 <etext+0x4e8>
    80003fd2:	853fc0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fd6:	24c1                	addiw	s1,s1,16
    80003fd8:	04c92783          	lw	a5,76(s2)
    80003fdc:	02f4fe63          	bgeu	s1,a5,80004018 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fe0:	874e                	mv	a4,s3
    80003fe2:	86a6                	mv	a3,s1
    80003fe4:	8652                	mv	a2,s4
    80003fe6:	4581                	li	a1,0
    80003fe8:	854a                	mv	a0,s2
    80003fea:	d93ff0ef          	jal	80003d7c <readi>
    80003fee:	fd351ee3          	bne	a0,s3,80003fca <dirlookup+0x46>
    if(de.inum == 0)
    80003ff2:	fa045783          	lhu	a5,-96(s0)
    80003ff6:	d3e5                	beqz	a5,80003fd6 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003ff8:	85da                	mv	a1,s6
    80003ffa:	8556                	mv	a0,s5
    80003ffc:	f73ff0ef          	jal	80003f6e <namecmp>
    80004000:	f979                	bnez	a0,80003fd6 <dirlookup+0x52>
      if(poff)
    80004002:	000b8463          	beqz	s7,8000400a <dirlookup+0x86>
        *poff = off;
    80004006:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    8000400a:	fa045583          	lhu	a1,-96(s0)
    8000400e:	00092503          	lw	a0,0(s2)
    80004012:	f66ff0ef          	jal	80003778 <iget>
    80004016:	a011                	j	8000401a <dirlookup+0x96>
  return 0;
    80004018:	4501                	li	a0,0
}
    8000401a:	60e6                	ld	ra,88(sp)
    8000401c:	6446                	ld	s0,80(sp)
    8000401e:	64a6                	ld	s1,72(sp)
    80004020:	6906                	ld	s2,64(sp)
    80004022:	79e2                	ld	s3,56(sp)
    80004024:	7a42                	ld	s4,48(sp)
    80004026:	7aa2                	ld	s5,40(sp)
    80004028:	7b02                	ld	s6,32(sp)
    8000402a:	6be2                	ld	s7,24(sp)
    8000402c:	6125                	addi	sp,sp,96
    8000402e:	8082                	ret

0000000080004030 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004030:	711d                	addi	sp,sp,-96
    80004032:	ec86                	sd	ra,88(sp)
    80004034:	e8a2                	sd	s0,80(sp)
    80004036:	e4a6                	sd	s1,72(sp)
    80004038:	e0ca                	sd	s2,64(sp)
    8000403a:	fc4e                	sd	s3,56(sp)
    8000403c:	f852                	sd	s4,48(sp)
    8000403e:	f456                	sd	s5,40(sp)
    80004040:	f05a                	sd	s6,32(sp)
    80004042:	ec5e                	sd	s7,24(sp)
    80004044:	e862                	sd	s8,16(sp)
    80004046:	e466                	sd	s9,8(sp)
    80004048:	e06a                	sd	s10,0(sp)
    8000404a:	1080                	addi	s0,sp,96
    8000404c:	84aa                	mv	s1,a0
    8000404e:	8b2e                	mv	s6,a1
    80004050:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004052:	00054703          	lbu	a4,0(a0)
    80004056:	02f00793          	li	a5,47
    8000405a:	00f70f63          	beq	a4,a5,80004078 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000405e:	92dfd0ef          	jal	8000198a <myproc>
    80004062:	15853503          	ld	a0,344(a0)
    80004066:	94fff0ef          	jal	800039b4 <idup>
    8000406a:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000406c:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80004070:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80004072:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004074:	4b85                	li	s7,1
    80004076:	a879                	j	80004114 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80004078:	4585                	li	a1,1
    8000407a:	852e                	mv	a0,a1
    8000407c:	efcff0ef          	jal	80003778 <iget>
    80004080:	8a2a                	mv	s4,a0
    80004082:	b7ed                	j	8000406c <namex+0x3c>
      iunlockput(ip);
    80004084:	8552                	mv	a0,s4
    80004086:	b71ff0ef          	jal	80003bf6 <iunlockput>
      return 0;
    8000408a:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000408c:	8552                	mv	a0,s4
    8000408e:	60e6                	ld	ra,88(sp)
    80004090:	6446                	ld	s0,80(sp)
    80004092:	64a6                	ld	s1,72(sp)
    80004094:	6906                	ld	s2,64(sp)
    80004096:	79e2                	ld	s3,56(sp)
    80004098:	7a42                	ld	s4,48(sp)
    8000409a:	7aa2                	ld	s5,40(sp)
    8000409c:	7b02                	ld	s6,32(sp)
    8000409e:	6be2                	ld	s7,24(sp)
    800040a0:	6c42                	ld	s8,16(sp)
    800040a2:	6ca2                	ld	s9,8(sp)
    800040a4:	6d02                	ld	s10,0(sp)
    800040a6:	6125                	addi	sp,sp,96
    800040a8:	8082                	ret
      iunlock(ip);
    800040aa:	8552                	mv	a0,s4
    800040ac:	9edff0ef          	jal	80003a98 <iunlock>
      return ip;
    800040b0:	bff1                	j	8000408c <namex+0x5c>
      iunlockput(ip);
    800040b2:	8552                	mv	a0,s4
    800040b4:	b43ff0ef          	jal	80003bf6 <iunlockput>
      return 0;
    800040b8:	8a4a                	mv	s4,s2
    800040ba:	bfc9                	j	8000408c <namex+0x5c>
  len = path - s;
    800040bc:	40990633          	sub	a2,s2,s1
    800040c0:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800040c4:	09ac5463          	bge	s8,s10,8000414c <namex+0x11c>
    memmove(name, s, DIRSIZ);
    800040c8:	8666                	mv	a2,s9
    800040ca:	85a6                	mv	a1,s1
    800040cc:	8556                	mv	a0,s5
    800040ce:	c8bfc0ef          	jal	80000d58 <memmove>
    800040d2:	84ca                	mv	s1,s2
  while(*path == '/')
    800040d4:	0004c783          	lbu	a5,0(s1)
    800040d8:	01379763          	bne	a5,s3,800040e6 <namex+0xb6>
    path++;
    800040dc:	0485                	addi	s1,s1,1
  while(*path == '/')
    800040de:	0004c783          	lbu	a5,0(s1)
    800040e2:	ff378de3          	beq	a5,s3,800040dc <namex+0xac>
    ilock(ip);
    800040e6:	8552                	mv	a0,s4
    800040e8:	903ff0ef          	jal	800039ea <ilock>
    if(ip->type != T_DIR){
    800040ec:	044a1783          	lh	a5,68(s4)
    800040f0:	f9779ae3          	bne	a5,s7,80004084 <namex+0x54>
    if(nameiparent && *path == '\0'){
    800040f4:	000b0563          	beqz	s6,800040fe <namex+0xce>
    800040f8:	0004c783          	lbu	a5,0(s1)
    800040fc:	d7dd                	beqz	a5,800040aa <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800040fe:	4601                	li	a2,0
    80004100:	85d6                	mv	a1,s5
    80004102:	8552                	mv	a0,s4
    80004104:	e81ff0ef          	jal	80003f84 <dirlookup>
    80004108:	892a                	mv	s2,a0
    8000410a:	d545                	beqz	a0,800040b2 <namex+0x82>
    iunlockput(ip);
    8000410c:	8552                	mv	a0,s4
    8000410e:	ae9ff0ef          	jal	80003bf6 <iunlockput>
    ip = next;
    80004112:	8a4a                	mv	s4,s2
  while(*path == '/')
    80004114:	0004c783          	lbu	a5,0(s1)
    80004118:	01379763          	bne	a5,s3,80004126 <namex+0xf6>
    path++;
    8000411c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000411e:	0004c783          	lbu	a5,0(s1)
    80004122:	ff378de3          	beq	a5,s3,8000411c <namex+0xec>
  if(*path == 0)
    80004126:	cf8d                	beqz	a5,80004160 <namex+0x130>
  while(*path != '/' && *path != 0)
    80004128:	0004c783          	lbu	a5,0(s1)
    8000412c:	fd178713          	addi	a4,a5,-47
    80004130:	cb19                	beqz	a4,80004146 <namex+0x116>
    80004132:	cb91                	beqz	a5,80004146 <namex+0x116>
    80004134:	8926                	mv	s2,s1
    path++;
    80004136:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80004138:	00094783          	lbu	a5,0(s2)
    8000413c:	fd178713          	addi	a4,a5,-47
    80004140:	df35                	beqz	a4,800040bc <namex+0x8c>
    80004142:	fbf5                	bnez	a5,80004136 <namex+0x106>
    80004144:	bfa5                	j	800040bc <namex+0x8c>
    80004146:	8926                	mv	s2,s1
  len = path - s;
    80004148:	4d01                	li	s10,0
    8000414a:	4601                	li	a2,0
    memmove(name, s, len);
    8000414c:	2601                	sext.w	a2,a2
    8000414e:	85a6                	mv	a1,s1
    80004150:	8556                	mv	a0,s5
    80004152:	c07fc0ef          	jal	80000d58 <memmove>
    name[len] = 0;
    80004156:	9d56                	add	s10,s10,s5
    80004158:	000d0023          	sb	zero,0(s10)
    8000415c:	84ca                	mv	s1,s2
    8000415e:	bf9d                	j	800040d4 <namex+0xa4>
  if(nameiparent){
    80004160:	f20b06e3          	beqz	s6,8000408c <namex+0x5c>
    iput(ip);
    80004164:	8552                	mv	a0,s4
    80004166:	a07ff0ef          	jal	80003b6c <iput>
    return 0;
    8000416a:	4a01                	li	s4,0
    8000416c:	b705                	j	8000408c <namex+0x5c>

000000008000416e <dirlink>:
{
    8000416e:	715d                	addi	sp,sp,-80
    80004170:	e486                	sd	ra,72(sp)
    80004172:	e0a2                	sd	s0,64(sp)
    80004174:	f84a                	sd	s2,48(sp)
    80004176:	ec56                	sd	s5,24(sp)
    80004178:	e85a                	sd	s6,16(sp)
    8000417a:	0880                	addi	s0,sp,80
    8000417c:	892a                	mv	s2,a0
    8000417e:	8aae                	mv	s5,a1
    80004180:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004182:	4601                	li	a2,0
    80004184:	e01ff0ef          	jal	80003f84 <dirlookup>
    80004188:	ed1d                	bnez	a0,800041c6 <dirlink+0x58>
    8000418a:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000418c:	04c92483          	lw	s1,76(s2)
    80004190:	c4b9                	beqz	s1,800041de <dirlink+0x70>
    80004192:	f44e                	sd	s3,40(sp)
    80004194:	f052                	sd	s4,32(sp)
    80004196:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004198:	fb040a13          	addi	s4,s0,-80
    8000419c:	49c1                	li	s3,16
    8000419e:	874e                	mv	a4,s3
    800041a0:	86a6                	mv	a3,s1
    800041a2:	8652                	mv	a2,s4
    800041a4:	4581                	li	a1,0
    800041a6:	854a                	mv	a0,s2
    800041a8:	bd5ff0ef          	jal	80003d7c <readi>
    800041ac:	03351163          	bne	a0,s3,800041ce <dirlink+0x60>
    if(de.inum == 0)
    800041b0:	fb045783          	lhu	a5,-80(s0)
    800041b4:	c39d                	beqz	a5,800041da <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041b6:	24c1                	addiw	s1,s1,16
    800041b8:	04c92783          	lw	a5,76(s2)
    800041bc:	fef4e1e3          	bltu	s1,a5,8000419e <dirlink+0x30>
    800041c0:	79a2                	ld	s3,40(sp)
    800041c2:	7a02                	ld	s4,32(sp)
    800041c4:	a829                	j	800041de <dirlink+0x70>
    iput(ip);
    800041c6:	9a7ff0ef          	jal	80003b6c <iput>
    return -1;
    800041ca:	557d                	li	a0,-1
    800041cc:	a83d                	j	8000420a <dirlink+0x9c>
      panic("dirlink read");
    800041ce:	00004517          	auipc	a0,0x4
    800041d2:	32a50513          	addi	a0,a0,810 # 800084f8 <etext+0x4f8>
    800041d6:	e4efc0ef          	jal	80000824 <panic>
    800041da:	79a2                	ld	s3,40(sp)
    800041dc:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    800041de:	4639                	li	a2,14
    800041e0:	85d6                	mv	a1,s5
    800041e2:	fb240513          	addi	a0,s0,-78
    800041e6:	c21fc0ef          	jal	80000e06 <strncpy>
  de.inum = inum;
    800041ea:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041ee:	4741                	li	a4,16
    800041f0:	86a6                	mv	a3,s1
    800041f2:	fb040613          	addi	a2,s0,-80
    800041f6:	4581                	li	a1,0
    800041f8:	854a                	mv	a0,s2
    800041fa:	c75ff0ef          	jal	80003e6e <writei>
    800041fe:	1541                	addi	a0,a0,-16
    80004200:	00a03533          	snez	a0,a0
    80004204:	40a0053b          	negw	a0,a0
    80004208:	74e2                	ld	s1,56(sp)
}
    8000420a:	60a6                	ld	ra,72(sp)
    8000420c:	6406                	ld	s0,64(sp)
    8000420e:	7942                	ld	s2,48(sp)
    80004210:	6ae2                	ld	s5,24(sp)
    80004212:	6b42                	ld	s6,16(sp)
    80004214:	6161                	addi	sp,sp,80
    80004216:	8082                	ret

0000000080004218 <namei>:

struct inode*
namei(char *path)
{
    80004218:	1101                	addi	sp,sp,-32
    8000421a:	ec06                	sd	ra,24(sp)
    8000421c:	e822                	sd	s0,16(sp)
    8000421e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004220:	fe040613          	addi	a2,s0,-32
    80004224:	4581                	li	a1,0
    80004226:	e0bff0ef          	jal	80004030 <namex>
}
    8000422a:	60e2                	ld	ra,24(sp)
    8000422c:	6442                	ld	s0,16(sp)
    8000422e:	6105                	addi	sp,sp,32
    80004230:	8082                	ret

0000000080004232 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004232:	1141                	addi	sp,sp,-16
    80004234:	e406                	sd	ra,8(sp)
    80004236:	e022                	sd	s0,0(sp)
    80004238:	0800                	addi	s0,sp,16
    8000423a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000423c:	4585                	li	a1,1
    8000423e:	df3ff0ef          	jal	80004030 <namex>
}
    80004242:	60a2                	ld	ra,8(sp)
    80004244:	6402                	ld	s0,0(sp)
    80004246:	0141                	addi	sp,sp,16
    80004248:	8082                	ret

000000008000424a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000424a:	1101                	addi	sp,sp,-32
    8000424c:	ec06                	sd	ra,24(sp)
    8000424e:	e822                	sd	s0,16(sp)
    80004250:	e426                	sd	s1,8(sp)
    80004252:	e04a                	sd	s2,0(sp)
    80004254:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004256:	00062917          	auipc	s2,0x62
    8000425a:	7d290913          	addi	s2,s2,2002 # 80066a28 <log>
    8000425e:	01892583          	lw	a1,24(s2)
    80004262:	02492503          	lw	a0,36(s2)
    80004266:	8ecff0ef          	jal	80003352 <bread>
    8000426a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000426c:	02892603          	lw	a2,40(s2)
    80004270:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004272:	00c05f63          	blez	a2,80004290 <write_head+0x46>
    80004276:	00062717          	auipc	a4,0x62
    8000427a:	7de70713          	addi	a4,a4,2014 # 80066a54 <log+0x2c>
    8000427e:	87aa                	mv	a5,a0
    80004280:	060a                	slli	a2,a2,0x2
    80004282:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004284:	4314                	lw	a3,0(a4)
    80004286:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004288:	0711                	addi	a4,a4,4
    8000428a:	0791                	addi	a5,a5,4
    8000428c:	fec79ce3          	bne	a5,a2,80004284 <write_head+0x3a>
  }
  bwrite(buf);
    80004290:	8526                	mv	a0,s1
    80004292:	996ff0ef          	jal	80003428 <bwrite>
  brelse(buf);
    80004296:	8526                	mv	a0,s1
    80004298:	9c2ff0ef          	jal	8000345a <brelse>
}
    8000429c:	60e2                	ld	ra,24(sp)
    8000429e:	6442                	ld	s0,16(sp)
    800042a0:	64a2                	ld	s1,8(sp)
    800042a2:	6902                	ld	s2,0(sp)
    800042a4:	6105                	addi	sp,sp,32
    800042a6:	8082                	ret

00000000800042a8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800042a8:	00062797          	auipc	a5,0x62
    800042ac:	7a87a783          	lw	a5,1960(a5) # 80066a50 <log+0x28>
    800042b0:	0cf05163          	blez	a5,80004372 <install_trans+0xca>
{
    800042b4:	715d                	addi	sp,sp,-80
    800042b6:	e486                	sd	ra,72(sp)
    800042b8:	e0a2                	sd	s0,64(sp)
    800042ba:	fc26                	sd	s1,56(sp)
    800042bc:	f84a                	sd	s2,48(sp)
    800042be:	f44e                	sd	s3,40(sp)
    800042c0:	f052                	sd	s4,32(sp)
    800042c2:	ec56                	sd	s5,24(sp)
    800042c4:	e85a                	sd	s6,16(sp)
    800042c6:	e45e                	sd	s7,8(sp)
    800042c8:	e062                	sd	s8,0(sp)
    800042ca:	0880                	addi	s0,sp,80
    800042cc:	8b2a                	mv	s6,a0
    800042ce:	00062a97          	auipc	s5,0x62
    800042d2:	786a8a93          	addi	s5,s5,1926 # 80066a54 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042d6:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800042d8:	00004c17          	auipc	s8,0x4
    800042dc:	230c0c13          	addi	s8,s8,560 # 80008508 <etext+0x508>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800042e0:	00062a17          	auipc	s4,0x62
    800042e4:	748a0a13          	addi	s4,s4,1864 # 80066a28 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800042e8:	40000b93          	li	s7,1024
    800042ec:	a025                	j	80004314 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800042ee:	000aa603          	lw	a2,0(s5)
    800042f2:	85ce                	mv	a1,s3
    800042f4:	8562                	mv	a0,s8
    800042f6:	a04fc0ef          	jal	800004fa <printf>
    800042fa:	a839                	j	80004318 <install_trans+0x70>
    brelse(lbuf);
    800042fc:	854a                	mv	a0,s2
    800042fe:	95cff0ef          	jal	8000345a <brelse>
    brelse(dbuf);
    80004302:	8526                	mv	a0,s1
    80004304:	956ff0ef          	jal	8000345a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004308:	2985                	addiw	s3,s3,1
    8000430a:	0a91                	addi	s5,s5,4
    8000430c:	028a2783          	lw	a5,40(s4)
    80004310:	04f9d563          	bge	s3,a5,8000435a <install_trans+0xb2>
    if(recovering) {
    80004314:	fc0b1de3          	bnez	s6,800042ee <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004318:	018a2583          	lw	a1,24(s4)
    8000431c:	013585bb          	addw	a1,a1,s3
    80004320:	2585                	addiw	a1,a1,1
    80004322:	024a2503          	lw	a0,36(s4)
    80004326:	82cff0ef          	jal	80003352 <bread>
    8000432a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000432c:	000aa583          	lw	a1,0(s5)
    80004330:	024a2503          	lw	a0,36(s4)
    80004334:	81eff0ef          	jal	80003352 <bread>
    80004338:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000433a:	865e                	mv	a2,s7
    8000433c:	05890593          	addi	a1,s2,88
    80004340:	05850513          	addi	a0,a0,88
    80004344:	a15fc0ef          	jal	80000d58 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004348:	8526                	mv	a0,s1
    8000434a:	8deff0ef          	jal	80003428 <bwrite>
    if(recovering == 0)
    8000434e:	fa0b17e3          	bnez	s6,800042fc <install_trans+0x54>
      bunpin(dbuf);
    80004352:	8526                	mv	a0,s1
    80004354:	9beff0ef          	jal	80003512 <bunpin>
    80004358:	b755                	j	800042fc <install_trans+0x54>
}
    8000435a:	60a6                	ld	ra,72(sp)
    8000435c:	6406                	ld	s0,64(sp)
    8000435e:	74e2                	ld	s1,56(sp)
    80004360:	7942                	ld	s2,48(sp)
    80004362:	79a2                	ld	s3,40(sp)
    80004364:	7a02                	ld	s4,32(sp)
    80004366:	6ae2                	ld	s5,24(sp)
    80004368:	6b42                	ld	s6,16(sp)
    8000436a:	6ba2                	ld	s7,8(sp)
    8000436c:	6c02                	ld	s8,0(sp)
    8000436e:	6161                	addi	sp,sp,80
    80004370:	8082                	ret
    80004372:	8082                	ret

0000000080004374 <initlog>:
{
    80004374:	7179                	addi	sp,sp,-48
    80004376:	f406                	sd	ra,40(sp)
    80004378:	f022                	sd	s0,32(sp)
    8000437a:	ec26                	sd	s1,24(sp)
    8000437c:	e84a                	sd	s2,16(sp)
    8000437e:	e44e                	sd	s3,8(sp)
    80004380:	1800                	addi	s0,sp,48
    80004382:	84aa                	mv	s1,a0
    80004384:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004386:	00062917          	auipc	s2,0x62
    8000438a:	6a290913          	addi	s2,s2,1698 # 80066a28 <log>
    8000438e:	00004597          	auipc	a1,0x4
    80004392:	19a58593          	addi	a1,a1,410 # 80008528 <etext+0x528>
    80004396:	854a                	mv	a0,s2
    80004398:	807fc0ef          	jal	80000b9e <initlock>
  log.start = sb->logstart;
    8000439c:	0149a583          	lw	a1,20(s3)
    800043a0:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    800043a4:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    800043a8:	8526                	mv	a0,s1
    800043aa:	fa9fe0ef          	jal	80003352 <bread>
  log.lh.n = lh->n;
    800043ae:	4d30                	lw	a2,88(a0)
    800043b0:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    800043b4:	00c05f63          	blez	a2,800043d2 <initlog+0x5e>
    800043b8:	87aa                	mv	a5,a0
    800043ba:	00062717          	auipc	a4,0x62
    800043be:	69a70713          	addi	a4,a4,1690 # 80066a54 <log+0x2c>
    800043c2:	060a                	slli	a2,a2,0x2
    800043c4:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800043c6:	4ff4                	lw	a3,92(a5)
    800043c8:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800043ca:	0791                	addi	a5,a5,4
    800043cc:	0711                	addi	a4,a4,4
    800043ce:	fec79ce3          	bne	a5,a2,800043c6 <initlog+0x52>
  brelse(buf);
    800043d2:	888ff0ef          	jal	8000345a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800043d6:	4505                	li	a0,1
    800043d8:	ed1ff0ef          	jal	800042a8 <install_trans>
  log.lh.n = 0;
    800043dc:	00062797          	auipc	a5,0x62
    800043e0:	6607aa23          	sw	zero,1652(a5) # 80066a50 <log+0x28>
  write_head(); // clear the log
    800043e4:	e67ff0ef          	jal	8000424a <write_head>
}
    800043e8:	70a2                	ld	ra,40(sp)
    800043ea:	7402                	ld	s0,32(sp)
    800043ec:	64e2                	ld	s1,24(sp)
    800043ee:	6942                	ld	s2,16(sp)
    800043f0:	69a2                	ld	s3,8(sp)
    800043f2:	6145                	addi	sp,sp,48
    800043f4:	8082                	ret

00000000800043f6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800043f6:	1101                	addi	sp,sp,-32
    800043f8:	ec06                	sd	ra,24(sp)
    800043fa:	e822                	sd	s0,16(sp)
    800043fc:	e426                	sd	s1,8(sp)
    800043fe:	e04a                	sd	s2,0(sp)
    80004400:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004402:	00062517          	auipc	a0,0x62
    80004406:	62650513          	addi	a0,a0,1574 # 80066a28 <log>
    8000440a:	81ffc0ef          	jal	80000c28 <acquire>
  while(1){
    if(log.committing){
    8000440e:	00062497          	auipc	s1,0x62
    80004412:	61a48493          	addi	s1,s1,1562 # 80066a28 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004416:	4979                	li	s2,30
    80004418:	a029                	j	80004422 <begin_op+0x2c>
      sleep(&log, &log.lock);
    8000441a:	85a6                	mv	a1,s1
    8000441c:	8526                	mv	a0,s1
    8000441e:	c7dfd0ef          	jal	8000209a <sleep>
    if(log.committing){
    80004422:	509c                	lw	a5,32(s1)
    80004424:	fbfd                	bnez	a5,8000441a <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004426:	4cd8                	lw	a4,28(s1)
    80004428:	2705                	addiw	a4,a4,1
    8000442a:	0027179b          	slliw	a5,a4,0x2
    8000442e:	9fb9                	addw	a5,a5,a4
    80004430:	0017979b          	slliw	a5,a5,0x1
    80004434:	5494                	lw	a3,40(s1)
    80004436:	9fb5                	addw	a5,a5,a3
    80004438:	00f95763          	bge	s2,a5,80004446 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000443c:	85a6                	mv	a1,s1
    8000443e:	8526                	mv	a0,s1
    80004440:	c5bfd0ef          	jal	8000209a <sleep>
    80004444:	bff9                	j	80004422 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80004446:	00062797          	auipc	a5,0x62
    8000444a:	5ee7af23          	sw	a4,1534(a5) # 80066a44 <log+0x1c>
      release(&log.lock);
    8000444e:	00062517          	auipc	a0,0x62
    80004452:	5da50513          	addi	a0,a0,1498 # 80066a28 <log>
    80004456:	867fc0ef          	jal	80000cbc <release>
      break;
    }
  }
}
    8000445a:	60e2                	ld	ra,24(sp)
    8000445c:	6442                	ld	s0,16(sp)
    8000445e:	64a2                	ld	s1,8(sp)
    80004460:	6902                	ld	s2,0(sp)
    80004462:	6105                	addi	sp,sp,32
    80004464:	8082                	ret

0000000080004466 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004466:	7139                	addi	sp,sp,-64
    80004468:	fc06                	sd	ra,56(sp)
    8000446a:	f822                	sd	s0,48(sp)
    8000446c:	f426                	sd	s1,40(sp)
    8000446e:	f04a                	sd	s2,32(sp)
    80004470:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004472:	00062497          	auipc	s1,0x62
    80004476:	5b648493          	addi	s1,s1,1462 # 80066a28 <log>
    8000447a:	8526                	mv	a0,s1
    8000447c:	facfc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80004480:	4cdc                	lw	a5,28(s1)
    80004482:	37fd                	addiw	a5,a5,-1
    80004484:	893e                	mv	s2,a5
    80004486:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80004488:	509c                	lw	a5,32(s1)
    8000448a:	e7b1                	bnez	a5,800044d6 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    8000448c:	04091e63          	bnez	s2,800044e8 <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    80004490:	00062497          	auipc	s1,0x62
    80004494:	59848493          	addi	s1,s1,1432 # 80066a28 <log>
    80004498:	4785                	li	a5,1
    8000449a:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000449c:	8526                	mv	a0,s1
    8000449e:	81ffc0ef          	jal	80000cbc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800044a2:	549c                	lw	a5,40(s1)
    800044a4:	06f04463          	bgtz	a5,8000450c <end_op+0xa6>
    acquire(&log.lock);
    800044a8:	00062517          	auipc	a0,0x62
    800044ac:	58050513          	addi	a0,a0,1408 # 80066a28 <log>
    800044b0:	f78fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    800044b4:	00062797          	auipc	a5,0x62
    800044b8:	5807aa23          	sw	zero,1428(a5) # 80066a48 <log+0x20>
    wakeup(&log);
    800044bc:	00062517          	auipc	a0,0x62
    800044c0:	56c50513          	addi	a0,a0,1388 # 80066a28 <log>
    800044c4:	c23fd0ef          	jal	800020e6 <wakeup>
    release(&log.lock);
    800044c8:	00062517          	auipc	a0,0x62
    800044cc:	56050513          	addi	a0,a0,1376 # 80066a28 <log>
    800044d0:	fecfc0ef          	jal	80000cbc <release>
}
    800044d4:	a035                	j	80004500 <end_op+0x9a>
    800044d6:	ec4e                	sd	s3,24(sp)
    800044d8:	e852                	sd	s4,16(sp)
    800044da:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800044dc:	00004517          	auipc	a0,0x4
    800044e0:	05450513          	addi	a0,a0,84 # 80008530 <etext+0x530>
    800044e4:	b40fc0ef          	jal	80000824 <panic>
    wakeup(&log);
    800044e8:	00062517          	auipc	a0,0x62
    800044ec:	54050513          	addi	a0,a0,1344 # 80066a28 <log>
    800044f0:	bf7fd0ef          	jal	800020e6 <wakeup>
  release(&log.lock);
    800044f4:	00062517          	auipc	a0,0x62
    800044f8:	53450513          	addi	a0,a0,1332 # 80066a28 <log>
    800044fc:	fc0fc0ef          	jal	80000cbc <release>
}
    80004500:	70e2                	ld	ra,56(sp)
    80004502:	7442                	ld	s0,48(sp)
    80004504:	74a2                	ld	s1,40(sp)
    80004506:	7902                	ld	s2,32(sp)
    80004508:	6121                	addi	sp,sp,64
    8000450a:	8082                	ret
    8000450c:	ec4e                	sd	s3,24(sp)
    8000450e:	e852                	sd	s4,16(sp)
    80004510:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004512:	00062a97          	auipc	s5,0x62
    80004516:	542a8a93          	addi	s5,s5,1346 # 80066a54 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000451a:	00062a17          	auipc	s4,0x62
    8000451e:	50ea0a13          	addi	s4,s4,1294 # 80066a28 <log>
    80004522:	018a2583          	lw	a1,24(s4)
    80004526:	012585bb          	addw	a1,a1,s2
    8000452a:	2585                	addiw	a1,a1,1
    8000452c:	024a2503          	lw	a0,36(s4)
    80004530:	e23fe0ef          	jal	80003352 <bread>
    80004534:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004536:	000aa583          	lw	a1,0(s5)
    8000453a:	024a2503          	lw	a0,36(s4)
    8000453e:	e15fe0ef          	jal	80003352 <bread>
    80004542:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004544:	40000613          	li	a2,1024
    80004548:	05850593          	addi	a1,a0,88
    8000454c:	05848513          	addi	a0,s1,88
    80004550:	809fc0ef          	jal	80000d58 <memmove>
    bwrite(to);  // write the log
    80004554:	8526                	mv	a0,s1
    80004556:	ed3fe0ef          	jal	80003428 <bwrite>
    brelse(from);
    8000455a:	854e                	mv	a0,s3
    8000455c:	efffe0ef          	jal	8000345a <brelse>
    brelse(to);
    80004560:	8526                	mv	a0,s1
    80004562:	ef9fe0ef          	jal	8000345a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004566:	2905                	addiw	s2,s2,1
    80004568:	0a91                	addi	s5,s5,4
    8000456a:	028a2783          	lw	a5,40(s4)
    8000456e:	faf94ae3          	blt	s2,a5,80004522 <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004572:	cd9ff0ef          	jal	8000424a <write_head>
    install_trans(0); // Now install writes to home locations
    80004576:	4501                	li	a0,0
    80004578:	d31ff0ef          	jal	800042a8 <install_trans>
    log.lh.n = 0;
    8000457c:	00062797          	auipc	a5,0x62
    80004580:	4c07aa23          	sw	zero,1236(a5) # 80066a50 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004584:	cc7ff0ef          	jal	8000424a <write_head>
    80004588:	69e2                	ld	s3,24(sp)
    8000458a:	6a42                	ld	s4,16(sp)
    8000458c:	6aa2                	ld	s5,8(sp)
    8000458e:	bf29                	j	800044a8 <end_op+0x42>

0000000080004590 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004590:	1101                	addi	sp,sp,-32
    80004592:	ec06                	sd	ra,24(sp)
    80004594:	e822                	sd	s0,16(sp)
    80004596:	e426                	sd	s1,8(sp)
    80004598:	1000                	addi	s0,sp,32
    8000459a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000459c:	00062517          	auipc	a0,0x62
    800045a0:	48c50513          	addi	a0,a0,1164 # 80066a28 <log>
    800045a4:	e84fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800045a8:	00062617          	auipc	a2,0x62
    800045ac:	4a862603          	lw	a2,1192(a2) # 80066a50 <log+0x28>
    800045b0:	47f5                	li	a5,29
    800045b2:	04c7cd63          	blt	a5,a2,8000460c <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800045b6:	00062797          	auipc	a5,0x62
    800045ba:	48e7a783          	lw	a5,1166(a5) # 80066a44 <log+0x1c>
    800045be:	04f05d63          	blez	a5,80004618 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800045c2:	4781                	li	a5,0
    800045c4:	06c05063          	blez	a2,80004624 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045c8:	44cc                	lw	a1,12(s1)
    800045ca:	00062717          	auipc	a4,0x62
    800045ce:	48a70713          	addi	a4,a4,1162 # 80066a54 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    800045d2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045d4:	4314                	lw	a3,0(a4)
    800045d6:	04b68763          	beq	a3,a1,80004624 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    800045da:	2785                	addiw	a5,a5,1
    800045dc:	0711                	addi	a4,a4,4
    800045de:	fef61be3          	bne	a2,a5,800045d4 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    800045e2:	060a                	slli	a2,a2,0x2
    800045e4:	02060613          	addi	a2,a2,32
    800045e8:	00062797          	auipc	a5,0x62
    800045ec:	44078793          	addi	a5,a5,1088 # 80066a28 <log>
    800045f0:	97b2                	add	a5,a5,a2
    800045f2:	44d8                	lw	a4,12(s1)
    800045f4:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800045f6:	8526                	mv	a0,s1
    800045f8:	ee7fe0ef          	jal	800034de <bpin>
    log.lh.n++;
    800045fc:	00062717          	auipc	a4,0x62
    80004600:	42c70713          	addi	a4,a4,1068 # 80066a28 <log>
    80004604:	571c                	lw	a5,40(a4)
    80004606:	2785                	addiw	a5,a5,1
    80004608:	d71c                	sw	a5,40(a4)
    8000460a:	a815                	j	8000463e <log_write+0xae>
    panic("too big a transaction");
    8000460c:	00004517          	auipc	a0,0x4
    80004610:	f3450513          	addi	a0,a0,-204 # 80008540 <etext+0x540>
    80004614:	a10fc0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    80004618:	00004517          	auipc	a0,0x4
    8000461c:	f4050513          	addi	a0,a0,-192 # 80008558 <etext+0x558>
    80004620:	a04fc0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    80004624:	00279693          	slli	a3,a5,0x2
    80004628:	02068693          	addi	a3,a3,32
    8000462c:	00062717          	auipc	a4,0x62
    80004630:	3fc70713          	addi	a4,a4,1020 # 80066a28 <log>
    80004634:	9736                	add	a4,a4,a3
    80004636:	44d4                	lw	a3,12(s1)
    80004638:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000463a:	faf60ee3          	beq	a2,a5,800045f6 <log_write+0x66>
  }
  release(&log.lock);
    8000463e:	00062517          	auipc	a0,0x62
    80004642:	3ea50513          	addi	a0,a0,1002 # 80066a28 <log>
    80004646:	e76fc0ef          	jal	80000cbc <release>
}
    8000464a:	60e2                	ld	ra,24(sp)
    8000464c:	6442                	ld	s0,16(sp)
    8000464e:	64a2                	ld	s1,8(sp)
    80004650:	6105                	addi	sp,sp,32
    80004652:	8082                	ret

0000000080004654 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004654:	1101                	addi	sp,sp,-32
    80004656:	ec06                	sd	ra,24(sp)
    80004658:	e822                	sd	s0,16(sp)
    8000465a:	e426                	sd	s1,8(sp)
    8000465c:	e04a                	sd	s2,0(sp)
    8000465e:	1000                	addi	s0,sp,32
    80004660:	84aa                	mv	s1,a0
    80004662:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004664:	00004597          	auipc	a1,0x4
    80004668:	f1458593          	addi	a1,a1,-236 # 80008578 <etext+0x578>
    8000466c:	0521                	addi	a0,a0,8
    8000466e:	d30fc0ef          	jal	80000b9e <initlock>
  lk->name = name;
    80004672:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004676:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000467a:	0204a423          	sw	zero,40(s1)
}
    8000467e:	60e2                	ld	ra,24(sp)
    80004680:	6442                	ld	s0,16(sp)
    80004682:	64a2                	ld	s1,8(sp)
    80004684:	6902                	ld	s2,0(sp)
    80004686:	6105                	addi	sp,sp,32
    80004688:	8082                	ret

000000008000468a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000468a:	1101                	addi	sp,sp,-32
    8000468c:	ec06                	sd	ra,24(sp)
    8000468e:	e822                	sd	s0,16(sp)
    80004690:	e426                	sd	s1,8(sp)
    80004692:	e04a                	sd	s2,0(sp)
    80004694:	1000                	addi	s0,sp,32
    80004696:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004698:	00850913          	addi	s2,a0,8
    8000469c:	854a                	mv	a0,s2
    8000469e:	d8afc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    800046a2:	409c                	lw	a5,0(s1)
    800046a4:	c799                	beqz	a5,800046b2 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800046a6:	85ca                	mv	a1,s2
    800046a8:	8526                	mv	a0,s1
    800046aa:	9f1fd0ef          	jal	8000209a <sleep>
  while (lk->locked) {
    800046ae:	409c                	lw	a5,0(s1)
    800046b0:	fbfd                	bnez	a5,800046a6 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800046b2:	4785                	li	a5,1
    800046b4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800046b6:	ad4fd0ef          	jal	8000198a <myproc>
    800046ba:	591c                	lw	a5,48(a0)
    800046bc:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800046be:	854a                	mv	a0,s2
    800046c0:	dfcfc0ef          	jal	80000cbc <release>
}
    800046c4:	60e2                	ld	ra,24(sp)
    800046c6:	6442                	ld	s0,16(sp)
    800046c8:	64a2                	ld	s1,8(sp)
    800046ca:	6902                	ld	s2,0(sp)
    800046cc:	6105                	addi	sp,sp,32
    800046ce:	8082                	ret

00000000800046d0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800046d0:	1101                	addi	sp,sp,-32
    800046d2:	ec06                	sd	ra,24(sp)
    800046d4:	e822                	sd	s0,16(sp)
    800046d6:	e426                	sd	s1,8(sp)
    800046d8:	e04a                	sd	s2,0(sp)
    800046da:	1000                	addi	s0,sp,32
    800046dc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046de:	00850913          	addi	s2,a0,8
    800046e2:	854a                	mv	a0,s2
    800046e4:	d44fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    800046e8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046ec:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800046f0:	8526                	mv	a0,s1
    800046f2:	9f5fd0ef          	jal	800020e6 <wakeup>
  release(&lk->lk);
    800046f6:	854a                	mv	a0,s2
    800046f8:	dc4fc0ef          	jal	80000cbc <release>
}
    800046fc:	60e2                	ld	ra,24(sp)
    800046fe:	6442                	ld	s0,16(sp)
    80004700:	64a2                	ld	s1,8(sp)
    80004702:	6902                	ld	s2,0(sp)
    80004704:	6105                	addi	sp,sp,32
    80004706:	8082                	ret

0000000080004708 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004708:	7179                	addi	sp,sp,-48
    8000470a:	f406                	sd	ra,40(sp)
    8000470c:	f022                	sd	s0,32(sp)
    8000470e:	ec26                	sd	s1,24(sp)
    80004710:	e84a                	sd	s2,16(sp)
    80004712:	1800                	addi	s0,sp,48
    80004714:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004716:	00850913          	addi	s2,a0,8
    8000471a:	854a                	mv	a0,s2
    8000471c:	d0cfc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004720:	409c                	lw	a5,0(s1)
    80004722:	ef81                	bnez	a5,8000473a <holdingsleep+0x32>
    80004724:	4481                	li	s1,0
  release(&lk->lk);
    80004726:	854a                	mv	a0,s2
    80004728:	d94fc0ef          	jal	80000cbc <release>
  return r;
}
    8000472c:	8526                	mv	a0,s1
    8000472e:	70a2                	ld	ra,40(sp)
    80004730:	7402                	ld	s0,32(sp)
    80004732:	64e2                	ld	s1,24(sp)
    80004734:	6942                	ld	s2,16(sp)
    80004736:	6145                	addi	sp,sp,48
    80004738:	8082                	ret
    8000473a:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000473c:	0284a983          	lw	s3,40(s1)
    80004740:	a4afd0ef          	jal	8000198a <myproc>
    80004744:	5904                	lw	s1,48(a0)
    80004746:	413484b3          	sub	s1,s1,s3
    8000474a:	0014b493          	seqz	s1,s1
    8000474e:	69a2                	ld	s3,8(sp)
    80004750:	bfd9                	j	80004726 <holdingsleep+0x1e>

0000000080004752 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004752:	1141                	addi	sp,sp,-16
    80004754:	e406                	sd	ra,8(sp)
    80004756:	e022                	sd	s0,0(sp)
    80004758:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000475a:	00004597          	auipc	a1,0x4
    8000475e:	e2e58593          	addi	a1,a1,-466 # 80008588 <etext+0x588>
    80004762:	00062517          	auipc	a0,0x62
    80004766:	40e50513          	addi	a0,a0,1038 # 80066b70 <ftable>
    8000476a:	c34fc0ef          	jal	80000b9e <initlock>
}
    8000476e:	60a2                	ld	ra,8(sp)
    80004770:	6402                	ld	s0,0(sp)
    80004772:	0141                	addi	sp,sp,16
    80004774:	8082                	ret

0000000080004776 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004776:	1101                	addi	sp,sp,-32
    80004778:	ec06                	sd	ra,24(sp)
    8000477a:	e822                	sd	s0,16(sp)
    8000477c:	e426                	sd	s1,8(sp)
    8000477e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004780:	00062517          	auipc	a0,0x62
    80004784:	3f050513          	addi	a0,a0,1008 # 80066b70 <ftable>
    80004788:	ca0fc0ef          	jal	80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000478c:	00062497          	auipc	s1,0x62
    80004790:	3fc48493          	addi	s1,s1,1020 # 80066b88 <ftable+0x18>
    80004794:	00063717          	auipc	a4,0x63
    80004798:	39470713          	addi	a4,a4,916 # 80067b28 <disk>
    if(f->ref == 0){
    8000479c:	40dc                	lw	a5,4(s1)
    8000479e:	cf89                	beqz	a5,800047b8 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047a0:	02848493          	addi	s1,s1,40
    800047a4:	fee49ce3          	bne	s1,a4,8000479c <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800047a8:	00062517          	auipc	a0,0x62
    800047ac:	3c850513          	addi	a0,a0,968 # 80066b70 <ftable>
    800047b0:	d0cfc0ef          	jal	80000cbc <release>
  return 0;
    800047b4:	4481                	li	s1,0
    800047b6:	a809                	j	800047c8 <filealloc+0x52>
      f->ref = 1;
    800047b8:	4785                	li	a5,1
    800047ba:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800047bc:	00062517          	auipc	a0,0x62
    800047c0:	3b450513          	addi	a0,a0,948 # 80066b70 <ftable>
    800047c4:	cf8fc0ef          	jal	80000cbc <release>
}
    800047c8:	8526                	mv	a0,s1
    800047ca:	60e2                	ld	ra,24(sp)
    800047cc:	6442                	ld	s0,16(sp)
    800047ce:	64a2                	ld	s1,8(sp)
    800047d0:	6105                	addi	sp,sp,32
    800047d2:	8082                	ret

00000000800047d4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800047d4:	1101                	addi	sp,sp,-32
    800047d6:	ec06                	sd	ra,24(sp)
    800047d8:	e822                	sd	s0,16(sp)
    800047da:	e426                	sd	s1,8(sp)
    800047dc:	1000                	addi	s0,sp,32
    800047de:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800047e0:	00062517          	auipc	a0,0x62
    800047e4:	39050513          	addi	a0,a0,912 # 80066b70 <ftable>
    800047e8:	c40fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    800047ec:	40dc                	lw	a5,4(s1)
    800047ee:	02f05063          	blez	a5,8000480e <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800047f2:	2785                	addiw	a5,a5,1
    800047f4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800047f6:	00062517          	auipc	a0,0x62
    800047fa:	37a50513          	addi	a0,a0,890 # 80066b70 <ftable>
    800047fe:	cbefc0ef          	jal	80000cbc <release>
  return f;
}
    80004802:	8526                	mv	a0,s1
    80004804:	60e2                	ld	ra,24(sp)
    80004806:	6442                	ld	s0,16(sp)
    80004808:	64a2                	ld	s1,8(sp)
    8000480a:	6105                	addi	sp,sp,32
    8000480c:	8082                	ret
    panic("filedup");
    8000480e:	00004517          	auipc	a0,0x4
    80004812:	d8250513          	addi	a0,a0,-638 # 80008590 <etext+0x590>
    80004816:	80efc0ef          	jal	80000824 <panic>

000000008000481a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000481a:	7139                	addi	sp,sp,-64
    8000481c:	fc06                	sd	ra,56(sp)
    8000481e:	f822                	sd	s0,48(sp)
    80004820:	f426                	sd	s1,40(sp)
    80004822:	0080                	addi	s0,sp,64
    80004824:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004826:	00062517          	auipc	a0,0x62
    8000482a:	34a50513          	addi	a0,a0,842 # 80066b70 <ftable>
    8000482e:	bfafc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    80004832:	40dc                	lw	a5,4(s1)
    80004834:	04f05a63          	blez	a5,80004888 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004838:	37fd                	addiw	a5,a5,-1
    8000483a:	c0dc                	sw	a5,4(s1)
    8000483c:	06f04063          	bgtz	a5,8000489c <fileclose+0x82>
    80004840:	f04a                	sd	s2,32(sp)
    80004842:	ec4e                	sd	s3,24(sp)
    80004844:	e852                	sd	s4,16(sp)
    80004846:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004848:	0004a903          	lw	s2,0(s1)
    8000484c:	0094c783          	lbu	a5,9(s1)
    80004850:	89be                	mv	s3,a5
    80004852:	689c                	ld	a5,16(s1)
    80004854:	8a3e                	mv	s4,a5
    80004856:	6c9c                	ld	a5,24(s1)
    80004858:	8abe                	mv	s5,a5
  f->ref = 0;
    8000485a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000485e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004862:	00062517          	auipc	a0,0x62
    80004866:	30e50513          	addi	a0,a0,782 # 80066b70 <ftable>
    8000486a:	c52fc0ef          	jal	80000cbc <release>

  if(ff.type == FD_PIPE){
    8000486e:	4785                	li	a5,1
    80004870:	04f90163          	beq	s2,a5,800048b2 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004874:	ffe9079b          	addiw	a5,s2,-2
    80004878:	4705                	li	a4,1
    8000487a:	04f77563          	bgeu	a4,a5,800048c4 <fileclose+0xaa>
    8000487e:	7902                	ld	s2,32(sp)
    80004880:	69e2                	ld	s3,24(sp)
    80004882:	6a42                	ld	s4,16(sp)
    80004884:	6aa2                	ld	s5,8(sp)
    80004886:	a00d                	j	800048a8 <fileclose+0x8e>
    80004888:	f04a                	sd	s2,32(sp)
    8000488a:	ec4e                	sd	s3,24(sp)
    8000488c:	e852                	sd	s4,16(sp)
    8000488e:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004890:	00004517          	auipc	a0,0x4
    80004894:	d0850513          	addi	a0,a0,-760 # 80008598 <etext+0x598>
    80004898:	f8dfb0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    8000489c:	00062517          	auipc	a0,0x62
    800048a0:	2d450513          	addi	a0,a0,724 # 80066b70 <ftable>
    800048a4:	c18fc0ef          	jal	80000cbc <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800048a8:	70e2                	ld	ra,56(sp)
    800048aa:	7442                	ld	s0,48(sp)
    800048ac:	74a2                	ld	s1,40(sp)
    800048ae:	6121                	addi	sp,sp,64
    800048b0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800048b2:	85ce                	mv	a1,s3
    800048b4:	8552                	mv	a0,s4
    800048b6:	348000ef          	jal	80004bfe <pipeclose>
    800048ba:	7902                	ld	s2,32(sp)
    800048bc:	69e2                	ld	s3,24(sp)
    800048be:	6a42                	ld	s4,16(sp)
    800048c0:	6aa2                	ld	s5,8(sp)
    800048c2:	b7dd                	j	800048a8 <fileclose+0x8e>
    begin_op();
    800048c4:	b33ff0ef          	jal	800043f6 <begin_op>
    iput(ff.ip);
    800048c8:	8556                	mv	a0,s5
    800048ca:	aa2ff0ef          	jal	80003b6c <iput>
    end_op();
    800048ce:	b99ff0ef          	jal	80004466 <end_op>
    800048d2:	7902                	ld	s2,32(sp)
    800048d4:	69e2                	ld	s3,24(sp)
    800048d6:	6a42                	ld	s4,16(sp)
    800048d8:	6aa2                	ld	s5,8(sp)
    800048da:	b7f9                	j	800048a8 <fileclose+0x8e>

00000000800048dc <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800048dc:	715d                	addi	sp,sp,-80
    800048de:	e486                	sd	ra,72(sp)
    800048e0:	e0a2                	sd	s0,64(sp)
    800048e2:	fc26                	sd	s1,56(sp)
    800048e4:	f052                	sd	s4,32(sp)
    800048e6:	0880                	addi	s0,sp,80
    800048e8:	84aa                	mv	s1,a0
    800048ea:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    800048ec:	89efd0ef          	jal	8000198a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800048f0:	409c                	lw	a5,0(s1)
    800048f2:	37f9                	addiw	a5,a5,-2
    800048f4:	4705                	li	a4,1
    800048f6:	04f76263          	bltu	a4,a5,8000493a <filestat+0x5e>
    800048fa:	f84a                	sd	s2,48(sp)
    800048fc:	f44e                	sd	s3,40(sp)
    800048fe:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004900:	6c88                	ld	a0,24(s1)
    80004902:	8e8ff0ef          	jal	800039ea <ilock>
    stati(f->ip, &st);
    80004906:	fb840913          	addi	s2,s0,-72
    8000490a:	85ca                	mv	a1,s2
    8000490c:	6c88                	ld	a0,24(s1)
    8000490e:	c40ff0ef          	jal	80003d4e <stati>
    iunlock(f->ip);
    80004912:	6c88                	ld	a0,24(s1)
    80004914:	984ff0ef          	jal	80003a98 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004918:	46e1                	li	a3,24
    8000491a:	864a                	mv	a2,s2
    8000491c:	85d2                	mv	a1,s4
    8000491e:	0589b503          	ld	a0,88(s3)
    80004922:	d33fc0ef          	jal	80001654 <copyout>
    80004926:	41f5551b          	sraiw	a0,a0,0x1f
    8000492a:	7942                	ld	s2,48(sp)
    8000492c:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000492e:	60a6                	ld	ra,72(sp)
    80004930:	6406                	ld	s0,64(sp)
    80004932:	74e2                	ld	s1,56(sp)
    80004934:	7a02                	ld	s4,32(sp)
    80004936:	6161                	addi	sp,sp,80
    80004938:	8082                	ret
  return -1;
    8000493a:	557d                	li	a0,-1
    8000493c:	bfcd                	j	8000492e <filestat+0x52>

000000008000493e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000493e:	7179                	addi	sp,sp,-48
    80004940:	f406                	sd	ra,40(sp)
    80004942:	f022                	sd	s0,32(sp)
    80004944:	e84a                	sd	s2,16(sp)
    80004946:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004948:	00854783          	lbu	a5,8(a0)
    8000494c:	cfd1                	beqz	a5,800049e8 <fileread+0xaa>
    8000494e:	ec26                	sd	s1,24(sp)
    80004950:	e44e                	sd	s3,8(sp)
    80004952:	84aa                	mv	s1,a0
    80004954:	892e                	mv	s2,a1
    80004956:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    80004958:	411c                	lw	a5,0(a0)
    8000495a:	4705                	li	a4,1
    8000495c:	04e78363          	beq	a5,a4,800049a2 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004960:	470d                	li	a4,3
    80004962:	04e78763          	beq	a5,a4,800049b0 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004966:	4709                	li	a4,2
    80004968:	06e79a63          	bne	a5,a4,800049dc <fileread+0x9e>
    ilock(f->ip);
    8000496c:	6d08                	ld	a0,24(a0)
    8000496e:	87cff0ef          	jal	800039ea <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004972:	874e                	mv	a4,s3
    80004974:	5094                	lw	a3,32(s1)
    80004976:	864a                	mv	a2,s2
    80004978:	4585                	li	a1,1
    8000497a:	6c88                	ld	a0,24(s1)
    8000497c:	c00ff0ef          	jal	80003d7c <readi>
    80004980:	892a                	mv	s2,a0
    80004982:	00a05563          	blez	a0,8000498c <fileread+0x4e>
      f->off += r;
    80004986:	509c                	lw	a5,32(s1)
    80004988:	9fa9                	addw	a5,a5,a0
    8000498a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000498c:	6c88                	ld	a0,24(s1)
    8000498e:	90aff0ef          	jal	80003a98 <iunlock>
    80004992:	64e2                	ld	s1,24(sp)
    80004994:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004996:	854a                	mv	a0,s2
    80004998:	70a2                	ld	ra,40(sp)
    8000499a:	7402                	ld	s0,32(sp)
    8000499c:	6942                	ld	s2,16(sp)
    8000499e:	6145                	addi	sp,sp,48
    800049a0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800049a2:	6908                	ld	a0,16(a0)
    800049a4:	3b0000ef          	jal	80004d54 <piperead>
    800049a8:	892a                	mv	s2,a0
    800049aa:	64e2                	ld	s1,24(sp)
    800049ac:	69a2                	ld	s3,8(sp)
    800049ae:	b7e5                	j	80004996 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800049b0:	02451783          	lh	a5,36(a0)
    800049b4:	03079693          	slli	a3,a5,0x30
    800049b8:	92c1                	srli	a3,a3,0x30
    800049ba:	4725                	li	a4,9
    800049bc:	02d76963          	bltu	a4,a3,800049ee <fileread+0xb0>
    800049c0:	0792                	slli	a5,a5,0x4
    800049c2:	00062717          	auipc	a4,0x62
    800049c6:	10e70713          	addi	a4,a4,270 # 80066ad0 <devsw>
    800049ca:	97ba                	add	a5,a5,a4
    800049cc:	639c                	ld	a5,0(a5)
    800049ce:	c78d                	beqz	a5,800049f8 <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    800049d0:	4505                	li	a0,1
    800049d2:	9782                	jalr	a5
    800049d4:	892a                	mv	s2,a0
    800049d6:	64e2                	ld	s1,24(sp)
    800049d8:	69a2                	ld	s3,8(sp)
    800049da:	bf75                	j	80004996 <fileread+0x58>
    panic("fileread");
    800049dc:	00004517          	auipc	a0,0x4
    800049e0:	bcc50513          	addi	a0,a0,-1076 # 800085a8 <etext+0x5a8>
    800049e4:	e41fb0ef          	jal	80000824 <panic>
    return -1;
    800049e8:	57fd                	li	a5,-1
    800049ea:	893e                	mv	s2,a5
    800049ec:	b76d                	j	80004996 <fileread+0x58>
      return -1;
    800049ee:	57fd                	li	a5,-1
    800049f0:	893e                	mv	s2,a5
    800049f2:	64e2                	ld	s1,24(sp)
    800049f4:	69a2                	ld	s3,8(sp)
    800049f6:	b745                	j	80004996 <fileread+0x58>
    800049f8:	57fd                	li	a5,-1
    800049fa:	893e                	mv	s2,a5
    800049fc:	64e2                	ld	s1,24(sp)
    800049fe:	69a2                	ld	s3,8(sp)
    80004a00:	bf59                	j	80004996 <fileread+0x58>

0000000080004a02 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004a02:	00954783          	lbu	a5,9(a0)
    80004a06:	10078f63          	beqz	a5,80004b24 <filewrite+0x122>
{
    80004a0a:	711d                	addi	sp,sp,-96
    80004a0c:	ec86                	sd	ra,88(sp)
    80004a0e:	e8a2                	sd	s0,80(sp)
    80004a10:	e0ca                	sd	s2,64(sp)
    80004a12:	f456                	sd	s5,40(sp)
    80004a14:	f05a                	sd	s6,32(sp)
    80004a16:	1080                	addi	s0,sp,96
    80004a18:	892a                	mv	s2,a0
    80004a1a:	8b2e                	mv	s6,a1
    80004a1c:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a1e:	411c                	lw	a5,0(a0)
    80004a20:	4705                	li	a4,1
    80004a22:	02e78a63          	beq	a5,a4,80004a56 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a26:	470d                	li	a4,3
    80004a28:	02e78b63          	beq	a5,a4,80004a5e <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a2c:	4709                	li	a4,2
    80004a2e:	0ce79f63          	bne	a5,a4,80004b0c <filewrite+0x10a>
    80004a32:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a34:	0ac05a63          	blez	a2,80004ae8 <filewrite+0xe6>
    80004a38:	e4a6                	sd	s1,72(sp)
    80004a3a:	fc4e                	sd	s3,56(sp)
    80004a3c:	ec5e                	sd	s7,24(sp)
    80004a3e:	e862                	sd	s8,16(sp)
    80004a40:	e466                	sd	s9,8(sp)
    int i = 0;
    80004a42:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004a44:	6b85                	lui	s7,0x1
    80004a46:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004a4a:	6785                	lui	a5,0x1
    80004a4c:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004a50:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a52:	4c05                	li	s8,1
    80004a54:	a8ad                	j	80004ace <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004a56:	6908                	ld	a0,16(a0)
    80004a58:	204000ef          	jal	80004c5c <pipewrite>
    80004a5c:	a04d                	j	80004afe <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a5e:	02451783          	lh	a5,36(a0)
    80004a62:	03079693          	slli	a3,a5,0x30
    80004a66:	92c1                	srli	a3,a3,0x30
    80004a68:	4725                	li	a4,9
    80004a6a:	0ad76f63          	bltu	a4,a3,80004b28 <filewrite+0x126>
    80004a6e:	0792                	slli	a5,a5,0x4
    80004a70:	00062717          	auipc	a4,0x62
    80004a74:	06070713          	addi	a4,a4,96 # 80066ad0 <devsw>
    80004a78:	97ba                	add	a5,a5,a4
    80004a7a:	679c                	ld	a5,8(a5)
    80004a7c:	cbc5                	beqz	a5,80004b2c <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    80004a7e:	4505                	li	a0,1
    80004a80:	9782                	jalr	a5
    80004a82:	a8b5                	j	80004afe <filewrite+0xfc>
      if(n1 > max)
    80004a84:	2981                	sext.w	s3,s3
      begin_op();
    80004a86:	971ff0ef          	jal	800043f6 <begin_op>
      ilock(f->ip);
    80004a8a:	01893503          	ld	a0,24(s2)
    80004a8e:	f5dfe0ef          	jal	800039ea <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a92:	874e                	mv	a4,s3
    80004a94:	02092683          	lw	a3,32(s2)
    80004a98:	016a0633          	add	a2,s4,s6
    80004a9c:	85e2                	mv	a1,s8
    80004a9e:	01893503          	ld	a0,24(s2)
    80004aa2:	bccff0ef          	jal	80003e6e <writei>
    80004aa6:	84aa                	mv	s1,a0
    80004aa8:	00a05763          	blez	a0,80004ab6 <filewrite+0xb4>
        f->off += r;
    80004aac:	02092783          	lw	a5,32(s2)
    80004ab0:	9fa9                	addw	a5,a5,a0
    80004ab2:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004ab6:	01893503          	ld	a0,24(s2)
    80004aba:	fdffe0ef          	jal	80003a98 <iunlock>
      end_op();
    80004abe:	9a9ff0ef          	jal	80004466 <end_op>

      if(r != n1){
    80004ac2:	02999563          	bne	s3,s1,80004aec <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    80004ac6:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004aca:	015a5963          	bge	s4,s5,80004adc <filewrite+0xda>
      int n1 = n - i;
    80004ace:	414a87bb          	subw	a5,s5,s4
    80004ad2:	89be                	mv	s3,a5
      if(n1 > max)
    80004ad4:	fafbd8e3          	bge	s7,a5,80004a84 <filewrite+0x82>
    80004ad8:	89e6                	mv	s3,s9
    80004ada:	b76d                	j	80004a84 <filewrite+0x82>
    80004adc:	64a6                	ld	s1,72(sp)
    80004ade:	79e2                	ld	s3,56(sp)
    80004ae0:	6be2                	ld	s7,24(sp)
    80004ae2:	6c42                	ld	s8,16(sp)
    80004ae4:	6ca2                	ld	s9,8(sp)
    80004ae6:	a801                	j	80004af6 <filewrite+0xf4>
    int i = 0;
    80004ae8:	4a01                	li	s4,0
    80004aea:	a031                	j	80004af6 <filewrite+0xf4>
    80004aec:	64a6                	ld	s1,72(sp)
    80004aee:	79e2                	ld	s3,56(sp)
    80004af0:	6be2                	ld	s7,24(sp)
    80004af2:	6c42                	ld	s8,16(sp)
    80004af4:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004af6:	034a9d63          	bne	s5,s4,80004b30 <filewrite+0x12e>
    80004afa:	8556                	mv	a0,s5
    80004afc:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004afe:	60e6                	ld	ra,88(sp)
    80004b00:	6446                	ld	s0,80(sp)
    80004b02:	6906                	ld	s2,64(sp)
    80004b04:	7aa2                	ld	s5,40(sp)
    80004b06:	7b02                	ld	s6,32(sp)
    80004b08:	6125                	addi	sp,sp,96
    80004b0a:	8082                	ret
    80004b0c:	e4a6                	sd	s1,72(sp)
    80004b0e:	fc4e                	sd	s3,56(sp)
    80004b10:	f852                	sd	s4,48(sp)
    80004b12:	ec5e                	sd	s7,24(sp)
    80004b14:	e862                	sd	s8,16(sp)
    80004b16:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004b18:	00004517          	auipc	a0,0x4
    80004b1c:	aa050513          	addi	a0,a0,-1376 # 800085b8 <etext+0x5b8>
    80004b20:	d05fb0ef          	jal	80000824 <panic>
    return -1;
    80004b24:	557d                	li	a0,-1
}
    80004b26:	8082                	ret
      return -1;
    80004b28:	557d                	li	a0,-1
    80004b2a:	bfd1                	j	80004afe <filewrite+0xfc>
    80004b2c:	557d                	li	a0,-1
    80004b2e:	bfc1                	j	80004afe <filewrite+0xfc>
    ret = (i == n ? n : -1);
    80004b30:	557d                	li	a0,-1
    80004b32:	7a42                	ld	s4,48(sp)
    80004b34:	b7e9                	j	80004afe <filewrite+0xfc>

0000000080004b36 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b36:	7179                	addi	sp,sp,-48
    80004b38:	f406                	sd	ra,40(sp)
    80004b3a:	f022                	sd	s0,32(sp)
    80004b3c:	ec26                	sd	s1,24(sp)
    80004b3e:	e052                	sd	s4,0(sp)
    80004b40:	1800                	addi	s0,sp,48
    80004b42:	84aa                	mv	s1,a0
    80004b44:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b46:	0005b023          	sd	zero,0(a1)
    80004b4a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b4e:	c29ff0ef          	jal	80004776 <filealloc>
    80004b52:	e088                	sd	a0,0(s1)
    80004b54:	c549                	beqz	a0,80004bde <pipealloc+0xa8>
    80004b56:	c21ff0ef          	jal	80004776 <filealloc>
    80004b5a:	00aa3023          	sd	a0,0(s4)
    80004b5e:	cd25                	beqz	a0,80004bd6 <pipealloc+0xa0>
    80004b60:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b62:	fe3fb0ef          	jal	80000b44 <kalloc>
    80004b66:	892a                	mv	s2,a0
    80004b68:	c12d                	beqz	a0,80004bca <pipealloc+0x94>
    80004b6a:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004b6c:	4985                	li	s3,1
    80004b6e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b72:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b76:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b7a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b7e:	00004597          	auipc	a1,0x4
    80004b82:	a4a58593          	addi	a1,a1,-1462 # 800085c8 <etext+0x5c8>
    80004b86:	818fc0ef          	jal	80000b9e <initlock>
  (*f0)->type = FD_PIPE;
    80004b8a:	609c                	ld	a5,0(s1)
    80004b8c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b90:	609c                	ld	a5,0(s1)
    80004b92:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b96:	609c                	ld	a5,0(s1)
    80004b98:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b9c:	609c                	ld	a5,0(s1)
    80004b9e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004ba2:	000a3783          	ld	a5,0(s4)
    80004ba6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004baa:	000a3783          	ld	a5,0(s4)
    80004bae:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004bb2:	000a3783          	ld	a5,0(s4)
    80004bb6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004bba:	000a3783          	ld	a5,0(s4)
    80004bbe:	0127b823          	sd	s2,16(a5)
  return 0;
    80004bc2:	4501                	li	a0,0
    80004bc4:	6942                	ld	s2,16(sp)
    80004bc6:	69a2                	ld	s3,8(sp)
    80004bc8:	a01d                	j	80004bee <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004bca:	6088                	ld	a0,0(s1)
    80004bcc:	c119                	beqz	a0,80004bd2 <pipealloc+0x9c>
    80004bce:	6942                	ld	s2,16(sp)
    80004bd0:	a029                	j	80004bda <pipealloc+0xa4>
    80004bd2:	6942                	ld	s2,16(sp)
    80004bd4:	a029                	j	80004bde <pipealloc+0xa8>
    80004bd6:	6088                	ld	a0,0(s1)
    80004bd8:	c10d                	beqz	a0,80004bfa <pipealloc+0xc4>
    fileclose(*f0);
    80004bda:	c41ff0ef          	jal	8000481a <fileclose>
  if(*f1)
    80004bde:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004be2:	557d                	li	a0,-1
  if(*f1)
    80004be4:	c789                	beqz	a5,80004bee <pipealloc+0xb8>
    fileclose(*f1);
    80004be6:	853e                	mv	a0,a5
    80004be8:	c33ff0ef          	jal	8000481a <fileclose>
  return -1;
    80004bec:	557d                	li	a0,-1
}
    80004bee:	70a2                	ld	ra,40(sp)
    80004bf0:	7402                	ld	s0,32(sp)
    80004bf2:	64e2                	ld	s1,24(sp)
    80004bf4:	6a02                	ld	s4,0(sp)
    80004bf6:	6145                	addi	sp,sp,48
    80004bf8:	8082                	ret
  return -1;
    80004bfa:	557d                	li	a0,-1
    80004bfc:	bfcd                	j	80004bee <pipealloc+0xb8>

0000000080004bfe <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bfe:	1101                	addi	sp,sp,-32
    80004c00:	ec06                	sd	ra,24(sp)
    80004c02:	e822                	sd	s0,16(sp)
    80004c04:	e426                	sd	s1,8(sp)
    80004c06:	e04a                	sd	s2,0(sp)
    80004c08:	1000                	addi	s0,sp,32
    80004c0a:	84aa                	mv	s1,a0
    80004c0c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c0e:	81afc0ef          	jal	80000c28 <acquire>
  if(writable){
    80004c12:	02090763          	beqz	s2,80004c40 <pipeclose+0x42>
    pi->writeopen = 0;
    80004c16:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c1a:	21848513          	addi	a0,s1,536
    80004c1e:	cc8fd0ef          	jal	800020e6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c22:	2204a783          	lw	a5,544(s1)
    80004c26:	e781                	bnez	a5,80004c2e <pipeclose+0x30>
    80004c28:	2244a783          	lw	a5,548(s1)
    80004c2c:	c38d                	beqz	a5,80004c4e <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    80004c2e:	8526                	mv	a0,s1
    80004c30:	88cfc0ef          	jal	80000cbc <release>
}
    80004c34:	60e2                	ld	ra,24(sp)
    80004c36:	6442                	ld	s0,16(sp)
    80004c38:	64a2                	ld	s1,8(sp)
    80004c3a:	6902                	ld	s2,0(sp)
    80004c3c:	6105                	addi	sp,sp,32
    80004c3e:	8082                	ret
    pi->readopen = 0;
    80004c40:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c44:	21c48513          	addi	a0,s1,540
    80004c48:	c9efd0ef          	jal	800020e6 <wakeup>
    80004c4c:	bfd9                	j	80004c22 <pipeclose+0x24>
    release(&pi->lock);
    80004c4e:	8526                	mv	a0,s1
    80004c50:	86cfc0ef          	jal	80000cbc <release>
    kfree((char*)pi);
    80004c54:	8526                	mv	a0,s1
    80004c56:	e07fb0ef          	jal	80000a5c <kfree>
    80004c5a:	bfe9                	j	80004c34 <pipeclose+0x36>

0000000080004c5c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c5c:	7159                	addi	sp,sp,-112
    80004c5e:	f486                	sd	ra,104(sp)
    80004c60:	f0a2                	sd	s0,96(sp)
    80004c62:	eca6                	sd	s1,88(sp)
    80004c64:	e8ca                	sd	s2,80(sp)
    80004c66:	e4ce                	sd	s3,72(sp)
    80004c68:	e0d2                	sd	s4,64(sp)
    80004c6a:	fc56                	sd	s5,56(sp)
    80004c6c:	1880                	addi	s0,sp,112
    80004c6e:	84aa                	mv	s1,a0
    80004c70:	8aae                	mv	s5,a1
    80004c72:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c74:	d17fc0ef          	jal	8000198a <myproc>
    80004c78:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c7a:	8526                	mv	a0,s1
    80004c7c:	fadfb0ef          	jal	80000c28 <acquire>
  while(i < n){
    80004c80:	0d405263          	blez	s4,80004d44 <pipewrite+0xe8>
    80004c84:	f85a                	sd	s6,48(sp)
    80004c86:	f45e                	sd	s7,40(sp)
    80004c88:	f062                	sd	s8,32(sp)
    80004c8a:	ec66                	sd	s9,24(sp)
    80004c8c:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004c8e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c90:	f9f40c13          	addi	s8,s0,-97
    80004c94:	4b85                	li	s7,1
    80004c96:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c98:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c9c:	21c48c93          	addi	s9,s1,540
    80004ca0:	a82d                	j	80004cda <pipewrite+0x7e>
      release(&pi->lock);
    80004ca2:	8526                	mv	a0,s1
    80004ca4:	818fc0ef          	jal	80000cbc <release>
      return -1;
    80004ca8:	597d                	li	s2,-1
    80004caa:	7b42                	ld	s6,48(sp)
    80004cac:	7ba2                	ld	s7,40(sp)
    80004cae:	7c02                	ld	s8,32(sp)
    80004cb0:	6ce2                	ld	s9,24(sp)
    80004cb2:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004cb4:	854a                	mv	a0,s2
    80004cb6:	70a6                	ld	ra,104(sp)
    80004cb8:	7406                	ld	s0,96(sp)
    80004cba:	64e6                	ld	s1,88(sp)
    80004cbc:	6946                	ld	s2,80(sp)
    80004cbe:	69a6                	ld	s3,72(sp)
    80004cc0:	6a06                	ld	s4,64(sp)
    80004cc2:	7ae2                	ld	s5,56(sp)
    80004cc4:	6165                	addi	sp,sp,112
    80004cc6:	8082                	ret
      wakeup(&pi->nread);
    80004cc8:	856a                	mv	a0,s10
    80004cca:	c1cfd0ef          	jal	800020e6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004cce:	85a6                	mv	a1,s1
    80004cd0:	8566                	mv	a0,s9
    80004cd2:	bc8fd0ef          	jal	8000209a <sleep>
  while(i < n){
    80004cd6:	05495a63          	bge	s2,s4,80004d2a <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    80004cda:	2204a783          	lw	a5,544(s1)
    80004cde:	d3f1                	beqz	a5,80004ca2 <pipewrite+0x46>
    80004ce0:	854e                	mv	a0,s3
    80004ce2:	e0cfd0ef          	jal	800022ee <killed>
    80004ce6:	fd55                	bnez	a0,80004ca2 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004ce8:	2184a783          	lw	a5,536(s1)
    80004cec:	21c4a703          	lw	a4,540(s1)
    80004cf0:	2007879b          	addiw	a5,a5,512
    80004cf4:	fcf70ae3          	beq	a4,a5,80004cc8 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cf8:	86de                	mv	a3,s7
    80004cfa:	01590633          	add	a2,s2,s5
    80004cfe:	85e2                	mv	a1,s8
    80004d00:	0589b503          	ld	a0,88(s3)
    80004d04:	a0ffc0ef          	jal	80001712 <copyin>
    80004d08:	05650063          	beq	a0,s6,80004d48 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d0c:	21c4a783          	lw	a5,540(s1)
    80004d10:	0017871b          	addiw	a4,a5,1
    80004d14:	20e4ae23          	sw	a4,540(s1)
    80004d18:	1ff7f793          	andi	a5,a5,511
    80004d1c:	97a6                	add	a5,a5,s1
    80004d1e:	f9f44703          	lbu	a4,-97(s0)
    80004d22:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d26:	2905                	addiw	s2,s2,1
    80004d28:	b77d                	j	80004cd6 <pipewrite+0x7a>
    80004d2a:	7b42                	ld	s6,48(sp)
    80004d2c:	7ba2                	ld	s7,40(sp)
    80004d2e:	7c02                	ld	s8,32(sp)
    80004d30:	6ce2                	ld	s9,24(sp)
    80004d32:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004d34:	21848513          	addi	a0,s1,536
    80004d38:	baefd0ef          	jal	800020e6 <wakeup>
  release(&pi->lock);
    80004d3c:	8526                	mv	a0,s1
    80004d3e:	f7ffb0ef          	jal	80000cbc <release>
  return i;
    80004d42:	bf8d                	j	80004cb4 <pipewrite+0x58>
  int i = 0;
    80004d44:	4901                	li	s2,0
    80004d46:	b7fd                	j	80004d34 <pipewrite+0xd8>
    80004d48:	7b42                	ld	s6,48(sp)
    80004d4a:	7ba2                	ld	s7,40(sp)
    80004d4c:	7c02                	ld	s8,32(sp)
    80004d4e:	6ce2                	ld	s9,24(sp)
    80004d50:	6d42                	ld	s10,16(sp)
    80004d52:	b7cd                	j	80004d34 <pipewrite+0xd8>

0000000080004d54 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d54:	711d                	addi	sp,sp,-96
    80004d56:	ec86                	sd	ra,88(sp)
    80004d58:	e8a2                	sd	s0,80(sp)
    80004d5a:	e4a6                	sd	s1,72(sp)
    80004d5c:	e0ca                	sd	s2,64(sp)
    80004d5e:	fc4e                	sd	s3,56(sp)
    80004d60:	f852                	sd	s4,48(sp)
    80004d62:	f456                	sd	s5,40(sp)
    80004d64:	1080                	addi	s0,sp,96
    80004d66:	84aa                	mv	s1,a0
    80004d68:	892e                	mv	s2,a1
    80004d6a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d6c:	c1ffc0ef          	jal	8000198a <myproc>
    80004d70:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d72:	8526                	mv	a0,s1
    80004d74:	eb5fb0ef          	jal	80000c28 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d78:	2184a703          	lw	a4,536(s1)
    80004d7c:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d80:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d84:	02f71763          	bne	a4,a5,80004db2 <piperead+0x5e>
    80004d88:	2244a783          	lw	a5,548(s1)
    80004d8c:	cf85                	beqz	a5,80004dc4 <piperead+0x70>
    if(killed(pr)){
    80004d8e:	8552                	mv	a0,s4
    80004d90:	d5efd0ef          	jal	800022ee <killed>
    80004d94:	e11d                	bnez	a0,80004dba <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d96:	85a6                	mv	a1,s1
    80004d98:	854e                	mv	a0,s3
    80004d9a:	b00fd0ef          	jal	8000209a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d9e:	2184a703          	lw	a4,536(s1)
    80004da2:	21c4a783          	lw	a5,540(s1)
    80004da6:	fef701e3          	beq	a4,a5,80004d88 <piperead+0x34>
    80004daa:	f05a                	sd	s6,32(sp)
    80004dac:	ec5e                	sd	s7,24(sp)
    80004dae:	e862                	sd	s8,16(sp)
    80004db0:	a829                	j	80004dca <piperead+0x76>
    80004db2:	f05a                	sd	s6,32(sp)
    80004db4:	ec5e                	sd	s7,24(sp)
    80004db6:	e862                	sd	s8,16(sp)
    80004db8:	a809                	j	80004dca <piperead+0x76>
      release(&pi->lock);
    80004dba:	8526                	mv	a0,s1
    80004dbc:	f01fb0ef          	jal	80000cbc <release>
      return -1;
    80004dc0:	59fd                	li	s3,-1
    80004dc2:	a0a5                	j	80004e2a <piperead+0xd6>
    80004dc4:	f05a                	sd	s6,32(sp)
    80004dc6:	ec5e                	sd	s7,24(sp)
    80004dc8:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dca:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004dcc:	faf40c13          	addi	s8,s0,-81
    80004dd0:	4b85                	li	s7,1
    80004dd2:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dd4:	05505163          	blez	s5,80004e16 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    80004dd8:	2184a783          	lw	a5,536(s1)
    80004ddc:	21c4a703          	lw	a4,540(s1)
    80004de0:	02f70b63          	beq	a4,a5,80004e16 <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004de4:	1ff7f793          	andi	a5,a5,511
    80004de8:	97a6                	add	a5,a5,s1
    80004dea:	0187c783          	lbu	a5,24(a5)
    80004dee:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004df2:	86de                	mv	a3,s7
    80004df4:	8662                	mv	a2,s8
    80004df6:	85ca                	mv	a1,s2
    80004df8:	058a3503          	ld	a0,88(s4)
    80004dfc:	859fc0ef          	jal	80001654 <copyout>
    80004e00:	03650f63          	beq	a0,s6,80004e3e <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004e04:	2184a783          	lw	a5,536(s1)
    80004e08:	2785                	addiw	a5,a5,1
    80004e0a:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e0e:	2985                	addiw	s3,s3,1
    80004e10:	0905                	addi	s2,s2,1
    80004e12:	fd3a93e3          	bne	s5,s3,80004dd8 <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e16:	21c48513          	addi	a0,s1,540
    80004e1a:	accfd0ef          	jal	800020e6 <wakeup>
  release(&pi->lock);
    80004e1e:	8526                	mv	a0,s1
    80004e20:	e9dfb0ef          	jal	80000cbc <release>
    80004e24:	7b02                	ld	s6,32(sp)
    80004e26:	6be2                	ld	s7,24(sp)
    80004e28:	6c42                	ld	s8,16(sp)
  return i;
}
    80004e2a:	854e                	mv	a0,s3
    80004e2c:	60e6                	ld	ra,88(sp)
    80004e2e:	6446                	ld	s0,80(sp)
    80004e30:	64a6                	ld	s1,72(sp)
    80004e32:	6906                	ld	s2,64(sp)
    80004e34:	79e2                	ld	s3,56(sp)
    80004e36:	7a42                	ld	s4,48(sp)
    80004e38:	7aa2                	ld	s5,40(sp)
    80004e3a:	6125                	addi	sp,sp,96
    80004e3c:	8082                	ret
      if(i == 0)
    80004e3e:	fc099ce3          	bnez	s3,80004e16 <piperead+0xc2>
        i = -1;
    80004e42:	89aa                	mv	s3,a0
    80004e44:	bfc9                	j	80004e16 <piperead+0xc2>

0000000080004e46 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004e46:	1141                	addi	sp,sp,-16
    80004e48:	e406                	sd	ra,8(sp)
    80004e4a:	e022                	sd	s0,0(sp)
    80004e4c:	0800                	addi	s0,sp,16
    80004e4e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e50:	0035151b          	slliw	a0,a0,0x3
    80004e54:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004e56:	8b89                	andi	a5,a5,2
    80004e58:	c399                	beqz	a5,80004e5e <flags2perm+0x18>
      perm |= PTE_W;
    80004e5a:	00456513          	ori	a0,a0,4
    return perm;
}
    80004e5e:	60a2                	ld	ra,8(sp)
    80004e60:	6402                	ld	s0,0(sp)
    80004e62:	0141                	addi	sp,sp,16
    80004e64:	8082                	ret

0000000080004e66 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004e66:	de010113          	addi	sp,sp,-544
    80004e6a:	20113c23          	sd	ra,536(sp)
    80004e6e:	20813823          	sd	s0,528(sp)
    80004e72:	20913423          	sd	s1,520(sp)
    80004e76:	21213023          	sd	s2,512(sp)
    80004e7a:	1400                	addi	s0,sp,544
    80004e7c:	892a                	mv	s2,a0
    80004e7e:	dea43823          	sd	a0,-528(s0)
    80004e82:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e86:	b05fc0ef          	jal	8000198a <myproc>
    80004e8a:	84aa                	mv	s1,a0

  begin_op();
    80004e8c:	d6aff0ef          	jal	800043f6 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004e90:	854a                	mv	a0,s2
    80004e92:	b86ff0ef          	jal	80004218 <namei>
    80004e96:	cd21                	beqz	a0,80004eee <kexec+0x88>
    80004e98:	fbd2                	sd	s4,496(sp)
    80004e9a:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e9c:	b4ffe0ef          	jal	800039ea <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004ea0:	04000713          	li	a4,64
    80004ea4:	4681                	li	a3,0
    80004ea6:	e5040613          	addi	a2,s0,-432
    80004eaa:	4581                	li	a1,0
    80004eac:	8552                	mv	a0,s4
    80004eae:	ecffe0ef          	jal	80003d7c <readi>
    80004eb2:	04000793          	li	a5,64
    80004eb6:	00f51a63          	bne	a0,a5,80004eca <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004eba:	e5042703          	lw	a4,-432(s0)
    80004ebe:	464c47b7          	lui	a5,0x464c4
    80004ec2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004ec6:	02f70863          	beq	a4,a5,80004ef6 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004eca:	8552                	mv	a0,s4
    80004ecc:	d2bfe0ef          	jal	80003bf6 <iunlockput>
    end_op();
    80004ed0:	d96ff0ef          	jal	80004466 <end_op>
  }
  return -1;
    80004ed4:	557d                	li	a0,-1
    80004ed6:	7a5e                	ld	s4,496(sp)
}
    80004ed8:	21813083          	ld	ra,536(sp)
    80004edc:	21013403          	ld	s0,528(sp)
    80004ee0:	20813483          	ld	s1,520(sp)
    80004ee4:	20013903          	ld	s2,512(sp)
    80004ee8:	22010113          	addi	sp,sp,544
    80004eec:	8082                	ret
    end_op();
    80004eee:	d78ff0ef          	jal	80004466 <end_op>
    return -1;
    80004ef2:	557d                	li	a0,-1
    80004ef4:	b7d5                	j	80004ed8 <kexec+0x72>
    80004ef6:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004ef8:	8526                	mv	a0,s1
    80004efa:	b9bfc0ef          	jal	80001a94 <proc_pagetable>
    80004efe:	8b2a                	mv	s6,a0
    80004f00:	26050f63          	beqz	a0,8000517e <kexec+0x318>
    80004f04:	ffce                	sd	s3,504(sp)
    80004f06:	f7d6                	sd	s5,488(sp)
    80004f08:	efde                	sd	s7,472(sp)
    80004f0a:	ebe2                	sd	s8,464(sp)
    80004f0c:	e7e6                	sd	s9,456(sp)
    80004f0e:	e3ea                	sd	s10,448(sp)
    80004f10:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f12:	e8845783          	lhu	a5,-376(s0)
    80004f16:	0e078963          	beqz	a5,80005008 <kexec+0x1a2>
    80004f1a:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f1e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f20:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f22:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004f26:	6c85                	lui	s9,0x1
    80004f28:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004f2c:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004f30:	6a85                	lui	s5,0x1
    80004f32:	a085                	j	80004f92 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004f34:	00003517          	auipc	a0,0x3
    80004f38:	69c50513          	addi	a0,a0,1692 # 800085d0 <etext+0x5d0>
    80004f3c:	8e9fb0ef          	jal	80000824 <panic>
    if(sz - i < PGSIZE)
    80004f40:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f42:	874a                	mv	a4,s2
    80004f44:	009b86bb          	addw	a3,s7,s1
    80004f48:	4581                	li	a1,0
    80004f4a:	8552                	mv	a0,s4
    80004f4c:	e31fe0ef          	jal	80003d7c <readi>
    80004f50:	22a91b63          	bne	s2,a0,80005186 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    80004f54:	009a84bb          	addw	s1,s5,s1
    80004f58:	0334f263          	bgeu	s1,s3,80004f7c <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004f5c:	02049593          	slli	a1,s1,0x20
    80004f60:	9181                	srli	a1,a1,0x20
    80004f62:	95e2                	add	a1,a1,s8
    80004f64:	855a                	mv	a0,s6
    80004f66:	8c0fc0ef          	jal	80001026 <walkaddr>
    80004f6a:	862a                	mv	a2,a0
    if(pa == 0)
    80004f6c:	d561                	beqz	a0,80004f34 <kexec+0xce>
    if(sz - i < PGSIZE)
    80004f6e:	409987bb          	subw	a5,s3,s1
    80004f72:	893e                	mv	s2,a5
    80004f74:	fcfcf6e3          	bgeu	s9,a5,80004f40 <kexec+0xda>
    80004f78:	8956                	mv	s2,s5
    80004f7a:	b7d9                	j	80004f40 <kexec+0xda>
    sz = sz1;
    80004f7c:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f80:	2d05                	addiw	s10,s10,1
    80004f82:	e0843783          	ld	a5,-504(s0)
    80004f86:	0387869b          	addiw	a3,a5,56
    80004f8a:	e8845783          	lhu	a5,-376(s0)
    80004f8e:	06fd5e63          	bge	s10,a5,8000500a <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f92:	e0d43423          	sd	a3,-504(s0)
    80004f96:	876e                	mv	a4,s11
    80004f98:	e1840613          	addi	a2,s0,-488
    80004f9c:	4581                	li	a1,0
    80004f9e:	8552                	mv	a0,s4
    80004fa0:	dddfe0ef          	jal	80003d7c <readi>
    80004fa4:	1db51f63          	bne	a0,s11,80005182 <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    80004fa8:	e1842783          	lw	a5,-488(s0)
    80004fac:	4705                	li	a4,1
    80004fae:	fce799e3          	bne	a5,a4,80004f80 <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    80004fb2:	e4043483          	ld	s1,-448(s0)
    80004fb6:	e3843783          	ld	a5,-456(s0)
    80004fba:	1ef4e463          	bltu	s1,a5,800051a2 <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004fbe:	e2843783          	ld	a5,-472(s0)
    80004fc2:	94be                	add	s1,s1,a5
    80004fc4:	1ef4e263          	bltu	s1,a5,800051a8 <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    80004fc8:	de843703          	ld	a4,-536(s0)
    80004fcc:	8ff9                	and	a5,a5,a4
    80004fce:	1e079063          	bnez	a5,800051ae <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004fd2:	e1c42503          	lw	a0,-484(s0)
    80004fd6:	e71ff0ef          	jal	80004e46 <flags2perm>
    80004fda:	86aa                	mv	a3,a0
    80004fdc:	8626                	mv	a2,s1
    80004fde:	85ca                	mv	a1,s2
    80004fe0:	855a                	mv	a0,s6
    80004fe2:	b1afc0ef          	jal	800012fc <uvmalloc>
    80004fe6:	dea43c23          	sd	a0,-520(s0)
    80004fea:	1c050563          	beqz	a0,800051b4 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004fee:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004ff2:	00098863          	beqz	s3,80005002 <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ff6:	e2843c03          	ld	s8,-472(s0)
    80004ffa:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004ffe:	4481                	li	s1,0
    80005000:	bfb1                	j	80004f5c <kexec+0xf6>
    sz = sz1;
    80005002:	df843903          	ld	s2,-520(s0)
    80005006:	bfad                	j	80004f80 <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005008:	4901                	li	s2,0
  iunlockput(ip);
    8000500a:	8552                	mv	a0,s4
    8000500c:	bebfe0ef          	jal	80003bf6 <iunlockput>
  end_op();
    80005010:	c56ff0ef          	jal	80004466 <end_op>
  p = myproc();
    80005014:	977fc0ef          	jal	8000198a <myproc>
    80005018:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000501a:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    8000501e:	6985                	lui	s3,0x1
    80005020:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005022:	99ca                	add	s3,s3,s2
    80005024:	77fd                	lui	a5,0xfffff
    80005026:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000502a:	4691                	li	a3,4
    8000502c:	6609                	lui	a2,0x2
    8000502e:	964e                	add	a2,a2,s3
    80005030:	85ce                	mv	a1,s3
    80005032:	855a                	mv	a0,s6
    80005034:	ac8fc0ef          	jal	800012fc <uvmalloc>
    80005038:	8a2a                	mv	s4,a0
    8000503a:	e105                	bnez	a0,8000505a <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    8000503c:	85ce                	mv	a1,s3
    8000503e:	855a                	mv	a0,s6
    80005040:	ad9fc0ef          	jal	80001b18 <proc_freepagetable>
  return -1;
    80005044:	557d                	li	a0,-1
    80005046:	79fe                	ld	s3,504(sp)
    80005048:	7a5e                	ld	s4,496(sp)
    8000504a:	7abe                	ld	s5,488(sp)
    8000504c:	7b1e                	ld	s6,480(sp)
    8000504e:	6bfe                	ld	s7,472(sp)
    80005050:	6c5e                	ld	s8,464(sp)
    80005052:	6cbe                	ld	s9,456(sp)
    80005054:	6d1e                	ld	s10,448(sp)
    80005056:	7dfa                	ld	s11,440(sp)
    80005058:	b541                	j	80004ed8 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    8000505a:	75f9                	lui	a1,0xffffe
    8000505c:	95aa                	add	a1,a1,a0
    8000505e:	855a                	mv	a0,s6
    80005060:	c6efc0ef          	jal	800014ce <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80005064:	800a0b93          	addi	s7,s4,-2048
    80005068:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    8000506c:	e0043783          	ld	a5,-512(s0)
    80005070:	6388                	ld	a0,0(a5)
  sp = sz;
    80005072:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80005074:	4481                	li	s1,0
    ustack[argc] = sp;
    80005076:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    8000507a:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    8000507e:	cd21                	beqz	a0,800050d6 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80005080:	e03fb0ef          	jal	80000e82 <strlen>
    80005084:	0015079b          	addiw	a5,a0,1
    80005088:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000508c:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005090:	13796563          	bltu	s2,s7,800051ba <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005094:	e0043d83          	ld	s11,-512(s0)
    80005098:	000db983          	ld	s3,0(s11)
    8000509c:	854e                	mv	a0,s3
    8000509e:	de5fb0ef          	jal	80000e82 <strlen>
    800050a2:	0015069b          	addiw	a3,a0,1
    800050a6:	864e                	mv	a2,s3
    800050a8:	85ca                	mv	a1,s2
    800050aa:	855a                	mv	a0,s6
    800050ac:	da8fc0ef          	jal	80001654 <copyout>
    800050b0:	10054763          	bltz	a0,800051be <kexec+0x358>
    ustack[argc] = sp;
    800050b4:	00349793          	slli	a5,s1,0x3
    800050b8:	97e6                	add	a5,a5,s9
    800050ba:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ff97398>
  for(argc = 0; argv[argc]; argc++) {
    800050be:	0485                	addi	s1,s1,1
    800050c0:	008d8793          	addi	a5,s11,8
    800050c4:	e0f43023          	sd	a5,-512(s0)
    800050c8:	008db503          	ld	a0,8(s11)
    800050cc:	c509                	beqz	a0,800050d6 <kexec+0x270>
    if(argc >= MAXARG)
    800050ce:	fb8499e3          	bne	s1,s8,80005080 <kexec+0x21a>
  sz = sz1;
    800050d2:	89d2                	mv	s3,s4
    800050d4:	b7a5                	j	8000503c <kexec+0x1d6>
  ustack[argc] = 0;
    800050d6:	00349793          	slli	a5,s1,0x3
    800050da:	f9078793          	addi	a5,a5,-112
    800050de:	97a2                	add	a5,a5,s0
    800050e0:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800050e4:	00349693          	slli	a3,s1,0x3
    800050e8:	06a1                	addi	a3,a3,8
    800050ea:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800050ee:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800050f2:	89d2                	mv	s3,s4
  if(sp < stackbase)
    800050f4:	f57964e3          	bltu	s2,s7,8000503c <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800050f8:	e9040613          	addi	a2,s0,-368
    800050fc:	85ca                	mv	a1,s2
    800050fe:	855a                	mv	a0,s6
    80005100:	d54fc0ef          	jal	80001654 <copyout>
    80005104:	f2054ce3          	bltz	a0,8000503c <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80005108:	060ab783          	ld	a5,96(s5) # 1060 <_entry-0x7fffefa0>
    8000510c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005110:	df043783          	ld	a5,-528(s0)
    80005114:	0007c703          	lbu	a4,0(a5)
    80005118:	cf11                	beqz	a4,80005134 <kexec+0x2ce>
    8000511a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000511c:	02f00693          	li	a3,47
    80005120:	a029                	j	8000512a <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80005122:	0785                	addi	a5,a5,1
    80005124:	fff7c703          	lbu	a4,-1(a5)
    80005128:	c711                	beqz	a4,80005134 <kexec+0x2ce>
    if(*s == '/')
    8000512a:	fed71ce3          	bne	a4,a3,80005122 <kexec+0x2bc>
      last = s+1;
    8000512e:	def43823          	sd	a5,-528(s0)
    80005132:	bfc5                	j	80005122 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80005134:	4641                	li	a2,16
    80005136:	df043583          	ld	a1,-528(s0)
    8000513a:	160a8513          	addi	a0,s5,352
    8000513e:	d0ffb0ef          	jal	80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    80005142:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80005146:	056abc23          	sd	s6,88(s5)
  p->sz = sz;
    8000514a:	054ab823          	sd	s4,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    8000514e:	060ab783          	ld	a5,96(s5)
    80005152:	e6843703          	ld	a4,-408(s0)
    80005156:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005158:	060ab783          	ld	a5,96(s5)
    8000515c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005160:	85ea                	mv	a1,s10
    80005162:	9b7fc0ef          	jal	80001b18 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005166:	0004851b          	sext.w	a0,s1
    8000516a:	79fe                	ld	s3,504(sp)
    8000516c:	7a5e                	ld	s4,496(sp)
    8000516e:	7abe                	ld	s5,488(sp)
    80005170:	7b1e                	ld	s6,480(sp)
    80005172:	6bfe                	ld	s7,472(sp)
    80005174:	6c5e                	ld	s8,464(sp)
    80005176:	6cbe                	ld	s9,456(sp)
    80005178:	6d1e                	ld	s10,448(sp)
    8000517a:	7dfa                	ld	s11,440(sp)
    8000517c:	bbb1                	j	80004ed8 <kexec+0x72>
    8000517e:	7b1e                	ld	s6,480(sp)
    80005180:	b3a9                	j	80004eca <kexec+0x64>
    80005182:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005186:	df843583          	ld	a1,-520(s0)
    8000518a:	855a                	mv	a0,s6
    8000518c:	98dfc0ef          	jal	80001b18 <proc_freepagetable>
  if(ip){
    80005190:	79fe                	ld	s3,504(sp)
    80005192:	7abe                	ld	s5,488(sp)
    80005194:	7b1e                	ld	s6,480(sp)
    80005196:	6bfe                	ld	s7,472(sp)
    80005198:	6c5e                	ld	s8,464(sp)
    8000519a:	6cbe                	ld	s9,456(sp)
    8000519c:	6d1e                	ld	s10,448(sp)
    8000519e:	7dfa                	ld	s11,440(sp)
    800051a0:	b32d                	j	80004eca <kexec+0x64>
    800051a2:	df243c23          	sd	s2,-520(s0)
    800051a6:	b7c5                	j	80005186 <kexec+0x320>
    800051a8:	df243c23          	sd	s2,-520(s0)
    800051ac:	bfe9                	j	80005186 <kexec+0x320>
    800051ae:	df243c23          	sd	s2,-520(s0)
    800051b2:	bfd1                	j	80005186 <kexec+0x320>
    800051b4:	df243c23          	sd	s2,-520(s0)
    800051b8:	b7f9                	j	80005186 <kexec+0x320>
  sz = sz1;
    800051ba:	89d2                	mv	s3,s4
    800051bc:	b541                	j	8000503c <kexec+0x1d6>
    800051be:	89d2                	mv	s3,s4
    800051c0:	bdb5                	j	8000503c <kexec+0x1d6>

00000000800051c2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800051c2:	7179                	addi	sp,sp,-48
    800051c4:	f406                	sd	ra,40(sp)
    800051c6:	f022                	sd	s0,32(sp)
    800051c8:	ec26                	sd	s1,24(sp)
    800051ca:	e84a                	sd	s2,16(sp)
    800051cc:	1800                	addi	s0,sp,48
    800051ce:	892e                	mv	s2,a1
    800051d0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800051d2:	fdc40593          	addi	a1,s0,-36
    800051d6:	ff2fd0ef          	jal	800029c8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800051da:	fdc42703          	lw	a4,-36(s0)
    800051de:	47bd                	li	a5,15
    800051e0:	02e7ea63          	bltu	a5,a4,80005214 <argfd+0x52>
    800051e4:	fa6fc0ef          	jal	8000198a <myproc>
    800051e8:	fdc42703          	lw	a4,-36(s0)
    800051ec:	00371793          	slli	a5,a4,0x3
    800051f0:	0d078793          	addi	a5,a5,208
    800051f4:	953e                	add	a0,a0,a5
    800051f6:	651c                	ld	a5,8(a0)
    800051f8:	c385                	beqz	a5,80005218 <argfd+0x56>
    return -1;
  if(pfd)
    800051fa:	00090463          	beqz	s2,80005202 <argfd+0x40>
    *pfd = fd;
    800051fe:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005202:	4501                	li	a0,0
  if(pf)
    80005204:	c091                	beqz	s1,80005208 <argfd+0x46>
    *pf = f;
    80005206:	e09c                	sd	a5,0(s1)
}
    80005208:	70a2                	ld	ra,40(sp)
    8000520a:	7402                	ld	s0,32(sp)
    8000520c:	64e2                	ld	s1,24(sp)
    8000520e:	6942                	ld	s2,16(sp)
    80005210:	6145                	addi	sp,sp,48
    80005212:	8082                	ret
    return -1;
    80005214:	557d                	li	a0,-1
    80005216:	bfcd                	j	80005208 <argfd+0x46>
    80005218:	557d                	li	a0,-1
    8000521a:	b7fd                	j	80005208 <argfd+0x46>

000000008000521c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000521c:	1101                	addi	sp,sp,-32
    8000521e:	ec06                	sd	ra,24(sp)
    80005220:	e822                	sd	s0,16(sp)
    80005222:	e426                	sd	s1,8(sp)
    80005224:	1000                	addi	s0,sp,32
    80005226:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005228:	f62fc0ef          	jal	8000198a <myproc>
    8000522c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000522e:	0d850793          	addi	a5,a0,216
    80005232:	4501                	li	a0,0
    80005234:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005236:	6398                	ld	a4,0(a5)
    80005238:	cb19                	beqz	a4,8000524e <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    8000523a:	2505                	addiw	a0,a0,1
    8000523c:	07a1                	addi	a5,a5,8
    8000523e:	fed51ce3          	bne	a0,a3,80005236 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005242:	557d                	li	a0,-1
}
    80005244:	60e2                	ld	ra,24(sp)
    80005246:	6442                	ld	s0,16(sp)
    80005248:	64a2                	ld	s1,8(sp)
    8000524a:	6105                	addi	sp,sp,32
    8000524c:	8082                	ret
      p->ofile[fd] = f;
    8000524e:	00351793          	slli	a5,a0,0x3
    80005252:	0d078793          	addi	a5,a5,208
    80005256:	963e                	add	a2,a2,a5
    80005258:	e604                	sd	s1,8(a2)
      return fd;
    8000525a:	b7ed                	j	80005244 <fdalloc+0x28>

000000008000525c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000525c:	715d                	addi	sp,sp,-80
    8000525e:	e486                	sd	ra,72(sp)
    80005260:	e0a2                	sd	s0,64(sp)
    80005262:	fc26                	sd	s1,56(sp)
    80005264:	f84a                	sd	s2,48(sp)
    80005266:	f44e                	sd	s3,40(sp)
    80005268:	f052                	sd	s4,32(sp)
    8000526a:	ec56                	sd	s5,24(sp)
    8000526c:	e85a                	sd	s6,16(sp)
    8000526e:	0880                	addi	s0,sp,80
    80005270:	892e                	mv	s2,a1
    80005272:	8a2e                	mv	s4,a1
    80005274:	8ab2                	mv	s5,a2
    80005276:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005278:	fb040593          	addi	a1,s0,-80
    8000527c:	fb7fe0ef          	jal	80004232 <nameiparent>
    80005280:	84aa                	mv	s1,a0
    80005282:	10050763          	beqz	a0,80005390 <create+0x134>
    return 0;

  ilock(dp);
    80005286:	f64fe0ef          	jal	800039ea <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000528a:	4601                	li	a2,0
    8000528c:	fb040593          	addi	a1,s0,-80
    80005290:	8526                	mv	a0,s1
    80005292:	cf3fe0ef          	jal	80003f84 <dirlookup>
    80005296:	89aa                	mv	s3,a0
    80005298:	c131                	beqz	a0,800052dc <create+0x80>
    iunlockput(dp);
    8000529a:	8526                	mv	a0,s1
    8000529c:	95bfe0ef          	jal	80003bf6 <iunlockput>
    ilock(ip);
    800052a0:	854e                	mv	a0,s3
    800052a2:	f48fe0ef          	jal	800039ea <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052a6:	4789                	li	a5,2
    800052a8:	02f91563          	bne	s2,a5,800052d2 <create+0x76>
    800052ac:	0449d783          	lhu	a5,68(s3)
    800052b0:	37f9                	addiw	a5,a5,-2
    800052b2:	17c2                	slli	a5,a5,0x30
    800052b4:	93c1                	srli	a5,a5,0x30
    800052b6:	4705                	li	a4,1
    800052b8:	00f76d63          	bltu	a4,a5,800052d2 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800052bc:	854e                	mv	a0,s3
    800052be:	60a6                	ld	ra,72(sp)
    800052c0:	6406                	ld	s0,64(sp)
    800052c2:	74e2                	ld	s1,56(sp)
    800052c4:	7942                	ld	s2,48(sp)
    800052c6:	79a2                	ld	s3,40(sp)
    800052c8:	7a02                	ld	s4,32(sp)
    800052ca:	6ae2                	ld	s5,24(sp)
    800052cc:	6b42                	ld	s6,16(sp)
    800052ce:	6161                	addi	sp,sp,80
    800052d0:	8082                	ret
    iunlockput(ip);
    800052d2:	854e                	mv	a0,s3
    800052d4:	923fe0ef          	jal	80003bf6 <iunlockput>
    return 0;
    800052d8:	4981                	li	s3,0
    800052da:	b7cd                	j	800052bc <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    800052dc:	85ca                	mv	a1,s2
    800052de:	4088                	lw	a0,0(s1)
    800052e0:	d9afe0ef          	jal	8000387a <ialloc>
    800052e4:	892a                	mv	s2,a0
    800052e6:	cd15                	beqz	a0,80005322 <create+0xc6>
  ilock(ip);
    800052e8:	f02fe0ef          	jal	800039ea <ilock>
  ip->major = major;
    800052ec:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    800052f0:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    800052f4:	4785                	li	a5,1
    800052f6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800052fa:	854a                	mv	a0,s2
    800052fc:	e3afe0ef          	jal	80003936 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005300:	4705                	li	a4,1
    80005302:	02ea0463          	beq	s4,a4,8000532a <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80005306:	00492603          	lw	a2,4(s2)
    8000530a:	fb040593          	addi	a1,s0,-80
    8000530e:	8526                	mv	a0,s1
    80005310:	e5ffe0ef          	jal	8000416e <dirlink>
    80005314:	06054263          	bltz	a0,80005378 <create+0x11c>
  iunlockput(dp);
    80005318:	8526                	mv	a0,s1
    8000531a:	8ddfe0ef          	jal	80003bf6 <iunlockput>
  return ip;
    8000531e:	89ca                	mv	s3,s2
    80005320:	bf71                	j	800052bc <create+0x60>
    iunlockput(dp);
    80005322:	8526                	mv	a0,s1
    80005324:	8d3fe0ef          	jal	80003bf6 <iunlockput>
    return 0;
    80005328:	bf51                	j	800052bc <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000532a:	00492603          	lw	a2,4(s2)
    8000532e:	00003597          	auipc	a1,0x3
    80005332:	2c258593          	addi	a1,a1,706 # 800085f0 <etext+0x5f0>
    80005336:	854a                	mv	a0,s2
    80005338:	e37fe0ef          	jal	8000416e <dirlink>
    8000533c:	02054e63          	bltz	a0,80005378 <create+0x11c>
    80005340:	40d0                	lw	a2,4(s1)
    80005342:	00003597          	auipc	a1,0x3
    80005346:	2b658593          	addi	a1,a1,694 # 800085f8 <etext+0x5f8>
    8000534a:	854a                	mv	a0,s2
    8000534c:	e23fe0ef          	jal	8000416e <dirlink>
    80005350:	02054463          	bltz	a0,80005378 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005354:	00492603          	lw	a2,4(s2)
    80005358:	fb040593          	addi	a1,s0,-80
    8000535c:	8526                	mv	a0,s1
    8000535e:	e11fe0ef          	jal	8000416e <dirlink>
    80005362:	00054b63          	bltz	a0,80005378 <create+0x11c>
    dp->nlink++;  // for ".."
    80005366:	04a4d783          	lhu	a5,74(s1)
    8000536a:	2785                	addiw	a5,a5,1
    8000536c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005370:	8526                	mv	a0,s1
    80005372:	dc4fe0ef          	jal	80003936 <iupdate>
    80005376:	b74d                	j	80005318 <create+0xbc>
  ip->nlink = 0;
    80005378:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    8000537c:	854a                	mv	a0,s2
    8000537e:	db8fe0ef          	jal	80003936 <iupdate>
  iunlockput(ip);
    80005382:	854a                	mv	a0,s2
    80005384:	873fe0ef          	jal	80003bf6 <iunlockput>
  iunlockput(dp);
    80005388:	8526                	mv	a0,s1
    8000538a:	86dfe0ef          	jal	80003bf6 <iunlockput>
  return 0;
    8000538e:	b73d                	j	800052bc <create+0x60>
    return 0;
    80005390:	89aa                	mv	s3,a0
    80005392:	b72d                	j	800052bc <create+0x60>

0000000080005394 <sys_dup>:
{
    80005394:	7179                	addi	sp,sp,-48
    80005396:	f406                	sd	ra,40(sp)
    80005398:	f022                	sd	s0,32(sp)
    8000539a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000539c:	fd840613          	addi	a2,s0,-40
    800053a0:	4581                	li	a1,0
    800053a2:	4501                	li	a0,0
    800053a4:	e1fff0ef          	jal	800051c2 <argfd>
    return -1;
    800053a8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053aa:	02054363          	bltz	a0,800053d0 <sys_dup+0x3c>
    800053ae:	ec26                	sd	s1,24(sp)
    800053b0:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800053b2:	fd843483          	ld	s1,-40(s0)
    800053b6:	8526                	mv	a0,s1
    800053b8:	e65ff0ef          	jal	8000521c <fdalloc>
    800053bc:	892a                	mv	s2,a0
    return -1;
    800053be:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053c0:	00054d63          	bltz	a0,800053da <sys_dup+0x46>
  filedup(f);
    800053c4:	8526                	mv	a0,s1
    800053c6:	c0eff0ef          	jal	800047d4 <filedup>
  return fd;
    800053ca:	87ca                	mv	a5,s2
    800053cc:	64e2                	ld	s1,24(sp)
    800053ce:	6942                	ld	s2,16(sp)
}
    800053d0:	853e                	mv	a0,a5
    800053d2:	70a2                	ld	ra,40(sp)
    800053d4:	7402                	ld	s0,32(sp)
    800053d6:	6145                	addi	sp,sp,48
    800053d8:	8082                	ret
    800053da:	64e2                	ld	s1,24(sp)
    800053dc:	6942                	ld	s2,16(sp)
    800053de:	bfcd                	j	800053d0 <sys_dup+0x3c>

00000000800053e0 <sys_read>:
{
    800053e0:	7179                	addi	sp,sp,-48
    800053e2:	f406                	sd	ra,40(sp)
    800053e4:	f022                	sd	s0,32(sp)
    800053e6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800053e8:	fd840593          	addi	a1,s0,-40
    800053ec:	4505                	li	a0,1
    800053ee:	df6fd0ef          	jal	800029e4 <argaddr>
  argint(2, &n);
    800053f2:	fe440593          	addi	a1,s0,-28
    800053f6:	4509                	li	a0,2
    800053f8:	dd0fd0ef          	jal	800029c8 <argint>
  if(argfd(0, 0, &f) < 0)
    800053fc:	fe840613          	addi	a2,s0,-24
    80005400:	4581                	li	a1,0
    80005402:	4501                	li	a0,0
    80005404:	dbfff0ef          	jal	800051c2 <argfd>
    80005408:	87aa                	mv	a5,a0
    return -1;
    8000540a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000540c:	0007ca63          	bltz	a5,80005420 <sys_read+0x40>
  return fileread(f, p, n);
    80005410:	fe442603          	lw	a2,-28(s0)
    80005414:	fd843583          	ld	a1,-40(s0)
    80005418:	fe843503          	ld	a0,-24(s0)
    8000541c:	d22ff0ef          	jal	8000493e <fileread>
}
    80005420:	70a2                	ld	ra,40(sp)
    80005422:	7402                	ld	s0,32(sp)
    80005424:	6145                	addi	sp,sp,48
    80005426:	8082                	ret

0000000080005428 <sys_write>:
{
    80005428:	7179                	addi	sp,sp,-48
    8000542a:	f406                	sd	ra,40(sp)
    8000542c:	f022                	sd	s0,32(sp)
    8000542e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005430:	fd840593          	addi	a1,s0,-40
    80005434:	4505                	li	a0,1
    80005436:	daefd0ef          	jal	800029e4 <argaddr>
  argint(2, &n);
    8000543a:	fe440593          	addi	a1,s0,-28
    8000543e:	4509                	li	a0,2
    80005440:	d88fd0ef          	jal	800029c8 <argint>
  if(argfd(0, 0, &f) < 0)
    80005444:	fe840613          	addi	a2,s0,-24
    80005448:	4581                	li	a1,0
    8000544a:	4501                	li	a0,0
    8000544c:	d77ff0ef          	jal	800051c2 <argfd>
    80005450:	87aa                	mv	a5,a0
    return -1;
    80005452:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005454:	0007ca63          	bltz	a5,80005468 <sys_write+0x40>
  return filewrite(f, p, n);
    80005458:	fe442603          	lw	a2,-28(s0)
    8000545c:	fd843583          	ld	a1,-40(s0)
    80005460:	fe843503          	ld	a0,-24(s0)
    80005464:	d9eff0ef          	jal	80004a02 <filewrite>
}
    80005468:	70a2                	ld	ra,40(sp)
    8000546a:	7402                	ld	s0,32(sp)
    8000546c:	6145                	addi	sp,sp,48
    8000546e:	8082                	ret

0000000080005470 <sys_close>:
{
    80005470:	1101                	addi	sp,sp,-32
    80005472:	ec06                	sd	ra,24(sp)
    80005474:	e822                	sd	s0,16(sp)
    80005476:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005478:	fe040613          	addi	a2,s0,-32
    8000547c:	fec40593          	addi	a1,s0,-20
    80005480:	4501                	li	a0,0
    80005482:	d41ff0ef          	jal	800051c2 <argfd>
    return -1;
    80005486:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005488:	02054163          	bltz	a0,800054aa <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    8000548c:	cfefc0ef          	jal	8000198a <myproc>
    80005490:	fec42783          	lw	a5,-20(s0)
    80005494:	078e                	slli	a5,a5,0x3
    80005496:	0d078793          	addi	a5,a5,208
    8000549a:	953e                	add	a0,a0,a5
    8000549c:	00053423          	sd	zero,8(a0)
  fileclose(f);
    800054a0:	fe043503          	ld	a0,-32(s0)
    800054a4:	b76ff0ef          	jal	8000481a <fileclose>
  return 0;
    800054a8:	4781                	li	a5,0
}
    800054aa:	853e                	mv	a0,a5
    800054ac:	60e2                	ld	ra,24(sp)
    800054ae:	6442                	ld	s0,16(sp)
    800054b0:	6105                	addi	sp,sp,32
    800054b2:	8082                	ret

00000000800054b4 <sys_fstat>:
{
    800054b4:	1101                	addi	sp,sp,-32
    800054b6:	ec06                	sd	ra,24(sp)
    800054b8:	e822                	sd	s0,16(sp)
    800054ba:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800054bc:	fe040593          	addi	a1,s0,-32
    800054c0:	4505                	li	a0,1
    800054c2:	d22fd0ef          	jal	800029e4 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800054c6:	fe840613          	addi	a2,s0,-24
    800054ca:	4581                	li	a1,0
    800054cc:	4501                	li	a0,0
    800054ce:	cf5ff0ef          	jal	800051c2 <argfd>
    800054d2:	87aa                	mv	a5,a0
    return -1;
    800054d4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054d6:	0007c863          	bltz	a5,800054e6 <sys_fstat+0x32>
  return filestat(f, st);
    800054da:	fe043583          	ld	a1,-32(s0)
    800054de:	fe843503          	ld	a0,-24(s0)
    800054e2:	bfaff0ef          	jal	800048dc <filestat>
}
    800054e6:	60e2                	ld	ra,24(sp)
    800054e8:	6442                	ld	s0,16(sp)
    800054ea:	6105                	addi	sp,sp,32
    800054ec:	8082                	ret

00000000800054ee <sys_link>:
{
    800054ee:	7169                	addi	sp,sp,-304
    800054f0:	f606                	sd	ra,296(sp)
    800054f2:	f222                	sd	s0,288(sp)
    800054f4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054f6:	08000613          	li	a2,128
    800054fa:	ed040593          	addi	a1,s0,-304
    800054fe:	4501                	li	a0,0
    80005500:	d00fd0ef          	jal	80002a00 <argstr>
    return -1;
    80005504:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005506:	0c054e63          	bltz	a0,800055e2 <sys_link+0xf4>
    8000550a:	08000613          	li	a2,128
    8000550e:	f5040593          	addi	a1,s0,-176
    80005512:	4505                	li	a0,1
    80005514:	cecfd0ef          	jal	80002a00 <argstr>
    return -1;
    80005518:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000551a:	0c054463          	bltz	a0,800055e2 <sys_link+0xf4>
    8000551e:	ee26                	sd	s1,280(sp)
  begin_op();
    80005520:	ed7fe0ef          	jal	800043f6 <begin_op>
  if((ip = namei(old)) == 0){
    80005524:	ed040513          	addi	a0,s0,-304
    80005528:	cf1fe0ef          	jal	80004218 <namei>
    8000552c:	84aa                	mv	s1,a0
    8000552e:	c53d                	beqz	a0,8000559c <sys_link+0xae>
  ilock(ip);
    80005530:	cbafe0ef          	jal	800039ea <ilock>
  if(ip->type == T_DIR){
    80005534:	04449703          	lh	a4,68(s1)
    80005538:	4785                	li	a5,1
    8000553a:	06f70663          	beq	a4,a5,800055a6 <sys_link+0xb8>
    8000553e:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005540:	04a4d783          	lhu	a5,74(s1)
    80005544:	2785                	addiw	a5,a5,1
    80005546:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000554a:	8526                	mv	a0,s1
    8000554c:	beafe0ef          	jal	80003936 <iupdate>
  iunlock(ip);
    80005550:	8526                	mv	a0,s1
    80005552:	d46fe0ef          	jal	80003a98 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005556:	fd040593          	addi	a1,s0,-48
    8000555a:	f5040513          	addi	a0,s0,-176
    8000555e:	cd5fe0ef          	jal	80004232 <nameiparent>
    80005562:	892a                	mv	s2,a0
    80005564:	cd21                	beqz	a0,800055bc <sys_link+0xce>
  ilock(dp);
    80005566:	c84fe0ef          	jal	800039ea <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000556a:	854a                	mv	a0,s2
    8000556c:	00092703          	lw	a4,0(s2)
    80005570:	409c                	lw	a5,0(s1)
    80005572:	04f71263          	bne	a4,a5,800055b6 <sys_link+0xc8>
    80005576:	40d0                	lw	a2,4(s1)
    80005578:	fd040593          	addi	a1,s0,-48
    8000557c:	bf3fe0ef          	jal	8000416e <dirlink>
    80005580:	02054b63          	bltz	a0,800055b6 <sys_link+0xc8>
  iunlockput(dp);
    80005584:	854a                	mv	a0,s2
    80005586:	e70fe0ef          	jal	80003bf6 <iunlockput>
  iput(ip);
    8000558a:	8526                	mv	a0,s1
    8000558c:	de0fe0ef          	jal	80003b6c <iput>
  end_op();
    80005590:	ed7fe0ef          	jal	80004466 <end_op>
  return 0;
    80005594:	4781                	li	a5,0
    80005596:	64f2                	ld	s1,280(sp)
    80005598:	6952                	ld	s2,272(sp)
    8000559a:	a0a1                	j	800055e2 <sys_link+0xf4>
    end_op();
    8000559c:	ecbfe0ef          	jal	80004466 <end_op>
    return -1;
    800055a0:	57fd                	li	a5,-1
    800055a2:	64f2                	ld	s1,280(sp)
    800055a4:	a83d                	j	800055e2 <sys_link+0xf4>
    iunlockput(ip);
    800055a6:	8526                	mv	a0,s1
    800055a8:	e4efe0ef          	jal	80003bf6 <iunlockput>
    end_op();
    800055ac:	ebbfe0ef          	jal	80004466 <end_op>
    return -1;
    800055b0:	57fd                	li	a5,-1
    800055b2:	64f2                	ld	s1,280(sp)
    800055b4:	a03d                	j	800055e2 <sys_link+0xf4>
    iunlockput(dp);
    800055b6:	854a                	mv	a0,s2
    800055b8:	e3efe0ef          	jal	80003bf6 <iunlockput>
  ilock(ip);
    800055bc:	8526                	mv	a0,s1
    800055be:	c2cfe0ef          	jal	800039ea <ilock>
  ip->nlink--;
    800055c2:	04a4d783          	lhu	a5,74(s1)
    800055c6:	37fd                	addiw	a5,a5,-1
    800055c8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055cc:	8526                	mv	a0,s1
    800055ce:	b68fe0ef          	jal	80003936 <iupdate>
  iunlockput(ip);
    800055d2:	8526                	mv	a0,s1
    800055d4:	e22fe0ef          	jal	80003bf6 <iunlockput>
  end_op();
    800055d8:	e8ffe0ef          	jal	80004466 <end_op>
  return -1;
    800055dc:	57fd                	li	a5,-1
    800055de:	64f2                	ld	s1,280(sp)
    800055e0:	6952                	ld	s2,272(sp)
}
    800055e2:	853e                	mv	a0,a5
    800055e4:	70b2                	ld	ra,296(sp)
    800055e6:	7412                	ld	s0,288(sp)
    800055e8:	6155                	addi	sp,sp,304
    800055ea:	8082                	ret

00000000800055ec <sys_unlink>:
{
    800055ec:	7151                	addi	sp,sp,-240
    800055ee:	f586                	sd	ra,232(sp)
    800055f0:	f1a2                	sd	s0,224(sp)
    800055f2:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800055f4:	08000613          	li	a2,128
    800055f8:	f3040593          	addi	a1,s0,-208
    800055fc:	4501                	li	a0,0
    800055fe:	c02fd0ef          	jal	80002a00 <argstr>
    80005602:	14054d63          	bltz	a0,8000575c <sys_unlink+0x170>
    80005606:	eda6                	sd	s1,216(sp)
  begin_op();
    80005608:	deffe0ef          	jal	800043f6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000560c:	fb040593          	addi	a1,s0,-80
    80005610:	f3040513          	addi	a0,s0,-208
    80005614:	c1ffe0ef          	jal	80004232 <nameiparent>
    80005618:	84aa                	mv	s1,a0
    8000561a:	c955                	beqz	a0,800056ce <sys_unlink+0xe2>
  ilock(dp);
    8000561c:	bcefe0ef          	jal	800039ea <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005620:	00003597          	auipc	a1,0x3
    80005624:	fd058593          	addi	a1,a1,-48 # 800085f0 <etext+0x5f0>
    80005628:	fb040513          	addi	a0,s0,-80
    8000562c:	943fe0ef          	jal	80003f6e <namecmp>
    80005630:	10050b63          	beqz	a0,80005746 <sys_unlink+0x15a>
    80005634:	00003597          	auipc	a1,0x3
    80005638:	fc458593          	addi	a1,a1,-60 # 800085f8 <etext+0x5f8>
    8000563c:	fb040513          	addi	a0,s0,-80
    80005640:	92ffe0ef          	jal	80003f6e <namecmp>
    80005644:	10050163          	beqz	a0,80005746 <sys_unlink+0x15a>
    80005648:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000564a:	f2c40613          	addi	a2,s0,-212
    8000564e:	fb040593          	addi	a1,s0,-80
    80005652:	8526                	mv	a0,s1
    80005654:	931fe0ef          	jal	80003f84 <dirlookup>
    80005658:	892a                	mv	s2,a0
    8000565a:	0e050563          	beqz	a0,80005744 <sys_unlink+0x158>
    8000565e:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005660:	b8afe0ef          	jal	800039ea <ilock>
  if(ip->nlink < 1)
    80005664:	04a91783          	lh	a5,74(s2)
    80005668:	06f05863          	blez	a5,800056d8 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000566c:	04491703          	lh	a4,68(s2)
    80005670:	4785                	li	a5,1
    80005672:	06f70963          	beq	a4,a5,800056e4 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005676:	fc040993          	addi	s3,s0,-64
    8000567a:	4641                	li	a2,16
    8000567c:	4581                	li	a1,0
    8000567e:	854e                	mv	a0,s3
    80005680:	e78fb0ef          	jal	80000cf8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005684:	4741                	li	a4,16
    80005686:	f2c42683          	lw	a3,-212(s0)
    8000568a:	864e                	mv	a2,s3
    8000568c:	4581                	li	a1,0
    8000568e:	8526                	mv	a0,s1
    80005690:	fdefe0ef          	jal	80003e6e <writei>
    80005694:	47c1                	li	a5,16
    80005696:	08f51863          	bne	a0,a5,80005726 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    8000569a:	04491703          	lh	a4,68(s2)
    8000569e:	4785                	li	a5,1
    800056a0:	08f70963          	beq	a4,a5,80005732 <sys_unlink+0x146>
  iunlockput(dp);
    800056a4:	8526                	mv	a0,s1
    800056a6:	d50fe0ef          	jal	80003bf6 <iunlockput>
  ip->nlink--;
    800056aa:	04a95783          	lhu	a5,74(s2)
    800056ae:	37fd                	addiw	a5,a5,-1
    800056b0:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800056b4:	854a                	mv	a0,s2
    800056b6:	a80fe0ef          	jal	80003936 <iupdate>
  iunlockput(ip);
    800056ba:	854a                	mv	a0,s2
    800056bc:	d3afe0ef          	jal	80003bf6 <iunlockput>
  end_op();
    800056c0:	da7fe0ef          	jal	80004466 <end_op>
  return 0;
    800056c4:	4501                	li	a0,0
    800056c6:	64ee                	ld	s1,216(sp)
    800056c8:	694e                	ld	s2,208(sp)
    800056ca:	69ae                	ld	s3,200(sp)
    800056cc:	a061                	j	80005754 <sys_unlink+0x168>
    end_op();
    800056ce:	d99fe0ef          	jal	80004466 <end_op>
    return -1;
    800056d2:	557d                	li	a0,-1
    800056d4:	64ee                	ld	s1,216(sp)
    800056d6:	a8bd                	j	80005754 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800056d8:	00003517          	auipc	a0,0x3
    800056dc:	f2850513          	addi	a0,a0,-216 # 80008600 <etext+0x600>
    800056e0:	944fb0ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056e4:	04c92703          	lw	a4,76(s2)
    800056e8:	02000793          	li	a5,32
    800056ec:	f8e7f5e3          	bgeu	a5,a4,80005676 <sys_unlink+0x8a>
    800056f0:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056f2:	4741                	li	a4,16
    800056f4:	86ce                	mv	a3,s3
    800056f6:	f1840613          	addi	a2,s0,-232
    800056fa:	4581                	li	a1,0
    800056fc:	854a                	mv	a0,s2
    800056fe:	e7efe0ef          	jal	80003d7c <readi>
    80005702:	47c1                	li	a5,16
    80005704:	00f51b63          	bne	a0,a5,8000571a <sys_unlink+0x12e>
    if(de.inum != 0)
    80005708:	f1845783          	lhu	a5,-232(s0)
    8000570c:	ebb1                	bnez	a5,80005760 <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000570e:	29c1                	addiw	s3,s3,16
    80005710:	04c92783          	lw	a5,76(s2)
    80005714:	fcf9efe3          	bltu	s3,a5,800056f2 <sys_unlink+0x106>
    80005718:	bfb9                	j	80005676 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    8000571a:	00003517          	auipc	a0,0x3
    8000571e:	efe50513          	addi	a0,a0,-258 # 80008618 <etext+0x618>
    80005722:	902fb0ef          	jal	80000824 <panic>
    panic("unlink: writei");
    80005726:	00003517          	auipc	a0,0x3
    8000572a:	f0a50513          	addi	a0,a0,-246 # 80008630 <etext+0x630>
    8000572e:	8f6fb0ef          	jal	80000824 <panic>
    dp->nlink--;
    80005732:	04a4d783          	lhu	a5,74(s1)
    80005736:	37fd                	addiw	a5,a5,-1
    80005738:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000573c:	8526                	mv	a0,s1
    8000573e:	9f8fe0ef          	jal	80003936 <iupdate>
    80005742:	b78d                	j	800056a4 <sys_unlink+0xb8>
    80005744:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005746:	8526                	mv	a0,s1
    80005748:	caefe0ef          	jal	80003bf6 <iunlockput>
  end_op();
    8000574c:	d1bfe0ef          	jal	80004466 <end_op>
  return -1;
    80005750:	557d                	li	a0,-1
    80005752:	64ee                	ld	s1,216(sp)
}
    80005754:	70ae                	ld	ra,232(sp)
    80005756:	740e                	ld	s0,224(sp)
    80005758:	616d                	addi	sp,sp,240
    8000575a:	8082                	ret
    return -1;
    8000575c:	557d                	li	a0,-1
    8000575e:	bfdd                	j	80005754 <sys_unlink+0x168>
    iunlockput(ip);
    80005760:	854a                	mv	a0,s2
    80005762:	c94fe0ef          	jal	80003bf6 <iunlockput>
    goto bad;
    80005766:	694e                	ld	s2,208(sp)
    80005768:	69ae                	ld	s3,200(sp)
    8000576a:	bff1                	j	80005746 <sys_unlink+0x15a>

000000008000576c <sys_open>:

uint64
sys_open(void)
{
    8000576c:	7131                	addi	sp,sp,-192
    8000576e:	fd06                	sd	ra,184(sp)
    80005770:	f922                	sd	s0,176(sp)
    80005772:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005774:	f4c40593          	addi	a1,s0,-180
    80005778:	4505                	li	a0,1
    8000577a:	a4efd0ef          	jal	800029c8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000577e:	08000613          	li	a2,128
    80005782:	f5040593          	addi	a1,s0,-176
    80005786:	4501                	li	a0,0
    80005788:	a78fd0ef          	jal	80002a00 <argstr>
    8000578c:	87aa                	mv	a5,a0
    return -1;
    8000578e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005790:	0a07c363          	bltz	a5,80005836 <sys_open+0xca>
    80005794:	f526                	sd	s1,168(sp)

  begin_op();
    80005796:	c61fe0ef          	jal	800043f6 <begin_op>

  if(omode & O_CREATE){
    8000579a:	f4c42783          	lw	a5,-180(s0)
    8000579e:	2007f793          	andi	a5,a5,512
    800057a2:	c3dd                	beqz	a5,80005848 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    800057a4:	4681                	li	a3,0
    800057a6:	4601                	li	a2,0
    800057a8:	4589                	li	a1,2
    800057aa:	f5040513          	addi	a0,s0,-176
    800057ae:	aafff0ef          	jal	8000525c <create>
    800057b2:	84aa                	mv	s1,a0
    if(ip == 0){
    800057b4:	c549                	beqz	a0,8000583e <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800057b6:	04449703          	lh	a4,68(s1)
    800057ba:	478d                	li	a5,3
    800057bc:	00f71763          	bne	a4,a5,800057ca <sys_open+0x5e>
    800057c0:	0464d703          	lhu	a4,70(s1)
    800057c4:	47a5                	li	a5,9
    800057c6:	0ae7ee63          	bltu	a5,a4,80005882 <sys_open+0x116>
    800057ca:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800057cc:	fabfe0ef          	jal	80004776 <filealloc>
    800057d0:	892a                	mv	s2,a0
    800057d2:	c561                	beqz	a0,8000589a <sys_open+0x12e>
    800057d4:	ed4e                	sd	s3,152(sp)
    800057d6:	a47ff0ef          	jal	8000521c <fdalloc>
    800057da:	89aa                	mv	s3,a0
    800057dc:	0a054b63          	bltz	a0,80005892 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800057e0:	04449703          	lh	a4,68(s1)
    800057e4:	478d                	li	a5,3
    800057e6:	0cf70363          	beq	a4,a5,800058ac <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800057ea:	4789                	li	a5,2
    800057ec:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800057f0:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800057f4:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800057f8:	f4c42783          	lw	a5,-180(s0)
    800057fc:	0017f713          	andi	a4,a5,1
    80005800:	00174713          	xori	a4,a4,1
    80005804:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005808:	0037f713          	andi	a4,a5,3
    8000580c:	00e03733          	snez	a4,a4
    80005810:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005814:	4007f793          	andi	a5,a5,1024
    80005818:	c791                	beqz	a5,80005824 <sys_open+0xb8>
    8000581a:	04449703          	lh	a4,68(s1)
    8000581e:	4789                	li	a5,2
    80005820:	08f70d63          	beq	a4,a5,800058ba <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80005824:	8526                	mv	a0,s1
    80005826:	a72fe0ef          	jal	80003a98 <iunlock>
  end_op();
    8000582a:	c3dfe0ef          	jal	80004466 <end_op>

  return fd;
    8000582e:	854e                	mv	a0,s3
    80005830:	74aa                	ld	s1,168(sp)
    80005832:	790a                	ld	s2,160(sp)
    80005834:	69ea                	ld	s3,152(sp)
}
    80005836:	70ea                	ld	ra,184(sp)
    80005838:	744a                	ld	s0,176(sp)
    8000583a:	6129                	addi	sp,sp,192
    8000583c:	8082                	ret
      end_op();
    8000583e:	c29fe0ef          	jal	80004466 <end_op>
      return -1;
    80005842:	557d                	li	a0,-1
    80005844:	74aa                	ld	s1,168(sp)
    80005846:	bfc5                	j	80005836 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80005848:	f5040513          	addi	a0,s0,-176
    8000584c:	9cdfe0ef          	jal	80004218 <namei>
    80005850:	84aa                	mv	s1,a0
    80005852:	c11d                	beqz	a0,80005878 <sys_open+0x10c>
    ilock(ip);
    80005854:	996fe0ef          	jal	800039ea <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005858:	04449703          	lh	a4,68(s1)
    8000585c:	4785                	li	a5,1
    8000585e:	f4f71ce3          	bne	a4,a5,800057b6 <sys_open+0x4a>
    80005862:	f4c42783          	lw	a5,-180(s0)
    80005866:	d3b5                	beqz	a5,800057ca <sys_open+0x5e>
      iunlockput(ip);
    80005868:	8526                	mv	a0,s1
    8000586a:	b8cfe0ef          	jal	80003bf6 <iunlockput>
      end_op();
    8000586e:	bf9fe0ef          	jal	80004466 <end_op>
      return -1;
    80005872:	557d                	li	a0,-1
    80005874:	74aa                	ld	s1,168(sp)
    80005876:	b7c1                	j	80005836 <sys_open+0xca>
      end_op();
    80005878:	beffe0ef          	jal	80004466 <end_op>
      return -1;
    8000587c:	557d                	li	a0,-1
    8000587e:	74aa                	ld	s1,168(sp)
    80005880:	bf5d                	j	80005836 <sys_open+0xca>
    iunlockput(ip);
    80005882:	8526                	mv	a0,s1
    80005884:	b72fe0ef          	jal	80003bf6 <iunlockput>
    end_op();
    80005888:	bdffe0ef          	jal	80004466 <end_op>
    return -1;
    8000588c:	557d                	li	a0,-1
    8000588e:	74aa                	ld	s1,168(sp)
    80005890:	b75d                	j	80005836 <sys_open+0xca>
      fileclose(f);
    80005892:	854a                	mv	a0,s2
    80005894:	f87fe0ef          	jal	8000481a <fileclose>
    80005898:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000589a:	8526                	mv	a0,s1
    8000589c:	b5afe0ef          	jal	80003bf6 <iunlockput>
    end_op();
    800058a0:	bc7fe0ef          	jal	80004466 <end_op>
    return -1;
    800058a4:	557d                	li	a0,-1
    800058a6:	74aa                	ld	s1,168(sp)
    800058a8:	790a                	ld	s2,160(sp)
    800058aa:	b771                	j	80005836 <sys_open+0xca>
    f->type = FD_DEVICE;
    800058ac:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    800058b0:	04649783          	lh	a5,70(s1)
    800058b4:	02f91223          	sh	a5,36(s2)
    800058b8:	bf35                	j	800057f4 <sys_open+0x88>
    itrunc(ip);
    800058ba:	8526                	mv	a0,s1
    800058bc:	a1cfe0ef          	jal	80003ad8 <itrunc>
    800058c0:	b795                	j	80005824 <sys_open+0xb8>

00000000800058c2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800058c2:	7175                	addi	sp,sp,-144
    800058c4:	e506                	sd	ra,136(sp)
    800058c6:	e122                	sd	s0,128(sp)
    800058c8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800058ca:	b2dfe0ef          	jal	800043f6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800058ce:	08000613          	li	a2,128
    800058d2:	f7040593          	addi	a1,s0,-144
    800058d6:	4501                	li	a0,0
    800058d8:	928fd0ef          	jal	80002a00 <argstr>
    800058dc:	02054363          	bltz	a0,80005902 <sys_mkdir+0x40>
    800058e0:	4681                	li	a3,0
    800058e2:	4601                	li	a2,0
    800058e4:	4585                	li	a1,1
    800058e6:	f7040513          	addi	a0,s0,-144
    800058ea:	973ff0ef          	jal	8000525c <create>
    800058ee:	c911                	beqz	a0,80005902 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058f0:	b06fe0ef          	jal	80003bf6 <iunlockput>
  end_op();
    800058f4:	b73fe0ef          	jal	80004466 <end_op>
  return 0;
    800058f8:	4501                	li	a0,0
}
    800058fa:	60aa                	ld	ra,136(sp)
    800058fc:	640a                	ld	s0,128(sp)
    800058fe:	6149                	addi	sp,sp,144
    80005900:	8082                	ret
    end_op();
    80005902:	b65fe0ef          	jal	80004466 <end_op>
    return -1;
    80005906:	557d                	li	a0,-1
    80005908:	bfcd                	j	800058fa <sys_mkdir+0x38>

000000008000590a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000590a:	7135                	addi	sp,sp,-160
    8000590c:	ed06                	sd	ra,152(sp)
    8000590e:	e922                	sd	s0,144(sp)
    80005910:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005912:	ae5fe0ef          	jal	800043f6 <begin_op>
  argint(1, &major);
    80005916:	f6c40593          	addi	a1,s0,-148
    8000591a:	4505                	li	a0,1
    8000591c:	8acfd0ef          	jal	800029c8 <argint>
  argint(2, &minor);
    80005920:	f6840593          	addi	a1,s0,-152
    80005924:	4509                	li	a0,2
    80005926:	8a2fd0ef          	jal	800029c8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000592a:	08000613          	li	a2,128
    8000592e:	f7040593          	addi	a1,s0,-144
    80005932:	4501                	li	a0,0
    80005934:	8ccfd0ef          	jal	80002a00 <argstr>
    80005938:	02054563          	bltz	a0,80005962 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000593c:	f6841683          	lh	a3,-152(s0)
    80005940:	f6c41603          	lh	a2,-148(s0)
    80005944:	458d                	li	a1,3
    80005946:	f7040513          	addi	a0,s0,-144
    8000594a:	913ff0ef          	jal	8000525c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000594e:	c911                	beqz	a0,80005962 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005950:	aa6fe0ef          	jal	80003bf6 <iunlockput>
  end_op();
    80005954:	b13fe0ef          	jal	80004466 <end_op>
  return 0;
    80005958:	4501                	li	a0,0
}
    8000595a:	60ea                	ld	ra,152(sp)
    8000595c:	644a                	ld	s0,144(sp)
    8000595e:	610d                	addi	sp,sp,160
    80005960:	8082                	ret
    end_op();
    80005962:	b05fe0ef          	jal	80004466 <end_op>
    return -1;
    80005966:	557d                	li	a0,-1
    80005968:	bfcd                	j	8000595a <sys_mknod+0x50>

000000008000596a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000596a:	7135                	addi	sp,sp,-160
    8000596c:	ed06                	sd	ra,152(sp)
    8000596e:	e922                	sd	s0,144(sp)
    80005970:	e14a                	sd	s2,128(sp)
    80005972:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005974:	816fc0ef          	jal	8000198a <myproc>
    80005978:	892a                	mv	s2,a0
  
  begin_op();
    8000597a:	a7dfe0ef          	jal	800043f6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000597e:	08000613          	li	a2,128
    80005982:	f6040593          	addi	a1,s0,-160
    80005986:	4501                	li	a0,0
    80005988:	878fd0ef          	jal	80002a00 <argstr>
    8000598c:	04054363          	bltz	a0,800059d2 <sys_chdir+0x68>
    80005990:	e526                	sd	s1,136(sp)
    80005992:	f6040513          	addi	a0,s0,-160
    80005996:	883fe0ef          	jal	80004218 <namei>
    8000599a:	84aa                	mv	s1,a0
    8000599c:	c915                	beqz	a0,800059d0 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000599e:	84cfe0ef          	jal	800039ea <ilock>
  if(ip->type != T_DIR){
    800059a2:	04449703          	lh	a4,68(s1)
    800059a6:	4785                	li	a5,1
    800059a8:	02f71963          	bne	a4,a5,800059da <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800059ac:	8526                	mv	a0,s1
    800059ae:	8eafe0ef          	jal	80003a98 <iunlock>
  iput(p->cwd);
    800059b2:	15893503          	ld	a0,344(s2)
    800059b6:	9b6fe0ef          	jal	80003b6c <iput>
  end_op();
    800059ba:	aadfe0ef          	jal	80004466 <end_op>
  p->cwd = ip;
    800059be:	14993c23          	sd	s1,344(s2)
  return 0;
    800059c2:	4501                	li	a0,0
    800059c4:	64aa                	ld	s1,136(sp)
}
    800059c6:	60ea                	ld	ra,152(sp)
    800059c8:	644a                	ld	s0,144(sp)
    800059ca:	690a                	ld	s2,128(sp)
    800059cc:	610d                	addi	sp,sp,160
    800059ce:	8082                	ret
    800059d0:	64aa                	ld	s1,136(sp)
    end_op();
    800059d2:	a95fe0ef          	jal	80004466 <end_op>
    return -1;
    800059d6:	557d                	li	a0,-1
    800059d8:	b7fd                	j	800059c6 <sys_chdir+0x5c>
    iunlockput(ip);
    800059da:	8526                	mv	a0,s1
    800059dc:	a1afe0ef          	jal	80003bf6 <iunlockput>
    end_op();
    800059e0:	a87fe0ef          	jal	80004466 <end_op>
    return -1;
    800059e4:	557d                	li	a0,-1
    800059e6:	64aa                	ld	s1,136(sp)
    800059e8:	bff9                	j	800059c6 <sys_chdir+0x5c>

00000000800059ea <sys_exec>:

uint64
sys_exec(void)
{
    800059ea:	7105                	addi	sp,sp,-480
    800059ec:	ef86                	sd	ra,472(sp)
    800059ee:	eba2                	sd	s0,464(sp)
    800059f0:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800059f2:	e2840593          	addi	a1,s0,-472
    800059f6:	4505                	li	a0,1
    800059f8:	fedfc0ef          	jal	800029e4 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800059fc:	08000613          	li	a2,128
    80005a00:	f3040593          	addi	a1,s0,-208
    80005a04:	4501                	li	a0,0
    80005a06:	ffbfc0ef          	jal	80002a00 <argstr>
    80005a0a:	87aa                	mv	a5,a0
    return -1;
    80005a0c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005a0e:	0e07c063          	bltz	a5,80005aee <sys_exec+0x104>
    80005a12:	e7a6                	sd	s1,456(sp)
    80005a14:	e3ca                	sd	s2,448(sp)
    80005a16:	ff4e                	sd	s3,440(sp)
    80005a18:	fb52                	sd	s4,432(sp)
    80005a1a:	f756                	sd	s5,424(sp)
    80005a1c:	f35a                	sd	s6,416(sp)
    80005a1e:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005a20:	e3040a13          	addi	s4,s0,-464
    80005a24:	10000613          	li	a2,256
    80005a28:	4581                	li	a1,0
    80005a2a:	8552                	mv	a0,s4
    80005a2c:	accfb0ef          	jal	80000cf8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a30:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005a32:	89d2                	mv	s3,s4
    80005a34:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a36:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a3a:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80005a3c:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a40:	00391513          	slli	a0,s2,0x3
    80005a44:	85d6                	mv	a1,s5
    80005a46:	e2843783          	ld	a5,-472(s0)
    80005a4a:	953e                	add	a0,a0,a5
    80005a4c:	ef3fc0ef          	jal	8000293e <fetchaddr>
    80005a50:	02054663          	bltz	a0,80005a7c <sys_exec+0x92>
    if(uarg == 0){
    80005a54:	e2043783          	ld	a5,-480(s0)
    80005a58:	c7a1                	beqz	a5,80005aa0 <sys_exec+0xb6>
    argv[i] = kalloc();
    80005a5a:	8eafb0ef          	jal	80000b44 <kalloc>
    80005a5e:	85aa                	mv	a1,a0
    80005a60:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a64:	cd01                	beqz	a0,80005a7c <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a66:	865a                	mv	a2,s6
    80005a68:	e2043503          	ld	a0,-480(s0)
    80005a6c:	f1dfc0ef          	jal	80002988 <fetchstr>
    80005a70:	00054663          	bltz	a0,80005a7c <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005a74:	0905                	addi	s2,s2,1
    80005a76:	09a1                	addi	s3,s3,8
    80005a78:	fd7914e3          	bne	s2,s7,80005a40 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a7c:	100a0a13          	addi	s4,s4,256
    80005a80:	6088                	ld	a0,0(s1)
    80005a82:	cd31                	beqz	a0,80005ade <sys_exec+0xf4>
    kfree(argv[i]);
    80005a84:	fd9fa0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a88:	04a1                	addi	s1,s1,8
    80005a8a:	ff449be3          	bne	s1,s4,80005a80 <sys_exec+0x96>
  return -1;
    80005a8e:	557d                	li	a0,-1
    80005a90:	64be                	ld	s1,456(sp)
    80005a92:	691e                	ld	s2,448(sp)
    80005a94:	79fa                	ld	s3,440(sp)
    80005a96:	7a5a                	ld	s4,432(sp)
    80005a98:	7aba                	ld	s5,424(sp)
    80005a9a:	7b1a                	ld	s6,416(sp)
    80005a9c:	6bfa                	ld	s7,408(sp)
    80005a9e:	a881                	j	80005aee <sys_exec+0x104>
      argv[i] = 0;
    80005aa0:	0009079b          	sext.w	a5,s2
    80005aa4:	e3040593          	addi	a1,s0,-464
    80005aa8:	078e                	slli	a5,a5,0x3
    80005aaa:	97ae                	add	a5,a5,a1
    80005aac:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005ab0:	f3040513          	addi	a0,s0,-208
    80005ab4:	bb2ff0ef          	jal	80004e66 <kexec>
    80005ab8:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005aba:	100a0a13          	addi	s4,s4,256
    80005abe:	6088                	ld	a0,0(s1)
    80005ac0:	c511                	beqz	a0,80005acc <sys_exec+0xe2>
    kfree(argv[i]);
    80005ac2:	f9bfa0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ac6:	04a1                	addi	s1,s1,8
    80005ac8:	ff449be3          	bne	s1,s4,80005abe <sys_exec+0xd4>
  return ret;
    80005acc:	854a                	mv	a0,s2
    80005ace:	64be                	ld	s1,456(sp)
    80005ad0:	691e                	ld	s2,448(sp)
    80005ad2:	79fa                	ld	s3,440(sp)
    80005ad4:	7a5a                	ld	s4,432(sp)
    80005ad6:	7aba                	ld	s5,424(sp)
    80005ad8:	7b1a                	ld	s6,416(sp)
    80005ada:	6bfa                	ld	s7,408(sp)
    80005adc:	a809                	j	80005aee <sys_exec+0x104>
  return -1;
    80005ade:	557d                	li	a0,-1
    80005ae0:	64be                	ld	s1,456(sp)
    80005ae2:	691e                	ld	s2,448(sp)
    80005ae4:	79fa                	ld	s3,440(sp)
    80005ae6:	7a5a                	ld	s4,432(sp)
    80005ae8:	7aba                	ld	s5,424(sp)
    80005aea:	7b1a                	ld	s6,416(sp)
    80005aec:	6bfa                	ld	s7,408(sp)
}
    80005aee:	60fe                	ld	ra,472(sp)
    80005af0:	645e                	ld	s0,464(sp)
    80005af2:	613d                	addi	sp,sp,480
    80005af4:	8082                	ret

0000000080005af6 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005af6:	7139                	addi	sp,sp,-64
    80005af8:	fc06                	sd	ra,56(sp)
    80005afa:	f822                	sd	s0,48(sp)
    80005afc:	f426                	sd	s1,40(sp)
    80005afe:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b00:	e8bfb0ef          	jal	8000198a <myproc>
    80005b04:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005b06:	fd840593          	addi	a1,s0,-40
    80005b0a:	4501                	li	a0,0
    80005b0c:	ed9fc0ef          	jal	800029e4 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005b10:	fc840593          	addi	a1,s0,-56
    80005b14:	fd040513          	addi	a0,s0,-48
    80005b18:	81eff0ef          	jal	80004b36 <pipealloc>
    return -1;
    80005b1c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b1e:	0a054763          	bltz	a0,80005bcc <sys_pipe+0xd6>
  fd0 = -1;
    80005b22:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b26:	fd043503          	ld	a0,-48(s0)
    80005b2a:	ef2ff0ef          	jal	8000521c <fdalloc>
    80005b2e:	fca42223          	sw	a0,-60(s0)
    80005b32:	08054463          	bltz	a0,80005bba <sys_pipe+0xc4>
    80005b36:	fc843503          	ld	a0,-56(s0)
    80005b3a:	ee2ff0ef          	jal	8000521c <fdalloc>
    80005b3e:	fca42023          	sw	a0,-64(s0)
    80005b42:	06054263          	bltz	a0,80005ba6 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b46:	4691                	li	a3,4
    80005b48:	fc440613          	addi	a2,s0,-60
    80005b4c:	fd843583          	ld	a1,-40(s0)
    80005b50:	6ca8                	ld	a0,88(s1)
    80005b52:	b03fb0ef          	jal	80001654 <copyout>
    80005b56:	00054e63          	bltz	a0,80005b72 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b5a:	4691                	li	a3,4
    80005b5c:	fc040613          	addi	a2,s0,-64
    80005b60:	fd843583          	ld	a1,-40(s0)
    80005b64:	95b6                	add	a1,a1,a3
    80005b66:	6ca8                	ld	a0,88(s1)
    80005b68:	aedfb0ef          	jal	80001654 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b6c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b6e:	04055f63          	bgez	a0,80005bcc <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    80005b72:	fc442783          	lw	a5,-60(s0)
    80005b76:	078e                	slli	a5,a5,0x3
    80005b78:	0d078793          	addi	a5,a5,208
    80005b7c:	97a6                	add	a5,a5,s1
    80005b7e:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005b82:	fc042783          	lw	a5,-64(s0)
    80005b86:	078e                	slli	a5,a5,0x3
    80005b88:	0d078793          	addi	a5,a5,208
    80005b8c:	97a6                	add	a5,a5,s1
    80005b8e:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80005b92:	fd043503          	ld	a0,-48(s0)
    80005b96:	c85fe0ef          	jal	8000481a <fileclose>
    fileclose(wf);
    80005b9a:	fc843503          	ld	a0,-56(s0)
    80005b9e:	c7dfe0ef          	jal	8000481a <fileclose>
    return -1;
    80005ba2:	57fd                	li	a5,-1
    80005ba4:	a025                	j	80005bcc <sys_pipe+0xd6>
    if(fd0 >= 0)
    80005ba6:	fc442783          	lw	a5,-60(s0)
    80005baa:	0007c863          	bltz	a5,80005bba <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    80005bae:	078e                	slli	a5,a5,0x3
    80005bb0:	0d078793          	addi	a5,a5,208
    80005bb4:	97a6                	add	a5,a5,s1
    80005bb6:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80005bba:	fd043503          	ld	a0,-48(s0)
    80005bbe:	c5dfe0ef          	jal	8000481a <fileclose>
    fileclose(wf);
    80005bc2:	fc843503          	ld	a0,-56(s0)
    80005bc6:	c55fe0ef          	jal	8000481a <fileclose>
    return -1;
    80005bca:	57fd                	li	a5,-1
}
    80005bcc:	853e                	mv	a0,a5
    80005bce:	70e2                	ld	ra,56(sp)
    80005bd0:	7442                	ld	s0,48(sp)
    80005bd2:	74a2                	ld	s1,40(sp)
    80005bd4:	6121                	addi	sp,sp,64
    80005bd6:	8082                	ret
	...

0000000080005be0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005be0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005be2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005be4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005be6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005be8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005bea:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005bec:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005bee:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005bf0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005bf2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005bf4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005bf6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005bf8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005bfa:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005bfc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005bfe:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005c00:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005c02:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005c04:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005c06:	c47fc0ef          	jal	8000284c <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005c0a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005c0c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005c0e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005c10:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005c12:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005c14:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005c16:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005c18:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005c1a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005c1c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005c1e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005c20:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005c22:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005c24:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005c26:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005c28:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005c2a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005c2c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005c2e:	10200073          	sret
    80005c32:	00000013          	nop
    80005c36:	00000013          	nop
    80005c3a:	00000013          	nop

0000000080005c3e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005c3e:	1141                	addi	sp,sp,-16
    80005c40:	e406                	sd	ra,8(sp)
    80005c42:	e022                	sd	s0,0(sp)
    80005c44:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005c46:	0c000737          	lui	a4,0xc000
    80005c4a:	4785                	li	a5,1
    80005c4c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005c4e:	c35c                	sw	a5,4(a4)
}
    80005c50:	60a2                	ld	ra,8(sp)
    80005c52:	6402                	ld	s0,0(sp)
    80005c54:	0141                	addi	sp,sp,16
    80005c56:	8082                	ret

0000000080005c58 <plicinithart>:

void
plicinithart(void)
{
    80005c58:	1141                	addi	sp,sp,-16
    80005c5a:	e406                	sd	ra,8(sp)
    80005c5c:	e022                	sd	s0,0(sp)
    80005c5e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c60:	cf7fb0ef          	jal	80001956 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005c64:	0085171b          	slliw	a4,a0,0x8
    80005c68:	0c0027b7          	lui	a5,0xc002
    80005c6c:	97ba                	add	a5,a5,a4
    80005c6e:	40200713          	li	a4,1026
    80005c72:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005c76:	00d5151b          	slliw	a0,a0,0xd
    80005c7a:	0c2017b7          	lui	a5,0xc201
    80005c7e:	97aa                	add	a5,a5,a0
    80005c80:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005c84:	60a2                	ld	ra,8(sp)
    80005c86:	6402                	ld	s0,0(sp)
    80005c88:	0141                	addi	sp,sp,16
    80005c8a:	8082                	ret

0000000080005c8c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005c8c:	1141                	addi	sp,sp,-16
    80005c8e:	e406                	sd	ra,8(sp)
    80005c90:	e022                	sd	s0,0(sp)
    80005c92:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c94:	cc3fb0ef          	jal	80001956 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005c98:	00d5151b          	slliw	a0,a0,0xd
    80005c9c:	0c2017b7          	lui	a5,0xc201
    80005ca0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005ca2:	43c8                	lw	a0,4(a5)
    80005ca4:	60a2                	ld	ra,8(sp)
    80005ca6:	6402                	ld	s0,0(sp)
    80005ca8:	0141                	addi	sp,sp,16
    80005caa:	8082                	ret

0000000080005cac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005cac:	1101                	addi	sp,sp,-32
    80005cae:	ec06                	sd	ra,24(sp)
    80005cb0:	e822                	sd	s0,16(sp)
    80005cb2:	e426                	sd	s1,8(sp)
    80005cb4:	1000                	addi	s0,sp,32
    80005cb6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005cb8:	c9ffb0ef          	jal	80001956 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005cbc:	00d5179b          	slliw	a5,a0,0xd
    80005cc0:	0c201737          	lui	a4,0xc201
    80005cc4:	97ba                	add	a5,a5,a4
    80005cc6:	c3c4                	sw	s1,4(a5)
}
    80005cc8:	60e2                	ld	ra,24(sp)
    80005cca:	6442                	ld	s0,16(sp)
    80005ccc:	64a2                	ld	s1,8(sp)
    80005cce:	6105                	addi	sp,sp,32
    80005cd0:	8082                	ret

0000000080005cd2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005cd2:	1141                	addi	sp,sp,-16
    80005cd4:	e406                	sd	ra,8(sp)
    80005cd6:	e022                	sd	s0,0(sp)
    80005cd8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005cda:	479d                	li	a5,7
    80005cdc:	04a7ca63          	blt	a5,a0,80005d30 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005ce0:	00062797          	auipc	a5,0x62
    80005ce4:	e4878793          	addi	a5,a5,-440 # 80067b28 <disk>
    80005ce8:	97aa                	add	a5,a5,a0
    80005cea:	0187c783          	lbu	a5,24(a5)
    80005cee:	e7b9                	bnez	a5,80005d3c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005cf0:	00451693          	slli	a3,a0,0x4
    80005cf4:	00062797          	auipc	a5,0x62
    80005cf8:	e3478793          	addi	a5,a5,-460 # 80067b28 <disk>
    80005cfc:	6398                	ld	a4,0(a5)
    80005cfe:	9736                	add	a4,a4,a3
    80005d00:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005d04:	6398                	ld	a4,0(a5)
    80005d06:	9736                	add	a4,a4,a3
    80005d08:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005d0c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005d10:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005d14:	97aa                	add	a5,a5,a0
    80005d16:	4705                	li	a4,1
    80005d18:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005d1c:	00062517          	auipc	a0,0x62
    80005d20:	e2450513          	addi	a0,a0,-476 # 80067b40 <disk+0x18>
    80005d24:	bc2fc0ef          	jal	800020e6 <wakeup>
}
    80005d28:	60a2                	ld	ra,8(sp)
    80005d2a:	6402                	ld	s0,0(sp)
    80005d2c:	0141                	addi	sp,sp,16
    80005d2e:	8082                	ret
    panic("free_desc 1");
    80005d30:	00003517          	auipc	a0,0x3
    80005d34:	91050513          	addi	a0,a0,-1776 # 80008640 <etext+0x640>
    80005d38:	aedfa0ef          	jal	80000824 <panic>
    panic("free_desc 2");
    80005d3c:	00003517          	auipc	a0,0x3
    80005d40:	91450513          	addi	a0,a0,-1772 # 80008650 <etext+0x650>
    80005d44:	ae1fa0ef          	jal	80000824 <panic>

0000000080005d48 <virtio_disk_init>:
{
    80005d48:	1101                	addi	sp,sp,-32
    80005d4a:	ec06                	sd	ra,24(sp)
    80005d4c:	e822                	sd	s0,16(sp)
    80005d4e:	e426                	sd	s1,8(sp)
    80005d50:	e04a                	sd	s2,0(sp)
    80005d52:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005d54:	00003597          	auipc	a1,0x3
    80005d58:	90c58593          	addi	a1,a1,-1780 # 80008660 <etext+0x660>
    80005d5c:	00062517          	auipc	a0,0x62
    80005d60:	ef450513          	addi	a0,a0,-268 # 80067c50 <disk+0x128>
    80005d64:	e3bfa0ef          	jal	80000b9e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d68:	100017b7          	lui	a5,0x10001
    80005d6c:	4398                	lw	a4,0(a5)
    80005d6e:	2701                	sext.w	a4,a4
    80005d70:	747277b7          	lui	a5,0x74727
    80005d74:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005d78:	14f71863          	bne	a4,a5,80005ec8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005d7c:	100017b7          	lui	a5,0x10001
    80005d80:	43dc                	lw	a5,4(a5)
    80005d82:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d84:	4709                	li	a4,2
    80005d86:	14e79163          	bne	a5,a4,80005ec8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d8a:	100017b7          	lui	a5,0x10001
    80005d8e:	479c                	lw	a5,8(a5)
    80005d90:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005d92:	12e79b63          	bne	a5,a4,80005ec8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005d96:	100017b7          	lui	a5,0x10001
    80005d9a:	47d8                	lw	a4,12(a5)
    80005d9c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d9e:	554d47b7          	lui	a5,0x554d4
    80005da2:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005da6:	12f71163          	bne	a4,a5,80005ec8 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005daa:	100017b7          	lui	a5,0x10001
    80005dae:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005db2:	4705                	li	a4,1
    80005db4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005db6:	470d                	li	a4,3
    80005db8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005dba:	10001737          	lui	a4,0x10001
    80005dbe:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005dc0:	c7ffe6b7          	lui	a3,0xc7ffe
    80005dc4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47f96af7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005dc8:	8f75                	and	a4,a4,a3
    80005dca:	100016b7          	lui	a3,0x10001
    80005dce:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dd0:	472d                	li	a4,11
    80005dd2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dd4:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005dd8:	439c                	lw	a5,0(a5)
    80005dda:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005dde:	8ba1                	andi	a5,a5,8
    80005de0:	0e078a63          	beqz	a5,80005ed4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005de4:	100017b7          	lui	a5,0x10001
    80005de8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005dec:	43fc                	lw	a5,68(a5)
    80005dee:	2781                	sext.w	a5,a5
    80005df0:	0e079863          	bnez	a5,80005ee0 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005df4:	100017b7          	lui	a5,0x10001
    80005df8:	5bdc                	lw	a5,52(a5)
    80005dfa:	2781                	sext.w	a5,a5
  if(max == 0)
    80005dfc:	0e078863          	beqz	a5,80005eec <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005e00:	471d                	li	a4,7
    80005e02:	0ef77b63          	bgeu	a4,a5,80005ef8 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005e06:	d3ffa0ef          	jal	80000b44 <kalloc>
    80005e0a:	00062497          	auipc	s1,0x62
    80005e0e:	d1e48493          	addi	s1,s1,-738 # 80067b28 <disk>
    80005e12:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005e14:	d31fa0ef          	jal	80000b44 <kalloc>
    80005e18:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005e1a:	d2bfa0ef          	jal	80000b44 <kalloc>
    80005e1e:	87aa                	mv	a5,a0
    80005e20:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005e22:	6088                	ld	a0,0(s1)
    80005e24:	0e050063          	beqz	a0,80005f04 <virtio_disk_init+0x1bc>
    80005e28:	00062717          	auipc	a4,0x62
    80005e2c:	d0873703          	ld	a4,-760(a4) # 80067b30 <disk+0x8>
    80005e30:	cb71                	beqz	a4,80005f04 <virtio_disk_init+0x1bc>
    80005e32:	cbe9                	beqz	a5,80005f04 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005e34:	6605                	lui	a2,0x1
    80005e36:	4581                	li	a1,0
    80005e38:	ec1fa0ef          	jal	80000cf8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005e3c:	00062497          	auipc	s1,0x62
    80005e40:	cec48493          	addi	s1,s1,-788 # 80067b28 <disk>
    80005e44:	6605                	lui	a2,0x1
    80005e46:	4581                	li	a1,0
    80005e48:	6488                	ld	a0,8(s1)
    80005e4a:	eaffa0ef          	jal	80000cf8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005e4e:	6605                	lui	a2,0x1
    80005e50:	4581                	li	a1,0
    80005e52:	6888                	ld	a0,16(s1)
    80005e54:	ea5fa0ef          	jal	80000cf8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005e58:	100017b7          	lui	a5,0x10001
    80005e5c:	4721                	li	a4,8
    80005e5e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005e60:	4098                	lw	a4,0(s1)
    80005e62:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005e66:	40d8                	lw	a4,4(s1)
    80005e68:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005e6c:	649c                	ld	a5,8(s1)
    80005e6e:	0007869b          	sext.w	a3,a5
    80005e72:	10001737          	lui	a4,0x10001
    80005e76:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005e7a:	9781                	srai	a5,a5,0x20
    80005e7c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005e80:	689c                	ld	a5,16(s1)
    80005e82:	0007869b          	sext.w	a3,a5
    80005e86:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005e8a:	9781                	srai	a5,a5,0x20
    80005e8c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005e90:	4785                	li	a5,1
    80005e92:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005e94:	00f48c23          	sb	a5,24(s1)
    80005e98:	00f48ca3          	sb	a5,25(s1)
    80005e9c:	00f48d23          	sb	a5,26(s1)
    80005ea0:	00f48da3          	sb	a5,27(s1)
    80005ea4:	00f48e23          	sb	a5,28(s1)
    80005ea8:	00f48ea3          	sb	a5,29(s1)
    80005eac:	00f48f23          	sb	a5,30(s1)
    80005eb0:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005eb4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005eb8:	07272823          	sw	s2,112(a4)
}
    80005ebc:	60e2                	ld	ra,24(sp)
    80005ebe:	6442                	ld	s0,16(sp)
    80005ec0:	64a2                	ld	s1,8(sp)
    80005ec2:	6902                	ld	s2,0(sp)
    80005ec4:	6105                	addi	sp,sp,32
    80005ec6:	8082                	ret
    panic("could not find virtio disk");
    80005ec8:	00002517          	auipc	a0,0x2
    80005ecc:	7a850513          	addi	a0,a0,1960 # 80008670 <etext+0x670>
    80005ed0:	955fa0ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005ed4:	00002517          	auipc	a0,0x2
    80005ed8:	7bc50513          	addi	a0,a0,1980 # 80008690 <etext+0x690>
    80005edc:	949fa0ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    80005ee0:	00002517          	auipc	a0,0x2
    80005ee4:	7d050513          	addi	a0,a0,2000 # 800086b0 <etext+0x6b0>
    80005ee8:	93dfa0ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    80005eec:	00002517          	auipc	a0,0x2
    80005ef0:	7e450513          	addi	a0,a0,2020 # 800086d0 <etext+0x6d0>
    80005ef4:	931fa0ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    80005ef8:	00002517          	auipc	a0,0x2
    80005efc:	7f850513          	addi	a0,a0,2040 # 800086f0 <etext+0x6f0>
    80005f00:	925fa0ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    80005f04:	00003517          	auipc	a0,0x3
    80005f08:	80c50513          	addi	a0,a0,-2036 # 80008710 <etext+0x710>
    80005f0c:	919fa0ef          	jal	80000824 <panic>

0000000080005f10 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f10:	711d                	addi	sp,sp,-96
    80005f12:	ec86                	sd	ra,88(sp)
    80005f14:	e8a2                	sd	s0,80(sp)
    80005f16:	e4a6                	sd	s1,72(sp)
    80005f18:	e0ca                	sd	s2,64(sp)
    80005f1a:	fc4e                	sd	s3,56(sp)
    80005f1c:	f852                	sd	s4,48(sp)
    80005f1e:	f456                	sd	s5,40(sp)
    80005f20:	f05a                	sd	s6,32(sp)
    80005f22:	ec5e                	sd	s7,24(sp)
    80005f24:	e862                	sd	s8,16(sp)
    80005f26:	1080                	addi	s0,sp,96
    80005f28:	89aa                	mv	s3,a0
    80005f2a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f2c:	00c52b83          	lw	s7,12(a0)
    80005f30:	001b9b9b          	slliw	s7,s7,0x1
    80005f34:	1b82                	slli	s7,s7,0x20
    80005f36:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005f3a:	00062517          	auipc	a0,0x62
    80005f3e:	d1650513          	addi	a0,a0,-746 # 80067c50 <disk+0x128>
    80005f42:	ce7fa0ef          	jal	80000c28 <acquire>
  for(int i = 0; i < NUM; i++){
    80005f46:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005f48:	00062a97          	auipc	s5,0x62
    80005f4c:	be0a8a93          	addi	s5,s5,-1056 # 80067b28 <disk>
  for(int i = 0; i < 3; i++){
    80005f50:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005f52:	5c7d                	li	s8,-1
    80005f54:	a095                	j	80005fb8 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005f56:	00fa8733          	add	a4,s5,a5
    80005f5a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005f5e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005f60:	0207c563          	bltz	a5,80005f8a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005f64:	2905                	addiw	s2,s2,1
    80005f66:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005f68:	05490c63          	beq	s2,s4,80005fc0 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    80005f6c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005f6e:	00062717          	auipc	a4,0x62
    80005f72:	bba70713          	addi	a4,a4,-1094 # 80067b28 <disk>
    80005f76:	4781                	li	a5,0
    if(disk.free[i]){
    80005f78:	01874683          	lbu	a3,24(a4)
    80005f7c:	fee9                	bnez	a3,80005f56 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    80005f7e:	2785                	addiw	a5,a5,1
    80005f80:	0705                	addi	a4,a4,1
    80005f82:	fe979be3          	bne	a5,s1,80005f78 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005f86:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80005f8a:	01205d63          	blez	s2,80005fa4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005f8e:	fa042503          	lw	a0,-96(s0)
    80005f92:	d41ff0ef          	jal	80005cd2 <free_desc>
      for(int j = 0; j < i; j++)
    80005f96:	4785                	li	a5,1
    80005f98:	0127d663          	bge	a5,s2,80005fa4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005f9c:	fa442503          	lw	a0,-92(s0)
    80005fa0:	d33ff0ef          	jal	80005cd2 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005fa4:	00062597          	auipc	a1,0x62
    80005fa8:	cac58593          	addi	a1,a1,-852 # 80067c50 <disk+0x128>
    80005fac:	00062517          	auipc	a0,0x62
    80005fb0:	b9450513          	addi	a0,a0,-1132 # 80067b40 <disk+0x18>
    80005fb4:	8e6fc0ef          	jal	8000209a <sleep>
  for(int i = 0; i < 3; i++){
    80005fb8:	fa040613          	addi	a2,s0,-96
    80005fbc:	4901                	li	s2,0
    80005fbe:	b77d                	j	80005f6c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005fc0:	fa042503          	lw	a0,-96(s0)
    80005fc4:	00451693          	slli	a3,a0,0x4

  if(write)
    80005fc8:	00062797          	auipc	a5,0x62
    80005fcc:	b6078793          	addi	a5,a5,-1184 # 80067b28 <disk>
    80005fd0:	00451713          	slli	a4,a0,0x4
    80005fd4:	0a070713          	addi	a4,a4,160
    80005fd8:	973e                	add	a4,a4,a5
    80005fda:	01603633          	snez	a2,s6
    80005fde:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005fe0:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005fe4:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005fe8:	6398                	ld	a4,0(a5)
    80005fea:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005fec:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005ff0:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005ff2:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005ff4:	6390                	ld	a2,0(a5)
    80005ff6:	00d60833          	add	a6,a2,a3
    80005ffa:	4741                	li	a4,16
    80005ffc:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006000:	4585                	li	a1,1
    80006002:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80006006:	fa442703          	lw	a4,-92(s0)
    8000600a:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000600e:	0712                	slli	a4,a4,0x4
    80006010:	963a                	add	a2,a2,a4
    80006012:	05898813          	addi	a6,s3,88
    80006016:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000601a:	0007b883          	ld	a7,0(a5)
    8000601e:	9746                	add	a4,a4,a7
    80006020:	40000613          	li	a2,1024
    80006024:	c710                	sw	a2,8(a4)
  if(write)
    80006026:	001b3613          	seqz	a2,s6
    8000602a:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000602e:	8e4d                	or	a2,a2,a1
    80006030:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006034:	fa842603          	lw	a2,-88(s0)
    80006038:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000603c:	00451813          	slli	a6,a0,0x4
    80006040:	02080813          	addi	a6,a6,32
    80006044:	983e                	add	a6,a6,a5
    80006046:	577d                	li	a4,-1
    80006048:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000604c:	0612                	slli	a2,a2,0x4
    8000604e:	98b2                	add	a7,a7,a2
    80006050:	03068713          	addi	a4,a3,48
    80006054:	973e                	add	a4,a4,a5
    80006056:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    8000605a:	6398                	ld	a4,0(a5)
    8000605c:	9732                	add	a4,a4,a2
    8000605e:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006060:	4689                	li	a3,2
    80006062:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006066:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000606a:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    8000606e:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006072:	6794                	ld	a3,8(a5)
    80006074:	0026d703          	lhu	a4,2(a3)
    80006078:	8b1d                	andi	a4,a4,7
    8000607a:	0706                	slli	a4,a4,0x1
    8000607c:	96ba                	add	a3,a3,a4
    8000607e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006082:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006086:	6798                	ld	a4,8(a5)
    80006088:	00275783          	lhu	a5,2(a4)
    8000608c:	2785                	addiw	a5,a5,1
    8000608e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006092:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006096:	100017b7          	lui	a5,0x10001
    8000609a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000609e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    800060a2:	00062917          	auipc	s2,0x62
    800060a6:	bae90913          	addi	s2,s2,-1106 # 80067c50 <disk+0x128>
  while(b->disk == 1) {
    800060aa:	84ae                	mv	s1,a1
    800060ac:	00b79a63          	bne	a5,a1,800060c0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    800060b0:	85ca                	mv	a1,s2
    800060b2:	854e                	mv	a0,s3
    800060b4:	fe7fb0ef          	jal	8000209a <sleep>
  while(b->disk == 1) {
    800060b8:	0049a783          	lw	a5,4(s3)
    800060bc:	fe978ae3          	beq	a5,s1,800060b0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    800060c0:	fa042903          	lw	s2,-96(s0)
    800060c4:	00491713          	slli	a4,s2,0x4
    800060c8:	02070713          	addi	a4,a4,32
    800060cc:	00062797          	auipc	a5,0x62
    800060d0:	a5c78793          	addi	a5,a5,-1444 # 80067b28 <disk>
    800060d4:	97ba                	add	a5,a5,a4
    800060d6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800060da:	00062997          	auipc	s3,0x62
    800060de:	a4e98993          	addi	s3,s3,-1458 # 80067b28 <disk>
    800060e2:	00491713          	slli	a4,s2,0x4
    800060e6:	0009b783          	ld	a5,0(s3)
    800060ea:	97ba                	add	a5,a5,a4
    800060ec:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800060f0:	854a                	mv	a0,s2
    800060f2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800060f6:	bddff0ef          	jal	80005cd2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800060fa:	8885                	andi	s1,s1,1
    800060fc:	f0fd                	bnez	s1,800060e2 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800060fe:	00062517          	auipc	a0,0x62
    80006102:	b5250513          	addi	a0,a0,-1198 # 80067c50 <disk+0x128>
    80006106:	bb7fa0ef          	jal	80000cbc <release>
}
    8000610a:	60e6                	ld	ra,88(sp)
    8000610c:	6446                	ld	s0,80(sp)
    8000610e:	64a6                	ld	s1,72(sp)
    80006110:	6906                	ld	s2,64(sp)
    80006112:	79e2                	ld	s3,56(sp)
    80006114:	7a42                	ld	s4,48(sp)
    80006116:	7aa2                	ld	s5,40(sp)
    80006118:	7b02                	ld	s6,32(sp)
    8000611a:	6be2                	ld	s7,24(sp)
    8000611c:	6c42                	ld	s8,16(sp)
    8000611e:	6125                	addi	sp,sp,96
    80006120:	8082                	ret

0000000080006122 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006122:	1101                	addi	sp,sp,-32
    80006124:	ec06                	sd	ra,24(sp)
    80006126:	e822                	sd	s0,16(sp)
    80006128:	e426                	sd	s1,8(sp)
    8000612a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000612c:	00062497          	auipc	s1,0x62
    80006130:	9fc48493          	addi	s1,s1,-1540 # 80067b28 <disk>
    80006134:	00062517          	auipc	a0,0x62
    80006138:	b1c50513          	addi	a0,a0,-1252 # 80067c50 <disk+0x128>
    8000613c:	aedfa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006140:	100017b7          	lui	a5,0x10001
    80006144:	53bc                	lw	a5,96(a5)
    80006146:	8b8d                	andi	a5,a5,3
    80006148:	10001737          	lui	a4,0x10001
    8000614c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000614e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006152:	689c                	ld	a5,16(s1)
    80006154:	0204d703          	lhu	a4,32(s1)
    80006158:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000615c:	04f70863          	beq	a4,a5,800061ac <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006160:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006164:	6898                	ld	a4,16(s1)
    80006166:	0204d783          	lhu	a5,32(s1)
    8000616a:	8b9d                	andi	a5,a5,7
    8000616c:	078e                	slli	a5,a5,0x3
    8000616e:	97ba                	add	a5,a5,a4
    80006170:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006172:	00479713          	slli	a4,a5,0x4
    80006176:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    8000617a:	9726                	add	a4,a4,s1
    8000617c:	01074703          	lbu	a4,16(a4)
    80006180:	e329                	bnez	a4,800061c2 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006182:	0792                	slli	a5,a5,0x4
    80006184:	02078793          	addi	a5,a5,32
    80006188:	97a6                	add	a5,a5,s1
    8000618a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000618c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006190:	f57fb0ef          	jal	800020e6 <wakeup>

    disk.used_idx += 1;
    80006194:	0204d783          	lhu	a5,32(s1)
    80006198:	2785                	addiw	a5,a5,1
    8000619a:	17c2                	slli	a5,a5,0x30
    8000619c:	93c1                	srli	a5,a5,0x30
    8000619e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800061a2:	6898                	ld	a4,16(s1)
    800061a4:	00275703          	lhu	a4,2(a4)
    800061a8:	faf71ce3          	bne	a4,a5,80006160 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800061ac:	00062517          	auipc	a0,0x62
    800061b0:	aa450513          	addi	a0,a0,-1372 # 80067c50 <disk+0x128>
    800061b4:	b09fa0ef          	jal	80000cbc <release>
}
    800061b8:	60e2                	ld	ra,24(sp)
    800061ba:	6442                	ld	s0,16(sp)
    800061bc:	64a2                	ld	s1,8(sp)
    800061be:	6105                	addi	sp,sp,32
    800061c0:	8082                	ret
      panic("virtio_disk_intr status");
    800061c2:	00002517          	auipc	a0,0x2
    800061c6:	56650513          	addi	a0,a0,1382 # 80008728 <etext+0x728>
    800061ca:	e5afa0ef          	jal	80000824 <panic>

00000000800061ce <enqueue_msg>:
#include "riscv.h"
#include "spinlock.h"
#include "types.h"

static int enqueue_msg(struct proc *dst, int sender_pid, char *data, int size) {
  if (size <= 0 || size > MAX_MSG_SIZE)
    800061ce:	fff6871b          	addiw	a4,a3,-1
    800061d2:	0ff00793          	li	a5,255
    800061d6:	0ae7ed63          	bltu	a5,a4,80006290 <enqueue_msg+0xc2>
static int enqueue_msg(struct proc *dst, int sender_pid, char *data, int size) {
    800061da:	7139                	addi	sp,sp,-64
    800061dc:	fc06                	sd	ra,56(sp)
    800061de:	f822                	sd	s0,48(sp)
    800061e0:	f426                	sd	s1,40(sp)
    800061e2:	ec4e                	sd	s3,24(sp)
    800061e4:	e852                	sd	s4,16(sp)
    800061e6:	e456                	sd	s5,8(sp)
    800061e8:	e05a                	sd	s6,0(sp)
    800061ea:	0080                	addi	s0,sp,64
    800061ec:	84aa                	mv	s1,a0
    800061ee:	8aae                	mv	s5,a1
    800061f0:	8b32                	mv	s6,a2
    800061f2:	8a36                	mv	s4,a3
    return -1;

  acquire(&dst->mq.lock);
    800061f4:	6985                	lui	s3,0x1
    800061f6:	20898993          	addi	s3,s3,520 # 1208 <_entry-0x7fffedf8>
    800061fa:	99aa                	add	s3,s3,a0
    800061fc:	854e                	mv	a0,s3
    800061fe:	a2bfa0ef          	jal	80000c28 <acquire>

  if (dst->mq.count == MSG_QUEUE_LEN) {
    80006202:	6785                	lui	a5,0x1
    80006204:	97a6                	add	a5,a5,s1
    80006206:	2007a703          	lw	a4,512(a5) # 1200 <_entry-0x7fffee00>
    8000620a:	47c1                	li	a5,16
    8000620c:	06f70d63          	beq	a4,a5,80006286 <enqueue_msg+0xb8>
    80006210:	f04a                	sd	s2,32(sp)
    release(&dst->mq.lock);
    return -1;
  }

  struct message *m = &dst->mq.buf[dst->mq.tail];
    80006212:	6905                	lui	s2,0x1
    80006214:	9926                	add	s2,s2,s1
    80006216:	1fc92703          	lw	a4,508(s2) # 11fc <_entry-0x7fffee04>
  m->sender_pid = sender_pid;
    8000621a:	00571513          	slli	a0,a4,0x5
    8000621e:	00e507b3          	add	a5,a0,a4
    80006222:	078e                	slli	a5,a5,0x3
    80006224:	97a6                	add	a5,a5,s1
    80006226:	1757ac23          	sw	s5,376(a5)
  m->size = size;
    8000622a:	1747ae23          	sw	s4,380(a5)
  memmove(m->data, data, size);
    8000622e:	953a                	add	a0,a0,a4
    80006230:	050e                	slli	a0,a0,0x3
    80006232:	18050513          	addi	a0,a0,384
    80006236:	8652                	mv	a2,s4
    80006238:	85da                	mv	a1,s6
    8000623a:	9526                	add	a0,a0,s1
    8000623c:	b1dfa0ef          	jal	80000d58 <memmove>

  dst->mq.tail = (dst->mq.tail + 1) % MSG_QUEUE_LEN;
    80006240:	1fc92783          	lw	a5,508(s2)
    80006244:	2785                	addiw	a5,a5,1
    80006246:	41f7d71b          	sraiw	a4,a5,0x1f
    8000624a:	01c7571b          	srliw	a4,a4,0x1c
    8000624e:	9fb9                	addw	a5,a5,a4
    80006250:	8bbd                	andi	a5,a5,15
    80006252:	9f99                	subw	a5,a5,a4
    80006254:	1ef92e23          	sw	a5,508(s2)
  dst->mq.count++;
    80006258:	20092783          	lw	a5,512(s2)
    8000625c:	2785                	addiw	a5,a5,1
    8000625e:	20f92023          	sw	a5,512(s2)

  wakeup(&dst->mq);
    80006262:	17848513          	addi	a0,s1,376
    80006266:	e81fb0ef          	jal	800020e6 <wakeup>
  release(&dst->mq.lock);
    8000626a:	854e                	mv	a0,s3
    8000626c:	a51fa0ef          	jal	80000cbc <release>
  return 0;
    80006270:	4501                	li	a0,0
    80006272:	7902                	ld	s2,32(sp)
}
    80006274:	70e2                	ld	ra,56(sp)
    80006276:	7442                	ld	s0,48(sp)
    80006278:	74a2                	ld	s1,40(sp)
    8000627a:	69e2                	ld	s3,24(sp)
    8000627c:	6a42                	ld	s4,16(sp)
    8000627e:	6aa2                	ld	s5,8(sp)
    80006280:	6b02                	ld	s6,0(sp)
    80006282:	6121                	addi	sp,sp,64
    80006284:	8082                	ret
    release(&dst->mq.lock);
    80006286:	854e                	mv	a0,s3
    80006288:	a35fa0ef          	jal	80000cbc <release>
    return -1;
    8000628c:	557d                	li	a0,-1
    8000628e:	b7dd                	j	80006274 <enqueue_msg+0xa6>
    return -1;
    80006290:	557d                	li	a0,-1
}
    80006292:	8082                	ret

0000000080006294 <sys_sendmsg>:

uint64 sys_sendmsg(void) {
    80006294:	7169                	addi	sp,sp,-304
    80006296:	f606                	sd	ra,296(sp)
    80006298:	f222                	sd	s0,288(sp)
    8000629a:	1a00                	addi	s0,sp,304
  int target_pid, size;
  uint64 buf_addr;

  argint(0, &target_pid);
    8000629c:	fdc40593          	addi	a1,s0,-36
    800062a0:	4501                	li	a0,0
    800062a2:	f26fc0ef          	jal	800029c8 <argint>
  argaddr(1, &buf_addr);
    800062a6:	fd040593          	addi	a1,s0,-48
    800062aa:	4505                	li	a0,1
    800062ac:	f38fc0ef          	jal	800029e4 <argaddr>
  argint(2, &size);
    800062b0:	fd840593          	addi	a1,s0,-40
    800062b4:	4509                	li	a0,2
    800062b6:	f12fc0ef          	jal	800029c8 <argint>

  if (size <= 0 || size > MAX_MSG_SIZE)
    800062ba:	fd842783          	lw	a5,-40(s0)
    800062be:	37fd                	addiw	a5,a5,-1
    800062c0:	0ff00713          	li	a4,255
    return -1;
    800062c4:	557d                	li	a0,-1
  if (size <= 0 || size > MAX_MSG_SIZE)
    800062c6:	06f76163          	bltu	a4,a5,80006328 <sys_sendmsg+0x94>

  char kbuf[MAX_MSG_SIZE];
  if (copyin(myproc()->pagetable, kbuf, buf_addr, size) < 0)
    800062ca:	ec0fb0ef          	jal	8000198a <myproc>
    800062ce:	fd842683          	lw	a3,-40(s0)
    800062d2:	fd043603          	ld	a2,-48(s0)
    800062d6:	ed040593          	addi	a1,s0,-304
    800062da:	6d28                	ld	a0,88(a0)
    800062dc:	c36fb0ef          	jal	80001712 <copyin>
    800062e0:	04054b63          	bltz	a0,80006336 <sys_sendmsg+0xa2>
    800062e4:	ee26                	sd	s1,280(sp)
    return -1;

  struct proc *target = 0;
  extern struct proc proc[];
  for (struct proc *p = proc; p < &proc[NPROC]; p++) {
    if (p->pid == target_pid && p->state != UNUSED) {
    800062e6:	fdc42683          	lw	a3,-36(s0)
  for (struct proc *p = proc; p < &proc[NPROC]; p++) {
    800062ea:	0000e497          	auipc	s1,0xe
    800062ee:	a9e48493          	addi	s1,s1,-1378 # 80013d88 <proc>
    800062f2:	6705                	lui	a4,0x1
    800062f4:	22070713          	addi	a4,a4,544 # 1220 <_entry-0x7fffede0>
    800062f8:	00056617          	auipc	a2,0x56
    800062fc:	29060613          	addi	a2,a2,656 # 8005c588 <tickslock>
    80006300:	a021                	j	80006308 <sys_sendmsg+0x74>
    80006302:	94ba                	add	s1,s1,a4
    80006304:	02c48663          	beq	s1,a2,80006330 <sys_sendmsg+0x9c>
    if (p->pid == target_pid && p->state != UNUSED) {
    80006308:	589c                	lw	a5,48(s1)
    8000630a:	fed79ce3          	bne	a5,a3,80006302 <sys_sendmsg+0x6e>
    8000630e:	4c9c                	lw	a5,24(s1)
    80006310:	dbed                	beqz	a5,80006302 <sys_sendmsg+0x6e>
    }
  }
  if (!target)
    return -1;

  return enqueue_msg(target, myproc()->pid, kbuf, size);
    80006312:	e78fb0ef          	jal	8000198a <myproc>
    80006316:	fd842683          	lw	a3,-40(s0)
    8000631a:	ed040613          	addi	a2,s0,-304
    8000631e:	590c                	lw	a1,48(a0)
    80006320:	8526                	mv	a0,s1
    80006322:	eadff0ef          	jal	800061ce <enqueue_msg>
    80006326:	64f2                	ld	s1,280(sp)
}
    80006328:	70b2                	ld	ra,296(sp)
    8000632a:	7412                	ld	s0,288(sp)
    8000632c:	6155                	addi	sp,sp,304
    8000632e:	8082                	ret
    return -1;
    80006330:	557d                	li	a0,-1
    80006332:	64f2                	ld	s1,280(sp)
    80006334:	bfd5                	j	80006328 <sys_sendmsg+0x94>
    return -1;
    80006336:	557d                	li	a0,-1
    80006338:	bfc5                	j	80006328 <sys_sendmsg+0x94>

000000008000633a <sys_recvmsg>:

uint64 sys_recvmsg(void) {
    8000633a:	7139                	addi	sp,sp,-64
    8000633c:	fc06                	sd	ra,56(sp)
    8000633e:	f822                	sd	s0,48(sp)
    80006340:	f426                	sd	s1,40(sp)
    80006342:	f04a                	sd	s2,32(sp)
    80006344:	ec4e                	sd	s3,24(sp)
    80006346:	0080                	addi	s0,sp,64
  uint64 buf_addr;
  int size;

  argaddr(0, &buf_addr);
    80006348:	fc840593          	addi	a1,s0,-56
    8000634c:	4501                	li	a0,0
    8000634e:	e96fc0ef          	jal	800029e4 <argaddr>
  argint(1, &size);
    80006352:	fc440593          	addi	a1,s0,-60
    80006356:	4505                	li	a0,1
    80006358:	e70fc0ef          	jal	800029c8 <argint>

  struct proc *p = myproc();
    8000635c:	e2efb0ef          	jal	8000198a <myproc>
    80006360:	892a                	mv	s2,a0

  acquire(&p->mq.lock);
    80006362:	6485                	lui	s1,0x1
    80006364:	20848493          	addi	s1,s1,520 # 1208 <_entry-0x7fffedf8>
    80006368:	94aa                	add	s1,s1,a0
    8000636a:	8526                	mv	a0,s1
    8000636c:	8bdfa0ef          	jal	80000c28 <acquire>

  while (p->mq.count == 0) {
    80006370:	6785                	lui	a5,0x1
    80006372:	97ca                	add	a5,a5,s2
    80006374:	2007a783          	lw	a5,512(a5) # 1200 <_entry-0x7fffee00>
    80006378:	ef91                	bnez	a5,80006394 <sys_recvmsg+0x5a>
    8000637a:	e852                	sd	s4,16(sp)
    sleep(&p->mq, &p->mq.lock);
    8000637c:	17890a13          	addi	s4,s2,376
  while (p->mq.count == 0) {
    80006380:	6985                	lui	s3,0x1
    80006382:	99ca                	add	s3,s3,s2
    sleep(&p->mq, &p->mq.lock);
    80006384:	85a6                	mv	a1,s1
    80006386:	8552                	mv	a0,s4
    80006388:	d13fb0ef          	jal	8000209a <sleep>
  while (p->mq.count == 0) {
    8000638c:	2009a783          	lw	a5,512(s3) # 1200 <_entry-0x7fffee00>
    80006390:	dbf5                	beqz	a5,80006384 <sys_recvmsg+0x4a>
    80006392:	6a42                	ld	s4,16(sp)
  }

  struct message *m = &p->mq.buf[p->mq.head];
    80006394:	6785                	lui	a5,0x1
    80006396:	97ca                	add	a5,a5,s2
    80006398:	1f87a983          	lw	s3,504(a5) # 11f8 <_entry-0x7fffee08>
  int copy_len = (m->size < size) ? m->size : size;
    8000639c:	00599793          	slli	a5,s3,0x5
    800063a0:	97ce                	add	a5,a5,s3
    800063a2:	078e                	slli	a5,a5,0x3
    800063a4:	97ca                	add	a5,a5,s2
    800063a6:	fc442703          	lw	a4,-60(s0)
    800063aa:	17c7a783          	lw	a5,380(a5)
    800063ae:	86be                	mv	a3,a5
    800063b0:	2781                	sext.w	a5,a5
    800063b2:	00f75363          	bge	a4,a5,800063b8 <sys_recvmsg+0x7e>
    800063b6:	86ba                	mv	a3,a4

  if (copyout(p->pagetable, buf_addr, m->data, copy_len) < 0) {
    800063b8:	00599613          	slli	a2,s3,0x5
    800063bc:	964e                	add	a2,a2,s3
    800063be:	060e                	slli	a2,a2,0x3
    800063c0:	18060613          	addi	a2,a2,384
    800063c4:	2681                	sext.w	a3,a3
    800063c6:	964a                	add	a2,a2,s2
    800063c8:	fc843583          	ld	a1,-56(s0)
    800063cc:	05893503          	ld	a0,88(s2)
    800063d0:	a84fb0ef          	jal	80001654 <copyout>
    800063d4:	04054663          	bltz	a0,80006420 <sys_recvmsg+0xe6>
    release(&p->mq.lock);
    return -1;
  }

  p->mq.head = (p->mq.head + 1) % MSG_QUEUE_LEN;
    800063d8:	6705                	lui	a4,0x1
    800063da:	974a                	add	a4,a4,s2
    800063dc:	1f872783          	lw	a5,504(a4) # 11f8 <_entry-0x7fffee08>
    800063e0:	2785                	addiw	a5,a5,1
    800063e2:	41f7d69b          	sraiw	a3,a5,0x1f
    800063e6:	01c6d69b          	srliw	a3,a3,0x1c
    800063ea:	9fb5                	addw	a5,a5,a3
    800063ec:	8bbd                	andi	a5,a5,15
    800063ee:	9f95                	subw	a5,a5,a3
    800063f0:	1ef72c23          	sw	a5,504(a4)
  p->mq.count--;
    800063f4:	20072783          	lw	a5,512(a4)
    800063f8:	37fd                	addiw	a5,a5,-1
    800063fa:	20f72023          	sw	a5,512(a4)

  release(&p->mq.lock);
    800063fe:	8526                	mv	a0,s1
    80006400:	8bdfa0ef          	jal	80000cbc <release>
  return m->sender_pid;
    80006404:	00599793          	slli	a5,s3,0x5
    80006408:	97ce                	add	a5,a5,s3
    8000640a:	078e                	slli	a5,a5,0x3
    8000640c:	993e                	add	s2,s2,a5
    8000640e:	17892503          	lw	a0,376(s2)
}
    80006412:	70e2                	ld	ra,56(sp)
    80006414:	7442                	ld	s0,48(sp)
    80006416:	74a2                	ld	s1,40(sp)
    80006418:	7902                	ld	s2,32(sp)
    8000641a:	69e2                	ld	s3,24(sp)
    8000641c:	6121                	addi	sp,sp,64
    8000641e:	8082                	ret
    release(&p->mq.lock);
    80006420:	8526                	mv	a0,s1
    80006422:	89bfa0ef          	jal	80000cbc <release>
    return -1;
    80006426:	557d                	li	a0,-1
    80006428:	b7ed                	j	80006412 <sys_recvmsg+0xd8>

000000008000642a <sys_broadcast>:

uint64 sys_broadcast(void) {
    8000642a:	714d                	addi	sp,sp,-336
    8000642c:	e686                	sd	ra,328(sp)
    8000642e:	e2a2                	sd	s0,320(sp)
    80006430:	0a80                	addi	s0,sp,336
  uint64 buf_addr;
  int size;

  argaddr(0, &buf_addr);
    80006432:	fb840593          	addi	a1,s0,-72
    80006436:	4501                	li	a0,0
    80006438:	dacfc0ef          	jal	800029e4 <argaddr>
  argint(1, &size);
    8000643c:	fb440593          	addi	a1,s0,-76
    80006440:	4505                	li	a0,1
    80006442:	d86fc0ef          	jal	800029c8 <argint>

  if (size <= 0 || size > MAX_MSG_SIZE)
    80006446:	fb442783          	lw	a5,-76(s0)
    8000644a:	37fd                	addiw	a5,a5,-1
    8000644c:	0ff00713          	li	a4,255
    return -1;
    80006450:	557d                	li	a0,-1
  if (size <= 0 || size > MAX_MSG_SIZE)
    80006452:	08f76363          	bltu	a4,a5,800064d8 <sys_broadcast+0xae>

  char kbuf[MAX_MSG_SIZE];
  if (copyin(myproc()->pagetable, kbuf, buf_addr, size) < 0)
    80006456:	d34fb0ef          	jal	8000198a <myproc>
    8000645a:	fb442683          	lw	a3,-76(s0)
    8000645e:	fb843603          	ld	a2,-72(s0)
    80006462:	eb040593          	addi	a1,s0,-336
    80006466:	6d28                	ld	a0,88(a0)
    80006468:	aaafb0ef          	jal	80001712 <copyin>
    8000646c:	87aa                	mv	a5,a0
    return -1;
    8000646e:	557d                	li	a0,-1
  if (copyin(myproc()->pagetable, kbuf, buf_addr, size) < 0)
    80006470:	0607c463          	bltz	a5,800064d8 <sys_broadcast+0xae>
    80006474:	fe26                	sd	s1,312(sp)
    80006476:	fa4a                	sd	s2,304(sp)
    80006478:	f64e                	sd	s3,296(sp)
    8000647a:	f252                	sd	s4,288(sp)
    8000647c:	ee56                	sd	s5,280(sp)
    8000647e:	ea5a                	sd	s6,272(sp)

  int sender_pid = myproc()->pid;
    80006480:	d0afb0ef          	jal	8000198a <myproc>
    80006484:	03052903          	lw	s2,48(a0)
  int count = 0;
  extern struct proc proc[];

  for (struct proc *p = proc; p < &proc[NPROC]; p++) {
    80006488:	0000e497          	auipc	s1,0xe
    8000648c:	90048493          	addi	s1,s1,-1792 # 80013d88 <proc>
  int count = 0;
    80006490:	4a81                	li	s5,0
    if (p->pid != sender_pid && p->state != UNUSED) {
      if (enqueue_msg(p, sender_pid, kbuf, size) == 0)
    80006492:	eb040b13          	addi	s6,s0,-336
  for (struct proc *p = proc; p < &proc[NPROC]; p++) {
    80006496:	6985                	lui	s3,0x1
    80006498:	22098993          	addi	s3,s3,544 # 1220 <_entry-0x7fffede0>
    8000649c:	00056a17          	auipc	s4,0x56
    800064a0:	0eca0a13          	addi	s4,s4,236 # 8005c588 <tickslock>
    800064a4:	a021                	j	800064ac <sys_broadcast+0x82>
    800064a6:	94ce                	add	s1,s1,s3
    800064a8:	03448163          	beq	s1,s4,800064ca <sys_broadcast+0xa0>
    if (p->pid != sender_pid && p->state != UNUSED) {
    800064ac:	589c                	lw	a5,48(s1)
    800064ae:	ff278ce3          	beq	a5,s2,800064a6 <sys_broadcast+0x7c>
    800064b2:	4c9c                	lw	a5,24(s1)
    800064b4:	dbed                	beqz	a5,800064a6 <sys_broadcast+0x7c>
      if (enqueue_msg(p, sender_pid, kbuf, size) == 0)
    800064b6:	fb442683          	lw	a3,-76(s0)
    800064ba:	865a                	mv	a2,s6
    800064bc:	85ca                	mv	a1,s2
    800064be:	8526                	mv	a0,s1
    800064c0:	d0fff0ef          	jal	800061ce <enqueue_msg>
    800064c4:	f16d                	bnez	a0,800064a6 <sys_broadcast+0x7c>
        count++;
    800064c6:	2a85                	addiw	s5,s5,1
    800064c8:	bff9                	j	800064a6 <sys_broadcast+0x7c>
    }
  }

  return count;
    800064ca:	8556                	mv	a0,s5
    800064cc:	74f2                	ld	s1,312(sp)
    800064ce:	7952                	ld	s2,304(sp)
    800064d0:	79b2                	ld	s3,296(sp)
    800064d2:	7a12                	ld	s4,288(sp)
    800064d4:	6af2                	ld	s5,280(sp)
    800064d6:	6b52                	ld	s6,272(sp)
}
    800064d8:	60b6                	ld	ra,328(sp)
    800064da:	6416                	ld	s0,320(sp)
    800064dc:	6171                	addi	sp,sp,336
    800064de:	8082                	ret
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	9282                	jalr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
