
user/_sclimit:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fail>:
#include "kernel/stat.h"
#include "user/user.h"

static void
fail(const char *msg)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
   8:	85aa                	mv	a1,a0
  printf("sclimit: FAIL: %s\n", msg);
   a:	00001517          	auipc	a0,0x1
   e:	b0650513          	addi	a0,a0,-1274 # b10 <malloc+0xfa>
  12:	14d000ef          	jal	95e <printf>
  exit(1);
  16:	4505                	li	a0,1
  18:	46a000ef          	jal	482 <exit>

000000000000001c <main>:
  printf("sclimit: PASS: %s\n", msg);
}

int
main(void)
{
  1c:	1101                	addi	sp,sp,-32
  1e:	ec06                	sd	ra,24(sp)
  20:	e822                	sd	s0,16(sp)
  22:	1000                	addi	s0,sp,32
  int pid;
  int status;

  if(setchildlimit(2) != 0)
  24:	4509                	li	a0,2
  26:	588000ef          	jal	5ae <setchildlimit>
  2a:	c519                	beqz	a0,38 <main+0x1c>
    fail("setchildlimit(2) should return 0");
  2c:	00001517          	auipc	a0,0x1
  30:	afc50513          	addi	a0,a0,-1284 # b28 <malloc+0x112>
  34:	fcdff0ef          	jal	0 <fail>

  pid = fork();
  38:	442000ef          	jal	47a <fork>
  if(pid < 0)
  3c:	00054a63          	bltz	a0,50 <main+0x34>
    fail("first fork should succeed with limit=2");
  if(pid == 0){
  40:	ed11                	bnez	a0,5c <main+0x40>
    pause(200);
  42:	0c800513          	li	a0,200
  46:	558000ef          	jal	59e <pause>
    exit(0);
  4a:	4501                	li	a0,0
  4c:	436000ef          	jal	482 <exit>
    fail("first fork should succeed with limit=2");
  50:	00001517          	auipc	a0,0x1
  54:	b0050513          	addi	a0,a0,-1280 # b50 <malloc+0x13a>
  58:	fa9ff0ef          	jal	0 <fail>
  }

  pid = fork();
  5c:	41e000ef          	jal	47a <fork>
  if(pid < 0)
  60:	00054a63          	bltz	a0,74 <main+0x58>
    fail("second fork should succeed with limit=2");
  if(pid == 0){
  64:	ed11                	bnez	a0,80 <main+0x64>
    pause(200);
  66:	0c800513          	li	a0,200
  6a:	534000ef          	jal	59e <pause>
    exit(0);
  6e:	4501                	li	a0,0
  70:	412000ef          	jal	482 <exit>
    fail("second fork should succeed with limit=2");
  74:	00001517          	auipc	a0,0x1
  78:	b0450513          	addi	a0,a0,-1276 # b78 <malloc+0x162>
  7c:	f85ff0ef          	jal	0 <fail>
  }

  pid = fork();
  80:	3fa000ef          	jal	47a <fork>
  if(pid != -1)
  84:	57fd                	li	a5,-1
  86:	00f50863          	beq	a0,a5,96 <main+0x7a>
    fail("third fork should fail when child limit is reached");
  8a:	00001517          	auipc	a0,0x1
  8e:	b1650513          	addi	a0,a0,-1258 # ba0 <malloc+0x18a>
  92:	f6fff0ef          	jal	0 <fail>
  printf("sclimit: PASS: %s\n", msg);
  96:	00001597          	auipc	a1,0x1
  9a:	b4258593          	addi	a1,a1,-1214 # bd8 <malloc+0x1c2>
  9e:	00001517          	auipc	a0,0x1
  a2:	b5a50513          	addi	a0,a0,-1190 # bf8 <malloc+0x1e2>
  a6:	0b9000ef          	jal	95e <printf>
  pass("fork blocked at child limit");

  if(wait(&status) < 0)
  aa:	fec40513          	addi	a0,s0,-20
  ae:	3dc000ef          	jal	48a <wait>
  b2:	00054f63          	bltz	a0,d0 <main+0xb4>
    fail("wait after reaching limit (child 1)");
  if(wait(&status) < 0)
  b6:	fec40513          	addi	a0,s0,-20
  ba:	3d0000ef          	jal	48a <wait>
  be:	00054f63          	bltz	a0,dc <main+0xc0>
    fail("wait after reaching limit (child 2)");

  pid = fork();
  c2:	3b8000ef          	jal	47a <fork>
  if(pid < 0)
  c6:	02054163          	bltz	a0,e8 <main+0xcc>
    fail("fork should succeed again after children are reaped");
  if(pid == 0)
  ca:	e50d                	bnez	a0,f4 <main+0xd8>
    exit(0);
  cc:	3b6000ef          	jal	482 <exit>
    fail("wait after reaching limit (child 1)");
  d0:	00001517          	auipc	a0,0x1
  d4:	b4050513          	addi	a0,a0,-1216 # c10 <malloc+0x1fa>
  d8:	f29ff0ef          	jal	0 <fail>
    fail("wait after reaching limit (child 2)");
  dc:	00001517          	auipc	a0,0x1
  e0:	b5c50513          	addi	a0,a0,-1188 # c38 <malloc+0x222>
  e4:	f1dff0ef          	jal	0 <fail>
    fail("fork should succeed again after children are reaped");
  e8:	00001517          	auipc	a0,0x1
  ec:	b7850513          	addi	a0,a0,-1160 # c60 <malloc+0x24a>
  f0:	f11ff0ef          	jal	0 <fail>
  if(wait(&status) < 0)
  f4:	fec40513          	addi	a0,s0,-20
  f8:	392000ef          	jal	48a <wait>
  fc:	02054663          	bltz	a0,128 <main+0x10c>
  printf("sclimit: PASS: %s\n", msg);
 100:	00001597          	auipc	a1,0x1
 104:	bb858593          	addi	a1,a1,-1096 # cb8 <malloc+0x2a2>
 108:	00001517          	auipc	a0,0x1
 10c:	af050513          	addi	a0,a0,-1296 # bf8 <malloc+0x1e2>
 110:	04f000ef          	jal	95e <printf>
    fail("wait for post-reap child");
  pass("fork allowed again after reaping children");

  if(setchildlimit(0) != 0)
 114:	4501                	li	a0,0
 116:	498000ef          	jal	5ae <setchildlimit>
 11a:	cd09                	beqz	a0,134 <main+0x118>
    fail("setchildlimit(0) should return 0");
 11c:	00001517          	auipc	a0,0x1
 120:	bcc50513          	addi	a0,a0,-1076 # ce8 <malloc+0x2d2>
 124:	eddff0ef          	jal	0 <fail>
    fail("wait for post-reap child");
 128:	00001517          	auipc	a0,0x1
 12c:	b7050513          	addi	a0,a0,-1168 # c98 <malloc+0x282>
 130:	ed1ff0ef          	jal	0 <fail>
  pid = fork();
 134:	346000ef          	jal	47a <fork>
  if(pid != -1)
 138:	57fd                	li	a5,-1
 13a:	00f50863          	beq	a0,a5,14a <main+0x12e>
    fail("fork should fail when limit is 0");
 13e:	00001517          	auipc	a0,0x1
 142:	bd250513          	addi	a0,a0,-1070 # d10 <malloc+0x2fa>
 146:	ebbff0ef          	jal	0 <fail>
  printf("sclimit: PASS: %s\n", msg);
 14a:	00001597          	auipc	a1,0x1
 14e:	bee58593          	addi	a1,a1,-1042 # d38 <malloc+0x322>
 152:	00001517          	auipc	a0,0x1
 156:	aa650513          	addi	a0,a0,-1370 # bf8 <malloc+0x1e2>
 15a:	005000ef          	jal	95e <printf>
  pass("limit=0 blocks fork");

  if(setchildlimit(-1) != 0)
 15e:	557d                	li	a0,-1
 160:	44e000ef          	jal	5ae <setchildlimit>
 164:	c519                	beqz	a0,172 <main+0x156>
    fail("setchildlimit(-1) should return 0");
 166:	00001517          	auipc	a0,0x1
 16a:	bea50513          	addi	a0,a0,-1046 # d50 <malloc+0x33a>
 16e:	e93ff0ef          	jal	0 <fail>
  pid = fork();
 172:	308000ef          	jal	47a <fork>
  if(pid < 0)
 176:	00054663          	bltz	a0,182 <main+0x166>
    fail("fork should succeed again when limit=-1 (disabled)");
  if(pid == 0)
 17a:	e911                	bnez	a0,18e <main+0x172>
    exit(0);
 17c:	4501                	li	a0,0
 17e:	304000ef          	jal	482 <exit>
    fail("fork should succeed again when limit=-1 (disabled)");
 182:	00001517          	auipc	a0,0x1
 186:	bf650513          	addi	a0,a0,-1034 # d78 <malloc+0x362>
 18a:	e77ff0ef          	jal	0 <fail>
  if(wait(&status) < 0)
 18e:	fec40513          	addi	a0,s0,-20
 192:	2f8000ef          	jal	48a <wait>
 196:	02054563          	bltz	a0,1c0 <main+0x1a4>
  printf("sclimit: PASS: %s\n", msg);
 19a:	00001597          	auipc	a1,0x1
 19e:	c3658593          	addi	a1,a1,-970 # dd0 <malloc+0x3ba>
 1a2:	00001517          	auipc	a0,0x1
 1a6:	a5650513          	addi	a0,a0,-1450 # bf8 <malloc+0x1e2>
 1aa:	7b4000ef          	jal	95e <printf>
    fail("wait for unlimited-mode child");
  pass("limit=-1 disables restriction");

  printf("sclimit: all checks passed\n");
 1ae:	00001517          	auipc	a0,0x1
 1b2:	c4250513          	addi	a0,a0,-958 # df0 <malloc+0x3da>
 1b6:	7a8000ef          	jal	95e <printf>
  exit(0);
 1ba:	4501                	li	a0,0
 1bc:	2c6000ef          	jal	482 <exit>
    fail("wait for unlimited-mode child");
 1c0:	00001517          	auipc	a0,0x1
 1c4:	bf050513          	addi	a0,a0,-1040 # db0 <malloc+0x39a>
 1c8:	e39ff0ef          	jal	0 <fail>

00000000000001cc <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1cc:	1141                	addi	sp,sp,-16
 1ce:	e406                	sd	ra,8(sp)
 1d0:	e022                	sd	s0,0(sp)
 1d2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1d4:	e49ff0ef          	jal	1c <main>
  exit(r);
 1d8:	2aa000ef          	jal	482 <exit>

00000000000001dc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1dc:	1141                	addi	sp,sp,-16
 1de:	e406                	sd	ra,8(sp)
 1e0:	e022                	sd	s0,0(sp)
 1e2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1e4:	87aa                	mv	a5,a0
 1e6:	0585                	addi	a1,a1,1
 1e8:	0785                	addi	a5,a5,1
 1ea:	fff5c703          	lbu	a4,-1(a1)
 1ee:	fee78fa3          	sb	a4,-1(a5)
 1f2:	fb75                	bnez	a4,1e6 <strcpy+0xa>
    ;
  return os;
}
 1f4:	60a2                	ld	ra,8(sp)
 1f6:	6402                	ld	s0,0(sp)
 1f8:	0141                	addi	sp,sp,16
 1fa:	8082                	ret

