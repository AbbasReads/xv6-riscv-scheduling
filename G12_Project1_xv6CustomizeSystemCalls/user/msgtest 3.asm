
user/_msgtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(void)
{
   0:	7169                	addi	sp,sp,-304
   2:	f606                	sd	ra,296(sp)
   4:	f222                	sd	s0,288(sp)
   6:	1a00                	addi	s0,sp,304
    int pid1 = fork();
   8:	382000ef          	jal	38a <fork>
    if (pid1 == 0) {
   c:	e505                	bnez	a0,34 <main+0x34>
   e:	ee26                	sd	s1,280(sp)
        char buf[256];
        int sender = recvmsg(buf, sizeof(buf));
  10:	ed040493          	addi	s1,s0,-304
  14:	10000593          	li	a1,256
  18:	8526                	mv	a0,s1
  1a:	420000ef          	jal	43a <recvmsg>
  1e:	85aa                	mv	a1,a0
        printf("Child 1 got broadcast from pid %d: %s\n", sender, buf);
  20:	8626                	mv	a2,s1
  22:	00001517          	auipc	a0,0x1
  26:	97e50513          	addi	a0,a0,-1666 # 9a0 <malloc+0xf8>
  2a:	7c6000ef          	jal	7f0 <printf>
        exit(0);
  2e:	4501                	li	a0,0
  30:	362000ef          	jal	392 <exit>
    }

    int pid2 = fork();
  34:	356000ef          	jal	38a <fork>
    if (pid2 == 0) {
  38:	cd3d                	beqz	a0,b6 <main+0xb6>
  3a:	ee26                	sd	s1,280(sp)
        printf("Child 2 got broadcast from pid %d: %s\n", sender, buf);
        exit(0);
    }

    // small delay so children are ready
    for(volatile int i = 0; i < 1000000; i++);
  3c:	ec042823          	sw	zero,-304(s0)
  40:	ed042703          	lw	a4,-304(s0)
  44:	2701                	sext.w	a4,a4
  46:	000f47b7          	lui	a5,0xf4
  4a:	23f78793          	addi	a5,a5,575 # f423f <base+0xf322f>
  4e:	00e7cd63          	blt	a5,a4,68 <main+0x68>
  52:	873e                	mv	a4,a5
  54:	ed042783          	lw	a5,-304(s0)
  58:	2785                	addiw	a5,a5,1
  5a:	ecf42823          	sw	a5,-304(s0)
  5e:	ed042783          	lw	a5,-304(s0)
  62:	2781                	sext.w	a5,a5
  64:	fef758e3          	bge	a4,a5,54 <main+0x54>

    char bmsg[] = "hello everyone";
  68:	00001797          	auipc	a5,0x1
  6c:	9b878793          	addi	a5,a5,-1608 # a20 <malloc+0x178>
  70:	6398                	ld	a4,0(a5)
  72:	fce43823          	sd	a4,-48(s0)
  76:	4798                	lw	a4,8(a5)
  78:	fce42c23          	sw	a4,-40(s0)
  7c:	00c7d703          	lhu	a4,12(a5)
  80:	fce41e23          	sh	a4,-36(s0)
  84:	00e7c783          	lbu	a5,14(a5)
  88:	fcf40f23          	sb	a5,-34(s0)
    int n = broadcast(bmsg, sizeof(bmsg));
  8c:	45bd                	li	a1,15
  8e:	fd040513          	addi	a0,s0,-48
  92:	3b0000ef          	jal	442 <broadcast>
  96:	85aa                	mv	a1,a0
    printf("Parent broadcast to %d processes\n", n);
  98:	00001517          	auipc	a0,0x1
  9c:	96050513          	addi	a0,a0,-1696 # 9f8 <malloc+0x150>
  a0:	750000ef          	jal	7f0 <printf>

    wait(0);
  a4:	4501                	li	a0,0
  a6:	2f4000ef          	jal	39a <wait>
    wait(0);
  aa:	4501                	li	a0,0
  ac:	2ee000ef          	jal	39a <wait>
    exit(0);
  b0:	4501                	li	a0,0
  b2:	2e0000ef          	jal	392 <exit>
  b6:	ee26                	sd	s1,280(sp)
        int sender = recvmsg(buf, sizeof(buf));
  b8:	ed040493          	addi	s1,s0,-304
  bc:	10000593          	li	a1,256
  c0:	8526                	mv	a0,s1
  c2:	378000ef          	jal	43a <recvmsg>
  c6:	85aa                	mv	a1,a0
        printf("Child 2 got broadcast from pid %d: %s\n", sender, buf);
  c8:	8626                	mv	a2,s1
  ca:	00001517          	auipc	a0,0x1
  ce:	90650513          	addi	a0,a0,-1786 # 9d0 <malloc+0x128>
  d2:	71e000ef          	jal	7f0 <printf>
        exit(0);
  d6:	4501                	li	a0,0
  d8:	2ba000ef          	jal	392 <exit>

00000000000000dc <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  dc:	1141                	addi	sp,sp,-16
  de:	e406                	sd	ra,8(sp)
  e0:	e022                	sd	s0,0(sp)
  e2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  e4:	f1dff0ef          	jal	0 <main>
  exit(r);
  e8:	2aa000ef          	jal	392 <exit>

00000000000000ec <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  ec:	1141                	addi	sp,sp,-16
  ee:	e406                	sd	ra,8(sp)
  f0:	e022                	sd	s0,0(sp)
  f2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  f4:	87aa                	mv	a5,a0
  f6:	0585                	addi	a1,a1,1
  f8:	0785                	addi	a5,a5,1
  fa:	fff5c703          	lbu	a4,-1(a1)
  fe:	fee78fa3          	sb	a4,-1(a5)
 102:	fb75                	bnez	a4,f6 <strcpy+0xa>
    ;
  return os;
}
 104:	60a2                	ld	ra,8(sp)
 106:	6402                	ld	s0,0(sp)
 108:	0141                	addi	sp,sp,16
 10a:	8082                	ret

