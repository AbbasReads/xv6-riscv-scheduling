
user/_test_sleep2:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main(){
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    printf("Start\n");
   8:	00001517          	auipc	a0,0x1
   c:	8b850513          	addi	a0,a0,-1864 # 8c0 <malloc+0x102>
  10:	6fa000ef          	jal	70a <printf>
    sleep2(50);
  14:	03200513          	li	a0,50
  18:	35a000ef          	jal	372 <sleep2>
    printf("End\n");
  1c:	00001517          	auipc	a0,0x1
  20:	8ac50513          	addi	a0,a0,-1876 # 8c8 <malloc+0x10a>
  24:	6e6000ef          	jal	70a <printf>
    exit(0);
  28:	4501                	li	a0,0
  2a:	298000ef          	jal	2c2 <exit>

000000000000002e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  2e:	1141                	addi	sp,sp,-16
  30:	e406                	sd	ra,8(sp)
  32:	e022                	sd	s0,0(sp)
  34:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  36:	fcbff0ef          	jal	0 <main>
  exit(r);
  3a:	288000ef          	jal	2c2 <exit>

000000000000003e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  3e:	1141                	addi	sp,sp,-16
  40:	e422                	sd	s0,8(sp)
  42:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  44:	87aa                	mv	a5,a0
  46:	0585                	addi	a1,a1,1
  48:	0785                	addi	a5,a5,1
  4a:	fff5c703          	lbu	a4,-1(a1)
  4e:	fee78fa3          	sb	a4,-1(a5)
  52:	fb75                	bnez	a4,46 <strcpy+0x8>
    ;
  return os;
}
  54:	6422                	ld	s0,8(sp)
  56:	0141                	addi	sp,sp,16
  58:	8082                	ret

000000000000005a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  5a:	1141                	addi	sp,sp,-16
  5c:	e422                	sd	s0,8(sp)
  5e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  60:	00054783          	lbu	a5,0(a0)
  64:	cb91                	beqz	a5,78 <strcmp+0x1e>
  66:	0005c703          	lbu	a4,0(a1)
  6a:	00f71763          	bne	a4,a5,78 <strcmp+0x1e>
    p++, q++;
  6e:	0505                	addi	a0,a0,1
  70:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  72:	00054783          	lbu	a5,0(a0)
  76:	fbe5                	bnez	a5,66 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  78:	0005c503          	lbu	a0,0(a1)
}
  7c:	40a7853b          	subw	a0,a5,a0
  80:	6422                	ld	s0,8(sp)
  82:	0141                	addi	sp,sp,16
  84:	8082                	ret

0000000000000086 <strlen>:

uint
strlen(const char *s)
{
  86:	1141                	addi	sp,sp,-16
  88:	e422                	sd	s0,8(sp)
  8a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  8c:	00054783          	lbu	a5,0(a0)
  90:	cf91                	beqz	a5,ac <strlen+0x26>
  92:	0505                	addi	a0,a0,1
  94:	87aa                	mv	a5,a0
  96:	86be                	mv	a3,a5
  98:	0785                	addi	a5,a5,1
  9a:	fff7c703          	lbu	a4,-1(a5)
  9e:	ff65                	bnez	a4,96 <strlen+0x10>
  a0:	40a6853b          	subw	a0,a3,a0
  a4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  a6:	6422                	ld	s0,8(sp)
  a8:	0141                	addi	sp,sp,16
  aa:	8082                	ret
  for(n = 0; s[n]; n++)
  ac:	4501                	li	a0,0
  ae:	bfe5                	j	a6 <strlen+0x20>

00000000000000b0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b0:	1141                	addi	sp,sp,-16
  b2:	e422                	sd	s0,8(sp)
  b4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  b6:	ca19                	beqz	a2,cc <memset+0x1c>
  b8:	87aa                	mv	a5,a0
  ba:	1602                	slli	a2,a2,0x20
  bc:	9201                	srli	a2,a2,0x20
  be:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  c2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  c6:	0785                	addi	a5,a5,1
  c8:	fee79de3          	bne	a5,a4,c2 <memset+0x12>
  }
  return dst;
}
  cc:	6422                	ld	s0,8(sp)
  ce:	0141                	addi	sp,sp,16
  d0:	8082                	ret

00000000000000d2 <strchr>:

