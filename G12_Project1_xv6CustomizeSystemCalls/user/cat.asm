
user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	addi	s0,sp,64
  12:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  14:	20000a13          	li	s4,512
  18:	00001917          	auipc	s2,0x1
  1c:	ff890913          	addi	s2,s2,-8 # 1010 <buf>
    if (write(1, buf, n) != n) {
  20:	4a85                	li	s5,1
  while((n = read(fd, buf, sizeof(buf))) > 0) {
  22:	8652                	mv	a2,s4
  24:	85ca                	mv	a1,s2
  26:	854e                	mv	a0,s3
  28:	39c000ef          	jal	3c4 <read>
  2c:	84aa                	mv	s1,a0
  2e:	02a05363          	blez	a0,54 <cat+0x54>
    if (write(1, buf, n) != n) {
  32:	8626                	mv	a2,s1
  34:	85ca                	mv	a1,s2
  36:	8556                	mv	a0,s5
  38:	394000ef          	jal	3cc <write>
  3c:	fe9503e3          	beq	a0,s1,22 <cat+0x22>
      fprintf(2, "cat: write error\n");
  40:	00001597          	auipc	a1,0x1
  44:	a0058593          	addi	a1,a1,-1536 # a40 <malloc+0x100>
  48:	4509                	li	a0,2
  4a:	015000ef          	jal	85e <fprintf>
      exit(1);
  4e:	4505                	li	a0,1
  50:	35c000ef          	jal	3ac <exit>
    }
  }
  if(n < 0){
  54:	00054b63          	bltz	a0,6a <cat+0x6a>
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
  58:	70e2                	ld	ra,56(sp)
  5a:	7442                	ld	s0,48(sp)
  5c:	74a2                	ld	s1,40(sp)
  5e:	7902                	ld	s2,32(sp)
  60:	69e2                	ld	s3,24(sp)
  62:	6a42                	ld	s4,16(sp)
  64:	6aa2                	ld	s5,8(sp)
  66:	6121                	addi	sp,sp,64
  68:	8082                	ret
    fprintf(2, "cat: read error\n");
  6a:	00001597          	auipc	a1,0x1
  6e:	9ee58593          	addi	a1,a1,-1554 # a58 <malloc+0x118>
  72:	4509                	li	a0,2
  74:	7ea000ef          	jal	85e <fprintf>
    exit(1);
  78:	4505                	li	a0,1
  7a:	332000ef          	jal	3ac <exit>

000000000000007e <main>:

int
main(int argc, char *argv[])
{
  7e:	7179                	addi	sp,sp,-48
  80:	f406                	sd	ra,40(sp)
  82:	f022                	sd	s0,32(sp)
  84:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  86:	4785                	li	a5,1
  88:	04a7d263          	bge	a5,a0,cc <main+0x4e>
  8c:	ec26                	sd	s1,24(sp)
  8e:	e84a                	sd	s2,16(sp)
  90:	e44e                	sd	s3,8(sp)
  92:	00858913          	addi	s2,a1,8
  96:	ffe5099b          	addiw	s3,a0,-2
  9a:	02099793          	slli	a5,s3,0x20
  9e:	01d7d993          	srli	s3,a5,0x1d
  a2:	05c1                	addi	a1,a1,16
  a4:	99ae                	add	s3,s3,a1
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], O_RDONLY)) < 0){
  a6:	4581                	li	a1,0
  a8:	00093503          	ld	a0,0(s2)
  ac:	3cc000ef          	jal	478 <open>
  b0:	84aa                	mv	s1,a0
  b2:	02054663          	bltz	a0,de <main+0x60>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
  b6:	f4bff0ef          	jal	0 <cat>
    close(fd);
  ba:	8526                	mv	a0,s1
  bc:	318000ef          	jal	3d4 <close>
  for(i = 1; i < argc; i++){
  c0:	0921                	addi	s2,s2,8
  c2:	ff3912e3          	bne	s2,s3,a6 <main+0x28>
  }
  exit(0);
  c6:	4501                	li	a0,0
  c8:	2e4000ef          	jal	3ac <exit>
  cc:	ec26                	sd	s1,24(sp)
  ce:	e84a                	sd	s2,16(sp)
  d0:	e44e                	sd	s3,8(sp)
    cat(0);
  d2:	4501                	li	a0,0
  d4:	f2dff0ef          	jal	0 <cat>
    exit(0);
  d8:	4501                	li	a0,0
  da:	2d2000ef          	jal	3ac <exit>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
  de:	00093603          	ld	a2,0(s2)
  e2:	00001597          	auipc	a1,0x1
  e6:	98e58593          	addi	a1,a1,-1650 # a70 <malloc+0x130>
  ea:	4509                	li	a0,2
  ec:	772000ef          	jal	85e <fprintf>
      exit(1);
  f0:	4505                	li	a0,1
  f2:	2ba000ef          	jal	3ac <exit>

00000000000000f6 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e406                	sd	ra,8(sp)
  fa:	e022                	sd	s0,0(sp)
  fc:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  fe:	f81ff0ef          	jal	7e <main>
  exit(r);
 102:	2aa000ef          	jal	3ac <exit>

0000000000000106 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 106:	1141                	addi	sp,sp,-16
 108:	e406                	sd	ra,8(sp)
 10a:	e022                	sd	s0,0(sp)
 10c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 10e:	87aa                	mv	a5,a0
 110:	0585                	addi	a1,a1,1
 112:	0785                	addi	a5,a5,1
 114:	fff5c703          	lbu	a4,-1(a1)
 118:	fee78fa3          	sb	a4,-1(a5)
 11c:	fb75                	bnez	a4,110 <strcpy+0xa>
    ;
  return os;
}
 11e:	60a2                	ld	ra,8(sp)
 120:	6402                	ld	s0,0(sp)
 122:	0141                	addi	sp,sp,16
 124:	8082                	ret

