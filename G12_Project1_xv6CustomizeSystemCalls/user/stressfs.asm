
user/_stressfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

int
main(int argc, char *argv[])
{
   0:	dc010113          	addi	sp,sp,-576
   4:	22113c23          	sd	ra,568(sp)
   8:	22813823          	sd	s0,560(sp)
   c:	22913423          	sd	s1,552(sp)
  10:	23213023          	sd	s2,544(sp)
  14:	21313c23          	sd	s3,536(sp)
  18:	21413823          	sd	s4,528(sp)
  1c:	0480                	addi	s0,sp,576
  int fd, i;
  char path[] = "stressfs0";
  1e:	00001797          	auipc	a5,0x1
  22:	a4278793          	addi	a5,a5,-1470 # a60 <malloc+0x12e>
  26:	6398                	ld	a4,0(a5)
  28:	fce43023          	sd	a4,-64(s0)
  2c:	0087d783          	lhu	a5,8(a5)
  30:	fcf41423          	sh	a5,-56(s0)
  char data[512];

  printf("stressfs starting\n");
  34:	00001517          	auipc	a0,0x1
  38:	9fc50513          	addi	a0,a0,-1540 # a30 <malloc+0xfe>
  3c:	03f000ef          	jal	87a <printf>
  memset(data, 'a', sizeof(data));
  40:	20000613          	li	a2,512
  44:	06100593          	li	a1,97
  48:	dc040513          	addi	a0,s0,-576
  4c:	128000ef          	jal	174 <memset>

  for(i = 0; i < 4; i++)
  50:	4481                	li	s1,0
  52:	4911                	li	s2,4
    if(fork() > 0)
  54:	342000ef          	jal	396 <fork>
  58:	00a04563          	bgtz	a0,62 <main+0x62>
  for(i = 0; i < 4; i++)
  5c:	2485                	addiw	s1,s1,1
  5e:	ff249be3          	bne	s1,s2,54 <main+0x54>
      break;

  printf("write %d\n", i);
  62:	85a6                	mv	a1,s1
  64:	00001517          	auipc	a0,0x1
  68:	9e450513          	addi	a0,a0,-1564 # a48 <malloc+0x116>
  6c:	00f000ef          	jal	87a <printf>

  path[8] += i;
  70:	fc844783          	lbu	a5,-56(s0)
  74:	9fa5                	addw	a5,a5,s1
  76:	fcf40423          	sb	a5,-56(s0)
  fd = open(path, O_CREATE | O_RDWR);
  7a:	20200593          	li	a1,514
  7e:	fc040513          	addi	a0,s0,-64
  82:	3e8000ef          	jal	46a <open>
  86:	892a                	mv	s2,a0
  88:	44d1                	li	s1,20
  for(i = 0; i < 20; i++)
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  8a:	dc040a13          	addi	s4,s0,-576
  8e:	20000993          	li	s3,512
  92:	864e                	mv	a2,s3
  94:	85d2                	mv	a1,s4
  96:	854a                	mv	a0,s2
  98:	326000ef          	jal	3be <write>
  for(i = 0; i < 20; i++)
  9c:	34fd                	addiw	s1,s1,-1
  9e:	f8f5                	bnez	s1,92 <main+0x92>
  close(fd);
  a0:	854a                	mv	a0,s2
  a2:	324000ef          	jal	3c6 <close>

  printf("read\n");
  a6:	00001517          	auipc	a0,0x1
  aa:	9b250513          	addi	a0,a0,-1614 # a58 <malloc+0x126>
  ae:	7cc000ef          	jal	87a <printf>

  fd = open(path, O_RDONLY);
  b2:	4581                	li	a1,0
  b4:	fc040513          	addi	a0,s0,-64
  b8:	3b2000ef          	jal	46a <open>
  bc:	892a                	mv	s2,a0
  be:	44d1                	li	s1,20
  for (i = 0; i < 20; i++)
    read(fd, data, sizeof(data));
  c0:	dc040a13          	addi	s4,s0,-576
  c4:	20000993          	li	s3,512
  c8:	864e                	mv	a2,s3
  ca:	85d2                	mv	a1,s4
  cc:	854a                	mv	a0,s2
  ce:	2e8000ef          	jal	3b6 <read>
  for (i = 0; i < 20; i++)
  d2:	34fd                	addiw	s1,s1,-1
  d4:	f8f5                	bnez	s1,c8 <main+0xc8>
  close(fd);
  d6:	854a                	mv	a0,s2
  d8:	2ee000ef          	jal	3c6 <close>

  wait(0);
  dc:	4501                	li	a0,0
  de:	2c8000ef          	jal	3a6 <wait>

  exit(0);
  e2:	4501                	li	a0,0
  e4:	2ba000ef          	jal	39e <exit>

00000000000000e8 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  e8:	1141                	addi	sp,sp,-16
  ea:	e406                	sd	ra,8(sp)
  ec:	e022                	sd	s0,0(sp)
  ee:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  f0:	f11ff0ef          	jal	0 <main>
  exit(r);
  f4:	2aa000ef          	jal	39e <exit>

00000000000000f8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e406                	sd	ra,8(sp)
  fc:	e022                	sd	s0,0(sp)
  fe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 100:	87aa                	mv	a5,a0
 102:	0585                	addi	a1,a1,1
 104:	0785                	addi	a5,a5,1
 106:	fff5c703          	lbu	a4,-1(a1)
 10a:	fee78fa3          	sb	a4,-1(a5)
 10e:	fb75                	bnez	a4,102 <strcpy+0xa>
    ;
  return os;
}
 110:	60a2                	ld	ra,8(sp)
 112:	6402                	ld	s0,0(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret

0000000000000118 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 118:	1141                	addi	sp,sp,-16
 11a:	e406                	sd	ra,8(sp)
 11c:	e022                	sd	s0,0(sp)
 11e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 120:	00054783          	lbu	a5,0(a0)
 124:	cb91                	beqz	a5,138 <strcmp+0x20>
 126:	0005c703          	lbu	a4,0(a1)
 12a:	00f71763          	bne	a4,a5,138 <strcmp+0x20>
    p++, q++;
 12e:	0505                	addi	a0,a0,1
 130:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 132:	00054783          	lbu	a5,0(a0)
 136:	fbe5                	bnez	a5,126 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 138:	0005c503          	lbu	a0,0(a1)
}
 13c:	40a7853b          	subw	a0,a5,a0
 140:	60a2                	ld	ra,8(sp)
 142:	6402                	ld	s0,0(sp)
 144:	0141                	addi	sp,sp,16
 146:	8082                	ret

