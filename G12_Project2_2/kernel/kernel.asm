
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	1f813103          	ld	sp,504(sp) # 8000a1f8 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb0b7>
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
    8000011a:	28a020ef          	jal	800023a4 <either_copyin>
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
    80000192:	00012517          	auipc	a0,0x12
    80000196:	0ae50513          	addi	a0,a0,174 # 80012240 <cons>
    8000019a:	28f000ef          	jal	80000c28 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	00012497          	auipc	s1,0x12
    800001a2:	0a248493          	addi	s1,s1,162 # 80012240 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	00012917          	auipc	s2,0x12
    800001aa:	13290913          	addi	s2,s2,306 # 800122d8 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	770010ef          	jal	8000192e <myproc>
    800001c2:	07a020ef          	jal	8000223c <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	635010ef          	jal	80002000 <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00012717          	auipc	a4,0x12
    800001e2:	06270713          	addi	a4,a4,98 # 80012240 <cons>
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
    80000210:	14a020ef          	jal	8000235a <either_copyout>
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
    80000228:	00012517          	auipc	a0,0x12
    8000022c:	01850513          	addi	a0,a0,24 # 80012240 <cons>
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
    8000024e:	00012717          	auipc	a4,0x12
    80000252:	08f72523          	sw	a5,138(a4) # 800122d8 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	00012517          	auipc	a0,0x12
    80000268:	fdc50513          	addi	a0,a0,-36 # 80012240 <cons>
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
    800002b8:	00012517          	auipc	a0,0x12
    800002bc:	f8850513          	addi	a0,a0,-120 # 80012240 <cons>
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
    800002da:	114020ef          	jal	800023ee <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	00012517          	auipc	a0,0x12
    800002e2:	f6250513          	addi	a0,a0,-158 # 80012240 <cons>
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
    800002fc:	00012717          	auipc	a4,0x12
    80000300:	f4470713          	addi	a4,a4,-188 # 80012240 <cons>
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
    80000322:	00012717          	auipc	a4,0x12
    80000326:	f1e70713          	addi	a4,a4,-226 # 80012240 <cons>
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
    8000034c:	00012717          	auipc	a4,0x12
    80000350:	f8c72703          	lw	a4,-116(a4) # 800122d8 <cons+0x98>
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	08000713          	li	a4,128
    8000035a:	f8e792e3          	bne	a5,a4,800002de <consoleintr+0x32>
    8000035e:	a075                	j	8000040a <consoleintr+0x15e>
    80000360:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000362:	00012717          	auipc	a4,0x12
    80000366:	ede70713          	addi	a4,a4,-290 # 80012240 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000372:	00012497          	auipc	s1,0x12
    80000376:	ece48493          	addi	s1,s1,-306 # 80012240 <cons>
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
    800003b4:	00012717          	auipc	a4,0x12
    800003b8:	e8c70713          	addi	a4,a4,-372 # 80012240 <cons>
    800003bc:	0a072783          	lw	a5,160(a4)
    800003c0:	09c72703          	lw	a4,156(a4)
    800003c4:	f0f70de3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003c8:	37fd                	addiw	a5,a5,-1
    800003ca:	00012717          	auipc	a4,0x12
    800003ce:	f0f72b23          	sw	a5,-234(a4) # 800122e0 <cons+0xa0>
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
    800003e8:	00012797          	auipc	a5,0x12
    800003ec:	e5878793          	addi	a5,a5,-424 # 80012240 <cons>
    800003f0:	0a07a703          	lw	a4,160(a5)
    800003f4:	0017069b          	addiw	a3,a4,1
    800003f8:	8636                	mv	a2,a3
    800003fa:	0ad7a023          	sw	a3,160(a5)
    800003fe:	07f77713          	andi	a4,a4,127
    80000402:	97ba                	add	a5,a5,a4
    80000404:	4729                	li	a4,10
    80000406:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040a:	00012797          	auipc	a5,0x12
    8000040e:	ecc7a923          	sw	a2,-302(a5) # 800122dc <cons+0x9c>
        wakeup(&cons.r);
    80000412:	00012517          	auipc	a0,0x12
    80000416:	ec650513          	addi	a0,a0,-314 # 800122d8 <cons+0x98>
    8000041a:	433010ef          	jal	8000204c <wakeup>
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
    80000430:	00012517          	auipc	a0,0x12
    80000434:	e1050513          	addi	a0,a0,-496 # 80012240 <cons>
    80000438:	766000ef          	jal	80000b9e <initlock>

  uartinit();
    8000043c:	448000ef          	jal	80000884 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	00022797          	auipc	a5,0x22
    80000444:	17078793          	addi	a5,a5,368 # 800225b0 <devsw>
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
    80000482:	29280813          	addi	a6,a6,658 # 80007710 <digits>
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
    80000518:	0000a797          	auipc	a5,0xa
    8000051c:	cfc7a783          	lw	a5,-772(a5) # 8000a214 <panicking>
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
    8000055e:	00012517          	auipc	a0,0x12
    80000562:	d8a50513          	addi	a0,a0,-630 # 800122e8 <pr>
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
    800006d6:	03ec8c93          	addi	s9,s9,62 # 80007710 <digits>
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
    8000075a:	0000a797          	auipc	a5,0xa
    8000075e:	aba7a783          	lw	a5,-1350(a5) # 8000a214 <panicking>
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
    80000784:	00012517          	auipc	a0,0x12
    80000788:	b6450513          	addi	a0,a0,-1180 # 800122e8 <pr>
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
    80000834:	0000a797          	auipc	a5,0xa
    80000838:	9e97a023          	sw	s1,-1568(a5) # 8000a214 <panicking>
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
    80000856:	0000a797          	auipc	a5,0xa
    8000085a:	9a97ad23          	sw	s1,-1606(a5) # 8000a210 <panicked>
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
    80000870:	00012517          	auipc	a0,0x12
    80000874:	a7850513          	addi	a0,a0,-1416 # 800122e8 <pr>
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
    800008c6:	00012517          	auipc	a0,0x12
    800008ca:	a3a50513          	addi	a0,a0,-1478 # 80012300 <tx_lock>
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
    800008ea:	00012517          	auipc	a0,0x12
    800008ee:	a1650513          	addi	a0,a0,-1514 # 80012300 <tx_lock>
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
    80000908:	0000a497          	auipc	s1,0xa
    8000090c:	91448493          	addi	s1,s1,-1772 # 8000a21c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000910:	00012997          	auipc	s3,0x12
    80000914:	9f098993          	addi	s3,s3,-1552 # 80012300 <tx_lock>
    80000918:	0000a917          	auipc	s2,0xa
    8000091c:	90090913          	addi	s2,s2,-1792 # 8000a218 <tx_chan>
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
    8000092c:	6d4010ef          	jal	80002000 <sleep>
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
    80000956:	00012517          	auipc	a0,0x12
    8000095a:	9aa50513          	addi	a0,a0,-1622 # 80012300 <tx_lock>
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
    8000097a:	0000a797          	auipc	a5,0xa
    8000097e:	89a7a783          	lw	a5,-1894(a5) # 8000a214 <panicking>
    80000982:	cf95                	beqz	a5,800009be <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000984:	0000a797          	auipc	a5,0xa
    80000988:	88c7a783          	lw	a5,-1908(a5) # 8000a210 <panicked>
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
    800009aa:	0000a797          	auipc	a5,0xa
    800009ae:	86a7a783          	lw	a5,-1942(a5) # 8000a214 <panicking>
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
    80000a06:	00012517          	auipc	a0,0x12
    80000a0a:	8fa50513          	addi	a0,a0,-1798 # 80012300 <tx_lock>
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
    80000a20:	00012517          	auipc	a0,0x12
    80000a24:	8e050513          	addi	a0,a0,-1824 # 80012300 <tx_lock>
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
    80000a3c:	00009797          	auipc	a5,0x9
    80000a40:	7e07a023          	sw	zero,2016(a5) # 8000a21c <tx_busy>
    wakeup(&tx_chan);
    80000a44:	00009517          	auipc	a0,0x9
    80000a48:	7d450513          	addi	a0,a0,2004 # 8000a218 <tx_chan>
    80000a4c:	600010ef          	jal	8000204c <wakeup>
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
    80000a68:	00023797          	auipc	a5,0x23
    80000a6c:	ce078793          	addi	a5,a5,-800 # 80023748 <end>
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
    80000a92:	00012917          	auipc	s2,0x12
    80000a96:	88690913          	addi	s2,s2,-1914 # 80012318 <kmem>
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
    80000b20:	00011517          	auipc	a0,0x11
    80000b24:	7f850513          	addi	a0,a0,2040 # 80012318 <kmem>
    80000b28:	076000ef          	jal	80000b9e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00023517          	auipc	a0,0x23
    80000b34:	c1850513          	addi	a0,a0,-1000 # 80023748 <end>
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
    80000b4e:	00011517          	auipc	a0,0x11
    80000b52:	7ca50513          	addi	a0,a0,1994 # 80012318 <kmem>
    80000b56:	0d2000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b5a:	00011497          	auipc	s1,0x11
    80000b5e:	7d64b483          	ld	s1,2006(s1) # 80012330 <kmem+0x18>
  if(r)
    80000b62:	c49d                	beqz	s1,80000b90 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b64:	609c                	ld	a5,0(s1)
    80000b66:	00011717          	auipc	a4,0x11
    80000b6a:	7cf73523          	sd	a5,1994(a4) # 80012330 <kmem+0x18>
  release(&kmem.lock);
    80000b6e:	00011517          	auipc	a0,0x11
    80000b72:	7aa50513          	addi	a0,a0,1962 # 80012318 <kmem>
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
    80000b90:	00011517          	auipc	a0,0x11
    80000b94:	78850513          	addi	a0,a0,1928 # 80012318 <kmem>
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
    80000bce:	541000ef          	jal	8000190e <mycpu>
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
    80000bfe:	511000ef          	jal	8000190e <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	509000ef          	jal	8000190e <mycpu>
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
    80000c1a:	4f5000ef          	jal	8000190e <mycpu>
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
    80000c50:	4bf000ef          	jal	8000190e <mycpu>
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
    80000c74:	49b000ef          	jal	8000190e <mycpu>
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
    80000eb6:	245000ef          	jal	800018fa <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eba:	00009717          	auipc	a4,0x9
    80000ebe:	36670713          	addi	a4,a4,870 # 8000a220 <started>
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
    80000ece:	22d000ef          	jal	800018fa <cpuid>
    80000ed2:	85aa                	mv	a1,a0
    80000ed4:	00006517          	auipc	a0,0x6
    80000ed8:	1c450513          	addi	a0,a0,452 # 80007098 <etext+0x98>
    80000edc:	e1eff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000ee0:	080000ef          	jal	80000f60 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee4:	63c010ef          	jal	80002520 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee8:	660040ef          	jal	80005548 <plicinithart>
  }

  scheduler();        
    80000eec:	6c9000ef          	jal	80001db4 <scheduler>
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
    80000f28:	11d000ef          	jal	80001844 <procinit>
    trapinit();      // trap vectors
    80000f2c:	5d0010ef          	jal	800024fc <trapinit>
    trapinithart();  // install kernel trap vector
    80000f30:	5f0010ef          	jal	80002520 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f34:	5fa040ef          	jal	8000552e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f38:	610040ef          	jal	80005548 <plicinithart>
    binit();         // buffer cache
    80000f3c:	47d010ef          	jal	80002bb8 <binit>
    iinit();         // inode table
    80000f40:	1ce020ef          	jal	8000310e <iinit>
    fileinit();      // file table
    80000f44:	0fa030ef          	jal	8000403e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	6f0040ef          	jal	80005638 <virtio_disk_init>
    userinit();      // first user process
    80000f4c:	4b5000ef          	jal	80001c00 <userinit>
    __sync_synchronize();
    80000f50:	0330000f          	fence	rw,rw
    started = 1;
    80000f54:	4785                	li	a5,1
    80000f56:	00009717          	auipc	a4,0x9
    80000f5a:	2cf72523          	sw	a5,714(a4) # 8000a220 <started>
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
    80000f6c:	00009797          	auipc	a5,0x9
    80000f70:	2bc7b783          	ld	a5,700(a5) # 8000a228 <kernel_pagetable>
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
    800011f8:	00009797          	auipc	a5,0x9
    800011fc:	02a7b823          	sd	a0,48(a5) # 8000a228 <kernel_pagetable>
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
    800015e0:	34e000ef          	jal	8000192e <myproc>
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

00000000800017a0 <proc_mapstacks>:
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.s
void proc_mapstacks(pagetable_t kpgtbl) {
    800017a0:	715d                	addi	sp,sp,-80
    800017a2:	e486                	sd	ra,72(sp)
    800017a4:	e0a2                	sd	s0,64(sp)
    800017a6:	fc26                	sd	s1,56(sp)
    800017a8:	f84a                	sd	s2,48(sp)
    800017aa:	f44e                	sd	s3,40(sp)
    800017ac:	f052                	sd	s4,32(sp)
    800017ae:	ec56                	sd	s5,24(sp)
    800017b0:	e85a                	sd	s6,16(sp)
    800017b2:	e45e                	sd	s7,8(sp)
    800017b4:	e062                	sd	s8,0(sp)
    800017b6:	0880                	addi	s0,sp,80
    800017b8:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800017ba:	00011497          	auipc	s1,0x11
    800017be:	fae48493          	addi	s1,s1,-82 # 80012768 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800017c2:	8c26                	mv	s8,s1
    800017c4:	ff4df937          	lui	s2,0xff4df
    800017c8:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb275>
    800017cc:	0936                	slli	s2,s2,0xd
    800017ce:	6f590913          	addi	s2,s2,1781
    800017d2:	0936                	slli	s2,s2,0xd
    800017d4:	bd390913          	addi	s2,s2,-1069
    800017d8:	0932                	slli	s2,s2,0xc
    800017da:	7a790913          	addi	s2,s2,1959
    800017de:	040009b7          	lui	s3,0x4000
    800017e2:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017e4:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017e6:	4b99                	li	s7,6
    800017e8:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    800017ea:	00017a97          	auipc	s5,0x17
    800017ee:	b7ea8a93          	addi	s5,s5,-1154 # 80018368 <tickslock>
    char *pa = kalloc();
    800017f2:	b52ff0ef          	jal	80000b44 <kalloc>
    800017f6:	862a                	mv	a2,a0
    if (pa == 0)
    800017f8:	c121                	beqz	a0,80001838 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    800017fa:	418485b3          	sub	a1,s1,s8
    800017fe:	8591                	srai	a1,a1,0x4
    80001800:	032585b3          	mul	a1,a1,s2
    80001804:	05b6                	slli	a1,a1,0xd
    80001806:	6789                	lui	a5,0x2
    80001808:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000180a:	875e                	mv	a4,s7
    8000180c:	86da                	mv	a3,s6
    8000180e:	40b985b3          	sub	a1,s3,a1
    80001812:	8552                	mv	a0,s4
    80001814:	903ff0ef          	jal	80001116 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001818:	17048493          	addi	s1,s1,368
    8000181c:	fd549be3          	bne	s1,s5,800017f2 <proc_mapstacks+0x52>
  }
}
    80001820:	60a6                	ld	ra,72(sp)
    80001822:	6406                	ld	s0,64(sp)
    80001824:	74e2                	ld	s1,56(sp)
    80001826:	7942                	ld	s2,48(sp)
    80001828:	79a2                	ld	s3,40(sp)
    8000182a:	7a02                	ld	s4,32(sp)
    8000182c:	6ae2                	ld	s5,24(sp)
    8000182e:	6b42                	ld	s6,16(sp)
    80001830:	6ba2                	ld	s7,8(sp)
    80001832:	6c02                	ld	s8,0(sp)
    80001834:	6161                	addi	sp,sp,80
    80001836:	8082                	ret
      panic("kalloc");
    80001838:	00006517          	auipc	a0,0x6
    8000183c:	92050513          	addi	a0,a0,-1760 # 80007158 <etext+0x158>
    80001840:	fe5fe0ef          	jal	80000824 <panic>

0000000080001844 <procinit>:

// initialize the proc table.
void procinit(void) {
    80001844:	7139                	addi	sp,sp,-64
    80001846:	fc06                	sd	ra,56(sp)
    80001848:	f822                	sd	s0,48(sp)
    8000184a:	f426                	sd	s1,40(sp)
    8000184c:	f04a                	sd	s2,32(sp)
    8000184e:	ec4e                	sd	s3,24(sp)
    80001850:	e852                	sd	s4,16(sp)
    80001852:	e456                	sd	s5,8(sp)
    80001854:	e05a                	sd	s6,0(sp)
    80001856:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001858:	00006597          	auipc	a1,0x6
    8000185c:	90858593          	addi	a1,a1,-1784 # 80007160 <etext+0x160>
    80001860:	00011517          	auipc	a0,0x11
    80001864:	ad850513          	addi	a0,a0,-1320 # 80012338 <pid_lock>
    80001868:	b36ff0ef          	jal	80000b9e <initlock>
  initlock(&wait_lock, "wait_lock");
    8000186c:	00006597          	auipc	a1,0x6
    80001870:	8fc58593          	addi	a1,a1,-1796 # 80007168 <etext+0x168>
    80001874:	00011517          	auipc	a0,0x11
    80001878:	adc50513          	addi	a0,a0,-1316 # 80012350 <wait_lock>
    8000187c:	b22ff0ef          	jal	80000b9e <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001880:	00011497          	auipc	s1,0x11
    80001884:	ee848493          	addi	s1,s1,-280 # 80012768 <proc>
    initlock(&p->lock, "proc");
    80001888:	00006b17          	auipc	s6,0x6
    8000188c:	8f0b0b13          	addi	s6,s6,-1808 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001890:	8aa6                	mv	s5,s1
    80001892:	ff4df937          	lui	s2,0xff4df
    80001896:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb275>
    8000189a:	0936                	slli	s2,s2,0xd
    8000189c:	6f590913          	addi	s2,s2,1781
    800018a0:	0936                	slli	s2,s2,0xd
    800018a2:	bd390913          	addi	s2,s2,-1069
    800018a6:	0932                	slli	s2,s2,0xc
    800018a8:	7a790913          	addi	s2,s2,1959
    800018ac:	040009b7          	lui	s3,0x4000
    800018b0:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018b2:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    800018b4:	00017a17          	auipc	s4,0x17
    800018b8:	ab4a0a13          	addi	s4,s4,-1356 # 80018368 <tickslock>
    initlock(&p->lock, "proc");
    800018bc:	85da                	mv	a1,s6
    800018be:	8526                	mv	a0,s1
    800018c0:	adeff0ef          	jal	80000b9e <initlock>
    p->state = UNUSED;
    800018c4:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    800018c8:	415487b3          	sub	a5,s1,s5
    800018cc:	8791                	srai	a5,a5,0x4
    800018ce:	032787b3          	mul	a5,a5,s2
    800018d2:	07b6                	slli	a5,a5,0xd
    800018d4:	6709                	lui	a4,0x2
    800018d6:	9fb9                	addw	a5,a5,a4
    800018d8:	40f987b3          	sub	a5,s3,a5
    800018dc:	e4bc                	sd	a5,72(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    800018de:	17048493          	addi	s1,s1,368
    800018e2:	fd449de3          	bne	s1,s4,800018bc <procinit+0x78>
  }
}
    800018e6:	70e2                	ld	ra,56(sp)
    800018e8:	7442                	ld	s0,48(sp)
    800018ea:	74a2                	ld	s1,40(sp)
    800018ec:	7902                	ld	s2,32(sp)
    800018ee:	69e2                	ld	s3,24(sp)
    800018f0:	6a42                	ld	s4,16(sp)
    800018f2:	6aa2                	ld	s5,8(sp)
    800018f4:	6b02                	ld	s6,0(sp)
    800018f6:	6121                	addi	sp,sp,64
    800018f8:	8082                	ret

00000000800018fa <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid() {
    800018fa:	1141                	addi	sp,sp,-16
    800018fc:	e406                	sd	ra,8(sp)
    800018fe:	e022                	sd	s0,0(sp)
    80001900:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    80001902:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001904:	2501                	sext.w	a0,a0
    80001906:	60a2                	ld	ra,8(sp)
    80001908:	6402                	ld	s0,0(sp)
    8000190a:	0141                	addi	sp,sp,16
    8000190c:	8082                	ret

000000008000190e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *mycpu(void) {
    8000190e:	1141                	addi	sp,sp,-16
    80001910:	e406                	sd	ra,8(sp)
    80001912:	e022                	sd	s0,0(sp)
    80001914:	0800                	addi	s0,sp,16
    80001916:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001918:	2781                	sext.w	a5,a5
    8000191a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000191c:	00011517          	auipc	a0,0x11
    80001920:	a4c50513          	addi	a0,a0,-1460 # 80012368 <cpus>
    80001924:	953e                	add	a0,a0,a5
    80001926:	60a2                	ld	ra,8(sp)
    80001928:	6402                	ld	s0,0(sp)
    8000192a:	0141                	addi	sp,sp,16
    8000192c:	8082                	ret

000000008000192e <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *myproc(void) {
    8000192e:	1101                	addi	sp,sp,-32
    80001930:	ec06                	sd	ra,24(sp)
    80001932:	e822                	sd	s0,16(sp)
    80001934:	e426                	sd	s1,8(sp)
    80001936:	1000                	addi	s0,sp,32
  push_off();
    80001938:	aacff0ef          	jal	80000be4 <push_off>
    8000193c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    8000193e:	2781                	sext.w	a5,a5
    80001940:	079e                	slli	a5,a5,0x7
    80001942:	00011717          	auipc	a4,0x11
    80001946:	9f670713          	addi	a4,a4,-1546 # 80012338 <pid_lock>
    8000194a:	97ba                	add	a5,a5,a4
    8000194c:	7b9c                	ld	a5,48(a5)
    8000194e:	84be                	mv	s1,a5
  pop_off();
    80001950:	b1cff0ef          	jal	80000c6c <pop_off>
  return p;
}
    80001954:	8526                	mv	a0,s1
    80001956:	60e2                	ld	ra,24(sp)
    80001958:	6442                	ld	s0,16(sp)
    8000195a:	64a2                	ld	s1,8(sp)
    8000195c:	6105                	addi	sp,sp,32
    8000195e:	8082                	ret

0000000080001960 <forkret>:
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void) {
    80001960:	7179                	addi	sp,sp,-48
    80001962:	f406                	sd	ra,40(sp)
    80001964:	f022                	sd	s0,32(sp)
    80001966:	ec26                	sd	s1,24(sp)
    80001968:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    8000196a:	fc5ff0ef          	jal	8000192e <myproc>
    8000196e:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001970:	b4cff0ef          	jal	80000cbc <release>

  if (first) {
    80001974:	00009797          	auipc	a5,0x9
    80001978:	86c7a783          	lw	a5,-1940(a5) # 8000a1e0 <first.1>
    8000197c:	cf95                	beqz	a5,800019b8 <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    8000197e:	4505                	li	a0,1
    80001980:	44b010ef          	jal	800035ca <fsinit>

    first = 0;
    80001984:	00009797          	auipc	a5,0x9
    80001988:	8407ae23          	sw	zero,-1956(a5) # 8000a1e0 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    8000198c:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001990:	00005797          	auipc	a5,0x5
    80001994:	7f078793          	addi	a5,a5,2032 # 80007180 <etext+0x180>
    80001998:	fcf43823          	sd	a5,-48(s0)
    8000199c:	fc043c23          	sd	zero,-40(s0)
    800019a0:	fd040593          	addi	a1,s0,-48
    800019a4:	853e                	mv	a0,a5
    800019a6:	5ad020ef          	jal	80004752 <kexec>
    800019aa:	70bc                	ld	a5,96(s1)
    800019ac:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019ae:	70bc                	ld	a5,96(s1)
    800019b0:	7bb8                	ld	a4,112(a5)
    800019b2:	57fd                	li	a5,-1
    800019b4:	02f70d63          	beq	a4,a5,800019ee <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800019b8:	385000ef          	jal	8000253c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019bc:	6ca8                	ld	a0,88(s1)
    800019be:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019c0:	04000737          	lui	a4,0x4000
    800019c4:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800019c6:	0732                	slli	a4,a4,0xc
    800019c8:	00004797          	auipc	a5,0x4
    800019cc:	6d478793          	addi	a5,a5,1748 # 8000609c <userret>
    800019d0:	00004697          	auipc	a3,0x4
    800019d4:	63068693          	addi	a3,a3,1584 # 80006000 <_trampoline>
    800019d8:	8f95                	sub	a5,a5,a3
    800019da:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019dc:	577d                	li	a4,-1
    800019de:	177e                	slli	a4,a4,0x3f
    800019e0:	8d59                	or	a0,a0,a4
    800019e2:	9782                	jalr	a5
}
    800019e4:	70a2                	ld	ra,40(sp)
    800019e6:	7402                	ld	s0,32(sp)
    800019e8:	64e2                	ld	s1,24(sp)
    800019ea:	6145                	addi	sp,sp,48
    800019ec:	8082                	ret
      panic("exec");
    800019ee:	00005517          	auipc	a0,0x5
    800019f2:	79a50513          	addi	a0,a0,1946 # 80007188 <etext+0x188>
    800019f6:	e2ffe0ef          	jal	80000824 <panic>

00000000800019fa <allocpid>:
int allocpid() {
    800019fa:	1101                	addi	sp,sp,-32
    800019fc:	ec06                	sd	ra,24(sp)
    800019fe:	e822                	sd	s0,16(sp)
    80001a00:	e426                	sd	s1,8(sp)
    80001a02:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a04:	00011517          	auipc	a0,0x11
    80001a08:	93450513          	addi	a0,a0,-1740 # 80012338 <pid_lock>
    80001a0c:	a1cff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a10:	00008797          	auipc	a5,0x8
    80001a14:	7d878793          	addi	a5,a5,2008 # 8000a1e8 <nextpid>
    80001a18:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a1a:	0014871b          	addiw	a4,s1,1
    80001a1e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a20:	00011517          	auipc	a0,0x11
    80001a24:	91850513          	addi	a0,a0,-1768 # 80012338 <pid_lock>
    80001a28:	a94ff0ef          	jal	80000cbc <release>
}
    80001a2c:	8526                	mv	a0,s1
    80001a2e:	60e2                	ld	ra,24(sp)
    80001a30:	6442                	ld	s0,16(sp)
    80001a32:	64a2                	ld	s1,8(sp)
    80001a34:	6105                	addi	sp,sp,32
    80001a36:	8082                	ret

0000000080001a38 <proc_pagetable>:
pagetable_t proc_pagetable(struct proc *p) {
    80001a38:	1101                	addi	sp,sp,-32
    80001a3a:	ec06                	sd	ra,24(sp)
    80001a3c:	e822                	sd	s0,16(sp)
    80001a3e:	e426                	sd	s1,8(sp)
    80001a40:	e04a                	sd	s2,0(sp)
    80001a42:	1000                	addi	s0,sp,32
    80001a44:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a46:	fc2ff0ef          	jal	80001208 <uvmcreate>
    80001a4a:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a4c:	cd05                	beqz	a0,80001a84 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001a4e:	4729                	li	a4,10
    80001a50:	00004697          	auipc	a3,0x4
    80001a54:	5b068693          	addi	a3,a3,1456 # 80006000 <_trampoline>
    80001a58:	6605                	lui	a2,0x1
    80001a5a:	040005b7          	lui	a1,0x4000
    80001a5e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a60:	05b2                	slli	a1,a1,0xc
    80001a62:	dfeff0ef          	jal	80001060 <mappages>
    80001a66:	02054663          	bltz	a0,80001a92 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001a6a:	4719                	li	a4,6
    80001a6c:	06093683          	ld	a3,96(s2)
    80001a70:	6605                	lui	a2,0x1
    80001a72:	020005b7          	lui	a1,0x2000
    80001a76:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a78:	05b6                	slli	a1,a1,0xd
    80001a7a:	8526                	mv	a0,s1
    80001a7c:	de4ff0ef          	jal	80001060 <mappages>
    80001a80:	00054f63          	bltz	a0,80001a9e <proc_pagetable+0x66>
}
    80001a84:	8526                	mv	a0,s1
    80001a86:	60e2                	ld	ra,24(sp)
    80001a88:	6442                	ld	s0,16(sp)
    80001a8a:	64a2                	ld	s1,8(sp)
    80001a8c:	6902                	ld	s2,0(sp)
    80001a8e:	6105                	addi	sp,sp,32
    80001a90:	8082                	ret
    uvmfree(pagetable, 0);
    80001a92:	4581                	li	a1,0
    80001a94:	8526                	mv	a0,s1
    80001a96:	96dff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001a9a:	4481                	li	s1,0
    80001a9c:	b7e5                	j	80001a84 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a9e:	4681                	li	a3,0
    80001aa0:	4605                	li	a2,1
    80001aa2:	040005b7          	lui	a1,0x4000
    80001aa6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aa8:	05b2                	slli	a1,a1,0xc
    80001aaa:	8526                	mv	a0,s1
    80001aac:	f82ff0ef          	jal	8000122e <uvmunmap>
    uvmfree(pagetable, 0);
    80001ab0:	4581                	li	a1,0
    80001ab2:	8526                	mv	a0,s1
    80001ab4:	94fff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001ab8:	4481                	li	s1,0
    80001aba:	b7e9                	j	80001a84 <proc_pagetable+0x4c>

0000000080001abc <proc_freepagetable>:
void proc_freepagetable(pagetable_t pagetable, uint64 sz) {
    80001abc:	1101                	addi	sp,sp,-32
    80001abe:	ec06                	sd	ra,24(sp)
    80001ac0:	e822                	sd	s0,16(sp)
    80001ac2:	e426                	sd	s1,8(sp)
    80001ac4:	e04a                	sd	s2,0(sp)
    80001ac6:	1000                	addi	s0,sp,32
    80001ac8:	84aa                	mv	s1,a0
    80001aca:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001acc:	4681                	li	a3,0
    80001ace:	4605                	li	a2,1
    80001ad0:	040005b7          	lui	a1,0x4000
    80001ad4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ad6:	05b2                	slli	a1,a1,0xc
    80001ad8:	f56ff0ef          	jal	8000122e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001adc:	4681                	li	a3,0
    80001ade:	4605                	li	a2,1
    80001ae0:	020005b7          	lui	a1,0x2000
    80001ae4:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ae6:	05b6                	slli	a1,a1,0xd
    80001ae8:	8526                	mv	a0,s1
    80001aea:	f44ff0ef          	jal	8000122e <uvmunmap>
  uvmfree(pagetable, sz);
    80001aee:	85ca                	mv	a1,s2
    80001af0:	8526                	mv	a0,s1
    80001af2:	911ff0ef          	jal	80001402 <uvmfree>
}
    80001af6:	60e2                	ld	ra,24(sp)
    80001af8:	6442                	ld	s0,16(sp)
    80001afa:	64a2                	ld	s1,8(sp)
    80001afc:	6902                	ld	s2,0(sp)
    80001afe:	6105                	addi	sp,sp,32
    80001b00:	8082                	ret

0000000080001b02 <freeproc>:
static void freeproc(struct proc *p) {
    80001b02:	1101                	addi	sp,sp,-32
    80001b04:	ec06                	sd	ra,24(sp)
    80001b06:	e822                	sd	s0,16(sp)
    80001b08:	e426                	sd	s1,8(sp)
    80001b0a:	1000                	addi	s0,sp,32
    80001b0c:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b0e:	7128                	ld	a0,96(a0)
    80001b10:	c119                	beqz	a0,80001b16 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001b12:	f4bfe0ef          	jal	80000a5c <kfree>
  p->trapframe = 0;
    80001b16:	0604b023          	sd	zero,96(s1)
  if (p->pagetable)
    80001b1a:	6ca8                	ld	a0,88(s1)
    80001b1c:	c501                	beqz	a0,80001b24 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b1e:	68ac                	ld	a1,80(s1)
    80001b20:	f9dff0ef          	jal	80001abc <proc_freepagetable>
  p->pagetable = 0;
    80001b24:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001b28:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001b2c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b30:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001b34:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001b38:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b3c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b40:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b44:	0004ac23          	sw	zero,24(s1)
}
    80001b48:	60e2                	ld	ra,24(sp)
    80001b4a:	6442                	ld	s0,16(sp)
    80001b4c:	64a2                	ld	s1,8(sp)
    80001b4e:	6105                	addi	sp,sp,32
    80001b50:	8082                	ret

0000000080001b52 <allocproc>:
static struct proc *allocproc(void) {
    80001b52:	1101                	addi	sp,sp,-32
    80001b54:	ec06                	sd	ra,24(sp)
    80001b56:	e822                	sd	s0,16(sp)
    80001b58:	e426                	sd	s1,8(sp)
    80001b5a:	e04a                	sd	s2,0(sp)
    80001b5c:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b5e:	00011497          	auipc	s1,0x11
    80001b62:	c0a48493          	addi	s1,s1,-1014 # 80012768 <proc>
    80001b66:	00017917          	auipc	s2,0x17
    80001b6a:	80290913          	addi	s2,s2,-2046 # 80018368 <tickslock>
    acquire(&p->lock);
    80001b6e:	8526                	mv	a0,s1
    80001b70:	8b8ff0ef          	jal	80000c28 <acquire>
    if (p->state == UNUSED) {
    80001b74:	4c9c                	lw	a5,24(s1)
    80001b76:	cb91                	beqz	a5,80001b8a <allocproc+0x38>
      release(&p->lock);
    80001b78:	8526                	mv	a0,s1
    80001b7a:	942ff0ef          	jal	80000cbc <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b7e:	17048493          	addi	s1,s1,368
    80001b82:	ff2496e3          	bne	s1,s2,80001b6e <allocproc+0x1c>
  return 0;
    80001b86:	4481                	li	s1,0
    80001b88:	a0a9                	j	80001bd2 <allocproc+0x80>
  p->pid = allocpid();
    80001b8a:	e71ff0ef          	jal	800019fa <allocpid>
    80001b8e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b90:	4785                	li	a5,1
    80001b92:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001b94:	fb1fe0ef          	jal	80000b44 <kalloc>
    80001b98:	892a                	mv	s2,a0
    80001b9a:	f0a8                	sd	a0,96(s1)
    80001b9c:	c131                	beqz	a0,80001be0 <allocproc+0x8e>
  p->pagetable = proc_pagetable(p);
    80001b9e:	8526                	mv	a0,s1
    80001ba0:	e99ff0ef          	jal	80001a38 <proc_pagetable>
    80001ba4:	892a                	mv	s2,a0
    80001ba6:	eca8                	sd	a0,88(s1)
  if (p->pagetable == 0) {
    80001ba8:	c521                	beqz	a0,80001bf0 <allocproc+0x9e>
  memset(&p->context, 0, sizeof(p->context));
    80001baa:	07000613          	li	a2,112
    80001bae:	4581                	li	a1,0
    80001bb0:	06848513          	addi	a0,s1,104
    80001bb4:	944ff0ef          	jal	80000cf8 <memset>
  p->tickets = 10;
    80001bb8:	47a9                	li	a5,10
    80001bba:	d8dc                	sw	a5,52(s1)
  p->sched_count = 0;
    80001bbc:	0204ac23          	sw	zero,56(s1)
  p->context.ra = (uint64)forkret;
    80001bc0:	00000797          	auipc	a5,0x0
    80001bc4:	da078793          	addi	a5,a5,-608 # 80001960 <forkret>
    80001bc8:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001bca:	64bc                	ld	a5,72(s1)
    80001bcc:	6705                	lui	a4,0x1
    80001bce:	97ba                	add	a5,a5,a4
    80001bd0:	f8bc                	sd	a5,112(s1)
}
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	60e2                	ld	ra,24(sp)
    80001bd6:	6442                	ld	s0,16(sp)
    80001bd8:	64a2                	ld	s1,8(sp)
    80001bda:	6902                	ld	s2,0(sp)
    80001bdc:	6105                	addi	sp,sp,32
    80001bde:	8082                	ret
    freeproc(p);
    80001be0:	8526                	mv	a0,s1
    80001be2:	f21ff0ef          	jal	80001b02 <freeproc>
    release(&p->lock);
    80001be6:	8526                	mv	a0,s1
    80001be8:	8d4ff0ef          	jal	80000cbc <release>
    return 0;
    80001bec:	84ca                	mv	s1,s2
    80001bee:	b7d5                	j	80001bd2 <allocproc+0x80>
    freeproc(p);
    80001bf0:	8526                	mv	a0,s1
    80001bf2:	f11ff0ef          	jal	80001b02 <freeproc>
    release(&p->lock);
    80001bf6:	8526                	mv	a0,s1
    80001bf8:	8c4ff0ef          	jal	80000cbc <release>
    return 0;
    80001bfc:	84ca                	mv	s1,s2
    80001bfe:	bfd1                	j	80001bd2 <allocproc+0x80>

0000000080001c00 <userinit>:
void userinit(void) {
    80001c00:	1101                	addi	sp,sp,-32
    80001c02:	ec06                	sd	ra,24(sp)
    80001c04:	e822                	sd	s0,16(sp)
    80001c06:	e426                	sd	s1,8(sp)
    80001c08:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c0a:	f49ff0ef          	jal	80001b52 <allocproc>
    80001c0e:	84aa                	mv	s1,a0
  initproc = p;
    80001c10:	00008797          	auipc	a5,0x8
    80001c14:	62a7b023          	sd	a0,1568(a5) # 8000a230 <initproc>
  p->cwd = namei("/");
    80001c18:	00005517          	auipc	a0,0x5
    80001c1c:	57850513          	addi	a0,a0,1400 # 80007190 <etext+0x190>
    80001c20:	6e5010ef          	jal	80003b04 <namei>
    80001c24:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001c28:	478d                	li	a5,3
    80001c2a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c2c:	8526                	mv	a0,s1
    80001c2e:	88eff0ef          	jal	80000cbc <release>
}
    80001c32:	60e2                	ld	ra,24(sp)
    80001c34:	6442                	ld	s0,16(sp)
    80001c36:	64a2                	ld	s1,8(sp)
    80001c38:	6105                	addi	sp,sp,32
    80001c3a:	8082                	ret

0000000080001c3c <growproc>:
int growproc(int n) {
    80001c3c:	1101                	addi	sp,sp,-32
    80001c3e:	ec06                	sd	ra,24(sp)
    80001c40:	e822                	sd	s0,16(sp)
    80001c42:	e426                	sd	s1,8(sp)
    80001c44:	e04a                	sd	s2,0(sp)
    80001c46:	1000                	addi	s0,sp,32
    80001c48:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c4a:	ce5ff0ef          	jal	8000192e <myproc>
    80001c4e:	892a                	mv	s2,a0
  sz = p->sz;
    80001c50:	692c                	ld	a1,80(a0)
  if (n > 0) {
    80001c52:	02905963          	blez	s1,80001c84 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c56:	00b48633          	add	a2,s1,a1
    80001c5a:	020007b7          	lui	a5,0x2000
    80001c5e:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c60:	07b6                	slli	a5,a5,0xd
    80001c62:	02c7ea63          	bltu	a5,a2,80001c96 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c66:	4691                	li	a3,4
    80001c68:	6d28                	ld	a0,88(a0)
    80001c6a:	e92ff0ef          	jal	800012fc <uvmalloc>
    80001c6e:	85aa                	mv	a1,a0
    80001c70:	c50d                	beqz	a0,80001c9a <growproc+0x5e>
  p->sz = sz;
    80001c72:	04b93823          	sd	a1,80(s2)
  return 0;
    80001c76:	4501                	li	a0,0
}
    80001c78:	60e2                	ld	ra,24(sp)
    80001c7a:	6442                	ld	s0,16(sp)
    80001c7c:	64a2                	ld	s1,8(sp)
    80001c7e:	6902                	ld	s2,0(sp)
    80001c80:	6105                	addi	sp,sp,32
    80001c82:	8082                	ret
  } else if (n < 0) {
    80001c84:	fe04d7e3          	bgez	s1,80001c72 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c88:	00b48633          	add	a2,s1,a1
    80001c8c:	6d28                	ld	a0,88(a0)
    80001c8e:	e2aff0ef          	jal	800012b8 <uvmdealloc>
    80001c92:	85aa                	mv	a1,a0
    80001c94:	bff9                	j	80001c72 <growproc+0x36>
      return -1;
    80001c96:	557d                	li	a0,-1
    80001c98:	b7c5                	j	80001c78 <growproc+0x3c>
      return -1;
    80001c9a:	557d                	li	a0,-1
    80001c9c:	bff1                	j	80001c78 <growproc+0x3c>

0000000080001c9e <kfork>:
int kfork(void) {
    80001c9e:	7139                	addi	sp,sp,-64
    80001ca0:	fc06                	sd	ra,56(sp)
    80001ca2:	f822                	sd	s0,48(sp)
    80001ca4:	f426                	sd	s1,40(sp)
    80001ca6:	e456                	sd	s5,8(sp)
    80001ca8:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001caa:	c85ff0ef          	jal	8000192e <myproc>
    80001cae:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001cb0:	ea3ff0ef          	jal	80001b52 <allocproc>
    80001cb4:	0e050e63          	beqz	a0,80001db0 <kfork+0x112>
    80001cb8:	ec4e                	sd	s3,24(sp)
    80001cba:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001cbc:	050ab603          	ld	a2,80(s5)
    80001cc0:	6d2c                	ld	a1,88(a0)
    80001cc2:	058ab503          	ld	a0,88(s5)
    80001cc6:	f6eff0ef          	jal	80001434 <uvmcopy>
    80001cca:	04054c63          	bltz	a0,80001d22 <kfork+0x84>
    80001cce:	f04a                	sd	s2,32(sp)
    80001cd0:	e852                	sd	s4,16(sp)
  np->tickets = p->tickets;
    80001cd2:	034aa783          	lw	a5,52(s5)
    80001cd6:	02f9aa23          	sw	a5,52(s3)
  np->sz = p->sz;
    80001cda:	050ab783          	ld	a5,80(s5)
    80001cde:	04f9b823          	sd	a5,80(s3)
  *(np->trapframe) = *(p->trapframe);
    80001ce2:	060ab683          	ld	a3,96(s5)
    80001ce6:	87b6                	mv	a5,a3
    80001ce8:	0609b703          	ld	a4,96(s3)
    80001cec:	12068693          	addi	a3,a3,288
    80001cf0:	6388                	ld	a0,0(a5)
    80001cf2:	678c                	ld	a1,8(a5)
    80001cf4:	6b90                	ld	a2,16(a5)
    80001cf6:	e308                	sd	a0,0(a4)
    80001cf8:	e70c                	sd	a1,8(a4)
    80001cfa:	eb10                	sd	a2,16(a4)
    80001cfc:	6f90                	ld	a2,24(a5)
    80001cfe:	ef10                	sd	a2,24(a4)
    80001d00:	02078793          	addi	a5,a5,32
    80001d04:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d08:	fed794e3          	bne	a5,a3,80001cf0 <kfork+0x52>
  np->trapframe->a0 = 0;
    80001d0c:	0609b783          	ld	a5,96(s3)
    80001d10:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d14:	0d8a8493          	addi	s1,s5,216
    80001d18:	0d898913          	addi	s2,s3,216
    80001d1c:	158a8a13          	addi	s4,s5,344
    80001d20:	a831                	j	80001d3c <kfork+0x9e>
    freeproc(np);
    80001d22:	854e                	mv	a0,s3
    80001d24:	ddfff0ef          	jal	80001b02 <freeproc>
    release(&np->lock);
    80001d28:	854e                	mv	a0,s3
    80001d2a:	f93fe0ef          	jal	80000cbc <release>
    return -1;
    80001d2e:	54fd                	li	s1,-1
    80001d30:	69e2                	ld	s3,24(sp)
    80001d32:	a885                	j	80001da2 <kfork+0x104>
  for (i = 0; i < NOFILE; i++)
    80001d34:	04a1                	addi	s1,s1,8
    80001d36:	0921                	addi	s2,s2,8
    80001d38:	01448963          	beq	s1,s4,80001d4a <kfork+0xac>
    if (p->ofile[i])
    80001d3c:	6088                	ld	a0,0(s1)
    80001d3e:	d97d                	beqz	a0,80001d34 <kfork+0x96>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d40:	380020ef          	jal	800040c0 <filedup>
    80001d44:	00a93023          	sd	a0,0(s2)
    80001d48:	b7f5                	j	80001d34 <kfork+0x96>
  np->cwd = idup(p->cwd);
    80001d4a:	158ab503          	ld	a0,344(s5)
    80001d4e:	552010ef          	jal	800032a0 <idup>
    80001d52:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d56:	4641                	li	a2,16
    80001d58:	160a8593          	addi	a1,s5,352
    80001d5c:	16098513          	addi	a0,s3,352
    80001d60:	8ecff0ef          	jal	80000e4c <safestrcpy>
  pid = np->pid;
    80001d64:	0309a483          	lw	s1,48(s3)
  release(&np->lock);
    80001d68:	854e                	mv	a0,s3
    80001d6a:	f53fe0ef          	jal	80000cbc <release>
  acquire(&wait_lock);
    80001d6e:	00010517          	auipc	a0,0x10
    80001d72:	5e250513          	addi	a0,a0,1506 # 80012350 <wait_lock>
    80001d76:	eb3fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001d7a:	0559b023          	sd	s5,64(s3)
  release(&wait_lock);
    80001d7e:	00010517          	auipc	a0,0x10
    80001d82:	5d250513          	addi	a0,a0,1490 # 80012350 <wait_lock>
    80001d86:	f37fe0ef          	jal	80000cbc <release>
  acquire(&np->lock);
    80001d8a:	854e                	mv	a0,s3
    80001d8c:	e9dfe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001d90:	478d                	li	a5,3
    80001d92:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001d96:	854e                	mv	a0,s3
    80001d98:	f25fe0ef          	jal	80000cbc <release>
  return pid;
    80001d9c:	7902                	ld	s2,32(sp)
    80001d9e:	69e2                	ld	s3,24(sp)
    80001da0:	6a42                	ld	s4,16(sp)
}
    80001da2:	8526                	mv	a0,s1
    80001da4:	70e2                	ld	ra,56(sp)
    80001da6:	7442                	ld	s0,48(sp)
    80001da8:	74a2                	ld	s1,40(sp)
    80001daa:	6aa2                	ld	s5,8(sp)
    80001dac:	6121                	addi	sp,sp,64
    80001dae:	8082                	ret
    return -1;
    80001db0:	54fd                	li	s1,-1
    80001db2:	bfc5                	j	80001da2 <kfork+0x104>

0000000080001db4 <scheduler>:
void scheduler(void) {
    80001db4:	ca010113          	addi	sp,sp,-864
    80001db8:	34113c23          	sd	ra,856(sp)
    80001dbc:	34813823          	sd	s0,848(sp)
    80001dc0:	34913423          	sd	s1,840(sp)
    80001dc4:	35213023          	sd	s2,832(sp)
    80001dc8:	33313c23          	sd	s3,824(sp)
    80001dcc:	33413823          	sd	s4,816(sp)
    80001dd0:	33513423          	sd	s5,808(sp)
    80001dd4:	33613023          	sd	s6,800(sp)
    80001dd8:	31713c23          	sd	s7,792(sp)
    80001ddc:	31813823          	sd	s8,784(sp)
    80001de0:	31913423          	sd	s9,776(sp)
    80001de4:	31a13023          	sd	s10,768(sp)
    80001de8:	1680                	addi	s0,sp,864
    80001dea:	8792                	mv	a5,tp
  int id = r_tp();
    80001dec:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001dee:	00779693          	slli	a3,a5,0x7
    80001df2:	00010717          	auipc	a4,0x10
    80001df6:	54670713          	addi	a4,a4,1350 # 80012338 <pid_lock>
    80001dfa:	9736                	add	a4,a4,a3
    80001dfc:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &winner->context);
    80001e00:	00010717          	auipc	a4,0x10
    80001e04:	57070713          	addi	a4,a4,1392 # 80012370 <cpus+0x8>
    80001e08:	9736                	add	a4,a4,a3
    80001e0a:	8d3a                	mv	s10,a4
        runnable[count] = p;
    80001e0c:	da040b13          	addi	s6,s0,-608
        cumulative[count] = total + t;
    80001e10:	ca040b93          	addi	s7,s0,-864
      c->proc = winner;
    80001e14:	00010c97          	auipc	s9,0x10
    80001e18:	524c8c93          	addi	s9,s9,1316 # 80012338 <pid_lock>
    80001e1c:	9cb6                	add	s9,s9,a3
    80001e1e:	a0a9                	j	80001e68 <scheduler+0xb4>
        runnable[count] = p;
    80001e20:	00391713          	slli	a4,s2,0x3
    80001e24:	975a                	add	a4,a4,s6
    80001e26:	e304                	sd	s1,0(a4)
        cumulative[count] = total + t;
    80001e28:	00fa87bb          	addw	a5,s5,a5
    80001e2c:	8abe                	mv	s5,a5
    80001e2e:	00291713          	slli	a4,s2,0x2
    80001e32:	975e                	add	a4,a4,s7
    80001e34:	c31c                	sw	a5,0(a4)
        count++;
    80001e36:	2905                	addiw	s2,s2,1
      release(&p->lock);
    80001e38:	8526                	mv	a0,s1
    80001e3a:	e83fe0ef          	jal	80000cbc <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e3e:	17048493          	addi	s1,s1,368
    80001e42:	01348f63          	beq	s1,s3,80001e60 <scheduler+0xac>
      acquire(&p->lock);
    80001e46:	8526                	mv	a0,s1
    80001e48:	de1fe0ef          	jal	80000c28 <acquire>
      if (p->state == RUNNABLE) {
    80001e4c:	4c9c                	lw	a5,24(s1)
    80001e4e:	ff4795e3          	bne	a5,s4,80001e38 <scheduler+0x84>
        if (t < 1)
    80001e52:	58d8                	lw	a4,52(s1)
    80001e54:	87ba                	mv	a5,a4
    80001e56:	2701                	sext.w	a4,a4
    80001e58:	fce044e3          	bgtz	a4,80001e20 <scheduler+0x6c>
    80001e5c:	87e2                	mv	a5,s8
    80001e5e:	b7c9                	j	80001e20 <scheduler+0x6c>
    if (count == 0) {
    80001e60:	02091c63          	bnez	s2,80001e98 <scheduler+0xe4>
      asm volatile("wfi");
    80001e64:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001e68:	100027f3          	csrr	a5,sstatus
static inline void intr_on() { w_sstatus(r_sstatus() | SSTATUS_SIE); }
    80001e6c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80001e70:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001e74:	100027f3          	csrr	a5,sstatus
static inline void intr_off() { w_sstatus(r_sstatus() & ~SSTATUS_SIE); }
    80001e78:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80001e7a:	10079073          	csrw	sstatus,a5
    int total = 0;
    80001e7e:	4a81                	li	s5,0
    int count = 0;
    80001e80:	4901                	li	s2,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e82:	00011497          	auipc	s1,0x11
    80001e86:	8e648493          	addi	s1,s1,-1818 # 80012768 <proc>
      if (p->state == RUNNABLE) {
    80001e8a:	4a0d                	li	s4,3
        if (t < 1)
    80001e8c:	4c05                	li	s8,1
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e8e:	00016997          	auipc	s3,0x16
    80001e92:	4da98993          	addi	s3,s3,1242 # 80018368 <tickslock>
    80001e96:	bf45                	j	80001e46 <scheduler+0x92>
  rand_state = rand_state * 1664525 + 1013904223;
    80001e98:	00008697          	auipc	a3,0x8
    80001e9c:	34c68693          	addi	a3,a3,844 # 8000a1e4 <rand_state>
    80001ea0:	429c                	lw	a5,0(a3)
    80001ea2:	00196737          	lui	a4,0x196
    80001ea6:	60d7071b          	addiw	a4,a4,1549 # 19660d <_entry-0x7fe699f3>
    80001eaa:	02f7073b          	mulw	a4,a4,a5
    80001eae:	3c6ef7b7          	lui	a5,0x3c6ef
    80001eb2:	35f7879b          	addiw	a5,a5,863 # 3c6ef35f <_entry-0x43910ca1>
    80001eb6:	9fb9                	addw	a5,a5,a4
    80001eb8:	c29c                	sw	a5,0(a3)
    for (int i = 0; i < count; i++) {
    80001eba:	fb2057e3          	blez	s2,80001e68 <scheduler+0xb4>
    int ticket_no = (krand() % total) + 1;
    80001ebe:	0357f7bb          	remuw	a5,a5,s5
    80001ec2:	0017861b          	addiw	a2,a5,1
    80001ec6:	ca040713          	addi	a4,s0,-864
    for (int i = 0; i < count; i++) {
    80001eca:	4781                	li	a5,0
      if (cumulative[i] >= ticket_no) {
    80001ecc:	4314                	lw	a3,0(a4)
    80001ece:	00c6d763          	bge	a3,a2,80001edc <scheduler+0x128>
    for (int i = 0; i < count; i++) {
    80001ed2:	2785                	addiw	a5,a5,1
    80001ed4:	0711                	addi	a4,a4,4
    80001ed6:	fef91be3          	bne	s2,a5,80001ecc <scheduler+0x118>
    80001eda:	b779                	j	80001e68 <scheduler+0xb4>
        winner = runnable[i];
    80001edc:	078e                	slli	a5,a5,0x3
    80001ede:	97da                	add	a5,a5,s6
    80001ee0:	6384                	ld	s1,0(a5)
    if (winner == 0)
    80001ee2:	d0d9                	beqz	s1,80001e68 <scheduler+0xb4>
    acquire(&winner->lock);
    80001ee4:	8526                	mv	a0,s1
    80001ee6:	d43fe0ef          	jal	80000c28 <acquire>
    if (winner->state == RUNNABLE) {
    80001eea:	4c98                	lw	a4,24(s1)
    80001eec:	478d                	li	a5,3
    80001eee:	00f70663          	beq	a4,a5,80001efa <scheduler+0x146>
    release(&winner->lock);
    80001ef2:	8526                	mv	a0,s1
    80001ef4:	dc9fe0ef          	jal	80000cbc <release>
    80001ef8:	bf85                	j	80001e68 <scheduler+0xb4>
      winner->state = RUNNING;
    80001efa:	4791                	li	a5,4
    80001efc:	cc9c                	sw	a5,24(s1)
      winner->sched_count++;
    80001efe:	5c9c                	lw	a5,56(s1)
    80001f00:	2785                	addiw	a5,a5,1
    80001f02:	dc9c                	sw	a5,56(s1)
      c->proc = winner;
    80001f04:	029cb823          	sd	s1,48(s9)
      swtch(&c->context, &winner->context);
    80001f08:	06848593          	addi	a1,s1,104
    80001f0c:	856a                	mv	a0,s10
    80001f0e:	584000ef          	jal	80002492 <swtch>
      c->proc = 0;
    80001f12:	020cb823          	sd	zero,48(s9)
    80001f16:	bff1                	j	80001ef2 <scheduler+0x13e>

0000000080001f18 <sched>:
void sched(void) {
    80001f18:	7179                	addi	sp,sp,-48
    80001f1a:	f406                	sd	ra,40(sp)
    80001f1c:	f022                	sd	s0,32(sp)
    80001f1e:	ec26                	sd	s1,24(sp)
    80001f20:	e84a                	sd	s2,16(sp)
    80001f22:	e44e                	sd	s3,8(sp)
    80001f24:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f26:	a09ff0ef          	jal	8000192e <myproc>
    80001f2a:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001f2c:	c8dfe0ef          	jal	80000bb8 <holding>
    80001f30:	c935                	beqz	a0,80001fa4 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f32:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001f34:	2781                	sext.w	a5,a5
    80001f36:	079e                	slli	a5,a5,0x7
    80001f38:	00010717          	auipc	a4,0x10
    80001f3c:	40070713          	addi	a4,a4,1024 # 80012338 <pid_lock>
    80001f40:	97ba                	add	a5,a5,a4
    80001f42:	0a87a703          	lw	a4,168(a5)
    80001f46:	4785                	li	a5,1
    80001f48:	06f71463          	bne	a4,a5,80001fb0 <sched+0x98>
  if (p->state == RUNNING)
    80001f4c:	4c98                	lw	a4,24(s1)
    80001f4e:	4791                	li	a5,4
    80001f50:	06f70663          	beq	a4,a5,80001fbc <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001f54:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f58:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001f5a:	e7bd                	bnez	a5,80001fc8 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f5c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f5e:	00010917          	auipc	s2,0x10
    80001f62:	3da90913          	addi	s2,s2,986 # 80012338 <pid_lock>
    80001f66:	2781                	sext.w	a5,a5
    80001f68:	079e                	slli	a5,a5,0x7
    80001f6a:	97ca                	add	a5,a5,s2
    80001f6c:	0ac7a983          	lw	s3,172(a5)
    80001f70:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f72:	2781                	sext.w	a5,a5
    80001f74:	079e                	slli	a5,a5,0x7
    80001f76:	07a1                	addi	a5,a5,8
    80001f78:	00010597          	auipc	a1,0x10
    80001f7c:	3f058593          	addi	a1,a1,1008 # 80012368 <cpus>
    80001f80:	95be                	add	a1,a1,a5
    80001f82:	06848513          	addi	a0,s1,104
    80001f86:	50c000ef          	jal	80002492 <swtch>
    80001f8a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f8c:	2781                	sext.w	a5,a5
    80001f8e:	079e                	slli	a5,a5,0x7
    80001f90:	993e                	add	s2,s2,a5
    80001f92:	0b392623          	sw	s3,172(s2)
}
    80001f96:	70a2                	ld	ra,40(sp)
    80001f98:	7402                	ld	s0,32(sp)
    80001f9a:	64e2                	ld	s1,24(sp)
    80001f9c:	6942                	ld	s2,16(sp)
    80001f9e:	69a2                	ld	s3,8(sp)
    80001fa0:	6145                	addi	sp,sp,48
    80001fa2:	8082                	ret
    panic("sched p->lock");
    80001fa4:	00005517          	auipc	a0,0x5
    80001fa8:	1f450513          	addi	a0,a0,500 # 80007198 <etext+0x198>
    80001fac:	879fe0ef          	jal	80000824 <panic>
    panic("sched locks");
    80001fb0:	00005517          	auipc	a0,0x5
    80001fb4:	1f850513          	addi	a0,a0,504 # 800071a8 <etext+0x1a8>
    80001fb8:	86dfe0ef          	jal	80000824 <panic>
    panic("sched RUNNING");
    80001fbc:	00005517          	auipc	a0,0x5
    80001fc0:	1fc50513          	addi	a0,a0,508 # 800071b8 <etext+0x1b8>
    80001fc4:	861fe0ef          	jal	80000824 <panic>
    panic("sched interruptible");
    80001fc8:	00005517          	auipc	a0,0x5
    80001fcc:	20050513          	addi	a0,a0,512 # 800071c8 <etext+0x1c8>
    80001fd0:	855fe0ef          	jal	80000824 <panic>

0000000080001fd4 <yield>:
void yield(void) {
    80001fd4:	1101                	addi	sp,sp,-32
    80001fd6:	ec06                	sd	ra,24(sp)
    80001fd8:	e822                	sd	s0,16(sp)
    80001fda:	e426                	sd	s1,8(sp)
    80001fdc:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001fde:	951ff0ef          	jal	8000192e <myproc>
    80001fe2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001fe4:	c45fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80001fe8:	478d                	li	a5,3
    80001fea:	cc9c                	sw	a5,24(s1)
  sched();
    80001fec:	f2dff0ef          	jal	80001f18 <sched>
  release(&p->lock);
    80001ff0:	8526                	mv	a0,s1
    80001ff2:	ccbfe0ef          	jal	80000cbc <release>
}
    80001ff6:	60e2                	ld	ra,24(sp)
    80001ff8:	6442                	ld	s0,16(sp)
    80001ffa:	64a2                	ld	s1,8(sp)
    80001ffc:	6105                	addi	sp,sp,32
    80001ffe:	8082                	ret

0000000080002000 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void sleep(void *chan, struct spinlock *lk) {
    80002000:	7179                	addi	sp,sp,-48
    80002002:	f406                	sd	ra,40(sp)
    80002004:	f022                	sd	s0,32(sp)
    80002006:	ec26                	sd	s1,24(sp)
    80002008:	e84a                	sd	s2,16(sp)
    8000200a:	e44e                	sd	s3,8(sp)
    8000200c:	1800                	addi	s0,sp,48
    8000200e:	89aa                	mv	s3,a0
    80002010:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002012:	91dff0ef          	jal	8000192e <myproc>
    80002016:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002018:	c11fe0ef          	jal	80000c28 <acquire>
  release(lk);
    8000201c:	854a                	mv	a0,s2
    8000201e:	c9ffe0ef          	jal	80000cbc <release>

  // Go to sleep.
  p->chan = chan;
    80002022:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002026:	4789                	li	a5,2
    80002028:	cc9c                	sw	a5,24(s1)

  sched();
    8000202a:	eefff0ef          	jal	80001f18 <sched>

  // Tidy up.
  p->chan = 0;
    8000202e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002032:	8526                	mv	a0,s1
    80002034:	c89fe0ef          	jal	80000cbc <release>
  acquire(lk);
    80002038:	854a                	mv	a0,s2
    8000203a:	beffe0ef          	jal	80000c28 <acquire>
}
    8000203e:	70a2                	ld	ra,40(sp)
    80002040:	7402                	ld	s0,32(sp)
    80002042:	64e2                	ld	s1,24(sp)
    80002044:	6942                	ld	s2,16(sp)
    80002046:	69a2                	ld	s3,8(sp)
    80002048:	6145                	addi	sp,sp,48
    8000204a:	8082                	ret

000000008000204c <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void wakeup(void *chan) {
    8000204c:	7139                	addi	sp,sp,-64
    8000204e:	fc06                	sd	ra,56(sp)
    80002050:	f822                	sd	s0,48(sp)
    80002052:	f426                	sd	s1,40(sp)
    80002054:	f04a                	sd	s2,32(sp)
    80002056:	ec4e                	sd	s3,24(sp)
    80002058:	e852                	sd	s4,16(sp)
    8000205a:	e456                	sd	s5,8(sp)
    8000205c:	0080                	addi	s0,sp,64
    8000205e:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002060:	00010497          	auipc	s1,0x10
    80002064:	70848493          	addi	s1,s1,1800 # 80012768 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    80002068:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000206a:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    8000206c:	00016917          	auipc	s2,0x16
    80002070:	2fc90913          	addi	s2,s2,764 # 80018368 <tickslock>
    80002074:	a801                	j	80002084 <wakeup+0x38>
      }
      release(&p->lock);
    80002076:	8526                	mv	a0,s1
    80002078:	c45fe0ef          	jal	80000cbc <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000207c:	17048493          	addi	s1,s1,368
    80002080:	03248263          	beq	s1,s2,800020a4 <wakeup+0x58>
    if (p != myproc()) {
    80002084:	8abff0ef          	jal	8000192e <myproc>
    80002088:	fe950ae3          	beq	a0,s1,8000207c <wakeup+0x30>
      acquire(&p->lock);
    8000208c:	8526                	mv	a0,s1
    8000208e:	b9bfe0ef          	jal	80000c28 <acquire>
      if (p->state == SLEEPING && p->chan == chan) {
    80002092:	4c9c                	lw	a5,24(s1)
    80002094:	ff3791e3          	bne	a5,s3,80002076 <wakeup+0x2a>
    80002098:	709c                	ld	a5,32(s1)
    8000209a:	fd479ee3          	bne	a5,s4,80002076 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000209e:	0154ac23          	sw	s5,24(s1)
    800020a2:	bfd1                	j	80002076 <wakeup+0x2a>
    }
  }
}
    800020a4:	70e2                	ld	ra,56(sp)
    800020a6:	7442                	ld	s0,48(sp)
    800020a8:	74a2                	ld	s1,40(sp)
    800020aa:	7902                	ld	s2,32(sp)
    800020ac:	69e2                	ld	s3,24(sp)
    800020ae:	6a42                	ld	s4,16(sp)
    800020b0:	6aa2                	ld	s5,8(sp)
    800020b2:	6121                	addi	sp,sp,64
    800020b4:	8082                	ret

00000000800020b6 <reparent>:
void reparent(struct proc *p) {
    800020b6:	7179                	addi	sp,sp,-48
    800020b8:	f406                	sd	ra,40(sp)
    800020ba:	f022                	sd	s0,32(sp)
    800020bc:	ec26                	sd	s1,24(sp)
    800020be:	e84a                	sd	s2,16(sp)
    800020c0:	e44e                	sd	s3,8(sp)
    800020c2:	e052                	sd	s4,0(sp)
    800020c4:	1800                	addi	s0,sp,48
    800020c6:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800020c8:	00010497          	auipc	s1,0x10
    800020cc:	6a048493          	addi	s1,s1,1696 # 80012768 <proc>
      pp->parent = initproc;
    800020d0:	00008a17          	auipc	s4,0x8
    800020d4:	160a0a13          	addi	s4,s4,352 # 8000a230 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800020d8:	00016997          	auipc	s3,0x16
    800020dc:	29098993          	addi	s3,s3,656 # 80018368 <tickslock>
    800020e0:	a029                	j	800020ea <reparent+0x34>
    800020e2:	17048493          	addi	s1,s1,368
    800020e6:	01348b63          	beq	s1,s3,800020fc <reparent+0x46>
    if (pp->parent == p) {
    800020ea:	60bc                	ld	a5,64(s1)
    800020ec:	ff279be3          	bne	a5,s2,800020e2 <reparent+0x2c>
      pp->parent = initproc;
    800020f0:	000a3503          	ld	a0,0(s4)
    800020f4:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    800020f6:	f57ff0ef          	jal	8000204c <wakeup>
    800020fa:	b7e5                	j	800020e2 <reparent+0x2c>
}
    800020fc:	70a2                	ld	ra,40(sp)
    800020fe:	7402                	ld	s0,32(sp)
    80002100:	64e2                	ld	s1,24(sp)
    80002102:	6942                	ld	s2,16(sp)
    80002104:	69a2                	ld	s3,8(sp)
    80002106:	6a02                	ld	s4,0(sp)
    80002108:	6145                	addi	sp,sp,48
    8000210a:	8082                	ret

000000008000210c <kexit>:
void kexit(int status) {
    8000210c:	7179                	addi	sp,sp,-48
    8000210e:	f406                	sd	ra,40(sp)
    80002110:	f022                	sd	s0,32(sp)
    80002112:	ec26                	sd	s1,24(sp)
    80002114:	e84a                	sd	s2,16(sp)
    80002116:	e44e                	sd	s3,8(sp)
    80002118:	e052                	sd	s4,0(sp)
    8000211a:	1800                	addi	s0,sp,48
    8000211c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000211e:	811ff0ef          	jal	8000192e <myproc>
    80002122:	89aa                	mv	s3,a0
  if (p == initproc)
    80002124:	00008797          	auipc	a5,0x8
    80002128:	10c7b783          	ld	a5,268(a5) # 8000a230 <initproc>
    8000212c:	0d850493          	addi	s1,a0,216
    80002130:	15850913          	addi	s2,a0,344
    80002134:	00a79b63          	bne	a5,a0,8000214a <kexit+0x3e>
    panic("init exiting");
    80002138:	00005517          	auipc	a0,0x5
    8000213c:	0a850513          	addi	a0,a0,168 # 800071e0 <etext+0x1e0>
    80002140:	ee4fe0ef          	jal	80000824 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002144:	04a1                	addi	s1,s1,8
    80002146:	01248963          	beq	s1,s2,80002158 <kexit+0x4c>
    if (p->ofile[fd]) {
    8000214a:	6088                	ld	a0,0(s1)
    8000214c:	dd65                	beqz	a0,80002144 <kexit+0x38>
      fileclose(f);
    8000214e:	7b9010ef          	jal	80004106 <fileclose>
      p->ofile[fd] = 0;
    80002152:	0004b023          	sd	zero,0(s1)
    80002156:	b7fd                	j	80002144 <kexit+0x38>
  begin_op();
    80002158:	38b010ef          	jal	80003ce2 <begin_op>
  iput(p->cwd);
    8000215c:	1589b503          	ld	a0,344(s3)
    80002160:	2f8010ef          	jal	80003458 <iput>
  end_op();
    80002164:	3ef010ef          	jal	80003d52 <end_op>
  p->cwd = 0;
    80002168:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    8000216c:	00010517          	auipc	a0,0x10
    80002170:	1e450513          	addi	a0,a0,484 # 80012350 <wait_lock>
    80002174:	ab5fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    80002178:	854e                	mv	a0,s3
    8000217a:	f3dff0ef          	jal	800020b6 <reparent>
  wakeup(p->parent);
    8000217e:	0409b503          	ld	a0,64(s3)
    80002182:	ecbff0ef          	jal	8000204c <wakeup>
  acquire(&p->lock);
    80002186:	854e                	mv	a0,s3
    80002188:	aa1fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    8000218c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002190:	4795                	li	a5,5
    80002192:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002196:	00010517          	auipc	a0,0x10
    8000219a:	1ba50513          	addi	a0,a0,442 # 80012350 <wait_lock>
    8000219e:	b1ffe0ef          	jal	80000cbc <release>
  sched();
    800021a2:	d77ff0ef          	jal	80001f18 <sched>
  panic("zombie exit");
    800021a6:	00005517          	auipc	a0,0x5
    800021aa:	04a50513          	addi	a0,a0,74 # 800071f0 <etext+0x1f0>
    800021ae:	e76fe0ef          	jal	80000824 <panic>

00000000800021b2 <kkill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kkill(int pid) {
    800021b2:	7179                	addi	sp,sp,-48
    800021b4:	f406                	sd	ra,40(sp)
    800021b6:	f022                	sd	s0,32(sp)
    800021b8:	ec26                	sd	s1,24(sp)
    800021ba:	e84a                	sd	s2,16(sp)
    800021bc:	e44e                	sd	s3,8(sp)
    800021be:	1800                	addi	s0,sp,48
    800021c0:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800021c2:	00010497          	auipc	s1,0x10
    800021c6:	5a648493          	addi	s1,s1,1446 # 80012768 <proc>
    800021ca:	00016997          	auipc	s3,0x16
    800021ce:	19e98993          	addi	s3,s3,414 # 80018368 <tickslock>
    acquire(&p->lock);
    800021d2:	8526                	mv	a0,s1
    800021d4:	a55fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid) {
    800021d8:	589c                	lw	a5,48(s1)
    800021da:	01278b63          	beq	a5,s2,800021f0 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800021de:	8526                	mv	a0,s1
    800021e0:	addfe0ef          	jal	80000cbc <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800021e4:	17048493          	addi	s1,s1,368
    800021e8:	ff3495e3          	bne	s1,s3,800021d2 <kkill+0x20>
  }
  return -1;
    800021ec:	557d                	li	a0,-1
    800021ee:	a819                	j	80002204 <kkill+0x52>
      p->killed = 1;
    800021f0:	4785                	li	a5,1
    800021f2:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    800021f4:	4c98                	lw	a4,24(s1)
    800021f6:	4789                	li	a5,2
    800021f8:	00f70d63          	beq	a4,a5,80002212 <kkill+0x60>
      release(&p->lock);
    800021fc:	8526                	mv	a0,s1
    800021fe:	abffe0ef          	jal	80000cbc <release>
      return 0;
    80002202:	4501                	li	a0,0
}
    80002204:	70a2                	ld	ra,40(sp)
    80002206:	7402                	ld	s0,32(sp)
    80002208:	64e2                	ld	s1,24(sp)
    8000220a:	6942                	ld	s2,16(sp)
    8000220c:	69a2                	ld	s3,8(sp)
    8000220e:	6145                	addi	sp,sp,48
    80002210:	8082                	ret
        p->state = RUNNABLE;
    80002212:	478d                	li	a5,3
    80002214:	cc9c                	sw	a5,24(s1)
    80002216:	b7dd                	j	800021fc <kkill+0x4a>

0000000080002218 <setkilled>:

void setkilled(struct proc *p) {
    80002218:	1101                	addi	sp,sp,-32
    8000221a:	ec06                	sd	ra,24(sp)
    8000221c:	e822                	sd	s0,16(sp)
    8000221e:	e426                	sd	s1,8(sp)
    80002220:	1000                	addi	s0,sp,32
    80002222:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002224:	a05fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    80002228:	4785                	li	a5,1
    8000222a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000222c:	8526                	mv	a0,s1
    8000222e:	a8ffe0ef          	jal	80000cbc <release>
}
    80002232:	60e2                	ld	ra,24(sp)
    80002234:	6442                	ld	s0,16(sp)
    80002236:	64a2                	ld	s1,8(sp)
    80002238:	6105                	addi	sp,sp,32
    8000223a:	8082                	ret

000000008000223c <killed>:

int killed(struct proc *p) {
    8000223c:	1101                	addi	sp,sp,-32
    8000223e:	ec06                	sd	ra,24(sp)
    80002240:	e822                	sd	s0,16(sp)
    80002242:	e426                	sd	s1,8(sp)
    80002244:	e04a                	sd	s2,0(sp)
    80002246:	1000                	addi	s0,sp,32
    80002248:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000224a:	9dffe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    8000224e:	549c                	lw	a5,40(s1)
    80002250:	893e                	mv	s2,a5
  release(&p->lock);
    80002252:	8526                	mv	a0,s1
    80002254:	a69fe0ef          	jal	80000cbc <release>
  return k;
}
    80002258:	854a                	mv	a0,s2
    8000225a:	60e2                	ld	ra,24(sp)
    8000225c:	6442                	ld	s0,16(sp)
    8000225e:	64a2                	ld	s1,8(sp)
    80002260:	6902                	ld	s2,0(sp)
    80002262:	6105                	addi	sp,sp,32
    80002264:	8082                	ret

0000000080002266 <kwait>:
int kwait(uint64 addr) {
    80002266:	715d                	addi	sp,sp,-80
    80002268:	e486                	sd	ra,72(sp)
    8000226a:	e0a2                	sd	s0,64(sp)
    8000226c:	fc26                	sd	s1,56(sp)
    8000226e:	f84a                	sd	s2,48(sp)
    80002270:	f44e                	sd	s3,40(sp)
    80002272:	f052                	sd	s4,32(sp)
    80002274:	ec56                	sd	s5,24(sp)
    80002276:	e85a                	sd	s6,16(sp)
    80002278:	e45e                	sd	s7,8(sp)
    8000227a:	0880                	addi	s0,sp,80
    8000227c:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    8000227e:	eb0ff0ef          	jal	8000192e <myproc>
    80002282:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002284:	00010517          	auipc	a0,0x10
    80002288:	0cc50513          	addi	a0,a0,204 # 80012350 <wait_lock>
    8000228c:	99dfe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    80002290:	4a15                	li	s4,5
        havekids = 1;
    80002292:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002294:	00016997          	auipc	s3,0x16
    80002298:	0d498993          	addi	s3,s3,212 # 80018368 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000229c:	00010b17          	auipc	s6,0x10
    800022a0:	0b4b0b13          	addi	s6,s6,180 # 80012350 <wait_lock>
    800022a4:	a869                	j	8000233e <kwait+0xd8>
          pid = pp->pid;
    800022a6:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800022aa:	000b8c63          	beqz	s7,800022c2 <kwait+0x5c>
    800022ae:	4691                	li	a3,4
    800022b0:	02c48613          	addi	a2,s1,44
    800022b4:	85de                	mv	a1,s7
    800022b6:	05893503          	ld	a0,88(s2)
    800022ba:	b9aff0ef          	jal	80001654 <copyout>
    800022be:	02054a63          	bltz	a0,800022f2 <kwait+0x8c>
          freeproc(pp);
    800022c2:	8526                	mv	a0,s1
    800022c4:	83fff0ef          	jal	80001b02 <freeproc>
          release(&pp->lock);
    800022c8:	8526                	mv	a0,s1
    800022ca:	9f3fe0ef          	jal	80000cbc <release>
          release(&wait_lock);
    800022ce:	00010517          	auipc	a0,0x10
    800022d2:	08250513          	addi	a0,a0,130 # 80012350 <wait_lock>
    800022d6:	9e7fe0ef          	jal	80000cbc <release>
}
    800022da:	854e                	mv	a0,s3
    800022dc:	60a6                	ld	ra,72(sp)
    800022de:	6406                	ld	s0,64(sp)
    800022e0:	74e2                	ld	s1,56(sp)
    800022e2:	7942                	ld	s2,48(sp)
    800022e4:	79a2                	ld	s3,40(sp)
    800022e6:	7a02                	ld	s4,32(sp)
    800022e8:	6ae2                	ld	s5,24(sp)
    800022ea:	6b42                	ld	s6,16(sp)
    800022ec:	6ba2                	ld	s7,8(sp)
    800022ee:	6161                	addi	sp,sp,80
    800022f0:	8082                	ret
            release(&pp->lock);
    800022f2:	8526                	mv	a0,s1
    800022f4:	9c9fe0ef          	jal	80000cbc <release>
            release(&wait_lock);
    800022f8:	00010517          	auipc	a0,0x10
    800022fc:	05850513          	addi	a0,a0,88 # 80012350 <wait_lock>
    80002300:	9bdfe0ef          	jal	80000cbc <release>
            return -1;
    80002304:	59fd                	li	s3,-1
    80002306:	bfd1                	j	800022da <kwait+0x74>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002308:	17048493          	addi	s1,s1,368
    8000230c:	03348063          	beq	s1,s3,8000232c <kwait+0xc6>
      if (pp->parent == p) {
    80002310:	60bc                	ld	a5,64(s1)
    80002312:	ff279be3          	bne	a5,s2,80002308 <kwait+0xa2>
        acquire(&pp->lock);
    80002316:	8526                	mv	a0,s1
    80002318:	911fe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE) {
    8000231c:	4c9c                	lw	a5,24(s1)
    8000231e:	f94784e3          	beq	a5,s4,800022a6 <kwait+0x40>
        release(&pp->lock);
    80002322:	8526                	mv	a0,s1
    80002324:	999fe0ef          	jal	80000cbc <release>
        havekids = 1;
    80002328:	8756                	mv	a4,s5
    8000232a:	bff9                	j	80002308 <kwait+0xa2>
    if (!havekids || killed(p)) {
    8000232c:	cf19                	beqz	a4,8000234a <kwait+0xe4>
    8000232e:	854a                	mv	a0,s2
    80002330:	f0dff0ef          	jal	8000223c <killed>
    80002334:	e919                	bnez	a0,8000234a <kwait+0xe4>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002336:	85da                	mv	a1,s6
    80002338:	854a                	mv	a0,s2
    8000233a:	cc7ff0ef          	jal	80002000 <sleep>
    havekids = 0;
    8000233e:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002340:	00010497          	auipc	s1,0x10
    80002344:	42848493          	addi	s1,s1,1064 # 80012768 <proc>
    80002348:	b7e1                	j	80002310 <kwait+0xaa>
      release(&wait_lock);
    8000234a:	00010517          	auipc	a0,0x10
    8000234e:	00650513          	addi	a0,a0,6 # 80012350 <wait_lock>
    80002352:	96bfe0ef          	jal	80000cbc <release>
      return -1;
    80002356:	59fd                	li	s3,-1
    80002358:	b749                	j	800022da <kwait+0x74>

000000008000235a <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len) {
    8000235a:	7179                	addi	sp,sp,-48
    8000235c:	f406                	sd	ra,40(sp)
    8000235e:	f022                	sd	s0,32(sp)
    80002360:	ec26                	sd	s1,24(sp)
    80002362:	e84a                	sd	s2,16(sp)
    80002364:	e44e                	sd	s3,8(sp)
    80002366:	e052                	sd	s4,0(sp)
    80002368:	1800                	addi	s0,sp,48
    8000236a:	84aa                	mv	s1,a0
    8000236c:	8a2e                	mv	s4,a1
    8000236e:	89b2                	mv	s3,a2
    80002370:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002372:	dbcff0ef          	jal	8000192e <myproc>
  if (user_dst) {
    80002376:	cc99                	beqz	s1,80002394 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002378:	86ca                	mv	a3,s2
    8000237a:	864e                	mv	a2,s3
    8000237c:	85d2                	mv	a1,s4
    8000237e:	6d28                	ld	a0,88(a0)
    80002380:	ad4ff0ef          	jal	80001654 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002384:	70a2                	ld	ra,40(sp)
    80002386:	7402                	ld	s0,32(sp)
    80002388:	64e2                	ld	s1,24(sp)
    8000238a:	6942                	ld	s2,16(sp)
    8000238c:	69a2                	ld	s3,8(sp)
    8000238e:	6a02                	ld	s4,0(sp)
    80002390:	6145                	addi	sp,sp,48
    80002392:	8082                	ret
    memmove((char *)dst, src, len);
    80002394:	0009061b          	sext.w	a2,s2
    80002398:	85ce                	mv	a1,s3
    8000239a:	8552                	mv	a0,s4
    8000239c:	9bdfe0ef          	jal	80000d58 <memmove>
    return 0;
    800023a0:	8526                	mv	a0,s1
    800023a2:	b7cd                	j	80002384 <either_copyout+0x2a>

00000000800023a4 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len) {
    800023a4:	7179                	addi	sp,sp,-48
    800023a6:	f406                	sd	ra,40(sp)
    800023a8:	f022                	sd	s0,32(sp)
    800023aa:	ec26                	sd	s1,24(sp)
    800023ac:	e84a                	sd	s2,16(sp)
    800023ae:	e44e                	sd	s3,8(sp)
    800023b0:	e052                	sd	s4,0(sp)
    800023b2:	1800                	addi	s0,sp,48
    800023b4:	8a2a                	mv	s4,a0
    800023b6:	84ae                	mv	s1,a1
    800023b8:	89b2                	mv	s3,a2
    800023ba:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800023bc:	d72ff0ef          	jal	8000192e <myproc>
  if (user_src) {
    800023c0:	cc99                	beqz	s1,800023de <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800023c2:	86ca                	mv	a3,s2
    800023c4:	864e                	mv	a2,s3
    800023c6:	85d2                	mv	a1,s4
    800023c8:	6d28                	ld	a0,88(a0)
    800023ca:	b48ff0ef          	jal	80001712 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800023ce:	70a2                	ld	ra,40(sp)
    800023d0:	7402                	ld	s0,32(sp)
    800023d2:	64e2                	ld	s1,24(sp)
    800023d4:	6942                	ld	s2,16(sp)
    800023d6:	69a2                	ld	s3,8(sp)
    800023d8:	6a02                	ld	s4,0(sp)
    800023da:	6145                	addi	sp,sp,48
    800023dc:	8082                	ret
    memmove(dst, (char *)src, len);
    800023de:	0009061b          	sext.w	a2,s2
    800023e2:	85ce                	mv	a1,s3
    800023e4:	8552                	mv	a0,s4
    800023e6:	973fe0ef          	jal	80000d58 <memmove>
    return 0;
    800023ea:	8526                	mv	a0,s1
    800023ec:	b7cd                	j	800023ce <either_copyin+0x2a>

00000000800023ee <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void) {
    800023ee:	715d                	addi	sp,sp,-80
    800023f0:	e486                	sd	ra,72(sp)
    800023f2:	e0a2                	sd	s0,64(sp)
    800023f4:	fc26                	sd	s1,56(sp)
    800023f6:	f84a                	sd	s2,48(sp)
    800023f8:	f44e                	sd	s3,40(sp)
    800023fa:	f052                	sd	s4,32(sp)
    800023fc:	ec56                	sd	s5,24(sp)
    800023fe:	e85a                	sd	s6,16(sp)
    80002400:	e45e                	sd	s7,8(sp)
    80002402:	0880                	addi	s0,sp,80
      [UNUSED] "unused",   [USED] "used",      [SLEEPING] "sleep ",
      [RUNNABLE] "runble", [RUNNING] "run   ", [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002404:	00005517          	auipc	a0,0x5
    80002408:	c7450513          	addi	a0,a0,-908 # 80007078 <etext+0x78>
    8000240c:	8eefe0ef          	jal	800004fa <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002410:	00010497          	auipc	s1,0x10
    80002414:	4b848493          	addi	s1,s1,1208 # 800128c8 <proc+0x160>
    80002418:	00016917          	auipc	s2,0x16
    8000241c:	0b090913          	addi	s2,s2,176 # 800184c8 <bcache+0x148>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002420:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002422:	00005997          	auipc	s3,0x5
    80002426:	dde98993          	addi	s3,s3,-546 # 80007200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    8000242a:	00005a97          	auipc	s5,0x5
    8000242e:	ddea8a93          	addi	s5,s5,-546 # 80007208 <etext+0x208>
    printf("\n");
    80002432:	00005a17          	auipc	s4,0x5
    80002436:	c46a0a13          	addi	s4,s4,-954 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000243a:	00005b97          	auipc	s7,0x5
    8000243e:	2eeb8b93          	addi	s7,s7,750 # 80007728 <states.0>
    80002442:	a829                	j	8000245c <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002444:	ed06a583          	lw	a1,-304(a3)
    80002448:	8556                	mv	a0,s5
    8000244a:	8b0fe0ef          	jal	800004fa <printf>
    printf("\n");
    8000244e:	8552                	mv	a0,s4
    80002450:	8aafe0ef          	jal	800004fa <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002454:	17048493          	addi	s1,s1,368
    80002458:	03248263          	beq	s1,s2,8000247c <procdump+0x8e>
    if (p->state == UNUSED)
    8000245c:	86a6                	mv	a3,s1
    8000245e:	eb84a783          	lw	a5,-328(s1)
    80002462:	dbed                	beqz	a5,80002454 <procdump+0x66>
      state = "???";
    80002464:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002466:	fcfb6fe3          	bltu	s6,a5,80002444 <procdump+0x56>
    8000246a:	02079713          	slli	a4,a5,0x20
    8000246e:	01d75793          	srli	a5,a4,0x1d
    80002472:	97de                	add	a5,a5,s7
    80002474:	6390                	ld	a2,0(a5)
    80002476:	f679                	bnez	a2,80002444 <procdump+0x56>
      state = "???";
    80002478:	864e                	mv	a2,s3
    8000247a:	b7e9                	j	80002444 <procdump+0x56>
  }
}
    8000247c:	60a6                	ld	ra,72(sp)
    8000247e:	6406                	ld	s0,64(sp)
    80002480:	74e2                	ld	s1,56(sp)
    80002482:	7942                	ld	s2,48(sp)
    80002484:	79a2                	ld	s3,40(sp)
    80002486:	7a02                	ld	s4,32(sp)
    80002488:	6ae2                	ld	s5,24(sp)
    8000248a:	6b42                	ld	s6,16(sp)
    8000248c:	6ba2                	ld	s7,8(sp)
    8000248e:	6161                	addi	sp,sp,80
    80002490:	8082                	ret

0000000080002492 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002492:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002496:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000249a:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000249c:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000249e:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800024a2:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800024a6:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800024aa:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800024ae:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800024b2:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800024b6:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800024ba:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800024be:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800024c2:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800024c6:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800024ca:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800024ce:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800024d0:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800024d2:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800024d6:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800024da:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800024de:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800024e2:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800024e6:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800024ea:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800024ee:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800024f2:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800024f6:	0685bd83          	ld	s11,104(a1)
        
        ret
    800024fa:	8082                	ret

00000000800024fc <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800024fc:	1141                	addi	sp,sp,-16
    800024fe:	e406                	sd	ra,8(sp)
    80002500:	e022                	sd	s0,0(sp)
    80002502:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002504:	00005597          	auipc	a1,0x5
    80002508:	d4458593          	addi	a1,a1,-700 # 80007248 <etext+0x248>
    8000250c:	00016517          	auipc	a0,0x16
    80002510:	e5c50513          	addi	a0,a0,-420 # 80018368 <tickslock>
    80002514:	e8afe0ef          	jal	80000b9e <initlock>
}
    80002518:	60a2                	ld	ra,8(sp)
    8000251a:	6402                	ld	s0,0(sp)
    8000251c:	0141                	addi	sp,sp,16
    8000251e:	8082                	ret

0000000080002520 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002520:	1141                	addi	sp,sp,-16
    80002522:	e406                	sd	ra,8(sp)
    80002524:	e022                	sd	s0,0(sp)
    80002526:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002528:	00003797          	auipc	a5,0x3
    8000252c:	fa878793          	addi	a5,a5,-88 # 800054d0 <kernelvec>
    80002530:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002534:	60a2                	ld	ra,8(sp)
    80002536:	6402                	ld	s0,0(sp)
    80002538:	0141                	addi	sp,sp,16
    8000253a:	8082                	ret

000000008000253c <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000253c:	1141                	addi	sp,sp,-16
    8000253e:	e406                	sd	ra,8(sp)
    80002540:	e022                	sd	s0,0(sp)
    80002542:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002544:	beaff0ef          	jal	8000192e <myproc>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002548:	100027f3          	csrr	a5,sstatus
static inline void intr_off() { w_sstatus(r_sstatus() & ~SSTATUS_SIE); }
    8000254c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000254e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002552:	04000737          	lui	a4,0x4000
    80002556:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002558:	0732                	slli	a4,a4,0xc
    8000255a:	00004797          	auipc	a5,0x4
    8000255e:	aa678793          	addi	a5,a5,-1370 # 80006000 <_trampoline>
    80002562:	00004697          	auipc	a3,0x4
    80002566:	a9e68693          	addi	a3,a3,-1378 # 80006000 <_trampoline>
    8000256a:	8f95                	sub	a5,a5,a3
    8000256c:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    8000256e:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002572:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    80002574:	18002773          	csrr	a4,satp
    80002578:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000257a:	7138                	ld	a4,96(a0)
    8000257c:	653c                	ld	a5,72(a0)
    8000257e:	6685                	lui	a3,0x1
    80002580:	97b6                	add	a5,a5,a3
    80002582:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002584:	713c                	ld	a5,96(a0)
    80002586:	00000717          	auipc	a4,0x0
    8000258a:	0fc70713          	addi	a4,a4,252 # 80002682 <usertrap>
    8000258e:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002590:	713c                	ld	a5,96(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    80002592:	8712                	mv	a4,tp
    80002594:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002596:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000259a:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000259e:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800025a2:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800025a6:	713c                	ld	a5,96(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    800025a8:	6f9c                	ld	a5,24(a5)
    800025aa:	14179073          	csrw	sepc,a5
}
    800025ae:	60a2                	ld	ra,8(sp)
    800025b0:	6402                	ld	s0,0(sp)
    800025b2:	0141                	addi	sp,sp,16
    800025b4:	8082                	ret

00000000800025b6 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800025b6:	1141                	addi	sp,sp,-16
    800025b8:	e406                	sd	ra,8(sp)
    800025ba:	e022                	sd	s0,0(sp)
    800025bc:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800025be:	b3cff0ef          	jal	800018fa <cpuid>
    800025c2:	cd11                	beqz	a0,800025de <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    800025c4:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800025c8:	000f4737          	lui	a4,0xf4
    800025cc:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800025d0:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    800025d2:	14d79073          	csrw	stimecmp,a5
}
    800025d6:	60a2                	ld	ra,8(sp)
    800025d8:	6402                	ld	s0,0(sp)
    800025da:	0141                	addi	sp,sp,16
    800025dc:	8082                	ret
    acquire(&tickslock);
    800025de:	00016517          	auipc	a0,0x16
    800025e2:	d8a50513          	addi	a0,a0,-630 # 80018368 <tickslock>
    800025e6:	e42fe0ef          	jal	80000c28 <acquire>
    ticks++;
    800025ea:	00008717          	auipc	a4,0x8
    800025ee:	c4e70713          	addi	a4,a4,-946 # 8000a238 <ticks>
    800025f2:	431c                	lw	a5,0(a4)
    800025f4:	2785                	addiw	a5,a5,1
    800025f6:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    800025f8:	853a                	mv	a0,a4
    800025fa:	a53ff0ef          	jal	8000204c <wakeup>
    release(&tickslock);
    800025fe:	00016517          	auipc	a0,0x16
    80002602:	d6a50513          	addi	a0,a0,-662 # 80018368 <tickslock>
    80002606:	eb6fe0ef          	jal	80000cbc <release>
    8000260a:	bf6d                	j	800025c4 <clockintr+0xe>

000000008000260c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000260c:	1101                	addi	sp,sp,-32
    8000260e:	ec06                	sd	ra,24(sp)
    80002610:	e822                	sd	s0,16(sp)
    80002612:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    80002614:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002618:	57fd                	li	a5,-1
    8000261a:	17fe                	slli	a5,a5,0x3f
    8000261c:	07a5                	addi	a5,a5,9
    8000261e:	00f70c63          	beq	a4,a5,80002636 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002622:	57fd                	li	a5,-1
    80002624:	17fe                	slli	a5,a5,0x3f
    80002626:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002628:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000262a:	04f70863          	beq	a4,a5,8000267a <devintr+0x6e>
  }
}
    8000262e:	60e2                	ld	ra,24(sp)
    80002630:	6442                	ld	s0,16(sp)
    80002632:	6105                	addi	sp,sp,32
    80002634:	8082                	ret
    80002636:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002638:	745020ef          	jal	8000557c <plic_claim>
    8000263c:	872a                	mv	a4,a0
    8000263e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002640:	47a9                	li	a5,10
    80002642:	00f50963          	beq	a0,a5,80002654 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    80002646:	4785                	li	a5,1
    80002648:	00f50963          	beq	a0,a5,8000265a <devintr+0x4e>
    return 1;
    8000264c:	4505                	li	a0,1
    } else if(irq){
    8000264e:	eb09                	bnez	a4,80002660 <devintr+0x54>
    80002650:	64a2                	ld	s1,8(sp)
    80002652:	bff1                	j	8000262e <devintr+0x22>
      uartintr();
    80002654:	ba0fe0ef          	jal	800009f4 <uartintr>
    if(irq)
    80002658:	a819                	j	8000266e <devintr+0x62>
      virtio_disk_intr();
    8000265a:	3b8030ef          	jal	80005a12 <virtio_disk_intr>
    if(irq)
    8000265e:	a801                	j	8000266e <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    80002660:	85ba                	mv	a1,a4
    80002662:	00005517          	auipc	a0,0x5
    80002666:	bee50513          	addi	a0,a0,-1042 # 80007250 <etext+0x250>
    8000266a:	e91fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    8000266e:	8526                	mv	a0,s1
    80002670:	72d020ef          	jal	8000559c <plic_complete>
    return 1;
    80002674:	4505                	li	a0,1
    80002676:	64a2                	ld	s1,8(sp)
    80002678:	bf5d                	j	8000262e <devintr+0x22>
    clockintr();
    8000267a:	f3dff0ef          	jal	800025b6 <clockintr>
    return 2;
    8000267e:	4509                	li	a0,2
    80002680:	b77d                	j	8000262e <devintr+0x22>

0000000080002682 <usertrap>:
{
    80002682:	1101                	addi	sp,sp,-32
    80002684:	ec06                	sd	ra,24(sp)
    80002686:	e822                	sd	s0,16(sp)
    80002688:	e426                	sd	s1,8(sp)
    8000268a:	e04a                	sd	s2,0(sp)
    8000268c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000268e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002692:	1007f793          	andi	a5,a5,256
    80002696:	eba5                	bnez	a5,80002706 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002698:	00003797          	auipc	a5,0x3
    8000269c:	e3878793          	addi	a5,a5,-456 # 800054d0 <kernelvec>
    800026a0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800026a4:	a8aff0ef          	jal	8000192e <myproc>
    800026a8:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800026aa:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026ac:	14102773          	csrr	a4,sepc
    800026b0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    800026b2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800026b6:	47a1                	li	a5,8
    800026b8:	04f70d63          	beq	a4,a5,80002712 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    800026bc:	f51ff0ef          	jal	8000260c <devintr>
    800026c0:	892a                	mv	s2,a0
    800026c2:	e945                	bnez	a0,80002772 <usertrap+0xf0>
    800026c4:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800026c8:	47bd                	li	a5,15
    800026ca:	08f70863          	beq	a4,a5,8000275a <usertrap+0xd8>
    800026ce:	14202773          	csrr	a4,scause
    800026d2:	47b5                	li	a5,13
    800026d4:	08f70363          	beq	a4,a5,8000275a <usertrap+0xd8>
    800026d8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800026dc:	5890                	lw	a2,48(s1)
    800026de:	00005517          	auipc	a0,0x5
    800026e2:	bb250513          	addi	a0,a0,-1102 # 80007290 <etext+0x290>
    800026e6:	e15fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026ea:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800026ee:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800026f2:	00005517          	auipc	a0,0x5
    800026f6:	bce50513          	addi	a0,a0,-1074 # 800072c0 <etext+0x2c0>
    800026fa:	e01fd0ef          	jal	800004fa <printf>
    setkilled(p);
    800026fe:	8526                	mv	a0,s1
    80002700:	b19ff0ef          	jal	80002218 <setkilled>
    80002704:	a035                	j	80002730 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002706:	00005517          	auipc	a0,0x5
    8000270a:	b6a50513          	addi	a0,a0,-1174 # 80007270 <etext+0x270>
    8000270e:	916fe0ef          	jal	80000824 <panic>
    if(killed(p))
    80002712:	b2bff0ef          	jal	8000223c <killed>
    80002716:	ed15                	bnez	a0,80002752 <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002718:	70b8                	ld	a4,96(s1)
    8000271a:	6f1c                	ld	a5,24(a4)
    8000271c:	0791                	addi	a5,a5,4
    8000271e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002720:	100027f3          	csrr	a5,sstatus
static inline void intr_on() { w_sstatus(r_sstatus() | SSTATUS_SIE); }
    80002724:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002728:	10079073          	csrw	sstatus,a5
    syscall();
    8000272c:	240000ef          	jal	8000296c <syscall>
  if(killed(p))
    80002730:	8526                	mv	a0,s1
    80002732:	b0bff0ef          	jal	8000223c <killed>
    80002736:	e139                	bnez	a0,8000277c <usertrap+0xfa>
  prepare_return();
    80002738:	e05ff0ef          	jal	8000253c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000273c:	6ca8                	ld	a0,88(s1)
    8000273e:	8131                	srli	a0,a0,0xc
    80002740:	57fd                	li	a5,-1
    80002742:	17fe                	slli	a5,a5,0x3f
    80002744:	8d5d                	or	a0,a0,a5
}
    80002746:	60e2                	ld	ra,24(sp)
    80002748:	6442                	ld	s0,16(sp)
    8000274a:	64a2                	ld	s1,8(sp)
    8000274c:	6902                	ld	s2,0(sp)
    8000274e:	6105                	addi	sp,sp,32
    80002750:	8082                	ret
      kexit(-1);
    80002752:	557d                	li	a0,-1
    80002754:	9b9ff0ef          	jal	8000210c <kexit>
    80002758:	b7c1                	j	80002718 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    8000275a:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    8000275e:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002762:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002764:	00163613          	seqz	a2,a2
    80002768:	6ca8                	ld	a0,88(s1)
    8000276a:	e67fe0ef          	jal	800015d0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000276e:	f169                	bnez	a0,80002730 <usertrap+0xae>
    80002770:	b7a5                	j	800026d8 <usertrap+0x56>
  if(killed(p))
    80002772:	8526                	mv	a0,s1
    80002774:	ac9ff0ef          	jal	8000223c <killed>
    80002778:	c511                	beqz	a0,80002784 <usertrap+0x102>
    8000277a:	a011                	j	8000277e <usertrap+0xfc>
    8000277c:	4901                	li	s2,0
    kexit(-1);
    8000277e:	557d                	li	a0,-1
    80002780:	98dff0ef          	jal	8000210c <kexit>
  if(which_dev == 2)
    80002784:	4789                	li	a5,2
    80002786:	faf919e3          	bne	s2,a5,80002738 <usertrap+0xb6>
    yield();
    8000278a:	84bff0ef          	jal	80001fd4 <yield>
    8000278e:	b76d                	j	80002738 <usertrap+0xb6>

0000000080002790 <kerneltrap>:
{
    80002790:	7179                	addi	sp,sp,-48
    80002792:	f406                	sd	ra,40(sp)
    80002794:	f022                	sd	s0,32(sp)
    80002796:	ec26                	sd	s1,24(sp)
    80002798:	e84a                	sd	s2,16(sp)
    8000279a:	e44e                	sd	s3,8(sp)
    8000279c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000279e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027a2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    800027a6:	142027f3          	csrr	a5,scause
    800027aa:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    800027ac:	1004f793          	andi	a5,s1,256
    800027b0:	c795                	beqz	a5,800027dc <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027b2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800027b6:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800027b8:	eb85                	bnez	a5,800027e8 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    800027ba:	e53ff0ef          	jal	8000260c <devintr>
    800027be:	c91d                	beqz	a0,800027f4 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    800027c0:	4789                	li	a5,2
    800027c2:	04f50a63          	beq	a0,a5,80002816 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    800027c6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800027ca:	10049073          	csrw	sstatus,s1
}
    800027ce:	70a2                	ld	ra,40(sp)
    800027d0:	7402                	ld	s0,32(sp)
    800027d2:	64e2                	ld	s1,24(sp)
    800027d4:	6942                	ld	s2,16(sp)
    800027d6:	69a2                	ld	s3,8(sp)
    800027d8:	6145                	addi	sp,sp,48
    800027da:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800027dc:	00005517          	auipc	a0,0x5
    800027e0:	b0c50513          	addi	a0,a0,-1268 # 800072e8 <etext+0x2e8>
    800027e4:	840fe0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    800027e8:	00005517          	auipc	a0,0x5
    800027ec:	b2850513          	addi	a0,a0,-1240 # 80007310 <etext+0x310>
    800027f0:	834fe0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800027f4:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800027f8:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800027fc:	85ce                	mv	a1,s3
    800027fe:	00005517          	auipc	a0,0x5
    80002802:	b3250513          	addi	a0,a0,-1230 # 80007330 <etext+0x330>
    80002806:	cf5fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    8000280a:	00005517          	auipc	a0,0x5
    8000280e:	b4e50513          	addi	a0,a0,-1202 # 80007358 <etext+0x358>
    80002812:	812fe0ef          	jal	80000824 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002816:	918ff0ef          	jal	8000192e <myproc>
    8000281a:	d555                	beqz	a0,800027c6 <kerneltrap+0x36>
    yield();
    8000281c:	fb8ff0ef          	jal	80001fd4 <yield>
    80002820:	b75d                	j	800027c6 <kerneltrap+0x36>

0000000080002822 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002822:	1101                	addi	sp,sp,-32
    80002824:	ec06                	sd	ra,24(sp)
    80002826:	e822                	sd	s0,16(sp)
    80002828:	e426                	sd	s1,8(sp)
    8000282a:	1000                	addi	s0,sp,32
    8000282c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000282e:	900ff0ef          	jal	8000192e <myproc>
  switch (n) {
    80002832:	4795                	li	a5,5
    80002834:	0497e163          	bltu	a5,s1,80002876 <argraw+0x54>
    80002838:	048a                	slli	s1,s1,0x2
    8000283a:	00005717          	auipc	a4,0x5
    8000283e:	f1e70713          	addi	a4,a4,-226 # 80007758 <states.0+0x30>
    80002842:	94ba                	add	s1,s1,a4
    80002844:	409c                	lw	a5,0(s1)
    80002846:	97ba                	add	a5,a5,a4
    80002848:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000284a:	713c                	ld	a5,96(a0)
    8000284c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000284e:	60e2                	ld	ra,24(sp)
    80002850:	6442                	ld	s0,16(sp)
    80002852:	64a2                	ld	s1,8(sp)
    80002854:	6105                	addi	sp,sp,32
    80002856:	8082                	ret
    return p->trapframe->a1;
    80002858:	713c                	ld	a5,96(a0)
    8000285a:	7fa8                	ld	a0,120(a5)
    8000285c:	bfcd                	j	8000284e <argraw+0x2c>
    return p->trapframe->a2;
    8000285e:	713c                	ld	a5,96(a0)
    80002860:	63c8                	ld	a0,128(a5)
    80002862:	b7f5                	j	8000284e <argraw+0x2c>
    return p->trapframe->a3;
    80002864:	713c                	ld	a5,96(a0)
    80002866:	67c8                	ld	a0,136(a5)
    80002868:	b7dd                	j	8000284e <argraw+0x2c>
    return p->trapframe->a4;
    8000286a:	713c                	ld	a5,96(a0)
    8000286c:	6bc8                	ld	a0,144(a5)
    8000286e:	b7c5                	j	8000284e <argraw+0x2c>
    return p->trapframe->a5;
    80002870:	713c                	ld	a5,96(a0)
    80002872:	6fc8                	ld	a0,152(a5)
    80002874:	bfe9                	j	8000284e <argraw+0x2c>
  panic("argraw");
    80002876:	00005517          	auipc	a0,0x5
    8000287a:	af250513          	addi	a0,a0,-1294 # 80007368 <etext+0x368>
    8000287e:	fa7fd0ef          	jal	80000824 <panic>

0000000080002882 <fetchaddr>:
{
    80002882:	1101                	addi	sp,sp,-32
    80002884:	ec06                	sd	ra,24(sp)
    80002886:	e822                	sd	s0,16(sp)
    80002888:	e426                	sd	s1,8(sp)
    8000288a:	e04a                	sd	s2,0(sp)
    8000288c:	1000                	addi	s0,sp,32
    8000288e:	84aa                	mv	s1,a0
    80002890:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002892:	89cff0ef          	jal	8000192e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002896:	693c                	ld	a5,80(a0)
    80002898:	02f4f663          	bgeu	s1,a5,800028c4 <fetchaddr+0x42>
    8000289c:	00848713          	addi	a4,s1,8
    800028a0:	02e7e463          	bltu	a5,a4,800028c8 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800028a4:	46a1                	li	a3,8
    800028a6:	8626                	mv	a2,s1
    800028a8:	85ca                	mv	a1,s2
    800028aa:	6d28                	ld	a0,88(a0)
    800028ac:	e67fe0ef          	jal	80001712 <copyin>
    800028b0:	00a03533          	snez	a0,a0
    800028b4:	40a0053b          	negw	a0,a0
}
    800028b8:	60e2                	ld	ra,24(sp)
    800028ba:	6442                	ld	s0,16(sp)
    800028bc:	64a2                	ld	s1,8(sp)
    800028be:	6902                	ld	s2,0(sp)
    800028c0:	6105                	addi	sp,sp,32
    800028c2:	8082                	ret
    return -1;
    800028c4:	557d                	li	a0,-1
    800028c6:	bfcd                	j	800028b8 <fetchaddr+0x36>
    800028c8:	557d                	li	a0,-1
    800028ca:	b7fd                	j	800028b8 <fetchaddr+0x36>

00000000800028cc <fetchstr>:
{
    800028cc:	7179                	addi	sp,sp,-48
    800028ce:	f406                	sd	ra,40(sp)
    800028d0:	f022                	sd	s0,32(sp)
    800028d2:	ec26                	sd	s1,24(sp)
    800028d4:	e84a                	sd	s2,16(sp)
    800028d6:	e44e                	sd	s3,8(sp)
    800028d8:	1800                	addi	s0,sp,48
    800028da:	89aa                	mv	s3,a0
    800028dc:	84ae                	mv	s1,a1
    800028de:	8932                	mv	s2,a2
  struct proc *p = myproc();
    800028e0:	84eff0ef          	jal	8000192e <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800028e4:	86ca                	mv	a3,s2
    800028e6:	864e                	mv	a2,s3
    800028e8:	85a6                	mv	a1,s1
    800028ea:	6d28                	ld	a0,88(a0)
    800028ec:	c0dfe0ef          	jal	800014f8 <copyinstr>
    800028f0:	00054c63          	bltz	a0,80002908 <fetchstr+0x3c>
  return strlen(buf);
    800028f4:	8526                	mv	a0,s1
    800028f6:	d8cfe0ef          	jal	80000e82 <strlen>
}
    800028fa:	70a2                	ld	ra,40(sp)
    800028fc:	7402                	ld	s0,32(sp)
    800028fe:	64e2                	ld	s1,24(sp)
    80002900:	6942                	ld	s2,16(sp)
    80002902:	69a2                	ld	s3,8(sp)
    80002904:	6145                	addi	sp,sp,48
    80002906:	8082                	ret
    return -1;
    80002908:	557d                	li	a0,-1
    8000290a:	bfc5                	j	800028fa <fetchstr+0x2e>

000000008000290c <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000290c:	1101                	addi	sp,sp,-32
    8000290e:	ec06                	sd	ra,24(sp)
    80002910:	e822                	sd	s0,16(sp)
    80002912:	e426                	sd	s1,8(sp)
    80002914:	1000                	addi	s0,sp,32
    80002916:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002918:	f0bff0ef          	jal	80002822 <argraw>
    8000291c:	c088                	sw	a0,0(s1)
}
    8000291e:	60e2                	ld	ra,24(sp)
    80002920:	6442                	ld	s0,16(sp)
    80002922:	64a2                	ld	s1,8(sp)
    80002924:	6105                	addi	sp,sp,32
    80002926:	8082                	ret

0000000080002928 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002928:	1101                	addi	sp,sp,-32
    8000292a:	ec06                	sd	ra,24(sp)
    8000292c:	e822                	sd	s0,16(sp)
    8000292e:	e426                	sd	s1,8(sp)
    80002930:	1000                	addi	s0,sp,32
    80002932:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002934:	eefff0ef          	jal	80002822 <argraw>
    80002938:	e088                	sd	a0,0(s1)
}
    8000293a:	60e2                	ld	ra,24(sp)
    8000293c:	6442                	ld	s0,16(sp)
    8000293e:	64a2                	ld	s1,8(sp)
    80002940:	6105                	addi	sp,sp,32
    80002942:	8082                	ret

0000000080002944 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002944:	1101                	addi	sp,sp,-32
    80002946:	ec06                	sd	ra,24(sp)
    80002948:	e822                	sd	s0,16(sp)
    8000294a:	e426                	sd	s1,8(sp)
    8000294c:	e04a                	sd	s2,0(sp)
    8000294e:	1000                	addi	s0,sp,32
    80002950:	892e                	mv	s2,a1
    80002952:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002954:	ecfff0ef          	jal	80002822 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002958:	8626                	mv	a2,s1
    8000295a:	85ca                	mv	a1,s2
    8000295c:	f71ff0ef          	jal	800028cc <fetchstr>
}
    80002960:	60e2                	ld	ra,24(sp)
    80002962:	6442                	ld	s0,16(sp)
    80002964:	64a2                	ld	s1,8(sp)
    80002966:	6902                	ld	s2,0(sp)
    80002968:	6105                	addi	sp,sp,32
    8000296a:	8082                	ret

000000008000296c <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    8000296c:	1101                	addi	sp,sp,-32
    8000296e:	ec06                	sd	ra,24(sp)
    80002970:	e822                	sd	s0,16(sp)
    80002972:	e426                	sd	s1,8(sp)
    80002974:	e04a                	sd	s2,0(sp)
    80002976:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002978:	fb7fe0ef          	jal	8000192e <myproc>
    8000297c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000297e:	06053903          	ld	s2,96(a0)
    80002982:	0a893783          	ld	a5,168(s2)
    80002986:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000298a:	37fd                	addiw	a5,a5,-1
    8000298c:	4751                	li	a4,20
    8000298e:	00f76f63          	bltu	a4,a5,800029ac <syscall+0x40>
    80002992:	00369713          	slli	a4,a3,0x3
    80002996:	00005797          	auipc	a5,0x5
    8000299a:	dda78793          	addi	a5,a5,-550 # 80007770 <syscalls>
    8000299e:	97ba                	add	a5,a5,a4
    800029a0:	639c                	ld	a5,0(a5)
    800029a2:	c789                	beqz	a5,800029ac <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800029a4:	9782                	jalr	a5
    800029a6:	06a93823          	sd	a0,112(s2)
    800029aa:	a829                	j	800029c4 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800029ac:	16048613          	addi	a2,s1,352
    800029b0:	588c                	lw	a1,48(s1)
    800029b2:	00005517          	auipc	a0,0x5
    800029b6:	9be50513          	addi	a0,a0,-1602 # 80007370 <etext+0x370>
    800029ba:	b41fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800029be:	70bc                	ld	a5,96(s1)
    800029c0:	577d                	li	a4,-1
    800029c2:	fbb8                	sd	a4,112(a5)
  }
}
    800029c4:	60e2                	ld	ra,24(sp)
    800029c6:	6442                	ld	s0,16(sp)
    800029c8:	64a2                	ld	s1,8(sp)
    800029ca:	6902                	ld	s2,0(sp)
    800029cc:	6105                	addi	sp,sp,32
    800029ce:	8082                	ret

00000000800029d0 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800029d0:	1101                	addi	sp,sp,-32
    800029d2:	ec06                	sd	ra,24(sp)
    800029d4:	e822                	sd	s0,16(sp)
    800029d6:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800029d8:	fec40593          	addi	a1,s0,-20
    800029dc:	4501                	li	a0,0
    800029de:	f2fff0ef          	jal	8000290c <argint>
  kexit(n);
    800029e2:	fec42503          	lw	a0,-20(s0)
    800029e6:	f26ff0ef          	jal	8000210c <kexit>
  return 0;  // not reached
}
    800029ea:	4501                	li	a0,0
    800029ec:	60e2                	ld	ra,24(sp)
    800029ee:	6442                	ld	s0,16(sp)
    800029f0:	6105                	addi	sp,sp,32
    800029f2:	8082                	ret

00000000800029f4 <sys_getpid>:

uint64
sys_getpid(void)
{
    800029f4:	1141                	addi	sp,sp,-16
    800029f6:	e406                	sd	ra,8(sp)
    800029f8:	e022                	sd	s0,0(sp)
    800029fa:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800029fc:	f33fe0ef          	jal	8000192e <myproc>
}
    80002a00:	5908                	lw	a0,48(a0)
    80002a02:	60a2                	ld	ra,8(sp)
    80002a04:	6402                	ld	s0,0(sp)
    80002a06:	0141                	addi	sp,sp,16
    80002a08:	8082                	ret

0000000080002a0a <sys_fork>:

uint64
sys_fork(void)
{
    80002a0a:	1141                	addi	sp,sp,-16
    80002a0c:	e406                	sd	ra,8(sp)
    80002a0e:	e022                	sd	s0,0(sp)
    80002a10:	0800                	addi	s0,sp,16
  return kfork();
    80002a12:	a8cff0ef          	jal	80001c9e <kfork>
}
    80002a16:	60a2                	ld	ra,8(sp)
    80002a18:	6402                	ld	s0,0(sp)
    80002a1a:	0141                	addi	sp,sp,16
    80002a1c:	8082                	ret

0000000080002a1e <sys_wait>:

uint64
sys_wait(void)
{
    80002a1e:	1101                	addi	sp,sp,-32
    80002a20:	ec06                	sd	ra,24(sp)
    80002a22:	e822                	sd	s0,16(sp)
    80002a24:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a26:	fe840593          	addi	a1,s0,-24
    80002a2a:	4501                	li	a0,0
    80002a2c:	efdff0ef          	jal	80002928 <argaddr>
  return kwait(p);
    80002a30:	fe843503          	ld	a0,-24(s0)
    80002a34:	833ff0ef          	jal	80002266 <kwait>
}
    80002a38:	60e2                	ld	ra,24(sp)
    80002a3a:	6442                	ld	s0,16(sp)
    80002a3c:	6105                	addi	sp,sp,32
    80002a3e:	8082                	ret

0000000080002a40 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a40:	7179                	addi	sp,sp,-48
    80002a42:	f406                	sd	ra,40(sp)
    80002a44:	f022                	sd	s0,32(sp)
    80002a46:	ec26                	sd	s1,24(sp)
    80002a48:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002a4a:	fd840593          	addi	a1,s0,-40
    80002a4e:	4501                	li	a0,0
    80002a50:	ebdff0ef          	jal	8000290c <argint>
  argint(1, &t);
    80002a54:	fdc40593          	addi	a1,s0,-36
    80002a58:	4505                	li	a0,1
    80002a5a:	eb3ff0ef          	jal	8000290c <argint>
  addr = myproc()->sz;
    80002a5e:	ed1fe0ef          	jal	8000192e <myproc>
    80002a62:	6924                	ld	s1,80(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002a64:	fdc42703          	lw	a4,-36(s0)
    80002a68:	4785                	li	a5,1
    80002a6a:	02f70763          	beq	a4,a5,80002a98 <sys_sbrk+0x58>
    80002a6e:	fd842783          	lw	a5,-40(s0)
    80002a72:	0207c363          	bltz	a5,80002a98 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002a76:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    80002a78:	02000737          	lui	a4,0x2000
    80002a7c:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002a7e:	0736                	slli	a4,a4,0xd
    80002a80:	02f76a63          	bltu	a4,a5,80002ab4 <sys_sbrk+0x74>
    80002a84:	0297e863          	bltu	a5,s1,80002ab4 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002a88:	ea7fe0ef          	jal	8000192e <myproc>
    80002a8c:	fd842703          	lw	a4,-40(s0)
    80002a90:	693c                	ld	a5,80(a0)
    80002a92:	97ba                	add	a5,a5,a4
    80002a94:	e93c                	sd	a5,80(a0)
    80002a96:	a039                	j	80002aa4 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002a98:	fd842503          	lw	a0,-40(s0)
    80002a9c:	9a0ff0ef          	jal	80001c3c <growproc>
    80002aa0:	00054863          	bltz	a0,80002ab0 <sys_sbrk+0x70>
  }
  return addr;
}
    80002aa4:	8526                	mv	a0,s1
    80002aa6:	70a2                	ld	ra,40(sp)
    80002aa8:	7402                	ld	s0,32(sp)
    80002aaa:	64e2                	ld	s1,24(sp)
    80002aac:	6145                	addi	sp,sp,48
    80002aae:	8082                	ret
      return -1;
    80002ab0:	54fd                	li	s1,-1
    80002ab2:	bfcd                	j	80002aa4 <sys_sbrk+0x64>
      return -1;
    80002ab4:	54fd                	li	s1,-1
    80002ab6:	b7fd                	j	80002aa4 <sys_sbrk+0x64>

0000000080002ab8 <sys_pause>:

uint64
sys_pause(void)
{
    80002ab8:	7139                	addi	sp,sp,-64
    80002aba:	fc06                	sd	ra,56(sp)
    80002abc:	f822                	sd	s0,48(sp)
    80002abe:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002ac0:	fcc40593          	addi	a1,s0,-52
    80002ac4:	4501                	li	a0,0
    80002ac6:	e47ff0ef          	jal	8000290c <argint>
  if(n < 0)
    80002aca:	fcc42783          	lw	a5,-52(s0)
    80002ace:	0607c863          	bltz	a5,80002b3e <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002ad2:	00016517          	auipc	a0,0x16
    80002ad6:	89650513          	addi	a0,a0,-1898 # 80018368 <tickslock>
    80002ada:	94efe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002ade:	fcc42783          	lw	a5,-52(s0)
    80002ae2:	c3b9                	beqz	a5,80002b28 <sys_pause+0x70>
    80002ae4:	f426                	sd	s1,40(sp)
    80002ae6:	f04a                	sd	s2,32(sp)
    80002ae8:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002aea:	00007997          	auipc	s3,0x7
    80002aee:	74e9a983          	lw	s3,1870(s3) # 8000a238 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002af2:	00016917          	auipc	s2,0x16
    80002af6:	87690913          	addi	s2,s2,-1930 # 80018368 <tickslock>
    80002afa:	00007497          	auipc	s1,0x7
    80002afe:	73e48493          	addi	s1,s1,1854 # 8000a238 <ticks>
    if(killed(myproc())){
    80002b02:	e2dfe0ef          	jal	8000192e <myproc>
    80002b06:	f36ff0ef          	jal	8000223c <killed>
    80002b0a:	ed0d                	bnez	a0,80002b44 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002b0c:	85ca                	mv	a1,s2
    80002b0e:	8526                	mv	a0,s1
    80002b10:	cf0ff0ef          	jal	80002000 <sleep>
  while(ticks - ticks0 < n){
    80002b14:	409c                	lw	a5,0(s1)
    80002b16:	413787bb          	subw	a5,a5,s3
    80002b1a:	fcc42703          	lw	a4,-52(s0)
    80002b1e:	fee7e2e3          	bltu	a5,a4,80002b02 <sys_pause+0x4a>
    80002b22:	74a2                	ld	s1,40(sp)
    80002b24:	7902                	ld	s2,32(sp)
    80002b26:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002b28:	00016517          	auipc	a0,0x16
    80002b2c:	84050513          	addi	a0,a0,-1984 # 80018368 <tickslock>
    80002b30:	98cfe0ef          	jal	80000cbc <release>
  return 0;
    80002b34:	4501                	li	a0,0
}
    80002b36:	70e2                	ld	ra,56(sp)
    80002b38:	7442                	ld	s0,48(sp)
    80002b3a:	6121                	addi	sp,sp,64
    80002b3c:	8082                	ret
    n = 0;
    80002b3e:	fc042623          	sw	zero,-52(s0)
    80002b42:	bf41                	j	80002ad2 <sys_pause+0x1a>
      release(&tickslock);
    80002b44:	00016517          	auipc	a0,0x16
    80002b48:	82450513          	addi	a0,a0,-2012 # 80018368 <tickslock>
    80002b4c:	970fe0ef          	jal	80000cbc <release>
      return -1;
    80002b50:	557d                	li	a0,-1
    80002b52:	74a2                	ld	s1,40(sp)
    80002b54:	7902                	ld	s2,32(sp)
    80002b56:	69e2                	ld	s3,24(sp)
    80002b58:	bff9                	j	80002b36 <sys_pause+0x7e>

0000000080002b5a <sys_kill>:

uint64
sys_kill(void)
{
    80002b5a:	1101                	addi	sp,sp,-32
    80002b5c:	ec06                	sd	ra,24(sp)
    80002b5e:	e822                	sd	s0,16(sp)
    80002b60:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b62:	fec40593          	addi	a1,s0,-20
    80002b66:	4501                	li	a0,0
    80002b68:	da5ff0ef          	jal	8000290c <argint>
  return kkill(pid);
    80002b6c:	fec42503          	lw	a0,-20(s0)
    80002b70:	e42ff0ef          	jal	800021b2 <kkill>
}
    80002b74:	60e2                	ld	ra,24(sp)
    80002b76:	6442                	ld	s0,16(sp)
    80002b78:	6105                	addi	sp,sp,32
    80002b7a:	8082                	ret

0000000080002b7c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002b7c:	1101                	addi	sp,sp,-32
    80002b7e:	ec06                	sd	ra,24(sp)
    80002b80:	e822                	sd	s0,16(sp)
    80002b82:	e426                	sd	s1,8(sp)
    80002b84:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b86:	00015517          	auipc	a0,0x15
    80002b8a:	7e250513          	addi	a0,a0,2018 # 80018368 <tickslock>
    80002b8e:	89afe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002b92:	00007797          	auipc	a5,0x7
    80002b96:	6a67a783          	lw	a5,1702(a5) # 8000a238 <ticks>
    80002b9a:	84be                	mv	s1,a5
  release(&tickslock);
    80002b9c:	00015517          	auipc	a0,0x15
    80002ba0:	7cc50513          	addi	a0,a0,1996 # 80018368 <tickslock>
    80002ba4:	918fe0ef          	jal	80000cbc <release>
  return xticks;
}
    80002ba8:	02049513          	slli	a0,s1,0x20
    80002bac:	9101                	srli	a0,a0,0x20
    80002bae:	60e2                	ld	ra,24(sp)
    80002bb0:	6442                	ld	s0,16(sp)
    80002bb2:	64a2                	ld	s1,8(sp)
    80002bb4:	6105                	addi	sp,sp,32
    80002bb6:	8082                	ret

0000000080002bb8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002bb8:	7179                	addi	sp,sp,-48
    80002bba:	f406                	sd	ra,40(sp)
    80002bbc:	f022                	sd	s0,32(sp)
    80002bbe:	ec26                	sd	s1,24(sp)
    80002bc0:	e84a                	sd	s2,16(sp)
    80002bc2:	e44e                	sd	s3,8(sp)
    80002bc4:	e052                	sd	s4,0(sp)
    80002bc6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002bc8:	00004597          	auipc	a1,0x4
    80002bcc:	7c858593          	addi	a1,a1,1992 # 80007390 <etext+0x390>
    80002bd0:	00015517          	auipc	a0,0x15
    80002bd4:	7b050513          	addi	a0,a0,1968 # 80018380 <bcache>
    80002bd8:	fc7fd0ef          	jal	80000b9e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002bdc:	0001d797          	auipc	a5,0x1d
    80002be0:	7a478793          	addi	a5,a5,1956 # 80020380 <bcache+0x8000>
    80002be4:	0001e717          	auipc	a4,0x1e
    80002be8:	a0470713          	addi	a4,a4,-1532 # 800205e8 <bcache+0x8268>
    80002bec:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002bf0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002bf4:	00015497          	auipc	s1,0x15
    80002bf8:	7a448493          	addi	s1,s1,1956 # 80018398 <bcache+0x18>
    b->next = bcache.head.next;
    80002bfc:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002bfe:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002c00:	00004a17          	auipc	s4,0x4
    80002c04:	798a0a13          	addi	s4,s4,1944 # 80007398 <etext+0x398>
    b->next = bcache.head.next;
    80002c08:	2b893783          	ld	a5,696(s2)
    80002c0c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002c0e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002c12:	85d2                	mv	a1,s4
    80002c14:	01048513          	addi	a0,s1,16
    80002c18:	328010ef          	jal	80003f40 <initsleeplock>
    bcache.head.next->prev = b;
    80002c1c:	2b893783          	ld	a5,696(s2)
    80002c20:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002c22:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c26:	45848493          	addi	s1,s1,1112
    80002c2a:	fd349fe3          	bne	s1,s3,80002c08 <binit+0x50>
  }
}
    80002c2e:	70a2                	ld	ra,40(sp)
    80002c30:	7402                	ld	s0,32(sp)
    80002c32:	64e2                	ld	s1,24(sp)
    80002c34:	6942                	ld	s2,16(sp)
    80002c36:	69a2                	ld	s3,8(sp)
    80002c38:	6a02                	ld	s4,0(sp)
    80002c3a:	6145                	addi	sp,sp,48
    80002c3c:	8082                	ret

0000000080002c3e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002c3e:	7179                	addi	sp,sp,-48
    80002c40:	f406                	sd	ra,40(sp)
    80002c42:	f022                	sd	s0,32(sp)
    80002c44:	ec26                	sd	s1,24(sp)
    80002c46:	e84a                	sd	s2,16(sp)
    80002c48:	e44e                	sd	s3,8(sp)
    80002c4a:	1800                	addi	s0,sp,48
    80002c4c:	892a                	mv	s2,a0
    80002c4e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002c50:	00015517          	auipc	a0,0x15
    80002c54:	73050513          	addi	a0,a0,1840 # 80018380 <bcache>
    80002c58:	fd1fd0ef          	jal	80000c28 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002c5c:	0001e497          	auipc	s1,0x1e
    80002c60:	9dc4b483          	ld	s1,-1572(s1) # 80020638 <bcache+0x82b8>
    80002c64:	0001e797          	auipc	a5,0x1e
    80002c68:	98478793          	addi	a5,a5,-1660 # 800205e8 <bcache+0x8268>
    80002c6c:	02f48b63          	beq	s1,a5,80002ca2 <bread+0x64>
    80002c70:	873e                	mv	a4,a5
    80002c72:	a021                	j	80002c7a <bread+0x3c>
    80002c74:	68a4                	ld	s1,80(s1)
    80002c76:	02e48663          	beq	s1,a4,80002ca2 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002c7a:	449c                	lw	a5,8(s1)
    80002c7c:	ff279ce3          	bne	a5,s2,80002c74 <bread+0x36>
    80002c80:	44dc                	lw	a5,12(s1)
    80002c82:	ff3799e3          	bne	a5,s3,80002c74 <bread+0x36>
      b->refcnt++;
    80002c86:	40bc                	lw	a5,64(s1)
    80002c88:	2785                	addiw	a5,a5,1
    80002c8a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c8c:	00015517          	auipc	a0,0x15
    80002c90:	6f450513          	addi	a0,a0,1780 # 80018380 <bcache>
    80002c94:	828fe0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002c98:	01048513          	addi	a0,s1,16
    80002c9c:	2da010ef          	jal	80003f76 <acquiresleep>
      return b;
    80002ca0:	a889                	j	80002cf2 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ca2:	0001e497          	auipc	s1,0x1e
    80002ca6:	98e4b483          	ld	s1,-1650(s1) # 80020630 <bcache+0x82b0>
    80002caa:	0001e797          	auipc	a5,0x1e
    80002cae:	93e78793          	addi	a5,a5,-1730 # 800205e8 <bcache+0x8268>
    80002cb2:	00f48863          	beq	s1,a5,80002cc2 <bread+0x84>
    80002cb6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002cb8:	40bc                	lw	a5,64(s1)
    80002cba:	cb91                	beqz	a5,80002cce <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002cbc:	64a4                	ld	s1,72(s1)
    80002cbe:	fee49de3          	bne	s1,a4,80002cb8 <bread+0x7a>
  panic("bget: no buffers");
    80002cc2:	00004517          	auipc	a0,0x4
    80002cc6:	6de50513          	addi	a0,a0,1758 # 800073a0 <etext+0x3a0>
    80002cca:	b5bfd0ef          	jal	80000824 <panic>
      b->dev = dev;
    80002cce:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002cd2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002cd6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002cda:	4785                	li	a5,1
    80002cdc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002cde:	00015517          	auipc	a0,0x15
    80002ce2:	6a250513          	addi	a0,a0,1698 # 80018380 <bcache>
    80002ce6:	fd7fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002cea:	01048513          	addi	a0,s1,16
    80002cee:	288010ef          	jal	80003f76 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002cf2:	409c                	lw	a5,0(s1)
    80002cf4:	cb89                	beqz	a5,80002d06 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002cf6:	8526                	mv	a0,s1
    80002cf8:	70a2                	ld	ra,40(sp)
    80002cfa:	7402                	ld	s0,32(sp)
    80002cfc:	64e2                	ld	s1,24(sp)
    80002cfe:	6942                	ld	s2,16(sp)
    80002d00:	69a2                	ld	s3,8(sp)
    80002d02:	6145                	addi	sp,sp,48
    80002d04:	8082                	ret
    virtio_disk_rw(b, 0);
    80002d06:	4581                	li	a1,0
    80002d08:	8526                	mv	a0,s1
    80002d0a:	2f7020ef          	jal	80005800 <virtio_disk_rw>
    b->valid = 1;
    80002d0e:	4785                	li	a5,1
    80002d10:	c09c                	sw	a5,0(s1)
  return b;
    80002d12:	b7d5                	j	80002cf6 <bread+0xb8>

0000000080002d14 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002d14:	1101                	addi	sp,sp,-32
    80002d16:	ec06                	sd	ra,24(sp)
    80002d18:	e822                	sd	s0,16(sp)
    80002d1a:	e426                	sd	s1,8(sp)
    80002d1c:	1000                	addi	s0,sp,32
    80002d1e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d20:	0541                	addi	a0,a0,16
    80002d22:	2d2010ef          	jal	80003ff4 <holdingsleep>
    80002d26:	c911                	beqz	a0,80002d3a <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002d28:	4585                	li	a1,1
    80002d2a:	8526                	mv	a0,s1
    80002d2c:	2d5020ef          	jal	80005800 <virtio_disk_rw>
}
    80002d30:	60e2                	ld	ra,24(sp)
    80002d32:	6442                	ld	s0,16(sp)
    80002d34:	64a2                	ld	s1,8(sp)
    80002d36:	6105                	addi	sp,sp,32
    80002d38:	8082                	ret
    panic("bwrite");
    80002d3a:	00004517          	auipc	a0,0x4
    80002d3e:	67e50513          	addi	a0,a0,1662 # 800073b8 <etext+0x3b8>
    80002d42:	ae3fd0ef          	jal	80000824 <panic>

0000000080002d46 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002d46:	1101                	addi	sp,sp,-32
    80002d48:	ec06                	sd	ra,24(sp)
    80002d4a:	e822                	sd	s0,16(sp)
    80002d4c:	e426                	sd	s1,8(sp)
    80002d4e:	e04a                	sd	s2,0(sp)
    80002d50:	1000                	addi	s0,sp,32
    80002d52:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d54:	01050913          	addi	s2,a0,16
    80002d58:	854a                	mv	a0,s2
    80002d5a:	29a010ef          	jal	80003ff4 <holdingsleep>
    80002d5e:	c125                	beqz	a0,80002dbe <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002d60:	854a                	mv	a0,s2
    80002d62:	25a010ef          	jal	80003fbc <releasesleep>

  acquire(&bcache.lock);
    80002d66:	00015517          	auipc	a0,0x15
    80002d6a:	61a50513          	addi	a0,a0,1562 # 80018380 <bcache>
    80002d6e:	ebbfd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002d72:	40bc                	lw	a5,64(s1)
    80002d74:	37fd                	addiw	a5,a5,-1
    80002d76:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d78:	e79d                	bnez	a5,80002da6 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002d7a:	68b8                	ld	a4,80(s1)
    80002d7c:	64bc                	ld	a5,72(s1)
    80002d7e:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002d80:	68b8                	ld	a4,80(s1)
    80002d82:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d84:	0001d797          	auipc	a5,0x1d
    80002d88:	5fc78793          	addi	a5,a5,1532 # 80020380 <bcache+0x8000>
    80002d8c:	2b87b703          	ld	a4,696(a5)
    80002d90:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d92:	0001e717          	auipc	a4,0x1e
    80002d96:	85670713          	addi	a4,a4,-1962 # 800205e8 <bcache+0x8268>
    80002d9a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d9c:	2b87b703          	ld	a4,696(a5)
    80002da0:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002da2:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002da6:	00015517          	auipc	a0,0x15
    80002daa:	5da50513          	addi	a0,a0,1498 # 80018380 <bcache>
    80002dae:	f0ffd0ef          	jal	80000cbc <release>
}
    80002db2:	60e2                	ld	ra,24(sp)
    80002db4:	6442                	ld	s0,16(sp)
    80002db6:	64a2                	ld	s1,8(sp)
    80002db8:	6902                	ld	s2,0(sp)
    80002dba:	6105                	addi	sp,sp,32
    80002dbc:	8082                	ret
    panic("brelse");
    80002dbe:	00004517          	auipc	a0,0x4
    80002dc2:	60250513          	addi	a0,a0,1538 # 800073c0 <etext+0x3c0>
    80002dc6:	a5ffd0ef          	jal	80000824 <panic>

0000000080002dca <bpin>:

void
bpin(struct buf *b) {
    80002dca:	1101                	addi	sp,sp,-32
    80002dcc:	ec06                	sd	ra,24(sp)
    80002dce:	e822                	sd	s0,16(sp)
    80002dd0:	e426                	sd	s1,8(sp)
    80002dd2:	1000                	addi	s0,sp,32
    80002dd4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002dd6:	00015517          	auipc	a0,0x15
    80002dda:	5aa50513          	addi	a0,a0,1450 # 80018380 <bcache>
    80002dde:	e4bfd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002de2:	40bc                	lw	a5,64(s1)
    80002de4:	2785                	addiw	a5,a5,1
    80002de6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002de8:	00015517          	auipc	a0,0x15
    80002dec:	59850513          	addi	a0,a0,1432 # 80018380 <bcache>
    80002df0:	ecdfd0ef          	jal	80000cbc <release>
}
    80002df4:	60e2                	ld	ra,24(sp)
    80002df6:	6442                	ld	s0,16(sp)
    80002df8:	64a2                	ld	s1,8(sp)
    80002dfa:	6105                	addi	sp,sp,32
    80002dfc:	8082                	ret

0000000080002dfe <bunpin>:

void
bunpin(struct buf *b) {
    80002dfe:	1101                	addi	sp,sp,-32
    80002e00:	ec06                	sd	ra,24(sp)
    80002e02:	e822                	sd	s0,16(sp)
    80002e04:	e426                	sd	s1,8(sp)
    80002e06:	1000                	addi	s0,sp,32
    80002e08:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e0a:	00015517          	auipc	a0,0x15
    80002e0e:	57650513          	addi	a0,a0,1398 # 80018380 <bcache>
    80002e12:	e17fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002e16:	40bc                	lw	a5,64(s1)
    80002e18:	37fd                	addiw	a5,a5,-1
    80002e1a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e1c:	00015517          	auipc	a0,0x15
    80002e20:	56450513          	addi	a0,a0,1380 # 80018380 <bcache>
    80002e24:	e99fd0ef          	jal	80000cbc <release>
}
    80002e28:	60e2                	ld	ra,24(sp)
    80002e2a:	6442                	ld	s0,16(sp)
    80002e2c:	64a2                	ld	s1,8(sp)
    80002e2e:	6105                	addi	sp,sp,32
    80002e30:	8082                	ret

0000000080002e32 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002e32:	1101                	addi	sp,sp,-32
    80002e34:	ec06                	sd	ra,24(sp)
    80002e36:	e822                	sd	s0,16(sp)
    80002e38:	e426                	sd	s1,8(sp)
    80002e3a:	e04a                	sd	s2,0(sp)
    80002e3c:	1000                	addi	s0,sp,32
    80002e3e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002e40:	00d5d79b          	srliw	a5,a1,0xd
    80002e44:	0001e597          	auipc	a1,0x1e
    80002e48:	c185a583          	lw	a1,-1000(a1) # 80020a5c <sb+0x1c>
    80002e4c:	9dbd                	addw	a1,a1,a5
    80002e4e:	df1ff0ef          	jal	80002c3e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002e52:	0074f713          	andi	a4,s1,7
    80002e56:	4785                	li	a5,1
    80002e58:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002e5c:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80002e5e:	90d9                	srli	s1,s1,0x36
    80002e60:	00950733          	add	a4,a0,s1
    80002e64:	05874703          	lbu	a4,88(a4)
    80002e68:	00e7f6b3          	and	a3,a5,a4
    80002e6c:	c29d                	beqz	a3,80002e92 <bfree+0x60>
    80002e6e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002e70:	94aa                	add	s1,s1,a0
    80002e72:	fff7c793          	not	a5,a5
    80002e76:	8f7d                	and	a4,a4,a5
    80002e78:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002e7c:	000010ef          	jal	80003e7c <log_write>
  brelse(bp);
    80002e80:	854a                	mv	a0,s2
    80002e82:	ec5ff0ef          	jal	80002d46 <brelse>
}
    80002e86:	60e2                	ld	ra,24(sp)
    80002e88:	6442                	ld	s0,16(sp)
    80002e8a:	64a2                	ld	s1,8(sp)
    80002e8c:	6902                	ld	s2,0(sp)
    80002e8e:	6105                	addi	sp,sp,32
    80002e90:	8082                	ret
    panic("freeing free block");
    80002e92:	00004517          	auipc	a0,0x4
    80002e96:	53650513          	addi	a0,a0,1334 # 800073c8 <etext+0x3c8>
    80002e9a:	98bfd0ef          	jal	80000824 <panic>

0000000080002e9e <balloc>:
{
    80002e9e:	715d                	addi	sp,sp,-80
    80002ea0:	e486                	sd	ra,72(sp)
    80002ea2:	e0a2                	sd	s0,64(sp)
    80002ea4:	fc26                	sd	s1,56(sp)
    80002ea6:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80002ea8:	0001e797          	auipc	a5,0x1e
    80002eac:	b9c7a783          	lw	a5,-1124(a5) # 80020a44 <sb+0x4>
    80002eb0:	0e078263          	beqz	a5,80002f94 <balloc+0xf6>
    80002eb4:	f84a                	sd	s2,48(sp)
    80002eb6:	f44e                	sd	s3,40(sp)
    80002eb8:	f052                	sd	s4,32(sp)
    80002eba:	ec56                	sd	s5,24(sp)
    80002ebc:	e85a                	sd	s6,16(sp)
    80002ebe:	e45e                	sd	s7,8(sp)
    80002ec0:	e062                	sd	s8,0(sp)
    80002ec2:	8baa                	mv	s7,a0
    80002ec4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002ec6:	0001eb17          	auipc	s6,0x1e
    80002eca:	b7ab0b13          	addi	s6,s6,-1158 # 80020a40 <sb>
      m = 1 << (bi % 8);
    80002ece:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ed0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002ed2:	6c09                	lui	s8,0x2
    80002ed4:	a09d                	j	80002f3a <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002ed6:	97ca                	add	a5,a5,s2
    80002ed8:	8e55                	or	a2,a2,a3
    80002eda:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002ede:	854a                	mv	a0,s2
    80002ee0:	79d000ef          	jal	80003e7c <log_write>
        brelse(bp);
    80002ee4:	854a                	mv	a0,s2
    80002ee6:	e61ff0ef          	jal	80002d46 <brelse>
  bp = bread(dev, bno);
    80002eea:	85a6                	mv	a1,s1
    80002eec:	855e                	mv	a0,s7
    80002eee:	d51ff0ef          	jal	80002c3e <bread>
    80002ef2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002ef4:	40000613          	li	a2,1024
    80002ef8:	4581                	li	a1,0
    80002efa:	05850513          	addi	a0,a0,88
    80002efe:	dfbfd0ef          	jal	80000cf8 <memset>
  log_write(bp);
    80002f02:	854a                	mv	a0,s2
    80002f04:	779000ef          	jal	80003e7c <log_write>
  brelse(bp);
    80002f08:	854a                	mv	a0,s2
    80002f0a:	e3dff0ef          	jal	80002d46 <brelse>
}
    80002f0e:	7942                	ld	s2,48(sp)
    80002f10:	79a2                	ld	s3,40(sp)
    80002f12:	7a02                	ld	s4,32(sp)
    80002f14:	6ae2                	ld	s5,24(sp)
    80002f16:	6b42                	ld	s6,16(sp)
    80002f18:	6ba2                	ld	s7,8(sp)
    80002f1a:	6c02                	ld	s8,0(sp)
}
    80002f1c:	8526                	mv	a0,s1
    80002f1e:	60a6                	ld	ra,72(sp)
    80002f20:	6406                	ld	s0,64(sp)
    80002f22:	74e2                	ld	s1,56(sp)
    80002f24:	6161                	addi	sp,sp,80
    80002f26:	8082                	ret
    brelse(bp);
    80002f28:	854a                	mv	a0,s2
    80002f2a:	e1dff0ef          	jal	80002d46 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002f2e:	015c0abb          	addw	s5,s8,s5
    80002f32:	004b2783          	lw	a5,4(s6)
    80002f36:	04faf863          	bgeu	s5,a5,80002f86 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002f3a:	40dad59b          	sraiw	a1,s5,0xd
    80002f3e:	01cb2783          	lw	a5,28(s6)
    80002f42:	9dbd                	addw	a1,a1,a5
    80002f44:	855e                	mv	a0,s7
    80002f46:	cf9ff0ef          	jal	80002c3e <bread>
    80002f4a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f4c:	004b2503          	lw	a0,4(s6)
    80002f50:	84d6                	mv	s1,s5
    80002f52:	4701                	li	a4,0
    80002f54:	fca4fae3          	bgeu	s1,a0,80002f28 <balloc+0x8a>
      m = 1 << (bi % 8);
    80002f58:	00777693          	andi	a3,a4,7
    80002f5c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002f60:	41f7579b          	sraiw	a5,a4,0x1f
    80002f64:	01d7d79b          	srliw	a5,a5,0x1d
    80002f68:	9fb9                	addw	a5,a5,a4
    80002f6a:	4037d79b          	sraiw	a5,a5,0x3
    80002f6e:	00f90633          	add	a2,s2,a5
    80002f72:	05864603          	lbu	a2,88(a2)
    80002f76:	00c6f5b3          	and	a1,a3,a2
    80002f7a:	ddb1                	beqz	a1,80002ed6 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f7c:	2705                	addiw	a4,a4,1
    80002f7e:	2485                	addiw	s1,s1,1
    80002f80:	fd471ae3          	bne	a4,s4,80002f54 <balloc+0xb6>
    80002f84:	b755                	j	80002f28 <balloc+0x8a>
    80002f86:	7942                	ld	s2,48(sp)
    80002f88:	79a2                	ld	s3,40(sp)
    80002f8a:	7a02                	ld	s4,32(sp)
    80002f8c:	6ae2                	ld	s5,24(sp)
    80002f8e:	6b42                	ld	s6,16(sp)
    80002f90:	6ba2                	ld	s7,8(sp)
    80002f92:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80002f94:	00004517          	auipc	a0,0x4
    80002f98:	44c50513          	addi	a0,a0,1100 # 800073e0 <etext+0x3e0>
    80002f9c:	d5efd0ef          	jal	800004fa <printf>
  return 0;
    80002fa0:	4481                	li	s1,0
    80002fa2:	bfad                	j	80002f1c <balloc+0x7e>

0000000080002fa4 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002fa4:	7179                	addi	sp,sp,-48
    80002fa6:	f406                	sd	ra,40(sp)
    80002fa8:	f022                	sd	s0,32(sp)
    80002faa:	ec26                	sd	s1,24(sp)
    80002fac:	e84a                	sd	s2,16(sp)
    80002fae:	e44e                	sd	s3,8(sp)
    80002fb0:	1800                	addi	s0,sp,48
    80002fb2:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002fb4:	47ad                	li	a5,11
    80002fb6:	02b7e363          	bltu	a5,a1,80002fdc <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80002fba:	02059793          	slli	a5,a1,0x20
    80002fbe:	01e7d593          	srli	a1,a5,0x1e
    80002fc2:	00b509b3          	add	s3,a0,a1
    80002fc6:	0509a483          	lw	s1,80(s3)
    80002fca:	e0b5                	bnez	s1,8000302e <bmap+0x8a>
      addr = balloc(ip->dev);
    80002fcc:	4108                	lw	a0,0(a0)
    80002fce:	ed1ff0ef          	jal	80002e9e <balloc>
    80002fd2:	84aa                	mv	s1,a0
      if(addr == 0)
    80002fd4:	cd29                	beqz	a0,8000302e <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80002fd6:	04a9a823          	sw	a0,80(s3)
    80002fda:	a891                	j	8000302e <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002fdc:	ff45879b          	addiw	a5,a1,-12
    80002fe0:	873e                	mv	a4,a5
    80002fe2:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    80002fe4:	0ff00793          	li	a5,255
    80002fe8:	06e7e763          	bltu	a5,a4,80003056 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002fec:	08052483          	lw	s1,128(a0)
    80002ff0:	e891                	bnez	s1,80003004 <bmap+0x60>
      addr = balloc(ip->dev);
    80002ff2:	4108                	lw	a0,0(a0)
    80002ff4:	eabff0ef          	jal	80002e9e <balloc>
    80002ff8:	84aa                	mv	s1,a0
      if(addr == 0)
    80002ffa:	c915                	beqz	a0,8000302e <bmap+0x8a>
    80002ffc:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002ffe:	08a92023          	sw	a0,128(s2)
    80003002:	a011                	j	80003006 <bmap+0x62>
    80003004:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003006:	85a6                	mv	a1,s1
    80003008:	00092503          	lw	a0,0(s2)
    8000300c:	c33ff0ef          	jal	80002c3e <bread>
    80003010:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003012:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003016:	02099713          	slli	a4,s3,0x20
    8000301a:	01e75593          	srli	a1,a4,0x1e
    8000301e:	97ae                	add	a5,a5,a1
    80003020:	89be                	mv	s3,a5
    80003022:	4384                	lw	s1,0(a5)
    80003024:	cc89                	beqz	s1,8000303e <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003026:	8552                	mv	a0,s4
    80003028:	d1fff0ef          	jal	80002d46 <brelse>
    return addr;
    8000302c:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000302e:	8526                	mv	a0,s1
    80003030:	70a2                	ld	ra,40(sp)
    80003032:	7402                	ld	s0,32(sp)
    80003034:	64e2                	ld	s1,24(sp)
    80003036:	6942                	ld	s2,16(sp)
    80003038:	69a2                	ld	s3,8(sp)
    8000303a:	6145                	addi	sp,sp,48
    8000303c:	8082                	ret
      addr = balloc(ip->dev);
    8000303e:	00092503          	lw	a0,0(s2)
    80003042:	e5dff0ef          	jal	80002e9e <balloc>
    80003046:	84aa                	mv	s1,a0
      if(addr){
    80003048:	dd79                	beqz	a0,80003026 <bmap+0x82>
        a[bn] = addr;
    8000304a:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    8000304e:	8552                	mv	a0,s4
    80003050:	62d000ef          	jal	80003e7c <log_write>
    80003054:	bfc9                	j	80003026 <bmap+0x82>
    80003056:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003058:	00004517          	auipc	a0,0x4
    8000305c:	3a050513          	addi	a0,a0,928 # 800073f8 <etext+0x3f8>
    80003060:	fc4fd0ef          	jal	80000824 <panic>

0000000080003064 <iget>:
{
    80003064:	7179                	addi	sp,sp,-48
    80003066:	f406                	sd	ra,40(sp)
    80003068:	f022                	sd	s0,32(sp)
    8000306a:	ec26                	sd	s1,24(sp)
    8000306c:	e84a                	sd	s2,16(sp)
    8000306e:	e44e                	sd	s3,8(sp)
    80003070:	e052                	sd	s4,0(sp)
    80003072:	1800                	addi	s0,sp,48
    80003074:	892a                	mv	s2,a0
    80003076:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003078:	0001e517          	auipc	a0,0x1e
    8000307c:	9e850513          	addi	a0,a0,-1560 # 80020a60 <itable>
    80003080:	ba9fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    80003084:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003086:	0001e497          	auipc	s1,0x1e
    8000308a:	9f248493          	addi	s1,s1,-1550 # 80020a78 <itable+0x18>
    8000308e:	0001f697          	auipc	a3,0x1f
    80003092:	47a68693          	addi	a3,a3,1146 # 80022508 <log>
    80003096:	a809                	j	800030a8 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003098:	e781                	bnez	a5,800030a0 <iget+0x3c>
    8000309a:	00099363          	bnez	s3,800030a0 <iget+0x3c>
      empty = ip;
    8000309e:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800030a0:	08848493          	addi	s1,s1,136
    800030a4:	02d48563          	beq	s1,a3,800030ce <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800030a8:	449c                	lw	a5,8(s1)
    800030aa:	fef057e3          	blez	a5,80003098 <iget+0x34>
    800030ae:	4098                	lw	a4,0(s1)
    800030b0:	ff2718e3          	bne	a4,s2,800030a0 <iget+0x3c>
    800030b4:	40d8                	lw	a4,4(s1)
    800030b6:	ff4715e3          	bne	a4,s4,800030a0 <iget+0x3c>
      ip->ref++;
    800030ba:	2785                	addiw	a5,a5,1
    800030bc:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800030be:	0001e517          	auipc	a0,0x1e
    800030c2:	9a250513          	addi	a0,a0,-1630 # 80020a60 <itable>
    800030c6:	bf7fd0ef          	jal	80000cbc <release>
      return ip;
    800030ca:	89a6                	mv	s3,s1
    800030cc:	a015                	j	800030f0 <iget+0x8c>
  if(empty == 0)
    800030ce:	02098a63          	beqz	s3,80003102 <iget+0x9e>
  ip->dev = dev;
    800030d2:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    800030d6:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    800030da:	4785                	li	a5,1
    800030dc:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    800030e0:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    800030e4:	0001e517          	auipc	a0,0x1e
    800030e8:	97c50513          	addi	a0,a0,-1668 # 80020a60 <itable>
    800030ec:	bd1fd0ef          	jal	80000cbc <release>
}
    800030f0:	854e                	mv	a0,s3
    800030f2:	70a2                	ld	ra,40(sp)
    800030f4:	7402                	ld	s0,32(sp)
    800030f6:	64e2                	ld	s1,24(sp)
    800030f8:	6942                	ld	s2,16(sp)
    800030fa:	69a2                	ld	s3,8(sp)
    800030fc:	6a02                	ld	s4,0(sp)
    800030fe:	6145                	addi	sp,sp,48
    80003100:	8082                	ret
    panic("iget: no inodes");
    80003102:	00004517          	auipc	a0,0x4
    80003106:	30e50513          	addi	a0,a0,782 # 80007410 <etext+0x410>
    8000310a:	f1afd0ef          	jal	80000824 <panic>

000000008000310e <iinit>:
{
    8000310e:	7179                	addi	sp,sp,-48
    80003110:	f406                	sd	ra,40(sp)
    80003112:	f022                	sd	s0,32(sp)
    80003114:	ec26                	sd	s1,24(sp)
    80003116:	e84a                	sd	s2,16(sp)
    80003118:	e44e                	sd	s3,8(sp)
    8000311a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000311c:	00004597          	auipc	a1,0x4
    80003120:	30458593          	addi	a1,a1,772 # 80007420 <etext+0x420>
    80003124:	0001e517          	auipc	a0,0x1e
    80003128:	93c50513          	addi	a0,a0,-1732 # 80020a60 <itable>
    8000312c:	a73fd0ef          	jal	80000b9e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003130:	0001e497          	auipc	s1,0x1e
    80003134:	95848493          	addi	s1,s1,-1704 # 80020a88 <itable+0x28>
    80003138:	0001f997          	auipc	s3,0x1f
    8000313c:	3e098993          	addi	s3,s3,992 # 80022518 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003140:	00004917          	auipc	s2,0x4
    80003144:	2e890913          	addi	s2,s2,744 # 80007428 <etext+0x428>
    80003148:	85ca                	mv	a1,s2
    8000314a:	8526                	mv	a0,s1
    8000314c:	5f5000ef          	jal	80003f40 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003150:	08848493          	addi	s1,s1,136
    80003154:	ff349ae3          	bne	s1,s3,80003148 <iinit+0x3a>
}
    80003158:	70a2                	ld	ra,40(sp)
    8000315a:	7402                	ld	s0,32(sp)
    8000315c:	64e2                	ld	s1,24(sp)
    8000315e:	6942                	ld	s2,16(sp)
    80003160:	69a2                	ld	s3,8(sp)
    80003162:	6145                	addi	sp,sp,48
    80003164:	8082                	ret

0000000080003166 <ialloc>:
{
    80003166:	7139                	addi	sp,sp,-64
    80003168:	fc06                	sd	ra,56(sp)
    8000316a:	f822                	sd	s0,48(sp)
    8000316c:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000316e:	0001e717          	auipc	a4,0x1e
    80003172:	8de72703          	lw	a4,-1826(a4) # 80020a4c <sb+0xc>
    80003176:	4785                	li	a5,1
    80003178:	06e7f063          	bgeu	a5,a4,800031d8 <ialloc+0x72>
    8000317c:	f426                	sd	s1,40(sp)
    8000317e:	f04a                	sd	s2,32(sp)
    80003180:	ec4e                	sd	s3,24(sp)
    80003182:	e852                	sd	s4,16(sp)
    80003184:	e456                	sd	s5,8(sp)
    80003186:	e05a                	sd	s6,0(sp)
    80003188:	8aaa                	mv	s5,a0
    8000318a:	8b2e                	mv	s6,a1
    8000318c:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    8000318e:	0001ea17          	auipc	s4,0x1e
    80003192:	8b2a0a13          	addi	s4,s4,-1870 # 80020a40 <sb>
    80003196:	00495593          	srli	a1,s2,0x4
    8000319a:	018a2783          	lw	a5,24(s4)
    8000319e:	9dbd                	addw	a1,a1,a5
    800031a0:	8556                	mv	a0,s5
    800031a2:	a9dff0ef          	jal	80002c3e <bread>
    800031a6:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800031a8:	05850993          	addi	s3,a0,88
    800031ac:	00f97793          	andi	a5,s2,15
    800031b0:	079a                	slli	a5,a5,0x6
    800031b2:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800031b4:	00099783          	lh	a5,0(s3)
    800031b8:	cb9d                	beqz	a5,800031ee <ialloc+0x88>
    brelse(bp);
    800031ba:	b8dff0ef          	jal	80002d46 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800031be:	0905                	addi	s2,s2,1
    800031c0:	00ca2703          	lw	a4,12(s4)
    800031c4:	0009079b          	sext.w	a5,s2
    800031c8:	fce7e7e3          	bltu	a5,a4,80003196 <ialloc+0x30>
    800031cc:	74a2                	ld	s1,40(sp)
    800031ce:	7902                	ld	s2,32(sp)
    800031d0:	69e2                	ld	s3,24(sp)
    800031d2:	6a42                	ld	s4,16(sp)
    800031d4:	6aa2                	ld	s5,8(sp)
    800031d6:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800031d8:	00004517          	auipc	a0,0x4
    800031dc:	25850513          	addi	a0,a0,600 # 80007430 <etext+0x430>
    800031e0:	b1afd0ef          	jal	800004fa <printf>
  return 0;
    800031e4:	4501                	li	a0,0
}
    800031e6:	70e2                	ld	ra,56(sp)
    800031e8:	7442                	ld	s0,48(sp)
    800031ea:	6121                	addi	sp,sp,64
    800031ec:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800031ee:	04000613          	li	a2,64
    800031f2:	4581                	li	a1,0
    800031f4:	854e                	mv	a0,s3
    800031f6:	b03fd0ef          	jal	80000cf8 <memset>
      dip->type = type;
    800031fa:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800031fe:	8526                	mv	a0,s1
    80003200:	47d000ef          	jal	80003e7c <log_write>
      brelse(bp);
    80003204:	8526                	mv	a0,s1
    80003206:	b41ff0ef          	jal	80002d46 <brelse>
      return iget(dev, inum);
    8000320a:	0009059b          	sext.w	a1,s2
    8000320e:	8556                	mv	a0,s5
    80003210:	e55ff0ef          	jal	80003064 <iget>
    80003214:	74a2                	ld	s1,40(sp)
    80003216:	7902                	ld	s2,32(sp)
    80003218:	69e2                	ld	s3,24(sp)
    8000321a:	6a42                	ld	s4,16(sp)
    8000321c:	6aa2                	ld	s5,8(sp)
    8000321e:	6b02                	ld	s6,0(sp)
    80003220:	b7d9                	j	800031e6 <ialloc+0x80>

0000000080003222 <iupdate>:
{
    80003222:	1101                	addi	sp,sp,-32
    80003224:	ec06                	sd	ra,24(sp)
    80003226:	e822                	sd	s0,16(sp)
    80003228:	e426                	sd	s1,8(sp)
    8000322a:	e04a                	sd	s2,0(sp)
    8000322c:	1000                	addi	s0,sp,32
    8000322e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003230:	415c                	lw	a5,4(a0)
    80003232:	0047d79b          	srliw	a5,a5,0x4
    80003236:	0001e597          	auipc	a1,0x1e
    8000323a:	8225a583          	lw	a1,-2014(a1) # 80020a58 <sb+0x18>
    8000323e:	9dbd                	addw	a1,a1,a5
    80003240:	4108                	lw	a0,0(a0)
    80003242:	9fdff0ef          	jal	80002c3e <bread>
    80003246:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003248:	05850793          	addi	a5,a0,88
    8000324c:	40d8                	lw	a4,4(s1)
    8000324e:	8b3d                	andi	a4,a4,15
    80003250:	071a                	slli	a4,a4,0x6
    80003252:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003254:	04449703          	lh	a4,68(s1)
    80003258:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000325c:	04649703          	lh	a4,70(s1)
    80003260:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003264:	04849703          	lh	a4,72(s1)
    80003268:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000326c:	04a49703          	lh	a4,74(s1)
    80003270:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003274:	44f8                	lw	a4,76(s1)
    80003276:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003278:	03400613          	li	a2,52
    8000327c:	05048593          	addi	a1,s1,80
    80003280:	00c78513          	addi	a0,a5,12
    80003284:	ad5fd0ef          	jal	80000d58 <memmove>
  log_write(bp);
    80003288:	854a                	mv	a0,s2
    8000328a:	3f3000ef          	jal	80003e7c <log_write>
  brelse(bp);
    8000328e:	854a                	mv	a0,s2
    80003290:	ab7ff0ef          	jal	80002d46 <brelse>
}
    80003294:	60e2                	ld	ra,24(sp)
    80003296:	6442                	ld	s0,16(sp)
    80003298:	64a2                	ld	s1,8(sp)
    8000329a:	6902                	ld	s2,0(sp)
    8000329c:	6105                	addi	sp,sp,32
    8000329e:	8082                	ret

00000000800032a0 <idup>:
{
    800032a0:	1101                	addi	sp,sp,-32
    800032a2:	ec06                	sd	ra,24(sp)
    800032a4:	e822                	sd	s0,16(sp)
    800032a6:	e426                	sd	s1,8(sp)
    800032a8:	1000                	addi	s0,sp,32
    800032aa:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800032ac:	0001d517          	auipc	a0,0x1d
    800032b0:	7b450513          	addi	a0,a0,1972 # 80020a60 <itable>
    800032b4:	975fd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    800032b8:	449c                	lw	a5,8(s1)
    800032ba:	2785                	addiw	a5,a5,1
    800032bc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800032be:	0001d517          	auipc	a0,0x1d
    800032c2:	7a250513          	addi	a0,a0,1954 # 80020a60 <itable>
    800032c6:	9f7fd0ef          	jal	80000cbc <release>
}
    800032ca:	8526                	mv	a0,s1
    800032cc:	60e2                	ld	ra,24(sp)
    800032ce:	6442                	ld	s0,16(sp)
    800032d0:	64a2                	ld	s1,8(sp)
    800032d2:	6105                	addi	sp,sp,32
    800032d4:	8082                	ret

00000000800032d6 <ilock>:
{
    800032d6:	1101                	addi	sp,sp,-32
    800032d8:	ec06                	sd	ra,24(sp)
    800032da:	e822                	sd	s0,16(sp)
    800032dc:	e426                	sd	s1,8(sp)
    800032de:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800032e0:	cd19                	beqz	a0,800032fe <ilock+0x28>
    800032e2:	84aa                	mv	s1,a0
    800032e4:	451c                	lw	a5,8(a0)
    800032e6:	00f05c63          	blez	a5,800032fe <ilock+0x28>
  acquiresleep(&ip->lock);
    800032ea:	0541                	addi	a0,a0,16
    800032ec:	48b000ef          	jal	80003f76 <acquiresleep>
  if(ip->valid == 0){
    800032f0:	40bc                	lw	a5,64(s1)
    800032f2:	cf89                	beqz	a5,8000330c <ilock+0x36>
}
    800032f4:	60e2                	ld	ra,24(sp)
    800032f6:	6442                	ld	s0,16(sp)
    800032f8:	64a2                	ld	s1,8(sp)
    800032fa:	6105                	addi	sp,sp,32
    800032fc:	8082                	ret
    800032fe:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003300:	00004517          	auipc	a0,0x4
    80003304:	14850513          	addi	a0,a0,328 # 80007448 <etext+0x448>
    80003308:	d1cfd0ef          	jal	80000824 <panic>
    8000330c:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000330e:	40dc                	lw	a5,4(s1)
    80003310:	0047d79b          	srliw	a5,a5,0x4
    80003314:	0001d597          	auipc	a1,0x1d
    80003318:	7445a583          	lw	a1,1860(a1) # 80020a58 <sb+0x18>
    8000331c:	9dbd                	addw	a1,a1,a5
    8000331e:	4088                	lw	a0,0(s1)
    80003320:	91fff0ef          	jal	80002c3e <bread>
    80003324:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003326:	05850593          	addi	a1,a0,88
    8000332a:	40dc                	lw	a5,4(s1)
    8000332c:	8bbd                	andi	a5,a5,15
    8000332e:	079a                	slli	a5,a5,0x6
    80003330:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003332:	00059783          	lh	a5,0(a1)
    80003336:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000333a:	00259783          	lh	a5,2(a1)
    8000333e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003342:	00459783          	lh	a5,4(a1)
    80003346:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000334a:	00659783          	lh	a5,6(a1)
    8000334e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003352:	459c                	lw	a5,8(a1)
    80003354:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003356:	03400613          	li	a2,52
    8000335a:	05b1                	addi	a1,a1,12
    8000335c:	05048513          	addi	a0,s1,80
    80003360:	9f9fd0ef          	jal	80000d58 <memmove>
    brelse(bp);
    80003364:	854a                	mv	a0,s2
    80003366:	9e1ff0ef          	jal	80002d46 <brelse>
    ip->valid = 1;
    8000336a:	4785                	li	a5,1
    8000336c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000336e:	04449783          	lh	a5,68(s1)
    80003372:	c399                	beqz	a5,80003378 <ilock+0xa2>
    80003374:	6902                	ld	s2,0(sp)
    80003376:	bfbd                	j	800032f4 <ilock+0x1e>
      panic("ilock: no type");
    80003378:	00004517          	auipc	a0,0x4
    8000337c:	0d850513          	addi	a0,a0,216 # 80007450 <etext+0x450>
    80003380:	ca4fd0ef          	jal	80000824 <panic>

0000000080003384 <iunlock>:
{
    80003384:	1101                	addi	sp,sp,-32
    80003386:	ec06                	sd	ra,24(sp)
    80003388:	e822                	sd	s0,16(sp)
    8000338a:	e426                	sd	s1,8(sp)
    8000338c:	e04a                	sd	s2,0(sp)
    8000338e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003390:	c505                	beqz	a0,800033b8 <iunlock+0x34>
    80003392:	84aa                	mv	s1,a0
    80003394:	01050913          	addi	s2,a0,16
    80003398:	854a                	mv	a0,s2
    8000339a:	45b000ef          	jal	80003ff4 <holdingsleep>
    8000339e:	cd09                	beqz	a0,800033b8 <iunlock+0x34>
    800033a0:	449c                	lw	a5,8(s1)
    800033a2:	00f05b63          	blez	a5,800033b8 <iunlock+0x34>
  releasesleep(&ip->lock);
    800033a6:	854a                	mv	a0,s2
    800033a8:	415000ef          	jal	80003fbc <releasesleep>
}
    800033ac:	60e2                	ld	ra,24(sp)
    800033ae:	6442                	ld	s0,16(sp)
    800033b0:	64a2                	ld	s1,8(sp)
    800033b2:	6902                	ld	s2,0(sp)
    800033b4:	6105                	addi	sp,sp,32
    800033b6:	8082                	ret
    panic("iunlock");
    800033b8:	00004517          	auipc	a0,0x4
    800033bc:	0a850513          	addi	a0,a0,168 # 80007460 <etext+0x460>
    800033c0:	c64fd0ef          	jal	80000824 <panic>

00000000800033c4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800033c4:	7179                	addi	sp,sp,-48
    800033c6:	f406                	sd	ra,40(sp)
    800033c8:	f022                	sd	s0,32(sp)
    800033ca:	ec26                	sd	s1,24(sp)
    800033cc:	e84a                	sd	s2,16(sp)
    800033ce:	e44e                	sd	s3,8(sp)
    800033d0:	1800                	addi	s0,sp,48
    800033d2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800033d4:	05050493          	addi	s1,a0,80
    800033d8:	08050913          	addi	s2,a0,128
    800033dc:	a021                	j	800033e4 <itrunc+0x20>
    800033de:	0491                	addi	s1,s1,4
    800033e0:	01248b63          	beq	s1,s2,800033f6 <itrunc+0x32>
    if(ip->addrs[i]){
    800033e4:	408c                	lw	a1,0(s1)
    800033e6:	dde5                	beqz	a1,800033de <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800033e8:	0009a503          	lw	a0,0(s3)
    800033ec:	a47ff0ef          	jal	80002e32 <bfree>
      ip->addrs[i] = 0;
    800033f0:	0004a023          	sw	zero,0(s1)
    800033f4:	b7ed                	j	800033de <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800033f6:	0809a583          	lw	a1,128(s3)
    800033fa:	ed89                	bnez	a1,80003414 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800033fc:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003400:	854e                	mv	a0,s3
    80003402:	e21ff0ef          	jal	80003222 <iupdate>
}
    80003406:	70a2                	ld	ra,40(sp)
    80003408:	7402                	ld	s0,32(sp)
    8000340a:	64e2                	ld	s1,24(sp)
    8000340c:	6942                	ld	s2,16(sp)
    8000340e:	69a2                	ld	s3,8(sp)
    80003410:	6145                	addi	sp,sp,48
    80003412:	8082                	ret
    80003414:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003416:	0009a503          	lw	a0,0(s3)
    8000341a:	825ff0ef          	jal	80002c3e <bread>
    8000341e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003420:	05850493          	addi	s1,a0,88
    80003424:	45850913          	addi	s2,a0,1112
    80003428:	a021                	j	80003430 <itrunc+0x6c>
    8000342a:	0491                	addi	s1,s1,4
    8000342c:	01248963          	beq	s1,s2,8000343e <itrunc+0x7a>
      if(a[j])
    80003430:	408c                	lw	a1,0(s1)
    80003432:	dde5                	beqz	a1,8000342a <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003434:	0009a503          	lw	a0,0(s3)
    80003438:	9fbff0ef          	jal	80002e32 <bfree>
    8000343c:	b7fd                	j	8000342a <itrunc+0x66>
    brelse(bp);
    8000343e:	8552                	mv	a0,s4
    80003440:	907ff0ef          	jal	80002d46 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003444:	0809a583          	lw	a1,128(s3)
    80003448:	0009a503          	lw	a0,0(s3)
    8000344c:	9e7ff0ef          	jal	80002e32 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003450:	0809a023          	sw	zero,128(s3)
    80003454:	6a02                	ld	s4,0(sp)
    80003456:	b75d                	j	800033fc <itrunc+0x38>

0000000080003458 <iput>:
{
    80003458:	1101                	addi	sp,sp,-32
    8000345a:	ec06                	sd	ra,24(sp)
    8000345c:	e822                	sd	s0,16(sp)
    8000345e:	e426                	sd	s1,8(sp)
    80003460:	1000                	addi	s0,sp,32
    80003462:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003464:	0001d517          	auipc	a0,0x1d
    80003468:	5fc50513          	addi	a0,a0,1532 # 80020a60 <itable>
    8000346c:	fbcfd0ef          	jal	80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003470:	4498                	lw	a4,8(s1)
    80003472:	4785                	li	a5,1
    80003474:	02f70063          	beq	a4,a5,80003494 <iput+0x3c>
  ip->ref--;
    80003478:	449c                	lw	a5,8(s1)
    8000347a:	37fd                	addiw	a5,a5,-1
    8000347c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000347e:	0001d517          	auipc	a0,0x1d
    80003482:	5e250513          	addi	a0,a0,1506 # 80020a60 <itable>
    80003486:	837fd0ef          	jal	80000cbc <release>
}
    8000348a:	60e2                	ld	ra,24(sp)
    8000348c:	6442                	ld	s0,16(sp)
    8000348e:	64a2                	ld	s1,8(sp)
    80003490:	6105                	addi	sp,sp,32
    80003492:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003494:	40bc                	lw	a5,64(s1)
    80003496:	d3ed                	beqz	a5,80003478 <iput+0x20>
    80003498:	04a49783          	lh	a5,74(s1)
    8000349c:	fff1                	bnez	a5,80003478 <iput+0x20>
    8000349e:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800034a0:	01048793          	addi	a5,s1,16
    800034a4:	893e                	mv	s2,a5
    800034a6:	853e                	mv	a0,a5
    800034a8:	2cf000ef          	jal	80003f76 <acquiresleep>
    release(&itable.lock);
    800034ac:	0001d517          	auipc	a0,0x1d
    800034b0:	5b450513          	addi	a0,a0,1460 # 80020a60 <itable>
    800034b4:	809fd0ef          	jal	80000cbc <release>
    itrunc(ip);
    800034b8:	8526                	mv	a0,s1
    800034ba:	f0bff0ef          	jal	800033c4 <itrunc>
    ip->type = 0;
    800034be:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800034c2:	8526                	mv	a0,s1
    800034c4:	d5fff0ef          	jal	80003222 <iupdate>
    ip->valid = 0;
    800034c8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800034cc:	854a                	mv	a0,s2
    800034ce:	2ef000ef          	jal	80003fbc <releasesleep>
    acquire(&itable.lock);
    800034d2:	0001d517          	auipc	a0,0x1d
    800034d6:	58e50513          	addi	a0,a0,1422 # 80020a60 <itable>
    800034da:	f4efd0ef          	jal	80000c28 <acquire>
    800034de:	6902                	ld	s2,0(sp)
    800034e0:	bf61                	j	80003478 <iput+0x20>

00000000800034e2 <iunlockput>:
{
    800034e2:	1101                	addi	sp,sp,-32
    800034e4:	ec06                	sd	ra,24(sp)
    800034e6:	e822                	sd	s0,16(sp)
    800034e8:	e426                	sd	s1,8(sp)
    800034ea:	1000                	addi	s0,sp,32
    800034ec:	84aa                	mv	s1,a0
  iunlock(ip);
    800034ee:	e97ff0ef          	jal	80003384 <iunlock>
  iput(ip);
    800034f2:	8526                	mv	a0,s1
    800034f4:	f65ff0ef          	jal	80003458 <iput>
}
    800034f8:	60e2                	ld	ra,24(sp)
    800034fa:	6442                	ld	s0,16(sp)
    800034fc:	64a2                	ld	s1,8(sp)
    800034fe:	6105                	addi	sp,sp,32
    80003500:	8082                	ret

0000000080003502 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003502:	0001d717          	auipc	a4,0x1d
    80003506:	54a72703          	lw	a4,1354(a4) # 80020a4c <sb+0xc>
    8000350a:	4785                	li	a5,1
    8000350c:	0ae7fe63          	bgeu	a5,a4,800035c8 <ireclaim+0xc6>
{
    80003510:	7139                	addi	sp,sp,-64
    80003512:	fc06                	sd	ra,56(sp)
    80003514:	f822                	sd	s0,48(sp)
    80003516:	f426                	sd	s1,40(sp)
    80003518:	f04a                	sd	s2,32(sp)
    8000351a:	ec4e                	sd	s3,24(sp)
    8000351c:	e852                	sd	s4,16(sp)
    8000351e:	e456                	sd	s5,8(sp)
    80003520:	e05a                	sd	s6,0(sp)
    80003522:	0080                	addi	s0,sp,64
    80003524:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003526:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003528:	0001da17          	auipc	s4,0x1d
    8000352c:	518a0a13          	addi	s4,s4,1304 # 80020a40 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003530:	00004b17          	auipc	s6,0x4
    80003534:	f38b0b13          	addi	s6,s6,-200 # 80007468 <etext+0x468>
    80003538:	a099                	j	8000357e <ireclaim+0x7c>
    8000353a:	85ce                	mv	a1,s3
    8000353c:	855a                	mv	a0,s6
    8000353e:	fbdfc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003542:	85ce                	mv	a1,s3
    80003544:	8556                	mv	a0,s5
    80003546:	b1fff0ef          	jal	80003064 <iget>
    8000354a:	89aa                	mv	s3,a0
    brelse(bp);
    8000354c:	854a                	mv	a0,s2
    8000354e:	ff8ff0ef          	jal	80002d46 <brelse>
    if (ip) {
    80003552:	00098f63          	beqz	s3,80003570 <ireclaim+0x6e>
      begin_op();
    80003556:	78c000ef          	jal	80003ce2 <begin_op>
      ilock(ip);
    8000355a:	854e                	mv	a0,s3
    8000355c:	d7bff0ef          	jal	800032d6 <ilock>
      iunlock(ip);
    80003560:	854e                	mv	a0,s3
    80003562:	e23ff0ef          	jal	80003384 <iunlock>
      iput(ip);
    80003566:	854e                	mv	a0,s3
    80003568:	ef1ff0ef          	jal	80003458 <iput>
      end_op();
    8000356c:	7e6000ef          	jal	80003d52 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003570:	0485                	addi	s1,s1,1
    80003572:	00ca2703          	lw	a4,12(s4)
    80003576:	0004879b          	sext.w	a5,s1
    8000357a:	02e7fd63          	bgeu	a5,a4,800035b4 <ireclaim+0xb2>
    8000357e:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003582:	0044d593          	srli	a1,s1,0x4
    80003586:	018a2783          	lw	a5,24(s4)
    8000358a:	9dbd                	addw	a1,a1,a5
    8000358c:	8556                	mv	a0,s5
    8000358e:	eb0ff0ef          	jal	80002c3e <bread>
    80003592:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003594:	05850793          	addi	a5,a0,88
    80003598:	00f9f713          	andi	a4,s3,15
    8000359c:	071a                	slli	a4,a4,0x6
    8000359e:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800035a0:	00079703          	lh	a4,0(a5)
    800035a4:	c701                	beqz	a4,800035ac <ireclaim+0xaa>
    800035a6:	00679783          	lh	a5,6(a5)
    800035aa:	dbc1                	beqz	a5,8000353a <ireclaim+0x38>
    brelse(bp);
    800035ac:	854a                	mv	a0,s2
    800035ae:	f98ff0ef          	jal	80002d46 <brelse>
    if (ip) {
    800035b2:	bf7d                	j	80003570 <ireclaim+0x6e>
}
    800035b4:	70e2                	ld	ra,56(sp)
    800035b6:	7442                	ld	s0,48(sp)
    800035b8:	74a2                	ld	s1,40(sp)
    800035ba:	7902                	ld	s2,32(sp)
    800035bc:	69e2                	ld	s3,24(sp)
    800035be:	6a42                	ld	s4,16(sp)
    800035c0:	6aa2                	ld	s5,8(sp)
    800035c2:	6b02                	ld	s6,0(sp)
    800035c4:	6121                	addi	sp,sp,64
    800035c6:	8082                	ret
    800035c8:	8082                	ret

00000000800035ca <fsinit>:
fsinit(int dev) {
    800035ca:	1101                	addi	sp,sp,-32
    800035cc:	ec06                	sd	ra,24(sp)
    800035ce:	e822                	sd	s0,16(sp)
    800035d0:	e426                	sd	s1,8(sp)
    800035d2:	e04a                	sd	s2,0(sp)
    800035d4:	1000                	addi	s0,sp,32
    800035d6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800035d8:	4585                	li	a1,1
    800035da:	e64ff0ef          	jal	80002c3e <bread>
    800035de:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800035e0:	02000613          	li	a2,32
    800035e4:	05850593          	addi	a1,a0,88
    800035e8:	0001d517          	auipc	a0,0x1d
    800035ec:	45850513          	addi	a0,a0,1112 # 80020a40 <sb>
    800035f0:	f68fd0ef          	jal	80000d58 <memmove>
  brelse(bp);
    800035f4:	8526                	mv	a0,s1
    800035f6:	f50ff0ef          	jal	80002d46 <brelse>
  if(sb.magic != FSMAGIC)
    800035fa:	0001d717          	auipc	a4,0x1d
    800035fe:	44672703          	lw	a4,1094(a4) # 80020a40 <sb>
    80003602:	102037b7          	lui	a5,0x10203
    80003606:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000360a:	02f71263          	bne	a4,a5,8000362e <fsinit+0x64>
  initlog(dev, &sb);
    8000360e:	0001d597          	auipc	a1,0x1d
    80003612:	43258593          	addi	a1,a1,1074 # 80020a40 <sb>
    80003616:	854a                	mv	a0,s2
    80003618:	648000ef          	jal	80003c60 <initlog>
  ireclaim(dev);
    8000361c:	854a                	mv	a0,s2
    8000361e:	ee5ff0ef          	jal	80003502 <ireclaim>
}
    80003622:	60e2                	ld	ra,24(sp)
    80003624:	6442                	ld	s0,16(sp)
    80003626:	64a2                	ld	s1,8(sp)
    80003628:	6902                	ld	s2,0(sp)
    8000362a:	6105                	addi	sp,sp,32
    8000362c:	8082                	ret
    panic("invalid file system");
    8000362e:	00004517          	auipc	a0,0x4
    80003632:	e5a50513          	addi	a0,a0,-422 # 80007488 <etext+0x488>
    80003636:	9eefd0ef          	jal	80000824 <panic>

000000008000363a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000363a:	1141                	addi	sp,sp,-16
    8000363c:	e406                	sd	ra,8(sp)
    8000363e:	e022                	sd	s0,0(sp)
    80003640:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003642:	411c                	lw	a5,0(a0)
    80003644:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003646:	415c                	lw	a5,4(a0)
    80003648:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000364a:	04451783          	lh	a5,68(a0)
    8000364e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003652:	04a51783          	lh	a5,74(a0)
    80003656:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000365a:	04c56783          	lwu	a5,76(a0)
    8000365e:	e99c                	sd	a5,16(a1)
}
    80003660:	60a2                	ld	ra,8(sp)
    80003662:	6402                	ld	s0,0(sp)
    80003664:	0141                	addi	sp,sp,16
    80003666:	8082                	ret

0000000080003668 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003668:	457c                	lw	a5,76(a0)
    8000366a:	0ed7e663          	bltu	a5,a3,80003756 <readi+0xee>
{
    8000366e:	7159                	addi	sp,sp,-112
    80003670:	f486                	sd	ra,104(sp)
    80003672:	f0a2                	sd	s0,96(sp)
    80003674:	eca6                	sd	s1,88(sp)
    80003676:	e0d2                	sd	s4,64(sp)
    80003678:	fc56                	sd	s5,56(sp)
    8000367a:	f85a                	sd	s6,48(sp)
    8000367c:	f45e                	sd	s7,40(sp)
    8000367e:	1880                	addi	s0,sp,112
    80003680:	8b2a                	mv	s6,a0
    80003682:	8bae                	mv	s7,a1
    80003684:	8a32                	mv	s4,a2
    80003686:	84b6                	mv	s1,a3
    80003688:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000368a:	9f35                	addw	a4,a4,a3
    return 0;
    8000368c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000368e:	0ad76b63          	bltu	a4,a3,80003744 <readi+0xdc>
    80003692:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003694:	00e7f463          	bgeu	a5,a4,8000369c <readi+0x34>
    n = ip->size - off;
    80003698:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000369c:	080a8b63          	beqz	s5,80003732 <readi+0xca>
    800036a0:	e8ca                	sd	s2,80(sp)
    800036a2:	f062                	sd	s8,32(sp)
    800036a4:	ec66                	sd	s9,24(sp)
    800036a6:	e86a                	sd	s10,16(sp)
    800036a8:	e46e                	sd	s11,8(sp)
    800036aa:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800036ac:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800036b0:	5c7d                	li	s8,-1
    800036b2:	a80d                	j	800036e4 <readi+0x7c>
    800036b4:	020d1d93          	slli	s11,s10,0x20
    800036b8:	020ddd93          	srli	s11,s11,0x20
    800036bc:	05890613          	addi	a2,s2,88
    800036c0:	86ee                	mv	a3,s11
    800036c2:	963e                	add	a2,a2,a5
    800036c4:	85d2                	mv	a1,s4
    800036c6:	855e                	mv	a0,s7
    800036c8:	c93fe0ef          	jal	8000235a <either_copyout>
    800036cc:	05850363          	beq	a0,s8,80003712 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800036d0:	854a                	mv	a0,s2
    800036d2:	e74ff0ef          	jal	80002d46 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800036d6:	013d09bb          	addw	s3,s10,s3
    800036da:	009d04bb          	addw	s1,s10,s1
    800036de:	9a6e                	add	s4,s4,s11
    800036e0:	0559f363          	bgeu	s3,s5,80003726 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800036e4:	00a4d59b          	srliw	a1,s1,0xa
    800036e8:	855a                	mv	a0,s6
    800036ea:	8bbff0ef          	jal	80002fa4 <bmap>
    800036ee:	85aa                	mv	a1,a0
    if(addr == 0)
    800036f0:	c139                	beqz	a0,80003736 <readi+0xce>
    bp = bread(ip->dev, addr);
    800036f2:	000b2503          	lw	a0,0(s6)
    800036f6:	d48ff0ef          	jal	80002c3e <bread>
    800036fa:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800036fc:	3ff4f793          	andi	a5,s1,1023
    80003700:	40fc873b          	subw	a4,s9,a5
    80003704:	413a86bb          	subw	a3,s5,s3
    80003708:	8d3a                	mv	s10,a4
    8000370a:	fae6f5e3          	bgeu	a3,a4,800036b4 <readi+0x4c>
    8000370e:	8d36                	mv	s10,a3
    80003710:	b755                	j	800036b4 <readi+0x4c>
      brelse(bp);
    80003712:	854a                	mv	a0,s2
    80003714:	e32ff0ef          	jal	80002d46 <brelse>
      tot = -1;
    80003718:	59fd                	li	s3,-1
      break;
    8000371a:	6946                	ld	s2,80(sp)
    8000371c:	7c02                	ld	s8,32(sp)
    8000371e:	6ce2                	ld	s9,24(sp)
    80003720:	6d42                	ld	s10,16(sp)
    80003722:	6da2                	ld	s11,8(sp)
    80003724:	a831                	j	80003740 <readi+0xd8>
    80003726:	6946                	ld	s2,80(sp)
    80003728:	7c02                	ld	s8,32(sp)
    8000372a:	6ce2                	ld	s9,24(sp)
    8000372c:	6d42                	ld	s10,16(sp)
    8000372e:	6da2                	ld	s11,8(sp)
    80003730:	a801                	j	80003740 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003732:	89d6                	mv	s3,s5
    80003734:	a031                	j	80003740 <readi+0xd8>
    80003736:	6946                	ld	s2,80(sp)
    80003738:	7c02                	ld	s8,32(sp)
    8000373a:	6ce2                	ld	s9,24(sp)
    8000373c:	6d42                	ld	s10,16(sp)
    8000373e:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003740:	854e                	mv	a0,s3
    80003742:	69a6                	ld	s3,72(sp)
}
    80003744:	70a6                	ld	ra,104(sp)
    80003746:	7406                	ld	s0,96(sp)
    80003748:	64e6                	ld	s1,88(sp)
    8000374a:	6a06                	ld	s4,64(sp)
    8000374c:	7ae2                	ld	s5,56(sp)
    8000374e:	7b42                	ld	s6,48(sp)
    80003750:	7ba2                	ld	s7,40(sp)
    80003752:	6165                	addi	sp,sp,112
    80003754:	8082                	ret
    return 0;
    80003756:	4501                	li	a0,0
}
    80003758:	8082                	ret

000000008000375a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000375a:	457c                	lw	a5,76(a0)
    8000375c:	0ed7eb63          	bltu	a5,a3,80003852 <writei+0xf8>
{
    80003760:	7159                	addi	sp,sp,-112
    80003762:	f486                	sd	ra,104(sp)
    80003764:	f0a2                	sd	s0,96(sp)
    80003766:	e8ca                	sd	s2,80(sp)
    80003768:	e0d2                	sd	s4,64(sp)
    8000376a:	fc56                	sd	s5,56(sp)
    8000376c:	f85a                	sd	s6,48(sp)
    8000376e:	f45e                	sd	s7,40(sp)
    80003770:	1880                	addi	s0,sp,112
    80003772:	8aaa                	mv	s5,a0
    80003774:	8bae                	mv	s7,a1
    80003776:	8a32                	mv	s4,a2
    80003778:	8936                	mv	s2,a3
    8000377a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000377c:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003780:	00043737          	lui	a4,0x43
    80003784:	0cf76963          	bltu	a4,a5,80003856 <writei+0xfc>
    80003788:	0cd7e763          	bltu	a5,a3,80003856 <writei+0xfc>
    8000378c:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000378e:	0a0b0a63          	beqz	s6,80003842 <writei+0xe8>
    80003792:	eca6                	sd	s1,88(sp)
    80003794:	f062                	sd	s8,32(sp)
    80003796:	ec66                	sd	s9,24(sp)
    80003798:	e86a                	sd	s10,16(sp)
    8000379a:	e46e                	sd	s11,8(sp)
    8000379c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000379e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800037a2:	5c7d                	li	s8,-1
    800037a4:	a825                	j	800037dc <writei+0x82>
    800037a6:	020d1d93          	slli	s11,s10,0x20
    800037aa:	020ddd93          	srli	s11,s11,0x20
    800037ae:	05848513          	addi	a0,s1,88
    800037b2:	86ee                	mv	a3,s11
    800037b4:	8652                	mv	a2,s4
    800037b6:	85de                	mv	a1,s7
    800037b8:	953e                	add	a0,a0,a5
    800037ba:	bebfe0ef          	jal	800023a4 <either_copyin>
    800037be:	05850663          	beq	a0,s8,8000380a <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    800037c2:	8526                	mv	a0,s1
    800037c4:	6b8000ef          	jal	80003e7c <log_write>
    brelse(bp);
    800037c8:	8526                	mv	a0,s1
    800037ca:	d7cff0ef          	jal	80002d46 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800037ce:	013d09bb          	addw	s3,s10,s3
    800037d2:	012d093b          	addw	s2,s10,s2
    800037d6:	9a6e                	add	s4,s4,s11
    800037d8:	0369fc63          	bgeu	s3,s6,80003810 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    800037dc:	00a9559b          	srliw	a1,s2,0xa
    800037e0:	8556                	mv	a0,s5
    800037e2:	fc2ff0ef          	jal	80002fa4 <bmap>
    800037e6:	85aa                	mv	a1,a0
    if(addr == 0)
    800037e8:	c505                	beqz	a0,80003810 <writei+0xb6>
    bp = bread(ip->dev, addr);
    800037ea:	000aa503          	lw	a0,0(s5)
    800037ee:	c50ff0ef          	jal	80002c3e <bread>
    800037f2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800037f4:	3ff97793          	andi	a5,s2,1023
    800037f8:	40fc873b          	subw	a4,s9,a5
    800037fc:	413b06bb          	subw	a3,s6,s3
    80003800:	8d3a                	mv	s10,a4
    80003802:	fae6f2e3          	bgeu	a3,a4,800037a6 <writei+0x4c>
    80003806:	8d36                	mv	s10,a3
    80003808:	bf79                	j	800037a6 <writei+0x4c>
      brelse(bp);
    8000380a:	8526                	mv	a0,s1
    8000380c:	d3aff0ef          	jal	80002d46 <brelse>
  }

  if(off > ip->size)
    80003810:	04caa783          	lw	a5,76(s5)
    80003814:	0327f963          	bgeu	a5,s2,80003846 <writei+0xec>
    ip->size = off;
    80003818:	052aa623          	sw	s2,76(s5)
    8000381c:	64e6                	ld	s1,88(sp)
    8000381e:	7c02                	ld	s8,32(sp)
    80003820:	6ce2                	ld	s9,24(sp)
    80003822:	6d42                	ld	s10,16(sp)
    80003824:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003826:	8556                	mv	a0,s5
    80003828:	9fbff0ef          	jal	80003222 <iupdate>

  return tot;
    8000382c:	854e                	mv	a0,s3
    8000382e:	69a6                	ld	s3,72(sp)
}
    80003830:	70a6                	ld	ra,104(sp)
    80003832:	7406                	ld	s0,96(sp)
    80003834:	6946                	ld	s2,80(sp)
    80003836:	6a06                	ld	s4,64(sp)
    80003838:	7ae2                	ld	s5,56(sp)
    8000383a:	7b42                	ld	s6,48(sp)
    8000383c:	7ba2                	ld	s7,40(sp)
    8000383e:	6165                	addi	sp,sp,112
    80003840:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003842:	89da                	mv	s3,s6
    80003844:	b7cd                	j	80003826 <writei+0xcc>
    80003846:	64e6                	ld	s1,88(sp)
    80003848:	7c02                	ld	s8,32(sp)
    8000384a:	6ce2                	ld	s9,24(sp)
    8000384c:	6d42                	ld	s10,16(sp)
    8000384e:	6da2                	ld	s11,8(sp)
    80003850:	bfd9                	j	80003826 <writei+0xcc>
    return -1;
    80003852:	557d                	li	a0,-1
}
    80003854:	8082                	ret
    return -1;
    80003856:	557d                	li	a0,-1
    80003858:	bfe1                	j	80003830 <writei+0xd6>

000000008000385a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000385a:	1141                	addi	sp,sp,-16
    8000385c:	e406                	sd	ra,8(sp)
    8000385e:	e022                	sd	s0,0(sp)
    80003860:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003862:	4639                	li	a2,14
    80003864:	d68fd0ef          	jal	80000dcc <strncmp>
}
    80003868:	60a2                	ld	ra,8(sp)
    8000386a:	6402                	ld	s0,0(sp)
    8000386c:	0141                	addi	sp,sp,16
    8000386e:	8082                	ret

0000000080003870 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003870:	711d                	addi	sp,sp,-96
    80003872:	ec86                	sd	ra,88(sp)
    80003874:	e8a2                	sd	s0,80(sp)
    80003876:	e4a6                	sd	s1,72(sp)
    80003878:	e0ca                	sd	s2,64(sp)
    8000387a:	fc4e                	sd	s3,56(sp)
    8000387c:	f852                	sd	s4,48(sp)
    8000387e:	f456                	sd	s5,40(sp)
    80003880:	f05a                	sd	s6,32(sp)
    80003882:	ec5e                	sd	s7,24(sp)
    80003884:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003886:	04451703          	lh	a4,68(a0)
    8000388a:	4785                	li	a5,1
    8000388c:	00f71f63          	bne	a4,a5,800038aa <dirlookup+0x3a>
    80003890:	892a                	mv	s2,a0
    80003892:	8aae                	mv	s5,a1
    80003894:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003896:	457c                	lw	a5,76(a0)
    80003898:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000389a:	fa040a13          	addi	s4,s0,-96
    8000389e:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    800038a0:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800038a4:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038a6:	e39d                	bnez	a5,800038cc <dirlookup+0x5c>
    800038a8:	a8b9                	j	80003906 <dirlookup+0x96>
    panic("dirlookup not DIR");
    800038aa:	00004517          	auipc	a0,0x4
    800038ae:	bf650513          	addi	a0,a0,-1034 # 800074a0 <etext+0x4a0>
    800038b2:	f73fc0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    800038b6:	00004517          	auipc	a0,0x4
    800038ba:	c0250513          	addi	a0,a0,-1022 # 800074b8 <etext+0x4b8>
    800038be:	f67fc0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038c2:	24c1                	addiw	s1,s1,16
    800038c4:	04c92783          	lw	a5,76(s2)
    800038c8:	02f4fe63          	bgeu	s1,a5,80003904 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038cc:	874e                	mv	a4,s3
    800038ce:	86a6                	mv	a3,s1
    800038d0:	8652                	mv	a2,s4
    800038d2:	4581                	li	a1,0
    800038d4:	854a                	mv	a0,s2
    800038d6:	d93ff0ef          	jal	80003668 <readi>
    800038da:	fd351ee3          	bne	a0,s3,800038b6 <dirlookup+0x46>
    if(de.inum == 0)
    800038de:	fa045783          	lhu	a5,-96(s0)
    800038e2:	d3e5                	beqz	a5,800038c2 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    800038e4:	85da                	mv	a1,s6
    800038e6:	8556                	mv	a0,s5
    800038e8:	f73ff0ef          	jal	8000385a <namecmp>
    800038ec:	f979                	bnez	a0,800038c2 <dirlookup+0x52>
      if(poff)
    800038ee:	000b8463          	beqz	s7,800038f6 <dirlookup+0x86>
        *poff = off;
    800038f2:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800038f6:	fa045583          	lhu	a1,-96(s0)
    800038fa:	00092503          	lw	a0,0(s2)
    800038fe:	f66ff0ef          	jal	80003064 <iget>
    80003902:	a011                	j	80003906 <dirlookup+0x96>
  return 0;
    80003904:	4501                	li	a0,0
}
    80003906:	60e6                	ld	ra,88(sp)
    80003908:	6446                	ld	s0,80(sp)
    8000390a:	64a6                	ld	s1,72(sp)
    8000390c:	6906                	ld	s2,64(sp)
    8000390e:	79e2                	ld	s3,56(sp)
    80003910:	7a42                	ld	s4,48(sp)
    80003912:	7aa2                	ld	s5,40(sp)
    80003914:	7b02                	ld	s6,32(sp)
    80003916:	6be2                	ld	s7,24(sp)
    80003918:	6125                	addi	sp,sp,96
    8000391a:	8082                	ret

000000008000391c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000391c:	711d                	addi	sp,sp,-96
    8000391e:	ec86                	sd	ra,88(sp)
    80003920:	e8a2                	sd	s0,80(sp)
    80003922:	e4a6                	sd	s1,72(sp)
    80003924:	e0ca                	sd	s2,64(sp)
    80003926:	fc4e                	sd	s3,56(sp)
    80003928:	f852                	sd	s4,48(sp)
    8000392a:	f456                	sd	s5,40(sp)
    8000392c:	f05a                	sd	s6,32(sp)
    8000392e:	ec5e                	sd	s7,24(sp)
    80003930:	e862                	sd	s8,16(sp)
    80003932:	e466                	sd	s9,8(sp)
    80003934:	e06a                	sd	s10,0(sp)
    80003936:	1080                	addi	s0,sp,96
    80003938:	84aa                	mv	s1,a0
    8000393a:	8b2e                	mv	s6,a1
    8000393c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000393e:	00054703          	lbu	a4,0(a0)
    80003942:	02f00793          	li	a5,47
    80003946:	00f70f63          	beq	a4,a5,80003964 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000394a:	fe5fd0ef          	jal	8000192e <myproc>
    8000394e:	15853503          	ld	a0,344(a0)
    80003952:	94fff0ef          	jal	800032a0 <idup>
    80003956:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003958:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    8000395c:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    8000395e:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003960:	4b85                	li	s7,1
    80003962:	a879                	j	80003a00 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003964:	4585                	li	a1,1
    80003966:	852e                	mv	a0,a1
    80003968:	efcff0ef          	jal	80003064 <iget>
    8000396c:	8a2a                	mv	s4,a0
    8000396e:	b7ed                	j	80003958 <namex+0x3c>
      iunlockput(ip);
    80003970:	8552                	mv	a0,s4
    80003972:	b71ff0ef          	jal	800034e2 <iunlockput>
      return 0;
    80003976:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003978:	8552                	mv	a0,s4
    8000397a:	60e6                	ld	ra,88(sp)
    8000397c:	6446                	ld	s0,80(sp)
    8000397e:	64a6                	ld	s1,72(sp)
    80003980:	6906                	ld	s2,64(sp)
    80003982:	79e2                	ld	s3,56(sp)
    80003984:	7a42                	ld	s4,48(sp)
    80003986:	7aa2                	ld	s5,40(sp)
    80003988:	7b02                	ld	s6,32(sp)
    8000398a:	6be2                	ld	s7,24(sp)
    8000398c:	6c42                	ld	s8,16(sp)
    8000398e:	6ca2                	ld	s9,8(sp)
    80003990:	6d02                	ld	s10,0(sp)
    80003992:	6125                	addi	sp,sp,96
    80003994:	8082                	ret
      iunlock(ip);
    80003996:	8552                	mv	a0,s4
    80003998:	9edff0ef          	jal	80003384 <iunlock>
      return ip;
    8000399c:	bff1                	j	80003978 <namex+0x5c>
      iunlockput(ip);
    8000399e:	8552                	mv	a0,s4
    800039a0:	b43ff0ef          	jal	800034e2 <iunlockput>
      return 0;
    800039a4:	8a4a                	mv	s4,s2
    800039a6:	bfc9                	j	80003978 <namex+0x5c>
  len = path - s;
    800039a8:	40990633          	sub	a2,s2,s1
    800039ac:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800039b0:	09ac5463          	bge	s8,s10,80003a38 <namex+0x11c>
    memmove(name, s, DIRSIZ);
    800039b4:	8666                	mv	a2,s9
    800039b6:	85a6                	mv	a1,s1
    800039b8:	8556                	mv	a0,s5
    800039ba:	b9efd0ef          	jal	80000d58 <memmove>
    800039be:	84ca                	mv	s1,s2
  while(*path == '/')
    800039c0:	0004c783          	lbu	a5,0(s1)
    800039c4:	01379763          	bne	a5,s3,800039d2 <namex+0xb6>
    path++;
    800039c8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800039ca:	0004c783          	lbu	a5,0(s1)
    800039ce:	ff378de3          	beq	a5,s3,800039c8 <namex+0xac>
    ilock(ip);
    800039d2:	8552                	mv	a0,s4
    800039d4:	903ff0ef          	jal	800032d6 <ilock>
    if(ip->type != T_DIR){
    800039d8:	044a1783          	lh	a5,68(s4)
    800039dc:	f9779ae3          	bne	a5,s7,80003970 <namex+0x54>
    if(nameiparent && *path == '\0'){
    800039e0:	000b0563          	beqz	s6,800039ea <namex+0xce>
    800039e4:	0004c783          	lbu	a5,0(s1)
    800039e8:	d7dd                	beqz	a5,80003996 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800039ea:	4601                	li	a2,0
    800039ec:	85d6                	mv	a1,s5
    800039ee:	8552                	mv	a0,s4
    800039f0:	e81ff0ef          	jal	80003870 <dirlookup>
    800039f4:	892a                	mv	s2,a0
    800039f6:	d545                	beqz	a0,8000399e <namex+0x82>
    iunlockput(ip);
    800039f8:	8552                	mv	a0,s4
    800039fa:	ae9ff0ef          	jal	800034e2 <iunlockput>
    ip = next;
    800039fe:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003a00:	0004c783          	lbu	a5,0(s1)
    80003a04:	01379763          	bne	a5,s3,80003a12 <namex+0xf6>
    path++;
    80003a08:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a0a:	0004c783          	lbu	a5,0(s1)
    80003a0e:	ff378de3          	beq	a5,s3,80003a08 <namex+0xec>
  if(*path == 0)
    80003a12:	cf8d                	beqz	a5,80003a4c <namex+0x130>
  while(*path != '/' && *path != 0)
    80003a14:	0004c783          	lbu	a5,0(s1)
    80003a18:	fd178713          	addi	a4,a5,-47
    80003a1c:	cb19                	beqz	a4,80003a32 <namex+0x116>
    80003a1e:	cb91                	beqz	a5,80003a32 <namex+0x116>
    80003a20:	8926                	mv	s2,s1
    path++;
    80003a22:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003a24:	00094783          	lbu	a5,0(s2)
    80003a28:	fd178713          	addi	a4,a5,-47
    80003a2c:	df35                	beqz	a4,800039a8 <namex+0x8c>
    80003a2e:	fbf5                	bnez	a5,80003a22 <namex+0x106>
    80003a30:	bfa5                	j	800039a8 <namex+0x8c>
    80003a32:	8926                	mv	s2,s1
  len = path - s;
    80003a34:	4d01                	li	s10,0
    80003a36:	4601                	li	a2,0
    memmove(name, s, len);
    80003a38:	2601                	sext.w	a2,a2
    80003a3a:	85a6                	mv	a1,s1
    80003a3c:	8556                	mv	a0,s5
    80003a3e:	b1afd0ef          	jal	80000d58 <memmove>
    name[len] = 0;
    80003a42:	9d56                	add	s10,s10,s5
    80003a44:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdb8b8>
    80003a48:	84ca                	mv	s1,s2
    80003a4a:	bf9d                	j	800039c0 <namex+0xa4>
  if(nameiparent){
    80003a4c:	f20b06e3          	beqz	s6,80003978 <namex+0x5c>
    iput(ip);
    80003a50:	8552                	mv	a0,s4
    80003a52:	a07ff0ef          	jal	80003458 <iput>
    return 0;
    80003a56:	4a01                	li	s4,0
    80003a58:	b705                	j	80003978 <namex+0x5c>

0000000080003a5a <dirlink>:
{
    80003a5a:	715d                	addi	sp,sp,-80
    80003a5c:	e486                	sd	ra,72(sp)
    80003a5e:	e0a2                	sd	s0,64(sp)
    80003a60:	f84a                	sd	s2,48(sp)
    80003a62:	ec56                	sd	s5,24(sp)
    80003a64:	e85a                	sd	s6,16(sp)
    80003a66:	0880                	addi	s0,sp,80
    80003a68:	892a                	mv	s2,a0
    80003a6a:	8aae                	mv	s5,a1
    80003a6c:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003a6e:	4601                	li	a2,0
    80003a70:	e01ff0ef          	jal	80003870 <dirlookup>
    80003a74:	ed1d                	bnez	a0,80003ab2 <dirlink+0x58>
    80003a76:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a78:	04c92483          	lw	s1,76(s2)
    80003a7c:	c4b9                	beqz	s1,80003aca <dirlink+0x70>
    80003a7e:	f44e                	sd	s3,40(sp)
    80003a80:	f052                	sd	s4,32(sp)
    80003a82:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a84:	fb040a13          	addi	s4,s0,-80
    80003a88:	49c1                	li	s3,16
    80003a8a:	874e                	mv	a4,s3
    80003a8c:	86a6                	mv	a3,s1
    80003a8e:	8652                	mv	a2,s4
    80003a90:	4581                	li	a1,0
    80003a92:	854a                	mv	a0,s2
    80003a94:	bd5ff0ef          	jal	80003668 <readi>
    80003a98:	03351163          	bne	a0,s3,80003aba <dirlink+0x60>
    if(de.inum == 0)
    80003a9c:	fb045783          	lhu	a5,-80(s0)
    80003aa0:	c39d                	beqz	a5,80003ac6 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003aa2:	24c1                	addiw	s1,s1,16
    80003aa4:	04c92783          	lw	a5,76(s2)
    80003aa8:	fef4e1e3          	bltu	s1,a5,80003a8a <dirlink+0x30>
    80003aac:	79a2                	ld	s3,40(sp)
    80003aae:	7a02                	ld	s4,32(sp)
    80003ab0:	a829                	j	80003aca <dirlink+0x70>
    iput(ip);
    80003ab2:	9a7ff0ef          	jal	80003458 <iput>
    return -1;
    80003ab6:	557d                	li	a0,-1
    80003ab8:	a83d                	j	80003af6 <dirlink+0x9c>
      panic("dirlink read");
    80003aba:	00004517          	auipc	a0,0x4
    80003abe:	a0e50513          	addi	a0,a0,-1522 # 800074c8 <etext+0x4c8>
    80003ac2:	d63fc0ef          	jal	80000824 <panic>
    80003ac6:	79a2                	ld	s3,40(sp)
    80003ac8:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003aca:	4639                	li	a2,14
    80003acc:	85d6                	mv	a1,s5
    80003ace:	fb240513          	addi	a0,s0,-78
    80003ad2:	b34fd0ef          	jal	80000e06 <strncpy>
  de.inum = inum;
    80003ad6:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ada:	4741                	li	a4,16
    80003adc:	86a6                	mv	a3,s1
    80003ade:	fb040613          	addi	a2,s0,-80
    80003ae2:	4581                	li	a1,0
    80003ae4:	854a                	mv	a0,s2
    80003ae6:	c75ff0ef          	jal	8000375a <writei>
    80003aea:	1541                	addi	a0,a0,-16
    80003aec:	00a03533          	snez	a0,a0
    80003af0:	40a0053b          	negw	a0,a0
    80003af4:	74e2                	ld	s1,56(sp)
}
    80003af6:	60a6                	ld	ra,72(sp)
    80003af8:	6406                	ld	s0,64(sp)
    80003afa:	7942                	ld	s2,48(sp)
    80003afc:	6ae2                	ld	s5,24(sp)
    80003afe:	6b42                	ld	s6,16(sp)
    80003b00:	6161                	addi	sp,sp,80
    80003b02:	8082                	ret

0000000080003b04 <namei>:

struct inode*
namei(char *path)
{
    80003b04:	1101                	addi	sp,sp,-32
    80003b06:	ec06                	sd	ra,24(sp)
    80003b08:	e822                	sd	s0,16(sp)
    80003b0a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003b0c:	fe040613          	addi	a2,s0,-32
    80003b10:	4581                	li	a1,0
    80003b12:	e0bff0ef          	jal	8000391c <namex>
}
    80003b16:	60e2                	ld	ra,24(sp)
    80003b18:	6442                	ld	s0,16(sp)
    80003b1a:	6105                	addi	sp,sp,32
    80003b1c:	8082                	ret

0000000080003b1e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003b1e:	1141                	addi	sp,sp,-16
    80003b20:	e406                	sd	ra,8(sp)
    80003b22:	e022                	sd	s0,0(sp)
    80003b24:	0800                	addi	s0,sp,16
    80003b26:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003b28:	4585                	li	a1,1
    80003b2a:	df3ff0ef          	jal	8000391c <namex>
}
    80003b2e:	60a2                	ld	ra,8(sp)
    80003b30:	6402                	ld	s0,0(sp)
    80003b32:	0141                	addi	sp,sp,16
    80003b34:	8082                	ret

0000000080003b36 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003b36:	1101                	addi	sp,sp,-32
    80003b38:	ec06                	sd	ra,24(sp)
    80003b3a:	e822                	sd	s0,16(sp)
    80003b3c:	e426                	sd	s1,8(sp)
    80003b3e:	e04a                	sd	s2,0(sp)
    80003b40:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003b42:	0001f917          	auipc	s2,0x1f
    80003b46:	9c690913          	addi	s2,s2,-1594 # 80022508 <log>
    80003b4a:	01892583          	lw	a1,24(s2)
    80003b4e:	02492503          	lw	a0,36(s2)
    80003b52:	8ecff0ef          	jal	80002c3e <bread>
    80003b56:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003b58:	02892603          	lw	a2,40(s2)
    80003b5c:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b5e:	00c05f63          	blez	a2,80003b7c <write_head+0x46>
    80003b62:	0001f717          	auipc	a4,0x1f
    80003b66:	9d270713          	addi	a4,a4,-1582 # 80022534 <log+0x2c>
    80003b6a:	87aa                	mv	a5,a0
    80003b6c:	060a                	slli	a2,a2,0x2
    80003b6e:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003b70:	4314                	lw	a3,0(a4)
    80003b72:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003b74:	0711                	addi	a4,a4,4
    80003b76:	0791                	addi	a5,a5,4
    80003b78:	fec79ce3          	bne	a5,a2,80003b70 <write_head+0x3a>
  }
  bwrite(buf);
    80003b7c:	8526                	mv	a0,s1
    80003b7e:	996ff0ef          	jal	80002d14 <bwrite>
  brelse(buf);
    80003b82:	8526                	mv	a0,s1
    80003b84:	9c2ff0ef          	jal	80002d46 <brelse>
}
    80003b88:	60e2                	ld	ra,24(sp)
    80003b8a:	6442                	ld	s0,16(sp)
    80003b8c:	64a2                	ld	s1,8(sp)
    80003b8e:	6902                	ld	s2,0(sp)
    80003b90:	6105                	addi	sp,sp,32
    80003b92:	8082                	ret

0000000080003b94 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b94:	0001f797          	auipc	a5,0x1f
    80003b98:	99c7a783          	lw	a5,-1636(a5) # 80022530 <log+0x28>
    80003b9c:	0cf05163          	blez	a5,80003c5e <install_trans+0xca>
{
    80003ba0:	715d                	addi	sp,sp,-80
    80003ba2:	e486                	sd	ra,72(sp)
    80003ba4:	e0a2                	sd	s0,64(sp)
    80003ba6:	fc26                	sd	s1,56(sp)
    80003ba8:	f84a                	sd	s2,48(sp)
    80003baa:	f44e                	sd	s3,40(sp)
    80003bac:	f052                	sd	s4,32(sp)
    80003bae:	ec56                	sd	s5,24(sp)
    80003bb0:	e85a                	sd	s6,16(sp)
    80003bb2:	e45e                	sd	s7,8(sp)
    80003bb4:	e062                	sd	s8,0(sp)
    80003bb6:	0880                	addi	s0,sp,80
    80003bb8:	8b2a                	mv	s6,a0
    80003bba:	0001fa97          	auipc	s5,0x1f
    80003bbe:	97aa8a93          	addi	s5,s5,-1670 # 80022534 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bc2:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003bc4:	00004c17          	auipc	s8,0x4
    80003bc8:	914c0c13          	addi	s8,s8,-1772 # 800074d8 <etext+0x4d8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003bcc:	0001fa17          	auipc	s4,0x1f
    80003bd0:	93ca0a13          	addi	s4,s4,-1732 # 80022508 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003bd4:	40000b93          	li	s7,1024
    80003bd8:	a025                	j	80003c00 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003bda:	000aa603          	lw	a2,0(s5)
    80003bde:	85ce                	mv	a1,s3
    80003be0:	8562                	mv	a0,s8
    80003be2:	919fc0ef          	jal	800004fa <printf>
    80003be6:	a839                	j	80003c04 <install_trans+0x70>
    brelse(lbuf);
    80003be8:	854a                	mv	a0,s2
    80003bea:	95cff0ef          	jal	80002d46 <brelse>
    brelse(dbuf);
    80003bee:	8526                	mv	a0,s1
    80003bf0:	956ff0ef          	jal	80002d46 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bf4:	2985                	addiw	s3,s3,1
    80003bf6:	0a91                	addi	s5,s5,4
    80003bf8:	028a2783          	lw	a5,40(s4)
    80003bfc:	04f9d563          	bge	s3,a5,80003c46 <install_trans+0xb2>
    if(recovering) {
    80003c00:	fc0b1de3          	bnez	s6,80003bda <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c04:	018a2583          	lw	a1,24(s4)
    80003c08:	013585bb          	addw	a1,a1,s3
    80003c0c:	2585                	addiw	a1,a1,1
    80003c0e:	024a2503          	lw	a0,36(s4)
    80003c12:	82cff0ef          	jal	80002c3e <bread>
    80003c16:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003c18:	000aa583          	lw	a1,0(s5)
    80003c1c:	024a2503          	lw	a0,36(s4)
    80003c20:	81eff0ef          	jal	80002c3e <bread>
    80003c24:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003c26:	865e                	mv	a2,s7
    80003c28:	05890593          	addi	a1,s2,88
    80003c2c:	05850513          	addi	a0,a0,88
    80003c30:	928fd0ef          	jal	80000d58 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003c34:	8526                	mv	a0,s1
    80003c36:	8deff0ef          	jal	80002d14 <bwrite>
    if(recovering == 0)
    80003c3a:	fa0b17e3          	bnez	s6,80003be8 <install_trans+0x54>
      bunpin(dbuf);
    80003c3e:	8526                	mv	a0,s1
    80003c40:	9beff0ef          	jal	80002dfe <bunpin>
    80003c44:	b755                	j	80003be8 <install_trans+0x54>
}
    80003c46:	60a6                	ld	ra,72(sp)
    80003c48:	6406                	ld	s0,64(sp)
    80003c4a:	74e2                	ld	s1,56(sp)
    80003c4c:	7942                	ld	s2,48(sp)
    80003c4e:	79a2                	ld	s3,40(sp)
    80003c50:	7a02                	ld	s4,32(sp)
    80003c52:	6ae2                	ld	s5,24(sp)
    80003c54:	6b42                	ld	s6,16(sp)
    80003c56:	6ba2                	ld	s7,8(sp)
    80003c58:	6c02                	ld	s8,0(sp)
    80003c5a:	6161                	addi	sp,sp,80
    80003c5c:	8082                	ret
    80003c5e:	8082                	ret

0000000080003c60 <initlog>:
{
    80003c60:	7179                	addi	sp,sp,-48
    80003c62:	f406                	sd	ra,40(sp)
    80003c64:	f022                	sd	s0,32(sp)
    80003c66:	ec26                	sd	s1,24(sp)
    80003c68:	e84a                	sd	s2,16(sp)
    80003c6a:	e44e                	sd	s3,8(sp)
    80003c6c:	1800                	addi	s0,sp,48
    80003c6e:	84aa                	mv	s1,a0
    80003c70:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003c72:	0001f917          	auipc	s2,0x1f
    80003c76:	89690913          	addi	s2,s2,-1898 # 80022508 <log>
    80003c7a:	00004597          	auipc	a1,0x4
    80003c7e:	87e58593          	addi	a1,a1,-1922 # 800074f8 <etext+0x4f8>
    80003c82:	854a                	mv	a0,s2
    80003c84:	f1bfc0ef          	jal	80000b9e <initlock>
  log.start = sb->logstart;
    80003c88:	0149a583          	lw	a1,20(s3)
    80003c8c:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003c90:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003c94:	8526                	mv	a0,s1
    80003c96:	fa9fe0ef          	jal	80002c3e <bread>
  log.lh.n = lh->n;
    80003c9a:	4d30                	lw	a2,88(a0)
    80003c9c:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003ca0:	00c05f63          	blez	a2,80003cbe <initlog+0x5e>
    80003ca4:	87aa                	mv	a5,a0
    80003ca6:	0001f717          	auipc	a4,0x1f
    80003caa:	88e70713          	addi	a4,a4,-1906 # 80022534 <log+0x2c>
    80003cae:	060a                	slli	a2,a2,0x2
    80003cb0:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003cb2:	4ff4                	lw	a3,92(a5)
    80003cb4:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003cb6:	0791                	addi	a5,a5,4
    80003cb8:	0711                	addi	a4,a4,4
    80003cba:	fec79ce3          	bne	a5,a2,80003cb2 <initlog+0x52>
  brelse(buf);
    80003cbe:	888ff0ef          	jal	80002d46 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003cc2:	4505                	li	a0,1
    80003cc4:	ed1ff0ef          	jal	80003b94 <install_trans>
  log.lh.n = 0;
    80003cc8:	0001f797          	auipc	a5,0x1f
    80003ccc:	8607a423          	sw	zero,-1944(a5) # 80022530 <log+0x28>
  write_head(); // clear the log
    80003cd0:	e67ff0ef          	jal	80003b36 <write_head>
}
    80003cd4:	70a2                	ld	ra,40(sp)
    80003cd6:	7402                	ld	s0,32(sp)
    80003cd8:	64e2                	ld	s1,24(sp)
    80003cda:	6942                	ld	s2,16(sp)
    80003cdc:	69a2                	ld	s3,8(sp)
    80003cde:	6145                	addi	sp,sp,48
    80003ce0:	8082                	ret

0000000080003ce2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ce2:	1101                	addi	sp,sp,-32
    80003ce4:	ec06                	sd	ra,24(sp)
    80003ce6:	e822                	sd	s0,16(sp)
    80003ce8:	e426                	sd	s1,8(sp)
    80003cea:	e04a                	sd	s2,0(sp)
    80003cec:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003cee:	0001f517          	auipc	a0,0x1f
    80003cf2:	81a50513          	addi	a0,a0,-2022 # 80022508 <log>
    80003cf6:	f33fc0ef          	jal	80000c28 <acquire>
  while(1){
    if(log.committing){
    80003cfa:	0001f497          	auipc	s1,0x1f
    80003cfe:	80e48493          	addi	s1,s1,-2034 # 80022508 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003d02:	4979                	li	s2,30
    80003d04:	a029                	j	80003d0e <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003d06:	85a6                	mv	a1,s1
    80003d08:	8526                	mv	a0,s1
    80003d0a:	af6fe0ef          	jal	80002000 <sleep>
    if(log.committing){
    80003d0e:	509c                	lw	a5,32(s1)
    80003d10:	fbfd                	bnez	a5,80003d06 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003d12:	4cd8                	lw	a4,28(s1)
    80003d14:	2705                	addiw	a4,a4,1
    80003d16:	0027179b          	slliw	a5,a4,0x2
    80003d1a:	9fb9                	addw	a5,a5,a4
    80003d1c:	0017979b          	slliw	a5,a5,0x1
    80003d20:	5494                	lw	a3,40(s1)
    80003d22:	9fb5                	addw	a5,a5,a3
    80003d24:	00f95763          	bge	s2,a5,80003d32 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003d28:	85a6                	mv	a1,s1
    80003d2a:	8526                	mv	a0,s1
    80003d2c:	ad4fe0ef          	jal	80002000 <sleep>
    80003d30:	bff9                	j	80003d0e <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003d32:	0001e797          	auipc	a5,0x1e
    80003d36:	7ee7a923          	sw	a4,2034(a5) # 80022524 <log+0x1c>
      release(&log.lock);
    80003d3a:	0001e517          	auipc	a0,0x1e
    80003d3e:	7ce50513          	addi	a0,a0,1998 # 80022508 <log>
    80003d42:	f7bfc0ef          	jal	80000cbc <release>
      break;
    }
  }
}
    80003d46:	60e2                	ld	ra,24(sp)
    80003d48:	6442                	ld	s0,16(sp)
    80003d4a:	64a2                	ld	s1,8(sp)
    80003d4c:	6902                	ld	s2,0(sp)
    80003d4e:	6105                	addi	sp,sp,32
    80003d50:	8082                	ret

0000000080003d52 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003d52:	7139                	addi	sp,sp,-64
    80003d54:	fc06                	sd	ra,56(sp)
    80003d56:	f822                	sd	s0,48(sp)
    80003d58:	f426                	sd	s1,40(sp)
    80003d5a:	f04a                	sd	s2,32(sp)
    80003d5c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003d5e:	0001e497          	auipc	s1,0x1e
    80003d62:	7aa48493          	addi	s1,s1,1962 # 80022508 <log>
    80003d66:	8526                	mv	a0,s1
    80003d68:	ec1fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003d6c:	4cdc                	lw	a5,28(s1)
    80003d6e:	37fd                	addiw	a5,a5,-1
    80003d70:	893e                	mv	s2,a5
    80003d72:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003d74:	509c                	lw	a5,32(s1)
    80003d76:	e7b1                	bnez	a5,80003dc2 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    80003d78:	04091e63          	bnez	s2,80003dd4 <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    80003d7c:	0001e497          	auipc	s1,0x1e
    80003d80:	78c48493          	addi	s1,s1,1932 # 80022508 <log>
    80003d84:	4785                	li	a5,1
    80003d86:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003d88:	8526                	mv	a0,s1
    80003d8a:	f33fc0ef          	jal	80000cbc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003d8e:	549c                	lw	a5,40(s1)
    80003d90:	06f04463          	bgtz	a5,80003df8 <end_op+0xa6>
    acquire(&log.lock);
    80003d94:	0001e517          	auipc	a0,0x1e
    80003d98:	77450513          	addi	a0,a0,1908 # 80022508 <log>
    80003d9c:	e8dfc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003da0:	0001e797          	auipc	a5,0x1e
    80003da4:	7807a423          	sw	zero,1928(a5) # 80022528 <log+0x20>
    wakeup(&log);
    80003da8:	0001e517          	auipc	a0,0x1e
    80003dac:	76050513          	addi	a0,a0,1888 # 80022508 <log>
    80003db0:	a9cfe0ef          	jal	8000204c <wakeup>
    release(&log.lock);
    80003db4:	0001e517          	auipc	a0,0x1e
    80003db8:	75450513          	addi	a0,a0,1876 # 80022508 <log>
    80003dbc:	f01fc0ef          	jal	80000cbc <release>
}
    80003dc0:	a035                	j	80003dec <end_op+0x9a>
    80003dc2:	ec4e                	sd	s3,24(sp)
    80003dc4:	e852                	sd	s4,16(sp)
    80003dc6:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003dc8:	00003517          	auipc	a0,0x3
    80003dcc:	73850513          	addi	a0,a0,1848 # 80007500 <etext+0x500>
    80003dd0:	a55fc0ef          	jal	80000824 <panic>
    wakeup(&log);
    80003dd4:	0001e517          	auipc	a0,0x1e
    80003dd8:	73450513          	addi	a0,a0,1844 # 80022508 <log>
    80003ddc:	a70fe0ef          	jal	8000204c <wakeup>
  release(&log.lock);
    80003de0:	0001e517          	auipc	a0,0x1e
    80003de4:	72850513          	addi	a0,a0,1832 # 80022508 <log>
    80003de8:	ed5fc0ef          	jal	80000cbc <release>
}
    80003dec:	70e2                	ld	ra,56(sp)
    80003dee:	7442                	ld	s0,48(sp)
    80003df0:	74a2                	ld	s1,40(sp)
    80003df2:	7902                	ld	s2,32(sp)
    80003df4:	6121                	addi	sp,sp,64
    80003df6:	8082                	ret
    80003df8:	ec4e                	sd	s3,24(sp)
    80003dfa:	e852                	sd	s4,16(sp)
    80003dfc:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003dfe:	0001ea97          	auipc	s5,0x1e
    80003e02:	736a8a93          	addi	s5,s5,1846 # 80022534 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003e06:	0001ea17          	auipc	s4,0x1e
    80003e0a:	702a0a13          	addi	s4,s4,1794 # 80022508 <log>
    80003e0e:	018a2583          	lw	a1,24(s4)
    80003e12:	012585bb          	addw	a1,a1,s2
    80003e16:	2585                	addiw	a1,a1,1
    80003e18:	024a2503          	lw	a0,36(s4)
    80003e1c:	e23fe0ef          	jal	80002c3e <bread>
    80003e20:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003e22:	000aa583          	lw	a1,0(s5)
    80003e26:	024a2503          	lw	a0,36(s4)
    80003e2a:	e15fe0ef          	jal	80002c3e <bread>
    80003e2e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003e30:	40000613          	li	a2,1024
    80003e34:	05850593          	addi	a1,a0,88
    80003e38:	05848513          	addi	a0,s1,88
    80003e3c:	f1dfc0ef          	jal	80000d58 <memmove>
    bwrite(to);  // write the log
    80003e40:	8526                	mv	a0,s1
    80003e42:	ed3fe0ef          	jal	80002d14 <bwrite>
    brelse(from);
    80003e46:	854e                	mv	a0,s3
    80003e48:	efffe0ef          	jal	80002d46 <brelse>
    brelse(to);
    80003e4c:	8526                	mv	a0,s1
    80003e4e:	ef9fe0ef          	jal	80002d46 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e52:	2905                	addiw	s2,s2,1
    80003e54:	0a91                	addi	s5,s5,4
    80003e56:	028a2783          	lw	a5,40(s4)
    80003e5a:	faf94ae3          	blt	s2,a5,80003e0e <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003e5e:	cd9ff0ef          	jal	80003b36 <write_head>
    install_trans(0); // Now install writes to home locations
    80003e62:	4501                	li	a0,0
    80003e64:	d31ff0ef          	jal	80003b94 <install_trans>
    log.lh.n = 0;
    80003e68:	0001e797          	auipc	a5,0x1e
    80003e6c:	6c07a423          	sw	zero,1736(a5) # 80022530 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003e70:	cc7ff0ef          	jal	80003b36 <write_head>
    80003e74:	69e2                	ld	s3,24(sp)
    80003e76:	6a42                	ld	s4,16(sp)
    80003e78:	6aa2                	ld	s5,8(sp)
    80003e7a:	bf29                	j	80003d94 <end_op+0x42>

0000000080003e7c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003e7c:	1101                	addi	sp,sp,-32
    80003e7e:	ec06                	sd	ra,24(sp)
    80003e80:	e822                	sd	s0,16(sp)
    80003e82:	e426                	sd	s1,8(sp)
    80003e84:	1000                	addi	s0,sp,32
    80003e86:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003e88:	0001e517          	auipc	a0,0x1e
    80003e8c:	68050513          	addi	a0,a0,1664 # 80022508 <log>
    80003e90:	d99fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003e94:	0001e617          	auipc	a2,0x1e
    80003e98:	69c62603          	lw	a2,1692(a2) # 80022530 <log+0x28>
    80003e9c:	47f5                	li	a5,29
    80003e9e:	04c7cd63          	blt	a5,a2,80003ef8 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003ea2:	0001e797          	auipc	a5,0x1e
    80003ea6:	6827a783          	lw	a5,1666(a5) # 80022524 <log+0x1c>
    80003eaa:	04f05d63          	blez	a5,80003f04 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003eae:	4781                	li	a5,0
    80003eb0:	06c05063          	blez	a2,80003f10 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003eb4:	44cc                	lw	a1,12(s1)
    80003eb6:	0001e717          	auipc	a4,0x1e
    80003eba:	67e70713          	addi	a4,a4,1662 # 80022534 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003ebe:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003ec0:	4314                	lw	a3,0(a4)
    80003ec2:	04b68763          	beq	a3,a1,80003f10 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003ec6:	2785                	addiw	a5,a5,1
    80003ec8:	0711                	addi	a4,a4,4
    80003eca:	fef61be3          	bne	a2,a5,80003ec0 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003ece:	060a                	slli	a2,a2,0x2
    80003ed0:	02060613          	addi	a2,a2,32
    80003ed4:	0001e797          	auipc	a5,0x1e
    80003ed8:	63478793          	addi	a5,a5,1588 # 80022508 <log>
    80003edc:	97b2                	add	a5,a5,a2
    80003ede:	44d8                	lw	a4,12(s1)
    80003ee0:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003ee2:	8526                	mv	a0,s1
    80003ee4:	ee7fe0ef          	jal	80002dca <bpin>
    log.lh.n++;
    80003ee8:	0001e717          	auipc	a4,0x1e
    80003eec:	62070713          	addi	a4,a4,1568 # 80022508 <log>
    80003ef0:	571c                	lw	a5,40(a4)
    80003ef2:	2785                	addiw	a5,a5,1
    80003ef4:	d71c                	sw	a5,40(a4)
    80003ef6:	a815                	j	80003f2a <log_write+0xae>
    panic("too big a transaction");
    80003ef8:	00003517          	auipc	a0,0x3
    80003efc:	61850513          	addi	a0,a0,1560 # 80007510 <etext+0x510>
    80003f00:	925fc0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    80003f04:	00003517          	auipc	a0,0x3
    80003f08:	62450513          	addi	a0,a0,1572 # 80007528 <etext+0x528>
    80003f0c:	919fc0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    80003f10:	00279693          	slli	a3,a5,0x2
    80003f14:	02068693          	addi	a3,a3,32
    80003f18:	0001e717          	auipc	a4,0x1e
    80003f1c:	5f070713          	addi	a4,a4,1520 # 80022508 <log>
    80003f20:	9736                	add	a4,a4,a3
    80003f22:	44d4                	lw	a3,12(s1)
    80003f24:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003f26:	faf60ee3          	beq	a2,a5,80003ee2 <log_write+0x66>
  }
  release(&log.lock);
    80003f2a:	0001e517          	auipc	a0,0x1e
    80003f2e:	5de50513          	addi	a0,a0,1502 # 80022508 <log>
    80003f32:	d8bfc0ef          	jal	80000cbc <release>
}
    80003f36:	60e2                	ld	ra,24(sp)
    80003f38:	6442                	ld	s0,16(sp)
    80003f3a:	64a2                	ld	s1,8(sp)
    80003f3c:	6105                	addi	sp,sp,32
    80003f3e:	8082                	ret

0000000080003f40 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003f40:	1101                	addi	sp,sp,-32
    80003f42:	ec06                	sd	ra,24(sp)
    80003f44:	e822                	sd	s0,16(sp)
    80003f46:	e426                	sd	s1,8(sp)
    80003f48:	e04a                	sd	s2,0(sp)
    80003f4a:	1000                	addi	s0,sp,32
    80003f4c:	84aa                	mv	s1,a0
    80003f4e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003f50:	00003597          	auipc	a1,0x3
    80003f54:	5f858593          	addi	a1,a1,1528 # 80007548 <etext+0x548>
    80003f58:	0521                	addi	a0,a0,8
    80003f5a:	c45fc0ef          	jal	80000b9e <initlock>
  lk->name = name;
    80003f5e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003f62:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f66:	0204a423          	sw	zero,40(s1)
}
    80003f6a:	60e2                	ld	ra,24(sp)
    80003f6c:	6442                	ld	s0,16(sp)
    80003f6e:	64a2                	ld	s1,8(sp)
    80003f70:	6902                	ld	s2,0(sp)
    80003f72:	6105                	addi	sp,sp,32
    80003f74:	8082                	ret

0000000080003f76 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003f76:	1101                	addi	sp,sp,-32
    80003f78:	ec06                	sd	ra,24(sp)
    80003f7a:	e822                	sd	s0,16(sp)
    80003f7c:	e426                	sd	s1,8(sp)
    80003f7e:	e04a                	sd	s2,0(sp)
    80003f80:	1000                	addi	s0,sp,32
    80003f82:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f84:	00850913          	addi	s2,a0,8
    80003f88:	854a                	mv	a0,s2
    80003f8a:	c9ffc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80003f8e:	409c                	lw	a5,0(s1)
    80003f90:	c799                	beqz	a5,80003f9e <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003f92:	85ca                	mv	a1,s2
    80003f94:	8526                	mv	a0,s1
    80003f96:	86afe0ef          	jal	80002000 <sleep>
  while (lk->locked) {
    80003f9a:	409c                	lw	a5,0(s1)
    80003f9c:	fbfd                	bnez	a5,80003f92 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003f9e:	4785                	li	a5,1
    80003fa0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003fa2:	98dfd0ef          	jal	8000192e <myproc>
    80003fa6:	591c                	lw	a5,48(a0)
    80003fa8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003faa:	854a                	mv	a0,s2
    80003fac:	d11fc0ef          	jal	80000cbc <release>
}
    80003fb0:	60e2                	ld	ra,24(sp)
    80003fb2:	6442                	ld	s0,16(sp)
    80003fb4:	64a2                	ld	s1,8(sp)
    80003fb6:	6902                	ld	s2,0(sp)
    80003fb8:	6105                	addi	sp,sp,32
    80003fba:	8082                	ret

0000000080003fbc <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003fbc:	1101                	addi	sp,sp,-32
    80003fbe:	ec06                	sd	ra,24(sp)
    80003fc0:	e822                	sd	s0,16(sp)
    80003fc2:	e426                	sd	s1,8(sp)
    80003fc4:	e04a                	sd	s2,0(sp)
    80003fc6:	1000                	addi	s0,sp,32
    80003fc8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003fca:	00850913          	addi	s2,a0,8
    80003fce:	854a                	mv	a0,s2
    80003fd0:	c59fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    80003fd4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003fd8:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003fdc:	8526                	mv	a0,s1
    80003fde:	86efe0ef          	jal	8000204c <wakeup>
  release(&lk->lk);
    80003fe2:	854a                	mv	a0,s2
    80003fe4:	cd9fc0ef          	jal	80000cbc <release>
}
    80003fe8:	60e2                	ld	ra,24(sp)
    80003fea:	6442                	ld	s0,16(sp)
    80003fec:	64a2                	ld	s1,8(sp)
    80003fee:	6902                	ld	s2,0(sp)
    80003ff0:	6105                	addi	sp,sp,32
    80003ff2:	8082                	ret

0000000080003ff4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003ff4:	7179                	addi	sp,sp,-48
    80003ff6:	f406                	sd	ra,40(sp)
    80003ff8:	f022                	sd	s0,32(sp)
    80003ffa:	ec26                	sd	s1,24(sp)
    80003ffc:	e84a                	sd	s2,16(sp)
    80003ffe:	1800                	addi	s0,sp,48
    80004000:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004002:	00850913          	addi	s2,a0,8
    80004006:	854a                	mv	a0,s2
    80004008:	c21fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000400c:	409c                	lw	a5,0(s1)
    8000400e:	ef81                	bnez	a5,80004026 <holdingsleep+0x32>
    80004010:	4481                	li	s1,0
  release(&lk->lk);
    80004012:	854a                	mv	a0,s2
    80004014:	ca9fc0ef          	jal	80000cbc <release>
  return r;
}
    80004018:	8526                	mv	a0,s1
    8000401a:	70a2                	ld	ra,40(sp)
    8000401c:	7402                	ld	s0,32(sp)
    8000401e:	64e2                	ld	s1,24(sp)
    80004020:	6942                	ld	s2,16(sp)
    80004022:	6145                	addi	sp,sp,48
    80004024:	8082                	ret
    80004026:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004028:	0284a983          	lw	s3,40(s1)
    8000402c:	903fd0ef          	jal	8000192e <myproc>
    80004030:	5904                	lw	s1,48(a0)
    80004032:	413484b3          	sub	s1,s1,s3
    80004036:	0014b493          	seqz	s1,s1
    8000403a:	69a2                	ld	s3,8(sp)
    8000403c:	bfd9                	j	80004012 <holdingsleep+0x1e>

000000008000403e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000403e:	1141                	addi	sp,sp,-16
    80004040:	e406                	sd	ra,8(sp)
    80004042:	e022                	sd	s0,0(sp)
    80004044:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004046:	00003597          	auipc	a1,0x3
    8000404a:	51258593          	addi	a1,a1,1298 # 80007558 <etext+0x558>
    8000404e:	0001e517          	auipc	a0,0x1e
    80004052:	60250513          	addi	a0,a0,1538 # 80022650 <ftable>
    80004056:	b49fc0ef          	jal	80000b9e <initlock>
}
    8000405a:	60a2                	ld	ra,8(sp)
    8000405c:	6402                	ld	s0,0(sp)
    8000405e:	0141                	addi	sp,sp,16
    80004060:	8082                	ret

0000000080004062 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004062:	1101                	addi	sp,sp,-32
    80004064:	ec06                	sd	ra,24(sp)
    80004066:	e822                	sd	s0,16(sp)
    80004068:	e426                	sd	s1,8(sp)
    8000406a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000406c:	0001e517          	auipc	a0,0x1e
    80004070:	5e450513          	addi	a0,a0,1508 # 80022650 <ftable>
    80004074:	bb5fc0ef          	jal	80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004078:	0001e497          	auipc	s1,0x1e
    8000407c:	5f048493          	addi	s1,s1,1520 # 80022668 <ftable+0x18>
    80004080:	0001f717          	auipc	a4,0x1f
    80004084:	58870713          	addi	a4,a4,1416 # 80023608 <disk>
    if(f->ref == 0){
    80004088:	40dc                	lw	a5,4(s1)
    8000408a:	cf89                	beqz	a5,800040a4 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000408c:	02848493          	addi	s1,s1,40
    80004090:	fee49ce3          	bne	s1,a4,80004088 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004094:	0001e517          	auipc	a0,0x1e
    80004098:	5bc50513          	addi	a0,a0,1468 # 80022650 <ftable>
    8000409c:	c21fc0ef          	jal	80000cbc <release>
  return 0;
    800040a0:	4481                	li	s1,0
    800040a2:	a809                	j	800040b4 <filealloc+0x52>
      f->ref = 1;
    800040a4:	4785                	li	a5,1
    800040a6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800040a8:	0001e517          	auipc	a0,0x1e
    800040ac:	5a850513          	addi	a0,a0,1448 # 80022650 <ftable>
    800040b0:	c0dfc0ef          	jal	80000cbc <release>
}
    800040b4:	8526                	mv	a0,s1
    800040b6:	60e2                	ld	ra,24(sp)
    800040b8:	6442                	ld	s0,16(sp)
    800040ba:	64a2                	ld	s1,8(sp)
    800040bc:	6105                	addi	sp,sp,32
    800040be:	8082                	ret

00000000800040c0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800040c0:	1101                	addi	sp,sp,-32
    800040c2:	ec06                	sd	ra,24(sp)
    800040c4:	e822                	sd	s0,16(sp)
    800040c6:	e426                	sd	s1,8(sp)
    800040c8:	1000                	addi	s0,sp,32
    800040ca:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800040cc:	0001e517          	auipc	a0,0x1e
    800040d0:	58450513          	addi	a0,a0,1412 # 80022650 <ftable>
    800040d4:	b55fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    800040d8:	40dc                	lw	a5,4(s1)
    800040da:	02f05063          	blez	a5,800040fa <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800040de:	2785                	addiw	a5,a5,1
    800040e0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800040e2:	0001e517          	auipc	a0,0x1e
    800040e6:	56e50513          	addi	a0,a0,1390 # 80022650 <ftable>
    800040ea:	bd3fc0ef          	jal	80000cbc <release>
  return f;
}
    800040ee:	8526                	mv	a0,s1
    800040f0:	60e2                	ld	ra,24(sp)
    800040f2:	6442                	ld	s0,16(sp)
    800040f4:	64a2                	ld	s1,8(sp)
    800040f6:	6105                	addi	sp,sp,32
    800040f8:	8082                	ret
    panic("filedup");
    800040fa:	00003517          	auipc	a0,0x3
    800040fe:	46650513          	addi	a0,a0,1126 # 80007560 <etext+0x560>
    80004102:	f22fc0ef          	jal	80000824 <panic>

0000000080004106 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004106:	7139                	addi	sp,sp,-64
    80004108:	fc06                	sd	ra,56(sp)
    8000410a:	f822                	sd	s0,48(sp)
    8000410c:	f426                	sd	s1,40(sp)
    8000410e:	0080                	addi	s0,sp,64
    80004110:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004112:	0001e517          	auipc	a0,0x1e
    80004116:	53e50513          	addi	a0,a0,1342 # 80022650 <ftable>
    8000411a:	b0ffc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    8000411e:	40dc                	lw	a5,4(s1)
    80004120:	04f05a63          	blez	a5,80004174 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004124:	37fd                	addiw	a5,a5,-1
    80004126:	c0dc                	sw	a5,4(s1)
    80004128:	06f04063          	bgtz	a5,80004188 <fileclose+0x82>
    8000412c:	f04a                	sd	s2,32(sp)
    8000412e:	ec4e                	sd	s3,24(sp)
    80004130:	e852                	sd	s4,16(sp)
    80004132:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004134:	0004a903          	lw	s2,0(s1)
    80004138:	0094c783          	lbu	a5,9(s1)
    8000413c:	89be                	mv	s3,a5
    8000413e:	689c                	ld	a5,16(s1)
    80004140:	8a3e                	mv	s4,a5
    80004142:	6c9c                	ld	a5,24(s1)
    80004144:	8abe                	mv	s5,a5
  f->ref = 0;
    80004146:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000414a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000414e:	0001e517          	auipc	a0,0x1e
    80004152:	50250513          	addi	a0,a0,1282 # 80022650 <ftable>
    80004156:	b67fc0ef          	jal	80000cbc <release>

  if(ff.type == FD_PIPE){
    8000415a:	4785                	li	a5,1
    8000415c:	04f90163          	beq	s2,a5,8000419e <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004160:	ffe9079b          	addiw	a5,s2,-2
    80004164:	4705                	li	a4,1
    80004166:	04f77563          	bgeu	a4,a5,800041b0 <fileclose+0xaa>
    8000416a:	7902                	ld	s2,32(sp)
    8000416c:	69e2                	ld	s3,24(sp)
    8000416e:	6a42                	ld	s4,16(sp)
    80004170:	6aa2                	ld	s5,8(sp)
    80004172:	a00d                	j	80004194 <fileclose+0x8e>
    80004174:	f04a                	sd	s2,32(sp)
    80004176:	ec4e                	sd	s3,24(sp)
    80004178:	e852                	sd	s4,16(sp)
    8000417a:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000417c:	00003517          	auipc	a0,0x3
    80004180:	3ec50513          	addi	a0,a0,1004 # 80007568 <etext+0x568>
    80004184:	ea0fc0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    80004188:	0001e517          	auipc	a0,0x1e
    8000418c:	4c850513          	addi	a0,a0,1224 # 80022650 <ftable>
    80004190:	b2dfc0ef          	jal	80000cbc <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004194:	70e2                	ld	ra,56(sp)
    80004196:	7442                	ld	s0,48(sp)
    80004198:	74a2                	ld	s1,40(sp)
    8000419a:	6121                	addi	sp,sp,64
    8000419c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000419e:	85ce                	mv	a1,s3
    800041a0:	8552                	mv	a0,s4
    800041a2:	348000ef          	jal	800044ea <pipeclose>
    800041a6:	7902                	ld	s2,32(sp)
    800041a8:	69e2                	ld	s3,24(sp)
    800041aa:	6a42                	ld	s4,16(sp)
    800041ac:	6aa2                	ld	s5,8(sp)
    800041ae:	b7dd                	j	80004194 <fileclose+0x8e>
    begin_op();
    800041b0:	b33ff0ef          	jal	80003ce2 <begin_op>
    iput(ff.ip);
    800041b4:	8556                	mv	a0,s5
    800041b6:	aa2ff0ef          	jal	80003458 <iput>
    end_op();
    800041ba:	b99ff0ef          	jal	80003d52 <end_op>
    800041be:	7902                	ld	s2,32(sp)
    800041c0:	69e2                	ld	s3,24(sp)
    800041c2:	6a42                	ld	s4,16(sp)
    800041c4:	6aa2                	ld	s5,8(sp)
    800041c6:	b7f9                	j	80004194 <fileclose+0x8e>

00000000800041c8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800041c8:	715d                	addi	sp,sp,-80
    800041ca:	e486                	sd	ra,72(sp)
    800041cc:	e0a2                	sd	s0,64(sp)
    800041ce:	fc26                	sd	s1,56(sp)
    800041d0:	f052                	sd	s4,32(sp)
    800041d2:	0880                	addi	s0,sp,80
    800041d4:	84aa                	mv	s1,a0
    800041d6:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    800041d8:	f56fd0ef          	jal	8000192e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800041dc:	409c                	lw	a5,0(s1)
    800041de:	37f9                	addiw	a5,a5,-2
    800041e0:	4705                	li	a4,1
    800041e2:	04f76263          	bltu	a4,a5,80004226 <filestat+0x5e>
    800041e6:	f84a                	sd	s2,48(sp)
    800041e8:	f44e                	sd	s3,40(sp)
    800041ea:	89aa                	mv	s3,a0
    ilock(f->ip);
    800041ec:	6c88                	ld	a0,24(s1)
    800041ee:	8e8ff0ef          	jal	800032d6 <ilock>
    stati(f->ip, &st);
    800041f2:	fb840913          	addi	s2,s0,-72
    800041f6:	85ca                	mv	a1,s2
    800041f8:	6c88                	ld	a0,24(s1)
    800041fa:	c40ff0ef          	jal	8000363a <stati>
    iunlock(f->ip);
    800041fe:	6c88                	ld	a0,24(s1)
    80004200:	984ff0ef          	jal	80003384 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004204:	46e1                	li	a3,24
    80004206:	864a                	mv	a2,s2
    80004208:	85d2                	mv	a1,s4
    8000420a:	0589b503          	ld	a0,88(s3)
    8000420e:	c46fd0ef          	jal	80001654 <copyout>
    80004212:	41f5551b          	sraiw	a0,a0,0x1f
    80004216:	7942                	ld	s2,48(sp)
    80004218:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000421a:	60a6                	ld	ra,72(sp)
    8000421c:	6406                	ld	s0,64(sp)
    8000421e:	74e2                	ld	s1,56(sp)
    80004220:	7a02                	ld	s4,32(sp)
    80004222:	6161                	addi	sp,sp,80
    80004224:	8082                	ret
  return -1;
    80004226:	557d                	li	a0,-1
    80004228:	bfcd                	j	8000421a <filestat+0x52>

000000008000422a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000422a:	7179                	addi	sp,sp,-48
    8000422c:	f406                	sd	ra,40(sp)
    8000422e:	f022                	sd	s0,32(sp)
    80004230:	e84a                	sd	s2,16(sp)
    80004232:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004234:	00854783          	lbu	a5,8(a0)
    80004238:	cfd1                	beqz	a5,800042d4 <fileread+0xaa>
    8000423a:	ec26                	sd	s1,24(sp)
    8000423c:	e44e                	sd	s3,8(sp)
    8000423e:	84aa                	mv	s1,a0
    80004240:	892e                	mv	s2,a1
    80004242:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    80004244:	411c                	lw	a5,0(a0)
    80004246:	4705                	li	a4,1
    80004248:	04e78363          	beq	a5,a4,8000428e <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000424c:	470d                	li	a4,3
    8000424e:	04e78763          	beq	a5,a4,8000429c <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004252:	4709                	li	a4,2
    80004254:	06e79a63          	bne	a5,a4,800042c8 <fileread+0x9e>
    ilock(f->ip);
    80004258:	6d08                	ld	a0,24(a0)
    8000425a:	87cff0ef          	jal	800032d6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000425e:	874e                	mv	a4,s3
    80004260:	5094                	lw	a3,32(s1)
    80004262:	864a                	mv	a2,s2
    80004264:	4585                	li	a1,1
    80004266:	6c88                	ld	a0,24(s1)
    80004268:	c00ff0ef          	jal	80003668 <readi>
    8000426c:	892a                	mv	s2,a0
    8000426e:	00a05563          	blez	a0,80004278 <fileread+0x4e>
      f->off += r;
    80004272:	509c                	lw	a5,32(s1)
    80004274:	9fa9                	addw	a5,a5,a0
    80004276:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004278:	6c88                	ld	a0,24(s1)
    8000427a:	90aff0ef          	jal	80003384 <iunlock>
    8000427e:	64e2                	ld	s1,24(sp)
    80004280:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004282:	854a                	mv	a0,s2
    80004284:	70a2                	ld	ra,40(sp)
    80004286:	7402                	ld	s0,32(sp)
    80004288:	6942                	ld	s2,16(sp)
    8000428a:	6145                	addi	sp,sp,48
    8000428c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000428e:	6908                	ld	a0,16(a0)
    80004290:	3b0000ef          	jal	80004640 <piperead>
    80004294:	892a                	mv	s2,a0
    80004296:	64e2                	ld	s1,24(sp)
    80004298:	69a2                	ld	s3,8(sp)
    8000429a:	b7e5                	j	80004282 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000429c:	02451783          	lh	a5,36(a0)
    800042a0:	03079693          	slli	a3,a5,0x30
    800042a4:	92c1                	srli	a3,a3,0x30
    800042a6:	4725                	li	a4,9
    800042a8:	02d76963          	bltu	a4,a3,800042da <fileread+0xb0>
    800042ac:	0792                	slli	a5,a5,0x4
    800042ae:	0001e717          	auipc	a4,0x1e
    800042b2:	30270713          	addi	a4,a4,770 # 800225b0 <devsw>
    800042b6:	97ba                	add	a5,a5,a4
    800042b8:	639c                	ld	a5,0(a5)
    800042ba:	c78d                	beqz	a5,800042e4 <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    800042bc:	4505                	li	a0,1
    800042be:	9782                	jalr	a5
    800042c0:	892a                	mv	s2,a0
    800042c2:	64e2                	ld	s1,24(sp)
    800042c4:	69a2                	ld	s3,8(sp)
    800042c6:	bf75                	j	80004282 <fileread+0x58>
    panic("fileread");
    800042c8:	00003517          	auipc	a0,0x3
    800042cc:	2b050513          	addi	a0,a0,688 # 80007578 <etext+0x578>
    800042d0:	d54fc0ef          	jal	80000824 <panic>
    return -1;
    800042d4:	57fd                	li	a5,-1
    800042d6:	893e                	mv	s2,a5
    800042d8:	b76d                	j	80004282 <fileread+0x58>
      return -1;
    800042da:	57fd                	li	a5,-1
    800042dc:	893e                	mv	s2,a5
    800042de:	64e2                	ld	s1,24(sp)
    800042e0:	69a2                	ld	s3,8(sp)
    800042e2:	b745                	j	80004282 <fileread+0x58>
    800042e4:	57fd                	li	a5,-1
    800042e6:	893e                	mv	s2,a5
    800042e8:	64e2                	ld	s1,24(sp)
    800042ea:	69a2                	ld	s3,8(sp)
    800042ec:	bf59                	j	80004282 <fileread+0x58>

00000000800042ee <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800042ee:	00954783          	lbu	a5,9(a0)
    800042f2:	10078f63          	beqz	a5,80004410 <filewrite+0x122>
{
    800042f6:	711d                	addi	sp,sp,-96
    800042f8:	ec86                	sd	ra,88(sp)
    800042fa:	e8a2                	sd	s0,80(sp)
    800042fc:	e0ca                	sd	s2,64(sp)
    800042fe:	f456                	sd	s5,40(sp)
    80004300:	f05a                	sd	s6,32(sp)
    80004302:	1080                	addi	s0,sp,96
    80004304:	892a                	mv	s2,a0
    80004306:	8b2e                	mv	s6,a1
    80004308:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    8000430a:	411c                	lw	a5,0(a0)
    8000430c:	4705                	li	a4,1
    8000430e:	02e78a63          	beq	a5,a4,80004342 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004312:	470d                	li	a4,3
    80004314:	02e78b63          	beq	a5,a4,8000434a <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004318:	4709                	li	a4,2
    8000431a:	0ce79f63          	bne	a5,a4,800043f8 <filewrite+0x10a>
    8000431e:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004320:	0ac05a63          	blez	a2,800043d4 <filewrite+0xe6>
    80004324:	e4a6                	sd	s1,72(sp)
    80004326:	fc4e                	sd	s3,56(sp)
    80004328:	ec5e                	sd	s7,24(sp)
    8000432a:	e862                	sd	s8,16(sp)
    8000432c:	e466                	sd	s9,8(sp)
    int i = 0;
    8000432e:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004330:	6b85                	lui	s7,0x1
    80004332:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004336:	6785                	lui	a5,0x1
    80004338:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    8000433c:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000433e:	4c05                	li	s8,1
    80004340:	a8ad                	j	800043ba <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004342:	6908                	ld	a0,16(a0)
    80004344:	204000ef          	jal	80004548 <pipewrite>
    80004348:	a04d                	j	800043ea <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000434a:	02451783          	lh	a5,36(a0)
    8000434e:	03079693          	slli	a3,a5,0x30
    80004352:	92c1                	srli	a3,a3,0x30
    80004354:	4725                	li	a4,9
    80004356:	0ad76f63          	bltu	a4,a3,80004414 <filewrite+0x126>
    8000435a:	0792                	slli	a5,a5,0x4
    8000435c:	0001e717          	auipc	a4,0x1e
    80004360:	25470713          	addi	a4,a4,596 # 800225b0 <devsw>
    80004364:	97ba                	add	a5,a5,a4
    80004366:	679c                	ld	a5,8(a5)
    80004368:	cbc5                	beqz	a5,80004418 <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    8000436a:	4505                	li	a0,1
    8000436c:	9782                	jalr	a5
    8000436e:	a8b5                	j	800043ea <filewrite+0xfc>
      if(n1 > max)
    80004370:	2981                	sext.w	s3,s3
      begin_op();
    80004372:	971ff0ef          	jal	80003ce2 <begin_op>
      ilock(f->ip);
    80004376:	01893503          	ld	a0,24(s2)
    8000437a:	f5dfe0ef          	jal	800032d6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000437e:	874e                	mv	a4,s3
    80004380:	02092683          	lw	a3,32(s2)
    80004384:	016a0633          	add	a2,s4,s6
    80004388:	85e2                	mv	a1,s8
    8000438a:	01893503          	ld	a0,24(s2)
    8000438e:	bccff0ef          	jal	8000375a <writei>
    80004392:	84aa                	mv	s1,a0
    80004394:	00a05763          	blez	a0,800043a2 <filewrite+0xb4>
        f->off += r;
    80004398:	02092783          	lw	a5,32(s2)
    8000439c:	9fa9                	addw	a5,a5,a0
    8000439e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800043a2:	01893503          	ld	a0,24(s2)
    800043a6:	fdffe0ef          	jal	80003384 <iunlock>
      end_op();
    800043aa:	9a9ff0ef          	jal	80003d52 <end_op>

      if(r != n1){
    800043ae:	02999563          	bne	s3,s1,800043d8 <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    800043b2:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    800043b6:	015a5963          	bge	s4,s5,800043c8 <filewrite+0xda>
      int n1 = n - i;
    800043ba:	414a87bb          	subw	a5,s5,s4
    800043be:	89be                	mv	s3,a5
      if(n1 > max)
    800043c0:	fafbd8e3          	bge	s7,a5,80004370 <filewrite+0x82>
    800043c4:	89e6                	mv	s3,s9
    800043c6:	b76d                	j	80004370 <filewrite+0x82>
    800043c8:	64a6                	ld	s1,72(sp)
    800043ca:	79e2                	ld	s3,56(sp)
    800043cc:	6be2                	ld	s7,24(sp)
    800043ce:	6c42                	ld	s8,16(sp)
    800043d0:	6ca2                	ld	s9,8(sp)
    800043d2:	a801                	j	800043e2 <filewrite+0xf4>
    int i = 0;
    800043d4:	4a01                	li	s4,0
    800043d6:	a031                	j	800043e2 <filewrite+0xf4>
    800043d8:	64a6                	ld	s1,72(sp)
    800043da:	79e2                	ld	s3,56(sp)
    800043dc:	6be2                	ld	s7,24(sp)
    800043de:	6c42                	ld	s8,16(sp)
    800043e0:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    800043e2:	034a9d63          	bne	s5,s4,8000441c <filewrite+0x12e>
    800043e6:	8556                	mv	a0,s5
    800043e8:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800043ea:	60e6                	ld	ra,88(sp)
    800043ec:	6446                	ld	s0,80(sp)
    800043ee:	6906                	ld	s2,64(sp)
    800043f0:	7aa2                	ld	s5,40(sp)
    800043f2:	7b02                	ld	s6,32(sp)
    800043f4:	6125                	addi	sp,sp,96
    800043f6:	8082                	ret
    800043f8:	e4a6                	sd	s1,72(sp)
    800043fa:	fc4e                	sd	s3,56(sp)
    800043fc:	f852                	sd	s4,48(sp)
    800043fe:	ec5e                	sd	s7,24(sp)
    80004400:	e862                	sd	s8,16(sp)
    80004402:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004404:	00003517          	auipc	a0,0x3
    80004408:	18450513          	addi	a0,a0,388 # 80007588 <etext+0x588>
    8000440c:	c18fc0ef          	jal	80000824 <panic>
    return -1;
    80004410:	557d                	li	a0,-1
}
    80004412:	8082                	ret
      return -1;
    80004414:	557d                	li	a0,-1
    80004416:	bfd1                	j	800043ea <filewrite+0xfc>
    80004418:	557d                	li	a0,-1
    8000441a:	bfc1                	j	800043ea <filewrite+0xfc>
    ret = (i == n ? n : -1);
    8000441c:	557d                	li	a0,-1
    8000441e:	7a42                	ld	s4,48(sp)
    80004420:	b7e9                	j	800043ea <filewrite+0xfc>

0000000080004422 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004422:	7179                	addi	sp,sp,-48
    80004424:	f406                	sd	ra,40(sp)
    80004426:	f022                	sd	s0,32(sp)
    80004428:	ec26                	sd	s1,24(sp)
    8000442a:	e052                	sd	s4,0(sp)
    8000442c:	1800                	addi	s0,sp,48
    8000442e:	84aa                	mv	s1,a0
    80004430:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004432:	0005b023          	sd	zero,0(a1)
    80004436:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000443a:	c29ff0ef          	jal	80004062 <filealloc>
    8000443e:	e088                	sd	a0,0(s1)
    80004440:	c549                	beqz	a0,800044ca <pipealloc+0xa8>
    80004442:	c21ff0ef          	jal	80004062 <filealloc>
    80004446:	00aa3023          	sd	a0,0(s4)
    8000444a:	cd25                	beqz	a0,800044c2 <pipealloc+0xa0>
    8000444c:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000444e:	ef6fc0ef          	jal	80000b44 <kalloc>
    80004452:	892a                	mv	s2,a0
    80004454:	c12d                	beqz	a0,800044b6 <pipealloc+0x94>
    80004456:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004458:	4985                	li	s3,1
    8000445a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000445e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004462:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004466:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000446a:	00003597          	auipc	a1,0x3
    8000446e:	12e58593          	addi	a1,a1,302 # 80007598 <etext+0x598>
    80004472:	f2cfc0ef          	jal	80000b9e <initlock>
  (*f0)->type = FD_PIPE;
    80004476:	609c                	ld	a5,0(s1)
    80004478:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000447c:	609c                	ld	a5,0(s1)
    8000447e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004482:	609c                	ld	a5,0(s1)
    80004484:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004488:	609c                	ld	a5,0(s1)
    8000448a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000448e:	000a3783          	ld	a5,0(s4)
    80004492:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004496:	000a3783          	ld	a5,0(s4)
    8000449a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000449e:	000a3783          	ld	a5,0(s4)
    800044a2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800044a6:	000a3783          	ld	a5,0(s4)
    800044aa:	0127b823          	sd	s2,16(a5)
  return 0;
    800044ae:	4501                	li	a0,0
    800044b0:	6942                	ld	s2,16(sp)
    800044b2:	69a2                	ld	s3,8(sp)
    800044b4:	a01d                	j	800044da <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800044b6:	6088                	ld	a0,0(s1)
    800044b8:	c119                	beqz	a0,800044be <pipealloc+0x9c>
    800044ba:	6942                	ld	s2,16(sp)
    800044bc:	a029                	j	800044c6 <pipealloc+0xa4>
    800044be:	6942                	ld	s2,16(sp)
    800044c0:	a029                	j	800044ca <pipealloc+0xa8>
    800044c2:	6088                	ld	a0,0(s1)
    800044c4:	c10d                	beqz	a0,800044e6 <pipealloc+0xc4>
    fileclose(*f0);
    800044c6:	c41ff0ef          	jal	80004106 <fileclose>
  if(*f1)
    800044ca:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800044ce:	557d                	li	a0,-1
  if(*f1)
    800044d0:	c789                	beqz	a5,800044da <pipealloc+0xb8>
    fileclose(*f1);
    800044d2:	853e                	mv	a0,a5
    800044d4:	c33ff0ef          	jal	80004106 <fileclose>
  return -1;
    800044d8:	557d                	li	a0,-1
}
    800044da:	70a2                	ld	ra,40(sp)
    800044dc:	7402                	ld	s0,32(sp)
    800044de:	64e2                	ld	s1,24(sp)
    800044e0:	6a02                	ld	s4,0(sp)
    800044e2:	6145                	addi	sp,sp,48
    800044e4:	8082                	ret
  return -1;
    800044e6:	557d                	li	a0,-1
    800044e8:	bfcd                	j	800044da <pipealloc+0xb8>

00000000800044ea <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800044ea:	1101                	addi	sp,sp,-32
    800044ec:	ec06                	sd	ra,24(sp)
    800044ee:	e822                	sd	s0,16(sp)
    800044f0:	e426                	sd	s1,8(sp)
    800044f2:	e04a                	sd	s2,0(sp)
    800044f4:	1000                	addi	s0,sp,32
    800044f6:	84aa                	mv	s1,a0
    800044f8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800044fa:	f2efc0ef          	jal	80000c28 <acquire>
  if(writable){
    800044fe:	02090763          	beqz	s2,8000452c <pipeclose+0x42>
    pi->writeopen = 0;
    80004502:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004506:	21848513          	addi	a0,s1,536
    8000450a:	b43fd0ef          	jal	8000204c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000450e:	2204a783          	lw	a5,544(s1)
    80004512:	e781                	bnez	a5,8000451a <pipeclose+0x30>
    80004514:	2244a783          	lw	a5,548(s1)
    80004518:	c38d                	beqz	a5,8000453a <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    8000451a:	8526                	mv	a0,s1
    8000451c:	fa0fc0ef          	jal	80000cbc <release>
}
    80004520:	60e2                	ld	ra,24(sp)
    80004522:	6442                	ld	s0,16(sp)
    80004524:	64a2                	ld	s1,8(sp)
    80004526:	6902                	ld	s2,0(sp)
    80004528:	6105                	addi	sp,sp,32
    8000452a:	8082                	ret
    pi->readopen = 0;
    8000452c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004530:	21c48513          	addi	a0,s1,540
    80004534:	b19fd0ef          	jal	8000204c <wakeup>
    80004538:	bfd9                	j	8000450e <pipeclose+0x24>
    release(&pi->lock);
    8000453a:	8526                	mv	a0,s1
    8000453c:	f80fc0ef          	jal	80000cbc <release>
    kfree((char*)pi);
    80004540:	8526                	mv	a0,s1
    80004542:	d1afc0ef          	jal	80000a5c <kfree>
    80004546:	bfe9                	j	80004520 <pipeclose+0x36>

0000000080004548 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004548:	7159                	addi	sp,sp,-112
    8000454a:	f486                	sd	ra,104(sp)
    8000454c:	f0a2                	sd	s0,96(sp)
    8000454e:	eca6                	sd	s1,88(sp)
    80004550:	e8ca                	sd	s2,80(sp)
    80004552:	e4ce                	sd	s3,72(sp)
    80004554:	e0d2                	sd	s4,64(sp)
    80004556:	fc56                	sd	s5,56(sp)
    80004558:	1880                	addi	s0,sp,112
    8000455a:	84aa                	mv	s1,a0
    8000455c:	8aae                	mv	s5,a1
    8000455e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004560:	bcefd0ef          	jal	8000192e <myproc>
    80004564:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004566:	8526                	mv	a0,s1
    80004568:	ec0fc0ef          	jal	80000c28 <acquire>
  while(i < n){
    8000456c:	0d405263          	blez	s4,80004630 <pipewrite+0xe8>
    80004570:	f85a                	sd	s6,48(sp)
    80004572:	f45e                	sd	s7,40(sp)
    80004574:	f062                	sd	s8,32(sp)
    80004576:	ec66                	sd	s9,24(sp)
    80004578:	e86a                	sd	s10,16(sp)
  int i = 0;
    8000457a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000457c:	f9f40c13          	addi	s8,s0,-97
    80004580:	4b85                	li	s7,1
    80004582:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004584:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004588:	21c48c93          	addi	s9,s1,540
    8000458c:	a82d                	j	800045c6 <pipewrite+0x7e>
      release(&pi->lock);
    8000458e:	8526                	mv	a0,s1
    80004590:	f2cfc0ef          	jal	80000cbc <release>
      return -1;
    80004594:	597d                	li	s2,-1
    80004596:	7b42                	ld	s6,48(sp)
    80004598:	7ba2                	ld	s7,40(sp)
    8000459a:	7c02                	ld	s8,32(sp)
    8000459c:	6ce2                	ld	s9,24(sp)
    8000459e:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800045a0:	854a                	mv	a0,s2
    800045a2:	70a6                	ld	ra,104(sp)
    800045a4:	7406                	ld	s0,96(sp)
    800045a6:	64e6                	ld	s1,88(sp)
    800045a8:	6946                	ld	s2,80(sp)
    800045aa:	69a6                	ld	s3,72(sp)
    800045ac:	6a06                	ld	s4,64(sp)
    800045ae:	7ae2                	ld	s5,56(sp)
    800045b0:	6165                	addi	sp,sp,112
    800045b2:	8082                	ret
      wakeup(&pi->nread);
    800045b4:	856a                	mv	a0,s10
    800045b6:	a97fd0ef          	jal	8000204c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800045ba:	85a6                	mv	a1,s1
    800045bc:	8566                	mv	a0,s9
    800045be:	a43fd0ef          	jal	80002000 <sleep>
  while(i < n){
    800045c2:	05495a63          	bge	s2,s4,80004616 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    800045c6:	2204a783          	lw	a5,544(s1)
    800045ca:	d3f1                	beqz	a5,8000458e <pipewrite+0x46>
    800045cc:	854e                	mv	a0,s3
    800045ce:	c6ffd0ef          	jal	8000223c <killed>
    800045d2:	fd55                	bnez	a0,8000458e <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800045d4:	2184a783          	lw	a5,536(s1)
    800045d8:	21c4a703          	lw	a4,540(s1)
    800045dc:	2007879b          	addiw	a5,a5,512
    800045e0:	fcf70ae3          	beq	a4,a5,800045b4 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800045e4:	86de                	mv	a3,s7
    800045e6:	01590633          	add	a2,s2,s5
    800045ea:	85e2                	mv	a1,s8
    800045ec:	0589b503          	ld	a0,88(s3)
    800045f0:	922fd0ef          	jal	80001712 <copyin>
    800045f4:	05650063          	beq	a0,s6,80004634 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800045f8:	21c4a783          	lw	a5,540(s1)
    800045fc:	0017871b          	addiw	a4,a5,1
    80004600:	20e4ae23          	sw	a4,540(s1)
    80004604:	1ff7f793          	andi	a5,a5,511
    80004608:	97a6                	add	a5,a5,s1
    8000460a:	f9f44703          	lbu	a4,-97(s0)
    8000460e:	00e78c23          	sb	a4,24(a5)
      i++;
    80004612:	2905                	addiw	s2,s2,1
    80004614:	b77d                	j	800045c2 <pipewrite+0x7a>
    80004616:	7b42                	ld	s6,48(sp)
    80004618:	7ba2                	ld	s7,40(sp)
    8000461a:	7c02                	ld	s8,32(sp)
    8000461c:	6ce2                	ld	s9,24(sp)
    8000461e:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004620:	21848513          	addi	a0,s1,536
    80004624:	a29fd0ef          	jal	8000204c <wakeup>
  release(&pi->lock);
    80004628:	8526                	mv	a0,s1
    8000462a:	e92fc0ef          	jal	80000cbc <release>
  return i;
    8000462e:	bf8d                	j	800045a0 <pipewrite+0x58>
  int i = 0;
    80004630:	4901                	li	s2,0
    80004632:	b7fd                	j	80004620 <pipewrite+0xd8>
    80004634:	7b42                	ld	s6,48(sp)
    80004636:	7ba2                	ld	s7,40(sp)
    80004638:	7c02                	ld	s8,32(sp)
    8000463a:	6ce2                	ld	s9,24(sp)
    8000463c:	6d42                	ld	s10,16(sp)
    8000463e:	b7cd                	j	80004620 <pipewrite+0xd8>

0000000080004640 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004640:	711d                	addi	sp,sp,-96
    80004642:	ec86                	sd	ra,88(sp)
    80004644:	e8a2                	sd	s0,80(sp)
    80004646:	e4a6                	sd	s1,72(sp)
    80004648:	e0ca                	sd	s2,64(sp)
    8000464a:	fc4e                	sd	s3,56(sp)
    8000464c:	f852                	sd	s4,48(sp)
    8000464e:	f456                	sd	s5,40(sp)
    80004650:	1080                	addi	s0,sp,96
    80004652:	84aa                	mv	s1,a0
    80004654:	892e                	mv	s2,a1
    80004656:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004658:	ad6fd0ef          	jal	8000192e <myproc>
    8000465c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000465e:	8526                	mv	a0,s1
    80004660:	dc8fc0ef          	jal	80000c28 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004664:	2184a703          	lw	a4,536(s1)
    80004668:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000466c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004670:	02f71763          	bne	a4,a5,8000469e <piperead+0x5e>
    80004674:	2244a783          	lw	a5,548(s1)
    80004678:	cf85                	beqz	a5,800046b0 <piperead+0x70>
    if(killed(pr)){
    8000467a:	8552                	mv	a0,s4
    8000467c:	bc1fd0ef          	jal	8000223c <killed>
    80004680:	e11d                	bnez	a0,800046a6 <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004682:	85a6                	mv	a1,s1
    80004684:	854e                	mv	a0,s3
    80004686:	97bfd0ef          	jal	80002000 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000468a:	2184a703          	lw	a4,536(s1)
    8000468e:	21c4a783          	lw	a5,540(s1)
    80004692:	fef701e3          	beq	a4,a5,80004674 <piperead+0x34>
    80004696:	f05a                	sd	s6,32(sp)
    80004698:	ec5e                	sd	s7,24(sp)
    8000469a:	e862                	sd	s8,16(sp)
    8000469c:	a829                	j	800046b6 <piperead+0x76>
    8000469e:	f05a                	sd	s6,32(sp)
    800046a0:	ec5e                	sd	s7,24(sp)
    800046a2:	e862                	sd	s8,16(sp)
    800046a4:	a809                	j	800046b6 <piperead+0x76>
      release(&pi->lock);
    800046a6:	8526                	mv	a0,s1
    800046a8:	e14fc0ef          	jal	80000cbc <release>
      return -1;
    800046ac:	59fd                	li	s3,-1
    800046ae:	a0a5                	j	80004716 <piperead+0xd6>
    800046b0:	f05a                	sd	s6,32(sp)
    800046b2:	ec5e                	sd	s7,24(sp)
    800046b4:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046b6:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800046b8:	faf40c13          	addi	s8,s0,-81
    800046bc:	4b85                	li	s7,1
    800046be:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046c0:	05505163          	blez	s5,80004702 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    800046c4:	2184a783          	lw	a5,536(s1)
    800046c8:	21c4a703          	lw	a4,540(s1)
    800046cc:	02f70b63          	beq	a4,a5,80004702 <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    800046d0:	1ff7f793          	andi	a5,a5,511
    800046d4:	97a6                	add	a5,a5,s1
    800046d6:	0187c783          	lbu	a5,24(a5)
    800046da:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800046de:	86de                	mv	a3,s7
    800046e0:	8662                	mv	a2,s8
    800046e2:	85ca                	mv	a1,s2
    800046e4:	058a3503          	ld	a0,88(s4)
    800046e8:	f6dfc0ef          	jal	80001654 <copyout>
    800046ec:	03650f63          	beq	a0,s6,8000472a <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800046f0:	2184a783          	lw	a5,536(s1)
    800046f4:	2785                	addiw	a5,a5,1
    800046f6:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046fa:	2985                	addiw	s3,s3,1
    800046fc:	0905                	addi	s2,s2,1
    800046fe:	fd3a93e3          	bne	s5,s3,800046c4 <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004702:	21c48513          	addi	a0,s1,540
    80004706:	947fd0ef          	jal	8000204c <wakeup>
  release(&pi->lock);
    8000470a:	8526                	mv	a0,s1
    8000470c:	db0fc0ef          	jal	80000cbc <release>
    80004710:	7b02                	ld	s6,32(sp)
    80004712:	6be2                	ld	s7,24(sp)
    80004714:	6c42                	ld	s8,16(sp)
  return i;
}
    80004716:	854e                	mv	a0,s3
    80004718:	60e6                	ld	ra,88(sp)
    8000471a:	6446                	ld	s0,80(sp)
    8000471c:	64a6                	ld	s1,72(sp)
    8000471e:	6906                	ld	s2,64(sp)
    80004720:	79e2                	ld	s3,56(sp)
    80004722:	7a42                	ld	s4,48(sp)
    80004724:	7aa2                	ld	s5,40(sp)
    80004726:	6125                	addi	sp,sp,96
    80004728:	8082                	ret
      if(i == 0)
    8000472a:	fc099ce3          	bnez	s3,80004702 <piperead+0xc2>
        i = -1;
    8000472e:	89aa                	mv	s3,a0
    80004730:	bfc9                	j	80004702 <piperead+0xc2>

0000000080004732 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004732:	1141                	addi	sp,sp,-16
    80004734:	e406                	sd	ra,8(sp)
    80004736:	e022                	sd	s0,0(sp)
    80004738:	0800                	addi	s0,sp,16
    8000473a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000473c:	0035151b          	slliw	a0,a0,0x3
    80004740:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004742:	8b89                	andi	a5,a5,2
    80004744:	c399                	beqz	a5,8000474a <flags2perm+0x18>
      perm |= PTE_W;
    80004746:	00456513          	ori	a0,a0,4
    return perm;
}
    8000474a:	60a2                	ld	ra,8(sp)
    8000474c:	6402                	ld	s0,0(sp)
    8000474e:	0141                	addi	sp,sp,16
    80004750:	8082                	ret

0000000080004752 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004752:	de010113          	addi	sp,sp,-544
    80004756:	20113c23          	sd	ra,536(sp)
    8000475a:	20813823          	sd	s0,528(sp)
    8000475e:	20913423          	sd	s1,520(sp)
    80004762:	21213023          	sd	s2,512(sp)
    80004766:	1400                	addi	s0,sp,544
    80004768:	892a                	mv	s2,a0
    8000476a:	dea43823          	sd	a0,-528(s0)
    8000476e:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004772:	9bcfd0ef          	jal	8000192e <myproc>
    80004776:	84aa                	mv	s1,a0

  begin_op();
    80004778:	d6aff0ef          	jal	80003ce2 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    8000477c:	854a                	mv	a0,s2
    8000477e:	b86ff0ef          	jal	80003b04 <namei>
    80004782:	cd21                	beqz	a0,800047da <kexec+0x88>
    80004784:	fbd2                	sd	s4,496(sp)
    80004786:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004788:	b4ffe0ef          	jal	800032d6 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000478c:	04000713          	li	a4,64
    80004790:	4681                	li	a3,0
    80004792:	e5040613          	addi	a2,s0,-432
    80004796:	4581                	li	a1,0
    80004798:	8552                	mv	a0,s4
    8000479a:	ecffe0ef          	jal	80003668 <readi>
    8000479e:	04000793          	li	a5,64
    800047a2:	00f51a63          	bne	a0,a5,800047b6 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800047a6:	e5042703          	lw	a4,-432(s0)
    800047aa:	464c47b7          	lui	a5,0x464c4
    800047ae:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800047b2:	02f70863          	beq	a4,a5,800047e2 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800047b6:	8552                	mv	a0,s4
    800047b8:	d2bfe0ef          	jal	800034e2 <iunlockput>
    end_op();
    800047bc:	d96ff0ef          	jal	80003d52 <end_op>
  }
  return -1;
    800047c0:	557d                	li	a0,-1
    800047c2:	7a5e                	ld	s4,496(sp)
}
    800047c4:	21813083          	ld	ra,536(sp)
    800047c8:	21013403          	ld	s0,528(sp)
    800047cc:	20813483          	ld	s1,520(sp)
    800047d0:	20013903          	ld	s2,512(sp)
    800047d4:	22010113          	addi	sp,sp,544
    800047d8:	8082                	ret
    end_op();
    800047da:	d78ff0ef          	jal	80003d52 <end_op>
    return -1;
    800047de:	557d                	li	a0,-1
    800047e0:	b7d5                	j	800047c4 <kexec+0x72>
    800047e2:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800047e4:	8526                	mv	a0,s1
    800047e6:	a52fd0ef          	jal	80001a38 <proc_pagetable>
    800047ea:	8b2a                	mv	s6,a0
    800047ec:	26050f63          	beqz	a0,80004a6a <kexec+0x318>
    800047f0:	ffce                	sd	s3,504(sp)
    800047f2:	f7d6                	sd	s5,488(sp)
    800047f4:	efde                	sd	s7,472(sp)
    800047f6:	ebe2                	sd	s8,464(sp)
    800047f8:	e7e6                	sd	s9,456(sp)
    800047fa:	e3ea                	sd	s10,448(sp)
    800047fc:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047fe:	e8845783          	lhu	a5,-376(s0)
    80004802:	0e078963          	beqz	a5,800048f4 <kexec+0x1a2>
    80004806:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000480a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000480c:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000480e:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004812:	6c85                	lui	s9,0x1
    80004814:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004818:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000481c:	6a85                	lui	s5,0x1
    8000481e:	a085                	j	8000487e <kexec+0x12c>
      panic("loadseg: address should exist");
    80004820:	00003517          	auipc	a0,0x3
    80004824:	d8050513          	addi	a0,a0,-640 # 800075a0 <etext+0x5a0>
    80004828:	ffdfb0ef          	jal	80000824 <panic>
    if(sz - i < PGSIZE)
    8000482c:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000482e:	874a                	mv	a4,s2
    80004830:	009b86bb          	addw	a3,s7,s1
    80004834:	4581                	li	a1,0
    80004836:	8552                	mv	a0,s4
    80004838:	e31fe0ef          	jal	80003668 <readi>
    8000483c:	22a91b63          	bne	s2,a0,80004a72 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    80004840:	009a84bb          	addw	s1,s5,s1
    80004844:	0334f263          	bgeu	s1,s3,80004868 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004848:	02049593          	slli	a1,s1,0x20
    8000484c:	9181                	srli	a1,a1,0x20
    8000484e:	95e2                	add	a1,a1,s8
    80004850:	855a                	mv	a0,s6
    80004852:	fd4fc0ef          	jal	80001026 <walkaddr>
    80004856:	862a                	mv	a2,a0
    if(pa == 0)
    80004858:	d561                	beqz	a0,80004820 <kexec+0xce>
    if(sz - i < PGSIZE)
    8000485a:	409987bb          	subw	a5,s3,s1
    8000485e:	893e                	mv	s2,a5
    80004860:	fcfcf6e3          	bgeu	s9,a5,8000482c <kexec+0xda>
    80004864:	8956                	mv	s2,s5
    80004866:	b7d9                	j	8000482c <kexec+0xda>
    sz = sz1;
    80004868:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000486c:	2d05                	addiw	s10,s10,1
    8000486e:	e0843783          	ld	a5,-504(s0)
    80004872:	0387869b          	addiw	a3,a5,56
    80004876:	e8845783          	lhu	a5,-376(s0)
    8000487a:	06fd5e63          	bge	s10,a5,800048f6 <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000487e:	e0d43423          	sd	a3,-504(s0)
    80004882:	876e                	mv	a4,s11
    80004884:	e1840613          	addi	a2,s0,-488
    80004888:	4581                	li	a1,0
    8000488a:	8552                	mv	a0,s4
    8000488c:	dddfe0ef          	jal	80003668 <readi>
    80004890:	1db51f63          	bne	a0,s11,80004a6e <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    80004894:	e1842783          	lw	a5,-488(s0)
    80004898:	4705                	li	a4,1
    8000489a:	fce799e3          	bne	a5,a4,8000486c <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    8000489e:	e4043483          	ld	s1,-448(s0)
    800048a2:	e3843783          	ld	a5,-456(s0)
    800048a6:	1ef4e463          	bltu	s1,a5,80004a8e <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800048aa:	e2843783          	ld	a5,-472(s0)
    800048ae:	94be                	add	s1,s1,a5
    800048b0:	1ef4e263          	bltu	s1,a5,80004a94 <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    800048b4:	de843703          	ld	a4,-536(s0)
    800048b8:	8ff9                	and	a5,a5,a4
    800048ba:	1e079063          	bnez	a5,80004a9a <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800048be:	e1c42503          	lw	a0,-484(s0)
    800048c2:	e71ff0ef          	jal	80004732 <flags2perm>
    800048c6:	86aa                	mv	a3,a0
    800048c8:	8626                	mv	a2,s1
    800048ca:	85ca                	mv	a1,s2
    800048cc:	855a                	mv	a0,s6
    800048ce:	a2ffc0ef          	jal	800012fc <uvmalloc>
    800048d2:	dea43c23          	sd	a0,-520(s0)
    800048d6:	1c050563          	beqz	a0,80004aa0 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800048da:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800048de:	00098863          	beqz	s3,800048ee <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800048e2:	e2843c03          	ld	s8,-472(s0)
    800048e6:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800048ea:	4481                	li	s1,0
    800048ec:	bfb1                	j	80004848 <kexec+0xf6>
    sz = sz1;
    800048ee:	df843903          	ld	s2,-520(s0)
    800048f2:	bfad                	j	8000486c <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800048f4:	4901                	li	s2,0
  iunlockput(ip);
    800048f6:	8552                	mv	a0,s4
    800048f8:	bebfe0ef          	jal	800034e2 <iunlockput>
  end_op();
    800048fc:	c56ff0ef          	jal	80003d52 <end_op>
  p = myproc();
    80004900:	82efd0ef          	jal	8000192e <myproc>
    80004904:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004906:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    8000490a:	6985                	lui	s3,0x1
    8000490c:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000490e:	99ca                	add	s3,s3,s2
    80004910:	77fd                	lui	a5,0xfffff
    80004912:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004916:	4691                	li	a3,4
    80004918:	6609                	lui	a2,0x2
    8000491a:	964e                	add	a2,a2,s3
    8000491c:	85ce                	mv	a1,s3
    8000491e:	855a                	mv	a0,s6
    80004920:	9ddfc0ef          	jal	800012fc <uvmalloc>
    80004924:	8a2a                	mv	s4,a0
    80004926:	e105                	bnez	a0,80004946 <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004928:	85ce                	mv	a1,s3
    8000492a:	855a                	mv	a0,s6
    8000492c:	990fd0ef          	jal	80001abc <proc_freepagetable>
  return -1;
    80004930:	557d                	li	a0,-1
    80004932:	79fe                	ld	s3,504(sp)
    80004934:	7a5e                	ld	s4,496(sp)
    80004936:	7abe                	ld	s5,488(sp)
    80004938:	7b1e                	ld	s6,480(sp)
    8000493a:	6bfe                	ld	s7,472(sp)
    8000493c:	6c5e                	ld	s8,464(sp)
    8000493e:	6cbe                	ld	s9,456(sp)
    80004940:	6d1e                	ld	s10,448(sp)
    80004942:	7dfa                	ld	s11,440(sp)
    80004944:	b541                	j	800047c4 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004946:	75f9                	lui	a1,0xffffe
    80004948:	95aa                	add	a1,a1,a0
    8000494a:	855a                	mv	a0,s6
    8000494c:	b83fc0ef          	jal	800014ce <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004950:	800a0b93          	addi	s7,s4,-2048
    80004954:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80004958:	e0043783          	ld	a5,-512(s0)
    8000495c:	6388                	ld	a0,0(a5)
  sp = sz;
    8000495e:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004960:	4481                	li	s1,0
    ustack[argc] = sp;
    80004962:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004966:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    8000496a:	cd21                	beqz	a0,800049c2 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    8000496c:	d16fc0ef          	jal	80000e82 <strlen>
    80004970:	0015079b          	addiw	a5,a0,1
    80004974:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004978:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000497c:	13796563          	bltu	s2,s7,80004aa6 <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004980:	e0043d83          	ld	s11,-512(s0)
    80004984:	000db983          	ld	s3,0(s11)
    80004988:	854e                	mv	a0,s3
    8000498a:	cf8fc0ef          	jal	80000e82 <strlen>
    8000498e:	0015069b          	addiw	a3,a0,1
    80004992:	864e                	mv	a2,s3
    80004994:	85ca                	mv	a1,s2
    80004996:	855a                	mv	a0,s6
    80004998:	cbdfc0ef          	jal	80001654 <copyout>
    8000499c:	10054763          	bltz	a0,80004aaa <kexec+0x358>
    ustack[argc] = sp;
    800049a0:	00349793          	slli	a5,s1,0x3
    800049a4:	97e6                	add	a5,a5,s9
    800049a6:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb8b8>
  for(argc = 0; argv[argc]; argc++) {
    800049aa:	0485                	addi	s1,s1,1
    800049ac:	008d8793          	addi	a5,s11,8
    800049b0:	e0f43023          	sd	a5,-512(s0)
    800049b4:	008db503          	ld	a0,8(s11)
    800049b8:	c509                	beqz	a0,800049c2 <kexec+0x270>
    if(argc >= MAXARG)
    800049ba:	fb8499e3          	bne	s1,s8,8000496c <kexec+0x21a>
  sz = sz1;
    800049be:	89d2                	mv	s3,s4
    800049c0:	b7a5                	j	80004928 <kexec+0x1d6>
  ustack[argc] = 0;
    800049c2:	00349793          	slli	a5,s1,0x3
    800049c6:	f9078793          	addi	a5,a5,-112
    800049ca:	97a2                	add	a5,a5,s0
    800049cc:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800049d0:	00349693          	slli	a3,s1,0x3
    800049d4:	06a1                	addi	a3,a3,8
    800049d6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800049da:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800049de:	89d2                	mv	s3,s4
  if(sp < stackbase)
    800049e0:	f57964e3          	bltu	s2,s7,80004928 <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800049e4:	e9040613          	addi	a2,s0,-368
    800049e8:	85ca                	mv	a1,s2
    800049ea:	855a                	mv	a0,s6
    800049ec:	c69fc0ef          	jal	80001654 <copyout>
    800049f0:	f2054ce3          	bltz	a0,80004928 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    800049f4:	060ab783          	ld	a5,96(s5) # 1060 <_entry-0x7fffefa0>
    800049f8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800049fc:	df043783          	ld	a5,-528(s0)
    80004a00:	0007c703          	lbu	a4,0(a5)
    80004a04:	cf11                	beqz	a4,80004a20 <kexec+0x2ce>
    80004a06:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004a08:	02f00693          	li	a3,47
    80004a0c:	a029                	j	80004a16 <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80004a0e:	0785                	addi	a5,a5,1
    80004a10:	fff7c703          	lbu	a4,-1(a5)
    80004a14:	c711                	beqz	a4,80004a20 <kexec+0x2ce>
    if(*s == '/')
    80004a16:	fed71ce3          	bne	a4,a3,80004a0e <kexec+0x2bc>
      last = s+1;
    80004a1a:	def43823          	sd	a5,-528(s0)
    80004a1e:	bfc5                	j	80004a0e <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004a20:	4641                	li	a2,16
    80004a22:	df043583          	ld	a1,-528(s0)
    80004a26:	160a8513          	addi	a0,s5,352
    80004a2a:	c22fc0ef          	jal	80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    80004a2e:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80004a32:	056abc23          	sd	s6,88(s5)
  p->sz = sz;
    80004a36:	054ab823          	sd	s4,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004a3a:	060ab783          	ld	a5,96(s5)
    80004a3e:	e6843703          	ld	a4,-408(s0)
    80004a42:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004a44:	060ab783          	ld	a5,96(s5)
    80004a48:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004a4c:	85ea                	mv	a1,s10
    80004a4e:	86efd0ef          	jal	80001abc <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004a52:	0004851b          	sext.w	a0,s1
    80004a56:	79fe                	ld	s3,504(sp)
    80004a58:	7a5e                	ld	s4,496(sp)
    80004a5a:	7abe                	ld	s5,488(sp)
    80004a5c:	7b1e                	ld	s6,480(sp)
    80004a5e:	6bfe                	ld	s7,472(sp)
    80004a60:	6c5e                	ld	s8,464(sp)
    80004a62:	6cbe                	ld	s9,456(sp)
    80004a64:	6d1e                	ld	s10,448(sp)
    80004a66:	7dfa                	ld	s11,440(sp)
    80004a68:	bbb1                	j	800047c4 <kexec+0x72>
    80004a6a:	7b1e                	ld	s6,480(sp)
    80004a6c:	b3a9                	j	800047b6 <kexec+0x64>
    80004a6e:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004a72:	df843583          	ld	a1,-520(s0)
    80004a76:	855a                	mv	a0,s6
    80004a78:	844fd0ef          	jal	80001abc <proc_freepagetable>
  if(ip){
    80004a7c:	79fe                	ld	s3,504(sp)
    80004a7e:	7abe                	ld	s5,488(sp)
    80004a80:	7b1e                	ld	s6,480(sp)
    80004a82:	6bfe                	ld	s7,472(sp)
    80004a84:	6c5e                	ld	s8,464(sp)
    80004a86:	6cbe                	ld	s9,456(sp)
    80004a88:	6d1e                	ld	s10,448(sp)
    80004a8a:	7dfa                	ld	s11,440(sp)
    80004a8c:	b32d                	j	800047b6 <kexec+0x64>
    80004a8e:	df243c23          	sd	s2,-520(s0)
    80004a92:	b7c5                	j	80004a72 <kexec+0x320>
    80004a94:	df243c23          	sd	s2,-520(s0)
    80004a98:	bfe9                	j	80004a72 <kexec+0x320>
    80004a9a:	df243c23          	sd	s2,-520(s0)
    80004a9e:	bfd1                	j	80004a72 <kexec+0x320>
    80004aa0:	df243c23          	sd	s2,-520(s0)
    80004aa4:	b7f9                	j	80004a72 <kexec+0x320>
  sz = sz1;
    80004aa6:	89d2                	mv	s3,s4
    80004aa8:	b541                	j	80004928 <kexec+0x1d6>
    80004aaa:	89d2                	mv	s3,s4
    80004aac:	bdb5                	j	80004928 <kexec+0x1d6>

0000000080004aae <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004aae:	7179                	addi	sp,sp,-48
    80004ab0:	f406                	sd	ra,40(sp)
    80004ab2:	f022                	sd	s0,32(sp)
    80004ab4:	ec26                	sd	s1,24(sp)
    80004ab6:	e84a                	sd	s2,16(sp)
    80004ab8:	1800                	addi	s0,sp,48
    80004aba:	892e                	mv	s2,a1
    80004abc:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004abe:	fdc40593          	addi	a1,s0,-36
    80004ac2:	e4bfd0ef          	jal	8000290c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004ac6:	fdc42703          	lw	a4,-36(s0)
    80004aca:	47bd                	li	a5,15
    80004acc:	02e7ea63          	bltu	a5,a4,80004b00 <argfd+0x52>
    80004ad0:	e5ffc0ef          	jal	8000192e <myproc>
    80004ad4:	fdc42703          	lw	a4,-36(s0)
    80004ad8:	00371793          	slli	a5,a4,0x3
    80004adc:	0d078793          	addi	a5,a5,208
    80004ae0:	953e                	add	a0,a0,a5
    80004ae2:	651c                	ld	a5,8(a0)
    80004ae4:	c385                	beqz	a5,80004b04 <argfd+0x56>
    return -1;
  if(pfd)
    80004ae6:	00090463          	beqz	s2,80004aee <argfd+0x40>
    *pfd = fd;
    80004aea:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004aee:	4501                	li	a0,0
  if(pf)
    80004af0:	c091                	beqz	s1,80004af4 <argfd+0x46>
    *pf = f;
    80004af2:	e09c                	sd	a5,0(s1)
}
    80004af4:	70a2                	ld	ra,40(sp)
    80004af6:	7402                	ld	s0,32(sp)
    80004af8:	64e2                	ld	s1,24(sp)
    80004afa:	6942                	ld	s2,16(sp)
    80004afc:	6145                	addi	sp,sp,48
    80004afe:	8082                	ret
    return -1;
    80004b00:	557d                	li	a0,-1
    80004b02:	bfcd                	j	80004af4 <argfd+0x46>
    80004b04:	557d                	li	a0,-1
    80004b06:	b7fd                	j	80004af4 <argfd+0x46>

0000000080004b08 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004b08:	1101                	addi	sp,sp,-32
    80004b0a:	ec06                	sd	ra,24(sp)
    80004b0c:	e822                	sd	s0,16(sp)
    80004b0e:	e426                	sd	s1,8(sp)
    80004b10:	1000                	addi	s0,sp,32
    80004b12:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004b14:	e1bfc0ef          	jal	8000192e <myproc>
    80004b18:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004b1a:	0d850793          	addi	a5,a0,216
    80004b1e:	4501                	li	a0,0
    80004b20:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004b22:	6398                	ld	a4,0(a5)
    80004b24:	cb19                	beqz	a4,80004b3a <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004b26:	2505                	addiw	a0,a0,1
    80004b28:	07a1                	addi	a5,a5,8
    80004b2a:	fed51ce3          	bne	a0,a3,80004b22 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004b2e:	557d                	li	a0,-1
}
    80004b30:	60e2                	ld	ra,24(sp)
    80004b32:	6442                	ld	s0,16(sp)
    80004b34:	64a2                	ld	s1,8(sp)
    80004b36:	6105                	addi	sp,sp,32
    80004b38:	8082                	ret
      p->ofile[fd] = f;
    80004b3a:	00351793          	slli	a5,a0,0x3
    80004b3e:	0d078793          	addi	a5,a5,208
    80004b42:	963e                	add	a2,a2,a5
    80004b44:	e604                	sd	s1,8(a2)
      return fd;
    80004b46:	b7ed                	j	80004b30 <fdalloc+0x28>

0000000080004b48 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004b48:	715d                	addi	sp,sp,-80
    80004b4a:	e486                	sd	ra,72(sp)
    80004b4c:	e0a2                	sd	s0,64(sp)
    80004b4e:	fc26                	sd	s1,56(sp)
    80004b50:	f84a                	sd	s2,48(sp)
    80004b52:	f44e                	sd	s3,40(sp)
    80004b54:	f052                	sd	s4,32(sp)
    80004b56:	ec56                	sd	s5,24(sp)
    80004b58:	e85a                	sd	s6,16(sp)
    80004b5a:	0880                	addi	s0,sp,80
    80004b5c:	892e                	mv	s2,a1
    80004b5e:	8a2e                	mv	s4,a1
    80004b60:	8ab2                	mv	s5,a2
    80004b62:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004b64:	fb040593          	addi	a1,s0,-80
    80004b68:	fb7fe0ef          	jal	80003b1e <nameiparent>
    80004b6c:	84aa                	mv	s1,a0
    80004b6e:	10050763          	beqz	a0,80004c7c <create+0x134>
    return 0;

  ilock(dp);
    80004b72:	f64fe0ef          	jal	800032d6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004b76:	4601                	li	a2,0
    80004b78:	fb040593          	addi	a1,s0,-80
    80004b7c:	8526                	mv	a0,s1
    80004b7e:	cf3fe0ef          	jal	80003870 <dirlookup>
    80004b82:	89aa                	mv	s3,a0
    80004b84:	c131                	beqz	a0,80004bc8 <create+0x80>
    iunlockput(dp);
    80004b86:	8526                	mv	a0,s1
    80004b88:	95bfe0ef          	jal	800034e2 <iunlockput>
    ilock(ip);
    80004b8c:	854e                	mv	a0,s3
    80004b8e:	f48fe0ef          	jal	800032d6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004b92:	4789                	li	a5,2
    80004b94:	02f91563          	bne	s2,a5,80004bbe <create+0x76>
    80004b98:	0449d783          	lhu	a5,68(s3)
    80004b9c:	37f9                	addiw	a5,a5,-2
    80004b9e:	17c2                	slli	a5,a5,0x30
    80004ba0:	93c1                	srli	a5,a5,0x30
    80004ba2:	4705                	li	a4,1
    80004ba4:	00f76d63          	bltu	a4,a5,80004bbe <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004ba8:	854e                	mv	a0,s3
    80004baa:	60a6                	ld	ra,72(sp)
    80004bac:	6406                	ld	s0,64(sp)
    80004bae:	74e2                	ld	s1,56(sp)
    80004bb0:	7942                	ld	s2,48(sp)
    80004bb2:	79a2                	ld	s3,40(sp)
    80004bb4:	7a02                	ld	s4,32(sp)
    80004bb6:	6ae2                	ld	s5,24(sp)
    80004bb8:	6b42                	ld	s6,16(sp)
    80004bba:	6161                	addi	sp,sp,80
    80004bbc:	8082                	ret
    iunlockput(ip);
    80004bbe:	854e                	mv	a0,s3
    80004bc0:	923fe0ef          	jal	800034e2 <iunlockput>
    return 0;
    80004bc4:	4981                	li	s3,0
    80004bc6:	b7cd                	j	80004ba8 <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004bc8:	85ca                	mv	a1,s2
    80004bca:	4088                	lw	a0,0(s1)
    80004bcc:	d9afe0ef          	jal	80003166 <ialloc>
    80004bd0:	892a                	mv	s2,a0
    80004bd2:	cd15                	beqz	a0,80004c0e <create+0xc6>
  ilock(ip);
    80004bd4:	f02fe0ef          	jal	800032d6 <ilock>
  ip->major = major;
    80004bd8:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80004bdc:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80004be0:	4785                	li	a5,1
    80004be2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004be6:	854a                	mv	a0,s2
    80004be8:	e3afe0ef          	jal	80003222 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004bec:	4705                	li	a4,1
    80004bee:	02ea0463          	beq	s4,a4,80004c16 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004bf2:	00492603          	lw	a2,4(s2)
    80004bf6:	fb040593          	addi	a1,s0,-80
    80004bfa:	8526                	mv	a0,s1
    80004bfc:	e5ffe0ef          	jal	80003a5a <dirlink>
    80004c00:	06054263          	bltz	a0,80004c64 <create+0x11c>
  iunlockput(dp);
    80004c04:	8526                	mv	a0,s1
    80004c06:	8ddfe0ef          	jal	800034e2 <iunlockput>
  return ip;
    80004c0a:	89ca                	mv	s3,s2
    80004c0c:	bf71                	j	80004ba8 <create+0x60>
    iunlockput(dp);
    80004c0e:	8526                	mv	a0,s1
    80004c10:	8d3fe0ef          	jal	800034e2 <iunlockput>
    return 0;
    80004c14:	bf51                	j	80004ba8 <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004c16:	00492603          	lw	a2,4(s2)
    80004c1a:	00003597          	auipc	a1,0x3
    80004c1e:	9a658593          	addi	a1,a1,-1626 # 800075c0 <etext+0x5c0>
    80004c22:	854a                	mv	a0,s2
    80004c24:	e37fe0ef          	jal	80003a5a <dirlink>
    80004c28:	02054e63          	bltz	a0,80004c64 <create+0x11c>
    80004c2c:	40d0                	lw	a2,4(s1)
    80004c2e:	00003597          	auipc	a1,0x3
    80004c32:	99a58593          	addi	a1,a1,-1638 # 800075c8 <etext+0x5c8>
    80004c36:	854a                	mv	a0,s2
    80004c38:	e23fe0ef          	jal	80003a5a <dirlink>
    80004c3c:	02054463          	bltz	a0,80004c64 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004c40:	00492603          	lw	a2,4(s2)
    80004c44:	fb040593          	addi	a1,s0,-80
    80004c48:	8526                	mv	a0,s1
    80004c4a:	e11fe0ef          	jal	80003a5a <dirlink>
    80004c4e:	00054b63          	bltz	a0,80004c64 <create+0x11c>
    dp->nlink++;  // for ".."
    80004c52:	04a4d783          	lhu	a5,74(s1)
    80004c56:	2785                	addiw	a5,a5,1
    80004c58:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004c5c:	8526                	mv	a0,s1
    80004c5e:	dc4fe0ef          	jal	80003222 <iupdate>
    80004c62:	b74d                	j	80004c04 <create+0xbc>
  ip->nlink = 0;
    80004c64:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80004c68:	854a                	mv	a0,s2
    80004c6a:	db8fe0ef          	jal	80003222 <iupdate>
  iunlockput(ip);
    80004c6e:	854a                	mv	a0,s2
    80004c70:	873fe0ef          	jal	800034e2 <iunlockput>
  iunlockput(dp);
    80004c74:	8526                	mv	a0,s1
    80004c76:	86dfe0ef          	jal	800034e2 <iunlockput>
  return 0;
    80004c7a:	b73d                	j	80004ba8 <create+0x60>
    return 0;
    80004c7c:	89aa                	mv	s3,a0
    80004c7e:	b72d                	j	80004ba8 <create+0x60>

0000000080004c80 <sys_dup>:
{
    80004c80:	7179                	addi	sp,sp,-48
    80004c82:	f406                	sd	ra,40(sp)
    80004c84:	f022                	sd	s0,32(sp)
    80004c86:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004c88:	fd840613          	addi	a2,s0,-40
    80004c8c:	4581                	li	a1,0
    80004c8e:	4501                	li	a0,0
    80004c90:	e1fff0ef          	jal	80004aae <argfd>
    return -1;
    80004c94:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004c96:	02054363          	bltz	a0,80004cbc <sys_dup+0x3c>
    80004c9a:	ec26                	sd	s1,24(sp)
    80004c9c:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004c9e:	fd843483          	ld	s1,-40(s0)
    80004ca2:	8526                	mv	a0,s1
    80004ca4:	e65ff0ef          	jal	80004b08 <fdalloc>
    80004ca8:	892a                	mv	s2,a0
    return -1;
    80004caa:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004cac:	00054d63          	bltz	a0,80004cc6 <sys_dup+0x46>
  filedup(f);
    80004cb0:	8526                	mv	a0,s1
    80004cb2:	c0eff0ef          	jal	800040c0 <filedup>
  return fd;
    80004cb6:	87ca                	mv	a5,s2
    80004cb8:	64e2                	ld	s1,24(sp)
    80004cba:	6942                	ld	s2,16(sp)
}
    80004cbc:	853e                	mv	a0,a5
    80004cbe:	70a2                	ld	ra,40(sp)
    80004cc0:	7402                	ld	s0,32(sp)
    80004cc2:	6145                	addi	sp,sp,48
    80004cc4:	8082                	ret
    80004cc6:	64e2                	ld	s1,24(sp)
    80004cc8:	6942                	ld	s2,16(sp)
    80004cca:	bfcd                	j	80004cbc <sys_dup+0x3c>

0000000080004ccc <sys_read>:
{
    80004ccc:	7179                	addi	sp,sp,-48
    80004cce:	f406                	sd	ra,40(sp)
    80004cd0:	f022                	sd	s0,32(sp)
    80004cd2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004cd4:	fd840593          	addi	a1,s0,-40
    80004cd8:	4505                	li	a0,1
    80004cda:	c4ffd0ef          	jal	80002928 <argaddr>
  argint(2, &n);
    80004cde:	fe440593          	addi	a1,s0,-28
    80004ce2:	4509                	li	a0,2
    80004ce4:	c29fd0ef          	jal	8000290c <argint>
  if(argfd(0, 0, &f) < 0)
    80004ce8:	fe840613          	addi	a2,s0,-24
    80004cec:	4581                	li	a1,0
    80004cee:	4501                	li	a0,0
    80004cf0:	dbfff0ef          	jal	80004aae <argfd>
    80004cf4:	87aa                	mv	a5,a0
    return -1;
    80004cf6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004cf8:	0007ca63          	bltz	a5,80004d0c <sys_read+0x40>
  return fileread(f, p, n);
    80004cfc:	fe442603          	lw	a2,-28(s0)
    80004d00:	fd843583          	ld	a1,-40(s0)
    80004d04:	fe843503          	ld	a0,-24(s0)
    80004d08:	d22ff0ef          	jal	8000422a <fileread>
}
    80004d0c:	70a2                	ld	ra,40(sp)
    80004d0e:	7402                	ld	s0,32(sp)
    80004d10:	6145                	addi	sp,sp,48
    80004d12:	8082                	ret

0000000080004d14 <sys_write>:
{
    80004d14:	7179                	addi	sp,sp,-48
    80004d16:	f406                	sd	ra,40(sp)
    80004d18:	f022                	sd	s0,32(sp)
    80004d1a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004d1c:	fd840593          	addi	a1,s0,-40
    80004d20:	4505                	li	a0,1
    80004d22:	c07fd0ef          	jal	80002928 <argaddr>
  argint(2, &n);
    80004d26:	fe440593          	addi	a1,s0,-28
    80004d2a:	4509                	li	a0,2
    80004d2c:	be1fd0ef          	jal	8000290c <argint>
  if(argfd(0, 0, &f) < 0)
    80004d30:	fe840613          	addi	a2,s0,-24
    80004d34:	4581                	li	a1,0
    80004d36:	4501                	li	a0,0
    80004d38:	d77ff0ef          	jal	80004aae <argfd>
    80004d3c:	87aa                	mv	a5,a0
    return -1;
    80004d3e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d40:	0007ca63          	bltz	a5,80004d54 <sys_write+0x40>
  return filewrite(f, p, n);
    80004d44:	fe442603          	lw	a2,-28(s0)
    80004d48:	fd843583          	ld	a1,-40(s0)
    80004d4c:	fe843503          	ld	a0,-24(s0)
    80004d50:	d9eff0ef          	jal	800042ee <filewrite>
}
    80004d54:	70a2                	ld	ra,40(sp)
    80004d56:	7402                	ld	s0,32(sp)
    80004d58:	6145                	addi	sp,sp,48
    80004d5a:	8082                	ret

0000000080004d5c <sys_close>:
{
    80004d5c:	1101                	addi	sp,sp,-32
    80004d5e:	ec06                	sd	ra,24(sp)
    80004d60:	e822                	sd	s0,16(sp)
    80004d62:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004d64:	fe040613          	addi	a2,s0,-32
    80004d68:	fec40593          	addi	a1,s0,-20
    80004d6c:	4501                	li	a0,0
    80004d6e:	d41ff0ef          	jal	80004aae <argfd>
    return -1;
    80004d72:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004d74:	02054163          	bltz	a0,80004d96 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004d78:	bb7fc0ef          	jal	8000192e <myproc>
    80004d7c:	fec42783          	lw	a5,-20(s0)
    80004d80:	078e                	slli	a5,a5,0x3
    80004d82:	0d078793          	addi	a5,a5,208
    80004d86:	953e                	add	a0,a0,a5
    80004d88:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80004d8c:	fe043503          	ld	a0,-32(s0)
    80004d90:	b76ff0ef          	jal	80004106 <fileclose>
  return 0;
    80004d94:	4781                	li	a5,0
}
    80004d96:	853e                	mv	a0,a5
    80004d98:	60e2                	ld	ra,24(sp)
    80004d9a:	6442                	ld	s0,16(sp)
    80004d9c:	6105                	addi	sp,sp,32
    80004d9e:	8082                	ret

0000000080004da0 <sys_fstat>:
{
    80004da0:	1101                	addi	sp,sp,-32
    80004da2:	ec06                	sd	ra,24(sp)
    80004da4:	e822                	sd	s0,16(sp)
    80004da6:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004da8:	fe040593          	addi	a1,s0,-32
    80004dac:	4505                	li	a0,1
    80004dae:	b7bfd0ef          	jal	80002928 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004db2:	fe840613          	addi	a2,s0,-24
    80004db6:	4581                	li	a1,0
    80004db8:	4501                	li	a0,0
    80004dba:	cf5ff0ef          	jal	80004aae <argfd>
    80004dbe:	87aa                	mv	a5,a0
    return -1;
    80004dc0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004dc2:	0007c863          	bltz	a5,80004dd2 <sys_fstat+0x32>
  return filestat(f, st);
    80004dc6:	fe043583          	ld	a1,-32(s0)
    80004dca:	fe843503          	ld	a0,-24(s0)
    80004dce:	bfaff0ef          	jal	800041c8 <filestat>
}
    80004dd2:	60e2                	ld	ra,24(sp)
    80004dd4:	6442                	ld	s0,16(sp)
    80004dd6:	6105                	addi	sp,sp,32
    80004dd8:	8082                	ret

0000000080004dda <sys_link>:
{
    80004dda:	7169                	addi	sp,sp,-304
    80004ddc:	f606                	sd	ra,296(sp)
    80004dde:	f222                	sd	s0,288(sp)
    80004de0:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004de2:	08000613          	li	a2,128
    80004de6:	ed040593          	addi	a1,s0,-304
    80004dea:	4501                	li	a0,0
    80004dec:	b59fd0ef          	jal	80002944 <argstr>
    return -1;
    80004df0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004df2:	0c054e63          	bltz	a0,80004ece <sys_link+0xf4>
    80004df6:	08000613          	li	a2,128
    80004dfa:	f5040593          	addi	a1,s0,-176
    80004dfe:	4505                	li	a0,1
    80004e00:	b45fd0ef          	jal	80002944 <argstr>
    return -1;
    80004e04:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e06:	0c054463          	bltz	a0,80004ece <sys_link+0xf4>
    80004e0a:	ee26                	sd	s1,280(sp)
  begin_op();
    80004e0c:	ed7fe0ef          	jal	80003ce2 <begin_op>
  if((ip = namei(old)) == 0){
    80004e10:	ed040513          	addi	a0,s0,-304
    80004e14:	cf1fe0ef          	jal	80003b04 <namei>
    80004e18:	84aa                	mv	s1,a0
    80004e1a:	c53d                	beqz	a0,80004e88 <sys_link+0xae>
  ilock(ip);
    80004e1c:	cbafe0ef          	jal	800032d6 <ilock>
  if(ip->type == T_DIR){
    80004e20:	04449703          	lh	a4,68(s1)
    80004e24:	4785                	li	a5,1
    80004e26:	06f70663          	beq	a4,a5,80004e92 <sys_link+0xb8>
    80004e2a:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004e2c:	04a4d783          	lhu	a5,74(s1)
    80004e30:	2785                	addiw	a5,a5,1
    80004e32:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e36:	8526                	mv	a0,s1
    80004e38:	beafe0ef          	jal	80003222 <iupdate>
  iunlock(ip);
    80004e3c:	8526                	mv	a0,s1
    80004e3e:	d46fe0ef          	jal	80003384 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004e42:	fd040593          	addi	a1,s0,-48
    80004e46:	f5040513          	addi	a0,s0,-176
    80004e4a:	cd5fe0ef          	jal	80003b1e <nameiparent>
    80004e4e:	892a                	mv	s2,a0
    80004e50:	cd21                	beqz	a0,80004ea8 <sys_link+0xce>
  ilock(dp);
    80004e52:	c84fe0ef          	jal	800032d6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004e56:	854a                	mv	a0,s2
    80004e58:	00092703          	lw	a4,0(s2)
    80004e5c:	409c                	lw	a5,0(s1)
    80004e5e:	04f71263          	bne	a4,a5,80004ea2 <sys_link+0xc8>
    80004e62:	40d0                	lw	a2,4(s1)
    80004e64:	fd040593          	addi	a1,s0,-48
    80004e68:	bf3fe0ef          	jal	80003a5a <dirlink>
    80004e6c:	02054b63          	bltz	a0,80004ea2 <sys_link+0xc8>
  iunlockput(dp);
    80004e70:	854a                	mv	a0,s2
    80004e72:	e70fe0ef          	jal	800034e2 <iunlockput>
  iput(ip);
    80004e76:	8526                	mv	a0,s1
    80004e78:	de0fe0ef          	jal	80003458 <iput>
  end_op();
    80004e7c:	ed7fe0ef          	jal	80003d52 <end_op>
  return 0;
    80004e80:	4781                	li	a5,0
    80004e82:	64f2                	ld	s1,280(sp)
    80004e84:	6952                	ld	s2,272(sp)
    80004e86:	a0a1                	j	80004ece <sys_link+0xf4>
    end_op();
    80004e88:	ecbfe0ef          	jal	80003d52 <end_op>
    return -1;
    80004e8c:	57fd                	li	a5,-1
    80004e8e:	64f2                	ld	s1,280(sp)
    80004e90:	a83d                	j	80004ece <sys_link+0xf4>
    iunlockput(ip);
    80004e92:	8526                	mv	a0,s1
    80004e94:	e4efe0ef          	jal	800034e2 <iunlockput>
    end_op();
    80004e98:	ebbfe0ef          	jal	80003d52 <end_op>
    return -1;
    80004e9c:	57fd                	li	a5,-1
    80004e9e:	64f2                	ld	s1,280(sp)
    80004ea0:	a03d                	j	80004ece <sys_link+0xf4>
    iunlockput(dp);
    80004ea2:	854a                	mv	a0,s2
    80004ea4:	e3efe0ef          	jal	800034e2 <iunlockput>
  ilock(ip);
    80004ea8:	8526                	mv	a0,s1
    80004eaa:	c2cfe0ef          	jal	800032d6 <ilock>
  ip->nlink--;
    80004eae:	04a4d783          	lhu	a5,74(s1)
    80004eb2:	37fd                	addiw	a5,a5,-1
    80004eb4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004eb8:	8526                	mv	a0,s1
    80004eba:	b68fe0ef          	jal	80003222 <iupdate>
  iunlockput(ip);
    80004ebe:	8526                	mv	a0,s1
    80004ec0:	e22fe0ef          	jal	800034e2 <iunlockput>
  end_op();
    80004ec4:	e8ffe0ef          	jal	80003d52 <end_op>
  return -1;
    80004ec8:	57fd                	li	a5,-1
    80004eca:	64f2                	ld	s1,280(sp)
    80004ecc:	6952                	ld	s2,272(sp)
}
    80004ece:	853e                	mv	a0,a5
    80004ed0:	70b2                	ld	ra,296(sp)
    80004ed2:	7412                	ld	s0,288(sp)
    80004ed4:	6155                	addi	sp,sp,304
    80004ed6:	8082                	ret

0000000080004ed8 <sys_unlink>:
{
    80004ed8:	7151                	addi	sp,sp,-240
    80004eda:	f586                	sd	ra,232(sp)
    80004edc:	f1a2                	sd	s0,224(sp)
    80004ede:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004ee0:	08000613          	li	a2,128
    80004ee4:	f3040593          	addi	a1,s0,-208
    80004ee8:	4501                	li	a0,0
    80004eea:	a5bfd0ef          	jal	80002944 <argstr>
    80004eee:	14054d63          	bltz	a0,80005048 <sys_unlink+0x170>
    80004ef2:	eda6                	sd	s1,216(sp)
  begin_op();
    80004ef4:	deffe0ef          	jal	80003ce2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004ef8:	fb040593          	addi	a1,s0,-80
    80004efc:	f3040513          	addi	a0,s0,-208
    80004f00:	c1ffe0ef          	jal	80003b1e <nameiparent>
    80004f04:	84aa                	mv	s1,a0
    80004f06:	c955                	beqz	a0,80004fba <sys_unlink+0xe2>
  ilock(dp);
    80004f08:	bcefe0ef          	jal	800032d6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004f0c:	00002597          	auipc	a1,0x2
    80004f10:	6b458593          	addi	a1,a1,1716 # 800075c0 <etext+0x5c0>
    80004f14:	fb040513          	addi	a0,s0,-80
    80004f18:	943fe0ef          	jal	8000385a <namecmp>
    80004f1c:	10050b63          	beqz	a0,80005032 <sys_unlink+0x15a>
    80004f20:	00002597          	auipc	a1,0x2
    80004f24:	6a858593          	addi	a1,a1,1704 # 800075c8 <etext+0x5c8>
    80004f28:	fb040513          	addi	a0,s0,-80
    80004f2c:	92ffe0ef          	jal	8000385a <namecmp>
    80004f30:	10050163          	beqz	a0,80005032 <sys_unlink+0x15a>
    80004f34:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004f36:	f2c40613          	addi	a2,s0,-212
    80004f3a:	fb040593          	addi	a1,s0,-80
    80004f3e:	8526                	mv	a0,s1
    80004f40:	931fe0ef          	jal	80003870 <dirlookup>
    80004f44:	892a                	mv	s2,a0
    80004f46:	0e050563          	beqz	a0,80005030 <sys_unlink+0x158>
    80004f4a:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80004f4c:	b8afe0ef          	jal	800032d6 <ilock>
  if(ip->nlink < 1)
    80004f50:	04a91783          	lh	a5,74(s2)
    80004f54:	06f05863          	blez	a5,80004fc4 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004f58:	04491703          	lh	a4,68(s2)
    80004f5c:	4785                	li	a5,1
    80004f5e:	06f70963          	beq	a4,a5,80004fd0 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80004f62:	fc040993          	addi	s3,s0,-64
    80004f66:	4641                	li	a2,16
    80004f68:	4581                	li	a1,0
    80004f6a:	854e                	mv	a0,s3
    80004f6c:	d8dfb0ef          	jal	80000cf8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f70:	4741                	li	a4,16
    80004f72:	f2c42683          	lw	a3,-212(s0)
    80004f76:	864e                	mv	a2,s3
    80004f78:	4581                	li	a1,0
    80004f7a:	8526                	mv	a0,s1
    80004f7c:	fdefe0ef          	jal	8000375a <writei>
    80004f80:	47c1                	li	a5,16
    80004f82:	08f51863          	bne	a0,a5,80005012 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    80004f86:	04491703          	lh	a4,68(s2)
    80004f8a:	4785                	li	a5,1
    80004f8c:	08f70963          	beq	a4,a5,8000501e <sys_unlink+0x146>
  iunlockput(dp);
    80004f90:	8526                	mv	a0,s1
    80004f92:	d50fe0ef          	jal	800034e2 <iunlockput>
  ip->nlink--;
    80004f96:	04a95783          	lhu	a5,74(s2)
    80004f9a:	37fd                	addiw	a5,a5,-1
    80004f9c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004fa0:	854a                	mv	a0,s2
    80004fa2:	a80fe0ef          	jal	80003222 <iupdate>
  iunlockput(ip);
    80004fa6:	854a                	mv	a0,s2
    80004fa8:	d3afe0ef          	jal	800034e2 <iunlockput>
  end_op();
    80004fac:	da7fe0ef          	jal	80003d52 <end_op>
  return 0;
    80004fb0:	4501                	li	a0,0
    80004fb2:	64ee                	ld	s1,216(sp)
    80004fb4:	694e                	ld	s2,208(sp)
    80004fb6:	69ae                	ld	s3,200(sp)
    80004fb8:	a061                	j	80005040 <sys_unlink+0x168>
    end_op();
    80004fba:	d99fe0ef          	jal	80003d52 <end_op>
    return -1;
    80004fbe:	557d                	li	a0,-1
    80004fc0:	64ee                	ld	s1,216(sp)
    80004fc2:	a8bd                	j	80005040 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004fc4:	00002517          	auipc	a0,0x2
    80004fc8:	60c50513          	addi	a0,a0,1548 # 800075d0 <etext+0x5d0>
    80004fcc:	859fb0ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004fd0:	04c92703          	lw	a4,76(s2)
    80004fd4:	02000793          	li	a5,32
    80004fd8:	f8e7f5e3          	bgeu	a5,a4,80004f62 <sys_unlink+0x8a>
    80004fdc:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004fde:	4741                	li	a4,16
    80004fe0:	86ce                	mv	a3,s3
    80004fe2:	f1840613          	addi	a2,s0,-232
    80004fe6:	4581                	li	a1,0
    80004fe8:	854a                	mv	a0,s2
    80004fea:	e7efe0ef          	jal	80003668 <readi>
    80004fee:	47c1                	li	a5,16
    80004ff0:	00f51b63          	bne	a0,a5,80005006 <sys_unlink+0x12e>
    if(de.inum != 0)
    80004ff4:	f1845783          	lhu	a5,-232(s0)
    80004ff8:	ebb1                	bnez	a5,8000504c <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004ffa:	29c1                	addiw	s3,s3,16
    80004ffc:	04c92783          	lw	a5,76(s2)
    80005000:	fcf9efe3          	bltu	s3,a5,80004fde <sys_unlink+0x106>
    80005004:	bfb9                	j	80004f62 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005006:	00002517          	auipc	a0,0x2
    8000500a:	5e250513          	addi	a0,a0,1506 # 800075e8 <etext+0x5e8>
    8000500e:	817fb0ef          	jal	80000824 <panic>
    panic("unlink: writei");
    80005012:	00002517          	auipc	a0,0x2
    80005016:	5ee50513          	addi	a0,a0,1518 # 80007600 <etext+0x600>
    8000501a:	80bfb0ef          	jal	80000824 <panic>
    dp->nlink--;
    8000501e:	04a4d783          	lhu	a5,74(s1)
    80005022:	37fd                	addiw	a5,a5,-1
    80005024:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005028:	8526                	mv	a0,s1
    8000502a:	9f8fe0ef          	jal	80003222 <iupdate>
    8000502e:	b78d                	j	80004f90 <sys_unlink+0xb8>
    80005030:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005032:	8526                	mv	a0,s1
    80005034:	caefe0ef          	jal	800034e2 <iunlockput>
  end_op();
    80005038:	d1bfe0ef          	jal	80003d52 <end_op>
  return -1;
    8000503c:	557d                	li	a0,-1
    8000503e:	64ee                	ld	s1,216(sp)
}
    80005040:	70ae                	ld	ra,232(sp)
    80005042:	740e                	ld	s0,224(sp)
    80005044:	616d                	addi	sp,sp,240
    80005046:	8082                	ret
    return -1;
    80005048:	557d                	li	a0,-1
    8000504a:	bfdd                	j	80005040 <sys_unlink+0x168>
    iunlockput(ip);
    8000504c:	854a                	mv	a0,s2
    8000504e:	c94fe0ef          	jal	800034e2 <iunlockput>
    goto bad;
    80005052:	694e                	ld	s2,208(sp)
    80005054:	69ae                	ld	s3,200(sp)
    80005056:	bff1                	j	80005032 <sys_unlink+0x15a>

0000000080005058 <sys_open>:

uint64
sys_open(void)
{
    80005058:	7131                	addi	sp,sp,-192
    8000505a:	fd06                	sd	ra,184(sp)
    8000505c:	f922                	sd	s0,176(sp)
    8000505e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005060:	f4c40593          	addi	a1,s0,-180
    80005064:	4505                	li	a0,1
    80005066:	8a7fd0ef          	jal	8000290c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000506a:	08000613          	li	a2,128
    8000506e:	f5040593          	addi	a1,s0,-176
    80005072:	4501                	li	a0,0
    80005074:	8d1fd0ef          	jal	80002944 <argstr>
    80005078:	87aa                	mv	a5,a0
    return -1;
    8000507a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000507c:	0a07c363          	bltz	a5,80005122 <sys_open+0xca>
    80005080:	f526                	sd	s1,168(sp)

  begin_op();
    80005082:	c61fe0ef          	jal	80003ce2 <begin_op>

  if(omode & O_CREATE){
    80005086:	f4c42783          	lw	a5,-180(s0)
    8000508a:	2007f793          	andi	a5,a5,512
    8000508e:	c3dd                	beqz	a5,80005134 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005090:	4681                	li	a3,0
    80005092:	4601                	li	a2,0
    80005094:	4589                	li	a1,2
    80005096:	f5040513          	addi	a0,s0,-176
    8000509a:	aafff0ef          	jal	80004b48 <create>
    8000509e:	84aa                	mv	s1,a0
    if(ip == 0){
    800050a0:	c549                	beqz	a0,8000512a <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800050a2:	04449703          	lh	a4,68(s1)
    800050a6:	478d                	li	a5,3
    800050a8:	00f71763          	bne	a4,a5,800050b6 <sys_open+0x5e>
    800050ac:	0464d703          	lhu	a4,70(s1)
    800050b0:	47a5                	li	a5,9
    800050b2:	0ae7ee63          	bltu	a5,a4,8000516e <sys_open+0x116>
    800050b6:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800050b8:	fabfe0ef          	jal	80004062 <filealloc>
    800050bc:	892a                	mv	s2,a0
    800050be:	c561                	beqz	a0,80005186 <sys_open+0x12e>
    800050c0:	ed4e                	sd	s3,152(sp)
    800050c2:	a47ff0ef          	jal	80004b08 <fdalloc>
    800050c6:	89aa                	mv	s3,a0
    800050c8:	0a054b63          	bltz	a0,8000517e <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800050cc:	04449703          	lh	a4,68(s1)
    800050d0:	478d                	li	a5,3
    800050d2:	0cf70363          	beq	a4,a5,80005198 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800050d6:	4789                	li	a5,2
    800050d8:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800050dc:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800050e0:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800050e4:	f4c42783          	lw	a5,-180(s0)
    800050e8:	0017f713          	andi	a4,a5,1
    800050ec:	00174713          	xori	a4,a4,1
    800050f0:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800050f4:	0037f713          	andi	a4,a5,3
    800050f8:	00e03733          	snez	a4,a4
    800050fc:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005100:	4007f793          	andi	a5,a5,1024
    80005104:	c791                	beqz	a5,80005110 <sys_open+0xb8>
    80005106:	04449703          	lh	a4,68(s1)
    8000510a:	4789                	li	a5,2
    8000510c:	08f70d63          	beq	a4,a5,800051a6 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80005110:	8526                	mv	a0,s1
    80005112:	a72fe0ef          	jal	80003384 <iunlock>
  end_op();
    80005116:	c3dfe0ef          	jal	80003d52 <end_op>

  return fd;
    8000511a:	854e                	mv	a0,s3
    8000511c:	74aa                	ld	s1,168(sp)
    8000511e:	790a                	ld	s2,160(sp)
    80005120:	69ea                	ld	s3,152(sp)
}
    80005122:	70ea                	ld	ra,184(sp)
    80005124:	744a                	ld	s0,176(sp)
    80005126:	6129                	addi	sp,sp,192
    80005128:	8082                	ret
      end_op();
    8000512a:	c29fe0ef          	jal	80003d52 <end_op>
      return -1;
    8000512e:	557d                	li	a0,-1
    80005130:	74aa                	ld	s1,168(sp)
    80005132:	bfc5                	j	80005122 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80005134:	f5040513          	addi	a0,s0,-176
    80005138:	9cdfe0ef          	jal	80003b04 <namei>
    8000513c:	84aa                	mv	s1,a0
    8000513e:	c11d                	beqz	a0,80005164 <sys_open+0x10c>
    ilock(ip);
    80005140:	996fe0ef          	jal	800032d6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005144:	04449703          	lh	a4,68(s1)
    80005148:	4785                	li	a5,1
    8000514a:	f4f71ce3          	bne	a4,a5,800050a2 <sys_open+0x4a>
    8000514e:	f4c42783          	lw	a5,-180(s0)
    80005152:	d3b5                	beqz	a5,800050b6 <sys_open+0x5e>
      iunlockput(ip);
    80005154:	8526                	mv	a0,s1
    80005156:	b8cfe0ef          	jal	800034e2 <iunlockput>
      end_op();
    8000515a:	bf9fe0ef          	jal	80003d52 <end_op>
      return -1;
    8000515e:	557d                	li	a0,-1
    80005160:	74aa                	ld	s1,168(sp)
    80005162:	b7c1                	j	80005122 <sys_open+0xca>
      end_op();
    80005164:	beffe0ef          	jal	80003d52 <end_op>
      return -1;
    80005168:	557d                	li	a0,-1
    8000516a:	74aa                	ld	s1,168(sp)
    8000516c:	bf5d                	j	80005122 <sys_open+0xca>
    iunlockput(ip);
    8000516e:	8526                	mv	a0,s1
    80005170:	b72fe0ef          	jal	800034e2 <iunlockput>
    end_op();
    80005174:	bdffe0ef          	jal	80003d52 <end_op>
    return -1;
    80005178:	557d                	li	a0,-1
    8000517a:	74aa                	ld	s1,168(sp)
    8000517c:	b75d                	j	80005122 <sys_open+0xca>
      fileclose(f);
    8000517e:	854a                	mv	a0,s2
    80005180:	f87fe0ef          	jal	80004106 <fileclose>
    80005184:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005186:	8526                	mv	a0,s1
    80005188:	b5afe0ef          	jal	800034e2 <iunlockput>
    end_op();
    8000518c:	bc7fe0ef          	jal	80003d52 <end_op>
    return -1;
    80005190:	557d                	li	a0,-1
    80005192:	74aa                	ld	s1,168(sp)
    80005194:	790a                	ld	s2,160(sp)
    80005196:	b771                	j	80005122 <sys_open+0xca>
    f->type = FD_DEVICE;
    80005198:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    8000519c:	04649783          	lh	a5,70(s1)
    800051a0:	02f91223          	sh	a5,36(s2)
    800051a4:	bf35                	j	800050e0 <sys_open+0x88>
    itrunc(ip);
    800051a6:	8526                	mv	a0,s1
    800051a8:	a1cfe0ef          	jal	800033c4 <itrunc>
    800051ac:	b795                	j	80005110 <sys_open+0xb8>

00000000800051ae <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800051ae:	7175                	addi	sp,sp,-144
    800051b0:	e506                	sd	ra,136(sp)
    800051b2:	e122                	sd	s0,128(sp)
    800051b4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800051b6:	b2dfe0ef          	jal	80003ce2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800051ba:	08000613          	li	a2,128
    800051be:	f7040593          	addi	a1,s0,-144
    800051c2:	4501                	li	a0,0
    800051c4:	f80fd0ef          	jal	80002944 <argstr>
    800051c8:	02054363          	bltz	a0,800051ee <sys_mkdir+0x40>
    800051cc:	4681                	li	a3,0
    800051ce:	4601                	li	a2,0
    800051d0:	4585                	li	a1,1
    800051d2:	f7040513          	addi	a0,s0,-144
    800051d6:	973ff0ef          	jal	80004b48 <create>
    800051da:	c911                	beqz	a0,800051ee <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800051dc:	b06fe0ef          	jal	800034e2 <iunlockput>
  end_op();
    800051e0:	b73fe0ef          	jal	80003d52 <end_op>
  return 0;
    800051e4:	4501                	li	a0,0
}
    800051e6:	60aa                	ld	ra,136(sp)
    800051e8:	640a                	ld	s0,128(sp)
    800051ea:	6149                	addi	sp,sp,144
    800051ec:	8082                	ret
    end_op();
    800051ee:	b65fe0ef          	jal	80003d52 <end_op>
    return -1;
    800051f2:	557d                	li	a0,-1
    800051f4:	bfcd                	j	800051e6 <sys_mkdir+0x38>

00000000800051f6 <sys_mknod>:

uint64
sys_mknod(void)
{
    800051f6:	7135                	addi	sp,sp,-160
    800051f8:	ed06                	sd	ra,152(sp)
    800051fa:	e922                	sd	s0,144(sp)
    800051fc:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800051fe:	ae5fe0ef          	jal	80003ce2 <begin_op>
  argint(1, &major);
    80005202:	f6c40593          	addi	a1,s0,-148
    80005206:	4505                	li	a0,1
    80005208:	f04fd0ef          	jal	8000290c <argint>
  argint(2, &minor);
    8000520c:	f6840593          	addi	a1,s0,-152
    80005210:	4509                	li	a0,2
    80005212:	efafd0ef          	jal	8000290c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005216:	08000613          	li	a2,128
    8000521a:	f7040593          	addi	a1,s0,-144
    8000521e:	4501                	li	a0,0
    80005220:	f24fd0ef          	jal	80002944 <argstr>
    80005224:	02054563          	bltz	a0,8000524e <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005228:	f6841683          	lh	a3,-152(s0)
    8000522c:	f6c41603          	lh	a2,-148(s0)
    80005230:	458d                	li	a1,3
    80005232:	f7040513          	addi	a0,s0,-144
    80005236:	913ff0ef          	jal	80004b48 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000523a:	c911                	beqz	a0,8000524e <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000523c:	aa6fe0ef          	jal	800034e2 <iunlockput>
  end_op();
    80005240:	b13fe0ef          	jal	80003d52 <end_op>
  return 0;
    80005244:	4501                	li	a0,0
}
    80005246:	60ea                	ld	ra,152(sp)
    80005248:	644a                	ld	s0,144(sp)
    8000524a:	610d                	addi	sp,sp,160
    8000524c:	8082                	ret
    end_op();
    8000524e:	b05fe0ef          	jal	80003d52 <end_op>
    return -1;
    80005252:	557d                	li	a0,-1
    80005254:	bfcd                	j	80005246 <sys_mknod+0x50>

0000000080005256 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005256:	7135                	addi	sp,sp,-160
    80005258:	ed06                	sd	ra,152(sp)
    8000525a:	e922                	sd	s0,144(sp)
    8000525c:	e14a                	sd	s2,128(sp)
    8000525e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005260:	ecefc0ef          	jal	8000192e <myproc>
    80005264:	892a                	mv	s2,a0
  
  begin_op();
    80005266:	a7dfe0ef          	jal	80003ce2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000526a:	08000613          	li	a2,128
    8000526e:	f6040593          	addi	a1,s0,-160
    80005272:	4501                	li	a0,0
    80005274:	ed0fd0ef          	jal	80002944 <argstr>
    80005278:	04054363          	bltz	a0,800052be <sys_chdir+0x68>
    8000527c:	e526                	sd	s1,136(sp)
    8000527e:	f6040513          	addi	a0,s0,-160
    80005282:	883fe0ef          	jal	80003b04 <namei>
    80005286:	84aa                	mv	s1,a0
    80005288:	c915                	beqz	a0,800052bc <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000528a:	84cfe0ef          	jal	800032d6 <ilock>
  if(ip->type != T_DIR){
    8000528e:	04449703          	lh	a4,68(s1)
    80005292:	4785                	li	a5,1
    80005294:	02f71963          	bne	a4,a5,800052c6 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005298:	8526                	mv	a0,s1
    8000529a:	8eafe0ef          	jal	80003384 <iunlock>
  iput(p->cwd);
    8000529e:	15893503          	ld	a0,344(s2)
    800052a2:	9b6fe0ef          	jal	80003458 <iput>
  end_op();
    800052a6:	aadfe0ef          	jal	80003d52 <end_op>
  p->cwd = ip;
    800052aa:	14993c23          	sd	s1,344(s2)
  return 0;
    800052ae:	4501                	li	a0,0
    800052b0:	64aa                	ld	s1,136(sp)
}
    800052b2:	60ea                	ld	ra,152(sp)
    800052b4:	644a                	ld	s0,144(sp)
    800052b6:	690a                	ld	s2,128(sp)
    800052b8:	610d                	addi	sp,sp,160
    800052ba:	8082                	ret
    800052bc:	64aa                	ld	s1,136(sp)
    end_op();
    800052be:	a95fe0ef          	jal	80003d52 <end_op>
    return -1;
    800052c2:	557d                	li	a0,-1
    800052c4:	b7fd                	j	800052b2 <sys_chdir+0x5c>
    iunlockput(ip);
    800052c6:	8526                	mv	a0,s1
    800052c8:	a1afe0ef          	jal	800034e2 <iunlockput>
    end_op();
    800052cc:	a87fe0ef          	jal	80003d52 <end_op>
    return -1;
    800052d0:	557d                	li	a0,-1
    800052d2:	64aa                	ld	s1,136(sp)
    800052d4:	bff9                	j	800052b2 <sys_chdir+0x5c>

00000000800052d6 <sys_exec>:

uint64
sys_exec(void)
{
    800052d6:	7105                	addi	sp,sp,-480
    800052d8:	ef86                	sd	ra,472(sp)
    800052da:	eba2                	sd	s0,464(sp)
    800052dc:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800052de:	e2840593          	addi	a1,s0,-472
    800052e2:	4505                	li	a0,1
    800052e4:	e44fd0ef          	jal	80002928 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800052e8:	08000613          	li	a2,128
    800052ec:	f3040593          	addi	a1,s0,-208
    800052f0:	4501                	li	a0,0
    800052f2:	e52fd0ef          	jal	80002944 <argstr>
    800052f6:	87aa                	mv	a5,a0
    return -1;
    800052f8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800052fa:	0e07c063          	bltz	a5,800053da <sys_exec+0x104>
    800052fe:	e7a6                	sd	s1,456(sp)
    80005300:	e3ca                	sd	s2,448(sp)
    80005302:	ff4e                	sd	s3,440(sp)
    80005304:	fb52                	sd	s4,432(sp)
    80005306:	f756                	sd	s5,424(sp)
    80005308:	f35a                	sd	s6,416(sp)
    8000530a:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000530c:	e3040a13          	addi	s4,s0,-464
    80005310:	10000613          	li	a2,256
    80005314:	4581                	li	a1,0
    80005316:	8552                	mv	a0,s4
    80005318:	9e1fb0ef          	jal	80000cf8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000531c:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    8000531e:	89d2                	mv	s3,s4
    80005320:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005322:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005326:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80005328:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000532c:	00391513          	slli	a0,s2,0x3
    80005330:	85d6                	mv	a1,s5
    80005332:	e2843783          	ld	a5,-472(s0)
    80005336:	953e                	add	a0,a0,a5
    80005338:	d4afd0ef          	jal	80002882 <fetchaddr>
    8000533c:	02054663          	bltz	a0,80005368 <sys_exec+0x92>
    if(uarg == 0){
    80005340:	e2043783          	ld	a5,-480(s0)
    80005344:	c7a1                	beqz	a5,8000538c <sys_exec+0xb6>
    argv[i] = kalloc();
    80005346:	ffefb0ef          	jal	80000b44 <kalloc>
    8000534a:	85aa                	mv	a1,a0
    8000534c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005350:	cd01                	beqz	a0,80005368 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005352:	865a                	mv	a2,s6
    80005354:	e2043503          	ld	a0,-480(s0)
    80005358:	d74fd0ef          	jal	800028cc <fetchstr>
    8000535c:	00054663          	bltz	a0,80005368 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005360:	0905                	addi	s2,s2,1
    80005362:	09a1                	addi	s3,s3,8
    80005364:	fd7914e3          	bne	s2,s7,8000532c <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005368:	100a0a13          	addi	s4,s4,256
    8000536c:	6088                	ld	a0,0(s1)
    8000536e:	cd31                	beqz	a0,800053ca <sys_exec+0xf4>
    kfree(argv[i]);
    80005370:	eecfb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005374:	04a1                	addi	s1,s1,8
    80005376:	ff449be3          	bne	s1,s4,8000536c <sys_exec+0x96>
  return -1;
    8000537a:	557d                	li	a0,-1
    8000537c:	64be                	ld	s1,456(sp)
    8000537e:	691e                	ld	s2,448(sp)
    80005380:	79fa                	ld	s3,440(sp)
    80005382:	7a5a                	ld	s4,432(sp)
    80005384:	7aba                	ld	s5,424(sp)
    80005386:	7b1a                	ld	s6,416(sp)
    80005388:	6bfa                	ld	s7,408(sp)
    8000538a:	a881                	j	800053da <sys_exec+0x104>
      argv[i] = 0;
    8000538c:	0009079b          	sext.w	a5,s2
    80005390:	e3040593          	addi	a1,s0,-464
    80005394:	078e                	slli	a5,a5,0x3
    80005396:	97ae                	add	a5,a5,a1
    80005398:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    8000539c:	f3040513          	addi	a0,s0,-208
    800053a0:	bb2ff0ef          	jal	80004752 <kexec>
    800053a4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800053a6:	100a0a13          	addi	s4,s4,256
    800053aa:	6088                	ld	a0,0(s1)
    800053ac:	c511                	beqz	a0,800053b8 <sys_exec+0xe2>
    kfree(argv[i]);
    800053ae:	eaefb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800053b2:	04a1                	addi	s1,s1,8
    800053b4:	ff449be3          	bne	s1,s4,800053aa <sys_exec+0xd4>
  return ret;
    800053b8:	854a                	mv	a0,s2
    800053ba:	64be                	ld	s1,456(sp)
    800053bc:	691e                	ld	s2,448(sp)
    800053be:	79fa                	ld	s3,440(sp)
    800053c0:	7a5a                	ld	s4,432(sp)
    800053c2:	7aba                	ld	s5,424(sp)
    800053c4:	7b1a                	ld	s6,416(sp)
    800053c6:	6bfa                	ld	s7,408(sp)
    800053c8:	a809                	j	800053da <sys_exec+0x104>
  return -1;
    800053ca:	557d                	li	a0,-1
    800053cc:	64be                	ld	s1,456(sp)
    800053ce:	691e                	ld	s2,448(sp)
    800053d0:	79fa                	ld	s3,440(sp)
    800053d2:	7a5a                	ld	s4,432(sp)
    800053d4:	7aba                	ld	s5,424(sp)
    800053d6:	7b1a                	ld	s6,416(sp)
    800053d8:	6bfa                	ld	s7,408(sp)
}
    800053da:	60fe                	ld	ra,472(sp)
    800053dc:	645e                	ld	s0,464(sp)
    800053de:	613d                	addi	sp,sp,480
    800053e0:	8082                	ret

00000000800053e2 <sys_pipe>:

uint64
sys_pipe(void)
{
    800053e2:	7139                	addi	sp,sp,-64
    800053e4:	fc06                	sd	ra,56(sp)
    800053e6:	f822                	sd	s0,48(sp)
    800053e8:	f426                	sd	s1,40(sp)
    800053ea:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800053ec:	d42fc0ef          	jal	8000192e <myproc>
    800053f0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800053f2:	fd840593          	addi	a1,s0,-40
    800053f6:	4501                	li	a0,0
    800053f8:	d30fd0ef          	jal	80002928 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800053fc:	fc840593          	addi	a1,s0,-56
    80005400:	fd040513          	addi	a0,s0,-48
    80005404:	81eff0ef          	jal	80004422 <pipealloc>
    return -1;
    80005408:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000540a:	0a054763          	bltz	a0,800054b8 <sys_pipe+0xd6>
  fd0 = -1;
    8000540e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005412:	fd043503          	ld	a0,-48(s0)
    80005416:	ef2ff0ef          	jal	80004b08 <fdalloc>
    8000541a:	fca42223          	sw	a0,-60(s0)
    8000541e:	08054463          	bltz	a0,800054a6 <sys_pipe+0xc4>
    80005422:	fc843503          	ld	a0,-56(s0)
    80005426:	ee2ff0ef          	jal	80004b08 <fdalloc>
    8000542a:	fca42023          	sw	a0,-64(s0)
    8000542e:	06054263          	bltz	a0,80005492 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005432:	4691                	li	a3,4
    80005434:	fc440613          	addi	a2,s0,-60
    80005438:	fd843583          	ld	a1,-40(s0)
    8000543c:	6ca8                	ld	a0,88(s1)
    8000543e:	a16fc0ef          	jal	80001654 <copyout>
    80005442:	00054e63          	bltz	a0,8000545e <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005446:	4691                	li	a3,4
    80005448:	fc040613          	addi	a2,s0,-64
    8000544c:	fd843583          	ld	a1,-40(s0)
    80005450:	95b6                	add	a1,a1,a3
    80005452:	6ca8                	ld	a0,88(s1)
    80005454:	a00fc0ef          	jal	80001654 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005458:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000545a:	04055f63          	bgez	a0,800054b8 <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    8000545e:	fc442783          	lw	a5,-60(s0)
    80005462:	078e                	slli	a5,a5,0x3
    80005464:	0d078793          	addi	a5,a5,208
    80005468:	97a6                	add	a5,a5,s1
    8000546a:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    8000546e:	fc042783          	lw	a5,-64(s0)
    80005472:	078e                	slli	a5,a5,0x3
    80005474:	0d078793          	addi	a5,a5,208
    80005478:	97a6                	add	a5,a5,s1
    8000547a:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    8000547e:	fd043503          	ld	a0,-48(s0)
    80005482:	c85fe0ef          	jal	80004106 <fileclose>
    fileclose(wf);
    80005486:	fc843503          	ld	a0,-56(s0)
    8000548a:	c7dfe0ef          	jal	80004106 <fileclose>
    return -1;
    8000548e:	57fd                	li	a5,-1
    80005490:	a025                	j	800054b8 <sys_pipe+0xd6>
    if(fd0 >= 0)
    80005492:	fc442783          	lw	a5,-60(s0)
    80005496:	0007c863          	bltz	a5,800054a6 <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    8000549a:	078e                	slli	a5,a5,0x3
    8000549c:	0d078793          	addi	a5,a5,208
    800054a0:	97a6                	add	a5,a5,s1
    800054a2:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    800054a6:	fd043503          	ld	a0,-48(s0)
    800054aa:	c5dfe0ef          	jal	80004106 <fileclose>
    fileclose(wf);
    800054ae:	fc843503          	ld	a0,-56(s0)
    800054b2:	c55fe0ef          	jal	80004106 <fileclose>
    return -1;
    800054b6:	57fd                	li	a5,-1
}
    800054b8:	853e                	mv	a0,a5
    800054ba:	70e2                	ld	ra,56(sp)
    800054bc:	7442                	ld	s0,48(sp)
    800054be:	74a2                	ld	s1,40(sp)
    800054c0:	6121                	addi	sp,sp,64
    800054c2:	8082                	ret
	...

00000000800054d0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800054d0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800054d2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800054d4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    800054d6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    800054d8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800054da:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800054dc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800054de:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800054e0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800054e2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800054e4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800054e6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800054e8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800054ea:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800054ec:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800054ee:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800054f0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800054f2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800054f4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800054f6:	a9afd0ef          	jal	80002790 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800054fa:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800054fc:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800054fe:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005500:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005502:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005504:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005506:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005508:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000550a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000550c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000550e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005510:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005512:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005514:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005516:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005518:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000551a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000551c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000551e:	10200073          	sret
    80005522:	00000013          	nop
    80005526:	00000013          	nop
    8000552a:	00000013          	nop

000000008000552e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000552e:	1141                	addi	sp,sp,-16
    80005530:	e406                	sd	ra,8(sp)
    80005532:	e022                	sd	s0,0(sp)
    80005534:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005536:	0c000737          	lui	a4,0xc000
    8000553a:	4785                	li	a5,1
    8000553c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000553e:	c35c                	sw	a5,4(a4)
}
    80005540:	60a2                	ld	ra,8(sp)
    80005542:	6402                	ld	s0,0(sp)
    80005544:	0141                	addi	sp,sp,16
    80005546:	8082                	ret

0000000080005548 <plicinithart>:

void
plicinithart(void)
{
    80005548:	1141                	addi	sp,sp,-16
    8000554a:	e406                	sd	ra,8(sp)
    8000554c:	e022                	sd	s0,0(sp)
    8000554e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005550:	baafc0ef          	jal	800018fa <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005554:	0085171b          	slliw	a4,a0,0x8
    80005558:	0c0027b7          	lui	a5,0xc002
    8000555c:	97ba                	add	a5,a5,a4
    8000555e:	40200713          	li	a4,1026
    80005562:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005566:	00d5151b          	slliw	a0,a0,0xd
    8000556a:	0c2017b7          	lui	a5,0xc201
    8000556e:	97aa                	add	a5,a5,a0
    80005570:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005574:	60a2                	ld	ra,8(sp)
    80005576:	6402                	ld	s0,0(sp)
    80005578:	0141                	addi	sp,sp,16
    8000557a:	8082                	ret

000000008000557c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000557c:	1141                	addi	sp,sp,-16
    8000557e:	e406                	sd	ra,8(sp)
    80005580:	e022                	sd	s0,0(sp)
    80005582:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005584:	b76fc0ef          	jal	800018fa <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005588:	00d5151b          	slliw	a0,a0,0xd
    8000558c:	0c2017b7          	lui	a5,0xc201
    80005590:	97aa                	add	a5,a5,a0
  return irq;
}
    80005592:	43c8                	lw	a0,4(a5)
    80005594:	60a2                	ld	ra,8(sp)
    80005596:	6402                	ld	s0,0(sp)
    80005598:	0141                	addi	sp,sp,16
    8000559a:	8082                	ret

000000008000559c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000559c:	1101                	addi	sp,sp,-32
    8000559e:	ec06                	sd	ra,24(sp)
    800055a0:	e822                	sd	s0,16(sp)
    800055a2:	e426                	sd	s1,8(sp)
    800055a4:	1000                	addi	s0,sp,32
    800055a6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800055a8:	b52fc0ef          	jal	800018fa <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800055ac:	00d5179b          	slliw	a5,a0,0xd
    800055b0:	0c201737          	lui	a4,0xc201
    800055b4:	97ba                	add	a5,a5,a4
    800055b6:	c3c4                	sw	s1,4(a5)
}
    800055b8:	60e2                	ld	ra,24(sp)
    800055ba:	6442                	ld	s0,16(sp)
    800055bc:	64a2                	ld	s1,8(sp)
    800055be:	6105                	addi	sp,sp,32
    800055c0:	8082                	ret

00000000800055c2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800055c2:	1141                	addi	sp,sp,-16
    800055c4:	e406                	sd	ra,8(sp)
    800055c6:	e022                	sd	s0,0(sp)
    800055c8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800055ca:	479d                	li	a5,7
    800055cc:	04a7ca63          	blt	a5,a0,80005620 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800055d0:	0001e797          	auipc	a5,0x1e
    800055d4:	03878793          	addi	a5,a5,56 # 80023608 <disk>
    800055d8:	97aa                	add	a5,a5,a0
    800055da:	0187c783          	lbu	a5,24(a5)
    800055de:	e7b9                	bnez	a5,8000562c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800055e0:	00451693          	slli	a3,a0,0x4
    800055e4:	0001e797          	auipc	a5,0x1e
    800055e8:	02478793          	addi	a5,a5,36 # 80023608 <disk>
    800055ec:	6398                	ld	a4,0(a5)
    800055ee:	9736                	add	a4,a4,a3
    800055f0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    800055f4:	6398                	ld	a4,0(a5)
    800055f6:	9736                	add	a4,a4,a3
    800055f8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800055fc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005600:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005604:	97aa                	add	a5,a5,a0
    80005606:	4705                	li	a4,1
    80005608:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000560c:	0001e517          	auipc	a0,0x1e
    80005610:	01450513          	addi	a0,a0,20 # 80023620 <disk+0x18>
    80005614:	a39fc0ef          	jal	8000204c <wakeup>
}
    80005618:	60a2                	ld	ra,8(sp)
    8000561a:	6402                	ld	s0,0(sp)
    8000561c:	0141                	addi	sp,sp,16
    8000561e:	8082                	ret
    panic("free_desc 1");
    80005620:	00002517          	auipc	a0,0x2
    80005624:	ff050513          	addi	a0,a0,-16 # 80007610 <etext+0x610>
    80005628:	9fcfb0ef          	jal	80000824 <panic>
    panic("free_desc 2");
    8000562c:	00002517          	auipc	a0,0x2
    80005630:	ff450513          	addi	a0,a0,-12 # 80007620 <etext+0x620>
    80005634:	9f0fb0ef          	jal	80000824 <panic>

0000000080005638 <virtio_disk_init>:
{
    80005638:	1101                	addi	sp,sp,-32
    8000563a:	ec06                	sd	ra,24(sp)
    8000563c:	e822                	sd	s0,16(sp)
    8000563e:	e426                	sd	s1,8(sp)
    80005640:	e04a                	sd	s2,0(sp)
    80005642:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005644:	00002597          	auipc	a1,0x2
    80005648:	fec58593          	addi	a1,a1,-20 # 80007630 <etext+0x630>
    8000564c:	0001e517          	auipc	a0,0x1e
    80005650:	0e450513          	addi	a0,a0,228 # 80023730 <disk+0x128>
    80005654:	d4afb0ef          	jal	80000b9e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005658:	100017b7          	lui	a5,0x10001
    8000565c:	4398                	lw	a4,0(a5)
    8000565e:	2701                	sext.w	a4,a4
    80005660:	747277b7          	lui	a5,0x74727
    80005664:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005668:	14f71863          	bne	a4,a5,800057b8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000566c:	100017b7          	lui	a5,0x10001
    80005670:	43dc                	lw	a5,4(a5)
    80005672:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005674:	4709                	li	a4,2
    80005676:	14e79163          	bne	a5,a4,800057b8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000567a:	100017b7          	lui	a5,0x10001
    8000567e:	479c                	lw	a5,8(a5)
    80005680:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005682:	12e79b63          	bne	a5,a4,800057b8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005686:	100017b7          	lui	a5,0x10001
    8000568a:	47d8                	lw	a4,12(a5)
    8000568c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000568e:	554d47b7          	lui	a5,0x554d4
    80005692:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005696:	12f71163          	bne	a4,a5,800057b8 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000569a:	100017b7          	lui	a5,0x10001
    8000569e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800056a2:	4705                	li	a4,1
    800056a4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800056a6:	470d                	li	a4,3
    800056a8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800056aa:	10001737          	lui	a4,0x10001
    800056ae:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800056b0:	c7ffe6b7          	lui	a3,0xc7ffe
    800056b4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb017>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800056b8:	8f75                	and	a4,a4,a3
    800056ba:	100016b7          	lui	a3,0x10001
    800056be:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800056c0:	472d                	li	a4,11
    800056c2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800056c4:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800056c8:	439c                	lw	a5,0(a5)
    800056ca:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800056ce:	8ba1                	andi	a5,a5,8
    800056d0:	0e078a63          	beqz	a5,800057c4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800056d4:	100017b7          	lui	a5,0x10001
    800056d8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800056dc:	43fc                	lw	a5,68(a5)
    800056de:	2781                	sext.w	a5,a5
    800056e0:	0e079863          	bnez	a5,800057d0 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800056e4:	100017b7          	lui	a5,0x10001
    800056e8:	5bdc                	lw	a5,52(a5)
    800056ea:	2781                	sext.w	a5,a5
  if(max == 0)
    800056ec:	0e078863          	beqz	a5,800057dc <virtio_disk_init+0x1a4>
  if(max < NUM)
    800056f0:	471d                	li	a4,7
    800056f2:	0ef77b63          	bgeu	a4,a5,800057e8 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800056f6:	c4efb0ef          	jal	80000b44 <kalloc>
    800056fa:	0001e497          	auipc	s1,0x1e
    800056fe:	f0e48493          	addi	s1,s1,-242 # 80023608 <disk>
    80005702:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005704:	c40fb0ef          	jal	80000b44 <kalloc>
    80005708:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000570a:	c3afb0ef          	jal	80000b44 <kalloc>
    8000570e:	87aa                	mv	a5,a0
    80005710:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005712:	6088                	ld	a0,0(s1)
    80005714:	0e050063          	beqz	a0,800057f4 <virtio_disk_init+0x1bc>
    80005718:	0001e717          	auipc	a4,0x1e
    8000571c:	ef873703          	ld	a4,-264(a4) # 80023610 <disk+0x8>
    80005720:	cb71                	beqz	a4,800057f4 <virtio_disk_init+0x1bc>
    80005722:	cbe9                	beqz	a5,800057f4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005724:	6605                	lui	a2,0x1
    80005726:	4581                	li	a1,0
    80005728:	dd0fb0ef          	jal	80000cf8 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000572c:	0001e497          	auipc	s1,0x1e
    80005730:	edc48493          	addi	s1,s1,-292 # 80023608 <disk>
    80005734:	6605                	lui	a2,0x1
    80005736:	4581                	li	a1,0
    80005738:	6488                	ld	a0,8(s1)
    8000573a:	dbefb0ef          	jal	80000cf8 <memset>
  memset(disk.used, 0, PGSIZE);
    8000573e:	6605                	lui	a2,0x1
    80005740:	4581                	li	a1,0
    80005742:	6888                	ld	a0,16(s1)
    80005744:	db4fb0ef          	jal	80000cf8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005748:	100017b7          	lui	a5,0x10001
    8000574c:	4721                	li	a4,8
    8000574e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005750:	4098                	lw	a4,0(s1)
    80005752:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005756:	40d8                	lw	a4,4(s1)
    80005758:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000575c:	649c                	ld	a5,8(s1)
    8000575e:	0007869b          	sext.w	a3,a5
    80005762:	10001737          	lui	a4,0x10001
    80005766:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000576a:	9781                	srai	a5,a5,0x20
    8000576c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005770:	689c                	ld	a5,16(s1)
    80005772:	0007869b          	sext.w	a3,a5
    80005776:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000577a:	9781                	srai	a5,a5,0x20
    8000577c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005780:	4785                	li	a5,1
    80005782:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005784:	00f48c23          	sb	a5,24(s1)
    80005788:	00f48ca3          	sb	a5,25(s1)
    8000578c:	00f48d23          	sb	a5,26(s1)
    80005790:	00f48da3          	sb	a5,27(s1)
    80005794:	00f48e23          	sb	a5,28(s1)
    80005798:	00f48ea3          	sb	a5,29(s1)
    8000579c:	00f48f23          	sb	a5,30(s1)
    800057a0:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800057a4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800057a8:	07272823          	sw	s2,112(a4)
}
    800057ac:	60e2                	ld	ra,24(sp)
    800057ae:	6442                	ld	s0,16(sp)
    800057b0:	64a2                	ld	s1,8(sp)
    800057b2:	6902                	ld	s2,0(sp)
    800057b4:	6105                	addi	sp,sp,32
    800057b6:	8082                	ret
    panic("could not find virtio disk");
    800057b8:	00002517          	auipc	a0,0x2
    800057bc:	e8850513          	addi	a0,a0,-376 # 80007640 <etext+0x640>
    800057c0:	864fb0ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    800057c4:	00002517          	auipc	a0,0x2
    800057c8:	e9c50513          	addi	a0,a0,-356 # 80007660 <etext+0x660>
    800057cc:	858fb0ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    800057d0:	00002517          	auipc	a0,0x2
    800057d4:	eb050513          	addi	a0,a0,-336 # 80007680 <etext+0x680>
    800057d8:	84cfb0ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    800057dc:	00002517          	auipc	a0,0x2
    800057e0:	ec450513          	addi	a0,a0,-316 # 800076a0 <etext+0x6a0>
    800057e4:	840fb0ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    800057e8:	00002517          	auipc	a0,0x2
    800057ec:	ed850513          	addi	a0,a0,-296 # 800076c0 <etext+0x6c0>
    800057f0:	834fb0ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    800057f4:	00002517          	auipc	a0,0x2
    800057f8:	eec50513          	addi	a0,a0,-276 # 800076e0 <etext+0x6e0>
    800057fc:	828fb0ef          	jal	80000824 <panic>

0000000080005800 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005800:	711d                	addi	sp,sp,-96
    80005802:	ec86                	sd	ra,88(sp)
    80005804:	e8a2                	sd	s0,80(sp)
    80005806:	e4a6                	sd	s1,72(sp)
    80005808:	e0ca                	sd	s2,64(sp)
    8000580a:	fc4e                	sd	s3,56(sp)
    8000580c:	f852                	sd	s4,48(sp)
    8000580e:	f456                	sd	s5,40(sp)
    80005810:	f05a                	sd	s6,32(sp)
    80005812:	ec5e                	sd	s7,24(sp)
    80005814:	e862                	sd	s8,16(sp)
    80005816:	1080                	addi	s0,sp,96
    80005818:	89aa                	mv	s3,a0
    8000581a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000581c:	00c52b83          	lw	s7,12(a0)
    80005820:	001b9b9b          	slliw	s7,s7,0x1
    80005824:	1b82                	slli	s7,s7,0x20
    80005826:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    8000582a:	0001e517          	auipc	a0,0x1e
    8000582e:	f0650513          	addi	a0,a0,-250 # 80023730 <disk+0x128>
    80005832:	bf6fb0ef          	jal	80000c28 <acquire>
  for(int i = 0; i < NUM; i++){
    80005836:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005838:	0001ea97          	auipc	s5,0x1e
    8000583c:	dd0a8a93          	addi	s5,s5,-560 # 80023608 <disk>
  for(int i = 0; i < 3; i++){
    80005840:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005842:	5c7d                	li	s8,-1
    80005844:	a095                	j	800058a8 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005846:	00fa8733          	add	a4,s5,a5
    8000584a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000584e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005850:	0207c563          	bltz	a5,8000587a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005854:	2905                	addiw	s2,s2,1
    80005856:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005858:	05490c63          	beq	s2,s4,800058b0 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    8000585c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000585e:	0001e717          	auipc	a4,0x1e
    80005862:	daa70713          	addi	a4,a4,-598 # 80023608 <disk>
    80005866:	4781                	li	a5,0
    if(disk.free[i]){
    80005868:	01874683          	lbu	a3,24(a4)
    8000586c:	fee9                	bnez	a3,80005846 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    8000586e:	2785                	addiw	a5,a5,1
    80005870:	0705                	addi	a4,a4,1
    80005872:	fe979be3          	bne	a5,s1,80005868 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005876:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    8000587a:	01205d63          	blez	s2,80005894 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000587e:	fa042503          	lw	a0,-96(s0)
    80005882:	d41ff0ef          	jal	800055c2 <free_desc>
      for(int j = 0; j < i; j++)
    80005886:	4785                	li	a5,1
    80005888:	0127d663          	bge	a5,s2,80005894 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000588c:	fa442503          	lw	a0,-92(s0)
    80005890:	d33ff0ef          	jal	800055c2 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005894:	0001e597          	auipc	a1,0x1e
    80005898:	e9c58593          	addi	a1,a1,-356 # 80023730 <disk+0x128>
    8000589c:	0001e517          	auipc	a0,0x1e
    800058a0:	d8450513          	addi	a0,a0,-636 # 80023620 <disk+0x18>
    800058a4:	f5cfc0ef          	jal	80002000 <sleep>
  for(int i = 0; i < 3; i++){
    800058a8:	fa040613          	addi	a2,s0,-96
    800058ac:	4901                	li	s2,0
    800058ae:	b77d                	j	8000585c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800058b0:	fa042503          	lw	a0,-96(s0)
    800058b4:	00451693          	slli	a3,a0,0x4

  if(write)
    800058b8:	0001e797          	auipc	a5,0x1e
    800058bc:	d5078793          	addi	a5,a5,-688 # 80023608 <disk>
    800058c0:	00451713          	slli	a4,a0,0x4
    800058c4:	0a070713          	addi	a4,a4,160
    800058c8:	973e                	add	a4,a4,a5
    800058ca:	01603633          	snez	a2,s6
    800058ce:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800058d0:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800058d4:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800058d8:	6398                	ld	a4,0(a5)
    800058da:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800058dc:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    800058e0:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800058e2:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800058e4:	6390                	ld	a2,0(a5)
    800058e6:	00d60833          	add	a6,a2,a3
    800058ea:	4741                	li	a4,16
    800058ec:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800058f0:	4585                	li	a1,1
    800058f2:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    800058f6:	fa442703          	lw	a4,-92(s0)
    800058fa:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800058fe:	0712                	slli	a4,a4,0x4
    80005900:	963a                	add	a2,a2,a4
    80005902:	05898813          	addi	a6,s3,88
    80005906:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000590a:	0007b883          	ld	a7,0(a5)
    8000590e:	9746                	add	a4,a4,a7
    80005910:	40000613          	li	a2,1024
    80005914:	c710                	sw	a2,8(a4)
  if(write)
    80005916:	001b3613          	seqz	a2,s6
    8000591a:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000591e:	8e4d                	or	a2,a2,a1
    80005920:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005924:	fa842603          	lw	a2,-88(s0)
    80005928:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000592c:	00451813          	slli	a6,a0,0x4
    80005930:	02080813          	addi	a6,a6,32
    80005934:	983e                	add	a6,a6,a5
    80005936:	577d                	li	a4,-1
    80005938:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000593c:	0612                	slli	a2,a2,0x4
    8000593e:	98b2                	add	a7,a7,a2
    80005940:	03068713          	addi	a4,a3,48
    80005944:	973e                	add	a4,a4,a5
    80005946:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    8000594a:	6398                	ld	a4,0(a5)
    8000594c:	9732                	add	a4,a4,a2
    8000594e:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005950:	4689                	li	a3,2
    80005952:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005956:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000595a:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    8000595e:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005962:	6794                	ld	a3,8(a5)
    80005964:	0026d703          	lhu	a4,2(a3)
    80005968:	8b1d                	andi	a4,a4,7
    8000596a:	0706                	slli	a4,a4,0x1
    8000596c:	96ba                	add	a3,a3,a4
    8000596e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005972:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005976:	6798                	ld	a4,8(a5)
    80005978:	00275783          	lhu	a5,2(a4)
    8000597c:	2785                	addiw	a5,a5,1
    8000597e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005982:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005986:	100017b7          	lui	a5,0x10001
    8000598a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000598e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005992:	0001e917          	auipc	s2,0x1e
    80005996:	d9e90913          	addi	s2,s2,-610 # 80023730 <disk+0x128>
  while(b->disk == 1) {
    8000599a:	84ae                	mv	s1,a1
    8000599c:	00b79a63          	bne	a5,a1,800059b0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    800059a0:	85ca                	mv	a1,s2
    800059a2:	854e                	mv	a0,s3
    800059a4:	e5cfc0ef          	jal	80002000 <sleep>
  while(b->disk == 1) {
    800059a8:	0049a783          	lw	a5,4(s3)
    800059ac:	fe978ae3          	beq	a5,s1,800059a0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    800059b0:	fa042903          	lw	s2,-96(s0)
    800059b4:	00491713          	slli	a4,s2,0x4
    800059b8:	02070713          	addi	a4,a4,32
    800059bc:	0001e797          	auipc	a5,0x1e
    800059c0:	c4c78793          	addi	a5,a5,-948 # 80023608 <disk>
    800059c4:	97ba                	add	a5,a5,a4
    800059c6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800059ca:	0001e997          	auipc	s3,0x1e
    800059ce:	c3e98993          	addi	s3,s3,-962 # 80023608 <disk>
    800059d2:	00491713          	slli	a4,s2,0x4
    800059d6:	0009b783          	ld	a5,0(s3)
    800059da:	97ba                	add	a5,a5,a4
    800059dc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800059e0:	854a                	mv	a0,s2
    800059e2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800059e6:	bddff0ef          	jal	800055c2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800059ea:	8885                	andi	s1,s1,1
    800059ec:	f0fd                	bnez	s1,800059d2 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800059ee:	0001e517          	auipc	a0,0x1e
    800059f2:	d4250513          	addi	a0,a0,-702 # 80023730 <disk+0x128>
    800059f6:	ac6fb0ef          	jal	80000cbc <release>
}
    800059fa:	60e6                	ld	ra,88(sp)
    800059fc:	6446                	ld	s0,80(sp)
    800059fe:	64a6                	ld	s1,72(sp)
    80005a00:	6906                	ld	s2,64(sp)
    80005a02:	79e2                	ld	s3,56(sp)
    80005a04:	7a42                	ld	s4,48(sp)
    80005a06:	7aa2                	ld	s5,40(sp)
    80005a08:	7b02                	ld	s6,32(sp)
    80005a0a:	6be2                	ld	s7,24(sp)
    80005a0c:	6c42                	ld	s8,16(sp)
    80005a0e:	6125                	addi	sp,sp,96
    80005a10:	8082                	ret

0000000080005a12 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005a12:	1101                	addi	sp,sp,-32
    80005a14:	ec06                	sd	ra,24(sp)
    80005a16:	e822                	sd	s0,16(sp)
    80005a18:	e426                	sd	s1,8(sp)
    80005a1a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005a1c:	0001e497          	auipc	s1,0x1e
    80005a20:	bec48493          	addi	s1,s1,-1044 # 80023608 <disk>
    80005a24:	0001e517          	auipc	a0,0x1e
    80005a28:	d0c50513          	addi	a0,a0,-756 # 80023730 <disk+0x128>
    80005a2c:	9fcfb0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005a30:	100017b7          	lui	a5,0x10001
    80005a34:	53bc                	lw	a5,96(a5)
    80005a36:	8b8d                	andi	a5,a5,3
    80005a38:	10001737          	lui	a4,0x10001
    80005a3c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005a3e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005a42:	689c                	ld	a5,16(s1)
    80005a44:	0204d703          	lhu	a4,32(s1)
    80005a48:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005a4c:	04f70863          	beq	a4,a5,80005a9c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005a50:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005a54:	6898                	ld	a4,16(s1)
    80005a56:	0204d783          	lhu	a5,32(s1)
    80005a5a:	8b9d                	andi	a5,a5,7
    80005a5c:	078e                	slli	a5,a5,0x3
    80005a5e:	97ba                	add	a5,a5,a4
    80005a60:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005a62:	00479713          	slli	a4,a5,0x4
    80005a66:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005a6a:	9726                	add	a4,a4,s1
    80005a6c:	01074703          	lbu	a4,16(a4)
    80005a70:	e329                	bnez	a4,80005ab2 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005a72:	0792                	slli	a5,a5,0x4
    80005a74:	02078793          	addi	a5,a5,32
    80005a78:	97a6                	add	a5,a5,s1
    80005a7a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005a7c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005a80:	dccfc0ef          	jal	8000204c <wakeup>

    disk.used_idx += 1;
    80005a84:	0204d783          	lhu	a5,32(s1)
    80005a88:	2785                	addiw	a5,a5,1
    80005a8a:	17c2                	slli	a5,a5,0x30
    80005a8c:	93c1                	srli	a5,a5,0x30
    80005a8e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005a92:	6898                	ld	a4,16(s1)
    80005a94:	00275703          	lhu	a4,2(a4)
    80005a98:	faf71ce3          	bne	a4,a5,80005a50 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005a9c:	0001e517          	auipc	a0,0x1e
    80005aa0:	c9450513          	addi	a0,a0,-876 # 80023730 <disk+0x128>
    80005aa4:	a18fb0ef          	jal	80000cbc <release>
}
    80005aa8:	60e2                	ld	ra,24(sp)
    80005aaa:	6442                	ld	s0,16(sp)
    80005aac:	64a2                	ld	s1,8(sp)
    80005aae:	6105                	addi	sp,sp,32
    80005ab0:	8082                	ret
      panic("virtio_disk_intr status");
    80005ab2:	00002517          	auipc	a0,0x2
    80005ab6:	c4650513          	addi	a0,a0,-954 # 800076f8 <etext+0x6f8>
    80005aba:	d6bfa0ef          	jal	80000824 <panic>
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
