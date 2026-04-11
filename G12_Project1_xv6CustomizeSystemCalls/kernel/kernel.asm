
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
    80000004:	88010113          	addi	sp,sp,-1920 # 80007880 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdda77>
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
    80000112:	16c020ef          	jal	8000227e <either_copyin>
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
    80000190:	6f450513          	addi	a0,a0,1780 # 8000f880 <cons>
    80000194:	23b000ef          	jal	80000bce <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	0000f497          	auipc	s1,0xf
    8000019c:	6e848493          	addi	s1,s1,1768 # 8000f880 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	0000f917          	auipc	s2,0xf
    800001a4:	77890913          	addi	s2,s2,1912 # 8000f918 <cons+0x98>
  while(n > 0){
    800001a8:	0b305d63          	blez	s3,80000262 <consoleread+0xf4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	0af71263          	bne	a4,a5,80000258 <consoleread+0xea>
      if(killed(myproc())){
    800001b8:	716010ef          	jal	800018ce <myproc>
    800001bc:	755010ef          	jal	80002110 <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	513010ef          	jal	80001ed8 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef703e3          	beq	a4,a5,800001b8 <consoleread+0x4a>
    800001d6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d8:	0000f717          	auipc	a4,0xf
    800001dc:	6a870713          	addi	a4,a4,1704 # 8000f880 <cons>
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
    8000020a:	02a020ef          	jal	80002234 <either_copyout>
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
    80000226:	65e50513          	addi	a0,a0,1630 # 8000f880 <cons>
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
    80000250:	6cf72623          	sw	a5,1740(a4) # 8000f918 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	0000f517          	auipc	a0,0xf
    80000266:	61e50513          	addi	a0,a0,1566 # 8000f880 <cons>
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
    800002ba:	5ca50513          	addi	a0,a0,1482 # 8000f880 <cons>
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
    800002d8:	7f1010ef          	jal	800022c8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002dc:	0000f517          	auipc	a0,0xf
    800002e0:	5a450513          	addi	a0,a0,1444 # 8000f880 <cons>
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
    800002fe:	58670713          	addi	a4,a4,1414 # 8000f880 <cons>
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
    80000324:	56078793          	addi	a5,a5,1376 # 8000f880 <cons>
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
    80000352:	5ca7a783          	lw	a5,1482(a5) # 8000f918 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	0000f717          	auipc	a4,0xf
    80000368:	51c70713          	addi	a4,a4,1308 # 8000f880 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	0000f497          	auipc	s1,0xf
    80000378:	50c48493          	addi	s1,s1,1292 # 8000f880 <cons>
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
    800003ba:	4ca70713          	addi	a4,a4,1226 # 8000f880 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	0000f717          	auipc	a4,0xf
    800003d0:	54f72a23          	sw	a5,1364(a4) # 8000f920 <cons+0xa0>
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
    800003ee:	49678793          	addi	a5,a5,1174 # 8000f880 <cons>
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
    80000412:	50c7a723          	sw	a2,1294(a5) # 8000f91c <cons+0x9c>
        wakeup(&cons.r);
    80000416:	0000f517          	auipc	a0,0xf
    8000041a:	50250513          	addi	a0,a0,1282 # 8000f918 <cons+0x98>
    8000041e:	307010ef          	jal	80001f24 <wakeup>
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
    80000438:	44c50513          	addi	a0,a0,1100 # 8000f880 <cons>
    8000043c:	712000ef          	jal	80000b4e <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	0001f797          	auipc	a5,0x1f
    80000448:	7ac78793          	addi	a5,a5,1964 # 8001fbf0 <devsw>
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
    8000051c:	33c7a783          	lw	a5,828(a5) # 80007854 <panicking>
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
    80000564:	3c850513          	addi	a0,a0,968 # 8000f928 <pr>
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
    800007c0:	0987a783          	lw	a5,152(a5) # 80007854 <panicking>
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
    800007d6:	15650513          	addi	a0,a0,342 # 8000f928 <pr>
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
    800007f4:	0727a223          	sw	s2,100(a5) # 80007854 <panicking>
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
    80000816:	0327af23          	sw	s2,62(a5) # 80007850 <panicked>
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
    80000830:	0fc50513          	addi	a0,a0,252 # 8000f928 <pr>
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
    80000888:	0bc50513          	addi	a0,a0,188 # 8000f940 <tx_lock>
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
    800008ac:	09850513          	addi	a0,a0,152 # 8000f940 <tx_lock>
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
    800008ca:	f9648493          	addi	s1,s1,-106 # 8000785c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	0000f997          	auipc	s3,0xf
    800008d2:	07298993          	addi	s3,s3,114 # 8000f940 <tx_lock>
    800008d6:	00007917          	auipc	s2,0x7
    800008da:	f8290913          	addi	s2,s2,-126 # 80007858 <tx_chan>
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
    800008ea:	5ee010ef          	jal	80001ed8 <sleep>
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
    80000918:	02c50513          	addi	a0,a0,44 # 8000f940 <tx_lock>
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
    8000093c:	f1c7a783          	lw	a5,-228(a5) # 80007854 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	00007797          	auipc	a5,0x7
    80000946:	f0e7a783          	lw	a5,-242(a5) # 80007850 <panicked>
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
    8000096c:	eec7a783          	lw	a5,-276(a5) # 80007854 <panicking>
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
    800009c8:	f7c50513          	addi	a0,a0,-132 # 8000f940 <tx_lock>
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
    800009e4:	f6050513          	addi	a0,a0,-160 # 8000f940 <tx_lock>
    800009e8:	27e000ef          	jal	80000c66 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	00007797          	auipc	a5,0x7
    800009f4:	e607a623          	sw	zero,-404(a5) # 8000785c <tx_busy>
    wakeup(&tx_chan);
    800009f8:	00007517          	auipc	a0,0x7
    800009fc:	e6050513          	addi	a0,a0,-416 # 80007858 <tx_chan>
    80000a00:	524010ef          	jal	80001f24 <wakeup>
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
    80000a34:	35878793          	addi	a5,a5,856 # 80020d88 <end>
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
    80000a50:	f0c90913          	addi	s2,s2,-244 # 8000f958 <kmem>
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
    80000ade:	e7e50513          	addi	a0,a0,-386 # 8000f958 <kmem>
    80000ae2:	06c000ef          	jal	80000b4e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ae6:	45c5                	li	a1,17
    80000ae8:	05ee                	slli	a1,a1,0x1b
    80000aea:	00020517          	auipc	a0,0x20
    80000aee:	29e50513          	addi	a0,a0,670 # 80020d88 <end>
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
    80000b0c:	e5048493          	addi	s1,s1,-432 # 8000f958 <kmem>
    80000b10:	8526                	mv	a0,s1
    80000b12:	0bc000ef          	jal	80000bce <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c485                	beqz	s1,80000b40 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	0000f517          	auipc	a0,0xf
    80000b20:	e3c50513          	addi	a0,a0,-452 # 8000f958 <kmem>
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
    80000b44:	e1850513          	addi	a0,a0,-488 # 8000f958 <kmem>
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
    80000d16:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde279>
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
    80000e4c:	a1870713          	addi	a4,a4,-1512 # 80007860 <started>
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
    80000e72:	588010ef          	jal	800023fa <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e76:	7a2040ef          	jal	80005618 <plicinithart>
  }

  scheduler();        
    80000e7a:	6c7000ef          	jal	80001d40 <scheduler>
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
    80000eba:	51c010ef          	jal	800023d6 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ebe:	53c010ef          	jal	800023fa <trapinithart>
    plicinit();      // set up interrupt controller
    80000ec2:	73c040ef          	jal	800055fe <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ec6:	752040ef          	jal	80005618 <plicinithart>
    binit();         // buffer cache
    80000eca:	60f010ef          	jal	80002cd8 <binit>
    iinit();         // inode table
    80000ece:	394020ef          	jal	80003262 <iinit>
    fileinit();      // file table
    80000ed2:	286030ef          	jal	80004158 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ed6:	033040ef          	jal	80005708 <virtio_disk_init>
    userinit();      // first user process
    80000eda:	4bb000ef          	jal	80001b94 <userinit>
    __sync_synchronize();
    80000ede:	0ff0000f          	fence
    started = 1;
    80000ee2:	4785                	li	a5,1
    80000ee4:	00007717          	auipc	a4,0x7
    80000ee8:	96f72e23          	sw	a5,-1668(a4) # 80007860 <started>
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
    80000efc:	9707b783          	ld	a5,-1680(a5) # 80007868 <kernel_pagetable>
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
    80000f6a:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde26f>
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
    80001188:	6ea7b223          	sd	a0,1764(a5) # 80007868 <kernel_pagetable>
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
    8000176e:	63e48493          	addi	s1,s1,1598 # 8000fda8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001772:	8b26                	mv	s6,s1
    80001774:	04fa5937          	lui	s2,0x4fa5
    80001778:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    8000177c:	0932                	slli	s2,s2,0xc
    8000177e:	fa590913          	addi	s2,s2,-91
    80001782:	0932                	slli	s2,s2,0xc
    80001784:	fa590913          	addi	s2,s2,-91
    80001788:	0932                	slli	s2,s2,0xc
    8000178a:	fa590913          	addi	s2,s2,-91
    8000178e:	040009b7          	lui	s3,0x4000
    80001792:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001794:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001796:	00014a97          	auipc	s5,0x14
    8000179a:	012a8a93          	addi	s5,s5,18 # 800157a8 <tickslock>
    char *pa = kalloc();
    8000179e:	b60ff0ef          	jal	80000afe <kalloc>
    800017a2:	862a                	mv	a2,a0
    if(pa == 0)
    800017a4:	cd15                	beqz	a0,800017e0 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017a6:	416485b3          	sub	a1,s1,s6
    800017aa:	858d                	srai	a1,a1,0x3
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
    800017c4:	16848493          	addi	s1,s1,360
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
    8000180c:	17050513          	addi	a0,a0,368 # 8000f978 <pid_lock>
    80001810:	b3eff0ef          	jal	80000b4e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001814:	00006597          	auipc	a1,0x6
    80001818:	95458593          	addi	a1,a1,-1708 # 80007168 <etext+0x168>
    8000181c:	0000e517          	auipc	a0,0xe
    80001820:	17450513          	addi	a0,a0,372 # 8000f990 <wait_lock>
    80001824:	b2aff0ef          	jal	80000b4e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001828:	0000e497          	auipc	s1,0xe
    8000182c:	58048493          	addi	s1,s1,1408 # 8000fda8 <proc>
      initlock(&p->lock, "proc");
    80001830:	00006b17          	auipc	s6,0x6
    80001834:	948b0b13          	addi	s6,s6,-1720 # 80007178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001838:	8aa6                	mv	s5,s1
    8000183a:	04fa5937          	lui	s2,0x4fa5
    8000183e:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001842:	0932                	slli	s2,s2,0xc
    80001844:	fa590913          	addi	s2,s2,-91
    80001848:	0932                	slli	s2,s2,0xc
    8000184a:	fa590913          	addi	s2,s2,-91
    8000184e:	0932                	slli	s2,s2,0xc
    80001850:	fa590913          	addi	s2,s2,-91
    80001854:	040009b7          	lui	s3,0x4000
    80001858:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000185a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000185c:	00014a17          	auipc	s4,0x14
    80001860:	f4ca0a13          	addi	s4,s4,-180 # 800157a8 <tickslock>
      initlock(&p->lock, "proc");
    80001864:	85da                	mv	a1,s6
    80001866:	8526                	mv	a0,s1
    80001868:	ae6ff0ef          	jal	80000b4e <initlock>
      p->state = UNUSED;
    8000186c:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001870:	415487b3          	sub	a5,s1,s5
    80001874:	878d                	srai	a5,a5,0x3
    80001876:	032787b3          	mul	a5,a5,s2
    8000187a:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffde279>
    8000187c:	00d7979b          	slliw	a5,a5,0xd
    80001880:	40f987b3          	sub	a5,s3,a5
    80001884:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001886:	16848493          	addi	s1,s1,360
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
    800018c2:	0ea50513          	addi	a0,a0,234 # 8000f9a8 <cpus>
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
    800018e6:	09670713          	addi	a4,a4,150 # 8000f978 <pid_lock>
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
    80001916:	f2e7a783          	lw	a5,-210(a5) # 80007840 <first.1>
    8000191a:	cf8d                	beqz	a5,80001954 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    8000191c:	4505                	li	a0,1
    8000191e:	601010ef          	jal	8000371e <fsinit>

    first = 0;
    80001922:	00006797          	auipc	a5,0x6
    80001926:	f007af23          	sw	zero,-226(a5) # 80007840 <first.1>
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
    80001942:	6e7020ef          	jal	80004828 <kexec>
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
    80001954:	2bf000ef          	jal	80002412 <prepare_return>
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
    800019a6:	fd690913          	addi	s2,s2,-42 # 8000f978 <pid_lock>
    800019aa:	854a                	mv	a0,s2
    800019ac:	a22ff0ef          	jal	80000bce <acquire>
  pid = nextpid;
    800019b0:	00006797          	auipc	a5,0x6
    800019b4:	e9478793          	addi	a5,a5,-364 # 80007844 <nextpid>
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
    80001afe:	2ae48493          	addi	s1,s1,686 # 8000fda8 <proc>
    80001b02:	00014917          	auipc	s2,0x14
    80001b06:	ca690913          	addi	s2,s2,-858 # 800157a8 <tickslock>
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
    80001b1a:	16848493          	addi	s1,s1,360
    80001b1e:	ff2496e3          	bne	s1,s2,80001b0a <allocproc+0x1c>
  return 0;
    80001b22:	4481                	li	s1,0
    80001b24:	a089                	j	80001b66 <allocproc+0x78>
  p->pid = allocpid();
    80001b26:	e71ff0ef          	jal	80001996 <allocpid>
    80001b2a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b2c:	4785                	li	a5,1
    80001b2e:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b30:	fcffe0ef          	jal	80000afe <kalloc>
    80001b34:	892a                	mv	s2,a0
    80001b36:	eca8                	sd	a0,88(s1)
    80001b38:	cd15                	beqz	a0,80001b74 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b3a:	8526                	mv	a0,s1
    80001b3c:	e99ff0ef          	jal	800019d4 <proc_pagetable>
    80001b40:	892a                	mv	s2,a0
    80001b42:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b44:	c121                	beqz	a0,80001b84 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b46:	07000613          	li	a2,112
    80001b4a:	4581                	li	a1,0
    80001b4c:	06048513          	addi	a0,s1,96
    80001b50:	952ff0ef          	jal	80000ca2 <memset>
  p->context.ra = (uint64)forkret;
    80001b54:	00000797          	auipc	a5,0x0
    80001b58:	daa78793          	addi	a5,a5,-598 # 800018fe <forkret>
    80001b5c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b5e:	60bc                	ld	a5,64(s1)
    80001b60:	6705                	lui	a4,0x1
    80001b62:	97ba                	add	a5,a5,a4
    80001b64:	f4bc                	sd	a5,104(s1)
}
    80001b66:	8526                	mv	a0,s1
    80001b68:	60e2                	ld	ra,24(sp)
    80001b6a:	6442                	ld	s0,16(sp)
    80001b6c:	64a2                	ld	s1,8(sp)
    80001b6e:	6902                	ld	s2,0(sp)
    80001b70:	6105                	addi	sp,sp,32
    80001b72:	8082                	ret
    freeproc(p);
    80001b74:	8526                	mv	a0,s1
    80001b76:	f29ff0ef          	jal	80001a9e <freeproc>
    release(&p->lock);
    80001b7a:	8526                	mv	a0,s1
    80001b7c:	8eaff0ef          	jal	80000c66 <release>
    return 0;
    80001b80:	84ca                	mv	s1,s2
    80001b82:	b7d5                	j	80001b66 <allocproc+0x78>
    freeproc(p);
    80001b84:	8526                	mv	a0,s1
    80001b86:	f19ff0ef          	jal	80001a9e <freeproc>
    release(&p->lock);
    80001b8a:	8526                	mv	a0,s1
    80001b8c:	8daff0ef          	jal	80000c66 <release>
    return 0;
    80001b90:	84ca                	mv	s1,s2
    80001b92:	bfd1                	j	80001b66 <allocproc+0x78>

0000000080001b94 <userinit>:
{
    80001b94:	1101                	addi	sp,sp,-32
    80001b96:	ec06                	sd	ra,24(sp)
    80001b98:	e822                	sd	s0,16(sp)
    80001b9a:	e426                	sd	s1,8(sp)
    80001b9c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b9e:	f51ff0ef          	jal	80001aee <allocproc>
    80001ba2:	84aa                	mv	s1,a0
  initproc = p;
    80001ba4:	00006797          	auipc	a5,0x6
    80001ba8:	cca7b623          	sd	a0,-820(a5) # 80007870 <initproc>
  p->cwd = namei("/");
    80001bac:	00005517          	auipc	a0,0x5
    80001bb0:	5e450513          	addi	a0,a0,1508 # 80007190 <etext+0x190>
    80001bb4:	08c020ef          	jal	80003c40 <namei>
    80001bb8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bbc:	478d                	li	a5,3
    80001bbe:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	8a4ff0ef          	jal	80000c66 <release>
}
    80001bc6:	60e2                	ld	ra,24(sp)
    80001bc8:	6442                	ld	s0,16(sp)
    80001bca:	64a2                	ld	s1,8(sp)
    80001bcc:	6105                	addi	sp,sp,32
    80001bce:	8082                	ret

0000000080001bd0 <growproc>:
{
    80001bd0:	1101                	addi	sp,sp,-32
    80001bd2:	ec06                	sd	ra,24(sp)
    80001bd4:	e822                	sd	s0,16(sp)
    80001bd6:	e426                	sd	s1,8(sp)
    80001bd8:	e04a                	sd	s2,0(sp)
    80001bda:	1000                	addi	s0,sp,32
    80001bdc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001bde:	cf1ff0ef          	jal	800018ce <myproc>
    80001be2:	892a                	mv	s2,a0
  sz = p->sz;
    80001be4:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001be6:	02905963          	blez	s1,80001c18 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001bea:	00b48633          	add	a2,s1,a1
    80001bee:	020007b7          	lui	a5,0x2000
    80001bf2:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001bf4:	07b6                	slli	a5,a5,0xd
    80001bf6:	02c7ea63          	bltu	a5,a2,80001c2a <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001bfa:	4691                	li	a3,4
    80001bfc:	6928                	ld	a0,80(a0)
    80001bfe:	e8aff0ef          	jal	80001288 <uvmalloc>
    80001c02:	85aa                	mv	a1,a0
    80001c04:	c50d                	beqz	a0,80001c2e <growproc+0x5e>
  p->sz = sz;
    80001c06:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c0a:	4501                	li	a0,0
}
    80001c0c:	60e2                	ld	ra,24(sp)
    80001c0e:	6442                	ld	s0,16(sp)
    80001c10:	64a2                	ld	s1,8(sp)
    80001c12:	6902                	ld	s2,0(sp)
    80001c14:	6105                	addi	sp,sp,32
    80001c16:	8082                	ret
  } else if(n < 0){
    80001c18:	fe04d7e3          	bgez	s1,80001c06 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c1c:	00b48633          	add	a2,s1,a1
    80001c20:	6928                	ld	a0,80(a0)
    80001c22:	e22ff0ef          	jal	80001244 <uvmdealloc>
    80001c26:	85aa                	mv	a1,a0
    80001c28:	bff9                	j	80001c06 <growproc+0x36>
      return -1;
    80001c2a:	557d                	li	a0,-1
    80001c2c:	b7c5                	j	80001c0c <growproc+0x3c>
      return -1;
    80001c2e:	557d                	li	a0,-1
    80001c30:	bff1                	j	80001c0c <growproc+0x3c>

0000000080001c32 <kfork>:
{
    80001c32:	7139                	addi	sp,sp,-64
    80001c34:	fc06                	sd	ra,56(sp)
    80001c36:	f822                	sd	s0,48(sp)
    80001c38:	f04a                	sd	s2,32(sp)
    80001c3a:	e456                	sd	s5,8(sp)
    80001c3c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c3e:	c91ff0ef          	jal	800018ce <myproc>
    80001c42:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c44:	eabff0ef          	jal	80001aee <allocproc>
    80001c48:	0e050a63          	beqz	a0,80001d3c <kfork+0x10a>
    80001c4c:	e852                	sd	s4,16(sp)
    80001c4e:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c50:	048ab603          	ld	a2,72(s5)
    80001c54:	692c                	ld	a1,80(a0)
    80001c56:	050ab503          	ld	a0,80(s5)
    80001c5a:	f66ff0ef          	jal	800013c0 <uvmcopy>
    80001c5e:	04054a63          	bltz	a0,80001cb2 <kfork+0x80>
    80001c62:	f426                	sd	s1,40(sp)
    80001c64:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c66:	048ab783          	ld	a5,72(s5)
    80001c6a:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c6e:	058ab683          	ld	a3,88(s5)
    80001c72:	87b6                	mv	a5,a3
    80001c74:	058a3703          	ld	a4,88(s4)
    80001c78:	12068693          	addi	a3,a3,288
    80001c7c:	0007b803          	ld	a6,0(a5)
    80001c80:	6788                	ld	a0,8(a5)
    80001c82:	6b8c                	ld	a1,16(a5)
    80001c84:	6f90                	ld	a2,24(a5)
    80001c86:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001c8a:	e708                	sd	a0,8(a4)
    80001c8c:	eb0c                	sd	a1,16(a4)
    80001c8e:	ef10                	sd	a2,24(a4)
    80001c90:	02078793          	addi	a5,a5,32
    80001c94:	02070713          	addi	a4,a4,32
    80001c98:	fed792e3          	bne	a5,a3,80001c7c <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001c9c:	058a3783          	ld	a5,88(s4)
    80001ca0:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001ca4:	0d0a8493          	addi	s1,s5,208
    80001ca8:	0d0a0913          	addi	s2,s4,208
    80001cac:	150a8993          	addi	s3,s5,336
    80001cb0:	a831                	j	80001ccc <kfork+0x9a>
    freeproc(np);
    80001cb2:	8552                	mv	a0,s4
    80001cb4:	debff0ef          	jal	80001a9e <freeproc>
    release(&np->lock);
    80001cb8:	8552                	mv	a0,s4
    80001cba:	fadfe0ef          	jal	80000c66 <release>
    return -1;
    80001cbe:	597d                	li	s2,-1
    80001cc0:	6a42                	ld	s4,16(sp)
    80001cc2:	a0b5                	j	80001d2e <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001cc4:	04a1                	addi	s1,s1,8
    80001cc6:	0921                	addi	s2,s2,8
    80001cc8:	01348963          	beq	s1,s3,80001cda <kfork+0xa8>
    if(p->ofile[i])
    80001ccc:	6088                	ld	a0,0(s1)
    80001cce:	d97d                	beqz	a0,80001cc4 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cd0:	50a020ef          	jal	800041da <filedup>
    80001cd4:	00a93023          	sd	a0,0(s2)
    80001cd8:	b7f5                	j	80001cc4 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001cda:	150ab503          	ld	a0,336(s5)
    80001cde:	716010ef          	jal	800033f4 <idup>
    80001ce2:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ce6:	4641                	li	a2,16
    80001ce8:	158a8593          	addi	a1,s5,344
    80001cec:	158a0513          	addi	a0,s4,344
    80001cf0:	8f0ff0ef          	jal	80000de0 <safestrcpy>
  pid = np->pid;
    80001cf4:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001cf8:	8552                	mv	a0,s4
    80001cfa:	f6dfe0ef          	jal	80000c66 <release>
  acquire(&wait_lock);
    80001cfe:	0000e497          	auipc	s1,0xe
    80001d02:	c9248493          	addi	s1,s1,-878 # 8000f990 <wait_lock>
    80001d06:	8526                	mv	a0,s1
    80001d08:	ec7fe0ef          	jal	80000bce <acquire>
  np->parent = p;
    80001d0c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d10:	8526                	mv	a0,s1
    80001d12:	f55fe0ef          	jal	80000c66 <release>
  acquire(&np->lock);
    80001d16:	8552                	mv	a0,s4
    80001d18:	eb7fe0ef          	jal	80000bce <acquire>
  np->state = RUNNABLE;
    80001d1c:	478d                	li	a5,3
    80001d1e:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d22:	8552                	mv	a0,s4
    80001d24:	f43fe0ef          	jal	80000c66 <release>
  return pid;
    80001d28:	74a2                	ld	s1,40(sp)
    80001d2a:	69e2                	ld	s3,24(sp)
    80001d2c:	6a42                	ld	s4,16(sp)
}
    80001d2e:	854a                	mv	a0,s2
    80001d30:	70e2                	ld	ra,56(sp)
    80001d32:	7442                	ld	s0,48(sp)
    80001d34:	7902                	ld	s2,32(sp)
    80001d36:	6aa2                	ld	s5,8(sp)
    80001d38:	6121                	addi	sp,sp,64
    80001d3a:	8082                	ret
    return -1;
    80001d3c:	597d                	li	s2,-1
    80001d3e:	bfc5                	j	80001d2e <kfork+0xfc>

0000000080001d40 <scheduler>:
{
    80001d40:	715d                	addi	sp,sp,-80
    80001d42:	e486                	sd	ra,72(sp)
    80001d44:	e0a2                	sd	s0,64(sp)
    80001d46:	fc26                	sd	s1,56(sp)
    80001d48:	f84a                	sd	s2,48(sp)
    80001d4a:	f44e                	sd	s3,40(sp)
    80001d4c:	f052                	sd	s4,32(sp)
    80001d4e:	ec56                	sd	s5,24(sp)
    80001d50:	e85a                	sd	s6,16(sp)
    80001d52:	e45e                	sd	s7,8(sp)
    80001d54:	e062                	sd	s8,0(sp)
    80001d56:	0880                	addi	s0,sp,80
    80001d58:	8792                	mv	a5,tp
  int id = r_tp();
    80001d5a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d5c:	00779b13          	slli	s6,a5,0x7
    80001d60:	0000e717          	auipc	a4,0xe
    80001d64:	c1870713          	addi	a4,a4,-1000 # 8000f978 <pid_lock>
    80001d68:	975a                	add	a4,a4,s6
    80001d6a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d6e:	0000e717          	auipc	a4,0xe
    80001d72:	c4270713          	addi	a4,a4,-958 # 8000f9b0 <cpus+0x8>
    80001d76:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d78:	4c11                	li	s8,4
        c->proc = p;
    80001d7a:	079e                	slli	a5,a5,0x7
    80001d7c:	0000ea17          	auipc	s4,0xe
    80001d80:	bfca0a13          	addi	s4,s4,-1028 # 8000f978 <pid_lock>
    80001d84:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d86:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d88:	00014997          	auipc	s3,0x14
    80001d8c:	a2098993          	addi	s3,s3,-1504 # 800157a8 <tickslock>
    80001d90:	a83d                	j	80001dce <scheduler+0x8e>
      release(&p->lock);
    80001d92:	8526                	mv	a0,s1
    80001d94:	ed3fe0ef          	jal	80000c66 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d98:	16848493          	addi	s1,s1,360
    80001d9c:	03348563          	beq	s1,s3,80001dc6 <scheduler+0x86>
      acquire(&p->lock);
    80001da0:	8526                	mv	a0,s1
    80001da2:	e2dfe0ef          	jal	80000bce <acquire>
      if(p->state == RUNNABLE) {
    80001da6:	4c9c                	lw	a5,24(s1)
    80001da8:	ff2795e3          	bne	a5,s2,80001d92 <scheduler+0x52>
        p->state = RUNNING;
    80001dac:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001db0:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001db4:	06048593          	addi	a1,s1,96
    80001db8:	855a                	mv	a0,s6
    80001dba:	5b2000ef          	jal	8000236c <swtch>
        c->proc = 0;
    80001dbe:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001dc2:	8ade                	mv	s5,s7
    80001dc4:	b7f9                	j	80001d92 <scheduler+0x52>
    if(found == 0) {
    80001dc6:	000a9463          	bnez	s5,80001dce <scheduler+0x8e>
      asm volatile("wfi");
    80001dca:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dce:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dd2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dd6:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dda:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001dde:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001de0:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001de4:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001de6:	0000e497          	auipc	s1,0xe
    80001dea:	fc248493          	addi	s1,s1,-62 # 8000fda8 <proc>
      if(p->state == RUNNABLE) {
    80001dee:	490d                	li	s2,3
    80001df0:	bf45                	j	80001da0 <scheduler+0x60>

0000000080001df2 <sched>:
{
    80001df2:	7179                	addi	sp,sp,-48
    80001df4:	f406                	sd	ra,40(sp)
    80001df6:	f022                	sd	s0,32(sp)
    80001df8:	ec26                	sd	s1,24(sp)
    80001dfa:	e84a                	sd	s2,16(sp)
    80001dfc:	e44e                	sd	s3,8(sp)
    80001dfe:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e00:	acfff0ef          	jal	800018ce <myproc>
    80001e04:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e06:	d5ffe0ef          	jal	80000b64 <holding>
    80001e0a:	c92d                	beqz	a0,80001e7c <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e0c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e0e:	2781                	sext.w	a5,a5
    80001e10:	079e                	slli	a5,a5,0x7
    80001e12:	0000e717          	auipc	a4,0xe
    80001e16:	b6670713          	addi	a4,a4,-1178 # 8000f978 <pid_lock>
    80001e1a:	97ba                	add	a5,a5,a4
    80001e1c:	0a87a703          	lw	a4,168(a5)
    80001e20:	4785                	li	a5,1
    80001e22:	06f71363          	bne	a4,a5,80001e88 <sched+0x96>
  if(p->state == RUNNING)
    80001e26:	4c98                	lw	a4,24(s1)
    80001e28:	4791                	li	a5,4
    80001e2a:	06f70563          	beq	a4,a5,80001e94 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e2e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e32:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e34:	e7b5                	bnez	a5,80001ea0 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e36:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e38:	0000e917          	auipc	s2,0xe
    80001e3c:	b4090913          	addi	s2,s2,-1216 # 8000f978 <pid_lock>
    80001e40:	2781                	sext.w	a5,a5
    80001e42:	079e                	slli	a5,a5,0x7
    80001e44:	97ca                	add	a5,a5,s2
    80001e46:	0ac7a983          	lw	s3,172(a5)
    80001e4a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e4c:	2781                	sext.w	a5,a5
    80001e4e:	079e                	slli	a5,a5,0x7
    80001e50:	0000e597          	auipc	a1,0xe
    80001e54:	b6058593          	addi	a1,a1,-1184 # 8000f9b0 <cpus+0x8>
    80001e58:	95be                	add	a1,a1,a5
    80001e5a:	06048513          	addi	a0,s1,96
    80001e5e:	50e000ef          	jal	8000236c <swtch>
    80001e62:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e64:	2781                	sext.w	a5,a5
    80001e66:	079e                	slli	a5,a5,0x7
    80001e68:	993e                	add	s2,s2,a5
    80001e6a:	0b392623          	sw	s3,172(s2)
}
    80001e6e:	70a2                	ld	ra,40(sp)
    80001e70:	7402                	ld	s0,32(sp)
    80001e72:	64e2                	ld	s1,24(sp)
    80001e74:	6942                	ld	s2,16(sp)
    80001e76:	69a2                	ld	s3,8(sp)
    80001e78:	6145                	addi	sp,sp,48
    80001e7a:	8082                	ret
    panic("sched p->lock");
    80001e7c:	00005517          	auipc	a0,0x5
    80001e80:	31c50513          	addi	a0,a0,796 # 80007198 <etext+0x198>
    80001e84:	95dfe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    80001e88:	00005517          	auipc	a0,0x5
    80001e8c:	32050513          	addi	a0,a0,800 # 800071a8 <etext+0x1a8>
    80001e90:	951fe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    80001e94:	00005517          	auipc	a0,0x5
    80001e98:	32450513          	addi	a0,a0,804 # 800071b8 <etext+0x1b8>
    80001e9c:	945fe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    80001ea0:	00005517          	auipc	a0,0x5
    80001ea4:	32850513          	addi	a0,a0,808 # 800071c8 <etext+0x1c8>
    80001ea8:	939fe0ef          	jal	800007e0 <panic>

0000000080001eac <yield>:
{
    80001eac:	1101                	addi	sp,sp,-32
    80001eae:	ec06                	sd	ra,24(sp)
    80001eb0:	e822                	sd	s0,16(sp)
    80001eb2:	e426                	sd	s1,8(sp)
    80001eb4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001eb6:	a19ff0ef          	jal	800018ce <myproc>
    80001eba:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001ebc:	d13fe0ef          	jal	80000bce <acquire>
  p->state = RUNNABLE;
    80001ec0:	478d                	li	a5,3
    80001ec2:	cc9c                	sw	a5,24(s1)
  sched();
    80001ec4:	f2fff0ef          	jal	80001df2 <sched>
  release(&p->lock);
    80001ec8:	8526                	mv	a0,s1
    80001eca:	d9dfe0ef          	jal	80000c66 <release>
}
    80001ece:	60e2                	ld	ra,24(sp)
    80001ed0:	6442                	ld	s0,16(sp)
    80001ed2:	64a2                	ld	s1,8(sp)
    80001ed4:	6105                	addi	sp,sp,32
    80001ed6:	8082                	ret

0000000080001ed8 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001ed8:	7179                	addi	sp,sp,-48
    80001eda:	f406                	sd	ra,40(sp)
    80001edc:	f022                	sd	s0,32(sp)
    80001ede:	ec26                	sd	s1,24(sp)
    80001ee0:	e84a                	sd	s2,16(sp)
    80001ee2:	e44e                	sd	s3,8(sp)
    80001ee4:	1800                	addi	s0,sp,48
    80001ee6:	89aa                	mv	s3,a0
    80001ee8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001eea:	9e5ff0ef          	jal	800018ce <myproc>
    80001eee:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001ef0:	cdffe0ef          	jal	80000bce <acquire>
  release(lk);
    80001ef4:	854a                	mv	a0,s2
    80001ef6:	d71fe0ef          	jal	80000c66 <release>

  // Go to sleep.
  p->chan = chan;
    80001efa:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001efe:	4789                	li	a5,2
    80001f00:	cc9c                	sw	a5,24(s1)

  sched();
    80001f02:	ef1ff0ef          	jal	80001df2 <sched>

  // Tidy up.
  p->chan = 0;
    80001f06:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f0a:	8526                	mv	a0,s1
    80001f0c:	d5bfe0ef          	jal	80000c66 <release>
  acquire(lk);
    80001f10:	854a                	mv	a0,s2
    80001f12:	cbdfe0ef          	jal	80000bce <acquire>
}
    80001f16:	70a2                	ld	ra,40(sp)
    80001f18:	7402                	ld	s0,32(sp)
    80001f1a:	64e2                	ld	s1,24(sp)
    80001f1c:	6942                	ld	s2,16(sp)
    80001f1e:	69a2                	ld	s3,8(sp)
    80001f20:	6145                	addi	sp,sp,48
    80001f22:	8082                	ret

0000000080001f24 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001f24:	7139                	addi	sp,sp,-64
    80001f26:	fc06                	sd	ra,56(sp)
    80001f28:	f822                	sd	s0,48(sp)
    80001f2a:	f426                	sd	s1,40(sp)
    80001f2c:	f04a                	sd	s2,32(sp)
    80001f2e:	ec4e                	sd	s3,24(sp)
    80001f30:	e852                	sd	s4,16(sp)
    80001f32:	e456                	sd	s5,8(sp)
    80001f34:	0080                	addi	s0,sp,64
    80001f36:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f38:	0000e497          	auipc	s1,0xe
    80001f3c:	e7048493          	addi	s1,s1,-400 # 8000fda8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f40:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f42:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f44:	00014917          	auipc	s2,0x14
    80001f48:	86490913          	addi	s2,s2,-1948 # 800157a8 <tickslock>
    80001f4c:	a801                	j	80001f5c <wakeup+0x38>
      }
      release(&p->lock);
    80001f4e:	8526                	mv	a0,s1
    80001f50:	d17fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f54:	16848493          	addi	s1,s1,360
    80001f58:	03248263          	beq	s1,s2,80001f7c <wakeup+0x58>
    if(p != myproc()){
    80001f5c:	973ff0ef          	jal	800018ce <myproc>
    80001f60:	fea48ae3          	beq	s1,a0,80001f54 <wakeup+0x30>
      acquire(&p->lock);
    80001f64:	8526                	mv	a0,s1
    80001f66:	c69fe0ef          	jal	80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f6a:	4c9c                	lw	a5,24(s1)
    80001f6c:	ff3791e3          	bne	a5,s3,80001f4e <wakeup+0x2a>
    80001f70:	709c                	ld	a5,32(s1)
    80001f72:	fd479ee3          	bne	a5,s4,80001f4e <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f76:	0154ac23          	sw	s5,24(s1)
    80001f7a:	bfd1                	j	80001f4e <wakeup+0x2a>
    }
  }
}
    80001f7c:	70e2                	ld	ra,56(sp)
    80001f7e:	7442                	ld	s0,48(sp)
    80001f80:	74a2                	ld	s1,40(sp)
    80001f82:	7902                	ld	s2,32(sp)
    80001f84:	69e2                	ld	s3,24(sp)
    80001f86:	6a42                	ld	s4,16(sp)
    80001f88:	6aa2                	ld	s5,8(sp)
    80001f8a:	6121                	addi	sp,sp,64
    80001f8c:	8082                	ret

0000000080001f8e <reparent>:
{
    80001f8e:	7179                	addi	sp,sp,-48
    80001f90:	f406                	sd	ra,40(sp)
    80001f92:	f022                	sd	s0,32(sp)
    80001f94:	ec26                	sd	s1,24(sp)
    80001f96:	e84a                	sd	s2,16(sp)
    80001f98:	e44e                	sd	s3,8(sp)
    80001f9a:	e052                	sd	s4,0(sp)
    80001f9c:	1800                	addi	s0,sp,48
    80001f9e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fa0:	0000e497          	auipc	s1,0xe
    80001fa4:	e0848493          	addi	s1,s1,-504 # 8000fda8 <proc>
      pp->parent = initproc;
    80001fa8:	00006a17          	auipc	s4,0x6
    80001fac:	8c8a0a13          	addi	s4,s4,-1848 # 80007870 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fb0:	00013997          	auipc	s3,0x13
    80001fb4:	7f898993          	addi	s3,s3,2040 # 800157a8 <tickslock>
    80001fb8:	a029                	j	80001fc2 <reparent+0x34>
    80001fba:	16848493          	addi	s1,s1,360
    80001fbe:	01348b63          	beq	s1,s3,80001fd4 <reparent+0x46>
    if(pp->parent == p){
    80001fc2:	7c9c                	ld	a5,56(s1)
    80001fc4:	ff279be3          	bne	a5,s2,80001fba <reparent+0x2c>
      pp->parent = initproc;
    80001fc8:	000a3503          	ld	a0,0(s4)
    80001fcc:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fce:	f57ff0ef          	jal	80001f24 <wakeup>
    80001fd2:	b7e5                	j	80001fba <reparent+0x2c>
}
    80001fd4:	70a2                	ld	ra,40(sp)
    80001fd6:	7402                	ld	s0,32(sp)
    80001fd8:	64e2                	ld	s1,24(sp)
    80001fda:	6942                	ld	s2,16(sp)
    80001fdc:	69a2                	ld	s3,8(sp)
    80001fde:	6a02                	ld	s4,0(sp)
    80001fe0:	6145                	addi	sp,sp,48
    80001fe2:	8082                	ret

0000000080001fe4 <kexit>:
{
    80001fe4:	7179                	addi	sp,sp,-48
    80001fe6:	f406                	sd	ra,40(sp)
    80001fe8:	f022                	sd	s0,32(sp)
    80001fea:	ec26                	sd	s1,24(sp)
    80001fec:	e84a                	sd	s2,16(sp)
    80001fee:	e44e                	sd	s3,8(sp)
    80001ff0:	e052                	sd	s4,0(sp)
    80001ff2:	1800                	addi	s0,sp,48
    80001ff4:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001ff6:	8d9ff0ef          	jal	800018ce <myproc>
    80001ffa:	89aa                	mv	s3,a0
  if(p == initproc)
    80001ffc:	00006797          	auipc	a5,0x6
    80002000:	8747b783          	ld	a5,-1932(a5) # 80007870 <initproc>
    80002004:	0d050493          	addi	s1,a0,208
    80002008:	15050913          	addi	s2,a0,336
    8000200c:	00a79f63          	bne	a5,a0,8000202a <kexit+0x46>
    panic("init exiting");
    80002010:	00005517          	auipc	a0,0x5
    80002014:	1d050513          	addi	a0,a0,464 # 800071e0 <etext+0x1e0>
    80002018:	fc8fe0ef          	jal	800007e0 <panic>
      fileclose(f);
    8000201c:	204020ef          	jal	80004220 <fileclose>
      p->ofile[fd] = 0;
    80002020:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002024:	04a1                	addi	s1,s1,8
    80002026:	01248563          	beq	s1,s2,80002030 <kexit+0x4c>
    if(p->ofile[fd]){
    8000202a:	6088                	ld	a0,0(s1)
    8000202c:	f965                	bnez	a0,8000201c <kexit+0x38>
    8000202e:	bfdd                	j	80002024 <kexit+0x40>
  begin_op();
    80002030:	5e5010ef          	jal	80003e14 <begin_op>
  iput(p->cwd);
    80002034:	1509b503          	ld	a0,336(s3)
    80002038:	574010ef          	jal	800035ac <iput>
  end_op();
    8000203c:	643010ef          	jal	80003e7e <end_op>
  p->cwd = 0;
    80002040:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002044:	0000e497          	auipc	s1,0xe
    80002048:	94c48493          	addi	s1,s1,-1716 # 8000f990 <wait_lock>
    8000204c:	8526                	mv	a0,s1
    8000204e:	b81fe0ef          	jal	80000bce <acquire>
  reparent(p);
    80002052:	854e                	mv	a0,s3
    80002054:	f3bff0ef          	jal	80001f8e <reparent>
  wakeup(p->parent);
    80002058:	0389b503          	ld	a0,56(s3)
    8000205c:	ec9ff0ef          	jal	80001f24 <wakeup>
  acquire(&p->lock);
    80002060:	854e                	mv	a0,s3
    80002062:	b6dfe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    80002066:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000206a:	4795                	li	a5,5
    8000206c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002070:	8526                	mv	a0,s1
    80002072:	bf5fe0ef          	jal	80000c66 <release>
  sched();
    80002076:	d7dff0ef          	jal	80001df2 <sched>
  panic("zombie exit");
    8000207a:	00005517          	auipc	a0,0x5
    8000207e:	17650513          	addi	a0,a0,374 # 800071f0 <etext+0x1f0>
    80002082:	f5efe0ef          	jal	800007e0 <panic>

0000000080002086 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002086:	7179                	addi	sp,sp,-48
    80002088:	f406                	sd	ra,40(sp)
    8000208a:	f022                	sd	s0,32(sp)
    8000208c:	ec26                	sd	s1,24(sp)
    8000208e:	e84a                	sd	s2,16(sp)
    80002090:	e44e                	sd	s3,8(sp)
    80002092:	1800                	addi	s0,sp,48
    80002094:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002096:	0000e497          	auipc	s1,0xe
    8000209a:	d1248493          	addi	s1,s1,-750 # 8000fda8 <proc>
    8000209e:	00013997          	auipc	s3,0x13
    800020a2:	70a98993          	addi	s3,s3,1802 # 800157a8 <tickslock>
    acquire(&p->lock);
    800020a6:	8526                	mv	a0,s1
    800020a8:	b27fe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    800020ac:	589c                	lw	a5,48(s1)
    800020ae:	01278b63          	beq	a5,s2,800020c4 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020b2:	8526                	mv	a0,s1
    800020b4:	bb3fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020b8:	16848493          	addi	s1,s1,360
    800020bc:	ff3495e3          	bne	s1,s3,800020a6 <kkill+0x20>
  }
  return -1;
    800020c0:	557d                	li	a0,-1
    800020c2:	a819                	j	800020d8 <kkill+0x52>
      p->killed = 1;
    800020c4:	4785                	li	a5,1
    800020c6:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020c8:	4c98                	lw	a4,24(s1)
    800020ca:	4789                	li	a5,2
    800020cc:	00f70d63          	beq	a4,a5,800020e6 <kkill+0x60>
      release(&p->lock);
    800020d0:	8526                	mv	a0,s1
    800020d2:	b95fe0ef          	jal	80000c66 <release>
      return 0;
    800020d6:	4501                	li	a0,0
}
    800020d8:	70a2                	ld	ra,40(sp)
    800020da:	7402                	ld	s0,32(sp)
    800020dc:	64e2                	ld	s1,24(sp)
    800020de:	6942                	ld	s2,16(sp)
    800020e0:	69a2                	ld	s3,8(sp)
    800020e2:	6145                	addi	sp,sp,48
    800020e4:	8082                	ret
        p->state = RUNNABLE;
    800020e6:	478d                	li	a5,3
    800020e8:	cc9c                	sw	a5,24(s1)
    800020ea:	b7dd                	j	800020d0 <kkill+0x4a>

00000000800020ec <setkilled>:

void
setkilled(struct proc *p)
{
    800020ec:	1101                	addi	sp,sp,-32
    800020ee:	ec06                	sd	ra,24(sp)
    800020f0:	e822                	sd	s0,16(sp)
    800020f2:	e426                	sd	s1,8(sp)
    800020f4:	1000                	addi	s0,sp,32
    800020f6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020f8:	ad7fe0ef          	jal	80000bce <acquire>
  p->killed = 1;
    800020fc:	4785                	li	a5,1
    800020fe:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002100:	8526                	mv	a0,s1
    80002102:	b65fe0ef          	jal	80000c66 <release>
}
    80002106:	60e2                	ld	ra,24(sp)
    80002108:	6442                	ld	s0,16(sp)
    8000210a:	64a2                	ld	s1,8(sp)
    8000210c:	6105                	addi	sp,sp,32
    8000210e:	8082                	ret

0000000080002110 <killed>:

int
killed(struct proc *p)
{
    80002110:	1101                	addi	sp,sp,-32
    80002112:	ec06                	sd	ra,24(sp)
    80002114:	e822                	sd	s0,16(sp)
    80002116:	e426                	sd	s1,8(sp)
    80002118:	e04a                	sd	s2,0(sp)
    8000211a:	1000                	addi	s0,sp,32
    8000211c:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000211e:	ab1fe0ef          	jal	80000bce <acquire>
  k = p->killed;
    80002122:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002126:	8526                	mv	a0,s1
    80002128:	b3ffe0ef          	jal	80000c66 <release>
  return k;
}
    8000212c:	854a                	mv	a0,s2
    8000212e:	60e2                	ld	ra,24(sp)
    80002130:	6442                	ld	s0,16(sp)
    80002132:	64a2                	ld	s1,8(sp)
    80002134:	6902                	ld	s2,0(sp)
    80002136:	6105                	addi	sp,sp,32
    80002138:	8082                	ret

000000008000213a <kwait>:
{
    8000213a:	715d                	addi	sp,sp,-80
    8000213c:	e486                	sd	ra,72(sp)
    8000213e:	e0a2                	sd	s0,64(sp)
    80002140:	fc26                	sd	s1,56(sp)
    80002142:	f84a                	sd	s2,48(sp)
    80002144:	f44e                	sd	s3,40(sp)
    80002146:	f052                	sd	s4,32(sp)
    80002148:	ec56                	sd	s5,24(sp)
    8000214a:	e85a                	sd	s6,16(sp)
    8000214c:	e45e                	sd	s7,8(sp)
    8000214e:	e062                	sd	s8,0(sp)
    80002150:	0880                	addi	s0,sp,80
    80002152:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002154:	f7aff0ef          	jal	800018ce <myproc>
    80002158:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000215a:	0000e517          	auipc	a0,0xe
    8000215e:	83650513          	addi	a0,a0,-1994 # 8000f990 <wait_lock>
    80002162:	a6dfe0ef          	jal	80000bce <acquire>
    havekids = 0;
    80002166:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002168:	4a15                	li	s4,5
        havekids = 1;
    8000216a:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000216c:	00013997          	auipc	s3,0x13
    80002170:	63c98993          	addi	s3,s3,1596 # 800157a8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002174:	0000ec17          	auipc	s8,0xe
    80002178:	81cc0c13          	addi	s8,s8,-2020 # 8000f990 <wait_lock>
    8000217c:	a871                	j	80002218 <kwait+0xde>
          pid = pp->pid;
    8000217e:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002182:	000b0c63          	beqz	s6,8000219a <kwait+0x60>
    80002186:	4691                	li	a3,4
    80002188:	02c48613          	addi	a2,s1,44
    8000218c:	85da                	mv	a1,s6
    8000218e:	05093503          	ld	a0,80(s2)
    80002192:	c50ff0ef          	jal	800015e2 <copyout>
    80002196:	02054b63          	bltz	a0,800021cc <kwait+0x92>
          freeproc(pp);
    8000219a:	8526                	mv	a0,s1
    8000219c:	903ff0ef          	jal	80001a9e <freeproc>
          release(&pp->lock);
    800021a0:	8526                	mv	a0,s1
    800021a2:	ac5fe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    800021a6:	0000d517          	auipc	a0,0xd
    800021aa:	7ea50513          	addi	a0,a0,2026 # 8000f990 <wait_lock>
    800021ae:	ab9fe0ef          	jal	80000c66 <release>
}
    800021b2:	854e                	mv	a0,s3
    800021b4:	60a6                	ld	ra,72(sp)
    800021b6:	6406                	ld	s0,64(sp)
    800021b8:	74e2                	ld	s1,56(sp)
    800021ba:	7942                	ld	s2,48(sp)
    800021bc:	79a2                	ld	s3,40(sp)
    800021be:	7a02                	ld	s4,32(sp)
    800021c0:	6ae2                	ld	s5,24(sp)
    800021c2:	6b42                	ld	s6,16(sp)
    800021c4:	6ba2                	ld	s7,8(sp)
    800021c6:	6c02                	ld	s8,0(sp)
    800021c8:	6161                	addi	sp,sp,80
    800021ca:	8082                	ret
            release(&pp->lock);
    800021cc:	8526                	mv	a0,s1
    800021ce:	a99fe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    800021d2:	0000d517          	auipc	a0,0xd
    800021d6:	7be50513          	addi	a0,a0,1982 # 8000f990 <wait_lock>
    800021da:	a8dfe0ef          	jal	80000c66 <release>
            return -1;
    800021de:	59fd                	li	s3,-1
    800021e0:	bfc9                	j	800021b2 <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021e2:	16848493          	addi	s1,s1,360
    800021e6:	03348063          	beq	s1,s3,80002206 <kwait+0xcc>
      if(pp->parent == p){
    800021ea:	7c9c                	ld	a5,56(s1)
    800021ec:	ff279be3          	bne	a5,s2,800021e2 <kwait+0xa8>
        acquire(&pp->lock);
    800021f0:	8526                	mv	a0,s1
    800021f2:	9ddfe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    800021f6:	4c9c                	lw	a5,24(s1)
    800021f8:	f94783e3          	beq	a5,s4,8000217e <kwait+0x44>
        release(&pp->lock);
    800021fc:	8526                	mv	a0,s1
    800021fe:	a69fe0ef          	jal	80000c66 <release>
        havekids = 1;
    80002202:	8756                	mv	a4,s5
    80002204:	bff9                	j	800021e2 <kwait+0xa8>
    if(!havekids || killed(p)){
    80002206:	cf19                	beqz	a4,80002224 <kwait+0xea>
    80002208:	854a                	mv	a0,s2
    8000220a:	f07ff0ef          	jal	80002110 <killed>
    8000220e:	e919                	bnez	a0,80002224 <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002210:	85e2                	mv	a1,s8
    80002212:	854a                	mv	a0,s2
    80002214:	cc5ff0ef          	jal	80001ed8 <sleep>
    havekids = 0;
    80002218:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000221a:	0000e497          	auipc	s1,0xe
    8000221e:	b8e48493          	addi	s1,s1,-1138 # 8000fda8 <proc>
    80002222:	b7e1                	j	800021ea <kwait+0xb0>
      release(&wait_lock);
    80002224:	0000d517          	auipc	a0,0xd
    80002228:	76c50513          	addi	a0,a0,1900 # 8000f990 <wait_lock>
    8000222c:	a3bfe0ef          	jal	80000c66 <release>
      return -1;
    80002230:	59fd                	li	s3,-1
    80002232:	b741                	j	800021b2 <kwait+0x78>

0000000080002234 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002234:	7179                	addi	sp,sp,-48
    80002236:	f406                	sd	ra,40(sp)
    80002238:	f022                	sd	s0,32(sp)
    8000223a:	ec26                	sd	s1,24(sp)
    8000223c:	e84a                	sd	s2,16(sp)
    8000223e:	e44e                	sd	s3,8(sp)
    80002240:	e052                	sd	s4,0(sp)
    80002242:	1800                	addi	s0,sp,48
    80002244:	84aa                	mv	s1,a0
    80002246:	892e                	mv	s2,a1
    80002248:	89b2                	mv	s3,a2
    8000224a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000224c:	e82ff0ef          	jal	800018ce <myproc>
  if(user_dst){
    80002250:	cc99                	beqz	s1,8000226e <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002252:	86d2                	mv	a3,s4
    80002254:	864e                	mv	a2,s3
    80002256:	85ca                	mv	a1,s2
    80002258:	6928                	ld	a0,80(a0)
    8000225a:	b88ff0ef          	jal	800015e2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000225e:	70a2                	ld	ra,40(sp)
    80002260:	7402                	ld	s0,32(sp)
    80002262:	64e2                	ld	s1,24(sp)
    80002264:	6942                	ld	s2,16(sp)
    80002266:	69a2                	ld	s3,8(sp)
    80002268:	6a02                	ld	s4,0(sp)
    8000226a:	6145                	addi	sp,sp,48
    8000226c:	8082                	ret
    memmove((char *)dst, src, len);
    8000226e:	000a061b          	sext.w	a2,s4
    80002272:	85ce                	mv	a1,s3
    80002274:	854a                	mv	a0,s2
    80002276:	a89fe0ef          	jal	80000cfe <memmove>
    return 0;
    8000227a:	8526                	mv	a0,s1
    8000227c:	b7cd                	j	8000225e <either_copyout+0x2a>

000000008000227e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000227e:	7179                	addi	sp,sp,-48
    80002280:	f406                	sd	ra,40(sp)
    80002282:	f022                	sd	s0,32(sp)
    80002284:	ec26                	sd	s1,24(sp)
    80002286:	e84a                	sd	s2,16(sp)
    80002288:	e44e                	sd	s3,8(sp)
    8000228a:	e052                	sd	s4,0(sp)
    8000228c:	1800                	addi	s0,sp,48
    8000228e:	892a                	mv	s2,a0
    80002290:	84ae                	mv	s1,a1
    80002292:	89b2                	mv	s3,a2
    80002294:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002296:	e38ff0ef          	jal	800018ce <myproc>
  if(user_src){
    8000229a:	cc99                	beqz	s1,800022b8 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000229c:	86d2                	mv	a3,s4
    8000229e:	864e                	mv	a2,s3
    800022a0:	85ca                	mv	a1,s2
    800022a2:	6928                	ld	a0,80(a0)
    800022a4:	c22ff0ef          	jal	800016c6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022a8:	70a2                	ld	ra,40(sp)
    800022aa:	7402                	ld	s0,32(sp)
    800022ac:	64e2                	ld	s1,24(sp)
    800022ae:	6942                	ld	s2,16(sp)
    800022b0:	69a2                	ld	s3,8(sp)
    800022b2:	6a02                	ld	s4,0(sp)
    800022b4:	6145                	addi	sp,sp,48
    800022b6:	8082                	ret
    memmove(dst, (char*)src, len);
    800022b8:	000a061b          	sext.w	a2,s4
    800022bc:	85ce                	mv	a1,s3
    800022be:	854a                	mv	a0,s2
    800022c0:	a3ffe0ef          	jal	80000cfe <memmove>
    return 0;
    800022c4:	8526                	mv	a0,s1
    800022c6:	b7cd                	j	800022a8 <either_copyin+0x2a>

00000000800022c8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022c8:	715d                	addi	sp,sp,-80
    800022ca:	e486                	sd	ra,72(sp)
    800022cc:	e0a2                	sd	s0,64(sp)
    800022ce:	fc26                	sd	s1,56(sp)
    800022d0:	f84a                	sd	s2,48(sp)
    800022d2:	f44e                	sd	s3,40(sp)
    800022d4:	f052                	sd	s4,32(sp)
    800022d6:	ec56                	sd	s5,24(sp)
    800022d8:	e85a                	sd	s6,16(sp)
    800022da:	e45e                	sd	s7,8(sp)
    800022dc:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022de:	00005517          	auipc	a0,0x5
    800022e2:	d9a50513          	addi	a0,a0,-614 # 80007078 <etext+0x78>
    800022e6:	a14fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022ea:	0000e497          	auipc	s1,0xe
    800022ee:	c1648493          	addi	s1,s1,-1002 # 8000ff00 <proc+0x158>
    800022f2:	00013917          	auipc	s2,0x13
    800022f6:	60e90913          	addi	s2,s2,1550 # 80015900 <shmtable+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022fa:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022fc:	00005997          	auipc	s3,0x5
    80002300:	f0498993          	addi	s3,s3,-252 # 80007200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    80002304:	00005a97          	auipc	s5,0x5
    80002308:	f04a8a93          	addi	s5,s5,-252 # 80007208 <etext+0x208>
    printf("\n");
    8000230c:	00005a17          	auipc	s4,0x5
    80002310:	d6ca0a13          	addi	s4,s4,-660 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002314:	00005b97          	auipc	s7,0x5
    80002318:	414b8b93          	addi	s7,s7,1044 # 80007728 <states.0>
    8000231c:	a829                	j	80002336 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000231e:	ed86a583          	lw	a1,-296(a3)
    80002322:	8556                	mv	a0,s5
    80002324:	9d6fe0ef          	jal	800004fa <printf>
    printf("\n");
    80002328:	8552                	mv	a0,s4
    8000232a:	9d0fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000232e:	16848493          	addi	s1,s1,360
    80002332:	03248263          	beq	s1,s2,80002356 <procdump+0x8e>
    if(p->state == UNUSED)
    80002336:	86a6                	mv	a3,s1
    80002338:	ec04a783          	lw	a5,-320(s1)
    8000233c:	dbed                	beqz	a5,8000232e <procdump+0x66>
      state = "???";
    8000233e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002340:	fcfb6fe3          	bltu	s6,a5,8000231e <procdump+0x56>
    80002344:	02079713          	slli	a4,a5,0x20
    80002348:	01d75793          	srli	a5,a4,0x1d
    8000234c:	97de                	add	a5,a5,s7
    8000234e:	6390                	ld	a2,0(a5)
    80002350:	f679                	bnez	a2,8000231e <procdump+0x56>
      state = "???";
    80002352:	864e                	mv	a2,s3
    80002354:	b7e9                	j	8000231e <procdump+0x56>
  }
}
    80002356:	60a6                	ld	ra,72(sp)
    80002358:	6406                	ld	s0,64(sp)
    8000235a:	74e2                	ld	s1,56(sp)
    8000235c:	7942                	ld	s2,48(sp)
    8000235e:	79a2                	ld	s3,40(sp)
    80002360:	7a02                	ld	s4,32(sp)
    80002362:	6ae2                	ld	s5,24(sp)
    80002364:	6b42                	ld	s6,16(sp)
    80002366:	6ba2                	ld	s7,8(sp)
    80002368:	6161                	addi	sp,sp,80
    8000236a:	8082                	ret

000000008000236c <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000236c:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002370:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002374:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002376:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002378:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000237c:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002380:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002384:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002388:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000238c:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002390:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002394:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002398:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000239c:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800023a0:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800023a4:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800023a8:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800023aa:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800023ac:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800023b0:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800023b4:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800023b8:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800023bc:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800023c0:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800023c4:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800023c8:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800023cc:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800023d0:	0685bd83          	ld	s11,104(a1)
        
        ret
    800023d4:	8082                	ret

00000000800023d6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023d6:	1141                	addi	sp,sp,-16
    800023d8:	e406                	sd	ra,8(sp)
    800023da:	e022                	sd	s0,0(sp)
    800023dc:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023de:	00005597          	auipc	a1,0x5
    800023e2:	e6a58593          	addi	a1,a1,-406 # 80007248 <etext+0x248>
    800023e6:	00013517          	auipc	a0,0x13
    800023ea:	3c250513          	addi	a0,a0,962 # 800157a8 <tickslock>
    800023ee:	f60fe0ef          	jal	80000b4e <initlock>
}
    800023f2:	60a2                	ld	ra,8(sp)
    800023f4:	6402                	ld	s0,0(sp)
    800023f6:	0141                	addi	sp,sp,16
    800023f8:	8082                	ret

00000000800023fa <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800023fa:	1141                	addi	sp,sp,-16
    800023fc:	e422                	sd	s0,8(sp)
    800023fe:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002400:	00003797          	auipc	a5,0x3
    80002404:	1a078793          	addi	a5,a5,416 # 800055a0 <kernelvec>
    80002408:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000240c:	6422                	ld	s0,8(sp)
    8000240e:	0141                	addi	sp,sp,16
    80002410:	8082                	ret

0000000080002412 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002412:	1141                	addi	sp,sp,-16
    80002414:	e406                	sd	ra,8(sp)
    80002416:	e022                	sd	s0,0(sp)
    80002418:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000241a:	cb4ff0ef          	jal	800018ce <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000241e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002422:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002424:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002428:	04000737          	lui	a4,0x4000
    8000242c:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000242e:	0732                	slli	a4,a4,0xc
    80002430:	00004797          	auipc	a5,0x4
    80002434:	bd078793          	addi	a5,a5,-1072 # 80006000 <_trampoline>
    80002438:	00004697          	auipc	a3,0x4
    8000243c:	bc868693          	addi	a3,a3,-1080 # 80006000 <_trampoline>
    80002440:	8f95                	sub	a5,a5,a3
    80002442:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002444:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002448:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000244a:	18002773          	csrr	a4,satp
    8000244e:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002450:	6d38                	ld	a4,88(a0)
    80002452:	613c                	ld	a5,64(a0)
    80002454:	6685                	lui	a3,0x1
    80002456:	97b6                	add	a5,a5,a3
    80002458:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000245a:	6d3c                	ld	a5,88(a0)
    8000245c:	00000717          	auipc	a4,0x0
    80002460:	0f870713          	addi	a4,a4,248 # 80002554 <usertrap>
    80002464:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002466:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002468:	8712                	mv	a4,tp
    8000246a:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000246c:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002470:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002474:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002478:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000247c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000247e:	6f9c                	ld	a5,24(a5)
    80002480:	14179073          	csrw	sepc,a5
}
    80002484:	60a2                	ld	ra,8(sp)
    80002486:	6402                	ld	s0,0(sp)
    80002488:	0141                	addi	sp,sp,16
    8000248a:	8082                	ret

000000008000248c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000248c:	1101                	addi	sp,sp,-32
    8000248e:	ec06                	sd	ra,24(sp)
    80002490:	e822                	sd	s0,16(sp)
    80002492:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002494:	c0eff0ef          	jal	800018a2 <cpuid>
    80002498:	cd11                	beqz	a0,800024b4 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000249a:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000249e:	000f4737          	lui	a4,0xf4
    800024a2:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800024a6:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800024a8:	14d79073          	csrw	stimecmp,a5
}
    800024ac:	60e2                	ld	ra,24(sp)
    800024ae:	6442                	ld	s0,16(sp)
    800024b0:	6105                	addi	sp,sp,32
    800024b2:	8082                	ret
    800024b4:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024b6:	00013497          	auipc	s1,0x13
    800024ba:	2f248493          	addi	s1,s1,754 # 800157a8 <tickslock>
    800024be:	8526                	mv	a0,s1
    800024c0:	f0efe0ef          	jal	80000bce <acquire>
    ticks++;
    800024c4:	00005517          	auipc	a0,0x5
    800024c8:	3b450513          	addi	a0,a0,948 # 80007878 <ticks>
    800024cc:	411c                	lw	a5,0(a0)
    800024ce:	2785                	addiw	a5,a5,1
    800024d0:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024d2:	a53ff0ef          	jal	80001f24 <wakeup>
    release(&tickslock);
    800024d6:	8526                	mv	a0,s1
    800024d8:	f8efe0ef          	jal	80000c66 <release>
    800024dc:	64a2                	ld	s1,8(sp)
    800024de:	bf75                	j	8000249a <clockintr+0xe>

00000000800024e0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024e0:	1101                	addi	sp,sp,-32
    800024e2:	ec06                	sd	ra,24(sp)
    800024e4:	e822                	sd	s0,16(sp)
    800024e6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024e8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800024ec:	57fd                	li	a5,-1
    800024ee:	17fe                	slli	a5,a5,0x3f
    800024f0:	07a5                	addi	a5,a5,9
    800024f2:	00f70c63          	beq	a4,a5,8000250a <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800024f6:	57fd                	li	a5,-1
    800024f8:	17fe                	slli	a5,a5,0x3f
    800024fa:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800024fc:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800024fe:	04f70763          	beq	a4,a5,8000254c <devintr+0x6c>
  }
}
    80002502:	60e2                	ld	ra,24(sp)
    80002504:	6442                	ld	s0,16(sp)
    80002506:	6105                	addi	sp,sp,32
    80002508:	8082                	ret
    8000250a:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000250c:	140030ef          	jal	8000564c <plic_claim>
    80002510:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002512:	47a9                	li	a5,10
    80002514:	00f50963          	beq	a0,a5,80002526 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002518:	4785                	li	a5,1
    8000251a:	00f50963          	beq	a0,a5,8000252c <devintr+0x4c>
    return 1;
    8000251e:	4505                	li	a0,1
    } else if(irq){
    80002520:	e889                	bnez	s1,80002532 <devintr+0x52>
    80002522:	64a2                	ld	s1,8(sp)
    80002524:	bff9                	j	80002502 <devintr+0x22>
      uartintr();
    80002526:	c8afe0ef          	jal	800009b0 <uartintr>
    if(irq)
    8000252a:	a819                	j	80002540 <devintr+0x60>
      virtio_disk_intr();
    8000252c:	5e6030ef          	jal	80005b12 <virtio_disk_intr>
    if(irq)
    80002530:	a801                	j	80002540 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002532:	85a6                	mv	a1,s1
    80002534:	00005517          	auipc	a0,0x5
    80002538:	d1c50513          	addi	a0,a0,-740 # 80007250 <etext+0x250>
    8000253c:	fbffd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002540:	8526                	mv	a0,s1
    80002542:	12a030ef          	jal	8000566c <plic_complete>
    return 1;
    80002546:	4505                	li	a0,1
    80002548:	64a2                	ld	s1,8(sp)
    8000254a:	bf65                	j	80002502 <devintr+0x22>
    clockintr();
    8000254c:	f41ff0ef          	jal	8000248c <clockintr>
    return 2;
    80002550:	4509                	li	a0,2
    80002552:	bf45                	j	80002502 <devintr+0x22>

0000000080002554 <usertrap>:
{
    80002554:	1101                	addi	sp,sp,-32
    80002556:	ec06                	sd	ra,24(sp)
    80002558:	e822                	sd	s0,16(sp)
    8000255a:	e426                	sd	s1,8(sp)
    8000255c:	e04a                	sd	s2,0(sp)
    8000255e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002560:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002564:	1007f793          	andi	a5,a5,256
    80002568:	eba5                	bnez	a5,800025d8 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000256a:	00003797          	auipc	a5,0x3
    8000256e:	03678793          	addi	a5,a5,54 # 800055a0 <kernelvec>
    80002572:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002576:	b58ff0ef          	jal	800018ce <myproc>
    8000257a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000257c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000257e:	14102773          	csrr	a4,sepc
    80002582:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002584:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002588:	47a1                	li	a5,8
    8000258a:	04f70d63          	beq	a4,a5,800025e4 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    8000258e:	f53ff0ef          	jal	800024e0 <devintr>
    80002592:	892a                	mv	s2,a0
    80002594:	e945                	bnez	a0,80002644 <usertrap+0xf0>
    80002596:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000259a:	47bd                	li	a5,15
    8000259c:	08f70863          	beq	a4,a5,8000262c <usertrap+0xd8>
    800025a0:	14202773          	csrr	a4,scause
    800025a4:	47b5                	li	a5,13
    800025a6:	08f70363          	beq	a4,a5,8000262c <usertrap+0xd8>
    800025aa:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800025ae:	5890                	lw	a2,48(s1)
    800025b0:	00005517          	auipc	a0,0x5
    800025b4:	ce050513          	addi	a0,a0,-800 # 80007290 <etext+0x290>
    800025b8:	f43fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025bc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025c0:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800025c4:	00005517          	auipc	a0,0x5
    800025c8:	cfc50513          	addi	a0,a0,-772 # 800072c0 <etext+0x2c0>
    800025cc:	f2ffd0ef          	jal	800004fa <printf>
    setkilled(p);
    800025d0:	8526                	mv	a0,s1
    800025d2:	b1bff0ef          	jal	800020ec <setkilled>
    800025d6:	a035                	j	80002602 <usertrap+0xae>
    panic("usertrap: not from user mode");
    800025d8:	00005517          	auipc	a0,0x5
    800025dc:	c9850513          	addi	a0,a0,-872 # 80007270 <etext+0x270>
    800025e0:	a00fe0ef          	jal	800007e0 <panic>
    if(killed(p))
    800025e4:	b2dff0ef          	jal	80002110 <killed>
    800025e8:	ed15                	bnez	a0,80002624 <usertrap+0xd0>
    p->trapframe->epc += 4;
    800025ea:	6cb8                	ld	a4,88(s1)
    800025ec:	6f1c                	ld	a5,24(a4)
    800025ee:	0791                	addi	a5,a5,4
    800025f0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025f2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025f6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025fa:	10079073          	csrw	sstatus,a5
    syscall();
    800025fe:	246000ef          	jal	80002844 <syscall>
  if(killed(p))
    80002602:	8526                	mv	a0,s1
    80002604:	b0dff0ef          	jal	80002110 <killed>
    80002608:	e139                	bnez	a0,8000264e <usertrap+0xfa>
  prepare_return();
    8000260a:	e09ff0ef          	jal	80002412 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000260e:	68a8                	ld	a0,80(s1)
    80002610:	8131                	srli	a0,a0,0xc
    80002612:	57fd                	li	a5,-1
    80002614:	17fe                	slli	a5,a5,0x3f
    80002616:	8d5d                	or	a0,a0,a5
}
    80002618:	60e2                	ld	ra,24(sp)
    8000261a:	6442                	ld	s0,16(sp)
    8000261c:	64a2                	ld	s1,8(sp)
    8000261e:	6902                	ld	s2,0(sp)
    80002620:	6105                	addi	sp,sp,32
    80002622:	8082                	ret
      kexit(-1);
    80002624:	557d                	li	a0,-1
    80002626:	9bfff0ef          	jal	80001fe4 <kexit>
    8000262a:	b7c1                	j	800025ea <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000262c:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002630:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002634:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002636:	00163613          	seqz	a2,a2
    8000263a:	68a8                	ld	a0,80(s1)
    8000263c:	f25fe0ef          	jal	80001560 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002640:	f169                	bnez	a0,80002602 <usertrap+0xae>
    80002642:	b7a5                	j	800025aa <usertrap+0x56>
  if(killed(p))
    80002644:	8526                	mv	a0,s1
    80002646:	acbff0ef          	jal	80002110 <killed>
    8000264a:	c511                	beqz	a0,80002656 <usertrap+0x102>
    8000264c:	a011                	j	80002650 <usertrap+0xfc>
    8000264e:	4901                	li	s2,0
    kexit(-1);
    80002650:	557d                	li	a0,-1
    80002652:	993ff0ef          	jal	80001fe4 <kexit>
  if(which_dev == 2)
    80002656:	4789                	li	a5,2
    80002658:	faf919e3          	bne	s2,a5,8000260a <usertrap+0xb6>
    yield();
    8000265c:	851ff0ef          	jal	80001eac <yield>
    80002660:	b76d                	j	8000260a <usertrap+0xb6>

0000000080002662 <kerneltrap>:
{
    80002662:	7179                	addi	sp,sp,-48
    80002664:	f406                	sd	ra,40(sp)
    80002666:	f022                	sd	s0,32(sp)
    80002668:	ec26                	sd	s1,24(sp)
    8000266a:	e84a                	sd	s2,16(sp)
    8000266c:	e44e                	sd	s3,8(sp)
    8000266e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002670:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002674:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002678:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000267c:	1004f793          	andi	a5,s1,256
    80002680:	c795                	beqz	a5,800026ac <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002682:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002686:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002688:	eb85                	bnez	a5,800026b8 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    8000268a:	e57ff0ef          	jal	800024e0 <devintr>
    8000268e:	c91d                	beqz	a0,800026c4 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002690:	4789                	li	a5,2
    80002692:	04f50a63          	beq	a0,a5,800026e6 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002696:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000269a:	10049073          	csrw	sstatus,s1
}
    8000269e:	70a2                	ld	ra,40(sp)
    800026a0:	7402                	ld	s0,32(sp)
    800026a2:	64e2                	ld	s1,24(sp)
    800026a4:	6942                	ld	s2,16(sp)
    800026a6:	69a2                	ld	s3,8(sp)
    800026a8:	6145                	addi	sp,sp,48
    800026aa:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026ac:	00005517          	auipc	a0,0x5
    800026b0:	c3c50513          	addi	a0,a0,-964 # 800072e8 <etext+0x2e8>
    800026b4:	92cfe0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    800026b8:	00005517          	auipc	a0,0x5
    800026bc:	c5850513          	addi	a0,a0,-936 # 80007310 <etext+0x310>
    800026c0:	920fe0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026c4:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026c8:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800026cc:	85ce                	mv	a1,s3
    800026ce:	00005517          	auipc	a0,0x5
    800026d2:	c6250513          	addi	a0,a0,-926 # 80007330 <etext+0x330>
    800026d6:	e25fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    800026da:	00005517          	auipc	a0,0x5
    800026de:	c7e50513          	addi	a0,a0,-898 # 80007358 <etext+0x358>
    800026e2:	8fefe0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    800026e6:	9e8ff0ef          	jal	800018ce <myproc>
    800026ea:	d555                	beqz	a0,80002696 <kerneltrap+0x34>
    yield();
    800026ec:	fc0ff0ef          	jal	80001eac <yield>
    800026f0:	b75d                	j	80002696 <kerneltrap+0x34>

00000000800026f2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026f2:	1101                	addi	sp,sp,-32
    800026f4:	ec06                	sd	ra,24(sp)
    800026f6:	e822                	sd	s0,16(sp)
    800026f8:	e426                	sd	s1,8(sp)
    800026fa:	1000                	addi	s0,sp,32
    800026fc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800026fe:	9d0ff0ef          	jal	800018ce <myproc>
  switch (n) {
    80002702:	4795                	li	a5,5
    80002704:	0497e163          	bltu	a5,s1,80002746 <argraw+0x54>
    80002708:	048a                	slli	s1,s1,0x2
    8000270a:	00005717          	auipc	a4,0x5
    8000270e:	04e70713          	addi	a4,a4,78 # 80007758 <states.0+0x30>
    80002712:	94ba                	add	s1,s1,a4
    80002714:	409c                	lw	a5,0(s1)
    80002716:	97ba                	add	a5,a5,a4
    80002718:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000271a:	6d3c                	ld	a5,88(a0)
    8000271c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000271e:	60e2                	ld	ra,24(sp)
    80002720:	6442                	ld	s0,16(sp)
    80002722:	64a2                	ld	s1,8(sp)
    80002724:	6105                	addi	sp,sp,32
    80002726:	8082                	ret
    return p->trapframe->a1;
    80002728:	6d3c                	ld	a5,88(a0)
    8000272a:	7fa8                	ld	a0,120(a5)
    8000272c:	bfcd                	j	8000271e <argraw+0x2c>
    return p->trapframe->a2;
    8000272e:	6d3c                	ld	a5,88(a0)
    80002730:	63c8                	ld	a0,128(a5)
    80002732:	b7f5                	j	8000271e <argraw+0x2c>
    return p->trapframe->a3;
    80002734:	6d3c                	ld	a5,88(a0)
    80002736:	67c8                	ld	a0,136(a5)
    80002738:	b7dd                	j	8000271e <argraw+0x2c>
    return p->trapframe->a4;
    8000273a:	6d3c                	ld	a5,88(a0)
    8000273c:	6bc8                	ld	a0,144(a5)
    8000273e:	b7c5                	j	8000271e <argraw+0x2c>
    return p->trapframe->a5;
    80002740:	6d3c                	ld	a5,88(a0)
    80002742:	6fc8                	ld	a0,152(a5)
    80002744:	bfe9                	j	8000271e <argraw+0x2c>
  panic("argraw");
    80002746:	00005517          	auipc	a0,0x5
    8000274a:	c2250513          	addi	a0,a0,-990 # 80007368 <etext+0x368>
    8000274e:	892fe0ef          	jal	800007e0 <panic>

0000000080002752 <fetchaddr>:
{
    80002752:	1101                	addi	sp,sp,-32
    80002754:	ec06                	sd	ra,24(sp)
    80002756:	e822                	sd	s0,16(sp)
    80002758:	e426                	sd	s1,8(sp)
    8000275a:	e04a                	sd	s2,0(sp)
    8000275c:	1000                	addi	s0,sp,32
    8000275e:	84aa                	mv	s1,a0
    80002760:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002762:	96cff0ef          	jal	800018ce <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002766:	653c                	ld	a5,72(a0)
    80002768:	02f4f663          	bgeu	s1,a5,80002794 <fetchaddr+0x42>
    8000276c:	00848713          	addi	a4,s1,8
    80002770:	02e7e463          	bltu	a5,a4,80002798 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002774:	46a1                	li	a3,8
    80002776:	8626                	mv	a2,s1
    80002778:	85ca                	mv	a1,s2
    8000277a:	6928                	ld	a0,80(a0)
    8000277c:	f4bfe0ef          	jal	800016c6 <copyin>
    80002780:	00a03533          	snez	a0,a0
    80002784:	40a00533          	neg	a0,a0
}
    80002788:	60e2                	ld	ra,24(sp)
    8000278a:	6442                	ld	s0,16(sp)
    8000278c:	64a2                	ld	s1,8(sp)
    8000278e:	6902                	ld	s2,0(sp)
    80002790:	6105                	addi	sp,sp,32
    80002792:	8082                	ret
    return -1;
    80002794:	557d                	li	a0,-1
    80002796:	bfcd                	j	80002788 <fetchaddr+0x36>
    80002798:	557d                	li	a0,-1
    8000279a:	b7fd                	j	80002788 <fetchaddr+0x36>

000000008000279c <fetchstr>:
{
    8000279c:	7179                	addi	sp,sp,-48
    8000279e:	f406                	sd	ra,40(sp)
    800027a0:	f022                	sd	s0,32(sp)
    800027a2:	ec26                	sd	s1,24(sp)
    800027a4:	e84a                	sd	s2,16(sp)
    800027a6:	e44e                	sd	s3,8(sp)
    800027a8:	1800                	addi	s0,sp,48
    800027aa:	892a                	mv	s2,a0
    800027ac:	84ae                	mv	s1,a1
    800027ae:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800027b0:	91eff0ef          	jal	800018ce <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800027b4:	86ce                	mv	a3,s3
    800027b6:	864a                	mv	a2,s2
    800027b8:	85a6                	mv	a1,s1
    800027ba:	6928                	ld	a0,80(a0)
    800027bc:	ccdfe0ef          	jal	80001488 <copyinstr>
    800027c0:	00054c63          	bltz	a0,800027d8 <fetchstr+0x3c>
  return strlen(buf);
    800027c4:	8526                	mv	a0,s1
    800027c6:	e4cfe0ef          	jal	80000e12 <strlen>
}
    800027ca:	70a2                	ld	ra,40(sp)
    800027cc:	7402                	ld	s0,32(sp)
    800027ce:	64e2                	ld	s1,24(sp)
    800027d0:	6942                	ld	s2,16(sp)
    800027d2:	69a2                	ld	s3,8(sp)
    800027d4:	6145                	addi	sp,sp,48
    800027d6:	8082                	ret
    return -1;
    800027d8:	557d                	li	a0,-1
    800027da:	bfc5                	j	800027ca <fetchstr+0x2e>

00000000800027dc <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800027dc:	1101                	addi	sp,sp,-32
    800027de:	ec06                	sd	ra,24(sp)
    800027e0:	e822                	sd	s0,16(sp)
    800027e2:	e426                	sd	s1,8(sp)
    800027e4:	1000                	addi	s0,sp,32
    800027e6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027e8:	f0bff0ef          	jal	800026f2 <argraw>
    800027ec:	c088                	sw	a0,0(s1)
}
    800027ee:	60e2                	ld	ra,24(sp)
    800027f0:	6442                	ld	s0,16(sp)
    800027f2:	64a2                	ld	s1,8(sp)
    800027f4:	6105                	addi	sp,sp,32
    800027f6:	8082                	ret

00000000800027f8 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800027f8:	1101                	addi	sp,sp,-32
    800027fa:	ec06                	sd	ra,24(sp)
    800027fc:	e822                	sd	s0,16(sp)
    800027fe:	e426                	sd	s1,8(sp)
    80002800:	1000                	addi	s0,sp,32
    80002802:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002804:	eefff0ef          	jal	800026f2 <argraw>
    80002808:	e088                	sd	a0,0(s1)
}
    8000280a:	60e2                	ld	ra,24(sp)
    8000280c:	6442                	ld	s0,16(sp)
    8000280e:	64a2                	ld	s1,8(sp)
    80002810:	6105                	addi	sp,sp,32
    80002812:	8082                	ret

0000000080002814 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002814:	7179                	addi	sp,sp,-48
    80002816:	f406                	sd	ra,40(sp)
    80002818:	f022                	sd	s0,32(sp)
    8000281a:	ec26                	sd	s1,24(sp)
    8000281c:	e84a                	sd	s2,16(sp)
    8000281e:	1800                	addi	s0,sp,48
    80002820:	84ae                	mv	s1,a1
    80002822:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002824:	fd840593          	addi	a1,s0,-40
    80002828:	fd1ff0ef          	jal	800027f8 <argaddr>
  return fetchstr(addr, buf, max);
    8000282c:	864a                	mv	a2,s2
    8000282e:	85a6                	mv	a1,s1
    80002830:	fd843503          	ld	a0,-40(s0)
    80002834:	f69ff0ef          	jal	8000279c <fetchstr>
}
    80002838:	70a2                	ld	ra,40(sp)
    8000283a:	7402                	ld	s0,32(sp)
    8000283c:	64e2                	ld	s1,24(sp)
    8000283e:	6942                	ld	s2,16(sp)
    80002840:	6145                	addi	sp,sp,48
    80002842:	8082                	ret

0000000080002844 <syscall>:
[SYS_shmctl]  sys_shmctl
};

void
syscall(void)
{
    80002844:	1101                	addi	sp,sp,-32
    80002846:	ec06                	sd	ra,24(sp)
    80002848:	e822                	sd	s0,16(sp)
    8000284a:	e426                	sd	s1,8(sp)
    8000284c:	e04a                	sd	s2,0(sp)
    8000284e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002850:	87eff0ef          	jal	800018ce <myproc>
    80002854:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002856:	05853903          	ld	s2,88(a0)
    8000285a:	0a893783          	ld	a5,168(s2)
    8000285e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002862:	37fd                	addiw	a5,a5,-1
    80002864:	4761                	li	a4,24
    80002866:	00f76f63          	bltu	a4,a5,80002884 <syscall+0x40>
    8000286a:	00369713          	slli	a4,a3,0x3
    8000286e:	00005797          	auipc	a5,0x5
    80002872:	f0278793          	addi	a5,a5,-254 # 80007770 <syscalls>
    80002876:	97ba                	add	a5,a5,a4
    80002878:	639c                	ld	a5,0(a5)
    8000287a:	c789                	beqz	a5,80002884 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000287c:	9782                	jalr	a5
    8000287e:	06a93823          	sd	a0,112(s2)
    80002882:	a829                	j	8000289c <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002884:	15848613          	addi	a2,s1,344
    80002888:	588c                	lw	a1,48(s1)
    8000288a:	00005517          	auipc	a0,0x5
    8000288e:	ae650513          	addi	a0,a0,-1306 # 80007370 <etext+0x370>
    80002892:	c69fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002896:	6cbc                	ld	a5,88(s1)
    80002898:	577d                	li	a4,-1
    8000289a:	fbb8                	sd	a4,112(a5)
  }
}
    8000289c:	60e2                	ld	ra,24(sp)
    8000289e:	6442                	ld	s0,16(sp)
    800028a0:	64a2                	ld	s1,8(sp)
    800028a2:	6902                	ld	s2,0(sp)
    800028a4:	6105                	addi	sp,sp,32
    800028a6:	8082                	ret

00000000800028a8 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800028a8:	1101                	addi	sp,sp,-32
    800028aa:	ec06                	sd	ra,24(sp)
    800028ac:	e822                	sd	s0,16(sp)
    800028ae:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800028b0:	fec40593          	addi	a1,s0,-20
    800028b4:	4501                	li	a0,0
    800028b6:	f27ff0ef          	jal	800027dc <argint>
  kexit(n);
    800028ba:	fec42503          	lw	a0,-20(s0)
    800028be:	f26ff0ef          	jal	80001fe4 <kexit>
  return 0;  // not reached
}
    800028c2:	4501                	li	a0,0
    800028c4:	60e2                	ld	ra,24(sp)
    800028c6:	6442                	ld	s0,16(sp)
    800028c8:	6105                	addi	sp,sp,32
    800028ca:	8082                	ret

00000000800028cc <sys_getpid>:

uint64
sys_getpid(void)
{
    800028cc:	1141                	addi	sp,sp,-16
    800028ce:	e406                	sd	ra,8(sp)
    800028d0:	e022                	sd	s0,0(sp)
    800028d2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800028d4:	ffbfe0ef          	jal	800018ce <myproc>
}
    800028d8:	5908                	lw	a0,48(a0)
    800028da:	60a2                	ld	ra,8(sp)
    800028dc:	6402                	ld	s0,0(sp)
    800028de:	0141                	addi	sp,sp,16
    800028e0:	8082                	ret

00000000800028e2 <sys_fork>:

uint64
sys_fork(void)
{
    800028e2:	1141                	addi	sp,sp,-16
    800028e4:	e406                	sd	ra,8(sp)
    800028e6:	e022                	sd	s0,0(sp)
    800028e8:	0800                	addi	s0,sp,16
  return kfork();
    800028ea:	b48ff0ef          	jal	80001c32 <kfork>
}
    800028ee:	60a2                	ld	ra,8(sp)
    800028f0:	6402                	ld	s0,0(sp)
    800028f2:	0141                	addi	sp,sp,16
    800028f4:	8082                	ret

00000000800028f6 <sys_wait>:

uint64
sys_wait(void)
{
    800028f6:	1101                	addi	sp,sp,-32
    800028f8:	ec06                	sd	ra,24(sp)
    800028fa:	e822                	sd	s0,16(sp)
    800028fc:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800028fe:	fe840593          	addi	a1,s0,-24
    80002902:	4501                	li	a0,0
    80002904:	ef5ff0ef          	jal	800027f8 <argaddr>
  return kwait(p);
    80002908:	fe843503          	ld	a0,-24(s0)
    8000290c:	82fff0ef          	jal	8000213a <kwait>
}
    80002910:	60e2                	ld	ra,24(sp)
    80002912:	6442                	ld	s0,16(sp)
    80002914:	6105                	addi	sp,sp,32
    80002916:	8082                	ret

0000000080002918 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002918:	7179                	addi	sp,sp,-48
    8000291a:	f406                	sd	ra,40(sp)
    8000291c:	f022                	sd	s0,32(sp)
    8000291e:	ec26                	sd	s1,24(sp)
    80002920:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002922:	fd840593          	addi	a1,s0,-40
    80002926:	4501                	li	a0,0
    80002928:	eb5ff0ef          	jal	800027dc <argint>
  argint(1, &t);
    8000292c:	fdc40593          	addi	a1,s0,-36
    80002930:	4505                	li	a0,1
    80002932:	eabff0ef          	jal	800027dc <argint>
  addr = myproc()->sz;
    80002936:	f99fe0ef          	jal	800018ce <myproc>
    8000293a:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    8000293c:	fdc42703          	lw	a4,-36(s0)
    80002940:	4785                	li	a5,1
    80002942:	02f70763          	beq	a4,a5,80002970 <sys_sbrk+0x58>
    80002946:	fd842783          	lw	a5,-40(s0)
    8000294a:	0207c363          	bltz	a5,80002970 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    8000294e:	97a6                	add	a5,a5,s1
    80002950:	0297ee63          	bltu	a5,s1,8000298c <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002954:	02000737          	lui	a4,0x2000
    80002958:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    8000295a:	0736                	slli	a4,a4,0xd
    8000295c:	02f76a63          	bltu	a4,a5,80002990 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002960:	f6ffe0ef          	jal	800018ce <myproc>
    80002964:	fd842703          	lw	a4,-40(s0)
    80002968:	653c                	ld	a5,72(a0)
    8000296a:	97ba                	add	a5,a5,a4
    8000296c:	e53c                	sd	a5,72(a0)
    8000296e:	a039                	j	8000297c <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002970:	fd842503          	lw	a0,-40(s0)
    80002974:	a5cff0ef          	jal	80001bd0 <growproc>
    80002978:	00054863          	bltz	a0,80002988 <sys_sbrk+0x70>
  }
  return addr;
}
    8000297c:	8526                	mv	a0,s1
    8000297e:	70a2                	ld	ra,40(sp)
    80002980:	7402                	ld	s0,32(sp)
    80002982:	64e2                	ld	s1,24(sp)
    80002984:	6145                	addi	sp,sp,48
    80002986:	8082                	ret
      return -1;
    80002988:	54fd                	li	s1,-1
    8000298a:	bfcd                	j	8000297c <sys_sbrk+0x64>
      return -1;
    8000298c:	54fd                	li	s1,-1
    8000298e:	b7fd                	j	8000297c <sys_sbrk+0x64>
      return -1;
    80002990:	54fd                	li	s1,-1
    80002992:	b7ed                	j	8000297c <sys_sbrk+0x64>

0000000080002994 <sys_pause>:

uint64
sys_pause(void)
{
    80002994:	7139                	addi	sp,sp,-64
    80002996:	fc06                	sd	ra,56(sp)
    80002998:	f822                	sd	s0,48(sp)
    8000299a:	f04a                	sd	s2,32(sp)
    8000299c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000299e:	fcc40593          	addi	a1,s0,-52
    800029a2:	4501                	li	a0,0
    800029a4:	e39ff0ef          	jal	800027dc <argint>
  if(n < 0)
    800029a8:	fcc42783          	lw	a5,-52(s0)
    800029ac:	0607c763          	bltz	a5,80002a1a <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    800029b0:	00013517          	auipc	a0,0x13
    800029b4:	df850513          	addi	a0,a0,-520 # 800157a8 <tickslock>
    800029b8:	a16fe0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    800029bc:	00005917          	auipc	s2,0x5
    800029c0:	ebc92903          	lw	s2,-324(s2) # 80007878 <ticks>
  while(ticks - ticks0 < n){
    800029c4:	fcc42783          	lw	a5,-52(s0)
    800029c8:	cf8d                	beqz	a5,80002a02 <sys_pause+0x6e>
    800029ca:	f426                	sd	s1,40(sp)
    800029cc:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800029ce:	00013997          	auipc	s3,0x13
    800029d2:	dda98993          	addi	s3,s3,-550 # 800157a8 <tickslock>
    800029d6:	00005497          	auipc	s1,0x5
    800029da:	ea248493          	addi	s1,s1,-350 # 80007878 <ticks>
    if(killed(myproc())){
    800029de:	ef1fe0ef          	jal	800018ce <myproc>
    800029e2:	f2eff0ef          	jal	80002110 <killed>
    800029e6:	ed0d                	bnez	a0,80002a20 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    800029e8:	85ce                	mv	a1,s3
    800029ea:	8526                	mv	a0,s1
    800029ec:	cecff0ef          	jal	80001ed8 <sleep>
  while(ticks - ticks0 < n){
    800029f0:	409c                	lw	a5,0(s1)
    800029f2:	412787bb          	subw	a5,a5,s2
    800029f6:	fcc42703          	lw	a4,-52(s0)
    800029fa:	fee7e2e3          	bltu	a5,a4,800029de <sys_pause+0x4a>
    800029fe:	74a2                	ld	s1,40(sp)
    80002a00:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a02:	00013517          	auipc	a0,0x13
    80002a06:	da650513          	addi	a0,a0,-602 # 800157a8 <tickslock>
    80002a0a:	a5cfe0ef          	jal	80000c66 <release>
  return 0;
    80002a0e:	4501                	li	a0,0
}
    80002a10:	70e2                	ld	ra,56(sp)
    80002a12:	7442                	ld	s0,48(sp)
    80002a14:	7902                	ld	s2,32(sp)
    80002a16:	6121                	addi	sp,sp,64
    80002a18:	8082                	ret
    n = 0;
    80002a1a:	fc042623          	sw	zero,-52(s0)
    80002a1e:	bf49                	j	800029b0 <sys_pause+0x1c>
      release(&tickslock);
    80002a20:	00013517          	auipc	a0,0x13
    80002a24:	d8850513          	addi	a0,a0,-632 # 800157a8 <tickslock>
    80002a28:	a3efe0ef          	jal	80000c66 <release>
      return -1;
    80002a2c:	557d                	li	a0,-1
    80002a2e:	74a2                	ld	s1,40(sp)
    80002a30:	69e2                	ld	s3,24(sp)
    80002a32:	bff9                	j	80002a10 <sys_pause+0x7c>

0000000080002a34 <sys_kill>:

uint64
sys_kill(void)
{
    80002a34:	1101                	addi	sp,sp,-32
    80002a36:	ec06                	sd	ra,24(sp)
    80002a38:	e822                	sd	s0,16(sp)
    80002a3a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a3c:	fec40593          	addi	a1,s0,-20
    80002a40:	4501                	li	a0,0
    80002a42:	d9bff0ef          	jal	800027dc <argint>
  return kkill(pid);
    80002a46:	fec42503          	lw	a0,-20(s0)
    80002a4a:	e3cff0ef          	jal	80002086 <kkill>
}
    80002a4e:	60e2                	ld	ra,24(sp)
    80002a50:	6442                	ld	s0,16(sp)
    80002a52:	6105                	addi	sp,sp,32
    80002a54:	8082                	ret

0000000080002a56 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a56:	1101                	addi	sp,sp,-32
    80002a58:	ec06                	sd	ra,24(sp)
    80002a5a:	e822                	sd	s0,16(sp)
    80002a5c:	e426                	sd	s1,8(sp)
    80002a5e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a60:	00013517          	auipc	a0,0x13
    80002a64:	d4850513          	addi	a0,a0,-696 # 800157a8 <tickslock>
    80002a68:	966fe0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80002a6c:	00005497          	auipc	s1,0x5
    80002a70:	e0c4a483          	lw	s1,-500(s1) # 80007878 <ticks>
  release(&tickslock);
    80002a74:	00013517          	auipc	a0,0x13
    80002a78:	d3450513          	addi	a0,a0,-716 # 800157a8 <tickslock>
    80002a7c:	9eafe0ef          	jal	80000c66 <release>
  return xticks;
}
    80002a80:	02049513          	slli	a0,s1,0x20
    80002a84:	9101                	srli	a0,a0,0x20
    80002a86:	60e2                	ld	ra,24(sp)
    80002a88:	6442                	ld	s0,16(sp)
    80002a8a:	64a2                	ld	s1,8(sp)
    80002a8c:	6105                	addi	sp,sp,32
    80002a8e:	8082                	ret

0000000080002a90 <shmget>:
// Shared memory array
struct sharedmem shmtable[MAX_SHAREDMEM];

int
shmget(int id, int size)
{
    80002a90:	1101                	addi	sp,sp,-32
    80002a92:	ec06                	sd	ra,24(sp)
    80002a94:	e822                	sd	s0,16(sp)
    80002a96:	e426                	sd	s1,8(sp)
    80002a98:	1000                	addi	s0,sp,32
    80002a9a:	84aa                	mv	s1,a0
  for(int i = 0; i < MAX_SHAREDMEM; i++){
    80002a9c:	00013797          	auipc	a5,0x13
    80002aa0:	d2478793          	addi	a5,a5,-732 # 800157c0 <shmtable>
    80002aa4:	00013697          	auipc	a3,0x13
    80002aa8:	f1c68693          	addi	a3,a3,-228 # 800159c0 <bcache>
    80002aac:	a029                	j	80002ab6 <shmget+0x26>
    80002aae:	02078793          	addi	a5,a5,32
    80002ab2:	00d78963          	beq	a5,a3,80002ac4 <shmget+0x34>
    if(shmtable[i].valid && shmtable[i].id == id)
    80002ab6:	4f98                	lw	a4,24(a5)
    80002ab8:	db7d                	beqz	a4,80002aae <shmget+0x1e>
    80002aba:	4398                	lw	a4,0(a5)
    80002abc:	fe9719e3          	bne	a4,s1,80002aae <shmget+0x1e>
      return id;
    80002ac0:	8526                	mv	a0,s1
    80002ac2:	a839                	j	80002ae0 <shmget+0x50>
    80002ac4:	00013717          	auipc	a4,0x13
    80002ac8:	d1470713          	addi	a4,a4,-748 # 800157d8 <shmtable+0x18>
  }
  for(int i = 0; i < MAX_SHAREDMEM; i++){
    80002acc:	4781                	li	a5,0
    80002ace:	4641                	li	a2,16
    if(!shmtable[i].valid){
    80002ad0:	4314                	lw	a3,0(a4)
    80002ad2:	ce81                	beqz	a3,80002aea <shmget+0x5a>
  for(int i = 0; i < MAX_SHAREDMEM; i++){
    80002ad4:	2785                	addiw	a5,a5,1
    80002ad6:	02070713          	addi	a4,a4,32
    80002ada:	fec79be3          	bne	a5,a2,80002ad0 <shmget+0x40>
      shmtable[i].addr = (uint64)kalloc();
      shmtable[i].valid = 1;
      return id;
    }
  }
  return -1;
    80002ade:	557d                	li	a0,-1
}
    80002ae0:	60e2                	ld	ra,24(sp)
    80002ae2:	6442                	ld	s0,16(sp)
    80002ae4:	64a2                	ld	s1,8(sp)
    80002ae6:	6105                	addi	sp,sp,32
    80002ae8:	8082                	ret
    80002aea:	e04a                	sd	s2,0(sp)
      shmtable[i].id = id;
    80002aec:	0796                	slli	a5,a5,0x5
    80002aee:	00013917          	auipc	s2,0x13
    80002af2:	cd290913          	addi	s2,s2,-814 # 800157c0 <shmtable>
    80002af6:	993e                	add	s2,s2,a5
    80002af8:	00992023          	sw	s1,0(s2)
      shmtable[i].size = size;
    80002afc:	00b92823          	sw	a1,16(s2)
      shmtable[i].refcount = 0;
    80002b00:	00092a23          	sw	zero,20(s2)
      shmtable[i].addr = (uint64)kalloc();
    80002b04:	ffbfd0ef          	jal	80000afe <kalloc>
    80002b08:	00a93423          	sd	a0,8(s2)
      shmtable[i].valid = 1;
    80002b0c:	4785                	li	a5,1
    80002b0e:	00f92c23          	sw	a5,24(s2)
      return id;
    80002b12:	8526                	mv	a0,s1
    80002b14:	6902                	ld	s2,0(sp)
    80002b16:	b7e9                	j	80002ae0 <shmget+0x50>

0000000080002b18 <shmat>:

uint64
shmat(int id)
{
    80002b18:	1101                	addi	sp,sp,-32
    80002b1a:	ec06                	sd	ra,24(sp)
    80002b1c:	e822                	sd	s0,16(sp)
    80002b1e:	e426                	sd	s1,8(sp)
    80002b20:	e04a                	sd	s2,0(sp)
    80002b22:	1000                	addi	s0,sp,32
    80002b24:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b26:	da9fe0ef          	jal	800018ce <myproc>
    80002b2a:	892a                	mv	s2,a0
  for(int i = 0; i < MAX_SHAREDMEM; i++){
    80002b2c:	00013797          	auipc	a5,0x13
    80002b30:	c9478793          	addi	a5,a5,-876 # 800157c0 <shmtable>
    80002b34:	4701                	li	a4,0
    80002b36:	4641                	li	a2,16
    80002b38:	a031                	j	80002b44 <shmat+0x2c>
    80002b3a:	2705                	addiw	a4,a4,1
    80002b3c:	02078793          	addi	a5,a5,32
    80002b40:	04c70663          	beq	a4,a2,80002b8c <shmat+0x74>
    if(shmtable[i].valid && shmtable[i].id == id){
    80002b44:	4f94                	lw	a3,24(a5)
    80002b46:	daf5                	beqz	a3,80002b3a <shmat+0x22>
    80002b48:	4394                	lw	a3,0(a5)
    80002b4a:	fe9698e3          	bne	a3,s1,80002b3a <shmat+0x22>
      shmtable[i].refcount++;
    80002b4e:	0716                	slli	a4,a4,0x5
    80002b50:	00013797          	auipc	a5,0x13
    80002b54:	c7078793          	addi	a5,a5,-912 # 800157c0 <shmtable>
    80002b58:	97ba                	add	a5,a5,a4
    80002b5a:	4bd8                	lw	a4,20(a5)
    80002b5c:	2705                	addiw	a4,a4,1
    80002b5e:	cbd8                	sw	a4,20(a5)
      // map physical address to process virtual address space
      uint64 va = PGROUNDUP(p->sz);
    80002b60:	04893483          	ld	s1,72(s2)
    80002b64:	6705                	lui	a4,0x1
    80002b66:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    80002b68:	94ba                	add	s1,s1,a4
    80002b6a:	777d                	lui	a4,0xfffff
    80002b6c:	8cf9                	and	s1,s1,a4
      if(mappages(p->pagetable, va, PGSIZE, shmtable[i].addr, PTE_R|PTE_W|PTE_U) < 0)
    80002b6e:	4759                	li	a4,22
    80002b70:	6794                	ld	a3,8(a5)
    80002b72:	6605                	lui	a2,0x1
    80002b74:	85a6                	mv	a1,s1
    80002b76:	05093503          	ld	a0,80(s2)
    80002b7a:	c74fe0ef          	jal	80000fee <mappages>
    80002b7e:	00054f63          	bltz	a0,80002b9c <shmat+0x84>
        return -1;
      p->sz = va + PGSIZE;
    80002b82:	6785                	lui	a5,0x1
    80002b84:	97a6                	add	a5,a5,s1
    80002b86:	04f93423          	sd	a5,72(s2)
      return va;
    80002b8a:	a011                	j	80002b8e <shmat+0x76>
    }
  }
  return -1;
    80002b8c:	54fd                	li	s1,-1
}
    80002b8e:	8526                	mv	a0,s1
    80002b90:	60e2                	ld	ra,24(sp)
    80002b92:	6442                	ld	s0,16(sp)
    80002b94:	64a2                	ld	s1,8(sp)
    80002b96:	6902                	ld	s2,0(sp)
    80002b98:	6105                	addi	sp,sp,32
    80002b9a:	8082                	ret
        return -1;
    80002b9c:	54fd                	li	s1,-1
    80002b9e:	bfc5                	j	80002b8e <shmat+0x76>

0000000080002ba0 <shmdt>:

int
shmdt(int id)
{
    80002ba0:	1141                	addi	sp,sp,-16
    80002ba2:	e422                	sd	s0,8(sp)
    80002ba4:	0800                	addi	s0,sp,16
  for(int i = 0; i < MAX_SHAREDMEM; i++){
    80002ba6:	00013797          	auipc	a5,0x13
    80002baa:	c1a78793          	addi	a5,a5,-998 # 800157c0 <shmtable>
    80002bae:	4701                	li	a4,0
    80002bb0:	4641                	li	a2,16
    80002bb2:	a031                	j	80002bbe <shmdt+0x1e>
    80002bb4:	2705                	addiw	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde279>
    80002bb6:	02078793          	addi	a5,a5,32
    80002bba:	02c70263          	beq	a4,a2,80002bde <shmdt+0x3e>
    if(shmtable[i].valid && shmtable[i].id == id){
    80002bbe:	4f94                	lw	a3,24(a5)
    80002bc0:	daf5                	beqz	a3,80002bb4 <shmdt+0x14>
    80002bc2:	4394                	lw	a3,0(a5)
    80002bc4:	fea698e3          	bne	a3,a0,80002bb4 <shmdt+0x14>
      shmtable[i].refcount--;
    80002bc8:	0716                	slli	a4,a4,0x5
    80002bca:	00013797          	auipc	a5,0x13
    80002bce:	bf678793          	addi	a5,a5,-1034 # 800157c0 <shmtable>
    80002bd2:	97ba                	add	a5,a5,a4
    80002bd4:	4bd8                	lw	a4,20(a5)
    80002bd6:	377d                	addiw	a4,a4,-1
    80002bd8:	cbd8                	sw	a4,20(a5)
      return 0;
    80002bda:	4501                	li	a0,0
    80002bdc:	a011                	j	80002be0 <shmdt+0x40>
    }
  }
  return -1;
    80002bde:	557d                	li	a0,-1
}
    80002be0:	6422                	ld	s0,8(sp)
    80002be2:	0141                	addi	sp,sp,16
    80002be4:	8082                	ret

0000000080002be6 <shmctl>:

int
shmctl(int id)
{
    80002be6:	1101                	addi	sp,sp,-32
    80002be8:	ec06                	sd	ra,24(sp)
    80002bea:	e822                	sd	s0,16(sp)
    80002bec:	e426                	sd	s1,8(sp)
    80002bee:	1000                	addi	s0,sp,32
  for(int i = 0; i < MAX_SHAREDMEM; i++){
    80002bf0:	00013797          	auipc	a5,0x13
    80002bf4:	bd078793          	addi	a5,a5,-1072 # 800157c0 <shmtable>
    80002bf8:	4701                	li	a4,0
    80002bfa:	45c1                	li	a1,16
    80002bfc:	a031                	j	80002c08 <shmctl+0x22>
    80002bfe:	2705                	addiw	a4,a4,1
    80002c00:	02078793          	addi	a5,a5,32
    80002c04:	02b70863          	beq	a4,a1,80002c34 <shmctl+0x4e>
    if(shmtable[i].valid && shmtable[i].id == id){
    80002c08:	4f94                	lw	a3,24(a5)
    80002c0a:	daf5                	beqz	a3,80002bfe <shmctl+0x18>
    80002c0c:	4394                	lw	a3,0(a5)
    80002c0e:	fea698e3          	bne	a3,a0,80002bfe <shmctl+0x18>
      if(shmtable[i].refcount == 0){
    80002c12:	4bc4                	lw	s1,20(a5)
    80002c14:	f4ed                	bnez	s1,80002bfe <shmctl+0x18>
    80002c16:	e04a                	sd	s2,0(sp)
        kfree((void*)shmtable[i].addr);
    80002c18:	0716                	slli	a4,a4,0x5
    80002c1a:	00013917          	auipc	s2,0x13
    80002c1e:	ba690913          	addi	s2,s2,-1114 # 800157c0 <shmtable>
    80002c22:	993a                	add	s2,s2,a4
    80002c24:	00893503          	ld	a0,8(s2)
    80002c28:	df5fd0ef          	jal	80000a1c <kfree>
        shmtable[i].valid = 0;
    80002c2c:	00092c23          	sw	zero,24(s2)
        return 0;
    80002c30:	6902                	ld	s2,0(sp)
    80002c32:	a011                	j	80002c36 <shmctl+0x50>
      }
    }
  }
  return -1;
    80002c34:	54fd                	li	s1,-1
}
    80002c36:	8526                	mv	a0,s1
    80002c38:	60e2                	ld	ra,24(sp)
    80002c3a:	6442                	ld	s0,16(sp)
    80002c3c:	64a2                	ld	s1,8(sp)
    80002c3e:	6105                	addi	sp,sp,32
    80002c40:	8082                	ret

0000000080002c42 <sys_shmget>:

uint64
sys_shmget(void)
{
    80002c42:	1101                	addi	sp,sp,-32
    80002c44:	ec06                	sd	ra,24(sp)
    80002c46:	e822                	sd	s0,16(sp)
    80002c48:	1000                	addi	s0,sp,32
  int id, size;
  argint(0, &id);
    80002c4a:	fec40593          	addi	a1,s0,-20
    80002c4e:	4501                	li	a0,0
    80002c50:	b8dff0ef          	jal	800027dc <argint>
  argint(1, &size);
    80002c54:	fe840593          	addi	a1,s0,-24
    80002c58:	4505                	li	a0,1
    80002c5a:	b83ff0ef          	jal	800027dc <argint>
  return shmget(id, size);
    80002c5e:	fe842583          	lw	a1,-24(s0)
    80002c62:	fec42503          	lw	a0,-20(s0)
    80002c66:	e2bff0ef          	jal	80002a90 <shmget>
}
    80002c6a:	60e2                	ld	ra,24(sp)
    80002c6c:	6442                	ld	s0,16(sp)
    80002c6e:	6105                	addi	sp,sp,32
    80002c70:	8082                	ret

0000000080002c72 <sys_shmat>:

uint64
sys_shmat(void)
{
    80002c72:	1101                	addi	sp,sp,-32
    80002c74:	ec06                	sd	ra,24(sp)
    80002c76:	e822                	sd	s0,16(sp)
    80002c78:	1000                	addi	s0,sp,32
  int id;
  argint(0, &id);
    80002c7a:	fec40593          	addi	a1,s0,-20
    80002c7e:	4501                	li	a0,0
    80002c80:	b5dff0ef          	jal	800027dc <argint>
  return shmat(id);
    80002c84:	fec42503          	lw	a0,-20(s0)
    80002c88:	e91ff0ef          	jal	80002b18 <shmat>
}
    80002c8c:	60e2                	ld	ra,24(sp)
    80002c8e:	6442                	ld	s0,16(sp)
    80002c90:	6105                	addi	sp,sp,32
    80002c92:	8082                	ret

0000000080002c94 <sys_shmdt>:

uint64
sys_shmdt(void)
{
    80002c94:	1101                	addi	sp,sp,-32
    80002c96:	ec06                	sd	ra,24(sp)
    80002c98:	e822                	sd	s0,16(sp)
    80002c9a:	1000                	addi	s0,sp,32
  int id;
  argint(0, &id);
    80002c9c:	fec40593          	addi	a1,s0,-20
    80002ca0:	4501                	li	a0,0
    80002ca2:	b3bff0ef          	jal	800027dc <argint>
  return shmdt(id);
    80002ca6:	fec42503          	lw	a0,-20(s0)
    80002caa:	ef7ff0ef          	jal	80002ba0 <shmdt>
}
    80002cae:	60e2                	ld	ra,24(sp)
    80002cb0:	6442                	ld	s0,16(sp)
    80002cb2:	6105                	addi	sp,sp,32
    80002cb4:	8082                	ret

0000000080002cb6 <sys_shmctl>:

uint64
sys_shmctl(void)
{
    80002cb6:	1101                	addi	sp,sp,-32
    80002cb8:	ec06                	sd	ra,24(sp)
    80002cba:	e822                	sd	s0,16(sp)
    80002cbc:	1000                	addi	s0,sp,32
  int id;
  argint(0, &id);
    80002cbe:	fec40593          	addi	a1,s0,-20
    80002cc2:	4501                	li	a0,0
    80002cc4:	b19ff0ef          	jal	800027dc <argint>
  return shmctl(id);
    80002cc8:	fec42503          	lw	a0,-20(s0)
    80002ccc:	f1bff0ef          	jal	80002be6 <shmctl>
}
    80002cd0:	60e2                	ld	ra,24(sp)
    80002cd2:	6442                	ld	s0,16(sp)
    80002cd4:	6105                	addi	sp,sp,32
    80002cd6:	8082                	ret

0000000080002cd8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002cd8:	7179                	addi	sp,sp,-48
    80002cda:	f406                	sd	ra,40(sp)
    80002cdc:	f022                	sd	s0,32(sp)
    80002cde:	ec26                	sd	s1,24(sp)
    80002ce0:	e84a                	sd	s2,16(sp)
    80002ce2:	e44e                	sd	s3,8(sp)
    80002ce4:	e052                	sd	s4,0(sp)
    80002ce6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ce8:	00004597          	auipc	a1,0x4
    80002cec:	6a858593          	addi	a1,a1,1704 # 80007390 <etext+0x390>
    80002cf0:	00013517          	auipc	a0,0x13
    80002cf4:	cd050513          	addi	a0,a0,-816 # 800159c0 <bcache>
    80002cf8:	e57fd0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002cfc:	0001b797          	auipc	a5,0x1b
    80002d00:	cc478793          	addi	a5,a5,-828 # 8001d9c0 <bcache+0x8000>
    80002d04:	0001b717          	auipc	a4,0x1b
    80002d08:	f2470713          	addi	a4,a4,-220 # 8001dc28 <bcache+0x8268>
    80002d0c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002d10:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d14:	00013497          	auipc	s1,0x13
    80002d18:	cc448493          	addi	s1,s1,-828 # 800159d8 <bcache+0x18>
    b->next = bcache.head.next;
    80002d1c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002d1e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002d20:	00004a17          	auipc	s4,0x4
    80002d24:	678a0a13          	addi	s4,s4,1656 # 80007398 <etext+0x398>
    b->next = bcache.head.next;
    80002d28:	2b893783          	ld	a5,696(s2)
    80002d2c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d2e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d32:	85d2                	mv	a1,s4
    80002d34:	01048513          	addi	a0,s1,16
    80002d38:	322010ef          	jal	8000405a <initsleeplock>
    bcache.head.next->prev = b;
    80002d3c:	2b893783          	ld	a5,696(s2)
    80002d40:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d42:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d46:	45848493          	addi	s1,s1,1112
    80002d4a:	fd349fe3          	bne	s1,s3,80002d28 <binit+0x50>
  }
}
    80002d4e:	70a2                	ld	ra,40(sp)
    80002d50:	7402                	ld	s0,32(sp)
    80002d52:	64e2                	ld	s1,24(sp)
    80002d54:	6942                	ld	s2,16(sp)
    80002d56:	69a2                	ld	s3,8(sp)
    80002d58:	6a02                	ld	s4,0(sp)
    80002d5a:	6145                	addi	sp,sp,48
    80002d5c:	8082                	ret

0000000080002d5e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002d5e:	7179                	addi	sp,sp,-48
    80002d60:	f406                	sd	ra,40(sp)
    80002d62:	f022                	sd	s0,32(sp)
    80002d64:	ec26                	sd	s1,24(sp)
    80002d66:	e84a                	sd	s2,16(sp)
    80002d68:	e44e                	sd	s3,8(sp)
    80002d6a:	1800                	addi	s0,sp,48
    80002d6c:	892a                	mv	s2,a0
    80002d6e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002d70:	00013517          	auipc	a0,0x13
    80002d74:	c5050513          	addi	a0,a0,-944 # 800159c0 <bcache>
    80002d78:	e57fd0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002d7c:	0001b497          	auipc	s1,0x1b
    80002d80:	efc4b483          	ld	s1,-260(s1) # 8001dc78 <bcache+0x82b8>
    80002d84:	0001b797          	auipc	a5,0x1b
    80002d88:	ea478793          	addi	a5,a5,-348 # 8001dc28 <bcache+0x8268>
    80002d8c:	02f48b63          	beq	s1,a5,80002dc2 <bread+0x64>
    80002d90:	873e                	mv	a4,a5
    80002d92:	a021                	j	80002d9a <bread+0x3c>
    80002d94:	68a4                	ld	s1,80(s1)
    80002d96:	02e48663          	beq	s1,a4,80002dc2 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002d9a:	449c                	lw	a5,8(s1)
    80002d9c:	ff279ce3          	bne	a5,s2,80002d94 <bread+0x36>
    80002da0:	44dc                	lw	a5,12(s1)
    80002da2:	ff3799e3          	bne	a5,s3,80002d94 <bread+0x36>
      b->refcnt++;
    80002da6:	40bc                	lw	a5,64(s1)
    80002da8:	2785                	addiw	a5,a5,1
    80002daa:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002dac:	00013517          	auipc	a0,0x13
    80002db0:	c1450513          	addi	a0,a0,-1004 # 800159c0 <bcache>
    80002db4:	eb3fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002db8:	01048513          	addi	a0,s1,16
    80002dbc:	2d4010ef          	jal	80004090 <acquiresleep>
      return b;
    80002dc0:	a889                	j	80002e12 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002dc2:	0001b497          	auipc	s1,0x1b
    80002dc6:	eae4b483          	ld	s1,-338(s1) # 8001dc70 <bcache+0x82b0>
    80002dca:	0001b797          	auipc	a5,0x1b
    80002dce:	e5e78793          	addi	a5,a5,-418 # 8001dc28 <bcache+0x8268>
    80002dd2:	00f48863          	beq	s1,a5,80002de2 <bread+0x84>
    80002dd6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002dd8:	40bc                	lw	a5,64(s1)
    80002dda:	cb91                	beqz	a5,80002dee <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ddc:	64a4                	ld	s1,72(s1)
    80002dde:	fee49de3          	bne	s1,a4,80002dd8 <bread+0x7a>
  panic("bget: no buffers");
    80002de2:	00004517          	auipc	a0,0x4
    80002de6:	5be50513          	addi	a0,a0,1470 # 800073a0 <etext+0x3a0>
    80002dea:	9f7fd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80002dee:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002df2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002df6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002dfa:	4785                	li	a5,1
    80002dfc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002dfe:	00013517          	auipc	a0,0x13
    80002e02:	bc250513          	addi	a0,a0,-1086 # 800159c0 <bcache>
    80002e06:	e61fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002e0a:	01048513          	addi	a0,s1,16
    80002e0e:	282010ef          	jal	80004090 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002e12:	409c                	lw	a5,0(s1)
    80002e14:	cb89                	beqz	a5,80002e26 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002e16:	8526                	mv	a0,s1
    80002e18:	70a2                	ld	ra,40(sp)
    80002e1a:	7402                	ld	s0,32(sp)
    80002e1c:	64e2                	ld	s1,24(sp)
    80002e1e:	6942                	ld	s2,16(sp)
    80002e20:	69a2                	ld	s3,8(sp)
    80002e22:	6145                	addi	sp,sp,48
    80002e24:	8082                	ret
    virtio_disk_rw(b, 0);
    80002e26:	4581                	li	a1,0
    80002e28:	8526                	mv	a0,s1
    80002e2a:	2d7020ef          	jal	80005900 <virtio_disk_rw>
    b->valid = 1;
    80002e2e:	4785                	li	a5,1
    80002e30:	c09c                	sw	a5,0(s1)
  return b;
    80002e32:	b7d5                	j	80002e16 <bread+0xb8>

0000000080002e34 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002e34:	1101                	addi	sp,sp,-32
    80002e36:	ec06                	sd	ra,24(sp)
    80002e38:	e822                	sd	s0,16(sp)
    80002e3a:	e426                	sd	s1,8(sp)
    80002e3c:	1000                	addi	s0,sp,32
    80002e3e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e40:	0541                	addi	a0,a0,16
    80002e42:	2cc010ef          	jal	8000410e <holdingsleep>
    80002e46:	c911                	beqz	a0,80002e5a <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002e48:	4585                	li	a1,1
    80002e4a:	8526                	mv	a0,s1
    80002e4c:	2b5020ef          	jal	80005900 <virtio_disk_rw>
}
    80002e50:	60e2                	ld	ra,24(sp)
    80002e52:	6442                	ld	s0,16(sp)
    80002e54:	64a2                	ld	s1,8(sp)
    80002e56:	6105                	addi	sp,sp,32
    80002e58:	8082                	ret
    panic("bwrite");
    80002e5a:	00004517          	auipc	a0,0x4
    80002e5e:	55e50513          	addi	a0,a0,1374 # 800073b8 <etext+0x3b8>
    80002e62:	97ffd0ef          	jal	800007e0 <panic>

0000000080002e66 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002e66:	1101                	addi	sp,sp,-32
    80002e68:	ec06                	sd	ra,24(sp)
    80002e6a:	e822                	sd	s0,16(sp)
    80002e6c:	e426                	sd	s1,8(sp)
    80002e6e:	e04a                	sd	s2,0(sp)
    80002e70:	1000                	addi	s0,sp,32
    80002e72:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e74:	01050913          	addi	s2,a0,16
    80002e78:	854a                	mv	a0,s2
    80002e7a:	294010ef          	jal	8000410e <holdingsleep>
    80002e7e:	c135                	beqz	a0,80002ee2 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002e80:	854a                	mv	a0,s2
    80002e82:	254010ef          	jal	800040d6 <releasesleep>

  acquire(&bcache.lock);
    80002e86:	00013517          	auipc	a0,0x13
    80002e8a:	b3a50513          	addi	a0,a0,-1222 # 800159c0 <bcache>
    80002e8e:	d41fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002e92:	40bc                	lw	a5,64(s1)
    80002e94:	37fd                	addiw	a5,a5,-1
    80002e96:	0007871b          	sext.w	a4,a5
    80002e9a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002e9c:	e71d                	bnez	a4,80002eca <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002e9e:	68b8                	ld	a4,80(s1)
    80002ea0:	64bc                	ld	a5,72(s1)
    80002ea2:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002ea4:	68b8                	ld	a4,80(s1)
    80002ea6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002ea8:	0001b797          	auipc	a5,0x1b
    80002eac:	b1878793          	addi	a5,a5,-1256 # 8001d9c0 <bcache+0x8000>
    80002eb0:	2b87b703          	ld	a4,696(a5)
    80002eb4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002eb6:	0001b717          	auipc	a4,0x1b
    80002eba:	d7270713          	addi	a4,a4,-654 # 8001dc28 <bcache+0x8268>
    80002ebe:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002ec0:	2b87b703          	ld	a4,696(a5)
    80002ec4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002ec6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002eca:	00013517          	auipc	a0,0x13
    80002ece:	af650513          	addi	a0,a0,-1290 # 800159c0 <bcache>
    80002ed2:	d95fd0ef          	jal	80000c66 <release>
}
    80002ed6:	60e2                	ld	ra,24(sp)
    80002ed8:	6442                	ld	s0,16(sp)
    80002eda:	64a2                	ld	s1,8(sp)
    80002edc:	6902                	ld	s2,0(sp)
    80002ede:	6105                	addi	sp,sp,32
    80002ee0:	8082                	ret
    panic("brelse");
    80002ee2:	00004517          	auipc	a0,0x4
    80002ee6:	4de50513          	addi	a0,a0,1246 # 800073c0 <etext+0x3c0>
    80002eea:	8f7fd0ef          	jal	800007e0 <panic>

0000000080002eee <bpin>:

void
bpin(struct buf *b) {
    80002eee:	1101                	addi	sp,sp,-32
    80002ef0:	ec06                	sd	ra,24(sp)
    80002ef2:	e822                	sd	s0,16(sp)
    80002ef4:	e426                	sd	s1,8(sp)
    80002ef6:	1000                	addi	s0,sp,32
    80002ef8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002efa:	00013517          	auipc	a0,0x13
    80002efe:	ac650513          	addi	a0,a0,-1338 # 800159c0 <bcache>
    80002f02:	ccdfd0ef          	jal	80000bce <acquire>
  b->refcnt++;
    80002f06:	40bc                	lw	a5,64(s1)
    80002f08:	2785                	addiw	a5,a5,1
    80002f0a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f0c:	00013517          	auipc	a0,0x13
    80002f10:	ab450513          	addi	a0,a0,-1356 # 800159c0 <bcache>
    80002f14:	d53fd0ef          	jal	80000c66 <release>
}
    80002f18:	60e2                	ld	ra,24(sp)
    80002f1a:	6442                	ld	s0,16(sp)
    80002f1c:	64a2                	ld	s1,8(sp)
    80002f1e:	6105                	addi	sp,sp,32
    80002f20:	8082                	ret

0000000080002f22 <bunpin>:

void
bunpin(struct buf *b) {
    80002f22:	1101                	addi	sp,sp,-32
    80002f24:	ec06                	sd	ra,24(sp)
    80002f26:	e822                	sd	s0,16(sp)
    80002f28:	e426                	sd	s1,8(sp)
    80002f2a:	1000                	addi	s0,sp,32
    80002f2c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f2e:	00013517          	auipc	a0,0x13
    80002f32:	a9250513          	addi	a0,a0,-1390 # 800159c0 <bcache>
    80002f36:	c99fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002f3a:	40bc                	lw	a5,64(s1)
    80002f3c:	37fd                	addiw	a5,a5,-1
    80002f3e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f40:	00013517          	auipc	a0,0x13
    80002f44:	a8050513          	addi	a0,a0,-1408 # 800159c0 <bcache>
    80002f48:	d1ffd0ef          	jal	80000c66 <release>
}
    80002f4c:	60e2                	ld	ra,24(sp)
    80002f4e:	6442                	ld	s0,16(sp)
    80002f50:	64a2                	ld	s1,8(sp)
    80002f52:	6105                	addi	sp,sp,32
    80002f54:	8082                	ret

0000000080002f56 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002f56:	1101                	addi	sp,sp,-32
    80002f58:	ec06                	sd	ra,24(sp)
    80002f5a:	e822                	sd	s0,16(sp)
    80002f5c:	e426                	sd	s1,8(sp)
    80002f5e:	e04a                	sd	s2,0(sp)
    80002f60:	1000                	addi	s0,sp,32
    80002f62:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002f64:	00d5d59b          	srliw	a1,a1,0xd
    80002f68:	0001b797          	auipc	a5,0x1b
    80002f6c:	1347a783          	lw	a5,308(a5) # 8001e09c <sb+0x1c>
    80002f70:	9dbd                	addw	a1,a1,a5
    80002f72:	dedff0ef          	jal	80002d5e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002f76:	0074f713          	andi	a4,s1,7
    80002f7a:	4785                	li	a5,1
    80002f7c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002f80:	14ce                	slli	s1,s1,0x33
    80002f82:	90d9                	srli	s1,s1,0x36
    80002f84:	00950733          	add	a4,a0,s1
    80002f88:	05874703          	lbu	a4,88(a4)
    80002f8c:	00e7f6b3          	and	a3,a5,a4
    80002f90:	c29d                	beqz	a3,80002fb6 <bfree+0x60>
    80002f92:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002f94:	94aa                	add	s1,s1,a0
    80002f96:	fff7c793          	not	a5,a5
    80002f9a:	8f7d                	and	a4,a4,a5
    80002f9c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002fa0:	7f9000ef          	jal	80003f98 <log_write>
  brelse(bp);
    80002fa4:	854a                	mv	a0,s2
    80002fa6:	ec1ff0ef          	jal	80002e66 <brelse>
}
    80002faa:	60e2                	ld	ra,24(sp)
    80002fac:	6442                	ld	s0,16(sp)
    80002fae:	64a2                	ld	s1,8(sp)
    80002fb0:	6902                	ld	s2,0(sp)
    80002fb2:	6105                	addi	sp,sp,32
    80002fb4:	8082                	ret
    panic("freeing free block");
    80002fb6:	00004517          	auipc	a0,0x4
    80002fba:	41250513          	addi	a0,a0,1042 # 800073c8 <etext+0x3c8>
    80002fbe:	823fd0ef          	jal	800007e0 <panic>

0000000080002fc2 <balloc>:
{
    80002fc2:	711d                	addi	sp,sp,-96
    80002fc4:	ec86                	sd	ra,88(sp)
    80002fc6:	e8a2                	sd	s0,80(sp)
    80002fc8:	e4a6                	sd	s1,72(sp)
    80002fca:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002fcc:	0001b797          	auipc	a5,0x1b
    80002fd0:	0b87a783          	lw	a5,184(a5) # 8001e084 <sb+0x4>
    80002fd4:	0e078f63          	beqz	a5,800030d2 <balloc+0x110>
    80002fd8:	e0ca                	sd	s2,64(sp)
    80002fda:	fc4e                	sd	s3,56(sp)
    80002fdc:	f852                	sd	s4,48(sp)
    80002fde:	f456                	sd	s5,40(sp)
    80002fe0:	f05a                	sd	s6,32(sp)
    80002fe2:	ec5e                	sd	s7,24(sp)
    80002fe4:	e862                	sd	s8,16(sp)
    80002fe6:	e466                	sd	s9,8(sp)
    80002fe8:	8baa                	mv	s7,a0
    80002fea:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002fec:	0001bb17          	auipc	s6,0x1b
    80002ff0:	094b0b13          	addi	s6,s6,148 # 8001e080 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ff4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002ff6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ff8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002ffa:	6c89                	lui	s9,0x2
    80002ffc:	a0b5                	j	80003068 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002ffe:	97ca                	add	a5,a5,s2
    80003000:	8e55                	or	a2,a2,a3
    80003002:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003006:	854a                	mv	a0,s2
    80003008:	791000ef          	jal	80003f98 <log_write>
        brelse(bp);
    8000300c:	854a                	mv	a0,s2
    8000300e:	e59ff0ef          	jal	80002e66 <brelse>
  bp = bread(dev, bno);
    80003012:	85a6                	mv	a1,s1
    80003014:	855e                	mv	a0,s7
    80003016:	d49ff0ef          	jal	80002d5e <bread>
    8000301a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000301c:	40000613          	li	a2,1024
    80003020:	4581                	li	a1,0
    80003022:	05850513          	addi	a0,a0,88
    80003026:	c7dfd0ef          	jal	80000ca2 <memset>
  log_write(bp);
    8000302a:	854a                	mv	a0,s2
    8000302c:	76d000ef          	jal	80003f98 <log_write>
  brelse(bp);
    80003030:	854a                	mv	a0,s2
    80003032:	e35ff0ef          	jal	80002e66 <brelse>
}
    80003036:	6906                	ld	s2,64(sp)
    80003038:	79e2                	ld	s3,56(sp)
    8000303a:	7a42                	ld	s4,48(sp)
    8000303c:	7aa2                	ld	s5,40(sp)
    8000303e:	7b02                	ld	s6,32(sp)
    80003040:	6be2                	ld	s7,24(sp)
    80003042:	6c42                	ld	s8,16(sp)
    80003044:	6ca2                	ld	s9,8(sp)
}
    80003046:	8526                	mv	a0,s1
    80003048:	60e6                	ld	ra,88(sp)
    8000304a:	6446                	ld	s0,80(sp)
    8000304c:	64a6                	ld	s1,72(sp)
    8000304e:	6125                	addi	sp,sp,96
    80003050:	8082                	ret
    brelse(bp);
    80003052:	854a                	mv	a0,s2
    80003054:	e13ff0ef          	jal	80002e66 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003058:	015c87bb          	addw	a5,s9,s5
    8000305c:	00078a9b          	sext.w	s5,a5
    80003060:	004b2703          	lw	a4,4(s6)
    80003064:	04eaff63          	bgeu	s5,a4,800030c2 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003068:	41fad79b          	sraiw	a5,s5,0x1f
    8000306c:	0137d79b          	srliw	a5,a5,0x13
    80003070:	015787bb          	addw	a5,a5,s5
    80003074:	40d7d79b          	sraiw	a5,a5,0xd
    80003078:	01cb2583          	lw	a1,28(s6)
    8000307c:	9dbd                	addw	a1,a1,a5
    8000307e:	855e                	mv	a0,s7
    80003080:	cdfff0ef          	jal	80002d5e <bread>
    80003084:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003086:	004b2503          	lw	a0,4(s6)
    8000308a:	000a849b          	sext.w	s1,s5
    8000308e:	8762                	mv	a4,s8
    80003090:	fca4f1e3          	bgeu	s1,a0,80003052 <balloc+0x90>
      m = 1 << (bi % 8);
    80003094:	00777693          	andi	a3,a4,7
    80003098:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000309c:	41f7579b          	sraiw	a5,a4,0x1f
    800030a0:	01d7d79b          	srliw	a5,a5,0x1d
    800030a4:	9fb9                	addw	a5,a5,a4
    800030a6:	4037d79b          	sraiw	a5,a5,0x3
    800030aa:	00f90633          	add	a2,s2,a5
    800030ae:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    800030b2:	00c6f5b3          	and	a1,a3,a2
    800030b6:	d5a1                	beqz	a1,80002ffe <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030b8:	2705                	addiw	a4,a4,1
    800030ba:	2485                	addiw	s1,s1,1
    800030bc:	fd471ae3          	bne	a4,s4,80003090 <balloc+0xce>
    800030c0:	bf49                	j	80003052 <balloc+0x90>
    800030c2:	6906                	ld	s2,64(sp)
    800030c4:	79e2                	ld	s3,56(sp)
    800030c6:	7a42                	ld	s4,48(sp)
    800030c8:	7aa2                	ld	s5,40(sp)
    800030ca:	7b02                	ld	s6,32(sp)
    800030cc:	6be2                	ld	s7,24(sp)
    800030ce:	6c42                	ld	s8,16(sp)
    800030d0:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800030d2:	00004517          	auipc	a0,0x4
    800030d6:	30e50513          	addi	a0,a0,782 # 800073e0 <etext+0x3e0>
    800030da:	c20fd0ef          	jal	800004fa <printf>
  return 0;
    800030de:	4481                	li	s1,0
    800030e0:	b79d                	j	80003046 <balloc+0x84>

00000000800030e2 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800030e2:	7179                	addi	sp,sp,-48
    800030e4:	f406                	sd	ra,40(sp)
    800030e6:	f022                	sd	s0,32(sp)
    800030e8:	ec26                	sd	s1,24(sp)
    800030ea:	e84a                	sd	s2,16(sp)
    800030ec:	e44e                	sd	s3,8(sp)
    800030ee:	1800                	addi	s0,sp,48
    800030f0:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800030f2:	47ad                	li	a5,11
    800030f4:	02b7e663          	bltu	a5,a1,80003120 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    800030f8:	02059793          	slli	a5,a1,0x20
    800030fc:	01e7d593          	srli	a1,a5,0x1e
    80003100:	00b504b3          	add	s1,a0,a1
    80003104:	0504a903          	lw	s2,80(s1)
    80003108:	06091a63          	bnez	s2,8000317c <bmap+0x9a>
      addr = balloc(ip->dev);
    8000310c:	4108                	lw	a0,0(a0)
    8000310e:	eb5ff0ef          	jal	80002fc2 <balloc>
    80003112:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003116:	06090363          	beqz	s2,8000317c <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    8000311a:	0524a823          	sw	s2,80(s1)
    8000311e:	a8b9                	j	8000317c <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003120:	ff45849b          	addiw	s1,a1,-12
    80003124:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003128:	0ff00793          	li	a5,255
    8000312c:	06e7ee63          	bltu	a5,a4,800031a8 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003130:	08052903          	lw	s2,128(a0)
    80003134:	00091d63          	bnez	s2,8000314e <bmap+0x6c>
      addr = balloc(ip->dev);
    80003138:	4108                	lw	a0,0(a0)
    8000313a:	e89ff0ef          	jal	80002fc2 <balloc>
    8000313e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003142:	02090d63          	beqz	s2,8000317c <bmap+0x9a>
    80003146:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003148:	0929a023          	sw	s2,128(s3)
    8000314c:	a011                	j	80003150 <bmap+0x6e>
    8000314e:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003150:	85ca                	mv	a1,s2
    80003152:	0009a503          	lw	a0,0(s3)
    80003156:	c09ff0ef          	jal	80002d5e <bread>
    8000315a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000315c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003160:	02049713          	slli	a4,s1,0x20
    80003164:	01e75593          	srli	a1,a4,0x1e
    80003168:	00b784b3          	add	s1,a5,a1
    8000316c:	0004a903          	lw	s2,0(s1)
    80003170:	00090e63          	beqz	s2,8000318c <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003174:	8552                	mv	a0,s4
    80003176:	cf1ff0ef          	jal	80002e66 <brelse>
    return addr;
    8000317a:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000317c:	854a                	mv	a0,s2
    8000317e:	70a2                	ld	ra,40(sp)
    80003180:	7402                	ld	s0,32(sp)
    80003182:	64e2                	ld	s1,24(sp)
    80003184:	6942                	ld	s2,16(sp)
    80003186:	69a2                	ld	s3,8(sp)
    80003188:	6145                	addi	sp,sp,48
    8000318a:	8082                	ret
      addr = balloc(ip->dev);
    8000318c:	0009a503          	lw	a0,0(s3)
    80003190:	e33ff0ef          	jal	80002fc2 <balloc>
    80003194:	0005091b          	sext.w	s2,a0
      if(addr){
    80003198:	fc090ee3          	beqz	s2,80003174 <bmap+0x92>
        a[bn] = addr;
    8000319c:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800031a0:	8552                	mv	a0,s4
    800031a2:	5f7000ef          	jal	80003f98 <log_write>
    800031a6:	b7f9                	j	80003174 <bmap+0x92>
    800031a8:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800031aa:	00004517          	auipc	a0,0x4
    800031ae:	24e50513          	addi	a0,a0,590 # 800073f8 <etext+0x3f8>
    800031b2:	e2efd0ef          	jal	800007e0 <panic>

00000000800031b6 <iget>:
{
    800031b6:	7179                	addi	sp,sp,-48
    800031b8:	f406                	sd	ra,40(sp)
    800031ba:	f022                	sd	s0,32(sp)
    800031bc:	ec26                	sd	s1,24(sp)
    800031be:	e84a                	sd	s2,16(sp)
    800031c0:	e44e                	sd	s3,8(sp)
    800031c2:	e052                	sd	s4,0(sp)
    800031c4:	1800                	addi	s0,sp,48
    800031c6:	89aa                	mv	s3,a0
    800031c8:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800031ca:	0001b517          	auipc	a0,0x1b
    800031ce:	ed650513          	addi	a0,a0,-298 # 8001e0a0 <itable>
    800031d2:	9fdfd0ef          	jal	80000bce <acquire>
  empty = 0;
    800031d6:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800031d8:	0001b497          	auipc	s1,0x1b
    800031dc:	ee048493          	addi	s1,s1,-288 # 8001e0b8 <itable+0x18>
    800031e0:	0001d697          	auipc	a3,0x1d
    800031e4:	96868693          	addi	a3,a3,-1688 # 8001fb48 <log>
    800031e8:	a039                	j	800031f6 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800031ea:	02090963          	beqz	s2,8000321c <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800031ee:	08848493          	addi	s1,s1,136
    800031f2:	02d48863          	beq	s1,a3,80003222 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800031f6:	449c                	lw	a5,8(s1)
    800031f8:	fef059e3          	blez	a5,800031ea <iget+0x34>
    800031fc:	4098                	lw	a4,0(s1)
    800031fe:	ff3716e3          	bne	a4,s3,800031ea <iget+0x34>
    80003202:	40d8                	lw	a4,4(s1)
    80003204:	ff4713e3          	bne	a4,s4,800031ea <iget+0x34>
      ip->ref++;
    80003208:	2785                	addiw	a5,a5,1
    8000320a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000320c:	0001b517          	auipc	a0,0x1b
    80003210:	e9450513          	addi	a0,a0,-364 # 8001e0a0 <itable>
    80003214:	a53fd0ef          	jal	80000c66 <release>
      return ip;
    80003218:	8926                	mv	s2,s1
    8000321a:	a02d                	j	80003244 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000321c:	fbe9                	bnez	a5,800031ee <iget+0x38>
      empty = ip;
    8000321e:	8926                	mv	s2,s1
    80003220:	b7f9                	j	800031ee <iget+0x38>
  if(empty == 0)
    80003222:	02090a63          	beqz	s2,80003256 <iget+0xa0>
  ip->dev = dev;
    80003226:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000322a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000322e:	4785                	li	a5,1
    80003230:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003234:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003238:	0001b517          	auipc	a0,0x1b
    8000323c:	e6850513          	addi	a0,a0,-408 # 8001e0a0 <itable>
    80003240:	a27fd0ef          	jal	80000c66 <release>
}
    80003244:	854a                	mv	a0,s2
    80003246:	70a2                	ld	ra,40(sp)
    80003248:	7402                	ld	s0,32(sp)
    8000324a:	64e2                	ld	s1,24(sp)
    8000324c:	6942                	ld	s2,16(sp)
    8000324e:	69a2                	ld	s3,8(sp)
    80003250:	6a02                	ld	s4,0(sp)
    80003252:	6145                	addi	sp,sp,48
    80003254:	8082                	ret
    panic("iget: no inodes");
    80003256:	00004517          	auipc	a0,0x4
    8000325a:	1ba50513          	addi	a0,a0,442 # 80007410 <etext+0x410>
    8000325e:	d82fd0ef          	jal	800007e0 <panic>

0000000080003262 <iinit>:
{
    80003262:	7179                	addi	sp,sp,-48
    80003264:	f406                	sd	ra,40(sp)
    80003266:	f022                	sd	s0,32(sp)
    80003268:	ec26                	sd	s1,24(sp)
    8000326a:	e84a                	sd	s2,16(sp)
    8000326c:	e44e                	sd	s3,8(sp)
    8000326e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003270:	00004597          	auipc	a1,0x4
    80003274:	1b058593          	addi	a1,a1,432 # 80007420 <etext+0x420>
    80003278:	0001b517          	auipc	a0,0x1b
    8000327c:	e2850513          	addi	a0,a0,-472 # 8001e0a0 <itable>
    80003280:	8cffd0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003284:	0001b497          	auipc	s1,0x1b
    80003288:	e4448493          	addi	s1,s1,-444 # 8001e0c8 <itable+0x28>
    8000328c:	0001d997          	auipc	s3,0x1d
    80003290:	8cc98993          	addi	s3,s3,-1844 # 8001fb58 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003294:	00004917          	auipc	s2,0x4
    80003298:	19490913          	addi	s2,s2,404 # 80007428 <etext+0x428>
    8000329c:	85ca                	mv	a1,s2
    8000329e:	8526                	mv	a0,s1
    800032a0:	5bb000ef          	jal	8000405a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800032a4:	08848493          	addi	s1,s1,136
    800032a8:	ff349ae3          	bne	s1,s3,8000329c <iinit+0x3a>
}
    800032ac:	70a2                	ld	ra,40(sp)
    800032ae:	7402                	ld	s0,32(sp)
    800032b0:	64e2                	ld	s1,24(sp)
    800032b2:	6942                	ld	s2,16(sp)
    800032b4:	69a2                	ld	s3,8(sp)
    800032b6:	6145                	addi	sp,sp,48
    800032b8:	8082                	ret

00000000800032ba <ialloc>:
{
    800032ba:	7139                	addi	sp,sp,-64
    800032bc:	fc06                	sd	ra,56(sp)
    800032be:	f822                	sd	s0,48(sp)
    800032c0:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800032c2:	0001b717          	auipc	a4,0x1b
    800032c6:	dca72703          	lw	a4,-566(a4) # 8001e08c <sb+0xc>
    800032ca:	4785                	li	a5,1
    800032cc:	06e7f063          	bgeu	a5,a4,8000332c <ialloc+0x72>
    800032d0:	f426                	sd	s1,40(sp)
    800032d2:	f04a                	sd	s2,32(sp)
    800032d4:	ec4e                	sd	s3,24(sp)
    800032d6:	e852                	sd	s4,16(sp)
    800032d8:	e456                	sd	s5,8(sp)
    800032da:	e05a                	sd	s6,0(sp)
    800032dc:	8aaa                	mv	s5,a0
    800032de:	8b2e                	mv	s6,a1
    800032e0:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800032e2:	0001ba17          	auipc	s4,0x1b
    800032e6:	d9ea0a13          	addi	s4,s4,-610 # 8001e080 <sb>
    800032ea:	00495593          	srli	a1,s2,0x4
    800032ee:	018a2783          	lw	a5,24(s4)
    800032f2:	9dbd                	addw	a1,a1,a5
    800032f4:	8556                	mv	a0,s5
    800032f6:	a69ff0ef          	jal	80002d5e <bread>
    800032fa:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800032fc:	05850993          	addi	s3,a0,88
    80003300:	00f97793          	andi	a5,s2,15
    80003304:	079a                	slli	a5,a5,0x6
    80003306:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003308:	00099783          	lh	a5,0(s3)
    8000330c:	cb9d                	beqz	a5,80003342 <ialloc+0x88>
    brelse(bp);
    8000330e:	b59ff0ef          	jal	80002e66 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003312:	0905                	addi	s2,s2,1
    80003314:	00ca2703          	lw	a4,12(s4)
    80003318:	0009079b          	sext.w	a5,s2
    8000331c:	fce7e7e3          	bltu	a5,a4,800032ea <ialloc+0x30>
    80003320:	74a2                	ld	s1,40(sp)
    80003322:	7902                	ld	s2,32(sp)
    80003324:	69e2                	ld	s3,24(sp)
    80003326:	6a42                	ld	s4,16(sp)
    80003328:	6aa2                	ld	s5,8(sp)
    8000332a:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000332c:	00004517          	auipc	a0,0x4
    80003330:	10450513          	addi	a0,a0,260 # 80007430 <etext+0x430>
    80003334:	9c6fd0ef          	jal	800004fa <printf>
  return 0;
    80003338:	4501                	li	a0,0
}
    8000333a:	70e2                	ld	ra,56(sp)
    8000333c:	7442                	ld	s0,48(sp)
    8000333e:	6121                	addi	sp,sp,64
    80003340:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003342:	04000613          	li	a2,64
    80003346:	4581                	li	a1,0
    80003348:	854e                	mv	a0,s3
    8000334a:	959fd0ef          	jal	80000ca2 <memset>
      dip->type = type;
    8000334e:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003352:	8526                	mv	a0,s1
    80003354:	445000ef          	jal	80003f98 <log_write>
      brelse(bp);
    80003358:	8526                	mv	a0,s1
    8000335a:	b0dff0ef          	jal	80002e66 <brelse>
      return iget(dev, inum);
    8000335e:	0009059b          	sext.w	a1,s2
    80003362:	8556                	mv	a0,s5
    80003364:	e53ff0ef          	jal	800031b6 <iget>
    80003368:	74a2                	ld	s1,40(sp)
    8000336a:	7902                	ld	s2,32(sp)
    8000336c:	69e2                	ld	s3,24(sp)
    8000336e:	6a42                	ld	s4,16(sp)
    80003370:	6aa2                	ld	s5,8(sp)
    80003372:	6b02                	ld	s6,0(sp)
    80003374:	b7d9                	j	8000333a <ialloc+0x80>

0000000080003376 <iupdate>:
{
    80003376:	1101                	addi	sp,sp,-32
    80003378:	ec06                	sd	ra,24(sp)
    8000337a:	e822                	sd	s0,16(sp)
    8000337c:	e426                	sd	s1,8(sp)
    8000337e:	e04a                	sd	s2,0(sp)
    80003380:	1000                	addi	s0,sp,32
    80003382:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003384:	415c                	lw	a5,4(a0)
    80003386:	0047d79b          	srliw	a5,a5,0x4
    8000338a:	0001b597          	auipc	a1,0x1b
    8000338e:	d0e5a583          	lw	a1,-754(a1) # 8001e098 <sb+0x18>
    80003392:	9dbd                	addw	a1,a1,a5
    80003394:	4108                	lw	a0,0(a0)
    80003396:	9c9ff0ef          	jal	80002d5e <bread>
    8000339a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000339c:	05850793          	addi	a5,a0,88
    800033a0:	40d8                	lw	a4,4(s1)
    800033a2:	8b3d                	andi	a4,a4,15
    800033a4:	071a                	slli	a4,a4,0x6
    800033a6:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800033a8:	04449703          	lh	a4,68(s1)
    800033ac:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800033b0:	04649703          	lh	a4,70(s1)
    800033b4:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800033b8:	04849703          	lh	a4,72(s1)
    800033bc:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800033c0:	04a49703          	lh	a4,74(s1)
    800033c4:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800033c8:	44f8                	lw	a4,76(s1)
    800033ca:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800033cc:	03400613          	li	a2,52
    800033d0:	05048593          	addi	a1,s1,80
    800033d4:	00c78513          	addi	a0,a5,12
    800033d8:	927fd0ef          	jal	80000cfe <memmove>
  log_write(bp);
    800033dc:	854a                	mv	a0,s2
    800033de:	3bb000ef          	jal	80003f98 <log_write>
  brelse(bp);
    800033e2:	854a                	mv	a0,s2
    800033e4:	a83ff0ef          	jal	80002e66 <brelse>
}
    800033e8:	60e2                	ld	ra,24(sp)
    800033ea:	6442                	ld	s0,16(sp)
    800033ec:	64a2                	ld	s1,8(sp)
    800033ee:	6902                	ld	s2,0(sp)
    800033f0:	6105                	addi	sp,sp,32
    800033f2:	8082                	ret

00000000800033f4 <idup>:
{
    800033f4:	1101                	addi	sp,sp,-32
    800033f6:	ec06                	sd	ra,24(sp)
    800033f8:	e822                	sd	s0,16(sp)
    800033fa:	e426                	sd	s1,8(sp)
    800033fc:	1000                	addi	s0,sp,32
    800033fe:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003400:	0001b517          	auipc	a0,0x1b
    80003404:	ca050513          	addi	a0,a0,-864 # 8001e0a0 <itable>
    80003408:	fc6fd0ef          	jal	80000bce <acquire>
  ip->ref++;
    8000340c:	449c                	lw	a5,8(s1)
    8000340e:	2785                	addiw	a5,a5,1
    80003410:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003412:	0001b517          	auipc	a0,0x1b
    80003416:	c8e50513          	addi	a0,a0,-882 # 8001e0a0 <itable>
    8000341a:	84dfd0ef          	jal	80000c66 <release>
}
    8000341e:	8526                	mv	a0,s1
    80003420:	60e2                	ld	ra,24(sp)
    80003422:	6442                	ld	s0,16(sp)
    80003424:	64a2                	ld	s1,8(sp)
    80003426:	6105                	addi	sp,sp,32
    80003428:	8082                	ret

000000008000342a <ilock>:
{
    8000342a:	1101                	addi	sp,sp,-32
    8000342c:	ec06                	sd	ra,24(sp)
    8000342e:	e822                	sd	s0,16(sp)
    80003430:	e426                	sd	s1,8(sp)
    80003432:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003434:	cd19                	beqz	a0,80003452 <ilock+0x28>
    80003436:	84aa                	mv	s1,a0
    80003438:	451c                	lw	a5,8(a0)
    8000343a:	00f05c63          	blez	a5,80003452 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000343e:	0541                	addi	a0,a0,16
    80003440:	451000ef          	jal	80004090 <acquiresleep>
  if(ip->valid == 0){
    80003444:	40bc                	lw	a5,64(s1)
    80003446:	cf89                	beqz	a5,80003460 <ilock+0x36>
}
    80003448:	60e2                	ld	ra,24(sp)
    8000344a:	6442                	ld	s0,16(sp)
    8000344c:	64a2                	ld	s1,8(sp)
    8000344e:	6105                	addi	sp,sp,32
    80003450:	8082                	ret
    80003452:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003454:	00004517          	auipc	a0,0x4
    80003458:	ff450513          	addi	a0,a0,-12 # 80007448 <etext+0x448>
    8000345c:	b84fd0ef          	jal	800007e0 <panic>
    80003460:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003462:	40dc                	lw	a5,4(s1)
    80003464:	0047d79b          	srliw	a5,a5,0x4
    80003468:	0001b597          	auipc	a1,0x1b
    8000346c:	c305a583          	lw	a1,-976(a1) # 8001e098 <sb+0x18>
    80003470:	9dbd                	addw	a1,a1,a5
    80003472:	4088                	lw	a0,0(s1)
    80003474:	8ebff0ef          	jal	80002d5e <bread>
    80003478:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000347a:	05850593          	addi	a1,a0,88
    8000347e:	40dc                	lw	a5,4(s1)
    80003480:	8bbd                	andi	a5,a5,15
    80003482:	079a                	slli	a5,a5,0x6
    80003484:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003486:	00059783          	lh	a5,0(a1)
    8000348a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000348e:	00259783          	lh	a5,2(a1)
    80003492:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003496:	00459783          	lh	a5,4(a1)
    8000349a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000349e:	00659783          	lh	a5,6(a1)
    800034a2:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800034a6:	459c                	lw	a5,8(a1)
    800034a8:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800034aa:	03400613          	li	a2,52
    800034ae:	05b1                	addi	a1,a1,12
    800034b0:	05048513          	addi	a0,s1,80
    800034b4:	84bfd0ef          	jal	80000cfe <memmove>
    brelse(bp);
    800034b8:	854a                	mv	a0,s2
    800034ba:	9adff0ef          	jal	80002e66 <brelse>
    ip->valid = 1;
    800034be:	4785                	li	a5,1
    800034c0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800034c2:	04449783          	lh	a5,68(s1)
    800034c6:	c399                	beqz	a5,800034cc <ilock+0xa2>
    800034c8:	6902                	ld	s2,0(sp)
    800034ca:	bfbd                	j	80003448 <ilock+0x1e>
      panic("ilock: no type");
    800034cc:	00004517          	auipc	a0,0x4
    800034d0:	f8450513          	addi	a0,a0,-124 # 80007450 <etext+0x450>
    800034d4:	b0cfd0ef          	jal	800007e0 <panic>

00000000800034d8 <iunlock>:
{
    800034d8:	1101                	addi	sp,sp,-32
    800034da:	ec06                	sd	ra,24(sp)
    800034dc:	e822                	sd	s0,16(sp)
    800034de:	e426                	sd	s1,8(sp)
    800034e0:	e04a                	sd	s2,0(sp)
    800034e2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800034e4:	c505                	beqz	a0,8000350c <iunlock+0x34>
    800034e6:	84aa                	mv	s1,a0
    800034e8:	01050913          	addi	s2,a0,16
    800034ec:	854a                	mv	a0,s2
    800034ee:	421000ef          	jal	8000410e <holdingsleep>
    800034f2:	cd09                	beqz	a0,8000350c <iunlock+0x34>
    800034f4:	449c                	lw	a5,8(s1)
    800034f6:	00f05b63          	blez	a5,8000350c <iunlock+0x34>
  releasesleep(&ip->lock);
    800034fa:	854a                	mv	a0,s2
    800034fc:	3db000ef          	jal	800040d6 <releasesleep>
}
    80003500:	60e2                	ld	ra,24(sp)
    80003502:	6442                	ld	s0,16(sp)
    80003504:	64a2                	ld	s1,8(sp)
    80003506:	6902                	ld	s2,0(sp)
    80003508:	6105                	addi	sp,sp,32
    8000350a:	8082                	ret
    panic("iunlock");
    8000350c:	00004517          	auipc	a0,0x4
    80003510:	f5450513          	addi	a0,a0,-172 # 80007460 <etext+0x460>
    80003514:	accfd0ef          	jal	800007e0 <panic>

0000000080003518 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003518:	7179                	addi	sp,sp,-48
    8000351a:	f406                	sd	ra,40(sp)
    8000351c:	f022                	sd	s0,32(sp)
    8000351e:	ec26                	sd	s1,24(sp)
    80003520:	e84a                	sd	s2,16(sp)
    80003522:	e44e                	sd	s3,8(sp)
    80003524:	1800                	addi	s0,sp,48
    80003526:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003528:	05050493          	addi	s1,a0,80
    8000352c:	08050913          	addi	s2,a0,128
    80003530:	a021                	j	80003538 <itrunc+0x20>
    80003532:	0491                	addi	s1,s1,4
    80003534:	01248b63          	beq	s1,s2,8000354a <itrunc+0x32>
    if(ip->addrs[i]){
    80003538:	408c                	lw	a1,0(s1)
    8000353a:	dde5                	beqz	a1,80003532 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000353c:	0009a503          	lw	a0,0(s3)
    80003540:	a17ff0ef          	jal	80002f56 <bfree>
      ip->addrs[i] = 0;
    80003544:	0004a023          	sw	zero,0(s1)
    80003548:	b7ed                	j	80003532 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000354a:	0809a583          	lw	a1,128(s3)
    8000354e:	ed89                	bnez	a1,80003568 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003550:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003554:	854e                	mv	a0,s3
    80003556:	e21ff0ef          	jal	80003376 <iupdate>
}
    8000355a:	70a2                	ld	ra,40(sp)
    8000355c:	7402                	ld	s0,32(sp)
    8000355e:	64e2                	ld	s1,24(sp)
    80003560:	6942                	ld	s2,16(sp)
    80003562:	69a2                	ld	s3,8(sp)
    80003564:	6145                	addi	sp,sp,48
    80003566:	8082                	ret
    80003568:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000356a:	0009a503          	lw	a0,0(s3)
    8000356e:	ff0ff0ef          	jal	80002d5e <bread>
    80003572:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003574:	05850493          	addi	s1,a0,88
    80003578:	45850913          	addi	s2,a0,1112
    8000357c:	a021                	j	80003584 <itrunc+0x6c>
    8000357e:	0491                	addi	s1,s1,4
    80003580:	01248963          	beq	s1,s2,80003592 <itrunc+0x7a>
      if(a[j])
    80003584:	408c                	lw	a1,0(s1)
    80003586:	dde5                	beqz	a1,8000357e <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003588:	0009a503          	lw	a0,0(s3)
    8000358c:	9cbff0ef          	jal	80002f56 <bfree>
    80003590:	b7fd                	j	8000357e <itrunc+0x66>
    brelse(bp);
    80003592:	8552                	mv	a0,s4
    80003594:	8d3ff0ef          	jal	80002e66 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003598:	0809a583          	lw	a1,128(s3)
    8000359c:	0009a503          	lw	a0,0(s3)
    800035a0:	9b7ff0ef          	jal	80002f56 <bfree>
    ip->addrs[NDIRECT] = 0;
    800035a4:	0809a023          	sw	zero,128(s3)
    800035a8:	6a02                	ld	s4,0(sp)
    800035aa:	b75d                	j	80003550 <itrunc+0x38>

00000000800035ac <iput>:
{
    800035ac:	1101                	addi	sp,sp,-32
    800035ae:	ec06                	sd	ra,24(sp)
    800035b0:	e822                	sd	s0,16(sp)
    800035b2:	e426                	sd	s1,8(sp)
    800035b4:	1000                	addi	s0,sp,32
    800035b6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800035b8:	0001b517          	auipc	a0,0x1b
    800035bc:	ae850513          	addi	a0,a0,-1304 # 8001e0a0 <itable>
    800035c0:	e0efd0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800035c4:	4498                	lw	a4,8(s1)
    800035c6:	4785                	li	a5,1
    800035c8:	02f70063          	beq	a4,a5,800035e8 <iput+0x3c>
  ip->ref--;
    800035cc:	449c                	lw	a5,8(s1)
    800035ce:	37fd                	addiw	a5,a5,-1
    800035d0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035d2:	0001b517          	auipc	a0,0x1b
    800035d6:	ace50513          	addi	a0,a0,-1330 # 8001e0a0 <itable>
    800035da:	e8cfd0ef          	jal	80000c66 <release>
}
    800035de:	60e2                	ld	ra,24(sp)
    800035e0:	6442                	ld	s0,16(sp)
    800035e2:	64a2                	ld	s1,8(sp)
    800035e4:	6105                	addi	sp,sp,32
    800035e6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800035e8:	40bc                	lw	a5,64(s1)
    800035ea:	d3ed                	beqz	a5,800035cc <iput+0x20>
    800035ec:	04a49783          	lh	a5,74(s1)
    800035f0:	fff1                	bnez	a5,800035cc <iput+0x20>
    800035f2:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800035f4:	01048913          	addi	s2,s1,16
    800035f8:	854a                	mv	a0,s2
    800035fa:	297000ef          	jal	80004090 <acquiresleep>
    release(&itable.lock);
    800035fe:	0001b517          	auipc	a0,0x1b
    80003602:	aa250513          	addi	a0,a0,-1374 # 8001e0a0 <itable>
    80003606:	e60fd0ef          	jal	80000c66 <release>
    itrunc(ip);
    8000360a:	8526                	mv	a0,s1
    8000360c:	f0dff0ef          	jal	80003518 <itrunc>
    ip->type = 0;
    80003610:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003614:	8526                	mv	a0,s1
    80003616:	d61ff0ef          	jal	80003376 <iupdate>
    ip->valid = 0;
    8000361a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000361e:	854a                	mv	a0,s2
    80003620:	2b7000ef          	jal	800040d6 <releasesleep>
    acquire(&itable.lock);
    80003624:	0001b517          	auipc	a0,0x1b
    80003628:	a7c50513          	addi	a0,a0,-1412 # 8001e0a0 <itable>
    8000362c:	da2fd0ef          	jal	80000bce <acquire>
    80003630:	6902                	ld	s2,0(sp)
    80003632:	bf69                	j	800035cc <iput+0x20>

0000000080003634 <iunlockput>:
{
    80003634:	1101                	addi	sp,sp,-32
    80003636:	ec06                	sd	ra,24(sp)
    80003638:	e822                	sd	s0,16(sp)
    8000363a:	e426                	sd	s1,8(sp)
    8000363c:	1000                	addi	s0,sp,32
    8000363e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003640:	e99ff0ef          	jal	800034d8 <iunlock>
  iput(ip);
    80003644:	8526                	mv	a0,s1
    80003646:	f67ff0ef          	jal	800035ac <iput>
}
    8000364a:	60e2                	ld	ra,24(sp)
    8000364c:	6442                	ld	s0,16(sp)
    8000364e:	64a2                	ld	s1,8(sp)
    80003650:	6105                	addi	sp,sp,32
    80003652:	8082                	ret

0000000080003654 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003654:	0001b717          	auipc	a4,0x1b
    80003658:	a3872703          	lw	a4,-1480(a4) # 8001e08c <sb+0xc>
    8000365c:	4785                	li	a5,1
    8000365e:	0ae7ff63          	bgeu	a5,a4,8000371c <ireclaim+0xc8>
{
    80003662:	7139                	addi	sp,sp,-64
    80003664:	fc06                	sd	ra,56(sp)
    80003666:	f822                	sd	s0,48(sp)
    80003668:	f426                	sd	s1,40(sp)
    8000366a:	f04a                	sd	s2,32(sp)
    8000366c:	ec4e                	sd	s3,24(sp)
    8000366e:	e852                	sd	s4,16(sp)
    80003670:	e456                	sd	s5,8(sp)
    80003672:	e05a                	sd	s6,0(sp)
    80003674:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003676:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003678:	00050a1b          	sext.w	s4,a0
    8000367c:	0001ba97          	auipc	s5,0x1b
    80003680:	a04a8a93          	addi	s5,s5,-1532 # 8001e080 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003684:	00004b17          	auipc	s6,0x4
    80003688:	de4b0b13          	addi	s6,s6,-540 # 80007468 <etext+0x468>
    8000368c:	a099                	j	800036d2 <ireclaim+0x7e>
    8000368e:	85ce                	mv	a1,s3
    80003690:	855a                	mv	a0,s6
    80003692:	e69fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003696:	85ce                	mv	a1,s3
    80003698:	8552                	mv	a0,s4
    8000369a:	b1dff0ef          	jal	800031b6 <iget>
    8000369e:	89aa                	mv	s3,a0
    brelse(bp);
    800036a0:	854a                	mv	a0,s2
    800036a2:	fc4ff0ef          	jal	80002e66 <brelse>
    if (ip) {
    800036a6:	00098f63          	beqz	s3,800036c4 <ireclaim+0x70>
      begin_op();
    800036aa:	76a000ef          	jal	80003e14 <begin_op>
      ilock(ip);
    800036ae:	854e                	mv	a0,s3
    800036b0:	d7bff0ef          	jal	8000342a <ilock>
      iunlock(ip);
    800036b4:	854e                	mv	a0,s3
    800036b6:	e23ff0ef          	jal	800034d8 <iunlock>
      iput(ip);
    800036ba:	854e                	mv	a0,s3
    800036bc:	ef1ff0ef          	jal	800035ac <iput>
      end_op();
    800036c0:	7be000ef          	jal	80003e7e <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036c4:	0485                	addi	s1,s1,1
    800036c6:	00caa703          	lw	a4,12(s5)
    800036ca:	0004879b          	sext.w	a5,s1
    800036ce:	02e7fd63          	bgeu	a5,a4,80003708 <ireclaim+0xb4>
    800036d2:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800036d6:	0044d593          	srli	a1,s1,0x4
    800036da:	018aa783          	lw	a5,24(s5)
    800036de:	9dbd                	addw	a1,a1,a5
    800036e0:	8552                	mv	a0,s4
    800036e2:	e7cff0ef          	jal	80002d5e <bread>
    800036e6:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800036e8:	05850793          	addi	a5,a0,88
    800036ec:	00f9f713          	andi	a4,s3,15
    800036f0:	071a                	slli	a4,a4,0x6
    800036f2:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800036f4:	00079703          	lh	a4,0(a5)
    800036f8:	c701                	beqz	a4,80003700 <ireclaim+0xac>
    800036fa:	00679783          	lh	a5,6(a5)
    800036fe:	dbc1                	beqz	a5,8000368e <ireclaim+0x3a>
    brelse(bp);
    80003700:	854a                	mv	a0,s2
    80003702:	f64ff0ef          	jal	80002e66 <brelse>
    if (ip) {
    80003706:	bf7d                	j	800036c4 <ireclaim+0x70>
}
    80003708:	70e2                	ld	ra,56(sp)
    8000370a:	7442                	ld	s0,48(sp)
    8000370c:	74a2                	ld	s1,40(sp)
    8000370e:	7902                	ld	s2,32(sp)
    80003710:	69e2                	ld	s3,24(sp)
    80003712:	6a42                	ld	s4,16(sp)
    80003714:	6aa2                	ld	s5,8(sp)
    80003716:	6b02                	ld	s6,0(sp)
    80003718:	6121                	addi	sp,sp,64
    8000371a:	8082                	ret
    8000371c:	8082                	ret

000000008000371e <fsinit>:
fsinit(int dev) {
    8000371e:	7179                	addi	sp,sp,-48
    80003720:	f406                	sd	ra,40(sp)
    80003722:	f022                	sd	s0,32(sp)
    80003724:	ec26                	sd	s1,24(sp)
    80003726:	e84a                	sd	s2,16(sp)
    80003728:	e44e                	sd	s3,8(sp)
    8000372a:	1800                	addi	s0,sp,48
    8000372c:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    8000372e:	4585                	li	a1,1
    80003730:	e2eff0ef          	jal	80002d5e <bread>
    80003734:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003736:	0001b997          	auipc	s3,0x1b
    8000373a:	94a98993          	addi	s3,s3,-1718 # 8001e080 <sb>
    8000373e:	02000613          	li	a2,32
    80003742:	05850593          	addi	a1,a0,88
    80003746:	854e                	mv	a0,s3
    80003748:	db6fd0ef          	jal	80000cfe <memmove>
  brelse(bp);
    8000374c:	854a                	mv	a0,s2
    8000374e:	f18ff0ef          	jal	80002e66 <brelse>
  if(sb.magic != FSMAGIC)
    80003752:	0009a703          	lw	a4,0(s3)
    80003756:	102037b7          	lui	a5,0x10203
    8000375a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000375e:	02f71363          	bne	a4,a5,80003784 <fsinit+0x66>
  initlog(dev, &sb);
    80003762:	0001b597          	auipc	a1,0x1b
    80003766:	91e58593          	addi	a1,a1,-1762 # 8001e080 <sb>
    8000376a:	8526                	mv	a0,s1
    8000376c:	62a000ef          	jal	80003d96 <initlog>
  ireclaim(dev);
    80003770:	8526                	mv	a0,s1
    80003772:	ee3ff0ef          	jal	80003654 <ireclaim>
}
    80003776:	70a2                	ld	ra,40(sp)
    80003778:	7402                	ld	s0,32(sp)
    8000377a:	64e2                	ld	s1,24(sp)
    8000377c:	6942                	ld	s2,16(sp)
    8000377e:	69a2                	ld	s3,8(sp)
    80003780:	6145                	addi	sp,sp,48
    80003782:	8082                	ret
    panic("invalid file system");
    80003784:	00004517          	auipc	a0,0x4
    80003788:	d0450513          	addi	a0,a0,-764 # 80007488 <etext+0x488>
    8000378c:	854fd0ef          	jal	800007e0 <panic>

0000000080003790 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003790:	1141                	addi	sp,sp,-16
    80003792:	e422                	sd	s0,8(sp)
    80003794:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003796:	411c                	lw	a5,0(a0)
    80003798:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000379a:	415c                	lw	a5,4(a0)
    8000379c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000379e:	04451783          	lh	a5,68(a0)
    800037a2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800037a6:	04a51783          	lh	a5,74(a0)
    800037aa:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800037ae:	04c56783          	lwu	a5,76(a0)
    800037b2:	e99c                	sd	a5,16(a1)
}
    800037b4:	6422                	ld	s0,8(sp)
    800037b6:	0141                	addi	sp,sp,16
    800037b8:	8082                	ret

00000000800037ba <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800037ba:	457c                	lw	a5,76(a0)
    800037bc:	0ed7eb63          	bltu	a5,a3,800038b2 <readi+0xf8>
{
    800037c0:	7159                	addi	sp,sp,-112
    800037c2:	f486                	sd	ra,104(sp)
    800037c4:	f0a2                	sd	s0,96(sp)
    800037c6:	eca6                	sd	s1,88(sp)
    800037c8:	e0d2                	sd	s4,64(sp)
    800037ca:	fc56                	sd	s5,56(sp)
    800037cc:	f85a                	sd	s6,48(sp)
    800037ce:	f45e                	sd	s7,40(sp)
    800037d0:	1880                	addi	s0,sp,112
    800037d2:	8b2a                	mv	s6,a0
    800037d4:	8bae                	mv	s7,a1
    800037d6:	8a32                	mv	s4,a2
    800037d8:	84b6                	mv	s1,a3
    800037da:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800037dc:	9f35                	addw	a4,a4,a3
    return 0;
    800037de:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800037e0:	0cd76063          	bltu	a4,a3,800038a0 <readi+0xe6>
    800037e4:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800037e6:	00e7f463          	bgeu	a5,a4,800037ee <readi+0x34>
    n = ip->size - off;
    800037ea:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037ee:	080a8f63          	beqz	s5,8000388c <readi+0xd2>
    800037f2:	e8ca                	sd	s2,80(sp)
    800037f4:	f062                	sd	s8,32(sp)
    800037f6:	ec66                	sd	s9,24(sp)
    800037f8:	e86a                	sd	s10,16(sp)
    800037fa:	e46e                	sd	s11,8(sp)
    800037fc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800037fe:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003802:	5c7d                	li	s8,-1
    80003804:	a80d                	j	80003836 <readi+0x7c>
    80003806:	020d1d93          	slli	s11,s10,0x20
    8000380a:	020ddd93          	srli	s11,s11,0x20
    8000380e:	05890613          	addi	a2,s2,88
    80003812:	86ee                	mv	a3,s11
    80003814:	963a                	add	a2,a2,a4
    80003816:	85d2                	mv	a1,s4
    80003818:	855e                	mv	a0,s7
    8000381a:	a1bfe0ef          	jal	80002234 <either_copyout>
    8000381e:	05850763          	beq	a0,s8,8000386c <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003822:	854a                	mv	a0,s2
    80003824:	e42ff0ef          	jal	80002e66 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003828:	013d09bb          	addw	s3,s10,s3
    8000382c:	009d04bb          	addw	s1,s10,s1
    80003830:	9a6e                	add	s4,s4,s11
    80003832:	0559f763          	bgeu	s3,s5,80003880 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003836:	00a4d59b          	srliw	a1,s1,0xa
    8000383a:	855a                	mv	a0,s6
    8000383c:	8a7ff0ef          	jal	800030e2 <bmap>
    80003840:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003844:	c5b1                	beqz	a1,80003890 <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003846:	000b2503          	lw	a0,0(s6)
    8000384a:	d14ff0ef          	jal	80002d5e <bread>
    8000384e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003850:	3ff4f713          	andi	a4,s1,1023
    80003854:	40ec87bb          	subw	a5,s9,a4
    80003858:	413a86bb          	subw	a3,s5,s3
    8000385c:	8d3e                	mv	s10,a5
    8000385e:	2781                	sext.w	a5,a5
    80003860:	0006861b          	sext.w	a2,a3
    80003864:	faf671e3          	bgeu	a2,a5,80003806 <readi+0x4c>
    80003868:	8d36                	mv	s10,a3
    8000386a:	bf71                	j	80003806 <readi+0x4c>
      brelse(bp);
    8000386c:	854a                	mv	a0,s2
    8000386e:	df8ff0ef          	jal	80002e66 <brelse>
      tot = -1;
    80003872:	59fd                	li	s3,-1
      break;
    80003874:	6946                	ld	s2,80(sp)
    80003876:	7c02                	ld	s8,32(sp)
    80003878:	6ce2                	ld	s9,24(sp)
    8000387a:	6d42                	ld	s10,16(sp)
    8000387c:	6da2                	ld	s11,8(sp)
    8000387e:	a831                	j	8000389a <readi+0xe0>
    80003880:	6946                	ld	s2,80(sp)
    80003882:	7c02                	ld	s8,32(sp)
    80003884:	6ce2                	ld	s9,24(sp)
    80003886:	6d42                	ld	s10,16(sp)
    80003888:	6da2                	ld	s11,8(sp)
    8000388a:	a801                	j	8000389a <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000388c:	89d6                	mv	s3,s5
    8000388e:	a031                	j	8000389a <readi+0xe0>
    80003890:	6946                	ld	s2,80(sp)
    80003892:	7c02                	ld	s8,32(sp)
    80003894:	6ce2                	ld	s9,24(sp)
    80003896:	6d42                	ld	s10,16(sp)
    80003898:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000389a:	0009851b          	sext.w	a0,s3
    8000389e:	69a6                	ld	s3,72(sp)
}
    800038a0:	70a6                	ld	ra,104(sp)
    800038a2:	7406                	ld	s0,96(sp)
    800038a4:	64e6                	ld	s1,88(sp)
    800038a6:	6a06                	ld	s4,64(sp)
    800038a8:	7ae2                	ld	s5,56(sp)
    800038aa:	7b42                	ld	s6,48(sp)
    800038ac:	7ba2                	ld	s7,40(sp)
    800038ae:	6165                	addi	sp,sp,112
    800038b0:	8082                	ret
    return 0;
    800038b2:	4501                	li	a0,0
}
    800038b4:	8082                	ret

00000000800038b6 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800038b6:	457c                	lw	a5,76(a0)
    800038b8:	10d7e063          	bltu	a5,a3,800039b8 <writei+0x102>
{
    800038bc:	7159                	addi	sp,sp,-112
    800038be:	f486                	sd	ra,104(sp)
    800038c0:	f0a2                	sd	s0,96(sp)
    800038c2:	e8ca                	sd	s2,80(sp)
    800038c4:	e0d2                	sd	s4,64(sp)
    800038c6:	fc56                	sd	s5,56(sp)
    800038c8:	f85a                	sd	s6,48(sp)
    800038ca:	f45e                	sd	s7,40(sp)
    800038cc:	1880                	addi	s0,sp,112
    800038ce:	8aaa                	mv	s5,a0
    800038d0:	8bae                	mv	s7,a1
    800038d2:	8a32                	mv	s4,a2
    800038d4:	8936                	mv	s2,a3
    800038d6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800038d8:	00e687bb          	addw	a5,a3,a4
    800038dc:	0ed7e063          	bltu	a5,a3,800039bc <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800038e0:	00043737          	lui	a4,0x43
    800038e4:	0cf76e63          	bltu	a4,a5,800039c0 <writei+0x10a>
    800038e8:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800038ea:	0a0b0f63          	beqz	s6,800039a8 <writei+0xf2>
    800038ee:	eca6                	sd	s1,88(sp)
    800038f0:	f062                	sd	s8,32(sp)
    800038f2:	ec66                	sd	s9,24(sp)
    800038f4:	e86a                	sd	s10,16(sp)
    800038f6:	e46e                	sd	s11,8(sp)
    800038f8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800038fa:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800038fe:	5c7d                	li	s8,-1
    80003900:	a825                	j	80003938 <writei+0x82>
    80003902:	020d1d93          	slli	s11,s10,0x20
    80003906:	020ddd93          	srli	s11,s11,0x20
    8000390a:	05848513          	addi	a0,s1,88
    8000390e:	86ee                	mv	a3,s11
    80003910:	8652                	mv	a2,s4
    80003912:	85de                	mv	a1,s7
    80003914:	953a                	add	a0,a0,a4
    80003916:	969fe0ef          	jal	8000227e <either_copyin>
    8000391a:	05850a63          	beq	a0,s8,8000396e <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000391e:	8526                	mv	a0,s1
    80003920:	678000ef          	jal	80003f98 <log_write>
    brelse(bp);
    80003924:	8526                	mv	a0,s1
    80003926:	d40ff0ef          	jal	80002e66 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000392a:	013d09bb          	addw	s3,s10,s3
    8000392e:	012d093b          	addw	s2,s10,s2
    80003932:	9a6e                	add	s4,s4,s11
    80003934:	0569f063          	bgeu	s3,s6,80003974 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003938:	00a9559b          	srliw	a1,s2,0xa
    8000393c:	8556                	mv	a0,s5
    8000393e:	fa4ff0ef          	jal	800030e2 <bmap>
    80003942:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003946:	c59d                	beqz	a1,80003974 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003948:	000aa503          	lw	a0,0(s5)
    8000394c:	c12ff0ef          	jal	80002d5e <bread>
    80003950:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003952:	3ff97713          	andi	a4,s2,1023
    80003956:	40ec87bb          	subw	a5,s9,a4
    8000395a:	413b06bb          	subw	a3,s6,s3
    8000395e:	8d3e                	mv	s10,a5
    80003960:	2781                	sext.w	a5,a5
    80003962:	0006861b          	sext.w	a2,a3
    80003966:	f8f67ee3          	bgeu	a2,a5,80003902 <writei+0x4c>
    8000396a:	8d36                	mv	s10,a3
    8000396c:	bf59                	j	80003902 <writei+0x4c>
      brelse(bp);
    8000396e:	8526                	mv	a0,s1
    80003970:	cf6ff0ef          	jal	80002e66 <brelse>
  }

  if(off > ip->size)
    80003974:	04caa783          	lw	a5,76(s5)
    80003978:	0327fa63          	bgeu	a5,s2,800039ac <writei+0xf6>
    ip->size = off;
    8000397c:	052aa623          	sw	s2,76(s5)
    80003980:	64e6                	ld	s1,88(sp)
    80003982:	7c02                	ld	s8,32(sp)
    80003984:	6ce2                	ld	s9,24(sp)
    80003986:	6d42                	ld	s10,16(sp)
    80003988:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000398a:	8556                	mv	a0,s5
    8000398c:	9ebff0ef          	jal	80003376 <iupdate>

  return tot;
    80003990:	0009851b          	sext.w	a0,s3
    80003994:	69a6                	ld	s3,72(sp)
}
    80003996:	70a6                	ld	ra,104(sp)
    80003998:	7406                	ld	s0,96(sp)
    8000399a:	6946                	ld	s2,80(sp)
    8000399c:	6a06                	ld	s4,64(sp)
    8000399e:	7ae2                	ld	s5,56(sp)
    800039a0:	7b42                	ld	s6,48(sp)
    800039a2:	7ba2                	ld	s7,40(sp)
    800039a4:	6165                	addi	sp,sp,112
    800039a6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039a8:	89da                	mv	s3,s6
    800039aa:	b7c5                	j	8000398a <writei+0xd4>
    800039ac:	64e6                	ld	s1,88(sp)
    800039ae:	7c02                	ld	s8,32(sp)
    800039b0:	6ce2                	ld	s9,24(sp)
    800039b2:	6d42                	ld	s10,16(sp)
    800039b4:	6da2                	ld	s11,8(sp)
    800039b6:	bfd1                	j	8000398a <writei+0xd4>
    return -1;
    800039b8:	557d                	li	a0,-1
}
    800039ba:	8082                	ret
    return -1;
    800039bc:	557d                	li	a0,-1
    800039be:	bfe1                	j	80003996 <writei+0xe0>
    return -1;
    800039c0:	557d                	li	a0,-1
    800039c2:	bfd1                	j	80003996 <writei+0xe0>

00000000800039c4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800039c4:	1141                	addi	sp,sp,-16
    800039c6:	e406                	sd	ra,8(sp)
    800039c8:	e022                	sd	s0,0(sp)
    800039ca:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800039cc:	4639                	li	a2,14
    800039ce:	ba0fd0ef          	jal	80000d6e <strncmp>
}
    800039d2:	60a2                	ld	ra,8(sp)
    800039d4:	6402                	ld	s0,0(sp)
    800039d6:	0141                	addi	sp,sp,16
    800039d8:	8082                	ret

00000000800039da <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800039da:	7139                	addi	sp,sp,-64
    800039dc:	fc06                	sd	ra,56(sp)
    800039de:	f822                	sd	s0,48(sp)
    800039e0:	f426                	sd	s1,40(sp)
    800039e2:	f04a                	sd	s2,32(sp)
    800039e4:	ec4e                	sd	s3,24(sp)
    800039e6:	e852                	sd	s4,16(sp)
    800039e8:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800039ea:	04451703          	lh	a4,68(a0)
    800039ee:	4785                	li	a5,1
    800039f0:	00f71a63          	bne	a4,a5,80003a04 <dirlookup+0x2a>
    800039f4:	892a                	mv	s2,a0
    800039f6:	89ae                	mv	s3,a1
    800039f8:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800039fa:	457c                	lw	a5,76(a0)
    800039fc:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800039fe:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a00:	e39d                	bnez	a5,80003a26 <dirlookup+0x4c>
    80003a02:	a095                	j	80003a66 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003a04:	00004517          	auipc	a0,0x4
    80003a08:	a9c50513          	addi	a0,a0,-1380 # 800074a0 <etext+0x4a0>
    80003a0c:	dd5fc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    80003a10:	00004517          	auipc	a0,0x4
    80003a14:	aa850513          	addi	a0,a0,-1368 # 800074b8 <etext+0x4b8>
    80003a18:	dc9fc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a1c:	24c1                	addiw	s1,s1,16
    80003a1e:	04c92783          	lw	a5,76(s2)
    80003a22:	04f4f163          	bgeu	s1,a5,80003a64 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a26:	4741                	li	a4,16
    80003a28:	86a6                	mv	a3,s1
    80003a2a:	fc040613          	addi	a2,s0,-64
    80003a2e:	4581                	li	a1,0
    80003a30:	854a                	mv	a0,s2
    80003a32:	d89ff0ef          	jal	800037ba <readi>
    80003a36:	47c1                	li	a5,16
    80003a38:	fcf51ce3          	bne	a0,a5,80003a10 <dirlookup+0x36>
    if(de.inum == 0)
    80003a3c:	fc045783          	lhu	a5,-64(s0)
    80003a40:	dff1                	beqz	a5,80003a1c <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003a42:	fc240593          	addi	a1,s0,-62
    80003a46:	854e                	mv	a0,s3
    80003a48:	f7dff0ef          	jal	800039c4 <namecmp>
    80003a4c:	f961                	bnez	a0,80003a1c <dirlookup+0x42>
      if(poff)
    80003a4e:	000a0463          	beqz	s4,80003a56 <dirlookup+0x7c>
        *poff = off;
    80003a52:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003a56:	fc045583          	lhu	a1,-64(s0)
    80003a5a:	00092503          	lw	a0,0(s2)
    80003a5e:	f58ff0ef          	jal	800031b6 <iget>
    80003a62:	a011                	j	80003a66 <dirlookup+0x8c>
  return 0;
    80003a64:	4501                	li	a0,0
}
    80003a66:	70e2                	ld	ra,56(sp)
    80003a68:	7442                	ld	s0,48(sp)
    80003a6a:	74a2                	ld	s1,40(sp)
    80003a6c:	7902                	ld	s2,32(sp)
    80003a6e:	69e2                	ld	s3,24(sp)
    80003a70:	6a42                	ld	s4,16(sp)
    80003a72:	6121                	addi	sp,sp,64
    80003a74:	8082                	ret

0000000080003a76 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003a76:	711d                	addi	sp,sp,-96
    80003a78:	ec86                	sd	ra,88(sp)
    80003a7a:	e8a2                	sd	s0,80(sp)
    80003a7c:	e4a6                	sd	s1,72(sp)
    80003a7e:	e0ca                	sd	s2,64(sp)
    80003a80:	fc4e                	sd	s3,56(sp)
    80003a82:	f852                	sd	s4,48(sp)
    80003a84:	f456                	sd	s5,40(sp)
    80003a86:	f05a                	sd	s6,32(sp)
    80003a88:	ec5e                	sd	s7,24(sp)
    80003a8a:	e862                	sd	s8,16(sp)
    80003a8c:	e466                	sd	s9,8(sp)
    80003a8e:	1080                	addi	s0,sp,96
    80003a90:	84aa                	mv	s1,a0
    80003a92:	8b2e                	mv	s6,a1
    80003a94:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003a96:	00054703          	lbu	a4,0(a0)
    80003a9a:	02f00793          	li	a5,47
    80003a9e:	00f70e63          	beq	a4,a5,80003aba <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003aa2:	e2dfd0ef          	jal	800018ce <myproc>
    80003aa6:	15053503          	ld	a0,336(a0)
    80003aaa:	94bff0ef          	jal	800033f4 <idup>
    80003aae:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003ab0:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003ab4:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ab6:	4b85                	li	s7,1
    80003ab8:	a871                	j	80003b54 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003aba:	4585                	li	a1,1
    80003abc:	4505                	li	a0,1
    80003abe:	ef8ff0ef          	jal	800031b6 <iget>
    80003ac2:	8a2a                	mv	s4,a0
    80003ac4:	b7f5                	j	80003ab0 <namex+0x3a>
      iunlockput(ip);
    80003ac6:	8552                	mv	a0,s4
    80003ac8:	b6dff0ef          	jal	80003634 <iunlockput>
      return 0;
    80003acc:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ace:	8552                	mv	a0,s4
    80003ad0:	60e6                	ld	ra,88(sp)
    80003ad2:	6446                	ld	s0,80(sp)
    80003ad4:	64a6                	ld	s1,72(sp)
    80003ad6:	6906                	ld	s2,64(sp)
    80003ad8:	79e2                	ld	s3,56(sp)
    80003ada:	7a42                	ld	s4,48(sp)
    80003adc:	7aa2                	ld	s5,40(sp)
    80003ade:	7b02                	ld	s6,32(sp)
    80003ae0:	6be2                	ld	s7,24(sp)
    80003ae2:	6c42                	ld	s8,16(sp)
    80003ae4:	6ca2                	ld	s9,8(sp)
    80003ae6:	6125                	addi	sp,sp,96
    80003ae8:	8082                	ret
      iunlock(ip);
    80003aea:	8552                	mv	a0,s4
    80003aec:	9edff0ef          	jal	800034d8 <iunlock>
      return ip;
    80003af0:	bff9                	j	80003ace <namex+0x58>
      iunlockput(ip);
    80003af2:	8552                	mv	a0,s4
    80003af4:	b41ff0ef          	jal	80003634 <iunlockput>
      return 0;
    80003af8:	8a4e                	mv	s4,s3
    80003afa:	bfd1                	j	80003ace <namex+0x58>
  len = path - s;
    80003afc:	40998633          	sub	a2,s3,s1
    80003b00:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003b04:	099c5063          	bge	s8,s9,80003b84 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003b08:	4639                	li	a2,14
    80003b0a:	85a6                	mv	a1,s1
    80003b0c:	8556                	mv	a0,s5
    80003b0e:	9f0fd0ef          	jal	80000cfe <memmove>
    80003b12:	84ce                	mv	s1,s3
  while(*path == '/')
    80003b14:	0004c783          	lbu	a5,0(s1)
    80003b18:	01279763          	bne	a5,s2,80003b26 <namex+0xb0>
    path++;
    80003b1c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003b1e:	0004c783          	lbu	a5,0(s1)
    80003b22:	ff278de3          	beq	a5,s2,80003b1c <namex+0xa6>
    ilock(ip);
    80003b26:	8552                	mv	a0,s4
    80003b28:	903ff0ef          	jal	8000342a <ilock>
    if(ip->type != T_DIR){
    80003b2c:	044a1783          	lh	a5,68(s4)
    80003b30:	f9779be3          	bne	a5,s7,80003ac6 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003b34:	000b0563          	beqz	s6,80003b3e <namex+0xc8>
    80003b38:	0004c783          	lbu	a5,0(s1)
    80003b3c:	d7dd                	beqz	a5,80003aea <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003b3e:	4601                	li	a2,0
    80003b40:	85d6                	mv	a1,s5
    80003b42:	8552                	mv	a0,s4
    80003b44:	e97ff0ef          	jal	800039da <dirlookup>
    80003b48:	89aa                	mv	s3,a0
    80003b4a:	d545                	beqz	a0,80003af2 <namex+0x7c>
    iunlockput(ip);
    80003b4c:	8552                	mv	a0,s4
    80003b4e:	ae7ff0ef          	jal	80003634 <iunlockput>
    ip = next;
    80003b52:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003b54:	0004c783          	lbu	a5,0(s1)
    80003b58:	01279763          	bne	a5,s2,80003b66 <namex+0xf0>
    path++;
    80003b5c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003b5e:	0004c783          	lbu	a5,0(s1)
    80003b62:	ff278de3          	beq	a5,s2,80003b5c <namex+0xe6>
  if(*path == 0)
    80003b66:	cb8d                	beqz	a5,80003b98 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003b68:	0004c783          	lbu	a5,0(s1)
    80003b6c:	89a6                	mv	s3,s1
  len = path - s;
    80003b6e:	4c81                	li	s9,0
    80003b70:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003b72:	01278963          	beq	a5,s2,80003b84 <namex+0x10e>
    80003b76:	d3d9                	beqz	a5,80003afc <namex+0x86>
    path++;
    80003b78:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003b7a:	0009c783          	lbu	a5,0(s3)
    80003b7e:	ff279ce3          	bne	a5,s2,80003b76 <namex+0x100>
    80003b82:	bfad                	j	80003afc <namex+0x86>
    memmove(name, s, len);
    80003b84:	2601                	sext.w	a2,a2
    80003b86:	85a6                	mv	a1,s1
    80003b88:	8556                	mv	a0,s5
    80003b8a:	974fd0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    80003b8e:	9cd6                	add	s9,s9,s5
    80003b90:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003b94:	84ce                	mv	s1,s3
    80003b96:	bfbd                	j	80003b14 <namex+0x9e>
  if(nameiparent){
    80003b98:	f20b0be3          	beqz	s6,80003ace <namex+0x58>
    iput(ip);
    80003b9c:	8552                	mv	a0,s4
    80003b9e:	a0fff0ef          	jal	800035ac <iput>
    return 0;
    80003ba2:	4a01                	li	s4,0
    80003ba4:	b72d                	j	80003ace <namex+0x58>

0000000080003ba6 <dirlink>:
{
    80003ba6:	7139                	addi	sp,sp,-64
    80003ba8:	fc06                	sd	ra,56(sp)
    80003baa:	f822                	sd	s0,48(sp)
    80003bac:	f04a                	sd	s2,32(sp)
    80003bae:	ec4e                	sd	s3,24(sp)
    80003bb0:	e852                	sd	s4,16(sp)
    80003bb2:	0080                	addi	s0,sp,64
    80003bb4:	892a                	mv	s2,a0
    80003bb6:	8a2e                	mv	s4,a1
    80003bb8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003bba:	4601                	li	a2,0
    80003bbc:	e1fff0ef          	jal	800039da <dirlookup>
    80003bc0:	e535                	bnez	a0,80003c2c <dirlink+0x86>
    80003bc2:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bc4:	04c92483          	lw	s1,76(s2)
    80003bc8:	c48d                	beqz	s1,80003bf2 <dirlink+0x4c>
    80003bca:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bcc:	4741                	li	a4,16
    80003bce:	86a6                	mv	a3,s1
    80003bd0:	fc040613          	addi	a2,s0,-64
    80003bd4:	4581                	li	a1,0
    80003bd6:	854a                	mv	a0,s2
    80003bd8:	be3ff0ef          	jal	800037ba <readi>
    80003bdc:	47c1                	li	a5,16
    80003bde:	04f51b63          	bne	a0,a5,80003c34 <dirlink+0x8e>
    if(de.inum == 0)
    80003be2:	fc045783          	lhu	a5,-64(s0)
    80003be6:	c791                	beqz	a5,80003bf2 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003be8:	24c1                	addiw	s1,s1,16
    80003bea:	04c92783          	lw	a5,76(s2)
    80003bee:	fcf4efe3          	bltu	s1,a5,80003bcc <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003bf2:	4639                	li	a2,14
    80003bf4:	85d2                	mv	a1,s4
    80003bf6:	fc240513          	addi	a0,s0,-62
    80003bfa:	9aafd0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    80003bfe:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c02:	4741                	li	a4,16
    80003c04:	86a6                	mv	a3,s1
    80003c06:	fc040613          	addi	a2,s0,-64
    80003c0a:	4581                	li	a1,0
    80003c0c:	854a                	mv	a0,s2
    80003c0e:	ca9ff0ef          	jal	800038b6 <writei>
    80003c12:	1541                	addi	a0,a0,-16
    80003c14:	00a03533          	snez	a0,a0
    80003c18:	40a00533          	neg	a0,a0
    80003c1c:	74a2                	ld	s1,40(sp)
}
    80003c1e:	70e2                	ld	ra,56(sp)
    80003c20:	7442                	ld	s0,48(sp)
    80003c22:	7902                	ld	s2,32(sp)
    80003c24:	69e2                	ld	s3,24(sp)
    80003c26:	6a42                	ld	s4,16(sp)
    80003c28:	6121                	addi	sp,sp,64
    80003c2a:	8082                	ret
    iput(ip);
    80003c2c:	981ff0ef          	jal	800035ac <iput>
    return -1;
    80003c30:	557d                	li	a0,-1
    80003c32:	b7f5                	j	80003c1e <dirlink+0x78>
      panic("dirlink read");
    80003c34:	00004517          	auipc	a0,0x4
    80003c38:	89450513          	addi	a0,a0,-1900 # 800074c8 <etext+0x4c8>
    80003c3c:	ba5fc0ef          	jal	800007e0 <panic>

0000000080003c40 <namei>:

struct inode*
namei(char *path)
{
    80003c40:	1101                	addi	sp,sp,-32
    80003c42:	ec06                	sd	ra,24(sp)
    80003c44:	e822                	sd	s0,16(sp)
    80003c46:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003c48:	fe040613          	addi	a2,s0,-32
    80003c4c:	4581                	li	a1,0
    80003c4e:	e29ff0ef          	jal	80003a76 <namex>
}
    80003c52:	60e2                	ld	ra,24(sp)
    80003c54:	6442                	ld	s0,16(sp)
    80003c56:	6105                	addi	sp,sp,32
    80003c58:	8082                	ret

0000000080003c5a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003c5a:	1141                	addi	sp,sp,-16
    80003c5c:	e406                	sd	ra,8(sp)
    80003c5e:	e022                	sd	s0,0(sp)
    80003c60:	0800                	addi	s0,sp,16
    80003c62:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003c64:	4585                	li	a1,1
    80003c66:	e11ff0ef          	jal	80003a76 <namex>
}
    80003c6a:	60a2                	ld	ra,8(sp)
    80003c6c:	6402                	ld	s0,0(sp)
    80003c6e:	0141                	addi	sp,sp,16
    80003c70:	8082                	ret

0000000080003c72 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003c72:	1101                	addi	sp,sp,-32
    80003c74:	ec06                	sd	ra,24(sp)
    80003c76:	e822                	sd	s0,16(sp)
    80003c78:	e426                	sd	s1,8(sp)
    80003c7a:	e04a                	sd	s2,0(sp)
    80003c7c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003c7e:	0001c917          	auipc	s2,0x1c
    80003c82:	eca90913          	addi	s2,s2,-310 # 8001fb48 <log>
    80003c86:	01892583          	lw	a1,24(s2)
    80003c8a:	02492503          	lw	a0,36(s2)
    80003c8e:	8d0ff0ef          	jal	80002d5e <bread>
    80003c92:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003c94:	02892603          	lw	a2,40(s2)
    80003c98:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003c9a:	00c05f63          	blez	a2,80003cb8 <write_head+0x46>
    80003c9e:	0001c717          	auipc	a4,0x1c
    80003ca2:	ed670713          	addi	a4,a4,-298 # 8001fb74 <log+0x2c>
    80003ca6:	87aa                	mv	a5,a0
    80003ca8:	060a                	slli	a2,a2,0x2
    80003caa:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003cac:	4314                	lw	a3,0(a4)
    80003cae:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003cb0:	0711                	addi	a4,a4,4
    80003cb2:	0791                	addi	a5,a5,4
    80003cb4:	fec79ce3          	bne	a5,a2,80003cac <write_head+0x3a>
  }
  bwrite(buf);
    80003cb8:	8526                	mv	a0,s1
    80003cba:	97aff0ef          	jal	80002e34 <bwrite>
  brelse(buf);
    80003cbe:	8526                	mv	a0,s1
    80003cc0:	9a6ff0ef          	jal	80002e66 <brelse>
}
    80003cc4:	60e2                	ld	ra,24(sp)
    80003cc6:	6442                	ld	s0,16(sp)
    80003cc8:	64a2                	ld	s1,8(sp)
    80003cca:	6902                	ld	s2,0(sp)
    80003ccc:	6105                	addi	sp,sp,32
    80003cce:	8082                	ret

0000000080003cd0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cd0:	0001c797          	auipc	a5,0x1c
    80003cd4:	ea07a783          	lw	a5,-352(a5) # 8001fb70 <log+0x28>
    80003cd8:	0af05e63          	blez	a5,80003d94 <install_trans+0xc4>
{
    80003cdc:	715d                	addi	sp,sp,-80
    80003cde:	e486                	sd	ra,72(sp)
    80003ce0:	e0a2                	sd	s0,64(sp)
    80003ce2:	fc26                	sd	s1,56(sp)
    80003ce4:	f84a                	sd	s2,48(sp)
    80003ce6:	f44e                	sd	s3,40(sp)
    80003ce8:	f052                	sd	s4,32(sp)
    80003cea:	ec56                	sd	s5,24(sp)
    80003cec:	e85a                	sd	s6,16(sp)
    80003cee:	e45e                	sd	s7,8(sp)
    80003cf0:	0880                	addi	s0,sp,80
    80003cf2:	8b2a                	mv	s6,a0
    80003cf4:	0001ca97          	auipc	s5,0x1c
    80003cf8:	e80a8a93          	addi	s5,s5,-384 # 8001fb74 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cfc:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003cfe:	00003b97          	auipc	s7,0x3
    80003d02:	7dab8b93          	addi	s7,s7,2010 # 800074d8 <etext+0x4d8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d06:	0001ca17          	auipc	s4,0x1c
    80003d0a:	e42a0a13          	addi	s4,s4,-446 # 8001fb48 <log>
    80003d0e:	a025                	j	80003d36 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d10:	000aa603          	lw	a2,0(s5)
    80003d14:	85ce                	mv	a1,s3
    80003d16:	855e                	mv	a0,s7
    80003d18:	fe2fc0ef          	jal	800004fa <printf>
    80003d1c:	a839                	j	80003d3a <install_trans+0x6a>
    brelse(lbuf);
    80003d1e:	854a                	mv	a0,s2
    80003d20:	946ff0ef          	jal	80002e66 <brelse>
    brelse(dbuf);
    80003d24:	8526                	mv	a0,s1
    80003d26:	940ff0ef          	jal	80002e66 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d2a:	2985                	addiw	s3,s3,1
    80003d2c:	0a91                	addi	s5,s5,4
    80003d2e:	028a2783          	lw	a5,40(s4)
    80003d32:	04f9d663          	bge	s3,a5,80003d7e <install_trans+0xae>
    if(recovering) {
    80003d36:	fc0b1de3          	bnez	s6,80003d10 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d3a:	018a2583          	lw	a1,24(s4)
    80003d3e:	013585bb          	addw	a1,a1,s3
    80003d42:	2585                	addiw	a1,a1,1
    80003d44:	024a2503          	lw	a0,36(s4)
    80003d48:	816ff0ef          	jal	80002d5e <bread>
    80003d4c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003d4e:	000aa583          	lw	a1,0(s5)
    80003d52:	024a2503          	lw	a0,36(s4)
    80003d56:	808ff0ef          	jal	80002d5e <bread>
    80003d5a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003d5c:	40000613          	li	a2,1024
    80003d60:	05890593          	addi	a1,s2,88
    80003d64:	05850513          	addi	a0,a0,88
    80003d68:	f97fc0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    80003d6c:	8526                	mv	a0,s1
    80003d6e:	8c6ff0ef          	jal	80002e34 <bwrite>
    if(recovering == 0)
    80003d72:	fa0b16e3          	bnez	s6,80003d1e <install_trans+0x4e>
      bunpin(dbuf);
    80003d76:	8526                	mv	a0,s1
    80003d78:	9aaff0ef          	jal	80002f22 <bunpin>
    80003d7c:	b74d                	j	80003d1e <install_trans+0x4e>
}
    80003d7e:	60a6                	ld	ra,72(sp)
    80003d80:	6406                	ld	s0,64(sp)
    80003d82:	74e2                	ld	s1,56(sp)
    80003d84:	7942                	ld	s2,48(sp)
    80003d86:	79a2                	ld	s3,40(sp)
    80003d88:	7a02                	ld	s4,32(sp)
    80003d8a:	6ae2                	ld	s5,24(sp)
    80003d8c:	6b42                	ld	s6,16(sp)
    80003d8e:	6ba2                	ld	s7,8(sp)
    80003d90:	6161                	addi	sp,sp,80
    80003d92:	8082                	ret
    80003d94:	8082                	ret

0000000080003d96 <initlog>:
{
    80003d96:	7179                	addi	sp,sp,-48
    80003d98:	f406                	sd	ra,40(sp)
    80003d9a:	f022                	sd	s0,32(sp)
    80003d9c:	ec26                	sd	s1,24(sp)
    80003d9e:	e84a                	sd	s2,16(sp)
    80003da0:	e44e                	sd	s3,8(sp)
    80003da2:	1800                	addi	s0,sp,48
    80003da4:	892a                	mv	s2,a0
    80003da6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003da8:	0001c497          	auipc	s1,0x1c
    80003dac:	da048493          	addi	s1,s1,-608 # 8001fb48 <log>
    80003db0:	00003597          	auipc	a1,0x3
    80003db4:	74858593          	addi	a1,a1,1864 # 800074f8 <etext+0x4f8>
    80003db8:	8526                	mv	a0,s1
    80003dba:	d95fc0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    80003dbe:	0149a583          	lw	a1,20(s3)
    80003dc2:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003dc4:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003dc8:	854a                	mv	a0,s2
    80003dca:	f95fe0ef          	jal	80002d5e <bread>
  log.lh.n = lh->n;
    80003dce:	4d30                	lw	a2,88(a0)
    80003dd0:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003dd2:	00c05f63          	blez	a2,80003df0 <initlog+0x5a>
    80003dd6:	87aa                	mv	a5,a0
    80003dd8:	0001c717          	auipc	a4,0x1c
    80003ddc:	d9c70713          	addi	a4,a4,-612 # 8001fb74 <log+0x2c>
    80003de0:	060a                	slli	a2,a2,0x2
    80003de2:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003de4:	4ff4                	lw	a3,92(a5)
    80003de6:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003de8:	0791                	addi	a5,a5,4
    80003dea:	0711                	addi	a4,a4,4
    80003dec:	fec79ce3          	bne	a5,a2,80003de4 <initlog+0x4e>
  brelse(buf);
    80003df0:	876ff0ef          	jal	80002e66 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003df4:	4505                	li	a0,1
    80003df6:	edbff0ef          	jal	80003cd0 <install_trans>
  log.lh.n = 0;
    80003dfa:	0001c797          	auipc	a5,0x1c
    80003dfe:	d607ab23          	sw	zero,-650(a5) # 8001fb70 <log+0x28>
  write_head(); // clear the log
    80003e02:	e71ff0ef          	jal	80003c72 <write_head>
}
    80003e06:	70a2                	ld	ra,40(sp)
    80003e08:	7402                	ld	s0,32(sp)
    80003e0a:	64e2                	ld	s1,24(sp)
    80003e0c:	6942                	ld	s2,16(sp)
    80003e0e:	69a2                	ld	s3,8(sp)
    80003e10:	6145                	addi	sp,sp,48
    80003e12:	8082                	ret

0000000080003e14 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003e14:	1101                	addi	sp,sp,-32
    80003e16:	ec06                	sd	ra,24(sp)
    80003e18:	e822                	sd	s0,16(sp)
    80003e1a:	e426                	sd	s1,8(sp)
    80003e1c:	e04a                	sd	s2,0(sp)
    80003e1e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e20:	0001c517          	auipc	a0,0x1c
    80003e24:	d2850513          	addi	a0,a0,-728 # 8001fb48 <log>
    80003e28:	da7fc0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    80003e2c:	0001c497          	auipc	s1,0x1c
    80003e30:	d1c48493          	addi	s1,s1,-740 # 8001fb48 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003e34:	4979                	li	s2,30
    80003e36:	a029                	j	80003e40 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003e38:	85a6                	mv	a1,s1
    80003e3a:	8526                	mv	a0,s1
    80003e3c:	89cfe0ef          	jal	80001ed8 <sleep>
    if(log.committing){
    80003e40:	509c                	lw	a5,32(s1)
    80003e42:	fbfd                	bnez	a5,80003e38 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003e44:	4cd8                	lw	a4,28(s1)
    80003e46:	2705                	addiw	a4,a4,1
    80003e48:	0027179b          	slliw	a5,a4,0x2
    80003e4c:	9fb9                	addw	a5,a5,a4
    80003e4e:	0017979b          	slliw	a5,a5,0x1
    80003e52:	5494                	lw	a3,40(s1)
    80003e54:	9fb5                	addw	a5,a5,a3
    80003e56:	00f95763          	bge	s2,a5,80003e64 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003e5a:	85a6                	mv	a1,s1
    80003e5c:	8526                	mv	a0,s1
    80003e5e:	87afe0ef          	jal	80001ed8 <sleep>
    80003e62:	bff9                	j	80003e40 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003e64:	0001c517          	auipc	a0,0x1c
    80003e68:	ce450513          	addi	a0,a0,-796 # 8001fb48 <log>
    80003e6c:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003e6e:	df9fc0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80003e72:	60e2                	ld	ra,24(sp)
    80003e74:	6442                	ld	s0,16(sp)
    80003e76:	64a2                	ld	s1,8(sp)
    80003e78:	6902                	ld	s2,0(sp)
    80003e7a:	6105                	addi	sp,sp,32
    80003e7c:	8082                	ret

0000000080003e7e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003e7e:	7139                	addi	sp,sp,-64
    80003e80:	fc06                	sd	ra,56(sp)
    80003e82:	f822                	sd	s0,48(sp)
    80003e84:	f426                	sd	s1,40(sp)
    80003e86:	f04a                	sd	s2,32(sp)
    80003e88:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e8a:	0001c497          	auipc	s1,0x1c
    80003e8e:	cbe48493          	addi	s1,s1,-834 # 8001fb48 <log>
    80003e92:	8526                	mv	a0,s1
    80003e94:	d3bfc0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80003e98:	4cdc                	lw	a5,28(s1)
    80003e9a:	37fd                	addiw	a5,a5,-1
    80003e9c:	0007891b          	sext.w	s2,a5
    80003ea0:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003ea2:	509c                	lw	a5,32(s1)
    80003ea4:	ef9d                	bnez	a5,80003ee2 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003ea6:	04091763          	bnez	s2,80003ef4 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003eaa:	0001c497          	auipc	s1,0x1c
    80003eae:	c9e48493          	addi	s1,s1,-866 # 8001fb48 <log>
    80003eb2:	4785                	li	a5,1
    80003eb4:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003eb6:	8526                	mv	a0,s1
    80003eb8:	daffc0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003ebc:	549c                	lw	a5,40(s1)
    80003ebe:	04f04b63          	bgtz	a5,80003f14 <end_op+0x96>
    acquire(&log.lock);
    80003ec2:	0001c497          	auipc	s1,0x1c
    80003ec6:	c8648493          	addi	s1,s1,-890 # 8001fb48 <log>
    80003eca:	8526                	mv	a0,s1
    80003ecc:	d03fc0ef          	jal	80000bce <acquire>
    log.committing = 0;
    80003ed0:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003ed4:	8526                	mv	a0,s1
    80003ed6:	84efe0ef          	jal	80001f24 <wakeup>
    release(&log.lock);
    80003eda:	8526                	mv	a0,s1
    80003edc:	d8bfc0ef          	jal	80000c66 <release>
}
    80003ee0:	a025                	j	80003f08 <end_op+0x8a>
    80003ee2:	ec4e                	sd	s3,24(sp)
    80003ee4:	e852                	sd	s4,16(sp)
    80003ee6:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003ee8:	00003517          	auipc	a0,0x3
    80003eec:	61850513          	addi	a0,a0,1560 # 80007500 <etext+0x500>
    80003ef0:	8f1fc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80003ef4:	0001c497          	auipc	s1,0x1c
    80003ef8:	c5448493          	addi	s1,s1,-940 # 8001fb48 <log>
    80003efc:	8526                	mv	a0,s1
    80003efe:	826fe0ef          	jal	80001f24 <wakeup>
  release(&log.lock);
    80003f02:	8526                	mv	a0,s1
    80003f04:	d63fc0ef          	jal	80000c66 <release>
}
    80003f08:	70e2                	ld	ra,56(sp)
    80003f0a:	7442                	ld	s0,48(sp)
    80003f0c:	74a2                	ld	s1,40(sp)
    80003f0e:	7902                	ld	s2,32(sp)
    80003f10:	6121                	addi	sp,sp,64
    80003f12:	8082                	ret
    80003f14:	ec4e                	sd	s3,24(sp)
    80003f16:	e852                	sd	s4,16(sp)
    80003f18:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f1a:	0001ca97          	auipc	s5,0x1c
    80003f1e:	c5aa8a93          	addi	s5,s5,-934 # 8001fb74 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003f22:	0001ca17          	auipc	s4,0x1c
    80003f26:	c26a0a13          	addi	s4,s4,-986 # 8001fb48 <log>
    80003f2a:	018a2583          	lw	a1,24(s4)
    80003f2e:	012585bb          	addw	a1,a1,s2
    80003f32:	2585                	addiw	a1,a1,1
    80003f34:	024a2503          	lw	a0,36(s4)
    80003f38:	e27fe0ef          	jal	80002d5e <bread>
    80003f3c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003f3e:	000aa583          	lw	a1,0(s5)
    80003f42:	024a2503          	lw	a0,36(s4)
    80003f46:	e19fe0ef          	jal	80002d5e <bread>
    80003f4a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003f4c:	40000613          	li	a2,1024
    80003f50:	05850593          	addi	a1,a0,88
    80003f54:	05848513          	addi	a0,s1,88
    80003f58:	da7fc0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    80003f5c:	8526                	mv	a0,s1
    80003f5e:	ed7fe0ef          	jal	80002e34 <bwrite>
    brelse(from);
    80003f62:	854e                	mv	a0,s3
    80003f64:	f03fe0ef          	jal	80002e66 <brelse>
    brelse(to);
    80003f68:	8526                	mv	a0,s1
    80003f6a:	efdfe0ef          	jal	80002e66 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f6e:	2905                	addiw	s2,s2,1
    80003f70:	0a91                	addi	s5,s5,4
    80003f72:	028a2783          	lw	a5,40(s4)
    80003f76:	faf94ae3          	blt	s2,a5,80003f2a <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003f7a:	cf9ff0ef          	jal	80003c72 <write_head>
    install_trans(0); // Now install writes to home locations
    80003f7e:	4501                	li	a0,0
    80003f80:	d51ff0ef          	jal	80003cd0 <install_trans>
    log.lh.n = 0;
    80003f84:	0001c797          	auipc	a5,0x1c
    80003f88:	be07a623          	sw	zero,-1044(a5) # 8001fb70 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003f8c:	ce7ff0ef          	jal	80003c72 <write_head>
    80003f90:	69e2                	ld	s3,24(sp)
    80003f92:	6a42                	ld	s4,16(sp)
    80003f94:	6aa2                	ld	s5,8(sp)
    80003f96:	b735                	j	80003ec2 <end_op+0x44>

0000000080003f98 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003f98:	1101                	addi	sp,sp,-32
    80003f9a:	ec06                	sd	ra,24(sp)
    80003f9c:	e822                	sd	s0,16(sp)
    80003f9e:	e426                	sd	s1,8(sp)
    80003fa0:	e04a                	sd	s2,0(sp)
    80003fa2:	1000                	addi	s0,sp,32
    80003fa4:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003fa6:	0001c917          	auipc	s2,0x1c
    80003faa:	ba290913          	addi	s2,s2,-1118 # 8001fb48 <log>
    80003fae:	854a                	mv	a0,s2
    80003fb0:	c1ffc0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003fb4:	02892603          	lw	a2,40(s2)
    80003fb8:	47f5                	li	a5,29
    80003fba:	04c7cc63          	blt	a5,a2,80004012 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003fbe:	0001c797          	auipc	a5,0x1c
    80003fc2:	ba67a783          	lw	a5,-1114(a5) # 8001fb64 <log+0x1c>
    80003fc6:	04f05c63          	blez	a5,8000401e <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003fca:	4781                	li	a5,0
    80003fcc:	04c05f63          	blez	a2,8000402a <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003fd0:	44cc                	lw	a1,12(s1)
    80003fd2:	0001c717          	auipc	a4,0x1c
    80003fd6:	ba270713          	addi	a4,a4,-1118 # 8001fb74 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003fda:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003fdc:	4314                	lw	a3,0(a4)
    80003fde:	04b68663          	beq	a3,a1,8000402a <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003fe2:	2785                	addiw	a5,a5,1
    80003fe4:	0711                	addi	a4,a4,4
    80003fe6:	fef61be3          	bne	a2,a5,80003fdc <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003fea:	0621                	addi	a2,a2,8
    80003fec:	060a                	slli	a2,a2,0x2
    80003fee:	0001c797          	auipc	a5,0x1c
    80003ff2:	b5a78793          	addi	a5,a5,-1190 # 8001fb48 <log>
    80003ff6:	97b2                	add	a5,a5,a2
    80003ff8:	44d8                	lw	a4,12(s1)
    80003ffa:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003ffc:	8526                	mv	a0,s1
    80003ffe:	ef1fe0ef          	jal	80002eee <bpin>
    log.lh.n++;
    80004002:	0001c717          	auipc	a4,0x1c
    80004006:	b4670713          	addi	a4,a4,-1210 # 8001fb48 <log>
    8000400a:	571c                	lw	a5,40(a4)
    8000400c:	2785                	addiw	a5,a5,1
    8000400e:	d71c                	sw	a5,40(a4)
    80004010:	a80d                	j	80004042 <log_write+0xaa>
    panic("too big a transaction");
    80004012:	00003517          	auipc	a0,0x3
    80004016:	4fe50513          	addi	a0,a0,1278 # 80007510 <etext+0x510>
    8000401a:	fc6fc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    8000401e:	00003517          	auipc	a0,0x3
    80004022:	50a50513          	addi	a0,a0,1290 # 80007528 <etext+0x528>
    80004026:	fbafc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    8000402a:	00878693          	addi	a3,a5,8
    8000402e:	068a                	slli	a3,a3,0x2
    80004030:	0001c717          	auipc	a4,0x1c
    80004034:	b1870713          	addi	a4,a4,-1256 # 8001fb48 <log>
    80004038:	9736                	add	a4,a4,a3
    8000403a:	44d4                	lw	a3,12(s1)
    8000403c:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000403e:	faf60fe3          	beq	a2,a5,80003ffc <log_write+0x64>
  }
  release(&log.lock);
    80004042:	0001c517          	auipc	a0,0x1c
    80004046:	b0650513          	addi	a0,a0,-1274 # 8001fb48 <log>
    8000404a:	c1dfc0ef          	jal	80000c66 <release>
}
    8000404e:	60e2                	ld	ra,24(sp)
    80004050:	6442                	ld	s0,16(sp)
    80004052:	64a2                	ld	s1,8(sp)
    80004054:	6902                	ld	s2,0(sp)
    80004056:	6105                	addi	sp,sp,32
    80004058:	8082                	ret

000000008000405a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000405a:	1101                	addi	sp,sp,-32
    8000405c:	ec06                	sd	ra,24(sp)
    8000405e:	e822                	sd	s0,16(sp)
    80004060:	e426                	sd	s1,8(sp)
    80004062:	e04a                	sd	s2,0(sp)
    80004064:	1000                	addi	s0,sp,32
    80004066:	84aa                	mv	s1,a0
    80004068:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000406a:	00003597          	auipc	a1,0x3
    8000406e:	4de58593          	addi	a1,a1,1246 # 80007548 <etext+0x548>
    80004072:	0521                	addi	a0,a0,8
    80004074:	adbfc0ef          	jal	80000b4e <initlock>
  lk->name = name;
    80004078:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000407c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004080:	0204a423          	sw	zero,40(s1)
}
    80004084:	60e2                	ld	ra,24(sp)
    80004086:	6442                	ld	s0,16(sp)
    80004088:	64a2                	ld	s1,8(sp)
    8000408a:	6902                	ld	s2,0(sp)
    8000408c:	6105                	addi	sp,sp,32
    8000408e:	8082                	ret

0000000080004090 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004090:	1101                	addi	sp,sp,-32
    80004092:	ec06                	sd	ra,24(sp)
    80004094:	e822                	sd	s0,16(sp)
    80004096:	e426                	sd	s1,8(sp)
    80004098:	e04a                	sd	s2,0(sp)
    8000409a:	1000                	addi	s0,sp,32
    8000409c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000409e:	00850913          	addi	s2,a0,8
    800040a2:	854a                	mv	a0,s2
    800040a4:	b2bfc0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    800040a8:	409c                	lw	a5,0(s1)
    800040aa:	c799                	beqz	a5,800040b8 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800040ac:	85ca                	mv	a1,s2
    800040ae:	8526                	mv	a0,s1
    800040b0:	e29fd0ef          	jal	80001ed8 <sleep>
  while (lk->locked) {
    800040b4:	409c                	lw	a5,0(s1)
    800040b6:	fbfd                	bnez	a5,800040ac <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800040b8:	4785                	li	a5,1
    800040ba:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800040bc:	813fd0ef          	jal	800018ce <myproc>
    800040c0:	591c                	lw	a5,48(a0)
    800040c2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800040c4:	854a                	mv	a0,s2
    800040c6:	ba1fc0ef          	jal	80000c66 <release>
}
    800040ca:	60e2                	ld	ra,24(sp)
    800040cc:	6442                	ld	s0,16(sp)
    800040ce:	64a2                	ld	s1,8(sp)
    800040d0:	6902                	ld	s2,0(sp)
    800040d2:	6105                	addi	sp,sp,32
    800040d4:	8082                	ret

00000000800040d6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800040d6:	1101                	addi	sp,sp,-32
    800040d8:	ec06                	sd	ra,24(sp)
    800040da:	e822                	sd	s0,16(sp)
    800040dc:	e426                	sd	s1,8(sp)
    800040de:	e04a                	sd	s2,0(sp)
    800040e0:	1000                	addi	s0,sp,32
    800040e2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800040e4:	00850913          	addi	s2,a0,8
    800040e8:	854a                	mv	a0,s2
    800040ea:	ae5fc0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    800040ee:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800040f2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800040f6:	8526                	mv	a0,s1
    800040f8:	e2dfd0ef          	jal	80001f24 <wakeup>
  release(&lk->lk);
    800040fc:	854a                	mv	a0,s2
    800040fe:	b69fc0ef          	jal	80000c66 <release>
}
    80004102:	60e2                	ld	ra,24(sp)
    80004104:	6442                	ld	s0,16(sp)
    80004106:	64a2                	ld	s1,8(sp)
    80004108:	6902                	ld	s2,0(sp)
    8000410a:	6105                	addi	sp,sp,32
    8000410c:	8082                	ret

000000008000410e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000410e:	7179                	addi	sp,sp,-48
    80004110:	f406                	sd	ra,40(sp)
    80004112:	f022                	sd	s0,32(sp)
    80004114:	ec26                	sd	s1,24(sp)
    80004116:	e84a                	sd	s2,16(sp)
    80004118:	1800                	addi	s0,sp,48
    8000411a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000411c:	00850913          	addi	s2,a0,8
    80004120:	854a                	mv	a0,s2
    80004122:	aadfc0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004126:	409c                	lw	a5,0(s1)
    80004128:	ef81                	bnez	a5,80004140 <holdingsleep+0x32>
    8000412a:	4481                	li	s1,0
  release(&lk->lk);
    8000412c:	854a                	mv	a0,s2
    8000412e:	b39fc0ef          	jal	80000c66 <release>
  return r;
}
    80004132:	8526                	mv	a0,s1
    80004134:	70a2                	ld	ra,40(sp)
    80004136:	7402                	ld	s0,32(sp)
    80004138:	64e2                	ld	s1,24(sp)
    8000413a:	6942                	ld	s2,16(sp)
    8000413c:	6145                	addi	sp,sp,48
    8000413e:	8082                	ret
    80004140:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004142:	0284a983          	lw	s3,40(s1)
    80004146:	f88fd0ef          	jal	800018ce <myproc>
    8000414a:	5904                	lw	s1,48(a0)
    8000414c:	413484b3          	sub	s1,s1,s3
    80004150:	0014b493          	seqz	s1,s1
    80004154:	69a2                	ld	s3,8(sp)
    80004156:	bfd9                	j	8000412c <holdingsleep+0x1e>

0000000080004158 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004158:	1141                	addi	sp,sp,-16
    8000415a:	e406                	sd	ra,8(sp)
    8000415c:	e022                	sd	s0,0(sp)
    8000415e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004160:	00003597          	auipc	a1,0x3
    80004164:	3f858593          	addi	a1,a1,1016 # 80007558 <etext+0x558>
    80004168:	0001c517          	auipc	a0,0x1c
    8000416c:	b2850513          	addi	a0,a0,-1240 # 8001fc90 <ftable>
    80004170:	9dffc0ef          	jal	80000b4e <initlock>
}
    80004174:	60a2                	ld	ra,8(sp)
    80004176:	6402                	ld	s0,0(sp)
    80004178:	0141                	addi	sp,sp,16
    8000417a:	8082                	ret

000000008000417c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000417c:	1101                	addi	sp,sp,-32
    8000417e:	ec06                	sd	ra,24(sp)
    80004180:	e822                	sd	s0,16(sp)
    80004182:	e426                	sd	s1,8(sp)
    80004184:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004186:	0001c517          	auipc	a0,0x1c
    8000418a:	b0a50513          	addi	a0,a0,-1270 # 8001fc90 <ftable>
    8000418e:	a41fc0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004192:	0001c497          	auipc	s1,0x1c
    80004196:	b1648493          	addi	s1,s1,-1258 # 8001fca8 <ftable+0x18>
    8000419a:	0001d717          	auipc	a4,0x1d
    8000419e:	aae70713          	addi	a4,a4,-1362 # 80020c48 <disk>
    if(f->ref == 0){
    800041a2:	40dc                	lw	a5,4(s1)
    800041a4:	cf89                	beqz	a5,800041be <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800041a6:	02848493          	addi	s1,s1,40
    800041aa:	fee49ce3          	bne	s1,a4,800041a2 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800041ae:	0001c517          	auipc	a0,0x1c
    800041b2:	ae250513          	addi	a0,a0,-1310 # 8001fc90 <ftable>
    800041b6:	ab1fc0ef          	jal	80000c66 <release>
  return 0;
    800041ba:	4481                	li	s1,0
    800041bc:	a809                	j	800041ce <filealloc+0x52>
      f->ref = 1;
    800041be:	4785                	li	a5,1
    800041c0:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800041c2:	0001c517          	auipc	a0,0x1c
    800041c6:	ace50513          	addi	a0,a0,-1330 # 8001fc90 <ftable>
    800041ca:	a9dfc0ef          	jal	80000c66 <release>
}
    800041ce:	8526                	mv	a0,s1
    800041d0:	60e2                	ld	ra,24(sp)
    800041d2:	6442                	ld	s0,16(sp)
    800041d4:	64a2                	ld	s1,8(sp)
    800041d6:	6105                	addi	sp,sp,32
    800041d8:	8082                	ret

00000000800041da <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800041da:	1101                	addi	sp,sp,-32
    800041dc:	ec06                	sd	ra,24(sp)
    800041de:	e822                	sd	s0,16(sp)
    800041e0:	e426                	sd	s1,8(sp)
    800041e2:	1000                	addi	s0,sp,32
    800041e4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800041e6:	0001c517          	auipc	a0,0x1c
    800041ea:	aaa50513          	addi	a0,a0,-1366 # 8001fc90 <ftable>
    800041ee:	9e1fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    800041f2:	40dc                	lw	a5,4(s1)
    800041f4:	02f05063          	blez	a5,80004214 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800041f8:	2785                	addiw	a5,a5,1
    800041fa:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800041fc:	0001c517          	auipc	a0,0x1c
    80004200:	a9450513          	addi	a0,a0,-1388 # 8001fc90 <ftable>
    80004204:	a63fc0ef          	jal	80000c66 <release>
  return f;
}
    80004208:	8526                	mv	a0,s1
    8000420a:	60e2                	ld	ra,24(sp)
    8000420c:	6442                	ld	s0,16(sp)
    8000420e:	64a2                	ld	s1,8(sp)
    80004210:	6105                	addi	sp,sp,32
    80004212:	8082                	ret
    panic("filedup");
    80004214:	00003517          	auipc	a0,0x3
    80004218:	34c50513          	addi	a0,a0,844 # 80007560 <etext+0x560>
    8000421c:	dc4fc0ef          	jal	800007e0 <panic>

0000000080004220 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004220:	7139                	addi	sp,sp,-64
    80004222:	fc06                	sd	ra,56(sp)
    80004224:	f822                	sd	s0,48(sp)
    80004226:	f426                	sd	s1,40(sp)
    80004228:	0080                	addi	s0,sp,64
    8000422a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000422c:	0001c517          	auipc	a0,0x1c
    80004230:	a6450513          	addi	a0,a0,-1436 # 8001fc90 <ftable>
    80004234:	99bfc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80004238:	40dc                	lw	a5,4(s1)
    8000423a:	04f05a63          	blez	a5,8000428e <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    8000423e:	37fd                	addiw	a5,a5,-1
    80004240:	0007871b          	sext.w	a4,a5
    80004244:	c0dc                	sw	a5,4(s1)
    80004246:	04e04e63          	bgtz	a4,800042a2 <fileclose+0x82>
    8000424a:	f04a                	sd	s2,32(sp)
    8000424c:	ec4e                	sd	s3,24(sp)
    8000424e:	e852                	sd	s4,16(sp)
    80004250:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004252:	0004a903          	lw	s2,0(s1)
    80004256:	0094ca83          	lbu	s5,9(s1)
    8000425a:	0104ba03          	ld	s4,16(s1)
    8000425e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004262:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004266:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000426a:	0001c517          	auipc	a0,0x1c
    8000426e:	a2650513          	addi	a0,a0,-1498 # 8001fc90 <ftable>
    80004272:	9f5fc0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    80004276:	4785                	li	a5,1
    80004278:	04f90063          	beq	s2,a5,800042b8 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000427c:	3979                	addiw	s2,s2,-2
    8000427e:	4785                	li	a5,1
    80004280:	0527f563          	bgeu	a5,s2,800042ca <fileclose+0xaa>
    80004284:	7902                	ld	s2,32(sp)
    80004286:	69e2                	ld	s3,24(sp)
    80004288:	6a42                	ld	s4,16(sp)
    8000428a:	6aa2                	ld	s5,8(sp)
    8000428c:	a00d                	j	800042ae <fileclose+0x8e>
    8000428e:	f04a                	sd	s2,32(sp)
    80004290:	ec4e                	sd	s3,24(sp)
    80004292:	e852                	sd	s4,16(sp)
    80004294:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004296:	00003517          	auipc	a0,0x3
    8000429a:	2d250513          	addi	a0,a0,722 # 80007568 <etext+0x568>
    8000429e:	d42fc0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    800042a2:	0001c517          	auipc	a0,0x1c
    800042a6:	9ee50513          	addi	a0,a0,-1554 # 8001fc90 <ftable>
    800042aa:	9bdfc0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800042ae:	70e2                	ld	ra,56(sp)
    800042b0:	7442                	ld	s0,48(sp)
    800042b2:	74a2                	ld	s1,40(sp)
    800042b4:	6121                	addi	sp,sp,64
    800042b6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800042b8:	85d6                	mv	a1,s5
    800042ba:	8552                	mv	a0,s4
    800042bc:	336000ef          	jal	800045f2 <pipeclose>
    800042c0:	7902                	ld	s2,32(sp)
    800042c2:	69e2                	ld	s3,24(sp)
    800042c4:	6a42                	ld	s4,16(sp)
    800042c6:	6aa2                	ld	s5,8(sp)
    800042c8:	b7dd                	j	800042ae <fileclose+0x8e>
    begin_op();
    800042ca:	b4bff0ef          	jal	80003e14 <begin_op>
    iput(ff.ip);
    800042ce:	854e                	mv	a0,s3
    800042d0:	adcff0ef          	jal	800035ac <iput>
    end_op();
    800042d4:	babff0ef          	jal	80003e7e <end_op>
    800042d8:	7902                	ld	s2,32(sp)
    800042da:	69e2                	ld	s3,24(sp)
    800042dc:	6a42                	ld	s4,16(sp)
    800042de:	6aa2                	ld	s5,8(sp)
    800042e0:	b7f9                	j	800042ae <fileclose+0x8e>

00000000800042e2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800042e2:	715d                	addi	sp,sp,-80
    800042e4:	e486                	sd	ra,72(sp)
    800042e6:	e0a2                	sd	s0,64(sp)
    800042e8:	fc26                	sd	s1,56(sp)
    800042ea:	f44e                	sd	s3,40(sp)
    800042ec:	0880                	addi	s0,sp,80
    800042ee:	84aa                	mv	s1,a0
    800042f0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800042f2:	ddcfd0ef          	jal	800018ce <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800042f6:	409c                	lw	a5,0(s1)
    800042f8:	37f9                	addiw	a5,a5,-2
    800042fa:	4705                	li	a4,1
    800042fc:	04f76063          	bltu	a4,a5,8000433c <filestat+0x5a>
    80004300:	f84a                	sd	s2,48(sp)
    80004302:	892a                	mv	s2,a0
    ilock(f->ip);
    80004304:	6c88                	ld	a0,24(s1)
    80004306:	924ff0ef          	jal	8000342a <ilock>
    stati(f->ip, &st);
    8000430a:	fb840593          	addi	a1,s0,-72
    8000430e:	6c88                	ld	a0,24(s1)
    80004310:	c80ff0ef          	jal	80003790 <stati>
    iunlock(f->ip);
    80004314:	6c88                	ld	a0,24(s1)
    80004316:	9c2ff0ef          	jal	800034d8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000431a:	46e1                	li	a3,24
    8000431c:	fb840613          	addi	a2,s0,-72
    80004320:	85ce                	mv	a1,s3
    80004322:	05093503          	ld	a0,80(s2)
    80004326:	abcfd0ef          	jal	800015e2 <copyout>
    8000432a:	41f5551b          	sraiw	a0,a0,0x1f
    8000432e:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004330:	60a6                	ld	ra,72(sp)
    80004332:	6406                	ld	s0,64(sp)
    80004334:	74e2                	ld	s1,56(sp)
    80004336:	79a2                	ld	s3,40(sp)
    80004338:	6161                	addi	sp,sp,80
    8000433a:	8082                	ret
  return -1;
    8000433c:	557d                	li	a0,-1
    8000433e:	bfcd                	j	80004330 <filestat+0x4e>

0000000080004340 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004340:	7179                	addi	sp,sp,-48
    80004342:	f406                	sd	ra,40(sp)
    80004344:	f022                	sd	s0,32(sp)
    80004346:	e84a                	sd	s2,16(sp)
    80004348:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000434a:	00854783          	lbu	a5,8(a0)
    8000434e:	cfd1                	beqz	a5,800043ea <fileread+0xaa>
    80004350:	ec26                	sd	s1,24(sp)
    80004352:	e44e                	sd	s3,8(sp)
    80004354:	84aa                	mv	s1,a0
    80004356:	89ae                	mv	s3,a1
    80004358:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000435a:	411c                	lw	a5,0(a0)
    8000435c:	4705                	li	a4,1
    8000435e:	04e78363          	beq	a5,a4,800043a4 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004362:	470d                	li	a4,3
    80004364:	04e78763          	beq	a5,a4,800043b2 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004368:	4709                	li	a4,2
    8000436a:	06e79a63          	bne	a5,a4,800043de <fileread+0x9e>
    ilock(f->ip);
    8000436e:	6d08                	ld	a0,24(a0)
    80004370:	8baff0ef          	jal	8000342a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004374:	874a                	mv	a4,s2
    80004376:	5094                	lw	a3,32(s1)
    80004378:	864e                	mv	a2,s3
    8000437a:	4585                	li	a1,1
    8000437c:	6c88                	ld	a0,24(s1)
    8000437e:	c3cff0ef          	jal	800037ba <readi>
    80004382:	892a                	mv	s2,a0
    80004384:	00a05563          	blez	a0,8000438e <fileread+0x4e>
      f->off += r;
    80004388:	509c                	lw	a5,32(s1)
    8000438a:	9fa9                	addw	a5,a5,a0
    8000438c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000438e:	6c88                	ld	a0,24(s1)
    80004390:	948ff0ef          	jal	800034d8 <iunlock>
    80004394:	64e2                	ld	s1,24(sp)
    80004396:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004398:	854a                	mv	a0,s2
    8000439a:	70a2                	ld	ra,40(sp)
    8000439c:	7402                	ld	s0,32(sp)
    8000439e:	6942                	ld	s2,16(sp)
    800043a0:	6145                	addi	sp,sp,48
    800043a2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800043a4:	6908                	ld	a0,16(a0)
    800043a6:	388000ef          	jal	8000472e <piperead>
    800043aa:	892a                	mv	s2,a0
    800043ac:	64e2                	ld	s1,24(sp)
    800043ae:	69a2                	ld	s3,8(sp)
    800043b0:	b7e5                	j	80004398 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800043b2:	02451783          	lh	a5,36(a0)
    800043b6:	03079693          	slli	a3,a5,0x30
    800043ba:	92c1                	srli	a3,a3,0x30
    800043bc:	4725                	li	a4,9
    800043be:	02d76863          	bltu	a4,a3,800043ee <fileread+0xae>
    800043c2:	0792                	slli	a5,a5,0x4
    800043c4:	0001c717          	auipc	a4,0x1c
    800043c8:	82c70713          	addi	a4,a4,-2004 # 8001fbf0 <devsw>
    800043cc:	97ba                	add	a5,a5,a4
    800043ce:	639c                	ld	a5,0(a5)
    800043d0:	c39d                	beqz	a5,800043f6 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800043d2:	4505                	li	a0,1
    800043d4:	9782                	jalr	a5
    800043d6:	892a                	mv	s2,a0
    800043d8:	64e2                	ld	s1,24(sp)
    800043da:	69a2                	ld	s3,8(sp)
    800043dc:	bf75                	j	80004398 <fileread+0x58>
    panic("fileread");
    800043de:	00003517          	auipc	a0,0x3
    800043e2:	19a50513          	addi	a0,a0,410 # 80007578 <etext+0x578>
    800043e6:	bfafc0ef          	jal	800007e0 <panic>
    return -1;
    800043ea:	597d                	li	s2,-1
    800043ec:	b775                	j	80004398 <fileread+0x58>
      return -1;
    800043ee:	597d                	li	s2,-1
    800043f0:	64e2                	ld	s1,24(sp)
    800043f2:	69a2                	ld	s3,8(sp)
    800043f4:	b755                	j	80004398 <fileread+0x58>
    800043f6:	597d                	li	s2,-1
    800043f8:	64e2                	ld	s1,24(sp)
    800043fa:	69a2                	ld	s3,8(sp)
    800043fc:	bf71                	j	80004398 <fileread+0x58>

00000000800043fe <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800043fe:	00954783          	lbu	a5,9(a0)
    80004402:	10078b63          	beqz	a5,80004518 <filewrite+0x11a>
{
    80004406:	715d                	addi	sp,sp,-80
    80004408:	e486                	sd	ra,72(sp)
    8000440a:	e0a2                	sd	s0,64(sp)
    8000440c:	f84a                	sd	s2,48(sp)
    8000440e:	f052                	sd	s4,32(sp)
    80004410:	e85a                	sd	s6,16(sp)
    80004412:	0880                	addi	s0,sp,80
    80004414:	892a                	mv	s2,a0
    80004416:	8b2e                	mv	s6,a1
    80004418:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000441a:	411c                	lw	a5,0(a0)
    8000441c:	4705                	li	a4,1
    8000441e:	02e78763          	beq	a5,a4,8000444c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004422:	470d                	li	a4,3
    80004424:	02e78863          	beq	a5,a4,80004454 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004428:	4709                	li	a4,2
    8000442a:	0ce79c63          	bne	a5,a4,80004502 <filewrite+0x104>
    8000442e:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004430:	0ac05863          	blez	a2,800044e0 <filewrite+0xe2>
    80004434:	fc26                	sd	s1,56(sp)
    80004436:	ec56                	sd	s5,24(sp)
    80004438:	e45e                	sd	s7,8(sp)
    8000443a:	e062                	sd	s8,0(sp)
    int i = 0;
    8000443c:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000443e:	6b85                	lui	s7,0x1
    80004440:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004444:	6c05                	lui	s8,0x1
    80004446:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000444a:	a8b5                	j	800044c6 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    8000444c:	6908                	ld	a0,16(a0)
    8000444e:	1fc000ef          	jal	8000464a <pipewrite>
    80004452:	a04d                	j	800044f4 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004454:	02451783          	lh	a5,36(a0)
    80004458:	03079693          	slli	a3,a5,0x30
    8000445c:	92c1                	srli	a3,a3,0x30
    8000445e:	4725                	li	a4,9
    80004460:	0ad76e63          	bltu	a4,a3,8000451c <filewrite+0x11e>
    80004464:	0792                	slli	a5,a5,0x4
    80004466:	0001b717          	auipc	a4,0x1b
    8000446a:	78a70713          	addi	a4,a4,1930 # 8001fbf0 <devsw>
    8000446e:	97ba                	add	a5,a5,a4
    80004470:	679c                	ld	a5,8(a5)
    80004472:	c7dd                	beqz	a5,80004520 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004474:	4505                	li	a0,1
    80004476:	9782                	jalr	a5
    80004478:	a8b5                	j	800044f4 <filewrite+0xf6>
      if(n1 > max)
    8000447a:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    8000447e:	997ff0ef          	jal	80003e14 <begin_op>
      ilock(f->ip);
    80004482:	01893503          	ld	a0,24(s2)
    80004486:	fa5fe0ef          	jal	8000342a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000448a:	8756                	mv	a4,s5
    8000448c:	02092683          	lw	a3,32(s2)
    80004490:	01698633          	add	a2,s3,s6
    80004494:	4585                	li	a1,1
    80004496:	01893503          	ld	a0,24(s2)
    8000449a:	c1cff0ef          	jal	800038b6 <writei>
    8000449e:	84aa                	mv	s1,a0
    800044a0:	00a05763          	blez	a0,800044ae <filewrite+0xb0>
        f->off += r;
    800044a4:	02092783          	lw	a5,32(s2)
    800044a8:	9fa9                	addw	a5,a5,a0
    800044aa:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800044ae:	01893503          	ld	a0,24(s2)
    800044b2:	826ff0ef          	jal	800034d8 <iunlock>
      end_op();
    800044b6:	9c9ff0ef          	jal	80003e7e <end_op>

      if(r != n1){
    800044ba:	029a9563          	bne	s5,s1,800044e4 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800044be:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800044c2:	0149da63          	bge	s3,s4,800044d6 <filewrite+0xd8>
      int n1 = n - i;
    800044c6:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800044ca:	0004879b          	sext.w	a5,s1
    800044ce:	fafbd6e3          	bge	s7,a5,8000447a <filewrite+0x7c>
    800044d2:	84e2                	mv	s1,s8
    800044d4:	b75d                	j	8000447a <filewrite+0x7c>
    800044d6:	74e2                	ld	s1,56(sp)
    800044d8:	6ae2                	ld	s5,24(sp)
    800044da:	6ba2                	ld	s7,8(sp)
    800044dc:	6c02                	ld	s8,0(sp)
    800044de:	a039                	j	800044ec <filewrite+0xee>
    int i = 0;
    800044e0:	4981                	li	s3,0
    800044e2:	a029                	j	800044ec <filewrite+0xee>
    800044e4:	74e2                	ld	s1,56(sp)
    800044e6:	6ae2                	ld	s5,24(sp)
    800044e8:	6ba2                	ld	s7,8(sp)
    800044ea:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800044ec:	033a1c63          	bne	s4,s3,80004524 <filewrite+0x126>
    800044f0:	8552                	mv	a0,s4
    800044f2:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800044f4:	60a6                	ld	ra,72(sp)
    800044f6:	6406                	ld	s0,64(sp)
    800044f8:	7942                	ld	s2,48(sp)
    800044fa:	7a02                	ld	s4,32(sp)
    800044fc:	6b42                	ld	s6,16(sp)
    800044fe:	6161                	addi	sp,sp,80
    80004500:	8082                	ret
    80004502:	fc26                	sd	s1,56(sp)
    80004504:	f44e                	sd	s3,40(sp)
    80004506:	ec56                	sd	s5,24(sp)
    80004508:	e45e                	sd	s7,8(sp)
    8000450a:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000450c:	00003517          	auipc	a0,0x3
    80004510:	07c50513          	addi	a0,a0,124 # 80007588 <etext+0x588>
    80004514:	accfc0ef          	jal	800007e0 <panic>
    return -1;
    80004518:	557d                	li	a0,-1
}
    8000451a:	8082                	ret
      return -1;
    8000451c:	557d                	li	a0,-1
    8000451e:	bfd9                	j	800044f4 <filewrite+0xf6>
    80004520:	557d                	li	a0,-1
    80004522:	bfc9                	j	800044f4 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004524:	557d                	li	a0,-1
    80004526:	79a2                	ld	s3,40(sp)
    80004528:	b7f1                	j	800044f4 <filewrite+0xf6>

000000008000452a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000452a:	7179                	addi	sp,sp,-48
    8000452c:	f406                	sd	ra,40(sp)
    8000452e:	f022                	sd	s0,32(sp)
    80004530:	ec26                	sd	s1,24(sp)
    80004532:	e052                	sd	s4,0(sp)
    80004534:	1800                	addi	s0,sp,48
    80004536:	84aa                	mv	s1,a0
    80004538:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000453a:	0005b023          	sd	zero,0(a1)
    8000453e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004542:	c3bff0ef          	jal	8000417c <filealloc>
    80004546:	e088                	sd	a0,0(s1)
    80004548:	c549                	beqz	a0,800045d2 <pipealloc+0xa8>
    8000454a:	c33ff0ef          	jal	8000417c <filealloc>
    8000454e:	00aa3023          	sd	a0,0(s4)
    80004552:	cd25                	beqz	a0,800045ca <pipealloc+0xa0>
    80004554:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004556:	da8fc0ef          	jal	80000afe <kalloc>
    8000455a:	892a                	mv	s2,a0
    8000455c:	c12d                	beqz	a0,800045be <pipealloc+0x94>
    8000455e:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004560:	4985                	li	s3,1
    80004562:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004566:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000456a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000456e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004572:	00003597          	auipc	a1,0x3
    80004576:	02658593          	addi	a1,a1,38 # 80007598 <etext+0x598>
    8000457a:	dd4fc0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    8000457e:	609c                	ld	a5,0(s1)
    80004580:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004584:	609c                	ld	a5,0(s1)
    80004586:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000458a:	609c                	ld	a5,0(s1)
    8000458c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004590:	609c                	ld	a5,0(s1)
    80004592:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004596:	000a3783          	ld	a5,0(s4)
    8000459a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000459e:	000a3783          	ld	a5,0(s4)
    800045a2:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800045a6:	000a3783          	ld	a5,0(s4)
    800045aa:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800045ae:	000a3783          	ld	a5,0(s4)
    800045b2:	0127b823          	sd	s2,16(a5)
  return 0;
    800045b6:	4501                	li	a0,0
    800045b8:	6942                	ld	s2,16(sp)
    800045ba:	69a2                	ld	s3,8(sp)
    800045bc:	a01d                	j	800045e2 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800045be:	6088                	ld	a0,0(s1)
    800045c0:	c119                	beqz	a0,800045c6 <pipealloc+0x9c>
    800045c2:	6942                	ld	s2,16(sp)
    800045c4:	a029                	j	800045ce <pipealloc+0xa4>
    800045c6:	6942                	ld	s2,16(sp)
    800045c8:	a029                	j	800045d2 <pipealloc+0xa8>
    800045ca:	6088                	ld	a0,0(s1)
    800045cc:	c10d                	beqz	a0,800045ee <pipealloc+0xc4>
    fileclose(*f0);
    800045ce:	c53ff0ef          	jal	80004220 <fileclose>
  if(*f1)
    800045d2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800045d6:	557d                	li	a0,-1
  if(*f1)
    800045d8:	c789                	beqz	a5,800045e2 <pipealloc+0xb8>
    fileclose(*f1);
    800045da:	853e                	mv	a0,a5
    800045dc:	c45ff0ef          	jal	80004220 <fileclose>
  return -1;
    800045e0:	557d                	li	a0,-1
}
    800045e2:	70a2                	ld	ra,40(sp)
    800045e4:	7402                	ld	s0,32(sp)
    800045e6:	64e2                	ld	s1,24(sp)
    800045e8:	6a02                	ld	s4,0(sp)
    800045ea:	6145                	addi	sp,sp,48
    800045ec:	8082                	ret
  return -1;
    800045ee:	557d                	li	a0,-1
    800045f0:	bfcd                	j	800045e2 <pipealloc+0xb8>

00000000800045f2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800045f2:	1101                	addi	sp,sp,-32
    800045f4:	ec06                	sd	ra,24(sp)
    800045f6:	e822                	sd	s0,16(sp)
    800045f8:	e426                	sd	s1,8(sp)
    800045fa:	e04a                	sd	s2,0(sp)
    800045fc:	1000                	addi	s0,sp,32
    800045fe:	84aa                	mv	s1,a0
    80004600:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004602:	dccfc0ef          	jal	80000bce <acquire>
  if(writable){
    80004606:	02090763          	beqz	s2,80004634 <pipeclose+0x42>
    pi->writeopen = 0;
    8000460a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000460e:	21848513          	addi	a0,s1,536
    80004612:	913fd0ef          	jal	80001f24 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004616:	2204b783          	ld	a5,544(s1)
    8000461a:	e785                	bnez	a5,80004642 <pipeclose+0x50>
    release(&pi->lock);
    8000461c:	8526                	mv	a0,s1
    8000461e:	e48fc0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    80004622:	8526                	mv	a0,s1
    80004624:	bf8fc0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    80004628:	60e2                	ld	ra,24(sp)
    8000462a:	6442                	ld	s0,16(sp)
    8000462c:	64a2                	ld	s1,8(sp)
    8000462e:	6902                	ld	s2,0(sp)
    80004630:	6105                	addi	sp,sp,32
    80004632:	8082                	ret
    pi->readopen = 0;
    80004634:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004638:	21c48513          	addi	a0,s1,540
    8000463c:	8e9fd0ef          	jal	80001f24 <wakeup>
    80004640:	bfd9                	j	80004616 <pipeclose+0x24>
    release(&pi->lock);
    80004642:	8526                	mv	a0,s1
    80004644:	e22fc0ef          	jal	80000c66 <release>
}
    80004648:	b7c5                	j	80004628 <pipeclose+0x36>

000000008000464a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000464a:	711d                	addi	sp,sp,-96
    8000464c:	ec86                	sd	ra,88(sp)
    8000464e:	e8a2                	sd	s0,80(sp)
    80004650:	e4a6                	sd	s1,72(sp)
    80004652:	e0ca                	sd	s2,64(sp)
    80004654:	fc4e                	sd	s3,56(sp)
    80004656:	f852                	sd	s4,48(sp)
    80004658:	f456                	sd	s5,40(sp)
    8000465a:	1080                	addi	s0,sp,96
    8000465c:	84aa                	mv	s1,a0
    8000465e:	8aae                	mv	s5,a1
    80004660:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004662:	a6cfd0ef          	jal	800018ce <myproc>
    80004666:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004668:	8526                	mv	a0,s1
    8000466a:	d64fc0ef          	jal	80000bce <acquire>
  while(i < n){
    8000466e:	0b405a63          	blez	s4,80004722 <pipewrite+0xd8>
    80004672:	f05a                	sd	s6,32(sp)
    80004674:	ec5e                	sd	s7,24(sp)
    80004676:	e862                	sd	s8,16(sp)
  int i = 0;
    80004678:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000467a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000467c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004680:	21c48b93          	addi	s7,s1,540
    80004684:	a81d                	j	800046ba <pipewrite+0x70>
      release(&pi->lock);
    80004686:	8526                	mv	a0,s1
    80004688:	ddefc0ef          	jal	80000c66 <release>
      return -1;
    8000468c:	597d                	li	s2,-1
    8000468e:	7b02                	ld	s6,32(sp)
    80004690:	6be2                	ld	s7,24(sp)
    80004692:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004694:	854a                	mv	a0,s2
    80004696:	60e6                	ld	ra,88(sp)
    80004698:	6446                	ld	s0,80(sp)
    8000469a:	64a6                	ld	s1,72(sp)
    8000469c:	6906                	ld	s2,64(sp)
    8000469e:	79e2                	ld	s3,56(sp)
    800046a0:	7a42                	ld	s4,48(sp)
    800046a2:	7aa2                	ld	s5,40(sp)
    800046a4:	6125                	addi	sp,sp,96
    800046a6:	8082                	ret
      wakeup(&pi->nread);
    800046a8:	8562                	mv	a0,s8
    800046aa:	87bfd0ef          	jal	80001f24 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800046ae:	85a6                	mv	a1,s1
    800046b0:	855e                	mv	a0,s7
    800046b2:	827fd0ef          	jal	80001ed8 <sleep>
  while(i < n){
    800046b6:	05495b63          	bge	s2,s4,8000470c <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    800046ba:	2204a783          	lw	a5,544(s1)
    800046be:	d7e1                	beqz	a5,80004686 <pipewrite+0x3c>
    800046c0:	854e                	mv	a0,s3
    800046c2:	a4ffd0ef          	jal	80002110 <killed>
    800046c6:	f161                	bnez	a0,80004686 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800046c8:	2184a783          	lw	a5,536(s1)
    800046cc:	21c4a703          	lw	a4,540(s1)
    800046d0:	2007879b          	addiw	a5,a5,512
    800046d4:	fcf70ae3          	beq	a4,a5,800046a8 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800046d8:	4685                	li	a3,1
    800046da:	01590633          	add	a2,s2,s5
    800046de:	faf40593          	addi	a1,s0,-81
    800046e2:	0509b503          	ld	a0,80(s3)
    800046e6:	fe1fc0ef          	jal	800016c6 <copyin>
    800046ea:	03650e63          	beq	a0,s6,80004726 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800046ee:	21c4a783          	lw	a5,540(s1)
    800046f2:	0017871b          	addiw	a4,a5,1
    800046f6:	20e4ae23          	sw	a4,540(s1)
    800046fa:	1ff7f793          	andi	a5,a5,511
    800046fe:	97a6                	add	a5,a5,s1
    80004700:	faf44703          	lbu	a4,-81(s0)
    80004704:	00e78c23          	sb	a4,24(a5)
      i++;
    80004708:	2905                	addiw	s2,s2,1
    8000470a:	b775                	j	800046b6 <pipewrite+0x6c>
    8000470c:	7b02                	ld	s6,32(sp)
    8000470e:	6be2                	ld	s7,24(sp)
    80004710:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004712:	21848513          	addi	a0,s1,536
    80004716:	80ffd0ef          	jal	80001f24 <wakeup>
  release(&pi->lock);
    8000471a:	8526                	mv	a0,s1
    8000471c:	d4afc0ef          	jal	80000c66 <release>
  return i;
    80004720:	bf95                	j	80004694 <pipewrite+0x4a>
  int i = 0;
    80004722:	4901                	li	s2,0
    80004724:	b7fd                	j	80004712 <pipewrite+0xc8>
    80004726:	7b02                	ld	s6,32(sp)
    80004728:	6be2                	ld	s7,24(sp)
    8000472a:	6c42                	ld	s8,16(sp)
    8000472c:	b7dd                	j	80004712 <pipewrite+0xc8>

000000008000472e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000472e:	715d                	addi	sp,sp,-80
    80004730:	e486                	sd	ra,72(sp)
    80004732:	e0a2                	sd	s0,64(sp)
    80004734:	fc26                	sd	s1,56(sp)
    80004736:	f84a                	sd	s2,48(sp)
    80004738:	f44e                	sd	s3,40(sp)
    8000473a:	f052                	sd	s4,32(sp)
    8000473c:	ec56                	sd	s5,24(sp)
    8000473e:	0880                	addi	s0,sp,80
    80004740:	84aa                	mv	s1,a0
    80004742:	892e                	mv	s2,a1
    80004744:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004746:	988fd0ef          	jal	800018ce <myproc>
    8000474a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000474c:	8526                	mv	a0,s1
    8000474e:	c80fc0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004752:	2184a703          	lw	a4,536(s1)
    80004756:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000475a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000475e:	02f71563          	bne	a4,a5,80004788 <piperead+0x5a>
    80004762:	2244a783          	lw	a5,548(s1)
    80004766:	cb85                	beqz	a5,80004796 <piperead+0x68>
    if(killed(pr)){
    80004768:	8552                	mv	a0,s4
    8000476a:	9a7fd0ef          	jal	80002110 <killed>
    8000476e:	ed19                	bnez	a0,8000478c <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004770:	85a6                	mv	a1,s1
    80004772:	854e                	mv	a0,s3
    80004774:	f64fd0ef          	jal	80001ed8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004778:	2184a703          	lw	a4,536(s1)
    8000477c:	21c4a783          	lw	a5,540(s1)
    80004780:	fef701e3          	beq	a4,a5,80004762 <piperead+0x34>
    80004784:	e85a                	sd	s6,16(sp)
    80004786:	a809                	j	80004798 <piperead+0x6a>
    80004788:	e85a                	sd	s6,16(sp)
    8000478a:	a039                	j	80004798 <piperead+0x6a>
      release(&pi->lock);
    8000478c:	8526                	mv	a0,s1
    8000478e:	cd8fc0ef          	jal	80000c66 <release>
      return -1;
    80004792:	59fd                	li	s3,-1
    80004794:	a8b9                	j	800047f2 <piperead+0xc4>
    80004796:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004798:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000479a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000479c:	05505363          	blez	s5,800047e2 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    800047a0:	2184a783          	lw	a5,536(s1)
    800047a4:	21c4a703          	lw	a4,540(s1)
    800047a8:	02f70d63          	beq	a4,a5,800047e2 <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    800047ac:	1ff7f793          	andi	a5,a5,511
    800047b0:	97a6                	add	a5,a5,s1
    800047b2:	0187c783          	lbu	a5,24(a5)
    800047b6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800047ba:	4685                	li	a3,1
    800047bc:	fbf40613          	addi	a2,s0,-65
    800047c0:	85ca                	mv	a1,s2
    800047c2:	050a3503          	ld	a0,80(s4)
    800047c6:	e1dfc0ef          	jal	800015e2 <copyout>
    800047ca:	03650e63          	beq	a0,s6,80004806 <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800047ce:	2184a783          	lw	a5,536(s1)
    800047d2:	2785                	addiw	a5,a5,1
    800047d4:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800047d8:	2985                	addiw	s3,s3,1
    800047da:	0905                	addi	s2,s2,1
    800047dc:	fd3a92e3          	bne	s5,s3,800047a0 <piperead+0x72>
    800047e0:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800047e2:	21c48513          	addi	a0,s1,540
    800047e6:	f3efd0ef          	jal	80001f24 <wakeup>
  release(&pi->lock);
    800047ea:	8526                	mv	a0,s1
    800047ec:	c7afc0ef          	jal	80000c66 <release>
    800047f0:	6b42                	ld	s6,16(sp)
  return i;
}
    800047f2:	854e                	mv	a0,s3
    800047f4:	60a6                	ld	ra,72(sp)
    800047f6:	6406                	ld	s0,64(sp)
    800047f8:	74e2                	ld	s1,56(sp)
    800047fa:	7942                	ld	s2,48(sp)
    800047fc:	79a2                	ld	s3,40(sp)
    800047fe:	7a02                	ld	s4,32(sp)
    80004800:	6ae2                	ld	s5,24(sp)
    80004802:	6161                	addi	sp,sp,80
    80004804:	8082                	ret
      if(i == 0)
    80004806:	fc099ee3          	bnez	s3,800047e2 <piperead+0xb4>
        i = -1;
    8000480a:	89aa                	mv	s3,a0
    8000480c:	bfd9                	j	800047e2 <piperead+0xb4>

000000008000480e <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    8000480e:	1141                	addi	sp,sp,-16
    80004810:	e422                	sd	s0,8(sp)
    80004812:	0800                	addi	s0,sp,16
    80004814:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004816:	8905                	andi	a0,a0,1
    80004818:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    8000481a:	8b89                	andi	a5,a5,2
    8000481c:	c399                	beqz	a5,80004822 <flags2perm+0x14>
      perm |= PTE_W;
    8000481e:	00456513          	ori	a0,a0,4
    return perm;
}
    80004822:	6422                	ld	s0,8(sp)
    80004824:	0141                	addi	sp,sp,16
    80004826:	8082                	ret

0000000080004828 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004828:	df010113          	addi	sp,sp,-528
    8000482c:	20113423          	sd	ra,520(sp)
    80004830:	20813023          	sd	s0,512(sp)
    80004834:	ffa6                	sd	s1,504(sp)
    80004836:	fbca                	sd	s2,496(sp)
    80004838:	0c00                	addi	s0,sp,528
    8000483a:	892a                	mv	s2,a0
    8000483c:	dea43c23          	sd	a0,-520(s0)
    80004840:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004844:	88afd0ef          	jal	800018ce <myproc>
    80004848:	84aa                	mv	s1,a0

  begin_op();
    8000484a:	dcaff0ef          	jal	80003e14 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    8000484e:	854a                	mv	a0,s2
    80004850:	bf0ff0ef          	jal	80003c40 <namei>
    80004854:	c931                	beqz	a0,800048a8 <kexec+0x80>
    80004856:	f3d2                	sd	s4,480(sp)
    80004858:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000485a:	bd1fe0ef          	jal	8000342a <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000485e:	04000713          	li	a4,64
    80004862:	4681                	li	a3,0
    80004864:	e5040613          	addi	a2,s0,-432
    80004868:	4581                	li	a1,0
    8000486a:	8552                	mv	a0,s4
    8000486c:	f4ffe0ef          	jal	800037ba <readi>
    80004870:	04000793          	li	a5,64
    80004874:	00f51a63          	bne	a0,a5,80004888 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004878:	e5042703          	lw	a4,-432(s0)
    8000487c:	464c47b7          	lui	a5,0x464c4
    80004880:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004884:	02f70663          	beq	a4,a5,800048b0 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004888:	8552                	mv	a0,s4
    8000488a:	dabfe0ef          	jal	80003634 <iunlockput>
    end_op();
    8000488e:	df0ff0ef          	jal	80003e7e <end_op>
  }
  return -1;
    80004892:	557d                	li	a0,-1
    80004894:	7a1e                	ld	s4,480(sp)
}
    80004896:	20813083          	ld	ra,520(sp)
    8000489a:	20013403          	ld	s0,512(sp)
    8000489e:	74fe                	ld	s1,504(sp)
    800048a0:	795e                	ld	s2,496(sp)
    800048a2:	21010113          	addi	sp,sp,528
    800048a6:	8082                	ret
    end_op();
    800048a8:	dd6ff0ef          	jal	80003e7e <end_op>
    return -1;
    800048ac:	557d                	li	a0,-1
    800048ae:	b7e5                	j	80004896 <kexec+0x6e>
    800048b0:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800048b2:	8526                	mv	a0,s1
    800048b4:	920fd0ef          	jal	800019d4 <proc_pagetable>
    800048b8:	8b2a                	mv	s6,a0
    800048ba:	2c050b63          	beqz	a0,80004b90 <kexec+0x368>
    800048be:	f7ce                	sd	s3,488(sp)
    800048c0:	efd6                	sd	s5,472(sp)
    800048c2:	e7de                	sd	s7,456(sp)
    800048c4:	e3e2                	sd	s8,448(sp)
    800048c6:	ff66                	sd	s9,440(sp)
    800048c8:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800048ca:	e7042d03          	lw	s10,-400(s0)
    800048ce:	e8845783          	lhu	a5,-376(s0)
    800048d2:	12078963          	beqz	a5,80004a04 <kexec+0x1dc>
    800048d6:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800048d8:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800048da:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800048dc:	6c85                	lui	s9,0x1
    800048de:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800048e2:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800048e6:	6a85                	lui	s5,0x1
    800048e8:	a085                	j	80004948 <kexec+0x120>
      panic("loadseg: address should exist");
    800048ea:	00003517          	auipc	a0,0x3
    800048ee:	cb650513          	addi	a0,a0,-842 # 800075a0 <etext+0x5a0>
    800048f2:	eeffb0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    800048f6:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800048f8:	8726                	mv	a4,s1
    800048fa:	012c06bb          	addw	a3,s8,s2
    800048fe:	4581                	li	a1,0
    80004900:	8552                	mv	a0,s4
    80004902:	eb9fe0ef          	jal	800037ba <readi>
    80004906:	2501                	sext.w	a0,a0
    80004908:	24a49a63          	bne	s1,a0,80004b5c <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    8000490c:	012a893b          	addw	s2,s5,s2
    80004910:	03397363          	bgeu	s2,s3,80004936 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004914:	02091593          	slli	a1,s2,0x20
    80004918:	9181                	srli	a1,a1,0x20
    8000491a:	95de                	add	a1,a1,s7
    8000491c:	855a                	mv	a0,s6
    8000491e:	e92fc0ef          	jal	80000fb0 <walkaddr>
    80004922:	862a                	mv	a2,a0
    if(pa == 0)
    80004924:	d179                	beqz	a0,800048ea <kexec+0xc2>
    if(sz - i < PGSIZE)
    80004926:	412984bb          	subw	s1,s3,s2
    8000492a:	0004879b          	sext.w	a5,s1
    8000492e:	fcfcf4e3          	bgeu	s9,a5,800048f6 <kexec+0xce>
    80004932:	84d6                	mv	s1,s5
    80004934:	b7c9                	j	800048f6 <kexec+0xce>
    sz = sz1;
    80004936:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000493a:	2d85                	addiw	s11,s11,1
    8000493c:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004940:	e8845783          	lhu	a5,-376(s0)
    80004944:	08fdd063          	bge	s11,a5,800049c4 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004948:	2d01                	sext.w	s10,s10
    8000494a:	03800713          	li	a4,56
    8000494e:	86ea                	mv	a3,s10
    80004950:	e1840613          	addi	a2,s0,-488
    80004954:	4581                	li	a1,0
    80004956:	8552                	mv	a0,s4
    80004958:	e63fe0ef          	jal	800037ba <readi>
    8000495c:	03800793          	li	a5,56
    80004960:	1cf51663          	bne	a0,a5,80004b2c <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004964:	e1842783          	lw	a5,-488(s0)
    80004968:	4705                	li	a4,1
    8000496a:	fce798e3          	bne	a5,a4,8000493a <kexec+0x112>
    if(ph.memsz < ph.filesz)
    8000496e:	e4043483          	ld	s1,-448(s0)
    80004972:	e3843783          	ld	a5,-456(s0)
    80004976:	1af4ef63          	bltu	s1,a5,80004b34 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000497a:	e2843783          	ld	a5,-472(s0)
    8000497e:	94be                	add	s1,s1,a5
    80004980:	1af4ee63          	bltu	s1,a5,80004b3c <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004984:	df043703          	ld	a4,-528(s0)
    80004988:	8ff9                	and	a5,a5,a4
    8000498a:	1a079d63          	bnez	a5,80004b44 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000498e:	e1c42503          	lw	a0,-484(s0)
    80004992:	e7dff0ef          	jal	8000480e <flags2perm>
    80004996:	86aa                	mv	a3,a0
    80004998:	8626                	mv	a2,s1
    8000499a:	85ca                	mv	a1,s2
    8000499c:	855a                	mv	a0,s6
    8000499e:	8ebfc0ef          	jal	80001288 <uvmalloc>
    800049a2:	e0a43423          	sd	a0,-504(s0)
    800049a6:	1a050363          	beqz	a0,80004b4c <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800049aa:	e2843b83          	ld	s7,-472(s0)
    800049ae:	e2042c03          	lw	s8,-480(s0)
    800049b2:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800049b6:	00098463          	beqz	s3,800049be <kexec+0x196>
    800049ba:	4901                	li	s2,0
    800049bc:	bfa1                	j	80004914 <kexec+0xec>
    sz = sz1;
    800049be:	e0843903          	ld	s2,-504(s0)
    800049c2:	bfa5                	j	8000493a <kexec+0x112>
    800049c4:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800049c6:	8552                	mv	a0,s4
    800049c8:	c6dfe0ef          	jal	80003634 <iunlockput>
  end_op();
    800049cc:	cb2ff0ef          	jal	80003e7e <end_op>
  p = myproc();
    800049d0:	efffc0ef          	jal	800018ce <myproc>
    800049d4:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800049d6:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800049da:	6985                	lui	s3,0x1
    800049dc:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800049de:	99ca                	add	s3,s3,s2
    800049e0:	77fd                	lui	a5,0xfffff
    800049e2:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800049e6:	4691                	li	a3,4
    800049e8:	6609                	lui	a2,0x2
    800049ea:	964e                	add	a2,a2,s3
    800049ec:	85ce                	mv	a1,s3
    800049ee:	855a                	mv	a0,s6
    800049f0:	899fc0ef          	jal	80001288 <uvmalloc>
    800049f4:	892a                	mv	s2,a0
    800049f6:	e0a43423          	sd	a0,-504(s0)
    800049fa:	e519                	bnez	a0,80004a08 <kexec+0x1e0>
  if(pagetable)
    800049fc:	e1343423          	sd	s3,-504(s0)
    80004a00:	4a01                	li	s4,0
    80004a02:	aab1                	j	80004b5e <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a04:	4901                	li	s2,0
    80004a06:	b7c1                	j	800049c6 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004a08:	75f9                	lui	a1,0xffffe
    80004a0a:	95aa                	add	a1,a1,a0
    80004a0c:	855a                	mv	a0,s6
    80004a0e:	a51fc0ef          	jal	8000145e <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004a12:	7bfd                	lui	s7,0xfffff
    80004a14:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004a16:	e0043783          	ld	a5,-512(s0)
    80004a1a:	6388                	ld	a0,0(a5)
    80004a1c:	cd39                	beqz	a0,80004a7a <kexec+0x252>
    80004a1e:	e9040993          	addi	s3,s0,-368
    80004a22:	f9040c13          	addi	s8,s0,-112
    80004a26:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004a28:	beafc0ef          	jal	80000e12 <strlen>
    80004a2c:	0015079b          	addiw	a5,a0,1
    80004a30:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004a34:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004a38:	11796e63          	bltu	s2,s7,80004b54 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004a3c:	e0043d03          	ld	s10,-512(s0)
    80004a40:	000d3a03          	ld	s4,0(s10)
    80004a44:	8552                	mv	a0,s4
    80004a46:	bccfc0ef          	jal	80000e12 <strlen>
    80004a4a:	0015069b          	addiw	a3,a0,1
    80004a4e:	8652                	mv	a2,s4
    80004a50:	85ca                	mv	a1,s2
    80004a52:	855a                	mv	a0,s6
    80004a54:	b8ffc0ef          	jal	800015e2 <copyout>
    80004a58:	10054063          	bltz	a0,80004b58 <kexec+0x330>
    ustack[argc] = sp;
    80004a5c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004a60:	0485                	addi	s1,s1,1
    80004a62:	008d0793          	addi	a5,s10,8
    80004a66:	e0f43023          	sd	a5,-512(s0)
    80004a6a:	008d3503          	ld	a0,8(s10)
    80004a6e:	c909                	beqz	a0,80004a80 <kexec+0x258>
    if(argc >= MAXARG)
    80004a70:	09a1                	addi	s3,s3,8
    80004a72:	fb899be3          	bne	s3,s8,80004a28 <kexec+0x200>
  ip = 0;
    80004a76:	4a01                	li	s4,0
    80004a78:	a0dd                	j	80004b5e <kexec+0x336>
  sp = sz;
    80004a7a:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004a7e:	4481                	li	s1,0
  ustack[argc] = 0;
    80004a80:	00349793          	slli	a5,s1,0x3
    80004a84:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffde208>
    80004a88:	97a2                	add	a5,a5,s0
    80004a8a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004a8e:	00148693          	addi	a3,s1,1
    80004a92:	068e                	slli	a3,a3,0x3
    80004a94:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004a98:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004a9c:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004aa0:	f5796ee3          	bltu	s2,s7,800049fc <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004aa4:	e9040613          	addi	a2,s0,-368
    80004aa8:	85ca                	mv	a1,s2
    80004aaa:	855a                	mv	a0,s6
    80004aac:	b37fc0ef          	jal	800015e2 <copyout>
    80004ab0:	0e054263          	bltz	a0,80004b94 <kexec+0x36c>
  p->trapframe->a1 = sp;
    80004ab4:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004ab8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004abc:	df843783          	ld	a5,-520(s0)
    80004ac0:	0007c703          	lbu	a4,0(a5)
    80004ac4:	cf11                	beqz	a4,80004ae0 <kexec+0x2b8>
    80004ac6:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004ac8:	02f00693          	li	a3,47
    80004acc:	a039                	j	80004ada <kexec+0x2b2>
      last = s+1;
    80004ace:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004ad2:	0785                	addi	a5,a5,1
    80004ad4:	fff7c703          	lbu	a4,-1(a5)
    80004ad8:	c701                	beqz	a4,80004ae0 <kexec+0x2b8>
    if(*s == '/')
    80004ada:	fed71ce3          	bne	a4,a3,80004ad2 <kexec+0x2aa>
    80004ade:	bfc5                	j	80004ace <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004ae0:	4641                	li	a2,16
    80004ae2:	df843583          	ld	a1,-520(s0)
    80004ae6:	158a8513          	addi	a0,s5,344
    80004aea:	af6fc0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    80004aee:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004af2:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004af6:	e0843783          	ld	a5,-504(s0)
    80004afa:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004afe:	058ab783          	ld	a5,88(s5)
    80004b02:	e6843703          	ld	a4,-408(s0)
    80004b06:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004b08:	058ab783          	ld	a5,88(s5)
    80004b0c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004b10:	85e6                	mv	a1,s9
    80004b12:	f47fc0ef          	jal	80001a58 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004b16:	0004851b          	sext.w	a0,s1
    80004b1a:	79be                	ld	s3,488(sp)
    80004b1c:	7a1e                	ld	s4,480(sp)
    80004b1e:	6afe                	ld	s5,472(sp)
    80004b20:	6b5e                	ld	s6,464(sp)
    80004b22:	6bbe                	ld	s7,456(sp)
    80004b24:	6c1e                	ld	s8,448(sp)
    80004b26:	7cfa                	ld	s9,440(sp)
    80004b28:	7d5a                	ld	s10,432(sp)
    80004b2a:	b3b5                	j	80004896 <kexec+0x6e>
    80004b2c:	e1243423          	sd	s2,-504(s0)
    80004b30:	7dba                	ld	s11,424(sp)
    80004b32:	a035                	j	80004b5e <kexec+0x336>
    80004b34:	e1243423          	sd	s2,-504(s0)
    80004b38:	7dba                	ld	s11,424(sp)
    80004b3a:	a015                	j	80004b5e <kexec+0x336>
    80004b3c:	e1243423          	sd	s2,-504(s0)
    80004b40:	7dba                	ld	s11,424(sp)
    80004b42:	a831                	j	80004b5e <kexec+0x336>
    80004b44:	e1243423          	sd	s2,-504(s0)
    80004b48:	7dba                	ld	s11,424(sp)
    80004b4a:	a811                	j	80004b5e <kexec+0x336>
    80004b4c:	e1243423          	sd	s2,-504(s0)
    80004b50:	7dba                	ld	s11,424(sp)
    80004b52:	a031                	j	80004b5e <kexec+0x336>
  ip = 0;
    80004b54:	4a01                	li	s4,0
    80004b56:	a021                	j	80004b5e <kexec+0x336>
    80004b58:	4a01                	li	s4,0
  if(pagetable)
    80004b5a:	a011                	j	80004b5e <kexec+0x336>
    80004b5c:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004b5e:	e0843583          	ld	a1,-504(s0)
    80004b62:	855a                	mv	a0,s6
    80004b64:	ef5fc0ef          	jal	80001a58 <proc_freepagetable>
  return -1;
    80004b68:	557d                	li	a0,-1
  if(ip){
    80004b6a:	000a1b63          	bnez	s4,80004b80 <kexec+0x358>
    80004b6e:	79be                	ld	s3,488(sp)
    80004b70:	7a1e                	ld	s4,480(sp)
    80004b72:	6afe                	ld	s5,472(sp)
    80004b74:	6b5e                	ld	s6,464(sp)
    80004b76:	6bbe                	ld	s7,456(sp)
    80004b78:	6c1e                	ld	s8,448(sp)
    80004b7a:	7cfa                	ld	s9,440(sp)
    80004b7c:	7d5a                	ld	s10,432(sp)
    80004b7e:	bb21                	j	80004896 <kexec+0x6e>
    80004b80:	79be                	ld	s3,488(sp)
    80004b82:	6afe                	ld	s5,472(sp)
    80004b84:	6b5e                	ld	s6,464(sp)
    80004b86:	6bbe                	ld	s7,456(sp)
    80004b88:	6c1e                	ld	s8,448(sp)
    80004b8a:	7cfa                	ld	s9,440(sp)
    80004b8c:	7d5a                	ld	s10,432(sp)
    80004b8e:	b9ed                	j	80004888 <kexec+0x60>
    80004b90:	6b5e                	ld	s6,464(sp)
    80004b92:	b9dd                	j	80004888 <kexec+0x60>
  sz = sz1;
    80004b94:	e0843983          	ld	s3,-504(s0)
    80004b98:	b595                	j	800049fc <kexec+0x1d4>

0000000080004b9a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004b9a:	7179                	addi	sp,sp,-48
    80004b9c:	f406                	sd	ra,40(sp)
    80004b9e:	f022                	sd	s0,32(sp)
    80004ba0:	ec26                	sd	s1,24(sp)
    80004ba2:	e84a                	sd	s2,16(sp)
    80004ba4:	1800                	addi	s0,sp,48
    80004ba6:	892e                	mv	s2,a1
    80004ba8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004baa:	fdc40593          	addi	a1,s0,-36
    80004bae:	c2ffd0ef          	jal	800027dc <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004bb2:	fdc42703          	lw	a4,-36(s0)
    80004bb6:	47bd                	li	a5,15
    80004bb8:	02e7e963          	bltu	a5,a4,80004bea <argfd+0x50>
    80004bbc:	d13fc0ef          	jal	800018ce <myproc>
    80004bc0:	fdc42703          	lw	a4,-36(s0)
    80004bc4:	01a70793          	addi	a5,a4,26
    80004bc8:	078e                	slli	a5,a5,0x3
    80004bca:	953e                	add	a0,a0,a5
    80004bcc:	611c                	ld	a5,0(a0)
    80004bce:	c385                	beqz	a5,80004bee <argfd+0x54>
    return -1;
  if(pfd)
    80004bd0:	00090463          	beqz	s2,80004bd8 <argfd+0x3e>
    *pfd = fd;
    80004bd4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004bd8:	4501                	li	a0,0
  if(pf)
    80004bda:	c091                	beqz	s1,80004bde <argfd+0x44>
    *pf = f;
    80004bdc:	e09c                	sd	a5,0(s1)
}
    80004bde:	70a2                	ld	ra,40(sp)
    80004be0:	7402                	ld	s0,32(sp)
    80004be2:	64e2                	ld	s1,24(sp)
    80004be4:	6942                	ld	s2,16(sp)
    80004be6:	6145                	addi	sp,sp,48
    80004be8:	8082                	ret
    return -1;
    80004bea:	557d                	li	a0,-1
    80004bec:	bfcd                	j	80004bde <argfd+0x44>
    80004bee:	557d                	li	a0,-1
    80004bf0:	b7fd                	j	80004bde <argfd+0x44>

0000000080004bf2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004bf2:	1101                	addi	sp,sp,-32
    80004bf4:	ec06                	sd	ra,24(sp)
    80004bf6:	e822                	sd	s0,16(sp)
    80004bf8:	e426                	sd	s1,8(sp)
    80004bfa:	1000                	addi	s0,sp,32
    80004bfc:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004bfe:	cd1fc0ef          	jal	800018ce <myproc>
    80004c02:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004c04:	0d050793          	addi	a5,a0,208
    80004c08:	4501                	li	a0,0
    80004c0a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004c0c:	6398                	ld	a4,0(a5)
    80004c0e:	cb19                	beqz	a4,80004c24 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004c10:	2505                	addiw	a0,a0,1
    80004c12:	07a1                	addi	a5,a5,8
    80004c14:	fed51ce3          	bne	a0,a3,80004c0c <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004c18:	557d                	li	a0,-1
}
    80004c1a:	60e2                	ld	ra,24(sp)
    80004c1c:	6442                	ld	s0,16(sp)
    80004c1e:	64a2                	ld	s1,8(sp)
    80004c20:	6105                	addi	sp,sp,32
    80004c22:	8082                	ret
      p->ofile[fd] = f;
    80004c24:	01a50793          	addi	a5,a0,26
    80004c28:	078e                	slli	a5,a5,0x3
    80004c2a:	963e                	add	a2,a2,a5
    80004c2c:	e204                	sd	s1,0(a2)
      return fd;
    80004c2e:	b7f5                	j	80004c1a <fdalloc+0x28>

0000000080004c30 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004c30:	715d                	addi	sp,sp,-80
    80004c32:	e486                	sd	ra,72(sp)
    80004c34:	e0a2                	sd	s0,64(sp)
    80004c36:	fc26                	sd	s1,56(sp)
    80004c38:	f84a                	sd	s2,48(sp)
    80004c3a:	f44e                	sd	s3,40(sp)
    80004c3c:	ec56                	sd	s5,24(sp)
    80004c3e:	e85a                	sd	s6,16(sp)
    80004c40:	0880                	addi	s0,sp,80
    80004c42:	8b2e                	mv	s6,a1
    80004c44:	89b2                	mv	s3,a2
    80004c46:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004c48:	fb040593          	addi	a1,s0,-80
    80004c4c:	80eff0ef          	jal	80003c5a <nameiparent>
    80004c50:	84aa                	mv	s1,a0
    80004c52:	10050a63          	beqz	a0,80004d66 <create+0x136>
    return 0;

  ilock(dp);
    80004c56:	fd4fe0ef          	jal	8000342a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004c5a:	4601                	li	a2,0
    80004c5c:	fb040593          	addi	a1,s0,-80
    80004c60:	8526                	mv	a0,s1
    80004c62:	d79fe0ef          	jal	800039da <dirlookup>
    80004c66:	8aaa                	mv	s5,a0
    80004c68:	c129                	beqz	a0,80004caa <create+0x7a>
    iunlockput(dp);
    80004c6a:	8526                	mv	a0,s1
    80004c6c:	9c9fe0ef          	jal	80003634 <iunlockput>
    ilock(ip);
    80004c70:	8556                	mv	a0,s5
    80004c72:	fb8fe0ef          	jal	8000342a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004c76:	4789                	li	a5,2
    80004c78:	02fb1463          	bne	s6,a5,80004ca0 <create+0x70>
    80004c7c:	044ad783          	lhu	a5,68(s5)
    80004c80:	37f9                	addiw	a5,a5,-2
    80004c82:	17c2                	slli	a5,a5,0x30
    80004c84:	93c1                	srli	a5,a5,0x30
    80004c86:	4705                	li	a4,1
    80004c88:	00f76c63          	bltu	a4,a5,80004ca0 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004c8c:	8556                	mv	a0,s5
    80004c8e:	60a6                	ld	ra,72(sp)
    80004c90:	6406                	ld	s0,64(sp)
    80004c92:	74e2                	ld	s1,56(sp)
    80004c94:	7942                	ld	s2,48(sp)
    80004c96:	79a2                	ld	s3,40(sp)
    80004c98:	6ae2                	ld	s5,24(sp)
    80004c9a:	6b42                	ld	s6,16(sp)
    80004c9c:	6161                	addi	sp,sp,80
    80004c9e:	8082                	ret
    iunlockput(ip);
    80004ca0:	8556                	mv	a0,s5
    80004ca2:	993fe0ef          	jal	80003634 <iunlockput>
    return 0;
    80004ca6:	4a81                	li	s5,0
    80004ca8:	b7d5                	j	80004c8c <create+0x5c>
    80004caa:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004cac:	85da                	mv	a1,s6
    80004cae:	4088                	lw	a0,0(s1)
    80004cb0:	e0afe0ef          	jal	800032ba <ialloc>
    80004cb4:	8a2a                	mv	s4,a0
    80004cb6:	cd15                	beqz	a0,80004cf2 <create+0xc2>
  ilock(ip);
    80004cb8:	f72fe0ef          	jal	8000342a <ilock>
  ip->major = major;
    80004cbc:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004cc0:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004cc4:	4905                	li	s2,1
    80004cc6:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004cca:	8552                	mv	a0,s4
    80004ccc:	eaafe0ef          	jal	80003376 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004cd0:	032b0763          	beq	s6,s2,80004cfe <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004cd4:	004a2603          	lw	a2,4(s4)
    80004cd8:	fb040593          	addi	a1,s0,-80
    80004cdc:	8526                	mv	a0,s1
    80004cde:	ec9fe0ef          	jal	80003ba6 <dirlink>
    80004ce2:	06054563          	bltz	a0,80004d4c <create+0x11c>
  iunlockput(dp);
    80004ce6:	8526                	mv	a0,s1
    80004ce8:	94dfe0ef          	jal	80003634 <iunlockput>
  return ip;
    80004cec:	8ad2                	mv	s5,s4
    80004cee:	7a02                	ld	s4,32(sp)
    80004cf0:	bf71                	j	80004c8c <create+0x5c>
    iunlockput(dp);
    80004cf2:	8526                	mv	a0,s1
    80004cf4:	941fe0ef          	jal	80003634 <iunlockput>
    return 0;
    80004cf8:	8ad2                	mv	s5,s4
    80004cfa:	7a02                	ld	s4,32(sp)
    80004cfc:	bf41                	j	80004c8c <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004cfe:	004a2603          	lw	a2,4(s4)
    80004d02:	00003597          	auipc	a1,0x3
    80004d06:	8be58593          	addi	a1,a1,-1858 # 800075c0 <etext+0x5c0>
    80004d0a:	8552                	mv	a0,s4
    80004d0c:	e9bfe0ef          	jal	80003ba6 <dirlink>
    80004d10:	02054e63          	bltz	a0,80004d4c <create+0x11c>
    80004d14:	40d0                	lw	a2,4(s1)
    80004d16:	00003597          	auipc	a1,0x3
    80004d1a:	8b258593          	addi	a1,a1,-1870 # 800075c8 <etext+0x5c8>
    80004d1e:	8552                	mv	a0,s4
    80004d20:	e87fe0ef          	jal	80003ba6 <dirlink>
    80004d24:	02054463          	bltz	a0,80004d4c <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004d28:	004a2603          	lw	a2,4(s4)
    80004d2c:	fb040593          	addi	a1,s0,-80
    80004d30:	8526                	mv	a0,s1
    80004d32:	e75fe0ef          	jal	80003ba6 <dirlink>
    80004d36:	00054b63          	bltz	a0,80004d4c <create+0x11c>
    dp->nlink++;  // for ".."
    80004d3a:	04a4d783          	lhu	a5,74(s1)
    80004d3e:	2785                	addiw	a5,a5,1
    80004d40:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004d44:	8526                	mv	a0,s1
    80004d46:	e30fe0ef          	jal	80003376 <iupdate>
    80004d4a:	bf71                	j	80004ce6 <create+0xb6>
  ip->nlink = 0;
    80004d4c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004d50:	8552                	mv	a0,s4
    80004d52:	e24fe0ef          	jal	80003376 <iupdate>
  iunlockput(ip);
    80004d56:	8552                	mv	a0,s4
    80004d58:	8ddfe0ef          	jal	80003634 <iunlockput>
  iunlockput(dp);
    80004d5c:	8526                	mv	a0,s1
    80004d5e:	8d7fe0ef          	jal	80003634 <iunlockput>
  return 0;
    80004d62:	7a02                	ld	s4,32(sp)
    80004d64:	b725                	j	80004c8c <create+0x5c>
    return 0;
    80004d66:	8aaa                	mv	s5,a0
    80004d68:	b715                	j	80004c8c <create+0x5c>

0000000080004d6a <sys_dup>:
{
    80004d6a:	7179                	addi	sp,sp,-48
    80004d6c:	f406                	sd	ra,40(sp)
    80004d6e:	f022                	sd	s0,32(sp)
    80004d70:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004d72:	fd840613          	addi	a2,s0,-40
    80004d76:	4581                	li	a1,0
    80004d78:	4501                	li	a0,0
    80004d7a:	e21ff0ef          	jal	80004b9a <argfd>
    return -1;
    80004d7e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004d80:	02054363          	bltz	a0,80004da6 <sys_dup+0x3c>
    80004d84:	ec26                	sd	s1,24(sp)
    80004d86:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004d88:	fd843903          	ld	s2,-40(s0)
    80004d8c:	854a                	mv	a0,s2
    80004d8e:	e65ff0ef          	jal	80004bf2 <fdalloc>
    80004d92:	84aa                	mv	s1,a0
    return -1;
    80004d94:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004d96:	00054d63          	bltz	a0,80004db0 <sys_dup+0x46>
  filedup(f);
    80004d9a:	854a                	mv	a0,s2
    80004d9c:	c3eff0ef          	jal	800041da <filedup>
  return fd;
    80004da0:	87a6                	mv	a5,s1
    80004da2:	64e2                	ld	s1,24(sp)
    80004da4:	6942                	ld	s2,16(sp)
}
    80004da6:	853e                	mv	a0,a5
    80004da8:	70a2                	ld	ra,40(sp)
    80004daa:	7402                	ld	s0,32(sp)
    80004dac:	6145                	addi	sp,sp,48
    80004dae:	8082                	ret
    80004db0:	64e2                	ld	s1,24(sp)
    80004db2:	6942                	ld	s2,16(sp)
    80004db4:	bfcd                	j	80004da6 <sys_dup+0x3c>

0000000080004db6 <sys_read>:
{
    80004db6:	7179                	addi	sp,sp,-48
    80004db8:	f406                	sd	ra,40(sp)
    80004dba:	f022                	sd	s0,32(sp)
    80004dbc:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004dbe:	fd840593          	addi	a1,s0,-40
    80004dc2:	4505                	li	a0,1
    80004dc4:	a35fd0ef          	jal	800027f8 <argaddr>
  argint(2, &n);
    80004dc8:	fe440593          	addi	a1,s0,-28
    80004dcc:	4509                	li	a0,2
    80004dce:	a0ffd0ef          	jal	800027dc <argint>
  if(argfd(0, 0, &f) < 0)
    80004dd2:	fe840613          	addi	a2,s0,-24
    80004dd6:	4581                	li	a1,0
    80004dd8:	4501                	li	a0,0
    80004dda:	dc1ff0ef          	jal	80004b9a <argfd>
    80004dde:	87aa                	mv	a5,a0
    return -1;
    80004de0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004de2:	0007ca63          	bltz	a5,80004df6 <sys_read+0x40>
  return fileread(f, p, n);
    80004de6:	fe442603          	lw	a2,-28(s0)
    80004dea:	fd843583          	ld	a1,-40(s0)
    80004dee:	fe843503          	ld	a0,-24(s0)
    80004df2:	d4eff0ef          	jal	80004340 <fileread>
}
    80004df6:	70a2                	ld	ra,40(sp)
    80004df8:	7402                	ld	s0,32(sp)
    80004dfa:	6145                	addi	sp,sp,48
    80004dfc:	8082                	ret

0000000080004dfe <sys_write>:
{
    80004dfe:	7179                	addi	sp,sp,-48
    80004e00:	f406                	sd	ra,40(sp)
    80004e02:	f022                	sd	s0,32(sp)
    80004e04:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e06:	fd840593          	addi	a1,s0,-40
    80004e0a:	4505                	li	a0,1
    80004e0c:	9edfd0ef          	jal	800027f8 <argaddr>
  argint(2, &n);
    80004e10:	fe440593          	addi	a1,s0,-28
    80004e14:	4509                	li	a0,2
    80004e16:	9c7fd0ef          	jal	800027dc <argint>
  if(argfd(0, 0, &f) < 0)
    80004e1a:	fe840613          	addi	a2,s0,-24
    80004e1e:	4581                	li	a1,0
    80004e20:	4501                	li	a0,0
    80004e22:	d79ff0ef          	jal	80004b9a <argfd>
    80004e26:	87aa                	mv	a5,a0
    return -1;
    80004e28:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e2a:	0007ca63          	bltz	a5,80004e3e <sys_write+0x40>
  return filewrite(f, p, n);
    80004e2e:	fe442603          	lw	a2,-28(s0)
    80004e32:	fd843583          	ld	a1,-40(s0)
    80004e36:	fe843503          	ld	a0,-24(s0)
    80004e3a:	dc4ff0ef          	jal	800043fe <filewrite>
}
    80004e3e:	70a2                	ld	ra,40(sp)
    80004e40:	7402                	ld	s0,32(sp)
    80004e42:	6145                	addi	sp,sp,48
    80004e44:	8082                	ret

0000000080004e46 <sys_close>:
{
    80004e46:	1101                	addi	sp,sp,-32
    80004e48:	ec06                	sd	ra,24(sp)
    80004e4a:	e822                	sd	s0,16(sp)
    80004e4c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004e4e:	fe040613          	addi	a2,s0,-32
    80004e52:	fec40593          	addi	a1,s0,-20
    80004e56:	4501                	li	a0,0
    80004e58:	d43ff0ef          	jal	80004b9a <argfd>
    return -1;
    80004e5c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004e5e:	02054063          	bltz	a0,80004e7e <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004e62:	a6dfc0ef          	jal	800018ce <myproc>
    80004e66:	fec42783          	lw	a5,-20(s0)
    80004e6a:	07e9                	addi	a5,a5,26
    80004e6c:	078e                	slli	a5,a5,0x3
    80004e6e:	953e                	add	a0,a0,a5
    80004e70:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004e74:	fe043503          	ld	a0,-32(s0)
    80004e78:	ba8ff0ef          	jal	80004220 <fileclose>
  return 0;
    80004e7c:	4781                	li	a5,0
}
    80004e7e:	853e                	mv	a0,a5
    80004e80:	60e2                	ld	ra,24(sp)
    80004e82:	6442                	ld	s0,16(sp)
    80004e84:	6105                	addi	sp,sp,32
    80004e86:	8082                	ret

0000000080004e88 <sys_fstat>:
{
    80004e88:	1101                	addi	sp,sp,-32
    80004e8a:	ec06                	sd	ra,24(sp)
    80004e8c:	e822                	sd	s0,16(sp)
    80004e8e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004e90:	fe040593          	addi	a1,s0,-32
    80004e94:	4505                	li	a0,1
    80004e96:	963fd0ef          	jal	800027f8 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004e9a:	fe840613          	addi	a2,s0,-24
    80004e9e:	4581                	li	a1,0
    80004ea0:	4501                	li	a0,0
    80004ea2:	cf9ff0ef          	jal	80004b9a <argfd>
    80004ea6:	87aa                	mv	a5,a0
    return -1;
    80004ea8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004eaa:	0007c863          	bltz	a5,80004eba <sys_fstat+0x32>
  return filestat(f, st);
    80004eae:	fe043583          	ld	a1,-32(s0)
    80004eb2:	fe843503          	ld	a0,-24(s0)
    80004eb6:	c2cff0ef          	jal	800042e2 <filestat>
}
    80004eba:	60e2                	ld	ra,24(sp)
    80004ebc:	6442                	ld	s0,16(sp)
    80004ebe:	6105                	addi	sp,sp,32
    80004ec0:	8082                	ret

0000000080004ec2 <sys_link>:
{
    80004ec2:	7169                	addi	sp,sp,-304
    80004ec4:	f606                	sd	ra,296(sp)
    80004ec6:	f222                	sd	s0,288(sp)
    80004ec8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004eca:	08000613          	li	a2,128
    80004ece:	ed040593          	addi	a1,s0,-304
    80004ed2:	4501                	li	a0,0
    80004ed4:	941fd0ef          	jal	80002814 <argstr>
    return -1;
    80004ed8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004eda:	0c054e63          	bltz	a0,80004fb6 <sys_link+0xf4>
    80004ede:	08000613          	li	a2,128
    80004ee2:	f5040593          	addi	a1,s0,-176
    80004ee6:	4505                	li	a0,1
    80004ee8:	92dfd0ef          	jal	80002814 <argstr>
    return -1;
    80004eec:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004eee:	0c054463          	bltz	a0,80004fb6 <sys_link+0xf4>
    80004ef2:	ee26                	sd	s1,280(sp)
  begin_op();
    80004ef4:	f21fe0ef          	jal	80003e14 <begin_op>
  if((ip = namei(old)) == 0){
    80004ef8:	ed040513          	addi	a0,s0,-304
    80004efc:	d45fe0ef          	jal	80003c40 <namei>
    80004f00:	84aa                	mv	s1,a0
    80004f02:	c53d                	beqz	a0,80004f70 <sys_link+0xae>
  ilock(ip);
    80004f04:	d26fe0ef          	jal	8000342a <ilock>
  if(ip->type == T_DIR){
    80004f08:	04449703          	lh	a4,68(s1)
    80004f0c:	4785                	li	a5,1
    80004f0e:	06f70663          	beq	a4,a5,80004f7a <sys_link+0xb8>
    80004f12:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004f14:	04a4d783          	lhu	a5,74(s1)
    80004f18:	2785                	addiw	a5,a5,1
    80004f1a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f1e:	8526                	mv	a0,s1
    80004f20:	c56fe0ef          	jal	80003376 <iupdate>
  iunlock(ip);
    80004f24:	8526                	mv	a0,s1
    80004f26:	db2fe0ef          	jal	800034d8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004f2a:	fd040593          	addi	a1,s0,-48
    80004f2e:	f5040513          	addi	a0,s0,-176
    80004f32:	d29fe0ef          	jal	80003c5a <nameiparent>
    80004f36:	892a                	mv	s2,a0
    80004f38:	cd21                	beqz	a0,80004f90 <sys_link+0xce>
  ilock(dp);
    80004f3a:	cf0fe0ef          	jal	8000342a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004f3e:	00092703          	lw	a4,0(s2)
    80004f42:	409c                	lw	a5,0(s1)
    80004f44:	04f71363          	bne	a4,a5,80004f8a <sys_link+0xc8>
    80004f48:	40d0                	lw	a2,4(s1)
    80004f4a:	fd040593          	addi	a1,s0,-48
    80004f4e:	854a                	mv	a0,s2
    80004f50:	c57fe0ef          	jal	80003ba6 <dirlink>
    80004f54:	02054b63          	bltz	a0,80004f8a <sys_link+0xc8>
  iunlockput(dp);
    80004f58:	854a                	mv	a0,s2
    80004f5a:	edafe0ef          	jal	80003634 <iunlockput>
  iput(ip);
    80004f5e:	8526                	mv	a0,s1
    80004f60:	e4cfe0ef          	jal	800035ac <iput>
  end_op();
    80004f64:	f1bfe0ef          	jal	80003e7e <end_op>
  return 0;
    80004f68:	4781                	li	a5,0
    80004f6a:	64f2                	ld	s1,280(sp)
    80004f6c:	6952                	ld	s2,272(sp)
    80004f6e:	a0a1                	j	80004fb6 <sys_link+0xf4>
    end_op();
    80004f70:	f0ffe0ef          	jal	80003e7e <end_op>
    return -1;
    80004f74:	57fd                	li	a5,-1
    80004f76:	64f2                	ld	s1,280(sp)
    80004f78:	a83d                	j	80004fb6 <sys_link+0xf4>
    iunlockput(ip);
    80004f7a:	8526                	mv	a0,s1
    80004f7c:	eb8fe0ef          	jal	80003634 <iunlockput>
    end_op();
    80004f80:	efffe0ef          	jal	80003e7e <end_op>
    return -1;
    80004f84:	57fd                	li	a5,-1
    80004f86:	64f2                	ld	s1,280(sp)
    80004f88:	a03d                	j	80004fb6 <sys_link+0xf4>
    iunlockput(dp);
    80004f8a:	854a                	mv	a0,s2
    80004f8c:	ea8fe0ef          	jal	80003634 <iunlockput>
  ilock(ip);
    80004f90:	8526                	mv	a0,s1
    80004f92:	c98fe0ef          	jal	8000342a <ilock>
  ip->nlink--;
    80004f96:	04a4d783          	lhu	a5,74(s1)
    80004f9a:	37fd                	addiw	a5,a5,-1
    80004f9c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004fa0:	8526                	mv	a0,s1
    80004fa2:	bd4fe0ef          	jal	80003376 <iupdate>
  iunlockput(ip);
    80004fa6:	8526                	mv	a0,s1
    80004fa8:	e8cfe0ef          	jal	80003634 <iunlockput>
  end_op();
    80004fac:	ed3fe0ef          	jal	80003e7e <end_op>
  return -1;
    80004fb0:	57fd                	li	a5,-1
    80004fb2:	64f2                	ld	s1,280(sp)
    80004fb4:	6952                	ld	s2,272(sp)
}
    80004fb6:	853e                	mv	a0,a5
    80004fb8:	70b2                	ld	ra,296(sp)
    80004fba:	7412                	ld	s0,288(sp)
    80004fbc:	6155                	addi	sp,sp,304
    80004fbe:	8082                	ret

0000000080004fc0 <sys_unlink>:
{
    80004fc0:	7151                	addi	sp,sp,-240
    80004fc2:	f586                	sd	ra,232(sp)
    80004fc4:	f1a2                	sd	s0,224(sp)
    80004fc6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004fc8:	08000613          	li	a2,128
    80004fcc:	f3040593          	addi	a1,s0,-208
    80004fd0:	4501                	li	a0,0
    80004fd2:	843fd0ef          	jal	80002814 <argstr>
    80004fd6:	16054063          	bltz	a0,80005136 <sys_unlink+0x176>
    80004fda:	eda6                	sd	s1,216(sp)
  begin_op();
    80004fdc:	e39fe0ef          	jal	80003e14 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004fe0:	fb040593          	addi	a1,s0,-80
    80004fe4:	f3040513          	addi	a0,s0,-208
    80004fe8:	c73fe0ef          	jal	80003c5a <nameiparent>
    80004fec:	84aa                	mv	s1,a0
    80004fee:	c945                	beqz	a0,8000509e <sys_unlink+0xde>
  ilock(dp);
    80004ff0:	c3afe0ef          	jal	8000342a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004ff4:	00002597          	auipc	a1,0x2
    80004ff8:	5cc58593          	addi	a1,a1,1484 # 800075c0 <etext+0x5c0>
    80004ffc:	fb040513          	addi	a0,s0,-80
    80005000:	9c5fe0ef          	jal	800039c4 <namecmp>
    80005004:	10050e63          	beqz	a0,80005120 <sys_unlink+0x160>
    80005008:	00002597          	auipc	a1,0x2
    8000500c:	5c058593          	addi	a1,a1,1472 # 800075c8 <etext+0x5c8>
    80005010:	fb040513          	addi	a0,s0,-80
    80005014:	9b1fe0ef          	jal	800039c4 <namecmp>
    80005018:	10050463          	beqz	a0,80005120 <sys_unlink+0x160>
    8000501c:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000501e:	f2c40613          	addi	a2,s0,-212
    80005022:	fb040593          	addi	a1,s0,-80
    80005026:	8526                	mv	a0,s1
    80005028:	9b3fe0ef          	jal	800039da <dirlookup>
    8000502c:	892a                	mv	s2,a0
    8000502e:	0e050863          	beqz	a0,8000511e <sys_unlink+0x15e>
  ilock(ip);
    80005032:	bf8fe0ef          	jal	8000342a <ilock>
  if(ip->nlink < 1)
    80005036:	04a91783          	lh	a5,74(s2)
    8000503a:	06f05763          	blez	a5,800050a8 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000503e:	04491703          	lh	a4,68(s2)
    80005042:	4785                	li	a5,1
    80005044:	06f70963          	beq	a4,a5,800050b6 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005048:	4641                	li	a2,16
    8000504a:	4581                	li	a1,0
    8000504c:	fc040513          	addi	a0,s0,-64
    80005050:	c53fb0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005054:	4741                	li	a4,16
    80005056:	f2c42683          	lw	a3,-212(s0)
    8000505a:	fc040613          	addi	a2,s0,-64
    8000505e:	4581                	li	a1,0
    80005060:	8526                	mv	a0,s1
    80005062:	855fe0ef          	jal	800038b6 <writei>
    80005066:	47c1                	li	a5,16
    80005068:	08f51b63          	bne	a0,a5,800050fe <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    8000506c:	04491703          	lh	a4,68(s2)
    80005070:	4785                	li	a5,1
    80005072:	08f70d63          	beq	a4,a5,8000510c <sys_unlink+0x14c>
  iunlockput(dp);
    80005076:	8526                	mv	a0,s1
    80005078:	dbcfe0ef          	jal	80003634 <iunlockput>
  ip->nlink--;
    8000507c:	04a95783          	lhu	a5,74(s2)
    80005080:	37fd                	addiw	a5,a5,-1
    80005082:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005086:	854a                	mv	a0,s2
    80005088:	aeefe0ef          	jal	80003376 <iupdate>
  iunlockput(ip);
    8000508c:	854a                	mv	a0,s2
    8000508e:	da6fe0ef          	jal	80003634 <iunlockput>
  end_op();
    80005092:	dedfe0ef          	jal	80003e7e <end_op>
  return 0;
    80005096:	4501                	li	a0,0
    80005098:	64ee                	ld	s1,216(sp)
    8000509a:	694e                	ld	s2,208(sp)
    8000509c:	a849                	j	8000512e <sys_unlink+0x16e>
    end_op();
    8000509e:	de1fe0ef          	jal	80003e7e <end_op>
    return -1;
    800050a2:	557d                	li	a0,-1
    800050a4:	64ee                	ld	s1,216(sp)
    800050a6:	a061                	j	8000512e <sys_unlink+0x16e>
    800050a8:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800050aa:	00002517          	auipc	a0,0x2
    800050ae:	52650513          	addi	a0,a0,1318 # 800075d0 <etext+0x5d0>
    800050b2:	f2efb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800050b6:	04c92703          	lw	a4,76(s2)
    800050ba:	02000793          	li	a5,32
    800050be:	f8e7f5e3          	bgeu	a5,a4,80005048 <sys_unlink+0x88>
    800050c2:	e5ce                	sd	s3,200(sp)
    800050c4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800050c8:	4741                	li	a4,16
    800050ca:	86ce                	mv	a3,s3
    800050cc:	f1840613          	addi	a2,s0,-232
    800050d0:	4581                	li	a1,0
    800050d2:	854a                	mv	a0,s2
    800050d4:	ee6fe0ef          	jal	800037ba <readi>
    800050d8:	47c1                	li	a5,16
    800050da:	00f51c63          	bne	a0,a5,800050f2 <sys_unlink+0x132>
    if(de.inum != 0)
    800050de:	f1845783          	lhu	a5,-232(s0)
    800050e2:	efa1                	bnez	a5,8000513a <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800050e4:	29c1                	addiw	s3,s3,16
    800050e6:	04c92783          	lw	a5,76(s2)
    800050ea:	fcf9efe3          	bltu	s3,a5,800050c8 <sys_unlink+0x108>
    800050ee:	69ae                	ld	s3,200(sp)
    800050f0:	bfa1                	j	80005048 <sys_unlink+0x88>
      panic("isdirempty: readi");
    800050f2:	00002517          	auipc	a0,0x2
    800050f6:	4f650513          	addi	a0,a0,1270 # 800075e8 <etext+0x5e8>
    800050fa:	ee6fb0ef          	jal	800007e0 <panic>
    800050fe:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005100:	00002517          	auipc	a0,0x2
    80005104:	50050513          	addi	a0,a0,1280 # 80007600 <etext+0x600>
    80005108:	ed8fb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    8000510c:	04a4d783          	lhu	a5,74(s1)
    80005110:	37fd                	addiw	a5,a5,-1
    80005112:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005116:	8526                	mv	a0,s1
    80005118:	a5efe0ef          	jal	80003376 <iupdate>
    8000511c:	bfa9                	j	80005076 <sys_unlink+0xb6>
    8000511e:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005120:	8526                	mv	a0,s1
    80005122:	d12fe0ef          	jal	80003634 <iunlockput>
  end_op();
    80005126:	d59fe0ef          	jal	80003e7e <end_op>
  return -1;
    8000512a:	557d                	li	a0,-1
    8000512c:	64ee                	ld	s1,216(sp)
}
    8000512e:	70ae                	ld	ra,232(sp)
    80005130:	740e                	ld	s0,224(sp)
    80005132:	616d                	addi	sp,sp,240
    80005134:	8082                	ret
    return -1;
    80005136:	557d                	li	a0,-1
    80005138:	bfdd                	j	8000512e <sys_unlink+0x16e>
    iunlockput(ip);
    8000513a:	854a                	mv	a0,s2
    8000513c:	cf8fe0ef          	jal	80003634 <iunlockput>
    goto bad;
    80005140:	694e                	ld	s2,208(sp)
    80005142:	69ae                	ld	s3,200(sp)
    80005144:	bff1                	j	80005120 <sys_unlink+0x160>

0000000080005146 <sys_open>:

uint64
sys_open(void)
{
    80005146:	7131                	addi	sp,sp,-192
    80005148:	fd06                	sd	ra,184(sp)
    8000514a:	f922                	sd	s0,176(sp)
    8000514c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000514e:	f4c40593          	addi	a1,s0,-180
    80005152:	4505                	li	a0,1
    80005154:	e88fd0ef          	jal	800027dc <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005158:	08000613          	li	a2,128
    8000515c:	f5040593          	addi	a1,s0,-176
    80005160:	4501                	li	a0,0
    80005162:	eb2fd0ef          	jal	80002814 <argstr>
    80005166:	87aa                	mv	a5,a0
    return -1;
    80005168:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000516a:	0a07c263          	bltz	a5,8000520e <sys_open+0xc8>
    8000516e:	f526                	sd	s1,168(sp)

  begin_op();
    80005170:	ca5fe0ef          	jal	80003e14 <begin_op>

  if(omode & O_CREATE){
    80005174:	f4c42783          	lw	a5,-180(s0)
    80005178:	2007f793          	andi	a5,a5,512
    8000517c:	c3d5                	beqz	a5,80005220 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000517e:	4681                	li	a3,0
    80005180:	4601                	li	a2,0
    80005182:	4589                	li	a1,2
    80005184:	f5040513          	addi	a0,s0,-176
    80005188:	aa9ff0ef          	jal	80004c30 <create>
    8000518c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000518e:	c541                	beqz	a0,80005216 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005190:	04449703          	lh	a4,68(s1)
    80005194:	478d                	li	a5,3
    80005196:	00f71763          	bne	a4,a5,800051a4 <sys_open+0x5e>
    8000519a:	0464d703          	lhu	a4,70(s1)
    8000519e:	47a5                	li	a5,9
    800051a0:	0ae7ed63          	bltu	a5,a4,8000525a <sys_open+0x114>
    800051a4:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800051a6:	fd7fe0ef          	jal	8000417c <filealloc>
    800051aa:	892a                	mv	s2,a0
    800051ac:	c179                	beqz	a0,80005272 <sys_open+0x12c>
    800051ae:	ed4e                	sd	s3,152(sp)
    800051b0:	a43ff0ef          	jal	80004bf2 <fdalloc>
    800051b4:	89aa                	mv	s3,a0
    800051b6:	0a054a63          	bltz	a0,8000526a <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800051ba:	04449703          	lh	a4,68(s1)
    800051be:	478d                	li	a5,3
    800051c0:	0cf70263          	beq	a4,a5,80005284 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800051c4:	4789                	li	a5,2
    800051c6:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800051ca:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800051ce:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800051d2:	f4c42783          	lw	a5,-180(s0)
    800051d6:	0017c713          	xori	a4,a5,1
    800051da:	8b05                	andi	a4,a4,1
    800051dc:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800051e0:	0037f713          	andi	a4,a5,3
    800051e4:	00e03733          	snez	a4,a4
    800051e8:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800051ec:	4007f793          	andi	a5,a5,1024
    800051f0:	c791                	beqz	a5,800051fc <sys_open+0xb6>
    800051f2:	04449703          	lh	a4,68(s1)
    800051f6:	4789                	li	a5,2
    800051f8:	08f70d63          	beq	a4,a5,80005292 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    800051fc:	8526                	mv	a0,s1
    800051fe:	adafe0ef          	jal	800034d8 <iunlock>
  end_op();
    80005202:	c7dfe0ef          	jal	80003e7e <end_op>

  return fd;
    80005206:	854e                	mv	a0,s3
    80005208:	74aa                	ld	s1,168(sp)
    8000520a:	790a                	ld	s2,160(sp)
    8000520c:	69ea                	ld	s3,152(sp)
}
    8000520e:	70ea                	ld	ra,184(sp)
    80005210:	744a                	ld	s0,176(sp)
    80005212:	6129                	addi	sp,sp,192
    80005214:	8082                	ret
      end_op();
    80005216:	c69fe0ef          	jal	80003e7e <end_op>
      return -1;
    8000521a:	557d                	li	a0,-1
    8000521c:	74aa                	ld	s1,168(sp)
    8000521e:	bfc5                	j	8000520e <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80005220:	f5040513          	addi	a0,s0,-176
    80005224:	a1dfe0ef          	jal	80003c40 <namei>
    80005228:	84aa                	mv	s1,a0
    8000522a:	c11d                	beqz	a0,80005250 <sys_open+0x10a>
    ilock(ip);
    8000522c:	9fefe0ef          	jal	8000342a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005230:	04449703          	lh	a4,68(s1)
    80005234:	4785                	li	a5,1
    80005236:	f4f71de3          	bne	a4,a5,80005190 <sys_open+0x4a>
    8000523a:	f4c42783          	lw	a5,-180(s0)
    8000523e:	d3bd                	beqz	a5,800051a4 <sys_open+0x5e>
      iunlockput(ip);
    80005240:	8526                	mv	a0,s1
    80005242:	bf2fe0ef          	jal	80003634 <iunlockput>
      end_op();
    80005246:	c39fe0ef          	jal	80003e7e <end_op>
      return -1;
    8000524a:	557d                	li	a0,-1
    8000524c:	74aa                	ld	s1,168(sp)
    8000524e:	b7c1                	j	8000520e <sys_open+0xc8>
      end_op();
    80005250:	c2ffe0ef          	jal	80003e7e <end_op>
      return -1;
    80005254:	557d                	li	a0,-1
    80005256:	74aa                	ld	s1,168(sp)
    80005258:	bf5d                	j	8000520e <sys_open+0xc8>
    iunlockput(ip);
    8000525a:	8526                	mv	a0,s1
    8000525c:	bd8fe0ef          	jal	80003634 <iunlockput>
    end_op();
    80005260:	c1ffe0ef          	jal	80003e7e <end_op>
    return -1;
    80005264:	557d                	li	a0,-1
    80005266:	74aa                	ld	s1,168(sp)
    80005268:	b75d                	j	8000520e <sys_open+0xc8>
      fileclose(f);
    8000526a:	854a                	mv	a0,s2
    8000526c:	fb5fe0ef          	jal	80004220 <fileclose>
    80005270:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005272:	8526                	mv	a0,s1
    80005274:	bc0fe0ef          	jal	80003634 <iunlockput>
    end_op();
    80005278:	c07fe0ef          	jal	80003e7e <end_op>
    return -1;
    8000527c:	557d                	li	a0,-1
    8000527e:	74aa                	ld	s1,168(sp)
    80005280:	790a                	ld	s2,160(sp)
    80005282:	b771                	j	8000520e <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005284:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005288:	04649783          	lh	a5,70(s1)
    8000528c:	02f91223          	sh	a5,36(s2)
    80005290:	bf3d                	j	800051ce <sys_open+0x88>
    itrunc(ip);
    80005292:	8526                	mv	a0,s1
    80005294:	a84fe0ef          	jal	80003518 <itrunc>
    80005298:	b795                	j	800051fc <sys_open+0xb6>

000000008000529a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000529a:	7175                	addi	sp,sp,-144
    8000529c:	e506                	sd	ra,136(sp)
    8000529e:	e122                	sd	s0,128(sp)
    800052a0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800052a2:	b73fe0ef          	jal	80003e14 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800052a6:	08000613          	li	a2,128
    800052aa:	f7040593          	addi	a1,s0,-144
    800052ae:	4501                	li	a0,0
    800052b0:	d64fd0ef          	jal	80002814 <argstr>
    800052b4:	02054363          	bltz	a0,800052da <sys_mkdir+0x40>
    800052b8:	4681                	li	a3,0
    800052ba:	4601                	li	a2,0
    800052bc:	4585                	li	a1,1
    800052be:	f7040513          	addi	a0,s0,-144
    800052c2:	96fff0ef          	jal	80004c30 <create>
    800052c6:	c911                	beqz	a0,800052da <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800052c8:	b6cfe0ef          	jal	80003634 <iunlockput>
  end_op();
    800052cc:	bb3fe0ef          	jal	80003e7e <end_op>
  return 0;
    800052d0:	4501                	li	a0,0
}
    800052d2:	60aa                	ld	ra,136(sp)
    800052d4:	640a                	ld	s0,128(sp)
    800052d6:	6149                	addi	sp,sp,144
    800052d8:	8082                	ret
    end_op();
    800052da:	ba5fe0ef          	jal	80003e7e <end_op>
    return -1;
    800052de:	557d                	li	a0,-1
    800052e0:	bfcd                	j	800052d2 <sys_mkdir+0x38>

00000000800052e2 <sys_mknod>:

uint64
sys_mknod(void)
{
    800052e2:	7135                	addi	sp,sp,-160
    800052e4:	ed06                	sd	ra,152(sp)
    800052e6:	e922                	sd	s0,144(sp)
    800052e8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800052ea:	b2bfe0ef          	jal	80003e14 <begin_op>
  argint(1, &major);
    800052ee:	f6c40593          	addi	a1,s0,-148
    800052f2:	4505                	li	a0,1
    800052f4:	ce8fd0ef          	jal	800027dc <argint>
  argint(2, &minor);
    800052f8:	f6840593          	addi	a1,s0,-152
    800052fc:	4509                	li	a0,2
    800052fe:	cdefd0ef          	jal	800027dc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005302:	08000613          	li	a2,128
    80005306:	f7040593          	addi	a1,s0,-144
    8000530a:	4501                	li	a0,0
    8000530c:	d08fd0ef          	jal	80002814 <argstr>
    80005310:	02054563          	bltz	a0,8000533a <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005314:	f6841683          	lh	a3,-152(s0)
    80005318:	f6c41603          	lh	a2,-148(s0)
    8000531c:	458d                	li	a1,3
    8000531e:	f7040513          	addi	a0,s0,-144
    80005322:	90fff0ef          	jal	80004c30 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005326:	c911                	beqz	a0,8000533a <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005328:	b0cfe0ef          	jal	80003634 <iunlockput>
  end_op();
    8000532c:	b53fe0ef          	jal	80003e7e <end_op>
  return 0;
    80005330:	4501                	li	a0,0
}
    80005332:	60ea                	ld	ra,152(sp)
    80005334:	644a                	ld	s0,144(sp)
    80005336:	610d                	addi	sp,sp,160
    80005338:	8082                	ret
    end_op();
    8000533a:	b45fe0ef          	jal	80003e7e <end_op>
    return -1;
    8000533e:	557d                	li	a0,-1
    80005340:	bfcd                	j	80005332 <sys_mknod+0x50>

0000000080005342 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005342:	7135                	addi	sp,sp,-160
    80005344:	ed06                	sd	ra,152(sp)
    80005346:	e922                	sd	s0,144(sp)
    80005348:	e14a                	sd	s2,128(sp)
    8000534a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000534c:	d82fc0ef          	jal	800018ce <myproc>
    80005350:	892a                	mv	s2,a0
  
  begin_op();
    80005352:	ac3fe0ef          	jal	80003e14 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005356:	08000613          	li	a2,128
    8000535a:	f6040593          	addi	a1,s0,-160
    8000535e:	4501                	li	a0,0
    80005360:	cb4fd0ef          	jal	80002814 <argstr>
    80005364:	04054363          	bltz	a0,800053aa <sys_chdir+0x68>
    80005368:	e526                	sd	s1,136(sp)
    8000536a:	f6040513          	addi	a0,s0,-160
    8000536e:	8d3fe0ef          	jal	80003c40 <namei>
    80005372:	84aa                	mv	s1,a0
    80005374:	c915                	beqz	a0,800053a8 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005376:	8b4fe0ef          	jal	8000342a <ilock>
  if(ip->type != T_DIR){
    8000537a:	04449703          	lh	a4,68(s1)
    8000537e:	4785                	li	a5,1
    80005380:	02f71963          	bne	a4,a5,800053b2 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005384:	8526                	mv	a0,s1
    80005386:	952fe0ef          	jal	800034d8 <iunlock>
  iput(p->cwd);
    8000538a:	15093503          	ld	a0,336(s2)
    8000538e:	a1efe0ef          	jal	800035ac <iput>
  end_op();
    80005392:	aedfe0ef          	jal	80003e7e <end_op>
  p->cwd = ip;
    80005396:	14993823          	sd	s1,336(s2)
  return 0;
    8000539a:	4501                	li	a0,0
    8000539c:	64aa                	ld	s1,136(sp)
}
    8000539e:	60ea                	ld	ra,152(sp)
    800053a0:	644a                	ld	s0,144(sp)
    800053a2:	690a                	ld	s2,128(sp)
    800053a4:	610d                	addi	sp,sp,160
    800053a6:	8082                	ret
    800053a8:	64aa                	ld	s1,136(sp)
    end_op();
    800053aa:	ad5fe0ef          	jal	80003e7e <end_op>
    return -1;
    800053ae:	557d                	li	a0,-1
    800053b0:	b7fd                	j	8000539e <sys_chdir+0x5c>
    iunlockput(ip);
    800053b2:	8526                	mv	a0,s1
    800053b4:	a80fe0ef          	jal	80003634 <iunlockput>
    end_op();
    800053b8:	ac7fe0ef          	jal	80003e7e <end_op>
    return -1;
    800053bc:	557d                	li	a0,-1
    800053be:	64aa                	ld	s1,136(sp)
    800053c0:	bff9                	j	8000539e <sys_chdir+0x5c>

00000000800053c2 <sys_exec>:

uint64
sys_exec(void)
{
    800053c2:	7121                	addi	sp,sp,-448
    800053c4:	ff06                	sd	ra,440(sp)
    800053c6:	fb22                	sd	s0,432(sp)
    800053c8:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800053ca:	e4840593          	addi	a1,s0,-440
    800053ce:	4505                	li	a0,1
    800053d0:	c28fd0ef          	jal	800027f8 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800053d4:	08000613          	li	a2,128
    800053d8:	f5040593          	addi	a1,s0,-176
    800053dc:	4501                	li	a0,0
    800053de:	c36fd0ef          	jal	80002814 <argstr>
    800053e2:	87aa                	mv	a5,a0
    return -1;
    800053e4:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800053e6:	0c07c463          	bltz	a5,800054ae <sys_exec+0xec>
    800053ea:	f726                	sd	s1,424(sp)
    800053ec:	f34a                	sd	s2,416(sp)
    800053ee:	ef4e                	sd	s3,408(sp)
    800053f0:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800053f2:	10000613          	li	a2,256
    800053f6:	4581                	li	a1,0
    800053f8:	e5040513          	addi	a0,s0,-432
    800053fc:	8a7fb0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005400:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005404:	89a6                	mv	s3,s1
    80005406:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005408:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000540c:	00391513          	slli	a0,s2,0x3
    80005410:	e4040593          	addi	a1,s0,-448
    80005414:	e4843783          	ld	a5,-440(s0)
    80005418:	953e                	add	a0,a0,a5
    8000541a:	b38fd0ef          	jal	80002752 <fetchaddr>
    8000541e:	02054663          	bltz	a0,8000544a <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005422:	e4043783          	ld	a5,-448(s0)
    80005426:	c3a9                	beqz	a5,80005468 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005428:	ed6fb0ef          	jal	80000afe <kalloc>
    8000542c:	85aa                	mv	a1,a0
    8000542e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005432:	cd01                	beqz	a0,8000544a <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005434:	6605                	lui	a2,0x1
    80005436:	e4043503          	ld	a0,-448(s0)
    8000543a:	b62fd0ef          	jal	8000279c <fetchstr>
    8000543e:	00054663          	bltz	a0,8000544a <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005442:	0905                	addi	s2,s2,1
    80005444:	09a1                	addi	s3,s3,8
    80005446:	fd4913e3          	bne	s2,s4,8000540c <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000544a:	f5040913          	addi	s2,s0,-176
    8000544e:	6088                	ld	a0,0(s1)
    80005450:	c931                	beqz	a0,800054a4 <sys_exec+0xe2>
    kfree(argv[i]);
    80005452:	dcafb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005456:	04a1                	addi	s1,s1,8
    80005458:	ff249be3          	bne	s1,s2,8000544e <sys_exec+0x8c>
  return -1;
    8000545c:	557d                	li	a0,-1
    8000545e:	74ba                	ld	s1,424(sp)
    80005460:	791a                	ld	s2,416(sp)
    80005462:	69fa                	ld	s3,408(sp)
    80005464:	6a5a                	ld	s4,400(sp)
    80005466:	a0a1                	j	800054ae <sys_exec+0xec>
      argv[i] = 0;
    80005468:	0009079b          	sext.w	a5,s2
    8000546c:	078e                	slli	a5,a5,0x3
    8000546e:	fd078793          	addi	a5,a5,-48
    80005472:	97a2                	add	a5,a5,s0
    80005474:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80005478:	e5040593          	addi	a1,s0,-432
    8000547c:	f5040513          	addi	a0,s0,-176
    80005480:	ba8ff0ef          	jal	80004828 <kexec>
    80005484:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005486:	f5040993          	addi	s3,s0,-176
    8000548a:	6088                	ld	a0,0(s1)
    8000548c:	c511                	beqz	a0,80005498 <sys_exec+0xd6>
    kfree(argv[i]);
    8000548e:	d8efb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005492:	04a1                	addi	s1,s1,8
    80005494:	ff349be3          	bne	s1,s3,8000548a <sys_exec+0xc8>
  return ret;
    80005498:	854a                	mv	a0,s2
    8000549a:	74ba                	ld	s1,424(sp)
    8000549c:	791a                	ld	s2,416(sp)
    8000549e:	69fa                	ld	s3,408(sp)
    800054a0:	6a5a                	ld	s4,400(sp)
    800054a2:	a031                	j	800054ae <sys_exec+0xec>
  return -1;
    800054a4:	557d                	li	a0,-1
    800054a6:	74ba                	ld	s1,424(sp)
    800054a8:	791a                	ld	s2,416(sp)
    800054aa:	69fa                	ld	s3,408(sp)
    800054ac:	6a5a                	ld	s4,400(sp)
}
    800054ae:	70fa                	ld	ra,440(sp)
    800054b0:	745a                	ld	s0,432(sp)
    800054b2:	6139                	addi	sp,sp,448
    800054b4:	8082                	ret

00000000800054b6 <sys_pipe>:

uint64
sys_pipe(void)
{
    800054b6:	7139                	addi	sp,sp,-64
    800054b8:	fc06                	sd	ra,56(sp)
    800054ba:	f822                	sd	s0,48(sp)
    800054bc:	f426                	sd	s1,40(sp)
    800054be:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800054c0:	c0efc0ef          	jal	800018ce <myproc>
    800054c4:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800054c6:	fd840593          	addi	a1,s0,-40
    800054ca:	4501                	li	a0,0
    800054cc:	b2cfd0ef          	jal	800027f8 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800054d0:	fc840593          	addi	a1,s0,-56
    800054d4:	fd040513          	addi	a0,s0,-48
    800054d8:	852ff0ef          	jal	8000452a <pipealloc>
    return -1;
    800054dc:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800054de:	0a054463          	bltz	a0,80005586 <sys_pipe+0xd0>
  fd0 = -1;
    800054e2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800054e6:	fd043503          	ld	a0,-48(s0)
    800054ea:	f08ff0ef          	jal	80004bf2 <fdalloc>
    800054ee:	fca42223          	sw	a0,-60(s0)
    800054f2:	08054163          	bltz	a0,80005574 <sys_pipe+0xbe>
    800054f6:	fc843503          	ld	a0,-56(s0)
    800054fa:	ef8ff0ef          	jal	80004bf2 <fdalloc>
    800054fe:	fca42023          	sw	a0,-64(s0)
    80005502:	06054063          	bltz	a0,80005562 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005506:	4691                	li	a3,4
    80005508:	fc440613          	addi	a2,s0,-60
    8000550c:	fd843583          	ld	a1,-40(s0)
    80005510:	68a8                	ld	a0,80(s1)
    80005512:	8d0fc0ef          	jal	800015e2 <copyout>
    80005516:	00054e63          	bltz	a0,80005532 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000551a:	4691                	li	a3,4
    8000551c:	fc040613          	addi	a2,s0,-64
    80005520:	fd843583          	ld	a1,-40(s0)
    80005524:	0591                	addi	a1,a1,4
    80005526:	68a8                	ld	a0,80(s1)
    80005528:	8bafc0ef          	jal	800015e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000552c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000552e:	04055c63          	bgez	a0,80005586 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005532:	fc442783          	lw	a5,-60(s0)
    80005536:	07e9                	addi	a5,a5,26
    80005538:	078e                	slli	a5,a5,0x3
    8000553a:	97a6                	add	a5,a5,s1
    8000553c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005540:	fc042783          	lw	a5,-64(s0)
    80005544:	07e9                	addi	a5,a5,26
    80005546:	078e                	slli	a5,a5,0x3
    80005548:	94be                	add	s1,s1,a5
    8000554a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000554e:	fd043503          	ld	a0,-48(s0)
    80005552:	ccffe0ef          	jal	80004220 <fileclose>
    fileclose(wf);
    80005556:	fc843503          	ld	a0,-56(s0)
    8000555a:	cc7fe0ef          	jal	80004220 <fileclose>
    return -1;
    8000555e:	57fd                	li	a5,-1
    80005560:	a01d                	j	80005586 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005562:	fc442783          	lw	a5,-60(s0)
    80005566:	0007c763          	bltz	a5,80005574 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000556a:	07e9                	addi	a5,a5,26
    8000556c:	078e                	slli	a5,a5,0x3
    8000556e:	97a6                	add	a5,a5,s1
    80005570:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005574:	fd043503          	ld	a0,-48(s0)
    80005578:	ca9fe0ef          	jal	80004220 <fileclose>
    fileclose(wf);
    8000557c:	fc843503          	ld	a0,-56(s0)
    80005580:	ca1fe0ef          	jal	80004220 <fileclose>
    return -1;
    80005584:	57fd                	li	a5,-1
}
    80005586:	853e                	mv	a0,a5
    80005588:	70e2                	ld	ra,56(sp)
    8000558a:	7442                	ld	s0,48(sp)
    8000558c:	74a2                	ld	s1,40(sp)
    8000558e:	6121                	addi	sp,sp,64
    80005590:	8082                	ret
	...

00000000800055a0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800055a0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800055a2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800055a4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    800055a6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    800055a8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800055aa:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800055ac:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800055ae:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800055b0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800055b2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800055b4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800055b6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800055b8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800055ba:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800055bc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800055be:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800055c0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800055c2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800055c4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800055c6:	89cfd0ef          	jal	80002662 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800055ca:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800055cc:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800055ce:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800055d0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800055d2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800055d4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800055d6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800055d8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800055da:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800055dc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800055de:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800055e0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800055e2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800055e4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800055e6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800055e8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800055ea:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800055ec:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800055ee:	10200073          	sret
	...

00000000800055fe <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800055fe:	1141                	addi	sp,sp,-16
    80005600:	e422                	sd	s0,8(sp)
    80005602:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005604:	0c0007b7          	lui	a5,0xc000
    80005608:	4705                	li	a4,1
    8000560a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000560c:	0c0007b7          	lui	a5,0xc000
    80005610:	c3d8                	sw	a4,4(a5)
}
    80005612:	6422                	ld	s0,8(sp)
    80005614:	0141                	addi	sp,sp,16
    80005616:	8082                	ret

0000000080005618 <plicinithart>:

void
plicinithart(void)
{
    80005618:	1141                	addi	sp,sp,-16
    8000561a:	e406                	sd	ra,8(sp)
    8000561c:	e022                	sd	s0,0(sp)
    8000561e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005620:	a82fc0ef          	jal	800018a2 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005624:	0085171b          	slliw	a4,a0,0x8
    80005628:	0c0027b7          	lui	a5,0xc002
    8000562c:	97ba                	add	a5,a5,a4
    8000562e:	40200713          	li	a4,1026
    80005632:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005636:	00d5151b          	slliw	a0,a0,0xd
    8000563a:	0c2017b7          	lui	a5,0xc201
    8000563e:	97aa                	add	a5,a5,a0
    80005640:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005644:	60a2                	ld	ra,8(sp)
    80005646:	6402                	ld	s0,0(sp)
    80005648:	0141                	addi	sp,sp,16
    8000564a:	8082                	ret

000000008000564c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000564c:	1141                	addi	sp,sp,-16
    8000564e:	e406                	sd	ra,8(sp)
    80005650:	e022                	sd	s0,0(sp)
    80005652:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005654:	a4efc0ef          	jal	800018a2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005658:	00d5151b          	slliw	a0,a0,0xd
    8000565c:	0c2017b7          	lui	a5,0xc201
    80005660:	97aa                	add	a5,a5,a0
  return irq;
}
    80005662:	43c8                	lw	a0,4(a5)
    80005664:	60a2                	ld	ra,8(sp)
    80005666:	6402                	ld	s0,0(sp)
    80005668:	0141                	addi	sp,sp,16
    8000566a:	8082                	ret

000000008000566c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000566c:	1101                	addi	sp,sp,-32
    8000566e:	ec06                	sd	ra,24(sp)
    80005670:	e822                	sd	s0,16(sp)
    80005672:	e426                	sd	s1,8(sp)
    80005674:	1000                	addi	s0,sp,32
    80005676:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005678:	a2afc0ef          	jal	800018a2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000567c:	00d5151b          	slliw	a0,a0,0xd
    80005680:	0c2017b7          	lui	a5,0xc201
    80005684:	97aa                	add	a5,a5,a0
    80005686:	c3c4                	sw	s1,4(a5)
}
    80005688:	60e2                	ld	ra,24(sp)
    8000568a:	6442                	ld	s0,16(sp)
    8000568c:	64a2                	ld	s1,8(sp)
    8000568e:	6105                	addi	sp,sp,32
    80005690:	8082                	ret

0000000080005692 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005692:	1141                	addi	sp,sp,-16
    80005694:	e406                	sd	ra,8(sp)
    80005696:	e022                	sd	s0,0(sp)
    80005698:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000569a:	479d                	li	a5,7
    8000569c:	04a7ca63          	blt	a5,a0,800056f0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800056a0:	0001b797          	auipc	a5,0x1b
    800056a4:	5a878793          	addi	a5,a5,1448 # 80020c48 <disk>
    800056a8:	97aa                	add	a5,a5,a0
    800056aa:	0187c783          	lbu	a5,24(a5)
    800056ae:	e7b9                	bnez	a5,800056fc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800056b0:	00451693          	slli	a3,a0,0x4
    800056b4:	0001b797          	auipc	a5,0x1b
    800056b8:	59478793          	addi	a5,a5,1428 # 80020c48 <disk>
    800056bc:	6398                	ld	a4,0(a5)
    800056be:	9736                	add	a4,a4,a3
    800056c0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800056c4:	6398                	ld	a4,0(a5)
    800056c6:	9736                	add	a4,a4,a3
    800056c8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800056cc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800056d0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800056d4:	97aa                	add	a5,a5,a0
    800056d6:	4705                	li	a4,1
    800056d8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800056dc:	0001b517          	auipc	a0,0x1b
    800056e0:	58450513          	addi	a0,a0,1412 # 80020c60 <disk+0x18>
    800056e4:	841fc0ef          	jal	80001f24 <wakeup>
}
    800056e8:	60a2                	ld	ra,8(sp)
    800056ea:	6402                	ld	s0,0(sp)
    800056ec:	0141                	addi	sp,sp,16
    800056ee:	8082                	ret
    panic("free_desc 1");
    800056f0:	00002517          	auipc	a0,0x2
    800056f4:	f2050513          	addi	a0,a0,-224 # 80007610 <etext+0x610>
    800056f8:	8e8fb0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    800056fc:	00002517          	auipc	a0,0x2
    80005700:	f2450513          	addi	a0,a0,-220 # 80007620 <etext+0x620>
    80005704:	8dcfb0ef          	jal	800007e0 <panic>

0000000080005708 <virtio_disk_init>:
{
    80005708:	1101                	addi	sp,sp,-32
    8000570a:	ec06                	sd	ra,24(sp)
    8000570c:	e822                	sd	s0,16(sp)
    8000570e:	e426                	sd	s1,8(sp)
    80005710:	e04a                	sd	s2,0(sp)
    80005712:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005714:	00002597          	auipc	a1,0x2
    80005718:	f1c58593          	addi	a1,a1,-228 # 80007630 <etext+0x630>
    8000571c:	0001b517          	auipc	a0,0x1b
    80005720:	65450513          	addi	a0,a0,1620 # 80020d70 <disk+0x128>
    80005724:	c2afb0ef          	jal	80000b4e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005728:	100017b7          	lui	a5,0x10001
    8000572c:	4398                	lw	a4,0(a5)
    8000572e:	2701                	sext.w	a4,a4
    80005730:	747277b7          	lui	a5,0x74727
    80005734:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005738:	18f71063          	bne	a4,a5,800058b8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000573c:	100017b7          	lui	a5,0x10001
    80005740:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005742:	439c                	lw	a5,0(a5)
    80005744:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005746:	4709                	li	a4,2
    80005748:	16e79863          	bne	a5,a4,800058b8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000574c:	100017b7          	lui	a5,0x10001
    80005750:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005752:	439c                	lw	a5,0(a5)
    80005754:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005756:	16e79163          	bne	a5,a4,800058b8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000575a:	100017b7          	lui	a5,0x10001
    8000575e:	47d8                	lw	a4,12(a5)
    80005760:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005762:	554d47b7          	lui	a5,0x554d4
    80005766:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000576a:	14f71763          	bne	a4,a5,800058b8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000576e:	100017b7          	lui	a5,0x10001
    80005772:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005776:	4705                	li	a4,1
    80005778:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000577a:	470d                	li	a4,3
    8000577c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000577e:	10001737          	lui	a4,0x10001
    80005782:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005784:	c7ffe737          	lui	a4,0xc7ffe
    80005788:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd9d7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000578c:	8ef9                	and	a3,a3,a4
    8000578e:	10001737          	lui	a4,0x10001
    80005792:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005794:	472d                	li	a4,11
    80005796:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005798:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000579c:	439c                	lw	a5,0(a5)
    8000579e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800057a2:	8ba1                	andi	a5,a5,8
    800057a4:	12078063          	beqz	a5,800058c4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800057a8:	100017b7          	lui	a5,0x10001
    800057ac:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800057b0:	100017b7          	lui	a5,0x10001
    800057b4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800057b8:	439c                	lw	a5,0(a5)
    800057ba:	2781                	sext.w	a5,a5
    800057bc:	10079a63          	bnez	a5,800058d0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800057c0:	100017b7          	lui	a5,0x10001
    800057c4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800057c8:	439c                	lw	a5,0(a5)
    800057ca:	2781                	sext.w	a5,a5
  if(max == 0)
    800057cc:	10078863          	beqz	a5,800058dc <virtio_disk_init+0x1d4>
  if(max < NUM)
    800057d0:	471d                	li	a4,7
    800057d2:	10f77b63          	bgeu	a4,a5,800058e8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800057d6:	b28fb0ef          	jal	80000afe <kalloc>
    800057da:	0001b497          	auipc	s1,0x1b
    800057de:	46e48493          	addi	s1,s1,1134 # 80020c48 <disk>
    800057e2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800057e4:	b1afb0ef          	jal	80000afe <kalloc>
    800057e8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800057ea:	b14fb0ef          	jal	80000afe <kalloc>
    800057ee:	87aa                	mv	a5,a0
    800057f0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800057f2:	6088                	ld	a0,0(s1)
    800057f4:	10050063          	beqz	a0,800058f4 <virtio_disk_init+0x1ec>
    800057f8:	0001b717          	auipc	a4,0x1b
    800057fc:	45873703          	ld	a4,1112(a4) # 80020c50 <disk+0x8>
    80005800:	0e070a63          	beqz	a4,800058f4 <virtio_disk_init+0x1ec>
    80005804:	0e078863          	beqz	a5,800058f4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005808:	6605                	lui	a2,0x1
    8000580a:	4581                	li	a1,0
    8000580c:	c96fb0ef          	jal	80000ca2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005810:	0001b497          	auipc	s1,0x1b
    80005814:	43848493          	addi	s1,s1,1080 # 80020c48 <disk>
    80005818:	6605                	lui	a2,0x1
    8000581a:	4581                	li	a1,0
    8000581c:	6488                	ld	a0,8(s1)
    8000581e:	c84fb0ef          	jal	80000ca2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005822:	6605                	lui	a2,0x1
    80005824:	4581                	li	a1,0
    80005826:	6888                	ld	a0,16(s1)
    80005828:	c7afb0ef          	jal	80000ca2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000582c:	100017b7          	lui	a5,0x10001
    80005830:	4721                	li	a4,8
    80005832:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005834:	4098                	lw	a4,0(s1)
    80005836:	100017b7          	lui	a5,0x10001
    8000583a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000583e:	40d8                	lw	a4,4(s1)
    80005840:	100017b7          	lui	a5,0x10001
    80005844:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005848:	649c                	ld	a5,8(s1)
    8000584a:	0007869b          	sext.w	a3,a5
    8000584e:	10001737          	lui	a4,0x10001
    80005852:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005856:	9781                	srai	a5,a5,0x20
    80005858:	10001737          	lui	a4,0x10001
    8000585c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005860:	689c                	ld	a5,16(s1)
    80005862:	0007869b          	sext.w	a3,a5
    80005866:	10001737          	lui	a4,0x10001
    8000586a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000586e:	9781                	srai	a5,a5,0x20
    80005870:	10001737          	lui	a4,0x10001
    80005874:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005878:	10001737          	lui	a4,0x10001
    8000587c:	4785                	li	a5,1
    8000587e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005880:	00f48c23          	sb	a5,24(s1)
    80005884:	00f48ca3          	sb	a5,25(s1)
    80005888:	00f48d23          	sb	a5,26(s1)
    8000588c:	00f48da3          	sb	a5,27(s1)
    80005890:	00f48e23          	sb	a5,28(s1)
    80005894:	00f48ea3          	sb	a5,29(s1)
    80005898:	00f48f23          	sb	a5,30(s1)
    8000589c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800058a0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800058a4:	100017b7          	lui	a5,0x10001
    800058a8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800058ac:	60e2                	ld	ra,24(sp)
    800058ae:	6442                	ld	s0,16(sp)
    800058b0:	64a2                	ld	s1,8(sp)
    800058b2:	6902                	ld	s2,0(sp)
    800058b4:	6105                	addi	sp,sp,32
    800058b6:	8082                	ret
    panic("could not find virtio disk");
    800058b8:	00002517          	auipc	a0,0x2
    800058bc:	d8850513          	addi	a0,a0,-632 # 80007640 <etext+0x640>
    800058c0:	f21fa0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    800058c4:	00002517          	auipc	a0,0x2
    800058c8:	d9c50513          	addi	a0,a0,-612 # 80007660 <etext+0x660>
    800058cc:	f15fa0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    800058d0:	00002517          	auipc	a0,0x2
    800058d4:	db050513          	addi	a0,a0,-592 # 80007680 <etext+0x680>
    800058d8:	f09fa0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    800058dc:	00002517          	auipc	a0,0x2
    800058e0:	dc450513          	addi	a0,a0,-572 # 800076a0 <etext+0x6a0>
    800058e4:	efdfa0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    800058e8:	00002517          	auipc	a0,0x2
    800058ec:	dd850513          	addi	a0,a0,-552 # 800076c0 <etext+0x6c0>
    800058f0:	ef1fa0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    800058f4:	00002517          	auipc	a0,0x2
    800058f8:	dec50513          	addi	a0,a0,-532 # 800076e0 <etext+0x6e0>
    800058fc:	ee5fa0ef          	jal	800007e0 <panic>

0000000080005900 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005900:	7159                	addi	sp,sp,-112
    80005902:	f486                	sd	ra,104(sp)
    80005904:	f0a2                	sd	s0,96(sp)
    80005906:	eca6                	sd	s1,88(sp)
    80005908:	e8ca                	sd	s2,80(sp)
    8000590a:	e4ce                	sd	s3,72(sp)
    8000590c:	e0d2                	sd	s4,64(sp)
    8000590e:	fc56                	sd	s5,56(sp)
    80005910:	f85a                	sd	s6,48(sp)
    80005912:	f45e                	sd	s7,40(sp)
    80005914:	f062                	sd	s8,32(sp)
    80005916:	ec66                	sd	s9,24(sp)
    80005918:	1880                	addi	s0,sp,112
    8000591a:	8a2a                	mv	s4,a0
    8000591c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000591e:	00c52c83          	lw	s9,12(a0)
    80005922:	001c9c9b          	slliw	s9,s9,0x1
    80005926:	1c82                	slli	s9,s9,0x20
    80005928:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000592c:	0001b517          	auipc	a0,0x1b
    80005930:	44450513          	addi	a0,a0,1092 # 80020d70 <disk+0x128>
    80005934:	a9afb0ef          	jal	80000bce <acquire>
  for(int i = 0; i < 3; i++){
    80005938:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000593a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000593c:	0001bb17          	auipc	s6,0x1b
    80005940:	30cb0b13          	addi	s6,s6,780 # 80020c48 <disk>
  for(int i = 0; i < 3; i++){
    80005944:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005946:	0001bc17          	auipc	s8,0x1b
    8000594a:	42ac0c13          	addi	s8,s8,1066 # 80020d70 <disk+0x128>
    8000594e:	a8b9                	j	800059ac <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005950:	00fb0733          	add	a4,s6,a5
    80005954:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005958:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000595a:	0207c563          	bltz	a5,80005984 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000595e:	2905                	addiw	s2,s2,1
    80005960:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005962:	05590963          	beq	s2,s5,800059b4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005966:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005968:	0001b717          	auipc	a4,0x1b
    8000596c:	2e070713          	addi	a4,a4,736 # 80020c48 <disk>
    80005970:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005972:	01874683          	lbu	a3,24(a4)
    80005976:	fee9                	bnez	a3,80005950 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005978:	2785                	addiw	a5,a5,1
    8000597a:	0705                	addi	a4,a4,1
    8000597c:	fe979be3          	bne	a5,s1,80005972 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005980:	57fd                	li	a5,-1
    80005982:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005984:	01205d63          	blez	s2,8000599e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005988:	f9042503          	lw	a0,-112(s0)
    8000598c:	d07ff0ef          	jal	80005692 <free_desc>
      for(int j = 0; j < i; j++)
    80005990:	4785                	li	a5,1
    80005992:	0127d663          	bge	a5,s2,8000599e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005996:	f9442503          	lw	a0,-108(s0)
    8000599a:	cf9ff0ef          	jal	80005692 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000599e:	85e2                	mv	a1,s8
    800059a0:	0001b517          	auipc	a0,0x1b
    800059a4:	2c050513          	addi	a0,a0,704 # 80020c60 <disk+0x18>
    800059a8:	d30fc0ef          	jal	80001ed8 <sleep>
  for(int i = 0; i < 3; i++){
    800059ac:	f9040613          	addi	a2,s0,-112
    800059b0:	894e                	mv	s2,s3
    800059b2:	bf55                	j	80005966 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800059b4:	f9042503          	lw	a0,-112(s0)
    800059b8:	00451693          	slli	a3,a0,0x4

  if(write)
    800059bc:	0001b797          	auipc	a5,0x1b
    800059c0:	28c78793          	addi	a5,a5,652 # 80020c48 <disk>
    800059c4:	00a50713          	addi	a4,a0,10
    800059c8:	0712                	slli	a4,a4,0x4
    800059ca:	973e                	add	a4,a4,a5
    800059cc:	01703633          	snez	a2,s7
    800059d0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800059d2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800059d6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800059da:	6398                	ld	a4,0(a5)
    800059dc:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800059de:	0a868613          	addi	a2,a3,168
    800059e2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800059e4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800059e6:	6390                	ld	a2,0(a5)
    800059e8:	00d605b3          	add	a1,a2,a3
    800059ec:	4741                	li	a4,16
    800059ee:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800059f0:	4805                	li	a6,1
    800059f2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800059f6:	f9442703          	lw	a4,-108(s0)
    800059fa:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800059fe:	0712                	slli	a4,a4,0x4
    80005a00:	963a                	add	a2,a2,a4
    80005a02:	058a0593          	addi	a1,s4,88
    80005a06:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005a08:	0007b883          	ld	a7,0(a5)
    80005a0c:	9746                	add	a4,a4,a7
    80005a0e:	40000613          	li	a2,1024
    80005a12:	c710                	sw	a2,8(a4)
  if(write)
    80005a14:	001bb613          	seqz	a2,s7
    80005a18:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005a1c:	00166613          	ori	a2,a2,1
    80005a20:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005a24:	f9842583          	lw	a1,-104(s0)
    80005a28:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005a2c:	00250613          	addi	a2,a0,2
    80005a30:	0612                	slli	a2,a2,0x4
    80005a32:	963e                	add	a2,a2,a5
    80005a34:	577d                	li	a4,-1
    80005a36:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005a3a:	0592                	slli	a1,a1,0x4
    80005a3c:	98ae                	add	a7,a7,a1
    80005a3e:	03068713          	addi	a4,a3,48
    80005a42:	973e                	add	a4,a4,a5
    80005a44:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005a48:	6398                	ld	a4,0(a5)
    80005a4a:	972e                	add	a4,a4,a1
    80005a4c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005a50:	4689                	li	a3,2
    80005a52:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005a56:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005a5a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005a5e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005a62:	6794                	ld	a3,8(a5)
    80005a64:	0026d703          	lhu	a4,2(a3)
    80005a68:	8b1d                	andi	a4,a4,7
    80005a6a:	0706                	slli	a4,a4,0x1
    80005a6c:	96ba                	add	a3,a3,a4
    80005a6e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005a72:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005a76:	6798                	ld	a4,8(a5)
    80005a78:	00275783          	lhu	a5,2(a4)
    80005a7c:	2785                	addiw	a5,a5,1
    80005a7e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005a82:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005a86:	100017b7          	lui	a5,0x10001
    80005a8a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005a8e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005a92:	0001b917          	auipc	s2,0x1b
    80005a96:	2de90913          	addi	s2,s2,734 # 80020d70 <disk+0x128>
  while(b->disk == 1) {
    80005a9a:	4485                	li	s1,1
    80005a9c:	01079a63          	bne	a5,a6,80005ab0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005aa0:	85ca                	mv	a1,s2
    80005aa2:	8552                	mv	a0,s4
    80005aa4:	c34fc0ef          	jal	80001ed8 <sleep>
  while(b->disk == 1) {
    80005aa8:	004a2783          	lw	a5,4(s4)
    80005aac:	fe978ae3          	beq	a5,s1,80005aa0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005ab0:	f9042903          	lw	s2,-112(s0)
    80005ab4:	00290713          	addi	a4,s2,2
    80005ab8:	0712                	slli	a4,a4,0x4
    80005aba:	0001b797          	auipc	a5,0x1b
    80005abe:	18e78793          	addi	a5,a5,398 # 80020c48 <disk>
    80005ac2:	97ba                	add	a5,a5,a4
    80005ac4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005ac8:	0001b997          	auipc	s3,0x1b
    80005acc:	18098993          	addi	s3,s3,384 # 80020c48 <disk>
    80005ad0:	00491713          	slli	a4,s2,0x4
    80005ad4:	0009b783          	ld	a5,0(s3)
    80005ad8:	97ba                	add	a5,a5,a4
    80005ada:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005ade:	854a                	mv	a0,s2
    80005ae0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005ae4:	bafff0ef          	jal	80005692 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005ae8:	8885                	andi	s1,s1,1
    80005aea:	f0fd                	bnez	s1,80005ad0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005aec:	0001b517          	auipc	a0,0x1b
    80005af0:	28450513          	addi	a0,a0,644 # 80020d70 <disk+0x128>
    80005af4:	972fb0ef          	jal	80000c66 <release>
}
    80005af8:	70a6                	ld	ra,104(sp)
    80005afa:	7406                	ld	s0,96(sp)
    80005afc:	64e6                	ld	s1,88(sp)
    80005afe:	6946                	ld	s2,80(sp)
    80005b00:	69a6                	ld	s3,72(sp)
    80005b02:	6a06                	ld	s4,64(sp)
    80005b04:	7ae2                	ld	s5,56(sp)
    80005b06:	7b42                	ld	s6,48(sp)
    80005b08:	7ba2                	ld	s7,40(sp)
    80005b0a:	7c02                	ld	s8,32(sp)
    80005b0c:	6ce2                	ld	s9,24(sp)
    80005b0e:	6165                	addi	sp,sp,112
    80005b10:	8082                	ret

0000000080005b12 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005b12:	1101                	addi	sp,sp,-32
    80005b14:	ec06                	sd	ra,24(sp)
    80005b16:	e822                	sd	s0,16(sp)
    80005b18:	e426                	sd	s1,8(sp)
    80005b1a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005b1c:	0001b497          	auipc	s1,0x1b
    80005b20:	12c48493          	addi	s1,s1,300 # 80020c48 <disk>
    80005b24:	0001b517          	auipc	a0,0x1b
    80005b28:	24c50513          	addi	a0,a0,588 # 80020d70 <disk+0x128>
    80005b2c:	8a2fb0ef          	jal	80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005b30:	100017b7          	lui	a5,0x10001
    80005b34:	53b8                	lw	a4,96(a5)
    80005b36:	8b0d                	andi	a4,a4,3
    80005b38:	100017b7          	lui	a5,0x10001
    80005b3c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005b3e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005b42:	689c                	ld	a5,16(s1)
    80005b44:	0204d703          	lhu	a4,32(s1)
    80005b48:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005b4c:	04f70663          	beq	a4,a5,80005b98 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005b50:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005b54:	6898                	ld	a4,16(s1)
    80005b56:	0204d783          	lhu	a5,32(s1)
    80005b5a:	8b9d                	andi	a5,a5,7
    80005b5c:	078e                	slli	a5,a5,0x3
    80005b5e:	97ba                	add	a5,a5,a4
    80005b60:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005b62:	00278713          	addi	a4,a5,2
    80005b66:	0712                	slli	a4,a4,0x4
    80005b68:	9726                	add	a4,a4,s1
    80005b6a:	01074703          	lbu	a4,16(a4)
    80005b6e:	e321                	bnez	a4,80005bae <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005b70:	0789                	addi	a5,a5,2
    80005b72:	0792                	slli	a5,a5,0x4
    80005b74:	97a6                	add	a5,a5,s1
    80005b76:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005b78:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005b7c:	ba8fc0ef          	jal	80001f24 <wakeup>

    disk.used_idx += 1;
    80005b80:	0204d783          	lhu	a5,32(s1)
    80005b84:	2785                	addiw	a5,a5,1
    80005b86:	17c2                	slli	a5,a5,0x30
    80005b88:	93c1                	srli	a5,a5,0x30
    80005b8a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005b8e:	6898                	ld	a4,16(s1)
    80005b90:	00275703          	lhu	a4,2(a4)
    80005b94:	faf71ee3          	bne	a4,a5,80005b50 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005b98:	0001b517          	auipc	a0,0x1b
    80005b9c:	1d850513          	addi	a0,a0,472 # 80020d70 <disk+0x128>
    80005ba0:	8c6fb0ef          	jal	80000c66 <release>
}
    80005ba4:	60e2                	ld	ra,24(sp)
    80005ba6:	6442                	ld	s0,16(sp)
    80005ba8:	64a2                	ld	s1,8(sp)
    80005baa:	6105                	addi	sp,sp,32
    80005bac:	8082                	ret
      panic("virtio_disk_intr status");
    80005bae:	00002517          	auipc	a0,0x2
    80005bb2:	b4a50513          	addi	a0,a0,-1206 # 800076f8 <etext+0x6f8>
    80005bb6:	c2bfa0ef          	jal	800007e0 <panic>
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