0000000000000148 <strlen>:

uint
strlen(const char *s)
{
 148:	1141                	addi	sp,sp,-16
 14a:	e406                	sd	ra,8(sp)
 14c:	e022                	sd	s0,0(sp)
 14e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 150:	00054783          	lbu	a5,0(a0)
 154:	cf91                	beqz	a5,170 <strlen+0x28>
 156:	00150793          	addi	a5,a0,1
 15a:	86be                	mv	a3,a5
 15c:	0785                	addi	a5,a5,1
 15e:	fff7c703          	lbu	a4,-1(a5)
 162:	ff65                	bnez	a4,15a <strlen+0x12>
 164:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 168:	60a2                	ld	ra,8(sp)
 16a:	6402                	ld	s0,0(sp)
 16c:	0141                	addi	sp,sp,16
 16e:	8082                	ret
  for(n = 0; s[n]; n++)
 170:	4501                	li	a0,0
 172:	bfdd                	j	168 <strlen+0x20>

0000000000000174 <memset>:

void*
memset(void *dst, int c, uint n)
{
 174:	1141                	addi	sp,sp,-16
 176:	e406                	sd	ra,8(sp)
 178:	e022                	sd	s0,0(sp)
 17a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 17c:	ca19                	beqz	a2,192 <memset+0x1e>
 17e:	87aa                	mv	a5,a0
 180:	1602                	slli	a2,a2,0x20
 182:	9201                	srli	a2,a2,0x20
 184:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 188:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 18c:	0785                	addi	a5,a5,1
 18e:	fee79de3          	bne	a5,a4,188 <memset+0x14>
  }
  return dst;
}
 192:	60a2                	ld	ra,8(sp)
 194:	6402                	ld	s0,0(sp)
 196:	0141                	addi	sp,sp,16
 198:	8082                	ret

000000000000019a <strchr>:

char*
strchr(const char *s, char c)
{
 19a:	1141                	addi	sp,sp,-16
 19c:	e406                	sd	ra,8(sp)
 19e:	e022                	sd	s0,0(sp)
 1a0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1a2:	00054783          	lbu	a5,0(a0)
 1a6:	cf81                	beqz	a5,1be <strchr+0x24>
    if(*s == c)
 1a8:	00f58763          	beq	a1,a5,1b6 <strchr+0x1c>
  for(; *s; s++)
 1ac:	0505                	addi	a0,a0,1
 1ae:	00054783          	lbu	a5,0(a0)
 1b2:	fbfd                	bnez	a5,1a8 <strchr+0xe>
      return (char*)s;
  return 0;
 1b4:	4501                	li	a0,0
}
 1b6:	60a2                	ld	ra,8(sp)
 1b8:	6402                	ld	s0,0(sp)
 1ba:	0141                	addi	sp,sp,16
 1bc:	8082                	ret
  return 0;
 1be:	4501                	li	a0,0
 1c0:	bfdd                	j	1b6 <strchr+0x1c>

00000000000001c2 <gets>:

char*
gets(char *buf, int max)
{
 1c2:	711d                	addi	sp,sp,-96
 1c4:	ec86                	sd	ra,88(sp)
 1c6:	e8a2                	sd	s0,80(sp)
 1c8:	e4a6                	sd	s1,72(sp)
 1ca:	e0ca                	sd	s2,64(sp)
 1cc:	fc4e                	sd	s3,56(sp)
 1ce:	f852                	sd	s4,48(sp)
 1d0:	f456                	sd	s5,40(sp)
 1d2:	f05a                	sd	s6,32(sp)
 1d4:	ec5e                	sd	s7,24(sp)
 1d6:	e862                	sd	s8,16(sp)
 1d8:	1080                	addi	s0,sp,96
 1da:	8baa                	mv	s7,a0
 1dc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1de:	892a                	mv	s2,a0
 1e0:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1e2:	faf40b13          	addi	s6,s0,-81
 1e6:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1e8:	8c26                	mv	s8,s1
 1ea:	0014899b          	addiw	s3,s1,1
 1ee:	84ce                	mv	s1,s3
 1f0:	0349d463          	bge	s3,s4,218 <gets+0x56>
    cc = read(0, &c, 1);
 1f4:	8656                	mv	a2,s5
 1f6:	85da                	mv	a1,s6
 1f8:	4501                	li	a0,0
 1fa:	1bc000ef          	jal	3b6 <read>
    if(cc < 1)
 1fe:	00a05d63          	blez	a0,218 <gets+0x56>
      break;
    buf[i++] = c;
 202:	faf44783          	lbu	a5,-81(s0)
 206:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 20a:	0905                	addi	s2,s2,1
 20c:	ff678713          	addi	a4,a5,-10
 210:	c319                	beqz	a4,216 <gets+0x54>
 212:	17cd                	addi	a5,a5,-13
 214:	fbf1                	bnez	a5,1e8 <gets+0x26>
    buf[i++] = c;
 216:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 218:	9c5e                	add	s8,s8,s7
 21a:	000c0023          	sb	zero,0(s8)
  return buf;
}
 21e:	855e                	mv	a0,s7
 220:	60e6                	ld	ra,88(sp)
 222:	6446                	ld	s0,80(sp)
 224:	64a6                	ld	s1,72(sp)
 226:	6906                	ld	s2,64(sp)
 228:	79e2                	ld	s3,56(sp)
 22a:	7a42                	ld	s4,48(sp)
 22c:	7aa2                	ld	s5,40(sp)
 22e:	7b02                	ld	s6,32(sp)
 230:	6be2                	ld	s7,24(sp)
 232:	6c42                	ld	s8,16(sp)
 234:	6125                	addi	sp,sp,96
 236:	8082                	ret

0000000000000238 <stat>:

int
stat(const char *n, struct stat *st)
{
 238:	1101                	addi	sp,sp,-32
 23a:	ec06                	sd	ra,24(sp)
 23c:	e822                	sd	s0,16(sp)
 23e:	e04a                	sd	s2,0(sp)
 240:	1000                	addi	s0,sp,32
 242:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 244:	4581                	li	a1,0
 246:	224000ef          	jal	46a <open>
  if(fd < 0)
 24a:	02054263          	bltz	a0,26e <stat+0x36>
 24e:	e426                	sd	s1,8(sp)
 250:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 252:	85ca                	mv	a1,s2
 254:	22e000ef          	jal	482 <fstat>
 258:	892a                	mv	s2,a0
  close(fd);
 25a:	8526                	mv	a0,s1
 25c:	16a000ef          	jal	3c6 <close>
  return r;
 260:	64a2                	ld	s1,8(sp)
}
 262:	854a                	mv	a0,s2
 264:	60e2                	ld	ra,24(sp)
 266:	6442                	ld	s0,16(sp)
 268:	6902                	ld	s2,0(sp)
 26a:	6105                	addi	sp,sp,32
 26c:	8082                	ret
    return -1;
 26e:	57fd                	li	a5,-1
 270:	893e                	mv	s2,a5
 272:	bfc5                	j	262 <stat+0x2a>

0000000000000274 <atoi>:

int
atoi(const char *s)
{
 274:	1141                	addi	sp,sp,-16
 276:	e406                	sd	ra,8(sp)
 278:	e022                	sd	s0,0(sp)
 27a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 27c:	00054683          	lbu	a3,0(a0)
 280:	fd06879b          	addiw	a5,a3,-48
 284:	0ff7f793          	zext.b	a5,a5
 288:	4625                	li	a2,9
 28a:	02f66963          	bltu	a2,a5,2bc <atoi+0x48>
 28e:	872a                	mv	a4,a0
  n = 0;
 290:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 292:	0705                	addi	a4,a4,1
 294:	0025179b          	slliw	a5,a0,0x2
 298:	9fa9                	addw	a5,a5,a0
 29a:	0017979b          	slliw	a5,a5,0x1
 29e:	9fb5                	addw	a5,a5,a3
 2a0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2a4:	00074683          	lbu	a3,0(a4)
 2a8:	fd06879b          	addiw	a5,a3,-48
 2ac:	0ff7f793          	zext.b	a5,a5
 2b0:	fef671e3          	bgeu	a2,a5,292 <atoi+0x1e>
  return n;
}
 2b4:	60a2                	ld	ra,8(sp)
 2b6:	6402                	ld	s0,0(sp)
 2b8:	0141                	addi	sp,sp,16
 2ba:	8082                	ret
  n = 0;
 2bc:	4501                	li	a0,0
 2be:	bfdd                	j	2b4 <atoi+0x40>

00000000000002c0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e406                	sd	ra,8(sp)
 2c4:	e022                	sd	s0,0(sp)
 2c6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2c8:	02b57563          	bgeu	a0,a1,2f2 <memmove+0x32>
    while(n-- > 0)
 2cc:	00c05f63          	blez	a2,2ea <memmove+0x2a>
 2d0:	1602                	slli	a2,a2,0x20
 2d2:	9201                	srli	a2,a2,0x20
 2d4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2d8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2da:	0585                	addi	a1,a1,1
 2dc:	0705                	addi	a4,a4,1
 2de:	fff5c683          	lbu	a3,-1(a1)
 2e2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2e6:	fee79ae3          	bne	a5,a4,2da <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ea:	60a2                	ld	ra,8(sp)
 2ec:	6402                	ld	s0,0(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret
    while(n-- > 0)
 2f2:	fec05ce3          	blez	a2,2ea <memmove+0x2a>
    dst += n;
 2f6:	00c50733          	add	a4,a0,a2
    src += n;
 2fa:	95b2                	add	a1,a1,a2
 2fc:	fff6079b          	addiw	a5,a2,-1
 300:	1782                	slli	a5,a5,0x20
 302:	9381                	srli	a5,a5,0x20
 304:	fff7c793          	not	a5,a5
 308:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 30a:	15fd                	addi	a1,a1,-1
 30c:	177d                	addi	a4,a4,-1
 30e:	0005c683          	lbu	a3,0(a1)
 312:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 316:	fef71ae3          	bne	a4,a5,30a <memmove+0x4a>
 31a:	bfc1                	j	2ea <memmove+0x2a>

000000000000031c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 31c:	1141                	addi	sp,sp,-16
 31e:	e406                	sd	ra,8(sp)
 320:	e022                	sd	s0,0(sp)
 322:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 324:	c61d                	beqz	a2,352 <memcmp+0x36>
 326:	1602                	slli	a2,a2,0x20
 328:	9201                	srli	a2,a2,0x20
 32a:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 32e:	00054783          	lbu	a5,0(a0)
 332:	0005c703          	lbu	a4,0(a1)
 336:	00e79863          	bne	a5,a4,346 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 33a:	0505                	addi	a0,a0,1
    p2++;
 33c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 33e:	fed518e3          	bne	a0,a3,32e <memcmp+0x12>
  }
  return 0;
 342:	4501                	li	a0,0
 344:	a019                	j	34a <memcmp+0x2e>
      return *p1 - *p2;
 346:	40e7853b          	subw	a0,a5,a4
}
 34a:	60a2                	ld	ra,8(sp)
 34c:	6402                	ld	s0,0(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret
  return 0;
 352:	4501                	li	a0,0
 354:	bfdd                	j	34a <memcmp+0x2e>

0000000000000356 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 356:	1141                	addi	sp,sp,-16
 358:	e406                	sd	ra,8(sp)
 35a:	e022                	sd	s0,0(sp)
 35c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 35e:	f63ff0ef          	jal	2c0 <memmove>
}
 362:	60a2                	ld	ra,8(sp)
 364:	6402                	ld	s0,0(sp)
 366:	0141                	addi	sp,sp,16
 368:	8082                	ret

000000000000036a <sbrk>:

char *
sbrk(int n) {
 36a:	1141                	addi	sp,sp,-16
 36c:	e406                	sd	ra,8(sp)
 36e:	e022                	sd	s0,0(sp)
 370:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 372:	4585                	li	a1,1
 374:	13e000ef          	jal	4b2 <sys_sbrk>
}
 378:	60a2                	ld	ra,8(sp)
 37a:	6402                	ld	s0,0(sp)
 37c:	0141                	addi	sp,sp,16
 37e:	8082                	ret

0000000000000380 <sbrklazy>:

char *
sbrklazy(int n) {
 380:	1141                	addi	sp,sp,-16
 382:	e406                	sd	ra,8(sp)
 384:	e022                	sd	s0,0(sp)
 386:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 388:	4589                	li	a1,2
 38a:	128000ef          	jal	4b2 <sys_sbrk>
}
 38e:	60a2                	ld	ra,8(sp)
 390:	6402                	ld	s0,0(sp)
 392:	0141                	addi	sp,sp,16
 394:	8082                	ret

0000000000000396 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 396:	4885                	li	a7,1
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <exit>:
.global exit
exit:
 li a7, SYS_exit
 39e:	4889                	li	a7,2
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3a6:	488d                	li	a7,3
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ae:	4891                	li	a7,4
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <read>:
.global read
read:
 li a7, SYS_read
 3b6:	4895                	li	a7,5
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <write>:
.global write
write:
 li a7, SYS_write
 3be:	48c1                	li	a7,16
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <close>:
.global close
close:
 li a7, SYS_close
 3c6:	48d5                	li	a7,21
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 3ce:	48d9                	li	a7,22
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <shmat>:
.global shmat
shmat:
 li a7, SYS_shmat
 3d6:	48dd                	li	a7,23
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 3de:	48e1                	li	a7,24
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 3e6:	48e5                	li	a7,25
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <lockinit>:
.global lockinit
lockinit:
 li a7, SYS_lockinit
 3ee:	48e9                	li	a7,26
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <lockacquire>:
.global lockacquire
lockacquire:
 li a7, SYS_lockacquire
 3f6:	48ed                	li	a7,27
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <lockrelease>:
.global lockrelease
lockrelease:
 li a7, SYS_lockrelease
 3fe:	48f1                	li	a7,28
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <locktry>:
.global locktry
locktry:
 li a7, SYS_locktry
 406:	48f5                	li	a7,29
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <lockcheck>:
.global lockcheck
lockcheck:
 li a7, SYS_lockcheck
 40e:	48f9                	li	a7,30
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <sendmsg>:
.global sendmsg
sendmsg:
 li a7, SYS_sendmsg
 416:	48fd                	li	a7,31
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <recvmsg>:
.global recvmsg
recvmsg:
 li a7, SYS_recvmsg
 41e:	02000893          	li	a7,32
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <broadcast>:
.global broadcast
broadcast:
 li a7, SYS_broadcast
 428:	02100893          	li	a7,33
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <getprocsinfo>:
.global getprocsinfo
getprocsinfo:
 li a7, SYS_getprocsinfo
 432:	02200893          	li	a7,34
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 43c:	02300893          	li	a7,35
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <sleep2>:
.global sleep2
sleep2:
 li a7, SYS_sleep2
 446:	02400893          	li	a7,36
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <signal>:
.global signal
signal:
 li a7, SYS_signal
 450:	02500893          	li	a7,37
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <kill>:
.global kill
kill:
 li a7, SYS_kill
 45a:	4899                	li	a7,6
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <exec>:
.global exec
exec:
 li a7, SYS_exec
 462:	489d                	li	a7,7
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <open>:
.global open
open:
 li a7, SYS_open
 46a:	48bd                	li	a7,15
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 472:	48c5                	li	a7,17
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 47a:	48c9                	li	a7,18
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 482:	48a1                	li	a7,8
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <link>:
.global link
link:
 li a7, SYS_link
 48a:	48cd                	li	a7,19
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 492:	48d1                	li	a7,20
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 49a:	48a5                	li	a7,9
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4a2:	48a9                	li	a7,10
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4aa:	48ad                	li	a7,11
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4b2:	48b1                	li	a7,12
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <pause>:
.global pause
pause:
 li a7, SYS_pause
 4ba:	48b5                	li	a7,13
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4c2:	48b9                	li	a7,14
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <setchildlimit>:
.global setchildlimit
setchildlimit:
 li a7, SYS_setchildlimit
 4ca:	02600893          	li	a7,38
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4d4:	1101                	addi	sp,sp,-32
 4d6:	ec06                	sd	ra,24(sp)
 4d8:	e822                	sd	s0,16(sp)
 4da:	1000                	addi	s0,sp,32
 4dc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4e0:	4605                	li	a2,1
 4e2:	fef40593          	addi	a1,s0,-17
 4e6:	ed9ff0ef          	jal	3be <write>
}
 4ea:	60e2                	ld	ra,24(sp)
 4ec:	6442                	ld	s0,16(sp)
 4ee:	6105                	addi	sp,sp,32
 4f0:	8082                	ret

