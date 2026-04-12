
user/_init:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   c:	4589                	li	a1,2
   e:	00001517          	auipc	a0,0x1
  12:	9f250513          	addi	a0,a0,-1550 # a00 <malloc+0xfa>
  16:	428000ef          	jal	43e <open>
  1a:	04054563          	bltz	a0,64 <main+0x64>
    mknod("console", CONSOLE, 0);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  1e:	4501                	li	a0,0
  20:	456000ef          	jal	476 <dup>
  dup(0);  // stderr
  24:	4501                	li	a0,0
  26:	450000ef          	jal	476 <dup>

  for(;;){
    printf("init: starting sh\n");
  2a:	00001917          	auipc	s2,0x1
  2e:	9de90913          	addi	s2,s2,-1570 # a08 <malloc+0x102>
  32:	854a                	mv	a0,s2
  34:	01b000ef          	jal	84e <printf>
    pid = fork();
  38:	332000ef          	jal	36a <fork>
  3c:	84aa                	mv	s1,a0
    if(pid < 0){
  3e:	04054363          	bltz	a0,84 <main+0x84>
      printf("init: fork failed\n");
      exit(1);
    }
    if(pid == 0){
  42:	c931                	beqz	a0,96 <main+0x96>
    }

    for(;;){
      // this call to wait() returns if the shell exits,
      // or if a parentless process exits.
      wpid = wait((int *) 0);
  44:	4501                	li	a0,0
  46:	334000ef          	jal	37a <wait>
      if(wpid == pid){
  4a:	fea484e3          	beq	s1,a0,32 <main+0x32>
        // the shell exited; restart it.
        break;
      } else if(wpid < 0){
  4e:	fe055be3          	bgez	a0,44 <main+0x44>
        printf("init: wait returned an error\n");
  52:	00001517          	auipc	a0,0x1
  56:	a0650513          	addi	a0,a0,-1530 # a58 <malloc+0x152>
  5a:	7f4000ef          	jal	84e <printf>
        exit(1);
  5e:	4505                	li	a0,1
  60:	312000ef          	jal	372 <exit>
    mknod("console", CONSOLE, 0);
  64:	4601                	li	a2,0
  66:	4585                	li	a1,1
  68:	00001517          	auipc	a0,0x1
  6c:	99850513          	addi	a0,a0,-1640 # a00 <malloc+0xfa>
  70:	3d6000ef          	jal	446 <mknod>
    open("console", O_RDWR);
  74:	4589                	li	a1,2
  76:	00001517          	auipc	a0,0x1
  7a:	98a50513          	addi	a0,a0,-1654 # a00 <malloc+0xfa>
  7e:	3c0000ef          	jal	43e <open>
  82:	bf71                	j	1e <main+0x1e>
      printf("init: fork failed\n");
  84:	00001517          	auipc	a0,0x1
  88:	99c50513          	addi	a0,a0,-1636 # a20 <malloc+0x11a>
  8c:	7c2000ef          	jal	84e <printf>
      exit(1);
  90:	4505                	li	a0,1
  92:	2e0000ef          	jal	372 <exit>
      exec("sh", argv);
  96:	00001597          	auipc	a1,0x1
  9a:	f6a58593          	addi	a1,a1,-150 # 1000 <argv>
  9e:	00001517          	auipc	a0,0x1
  a2:	99a50513          	addi	a0,a0,-1638 # a38 <malloc+0x132>
  a6:	390000ef          	jal	436 <exec>
      printf("init: exec sh failed\n");
  aa:	00001517          	auipc	a0,0x1
  ae:	99650513          	addi	a0,a0,-1642 # a40 <malloc+0x13a>
  b2:	79c000ef          	jal	84e <printf>
      exit(1);
  b6:	4505                	li	a0,1
  b8:	2ba000ef          	jal	372 <exit>

00000000000000bc <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  bc:	1141                	addi	sp,sp,-16
  be:	e406                	sd	ra,8(sp)
  c0:	e022                	sd	s0,0(sp)
  c2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  c4:	f3dff0ef          	jal	0 <main>
  exit(r);
  c8:	2aa000ef          	jal	372 <exit>

00000000000000cc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e406                	sd	ra,8(sp)
  d0:	e022                	sd	s0,0(sp)
  d2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  d4:	87aa                	mv	a5,a0
  d6:	0585                	addi	a1,a1,1
  d8:	0785                	addi	a5,a5,1
  da:	fff5c703          	lbu	a4,-1(a1)
  de:	fee78fa3          	sb	a4,-1(a5)
  e2:	fb75                	bnez	a4,d6 <strcpy+0xa>
    ;
  return os;
}
  e4:	60a2                	ld	ra,8(sp)
  e6:	6402                	ld	s0,0(sp)
  e8:	0141                	addi	sp,sp,16
  ea:	8082                	ret

00000000000000ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ec:	1141                	addi	sp,sp,-16
  ee:	e406                	sd	ra,8(sp)
  f0:	e022                	sd	s0,0(sp)
  f2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  f4:	00054783          	lbu	a5,0(a0)
  f8:	cb91                	beqz	a5,10c <strcmp+0x20>
  fa:	0005c703          	lbu	a4,0(a1)
  fe:	00f71763          	bne	a4,a5,10c <strcmp+0x20>
    p++, q++;
 102:	0505                	addi	a0,a0,1
 104:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 106:	00054783          	lbu	a5,0(a0)
 10a:	fbe5                	bnez	a5,fa <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 10c:	0005c503          	lbu	a0,0(a1)
}
 110:	40a7853b          	subw	a0,a5,a0
 114:	60a2                	ld	ra,8(sp)
 116:	6402                	ld	s0,0(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret

000000000000011c <strlen>:

uint
strlen(const char *s)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e406                	sd	ra,8(sp)
 120:	e022                	sd	s0,0(sp)
 122:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 124:	00054783          	lbu	a5,0(a0)
 128:	cf91                	beqz	a5,144 <strlen+0x28>
 12a:	00150793          	addi	a5,a0,1
 12e:	86be                	mv	a3,a5
 130:	0785                	addi	a5,a5,1
 132:	fff7c703          	lbu	a4,-1(a5)
 136:	ff65                	bnez	a4,12e <strlen+0x12>
 138:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 13c:	60a2                	ld	ra,8(sp)
 13e:	6402                	ld	s0,0(sp)
 140:	0141                	addi	sp,sp,16
 142:	8082                	ret
  for(n = 0; s[n]; n++)
 144:	4501                	li	a0,0
 146:	bfdd                	j	13c <strlen+0x20>

0000000000000148 <memset>:

void*
memset(void *dst, int c, uint n)
{
 148:	1141                	addi	sp,sp,-16
 14a:	e406                	sd	ra,8(sp)
 14c:	e022                	sd	s0,0(sp)
 14e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 150:	ca19                	beqz	a2,166 <memset+0x1e>
 152:	87aa                	mv	a5,a0
 154:	1602                	slli	a2,a2,0x20
 156:	9201                	srli	a2,a2,0x20
 158:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 15c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 160:	0785                	addi	a5,a5,1
 162:	fee79de3          	bne	a5,a4,15c <memset+0x14>
  }
  return dst;
}
 166:	60a2                	ld	ra,8(sp)
 168:	6402                	ld	s0,0(sp)
 16a:	0141                	addi	sp,sp,16
 16c:	8082                	ret

000000000000016e <strchr>:

char*
strchr(const char *s, char c)
{
 16e:	1141                	addi	sp,sp,-16
 170:	e406                	sd	ra,8(sp)
 172:	e022                	sd	s0,0(sp)
 174:	0800                	addi	s0,sp,16
  for(; *s; s++)
 176:	00054783          	lbu	a5,0(a0)
 17a:	cf81                	beqz	a5,192 <strchr+0x24>
    if(*s == c)
 17c:	00f58763          	beq	a1,a5,18a <strchr+0x1c>
  for(; *s; s++)
 180:	0505                	addi	a0,a0,1
 182:	00054783          	lbu	a5,0(a0)
 186:	fbfd                	bnez	a5,17c <strchr+0xe>
      return (char*)s;
  return 0;
 188:	4501                	li	a0,0
}
 18a:	60a2                	ld	ra,8(sp)
 18c:	6402                	ld	s0,0(sp)
 18e:	0141                	addi	sp,sp,16
 190:	8082                	ret
  return 0;
 192:	4501                	li	a0,0
 194:	bfdd                	j	18a <strchr+0x1c>

0000000000000196 <gets>:

char*
gets(char *buf, int max)
{
 196:	711d                	addi	sp,sp,-96
 198:	ec86                	sd	ra,88(sp)
 19a:	e8a2                	sd	s0,80(sp)
 19c:	e4a6                	sd	s1,72(sp)
 19e:	e0ca                	sd	s2,64(sp)
 1a0:	fc4e                	sd	s3,56(sp)
 1a2:	f852                	sd	s4,48(sp)
 1a4:	f456                	sd	s5,40(sp)
 1a6:	f05a                	sd	s6,32(sp)
 1a8:	ec5e                	sd	s7,24(sp)
 1aa:	e862                	sd	s8,16(sp)
 1ac:	1080                	addi	s0,sp,96
 1ae:	8baa                	mv	s7,a0
 1b0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b2:	892a                	mv	s2,a0
 1b4:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1b6:	faf40b13          	addi	s6,s0,-81
 1ba:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1bc:	8c26                	mv	s8,s1
 1be:	0014899b          	addiw	s3,s1,1
 1c2:	84ce                	mv	s1,s3
 1c4:	0349d463          	bge	s3,s4,1ec <gets+0x56>
    cc = read(0, &c, 1);
 1c8:	8656                	mv	a2,s5
 1ca:	85da                	mv	a1,s6
 1cc:	4501                	li	a0,0
 1ce:	1bc000ef          	jal	38a <read>
    if(cc < 1)
 1d2:	00a05d63          	blez	a0,1ec <gets+0x56>
      break;
    buf[i++] = c;
 1d6:	faf44783          	lbu	a5,-81(s0)
 1da:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1de:	0905                	addi	s2,s2,1
 1e0:	ff678713          	addi	a4,a5,-10
 1e4:	c319                	beqz	a4,1ea <gets+0x54>
 1e6:	17cd                	addi	a5,a5,-13
 1e8:	fbf1                	bnez	a5,1bc <gets+0x26>
    buf[i++] = c;
 1ea:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1ec:	9c5e                	add	s8,s8,s7
 1ee:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1f2:	855e                	mv	a0,s7
 1f4:	60e6                	ld	ra,88(sp)
 1f6:	6446                	ld	s0,80(sp)
 1f8:	64a6                	ld	s1,72(sp)
 1fa:	6906                	ld	s2,64(sp)
 1fc:	79e2                	ld	s3,56(sp)
 1fe:	7a42                	ld	s4,48(sp)
 200:	7aa2                	ld	s5,40(sp)
 202:	7b02                	ld	s6,32(sp)
 204:	6be2                	ld	s7,24(sp)
 206:	6c42                	ld	s8,16(sp)
 208:	6125                	addi	sp,sp,96
 20a:	8082                	ret

000000000000020c <stat>:

int
stat(const char *n, struct stat *st)
{
 20c:	1101                	addi	sp,sp,-32
 20e:	ec06                	sd	ra,24(sp)
 210:	e822                	sd	s0,16(sp)
 212:	e04a                	sd	s2,0(sp)
 214:	1000                	addi	s0,sp,32
 216:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 218:	4581                	li	a1,0
 21a:	224000ef          	jal	43e <open>
  if(fd < 0)
 21e:	02054263          	bltz	a0,242 <stat+0x36>
 222:	e426                	sd	s1,8(sp)
 224:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 226:	85ca                	mv	a1,s2
 228:	22e000ef          	jal	456 <fstat>
 22c:	892a                	mv	s2,a0
  close(fd);
 22e:	8526                	mv	a0,s1
 230:	16a000ef          	jal	39a <close>
  return r;
 234:	64a2                	ld	s1,8(sp)
}
 236:	854a                	mv	a0,s2
 238:	60e2                	ld	ra,24(sp)
 23a:	6442                	ld	s0,16(sp)
 23c:	6902                	ld	s2,0(sp)
 23e:	6105                	addi	sp,sp,32
 240:	8082                	ret
    return -1;
 242:	57fd                	li	a5,-1
 244:	893e                	mv	s2,a5
 246:	bfc5                	j	236 <stat+0x2a>

0000000000000248 <atoi>:

int
atoi(const char *s)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e406                	sd	ra,8(sp)
 24c:	e022                	sd	s0,0(sp)
 24e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 250:	00054683          	lbu	a3,0(a0)
 254:	fd06879b          	addiw	a5,a3,-48
 258:	0ff7f793          	zext.b	a5,a5
 25c:	4625                	li	a2,9
 25e:	02f66963          	bltu	a2,a5,290 <atoi+0x48>
 262:	872a                	mv	a4,a0
  n = 0;
 264:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 266:	0705                	addi	a4,a4,1
 268:	0025179b          	slliw	a5,a0,0x2
 26c:	9fa9                	addw	a5,a5,a0
 26e:	0017979b          	slliw	a5,a5,0x1
 272:	9fb5                	addw	a5,a5,a3
 274:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 278:	00074683          	lbu	a3,0(a4)
 27c:	fd06879b          	addiw	a5,a3,-48
 280:	0ff7f793          	zext.b	a5,a5
 284:	fef671e3          	bgeu	a2,a5,266 <atoi+0x1e>
  return n;
}
 288:	60a2                	ld	ra,8(sp)
 28a:	6402                	ld	s0,0(sp)
 28c:	0141                	addi	sp,sp,16
 28e:	8082                	ret
  n = 0;
 290:	4501                	li	a0,0
 292:	bfdd                	j	288 <atoi+0x40>

0000000000000294 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 294:	1141                	addi	sp,sp,-16
 296:	e406                	sd	ra,8(sp)
 298:	e022                	sd	s0,0(sp)
 29a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 29c:	02b57563          	bgeu	a0,a1,2c6 <memmove+0x32>
    while(n-- > 0)
 2a0:	00c05f63          	blez	a2,2be <memmove+0x2a>
 2a4:	1602                	slli	a2,a2,0x20
 2a6:	9201                	srli	a2,a2,0x20
 2a8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ac:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ae:	0585                	addi	a1,a1,1
 2b0:	0705                	addi	a4,a4,1
 2b2:	fff5c683          	lbu	a3,-1(a1)
 2b6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2ba:	fee79ae3          	bne	a5,a4,2ae <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2be:	60a2                	ld	ra,8(sp)
 2c0:	6402                	ld	s0,0(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret
    while(n-- > 0)
 2c6:	fec05ce3          	blez	a2,2be <memmove+0x2a>
    dst += n;
 2ca:	00c50733          	add	a4,a0,a2
    src += n;
 2ce:	95b2                	add	a1,a1,a2
 2d0:	fff6079b          	addiw	a5,a2,-1
 2d4:	1782                	slli	a5,a5,0x20
 2d6:	9381                	srli	a5,a5,0x20
 2d8:	fff7c793          	not	a5,a5
 2dc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2de:	15fd                	addi	a1,a1,-1
 2e0:	177d                	addi	a4,a4,-1
 2e2:	0005c683          	lbu	a3,0(a1)
 2e6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ea:	fef71ae3          	bne	a4,a5,2de <memmove+0x4a>
 2ee:	bfc1                	j	2be <memmove+0x2a>

00000000000002f0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e406                	sd	ra,8(sp)
 2f4:	e022                	sd	s0,0(sp)
 2f6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2f8:	c61d                	beqz	a2,326 <memcmp+0x36>
 2fa:	1602                	slli	a2,a2,0x20
 2fc:	9201                	srli	a2,a2,0x20
 2fe:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 302:	00054783          	lbu	a5,0(a0)
 306:	0005c703          	lbu	a4,0(a1)
 30a:	00e79863          	bne	a5,a4,31a <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 30e:	0505                	addi	a0,a0,1
    p2++;
 310:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 312:	fed518e3          	bne	a0,a3,302 <memcmp+0x12>
  }
  return 0;
 316:	4501                	li	a0,0
 318:	a019                	j	31e <memcmp+0x2e>
      return *p1 - *p2;
 31a:	40e7853b          	subw	a0,a5,a4
}
 31e:	60a2                	ld	ra,8(sp)
 320:	6402                	ld	s0,0(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret
  return 0;
 326:	4501                	li	a0,0
 328:	bfdd                	j	31e <memcmp+0x2e>

000000000000032a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e406                	sd	ra,8(sp)
 32e:	e022                	sd	s0,0(sp)
 330:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 332:	f63ff0ef          	jal	294 <memmove>
}
 336:	60a2                	ld	ra,8(sp)
 338:	6402                	ld	s0,0(sp)
 33a:	0141                	addi	sp,sp,16
 33c:	8082                	ret

