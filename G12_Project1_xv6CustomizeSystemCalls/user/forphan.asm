
user/_forphan:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char buf[BUFSZ];

int
main(int argc, char **argv)
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	0080                	addi	s0,sp,64
  int fd = 0;
  char *s = argv[0];
   a:	6184                	ld	s1,0(a1)
  struct stat st;
  char *ff = "file0";
  
  if ((fd = open(ff, O_CREATE|O_WRONLY)) < 0) {
   c:	20100593          	li	a1,513
  10:	00001517          	auipc	a0,0x1
  14:	a0050513          	addi	a0,a0,-1536 # a10 <malloc+0x100>
  18:	430000ef          	jal	448 <open>
  1c:	04054463          	bltz	a0,64 <main+0x64>
    printf("%s: open failed\n", s);
    exit(1);
  }
  if(fstat(fd, &st) < 0){
  20:	fc840593          	addi	a1,s0,-56
  24:	43c000ef          	jal	460 <fstat>
  28:	04054863          	bltz	a0,78 <main+0x78>
    fprintf(2, "%s: cannot stat %s\n", s, "ff");
    exit(1);
  }
  if (unlink(ff) < 0) {
  2c:	00001517          	auipc	a0,0x1
  30:	9e450513          	addi	a0,a0,-1564 # a10 <malloc+0x100>
  34:	424000ef          	jal	458 <unlink>
  38:	04054f63          	bltz	a0,96 <main+0x96>
    printf("%s: unlink failed\n", s);
    exit(1);
  }
  if (open(ff, O_RDONLY) != -1) {
  3c:	4581                	li	a1,0
  3e:	00001517          	auipc	a0,0x1
  42:	9d250513          	addi	a0,a0,-1582 # a10 <malloc+0x100>
  46:	402000ef          	jal	448 <open>
  4a:	57fd                	li	a5,-1
  4c:	04f50f63          	beq	a0,a5,aa <main+0xaa>
    printf("%s: open successed\n", s);
  50:	85a6                	mv	a1,s1
  52:	00001517          	auipc	a0,0x1
  56:	a1e50513          	addi	a0,a0,-1506 # a70 <malloc+0x160>
  5a:	7fe000ef          	jal	858 <printf>
    exit(1);
  5e:	4505                	li	a0,1
  60:	31c000ef          	jal	37c <exit>
    printf("%s: open failed\n", s);
  64:	85a6                	mv	a1,s1
  66:	00001517          	auipc	a0,0x1
  6a:	9ba50513          	addi	a0,a0,-1606 # a20 <malloc+0x110>
  6e:	7ea000ef          	jal	858 <printf>
    exit(1);
  72:	4505                	li	a0,1
  74:	308000ef          	jal	37c <exit>
    fprintf(2, "%s: cannot stat %s\n", s, "ff");
  78:	00001697          	auipc	a3,0x1
  7c:	9c068693          	addi	a3,a3,-1600 # a38 <malloc+0x128>
  80:	8626                	mv	a2,s1
  82:	00001597          	auipc	a1,0x1
  86:	9be58593          	addi	a1,a1,-1602 # a40 <malloc+0x130>
  8a:	4509                	li	a0,2
  8c:	7a2000ef          	jal	82e <fprintf>
    exit(1);
  90:	4505                	li	a0,1
  92:	2ea000ef          	jal	37c <exit>
    printf("%s: unlink failed\n", s);
  96:	85a6                	mv	a1,s1
  98:	00001517          	auipc	a0,0x1
  9c:	9c050513          	addi	a0,a0,-1600 # a58 <malloc+0x148>
  a0:	7b8000ef          	jal	858 <printf>
    exit(1);
  a4:	4505                	li	a0,1
  a6:	2d6000ef          	jal	37c <exit>
  }
  printf("wait for kill and reclaim %d\n", st.ino);
  aa:	fcc42583          	lw	a1,-52(s0)
  ae:	00001517          	auipc	a0,0x1
  b2:	9da50513          	addi	a0,a0,-1574 # a88 <malloc+0x178>
  b6:	7a2000ef          	jal	858 <printf>
  // sit around until killed
  for(;;) pause(1000);
  ba:	3e800493          	li	s1,1000
  be:	8526                	mv	a0,s1
  c0:	3d8000ef          	jal	498 <pause>
  c4:	bfed                	j	be <main+0xbe>

00000000000000c6 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  c6:	1141                	addi	sp,sp,-16
  c8:	e406                	sd	ra,8(sp)
  ca:	e022                	sd	s0,0(sp)
  cc:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  ce:	f33ff0ef          	jal	0 <main>
  exit(r);
  d2:	2aa000ef          	jal	37c <exit>

00000000000000d6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  d6:	1141                	addi	sp,sp,-16
  d8:	e406                	sd	ra,8(sp)
  da:	e022                	sd	s0,0(sp)
  dc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  de:	87aa                	mv	a5,a0
  e0:	0585                	addi	a1,a1,1
  e2:	0785                	addi	a5,a5,1
  e4:	fff5c703          	lbu	a4,-1(a1)
  e8:	fee78fa3          	sb	a4,-1(a5)
  ec:	fb75                	bnez	a4,e0 <strcpy+0xa>
    ;
  return os;
}
  ee:	60a2                	ld	ra,8(sp)
  f0:	6402                	ld	s0,0(sp)
  f2:	0141                	addi	sp,sp,16
  f4:	8082                	ret

00000000000000f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e406                	sd	ra,8(sp)
  fa:	e022                	sd	s0,0(sp)
  fc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  fe:	00054783          	lbu	a5,0(a0)
 102:	cb91                	beqz	a5,116 <strcmp+0x20>
 104:	0005c703          	lbu	a4,0(a1)
 108:	00f71763          	bne	a4,a5,116 <strcmp+0x20>
    p++, q++;
 10c:	0505                	addi	a0,a0,1
 10e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 110:	00054783          	lbu	a5,0(a0)
 114:	fbe5                	bnez	a5,104 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 116:	0005c503          	lbu	a0,0(a1)
}
 11a:	40a7853b          	subw	a0,a5,a0
 11e:	60a2                	ld	ra,8(sp)
 120:	6402                	ld	s0,0(sp)
 122:	0141                	addi	sp,sp,16
 124:	8082                	ret

