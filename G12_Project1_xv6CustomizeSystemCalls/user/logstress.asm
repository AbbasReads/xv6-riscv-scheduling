
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
  42:	a0250513          	addi	a0,a0,-1534 # a40 <malloc+0xf4>
  46:	04f000ef          	jal	894 <printf>
      exit(1);
  4a:	4505                	li	a0,1
  4c:	36c000ef          	jal	3b8 <exit>
      fd = open(argv[i], O_CREATE | O_RDWR);
  50:	00349913          	slli	s2,s1,0x3
  54:	9952                	add	s2,s2,s4
  56:	20200593          	li	a1,514
  5a:	00093503          	ld	a0,0(s2)
  5e:	426000ef          	jal	484 <open>
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
  b0:	9ac50513          	addi	a0,a0,-1620 # a58 <malloc+0x10c>
  b4:	7e0000ef          	jal	894 <printf>
        exit(1);
  b8:	4505                	li	a0,1
  ba:	2fe000ef          	jal	3b8 <exit>
          printf("write failed %d\n", n);
  be:	85aa                	mv	a1,a0
  c0:	00001517          	auipc	a0,0x1
  c4:	9b050513          	addi	a0,a0,-1616 # a70 <malloc+0x124>
  c8:	7cc000ef          	jal	894 <printf>
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
 260:	224000ef          	jal	484 <open>
  if(fd < 0)
 264:	02054263          	bltz	a0,288 <stat+0x36>
 268:	e426                	sd	s1,8(sp)
 26a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 26c:	85ca                	mv	a1,s2
 26e:	22e000ef          	jal	49c <fstat>
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
 38e:	13e000ef          	jal	4cc <sys_sbrk>
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
 3a4:	128000ef          	jal	4cc <sys_sbrk>
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

00000000000003e8 <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 3e8:	48d9                	li	a7,22
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <shmat>:
.global shmat
shmat:
 li a7, SYS_shmat
 3f0:	48dd                	li	a7,23
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 3f8:	48e1                	li	a7,24
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 400:	48e5                	li	a7,25
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <lockinit>:
.global lockinit
lockinit:
 li a7, SYS_lockinit
 408:	48e9                	li	a7,26
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <lockacquire>:
.global lockacquire
lockacquire:
 li a7, SYS_lockacquire
 410:	48ed                	li	a7,27
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <lockrelease>:
.global lockrelease
lockrelease:
 li a7, SYS_lockrelease
 418:	48f1                	li	a7,28
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <locktry>:
.global locktry
locktry:
 li a7, SYS_locktry
 420:	48f5                	li	a7,29
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <lockcheck>:
.global lockcheck
lockcheck:
 li a7, SYS_lockcheck
 428:	48f9                	li	a7,30
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <sendmsg>:
.global sendmsg
sendmsg:
 li a7, SYS_sendmsg
 430:	48fd                	li	a7,31
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <recvmsg>:
.global recvmsg
recvmsg:
 li a7, SYS_recvmsg
 438:	02000893          	li	a7,32
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <broadcast>:
.global broadcast
broadcast:
 li a7, SYS_broadcast
 442:	02100893          	li	a7,33
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <getprocsinfo>:
.global getprocsinfo
getprocsinfo:
 li a7, SYS_getprocsinfo
 44c:	02200893          	li	a7,34
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 456:	02300893          	li	a7,35
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <sleep2>:
.global sleep2
sleep2:
 li a7, SYS_sleep2
 460:	02400893          	li	a7,36
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <signal>:
.global signal
signal:
 li a7, SYS_signal
 46a:	02500893          	li	a7,37
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <kill>:
.global kill
kill:
 li a7, SYS_kill
 474:	4899                	li	a7,6
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <exec>:
.global exec
exec:
 li a7, SYS_exec
 47c:	489d                	li	a7,7
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <open>:
.global open
open:
 li a7, SYS_open
 484:	48bd                	li	a7,15
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 48c:	48c5                	li	a7,17
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 494:	48c9                	li	a7,18
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 49c:	48a1                	li	a7,8
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <link>:
.global link
link:
 li a7, SYS_link
 4a4:	48cd                	li	a7,19
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4ac:	48d1                	li	a7,20
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4b4:	48a5                	li	a7,9
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <dup>:
.global dup
dup:
 li a7, SYS_dup
 4bc:	48a9                	li	a7,10
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4c4:	48ad                	li	a7,11
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4cc:	48b1                	li	a7,12
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <pause>:
.global pause
pause:
 li a7, SYS_pause
 4d4:	48b5                	li	a7,13
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4dc:	48b9                	li	a7,14
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <setchildlimit>:
.global setchildlimit
setchildlimit:
 li a7, SYS_setchildlimit
 4e4:	02600893          	li	a7,38
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ee:	1101                	addi	sp,sp,-32
 4f0:	ec06                	sd	ra,24(sp)
 4f2:	e822                	sd	s0,16(sp)
 4f4:	1000                	addi	s0,sp,32
 4f6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4fa:	4605                	li	a2,1
 4fc:	fef40593          	addi	a1,s0,-17
 500:	ed9ff0ef          	jal	3d8 <write>
}
 504:	60e2                	ld	ra,24(sp)
 506:	6442                	ld	s0,16(sp)
 508:	6105                	addi	sp,sp,32
 50a:	8082                	ret