00000000000001fc <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1fc:	1141                	addi	sp,sp,-16
 1fe:	e406                	sd	ra,8(sp)
 200:	e022                	sd	s0,0(sp)
 202:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 204:	00054783          	lbu	a5,0(a0)
 208:	cb91                	beqz	a5,21c <strcmp+0x20>
 20a:	0005c703          	lbu	a4,0(a1)
 20e:	00f71763          	bne	a4,a5,21c <strcmp+0x20>
    p++, q++;
 212:	0505                	addi	a0,a0,1
 214:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 216:	00054783          	lbu	a5,0(a0)
 21a:	fbe5                	bnez	a5,20a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 21c:	0005c503          	lbu	a0,0(a1)
}
 220:	40a7853b          	subw	a0,a5,a0
 224:	60a2                	ld	ra,8(sp)
 226:	6402                	ld	s0,0(sp)
 228:	0141                	addi	sp,sp,16
 22a:	8082                	ret

000000000000022c <strlen>:

uint
strlen(const char *s)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e406                	sd	ra,8(sp)
 230:	e022                	sd	s0,0(sp)
 232:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 234:	00054783          	lbu	a5,0(a0)
 238:	cf91                	beqz	a5,254 <strlen+0x28>
 23a:	00150793          	addi	a5,a0,1
 23e:	86be                	mv	a3,a5
 240:	0785                	addi	a5,a5,1
 242:	fff7c703          	lbu	a4,-1(a5)
 246:	ff65                	bnez	a4,23e <strlen+0x12>
 248:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 24c:	60a2                	ld	ra,8(sp)
 24e:	6402                	ld	s0,0(sp)
 250:	0141                	addi	sp,sp,16
 252:	8082                	ret
  for(n = 0; s[n]; n++)
 254:	4501                	li	a0,0
 256:	bfdd                	j	24c <strlen+0x20>

0000000000000258 <memset>:

void*
memset(void *dst, int c, uint n)
{
 258:	1141                	addi	sp,sp,-16
 25a:	e406                	sd	ra,8(sp)
 25c:	e022                	sd	s0,0(sp)
 25e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 260:	ca19                	beqz	a2,276 <memset+0x1e>
 262:	87aa                	mv	a5,a0
 264:	1602                	slli	a2,a2,0x20
 266:	9201                	srli	a2,a2,0x20
 268:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 26c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 270:	0785                	addi	a5,a5,1
 272:	fee79de3          	bne	a5,a4,26c <memset+0x14>
  }
  return dst;
}
 276:	60a2                	ld	ra,8(sp)
 278:	6402                	ld	s0,0(sp)
 27a:	0141                	addi	sp,sp,16
 27c:	8082                	ret