000000000000010c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 10c:	1141                	addi	sp,sp,-16
 10e:	e406                	sd	ra,8(sp)
 110:	e022                	sd	s0,0(sp)
 112:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 114:	00054783          	lbu	a5,0(a0)
 118:	cb91                	beqz	a5,12c <strcmp+0x20>
 11a:	0005c703          	lbu	a4,0(a1)
 11e:	00f71763          	bne	a4,a5,12c <strcmp+0x20>
    p++, q++;
 122:	0505                	addi	a0,a0,1
 124:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 126:	00054783          	lbu	a5,0(a0)
 12a:	fbe5                	bnez	a5,11a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 12c:	0005c503          	lbu	a0,0(a1)
}
 130:	40a7853b          	subw	a0,a5,a0
 134:	60a2                	ld	ra,8(sp)
 136:	6402                	ld	s0,0(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret

000000000000013c <strlen>:

uint
strlen(const char *s)
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e406                	sd	ra,8(sp)
 140:	e022                	sd	s0,0(sp)
 142:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 144:	00054783          	lbu	a5,0(a0)
 148:	cf91                	beqz	a5,164 <strlen+0x28>
 14a:	00150793          	addi	a5,a0,1
 14e:	86be                	mv	a3,a5
 150:	0785                	addi	a5,a5,1
 152:	fff7c703          	lbu	a4,-1(a5)
 156:	ff65                	bnez	a4,14e <strlen+0x12>
 158:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 15c:	60a2                	ld	ra,8(sp)
 15e:	6402                	ld	s0,0(sp)
 160:	0141                	addi	sp,sp,16
 162:	8082                	ret
  for(n = 0; s[n]; n++)
 164:	4501                	li	a0,0
 166:	bfdd                	j	15c <strlen+0x20>

0000000000000168 <memset>:

void*
memset(void *dst, int c, uint n)
{
 168:	1141                	addi	sp,sp,-16
 16a:	e406                	sd	ra,8(sp)
 16c:	e022                	sd	s0,0(sp)
 16e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 170:	ca19                	beqz	a2,186 <memset+0x1e>
 172:	87aa                	mv	a5,a0
 174:	1602                	slli	a2,a2,0x20
 176:	9201                	srli	a2,a2,0x20
 178:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 17c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 180:	0785                	addi	a5,a5,1
 182:	fee79de3          	bne	a5,a4,17c <memset+0x14>
  }
  return dst;
}
 186:	60a2                	ld	ra,8(sp)
 188:	6402                	ld	s0,0(sp)
 18a:	0141                	addi	sp,sp,16
 18c:	8082                	ret

000000000000018e <strchr>:

char*
strchr(const char *s, char c)
{
 18e:	1141                	addi	sp,sp,-16
 190:	e406                	sd	ra,8(sp)
 192:	e022                	sd	s0,0(sp)
 194:	0800                	addi	s0,sp,16
  for(; *s; s++)
 196:	00054783          	lbu	a5,0(a0)
 19a:	cf81                	beqz	a5,1b2 <strchr+0x24>
    if(*s == c)
 19c:	00f58763          	beq	a1,a5,1aa <strchr+0x1c>
  for(; *s; s++)
 1a0:	0505                	addi	a0,a0,1
 1a2:	00054783          	lbu	a5,0(a0)
 1a6:	fbfd                	bnez	a5,19c <strchr+0xe>
      return (char*)s;
  return 0;
 1a8:	4501                	li	a0,0
}
 1aa:	60a2                	ld	ra,8(sp)
 1ac:	6402                	ld	s0,0(sp)
 1ae:	0141                	addi	sp,sp,16
 1b0:	8082                	ret
  return 0;
 1b2:	4501                	li	a0,0
 1b4:	bfdd                	j	1aa <strchr+0x1c>

00000000000001b6 <gets>:

char*
gets(char *buf, int max)
{
 1b6:	711d                	addi	sp,sp,-96
 1b8:	ec86                	sd	ra,88(sp)
 1ba:	e8a2                	sd	s0,80(sp)
 1bc:	e4a6                	sd	s1,72(sp)
 1be:	e0ca                	sd	s2,64(sp)
 1c0:	fc4e                	sd	s3,56(sp)
 1c2:	f852                	sd	s4,48(sp)
 1c4:	f456                	sd	s5,40(sp)
 1c6:	f05a                	sd	s6,32(sp)
 1c8:	ec5e                	sd	s7,24(sp)
 1ca:	e862                	sd	s8,16(sp)
 1cc:	1080                	addi	s0,sp,96
 1ce:	8baa                	mv	s7,a0
 1d0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d2:	892a                	mv	s2,a0
 1d4:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1d6:	faf40b13          	addi	s6,s0,-81
 1da:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1dc:	8c26                	mv	s8,s1
 1de:	0014899b          	addiw	s3,s1,1
 1e2:	84ce                	mv	s1,s3
 1e4:	0349d463          	bge	s3,s4,20c <gets+0x56>
    cc = read(0, &c, 1);
 1e8:	8656                	mv	a2,s5
 1ea:	85da                	mv	a1,s6
 1ec:	4501                	li	a0,0
 1ee:	1bc000ef          	jal	3aa <read>
    if(cc < 1)
 1f2:	00a05d63          	blez	a0,20c <gets+0x56>
      break;
    buf[i++] = c;
 1f6:	faf44783          	lbu	a5,-81(s0)
 1fa:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1fe:	0905                	addi	s2,s2,1
 200:	ff678713          	addi	a4,a5,-10
 204:	c319                	beqz	a4,20a <gets+0x54>
 206:	17cd                	addi	a5,a5,-13
 208:	fbf1                	bnez	a5,1dc <gets+0x26>
    buf[i++] = c;
 20a:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 20c:	9c5e                	add	s8,s8,s7
 20e:	000c0023          	sb	zero,0(s8)
  return buf;
}
 212:	855e                	mv	a0,s7
 214:	60e6                	ld	ra,88(sp)
 216:	6446                	ld	s0,80(sp)
 218:	64a6                	ld	s1,72(sp)
 21a:	6906                	ld	s2,64(sp)
 21c:	79e2                	ld	s3,56(sp)
 21e:	7a42                	ld	s4,48(sp)
 220:	7aa2                	ld	s5,40(sp)
 222:	7b02                	ld	s6,32(sp)
 224:	6be2                	ld	s7,24(sp)
 226:	6c42                	ld	s8,16(sp)
 228:	6125                	addi	sp,sp,96
 22a:	8082                	ret