000000000000050c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 50c:	715d                	addi	sp,sp,-80
 50e:	e486                	sd	ra,72(sp)
 510:	e0a2                	sd	s0,64(sp)
 512:	f84a                	sd	s2,48(sp)
 514:	f44e                	sd	s3,40(sp)
 516:	0880                	addi	s0,sp,80
 518:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 51a:	c6d1                	beqz	a3,5a6 <printint+0x9a>
 51c:	0805d563          	bgez	a1,5a6 <printint+0x9a>
    neg = 1;
    x = -xx;
 520:	40b005b3          	neg	a1,a1
    neg = 1;
 524:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 526:	fb840993          	addi	s3,s0,-72
  neg = 0;
 52a:	86ce                	mv	a3,s3
  i = 0;
 52c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 52e:	00000817          	auipc	a6,0x0
 532:	56280813          	addi	a6,a6,1378 # a90 <digits>
 536:	88ba                	mv	a7,a4
 538:	0017051b          	addiw	a0,a4,1
 53c:	872a                	mv	a4,a0
 53e:	02c5f7b3          	remu	a5,a1,a2
 542:	97c2                	add	a5,a5,a6
 544:	0007c783          	lbu	a5,0(a5)
 548:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 54c:	87ae                	mv	a5,a1
 54e:	02c5d5b3          	divu	a1,a1,a2
 552:	0685                	addi	a3,a3,1
 554:	fec7f1e3          	bgeu	a5,a2,536 <printint+0x2a>
  if(neg)
 558:	00030c63          	beqz	t1,570 <printint+0x64>
    buf[i++] = '-';
 55c:	fd050793          	addi	a5,a0,-48
 560:	00878533          	add	a0,a5,s0
 564:	02d00793          	li	a5,45
 568:	fef50423          	sb	a5,-24(a0)
 56c:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 570:	02e05563          	blez	a4,59a <printint+0x8e>
 574:	fc26                	sd	s1,56(sp)
 576:	377d                	addiw	a4,a4,-1
 578:	00e984b3          	add	s1,s3,a4
 57c:	19fd                	addi	s3,s3,-1
 57e:	99ba                	add	s3,s3,a4
 580:	1702                	slli	a4,a4,0x20
 582:	9301                	srli	a4,a4,0x20
 584:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 588:	0004c583          	lbu	a1,0(s1)
 58c:	854a                	mv	a0,s2
 58e:	f61ff0ef          	jal	4ee <putc>
  while(--i >= 0)
 592:	14fd                	addi	s1,s1,-1
 594:	ff349ae3          	bne	s1,s3,588 <printint+0x7c>
 598:	74e2                	ld	s1,56(sp)
}
 59a:	60a6                	ld	ra,72(sp)
 59c:	6406                	ld	s0,64(sp)
 59e:	7942                	ld	s2,48(sp)
 5a0:	79a2                	ld	s3,40(sp)
 5a2:	6161                	addi	sp,sp,80
 5a4:	8082                	ret
  neg = 0;
 5a6:	4301                	li	t1,0
 5a8:	bfbd                	j	526 <printint+0x1a>

