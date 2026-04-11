
user/_mlfqtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cpu_bound>:
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"
// CPU bound process - uses full quantum
void cpu_bound(int n)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  int sum = 0;
  for(int i = 0; i < n; i++)
   8:	02a05263          	blez	a0,2c <cpu_bound+0x2c>
   c:	4781                	li	a5,0
  int sum = 0;
   e:	4581                	li	a1,0
    sum += i;
  10:	9dbd                	addw	a1,a1,a5
  for(int i = 0; i < n; i++)
  12:	2785                	addiw	a5,a5,1
  14:	fef51ee3          	bne	a0,a5,10 <cpu_bound+0x10>
  printf("cpu_bound: sum = %d\n", sum);
  18:	00001517          	auipc	a0,0x1
  1c:	9f850513          	addi	a0,a0,-1544 # a10 <malloc+0x104>
  20:	039000ef          	jal	858 <printf>
}
  24:	60a2                	ld	ra,8(sp)
  26:	6402                	ld	s0,0(sp)
  28:	0141                	addi	sp,sp,16
  2a:	8082                	ret
  int sum = 0;
  2c:	4581                	li	a1,0
  2e:	b7ed                	j	18 <cpu_bound+0x18>

0000000000000030 <io_bound>:

// IO bound process - yields frequently
void io_bound(int n)
{
  for(int i = 0; i < n; i++){
  30:	06a05463          	blez	a0,98 <io_bound+0x68>
{
  34:	7139                	addi	sp,sp,-64
  36:	fc06                	sd	ra,56(sp)
  38:	f822                	sd	s0,48(sp)
  3a:	f426                	sd	s1,40(sp)
  3c:	f04a                	sd	s2,32(sp)
  3e:	ec4e                	sd	s3,24(sp)
  40:	e852                	sd	s4,16(sp)
  42:	0080                	addi	s0,sp,64
  44:	89aa                	mv	s3,a0
  for(int i = 0; i < n; i++){
  46:	4901                	li	s2,0
    printf("io_bound: iteration %d\n", i);
  48:	00001a17          	auipc	s4,0x1
  4c:	9e8a0a13          	addi	s4,s4,-1560 # a30 <malloc+0x124>
    // simulate IO wait with busy loop
    for(volatile int j = 0; j < 1000000; j++);
  50:	000f44b7          	lui	s1,0xf4
  54:	23f48493          	addi	s1,s1,575 # f423f <base+0xf322f>
    printf("io_bound: iteration %d\n", i);
  58:	85ca                	mv	a1,s2
  5a:	8552                	mv	a0,s4
  5c:	7fc000ef          	jal	858 <printf>
    for(volatile int j = 0; j < 1000000; j++);
  60:	fc042623          	sw	zero,-52(s0)
  64:	fcc42783          	lw	a5,-52(s0)
  68:	2781                	sext.w	a5,a5
  6a:	00f4cc63          	blt	s1,a5,82 <io_bound+0x52>
  6e:	fcc42783          	lw	a5,-52(s0)
  72:	2785                	addiw	a5,a5,1
  74:	fcf42623          	sw	a5,-52(s0)
  78:	fcc42783          	lw	a5,-52(s0)
  7c:	2781                	sext.w	a5,a5
  7e:	fef4d8e3          	bge	s1,a5,6e <io_bound+0x3e>
  for(int i = 0; i < n; i++){
  82:	2905                	addiw	s2,s2,1
  84:	fd299ae3          	bne	s3,s2,58 <io_bound+0x28>
  }
}
  88:	70e2                	ld	ra,56(sp)
  8a:	7442                	ld	s0,48(sp)
  8c:	74a2                	ld	s1,40(sp)
  8e:	7902                	ld	s2,32(sp)
  90:	69e2                	ld	s3,24(sp)
  92:	6a42                	ld	s4,16(sp)
  94:	6121                	addi	sp,sp,64
  96:	8082                	ret
  98:	8082                	ret

000000000000009a <main>:

int
main(void)
{
  9a:	1101                	addi	sp,sp,-32
  9c:	ec06                	sd	ra,24(sp)
  9e:	e822                	sd	s0,16(sp)
  a0:	1000                	addi	s0,sp,32
  printf("=== MLFQ Scheduling Test ===\n");
  a2:	00001517          	auipc	a0,0x1
  a6:	9a650513          	addi	a0,a0,-1626 # a48 <malloc+0x13c>
  aa:	7ae000ef          	jal	858 <printf>
  printf("Processes start at Queue 0 (highest priority)\n");
  ae:	00001517          	auipc	a0,0x1
  b2:	9ba50513          	addi	a0,a0,-1606 # a68 <malloc+0x15c>
  b6:	7a2000ef          	jal	858 <printf>
  printf("CPU bound processes move to lower queues\n");
  ba:	00001517          	auipc	a0,0x1
  be:	9de50513          	addi	a0,a0,-1570 # a98 <malloc+0x18c>
  c2:	796000ef          	jal	858 <printf>
  printf("IO bound processes stay at higher queues\n\n");
  c6:	00001517          	auipc	a0,0x1
  ca:	a0250513          	addi	a0,a0,-1534 # ac8 <malloc+0x1bc>
  ce:	78a000ef          	jal	858 <printf>

  int pid1 = fork();
  d2:	356000ef          	jal	428 <fork>
  if(pid1 == 0){
  d6:	ed0d                	bnez	a0,110 <main+0x76>
  d8:	e426                	sd	s1,8(sp)
    // Child 1 - CPU bound
    printf("Process %d: CPU bound task starting (Queue 0)\n", getpid());
  da:	3d6000ef          	jal	4b0 <getpid>
  de:	85aa                	mv	a1,a0
  e0:	00001517          	auipc	a0,0x1
  e4:	a1850513          	addi	a0,a0,-1512 # af8 <malloc+0x1ec>
  e8:	770000ef          	jal	858 <printf>
    cpu_bound(1000000);
  ec:	000f4537          	lui	a0,0xf4
  f0:	24050513          	addi	a0,a0,576 # f4240 <base+0xf3230>
  f4:	f0dff0ef          	jal	0 <cpu_bound>
    printf("Process %d: CPU bound task done (moved to lower queue)\n", getpid());
  f8:	3b8000ef          	jal	4b0 <getpid>
  fc:	85aa                	mv	a1,a0
  fe:	00001517          	auipc	a0,0x1
 102:	a2a50513          	addi	a0,a0,-1494 # b28 <malloc+0x21c>
 106:	752000ef          	jal	858 <printf>
    exit(0);
 10a:	4501                	li	a0,0
 10c:	324000ef          	jal	430 <exit>
 110:	e426                	sd	s1,8(sp)
 112:	84aa                	mv	s1,a0
  }

  int pid2 = fork();
 114:	314000ef          	jal	428 <fork>
 118:	862a                	mv	a2,a0
  if(pid2 == 0){
 11a:	e90d                	bnez	a0,14c <main+0xb2>
    // Child 2 - IO bound
    printf("Process %d: IO bound task starting (Queue 0)\n", getpid());
 11c:	394000ef          	jal	4b0 <getpid>
 120:	85aa                	mv	a1,a0
 122:	00001517          	auipc	a0,0x1
 126:	a3e50513          	addi	a0,a0,-1474 # b60 <malloc+0x254>
 12a:	72e000ef          	jal	858 <printf>
    io_bound(3);
 12e:	450d                	li	a0,3
 130:	f01ff0ef          	jal	30 <io_bound>
    printf("Process %d: IO bound task done (stayed in high queue)\n", getpid());
 134:	37c000ef          	jal	4b0 <getpid>
 138:	85aa                	mv	a1,a0
 13a:	00001517          	auipc	a0,0x1
 13e:	a5650513          	addi	a0,a0,-1450 # b90 <malloc+0x284>
 142:	716000ef          	jal	858 <printf>
    exit(0);
 146:	4501                	li	a0,0
 148:	2e8000ef          	jal	430 <exit>
  }

  // Parent waits for both
  printf("Parent: waiting for processes %d and %d\n", pid1, pid2);
 14c:	85a6                	mv	a1,s1
 14e:	00001517          	auipc	a0,0x1
 152:	a7a50513          	addi	a0,a0,-1414 # bc8 <malloc+0x2bc>
 156:	702000ef          	jal	858 <printf>
  wait(0);
 15a:	4501                	li	a0,0
 15c:	2dc000ef          	jal	438 <wait>
  wait(0);
 160:	4501                	li	a0,0
 162:	2d6000ef          	jal	438 <wait>
  printf("\n=== MLFQ Test Complete ===\n");
 166:	00001517          	auipc	a0,0x1
 16a:	a9250513          	addi	a0,a0,-1390 # bf8 <malloc+0x2ec>
 16e:	6ea000ef          	jal	858 <printf>
  printf("Queue 0 (quantum=1): highest priority, IO bound\n");
 172:	00001517          	auipc	a0,0x1
 176:	aa650513          	addi	a0,a0,-1370 # c18 <malloc+0x30c>
 17a:	6de000ef          	jal	858 <printf>
  printf("Queue 1 (quantum=2): medium priority\n");
 17e:	00001517          	auipc	a0,0x1
 182:	ad250513          	addi	a0,a0,-1326 # c50 <malloc+0x344>
 186:	6d2000ef          	jal	858 <printf>
  printf("Queue 2 (quantum=4): lowest priority, CPU bound\n");
 18a:	00001517          	auipc	a0,0x1
 18e:	aee50513          	addi	a0,a0,-1298 # c78 <malloc+0x36c>
 192:	6c6000ef          	jal	858 <printf>

  exit(0);
 196:	4501                	li	a0,0
 198:	298000ef          	jal	430 <exit>

000000000000019c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 19c:	1141                	addi	sp,sp,-16
 19e:	e406                	sd	ra,8(sp)
 1a0:	e022                	sd	s0,0(sp)
 1a2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1a4:	ef7ff0ef          	jal	9a <main>
  exit(r);
 1a8:	288000ef          	jal	430 <exit>

00000000000001ac <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1ac:	1141                	addi	sp,sp,-16
 1ae:	e422                	sd	s0,8(sp)
 1b0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1b2:	87aa                	mv	a5,a0
 1b4:	0585                	addi	a1,a1,1
 1b6:	0785                	addi	a5,a5,1
 1b8:	fff5c703          	lbu	a4,-1(a1)
 1bc:	fee78fa3          	sb	a4,-1(a5)
 1c0:	fb75                	bnez	a4,1b4 <strcpy+0x8>
    ;
  return os;
}
 1c2:	6422                	ld	s0,8(sp)
 1c4:	0141                	addi	sp,sp,16
 1c6:	8082                	ret

00000000000001c8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1c8:	1141                	addi	sp,sp,-16
 1ca:	e422                	sd	s0,8(sp)
 1cc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1ce:	00054783          	lbu	a5,0(a0)
 1d2:	cb91                	beqz	a5,1e6 <strcmp+0x1e>
 1d4:	0005c703          	lbu	a4,0(a1)
 1d8:	00f71763          	bne	a4,a5,1e6 <strcmp+0x1e>
    p++, q++;
 1dc:	0505                	addi	a0,a0,1
 1de:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1e0:	00054783          	lbu	a5,0(a0)
 1e4:	fbe5                	bnez	a5,1d4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1e6:	0005c503          	lbu	a0,0(a1)
}
 1ea:	40a7853b          	subw	a0,a5,a0
 1ee:	6422                	ld	s0,8(sp)
 1f0:	0141                	addi	sp,sp,16
 1f2:	8082                	ret

00000000000001f4 <strlen>:

uint
strlen(const char *s)
{
 1f4:	1141                	addi	sp,sp,-16
 1f6:	e422                	sd	s0,8(sp)
 1f8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1fa:	00054783          	lbu	a5,0(a0)
 1fe:	cf91                	beqz	a5,21a <strlen+0x26>
 200:	0505                	addi	a0,a0,1
 202:	87aa                	mv	a5,a0
 204:	86be                	mv	a3,a5
 206:	0785                	addi	a5,a5,1
 208:	fff7c703          	lbu	a4,-1(a5)
 20c:	ff65                	bnez	a4,204 <strlen+0x10>
 20e:	40a6853b          	subw	a0,a3,a0
 212:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 214:	6422                	ld	s0,8(sp)
 216:	0141                	addi	sp,sp,16
 218:	8082                	ret
  for(n = 0; s[n]; n++)
 21a:	4501                	li	a0,0
 21c:	bfe5                	j	214 <strlen+0x20>

000000000000021e <memset>:

void*
memset(void *dst, int c, uint n)
{
 21e:	1141                	addi	sp,sp,-16
 220:	e422                	sd	s0,8(sp)
 222:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 224:	ca19                	beqz	a2,23a <memset+0x1c>
 226:	87aa                	mv	a5,a0
 228:	1602                	slli	a2,a2,0x20
 22a:	9201                	srli	a2,a2,0x20
 22c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 230:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 234:	0785                	addi	a5,a5,1
 236:	fee79de3          	bne	a5,a4,230 <memset+0x12>
  }
  return dst;
}
 23a:	6422                	ld	s0,8(sp)
 23c:	0141                	addi	sp,sp,16
 23e:	8082                	ret

0000000000000240 <strchr>:

char*
strchr(const char *s, char c)
{
 240:	1141                	addi	sp,sp,-16
 242:	e422                	sd	s0,8(sp)
 244:	0800                	addi	s0,sp,16
  for(; *s; s++)
 246:	00054783          	lbu	a5,0(a0)
 24a:	cb99                	beqz	a5,260 <strchr+0x20>
    if(*s == c)
 24c:	00f58763          	beq	a1,a5,25a <strchr+0x1a>
  for(; *s; s++)
 250:	0505                	addi	a0,a0,1
 252:	00054783          	lbu	a5,0(a0)
 256:	fbfd                	bnez	a5,24c <strchr+0xc>
      return (char*)s;
  return 0;
 258:	4501                	li	a0,0
}
 25a:	6422                	ld	s0,8(sp)
 25c:	0141                	addi	sp,sp,16
 25e:	8082                	ret
  return 0;
 260:	4501                	li	a0,0
 262:	bfe5                	j	25a <strchr+0x1a>

0000000000000264 <gets>:

char*
gets(char *buf, int max)
{
 264:	711d                	addi	sp,sp,-96
 266:	ec86                	sd	ra,88(sp)
 268:	e8a2                	sd	s0,80(sp)
 26a:	e4a6                	sd	s1,72(sp)
 26c:	e0ca                	sd	s2,64(sp)
 26e:	fc4e                	sd	s3,56(sp)
 270:	f852                	sd	s4,48(sp)
 272:	f456                	sd	s5,40(sp)
 274:	f05a                	sd	s6,32(sp)
 276:	ec5e                	sd	s7,24(sp)
 278:	1080                	addi	s0,sp,96
 27a:	8baa                	mv	s7,a0
 27c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 27e:	892a                	mv	s2,a0
 280:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 282:	4aa9                	li	s5,10
 284:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 286:	89a6                	mv	s3,s1
 288:	2485                	addiw	s1,s1,1
 28a:	0344d663          	bge	s1,s4,2b6 <gets+0x52>
    cc = read(0, &c, 1);
 28e:	4605                	li	a2,1
 290:	faf40593          	addi	a1,s0,-81
 294:	4501                	li	a0,0
 296:	1b2000ef          	jal	448 <read>
    if(cc < 1)
 29a:	00a05e63          	blez	a0,2b6 <gets+0x52>
    buf[i++] = c;
 29e:	faf44783          	lbu	a5,-81(s0)
 2a2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2a6:	01578763          	beq	a5,s5,2b4 <gets+0x50>
 2aa:	0905                	addi	s2,s2,1
 2ac:	fd679de3          	bne	a5,s6,286 <gets+0x22>
    buf[i++] = c;
 2b0:	89a6                	mv	s3,s1
 2b2:	a011                	j	2b6 <gets+0x52>
 2b4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2b6:	99de                	add	s3,s3,s7
 2b8:	00098023          	sb	zero,0(s3)
  return buf;
}
 2bc:	855e                	mv	a0,s7
 2be:	60e6                	ld	ra,88(sp)
 2c0:	6446                	ld	s0,80(sp)
 2c2:	64a6                	ld	s1,72(sp)
 2c4:	6906                	ld	s2,64(sp)
 2c6:	79e2                	ld	s3,56(sp)
 2c8:	7a42                	ld	s4,48(sp)
 2ca:	7aa2                	ld	s5,40(sp)
 2cc:	7b02                	ld	s6,32(sp)
 2ce:	6be2                	ld	s7,24(sp)
 2d0:	6125                	addi	sp,sp,96
 2d2:	8082                	ret

00000000000002d4 <stat>:

int
stat(const char *n, struct stat *st)
{
 2d4:	1101                	addi	sp,sp,-32
 2d6:	ec06                	sd	ra,24(sp)
 2d8:	e822                	sd	s0,16(sp)
 2da:	e04a                	sd	s2,0(sp)
 2dc:	1000                	addi	s0,sp,32
 2de:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2e0:	4581                	li	a1,0
 2e2:	18e000ef          	jal	470 <open>
  if(fd < 0)
 2e6:	02054263          	bltz	a0,30a <stat+0x36>
 2ea:	e426                	sd	s1,8(sp)
 2ec:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2ee:	85ca                	mv	a1,s2
 2f0:	198000ef          	jal	488 <fstat>
 2f4:	892a                	mv	s2,a0
  close(fd);
 2f6:	8526                	mv	a0,s1
 2f8:	160000ef          	jal	458 <close>
  return r;
 2fc:	64a2                	ld	s1,8(sp)
}
 2fe:	854a                	mv	a0,s2
 300:	60e2                	ld	ra,24(sp)
 302:	6442                	ld	s0,16(sp)
 304:	6902                	ld	s2,0(sp)
 306:	6105                	addi	sp,sp,32
 308:	8082                	ret
    return -1;
 30a:	597d                	li	s2,-1
 30c:	bfcd                	j	2fe <stat+0x2a>

000000000000030e <atoi>:

int
atoi(const char *s)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e422                	sd	s0,8(sp)
 312:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 314:	00054683          	lbu	a3,0(a0)
 318:	fd06879b          	addiw	a5,a3,-48
 31c:	0ff7f793          	zext.b	a5,a5
 320:	4625                	li	a2,9
 322:	02f66863          	bltu	a2,a5,352 <atoi+0x44>
 326:	872a                	mv	a4,a0
  n = 0;
 328:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 32a:	0705                	addi	a4,a4,1
 32c:	0025179b          	slliw	a5,a0,0x2
 330:	9fa9                	addw	a5,a5,a0
 332:	0017979b          	slliw	a5,a5,0x1
 336:	9fb5                	addw	a5,a5,a3
 338:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 33c:	00074683          	lbu	a3,0(a4)
 340:	fd06879b          	addiw	a5,a3,-48
 344:	0ff7f793          	zext.b	a5,a5
 348:	fef671e3          	bgeu	a2,a5,32a <atoi+0x1c>
  return n;
}
 34c:	6422                	ld	s0,8(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret
  n = 0;
 352:	4501                	li	a0,0
 354:	bfe5                	j	34c <atoi+0x3e>

0000000000000356 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 356:	1141                	addi	sp,sp,-16
 358:	e422                	sd	s0,8(sp)
 35a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 35c:	02b57463          	bgeu	a0,a1,384 <memmove+0x2e>
    while(n-- > 0)
 360:	00c05f63          	blez	a2,37e <memmove+0x28>
 364:	1602                	slli	a2,a2,0x20
 366:	9201                	srli	a2,a2,0x20
 368:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 36c:	872a                	mv	a4,a0
      *dst++ = *src++;
 36e:	0585                	addi	a1,a1,1
 370:	0705                	addi	a4,a4,1
 372:	fff5c683          	lbu	a3,-1(a1)
 376:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 37a:	fef71ae3          	bne	a4,a5,36e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 37e:	6422                	ld	s0,8(sp)
 380:	0141                	addi	sp,sp,16
 382:	8082                	ret
    dst += n;
 384:	00c50733          	add	a4,a0,a2
    src += n;
 388:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 38a:	fec05ae3          	blez	a2,37e <memmove+0x28>
 38e:	fff6079b          	addiw	a5,a2,-1
 392:	1782                	slli	a5,a5,0x20
 394:	9381                	srli	a5,a5,0x20
 396:	fff7c793          	not	a5,a5
 39a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 39c:	15fd                	addi	a1,a1,-1
 39e:	177d                	addi	a4,a4,-1
 3a0:	0005c683          	lbu	a3,0(a1)
 3a4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3a8:	fee79ae3          	bne	a5,a4,39c <memmove+0x46>
 3ac:	bfc9                	j	37e <memmove+0x28>

00000000000003ae <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3ae:	1141                	addi	sp,sp,-16
 3b0:	e422                	sd	s0,8(sp)
 3b2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3b4:	ca05                	beqz	a2,3e4 <memcmp+0x36>
 3b6:	fff6069b          	addiw	a3,a2,-1
 3ba:	1682                	slli	a3,a3,0x20
 3bc:	9281                	srli	a3,a3,0x20
 3be:	0685                	addi	a3,a3,1
 3c0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3c2:	00054783          	lbu	a5,0(a0)
 3c6:	0005c703          	lbu	a4,0(a1)
 3ca:	00e79863          	bne	a5,a4,3da <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3ce:	0505                	addi	a0,a0,1
    p2++;
 3d0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3d2:	fed518e3          	bne	a0,a3,3c2 <memcmp+0x14>
  }
  return 0;
 3d6:	4501                	li	a0,0
 3d8:	a019                	j	3de <memcmp+0x30>
      return *p1 - *p2;
 3da:	40e7853b          	subw	a0,a5,a4
}
 3de:	6422                	ld	s0,8(sp)
 3e0:	0141                	addi	sp,sp,16
 3e2:	8082                	ret
  return 0;
 3e4:	4501                	li	a0,0
 3e6:	bfe5                	j	3de <memcmp+0x30>