0000000000000126 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 126:	1141                	addi	sp,sp,-16
 128:	e406                	sd	ra,8(sp)
 12a:	e022                	sd	s0,0(sp)
 12c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 12e:	00054783          	lbu	a5,0(a0)
 132:	cb91                	beqz	a5,146 <strcmp+0x20>
 134:	0005c703          	lbu	a4,0(a1)
 138:	00f71763          	bne	a4,a5,146 <strcmp+0x20>
    p++, q++;
 13c:	0505                	addi	a0,a0,1
 13e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 140:	00054783          	lbu	a5,0(a0)
 144:	fbe5                	bnez	a5,134 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 146:	0005c503          	lbu	a0,0(a1)
}
 14a:	40a7853b          	subw	a0,a5,a0
 14e:	60a2                	ld	ra,8(sp)
 150:	6402                	ld	s0,0(sp)
 152:	0141                	addi	sp,sp,16
 154:	8082                	ret

0000000000000156 <strlen>:

uint
strlen(const char *s)
{
 156:	1141                	addi	sp,sp,-16
 158:	e406                	sd	ra,8(sp)
 15a:	e022                	sd	s0,0(sp)
 15c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 15e:	00054783          	lbu	a5,0(a0)
 162:	cf91                	beqz	a5,17e <strlen+0x28>
 164:	00150793          	addi	a5,a0,1
 168:	86be                	mv	a3,a5
 16a:	0785                	addi	a5,a5,1
 16c:	fff7c703          	lbu	a4,-1(a5)
 170:	ff65                	bnez	a4,168 <strlen+0x12>
 172:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 176:	60a2                	ld	ra,8(sp)
 178:	6402                	ld	s0,0(sp)
 17a:	0141                	addi	sp,sp,16
 17c:	8082                	ret
  for(n = 0; s[n]; n++)
 17e:	4501                	li	a0,0
 180:	bfdd                	j	176 <strlen+0x20>

0000000000000182 <memset>:

void*
memset(void *dst, int c, uint n)
{
 182:	1141                	addi	sp,sp,-16
 184:	e406                	sd	ra,8(sp)
 186:	e022                	sd	s0,0(sp)
 188:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 18a:	ca19                	beqz	a2,1a0 <memset+0x1e>
 18c:	87aa                	mv	a5,a0
 18e:	1602                	slli	a2,a2,0x20
 190:	9201                	srli	a2,a2,0x20
 192:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 196:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 19a:	0785                	addi	a5,a5,1
 19c:	fee79de3          	bne	a5,a4,196 <memset+0x14>
  }
  return dst;
}
 1a0:	60a2                	ld	ra,8(sp)
 1a2:	6402                	ld	s0,0(sp)
 1a4:	0141                	addi	sp,sp,16
 1a6:	8082                	ret

00000000000001a8 <strchr>:

char*
strchr(const char *s, char c)
{
 1a8:	1141                	addi	sp,sp,-16
 1aa:	e406                	sd	ra,8(sp)
 1ac:	e022                	sd	s0,0(sp)
 1ae:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1b0:	00054783          	lbu	a5,0(a0)
 1b4:	cf81                	beqz	a5,1cc <strchr+0x24>
    if(*s == c)
 1b6:	00f58763          	beq	a1,a5,1c4 <strchr+0x1c>
  for(; *s; s++)
 1ba:	0505                	addi	a0,a0,1
 1bc:	00054783          	lbu	a5,0(a0)
 1c0:	fbfd                	bnez	a5,1b6 <strchr+0xe>
      return (char*)s;
  return 0;
 1c2:	4501                	li	a0,0
}
 1c4:	60a2                	ld	ra,8(sp)
 1c6:	6402                	ld	s0,0(sp)
 1c8:	0141                	addi	sp,sp,16
 1ca:	8082                	ret
  return 0;
 1cc:	4501                	li	a0,0
 1ce:	bfdd                	j	1c4 <strchr+0x1c>

00000000000001d0 <gets>:

char*
gets(char *buf, int max)
{
 1d0:	711d                	addi	sp,sp,-96
 1d2:	ec86                	sd	ra,88(sp)
 1d4:	e8a2                	sd	s0,80(sp)
 1d6:	e4a6                	sd	s1,72(sp)
 1d8:	e0ca                	sd	s2,64(sp)
 1da:	fc4e                	sd	s3,56(sp)
 1dc:	f852                	sd	s4,48(sp)
 1de:	f456                	sd	s5,40(sp)
 1e0:	f05a                	sd	s6,32(sp)
 1e2:	ec5e                	sd	s7,24(sp)
 1e4:	e862                	sd	s8,16(sp)
 1e6:	1080                	addi	s0,sp,96
 1e8:	8baa                	mv	s7,a0
 1ea:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ec:	892a                	mv	s2,a0
 1ee:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1f0:	faf40b13          	addi	s6,s0,-81
 1f4:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1f6:	8c26                	mv	s8,s1
 1f8:	0014899b          	addiw	s3,s1,1
 1fc:	84ce                	mv	s1,s3
 1fe:	0349d463          	bge	s3,s4,226 <gets+0x56>
    cc = read(0, &c, 1);
 202:	8656                	mv	a2,s5
 204:	85da                	mv	a1,s6
 206:	4501                	li	a0,0
 208:	1bc000ef          	jal	3c4 <read>
    if(cc < 1)
 20c:	00a05d63          	blez	a0,226 <gets+0x56>
      break;
    buf[i++] = c;
 210:	faf44783          	lbu	a5,-81(s0)
 214:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 218:	0905                	addi	s2,s2,1
 21a:	ff678713          	addi	a4,a5,-10
 21e:	c319                	beqz	a4,224 <gets+0x54>
 220:	17cd                	addi	a5,a5,-13
 222:	fbf1                	bnez	a5,1f6 <gets+0x26>
    buf[i++] = c;
 224:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 226:	9c5e                	add	s8,s8,s7
 228:	000c0023          	sb	zero,0(s8)
  return buf;
}
 22c:	855e                	mv	a0,s7
 22e:	60e6                	ld	ra,88(sp)
 230:	6446                	ld	s0,80(sp)
 232:	64a6                	ld	s1,72(sp)
 234:	6906                	ld	s2,64(sp)
 236:	79e2                	ld	s3,56(sp)
 238:	7a42                	ld	s4,48(sp)
 23a:	7aa2                	ld	s5,40(sp)
 23c:	7b02                	ld	s6,32(sp)
 23e:	6be2                	ld	s7,24(sp)
 240:	6c42                	ld	s8,16(sp)
 242:	6125                	addi	sp,sp,96
 244:	8082                	ret