000000000000027e <strchr>:

char*
strchr(const char *s, char c)
{
 27e:	1141                	addi	sp,sp,-16
 280:	e406                	sd	ra,8(sp)
 282:	e022                	sd	s0,0(sp)
 284:	0800                	addi	s0,sp,16
  for(; *s; s++)
 286:	00054783          	lbu	a5,0(a0)
 28a:	cf81                	beqz	a5,2a2 <strchr+0x24>
    if(*s == c)
 28c:	00f58763          	beq	a1,a5,29a <strchr+0x1c>
  for(; *s; s++)
 290:	0505                	addi	a0,a0,1
 292:	00054783          	lbu	a5,0(a0)
 296:	fbfd                	bnez	a5,28c <strchr+0xe>
      return (char*)s;
  return 0;
 298:	4501                	li	a0,0
}
 29a:	60a2                	ld	ra,8(sp)
 29c:	6402                	ld	s0,0(sp)
 29e:	0141                	addi	sp,sp,16
 2a0:	8082                	ret
  return 0;
 2a2:	4501                	li	a0,0
 2a4:	bfdd                	j	29a <strchr+0x1c>

00000000000002a6 <gets>:

char*
gets(char *buf, int max)
{
 2a6:	711d                	addi	sp,sp,-96
 2a8:	ec86                	sd	ra,88(sp)
 2aa:	e8a2                	sd	s0,80(sp)
 2ac:	e4a6                	sd	s1,72(sp)
 2ae:	e0ca                	sd	s2,64(sp)
 2b0:	fc4e                	sd	s3,56(sp)
 2b2:	f852                	sd	s4,48(sp)
 2b4:	f456                	sd	s5,40(sp)
 2b6:	f05a                	sd	s6,32(sp)
 2b8:	ec5e                	sd	s7,24(sp)
 2ba:	e862                	sd	s8,16(sp)
 2bc:	1080                	addi	s0,sp,96
 2be:	8baa                	mv	s7,a0
 2c0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c2:	892a                	mv	s2,a0
 2c4:	4481                	li	s1,0
    cc = read(0, &c, 1);
 2c6:	faf40b13          	addi	s6,s0,-81
 2ca:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 2cc:	8c26                	mv	s8,s1
 2ce:	0014899b          	addiw	s3,s1,1
 2d2:	84ce                	mv	s1,s3
 2d4:	0349d463          	bge	s3,s4,2fc <gets+0x56>
    cc = read(0, &c, 1);
 2d8:	8656                	mv	a2,s5
 2da:	85da                	mv	a1,s6
 2dc:	4501                	li	a0,0
 2de:	1bc000ef          	jal	49a <read>
    if(cc < 1)
 2e2:	00a05d63          	blez	a0,2fc <gets+0x56>
      break;
    buf[i++] = c;
 2e6:	faf44783          	lbu	a5,-81(s0)
 2ea:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2ee:	0905                	addi	s2,s2,1
 2f0:	ff678713          	addi	a4,a5,-10
 2f4:	c319                	beqz	a4,2fa <gets+0x54>
 2f6:	17cd                	addi	a5,a5,-13
 2f8:	fbf1                	bnez	a5,2cc <gets+0x26>
    buf[i++] = c;
 2fa:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 2fc:	9c5e                	add	s8,s8,s7
 2fe:	000c0023          	sb	zero,0(s8)
  return buf;
}
 302:	855e                	mv	a0,s7
 304:	60e6                	ld	ra,88(sp)
 306:	6446                	ld	s0,80(sp)
 308:	64a6                	ld	s1,72(sp)
 30a:	6906                	ld	s2,64(sp)
 30c:	79e2                	ld	s3,56(sp)
 30e:	7a42                	ld	s4,48(sp)
 310:	7aa2                	ld	s5,40(sp)
 312:	7b02                	ld	s6,32(sp)
 314:	6be2                	ld	s7,24(sp)
 316:	6c42                	ld	s8,16(sp)
 318:	6125                	addi	sp,sp,96
 31a:	8082                	ret

000000000000031c <stat>:

int
stat(const char *n, struct stat *st)
{
 31c:	1101                	addi	sp,sp,-32
 31e:	ec06                	sd	ra,24(sp)
 320:	e822                	sd	s0,16(sp)
 322:	e04a                	sd	s2,0(sp)
 324:	1000                	addi	s0,sp,32
 326:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 328:	4581                	li	a1,0
 32a:	224000ef          	jal	54e <open>
  if(fd < 0)
 32e:	02054263          	bltz	a0,352 <stat+0x36>
 332:	e426                	sd	s1,8(sp)
 334:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 336:	85ca                	mv	a1,s2
 338:	22e000ef          	jal	566 <fstat>
 33c:	892a                	mv	s2,a0
  close(fd);
 33e:	8526                	mv	a0,s1
 340:	16a000ef          	jal	4aa <close>
  return r;
 344:	64a2                	ld	s1,8(sp)
}
 346:	854a                	mv	a0,s2
 348:	60e2                	ld	ra,24(sp)
 34a:	6442                	ld	s0,16(sp)
 34c:	6902                	ld	s2,0(sp)
 34e:	6105                	addi	sp,sp,32
 350:	8082                	ret
    return -1;
 352:	57fd                	li	a5,-1
 354:	893e                	mv	s2,a5
 356:	bfc5                	j	346 <stat+0x2a>

0000000000000358 <atoi>:

int
atoi(const char *s)
{
 358:	1141                	addi	sp,sp,-16
 35a:	e406                	sd	ra,8(sp)
 35c:	e022                	sd	s0,0(sp)
 35e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 360:	00054683          	lbu	a3,0(a0)
 364:	fd06879b          	addiw	a5,a3,-48
 368:	0ff7f793          	zext.b	a5,a5
 36c:	4625                	li	a2,9
 36e:	02f66963          	bltu	a2,a5,3a0 <atoi+0x48>
 372:	872a                	mv	a4,a0
  n = 0;
 374:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 376:	0705                	addi	a4,a4,1
 378:	0025179b          	slliw	a5,a0,0x2
 37c:	9fa9                	addw	a5,a5,a0
 37e:	0017979b          	slliw	a5,a5,0x1
 382:	9fb5                	addw	a5,a5,a3
 384:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 388:	00074683          	lbu	a3,0(a4)
 38c:	fd06879b          	addiw	a5,a3,-48
 390:	0ff7f793          	zext.b	a5,a5
 394:	fef671e3          	bgeu	a2,a5,376 <atoi+0x1e>
  return n;
}
 398:	60a2                	ld	ra,8(sp)
 39a:	6402                	ld	s0,0(sp)
 39c:	0141                	addi	sp,sp,16
 39e:	8082                	ret
  n = 0;
 3a0:	4501                	li	a0,0
 3a2:	bfdd                	j	398 <atoi+0x40>