00000000000003e8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3e8:	1141                	addi	sp,sp,-16
 3ea:	e406                	sd	ra,8(sp)
 3ec:	e022                	sd	s0,0(sp)
 3ee:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3f0:	f67ff0ef          	jal	356 <memmove>
}
 3f4:	60a2                	ld	ra,8(sp)
 3f6:	6402                	ld	s0,0(sp)
 3f8:	0141                	addi	sp,sp,16
 3fa:	8082                	ret

00000000000003fc <sbrk>:

char *
sbrk(int n) {
 3fc:	1141                	addi	sp,sp,-16
 3fe:	e406                	sd	ra,8(sp)
 400:	e022                	sd	s0,0(sp)
 402:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 404:	4585                	li	a1,1
 406:	0b2000ef          	jal	4b8 <sys_sbrk>
}
 40a:	60a2                	ld	ra,8(sp)
 40c:	6402                	ld	s0,0(sp)
 40e:	0141                	addi	sp,sp,16
 410:	8082                	ret

0000000000000412 <sbrklazy>:

char *
sbrklazy(int n) {
 412:	1141                	addi	sp,sp,-16
 414:	e406                	sd	ra,8(sp)
 416:	e022                	sd	s0,0(sp)
 418:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 41a:	4589                	li	a1,2
 41c:	09c000ef          	jal	4b8 <sys_sbrk>
}
 420:	60a2                	ld	ra,8(sp)
 422:	6402                	ld	s0,0(sp)
 424:	0141                	addi	sp,sp,16
 426:	8082                	ret