000000000000022c <stat>:

int
stat(const char *n, struct stat *st)
{
 22c:	1101                	addi	sp,sp,-32
 22e:	ec06                	sd	ra,24(sp)
 230:	e822                	sd	s0,16(sp)
 232:	e04a                	sd	s2,0(sp)
 234:	1000                	addi	s0,sp,32
 236:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 238:	4581                	li	a1,0
 23a:	198000ef          	jal	3d2 <open>
  if(fd < 0)
 23e:	02054263          	bltz	a0,262 <stat+0x36>
 242:	e426                	sd	s1,8(sp)
 244:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 246:	85ca                	mv	a1,s2
 248:	1a2000ef          	jal	3ea <fstat>
 24c:	892a                	mv	s2,a0
  close(fd);
 24e:	8526                	mv	a0,s1
 250:	16a000ef          	jal	3ba <close>
  return r;
 254:	64a2                	ld	s1,8(sp)
}
 256:	854a                	mv	a0,s2
 258:	60e2                	ld	ra,24(sp)
 25a:	6442                	ld	s0,16(sp)
 25c:	6902                	ld	s2,0(sp)
 25e:	6105                	addi	sp,sp,32
 260:	8082                	ret
    return -1;
 262:	57fd                	li	a5,-1
 264:	893e                	mv	s2,a5
 266:	bfc5                	j	256 <stat+0x2a>

0000000000000268 <atoi>:

int
atoi(const char *s)
{
 268:	1141                	addi	sp,sp,-16
 26a:	e406                	sd	ra,8(sp)
 26c:	e022                	sd	s0,0(sp)
 26e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 270:	00054683          	lbu	a3,0(a0)
 274:	fd06879b          	addiw	a5,a3,-48
 278:	0ff7f793          	zext.b	a5,a5
 27c:	4625                	li	a2,9
 27e:	02f66963          	bltu	a2,a5,2b0 <atoi+0x48>
 282:	872a                	mv	a4,a0
  n = 0;
 284:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 286:	0705                	addi	a4,a4,1
 288:	0025179b          	slliw	a5,a0,0x2
 28c:	9fa9                	addw	a5,a5,a0
 28e:	0017979b          	slliw	a5,a5,0x1
 292:	9fb5                	addw	a5,a5,a3
 294:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 298:	00074683          	lbu	a3,0(a4)
 29c:	fd06879b          	addiw	a5,a3,-48
 2a0:	0ff7f793          	zext.b	a5,a5
 2a4:	fef671e3          	bgeu	a2,a5,286 <atoi+0x1e>
  return n;
}
 2a8:	60a2                	ld	ra,8(sp)
 2aa:	6402                	ld	s0,0(sp)
 2ac:	0141                	addi	sp,sp,16
 2ae:	8082                	ret
  n = 0;
 2b0:	4501                	li	a0,0
 2b2:	bfdd                	j	2a8 <atoi+0x40>

00000000000002b4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b4:	1141                	addi	sp,sp,-16
 2b6:	e406                	sd	ra,8(sp)
 2b8:	e022                	sd	s0,0(sp)
 2ba:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2bc:	02b57563          	bgeu	a0,a1,2e6 <memmove+0x32>
    while(n-- > 0)
 2c0:	00c05f63          	blez	a2,2de <memmove+0x2a>
 2c4:	1602                	slli	a2,a2,0x20
 2c6:	9201                	srli	a2,a2,0x20
 2c8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2cc:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ce:	0585                	addi	a1,a1,1
 2d0:	0705                	addi	a4,a4,1
 2d2:	fff5c683          	lbu	a3,-1(a1)
 2d6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2da:	fee79ae3          	bne	a5,a4,2ce <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2de:	60a2                	ld	ra,8(sp)
 2e0:	6402                	ld	s0,0(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret
    while(n-- > 0)
 2e6:	fec05ce3          	blez	a2,2de <memmove+0x2a>
    dst += n;
 2ea:	00c50733          	add	a4,a0,a2
    src += n;
 2ee:	95b2                	add	a1,a1,a2
 2f0:	fff6079b          	addiw	a5,a2,-1
 2f4:	1782                	slli	a5,a5,0x20
 2f6:	9381                	srli	a5,a5,0x20
 2f8:	fff7c793          	not	a5,a5
 2fc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2fe:	15fd                	addi	a1,a1,-1
 300:	177d                	addi	a4,a4,-1
 302:	0005c683          	lbu	a3,0(a1)
 306:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 30a:	fef71ae3          	bne	a4,a5,2fe <memmove+0x4a>
 30e:	bfc1                	j	2de <memmove+0x2a>

0000000000000310 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e406                	sd	ra,8(sp)
 314:	e022                	sd	s0,0(sp)
 316:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 318:	c61d                	beqz	a2,346 <memcmp+0x36>
 31a:	1602                	slli	a2,a2,0x20
 31c:	9201                	srli	a2,a2,0x20
 31e:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 322:	00054783          	lbu	a5,0(a0)
 326:	0005c703          	lbu	a4,0(a1)
 32a:	00e79863          	bne	a5,a4,33a <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 32e:	0505                	addi	a0,a0,1
    p2++;
 330:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 332:	fed518e3          	bne	a0,a3,322 <memcmp+0x12>
  }
  return 0;
 336:	4501                	li	a0,0
 338:	a019                	j	33e <memcmp+0x2e>
      return *p1 - *p2;
 33a:	40e7853b          	subw	a0,a5,a4
}
 33e:	60a2                	ld	ra,8(sp)
 340:	6402                	ld	s0,0(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret
  return 0;
 346:	4501                	li	a0,0
 348:	bfdd                	j	33e <memcmp+0x2e>

000000000000034a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 34a:	1141                	addi	sp,sp,-16
 34c:	e406                	sd	ra,8(sp)
 34e:	e022                	sd	s0,0(sp)
 350:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 352:	f63ff0ef          	jal	2b4 <memmove>
}
 356:	60a2                	ld	ra,8(sp)
 358:	6402                	ld	s0,0(sp)
 35a:	0141                	addi	sp,sp,16
 35c:	8082                	ret