0000000000000246 <stat>:

int
stat(const char *n, struct stat *st)
{
 246:	1101                	addi	sp,sp,-32
 248:	ec06                	sd	ra,24(sp)
 24a:	e822                	sd	s0,16(sp)
 24c:	e04a                	sd	s2,0(sp)
 24e:	1000                	addi	s0,sp,32
 250:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 252:	4581                	li	a1,0
 254:	224000ef          	jal	478 <open>
  if(fd < 0)
 258:	02054263          	bltz	a0,27c <stat+0x36>
 25c:	e426                	sd	s1,8(sp)
 25e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 260:	85ca                	mv	a1,s2
 262:	22e000ef          	jal	490 <fstat>
 266:	892a                	mv	s2,a0
  close(fd);
 268:	8526                	mv	a0,s1
 26a:	16a000ef          	jal	3d4 <close>
  return r;
 26e:	64a2                	ld	s1,8(sp)
}
 270:	854a                	mv	a0,s2
 272:	60e2                	ld	ra,24(sp)
 274:	6442                	ld	s0,16(sp)
 276:	6902                	ld	s2,0(sp)
 278:	6105                	addi	sp,sp,32
 27a:	8082                	ret
    return -1;
 27c:	57fd                	li	a5,-1
 27e:	893e                	mv	s2,a5
 280:	bfc5                	j	270 <stat+0x2a>

0000000000000282 <atoi>:

int
atoi(const char *s)
{
 282:	1141                	addi	sp,sp,-16
 284:	e406                	sd	ra,8(sp)
 286:	e022                	sd	s0,0(sp)
 288:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 28a:	00054683          	lbu	a3,0(a0)
 28e:	fd06879b          	addiw	a5,a3,-48
 292:	0ff7f793          	zext.b	a5,a5
 296:	4625                	li	a2,9
 298:	02f66963          	bltu	a2,a5,2ca <atoi+0x48>
 29c:	872a                	mv	a4,a0
  n = 0;
 29e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2a0:	0705                	addi	a4,a4,1
 2a2:	0025179b          	slliw	a5,a0,0x2
 2a6:	9fa9                	addw	a5,a5,a0
 2a8:	0017979b          	slliw	a5,a5,0x1
 2ac:	9fb5                	addw	a5,a5,a3
 2ae:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2b2:	00074683          	lbu	a3,0(a4)
 2b6:	fd06879b          	addiw	a5,a3,-48
 2ba:	0ff7f793          	zext.b	a5,a5
 2be:	fef671e3          	bgeu	a2,a5,2a0 <atoi+0x1e>
  return n;
}
 2c2:	60a2                	ld	ra,8(sp)
 2c4:	6402                	ld	s0,0(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret
  n = 0;
 2ca:	4501                	li	a0,0
 2cc:	bfdd                	j	2c2 <atoi+0x40>

00000000000002ce <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e406                	sd	ra,8(sp)
 2d2:	e022                	sd	s0,0(sp)
 2d4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2d6:	02b57563          	bgeu	a0,a1,300 <memmove+0x32>
    while(n-- > 0)
 2da:	00c05f63          	blez	a2,2f8 <memmove+0x2a>
 2de:	1602                	slli	a2,a2,0x20
 2e0:	9201                	srli	a2,a2,0x20
 2e2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2e6:	872a                	mv	a4,a0
      *dst++ = *src++;
 2e8:	0585                	addi	a1,a1,1
 2ea:	0705                	addi	a4,a4,1
 2ec:	fff5c683          	lbu	a3,-1(a1)
 2f0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2f4:	fee79ae3          	bne	a5,a4,2e8 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2f8:	60a2                	ld	ra,8(sp)
 2fa:	6402                	ld	s0,0(sp)
 2fc:	0141                	addi	sp,sp,16
 2fe:	8082                	ret
    while(n-- > 0)
 300:	fec05ce3          	blez	a2,2f8 <memmove+0x2a>
    dst += n;
 304:	00c50733          	add	a4,a0,a2
    src += n;
 308:	95b2                	add	a1,a1,a2
 30a:	fff6079b          	addiw	a5,a2,-1
 30e:	1782                	slli	a5,a5,0x20
 310:	9381                	srli	a5,a5,0x20
 312:	fff7c793          	not	a5,a5
 316:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 318:	15fd                	addi	a1,a1,-1
 31a:	177d                	addi	a4,a4,-1
 31c:	0005c683          	lbu	a3,0(a1)
 320:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 324:	fef71ae3          	bne	a4,a5,318 <memmove+0x4a>
 328:	bfc1                	j	2f8 <memmove+0x2a>

000000000000032a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e406                	sd	ra,8(sp)
 32e:	e022                	sd	s0,0(sp)
 330:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 332:	c61d                	beqz	a2,360 <memcmp+0x36>
 334:	1602                	slli	a2,a2,0x20
 336:	9201                	srli	a2,a2,0x20
 338:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 33c:	00054783          	lbu	a5,0(a0)
 340:	0005c703          	lbu	a4,0(a1)
 344:	00e79863          	bne	a5,a4,354 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 348:	0505                	addi	a0,a0,1
    p2++;
 34a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 34c:	fed518e3          	bne	a0,a3,33c <memcmp+0x12>
  }
  return 0;
 350:	4501                	li	a0,0
 352:	a019                	j	358 <memcmp+0x2e>
      return *p1 - *p2;
 354:	40e7853b          	subw	a0,a5,a4
}
 358:	60a2                	ld	ra,8(sp)
 35a:	6402                	ld	s0,0(sp)
 35c:	0141                	addi	sp,sp,16
 35e:	8082                	ret
  return 0;
 360:	4501                	li	a0,0
 362:	bfdd                	j	358 <memcmp+0x2e>

0000000000000364 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 364:	1141                	addi	sp,sp,-16
 366:	e406                	sd	ra,8(sp)
 368:	e022                	sd	s0,0(sp)
 36a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 36c:	f63ff0ef          	jal	2ce <memmove>
}
 370:	60a2                	ld	ra,8(sp)
 372:	6402                	ld	s0,0(sp)
 374:	0141                	addi	sp,sp,16
 376:	8082                	ret