0000000000000428 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 428:	4885                	li	a7,1
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <exit>:
.global exit
exit:
 li a7, SYS_exit
 430:	4889                	li	a7,2
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <wait>:
.global wait
wait:
 li a7, SYS_wait
 438:	488d                	li	a7,3
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 440:	4891                	li	a7,4
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <read>:
.global read
read:
 li a7, SYS_read
 448:	4895                	li	a7,5
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <write>:
.global write
write:
 li a7, SYS_write
 450:	48c1                	li	a7,16
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <close>:
.global close
close:
 li a7, SYS_close
 458:	48d5                	li	a7,21
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <kill>:
.global kill
kill:
 li a7, SYS_kill
 460:	4899                	li	a7,6
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <exec>:
.global exec
exec:
 li a7, SYS_exec
 468:	489d                	li	a7,7
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <open>:
.global open
open:
 li a7, SYS_open
 470:	48bd                	li	a7,15
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 478:	48c5                	li	a7,17
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 480:	48c9                	li	a7,18
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 488:	48a1                	li	a7,8
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <link>:
.global link
link:
 li a7, SYS_link
 490:	48cd                	li	a7,19
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 498:	48d1                	li	a7,20
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4a0:	48a5                	li	a7,9
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4a8:	48a9                	li	a7,10
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4b0:	48ad                	li	a7,11
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4b8:	48b1                	li	a7,12
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <pause>:
.global pause
pause:
 li a7, SYS_pause
 4c0:	48b5                	li	a7,13
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4c8:	48b9                	li	a7,14
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4d0:	1101                	addi	sp,sp,-32
 4d2:	ec06                	sd	ra,24(sp)
 4d4:	e822                	sd	s0,16(sp)
 4d6:	1000                	addi	s0,sp,32
 4d8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4dc:	4605                	li	a2,1
 4de:	fef40593          	addi	a1,s0,-17
 4e2:	f6fff0ef          	jal	450 <write>
}
 4e6:	60e2                	ld	ra,24(sp)
 4e8:	6442                	ld	s0,16(sp)
 4ea:	6105                	addi	sp,sp,32
 4ec:	8082                	ret