000000000000033e <sbrk>:

char *
sbrk(int n) {
 33e:	1141                	addi	sp,sp,-16
 340:	e406                	sd	ra,8(sp)
 342:	e022                	sd	s0,0(sp)
 344:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 346:	4585                	li	a1,1
 348:	13e000ef          	jal	486 <sys_sbrk>
}
 34c:	60a2                	ld	ra,8(sp)
 34e:	6402                	ld	s0,0(sp)
 350:	0141                	addi	sp,sp,16
 352:	8082                	ret

0000000000000354 <sbrklazy>:

char *
sbrklazy(int n) {
 354:	1141                	addi	sp,sp,-16
 356:	e406                	sd	ra,8(sp)
 358:	e022                	sd	s0,0(sp)
 35a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 35c:	4589                	li	a1,2
 35e:	128000ef          	jal	486 <sys_sbrk>
}
 362:	60a2                	ld	ra,8(sp)
 364:	6402                	ld	s0,0(sp)
 366:	0141                	addi	sp,sp,16
 368:	8082                	ret

000000000000036a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 36a:	4885                	li	a7,1
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <exit>:
.global exit
exit:
 li a7, SYS_exit
 372:	4889                	li	a7,2
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <wait>:
.global wait
wait:
 li a7, SYS_wait
 37a:	488d                	li	a7,3
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 382:	4891                	li	a7,4
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <read>:
.global read
read:
 li a7, SYS_read
 38a:	4895                	li	a7,5
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <write>:
.global write
write:
 li a7, SYS_write
 392:	48c1                	li	a7,16
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <close>:
.global close
close:
 li a7, SYS_close
 39a:	48d5                	li	a7,21
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 3a2:	48d9                	li	a7,22
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <shmat>:
.global shmat
shmat:
 li a7, SYS_shmat
 3aa:	48dd                	li	a7,23
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 3b2:	48e1                	li	a7,24
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 3ba:	48e5                	li	a7,25
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <lockinit>:
.global lockinit
lockinit:
 li a7, SYS_lockinit
 3c2:	48e9                	li	a7,26
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <lockacquire>:
.global lockacquire
lockacquire:
 li a7, SYS_lockacquire
 3ca:	48ed                	li	a7,27
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <lockrelease>:
.global lockrelease
lockrelease:
 li a7, SYS_lockrelease
 3d2:	48f1                	li	a7,28
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <locktry>:
.global locktry
locktry:
 li a7, SYS_locktry
 3da:	48f5                	li	a7,29
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <lockcheck>:
.global lockcheck
lockcheck:
 li a7, SYS_lockcheck
 3e2:	48f9                	li	a7,30
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <sendmsg>:
.global sendmsg
sendmsg:
 li a7, SYS_sendmsg
 3ea:	48fd                	li	a7,31
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <recvmsg>:
.global recvmsg
recvmsg:
 li a7, SYS_recvmsg
 3f2:	02000893          	li	a7,32
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <broadcast>:
.global broadcast
broadcast:
 li a7, SYS_broadcast
 3fc:	02100893          	li	a7,33
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <getprocsinfo>:
.global getprocsinfo
getprocsinfo:
 li a7, SYS_getprocsinfo
 406:	02200893          	li	a7,34
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 410:	02300893          	li	a7,35
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <sleep2>:
.global sleep2
sleep2:
 li a7, SYS_sleep2
 41a:	02400893          	li	a7,36
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <signal>:
.global signal
signal:
 li a7, SYS_signal
 424:	02500893          	li	a7,37
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <kill>:
.global kill
kill:
 li a7, SYS_kill
 42e:	4899                	li	a7,6
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <exec>:
.global exec
exec:
 li a7, SYS_exec
 436:	489d                	li	a7,7
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <open>:
.global open
open:
 li a7, SYS_open
 43e:	48bd                	li	a7,15
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 446:	48c5                	li	a7,17
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 44e:	48c9                	li	a7,18
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 456:	48a1                	li	a7,8
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <link>:
.global link
link:
 li a7, SYS_link
 45e:	48cd                	li	a7,19
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 466:	48d1                	li	a7,20
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 46e:	48a5                	li	a7,9
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <dup>:
.global dup
dup:
 li a7, SYS_dup
 476:	48a9                	li	a7,10
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 47e:	48ad                	li	a7,11
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 486:	48b1                	li	a7,12
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <pause>:
.global pause
pause:
 li a7, SYS_pause
 48e:	48b5                	li	a7,13
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 496:	48b9                	li	a7,14
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <setchildlimit>:
.global setchildlimit
setchildlimit:
 li a7, SYS_setchildlimit
 49e:	02600893          	li	a7,38
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4a8:	1101                	addi	sp,sp,-32
 4aa:	ec06                	sd	ra,24(sp)
 4ac:	e822                	sd	s0,16(sp)
 4ae:	1000                	addi	s0,sp,32
 4b0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4b4:	4605                	li	a2,1
 4b6:	fef40593          	addi	a1,s0,-17
 4ba:	ed9ff0ef          	jal	392 <write>
}
 4be:	60e2                	ld	ra,24(sp)
 4c0:	6442                	ld	s0,16(sp)
 4c2:	6105                	addi	sp,sp,32
 4c4:	8082                	ret

