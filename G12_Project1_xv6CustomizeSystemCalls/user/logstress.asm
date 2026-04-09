
user/_logstress:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
main(int argc, char **argv)
{
  int fd, n;
  enum { N = 250, SZ=2000 };
  
  for (int i = 1; i < argc; i++){
   0:	4785                	li	a5,1
   2:	0ea7de63          	bge	a5,a0,fe <main+0xfe>
{
   6:	7139                	addi	sp,sp,-64
   8:	fc06                	sd	ra,56(sp)
   a:	f822                	sd	s0,48(sp)
   c:	f426                	sd	s1,40(sp)
   e:	f04a                	sd	s2,32(sp)
  10:	ec4e                	sd	s3,24(sp)
  12:	e852                	sd	s4,16(sp)
  14:	0080                	addi	s0,sp,64
  16:	892a                	mv	s2,a0
  18:	8a2e                	mv	s4,a1
  for (int i = 1; i < argc; i++){
  1a:	84be                	mv	s1,a5
  1c:	a011                	j	20 <main+0x20>
  1e:	84be                	mv	s1,a5
    int pid1 = fork();
  20:	390000ef          	jal	3b0 <fork>
    if(pid1 < 0){
  24:	00054b63          	bltz	a0,3a <main+0x3a>
      printf("%s: fork failed\n", argv[0]);
      exit(1);
    }
    if(pid1 == 0) {
  28:	c505                	beqz	a0,50 <main+0x50>
  for (int i = 1; i < argc; i++){
  2a:	0014879b          	addiw	a5,s1,1
  2e:	fef918e3          	bne	s2,a5,1e <main+0x1e>
      }
      exit(0);
    }
  }
  int xstatus;
  for(int i = 1; i < argc; i++){
  32:	4905                	li	s2,1
    wait(&xstatus);
  34:	fcc40993          	addi	s3,s0,-52
  38:	a871                	j	d4 <main+0xd4>
      printf("%s: fork failed\n", argv[0]);
  3a:	000a3583          	ld	a1,0(s4)
  3e:	00001517          	auipc	a0,0x1
  42:	98250513          	addi	a0,a0,-1662 # 9c0 <malloc+0xf2>
  46:	7d0000ef          	jal	816 <printf>
      exit(1);
  4a:	4505                	li	a0,1
  4c:	36c000ef          	jal	3b8 <exit>
      fd = open(argv[i], O_CREATE | O_RDWR);
  50:	00349913          	slli	s2,s1,0x3
  54:	9952                	add	s2,s2,s4
  56:	20200593          	li	a1,514
  5a:	00093503          	ld	a0,0(s2)
  5e:	39a000ef          	jal	3f8 <open>
  62:	89aa                	mv	s3,a0
      if(fd < 0){
  64:	04054063          	bltz	a0,a4 <main+0xa4>
      memset(buf, '0'+i, SZ);
  68:	7d000613          	li	a2,2000
  6c:	0304859b          	addiw	a1,s1,48
  70:	00001517          	auipc	a0,0x1
  74:	fa050513          	addi	a0,a0,-96 # 1010 <buf>
  78:	116000ef          	jal	18e <memset>
  7c:	0fa00493          	li	s1,250
        if((n = write(fd, buf, SZ)) != SZ){
  80:	7d000913          	li	s2,2000
  84:	00001a17          	auipc	s4,0x1
  88:	f8ca0a13          	addi	s4,s4,-116 # 1010 <buf>
  8c:	864a                	mv	a2,s2
  8e:	85d2                	mv	a1,s4
  90:	854e                	mv	a0,s3
  92:	346000ef          	jal	3d8 <write>
  96:	03251463          	bne	a0,s2,be <main+0xbe>
      for(i = 0; i < N; i++){
  9a:	34fd                	addiw	s1,s1,-1
  9c:	f8e5                	bnez	s1,8c <main+0x8c>
      exit(0);
  9e:	4501                	li	a0,0
  a0:	318000ef          	jal	3b8 <exit>
        printf("%s: create %s failed\n", argv[0], argv[i]);
  a4:	00093603          	ld	a2,0(s2)
  a8:	000a3583          	ld	a1,0(s4)
  ac:	00001517          	auipc	a0,0x1
  b0:	92c50513          	addi	a0,a0,-1748 # 9d8 <malloc+0x10a>
  b4:	762000ef          	jal	816 <printf>
        exit(1);
  b8:	4505                	li	a0,1
  ba:	2fe000ef          	jal	3b8 <exit>
          printf("write failed %d\n", n);
  be:	85aa                	mv	a1,a0
  c0:	00001517          	auipc	a0,0x1
  c4:	93050513          	addi	a0,a0,-1744 # 9f0 <malloc+0x122>
  c8:	74e000ef          	jal	816 <printf>
          exit(1);
  cc:	4505                	li	a0,1
  ce:	2ea000ef          	jal	3b8 <exit>
  d2:	893e                	mv	s2,a5
    wait(&xstatus);
  d4:	854e                	mv	a0,s3
  d6:	2ea000ef          	jal	3c0 <wait>
    if(xstatus != 0)
  da:	fcc42503          	lw	a0,-52(s0)
  de:	ed11                	bnez	a0,fa <main+0xfa>
  for(int i = 1; i < argc; i++){
  e0:	0019079b          	addiw	a5,s2,1
  e4:	ff2497e3          	bne	s1,s2,d2 <main+0xd2>
      exit(xstatus);
  }
  return 0;
}
  e8:	4501                	li	a0,0
  ea:	70e2                	ld	ra,56(sp)
  ec:	7442                	ld	s0,48(sp)
  ee:	74a2                	ld	s1,40(sp)
  f0:	7902                	ld	s2,32(sp)
  f2:	69e2                	ld	s3,24(sp)
  f4:	6a42                	ld	s4,16(sp)
  f6:	6121                	addi	sp,sp,64
  f8:	8082                	ret
      exit(xstatus);
  fa:	2be000ef          	jal	3b8 <exit>
}
  fe:	4501                	li	a0,0
 100:	8082                	ret

0000000000000102 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 102:	1141                	addi	sp,sp,-16
 104:	e406                	sd	ra,8(sp)
 106:	e022                	sd	s0,0(sp)
 108:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 10a:	ef7ff0ef          	jal	0 <main>
  exit(r);
 10e:	2aa000ef          	jal	3b8 <exit>

0000000000000112 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 112:	1141                	addi	sp,sp,-16
 114:	e406                	sd	ra,8(sp)
 116:	e022                	sd	s0,0(sp)
 118:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 11a:	87aa                	mv	a5,a0
 11c:	0585                	addi	a1,a1,1
 11e:	0785                	addi	a5,a5,1
 120:	fff5c703          	lbu	a4,-1(a1)
 124:	fee78fa3          	sb	a4,-1(a5)
 128:	fb75                	bnez	a4,11c <strcpy+0xa>
    ;
  return os;
}
 12a:	60a2                	ld	ra,8(sp)
 12c:	6402                	ld	s0,0(sp)
 12e:	0141                	addi	sp,sp,16
 130:	8082                	ret

0000000000000132 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 132:	1141                	addi	sp,sp,-16
 134:	e406                	sd	ra,8(sp)
 136:	e022                	sd	s0,0(sp)
 138:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 13a:	00054783          	lbu	a5,0(a0)
 13e:	cb91                	beqz	a5,152 <strcmp+0x20>
 140:	0005c703          	lbu	a4,0(a1)
 144:	00f71763          	bne	a4,a5,152 <strcmp+0x20>
    p++, q++;
 148:	0505                	addi	a0,a0,1
 14a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 14c:	00054783          	lbu	a5,0(a0)
 150:	fbe5                	bnez	a5,140 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 152:	0005c503          	lbu	a0,0(a1)
}
 156:	40a7853b          	subw	a0,a5,a0
 15a:	60a2                	ld	ra,8(sp)
 15c:	6402                	ld	s0,0(sp)
 15e:	0141                	addi	sp,sp,16
 160:	8082                	ret

0000000000000162 <strlen>:

uint
strlen(const char *s)
{
 162:	1141                	addi	sp,sp,-16
 164:	e406                	sd	ra,8(sp)
 166:	e022                	sd	s0,0(sp)
 168:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 16a:	00054783          	lbu	a5,0(a0)
 16e:	cf91                	beqz	a5,18a <strlen+0x28>
 170:	00150793          	addi	a5,a0,1
 174:	86be                	mv	a3,a5
 176:	0785                	addi	a5,a5,1
 178:	fff7c703          	lbu	a4,-1(a5)
 17c:	ff65                	bnez	a4,174 <strlen+0x12>
 17e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 182:	60a2                	ld	ra,8(sp)
 184:	6402                	ld	s0,0(sp)
 186:	0141                	addi	sp,sp,16
 188:	8082                	ret
  for(n = 0; s[n]; n++)
 18a:	4501                	li	a0,0
 18c:	bfdd                	j	182 <strlen+0x20>

000000000000018e <memset>:

void*
memset(void *dst, int c, uint n)
{
 18e:	1141                	addi	sp,sp,-16
 190:	e406                	sd	ra,8(sp)
 192:	e022                	sd	s0,0(sp)
 194:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 196:	ca19                	beqz	a2,1ac <memset+0x1e>
 198:	87aa                	mv	a5,a0
 19a:	1602                	slli	a2,a2,0x20
 19c:	9201                	srli	a2,a2,0x20
 19e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1a2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1a6:	0785                	addi	a5,a5,1
 1a8:	fee79de3          	bne	a5,a4,1a2 <memset+0x14>
  }
  return dst;
}
 1ac:	60a2                	ld	ra,8(sp)
 1ae:	6402                	ld	s0,0(sp)
 1b0:	0141                	addi	sp,sp,16
 1b2:	8082                	ret

00000000000001b4 <strchr>:

char*
strchr(const char *s, char c)
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e406                	sd	ra,8(sp)
 1b8:	e022                	sd	s0,0(sp)
 1ba:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1bc:	00054783          	lbu	a5,0(a0)
 1c0:	cf81                	beqz	a5,1d8 <strchr+0x24>
    if(*s == c)
 1c2:	00f58763          	beq	a1,a5,1d0 <strchr+0x1c>
  for(; *s; s++)
 1c6:	0505                	addi	a0,a0,1
 1c8:	00054783          	lbu	a5,0(a0)
 1cc:	fbfd                	bnez	a5,1c2 <strchr+0xe>
      return (char*)s;
  return 0;
 1ce:	4501                	li	a0,0
}
 1d0:	60a2                	ld	ra,8(sp)
 1d2:	6402                	ld	s0,0(sp)
 1d4:	0141                	addi	sp,sp,16
 1d6:	8082                	ret
  return 0;
 1d8:	4501                	li	a0,0
 1da:	bfdd                	j	1d0 <strchr+0x1c>

00000000000001dc <gets>:

char*
gets(char *buf, int max)
{
 1dc:	711d                	addi	sp,sp,-96
 1de:	ec86                	sd	ra,88(sp)
 1e0:	e8a2                	sd	s0,80(sp)
 1e2:	e4a6                	sd	s1,72(sp)
 1e4:	e0ca                	sd	s2,64(sp)
 1e6:	fc4e                	sd	s3,56(sp)
 1e8:	f852                	sd	s4,48(sp)
 1ea:	f456                	sd	s5,40(sp)
 1ec:	f05a                	sd	s6,32(sp)
 1ee:	ec5e                	sd	s7,24(sp)
 1f0:	e862                	sd	s8,16(sp)
 1f2:	1080                	addi	s0,sp,96
 1f4:	8baa                	mv	s7,a0
 1f6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f8:	892a                	mv	s2,a0
 1fa:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1fc:	faf40b13          	addi	s6,s0,-81
 200:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 202:	8c26                	mv	s8,s1
 204:	0014899b          	addiw	s3,s1,1
 208:	84ce                	mv	s1,s3
 20a:	0349d463          	bge	s3,s4,232 <gets+0x56>
    cc = read(0, &c, 1);
 20e:	8656                	mv	a2,s5
 210:	85da                	mv	a1,s6
 212:	4501                	li	a0,0
 214:	1bc000ef          	jal	3d0 <read>
    if(cc < 1)
 218:	00a05d63          	blez	a0,232 <gets+0x56>
      break;
    buf[i++] = c;
 21c:	faf44783          	lbu	a5,-81(s0)
 220:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 224:	0905                	addi	s2,s2,1
 226:	ff678713          	addi	a4,a5,-10
 22a:	c319                	beqz	a4,230 <gets+0x54>
 22c:	17cd                	addi	a5,a5,-13
 22e:	fbf1                	bnez	a5,202 <gets+0x26>
    buf[i++] = c;
 230:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 232:	9c5e                	add	s8,s8,s7
 234:	000c0023          	sb	zero,0(s8)
  return buf;
}
 238:	855e                	mv	a0,s7
 23a:	60e6                	ld	ra,88(sp)
 23c:	6446                	ld	s0,80(sp)
 23e:	64a6                	ld	s1,72(sp)
 240:	6906                	ld	s2,64(sp)
 242:	79e2                	ld	s3,56(sp)
 244:	7a42                	ld	s4,48(sp)
 246:	7aa2                	ld	s5,40(sp)
 248:	7b02                	ld	s6,32(sp)
 24a:	6be2                	ld	s7,24(sp)
 24c:	6c42                	ld	s8,16(sp)
 24e:	6125                	addi	sp,sp,96
 250:	8082                	ret

0000000000000252 <stat>:

int
stat(const char *n, struct stat *st)
{
 252:	1101                	addi	sp,sp,-32
 254:	ec06                	sd	ra,24(sp)
 256:	e822                	sd	s0,16(sp)
 258:	e04a                	sd	s2,0(sp)
 25a:	1000                	addi	s0,sp,32
 25c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 25e:	4581                	li	a1,0
 260:	198000ef          	jal	3f8 <open>
  if(fd < 0)
 264:	02054263          	bltz	a0,288 <stat+0x36>
 268:	e426                	sd	s1,8(sp)
 26a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 26c:	85ca                	mv	a1,s2
 26e:	1a2000ef          	jal	410 <fstat>
 272:	892a                	mv	s2,a0
  close(fd);
 274:	8526                	mv	a0,s1
 276:	16a000ef          	jal	3e0 <close>
  return r;
 27a:	64a2                	ld	s1,8(sp)
}
 27c:	854a                	mv	a0,s2
 27e:	60e2                	ld	ra,24(sp)
 280:	6442                	ld	s0,16(sp)
 282:	6902                	ld	s2,0(sp)
 284:	6105                	addi	sp,sp,32
 286:	8082                	ret
    return -1;
 288:	57fd                	li	a5,-1
 28a:	893e                	mv	s2,a5
 28c:	bfc5                	j	27c <stat+0x2a>

000000000000028e <atoi>:

int
atoi(const char *s)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e406                	sd	ra,8(sp)
 292:	e022                	sd	s0,0(sp)
 294:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 296:	00054683          	lbu	a3,0(a0)
 29a:	fd06879b          	addiw	a5,a3,-48
 29e:	0ff7f793          	zext.b	a5,a5
 2a2:	4625                	li	a2,9
 2a4:	02f66963          	bltu	a2,a5,2d6 <atoi+0x48>
 2a8:	872a                	mv	a4,a0
  n = 0;
 2aa:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2ac:	0705                	addi	a4,a4,1
 2ae:	0025179b          	slliw	a5,a0,0x2
 2b2:	9fa9                	addw	a5,a5,a0
 2b4:	0017979b          	slliw	a5,a5,0x1
 2b8:	9fb5                	addw	a5,a5,a3
 2ba:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2be:	00074683          	lbu	a3,0(a4)
 2c2:	fd06879b          	addiw	a5,a3,-48
 2c6:	0ff7f793          	zext.b	a5,a5
 2ca:	fef671e3          	bgeu	a2,a5,2ac <atoi+0x1e>
  return n;
}
 2ce:	60a2                	ld	ra,8(sp)
 2d0:	6402                	ld	s0,0(sp)
 2d2:	0141                	addi	sp,sp,16
 2d4:	8082                	ret
  n = 0;
 2d6:	4501                	li	a0,0
 2d8:	bfdd                	j	2ce <atoi+0x40>

00000000000002da <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2da:	1141                	addi	sp,sp,-16
 2dc:	e406                	sd	ra,8(sp)
 2de:	e022                	sd	s0,0(sp)
 2e0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2e2:	02b57563          	bgeu	a0,a1,30c <memmove+0x32>
    while(n-- > 0)
 2e6:	00c05f63          	blez	a2,304 <memmove+0x2a>
 2ea:	1602                	slli	a2,a2,0x20
 2ec:	9201                	srli	a2,a2,0x20
 2ee:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2f2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2f4:	0585                	addi	a1,a1,1
 2f6:	0705                	addi	a4,a4,1
 2f8:	fff5c683          	lbu	a3,-1(a1)
 2fc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 300:	fee79ae3          	bne	a5,a4,2f4 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 304:	60a2                	ld	ra,8(sp)
 306:	6402                	ld	s0,0(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
    while(n-- > 0)
 30c:	fec05ce3          	blez	a2,304 <memmove+0x2a>
    dst += n;
 310:	00c50733          	add	a4,a0,a2
    src += n;
 314:	95b2                	add	a1,a1,a2
 316:	fff6079b          	addiw	a5,a2,-1
 31a:	1782                	slli	a5,a5,0x20
 31c:	9381                	srli	a5,a5,0x20
 31e:	fff7c793          	not	a5,a5
 322:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 324:	15fd                	addi	a1,a1,-1
 326:	177d                	addi	a4,a4,-1
 328:	0005c683          	lbu	a3,0(a1)
 32c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 330:	fef71ae3          	bne	a4,a5,324 <memmove+0x4a>
 334:	bfc1                	j	304 <memmove+0x2a>

0000000000000336 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 336:	1141                	addi	sp,sp,-16
 338:	e406                	sd	ra,8(sp)
 33a:	e022                	sd	s0,0(sp)
 33c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 33e:	c61d                	beqz	a2,36c <memcmp+0x36>
 340:	1602                	slli	a2,a2,0x20
 342:	9201                	srli	a2,a2,0x20
 344:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 348:	00054783          	lbu	a5,0(a0)
 34c:	0005c703          	lbu	a4,0(a1)
 350:	00e79863          	bne	a5,a4,360 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 354:	0505                	addi	a0,a0,1
    p2++;
 356:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 358:	fed518e3          	bne	a0,a3,348 <memcmp+0x12>
  }
  return 0;
 35c:	4501                	li	a0,0
 35e:	a019                	j	364 <memcmp+0x2e>
      return *p1 - *p2;
 360:	40e7853b          	subw	a0,a5,a4
}
 364:	60a2                	ld	ra,8(sp)
 366:	6402                	ld	s0,0(sp)
 368:	0141                	addi	sp,sp,16
 36a:	8082                	ret
  return 0;
 36c:	4501                	li	a0,0
 36e:	bfdd                	j	364 <memcmp+0x2e>