00000000000004f2 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4f2:	715d                	addi	sp,sp,-80
 4f4:	e486                	sd	ra,72(sp)
 4f6:	e0a2                	sd	s0,64(sp)
 4f8:	f84a                	sd	s2,48(sp)
 4fa:	f44e                	sd	s3,40(sp)
 4fc:	0880                	addi	s0,sp,80
 4fe:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 500:	c6d1                	beqz	a3,58c <printint+0x9a>
 502:	0805d563          	bgez	a1,58c <printint+0x9a>
    neg = 1;
    x = -xx;
 506:	40b005b3          	neg	a1,a1
    neg = 1;
 50a:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 50c:	fb840993          	addi	s3,s0,-72
  neg = 0;
 510:	86ce                	mv	a3,s3
  i = 0;
 512:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 514:	00000817          	auipc	a6,0x0
 518:	56480813          	addi	a6,a6,1380 # a78 <digits>
 51c:	88ba                	mv	a7,a4
 51e:	0017051b          	addiw	a0,a4,1
 522:	872a                	mv	a4,a0
 524:	02c5f7b3          	remu	a5,a1,a2
 528:	97c2                	add	a5,a5,a6
 52a:	0007c783          	lbu	a5,0(a5)
 52e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 532:	87ae                	mv	a5,a1
 534:	02c5d5b3          	divu	a1,a1,a2
 538:	0685                	addi	a3,a3,1
 53a:	fec7f1e3          	bgeu	a5,a2,51c <printint+0x2a>
  if(neg)
 53e:	00030c63          	beqz	t1,556 <printint+0x64>
    buf[i++] = '-';
 542:	fd050793          	addi	a5,a0,-48
 546:	00878533          	add	a0,a5,s0
 54a:	02d00793          	li	a5,45
 54e:	fef50423          	sb	a5,-24(a0)
 552:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 556:	02e05563          	blez	a4,580 <printint+0x8e>
 55a:	fc26                	sd	s1,56(sp)
 55c:	377d                	addiw	a4,a4,-1
 55e:	00e984b3          	add	s1,s3,a4
 562:	19fd                	addi	s3,s3,-1
 564:	99ba                	add	s3,s3,a4
 566:	1702                	slli	a4,a4,0x20
 568:	9301                	srli	a4,a4,0x20
 56a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 56e:	0004c583          	lbu	a1,0(s1)
 572:	854a                	mv	a0,s2
 574:	f61ff0ef          	jal	4d4 <putc>
  while(--i >= 0)
 578:	14fd                	addi	s1,s1,-1
 57a:	ff349ae3          	bne	s1,s3,56e <printint+0x7c>
 57e:	74e2                	ld	s1,56(sp)
}
 580:	60a6                	ld	ra,72(sp)
 582:	6406                	ld	s0,64(sp)
 584:	7942                	ld	s2,48(sp)
 586:	79a2                	ld	s3,40(sp)
 588:	6161                	addi	sp,sp,80
 58a:	8082                	ret
  neg = 0;
 58c:	4301                	li	t1,0
 58e:	bfbd                	j	50c <printint+0x1a>