00000000000003a4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3a4:	1141                	addi	sp,sp,-16
 3a6:	e406                	sd	ra,8(sp)
 3a8:	e022                	sd	s0,0(sp)
 3aa:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3ac:	02b57563          	bgeu	a0,a1,3d6 <memmove+0x32>
    while(n-- > 0)
 3b0:	00c05f63          	blez	a2,3ce <memmove+0x2a>
 3b4:	1602                	slli	a2,a2,0x20
 3b6:	9201                	srli	a2,a2,0x20
 3b8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3bc:	872a                	mv	a4,a0
      *dst++ = *src++;
 3be:	0585                	addi	a1,a1,1
 3c0:	0705                	addi	a4,a4,1
 3c2:	fff5c683          	lbu	a3,-1(a1)
 3c6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3ca:	fee79ae3          	bne	a5,a4,3be <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3ce:	60a2                	ld	ra,8(sp)
 3d0:	6402                	ld	s0,0(sp)
 3d2:	0141                	addi	sp,sp,16
 3d4:	8082                	ret
    while(n-- > 0)
 3d6:	fec05ce3          	blez	a2,3ce <memmove+0x2a>
    dst += n;
 3da:	00c50733          	add	a4,a0,a2
    src += n;
 3de:	95b2                	add	a1,a1,a2
 3e0:	fff6079b          	addiw	a5,a2,-1
 3e4:	1782                	slli	a5,a5,0x20
 3e6:	9381                	srli	a5,a5,0x20
 3e8:	fff7c793          	not	a5,a5
 3ec:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3ee:	15fd                	addi	a1,a1,-1
 3f0:	177d                	addi	a4,a4,-1
 3f2:	0005c683          	lbu	a3,0(a1)
 3f6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3fa:	fef71ae3          	bne	a4,a5,3ee <memmove+0x4a>
 3fe:	bfc1                	j	3ce <memmove+0x2a>

0000000000000400 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 400:	1141                	addi	sp,sp,-16
 402:	e406                	sd	ra,8(sp)
 404:	e022                	sd	s0,0(sp)
 406:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 408:	c61d                	beqz	a2,436 <memcmp+0x36>
 40a:	1602                	slli	a2,a2,0x20
 40c:	9201                	srli	a2,a2,0x20
 40e:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 412:	00054783          	lbu	a5,0(a0)
 416:	0005c703          	lbu	a4,0(a1)
 41a:	00e79863          	bne	a5,a4,42a <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 41e:	0505                	addi	a0,a0,1
    p2++;
 420:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 422:	fed518e3          	bne	a0,a3,412 <memcmp+0x12>
  }
  return 0;
 426:	4501                	li	a0,0
 428:	a019                	j	42e <memcmp+0x2e>
      return *p1 - *p2;
 42a:	40e7853b          	subw	a0,a5,a4
}
 42e:	60a2                	ld	ra,8(sp)
 430:	6402                	ld	s0,0(sp)
 432:	0141                	addi	sp,sp,16
 434:	8082                	ret
  return 0;
 436:	4501                	li	a0,0
 438:	bfdd                	j	42e <memcmp+0x2e>

000000000000043a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 43a:	1141                	addi	sp,sp,-16
 43c:	e406                	sd	ra,8(sp)
 43e:	e022                	sd	s0,0(sp)
 440:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 442:	f63ff0ef          	jal	3a4 <memmove>
}
 446:	60a2                	ld	ra,8(sp)
 448:	6402                	ld	s0,0(sp)
 44a:	0141                	addi	sp,sp,16
 44c:	8082                	ret

000000000000044e <sbrk>:

char *
sbrk(int n) {
 44e:	1141                	addi	sp,sp,-16
 450:	e406                	sd	ra,8(sp)
 452:	e022                	sd	s0,0(sp)
 454:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 456:	4585                	li	a1,1
 458:	13e000ef          	jal	596 <sys_sbrk>
}
 45c:	60a2                	ld	ra,8(sp)
 45e:	6402                	ld	s0,0(sp)
 460:	0141                	addi	sp,sp,16
 462:	8082                	ret

0000000000000464 <sbrklazy>:

char *
sbrklazy(int n) {
 464:	1141                	addi	sp,sp,-16
 466:	e406                	sd	ra,8(sp)
 468:	e022                	sd	s0,0(sp)
 46a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 46c:	4589                	li	a1,2
 46e:	128000ef          	jal	596 <sys_sbrk>
}
 472:	60a2                	ld	ra,8(sp)
 474:	6402                	ld	s0,0(sp)
 476:	0141                	addi	sp,sp,16
 478:	8082                	ret

000000000000047a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 47a:	4885                	li	a7,1
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <exit>:
.global exit
exit:
 li a7, SYS_exit
 482:	4889                	li	a7,2
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <wait>:
.global wait
wait:
 li a7, SYS_wait
 48a:	488d                	li	a7,3
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 492:	4891                	li	a7,4
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <read>:
.global read
read:
 li a7, SYS_read
 49a:	4895                	li	a7,5
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <write>:
.global write
write:
 li a7, SYS_write
 4a2:	48c1                	li	a7,16
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <close>:
.global close
close:
 li a7, SYS_close
 4aa:	48d5                	li	a7,21
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 4b2:	48d9                	li	a7,22
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <shmat>:
.global shmat
shmat:
 li a7, SYS_shmat
 4ba:	48dd                	li	a7,23
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 4c2:	48e1                	li	a7,24
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 4ca:	48e5                	li	a7,25
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <lockinit>:
.global lockinit
lockinit:
 li a7, SYS_lockinit
 4d2:	48e9                	li	a7,26
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <lockacquire>:
.global lockacquire
lockacquire:
 li a7, SYS_lockacquire
 4da:	48ed                	li	a7,27
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <lockrelease>:
.global lockrelease
lockrelease:
 li a7, SYS_lockrelease
 4e2:	48f1                	li	a7,28
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <locktry>:
.global locktry
locktry:
 li a7, SYS_locktry
 4ea:	48f5                	li	a7,29
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <lockcheck>:
.global lockcheck
lockcheck:
 li a7, SYS_lockcheck
 4f2:	48f9                	li	a7,30
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <sendmsg>:
.global sendmsg
sendmsg:
 li a7, SYS_sendmsg
 4fa:	48fd                	li	a7,31
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <recvmsg>:
.global recvmsg
recvmsg:
 li a7, SYS_recvmsg
 502:	02000893          	li	a7,32
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <broadcast>:
.global broadcast
broadcast:
 li a7, SYS_broadcast
 50c:	02100893          	li	a7,33
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <getprocsinfo>:
.global getprocsinfo
getprocsinfo:
 li a7, SYS_getprocsinfo
 516:	02200893          	li	a7,34
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 520:	02300893          	li	a7,35
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <sleep2>:
.global sleep2
sleep2:
 li a7, SYS_sleep2
 52a:	02400893          	li	a7,36
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <signal>:
.global signal
signal:
 li a7, SYS_signal
 534:	02500893          	li	a7,37
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <kill>:
.global kill
kill:
 li a7, SYS_kill
 53e:	4899                	li	a7,6
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <exec>:
.global exec
exec:
 li a7, SYS_exec
 546:	489d                	li	a7,7
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <open>:
.global open
open:
 li a7, SYS_open
 54e:	48bd                	li	a7,15
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 556:	48c5                	li	a7,17
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 55e:	48c9                	li	a7,18
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 566:	48a1                	li	a7,8
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <link>:
.global link
link:
 li a7, SYS_link
 56e:	48cd                	li	a7,19
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 576:	48d1                	li	a7,20
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 57e:	48a5                	li	a7,9
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <dup>:
.global dup
dup:
 li a7, SYS_dup
 586:	48a9                	li	a7,10
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 58e:	48ad                	li	a7,11
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 596:	48b1                	li	a7,12
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <pause>:
.global pause
pause:
 li a7, SYS_pause
 59e:	48b5                	li	a7,13
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5a6:	48b9                	li	a7,14
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <setchildlimit>:
.global setchildlimit
setchildlimit:
 li a7, SYS_setchildlimit
 5ae:	02600893          	li	a7,38
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5b8:	1101                	addi	sp,sp,-32
 5ba:	ec06                	sd	ra,24(sp)
 5bc:	e822                	sd	s0,16(sp)
 5be:	1000                	addi	s0,sp,32
 5c0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5c4:	4605                	li	a2,1
 5c6:	fef40593          	addi	a1,s0,-17
 5ca:	ed9ff0ef          	jal	4a2 <write>
}
 5ce:	60e2                	ld	ra,24(sp)
 5d0:	6442                	ld	s0,16(sp)
 5d2:	6105                	addi	sp,sp,32
 5d4:	8082                	ret

