
user/_shmtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  int id = 1;
  int size = 4096;

  // Create shared memory
  int shmid = shmget(id, size);
   8:	6585                	lui	a1,0x1
   a:	4505                	li	a0,1
   c:	3d2000ef          	jal	3de <shmget>
  if(shmid < 0){
  10:	08054e63          	bltz	a0,ac <main+0xac>
  14:	e426                	sd	s1,8(sp)
  16:	e04a                	sd	s2,0(sp)
  18:	84aa                	mv	s1,a0
    printf("shmget failed\n");
    exit(1);
  }
  printf("shmget: created shared memory with id %d\n", shmid);
  1a:	85aa                	mv	a1,a0
  1c:	00001517          	auipc	a0,0x1
  20:	a3c50513          	addi	a0,a0,-1476 # a58 <malloc+0x116>
  24:	067000ef          	jal	88a <printf>

  // Attach shared memory
  char *addr = (char*)shmat(shmid);
  28:	8526                	mv	a0,s1
  2a:	3bc000ef          	jal	3e6 <shmat>
  2e:	892a                	mv	s2,a0
  if((uint64)addr == (uint64)-1){
  30:	57fd                	li	a5,-1
  32:	08f50863          	beq	a0,a5,c2 <main+0xc2>
    printf("shmat failed\n");
    exit(1);
  }
  printf("shmat: attached shared memory at address %p\n", addr);
  36:	85aa                	mv	a1,a0
  38:	00001517          	auipc	a0,0x1
  3c:	a6050513          	addi	a0,a0,-1440 # a98 <malloc+0x156>
  40:	04b000ef          	jal	88a <printf>

  // Write to shared memory
  addr[0] = 'H';
  44:	04800793          	li	a5,72
  48:	00f90023          	sb	a5,0(s2)
  addr[1] = 'i';
  4c:	06900793          	li	a5,105
  50:	00f900a3          	sb	a5,1(s2)
  addr[2] = '!';
  54:	02100793          	li	a5,33
  58:	00f90123          	sb	a5,2(s2)
  addr[3] = '\0';
  5c:	000901a3          	sb	zero,3(s2)
  printf("wrote to shared memory: %s\n", addr);
  60:	85ca                	mv	a1,s2
  62:	00001517          	auipc	a0,0x1
  66:	a6650513          	addi	a0,a0,-1434 # ac8 <malloc+0x186>
  6a:	021000ef          	jal	88a <printf>

  // Detach shared memory
  if(shmdt(shmid) < 0){
  6e:	8526                	mv	a0,s1
  70:	37e000ef          	jal	3ee <shmdt>
  74:	06054063          	bltz	a0,d4 <main+0xd4>
    printf("shmdt failed\n");
    exit(1);
  }
  printf("shmdt: detached shared memory\n");
  78:	00001517          	auipc	a0,0x1
  7c:	a8050513          	addi	a0,a0,-1408 # af8 <malloc+0x1b6>
  80:	00b000ef          	jal	88a <printf>

  // Delete shared memory
  if(shmctl(shmid) < 0){
  84:	8526                	mv	a0,s1
  86:	370000ef          	jal	3f6 <shmctl>
  8a:	04054e63          	bltz	a0,e6 <main+0xe6>
    printf("shmctl failed\n");
    exit(1);
  }
  printf("shmctl: deleted shared memory\n");
  8e:	00001517          	auipc	a0,0x1
  92:	a9a50513          	addi	a0,a0,-1382 # b28 <malloc+0x1e6>
  96:	7f4000ef          	jal	88a <printf>

  printf("Shared memory test complete!\n");
  9a:	00001517          	auipc	a0,0x1
  9e:	aae50513          	addi	a0,a0,-1362 # b48 <malloc+0x206>
  a2:	7e8000ef          	jal	88a <printf>
  exit(0);
  a6:	4501                	li	a0,0
  a8:	306000ef          	jal	3ae <exit>
  ac:	e426                	sd	s1,8(sp)
  ae:	e04a                	sd	s2,0(sp)
    printf("shmget failed\n");
  b0:	00001517          	auipc	a0,0x1
  b4:	99050513          	addi	a0,a0,-1648 # a40 <malloc+0xfe>
  b8:	7d2000ef          	jal	88a <printf>
    exit(1);
  bc:	4505                	li	a0,1
  be:	2f0000ef          	jal	3ae <exit>
    printf("shmat failed\n");
  c2:	00001517          	auipc	a0,0x1
  c6:	9c650513          	addi	a0,a0,-1594 # a88 <malloc+0x146>
  ca:	7c0000ef          	jal	88a <printf>
    exit(1);
  ce:	4505                	li	a0,1
  d0:	2de000ef          	jal	3ae <exit>
    printf("shmdt failed\n");
  d4:	00001517          	auipc	a0,0x1
  d8:	a1450513          	addi	a0,a0,-1516 # ae8 <malloc+0x1a6>
  dc:	7ae000ef          	jal	88a <printf>
    exit(1);
  e0:	4505                	li	a0,1
  e2:	2cc000ef          	jal	3ae <exit>
    printf("shmctl failed\n");
  e6:	00001517          	auipc	a0,0x1
  ea:	a3250513          	addi	a0,a0,-1486 # b18 <malloc+0x1d6>
  ee:	79c000ef          	jal	88a <printf>
    exit(1);
  f2:	4505                	li	a0,1
  f4:	2ba000ef          	jal	3ae <exit>

00000000000000f8 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e406                	sd	ra,8(sp)
  fc:	e022                	sd	s0,0(sp)
  fe:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 100:	f01ff0ef          	jal	0 <main>
  exit(r);
 104:	2aa000ef          	jal	3ae <exit>

0000000000000108 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 108:	1141                	addi	sp,sp,-16
 10a:	e406                	sd	ra,8(sp)
 10c:	e022                	sd	s0,0(sp)
 10e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 110:	87aa                	mv	a5,a0
 112:	0585                	addi	a1,a1,1 # 1001 <freep+0x1>
 114:	0785                	addi	a5,a5,1
 116:	fff5c703          	lbu	a4,-1(a1)
 11a:	fee78fa3          	sb	a4,-1(a5)
 11e:	fb75                	bnez	a4,112 <strcpy+0xa>
    ;
  return os;
}
 120:	60a2                	ld	ra,8(sp)
 122:	6402                	ld	s0,0(sp)
 124:	0141                	addi	sp,sp,16
 126:	8082                	ret