0000000000000378 <sbrk>:

char *
sbrk(int n) {
 378:	1141                	addi	sp,sp,-16
 37a:	e406                	sd	ra,8(sp)
 37c:	e022                	sd	s0,0(sp)
 37e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 380:	4585                	li	a1,1
 382:	13e000ef          	jal	4c0 <sys_sbrk>
}
 386:	60a2                	ld	ra,8(sp)
 388:	6402                	ld	s0,0(sp)
 38a:	0141                	addi	sp,sp,16
 38c:	8082                	ret

000000000000038e <sbrklazy>:

char *
sbrklazy(int n) {
 38e:	1141                	addi	sp,sp,-16
 390:	e406                	sd	ra,8(sp)
 392:	e022                	sd	s0,0(sp)
 394:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 396:	4589                	li	a1,2
 398:	128000ef          	jal	4c0 <sys_sbrk>
}
 39c:	60a2                	ld	ra,8(sp)
 39e:	6402                	ld	s0,0(sp)
 3a0:	0141                	addi	sp,sp,16
 3a2:	8082                	ret

00000000000003a4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3a4:	4885                	li	a7,1
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ac:	4889                	li	a7,2
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3b4:	488d                	li	a7,3
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3bc:	4891                	li	a7,4
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <read>:
.global read
read:
 li a7, SYS_read
 3c4:	4895                	li	a7,5
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <write>:
.global write
write:
 li a7, SYS_write
 3cc:	48c1                	li	a7,16
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <close>:
.global close
close:
 li a7, SYS_close
 3d4:	48d5                	li	a7,21
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 3dc:	48d9                	li	a7,22
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <shmat>:
.global shmat
shmat:
 li a7, SYS_shmat
 3e4:	48dd                	li	a7,23
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 3ec:	48e1                	li	a7,24
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 3f4:	48e5                	li	a7,25
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <lockinit>:
.global lockinit
lockinit:
 li a7, SYS_lockinit
 3fc:	48e9                	li	a7,26
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <lockacquire>:
.global lockacquire
lockacquire:
 li a7, SYS_lockacquire
 404:	48ed                	li	a7,27
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <lockrelease>:
.global lockrelease
lockrelease:
 li a7, SYS_lockrelease
 40c:	48f1                	li	a7,28
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <locktry>:
.global locktry
locktry:
 li a7, SYS_locktry
 414:	48f5                	li	a7,29
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <lockcheck>:
.global lockcheck
lockcheck:
 li a7, SYS_lockcheck
 41c:	48f9                	li	a7,30
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <sendmsg>:
.global sendmsg
sendmsg:
 li a7, SYS_sendmsg
 424:	48fd                	li	a7,31
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <recvmsg>:
.global recvmsg
recvmsg:
 li a7, SYS_recvmsg
 42c:	02000893          	li	a7,32
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <broadcast>:
.global broadcast
broadcast:
 li a7, SYS_broadcast
 436:	02100893          	li	a7,33
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <getprocsinfo>:
.global getprocsinfo
getprocsinfo:
 li a7, SYS_getprocsinfo
 440:	02200893          	li	a7,34
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 44a:	02300893          	li	a7,35
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <sleep2>:
.global sleep2
sleep2:
 li a7, SYS_sleep2
 454:	02400893          	li	a7,36
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <signal>:
.global signal
signal:
 li a7, SYS_signal
 45e:	02500893          	li	a7,37
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <kill>:
.global kill
kill:
 li a7, SYS_kill
 468:	4899                	li	a7,6
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <exec>:
.global exec
exec:
 li a7, SYS_exec
 470:	489d                	li	a7,7
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <open>:
.global open
open:
 li a7, SYS_open
 478:	48bd                	li	a7,15
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 480:	48c5                	li	a7,17
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 488:	48c9                	li	a7,18
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 490:	48a1                	li	a7,8
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <link>:
.global link
link:
 li a7, SYS_link
 498:	48cd                	li	a7,19
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4a0:	48d1                	li	a7,20
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4a8:	48a5                	li	a7,9
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4b0:	48a9                	li	a7,10
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4b8:	48ad                	li	a7,11
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4c0:	48b1                	li	a7,12
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <pause>:
.global pause
pause:
 li a7, SYS_pause
 4c8:	48b5                	li	a7,13
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4d0:	48b9                	li	a7,14
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <setchildlimit>:
.global setchildlimit
setchildlimit:
 li a7, SYS_setchildlimit
 4d8:	02600893          	li	a7,38
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4e2:	1101                	addi	sp,sp,-32
 4e4:	ec06                	sd	ra,24(sp)
 4e6:	e822                	sd	s0,16(sp)
 4e8:	1000                	addi	s0,sp,32
 4ea:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ee:	4605                	li	a2,1
 4f0:	fef40593          	addi	a1,s0,-17
 4f4:	ed9ff0ef          	jal	3cc <write>
}
 4f8:	60e2                	ld	ra,24(sp)
 4fa:	6442                	ld	s0,16(sp)
 4fc:	6105                	addi	sp,sp,32
 4fe:	8082                	ret