00000000000005d6 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5d6:	715d                	addi	sp,sp,-80
 5d8:	e486                	sd	ra,72(sp)
 5da:	e0a2                	sd	s0,64(sp)
 5dc:	f84a                	sd	s2,48(sp)
 5de:	f44e                	sd	s3,40(sp)
 5e0:	0880                	addi	s0,sp,80
 5e2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 5e4:	c6d1                	beqz	a3,670 <printint+0x9a>
 5e6:	0805d563          	bgez	a1,670 <printint+0x9a>
    neg = 1;
    x = -xx;
 5ea:	40b005b3          	neg	a1,a1
    neg = 1;
 5ee:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 5f0:	fb840993          	addi	s3,s0,-72
  neg = 0;
 5f4:	86ce                	mv	a3,s3
  i = 0;
 5f6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5f8:	00001817          	auipc	a6,0x1
 5fc:	82080813          	addi	a6,a6,-2016 # e18 <digits>
 600:	88ba                	mv	a7,a4
 602:	0017051b          	addiw	a0,a4,1
 606:	872a                	mv	a4,a0
 608:	02c5f7b3          	remu	a5,a1,a2
 60c:	97c2                	add	a5,a5,a6
 60e:	0007c783          	lbu	a5,0(a5)
 612:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 616:	87ae                	mv	a5,a1
 618:	02c5d5b3          	divu	a1,a1,a2
 61c:	0685                	addi	a3,a3,1
 61e:	fec7f1e3          	bgeu	a5,a2,600 <printint+0x2a>
  if(neg)
 622:	00030c63          	beqz	t1,63a <printint+0x64>
    buf[i++] = '-';
 626:	fd050793          	addi	a5,a0,-48
 62a:	00878533          	add	a0,a5,s0
 62e:	02d00793          	li	a5,45
 632:	fef50423          	sb	a5,-24(a0)
 636:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 63a:	02e05563          	blez	a4,664 <printint+0x8e>
 63e:	fc26                	sd	s1,56(sp)
 640:	377d                	addiw	a4,a4,-1
 642:	00e984b3          	add	s1,s3,a4
 646:	19fd                	addi	s3,s3,-1
 648:	99ba                	add	s3,s3,a4
 64a:	1702                	slli	a4,a4,0x20
 64c:	9301                	srli	a4,a4,0x20
 64e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 652:	0004c583          	lbu	a1,0(s1)
 656:	854a                	mv	a0,s2
 658:	f61ff0ef          	jal	5b8 <putc>
  while(--i >= 0)
 65c:	14fd                	addi	s1,s1,-1
 65e:	ff349ae3          	bne	s1,s3,652 <printint+0x7c>
 662:	74e2                	ld	s1,56(sp)
}
 664:	60a6                	ld	ra,72(sp)
 666:	6406                	ld	s0,64(sp)
 668:	7942                	ld	s2,48(sp)
 66a:	79a2                	ld	s3,40(sp)
 66c:	6161                	addi	sp,sp,80
 66e:	8082                	ret
  neg = 0;
 670:	4301                	li	t1,0
 672:	bfbd                	j	5f0 <printint+0x1a>