00000000000004ee <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4ee:	715d                	addi	sp,sp,-80
 4f0:	e486                	sd	ra,72(sp)
 4f2:	e0a2                	sd	s0,64(sp)
 4f4:	f84a                	sd	s2,48(sp)
 4f6:	0880                	addi	s0,sp,80
 4f8:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4fa:	c299                	beqz	a3,500 <printint+0x12>
 4fc:	0805c363          	bltz	a1,582 <printint+0x94>
  neg = 0;
 500:	4881                	li	a7,0
 502:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 506:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 508:	00000517          	auipc	a0,0x0
 50c:	7b050513          	addi	a0,a0,1968 # cb8 <digits>
 510:	883e                	mv	a6,a5
 512:	2785                	addiw	a5,a5,1
 514:	02c5f733          	remu	a4,a1,a2
 518:	972a                	add	a4,a4,a0
 51a:	00074703          	lbu	a4,0(a4)
 51e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 522:	872e                	mv	a4,a1
 524:	02c5d5b3          	divu	a1,a1,a2
 528:	0685                	addi	a3,a3,1
 52a:	fec773e3          	bgeu	a4,a2,510 <printint+0x22>
  if(neg)
 52e:	00088b63          	beqz	a7,544 <printint+0x56>
    buf[i++] = '-';
 532:	fd078793          	addi	a5,a5,-48
 536:	97a2                	add	a5,a5,s0
 538:	02d00713          	li	a4,45
 53c:	fee78423          	sb	a4,-24(a5)
 540:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 544:	02f05a63          	blez	a5,578 <printint+0x8a>
 548:	fc26                	sd	s1,56(sp)
 54a:	f44e                	sd	s3,40(sp)
 54c:	fb840713          	addi	a4,s0,-72
 550:	00f704b3          	add	s1,a4,a5
 554:	fff70993          	addi	s3,a4,-1
 558:	99be                	add	s3,s3,a5
 55a:	37fd                	addiw	a5,a5,-1
 55c:	1782                	slli	a5,a5,0x20
 55e:	9381                	srli	a5,a5,0x20
 560:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 564:	fff4c583          	lbu	a1,-1(s1)
 568:	854a                	mv	a0,s2
 56a:	f67ff0ef          	jal	4d0 <putc>
  while(--i >= 0)
 56e:	14fd                	addi	s1,s1,-1
 570:	ff349ae3          	bne	s1,s3,564 <printint+0x76>
 574:	74e2                	ld	s1,56(sp)
 576:	79a2                	ld	s3,40(sp)
}
 578:	60a6                	ld	ra,72(sp)
 57a:	6406                	ld	s0,64(sp)
 57c:	7942                	ld	s2,48(sp)
 57e:	6161                	addi	sp,sp,80
 580:	8082                	ret
    x = -xx;
 582:	40b005b3          	neg	a1,a1
    neg = 1;
 586:	4885                	li	a7,1
    x = -xx;
 588:	bfad                	j	502 <printint+0x14>

