
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
  12:	97250513          	addi	a0,a0,-1678 # 980 <malloc+0xf8>
  16:	39c000ef          	jal	3b2 <open>
  1a:	04054563          	bltz	a0,64 <main+0x64>
    mknod("console", CONSOLE, 0);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  1e:	4501                	li	a0,0
  20:	3ca000ef          	jal	3ea <dup>
  dup(0);  // stderr
  24:	4501                	li	a0,0
  26:	3c4000ef          	jal	3ea <dup>

  for(;;){
    printf("init: starting sh\n");
  2a:	00001917          	auipc	s2,0x1
  2e:	95e90913          	addi	s2,s2,-1698 # 988 <malloc+0x100>
  32:	854a                	mv	a0,s2
  34:	79c000ef          	jal	7d0 <printf>
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
  56:	98650513          	addi	a0,a0,-1658 # 9d8 <malloc+0x150>
  5a:	776000ef          	jal	7d0 <printf>
        exit(1);
  5e:	4505                	li	a0,1
  60:	312000ef          	jal	372 <exit>
    mknod("console", CONSOLE, 0);
  64:	4601                	li	a2,0
  66:	4585                	li	a1,1
  68:	00001517          	auipc	a0,0x1
  6c:	91850513          	addi	a0,a0,-1768 # 980 <malloc+0xf8>
  70:	34a000ef          	jal	3ba <mknod>
    open("console", O_RDWR);
  74:	4589                	li	a1,2
  76:	00001517          	auipc	a0,0x1
  7a:	90a50513          	addi	a0,a0,-1782 # 980 <malloc+0xf8>
  7e:	334000ef          	jal	3b2 <open>
  82:	bf71                	j	1e <main+0x1e>
      printf("init: fork failed\n");
  84:	00001517          	auipc	a0,0x1
  88:	91c50513          	addi	a0,a0,-1764 # 9a0 <malloc+0x118>
  8c:	744000ef          	jal	7d0 <printf>
      exit(1);
  90:	4505                	li	a0,1
  92:	2e0000ef          	jal	372 <exit>
      exec("sh", argv);
  96:	00001597          	auipc	a1,0x1
  9a:	f6a58593          	addi	a1,a1,-150 # 1000 <argv>
  9e:	00001517          	auipc	a0,0x1
  a2:	91a50513          	addi	a0,a0,-1766 # 9b8 <malloc+0x130>
  a6:	304000ef          	jal	3aa <exec>
      printf("init: exec sh failed\n");
  aa:	00001517          	auipc	a0,0x1
  ae:	91650513          	addi	a0,a0,-1770 # 9c0 <malloc+0x138>
  b2:	71e000ef          	jal	7d0 <printf>
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
 21a:	198000ef          	jal	3b2 <open>
  if(fd < 0)
 21e:	02054263          	bltz	a0,242 <stat+0x36>
 222:	e426                	sd	s1,8(sp)
 224:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 226:	85ca                	mv	a1,s2
 228:	1a2000ef          	jal	3ca <fstat>
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
 348:	0b2000ef          	jal	3fa <sys_sbrk>
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
 35e:	09c000ef          	jal	3fa <sys_sbrk>
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

00000000000003a2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3a2:	4899                	li	a7,6
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <exec>:
.global exec
exec:
 li a7, SYS_exec
 3aa:	489d                	li	a7,7
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <open>:
.global open
open:
 li a7, SYS_open
 3b2:	48bd                	li	a7,15
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ba:	48c5                	li	a7,17
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3c2:	48c9                	li	a7,18
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ca:	48a1                	li	a7,8
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <link>:
.global link
link:
 li a7, SYS_link
 3d2:	48cd                	li	a7,19
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3da:	48d1                	li	a7,20
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3e2:	48a5                	li	a7,9
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ea:	48a9                	li	a7,10
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3f2:	48ad                	li	a7,11
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3fa:	48b1                	li	a7,12
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <pause>:
.global pause
pause:
 li a7, SYS_pause
 402:	48b5                	li	a7,13
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 40a:	48b9                	li	a7,14
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <sendmsg>:
.global sendmsg
sendmsg:
 li a7, SYS_sendmsg
 412:	48d9                	li	a7,22
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <recvmsg>:
.global recvmsg
recvmsg:
 li a7, SYS_recvmsg
 41a:	48dd                	li	a7,23
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <broadcast>:
.global broadcast
broadcast:
 li a7, SYS_broadcast
 422:	48e1                	li	a7,24
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 42a:	1101                	addi	sp,sp,-32
 42c:	ec06                	sd	ra,24(sp)
 42e:	e822                	sd	s0,16(sp)
 430:	1000                	addi	s0,sp,32
 432:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 436:	4605                	li	a2,1
 438:	fef40593          	addi	a1,s0,-17
 43c:	f57ff0ef          	jal	392 <write>
}
 440:	60e2                	ld	ra,24(sp)
 442:	6442                	ld	s0,16(sp)
 444:	6105                	addi	sp,sp,32
 446:	8082                	ret

