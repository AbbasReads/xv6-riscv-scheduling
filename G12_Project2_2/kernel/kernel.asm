
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
    80000004:	87010113          	addi	sp,sp,-1936 # 80007870 <stack0>
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
    80000016:	04a000ef          	jal	80000060 <start>

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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdda87>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	dbc78793          	addi	a5,a5,-580 # 80000e3c <main>
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
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
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
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7119                	addi	sp,sp,-128
    800000d2:	fc86                	sd	ra,120(sp)
    800000d4:	f8a2                	sd	s0,112(sp)
    800000d6:	f4a6                	sd	s1,104(sp)
    800000d8:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000da:	06c05a63          	blez	a2,8000014e <consolewrite+0x7e>
    800000de:	f0ca                	sd	s2,96(sp)
    800000e0:	ecce                	sd	s3,88(sp)
    800000e2:	e8d2                	sd	s4,80(sp)
    800000e4:	e4d6                	sd	s5,72(sp)
    800000e6:	e0da                	sd	s6,64(sp)
    800000e8:	fc5e                	sd	s7,56(sp)
    800000ea:	f862                	sd	s8,48(sp)
    800000ec:	f466                	sd	s9,40(sp)
    800000ee:	8aaa                	mv	s5,a0
    800000f0:	8b2e                	mv	s6,a1
    800000f2:	8a32                	mv	s4,a2
  int i = 0;
    800000f4:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f6:	02000c13          	li	s8,32
    800000fa:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fe:	5bfd                	li	s7,-1
    80000100:	a035                	j	8000012c <consolewrite+0x5c>
    if(nn > n - i)
    80000102:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000106:	86ce                	mv	a3,s3
    80000108:	01648633          	add	a2,s1,s6
    8000010c:	85d6                	mv	a1,s5
    8000010e:	f8040513          	addi	a0,s0,-128
    80000112:	1a0020ef          	jal	800022b2 <either_copyin>
    80000116:	03750e63          	beq	a0,s7,80000152 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011a:	85ce                	mv	a1,s3
    8000011c:	f8040513          	addi	a0,s0,-128
    80000120:	778000ef          	jal	80000898 <uartwrite>
    i += nn;
    80000124:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80000128:	0144da63          	bge	s1,s4,8000013c <consolewrite+0x6c>
    if(nn > n - i)
    8000012c:	409a093b          	subw	s2,s4,s1
    80000130:	0009079b          	sext.w	a5,s2
    80000134:	fcfc57e3          	bge	s8,a5,80000102 <consolewrite+0x32>
    80000138:	8966                	mv	s2,s9
    8000013a:	b7e1                	j	80000102 <consolewrite+0x32>
    8000013c:	7906                	ld	s2,96(sp)
    8000013e:	69e6                	ld	s3,88(sp)
    80000140:	6a46                	ld	s4,80(sp)
    80000142:	6aa6                	ld	s5,72(sp)
    80000144:	6b06                	ld	s6,64(sp)
    80000146:	7be2                	ld	s7,56(sp)
    80000148:	7c42                	ld	s8,48(sp)
    8000014a:	7ca2                	ld	s9,40(sp)
    8000014c:	a819                	j	80000162 <consolewrite+0x92>
  int i = 0;
    8000014e:	4481                	li	s1,0
    80000150:	a809                	j	80000162 <consolewrite+0x92>
    80000152:	7906                	ld	s2,96(sp)
    80000154:	69e6                	ld	s3,88(sp)
    80000156:	6a46                	ld	s4,80(sp)
    80000158:	6aa6                	ld	s5,72(sp)
    8000015a:	6b06                	ld	s6,64(sp)
    8000015c:	7be2                	ld	s7,56(sp)
    8000015e:	7c42                	ld	s8,48(sp)
    80000160:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000162:	8526                	mv	a0,s1
    80000164:	70e6                	ld	ra,120(sp)
    80000166:	7446                	ld	s0,112(sp)
    80000168:	74a6                	ld	s1,104(sp)
    8000016a:	6109                	addi	sp,sp,128
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	0000f517          	auipc	a0,0xf
    80000190:	6e450513          	addi	a0,a0,1764 # 8000f870 <cons>
    80000194:	23b000ef          	jal	80000bce <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	0000f497          	auipc	s1,0xf
    8000019c:	6d848493          	addi	s1,s1,1752 # 8000f870 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	0000f917          	auipc	s2,0xf
    800001a4:	76890913          	addi	s2,s2,1896 # 8000f908 <cons+0x98>
  while(n > 0){
    800001a8:	0b305d63          	blez	s3,80000262 <consoleread+0xf4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	0af71263          	bne	a4,a5,80000258 <consoleread+0xea>
      if(killed(myproc())){
    800001b8:	716010ef          	jal	800018ce <myproc>
    800001bc:	789010ef          	jal	80002144 <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	547010ef          	jal	80001f0c <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef703e3          	beq	a4,a5,800001b8 <consoleread+0x4a>
    800001d6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d8:	0000f717          	auipc	a4,0xf
    800001dc:	69870713          	addi	a4,a4,1688 # 8000f870 <cons>
    800001e0:	0017869b          	addiw	a3,a5,1
    800001e4:	08d72c23          	sw	a3,152(a4)
    800001e8:	07f7f693          	andi	a3,a5,127
    800001ec:	9736                	add	a4,a4,a3
    800001ee:	01874703          	lbu	a4,24(a4)
    800001f2:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001f6:	4691                	li	a3,4
    800001f8:	04db8663          	beq	s7,a3,80000244 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001fc:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000200:	4685                	li	a3,1
    80000202:	faf40613          	addi	a2,s0,-81
    80000206:	85d2                	mv	a1,s4
    80000208:	8556                	mv	a0,s5
    8000020a:	05e020ef          	jal	80002268 <either_copyout>
    8000020e:	57fd                	li	a5,-1
    80000210:	04f50863          	beq	a0,a5,80000260 <consoleread+0xf2>
      break;

    dst++;
    80000214:	0a05                	addi	s4,s4,1
    --n;
    80000216:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000218:	47a9                	li	a5,10
    8000021a:	04fb8d63          	beq	s7,a5,80000274 <consoleread+0x106>
    8000021e:	6be2                	ld	s7,24(sp)
    80000220:	b761                	j	800001a8 <consoleread+0x3a>
        release(&cons.lock);
    80000222:	0000f517          	auipc	a0,0xf
    80000226:	64e50513          	addi	a0,a0,1614 # 8000f870 <cons>
    8000022a:	23d000ef          	jal	80000c66 <release>
        return -1;
    8000022e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000230:	60e6                	ld	ra,88(sp)
    80000232:	6446                	ld	s0,80(sp)
    80000234:	64a6                	ld	s1,72(sp)
    80000236:	6906                	ld	s2,64(sp)
    80000238:	79e2                	ld	s3,56(sp)
    8000023a:	7a42                	ld	s4,48(sp)
    8000023c:	7aa2                	ld	s5,40(sp)
    8000023e:	7b02                	ld	s6,32(sp)
    80000240:	6125                	addi	sp,sp,96
    80000242:	8082                	ret
      if(n < target){
    80000244:	0009871b          	sext.w	a4,s3
    80000248:	01677a63          	bgeu	a4,s6,8000025c <consoleread+0xee>
        cons.r--;
    8000024c:	0000f717          	auipc	a4,0xf
    80000250:	6af72e23          	sw	a5,1724(a4) # 8000f908 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	0000f517          	auipc	a0,0xf
    80000266:	60e50513          	addi	a0,a0,1550 # 8000f870 <cons>
    8000026a:	1fd000ef          	jal	80000c66 <release>
  return target - n;
    8000026e:	413b053b          	subw	a0,s6,s3
    80000272:	bf7d                	j	80000230 <consoleread+0xc2>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	b7f5                	j	80000262 <consoleread+0xf4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50863          	beq	a0,a5,80000294 <consputc+0x1c>
    uartputc_sync(c);
    80000288:	6a4000ef          	jal	8000092c <uartputc_sync>
}
    8000028c:	60a2                	ld	ra,8(sp)
    8000028e:	6402                	ld	s0,0(sp)
    80000290:	0141                	addi	sp,sp,16
    80000292:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000294:	4521                	li	a0,8
    80000296:	696000ef          	jal	8000092c <uartputc_sync>
    8000029a:	02000513          	li	a0,32
    8000029e:	68e000ef          	jal	8000092c <uartputc_sync>
    800002a2:	4521                	li	a0,8
    800002a4:	688000ef          	jal	8000092c <uartputc_sync>
    800002a8:	b7d5                	j	8000028c <consputc+0x14>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	1000                	addi	s0,sp,32
    800002b4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b6:	0000f517          	auipc	a0,0xf
    800002ba:	5ba50513          	addi	a0,a0,1466 # 8000f870 <cons>
    800002be:	111000ef          	jal	80000bce <acquire>

  switch(c){
    800002c2:	47d5                	li	a5,21
    800002c4:	08f48f63          	beq	s1,a5,80000362 <consoleintr+0xb8>
    800002c8:	0297c563          	blt	a5,s1,800002f2 <consoleintr+0x48>
    800002cc:	47a1                	li	a5,8
    800002ce:	0ef48463          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    800002d2:	47c1                	li	a5,16
    800002d4:	10f49563          	bne	s1,a5,800003de <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002d8:	024020ef          	jal	800022fc <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002dc:	0000f517          	auipc	a0,0xf
    800002e0:	59450513          	addi	a0,a0,1428 # 8000f870 <cons>
    800002e4:	183000ef          	jal	80000c66 <release>
}
    800002e8:	60e2                	ld	ra,24(sp)
    800002ea:	6442                	ld	s0,16(sp)
    800002ec:	64a2                	ld	s1,8(sp)
    800002ee:	6105                	addi	sp,sp,32
    800002f0:	8082                	ret
  switch(c){
    800002f2:	07f00793          	li	a5,127
    800002f6:	0cf48063          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fa:	0000f717          	auipc	a4,0xf
    800002fe:	57670713          	addi	a4,a4,1398 # 8000f870 <cons>
    80000302:	0a072783          	lw	a5,160(a4)
    80000306:	09872703          	lw	a4,152(a4)
    8000030a:	9f99                	subw	a5,a5,a4
    8000030c:	07f00713          	li	a4,127
    80000310:	fcf766e3          	bltu	a4,a5,800002dc <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000314:	47b5                	li	a5,13
    80000316:	0cf48763          	beq	s1,a5,800003e4 <consoleintr+0x13a>
      consputc(c);
    8000031a:	8526                	mv	a0,s1
    8000031c:	f5dff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000320:	0000f797          	auipc	a5,0xf
    80000324:	55078793          	addi	a5,a5,1360 # 8000f870 <cons>
    80000328:	0a07a683          	lw	a3,160(a5)
    8000032c:	0016871b          	addiw	a4,a3,1
    80000330:	0007061b          	sext.w	a2,a4
    80000334:	0ae7a023          	sw	a4,160(a5)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	97b6                	add	a5,a5,a3
    8000033e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	47a9                	li	a5,10
    80000344:	0cf48563          	beq	s1,a5,8000040e <consoleintr+0x164>
    80000348:	4791                	li	a5,4
    8000034a:	0cf48263          	beq	s1,a5,8000040e <consoleintr+0x164>
    8000034e:	0000f797          	auipc	a5,0xf
    80000352:	5ba7a783          	lw	a5,1466(a5) # 8000f908 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	0000f717          	auipc	a4,0xf
    80000368:	50c70713          	addi	a4,a4,1292 # 8000f870 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	0000f497          	auipc	s1,0xf
    80000378:	4fc48493          	addi	s1,s1,1276 # 8000f870 <cons>
    while(cons.e != cons.w &&
    8000037c:	4929                	li	s2,10
    8000037e:	02f70863          	beq	a4,a5,800003ae <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000382:	37fd                	addiw	a5,a5,-1
    80000384:	07f7f713          	andi	a4,a5,127
    80000388:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000038a:	01874703          	lbu	a4,24(a4)
    8000038e:	03270263          	beq	a4,s2,800003b2 <consoleintr+0x108>
      cons.e--;
    80000392:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000396:	10000513          	li	a0,256
    8000039a:	edfff0ef          	jal	80000278 <consputc>
    while(cons.e != cons.w &&
    8000039e:	0a04a783          	lw	a5,160(s1)
    800003a2:	09c4a703          	lw	a4,156(s1)
    800003a6:	fcf71ee3          	bne	a4,a5,80000382 <consoleintr+0xd8>
    800003aa:	6902                	ld	s2,0(sp)
    800003ac:	bf05                	j	800002dc <consoleintr+0x32>
    800003ae:	6902                	ld	s2,0(sp)
    800003b0:	b735                	j	800002dc <consoleintr+0x32>
    800003b2:	6902                	ld	s2,0(sp)
    800003b4:	b725                	j	800002dc <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b6:	0000f717          	auipc	a4,0xf
    800003ba:	4ba70713          	addi	a4,a4,1210 # 8000f870 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	0000f717          	auipc	a4,0xf
    800003d0:	54f72223          	sw	a5,1348(a4) # 8000f910 <cons+0xa0>
      consputc(BACKSPACE);
    800003d4:	10000513          	li	a0,256
    800003d8:	ea1ff0ef          	jal	80000278 <consputc>
    800003dc:	b701                	j	800002dc <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003de:	ee048fe3          	beqz	s1,800002dc <consoleintr+0x32>
    800003e2:	bf21                	j	800002fa <consoleintr+0x50>
      consputc(c);
    800003e4:	4529                	li	a0,10
    800003e6:	e93ff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003ea:	0000f797          	auipc	a5,0xf
    800003ee:	48678793          	addi	a5,a5,1158 # 8000f870 <cons>
    800003f2:	0a07a703          	lw	a4,160(a5)
    800003f6:	0017069b          	addiw	a3,a4,1
    800003fa:	0006861b          	sext.w	a2,a3
    800003fe:	0ad7a023          	sw	a3,160(a5)
    80000402:	07f77713          	andi	a4,a4,127
    80000406:	97ba                	add	a5,a5,a4
    80000408:	4729                	li	a4,10
    8000040a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040e:	0000f797          	auipc	a5,0xf
    80000412:	4ec7af23          	sw	a2,1278(a5) # 8000f90c <cons+0x9c>
        wakeup(&cons.r);
    80000416:	0000f517          	auipc	a0,0xf
    8000041a:	4f250513          	addi	a0,a0,1266 # 8000f908 <cons+0x98>
    8000041e:	33b010ef          	jal	80001f58 <wakeup>
    80000422:	bd6d                	j	800002dc <consoleintr+0x32>

0000000080000424 <consoleinit>:

void
consoleinit(void)
{
    80000424:	1141                	addi	sp,sp,-16
    80000426:	e406                	sd	ra,8(sp)
    80000428:	e022                	sd	s0,0(sp)
    8000042a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000042c:	00007597          	auipc	a1,0x7
    80000430:	bd458593          	addi	a1,a1,-1068 # 80007000 <etext>
    80000434:	0000f517          	auipc	a0,0xf
    80000438:	43c50513          	addi	a0,a0,1084 # 8000f870 <cons>
    8000043c:	712000ef          	jal	80000b4e <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	0001f797          	auipc	a5,0x1f
    80000448:	79c78793          	addi	a5,a5,1948 # 8001fbe0 <devsw>
    8000044c:	00000717          	auipc	a4,0x0
    80000450:	d2270713          	addi	a4,a4,-734 # 8000016e <consoleread>
    80000454:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000456:	00000717          	auipc	a4,0x0
    8000045a:	c7a70713          	addi	a4,a4,-902 # 800000d0 <consolewrite>
    8000045e:	ef98                	sd	a4,24(a5)
}
    80000460:	60a2                	ld	ra,8(sp)
    80000462:	6402                	ld	s0,0(sp)
    80000464:	0141                	addi	sp,sp,16
    80000466:	8082                	ret

0000000080000468 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000468:	7139                	addi	sp,sp,-64
    8000046a:	fc06                	sd	ra,56(sp)
    8000046c:	f822                	sd	s0,48(sp)
    8000046e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000470:	c219                	beqz	a2,80000476 <printint+0xe>
    80000472:	08054063          	bltz	a0,800004f2 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000476:	4881                	li	a7,0
    80000478:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000047c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00007617          	auipc	a2,0x7
    80000482:	29260613          	addi	a2,a2,658 # 80007710 <digits>
    80000486:	883e                	mv	a6,a5
    80000488:	2785                	addiw	a5,a5,1
    8000048a:	02b57733          	remu	a4,a0,a1
    8000048e:	9732                	add	a4,a4,a2
    80000490:	00074703          	lbu	a4,0(a4)
    80000494:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000498:	872a                	mv	a4,a0
    8000049a:	02b55533          	divu	a0,a0,a1
    8000049e:	0685                	addi	a3,a3,1
    800004a0:	feb773e3          	bgeu	a4,a1,80000486 <printint+0x1e>

  if(sign)
    800004a4:	00088a63          	beqz	a7,800004b8 <printint+0x50>
    buf[i++] = '-';
    800004a8:	1781                	addi	a5,a5,-32
    800004aa:	97a2                	add	a5,a5,s0
    800004ac:	02d00713          	li	a4,45
    800004b0:	fee78423          	sb	a4,-24(a5)
    800004b4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800004b8:	02f05963          	blez	a5,800004ea <printint+0x82>
    800004bc:	f426                	sd	s1,40(sp)
    800004be:	f04a                	sd	s2,32(sp)
    800004c0:	fc840713          	addi	a4,s0,-56
    800004c4:	00f704b3          	add	s1,a4,a5
    800004c8:	fff70913          	addi	s2,a4,-1
    800004cc:	993e                	add	s2,s2,a5
    800004ce:	37fd                	addiw	a5,a5,-1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004d8:	fff4c503          	lbu	a0,-1(s1)
    800004dc:	d9dff0ef          	jal	80000278 <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x70>
    800004e6:	74a2                	ld	s1,40(sp)
    800004e8:	7902                	ld	s2,32(sp)
}
    800004ea:	70e2                	ld	ra,56(sp)
    800004ec:	7442                	ld	s0,48(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4885                	li	a7,1
    x = -xx;
    800004f8:	b741                	j	80000478 <printint+0x10>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	e8d2                	sd	s4,80(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	8a2a                	mv	s4,a0
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
    8000051c:	32c7a783          	lw	a5,812(a5) # 80007844 <panicking>
    80000520:	c3a1                	beqz	a5,80000560 <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	000a4503          	lbu	a0,0(s4)
    8000052e:	28050763          	beqz	a0,800007bc <printf+0x2c2>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	f0ca                	sd	s2,96(sp)
    80000536:	ecce                	sd	s3,88(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	f862                	sd	s8,48(sp)
    8000053e:	f466                	sd	s9,40(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4981                	li	s3,0
    if(cx != '%'){
    80000546:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000054a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000054e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000552:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000556:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000055a:	07000d93          	li	s11,112
    8000055e:	a01d                	j	80000584 <printf+0x8a>
    acquire(&pr.lock);
    80000560:	0000f517          	auipc	a0,0xf
    80000564:	3b850513          	addi	a0,a0,952 # 8000f918 <pr>
    80000568:	666000ef          	jal	80000bce <acquire>
    8000056c:	bf5d                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056e:	d0bff0ef          	jal	80000278 <consputc>
      continue;
    80000572:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000574:	0014899b          	addiw	s3,s1,1
    80000578:	013a07b3          	add	a5,s4,s3
    8000057c:	0007c503          	lbu	a0,0(a5)
    80000580:	20050b63          	beqz	a0,80000796 <printf+0x29c>
    if(cx != '%'){
    80000584:	ff5515e3          	bne	a0,s5,8000056e <printf+0x74>
    i++;
    80000588:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000058c:	009a07b3          	add	a5,s4,s1
    80000590:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000594:	20090b63          	beqz	s2,800007aa <printf+0x2b0>
    80000598:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000059c:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059e:	c789                	beqz	a5,800005a8 <printf+0xae>
    800005a0:	009a0733          	add	a4,s4,s1
    800005a4:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800005a8:	03690963          	beq	s2,s6,800005da <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    800005ac:	05890363          	beq	s2,s8,800005f2 <printf+0xf8>
    } else if(c0 == 'u'){
    800005b0:	0d990663          	beq	s2,s9,8000067c <printf+0x182>
    } else if(c0 == 'x'){
    800005b4:	11a90d63          	beq	s2,s10,800006ce <printf+0x1d4>
    } else if(c0 == 'p'){
    800005b8:	15b90663          	beq	s2,s11,80000704 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800005bc:	06300793          	li	a5,99
    800005c0:	18f90563          	beq	s2,a5,8000074a <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800005c4:	07300793          	li	a5,115
    800005c8:	18f90b63          	beq	s2,a5,8000075e <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005cc:	03591b63          	bne	s2,s5,80000602 <printf+0x108>
      consputc('%');
    800005d0:	02500513          	li	a0,37
    800005d4:	ca5ff0ef          	jal	80000278 <consputc>
    800005d8:	bf71                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005da:	f8843783          	ld	a5,-120(s0)
    800005de:	00878713          	addi	a4,a5,8
    800005e2:	f8e43423          	sd	a4,-120(s0)
    800005e6:	4605                	li	a2,1
    800005e8:	45a9                	li	a1,10
    800005ea:	4388                	lw	a0,0(a5)
    800005ec:	e7dff0ef          	jal	80000468 <printint>
    800005f0:	b751                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    800005f2:	01678f63          	beq	a5,s6,80000610 <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005f6:	03878b63          	beq	a5,s8,8000062c <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    800005fa:	09978e63          	beq	a5,s9,80000696 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    800005fe:	0fa78563          	beq	a5,s10,800006e8 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000602:	8556                	mv	a0,s5
    80000604:	c75ff0ef          	jal	80000278 <consputc>
      consputc(c0);
    80000608:	854a                	mv	a0,s2
    8000060a:	c6fff0ef          	jal	80000278 <consputc>
    8000060e:	b79d                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000610:	f8843783          	ld	a5,-120(s0)
    80000614:	00878713          	addi	a4,a5,8
    80000618:	f8e43423          	sd	a4,-120(s0)
    8000061c:	4605                	li	a2,1
    8000061e:	45a9                	li	a1,10
    80000620:	6388                	ld	a0,0(a5)
    80000622:	e47ff0ef          	jal	80000468 <printint>
      i += 1;
    80000626:	0029849b          	addiw	s1,s3,2
    8000062a:	b7a9                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000062c:	06400793          	li	a5,100
    80000630:	02f68863          	beq	a3,a5,80000660 <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000634:	07500793          	li	a5,117
    80000638:	06f68d63          	beq	a3,a5,800006b2 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000063c:	07800793          	li	a5,120
    80000640:	fcf691e3          	bne	a3,a5,80000602 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4601                	li	a2,0
    80000652:	45c1                	li	a1,16
    80000654:	6388                	ld	a0,0(a5)
    80000656:	e13ff0ef          	jal	80000468 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bf19                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4605                	li	a2,1
    8000066e:	45a9                	li	a1,10
    80000670:	6388                	ld	a0,0(a5)
    80000672:	df7ff0ef          	jal	80000468 <printint>
      i += 2;
    80000676:	0039849b          	addiw	s1,s3,3
    8000067a:	bded                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4601                	li	a2,0
    8000068a:	45a9                	li	a1,10
    8000068c:	0007e503          	lwu	a0,0(a5)
    80000690:	dd9ff0ef          	jal	80000468 <printint>
    80000694:	b5c5                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	4601                	li	a2,0
    800006a4:	45a9                	li	a1,10
    800006a6:	6388                	ld	a0,0(a5)
    800006a8:	dc1ff0ef          	jal	80000468 <printint>
      i += 1;
    800006ac:	0029849b          	addiw	s1,s3,2
    800006b0:	b5d1                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4601                	li	a2,0
    800006c0:	45a9                	li	a1,10
    800006c2:	6388                	ld	a0,0(a5)
    800006c4:	da5ff0ef          	jal	80000468 <printint>
      i += 2;
    800006c8:	0039849b          	addiw	s1,s3,3
    800006cc:	b565                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	4601                	li	a2,0
    800006dc:	45c1                	li	a1,16
    800006de:	0007e503          	lwu	a0,0(a5)
    800006e2:	d87ff0ef          	jal	80000468 <printint>
    800006e6:	b579                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	4601                	li	a2,0
    800006f6:	45c1                	li	a1,16
    800006f8:	6388                	ld	a0,0(a5)
    800006fa:	d6fff0ef          	jal	80000468 <printint>
      i += 1;
    800006fe:	0029849b          	addiw	s1,s3,2
    80000702:	bd8d                	j	80000574 <printf+0x7a>
    80000704:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000706:	f8843783          	ld	a5,-120(s0)
    8000070a:	00878713          	addi	a4,a5,8
    8000070e:	f8e43423          	sd	a4,-120(s0)
    80000712:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000716:	03000513          	li	a0,48
    8000071a:	b5fff0ef          	jal	80000278 <consputc>
  consputc('x');
    8000071e:	07800513          	li	a0,120
    80000722:	b57ff0ef          	jal	80000278 <consputc>
    80000726:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000728:	00007b97          	auipc	s7,0x7
    8000072c:	fe8b8b93          	addi	s7,s7,-24 # 80007710 <digits>
    80000730:	03c9d793          	srli	a5,s3,0x3c
    80000734:	97de                	add	a5,a5,s7
    80000736:	0007c503          	lbu	a0,0(a5)
    8000073a:	b3fff0ef          	jal	80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000073e:	0992                	slli	s3,s3,0x4
    80000740:	397d                	addiw	s2,s2,-1
    80000742:	fe0917e3          	bnez	s2,80000730 <printf+0x236>
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	b535                	j	80000574 <printf+0x7a>
      consputc(va_arg(ap, uint));
    8000074a:	f8843783          	ld	a5,-120(s0)
    8000074e:	00878713          	addi	a4,a5,8
    80000752:	f8e43423          	sd	a4,-120(s0)
    80000756:	4388                	lw	a0,0(a5)
    80000758:	b21ff0ef          	jal	80000278 <consputc>
    8000075c:	bd21                	j	80000574 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000075e:	f8843783          	ld	a5,-120(s0)
    80000762:	00878713          	addi	a4,a5,8
    80000766:	f8e43423          	sd	a4,-120(s0)
    8000076a:	0007b903          	ld	s2,0(a5)
    8000076e:	00090d63          	beqz	s2,80000788 <printf+0x28e>
      for(; *s; s++)
    80000772:	00094503          	lbu	a0,0(s2)
    80000776:	de050fe3          	beqz	a0,80000574 <printf+0x7a>
        consputc(*s);
    8000077a:	affff0ef          	jal	80000278 <consputc>
      for(; *s; s++)
    8000077e:	0905                	addi	s2,s2,1
    80000780:	00094503          	lbu	a0,0(s2)
    80000784:	f97d                	bnez	a0,8000077a <printf+0x280>
    80000786:	b3fd                	j	80000574 <printf+0x7a>
        s = "(null)";
    80000788:	00007917          	auipc	s2,0x7
    8000078c:	88090913          	addi	s2,s2,-1920 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000790:	02800513          	li	a0,40
    80000794:	b7dd                	j	8000077a <printf+0x280>
    80000796:	74a6                	ld	s1,104(sp)
    80000798:	7906                	ld	s2,96(sp)
    8000079a:	69e6                	ld	s3,88(sp)
    8000079c:	6aa6                	ld	s5,72(sp)
    8000079e:	6b06                	ld	s6,64(sp)
    800007a0:	7c42                	ld	s8,48(sp)
    800007a2:	7ca2                	ld	s9,40(sp)
    800007a4:	7d02                	ld	s10,32(sp)
    800007a6:	6de2                	ld	s11,24(sp)
    800007a8:	a811                	j	800007bc <printf+0x2c2>
    800007aa:	74a6                	ld	s1,104(sp)
    800007ac:	7906                	ld	s2,96(sp)
    800007ae:	69e6                	ld	s3,88(sp)
    800007b0:	6aa6                	ld	s5,72(sp)
    800007b2:	6b06                	ld	s6,64(sp)
    800007b4:	7c42                	ld	s8,48(sp)
    800007b6:	7ca2                	ld	s9,40(sp)
    800007b8:	7d02                	ld	s10,32(sp)
    800007ba:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    800007bc:	00007797          	auipc	a5,0x7
    800007c0:	0887a783          	lw	a5,136(a5) # 80007844 <panicking>
    800007c4:	c799                	beqz	a5,800007d2 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007c6:	4501                	li	a0,0
    800007c8:	70e6                	ld	ra,120(sp)
    800007ca:	7446                	ld	s0,112(sp)
    800007cc:	6a46                	ld	s4,80(sp)
    800007ce:	6129                	addi	sp,sp,192
    800007d0:	8082                	ret
    release(&pr.lock);
    800007d2:	0000f517          	auipc	a0,0xf
    800007d6:	14650513          	addi	a0,a0,326 # 8000f918 <pr>
    800007da:	48c000ef          	jal	80000c66 <release>
  return 0;
    800007de:	b7e5                	j	800007c6 <printf+0x2cc>

00000000800007e0 <panic>:

void
panic(char *s)
{
    800007e0:	1101                	addi	sp,sp,-32
    800007e2:	ec06                	sd	ra,24(sp)
    800007e4:	e822                	sd	s0,16(sp)
    800007e6:	e426                	sd	s1,8(sp)
    800007e8:	e04a                	sd	s2,0(sp)
    800007ea:	1000                	addi	s0,sp,32
    800007ec:	84aa                	mv	s1,a0
  panicking = 1;
    800007ee:	4905                	li	s2,1
    800007f0:	00007797          	auipc	a5,0x7
    800007f4:	0527aa23          	sw	s2,84(a5) # 80007844 <panicking>
  printf("panic: ");
    800007f8:	00007517          	auipc	a0,0x7
    800007fc:	82050513          	addi	a0,a0,-2016 # 80007018 <etext+0x18>
    80000800:	cfbff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000804:	85a6                	mv	a1,s1
    80000806:	00007517          	auipc	a0,0x7
    8000080a:	81a50513          	addi	a0,a0,-2022 # 80007020 <etext+0x20>
    8000080e:	cedff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000812:	00007797          	auipc	a5,0x7
    80000816:	0327a723          	sw	s2,46(a5) # 80007840 <panicked>
  for(;;)
    8000081a:	a001                	j	8000081a <panic+0x3a>

000000008000081c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000081c:	1141                	addi	sp,sp,-16
    8000081e:	e406                	sd	ra,8(sp)
    80000820:	e022                	sd	s0,0(sp)
    80000822:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000824:	00007597          	auipc	a1,0x7
    80000828:	80458593          	addi	a1,a1,-2044 # 80007028 <etext+0x28>
    8000082c:	0000f517          	auipc	a0,0xf
    80000830:	0ec50513          	addi	a0,a0,236 # 8000f918 <pr>
    80000834:	31a000ef          	jal	80000b4e <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000840:	1141                	addi	sp,sp,-16
    80000842:	e406                	sd	ra,8(sp)
    80000844:	e022                	sd	s0,0(sp)
    80000846:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000848:	100007b7          	lui	a5,0x10000
    8000084c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000850:	10000737          	lui	a4,0x10000
    80000854:	f8000693          	li	a3,-128
    80000858:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000085c:	468d                	li	a3,3
    8000085e:	10000637          	lui	a2,0x10000
    80000862:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000866:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000086a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	461d                	li	a2,7
    80000874:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000878:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    8000087c:	00006597          	auipc	a1,0x6
    80000880:	7b458593          	addi	a1,a1,1972 # 80007030 <etext+0x30>
    80000884:	0000f517          	auipc	a0,0xf
    80000888:	0ac50513          	addi	a0,a0,172 # 8000f930 <tx_lock>
    8000088c:	2c2000ef          	jal	80000b4e <initlock>
}
    80000890:	60a2                	ld	ra,8(sp)
    80000892:	6402                	ld	s0,0(sp)
    80000894:	0141                	addi	sp,sp,16
    80000896:	8082                	ret

0000000080000898 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000898:	715d                	addi	sp,sp,-80
    8000089a:	e486                	sd	ra,72(sp)
    8000089c:	e0a2                	sd	s0,64(sp)
    8000089e:	fc26                	sd	s1,56(sp)
    800008a0:	ec56                	sd	s5,24(sp)
    800008a2:	0880                	addi	s0,sp,80
    800008a4:	8aaa                	mv	s5,a0
    800008a6:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008a8:	0000f517          	auipc	a0,0xf
    800008ac:	08850513          	addi	a0,a0,136 # 8000f930 <tx_lock>
    800008b0:	31e000ef          	jal	80000bce <acquire>

  int i = 0;
  while(i < n){ 
    800008b4:	06905063          	blez	s1,80000914 <uartwrite+0x7c>
    800008b8:	f84a                	sd	s2,48(sp)
    800008ba:	f44e                	sd	s3,40(sp)
    800008bc:	f052                	sd	s4,32(sp)
    800008be:	e85a                	sd	s6,16(sp)
    800008c0:	e45e                	sd	s7,8(sp)
    800008c2:	8a56                	mv	s4,s5
    800008c4:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800008c6:	00007497          	auipc	s1,0x7
    800008ca:	f8648493          	addi	s1,s1,-122 # 8000784c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	0000f997          	auipc	s3,0xf
    800008d2:	06298993          	addi	s3,s3,98 # 8000f930 <tx_lock>
    800008d6:	00007917          	auipc	s2,0x7
    800008da:	f7290913          	addi	s2,s2,-142 # 80007848 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    800008de:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    800008e2:	4b05                	li	s6,1
    800008e4:	a005                	j	80000904 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    800008e6:	85ce                	mv	a1,s3
    800008e8:	854a                	mv	a0,s2
    800008ea:	622010ef          	jal	80001f0c <sleep>
    while(tx_busy != 0){
    800008ee:	409c                	lw	a5,0(s1)
    800008f0:	fbfd                	bnez	a5,800008e6 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    800008f2:	000a4783          	lbu	a5,0(s4)
    800008f6:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008fa:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008fe:	0a05                	addi	s4,s4,1
    80000900:	015a0563          	beq	s4,s5,8000090a <uartwrite+0x72>
    while(tx_busy != 0){
    80000904:	409c                	lw	a5,0(s1)
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x4e>
    80000908:	b7ed                	j	800008f2 <uartwrite+0x5a>
    8000090a:	7942                	ld	s2,48(sp)
    8000090c:	79a2                	ld	s3,40(sp)
    8000090e:	7a02                	ld	s4,32(sp)
    80000910:	6b42                	ld	s6,16(sp)
    80000912:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000914:	0000f517          	auipc	a0,0xf
    80000918:	01c50513          	addi	a0,a0,28 # 8000f930 <tx_lock>
    8000091c:	34a000ef          	jal	80000c66 <release>
}
    80000920:	60a6                	ld	ra,72(sp)
    80000922:	6406                	ld	s0,64(sp)
    80000924:	74e2                	ld	s1,56(sp)
    80000926:	6ae2                	ld	s5,24(sp)
    80000928:	6161                	addi	sp,sp,80
    8000092a:	8082                	ret

000000008000092c <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092c:	1101                	addi	sp,sp,-32
    8000092e:	ec06                	sd	ra,24(sp)
    80000930:	e822                	sd	s0,16(sp)
    80000932:	e426                	sd	s1,8(sp)
    80000934:	1000                	addi	s0,sp,32
    80000936:	84aa                	mv	s1,a0
  if(panicking == 0)
    80000938:	00007797          	auipc	a5,0x7
    8000093c:	f0c7a783          	lw	a5,-244(a5) # 80007844 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	00007797          	auipc	a5,0x7
    80000946:	efe7a783          	lw	a5,-258(a5) # 80007840 <panicked>
    8000094a:	ef85                	bnez	a5,80000982 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094c:	10000737          	lui	a4,0x10000
    80000950:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000952:	00074783          	lbu	a5,0(a4)
    80000956:	0207f793          	andi	a5,a5,32
    8000095a:	dfe5                	beqz	a5,80000952 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095c:	0ff4f513          	zext.b	a0,s1
    80000960:	100007b7          	lui	a5,0x10000
    80000964:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000968:	00007797          	auipc	a5,0x7
    8000096c:	edc7a783          	lw	a5,-292(a5) # 80007844 <panicking>
    80000970:	cb91                	beqz	a5,80000984 <uartputc_sync+0x58>
    pop_off();
}
    80000972:	60e2                	ld	ra,24(sp)
    80000974:	6442                	ld	s0,16(sp)
    80000976:	64a2                	ld	s1,8(sp)
    80000978:	6105                	addi	sp,sp,32
    8000097a:	8082                	ret
    push_off();
    8000097c:	212000ef          	jal	80000b8e <push_off>
    80000980:	b7c9                	j	80000942 <uartputc_sync+0x16>
    for(;;)
    80000982:	a001                	j	80000982 <uartputc_sync+0x56>
    pop_off();
    80000984:	28e000ef          	jal	80000c12 <pop_off>
}
    80000988:	b7ed                	j	80000972 <uartputc_sync+0x46>

000000008000098a <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000098a:	1141                	addi	sp,sp,-16
    8000098c:	e422                	sd	s0,8(sp)
    8000098e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000990:	100007b7          	lui	a5,0x10000
    80000994:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80000996:	0007c783          	lbu	a5,0(a5)
    8000099a:	8b85                	andi	a5,a5,1
    8000099c:	cb81                	beqz	a5,800009ac <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    8000099e:	100007b7          	lui	a5,0x10000
    800009a2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a6:	6422                	ld	s0,8(sp)
    800009a8:	0141                	addi	sp,sp,16
    800009aa:	8082                	ret
    return -1;
    800009ac:	557d                	li	a0,-1
    800009ae:	bfe5                	j	800009a6 <uartgetc+0x1c>

00000000800009b0 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009b0:	1101                	addi	sp,sp,-32
    800009b2:	ec06                	sd	ra,24(sp)
    800009b4:	e822                	sd	s0,16(sp)
    800009b6:	e426                	sd	s1,8(sp)
    800009b8:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009ba:	100007b7          	lui	a5,0x10000
    800009be:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    800009c0:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    800009c4:	0000f517          	auipc	a0,0xf
    800009c8:	f6c50513          	addi	a0,a0,-148 # 8000f930 <tx_lock>
    800009cc:	202000ef          	jal	80000bce <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    800009d0:	100007b7          	lui	a5,0x10000
    800009d4:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009d6:	0007c783          	lbu	a5,0(a5)
    800009da:	0207f793          	andi	a5,a5,32
    800009de:	eb89                	bnez	a5,800009f0 <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800009e0:	0000f517          	auipc	a0,0xf
    800009e4:	f5050513          	addi	a0,a0,-176 # 8000f930 <tx_lock>
    800009e8:	27e000ef          	jal	80000c66 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	00007797          	auipc	a5,0x7
    800009f4:	e407ae23          	sw	zero,-420(a5) # 8000784c <tx_busy>
    wakeup(&tx_chan);
    800009f8:	00007517          	auipc	a0,0x7
    800009fc:	e5050513          	addi	a0,a0,-432 # 80007848 <tx_chan>
    80000a00:	558010ef          	jal	80001f58 <wakeup>
    80000a04:	bff1                	j	800009e0 <uartintr+0x30>
      break;
    consoleintr(c);
    80000a06:	8a5ff0ef          	jal	800002aa <consoleintr>
    int c = uartgetc();
    80000a0a:	f81ff0ef          	jal	8000098a <uartgetc>
    if(c == -1)
    80000a0e:	fe951ce3          	bne	a0,s1,80000a06 <uartintr+0x56>
  }
}
    80000a12:	60e2                	ld	ra,24(sp)
    80000a14:	6442                	ld	s0,16(sp)
    80000a16:	64a2                	ld	s1,8(sp)
    80000a18:	6105                	addi	sp,sp,32
    80000a1a:	8082                	ret

0000000080000a1c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a1c:	1101                	addi	sp,sp,-32
    80000a1e:	ec06                	sd	ra,24(sp)
    80000a20:	e822                	sd	s0,16(sp)
    80000a22:	e426                	sd	s1,8(sp)
    80000a24:	e04a                	sd	s2,0(sp)
    80000a26:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a28:	03451793          	slli	a5,a0,0x34
    80000a2c:	e7a9                	bnez	a5,80000a76 <kfree+0x5a>
    80000a2e:	84aa                	mv	s1,a0
    80000a30:	00020797          	auipc	a5,0x20
    80000a34:	34878793          	addi	a5,a5,840 # 80020d78 <end>
    80000a38:	02f56f63          	bltu	a0,a5,80000a76 <kfree+0x5a>
    80000a3c:	47c5                	li	a5,17
    80000a3e:	07ee                	slli	a5,a5,0x1b
    80000a40:	02f57b63          	bgeu	a0,a5,80000a76 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a44:	6605                	lui	a2,0x1
    80000a46:	4585                	li	a1,1
    80000a48:	25a000ef          	jal	80000ca2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a4c:	0000f917          	auipc	s2,0xf
    80000a50:	efc90913          	addi	s2,s2,-260 # 8000f948 <kmem>
    80000a54:	854a                	mv	a0,s2
    80000a56:	178000ef          	jal	80000bce <acquire>
  r->next = kmem.freelist;
    80000a5a:	01893783          	ld	a5,24(s2)
    80000a5e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a60:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a64:	854a                	mv	a0,s2
    80000a66:	200000ef          	jal	80000c66 <release>
}
    80000a6a:	60e2                	ld	ra,24(sp)
    80000a6c:	6442                	ld	s0,16(sp)
    80000a6e:	64a2                	ld	s1,8(sp)
    80000a70:	6902                	ld	s2,0(sp)
    80000a72:	6105                	addi	sp,sp,32
    80000a74:	8082                	ret
    panic("kfree");
    80000a76:	00006517          	auipc	a0,0x6
    80000a7a:	5c250513          	addi	a0,a0,1474 # 80007038 <etext+0x38>
    80000a7e:	d63ff0ef          	jal	800007e0 <panic>

0000000080000a82 <freerange>:
{
    80000a82:	7179                	addi	sp,sp,-48
    80000a84:	f406                	sd	ra,40(sp)
    80000a86:	f022                	sd	s0,32(sp)
    80000a88:	ec26                	sd	s1,24(sp)
    80000a8a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a8c:	6785                	lui	a5,0x1
    80000a8e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a92:	00e504b3          	add	s1,a0,a4
    80000a96:	777d                	lui	a4,0xfffff
    80000a98:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a9a:	94be                	add	s1,s1,a5
    80000a9c:	0295e263          	bltu	a1,s1,80000ac0 <freerange+0x3e>
    80000aa0:	e84a                	sd	s2,16(sp)
    80000aa2:	e44e                	sd	s3,8(sp)
    80000aa4:	e052                	sd	s4,0(sp)
    80000aa6:	892e                	mv	s2,a1
    kfree(p);
    80000aa8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aaa:	6985                	lui	s3,0x1
    kfree(p);
    80000aac:	01448533          	add	a0,s1,s4
    80000ab0:	f6dff0ef          	jal	80000a1c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab4:	94ce                	add	s1,s1,s3
    80000ab6:	fe997be3          	bgeu	s2,s1,80000aac <freerange+0x2a>
    80000aba:	6942                	ld	s2,16(sp)
    80000abc:	69a2                	ld	s3,8(sp)
    80000abe:	6a02                	ld	s4,0(sp)
}
    80000ac0:	70a2                	ld	ra,40(sp)
    80000ac2:	7402                	ld	s0,32(sp)
    80000ac4:	64e2                	ld	s1,24(sp)
    80000ac6:	6145                	addi	sp,sp,48
    80000ac8:	8082                	ret

0000000080000aca <kinit>:
{
    80000aca:	1141                	addi	sp,sp,-16
    80000acc:	e406                	sd	ra,8(sp)
    80000ace:	e022                	sd	s0,0(sp)
    80000ad0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ad2:	00006597          	auipc	a1,0x6
    80000ad6:	56e58593          	addi	a1,a1,1390 # 80007040 <etext+0x40>
    80000ada:	0000f517          	auipc	a0,0xf
    80000ade:	e6e50513          	addi	a0,a0,-402 # 8000f948 <kmem>
    80000ae2:	06c000ef          	jal	80000b4e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ae6:	45c5                	li	a1,17
    80000ae8:	05ee                	slli	a1,a1,0x1b
    80000aea:	00020517          	auipc	a0,0x20
    80000aee:	28e50513          	addi	a0,a0,654 # 80020d78 <end>
    80000af2:	f91ff0ef          	jal	80000a82 <freerange>
}
    80000af6:	60a2                	ld	ra,8(sp)
    80000af8:	6402                	ld	s0,0(sp)
    80000afa:	0141                	addi	sp,sp,16
    80000afc:	8082                	ret

0000000080000afe <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000afe:	1101                	addi	sp,sp,-32
    80000b00:	ec06                	sd	ra,24(sp)
    80000b02:	e822                	sd	s0,16(sp)
    80000b04:	e426                	sd	s1,8(sp)
    80000b06:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b08:	0000f497          	auipc	s1,0xf
    80000b0c:	e4048493          	addi	s1,s1,-448 # 8000f948 <kmem>
    80000b10:	8526                	mv	a0,s1
    80000b12:	0bc000ef          	jal	80000bce <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c485                	beqz	s1,80000b40 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	0000f517          	auipc	a0,0xf
    80000b20:	e2c50513          	addi	a0,a0,-468 # 8000f948 <kmem>
    80000b24:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b26:	140000ef          	jal	80000c66 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b2a:	6605                	lui	a2,0x1
    80000b2c:	4595                	li	a1,5
    80000b2e:	8526                	mv	a0,s1
    80000b30:	172000ef          	jal	80000ca2 <memset>
  return (void*)r;
}
    80000b34:	8526                	mv	a0,s1
    80000b36:	60e2                	ld	ra,24(sp)
    80000b38:	6442                	ld	s0,16(sp)
    80000b3a:	64a2                	ld	s1,8(sp)
    80000b3c:	6105                	addi	sp,sp,32
    80000b3e:	8082                	ret
  release(&kmem.lock);
    80000b40:	0000f517          	auipc	a0,0xf
    80000b44:	e0850513          	addi	a0,a0,-504 # 8000f948 <kmem>
    80000b48:	11e000ef          	jal	80000c66 <release>
  if(r)
    80000b4c:	b7e5                	j	80000b34 <kalloc+0x36>

0000000080000b4e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b4e:	1141                	addi	sp,sp,-16
    80000b50:	e422                	sd	s0,8(sp)
    80000b52:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b54:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b56:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b5a:	00053823          	sd	zero,16(a0)
}
    80000b5e:	6422                	ld	s0,8(sp)
    80000b60:	0141                	addi	sp,sp,16
    80000b62:	8082                	ret

0000000080000b64 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b64:	411c                	lw	a5,0(a0)
    80000b66:	e399                	bnez	a5,80000b6c <holding+0x8>
    80000b68:	4501                	li	a0,0
  return r;
}
    80000b6a:	8082                	ret
{
    80000b6c:	1101                	addi	sp,sp,-32
    80000b6e:	ec06                	sd	ra,24(sp)
    80000b70:	e822                	sd	s0,16(sp)
    80000b72:	e426                	sd	s1,8(sp)
    80000b74:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b76:	6904                	ld	s1,16(a0)
    80000b78:	53b000ef          	jal	800018b2 <mycpu>
    80000b7c:	40a48533          	sub	a0,s1,a0
    80000b80:	00153513          	seqz	a0,a0
}
    80000b84:	60e2                	ld	ra,24(sp)
    80000b86:	6442                	ld	s0,16(sp)
    80000b88:	64a2                	ld	s1,8(sp)
    80000b8a:	6105                	addi	sp,sp,32
    80000b8c:	8082                	ret

0000000080000b8e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8e:	1101                	addi	sp,sp,-32
    80000b90:	ec06                	sd	ra,24(sp)
    80000b92:	e822                	sd	s0,16(sp)
    80000b94:	e426                	sd	s1,8(sp)
    80000b96:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b98:	100024f3          	csrr	s1,sstatus
    80000b9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000ba0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ba2:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000ba6:	50d000ef          	jal	800018b2 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cb99                	beqz	a5,80000bc2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	505000ef          	jal	800018b2 <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	4f1000ef          	jal	800018b2 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc6:	8085                	srli	s1,s1,0x1
    80000bc8:	8885                	andi	s1,s1,1
    80000bca:	dd64                	sw	s1,124(a0)
    80000bcc:	b7cd                	j	80000bae <push_off+0x20>

0000000080000bce <acquire>:
{
    80000bce:	1101                	addi	sp,sp,-32
    80000bd0:	ec06                	sd	ra,24(sp)
    80000bd2:	e822                	sd	s0,16(sp)
    80000bd4:	e426                	sd	s1,8(sp)
    80000bd6:	1000                	addi	s0,sp,32
    80000bd8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bda:	fb5ff0ef          	jal	80000b8e <push_off>
  if(holding(lk))
    80000bde:	8526                	mv	a0,s1
    80000be0:	f85ff0ef          	jal	80000b64 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	4705                	li	a4,1
  if(holding(lk))
    80000be6:	e105                	bnez	a0,80000c06 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be8:	87ba                	mv	a5,a4
    80000bea:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bee:	2781                	sext.w	a5,a5
    80000bf0:	ffe5                	bnez	a5,80000be8 <acquire+0x1a>
  __sync_synchronize();
    80000bf2:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bf6:	4bd000ef          	jal	800018b2 <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00006517          	auipc	a0,0x6
    80000c0a:	44250513          	addi	a0,a0,1090 # 80007048 <etext+0x48>
    80000c0e:	bd3ff0ef          	jal	800007e0 <panic>

0000000080000c12 <pop_off>:

void
pop_off(void)
{
    80000c12:	1141                	addi	sp,sp,-16
    80000c14:	e406                	sd	ra,8(sp)
    80000c16:	e022                	sd	s0,0(sp)
    80000c18:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1a:	499000ef          	jal	800018b2 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c1e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c22:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c24:	e78d                	bnez	a5,80000c4e <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c26:	5d3c                	lw	a5,120(a0)
    80000c28:	02f05963          	blez	a5,80000c5a <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c2c:	37fd                	addiw	a5,a5,-1
    80000c2e:	0007871b          	sext.w	a4,a5
    80000c32:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c34:	eb09                	bnez	a4,80000c46 <pop_off+0x34>
    80000c36:	5d7c                	lw	a5,124(a0)
    80000c38:	c799                	beqz	a5,80000c46 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c3e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c42:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c46:	60a2                	ld	ra,8(sp)
    80000c48:	6402                	ld	s0,0(sp)
    80000c4a:	0141                	addi	sp,sp,16
    80000c4c:	8082                	ret
    panic("pop_off - interruptible");
    80000c4e:	00006517          	auipc	a0,0x6
    80000c52:	40250513          	addi	a0,a0,1026 # 80007050 <etext+0x50>
    80000c56:	b8bff0ef          	jal	800007e0 <panic>
    panic("pop_off");
    80000c5a:	00006517          	auipc	a0,0x6
    80000c5e:	40e50513          	addi	a0,a0,1038 # 80007068 <etext+0x68>
    80000c62:	b7fff0ef          	jal	800007e0 <panic>

0000000080000c66 <release>:
{
    80000c66:	1101                	addi	sp,sp,-32
    80000c68:	ec06                	sd	ra,24(sp)
    80000c6a:	e822                	sd	s0,16(sp)
    80000c6c:	e426                	sd	s1,8(sp)
    80000c6e:	1000                	addi	s0,sp,32
    80000c70:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c72:	ef3ff0ef          	jal	80000b64 <holding>
    80000c76:	c105                	beqz	a0,80000c96 <release+0x30>
  lk->cpu = 0;
    80000c78:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c7c:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c80:	0f50000f          	fence	iorw,ow
    80000c84:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c88:	f8bff0ef          	jal	80000c12 <pop_off>
}
    80000c8c:	60e2                	ld	ra,24(sp)
    80000c8e:	6442                	ld	s0,16(sp)
    80000c90:	64a2                	ld	s1,8(sp)
    80000c92:	6105                	addi	sp,sp,32
    80000c94:	8082                	ret
    panic("release");
    80000c96:	00006517          	auipc	a0,0x6
    80000c9a:	3da50513          	addi	a0,a0,986 # 80007070 <etext+0x70>
    80000c9e:	b43ff0ef          	jal	800007e0 <panic>

0000000080000ca2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ca2:	1141                	addi	sp,sp,-16
    80000ca4:	e422                	sd	s0,8(sp)
    80000ca6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ca8:	ca19                	beqz	a2,80000cbe <memset+0x1c>
    80000caa:	87aa                	mv	a5,a0
    80000cac:	1602                	slli	a2,a2,0x20
    80000cae:	9201                	srli	a2,a2,0x20
    80000cb0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cb4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cb8:	0785                	addi	a5,a5,1
    80000cba:	fee79de3          	bne	a5,a4,80000cb4 <memset+0x12>
  }
  return dst;
}
    80000cbe:	6422                	ld	s0,8(sp)
    80000cc0:	0141                	addi	sp,sp,16
    80000cc2:	8082                	ret

0000000080000cc4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cc4:	1141                	addi	sp,sp,-16
    80000cc6:	e422                	sd	s0,8(sp)
    80000cc8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cca:	ca05                	beqz	a2,80000cfa <memcmp+0x36>
    80000ccc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cd0:	1682                	slli	a3,a3,0x20
    80000cd2:	9281                	srli	a3,a3,0x20
    80000cd4:	0685                	addi	a3,a3,1
    80000cd6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cd8:	00054783          	lbu	a5,0(a0)
    80000cdc:	0005c703          	lbu	a4,0(a1)
    80000ce0:	00e79863          	bne	a5,a4,80000cf0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ce4:	0505                	addi	a0,a0,1
    80000ce6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ce8:	fed518e3          	bne	a0,a3,80000cd8 <memcmp+0x14>
  }

  return 0;
    80000cec:	4501                	li	a0,0
    80000cee:	a019                	j	80000cf4 <memcmp+0x30>
      return *s1 - *s2;
    80000cf0:	40e7853b          	subw	a0,a5,a4
}
    80000cf4:	6422                	ld	s0,8(sp)
    80000cf6:	0141                	addi	sp,sp,16
    80000cf8:	8082                	ret
  return 0;
    80000cfa:	4501                	li	a0,0
    80000cfc:	bfe5                	j	80000cf4 <memcmp+0x30>

0000000080000cfe <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000cfe:	1141                	addi	sp,sp,-16
    80000d00:	e422                	sd	s0,8(sp)
    80000d02:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d04:	c205                	beqz	a2,80000d24 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d06:	02a5e263          	bltu	a1,a0,80000d2a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d0a:	1602                	slli	a2,a2,0x20
    80000d0c:	9201                	srli	a2,a2,0x20
    80000d0e:	00c587b3          	add	a5,a1,a2
{
    80000d12:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d14:	0585                	addi	a1,a1,1
    80000d16:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde289>
    80000d18:	fff5c683          	lbu	a3,-1(a1)
    80000d1c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d20:	feb79ae3          	bne	a5,a1,80000d14 <memmove+0x16>

  return dst;
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  if(s < d && s + n > d){
    80000d2a:	02061693          	slli	a3,a2,0x20
    80000d2e:	9281                	srli	a3,a3,0x20
    80000d30:	00d58733          	add	a4,a1,a3
    80000d34:	fce57be3          	bgeu	a0,a4,80000d0a <memmove+0xc>
    d += n;
    80000d38:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d3a:	fff6079b          	addiw	a5,a2,-1
    80000d3e:	1782                	slli	a5,a5,0x20
    80000d40:	9381                	srli	a5,a5,0x20
    80000d42:	fff7c793          	not	a5,a5
    80000d46:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d48:	177d                	addi	a4,a4,-1
    80000d4a:	16fd                	addi	a3,a3,-1
    80000d4c:	00074603          	lbu	a2,0(a4)
    80000d50:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d54:	fef71ae3          	bne	a4,a5,80000d48 <memmove+0x4a>
    80000d58:	b7f1                	j	80000d24 <memmove+0x26>

0000000080000d5a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d5a:	1141                	addi	sp,sp,-16
    80000d5c:	e406                	sd	ra,8(sp)
    80000d5e:	e022                	sd	s0,0(sp)
    80000d60:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d62:	f9dff0ef          	jal	80000cfe <memmove>
}
    80000d66:	60a2                	ld	ra,8(sp)
    80000d68:	6402                	ld	s0,0(sp)
    80000d6a:	0141                	addi	sp,sp,16
    80000d6c:	8082                	ret

0000000080000d6e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d6e:	1141                	addi	sp,sp,-16
    80000d70:	e422                	sd	s0,8(sp)
    80000d72:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d74:	ce11                	beqz	a2,80000d90 <strncmp+0x22>
    80000d76:	00054783          	lbu	a5,0(a0)
    80000d7a:	cf89                	beqz	a5,80000d94 <strncmp+0x26>
    80000d7c:	0005c703          	lbu	a4,0(a1)
    80000d80:	00f71a63          	bne	a4,a5,80000d94 <strncmp+0x26>
    n--, p++, q++;
    80000d84:	367d                	addiw	a2,a2,-1
    80000d86:	0505                	addi	a0,a0,1
    80000d88:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d8a:	f675                	bnez	a2,80000d76 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	a801                	j	80000d9e <strncmp+0x30>
    80000d90:	4501                	li	a0,0
    80000d92:	a031                	j	80000d9e <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000d94:	00054503          	lbu	a0,0(a0)
    80000d98:	0005c783          	lbu	a5,0(a1)
    80000d9c:	9d1d                	subw	a0,a0,a5
}
    80000d9e:	6422                	ld	s0,8(sp)
    80000da0:	0141                	addi	sp,sp,16
    80000da2:	8082                	ret

0000000080000da4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000da4:	1141                	addi	sp,sp,-16
    80000da6:	e422                	sd	s0,8(sp)
    80000da8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000daa:	87aa                	mv	a5,a0
    80000dac:	86b2                	mv	a3,a2
    80000dae:	367d                	addiw	a2,a2,-1
    80000db0:	02d05563          	blez	a3,80000dda <strncpy+0x36>
    80000db4:	0785                	addi	a5,a5,1
    80000db6:	0005c703          	lbu	a4,0(a1)
    80000dba:	fee78fa3          	sb	a4,-1(a5)
    80000dbe:	0585                	addi	a1,a1,1
    80000dc0:	f775                	bnez	a4,80000dac <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dc2:	873e                	mv	a4,a5
    80000dc4:	9fb5                	addw	a5,a5,a3
    80000dc6:	37fd                	addiw	a5,a5,-1
    80000dc8:	00c05963          	blez	a2,80000dda <strncpy+0x36>
    *s++ = 0;
    80000dcc:	0705                	addi	a4,a4,1
    80000dce:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000dd2:	40e786bb          	subw	a3,a5,a4
    80000dd6:	fed04be3          	bgtz	a3,80000dcc <strncpy+0x28>
  return os;
}
    80000dda:	6422                	ld	s0,8(sp)
    80000ddc:	0141                	addi	sp,sp,16
    80000dde:	8082                	ret

0000000080000de0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e422                	sd	s0,8(sp)
    80000de4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000de6:	02c05363          	blez	a2,80000e0c <safestrcpy+0x2c>
    80000dea:	fff6069b          	addiw	a3,a2,-1
    80000dee:	1682                	slli	a3,a3,0x20
    80000df0:	9281                	srli	a3,a3,0x20
    80000df2:	96ae                	add	a3,a3,a1
    80000df4:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000df6:	00d58963          	beq	a1,a3,80000e08 <safestrcpy+0x28>
    80000dfa:	0585                	addi	a1,a1,1
    80000dfc:	0785                	addi	a5,a5,1
    80000dfe:	fff5c703          	lbu	a4,-1(a1)
    80000e02:	fee78fa3          	sb	a4,-1(a5)
    80000e06:	fb65                	bnez	a4,80000df6 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e08:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e0c:	6422                	ld	s0,8(sp)
    80000e0e:	0141                	addi	sp,sp,16
    80000e10:	8082                	ret

0000000080000e12 <strlen>:

int
strlen(const char *s)
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e422                	sd	s0,8(sp)
    80000e16:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e18:	00054783          	lbu	a5,0(a0)
    80000e1c:	cf91                	beqz	a5,80000e38 <strlen+0x26>
    80000e1e:	0505                	addi	a0,a0,1
    80000e20:	87aa                	mv	a5,a0
    80000e22:	86be                	mv	a3,a5
    80000e24:	0785                	addi	a5,a5,1
    80000e26:	fff7c703          	lbu	a4,-1(a5)
    80000e2a:	ff65                	bnez	a4,80000e22 <strlen+0x10>
    80000e2c:	40a6853b          	subw	a0,a3,a0
    80000e30:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e38:	4501                	li	a0,0
    80000e3a:	bfe5                	j	80000e32 <strlen+0x20>

0000000080000e3c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e3c:	1141                	addi	sp,sp,-16
    80000e3e:	e406                	sd	ra,8(sp)
    80000e40:	e022                	sd	s0,0(sp)
    80000e42:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e44:	25f000ef          	jal	800018a2 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e48:	00007717          	auipc	a4,0x7
    80000e4c:	a0870713          	addi	a4,a4,-1528 # 80007850 <started>
  if(cpuid() == 0){
    80000e50:	c51d                	beqz	a0,80000e7e <main+0x42>
    while(started == 0)
    80000e52:	431c                	lw	a5,0(a4)
    80000e54:	2781                	sext.w	a5,a5
    80000e56:	dff5                	beqz	a5,80000e52 <main+0x16>
      ;
    __sync_synchronize();
    80000e58:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e5c:	247000ef          	jal	800018a2 <cpuid>
    80000e60:	85aa                	mv	a1,a0
    80000e62:	00006517          	auipc	a0,0x6
    80000e66:	23650513          	addi	a0,a0,566 # 80007098 <etext+0x98>
    80000e6a:	e90ff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000e6e:	080000ef          	jal	80000eee <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e72:	5bc010ef          	jal	8000242e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e76:	5b2040ef          	jal	80005428 <plicinithart>
  }

  scheduler();        
    80000e7a:	6db000ef          	jal	80001d54 <scheduler>
    consoleinit();
    80000e7e:	da6ff0ef          	jal	80000424 <consoleinit>
    printfinit();
    80000e82:	99bff0ef          	jal	8000081c <printfinit>
    printf("\n");
    80000e86:	00006517          	auipc	a0,0x6
    80000e8a:	1f250513          	addi	a0,a0,498 # 80007078 <etext+0x78>
    80000e8e:	e6cff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000e92:	00006517          	auipc	a0,0x6
    80000e96:	1ee50513          	addi	a0,a0,494 # 80007080 <etext+0x80>
    80000e9a:	e60ff0ef          	jal	800004fa <printf>
    printf("\n");
    80000e9e:	00006517          	auipc	a0,0x6
    80000ea2:	1da50513          	addi	a0,a0,474 # 80007078 <etext+0x78>
    80000ea6:	e54ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000eaa:	c21ff0ef          	jal	80000aca <kinit>
    kvminit();       // create kernel page table
    80000eae:	2ca000ef          	jal	80001178 <kvminit>
    kvminithart();   // turn on paging
    80000eb2:	03c000ef          	jal	80000eee <kvminithart>
    procinit();      // process table
    80000eb6:	137000ef          	jal	800017ec <procinit>
    trapinit();      // trap vectors
    80000eba:	550010ef          	jal	8000240a <trapinit>
    trapinithart();  // install kernel trap vector
    80000ebe:	570010ef          	jal	8000242e <trapinithart>
    plicinit();      // set up interrupt controller
    80000ec2:	54c040ef          	jal	8000540e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ec6:	562040ef          	jal	80005428 <plicinithart>
    binit();         // buffer cache
    80000eca:	423010ef          	jal	80002aec <binit>
    iinit();         // inode table
    80000ece:	1a8020ef          	jal	80003076 <iinit>
    fileinit();      // file table
    80000ed2:	09a030ef          	jal	80003f6c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ed6:	642040ef          	jal	80005518 <virtio_disk_init>
    userinit();      // first user process
    80000eda:	4cf000ef          	jal	80001ba8 <userinit>
    __sync_synchronize();
    80000ede:	0ff0000f          	fence
    started = 1;
    80000ee2:	4785                	li	a5,1
    80000ee4:	00007717          	auipc	a4,0x7
    80000ee8:	96f72623          	sw	a5,-1684(a4) # 80007850 <started>
    80000eec:	b779                	j	80000e7a <main+0x3e>

0000000080000eee <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000eee:	1141                	addi	sp,sp,-16
    80000ef0:	e422                	sd	s0,8(sp)
    80000ef2:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ef4:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ef8:	00007797          	auipc	a5,0x7
    80000efc:	9607b783          	ld	a5,-1696(a5) # 80007858 <kernel_pagetable>
    80000f00:	83b1                	srli	a5,a5,0xc
    80000f02:	577d                	li	a4,-1
    80000f04:	177e                	slli	a4,a4,0x3f
    80000f06:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f08:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f0c:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f10:	6422                	ld	s0,8(sp)
    80000f12:	0141                	addi	sp,sp,16
    80000f14:	8082                	ret

0000000080000f16 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f16:	7139                	addi	sp,sp,-64
    80000f18:	fc06                	sd	ra,56(sp)
    80000f1a:	f822                	sd	s0,48(sp)
    80000f1c:	f426                	sd	s1,40(sp)
    80000f1e:	f04a                	sd	s2,32(sp)
    80000f20:	ec4e                	sd	s3,24(sp)
    80000f22:	e852                	sd	s4,16(sp)
    80000f24:	e456                	sd	s5,8(sp)
    80000f26:	e05a                	sd	s6,0(sp)
    80000f28:	0080                	addi	s0,sp,64
    80000f2a:	84aa                	mv	s1,a0
    80000f2c:	89ae                	mv	s3,a1
    80000f2e:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f30:	57fd                	li	a5,-1
    80000f32:	83e9                	srli	a5,a5,0x1a
    80000f34:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f36:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f38:	02b7fc63          	bgeu	a5,a1,80000f70 <walk+0x5a>
    panic("walk");
    80000f3c:	00006517          	auipc	a0,0x6
    80000f40:	17450513          	addi	a0,a0,372 # 800070b0 <etext+0xb0>
    80000f44:	89dff0ef          	jal	800007e0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f48:	060a8263          	beqz	s5,80000fac <walk+0x96>
    80000f4c:	bb3ff0ef          	jal	80000afe <kalloc>
    80000f50:	84aa                	mv	s1,a0
    80000f52:	c139                	beqz	a0,80000f98 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f54:	6605                	lui	a2,0x1
    80000f56:	4581                	li	a1,0
    80000f58:	d4bff0ef          	jal	80000ca2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f5c:	00c4d793          	srli	a5,s1,0xc
    80000f60:	07aa                	slli	a5,a5,0xa
    80000f62:	0017e793          	ori	a5,a5,1
    80000f66:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f6a:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde27f>
    80000f6c:	036a0063          	beq	s4,s6,80000f8c <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f70:	0149d933          	srl	s2,s3,s4
    80000f74:	1ff97913          	andi	s2,s2,511
    80000f78:	090e                	slli	s2,s2,0x3
    80000f7a:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f7c:	00093483          	ld	s1,0(s2)
    80000f80:	0014f793          	andi	a5,s1,1
    80000f84:	d3f1                	beqz	a5,80000f48 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f86:	80a9                	srli	s1,s1,0xa
    80000f88:	04b2                	slli	s1,s1,0xc
    80000f8a:	b7c5                	j	80000f6a <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f8c:	00c9d513          	srli	a0,s3,0xc
    80000f90:	1ff57513          	andi	a0,a0,511
    80000f94:	050e                	slli	a0,a0,0x3
    80000f96:	9526                	add	a0,a0,s1
}
    80000f98:	70e2                	ld	ra,56(sp)
    80000f9a:	7442                	ld	s0,48(sp)
    80000f9c:	74a2                	ld	s1,40(sp)
    80000f9e:	7902                	ld	s2,32(sp)
    80000fa0:	69e2                	ld	s3,24(sp)
    80000fa2:	6a42                	ld	s4,16(sp)
    80000fa4:	6aa2                	ld	s5,8(sp)
    80000fa6:	6b02                	ld	s6,0(sp)
    80000fa8:	6121                	addi	sp,sp,64
    80000faa:	8082                	ret
        return 0;
    80000fac:	4501                	li	a0,0
    80000fae:	b7ed                	j	80000f98 <walk+0x82>

0000000080000fb0 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fb0:	57fd                	li	a5,-1
    80000fb2:	83e9                	srli	a5,a5,0x1a
    80000fb4:	00b7f463          	bgeu	a5,a1,80000fbc <walkaddr+0xc>
    return 0;
    80000fb8:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fba:	8082                	ret
{
    80000fbc:	1141                	addi	sp,sp,-16
    80000fbe:	e406                	sd	ra,8(sp)
    80000fc0:	e022                	sd	s0,0(sp)
    80000fc2:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fc4:	4601                	li	a2,0
    80000fc6:	f51ff0ef          	jal	80000f16 <walk>
  if(pte == 0)
    80000fca:	c105                	beqz	a0,80000fea <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000fcc:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000fce:	0117f693          	andi	a3,a5,17
    80000fd2:	4745                	li	a4,17
    return 0;
    80000fd4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000fd6:	00e68663          	beq	a3,a4,80000fe2 <walkaddr+0x32>
}
    80000fda:	60a2                	ld	ra,8(sp)
    80000fdc:	6402                	ld	s0,0(sp)
    80000fde:	0141                	addi	sp,sp,16
    80000fe0:	8082                	ret
  pa = PTE2PA(*pte);
    80000fe2:	83a9                	srli	a5,a5,0xa
    80000fe4:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000fe8:	bfcd                	j	80000fda <walkaddr+0x2a>
    return 0;
    80000fea:	4501                	li	a0,0
    80000fec:	b7fd                	j	80000fda <walkaddr+0x2a>

0000000080000fee <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000fee:	715d                	addi	sp,sp,-80
    80000ff0:	e486                	sd	ra,72(sp)
    80000ff2:	e0a2                	sd	s0,64(sp)
    80000ff4:	fc26                	sd	s1,56(sp)
    80000ff6:	f84a                	sd	s2,48(sp)
    80000ff8:	f44e                	sd	s3,40(sp)
    80000ffa:	f052                	sd	s4,32(sp)
    80000ffc:	ec56                	sd	s5,24(sp)
    80000ffe:	e85a                	sd	s6,16(sp)
    80001000:	e45e                	sd	s7,8(sp)
    80001002:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001004:	03459793          	slli	a5,a1,0x34
    80001008:	e7a9                	bnez	a5,80001052 <mappages+0x64>
    8000100a:	8aaa                	mv	s5,a0
    8000100c:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    8000100e:	03461793          	slli	a5,a2,0x34
    80001012:	e7b1                	bnez	a5,8000105e <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80001014:	ca39                	beqz	a2,8000106a <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001016:	77fd                	lui	a5,0xfffff
    80001018:	963e                	add	a2,a2,a5
    8000101a:	00b609b3          	add	s3,a2,a1
  a = va;
    8000101e:	892e                	mv	s2,a1
    80001020:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001024:	6b85                	lui	s7,0x1
    80001026:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    8000102a:	4605                	li	a2,1
    8000102c:	85ca                	mv	a1,s2
    8000102e:	8556                	mv	a0,s5
    80001030:	ee7ff0ef          	jal	80000f16 <walk>
    80001034:	c539                	beqz	a0,80001082 <mappages+0x94>
    if(*pte & PTE_V)
    80001036:	611c                	ld	a5,0(a0)
    80001038:	8b85                	andi	a5,a5,1
    8000103a:	ef95                	bnez	a5,80001076 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000103c:	80b1                	srli	s1,s1,0xc
    8000103e:	04aa                	slli	s1,s1,0xa
    80001040:	0164e4b3          	or	s1,s1,s6
    80001044:	0014e493          	ori	s1,s1,1
    80001048:	e104                	sd	s1,0(a0)
    if(a == last)
    8000104a:	05390863          	beq	s2,s3,8000109a <mappages+0xac>
    a += PGSIZE;
    8000104e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	bfd9                	j	80001026 <mappages+0x38>
    panic("mappages: va not aligned");
    80001052:	00006517          	auipc	a0,0x6
    80001056:	06650513          	addi	a0,a0,102 # 800070b8 <etext+0xb8>
    8000105a:	f86ff0ef          	jal	800007e0 <panic>
    panic("mappages: size not aligned");
    8000105e:	00006517          	auipc	a0,0x6
    80001062:	07a50513          	addi	a0,a0,122 # 800070d8 <etext+0xd8>
    80001066:	f7aff0ef          	jal	800007e0 <panic>
    panic("mappages: size");
    8000106a:	00006517          	auipc	a0,0x6
    8000106e:	08e50513          	addi	a0,a0,142 # 800070f8 <etext+0xf8>
    80001072:	f6eff0ef          	jal	800007e0 <panic>
      panic("mappages: remap");
    80001076:	00006517          	auipc	a0,0x6
    8000107a:	09250513          	addi	a0,a0,146 # 80007108 <etext+0x108>
    8000107e:	f62ff0ef          	jal	800007e0 <panic>
      return -1;
    80001082:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001084:	60a6                	ld	ra,72(sp)
    80001086:	6406                	ld	s0,64(sp)
    80001088:	74e2                	ld	s1,56(sp)
    8000108a:	7942                	ld	s2,48(sp)
    8000108c:	79a2                	ld	s3,40(sp)
    8000108e:	7a02                	ld	s4,32(sp)
    80001090:	6ae2                	ld	s5,24(sp)
    80001092:	6b42                	ld	s6,16(sp)
    80001094:	6ba2                	ld	s7,8(sp)
    80001096:	6161                	addi	sp,sp,80
    80001098:	8082                	ret
  return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7e5                	j	80001084 <mappages+0x96>

000000008000109e <kvmmap>:
{
    8000109e:	1141                	addi	sp,sp,-16
    800010a0:	e406                	sd	ra,8(sp)
    800010a2:	e022                	sd	s0,0(sp)
    800010a4:	0800                	addi	s0,sp,16
    800010a6:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010a8:	86b2                	mv	a3,a2
    800010aa:	863e                	mv	a2,a5
    800010ac:	f43ff0ef          	jal	80000fee <mappages>
    800010b0:	e509                	bnez	a0,800010ba <kvmmap+0x1c>
}
    800010b2:	60a2                	ld	ra,8(sp)
    800010b4:	6402                	ld	s0,0(sp)
    800010b6:	0141                	addi	sp,sp,16
    800010b8:	8082                	ret
    panic("kvmmap");
    800010ba:	00006517          	auipc	a0,0x6
    800010be:	05e50513          	addi	a0,a0,94 # 80007118 <etext+0x118>
    800010c2:	f1eff0ef          	jal	800007e0 <panic>

00000000800010c6 <kvmmake>:
{
    800010c6:	1101                	addi	sp,sp,-32
    800010c8:	ec06                	sd	ra,24(sp)
    800010ca:	e822                	sd	s0,16(sp)
    800010cc:	e426                	sd	s1,8(sp)
    800010ce:	e04a                	sd	s2,0(sp)
    800010d0:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010d2:	a2dff0ef          	jal	80000afe <kalloc>
    800010d6:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010d8:	6605                	lui	a2,0x1
    800010da:	4581                	li	a1,0
    800010dc:	bc7ff0ef          	jal	80000ca2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800010e0:	4719                	li	a4,6
    800010e2:	6685                	lui	a3,0x1
    800010e4:	10000637          	lui	a2,0x10000
    800010e8:	100005b7          	lui	a1,0x10000
    800010ec:	8526                	mv	a0,s1
    800010ee:	fb1ff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010f2:	4719                	li	a4,6
    800010f4:	6685                	lui	a3,0x1
    800010f6:	10001637          	lui	a2,0x10001
    800010fa:	100015b7          	lui	a1,0x10001
    800010fe:	8526                	mv	a0,s1
    80001100:	f9fff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001104:	4719                	li	a4,6
    80001106:	040006b7          	lui	a3,0x4000
    8000110a:	0c000637          	lui	a2,0xc000
    8000110e:	0c0005b7          	lui	a1,0xc000
    80001112:	8526                	mv	a0,s1
    80001114:	f8bff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001118:	00006917          	auipc	s2,0x6
    8000111c:	ee890913          	addi	s2,s2,-280 # 80007000 <etext>
    80001120:	4729                	li	a4,10
    80001122:	80006697          	auipc	a3,0x80006
    80001126:	ede68693          	addi	a3,a3,-290 # 7000 <_entry-0x7fff9000>
    8000112a:	4605                	li	a2,1
    8000112c:	067e                	slli	a2,a2,0x1f
    8000112e:	85b2                	mv	a1,a2
    80001130:	8526                	mv	a0,s1
    80001132:	f6dff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001136:	46c5                	li	a3,17
    80001138:	06ee                	slli	a3,a3,0x1b
    8000113a:	4719                	li	a4,6
    8000113c:	412686b3          	sub	a3,a3,s2
    80001140:	864a                	mv	a2,s2
    80001142:	85ca                	mv	a1,s2
    80001144:	8526                	mv	a0,s1
    80001146:	f59ff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000114a:	4729                	li	a4,10
    8000114c:	6685                	lui	a3,0x1
    8000114e:	00005617          	auipc	a2,0x5
    80001152:	eb260613          	addi	a2,a2,-334 # 80006000 <_trampoline>
    80001156:	040005b7          	lui	a1,0x4000
    8000115a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000115c:	05b2                	slli	a1,a1,0xc
    8000115e:	8526                	mv	a0,s1
    80001160:	f3fff0ef          	jal	8000109e <kvmmap>
  proc_mapstacks(kpgtbl);
    80001164:	8526                	mv	a0,s1
    80001166:	5ee000ef          	jal	80001754 <proc_mapstacks>
}
    8000116a:	8526                	mv	a0,s1
    8000116c:	60e2                	ld	ra,24(sp)
    8000116e:	6442                	ld	s0,16(sp)
    80001170:	64a2                	ld	s1,8(sp)
    80001172:	6902                	ld	s2,0(sp)
    80001174:	6105                	addi	sp,sp,32
    80001176:	8082                	ret

0000000080001178 <kvminit>:
{
    80001178:	1141                	addi	sp,sp,-16
    8000117a:	e406                	sd	ra,8(sp)
    8000117c:	e022                	sd	s0,0(sp)
    8000117e:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001180:	f47ff0ef          	jal	800010c6 <kvmmake>
    80001184:	00006797          	auipc	a5,0x6
    80001188:	6ca7ba23          	sd	a0,1748(a5) # 80007858 <kernel_pagetable>
}
    8000118c:	60a2                	ld	ra,8(sp)
    8000118e:	6402                	ld	s0,0(sp)
    80001190:	0141                	addi	sp,sp,16
    80001192:	8082                	ret

0000000080001194 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001194:	1101                	addi	sp,sp,-32
    80001196:	ec06                	sd	ra,24(sp)
    80001198:	e822                	sd	s0,16(sp)
    8000119a:	e426                	sd	s1,8(sp)
    8000119c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000119e:	961ff0ef          	jal	80000afe <kalloc>
    800011a2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800011a4:	c509                	beqz	a0,800011ae <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800011a6:	6605                	lui	a2,0x1
    800011a8:	4581                	li	a1,0
    800011aa:	af9ff0ef          	jal	80000ca2 <memset>
  return pagetable;
}
    800011ae:	8526                	mv	a0,s1
    800011b0:	60e2                	ld	ra,24(sp)
    800011b2:	6442                	ld	s0,16(sp)
    800011b4:	64a2                	ld	s1,8(sp)
    800011b6:	6105                	addi	sp,sp,32
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	7139                	addi	sp,sp,-64
    800011bc:	fc06                	sd	ra,56(sp)
    800011be:	f822                	sd	s0,48(sp)
    800011c0:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e38d                	bnez	a5,800011e8 <uvmunmap+0x2e>
    800011c8:	f04a                	sd	s2,32(sp)
    800011ca:	ec4e                	sd	s3,24(sp)
    800011cc:	e852                	sd	s4,16(sp)
    800011ce:	e456                	sd	s5,8(sp)
    800011d0:	e05a                	sd	s6,0(sp)
    800011d2:	8a2a                	mv	s4,a0
    800011d4:	892e                	mv	s2,a1
    800011d6:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011d8:	0632                	slli	a2,a2,0xc
    800011da:	00b609b3          	add	s3,a2,a1
    800011de:	6b05                	lui	s6,0x1
    800011e0:	0535f963          	bgeu	a1,s3,80001232 <uvmunmap+0x78>
    800011e4:	f426                	sd	s1,40(sp)
    800011e6:	a015                	j	8000120a <uvmunmap+0x50>
    800011e8:	f426                	sd	s1,40(sp)
    800011ea:	f04a                	sd	s2,32(sp)
    800011ec:	ec4e                	sd	s3,24(sp)
    800011ee:	e852                	sd	s4,16(sp)
    800011f0:	e456                	sd	s5,8(sp)
    800011f2:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800011f4:	00006517          	auipc	a0,0x6
    800011f8:	f2c50513          	addi	a0,a0,-212 # 80007120 <etext+0x120>
    800011fc:	de4ff0ef          	jal	800007e0 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001200:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001204:	995a                	add	s2,s2,s6
    80001206:	03397563          	bgeu	s2,s3,80001230 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    8000120a:	4601                	li	a2,0
    8000120c:	85ca                	mv	a1,s2
    8000120e:	8552                	mv	a0,s4
    80001210:	d07ff0ef          	jal	80000f16 <walk>
    80001214:	84aa                	mv	s1,a0
    80001216:	d57d                	beqz	a0,80001204 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001218:	611c                	ld	a5,0(a0)
    8000121a:	0017f713          	andi	a4,a5,1
    8000121e:	d37d                	beqz	a4,80001204 <uvmunmap+0x4a>
    if(do_free){
    80001220:	fe0a80e3          	beqz	s5,80001200 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001224:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80001226:	00c79513          	slli	a0,a5,0xc
    8000122a:	ff2ff0ef          	jal	80000a1c <kfree>
    8000122e:	bfc9                	j	80001200 <uvmunmap+0x46>
    80001230:	74a2                	ld	s1,40(sp)
    80001232:	7902                	ld	s2,32(sp)
    80001234:	69e2                	ld	s3,24(sp)
    80001236:	6a42                	ld	s4,16(sp)
    80001238:	6aa2                	ld	s5,8(sp)
    8000123a:	6b02                	ld	s6,0(sp)
  }
}
    8000123c:	70e2                	ld	ra,56(sp)
    8000123e:	7442                	ld	s0,48(sp)
    80001240:	6121                	addi	sp,sp,64
    80001242:	8082                	ret

0000000080001244 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001244:	1101                	addi	sp,sp,-32
    80001246:	ec06                	sd	ra,24(sp)
    80001248:	e822                	sd	s0,16(sp)
    8000124a:	e426                	sd	s1,8(sp)
    8000124c:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000124e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001250:	00b67d63          	bgeu	a2,a1,8000126a <uvmdealloc+0x26>
    80001254:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001256:	6785                	lui	a5,0x1
    80001258:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000125a:	00f60733          	add	a4,a2,a5
    8000125e:	76fd                	lui	a3,0xfffff
    80001260:	8f75                	and	a4,a4,a3
    80001262:	97ae                	add	a5,a5,a1
    80001264:	8ff5                	and	a5,a5,a3
    80001266:	00f76863          	bltu	a4,a5,80001276 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000126a:	8526                	mv	a0,s1
    8000126c:	60e2                	ld	ra,24(sp)
    8000126e:	6442                	ld	s0,16(sp)
    80001270:	64a2                	ld	s1,8(sp)
    80001272:	6105                	addi	sp,sp,32
    80001274:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001276:	8f99                	sub	a5,a5,a4
    80001278:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000127a:	4685                	li	a3,1
    8000127c:	0007861b          	sext.w	a2,a5
    80001280:	85ba                	mv	a1,a4
    80001282:	f39ff0ef          	jal	800011ba <uvmunmap>
    80001286:	b7d5                	j	8000126a <uvmdealloc+0x26>

0000000080001288 <uvmalloc>:
  if(newsz < oldsz)
    80001288:	08b66f63          	bltu	a2,a1,80001326 <uvmalloc+0x9e>
{
    8000128c:	7139                	addi	sp,sp,-64
    8000128e:	fc06                	sd	ra,56(sp)
    80001290:	f822                	sd	s0,48(sp)
    80001292:	ec4e                	sd	s3,24(sp)
    80001294:	e852                	sd	s4,16(sp)
    80001296:	e456                	sd	s5,8(sp)
    80001298:	0080                	addi	s0,sp,64
    8000129a:	8aaa                	mv	s5,a0
    8000129c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000129e:	6785                	lui	a5,0x1
    800012a0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012a2:	95be                	add	a1,a1,a5
    800012a4:	77fd                	lui	a5,0xfffff
    800012a6:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012aa:	08c9f063          	bgeu	s3,a2,8000132a <uvmalloc+0xa2>
    800012ae:	f426                	sd	s1,40(sp)
    800012b0:	f04a                	sd	s2,32(sp)
    800012b2:	e05a                	sd	s6,0(sp)
    800012b4:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012b6:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800012ba:	845ff0ef          	jal	80000afe <kalloc>
    800012be:	84aa                	mv	s1,a0
    if(mem == 0){
    800012c0:	c515                	beqz	a0,800012ec <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800012c2:	6605                	lui	a2,0x1
    800012c4:	4581                	li	a1,0
    800012c6:	9ddff0ef          	jal	80000ca2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012ca:	875a                	mv	a4,s6
    800012cc:	86a6                	mv	a3,s1
    800012ce:	6605                	lui	a2,0x1
    800012d0:	85ca                	mv	a1,s2
    800012d2:	8556                	mv	a0,s5
    800012d4:	d1bff0ef          	jal	80000fee <mappages>
    800012d8:	e915                	bnez	a0,8000130c <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012da:	6785                	lui	a5,0x1
    800012dc:	993e                	add	s2,s2,a5
    800012de:	fd496ee3          	bltu	s2,s4,800012ba <uvmalloc+0x32>
  return newsz;
    800012e2:	8552                	mv	a0,s4
    800012e4:	74a2                	ld	s1,40(sp)
    800012e6:	7902                	ld	s2,32(sp)
    800012e8:	6b02                	ld	s6,0(sp)
    800012ea:	a811                	j	800012fe <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800012ec:	864e                	mv	a2,s3
    800012ee:	85ca                	mv	a1,s2
    800012f0:	8556                	mv	a0,s5
    800012f2:	f53ff0ef          	jal	80001244 <uvmdealloc>
      return 0;
    800012f6:	4501                	li	a0,0
    800012f8:	74a2                	ld	s1,40(sp)
    800012fa:	7902                	ld	s2,32(sp)
    800012fc:	6b02                	ld	s6,0(sp)
}
    800012fe:	70e2                	ld	ra,56(sp)
    80001300:	7442                	ld	s0,48(sp)
    80001302:	69e2                	ld	s3,24(sp)
    80001304:	6a42                	ld	s4,16(sp)
    80001306:	6aa2                	ld	s5,8(sp)
    80001308:	6121                	addi	sp,sp,64
    8000130a:	8082                	ret
      kfree(mem);
    8000130c:	8526                	mv	a0,s1
    8000130e:	f0eff0ef          	jal	80000a1c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001312:	864e                	mv	a2,s3
    80001314:	85ca                	mv	a1,s2
    80001316:	8556                	mv	a0,s5
    80001318:	f2dff0ef          	jal	80001244 <uvmdealloc>
      return 0;
    8000131c:	4501                	li	a0,0
    8000131e:	74a2                	ld	s1,40(sp)
    80001320:	7902                	ld	s2,32(sp)
    80001322:	6b02                	ld	s6,0(sp)
    80001324:	bfe9                	j	800012fe <uvmalloc+0x76>
    return oldsz;
    80001326:	852e                	mv	a0,a1
}
    80001328:	8082                	ret
  return newsz;
    8000132a:	8532                	mv	a0,a2
    8000132c:	bfc9                	j	800012fe <uvmalloc+0x76>

000000008000132e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000132e:	7179                	addi	sp,sp,-48
    80001330:	f406                	sd	ra,40(sp)
    80001332:	f022                	sd	s0,32(sp)
    80001334:	ec26                	sd	s1,24(sp)
    80001336:	e84a                	sd	s2,16(sp)
    80001338:	e44e                	sd	s3,8(sp)
    8000133a:	e052                	sd	s4,0(sp)
    8000133c:	1800                	addi	s0,sp,48
    8000133e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001340:	84aa                	mv	s1,a0
    80001342:	6905                	lui	s2,0x1
    80001344:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001346:	4985                	li	s3,1
    80001348:	a819                	j	8000135e <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000134a:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000134c:	00c79513          	slli	a0,a5,0xc
    80001350:	fdfff0ef          	jal	8000132e <freewalk>
      pagetable[i] = 0;
    80001354:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001358:	04a1                	addi	s1,s1,8
    8000135a:	01248f63          	beq	s1,s2,80001378 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000135e:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001360:	00f7f713          	andi	a4,a5,15
    80001364:	ff3703e3          	beq	a4,s3,8000134a <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001368:	8b85                	andi	a5,a5,1
    8000136a:	d7fd                	beqz	a5,80001358 <freewalk+0x2a>
      panic("freewalk: leaf");
    8000136c:	00006517          	auipc	a0,0x6
    80001370:	dcc50513          	addi	a0,a0,-564 # 80007138 <etext+0x138>
    80001374:	c6cff0ef          	jal	800007e0 <panic>
    }
  }
  kfree((void*)pagetable);
    80001378:	8552                	mv	a0,s4
    8000137a:	ea2ff0ef          	jal	80000a1c <kfree>
}
    8000137e:	70a2                	ld	ra,40(sp)
    80001380:	7402                	ld	s0,32(sp)
    80001382:	64e2                	ld	s1,24(sp)
    80001384:	6942                	ld	s2,16(sp)
    80001386:	69a2                	ld	s3,8(sp)
    80001388:	6a02                	ld	s4,0(sp)
    8000138a:	6145                	addi	sp,sp,48
    8000138c:	8082                	ret

000000008000138e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000138e:	1101                	addi	sp,sp,-32
    80001390:	ec06                	sd	ra,24(sp)
    80001392:	e822                	sd	s0,16(sp)
    80001394:	e426                	sd	s1,8(sp)
    80001396:	1000                	addi	s0,sp,32
    80001398:	84aa                	mv	s1,a0
  if(sz > 0)
    8000139a:	e989                	bnez	a1,800013ac <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000139c:	8526                	mv	a0,s1
    8000139e:	f91ff0ef          	jal	8000132e <freewalk>
}
    800013a2:	60e2                	ld	ra,24(sp)
    800013a4:	6442                	ld	s0,16(sp)
    800013a6:	64a2                	ld	s1,8(sp)
    800013a8:	6105                	addi	sp,sp,32
    800013aa:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800013ac:	6785                	lui	a5,0x1
    800013ae:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013b0:	95be                	add	a1,a1,a5
    800013b2:	4685                	li	a3,1
    800013b4:	00c5d613          	srli	a2,a1,0xc
    800013b8:	4581                	li	a1,0
    800013ba:	e01ff0ef          	jal	800011ba <uvmunmap>
    800013be:	bff9                	j	8000139c <uvmfree+0xe>

00000000800013c0 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800013c0:	ce49                	beqz	a2,8000145a <uvmcopy+0x9a>
{
    800013c2:	715d                	addi	sp,sp,-80
    800013c4:	e486                	sd	ra,72(sp)
    800013c6:	e0a2                	sd	s0,64(sp)
    800013c8:	fc26                	sd	s1,56(sp)
    800013ca:	f84a                	sd	s2,48(sp)
    800013cc:	f44e                	sd	s3,40(sp)
    800013ce:	f052                	sd	s4,32(sp)
    800013d0:	ec56                	sd	s5,24(sp)
    800013d2:	e85a                	sd	s6,16(sp)
    800013d4:	e45e                	sd	s7,8(sp)
    800013d6:	0880                	addi	s0,sp,80
    800013d8:	8aaa                	mv	s5,a0
    800013da:	8b2e                	mv	s6,a1
    800013dc:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800013de:	4481                	li	s1,0
    800013e0:	a029                	j	800013ea <uvmcopy+0x2a>
    800013e2:	6785                	lui	a5,0x1
    800013e4:	94be                	add	s1,s1,a5
    800013e6:	0544fe63          	bgeu	s1,s4,80001442 <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    800013ea:	4601                	li	a2,0
    800013ec:	85a6                	mv	a1,s1
    800013ee:	8556                	mv	a0,s5
    800013f0:	b27ff0ef          	jal	80000f16 <walk>
    800013f4:	d57d                	beqz	a0,800013e2 <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    800013f6:	6118                	ld	a4,0(a0)
    800013f8:	00177793          	andi	a5,a4,1
    800013fc:	d3fd                	beqz	a5,800013e2 <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    800013fe:	00a75593          	srli	a1,a4,0xa
    80001402:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001406:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    8000140a:	ef4ff0ef          	jal	80000afe <kalloc>
    8000140e:	89aa                	mv	s3,a0
    80001410:	c105                	beqz	a0,80001430 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001412:	6605                	lui	a2,0x1
    80001414:	85de                	mv	a1,s7
    80001416:	8e9ff0ef          	jal	80000cfe <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000141a:	874a                	mv	a4,s2
    8000141c:	86ce                	mv	a3,s3
    8000141e:	6605                	lui	a2,0x1
    80001420:	85a6                	mv	a1,s1
    80001422:	855a                	mv	a0,s6
    80001424:	bcbff0ef          	jal	80000fee <mappages>
    80001428:	dd4d                	beqz	a0,800013e2 <uvmcopy+0x22>
      kfree(mem);
    8000142a:	854e                	mv	a0,s3
    8000142c:	df0ff0ef          	jal	80000a1c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001430:	4685                	li	a3,1
    80001432:	00c4d613          	srli	a2,s1,0xc
    80001436:	4581                	li	a1,0
    80001438:	855a                	mv	a0,s6
    8000143a:	d81ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000143e:	557d                	li	a0,-1
    80001440:	a011                	j	80001444 <uvmcopy+0x84>
  return 0;
    80001442:	4501                	li	a0,0
}
    80001444:	60a6                	ld	ra,72(sp)
    80001446:	6406                	ld	s0,64(sp)
    80001448:	74e2                	ld	s1,56(sp)
    8000144a:	7942                	ld	s2,48(sp)
    8000144c:	79a2                	ld	s3,40(sp)
    8000144e:	7a02                	ld	s4,32(sp)
    80001450:	6ae2                	ld	s5,24(sp)
    80001452:	6b42                	ld	s6,16(sp)
    80001454:	6ba2                	ld	s7,8(sp)
    80001456:	6161                	addi	sp,sp,80
    80001458:	8082                	ret
  return 0;
    8000145a:	4501                	li	a0,0
}
    8000145c:	8082                	ret

000000008000145e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000145e:	1141                	addi	sp,sp,-16
    80001460:	e406                	sd	ra,8(sp)
    80001462:	e022                	sd	s0,0(sp)
    80001464:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001466:	4601                	li	a2,0
    80001468:	aafff0ef          	jal	80000f16 <walk>
  if(pte == 0)
    8000146c:	c901                	beqz	a0,8000147c <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000146e:	611c                	ld	a5,0(a0)
    80001470:	9bbd                	andi	a5,a5,-17
    80001472:	e11c                	sd	a5,0(a0)
}
    80001474:	60a2                	ld	ra,8(sp)
    80001476:	6402                	ld	s0,0(sp)
    80001478:	0141                	addi	sp,sp,16
    8000147a:	8082                	ret
    panic("uvmclear");
    8000147c:	00006517          	auipc	a0,0x6
    80001480:	ccc50513          	addi	a0,a0,-820 # 80007148 <etext+0x148>
    80001484:	b5cff0ef          	jal	800007e0 <panic>

0000000080001488 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001488:	c6dd                	beqz	a3,80001536 <copyinstr+0xae>
{
    8000148a:	715d                	addi	sp,sp,-80
    8000148c:	e486                	sd	ra,72(sp)
    8000148e:	e0a2                	sd	s0,64(sp)
    80001490:	fc26                	sd	s1,56(sp)
    80001492:	f84a                	sd	s2,48(sp)
    80001494:	f44e                	sd	s3,40(sp)
    80001496:	f052                	sd	s4,32(sp)
    80001498:	ec56                	sd	s5,24(sp)
    8000149a:	e85a                	sd	s6,16(sp)
    8000149c:	e45e                	sd	s7,8(sp)
    8000149e:	0880                	addi	s0,sp,80
    800014a0:	8a2a                	mv	s4,a0
    800014a2:	8b2e                	mv	s6,a1
    800014a4:	8bb2                	mv	s7,a2
    800014a6:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800014a8:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014aa:	6985                	lui	s3,0x1
    800014ac:	a825                	j	800014e4 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800014ae:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800014b2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800014b4:	37fd                	addiw	a5,a5,-1
    800014b6:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800014ba:	60a6                	ld	ra,72(sp)
    800014bc:	6406                	ld	s0,64(sp)
    800014be:	74e2                	ld	s1,56(sp)
    800014c0:	7942                	ld	s2,48(sp)
    800014c2:	79a2                	ld	s3,40(sp)
    800014c4:	7a02                	ld	s4,32(sp)
    800014c6:	6ae2                	ld	s5,24(sp)
    800014c8:	6b42                	ld	s6,16(sp)
    800014ca:	6ba2                	ld	s7,8(sp)
    800014cc:	6161                	addi	sp,sp,80
    800014ce:	8082                	ret
    800014d0:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800014d4:	9742                	add	a4,a4,a6
      --max;
    800014d6:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    800014da:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    800014de:	04e58463          	beq	a1,a4,80001526 <copyinstr+0x9e>
{
    800014e2:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    800014e4:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800014e8:	85a6                	mv	a1,s1
    800014ea:	8552                	mv	a0,s4
    800014ec:	ac5ff0ef          	jal	80000fb0 <walkaddr>
    if(pa0 == 0)
    800014f0:	cd0d                	beqz	a0,8000152a <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800014f2:	417486b3          	sub	a3,s1,s7
    800014f6:	96ce                	add	a3,a3,s3
    if(n > max)
    800014f8:	00d97363          	bgeu	s2,a3,800014fe <copyinstr+0x76>
    800014fc:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    800014fe:	955e                	add	a0,a0,s7
    80001500:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001502:	c695                	beqz	a3,8000152e <copyinstr+0xa6>
    80001504:	87da                	mv	a5,s6
    80001506:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001508:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000150c:	96da                	add	a3,a3,s6
    8000150e:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001510:	00f60733          	add	a4,a2,a5
    80001514:	00074703          	lbu	a4,0(a4)
    80001518:	db59                	beqz	a4,800014ae <copyinstr+0x26>
        *dst = *p;
    8000151a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000151e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001520:	fed797e3          	bne	a5,a3,8000150e <copyinstr+0x86>
    80001524:	b775                	j	800014d0 <copyinstr+0x48>
    80001526:	4781                	li	a5,0
    80001528:	b771                	j	800014b4 <copyinstr+0x2c>
      return -1;
    8000152a:	557d                	li	a0,-1
    8000152c:	b779                	j	800014ba <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    8000152e:	6b85                	lui	s7,0x1
    80001530:	9ba6                	add	s7,s7,s1
    80001532:	87da                	mv	a5,s6
    80001534:	b77d                	j	800014e2 <copyinstr+0x5a>
  int got_null = 0;
    80001536:	4781                	li	a5,0
  if(got_null){
    80001538:	37fd                	addiw	a5,a5,-1
    8000153a:	0007851b          	sext.w	a0,a5
}
    8000153e:	8082                	ret

0000000080001540 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    80001540:	1141                	addi	sp,sp,-16
    80001542:	e406                	sd	ra,8(sp)
    80001544:	e022                	sd	s0,0(sp)
    80001546:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001548:	4601                	li	a2,0
    8000154a:	9cdff0ef          	jal	80000f16 <walk>
  if (pte == 0) {
    8000154e:	c519                	beqz	a0,8000155c <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    80001550:	6108                	ld	a0,0(a0)
    80001552:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001554:	60a2                	ld	ra,8(sp)
    80001556:	6402                	ld	s0,0(sp)
    80001558:	0141                	addi	sp,sp,16
    8000155a:	8082                	ret
    return 0;
    8000155c:	4501                	li	a0,0
    8000155e:	bfdd                	j	80001554 <ismapped+0x14>

0000000080001560 <vmfault>:
{
    80001560:	7179                	addi	sp,sp,-48
    80001562:	f406                	sd	ra,40(sp)
    80001564:	f022                	sd	s0,32(sp)
    80001566:	ec26                	sd	s1,24(sp)
    80001568:	e44e                	sd	s3,8(sp)
    8000156a:	1800                	addi	s0,sp,48
    8000156c:	89aa                	mv	s3,a0
    8000156e:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80001570:	35e000ef          	jal	800018ce <myproc>
  if (va >= p->sz)
    80001574:	653c                	ld	a5,72(a0)
    80001576:	00f4ea63          	bltu	s1,a5,8000158a <vmfault+0x2a>
    return 0;
    8000157a:	4981                	li	s3,0
}
    8000157c:	854e                	mv	a0,s3
    8000157e:	70a2                	ld	ra,40(sp)
    80001580:	7402                	ld	s0,32(sp)
    80001582:	64e2                	ld	s1,24(sp)
    80001584:	69a2                	ld	s3,8(sp)
    80001586:	6145                	addi	sp,sp,48
    80001588:	8082                	ret
    8000158a:	e84a                	sd	s2,16(sp)
    8000158c:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    8000158e:	77fd                	lui	a5,0xfffff
    80001590:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80001592:	85a6                	mv	a1,s1
    80001594:	854e                	mv	a0,s3
    80001596:	fabff0ef          	jal	80001540 <ismapped>
    return 0;
    8000159a:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    8000159c:	c119                	beqz	a0,800015a2 <vmfault+0x42>
    8000159e:	6942                	ld	s2,16(sp)
    800015a0:	bff1                	j	8000157c <vmfault+0x1c>
    800015a2:	e052                	sd	s4,0(sp)
  mem = (uint64) kalloc();
    800015a4:	d5aff0ef          	jal	80000afe <kalloc>
    800015a8:	8a2a                	mv	s4,a0
  if(mem == 0)
    800015aa:	c90d                	beqz	a0,800015dc <vmfault+0x7c>
  mem = (uint64) kalloc();
    800015ac:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    800015ae:	6605                	lui	a2,0x1
    800015b0:	4581                	li	a1,0
    800015b2:	ef0ff0ef          	jal	80000ca2 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    800015b6:	4759                	li	a4,22
    800015b8:	86d2                	mv	a3,s4
    800015ba:	6605                	lui	a2,0x1
    800015bc:	85a6                	mv	a1,s1
    800015be:	05093503          	ld	a0,80(s2)
    800015c2:	a2dff0ef          	jal	80000fee <mappages>
    800015c6:	e501                	bnez	a0,800015ce <vmfault+0x6e>
    800015c8:	6942                	ld	s2,16(sp)
    800015ca:	6a02                	ld	s4,0(sp)
    800015cc:	bf45                	j	8000157c <vmfault+0x1c>
    kfree((void *)mem);
    800015ce:	8552                	mv	a0,s4
    800015d0:	c4cff0ef          	jal	80000a1c <kfree>
    return 0;
    800015d4:	4981                	li	s3,0
    800015d6:	6942                	ld	s2,16(sp)
    800015d8:	6a02                	ld	s4,0(sp)
    800015da:	b74d                	j	8000157c <vmfault+0x1c>
    800015dc:	6942                	ld	s2,16(sp)
    800015de:	6a02                	ld	s4,0(sp)
    800015e0:	bf71                	j	8000157c <vmfault+0x1c>

00000000800015e2 <copyout>:
  while(len > 0){
    800015e2:	c2cd                	beqz	a3,80001684 <copyout+0xa2>
{
    800015e4:	711d                	addi	sp,sp,-96
    800015e6:	ec86                	sd	ra,88(sp)
    800015e8:	e8a2                	sd	s0,80(sp)
    800015ea:	e4a6                	sd	s1,72(sp)
    800015ec:	f852                	sd	s4,48(sp)
    800015ee:	f05a                	sd	s6,32(sp)
    800015f0:	ec5e                	sd	s7,24(sp)
    800015f2:	e862                	sd	s8,16(sp)
    800015f4:	1080                	addi	s0,sp,96
    800015f6:	8c2a                	mv	s8,a0
    800015f8:	8b2e                	mv	s6,a1
    800015fa:	8bb2                	mv	s7,a2
    800015fc:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800015fe:	74fd                	lui	s1,0xfffff
    80001600:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001602:	57fd                	li	a5,-1
    80001604:	83e9                	srli	a5,a5,0x1a
    80001606:	0897e163          	bltu	a5,s1,80001688 <copyout+0xa6>
    8000160a:	e0ca                	sd	s2,64(sp)
    8000160c:	fc4e                	sd	s3,56(sp)
    8000160e:	f456                	sd	s5,40(sp)
    80001610:	e466                	sd	s9,8(sp)
    80001612:	e06a                	sd	s10,0(sp)
    80001614:	6d05                	lui	s10,0x1
    80001616:	8cbe                	mv	s9,a5
    80001618:	a015                	j	8000163c <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000161a:	409b0533          	sub	a0,s6,s1
    8000161e:	0009861b          	sext.w	a2,s3
    80001622:	85de                	mv	a1,s7
    80001624:	954a                	add	a0,a0,s2
    80001626:	ed8ff0ef          	jal	80000cfe <memmove>
    len -= n;
    8000162a:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000162e:	9bce                	add	s7,s7,s3
  while(len > 0){
    80001630:	040a0363          	beqz	s4,80001676 <copyout+0x94>
    if(va0 >= MAXVA)
    80001634:	055cec63          	bltu	s9,s5,8000168c <copyout+0xaa>
    80001638:	84d6                	mv	s1,s5
    8000163a:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    8000163c:	85a6                	mv	a1,s1
    8000163e:	8562                	mv	a0,s8
    80001640:	971ff0ef          	jal	80000fb0 <walkaddr>
    80001644:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80001646:	e901                	bnez	a0,80001656 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001648:	4601                	li	a2,0
    8000164a:	85a6                	mv	a1,s1
    8000164c:	8562                	mv	a0,s8
    8000164e:	f13ff0ef          	jal	80001560 <vmfault>
    80001652:	892a                	mv	s2,a0
    80001654:	c139                	beqz	a0,8000169a <copyout+0xb8>
    pte = walk(pagetable, va0, 0);
    80001656:	4601                	li	a2,0
    80001658:	85a6                	mv	a1,s1
    8000165a:	8562                	mv	a0,s8
    8000165c:	8bbff0ef          	jal	80000f16 <walk>
    if((*pte & PTE_W) == 0)
    80001660:	611c                	ld	a5,0(a0)
    80001662:	8b91                	andi	a5,a5,4
    80001664:	c3b1                	beqz	a5,800016a8 <copyout+0xc6>
    n = PGSIZE - (dstva - va0);
    80001666:	01a48ab3          	add	s5,s1,s10
    8000166a:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    8000166e:	fb3a76e3          	bgeu	s4,s3,8000161a <copyout+0x38>
    80001672:	89d2                	mv	s3,s4
    80001674:	b75d                	j	8000161a <copyout+0x38>
  return 0;
    80001676:	4501                	li	a0,0
    80001678:	6906                	ld	s2,64(sp)
    8000167a:	79e2                	ld	s3,56(sp)
    8000167c:	7aa2                	ld	s5,40(sp)
    8000167e:	6ca2                	ld	s9,8(sp)
    80001680:	6d02                	ld	s10,0(sp)
    80001682:	a80d                	j	800016b4 <copyout+0xd2>
    80001684:	4501                	li	a0,0
}
    80001686:	8082                	ret
      return -1;
    80001688:	557d                	li	a0,-1
    8000168a:	a02d                	j	800016b4 <copyout+0xd2>
    8000168c:	557d                	li	a0,-1
    8000168e:	6906                	ld	s2,64(sp)
    80001690:	79e2                	ld	s3,56(sp)
    80001692:	7aa2                	ld	s5,40(sp)
    80001694:	6ca2                	ld	s9,8(sp)
    80001696:	6d02                	ld	s10,0(sp)
    80001698:	a831                	j	800016b4 <copyout+0xd2>
        return -1;
    8000169a:	557d                	li	a0,-1
    8000169c:	6906                	ld	s2,64(sp)
    8000169e:	79e2                	ld	s3,56(sp)
    800016a0:	7aa2                	ld	s5,40(sp)
    800016a2:	6ca2                	ld	s9,8(sp)
    800016a4:	6d02                	ld	s10,0(sp)
    800016a6:	a039                	j	800016b4 <copyout+0xd2>
      return -1;
    800016a8:	557d                	li	a0,-1
    800016aa:	6906                	ld	s2,64(sp)
    800016ac:	79e2                	ld	s3,56(sp)
    800016ae:	7aa2                	ld	s5,40(sp)
    800016b0:	6ca2                	ld	s9,8(sp)
    800016b2:	6d02                	ld	s10,0(sp)
}
    800016b4:	60e6                	ld	ra,88(sp)
    800016b6:	6446                	ld	s0,80(sp)
    800016b8:	64a6                	ld	s1,72(sp)
    800016ba:	7a42                	ld	s4,48(sp)
    800016bc:	7b02                	ld	s6,32(sp)
    800016be:	6be2                	ld	s7,24(sp)
    800016c0:	6c42                	ld	s8,16(sp)
    800016c2:	6125                	addi	sp,sp,96
    800016c4:	8082                	ret

00000000800016c6 <copyin>:
  while(len > 0){
    800016c6:	c6c9                	beqz	a3,80001750 <copyin+0x8a>
{
    800016c8:	715d                	addi	sp,sp,-80
    800016ca:	e486                	sd	ra,72(sp)
    800016cc:	e0a2                	sd	s0,64(sp)
    800016ce:	fc26                	sd	s1,56(sp)
    800016d0:	f84a                	sd	s2,48(sp)
    800016d2:	f44e                	sd	s3,40(sp)
    800016d4:	f052                	sd	s4,32(sp)
    800016d6:	ec56                	sd	s5,24(sp)
    800016d8:	e85a                	sd	s6,16(sp)
    800016da:	e45e                	sd	s7,8(sp)
    800016dc:	e062                	sd	s8,0(sp)
    800016de:	0880                	addi	s0,sp,80
    800016e0:	8baa                	mv	s7,a0
    800016e2:	8aae                	mv	s5,a1
    800016e4:	8932                	mv	s2,a2
    800016e6:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800016e8:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800016ea:	6b05                	lui	s6,0x1
    800016ec:	a035                	j	80001718 <copyin+0x52>
    800016ee:	412984b3          	sub	s1,s3,s2
    800016f2:	94da                	add	s1,s1,s6
    if(n > len)
    800016f4:	009a7363          	bgeu	s4,s1,800016fa <copyin+0x34>
    800016f8:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016fa:	413905b3          	sub	a1,s2,s3
    800016fe:	0004861b          	sext.w	a2,s1
    80001702:	95aa                	add	a1,a1,a0
    80001704:	8556                	mv	a0,s5
    80001706:	df8ff0ef          	jal	80000cfe <memmove>
    len -= n;
    8000170a:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000170e:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001710:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001714:	020a0163          	beqz	s4,80001736 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001718:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000171c:	85ce                	mv	a1,s3
    8000171e:	855e                	mv	a0,s7
    80001720:	891ff0ef          	jal	80000fb0 <walkaddr>
    if(pa0 == 0) {
    80001724:	f569                	bnez	a0,800016ee <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001726:	4601                	li	a2,0
    80001728:	85ce                	mv	a1,s3
    8000172a:	855e                	mv	a0,s7
    8000172c:	e35ff0ef          	jal	80001560 <vmfault>
    80001730:	fd5d                	bnez	a0,800016ee <copyin+0x28>
        return -1;
    80001732:	557d                	li	a0,-1
    80001734:	a011                	j	80001738 <copyin+0x72>
  return 0;
    80001736:	4501                	li	a0,0
}
    80001738:	60a6                	ld	ra,72(sp)
    8000173a:	6406                	ld	s0,64(sp)
    8000173c:	74e2                	ld	s1,56(sp)
    8000173e:	7942                	ld	s2,48(sp)
    80001740:	79a2                	ld	s3,40(sp)
    80001742:	7a02                	ld	s4,32(sp)
    80001744:	6ae2                	ld	s5,24(sp)
    80001746:	6b42                	ld	s6,16(sp)
    80001748:	6ba2                	ld	s7,8(sp)
    8000174a:	6c02                	ld	s8,0(sp)
    8000174c:	6161                	addi	sp,sp,80
    8000174e:	8082                	ret
  return 0;
    80001750:	4501                	li	a0,0
}
    80001752:	8082                	ret

0000000080001754 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001754:	7139                	addi	sp,sp,-64
    80001756:	fc06                	sd	ra,56(sp)
    80001758:	f822                	sd	s0,48(sp)
    8000175a:	f426                	sd	s1,40(sp)
    8000175c:	f04a                	sd	s2,32(sp)
    8000175e:	ec4e                	sd	s3,24(sp)
    80001760:	e852                	sd	s4,16(sp)
    80001762:	e456                	sd	s5,8(sp)
    80001764:	e05a                	sd	s6,0(sp)
    80001766:	0080                	addi	s0,sp,64
    80001768:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000176a:	0000e497          	auipc	s1,0xe
    8000176e:	62e48493          	addi	s1,s1,1582 # 8000fd98 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001772:	8b26                	mv	s6,s1
    80001774:	ff4df937          	lui	s2,0xff4df
    80001778:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bdc45>
    8000177c:	0936                	slli	s2,s2,0xd
    8000177e:	6f590913          	addi	s2,s2,1781
    80001782:	0936                	slli	s2,s2,0xd
    80001784:	bd390913          	addi	s2,s2,-1069
    80001788:	0932                	slli	s2,s2,0xc
    8000178a:	7a790913          	addi	s2,s2,1959
    8000178e:	040009b7          	lui	s3,0x4000
    80001792:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001794:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001796:	00014a97          	auipc	s5,0x14
    8000179a:	202a8a93          	addi	s5,s5,514 # 80015998 <tickslock>
    char *pa = kalloc();
    8000179e:	b60ff0ef          	jal	80000afe <kalloc>
    800017a2:	862a                	mv	a2,a0
    if(pa == 0)
    800017a4:	cd15                	beqz	a0,800017e0 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017a6:	416485b3          	sub	a1,s1,s6
    800017aa:	8591                	srai	a1,a1,0x4
    800017ac:	032585b3          	mul	a1,a1,s2
    800017b0:	2585                	addiw	a1,a1,1
    800017b2:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017b6:	4719                	li	a4,6
    800017b8:	6685                	lui	a3,0x1
    800017ba:	40b985b3          	sub	a1,s3,a1
    800017be:	8552                	mv	a0,s4
    800017c0:	8dfff0ef          	jal	8000109e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017c4:	17048493          	addi	s1,s1,368
    800017c8:	fd549be3          	bne	s1,s5,8000179e <proc_mapstacks+0x4a>
  }
}
    800017cc:	70e2                	ld	ra,56(sp)
    800017ce:	7442                	ld	s0,48(sp)
    800017d0:	74a2                	ld	s1,40(sp)
    800017d2:	7902                	ld	s2,32(sp)
    800017d4:	69e2                	ld	s3,24(sp)
    800017d6:	6a42                	ld	s4,16(sp)
    800017d8:	6aa2                	ld	s5,8(sp)
    800017da:	6b02                	ld	s6,0(sp)
    800017dc:	6121                	addi	sp,sp,64
    800017de:	8082                	ret
      panic("kalloc");
    800017e0:	00006517          	auipc	a0,0x6
    800017e4:	97850513          	addi	a0,a0,-1672 # 80007158 <etext+0x158>
    800017e8:	ff9fe0ef          	jal	800007e0 <panic>

00000000800017ec <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017ec:	7139                	addi	sp,sp,-64
    800017ee:	fc06                	sd	ra,56(sp)
    800017f0:	f822                	sd	s0,48(sp)
    800017f2:	f426                	sd	s1,40(sp)
    800017f4:	f04a                	sd	s2,32(sp)
    800017f6:	ec4e                	sd	s3,24(sp)
    800017f8:	e852                	sd	s4,16(sp)
    800017fa:	e456                	sd	s5,8(sp)
    800017fc:	e05a                	sd	s6,0(sp)
    800017fe:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001800:	00006597          	auipc	a1,0x6
    80001804:	96058593          	addi	a1,a1,-1696 # 80007160 <etext+0x160>
    80001808:	0000e517          	auipc	a0,0xe
    8000180c:	16050513          	addi	a0,a0,352 # 8000f968 <pid_lock>
    80001810:	b3eff0ef          	jal	80000b4e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001814:	00006597          	auipc	a1,0x6
    80001818:	95458593          	addi	a1,a1,-1708 # 80007168 <etext+0x168>
    8000181c:	0000e517          	auipc	a0,0xe
    80001820:	16450513          	addi	a0,a0,356 # 8000f980 <wait_lock>
    80001824:	b2aff0ef          	jal	80000b4e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001828:	0000e497          	auipc	s1,0xe
    8000182c:	57048493          	addi	s1,s1,1392 # 8000fd98 <proc>
      initlock(&p->lock, "proc");
    80001830:	00006b17          	auipc	s6,0x6
    80001834:	948b0b13          	addi	s6,s6,-1720 # 80007178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001838:	8aa6                	mv	s5,s1
    8000183a:	ff4df937          	lui	s2,0xff4df
    8000183e:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bdc45>
    80001842:	0936                	slli	s2,s2,0xd
    80001844:	6f590913          	addi	s2,s2,1781
    80001848:	0936                	slli	s2,s2,0xd
    8000184a:	bd390913          	addi	s2,s2,-1069
    8000184e:	0932                	slli	s2,s2,0xc
    80001850:	7a790913          	addi	s2,s2,1959
    80001854:	040009b7          	lui	s3,0x4000
    80001858:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000185a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000185c:	00014a17          	auipc	s4,0x14
    80001860:	13ca0a13          	addi	s4,s4,316 # 80015998 <tickslock>
      initlock(&p->lock, "proc");
    80001864:	85da                	mv	a1,s6
    80001866:	8526                	mv	a0,s1
    80001868:	ae6ff0ef          	jal	80000b4e <initlock>
      p->state = UNUSED;
    8000186c:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001870:	415487b3          	sub	a5,s1,s5
    80001874:	8791                	srai	a5,a5,0x4
    80001876:	032787b3          	mul	a5,a5,s2
    8000187a:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffde289>
    8000187c:	00d7979b          	slliw	a5,a5,0xd
    80001880:	40f987b3          	sub	a5,s3,a5
    80001884:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001886:	17048493          	addi	s1,s1,368
    8000188a:	fd449de3          	bne	s1,s4,80001864 <procinit+0x78>
  }
}
    8000188e:	70e2                	ld	ra,56(sp)
    80001890:	7442                	ld	s0,48(sp)
    80001892:	74a2                	ld	s1,40(sp)
    80001894:	7902                	ld	s2,32(sp)
    80001896:	69e2                	ld	s3,24(sp)
    80001898:	6a42                	ld	s4,16(sp)
    8000189a:	6aa2                	ld	s5,8(sp)
    8000189c:	6b02                	ld	s6,0(sp)
    8000189e:	6121                	addi	sp,sp,64
    800018a0:	8082                	ret

00000000800018a2 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018a2:	1141                	addi	sp,sp,-16
    800018a4:	e422                	sd	s0,8(sp)
    800018a6:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018a8:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018aa:	2501                	sext.w	a0,a0
    800018ac:	6422                	ld	s0,8(sp)
    800018ae:	0141                	addi	sp,sp,16
    800018b0:	8082                	ret

00000000800018b2 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018b2:	1141                	addi	sp,sp,-16
    800018b4:	e422                	sd	s0,8(sp)
    800018b6:	0800                	addi	s0,sp,16
    800018b8:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018ba:	2781                	sext.w	a5,a5
    800018bc:	079e                	slli	a5,a5,0x7
  return c;
}
    800018be:	0000e517          	auipc	a0,0xe
    800018c2:	0da50513          	addi	a0,a0,218 # 8000f998 <cpus>
    800018c6:	953e                	add	a0,a0,a5
    800018c8:	6422                	ld	s0,8(sp)
    800018ca:	0141                	addi	sp,sp,16
    800018cc:	8082                	ret

00000000800018ce <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018ce:	1101                	addi	sp,sp,-32
    800018d0:	ec06                	sd	ra,24(sp)
    800018d2:	e822                	sd	s0,16(sp)
    800018d4:	e426                	sd	s1,8(sp)
    800018d6:	1000                	addi	s0,sp,32
  push_off();
    800018d8:	ab6ff0ef          	jal	80000b8e <push_off>
    800018dc:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018de:	2781                	sext.w	a5,a5
    800018e0:	079e                	slli	a5,a5,0x7
    800018e2:	0000e717          	auipc	a4,0xe
    800018e6:	08670713          	addi	a4,a4,134 # 8000f968 <pid_lock>
    800018ea:	97ba                	add	a5,a5,a4
    800018ec:	7b84                	ld	s1,48(a5)
  pop_off();
    800018ee:	b24ff0ef          	jal	80000c12 <pop_off>
  return p;
}
    800018f2:	8526                	mv	a0,s1
    800018f4:	60e2                	ld	ra,24(sp)
    800018f6:	6442                	ld	s0,16(sp)
    800018f8:	64a2                	ld	s1,8(sp)
    800018fa:	6105                	addi	sp,sp,32
    800018fc:	8082                	ret

00000000800018fe <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800018fe:	7179                	addi	sp,sp,-48
    80001900:	f406                	sd	ra,40(sp)
    80001902:	f022                	sd	s0,32(sp)
    80001904:	ec26                	sd	s1,24(sp)
    80001906:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001908:	fc7ff0ef          	jal	800018ce <myproc>
    8000190c:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    8000190e:	b58ff0ef          	jal	80000c66 <release>

  if (first) {
    80001912:	00006797          	auipc	a5,0x6
    80001916:	f1e7a783          	lw	a5,-226(a5) # 80007830 <first.1>
    8000191a:	cf8d                	beqz	a5,80001954 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    8000191c:	4505                	li	a0,1
    8000191e:	415010ef          	jal	80003532 <fsinit>

    first = 0;
    80001922:	00006797          	auipc	a5,0x6
    80001926:	f007a723          	sw	zero,-242(a5) # 80007830 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    8000192a:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    8000192e:	00006517          	auipc	a0,0x6
    80001932:	85250513          	addi	a0,a0,-1966 # 80007180 <etext+0x180>
    80001936:	fca43823          	sd	a0,-48(s0)
    8000193a:	fc043c23          	sd	zero,-40(s0)
    8000193e:	fd040593          	addi	a1,s0,-48
    80001942:	4fb020ef          	jal	8000463c <kexec>
    80001946:	6cbc                	ld	a5,88(s1)
    80001948:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    8000194a:	6cbc                	ld	a5,88(s1)
    8000194c:	7bb8                	ld	a4,112(a5)
    8000194e:	57fd                	li	a5,-1
    80001950:	02f70d63          	beq	a4,a5,8000198a <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001954:	2f3000ef          	jal	80002446 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001958:	68a8                	ld	a0,80(s1)
    8000195a:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000195c:	04000737          	lui	a4,0x4000
    80001960:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001962:	0732                	slli	a4,a4,0xc
    80001964:	00004797          	auipc	a5,0x4
    80001968:	73878793          	addi	a5,a5,1848 # 8000609c <userret>
    8000196c:	00004697          	auipc	a3,0x4
    80001970:	69468693          	addi	a3,a3,1684 # 80006000 <_trampoline>
    80001974:	8f95                	sub	a5,a5,a3
    80001976:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001978:	577d                	li	a4,-1
    8000197a:	177e                	slli	a4,a4,0x3f
    8000197c:	8d59                	or	a0,a0,a4
    8000197e:	9782                	jalr	a5
}
    80001980:	70a2                	ld	ra,40(sp)
    80001982:	7402                	ld	s0,32(sp)
    80001984:	64e2                	ld	s1,24(sp)
    80001986:	6145                	addi	sp,sp,48
    80001988:	8082                	ret
      panic("exec");
    8000198a:	00005517          	auipc	a0,0x5
    8000198e:	7fe50513          	addi	a0,a0,2046 # 80007188 <etext+0x188>
    80001992:	e4ffe0ef          	jal	800007e0 <panic>

0000000080001996 <allocpid>:
{
    80001996:	1101                	addi	sp,sp,-32
    80001998:	ec06                	sd	ra,24(sp)
    8000199a:	e822                	sd	s0,16(sp)
    8000199c:	e426                	sd	s1,8(sp)
    8000199e:	e04a                	sd	s2,0(sp)
    800019a0:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019a2:	0000e917          	auipc	s2,0xe
    800019a6:	fc690913          	addi	s2,s2,-58 # 8000f968 <pid_lock>
    800019aa:	854a                	mv	a0,s2
    800019ac:	a22ff0ef          	jal	80000bce <acquire>
  pid = nextpid;
    800019b0:	00006797          	auipc	a5,0x6
    800019b4:	e8478793          	addi	a5,a5,-380 # 80007834 <nextpid>
    800019b8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019ba:	0014871b          	addiw	a4,s1,1
    800019be:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019c0:	854a                	mv	a0,s2
    800019c2:	aa4ff0ef          	jal	80000c66 <release>
}
    800019c6:	8526                	mv	a0,s1
    800019c8:	60e2                	ld	ra,24(sp)
    800019ca:	6442                	ld	s0,16(sp)
    800019cc:	64a2                	ld	s1,8(sp)
    800019ce:	6902                	ld	s2,0(sp)
    800019d0:	6105                	addi	sp,sp,32
    800019d2:	8082                	ret

00000000800019d4 <proc_pagetable>:
{
    800019d4:	1101                	addi	sp,sp,-32
    800019d6:	ec06                	sd	ra,24(sp)
    800019d8:	e822                	sd	s0,16(sp)
    800019da:	e426                	sd	s1,8(sp)
    800019dc:	e04a                	sd	s2,0(sp)
    800019de:	1000                	addi	s0,sp,32
    800019e0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019e2:	fb2ff0ef          	jal	80001194 <uvmcreate>
    800019e6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800019e8:	cd05                	beqz	a0,80001a20 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800019ea:	4729                	li	a4,10
    800019ec:	00004697          	auipc	a3,0x4
    800019f0:	61468693          	addi	a3,a3,1556 # 80006000 <_trampoline>
    800019f4:	6605                	lui	a2,0x1
    800019f6:	040005b7          	lui	a1,0x4000
    800019fa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019fc:	05b2                	slli	a1,a1,0xc
    800019fe:	df0ff0ef          	jal	80000fee <mappages>
    80001a02:	02054663          	bltz	a0,80001a2e <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a06:	4719                	li	a4,6
    80001a08:	05893683          	ld	a3,88(s2)
    80001a0c:	6605                	lui	a2,0x1
    80001a0e:	020005b7          	lui	a1,0x2000
    80001a12:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a14:	05b6                	slli	a1,a1,0xd
    80001a16:	8526                	mv	a0,s1
    80001a18:	dd6ff0ef          	jal	80000fee <mappages>
    80001a1c:	00054f63          	bltz	a0,80001a3a <proc_pagetable+0x66>
}
    80001a20:	8526                	mv	a0,s1
    80001a22:	60e2                	ld	ra,24(sp)
    80001a24:	6442                	ld	s0,16(sp)
    80001a26:	64a2                	ld	s1,8(sp)
    80001a28:	6902                	ld	s2,0(sp)
    80001a2a:	6105                	addi	sp,sp,32
    80001a2c:	8082                	ret
    uvmfree(pagetable, 0);
    80001a2e:	4581                	li	a1,0
    80001a30:	8526                	mv	a0,s1
    80001a32:	95dff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001a36:	4481                	li	s1,0
    80001a38:	b7e5                	j	80001a20 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a3a:	4681                	li	a3,0
    80001a3c:	4605                	li	a2,1
    80001a3e:	040005b7          	lui	a1,0x4000
    80001a42:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a44:	05b2                	slli	a1,a1,0xc
    80001a46:	8526                	mv	a0,s1
    80001a48:	f72ff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001a4c:	4581                	li	a1,0
    80001a4e:	8526                	mv	a0,s1
    80001a50:	93fff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001a54:	4481                	li	s1,0
    80001a56:	b7e9                	j	80001a20 <proc_pagetable+0x4c>

0000000080001a58 <proc_freepagetable>:
{
    80001a58:	1101                	addi	sp,sp,-32
    80001a5a:	ec06                	sd	ra,24(sp)
    80001a5c:	e822                	sd	s0,16(sp)
    80001a5e:	e426                	sd	s1,8(sp)
    80001a60:	e04a                	sd	s2,0(sp)
    80001a62:	1000                	addi	s0,sp,32
    80001a64:	84aa                	mv	s1,a0
    80001a66:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a68:	4681                	li	a3,0
    80001a6a:	4605                	li	a2,1
    80001a6c:	040005b7          	lui	a1,0x4000
    80001a70:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a72:	05b2                	slli	a1,a1,0xc
    80001a74:	f46ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a78:	4681                	li	a3,0
    80001a7a:	4605                	li	a2,1
    80001a7c:	020005b7          	lui	a1,0x2000
    80001a80:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a82:	05b6                	slli	a1,a1,0xd
    80001a84:	8526                	mv	a0,s1
    80001a86:	f34ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001a8a:	85ca                	mv	a1,s2
    80001a8c:	8526                	mv	a0,s1
    80001a8e:	901ff0ef          	jal	8000138e <uvmfree>
}
    80001a92:	60e2                	ld	ra,24(sp)
    80001a94:	6442                	ld	s0,16(sp)
    80001a96:	64a2                	ld	s1,8(sp)
    80001a98:	6902                	ld	s2,0(sp)
    80001a9a:	6105                	addi	sp,sp,32
    80001a9c:	8082                	ret

0000000080001a9e <freeproc>:
{
    80001a9e:	1101                	addi	sp,sp,-32
    80001aa0:	ec06                	sd	ra,24(sp)
    80001aa2:	e822                	sd	s0,16(sp)
    80001aa4:	e426                	sd	s1,8(sp)
    80001aa6:	1000                	addi	s0,sp,32
    80001aa8:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001aaa:	6d28                	ld	a0,88(a0)
    80001aac:	c119                	beqz	a0,80001ab2 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001aae:	f6ffe0ef          	jal	80000a1c <kfree>
  p->trapframe = 0;
    80001ab2:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001ab6:	68a8                	ld	a0,80(s1)
    80001ab8:	c501                	beqz	a0,80001ac0 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001aba:	64ac                	ld	a1,72(s1)
    80001abc:	f9dff0ef          	jal	80001a58 <proc_freepagetable>
  p->pagetable = 0;
    80001ac0:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ac4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ac8:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001acc:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ad0:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ad4:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ad8:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001adc:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ae0:	0004ac23          	sw	zero,24(s1)
}
    80001ae4:	60e2                	ld	ra,24(sp)
    80001ae6:	6442                	ld	s0,16(sp)
    80001ae8:	64a2                	ld	s1,8(sp)
    80001aea:	6105                	addi	sp,sp,32
    80001aec:	8082                	ret

0000000080001aee <allocproc>:
{
    80001aee:	1101                	addi	sp,sp,-32
    80001af0:	ec06                	sd	ra,24(sp)
    80001af2:	e822                	sd	s0,16(sp)
    80001af4:	e426                	sd	s1,8(sp)
    80001af6:	e04a                	sd	s2,0(sp)
    80001af8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001afa:	0000e497          	auipc	s1,0xe
    80001afe:	29e48493          	addi	s1,s1,670 # 8000fd98 <proc>
    80001b02:	00014917          	auipc	s2,0x14
    80001b06:	e9690913          	addi	s2,s2,-362 # 80015998 <tickslock>
    acquire(&p->lock);
    80001b0a:	8526                	mv	a0,s1
    80001b0c:	8c2ff0ef          	jal	80000bce <acquire>
    if(p->state == UNUSED) {
    80001b10:	4c9c                	lw	a5,24(s1)
    80001b12:	cb91                	beqz	a5,80001b26 <allocproc+0x38>
      release(&p->lock);
    80001b14:	8526                	mv	a0,s1
    80001b16:	950ff0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b1a:	17048493          	addi	s1,s1,368
    80001b1e:	ff2496e3          	bne	s1,s2,80001b0a <allocproc+0x1c>
  return 0;
    80001b22:	4481                	li	s1,0
    80001b24:	a899                	j	80001b7a <allocproc+0x8c>
  p->pid = allocpid();
    80001b26:	e71ff0ef          	jal	80001996 <allocpid>
    80001b2a:	d888                	sw	a0,48(s1)
p->deadline = DEFAULT_DEADLINE;
    80001b2c:	06400793          	li	a5,100
    80001b30:	16f4a423          	sw	a5,360(s1)
p->arrivaltime = ticks;  
    80001b34:	00006797          	auipc	a5,0x6
    80001b38:	d347a783          	lw	a5,-716(a5) # 80007868 <ticks>
    80001b3c:	16f4a623          	sw	a5,364(s1)
p->state = USED;
    80001b40:	4785                	li	a5,1
    80001b42:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b44:	fbbfe0ef          	jal	80000afe <kalloc>
    80001b48:	892a                	mv	s2,a0
    80001b4a:	eca8                	sd	a0,88(s1)
    80001b4c:	cd15                	beqz	a0,80001b88 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001b4e:	8526                	mv	a0,s1
    80001b50:	e85ff0ef          	jal	800019d4 <proc_pagetable>
    80001b54:	892a                	mv	s2,a0
    80001b56:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b58:	c121                	beqz	a0,80001b98 <allocproc+0xaa>
  memset(&p->context, 0, sizeof(p->context));
    80001b5a:	07000613          	li	a2,112
    80001b5e:	4581                	li	a1,0
    80001b60:	06048513          	addi	a0,s1,96
    80001b64:	93eff0ef          	jal	80000ca2 <memset>
  p->context.ra = (uint64)forkret;
    80001b68:	00000797          	auipc	a5,0x0
    80001b6c:	d9678793          	addi	a5,a5,-618 # 800018fe <forkret>
    80001b70:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b72:	60bc                	ld	a5,64(s1)
    80001b74:	6705                	lui	a4,0x1
    80001b76:	97ba                	add	a5,a5,a4
    80001b78:	f4bc                	sd	a5,104(s1)
}
    80001b7a:	8526                	mv	a0,s1
    80001b7c:	60e2                	ld	ra,24(sp)
    80001b7e:	6442                	ld	s0,16(sp)
    80001b80:	64a2                	ld	s1,8(sp)
    80001b82:	6902                	ld	s2,0(sp)
    80001b84:	6105                	addi	sp,sp,32
    80001b86:	8082                	ret
    freeproc(p);
    80001b88:	8526                	mv	a0,s1
    80001b8a:	f15ff0ef          	jal	80001a9e <freeproc>
    release(&p->lock);
    80001b8e:	8526                	mv	a0,s1
    80001b90:	8d6ff0ef          	jal	80000c66 <release>
    return 0;
    80001b94:	84ca                	mv	s1,s2
    80001b96:	b7d5                	j	80001b7a <allocproc+0x8c>
    freeproc(p);
    80001b98:	8526                	mv	a0,s1
    80001b9a:	f05ff0ef          	jal	80001a9e <freeproc>
    release(&p->lock);
    80001b9e:	8526                	mv	a0,s1
    80001ba0:	8c6ff0ef          	jal	80000c66 <release>
    return 0;
    80001ba4:	84ca                	mv	s1,s2
    80001ba6:	bfd1                	j	80001b7a <allocproc+0x8c>

0000000080001ba8 <userinit>:
{
    80001ba8:	1101                	addi	sp,sp,-32
    80001baa:	ec06                	sd	ra,24(sp)
    80001bac:	e822                	sd	s0,16(sp)
    80001bae:	e426                	sd	s1,8(sp)
    80001bb0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001bb2:	f3dff0ef          	jal	80001aee <allocproc>
    80001bb6:	84aa                	mv	s1,a0
  initproc = p;
    80001bb8:	00006797          	auipc	a5,0x6
    80001bbc:	caa7b423          	sd	a0,-856(a5) # 80007860 <initproc>
  p->cwd = namei("/");
    80001bc0:	00005517          	auipc	a0,0x5
    80001bc4:	5d050513          	addi	a0,a0,1488 # 80007190 <etext+0x190>
    80001bc8:	68d010ef          	jal	80003a54 <namei>
    80001bcc:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bd0:	478d                	li	a5,3
    80001bd2:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bd4:	8526                	mv	a0,s1
    80001bd6:	890ff0ef          	jal	80000c66 <release>
}
    80001bda:	60e2                	ld	ra,24(sp)
    80001bdc:	6442                	ld	s0,16(sp)
    80001bde:	64a2                	ld	s1,8(sp)
    80001be0:	6105                	addi	sp,sp,32
    80001be2:	8082                	ret

0000000080001be4 <growproc>:
{
    80001be4:	1101                	addi	sp,sp,-32
    80001be6:	ec06                	sd	ra,24(sp)
    80001be8:	e822                	sd	s0,16(sp)
    80001bea:	e426                	sd	s1,8(sp)
    80001bec:	e04a                	sd	s2,0(sp)
    80001bee:	1000                	addi	s0,sp,32
    80001bf0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001bf2:	cddff0ef          	jal	800018ce <myproc>
    80001bf6:	892a                	mv	s2,a0
  sz = p->sz;
    80001bf8:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bfa:	02905963          	blez	s1,80001c2c <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001bfe:	00b48633          	add	a2,s1,a1
    80001c02:	020007b7          	lui	a5,0x2000
    80001c06:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c08:	07b6                	slli	a5,a5,0xd
    80001c0a:	02c7ea63          	bltu	a5,a2,80001c3e <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c0e:	4691                	li	a3,4
    80001c10:	6928                	ld	a0,80(a0)
    80001c12:	e76ff0ef          	jal	80001288 <uvmalloc>
    80001c16:	85aa                	mv	a1,a0
    80001c18:	c50d                	beqz	a0,80001c42 <growproc+0x5e>
  p->sz = sz;
    80001c1a:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c1e:	4501                	li	a0,0
}
    80001c20:	60e2                	ld	ra,24(sp)
    80001c22:	6442                	ld	s0,16(sp)
    80001c24:	64a2                	ld	s1,8(sp)
    80001c26:	6902                	ld	s2,0(sp)
    80001c28:	6105                	addi	sp,sp,32
    80001c2a:	8082                	ret
  } else if(n < 0){
    80001c2c:	fe04d7e3          	bgez	s1,80001c1a <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c30:	00b48633          	add	a2,s1,a1
    80001c34:	6928                	ld	a0,80(a0)
    80001c36:	e0eff0ef          	jal	80001244 <uvmdealloc>
    80001c3a:	85aa                	mv	a1,a0
    80001c3c:	bff9                	j	80001c1a <growproc+0x36>
      return -1;
    80001c3e:	557d                	li	a0,-1
    80001c40:	b7c5                	j	80001c20 <growproc+0x3c>
      return -1;
    80001c42:	557d                	li	a0,-1
    80001c44:	bff1                	j	80001c20 <growproc+0x3c>

0000000080001c46 <kfork>:
{
    80001c46:	7139                	addi	sp,sp,-64
    80001c48:	fc06                	sd	ra,56(sp)
    80001c4a:	f822                	sd	s0,48(sp)
    80001c4c:	f04a                	sd	s2,32(sp)
    80001c4e:	e456                	sd	s5,8(sp)
    80001c50:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c52:	c7dff0ef          	jal	800018ce <myproc>
    80001c56:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c58:	e97ff0ef          	jal	80001aee <allocproc>
    80001c5c:	0e050a63          	beqz	a0,80001d50 <kfork+0x10a>
    80001c60:	e852                	sd	s4,16(sp)
    80001c62:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c64:	048ab603          	ld	a2,72(s5)
    80001c68:	692c                	ld	a1,80(a0)
    80001c6a:	050ab503          	ld	a0,80(s5)
    80001c6e:	f52ff0ef          	jal	800013c0 <uvmcopy>
    80001c72:	04054a63          	bltz	a0,80001cc6 <kfork+0x80>
    80001c76:	f426                	sd	s1,40(sp)
    80001c78:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c7a:	048ab783          	ld	a5,72(s5)
    80001c7e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c82:	058ab683          	ld	a3,88(s5)
    80001c86:	87b6                	mv	a5,a3
    80001c88:	058a3703          	ld	a4,88(s4)
    80001c8c:	12068693          	addi	a3,a3,288
    80001c90:	0007b803          	ld	a6,0(a5)
    80001c94:	6788                	ld	a0,8(a5)
    80001c96:	6b8c                	ld	a1,16(a5)
    80001c98:	6f90                	ld	a2,24(a5)
    80001c9a:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001c9e:	e708                	sd	a0,8(a4)
    80001ca0:	eb0c                	sd	a1,16(a4)
    80001ca2:	ef10                	sd	a2,24(a4)
    80001ca4:	02078793          	addi	a5,a5,32
    80001ca8:	02070713          	addi	a4,a4,32
    80001cac:	fed792e3          	bne	a5,a3,80001c90 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001cb0:	058a3783          	ld	a5,88(s4)
    80001cb4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001cb8:	0d0a8493          	addi	s1,s5,208
    80001cbc:	0d0a0913          	addi	s2,s4,208
    80001cc0:	150a8993          	addi	s3,s5,336
    80001cc4:	a831                	j	80001ce0 <kfork+0x9a>
    freeproc(np);
    80001cc6:	8552                	mv	a0,s4
    80001cc8:	dd7ff0ef          	jal	80001a9e <freeproc>
    release(&np->lock);
    80001ccc:	8552                	mv	a0,s4
    80001cce:	f99fe0ef          	jal	80000c66 <release>
    return -1;
    80001cd2:	597d                	li	s2,-1
    80001cd4:	6a42                	ld	s4,16(sp)
    80001cd6:	a0b5                	j	80001d42 <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001cd8:	04a1                	addi	s1,s1,8
    80001cda:	0921                	addi	s2,s2,8
    80001cdc:	01348963          	beq	s1,s3,80001cee <kfork+0xa8>
    if(p->ofile[i])
    80001ce0:	6088                	ld	a0,0(s1)
    80001ce2:	d97d                	beqz	a0,80001cd8 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ce4:	30a020ef          	jal	80003fee <filedup>
    80001ce8:	00a93023          	sd	a0,0(s2)
    80001cec:	b7f5                	j	80001cd8 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001cee:	150ab503          	ld	a0,336(s5)
    80001cf2:	516010ef          	jal	80003208 <idup>
    80001cf6:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cfa:	4641                	li	a2,16
    80001cfc:	158a8593          	addi	a1,s5,344
    80001d00:	158a0513          	addi	a0,s4,344
    80001d04:	8dcff0ef          	jal	80000de0 <safestrcpy>
  pid = np->pid;
    80001d08:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001d0c:	8552                	mv	a0,s4
    80001d0e:	f59fe0ef          	jal	80000c66 <release>
  acquire(&wait_lock);
    80001d12:	0000e497          	auipc	s1,0xe
    80001d16:	c6e48493          	addi	s1,s1,-914 # 8000f980 <wait_lock>
    80001d1a:	8526                	mv	a0,s1
    80001d1c:	eb3fe0ef          	jal	80000bce <acquire>
  np->parent = p;
    80001d20:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d24:	8526                	mv	a0,s1
    80001d26:	f41fe0ef          	jal	80000c66 <release>
  acquire(&np->lock);
    80001d2a:	8552                	mv	a0,s4
    80001d2c:	ea3fe0ef          	jal	80000bce <acquire>
  np->state = RUNNABLE;
    80001d30:	478d                	li	a5,3
    80001d32:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d36:	8552                	mv	a0,s4
    80001d38:	f2ffe0ef          	jal	80000c66 <release>
  return pid;
    80001d3c:	74a2                	ld	s1,40(sp)
    80001d3e:	69e2                	ld	s3,24(sp)
    80001d40:	6a42                	ld	s4,16(sp)
}
    80001d42:	854a                	mv	a0,s2
    80001d44:	70e2                	ld	ra,56(sp)
    80001d46:	7442                	ld	s0,48(sp)
    80001d48:	7902                	ld	s2,32(sp)
    80001d4a:	6aa2                	ld	s5,8(sp)
    80001d4c:	6121                	addi	sp,sp,64
    80001d4e:	8082                	ret
    return -1;
    80001d50:	597d                	li	s2,-1
    80001d52:	bfc5                	j	80001d42 <kfork+0xfc>

0000000080001d54 <scheduler>:
{
    80001d54:	715d                	addi	sp,sp,-80
    80001d56:	e486                	sd	ra,72(sp)
    80001d58:	e0a2                	sd	s0,64(sp)
    80001d5a:	fc26                	sd	s1,56(sp)
    80001d5c:	f84a                	sd	s2,48(sp)
    80001d5e:	f44e                	sd	s3,40(sp)
    80001d60:	f052                	sd	s4,32(sp)
    80001d62:	ec56                	sd	s5,24(sp)
    80001d64:	e85a                	sd	s6,16(sp)
    80001d66:	e45e                	sd	s7,8(sp)
    80001d68:	e062                	sd	s8,0(sp)
    80001d6a:	0880                	addi	s0,sp,80
    80001d6c:	8792                	mv	a5,tp
  int id = r_tp();
    80001d6e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d70:	00779b93          	slli	s7,a5,0x7
    80001d74:	0000e717          	auipc	a4,0xe
    80001d78:	bf470713          	addi	a4,a4,-1036 # 8000f968 <pid_lock>
    80001d7c:	975e                	add	a4,a4,s7
    80001d7e:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &earliest->context);
    80001d82:	0000e717          	auipc	a4,0xe
    80001d86:	c1e70713          	addi	a4,a4,-994 # 8000f9a0 <cpus+0x8>
    80001d8a:	9bba                	add	s7,s7,a4
    earliest = 0;
    80001d8c:	4b01                	li	s6,0
      if(p->state == RUNNABLE){
    80001d8e:	4a0d                	li	s4,3
    for(p = proc; p < &proc[NPROC]; p++){
    80001d90:	00014997          	auipc	s3,0x14
    80001d94:	c0898993          	addi	s3,s3,-1016 # 80015998 <tickslock>
      earliest->state = RUNNING;
    80001d98:	4c11                	li	s8,4
      c->proc = earliest;
    80001d9a:	079e                	slli	a5,a5,0x7
    80001d9c:	0000ea97          	auipc	s5,0xe
    80001da0:	bcca8a93          	addi	s5,s5,-1076 # 8000f968 <pid_lock>
    80001da4:	9abe                	add	s5,s5,a5
    80001da6:	a095                	j	80001e0a <scheduler+0xb6>
          release(&p->lock);
    80001da8:	8526                	mv	a0,s1
    80001daa:	ebdfe0ef          	jal	80000c66 <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80001dae:	17048493          	addi	s1,s1,368
    80001db2:	03348e63          	beq	s1,s3,80001dee <scheduler+0x9a>
      acquire(&p->lock);
    80001db6:	8526                	mv	a0,s1
    80001db8:	e17fe0ef          	jal	80000bce <acquire>
      if(p->state == RUNNABLE){
    80001dbc:	4c9c                	lw	a5,24(s1)
    80001dbe:	01479f63          	bne	a5,s4,80001ddc <scheduler+0x88>
        if(earliest == 0 || p->deadline < earliest->deadline){
    80001dc2:	06090063          	beqz	s2,80001e22 <scheduler+0xce>
    80001dc6:	1684a703          	lw	a4,360(s1)
    80001dca:	16892783          	lw	a5,360(s2)
    80001dce:	fcf75de3          	bge	a4,a5,80001da8 <scheduler+0x54>
            release(&earliest->lock);
    80001dd2:	854a                	mv	a0,s2
    80001dd4:	e93fe0ef          	jal	80000c66 <release>
          earliest = p;
    80001dd8:	8926                	mv	s2,s1
    80001dda:	bfd1                	j	80001dae <scheduler+0x5a>
        release(&p->lock);
    80001ddc:	8526                	mv	a0,s1
    80001dde:	e89fe0ef          	jal	80000c66 <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80001de2:	17048493          	addi	s1,s1,368
    80001de6:	fd3498e3          	bne	s1,s3,80001db6 <scheduler+0x62>
    if(earliest != 0){
    80001dea:	02090063          	beqz	s2,80001e0a <scheduler+0xb6>
      earliest->state = RUNNING;
    80001dee:	01892c23          	sw	s8,24(s2)
      c->proc = earliest;
    80001df2:	032ab823          	sd	s2,48(s5)
      swtch(&c->context, &earliest->context);
    80001df6:	06090593          	addi	a1,s2,96
    80001dfa:	855e                	mv	a0,s7
    80001dfc:	5a4000ef          	jal	800023a0 <swtch>
      c->proc = 0;
    80001e00:	020ab823          	sd	zero,48(s5)
      release(&earliest->lock);
    80001e04:	854a                	mv	a0,s2
    80001e06:	e61fe0ef          	jal	80000c66 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e0a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e0e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e12:	10079073          	csrw	sstatus,a5
    earliest = 0;
    80001e16:	895a                	mv	s2,s6
    for(p = proc; p < &proc[NPROC]; p++){
    80001e18:	0000e497          	auipc	s1,0xe
    80001e1c:	f8048493          	addi	s1,s1,-128 # 8000fd98 <proc>
    80001e20:	bf59                	j	80001db6 <scheduler+0x62>
          earliest = p;
    80001e22:	8926                	mv	s2,s1
    80001e24:	b769                	j	80001dae <scheduler+0x5a>

0000000080001e26 <sched>:
{
    80001e26:	7179                	addi	sp,sp,-48
    80001e28:	f406                	sd	ra,40(sp)
    80001e2a:	f022                	sd	s0,32(sp)
    80001e2c:	ec26                	sd	s1,24(sp)
    80001e2e:	e84a                	sd	s2,16(sp)
    80001e30:	e44e                	sd	s3,8(sp)
    80001e32:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e34:	a9bff0ef          	jal	800018ce <myproc>
    80001e38:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e3a:	d2bfe0ef          	jal	80000b64 <holding>
    80001e3e:	c92d                	beqz	a0,80001eb0 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e40:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e42:	2781                	sext.w	a5,a5
    80001e44:	079e                	slli	a5,a5,0x7
    80001e46:	0000e717          	auipc	a4,0xe
    80001e4a:	b2270713          	addi	a4,a4,-1246 # 8000f968 <pid_lock>
    80001e4e:	97ba                	add	a5,a5,a4
    80001e50:	0a87a703          	lw	a4,168(a5)
    80001e54:	4785                	li	a5,1
    80001e56:	06f71363          	bne	a4,a5,80001ebc <sched+0x96>
  if(p->state == RUNNING)
    80001e5a:	4c98                	lw	a4,24(s1)
    80001e5c:	4791                	li	a5,4
    80001e5e:	06f70563          	beq	a4,a5,80001ec8 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e62:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e66:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e68:	e7b5                	bnez	a5,80001ed4 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e6a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e6c:	0000e917          	auipc	s2,0xe
    80001e70:	afc90913          	addi	s2,s2,-1284 # 8000f968 <pid_lock>
    80001e74:	2781                	sext.w	a5,a5
    80001e76:	079e                	slli	a5,a5,0x7
    80001e78:	97ca                	add	a5,a5,s2
    80001e7a:	0ac7a983          	lw	s3,172(a5)
    80001e7e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e80:	2781                	sext.w	a5,a5
    80001e82:	079e                	slli	a5,a5,0x7
    80001e84:	0000e597          	auipc	a1,0xe
    80001e88:	b1c58593          	addi	a1,a1,-1252 # 8000f9a0 <cpus+0x8>
    80001e8c:	95be                	add	a1,a1,a5
    80001e8e:	06048513          	addi	a0,s1,96
    80001e92:	50e000ef          	jal	800023a0 <swtch>
    80001e96:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e98:	2781                	sext.w	a5,a5
    80001e9a:	079e                	slli	a5,a5,0x7
    80001e9c:	993e                	add	s2,s2,a5
    80001e9e:	0b392623          	sw	s3,172(s2)
}
    80001ea2:	70a2                	ld	ra,40(sp)
    80001ea4:	7402                	ld	s0,32(sp)
    80001ea6:	64e2                	ld	s1,24(sp)
    80001ea8:	6942                	ld	s2,16(sp)
    80001eaa:	69a2                	ld	s3,8(sp)
    80001eac:	6145                	addi	sp,sp,48
    80001eae:	8082                	ret
    panic("sched p->lock");
    80001eb0:	00005517          	auipc	a0,0x5
    80001eb4:	2e850513          	addi	a0,a0,744 # 80007198 <etext+0x198>
    80001eb8:	929fe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    80001ebc:	00005517          	auipc	a0,0x5
    80001ec0:	2ec50513          	addi	a0,a0,748 # 800071a8 <etext+0x1a8>
    80001ec4:	91dfe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    80001ec8:	00005517          	auipc	a0,0x5
    80001ecc:	2f050513          	addi	a0,a0,752 # 800071b8 <etext+0x1b8>
    80001ed0:	911fe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    80001ed4:	00005517          	auipc	a0,0x5
    80001ed8:	2f450513          	addi	a0,a0,756 # 800071c8 <etext+0x1c8>
    80001edc:	905fe0ef          	jal	800007e0 <panic>

0000000080001ee0 <yield>:
{
    80001ee0:	1101                	addi	sp,sp,-32
    80001ee2:	ec06                	sd	ra,24(sp)
    80001ee4:	e822                	sd	s0,16(sp)
    80001ee6:	e426                	sd	s1,8(sp)
    80001ee8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001eea:	9e5ff0ef          	jal	800018ce <myproc>
    80001eee:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001ef0:	cdffe0ef          	jal	80000bce <acquire>
  p->state = RUNNABLE;
    80001ef4:	478d                	li	a5,3
    80001ef6:	cc9c                	sw	a5,24(s1)
  sched();
    80001ef8:	f2fff0ef          	jal	80001e26 <sched>
  release(&p->lock);
    80001efc:	8526                	mv	a0,s1
    80001efe:	d69fe0ef          	jal	80000c66 <release>
}
    80001f02:	60e2                	ld	ra,24(sp)
    80001f04:	6442                	ld	s0,16(sp)
    80001f06:	64a2                	ld	s1,8(sp)
    80001f08:	6105                	addi	sp,sp,32
    80001f0a:	8082                	ret

0000000080001f0c <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001f0c:	7179                	addi	sp,sp,-48
    80001f0e:	f406                	sd	ra,40(sp)
    80001f10:	f022                	sd	s0,32(sp)
    80001f12:	ec26                	sd	s1,24(sp)
    80001f14:	e84a                	sd	s2,16(sp)
    80001f16:	e44e                	sd	s3,8(sp)
    80001f18:	1800                	addi	s0,sp,48
    80001f1a:	89aa                	mv	s3,a0
    80001f1c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f1e:	9b1ff0ef          	jal	800018ce <myproc>
    80001f22:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001f24:	cabfe0ef          	jal	80000bce <acquire>
  release(lk);
    80001f28:	854a                	mv	a0,s2
    80001f2a:	d3dfe0ef          	jal	80000c66 <release>

  // Go to sleep.
  p->chan = chan;
    80001f2e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f32:	4789                	li	a5,2
    80001f34:	cc9c                	sw	a5,24(s1)

  sched();
    80001f36:	ef1ff0ef          	jal	80001e26 <sched>

  // Tidy up.
  p->chan = 0;
    80001f3a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f3e:	8526                	mv	a0,s1
    80001f40:	d27fe0ef          	jal	80000c66 <release>
  acquire(lk);
    80001f44:	854a                	mv	a0,s2
    80001f46:	c89fe0ef          	jal	80000bce <acquire>
}
    80001f4a:	70a2                	ld	ra,40(sp)
    80001f4c:	7402                	ld	s0,32(sp)
    80001f4e:	64e2                	ld	s1,24(sp)
    80001f50:	6942                	ld	s2,16(sp)
    80001f52:	69a2                	ld	s3,8(sp)
    80001f54:	6145                	addi	sp,sp,48
    80001f56:	8082                	ret

0000000080001f58 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001f58:	7139                	addi	sp,sp,-64
    80001f5a:	fc06                	sd	ra,56(sp)
    80001f5c:	f822                	sd	s0,48(sp)
    80001f5e:	f426                	sd	s1,40(sp)
    80001f60:	f04a                	sd	s2,32(sp)
    80001f62:	ec4e                	sd	s3,24(sp)
    80001f64:	e852                	sd	s4,16(sp)
    80001f66:	e456                	sd	s5,8(sp)
    80001f68:	0080                	addi	s0,sp,64
    80001f6a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f6c:	0000e497          	auipc	s1,0xe
    80001f70:	e2c48493          	addi	s1,s1,-468 # 8000fd98 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f74:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f76:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f78:	00014917          	auipc	s2,0x14
    80001f7c:	a2090913          	addi	s2,s2,-1504 # 80015998 <tickslock>
    80001f80:	a801                	j	80001f90 <wakeup+0x38>
      }
      release(&p->lock);
    80001f82:	8526                	mv	a0,s1
    80001f84:	ce3fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f88:	17048493          	addi	s1,s1,368
    80001f8c:	03248263          	beq	s1,s2,80001fb0 <wakeup+0x58>
    if(p != myproc()){
    80001f90:	93fff0ef          	jal	800018ce <myproc>
    80001f94:	fea48ae3          	beq	s1,a0,80001f88 <wakeup+0x30>
      acquire(&p->lock);
    80001f98:	8526                	mv	a0,s1
    80001f9a:	c35fe0ef          	jal	80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f9e:	4c9c                	lw	a5,24(s1)
    80001fa0:	ff3791e3          	bne	a5,s3,80001f82 <wakeup+0x2a>
    80001fa4:	709c                	ld	a5,32(s1)
    80001fa6:	fd479ee3          	bne	a5,s4,80001f82 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001faa:	0154ac23          	sw	s5,24(s1)
    80001fae:	bfd1                	j	80001f82 <wakeup+0x2a>
    }
  }
}
    80001fb0:	70e2                	ld	ra,56(sp)
    80001fb2:	7442                	ld	s0,48(sp)
    80001fb4:	74a2                	ld	s1,40(sp)
    80001fb6:	7902                	ld	s2,32(sp)
    80001fb8:	69e2                	ld	s3,24(sp)
    80001fba:	6a42                	ld	s4,16(sp)
    80001fbc:	6aa2                	ld	s5,8(sp)
    80001fbe:	6121                	addi	sp,sp,64
    80001fc0:	8082                	ret

0000000080001fc2 <reparent>:
{
    80001fc2:	7179                	addi	sp,sp,-48
    80001fc4:	f406                	sd	ra,40(sp)
    80001fc6:	f022                	sd	s0,32(sp)
    80001fc8:	ec26                	sd	s1,24(sp)
    80001fca:	e84a                	sd	s2,16(sp)
    80001fcc:	e44e                	sd	s3,8(sp)
    80001fce:	e052                	sd	s4,0(sp)
    80001fd0:	1800                	addi	s0,sp,48
    80001fd2:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fd4:	0000e497          	auipc	s1,0xe
    80001fd8:	dc448493          	addi	s1,s1,-572 # 8000fd98 <proc>
      pp->parent = initproc;
    80001fdc:	00006a17          	auipc	s4,0x6
    80001fe0:	884a0a13          	addi	s4,s4,-1916 # 80007860 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fe4:	00014997          	auipc	s3,0x14
    80001fe8:	9b498993          	addi	s3,s3,-1612 # 80015998 <tickslock>
    80001fec:	a029                	j	80001ff6 <reparent+0x34>
    80001fee:	17048493          	addi	s1,s1,368
    80001ff2:	01348b63          	beq	s1,s3,80002008 <reparent+0x46>
    if(pp->parent == p){
    80001ff6:	7c9c                	ld	a5,56(s1)
    80001ff8:	ff279be3          	bne	a5,s2,80001fee <reparent+0x2c>
      pp->parent = initproc;
    80001ffc:	000a3503          	ld	a0,0(s4)
    80002000:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002002:	f57ff0ef          	jal	80001f58 <wakeup>
    80002006:	b7e5                	j	80001fee <reparent+0x2c>
}
    80002008:	70a2                	ld	ra,40(sp)
    8000200a:	7402                	ld	s0,32(sp)
    8000200c:	64e2                	ld	s1,24(sp)
    8000200e:	6942                	ld	s2,16(sp)
    80002010:	69a2                	ld	s3,8(sp)
    80002012:	6a02                	ld	s4,0(sp)
    80002014:	6145                	addi	sp,sp,48
    80002016:	8082                	ret

0000000080002018 <kexit>:
{
    80002018:	7179                	addi	sp,sp,-48
    8000201a:	f406                	sd	ra,40(sp)
    8000201c:	f022                	sd	s0,32(sp)
    8000201e:	ec26                	sd	s1,24(sp)
    80002020:	e84a                	sd	s2,16(sp)
    80002022:	e44e                	sd	s3,8(sp)
    80002024:	e052                	sd	s4,0(sp)
    80002026:	1800                	addi	s0,sp,48
    80002028:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000202a:	8a5ff0ef          	jal	800018ce <myproc>
    8000202e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002030:	00006797          	auipc	a5,0x6
    80002034:	8307b783          	ld	a5,-2000(a5) # 80007860 <initproc>
    80002038:	0d050493          	addi	s1,a0,208
    8000203c:	15050913          	addi	s2,a0,336
    80002040:	00a79f63          	bne	a5,a0,8000205e <kexit+0x46>
    panic("init exiting");
    80002044:	00005517          	auipc	a0,0x5
    80002048:	19c50513          	addi	a0,a0,412 # 800071e0 <etext+0x1e0>
    8000204c:	f94fe0ef          	jal	800007e0 <panic>
      fileclose(f);
    80002050:	7e5010ef          	jal	80004034 <fileclose>
      p->ofile[fd] = 0;
    80002054:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002058:	04a1                	addi	s1,s1,8
    8000205a:	01248563          	beq	s1,s2,80002064 <kexit+0x4c>
    if(p->ofile[fd]){
    8000205e:	6088                	ld	a0,0(s1)
    80002060:	f965                	bnez	a0,80002050 <kexit+0x38>
    80002062:	bfdd                	j	80002058 <kexit+0x40>
  begin_op();
    80002064:	3c5010ef          	jal	80003c28 <begin_op>
  iput(p->cwd);
    80002068:	1509b503          	ld	a0,336(s3)
    8000206c:	354010ef          	jal	800033c0 <iput>
  end_op();
    80002070:	423010ef          	jal	80003c92 <end_op>
  p->cwd = 0;
    80002074:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002078:	0000e497          	auipc	s1,0xe
    8000207c:	90848493          	addi	s1,s1,-1784 # 8000f980 <wait_lock>
    80002080:	8526                	mv	a0,s1
    80002082:	b4dfe0ef          	jal	80000bce <acquire>
  reparent(p);
    80002086:	854e                	mv	a0,s3
    80002088:	f3bff0ef          	jal	80001fc2 <reparent>
  wakeup(p->parent);
    8000208c:	0389b503          	ld	a0,56(s3)
    80002090:	ec9ff0ef          	jal	80001f58 <wakeup>
  acquire(&p->lock);
    80002094:	854e                	mv	a0,s3
    80002096:	b39fe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    8000209a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000209e:	4795                	li	a5,5
    800020a0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800020a4:	8526                	mv	a0,s1
    800020a6:	bc1fe0ef          	jal	80000c66 <release>
  sched();
    800020aa:	d7dff0ef          	jal	80001e26 <sched>
  panic("zombie exit");
    800020ae:	00005517          	auipc	a0,0x5
    800020b2:	14250513          	addi	a0,a0,322 # 800071f0 <etext+0x1f0>
    800020b6:	f2afe0ef          	jal	800007e0 <panic>

00000000800020ba <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800020ba:	7179                	addi	sp,sp,-48
    800020bc:	f406                	sd	ra,40(sp)
    800020be:	f022                	sd	s0,32(sp)
    800020c0:	ec26                	sd	s1,24(sp)
    800020c2:	e84a                	sd	s2,16(sp)
    800020c4:	e44e                	sd	s3,8(sp)
    800020c6:	1800                	addi	s0,sp,48
    800020c8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800020ca:	0000e497          	auipc	s1,0xe
    800020ce:	cce48493          	addi	s1,s1,-818 # 8000fd98 <proc>
    800020d2:	00014997          	auipc	s3,0x14
    800020d6:	8c698993          	addi	s3,s3,-1850 # 80015998 <tickslock>
    acquire(&p->lock);
    800020da:	8526                	mv	a0,s1
    800020dc:	af3fe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    800020e0:	589c                	lw	a5,48(s1)
    800020e2:	01278b63          	beq	a5,s2,800020f8 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020e6:	8526                	mv	a0,s1
    800020e8:	b7ffe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020ec:	17048493          	addi	s1,s1,368
    800020f0:	ff3495e3          	bne	s1,s3,800020da <kkill+0x20>
  }
  return -1;
    800020f4:	557d                	li	a0,-1
    800020f6:	a819                	j	8000210c <kkill+0x52>
      p->killed = 1;
    800020f8:	4785                	li	a5,1
    800020fa:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020fc:	4c98                	lw	a4,24(s1)
    800020fe:	4789                	li	a5,2
    80002100:	00f70d63          	beq	a4,a5,8000211a <kkill+0x60>
      release(&p->lock);
    80002104:	8526                	mv	a0,s1
    80002106:	b61fe0ef          	jal	80000c66 <release>
      return 0;
    8000210a:	4501                	li	a0,0
}
    8000210c:	70a2                	ld	ra,40(sp)
    8000210e:	7402                	ld	s0,32(sp)
    80002110:	64e2                	ld	s1,24(sp)
    80002112:	6942                	ld	s2,16(sp)
    80002114:	69a2                	ld	s3,8(sp)
    80002116:	6145                	addi	sp,sp,48
    80002118:	8082                	ret
        p->state = RUNNABLE;
    8000211a:	478d                	li	a5,3
    8000211c:	cc9c                	sw	a5,24(s1)
    8000211e:	b7dd                	j	80002104 <kkill+0x4a>

0000000080002120 <setkilled>:

void
setkilled(struct proc *p)
{
    80002120:	1101                	addi	sp,sp,-32
    80002122:	ec06                	sd	ra,24(sp)
    80002124:	e822                	sd	s0,16(sp)
    80002126:	e426                	sd	s1,8(sp)
    80002128:	1000                	addi	s0,sp,32
    8000212a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000212c:	aa3fe0ef          	jal	80000bce <acquire>
  p->killed = 1;
    80002130:	4785                	li	a5,1
    80002132:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002134:	8526                	mv	a0,s1
    80002136:	b31fe0ef          	jal	80000c66 <release>
}
    8000213a:	60e2                	ld	ra,24(sp)
    8000213c:	6442                	ld	s0,16(sp)
    8000213e:	64a2                	ld	s1,8(sp)
    80002140:	6105                	addi	sp,sp,32
    80002142:	8082                	ret

0000000080002144 <killed>:

int
killed(struct proc *p)
{
    80002144:	1101                	addi	sp,sp,-32
    80002146:	ec06                	sd	ra,24(sp)
    80002148:	e822                	sd	s0,16(sp)
    8000214a:	e426                	sd	s1,8(sp)
    8000214c:	e04a                	sd	s2,0(sp)
    8000214e:	1000                	addi	s0,sp,32
    80002150:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002152:	a7dfe0ef          	jal	80000bce <acquire>
  k = p->killed;
    80002156:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000215a:	8526                	mv	a0,s1
    8000215c:	b0bfe0ef          	jal	80000c66 <release>
  return k;
}
    80002160:	854a                	mv	a0,s2
    80002162:	60e2                	ld	ra,24(sp)
    80002164:	6442                	ld	s0,16(sp)
    80002166:	64a2                	ld	s1,8(sp)
    80002168:	6902                	ld	s2,0(sp)
    8000216a:	6105                	addi	sp,sp,32
    8000216c:	8082                	ret

000000008000216e <kwait>:
{
    8000216e:	715d                	addi	sp,sp,-80
    80002170:	e486                	sd	ra,72(sp)
    80002172:	e0a2                	sd	s0,64(sp)
    80002174:	fc26                	sd	s1,56(sp)
    80002176:	f84a                	sd	s2,48(sp)
    80002178:	f44e                	sd	s3,40(sp)
    8000217a:	f052                	sd	s4,32(sp)
    8000217c:	ec56                	sd	s5,24(sp)
    8000217e:	e85a                	sd	s6,16(sp)
    80002180:	e45e                	sd	s7,8(sp)
    80002182:	e062                	sd	s8,0(sp)
    80002184:	0880                	addi	s0,sp,80
    80002186:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002188:	f46ff0ef          	jal	800018ce <myproc>
    8000218c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000218e:	0000d517          	auipc	a0,0xd
    80002192:	7f250513          	addi	a0,a0,2034 # 8000f980 <wait_lock>
    80002196:	a39fe0ef          	jal	80000bce <acquire>
    havekids = 0;
    8000219a:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000219c:	4a15                	li	s4,5
        havekids = 1;
    8000219e:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021a0:	00013997          	auipc	s3,0x13
    800021a4:	7f898993          	addi	s3,s3,2040 # 80015998 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021a8:	0000dc17          	auipc	s8,0xd
    800021ac:	7d8c0c13          	addi	s8,s8,2008 # 8000f980 <wait_lock>
    800021b0:	a871                	j	8000224c <kwait+0xde>
          pid = pp->pid;
    800021b2:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800021b6:	000b0c63          	beqz	s6,800021ce <kwait+0x60>
    800021ba:	4691                	li	a3,4
    800021bc:	02c48613          	addi	a2,s1,44
    800021c0:	85da                	mv	a1,s6
    800021c2:	05093503          	ld	a0,80(s2)
    800021c6:	c1cff0ef          	jal	800015e2 <copyout>
    800021ca:	02054b63          	bltz	a0,80002200 <kwait+0x92>
          freeproc(pp);
    800021ce:	8526                	mv	a0,s1
    800021d0:	8cfff0ef          	jal	80001a9e <freeproc>
          release(&pp->lock);
    800021d4:	8526                	mv	a0,s1
    800021d6:	a91fe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    800021da:	0000d517          	auipc	a0,0xd
    800021de:	7a650513          	addi	a0,a0,1958 # 8000f980 <wait_lock>
    800021e2:	a85fe0ef          	jal	80000c66 <release>
}
    800021e6:	854e                	mv	a0,s3
    800021e8:	60a6                	ld	ra,72(sp)
    800021ea:	6406                	ld	s0,64(sp)
    800021ec:	74e2                	ld	s1,56(sp)
    800021ee:	7942                	ld	s2,48(sp)
    800021f0:	79a2                	ld	s3,40(sp)
    800021f2:	7a02                	ld	s4,32(sp)
    800021f4:	6ae2                	ld	s5,24(sp)
    800021f6:	6b42                	ld	s6,16(sp)
    800021f8:	6ba2                	ld	s7,8(sp)
    800021fa:	6c02                	ld	s8,0(sp)
    800021fc:	6161                	addi	sp,sp,80
    800021fe:	8082                	ret
            release(&pp->lock);
    80002200:	8526                	mv	a0,s1
    80002202:	a65fe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    80002206:	0000d517          	auipc	a0,0xd
    8000220a:	77a50513          	addi	a0,a0,1914 # 8000f980 <wait_lock>
    8000220e:	a59fe0ef          	jal	80000c66 <release>
            return -1;
    80002212:	59fd                	li	s3,-1
    80002214:	bfc9                	j	800021e6 <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002216:	17048493          	addi	s1,s1,368
    8000221a:	03348063          	beq	s1,s3,8000223a <kwait+0xcc>
      if(pp->parent == p){
    8000221e:	7c9c                	ld	a5,56(s1)
    80002220:	ff279be3          	bne	a5,s2,80002216 <kwait+0xa8>
        acquire(&pp->lock);
    80002224:	8526                	mv	a0,s1
    80002226:	9a9fe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    8000222a:	4c9c                	lw	a5,24(s1)
    8000222c:	f94783e3          	beq	a5,s4,800021b2 <kwait+0x44>
        release(&pp->lock);
    80002230:	8526                	mv	a0,s1
    80002232:	a35fe0ef          	jal	80000c66 <release>
        havekids = 1;
    80002236:	8756                	mv	a4,s5
    80002238:	bff9                	j	80002216 <kwait+0xa8>
    if(!havekids || killed(p)){
    8000223a:	cf19                	beqz	a4,80002258 <kwait+0xea>
    8000223c:	854a                	mv	a0,s2
    8000223e:	f07ff0ef          	jal	80002144 <killed>
    80002242:	e919                	bnez	a0,80002258 <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002244:	85e2                	mv	a1,s8
    80002246:	854a                	mv	a0,s2
    80002248:	cc5ff0ef          	jal	80001f0c <sleep>
    havekids = 0;
    8000224c:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000224e:	0000e497          	auipc	s1,0xe
    80002252:	b4a48493          	addi	s1,s1,-1206 # 8000fd98 <proc>
    80002256:	b7e1                	j	8000221e <kwait+0xb0>
      release(&wait_lock);
    80002258:	0000d517          	auipc	a0,0xd
    8000225c:	72850513          	addi	a0,a0,1832 # 8000f980 <wait_lock>
    80002260:	a07fe0ef          	jal	80000c66 <release>
      return -1;
    80002264:	59fd                	li	s3,-1
    80002266:	b741                	j	800021e6 <kwait+0x78>

0000000080002268 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002268:	7179                	addi	sp,sp,-48
    8000226a:	f406                	sd	ra,40(sp)
    8000226c:	f022                	sd	s0,32(sp)
    8000226e:	ec26                	sd	s1,24(sp)
    80002270:	e84a                	sd	s2,16(sp)
    80002272:	e44e                	sd	s3,8(sp)
    80002274:	e052                	sd	s4,0(sp)
    80002276:	1800                	addi	s0,sp,48
    80002278:	84aa                	mv	s1,a0
    8000227a:	892e                	mv	s2,a1
    8000227c:	89b2                	mv	s3,a2
    8000227e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002280:	e4eff0ef          	jal	800018ce <myproc>
  if(user_dst){
    80002284:	cc99                	beqz	s1,800022a2 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002286:	86d2                	mv	a3,s4
    80002288:	864e                	mv	a2,s3
    8000228a:	85ca                	mv	a1,s2
    8000228c:	6928                	ld	a0,80(a0)
    8000228e:	b54ff0ef          	jal	800015e2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002292:	70a2                	ld	ra,40(sp)
    80002294:	7402                	ld	s0,32(sp)
    80002296:	64e2                	ld	s1,24(sp)
    80002298:	6942                	ld	s2,16(sp)
    8000229a:	69a2                	ld	s3,8(sp)
    8000229c:	6a02                	ld	s4,0(sp)
    8000229e:	6145                	addi	sp,sp,48
    800022a0:	8082                	ret
    memmove((char *)dst, src, len);
    800022a2:	000a061b          	sext.w	a2,s4
    800022a6:	85ce                	mv	a1,s3
    800022a8:	854a                	mv	a0,s2
    800022aa:	a55fe0ef          	jal	80000cfe <memmove>
    return 0;
    800022ae:	8526                	mv	a0,s1
    800022b0:	b7cd                	j	80002292 <either_copyout+0x2a>

00000000800022b2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800022b2:	7179                	addi	sp,sp,-48
    800022b4:	f406                	sd	ra,40(sp)
    800022b6:	f022                	sd	s0,32(sp)
    800022b8:	ec26                	sd	s1,24(sp)
    800022ba:	e84a                	sd	s2,16(sp)
    800022bc:	e44e                	sd	s3,8(sp)
    800022be:	e052                	sd	s4,0(sp)
    800022c0:	1800                	addi	s0,sp,48
    800022c2:	892a                	mv	s2,a0
    800022c4:	84ae                	mv	s1,a1
    800022c6:	89b2                	mv	s3,a2
    800022c8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022ca:	e04ff0ef          	jal	800018ce <myproc>
  if(user_src){
    800022ce:	cc99                	beqz	s1,800022ec <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800022d0:	86d2                	mv	a3,s4
    800022d2:	864e                	mv	a2,s3
    800022d4:	85ca                	mv	a1,s2
    800022d6:	6928                	ld	a0,80(a0)
    800022d8:	beeff0ef          	jal	800016c6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022dc:	70a2                	ld	ra,40(sp)
    800022de:	7402                	ld	s0,32(sp)
    800022e0:	64e2                	ld	s1,24(sp)
    800022e2:	6942                	ld	s2,16(sp)
    800022e4:	69a2                	ld	s3,8(sp)
    800022e6:	6a02                	ld	s4,0(sp)
    800022e8:	6145                	addi	sp,sp,48
    800022ea:	8082                	ret
    memmove(dst, (char*)src, len);
    800022ec:	000a061b          	sext.w	a2,s4
    800022f0:	85ce                	mv	a1,s3
    800022f2:	854a                	mv	a0,s2
    800022f4:	a0bfe0ef          	jal	80000cfe <memmove>
    return 0;
    800022f8:	8526                	mv	a0,s1
    800022fa:	b7cd                	j	800022dc <either_copyin+0x2a>

00000000800022fc <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022fc:	715d                	addi	sp,sp,-80
    800022fe:	e486                	sd	ra,72(sp)
    80002300:	e0a2                	sd	s0,64(sp)
    80002302:	fc26                	sd	s1,56(sp)
    80002304:	f84a                	sd	s2,48(sp)
    80002306:	f44e                	sd	s3,40(sp)
    80002308:	f052                	sd	s4,32(sp)
    8000230a:	ec56                	sd	s5,24(sp)
    8000230c:	e85a                	sd	s6,16(sp)
    8000230e:	e45e                	sd	s7,8(sp)
    80002310:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002312:	00005517          	auipc	a0,0x5
    80002316:	d6650513          	addi	a0,a0,-666 # 80007078 <etext+0x78>
    8000231a:	9e0fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000231e:	0000e497          	auipc	s1,0xe
    80002322:	bd248493          	addi	s1,s1,-1070 # 8000fef0 <proc+0x158>
    80002326:	00013917          	auipc	s2,0x13
    8000232a:	7ca90913          	addi	s2,s2,1994 # 80015af0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000232e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002330:	00005997          	auipc	s3,0x5
    80002334:	ed098993          	addi	s3,s3,-304 # 80007200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    80002338:	00005a97          	auipc	s5,0x5
    8000233c:	ed0a8a93          	addi	s5,s5,-304 # 80007208 <etext+0x208>
    printf("\n");
    80002340:	00005a17          	auipc	s4,0x5
    80002344:	d38a0a13          	addi	s4,s4,-712 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002348:	00005b97          	auipc	s7,0x5
    8000234c:	3e0b8b93          	addi	s7,s7,992 # 80007728 <states.0>
    80002350:	a829                	j	8000236a <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002352:	ed86a583          	lw	a1,-296(a3)
    80002356:	8556                	mv	a0,s5
    80002358:	9a2fe0ef          	jal	800004fa <printf>
    printf("\n");
    8000235c:	8552                	mv	a0,s4
    8000235e:	99cfe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002362:	17048493          	addi	s1,s1,368
    80002366:	03248263          	beq	s1,s2,8000238a <procdump+0x8e>
    if(p->state == UNUSED)
    8000236a:	86a6                	mv	a3,s1
    8000236c:	ec04a783          	lw	a5,-320(s1)
    80002370:	dbed                	beqz	a5,80002362 <procdump+0x66>
      state = "???";
    80002372:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002374:	fcfb6fe3          	bltu	s6,a5,80002352 <procdump+0x56>
    80002378:	02079713          	slli	a4,a5,0x20
    8000237c:	01d75793          	srli	a5,a4,0x1d
    80002380:	97de                	add	a5,a5,s7
    80002382:	6390                	ld	a2,0(a5)
    80002384:	f679                	bnez	a2,80002352 <procdump+0x56>
      state = "???";
    80002386:	864e                	mv	a2,s3
    80002388:	b7e9                	j	80002352 <procdump+0x56>
  }
}
    8000238a:	60a6                	ld	ra,72(sp)
    8000238c:	6406                	ld	s0,64(sp)
    8000238e:	74e2                	ld	s1,56(sp)
    80002390:	7942                	ld	s2,48(sp)
    80002392:	79a2                	ld	s3,40(sp)
    80002394:	7a02                	ld	s4,32(sp)
    80002396:	6ae2                	ld	s5,24(sp)
    80002398:	6b42                	ld	s6,16(sp)
    8000239a:	6ba2                	ld	s7,8(sp)
    8000239c:	6161                	addi	sp,sp,80
    8000239e:	8082                	ret

00000000800023a0 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800023a0:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800023a4:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800023a8:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800023aa:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800023ac:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800023b0:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800023b4:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800023b8:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800023bc:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800023c0:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800023c4:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800023c8:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800023cc:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800023d0:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800023d4:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800023d8:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800023dc:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800023de:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800023e0:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800023e4:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800023e8:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800023ec:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800023f0:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800023f4:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800023f8:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800023fc:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002400:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002404:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002408:	8082                	ret

000000008000240a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000240a:	1141                	addi	sp,sp,-16
    8000240c:	e406                	sd	ra,8(sp)
    8000240e:	e022                	sd	s0,0(sp)
    80002410:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002412:	00005597          	auipc	a1,0x5
    80002416:	e3658593          	addi	a1,a1,-458 # 80007248 <etext+0x248>
    8000241a:	00013517          	auipc	a0,0x13
    8000241e:	57e50513          	addi	a0,a0,1406 # 80015998 <tickslock>
    80002422:	f2cfe0ef          	jal	80000b4e <initlock>
}
    80002426:	60a2                	ld	ra,8(sp)
    80002428:	6402                	ld	s0,0(sp)
    8000242a:	0141                	addi	sp,sp,16
    8000242c:	8082                	ret

000000008000242e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000242e:	1141                	addi	sp,sp,-16
    80002430:	e422                	sd	s0,8(sp)
    80002432:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002434:	00003797          	auipc	a5,0x3
    80002438:	f7c78793          	addi	a5,a5,-132 # 800053b0 <kernelvec>
    8000243c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002440:	6422                	ld	s0,8(sp)
    80002442:	0141                	addi	sp,sp,16
    80002444:	8082                	ret

0000000080002446 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002446:	1141                	addi	sp,sp,-16
    80002448:	e406                	sd	ra,8(sp)
    8000244a:	e022                	sd	s0,0(sp)
    8000244c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000244e:	c80ff0ef          	jal	800018ce <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002452:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002456:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002458:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000245c:	04000737          	lui	a4,0x4000
    80002460:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002462:	0732                	slli	a4,a4,0xc
    80002464:	00004797          	auipc	a5,0x4
    80002468:	b9c78793          	addi	a5,a5,-1124 # 80006000 <_trampoline>
    8000246c:	00004697          	auipc	a3,0x4
    80002470:	b9468693          	addi	a3,a3,-1132 # 80006000 <_trampoline>
    80002474:	8f95                	sub	a5,a5,a3
    80002476:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002478:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000247c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000247e:	18002773          	csrr	a4,satp
    80002482:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002484:	6d38                	ld	a4,88(a0)
    80002486:	613c                	ld	a5,64(a0)
    80002488:	6685                	lui	a3,0x1
    8000248a:	97b6                	add	a5,a5,a3
    8000248c:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000248e:	6d3c                	ld	a5,88(a0)
    80002490:	00000717          	auipc	a4,0x0
    80002494:	0f870713          	addi	a4,a4,248 # 80002588 <usertrap>
    80002498:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000249a:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000249c:	8712                	mv	a4,tp
    8000249e:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024a0:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800024a4:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800024a8:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024ac:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800024b0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800024b2:	6f9c                	ld	a5,24(a5)
    800024b4:	14179073          	csrw	sepc,a5
}
    800024b8:	60a2                	ld	ra,8(sp)
    800024ba:	6402                	ld	s0,0(sp)
    800024bc:	0141                	addi	sp,sp,16
    800024be:	8082                	ret

00000000800024c0 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800024c0:	1101                	addi	sp,sp,-32
    800024c2:	ec06                	sd	ra,24(sp)
    800024c4:	e822                	sd	s0,16(sp)
    800024c6:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800024c8:	bdaff0ef          	jal	800018a2 <cpuid>
    800024cc:	cd11                	beqz	a0,800024e8 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800024ce:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800024d2:	000f4737          	lui	a4,0xf4
    800024d6:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800024da:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800024dc:	14d79073          	csrw	stimecmp,a5
}
    800024e0:	60e2                	ld	ra,24(sp)
    800024e2:	6442                	ld	s0,16(sp)
    800024e4:	6105                	addi	sp,sp,32
    800024e6:	8082                	ret
    800024e8:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024ea:	00013497          	auipc	s1,0x13
    800024ee:	4ae48493          	addi	s1,s1,1198 # 80015998 <tickslock>
    800024f2:	8526                	mv	a0,s1
    800024f4:	edafe0ef          	jal	80000bce <acquire>
    ticks++;
    800024f8:	00005517          	auipc	a0,0x5
    800024fc:	37050513          	addi	a0,a0,880 # 80007868 <ticks>
    80002500:	411c                	lw	a5,0(a0)
    80002502:	2785                	addiw	a5,a5,1
    80002504:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002506:	a53ff0ef          	jal	80001f58 <wakeup>
    release(&tickslock);
    8000250a:	8526                	mv	a0,s1
    8000250c:	f5afe0ef          	jal	80000c66 <release>
    80002510:	64a2                	ld	s1,8(sp)
    80002512:	bf75                	j	800024ce <clockintr+0xe>

0000000080002514 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002514:	1101                	addi	sp,sp,-32
    80002516:	ec06                	sd	ra,24(sp)
    80002518:	e822                	sd	s0,16(sp)
    8000251a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000251c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002520:	57fd                	li	a5,-1
    80002522:	17fe                	slli	a5,a5,0x3f
    80002524:	07a5                	addi	a5,a5,9
    80002526:	00f70c63          	beq	a4,a5,8000253e <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000252a:	57fd                	li	a5,-1
    8000252c:	17fe                	slli	a5,a5,0x3f
    8000252e:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002530:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002532:	04f70763          	beq	a4,a5,80002580 <devintr+0x6c>
  }
}
    80002536:	60e2                	ld	ra,24(sp)
    80002538:	6442                	ld	s0,16(sp)
    8000253a:	6105                	addi	sp,sp,32
    8000253c:	8082                	ret
    8000253e:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002540:	71d020ef          	jal	8000545c <plic_claim>
    80002544:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002546:	47a9                	li	a5,10
    80002548:	00f50963          	beq	a0,a5,8000255a <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    8000254c:	4785                	li	a5,1
    8000254e:	00f50963          	beq	a0,a5,80002560 <devintr+0x4c>
    return 1;
    80002552:	4505                	li	a0,1
    } else if(irq){
    80002554:	e889                	bnez	s1,80002566 <devintr+0x52>
    80002556:	64a2                	ld	s1,8(sp)
    80002558:	bff9                	j	80002536 <devintr+0x22>
      uartintr();
    8000255a:	c56fe0ef          	jal	800009b0 <uartintr>
    if(irq)
    8000255e:	a819                	j	80002574 <devintr+0x60>
      virtio_disk_intr();
    80002560:	3c2030ef          	jal	80005922 <virtio_disk_intr>
    if(irq)
    80002564:	a801                	j	80002574 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002566:	85a6                	mv	a1,s1
    80002568:	00005517          	auipc	a0,0x5
    8000256c:	ce850513          	addi	a0,a0,-792 # 80007250 <etext+0x250>
    80002570:	f8bfd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002574:	8526                	mv	a0,s1
    80002576:	707020ef          	jal	8000547c <plic_complete>
    return 1;
    8000257a:	4505                	li	a0,1
    8000257c:	64a2                	ld	s1,8(sp)
    8000257e:	bf65                	j	80002536 <devintr+0x22>
    clockintr();
    80002580:	f41ff0ef          	jal	800024c0 <clockintr>
    return 2;
    80002584:	4509                	li	a0,2
    80002586:	bf45                	j	80002536 <devintr+0x22>

0000000080002588 <usertrap>:
{
    80002588:	1101                	addi	sp,sp,-32
    8000258a:	ec06                	sd	ra,24(sp)
    8000258c:	e822                	sd	s0,16(sp)
    8000258e:	e426                	sd	s1,8(sp)
    80002590:	e04a                	sd	s2,0(sp)
    80002592:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002594:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002598:	1007f793          	andi	a5,a5,256
    8000259c:	eba5                	bnez	a5,8000260c <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000259e:	00003797          	auipc	a5,0x3
    800025a2:	e1278793          	addi	a5,a5,-494 # 800053b0 <kernelvec>
    800025a6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800025aa:	b24ff0ef          	jal	800018ce <myproc>
    800025ae:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800025b0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025b2:	14102773          	csrr	a4,sepc
    800025b6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025b8:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800025bc:	47a1                	li	a5,8
    800025be:	04f70d63          	beq	a4,a5,80002618 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    800025c2:	f53ff0ef          	jal	80002514 <devintr>
    800025c6:	892a                	mv	s2,a0
    800025c8:	e945                	bnez	a0,80002678 <usertrap+0xf0>
    800025ca:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800025ce:	47bd                	li	a5,15
    800025d0:	08f70863          	beq	a4,a5,80002660 <usertrap+0xd8>
    800025d4:	14202773          	csrr	a4,scause
    800025d8:	47b5                	li	a5,13
    800025da:	08f70363          	beq	a4,a5,80002660 <usertrap+0xd8>
    800025de:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800025e2:	5890                	lw	a2,48(s1)
    800025e4:	00005517          	auipc	a0,0x5
    800025e8:	cac50513          	addi	a0,a0,-852 # 80007290 <etext+0x290>
    800025ec:	f0ffd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025f0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025f4:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800025f8:	00005517          	auipc	a0,0x5
    800025fc:	cc850513          	addi	a0,a0,-824 # 800072c0 <etext+0x2c0>
    80002600:	efbfd0ef          	jal	800004fa <printf>
    setkilled(p);
    80002604:	8526                	mv	a0,s1
    80002606:	b1bff0ef          	jal	80002120 <setkilled>
    8000260a:	a035                	j	80002636 <usertrap+0xae>
    panic("usertrap: not from user mode");
    8000260c:	00005517          	auipc	a0,0x5
    80002610:	c6450513          	addi	a0,a0,-924 # 80007270 <etext+0x270>
    80002614:	9ccfe0ef          	jal	800007e0 <panic>
    if(killed(p))
    80002618:	b2dff0ef          	jal	80002144 <killed>
    8000261c:	ed15                	bnez	a0,80002658 <usertrap+0xd0>
    p->trapframe->epc += 4;
    8000261e:	6cb8                	ld	a4,88(s1)
    80002620:	6f1c                	ld	a5,24(a4)
    80002622:	0791                	addi	a5,a5,4
    80002624:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002626:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000262a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000262e:	10079073          	csrw	sstatus,a5
    syscall();
    80002632:	246000ef          	jal	80002878 <syscall>
  if(killed(p))
    80002636:	8526                	mv	a0,s1
    80002638:	b0dff0ef          	jal	80002144 <killed>
    8000263c:	e139                	bnez	a0,80002682 <usertrap+0xfa>
  prepare_return();
    8000263e:	e09ff0ef          	jal	80002446 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002642:	68a8                	ld	a0,80(s1)
    80002644:	8131                	srli	a0,a0,0xc
    80002646:	57fd                	li	a5,-1
    80002648:	17fe                	slli	a5,a5,0x3f
    8000264a:	8d5d                	or	a0,a0,a5
}
    8000264c:	60e2                	ld	ra,24(sp)
    8000264e:	6442                	ld	s0,16(sp)
    80002650:	64a2                	ld	s1,8(sp)
    80002652:	6902                	ld	s2,0(sp)
    80002654:	6105                	addi	sp,sp,32
    80002656:	8082                	ret
      kexit(-1);
    80002658:	557d                	li	a0,-1
    8000265a:	9bfff0ef          	jal	80002018 <kexit>
    8000265e:	b7c1                	j	8000261e <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002660:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002664:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002668:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    8000266a:	00163613          	seqz	a2,a2
    8000266e:	68a8                	ld	a0,80(s1)
    80002670:	ef1fe0ef          	jal	80001560 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002674:	f169                	bnez	a0,80002636 <usertrap+0xae>
    80002676:	b7a5                	j	800025de <usertrap+0x56>
  if(killed(p))
    80002678:	8526                	mv	a0,s1
    8000267a:	acbff0ef          	jal	80002144 <killed>
    8000267e:	c511                	beqz	a0,8000268a <usertrap+0x102>
    80002680:	a011                	j	80002684 <usertrap+0xfc>
    80002682:	4901                	li	s2,0
    kexit(-1);
    80002684:	557d                	li	a0,-1
    80002686:	993ff0ef          	jal	80002018 <kexit>
  if(which_dev == 2)
    8000268a:	4789                	li	a5,2
    8000268c:	faf919e3          	bne	s2,a5,8000263e <usertrap+0xb6>
    yield();
    80002690:	851ff0ef          	jal	80001ee0 <yield>
    80002694:	b76d                	j	8000263e <usertrap+0xb6>

0000000080002696 <kerneltrap>:
{
    80002696:	7179                	addi	sp,sp,-48
    80002698:	f406                	sd	ra,40(sp)
    8000269a:	f022                	sd	s0,32(sp)
    8000269c:	ec26                	sd	s1,24(sp)
    8000269e:	e84a                	sd	s2,16(sp)
    800026a0:	e44e                	sd	s3,8(sp)
    800026a2:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026a4:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026a8:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026ac:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800026b0:	1004f793          	andi	a5,s1,256
    800026b4:	c795                	beqz	a5,800026e0 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026b6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800026ba:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800026bc:	eb85                	bnez	a5,800026ec <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800026be:	e57ff0ef          	jal	80002514 <devintr>
    800026c2:	c91d                	beqz	a0,800026f8 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800026c4:	4789                	li	a5,2
    800026c6:	04f50a63          	beq	a0,a5,8000271a <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026ca:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026ce:	10049073          	csrw	sstatus,s1
}
    800026d2:	70a2                	ld	ra,40(sp)
    800026d4:	7402                	ld	s0,32(sp)
    800026d6:	64e2                	ld	s1,24(sp)
    800026d8:	6942                	ld	s2,16(sp)
    800026da:	69a2                	ld	s3,8(sp)
    800026dc:	6145                	addi	sp,sp,48
    800026de:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026e0:	00005517          	auipc	a0,0x5
    800026e4:	c0850513          	addi	a0,a0,-1016 # 800072e8 <etext+0x2e8>
    800026e8:	8f8fe0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    800026ec:	00005517          	auipc	a0,0x5
    800026f0:	c2450513          	addi	a0,a0,-988 # 80007310 <etext+0x310>
    800026f4:	8ecfe0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026f8:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026fc:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002700:	85ce                	mv	a1,s3
    80002702:	00005517          	auipc	a0,0x5
    80002706:	c2e50513          	addi	a0,a0,-978 # 80007330 <etext+0x330>
    8000270a:	df1fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    8000270e:	00005517          	auipc	a0,0x5
    80002712:	c4a50513          	addi	a0,a0,-950 # 80007358 <etext+0x358>
    80002716:	8cafe0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000271a:	9b4ff0ef          	jal	800018ce <myproc>
    8000271e:	d555                	beqz	a0,800026ca <kerneltrap+0x34>
    yield();
    80002720:	fc0ff0ef          	jal	80001ee0 <yield>
    80002724:	b75d                	j	800026ca <kerneltrap+0x34>

0000000080002726 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002726:	1101                	addi	sp,sp,-32
    80002728:	ec06                	sd	ra,24(sp)
    8000272a:	e822                	sd	s0,16(sp)
    8000272c:	e426                	sd	s1,8(sp)
    8000272e:	1000                	addi	s0,sp,32
    80002730:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002732:	99cff0ef          	jal	800018ce <myproc>
  switch (n) {
    80002736:	4795                	li	a5,5
    80002738:	0497e163          	bltu	a5,s1,8000277a <argraw+0x54>
    8000273c:	048a                	slli	s1,s1,0x2
    8000273e:	00005717          	auipc	a4,0x5
    80002742:	01a70713          	addi	a4,a4,26 # 80007758 <states.0+0x30>
    80002746:	94ba                	add	s1,s1,a4
    80002748:	409c                	lw	a5,0(s1)
    8000274a:	97ba                	add	a5,a5,a4
    8000274c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000274e:	6d3c                	ld	a5,88(a0)
    80002750:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002752:	60e2                	ld	ra,24(sp)
    80002754:	6442                	ld	s0,16(sp)
    80002756:	64a2                	ld	s1,8(sp)
    80002758:	6105                	addi	sp,sp,32
    8000275a:	8082                	ret
    return p->trapframe->a1;
    8000275c:	6d3c                	ld	a5,88(a0)
    8000275e:	7fa8                	ld	a0,120(a5)
    80002760:	bfcd                	j	80002752 <argraw+0x2c>
    return p->trapframe->a2;
    80002762:	6d3c                	ld	a5,88(a0)
    80002764:	63c8                	ld	a0,128(a5)
    80002766:	b7f5                	j	80002752 <argraw+0x2c>
    return p->trapframe->a3;
    80002768:	6d3c                	ld	a5,88(a0)
    8000276a:	67c8                	ld	a0,136(a5)
    8000276c:	b7dd                	j	80002752 <argraw+0x2c>
    return p->trapframe->a4;
    8000276e:	6d3c                	ld	a5,88(a0)
    80002770:	6bc8                	ld	a0,144(a5)
    80002772:	b7c5                	j	80002752 <argraw+0x2c>
    return p->trapframe->a5;
    80002774:	6d3c                	ld	a5,88(a0)
    80002776:	6fc8                	ld	a0,152(a5)
    80002778:	bfe9                	j	80002752 <argraw+0x2c>
  panic("argraw");
    8000277a:	00005517          	auipc	a0,0x5
    8000277e:	bee50513          	addi	a0,a0,-1042 # 80007368 <etext+0x368>
    80002782:	85efe0ef          	jal	800007e0 <panic>

0000000080002786 <fetchaddr>:
{
    80002786:	1101                	addi	sp,sp,-32
    80002788:	ec06                	sd	ra,24(sp)
    8000278a:	e822                	sd	s0,16(sp)
    8000278c:	e426                	sd	s1,8(sp)
    8000278e:	e04a                	sd	s2,0(sp)
    80002790:	1000                	addi	s0,sp,32
    80002792:	84aa                	mv	s1,a0
    80002794:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002796:	938ff0ef          	jal	800018ce <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000279a:	653c                	ld	a5,72(a0)
    8000279c:	02f4f663          	bgeu	s1,a5,800027c8 <fetchaddr+0x42>
    800027a0:	00848713          	addi	a4,s1,8
    800027a4:	02e7e463          	bltu	a5,a4,800027cc <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800027a8:	46a1                	li	a3,8
    800027aa:	8626                	mv	a2,s1
    800027ac:	85ca                	mv	a1,s2
    800027ae:	6928                	ld	a0,80(a0)
    800027b0:	f17fe0ef          	jal	800016c6 <copyin>
    800027b4:	00a03533          	snez	a0,a0
    800027b8:	40a00533          	neg	a0,a0
}
    800027bc:	60e2                	ld	ra,24(sp)
    800027be:	6442                	ld	s0,16(sp)
    800027c0:	64a2                	ld	s1,8(sp)
    800027c2:	6902                	ld	s2,0(sp)
    800027c4:	6105                	addi	sp,sp,32
    800027c6:	8082                	ret
    return -1;
    800027c8:	557d                	li	a0,-1
    800027ca:	bfcd                	j	800027bc <fetchaddr+0x36>
    800027cc:	557d                	li	a0,-1
    800027ce:	b7fd                	j	800027bc <fetchaddr+0x36>

00000000800027d0 <fetchstr>:
{
    800027d0:	7179                	addi	sp,sp,-48
    800027d2:	f406                	sd	ra,40(sp)
    800027d4:	f022                	sd	s0,32(sp)
    800027d6:	ec26                	sd	s1,24(sp)
    800027d8:	e84a                	sd	s2,16(sp)
    800027da:	e44e                	sd	s3,8(sp)
    800027dc:	1800                	addi	s0,sp,48
    800027de:	892a                	mv	s2,a0
    800027e0:	84ae                	mv	s1,a1
    800027e2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800027e4:	8eaff0ef          	jal	800018ce <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800027e8:	86ce                	mv	a3,s3
    800027ea:	864a                	mv	a2,s2
    800027ec:	85a6                	mv	a1,s1
    800027ee:	6928                	ld	a0,80(a0)
    800027f0:	c99fe0ef          	jal	80001488 <copyinstr>
    800027f4:	00054c63          	bltz	a0,8000280c <fetchstr+0x3c>
  return strlen(buf);
    800027f8:	8526                	mv	a0,s1
    800027fa:	e18fe0ef          	jal	80000e12 <strlen>
}
    800027fe:	70a2                	ld	ra,40(sp)
    80002800:	7402                	ld	s0,32(sp)
    80002802:	64e2                	ld	s1,24(sp)
    80002804:	6942                	ld	s2,16(sp)
    80002806:	69a2                	ld	s3,8(sp)
    80002808:	6145                	addi	sp,sp,48
    8000280a:	8082                	ret
    return -1;
    8000280c:	557d                	li	a0,-1
    8000280e:	bfc5                	j	800027fe <fetchstr+0x2e>

0000000080002810 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002810:	1101                	addi	sp,sp,-32
    80002812:	ec06                	sd	ra,24(sp)
    80002814:	e822                	sd	s0,16(sp)
    80002816:	e426                	sd	s1,8(sp)
    80002818:	1000                	addi	s0,sp,32
    8000281a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000281c:	f0bff0ef          	jal	80002726 <argraw>
    80002820:	c088                	sw	a0,0(s1)
}
    80002822:	60e2                	ld	ra,24(sp)
    80002824:	6442                	ld	s0,16(sp)
    80002826:	64a2                	ld	s1,8(sp)
    80002828:	6105                	addi	sp,sp,32
    8000282a:	8082                	ret

000000008000282c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000282c:	1101                	addi	sp,sp,-32
    8000282e:	ec06                	sd	ra,24(sp)
    80002830:	e822                	sd	s0,16(sp)
    80002832:	e426                	sd	s1,8(sp)
    80002834:	1000                	addi	s0,sp,32
    80002836:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002838:	eefff0ef          	jal	80002726 <argraw>
    8000283c:	e088                	sd	a0,0(s1)
}
    8000283e:	60e2                	ld	ra,24(sp)
    80002840:	6442                	ld	s0,16(sp)
    80002842:	64a2                	ld	s1,8(sp)
    80002844:	6105                	addi	sp,sp,32
    80002846:	8082                	ret

0000000080002848 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002848:	7179                	addi	sp,sp,-48
    8000284a:	f406                	sd	ra,40(sp)
    8000284c:	f022                	sd	s0,32(sp)
    8000284e:	ec26                	sd	s1,24(sp)
    80002850:	e84a                	sd	s2,16(sp)
    80002852:	1800                	addi	s0,sp,48
    80002854:	84ae                	mv	s1,a1
    80002856:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002858:	fd840593          	addi	a1,s0,-40
    8000285c:	fd1ff0ef          	jal	8000282c <argaddr>
  return fetchstr(addr, buf, max);
    80002860:	864a                	mv	a2,s2
    80002862:	85a6                	mv	a1,s1
    80002864:	fd843503          	ld	a0,-40(s0)
    80002868:	f69ff0ef          	jal	800027d0 <fetchstr>
}
    8000286c:	70a2                	ld	ra,40(sp)
    8000286e:	7402                	ld	s0,32(sp)
    80002870:	64e2                	ld	s1,24(sp)
    80002872:	6942                	ld	s2,16(sp)
    80002874:	6145                	addi	sp,sp,48
    80002876:	8082                	ret

0000000080002878 <syscall>:
[SYS_setdeadline] sys_setdeadline
};

void
syscall(void)
{
    80002878:	1101                	addi	sp,sp,-32
    8000287a:	ec06                	sd	ra,24(sp)
    8000287c:	e822                	sd	s0,16(sp)
    8000287e:	e426                	sd	s1,8(sp)
    80002880:	e04a                	sd	s2,0(sp)
    80002882:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002884:	84aff0ef          	jal	800018ce <myproc>
    80002888:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000288a:	05853903          	ld	s2,88(a0)
    8000288e:	0a893783          	ld	a5,168(s2)
    80002892:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002896:	37fd                	addiw	a5,a5,-1
    80002898:	4755                	li	a4,21
    8000289a:	00f76f63          	bltu	a4,a5,800028b8 <syscall+0x40>
    8000289e:	00369713          	slli	a4,a3,0x3
    800028a2:	00005797          	auipc	a5,0x5
    800028a6:	ece78793          	addi	a5,a5,-306 # 80007770 <syscalls>
    800028aa:	97ba                	add	a5,a5,a4
    800028ac:	639c                	ld	a5,0(a5)
    800028ae:	c789                	beqz	a5,800028b8 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800028b0:	9782                	jalr	a5
    800028b2:	06a93823          	sd	a0,112(s2)
    800028b6:	a829                	j	800028d0 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800028b8:	15848613          	addi	a2,s1,344
    800028bc:	588c                	lw	a1,48(s1)
    800028be:	00005517          	auipc	a0,0x5
    800028c2:	ab250513          	addi	a0,a0,-1358 # 80007370 <etext+0x370>
    800028c6:	c35fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800028ca:	6cbc                	ld	a5,88(s1)
    800028cc:	577d                	li	a4,-1
    800028ce:	fbb8                	sd	a4,112(a5)
  }
}
    800028d0:	60e2                	ld	ra,24(sp)
    800028d2:	6442                	ld	s0,16(sp)
    800028d4:	64a2                	ld	s1,8(sp)
    800028d6:	6902                	ld	s2,0(sp)
    800028d8:	6105                	addi	sp,sp,32
    800028da:	8082                	ret

00000000800028dc <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800028dc:	1101                	addi	sp,sp,-32
    800028de:	ec06                	sd	ra,24(sp)
    800028e0:	e822                	sd	s0,16(sp)
    800028e2:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800028e4:	fec40593          	addi	a1,s0,-20
    800028e8:	4501                	li	a0,0
    800028ea:	f27ff0ef          	jal	80002810 <argint>
  kexit(n);
    800028ee:	fec42503          	lw	a0,-20(s0)
    800028f2:	f26ff0ef          	jal	80002018 <kexit>
  return 0;  // not reached
}
    800028f6:	4501                	li	a0,0
    800028f8:	60e2                	ld	ra,24(sp)
    800028fa:	6442                	ld	s0,16(sp)
    800028fc:	6105                	addi	sp,sp,32
    800028fe:	8082                	ret

0000000080002900 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002900:	1141                	addi	sp,sp,-16
    80002902:	e406                	sd	ra,8(sp)
    80002904:	e022                	sd	s0,0(sp)
    80002906:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002908:	fc7fe0ef          	jal	800018ce <myproc>
}
    8000290c:	5908                	lw	a0,48(a0)
    8000290e:	60a2                	ld	ra,8(sp)
    80002910:	6402                	ld	s0,0(sp)
    80002912:	0141                	addi	sp,sp,16
    80002914:	8082                	ret

0000000080002916 <sys_fork>:

uint64
sys_fork(void)
{
    80002916:	1141                	addi	sp,sp,-16
    80002918:	e406                	sd	ra,8(sp)
    8000291a:	e022                	sd	s0,0(sp)
    8000291c:	0800                	addi	s0,sp,16
  return kfork();
    8000291e:	b28ff0ef          	jal	80001c46 <kfork>
}
    80002922:	60a2                	ld	ra,8(sp)
    80002924:	6402                	ld	s0,0(sp)
    80002926:	0141                	addi	sp,sp,16
    80002928:	8082                	ret

000000008000292a <sys_wait>:

uint64
sys_wait(void)
{
    8000292a:	1101                	addi	sp,sp,-32
    8000292c:	ec06                	sd	ra,24(sp)
    8000292e:	e822                	sd	s0,16(sp)
    80002930:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002932:	fe840593          	addi	a1,s0,-24
    80002936:	4501                	li	a0,0
    80002938:	ef5ff0ef          	jal	8000282c <argaddr>
  return kwait(p);
    8000293c:	fe843503          	ld	a0,-24(s0)
    80002940:	82fff0ef          	jal	8000216e <kwait>
}
    80002944:	60e2                	ld	ra,24(sp)
    80002946:	6442                	ld	s0,16(sp)
    80002948:	6105                	addi	sp,sp,32
    8000294a:	8082                	ret

000000008000294c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000294c:	7179                	addi	sp,sp,-48
    8000294e:	f406                	sd	ra,40(sp)
    80002950:	f022                	sd	s0,32(sp)
    80002952:	ec26                	sd	s1,24(sp)
    80002954:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002956:	fd840593          	addi	a1,s0,-40
    8000295a:	4501                	li	a0,0
    8000295c:	eb5ff0ef          	jal	80002810 <argint>
  argint(1, &t);
    80002960:	fdc40593          	addi	a1,s0,-36
    80002964:	4505                	li	a0,1
    80002966:	eabff0ef          	jal	80002810 <argint>
  addr = myproc()->sz;
    8000296a:	f65fe0ef          	jal	800018ce <myproc>
    8000296e:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002970:	fdc42703          	lw	a4,-36(s0)
    80002974:	4785                	li	a5,1
    80002976:	02f70763          	beq	a4,a5,800029a4 <sys_sbrk+0x58>
    8000297a:	fd842783          	lw	a5,-40(s0)
    8000297e:	0207c363          	bltz	a5,800029a4 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002982:	97a6                	add	a5,a5,s1
    80002984:	0297ee63          	bltu	a5,s1,800029c0 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002988:	02000737          	lui	a4,0x2000
    8000298c:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    8000298e:	0736                	slli	a4,a4,0xd
    80002990:	02f76a63          	bltu	a4,a5,800029c4 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002994:	f3bfe0ef          	jal	800018ce <myproc>
    80002998:	fd842703          	lw	a4,-40(s0)
    8000299c:	653c                	ld	a5,72(a0)
    8000299e:	97ba                	add	a5,a5,a4
    800029a0:	e53c                	sd	a5,72(a0)
    800029a2:	a039                	j	800029b0 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    800029a4:	fd842503          	lw	a0,-40(s0)
    800029a8:	a3cff0ef          	jal	80001be4 <growproc>
    800029ac:	00054863          	bltz	a0,800029bc <sys_sbrk+0x70>
  }
  return addr;
}
    800029b0:	8526                	mv	a0,s1
    800029b2:	70a2                	ld	ra,40(sp)
    800029b4:	7402                	ld	s0,32(sp)
    800029b6:	64e2                	ld	s1,24(sp)
    800029b8:	6145                	addi	sp,sp,48
    800029ba:	8082                	ret
      return -1;
    800029bc:	54fd                	li	s1,-1
    800029be:	bfcd                	j	800029b0 <sys_sbrk+0x64>
      return -1;
    800029c0:	54fd                	li	s1,-1
    800029c2:	b7fd                	j	800029b0 <sys_sbrk+0x64>
      return -1;
    800029c4:	54fd                	li	s1,-1
    800029c6:	b7ed                	j	800029b0 <sys_sbrk+0x64>

00000000800029c8 <sys_pause>:

uint64
sys_pause(void)
{
    800029c8:	7139                	addi	sp,sp,-64
    800029ca:	fc06                	sd	ra,56(sp)
    800029cc:	f822                	sd	s0,48(sp)
    800029ce:	f04a                	sd	s2,32(sp)
    800029d0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800029d2:	fcc40593          	addi	a1,s0,-52
    800029d6:	4501                	li	a0,0
    800029d8:	e39ff0ef          	jal	80002810 <argint>
  if(n < 0)
    800029dc:	fcc42783          	lw	a5,-52(s0)
    800029e0:	0607c763          	bltz	a5,80002a4e <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    800029e4:	00013517          	auipc	a0,0x13
    800029e8:	fb450513          	addi	a0,a0,-76 # 80015998 <tickslock>
    800029ec:	9e2fe0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    800029f0:	00005917          	auipc	s2,0x5
    800029f4:	e7892903          	lw	s2,-392(s2) # 80007868 <ticks>
  while(ticks - ticks0 < n){
    800029f8:	fcc42783          	lw	a5,-52(s0)
    800029fc:	cf8d                	beqz	a5,80002a36 <sys_pause+0x6e>
    800029fe:	f426                	sd	s1,40(sp)
    80002a00:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a02:	00013997          	auipc	s3,0x13
    80002a06:	f9698993          	addi	s3,s3,-106 # 80015998 <tickslock>
    80002a0a:	00005497          	auipc	s1,0x5
    80002a0e:	e5e48493          	addi	s1,s1,-418 # 80007868 <ticks>
    if(killed(myproc())){
    80002a12:	ebdfe0ef          	jal	800018ce <myproc>
    80002a16:	f2eff0ef          	jal	80002144 <killed>
    80002a1a:	ed0d                	bnez	a0,80002a54 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002a1c:	85ce                	mv	a1,s3
    80002a1e:	8526                	mv	a0,s1
    80002a20:	cecff0ef          	jal	80001f0c <sleep>
  while(ticks - ticks0 < n){
    80002a24:	409c                	lw	a5,0(s1)
    80002a26:	412787bb          	subw	a5,a5,s2
    80002a2a:	fcc42703          	lw	a4,-52(s0)
    80002a2e:	fee7e2e3          	bltu	a5,a4,80002a12 <sys_pause+0x4a>
    80002a32:	74a2                	ld	s1,40(sp)
    80002a34:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a36:	00013517          	auipc	a0,0x13
    80002a3a:	f6250513          	addi	a0,a0,-158 # 80015998 <tickslock>
    80002a3e:	a28fe0ef          	jal	80000c66 <release>
  return 0;
    80002a42:	4501                	li	a0,0
}
    80002a44:	70e2                	ld	ra,56(sp)
    80002a46:	7442                	ld	s0,48(sp)
    80002a48:	7902                	ld	s2,32(sp)
    80002a4a:	6121                	addi	sp,sp,64
    80002a4c:	8082                	ret
    n = 0;
    80002a4e:	fc042623          	sw	zero,-52(s0)
    80002a52:	bf49                	j	800029e4 <sys_pause+0x1c>
      release(&tickslock);
    80002a54:	00013517          	auipc	a0,0x13
    80002a58:	f4450513          	addi	a0,a0,-188 # 80015998 <tickslock>
    80002a5c:	a0afe0ef          	jal	80000c66 <release>
      return -1;
    80002a60:	557d                	li	a0,-1
    80002a62:	74a2                	ld	s1,40(sp)
    80002a64:	69e2                	ld	s3,24(sp)
    80002a66:	bff9                	j	80002a44 <sys_pause+0x7c>

0000000080002a68 <sys_kill>:

uint64
sys_kill(void)
{
    80002a68:	1101                	addi	sp,sp,-32
    80002a6a:	ec06                	sd	ra,24(sp)
    80002a6c:	e822                	sd	s0,16(sp)
    80002a6e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a70:	fec40593          	addi	a1,s0,-20
    80002a74:	4501                	li	a0,0
    80002a76:	d9bff0ef          	jal	80002810 <argint>
  return kkill(pid);
    80002a7a:	fec42503          	lw	a0,-20(s0)
    80002a7e:	e3cff0ef          	jal	800020ba <kkill>
}
    80002a82:	60e2                	ld	ra,24(sp)
    80002a84:	6442                	ld	s0,16(sp)
    80002a86:	6105                	addi	sp,sp,32
    80002a88:	8082                	ret

0000000080002a8a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a8a:	1101                	addi	sp,sp,-32
    80002a8c:	ec06                	sd	ra,24(sp)
    80002a8e:	e822                	sd	s0,16(sp)
    80002a90:	e426                	sd	s1,8(sp)
    80002a92:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a94:	00013517          	auipc	a0,0x13
    80002a98:	f0450513          	addi	a0,a0,-252 # 80015998 <tickslock>
    80002a9c:	932fe0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80002aa0:	00005497          	auipc	s1,0x5
    80002aa4:	dc84a483          	lw	s1,-568(s1) # 80007868 <ticks>
  release(&tickslock);
    80002aa8:	00013517          	auipc	a0,0x13
    80002aac:	ef050513          	addi	a0,a0,-272 # 80015998 <tickslock>
    80002ab0:	9b6fe0ef          	jal	80000c66 <release>
  return xticks;
}
    80002ab4:	02049513          	slli	a0,s1,0x20
    80002ab8:	9101                	srli	a0,a0,0x20
    80002aba:	60e2                	ld	ra,24(sp)
    80002abc:	6442                	ld	s0,16(sp)
    80002abe:	64a2                	ld	s1,8(sp)
    80002ac0:	6105                	addi	sp,sp,32
    80002ac2:	8082                	ret

0000000080002ac4 <sys_setdeadline>:
uint64
sys_setdeadline(void)
{
    80002ac4:	1101                	addi	sp,sp,-32
    80002ac6:	ec06                	sd	ra,24(sp)
    80002ac8:	e822                	sd	s0,16(sp)
    80002aca:	1000                	addi	s0,sp,32
  int deadline;
  argint(0, &deadline);
    80002acc:	fec40593          	addi	a1,s0,-20
    80002ad0:	4501                	li	a0,0
    80002ad2:	d3fff0ef          	jal	80002810 <argint>
  myproc()->deadline = deadline;
    80002ad6:	df9fe0ef          	jal	800018ce <myproc>
    80002ada:	fec42783          	lw	a5,-20(s0)
    80002ade:	16f52423          	sw	a5,360(a0)
  return 0;
}
    80002ae2:	4501                	li	a0,0
    80002ae4:	60e2                	ld	ra,24(sp)
    80002ae6:	6442                	ld	s0,16(sp)
    80002ae8:	6105                	addi	sp,sp,32
    80002aea:	8082                	ret

0000000080002aec <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002aec:	7179                	addi	sp,sp,-48
    80002aee:	f406                	sd	ra,40(sp)
    80002af0:	f022                	sd	s0,32(sp)
    80002af2:	ec26                	sd	s1,24(sp)
    80002af4:	e84a                	sd	s2,16(sp)
    80002af6:	e44e                	sd	s3,8(sp)
    80002af8:	e052                	sd	s4,0(sp)
    80002afa:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002afc:	00005597          	auipc	a1,0x5
    80002b00:	89458593          	addi	a1,a1,-1900 # 80007390 <etext+0x390>
    80002b04:	00013517          	auipc	a0,0x13
    80002b08:	eac50513          	addi	a0,a0,-340 # 800159b0 <bcache>
    80002b0c:	842fe0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b10:	0001b797          	auipc	a5,0x1b
    80002b14:	ea078793          	addi	a5,a5,-352 # 8001d9b0 <bcache+0x8000>
    80002b18:	0001b717          	auipc	a4,0x1b
    80002b1c:	10070713          	addi	a4,a4,256 # 8001dc18 <bcache+0x8268>
    80002b20:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b24:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b28:	00013497          	auipc	s1,0x13
    80002b2c:	ea048493          	addi	s1,s1,-352 # 800159c8 <bcache+0x18>
    b->next = bcache.head.next;
    80002b30:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b32:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b34:	00005a17          	auipc	s4,0x5
    80002b38:	864a0a13          	addi	s4,s4,-1948 # 80007398 <etext+0x398>
    b->next = bcache.head.next;
    80002b3c:	2b893783          	ld	a5,696(s2)
    80002b40:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b42:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b46:	85d2                	mv	a1,s4
    80002b48:	01048513          	addi	a0,s1,16
    80002b4c:	322010ef          	jal	80003e6e <initsleeplock>
    bcache.head.next->prev = b;
    80002b50:	2b893783          	ld	a5,696(s2)
    80002b54:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b56:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b5a:	45848493          	addi	s1,s1,1112
    80002b5e:	fd349fe3          	bne	s1,s3,80002b3c <binit+0x50>
  }
}
    80002b62:	70a2                	ld	ra,40(sp)
    80002b64:	7402                	ld	s0,32(sp)
    80002b66:	64e2                	ld	s1,24(sp)
    80002b68:	6942                	ld	s2,16(sp)
    80002b6a:	69a2                	ld	s3,8(sp)
    80002b6c:	6a02                	ld	s4,0(sp)
    80002b6e:	6145                	addi	sp,sp,48
    80002b70:	8082                	ret

0000000080002b72 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002b72:	7179                	addi	sp,sp,-48
    80002b74:	f406                	sd	ra,40(sp)
    80002b76:	f022                	sd	s0,32(sp)
    80002b78:	ec26                	sd	s1,24(sp)
    80002b7a:	e84a                	sd	s2,16(sp)
    80002b7c:	e44e                	sd	s3,8(sp)
    80002b7e:	1800                	addi	s0,sp,48
    80002b80:	892a                	mv	s2,a0
    80002b82:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002b84:	00013517          	auipc	a0,0x13
    80002b88:	e2c50513          	addi	a0,a0,-468 # 800159b0 <bcache>
    80002b8c:	842fe0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002b90:	0001b497          	auipc	s1,0x1b
    80002b94:	0d84b483          	ld	s1,216(s1) # 8001dc68 <bcache+0x82b8>
    80002b98:	0001b797          	auipc	a5,0x1b
    80002b9c:	08078793          	addi	a5,a5,128 # 8001dc18 <bcache+0x8268>
    80002ba0:	02f48b63          	beq	s1,a5,80002bd6 <bread+0x64>
    80002ba4:	873e                	mv	a4,a5
    80002ba6:	a021                	j	80002bae <bread+0x3c>
    80002ba8:	68a4                	ld	s1,80(s1)
    80002baa:	02e48663          	beq	s1,a4,80002bd6 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002bae:	449c                	lw	a5,8(s1)
    80002bb0:	ff279ce3          	bne	a5,s2,80002ba8 <bread+0x36>
    80002bb4:	44dc                	lw	a5,12(s1)
    80002bb6:	ff3799e3          	bne	a5,s3,80002ba8 <bread+0x36>
      b->refcnt++;
    80002bba:	40bc                	lw	a5,64(s1)
    80002bbc:	2785                	addiw	a5,a5,1
    80002bbe:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002bc0:	00013517          	auipc	a0,0x13
    80002bc4:	df050513          	addi	a0,a0,-528 # 800159b0 <bcache>
    80002bc8:	89efe0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002bcc:	01048513          	addi	a0,s1,16
    80002bd0:	2d4010ef          	jal	80003ea4 <acquiresleep>
      return b;
    80002bd4:	a889                	j	80002c26 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002bd6:	0001b497          	auipc	s1,0x1b
    80002bda:	08a4b483          	ld	s1,138(s1) # 8001dc60 <bcache+0x82b0>
    80002bde:	0001b797          	auipc	a5,0x1b
    80002be2:	03a78793          	addi	a5,a5,58 # 8001dc18 <bcache+0x8268>
    80002be6:	00f48863          	beq	s1,a5,80002bf6 <bread+0x84>
    80002bea:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002bec:	40bc                	lw	a5,64(s1)
    80002bee:	cb91                	beqz	a5,80002c02 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002bf0:	64a4                	ld	s1,72(s1)
    80002bf2:	fee49de3          	bne	s1,a4,80002bec <bread+0x7a>
  panic("bget: no buffers");
    80002bf6:	00004517          	auipc	a0,0x4
    80002bfa:	7aa50513          	addi	a0,a0,1962 # 800073a0 <etext+0x3a0>
    80002bfe:	be3fd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80002c02:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c06:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c0a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c0e:	4785                	li	a5,1
    80002c10:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c12:	00013517          	auipc	a0,0x13
    80002c16:	d9e50513          	addi	a0,a0,-610 # 800159b0 <bcache>
    80002c1a:	84cfe0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002c1e:	01048513          	addi	a0,s1,16
    80002c22:	282010ef          	jal	80003ea4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002c26:	409c                	lw	a5,0(s1)
    80002c28:	cb89                	beqz	a5,80002c3a <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c2a:	8526                	mv	a0,s1
    80002c2c:	70a2                	ld	ra,40(sp)
    80002c2e:	7402                	ld	s0,32(sp)
    80002c30:	64e2                	ld	s1,24(sp)
    80002c32:	6942                	ld	s2,16(sp)
    80002c34:	69a2                	ld	s3,8(sp)
    80002c36:	6145                	addi	sp,sp,48
    80002c38:	8082                	ret
    virtio_disk_rw(b, 0);
    80002c3a:	4581                	li	a1,0
    80002c3c:	8526                	mv	a0,s1
    80002c3e:	2d3020ef          	jal	80005710 <virtio_disk_rw>
    b->valid = 1;
    80002c42:	4785                	li	a5,1
    80002c44:	c09c                	sw	a5,0(s1)
  return b;
    80002c46:	b7d5                	j	80002c2a <bread+0xb8>

0000000080002c48 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002c48:	1101                	addi	sp,sp,-32
    80002c4a:	ec06                	sd	ra,24(sp)
    80002c4c:	e822                	sd	s0,16(sp)
    80002c4e:	e426                	sd	s1,8(sp)
    80002c50:	1000                	addi	s0,sp,32
    80002c52:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c54:	0541                	addi	a0,a0,16
    80002c56:	2cc010ef          	jal	80003f22 <holdingsleep>
    80002c5a:	c911                	beqz	a0,80002c6e <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002c5c:	4585                	li	a1,1
    80002c5e:	8526                	mv	a0,s1
    80002c60:	2b1020ef          	jal	80005710 <virtio_disk_rw>
}
    80002c64:	60e2                	ld	ra,24(sp)
    80002c66:	6442                	ld	s0,16(sp)
    80002c68:	64a2                	ld	s1,8(sp)
    80002c6a:	6105                	addi	sp,sp,32
    80002c6c:	8082                	ret
    panic("bwrite");
    80002c6e:	00004517          	auipc	a0,0x4
    80002c72:	74a50513          	addi	a0,a0,1866 # 800073b8 <etext+0x3b8>
    80002c76:	b6bfd0ef          	jal	800007e0 <panic>

0000000080002c7a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002c7a:	1101                	addi	sp,sp,-32
    80002c7c:	ec06                	sd	ra,24(sp)
    80002c7e:	e822                	sd	s0,16(sp)
    80002c80:	e426                	sd	s1,8(sp)
    80002c82:	e04a                	sd	s2,0(sp)
    80002c84:	1000                	addi	s0,sp,32
    80002c86:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c88:	01050913          	addi	s2,a0,16
    80002c8c:	854a                	mv	a0,s2
    80002c8e:	294010ef          	jal	80003f22 <holdingsleep>
    80002c92:	c135                	beqz	a0,80002cf6 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002c94:	854a                	mv	a0,s2
    80002c96:	254010ef          	jal	80003eea <releasesleep>

  acquire(&bcache.lock);
    80002c9a:	00013517          	auipc	a0,0x13
    80002c9e:	d1650513          	addi	a0,a0,-746 # 800159b0 <bcache>
    80002ca2:	f2dfd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002ca6:	40bc                	lw	a5,64(s1)
    80002ca8:	37fd                	addiw	a5,a5,-1
    80002caa:	0007871b          	sext.w	a4,a5
    80002cae:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002cb0:	e71d                	bnez	a4,80002cde <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002cb2:	68b8                	ld	a4,80(s1)
    80002cb4:	64bc                	ld	a5,72(s1)
    80002cb6:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002cb8:	68b8                	ld	a4,80(s1)
    80002cba:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002cbc:	0001b797          	auipc	a5,0x1b
    80002cc0:	cf478793          	addi	a5,a5,-780 # 8001d9b0 <bcache+0x8000>
    80002cc4:	2b87b703          	ld	a4,696(a5)
    80002cc8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002cca:	0001b717          	auipc	a4,0x1b
    80002cce:	f4e70713          	addi	a4,a4,-178 # 8001dc18 <bcache+0x8268>
    80002cd2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002cd4:	2b87b703          	ld	a4,696(a5)
    80002cd8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002cda:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002cde:	00013517          	auipc	a0,0x13
    80002ce2:	cd250513          	addi	a0,a0,-814 # 800159b0 <bcache>
    80002ce6:	f81fd0ef          	jal	80000c66 <release>
}
    80002cea:	60e2                	ld	ra,24(sp)
    80002cec:	6442                	ld	s0,16(sp)
    80002cee:	64a2                	ld	s1,8(sp)
    80002cf0:	6902                	ld	s2,0(sp)
    80002cf2:	6105                	addi	sp,sp,32
    80002cf4:	8082                	ret
    panic("brelse");
    80002cf6:	00004517          	auipc	a0,0x4
    80002cfa:	6ca50513          	addi	a0,a0,1738 # 800073c0 <etext+0x3c0>
    80002cfe:	ae3fd0ef          	jal	800007e0 <panic>

0000000080002d02 <bpin>:

void
bpin(struct buf *b) {
    80002d02:	1101                	addi	sp,sp,-32
    80002d04:	ec06                	sd	ra,24(sp)
    80002d06:	e822                	sd	s0,16(sp)
    80002d08:	e426                	sd	s1,8(sp)
    80002d0a:	1000                	addi	s0,sp,32
    80002d0c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d0e:	00013517          	auipc	a0,0x13
    80002d12:	ca250513          	addi	a0,a0,-862 # 800159b0 <bcache>
    80002d16:	eb9fd0ef          	jal	80000bce <acquire>
  b->refcnt++;
    80002d1a:	40bc                	lw	a5,64(s1)
    80002d1c:	2785                	addiw	a5,a5,1
    80002d1e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d20:	00013517          	auipc	a0,0x13
    80002d24:	c9050513          	addi	a0,a0,-880 # 800159b0 <bcache>
    80002d28:	f3ffd0ef          	jal	80000c66 <release>
}
    80002d2c:	60e2                	ld	ra,24(sp)
    80002d2e:	6442                	ld	s0,16(sp)
    80002d30:	64a2                	ld	s1,8(sp)
    80002d32:	6105                	addi	sp,sp,32
    80002d34:	8082                	ret

0000000080002d36 <bunpin>:

void
bunpin(struct buf *b) {
    80002d36:	1101                	addi	sp,sp,-32
    80002d38:	ec06                	sd	ra,24(sp)
    80002d3a:	e822                	sd	s0,16(sp)
    80002d3c:	e426                	sd	s1,8(sp)
    80002d3e:	1000                	addi	s0,sp,32
    80002d40:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d42:	00013517          	auipc	a0,0x13
    80002d46:	c6e50513          	addi	a0,a0,-914 # 800159b0 <bcache>
    80002d4a:	e85fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002d4e:	40bc                	lw	a5,64(s1)
    80002d50:	37fd                	addiw	a5,a5,-1
    80002d52:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d54:	00013517          	auipc	a0,0x13
    80002d58:	c5c50513          	addi	a0,a0,-932 # 800159b0 <bcache>
    80002d5c:	f0bfd0ef          	jal	80000c66 <release>
}
    80002d60:	60e2                	ld	ra,24(sp)
    80002d62:	6442                	ld	s0,16(sp)
    80002d64:	64a2                	ld	s1,8(sp)
    80002d66:	6105                	addi	sp,sp,32
    80002d68:	8082                	ret

0000000080002d6a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002d6a:	1101                	addi	sp,sp,-32
    80002d6c:	ec06                	sd	ra,24(sp)
    80002d6e:	e822                	sd	s0,16(sp)
    80002d70:	e426                	sd	s1,8(sp)
    80002d72:	e04a                	sd	s2,0(sp)
    80002d74:	1000                	addi	s0,sp,32
    80002d76:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002d78:	00d5d59b          	srliw	a1,a1,0xd
    80002d7c:	0001b797          	auipc	a5,0x1b
    80002d80:	3107a783          	lw	a5,784(a5) # 8001e08c <sb+0x1c>
    80002d84:	9dbd                	addw	a1,a1,a5
    80002d86:	dedff0ef          	jal	80002b72 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002d8a:	0074f713          	andi	a4,s1,7
    80002d8e:	4785                	li	a5,1
    80002d90:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002d94:	14ce                	slli	s1,s1,0x33
    80002d96:	90d9                	srli	s1,s1,0x36
    80002d98:	00950733          	add	a4,a0,s1
    80002d9c:	05874703          	lbu	a4,88(a4)
    80002da0:	00e7f6b3          	and	a3,a5,a4
    80002da4:	c29d                	beqz	a3,80002dca <bfree+0x60>
    80002da6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002da8:	94aa                	add	s1,s1,a0
    80002daa:	fff7c793          	not	a5,a5
    80002dae:	8f7d                	and	a4,a4,a5
    80002db0:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002db4:	7f9000ef          	jal	80003dac <log_write>
  brelse(bp);
    80002db8:	854a                	mv	a0,s2
    80002dba:	ec1ff0ef          	jal	80002c7a <brelse>
}
    80002dbe:	60e2                	ld	ra,24(sp)
    80002dc0:	6442                	ld	s0,16(sp)
    80002dc2:	64a2                	ld	s1,8(sp)
    80002dc4:	6902                	ld	s2,0(sp)
    80002dc6:	6105                	addi	sp,sp,32
    80002dc8:	8082                	ret
    panic("freeing free block");
    80002dca:	00004517          	auipc	a0,0x4
    80002dce:	5fe50513          	addi	a0,a0,1534 # 800073c8 <etext+0x3c8>
    80002dd2:	a0ffd0ef          	jal	800007e0 <panic>

0000000080002dd6 <balloc>:
{
    80002dd6:	711d                	addi	sp,sp,-96
    80002dd8:	ec86                	sd	ra,88(sp)
    80002dda:	e8a2                	sd	s0,80(sp)
    80002ddc:	e4a6                	sd	s1,72(sp)
    80002dde:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002de0:	0001b797          	auipc	a5,0x1b
    80002de4:	2947a783          	lw	a5,660(a5) # 8001e074 <sb+0x4>
    80002de8:	0e078f63          	beqz	a5,80002ee6 <balloc+0x110>
    80002dec:	e0ca                	sd	s2,64(sp)
    80002dee:	fc4e                	sd	s3,56(sp)
    80002df0:	f852                	sd	s4,48(sp)
    80002df2:	f456                	sd	s5,40(sp)
    80002df4:	f05a                	sd	s6,32(sp)
    80002df6:	ec5e                	sd	s7,24(sp)
    80002df8:	e862                	sd	s8,16(sp)
    80002dfa:	e466                	sd	s9,8(sp)
    80002dfc:	8baa                	mv	s7,a0
    80002dfe:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e00:	0001bb17          	auipc	s6,0x1b
    80002e04:	270b0b13          	addi	s6,s6,624 # 8001e070 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e08:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002e0a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e0c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002e0e:	6c89                	lui	s9,0x2
    80002e10:	a0b5                	j	80002e7c <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002e12:	97ca                	add	a5,a5,s2
    80002e14:	8e55                	or	a2,a2,a3
    80002e16:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e1a:	854a                	mv	a0,s2
    80002e1c:	791000ef          	jal	80003dac <log_write>
        brelse(bp);
    80002e20:	854a                	mv	a0,s2
    80002e22:	e59ff0ef          	jal	80002c7a <brelse>
  bp = bread(dev, bno);
    80002e26:	85a6                	mv	a1,s1
    80002e28:	855e                	mv	a0,s7
    80002e2a:	d49ff0ef          	jal	80002b72 <bread>
    80002e2e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002e30:	40000613          	li	a2,1024
    80002e34:	4581                	li	a1,0
    80002e36:	05850513          	addi	a0,a0,88
    80002e3a:	e69fd0ef          	jal	80000ca2 <memset>
  log_write(bp);
    80002e3e:	854a                	mv	a0,s2
    80002e40:	76d000ef          	jal	80003dac <log_write>
  brelse(bp);
    80002e44:	854a                	mv	a0,s2
    80002e46:	e35ff0ef          	jal	80002c7a <brelse>
}
    80002e4a:	6906                	ld	s2,64(sp)
    80002e4c:	79e2                	ld	s3,56(sp)
    80002e4e:	7a42                	ld	s4,48(sp)
    80002e50:	7aa2                	ld	s5,40(sp)
    80002e52:	7b02                	ld	s6,32(sp)
    80002e54:	6be2                	ld	s7,24(sp)
    80002e56:	6c42                	ld	s8,16(sp)
    80002e58:	6ca2                	ld	s9,8(sp)
}
    80002e5a:	8526                	mv	a0,s1
    80002e5c:	60e6                	ld	ra,88(sp)
    80002e5e:	6446                	ld	s0,80(sp)
    80002e60:	64a6                	ld	s1,72(sp)
    80002e62:	6125                	addi	sp,sp,96
    80002e64:	8082                	ret
    brelse(bp);
    80002e66:	854a                	mv	a0,s2
    80002e68:	e13ff0ef          	jal	80002c7a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002e6c:	015c87bb          	addw	a5,s9,s5
    80002e70:	00078a9b          	sext.w	s5,a5
    80002e74:	004b2703          	lw	a4,4(s6)
    80002e78:	04eaff63          	bgeu	s5,a4,80002ed6 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002e7c:	41fad79b          	sraiw	a5,s5,0x1f
    80002e80:	0137d79b          	srliw	a5,a5,0x13
    80002e84:	015787bb          	addw	a5,a5,s5
    80002e88:	40d7d79b          	sraiw	a5,a5,0xd
    80002e8c:	01cb2583          	lw	a1,28(s6)
    80002e90:	9dbd                	addw	a1,a1,a5
    80002e92:	855e                	mv	a0,s7
    80002e94:	cdfff0ef          	jal	80002b72 <bread>
    80002e98:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e9a:	004b2503          	lw	a0,4(s6)
    80002e9e:	000a849b          	sext.w	s1,s5
    80002ea2:	8762                	mv	a4,s8
    80002ea4:	fca4f1e3          	bgeu	s1,a0,80002e66 <balloc+0x90>
      m = 1 << (bi % 8);
    80002ea8:	00777693          	andi	a3,a4,7
    80002eac:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002eb0:	41f7579b          	sraiw	a5,a4,0x1f
    80002eb4:	01d7d79b          	srliw	a5,a5,0x1d
    80002eb8:	9fb9                	addw	a5,a5,a4
    80002eba:	4037d79b          	sraiw	a5,a5,0x3
    80002ebe:	00f90633          	add	a2,s2,a5
    80002ec2:	05864603          	lbu	a2,88(a2)
    80002ec6:	00c6f5b3          	and	a1,a3,a2
    80002eca:	d5a1                	beqz	a1,80002e12 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ecc:	2705                	addiw	a4,a4,1
    80002ece:	2485                	addiw	s1,s1,1
    80002ed0:	fd471ae3          	bne	a4,s4,80002ea4 <balloc+0xce>
    80002ed4:	bf49                	j	80002e66 <balloc+0x90>
    80002ed6:	6906                	ld	s2,64(sp)
    80002ed8:	79e2                	ld	s3,56(sp)
    80002eda:	7a42                	ld	s4,48(sp)
    80002edc:	7aa2                	ld	s5,40(sp)
    80002ede:	7b02                	ld	s6,32(sp)
    80002ee0:	6be2                	ld	s7,24(sp)
    80002ee2:	6c42                	ld	s8,16(sp)
    80002ee4:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002ee6:	00004517          	auipc	a0,0x4
    80002eea:	4fa50513          	addi	a0,a0,1274 # 800073e0 <etext+0x3e0>
    80002eee:	e0cfd0ef          	jal	800004fa <printf>
  return 0;
    80002ef2:	4481                	li	s1,0
    80002ef4:	b79d                	j	80002e5a <balloc+0x84>

0000000080002ef6 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002ef6:	7179                	addi	sp,sp,-48
    80002ef8:	f406                	sd	ra,40(sp)
    80002efa:	f022                	sd	s0,32(sp)
    80002efc:	ec26                	sd	s1,24(sp)
    80002efe:	e84a                	sd	s2,16(sp)
    80002f00:	e44e                	sd	s3,8(sp)
    80002f02:	1800                	addi	s0,sp,48
    80002f04:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002f06:	47ad                	li	a5,11
    80002f08:	02b7e663          	bltu	a5,a1,80002f34 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002f0c:	02059793          	slli	a5,a1,0x20
    80002f10:	01e7d593          	srli	a1,a5,0x1e
    80002f14:	00b504b3          	add	s1,a0,a1
    80002f18:	0504a903          	lw	s2,80(s1)
    80002f1c:	06091a63          	bnez	s2,80002f90 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002f20:	4108                	lw	a0,0(a0)
    80002f22:	eb5ff0ef          	jal	80002dd6 <balloc>
    80002f26:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002f2a:	06090363          	beqz	s2,80002f90 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002f2e:	0524a823          	sw	s2,80(s1)
    80002f32:	a8b9                	j	80002f90 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f34:	ff45849b          	addiw	s1,a1,-12
    80002f38:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002f3c:	0ff00793          	li	a5,255
    80002f40:	06e7ee63          	bltu	a5,a4,80002fbc <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002f44:	08052903          	lw	s2,128(a0)
    80002f48:	00091d63          	bnez	s2,80002f62 <bmap+0x6c>
      addr = balloc(ip->dev);
    80002f4c:	4108                	lw	a0,0(a0)
    80002f4e:	e89ff0ef          	jal	80002dd6 <balloc>
    80002f52:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002f56:	02090d63          	beqz	s2,80002f90 <bmap+0x9a>
    80002f5a:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002f5c:	0929a023          	sw	s2,128(s3)
    80002f60:	a011                	j	80002f64 <bmap+0x6e>
    80002f62:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f64:	85ca                	mv	a1,s2
    80002f66:	0009a503          	lw	a0,0(s3)
    80002f6a:	c09ff0ef          	jal	80002b72 <bread>
    80002f6e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002f70:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002f74:	02049713          	slli	a4,s1,0x20
    80002f78:	01e75593          	srli	a1,a4,0x1e
    80002f7c:	00b784b3          	add	s1,a5,a1
    80002f80:	0004a903          	lw	s2,0(s1)
    80002f84:	00090e63          	beqz	s2,80002fa0 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002f88:	8552                	mv	a0,s4
    80002f8a:	cf1ff0ef          	jal	80002c7a <brelse>
    return addr;
    80002f8e:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002f90:	854a                	mv	a0,s2
    80002f92:	70a2                	ld	ra,40(sp)
    80002f94:	7402                	ld	s0,32(sp)
    80002f96:	64e2                	ld	s1,24(sp)
    80002f98:	6942                	ld	s2,16(sp)
    80002f9a:	69a2                	ld	s3,8(sp)
    80002f9c:	6145                	addi	sp,sp,48
    80002f9e:	8082                	ret
      addr = balloc(ip->dev);
    80002fa0:	0009a503          	lw	a0,0(s3)
    80002fa4:	e33ff0ef          	jal	80002dd6 <balloc>
    80002fa8:	0005091b          	sext.w	s2,a0
      if(addr){
    80002fac:	fc090ee3          	beqz	s2,80002f88 <bmap+0x92>
        a[bn] = addr;
    80002fb0:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002fb4:	8552                	mv	a0,s4
    80002fb6:	5f7000ef          	jal	80003dac <log_write>
    80002fba:	b7f9                	j	80002f88 <bmap+0x92>
    80002fbc:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002fbe:	00004517          	auipc	a0,0x4
    80002fc2:	43a50513          	addi	a0,a0,1082 # 800073f8 <etext+0x3f8>
    80002fc6:	81bfd0ef          	jal	800007e0 <panic>

0000000080002fca <iget>:
{
    80002fca:	7179                	addi	sp,sp,-48
    80002fcc:	f406                	sd	ra,40(sp)
    80002fce:	f022                	sd	s0,32(sp)
    80002fd0:	ec26                	sd	s1,24(sp)
    80002fd2:	e84a                	sd	s2,16(sp)
    80002fd4:	e44e                	sd	s3,8(sp)
    80002fd6:	e052                	sd	s4,0(sp)
    80002fd8:	1800                	addi	s0,sp,48
    80002fda:	89aa                	mv	s3,a0
    80002fdc:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002fde:	0001b517          	auipc	a0,0x1b
    80002fe2:	0b250513          	addi	a0,a0,178 # 8001e090 <itable>
    80002fe6:	be9fd0ef          	jal	80000bce <acquire>
  empty = 0;
    80002fea:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002fec:	0001b497          	auipc	s1,0x1b
    80002ff0:	0bc48493          	addi	s1,s1,188 # 8001e0a8 <itable+0x18>
    80002ff4:	0001d697          	auipc	a3,0x1d
    80002ff8:	b4468693          	addi	a3,a3,-1212 # 8001fb38 <log>
    80002ffc:	a039                	j	8000300a <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002ffe:	02090963          	beqz	s2,80003030 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003002:	08848493          	addi	s1,s1,136
    80003006:	02d48863          	beq	s1,a3,80003036 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000300a:	449c                	lw	a5,8(s1)
    8000300c:	fef059e3          	blez	a5,80002ffe <iget+0x34>
    80003010:	4098                	lw	a4,0(s1)
    80003012:	ff3716e3          	bne	a4,s3,80002ffe <iget+0x34>
    80003016:	40d8                	lw	a4,4(s1)
    80003018:	ff4713e3          	bne	a4,s4,80002ffe <iget+0x34>
      ip->ref++;
    8000301c:	2785                	addiw	a5,a5,1
    8000301e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003020:	0001b517          	auipc	a0,0x1b
    80003024:	07050513          	addi	a0,a0,112 # 8001e090 <itable>
    80003028:	c3ffd0ef          	jal	80000c66 <release>
      return ip;
    8000302c:	8926                	mv	s2,s1
    8000302e:	a02d                	j	80003058 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003030:	fbe9                	bnez	a5,80003002 <iget+0x38>
      empty = ip;
    80003032:	8926                	mv	s2,s1
    80003034:	b7f9                	j	80003002 <iget+0x38>
  if(empty == 0)
    80003036:	02090a63          	beqz	s2,8000306a <iget+0xa0>
  ip->dev = dev;
    8000303a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000303e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003042:	4785                	li	a5,1
    80003044:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003048:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000304c:	0001b517          	auipc	a0,0x1b
    80003050:	04450513          	addi	a0,a0,68 # 8001e090 <itable>
    80003054:	c13fd0ef          	jal	80000c66 <release>
}
    80003058:	854a                	mv	a0,s2
    8000305a:	70a2                	ld	ra,40(sp)
    8000305c:	7402                	ld	s0,32(sp)
    8000305e:	64e2                	ld	s1,24(sp)
    80003060:	6942                	ld	s2,16(sp)
    80003062:	69a2                	ld	s3,8(sp)
    80003064:	6a02                	ld	s4,0(sp)
    80003066:	6145                	addi	sp,sp,48
    80003068:	8082                	ret
    panic("iget: no inodes");
    8000306a:	00004517          	auipc	a0,0x4
    8000306e:	3a650513          	addi	a0,a0,934 # 80007410 <etext+0x410>
    80003072:	f6efd0ef          	jal	800007e0 <panic>

0000000080003076 <iinit>:
{
    80003076:	7179                	addi	sp,sp,-48
    80003078:	f406                	sd	ra,40(sp)
    8000307a:	f022                	sd	s0,32(sp)
    8000307c:	ec26                	sd	s1,24(sp)
    8000307e:	e84a                	sd	s2,16(sp)
    80003080:	e44e                	sd	s3,8(sp)
    80003082:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003084:	00004597          	auipc	a1,0x4
    80003088:	39c58593          	addi	a1,a1,924 # 80007420 <etext+0x420>
    8000308c:	0001b517          	auipc	a0,0x1b
    80003090:	00450513          	addi	a0,a0,4 # 8001e090 <itable>
    80003094:	abbfd0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003098:	0001b497          	auipc	s1,0x1b
    8000309c:	02048493          	addi	s1,s1,32 # 8001e0b8 <itable+0x28>
    800030a0:	0001d997          	auipc	s3,0x1d
    800030a4:	aa898993          	addi	s3,s3,-1368 # 8001fb48 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800030a8:	00004917          	auipc	s2,0x4
    800030ac:	38090913          	addi	s2,s2,896 # 80007428 <etext+0x428>
    800030b0:	85ca                	mv	a1,s2
    800030b2:	8526                	mv	a0,s1
    800030b4:	5bb000ef          	jal	80003e6e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800030b8:	08848493          	addi	s1,s1,136
    800030bc:	ff349ae3          	bne	s1,s3,800030b0 <iinit+0x3a>
}
    800030c0:	70a2                	ld	ra,40(sp)
    800030c2:	7402                	ld	s0,32(sp)
    800030c4:	64e2                	ld	s1,24(sp)
    800030c6:	6942                	ld	s2,16(sp)
    800030c8:	69a2                	ld	s3,8(sp)
    800030ca:	6145                	addi	sp,sp,48
    800030cc:	8082                	ret

00000000800030ce <ialloc>:
{
    800030ce:	7139                	addi	sp,sp,-64
    800030d0:	fc06                	sd	ra,56(sp)
    800030d2:	f822                	sd	s0,48(sp)
    800030d4:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800030d6:	0001b717          	auipc	a4,0x1b
    800030da:	fa672703          	lw	a4,-90(a4) # 8001e07c <sb+0xc>
    800030de:	4785                	li	a5,1
    800030e0:	06e7f063          	bgeu	a5,a4,80003140 <ialloc+0x72>
    800030e4:	f426                	sd	s1,40(sp)
    800030e6:	f04a                	sd	s2,32(sp)
    800030e8:	ec4e                	sd	s3,24(sp)
    800030ea:	e852                	sd	s4,16(sp)
    800030ec:	e456                	sd	s5,8(sp)
    800030ee:	e05a                	sd	s6,0(sp)
    800030f0:	8aaa                	mv	s5,a0
    800030f2:	8b2e                	mv	s6,a1
    800030f4:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800030f6:	0001ba17          	auipc	s4,0x1b
    800030fa:	f7aa0a13          	addi	s4,s4,-134 # 8001e070 <sb>
    800030fe:	00495593          	srli	a1,s2,0x4
    80003102:	018a2783          	lw	a5,24(s4)
    80003106:	9dbd                	addw	a1,a1,a5
    80003108:	8556                	mv	a0,s5
    8000310a:	a69ff0ef          	jal	80002b72 <bread>
    8000310e:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003110:	05850993          	addi	s3,a0,88
    80003114:	00f97793          	andi	a5,s2,15
    80003118:	079a                	slli	a5,a5,0x6
    8000311a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000311c:	00099783          	lh	a5,0(s3)
    80003120:	cb9d                	beqz	a5,80003156 <ialloc+0x88>
    brelse(bp);
    80003122:	b59ff0ef          	jal	80002c7a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003126:	0905                	addi	s2,s2,1
    80003128:	00ca2703          	lw	a4,12(s4)
    8000312c:	0009079b          	sext.w	a5,s2
    80003130:	fce7e7e3          	bltu	a5,a4,800030fe <ialloc+0x30>
    80003134:	74a2                	ld	s1,40(sp)
    80003136:	7902                	ld	s2,32(sp)
    80003138:	69e2                	ld	s3,24(sp)
    8000313a:	6a42                	ld	s4,16(sp)
    8000313c:	6aa2                	ld	s5,8(sp)
    8000313e:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003140:	00004517          	auipc	a0,0x4
    80003144:	2f050513          	addi	a0,a0,752 # 80007430 <etext+0x430>
    80003148:	bb2fd0ef          	jal	800004fa <printf>
  return 0;
    8000314c:	4501                	li	a0,0
}
    8000314e:	70e2                	ld	ra,56(sp)
    80003150:	7442                	ld	s0,48(sp)
    80003152:	6121                	addi	sp,sp,64
    80003154:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003156:	04000613          	li	a2,64
    8000315a:	4581                	li	a1,0
    8000315c:	854e                	mv	a0,s3
    8000315e:	b45fd0ef          	jal	80000ca2 <memset>
      dip->type = type;
    80003162:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003166:	8526                	mv	a0,s1
    80003168:	445000ef          	jal	80003dac <log_write>
      brelse(bp);
    8000316c:	8526                	mv	a0,s1
    8000316e:	b0dff0ef          	jal	80002c7a <brelse>
      return iget(dev, inum);
    80003172:	0009059b          	sext.w	a1,s2
    80003176:	8556                	mv	a0,s5
    80003178:	e53ff0ef          	jal	80002fca <iget>
    8000317c:	74a2                	ld	s1,40(sp)
    8000317e:	7902                	ld	s2,32(sp)
    80003180:	69e2                	ld	s3,24(sp)
    80003182:	6a42                	ld	s4,16(sp)
    80003184:	6aa2                	ld	s5,8(sp)
    80003186:	6b02                	ld	s6,0(sp)
    80003188:	b7d9                	j	8000314e <ialloc+0x80>

000000008000318a <iupdate>:
{
    8000318a:	1101                	addi	sp,sp,-32
    8000318c:	ec06                	sd	ra,24(sp)
    8000318e:	e822                	sd	s0,16(sp)
    80003190:	e426                	sd	s1,8(sp)
    80003192:	e04a                	sd	s2,0(sp)
    80003194:	1000                	addi	s0,sp,32
    80003196:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003198:	415c                	lw	a5,4(a0)
    8000319a:	0047d79b          	srliw	a5,a5,0x4
    8000319e:	0001b597          	auipc	a1,0x1b
    800031a2:	eea5a583          	lw	a1,-278(a1) # 8001e088 <sb+0x18>
    800031a6:	9dbd                	addw	a1,a1,a5
    800031a8:	4108                	lw	a0,0(a0)
    800031aa:	9c9ff0ef          	jal	80002b72 <bread>
    800031ae:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800031b0:	05850793          	addi	a5,a0,88
    800031b4:	40d8                	lw	a4,4(s1)
    800031b6:	8b3d                	andi	a4,a4,15
    800031b8:	071a                	slli	a4,a4,0x6
    800031ba:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800031bc:	04449703          	lh	a4,68(s1)
    800031c0:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800031c4:	04649703          	lh	a4,70(s1)
    800031c8:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800031cc:	04849703          	lh	a4,72(s1)
    800031d0:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800031d4:	04a49703          	lh	a4,74(s1)
    800031d8:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800031dc:	44f8                	lw	a4,76(s1)
    800031de:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800031e0:	03400613          	li	a2,52
    800031e4:	05048593          	addi	a1,s1,80
    800031e8:	00c78513          	addi	a0,a5,12
    800031ec:	b13fd0ef          	jal	80000cfe <memmove>
  log_write(bp);
    800031f0:	854a                	mv	a0,s2
    800031f2:	3bb000ef          	jal	80003dac <log_write>
  brelse(bp);
    800031f6:	854a                	mv	a0,s2
    800031f8:	a83ff0ef          	jal	80002c7a <brelse>
}
    800031fc:	60e2                	ld	ra,24(sp)
    800031fe:	6442                	ld	s0,16(sp)
    80003200:	64a2                	ld	s1,8(sp)
    80003202:	6902                	ld	s2,0(sp)
    80003204:	6105                	addi	sp,sp,32
    80003206:	8082                	ret

0000000080003208 <idup>:
{
    80003208:	1101                	addi	sp,sp,-32
    8000320a:	ec06                	sd	ra,24(sp)
    8000320c:	e822                	sd	s0,16(sp)
    8000320e:	e426                	sd	s1,8(sp)
    80003210:	1000                	addi	s0,sp,32
    80003212:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003214:	0001b517          	auipc	a0,0x1b
    80003218:	e7c50513          	addi	a0,a0,-388 # 8001e090 <itable>
    8000321c:	9b3fd0ef          	jal	80000bce <acquire>
  ip->ref++;
    80003220:	449c                	lw	a5,8(s1)
    80003222:	2785                	addiw	a5,a5,1
    80003224:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003226:	0001b517          	auipc	a0,0x1b
    8000322a:	e6a50513          	addi	a0,a0,-406 # 8001e090 <itable>
    8000322e:	a39fd0ef          	jal	80000c66 <release>
}
    80003232:	8526                	mv	a0,s1
    80003234:	60e2                	ld	ra,24(sp)
    80003236:	6442                	ld	s0,16(sp)
    80003238:	64a2                	ld	s1,8(sp)
    8000323a:	6105                	addi	sp,sp,32
    8000323c:	8082                	ret

000000008000323e <ilock>:
{
    8000323e:	1101                	addi	sp,sp,-32
    80003240:	ec06                	sd	ra,24(sp)
    80003242:	e822                	sd	s0,16(sp)
    80003244:	e426                	sd	s1,8(sp)
    80003246:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003248:	cd19                	beqz	a0,80003266 <ilock+0x28>
    8000324a:	84aa                	mv	s1,a0
    8000324c:	451c                	lw	a5,8(a0)
    8000324e:	00f05c63          	blez	a5,80003266 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003252:	0541                	addi	a0,a0,16
    80003254:	451000ef          	jal	80003ea4 <acquiresleep>
  if(ip->valid == 0){
    80003258:	40bc                	lw	a5,64(s1)
    8000325a:	cf89                	beqz	a5,80003274 <ilock+0x36>
}
    8000325c:	60e2                	ld	ra,24(sp)
    8000325e:	6442                	ld	s0,16(sp)
    80003260:	64a2                	ld	s1,8(sp)
    80003262:	6105                	addi	sp,sp,32
    80003264:	8082                	ret
    80003266:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003268:	00004517          	auipc	a0,0x4
    8000326c:	1e050513          	addi	a0,a0,480 # 80007448 <etext+0x448>
    80003270:	d70fd0ef          	jal	800007e0 <panic>
    80003274:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003276:	40dc                	lw	a5,4(s1)
    80003278:	0047d79b          	srliw	a5,a5,0x4
    8000327c:	0001b597          	auipc	a1,0x1b
    80003280:	e0c5a583          	lw	a1,-500(a1) # 8001e088 <sb+0x18>
    80003284:	9dbd                	addw	a1,a1,a5
    80003286:	4088                	lw	a0,0(s1)
    80003288:	8ebff0ef          	jal	80002b72 <bread>
    8000328c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000328e:	05850593          	addi	a1,a0,88
    80003292:	40dc                	lw	a5,4(s1)
    80003294:	8bbd                	andi	a5,a5,15
    80003296:	079a                	slli	a5,a5,0x6
    80003298:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000329a:	00059783          	lh	a5,0(a1)
    8000329e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800032a2:	00259783          	lh	a5,2(a1)
    800032a6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800032aa:	00459783          	lh	a5,4(a1)
    800032ae:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800032b2:	00659783          	lh	a5,6(a1)
    800032b6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800032ba:	459c                	lw	a5,8(a1)
    800032bc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800032be:	03400613          	li	a2,52
    800032c2:	05b1                	addi	a1,a1,12
    800032c4:	05048513          	addi	a0,s1,80
    800032c8:	a37fd0ef          	jal	80000cfe <memmove>
    brelse(bp);
    800032cc:	854a                	mv	a0,s2
    800032ce:	9adff0ef          	jal	80002c7a <brelse>
    ip->valid = 1;
    800032d2:	4785                	li	a5,1
    800032d4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800032d6:	04449783          	lh	a5,68(s1)
    800032da:	c399                	beqz	a5,800032e0 <ilock+0xa2>
    800032dc:	6902                	ld	s2,0(sp)
    800032de:	bfbd                	j	8000325c <ilock+0x1e>
      panic("ilock: no type");
    800032e0:	00004517          	auipc	a0,0x4
    800032e4:	17050513          	addi	a0,a0,368 # 80007450 <etext+0x450>
    800032e8:	cf8fd0ef          	jal	800007e0 <panic>

00000000800032ec <iunlock>:
{
    800032ec:	1101                	addi	sp,sp,-32
    800032ee:	ec06                	sd	ra,24(sp)
    800032f0:	e822                	sd	s0,16(sp)
    800032f2:	e426                	sd	s1,8(sp)
    800032f4:	e04a                	sd	s2,0(sp)
    800032f6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800032f8:	c505                	beqz	a0,80003320 <iunlock+0x34>
    800032fa:	84aa                	mv	s1,a0
    800032fc:	01050913          	addi	s2,a0,16
    80003300:	854a                	mv	a0,s2
    80003302:	421000ef          	jal	80003f22 <holdingsleep>
    80003306:	cd09                	beqz	a0,80003320 <iunlock+0x34>
    80003308:	449c                	lw	a5,8(s1)
    8000330a:	00f05b63          	blez	a5,80003320 <iunlock+0x34>
  releasesleep(&ip->lock);
    8000330e:	854a                	mv	a0,s2
    80003310:	3db000ef          	jal	80003eea <releasesleep>
}
    80003314:	60e2                	ld	ra,24(sp)
    80003316:	6442                	ld	s0,16(sp)
    80003318:	64a2                	ld	s1,8(sp)
    8000331a:	6902                	ld	s2,0(sp)
    8000331c:	6105                	addi	sp,sp,32
    8000331e:	8082                	ret
    panic("iunlock");
    80003320:	00004517          	auipc	a0,0x4
    80003324:	14050513          	addi	a0,a0,320 # 80007460 <etext+0x460>
    80003328:	cb8fd0ef          	jal	800007e0 <panic>

000000008000332c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000332c:	7179                	addi	sp,sp,-48
    8000332e:	f406                	sd	ra,40(sp)
    80003330:	f022                	sd	s0,32(sp)
    80003332:	ec26                	sd	s1,24(sp)
    80003334:	e84a                	sd	s2,16(sp)
    80003336:	e44e                	sd	s3,8(sp)
    80003338:	1800                	addi	s0,sp,48
    8000333a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000333c:	05050493          	addi	s1,a0,80
    80003340:	08050913          	addi	s2,a0,128
    80003344:	a021                	j	8000334c <itrunc+0x20>
    80003346:	0491                	addi	s1,s1,4
    80003348:	01248b63          	beq	s1,s2,8000335e <itrunc+0x32>
    if(ip->addrs[i]){
    8000334c:	408c                	lw	a1,0(s1)
    8000334e:	dde5                	beqz	a1,80003346 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003350:	0009a503          	lw	a0,0(s3)
    80003354:	a17ff0ef          	jal	80002d6a <bfree>
      ip->addrs[i] = 0;
    80003358:	0004a023          	sw	zero,0(s1)
    8000335c:	b7ed                	j	80003346 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000335e:	0809a583          	lw	a1,128(s3)
    80003362:	ed89                	bnez	a1,8000337c <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003364:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003368:	854e                	mv	a0,s3
    8000336a:	e21ff0ef          	jal	8000318a <iupdate>
}
    8000336e:	70a2                	ld	ra,40(sp)
    80003370:	7402                	ld	s0,32(sp)
    80003372:	64e2                	ld	s1,24(sp)
    80003374:	6942                	ld	s2,16(sp)
    80003376:	69a2                	ld	s3,8(sp)
    80003378:	6145                	addi	sp,sp,48
    8000337a:	8082                	ret
    8000337c:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000337e:	0009a503          	lw	a0,0(s3)
    80003382:	ff0ff0ef          	jal	80002b72 <bread>
    80003386:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003388:	05850493          	addi	s1,a0,88
    8000338c:	45850913          	addi	s2,a0,1112
    80003390:	a021                	j	80003398 <itrunc+0x6c>
    80003392:	0491                	addi	s1,s1,4
    80003394:	01248963          	beq	s1,s2,800033a6 <itrunc+0x7a>
      if(a[j])
    80003398:	408c                	lw	a1,0(s1)
    8000339a:	dde5                	beqz	a1,80003392 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000339c:	0009a503          	lw	a0,0(s3)
    800033a0:	9cbff0ef          	jal	80002d6a <bfree>
    800033a4:	b7fd                	j	80003392 <itrunc+0x66>
    brelse(bp);
    800033a6:	8552                	mv	a0,s4
    800033a8:	8d3ff0ef          	jal	80002c7a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800033ac:	0809a583          	lw	a1,128(s3)
    800033b0:	0009a503          	lw	a0,0(s3)
    800033b4:	9b7ff0ef          	jal	80002d6a <bfree>
    ip->addrs[NDIRECT] = 0;
    800033b8:	0809a023          	sw	zero,128(s3)
    800033bc:	6a02                	ld	s4,0(sp)
    800033be:	b75d                	j	80003364 <itrunc+0x38>

00000000800033c0 <iput>:
{
    800033c0:	1101                	addi	sp,sp,-32
    800033c2:	ec06                	sd	ra,24(sp)
    800033c4:	e822                	sd	s0,16(sp)
    800033c6:	e426                	sd	s1,8(sp)
    800033c8:	1000                	addi	s0,sp,32
    800033ca:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033cc:	0001b517          	auipc	a0,0x1b
    800033d0:	cc450513          	addi	a0,a0,-828 # 8001e090 <itable>
    800033d4:	ffafd0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800033d8:	4498                	lw	a4,8(s1)
    800033da:	4785                	li	a5,1
    800033dc:	02f70063          	beq	a4,a5,800033fc <iput+0x3c>
  ip->ref--;
    800033e0:	449c                	lw	a5,8(s1)
    800033e2:	37fd                	addiw	a5,a5,-1
    800033e4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033e6:	0001b517          	auipc	a0,0x1b
    800033ea:	caa50513          	addi	a0,a0,-854 # 8001e090 <itable>
    800033ee:	879fd0ef          	jal	80000c66 <release>
}
    800033f2:	60e2                	ld	ra,24(sp)
    800033f4:	6442                	ld	s0,16(sp)
    800033f6:	64a2                	ld	s1,8(sp)
    800033f8:	6105                	addi	sp,sp,32
    800033fa:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800033fc:	40bc                	lw	a5,64(s1)
    800033fe:	d3ed                	beqz	a5,800033e0 <iput+0x20>
    80003400:	04a49783          	lh	a5,74(s1)
    80003404:	fff1                	bnez	a5,800033e0 <iput+0x20>
    80003406:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003408:	01048913          	addi	s2,s1,16
    8000340c:	854a                	mv	a0,s2
    8000340e:	297000ef          	jal	80003ea4 <acquiresleep>
    release(&itable.lock);
    80003412:	0001b517          	auipc	a0,0x1b
    80003416:	c7e50513          	addi	a0,a0,-898 # 8001e090 <itable>
    8000341a:	84dfd0ef          	jal	80000c66 <release>
    itrunc(ip);
    8000341e:	8526                	mv	a0,s1
    80003420:	f0dff0ef          	jal	8000332c <itrunc>
    ip->type = 0;
    80003424:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003428:	8526                	mv	a0,s1
    8000342a:	d61ff0ef          	jal	8000318a <iupdate>
    ip->valid = 0;
    8000342e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003432:	854a                	mv	a0,s2
    80003434:	2b7000ef          	jal	80003eea <releasesleep>
    acquire(&itable.lock);
    80003438:	0001b517          	auipc	a0,0x1b
    8000343c:	c5850513          	addi	a0,a0,-936 # 8001e090 <itable>
    80003440:	f8efd0ef          	jal	80000bce <acquire>
    80003444:	6902                	ld	s2,0(sp)
    80003446:	bf69                	j	800033e0 <iput+0x20>

0000000080003448 <iunlockput>:
{
    80003448:	1101                	addi	sp,sp,-32
    8000344a:	ec06                	sd	ra,24(sp)
    8000344c:	e822                	sd	s0,16(sp)
    8000344e:	e426                	sd	s1,8(sp)
    80003450:	1000                	addi	s0,sp,32
    80003452:	84aa                	mv	s1,a0
  iunlock(ip);
    80003454:	e99ff0ef          	jal	800032ec <iunlock>
  iput(ip);
    80003458:	8526                	mv	a0,s1
    8000345a:	f67ff0ef          	jal	800033c0 <iput>
}
    8000345e:	60e2                	ld	ra,24(sp)
    80003460:	6442                	ld	s0,16(sp)
    80003462:	64a2                	ld	s1,8(sp)
    80003464:	6105                	addi	sp,sp,32
    80003466:	8082                	ret

0000000080003468 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003468:	0001b717          	auipc	a4,0x1b
    8000346c:	c1472703          	lw	a4,-1004(a4) # 8001e07c <sb+0xc>
    80003470:	4785                	li	a5,1
    80003472:	0ae7ff63          	bgeu	a5,a4,80003530 <ireclaim+0xc8>
{
    80003476:	7139                	addi	sp,sp,-64
    80003478:	fc06                	sd	ra,56(sp)
    8000347a:	f822                	sd	s0,48(sp)
    8000347c:	f426                	sd	s1,40(sp)
    8000347e:	f04a                	sd	s2,32(sp)
    80003480:	ec4e                	sd	s3,24(sp)
    80003482:	e852                	sd	s4,16(sp)
    80003484:	e456                	sd	s5,8(sp)
    80003486:	e05a                	sd	s6,0(sp)
    80003488:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000348a:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000348c:	00050a1b          	sext.w	s4,a0
    80003490:	0001ba97          	auipc	s5,0x1b
    80003494:	be0a8a93          	addi	s5,s5,-1056 # 8001e070 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003498:	00004b17          	auipc	s6,0x4
    8000349c:	fd0b0b13          	addi	s6,s6,-48 # 80007468 <etext+0x468>
    800034a0:	a099                	j	800034e6 <ireclaim+0x7e>
    800034a2:	85ce                	mv	a1,s3
    800034a4:	855a                	mv	a0,s6
    800034a6:	854fd0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    800034aa:	85ce                	mv	a1,s3
    800034ac:	8552                	mv	a0,s4
    800034ae:	b1dff0ef          	jal	80002fca <iget>
    800034b2:	89aa                	mv	s3,a0
    brelse(bp);
    800034b4:	854a                	mv	a0,s2
    800034b6:	fc4ff0ef          	jal	80002c7a <brelse>
    if (ip) {
    800034ba:	00098f63          	beqz	s3,800034d8 <ireclaim+0x70>
      begin_op();
    800034be:	76a000ef          	jal	80003c28 <begin_op>
      ilock(ip);
    800034c2:	854e                	mv	a0,s3
    800034c4:	d7bff0ef          	jal	8000323e <ilock>
      iunlock(ip);
    800034c8:	854e                	mv	a0,s3
    800034ca:	e23ff0ef          	jal	800032ec <iunlock>
      iput(ip);
    800034ce:	854e                	mv	a0,s3
    800034d0:	ef1ff0ef          	jal	800033c0 <iput>
      end_op();
    800034d4:	7be000ef          	jal	80003c92 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034d8:	0485                	addi	s1,s1,1
    800034da:	00caa703          	lw	a4,12(s5)
    800034de:	0004879b          	sext.w	a5,s1
    800034e2:	02e7fd63          	bgeu	a5,a4,8000351c <ireclaim+0xb4>
    800034e6:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800034ea:	0044d593          	srli	a1,s1,0x4
    800034ee:	018aa783          	lw	a5,24(s5)
    800034f2:	9dbd                	addw	a1,a1,a5
    800034f4:	8552                	mv	a0,s4
    800034f6:	e7cff0ef          	jal	80002b72 <bread>
    800034fa:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800034fc:	05850793          	addi	a5,a0,88
    80003500:	00f9f713          	andi	a4,s3,15
    80003504:	071a                	slli	a4,a4,0x6
    80003506:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003508:	00079703          	lh	a4,0(a5)
    8000350c:	c701                	beqz	a4,80003514 <ireclaim+0xac>
    8000350e:	00679783          	lh	a5,6(a5)
    80003512:	dbc1                	beqz	a5,800034a2 <ireclaim+0x3a>
    brelse(bp);
    80003514:	854a                	mv	a0,s2
    80003516:	f64ff0ef          	jal	80002c7a <brelse>
    if (ip) {
    8000351a:	bf7d                	j	800034d8 <ireclaim+0x70>
}
    8000351c:	70e2                	ld	ra,56(sp)
    8000351e:	7442                	ld	s0,48(sp)
    80003520:	74a2                	ld	s1,40(sp)
    80003522:	7902                	ld	s2,32(sp)
    80003524:	69e2                	ld	s3,24(sp)
    80003526:	6a42                	ld	s4,16(sp)
    80003528:	6aa2                	ld	s5,8(sp)
    8000352a:	6b02                	ld	s6,0(sp)
    8000352c:	6121                	addi	sp,sp,64
    8000352e:	8082                	ret
    80003530:	8082                	ret

0000000080003532 <fsinit>:
fsinit(int dev) {
    80003532:	7179                	addi	sp,sp,-48
    80003534:	f406                	sd	ra,40(sp)
    80003536:	f022                	sd	s0,32(sp)
    80003538:	ec26                	sd	s1,24(sp)
    8000353a:	e84a                	sd	s2,16(sp)
    8000353c:	e44e                	sd	s3,8(sp)
    8000353e:	1800                	addi	s0,sp,48
    80003540:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003542:	4585                	li	a1,1
    80003544:	e2eff0ef          	jal	80002b72 <bread>
    80003548:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000354a:	0001b997          	auipc	s3,0x1b
    8000354e:	b2698993          	addi	s3,s3,-1242 # 8001e070 <sb>
    80003552:	02000613          	li	a2,32
    80003556:	05850593          	addi	a1,a0,88
    8000355a:	854e                	mv	a0,s3
    8000355c:	fa2fd0ef          	jal	80000cfe <memmove>
  brelse(bp);
    80003560:	854a                	mv	a0,s2
    80003562:	f18ff0ef          	jal	80002c7a <brelse>
  if(sb.magic != FSMAGIC)
    80003566:	0009a703          	lw	a4,0(s3)
    8000356a:	102037b7          	lui	a5,0x10203
    8000356e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003572:	02f71363          	bne	a4,a5,80003598 <fsinit+0x66>
  initlog(dev, &sb);
    80003576:	0001b597          	auipc	a1,0x1b
    8000357a:	afa58593          	addi	a1,a1,-1286 # 8001e070 <sb>
    8000357e:	8526                	mv	a0,s1
    80003580:	62a000ef          	jal	80003baa <initlog>
  ireclaim(dev);
    80003584:	8526                	mv	a0,s1
    80003586:	ee3ff0ef          	jal	80003468 <ireclaim>
}
    8000358a:	70a2                	ld	ra,40(sp)
    8000358c:	7402                	ld	s0,32(sp)
    8000358e:	64e2                	ld	s1,24(sp)
    80003590:	6942                	ld	s2,16(sp)
    80003592:	69a2                	ld	s3,8(sp)
    80003594:	6145                	addi	sp,sp,48
    80003596:	8082                	ret
    panic("invalid file system");
    80003598:	00004517          	auipc	a0,0x4
    8000359c:	ef050513          	addi	a0,a0,-272 # 80007488 <etext+0x488>
    800035a0:	a40fd0ef          	jal	800007e0 <panic>

00000000800035a4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800035a4:	1141                	addi	sp,sp,-16
    800035a6:	e422                	sd	s0,8(sp)
    800035a8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800035aa:	411c                	lw	a5,0(a0)
    800035ac:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800035ae:	415c                	lw	a5,4(a0)
    800035b0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800035b2:	04451783          	lh	a5,68(a0)
    800035b6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800035ba:	04a51783          	lh	a5,74(a0)
    800035be:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800035c2:	04c56783          	lwu	a5,76(a0)
    800035c6:	e99c                	sd	a5,16(a1)
}
    800035c8:	6422                	ld	s0,8(sp)
    800035ca:	0141                	addi	sp,sp,16
    800035cc:	8082                	ret

00000000800035ce <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800035ce:	457c                	lw	a5,76(a0)
    800035d0:	0ed7eb63          	bltu	a5,a3,800036c6 <readi+0xf8>
{
    800035d4:	7159                	addi	sp,sp,-112
    800035d6:	f486                	sd	ra,104(sp)
    800035d8:	f0a2                	sd	s0,96(sp)
    800035da:	eca6                	sd	s1,88(sp)
    800035dc:	e0d2                	sd	s4,64(sp)
    800035de:	fc56                	sd	s5,56(sp)
    800035e0:	f85a                	sd	s6,48(sp)
    800035e2:	f45e                	sd	s7,40(sp)
    800035e4:	1880                	addi	s0,sp,112
    800035e6:	8b2a                	mv	s6,a0
    800035e8:	8bae                	mv	s7,a1
    800035ea:	8a32                	mv	s4,a2
    800035ec:	84b6                	mv	s1,a3
    800035ee:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800035f0:	9f35                	addw	a4,a4,a3
    return 0;
    800035f2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800035f4:	0cd76063          	bltu	a4,a3,800036b4 <readi+0xe6>
    800035f8:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800035fa:	00e7f463          	bgeu	a5,a4,80003602 <readi+0x34>
    n = ip->size - off;
    800035fe:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003602:	080a8f63          	beqz	s5,800036a0 <readi+0xd2>
    80003606:	e8ca                	sd	s2,80(sp)
    80003608:	f062                	sd	s8,32(sp)
    8000360a:	ec66                	sd	s9,24(sp)
    8000360c:	e86a                	sd	s10,16(sp)
    8000360e:	e46e                	sd	s11,8(sp)
    80003610:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003612:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003616:	5c7d                	li	s8,-1
    80003618:	a80d                	j	8000364a <readi+0x7c>
    8000361a:	020d1d93          	slli	s11,s10,0x20
    8000361e:	020ddd93          	srli	s11,s11,0x20
    80003622:	05890613          	addi	a2,s2,88
    80003626:	86ee                	mv	a3,s11
    80003628:	963a                	add	a2,a2,a4
    8000362a:	85d2                	mv	a1,s4
    8000362c:	855e                	mv	a0,s7
    8000362e:	c3bfe0ef          	jal	80002268 <either_copyout>
    80003632:	05850763          	beq	a0,s8,80003680 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003636:	854a                	mv	a0,s2
    80003638:	e42ff0ef          	jal	80002c7a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000363c:	013d09bb          	addw	s3,s10,s3
    80003640:	009d04bb          	addw	s1,s10,s1
    80003644:	9a6e                	add	s4,s4,s11
    80003646:	0559f763          	bgeu	s3,s5,80003694 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    8000364a:	00a4d59b          	srliw	a1,s1,0xa
    8000364e:	855a                	mv	a0,s6
    80003650:	8a7ff0ef          	jal	80002ef6 <bmap>
    80003654:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003658:	c5b1                	beqz	a1,800036a4 <readi+0xd6>
    bp = bread(ip->dev, addr);
    8000365a:	000b2503          	lw	a0,0(s6)
    8000365e:	d14ff0ef          	jal	80002b72 <bread>
    80003662:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003664:	3ff4f713          	andi	a4,s1,1023
    80003668:	40ec87bb          	subw	a5,s9,a4
    8000366c:	413a86bb          	subw	a3,s5,s3
    80003670:	8d3e                	mv	s10,a5
    80003672:	2781                	sext.w	a5,a5
    80003674:	0006861b          	sext.w	a2,a3
    80003678:	faf671e3          	bgeu	a2,a5,8000361a <readi+0x4c>
    8000367c:	8d36                	mv	s10,a3
    8000367e:	bf71                	j	8000361a <readi+0x4c>
      brelse(bp);
    80003680:	854a                	mv	a0,s2
    80003682:	df8ff0ef          	jal	80002c7a <brelse>
      tot = -1;
    80003686:	59fd                	li	s3,-1
      break;
    80003688:	6946                	ld	s2,80(sp)
    8000368a:	7c02                	ld	s8,32(sp)
    8000368c:	6ce2                	ld	s9,24(sp)
    8000368e:	6d42                	ld	s10,16(sp)
    80003690:	6da2                	ld	s11,8(sp)
    80003692:	a831                	j	800036ae <readi+0xe0>
    80003694:	6946                	ld	s2,80(sp)
    80003696:	7c02                	ld	s8,32(sp)
    80003698:	6ce2                	ld	s9,24(sp)
    8000369a:	6d42                	ld	s10,16(sp)
    8000369c:	6da2                	ld	s11,8(sp)
    8000369e:	a801                	j	800036ae <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800036a0:	89d6                	mv	s3,s5
    800036a2:	a031                	j	800036ae <readi+0xe0>
    800036a4:	6946                	ld	s2,80(sp)
    800036a6:	7c02                	ld	s8,32(sp)
    800036a8:	6ce2                	ld	s9,24(sp)
    800036aa:	6d42                	ld	s10,16(sp)
    800036ac:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800036ae:	0009851b          	sext.w	a0,s3
    800036b2:	69a6                	ld	s3,72(sp)
}
    800036b4:	70a6                	ld	ra,104(sp)
    800036b6:	7406                	ld	s0,96(sp)
    800036b8:	64e6                	ld	s1,88(sp)
    800036ba:	6a06                	ld	s4,64(sp)
    800036bc:	7ae2                	ld	s5,56(sp)
    800036be:	7b42                	ld	s6,48(sp)
    800036c0:	7ba2                	ld	s7,40(sp)
    800036c2:	6165                	addi	sp,sp,112
    800036c4:	8082                	ret
    return 0;
    800036c6:	4501                	li	a0,0
}
    800036c8:	8082                	ret

00000000800036ca <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800036ca:	457c                	lw	a5,76(a0)
    800036cc:	10d7e063          	bltu	a5,a3,800037cc <writei+0x102>
{
    800036d0:	7159                	addi	sp,sp,-112
    800036d2:	f486                	sd	ra,104(sp)
    800036d4:	f0a2                	sd	s0,96(sp)
    800036d6:	e8ca                	sd	s2,80(sp)
    800036d8:	e0d2                	sd	s4,64(sp)
    800036da:	fc56                	sd	s5,56(sp)
    800036dc:	f85a                	sd	s6,48(sp)
    800036de:	f45e                	sd	s7,40(sp)
    800036e0:	1880                	addi	s0,sp,112
    800036e2:	8aaa                	mv	s5,a0
    800036e4:	8bae                	mv	s7,a1
    800036e6:	8a32                	mv	s4,a2
    800036e8:	8936                	mv	s2,a3
    800036ea:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800036ec:	00e687bb          	addw	a5,a3,a4
    800036f0:	0ed7e063          	bltu	a5,a3,800037d0 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800036f4:	00043737          	lui	a4,0x43
    800036f8:	0cf76e63          	bltu	a4,a5,800037d4 <writei+0x10a>
    800036fc:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800036fe:	0a0b0f63          	beqz	s6,800037bc <writei+0xf2>
    80003702:	eca6                	sd	s1,88(sp)
    80003704:	f062                	sd	s8,32(sp)
    80003706:	ec66                	sd	s9,24(sp)
    80003708:	e86a                	sd	s10,16(sp)
    8000370a:	e46e                	sd	s11,8(sp)
    8000370c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000370e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003712:	5c7d                	li	s8,-1
    80003714:	a825                	j	8000374c <writei+0x82>
    80003716:	020d1d93          	slli	s11,s10,0x20
    8000371a:	020ddd93          	srli	s11,s11,0x20
    8000371e:	05848513          	addi	a0,s1,88
    80003722:	86ee                	mv	a3,s11
    80003724:	8652                	mv	a2,s4
    80003726:	85de                	mv	a1,s7
    80003728:	953a                	add	a0,a0,a4
    8000372a:	b89fe0ef          	jal	800022b2 <either_copyin>
    8000372e:	05850a63          	beq	a0,s8,80003782 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003732:	8526                	mv	a0,s1
    80003734:	678000ef          	jal	80003dac <log_write>
    brelse(bp);
    80003738:	8526                	mv	a0,s1
    8000373a:	d40ff0ef          	jal	80002c7a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000373e:	013d09bb          	addw	s3,s10,s3
    80003742:	012d093b          	addw	s2,s10,s2
    80003746:	9a6e                	add	s4,s4,s11
    80003748:	0569f063          	bgeu	s3,s6,80003788 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    8000374c:	00a9559b          	srliw	a1,s2,0xa
    80003750:	8556                	mv	a0,s5
    80003752:	fa4ff0ef          	jal	80002ef6 <bmap>
    80003756:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000375a:	c59d                	beqz	a1,80003788 <writei+0xbe>
    bp = bread(ip->dev, addr);
    8000375c:	000aa503          	lw	a0,0(s5)
    80003760:	c12ff0ef          	jal	80002b72 <bread>
    80003764:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003766:	3ff97713          	andi	a4,s2,1023
    8000376a:	40ec87bb          	subw	a5,s9,a4
    8000376e:	413b06bb          	subw	a3,s6,s3
    80003772:	8d3e                	mv	s10,a5
    80003774:	2781                	sext.w	a5,a5
    80003776:	0006861b          	sext.w	a2,a3
    8000377a:	f8f67ee3          	bgeu	a2,a5,80003716 <writei+0x4c>
    8000377e:	8d36                	mv	s10,a3
    80003780:	bf59                	j	80003716 <writei+0x4c>
      brelse(bp);
    80003782:	8526                	mv	a0,s1
    80003784:	cf6ff0ef          	jal	80002c7a <brelse>
  }

  if(off > ip->size)
    80003788:	04caa783          	lw	a5,76(s5)
    8000378c:	0327fa63          	bgeu	a5,s2,800037c0 <writei+0xf6>
    ip->size = off;
    80003790:	052aa623          	sw	s2,76(s5)
    80003794:	64e6                	ld	s1,88(sp)
    80003796:	7c02                	ld	s8,32(sp)
    80003798:	6ce2                	ld	s9,24(sp)
    8000379a:	6d42                	ld	s10,16(sp)
    8000379c:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000379e:	8556                	mv	a0,s5
    800037a0:	9ebff0ef          	jal	8000318a <iupdate>

  return tot;
    800037a4:	0009851b          	sext.w	a0,s3
    800037a8:	69a6                	ld	s3,72(sp)
}
    800037aa:	70a6                	ld	ra,104(sp)
    800037ac:	7406                	ld	s0,96(sp)
    800037ae:	6946                	ld	s2,80(sp)
    800037b0:	6a06                	ld	s4,64(sp)
    800037b2:	7ae2                	ld	s5,56(sp)
    800037b4:	7b42                	ld	s6,48(sp)
    800037b6:	7ba2                	ld	s7,40(sp)
    800037b8:	6165                	addi	sp,sp,112
    800037ba:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800037bc:	89da                	mv	s3,s6
    800037be:	b7c5                	j	8000379e <writei+0xd4>
    800037c0:	64e6                	ld	s1,88(sp)
    800037c2:	7c02                	ld	s8,32(sp)
    800037c4:	6ce2                	ld	s9,24(sp)
    800037c6:	6d42                	ld	s10,16(sp)
    800037c8:	6da2                	ld	s11,8(sp)
    800037ca:	bfd1                	j	8000379e <writei+0xd4>
    return -1;
    800037cc:	557d                	li	a0,-1
}
    800037ce:	8082                	ret
    return -1;
    800037d0:	557d                	li	a0,-1
    800037d2:	bfe1                	j	800037aa <writei+0xe0>
    return -1;
    800037d4:	557d                	li	a0,-1
    800037d6:	bfd1                	j	800037aa <writei+0xe0>

00000000800037d8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800037d8:	1141                	addi	sp,sp,-16
    800037da:	e406                	sd	ra,8(sp)
    800037dc:	e022                	sd	s0,0(sp)
    800037de:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800037e0:	4639                	li	a2,14
    800037e2:	d8cfd0ef          	jal	80000d6e <strncmp>
}
    800037e6:	60a2                	ld	ra,8(sp)
    800037e8:	6402                	ld	s0,0(sp)
    800037ea:	0141                	addi	sp,sp,16
    800037ec:	8082                	ret

00000000800037ee <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800037ee:	7139                	addi	sp,sp,-64
    800037f0:	fc06                	sd	ra,56(sp)
    800037f2:	f822                	sd	s0,48(sp)
    800037f4:	f426                	sd	s1,40(sp)
    800037f6:	f04a                	sd	s2,32(sp)
    800037f8:	ec4e                	sd	s3,24(sp)
    800037fa:	e852                	sd	s4,16(sp)
    800037fc:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800037fe:	04451703          	lh	a4,68(a0)
    80003802:	4785                	li	a5,1
    80003804:	00f71a63          	bne	a4,a5,80003818 <dirlookup+0x2a>
    80003808:	892a                	mv	s2,a0
    8000380a:	89ae                	mv	s3,a1
    8000380c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000380e:	457c                	lw	a5,76(a0)
    80003810:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003812:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003814:	e39d                	bnez	a5,8000383a <dirlookup+0x4c>
    80003816:	a095                	j	8000387a <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003818:	00004517          	auipc	a0,0x4
    8000381c:	c8850513          	addi	a0,a0,-888 # 800074a0 <etext+0x4a0>
    80003820:	fc1fc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    80003824:	00004517          	auipc	a0,0x4
    80003828:	c9450513          	addi	a0,a0,-876 # 800074b8 <etext+0x4b8>
    8000382c:	fb5fc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003830:	24c1                	addiw	s1,s1,16
    80003832:	04c92783          	lw	a5,76(s2)
    80003836:	04f4f163          	bgeu	s1,a5,80003878 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000383a:	4741                	li	a4,16
    8000383c:	86a6                	mv	a3,s1
    8000383e:	fc040613          	addi	a2,s0,-64
    80003842:	4581                	li	a1,0
    80003844:	854a                	mv	a0,s2
    80003846:	d89ff0ef          	jal	800035ce <readi>
    8000384a:	47c1                	li	a5,16
    8000384c:	fcf51ce3          	bne	a0,a5,80003824 <dirlookup+0x36>
    if(de.inum == 0)
    80003850:	fc045783          	lhu	a5,-64(s0)
    80003854:	dff1                	beqz	a5,80003830 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003856:	fc240593          	addi	a1,s0,-62
    8000385a:	854e                	mv	a0,s3
    8000385c:	f7dff0ef          	jal	800037d8 <namecmp>
    80003860:	f961                	bnez	a0,80003830 <dirlookup+0x42>
      if(poff)
    80003862:	000a0463          	beqz	s4,8000386a <dirlookup+0x7c>
        *poff = off;
    80003866:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000386a:	fc045583          	lhu	a1,-64(s0)
    8000386e:	00092503          	lw	a0,0(s2)
    80003872:	f58ff0ef          	jal	80002fca <iget>
    80003876:	a011                	j	8000387a <dirlookup+0x8c>
  return 0;
    80003878:	4501                	li	a0,0
}
    8000387a:	70e2                	ld	ra,56(sp)
    8000387c:	7442                	ld	s0,48(sp)
    8000387e:	74a2                	ld	s1,40(sp)
    80003880:	7902                	ld	s2,32(sp)
    80003882:	69e2                	ld	s3,24(sp)
    80003884:	6a42                	ld	s4,16(sp)
    80003886:	6121                	addi	sp,sp,64
    80003888:	8082                	ret

000000008000388a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000388a:	711d                	addi	sp,sp,-96
    8000388c:	ec86                	sd	ra,88(sp)
    8000388e:	e8a2                	sd	s0,80(sp)
    80003890:	e4a6                	sd	s1,72(sp)
    80003892:	e0ca                	sd	s2,64(sp)
    80003894:	fc4e                	sd	s3,56(sp)
    80003896:	f852                	sd	s4,48(sp)
    80003898:	f456                	sd	s5,40(sp)
    8000389a:	f05a                	sd	s6,32(sp)
    8000389c:	ec5e                	sd	s7,24(sp)
    8000389e:	e862                	sd	s8,16(sp)
    800038a0:	e466                	sd	s9,8(sp)
    800038a2:	1080                	addi	s0,sp,96
    800038a4:	84aa                	mv	s1,a0
    800038a6:	8b2e                	mv	s6,a1
    800038a8:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800038aa:	00054703          	lbu	a4,0(a0)
    800038ae:	02f00793          	li	a5,47
    800038b2:	00f70e63          	beq	a4,a5,800038ce <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800038b6:	818fe0ef          	jal	800018ce <myproc>
    800038ba:	15053503          	ld	a0,336(a0)
    800038be:	94bff0ef          	jal	80003208 <idup>
    800038c2:	8a2a                	mv	s4,a0
  while(*path == '/')
    800038c4:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800038c8:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800038ca:	4b85                	li	s7,1
    800038cc:	a871                	j	80003968 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    800038ce:	4585                	li	a1,1
    800038d0:	4505                	li	a0,1
    800038d2:	ef8ff0ef          	jal	80002fca <iget>
    800038d6:	8a2a                	mv	s4,a0
    800038d8:	b7f5                	j	800038c4 <namex+0x3a>
      iunlockput(ip);
    800038da:	8552                	mv	a0,s4
    800038dc:	b6dff0ef          	jal	80003448 <iunlockput>
      return 0;
    800038e0:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800038e2:	8552                	mv	a0,s4
    800038e4:	60e6                	ld	ra,88(sp)
    800038e6:	6446                	ld	s0,80(sp)
    800038e8:	64a6                	ld	s1,72(sp)
    800038ea:	6906                	ld	s2,64(sp)
    800038ec:	79e2                	ld	s3,56(sp)
    800038ee:	7a42                	ld	s4,48(sp)
    800038f0:	7aa2                	ld	s5,40(sp)
    800038f2:	7b02                	ld	s6,32(sp)
    800038f4:	6be2                	ld	s7,24(sp)
    800038f6:	6c42                	ld	s8,16(sp)
    800038f8:	6ca2                	ld	s9,8(sp)
    800038fa:	6125                	addi	sp,sp,96
    800038fc:	8082                	ret
      iunlock(ip);
    800038fe:	8552                	mv	a0,s4
    80003900:	9edff0ef          	jal	800032ec <iunlock>
      return ip;
    80003904:	bff9                	j	800038e2 <namex+0x58>
      iunlockput(ip);
    80003906:	8552                	mv	a0,s4
    80003908:	b41ff0ef          	jal	80003448 <iunlockput>
      return 0;
    8000390c:	8a4e                	mv	s4,s3
    8000390e:	bfd1                	j	800038e2 <namex+0x58>
  len = path - s;
    80003910:	40998633          	sub	a2,s3,s1
    80003914:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003918:	099c5063          	bge	s8,s9,80003998 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    8000391c:	4639                	li	a2,14
    8000391e:	85a6                	mv	a1,s1
    80003920:	8556                	mv	a0,s5
    80003922:	bdcfd0ef          	jal	80000cfe <memmove>
    80003926:	84ce                	mv	s1,s3
  while(*path == '/')
    80003928:	0004c783          	lbu	a5,0(s1)
    8000392c:	01279763          	bne	a5,s2,8000393a <namex+0xb0>
    path++;
    80003930:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003932:	0004c783          	lbu	a5,0(s1)
    80003936:	ff278de3          	beq	a5,s2,80003930 <namex+0xa6>
    ilock(ip);
    8000393a:	8552                	mv	a0,s4
    8000393c:	903ff0ef          	jal	8000323e <ilock>
    if(ip->type != T_DIR){
    80003940:	044a1783          	lh	a5,68(s4)
    80003944:	f9779be3          	bne	a5,s7,800038da <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003948:	000b0563          	beqz	s6,80003952 <namex+0xc8>
    8000394c:	0004c783          	lbu	a5,0(s1)
    80003950:	d7dd                	beqz	a5,800038fe <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003952:	4601                	li	a2,0
    80003954:	85d6                	mv	a1,s5
    80003956:	8552                	mv	a0,s4
    80003958:	e97ff0ef          	jal	800037ee <dirlookup>
    8000395c:	89aa                	mv	s3,a0
    8000395e:	d545                	beqz	a0,80003906 <namex+0x7c>
    iunlockput(ip);
    80003960:	8552                	mv	a0,s4
    80003962:	ae7ff0ef          	jal	80003448 <iunlockput>
    ip = next;
    80003966:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003968:	0004c783          	lbu	a5,0(s1)
    8000396c:	01279763          	bne	a5,s2,8000397a <namex+0xf0>
    path++;
    80003970:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003972:	0004c783          	lbu	a5,0(s1)
    80003976:	ff278de3          	beq	a5,s2,80003970 <namex+0xe6>
  if(*path == 0)
    8000397a:	cb8d                	beqz	a5,800039ac <namex+0x122>
  while(*path != '/' && *path != 0)
    8000397c:	0004c783          	lbu	a5,0(s1)
    80003980:	89a6                	mv	s3,s1
  len = path - s;
    80003982:	4c81                	li	s9,0
    80003984:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003986:	01278963          	beq	a5,s2,80003998 <namex+0x10e>
    8000398a:	d3d9                	beqz	a5,80003910 <namex+0x86>
    path++;
    8000398c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000398e:	0009c783          	lbu	a5,0(s3)
    80003992:	ff279ce3          	bne	a5,s2,8000398a <namex+0x100>
    80003996:	bfad                	j	80003910 <namex+0x86>
    memmove(name, s, len);
    80003998:	2601                	sext.w	a2,a2
    8000399a:	85a6                	mv	a1,s1
    8000399c:	8556                	mv	a0,s5
    8000399e:	b60fd0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    800039a2:	9cd6                	add	s9,s9,s5
    800039a4:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800039a8:	84ce                	mv	s1,s3
    800039aa:	bfbd                	j	80003928 <namex+0x9e>
  if(nameiparent){
    800039ac:	f20b0be3          	beqz	s6,800038e2 <namex+0x58>
    iput(ip);
    800039b0:	8552                	mv	a0,s4
    800039b2:	a0fff0ef          	jal	800033c0 <iput>
    return 0;
    800039b6:	4a01                	li	s4,0
    800039b8:	b72d                	j	800038e2 <namex+0x58>

00000000800039ba <dirlink>:
{
    800039ba:	7139                	addi	sp,sp,-64
    800039bc:	fc06                	sd	ra,56(sp)
    800039be:	f822                	sd	s0,48(sp)
    800039c0:	f04a                	sd	s2,32(sp)
    800039c2:	ec4e                	sd	s3,24(sp)
    800039c4:	e852                	sd	s4,16(sp)
    800039c6:	0080                	addi	s0,sp,64
    800039c8:	892a                	mv	s2,a0
    800039ca:	8a2e                	mv	s4,a1
    800039cc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800039ce:	4601                	li	a2,0
    800039d0:	e1fff0ef          	jal	800037ee <dirlookup>
    800039d4:	e535                	bnez	a0,80003a40 <dirlink+0x86>
    800039d6:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039d8:	04c92483          	lw	s1,76(s2)
    800039dc:	c48d                	beqz	s1,80003a06 <dirlink+0x4c>
    800039de:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039e0:	4741                	li	a4,16
    800039e2:	86a6                	mv	a3,s1
    800039e4:	fc040613          	addi	a2,s0,-64
    800039e8:	4581                	li	a1,0
    800039ea:	854a                	mv	a0,s2
    800039ec:	be3ff0ef          	jal	800035ce <readi>
    800039f0:	47c1                	li	a5,16
    800039f2:	04f51b63          	bne	a0,a5,80003a48 <dirlink+0x8e>
    if(de.inum == 0)
    800039f6:	fc045783          	lhu	a5,-64(s0)
    800039fa:	c791                	beqz	a5,80003a06 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039fc:	24c1                	addiw	s1,s1,16
    800039fe:	04c92783          	lw	a5,76(s2)
    80003a02:	fcf4efe3          	bltu	s1,a5,800039e0 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003a06:	4639                	li	a2,14
    80003a08:	85d2                	mv	a1,s4
    80003a0a:	fc240513          	addi	a0,s0,-62
    80003a0e:	b96fd0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    80003a12:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a16:	4741                	li	a4,16
    80003a18:	86a6                	mv	a3,s1
    80003a1a:	fc040613          	addi	a2,s0,-64
    80003a1e:	4581                	li	a1,0
    80003a20:	854a                	mv	a0,s2
    80003a22:	ca9ff0ef          	jal	800036ca <writei>
    80003a26:	1541                	addi	a0,a0,-16
    80003a28:	00a03533          	snez	a0,a0
    80003a2c:	40a00533          	neg	a0,a0
    80003a30:	74a2                	ld	s1,40(sp)
}
    80003a32:	70e2                	ld	ra,56(sp)
    80003a34:	7442                	ld	s0,48(sp)
    80003a36:	7902                	ld	s2,32(sp)
    80003a38:	69e2                	ld	s3,24(sp)
    80003a3a:	6a42                	ld	s4,16(sp)
    80003a3c:	6121                	addi	sp,sp,64
    80003a3e:	8082                	ret
    iput(ip);
    80003a40:	981ff0ef          	jal	800033c0 <iput>
    return -1;
    80003a44:	557d                	li	a0,-1
    80003a46:	b7f5                	j	80003a32 <dirlink+0x78>
      panic("dirlink read");
    80003a48:	00004517          	auipc	a0,0x4
    80003a4c:	a8050513          	addi	a0,a0,-1408 # 800074c8 <etext+0x4c8>
    80003a50:	d91fc0ef          	jal	800007e0 <panic>

0000000080003a54 <namei>:

struct inode*
namei(char *path)
{
    80003a54:	1101                	addi	sp,sp,-32
    80003a56:	ec06                	sd	ra,24(sp)
    80003a58:	e822                	sd	s0,16(sp)
    80003a5a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003a5c:	fe040613          	addi	a2,s0,-32
    80003a60:	4581                	li	a1,0
    80003a62:	e29ff0ef          	jal	8000388a <namex>
}
    80003a66:	60e2                	ld	ra,24(sp)
    80003a68:	6442                	ld	s0,16(sp)
    80003a6a:	6105                	addi	sp,sp,32
    80003a6c:	8082                	ret

0000000080003a6e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003a6e:	1141                	addi	sp,sp,-16
    80003a70:	e406                	sd	ra,8(sp)
    80003a72:	e022                	sd	s0,0(sp)
    80003a74:	0800                	addi	s0,sp,16
    80003a76:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003a78:	4585                	li	a1,1
    80003a7a:	e11ff0ef          	jal	8000388a <namex>
}
    80003a7e:	60a2                	ld	ra,8(sp)
    80003a80:	6402                	ld	s0,0(sp)
    80003a82:	0141                	addi	sp,sp,16
    80003a84:	8082                	ret

0000000080003a86 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003a86:	1101                	addi	sp,sp,-32
    80003a88:	ec06                	sd	ra,24(sp)
    80003a8a:	e822                	sd	s0,16(sp)
    80003a8c:	e426                	sd	s1,8(sp)
    80003a8e:	e04a                	sd	s2,0(sp)
    80003a90:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003a92:	0001c917          	auipc	s2,0x1c
    80003a96:	0a690913          	addi	s2,s2,166 # 8001fb38 <log>
    80003a9a:	01892583          	lw	a1,24(s2)
    80003a9e:	02492503          	lw	a0,36(s2)
    80003aa2:	8d0ff0ef          	jal	80002b72 <bread>
    80003aa6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003aa8:	02892603          	lw	a2,40(s2)
    80003aac:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003aae:	00c05f63          	blez	a2,80003acc <write_head+0x46>
    80003ab2:	0001c717          	auipc	a4,0x1c
    80003ab6:	0b270713          	addi	a4,a4,178 # 8001fb64 <log+0x2c>
    80003aba:	87aa                	mv	a5,a0
    80003abc:	060a                	slli	a2,a2,0x2
    80003abe:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003ac0:	4314                	lw	a3,0(a4)
    80003ac2:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003ac4:	0711                	addi	a4,a4,4
    80003ac6:	0791                	addi	a5,a5,4
    80003ac8:	fec79ce3          	bne	a5,a2,80003ac0 <write_head+0x3a>
  }
  bwrite(buf);
    80003acc:	8526                	mv	a0,s1
    80003ace:	97aff0ef          	jal	80002c48 <bwrite>
  brelse(buf);
    80003ad2:	8526                	mv	a0,s1
    80003ad4:	9a6ff0ef          	jal	80002c7a <brelse>
}
    80003ad8:	60e2                	ld	ra,24(sp)
    80003ada:	6442                	ld	s0,16(sp)
    80003adc:	64a2                	ld	s1,8(sp)
    80003ade:	6902                	ld	s2,0(sp)
    80003ae0:	6105                	addi	sp,sp,32
    80003ae2:	8082                	ret

0000000080003ae4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ae4:	0001c797          	auipc	a5,0x1c
    80003ae8:	07c7a783          	lw	a5,124(a5) # 8001fb60 <log+0x28>
    80003aec:	0af05e63          	blez	a5,80003ba8 <install_trans+0xc4>
{
    80003af0:	715d                	addi	sp,sp,-80
    80003af2:	e486                	sd	ra,72(sp)
    80003af4:	e0a2                	sd	s0,64(sp)
    80003af6:	fc26                	sd	s1,56(sp)
    80003af8:	f84a                	sd	s2,48(sp)
    80003afa:	f44e                	sd	s3,40(sp)
    80003afc:	f052                	sd	s4,32(sp)
    80003afe:	ec56                	sd	s5,24(sp)
    80003b00:	e85a                	sd	s6,16(sp)
    80003b02:	e45e                	sd	s7,8(sp)
    80003b04:	0880                	addi	s0,sp,80
    80003b06:	8b2a                	mv	s6,a0
    80003b08:	0001ca97          	auipc	s5,0x1c
    80003b0c:	05ca8a93          	addi	s5,s5,92 # 8001fb64 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b10:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b12:	00004b97          	auipc	s7,0x4
    80003b16:	9c6b8b93          	addi	s7,s7,-1594 # 800074d8 <etext+0x4d8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003b1a:	0001ca17          	auipc	s4,0x1c
    80003b1e:	01ea0a13          	addi	s4,s4,30 # 8001fb38 <log>
    80003b22:	a025                	j	80003b4a <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b24:	000aa603          	lw	a2,0(s5)
    80003b28:	85ce                	mv	a1,s3
    80003b2a:	855e                	mv	a0,s7
    80003b2c:	9cffc0ef          	jal	800004fa <printf>
    80003b30:	a839                	j	80003b4e <install_trans+0x6a>
    brelse(lbuf);
    80003b32:	854a                	mv	a0,s2
    80003b34:	946ff0ef          	jal	80002c7a <brelse>
    brelse(dbuf);
    80003b38:	8526                	mv	a0,s1
    80003b3a:	940ff0ef          	jal	80002c7a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b3e:	2985                	addiw	s3,s3,1
    80003b40:	0a91                	addi	s5,s5,4
    80003b42:	028a2783          	lw	a5,40(s4)
    80003b46:	04f9d663          	bge	s3,a5,80003b92 <install_trans+0xae>
    if(recovering) {
    80003b4a:	fc0b1de3          	bnez	s6,80003b24 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003b4e:	018a2583          	lw	a1,24(s4)
    80003b52:	013585bb          	addw	a1,a1,s3
    80003b56:	2585                	addiw	a1,a1,1
    80003b58:	024a2503          	lw	a0,36(s4)
    80003b5c:	816ff0ef          	jal	80002b72 <bread>
    80003b60:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003b62:	000aa583          	lw	a1,0(s5)
    80003b66:	024a2503          	lw	a0,36(s4)
    80003b6a:	808ff0ef          	jal	80002b72 <bread>
    80003b6e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003b70:	40000613          	li	a2,1024
    80003b74:	05890593          	addi	a1,s2,88
    80003b78:	05850513          	addi	a0,a0,88
    80003b7c:	982fd0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    80003b80:	8526                	mv	a0,s1
    80003b82:	8c6ff0ef          	jal	80002c48 <bwrite>
    if(recovering == 0)
    80003b86:	fa0b16e3          	bnez	s6,80003b32 <install_trans+0x4e>
      bunpin(dbuf);
    80003b8a:	8526                	mv	a0,s1
    80003b8c:	9aaff0ef          	jal	80002d36 <bunpin>
    80003b90:	b74d                	j	80003b32 <install_trans+0x4e>
}
    80003b92:	60a6                	ld	ra,72(sp)
    80003b94:	6406                	ld	s0,64(sp)
    80003b96:	74e2                	ld	s1,56(sp)
    80003b98:	7942                	ld	s2,48(sp)
    80003b9a:	79a2                	ld	s3,40(sp)
    80003b9c:	7a02                	ld	s4,32(sp)
    80003b9e:	6ae2                	ld	s5,24(sp)
    80003ba0:	6b42                	ld	s6,16(sp)
    80003ba2:	6ba2                	ld	s7,8(sp)
    80003ba4:	6161                	addi	sp,sp,80
    80003ba6:	8082                	ret
    80003ba8:	8082                	ret

0000000080003baa <initlog>:
{
    80003baa:	7179                	addi	sp,sp,-48
    80003bac:	f406                	sd	ra,40(sp)
    80003bae:	f022                	sd	s0,32(sp)
    80003bb0:	ec26                	sd	s1,24(sp)
    80003bb2:	e84a                	sd	s2,16(sp)
    80003bb4:	e44e                	sd	s3,8(sp)
    80003bb6:	1800                	addi	s0,sp,48
    80003bb8:	892a                	mv	s2,a0
    80003bba:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003bbc:	0001c497          	auipc	s1,0x1c
    80003bc0:	f7c48493          	addi	s1,s1,-132 # 8001fb38 <log>
    80003bc4:	00004597          	auipc	a1,0x4
    80003bc8:	93458593          	addi	a1,a1,-1740 # 800074f8 <etext+0x4f8>
    80003bcc:	8526                	mv	a0,s1
    80003bce:	f81fc0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    80003bd2:	0149a583          	lw	a1,20(s3)
    80003bd6:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003bd8:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003bdc:	854a                	mv	a0,s2
    80003bde:	f95fe0ef          	jal	80002b72 <bread>
  log.lh.n = lh->n;
    80003be2:	4d30                	lw	a2,88(a0)
    80003be4:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003be6:	00c05f63          	blez	a2,80003c04 <initlog+0x5a>
    80003bea:	87aa                	mv	a5,a0
    80003bec:	0001c717          	auipc	a4,0x1c
    80003bf0:	f7870713          	addi	a4,a4,-136 # 8001fb64 <log+0x2c>
    80003bf4:	060a                	slli	a2,a2,0x2
    80003bf6:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003bf8:	4ff4                	lw	a3,92(a5)
    80003bfa:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003bfc:	0791                	addi	a5,a5,4
    80003bfe:	0711                	addi	a4,a4,4
    80003c00:	fec79ce3          	bne	a5,a2,80003bf8 <initlog+0x4e>
  brelse(buf);
    80003c04:	876ff0ef          	jal	80002c7a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003c08:	4505                	li	a0,1
    80003c0a:	edbff0ef          	jal	80003ae4 <install_trans>
  log.lh.n = 0;
    80003c0e:	0001c797          	auipc	a5,0x1c
    80003c12:	f407a923          	sw	zero,-174(a5) # 8001fb60 <log+0x28>
  write_head(); // clear the log
    80003c16:	e71ff0ef          	jal	80003a86 <write_head>
}
    80003c1a:	70a2                	ld	ra,40(sp)
    80003c1c:	7402                	ld	s0,32(sp)
    80003c1e:	64e2                	ld	s1,24(sp)
    80003c20:	6942                	ld	s2,16(sp)
    80003c22:	69a2                	ld	s3,8(sp)
    80003c24:	6145                	addi	sp,sp,48
    80003c26:	8082                	ret

0000000080003c28 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003c28:	1101                	addi	sp,sp,-32
    80003c2a:	ec06                	sd	ra,24(sp)
    80003c2c:	e822                	sd	s0,16(sp)
    80003c2e:	e426                	sd	s1,8(sp)
    80003c30:	e04a                	sd	s2,0(sp)
    80003c32:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003c34:	0001c517          	auipc	a0,0x1c
    80003c38:	f0450513          	addi	a0,a0,-252 # 8001fb38 <log>
    80003c3c:	f93fc0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    80003c40:	0001c497          	auipc	s1,0x1c
    80003c44:	ef848493          	addi	s1,s1,-264 # 8001fb38 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003c48:	4979                	li	s2,30
    80003c4a:	a029                	j	80003c54 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003c4c:	85a6                	mv	a1,s1
    80003c4e:	8526                	mv	a0,s1
    80003c50:	abcfe0ef          	jal	80001f0c <sleep>
    if(log.committing){
    80003c54:	509c                	lw	a5,32(s1)
    80003c56:	fbfd                	bnez	a5,80003c4c <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003c58:	4cd8                	lw	a4,28(s1)
    80003c5a:	2705                	addiw	a4,a4,1
    80003c5c:	0027179b          	slliw	a5,a4,0x2
    80003c60:	9fb9                	addw	a5,a5,a4
    80003c62:	0017979b          	slliw	a5,a5,0x1
    80003c66:	5494                	lw	a3,40(s1)
    80003c68:	9fb5                	addw	a5,a5,a3
    80003c6a:	00f95763          	bge	s2,a5,80003c78 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003c6e:	85a6                	mv	a1,s1
    80003c70:	8526                	mv	a0,s1
    80003c72:	a9afe0ef          	jal	80001f0c <sleep>
    80003c76:	bff9                	j	80003c54 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003c78:	0001c517          	auipc	a0,0x1c
    80003c7c:	ec050513          	addi	a0,a0,-320 # 8001fb38 <log>
    80003c80:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003c82:	fe5fc0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80003c86:	60e2                	ld	ra,24(sp)
    80003c88:	6442                	ld	s0,16(sp)
    80003c8a:	64a2                	ld	s1,8(sp)
    80003c8c:	6902                	ld	s2,0(sp)
    80003c8e:	6105                	addi	sp,sp,32
    80003c90:	8082                	ret

0000000080003c92 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003c92:	7139                	addi	sp,sp,-64
    80003c94:	fc06                	sd	ra,56(sp)
    80003c96:	f822                	sd	s0,48(sp)
    80003c98:	f426                	sd	s1,40(sp)
    80003c9a:	f04a                	sd	s2,32(sp)
    80003c9c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003c9e:	0001c497          	auipc	s1,0x1c
    80003ca2:	e9a48493          	addi	s1,s1,-358 # 8001fb38 <log>
    80003ca6:	8526                	mv	a0,s1
    80003ca8:	f27fc0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80003cac:	4cdc                	lw	a5,28(s1)
    80003cae:	37fd                	addiw	a5,a5,-1
    80003cb0:	0007891b          	sext.w	s2,a5
    80003cb4:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003cb6:	509c                	lw	a5,32(s1)
    80003cb8:	ef9d                	bnez	a5,80003cf6 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003cba:	04091763          	bnez	s2,80003d08 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003cbe:	0001c497          	auipc	s1,0x1c
    80003cc2:	e7a48493          	addi	s1,s1,-390 # 8001fb38 <log>
    80003cc6:	4785                	li	a5,1
    80003cc8:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003cca:	8526                	mv	a0,s1
    80003ccc:	f9bfc0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003cd0:	549c                	lw	a5,40(s1)
    80003cd2:	04f04b63          	bgtz	a5,80003d28 <end_op+0x96>
    acquire(&log.lock);
    80003cd6:	0001c497          	auipc	s1,0x1c
    80003cda:	e6248493          	addi	s1,s1,-414 # 8001fb38 <log>
    80003cde:	8526                	mv	a0,s1
    80003ce0:	eeffc0ef          	jal	80000bce <acquire>
    log.committing = 0;
    80003ce4:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003ce8:	8526                	mv	a0,s1
    80003cea:	a6efe0ef          	jal	80001f58 <wakeup>
    release(&log.lock);
    80003cee:	8526                	mv	a0,s1
    80003cf0:	f77fc0ef          	jal	80000c66 <release>
}
    80003cf4:	a025                	j	80003d1c <end_op+0x8a>
    80003cf6:	ec4e                	sd	s3,24(sp)
    80003cf8:	e852                	sd	s4,16(sp)
    80003cfa:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003cfc:	00004517          	auipc	a0,0x4
    80003d00:	80450513          	addi	a0,a0,-2044 # 80007500 <etext+0x500>
    80003d04:	addfc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80003d08:	0001c497          	auipc	s1,0x1c
    80003d0c:	e3048493          	addi	s1,s1,-464 # 8001fb38 <log>
    80003d10:	8526                	mv	a0,s1
    80003d12:	a46fe0ef          	jal	80001f58 <wakeup>
  release(&log.lock);
    80003d16:	8526                	mv	a0,s1
    80003d18:	f4ffc0ef          	jal	80000c66 <release>
}
    80003d1c:	70e2                	ld	ra,56(sp)
    80003d1e:	7442                	ld	s0,48(sp)
    80003d20:	74a2                	ld	s1,40(sp)
    80003d22:	7902                	ld	s2,32(sp)
    80003d24:	6121                	addi	sp,sp,64
    80003d26:	8082                	ret
    80003d28:	ec4e                	sd	s3,24(sp)
    80003d2a:	e852                	sd	s4,16(sp)
    80003d2c:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d2e:	0001ca97          	auipc	s5,0x1c
    80003d32:	e36a8a93          	addi	s5,s5,-458 # 8001fb64 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003d36:	0001ca17          	auipc	s4,0x1c
    80003d3a:	e02a0a13          	addi	s4,s4,-510 # 8001fb38 <log>
    80003d3e:	018a2583          	lw	a1,24(s4)
    80003d42:	012585bb          	addw	a1,a1,s2
    80003d46:	2585                	addiw	a1,a1,1
    80003d48:	024a2503          	lw	a0,36(s4)
    80003d4c:	e27fe0ef          	jal	80002b72 <bread>
    80003d50:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003d52:	000aa583          	lw	a1,0(s5)
    80003d56:	024a2503          	lw	a0,36(s4)
    80003d5a:	e19fe0ef          	jal	80002b72 <bread>
    80003d5e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003d60:	40000613          	li	a2,1024
    80003d64:	05850593          	addi	a1,a0,88
    80003d68:	05848513          	addi	a0,s1,88
    80003d6c:	f93fc0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    80003d70:	8526                	mv	a0,s1
    80003d72:	ed7fe0ef          	jal	80002c48 <bwrite>
    brelse(from);
    80003d76:	854e                	mv	a0,s3
    80003d78:	f03fe0ef          	jal	80002c7a <brelse>
    brelse(to);
    80003d7c:	8526                	mv	a0,s1
    80003d7e:	efdfe0ef          	jal	80002c7a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d82:	2905                	addiw	s2,s2,1
    80003d84:	0a91                	addi	s5,s5,4
    80003d86:	028a2783          	lw	a5,40(s4)
    80003d8a:	faf94ae3          	blt	s2,a5,80003d3e <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003d8e:	cf9ff0ef          	jal	80003a86 <write_head>
    install_trans(0); // Now install writes to home locations
    80003d92:	4501                	li	a0,0
    80003d94:	d51ff0ef          	jal	80003ae4 <install_trans>
    log.lh.n = 0;
    80003d98:	0001c797          	auipc	a5,0x1c
    80003d9c:	dc07a423          	sw	zero,-568(a5) # 8001fb60 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003da0:	ce7ff0ef          	jal	80003a86 <write_head>
    80003da4:	69e2                	ld	s3,24(sp)
    80003da6:	6a42                	ld	s4,16(sp)
    80003da8:	6aa2                	ld	s5,8(sp)
    80003daa:	b735                	j	80003cd6 <end_op+0x44>

0000000080003dac <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003dac:	1101                	addi	sp,sp,-32
    80003dae:	ec06                	sd	ra,24(sp)
    80003db0:	e822                	sd	s0,16(sp)
    80003db2:	e426                	sd	s1,8(sp)
    80003db4:	e04a                	sd	s2,0(sp)
    80003db6:	1000                	addi	s0,sp,32
    80003db8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003dba:	0001c917          	auipc	s2,0x1c
    80003dbe:	d7e90913          	addi	s2,s2,-642 # 8001fb38 <log>
    80003dc2:	854a                	mv	a0,s2
    80003dc4:	e0bfc0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003dc8:	02892603          	lw	a2,40(s2)
    80003dcc:	47f5                	li	a5,29
    80003dce:	04c7cc63          	blt	a5,a2,80003e26 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003dd2:	0001c797          	auipc	a5,0x1c
    80003dd6:	d827a783          	lw	a5,-638(a5) # 8001fb54 <log+0x1c>
    80003dda:	04f05c63          	blez	a5,80003e32 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003dde:	4781                	li	a5,0
    80003de0:	04c05f63          	blez	a2,80003e3e <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003de4:	44cc                	lw	a1,12(s1)
    80003de6:	0001c717          	auipc	a4,0x1c
    80003dea:	d7e70713          	addi	a4,a4,-642 # 8001fb64 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003dee:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003df0:	4314                	lw	a3,0(a4)
    80003df2:	04b68663          	beq	a3,a1,80003e3e <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003df6:	2785                	addiw	a5,a5,1
    80003df8:	0711                	addi	a4,a4,4
    80003dfa:	fef61be3          	bne	a2,a5,80003df0 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003dfe:	0621                	addi	a2,a2,8
    80003e00:	060a                	slli	a2,a2,0x2
    80003e02:	0001c797          	auipc	a5,0x1c
    80003e06:	d3678793          	addi	a5,a5,-714 # 8001fb38 <log>
    80003e0a:	97b2                	add	a5,a5,a2
    80003e0c:	44d8                	lw	a4,12(s1)
    80003e0e:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003e10:	8526                	mv	a0,s1
    80003e12:	ef1fe0ef          	jal	80002d02 <bpin>
    log.lh.n++;
    80003e16:	0001c717          	auipc	a4,0x1c
    80003e1a:	d2270713          	addi	a4,a4,-734 # 8001fb38 <log>
    80003e1e:	571c                	lw	a5,40(a4)
    80003e20:	2785                	addiw	a5,a5,1
    80003e22:	d71c                	sw	a5,40(a4)
    80003e24:	a80d                	j	80003e56 <log_write+0xaa>
    panic("too big a transaction");
    80003e26:	00003517          	auipc	a0,0x3
    80003e2a:	6ea50513          	addi	a0,a0,1770 # 80007510 <etext+0x510>
    80003e2e:	9b3fc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    80003e32:	00003517          	auipc	a0,0x3
    80003e36:	6f650513          	addi	a0,a0,1782 # 80007528 <etext+0x528>
    80003e3a:	9a7fc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    80003e3e:	00878693          	addi	a3,a5,8
    80003e42:	068a                	slli	a3,a3,0x2
    80003e44:	0001c717          	auipc	a4,0x1c
    80003e48:	cf470713          	addi	a4,a4,-780 # 8001fb38 <log>
    80003e4c:	9736                	add	a4,a4,a3
    80003e4e:	44d4                	lw	a3,12(s1)
    80003e50:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003e52:	faf60fe3          	beq	a2,a5,80003e10 <log_write+0x64>
  }
  release(&log.lock);
    80003e56:	0001c517          	auipc	a0,0x1c
    80003e5a:	ce250513          	addi	a0,a0,-798 # 8001fb38 <log>
    80003e5e:	e09fc0ef          	jal	80000c66 <release>
}
    80003e62:	60e2                	ld	ra,24(sp)
    80003e64:	6442                	ld	s0,16(sp)
    80003e66:	64a2                	ld	s1,8(sp)
    80003e68:	6902                	ld	s2,0(sp)
    80003e6a:	6105                	addi	sp,sp,32
    80003e6c:	8082                	ret

0000000080003e6e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003e6e:	1101                	addi	sp,sp,-32
    80003e70:	ec06                	sd	ra,24(sp)
    80003e72:	e822                	sd	s0,16(sp)
    80003e74:	e426                	sd	s1,8(sp)
    80003e76:	e04a                	sd	s2,0(sp)
    80003e78:	1000                	addi	s0,sp,32
    80003e7a:	84aa                	mv	s1,a0
    80003e7c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003e7e:	00003597          	auipc	a1,0x3
    80003e82:	6ca58593          	addi	a1,a1,1738 # 80007548 <etext+0x548>
    80003e86:	0521                	addi	a0,a0,8
    80003e88:	cc7fc0ef          	jal	80000b4e <initlock>
  lk->name = name;
    80003e8c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003e90:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003e94:	0204a423          	sw	zero,40(s1)
}
    80003e98:	60e2                	ld	ra,24(sp)
    80003e9a:	6442                	ld	s0,16(sp)
    80003e9c:	64a2                	ld	s1,8(sp)
    80003e9e:	6902                	ld	s2,0(sp)
    80003ea0:	6105                	addi	sp,sp,32
    80003ea2:	8082                	ret

0000000080003ea4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003ea4:	1101                	addi	sp,sp,-32
    80003ea6:	ec06                	sd	ra,24(sp)
    80003ea8:	e822                	sd	s0,16(sp)
    80003eaa:	e426                	sd	s1,8(sp)
    80003eac:	e04a                	sd	s2,0(sp)
    80003eae:	1000                	addi	s0,sp,32
    80003eb0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003eb2:	00850913          	addi	s2,a0,8
    80003eb6:	854a                	mv	a0,s2
    80003eb8:	d17fc0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    80003ebc:	409c                	lw	a5,0(s1)
    80003ebe:	c799                	beqz	a5,80003ecc <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003ec0:	85ca                	mv	a1,s2
    80003ec2:	8526                	mv	a0,s1
    80003ec4:	848fe0ef          	jal	80001f0c <sleep>
  while (lk->locked) {
    80003ec8:	409c                	lw	a5,0(s1)
    80003eca:	fbfd                	bnez	a5,80003ec0 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003ecc:	4785                	li	a5,1
    80003ece:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003ed0:	9fffd0ef          	jal	800018ce <myproc>
    80003ed4:	591c                	lw	a5,48(a0)
    80003ed6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003ed8:	854a                	mv	a0,s2
    80003eda:	d8dfc0ef          	jal	80000c66 <release>
}
    80003ede:	60e2                	ld	ra,24(sp)
    80003ee0:	6442                	ld	s0,16(sp)
    80003ee2:	64a2                	ld	s1,8(sp)
    80003ee4:	6902                	ld	s2,0(sp)
    80003ee6:	6105                	addi	sp,sp,32
    80003ee8:	8082                	ret

0000000080003eea <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003eea:	1101                	addi	sp,sp,-32
    80003eec:	ec06                	sd	ra,24(sp)
    80003eee:	e822                	sd	s0,16(sp)
    80003ef0:	e426                	sd	s1,8(sp)
    80003ef2:	e04a                	sd	s2,0(sp)
    80003ef4:	1000                	addi	s0,sp,32
    80003ef6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003ef8:	00850913          	addi	s2,a0,8
    80003efc:	854a                	mv	a0,s2
    80003efe:	cd1fc0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    80003f02:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f06:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003f0a:	8526                	mv	a0,s1
    80003f0c:	84cfe0ef          	jal	80001f58 <wakeup>
  release(&lk->lk);
    80003f10:	854a                	mv	a0,s2
    80003f12:	d55fc0ef          	jal	80000c66 <release>
}
    80003f16:	60e2                	ld	ra,24(sp)
    80003f18:	6442                	ld	s0,16(sp)
    80003f1a:	64a2                	ld	s1,8(sp)
    80003f1c:	6902                	ld	s2,0(sp)
    80003f1e:	6105                	addi	sp,sp,32
    80003f20:	8082                	ret

0000000080003f22 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003f22:	7179                	addi	sp,sp,-48
    80003f24:	f406                	sd	ra,40(sp)
    80003f26:	f022                	sd	s0,32(sp)
    80003f28:	ec26                	sd	s1,24(sp)
    80003f2a:	e84a                	sd	s2,16(sp)
    80003f2c:	1800                	addi	s0,sp,48
    80003f2e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003f30:	00850913          	addi	s2,a0,8
    80003f34:	854a                	mv	a0,s2
    80003f36:	c99fc0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003f3a:	409c                	lw	a5,0(s1)
    80003f3c:	ef81                	bnez	a5,80003f54 <holdingsleep+0x32>
    80003f3e:	4481                	li	s1,0
  release(&lk->lk);
    80003f40:	854a                	mv	a0,s2
    80003f42:	d25fc0ef          	jal	80000c66 <release>
  return r;
}
    80003f46:	8526                	mv	a0,s1
    80003f48:	70a2                	ld	ra,40(sp)
    80003f4a:	7402                	ld	s0,32(sp)
    80003f4c:	64e2                	ld	s1,24(sp)
    80003f4e:	6942                	ld	s2,16(sp)
    80003f50:	6145                	addi	sp,sp,48
    80003f52:	8082                	ret
    80003f54:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003f56:	0284a983          	lw	s3,40(s1)
    80003f5a:	975fd0ef          	jal	800018ce <myproc>
    80003f5e:	5904                	lw	s1,48(a0)
    80003f60:	413484b3          	sub	s1,s1,s3
    80003f64:	0014b493          	seqz	s1,s1
    80003f68:	69a2                	ld	s3,8(sp)
    80003f6a:	bfd9                	j	80003f40 <holdingsleep+0x1e>

0000000080003f6c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003f6c:	1141                	addi	sp,sp,-16
    80003f6e:	e406                	sd	ra,8(sp)
    80003f70:	e022                	sd	s0,0(sp)
    80003f72:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003f74:	00003597          	auipc	a1,0x3
    80003f78:	5e458593          	addi	a1,a1,1508 # 80007558 <etext+0x558>
    80003f7c:	0001c517          	auipc	a0,0x1c
    80003f80:	d0450513          	addi	a0,a0,-764 # 8001fc80 <ftable>
    80003f84:	bcbfc0ef          	jal	80000b4e <initlock>
}
    80003f88:	60a2                	ld	ra,8(sp)
    80003f8a:	6402                	ld	s0,0(sp)
    80003f8c:	0141                	addi	sp,sp,16
    80003f8e:	8082                	ret

0000000080003f90 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003f90:	1101                	addi	sp,sp,-32
    80003f92:	ec06                	sd	ra,24(sp)
    80003f94:	e822                	sd	s0,16(sp)
    80003f96:	e426                	sd	s1,8(sp)
    80003f98:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003f9a:	0001c517          	auipc	a0,0x1c
    80003f9e:	ce650513          	addi	a0,a0,-794 # 8001fc80 <ftable>
    80003fa2:	c2dfc0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003fa6:	0001c497          	auipc	s1,0x1c
    80003faa:	cf248493          	addi	s1,s1,-782 # 8001fc98 <ftable+0x18>
    80003fae:	0001d717          	auipc	a4,0x1d
    80003fb2:	c8a70713          	addi	a4,a4,-886 # 80020c38 <disk>
    if(f->ref == 0){
    80003fb6:	40dc                	lw	a5,4(s1)
    80003fb8:	cf89                	beqz	a5,80003fd2 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003fba:	02848493          	addi	s1,s1,40
    80003fbe:	fee49ce3          	bne	s1,a4,80003fb6 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003fc2:	0001c517          	auipc	a0,0x1c
    80003fc6:	cbe50513          	addi	a0,a0,-834 # 8001fc80 <ftable>
    80003fca:	c9dfc0ef          	jal	80000c66 <release>
  return 0;
    80003fce:	4481                	li	s1,0
    80003fd0:	a809                	j	80003fe2 <filealloc+0x52>
      f->ref = 1;
    80003fd2:	4785                	li	a5,1
    80003fd4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003fd6:	0001c517          	auipc	a0,0x1c
    80003fda:	caa50513          	addi	a0,a0,-854 # 8001fc80 <ftable>
    80003fde:	c89fc0ef          	jal	80000c66 <release>
}
    80003fe2:	8526                	mv	a0,s1
    80003fe4:	60e2                	ld	ra,24(sp)
    80003fe6:	6442                	ld	s0,16(sp)
    80003fe8:	64a2                	ld	s1,8(sp)
    80003fea:	6105                	addi	sp,sp,32
    80003fec:	8082                	ret

0000000080003fee <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003fee:	1101                	addi	sp,sp,-32
    80003ff0:	ec06                	sd	ra,24(sp)
    80003ff2:	e822                	sd	s0,16(sp)
    80003ff4:	e426                	sd	s1,8(sp)
    80003ff6:	1000                	addi	s0,sp,32
    80003ff8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003ffa:	0001c517          	auipc	a0,0x1c
    80003ffe:	c8650513          	addi	a0,a0,-890 # 8001fc80 <ftable>
    80004002:	bcdfc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80004006:	40dc                	lw	a5,4(s1)
    80004008:	02f05063          	blez	a5,80004028 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000400c:	2785                	addiw	a5,a5,1
    8000400e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004010:	0001c517          	auipc	a0,0x1c
    80004014:	c7050513          	addi	a0,a0,-912 # 8001fc80 <ftable>
    80004018:	c4ffc0ef          	jal	80000c66 <release>
  return f;
}
    8000401c:	8526                	mv	a0,s1
    8000401e:	60e2                	ld	ra,24(sp)
    80004020:	6442                	ld	s0,16(sp)
    80004022:	64a2                	ld	s1,8(sp)
    80004024:	6105                	addi	sp,sp,32
    80004026:	8082                	ret
    panic("filedup");
    80004028:	00003517          	auipc	a0,0x3
    8000402c:	53850513          	addi	a0,a0,1336 # 80007560 <etext+0x560>
    80004030:	fb0fc0ef          	jal	800007e0 <panic>

0000000080004034 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004034:	7139                	addi	sp,sp,-64
    80004036:	fc06                	sd	ra,56(sp)
    80004038:	f822                	sd	s0,48(sp)
    8000403a:	f426                	sd	s1,40(sp)
    8000403c:	0080                	addi	s0,sp,64
    8000403e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004040:	0001c517          	auipc	a0,0x1c
    80004044:	c4050513          	addi	a0,a0,-960 # 8001fc80 <ftable>
    80004048:	b87fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    8000404c:	40dc                	lw	a5,4(s1)
    8000404e:	04f05a63          	blez	a5,800040a2 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004052:	37fd                	addiw	a5,a5,-1
    80004054:	0007871b          	sext.w	a4,a5
    80004058:	c0dc                	sw	a5,4(s1)
    8000405a:	04e04e63          	bgtz	a4,800040b6 <fileclose+0x82>
    8000405e:	f04a                	sd	s2,32(sp)
    80004060:	ec4e                	sd	s3,24(sp)
    80004062:	e852                	sd	s4,16(sp)
    80004064:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004066:	0004a903          	lw	s2,0(s1)
    8000406a:	0094ca83          	lbu	s5,9(s1)
    8000406e:	0104ba03          	ld	s4,16(s1)
    80004072:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004076:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000407a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000407e:	0001c517          	auipc	a0,0x1c
    80004082:	c0250513          	addi	a0,a0,-1022 # 8001fc80 <ftable>
    80004086:	be1fc0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    8000408a:	4785                	li	a5,1
    8000408c:	04f90063          	beq	s2,a5,800040cc <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004090:	3979                	addiw	s2,s2,-2
    80004092:	4785                	li	a5,1
    80004094:	0527f563          	bgeu	a5,s2,800040de <fileclose+0xaa>
    80004098:	7902                	ld	s2,32(sp)
    8000409a:	69e2                	ld	s3,24(sp)
    8000409c:	6a42                	ld	s4,16(sp)
    8000409e:	6aa2                	ld	s5,8(sp)
    800040a0:	a00d                	j	800040c2 <fileclose+0x8e>
    800040a2:	f04a                	sd	s2,32(sp)
    800040a4:	ec4e                	sd	s3,24(sp)
    800040a6:	e852                	sd	s4,16(sp)
    800040a8:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800040aa:	00003517          	auipc	a0,0x3
    800040ae:	4be50513          	addi	a0,a0,1214 # 80007568 <etext+0x568>
    800040b2:	f2efc0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    800040b6:	0001c517          	auipc	a0,0x1c
    800040ba:	bca50513          	addi	a0,a0,-1078 # 8001fc80 <ftable>
    800040be:	ba9fc0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800040c2:	70e2                	ld	ra,56(sp)
    800040c4:	7442                	ld	s0,48(sp)
    800040c6:	74a2                	ld	s1,40(sp)
    800040c8:	6121                	addi	sp,sp,64
    800040ca:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800040cc:	85d6                	mv	a1,s5
    800040ce:	8552                	mv	a0,s4
    800040d0:	336000ef          	jal	80004406 <pipeclose>
    800040d4:	7902                	ld	s2,32(sp)
    800040d6:	69e2                	ld	s3,24(sp)
    800040d8:	6a42                	ld	s4,16(sp)
    800040da:	6aa2                	ld	s5,8(sp)
    800040dc:	b7dd                	j	800040c2 <fileclose+0x8e>
    begin_op();
    800040de:	b4bff0ef          	jal	80003c28 <begin_op>
    iput(ff.ip);
    800040e2:	854e                	mv	a0,s3
    800040e4:	adcff0ef          	jal	800033c0 <iput>
    end_op();
    800040e8:	babff0ef          	jal	80003c92 <end_op>
    800040ec:	7902                	ld	s2,32(sp)
    800040ee:	69e2                	ld	s3,24(sp)
    800040f0:	6a42                	ld	s4,16(sp)
    800040f2:	6aa2                	ld	s5,8(sp)
    800040f4:	b7f9                	j	800040c2 <fileclose+0x8e>

00000000800040f6 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800040f6:	715d                	addi	sp,sp,-80
    800040f8:	e486                	sd	ra,72(sp)
    800040fa:	e0a2                	sd	s0,64(sp)
    800040fc:	fc26                	sd	s1,56(sp)
    800040fe:	f44e                	sd	s3,40(sp)
    80004100:	0880                	addi	s0,sp,80
    80004102:	84aa                	mv	s1,a0
    80004104:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004106:	fc8fd0ef          	jal	800018ce <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000410a:	409c                	lw	a5,0(s1)
    8000410c:	37f9                	addiw	a5,a5,-2
    8000410e:	4705                	li	a4,1
    80004110:	04f76063          	bltu	a4,a5,80004150 <filestat+0x5a>
    80004114:	f84a                	sd	s2,48(sp)
    80004116:	892a                	mv	s2,a0
    ilock(f->ip);
    80004118:	6c88                	ld	a0,24(s1)
    8000411a:	924ff0ef          	jal	8000323e <ilock>
    stati(f->ip, &st);
    8000411e:	fb840593          	addi	a1,s0,-72
    80004122:	6c88                	ld	a0,24(s1)
    80004124:	c80ff0ef          	jal	800035a4 <stati>
    iunlock(f->ip);
    80004128:	6c88                	ld	a0,24(s1)
    8000412a:	9c2ff0ef          	jal	800032ec <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000412e:	46e1                	li	a3,24
    80004130:	fb840613          	addi	a2,s0,-72
    80004134:	85ce                	mv	a1,s3
    80004136:	05093503          	ld	a0,80(s2)
    8000413a:	ca8fd0ef          	jal	800015e2 <copyout>
    8000413e:	41f5551b          	sraiw	a0,a0,0x1f
    80004142:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004144:	60a6                	ld	ra,72(sp)
    80004146:	6406                	ld	s0,64(sp)
    80004148:	74e2                	ld	s1,56(sp)
    8000414a:	79a2                	ld	s3,40(sp)
    8000414c:	6161                	addi	sp,sp,80
    8000414e:	8082                	ret
  return -1;
    80004150:	557d                	li	a0,-1
    80004152:	bfcd                	j	80004144 <filestat+0x4e>

0000000080004154 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004154:	7179                	addi	sp,sp,-48
    80004156:	f406                	sd	ra,40(sp)
    80004158:	f022                	sd	s0,32(sp)
    8000415a:	e84a                	sd	s2,16(sp)
    8000415c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000415e:	00854783          	lbu	a5,8(a0)
    80004162:	cfd1                	beqz	a5,800041fe <fileread+0xaa>
    80004164:	ec26                	sd	s1,24(sp)
    80004166:	e44e                	sd	s3,8(sp)
    80004168:	84aa                	mv	s1,a0
    8000416a:	89ae                	mv	s3,a1
    8000416c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000416e:	411c                	lw	a5,0(a0)
    80004170:	4705                	li	a4,1
    80004172:	04e78363          	beq	a5,a4,800041b8 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004176:	470d                	li	a4,3
    80004178:	04e78763          	beq	a5,a4,800041c6 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000417c:	4709                	li	a4,2
    8000417e:	06e79a63          	bne	a5,a4,800041f2 <fileread+0x9e>
    ilock(f->ip);
    80004182:	6d08                	ld	a0,24(a0)
    80004184:	8baff0ef          	jal	8000323e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004188:	874a                	mv	a4,s2
    8000418a:	5094                	lw	a3,32(s1)
    8000418c:	864e                	mv	a2,s3
    8000418e:	4585                	li	a1,1
    80004190:	6c88                	ld	a0,24(s1)
    80004192:	c3cff0ef          	jal	800035ce <readi>
    80004196:	892a                	mv	s2,a0
    80004198:	00a05563          	blez	a0,800041a2 <fileread+0x4e>
      f->off += r;
    8000419c:	509c                	lw	a5,32(s1)
    8000419e:	9fa9                	addw	a5,a5,a0
    800041a0:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800041a2:	6c88                	ld	a0,24(s1)
    800041a4:	948ff0ef          	jal	800032ec <iunlock>
    800041a8:	64e2                	ld	s1,24(sp)
    800041aa:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800041ac:	854a                	mv	a0,s2
    800041ae:	70a2                	ld	ra,40(sp)
    800041b0:	7402                	ld	s0,32(sp)
    800041b2:	6942                	ld	s2,16(sp)
    800041b4:	6145                	addi	sp,sp,48
    800041b6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800041b8:	6908                	ld	a0,16(a0)
    800041ba:	388000ef          	jal	80004542 <piperead>
    800041be:	892a                	mv	s2,a0
    800041c0:	64e2                	ld	s1,24(sp)
    800041c2:	69a2                	ld	s3,8(sp)
    800041c4:	b7e5                	j	800041ac <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800041c6:	02451783          	lh	a5,36(a0)
    800041ca:	03079693          	slli	a3,a5,0x30
    800041ce:	92c1                	srli	a3,a3,0x30
    800041d0:	4725                	li	a4,9
    800041d2:	02d76863          	bltu	a4,a3,80004202 <fileread+0xae>
    800041d6:	0792                	slli	a5,a5,0x4
    800041d8:	0001c717          	auipc	a4,0x1c
    800041dc:	a0870713          	addi	a4,a4,-1528 # 8001fbe0 <devsw>
    800041e0:	97ba                	add	a5,a5,a4
    800041e2:	639c                	ld	a5,0(a5)
    800041e4:	c39d                	beqz	a5,8000420a <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800041e6:	4505                	li	a0,1
    800041e8:	9782                	jalr	a5
    800041ea:	892a                	mv	s2,a0
    800041ec:	64e2                	ld	s1,24(sp)
    800041ee:	69a2                	ld	s3,8(sp)
    800041f0:	bf75                	j	800041ac <fileread+0x58>
    panic("fileread");
    800041f2:	00003517          	auipc	a0,0x3
    800041f6:	38650513          	addi	a0,a0,902 # 80007578 <etext+0x578>
    800041fa:	de6fc0ef          	jal	800007e0 <panic>
    return -1;
    800041fe:	597d                	li	s2,-1
    80004200:	b775                	j	800041ac <fileread+0x58>
      return -1;
    80004202:	597d                	li	s2,-1
    80004204:	64e2                	ld	s1,24(sp)
    80004206:	69a2                	ld	s3,8(sp)
    80004208:	b755                	j	800041ac <fileread+0x58>
    8000420a:	597d                	li	s2,-1
    8000420c:	64e2                	ld	s1,24(sp)
    8000420e:	69a2                	ld	s3,8(sp)
    80004210:	bf71                	j	800041ac <fileread+0x58>

0000000080004212 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004212:	00954783          	lbu	a5,9(a0)
    80004216:	10078b63          	beqz	a5,8000432c <filewrite+0x11a>
{
    8000421a:	715d                	addi	sp,sp,-80
    8000421c:	e486                	sd	ra,72(sp)
    8000421e:	e0a2                	sd	s0,64(sp)
    80004220:	f84a                	sd	s2,48(sp)
    80004222:	f052                	sd	s4,32(sp)
    80004224:	e85a                	sd	s6,16(sp)
    80004226:	0880                	addi	s0,sp,80
    80004228:	892a                	mv	s2,a0
    8000422a:	8b2e                	mv	s6,a1
    8000422c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000422e:	411c                	lw	a5,0(a0)
    80004230:	4705                	li	a4,1
    80004232:	02e78763          	beq	a5,a4,80004260 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004236:	470d                	li	a4,3
    80004238:	02e78863          	beq	a5,a4,80004268 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000423c:	4709                	li	a4,2
    8000423e:	0ce79c63          	bne	a5,a4,80004316 <filewrite+0x104>
    80004242:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004244:	0ac05863          	blez	a2,800042f4 <filewrite+0xe2>
    80004248:	fc26                	sd	s1,56(sp)
    8000424a:	ec56                	sd	s5,24(sp)
    8000424c:	e45e                	sd	s7,8(sp)
    8000424e:	e062                	sd	s8,0(sp)
    int i = 0;
    80004250:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004252:	6b85                	lui	s7,0x1
    80004254:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004258:	6c05                	lui	s8,0x1
    8000425a:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000425e:	a8b5                	j	800042da <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004260:	6908                	ld	a0,16(a0)
    80004262:	1fc000ef          	jal	8000445e <pipewrite>
    80004266:	a04d                	j	80004308 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004268:	02451783          	lh	a5,36(a0)
    8000426c:	03079693          	slli	a3,a5,0x30
    80004270:	92c1                	srli	a3,a3,0x30
    80004272:	4725                	li	a4,9
    80004274:	0ad76e63          	bltu	a4,a3,80004330 <filewrite+0x11e>
    80004278:	0792                	slli	a5,a5,0x4
    8000427a:	0001c717          	auipc	a4,0x1c
    8000427e:	96670713          	addi	a4,a4,-1690 # 8001fbe0 <devsw>
    80004282:	97ba                	add	a5,a5,a4
    80004284:	679c                	ld	a5,8(a5)
    80004286:	c7dd                	beqz	a5,80004334 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004288:	4505                	li	a0,1
    8000428a:	9782                	jalr	a5
    8000428c:	a8b5                	j	80004308 <filewrite+0xf6>
      if(n1 > max)
    8000428e:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004292:	997ff0ef          	jal	80003c28 <begin_op>
      ilock(f->ip);
    80004296:	01893503          	ld	a0,24(s2)
    8000429a:	fa5fe0ef          	jal	8000323e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000429e:	8756                	mv	a4,s5
    800042a0:	02092683          	lw	a3,32(s2)
    800042a4:	01698633          	add	a2,s3,s6
    800042a8:	4585                	li	a1,1
    800042aa:	01893503          	ld	a0,24(s2)
    800042ae:	c1cff0ef          	jal	800036ca <writei>
    800042b2:	84aa                	mv	s1,a0
    800042b4:	00a05763          	blez	a0,800042c2 <filewrite+0xb0>
        f->off += r;
    800042b8:	02092783          	lw	a5,32(s2)
    800042bc:	9fa9                	addw	a5,a5,a0
    800042be:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800042c2:	01893503          	ld	a0,24(s2)
    800042c6:	826ff0ef          	jal	800032ec <iunlock>
      end_op();
    800042ca:	9c9ff0ef          	jal	80003c92 <end_op>

      if(r != n1){
    800042ce:	029a9563          	bne	s5,s1,800042f8 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800042d2:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800042d6:	0149da63          	bge	s3,s4,800042ea <filewrite+0xd8>
      int n1 = n - i;
    800042da:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800042de:	0004879b          	sext.w	a5,s1
    800042e2:	fafbd6e3          	bge	s7,a5,8000428e <filewrite+0x7c>
    800042e6:	84e2                	mv	s1,s8
    800042e8:	b75d                	j	8000428e <filewrite+0x7c>
    800042ea:	74e2                	ld	s1,56(sp)
    800042ec:	6ae2                	ld	s5,24(sp)
    800042ee:	6ba2                	ld	s7,8(sp)
    800042f0:	6c02                	ld	s8,0(sp)
    800042f2:	a039                	j	80004300 <filewrite+0xee>
    int i = 0;
    800042f4:	4981                	li	s3,0
    800042f6:	a029                	j	80004300 <filewrite+0xee>
    800042f8:	74e2                	ld	s1,56(sp)
    800042fa:	6ae2                	ld	s5,24(sp)
    800042fc:	6ba2                	ld	s7,8(sp)
    800042fe:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004300:	033a1c63          	bne	s4,s3,80004338 <filewrite+0x126>
    80004304:	8552                	mv	a0,s4
    80004306:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004308:	60a6                	ld	ra,72(sp)
    8000430a:	6406                	ld	s0,64(sp)
    8000430c:	7942                	ld	s2,48(sp)
    8000430e:	7a02                	ld	s4,32(sp)
    80004310:	6b42                	ld	s6,16(sp)
    80004312:	6161                	addi	sp,sp,80
    80004314:	8082                	ret
    80004316:	fc26                	sd	s1,56(sp)
    80004318:	f44e                	sd	s3,40(sp)
    8000431a:	ec56                	sd	s5,24(sp)
    8000431c:	e45e                	sd	s7,8(sp)
    8000431e:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004320:	00003517          	auipc	a0,0x3
    80004324:	26850513          	addi	a0,a0,616 # 80007588 <etext+0x588>
    80004328:	cb8fc0ef          	jal	800007e0 <panic>
    return -1;
    8000432c:	557d                	li	a0,-1
}
    8000432e:	8082                	ret
      return -1;
    80004330:	557d                	li	a0,-1
    80004332:	bfd9                	j	80004308 <filewrite+0xf6>
    80004334:	557d                	li	a0,-1
    80004336:	bfc9                	j	80004308 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004338:	557d                	li	a0,-1
    8000433a:	79a2                	ld	s3,40(sp)
    8000433c:	b7f1                	j	80004308 <filewrite+0xf6>

000000008000433e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000433e:	7179                	addi	sp,sp,-48
    80004340:	f406                	sd	ra,40(sp)
    80004342:	f022                	sd	s0,32(sp)
    80004344:	ec26                	sd	s1,24(sp)
    80004346:	e052                	sd	s4,0(sp)
    80004348:	1800                	addi	s0,sp,48
    8000434a:	84aa                	mv	s1,a0
    8000434c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000434e:	0005b023          	sd	zero,0(a1)
    80004352:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004356:	c3bff0ef          	jal	80003f90 <filealloc>
    8000435a:	e088                	sd	a0,0(s1)
    8000435c:	c549                	beqz	a0,800043e6 <pipealloc+0xa8>
    8000435e:	c33ff0ef          	jal	80003f90 <filealloc>
    80004362:	00aa3023          	sd	a0,0(s4)
    80004366:	cd25                	beqz	a0,800043de <pipealloc+0xa0>
    80004368:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000436a:	f94fc0ef          	jal	80000afe <kalloc>
    8000436e:	892a                	mv	s2,a0
    80004370:	c12d                	beqz	a0,800043d2 <pipealloc+0x94>
    80004372:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004374:	4985                	li	s3,1
    80004376:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000437a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000437e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004382:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004386:	00003597          	auipc	a1,0x3
    8000438a:	21258593          	addi	a1,a1,530 # 80007598 <etext+0x598>
    8000438e:	fc0fc0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    80004392:	609c                	ld	a5,0(s1)
    80004394:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004398:	609c                	ld	a5,0(s1)
    8000439a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000439e:	609c                	ld	a5,0(s1)
    800043a0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800043a4:	609c                	ld	a5,0(s1)
    800043a6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800043aa:	000a3783          	ld	a5,0(s4)
    800043ae:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800043b2:	000a3783          	ld	a5,0(s4)
    800043b6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800043ba:	000a3783          	ld	a5,0(s4)
    800043be:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800043c2:	000a3783          	ld	a5,0(s4)
    800043c6:	0127b823          	sd	s2,16(a5)
  return 0;
    800043ca:	4501                	li	a0,0
    800043cc:	6942                	ld	s2,16(sp)
    800043ce:	69a2                	ld	s3,8(sp)
    800043d0:	a01d                	j	800043f6 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800043d2:	6088                	ld	a0,0(s1)
    800043d4:	c119                	beqz	a0,800043da <pipealloc+0x9c>
    800043d6:	6942                	ld	s2,16(sp)
    800043d8:	a029                	j	800043e2 <pipealloc+0xa4>
    800043da:	6942                	ld	s2,16(sp)
    800043dc:	a029                	j	800043e6 <pipealloc+0xa8>
    800043de:	6088                	ld	a0,0(s1)
    800043e0:	c10d                	beqz	a0,80004402 <pipealloc+0xc4>
    fileclose(*f0);
    800043e2:	c53ff0ef          	jal	80004034 <fileclose>
  if(*f1)
    800043e6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800043ea:	557d                	li	a0,-1
  if(*f1)
    800043ec:	c789                	beqz	a5,800043f6 <pipealloc+0xb8>
    fileclose(*f1);
    800043ee:	853e                	mv	a0,a5
    800043f0:	c45ff0ef          	jal	80004034 <fileclose>
  return -1;
    800043f4:	557d                	li	a0,-1
}
    800043f6:	70a2                	ld	ra,40(sp)
    800043f8:	7402                	ld	s0,32(sp)
    800043fa:	64e2                	ld	s1,24(sp)
    800043fc:	6a02                	ld	s4,0(sp)
    800043fe:	6145                	addi	sp,sp,48
    80004400:	8082                	ret
  return -1;
    80004402:	557d                	li	a0,-1
    80004404:	bfcd                	j	800043f6 <pipealloc+0xb8>

0000000080004406 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004406:	1101                	addi	sp,sp,-32
    80004408:	ec06                	sd	ra,24(sp)
    8000440a:	e822                	sd	s0,16(sp)
    8000440c:	e426                	sd	s1,8(sp)
    8000440e:	e04a                	sd	s2,0(sp)
    80004410:	1000                	addi	s0,sp,32
    80004412:	84aa                	mv	s1,a0
    80004414:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004416:	fb8fc0ef          	jal	80000bce <acquire>
  if(writable){
    8000441a:	02090763          	beqz	s2,80004448 <pipeclose+0x42>
    pi->writeopen = 0;
    8000441e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004422:	21848513          	addi	a0,s1,536
    80004426:	b33fd0ef          	jal	80001f58 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000442a:	2204b783          	ld	a5,544(s1)
    8000442e:	e785                	bnez	a5,80004456 <pipeclose+0x50>
    release(&pi->lock);
    80004430:	8526                	mv	a0,s1
    80004432:	835fc0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    80004436:	8526                	mv	a0,s1
    80004438:	de4fc0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    8000443c:	60e2                	ld	ra,24(sp)
    8000443e:	6442                	ld	s0,16(sp)
    80004440:	64a2                	ld	s1,8(sp)
    80004442:	6902                	ld	s2,0(sp)
    80004444:	6105                	addi	sp,sp,32
    80004446:	8082                	ret
    pi->readopen = 0;
    80004448:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000444c:	21c48513          	addi	a0,s1,540
    80004450:	b09fd0ef          	jal	80001f58 <wakeup>
    80004454:	bfd9                	j	8000442a <pipeclose+0x24>
    release(&pi->lock);
    80004456:	8526                	mv	a0,s1
    80004458:	80ffc0ef          	jal	80000c66 <release>
}
    8000445c:	b7c5                	j	8000443c <pipeclose+0x36>

000000008000445e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000445e:	711d                	addi	sp,sp,-96
    80004460:	ec86                	sd	ra,88(sp)
    80004462:	e8a2                	sd	s0,80(sp)
    80004464:	e4a6                	sd	s1,72(sp)
    80004466:	e0ca                	sd	s2,64(sp)
    80004468:	fc4e                	sd	s3,56(sp)
    8000446a:	f852                	sd	s4,48(sp)
    8000446c:	f456                	sd	s5,40(sp)
    8000446e:	1080                	addi	s0,sp,96
    80004470:	84aa                	mv	s1,a0
    80004472:	8aae                	mv	s5,a1
    80004474:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004476:	c58fd0ef          	jal	800018ce <myproc>
    8000447a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000447c:	8526                	mv	a0,s1
    8000447e:	f50fc0ef          	jal	80000bce <acquire>
  while(i < n){
    80004482:	0b405a63          	blez	s4,80004536 <pipewrite+0xd8>
    80004486:	f05a                	sd	s6,32(sp)
    80004488:	ec5e                	sd	s7,24(sp)
    8000448a:	e862                	sd	s8,16(sp)
  int i = 0;
    8000448c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000448e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004490:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004494:	21c48b93          	addi	s7,s1,540
    80004498:	a81d                	j	800044ce <pipewrite+0x70>
      release(&pi->lock);
    8000449a:	8526                	mv	a0,s1
    8000449c:	fcafc0ef          	jal	80000c66 <release>
      return -1;
    800044a0:	597d                	li	s2,-1
    800044a2:	7b02                	ld	s6,32(sp)
    800044a4:	6be2                	ld	s7,24(sp)
    800044a6:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800044a8:	854a                	mv	a0,s2
    800044aa:	60e6                	ld	ra,88(sp)
    800044ac:	6446                	ld	s0,80(sp)
    800044ae:	64a6                	ld	s1,72(sp)
    800044b0:	6906                	ld	s2,64(sp)
    800044b2:	79e2                	ld	s3,56(sp)
    800044b4:	7a42                	ld	s4,48(sp)
    800044b6:	7aa2                	ld	s5,40(sp)
    800044b8:	6125                	addi	sp,sp,96
    800044ba:	8082                	ret
      wakeup(&pi->nread);
    800044bc:	8562                	mv	a0,s8
    800044be:	a9bfd0ef          	jal	80001f58 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800044c2:	85a6                	mv	a1,s1
    800044c4:	855e                	mv	a0,s7
    800044c6:	a47fd0ef          	jal	80001f0c <sleep>
  while(i < n){
    800044ca:	05495b63          	bge	s2,s4,80004520 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    800044ce:	2204a783          	lw	a5,544(s1)
    800044d2:	d7e1                	beqz	a5,8000449a <pipewrite+0x3c>
    800044d4:	854e                	mv	a0,s3
    800044d6:	c6ffd0ef          	jal	80002144 <killed>
    800044da:	f161                	bnez	a0,8000449a <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800044dc:	2184a783          	lw	a5,536(s1)
    800044e0:	21c4a703          	lw	a4,540(s1)
    800044e4:	2007879b          	addiw	a5,a5,512
    800044e8:	fcf70ae3          	beq	a4,a5,800044bc <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800044ec:	4685                	li	a3,1
    800044ee:	01590633          	add	a2,s2,s5
    800044f2:	faf40593          	addi	a1,s0,-81
    800044f6:	0509b503          	ld	a0,80(s3)
    800044fa:	9ccfd0ef          	jal	800016c6 <copyin>
    800044fe:	03650e63          	beq	a0,s6,8000453a <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004502:	21c4a783          	lw	a5,540(s1)
    80004506:	0017871b          	addiw	a4,a5,1
    8000450a:	20e4ae23          	sw	a4,540(s1)
    8000450e:	1ff7f793          	andi	a5,a5,511
    80004512:	97a6                	add	a5,a5,s1
    80004514:	faf44703          	lbu	a4,-81(s0)
    80004518:	00e78c23          	sb	a4,24(a5)
      i++;
    8000451c:	2905                	addiw	s2,s2,1
    8000451e:	b775                	j	800044ca <pipewrite+0x6c>
    80004520:	7b02                	ld	s6,32(sp)
    80004522:	6be2                	ld	s7,24(sp)
    80004524:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004526:	21848513          	addi	a0,s1,536
    8000452a:	a2ffd0ef          	jal	80001f58 <wakeup>
  release(&pi->lock);
    8000452e:	8526                	mv	a0,s1
    80004530:	f36fc0ef          	jal	80000c66 <release>
  return i;
    80004534:	bf95                	j	800044a8 <pipewrite+0x4a>
  int i = 0;
    80004536:	4901                	li	s2,0
    80004538:	b7fd                	j	80004526 <pipewrite+0xc8>
    8000453a:	7b02                	ld	s6,32(sp)
    8000453c:	6be2                	ld	s7,24(sp)
    8000453e:	6c42                	ld	s8,16(sp)
    80004540:	b7dd                	j	80004526 <pipewrite+0xc8>

0000000080004542 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004542:	715d                	addi	sp,sp,-80
    80004544:	e486                	sd	ra,72(sp)
    80004546:	e0a2                	sd	s0,64(sp)
    80004548:	fc26                	sd	s1,56(sp)
    8000454a:	f84a                	sd	s2,48(sp)
    8000454c:	f44e                	sd	s3,40(sp)
    8000454e:	f052                	sd	s4,32(sp)
    80004550:	ec56                	sd	s5,24(sp)
    80004552:	0880                	addi	s0,sp,80
    80004554:	84aa                	mv	s1,a0
    80004556:	892e                	mv	s2,a1
    80004558:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000455a:	b74fd0ef          	jal	800018ce <myproc>
    8000455e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004560:	8526                	mv	a0,s1
    80004562:	e6cfc0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004566:	2184a703          	lw	a4,536(s1)
    8000456a:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000456e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004572:	02f71563          	bne	a4,a5,8000459c <piperead+0x5a>
    80004576:	2244a783          	lw	a5,548(s1)
    8000457a:	cb85                	beqz	a5,800045aa <piperead+0x68>
    if(killed(pr)){
    8000457c:	8552                	mv	a0,s4
    8000457e:	bc7fd0ef          	jal	80002144 <killed>
    80004582:	ed19                	bnez	a0,800045a0 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004584:	85a6                	mv	a1,s1
    80004586:	854e                	mv	a0,s3
    80004588:	985fd0ef          	jal	80001f0c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000458c:	2184a703          	lw	a4,536(s1)
    80004590:	21c4a783          	lw	a5,540(s1)
    80004594:	fef701e3          	beq	a4,a5,80004576 <piperead+0x34>
    80004598:	e85a                	sd	s6,16(sp)
    8000459a:	a809                	j	800045ac <piperead+0x6a>
    8000459c:	e85a                	sd	s6,16(sp)
    8000459e:	a039                	j	800045ac <piperead+0x6a>
      release(&pi->lock);
    800045a0:	8526                	mv	a0,s1
    800045a2:	ec4fc0ef          	jal	80000c66 <release>
      return -1;
    800045a6:	59fd                	li	s3,-1
    800045a8:	a8b9                	j	80004606 <piperead+0xc4>
    800045aa:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800045ac:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800045ae:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800045b0:	05505363          	blez	s5,800045f6 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    800045b4:	2184a783          	lw	a5,536(s1)
    800045b8:	21c4a703          	lw	a4,540(s1)
    800045bc:	02f70d63          	beq	a4,a5,800045f6 <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    800045c0:	1ff7f793          	andi	a5,a5,511
    800045c4:	97a6                	add	a5,a5,s1
    800045c6:	0187c783          	lbu	a5,24(a5)
    800045ca:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800045ce:	4685                	li	a3,1
    800045d0:	fbf40613          	addi	a2,s0,-65
    800045d4:	85ca                	mv	a1,s2
    800045d6:	050a3503          	ld	a0,80(s4)
    800045da:	808fd0ef          	jal	800015e2 <copyout>
    800045de:	03650e63          	beq	a0,s6,8000461a <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800045e2:	2184a783          	lw	a5,536(s1)
    800045e6:	2785                	addiw	a5,a5,1
    800045e8:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800045ec:	2985                	addiw	s3,s3,1
    800045ee:	0905                	addi	s2,s2,1
    800045f0:	fd3a92e3          	bne	s5,s3,800045b4 <piperead+0x72>
    800045f4:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800045f6:	21c48513          	addi	a0,s1,540
    800045fa:	95ffd0ef          	jal	80001f58 <wakeup>
  release(&pi->lock);
    800045fe:	8526                	mv	a0,s1
    80004600:	e66fc0ef          	jal	80000c66 <release>
    80004604:	6b42                	ld	s6,16(sp)
  return i;
}
    80004606:	854e                	mv	a0,s3
    80004608:	60a6                	ld	ra,72(sp)
    8000460a:	6406                	ld	s0,64(sp)
    8000460c:	74e2                	ld	s1,56(sp)
    8000460e:	7942                	ld	s2,48(sp)
    80004610:	79a2                	ld	s3,40(sp)
    80004612:	7a02                	ld	s4,32(sp)
    80004614:	6ae2                	ld	s5,24(sp)
    80004616:	6161                	addi	sp,sp,80
    80004618:	8082                	ret
      if(i == 0)
    8000461a:	fc099ee3          	bnez	s3,800045f6 <piperead+0xb4>
        i = -1;
    8000461e:	89aa                	mv	s3,a0
    80004620:	bfd9                	j	800045f6 <piperead+0xb4>

0000000080004622 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004622:	1141                	addi	sp,sp,-16
    80004624:	e422                	sd	s0,8(sp)
    80004626:	0800                	addi	s0,sp,16
    80004628:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000462a:	8905                	andi	a0,a0,1
    8000462c:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    8000462e:	8b89                	andi	a5,a5,2
    80004630:	c399                	beqz	a5,80004636 <flags2perm+0x14>
      perm |= PTE_W;
    80004632:	00456513          	ori	a0,a0,4
    return perm;
}
    80004636:	6422                	ld	s0,8(sp)
    80004638:	0141                	addi	sp,sp,16
    8000463a:	8082                	ret

000000008000463c <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000463c:	df010113          	addi	sp,sp,-528
    80004640:	20113423          	sd	ra,520(sp)
    80004644:	20813023          	sd	s0,512(sp)
    80004648:	ffa6                	sd	s1,504(sp)
    8000464a:	fbca                	sd	s2,496(sp)
    8000464c:	0c00                	addi	s0,sp,528
    8000464e:	892a                	mv	s2,a0
    80004650:	dea43c23          	sd	a0,-520(s0)
    80004654:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004658:	a76fd0ef          	jal	800018ce <myproc>
    8000465c:	84aa                	mv	s1,a0

  begin_op();
    8000465e:	dcaff0ef          	jal	80003c28 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004662:	854a                	mv	a0,s2
    80004664:	bf0ff0ef          	jal	80003a54 <namei>
    80004668:	c931                	beqz	a0,800046bc <kexec+0x80>
    8000466a:	f3d2                	sd	s4,480(sp)
    8000466c:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000466e:	bd1fe0ef          	jal	8000323e <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004672:	04000713          	li	a4,64
    80004676:	4681                	li	a3,0
    80004678:	e5040613          	addi	a2,s0,-432
    8000467c:	4581                	li	a1,0
    8000467e:	8552                	mv	a0,s4
    80004680:	f4ffe0ef          	jal	800035ce <readi>
    80004684:	04000793          	li	a5,64
    80004688:	00f51a63          	bne	a0,a5,8000469c <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    8000468c:	e5042703          	lw	a4,-432(s0)
    80004690:	464c47b7          	lui	a5,0x464c4
    80004694:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004698:	02f70663          	beq	a4,a5,800046c4 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000469c:	8552                	mv	a0,s4
    8000469e:	dabfe0ef          	jal	80003448 <iunlockput>
    end_op();
    800046a2:	df0ff0ef          	jal	80003c92 <end_op>
  }
  return -1;
    800046a6:	557d                	li	a0,-1
    800046a8:	7a1e                	ld	s4,480(sp)
}
    800046aa:	20813083          	ld	ra,520(sp)
    800046ae:	20013403          	ld	s0,512(sp)
    800046b2:	74fe                	ld	s1,504(sp)
    800046b4:	795e                	ld	s2,496(sp)
    800046b6:	21010113          	addi	sp,sp,528
    800046ba:	8082                	ret
    end_op();
    800046bc:	dd6ff0ef          	jal	80003c92 <end_op>
    return -1;
    800046c0:	557d                	li	a0,-1
    800046c2:	b7e5                	j	800046aa <kexec+0x6e>
    800046c4:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800046c6:	8526                	mv	a0,s1
    800046c8:	b0cfd0ef          	jal	800019d4 <proc_pagetable>
    800046cc:	8b2a                	mv	s6,a0
    800046ce:	2c050b63          	beqz	a0,800049a4 <kexec+0x368>
    800046d2:	f7ce                	sd	s3,488(sp)
    800046d4:	efd6                	sd	s5,472(sp)
    800046d6:	e7de                	sd	s7,456(sp)
    800046d8:	e3e2                	sd	s8,448(sp)
    800046da:	ff66                	sd	s9,440(sp)
    800046dc:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800046de:	e7042d03          	lw	s10,-400(s0)
    800046e2:	e8845783          	lhu	a5,-376(s0)
    800046e6:	12078963          	beqz	a5,80004818 <kexec+0x1dc>
    800046ea:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800046ec:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800046ee:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800046f0:	6c85                	lui	s9,0x1
    800046f2:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800046f6:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800046fa:	6a85                	lui	s5,0x1
    800046fc:	a085                	j	8000475c <kexec+0x120>
      panic("loadseg: address should exist");
    800046fe:	00003517          	auipc	a0,0x3
    80004702:	ea250513          	addi	a0,a0,-350 # 800075a0 <etext+0x5a0>
    80004706:	8dafc0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    8000470a:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000470c:	8726                	mv	a4,s1
    8000470e:	012c06bb          	addw	a3,s8,s2
    80004712:	4581                	li	a1,0
    80004714:	8552                	mv	a0,s4
    80004716:	eb9fe0ef          	jal	800035ce <readi>
    8000471a:	2501                	sext.w	a0,a0
    8000471c:	24a49a63          	bne	s1,a0,80004970 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004720:	012a893b          	addw	s2,s5,s2
    80004724:	03397363          	bgeu	s2,s3,8000474a <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004728:	02091593          	slli	a1,s2,0x20
    8000472c:	9181                	srli	a1,a1,0x20
    8000472e:	95de                	add	a1,a1,s7
    80004730:	855a                	mv	a0,s6
    80004732:	87ffc0ef          	jal	80000fb0 <walkaddr>
    80004736:	862a                	mv	a2,a0
    if(pa == 0)
    80004738:	d179                	beqz	a0,800046fe <kexec+0xc2>
    if(sz - i < PGSIZE)
    8000473a:	412984bb          	subw	s1,s3,s2
    8000473e:	0004879b          	sext.w	a5,s1
    80004742:	fcfcf4e3          	bgeu	s9,a5,8000470a <kexec+0xce>
    80004746:	84d6                	mv	s1,s5
    80004748:	b7c9                	j	8000470a <kexec+0xce>
    sz = sz1;
    8000474a:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000474e:	2d85                	addiw	s11,s11,1
    80004750:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004754:	e8845783          	lhu	a5,-376(s0)
    80004758:	08fdd063          	bge	s11,a5,800047d8 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000475c:	2d01                	sext.w	s10,s10
    8000475e:	03800713          	li	a4,56
    80004762:	86ea                	mv	a3,s10
    80004764:	e1840613          	addi	a2,s0,-488
    80004768:	4581                	li	a1,0
    8000476a:	8552                	mv	a0,s4
    8000476c:	e63fe0ef          	jal	800035ce <readi>
    80004770:	03800793          	li	a5,56
    80004774:	1cf51663          	bne	a0,a5,80004940 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004778:	e1842783          	lw	a5,-488(s0)
    8000477c:	4705                	li	a4,1
    8000477e:	fce798e3          	bne	a5,a4,8000474e <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80004782:	e4043483          	ld	s1,-448(s0)
    80004786:	e3843783          	ld	a5,-456(s0)
    8000478a:	1af4ef63          	bltu	s1,a5,80004948 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000478e:	e2843783          	ld	a5,-472(s0)
    80004792:	94be                	add	s1,s1,a5
    80004794:	1af4ee63          	bltu	s1,a5,80004950 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004798:	df043703          	ld	a4,-528(s0)
    8000479c:	8ff9                	and	a5,a5,a4
    8000479e:	1a079d63          	bnez	a5,80004958 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800047a2:	e1c42503          	lw	a0,-484(s0)
    800047a6:	e7dff0ef          	jal	80004622 <flags2perm>
    800047aa:	86aa                	mv	a3,a0
    800047ac:	8626                	mv	a2,s1
    800047ae:	85ca                	mv	a1,s2
    800047b0:	855a                	mv	a0,s6
    800047b2:	ad7fc0ef          	jal	80001288 <uvmalloc>
    800047b6:	e0a43423          	sd	a0,-504(s0)
    800047ba:	1a050363          	beqz	a0,80004960 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800047be:	e2843b83          	ld	s7,-472(s0)
    800047c2:	e2042c03          	lw	s8,-480(s0)
    800047c6:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800047ca:	00098463          	beqz	s3,800047d2 <kexec+0x196>
    800047ce:	4901                	li	s2,0
    800047d0:	bfa1                	j	80004728 <kexec+0xec>
    sz = sz1;
    800047d2:	e0843903          	ld	s2,-504(s0)
    800047d6:	bfa5                	j	8000474e <kexec+0x112>
    800047d8:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800047da:	8552                	mv	a0,s4
    800047dc:	c6dfe0ef          	jal	80003448 <iunlockput>
  end_op();
    800047e0:	cb2ff0ef          	jal	80003c92 <end_op>
  p = myproc();
    800047e4:	8eafd0ef          	jal	800018ce <myproc>
    800047e8:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800047ea:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800047ee:	6985                	lui	s3,0x1
    800047f0:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800047f2:	99ca                	add	s3,s3,s2
    800047f4:	77fd                	lui	a5,0xfffff
    800047f6:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800047fa:	4691                	li	a3,4
    800047fc:	6609                	lui	a2,0x2
    800047fe:	964e                	add	a2,a2,s3
    80004800:	85ce                	mv	a1,s3
    80004802:	855a                	mv	a0,s6
    80004804:	a85fc0ef          	jal	80001288 <uvmalloc>
    80004808:	892a                	mv	s2,a0
    8000480a:	e0a43423          	sd	a0,-504(s0)
    8000480e:	e519                	bnez	a0,8000481c <kexec+0x1e0>
  if(pagetable)
    80004810:	e1343423          	sd	s3,-504(s0)
    80004814:	4a01                	li	s4,0
    80004816:	aab1                	j	80004972 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004818:	4901                	li	s2,0
    8000481a:	b7c1                	j	800047da <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    8000481c:	75f9                	lui	a1,0xffffe
    8000481e:	95aa                	add	a1,a1,a0
    80004820:	855a                	mv	a0,s6
    80004822:	c3dfc0ef          	jal	8000145e <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004826:	7bfd                	lui	s7,0xfffff
    80004828:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    8000482a:	e0043783          	ld	a5,-512(s0)
    8000482e:	6388                	ld	a0,0(a5)
    80004830:	cd39                	beqz	a0,8000488e <kexec+0x252>
    80004832:	e9040993          	addi	s3,s0,-368
    80004836:	f9040c13          	addi	s8,s0,-112
    8000483a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000483c:	dd6fc0ef          	jal	80000e12 <strlen>
    80004840:	0015079b          	addiw	a5,a0,1
    80004844:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004848:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000484c:	11796e63          	bltu	s2,s7,80004968 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004850:	e0043d03          	ld	s10,-512(s0)
    80004854:	000d3a03          	ld	s4,0(s10)
    80004858:	8552                	mv	a0,s4
    8000485a:	db8fc0ef          	jal	80000e12 <strlen>
    8000485e:	0015069b          	addiw	a3,a0,1
    80004862:	8652                	mv	a2,s4
    80004864:	85ca                	mv	a1,s2
    80004866:	855a                	mv	a0,s6
    80004868:	d7bfc0ef          	jal	800015e2 <copyout>
    8000486c:	10054063          	bltz	a0,8000496c <kexec+0x330>
    ustack[argc] = sp;
    80004870:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004874:	0485                	addi	s1,s1,1
    80004876:	008d0793          	addi	a5,s10,8
    8000487a:	e0f43023          	sd	a5,-512(s0)
    8000487e:	008d3503          	ld	a0,8(s10)
    80004882:	c909                	beqz	a0,80004894 <kexec+0x258>
    if(argc >= MAXARG)
    80004884:	09a1                	addi	s3,s3,8
    80004886:	fb899be3          	bne	s3,s8,8000483c <kexec+0x200>
  ip = 0;
    8000488a:	4a01                	li	s4,0
    8000488c:	a0dd                	j	80004972 <kexec+0x336>
  sp = sz;
    8000488e:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004892:	4481                	li	s1,0
  ustack[argc] = 0;
    80004894:	00349793          	slli	a5,s1,0x3
    80004898:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffde218>
    8000489c:	97a2                	add	a5,a5,s0
    8000489e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800048a2:	00148693          	addi	a3,s1,1
    800048a6:	068e                	slli	a3,a3,0x3
    800048a8:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800048ac:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800048b0:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    800048b4:	f5796ee3          	bltu	s2,s7,80004810 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800048b8:	e9040613          	addi	a2,s0,-368
    800048bc:	85ca                	mv	a1,s2
    800048be:	855a                	mv	a0,s6
    800048c0:	d23fc0ef          	jal	800015e2 <copyout>
    800048c4:	0e054263          	bltz	a0,800049a8 <kexec+0x36c>
  p->trapframe->a1 = sp;
    800048c8:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800048cc:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800048d0:	df843783          	ld	a5,-520(s0)
    800048d4:	0007c703          	lbu	a4,0(a5)
    800048d8:	cf11                	beqz	a4,800048f4 <kexec+0x2b8>
    800048da:	0785                	addi	a5,a5,1
    if(*s == '/')
    800048dc:	02f00693          	li	a3,47
    800048e0:	a039                	j	800048ee <kexec+0x2b2>
      last = s+1;
    800048e2:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800048e6:	0785                	addi	a5,a5,1
    800048e8:	fff7c703          	lbu	a4,-1(a5)
    800048ec:	c701                	beqz	a4,800048f4 <kexec+0x2b8>
    if(*s == '/')
    800048ee:	fed71ce3          	bne	a4,a3,800048e6 <kexec+0x2aa>
    800048f2:	bfc5                	j	800048e2 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    800048f4:	4641                	li	a2,16
    800048f6:	df843583          	ld	a1,-520(s0)
    800048fa:	158a8513          	addi	a0,s5,344
    800048fe:	ce2fc0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    80004902:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004906:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000490a:	e0843783          	ld	a5,-504(s0)
    8000490e:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004912:	058ab783          	ld	a5,88(s5)
    80004916:	e6843703          	ld	a4,-408(s0)
    8000491a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000491c:	058ab783          	ld	a5,88(s5)
    80004920:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004924:	85e6                	mv	a1,s9
    80004926:	932fd0ef          	jal	80001a58 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000492a:	0004851b          	sext.w	a0,s1
    8000492e:	79be                	ld	s3,488(sp)
    80004930:	7a1e                	ld	s4,480(sp)
    80004932:	6afe                	ld	s5,472(sp)
    80004934:	6b5e                	ld	s6,464(sp)
    80004936:	6bbe                	ld	s7,456(sp)
    80004938:	6c1e                	ld	s8,448(sp)
    8000493a:	7cfa                	ld	s9,440(sp)
    8000493c:	7d5a                	ld	s10,432(sp)
    8000493e:	b3b5                	j	800046aa <kexec+0x6e>
    80004940:	e1243423          	sd	s2,-504(s0)
    80004944:	7dba                	ld	s11,424(sp)
    80004946:	a035                	j	80004972 <kexec+0x336>
    80004948:	e1243423          	sd	s2,-504(s0)
    8000494c:	7dba                	ld	s11,424(sp)
    8000494e:	a015                	j	80004972 <kexec+0x336>
    80004950:	e1243423          	sd	s2,-504(s0)
    80004954:	7dba                	ld	s11,424(sp)
    80004956:	a831                	j	80004972 <kexec+0x336>
    80004958:	e1243423          	sd	s2,-504(s0)
    8000495c:	7dba                	ld	s11,424(sp)
    8000495e:	a811                	j	80004972 <kexec+0x336>
    80004960:	e1243423          	sd	s2,-504(s0)
    80004964:	7dba                	ld	s11,424(sp)
    80004966:	a031                	j	80004972 <kexec+0x336>
  ip = 0;
    80004968:	4a01                	li	s4,0
    8000496a:	a021                	j	80004972 <kexec+0x336>
    8000496c:	4a01                	li	s4,0
  if(pagetable)
    8000496e:	a011                	j	80004972 <kexec+0x336>
    80004970:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004972:	e0843583          	ld	a1,-504(s0)
    80004976:	855a                	mv	a0,s6
    80004978:	8e0fd0ef          	jal	80001a58 <proc_freepagetable>
  return -1;
    8000497c:	557d                	li	a0,-1
  if(ip){
    8000497e:	000a1b63          	bnez	s4,80004994 <kexec+0x358>
    80004982:	79be                	ld	s3,488(sp)
    80004984:	7a1e                	ld	s4,480(sp)
    80004986:	6afe                	ld	s5,472(sp)
    80004988:	6b5e                	ld	s6,464(sp)
    8000498a:	6bbe                	ld	s7,456(sp)
    8000498c:	6c1e                	ld	s8,448(sp)
    8000498e:	7cfa                	ld	s9,440(sp)
    80004990:	7d5a                	ld	s10,432(sp)
    80004992:	bb21                	j	800046aa <kexec+0x6e>
    80004994:	79be                	ld	s3,488(sp)
    80004996:	6afe                	ld	s5,472(sp)
    80004998:	6b5e                	ld	s6,464(sp)
    8000499a:	6bbe                	ld	s7,456(sp)
    8000499c:	6c1e                	ld	s8,448(sp)
    8000499e:	7cfa                	ld	s9,440(sp)
    800049a0:	7d5a                	ld	s10,432(sp)
    800049a2:	b9ed                	j	8000469c <kexec+0x60>
    800049a4:	6b5e                	ld	s6,464(sp)
    800049a6:	b9dd                	j	8000469c <kexec+0x60>
  sz = sz1;
    800049a8:	e0843983          	ld	s3,-504(s0)
    800049ac:	b595                	j	80004810 <kexec+0x1d4>

00000000800049ae <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800049ae:	7179                	addi	sp,sp,-48
    800049b0:	f406                	sd	ra,40(sp)
    800049b2:	f022                	sd	s0,32(sp)
    800049b4:	ec26                	sd	s1,24(sp)
    800049b6:	e84a                	sd	s2,16(sp)
    800049b8:	1800                	addi	s0,sp,48
    800049ba:	892e                	mv	s2,a1
    800049bc:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800049be:	fdc40593          	addi	a1,s0,-36
    800049c2:	e4ffd0ef          	jal	80002810 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800049c6:	fdc42703          	lw	a4,-36(s0)
    800049ca:	47bd                	li	a5,15
    800049cc:	02e7e963          	bltu	a5,a4,800049fe <argfd+0x50>
    800049d0:	efffc0ef          	jal	800018ce <myproc>
    800049d4:	fdc42703          	lw	a4,-36(s0)
    800049d8:	01a70793          	addi	a5,a4,26
    800049dc:	078e                	slli	a5,a5,0x3
    800049de:	953e                	add	a0,a0,a5
    800049e0:	611c                	ld	a5,0(a0)
    800049e2:	c385                	beqz	a5,80004a02 <argfd+0x54>
    return -1;
  if(pfd)
    800049e4:	00090463          	beqz	s2,800049ec <argfd+0x3e>
    *pfd = fd;
    800049e8:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800049ec:	4501                	li	a0,0
  if(pf)
    800049ee:	c091                	beqz	s1,800049f2 <argfd+0x44>
    *pf = f;
    800049f0:	e09c                	sd	a5,0(s1)
}
    800049f2:	70a2                	ld	ra,40(sp)
    800049f4:	7402                	ld	s0,32(sp)
    800049f6:	64e2                	ld	s1,24(sp)
    800049f8:	6942                	ld	s2,16(sp)
    800049fa:	6145                	addi	sp,sp,48
    800049fc:	8082                	ret
    return -1;
    800049fe:	557d                	li	a0,-1
    80004a00:	bfcd                	j	800049f2 <argfd+0x44>
    80004a02:	557d                	li	a0,-1
    80004a04:	b7fd                	j	800049f2 <argfd+0x44>

0000000080004a06 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004a06:	1101                	addi	sp,sp,-32
    80004a08:	ec06                	sd	ra,24(sp)
    80004a0a:	e822                	sd	s0,16(sp)
    80004a0c:	e426                	sd	s1,8(sp)
    80004a0e:	1000                	addi	s0,sp,32
    80004a10:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004a12:	ebdfc0ef          	jal	800018ce <myproc>
    80004a16:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004a18:	0d050793          	addi	a5,a0,208
    80004a1c:	4501                	li	a0,0
    80004a1e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004a20:	6398                	ld	a4,0(a5)
    80004a22:	cb19                	beqz	a4,80004a38 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004a24:	2505                	addiw	a0,a0,1
    80004a26:	07a1                	addi	a5,a5,8
    80004a28:	fed51ce3          	bne	a0,a3,80004a20 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004a2c:	557d                	li	a0,-1
}
    80004a2e:	60e2                	ld	ra,24(sp)
    80004a30:	6442                	ld	s0,16(sp)
    80004a32:	64a2                	ld	s1,8(sp)
    80004a34:	6105                	addi	sp,sp,32
    80004a36:	8082                	ret
      p->ofile[fd] = f;
    80004a38:	01a50793          	addi	a5,a0,26
    80004a3c:	078e                	slli	a5,a5,0x3
    80004a3e:	963e                	add	a2,a2,a5
    80004a40:	e204                	sd	s1,0(a2)
      return fd;
    80004a42:	b7f5                	j	80004a2e <fdalloc+0x28>

0000000080004a44 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004a44:	715d                	addi	sp,sp,-80
    80004a46:	e486                	sd	ra,72(sp)
    80004a48:	e0a2                	sd	s0,64(sp)
    80004a4a:	fc26                	sd	s1,56(sp)
    80004a4c:	f84a                	sd	s2,48(sp)
    80004a4e:	f44e                	sd	s3,40(sp)
    80004a50:	ec56                	sd	s5,24(sp)
    80004a52:	e85a                	sd	s6,16(sp)
    80004a54:	0880                	addi	s0,sp,80
    80004a56:	8b2e                	mv	s6,a1
    80004a58:	89b2                	mv	s3,a2
    80004a5a:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004a5c:	fb040593          	addi	a1,s0,-80
    80004a60:	80eff0ef          	jal	80003a6e <nameiparent>
    80004a64:	84aa                	mv	s1,a0
    80004a66:	10050a63          	beqz	a0,80004b7a <create+0x136>
    return 0;

  ilock(dp);
    80004a6a:	fd4fe0ef          	jal	8000323e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004a6e:	4601                	li	a2,0
    80004a70:	fb040593          	addi	a1,s0,-80
    80004a74:	8526                	mv	a0,s1
    80004a76:	d79fe0ef          	jal	800037ee <dirlookup>
    80004a7a:	8aaa                	mv	s5,a0
    80004a7c:	c129                	beqz	a0,80004abe <create+0x7a>
    iunlockput(dp);
    80004a7e:	8526                	mv	a0,s1
    80004a80:	9c9fe0ef          	jal	80003448 <iunlockput>
    ilock(ip);
    80004a84:	8556                	mv	a0,s5
    80004a86:	fb8fe0ef          	jal	8000323e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004a8a:	4789                	li	a5,2
    80004a8c:	02fb1463          	bne	s6,a5,80004ab4 <create+0x70>
    80004a90:	044ad783          	lhu	a5,68(s5)
    80004a94:	37f9                	addiw	a5,a5,-2
    80004a96:	17c2                	slli	a5,a5,0x30
    80004a98:	93c1                	srli	a5,a5,0x30
    80004a9a:	4705                	li	a4,1
    80004a9c:	00f76c63          	bltu	a4,a5,80004ab4 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004aa0:	8556                	mv	a0,s5
    80004aa2:	60a6                	ld	ra,72(sp)
    80004aa4:	6406                	ld	s0,64(sp)
    80004aa6:	74e2                	ld	s1,56(sp)
    80004aa8:	7942                	ld	s2,48(sp)
    80004aaa:	79a2                	ld	s3,40(sp)
    80004aac:	6ae2                	ld	s5,24(sp)
    80004aae:	6b42                	ld	s6,16(sp)
    80004ab0:	6161                	addi	sp,sp,80
    80004ab2:	8082                	ret
    iunlockput(ip);
    80004ab4:	8556                	mv	a0,s5
    80004ab6:	993fe0ef          	jal	80003448 <iunlockput>
    return 0;
    80004aba:	4a81                	li	s5,0
    80004abc:	b7d5                	j	80004aa0 <create+0x5c>
    80004abe:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004ac0:	85da                	mv	a1,s6
    80004ac2:	4088                	lw	a0,0(s1)
    80004ac4:	e0afe0ef          	jal	800030ce <ialloc>
    80004ac8:	8a2a                	mv	s4,a0
    80004aca:	cd15                	beqz	a0,80004b06 <create+0xc2>
  ilock(ip);
    80004acc:	f72fe0ef          	jal	8000323e <ilock>
  ip->major = major;
    80004ad0:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004ad4:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004ad8:	4905                	li	s2,1
    80004ada:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004ade:	8552                	mv	a0,s4
    80004ae0:	eaafe0ef          	jal	8000318a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004ae4:	032b0763          	beq	s6,s2,80004b12 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004ae8:	004a2603          	lw	a2,4(s4)
    80004aec:	fb040593          	addi	a1,s0,-80
    80004af0:	8526                	mv	a0,s1
    80004af2:	ec9fe0ef          	jal	800039ba <dirlink>
    80004af6:	06054563          	bltz	a0,80004b60 <create+0x11c>
  iunlockput(dp);
    80004afa:	8526                	mv	a0,s1
    80004afc:	94dfe0ef          	jal	80003448 <iunlockput>
  return ip;
    80004b00:	8ad2                	mv	s5,s4
    80004b02:	7a02                	ld	s4,32(sp)
    80004b04:	bf71                	j	80004aa0 <create+0x5c>
    iunlockput(dp);
    80004b06:	8526                	mv	a0,s1
    80004b08:	941fe0ef          	jal	80003448 <iunlockput>
    return 0;
    80004b0c:	8ad2                	mv	s5,s4
    80004b0e:	7a02                	ld	s4,32(sp)
    80004b10:	bf41                	j	80004aa0 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004b12:	004a2603          	lw	a2,4(s4)
    80004b16:	00003597          	auipc	a1,0x3
    80004b1a:	aaa58593          	addi	a1,a1,-1366 # 800075c0 <etext+0x5c0>
    80004b1e:	8552                	mv	a0,s4
    80004b20:	e9bfe0ef          	jal	800039ba <dirlink>
    80004b24:	02054e63          	bltz	a0,80004b60 <create+0x11c>
    80004b28:	40d0                	lw	a2,4(s1)
    80004b2a:	00003597          	auipc	a1,0x3
    80004b2e:	a9e58593          	addi	a1,a1,-1378 # 800075c8 <etext+0x5c8>
    80004b32:	8552                	mv	a0,s4
    80004b34:	e87fe0ef          	jal	800039ba <dirlink>
    80004b38:	02054463          	bltz	a0,80004b60 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004b3c:	004a2603          	lw	a2,4(s4)
    80004b40:	fb040593          	addi	a1,s0,-80
    80004b44:	8526                	mv	a0,s1
    80004b46:	e75fe0ef          	jal	800039ba <dirlink>
    80004b4a:	00054b63          	bltz	a0,80004b60 <create+0x11c>
    dp->nlink++;  // for ".."
    80004b4e:	04a4d783          	lhu	a5,74(s1)
    80004b52:	2785                	addiw	a5,a5,1
    80004b54:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004b58:	8526                	mv	a0,s1
    80004b5a:	e30fe0ef          	jal	8000318a <iupdate>
    80004b5e:	bf71                	j	80004afa <create+0xb6>
  ip->nlink = 0;
    80004b60:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004b64:	8552                	mv	a0,s4
    80004b66:	e24fe0ef          	jal	8000318a <iupdate>
  iunlockput(ip);
    80004b6a:	8552                	mv	a0,s4
    80004b6c:	8ddfe0ef          	jal	80003448 <iunlockput>
  iunlockput(dp);
    80004b70:	8526                	mv	a0,s1
    80004b72:	8d7fe0ef          	jal	80003448 <iunlockput>
  return 0;
    80004b76:	7a02                	ld	s4,32(sp)
    80004b78:	b725                	j	80004aa0 <create+0x5c>
    return 0;
    80004b7a:	8aaa                	mv	s5,a0
    80004b7c:	b715                	j	80004aa0 <create+0x5c>

0000000080004b7e <sys_dup>:
{
    80004b7e:	7179                	addi	sp,sp,-48
    80004b80:	f406                	sd	ra,40(sp)
    80004b82:	f022                	sd	s0,32(sp)
    80004b84:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004b86:	fd840613          	addi	a2,s0,-40
    80004b8a:	4581                	li	a1,0
    80004b8c:	4501                	li	a0,0
    80004b8e:	e21ff0ef          	jal	800049ae <argfd>
    return -1;
    80004b92:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004b94:	02054363          	bltz	a0,80004bba <sys_dup+0x3c>
    80004b98:	ec26                	sd	s1,24(sp)
    80004b9a:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004b9c:	fd843903          	ld	s2,-40(s0)
    80004ba0:	854a                	mv	a0,s2
    80004ba2:	e65ff0ef          	jal	80004a06 <fdalloc>
    80004ba6:	84aa                	mv	s1,a0
    return -1;
    80004ba8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004baa:	00054d63          	bltz	a0,80004bc4 <sys_dup+0x46>
  filedup(f);
    80004bae:	854a                	mv	a0,s2
    80004bb0:	c3eff0ef          	jal	80003fee <filedup>
  return fd;
    80004bb4:	87a6                	mv	a5,s1
    80004bb6:	64e2                	ld	s1,24(sp)
    80004bb8:	6942                	ld	s2,16(sp)
}
    80004bba:	853e                	mv	a0,a5
    80004bbc:	70a2                	ld	ra,40(sp)
    80004bbe:	7402                	ld	s0,32(sp)
    80004bc0:	6145                	addi	sp,sp,48
    80004bc2:	8082                	ret
    80004bc4:	64e2                	ld	s1,24(sp)
    80004bc6:	6942                	ld	s2,16(sp)
    80004bc8:	bfcd                	j	80004bba <sys_dup+0x3c>

0000000080004bca <sys_read>:
{
    80004bca:	7179                	addi	sp,sp,-48
    80004bcc:	f406                	sd	ra,40(sp)
    80004bce:	f022                	sd	s0,32(sp)
    80004bd0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004bd2:	fd840593          	addi	a1,s0,-40
    80004bd6:	4505                	li	a0,1
    80004bd8:	c55fd0ef          	jal	8000282c <argaddr>
  argint(2, &n);
    80004bdc:	fe440593          	addi	a1,s0,-28
    80004be0:	4509                	li	a0,2
    80004be2:	c2ffd0ef          	jal	80002810 <argint>
  if(argfd(0, 0, &f) < 0)
    80004be6:	fe840613          	addi	a2,s0,-24
    80004bea:	4581                	li	a1,0
    80004bec:	4501                	li	a0,0
    80004bee:	dc1ff0ef          	jal	800049ae <argfd>
    80004bf2:	87aa                	mv	a5,a0
    return -1;
    80004bf4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004bf6:	0007ca63          	bltz	a5,80004c0a <sys_read+0x40>
  return fileread(f, p, n);
    80004bfa:	fe442603          	lw	a2,-28(s0)
    80004bfe:	fd843583          	ld	a1,-40(s0)
    80004c02:	fe843503          	ld	a0,-24(s0)
    80004c06:	d4eff0ef          	jal	80004154 <fileread>
}
    80004c0a:	70a2                	ld	ra,40(sp)
    80004c0c:	7402                	ld	s0,32(sp)
    80004c0e:	6145                	addi	sp,sp,48
    80004c10:	8082                	ret

0000000080004c12 <sys_write>:
{
    80004c12:	7179                	addi	sp,sp,-48
    80004c14:	f406                	sd	ra,40(sp)
    80004c16:	f022                	sd	s0,32(sp)
    80004c18:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c1a:	fd840593          	addi	a1,s0,-40
    80004c1e:	4505                	li	a0,1
    80004c20:	c0dfd0ef          	jal	8000282c <argaddr>
  argint(2, &n);
    80004c24:	fe440593          	addi	a1,s0,-28
    80004c28:	4509                	li	a0,2
    80004c2a:	be7fd0ef          	jal	80002810 <argint>
  if(argfd(0, 0, &f) < 0)
    80004c2e:	fe840613          	addi	a2,s0,-24
    80004c32:	4581                	li	a1,0
    80004c34:	4501                	li	a0,0
    80004c36:	d79ff0ef          	jal	800049ae <argfd>
    80004c3a:	87aa                	mv	a5,a0
    return -1;
    80004c3c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c3e:	0007ca63          	bltz	a5,80004c52 <sys_write+0x40>
  return filewrite(f, p, n);
    80004c42:	fe442603          	lw	a2,-28(s0)
    80004c46:	fd843583          	ld	a1,-40(s0)
    80004c4a:	fe843503          	ld	a0,-24(s0)
    80004c4e:	dc4ff0ef          	jal	80004212 <filewrite>
}
    80004c52:	70a2                	ld	ra,40(sp)
    80004c54:	7402                	ld	s0,32(sp)
    80004c56:	6145                	addi	sp,sp,48
    80004c58:	8082                	ret

0000000080004c5a <sys_close>:
{
    80004c5a:	1101                	addi	sp,sp,-32
    80004c5c:	ec06                	sd	ra,24(sp)
    80004c5e:	e822                	sd	s0,16(sp)
    80004c60:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004c62:	fe040613          	addi	a2,s0,-32
    80004c66:	fec40593          	addi	a1,s0,-20
    80004c6a:	4501                	li	a0,0
    80004c6c:	d43ff0ef          	jal	800049ae <argfd>
    return -1;
    80004c70:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004c72:	02054063          	bltz	a0,80004c92 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004c76:	c59fc0ef          	jal	800018ce <myproc>
    80004c7a:	fec42783          	lw	a5,-20(s0)
    80004c7e:	07e9                	addi	a5,a5,26
    80004c80:	078e                	slli	a5,a5,0x3
    80004c82:	953e                	add	a0,a0,a5
    80004c84:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004c88:	fe043503          	ld	a0,-32(s0)
    80004c8c:	ba8ff0ef          	jal	80004034 <fileclose>
  return 0;
    80004c90:	4781                	li	a5,0
}
    80004c92:	853e                	mv	a0,a5
    80004c94:	60e2                	ld	ra,24(sp)
    80004c96:	6442                	ld	s0,16(sp)
    80004c98:	6105                	addi	sp,sp,32
    80004c9a:	8082                	ret

0000000080004c9c <sys_fstat>:
{
    80004c9c:	1101                	addi	sp,sp,-32
    80004c9e:	ec06                	sd	ra,24(sp)
    80004ca0:	e822                	sd	s0,16(sp)
    80004ca2:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004ca4:	fe040593          	addi	a1,s0,-32
    80004ca8:	4505                	li	a0,1
    80004caa:	b83fd0ef          	jal	8000282c <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004cae:	fe840613          	addi	a2,s0,-24
    80004cb2:	4581                	li	a1,0
    80004cb4:	4501                	li	a0,0
    80004cb6:	cf9ff0ef          	jal	800049ae <argfd>
    80004cba:	87aa                	mv	a5,a0
    return -1;
    80004cbc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004cbe:	0007c863          	bltz	a5,80004cce <sys_fstat+0x32>
  return filestat(f, st);
    80004cc2:	fe043583          	ld	a1,-32(s0)
    80004cc6:	fe843503          	ld	a0,-24(s0)
    80004cca:	c2cff0ef          	jal	800040f6 <filestat>
}
    80004cce:	60e2                	ld	ra,24(sp)
    80004cd0:	6442                	ld	s0,16(sp)
    80004cd2:	6105                	addi	sp,sp,32
    80004cd4:	8082                	ret

0000000080004cd6 <sys_link>:
{
    80004cd6:	7169                	addi	sp,sp,-304
    80004cd8:	f606                	sd	ra,296(sp)
    80004cda:	f222                	sd	s0,288(sp)
    80004cdc:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004cde:	08000613          	li	a2,128
    80004ce2:	ed040593          	addi	a1,s0,-304
    80004ce6:	4501                	li	a0,0
    80004ce8:	b61fd0ef          	jal	80002848 <argstr>
    return -1;
    80004cec:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004cee:	0c054e63          	bltz	a0,80004dca <sys_link+0xf4>
    80004cf2:	08000613          	li	a2,128
    80004cf6:	f5040593          	addi	a1,s0,-176
    80004cfa:	4505                	li	a0,1
    80004cfc:	b4dfd0ef          	jal	80002848 <argstr>
    return -1;
    80004d00:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d02:	0c054463          	bltz	a0,80004dca <sys_link+0xf4>
    80004d06:	ee26                	sd	s1,280(sp)
  begin_op();
    80004d08:	f21fe0ef          	jal	80003c28 <begin_op>
  if((ip = namei(old)) == 0){
    80004d0c:	ed040513          	addi	a0,s0,-304
    80004d10:	d45fe0ef          	jal	80003a54 <namei>
    80004d14:	84aa                	mv	s1,a0
    80004d16:	c53d                	beqz	a0,80004d84 <sys_link+0xae>
  ilock(ip);
    80004d18:	d26fe0ef          	jal	8000323e <ilock>
  if(ip->type == T_DIR){
    80004d1c:	04449703          	lh	a4,68(s1)
    80004d20:	4785                	li	a5,1
    80004d22:	06f70663          	beq	a4,a5,80004d8e <sys_link+0xb8>
    80004d26:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004d28:	04a4d783          	lhu	a5,74(s1)
    80004d2c:	2785                	addiw	a5,a5,1
    80004d2e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d32:	8526                	mv	a0,s1
    80004d34:	c56fe0ef          	jal	8000318a <iupdate>
  iunlock(ip);
    80004d38:	8526                	mv	a0,s1
    80004d3a:	db2fe0ef          	jal	800032ec <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004d3e:	fd040593          	addi	a1,s0,-48
    80004d42:	f5040513          	addi	a0,s0,-176
    80004d46:	d29fe0ef          	jal	80003a6e <nameiparent>
    80004d4a:	892a                	mv	s2,a0
    80004d4c:	cd21                	beqz	a0,80004da4 <sys_link+0xce>
  ilock(dp);
    80004d4e:	cf0fe0ef          	jal	8000323e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004d52:	00092703          	lw	a4,0(s2)
    80004d56:	409c                	lw	a5,0(s1)
    80004d58:	04f71363          	bne	a4,a5,80004d9e <sys_link+0xc8>
    80004d5c:	40d0                	lw	a2,4(s1)
    80004d5e:	fd040593          	addi	a1,s0,-48
    80004d62:	854a                	mv	a0,s2
    80004d64:	c57fe0ef          	jal	800039ba <dirlink>
    80004d68:	02054b63          	bltz	a0,80004d9e <sys_link+0xc8>
  iunlockput(dp);
    80004d6c:	854a                	mv	a0,s2
    80004d6e:	edafe0ef          	jal	80003448 <iunlockput>
  iput(ip);
    80004d72:	8526                	mv	a0,s1
    80004d74:	e4cfe0ef          	jal	800033c0 <iput>
  end_op();
    80004d78:	f1bfe0ef          	jal	80003c92 <end_op>
  return 0;
    80004d7c:	4781                	li	a5,0
    80004d7e:	64f2                	ld	s1,280(sp)
    80004d80:	6952                	ld	s2,272(sp)
    80004d82:	a0a1                	j	80004dca <sys_link+0xf4>
    end_op();
    80004d84:	f0ffe0ef          	jal	80003c92 <end_op>
    return -1;
    80004d88:	57fd                	li	a5,-1
    80004d8a:	64f2                	ld	s1,280(sp)
    80004d8c:	a83d                	j	80004dca <sys_link+0xf4>
    iunlockput(ip);
    80004d8e:	8526                	mv	a0,s1
    80004d90:	eb8fe0ef          	jal	80003448 <iunlockput>
    end_op();
    80004d94:	efffe0ef          	jal	80003c92 <end_op>
    return -1;
    80004d98:	57fd                	li	a5,-1
    80004d9a:	64f2                	ld	s1,280(sp)
    80004d9c:	a03d                	j	80004dca <sys_link+0xf4>
    iunlockput(dp);
    80004d9e:	854a                	mv	a0,s2
    80004da0:	ea8fe0ef          	jal	80003448 <iunlockput>
  ilock(ip);
    80004da4:	8526                	mv	a0,s1
    80004da6:	c98fe0ef          	jal	8000323e <ilock>
  ip->nlink--;
    80004daa:	04a4d783          	lhu	a5,74(s1)
    80004dae:	37fd                	addiw	a5,a5,-1
    80004db0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004db4:	8526                	mv	a0,s1
    80004db6:	bd4fe0ef          	jal	8000318a <iupdate>
  iunlockput(ip);
    80004dba:	8526                	mv	a0,s1
    80004dbc:	e8cfe0ef          	jal	80003448 <iunlockput>
  end_op();
    80004dc0:	ed3fe0ef          	jal	80003c92 <end_op>
  return -1;
    80004dc4:	57fd                	li	a5,-1
    80004dc6:	64f2                	ld	s1,280(sp)
    80004dc8:	6952                	ld	s2,272(sp)
}
    80004dca:	853e                	mv	a0,a5
    80004dcc:	70b2                	ld	ra,296(sp)
    80004dce:	7412                	ld	s0,288(sp)
    80004dd0:	6155                	addi	sp,sp,304
    80004dd2:	8082                	ret

0000000080004dd4 <sys_unlink>:
{
    80004dd4:	7151                	addi	sp,sp,-240
    80004dd6:	f586                	sd	ra,232(sp)
    80004dd8:	f1a2                	sd	s0,224(sp)
    80004dda:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004ddc:	08000613          	li	a2,128
    80004de0:	f3040593          	addi	a1,s0,-208
    80004de4:	4501                	li	a0,0
    80004de6:	a63fd0ef          	jal	80002848 <argstr>
    80004dea:	16054063          	bltz	a0,80004f4a <sys_unlink+0x176>
    80004dee:	eda6                	sd	s1,216(sp)
  begin_op();
    80004df0:	e39fe0ef          	jal	80003c28 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004df4:	fb040593          	addi	a1,s0,-80
    80004df8:	f3040513          	addi	a0,s0,-208
    80004dfc:	c73fe0ef          	jal	80003a6e <nameiparent>
    80004e00:	84aa                	mv	s1,a0
    80004e02:	c945                	beqz	a0,80004eb2 <sys_unlink+0xde>
  ilock(dp);
    80004e04:	c3afe0ef          	jal	8000323e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004e08:	00002597          	auipc	a1,0x2
    80004e0c:	7b858593          	addi	a1,a1,1976 # 800075c0 <etext+0x5c0>
    80004e10:	fb040513          	addi	a0,s0,-80
    80004e14:	9c5fe0ef          	jal	800037d8 <namecmp>
    80004e18:	10050e63          	beqz	a0,80004f34 <sys_unlink+0x160>
    80004e1c:	00002597          	auipc	a1,0x2
    80004e20:	7ac58593          	addi	a1,a1,1964 # 800075c8 <etext+0x5c8>
    80004e24:	fb040513          	addi	a0,s0,-80
    80004e28:	9b1fe0ef          	jal	800037d8 <namecmp>
    80004e2c:	10050463          	beqz	a0,80004f34 <sys_unlink+0x160>
    80004e30:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004e32:	f2c40613          	addi	a2,s0,-212
    80004e36:	fb040593          	addi	a1,s0,-80
    80004e3a:	8526                	mv	a0,s1
    80004e3c:	9b3fe0ef          	jal	800037ee <dirlookup>
    80004e40:	892a                	mv	s2,a0
    80004e42:	0e050863          	beqz	a0,80004f32 <sys_unlink+0x15e>
  ilock(ip);
    80004e46:	bf8fe0ef          	jal	8000323e <ilock>
  if(ip->nlink < 1)
    80004e4a:	04a91783          	lh	a5,74(s2)
    80004e4e:	06f05763          	blez	a5,80004ebc <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004e52:	04491703          	lh	a4,68(s2)
    80004e56:	4785                	li	a5,1
    80004e58:	06f70963          	beq	a4,a5,80004eca <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004e5c:	4641                	li	a2,16
    80004e5e:	4581                	li	a1,0
    80004e60:	fc040513          	addi	a0,s0,-64
    80004e64:	e3ffb0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e68:	4741                	li	a4,16
    80004e6a:	f2c42683          	lw	a3,-212(s0)
    80004e6e:	fc040613          	addi	a2,s0,-64
    80004e72:	4581                	li	a1,0
    80004e74:	8526                	mv	a0,s1
    80004e76:	855fe0ef          	jal	800036ca <writei>
    80004e7a:	47c1                	li	a5,16
    80004e7c:	08f51b63          	bne	a0,a5,80004f12 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004e80:	04491703          	lh	a4,68(s2)
    80004e84:	4785                	li	a5,1
    80004e86:	08f70d63          	beq	a4,a5,80004f20 <sys_unlink+0x14c>
  iunlockput(dp);
    80004e8a:	8526                	mv	a0,s1
    80004e8c:	dbcfe0ef          	jal	80003448 <iunlockput>
  ip->nlink--;
    80004e90:	04a95783          	lhu	a5,74(s2)
    80004e94:	37fd                	addiw	a5,a5,-1
    80004e96:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004e9a:	854a                	mv	a0,s2
    80004e9c:	aeefe0ef          	jal	8000318a <iupdate>
  iunlockput(ip);
    80004ea0:	854a                	mv	a0,s2
    80004ea2:	da6fe0ef          	jal	80003448 <iunlockput>
  end_op();
    80004ea6:	dedfe0ef          	jal	80003c92 <end_op>
  return 0;
    80004eaa:	4501                	li	a0,0
    80004eac:	64ee                	ld	s1,216(sp)
    80004eae:	694e                	ld	s2,208(sp)
    80004eb0:	a849                	j	80004f42 <sys_unlink+0x16e>
    end_op();
    80004eb2:	de1fe0ef          	jal	80003c92 <end_op>
    return -1;
    80004eb6:	557d                	li	a0,-1
    80004eb8:	64ee                	ld	s1,216(sp)
    80004eba:	a061                	j	80004f42 <sys_unlink+0x16e>
    80004ebc:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004ebe:	00002517          	auipc	a0,0x2
    80004ec2:	71250513          	addi	a0,a0,1810 # 800075d0 <etext+0x5d0>
    80004ec6:	91bfb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004eca:	04c92703          	lw	a4,76(s2)
    80004ece:	02000793          	li	a5,32
    80004ed2:	f8e7f5e3          	bgeu	a5,a4,80004e5c <sys_unlink+0x88>
    80004ed6:	e5ce                	sd	s3,200(sp)
    80004ed8:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004edc:	4741                	li	a4,16
    80004ede:	86ce                	mv	a3,s3
    80004ee0:	f1840613          	addi	a2,s0,-232
    80004ee4:	4581                	li	a1,0
    80004ee6:	854a                	mv	a0,s2
    80004ee8:	ee6fe0ef          	jal	800035ce <readi>
    80004eec:	47c1                	li	a5,16
    80004eee:	00f51c63          	bne	a0,a5,80004f06 <sys_unlink+0x132>
    if(de.inum != 0)
    80004ef2:	f1845783          	lhu	a5,-232(s0)
    80004ef6:	efa1                	bnez	a5,80004f4e <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004ef8:	29c1                	addiw	s3,s3,16
    80004efa:	04c92783          	lw	a5,76(s2)
    80004efe:	fcf9efe3          	bltu	s3,a5,80004edc <sys_unlink+0x108>
    80004f02:	69ae                	ld	s3,200(sp)
    80004f04:	bfa1                	j	80004e5c <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004f06:	00002517          	auipc	a0,0x2
    80004f0a:	6e250513          	addi	a0,a0,1762 # 800075e8 <etext+0x5e8>
    80004f0e:	8d3fb0ef          	jal	800007e0 <panic>
    80004f12:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004f14:	00002517          	auipc	a0,0x2
    80004f18:	6ec50513          	addi	a0,a0,1772 # 80007600 <etext+0x600>
    80004f1c:	8c5fb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    80004f20:	04a4d783          	lhu	a5,74(s1)
    80004f24:	37fd                	addiw	a5,a5,-1
    80004f26:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004f2a:	8526                	mv	a0,s1
    80004f2c:	a5efe0ef          	jal	8000318a <iupdate>
    80004f30:	bfa9                	j	80004e8a <sys_unlink+0xb6>
    80004f32:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004f34:	8526                	mv	a0,s1
    80004f36:	d12fe0ef          	jal	80003448 <iunlockput>
  end_op();
    80004f3a:	d59fe0ef          	jal	80003c92 <end_op>
  return -1;
    80004f3e:	557d                	li	a0,-1
    80004f40:	64ee                	ld	s1,216(sp)
}
    80004f42:	70ae                	ld	ra,232(sp)
    80004f44:	740e                	ld	s0,224(sp)
    80004f46:	616d                	addi	sp,sp,240
    80004f48:	8082                	ret
    return -1;
    80004f4a:	557d                	li	a0,-1
    80004f4c:	bfdd                	j	80004f42 <sys_unlink+0x16e>
    iunlockput(ip);
    80004f4e:	854a                	mv	a0,s2
    80004f50:	cf8fe0ef          	jal	80003448 <iunlockput>
    goto bad;
    80004f54:	694e                	ld	s2,208(sp)
    80004f56:	69ae                	ld	s3,200(sp)
    80004f58:	bff1                	j	80004f34 <sys_unlink+0x160>

0000000080004f5a <sys_open>:

uint64
sys_open(void)
{
    80004f5a:	7131                	addi	sp,sp,-192
    80004f5c:	fd06                	sd	ra,184(sp)
    80004f5e:	f922                	sd	s0,176(sp)
    80004f60:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004f62:	f4c40593          	addi	a1,s0,-180
    80004f66:	4505                	li	a0,1
    80004f68:	8a9fd0ef          	jal	80002810 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f6c:	08000613          	li	a2,128
    80004f70:	f5040593          	addi	a1,s0,-176
    80004f74:	4501                	li	a0,0
    80004f76:	8d3fd0ef          	jal	80002848 <argstr>
    80004f7a:	87aa                	mv	a5,a0
    return -1;
    80004f7c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f7e:	0a07c263          	bltz	a5,80005022 <sys_open+0xc8>
    80004f82:	f526                	sd	s1,168(sp)

  begin_op();
    80004f84:	ca5fe0ef          	jal	80003c28 <begin_op>

  if(omode & O_CREATE){
    80004f88:	f4c42783          	lw	a5,-180(s0)
    80004f8c:	2007f793          	andi	a5,a5,512
    80004f90:	c3d5                	beqz	a5,80005034 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004f92:	4681                	li	a3,0
    80004f94:	4601                	li	a2,0
    80004f96:	4589                	li	a1,2
    80004f98:	f5040513          	addi	a0,s0,-176
    80004f9c:	aa9ff0ef          	jal	80004a44 <create>
    80004fa0:	84aa                	mv	s1,a0
    if(ip == 0){
    80004fa2:	c541                	beqz	a0,8000502a <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004fa4:	04449703          	lh	a4,68(s1)
    80004fa8:	478d                	li	a5,3
    80004faa:	00f71763          	bne	a4,a5,80004fb8 <sys_open+0x5e>
    80004fae:	0464d703          	lhu	a4,70(s1)
    80004fb2:	47a5                	li	a5,9
    80004fb4:	0ae7ed63          	bltu	a5,a4,8000506e <sys_open+0x114>
    80004fb8:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004fba:	fd7fe0ef          	jal	80003f90 <filealloc>
    80004fbe:	892a                	mv	s2,a0
    80004fc0:	c179                	beqz	a0,80005086 <sys_open+0x12c>
    80004fc2:	ed4e                	sd	s3,152(sp)
    80004fc4:	a43ff0ef          	jal	80004a06 <fdalloc>
    80004fc8:	89aa                	mv	s3,a0
    80004fca:	0a054a63          	bltz	a0,8000507e <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004fce:	04449703          	lh	a4,68(s1)
    80004fd2:	478d                	li	a5,3
    80004fd4:	0cf70263          	beq	a4,a5,80005098 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004fd8:	4789                	li	a5,2
    80004fda:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004fde:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004fe2:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004fe6:	f4c42783          	lw	a5,-180(s0)
    80004fea:	0017c713          	xori	a4,a5,1
    80004fee:	8b05                	andi	a4,a4,1
    80004ff0:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004ff4:	0037f713          	andi	a4,a5,3
    80004ff8:	00e03733          	snez	a4,a4
    80004ffc:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005000:	4007f793          	andi	a5,a5,1024
    80005004:	c791                	beqz	a5,80005010 <sys_open+0xb6>
    80005006:	04449703          	lh	a4,68(s1)
    8000500a:	4789                	li	a5,2
    8000500c:	08f70d63          	beq	a4,a5,800050a6 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005010:	8526                	mv	a0,s1
    80005012:	adafe0ef          	jal	800032ec <iunlock>
  end_op();
    80005016:	c7dfe0ef          	jal	80003c92 <end_op>

  return fd;
    8000501a:	854e                	mv	a0,s3
    8000501c:	74aa                	ld	s1,168(sp)
    8000501e:	790a                	ld	s2,160(sp)
    80005020:	69ea                	ld	s3,152(sp)
}
    80005022:	70ea                	ld	ra,184(sp)
    80005024:	744a                	ld	s0,176(sp)
    80005026:	6129                	addi	sp,sp,192
    80005028:	8082                	ret
      end_op();
    8000502a:	c69fe0ef          	jal	80003c92 <end_op>
      return -1;
    8000502e:	557d                	li	a0,-1
    80005030:	74aa                	ld	s1,168(sp)
    80005032:	bfc5                	j	80005022 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80005034:	f5040513          	addi	a0,s0,-176
    80005038:	a1dfe0ef          	jal	80003a54 <namei>
    8000503c:	84aa                	mv	s1,a0
    8000503e:	c11d                	beqz	a0,80005064 <sys_open+0x10a>
    ilock(ip);
    80005040:	9fefe0ef          	jal	8000323e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005044:	04449703          	lh	a4,68(s1)
    80005048:	4785                	li	a5,1
    8000504a:	f4f71de3          	bne	a4,a5,80004fa4 <sys_open+0x4a>
    8000504e:	f4c42783          	lw	a5,-180(s0)
    80005052:	d3bd                	beqz	a5,80004fb8 <sys_open+0x5e>
      iunlockput(ip);
    80005054:	8526                	mv	a0,s1
    80005056:	bf2fe0ef          	jal	80003448 <iunlockput>
      end_op();
    8000505a:	c39fe0ef          	jal	80003c92 <end_op>
      return -1;
    8000505e:	557d                	li	a0,-1
    80005060:	74aa                	ld	s1,168(sp)
    80005062:	b7c1                	j	80005022 <sys_open+0xc8>
      end_op();
    80005064:	c2ffe0ef          	jal	80003c92 <end_op>
      return -1;
    80005068:	557d                	li	a0,-1
    8000506a:	74aa                	ld	s1,168(sp)
    8000506c:	bf5d                	j	80005022 <sys_open+0xc8>
    iunlockput(ip);
    8000506e:	8526                	mv	a0,s1
    80005070:	bd8fe0ef          	jal	80003448 <iunlockput>
    end_op();
    80005074:	c1ffe0ef          	jal	80003c92 <end_op>
    return -1;
    80005078:	557d                	li	a0,-1
    8000507a:	74aa                	ld	s1,168(sp)
    8000507c:	b75d                	j	80005022 <sys_open+0xc8>
      fileclose(f);
    8000507e:	854a                	mv	a0,s2
    80005080:	fb5fe0ef          	jal	80004034 <fileclose>
    80005084:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005086:	8526                	mv	a0,s1
    80005088:	bc0fe0ef          	jal	80003448 <iunlockput>
    end_op();
    8000508c:	c07fe0ef          	jal	80003c92 <end_op>
    return -1;
    80005090:	557d                	li	a0,-1
    80005092:	74aa                	ld	s1,168(sp)
    80005094:	790a                	ld	s2,160(sp)
    80005096:	b771                	j	80005022 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005098:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000509c:	04649783          	lh	a5,70(s1)
    800050a0:	02f91223          	sh	a5,36(s2)
    800050a4:	bf3d                	j	80004fe2 <sys_open+0x88>
    itrunc(ip);
    800050a6:	8526                	mv	a0,s1
    800050a8:	a84fe0ef          	jal	8000332c <itrunc>
    800050ac:	b795                	j	80005010 <sys_open+0xb6>

00000000800050ae <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800050ae:	7175                	addi	sp,sp,-144
    800050b0:	e506                	sd	ra,136(sp)
    800050b2:	e122                	sd	s0,128(sp)
    800050b4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800050b6:	b73fe0ef          	jal	80003c28 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800050ba:	08000613          	li	a2,128
    800050be:	f7040593          	addi	a1,s0,-144
    800050c2:	4501                	li	a0,0
    800050c4:	f84fd0ef          	jal	80002848 <argstr>
    800050c8:	02054363          	bltz	a0,800050ee <sys_mkdir+0x40>
    800050cc:	4681                	li	a3,0
    800050ce:	4601                	li	a2,0
    800050d0:	4585                	li	a1,1
    800050d2:	f7040513          	addi	a0,s0,-144
    800050d6:	96fff0ef          	jal	80004a44 <create>
    800050da:	c911                	beqz	a0,800050ee <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800050dc:	b6cfe0ef          	jal	80003448 <iunlockput>
  end_op();
    800050e0:	bb3fe0ef          	jal	80003c92 <end_op>
  return 0;
    800050e4:	4501                	li	a0,0
}
    800050e6:	60aa                	ld	ra,136(sp)
    800050e8:	640a                	ld	s0,128(sp)
    800050ea:	6149                	addi	sp,sp,144
    800050ec:	8082                	ret
    end_op();
    800050ee:	ba5fe0ef          	jal	80003c92 <end_op>
    return -1;
    800050f2:	557d                	li	a0,-1
    800050f4:	bfcd                	j	800050e6 <sys_mkdir+0x38>

00000000800050f6 <sys_mknod>:

uint64
sys_mknod(void)
{
    800050f6:	7135                	addi	sp,sp,-160
    800050f8:	ed06                	sd	ra,152(sp)
    800050fa:	e922                	sd	s0,144(sp)
    800050fc:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800050fe:	b2bfe0ef          	jal	80003c28 <begin_op>
  argint(1, &major);
    80005102:	f6c40593          	addi	a1,s0,-148
    80005106:	4505                	li	a0,1
    80005108:	f08fd0ef          	jal	80002810 <argint>
  argint(2, &minor);
    8000510c:	f6840593          	addi	a1,s0,-152
    80005110:	4509                	li	a0,2
    80005112:	efefd0ef          	jal	80002810 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005116:	08000613          	li	a2,128
    8000511a:	f7040593          	addi	a1,s0,-144
    8000511e:	4501                	li	a0,0
    80005120:	f28fd0ef          	jal	80002848 <argstr>
    80005124:	02054563          	bltz	a0,8000514e <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005128:	f6841683          	lh	a3,-152(s0)
    8000512c:	f6c41603          	lh	a2,-148(s0)
    80005130:	458d                	li	a1,3
    80005132:	f7040513          	addi	a0,s0,-144
    80005136:	90fff0ef          	jal	80004a44 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000513a:	c911                	beqz	a0,8000514e <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000513c:	b0cfe0ef          	jal	80003448 <iunlockput>
  end_op();
    80005140:	b53fe0ef          	jal	80003c92 <end_op>
  return 0;
    80005144:	4501                	li	a0,0
}
    80005146:	60ea                	ld	ra,152(sp)
    80005148:	644a                	ld	s0,144(sp)
    8000514a:	610d                	addi	sp,sp,160
    8000514c:	8082                	ret
    end_op();
    8000514e:	b45fe0ef          	jal	80003c92 <end_op>
    return -1;
    80005152:	557d                	li	a0,-1
    80005154:	bfcd                	j	80005146 <sys_mknod+0x50>

0000000080005156 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005156:	7135                	addi	sp,sp,-160
    80005158:	ed06                	sd	ra,152(sp)
    8000515a:	e922                	sd	s0,144(sp)
    8000515c:	e14a                	sd	s2,128(sp)
    8000515e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005160:	f6efc0ef          	jal	800018ce <myproc>
    80005164:	892a                	mv	s2,a0
  
  begin_op();
    80005166:	ac3fe0ef          	jal	80003c28 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000516a:	08000613          	li	a2,128
    8000516e:	f6040593          	addi	a1,s0,-160
    80005172:	4501                	li	a0,0
    80005174:	ed4fd0ef          	jal	80002848 <argstr>
    80005178:	04054363          	bltz	a0,800051be <sys_chdir+0x68>
    8000517c:	e526                	sd	s1,136(sp)
    8000517e:	f6040513          	addi	a0,s0,-160
    80005182:	8d3fe0ef          	jal	80003a54 <namei>
    80005186:	84aa                	mv	s1,a0
    80005188:	c915                	beqz	a0,800051bc <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000518a:	8b4fe0ef          	jal	8000323e <ilock>
  if(ip->type != T_DIR){
    8000518e:	04449703          	lh	a4,68(s1)
    80005192:	4785                	li	a5,1
    80005194:	02f71963          	bne	a4,a5,800051c6 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005198:	8526                	mv	a0,s1
    8000519a:	952fe0ef          	jal	800032ec <iunlock>
  iput(p->cwd);
    8000519e:	15093503          	ld	a0,336(s2)
    800051a2:	a1efe0ef          	jal	800033c0 <iput>
  end_op();
    800051a6:	aedfe0ef          	jal	80003c92 <end_op>
  p->cwd = ip;
    800051aa:	14993823          	sd	s1,336(s2)
  return 0;
    800051ae:	4501                	li	a0,0
    800051b0:	64aa                	ld	s1,136(sp)
}
    800051b2:	60ea                	ld	ra,152(sp)
    800051b4:	644a                	ld	s0,144(sp)
    800051b6:	690a                	ld	s2,128(sp)
    800051b8:	610d                	addi	sp,sp,160
    800051ba:	8082                	ret
    800051bc:	64aa                	ld	s1,136(sp)
    end_op();
    800051be:	ad5fe0ef          	jal	80003c92 <end_op>
    return -1;
    800051c2:	557d                	li	a0,-1
    800051c4:	b7fd                	j	800051b2 <sys_chdir+0x5c>
    iunlockput(ip);
    800051c6:	8526                	mv	a0,s1
    800051c8:	a80fe0ef          	jal	80003448 <iunlockput>
    end_op();
    800051cc:	ac7fe0ef          	jal	80003c92 <end_op>
    return -1;
    800051d0:	557d                	li	a0,-1
    800051d2:	64aa                	ld	s1,136(sp)
    800051d4:	bff9                	j	800051b2 <sys_chdir+0x5c>

00000000800051d6 <sys_exec>:

uint64
sys_exec(void)
{
    800051d6:	7121                	addi	sp,sp,-448
    800051d8:	ff06                	sd	ra,440(sp)
    800051da:	fb22                	sd	s0,432(sp)
    800051dc:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800051de:	e4840593          	addi	a1,s0,-440
    800051e2:	4505                	li	a0,1
    800051e4:	e48fd0ef          	jal	8000282c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800051e8:	08000613          	li	a2,128
    800051ec:	f5040593          	addi	a1,s0,-176
    800051f0:	4501                	li	a0,0
    800051f2:	e56fd0ef          	jal	80002848 <argstr>
    800051f6:	87aa                	mv	a5,a0
    return -1;
    800051f8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800051fa:	0c07c463          	bltz	a5,800052c2 <sys_exec+0xec>
    800051fe:	f726                	sd	s1,424(sp)
    80005200:	f34a                	sd	s2,416(sp)
    80005202:	ef4e                	sd	s3,408(sp)
    80005204:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005206:	10000613          	li	a2,256
    8000520a:	4581                	li	a1,0
    8000520c:	e5040513          	addi	a0,s0,-432
    80005210:	a93fb0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005214:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005218:	89a6                	mv	s3,s1
    8000521a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000521c:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005220:	00391513          	slli	a0,s2,0x3
    80005224:	e4040593          	addi	a1,s0,-448
    80005228:	e4843783          	ld	a5,-440(s0)
    8000522c:	953e                	add	a0,a0,a5
    8000522e:	d58fd0ef          	jal	80002786 <fetchaddr>
    80005232:	02054663          	bltz	a0,8000525e <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005236:	e4043783          	ld	a5,-448(s0)
    8000523a:	c3a9                	beqz	a5,8000527c <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000523c:	8c3fb0ef          	jal	80000afe <kalloc>
    80005240:	85aa                	mv	a1,a0
    80005242:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005246:	cd01                	beqz	a0,8000525e <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005248:	6605                	lui	a2,0x1
    8000524a:	e4043503          	ld	a0,-448(s0)
    8000524e:	d82fd0ef          	jal	800027d0 <fetchstr>
    80005252:	00054663          	bltz	a0,8000525e <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005256:	0905                	addi	s2,s2,1
    80005258:	09a1                	addi	s3,s3,8
    8000525a:	fd4913e3          	bne	s2,s4,80005220 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000525e:	f5040913          	addi	s2,s0,-176
    80005262:	6088                	ld	a0,0(s1)
    80005264:	c931                	beqz	a0,800052b8 <sys_exec+0xe2>
    kfree(argv[i]);
    80005266:	fb6fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000526a:	04a1                	addi	s1,s1,8
    8000526c:	ff249be3          	bne	s1,s2,80005262 <sys_exec+0x8c>
  return -1;
    80005270:	557d                	li	a0,-1
    80005272:	74ba                	ld	s1,424(sp)
    80005274:	791a                	ld	s2,416(sp)
    80005276:	69fa                	ld	s3,408(sp)
    80005278:	6a5a                	ld	s4,400(sp)
    8000527a:	a0a1                	j	800052c2 <sys_exec+0xec>
      argv[i] = 0;
    8000527c:	0009079b          	sext.w	a5,s2
    80005280:	078e                	slli	a5,a5,0x3
    80005282:	fd078793          	addi	a5,a5,-48
    80005286:	97a2                	add	a5,a5,s0
    80005288:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    8000528c:	e5040593          	addi	a1,s0,-432
    80005290:	f5040513          	addi	a0,s0,-176
    80005294:	ba8ff0ef          	jal	8000463c <kexec>
    80005298:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000529a:	f5040993          	addi	s3,s0,-176
    8000529e:	6088                	ld	a0,0(s1)
    800052a0:	c511                	beqz	a0,800052ac <sys_exec+0xd6>
    kfree(argv[i]);
    800052a2:	f7afb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052a6:	04a1                	addi	s1,s1,8
    800052a8:	ff349be3          	bne	s1,s3,8000529e <sys_exec+0xc8>
  return ret;
    800052ac:	854a                	mv	a0,s2
    800052ae:	74ba                	ld	s1,424(sp)
    800052b0:	791a                	ld	s2,416(sp)
    800052b2:	69fa                	ld	s3,408(sp)
    800052b4:	6a5a                	ld	s4,400(sp)
    800052b6:	a031                	j	800052c2 <sys_exec+0xec>
  return -1;
    800052b8:	557d                	li	a0,-1
    800052ba:	74ba                	ld	s1,424(sp)
    800052bc:	791a                	ld	s2,416(sp)
    800052be:	69fa                	ld	s3,408(sp)
    800052c0:	6a5a                	ld	s4,400(sp)
}
    800052c2:	70fa                	ld	ra,440(sp)
    800052c4:	745a                	ld	s0,432(sp)
    800052c6:	6139                	addi	sp,sp,448
    800052c8:	8082                	ret

00000000800052ca <sys_pipe>:

uint64
sys_pipe(void)
{
    800052ca:	7139                	addi	sp,sp,-64
    800052cc:	fc06                	sd	ra,56(sp)
    800052ce:	f822                	sd	s0,48(sp)
    800052d0:	f426                	sd	s1,40(sp)
    800052d2:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800052d4:	dfafc0ef          	jal	800018ce <myproc>
    800052d8:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800052da:	fd840593          	addi	a1,s0,-40
    800052de:	4501                	li	a0,0
    800052e0:	d4cfd0ef          	jal	8000282c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800052e4:	fc840593          	addi	a1,s0,-56
    800052e8:	fd040513          	addi	a0,s0,-48
    800052ec:	852ff0ef          	jal	8000433e <pipealloc>
    return -1;
    800052f0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800052f2:	0a054463          	bltz	a0,8000539a <sys_pipe+0xd0>
  fd0 = -1;
    800052f6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800052fa:	fd043503          	ld	a0,-48(s0)
    800052fe:	f08ff0ef          	jal	80004a06 <fdalloc>
    80005302:	fca42223          	sw	a0,-60(s0)
    80005306:	08054163          	bltz	a0,80005388 <sys_pipe+0xbe>
    8000530a:	fc843503          	ld	a0,-56(s0)
    8000530e:	ef8ff0ef          	jal	80004a06 <fdalloc>
    80005312:	fca42023          	sw	a0,-64(s0)
    80005316:	06054063          	bltz	a0,80005376 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000531a:	4691                	li	a3,4
    8000531c:	fc440613          	addi	a2,s0,-60
    80005320:	fd843583          	ld	a1,-40(s0)
    80005324:	68a8                	ld	a0,80(s1)
    80005326:	abcfc0ef          	jal	800015e2 <copyout>
    8000532a:	00054e63          	bltz	a0,80005346 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000532e:	4691                	li	a3,4
    80005330:	fc040613          	addi	a2,s0,-64
    80005334:	fd843583          	ld	a1,-40(s0)
    80005338:	0591                	addi	a1,a1,4
    8000533a:	68a8                	ld	a0,80(s1)
    8000533c:	aa6fc0ef          	jal	800015e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005340:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005342:	04055c63          	bgez	a0,8000539a <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005346:	fc442783          	lw	a5,-60(s0)
    8000534a:	07e9                	addi	a5,a5,26
    8000534c:	078e                	slli	a5,a5,0x3
    8000534e:	97a6                	add	a5,a5,s1
    80005350:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005354:	fc042783          	lw	a5,-64(s0)
    80005358:	07e9                	addi	a5,a5,26
    8000535a:	078e                	slli	a5,a5,0x3
    8000535c:	94be                	add	s1,s1,a5
    8000535e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005362:	fd043503          	ld	a0,-48(s0)
    80005366:	ccffe0ef          	jal	80004034 <fileclose>
    fileclose(wf);
    8000536a:	fc843503          	ld	a0,-56(s0)
    8000536e:	cc7fe0ef          	jal	80004034 <fileclose>
    return -1;
    80005372:	57fd                	li	a5,-1
    80005374:	a01d                	j	8000539a <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005376:	fc442783          	lw	a5,-60(s0)
    8000537a:	0007c763          	bltz	a5,80005388 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000537e:	07e9                	addi	a5,a5,26
    80005380:	078e                	slli	a5,a5,0x3
    80005382:	97a6                	add	a5,a5,s1
    80005384:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005388:	fd043503          	ld	a0,-48(s0)
    8000538c:	ca9fe0ef          	jal	80004034 <fileclose>
    fileclose(wf);
    80005390:	fc843503          	ld	a0,-56(s0)
    80005394:	ca1fe0ef          	jal	80004034 <fileclose>
    return -1;
    80005398:	57fd                	li	a5,-1
}
    8000539a:	853e                	mv	a0,a5
    8000539c:	70e2                	ld	ra,56(sp)
    8000539e:	7442                	ld	s0,48(sp)
    800053a0:	74a2                	ld	s1,40(sp)
    800053a2:	6121                	addi	sp,sp,64
    800053a4:	8082                	ret
	...

00000000800053b0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800053b0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800053b2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800053b4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    800053b6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    800053b8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800053ba:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800053bc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800053be:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800053c0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800053c2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800053c4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800053c6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800053c8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800053ca:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800053cc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800053ce:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800053d0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800053d2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800053d4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800053d6:	ac0fd0ef          	jal	80002696 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800053da:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800053dc:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800053de:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800053e0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800053e2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800053e4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800053e6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800053e8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800053ea:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800053ec:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800053ee:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800053f0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800053f2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800053f4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800053f6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800053f8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800053fa:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800053fc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800053fe:	10200073          	sret
	...

000000008000540e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000540e:	1141                	addi	sp,sp,-16
    80005410:	e422                	sd	s0,8(sp)
    80005412:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005414:	0c0007b7          	lui	a5,0xc000
    80005418:	4705                	li	a4,1
    8000541a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000541c:	0c0007b7          	lui	a5,0xc000
    80005420:	c3d8                	sw	a4,4(a5)
}
    80005422:	6422                	ld	s0,8(sp)
    80005424:	0141                	addi	sp,sp,16
    80005426:	8082                	ret

0000000080005428 <plicinithart>:

void
plicinithart(void)
{
    80005428:	1141                	addi	sp,sp,-16
    8000542a:	e406                	sd	ra,8(sp)
    8000542c:	e022                	sd	s0,0(sp)
    8000542e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005430:	c72fc0ef          	jal	800018a2 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005434:	0085171b          	slliw	a4,a0,0x8
    80005438:	0c0027b7          	lui	a5,0xc002
    8000543c:	97ba                	add	a5,a5,a4
    8000543e:	40200713          	li	a4,1026
    80005442:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005446:	00d5151b          	slliw	a0,a0,0xd
    8000544a:	0c2017b7          	lui	a5,0xc201
    8000544e:	97aa                	add	a5,a5,a0
    80005450:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005454:	60a2                	ld	ra,8(sp)
    80005456:	6402                	ld	s0,0(sp)
    80005458:	0141                	addi	sp,sp,16
    8000545a:	8082                	ret

000000008000545c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000545c:	1141                	addi	sp,sp,-16
    8000545e:	e406                	sd	ra,8(sp)
    80005460:	e022                	sd	s0,0(sp)
    80005462:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005464:	c3efc0ef          	jal	800018a2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005468:	00d5151b          	slliw	a0,a0,0xd
    8000546c:	0c2017b7          	lui	a5,0xc201
    80005470:	97aa                	add	a5,a5,a0
  return irq;
}
    80005472:	43c8                	lw	a0,4(a5)
    80005474:	60a2                	ld	ra,8(sp)
    80005476:	6402                	ld	s0,0(sp)
    80005478:	0141                	addi	sp,sp,16
    8000547a:	8082                	ret

000000008000547c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000547c:	1101                	addi	sp,sp,-32
    8000547e:	ec06                	sd	ra,24(sp)
    80005480:	e822                	sd	s0,16(sp)
    80005482:	e426                	sd	s1,8(sp)
    80005484:	1000                	addi	s0,sp,32
    80005486:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005488:	c1afc0ef          	jal	800018a2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000548c:	00d5151b          	slliw	a0,a0,0xd
    80005490:	0c2017b7          	lui	a5,0xc201
    80005494:	97aa                	add	a5,a5,a0
    80005496:	c3c4                	sw	s1,4(a5)
}
    80005498:	60e2                	ld	ra,24(sp)
    8000549a:	6442                	ld	s0,16(sp)
    8000549c:	64a2                	ld	s1,8(sp)
    8000549e:	6105                	addi	sp,sp,32
    800054a0:	8082                	ret

00000000800054a2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800054a2:	1141                	addi	sp,sp,-16
    800054a4:	e406                	sd	ra,8(sp)
    800054a6:	e022                	sd	s0,0(sp)
    800054a8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800054aa:	479d                	li	a5,7
    800054ac:	04a7ca63          	blt	a5,a0,80005500 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800054b0:	0001b797          	auipc	a5,0x1b
    800054b4:	78878793          	addi	a5,a5,1928 # 80020c38 <disk>
    800054b8:	97aa                	add	a5,a5,a0
    800054ba:	0187c783          	lbu	a5,24(a5)
    800054be:	e7b9                	bnez	a5,8000550c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800054c0:	00451693          	slli	a3,a0,0x4
    800054c4:	0001b797          	auipc	a5,0x1b
    800054c8:	77478793          	addi	a5,a5,1908 # 80020c38 <disk>
    800054cc:	6398                	ld	a4,0(a5)
    800054ce:	9736                	add	a4,a4,a3
    800054d0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800054d4:	6398                	ld	a4,0(a5)
    800054d6:	9736                	add	a4,a4,a3
    800054d8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800054dc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800054e0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800054e4:	97aa                	add	a5,a5,a0
    800054e6:	4705                	li	a4,1
    800054e8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800054ec:	0001b517          	auipc	a0,0x1b
    800054f0:	76450513          	addi	a0,a0,1892 # 80020c50 <disk+0x18>
    800054f4:	a65fc0ef          	jal	80001f58 <wakeup>
}
    800054f8:	60a2                	ld	ra,8(sp)
    800054fa:	6402                	ld	s0,0(sp)
    800054fc:	0141                	addi	sp,sp,16
    800054fe:	8082                	ret
    panic("free_desc 1");
    80005500:	00002517          	auipc	a0,0x2
    80005504:	11050513          	addi	a0,a0,272 # 80007610 <etext+0x610>
    80005508:	ad8fb0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    8000550c:	00002517          	auipc	a0,0x2
    80005510:	11450513          	addi	a0,a0,276 # 80007620 <etext+0x620>
    80005514:	accfb0ef          	jal	800007e0 <panic>

0000000080005518 <virtio_disk_init>:
{
    80005518:	1101                	addi	sp,sp,-32
    8000551a:	ec06                	sd	ra,24(sp)
    8000551c:	e822                	sd	s0,16(sp)
    8000551e:	e426                	sd	s1,8(sp)
    80005520:	e04a                	sd	s2,0(sp)
    80005522:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005524:	00002597          	auipc	a1,0x2
    80005528:	10c58593          	addi	a1,a1,268 # 80007630 <etext+0x630>
    8000552c:	0001c517          	auipc	a0,0x1c
    80005530:	83450513          	addi	a0,a0,-1996 # 80020d60 <disk+0x128>
    80005534:	e1afb0ef          	jal	80000b4e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005538:	100017b7          	lui	a5,0x10001
    8000553c:	4398                	lw	a4,0(a5)
    8000553e:	2701                	sext.w	a4,a4
    80005540:	747277b7          	lui	a5,0x74727
    80005544:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005548:	18f71063          	bne	a4,a5,800056c8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000554c:	100017b7          	lui	a5,0x10001
    80005550:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005552:	439c                	lw	a5,0(a5)
    80005554:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005556:	4709                	li	a4,2
    80005558:	16e79863          	bne	a5,a4,800056c8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000555c:	100017b7          	lui	a5,0x10001
    80005560:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005562:	439c                	lw	a5,0(a5)
    80005564:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005566:	16e79163          	bne	a5,a4,800056c8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000556a:	100017b7          	lui	a5,0x10001
    8000556e:	47d8                	lw	a4,12(a5)
    80005570:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005572:	554d47b7          	lui	a5,0x554d4
    80005576:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000557a:	14f71763          	bne	a4,a5,800056c8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000557e:	100017b7          	lui	a5,0x10001
    80005582:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005586:	4705                	li	a4,1
    80005588:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000558a:	470d                	li	a4,3
    8000558c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000558e:	10001737          	lui	a4,0x10001
    80005592:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005594:	c7ffe737          	lui	a4,0xc7ffe
    80005598:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd9e7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000559c:	8ef9                	and	a3,a3,a4
    8000559e:	10001737          	lui	a4,0x10001
    800055a2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800055a4:	472d                	li	a4,11
    800055a6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800055a8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800055ac:	439c                	lw	a5,0(a5)
    800055ae:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800055b2:	8ba1                	andi	a5,a5,8
    800055b4:	12078063          	beqz	a5,800056d4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800055b8:	100017b7          	lui	a5,0x10001
    800055bc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800055c0:	100017b7          	lui	a5,0x10001
    800055c4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800055c8:	439c                	lw	a5,0(a5)
    800055ca:	2781                	sext.w	a5,a5
    800055cc:	10079a63          	bnez	a5,800056e0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800055d0:	100017b7          	lui	a5,0x10001
    800055d4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800055d8:	439c                	lw	a5,0(a5)
    800055da:	2781                	sext.w	a5,a5
  if(max == 0)
    800055dc:	10078863          	beqz	a5,800056ec <virtio_disk_init+0x1d4>
  if(max < NUM)
    800055e0:	471d                	li	a4,7
    800055e2:	10f77b63          	bgeu	a4,a5,800056f8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800055e6:	d18fb0ef          	jal	80000afe <kalloc>
    800055ea:	0001b497          	auipc	s1,0x1b
    800055ee:	64e48493          	addi	s1,s1,1614 # 80020c38 <disk>
    800055f2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800055f4:	d0afb0ef          	jal	80000afe <kalloc>
    800055f8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800055fa:	d04fb0ef          	jal	80000afe <kalloc>
    800055fe:	87aa                	mv	a5,a0
    80005600:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005602:	6088                	ld	a0,0(s1)
    80005604:	10050063          	beqz	a0,80005704 <virtio_disk_init+0x1ec>
    80005608:	0001b717          	auipc	a4,0x1b
    8000560c:	63873703          	ld	a4,1592(a4) # 80020c40 <disk+0x8>
    80005610:	0e070a63          	beqz	a4,80005704 <virtio_disk_init+0x1ec>
    80005614:	0e078863          	beqz	a5,80005704 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005618:	6605                	lui	a2,0x1
    8000561a:	4581                	li	a1,0
    8000561c:	e86fb0ef          	jal	80000ca2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005620:	0001b497          	auipc	s1,0x1b
    80005624:	61848493          	addi	s1,s1,1560 # 80020c38 <disk>
    80005628:	6605                	lui	a2,0x1
    8000562a:	4581                	li	a1,0
    8000562c:	6488                	ld	a0,8(s1)
    8000562e:	e74fb0ef          	jal	80000ca2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005632:	6605                	lui	a2,0x1
    80005634:	4581                	li	a1,0
    80005636:	6888                	ld	a0,16(s1)
    80005638:	e6afb0ef          	jal	80000ca2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000563c:	100017b7          	lui	a5,0x10001
    80005640:	4721                	li	a4,8
    80005642:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005644:	4098                	lw	a4,0(s1)
    80005646:	100017b7          	lui	a5,0x10001
    8000564a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000564e:	40d8                	lw	a4,4(s1)
    80005650:	100017b7          	lui	a5,0x10001
    80005654:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005658:	649c                	ld	a5,8(s1)
    8000565a:	0007869b          	sext.w	a3,a5
    8000565e:	10001737          	lui	a4,0x10001
    80005662:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005666:	9781                	srai	a5,a5,0x20
    80005668:	10001737          	lui	a4,0x10001
    8000566c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005670:	689c                	ld	a5,16(s1)
    80005672:	0007869b          	sext.w	a3,a5
    80005676:	10001737          	lui	a4,0x10001
    8000567a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000567e:	9781                	srai	a5,a5,0x20
    80005680:	10001737          	lui	a4,0x10001
    80005684:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005688:	10001737          	lui	a4,0x10001
    8000568c:	4785                	li	a5,1
    8000568e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005690:	00f48c23          	sb	a5,24(s1)
    80005694:	00f48ca3          	sb	a5,25(s1)
    80005698:	00f48d23          	sb	a5,26(s1)
    8000569c:	00f48da3          	sb	a5,27(s1)
    800056a0:	00f48e23          	sb	a5,28(s1)
    800056a4:	00f48ea3          	sb	a5,29(s1)
    800056a8:	00f48f23          	sb	a5,30(s1)
    800056ac:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800056b0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800056b4:	100017b7          	lui	a5,0x10001
    800056b8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800056bc:	60e2                	ld	ra,24(sp)
    800056be:	6442                	ld	s0,16(sp)
    800056c0:	64a2                	ld	s1,8(sp)
    800056c2:	6902                	ld	s2,0(sp)
    800056c4:	6105                	addi	sp,sp,32
    800056c6:	8082                	ret
    panic("could not find virtio disk");
    800056c8:	00002517          	auipc	a0,0x2
    800056cc:	f7850513          	addi	a0,a0,-136 # 80007640 <etext+0x640>
    800056d0:	910fb0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    800056d4:	00002517          	auipc	a0,0x2
    800056d8:	f8c50513          	addi	a0,a0,-116 # 80007660 <etext+0x660>
    800056dc:	904fb0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    800056e0:	00002517          	auipc	a0,0x2
    800056e4:	fa050513          	addi	a0,a0,-96 # 80007680 <etext+0x680>
    800056e8:	8f8fb0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    800056ec:	00002517          	auipc	a0,0x2
    800056f0:	fb450513          	addi	a0,a0,-76 # 800076a0 <etext+0x6a0>
    800056f4:	8ecfb0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    800056f8:	00002517          	auipc	a0,0x2
    800056fc:	fc850513          	addi	a0,a0,-56 # 800076c0 <etext+0x6c0>
    80005700:	8e0fb0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    80005704:	00002517          	auipc	a0,0x2
    80005708:	fdc50513          	addi	a0,a0,-36 # 800076e0 <etext+0x6e0>
    8000570c:	8d4fb0ef          	jal	800007e0 <panic>

0000000080005710 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005710:	7159                	addi	sp,sp,-112
    80005712:	f486                	sd	ra,104(sp)
    80005714:	f0a2                	sd	s0,96(sp)
    80005716:	eca6                	sd	s1,88(sp)
    80005718:	e8ca                	sd	s2,80(sp)
    8000571a:	e4ce                	sd	s3,72(sp)
    8000571c:	e0d2                	sd	s4,64(sp)
    8000571e:	fc56                	sd	s5,56(sp)
    80005720:	f85a                	sd	s6,48(sp)
    80005722:	f45e                	sd	s7,40(sp)
    80005724:	f062                	sd	s8,32(sp)
    80005726:	ec66                	sd	s9,24(sp)
    80005728:	1880                	addi	s0,sp,112
    8000572a:	8a2a                	mv	s4,a0
    8000572c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000572e:	00c52c83          	lw	s9,12(a0)
    80005732:	001c9c9b          	slliw	s9,s9,0x1
    80005736:	1c82                	slli	s9,s9,0x20
    80005738:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000573c:	0001b517          	auipc	a0,0x1b
    80005740:	62450513          	addi	a0,a0,1572 # 80020d60 <disk+0x128>
    80005744:	c8afb0ef          	jal	80000bce <acquire>
  for(int i = 0; i < 3; i++){
    80005748:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000574a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000574c:	0001bb17          	auipc	s6,0x1b
    80005750:	4ecb0b13          	addi	s6,s6,1260 # 80020c38 <disk>
  for(int i = 0; i < 3; i++){
    80005754:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005756:	0001bc17          	auipc	s8,0x1b
    8000575a:	60ac0c13          	addi	s8,s8,1546 # 80020d60 <disk+0x128>
    8000575e:	a8b9                	j	800057bc <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005760:	00fb0733          	add	a4,s6,a5
    80005764:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005768:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000576a:	0207c563          	bltz	a5,80005794 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000576e:	2905                	addiw	s2,s2,1
    80005770:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005772:	05590963          	beq	s2,s5,800057c4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005776:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005778:	0001b717          	auipc	a4,0x1b
    8000577c:	4c070713          	addi	a4,a4,1216 # 80020c38 <disk>
    80005780:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005782:	01874683          	lbu	a3,24(a4)
    80005786:	fee9                	bnez	a3,80005760 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005788:	2785                	addiw	a5,a5,1
    8000578a:	0705                	addi	a4,a4,1
    8000578c:	fe979be3          	bne	a5,s1,80005782 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005790:	57fd                	li	a5,-1
    80005792:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005794:	01205d63          	blez	s2,800057ae <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005798:	f9042503          	lw	a0,-112(s0)
    8000579c:	d07ff0ef          	jal	800054a2 <free_desc>
      for(int j = 0; j < i; j++)
    800057a0:	4785                	li	a5,1
    800057a2:	0127d663          	bge	a5,s2,800057ae <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800057a6:	f9442503          	lw	a0,-108(s0)
    800057aa:	cf9ff0ef          	jal	800054a2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800057ae:	85e2                	mv	a1,s8
    800057b0:	0001b517          	auipc	a0,0x1b
    800057b4:	4a050513          	addi	a0,a0,1184 # 80020c50 <disk+0x18>
    800057b8:	f54fc0ef          	jal	80001f0c <sleep>
  for(int i = 0; i < 3; i++){
    800057bc:	f9040613          	addi	a2,s0,-112
    800057c0:	894e                	mv	s2,s3
    800057c2:	bf55                	j	80005776 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800057c4:	f9042503          	lw	a0,-112(s0)
    800057c8:	00451693          	slli	a3,a0,0x4

  if(write)
    800057cc:	0001b797          	auipc	a5,0x1b
    800057d0:	46c78793          	addi	a5,a5,1132 # 80020c38 <disk>
    800057d4:	00a50713          	addi	a4,a0,10
    800057d8:	0712                	slli	a4,a4,0x4
    800057da:	973e                	add	a4,a4,a5
    800057dc:	01703633          	snez	a2,s7
    800057e0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800057e2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800057e6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800057ea:	6398                	ld	a4,0(a5)
    800057ec:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800057ee:	0a868613          	addi	a2,a3,168
    800057f2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800057f4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800057f6:	6390                	ld	a2,0(a5)
    800057f8:	00d605b3          	add	a1,a2,a3
    800057fc:	4741                	li	a4,16
    800057fe:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005800:	4805                	li	a6,1
    80005802:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005806:	f9442703          	lw	a4,-108(s0)
    8000580a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000580e:	0712                	slli	a4,a4,0x4
    80005810:	963a                	add	a2,a2,a4
    80005812:	058a0593          	addi	a1,s4,88
    80005816:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005818:	0007b883          	ld	a7,0(a5)
    8000581c:	9746                	add	a4,a4,a7
    8000581e:	40000613          	li	a2,1024
    80005822:	c710                	sw	a2,8(a4)
  if(write)
    80005824:	001bb613          	seqz	a2,s7
    80005828:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000582c:	00166613          	ori	a2,a2,1
    80005830:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005834:	f9842583          	lw	a1,-104(s0)
    80005838:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000583c:	00250613          	addi	a2,a0,2
    80005840:	0612                	slli	a2,a2,0x4
    80005842:	963e                	add	a2,a2,a5
    80005844:	577d                	li	a4,-1
    80005846:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000584a:	0592                	slli	a1,a1,0x4
    8000584c:	98ae                	add	a7,a7,a1
    8000584e:	03068713          	addi	a4,a3,48
    80005852:	973e                	add	a4,a4,a5
    80005854:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005858:	6398                	ld	a4,0(a5)
    8000585a:	972e                	add	a4,a4,a1
    8000585c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005860:	4689                	li	a3,2
    80005862:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005866:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000586a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000586e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005872:	6794                	ld	a3,8(a5)
    80005874:	0026d703          	lhu	a4,2(a3)
    80005878:	8b1d                	andi	a4,a4,7
    8000587a:	0706                	slli	a4,a4,0x1
    8000587c:	96ba                	add	a3,a3,a4
    8000587e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005882:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005886:	6798                	ld	a4,8(a5)
    80005888:	00275783          	lhu	a5,2(a4)
    8000588c:	2785                	addiw	a5,a5,1
    8000588e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005892:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005896:	100017b7          	lui	a5,0x10001
    8000589a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000589e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800058a2:	0001b917          	auipc	s2,0x1b
    800058a6:	4be90913          	addi	s2,s2,1214 # 80020d60 <disk+0x128>
  while(b->disk == 1) {
    800058aa:	4485                	li	s1,1
    800058ac:	01079a63          	bne	a5,a6,800058c0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    800058b0:	85ca                	mv	a1,s2
    800058b2:	8552                	mv	a0,s4
    800058b4:	e58fc0ef          	jal	80001f0c <sleep>
  while(b->disk == 1) {
    800058b8:	004a2783          	lw	a5,4(s4)
    800058bc:	fe978ae3          	beq	a5,s1,800058b0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    800058c0:	f9042903          	lw	s2,-112(s0)
    800058c4:	00290713          	addi	a4,s2,2
    800058c8:	0712                	slli	a4,a4,0x4
    800058ca:	0001b797          	auipc	a5,0x1b
    800058ce:	36e78793          	addi	a5,a5,878 # 80020c38 <disk>
    800058d2:	97ba                	add	a5,a5,a4
    800058d4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800058d8:	0001b997          	auipc	s3,0x1b
    800058dc:	36098993          	addi	s3,s3,864 # 80020c38 <disk>
    800058e0:	00491713          	slli	a4,s2,0x4
    800058e4:	0009b783          	ld	a5,0(s3)
    800058e8:	97ba                	add	a5,a5,a4
    800058ea:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800058ee:	854a                	mv	a0,s2
    800058f0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800058f4:	bafff0ef          	jal	800054a2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800058f8:	8885                	andi	s1,s1,1
    800058fa:	f0fd                	bnez	s1,800058e0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800058fc:	0001b517          	auipc	a0,0x1b
    80005900:	46450513          	addi	a0,a0,1124 # 80020d60 <disk+0x128>
    80005904:	b62fb0ef          	jal	80000c66 <release>
}
    80005908:	70a6                	ld	ra,104(sp)
    8000590a:	7406                	ld	s0,96(sp)
    8000590c:	64e6                	ld	s1,88(sp)
    8000590e:	6946                	ld	s2,80(sp)
    80005910:	69a6                	ld	s3,72(sp)
    80005912:	6a06                	ld	s4,64(sp)
    80005914:	7ae2                	ld	s5,56(sp)
    80005916:	7b42                	ld	s6,48(sp)
    80005918:	7ba2                	ld	s7,40(sp)
    8000591a:	7c02                	ld	s8,32(sp)
    8000591c:	6ce2                	ld	s9,24(sp)
    8000591e:	6165                	addi	sp,sp,112
    80005920:	8082                	ret

0000000080005922 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005922:	1101                	addi	sp,sp,-32
    80005924:	ec06                	sd	ra,24(sp)
    80005926:	e822                	sd	s0,16(sp)
    80005928:	e426                	sd	s1,8(sp)
    8000592a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000592c:	0001b497          	auipc	s1,0x1b
    80005930:	30c48493          	addi	s1,s1,780 # 80020c38 <disk>
    80005934:	0001b517          	auipc	a0,0x1b
    80005938:	42c50513          	addi	a0,a0,1068 # 80020d60 <disk+0x128>
    8000593c:	a92fb0ef          	jal	80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005940:	100017b7          	lui	a5,0x10001
    80005944:	53b8                	lw	a4,96(a5)
    80005946:	8b0d                	andi	a4,a4,3
    80005948:	100017b7          	lui	a5,0x10001
    8000594c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000594e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005952:	689c                	ld	a5,16(s1)
    80005954:	0204d703          	lhu	a4,32(s1)
    80005958:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000595c:	04f70663          	beq	a4,a5,800059a8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005960:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005964:	6898                	ld	a4,16(s1)
    80005966:	0204d783          	lhu	a5,32(s1)
    8000596a:	8b9d                	andi	a5,a5,7
    8000596c:	078e                	slli	a5,a5,0x3
    8000596e:	97ba                	add	a5,a5,a4
    80005970:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005972:	00278713          	addi	a4,a5,2
    80005976:	0712                	slli	a4,a4,0x4
    80005978:	9726                	add	a4,a4,s1
    8000597a:	01074703          	lbu	a4,16(a4)
    8000597e:	e321                	bnez	a4,800059be <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005980:	0789                	addi	a5,a5,2
    80005982:	0792                	slli	a5,a5,0x4
    80005984:	97a6                	add	a5,a5,s1
    80005986:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005988:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000598c:	dccfc0ef          	jal	80001f58 <wakeup>

    disk.used_idx += 1;
    80005990:	0204d783          	lhu	a5,32(s1)
    80005994:	2785                	addiw	a5,a5,1
    80005996:	17c2                	slli	a5,a5,0x30
    80005998:	93c1                	srli	a5,a5,0x30
    8000599a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000599e:	6898                	ld	a4,16(s1)
    800059a0:	00275703          	lhu	a4,2(a4)
    800059a4:	faf71ee3          	bne	a4,a5,80005960 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800059a8:	0001b517          	auipc	a0,0x1b
    800059ac:	3b850513          	addi	a0,a0,952 # 80020d60 <disk+0x128>
    800059b0:	ab6fb0ef          	jal	80000c66 <release>
}
    800059b4:	60e2                	ld	ra,24(sp)
    800059b6:	6442                	ld	s0,16(sp)
    800059b8:	64a2                	ld	s1,8(sp)
    800059ba:	6105                	addi	sp,sp,32
    800059bc:	8082                	ret
      panic("virtio_disk_intr status");
    800059be:	00002517          	auipc	a0,0x2
    800059c2:	d3a50513          	addi	a0,a0,-710 # 800076f8 <etext+0x6f8>
    800059c6:	e1bfa0ef          	jal	800007e0 <panic>
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