0000000000000370 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 370:	1141                	addi	sp,sp,-16
 372:	e406                	sd	ra,8(sp)
 374:	e022                	sd	s0,0(sp)
 376:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 378:	f63ff0ef          	jal	2da <memmove>
}
 37c:	60a2                	ld	ra,8(sp)
 37e:	6402                	ld	s0,0(sp)
 380:	0141                	addi	sp,sp,16
 382:	8082                	ret

0000000000000384 <sbrk>:

char *
sbrk(int n) {
 384:	1141                	addi	sp,sp,-16
 386:	e406                	sd	ra,8(sp)
 388:	e022                	sd	s0,0(sp)
 38a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 38c:	4585                	li	a1,1
 38e:	0b2000ef          	jal	440 <sys_sbrk>
}
 392:	60a2                	ld	ra,8(sp)
 394:	6402                	ld	s0,0(sp)
 396:	0141                	addi	sp,sp,16
 398:	8082                	ret

000000000000039a <sbrklazy>:

char *
sbrklazy(int n) {
 39a:	1141                	addi	sp,sp,-16
 39c:	e406                	sd	ra,8(sp)
 39e:	e022                	sd	s0,0(sp)
 3a0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3a2:	4589                	li	a1,2
 3a4:	09c000ef          	jal	440 <sys_sbrk>
}
 3a8:	60a2                	ld	ra,8(sp)
 3aa:	6402                	ld	s0,0(sp)
 3ac:	0141                	addi	sp,sp,16
 3ae:	8082                	ret