0000000000000448 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 448:	715d                	addi	sp,sp,-80
 44a:	e486                	sd	ra,72(sp)
 44c:	e0a2                	sd	s0,64(sp)
 44e:	f84a                	sd	s2,48(sp)
 450:	f44e                	sd	s3,40(sp)
 452:	0880                	addi	s0,sp,80
 454:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 456:	c6d1                	beqz	a3,4e2 <printint+0x9a>
 458:	0805d563          	bgez	a1,4e2 <printint+0x9a>
    neg = 1;
    x = -xx;
 45c:	40b005b3          	neg	a1,a1
    neg = 1;
 460:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 462:	fb840993          	addi	s3,s0,-72
  neg = 0;
 466:	86ce                	mv	a3,s3
  i = 0;
 468:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 46a:	00000817          	auipc	a6,0x0
 46e:	59680813          	addi	a6,a6,1430 # a00 <digits>
 472:	88ba                	mv	a7,a4
 474:	0017051b          	addiw	a0,a4,1
 478:	872a                	mv	a4,a0
 47a:	02c5f7b3          	remu	a5,a1,a2
 47e:	97c2                	add	a5,a5,a6
 480:	0007c783          	lbu	a5,0(a5)
 484:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 488:	87ae                	mv	a5,a1
 48a:	02c5d5b3          	divu	a1,a1,a2
 48e:	0685                	addi	a3,a3,1
 490:	fec7f1e3          	bgeu	a5,a2,472 <printint+0x2a>
  if(neg)
 494:	00030c63          	beqz	t1,4ac <printint+0x64>
    buf[i++] = '-';
 498:	fd050793          	addi	a5,a0,-48
 49c:	00878533          	add	a0,a5,s0
 4a0:	02d00793          	li	a5,45
 4a4:	fef50423          	sb	a5,-24(a0)
 4a8:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 4ac:	02e05563          	blez	a4,4d6 <printint+0x8e>
 4b0:	fc26                	sd	s1,56(sp)
 4b2:	377d                	addiw	a4,a4,-1
 4b4:	00e984b3          	add	s1,s3,a4
 4b8:	19fd                	addi	s3,s3,-1
 4ba:	99ba                	add	s3,s3,a4
 4bc:	1702                	slli	a4,a4,0x20
 4be:	9301                	srli	a4,a4,0x20
 4c0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4c4:	0004c583          	lbu	a1,0(s1)
 4c8:	854a                	mv	a0,s2
 4ca:	f61ff0ef          	jal	42a <putc>
  while(--i >= 0)
 4ce:	14fd                	addi	s1,s1,-1
 4d0:	ff349ae3          	bne	s1,s3,4c4 <printint+0x7c>
 4d4:	74e2                	ld	s1,56(sp)
}
 4d6:	60a6                	ld	ra,72(sp)
 4d8:	6406                	ld	s0,64(sp)
 4da:	7942                	ld	s2,48(sp)
 4dc:	79a2                	ld	s3,40(sp)
 4de:	6161                	addi	sp,sp,80
 4e0:	8082                	ret
  neg = 0;
 4e2:	4301                	li	t1,0
 4e4:	bfbd                	j	462 <printint+0x1a>

