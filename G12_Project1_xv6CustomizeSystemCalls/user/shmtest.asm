
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
   c:	3b0000ef          	jal	3bc <shmget>
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
  20:	97c50513          	addi	a0,a0,-1668 # 998 <malloc+0x110>
  24:	7b0000ef          	jal	7d4 <printf>

  // Attach shared memory
  char *addr = (char*)shmat(shmid);
  28:	8526                	mv	a0,s1
  2a:	39a000ef          	jal	3c4 <shmat>
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
  3c:	9a050513          	addi	a0,a0,-1632 # 9d8 <malloc+0x150>
  40:	794000ef          	jal	7d4 <printf>

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
  66:	9a650513          	addi	a0,a0,-1626 # a08 <malloc+0x180>
  6a:	76a000ef          	jal	7d4 <printf>

  // Detach shared memory
  if(shmdt(shmid) < 0){
  6e:	8526                	mv	a0,s1
  70:	35c000ef          	jal	3cc <shmdt>
  74:	06054063          	bltz	a0,d4 <main+0xd4>
    printf("shmdt failed\n");
    exit(1);
  }
  printf("shmdt: detached shared memory\n");
  78:	00001517          	auipc	a0,0x1
  7c:	9c050513          	addi	a0,a0,-1600 # a38 <malloc+0x1b0>
  80:	754000ef          	jal	7d4 <printf>

  // Delete shared memory
  if(shmctl(shmid) < 0){
  84:	8526                	mv	a0,s1
  86:	34e000ef          	jal	3d4 <shmctl>
  8a:	04054e63          	bltz	a0,e6 <main+0xe6>
    printf("shmctl failed\n");
    exit(1);
  }
  printf("shmctl: deleted shared memory\n");
  8e:	00001517          	auipc	a0,0x1
  92:	9da50513          	addi	a0,a0,-1574 # a68 <malloc+0x1e0>
  96:	73e000ef          	jal	7d4 <printf>

  printf("Shared memory test complete!\n");
  9a:	00001517          	auipc	a0,0x1
  9e:	9ee50513          	addi	a0,a0,-1554 # a88 <malloc+0x200>
  a2:	732000ef          	jal	7d4 <printf>
  exit(0);
  a6:	4501                	li	a0,0
  a8:	2e4000ef          	jal	38c <exit>
  ac:	e426                	sd	s1,8(sp)
  ae:	e04a                	sd	s2,0(sp)
    printf("shmget failed\n");
  b0:	00001517          	auipc	a0,0x1
  b4:	8d050513          	addi	a0,a0,-1840 # 980 <malloc+0xf8>
  b8:	71c000ef          	jal	7d4 <printf>
    exit(1);
  bc:	4505                	li	a0,1
  be:	2ce000ef          	jal	38c <exit>
    printf("shmat failed\n");
  c2:	00001517          	auipc	a0,0x1
  c6:	90650513          	addi	a0,a0,-1786 # 9c8 <malloc+0x140>
  ca:	70a000ef          	jal	7d4 <printf>
    exit(1);
  ce:	4505                	li	a0,1
  d0:	2bc000ef          	jal	38c <exit>
    printf("shmdt failed\n");
  d4:	00001517          	auipc	a0,0x1
  d8:	95450513          	addi	a0,a0,-1708 # a28 <malloc+0x1a0>
  dc:	6f8000ef          	jal	7d4 <printf>
    exit(1);
  e0:	4505                	li	a0,1
  e2:	2aa000ef          	jal	38c <exit>
    printf("shmctl failed\n");
  e6:	00001517          	auipc	a0,0x1
  ea:	97250513          	addi	a0,a0,-1678 # a58 <malloc+0x1d0>
  ee:	6e6000ef          	jal	7d4 <printf>
    exit(1);
  f2:	4505                	li	a0,1
  f4:	298000ef          	jal	38c <exit>

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
 104:	288000ef          	jal	38c <exit>

0000000000000108 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 108:	1141                	addi	sp,sp,-16
 10a:	e422                	sd	s0,8(sp)
 10c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 10e:	87aa                	mv	a5,a0
 110:	0585                	addi	a1,a1,1 # 1001 <freep+0x1>
 112:	0785                	addi	a5,a5,1
 114:	fff5c703          	lbu	a4,-1(a1)
 118:	fee78fa3          	sb	a4,-1(a5)
 11c:	fb75                	bnez	a4,110 <strcpy+0x8>
    ;
  return os;
}
 11e:	6422                	ld	s0,8(sp)
 120:	0141                	addi	sp,sp,16
 122:	8082                	ret

0000000000000124 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 124:	1141                	addi	sp,sp,-16
 126:	e422                	sd	s0,8(sp)
 128:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 12a:	00054783          	lbu	a5,0(a0)
 12e:	cb91                	beqz	a5,142 <strcmp+0x1e>
 130:	0005c703          	lbu	a4,0(a1)
 134:	00f71763          	bne	a4,a5,142 <strcmp+0x1e>
    p++, q++;
 138:	0505                	addi	a0,a0,1
 13a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 13c:	00054783          	lbu	a5,0(a0)
 140:	fbe5                	bnez	a5,130 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 142:	0005c503          	lbu	a0,0(a1)
}
 146:	40a7853b          	subw	a0,a5,a0
 14a:	6422                	ld	s0,8(sp)
 14c:	0141                	addi	sp,sp,16
 14e:	8082                	ret

0000000000000150 <strlen>:

uint
strlen(const char *s)
{
 150:	1141                	addi	sp,sp,-16
 152:	e422                	sd	s0,8(sp)
 154:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 156:	00054783          	lbu	a5,0(a0)
 15a:	cf91                	beqz	a5,176 <strlen+0x26>
 15c:	0505                	addi	a0,a0,1
 15e:	87aa                	mv	a5,a0
 160:	86be                	mv	a3,a5
 162:	0785                	addi	a5,a5,1
 164:	fff7c703          	lbu	a4,-1(a5)
 168:	ff65                	bnez	a4,160 <strlen+0x10>
 16a:	40a6853b          	subw	a0,a3,a0
 16e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 170:	6422                	ld	s0,8(sp)
 172:	0141                	addi	sp,sp,16
 174:	8082                	ret
  for(n = 0; s[n]; n++)
 176:	4501                	li	a0,0
 178:	bfe5                	j	170 <strlen+0x20>

000000000000017a <memset>:

void*
memset(void *dst, int c, uint n)
{
 17a:	1141                	addi	sp,sp,-16
 17c:	e422                	sd	s0,8(sp)
 17e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 180:	ca19                	beqz	a2,196 <memset+0x1c>
 182:	87aa                	mv	a5,a0
 184:	1602                	slli	a2,a2,0x20
 186:	9201                	srli	a2,a2,0x20
 188:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 18c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 190:	0785                	addi	a5,a5,1
 192:	fee79de3          	bne	a5,a4,18c <memset+0x12>
  }
  return dst;
}
 196:	6422                	ld	s0,8(sp)
 198:	0141                	addi	sp,sp,16
 19a:	8082                	ret

000000000000019c <strchr>:

char*
strchr(const char *s, char c)
{
 19c:	1141                	addi	sp,sp,-16
 19e:	e422                	sd	s0,8(sp)
 1a0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1a2:	00054783          	lbu	a5,0(a0)
 1a6:	cb99                	beqz	a5,1bc <strchr+0x20>
    if(*s == c)
 1a8:	00f58763          	beq	a1,a5,1b6 <strchr+0x1a>
  for(; *s; s++)
 1ac:	0505                	addi	a0,a0,1
 1ae:	00054783          	lbu	a5,0(a0)
 1b2:	fbfd                	bnez	a5,1a8 <strchr+0xc>
      return (char*)s;
  return 0;
 1b4:	4501                	li	a0,0
}
 1b6:	6422                	ld	s0,8(sp)
 1b8:	0141                	addi	sp,sp,16
 1ba:	8082                	ret
  return 0;
 1bc:	4501                	li	a0,0
 1be:	bfe5                	j	1b6 <strchr+0x1a>

00000000000001c0 <gets>:

char*
gets(char *buf, int max)
{
 1c0:	711d                	addi	sp,sp,-96
 1c2:	ec86                	sd	ra,88(sp)
 1c4:	e8a2                	sd	s0,80(sp)
 1c6:	e4a6                	sd	s1,72(sp)
 1c8:	e0ca                	sd	s2,64(sp)
 1ca:	fc4e                	sd	s3,56(sp)
 1cc:	f852                	sd	s4,48(sp)
 1ce:	f456                	sd	s5,40(sp)
 1d0:	f05a                	sd	s6,32(sp)
 1d2:	ec5e                	sd	s7,24(sp)
 1d4:	1080                	addi	s0,sp,96
 1d6:	8baa                	mv	s7,a0
 1d8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1da:	892a                	mv	s2,a0
 1dc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1de:	4aa9                	li	s5,10
 1e0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1e2:	89a6                	mv	s3,s1
 1e4:	2485                	addiw	s1,s1,1
 1e6:	0344d663          	bge	s1,s4,212 <gets+0x52>
    cc = read(0, &c, 1);
 1ea:	4605                	li	a2,1
 1ec:	faf40593          	addi	a1,s0,-81
 1f0:	4501                	li	a0,0
 1f2:	1b2000ef          	jal	3a4 <read>
    if(cc < 1)
 1f6:	00a05e63          	blez	a0,212 <gets+0x52>
    buf[i++] = c;
 1fa:	faf44783          	lbu	a5,-81(s0)
 1fe:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 202:	01578763          	beq	a5,s5,210 <gets+0x50>
 206:	0905                	addi	s2,s2,1
 208:	fd679de3          	bne	a5,s6,1e2 <gets+0x22>
    buf[i++] = c;
 20c:	89a6                	mv	s3,s1
 20e:	a011                	j	212 <gets+0x52>
 210:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 212:	99de                	add	s3,s3,s7
 214:	00098023          	sb	zero,0(s3)
  return buf;
}
 218:	855e                	mv	a0,s7
 21a:	60e6                	ld	ra,88(sp)
 21c:	6446                	ld	s0,80(sp)
 21e:	64a6                	ld	s1,72(sp)
 220:	6906                	ld	s2,64(sp)
 222:	79e2                	ld	s3,56(sp)
 224:	7a42                	ld	s4,48(sp)
 226:	7aa2                	ld	s5,40(sp)
 228:	7b02                	ld	s6,32(sp)
 22a:	6be2                	ld	s7,24(sp)
 22c:	6125                	addi	sp,sp,96
 22e:	8082                	ret

0000000000000230 <stat>:

int
stat(const char *n, struct stat *st)
{
 230:	1101                	addi	sp,sp,-32
 232:	ec06                	sd	ra,24(sp)
 234:	e822                	sd	s0,16(sp)
 236:	e04a                	sd	s2,0(sp)
 238:	1000                	addi	s0,sp,32
 23a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 23c:	4581                	li	a1,0
 23e:	1ae000ef          	jal	3ec <open>
  if(fd < 0)
 242:	02054263          	bltz	a0,266 <stat+0x36>
 246:	e426                	sd	s1,8(sp)
 248:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 24a:	85ca                	mv	a1,s2
 24c:	1b8000ef          	jal	404 <fstat>
 250:	892a                	mv	s2,a0
  close(fd);
 252:	8526                	mv	a0,s1
 254:	160000ef          	jal	3b4 <close>
  return r;
 258:	64a2                	ld	s1,8(sp)
}
 25a:	854a                	mv	a0,s2
 25c:	60e2                	ld	ra,24(sp)
 25e:	6442                	ld	s0,16(sp)
 260:	6902                	ld	s2,0(sp)
 262:	6105                	addi	sp,sp,32
 264:	8082                	ret
    return -1;
 266:	597d                	li	s2,-1
 268:	bfcd                	j	25a <stat+0x2a>

000000000000026a <atoi>:

int
atoi(const char *s)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e422                	sd	s0,8(sp)
 26e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 270:	00054683          	lbu	a3,0(a0)
 274:	fd06879b          	addiw	a5,a3,-48
 278:	0ff7f793          	zext.b	a5,a5
 27c:	4625                	li	a2,9
 27e:	02f66863          	bltu	a2,a5,2ae <atoi+0x44>
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
 2a4:	fef671e3          	bgeu	a2,a5,286 <atoi+0x1c>
  return n;
}
 2a8:	6422                	ld	s0,8(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret
  n = 0;
 2ae:	4501                	li	a0,0
 2b0:	bfe5                	j	2a8 <atoi+0x3e>

00000000000002b2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b2:	1141                	addi	sp,sp,-16
 2b4:	e422                	sd	s0,8(sp)
 2b6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2b8:	02b57463          	bgeu	a0,a1,2e0 <memmove+0x2e>
    while(n-- > 0)
 2bc:	00c05f63          	blez	a2,2da <memmove+0x28>
 2c0:	1602                	slli	a2,a2,0x20
 2c2:	9201                	srli	a2,a2,0x20
 2c4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2c8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ca:	0585                	addi	a1,a1,1
 2cc:	0705                	addi	a4,a4,1
 2ce:	fff5c683          	lbu	a3,-1(a1)
 2d2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2d6:	fef71ae3          	bne	a4,a5,2ca <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2da:	6422                	ld	s0,8(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret
    dst += n;
 2e0:	00c50733          	add	a4,a0,a2
    src += n;
 2e4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2e6:	fec05ae3          	blez	a2,2da <memmove+0x28>
 2ea:	fff6079b          	addiw	a5,a2,-1
 2ee:	1782                	slli	a5,a5,0x20
 2f0:	9381                	srli	a5,a5,0x20
 2f2:	fff7c793          	not	a5,a5
 2f6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2f8:	15fd                	addi	a1,a1,-1
 2fa:	177d                	addi	a4,a4,-1
 2fc:	0005c683          	lbu	a3,0(a1)
 300:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 304:	fee79ae3          	bne	a5,a4,2f8 <memmove+0x46>
 308:	bfc9                	j	2da <memmove+0x28>

000000000000030a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 30a:	1141                	addi	sp,sp,-16
 30c:	e422                	sd	s0,8(sp)
 30e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 310:	ca05                	beqz	a2,340 <memcmp+0x36>
 312:	fff6069b          	addiw	a3,a2,-1
 316:	1682                	slli	a3,a3,0x20
 318:	9281                	srli	a3,a3,0x20
 31a:	0685                	addi	a3,a3,1
 31c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 31e:	00054783          	lbu	a5,0(a0)
 322:	0005c703          	lbu	a4,0(a1)
 326:	00e79863          	bne	a5,a4,336 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 32a:	0505                	addi	a0,a0,1
    p2++;
 32c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 32e:	fed518e3          	bne	a0,a3,31e <memcmp+0x14>
  }
  return 0;
 332:	4501                	li	a0,0
 334:	a019                	j	33a <memcmp+0x30>
      return *p1 - *p2;
 336:	40e7853b          	subw	a0,a5,a4
}
 33a:	6422                	ld	s0,8(sp)
 33c:	0141                	addi	sp,sp,16
 33e:	8082                	ret
  return 0;
 340:	4501                	li	a0,0
 342:	bfe5                	j	33a <memcmp+0x30>

0000000000000344 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 344:	1141                	addi	sp,sp,-16
 346:	e406                	sd	ra,8(sp)
 348:	e022                	sd	s0,0(sp)
 34a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 34c:	f67ff0ef          	jal	2b2 <memmove>
}
 350:	60a2                	ld	ra,8(sp)
 352:	6402                	ld	s0,0(sp)
 354:	0141                	addi	sp,sp,16
 356:	8082                	ret

0000000000000358 <sbrk>:

char *
sbrk(int n) {
 358:	1141                	addi	sp,sp,-16
 35a:	e406                	sd	ra,8(sp)
 35c:	e022                	sd	s0,0(sp)
 35e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 360:	4585                	li	a1,1
 362:	0d2000ef          	jal	434 <sys_sbrk>
}
 366:	60a2                	ld	ra,8(sp)
 368:	6402                	ld	s0,0(sp)
 36a:	0141                	addi	sp,sp,16
 36c:	8082                	ret