0000000000000126 <strlen>:

uint
strlen(const char *s)
{
 126:	1141                	addi	sp,sp,-16
 128:	e406                	sd	ra,8(sp)
 12a:	e022                	sd	s0,0(sp)
 12c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 12e:	00054783          	lbu	a5,0(a0)
 132:	cf91                	beqz	a5,14e <strlen+0x28>
 134:	00150793          	addi	a5,a0,1
 138:	86be                	mv	a3,a5
 13a:	0785                	addi	a5,a5,1
 13c:	fff7c703          	lbu	a4,-1(a5)
 140:	ff65                	bnez	a4,138 <strlen+0x12>
 142:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 146:	60a2                	ld	ra,8(sp)
 148:	6402                	ld	s0,0(sp)
 14a:	0141                	addi	sp,sp,16
 14c:	8082                	ret
  for(n = 0; s[n]; n++)
 14e:	4501                	li	a0,0
 150:	bfdd                	j	146 <strlen+0x20>

0000000000000152 <memset>:

void*
memset(void *dst, int c, uint n)
{
 152:	1141                	addi	sp,sp,-16
 154:	e406                	sd	ra,8(sp)
 156:	e022                	sd	s0,0(sp)
 158:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 15a:	ca19                	beqz	a2,170 <memset+0x1e>
 15c:	87aa                	mv	a5,a0
 15e:	1602                	slli	a2,a2,0x20
 160:	9201                	srli	a2,a2,0x20
 162:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 166:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 16a:	0785                	addi	a5,a5,1
 16c:	fee79de3          	bne	a5,a4,166 <memset+0x14>
  }
  return dst;
}
 170:	60a2                	ld	ra,8(sp)
 172:	6402                	ld	s0,0(sp)
 174:	0141                	addi	sp,sp,16
 176:	8082                	ret

0000000000000178 <strchr>:

char*
strchr(const char *s, char c)
{
 178:	1141                	addi	sp,sp,-16
 17a:	e406                	sd	ra,8(sp)
 17c:	e022                	sd	s0,0(sp)
 17e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 180:	00054783          	lbu	a5,0(a0)
 184:	cf81                	beqz	a5,19c <strchr+0x24>
    if(*s == c)
 186:	00f58763          	beq	a1,a5,194 <strchr+0x1c>
  for(; *s; s++)
 18a:	0505                	addi	a0,a0,1
 18c:	00054783          	lbu	a5,0(a0)
 190:	fbfd                	bnez	a5,186 <strchr+0xe>
      return (char*)s;
  return 0;
 192:	4501                	li	a0,0
}
 194:	60a2                	ld	ra,8(sp)
 196:	6402                	ld	s0,0(sp)
 198:	0141                	addi	sp,sp,16
 19a:	8082                	ret
  return 0;
 19c:	4501                	li	a0,0
 19e:	bfdd                	j	194 <strchr+0x1c>

00000000000001a0 <gets>:

char*
gets(char *buf, int max)
{
 1a0:	711d                	addi	sp,sp,-96
 1a2:	ec86                	sd	ra,88(sp)
 1a4:	e8a2                	sd	s0,80(sp)
 1a6:	e4a6                	sd	s1,72(sp)
 1a8:	e0ca                	sd	s2,64(sp)
 1aa:	fc4e                	sd	s3,56(sp)
 1ac:	f852                	sd	s4,48(sp)
 1ae:	f456                	sd	s5,40(sp)
 1b0:	f05a                	sd	s6,32(sp)
 1b2:	ec5e                	sd	s7,24(sp)
 1b4:	e862                	sd	s8,16(sp)
 1b6:	1080                	addi	s0,sp,96
 1b8:	8baa                	mv	s7,a0
 1ba:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1bc:	892a                	mv	s2,a0
 1be:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1c0:	faf40b13          	addi	s6,s0,-81
 1c4:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1c6:	8c26                	mv	s8,s1
 1c8:	0014899b          	addiw	s3,s1,1
 1cc:	84ce                	mv	s1,s3
 1ce:	0349d463          	bge	s3,s4,1f6 <gets+0x56>
    cc = read(0, &c, 1);
 1d2:	8656                	mv	a2,s5
 1d4:	85da                	mv	a1,s6
 1d6:	4501                	li	a0,0
 1d8:	1bc000ef          	jal	394 <read>
    if(cc < 1)
 1dc:	00a05d63          	blez	a0,1f6 <gets+0x56>
      break;
    buf[i++] = c;
 1e0:	faf44783          	lbu	a5,-81(s0)
 1e4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1e8:	0905                	addi	s2,s2,1
 1ea:	ff678713          	addi	a4,a5,-10
 1ee:	c319                	beqz	a4,1f4 <gets+0x54>
 1f0:	17cd                	addi	a5,a5,-13
 1f2:	fbf1                	bnez	a5,1c6 <gets+0x26>
    buf[i++] = c;
 1f4:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1f6:	9c5e                	add	s8,s8,s7
 1f8:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1fc:	855e                	mv	a0,s7
 1fe:	60e6                	ld	ra,88(sp)
 200:	6446                	ld	s0,80(sp)
 202:	64a6                	ld	s1,72(sp)
 204:	6906                	ld	s2,64(sp)
 206:	79e2                	ld	s3,56(sp)
 208:	7a42                	ld	s4,48(sp)
 20a:	7aa2                	ld	s5,40(sp)
 20c:	7b02                	ld	s6,32(sp)
 20e:	6be2                	ld	s7,24(sp)
 210:	6c42                	ld	s8,16(sp)
 212:	6125                	addi	sp,sp,96
 214:	8082                	ret

0000000000000216 <stat>:

int
stat(const char *n, struct stat *st)
{
 216:	1101                	addi	sp,sp,-32
 218:	ec06                	sd	ra,24(sp)
 21a:	e822                	sd	s0,16(sp)
 21c:	e04a                	sd	s2,0(sp)
 21e:	1000                	addi	s0,sp,32
 220:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 222:	4581                	li	a1,0
 224:	224000ef          	jal	448 <open>
  if(fd < 0)
 228:	02054263          	bltz	a0,24c <stat+0x36>
 22c:	e426                	sd	s1,8(sp)
 22e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 230:	85ca                	mv	a1,s2
 232:	22e000ef          	jal	460 <fstat>
 236:	892a                	mv	s2,a0
  close(fd);
 238:	8526                	mv	a0,s1
 23a:	16a000ef          	jal	3a4 <close>
  return r;
 23e:	64a2                	ld	s1,8(sp)
}
 240:	854a                	mv	a0,s2
 242:	60e2                	ld	ra,24(sp)
 244:	6442                	ld	s0,16(sp)
 246:	6902                	ld	s2,0(sp)
 248:	6105                	addi	sp,sp,32
 24a:	8082                	ret
    return -1;
 24c:	57fd                	li	a5,-1
 24e:	893e                	mv	s2,a5
 250:	bfc5                	j	240 <stat+0x2a>

0000000000000252 <atoi>:

int
atoi(const char *s)
{
 252:	1141                	addi	sp,sp,-16
 254:	e406                	sd	ra,8(sp)
 256:	e022                	sd	s0,0(sp)
 258:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 25a:	00054683          	lbu	a3,0(a0)
 25e:	fd06879b          	addiw	a5,a3,-48
 262:	0ff7f793          	zext.b	a5,a5
 266:	4625                	li	a2,9
 268:	02f66963          	bltu	a2,a5,29a <atoi+0x48>
 26c:	872a                	mv	a4,a0
  n = 0;
 26e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 270:	0705                	addi	a4,a4,1
 272:	0025179b          	slliw	a5,a0,0x2
 276:	9fa9                	addw	a5,a5,a0
 278:	0017979b          	slliw	a5,a5,0x1
 27c:	9fb5                	addw	a5,a5,a3
 27e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 282:	00074683          	lbu	a3,0(a4)
 286:	fd06879b          	addiw	a5,a3,-48
 28a:	0ff7f793          	zext.b	a5,a5
 28e:	fef671e3          	bgeu	a2,a5,270 <atoi+0x1e>
  return n;
}
 292:	60a2                	ld	ra,8(sp)
 294:	6402                	ld	s0,0(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret
  n = 0;
 29a:	4501                	li	a0,0
 29c:	bfdd                	j	292 <atoi+0x40>

000000000000029e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e406                	sd	ra,8(sp)
 2a2:	e022                	sd	s0,0(sp)
 2a4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2a6:	02b57563          	bgeu	a0,a1,2d0 <memmove+0x32>
    while(n-- > 0)
 2aa:	00c05f63          	blez	a2,2c8 <memmove+0x2a>
 2ae:	1602                	slli	a2,a2,0x20
 2b0:	9201                	srli	a2,a2,0x20
 2b2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2b6:	872a                	mv	a4,a0
      *dst++ = *src++;
 2b8:	0585                	addi	a1,a1,1
 2ba:	0705                	addi	a4,a4,1
 2bc:	fff5c683          	lbu	a3,-1(a1)
 2c0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2c4:	fee79ae3          	bne	a5,a4,2b8 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2c8:	60a2                	ld	ra,8(sp)
 2ca:	6402                	ld	s0,0(sp)
 2cc:	0141                	addi	sp,sp,16
 2ce:	8082                	ret
    while(n-- > 0)
 2d0:	fec05ce3          	blez	a2,2c8 <memmove+0x2a>
    dst += n;
 2d4:	00c50733          	add	a4,a0,a2
    src += n;
 2d8:	95b2                	add	a1,a1,a2
 2da:	fff6079b          	addiw	a5,a2,-1
 2de:	1782                	slli	a5,a5,0x20
 2e0:	9381                	srli	a5,a5,0x20
 2e2:	fff7c793          	not	a5,a5
 2e6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2e8:	15fd                	addi	a1,a1,-1
 2ea:	177d                	addi	a4,a4,-1
 2ec:	0005c683          	lbu	a3,0(a1)
 2f0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2f4:	fef71ae3          	bne	a4,a5,2e8 <memmove+0x4a>
 2f8:	bfc1                	j	2c8 <memmove+0x2a>

00000000000002fa <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2fa:	1141                	addi	sp,sp,-16
 2fc:	e406                	sd	ra,8(sp)
 2fe:	e022                	sd	s0,0(sp)
 300:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 302:	c61d                	beqz	a2,330 <memcmp+0x36>
 304:	1602                	slli	a2,a2,0x20
 306:	9201                	srli	a2,a2,0x20
 308:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 30c:	00054783          	lbu	a5,0(a0)
 310:	0005c703          	lbu	a4,0(a1)
 314:	00e79863          	bne	a5,a4,324 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 318:	0505                	addi	a0,a0,1
    p2++;
 31a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 31c:	fed518e3          	bne	a0,a3,30c <memcmp+0x12>
  }
  return 0;
 320:	4501                	li	a0,0
 322:	a019                	j	328 <memcmp+0x2e>
      return *p1 - *p2;
 324:	40e7853b          	subw	a0,a5,a4
}
 328:	60a2                	ld	ra,8(sp)
 32a:	6402                	ld	s0,0(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret
  return 0;
 330:	4501                	li	a0,0
 332:	bfdd                	j	328 <memcmp+0x2e>

0000000000000334 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 334:	1141                	addi	sp,sp,-16
 336:	e406                	sd	ra,8(sp)
 338:	e022                	sd	s0,0(sp)
 33a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 33c:	f63ff0ef          	jal	29e <memmove>
}
 340:	60a2                	ld	ra,8(sp)
 342:	6402                	ld	s0,0(sp)
 344:	0141                	addi	sp,sp,16
 346:	8082                	ret