char*
strchr(const char *s, char c)
{
  d2:	1141                	addi	sp,sp,-16
  d4:	e422                	sd	s0,8(sp)
  d6:	0800                	addi	s0,sp,16
  for(; *s; s++)
  d8:	00054783          	lbu	a5,0(a0)
  dc:	cb99                	beqz	a5,f2 <strchr+0x20>
    if(*s == c)
  de:	00f58763          	beq	a1,a5,ec <strchr+0x1a>
  for(; *s; s++)
  e2:	0505                	addi	a0,a0,1
  e4:	00054783          	lbu	a5,0(a0)
  e8:	fbfd                	bnez	a5,de <strchr+0xc>
      return (char*)s;
  return 0;
  ea:	4501                	li	a0,0
}
  ec:	6422                	ld	s0,8(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret
  return 0;
  f2:	4501                	li	a0,0
  f4:	bfe5                	j	ec <strchr+0x1a>

00000000000000f6 <gets>:

char*
gets(char *buf, int max)
{
  f6:	711d                	addi	sp,sp,-96
  f8:	ec86                	sd	ra,88(sp)
  fa:	e8a2                	sd	s0,80(sp)
  fc:	e4a6                	sd	s1,72(sp)
  fe:	e0ca                	sd	s2,64(sp)
 100:	fc4e                	sd	s3,56(sp)
 102:	f852                	sd	s4,48(sp)
 104:	f456                	sd	s5,40(sp)
 106:	f05a                	sd	s6,32(sp)
 108:	ec5e                	sd	s7,24(sp)
 10a:	1080                	addi	s0,sp,96
 10c:	8baa                	mv	s7,a0
 10e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 110:	892a                	mv	s2,a0
 112:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 114:	4aa9                	li	s5,10
 116:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 118:	89a6                	mv	s3,s1
 11a:	2485                	addiw	s1,s1,1
 11c:	0344d663          	bge	s1,s4,148 <gets+0x52>
    cc = read(0, &c, 1);
 120:	4605                	li	a2,1
 122:	faf40593          	addi	a1,s0,-81
 126:	4501                	li	a0,0
 128:	1b2000ef          	jal	2da <read>
    if(cc < 1)
 12c:	00a05e63          	blez	a0,148 <gets+0x52>
    buf[i++] = c;
 130:	faf44783          	lbu	a5,-81(s0)
 134:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 138:	01578763          	beq	a5,s5,146 <gets+0x50>
 13c:	0905                	addi	s2,s2,1
 13e:	fd679de3          	bne	a5,s6,118 <gets+0x22>
    buf[i++] = c;
 142:	89a6                	mv	s3,s1
 144:	a011                	j	148 <gets+0x52>
 146:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 148:	99de                	add	s3,s3,s7
 14a:	00098023          	sb	zero,0(s3)
  return buf;
}
 14e:	855e                	mv	a0,s7
 150:	60e6                	ld	ra,88(sp)
 152:	6446                	ld	s0,80(sp)
 154:	64a6                	ld	s1,72(sp)
 156:	6906                	ld	s2,64(sp)
 158:	79e2                	ld	s3,56(sp)
 15a:	7a42                	ld	s4,48(sp)
 15c:	7aa2                	ld	s5,40(sp)
 15e:	7b02                	ld	s6,32(sp)
 160:	6be2                	ld	s7,24(sp)
 162:	6125                	addi	sp,sp,96
 164:	8082                	ret

0000000000000166 <stat>:

int
stat(const char *n, struct stat *st)
{
 166:	1101                	addi	sp,sp,-32
 168:	ec06                	sd	ra,24(sp)
 16a:	e822                	sd	s0,16(sp)
 16c:	e04a                	sd	s2,0(sp)
 16e:	1000                	addi	s0,sp,32
 170:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 172:	4581                	li	a1,0
 174:	18e000ef          	jal	302 <open>
  if(fd < 0)
 178:	02054263          	bltz	a0,19c <stat+0x36>
 17c:	e426                	sd	s1,8(sp)
 17e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 180:	85ca                	mv	a1,s2
 182:	198000ef          	jal	31a <fstat>
 186:	892a                	mv	s2,a0
  close(fd);
 188:	8526                	mv	a0,s1
 18a:	160000ef          	jal	2ea <close>
  return r;
 18e:	64a2                	ld	s1,8(sp)
}
 190:	854a                	mv	a0,s2
 192:	60e2                	ld	ra,24(sp)
 194:	6442                	ld	s0,16(sp)
 196:	6902                	ld	s2,0(sp)
 198:	6105                	addi	sp,sp,32
 19a:	8082                	ret
    return -1;
 19c:	597d                	li	s2,-1
 19e:	bfcd                	j	190 <stat+0x2a>

00000000000001a0 <atoi>:

int
atoi(const char *s)
{
 1a0:	1141                	addi	sp,sp,-16
 1a2:	e422                	sd	s0,8(sp)
 1a4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1a6:	00054683          	lbu	a3,0(a0)
 1aa:	fd06879b          	addiw	a5,a3,-48
 1ae:	0ff7f793          	zext.b	a5,a5
 1b2:	4625                	li	a2,9
 1b4:	02f66863          	bltu	a2,a5,1e4 <atoi+0x44>
 1b8:	872a                	mv	a4,a0
  n = 0;
 1ba:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1bc:	0705                	addi	a4,a4,1
 1be:	0025179b          	slliw	a5,a0,0x2
 1c2:	9fa9                	addw	a5,a5,a0
 1c4:	0017979b          	slliw	a5,a5,0x1
 1c8:	9fb5                	addw	a5,a5,a3
 1ca:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1ce:	00074683          	lbu	a3,0(a4)
 1d2:	fd06879b          	addiw	a5,a3,-48
 1d6:	0ff7f793          	zext.b	a5,a5
 1da:	fef671e3          	bgeu	a2,a5,1bc <atoi+0x1c>
  return n;
}
 1de:	6422                	ld	s0,8(sp)
 1e0:	0141                	addi	sp,sp,16
 1e2:	8082                	ret
  n = 0;
 1e4:	4501                	li	a0,0
 1e6:	bfe5                	j	1de <atoi+0x3e>

00000000000001e8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1e8:	1141                	addi	sp,sp,-16
 1ea:	e422                	sd	s0,8(sp)
 1ec:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1ee:	02b57463          	bgeu	a0,a1,216 <memmove+0x2e>
    while(n-- > 0)
 1f2:	00c05f63          	blez	a2,210 <memmove+0x28>
 1f6:	1602                	slli	a2,a2,0x20
 1f8:	9201                	srli	a2,a2,0x20
 1fa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1fe:	872a                	mv	a4,a0
      *dst++ = *src++;
 200:	0585                	addi	a1,a1,1
 202:	0705                	addi	a4,a4,1
 204:	fff5c683          	lbu	a3,-1(a1)
 208:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 20c:	fef71ae3          	bne	a4,a5,200 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 210:	6422                	ld	s0,8(sp)
 212:	0141                	addi	sp,sp,16
 214:	8082                	ret
    dst += n;
 216:	00c50733          	add	a4,a0,a2
    src += n;
 21a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 21c:	fec05ae3          	blez	a2,210 <memmove+0x28>
 220:	fff6079b          	addiw	a5,a2,-1
 224:	1782                	slli	a5,a5,0x20
 226:	9381                	srli	a5,a5,0x20
 228:	fff7c793          	not	a5,a5
 22c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 22e:	15fd                	addi	a1,a1,-1
 230:	177d                	addi	a4,a4,-1
 232:	0005c683          	lbu	a3,0(a1)
 236:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 23a:	fee79ae3          	bne	a5,a4,22e <memmove+0x46>
 23e:	bfc9                	j	210 <memmove+0x28>

0000000000000240 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 240:	1141                	addi	sp,sp,-16
 242:	e422                	sd	s0,8(sp)
 244:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 246:	ca05                	beqz	a2,276 <memcmp+0x36>
 248:	fff6069b          	addiw	a3,a2,-1
 24c:	1682                	slli	a3,a3,0x20
 24e:	9281                	srli	a3,a3,0x20
 250:	0685                	addi	a3,a3,1
 252:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 254:	00054783          	lbu	a5,0(a0)
 258:	0005c703          	lbu	a4,0(a1)
 25c:	00e79863          	bne	a5,a4,26c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 260:	0505                	addi	a0,a0,1
    p2++;
 262:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 264:	fed518e3          	bne	a0,a3,254 <memcmp+0x14>
  }
  return 0;
 268:	4501                	li	a0,0
 26a:	a019                	j	270 <memcmp+0x30>
      return *p1 - *p2;
 26c:	40e7853b          	subw	a0,a5,a4
}
 270:	6422                	ld	s0,8(sp)
 272:	0141                	addi	sp,sp,16
 274:	8082                	ret
  return 0;
 276:	4501                	li	a0,0
 278:	bfe5                	j	270 <memcmp+0x30>