0000000000000128 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 128:	1141                	addi	sp,sp,-16
 12a:	e406                	sd	ra,8(sp)
 12c:	e022                	sd	s0,0(sp)
 12e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 130:	00054783          	lbu	a5,0(a0)
 134:	cb91                	beqz	a5,148 <strcmp+0x20>
 136:	0005c703          	lbu	a4,0(a1)
 13a:	00f71763          	bne	a4,a5,148 <strcmp+0x20>
    p++, q++;
 13e:	0505                	addi	a0,a0,1
 140:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 142:	00054783          	lbu	a5,0(a0)
 146:	fbe5                	bnez	a5,136 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 148:	0005c503          	lbu	a0,0(a1)
}
 14c:	40a7853b          	subw	a0,a5,a0
 150:	60a2                	ld	ra,8(sp)
 152:	6402                	ld	s0,0(sp)
 154:	0141                	addi	sp,sp,16
 156:	8082                	ret

0000000000000158 <strlen>:

uint
strlen(const char *s)
{
 158:	1141                	addi	sp,sp,-16
 15a:	e406                	sd	ra,8(sp)
 15c:	e022                	sd	s0,0(sp)
 15e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 160:	00054783          	lbu	a5,0(a0)
 164:	cf91                	beqz	a5,180 <strlen+0x28>
 166:	00150793          	addi	a5,a0,1
 16a:	86be                	mv	a3,a5
 16c:	0785                	addi	a5,a5,1
 16e:	fff7c703          	lbu	a4,-1(a5)
 172:	ff65                	bnez	a4,16a <strlen+0x12>
 174:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 178:	60a2                	ld	ra,8(sp)
 17a:	6402                	ld	s0,0(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret
  for(n = 0; s[n]; n++)
 180:	4501                	li	a0,0
 182:	bfdd                	j	178 <strlen+0x20>

0000000000000184 <memset>:

void*
memset(void *dst, int c, uint n)
{
 184:	1141                	addi	sp,sp,-16
 186:	e406                	sd	ra,8(sp)
 188:	e022                	sd	s0,0(sp)
 18a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 18c:	ca19                	beqz	a2,1a2 <memset+0x1e>
 18e:	87aa                	mv	a5,a0
 190:	1602                	slli	a2,a2,0x20
 192:	9201                	srli	a2,a2,0x20
 194:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 198:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 19c:	0785                	addi	a5,a5,1
 19e:	fee79de3          	bne	a5,a4,198 <memset+0x14>
  }
  return dst;
}
 1a2:	60a2                	ld	ra,8(sp)
 1a4:	6402                	ld	s0,0(sp)
 1a6:	0141                	addi	sp,sp,16
 1a8:	8082                	ret

00000000000001aa <strchr>:

char*
strchr(const char *s, char c)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e406                	sd	ra,8(sp)
 1ae:	e022                	sd	s0,0(sp)
 1b0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1b2:	00054783          	lbu	a5,0(a0)
 1b6:	cf81                	beqz	a5,1ce <strchr+0x24>
    if(*s == c)
 1b8:	00f58763          	beq	a1,a5,1c6 <strchr+0x1c>
  for(; *s; s++)
 1bc:	0505                	addi	a0,a0,1
 1be:	00054783          	lbu	a5,0(a0)
 1c2:	fbfd                	bnez	a5,1b8 <strchr+0xe>
      return (char*)s;
  return 0;
 1c4:	4501                	li	a0,0
}
 1c6:	60a2                	ld	ra,8(sp)
 1c8:	6402                	ld	s0,0(sp)
 1ca:	0141                	addi	sp,sp,16
 1cc:	8082                	ret
  return 0;
 1ce:	4501                	li	a0,0
 1d0:	bfdd                	j	1c6 <strchr+0x1c>

00000000000001d2 <gets>:

char*
gets(char *buf, int max)
{
 1d2:	711d                	addi	sp,sp,-96
 1d4:	ec86                	sd	ra,88(sp)
 1d6:	e8a2                	sd	s0,80(sp)
 1d8:	e4a6                	sd	s1,72(sp)
 1da:	e0ca                	sd	s2,64(sp)
 1dc:	fc4e                	sd	s3,56(sp)
 1de:	f852                	sd	s4,48(sp)
 1e0:	f456                	sd	s5,40(sp)
 1e2:	f05a                	sd	s6,32(sp)
 1e4:	ec5e                	sd	s7,24(sp)
 1e6:	e862                	sd	s8,16(sp)
 1e8:	1080                	addi	s0,sp,96
 1ea:	8baa                	mv	s7,a0
 1ec:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ee:	892a                	mv	s2,a0
 1f0:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1f2:	faf40b13          	addi	s6,s0,-81
 1f6:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1f8:	8c26                	mv	s8,s1
 1fa:	0014899b          	addiw	s3,s1,1
 1fe:	84ce                	mv	s1,s3
 200:	0349d463          	bge	s3,s4,228 <gets+0x56>
    cc = read(0, &c, 1);
 204:	8656                	mv	a2,s5
 206:	85da                	mv	a1,s6
 208:	4501                	li	a0,0
 20a:	1bc000ef          	jal	3c6 <read>
    if(cc < 1)
 20e:	00a05d63          	blez	a0,228 <gets+0x56>
      break;
    buf[i++] = c;
 212:	faf44783          	lbu	a5,-81(s0)
 216:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 21a:	0905                	addi	s2,s2,1
 21c:	ff678713          	addi	a4,a5,-10
 220:	c319                	beqz	a4,226 <gets+0x54>
 222:	17cd                	addi	a5,a5,-13
 224:	fbf1                	bnez	a5,1f8 <gets+0x26>
    buf[i++] = c;
 226:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 228:	9c5e                	add	s8,s8,s7
 22a:	000c0023          	sb	zero,0(s8)
  return buf;
}
 22e:	855e                	mv	a0,s7
 230:	60e6                	ld	ra,88(sp)
 232:	6446                	ld	s0,80(sp)
 234:	64a6                	ld	s1,72(sp)
 236:	6906                	ld	s2,64(sp)
 238:	79e2                	ld	s3,56(sp)
 23a:	7a42                	ld	s4,48(sp)
 23c:	7aa2                	ld	s5,40(sp)
 23e:	7b02                	ld	s6,32(sp)
 240:	6be2                	ld	s7,24(sp)
 242:	6c42                	ld	s8,16(sp)
 244:	6125                	addi	sp,sp,96
 246:	8082                	ret