000000000000058a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 58a:	711d                	addi	sp,sp,-96
 58c:	ec86                	sd	ra,88(sp)
 58e:	e8a2                	sd	s0,80(sp)
 590:	e0ca                	sd	s2,64(sp)
 592:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 594:	0005c903          	lbu	s2,0(a1)
 598:	28090663          	beqz	s2,824 <vprintf+0x29a>
 59c:	e4a6                	sd	s1,72(sp)
 59e:	fc4e                	sd	s3,56(sp)
 5a0:	f852                	sd	s4,48(sp)
 5a2:	f456                	sd	s5,40(sp)
 5a4:	f05a                	sd	s6,32(sp)
 5a6:	ec5e                	sd	s7,24(sp)
 5a8:	e862                	sd	s8,16(sp)
 5aa:	e466                	sd	s9,8(sp)
 5ac:	8b2a                	mv	s6,a0
 5ae:	8a2e                	mv	s4,a1
 5b0:	8bb2                	mv	s7,a2
  state = 0;
 5b2:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5b4:	4481                	li	s1,0
 5b6:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5b8:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5bc:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5c0:	06c00c93          	li	s9,108
 5c4:	a005                	j	5e4 <vprintf+0x5a>
        putc(fd, c0);
 5c6:	85ca                	mv	a1,s2
 5c8:	855a                	mv	a0,s6
 5ca:	f07ff0ef          	jal	4d0 <putc>
 5ce:	a019                	j	5d4 <vprintf+0x4a>
    } else if(state == '%'){
 5d0:	03598263          	beq	s3,s5,5f4 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5d4:	2485                	addiw	s1,s1,1
 5d6:	8726                	mv	a4,s1
 5d8:	009a07b3          	add	a5,s4,s1
 5dc:	0007c903          	lbu	s2,0(a5)
 5e0:	22090a63          	beqz	s2,814 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5e4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5e8:	fe0994e3          	bnez	s3,5d0 <vprintf+0x46>
      if(c0 == '%'){
 5ec:	fd579de3          	bne	a5,s5,5c6 <vprintf+0x3c>
        state = '%';
 5f0:	89be                	mv	s3,a5
 5f2:	b7cd                	j	5d4 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5f4:	00ea06b3          	add	a3,s4,a4
 5f8:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5fc:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5fe:	c681                	beqz	a3,606 <vprintf+0x7c>
 600:	9752                	add	a4,a4,s4
 602:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 606:	05878363          	beq	a5,s8,64c <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 60a:	05978d63          	beq	a5,s9,664 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 60e:	07500713          	li	a4,117
 612:	0ee78763          	beq	a5,a4,700 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 616:	07800713          	li	a4,120
 61a:	12e78963          	beq	a5,a4,74c <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 61e:	07000713          	li	a4,112
 622:	14e78e63          	beq	a5,a4,77e <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 626:	06300713          	li	a4,99
 62a:	18e78e63          	beq	a5,a4,7c6 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 62e:	07300713          	li	a4,115
 632:	1ae78463          	beq	a5,a4,7da <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 636:	02500713          	li	a4,37
 63a:	04e79563          	bne	a5,a4,684 <vprintf+0xfa>
        putc(fd, '%');
 63e:	02500593          	li	a1,37
 642:	855a                	mv	a0,s6
 644:	e8dff0ef          	jal	4d0 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 648:	4981                	li	s3,0
 64a:	b769                	j	5d4 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 64c:	008b8913          	addi	s2,s7,8
 650:	4685                	li	a3,1
 652:	4629                	li	a2,10
 654:	000ba583          	lw	a1,0(s7)
 658:	855a                	mv	a0,s6
 65a:	e95ff0ef          	jal	4ee <printint>
 65e:	8bca                	mv	s7,s2
      state = 0;
 660:	4981                	li	s3,0
 662:	bf8d                	j	5d4 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 664:	06400793          	li	a5,100
 668:	02f68963          	beq	a3,a5,69a <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 66c:	06c00793          	li	a5,108
 670:	04f68263          	beq	a3,a5,6b4 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 674:	07500793          	li	a5,117
 678:	0af68063          	beq	a3,a5,718 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 67c:	07800793          	li	a5,120
 680:	0ef68263          	beq	a3,a5,764 <vprintf+0x1da>
        putc(fd, '%');
 684:	02500593          	li	a1,37
 688:	855a                	mv	a0,s6
 68a:	e47ff0ef          	jal	4d0 <putc>
        putc(fd, c0);
 68e:	85ca                	mv	a1,s2
 690:	855a                	mv	a0,s6
 692:	e3fff0ef          	jal	4d0 <putc>
      state = 0;
 696:	4981                	li	s3,0
 698:	bf35                	j	5d4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 69a:	008b8913          	addi	s2,s7,8
 69e:	4685                	li	a3,1
 6a0:	4629                	li	a2,10
 6a2:	000bb583          	ld	a1,0(s7)
 6a6:	855a                	mv	a0,s6
 6a8:	e47ff0ef          	jal	4ee <printint>
        i += 1;
 6ac:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ae:	8bca                	mv	s7,s2
      state = 0;
 6b0:	4981                	li	s3,0
        i += 1;
 6b2:	b70d                	j	5d4 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6b4:	06400793          	li	a5,100
 6b8:	02f60763          	beq	a2,a5,6e6 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6bc:	07500793          	li	a5,117
 6c0:	06f60963          	beq	a2,a5,732 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6c4:	07800793          	li	a5,120
 6c8:	faf61ee3          	bne	a2,a5,684 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6cc:	008b8913          	addi	s2,s7,8
 6d0:	4681                	li	a3,0
 6d2:	4641                	li	a2,16
 6d4:	000bb583          	ld	a1,0(s7)
 6d8:	855a                	mv	a0,s6
 6da:	e15ff0ef          	jal	4ee <printint>
        i += 2;
 6de:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e0:	8bca                	mv	s7,s2
      state = 0;
 6e2:	4981                	li	s3,0
        i += 2;
 6e4:	bdc5                	j	5d4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e6:	008b8913          	addi	s2,s7,8
 6ea:	4685                	li	a3,1
 6ec:	4629                	li	a2,10
 6ee:	000bb583          	ld	a1,0(s7)
 6f2:	855a                	mv	a0,s6
 6f4:	dfbff0ef          	jal	4ee <printint>
        i += 2;
 6f8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6fa:	8bca                	mv	s7,s2
      state = 0;
 6fc:	4981                	li	s3,0
        i += 2;
 6fe:	bdd9                	j	5d4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 700:	008b8913          	addi	s2,s7,8
 704:	4681                	li	a3,0
 706:	4629                	li	a2,10
 708:	000be583          	lwu	a1,0(s7)
 70c:	855a                	mv	a0,s6
 70e:	de1ff0ef          	jal	4ee <printint>
 712:	8bca                	mv	s7,s2
      state = 0;
 714:	4981                	li	s3,0
 716:	bd7d                	j	5d4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 718:	008b8913          	addi	s2,s7,8
 71c:	4681                	li	a3,0
 71e:	4629                	li	a2,10
 720:	000bb583          	ld	a1,0(s7)
 724:	855a                	mv	a0,s6
 726:	dc9ff0ef          	jal	4ee <printint>
        i += 1;
 72a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 72c:	8bca                	mv	s7,s2
      state = 0;
 72e:	4981                	li	s3,0
        i += 1;
 730:	b555                	j	5d4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 732:	008b8913          	addi	s2,s7,8
 736:	4681                	li	a3,0
 738:	4629                	li	a2,10
 73a:	000bb583          	ld	a1,0(s7)
 73e:	855a                	mv	a0,s6
 740:	dafff0ef          	jal	4ee <printint>
        i += 2;
 744:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 746:	8bca                	mv	s7,s2
      state = 0;
 748:	4981                	li	s3,0
        i += 2;
 74a:	b569                	j	5d4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 74c:	008b8913          	addi	s2,s7,8
 750:	4681                	li	a3,0
 752:	4641                	li	a2,16
 754:	000be583          	lwu	a1,0(s7)
 758:	855a                	mv	a0,s6
 75a:	d95ff0ef          	jal	4ee <printint>
 75e:	8bca                	mv	s7,s2
      state = 0;
 760:	4981                	li	s3,0
 762:	bd8d                	j	5d4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 764:	008b8913          	addi	s2,s7,8
 768:	4681                	li	a3,0
 76a:	4641                	li	a2,16
 76c:	000bb583          	ld	a1,0(s7)
 770:	855a                	mv	a0,s6
 772:	d7dff0ef          	jal	4ee <printint>
        i += 1;
 776:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 778:	8bca                	mv	s7,s2
      state = 0;
 77a:	4981                	li	s3,0
        i += 1;
 77c:	bda1                	j	5d4 <vprintf+0x4a>
 77e:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 780:	008b8d13          	addi	s10,s7,8
 784:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 788:	03000593          	li	a1,48
 78c:	855a                	mv	a0,s6
 78e:	d43ff0ef          	jal	4d0 <putc>
  putc(fd, 'x');
 792:	07800593          	li	a1,120
 796:	855a                	mv	a0,s6
 798:	d39ff0ef          	jal	4d0 <putc>
 79c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 79e:	00000b97          	auipc	s7,0x0
 7a2:	51ab8b93          	addi	s7,s7,1306 # cb8 <digits>
 7a6:	03c9d793          	srli	a5,s3,0x3c
 7aa:	97de                	add	a5,a5,s7
 7ac:	0007c583          	lbu	a1,0(a5)
 7b0:	855a                	mv	a0,s6
 7b2:	d1fff0ef          	jal	4d0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7b6:	0992                	slli	s3,s3,0x4
 7b8:	397d                	addiw	s2,s2,-1
 7ba:	fe0916e3          	bnez	s2,7a6 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 7be:	8bea                	mv	s7,s10
      state = 0;
 7c0:	4981                	li	s3,0
 7c2:	6d02                	ld	s10,0(sp)
 7c4:	bd01                	j	5d4 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 7c6:	008b8913          	addi	s2,s7,8
 7ca:	000bc583          	lbu	a1,0(s7)
 7ce:	855a                	mv	a0,s6
 7d0:	d01ff0ef          	jal	4d0 <putc>
 7d4:	8bca                	mv	s7,s2
      state = 0;
 7d6:	4981                	li	s3,0
 7d8:	bbf5                	j	5d4 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7da:	008b8993          	addi	s3,s7,8
 7de:	000bb903          	ld	s2,0(s7)
 7e2:	00090f63          	beqz	s2,800 <vprintf+0x276>
        for(; *s; s++)
 7e6:	00094583          	lbu	a1,0(s2)
 7ea:	c195                	beqz	a1,80e <vprintf+0x284>
          putc(fd, *s);
 7ec:	855a                	mv	a0,s6
 7ee:	ce3ff0ef          	jal	4d0 <putc>
        for(; *s; s++)
 7f2:	0905                	addi	s2,s2,1
 7f4:	00094583          	lbu	a1,0(s2)
 7f8:	f9f5                	bnez	a1,7ec <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7fa:	8bce                	mv	s7,s3
      state = 0;
 7fc:	4981                	li	s3,0
 7fe:	bbd9                	j	5d4 <vprintf+0x4a>
          s = "(null)";
 800:	00000917          	auipc	s2,0x0
 804:	4b090913          	addi	s2,s2,1200 # cb0 <malloc+0x3a4>
        for(; *s; s++)
 808:	02800593          	li	a1,40
 80c:	b7c5                	j	7ec <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 80e:	8bce                	mv	s7,s3
      state = 0;
 810:	4981                	li	s3,0
 812:	b3c9                	j	5d4 <vprintf+0x4a>
 814:	64a6                	ld	s1,72(sp)
 816:	79e2                	ld	s3,56(sp)
 818:	7a42                	ld	s4,48(sp)
 81a:	7aa2                	ld	s5,40(sp)
 81c:	7b02                	ld	s6,32(sp)
 81e:	6be2                	ld	s7,24(sp)
 820:	6c42                	ld	s8,16(sp)
 822:	6ca2                	ld	s9,8(sp)
    }
  }
}
 824:	60e6                	ld	ra,88(sp)
 826:	6446                	ld	s0,80(sp)
 828:	6906                	ld	s2,64(sp)
 82a:	6125                	addi	sp,sp,96
 82c:	8082                	ret