000000000000027a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e406                	sd	ra,8(sp)
 27e:	e022                	sd	s0,0(sp)
 280:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 282:	f67ff0ef          	jal	1e8 <memmove>
}
 286:	60a2                	ld	ra,8(sp)
 288:	6402                	ld	s0,0(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret

000000000000028e <sbrk>:

char *
sbrk(int n) {
 28e:	1141                	addi	sp,sp,-16
 290:	e406                	sd	ra,8(sp)
 292:	e022                	sd	s0,0(sp)
 294:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 296:	4585                	li	a1,1
 298:	0b2000ef          	jal	34a <sys_sbrk>
}
 29c:	60a2                	ld	ra,8(sp)
 29e:	6402                	ld	s0,0(sp)
 2a0:	0141                	addi	sp,sp,16
 2a2:	8082                	ret

00000000000002a4 <sbrklazy>:

char *
sbrklazy(int n) {
 2a4:	1141                	addi	sp,sp,-16
 2a6:	e406                	sd	ra,8(sp)
 2a8:	e022                	sd	s0,0(sp)
 2aa:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2ac:	4589                	li	a1,2
 2ae:	09c000ef          	jal	34a <sys_sbrk>
}
 2b2:	60a2                	ld	ra,8(sp)
 2b4:	6402                	ld	s0,0(sp)
 2b6:	0141                	addi	sp,sp,16
 2b8:	8082                	ret

00000000000002ba <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2ba:	4885                	li	a7,1
 ecall
 2bc:	00000073          	ecall
 ret
 2c0:	8082                	ret

00000000000002c2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2c2:	4889                	li	a7,2
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ca:	488d                	li	a7,3
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2d2:	4891                	li	a7,4
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <read>:
.global read
read:
 li a7, SYS_read
 2da:	4895                	li	a7,5
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <write>:
.global write
write:
 li a7, SYS_write
 2e2:	48c1                	li	a7,16
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <close>:
.global close
close:
 li a7, SYS_close
 2ea:	48d5                	li	a7,21
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2f2:	4899                	li	a7,6
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <exec>:
.global exec
exec:
 li a7, SYS_exec
 2fa:	489d                	li	a7,7
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <open>:
.global open
open:
 li a7, SYS_open
 302:	48bd                	li	a7,15
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 30a:	48c5                	li	a7,17
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 312:	48c9                	li	a7,18
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 31a:	48a1                	li	a7,8
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <link>:
.global link
link:
 li a7, SYS_link
 322:	48cd                	li	a7,19
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 32a:	48d1                	li	a7,20
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 332:	48a5                	li	a7,9
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <dup>:
.global dup
dup:
 li a7, SYS_dup
 33a:	48a9                	li	a7,10
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 342:	48ad                	li	a7,11
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 34a:	48b1                	li	a7,12
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <pause>:
.global pause
pause:
 li a7, SYS_pause
 352:	48b5                	li	a7,13
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 35a:	48b9                	li	a7,14
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <getprocsinfo>:
.global getprocsinfo
getprocsinfo:
 li a7, SYS_getprocsinfo
 362:	48d9                	li	a7,22
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 36a:	48dd                	li	a7,23
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <sleep2>:
.global sleep2
sleep2:
 li a7, SYS_sleep2
 372:	48e1                	li	a7,24
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <signal>:
.global signal
signal:
 li a7, SYS_signal
 37a:	48e5                	li	a7,25
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 382:	1101                	addi	sp,sp,-32
 384:	ec06                	sd	ra,24(sp)
 386:	e822                	sd	s0,16(sp)
 388:	1000                	addi	s0,sp,32
 38a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 38e:	4605                	li	a2,1
 390:	fef40593          	addi	a1,s0,-17
 394:	f4fff0ef          	jal	2e2 <write>
}
 398:	60e2                	ld	ra,24(sp)
 39a:	6442                	ld	s0,16(sp)
 39c:	6105                	addi	sp,sp,32
 39e:	8082                	ret