0000000000000348 <sbrk>:

char *
sbrk(int n) {
 348:	1141                	addi	sp,sp,-16
 34a:	e406                	sd	ra,8(sp)
 34c:	e022                	sd	s0,0(sp)
 34e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 350:	4585                	li	a1,1
 352:	13e000ef          	jal	490 <sys_sbrk>
}
 356:	60a2                	ld	ra,8(sp)
 358:	6402                	ld	s0,0(sp)
 35a:	0141                	addi	sp,sp,16
 35c:	8082                	ret

000000000000035e <sbrklazy>:

char *
sbrklazy(int n) {
 35e:	1141                	addi	sp,sp,-16
 360:	e406                	sd	ra,8(sp)
 362:	e022                	sd	s0,0(sp)
 364:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 366:	4589                	li	a1,2
 368:	128000ef          	jal	490 <sys_sbrk>
}
 36c:	60a2                	ld	ra,8(sp)
 36e:	6402                	ld	s0,0(sp)
 370:	0141                	addi	sp,sp,16
 372:	8082                	ret

0000000000000374 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 374:	4885                	li	a7,1
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <exit>:
.global exit
exit:
 li a7, SYS_exit
 37c:	4889                	li	a7,2
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <wait>:
.global wait
wait:
 li a7, SYS_wait
 384:	488d                	li	a7,3
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 38c:	4891                	li	a7,4
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <read>:
.global read
read:
 li a7, SYS_read
 394:	4895                	li	a7,5
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <write>:
.global write
write:
 li a7, SYS_write
 39c:	48c1                	li	a7,16
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <close>:
.global close
close:
 li a7, SYS_close
 3a4:	48d5                	li	a7,21
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 3ac:	48d9                	li	a7,22
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <shmat>:
.global shmat
shmat:
 li a7, SYS_shmat
 3b4:	48dd                	li	a7,23
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 3bc:	48e1                	li	a7,24
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 3c4:	48e5                	li	a7,25
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <lockinit>:
.global lockinit
lockinit:
 li a7, SYS_lockinit
 3cc:	48e9                	li	a7,26
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <lockacquire>:
.global lockacquire
lockacquire:
 li a7, SYS_lockacquire
 3d4:	48ed                	li	a7,27
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <lockrelease>:
.global lockrelease
lockrelease:
 li a7, SYS_lockrelease
 3dc:	48f1                	li	a7,28
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <locktry>:
.global locktry
locktry:
 li a7, SYS_locktry
 3e4:	48f5                	li	a7,29
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <lockcheck>:
.global lockcheck
lockcheck:
 li a7, SYS_lockcheck
 3ec:	48f9                	li	a7,30
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <sendmsg>:
.global sendmsg
sendmsg:
 li a7, SYS_sendmsg
 3f4:	48fd                	li	a7,31
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <recvmsg>:
.global recvmsg
recvmsg:
 li a7, SYS_recvmsg
 3fc:	02000893          	li	a7,32
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <broadcast>:
.global broadcast
broadcast:
 li a7, SYS_broadcast
 406:	02100893          	li	a7,33
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <getprocsinfo>:
.global getprocsinfo
getprocsinfo:
 li a7, SYS_getprocsinfo
 410:	02200893          	li	a7,34
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 41a:	02300893          	li	a7,35
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <sleep2>:
.global sleep2
sleep2:
 li a7, SYS_sleep2
 424:	02400893          	li	a7,36
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <signal>:
.global signal
signal:
 li a7, SYS_signal
 42e:	02500893          	li	a7,37
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <kill>:
.global kill
kill:
 li a7, SYS_kill
 438:	4899                	li	a7,6
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <exec>:
.global exec
exec:
 li a7, SYS_exec
 440:	489d                	li	a7,7
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <open>:
.global open
open:
 li a7, SYS_open
 448:	48bd                	li	a7,15
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 450:	48c5                	li	a7,17
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 458:	48c9                	li	a7,18
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 460:	48a1                	li	a7,8
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <link>:
.global link
link:
 li a7, SYS_link
 468:	48cd                	li	a7,19
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 470:	48d1                	li	a7,20
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 478:	48a5                	li	a7,9
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <dup>:
.global dup
dup:
 li a7, SYS_dup
 480:	48a9                	li	a7,10
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 488:	48ad                	li	a7,11
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 490:	48b1                	li	a7,12
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <pause>:
.global pause
pause:
 li a7, SYS_pause
 498:	48b5                	li	a7,13
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4a0:	48b9                	li	a7,14
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <setchildlimit>:
.global setchildlimit
setchildlimit:
 li a7, SYS_setchildlimit
 4a8:	02600893          	li	a7,38
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4b2:	1101                	addi	sp,sp,-32
 4b4:	ec06                	sd	ra,24(sp)
 4b6:	e822                	sd	s0,16(sp)
 4b8:	1000                	addi	s0,sp,32
 4ba:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4be:	4605                	li	a2,1
 4c0:	fef40593          	addi	a1,s0,-17
 4c4:	ed9ff0ef          	jal	39c <write>
}
 4c8:	60e2                	ld	ra,24(sp)
 4ca:	6442                	ld	s0,16(sp)
 4cc:	6105                	addi	sp,sp,32
 4ce:	8082                	ret