000000000000082e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 82e:	715d                	addi	sp,sp,-80
 830:	ec06                	sd	ra,24(sp)
 832:	e822                	sd	s0,16(sp)
 834:	1000                	addi	s0,sp,32
 836:	e010                	sd	a2,0(s0)
 838:	e414                	sd	a3,8(s0)
 83a:	e818                	sd	a4,16(s0)
 83c:	ec1c                	sd	a5,24(s0)
 83e:	03043023          	sd	a6,32(s0)
 842:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 846:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 84a:	8622                	mv	a2,s0
 84c:	d3fff0ef          	jal	58a <vprintf>
}
 850:	60e2                	ld	ra,24(sp)
 852:	6442                	ld	s0,16(sp)
 854:	6161                	addi	sp,sp,80
 856:	8082                	ret

0000000000000858 <printf>:

void
printf(const char *fmt, ...)
{
 858:	711d                	addi	sp,sp,-96
 85a:	ec06                	sd	ra,24(sp)
 85c:	e822                	sd	s0,16(sp)
 85e:	1000                	addi	s0,sp,32
 860:	e40c                	sd	a1,8(s0)
 862:	e810                	sd	a2,16(s0)
 864:	ec14                	sd	a3,24(s0)
 866:	f018                	sd	a4,32(s0)
 868:	f41c                	sd	a5,40(s0)
 86a:	03043823          	sd	a6,48(s0)
 86e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 872:	00840613          	addi	a2,s0,8
 876:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 87a:	85aa                	mv	a1,a0
 87c:	4505                	li	a0,1
 87e:	d0dff0ef          	jal	58a <vprintf>
}
 882:	60e2                	ld	ra,24(sp)
 884:	6442                	ld	s0,16(sp)
 886:	6125                	addi	sp,sp,96
 888:	8082                	ret