00000000000003b0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3b0:	4885                	li	a7,1
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3b8:	4889                	li	a7,2
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3c0:	488d                	li	a7,3
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3c8:	4891                	li	a7,4
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <read>:
.global read
read:
 li a7, SYS_read
 3d0:	4895                	li	a7,5
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <write>:
.global write
write:
 li a7, SYS_write
 3d8:	48c1                	li	a7,16
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <close>:
.global close
close:
 li a7, SYS_close
 3e0:	48d5                	li	a7,21
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3e8:	4899                	li	a7,6
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3f0:	489d                	li	a7,7
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <open>:
.global open
open:
 li a7, SYS_open
 3f8:	48bd                	li	a7,15
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 400:	48c5                	li	a7,17
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 408:	48c9                	li	a7,18
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 410:	48a1                	li	a7,8
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <link>:
.global link
link:
 li a7, SYS_link
 418:	48cd                	li	a7,19
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 420:	48d1                	li	a7,20
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 428:	48a5                	li	a7,9
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <dup>:
.global dup
dup:
 li a7, SYS_dup
 430:	48a9                	li	a7,10
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 438:	48ad                	li	a7,11
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 440:	48b1                	li	a7,12
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <pause>:
.global pause
pause:
 li a7, SYS_pause
 448:	48b5                	li	a7,13
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 450:	48b9                	li	a7,14
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <sendmsg>:
.global sendmsg
sendmsg:
 li a7, SYS_sendmsg
 458:	48d9                	li	a7,22
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <recvmsg>:
.global recvmsg
recvmsg:
 li a7, SYS_recvmsg
 460:	48dd                	li	a7,23
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <broadcast>:
.global broadcast
broadcast:
 li a7, SYS_broadcast
 468:	48e1                	li	a7,24
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 470:	1101                	addi	sp,sp,-32
 472:	ec06                	sd	ra,24(sp)
 474:	e822                	sd	s0,16(sp)
 476:	1000                	addi	s0,sp,32
 478:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 47c:	4605                	li	a2,1
 47e:	fef40593          	addi	a1,s0,-17
 482:	f57ff0ef          	jal	3d8 <write>
}
 486:	60e2                	ld	ra,24(sp)
 488:	6442                	ld	s0,16(sp)
 48a:	6105                	addi	sp,sp,32
 48c:	8082                	ret