0000000000000248 <stat>:

int
stat(const char *n, struct stat *st)
{
 248:	1101                	addi	sp,sp,-32
 24a:	ec06                	sd	ra,24(sp)
 24c:	e822                	sd	s0,16(sp)
 24e:	e04a                	sd	s2,0(sp)
 250:	1000                	addi	s0,sp,32
 252:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 254:	4581                	li	a1,0
 256:	224000ef          	jal	47a <open>
  if(fd < 0)
 25a:	02054263          	bltz	a0,27e <stat+0x36>
 25e:	e426                	sd	s1,8(sp)
 260:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 262:	85ca                	mv	a1,s2
 264:	22e000ef          	jal	492 <fstat>
 268:	892a                	mv	s2,a0
  close(fd);
 26a:	8526                	mv	a0,s1
 26c:	16a000ef          	jal	3d6 <close>
  return r;
 270:	64a2                	ld	s1,8(sp)
}
 272:	854a                	mv	a0,s2
 274:	60e2                	ld	ra,24(sp)
 276:	6442                	ld	s0,16(sp)
 278:	6902                	ld	s2,0(sp)
 27a:	6105                	addi	sp,sp,32
 27c:	8082                	ret
    return -1;
 27e:	57fd                	li	a5,-1
 280:	893e                	mv	s2,a5
 282:	bfc5                	j	272 <stat+0x2a>

0000000000000284 <atoi>:

int
atoi(const char *s)
{
 284:	1141                	addi	sp,sp,-16
 286:	e406                	sd	ra,8(sp)
 288:	e022                	sd	s0,0(sp)
 28a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 28c:	00054683          	lbu	a3,0(a0)
 290:	fd06879b          	addiw	a5,a3,-48
 294:	0ff7f793          	zext.b	a5,a5
 298:	4625                	li	a2,9
 29a:	02f66963          	bltu	a2,a5,2cc <atoi+0x48>
 29e:	872a                	mv	a4,a0
  n = 0;
 2a0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2a2:	0705                	addi	a4,a4,1
 2a4:	0025179b          	slliw	a5,a0,0x2
 2a8:	9fa9                	addw	a5,a5,a0
 2aa:	0017979b          	slliw	a5,a5,0x1
 2ae:	9fb5                	addw	a5,a5,a3
 2b0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2b4:	00074683          	lbu	a3,0(a4)
 2b8:	fd06879b          	addiw	a5,a3,-48
 2bc:	0ff7f793          	zext.b	a5,a5
 2c0:	fef671e3          	bgeu	a2,a5,2a2 <atoi+0x1e>
  return n;
}
 2c4:	60a2                	ld	ra,8(sp)
 2c6:	6402                	ld	s0,0(sp)
 2c8:	0141                	addi	sp,sp,16
 2ca:	8082                	ret
  n = 0;
 2cc:	4501                	li	a0,0
 2ce:	bfdd                	j	2c4 <atoi+0x40>

00000000000002d0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2d0:	1141                	addi	sp,sp,-16
 2d2:	e406                	sd	ra,8(sp)
 2d4:	e022                	sd	s0,0(sp)
 2d6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2d8:	02b57563          	bgeu	a0,a1,302 <memmove+0x32>
    while(n-- > 0)
 2dc:	00c05f63          	blez	a2,2fa <memmove+0x2a>
 2e0:	1602                	slli	a2,a2,0x20
 2e2:	9201                	srli	a2,a2,0x20
 2e4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2e8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ea:	0585                	addi	a1,a1,1
 2ec:	0705                	addi	a4,a4,1
 2ee:	fff5c683          	lbu	a3,-1(a1)
 2f2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2f6:	fee79ae3          	bne	a5,a4,2ea <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2fa:	60a2                	ld	ra,8(sp)
 2fc:	6402                	ld	s0,0(sp)
 2fe:	0141                	addi	sp,sp,16
 300:	8082                	ret
    while(n-- > 0)
 302:	fec05ce3          	blez	a2,2fa <memmove+0x2a>
    dst += n;
 306:	00c50733          	add	a4,a0,a2
    src += n;
 30a:	95b2                	add	a1,a1,a2
 30c:	fff6079b          	addiw	a5,a2,-1
 310:	1782                	slli	a5,a5,0x20
 312:	9381                	srli	a5,a5,0x20
 314:	fff7c793          	not	a5,a5
 318:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 31a:	15fd                	addi	a1,a1,-1
 31c:	177d                	addi	a4,a4,-1
 31e:	0005c683          	lbu	a3,0(a1)
 322:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 326:	fef71ae3          	bne	a4,a5,31a <memmove+0x4a>
 32a:	bfc1                	j	2fa <memmove+0x2a>

000000000000032c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 32c:	1141                	addi	sp,sp,-16
 32e:	e406                	sd	ra,8(sp)
 330:	e022                	sd	s0,0(sp)
 332:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 334:	c61d                	beqz	a2,362 <memcmp+0x36>
 336:	1602                	slli	a2,a2,0x20
 338:	9201                	srli	a2,a2,0x20
 33a:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 33e:	00054783          	lbu	a5,0(a0)
 342:	0005c703          	lbu	a4,0(a1)
 346:	00e79863          	bne	a5,a4,356 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 34a:	0505                	addi	a0,a0,1
    p2++;
 34c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 34e:	fed518e3          	bne	a0,a3,33e <memcmp+0x12>
  }
  return 0;
 352:	4501                	li	a0,0
 354:	a019                	j	35a <memcmp+0x2e>
      return *p1 - *p2;
 356:	40e7853b          	subw	a0,a5,a4
}
 35a:	60a2                	ld	ra,8(sp)
 35c:	6402                	ld	s0,0(sp)
 35e:	0141                	addi	sp,sp,16
 360:	8082                	ret
  return 0;
 362:	4501                	li	a0,0
 364:	bfdd                	j	35a <memcmp+0x2e>