0000000000000674 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 674:	711d                	addi	sp,sp,-96
 676:	ec86                	sd	ra,88(sp)
 678:	e8a2                	sd	s0,80(sp)
 67a:	e4a6                	sd	s1,72(sp)
 67c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 67e:	0005c483          	lbu	s1,0(a1)
 682:	22048363          	beqz	s1,8a8 <vprintf+0x234>
 686:	e0ca                	sd	s2,64(sp)
 688:	fc4e                	sd	s3,56(sp)
 68a:	f852                	sd	s4,48(sp)
 68c:	f456                	sd	s5,40(sp)
 68e:	f05a                	sd	s6,32(sp)
 690:	ec5e                	sd	s7,24(sp)
 692:	e862                	sd	s8,16(sp)
 694:	8b2a                	mv	s6,a0
 696:	8a2e                	mv	s4,a1
 698:	8bb2                	mv	s7,a2
  state = 0;
 69a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 69c:	4901                	li	s2,0
 69e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6a0:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6a4:	06400c13          	li	s8,100
 6a8:	a00d                	j	6ca <vprintf+0x56>
        putc(fd, c0);
 6aa:	85a6                	mv	a1,s1
 6ac:	855a                	mv	a0,s6
 6ae:	f0bff0ef          	jal	5b8 <putc>
 6b2:	a019                	j	6b8 <vprintf+0x44>
    } else if(state == '%'){
 6b4:	03598363          	beq	s3,s5,6da <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 6b8:	0019079b          	addiw	a5,s2,1
 6bc:	893e                	mv	s2,a5
 6be:	873e                	mv	a4,a5
 6c0:	97d2                	add	a5,a5,s4
 6c2:	0007c483          	lbu	s1,0(a5)
 6c6:	1c048a63          	beqz	s1,89a <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 6ca:	0004879b          	sext.w	a5,s1
    if(state == 0){
 6ce:	fe0993e3          	bnez	s3,6b4 <vprintf+0x40>
      if(c0 == '%'){
 6d2:	fd579ce3          	bne	a5,s5,6aa <vprintf+0x36>
        state = '%';
 6d6:	89be                	mv	s3,a5
 6d8:	b7c5                	j	6b8 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 6da:	00ea06b3          	add	a3,s4,a4
 6de:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 6e2:	1c060863          	beqz	a2,8b2 <vprintf+0x23e>
      if(c0 == 'd'){
 6e6:	03878763          	beq	a5,s8,714 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6ea:	f9478693          	addi	a3,a5,-108
 6ee:	0016b693          	seqz	a3,a3
 6f2:	f9c60593          	addi	a1,a2,-100
 6f6:	e99d                	bnez	a1,72c <vprintf+0xb8>
 6f8:	ca95                	beqz	a3,72c <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6fa:	008b8493          	addi	s1,s7,8
 6fe:	4685                	li	a3,1
 700:	4629                	li	a2,10
 702:	000bb583          	ld	a1,0(s7)
 706:	855a                	mv	a0,s6
 708:	ecfff0ef          	jal	5d6 <printint>
        i += 1;
 70c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 70e:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 710:	4981                	li	s3,0
 712:	b75d                	j	6b8 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 714:	008b8493          	addi	s1,s7,8
 718:	4685                	li	a3,1
 71a:	4629                	li	a2,10
 71c:	000ba583          	lw	a1,0(s7)
 720:	855a                	mv	a0,s6
 722:	eb5ff0ef          	jal	5d6 <printint>
 726:	8ba6                	mv	s7,s1
      state = 0;
 728:	4981                	li	s3,0
 72a:	b779                	j	6b8 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 72c:	9752                	add	a4,a4,s4
 72e:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 732:	f9460713          	addi	a4,a2,-108
 736:	00173713          	seqz	a4,a4
 73a:	8f75                	and	a4,a4,a3
 73c:	f9c58513          	addi	a0,a1,-100
 740:	18051363          	bnez	a0,8c6 <vprintf+0x252>
 744:	18070163          	beqz	a4,8c6 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 748:	008b8493          	addi	s1,s7,8
 74c:	4685                	li	a3,1
 74e:	4629                	li	a2,10
 750:	000bb583          	ld	a1,0(s7)
 754:	855a                	mv	a0,s6
 756:	e81ff0ef          	jal	5d6 <printint>
        i += 2;
 75a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 75c:	8ba6                	mv	s7,s1
      state = 0;
 75e:	4981                	li	s3,0
        i += 2;
 760:	bfa1                	j	6b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 762:	008b8493          	addi	s1,s7,8
 766:	4681                	li	a3,0
 768:	4629                	li	a2,10
 76a:	000be583          	lwu	a1,0(s7)
 76e:	855a                	mv	a0,s6
 770:	e67ff0ef          	jal	5d6 <printint>
 774:	8ba6                	mv	s7,s1
      state = 0;
 776:	4981                	li	s3,0
 778:	b781                	j	6b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 77a:	008b8493          	addi	s1,s7,8
 77e:	4681                	li	a3,0
 780:	4629                	li	a2,10
 782:	000bb583          	ld	a1,0(s7)
 786:	855a                	mv	a0,s6
 788:	e4fff0ef          	jal	5d6 <printint>
        i += 1;
 78c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 78e:	8ba6                	mv	s7,s1
      state = 0;
 790:	4981                	li	s3,0
 792:	b71d                	j	6b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 794:	008b8493          	addi	s1,s7,8
 798:	4681                	li	a3,0
 79a:	4629                	li	a2,10
 79c:	000bb583          	ld	a1,0(s7)
 7a0:	855a                	mv	a0,s6
 7a2:	e35ff0ef          	jal	5d6 <printint>
        i += 2;
 7a6:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7a8:	8ba6                	mv	s7,s1
      state = 0;
 7aa:	4981                	li	s3,0
        i += 2;
 7ac:	b731                	j	6b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 7ae:	008b8493          	addi	s1,s7,8
 7b2:	4681                	li	a3,0
 7b4:	4641                	li	a2,16
 7b6:	000be583          	lwu	a1,0(s7)
 7ba:	855a                	mv	a0,s6
 7bc:	e1bff0ef          	jal	5d6 <printint>
 7c0:	8ba6                	mv	s7,s1
      state = 0;
 7c2:	4981                	li	s3,0
 7c4:	bdd5                	j	6b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7c6:	008b8493          	addi	s1,s7,8
 7ca:	4681                	li	a3,0
 7cc:	4641                	li	a2,16
 7ce:	000bb583          	ld	a1,0(s7)
 7d2:	855a                	mv	a0,s6
 7d4:	e03ff0ef          	jal	5d6 <printint>
        i += 1;
 7d8:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7da:	8ba6                	mv	s7,s1
      state = 0;
 7dc:	4981                	li	s3,0
 7de:	bde9                	j	6b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7e0:	008b8493          	addi	s1,s7,8
 7e4:	4681                	li	a3,0
 7e6:	4641                	li	a2,16
 7e8:	000bb583          	ld	a1,0(s7)
 7ec:	855a                	mv	a0,s6
 7ee:	de9ff0ef          	jal	5d6 <printint>
        i += 2;
 7f2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7f4:	8ba6                	mv	s7,s1
      state = 0;
 7f6:	4981                	li	s3,0
        i += 2;
 7f8:	b5c1                	j	6b8 <vprintf+0x44>
 7fa:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 7fc:	008b8793          	addi	a5,s7,8
 800:	8cbe                	mv	s9,a5
 802:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 806:	03000593          	li	a1,48
 80a:	855a                	mv	a0,s6
 80c:	dadff0ef          	jal	5b8 <putc>
  putc(fd, 'x');
 810:	07800593          	li	a1,120
 814:	855a                	mv	a0,s6
 816:	da3ff0ef          	jal	5b8 <putc>
 81a:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 81c:	00000b97          	auipc	s7,0x0
 820:	5fcb8b93          	addi	s7,s7,1532 # e18 <digits>
 824:	03c9d793          	srli	a5,s3,0x3c
 828:	97de                	add	a5,a5,s7
 82a:	0007c583          	lbu	a1,0(a5)
 82e:	855a                	mv	a0,s6
 830:	d89ff0ef          	jal	5b8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 834:	0992                	slli	s3,s3,0x4
 836:	34fd                	addiw	s1,s1,-1
 838:	f4f5                	bnez	s1,824 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 83a:	8be6                	mv	s7,s9
      state = 0;
 83c:	4981                	li	s3,0
 83e:	6ca2                	ld	s9,8(sp)
 840:	bda5                	j	6b8 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 842:	008b8493          	addi	s1,s7,8
 846:	000bc583          	lbu	a1,0(s7)
 84a:	855a                	mv	a0,s6
 84c:	d6dff0ef          	jal	5b8 <putc>
 850:	8ba6                	mv	s7,s1
      state = 0;
 852:	4981                	li	s3,0
 854:	b595                	j	6b8 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 856:	008b8993          	addi	s3,s7,8
 85a:	000bb483          	ld	s1,0(s7)
 85e:	cc91                	beqz	s1,87a <vprintf+0x206>
        for(; *s; s++)
 860:	0004c583          	lbu	a1,0(s1)
 864:	c985                	beqz	a1,894 <vprintf+0x220>
          putc(fd, *s);
 866:	855a                	mv	a0,s6
 868:	d51ff0ef          	jal	5b8 <putc>
        for(; *s; s++)
 86c:	0485                	addi	s1,s1,1
 86e:	0004c583          	lbu	a1,0(s1)
 872:	f9f5                	bnez	a1,866 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 874:	8bce                	mv	s7,s3
      state = 0;
 876:	4981                	li	s3,0
 878:	b581                	j	6b8 <vprintf+0x44>
          s = "(null)";
 87a:	00000497          	auipc	s1,0x0
 87e:	59648493          	addi	s1,s1,1430 # e10 <malloc+0x3fa>
        for(; *s; s++)
 882:	02800593          	li	a1,40
 886:	b7c5                	j	866 <vprintf+0x1f2>
        putc(fd, '%');
 888:	85be                	mv	a1,a5
 88a:	855a                	mv	a0,s6
 88c:	d2dff0ef          	jal	5b8 <putc>
      state = 0;
 890:	4981                	li	s3,0
 892:	b51d                	j	6b8 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 894:	8bce                	mv	s7,s3
      state = 0;
 896:	4981                	li	s3,0
 898:	b505                	j	6b8 <vprintf+0x44>
 89a:	6906                	ld	s2,64(sp)
 89c:	79e2                	ld	s3,56(sp)
 89e:	7a42                	ld	s4,48(sp)
 8a0:	7aa2                	ld	s5,40(sp)
 8a2:	7b02                	ld	s6,32(sp)
 8a4:	6be2                	ld	s7,24(sp)
 8a6:	6c42                	ld	s8,16(sp)
    }
  }
}
 8a8:	60e6                	ld	ra,88(sp)
 8aa:	6446                	ld	s0,80(sp)
 8ac:	64a6                	ld	s1,72(sp)
 8ae:	6125                	addi	sp,sp,96
 8b0:	8082                	ret
      if(c0 == 'd'){
 8b2:	06400713          	li	a4,100
 8b6:	e4e78fe3          	beq	a5,a4,714 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 8ba:	f9478693          	addi	a3,a5,-108
 8be:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 8c2:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 8c4:	4701                	li	a4,0
      } else if(c0 == 'u'){
 8c6:	07500513          	li	a0,117
 8ca:	e8a78ce3          	beq	a5,a0,762 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 8ce:	f8b60513          	addi	a0,a2,-117
 8d2:	e119                	bnez	a0,8d8 <vprintf+0x264>
 8d4:	ea0693e3          	bnez	a3,77a <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 8d8:	f8b58513          	addi	a0,a1,-117
 8dc:	e119                	bnez	a0,8e2 <vprintf+0x26e>
 8de:	ea071be3          	bnez	a4,794 <vprintf+0x120>
      } else if(c0 == 'x'){
 8e2:	07800513          	li	a0,120
 8e6:	eca784e3          	beq	a5,a0,7ae <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 8ea:	f8860613          	addi	a2,a2,-120
 8ee:	e219                	bnez	a2,8f4 <vprintf+0x280>
 8f0:	ec069be3          	bnez	a3,7c6 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 8f4:	f8858593          	addi	a1,a1,-120
 8f8:	e199                	bnez	a1,8fe <vprintf+0x28a>
 8fa:	ee0713e3          	bnez	a4,7e0 <vprintf+0x16c>
      } else if(c0 == 'p'){
 8fe:	07000713          	li	a4,112
 902:	eee78ce3          	beq	a5,a4,7fa <vprintf+0x186>
      } else if(c0 == 'c'){
 906:	06300713          	li	a4,99
 90a:	f2e78ce3          	beq	a5,a4,842 <vprintf+0x1ce>
      } else if(c0 == 's'){
 90e:	07300713          	li	a4,115
 912:	f4e782e3          	beq	a5,a4,856 <vprintf+0x1e2>
      } else if(c0 == '%'){
 916:	02500713          	li	a4,37
 91a:	f6e787e3          	beq	a5,a4,888 <vprintf+0x214>
        putc(fd, '%');
 91e:	02500593          	li	a1,37
 922:	855a                	mv	a0,s6
 924:	c95ff0ef          	jal	5b8 <putc>
        putc(fd, c0);
 928:	85a6                	mv	a1,s1
 92a:	855a                	mv	a0,s6
 92c:	c8dff0ef          	jal	5b8 <putc>
      state = 0;
 930:	4981                	li	s3,0
 932:	b359                	j	6b8 <vprintf+0x44>

0000000000000934 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 934:	715d                	addi	sp,sp,-80
 936:	ec06                	sd	ra,24(sp)
 938:	e822                	sd	s0,16(sp)
 93a:	1000                	addi	s0,sp,32
 93c:	e010                	sd	a2,0(s0)
 93e:	e414                	sd	a3,8(s0)
 940:	e818                	sd	a4,16(s0)
 942:	ec1c                	sd	a5,24(s0)
 944:	03043023          	sd	a6,32(s0)
 948:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 94c:	8622                	mv	a2,s0
 94e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 952:	d23ff0ef          	jal	674 <vprintf>
}
 956:	60e2                	ld	ra,24(sp)
 958:	6442                	ld	s0,16(sp)
 95a:	6161                	addi	sp,sp,80
 95c:	8082                	ret

000000000000095e <printf>:

void
printf(const char *fmt, ...)
{
 95e:	711d                	addi	sp,sp,-96
 960:	ec06                	sd	ra,24(sp)
 962:	e822                	sd	s0,16(sp)
 964:	1000                	addi	s0,sp,32
 966:	e40c                	sd	a1,8(s0)
 968:	e810                	sd	a2,16(s0)
 96a:	ec14                	sd	a3,24(s0)
 96c:	f018                	sd	a4,32(s0)
 96e:	f41c                	sd	a5,40(s0)
 970:	03043823          	sd	a6,48(s0)
 974:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 978:	00840613          	addi	a2,s0,8
 97c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 980:	85aa                	mv	a1,a0
 982:	4505                	li	a0,1
 984:	cf1ff0ef          	jal	674 <vprintf>
}
 988:	60e2                	ld	ra,24(sp)
 98a:	6442                	ld	s0,16(sp)
 98c:	6125                	addi	sp,sp,96
 98e:	8082                	ret

0000000000000990 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 990:	1141                	addi	sp,sp,-16
 992:	e406                	sd	ra,8(sp)
 994:	e022                	sd	s0,0(sp)
 996:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 998:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 99c:	00001797          	auipc	a5,0x1
 9a0:	6647b783          	ld	a5,1636(a5) # 2000 <freep>
 9a4:	a039                	j	9b2 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9a6:	6398                	ld	a4,0(a5)
 9a8:	00e7e463          	bltu	a5,a4,9b0 <free+0x20>
 9ac:	00e6ea63          	bltu	a3,a4,9c0 <free+0x30>
{
 9b0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9b2:	fed7fae3          	bgeu	a5,a3,9a6 <free+0x16>
 9b6:	6398                	ld	a4,0(a5)
 9b8:	00e6e463          	bltu	a3,a4,9c0 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9bc:	fee7eae3          	bltu	a5,a4,9b0 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 9c0:	ff852583          	lw	a1,-8(a0)
 9c4:	6390                	ld	a2,0(a5)
 9c6:	02059813          	slli	a6,a1,0x20
 9ca:	01c85713          	srli	a4,a6,0x1c
 9ce:	9736                	add	a4,a4,a3
 9d0:	02e60563          	beq	a2,a4,9fa <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 9d4:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 9d8:	4790                	lw	a2,8(a5)
 9da:	02061593          	slli	a1,a2,0x20
 9de:	01c5d713          	srli	a4,a1,0x1c
 9e2:	973e                	add	a4,a4,a5
 9e4:	02e68263          	beq	a3,a4,a08 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 9e8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9ea:	00001717          	auipc	a4,0x1
 9ee:	60f73b23          	sd	a5,1558(a4) # 2000 <freep>
}
 9f2:	60a2                	ld	ra,8(sp)
 9f4:	6402                	ld	s0,0(sp)
 9f6:	0141                	addi	sp,sp,16
 9f8:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 9fa:	4618                	lw	a4,8(a2)
 9fc:	9f2d                	addw	a4,a4,a1
 9fe:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a02:	6398                	ld	a4,0(a5)
 a04:	6310                	ld	a2,0(a4)
 a06:	b7f9                	j	9d4 <free+0x44>
    p->s.size += bp->s.size;
 a08:	ff852703          	lw	a4,-8(a0)
 a0c:	9f31                	addw	a4,a4,a2
 a0e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a10:	ff053683          	ld	a3,-16(a0)
 a14:	bfd1                	j	9e8 <free+0x58>

0000000000000a16 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a16:	7139                	addi	sp,sp,-64
 a18:	fc06                	sd	ra,56(sp)
 a1a:	f822                	sd	s0,48(sp)
 a1c:	f04a                	sd	s2,32(sp)
 a1e:	ec4e                	sd	s3,24(sp)
 a20:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a22:	02051993          	slli	s3,a0,0x20
 a26:	0209d993          	srli	s3,s3,0x20
 a2a:	09bd                	addi	s3,s3,15
 a2c:	0049d993          	srli	s3,s3,0x4
 a30:	2985                	addiw	s3,s3,1
 a32:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 a34:	00001517          	auipc	a0,0x1
 a38:	5cc53503          	ld	a0,1484(a0) # 2000 <freep>
 a3c:	c905                	beqz	a0,a6c <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a3e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a40:	4798                	lw	a4,8(a5)
 a42:	09377663          	bgeu	a4,s3,ace <malloc+0xb8>
 a46:	f426                	sd	s1,40(sp)
 a48:	e852                	sd	s4,16(sp)
 a4a:	e456                	sd	s5,8(sp)
 a4c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a4e:	8a4e                	mv	s4,s3
 a50:	6705                	lui	a4,0x1
 a52:	00e9f363          	bgeu	s3,a4,a58 <malloc+0x42>
 a56:	6a05                	lui	s4,0x1
 a58:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a5c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a60:	00001497          	auipc	s1,0x1
 a64:	5a048493          	addi	s1,s1,1440 # 2000 <freep>
  if(p == SBRK_ERROR)
 a68:	5afd                	li	s5,-1
 a6a:	a83d                	j	aa8 <malloc+0x92>
 a6c:	f426                	sd	s1,40(sp)
 a6e:	e852                	sd	s4,16(sp)
 a70:	e456                	sd	s5,8(sp)
 a72:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a74:	00001797          	auipc	a5,0x1
 a78:	59c78793          	addi	a5,a5,1436 # 2010 <base>
 a7c:	00001717          	auipc	a4,0x1
 a80:	58f73223          	sd	a5,1412(a4) # 2000 <freep>
 a84:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a86:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a8a:	b7d1                	j	a4e <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a8c:	6398                	ld	a4,0(a5)
 a8e:	e118                	sd	a4,0(a0)
 a90:	a899                	j	ae6 <malloc+0xd0>
  hp->s.size = nu;
 a92:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a96:	0541                	addi	a0,a0,16
 a98:	ef9ff0ef          	jal	990 <free>
  return freep;
 a9c:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 a9e:	c125                	beqz	a0,afe <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aa0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 aa2:	4798                	lw	a4,8(a5)
 aa4:	03277163          	bgeu	a4,s2,ac6 <malloc+0xb0>
    if(p == freep)
 aa8:	6098                	ld	a4,0(s1)
 aaa:	853e                	mv	a0,a5
 aac:	fef71ae3          	bne	a4,a5,aa0 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 ab0:	8552                	mv	a0,s4
 ab2:	99dff0ef          	jal	44e <sbrk>
  if(p == SBRK_ERROR)
 ab6:	fd551ee3          	bne	a0,s5,a92 <malloc+0x7c>
        return 0;
 aba:	4501                	li	a0,0
 abc:	74a2                	ld	s1,40(sp)
 abe:	6a42                	ld	s4,16(sp)
 ac0:	6aa2                	ld	s5,8(sp)
 ac2:	6b02                	ld	s6,0(sp)
 ac4:	a03d                	j	af2 <malloc+0xdc>
 ac6:	74a2                	ld	s1,40(sp)
 ac8:	6a42                	ld	s4,16(sp)
 aca:	6aa2                	ld	s5,8(sp)
 acc:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 ace:	fae90fe3          	beq	s2,a4,a8c <malloc+0x76>
        p->s.size -= nunits;
 ad2:	4137073b          	subw	a4,a4,s3
 ad6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ad8:	02071693          	slli	a3,a4,0x20
 adc:	01c6d713          	srli	a4,a3,0x1c
 ae0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ae2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 ae6:	00001717          	auipc	a4,0x1
 aea:	50a73d23          	sd	a0,1306(a4) # 2000 <freep>
      return (void*)(p + 1);
 aee:	01078513          	addi	a0,a5,16
  }
}
 af2:	70e2                	ld	ra,56(sp)
 af4:	7442                	ld	s0,48(sp)
 af6:	7902                	ld	s2,32(sp)
 af8:	69e2                	ld	s3,24(sp)
 afa:	6121                	addi	sp,sp,64
 afc:	8082                	ret
 afe:	74a2                	ld	s1,40(sp)
 b00:	6a42                	ld	s4,16(sp)
 b02:	6aa2                	ld	s5,8(sp)
 b04:	6b02                	ld	s6,0(sp)
 b06:	b7f5                	j	af2 <malloc+0xdc>