00000000000004d0 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4d0:	715d                	addi	sp,sp,-80
 4d2:	e486                	sd	ra,72(sp)
 4d4:	e0a2                	sd	s0,64(sp)
 4d6:	f84a                	sd	s2,48(sp)
 4d8:	f44e                	sd	s3,40(sp)
 4da:	0880                	addi	s0,sp,80
 4dc:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4de:	c6d1                	beqz	a3,56a <printint+0x9a>
 4e0:	0805d563          	bgez	a1,56a <printint+0x9a>
    neg = 1;
    x = -xx;
 4e4:	40b005b3          	neg	a1,a1
    neg = 1;
 4e8:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 4ea:	fb840993          	addi	s3,s0,-72
  neg = 0;
 4ee:	86ce                	mv	a3,s3
  i = 0;
 4f0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4f2:	00000817          	auipc	a6,0x0
 4f6:	5be80813          	addi	a6,a6,1470 # ab0 <digits>
 4fa:	88ba                	mv	a7,a4
 4fc:	0017051b          	addiw	a0,a4,1
 500:	872a                	mv	a4,a0
 502:	02c5f7b3          	remu	a5,a1,a2
 506:	97c2                	add	a5,a5,a6
 508:	0007c783          	lbu	a5,0(a5)
 50c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 510:	87ae                	mv	a5,a1
 512:	02c5d5b3          	divu	a1,a1,a2
 516:	0685                	addi	a3,a3,1
 518:	fec7f1e3          	bgeu	a5,a2,4fa <printint+0x2a>
  if(neg)
 51c:	00030c63          	beqz	t1,534 <printint+0x64>
    buf[i++] = '-';
 520:	fd050793          	addi	a5,a0,-48
 524:	00878533          	add	a0,a5,s0
 528:	02d00793          	li	a5,45
 52c:	fef50423          	sb	a5,-24(a0)
 530:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 534:	02e05563          	blez	a4,55e <printint+0x8e>
 538:	fc26                	sd	s1,56(sp)
 53a:	377d                	addiw	a4,a4,-1
 53c:	00e984b3          	add	s1,s3,a4
 540:	19fd                	addi	s3,s3,-1
 542:	99ba                	add	s3,s3,a4
 544:	1702                	slli	a4,a4,0x20
 546:	9301                	srli	a4,a4,0x20
 548:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 54c:	0004c583          	lbu	a1,0(s1)
 550:	854a                	mv	a0,s2
 552:	f61ff0ef          	jal	4b2 <putc>
  while(--i >= 0)
 556:	14fd                	addi	s1,s1,-1
 558:	ff349ae3          	bne	s1,s3,54c <printint+0x7c>
 55c:	74e2                	ld	s1,56(sp)
}
 55e:	60a6                	ld	ra,72(sp)
 560:	6406                	ld	s0,64(sp)
 562:	7942                	ld	s2,48(sp)
 564:	79a2                	ld	s3,40(sp)
 566:	6161                	addi	sp,sp,80
 568:	8082                	ret
  neg = 0;
 56a:	4301                	li	t1,0
 56c:	bfbd                	j	4ea <printint+0x1a>