000000000000035e <sbrk>:

char *
sbrk(int n) {
 35e:	1141                	addi	sp,sp,-16
 360:	e406                	sd	ra,8(sp)
 362:	e022                	sd	s0,0(sp)
 364:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 366:	4585                	li	a1,1
 368:	0b2000ef          	jal	41a <sys_sbrk>
}
 36c:	60a2                	ld	ra,8(sp)
 36e:	6402                	ld	s0,0(sp)
 370:	0141                	addi	sp,sp,16
 372:	8082                	ret

0000000000000374 <sbrklazy>:

char *
sbrklazy(int n) {
 374:	1141                	addi	sp,sp,-16
 376:	e406                	sd	ra,8(sp)
 378:	e022                	sd	s0,0(sp)
 37a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 37c:	4589                	li	a1,2
 37e:	09c000ef          	jal	41a <sys_sbrk>
}
 382:	60a2                	ld	ra,8(sp)
 384:	6402                	ld	s0,0(sp)
 386:	0141                	addi	sp,sp,16
 388:	8082                	ret

000000000000038a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 38a:	4885                	li	a7,1
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <exit>:
.global exit
exit:
 li a7, SYS_exit
 392:	4889                	li	a7,2
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <wait>:
.global wait
wait:
 li a7, SYS_wait
 39a:	488d                	li	a7,3
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a2:	4891                	li	a7,4
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <read>:
.global read
read:
 li a7, SYS_read
 3aa:	4895                	li	a7,5
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <write>:
.global write
write:
 li a7, SYS_write
 3b2:	48c1                	li	a7,16
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <close>:
.global close
close:
 li a7, SYS_close
 3ba:	48d5                	li	a7,21
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c2:	4899                	li	a7,6
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <exec>:
.global exec
exec:
 li a7, SYS_exec
 3ca:	489d                	li	a7,7
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <open>:
.global open
open:
 li a7, SYS_open
 3d2:	48bd                	li	a7,15
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3da:	48c5                	li	a7,17
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e2:	48c9                	li	a7,18
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ea:	48a1                	li	a7,8
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <link>:
.global link
link:
 li a7, SYS_link
 3f2:	48cd                	li	a7,19
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3fa:	48d1                	li	a7,20
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 402:	48a5                	li	a7,9
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <dup>:
.global dup
dup:
 li a7, SYS_dup
 40a:	48a9                	li	a7,10
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 412:	48ad                	li	a7,11
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 41a:	48b1                	li	a7,12
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <pause>:
.global pause
pause:
 li a7, SYS_pause
 422:	48b5                	li	a7,13
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 42a:	48b9                	li	a7,14
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <sendmsg>:
.global sendmsg
sendmsg:
 li a7, SYS_sendmsg
 432:	48d9                	li	a7,22
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <recvmsg>:
.global recvmsg
recvmsg:
 li a7, SYS_recvmsg
 43a:	48dd                	li	a7,23
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <broadcast>:
.global broadcast
broadcast:
 li a7, SYS_broadcast
 442:	48e1                	li	a7,24
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 44a:	1101                	addi	sp,sp,-32
 44c:	ec06                	sd	ra,24(sp)
 44e:	e822                	sd	s0,16(sp)
 450:	1000                	addi	s0,sp,32
 452:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 456:	4605                	li	a2,1
 458:	fef40593          	addi	a1,s0,-17
 45c:	f57ff0ef          	jal	3b2 <write>
}
 460:	60e2                	ld	ra,24(sp)
 462:	6442                	ld	s0,16(sp)
 464:	6105                	addi	sp,sp,32
 466:	8082                	ret

0000000000000468 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 468:	715d                	addi	sp,sp,-80
 46a:	e486                	sd	ra,72(sp)
 46c:	e0a2                	sd	s0,64(sp)
 46e:	f84a                	sd	s2,48(sp)
 470:	f44e                	sd	s3,40(sp)
 472:	0880                	addi	s0,sp,80
 474:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 476:	c6d1                	beqz	a3,502 <printint+0x9a>
 478:	0805d563          	bgez	a1,502 <printint+0x9a>
    neg = 1;
    x = -xx;
 47c:	40b005b3          	neg	a1,a1
    neg = 1;
 480:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 482:	fb840993          	addi	s3,s0,-72
  neg = 0;
 486:	86ce                	mv	a3,s3
  i = 0;
 488:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 48a:	00000817          	auipc	a6,0x0
 48e:	5ae80813          	addi	a6,a6,1454 # a38 <digits>
 492:	88ba                	mv	a7,a4
 494:	0017051b          	addiw	a0,a4,1
 498:	872a                	mv	a4,a0
 49a:	02c5f7b3          	remu	a5,a1,a2
 49e:	97c2                	add	a5,a5,a6
 4a0:	0007c783          	lbu	a5,0(a5)
 4a4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4a8:	87ae                	mv	a5,a1
 4aa:	02c5d5b3          	divu	a1,a1,a2
 4ae:	0685                	addi	a3,a3,1
 4b0:	fec7f1e3          	bgeu	a5,a2,492 <printint+0x2a>
  if(neg)
 4b4:	00030c63          	beqz	t1,4cc <printint+0x64>
    buf[i++] = '-';
 4b8:	fd050793          	addi	a5,a0,-48
 4bc:	00878533          	add	a0,a5,s0
 4c0:	02d00793          	li	a5,45
 4c4:	fef50423          	sb	a5,-24(a0)
 4c8:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 4cc:	02e05563          	blez	a4,4f6 <printint+0x8e>
 4d0:	fc26                	sd	s1,56(sp)
 4d2:	377d                	addiw	a4,a4,-1
 4d4:	00e984b3          	add	s1,s3,a4
 4d8:	19fd                	addi	s3,s3,-1
 4da:	99ba                	add	s3,s3,a4
 4dc:	1702                	slli	a4,a4,0x20
 4de:	9301                	srli	a4,a4,0x20
 4e0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4e4:	0004c583          	lbu	a1,0(s1)
 4e8:	854a                	mv	a0,s2
 4ea:	f61ff0ef          	jal	44a <putc>
  while(--i >= 0)
 4ee:	14fd                	addi	s1,s1,-1
 4f0:	ff349ae3          	bne	s1,s3,4e4 <printint+0x7c>
 4f4:	74e2                	ld	s1,56(sp)
}
 4f6:	60a6                	ld	ra,72(sp)
 4f8:	6406                	ld	s0,64(sp)
 4fa:	7942                	ld	s2,48(sp)
 4fc:	79a2                	ld	s3,40(sp)
 4fe:	6161                	addi	sp,sp,80
 500:	8082                	ret
  neg = 0;
 502:	4301                	li	t1,0
 504:	bfbd                	j	482 <printint+0x1a>