00000000000003a0 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3a0:	715d                	addi	sp,sp,-80
 3a2:	e486                	sd	ra,72(sp)
 3a4:	e0a2                	sd	s0,64(sp)
 3a6:	f84a                	sd	s2,48(sp)
 3a8:	0880                	addi	s0,sp,80
 3aa:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3ac:	c299                	beqz	a3,3b2 <printint+0x12>
 3ae:	0805c363          	bltz	a1,434 <printint+0x94>
  neg = 0;
 3b2:	4881                	li	a7,0
 3b4:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3b8:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3ba:	00000517          	auipc	a0,0x0
 3be:	51e50513          	addi	a0,a0,1310 # 8d8 <digits>
 3c2:	883e                	mv	a6,a5
 3c4:	2785                	addiw	a5,a5,1
 3c6:	02c5f733          	remu	a4,a1,a2
 3ca:	972a                	add	a4,a4,a0
 3cc:	00074703          	lbu	a4,0(a4)
 3d0:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 3d4:	872e                	mv	a4,a1
 3d6:	02c5d5b3          	divu	a1,a1,a2
 3da:	0685                	addi	a3,a3,1
 3dc:	fec773e3          	bgeu	a4,a2,3c2 <printint+0x22>
  if(neg)
 3e0:	00088b63          	beqz	a7,3f6 <printint+0x56>
    buf[i++] = '-';
 3e4:	fd078793          	addi	a5,a5,-48
 3e8:	97a2                	add	a5,a5,s0
 3ea:	02d00713          	li	a4,45
 3ee:	fee78423          	sb	a4,-24(a5)
 3f2:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 3f6:	02f05a63          	blez	a5,42a <printint+0x8a>
 3fa:	fc26                	sd	s1,56(sp)
 3fc:	f44e                	sd	s3,40(sp)
 3fe:	fb840713          	addi	a4,s0,-72
 402:	00f704b3          	add	s1,a4,a5
 406:	fff70993          	addi	s3,a4,-1
 40a:	99be                	add	s3,s3,a5
 40c:	37fd                	addiw	a5,a5,-1
 40e:	1782                	slli	a5,a5,0x20
 410:	9381                	srli	a5,a5,0x20
 412:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 416:	fff4c583          	lbu	a1,-1(s1)
 41a:	854a                	mv	a0,s2
 41c:	f67ff0ef          	jal	382 <putc>
  while(--i >= 0)
 420:	14fd                	addi	s1,s1,-1
 422:	ff349ae3          	bne	s1,s3,416 <printint+0x76>
 426:	74e2                	ld	s1,56(sp)
 428:	79a2                	ld	s3,40(sp)
}
 42a:	60a6                	ld	ra,72(sp)
 42c:	6406                	ld	s0,64(sp)
 42e:	7942                	ld	s2,48(sp)
 430:	6161                	addi	sp,sp,80
 432:	8082                	ret
    x = -xx;
 434:	40b005b3          	neg	a1,a1
    neg = 1;
 438:	4885                	li	a7,1
    x = -xx;
 43a:	bfad                	j	3b4 <printint+0x14>