0000000000000500 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 500:	715d                	addi	sp,sp,-80
 502:	e486                	sd	ra,72(sp)
 504:	e0a2                	sd	s0,64(sp)
 506:	f84a                	sd	s2,48(sp)
 508:	f44e                	sd	s3,40(sp)
 50a:	0880                	addi	s0,sp,80
 50c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 50e:	c6d1                	beqz	a3,59a <printint+0x9a>
 510:	0805d563          	bgez	a1,59a <printint+0x9a>
    neg = 1;
    x = -xx;
 514:	40b005b3          	neg	a1,a1
    neg = 1;
 518:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 51a:	fb840993          	addi	s3,s0,-72
  neg = 0;
 51e:	86ce                	mv	a3,s3
  i = 0;
 520:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 522:	00000817          	auipc	a6,0x0
 526:	56e80813          	addi	a6,a6,1390 # a90 <digits>
 52a:	88ba                	mv	a7,a4
 52c:	0017051b          	addiw	a0,a4,1
 530:	872a                	mv	a4,a0
 532:	02c5f7b3          	remu	a5,a1,a2
 536:	97c2                	add	a5,a5,a6
 538:	0007c783          	lbu	a5,0(a5)
 53c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 540:	87ae                	mv	a5,a1
 542:	02c5d5b3          	divu	a1,a1,a2
 546:	0685                	addi	a3,a3,1
 548:	fec7f1e3          	bgeu	a5,a2,52a <printint+0x2a>
  if(neg)
 54c:	00030c63          	beqz	t1,564 <printint+0x64>
    buf[i++] = '-';
 550:	fd050793          	addi	a5,a0,-48
 554:	00878533          	add	a0,a5,s0
 558:	02d00793          	li	a5,45
 55c:	fef50423          	sb	a5,-24(a0)
 560:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 564:	02e05563          	blez	a4,58e <printint+0x8e>
 568:	fc26                	sd	s1,56(sp)
 56a:	377d                	addiw	a4,a4,-1
 56c:	00e984b3          	add	s1,s3,a4
 570:	19fd                	addi	s3,s3,-1
 572:	99ba                	add	s3,s3,a4
 574:	1702                	slli	a4,a4,0x20
 576:	9301                	srli	a4,a4,0x20
 578:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 57c:	0004c583          	lbu	a1,0(s1)
 580:	854a                	mv	a0,s2
 582:	f61ff0ef          	jal	4e2 <putc>
  while(--i >= 0)
 586:	14fd                	addi	s1,s1,-1
 588:	ff349ae3          	bne	s1,s3,57c <printint+0x7c>
 58c:	74e2                	ld	s1,56(sp)
}
 58e:	60a6                	ld	ra,72(sp)
 590:	6406                	ld	s0,64(sp)
 592:	7942                	ld	s2,48(sp)
 594:	79a2                	ld	s3,40(sp)
 596:	6161                	addi	sp,sp,80
 598:	8082                	ret
  neg = 0;
 59a:	4301                	li	t1,0
 59c:	bfbd                	j	51a <printint+0x1a>