00000000000004c6 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4c6:	715d                	addi	sp,sp,-80
 4c8:	e486                	sd	ra,72(sp)
 4ca:	e0a2                	sd	s0,64(sp)
 4cc:	f84a                	sd	s2,48(sp)
 4ce:	f44e                	sd	s3,40(sp)
 4d0:	0880                	addi	s0,sp,80
 4d2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4d4:	c6d1                	beqz	a3,560 <printint+0x9a>
 4d6:	0805d563          	bgez	a1,560 <printint+0x9a>
    neg = 1;
    x = -xx;
 4da:	40b005b3          	neg	a1,a1
    neg = 1;
 4de:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 4e0:	fb840993          	addi	s3,s0,-72
  neg = 0;
 4e4:	86ce                	mv	a3,s3
  i = 0;
 4e6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4e8:	00000817          	auipc	a6,0x0
 4ec:	59880813          	addi	a6,a6,1432 # a80 <digits>
 4f0:	88ba                	mv	a7,a4
 4f2:	0017051b          	addiw	a0,a4,1
 4f6:	872a                	mv	a4,a0
 4f8:	02c5f7b3          	remu	a5,a1,a2
 4fc:	97c2                	add	a5,a5,a6
 4fe:	0007c783          	lbu	a5,0(a5)
 502:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 506:	87ae                	mv	a5,a1
 508:	02c5d5b3          	divu	a1,a1,a2
 50c:	0685                	addi	a3,a3,1
 50e:	fec7f1e3          	bgeu	a5,a2,4f0 <printint+0x2a>
  if(neg)
 512:	00030c63          	beqz	t1,52a <printint+0x64>
    buf[i++] = '-';
 516:	fd050793          	addi	a5,a0,-48
 51a:	00878533          	add	a0,a5,s0
 51e:	02d00793          	li	a5,45
 522:	fef50423          	sb	a5,-24(a0)
 526:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 52a:	02e05563          	blez	a4,554 <printint+0x8e>
 52e:	fc26                	sd	s1,56(sp)
 530:	377d                	addiw	a4,a4,-1
 532:	00e984b3          	add	s1,s3,a4
 536:	19fd                	addi	s3,s3,-1
 538:	99ba                	add	s3,s3,a4
 53a:	1702                	slli	a4,a4,0x20
 53c:	9301                	srli	a4,a4,0x20
 53e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 542:	0004c583          	lbu	a1,0(s1)
 546:	854a                	mv	a0,s2
 548:	f61ff0ef          	jal	4a8 <putc>
  while(--i >= 0)
 54c:	14fd                	addi	s1,s1,-1
 54e:	ff349ae3          	bne	s1,s3,542 <printint+0x7c>
 552:	74e2                	ld	s1,56(sp)
}
 554:	60a6                	ld	ra,72(sp)
 556:	6406                	ld	s0,64(sp)
 558:	7942                	ld	s2,48(sp)
 55a:	79a2                	ld	s3,40(sp)
 55c:	6161                	addi	sp,sp,80
 55e:	8082                	ret
  neg = 0;
 560:	4301                	li	t1,0
 562:	bfbd                	j	4e0 <printint+0x1a>