0000000000000366 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 366:	1141                	addi	sp,sp,-16
 368:	e406                	sd	ra,8(sp)
 36a:	e022                	sd	s0,0(sp)
 36c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 36e:	f63ff0ef          	jal	2d0 <memmove>
}
 372:	60a2                	ld	ra,8(sp)
 374:	6402                	ld	s0,0(sp)
 376:	0141                	addi	sp,sp,16
 378:	8082                	ret

000000000000037a <sbrk>:

char *
sbrk(int n) {
 37a:	1141                	addi	sp,sp,-16
 37c:	e406                	sd	ra,8(sp)
 37e:	e022                	sd	s0,0(sp)
 380:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 382:	4585                	li	a1,1
 384:	13e000ef          	jal	4c2 <sys_sbrk>
}
 388:	60a2                	ld	ra,8(sp)
 38a:	6402                	ld	s0,0(sp)
 38c:	0141                	addi	sp,sp,16
 38e:	8082                	ret

0000000000000390 <sbrklazy>:

char *
sbrklazy(int n) {
 390:	1141                	addi	sp,sp,-16
 392:	e406                	sd	ra,8(sp)
 394:	e022                	sd	s0,0(sp)
 396:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 398:	4589                	li	a1,2
 39a:	128000ef          	jal	4c2 <sys_sbrk>
}
 39e:	60a2                	ld	ra,8(sp)
 3a0:	6402                	ld	s0,0(sp)
 3a2:	0141                	addi	sp,sp,16
 3a4:	8082                	ret

00000000000003a6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3a6:	4885                	li	a7,1
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ae:	4889                	li	a7,2
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3b6:	488d                	li	a7,3
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3be:	4891                	li	a7,4
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <read>:
.global read
read:
 li a7, SYS_read
 3c6:	4895                	li	a7,5
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <write>:
.global write
write:
 li a7, SYS_write
 3ce:	48c1                	li	a7,16
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <close>:
.global close
close:
 li a7, SYS_close
 3d6:	48d5                	li	a7,21
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 3de:	48d9                	li	a7,22
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <shmat>:
.global shmat
shmat:
 li a7, SYS_shmat
 3e6:	48dd                	li	a7,23
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 3ee:	48e1                	li	a7,24
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 3f6:	48e5                	li	a7,25
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <lockinit>:
.global lockinit
lockinit:
 li a7, SYS_lockinit
 3fe:	48e9                	li	a7,26
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <lockacquire>:
.global lockacquire
lockacquire:
 li a7, SYS_lockacquire
 406:	48ed                	li	a7,27
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <lockrelease>:
.global lockrelease
lockrelease:
 li a7, SYS_lockrelease
 40e:	48f1                	li	a7,28
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <locktry>:
.global locktry
locktry:
 li a7, SYS_locktry
 416:	48f5                	li	a7,29
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <lockcheck>:
.global lockcheck
lockcheck:
 li a7, SYS_lockcheck
 41e:	48f9                	li	a7,30
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <sendmsg>:
.global sendmsg
sendmsg:
 li a7, SYS_sendmsg
 426:	48fd                	li	a7,31
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <recvmsg>:
.global recvmsg
recvmsg:
 li a7, SYS_recvmsg
 42e:	02000893          	li	a7,32
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <broadcast>:
.global broadcast
broadcast:
 li a7, SYS_broadcast
 438:	02100893          	li	a7,33
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <getprocsinfo>:
.global getprocsinfo
getprocsinfo:
 li a7, SYS_getprocsinfo
 442:	02200893          	li	a7,34
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 44c:	02300893          	li	a7,35
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <sleep2>:
.global sleep2
sleep2:
 li a7, SYS_sleep2
 456:	02400893          	li	a7,36
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <signal>:
.global signal
signal:
 li a7, SYS_signal
 460:	02500893          	li	a7,37
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <kill>:
.global kill
kill:
 li a7, SYS_kill
 46a:	4899                	li	a7,6
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <exec>:
.global exec
exec:
 li a7, SYS_exec
 472:	489d                	li	a7,7
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <open>:
.global open
open:
 li a7, SYS_open
 47a:	48bd                	li	a7,15
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 482:	48c5                	li	a7,17
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 48a:	48c9                	li	a7,18
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 492:	48a1                	li	a7,8
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <link>:
.global link
link:
 li a7, SYS_link
 49a:	48cd                	li	a7,19
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4a2:	48d1                	li	a7,20
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4aa:	48a5                	li	a7,9
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4b2:	48a9                	li	a7,10
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4ba:	48ad                	li	a7,11
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4c2:	48b1                	li	a7,12
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <pause>:
.global pause
pause:
 li a7, SYS_pause
 4ca:	48b5                	li	a7,13
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4d2:	48b9                	li	a7,14
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <setchildlimit>:
.global setchildlimit
setchildlimit:
 li a7, SYS_setchildlimit
 4da:	02600893          	li	a7,38
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4e4:	1101                	addi	sp,sp,-32
 4e6:	ec06                	sd	ra,24(sp)
 4e8:	e822                	sd	s0,16(sp)
 4ea:	1000                	addi	s0,sp,32
 4ec:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4f0:	4605                	li	a2,1
 4f2:	fef40593          	addi	a1,s0,-17
 4f6:	ed9ff0ef          	jal	3ce <write>
}
 4fa:	60e2                	ld	ra,24(sp)
 4fc:	6442                	ld	s0,16(sp)
 4fe:	6105                	addi	sp,sp,32
 500:	8082                	ret