000000000000059e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 59e:	711d                	addi	sp,sp,-96
 5a0:	ec86                	sd	ra,88(sp)
 5a2:	e8a2                	sd	s0,80(sp)
 5a4:	e4a6                	sd	s1,72(sp)
 5a6:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5a8:	0005c483          	lbu	s1,0(a1)
 5ac:	22048363          	beqz	s1,7d2 <vprintf+0x234>
 5b0:	e0ca                	sd	s2,64(sp)
 5b2:	fc4e                	sd	s3,56(sp)
 5b4:	f852                	sd	s4,48(sp)
 5b6:	f456                	sd	s5,40(sp)
 5b8:	f05a                	sd	s6,32(sp)
 5ba:	ec5e                	sd	s7,24(sp)
 5bc:	e862                	sd	s8,16(sp)
 5be:	8b2a                	mv	s6,a0
 5c0:	8a2e                	mv	s4,a1
 5c2:	8bb2                	mv	s7,a2
  state = 0;
 5c4:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5c6:	4901                	li	s2,0
 5c8:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5ca:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5ce:	06400c13          	li	s8,100
 5d2:	a00d                	j	5f4 <vprintf+0x56>
        putc(fd, c0);
 5d4:	85a6                	mv	a1,s1
 5d6:	855a                	mv	a0,s6
 5d8:	f0bff0ef          	jal	4e2 <putc>
 5dc:	a019                	j	5e2 <vprintf+0x44>
    } else if(state == '%'){
 5de:	03598363          	beq	s3,s5,604 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 5e2:	0019079b          	addiw	a5,s2,1
 5e6:	893e                	mv	s2,a5
 5e8:	873e                	mv	a4,a5
 5ea:	97d2                	add	a5,a5,s4
 5ec:	0007c483          	lbu	s1,0(a5)
 5f0:	1c048a63          	beqz	s1,7c4 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 5f4:	0004879b          	sext.w	a5,s1
    if(state == 0){
 5f8:	fe0993e3          	bnez	s3,5de <vprintf+0x40>
      if(c0 == '%'){
 5fc:	fd579ce3          	bne	a5,s5,5d4 <vprintf+0x36>
        state = '%';
 600:	89be                	mv	s3,a5
 602:	b7c5                	j	5e2 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 604:	00ea06b3          	add	a3,s4,a4
 608:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 60c:	1c060863          	beqz	a2,7dc <vprintf+0x23e>
      if(c0 == 'd'){
 610:	03878763          	beq	a5,s8,63e <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 614:	f9478693          	addi	a3,a5,-108
 618:	0016b693          	seqz	a3,a3
 61c:	f9c60593          	addi	a1,a2,-100
 620:	e99d                	bnez	a1,656 <vprintf+0xb8>
 622:	ca95                	beqz	a3,656 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 624:	008b8493          	addi	s1,s7,8
 628:	4685                	li	a3,1
 62a:	4629                	li	a2,10
 62c:	000bb583          	ld	a1,0(s7)
 630:	855a                	mv	a0,s6
 632:	ecfff0ef          	jal	500 <printint>
        i += 1;
 636:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 638:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 63a:	4981                	li	s3,0
 63c:	b75d                	j	5e2 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 63e:	008b8493          	addi	s1,s7,8
 642:	4685                	li	a3,1
 644:	4629                	li	a2,10
 646:	000ba583          	lw	a1,0(s7)
 64a:	855a                	mv	a0,s6
 64c:	eb5ff0ef          	jal	500 <printint>
 650:	8ba6                	mv	s7,s1
      state = 0;
 652:	4981                	li	s3,0
 654:	b779                	j	5e2 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 656:	9752                	add	a4,a4,s4
 658:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 65c:	f9460713          	addi	a4,a2,-108
 660:	00173713          	seqz	a4,a4
 664:	8f75                	and	a4,a4,a3
 666:	f9c58513          	addi	a0,a1,-100
 66a:	18051363          	bnez	a0,7f0 <vprintf+0x252>
 66e:	18070163          	beqz	a4,7f0 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 672:	008b8493          	addi	s1,s7,8
 676:	4685                	li	a3,1
 678:	4629                	li	a2,10
 67a:	000bb583          	ld	a1,0(s7)
 67e:	855a                	mv	a0,s6
 680:	e81ff0ef          	jal	500 <printint>
        i += 2;
 684:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 686:	8ba6                	mv	s7,s1
      state = 0;
 688:	4981                	li	s3,0
        i += 2;
 68a:	bfa1                	j	5e2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 68c:	008b8493          	addi	s1,s7,8
 690:	4681                	li	a3,0
 692:	4629                	li	a2,10
 694:	000be583          	lwu	a1,0(s7)
 698:	855a                	mv	a0,s6
 69a:	e67ff0ef          	jal	500 <printint>
 69e:	8ba6                	mv	s7,s1
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	b781                	j	5e2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a4:	008b8493          	addi	s1,s7,8
 6a8:	4681                	li	a3,0
 6aa:	4629                	li	a2,10
 6ac:	000bb583          	ld	a1,0(s7)
 6b0:	855a                	mv	a0,s6
 6b2:	e4fff0ef          	jal	500 <printint>
        i += 1;
 6b6:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b8:	8ba6                	mv	s7,s1
      state = 0;
 6ba:	4981                	li	s3,0
 6bc:	b71d                	j	5e2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6be:	008b8493          	addi	s1,s7,8
 6c2:	4681                	li	a3,0
 6c4:	4629                	li	a2,10
 6c6:	000bb583          	ld	a1,0(s7)
 6ca:	855a                	mv	a0,s6
 6cc:	e35ff0ef          	jal	500 <printint>
        i += 2;
 6d0:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d2:	8ba6                	mv	s7,s1
      state = 0;
 6d4:	4981                	li	s3,0
        i += 2;
 6d6:	b731                	j	5e2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6d8:	008b8493          	addi	s1,s7,8
 6dc:	4681                	li	a3,0
 6de:	4641                	li	a2,16
 6e0:	000be583          	lwu	a1,0(s7)
 6e4:	855a                	mv	a0,s6
 6e6:	e1bff0ef          	jal	500 <printint>
 6ea:	8ba6                	mv	s7,s1
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	bdd5                	j	5e2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f0:	008b8493          	addi	s1,s7,8
 6f4:	4681                	li	a3,0
 6f6:	4641                	li	a2,16
 6f8:	000bb583          	ld	a1,0(s7)
 6fc:	855a                	mv	a0,s6
 6fe:	e03ff0ef          	jal	500 <printint>
        i += 1;
 702:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 704:	8ba6                	mv	s7,s1
      state = 0;
 706:	4981                	li	s3,0
 708:	bde9                	j	5e2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 70a:	008b8493          	addi	s1,s7,8
 70e:	4681                	li	a3,0
 710:	4641                	li	a2,16
 712:	000bb583          	ld	a1,0(s7)
 716:	855a                	mv	a0,s6
 718:	de9ff0ef          	jal	500 <printint>
        i += 2;
 71c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 71e:	8ba6                	mv	s7,s1
      state = 0;
 720:	4981                	li	s3,0
        i += 2;
 722:	b5c1                	j	5e2 <vprintf+0x44>
 724:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 726:	008b8793          	addi	a5,s7,8
 72a:	8cbe                	mv	s9,a5
 72c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 730:	03000593          	li	a1,48
 734:	855a                	mv	a0,s6
 736:	dadff0ef          	jal	4e2 <putc>
  putc(fd, 'x');
 73a:	07800593          	li	a1,120
 73e:	855a                	mv	a0,s6
 740:	da3ff0ef          	jal	4e2 <putc>
 744:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 746:	00000b97          	auipc	s7,0x0
 74a:	34ab8b93          	addi	s7,s7,842 # a90 <digits>
 74e:	03c9d793          	srli	a5,s3,0x3c
 752:	97de                	add	a5,a5,s7
 754:	0007c583          	lbu	a1,0(a5)
 758:	855a                	mv	a0,s6
 75a:	d89ff0ef          	jal	4e2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 75e:	0992                	slli	s3,s3,0x4
 760:	34fd                	addiw	s1,s1,-1
 762:	f4f5                	bnez	s1,74e <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 764:	8be6                	mv	s7,s9
      state = 0;
 766:	4981                	li	s3,0
 768:	6ca2                	ld	s9,8(sp)
 76a:	bda5                	j	5e2 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 76c:	008b8493          	addi	s1,s7,8
 770:	000bc583          	lbu	a1,0(s7)
 774:	855a                	mv	a0,s6
 776:	d6dff0ef          	jal	4e2 <putc>
 77a:	8ba6                	mv	s7,s1
      state = 0;
 77c:	4981                	li	s3,0
 77e:	b595                	j	5e2 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 780:	008b8993          	addi	s3,s7,8
 784:	000bb483          	ld	s1,0(s7)
 788:	cc91                	beqz	s1,7a4 <vprintf+0x206>
        for(; *s; s++)
 78a:	0004c583          	lbu	a1,0(s1)
 78e:	c985                	beqz	a1,7be <vprintf+0x220>
          putc(fd, *s);
 790:	855a                	mv	a0,s6
 792:	d51ff0ef          	jal	4e2 <putc>
        for(; *s; s++)
 796:	0485                	addi	s1,s1,1
 798:	0004c583          	lbu	a1,0(s1)
 79c:	f9f5                	bnez	a1,790 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 79e:	8bce                	mv	s7,s3
      state = 0;
 7a0:	4981                	li	s3,0
 7a2:	b581                	j	5e2 <vprintf+0x44>
          s = "(null)";
 7a4:	00000497          	auipc	s1,0x0
 7a8:	2e448493          	addi	s1,s1,740 # a88 <malloc+0x148>
        for(; *s; s++)
 7ac:	02800593          	li	a1,40
 7b0:	b7c5                	j	790 <vprintf+0x1f2>
        putc(fd, '%');
 7b2:	85be                	mv	a1,a5
 7b4:	855a                	mv	a0,s6
 7b6:	d2dff0ef          	jal	4e2 <putc>
      state = 0;
 7ba:	4981                	li	s3,0
 7bc:	b51d                	j	5e2 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 7be:	8bce                	mv	s7,s3
      state = 0;
 7c0:	4981                	li	s3,0
 7c2:	b505                	j	5e2 <vprintf+0x44>
 7c4:	6906                	ld	s2,64(sp)
 7c6:	79e2                	ld	s3,56(sp)
 7c8:	7a42                	ld	s4,48(sp)
 7ca:	7aa2                	ld	s5,40(sp)
 7cc:	7b02                	ld	s6,32(sp)
 7ce:	6be2                	ld	s7,24(sp)
 7d0:	6c42                	ld	s8,16(sp)
    }
  }
}
 7d2:	60e6                	ld	ra,88(sp)
 7d4:	6446                	ld	s0,80(sp)
 7d6:	64a6                	ld	s1,72(sp)
 7d8:	6125                	addi	sp,sp,96
 7da:	8082                	ret
      if(c0 == 'd'){
 7dc:	06400713          	li	a4,100
 7e0:	e4e78fe3          	beq	a5,a4,63e <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 7e4:	f9478693          	addi	a3,a5,-108
 7e8:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 7ec:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7ee:	4701                	li	a4,0
      } else if(c0 == 'u'){
 7f0:	07500513          	li	a0,117
 7f4:	e8a78ce3          	beq	a5,a0,68c <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 7f8:	f8b60513          	addi	a0,a2,-117
 7fc:	e119                	bnez	a0,802 <vprintf+0x264>
 7fe:	ea0693e3          	bnez	a3,6a4 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 802:	f8b58513          	addi	a0,a1,-117
 806:	e119                	bnez	a0,80c <vprintf+0x26e>
 808:	ea071be3          	bnez	a4,6be <vprintf+0x120>
      } else if(c0 == 'x'){
 80c:	07800513          	li	a0,120
 810:	eca784e3          	beq	a5,a0,6d8 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 814:	f8860613          	addi	a2,a2,-120
 818:	e219                	bnez	a2,81e <vprintf+0x280>
 81a:	ec069be3          	bnez	a3,6f0 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 81e:	f8858593          	addi	a1,a1,-120
 822:	e199                	bnez	a1,828 <vprintf+0x28a>
 824:	ee0713e3          	bnez	a4,70a <vprintf+0x16c>
      } else if(c0 == 'p'){
 828:	07000713          	li	a4,112
 82c:	eee78ce3          	beq	a5,a4,724 <vprintf+0x186>
      } else if(c0 == 'c'){
 830:	06300713          	li	a4,99
 834:	f2e78ce3          	beq	a5,a4,76c <vprintf+0x1ce>
      } else if(c0 == 's'){
 838:	07300713          	li	a4,115
 83c:	f4e782e3          	beq	a5,a4,780 <vprintf+0x1e2>
      } else if(c0 == '%'){
 840:	02500713          	li	a4,37
 844:	f6e787e3          	beq	a5,a4,7b2 <vprintf+0x214>
        putc(fd, '%');
 848:	02500593          	li	a1,37
 84c:	855a                	mv	a0,s6
 84e:	c95ff0ef          	jal	4e2 <putc>
        putc(fd, c0);
 852:	85a6                	mv	a1,s1
 854:	855a                	mv	a0,s6
 856:	c8dff0ef          	jal	4e2 <putc>
      state = 0;
 85a:	4981                	li	s3,0
 85c:	b359                	j	5e2 <vprintf+0x44>

000000000000085e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 85e:	715d                	addi	sp,sp,-80
 860:	ec06                	sd	ra,24(sp)
 862:	e822                	sd	s0,16(sp)
 864:	1000                	addi	s0,sp,32
 866:	e010                	sd	a2,0(s0)
 868:	e414                	sd	a3,8(s0)
 86a:	e818                	sd	a4,16(s0)
 86c:	ec1c                	sd	a5,24(s0)
 86e:	03043023          	sd	a6,32(s0)
 872:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 876:	8622                	mv	a2,s0
 878:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 87c:	d23ff0ef          	jal	59e <vprintf>
}
 880:	60e2                	ld	ra,24(sp)
 882:	6442                	ld	s0,16(sp)
 884:	6161                	addi	sp,sp,80
 886:	8082                	ret

0000000000000888 <printf>:

void
printf(const char *fmt, ...)
{
 888:	711d                	addi	sp,sp,-96
 88a:	ec06                	sd	ra,24(sp)
 88c:	e822                	sd	s0,16(sp)
 88e:	1000                	addi	s0,sp,32
 890:	e40c                	sd	a1,8(s0)
 892:	e810                	sd	a2,16(s0)
 894:	ec14                	sd	a3,24(s0)
 896:	f018                	sd	a4,32(s0)
 898:	f41c                	sd	a5,40(s0)
 89a:	03043823          	sd	a6,48(s0)
 89e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8a2:	00840613          	addi	a2,s0,8
 8a6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8aa:	85aa                	mv	a1,a0
 8ac:	4505                	li	a0,1
 8ae:	cf1ff0ef          	jal	59e <vprintf>
}
 8b2:	60e2                	ld	ra,24(sp)
 8b4:	6442                	ld	s0,16(sp)
 8b6:	6125                	addi	sp,sp,96
 8b8:	8082                	ret

00000000000008ba <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8ba:	1141                	addi	sp,sp,-16
 8bc:	e406                	sd	ra,8(sp)
 8be:	e022                	sd	s0,0(sp)
 8c0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8c2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c6:	00000797          	auipc	a5,0x0
 8ca:	73a7b783          	ld	a5,1850(a5) # 1000 <freep>
 8ce:	a039                	j	8dc <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d0:	6398                	ld	a4,0(a5)
 8d2:	00e7e463          	bltu	a5,a4,8da <free+0x20>
 8d6:	00e6ea63          	bltu	a3,a4,8ea <free+0x30>
{
 8da:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8dc:	fed7fae3          	bgeu	a5,a3,8d0 <free+0x16>
 8e0:	6398                	ld	a4,0(a5)
 8e2:	00e6e463          	bltu	a3,a4,8ea <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8e6:	fee7eae3          	bltu	a5,a4,8da <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8ea:	ff852583          	lw	a1,-8(a0)
 8ee:	6390                	ld	a2,0(a5)
 8f0:	02059813          	slli	a6,a1,0x20
 8f4:	01c85713          	srli	a4,a6,0x1c
 8f8:	9736                	add	a4,a4,a3
 8fa:	02e60563          	beq	a2,a4,924 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 8fe:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 902:	4790                	lw	a2,8(a5)
 904:	02061593          	slli	a1,a2,0x20
 908:	01c5d713          	srli	a4,a1,0x1c
 90c:	973e                	add	a4,a4,a5
 90e:	02e68263          	beq	a3,a4,932 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 912:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 914:	00000717          	auipc	a4,0x0
 918:	6ef73623          	sd	a5,1772(a4) # 1000 <freep>
}
 91c:	60a2                	ld	ra,8(sp)
 91e:	6402                	ld	s0,0(sp)
 920:	0141                	addi	sp,sp,16
 922:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 924:	4618                	lw	a4,8(a2)
 926:	9f2d                	addw	a4,a4,a1
 928:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 92c:	6398                	ld	a4,0(a5)
 92e:	6310                	ld	a2,0(a4)
 930:	b7f9                	j	8fe <free+0x44>
    p->s.size += bp->s.size;
 932:	ff852703          	lw	a4,-8(a0)
 936:	9f31                	addw	a4,a4,a2
 938:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 93a:	ff053683          	ld	a3,-16(a0)
 93e:	bfd1                	j	912 <free+0x58>

0000000000000940 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 940:	7139                	addi	sp,sp,-64
 942:	fc06                	sd	ra,56(sp)
 944:	f822                	sd	s0,48(sp)
 946:	f04a                	sd	s2,32(sp)
 948:	ec4e                	sd	s3,24(sp)
 94a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 94c:	02051993          	slli	s3,a0,0x20
 950:	0209d993          	srli	s3,s3,0x20
 954:	09bd                	addi	s3,s3,15
 956:	0049d993          	srli	s3,s3,0x4
 95a:	2985                	addiw	s3,s3,1
 95c:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 95e:	00000517          	auipc	a0,0x0
 962:	6a253503          	ld	a0,1698(a0) # 1000 <freep>
 966:	c905                	beqz	a0,996 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 968:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 96a:	4798                	lw	a4,8(a5)
 96c:	09377663          	bgeu	a4,s3,9f8 <malloc+0xb8>
 970:	f426                	sd	s1,40(sp)
 972:	e852                	sd	s4,16(sp)
 974:	e456                	sd	s5,8(sp)
 976:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 978:	8a4e                	mv	s4,s3
 97a:	6705                	lui	a4,0x1
 97c:	00e9f363          	bgeu	s3,a4,982 <malloc+0x42>
 980:	6a05                	lui	s4,0x1
 982:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 986:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 98a:	00000497          	auipc	s1,0x0
 98e:	67648493          	addi	s1,s1,1654 # 1000 <freep>
  if(p == SBRK_ERROR)
 992:	5afd                	li	s5,-1
 994:	a83d                	j	9d2 <malloc+0x92>
 996:	f426                	sd	s1,40(sp)
 998:	e852                	sd	s4,16(sp)
 99a:	e456                	sd	s5,8(sp)
 99c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 99e:	00001797          	auipc	a5,0x1
 9a2:	87278793          	addi	a5,a5,-1934 # 1210 <base>
 9a6:	00000717          	auipc	a4,0x0
 9aa:	64f73d23          	sd	a5,1626(a4) # 1000 <freep>
 9ae:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9b0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9b4:	b7d1                	j	978 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 9b6:	6398                	ld	a4,0(a5)
 9b8:	e118                	sd	a4,0(a0)
 9ba:	a899                	j	a10 <malloc+0xd0>
  hp->s.size = nu;
 9bc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9c0:	0541                	addi	a0,a0,16
 9c2:	ef9ff0ef          	jal	8ba <free>
  return freep;
 9c6:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 9c8:	c125                	beqz	a0,a28 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ca:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9cc:	4798                	lw	a4,8(a5)
 9ce:	03277163          	bgeu	a4,s2,9f0 <malloc+0xb0>
    if(p == freep)
 9d2:	6098                	ld	a4,0(s1)
 9d4:	853e                	mv	a0,a5
 9d6:	fef71ae3          	bne	a4,a5,9ca <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 9da:	8552                	mv	a0,s4
 9dc:	99dff0ef          	jal	378 <sbrk>
  if(p == SBRK_ERROR)
 9e0:	fd551ee3          	bne	a0,s5,9bc <malloc+0x7c>
        return 0;
 9e4:	4501                	li	a0,0
 9e6:	74a2                	ld	s1,40(sp)
 9e8:	6a42                	ld	s4,16(sp)
 9ea:	6aa2                	ld	s5,8(sp)
 9ec:	6b02                	ld	s6,0(sp)
 9ee:	a03d                	j	a1c <malloc+0xdc>
 9f0:	74a2                	ld	s1,40(sp)
 9f2:	6a42                	ld	s4,16(sp)
 9f4:	6aa2                	ld	s5,8(sp)
 9f6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9f8:	fae90fe3          	beq	s2,a4,9b6 <malloc+0x76>
        p->s.size -= nunits;
 9fc:	4137073b          	subw	a4,a4,s3
 a00:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a02:	02071693          	slli	a3,a4,0x20
 a06:	01c6d713          	srli	a4,a3,0x1c
 a0a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a0c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a10:	00000717          	auipc	a4,0x0
 a14:	5ea73823          	sd	a0,1520(a4) # 1000 <freep>
      return (void*)(p + 1);
 a18:	01078513          	addi	a0,a5,16
  }
}
 a1c:	70e2                	ld	ra,56(sp)
 a1e:	7442                	ld	s0,48(sp)
 a20:	7902                	ld	s2,32(sp)
 a22:	69e2                	ld	s3,24(sp)
 a24:	6121                	addi	sp,sp,64
 a26:	8082                	ret
 a28:	74a2                	ld	s1,40(sp)
 a2a:	6a42                	ld	s4,16(sp)
 a2c:	6aa2                	ld	s5,8(sp)
 a2e:	6b02                	ld	s6,0(sp)
 a30:	b7f5                	j	a1c <malloc+0xdc>