000000000000048e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 48e:	715d                	addi	sp,sp,-80
 490:	e486                	sd	ra,72(sp)
 492:	e0a2                	sd	s0,64(sp)
 494:	f84a                	sd	s2,48(sp)
 496:	f44e                	sd	s3,40(sp)
 498:	0880                	addi	s0,sp,80
 49a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 49c:	c6d1                	beqz	a3,528 <printint+0x9a>
 49e:	0805d563          	bgez	a1,528 <printint+0x9a>
    neg = 1;
    x = -xx;
 4a2:	40b005b3          	neg	a1,a1
    neg = 1;
 4a6:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 4a8:	fb840993          	addi	s3,s0,-72
  neg = 0;
 4ac:	86ce                	mv	a3,s3
  i = 0;
 4ae:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4b0:	00000817          	auipc	a6,0x0
 4b4:	56080813          	addi	a6,a6,1376 # a10 <digits>
 4b8:	88ba                	mv	a7,a4
 4ba:	0017051b          	addiw	a0,a4,1
 4be:	872a                	mv	a4,a0
 4c0:	02c5f7b3          	remu	a5,a1,a2
 4c4:	97c2                	add	a5,a5,a6
 4c6:	0007c783          	lbu	a5,0(a5)
 4ca:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4ce:	87ae                	mv	a5,a1
 4d0:	02c5d5b3          	divu	a1,a1,a2
 4d4:	0685                	addi	a3,a3,1
 4d6:	fec7f1e3          	bgeu	a5,a2,4b8 <printint+0x2a>
  if(neg)
 4da:	00030c63          	beqz	t1,4f2 <printint+0x64>
    buf[i++] = '-';
 4de:	fd050793          	addi	a5,a0,-48
 4e2:	00878533          	add	a0,a5,s0
 4e6:	02d00793          	li	a5,45
 4ea:	fef50423          	sb	a5,-24(a0)
 4ee:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 4f2:	02e05563          	blez	a4,51c <printint+0x8e>
 4f6:	fc26                	sd	s1,56(sp)
 4f8:	377d                	addiw	a4,a4,-1
 4fa:	00e984b3          	add	s1,s3,a4
 4fe:	19fd                	addi	s3,s3,-1
 500:	99ba                	add	s3,s3,a4
 502:	1702                	slli	a4,a4,0x20
 504:	9301                	srli	a4,a4,0x20
 506:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 50a:	0004c583          	lbu	a1,0(s1)
 50e:	854a                	mv	a0,s2
 510:	f61ff0ef          	jal	470 <putc>
  while(--i >= 0)
 514:	14fd                	addi	s1,s1,-1
 516:	ff349ae3          	bne	s1,s3,50a <printint+0x7c>
 51a:	74e2                	ld	s1,56(sp)
}
 51c:	60a6                	ld	ra,72(sp)
 51e:	6406                	ld	s0,64(sp)
 520:	7942                	ld	s2,48(sp)
 522:	79a2                	ld	s3,40(sp)
 524:	6161                	addi	sp,sp,80
 526:	8082                	ret
  neg = 0;
 528:	4301                	li	t1,0
 52a:	bfbd                	j	4a8 <printint+0x1a>