000000000000036e <sbrklazy>:

char *
sbrklazy(int n) {
 36e:	1141                	addi	sp,sp,-16
 370:	e406                	sd	ra,8(sp)
 372:	e022                	sd	s0,0(sp)
 374:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 376:	4589                	li	a1,2
 378:	0bc000ef          	jal	434 <sys_sbrk>
}
 37c:	60a2                	ld	ra,8(sp)
 37e:	6402                	ld	s0,0(sp)
 380:	0141                	addi	sp,sp,16
 382:	8082                	ret

0000000000000384 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 384:	4885                	li	a7,1
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <exit>:
.global exit
exit:
 li a7, SYS_exit
 38c:	4889                	li	a7,2
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <wait>:
.global wait
wait:
 li a7, SYS_wait
 394:	488d                	li	a7,3
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 39c:	4891                	li	a7,4
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <read>:
.global read
read:
 li a7, SYS_read
 3a4:	4895                	li	a7,5
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <write>:
.global write
write:
 li a7, SYS_write
 3ac:	48c1                	li	a7,16
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <close>:
.global close
close:
 li a7, SYS_close
 3b4:	48d5                	li	a7,21
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 3bc:	48d9                	li	a7,22
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <shmat>:
.global shmat
shmat:
 li a7, SYS_shmat
 3c4:	48dd                	li	a7,23
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 3cc:	48e1                	li	a7,24
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 3d4:	48e5                	li	a7,25
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <kill>:
.global kill
kill:
 li a7, SYS_kill
 3dc:	4899                	li	a7,6
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3e4:	489d                	li	a7,7
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <open>:
.global open
open:
 li a7, SYS_open
 3ec:	48bd                	li	a7,15
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3f4:	48c5                	li	a7,17
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3fc:	48c9                	li	a7,18
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 404:	48a1                	li	a7,8
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <link>:
.global link
link:
 li a7, SYS_link
 40c:	48cd                	li	a7,19
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 414:	48d1                	li	a7,20
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 41c:	48a5                	li	a7,9
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <dup>:
.global dup
dup:
 li a7, SYS_dup
 424:	48a9                	li	a7,10
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 42c:	48ad                	li	a7,11
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 434:	48b1                	li	a7,12
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <pause>:
.global pause
pause:
 li a7, SYS_pause
 43c:	48b5                	li	a7,13
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 444:	48b9                	li	a7,14
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 44c:	1101                	addi	sp,sp,-32
 44e:	ec06                	sd	ra,24(sp)
 450:	e822                	sd	s0,16(sp)
 452:	1000                	addi	s0,sp,32
 454:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 458:	4605                	li	a2,1
 45a:	fef40593          	addi	a1,s0,-17
 45e:	f4fff0ef          	jal	3ac <write>
}
 462:	60e2                	ld	ra,24(sp)
 464:	6442                	ld	s0,16(sp)
 466:	6105                	addi	sp,sp,32
 468:	8082                	ret

000000000000046a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 46a:	715d                	addi	sp,sp,-80
 46c:	e486                	sd	ra,72(sp)
 46e:	e0a2                	sd	s0,64(sp)
 470:	f84a                	sd	s2,48(sp)
 472:	0880                	addi	s0,sp,80
 474:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 476:	c299                	beqz	a3,47c <printint+0x12>
 478:	0805c363          	bltz	a1,4fe <printint+0x94>
  neg = 0;
 47c:	4881                	li	a7,0
 47e:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 482:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 484:	00000517          	auipc	a0,0x0
 488:	62c50513          	addi	a0,a0,1580 # ab0 <digits>
 48c:	883e                	mv	a6,a5
 48e:	2785                	addiw	a5,a5,1
 490:	02c5f733          	remu	a4,a1,a2
 494:	972a                	add	a4,a4,a0
 496:	00074703          	lbu	a4,0(a4)
 49a:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 49e:	872e                	mv	a4,a1
 4a0:	02c5d5b3          	divu	a1,a1,a2
 4a4:	0685                	addi	a3,a3,1
 4a6:	fec773e3          	bgeu	a4,a2,48c <printint+0x22>
  if(neg)
 4aa:	00088b63          	beqz	a7,4c0 <printint+0x56>
    buf[i++] = '-';
 4ae:	fd078793          	addi	a5,a5,-48
 4b2:	97a2                	add	a5,a5,s0
 4b4:	02d00713          	li	a4,45
 4b8:	fee78423          	sb	a4,-24(a5)
 4bc:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4c0:	02f05a63          	blez	a5,4f4 <printint+0x8a>
 4c4:	fc26                	sd	s1,56(sp)
 4c6:	f44e                	sd	s3,40(sp)
 4c8:	fb840713          	addi	a4,s0,-72
 4cc:	00f704b3          	add	s1,a4,a5
 4d0:	fff70993          	addi	s3,a4,-1
 4d4:	99be                	add	s3,s3,a5
 4d6:	37fd                	addiw	a5,a5,-1
 4d8:	1782                	slli	a5,a5,0x20
 4da:	9381                	srli	a5,a5,0x20
 4dc:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4e0:	fff4c583          	lbu	a1,-1(s1)
 4e4:	854a                	mv	a0,s2
 4e6:	f67ff0ef          	jal	44c <putc>
  while(--i >= 0)
 4ea:	14fd                	addi	s1,s1,-1
 4ec:	ff349ae3          	bne	s1,s3,4e0 <printint+0x76>
 4f0:	74e2                	ld	s1,56(sp)
 4f2:	79a2                	ld	s3,40(sp)
}
 4f4:	60a6                	ld	ra,72(sp)
 4f6:	6406                	ld	s0,64(sp)
 4f8:	7942                	ld	s2,48(sp)
 4fa:	6161                	addi	sp,sp,80
 4fc:	8082                	ret
    x = -xx;
 4fe:	40b005b3          	neg	a1,a1
    neg = 1;
 502:	4885                	li	a7,1
    x = -xx;
 504:	bfad                	j	47e <printint+0x14>