0000000000000590 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 590:	711d                	addi	sp,sp,-96
 592:	ec86                	sd	ra,88(sp)
 594:	e8a2                	sd	s0,80(sp)
 596:	e4a6                	sd	s1,72(sp)
 598:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 59a:	0005c483          	lbu	s1,0(a1)
 59e:	22048363          	beqz	s1,7c4 <vprintf+0x234>
 5a2:	e0ca                	sd	s2,64(sp)
 5a4:	fc4e                	sd	s3,56(sp)
 5a6:	f852                	sd	s4,48(sp)
 5a8:	f456                	sd	s5,40(sp)
 5aa:	f05a                	sd	s6,32(sp)
 5ac:	ec5e                	sd	s7,24(sp)
 5ae:	e862                	sd	s8,16(sp)
 5b0:	8b2a                	mv	s6,a0
 5b2:	8a2e                	mv	s4,a1
 5b4:	8bb2                	mv	s7,a2
  state = 0;
 5b6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5b8:	4901                	li	s2,0
 5ba:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5bc:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5c0:	06400c13          	li	s8,100
 5c4:	a00d                	j	5e6 <vprintf+0x56>
        putc(fd, c0);
 5c6:	85a6                	mv	a1,s1
 5c8:	855a                	mv	a0,s6
 5ca:	f0bff0ef          	jal	4d4 <putc>
 5ce:	a019                	j	5d4 <vprintf+0x44>
    } else if(state == '%'){
 5d0:	03598363          	beq	s3,s5,5f6 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 5d4:	0019079b          	addiw	a5,s2,1
 5d8:	893e                	mv	s2,a5
 5da:	873e                	mv	a4,a5
 5dc:	97d2                	add	a5,a5,s4
 5de:	0007c483          	lbu	s1,0(a5)
 5e2:	1c048a63          	beqz	s1,7b6 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 5e6:	0004879b          	sext.w	a5,s1
    if(state == 0){
 5ea:	fe0993e3          	bnez	s3,5d0 <vprintf+0x40>
      if(c0 == '%'){
 5ee:	fd579ce3          	bne	a5,s5,5c6 <vprintf+0x36>
        state = '%';
 5f2:	89be                	mv	s3,a5
 5f4:	b7c5                	j	5d4 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 5f6:	00ea06b3          	add	a3,s4,a4
 5fa:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 5fe:	1c060863          	beqz	a2,7ce <vprintf+0x23e>
      if(c0 == 'd'){
 602:	03878763          	beq	a5,s8,630 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 606:	f9478693          	addi	a3,a5,-108
 60a:	0016b693          	seqz	a3,a3
 60e:	f9c60593          	addi	a1,a2,-100
 612:	e99d                	bnez	a1,648 <vprintf+0xb8>
 614:	ca95                	beqz	a3,648 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 616:	008b8493          	addi	s1,s7,8
 61a:	4685                	li	a3,1
 61c:	4629                	li	a2,10
 61e:	000bb583          	ld	a1,0(s7)
 622:	855a                	mv	a0,s6
 624:	ecfff0ef          	jal	4f2 <printint>
        i += 1;
 628:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 62a:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 62c:	4981                	li	s3,0
 62e:	b75d                	j	5d4 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 630:	008b8493          	addi	s1,s7,8
 634:	4685                	li	a3,1
 636:	4629                	li	a2,10
 638:	000ba583          	lw	a1,0(s7)
 63c:	855a                	mv	a0,s6
 63e:	eb5ff0ef          	jal	4f2 <printint>
 642:	8ba6                	mv	s7,s1
      state = 0;
 644:	4981                	li	s3,0
 646:	b779                	j	5d4 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 648:	9752                	add	a4,a4,s4
 64a:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 64e:	f9460713          	addi	a4,a2,-108
 652:	00173713          	seqz	a4,a4
 656:	8f75                	and	a4,a4,a3
 658:	f9c58513          	addi	a0,a1,-100
 65c:	18051363          	bnez	a0,7e2 <vprintf+0x252>
 660:	18070163          	beqz	a4,7e2 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 664:	008b8493          	addi	s1,s7,8
 668:	4685                	li	a3,1
 66a:	4629                	li	a2,10
 66c:	000bb583          	ld	a1,0(s7)
 670:	855a                	mv	a0,s6
 672:	e81ff0ef          	jal	4f2 <printint>
        i += 2;
 676:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 678:	8ba6                	mv	s7,s1
      state = 0;
 67a:	4981                	li	s3,0
        i += 2;
 67c:	bfa1                	j	5d4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 67e:	008b8493          	addi	s1,s7,8
 682:	4681                	li	a3,0
 684:	4629                	li	a2,10
 686:	000be583          	lwu	a1,0(s7)
 68a:	855a                	mv	a0,s6
 68c:	e67ff0ef          	jal	4f2 <printint>
 690:	8ba6                	mv	s7,s1
      state = 0;
 692:	4981                	li	s3,0
 694:	b781                	j	5d4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 696:	008b8493          	addi	s1,s7,8
 69a:	4681                	li	a3,0
 69c:	4629                	li	a2,10
 69e:	000bb583          	ld	a1,0(s7)
 6a2:	855a                	mv	a0,s6
 6a4:	e4fff0ef          	jal	4f2 <printint>
        i += 1;
 6a8:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6aa:	8ba6                	mv	s7,s1
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	b71d                	j	5d4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b0:	008b8493          	addi	s1,s7,8
 6b4:	4681                	li	a3,0
 6b6:	4629                	li	a2,10
 6b8:	000bb583          	ld	a1,0(s7)
 6bc:	855a                	mv	a0,s6
 6be:	e35ff0ef          	jal	4f2 <printint>
        i += 2;
 6c2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c4:	8ba6                	mv	s7,s1
      state = 0;
 6c6:	4981                	li	s3,0
        i += 2;
 6c8:	b731                	j	5d4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6ca:	008b8493          	addi	s1,s7,8
 6ce:	4681                	li	a3,0
 6d0:	4641                	li	a2,16
 6d2:	000be583          	lwu	a1,0(s7)
 6d6:	855a                	mv	a0,s6
 6d8:	e1bff0ef          	jal	4f2 <printint>
 6dc:	8ba6                	mv	s7,s1
      state = 0;
 6de:	4981                	li	s3,0
 6e0:	bdd5                	j	5d4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e2:	008b8493          	addi	s1,s7,8
 6e6:	4681                	li	a3,0
 6e8:	4641                	li	a2,16
 6ea:	000bb583          	ld	a1,0(s7)
 6ee:	855a                	mv	a0,s6
 6f0:	e03ff0ef          	jal	4f2 <printint>
        i += 1;
 6f4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f6:	8ba6                	mv	s7,s1
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	bde9                	j	5d4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6fc:	008b8493          	addi	s1,s7,8
 700:	4681                	li	a3,0
 702:	4641                	li	a2,16
 704:	000bb583          	ld	a1,0(s7)
 708:	855a                	mv	a0,s6
 70a:	de9ff0ef          	jal	4f2 <printint>
        i += 2;
 70e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 710:	8ba6                	mv	s7,s1
      state = 0;
 712:	4981                	li	s3,0
        i += 2;
 714:	b5c1                	j	5d4 <vprintf+0x44>
 716:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 718:	008b8793          	addi	a5,s7,8
 71c:	8cbe                	mv	s9,a5
 71e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 722:	03000593          	li	a1,48
 726:	855a                	mv	a0,s6
 728:	dadff0ef          	jal	4d4 <putc>
  putc(fd, 'x');
 72c:	07800593          	li	a1,120
 730:	855a                	mv	a0,s6
 732:	da3ff0ef          	jal	4d4 <putc>
 736:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 738:	00000b97          	auipc	s7,0x0
 73c:	340b8b93          	addi	s7,s7,832 # a78 <digits>
 740:	03c9d793          	srli	a5,s3,0x3c
 744:	97de                	add	a5,a5,s7
 746:	0007c583          	lbu	a1,0(a5)
 74a:	855a                	mv	a0,s6
 74c:	d89ff0ef          	jal	4d4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 750:	0992                	slli	s3,s3,0x4
 752:	34fd                	addiw	s1,s1,-1
 754:	f4f5                	bnez	s1,740 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 756:	8be6                	mv	s7,s9
      state = 0;
 758:	4981                	li	s3,0
 75a:	6ca2                	ld	s9,8(sp)
 75c:	bda5                	j	5d4 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 75e:	008b8493          	addi	s1,s7,8
 762:	000bc583          	lbu	a1,0(s7)
 766:	855a                	mv	a0,s6
 768:	d6dff0ef          	jal	4d4 <putc>
 76c:	8ba6                	mv	s7,s1
      state = 0;
 76e:	4981                	li	s3,0
 770:	b595                	j	5d4 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 772:	008b8993          	addi	s3,s7,8
 776:	000bb483          	ld	s1,0(s7)
 77a:	cc91                	beqz	s1,796 <vprintf+0x206>
        for(; *s; s++)
 77c:	0004c583          	lbu	a1,0(s1)
 780:	c985                	beqz	a1,7b0 <vprintf+0x220>
          putc(fd, *s);
 782:	855a                	mv	a0,s6
 784:	d51ff0ef          	jal	4d4 <putc>
        for(; *s; s++)
 788:	0485                	addi	s1,s1,1
 78a:	0004c583          	lbu	a1,0(s1)
 78e:	f9f5                	bnez	a1,782 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 790:	8bce                	mv	s7,s3
      state = 0;
 792:	4981                	li	s3,0
 794:	b581                	j	5d4 <vprintf+0x44>
          s = "(null)";
 796:	00000497          	auipc	s1,0x0
 79a:	2da48493          	addi	s1,s1,730 # a70 <malloc+0x13e>
        for(; *s; s++)
 79e:	02800593          	li	a1,40
 7a2:	b7c5                	j	782 <vprintf+0x1f2>
        putc(fd, '%');
 7a4:	85be                	mv	a1,a5
 7a6:	855a                	mv	a0,s6
 7a8:	d2dff0ef          	jal	4d4 <putc>
      state = 0;
 7ac:	4981                	li	s3,0
 7ae:	b51d                	j	5d4 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 7b0:	8bce                	mv	s7,s3
      state = 0;
 7b2:	4981                	li	s3,0
 7b4:	b505                	j	5d4 <vprintf+0x44>
 7b6:	6906                	ld	s2,64(sp)
 7b8:	79e2                	ld	s3,56(sp)
 7ba:	7a42                	ld	s4,48(sp)
 7bc:	7aa2                	ld	s5,40(sp)
 7be:	7b02                	ld	s6,32(sp)
 7c0:	6be2                	ld	s7,24(sp)
 7c2:	6c42                	ld	s8,16(sp)
    }
  }
}
 7c4:	60e6                	ld	ra,88(sp)
 7c6:	6446                	ld	s0,80(sp)
 7c8:	64a6                	ld	s1,72(sp)
 7ca:	6125                	addi	sp,sp,96
 7cc:	8082                	ret
      if(c0 == 'd'){
 7ce:	06400713          	li	a4,100
 7d2:	e4e78fe3          	beq	a5,a4,630 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 7d6:	f9478693          	addi	a3,a5,-108
 7da:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 7de:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7e0:	4701                	li	a4,0
      } else if(c0 == 'u'){
 7e2:	07500513          	li	a0,117
 7e6:	e8a78ce3          	beq	a5,a0,67e <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 7ea:	f8b60513          	addi	a0,a2,-117
 7ee:	e119                	bnez	a0,7f4 <vprintf+0x264>
 7f0:	ea0693e3          	bnez	a3,696 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7f4:	f8b58513          	addi	a0,a1,-117
 7f8:	e119                	bnez	a0,7fe <vprintf+0x26e>
 7fa:	ea071be3          	bnez	a4,6b0 <vprintf+0x120>
      } else if(c0 == 'x'){
 7fe:	07800513          	li	a0,120
 802:	eca784e3          	beq	a5,a0,6ca <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 806:	f8860613          	addi	a2,a2,-120
 80a:	e219                	bnez	a2,810 <vprintf+0x280>
 80c:	ec069be3          	bnez	a3,6e2 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 810:	f8858593          	addi	a1,a1,-120
 814:	e199                	bnez	a1,81a <vprintf+0x28a>
 816:	ee0713e3          	bnez	a4,6fc <vprintf+0x16c>
      } else if(c0 == 'p'){
 81a:	07000713          	li	a4,112
 81e:	eee78ce3          	beq	a5,a4,716 <vprintf+0x186>
      } else if(c0 == 'c'){
 822:	06300713          	li	a4,99
 826:	f2e78ce3          	beq	a5,a4,75e <vprintf+0x1ce>
      } else if(c0 == 's'){
 82a:	07300713          	li	a4,115
 82e:	f4e782e3          	beq	a5,a4,772 <vprintf+0x1e2>
      } else if(c0 == '%'){
 832:	02500713          	li	a4,37
 836:	f6e787e3          	beq	a5,a4,7a4 <vprintf+0x214>
        putc(fd, '%');
 83a:	02500593          	li	a1,37
 83e:	855a                	mv	a0,s6
 840:	c95ff0ef          	jal	4d4 <putc>
        putc(fd, c0);
 844:	85a6                	mv	a1,s1
 846:	855a                	mv	a0,s6
 848:	c8dff0ef          	jal	4d4 <putc>
      state = 0;
 84c:	4981                	li	s3,0
 84e:	b359                	j	5d4 <vprintf+0x44>

0000000000000850 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 850:	715d                	addi	sp,sp,-80
 852:	ec06                	sd	ra,24(sp)
 854:	e822                	sd	s0,16(sp)
 856:	1000                	addi	s0,sp,32
 858:	e010                	sd	a2,0(s0)
 85a:	e414                	sd	a3,8(s0)
 85c:	e818                	sd	a4,16(s0)
 85e:	ec1c                	sd	a5,24(s0)
 860:	03043023          	sd	a6,32(s0)
 864:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 868:	8622                	mv	a2,s0
 86a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 86e:	d23ff0ef          	jal	590 <vprintf>
}
 872:	60e2                	ld	ra,24(sp)
 874:	6442                	ld	s0,16(sp)
 876:	6161                	addi	sp,sp,80
 878:	8082                	ret

000000000000087a <printf>:

void
printf(const char *fmt, ...)
{
 87a:	711d                	addi	sp,sp,-96
 87c:	ec06                	sd	ra,24(sp)
 87e:	e822                	sd	s0,16(sp)
 880:	1000                	addi	s0,sp,32
 882:	e40c                	sd	a1,8(s0)
 884:	e810                	sd	a2,16(s0)
 886:	ec14                	sd	a3,24(s0)
 888:	f018                	sd	a4,32(s0)
 88a:	f41c                	sd	a5,40(s0)
 88c:	03043823          	sd	a6,48(s0)
 890:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 894:	00840613          	addi	a2,s0,8
 898:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 89c:	85aa                	mv	a1,a0
 89e:	4505                	li	a0,1
 8a0:	cf1ff0ef          	jal	590 <vprintf>
}
 8a4:	60e2                	ld	ra,24(sp)
 8a6:	6442                	ld	s0,16(sp)
 8a8:	6125                	addi	sp,sp,96
 8aa:	8082                	ret

00000000000008ac <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8ac:	1141                	addi	sp,sp,-16
 8ae:	e406                	sd	ra,8(sp)
 8b0:	e022                	sd	s0,0(sp)
 8b2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8b4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b8:	00000797          	auipc	a5,0x0
 8bc:	7487b783          	ld	a5,1864(a5) # 1000 <freep>
 8c0:	a039                	j	8ce <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c2:	6398                	ld	a4,0(a5)
 8c4:	00e7e463          	bltu	a5,a4,8cc <free+0x20>
 8c8:	00e6ea63          	bltu	a3,a4,8dc <free+0x30>
{
 8cc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ce:	fed7fae3          	bgeu	a5,a3,8c2 <free+0x16>
 8d2:	6398                	ld	a4,0(a5)
 8d4:	00e6e463          	bltu	a3,a4,8dc <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d8:	fee7eae3          	bltu	a5,a4,8cc <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8dc:	ff852583          	lw	a1,-8(a0)
 8e0:	6390                	ld	a2,0(a5)
 8e2:	02059813          	slli	a6,a1,0x20
 8e6:	01c85713          	srli	a4,a6,0x1c
 8ea:	9736                	add	a4,a4,a3
 8ec:	02e60563          	beq	a2,a4,916 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 8f0:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 8f4:	4790                	lw	a2,8(a5)
 8f6:	02061593          	slli	a1,a2,0x20
 8fa:	01c5d713          	srli	a4,a1,0x1c
 8fe:	973e                	add	a4,a4,a5
 900:	02e68263          	beq	a3,a4,924 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 904:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 906:	00000717          	auipc	a4,0x0
 90a:	6ef73d23          	sd	a5,1786(a4) # 1000 <freep>
}
 90e:	60a2                	ld	ra,8(sp)
 910:	6402                	ld	s0,0(sp)
 912:	0141                	addi	sp,sp,16
 914:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 916:	4618                	lw	a4,8(a2)
 918:	9f2d                	addw	a4,a4,a1
 91a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 91e:	6398                	ld	a4,0(a5)
 920:	6310                	ld	a2,0(a4)
 922:	b7f9                	j	8f0 <free+0x44>
    p->s.size += bp->s.size;
 924:	ff852703          	lw	a4,-8(a0)
 928:	9f31                	addw	a4,a4,a2
 92a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 92c:	ff053683          	ld	a3,-16(a0)
 930:	bfd1                	j	904 <free+0x58>

0000000000000932 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 932:	7139                	addi	sp,sp,-64
 934:	fc06                	sd	ra,56(sp)
 936:	f822                	sd	s0,48(sp)
 938:	f04a                	sd	s2,32(sp)
 93a:	ec4e                	sd	s3,24(sp)
 93c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 93e:	02051993          	slli	s3,a0,0x20
 942:	0209d993          	srli	s3,s3,0x20
 946:	09bd                	addi	s3,s3,15
 948:	0049d993          	srli	s3,s3,0x4
 94c:	2985                	addiw	s3,s3,1
 94e:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 950:	00000517          	auipc	a0,0x0
 954:	6b053503          	ld	a0,1712(a0) # 1000 <freep>
 958:	c905                	beqz	a0,988 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 95a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 95c:	4798                	lw	a4,8(a5)
 95e:	09377663          	bgeu	a4,s3,9ea <malloc+0xb8>
 962:	f426                	sd	s1,40(sp)
 964:	e852                	sd	s4,16(sp)
 966:	e456                	sd	s5,8(sp)
 968:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 96a:	8a4e                	mv	s4,s3
 96c:	6705                	lui	a4,0x1
 96e:	00e9f363          	bgeu	s3,a4,974 <malloc+0x42>
 972:	6a05                	lui	s4,0x1
 974:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 978:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 97c:	00000497          	auipc	s1,0x0
 980:	68448493          	addi	s1,s1,1668 # 1000 <freep>
  if(p == SBRK_ERROR)
 984:	5afd                	li	s5,-1
 986:	a83d                	j	9c4 <malloc+0x92>
 988:	f426                	sd	s1,40(sp)
 98a:	e852                	sd	s4,16(sp)
 98c:	e456                	sd	s5,8(sp)
 98e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 990:	00000797          	auipc	a5,0x0
 994:	68078793          	addi	a5,a5,1664 # 1010 <base>
 998:	00000717          	auipc	a4,0x0
 99c:	66f73423          	sd	a5,1640(a4) # 1000 <freep>
 9a0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9a2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9a6:	b7d1                	j	96a <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 9a8:	6398                	ld	a4,0(a5)
 9aa:	e118                	sd	a4,0(a0)
 9ac:	a899                	j	a02 <malloc+0xd0>
  hp->s.size = nu;
 9ae:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9b2:	0541                	addi	a0,a0,16
 9b4:	ef9ff0ef          	jal	8ac <free>
  return freep;
 9b8:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 9ba:	c125                	beqz	a0,a1a <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9bc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9be:	4798                	lw	a4,8(a5)
 9c0:	03277163          	bgeu	a4,s2,9e2 <malloc+0xb0>
    if(p == freep)
 9c4:	6098                	ld	a4,0(s1)
 9c6:	853e                	mv	a0,a5
 9c8:	fef71ae3          	bne	a4,a5,9bc <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 9cc:	8552                	mv	a0,s4
 9ce:	99dff0ef          	jal	36a <sbrk>
  if(p == SBRK_ERROR)
 9d2:	fd551ee3          	bne	a0,s5,9ae <malloc+0x7c>
        return 0;
 9d6:	4501                	li	a0,0
 9d8:	74a2                	ld	s1,40(sp)
 9da:	6a42                	ld	s4,16(sp)
 9dc:	6aa2                	ld	s5,8(sp)
 9de:	6b02                	ld	s6,0(sp)
 9e0:	a03d                	j	a0e <malloc+0xdc>
 9e2:	74a2                	ld	s1,40(sp)
 9e4:	6a42                	ld	s4,16(sp)
 9e6:	6aa2                	ld	s5,8(sp)
 9e8:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9ea:	fae90fe3          	beq	s2,a4,9a8 <malloc+0x76>
        p->s.size -= nunits;
 9ee:	4137073b          	subw	a4,a4,s3
 9f2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9f4:	02071693          	slli	a3,a4,0x20
 9f8:	01c6d713          	srli	a4,a3,0x1c
 9fc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9fe:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a02:	00000717          	auipc	a4,0x0
 a06:	5ea73f23          	sd	a0,1534(a4) # 1000 <freep>
      return (void*)(p + 1);
 a0a:	01078513          	addi	a0,a5,16
  }
}
 a0e:	70e2                	ld	ra,56(sp)
 a10:	7442                	ld	s0,48(sp)
 a12:	7902                	ld	s2,32(sp)
 a14:	69e2                	ld	s3,24(sp)
 a16:	6121                	addi	sp,sp,64
 a18:	8082                	ret
 a1a:	74a2                	ld	s1,40(sp)
 a1c:	6a42                	ld	s4,16(sp)
 a1e:	6aa2                	ld	s5,8(sp)
 a20:	6b02                	ld	s6,0(sp)
 a22:	b7f5                	j	a0e <malloc+0xdc>