000000000000043c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 43c:	711d                	addi	sp,sp,-96
 43e:	ec86                	sd	ra,88(sp)
 440:	e8a2                	sd	s0,80(sp)
 442:	e0ca                	sd	s2,64(sp)
 444:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 446:	0005c903          	lbu	s2,0(a1)
 44a:	28090663          	beqz	s2,6d6 <vprintf+0x29a>
 44e:	e4a6                	sd	s1,72(sp)
 450:	fc4e                	sd	s3,56(sp)
 452:	f852                	sd	s4,48(sp)
 454:	f456                	sd	s5,40(sp)
 456:	f05a                	sd	s6,32(sp)
 458:	ec5e                	sd	s7,24(sp)
 45a:	e862                	sd	s8,16(sp)
 45c:	e466                	sd	s9,8(sp)
 45e:	8b2a                	mv	s6,a0
 460:	8a2e                	mv	s4,a1
 462:	8bb2                	mv	s7,a2
  state = 0;
 464:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 466:	4481                	li	s1,0
 468:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 46a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 46e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 472:	06c00c93          	li	s9,108
 476:	a005                	j	496 <vprintf+0x5a>
        putc(fd, c0);
 478:	85ca                	mv	a1,s2
 47a:	855a                	mv	a0,s6
 47c:	f07ff0ef          	jal	382 <putc>
 480:	a019                	j	486 <vprintf+0x4a>
    } else if(state == '%'){
 482:	03598263          	beq	s3,s5,4a6 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 486:	2485                	addiw	s1,s1,1
 488:	8726                	mv	a4,s1
 48a:	009a07b3          	add	a5,s4,s1
 48e:	0007c903          	lbu	s2,0(a5)
 492:	22090a63          	beqz	s2,6c6 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 496:	0009079b          	sext.w	a5,s2
    if(state == 0){
 49a:	fe0994e3          	bnez	s3,482 <vprintf+0x46>
      if(c0 == '%'){
 49e:	fd579de3          	bne	a5,s5,478 <vprintf+0x3c>
        state = '%';
 4a2:	89be                	mv	s3,a5
 4a4:	b7cd                	j	486 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4a6:	00ea06b3          	add	a3,s4,a4
 4aa:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4ae:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4b0:	c681                	beqz	a3,4b8 <vprintf+0x7c>
 4b2:	9752                	add	a4,a4,s4
 4b4:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4b8:	05878363          	beq	a5,s8,4fe <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 4bc:	05978d63          	beq	a5,s9,516 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4c0:	07500713          	li	a4,117
 4c4:	0ee78763          	beq	a5,a4,5b2 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4c8:	07800713          	li	a4,120
 4cc:	12e78963          	beq	a5,a4,5fe <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4d0:	07000713          	li	a4,112
 4d4:	14e78e63          	beq	a5,a4,630 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 4d8:	06300713          	li	a4,99
 4dc:	18e78e63          	beq	a5,a4,678 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 4e0:	07300713          	li	a4,115
 4e4:	1ae78463          	beq	a5,a4,68c <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4e8:	02500713          	li	a4,37
 4ec:	04e79563          	bne	a5,a4,536 <vprintf+0xfa>
        putc(fd, '%');
 4f0:	02500593          	li	a1,37
 4f4:	855a                	mv	a0,s6
 4f6:	e8dff0ef          	jal	382 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 4fa:	4981                	li	s3,0
 4fc:	b769                	j	486 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 4fe:	008b8913          	addi	s2,s7,8
 502:	4685                	li	a3,1
 504:	4629                	li	a2,10
 506:	000ba583          	lw	a1,0(s7)
 50a:	855a                	mv	a0,s6
 50c:	e95ff0ef          	jal	3a0 <printint>
 510:	8bca                	mv	s7,s2
      state = 0;
 512:	4981                	li	s3,0
 514:	bf8d                	j	486 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 516:	06400793          	li	a5,100
 51a:	02f68963          	beq	a3,a5,54c <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 51e:	06c00793          	li	a5,108
 522:	04f68263          	beq	a3,a5,566 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 526:	07500793          	li	a5,117
 52a:	0af68063          	beq	a3,a5,5ca <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 52e:	07800793          	li	a5,120
 532:	0ef68263          	beq	a3,a5,616 <vprintf+0x1da>
        putc(fd, '%');
 536:	02500593          	li	a1,37
 53a:	855a                	mv	a0,s6
 53c:	e47ff0ef          	jal	382 <putc>
        putc(fd, c0);
 540:	85ca                	mv	a1,s2
 542:	855a                	mv	a0,s6
 544:	e3fff0ef          	jal	382 <putc>
      state = 0;
 548:	4981                	li	s3,0
 54a:	bf35                	j	486 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 54c:	008b8913          	addi	s2,s7,8
 550:	4685                	li	a3,1
 552:	4629                	li	a2,10
 554:	000bb583          	ld	a1,0(s7)
 558:	855a                	mv	a0,s6
 55a:	e47ff0ef          	jal	3a0 <printint>
        i += 1;
 55e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 560:	8bca                	mv	s7,s2
      state = 0;
 562:	4981                	li	s3,0
        i += 1;
 564:	b70d                	j	486 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 566:	06400793          	li	a5,100
 56a:	02f60763          	beq	a2,a5,598 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 56e:	07500793          	li	a5,117
 572:	06f60963          	beq	a2,a5,5e4 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 576:	07800793          	li	a5,120
 57a:	faf61ee3          	bne	a2,a5,536 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 57e:	008b8913          	addi	s2,s7,8
 582:	4681                	li	a3,0
 584:	4641                	li	a2,16
 586:	000bb583          	ld	a1,0(s7)
 58a:	855a                	mv	a0,s6
 58c:	e15ff0ef          	jal	3a0 <printint>
        i += 2;
 590:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 592:	8bca                	mv	s7,s2
      state = 0;
 594:	4981                	li	s3,0
        i += 2;
 596:	bdc5                	j	486 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 598:	008b8913          	addi	s2,s7,8
 59c:	4685                	li	a3,1
 59e:	4629                	li	a2,10
 5a0:	000bb583          	ld	a1,0(s7)
 5a4:	855a                	mv	a0,s6
 5a6:	dfbff0ef          	jal	3a0 <printint>
        i += 2;
 5aa:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ac:	8bca                	mv	s7,s2
      state = 0;
 5ae:	4981                	li	s3,0
        i += 2;
 5b0:	bdd9                	j	486 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5b2:	008b8913          	addi	s2,s7,8
 5b6:	4681                	li	a3,0
 5b8:	4629                	li	a2,10
 5ba:	000be583          	lwu	a1,0(s7)
 5be:	855a                	mv	a0,s6
 5c0:	de1ff0ef          	jal	3a0 <printint>
 5c4:	8bca                	mv	s7,s2
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	bd7d                	j	486 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ca:	008b8913          	addi	s2,s7,8
 5ce:	4681                	li	a3,0
 5d0:	4629                	li	a2,10
 5d2:	000bb583          	ld	a1,0(s7)
 5d6:	855a                	mv	a0,s6
 5d8:	dc9ff0ef          	jal	3a0 <printint>
        i += 1;
 5dc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5de:	8bca                	mv	s7,s2
      state = 0;
 5e0:	4981                	li	s3,0
        i += 1;
 5e2:	b555                	j	486 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e4:	008b8913          	addi	s2,s7,8
 5e8:	4681                	li	a3,0
 5ea:	4629                	li	a2,10
 5ec:	000bb583          	ld	a1,0(s7)
 5f0:	855a                	mv	a0,s6
 5f2:	dafff0ef          	jal	3a0 <printint>
        i += 2;
 5f6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f8:	8bca                	mv	s7,s2
      state = 0;
 5fa:	4981                	li	s3,0
        i += 2;
 5fc:	b569                	j	486 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5fe:	008b8913          	addi	s2,s7,8
 602:	4681                	li	a3,0
 604:	4641                	li	a2,16
 606:	000be583          	lwu	a1,0(s7)
 60a:	855a                	mv	a0,s6
 60c:	d95ff0ef          	jal	3a0 <printint>
 610:	8bca                	mv	s7,s2
      state = 0;
 612:	4981                	li	s3,0
 614:	bd8d                	j	486 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 616:	008b8913          	addi	s2,s7,8
 61a:	4681                	li	a3,0
 61c:	4641                	li	a2,16
 61e:	000bb583          	ld	a1,0(s7)
 622:	855a                	mv	a0,s6
 624:	d7dff0ef          	jal	3a0 <printint>
        i += 1;
 628:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 62a:	8bca                	mv	s7,s2
      state = 0;
 62c:	4981                	li	s3,0
        i += 1;
 62e:	bda1                	j	486 <vprintf+0x4a>
 630:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 632:	008b8d13          	addi	s10,s7,8
 636:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 63a:	03000593          	li	a1,48
 63e:	855a                	mv	a0,s6
 640:	d43ff0ef          	jal	382 <putc>
  putc(fd, 'x');
 644:	07800593          	li	a1,120
 648:	855a                	mv	a0,s6
 64a:	d39ff0ef          	jal	382 <putc>
 64e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 650:	00000b97          	auipc	s7,0x0
 654:	288b8b93          	addi	s7,s7,648 # 8d8 <digits>
 658:	03c9d793          	srli	a5,s3,0x3c
 65c:	97de                	add	a5,a5,s7
 65e:	0007c583          	lbu	a1,0(a5)
 662:	855a                	mv	a0,s6
 664:	d1fff0ef          	jal	382 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 668:	0992                	slli	s3,s3,0x4
 66a:	397d                	addiw	s2,s2,-1
 66c:	fe0916e3          	bnez	s2,658 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 670:	8bea                	mv	s7,s10
      state = 0;
 672:	4981                	li	s3,0
 674:	6d02                	ld	s10,0(sp)
 676:	bd01                	j	486 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 678:	008b8913          	addi	s2,s7,8
 67c:	000bc583          	lbu	a1,0(s7)
 680:	855a                	mv	a0,s6
 682:	d01ff0ef          	jal	382 <putc>
 686:	8bca                	mv	s7,s2
      state = 0;
 688:	4981                	li	s3,0
 68a:	bbf5                	j	486 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 68c:	008b8993          	addi	s3,s7,8
 690:	000bb903          	ld	s2,0(s7)
 694:	00090f63          	beqz	s2,6b2 <vprintf+0x276>
        for(; *s; s++)
 698:	00094583          	lbu	a1,0(s2)
 69c:	c195                	beqz	a1,6c0 <vprintf+0x284>
          putc(fd, *s);
 69e:	855a                	mv	a0,s6
 6a0:	ce3ff0ef          	jal	382 <putc>
        for(; *s; s++)
 6a4:	0905                	addi	s2,s2,1
 6a6:	00094583          	lbu	a1,0(s2)
 6aa:	f9f5                	bnez	a1,69e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6ac:	8bce                	mv	s7,s3
      state = 0;
 6ae:	4981                	li	s3,0
 6b0:	bbd9                	j	486 <vprintf+0x4a>
          s = "(null)";
 6b2:	00000917          	auipc	s2,0x0
 6b6:	21e90913          	addi	s2,s2,542 # 8d0 <malloc+0x112>
        for(; *s; s++)
 6ba:	02800593          	li	a1,40
 6be:	b7c5                	j	69e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6c0:	8bce                	mv	s7,s3
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	b3c9                	j	486 <vprintf+0x4a>
 6c6:	64a6                	ld	s1,72(sp)
 6c8:	79e2                	ld	s3,56(sp)
 6ca:	7a42                	ld	s4,48(sp)
 6cc:	7aa2                	ld	s5,40(sp)
 6ce:	7b02                	ld	s6,32(sp)
 6d0:	6be2                	ld	s7,24(sp)
 6d2:	6c42                	ld	s8,16(sp)
 6d4:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6d6:	60e6                	ld	ra,88(sp)
 6d8:	6446                	ld	s0,80(sp)
 6da:	6906                	ld	s2,64(sp)
 6dc:	6125                	addi	sp,sp,96
 6de:	8082                	ret

00000000000006e0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6e0:	715d                	addi	sp,sp,-80
 6e2:	ec06                	sd	ra,24(sp)
 6e4:	e822                	sd	s0,16(sp)
 6e6:	1000                	addi	s0,sp,32
 6e8:	e010                	sd	a2,0(s0)
 6ea:	e414                	sd	a3,8(s0)
 6ec:	e818                	sd	a4,16(s0)
 6ee:	ec1c                	sd	a5,24(s0)
 6f0:	03043023          	sd	a6,32(s0)
 6f4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6f8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6fc:	8622                	mv	a2,s0
 6fe:	d3fff0ef          	jal	43c <vprintf>
}
 702:	60e2                	ld	ra,24(sp)
 704:	6442                	ld	s0,16(sp)
 706:	6161                	addi	sp,sp,80
 708:	8082                	ret

000000000000070a <printf>:

void
printf(const char *fmt, ...)
{
 70a:	711d                	addi	sp,sp,-96
 70c:	ec06                	sd	ra,24(sp)
 70e:	e822                	sd	s0,16(sp)
 710:	1000                	addi	s0,sp,32
 712:	e40c                	sd	a1,8(s0)
 714:	e810                	sd	a2,16(s0)
 716:	ec14                	sd	a3,24(s0)
 718:	f018                	sd	a4,32(s0)
 71a:	f41c                	sd	a5,40(s0)
 71c:	03043823          	sd	a6,48(s0)
 720:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 724:	00840613          	addi	a2,s0,8
 728:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 72c:	85aa                	mv	a1,a0
 72e:	4505                	li	a0,1
 730:	d0dff0ef          	jal	43c <vprintf>
}
 734:	60e2                	ld	ra,24(sp)
 736:	6442                	ld	s0,16(sp)
 738:	6125                	addi	sp,sp,96
 73a:	8082                	ret

000000000000073c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 73c:	1141                	addi	sp,sp,-16
 73e:	e422                	sd	s0,8(sp)
 740:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 742:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 746:	00001797          	auipc	a5,0x1
 74a:	8ba7b783          	ld	a5,-1862(a5) # 1000 <freep>
 74e:	a02d                	j	778 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 750:	4618                	lw	a4,8(a2)
 752:	9f2d                	addw	a4,a4,a1
 754:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 758:	6398                	ld	a4,0(a5)
 75a:	6310                	ld	a2,0(a4)
 75c:	a83d                	j	79a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 75e:	ff852703          	lw	a4,-8(a0)
 762:	9f31                	addw	a4,a4,a2
 764:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 766:	ff053683          	ld	a3,-16(a0)
 76a:	a091                	j	7ae <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 76c:	6398                	ld	a4,0(a5)
 76e:	00e7e463          	bltu	a5,a4,776 <free+0x3a>
 772:	00e6ea63          	bltu	a3,a4,786 <free+0x4a>
{
 776:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 778:	fed7fae3          	bgeu	a5,a3,76c <free+0x30>
 77c:	6398                	ld	a4,0(a5)
 77e:	00e6e463          	bltu	a3,a4,786 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 782:	fee7eae3          	bltu	a5,a4,776 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 786:	ff852583          	lw	a1,-8(a0)
 78a:	6390                	ld	a2,0(a5)
 78c:	02059813          	slli	a6,a1,0x20
 790:	01c85713          	srli	a4,a6,0x1c
 794:	9736                	add	a4,a4,a3
 796:	fae60de3          	beq	a2,a4,750 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 79a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 79e:	4790                	lw	a2,8(a5)
 7a0:	02061593          	slli	a1,a2,0x20
 7a4:	01c5d713          	srli	a4,a1,0x1c
 7a8:	973e                	add	a4,a4,a5
 7aa:	fae68ae3          	beq	a3,a4,75e <free+0x22>
    p->s.ptr = bp->s.ptr;
 7ae:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7b0:	00001717          	auipc	a4,0x1
 7b4:	84f73823          	sd	a5,-1968(a4) # 1000 <freep>
}
 7b8:	6422                	ld	s0,8(sp)
 7ba:	0141                	addi	sp,sp,16
 7bc:	8082                	ret

00000000000007be <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7be:	7139                	addi	sp,sp,-64
 7c0:	fc06                	sd	ra,56(sp)
 7c2:	f822                	sd	s0,48(sp)
 7c4:	f426                	sd	s1,40(sp)
 7c6:	ec4e                	sd	s3,24(sp)
 7c8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7ca:	02051493          	slli	s1,a0,0x20
 7ce:	9081                	srli	s1,s1,0x20
 7d0:	04bd                	addi	s1,s1,15
 7d2:	8091                	srli	s1,s1,0x4
 7d4:	0014899b          	addiw	s3,s1,1
 7d8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7da:	00001517          	auipc	a0,0x1
 7de:	82653503          	ld	a0,-2010(a0) # 1000 <freep>
 7e2:	c915                	beqz	a0,816 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7e6:	4798                	lw	a4,8(a5)
 7e8:	08977a63          	bgeu	a4,s1,87c <malloc+0xbe>
 7ec:	f04a                	sd	s2,32(sp)
 7ee:	e852                	sd	s4,16(sp)
 7f0:	e456                	sd	s5,8(sp)
 7f2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7f4:	8a4e                	mv	s4,s3
 7f6:	0009871b          	sext.w	a4,s3
 7fa:	6685                	lui	a3,0x1
 7fc:	00d77363          	bgeu	a4,a3,802 <malloc+0x44>
 800:	6a05                	lui	s4,0x1
 802:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 806:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 80a:	00000917          	auipc	s2,0x0
 80e:	7f690913          	addi	s2,s2,2038 # 1000 <freep>
  if(p == SBRK_ERROR)
 812:	5afd                	li	s5,-1
 814:	a081                	j	854 <malloc+0x96>
 816:	f04a                	sd	s2,32(sp)
 818:	e852                	sd	s4,16(sp)
 81a:	e456                	sd	s5,8(sp)
 81c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 81e:	00000797          	auipc	a5,0x0
 822:	7f278793          	addi	a5,a5,2034 # 1010 <base>
 826:	00000717          	auipc	a4,0x0
 82a:	7cf73d23          	sd	a5,2010(a4) # 1000 <freep>
 82e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 830:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 834:	b7c1                	j	7f4 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 836:	6398                	ld	a4,0(a5)
 838:	e118                	sd	a4,0(a0)
 83a:	a8a9                	j	894 <malloc+0xd6>
  hp->s.size = nu;
 83c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 840:	0541                	addi	a0,a0,16
 842:	efbff0ef          	jal	73c <free>
  return freep;
 846:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 84a:	c12d                	beqz	a0,8ac <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 84c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 84e:	4798                	lw	a4,8(a5)
 850:	02977263          	bgeu	a4,s1,874 <malloc+0xb6>
    if(p == freep)
 854:	00093703          	ld	a4,0(s2)
 858:	853e                	mv	a0,a5
 85a:	fef719e3          	bne	a4,a5,84c <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 85e:	8552                	mv	a0,s4
 860:	a2fff0ef          	jal	28e <sbrk>
  if(p == SBRK_ERROR)
 864:	fd551ce3          	bne	a0,s5,83c <malloc+0x7e>
        return 0;
 868:	4501                	li	a0,0
 86a:	7902                	ld	s2,32(sp)
 86c:	6a42                	ld	s4,16(sp)
 86e:	6aa2                	ld	s5,8(sp)
 870:	6b02                	ld	s6,0(sp)
 872:	a03d                	j	8a0 <malloc+0xe2>
 874:	7902                	ld	s2,32(sp)
 876:	6a42                	ld	s4,16(sp)
 878:	6aa2                	ld	s5,8(sp)
 87a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 87c:	fae48de3          	beq	s1,a4,836 <malloc+0x78>
        p->s.size -= nunits;
 880:	4137073b          	subw	a4,a4,s3
 884:	c798                	sw	a4,8(a5)
        p += p->s.size;
 886:	02071693          	slli	a3,a4,0x20
 88a:	01c6d713          	srli	a4,a3,0x1c
 88e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 890:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 894:	00000717          	auipc	a4,0x0
 898:	76a73623          	sd	a0,1900(a4) # 1000 <freep>
      return (void*)(p + 1);
 89c:	01078513          	addi	a0,a5,16
  }
}
 8a0:	70e2                	ld	ra,56(sp)
 8a2:	7442                	ld	s0,48(sp)
 8a4:	74a2                	ld	s1,40(sp)
 8a6:	69e2                	ld	s3,24(sp)
 8a8:	6121                	addi	sp,sp,64
 8aa:	8082                	ret
 8ac:	7902                	ld	s2,32(sp)
 8ae:	6a42                	ld	s4,16(sp)
 8b0:	6aa2                	ld	s5,8(sp)
 8b2:	6b02                	ld	s6,0(sp)
 8b4:	b7f5                	j	8a0 <malloc+0xe2>