0000000000000506 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 506:	711d                	addi	sp,sp,-96
 508:	ec86                	sd	ra,88(sp)
 50a:	e8a2                	sd	s0,80(sp)
 50c:	e4a6                	sd	s1,72(sp)
 50e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 510:	0005c483          	lbu	s1,0(a1)
 514:	22048363          	beqz	s1,73a <vprintf+0x234>
 518:	e0ca                	sd	s2,64(sp)
 51a:	fc4e                	sd	s3,56(sp)
 51c:	f852                	sd	s4,48(sp)
 51e:	f456                	sd	s5,40(sp)
 520:	f05a                	sd	s6,32(sp)
 522:	ec5e                	sd	s7,24(sp)
 524:	e862                	sd	s8,16(sp)
 526:	8b2a                	mv	s6,a0
 528:	8a2e                	mv	s4,a1
 52a:	8bb2                	mv	s7,a2
  state = 0;
 52c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 52e:	4901                	li	s2,0
 530:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 532:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 536:	06400c13          	li	s8,100
 53a:	a00d                	j	55c <vprintf+0x56>
        putc(fd, c0);
 53c:	85a6                	mv	a1,s1
 53e:	855a                	mv	a0,s6
 540:	f0bff0ef          	jal	44a <putc>
 544:	a019                	j	54a <vprintf+0x44>
    } else if(state == '%'){
 546:	03598363          	beq	s3,s5,56c <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 54a:	0019079b          	addiw	a5,s2,1
 54e:	893e                	mv	s2,a5
 550:	873e                	mv	a4,a5
 552:	97d2                	add	a5,a5,s4
 554:	0007c483          	lbu	s1,0(a5)
 558:	1c048a63          	beqz	s1,72c <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 55c:	0004879b          	sext.w	a5,s1
    if(state == 0){
 560:	fe0993e3          	bnez	s3,546 <vprintf+0x40>
      if(c0 == '%'){
 564:	fd579ce3          	bne	a5,s5,53c <vprintf+0x36>
        state = '%';
 568:	89be                	mv	s3,a5
 56a:	b7c5                	j	54a <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 56c:	00ea06b3          	add	a3,s4,a4
 570:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 574:	1c060863          	beqz	a2,744 <vprintf+0x23e>
      if(c0 == 'd'){
 578:	03878763          	beq	a5,s8,5a6 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 57c:	f9478693          	addi	a3,a5,-108
 580:	0016b693          	seqz	a3,a3
 584:	f9c60593          	addi	a1,a2,-100
 588:	e99d                	bnez	a1,5be <vprintf+0xb8>
 58a:	ca95                	beqz	a3,5be <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 58c:	008b8493          	addi	s1,s7,8
 590:	4685                	li	a3,1
 592:	4629                	li	a2,10
 594:	000bb583          	ld	a1,0(s7)
 598:	855a                	mv	a0,s6
 59a:	ecfff0ef          	jal	468 <printint>
        i += 1;
 59e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a0:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5a2:	4981                	li	s3,0
 5a4:	b75d                	j	54a <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 5a6:	008b8493          	addi	s1,s7,8
 5aa:	4685                	li	a3,1
 5ac:	4629                	li	a2,10
 5ae:	000ba583          	lw	a1,0(s7)
 5b2:	855a                	mv	a0,s6
 5b4:	eb5ff0ef          	jal	468 <printint>
 5b8:	8ba6                	mv	s7,s1
      state = 0;
 5ba:	4981                	li	s3,0
 5bc:	b779                	j	54a <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 5be:	9752                	add	a4,a4,s4
 5c0:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5c4:	f9460713          	addi	a4,a2,-108
 5c8:	00173713          	seqz	a4,a4
 5cc:	8f75                	and	a4,a4,a3
 5ce:	f9c58513          	addi	a0,a1,-100
 5d2:	18051363          	bnez	a0,758 <vprintf+0x252>
 5d6:	18070163          	beqz	a4,758 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5da:	008b8493          	addi	s1,s7,8
 5de:	4685                	li	a3,1
 5e0:	4629                	li	a2,10
 5e2:	000bb583          	ld	a1,0(s7)
 5e6:	855a                	mv	a0,s6
 5e8:	e81ff0ef          	jal	468 <printint>
        i += 2;
 5ec:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ee:	8ba6                	mv	s7,s1
      state = 0;
 5f0:	4981                	li	s3,0
        i += 2;
 5f2:	bfa1                	j	54a <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5f4:	008b8493          	addi	s1,s7,8
 5f8:	4681                	li	a3,0
 5fa:	4629                	li	a2,10
 5fc:	000be583          	lwu	a1,0(s7)
 600:	855a                	mv	a0,s6
 602:	e67ff0ef          	jal	468 <printint>
 606:	8ba6                	mv	s7,s1
      state = 0;
 608:	4981                	li	s3,0
 60a:	b781                	j	54a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 60c:	008b8493          	addi	s1,s7,8
 610:	4681                	li	a3,0
 612:	4629                	li	a2,10
 614:	000bb583          	ld	a1,0(s7)
 618:	855a                	mv	a0,s6
 61a:	e4fff0ef          	jal	468 <printint>
        i += 1;
 61e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 620:	8ba6                	mv	s7,s1
      state = 0;
 622:	4981                	li	s3,0
 624:	b71d                	j	54a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 626:	008b8493          	addi	s1,s7,8
 62a:	4681                	li	a3,0
 62c:	4629                	li	a2,10
 62e:	000bb583          	ld	a1,0(s7)
 632:	855a                	mv	a0,s6
 634:	e35ff0ef          	jal	468 <printint>
        i += 2;
 638:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 63a:	8ba6                	mv	s7,s1
      state = 0;
 63c:	4981                	li	s3,0
        i += 2;
 63e:	b731                	j	54a <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 640:	008b8493          	addi	s1,s7,8
 644:	4681                	li	a3,0
 646:	4641                	li	a2,16
 648:	000be583          	lwu	a1,0(s7)
 64c:	855a                	mv	a0,s6
 64e:	e1bff0ef          	jal	468 <printint>
 652:	8ba6                	mv	s7,s1
      state = 0;
 654:	4981                	li	s3,0
 656:	bdd5                	j	54a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 658:	008b8493          	addi	s1,s7,8
 65c:	4681                	li	a3,0
 65e:	4641                	li	a2,16
 660:	000bb583          	ld	a1,0(s7)
 664:	855a                	mv	a0,s6
 666:	e03ff0ef          	jal	468 <printint>
        i += 1;
 66a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 66c:	8ba6                	mv	s7,s1
      state = 0;
 66e:	4981                	li	s3,0
 670:	bde9                	j	54a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 672:	008b8493          	addi	s1,s7,8
 676:	4681                	li	a3,0
 678:	4641                	li	a2,16
 67a:	000bb583          	ld	a1,0(s7)
 67e:	855a                	mv	a0,s6
 680:	de9ff0ef          	jal	468 <printint>
        i += 2;
 684:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 686:	8ba6                	mv	s7,s1
      state = 0;
 688:	4981                	li	s3,0
        i += 2;
 68a:	b5c1                	j	54a <vprintf+0x44>
 68c:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 68e:	008b8793          	addi	a5,s7,8
 692:	8cbe                	mv	s9,a5
 694:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 698:	03000593          	li	a1,48
 69c:	855a                	mv	a0,s6
 69e:	dadff0ef          	jal	44a <putc>
  putc(fd, 'x');
 6a2:	07800593          	li	a1,120
 6a6:	855a                	mv	a0,s6
 6a8:	da3ff0ef          	jal	44a <putc>
 6ac:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ae:	00000b97          	auipc	s7,0x0
 6b2:	38ab8b93          	addi	s7,s7,906 # a38 <digits>
 6b6:	03c9d793          	srli	a5,s3,0x3c
 6ba:	97de                	add	a5,a5,s7
 6bc:	0007c583          	lbu	a1,0(a5)
 6c0:	855a                	mv	a0,s6
 6c2:	d89ff0ef          	jal	44a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6c6:	0992                	slli	s3,s3,0x4
 6c8:	34fd                	addiw	s1,s1,-1
 6ca:	f4f5                	bnez	s1,6b6 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 6cc:	8be6                	mv	s7,s9
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	6ca2                	ld	s9,8(sp)
 6d2:	bda5                	j	54a <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 6d4:	008b8493          	addi	s1,s7,8
 6d8:	000bc583          	lbu	a1,0(s7)
 6dc:	855a                	mv	a0,s6
 6de:	d6dff0ef          	jal	44a <putc>
 6e2:	8ba6                	mv	s7,s1
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	b595                	j	54a <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6e8:	008b8993          	addi	s3,s7,8
 6ec:	000bb483          	ld	s1,0(s7)
 6f0:	cc91                	beqz	s1,70c <vprintf+0x206>
        for(; *s; s++)
 6f2:	0004c583          	lbu	a1,0(s1)
 6f6:	c985                	beqz	a1,726 <vprintf+0x220>
          putc(fd, *s);
 6f8:	855a                	mv	a0,s6
 6fa:	d51ff0ef          	jal	44a <putc>
        for(; *s; s++)
 6fe:	0485                	addi	s1,s1,1
 700:	0004c583          	lbu	a1,0(s1)
 704:	f9f5                	bnez	a1,6f8 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 706:	8bce                	mv	s7,s3
      state = 0;
 708:	4981                	li	s3,0
 70a:	b581                	j	54a <vprintf+0x44>
          s = "(null)";
 70c:	00000497          	auipc	s1,0x0
 710:	32448493          	addi	s1,s1,804 # a30 <malloc+0x188>
        for(; *s; s++)
 714:	02800593          	li	a1,40
 718:	b7c5                	j	6f8 <vprintf+0x1f2>
        putc(fd, '%');
 71a:	85be                	mv	a1,a5
 71c:	855a                	mv	a0,s6
 71e:	d2dff0ef          	jal	44a <putc>
      state = 0;
 722:	4981                	li	s3,0
 724:	b51d                	j	54a <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 726:	8bce                	mv	s7,s3
      state = 0;
 728:	4981                	li	s3,0
 72a:	b505                	j	54a <vprintf+0x44>
 72c:	6906                	ld	s2,64(sp)
 72e:	79e2                	ld	s3,56(sp)
 730:	7a42                	ld	s4,48(sp)
 732:	7aa2                	ld	s5,40(sp)
 734:	7b02                	ld	s6,32(sp)
 736:	6be2                	ld	s7,24(sp)
 738:	6c42                	ld	s8,16(sp)
    }
  }
}
 73a:	60e6                	ld	ra,88(sp)
 73c:	6446                	ld	s0,80(sp)
 73e:	64a6                	ld	s1,72(sp)
 740:	6125                	addi	sp,sp,96
 742:	8082                	ret
      if(c0 == 'd'){
 744:	06400713          	li	a4,100
 748:	e4e78fe3          	beq	a5,a4,5a6 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 74c:	f9478693          	addi	a3,a5,-108
 750:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 754:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 756:	4701                	li	a4,0
      } else if(c0 == 'u'){
 758:	07500513          	li	a0,117
 75c:	e8a78ce3          	beq	a5,a0,5f4 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 760:	f8b60513          	addi	a0,a2,-117
 764:	e119                	bnez	a0,76a <vprintf+0x264>
 766:	ea0693e3          	bnez	a3,60c <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 76a:	f8b58513          	addi	a0,a1,-117
 76e:	e119                	bnez	a0,774 <vprintf+0x26e>
 770:	ea071be3          	bnez	a4,626 <vprintf+0x120>
      } else if(c0 == 'x'){
 774:	07800513          	li	a0,120
 778:	eca784e3          	beq	a5,a0,640 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 77c:	f8860613          	addi	a2,a2,-120
 780:	e219                	bnez	a2,786 <vprintf+0x280>
 782:	ec069be3          	bnez	a3,658 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 786:	f8858593          	addi	a1,a1,-120
 78a:	e199                	bnez	a1,790 <vprintf+0x28a>
 78c:	ee0713e3          	bnez	a4,672 <vprintf+0x16c>
      } else if(c0 == 'p'){
 790:	07000713          	li	a4,112
 794:	eee78ce3          	beq	a5,a4,68c <vprintf+0x186>
      } else if(c0 == 'c'){
 798:	06300713          	li	a4,99
 79c:	f2e78ce3          	beq	a5,a4,6d4 <vprintf+0x1ce>
      } else if(c0 == 's'){
 7a0:	07300713          	li	a4,115
 7a4:	f4e782e3          	beq	a5,a4,6e8 <vprintf+0x1e2>
      } else if(c0 == '%'){
 7a8:	02500713          	li	a4,37
 7ac:	f6e787e3          	beq	a5,a4,71a <vprintf+0x214>
        putc(fd, '%');
 7b0:	02500593          	li	a1,37
 7b4:	855a                	mv	a0,s6
 7b6:	c95ff0ef          	jal	44a <putc>
        putc(fd, c0);
 7ba:	85a6                	mv	a1,s1
 7bc:	855a                	mv	a0,s6
 7be:	c8dff0ef          	jal	44a <putc>
      state = 0;
 7c2:	4981                	li	s3,0
 7c4:	b359                	j	54a <vprintf+0x44>

00000000000007c6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7c6:	715d                	addi	sp,sp,-80
 7c8:	ec06                	sd	ra,24(sp)
 7ca:	e822                	sd	s0,16(sp)
 7cc:	1000                	addi	s0,sp,32
 7ce:	e010                	sd	a2,0(s0)
 7d0:	e414                	sd	a3,8(s0)
 7d2:	e818                	sd	a4,16(s0)
 7d4:	ec1c                	sd	a5,24(s0)
 7d6:	03043023          	sd	a6,32(s0)
 7da:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7de:	8622                	mv	a2,s0
 7e0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7e4:	d23ff0ef          	jal	506 <vprintf>
}
 7e8:	60e2                	ld	ra,24(sp)
 7ea:	6442                	ld	s0,16(sp)
 7ec:	6161                	addi	sp,sp,80
 7ee:	8082                	ret

00000000000007f0 <printf>:

void
printf(const char *fmt, ...)
{
 7f0:	711d                	addi	sp,sp,-96
 7f2:	ec06                	sd	ra,24(sp)
 7f4:	e822                	sd	s0,16(sp)
 7f6:	1000                	addi	s0,sp,32
 7f8:	e40c                	sd	a1,8(s0)
 7fa:	e810                	sd	a2,16(s0)
 7fc:	ec14                	sd	a3,24(s0)
 7fe:	f018                	sd	a4,32(s0)
 800:	f41c                	sd	a5,40(s0)
 802:	03043823          	sd	a6,48(s0)
 806:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 80a:	00840613          	addi	a2,s0,8
 80e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 812:	85aa                	mv	a1,a0
 814:	4505                	li	a0,1
 816:	cf1ff0ef          	jal	506 <vprintf>
}
 81a:	60e2                	ld	ra,24(sp)
 81c:	6442                	ld	s0,16(sp)
 81e:	6125                	addi	sp,sp,96
 820:	8082                	ret

0000000000000822 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 822:	1141                	addi	sp,sp,-16
 824:	e406                	sd	ra,8(sp)
 826:	e022                	sd	s0,0(sp)
 828:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 82a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82e:	00000797          	auipc	a5,0x0
 832:	7d27b783          	ld	a5,2002(a5) # 1000 <freep>
 836:	a039                	j	844 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 838:	6398                	ld	a4,0(a5)
 83a:	00e7e463          	bltu	a5,a4,842 <free+0x20>
 83e:	00e6ea63          	bltu	a3,a4,852 <free+0x30>
{
 842:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 844:	fed7fae3          	bgeu	a5,a3,838 <free+0x16>
 848:	6398                	ld	a4,0(a5)
 84a:	00e6e463          	bltu	a3,a4,852 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 84e:	fee7eae3          	bltu	a5,a4,842 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 852:	ff852583          	lw	a1,-8(a0)
 856:	6390                	ld	a2,0(a5)
 858:	02059813          	slli	a6,a1,0x20
 85c:	01c85713          	srli	a4,a6,0x1c
 860:	9736                	add	a4,a4,a3
 862:	02e60563          	beq	a2,a4,88c <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 866:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 86a:	4790                	lw	a2,8(a5)
 86c:	02061593          	slli	a1,a2,0x20
 870:	01c5d713          	srli	a4,a1,0x1c
 874:	973e                	add	a4,a4,a5
 876:	02e68263          	beq	a3,a4,89a <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 87a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 87c:	00000717          	auipc	a4,0x0
 880:	78f73223          	sd	a5,1924(a4) # 1000 <freep>
}
 884:	60a2                	ld	ra,8(sp)
 886:	6402                	ld	s0,0(sp)
 888:	0141                	addi	sp,sp,16
 88a:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 88c:	4618                	lw	a4,8(a2)
 88e:	9f2d                	addw	a4,a4,a1
 890:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 894:	6398                	ld	a4,0(a5)
 896:	6310                	ld	a2,0(a4)
 898:	b7f9                	j	866 <free+0x44>
    p->s.size += bp->s.size;
 89a:	ff852703          	lw	a4,-8(a0)
 89e:	9f31                	addw	a4,a4,a2
 8a0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8a2:	ff053683          	ld	a3,-16(a0)
 8a6:	bfd1                	j	87a <free+0x58>

00000000000008a8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8a8:	7139                	addi	sp,sp,-64
 8aa:	fc06                	sd	ra,56(sp)
 8ac:	f822                	sd	s0,48(sp)
 8ae:	f04a                	sd	s2,32(sp)
 8b0:	ec4e                	sd	s3,24(sp)
 8b2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8b4:	02051993          	slli	s3,a0,0x20
 8b8:	0209d993          	srli	s3,s3,0x20
 8bc:	09bd                	addi	s3,s3,15
 8be:	0049d993          	srli	s3,s3,0x4
 8c2:	2985                	addiw	s3,s3,1
 8c4:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 8c6:	00000517          	auipc	a0,0x0
 8ca:	73a53503          	ld	a0,1850(a0) # 1000 <freep>
 8ce:	c905                	beqz	a0,8fe <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d2:	4798                	lw	a4,8(a5)
 8d4:	09377663          	bgeu	a4,s3,960 <malloc+0xb8>
 8d8:	f426                	sd	s1,40(sp)
 8da:	e852                	sd	s4,16(sp)
 8dc:	e456                	sd	s5,8(sp)
 8de:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8e0:	8a4e                	mv	s4,s3
 8e2:	6705                	lui	a4,0x1
 8e4:	00e9f363          	bgeu	s3,a4,8ea <malloc+0x42>
 8e8:	6a05                	lui	s4,0x1
 8ea:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ee:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8f2:	00000497          	auipc	s1,0x0
 8f6:	70e48493          	addi	s1,s1,1806 # 1000 <freep>
  if(p == SBRK_ERROR)
 8fa:	5afd                	li	s5,-1
 8fc:	a83d                	j	93a <malloc+0x92>
 8fe:	f426                	sd	s1,40(sp)
 900:	e852                	sd	s4,16(sp)
 902:	e456                	sd	s5,8(sp)
 904:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 906:	00000797          	auipc	a5,0x0
 90a:	70a78793          	addi	a5,a5,1802 # 1010 <base>
 90e:	00000717          	auipc	a4,0x0
 912:	6ef73923          	sd	a5,1778(a4) # 1000 <freep>
 916:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 918:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 91c:	b7d1                	j	8e0 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 91e:	6398                	ld	a4,0(a5)
 920:	e118                	sd	a4,0(a0)
 922:	a899                	j	978 <malloc+0xd0>
  hp->s.size = nu;
 924:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 928:	0541                	addi	a0,a0,16
 92a:	ef9ff0ef          	jal	822 <free>
  return freep;
 92e:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 930:	c125                	beqz	a0,990 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 932:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 934:	4798                	lw	a4,8(a5)
 936:	03277163          	bgeu	a4,s2,958 <malloc+0xb0>
    if(p == freep)
 93a:	6098                	ld	a4,0(s1)
 93c:	853e                	mv	a0,a5
 93e:	fef71ae3          	bne	a4,a5,932 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 942:	8552                	mv	a0,s4
 944:	a1bff0ef          	jal	35e <sbrk>
  if(p == SBRK_ERROR)
 948:	fd551ee3          	bne	a0,s5,924 <malloc+0x7c>
        return 0;
 94c:	4501                	li	a0,0
 94e:	74a2                	ld	s1,40(sp)
 950:	6a42                	ld	s4,16(sp)
 952:	6aa2                	ld	s5,8(sp)
 954:	6b02                	ld	s6,0(sp)
 956:	a03d                	j	984 <malloc+0xdc>
 958:	74a2                	ld	s1,40(sp)
 95a:	6a42                	ld	s4,16(sp)
 95c:	6aa2                	ld	s5,8(sp)
 95e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 960:	fae90fe3          	beq	s2,a4,91e <malloc+0x76>
        p->s.size -= nunits;
 964:	4137073b          	subw	a4,a4,s3
 968:	c798                	sw	a4,8(a5)
        p += p->s.size;
 96a:	02071693          	slli	a3,a4,0x20
 96e:	01c6d713          	srli	a4,a3,0x1c
 972:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 974:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 978:	00000717          	auipc	a4,0x0
 97c:	68a73423          	sd	a0,1672(a4) # 1000 <freep>
      return (void*)(p + 1);
 980:	01078513          	addi	a0,a5,16
  }
}
 984:	70e2                	ld	ra,56(sp)
 986:	7442                	ld	s0,48(sp)
 988:	7902                	ld	s2,32(sp)
 98a:	69e2                	ld	s3,24(sp)
 98c:	6121                	addi	sp,sp,64
 98e:	8082                	ret
 990:	74a2                	ld	s1,40(sp)
 992:	6a42                	ld	s4,16(sp)
 994:	6aa2                	ld	s5,8(sp)
 996:	6b02                	ld	s6,0(sp)
 998:	b7f5                	j	984 <malloc+0xdc>