00000000000004e6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4e6:	711d                	addi	sp,sp,-96
 4e8:	ec86                	sd	ra,88(sp)
 4ea:	e8a2                	sd	s0,80(sp)
 4ec:	e4a6                	sd	s1,72(sp)
 4ee:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4f0:	0005c483          	lbu	s1,0(a1)
 4f4:	22048363          	beqz	s1,71a <vprintf+0x234>
 4f8:	e0ca                	sd	s2,64(sp)
 4fa:	fc4e                	sd	s3,56(sp)
 4fc:	f852                	sd	s4,48(sp)
 4fe:	f456                	sd	s5,40(sp)
 500:	f05a                	sd	s6,32(sp)
 502:	ec5e                	sd	s7,24(sp)
 504:	e862                	sd	s8,16(sp)
 506:	8b2a                	mv	s6,a0
 508:	8a2e                	mv	s4,a1
 50a:	8bb2                	mv	s7,a2
  state = 0;
 50c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 50e:	4901                	li	s2,0
 510:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 512:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 516:	06400c13          	li	s8,100
 51a:	a00d                	j	53c <vprintf+0x56>
        putc(fd, c0);
 51c:	85a6                	mv	a1,s1
 51e:	855a                	mv	a0,s6
 520:	f0bff0ef          	jal	42a <putc>
 524:	a019                	j	52a <vprintf+0x44>
    } else if(state == '%'){
 526:	03598363          	beq	s3,s5,54c <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 52a:	0019079b          	addiw	a5,s2,1
 52e:	893e                	mv	s2,a5
 530:	873e                	mv	a4,a5
 532:	97d2                	add	a5,a5,s4
 534:	0007c483          	lbu	s1,0(a5)
 538:	1c048a63          	beqz	s1,70c <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 53c:	0004879b          	sext.w	a5,s1
    if(state == 0){
 540:	fe0993e3          	bnez	s3,526 <vprintf+0x40>
      if(c0 == '%'){
 544:	fd579ce3          	bne	a5,s5,51c <vprintf+0x36>
        state = '%';
 548:	89be                	mv	s3,a5
 54a:	b7c5                	j	52a <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 54c:	00ea06b3          	add	a3,s4,a4
 550:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 554:	1c060863          	beqz	a2,724 <vprintf+0x23e>
      if(c0 == 'd'){
 558:	03878763          	beq	a5,s8,586 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 55c:	f9478693          	addi	a3,a5,-108
 560:	0016b693          	seqz	a3,a3
 564:	f9c60593          	addi	a1,a2,-100
 568:	e99d                	bnez	a1,59e <vprintf+0xb8>
 56a:	ca95                	beqz	a3,59e <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 56c:	008b8493          	addi	s1,s7,8
 570:	4685                	li	a3,1
 572:	4629                	li	a2,10
 574:	000bb583          	ld	a1,0(s7)
 578:	855a                	mv	a0,s6
 57a:	ecfff0ef          	jal	448 <printint>
        i += 1;
 57e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 580:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 582:	4981                	li	s3,0
 584:	b75d                	j	52a <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 586:	008b8493          	addi	s1,s7,8
 58a:	4685                	li	a3,1
 58c:	4629                	li	a2,10
 58e:	000ba583          	lw	a1,0(s7)
 592:	855a                	mv	a0,s6
 594:	eb5ff0ef          	jal	448 <printint>
 598:	8ba6                	mv	s7,s1
      state = 0;
 59a:	4981                	li	s3,0
 59c:	b779                	j	52a <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 59e:	9752                	add	a4,a4,s4
 5a0:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5a4:	f9460713          	addi	a4,a2,-108
 5a8:	00173713          	seqz	a4,a4
 5ac:	8f75                	and	a4,a4,a3
 5ae:	f9c58513          	addi	a0,a1,-100
 5b2:	18051363          	bnez	a0,738 <vprintf+0x252>
 5b6:	18070163          	beqz	a4,738 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ba:	008b8493          	addi	s1,s7,8
 5be:	4685                	li	a3,1
 5c0:	4629                	li	a2,10
 5c2:	000bb583          	ld	a1,0(s7)
 5c6:	855a                	mv	a0,s6
 5c8:	e81ff0ef          	jal	448 <printint>
        i += 2;
 5cc:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ce:	8ba6                	mv	s7,s1
      state = 0;
 5d0:	4981                	li	s3,0
        i += 2;
 5d2:	bfa1                	j	52a <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5d4:	008b8493          	addi	s1,s7,8
 5d8:	4681                	li	a3,0
 5da:	4629                	li	a2,10
 5dc:	000be583          	lwu	a1,0(s7)
 5e0:	855a                	mv	a0,s6
 5e2:	e67ff0ef          	jal	448 <printint>
 5e6:	8ba6                	mv	s7,s1
      state = 0;
 5e8:	4981                	li	s3,0
 5ea:	b781                	j	52a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ec:	008b8493          	addi	s1,s7,8
 5f0:	4681                	li	a3,0
 5f2:	4629                	li	a2,10
 5f4:	000bb583          	ld	a1,0(s7)
 5f8:	855a                	mv	a0,s6
 5fa:	e4fff0ef          	jal	448 <printint>
        i += 1;
 5fe:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 600:	8ba6                	mv	s7,s1
      state = 0;
 602:	4981                	li	s3,0
 604:	b71d                	j	52a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 606:	008b8493          	addi	s1,s7,8
 60a:	4681                	li	a3,0
 60c:	4629                	li	a2,10
 60e:	000bb583          	ld	a1,0(s7)
 612:	855a                	mv	a0,s6
 614:	e35ff0ef          	jal	448 <printint>
        i += 2;
 618:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 61a:	8ba6                	mv	s7,s1
      state = 0;
 61c:	4981                	li	s3,0
        i += 2;
 61e:	b731                	j	52a <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 620:	008b8493          	addi	s1,s7,8
 624:	4681                	li	a3,0
 626:	4641                	li	a2,16
 628:	000be583          	lwu	a1,0(s7)
 62c:	855a                	mv	a0,s6
 62e:	e1bff0ef          	jal	448 <printint>
 632:	8ba6                	mv	s7,s1
      state = 0;
 634:	4981                	li	s3,0
 636:	bdd5                	j	52a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 638:	008b8493          	addi	s1,s7,8
 63c:	4681                	li	a3,0
 63e:	4641                	li	a2,16
 640:	000bb583          	ld	a1,0(s7)
 644:	855a                	mv	a0,s6
 646:	e03ff0ef          	jal	448 <printint>
        i += 1;
 64a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 64c:	8ba6                	mv	s7,s1
      state = 0;
 64e:	4981                	li	s3,0
 650:	bde9                	j	52a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 652:	008b8493          	addi	s1,s7,8
 656:	4681                	li	a3,0
 658:	4641                	li	a2,16
 65a:	000bb583          	ld	a1,0(s7)
 65e:	855a                	mv	a0,s6
 660:	de9ff0ef          	jal	448 <printint>
        i += 2;
 664:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 666:	8ba6                	mv	s7,s1
      state = 0;
 668:	4981                	li	s3,0
        i += 2;
 66a:	b5c1                	j	52a <vprintf+0x44>
 66c:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 66e:	008b8793          	addi	a5,s7,8
 672:	8cbe                	mv	s9,a5
 674:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 678:	03000593          	li	a1,48
 67c:	855a                	mv	a0,s6
 67e:	dadff0ef          	jal	42a <putc>
  putc(fd, 'x');
 682:	07800593          	li	a1,120
 686:	855a                	mv	a0,s6
 688:	da3ff0ef          	jal	42a <putc>
 68c:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 68e:	00000b97          	auipc	s7,0x0
 692:	372b8b93          	addi	s7,s7,882 # a00 <digits>
 696:	03c9d793          	srli	a5,s3,0x3c
 69a:	97de                	add	a5,a5,s7
 69c:	0007c583          	lbu	a1,0(a5)
 6a0:	855a                	mv	a0,s6
 6a2:	d89ff0ef          	jal	42a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6a6:	0992                	slli	s3,s3,0x4
 6a8:	34fd                	addiw	s1,s1,-1
 6aa:	f4f5                	bnez	s1,696 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 6ac:	8be6                	mv	s7,s9
      state = 0;
 6ae:	4981                	li	s3,0
 6b0:	6ca2                	ld	s9,8(sp)
 6b2:	bda5                	j	52a <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 6b4:	008b8493          	addi	s1,s7,8
 6b8:	000bc583          	lbu	a1,0(s7)
 6bc:	855a                	mv	a0,s6
 6be:	d6dff0ef          	jal	42a <putc>
 6c2:	8ba6                	mv	s7,s1
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	b595                	j	52a <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6c8:	008b8993          	addi	s3,s7,8
 6cc:	000bb483          	ld	s1,0(s7)
 6d0:	cc91                	beqz	s1,6ec <vprintf+0x206>
        for(; *s; s++)
 6d2:	0004c583          	lbu	a1,0(s1)
 6d6:	c985                	beqz	a1,706 <vprintf+0x220>
          putc(fd, *s);
 6d8:	855a                	mv	a0,s6
 6da:	d51ff0ef          	jal	42a <putc>
        for(; *s; s++)
 6de:	0485                	addi	s1,s1,1
 6e0:	0004c583          	lbu	a1,0(s1)
 6e4:	f9f5                	bnez	a1,6d8 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 6e6:	8bce                	mv	s7,s3
      state = 0;
 6e8:	4981                	li	s3,0
 6ea:	b581                	j	52a <vprintf+0x44>
          s = "(null)";
 6ec:	00000497          	auipc	s1,0x0
 6f0:	30c48493          	addi	s1,s1,780 # 9f8 <malloc+0x170>
        for(; *s; s++)
 6f4:	02800593          	li	a1,40
 6f8:	b7c5                	j	6d8 <vprintf+0x1f2>
        putc(fd, '%');
 6fa:	85be                	mv	a1,a5
 6fc:	855a                	mv	a0,s6
 6fe:	d2dff0ef          	jal	42a <putc>
      state = 0;
 702:	4981                	li	s3,0
 704:	b51d                	j	52a <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 706:	8bce                	mv	s7,s3
      state = 0;
 708:	4981                	li	s3,0
 70a:	b505                	j	52a <vprintf+0x44>
 70c:	6906                	ld	s2,64(sp)
 70e:	79e2                	ld	s3,56(sp)
 710:	7a42                	ld	s4,48(sp)
 712:	7aa2                	ld	s5,40(sp)
 714:	7b02                	ld	s6,32(sp)
 716:	6be2                	ld	s7,24(sp)
 718:	6c42                	ld	s8,16(sp)
    }
  }
}
 71a:	60e6                	ld	ra,88(sp)
 71c:	6446                	ld	s0,80(sp)
 71e:	64a6                	ld	s1,72(sp)
 720:	6125                	addi	sp,sp,96
 722:	8082                	ret
      if(c0 == 'd'){
 724:	06400713          	li	a4,100
 728:	e4e78fe3          	beq	a5,a4,586 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 72c:	f9478693          	addi	a3,a5,-108
 730:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 734:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 736:	4701                	li	a4,0
      } else if(c0 == 'u'){
 738:	07500513          	li	a0,117
 73c:	e8a78ce3          	beq	a5,a0,5d4 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 740:	f8b60513          	addi	a0,a2,-117
 744:	e119                	bnez	a0,74a <vprintf+0x264>
 746:	ea0693e3          	bnez	a3,5ec <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 74a:	f8b58513          	addi	a0,a1,-117
 74e:	e119                	bnez	a0,754 <vprintf+0x26e>
 750:	ea071be3          	bnez	a4,606 <vprintf+0x120>
      } else if(c0 == 'x'){
 754:	07800513          	li	a0,120
 758:	eca784e3          	beq	a5,a0,620 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 75c:	f8860613          	addi	a2,a2,-120
 760:	e219                	bnez	a2,766 <vprintf+0x280>
 762:	ec069be3          	bnez	a3,638 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 766:	f8858593          	addi	a1,a1,-120
 76a:	e199                	bnez	a1,770 <vprintf+0x28a>
 76c:	ee0713e3          	bnez	a4,652 <vprintf+0x16c>
      } else if(c0 == 'p'){
 770:	07000713          	li	a4,112
 774:	eee78ce3          	beq	a5,a4,66c <vprintf+0x186>
      } else if(c0 == 'c'){
 778:	06300713          	li	a4,99
 77c:	f2e78ce3          	beq	a5,a4,6b4 <vprintf+0x1ce>
      } else if(c0 == 's'){
 780:	07300713          	li	a4,115
 784:	f4e782e3          	beq	a5,a4,6c8 <vprintf+0x1e2>
      } else if(c0 == '%'){
 788:	02500713          	li	a4,37
 78c:	f6e787e3          	beq	a5,a4,6fa <vprintf+0x214>
        putc(fd, '%');
 790:	02500593          	li	a1,37
 794:	855a                	mv	a0,s6
 796:	c95ff0ef          	jal	42a <putc>
        putc(fd, c0);
 79a:	85a6                	mv	a1,s1
 79c:	855a                	mv	a0,s6
 79e:	c8dff0ef          	jal	42a <putc>
      state = 0;
 7a2:	4981                	li	s3,0
 7a4:	b359                	j	52a <vprintf+0x44>

00000000000007a6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7a6:	715d                	addi	sp,sp,-80
 7a8:	ec06                	sd	ra,24(sp)
 7aa:	e822                	sd	s0,16(sp)
 7ac:	1000                	addi	s0,sp,32
 7ae:	e010                	sd	a2,0(s0)
 7b0:	e414                	sd	a3,8(s0)
 7b2:	e818                	sd	a4,16(s0)
 7b4:	ec1c                	sd	a5,24(s0)
 7b6:	03043023          	sd	a6,32(s0)
 7ba:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7be:	8622                	mv	a2,s0
 7c0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7c4:	d23ff0ef          	jal	4e6 <vprintf>
}
 7c8:	60e2                	ld	ra,24(sp)
 7ca:	6442                	ld	s0,16(sp)
 7cc:	6161                	addi	sp,sp,80
 7ce:	8082                	ret

00000000000007d0 <printf>:

void
printf(const char *fmt, ...)
{
 7d0:	711d                	addi	sp,sp,-96
 7d2:	ec06                	sd	ra,24(sp)
 7d4:	e822                	sd	s0,16(sp)
 7d6:	1000                	addi	s0,sp,32
 7d8:	e40c                	sd	a1,8(s0)
 7da:	e810                	sd	a2,16(s0)
 7dc:	ec14                	sd	a3,24(s0)
 7de:	f018                	sd	a4,32(s0)
 7e0:	f41c                	sd	a5,40(s0)
 7e2:	03043823          	sd	a6,48(s0)
 7e6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ea:	00840613          	addi	a2,s0,8
 7ee:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7f2:	85aa                	mv	a1,a0
 7f4:	4505                	li	a0,1
 7f6:	cf1ff0ef          	jal	4e6 <vprintf>
}
 7fa:	60e2                	ld	ra,24(sp)
 7fc:	6442                	ld	s0,16(sp)
 7fe:	6125                	addi	sp,sp,96
 800:	8082                	ret

0000000000000802 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 802:	1141                	addi	sp,sp,-16
 804:	e406                	sd	ra,8(sp)
 806:	e022                	sd	s0,0(sp)
 808:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 80a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 80e:	00001797          	auipc	a5,0x1
 812:	8027b783          	ld	a5,-2046(a5) # 1010 <freep>
 816:	a039                	j	824 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 818:	6398                	ld	a4,0(a5)
 81a:	00e7e463          	bltu	a5,a4,822 <free+0x20>
 81e:	00e6ea63          	bltu	a3,a4,832 <free+0x30>
{
 822:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 824:	fed7fae3          	bgeu	a5,a3,818 <free+0x16>
 828:	6398                	ld	a4,0(a5)
 82a:	00e6e463          	bltu	a3,a4,832 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 82e:	fee7eae3          	bltu	a5,a4,822 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 832:	ff852583          	lw	a1,-8(a0)
 836:	6390                	ld	a2,0(a5)
 838:	02059813          	slli	a6,a1,0x20
 83c:	01c85713          	srli	a4,a6,0x1c
 840:	9736                	add	a4,a4,a3
 842:	02e60563          	beq	a2,a4,86c <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 846:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 84a:	4790                	lw	a2,8(a5)
 84c:	02061593          	slli	a1,a2,0x20
 850:	01c5d713          	srli	a4,a1,0x1c
 854:	973e                	add	a4,a4,a5
 856:	02e68263          	beq	a3,a4,87a <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 85a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 85c:	00000717          	auipc	a4,0x0
 860:	7af73a23          	sd	a5,1972(a4) # 1010 <freep>
}
 864:	60a2                	ld	ra,8(sp)
 866:	6402                	ld	s0,0(sp)
 868:	0141                	addi	sp,sp,16
 86a:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 86c:	4618                	lw	a4,8(a2)
 86e:	9f2d                	addw	a4,a4,a1
 870:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 874:	6398                	ld	a4,0(a5)
 876:	6310                	ld	a2,0(a4)
 878:	b7f9                	j	846 <free+0x44>
    p->s.size += bp->s.size;
 87a:	ff852703          	lw	a4,-8(a0)
 87e:	9f31                	addw	a4,a4,a2
 880:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 882:	ff053683          	ld	a3,-16(a0)
 886:	bfd1                	j	85a <free+0x58>

0000000000000888 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 888:	7139                	addi	sp,sp,-64
 88a:	fc06                	sd	ra,56(sp)
 88c:	f822                	sd	s0,48(sp)
 88e:	f04a                	sd	s2,32(sp)
 890:	ec4e                	sd	s3,24(sp)
 892:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 894:	02051993          	slli	s3,a0,0x20
 898:	0209d993          	srli	s3,s3,0x20
 89c:	09bd                	addi	s3,s3,15
 89e:	0049d993          	srli	s3,s3,0x4
 8a2:	2985                	addiw	s3,s3,1
 8a4:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 8a6:	00000517          	auipc	a0,0x0
 8aa:	76a53503          	ld	a0,1898(a0) # 1010 <freep>
 8ae:	c905                	beqz	a0,8de <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b2:	4798                	lw	a4,8(a5)
 8b4:	09377663          	bgeu	a4,s3,940 <malloc+0xb8>
 8b8:	f426                	sd	s1,40(sp)
 8ba:	e852                	sd	s4,16(sp)
 8bc:	e456                	sd	s5,8(sp)
 8be:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8c0:	8a4e                	mv	s4,s3
 8c2:	6705                	lui	a4,0x1
 8c4:	00e9f363          	bgeu	s3,a4,8ca <malloc+0x42>
 8c8:	6a05                	lui	s4,0x1
 8ca:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ce:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8d2:	00000497          	auipc	s1,0x0
 8d6:	73e48493          	addi	s1,s1,1854 # 1010 <freep>
  if(p == SBRK_ERROR)
 8da:	5afd                	li	s5,-1
 8dc:	a83d                	j	91a <malloc+0x92>
 8de:	f426                	sd	s1,40(sp)
 8e0:	e852                	sd	s4,16(sp)
 8e2:	e456                	sd	s5,8(sp)
 8e4:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8e6:	00000797          	auipc	a5,0x0
 8ea:	73a78793          	addi	a5,a5,1850 # 1020 <base>
 8ee:	00000717          	auipc	a4,0x0
 8f2:	72f73123          	sd	a5,1826(a4) # 1010 <freep>
 8f6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8f8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8fc:	b7d1                	j	8c0 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8fe:	6398                	ld	a4,0(a5)
 900:	e118                	sd	a4,0(a0)
 902:	a899                	j	958 <malloc+0xd0>
  hp->s.size = nu;
 904:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 908:	0541                	addi	a0,a0,16
 90a:	ef9ff0ef          	jal	802 <free>
  return freep;
 90e:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 910:	c125                	beqz	a0,970 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 912:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 914:	4798                	lw	a4,8(a5)
 916:	03277163          	bgeu	a4,s2,938 <malloc+0xb0>
    if(p == freep)
 91a:	6098                	ld	a4,0(s1)
 91c:	853e                	mv	a0,a5
 91e:	fef71ae3          	bne	a4,a5,912 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 922:	8552                	mv	a0,s4
 924:	a1bff0ef          	jal	33e <sbrk>
  if(p == SBRK_ERROR)
 928:	fd551ee3          	bne	a0,s5,904 <malloc+0x7c>
        return 0;
 92c:	4501                	li	a0,0
 92e:	74a2                	ld	s1,40(sp)
 930:	6a42                	ld	s4,16(sp)
 932:	6aa2                	ld	s5,8(sp)
 934:	6b02                	ld	s6,0(sp)
 936:	a03d                	j	964 <malloc+0xdc>
 938:	74a2                	ld	s1,40(sp)
 93a:	6a42                	ld	s4,16(sp)
 93c:	6aa2                	ld	s5,8(sp)
 93e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 940:	fae90fe3          	beq	s2,a4,8fe <malloc+0x76>
        p->s.size -= nunits;
 944:	4137073b          	subw	a4,a4,s3
 948:	c798                	sw	a4,8(a5)
        p += p->s.size;
 94a:	02071693          	slli	a3,a4,0x20
 94e:	01c6d713          	srli	a4,a3,0x1c
 952:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 954:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 958:	00000717          	auipc	a4,0x0
 95c:	6aa73c23          	sd	a0,1720(a4) # 1010 <freep>
      return (void*)(p + 1);
 960:	01078513          	addi	a0,a5,16
  }
}
 964:	70e2                	ld	ra,56(sp)
 966:	7442                	ld	s0,48(sp)
 968:	7902                	ld	s2,32(sp)
 96a:	69e2                	ld	s3,24(sp)
 96c:	6121                	addi	sp,sp,64
 96e:	8082                	ret
 970:	74a2                	ld	s1,40(sp)
 972:	6a42                	ld	s4,16(sp)
 974:	6aa2                	ld	s5,8(sp)
 976:	6b02                	ld	s6,0(sp)
 978:	b7f5                	j	964 <malloc+0xdc>