0000000000000502 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 502:	715d                	addi	sp,sp,-80
 504:	e486                	sd	ra,72(sp)
 506:	e0a2                	sd	s0,64(sp)
 508:	f84a                	sd	s2,48(sp)
 50a:	f44e                	sd	s3,40(sp)
 50c:	0880                	addi	s0,sp,80
 50e:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 510:	c6d1                	beqz	a3,59c <printint+0x9a>
 512:	0805d563          	bgez	a1,59c <printint+0x9a>
    neg = 1;
    x = -xx;
 516:	40b005b3          	neg	a1,a1
    neg = 1;
 51a:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 51c:	fb840993          	addi	s3,s0,-72
  neg = 0;
 520:	86ce                	mv	a3,s3
  i = 0;
 522:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 524:	00000817          	auipc	a6,0x0
 528:	64c80813          	addi	a6,a6,1612 # b70 <digits>
 52c:	88ba                	mv	a7,a4
 52e:	0017051b          	addiw	a0,a4,1
 532:	872a                	mv	a4,a0
 534:	02c5f7b3          	remu	a5,a1,a2
 538:	97c2                	add	a5,a5,a6
 53a:	0007c783          	lbu	a5,0(a5)
 53e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 542:	87ae                	mv	a5,a1
 544:	02c5d5b3          	divu	a1,a1,a2
 548:	0685                	addi	a3,a3,1
 54a:	fec7f1e3          	bgeu	a5,a2,52c <printint+0x2a>
  if(neg)
 54e:	00030c63          	beqz	t1,566 <printint+0x64>
    buf[i++] = '-';
 552:	fd050793          	addi	a5,a0,-48
 556:	00878533          	add	a0,a5,s0
 55a:	02d00793          	li	a5,45
 55e:	fef50423          	sb	a5,-24(a0)
 562:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 566:	02e05563          	blez	a4,590 <printint+0x8e>
 56a:	fc26                	sd	s1,56(sp)
 56c:	377d                	addiw	a4,a4,-1
 56e:	00e984b3          	add	s1,s3,a4
 572:	19fd                	addi	s3,s3,-1
 574:	99ba                	add	s3,s3,a4
 576:	1702                	slli	a4,a4,0x20
 578:	9301                	srli	a4,a4,0x20
 57a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 57e:	0004c583          	lbu	a1,0(s1)
 582:	854a                	mv	a0,s2
 584:	f61ff0ef          	jal	4e4 <putc>
  while(--i >= 0)
 588:	14fd                	addi	s1,s1,-1
 58a:	ff349ae3          	bne	s1,s3,57e <printint+0x7c>
 58e:	74e2                	ld	s1,56(sp)
}
 590:	60a6                	ld	ra,72(sp)
 592:	6406                	ld	s0,64(sp)
 594:	7942                	ld	s2,48(sp)
 596:	79a2                	ld	s3,40(sp)
 598:	6161                	addi	sp,sp,80
 59a:	8082                	ret
  neg = 0;
 59c:	4301                	li	t1,0
 59e:	bfbd                	j	51c <printint+0x1a>