000000000000056e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 56e:	711d                	addi	sp,sp,-96
 570:	ec86                	sd	ra,88(sp)
 572:	e8a2                	sd	s0,80(sp)
 574:	e4a6                	sd	s1,72(sp)
 576:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 578:	0005c483          	lbu	s1,0(a1)
 57c:	22048363          	beqz	s1,7a2 <vprintf+0x234>
 580:	e0ca                	sd	s2,64(sp)
 582:	fc4e                	sd	s3,56(sp)
 584:	f852                	sd	s4,48(sp)
 586:	f456                	sd	s5,40(sp)
 588:	f05a                	sd	s6,32(sp)
 58a:	ec5e                	sd	s7,24(sp)
 58c:	e862                	sd	s8,16(sp)
 58e:	8b2a                	mv	s6,a0
 590:	8a2e                	mv	s4,a1
 592:	8bb2                	mv	s7,a2
  state = 0;
 594:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 596:	4901                	li	s2,0
 598:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 59a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 59e:	06400c13          	li	s8,100
 5a2:	a00d                	j	5c4 <vprintf+0x56>
        putc(fd, c0);
 5a4:	85a6                	mv	a1,s1
 5a6:	855a                	mv	a0,s6
 5a8:	f0bff0ef          	jal	4b2 <putc>
 5ac:	a019                	j	5b2 <vprintf+0x44>
    } else if(state == '%'){
 5ae:	03598363          	beq	s3,s5,5d4 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 5b2:	0019079b          	addiw	a5,s2,1
 5b6:	893e                	mv	s2,a5
 5b8:	873e                	mv	a4,a5
 5ba:	97d2                	add	a5,a5,s4
 5bc:	0007c483          	lbu	s1,0(a5)
 5c0:	1c048a63          	beqz	s1,794 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 5c4:	0004879b          	sext.w	a5,s1
    if(state == 0){
 5c8:	fe0993e3          	bnez	s3,5ae <vprintf+0x40>
      if(c0 == '%'){
 5cc:	fd579ce3          	bne	a5,s5,5a4 <vprintf+0x36>
        state = '%';
 5d0:	89be                	mv	s3,a5
 5d2:	b7c5                	j	5b2 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 5d4:	00ea06b3          	add	a3,s4,a4
 5d8:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 5dc:	1c060863          	beqz	a2,7ac <vprintf+0x23e>
      if(c0 == 'd'){
 5e0:	03878763          	beq	a5,s8,60e <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5e4:	f9478693          	addi	a3,a5,-108
 5e8:	0016b693          	seqz	a3,a3
 5ec:	f9c60593          	addi	a1,a2,-100
 5f0:	e99d                	bnez	a1,626 <vprintf+0xb8>
 5f2:	ca95                	beqz	a3,626 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f4:	008b8493          	addi	s1,s7,8
 5f8:	4685                	li	a3,1
 5fa:	4629                	li	a2,10
 5fc:	000bb583          	ld	a1,0(s7)
 600:	855a                	mv	a0,s6
 602:	ecfff0ef          	jal	4d0 <printint>
        i += 1;
 606:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 608:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 60a:	4981                	li	s3,0
 60c:	b75d                	j	5b2 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 60e:	008b8493          	addi	s1,s7,8
 612:	4685                	li	a3,1
 614:	4629                	li	a2,10
 616:	000ba583          	lw	a1,0(s7)
 61a:	855a                	mv	a0,s6
 61c:	eb5ff0ef          	jal	4d0 <printint>
 620:	8ba6                	mv	s7,s1
      state = 0;
 622:	4981                	li	s3,0
 624:	b779                	j	5b2 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 626:	9752                	add	a4,a4,s4
 628:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 62c:	f9460713          	addi	a4,a2,-108
 630:	00173713          	seqz	a4,a4
 634:	8f75                	and	a4,a4,a3
 636:	f9c58513          	addi	a0,a1,-100
 63a:	18051363          	bnez	a0,7c0 <vprintf+0x252>
 63e:	18070163          	beqz	a4,7c0 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 642:	008b8493          	addi	s1,s7,8
 646:	4685                	li	a3,1
 648:	4629                	li	a2,10
 64a:	000bb583          	ld	a1,0(s7)
 64e:	855a                	mv	a0,s6
 650:	e81ff0ef          	jal	4d0 <printint>
        i += 2;
 654:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 656:	8ba6                	mv	s7,s1
      state = 0;
 658:	4981                	li	s3,0
        i += 2;
 65a:	bfa1                	j	5b2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 65c:	008b8493          	addi	s1,s7,8
 660:	4681                	li	a3,0
 662:	4629                	li	a2,10
 664:	000be583          	lwu	a1,0(s7)
 668:	855a                	mv	a0,s6
 66a:	e67ff0ef          	jal	4d0 <printint>
 66e:	8ba6                	mv	s7,s1
      state = 0;
 670:	4981                	li	s3,0
 672:	b781                	j	5b2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 674:	008b8493          	addi	s1,s7,8
 678:	4681                	li	a3,0
 67a:	4629                	li	a2,10
 67c:	000bb583          	ld	a1,0(s7)
 680:	855a                	mv	a0,s6
 682:	e4fff0ef          	jal	4d0 <printint>
        i += 1;
 686:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 688:	8ba6                	mv	s7,s1
      state = 0;
 68a:	4981                	li	s3,0
 68c:	b71d                	j	5b2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 68e:	008b8493          	addi	s1,s7,8
 692:	4681                	li	a3,0
 694:	4629                	li	a2,10
 696:	000bb583          	ld	a1,0(s7)
 69a:	855a                	mv	a0,s6
 69c:	e35ff0ef          	jal	4d0 <printint>
        i += 2;
 6a0:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a2:	8ba6                	mv	s7,s1
      state = 0;
 6a4:	4981                	li	s3,0
        i += 2;
 6a6:	b731                	j	5b2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6a8:	008b8493          	addi	s1,s7,8
 6ac:	4681                	li	a3,0
 6ae:	4641                	li	a2,16
 6b0:	000be583          	lwu	a1,0(s7)
 6b4:	855a                	mv	a0,s6
 6b6:	e1bff0ef          	jal	4d0 <printint>
 6ba:	8ba6                	mv	s7,s1
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	bdd5                	j	5b2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c0:	008b8493          	addi	s1,s7,8
 6c4:	4681                	li	a3,0
 6c6:	4641                	li	a2,16
 6c8:	000bb583          	ld	a1,0(s7)
 6cc:	855a                	mv	a0,s6
 6ce:	e03ff0ef          	jal	4d0 <printint>
        i += 1;
 6d2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d4:	8ba6                	mv	s7,s1
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	bde9                	j	5b2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6da:	008b8493          	addi	s1,s7,8
 6de:	4681                	li	a3,0
 6e0:	4641                	li	a2,16
 6e2:	000bb583          	ld	a1,0(s7)
 6e6:	855a                	mv	a0,s6
 6e8:	de9ff0ef          	jal	4d0 <printint>
        i += 2;
 6ec:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ee:	8ba6                	mv	s7,s1
      state = 0;
 6f0:	4981                	li	s3,0
        i += 2;
 6f2:	b5c1                	j	5b2 <vprintf+0x44>
 6f4:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 6f6:	008b8793          	addi	a5,s7,8
 6fa:	8cbe                	mv	s9,a5
 6fc:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 700:	03000593          	li	a1,48
 704:	855a                	mv	a0,s6
 706:	dadff0ef          	jal	4b2 <putc>
  putc(fd, 'x');
 70a:	07800593          	li	a1,120
 70e:	855a                	mv	a0,s6
 710:	da3ff0ef          	jal	4b2 <putc>
 714:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 716:	00000b97          	auipc	s7,0x0
 71a:	39ab8b93          	addi	s7,s7,922 # ab0 <digits>
 71e:	03c9d793          	srli	a5,s3,0x3c
 722:	97de                	add	a5,a5,s7
 724:	0007c583          	lbu	a1,0(a5)
 728:	855a                	mv	a0,s6
 72a:	d89ff0ef          	jal	4b2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 72e:	0992                	slli	s3,s3,0x4
 730:	34fd                	addiw	s1,s1,-1
 732:	f4f5                	bnez	s1,71e <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 734:	8be6                	mv	s7,s9
      state = 0;
 736:	4981                	li	s3,0
 738:	6ca2                	ld	s9,8(sp)
 73a:	bda5                	j	5b2 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 73c:	008b8493          	addi	s1,s7,8
 740:	000bc583          	lbu	a1,0(s7)
 744:	855a                	mv	a0,s6
 746:	d6dff0ef          	jal	4b2 <putc>
 74a:	8ba6                	mv	s7,s1
      state = 0;
 74c:	4981                	li	s3,0
 74e:	b595                	j	5b2 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 750:	008b8993          	addi	s3,s7,8
 754:	000bb483          	ld	s1,0(s7)
 758:	cc91                	beqz	s1,774 <vprintf+0x206>
        for(; *s; s++)
 75a:	0004c583          	lbu	a1,0(s1)
 75e:	c985                	beqz	a1,78e <vprintf+0x220>
          putc(fd, *s);
 760:	855a                	mv	a0,s6
 762:	d51ff0ef          	jal	4b2 <putc>
        for(; *s; s++)
 766:	0485                	addi	s1,s1,1
 768:	0004c583          	lbu	a1,0(s1)
 76c:	f9f5                	bnez	a1,760 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 76e:	8bce                	mv	s7,s3
      state = 0;
 770:	4981                	li	s3,0
 772:	b581                	j	5b2 <vprintf+0x44>
          s = "(null)";
 774:	00000497          	auipc	s1,0x0
 778:	33448493          	addi	s1,s1,820 # aa8 <malloc+0x198>
        for(; *s; s++)
 77c:	02800593          	li	a1,40
 780:	b7c5                	j	760 <vprintf+0x1f2>
        putc(fd, '%');
 782:	85be                	mv	a1,a5
 784:	855a                	mv	a0,s6
 786:	d2dff0ef          	jal	4b2 <putc>
      state = 0;
 78a:	4981                	li	s3,0
 78c:	b51d                	j	5b2 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 78e:	8bce                	mv	s7,s3
      state = 0;
 790:	4981                	li	s3,0
 792:	b505                	j	5b2 <vprintf+0x44>
 794:	6906                	ld	s2,64(sp)
 796:	79e2                	ld	s3,56(sp)
 798:	7a42                	ld	s4,48(sp)
 79a:	7aa2                	ld	s5,40(sp)
 79c:	7b02                	ld	s6,32(sp)
 79e:	6be2                	ld	s7,24(sp)
 7a0:	6c42                	ld	s8,16(sp)
    }
  }
}
 7a2:	60e6                	ld	ra,88(sp)
 7a4:	6446                	ld	s0,80(sp)
 7a6:	64a6                	ld	s1,72(sp)
 7a8:	6125                	addi	sp,sp,96
 7aa:	8082                	ret
      if(c0 == 'd'){
 7ac:	06400713          	li	a4,100
 7b0:	e4e78fe3          	beq	a5,a4,60e <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 7b4:	f9478693          	addi	a3,a5,-108
 7b8:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 7bc:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7be:	4701                	li	a4,0
      } else if(c0 == 'u'){
 7c0:	07500513          	li	a0,117
 7c4:	e8a78ce3          	beq	a5,a0,65c <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 7c8:	f8b60513          	addi	a0,a2,-117
 7cc:	e119                	bnez	a0,7d2 <vprintf+0x264>
 7ce:	ea0693e3          	bnez	a3,674 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7d2:	f8b58513          	addi	a0,a1,-117
 7d6:	e119                	bnez	a0,7dc <vprintf+0x26e>
 7d8:	ea071be3          	bnez	a4,68e <vprintf+0x120>
      } else if(c0 == 'x'){
 7dc:	07800513          	li	a0,120
 7e0:	eca784e3          	beq	a5,a0,6a8 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 7e4:	f8860613          	addi	a2,a2,-120
 7e8:	e219                	bnez	a2,7ee <vprintf+0x280>
 7ea:	ec069be3          	bnez	a3,6c0 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7ee:	f8858593          	addi	a1,a1,-120
 7f2:	e199                	bnez	a1,7f8 <vprintf+0x28a>
 7f4:	ee0713e3          	bnez	a4,6da <vprintf+0x16c>
      } else if(c0 == 'p'){
 7f8:	07000713          	li	a4,112
 7fc:	eee78ce3          	beq	a5,a4,6f4 <vprintf+0x186>
      } else if(c0 == 'c'){
 800:	06300713          	li	a4,99
 804:	f2e78ce3          	beq	a5,a4,73c <vprintf+0x1ce>
      } else if(c0 == 's'){
 808:	07300713          	li	a4,115
 80c:	f4e782e3          	beq	a5,a4,750 <vprintf+0x1e2>
      } else if(c0 == '%'){
 810:	02500713          	li	a4,37
 814:	f6e787e3          	beq	a5,a4,782 <vprintf+0x214>
        putc(fd, '%');
 818:	02500593          	li	a1,37
 81c:	855a                	mv	a0,s6
 81e:	c95ff0ef          	jal	4b2 <putc>
        putc(fd, c0);
 822:	85a6                	mv	a1,s1
 824:	855a                	mv	a0,s6
 826:	c8dff0ef          	jal	4b2 <putc>
      state = 0;
 82a:	4981                	li	s3,0
 82c:	b359                	j	5b2 <vprintf+0x44>

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
 846:	8622                	mv	a2,s0
 848:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 84c:	d23ff0ef          	jal	56e <vprintf>
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
 87e:	cf1ff0ef          	jal	56e <vprintf>
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
 88c:	e406                	sd	ra,8(sp)
 88e:	e022                	sd	s0,0(sp)
 890:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 892:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 896:	00000797          	auipc	a5,0x0
 89a:	76a7b783          	ld	a5,1898(a5) # 1000 <freep>
 89e:	a039                	j	8ac <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a0:	6398                	ld	a4,0(a5)
 8a2:	00e7e463          	bltu	a5,a4,8aa <free+0x20>
 8a6:	00e6ea63          	bltu	a3,a4,8ba <free+0x30>
{
 8aa:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ac:	fed7fae3          	bgeu	a5,a3,8a0 <free+0x16>
 8b0:	6398                	ld	a4,0(a5)
 8b2:	00e6e463          	bltu	a3,a4,8ba <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b6:	fee7eae3          	bltu	a5,a4,8aa <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8ba:	ff852583          	lw	a1,-8(a0)
 8be:	6390                	ld	a2,0(a5)
 8c0:	02059813          	slli	a6,a1,0x20
 8c4:	01c85713          	srli	a4,a6,0x1c
 8c8:	9736                	add	a4,a4,a3
 8ca:	02e60563          	beq	a2,a4,8f4 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 8ce:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 8d2:	4790                	lw	a2,8(a5)
 8d4:	02061593          	slli	a1,a2,0x20
 8d8:	01c5d713          	srli	a4,a1,0x1c
 8dc:	973e                	add	a4,a4,a5
 8de:	02e68263          	beq	a3,a4,902 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 8e2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8e4:	00000717          	auipc	a4,0x0
 8e8:	70f73e23          	sd	a5,1820(a4) # 1000 <freep>
}
 8ec:	60a2                	ld	ra,8(sp)
 8ee:	6402                	ld	s0,0(sp)
 8f0:	0141                	addi	sp,sp,16
 8f2:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 8f4:	4618                	lw	a4,8(a2)
 8f6:	9f2d                	addw	a4,a4,a1
 8f8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8fc:	6398                	ld	a4,0(a5)
 8fe:	6310                	ld	a2,0(a4)
 900:	b7f9                	j	8ce <free+0x44>
    p->s.size += bp->s.size;
 902:	ff852703          	lw	a4,-8(a0)
 906:	9f31                	addw	a4,a4,a2
 908:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 90a:	ff053683          	ld	a3,-16(a0)
 90e:	bfd1                	j	8e2 <free+0x58>

0000000000000910 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 910:	7139                	addi	sp,sp,-64
 912:	fc06                	sd	ra,56(sp)
 914:	f822                	sd	s0,48(sp)
 916:	f04a                	sd	s2,32(sp)
 918:	ec4e                	sd	s3,24(sp)
 91a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 91c:	02051993          	slli	s3,a0,0x20
 920:	0209d993          	srli	s3,s3,0x20
 924:	09bd                	addi	s3,s3,15
 926:	0049d993          	srli	s3,s3,0x4
 92a:	2985                	addiw	s3,s3,1
 92c:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 92e:	00000517          	auipc	a0,0x0
 932:	6d253503          	ld	a0,1746(a0) # 1000 <freep>
 936:	c905                	beqz	a0,966 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 938:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 93a:	4798                	lw	a4,8(a5)
 93c:	09377663          	bgeu	a4,s3,9c8 <malloc+0xb8>
 940:	f426                	sd	s1,40(sp)
 942:	e852                	sd	s4,16(sp)
 944:	e456                	sd	s5,8(sp)
 946:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 948:	8a4e                	mv	s4,s3
 94a:	6705                	lui	a4,0x1
 94c:	00e9f363          	bgeu	s3,a4,952 <malloc+0x42>
 950:	6a05                	lui	s4,0x1
 952:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 956:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 95a:	00000497          	auipc	s1,0x0
 95e:	6a648493          	addi	s1,s1,1702 # 1000 <freep>
  if(p == SBRK_ERROR)
 962:	5afd                	li	s5,-1
 964:	a83d                	j	9a2 <malloc+0x92>
 966:	f426                	sd	s1,40(sp)
 968:	e852                	sd	s4,16(sp)
 96a:	e456                	sd	s5,8(sp)
 96c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 96e:	00001797          	auipc	a5,0x1
 972:	89a78793          	addi	a5,a5,-1894 # 1208 <base>
 976:	00000717          	auipc	a4,0x0
 97a:	68f73523          	sd	a5,1674(a4) # 1000 <freep>
 97e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 980:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 984:	b7d1                	j	948 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 986:	6398                	ld	a4,0(a5)
 988:	e118                	sd	a4,0(a0)
 98a:	a899                	j	9e0 <malloc+0xd0>
  hp->s.size = nu;
 98c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 990:	0541                	addi	a0,a0,16
 992:	ef9ff0ef          	jal	88a <free>
  return freep;
 996:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 998:	c125                	beqz	a0,9f8 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 99a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 99c:	4798                	lw	a4,8(a5)
 99e:	03277163          	bgeu	a4,s2,9c0 <malloc+0xb0>
    if(p == freep)
 9a2:	6098                	ld	a4,0(s1)
 9a4:	853e                	mv	a0,a5
 9a6:	fef71ae3          	bne	a4,a5,99a <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 9aa:	8552                	mv	a0,s4
 9ac:	99dff0ef          	jal	348 <sbrk>
  if(p == SBRK_ERROR)
 9b0:	fd551ee3          	bne	a0,s5,98c <malloc+0x7c>
        return 0;
 9b4:	4501                	li	a0,0
 9b6:	74a2                	ld	s1,40(sp)
 9b8:	6a42                	ld	s4,16(sp)
 9ba:	6aa2                	ld	s5,8(sp)
 9bc:	6b02                	ld	s6,0(sp)
 9be:	a03d                	j	9ec <malloc+0xdc>
 9c0:	74a2                	ld	s1,40(sp)
 9c2:	6a42                	ld	s4,16(sp)
 9c4:	6aa2                	ld	s5,8(sp)
 9c6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9c8:	fae90fe3          	beq	s2,a4,986 <malloc+0x76>
        p->s.size -= nunits;
 9cc:	4137073b          	subw	a4,a4,s3
 9d0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9d2:	02071693          	slli	a3,a4,0x20
 9d6:	01c6d713          	srli	a4,a3,0x1c
 9da:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9dc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9e0:	00000717          	auipc	a4,0x0
 9e4:	62a73023          	sd	a0,1568(a4) # 1000 <freep>
      return (void*)(p + 1);
 9e8:	01078513          	addi	a0,a5,16
  }
}
 9ec:	70e2                	ld	ra,56(sp)
 9ee:	7442                	ld	s0,48(sp)
 9f0:	7902                	ld	s2,32(sp)
 9f2:	69e2                	ld	s3,24(sp)
 9f4:	6121                	addi	sp,sp,64
 9f6:	8082                	ret
 9f8:	74a2                	ld	s1,40(sp)
 9fa:	6a42                	ld	s4,16(sp)
 9fc:	6aa2                	ld	s5,8(sp)
 9fe:	6b02                	ld	s6,0(sp)
 a00:	b7f5                	j	9ec <malloc+0xdc>