0000000000000564 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 564:	711d                	addi	sp,sp,-96
 566:	ec86                	sd	ra,88(sp)
 568:	e8a2                	sd	s0,80(sp)
 56a:	e4a6                	sd	s1,72(sp)
 56c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 56e:	0005c483          	lbu	s1,0(a1)
 572:	22048363          	beqz	s1,798 <vprintf+0x234>
 576:	e0ca                	sd	s2,64(sp)
 578:	fc4e                	sd	s3,56(sp)
 57a:	f852                	sd	s4,48(sp)
 57c:	f456                	sd	s5,40(sp)
 57e:	f05a                	sd	s6,32(sp)
 580:	ec5e                	sd	s7,24(sp)
 582:	e862                	sd	s8,16(sp)
 584:	8b2a                	mv	s6,a0
 586:	8a2e                	mv	s4,a1
 588:	8bb2                	mv	s7,a2
  state = 0;
 58a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 58c:	4901                	li	s2,0
 58e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 590:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 594:	06400c13          	li	s8,100
 598:	a00d                	j	5ba <vprintf+0x56>
        putc(fd, c0);
 59a:	85a6                	mv	a1,s1
 59c:	855a                	mv	a0,s6
 59e:	f0bff0ef          	jal	4a8 <putc>
 5a2:	a019                	j	5a8 <vprintf+0x44>
    } else if(state == '%'){
 5a4:	03598363          	beq	s3,s5,5ca <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 5a8:	0019079b          	addiw	a5,s2,1
 5ac:	893e                	mv	s2,a5
 5ae:	873e                	mv	a4,a5
 5b0:	97d2                	add	a5,a5,s4
 5b2:	0007c483          	lbu	s1,0(a5)
 5b6:	1c048a63          	beqz	s1,78a <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 5ba:	0004879b          	sext.w	a5,s1
    if(state == 0){
 5be:	fe0993e3          	bnez	s3,5a4 <vprintf+0x40>
      if(c0 == '%'){
 5c2:	fd579ce3          	bne	a5,s5,59a <vprintf+0x36>
        state = '%';
 5c6:	89be                	mv	s3,a5
 5c8:	b7c5                	j	5a8 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 5ca:	00ea06b3          	add	a3,s4,a4
 5ce:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 5d2:	1c060863          	beqz	a2,7a2 <vprintf+0x23e>
      if(c0 == 'd'){
 5d6:	03878763          	beq	a5,s8,604 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5da:	f9478693          	addi	a3,a5,-108
 5de:	0016b693          	seqz	a3,a3
 5e2:	f9c60593          	addi	a1,a2,-100
 5e6:	e99d                	bnez	a1,61c <vprintf+0xb8>
 5e8:	ca95                	beqz	a3,61c <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ea:	008b8493          	addi	s1,s7,8
 5ee:	4685                	li	a3,1
 5f0:	4629                	li	a2,10
 5f2:	000bb583          	ld	a1,0(s7)
 5f6:	855a                	mv	a0,s6
 5f8:	ecfff0ef          	jal	4c6 <printint>
        i += 1;
 5fc:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5fe:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 600:	4981                	li	s3,0
 602:	b75d                	j	5a8 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 604:	008b8493          	addi	s1,s7,8
 608:	4685                	li	a3,1
 60a:	4629                	li	a2,10
 60c:	000ba583          	lw	a1,0(s7)
 610:	855a                	mv	a0,s6
 612:	eb5ff0ef          	jal	4c6 <printint>
 616:	8ba6                	mv	s7,s1
      state = 0;
 618:	4981                	li	s3,0
 61a:	b779                	j	5a8 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 61c:	9752                	add	a4,a4,s4
 61e:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 622:	f9460713          	addi	a4,a2,-108
 626:	00173713          	seqz	a4,a4
 62a:	8f75                	and	a4,a4,a3
 62c:	f9c58513          	addi	a0,a1,-100
 630:	18051363          	bnez	a0,7b6 <vprintf+0x252>
 634:	18070163          	beqz	a4,7b6 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 638:	008b8493          	addi	s1,s7,8
 63c:	4685                	li	a3,1
 63e:	4629                	li	a2,10
 640:	000bb583          	ld	a1,0(s7)
 644:	855a                	mv	a0,s6
 646:	e81ff0ef          	jal	4c6 <printint>
        i += 2;
 64a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 64c:	8ba6                	mv	s7,s1
      state = 0;
 64e:	4981                	li	s3,0
        i += 2;
 650:	bfa1                	j	5a8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 652:	008b8493          	addi	s1,s7,8
 656:	4681                	li	a3,0
 658:	4629                	li	a2,10
 65a:	000be583          	lwu	a1,0(s7)
 65e:	855a                	mv	a0,s6
 660:	e67ff0ef          	jal	4c6 <printint>
 664:	8ba6                	mv	s7,s1
      state = 0;
 666:	4981                	li	s3,0
 668:	b781                	j	5a8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 66a:	008b8493          	addi	s1,s7,8
 66e:	4681                	li	a3,0
 670:	4629                	li	a2,10
 672:	000bb583          	ld	a1,0(s7)
 676:	855a                	mv	a0,s6
 678:	e4fff0ef          	jal	4c6 <printint>
        i += 1;
 67c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 67e:	8ba6                	mv	s7,s1
      state = 0;
 680:	4981                	li	s3,0
 682:	b71d                	j	5a8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 684:	008b8493          	addi	s1,s7,8
 688:	4681                	li	a3,0
 68a:	4629                	li	a2,10
 68c:	000bb583          	ld	a1,0(s7)
 690:	855a                	mv	a0,s6
 692:	e35ff0ef          	jal	4c6 <printint>
        i += 2;
 696:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 698:	8ba6                	mv	s7,s1
      state = 0;
 69a:	4981                	li	s3,0
        i += 2;
 69c:	b731                	j	5a8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 69e:	008b8493          	addi	s1,s7,8
 6a2:	4681                	li	a3,0
 6a4:	4641                	li	a2,16
 6a6:	000be583          	lwu	a1,0(s7)
 6aa:	855a                	mv	a0,s6
 6ac:	e1bff0ef          	jal	4c6 <printint>
 6b0:	8ba6                	mv	s7,s1
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	bdd5                	j	5a8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b6:	008b8493          	addi	s1,s7,8
 6ba:	4681                	li	a3,0
 6bc:	4641                	li	a2,16
 6be:	000bb583          	ld	a1,0(s7)
 6c2:	855a                	mv	a0,s6
 6c4:	e03ff0ef          	jal	4c6 <printint>
        i += 1;
 6c8:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ca:	8ba6                	mv	s7,s1
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	bde9                	j	5a8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d0:	008b8493          	addi	s1,s7,8
 6d4:	4681                	li	a3,0
 6d6:	4641                	li	a2,16
 6d8:	000bb583          	ld	a1,0(s7)
 6dc:	855a                	mv	a0,s6
 6de:	de9ff0ef          	jal	4c6 <printint>
        i += 2;
 6e2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e4:	8ba6                	mv	s7,s1
      state = 0;
 6e6:	4981                	li	s3,0
        i += 2;
 6e8:	b5c1                	j	5a8 <vprintf+0x44>
 6ea:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 6ec:	008b8793          	addi	a5,s7,8
 6f0:	8cbe                	mv	s9,a5
 6f2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6f6:	03000593          	li	a1,48
 6fa:	855a                	mv	a0,s6
 6fc:	dadff0ef          	jal	4a8 <putc>
  putc(fd, 'x');
 700:	07800593          	li	a1,120
 704:	855a                	mv	a0,s6
 706:	da3ff0ef          	jal	4a8 <putc>
 70a:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 70c:	00000b97          	auipc	s7,0x0
 710:	374b8b93          	addi	s7,s7,884 # a80 <digits>
 714:	03c9d793          	srli	a5,s3,0x3c
 718:	97de                	add	a5,a5,s7
 71a:	0007c583          	lbu	a1,0(a5)
 71e:	855a                	mv	a0,s6
 720:	d89ff0ef          	jal	4a8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 724:	0992                	slli	s3,s3,0x4
 726:	34fd                	addiw	s1,s1,-1
 728:	f4f5                	bnez	s1,714 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 72a:	8be6                	mv	s7,s9
      state = 0;
 72c:	4981                	li	s3,0
 72e:	6ca2                	ld	s9,8(sp)
 730:	bda5                	j	5a8 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 732:	008b8493          	addi	s1,s7,8
 736:	000bc583          	lbu	a1,0(s7)
 73a:	855a                	mv	a0,s6
 73c:	d6dff0ef          	jal	4a8 <putc>
 740:	8ba6                	mv	s7,s1
      state = 0;
 742:	4981                	li	s3,0
 744:	b595                	j	5a8 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 746:	008b8993          	addi	s3,s7,8
 74a:	000bb483          	ld	s1,0(s7)
 74e:	cc91                	beqz	s1,76a <vprintf+0x206>
        for(; *s; s++)
 750:	0004c583          	lbu	a1,0(s1)
 754:	c985                	beqz	a1,784 <vprintf+0x220>
          putc(fd, *s);
 756:	855a                	mv	a0,s6
 758:	d51ff0ef          	jal	4a8 <putc>
        for(; *s; s++)
 75c:	0485                	addi	s1,s1,1
 75e:	0004c583          	lbu	a1,0(s1)
 762:	f9f5                	bnez	a1,756 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 764:	8bce                	mv	s7,s3
      state = 0;
 766:	4981                	li	s3,0
 768:	b581                	j	5a8 <vprintf+0x44>
          s = "(null)";
 76a:	00000497          	auipc	s1,0x0
 76e:	30e48493          	addi	s1,s1,782 # a78 <malloc+0x172>
        for(; *s; s++)
 772:	02800593          	li	a1,40
 776:	b7c5                	j	756 <vprintf+0x1f2>
        putc(fd, '%');
 778:	85be                	mv	a1,a5
 77a:	855a                	mv	a0,s6
 77c:	d2dff0ef          	jal	4a8 <putc>
      state = 0;
 780:	4981                	li	s3,0
 782:	b51d                	j	5a8 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 784:	8bce                	mv	s7,s3
      state = 0;
 786:	4981                	li	s3,0
 788:	b505                	j	5a8 <vprintf+0x44>
 78a:	6906                	ld	s2,64(sp)
 78c:	79e2                	ld	s3,56(sp)
 78e:	7a42                	ld	s4,48(sp)
 790:	7aa2                	ld	s5,40(sp)
 792:	7b02                	ld	s6,32(sp)
 794:	6be2                	ld	s7,24(sp)
 796:	6c42                	ld	s8,16(sp)
    }
  }
}
 798:	60e6                	ld	ra,88(sp)
 79a:	6446                	ld	s0,80(sp)
 79c:	64a6                	ld	s1,72(sp)
 79e:	6125                	addi	sp,sp,96
 7a0:	8082                	ret
      if(c0 == 'd'){
 7a2:	06400713          	li	a4,100
 7a6:	e4e78fe3          	beq	a5,a4,604 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 7aa:	f9478693          	addi	a3,a5,-108
 7ae:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 7b2:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7b4:	4701                	li	a4,0
      } else if(c0 == 'u'){
 7b6:	07500513          	li	a0,117
 7ba:	e8a78ce3          	beq	a5,a0,652 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 7be:	f8b60513          	addi	a0,a2,-117
 7c2:	e119                	bnez	a0,7c8 <vprintf+0x264>
 7c4:	ea0693e3          	bnez	a3,66a <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7c8:	f8b58513          	addi	a0,a1,-117
 7cc:	e119                	bnez	a0,7d2 <vprintf+0x26e>
 7ce:	ea071be3          	bnez	a4,684 <vprintf+0x120>
      } else if(c0 == 'x'){
 7d2:	07800513          	li	a0,120
 7d6:	eca784e3          	beq	a5,a0,69e <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 7da:	f8860613          	addi	a2,a2,-120
 7de:	e219                	bnez	a2,7e4 <vprintf+0x280>
 7e0:	ec069be3          	bnez	a3,6b6 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7e4:	f8858593          	addi	a1,a1,-120
 7e8:	e199                	bnez	a1,7ee <vprintf+0x28a>
 7ea:	ee0713e3          	bnez	a4,6d0 <vprintf+0x16c>
      } else if(c0 == 'p'){
 7ee:	07000713          	li	a4,112
 7f2:	eee78ce3          	beq	a5,a4,6ea <vprintf+0x186>
      } else if(c0 == 'c'){
 7f6:	06300713          	li	a4,99
 7fa:	f2e78ce3          	beq	a5,a4,732 <vprintf+0x1ce>
      } else if(c0 == 's'){
 7fe:	07300713          	li	a4,115
 802:	f4e782e3          	beq	a5,a4,746 <vprintf+0x1e2>
      } else if(c0 == '%'){
 806:	02500713          	li	a4,37
 80a:	f6e787e3          	beq	a5,a4,778 <vprintf+0x214>
        putc(fd, '%');
 80e:	02500593          	li	a1,37
 812:	855a                	mv	a0,s6
 814:	c95ff0ef          	jal	4a8 <putc>
        putc(fd, c0);
 818:	85a6                	mv	a1,s1
 81a:	855a                	mv	a0,s6
 81c:	c8dff0ef          	jal	4a8 <putc>
      state = 0;
 820:	4981                	li	s3,0
 822:	b359                	j	5a8 <vprintf+0x44>

0000000000000824 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 824:	715d                	addi	sp,sp,-80
 826:	ec06                	sd	ra,24(sp)
 828:	e822                	sd	s0,16(sp)
 82a:	1000                	addi	s0,sp,32
 82c:	e010                	sd	a2,0(s0)
 82e:	e414                	sd	a3,8(s0)
 830:	e818                	sd	a4,16(s0)
 832:	ec1c                	sd	a5,24(s0)
 834:	03043023          	sd	a6,32(s0)
 838:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 83c:	8622                	mv	a2,s0
 83e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 842:	d23ff0ef          	jal	564 <vprintf>
}
 846:	60e2                	ld	ra,24(sp)
 848:	6442                	ld	s0,16(sp)
 84a:	6161                	addi	sp,sp,80
 84c:	8082                	ret

000000000000084e <printf>:

void
printf(const char *fmt, ...)
{
 84e:	711d                	addi	sp,sp,-96
 850:	ec06                	sd	ra,24(sp)
 852:	e822                	sd	s0,16(sp)
 854:	1000                	addi	s0,sp,32
 856:	e40c                	sd	a1,8(s0)
 858:	e810                	sd	a2,16(s0)
 85a:	ec14                	sd	a3,24(s0)
 85c:	f018                	sd	a4,32(s0)
 85e:	f41c                	sd	a5,40(s0)
 860:	03043823          	sd	a6,48(s0)
 864:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 868:	00840613          	addi	a2,s0,8
 86c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 870:	85aa                	mv	a1,a0
 872:	4505                	li	a0,1
 874:	cf1ff0ef          	jal	564 <vprintf>
}
 878:	60e2                	ld	ra,24(sp)
 87a:	6442                	ld	s0,16(sp)
 87c:	6125                	addi	sp,sp,96
 87e:	8082                	ret

0000000000000880 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 880:	1141                	addi	sp,sp,-16
 882:	e406                	sd	ra,8(sp)
 884:	e022                	sd	s0,0(sp)
 886:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 888:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88c:	00000797          	auipc	a5,0x0
 890:	7847b783          	ld	a5,1924(a5) # 1010 <freep>
 894:	a039                	j	8a2 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 896:	6398                	ld	a4,0(a5)
 898:	00e7e463          	bltu	a5,a4,8a0 <free+0x20>
 89c:	00e6ea63          	bltu	a3,a4,8b0 <free+0x30>
{
 8a0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a2:	fed7fae3          	bgeu	a5,a3,896 <free+0x16>
 8a6:	6398                	ld	a4,0(a5)
 8a8:	00e6e463          	bltu	a3,a4,8b0 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ac:	fee7eae3          	bltu	a5,a4,8a0 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8b0:	ff852583          	lw	a1,-8(a0)
 8b4:	6390                	ld	a2,0(a5)
 8b6:	02059813          	slli	a6,a1,0x20
 8ba:	01c85713          	srli	a4,a6,0x1c
 8be:	9736                	add	a4,a4,a3
 8c0:	02e60563          	beq	a2,a4,8ea <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 8c4:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 8c8:	4790                	lw	a2,8(a5)
 8ca:	02061593          	slli	a1,a2,0x20
 8ce:	01c5d713          	srli	a4,a1,0x1c
 8d2:	973e                	add	a4,a4,a5
 8d4:	02e68263          	beq	a3,a4,8f8 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 8d8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8da:	00000717          	auipc	a4,0x0
 8de:	72f73b23          	sd	a5,1846(a4) # 1010 <freep>
}
 8e2:	60a2                	ld	ra,8(sp)
 8e4:	6402                	ld	s0,0(sp)
 8e6:	0141                	addi	sp,sp,16
 8e8:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 8ea:	4618                	lw	a4,8(a2)
 8ec:	9f2d                	addw	a4,a4,a1
 8ee:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8f2:	6398                	ld	a4,0(a5)
 8f4:	6310                	ld	a2,0(a4)
 8f6:	b7f9                	j	8c4 <free+0x44>
    p->s.size += bp->s.size;
 8f8:	ff852703          	lw	a4,-8(a0)
 8fc:	9f31                	addw	a4,a4,a2
 8fe:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 900:	ff053683          	ld	a3,-16(a0)
 904:	bfd1                	j	8d8 <free+0x58>

0000000000000906 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 906:	7139                	addi	sp,sp,-64
 908:	fc06                	sd	ra,56(sp)
 90a:	f822                	sd	s0,48(sp)
 90c:	f04a                	sd	s2,32(sp)
 90e:	ec4e                	sd	s3,24(sp)
 910:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 912:	02051993          	slli	s3,a0,0x20
 916:	0209d993          	srli	s3,s3,0x20
 91a:	09bd                	addi	s3,s3,15
 91c:	0049d993          	srli	s3,s3,0x4
 920:	2985                	addiw	s3,s3,1
 922:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 924:	00000517          	auipc	a0,0x0
 928:	6ec53503          	ld	a0,1772(a0) # 1010 <freep>
 92c:	c905                	beqz	a0,95c <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 930:	4798                	lw	a4,8(a5)
 932:	09377663          	bgeu	a4,s3,9be <malloc+0xb8>
 936:	f426                	sd	s1,40(sp)
 938:	e852                	sd	s4,16(sp)
 93a:	e456                	sd	s5,8(sp)
 93c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 93e:	8a4e                	mv	s4,s3
 940:	6705                	lui	a4,0x1
 942:	00e9f363          	bgeu	s3,a4,948 <malloc+0x42>
 946:	6a05                	lui	s4,0x1
 948:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 94c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 950:	00000497          	auipc	s1,0x0
 954:	6c048493          	addi	s1,s1,1728 # 1010 <freep>
  if(p == SBRK_ERROR)
 958:	5afd                	li	s5,-1
 95a:	a83d                	j	998 <malloc+0x92>
 95c:	f426                	sd	s1,40(sp)
 95e:	e852                	sd	s4,16(sp)
 960:	e456                	sd	s5,8(sp)
 962:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 964:	00000797          	auipc	a5,0x0
 968:	6bc78793          	addi	a5,a5,1724 # 1020 <base>
 96c:	00000717          	auipc	a4,0x0
 970:	6af73223          	sd	a5,1700(a4) # 1010 <freep>
 974:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 976:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 97a:	b7d1                	j	93e <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 97c:	6398                	ld	a4,0(a5)
 97e:	e118                	sd	a4,0(a0)
 980:	a899                	j	9d6 <malloc+0xd0>
  hp->s.size = nu;
 982:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 986:	0541                	addi	a0,a0,16
 988:	ef9ff0ef          	jal	880 <free>
  return freep;
 98c:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 98e:	c125                	beqz	a0,9ee <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 990:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 992:	4798                	lw	a4,8(a5)
 994:	03277163          	bgeu	a4,s2,9b6 <malloc+0xb0>
    if(p == freep)
 998:	6098                	ld	a4,0(s1)
 99a:	853e                	mv	a0,a5
 99c:	fef71ae3          	bne	a4,a5,990 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 9a0:	8552                	mv	a0,s4
 9a2:	99dff0ef          	jal	33e <sbrk>
  if(p == SBRK_ERROR)
 9a6:	fd551ee3          	bne	a0,s5,982 <malloc+0x7c>
        return 0;
 9aa:	4501                	li	a0,0
 9ac:	74a2                	ld	s1,40(sp)
 9ae:	6a42                	ld	s4,16(sp)
 9b0:	6aa2                	ld	s5,8(sp)
 9b2:	6b02                	ld	s6,0(sp)
 9b4:	a03d                	j	9e2 <malloc+0xdc>
 9b6:	74a2                	ld	s1,40(sp)
 9b8:	6a42                	ld	s4,16(sp)
 9ba:	6aa2                	ld	s5,8(sp)
 9bc:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9be:	fae90fe3          	beq	s2,a4,97c <malloc+0x76>
        p->s.size -= nunits;
 9c2:	4137073b          	subw	a4,a4,s3
 9c6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9c8:	02071693          	slli	a3,a4,0x20
 9cc:	01c6d713          	srli	a4,a3,0x1c
 9d0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9d2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9d6:	00000717          	auipc	a4,0x0
 9da:	62a73d23          	sd	a0,1594(a4) # 1010 <freep>
      return (void*)(p + 1);
 9de:	01078513          	addi	a0,a5,16
  }
}
 9e2:	70e2                	ld	ra,56(sp)
 9e4:	7442                	ld	s0,48(sp)
 9e6:	7902                	ld	s2,32(sp)
 9e8:	69e2                	ld	s3,24(sp)
 9ea:	6121                	addi	sp,sp,64
 9ec:	8082                	ret
 9ee:	74a2                	ld	s1,40(sp)
 9f0:	6a42                	ld	s4,16(sp)
 9f2:	6aa2                	ld	s5,8(sp)
 9f4:	6b02                	ld	s6,0(sp)
 9f6:	b7f5                	j	9e2 <malloc+0xdc>