0000000000000506 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 506:	711d                	addi	sp,sp,-96
 508:	ec86                	sd	ra,88(sp)
 50a:	e8a2                	sd	s0,80(sp)
 50c:	e0ca                	sd	s2,64(sp)
 50e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 510:	0005c903          	lbu	s2,0(a1)
 514:	28090663          	beqz	s2,7a0 <vprintf+0x29a>
 518:	e4a6                	sd	s1,72(sp)
 51a:	fc4e                	sd	s3,56(sp)
 51c:	f852                	sd	s4,48(sp)
 51e:	f456                	sd	s5,40(sp)
 520:	f05a                	sd	s6,32(sp)
 522:	ec5e                	sd	s7,24(sp)
 524:	e862                	sd	s8,16(sp)
 526:	e466                	sd	s9,8(sp)
 528:	8b2a                	mv	s6,a0
 52a:	8a2e                	mv	s4,a1
 52c:	8bb2                	mv	s7,a2
  state = 0;
 52e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 530:	4481                	li	s1,0
 532:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 534:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 538:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 53c:	06c00c93          	li	s9,108
 540:	a005                	j	560 <vprintf+0x5a>
        putc(fd, c0);
 542:	85ca                	mv	a1,s2
 544:	855a                	mv	a0,s6
 546:	f07ff0ef          	jal	44c <putc>
 54a:	a019                	j	550 <vprintf+0x4a>
    } else if(state == '%'){
 54c:	03598263          	beq	s3,s5,570 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 550:	2485                	addiw	s1,s1,1
 552:	8726                	mv	a4,s1
 554:	009a07b3          	add	a5,s4,s1
 558:	0007c903          	lbu	s2,0(a5)
 55c:	22090a63          	beqz	s2,790 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 560:	0009079b          	sext.w	a5,s2
    if(state == 0){
 564:	fe0994e3          	bnez	s3,54c <vprintf+0x46>
      if(c0 == '%'){
 568:	fd579de3          	bne	a5,s5,542 <vprintf+0x3c>
        state = '%';
 56c:	89be                	mv	s3,a5
 56e:	b7cd                	j	550 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 570:	00ea06b3          	add	a3,s4,a4
 574:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 578:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 57a:	c681                	beqz	a3,582 <vprintf+0x7c>
 57c:	9752                	add	a4,a4,s4
 57e:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 582:	05878363          	beq	a5,s8,5c8 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 586:	05978d63          	beq	a5,s9,5e0 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 58a:	07500713          	li	a4,117
 58e:	0ee78763          	beq	a5,a4,67c <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 592:	07800713          	li	a4,120
 596:	12e78963          	beq	a5,a4,6c8 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 59a:	07000713          	li	a4,112
 59e:	14e78e63          	beq	a5,a4,6fa <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5a2:	06300713          	li	a4,99
 5a6:	18e78e63          	beq	a5,a4,742 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5aa:	07300713          	li	a4,115
 5ae:	1ae78463          	beq	a5,a4,756 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5b2:	02500713          	li	a4,37
 5b6:	04e79563          	bne	a5,a4,600 <vprintf+0xfa>
        putc(fd, '%');
 5ba:	02500593          	li	a1,37
 5be:	855a                	mv	a0,s6
 5c0:	e8dff0ef          	jal	44c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5c4:	4981                	li	s3,0
 5c6:	b769                	j	550 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5c8:	008b8913          	addi	s2,s7,8
 5cc:	4685                	li	a3,1
 5ce:	4629                	li	a2,10
 5d0:	000ba583          	lw	a1,0(s7)
 5d4:	855a                	mv	a0,s6
 5d6:	e95ff0ef          	jal	46a <printint>
 5da:	8bca                	mv	s7,s2
      state = 0;
 5dc:	4981                	li	s3,0
 5de:	bf8d                	j	550 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5e0:	06400793          	li	a5,100
 5e4:	02f68963          	beq	a3,a5,616 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5e8:	06c00793          	li	a5,108
 5ec:	04f68263          	beq	a3,a5,630 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5f0:	07500793          	li	a5,117
 5f4:	0af68063          	beq	a3,a5,694 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 5f8:	07800793          	li	a5,120
 5fc:	0ef68263          	beq	a3,a5,6e0 <vprintf+0x1da>
        putc(fd, '%');
 600:	02500593          	li	a1,37
 604:	855a                	mv	a0,s6
 606:	e47ff0ef          	jal	44c <putc>
        putc(fd, c0);
 60a:	85ca                	mv	a1,s2
 60c:	855a                	mv	a0,s6
 60e:	e3fff0ef          	jal	44c <putc>
      state = 0;
 612:	4981                	li	s3,0
 614:	bf35                	j	550 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 616:	008b8913          	addi	s2,s7,8
 61a:	4685                	li	a3,1
 61c:	4629                	li	a2,10
 61e:	000bb583          	ld	a1,0(s7)
 622:	855a                	mv	a0,s6
 624:	e47ff0ef          	jal	46a <printint>
        i += 1;
 628:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 62a:	8bca                	mv	s7,s2
      state = 0;
 62c:	4981                	li	s3,0
        i += 1;
 62e:	b70d                	j	550 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 630:	06400793          	li	a5,100
 634:	02f60763          	beq	a2,a5,662 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 638:	07500793          	li	a5,117
 63c:	06f60963          	beq	a2,a5,6ae <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 640:	07800793          	li	a5,120
 644:	faf61ee3          	bne	a2,a5,600 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 648:	008b8913          	addi	s2,s7,8
 64c:	4681                	li	a3,0
 64e:	4641                	li	a2,16
 650:	000bb583          	ld	a1,0(s7)
 654:	855a                	mv	a0,s6
 656:	e15ff0ef          	jal	46a <printint>
        i += 2;
 65a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 65c:	8bca                	mv	s7,s2
      state = 0;
 65e:	4981                	li	s3,0
        i += 2;
 660:	bdc5                	j	550 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 662:	008b8913          	addi	s2,s7,8
 666:	4685                	li	a3,1
 668:	4629                	li	a2,10
 66a:	000bb583          	ld	a1,0(s7)
 66e:	855a                	mv	a0,s6
 670:	dfbff0ef          	jal	46a <printint>
        i += 2;
 674:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 676:	8bca                	mv	s7,s2
      state = 0;
 678:	4981                	li	s3,0
        i += 2;
 67a:	bdd9                	j	550 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 67c:	008b8913          	addi	s2,s7,8
 680:	4681                	li	a3,0
 682:	4629                	li	a2,10
 684:	000be583          	lwu	a1,0(s7)
 688:	855a                	mv	a0,s6
 68a:	de1ff0ef          	jal	46a <printint>
 68e:	8bca                	mv	s7,s2
      state = 0;
 690:	4981                	li	s3,0
 692:	bd7d                	j	550 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 694:	008b8913          	addi	s2,s7,8
 698:	4681                	li	a3,0
 69a:	4629                	li	a2,10
 69c:	000bb583          	ld	a1,0(s7)
 6a0:	855a                	mv	a0,s6
 6a2:	dc9ff0ef          	jal	46a <printint>
        i += 1;
 6a6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a8:	8bca                	mv	s7,s2
      state = 0;
 6aa:	4981                	li	s3,0
        i += 1;
 6ac:	b555                	j	550 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ae:	008b8913          	addi	s2,s7,8
 6b2:	4681                	li	a3,0
 6b4:	4629                	li	a2,10
 6b6:	000bb583          	ld	a1,0(s7)
 6ba:	855a                	mv	a0,s6
 6bc:	dafff0ef          	jal	46a <printint>
        i += 2;
 6c0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c2:	8bca                	mv	s7,s2
      state = 0;
 6c4:	4981                	li	s3,0
        i += 2;
 6c6:	b569                	j	550 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6c8:	008b8913          	addi	s2,s7,8
 6cc:	4681                	li	a3,0
 6ce:	4641                	li	a2,16
 6d0:	000be583          	lwu	a1,0(s7)
 6d4:	855a                	mv	a0,s6
 6d6:	d95ff0ef          	jal	46a <printint>
 6da:	8bca                	mv	s7,s2
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	bd8d                	j	550 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e0:	008b8913          	addi	s2,s7,8
 6e4:	4681                	li	a3,0
 6e6:	4641                	li	a2,16
 6e8:	000bb583          	ld	a1,0(s7)
 6ec:	855a                	mv	a0,s6
 6ee:	d7dff0ef          	jal	46a <printint>
        i += 1;
 6f2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f4:	8bca                	mv	s7,s2
      state = 0;
 6f6:	4981                	li	s3,0
        i += 1;
 6f8:	bda1                	j	550 <vprintf+0x4a>
 6fa:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6fc:	008b8d13          	addi	s10,s7,8
 700:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 704:	03000593          	li	a1,48
 708:	855a                	mv	a0,s6
 70a:	d43ff0ef          	jal	44c <putc>
  putc(fd, 'x');
 70e:	07800593          	li	a1,120
 712:	855a                	mv	a0,s6
 714:	d39ff0ef          	jal	44c <putc>
 718:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 71a:	00000b97          	auipc	s7,0x0
 71e:	396b8b93          	addi	s7,s7,918 # ab0 <digits>
 722:	03c9d793          	srli	a5,s3,0x3c
 726:	97de                	add	a5,a5,s7
 728:	0007c583          	lbu	a1,0(a5)
 72c:	855a                	mv	a0,s6
 72e:	d1fff0ef          	jal	44c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 732:	0992                	slli	s3,s3,0x4
 734:	397d                	addiw	s2,s2,-1
 736:	fe0916e3          	bnez	s2,722 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 73a:	8bea                	mv	s7,s10
      state = 0;
 73c:	4981                	li	s3,0
 73e:	6d02                	ld	s10,0(sp)
 740:	bd01                	j	550 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 742:	008b8913          	addi	s2,s7,8
 746:	000bc583          	lbu	a1,0(s7)
 74a:	855a                	mv	a0,s6
 74c:	d01ff0ef          	jal	44c <putc>
 750:	8bca                	mv	s7,s2
      state = 0;
 752:	4981                	li	s3,0
 754:	bbf5                	j	550 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 756:	008b8993          	addi	s3,s7,8
 75a:	000bb903          	ld	s2,0(s7)
 75e:	00090f63          	beqz	s2,77c <vprintf+0x276>
        for(; *s; s++)
 762:	00094583          	lbu	a1,0(s2)
 766:	c195                	beqz	a1,78a <vprintf+0x284>
          putc(fd, *s);
 768:	855a                	mv	a0,s6
 76a:	ce3ff0ef          	jal	44c <putc>
        for(; *s; s++)
 76e:	0905                	addi	s2,s2,1
 770:	00094583          	lbu	a1,0(s2)
 774:	f9f5                	bnez	a1,768 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 776:	8bce                	mv	s7,s3
      state = 0;
 778:	4981                	li	s3,0
 77a:	bbd9                	j	550 <vprintf+0x4a>
          s = "(null)";
 77c:	00000917          	auipc	s2,0x0
 780:	32c90913          	addi	s2,s2,812 # aa8 <malloc+0x220>
        for(; *s; s++)
 784:	02800593          	li	a1,40
 788:	b7c5                	j	768 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 78a:	8bce                	mv	s7,s3
      state = 0;
 78c:	4981                	li	s3,0
 78e:	b3c9                	j	550 <vprintf+0x4a>
 790:	64a6                	ld	s1,72(sp)
 792:	79e2                	ld	s3,56(sp)
 794:	7a42                	ld	s4,48(sp)
 796:	7aa2                	ld	s5,40(sp)
 798:	7b02                	ld	s6,32(sp)
 79a:	6be2                	ld	s7,24(sp)
 79c:	6c42                	ld	s8,16(sp)
 79e:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7a0:	60e6                	ld	ra,88(sp)
 7a2:	6446                	ld	s0,80(sp)
 7a4:	6906                	ld	s2,64(sp)
 7a6:	6125                	addi	sp,sp,96
 7a8:	8082                	ret

00000000000007aa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7aa:	715d                	addi	sp,sp,-80
 7ac:	ec06                	sd	ra,24(sp)
 7ae:	e822                	sd	s0,16(sp)
 7b0:	1000                	addi	s0,sp,32
 7b2:	e010                	sd	a2,0(s0)
 7b4:	e414                	sd	a3,8(s0)
 7b6:	e818                	sd	a4,16(s0)
 7b8:	ec1c                	sd	a5,24(s0)
 7ba:	03043023          	sd	a6,32(s0)
 7be:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7c2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7c6:	8622                	mv	a2,s0
 7c8:	d3fff0ef          	jal	506 <vprintf>
}
 7cc:	60e2                	ld	ra,24(sp)
 7ce:	6442                	ld	s0,16(sp)
 7d0:	6161                	addi	sp,sp,80
 7d2:	8082                	ret

00000000000007d4 <printf>:

void
printf(const char *fmt, ...)
{
 7d4:	711d                	addi	sp,sp,-96
 7d6:	ec06                	sd	ra,24(sp)
 7d8:	e822                	sd	s0,16(sp)
 7da:	1000                	addi	s0,sp,32
 7dc:	e40c                	sd	a1,8(s0)
 7de:	e810                	sd	a2,16(s0)
 7e0:	ec14                	sd	a3,24(s0)
 7e2:	f018                	sd	a4,32(s0)
 7e4:	f41c                	sd	a5,40(s0)
 7e6:	03043823          	sd	a6,48(s0)
 7ea:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ee:	00840613          	addi	a2,s0,8
 7f2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7f6:	85aa                	mv	a1,a0
 7f8:	4505                	li	a0,1
 7fa:	d0dff0ef          	jal	506 <vprintf>
}
 7fe:	60e2                	ld	ra,24(sp)
 800:	6442                	ld	s0,16(sp)
 802:	6125                	addi	sp,sp,96
 804:	8082                	ret

0000000000000806 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 806:	1141                	addi	sp,sp,-16
 808:	e422                	sd	s0,8(sp)
 80a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 80c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 810:	00000797          	auipc	a5,0x0
 814:	7f07b783          	ld	a5,2032(a5) # 1000 <freep>
 818:	a02d                	j	842 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 81a:	4618                	lw	a4,8(a2)
 81c:	9f2d                	addw	a4,a4,a1
 81e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 822:	6398                	ld	a4,0(a5)
 824:	6310                	ld	a2,0(a4)
 826:	a83d                	j	864 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 828:	ff852703          	lw	a4,-8(a0)
 82c:	9f31                	addw	a4,a4,a2
 82e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 830:	ff053683          	ld	a3,-16(a0)
 834:	a091                	j	878 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 836:	6398                	ld	a4,0(a5)
 838:	00e7e463          	bltu	a5,a4,840 <free+0x3a>
 83c:	00e6ea63          	bltu	a3,a4,850 <free+0x4a>
{
 840:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 842:	fed7fae3          	bgeu	a5,a3,836 <free+0x30>
 846:	6398                	ld	a4,0(a5)
 848:	00e6e463          	bltu	a3,a4,850 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 84c:	fee7eae3          	bltu	a5,a4,840 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 850:	ff852583          	lw	a1,-8(a0)
 854:	6390                	ld	a2,0(a5)
 856:	02059813          	slli	a6,a1,0x20
 85a:	01c85713          	srli	a4,a6,0x1c
 85e:	9736                	add	a4,a4,a3
 860:	fae60de3          	beq	a2,a4,81a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 864:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 868:	4790                	lw	a2,8(a5)
 86a:	02061593          	slli	a1,a2,0x20
 86e:	01c5d713          	srli	a4,a1,0x1c
 872:	973e                	add	a4,a4,a5
 874:	fae68ae3          	beq	a3,a4,828 <free+0x22>
    p->s.ptr = bp->s.ptr;
 878:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 87a:	00000717          	auipc	a4,0x0
 87e:	78f73323          	sd	a5,1926(a4) # 1000 <freep>
}
 882:	6422                	ld	s0,8(sp)
 884:	0141                	addi	sp,sp,16
 886:	8082                	ret

0000000000000888 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 888:	7139                	addi	sp,sp,-64
 88a:	fc06                	sd	ra,56(sp)
 88c:	f822                	sd	s0,48(sp)
 88e:	f426                	sd	s1,40(sp)
 890:	ec4e                	sd	s3,24(sp)
 892:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 894:	02051493          	slli	s1,a0,0x20
 898:	9081                	srli	s1,s1,0x20
 89a:	04bd                	addi	s1,s1,15
 89c:	8091                	srli	s1,s1,0x4
 89e:	0014899b          	addiw	s3,s1,1
 8a2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8a4:	00000517          	auipc	a0,0x0
 8a8:	75c53503          	ld	a0,1884(a0) # 1000 <freep>
 8ac:	c915                	beqz	a0,8e0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b0:	4798                	lw	a4,8(a5)
 8b2:	08977a63          	bgeu	a4,s1,946 <malloc+0xbe>
 8b6:	f04a                	sd	s2,32(sp)
 8b8:	e852                	sd	s4,16(sp)
 8ba:	e456                	sd	s5,8(sp)
 8bc:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8be:	8a4e                	mv	s4,s3
 8c0:	0009871b          	sext.w	a4,s3
 8c4:	6685                	lui	a3,0x1
 8c6:	00d77363          	bgeu	a4,a3,8cc <malloc+0x44>
 8ca:	6a05                	lui	s4,0x1
 8cc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8d0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8d4:	00000917          	auipc	s2,0x0
 8d8:	72c90913          	addi	s2,s2,1836 # 1000 <freep>
  if(p == SBRK_ERROR)
 8dc:	5afd                	li	s5,-1
 8de:	a081                	j	91e <malloc+0x96>
 8e0:	f04a                	sd	s2,32(sp)
 8e2:	e852                	sd	s4,16(sp)
 8e4:	e456                	sd	s5,8(sp)
 8e6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8e8:	00000797          	auipc	a5,0x0
 8ec:	72878793          	addi	a5,a5,1832 # 1010 <base>
 8f0:	00000717          	auipc	a4,0x0
 8f4:	70f73823          	sd	a5,1808(a4) # 1000 <freep>
 8f8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8fa:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8fe:	b7c1                	j	8be <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 900:	6398                	ld	a4,0(a5)
 902:	e118                	sd	a4,0(a0)
 904:	a8a9                	j	95e <malloc+0xd6>
  hp->s.size = nu;
 906:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 90a:	0541                	addi	a0,a0,16
 90c:	efbff0ef          	jal	806 <free>
  return freep;
 910:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 914:	c12d                	beqz	a0,976 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 916:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 918:	4798                	lw	a4,8(a5)
 91a:	02977263          	bgeu	a4,s1,93e <malloc+0xb6>
    if(p == freep)
 91e:	00093703          	ld	a4,0(s2)
 922:	853e                	mv	a0,a5
 924:	fef719e3          	bne	a4,a5,916 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 928:	8552                	mv	a0,s4
 92a:	a2fff0ef          	jal	358 <sbrk>
  if(p == SBRK_ERROR)
 92e:	fd551ce3          	bne	a0,s5,906 <malloc+0x7e>
        return 0;
 932:	4501                	li	a0,0
 934:	7902                	ld	s2,32(sp)
 936:	6a42                	ld	s4,16(sp)
 938:	6aa2                	ld	s5,8(sp)
 93a:	6b02                	ld	s6,0(sp)
 93c:	a03d                	j	96a <malloc+0xe2>
 93e:	7902                	ld	s2,32(sp)
 940:	6a42                	ld	s4,16(sp)
 942:	6aa2                	ld	s5,8(sp)
 944:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 946:	fae48de3          	beq	s1,a4,900 <malloc+0x78>
        p->s.size -= nunits;
 94a:	4137073b          	subw	a4,a4,s3
 94e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 950:	02071693          	slli	a3,a4,0x20
 954:	01c6d713          	srli	a4,a3,0x1c
 958:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 95a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 95e:	00000717          	auipc	a4,0x0
 962:	6aa73123          	sd	a0,1698(a4) # 1000 <freep>
      return (void*)(p + 1);
 966:	01078513          	addi	a0,a5,16
  }
}
 96a:	70e2                	ld	ra,56(sp)
 96c:	7442                	ld	s0,48(sp)
 96e:	74a2                	ld	s1,40(sp)
 970:	69e2                	ld	s3,24(sp)
 972:	6121                	addi	sp,sp,64
 974:	8082                	ret
 976:	7902                	ld	s2,32(sp)
 978:	6a42                	ld	s4,16(sp)
 97a:	6aa2                	ld	s5,8(sp)
 97c:	6b02                	ld	s6,0(sp)
 97e:	b7f5                	j	96a <malloc+0xe2>