000000000000088a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 88a:	1141                	addi	sp,sp,-16
 88c:	e422                	sd	s0,8(sp)
 88e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 890:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 894:	00000797          	auipc	a5,0x0
 898:	76c7b783          	ld	a5,1900(a5) # 1000 <freep>
 89c:	a02d                	j	8c6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 89e:	4618                	lw	a4,8(a2)
 8a0:	9f2d                	addw	a4,a4,a1
 8a2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8a6:	6398                	ld	a4,0(a5)
 8a8:	6310                	ld	a2,0(a4)
 8aa:	a83d                	j	8e8 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8ac:	ff852703          	lw	a4,-8(a0)
 8b0:	9f31                	addw	a4,a4,a2
 8b2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8b4:	ff053683          	ld	a3,-16(a0)
 8b8:	a091                	j	8fc <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ba:	6398                	ld	a4,0(a5)
 8bc:	00e7e463          	bltu	a5,a4,8c4 <free+0x3a>
 8c0:	00e6ea63          	bltu	a3,a4,8d4 <free+0x4a>
{
 8c4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c6:	fed7fae3          	bgeu	a5,a3,8ba <free+0x30>
 8ca:	6398                	ld	a4,0(a5)
 8cc:	00e6e463          	bltu	a3,a4,8d4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d0:	fee7eae3          	bltu	a5,a4,8c4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8d4:	ff852583          	lw	a1,-8(a0)
 8d8:	6390                	ld	a2,0(a5)
 8da:	02059813          	slli	a6,a1,0x20
 8de:	01c85713          	srli	a4,a6,0x1c
 8e2:	9736                	add	a4,a4,a3
 8e4:	fae60de3          	beq	a2,a4,89e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8e8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8ec:	4790                	lw	a2,8(a5)
 8ee:	02061593          	slli	a1,a2,0x20
 8f2:	01c5d713          	srli	a4,a1,0x1c
 8f6:	973e                	add	a4,a4,a5
 8f8:	fae68ae3          	beq	a3,a4,8ac <free+0x22>
    p->s.ptr = bp->s.ptr;
 8fc:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8fe:	00000717          	auipc	a4,0x0
 902:	70f73123          	sd	a5,1794(a4) # 1000 <freep>
}
 906:	6422                	ld	s0,8(sp)
 908:	0141                	addi	sp,sp,16
 90a:	8082                	ret