00000000000005aa <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5aa:	711d                	addi	sp,sp,-96
 5ac:	ec86                	sd	ra,88(sp)
 5ae:	e8a2                	sd	s0,80(sp)
 5b0:	e4a6                	sd	s1,72(sp)
 5b2:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5b4:	0005c483          	lbu	s1,0(a1)
 5b8:	22048363          	beqz	s1,7de <vprintf+0x234>
 5bc:	e0ca                	sd	s2,64(sp)
 5be:	fc4e                	sd	s3,56(sp)
 5c0:	f852                	sd	s4,48(sp)
 5c2:	f456                	sd	s5,40(sp)
 5c4:	f05a                	sd	s6,32(sp)
 5c6:	ec5e                	sd	s7,24(sp)
 5c8:	e862                	sd	s8,16(sp)
 5ca:	8b2a                	mv	s6,a0
 5cc:	8a2e                	mv	s4,a1
 5ce:	8bb2                	mv	s7,a2
  state = 0;
 5d0:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5d2:	4901                	li	s2,0
 5d4:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5d6:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5da:	06400c13          	li	s8,100
 5de:	a00d                	j	600 <vprintf+0x56>
        putc(fd, c0);
 5e0:	85a6                	mv	a1,s1
 5e2:	855a                	mv	a0,s6
 5e4:	f0bff0ef          	jal	4ee <putc>
 5e8:	a019                	j	5ee <vprintf+0x44>
    } else if(state == '%'){
 5ea:	03598363          	beq	s3,s5,610 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 5ee:	0019079b          	addiw	a5,s2,1
 5f2:	893e                	mv	s2,a5
 5f4:	873e                	mv	a4,a5
 5f6:	97d2                	add	a5,a5,s4
 5f8:	0007c483          	lbu	s1,0(a5)
 5fc:	1c048a63          	beqz	s1,7d0 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 600:	0004879b          	sext.w	a5,s1
    if(state == 0){
 604:	fe0993e3          	bnez	s3,5ea <vprintf+0x40>
      if(c0 == '%'){
 608:	fd579ce3          	bne	a5,s5,5e0 <vprintf+0x36>
        state = '%';
 60c:	89be                	mv	s3,a5
 60e:	b7c5                	j	5ee <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 610:	00ea06b3          	add	a3,s4,a4
 614:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 618:	1c060863          	beqz	a2,7e8 <vprintf+0x23e>
      if(c0 == 'd'){
 61c:	03878763          	beq	a5,s8,64a <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 620:	f9478693          	addi	a3,a5,-108
 624:	0016b693          	seqz	a3,a3
 628:	f9c60593          	addi	a1,a2,-100
 62c:	e99d                	bnez	a1,662 <vprintf+0xb8>
 62e:	ca95                	beqz	a3,662 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 630:	008b8493          	addi	s1,s7,8
 634:	4685                	li	a3,1
 636:	4629                	li	a2,10
 638:	000bb583          	ld	a1,0(s7)
 63c:	855a                	mv	a0,s6
 63e:	ecfff0ef          	jal	50c <printint>
        i += 1;
 642:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 644:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 646:	4981                	li	s3,0
 648:	b75d                	j	5ee <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 64a:	008b8493          	addi	s1,s7,8
 64e:	4685                	li	a3,1
 650:	4629                	li	a2,10
 652:	000ba583          	lw	a1,0(s7)
 656:	855a                	mv	a0,s6
 658:	eb5ff0ef          	jal	50c <printint>
 65c:	8ba6                	mv	s7,s1
      state = 0;
 65e:	4981                	li	s3,0
 660:	b779                	j	5ee <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 662:	9752                	add	a4,a4,s4
 664:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 668:	f9460713          	addi	a4,a2,-108
 66c:	00173713          	seqz	a4,a4
 670:	8f75                	and	a4,a4,a3
 672:	f9c58513          	addi	a0,a1,-100
 676:	18051363          	bnez	a0,7fc <vprintf+0x252>
 67a:	18070163          	beqz	a4,7fc <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 67e:	008b8493          	addi	s1,s7,8
 682:	4685                	li	a3,1
 684:	4629                	li	a2,10
 686:	000bb583          	ld	a1,0(s7)
 68a:	855a                	mv	a0,s6
 68c:	e81ff0ef          	jal	50c <printint>
        i += 2;
 690:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 692:	8ba6                	mv	s7,s1
      state = 0;
 694:	4981                	li	s3,0
        i += 2;
 696:	bfa1                	j	5ee <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 698:	008b8493          	addi	s1,s7,8
 69c:	4681                	li	a3,0
 69e:	4629                	li	a2,10
 6a0:	000be583          	lwu	a1,0(s7)
 6a4:	855a                	mv	a0,s6
 6a6:	e67ff0ef          	jal	50c <printint>
 6aa:	8ba6                	mv	s7,s1
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	b781                	j	5ee <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b0:	008b8493          	addi	s1,s7,8
 6b4:	4681                	li	a3,0
 6b6:	4629                	li	a2,10
 6b8:	000bb583          	ld	a1,0(s7)
 6bc:	855a                	mv	a0,s6
 6be:	e4fff0ef          	jal	50c <printint>
        i += 1;
 6c2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c4:	8ba6                	mv	s7,s1
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	b71d                	j	5ee <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ca:	008b8493          	addi	s1,s7,8
 6ce:	4681                	li	a3,0
 6d0:	4629                	li	a2,10
 6d2:	000bb583          	ld	a1,0(s7)
 6d6:	855a                	mv	a0,s6
 6d8:	e35ff0ef          	jal	50c <printint>
        i += 2;
 6dc:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6de:	8ba6                	mv	s7,s1
      state = 0;
 6e0:	4981                	li	s3,0
        i += 2;
 6e2:	b731                	j	5ee <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6e4:	008b8493          	addi	s1,s7,8
 6e8:	4681                	li	a3,0
 6ea:	4641                	li	a2,16
 6ec:	000be583          	lwu	a1,0(s7)
 6f0:	855a                	mv	a0,s6
 6f2:	e1bff0ef          	jal	50c <printint>
 6f6:	8ba6                	mv	s7,s1
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	bdd5                	j	5ee <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6fc:	008b8493          	addi	s1,s7,8
 700:	4681                	li	a3,0
 702:	4641                	li	a2,16
 704:	000bb583          	ld	a1,0(s7)
 708:	855a                	mv	a0,s6
 70a:	e03ff0ef          	jal	50c <printint>
        i += 1;
 70e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 710:	8ba6                	mv	s7,s1
      state = 0;
 712:	4981                	li	s3,0
 714:	bde9                	j	5ee <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 716:	008b8493          	addi	s1,s7,8
 71a:	4681                	li	a3,0
 71c:	4641                	li	a2,16
 71e:	000bb583          	ld	a1,0(s7)
 722:	855a                	mv	a0,s6
 724:	de9ff0ef          	jal	50c <printint>
        i += 2;
 728:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 72a:	8ba6                	mv	s7,s1
      state = 0;
 72c:	4981                	li	s3,0
        i += 2;
 72e:	b5c1                	j	5ee <vprintf+0x44>
 730:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 732:	008b8793          	addi	a5,s7,8
 736:	8cbe                	mv	s9,a5
 738:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 73c:	03000593          	li	a1,48
 740:	855a                	mv	a0,s6
 742:	dadff0ef          	jal	4ee <putc>
  putc(fd, 'x');
 746:	07800593          	li	a1,120
 74a:	855a                	mv	a0,s6
 74c:	da3ff0ef          	jal	4ee <putc>
 750:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 752:	00000b97          	auipc	s7,0x0
 756:	33eb8b93          	addi	s7,s7,830 # a90 <digits>
 75a:	03c9d793          	srli	a5,s3,0x3c
 75e:	97de                	add	a5,a5,s7
 760:	0007c583          	lbu	a1,0(a5)
 764:	855a                	mv	a0,s6
 766:	d89ff0ef          	jal	4ee <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 76a:	0992                	slli	s3,s3,0x4
 76c:	34fd                	addiw	s1,s1,-1
 76e:	f4f5                	bnez	s1,75a <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 770:	8be6                	mv	s7,s9
      state = 0;
 772:	4981                	li	s3,0
 774:	6ca2                	ld	s9,8(sp)
 776:	bda5                	j	5ee <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 778:	008b8493          	addi	s1,s7,8
 77c:	000bc583          	lbu	a1,0(s7)
 780:	855a                	mv	a0,s6
 782:	d6dff0ef          	jal	4ee <putc>
 786:	8ba6                	mv	s7,s1
      state = 0;
 788:	4981                	li	s3,0
 78a:	b595                	j	5ee <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 78c:	008b8993          	addi	s3,s7,8
 790:	000bb483          	ld	s1,0(s7)
 794:	cc91                	beqz	s1,7b0 <vprintf+0x206>
        for(; *s; s++)
 796:	0004c583          	lbu	a1,0(s1)
 79a:	c985                	beqz	a1,7ca <vprintf+0x220>
          putc(fd, *s);
 79c:	855a                	mv	a0,s6
 79e:	d51ff0ef          	jal	4ee <putc>
        for(; *s; s++)
 7a2:	0485                	addi	s1,s1,1
 7a4:	0004c583          	lbu	a1,0(s1)
 7a8:	f9f5                	bnez	a1,79c <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 7aa:	8bce                	mv	s7,s3
      state = 0;
 7ac:	4981                	li	s3,0
 7ae:	b581                	j	5ee <vprintf+0x44>
          s = "(null)";
 7b0:	00000497          	auipc	s1,0x0
 7b4:	2d848493          	addi	s1,s1,728 # a88 <malloc+0x13c>
        for(; *s; s++)
 7b8:	02800593          	li	a1,40
 7bc:	b7c5                	j	79c <vprintf+0x1f2>
        putc(fd, '%');
 7be:	85be                	mv	a1,a5
 7c0:	855a                	mv	a0,s6
 7c2:	d2dff0ef          	jal	4ee <putc>
      state = 0;
 7c6:	4981                	li	s3,0
 7c8:	b51d                	j	5ee <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 7ca:	8bce                	mv	s7,s3
      state = 0;
 7cc:	4981                	li	s3,0
 7ce:	b505                	j	5ee <vprintf+0x44>
 7d0:	6906                	ld	s2,64(sp)
 7d2:	79e2                	ld	s3,56(sp)
 7d4:	7a42                	ld	s4,48(sp)
 7d6:	7aa2                	ld	s5,40(sp)
 7d8:	7b02                	ld	s6,32(sp)
 7da:	6be2                	ld	s7,24(sp)
 7dc:	6c42                	ld	s8,16(sp)
    }
  }
}
 7de:	60e6                	ld	ra,88(sp)
 7e0:	6446                	ld	s0,80(sp)
 7e2:	64a6                	ld	s1,72(sp)
 7e4:	6125                	addi	sp,sp,96
 7e6:	8082                	ret
      if(c0 == 'd'){
 7e8:	06400713          	li	a4,100
 7ec:	e4e78fe3          	beq	a5,a4,64a <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 7f0:	f9478693          	addi	a3,a5,-108
 7f4:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 7f8:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7fa:	4701                	li	a4,0
      } else if(c0 == 'u'){
 7fc:	07500513          	li	a0,117
 800:	e8a78ce3          	beq	a5,a0,698 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 804:	f8b60513          	addi	a0,a2,-117
 808:	e119                	bnez	a0,80e <vprintf+0x264>
 80a:	ea0693e3          	bnez	a3,6b0 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 80e:	f8b58513          	addi	a0,a1,-117
 812:	e119                	bnez	a0,818 <vprintf+0x26e>
 814:	ea071be3          	bnez	a4,6ca <vprintf+0x120>
      } else if(c0 == 'x'){
 818:	07800513          	li	a0,120
 81c:	eca784e3          	beq	a5,a0,6e4 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 820:	f8860613          	addi	a2,a2,-120
 824:	e219                	bnez	a2,82a <vprintf+0x280>
 826:	ec069be3          	bnez	a3,6fc <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 82a:	f8858593          	addi	a1,a1,-120
 82e:	e199                	bnez	a1,834 <vprintf+0x28a>
 830:	ee0713e3          	bnez	a4,716 <vprintf+0x16c>
      } else if(c0 == 'p'){
 834:	07000713          	li	a4,112
 838:	eee78ce3          	beq	a5,a4,730 <vprintf+0x186>
      } else if(c0 == 'c'){
 83c:	06300713          	li	a4,99
 840:	f2e78ce3          	beq	a5,a4,778 <vprintf+0x1ce>
      } else if(c0 == 's'){
 844:	07300713          	li	a4,115
 848:	f4e782e3          	beq	a5,a4,78c <vprintf+0x1e2>
      } else if(c0 == '%'){
 84c:	02500713          	li	a4,37
 850:	f6e787e3          	beq	a5,a4,7be <vprintf+0x214>
        putc(fd, '%');
 854:	02500593          	li	a1,37
 858:	855a                	mv	a0,s6
 85a:	c95ff0ef          	jal	4ee <putc>
        putc(fd, c0);
 85e:	85a6                	mv	a1,s1
 860:	855a                	mv	a0,s6
 862:	c8dff0ef          	jal	4ee <putc>
      state = 0;
 866:	4981                	li	s3,0
 868:	b359                	j	5ee <vprintf+0x44>

000000000000086a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 86a:	715d                	addi	sp,sp,-80
 86c:	ec06                	sd	ra,24(sp)
 86e:	e822                	sd	s0,16(sp)
 870:	1000                	addi	s0,sp,32
 872:	e010                	sd	a2,0(s0)
 874:	e414                	sd	a3,8(s0)
 876:	e818                	sd	a4,16(s0)
 878:	ec1c                	sd	a5,24(s0)
 87a:	03043023          	sd	a6,32(s0)
 87e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 882:	8622                	mv	a2,s0
 884:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 888:	d23ff0ef          	jal	5aa <vprintf>
}
 88c:	60e2                	ld	ra,24(sp)
 88e:	6442                	ld	s0,16(sp)
 890:	6161                	addi	sp,sp,80
 892:	8082                	ret

0000000000000894 <printf>:

void
printf(const char *fmt, ...)
{
 894:	711d                	addi	sp,sp,-96
 896:	ec06                	sd	ra,24(sp)
 898:	e822                	sd	s0,16(sp)
 89a:	1000                	addi	s0,sp,32
 89c:	e40c                	sd	a1,8(s0)
 89e:	e810                	sd	a2,16(s0)
 8a0:	ec14                	sd	a3,24(s0)
 8a2:	f018                	sd	a4,32(s0)
 8a4:	f41c                	sd	a5,40(s0)
 8a6:	03043823          	sd	a6,48(s0)
 8aa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8ae:	00840613          	addi	a2,s0,8
 8b2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8b6:	85aa                	mv	a1,a0
 8b8:	4505                	li	a0,1
 8ba:	cf1ff0ef          	jal	5aa <vprintf>
}
 8be:	60e2                	ld	ra,24(sp)
 8c0:	6442                	ld	s0,16(sp)
 8c2:	6125                	addi	sp,sp,96
 8c4:	8082                	ret

00000000000008c6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8c6:	1141                	addi	sp,sp,-16
 8c8:	e406                	sd	ra,8(sp)
 8ca:	e022                	sd	s0,0(sp)
 8cc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8ce:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d2:	00000797          	auipc	a5,0x0
 8d6:	72e7b783          	ld	a5,1838(a5) # 1000 <freep>
 8da:	a039                	j	8e8 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8dc:	6398                	ld	a4,0(a5)
 8de:	00e7e463          	bltu	a5,a4,8e6 <free+0x20>
 8e2:	00e6ea63          	bltu	a3,a4,8f6 <free+0x30>
{
 8e6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e8:	fed7fae3          	bgeu	a5,a3,8dc <free+0x16>
 8ec:	6398                	ld	a4,0(a5)
 8ee:	00e6e463          	bltu	a3,a4,8f6 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8f2:	fee7eae3          	bltu	a5,a4,8e6 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8f6:	ff852583          	lw	a1,-8(a0)
 8fa:	6390                	ld	a2,0(a5)
 8fc:	02059813          	slli	a6,a1,0x20
 900:	01c85713          	srli	a4,a6,0x1c
 904:	9736                	add	a4,a4,a3
 906:	02e60563          	beq	a2,a4,930 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 90a:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 90e:	4790                	lw	a2,8(a5)
 910:	02061593          	slli	a1,a2,0x20
 914:	01c5d713          	srli	a4,a1,0x1c
 918:	973e                	add	a4,a4,a5
 91a:	02e68263          	beq	a3,a4,93e <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 91e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 920:	00000717          	auipc	a4,0x0
 924:	6ef73023          	sd	a5,1760(a4) # 1000 <freep>
}
 928:	60a2                	ld	ra,8(sp)
 92a:	6402                	ld	s0,0(sp)
 92c:	0141                	addi	sp,sp,16
 92e:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 930:	4618                	lw	a4,8(a2)
 932:	9f2d                	addw	a4,a4,a1
 934:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 938:	6398                	ld	a4,0(a5)
 93a:	6310                	ld	a2,0(a4)
 93c:	b7f9                	j	90a <free+0x44>
    p->s.size += bp->s.size;
 93e:	ff852703          	lw	a4,-8(a0)
 942:	9f31                	addw	a4,a4,a2
 944:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 946:	ff053683          	ld	a3,-16(a0)
 94a:	bfd1                	j	91e <free+0x58>

000000000000094c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 94c:	7139                	addi	sp,sp,-64
 94e:	fc06                	sd	ra,56(sp)
 950:	f822                	sd	s0,48(sp)
 952:	f04a                	sd	s2,32(sp)
 954:	ec4e                	sd	s3,24(sp)
 956:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 958:	02051993          	slli	s3,a0,0x20
 95c:	0209d993          	srli	s3,s3,0x20
 960:	09bd                	addi	s3,s3,15
 962:	0049d993          	srli	s3,s3,0x4
 966:	2985                	addiw	s3,s3,1
 968:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 96a:	00000517          	auipc	a0,0x0
 96e:	69653503          	ld	a0,1686(a0) # 1000 <freep>
 972:	c905                	beqz	a0,9a2 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 974:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 976:	4798                	lw	a4,8(a5)
 978:	09377663          	bgeu	a4,s3,a04 <malloc+0xb8>
 97c:	f426                	sd	s1,40(sp)
 97e:	e852                	sd	s4,16(sp)
 980:	e456                	sd	s5,8(sp)
 982:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 984:	8a4e                	mv	s4,s3
 986:	6705                	lui	a4,0x1
 988:	00e9f363          	bgeu	s3,a4,98e <malloc+0x42>
 98c:	6a05                	lui	s4,0x1
 98e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 992:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 996:	00000497          	auipc	s1,0x0
 99a:	66a48493          	addi	s1,s1,1642 # 1000 <freep>
  if(p == SBRK_ERROR)
 99e:	5afd                	li	s5,-1
 9a0:	a83d                	j	9de <malloc+0x92>
 9a2:	f426                	sd	s1,40(sp)
 9a4:	e852                	sd	s4,16(sp)
 9a6:	e456                	sd	s5,8(sp)
 9a8:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9aa:	00001797          	auipc	a5,0x1
 9ae:	85e78793          	addi	a5,a5,-1954 # 1208 <base>
 9b2:	00000717          	auipc	a4,0x0
 9b6:	64f73723          	sd	a5,1614(a4) # 1000 <freep>
 9ba:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9bc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9c0:	b7d1                	j	984 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 9c2:	6398                	ld	a4,0(a5)
 9c4:	e118                	sd	a4,0(a0)
 9c6:	a899                	j	a1c <malloc+0xd0>
  hp->s.size = nu;
 9c8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9cc:	0541                	addi	a0,a0,16
 9ce:	ef9ff0ef          	jal	8c6 <free>
  return freep;
 9d2:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 9d4:	c125                	beqz	a0,a34 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9d6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9d8:	4798                	lw	a4,8(a5)
 9da:	03277163          	bgeu	a4,s2,9fc <malloc+0xb0>
    if(p == freep)
 9de:	6098                	ld	a4,0(s1)
 9e0:	853e                	mv	a0,a5
 9e2:	fef71ae3          	bne	a4,a5,9d6 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 9e6:	8552                	mv	a0,s4
 9e8:	99dff0ef          	jal	384 <sbrk>
  if(p == SBRK_ERROR)
 9ec:	fd551ee3          	bne	a0,s5,9c8 <malloc+0x7c>
        return 0;
 9f0:	4501                	li	a0,0
 9f2:	74a2                	ld	s1,40(sp)
 9f4:	6a42                	ld	s4,16(sp)
 9f6:	6aa2                	ld	s5,8(sp)
 9f8:	6b02                	ld	s6,0(sp)
 9fa:	a03d                	j	a28 <malloc+0xdc>
 9fc:	74a2                	ld	s1,40(sp)
 9fe:	6a42                	ld	s4,16(sp)
 a00:	6aa2                	ld	s5,8(sp)
 a02:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a04:	fae90fe3          	beq	s2,a4,9c2 <malloc+0x76>
        p->s.size -= nunits;
 a08:	4137073b          	subw	a4,a4,s3
 a0c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a0e:	02071693          	slli	a3,a4,0x20
 a12:	01c6d713          	srli	a4,a3,0x1c
 a16:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a18:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a1c:	00000717          	auipc	a4,0x0
 a20:	5ea73223          	sd	a0,1508(a4) # 1000 <freep>
      return (void*)(p + 1);
 a24:	01078513          	addi	a0,a5,16
  }
}
 a28:	70e2                	ld	ra,56(sp)
 a2a:	7442                	ld	s0,48(sp)
 a2c:	7902                	ld	s2,32(sp)
 a2e:	69e2                	ld	s3,24(sp)
 a30:	6121                	addi	sp,sp,64
 a32:	8082                	ret
 a34:	74a2                	ld	s1,40(sp)
 a36:	6a42                	ld	s4,16(sp)
 a38:	6aa2                	ld	s5,8(sp)
 a3a:	6b02                	ld	s6,0(sp)
 a3c:	b7f5                	j	a28 <malloc+0xdc>