000000000000052c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 52c:	711d                	addi	sp,sp,-96
 52e:	ec86                	sd	ra,88(sp)
 530:	e8a2                	sd	s0,80(sp)
 532:	e4a6                	sd	s1,72(sp)
 534:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 536:	0005c483          	lbu	s1,0(a1)
 53a:	22048363          	beqz	s1,760 <vprintf+0x234>
 53e:	e0ca                	sd	s2,64(sp)
 540:	fc4e                	sd	s3,56(sp)
 542:	f852                	sd	s4,48(sp)
 544:	f456                	sd	s5,40(sp)
 546:	f05a                	sd	s6,32(sp)
 548:	ec5e                	sd	s7,24(sp)
 54a:	e862                	sd	s8,16(sp)
 54c:	8b2a                	mv	s6,a0
 54e:	8a2e                	mv	s4,a1
 550:	8bb2                	mv	s7,a2
  state = 0;
 552:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 554:	4901                	li	s2,0
 556:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 558:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 55c:	06400c13          	li	s8,100
 560:	a00d                	j	582 <vprintf+0x56>
        putc(fd, c0);
 562:	85a6                	mv	a1,s1
 564:	855a                	mv	a0,s6
 566:	f0bff0ef          	jal	470 <putc>
 56a:	a019                	j	570 <vprintf+0x44>
    } else if(state == '%'){
 56c:	03598363          	beq	s3,s5,592 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 570:	0019079b          	addiw	a5,s2,1
 574:	893e                	mv	s2,a5
 576:	873e                	mv	a4,a5
 578:	97d2                	add	a5,a5,s4
 57a:	0007c483          	lbu	s1,0(a5)
 57e:	1c048a63          	beqz	s1,752 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 582:	0004879b          	sext.w	a5,s1
    if(state == 0){
 586:	fe0993e3          	bnez	s3,56c <vprintf+0x40>
      if(c0 == '%'){
 58a:	fd579ce3          	bne	a5,s5,562 <vprintf+0x36>
        state = '%';
 58e:	89be                	mv	s3,a5
 590:	b7c5                	j	570 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 592:	00ea06b3          	add	a3,s4,a4
 596:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 59a:	1c060863          	beqz	a2,76a <vprintf+0x23e>
      if(c0 == 'd'){
 59e:	03878763          	beq	a5,s8,5cc <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5a2:	f9478693          	addi	a3,a5,-108
 5a6:	0016b693          	seqz	a3,a3
 5aa:	f9c60593          	addi	a1,a2,-100
 5ae:	e99d                	bnez	a1,5e4 <vprintf+0xb8>
 5b0:	ca95                	beqz	a3,5e4 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b2:	008b8493          	addi	s1,s7,8
 5b6:	4685                	li	a3,1
 5b8:	4629                	li	a2,10
 5ba:	000bb583          	ld	a1,0(s7)
 5be:	855a                	mv	a0,s6
 5c0:	ecfff0ef          	jal	48e <printint>
        i += 1;
 5c4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c6:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5c8:	4981                	li	s3,0
 5ca:	b75d                	j	570 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 5cc:	008b8493          	addi	s1,s7,8
 5d0:	4685                	li	a3,1
 5d2:	4629                	li	a2,10
 5d4:	000ba583          	lw	a1,0(s7)
 5d8:	855a                	mv	a0,s6
 5da:	eb5ff0ef          	jal	48e <printint>
 5de:	8ba6                	mv	s7,s1
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	b779                	j	570 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 5e4:	9752                	add	a4,a4,s4
 5e6:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ea:	f9460713          	addi	a4,a2,-108
 5ee:	00173713          	seqz	a4,a4
 5f2:	8f75                	and	a4,a4,a3
 5f4:	f9c58513          	addi	a0,a1,-100
 5f8:	18051363          	bnez	a0,77e <vprintf+0x252>
 5fc:	18070163          	beqz	a4,77e <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 600:	008b8493          	addi	s1,s7,8
 604:	4685                	li	a3,1
 606:	4629                	li	a2,10
 608:	000bb583          	ld	a1,0(s7)
 60c:	855a                	mv	a0,s6
 60e:	e81ff0ef          	jal	48e <printint>
        i += 2;
 612:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 614:	8ba6                	mv	s7,s1
      state = 0;
 616:	4981                	li	s3,0
        i += 2;
 618:	bfa1                	j	570 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 61a:	008b8493          	addi	s1,s7,8
 61e:	4681                	li	a3,0
 620:	4629                	li	a2,10
 622:	000be583          	lwu	a1,0(s7)
 626:	855a                	mv	a0,s6
 628:	e67ff0ef          	jal	48e <printint>
 62c:	8ba6                	mv	s7,s1
      state = 0;
 62e:	4981                	li	s3,0
 630:	b781                	j	570 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 632:	008b8493          	addi	s1,s7,8
 636:	4681                	li	a3,0
 638:	4629                	li	a2,10
 63a:	000bb583          	ld	a1,0(s7)
 63e:	855a                	mv	a0,s6
 640:	e4fff0ef          	jal	48e <printint>
        i += 1;
 644:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 646:	8ba6                	mv	s7,s1
      state = 0;
 648:	4981                	li	s3,0
 64a:	b71d                	j	570 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 64c:	008b8493          	addi	s1,s7,8
 650:	4681                	li	a3,0
 652:	4629                	li	a2,10
 654:	000bb583          	ld	a1,0(s7)
 658:	855a                	mv	a0,s6
 65a:	e35ff0ef          	jal	48e <printint>
        i += 2;
 65e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 660:	8ba6                	mv	s7,s1
      state = 0;
 662:	4981                	li	s3,0
        i += 2;
 664:	b731                	j	570 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 666:	008b8493          	addi	s1,s7,8
 66a:	4681                	li	a3,0
 66c:	4641                	li	a2,16
 66e:	000be583          	lwu	a1,0(s7)
 672:	855a                	mv	a0,s6
 674:	e1bff0ef          	jal	48e <printint>
 678:	8ba6                	mv	s7,s1
      state = 0;
 67a:	4981                	li	s3,0
 67c:	bdd5                	j	570 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 67e:	008b8493          	addi	s1,s7,8
 682:	4681                	li	a3,0
 684:	4641                	li	a2,16
 686:	000bb583          	ld	a1,0(s7)
 68a:	855a                	mv	a0,s6
 68c:	e03ff0ef          	jal	48e <printint>
        i += 1;
 690:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 692:	8ba6                	mv	s7,s1
      state = 0;
 694:	4981                	li	s3,0
 696:	bde9                	j	570 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 698:	008b8493          	addi	s1,s7,8
 69c:	4681                	li	a3,0
 69e:	4641                	li	a2,16
 6a0:	000bb583          	ld	a1,0(s7)
 6a4:	855a                	mv	a0,s6
 6a6:	de9ff0ef          	jal	48e <printint>
        i += 2;
 6aa:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ac:	8ba6                	mv	s7,s1
      state = 0;
 6ae:	4981                	li	s3,0
        i += 2;
 6b0:	b5c1                	j	570 <vprintf+0x44>
 6b2:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 6b4:	008b8793          	addi	a5,s7,8
 6b8:	8cbe                	mv	s9,a5
 6ba:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6be:	03000593          	li	a1,48
 6c2:	855a                	mv	a0,s6
 6c4:	dadff0ef          	jal	470 <putc>
  putc(fd, 'x');
 6c8:	07800593          	li	a1,120
 6cc:	855a                	mv	a0,s6
 6ce:	da3ff0ef          	jal	470 <putc>
 6d2:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6d4:	00000b97          	auipc	s7,0x0
 6d8:	33cb8b93          	addi	s7,s7,828 # a10 <digits>
 6dc:	03c9d793          	srli	a5,s3,0x3c
 6e0:	97de                	add	a5,a5,s7
 6e2:	0007c583          	lbu	a1,0(a5)
 6e6:	855a                	mv	a0,s6
 6e8:	d89ff0ef          	jal	470 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6ec:	0992                	slli	s3,s3,0x4
 6ee:	34fd                	addiw	s1,s1,-1
 6f0:	f4f5                	bnez	s1,6dc <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 6f2:	8be6                	mv	s7,s9
      state = 0;
 6f4:	4981                	li	s3,0
 6f6:	6ca2                	ld	s9,8(sp)
 6f8:	bda5                	j	570 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 6fa:	008b8493          	addi	s1,s7,8
 6fe:	000bc583          	lbu	a1,0(s7)
 702:	855a                	mv	a0,s6
 704:	d6dff0ef          	jal	470 <putc>
 708:	8ba6                	mv	s7,s1
      state = 0;
 70a:	4981                	li	s3,0
 70c:	b595                	j	570 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 70e:	008b8993          	addi	s3,s7,8
 712:	000bb483          	ld	s1,0(s7)
 716:	cc91                	beqz	s1,732 <vprintf+0x206>
        for(; *s; s++)
 718:	0004c583          	lbu	a1,0(s1)
 71c:	c985                	beqz	a1,74c <vprintf+0x220>
          putc(fd, *s);
 71e:	855a                	mv	a0,s6
 720:	d51ff0ef          	jal	470 <putc>
        for(; *s; s++)
 724:	0485                	addi	s1,s1,1
 726:	0004c583          	lbu	a1,0(s1)
 72a:	f9f5                	bnez	a1,71e <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 72c:	8bce                	mv	s7,s3
      state = 0;
 72e:	4981                	li	s3,0
 730:	b581                	j	570 <vprintf+0x44>
          s = "(null)";
 732:	00000497          	auipc	s1,0x0
 736:	2d648493          	addi	s1,s1,726 # a08 <malloc+0x13a>
        for(; *s; s++)
 73a:	02800593          	li	a1,40
 73e:	b7c5                	j	71e <vprintf+0x1f2>
        putc(fd, '%');
 740:	85be                	mv	a1,a5
 742:	855a                	mv	a0,s6
 744:	d2dff0ef          	jal	470 <putc>
      state = 0;
 748:	4981                	li	s3,0
 74a:	b51d                	j	570 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 74c:	8bce                	mv	s7,s3
      state = 0;
 74e:	4981                	li	s3,0
 750:	b505                	j	570 <vprintf+0x44>
 752:	6906                	ld	s2,64(sp)
 754:	79e2                	ld	s3,56(sp)
 756:	7a42                	ld	s4,48(sp)
 758:	7aa2                	ld	s5,40(sp)
 75a:	7b02                	ld	s6,32(sp)
 75c:	6be2                	ld	s7,24(sp)
 75e:	6c42                	ld	s8,16(sp)
    }
  }
}
 760:	60e6                	ld	ra,88(sp)
 762:	6446                	ld	s0,80(sp)
 764:	64a6                	ld	s1,72(sp)
 766:	6125                	addi	sp,sp,96
 768:	8082                	ret
      if(c0 == 'd'){
 76a:	06400713          	li	a4,100
 76e:	e4e78fe3          	beq	a5,a4,5cc <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 772:	f9478693          	addi	a3,a5,-108
 776:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 77a:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 77c:	4701                	li	a4,0
      } else if(c0 == 'u'){
 77e:	07500513          	li	a0,117
 782:	e8a78ce3          	beq	a5,a0,61a <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 786:	f8b60513          	addi	a0,a2,-117
 78a:	e119                	bnez	a0,790 <vprintf+0x264>
 78c:	ea0693e3          	bnez	a3,632 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 790:	f8b58513          	addi	a0,a1,-117
 794:	e119                	bnez	a0,79a <vprintf+0x26e>
 796:	ea071be3          	bnez	a4,64c <vprintf+0x120>
      } else if(c0 == 'x'){
 79a:	07800513          	li	a0,120
 79e:	eca784e3          	beq	a5,a0,666 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 7a2:	f8860613          	addi	a2,a2,-120
 7a6:	e219                	bnez	a2,7ac <vprintf+0x280>
 7a8:	ec069be3          	bnez	a3,67e <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7ac:	f8858593          	addi	a1,a1,-120
 7b0:	e199                	bnez	a1,7b6 <vprintf+0x28a>
 7b2:	ee0713e3          	bnez	a4,698 <vprintf+0x16c>
      } else if(c0 == 'p'){
 7b6:	07000713          	li	a4,112
 7ba:	eee78ce3          	beq	a5,a4,6b2 <vprintf+0x186>
      } else if(c0 == 'c'){
 7be:	06300713          	li	a4,99
 7c2:	f2e78ce3          	beq	a5,a4,6fa <vprintf+0x1ce>
      } else if(c0 == 's'){
 7c6:	07300713          	li	a4,115
 7ca:	f4e782e3          	beq	a5,a4,70e <vprintf+0x1e2>
      } else if(c0 == '%'){
 7ce:	02500713          	li	a4,37
 7d2:	f6e787e3          	beq	a5,a4,740 <vprintf+0x214>
        putc(fd, '%');
 7d6:	02500593          	li	a1,37
 7da:	855a                	mv	a0,s6
 7dc:	c95ff0ef          	jal	470 <putc>
        putc(fd, c0);
 7e0:	85a6                	mv	a1,s1
 7e2:	855a                	mv	a0,s6
 7e4:	c8dff0ef          	jal	470 <putc>
      state = 0;
 7e8:	4981                	li	s3,0
 7ea:	b359                	j	570 <vprintf+0x44>

00000000000007ec <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7ec:	715d                	addi	sp,sp,-80
 7ee:	ec06                	sd	ra,24(sp)
 7f0:	e822                	sd	s0,16(sp)
 7f2:	1000                	addi	s0,sp,32
 7f4:	e010                	sd	a2,0(s0)
 7f6:	e414                	sd	a3,8(s0)
 7f8:	e818                	sd	a4,16(s0)
 7fa:	ec1c                	sd	a5,24(s0)
 7fc:	03043023          	sd	a6,32(s0)
 800:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 804:	8622                	mv	a2,s0
 806:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 80a:	d23ff0ef          	jal	52c <vprintf>
}
 80e:	60e2                	ld	ra,24(sp)
 810:	6442                	ld	s0,16(sp)
 812:	6161                	addi	sp,sp,80
 814:	8082                	ret

0000000000000816 <printf>:

void
printf(const char *fmt, ...)
{
 816:	711d                	addi	sp,sp,-96
 818:	ec06                	sd	ra,24(sp)
 81a:	e822                	sd	s0,16(sp)
 81c:	1000                	addi	s0,sp,32
 81e:	e40c                	sd	a1,8(s0)
 820:	e810                	sd	a2,16(s0)
 822:	ec14                	sd	a3,24(s0)
 824:	f018                	sd	a4,32(s0)
 826:	f41c                	sd	a5,40(s0)
 828:	03043823          	sd	a6,48(s0)
 82c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 830:	00840613          	addi	a2,s0,8
 834:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 838:	85aa                	mv	a1,a0
 83a:	4505                	li	a0,1
 83c:	cf1ff0ef          	jal	52c <vprintf>
}
 840:	60e2                	ld	ra,24(sp)
 842:	6442                	ld	s0,16(sp)
 844:	6125                	addi	sp,sp,96
 846:	8082                	ret

0000000000000848 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 848:	1141                	addi	sp,sp,-16
 84a:	e406                	sd	ra,8(sp)
 84c:	e022                	sd	s0,0(sp)
 84e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 850:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 854:	00000797          	auipc	a5,0x0
 858:	7ac7b783          	ld	a5,1964(a5) # 1000 <freep>
 85c:	a039                	j	86a <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85e:	6398                	ld	a4,0(a5)
 860:	00e7e463          	bltu	a5,a4,868 <free+0x20>
 864:	00e6ea63          	bltu	a3,a4,878 <free+0x30>
{
 868:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86a:	fed7fae3          	bgeu	a5,a3,85e <free+0x16>
 86e:	6398                	ld	a4,0(a5)
 870:	00e6e463          	bltu	a3,a4,878 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 874:	fee7eae3          	bltu	a5,a4,868 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 878:	ff852583          	lw	a1,-8(a0)
 87c:	6390                	ld	a2,0(a5)
 87e:	02059813          	slli	a6,a1,0x20
 882:	01c85713          	srli	a4,a6,0x1c
 886:	9736                	add	a4,a4,a3
 888:	02e60563          	beq	a2,a4,8b2 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 88c:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 890:	4790                	lw	a2,8(a5)
 892:	02061593          	slli	a1,a2,0x20
 896:	01c5d713          	srli	a4,a1,0x1c
 89a:	973e                	add	a4,a4,a5
 89c:	02e68263          	beq	a3,a4,8c0 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 8a0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8a2:	00000717          	auipc	a4,0x0
 8a6:	74f73f23          	sd	a5,1886(a4) # 1000 <freep>
}
 8aa:	60a2                	ld	ra,8(sp)
 8ac:	6402                	ld	s0,0(sp)
 8ae:	0141                	addi	sp,sp,16
 8b0:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 8b2:	4618                	lw	a4,8(a2)
 8b4:	9f2d                	addw	a4,a4,a1
 8b6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8ba:	6398                	ld	a4,0(a5)
 8bc:	6310                	ld	a2,0(a4)
 8be:	b7f9                	j	88c <free+0x44>
    p->s.size += bp->s.size;
 8c0:	ff852703          	lw	a4,-8(a0)
 8c4:	9f31                	addw	a4,a4,a2
 8c6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8c8:	ff053683          	ld	a3,-16(a0)
 8cc:	bfd1                	j	8a0 <free+0x58>

00000000000008ce <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8ce:	7139                	addi	sp,sp,-64
 8d0:	fc06                	sd	ra,56(sp)
 8d2:	f822                	sd	s0,48(sp)
 8d4:	f04a                	sd	s2,32(sp)
 8d6:	ec4e                	sd	s3,24(sp)
 8d8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8da:	02051993          	slli	s3,a0,0x20
 8de:	0209d993          	srli	s3,s3,0x20
 8e2:	09bd                	addi	s3,s3,15
 8e4:	0049d993          	srli	s3,s3,0x4
 8e8:	2985                	addiw	s3,s3,1
 8ea:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 8ec:	00000517          	auipc	a0,0x0
 8f0:	71453503          	ld	a0,1812(a0) # 1000 <freep>
 8f4:	c905                	beqz	a0,924 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f8:	4798                	lw	a4,8(a5)
 8fa:	09377663          	bgeu	a4,s3,986 <malloc+0xb8>
 8fe:	f426                	sd	s1,40(sp)
 900:	e852                	sd	s4,16(sp)
 902:	e456                	sd	s5,8(sp)
 904:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 906:	8a4e                	mv	s4,s3
 908:	6705                	lui	a4,0x1
 90a:	00e9f363          	bgeu	s3,a4,910 <malloc+0x42>
 90e:	6a05                	lui	s4,0x1
 910:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 914:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 918:	00000497          	auipc	s1,0x0
 91c:	6e848493          	addi	s1,s1,1768 # 1000 <freep>
  if(p == SBRK_ERROR)
 920:	5afd                	li	s5,-1
 922:	a83d                	j	960 <malloc+0x92>
 924:	f426                	sd	s1,40(sp)
 926:	e852                	sd	s4,16(sp)
 928:	e456                	sd	s5,8(sp)
 92a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 92c:	00001797          	auipc	a5,0x1
 930:	8dc78793          	addi	a5,a5,-1828 # 1208 <base>
 934:	00000717          	auipc	a4,0x0
 938:	6cf73623          	sd	a5,1740(a4) # 1000 <freep>
 93c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 93e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 942:	b7d1                	j	906 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 944:	6398                	ld	a4,0(a5)
 946:	e118                	sd	a4,0(a0)
 948:	a899                	j	99e <malloc+0xd0>
  hp->s.size = nu;
 94a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 94e:	0541                	addi	a0,a0,16
 950:	ef9ff0ef          	jal	848 <free>
  return freep;
 954:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 956:	c125                	beqz	a0,9b6 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 958:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 95a:	4798                	lw	a4,8(a5)
 95c:	03277163          	bgeu	a4,s2,97e <malloc+0xb0>
    if(p == freep)
 960:	6098                	ld	a4,0(s1)
 962:	853e                	mv	a0,a5
 964:	fef71ae3          	bne	a4,a5,958 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 968:	8552                	mv	a0,s4
 96a:	a1bff0ef          	jal	384 <sbrk>
  if(p == SBRK_ERROR)
 96e:	fd551ee3          	bne	a0,s5,94a <malloc+0x7c>
        return 0;
 972:	4501                	li	a0,0
 974:	74a2                	ld	s1,40(sp)
 976:	6a42                	ld	s4,16(sp)
 978:	6aa2                	ld	s5,8(sp)
 97a:	6b02                	ld	s6,0(sp)
 97c:	a03d                	j	9aa <malloc+0xdc>
 97e:	74a2                	ld	s1,40(sp)
 980:	6a42                	ld	s4,16(sp)
 982:	6aa2                	ld	s5,8(sp)
 984:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 986:	fae90fe3          	beq	s2,a4,944 <malloc+0x76>
        p->s.size -= nunits;
 98a:	4137073b          	subw	a4,a4,s3
 98e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 990:	02071693          	slli	a3,a4,0x20
 994:	01c6d713          	srli	a4,a3,0x1c
 998:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 99a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 99e:	00000717          	auipc	a4,0x0
 9a2:	66a73123          	sd	a0,1634(a4) # 1000 <freep>
      return (void*)(p + 1);
 9a6:	01078513          	addi	a0,a5,16
  }
}
 9aa:	70e2                	ld	ra,56(sp)
 9ac:	7442                	ld	s0,48(sp)
 9ae:	7902                	ld	s2,32(sp)
 9b0:	69e2                	ld	s3,24(sp)
 9b2:	6121                	addi	sp,sp,64
 9b4:	8082                	ret
 9b6:	74a2                	ld	s1,40(sp)
 9b8:	6a42                	ld	s4,16(sp)
 9ba:	6aa2                	ld	s5,8(sp)
 9bc:	6b02                	ld	s6,0(sp)
 9be:	b7f5                	j	9aa <malloc+0xdc>