000000000000090c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 90c:	7139                	addi	sp,sp,-64
 90e:	fc06                	sd	ra,56(sp)
 910:	f822                	sd	s0,48(sp)
 912:	f426                	sd	s1,40(sp)
 914:	ec4e                	sd	s3,24(sp)
 916:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 918:	02051493          	slli	s1,a0,0x20
 91c:	9081                	srli	s1,s1,0x20
 91e:	04bd                	addi	s1,s1,15
 920:	8091                	srli	s1,s1,0x4
 922:	0014899b          	addiw	s3,s1,1
 926:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 928:	00000517          	auipc	a0,0x0
 92c:	6d853503          	ld	a0,1752(a0) # 1000 <freep>
 930:	c915                	beqz	a0,964 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 932:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 934:	4798                	lw	a4,8(a5)
 936:	08977a63          	bgeu	a4,s1,9ca <malloc+0xbe>
 93a:	f04a                	sd	s2,32(sp)
 93c:	e852                	sd	s4,16(sp)
 93e:	e456                	sd	s5,8(sp)
 940:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 942:	8a4e                	mv	s4,s3
 944:	0009871b          	sext.w	a4,s3
 948:	6685                	lui	a3,0x1
 94a:	00d77363          	bgeu	a4,a3,950 <malloc+0x44>
 94e:	6a05                	lui	s4,0x1
 950:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 954:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 958:	00000917          	auipc	s2,0x0
 95c:	6a890913          	addi	s2,s2,1704 # 1000 <freep>
  if(p == SBRK_ERROR)
 960:	5afd                	li	s5,-1
 962:	a081                	j	9a2 <malloc+0x96>
 964:	f04a                	sd	s2,32(sp)
 966:	e852                	sd	s4,16(sp)
 968:	e456                	sd	s5,8(sp)
 96a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 96c:	00000797          	auipc	a5,0x0
 970:	6a478793          	addi	a5,a5,1700 # 1010 <base>
 974:	00000717          	auipc	a4,0x0
 978:	68f73623          	sd	a5,1676(a4) # 1000 <freep>
 97c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 97e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 982:	b7c1                	j	942 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 984:	6398                	ld	a4,0(a5)
 986:	e118                	sd	a4,0(a0)
 988:	a8a9                	j	9e2 <malloc+0xd6>
  hp->s.size = nu;
 98a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 98e:	0541                	addi	a0,a0,16
 990:	efbff0ef          	jal	88a <free>
  return freep;
 994:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 998:	c12d                	beqz	a0,9fa <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 99a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 99c:	4798                	lw	a4,8(a5)
 99e:	02977263          	bgeu	a4,s1,9c2 <malloc+0xb6>
    if(p == freep)
 9a2:	00093703          	ld	a4,0(s2)
 9a6:	853e                	mv	a0,a5
 9a8:	fef719e3          	bne	a4,a5,99a <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 9ac:	8552                	mv	a0,s4
 9ae:	a4fff0ef          	jal	3fc <sbrk>
  if(p == SBRK_ERROR)
 9b2:	fd551ce3          	bne	a0,s5,98a <malloc+0x7e>
        return 0;
 9b6:	4501                	li	a0,0
 9b8:	7902                	ld	s2,32(sp)
 9ba:	6a42                	ld	s4,16(sp)
 9bc:	6aa2                	ld	s5,8(sp)
 9be:	6b02                	ld	s6,0(sp)
 9c0:	a03d                	j	9ee <malloc+0xe2>
 9c2:	7902                	ld	s2,32(sp)
 9c4:	6a42                	ld	s4,16(sp)
 9c6:	6aa2                	ld	s5,8(sp)
 9c8:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9ca:	fae48de3          	beq	s1,a4,984 <malloc+0x78>
        p->s.size -= nunits;
 9ce:	4137073b          	subw	a4,a4,s3
 9d2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9d4:	02071693          	slli	a3,a4,0x20
 9d8:	01c6d713          	srli	a4,a3,0x1c
 9dc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9de:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9e2:	00000717          	auipc	a4,0x0
 9e6:	60a73f23          	sd	a0,1566(a4) # 1000 <freep>
      return (void*)(p + 1);
 9ea:	01078513          	addi	a0,a5,16
  }
}
 9ee:	70e2                	ld	ra,56(sp)
 9f0:	7442                	ld	s0,48(sp)
 9f2:	74a2                	ld	s1,40(sp)
 9f4:	69e2                	ld	s3,24(sp)
 9f6:	6121                	addi	sp,sp,64
 9f8:	8082                	ret
 9fa:	7902                	ld	s2,32(sp)
 9fc:	6a42                	ld	s4,16(sp)
 9fe:	6aa2                	ld	s5,8(sp)
 a00:	6b02                	ld	s6,0(sp)
 a02:	b7f5                	j	9ee <malloc+0xe2>