00000000000005a0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5a0:	711d                	addi	sp,sp,-96
 5a2:	ec86                	sd	ra,88(sp)
 5a4:	e8a2                	sd	s0,80(sp)
 5a6:	e4a6                	sd	s1,72(sp)
 5a8:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5aa:	0005c483          	lbu	s1,0(a1)
 5ae:	22048363          	beqz	s1,7d4 <vprintf+0x234>
 5b2:	e0ca                	sd	s2,64(sp)
 5b4:	fc4e                	sd	s3,56(sp)
 5b6:	f852                	sd	s4,48(sp)
 5b8:	f456                	sd	s5,40(sp)
 5ba:	f05a                	sd	s6,32(sp)
 5bc:	ec5e                	sd	s7,24(sp)
 5be:	e862                	sd	s8,16(sp)
 5c0:	8b2a                	mv	s6,a0
 5c2:	8a2e                	mv	s4,a1
 5c4:	8bb2                	mv	s7,a2
  state = 0;
 5c6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5c8:	4901                	li	s2,0
 5ca:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5cc:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5d0:	06400c13          	li	s8,100
 5d4:	a00d                	j	5f6 <vprintf+0x56>
        putc(fd, c0);
 5d6:	85a6                	mv	a1,s1
 5d8:	855a                	mv	a0,s6
 5da:	f0bff0ef          	jal	4e4 <putc>
 5de:	a019                	j	5e4 <vprintf+0x44>
    } else if(state == '%'){
 5e0:	03598363          	beq	s3,s5,606 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 5e4:	0019079b          	addiw	a5,s2,1
 5e8:	893e                	mv	s2,a5
 5ea:	873e                	mv	a4,a5
 5ec:	97d2                	add	a5,a5,s4
 5ee:	0007c483          	lbu	s1,0(a5)
 5f2:	1c048a63          	beqz	s1,7c6 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 5f6:	0004879b          	sext.w	a5,s1
    if(state == 0){
 5fa:	fe0993e3          	bnez	s3,5e0 <vprintf+0x40>
      if(c0 == '%'){
 5fe:	fd579ce3          	bne	a5,s5,5d6 <vprintf+0x36>
        state = '%';
 602:	89be                	mv	s3,a5
 604:	b7c5                	j	5e4 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 606:	00ea06b3          	add	a3,s4,a4
 60a:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 60e:	1c060863          	beqz	a2,7de <vprintf+0x23e>
      if(c0 == 'd'){
 612:	03878763          	beq	a5,s8,640 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 616:	f9478693          	addi	a3,a5,-108
 61a:	0016b693          	seqz	a3,a3
 61e:	f9c60593          	addi	a1,a2,-100
 622:	e99d                	bnez	a1,658 <vprintf+0xb8>
 624:	ca95                	beqz	a3,658 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 626:	008b8493          	addi	s1,s7,8
 62a:	4685                	li	a3,1
 62c:	4629                	li	a2,10
 62e:	000bb583          	ld	a1,0(s7)
 632:	855a                	mv	a0,s6
 634:	ecfff0ef          	jal	502 <printint>
        i += 1;
 638:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 63a:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 63c:	4981                	li	s3,0
 63e:	b75d                	j	5e4 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 640:	008b8493          	addi	s1,s7,8
 644:	4685                	li	a3,1
 646:	4629                	li	a2,10
 648:	000ba583          	lw	a1,0(s7)
 64c:	855a                	mv	a0,s6
 64e:	eb5ff0ef          	jal	502 <printint>
 652:	8ba6                	mv	s7,s1
      state = 0;
 654:	4981                	li	s3,0
 656:	b779                	j	5e4 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 658:	9752                	add	a4,a4,s4
 65a:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 65e:	f9460713          	addi	a4,a2,-108
 662:	00173713          	seqz	a4,a4
 666:	8f75                	and	a4,a4,a3
 668:	f9c58513          	addi	a0,a1,-100
 66c:	18051363          	bnez	a0,7f2 <vprintf+0x252>
 670:	18070163          	beqz	a4,7f2 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 674:	008b8493          	addi	s1,s7,8
 678:	4685                	li	a3,1
 67a:	4629                	li	a2,10
 67c:	000bb583          	ld	a1,0(s7)
 680:	855a                	mv	a0,s6
 682:	e81ff0ef          	jal	502 <printint>
        i += 2;
 686:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 688:	8ba6                	mv	s7,s1
      state = 0;
 68a:	4981                	li	s3,0
        i += 2;
 68c:	bfa1                	j	5e4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 68e:	008b8493          	addi	s1,s7,8
 692:	4681                	li	a3,0
 694:	4629                	li	a2,10
 696:	000be583          	lwu	a1,0(s7)
 69a:	855a                	mv	a0,s6
 69c:	e67ff0ef          	jal	502 <printint>
 6a0:	8ba6                	mv	s7,s1
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	b781                	j	5e4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a6:	008b8493          	addi	s1,s7,8
 6aa:	4681                	li	a3,0
 6ac:	4629                	li	a2,10
 6ae:	000bb583          	ld	a1,0(s7)
 6b2:	855a                	mv	a0,s6
 6b4:	e4fff0ef          	jal	502 <printint>
        i += 1;
 6b8:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ba:	8ba6                	mv	s7,s1
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	b71d                	j	5e4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c0:	008b8493          	addi	s1,s7,8
 6c4:	4681                	li	a3,0
 6c6:	4629                	li	a2,10
 6c8:	000bb583          	ld	a1,0(s7)
 6cc:	855a                	mv	a0,s6
 6ce:	e35ff0ef          	jal	502 <printint>
        i += 2;
 6d2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d4:	8ba6                	mv	s7,s1
      state = 0;
 6d6:	4981                	li	s3,0
        i += 2;
 6d8:	b731                	j	5e4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6da:	008b8493          	addi	s1,s7,8
 6de:	4681                	li	a3,0
 6e0:	4641                	li	a2,16
 6e2:	000be583          	lwu	a1,0(s7)
 6e6:	855a                	mv	a0,s6
 6e8:	e1bff0ef          	jal	502 <printint>
 6ec:	8ba6                	mv	s7,s1
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	bdd5                	j	5e4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f2:	008b8493          	addi	s1,s7,8
 6f6:	4681                	li	a3,0
 6f8:	4641                	li	a2,16
 6fa:	000bb583          	ld	a1,0(s7)
 6fe:	855a                	mv	a0,s6
 700:	e03ff0ef          	jal	502 <printint>
        i += 1;
 704:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 706:	8ba6                	mv	s7,s1
      state = 0;
 708:	4981                	li	s3,0
 70a:	bde9                	j	5e4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 70c:	008b8493          	addi	s1,s7,8
 710:	4681                	li	a3,0
 712:	4641                	li	a2,16
 714:	000bb583          	ld	a1,0(s7)
 718:	855a                	mv	a0,s6
 71a:	de9ff0ef          	jal	502 <printint>
        i += 2;
 71e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 720:	8ba6                	mv	s7,s1
      state = 0;
 722:	4981                	li	s3,0
        i += 2;
 724:	b5c1                	j	5e4 <vprintf+0x44>
 726:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 728:	008b8793          	addi	a5,s7,8
 72c:	8cbe                	mv	s9,a5
 72e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 732:	03000593          	li	a1,48
 736:	855a                	mv	a0,s6
 738:	dadff0ef          	jal	4e4 <putc>
  putc(fd, 'x');
 73c:	07800593          	li	a1,120
 740:	855a                	mv	a0,s6
 742:	da3ff0ef          	jal	4e4 <putc>
 746:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 748:	00000b97          	auipc	s7,0x0
 74c:	428b8b93          	addi	s7,s7,1064 # b70 <digits>
 750:	03c9d793          	srli	a5,s3,0x3c
 754:	97de                	add	a5,a5,s7
 756:	0007c583          	lbu	a1,0(a5)
 75a:	855a                	mv	a0,s6
 75c:	d89ff0ef          	jal	4e4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 760:	0992                	slli	s3,s3,0x4
 762:	34fd                	addiw	s1,s1,-1
 764:	f4f5                	bnez	s1,750 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 766:	8be6                	mv	s7,s9
      state = 0;
 768:	4981                	li	s3,0
 76a:	6ca2                	ld	s9,8(sp)
 76c:	bda5                	j	5e4 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 76e:	008b8493          	addi	s1,s7,8
 772:	000bc583          	lbu	a1,0(s7)
 776:	855a                	mv	a0,s6
 778:	d6dff0ef          	jal	4e4 <putc>
 77c:	8ba6                	mv	s7,s1
      state = 0;
 77e:	4981                	li	s3,0
 780:	b595                	j	5e4 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 782:	008b8993          	addi	s3,s7,8
 786:	000bb483          	ld	s1,0(s7)
 78a:	cc91                	beqz	s1,7a6 <vprintf+0x206>
        for(; *s; s++)
 78c:	0004c583          	lbu	a1,0(s1)
 790:	c985                	beqz	a1,7c0 <vprintf+0x220>
          putc(fd, *s);
 792:	855a                	mv	a0,s6
 794:	d51ff0ef          	jal	4e4 <putc>
        for(; *s; s++)
 798:	0485                	addi	s1,s1,1
 79a:	0004c583          	lbu	a1,0(s1)
 79e:	f9f5                	bnez	a1,792 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 7a0:	8bce                	mv	s7,s3
      state = 0;
 7a2:	4981                	li	s3,0
 7a4:	b581                	j	5e4 <vprintf+0x44>
          s = "(null)";
 7a6:	00000497          	auipc	s1,0x0
 7aa:	3c248493          	addi	s1,s1,962 # b68 <malloc+0x226>
        for(; *s; s++)
 7ae:	02800593          	li	a1,40
 7b2:	b7c5                	j	792 <vprintf+0x1f2>
        putc(fd, '%');
 7b4:	85be                	mv	a1,a5
 7b6:	855a                	mv	a0,s6
 7b8:	d2dff0ef          	jal	4e4 <putc>
      state = 0;
 7bc:	4981                	li	s3,0
 7be:	b51d                	j	5e4 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 7c0:	8bce                	mv	s7,s3
      state = 0;
 7c2:	4981                	li	s3,0
 7c4:	b505                	j	5e4 <vprintf+0x44>
 7c6:	6906                	ld	s2,64(sp)
 7c8:	79e2                	ld	s3,56(sp)
 7ca:	7a42                	ld	s4,48(sp)
 7cc:	7aa2                	ld	s5,40(sp)
 7ce:	7b02                	ld	s6,32(sp)
 7d0:	6be2                	ld	s7,24(sp)
 7d2:	6c42                	ld	s8,16(sp)
    }
  }
}
 7d4:	60e6                	ld	ra,88(sp)
 7d6:	6446                	ld	s0,80(sp)
 7d8:	64a6                	ld	s1,72(sp)
 7da:	6125                	addi	sp,sp,96
 7dc:	8082                	ret
      if(c0 == 'd'){
 7de:	06400713          	li	a4,100
 7e2:	e4e78fe3          	beq	a5,a4,640 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 7e6:	f9478693          	addi	a3,a5,-108
 7ea:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 7ee:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7f0:	4701                	li	a4,0
      } else if(c0 == 'u'){
 7f2:	07500513          	li	a0,117
 7f6:	e8a78ce3          	beq	a5,a0,68e <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 7fa:	f8b60513          	addi	a0,a2,-117
 7fe:	e119                	bnez	a0,804 <vprintf+0x264>
 800:	ea0693e3          	bnez	a3,6a6 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 804:	f8b58513          	addi	a0,a1,-117
 808:	e119                	bnez	a0,80e <vprintf+0x26e>
 80a:	ea071be3          	bnez	a4,6c0 <vprintf+0x120>
      } else if(c0 == 'x'){
 80e:	07800513          	li	a0,120
 812:	eca784e3          	beq	a5,a0,6da <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 816:	f8860613          	addi	a2,a2,-120
 81a:	e219                	bnez	a2,820 <vprintf+0x280>
 81c:	ec069be3          	bnez	a3,6f2 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 820:	f8858593          	addi	a1,a1,-120
 824:	e199                	bnez	a1,82a <vprintf+0x28a>
 826:	ee0713e3          	bnez	a4,70c <vprintf+0x16c>
      } else if(c0 == 'p'){
 82a:	07000713          	li	a4,112
 82e:	eee78ce3          	beq	a5,a4,726 <vprintf+0x186>
      } else if(c0 == 'c'){
 832:	06300713          	li	a4,99
 836:	f2e78ce3          	beq	a5,a4,76e <vprintf+0x1ce>
      } else if(c0 == 's'){
 83a:	07300713          	li	a4,115
 83e:	f4e782e3          	beq	a5,a4,782 <vprintf+0x1e2>
      } else if(c0 == '%'){
 842:	02500713          	li	a4,37
 846:	f6e787e3          	beq	a5,a4,7b4 <vprintf+0x214>
        putc(fd, '%');
 84a:	02500593          	li	a1,37
 84e:	855a                	mv	a0,s6
 850:	c95ff0ef          	jal	4e4 <putc>
        putc(fd, c0);
 854:	85a6                	mv	a1,s1
 856:	855a                	mv	a0,s6
 858:	c8dff0ef          	jal	4e4 <putc>
      state = 0;
 85c:	4981                	li	s3,0
 85e:	b359                	j	5e4 <vprintf+0x44>

0000000000000860 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 860:	715d                	addi	sp,sp,-80
 862:	ec06                	sd	ra,24(sp)
 864:	e822                	sd	s0,16(sp)
 866:	1000                	addi	s0,sp,32
 868:	e010                	sd	a2,0(s0)
 86a:	e414                	sd	a3,8(s0)
 86c:	e818                	sd	a4,16(s0)
 86e:	ec1c                	sd	a5,24(s0)
 870:	03043023          	sd	a6,32(s0)
 874:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 878:	8622                	mv	a2,s0
 87a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 87e:	d23ff0ef          	jal	5a0 <vprintf>
}
 882:	60e2                	ld	ra,24(sp)
 884:	6442                	ld	s0,16(sp)
 886:	6161                	addi	sp,sp,80
 888:	8082                	ret

000000000000088a <printf>:

void
printf(const char *fmt, ...)
{
 88a:	711d                	addi	sp,sp,-96
 88c:	ec06                	sd	ra,24(sp)
 88e:	e822                	sd	s0,16(sp)
 890:	1000                	addi	s0,sp,32
 892:	e40c                	sd	a1,8(s0)
 894:	e810                	sd	a2,16(s0)
 896:	ec14                	sd	a3,24(s0)
 898:	f018                	sd	a4,32(s0)
 89a:	f41c                	sd	a5,40(s0)
 89c:	03043823          	sd	a6,48(s0)
 8a0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8a4:	00840613          	addi	a2,s0,8
 8a8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8ac:	85aa                	mv	a1,a0
 8ae:	4505                	li	a0,1
 8b0:	cf1ff0ef          	jal	5a0 <vprintf>
}
 8b4:	60e2                	ld	ra,24(sp)
 8b6:	6442                	ld	s0,16(sp)
 8b8:	6125                	addi	sp,sp,96
 8ba:	8082                	ret

00000000000008bc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8bc:	1141                	addi	sp,sp,-16
 8be:	e406                	sd	ra,8(sp)
 8c0:	e022                	sd	s0,0(sp)
 8c2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8c4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c8:	00000797          	auipc	a5,0x0
 8cc:	7387b783          	ld	a5,1848(a5) # 1000 <freep>
 8d0:	a039                	j	8de <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d2:	6398                	ld	a4,0(a5)
 8d4:	00e7e463          	bltu	a5,a4,8dc <free+0x20>
 8d8:	00e6ea63          	bltu	a3,a4,8ec <free+0x30>
{
 8dc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8de:	fed7fae3          	bgeu	a5,a3,8d2 <free+0x16>
 8e2:	6398                	ld	a4,0(a5)
 8e4:	00e6e463          	bltu	a3,a4,8ec <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8e8:	fee7eae3          	bltu	a5,a4,8dc <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8ec:	ff852583          	lw	a1,-8(a0)
 8f0:	6390                	ld	a2,0(a5)
 8f2:	02059813          	slli	a6,a1,0x20
 8f6:	01c85713          	srli	a4,a6,0x1c
 8fa:	9736                	add	a4,a4,a3
 8fc:	02e60563          	beq	a2,a4,926 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 900:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 904:	4790                	lw	a2,8(a5)
 906:	02061593          	slli	a1,a2,0x20
 90a:	01c5d713          	srli	a4,a1,0x1c
 90e:	973e                	add	a4,a4,a5
 910:	02e68263          	beq	a3,a4,934 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 914:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 916:	00000717          	auipc	a4,0x0
 91a:	6ef73523          	sd	a5,1770(a4) # 1000 <freep>
}
 91e:	60a2                	ld	ra,8(sp)
 920:	6402                	ld	s0,0(sp)
 922:	0141                	addi	sp,sp,16
 924:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 926:	4618                	lw	a4,8(a2)
 928:	9f2d                	addw	a4,a4,a1
 92a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 92e:	6398                	ld	a4,0(a5)
 930:	6310                	ld	a2,0(a4)
 932:	b7f9                	j	900 <free+0x44>
    p->s.size += bp->s.size;
 934:	ff852703          	lw	a4,-8(a0)
 938:	9f31                	addw	a4,a4,a2
 93a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 93c:	ff053683          	ld	a3,-16(a0)
 940:	bfd1                	j	914 <free+0x58>

0000000000000942 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 942:	7139                	addi	sp,sp,-64
 944:	fc06                	sd	ra,56(sp)
 946:	f822                	sd	s0,48(sp)
 948:	f04a                	sd	s2,32(sp)
 94a:	ec4e                	sd	s3,24(sp)
 94c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 94e:	02051993          	slli	s3,a0,0x20
 952:	0209d993          	srli	s3,s3,0x20
 956:	09bd                	addi	s3,s3,15
 958:	0049d993          	srli	s3,s3,0x4
 95c:	2985                	addiw	s3,s3,1
 95e:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 960:	00000517          	auipc	a0,0x0
 964:	6a053503          	ld	a0,1696(a0) # 1000 <freep>
 968:	c905                	beqz	a0,998 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 96a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 96c:	4798                	lw	a4,8(a5)
 96e:	09377663          	bgeu	a4,s3,9fa <malloc+0xb8>
 972:	f426                	sd	s1,40(sp)
 974:	e852                	sd	s4,16(sp)
 976:	e456                	sd	s5,8(sp)
 978:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 97a:	8a4e                	mv	s4,s3
 97c:	6705                	lui	a4,0x1
 97e:	00e9f363          	bgeu	s3,a4,984 <malloc+0x42>
 982:	6a05                	lui	s4,0x1
 984:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 988:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 98c:	00000497          	auipc	s1,0x0
 990:	67448493          	addi	s1,s1,1652 # 1000 <freep>
  if(p == SBRK_ERROR)
 994:	5afd                	li	s5,-1
 996:	a83d                	j	9d4 <malloc+0x92>
 998:	f426                	sd	s1,40(sp)
 99a:	e852                	sd	s4,16(sp)
 99c:	e456                	sd	s5,8(sp)
 99e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9a0:	00000797          	auipc	a5,0x0
 9a4:	67078793          	addi	a5,a5,1648 # 1010 <base>
 9a8:	00000717          	auipc	a4,0x0
 9ac:	64f73c23          	sd	a5,1624(a4) # 1000 <freep>
 9b0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9b2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9b6:	b7d1                	j	97a <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 9b8:	6398                	ld	a4,0(a5)
 9ba:	e118                	sd	a4,0(a0)
 9bc:	a899                	j	a12 <malloc+0xd0>
  hp->s.size = nu;
 9be:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9c2:	0541                	addi	a0,a0,16
 9c4:	ef9ff0ef          	jal	8bc <free>
  return freep;
 9c8:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 9ca:	c125                	beqz	a0,a2a <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9cc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9ce:	4798                	lw	a4,8(a5)
 9d0:	03277163          	bgeu	a4,s2,9f2 <malloc+0xb0>
    if(p == freep)
 9d4:	6098                	ld	a4,0(s1)
 9d6:	853e                	mv	a0,a5
 9d8:	fef71ae3          	bne	a4,a5,9cc <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 9dc:	8552                	mv	a0,s4
 9de:	99dff0ef          	jal	37a <sbrk>
  if(p == SBRK_ERROR)
 9e2:	fd551ee3          	bne	a0,s5,9be <malloc+0x7c>
        return 0;
 9e6:	4501                	li	a0,0
 9e8:	74a2                	ld	s1,40(sp)
 9ea:	6a42                	ld	s4,16(sp)
 9ec:	6aa2                	ld	s5,8(sp)
 9ee:	6b02                	ld	s6,0(sp)
 9f0:	a03d                	j	a1e <malloc+0xdc>
 9f2:	74a2                	ld	s1,40(sp)
 9f4:	6a42                	ld	s4,16(sp)
 9f6:	6aa2                	ld	s5,8(sp)
 9f8:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9fa:	fae90fe3          	beq	s2,a4,9b8 <malloc+0x76>
        p->s.size -= nunits;
 9fe:	4137073b          	subw	a4,a4,s3
 a02:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a04:	02071693          	slli	a3,a4,0x20
 a08:	01c6d713          	srli	a4,a3,0x1c
 a0c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a0e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a12:	00000717          	auipc	a4,0x0
 a16:	5ea73723          	sd	a0,1518(a4) # 1000 <freep>
      return (void*)(p + 1);
 a1a:	01078513          	addi	a0,a5,16
  }
}
 a1e:	70e2                	ld	ra,56(sp)
 a20:	7442                	ld	s0,48(sp)
 a22:	7902                	ld	s2,32(sp)
 a24:	69e2                	ld	s3,24(sp)
 a26:	6121                	addi	sp,sp,64
 a28:	8082                	ret
 a2a:	74a2                	ld	s1,40(sp)
 a2c:	6a42                	ld	s4,16(sp)
 a2e:	6aa2                	ld	s5,8(sp)
 a30:	6b02                	ld	s6,0(sp)
 a32:	b7f5                	j	a1e <malloc+0xdc>
