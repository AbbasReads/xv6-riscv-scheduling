
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4901                	li	s2,0
  l = w = c = 0;
  28:	4c81                	li	s9,0
  2a:	4c01                	li	s8,0
  2c:	4b81                	li	s7,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  2e:	20000d93          	li	s11,512
  32:	00001d17          	auipc	s10,0x1
  36:	fded0d13          	addi	s10,s10,-34 # 1010 <buf>
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  3a:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  3c:	00001a17          	auipc	s4,0x1
  40:	a64a0a13          	addi	s4,s4,-1436 # aa0 <malloc+0xfa>
  while((n = read(fd, buf, sizeof(buf))) > 0){
  44:	a035                	j	70 <wc+0x70>
      if(strchr(" \r\t\n\v", buf[i]))
  46:	8552                	mv	a0,s4
  48:	1c6000ef          	jal	20e <strchr>
  4c:	c919                	beqz	a0,62 <wc+0x62>
        inword = 0;
  4e:	4901                	li	s2,0
    for(i=0; i<n; i++){
  50:	0485                	addi	s1,s1,1
  52:	01348d63          	beq	s1,s3,6c <wc+0x6c>
      if(buf[i] == '\n')
  56:	0004c583          	lbu	a1,0(s1)
  5a:	ff5596e3          	bne	a1,s5,46 <wc+0x46>
        l++;
  5e:	2b85                	addiw	s7,s7,1
  60:	b7dd                	j	46 <wc+0x46>
      else if(!inword){
  62:	fe0917e3          	bnez	s2,50 <wc+0x50>
        w++;
  66:	2c05                	addiw	s8,s8,1
        inword = 1;
  68:	4905                	li	s2,1
  6a:	b7dd                	j	50 <wc+0x50>
  6c:	019b0cbb          	addw	s9,s6,s9
  while((n = read(fd, buf, sizeof(buf))) > 0){
  70:	866e                	mv	a2,s11
  72:	85ea                	mv	a1,s10
  74:	f8843503          	ld	a0,-120(s0)
  78:	3b2000ef          	jal	42a <read>
  7c:	8b2a                	mv	s6,a0
  7e:	00a05963          	blez	a0,90 <wc+0x90>
  82:	00001497          	auipc	s1,0x1
  86:	f8e48493          	addi	s1,s1,-114 # 1010 <buf>
  8a:	009b09b3          	add	s3,s6,s1
  8e:	b7e1                	j	56 <wc+0x56>
      }
    }
  }
  if(n < 0){
  90:	02054c63          	bltz	a0,c8 <wc+0xc8>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %s\n", l, w, c, name);
  94:	f8043703          	ld	a4,-128(s0)
  98:	86e6                	mv	a3,s9
  9a:	8662                	mv	a2,s8
  9c:	85de                	mv	a1,s7
  9e:	00001517          	auipc	a0,0x1
  a2:	a2250513          	addi	a0,a0,-1502 # ac0 <malloc+0x11a>
  a6:	049000ef          	jal	8ee <printf>
}
  aa:	70e6                	ld	ra,120(sp)
  ac:	7446                	ld	s0,112(sp)
  ae:	74a6                	ld	s1,104(sp)
  b0:	7906                	ld	s2,96(sp)
  b2:	69e6                	ld	s3,88(sp)
  b4:	6a46                	ld	s4,80(sp)
  b6:	6aa6                	ld	s5,72(sp)
  b8:	6b06                	ld	s6,64(sp)
  ba:	7be2                	ld	s7,56(sp)
  bc:	7c42                	ld	s8,48(sp)
  be:	7ca2                	ld	s9,40(sp)
  c0:	7d02                	ld	s10,32(sp)
  c2:	6de2                	ld	s11,24(sp)
  c4:	6109                	addi	sp,sp,128
  c6:	8082                	ret
    printf("wc: read error\n");
  c8:	00001517          	auipc	a0,0x1
  cc:	9e850513          	addi	a0,a0,-1560 # ab0 <malloc+0x10a>
  d0:	01f000ef          	jal	8ee <printf>
    exit(1);
  d4:	4505                	li	a0,1
  d6:	33c000ef          	jal	412 <exit>

00000000000000da <main>:

int
main(int argc, char *argv[])
{
  da:	7179                	addi	sp,sp,-48
  dc:	f406                	sd	ra,40(sp)
  de:	f022                	sd	s0,32(sp)
  e0:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  e2:	4785                	li	a5,1
  e4:	04a7d463          	bge	a5,a0,12c <main+0x52>
  e8:	ec26                	sd	s1,24(sp)
  ea:	e84a                	sd	s2,16(sp)
  ec:	e44e                	sd	s3,8(sp)
  ee:	00858913          	addi	s2,a1,8
  f2:	ffe5099b          	addiw	s3,a0,-2
  f6:	02099793          	slli	a5,s3,0x20
  fa:	01d7d993          	srli	s3,a5,0x1d
  fe:	05c1                	addi	a1,a1,16
 100:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], O_RDONLY)) < 0){
 102:	4581                	li	a1,0
 104:	00093503          	ld	a0,0(s2)
 108:	3d6000ef          	jal	4de <open>
 10c:	84aa                	mv	s1,a0
 10e:	02054c63          	bltz	a0,146 <main+0x6c>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 112:	00093583          	ld	a1,0(s2)
 116:	eebff0ef          	jal	0 <wc>
    close(fd);
 11a:	8526                	mv	a0,s1
 11c:	31e000ef          	jal	43a <close>
  for(i = 1; i < argc; i++){
 120:	0921                	addi	s2,s2,8
 122:	ff3910e3          	bne	s2,s3,102 <main+0x28>
  }
  exit(0);
 126:	4501                	li	a0,0
 128:	2ea000ef          	jal	412 <exit>
 12c:	ec26                	sd	s1,24(sp)
 12e:	e84a                	sd	s2,16(sp)
 130:	e44e                	sd	s3,8(sp)
    wc(0, "");
 132:	00001597          	auipc	a1,0x1
 136:	97658593          	addi	a1,a1,-1674 # aa8 <malloc+0x102>
 13a:	4501                	li	a0,0
 13c:	ec5ff0ef          	jal	0 <wc>
    exit(0);
 140:	4501                	li	a0,0
 142:	2d0000ef          	jal	412 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 146:	00093583          	ld	a1,0(s2)
 14a:	00001517          	auipc	a0,0x1
 14e:	98650513          	addi	a0,a0,-1658 # ad0 <malloc+0x12a>
 152:	79c000ef          	jal	8ee <printf>
      exit(1);
 156:	4505                	li	a0,1
 158:	2ba000ef          	jal	412 <exit>

000000000000015c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 15c:	1141                	addi	sp,sp,-16
 15e:	e406                	sd	ra,8(sp)
 160:	e022                	sd	s0,0(sp)
 162:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 164:	f77ff0ef          	jal	da <main>
  exit(r);
 168:	2aa000ef          	jal	412 <exit>

000000000000016c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e406                	sd	ra,8(sp)
 170:	e022                	sd	s0,0(sp)
 172:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 174:	87aa                	mv	a5,a0
 176:	0585                	addi	a1,a1,1
 178:	0785                	addi	a5,a5,1
 17a:	fff5c703          	lbu	a4,-1(a1)
 17e:	fee78fa3          	sb	a4,-1(a5)
 182:	fb75                	bnez	a4,176 <strcpy+0xa>
    ;
  return os;
}
 184:	60a2                	ld	ra,8(sp)
 186:	6402                	ld	s0,0(sp)
 188:	0141                	addi	sp,sp,16
 18a:	8082                	ret

000000000000018c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 18c:	1141                	addi	sp,sp,-16
 18e:	e406                	sd	ra,8(sp)
 190:	e022                	sd	s0,0(sp)
 192:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 194:	00054783          	lbu	a5,0(a0)
 198:	cb91                	beqz	a5,1ac <strcmp+0x20>
 19a:	0005c703          	lbu	a4,0(a1)
 19e:	00f71763          	bne	a4,a5,1ac <strcmp+0x20>
    p++, q++;
 1a2:	0505                	addi	a0,a0,1
 1a4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1a6:	00054783          	lbu	a5,0(a0)
 1aa:	fbe5                	bnez	a5,19a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 1ac:	0005c503          	lbu	a0,0(a1)
}
 1b0:	40a7853b          	subw	a0,a5,a0
 1b4:	60a2                	ld	ra,8(sp)
 1b6:	6402                	ld	s0,0(sp)
 1b8:	0141                	addi	sp,sp,16
 1ba:	8082                	ret

00000000000001bc <strlen>:

uint
strlen(const char *s)
{
 1bc:	1141                	addi	sp,sp,-16
 1be:	e406                	sd	ra,8(sp)
 1c0:	e022                	sd	s0,0(sp)
 1c2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1c4:	00054783          	lbu	a5,0(a0)
 1c8:	cf91                	beqz	a5,1e4 <strlen+0x28>
 1ca:	00150793          	addi	a5,a0,1
 1ce:	86be                	mv	a3,a5
 1d0:	0785                	addi	a5,a5,1
 1d2:	fff7c703          	lbu	a4,-1(a5)
 1d6:	ff65                	bnez	a4,1ce <strlen+0x12>
 1d8:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 1dc:	60a2                	ld	ra,8(sp)
 1de:	6402                	ld	s0,0(sp)
 1e0:	0141                	addi	sp,sp,16
 1e2:	8082                	ret
  for(n = 0; s[n]; n++)
 1e4:	4501                	li	a0,0
 1e6:	bfdd                	j	1dc <strlen+0x20>

00000000000001e8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e8:	1141                	addi	sp,sp,-16
 1ea:	e406                	sd	ra,8(sp)
 1ec:	e022                	sd	s0,0(sp)
 1ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1f0:	ca19                	beqz	a2,206 <memset+0x1e>
 1f2:	87aa                	mv	a5,a0
 1f4:	1602                	slli	a2,a2,0x20
 1f6:	9201                	srli	a2,a2,0x20
 1f8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1fc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 200:	0785                	addi	a5,a5,1
 202:	fee79de3          	bne	a5,a4,1fc <memset+0x14>
  }
  return dst;
}
 206:	60a2                	ld	ra,8(sp)
 208:	6402                	ld	s0,0(sp)
 20a:	0141                	addi	sp,sp,16
 20c:	8082                	ret

000000000000020e <strchr>:

char*
strchr(const char *s, char c)
{
 20e:	1141                	addi	sp,sp,-16
 210:	e406                	sd	ra,8(sp)
 212:	e022                	sd	s0,0(sp)
 214:	0800                	addi	s0,sp,16
  for(; *s; s++)
 216:	00054783          	lbu	a5,0(a0)
 21a:	cf81                	beqz	a5,232 <strchr+0x24>
    if(*s == c)
 21c:	00f58763          	beq	a1,a5,22a <strchr+0x1c>
  for(; *s; s++)
 220:	0505                	addi	a0,a0,1
 222:	00054783          	lbu	a5,0(a0)
 226:	fbfd                	bnez	a5,21c <strchr+0xe>
      return (char*)s;
  return 0;
 228:	4501                	li	a0,0
}
 22a:	60a2                	ld	ra,8(sp)
 22c:	6402                	ld	s0,0(sp)
 22e:	0141                	addi	sp,sp,16
 230:	8082                	ret
  return 0;
 232:	4501                	li	a0,0
 234:	bfdd                	j	22a <strchr+0x1c>

0000000000000236 <gets>:

char*
gets(char *buf, int max)
{
 236:	711d                	addi	sp,sp,-96
 238:	ec86                	sd	ra,88(sp)
 23a:	e8a2                	sd	s0,80(sp)
 23c:	e4a6                	sd	s1,72(sp)
 23e:	e0ca                	sd	s2,64(sp)
 240:	fc4e                	sd	s3,56(sp)
 242:	f852                	sd	s4,48(sp)
 244:	f456                	sd	s5,40(sp)
 246:	f05a                	sd	s6,32(sp)
 248:	ec5e                	sd	s7,24(sp)
 24a:	e862                	sd	s8,16(sp)
 24c:	1080                	addi	s0,sp,96
 24e:	8baa                	mv	s7,a0
 250:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 252:	892a                	mv	s2,a0
 254:	4481                	li	s1,0
    cc = read(0, &c, 1);
 256:	faf40b13          	addi	s6,s0,-81
 25a:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 25c:	8c26                	mv	s8,s1
 25e:	0014899b          	addiw	s3,s1,1
 262:	84ce                	mv	s1,s3
 264:	0349d463          	bge	s3,s4,28c <gets+0x56>
    cc = read(0, &c, 1);
 268:	8656                	mv	a2,s5
 26a:	85da                	mv	a1,s6
 26c:	4501                	li	a0,0
 26e:	1bc000ef          	jal	42a <read>
    if(cc < 1)
 272:	00a05d63          	blez	a0,28c <gets+0x56>
      break;
    buf[i++] = c;
 276:	faf44783          	lbu	a5,-81(s0)
 27a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 27e:	0905                	addi	s2,s2,1
 280:	ff678713          	addi	a4,a5,-10
 284:	c319                	beqz	a4,28a <gets+0x54>
 286:	17cd                	addi	a5,a5,-13
 288:	fbf1                	bnez	a5,25c <gets+0x26>
    buf[i++] = c;
 28a:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 28c:	9c5e                	add	s8,s8,s7
 28e:	000c0023          	sb	zero,0(s8)
  return buf;
}
 292:	855e                	mv	a0,s7
 294:	60e6                	ld	ra,88(sp)
 296:	6446                	ld	s0,80(sp)
 298:	64a6                	ld	s1,72(sp)
 29a:	6906                	ld	s2,64(sp)
 29c:	79e2                	ld	s3,56(sp)
 29e:	7a42                	ld	s4,48(sp)
 2a0:	7aa2                	ld	s5,40(sp)
 2a2:	7b02                	ld	s6,32(sp)
 2a4:	6be2                	ld	s7,24(sp)
 2a6:	6c42                	ld	s8,16(sp)
 2a8:	6125                	addi	sp,sp,96
 2aa:	8082                	ret

00000000000002ac <stat>:

int
stat(const char *n, struct stat *st)
{
 2ac:	1101                	addi	sp,sp,-32
 2ae:	ec06                	sd	ra,24(sp)
 2b0:	e822                	sd	s0,16(sp)
 2b2:	e04a                	sd	s2,0(sp)
 2b4:	1000                	addi	s0,sp,32
 2b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b8:	4581                	li	a1,0
 2ba:	224000ef          	jal	4de <open>
  if(fd < 0)
 2be:	02054263          	bltz	a0,2e2 <stat+0x36>
 2c2:	e426                	sd	s1,8(sp)
 2c4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c6:	85ca                	mv	a1,s2
 2c8:	22e000ef          	jal	4f6 <fstat>
 2cc:	892a                	mv	s2,a0
  close(fd);
 2ce:	8526                	mv	a0,s1
 2d0:	16a000ef          	jal	43a <close>
  return r;
 2d4:	64a2                	ld	s1,8(sp)
}
 2d6:	854a                	mv	a0,s2
 2d8:	60e2                	ld	ra,24(sp)
 2da:	6442                	ld	s0,16(sp)
 2dc:	6902                	ld	s2,0(sp)
 2de:	6105                	addi	sp,sp,32
 2e0:	8082                	ret
    return -1;
 2e2:	57fd                	li	a5,-1
 2e4:	893e                	mv	s2,a5
 2e6:	bfc5                	j	2d6 <stat+0x2a>

00000000000002e8 <atoi>:

int
atoi(const char *s)
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e406                	sd	ra,8(sp)
 2ec:	e022                	sd	s0,0(sp)
 2ee:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2f0:	00054683          	lbu	a3,0(a0)
 2f4:	fd06879b          	addiw	a5,a3,-48
 2f8:	0ff7f793          	zext.b	a5,a5
 2fc:	4625                	li	a2,9
 2fe:	02f66963          	bltu	a2,a5,330 <atoi+0x48>
 302:	872a                	mv	a4,a0
  n = 0;
 304:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 306:	0705                	addi	a4,a4,1
 308:	0025179b          	slliw	a5,a0,0x2
 30c:	9fa9                	addw	a5,a5,a0
 30e:	0017979b          	slliw	a5,a5,0x1
 312:	9fb5                	addw	a5,a5,a3
 314:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 318:	00074683          	lbu	a3,0(a4)
 31c:	fd06879b          	addiw	a5,a3,-48
 320:	0ff7f793          	zext.b	a5,a5
 324:	fef671e3          	bgeu	a2,a5,306 <atoi+0x1e>
  return n;
}
 328:	60a2                	ld	ra,8(sp)
 32a:	6402                	ld	s0,0(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret
  n = 0;
 330:	4501                	li	a0,0
 332:	bfdd                	j	328 <atoi+0x40>

0000000000000334 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 334:	1141                	addi	sp,sp,-16
 336:	e406                	sd	ra,8(sp)
 338:	e022                	sd	s0,0(sp)
 33a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 33c:	02b57563          	bgeu	a0,a1,366 <memmove+0x32>
    while(n-- > 0)
 340:	00c05f63          	blez	a2,35e <memmove+0x2a>
 344:	1602                	slli	a2,a2,0x20
 346:	9201                	srli	a2,a2,0x20
 348:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 34c:	872a                	mv	a4,a0
      *dst++ = *src++;
 34e:	0585                	addi	a1,a1,1
 350:	0705                	addi	a4,a4,1
 352:	fff5c683          	lbu	a3,-1(a1)
 356:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 35a:	fee79ae3          	bne	a5,a4,34e <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 35e:	60a2                	ld	ra,8(sp)
 360:	6402                	ld	s0,0(sp)
 362:	0141                	addi	sp,sp,16
 364:	8082                	ret
    while(n-- > 0)
 366:	fec05ce3          	blez	a2,35e <memmove+0x2a>
    dst += n;
 36a:	00c50733          	add	a4,a0,a2
    src += n;
 36e:	95b2                	add	a1,a1,a2
 370:	fff6079b          	addiw	a5,a2,-1
 374:	1782                	slli	a5,a5,0x20
 376:	9381                	srli	a5,a5,0x20
 378:	fff7c793          	not	a5,a5
 37c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 37e:	15fd                	addi	a1,a1,-1
 380:	177d                	addi	a4,a4,-1
 382:	0005c683          	lbu	a3,0(a1)
 386:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 38a:	fef71ae3          	bne	a4,a5,37e <memmove+0x4a>
 38e:	bfc1                	j	35e <memmove+0x2a>

0000000000000390 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 390:	1141                	addi	sp,sp,-16
 392:	e406                	sd	ra,8(sp)
 394:	e022                	sd	s0,0(sp)
 396:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 398:	c61d                	beqz	a2,3c6 <memcmp+0x36>
 39a:	1602                	slli	a2,a2,0x20
 39c:	9201                	srli	a2,a2,0x20
 39e:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 3a2:	00054783          	lbu	a5,0(a0)
 3a6:	0005c703          	lbu	a4,0(a1)
 3aa:	00e79863          	bne	a5,a4,3ba <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 3ae:	0505                	addi	a0,a0,1
    p2++;
 3b0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3b2:	fed518e3          	bne	a0,a3,3a2 <memcmp+0x12>
  }
  return 0;
 3b6:	4501                	li	a0,0
 3b8:	a019                	j	3be <memcmp+0x2e>
      return *p1 - *p2;
 3ba:	40e7853b          	subw	a0,a5,a4
}
 3be:	60a2                	ld	ra,8(sp)
 3c0:	6402                	ld	s0,0(sp)
 3c2:	0141                	addi	sp,sp,16
 3c4:	8082                	ret
  return 0;
 3c6:	4501                	li	a0,0
 3c8:	bfdd                	j	3be <memcmp+0x2e>

00000000000003ca <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ca:	1141                	addi	sp,sp,-16
 3cc:	e406                	sd	ra,8(sp)
 3ce:	e022                	sd	s0,0(sp)
 3d0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3d2:	f63ff0ef          	jal	334 <memmove>
}
 3d6:	60a2                	ld	ra,8(sp)
 3d8:	6402                	ld	s0,0(sp)
 3da:	0141                	addi	sp,sp,16
 3dc:	8082                	ret

00000000000003de <sbrk>:

char *
sbrk(int n) {
 3de:	1141                	addi	sp,sp,-16
 3e0:	e406                	sd	ra,8(sp)
 3e2:	e022                	sd	s0,0(sp)
 3e4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3e6:	4585                	li	a1,1
 3e8:	13e000ef          	jal	526 <sys_sbrk>
}
 3ec:	60a2                	ld	ra,8(sp)
 3ee:	6402                	ld	s0,0(sp)
 3f0:	0141                	addi	sp,sp,16
 3f2:	8082                	ret

00000000000003f4 <sbrklazy>:

char *
sbrklazy(int n) {
 3f4:	1141                	addi	sp,sp,-16
 3f6:	e406                	sd	ra,8(sp)
 3f8:	e022                	sd	s0,0(sp)
 3fa:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3fc:	4589                	li	a1,2
 3fe:	128000ef          	jal	526 <sys_sbrk>
}
 402:	60a2                	ld	ra,8(sp)
 404:	6402                	ld	s0,0(sp)
 406:	0141                	addi	sp,sp,16
 408:	8082                	ret

000000000000040a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 40a:	4885                	li	a7,1
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <exit>:
.global exit
exit:
 li a7, SYS_exit
 412:	4889                	li	a7,2
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <wait>:
.global wait
wait:
 li a7, SYS_wait
 41a:	488d                	li	a7,3
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 422:	4891                	li	a7,4
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <read>:
.global read
read:
 li a7, SYS_read
 42a:	4895                	li	a7,5
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <write>:
.global write
write:
 li a7, SYS_write
 432:	48c1                	li	a7,16
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <close>:
.global close
close:
 li a7, SYS_close
 43a:	48d5                	li	a7,21
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 442:	48d9                	li	a7,22
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <shmat>:
.global shmat
shmat:
 li a7, SYS_shmat
 44a:	48dd                	li	a7,23
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 452:	48e1                	li	a7,24
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 45a:	48e5                	li	a7,25
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <lockinit>:
.global lockinit
lockinit:
 li a7, SYS_lockinit
 462:	48e9                	li	a7,26
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <lockacquire>:
.global lockacquire
lockacquire:
 li a7, SYS_lockacquire
 46a:	48ed                	li	a7,27
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <lockrelease>:
.global lockrelease
lockrelease:
 li a7, SYS_lockrelease
 472:	48f1                	li	a7,28
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <locktry>:
.global locktry
locktry:
 li a7, SYS_locktry
 47a:	48f5                	li	a7,29
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <lockcheck>:
.global lockcheck
lockcheck:
 li a7, SYS_lockcheck
 482:	48f9                	li	a7,30
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <sendmsg>:
.global sendmsg
sendmsg:
 li a7, SYS_sendmsg
 48a:	48fd                	li	a7,31
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <recvmsg>:
.global recvmsg
recvmsg:
 li a7, SYS_recvmsg
 492:	02000893          	li	a7,32
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <broadcast>:
.global broadcast
broadcast:
 li a7, SYS_broadcast
 49c:	02100893          	li	a7,33
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <getprocsinfo>:
.global getprocsinfo
getprocsinfo:
 li a7, SYS_getprocsinfo
 4a6:	02200893          	li	a7,34
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 4b0:	02300893          	li	a7,35
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <sleep2>:
.global sleep2
sleep2:
 li a7, SYS_sleep2
 4ba:	02400893          	li	a7,36
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <signal>:
.global signal
signal:
 li a7, SYS_signal
 4c4:	02500893          	li	a7,37
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <kill>:
.global kill
kill:
 li a7, SYS_kill
 4ce:	4899                	li	a7,6
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4d6:	489d                	li	a7,7
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <open>:
.global open
open:
 li a7, SYS_open
 4de:	48bd                	li	a7,15
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4e6:	48c5                	li	a7,17
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4ee:	48c9                	li	a7,18
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4f6:	48a1                	li	a7,8
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <link>:
.global link
link:
 li a7, SYS_link
 4fe:	48cd                	li	a7,19
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 506:	48d1                	li	a7,20
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 50e:	48a5                	li	a7,9
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <dup>:
.global dup
dup:
 li a7, SYS_dup
 516:	48a9                	li	a7,10
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 51e:	48ad                	li	a7,11
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 526:	48b1                	li	a7,12
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <pause>:
.global pause
pause:
 li a7, SYS_pause
 52e:	48b5                	li	a7,13
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 536:	48b9                	li	a7,14
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <setchildlimit>:
.global setchildlimit
setchildlimit:
 li a7, SYS_setchildlimit
 53e:	02600893          	li	a7,38
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 548:	1101                	addi	sp,sp,-32
 54a:	ec06                	sd	ra,24(sp)
 54c:	e822                	sd	s0,16(sp)
 54e:	1000                	addi	s0,sp,32
 550:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 554:	4605                	li	a2,1
 556:	fef40593          	addi	a1,s0,-17
 55a:	ed9ff0ef          	jal	432 <write>
}
 55e:	60e2                	ld	ra,24(sp)
 560:	6442                	ld	s0,16(sp)
 562:	6105                	addi	sp,sp,32
 564:	8082                	ret

0000000000000566 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 566:	715d                	addi	sp,sp,-80
 568:	e486                	sd	ra,72(sp)
 56a:	e0a2                	sd	s0,64(sp)
 56c:	f84a                	sd	s2,48(sp)
 56e:	f44e                	sd	s3,40(sp)
 570:	0880                	addi	s0,sp,80
 572:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 574:	c6d1                	beqz	a3,600 <printint+0x9a>
 576:	0805d563          	bgez	a1,600 <printint+0x9a>
    neg = 1;
    x = -xx;
 57a:	40b005b3          	neg	a1,a1
    neg = 1;
 57e:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 580:	fb840993          	addi	s3,s0,-72
  neg = 0;
 584:	86ce                	mv	a3,s3
  i = 0;
 586:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 588:	00000817          	auipc	a6,0x0
 58c:	56880813          	addi	a6,a6,1384 # af0 <digits>
 590:	88ba                	mv	a7,a4
 592:	0017051b          	addiw	a0,a4,1
 596:	872a                	mv	a4,a0
 598:	02c5f7b3          	remu	a5,a1,a2
 59c:	97c2                	add	a5,a5,a6
 59e:	0007c783          	lbu	a5,0(a5)
 5a2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5a6:	87ae                	mv	a5,a1
 5a8:	02c5d5b3          	divu	a1,a1,a2
 5ac:	0685                	addi	a3,a3,1
 5ae:	fec7f1e3          	bgeu	a5,a2,590 <printint+0x2a>
  if(neg)
 5b2:	00030c63          	beqz	t1,5ca <printint+0x64>
    buf[i++] = '-';
 5b6:	fd050793          	addi	a5,a0,-48
 5ba:	00878533          	add	a0,a5,s0
 5be:	02d00793          	li	a5,45
 5c2:	fef50423          	sb	a5,-24(a0)
 5c6:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 5ca:	02e05563          	blez	a4,5f4 <printint+0x8e>
 5ce:	fc26                	sd	s1,56(sp)
 5d0:	377d                	addiw	a4,a4,-1
 5d2:	00e984b3          	add	s1,s3,a4
 5d6:	19fd                	addi	s3,s3,-1
 5d8:	99ba                	add	s3,s3,a4
 5da:	1702                	slli	a4,a4,0x20
 5dc:	9301                	srli	a4,a4,0x20
 5de:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5e2:	0004c583          	lbu	a1,0(s1)
 5e6:	854a                	mv	a0,s2
 5e8:	f61ff0ef          	jal	548 <putc>
  while(--i >= 0)
 5ec:	14fd                	addi	s1,s1,-1
 5ee:	ff349ae3          	bne	s1,s3,5e2 <printint+0x7c>
 5f2:	74e2                	ld	s1,56(sp)
}
 5f4:	60a6                	ld	ra,72(sp)
 5f6:	6406                	ld	s0,64(sp)
 5f8:	7942                	ld	s2,48(sp)
 5fa:	79a2                	ld	s3,40(sp)
 5fc:	6161                	addi	sp,sp,80
 5fe:	8082                	ret
  neg = 0;
 600:	4301                	li	t1,0
 602:	bfbd                	j	580 <printint+0x1a>

0000000000000604 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 604:	711d                	addi	sp,sp,-96
 606:	ec86                	sd	ra,88(sp)
 608:	e8a2                	sd	s0,80(sp)
 60a:	e4a6                	sd	s1,72(sp)
 60c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 60e:	0005c483          	lbu	s1,0(a1)
 612:	22048363          	beqz	s1,838 <vprintf+0x234>
 616:	e0ca                	sd	s2,64(sp)
 618:	fc4e                	sd	s3,56(sp)
 61a:	f852                	sd	s4,48(sp)
 61c:	f456                	sd	s5,40(sp)
 61e:	f05a                	sd	s6,32(sp)
 620:	ec5e                	sd	s7,24(sp)
 622:	e862                	sd	s8,16(sp)
 624:	8b2a                	mv	s6,a0
 626:	8a2e                	mv	s4,a1
 628:	8bb2                	mv	s7,a2
  state = 0;
 62a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 62c:	4901                	li	s2,0
 62e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 630:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 634:	06400c13          	li	s8,100
 638:	a00d                	j	65a <vprintf+0x56>
        putc(fd, c0);
 63a:	85a6                	mv	a1,s1
 63c:	855a                	mv	a0,s6
 63e:	f0bff0ef          	jal	548 <putc>
 642:	a019                	j	648 <vprintf+0x44>
    } else if(state == '%'){
 644:	03598363          	beq	s3,s5,66a <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 648:	0019079b          	addiw	a5,s2,1
 64c:	893e                	mv	s2,a5
 64e:	873e                	mv	a4,a5
 650:	97d2                	add	a5,a5,s4
 652:	0007c483          	lbu	s1,0(a5)
 656:	1c048a63          	beqz	s1,82a <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 65a:	0004879b          	sext.w	a5,s1
    if(state == 0){
 65e:	fe0993e3          	bnez	s3,644 <vprintf+0x40>
      if(c0 == '%'){
 662:	fd579ce3          	bne	a5,s5,63a <vprintf+0x36>
        state = '%';
 666:	89be                	mv	s3,a5
 668:	b7c5                	j	648 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 66a:	00ea06b3          	add	a3,s4,a4
 66e:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 672:	1c060863          	beqz	a2,842 <vprintf+0x23e>
      if(c0 == 'd'){
 676:	03878763          	beq	a5,s8,6a4 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 67a:	f9478693          	addi	a3,a5,-108
 67e:	0016b693          	seqz	a3,a3
 682:	f9c60593          	addi	a1,a2,-100
 686:	e99d                	bnez	a1,6bc <vprintf+0xb8>
 688:	ca95                	beqz	a3,6bc <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 68a:	008b8493          	addi	s1,s7,8
 68e:	4685                	li	a3,1
 690:	4629                	li	a2,10
 692:	000bb583          	ld	a1,0(s7)
 696:	855a                	mv	a0,s6
 698:	ecfff0ef          	jal	566 <printint>
        i += 1;
 69c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 69e:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	b75d                	j	648 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 6a4:	008b8493          	addi	s1,s7,8
 6a8:	4685                	li	a3,1
 6aa:	4629                	li	a2,10
 6ac:	000ba583          	lw	a1,0(s7)
 6b0:	855a                	mv	a0,s6
 6b2:	eb5ff0ef          	jal	566 <printint>
 6b6:	8ba6                	mv	s7,s1
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	b779                	j	648 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 6bc:	9752                	add	a4,a4,s4
 6be:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6c2:	f9460713          	addi	a4,a2,-108
 6c6:	00173713          	seqz	a4,a4
 6ca:	8f75                	and	a4,a4,a3
 6cc:	f9c58513          	addi	a0,a1,-100
 6d0:	18051363          	bnez	a0,856 <vprintf+0x252>
 6d4:	18070163          	beqz	a4,856 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d8:	008b8493          	addi	s1,s7,8
 6dc:	4685                	li	a3,1
 6de:	4629                	li	a2,10
 6e0:	000bb583          	ld	a1,0(s7)
 6e4:	855a                	mv	a0,s6
 6e6:	e81ff0ef          	jal	566 <printint>
        i += 2;
 6ea:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ec:	8ba6                	mv	s7,s1
      state = 0;
 6ee:	4981                	li	s3,0
        i += 2;
 6f0:	bfa1                	j	648 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6f2:	008b8493          	addi	s1,s7,8
 6f6:	4681                	li	a3,0
 6f8:	4629                	li	a2,10
 6fa:	000be583          	lwu	a1,0(s7)
 6fe:	855a                	mv	a0,s6
 700:	e67ff0ef          	jal	566 <printint>
 704:	8ba6                	mv	s7,s1
      state = 0;
 706:	4981                	li	s3,0
 708:	b781                	j	648 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 70a:	008b8493          	addi	s1,s7,8
 70e:	4681                	li	a3,0
 710:	4629                	li	a2,10
 712:	000bb583          	ld	a1,0(s7)
 716:	855a                	mv	a0,s6
 718:	e4fff0ef          	jal	566 <printint>
        i += 1;
 71c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 71e:	8ba6                	mv	s7,s1
      state = 0;
 720:	4981                	li	s3,0
 722:	b71d                	j	648 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 724:	008b8493          	addi	s1,s7,8
 728:	4681                	li	a3,0
 72a:	4629                	li	a2,10
 72c:	000bb583          	ld	a1,0(s7)
 730:	855a                	mv	a0,s6
 732:	e35ff0ef          	jal	566 <printint>
        i += 2;
 736:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 738:	8ba6                	mv	s7,s1
      state = 0;
 73a:	4981                	li	s3,0
        i += 2;
 73c:	b731                	j	648 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 73e:	008b8493          	addi	s1,s7,8
 742:	4681                	li	a3,0
 744:	4641                	li	a2,16
 746:	000be583          	lwu	a1,0(s7)
 74a:	855a                	mv	a0,s6
 74c:	e1bff0ef          	jal	566 <printint>
 750:	8ba6                	mv	s7,s1
      state = 0;
 752:	4981                	li	s3,0
 754:	bdd5                	j	648 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 756:	008b8493          	addi	s1,s7,8
 75a:	4681                	li	a3,0
 75c:	4641                	li	a2,16
 75e:	000bb583          	ld	a1,0(s7)
 762:	855a                	mv	a0,s6
 764:	e03ff0ef          	jal	566 <printint>
        i += 1;
 768:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 76a:	8ba6                	mv	s7,s1
      state = 0;
 76c:	4981                	li	s3,0
 76e:	bde9                	j	648 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 770:	008b8493          	addi	s1,s7,8
 774:	4681                	li	a3,0
 776:	4641                	li	a2,16
 778:	000bb583          	ld	a1,0(s7)
 77c:	855a                	mv	a0,s6
 77e:	de9ff0ef          	jal	566 <printint>
        i += 2;
 782:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 784:	8ba6                	mv	s7,s1
      state = 0;
 786:	4981                	li	s3,0
        i += 2;
 788:	b5c1                	j	648 <vprintf+0x44>
 78a:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 78c:	008b8793          	addi	a5,s7,8
 790:	8cbe                	mv	s9,a5
 792:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 796:	03000593          	li	a1,48
 79a:	855a                	mv	a0,s6
 79c:	dadff0ef          	jal	548 <putc>
  putc(fd, 'x');
 7a0:	07800593          	li	a1,120
 7a4:	855a                	mv	a0,s6
 7a6:	da3ff0ef          	jal	548 <putc>
 7aa:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7ac:	00000b97          	auipc	s7,0x0
 7b0:	344b8b93          	addi	s7,s7,836 # af0 <digits>
 7b4:	03c9d793          	srli	a5,s3,0x3c
 7b8:	97de                	add	a5,a5,s7
 7ba:	0007c583          	lbu	a1,0(a5)
 7be:	855a                	mv	a0,s6
 7c0:	d89ff0ef          	jal	548 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7c4:	0992                	slli	s3,s3,0x4
 7c6:	34fd                	addiw	s1,s1,-1
 7c8:	f4f5                	bnez	s1,7b4 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 7ca:	8be6                	mv	s7,s9
      state = 0;
 7cc:	4981                	li	s3,0
 7ce:	6ca2                	ld	s9,8(sp)
 7d0:	bda5                	j	648 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 7d2:	008b8493          	addi	s1,s7,8
 7d6:	000bc583          	lbu	a1,0(s7)
 7da:	855a                	mv	a0,s6
 7dc:	d6dff0ef          	jal	548 <putc>
 7e0:	8ba6                	mv	s7,s1
      state = 0;
 7e2:	4981                	li	s3,0
 7e4:	b595                	j	648 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 7e6:	008b8993          	addi	s3,s7,8
 7ea:	000bb483          	ld	s1,0(s7)
 7ee:	cc91                	beqz	s1,80a <vprintf+0x206>
        for(; *s; s++)
 7f0:	0004c583          	lbu	a1,0(s1)
 7f4:	c985                	beqz	a1,824 <vprintf+0x220>
          putc(fd, *s);
 7f6:	855a                	mv	a0,s6
 7f8:	d51ff0ef          	jal	548 <putc>
        for(; *s; s++)
 7fc:	0485                	addi	s1,s1,1
 7fe:	0004c583          	lbu	a1,0(s1)
 802:	f9f5                	bnez	a1,7f6 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 804:	8bce                	mv	s7,s3
      state = 0;
 806:	4981                	li	s3,0
 808:	b581                	j	648 <vprintf+0x44>
          s = "(null)";
 80a:	00000497          	auipc	s1,0x0
 80e:	2de48493          	addi	s1,s1,734 # ae8 <malloc+0x142>
        for(; *s; s++)
 812:	02800593          	li	a1,40
 816:	b7c5                	j	7f6 <vprintf+0x1f2>
        putc(fd, '%');
 818:	85be                	mv	a1,a5
 81a:	855a                	mv	a0,s6
 81c:	d2dff0ef          	jal	548 <putc>
      state = 0;
 820:	4981                	li	s3,0
 822:	b51d                	j	648 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 824:	8bce                	mv	s7,s3
      state = 0;
 826:	4981                	li	s3,0
 828:	b505                	j	648 <vprintf+0x44>
 82a:	6906                	ld	s2,64(sp)
 82c:	79e2                	ld	s3,56(sp)
 82e:	7a42                	ld	s4,48(sp)
 830:	7aa2                	ld	s5,40(sp)
 832:	7b02                	ld	s6,32(sp)
 834:	6be2                	ld	s7,24(sp)
 836:	6c42                	ld	s8,16(sp)
    }
  }
}
 838:	60e6                	ld	ra,88(sp)
 83a:	6446                	ld	s0,80(sp)
 83c:	64a6                	ld	s1,72(sp)
 83e:	6125                	addi	sp,sp,96
 840:	8082                	ret
      if(c0 == 'd'){
 842:	06400713          	li	a4,100
 846:	e4e78fe3          	beq	a5,a4,6a4 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 84a:	f9478693          	addi	a3,a5,-108
 84e:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 852:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 854:	4701                	li	a4,0
      } else if(c0 == 'u'){
 856:	07500513          	li	a0,117
 85a:	e8a78ce3          	beq	a5,a0,6f2 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 85e:	f8b60513          	addi	a0,a2,-117
 862:	e119                	bnez	a0,868 <vprintf+0x264>
 864:	ea0693e3          	bnez	a3,70a <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 868:	f8b58513          	addi	a0,a1,-117
 86c:	e119                	bnez	a0,872 <vprintf+0x26e>
 86e:	ea071be3          	bnez	a4,724 <vprintf+0x120>
      } else if(c0 == 'x'){
 872:	07800513          	li	a0,120
 876:	eca784e3          	beq	a5,a0,73e <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 87a:	f8860613          	addi	a2,a2,-120
 87e:	e219                	bnez	a2,884 <vprintf+0x280>
 880:	ec069be3          	bnez	a3,756 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 884:	f8858593          	addi	a1,a1,-120
 888:	e199                	bnez	a1,88e <vprintf+0x28a>
 88a:	ee0713e3          	bnez	a4,770 <vprintf+0x16c>
      } else if(c0 == 'p'){
 88e:	07000713          	li	a4,112
 892:	eee78ce3          	beq	a5,a4,78a <vprintf+0x186>
      } else if(c0 == 'c'){
 896:	06300713          	li	a4,99
 89a:	f2e78ce3          	beq	a5,a4,7d2 <vprintf+0x1ce>
      } else if(c0 == 's'){
 89e:	07300713          	li	a4,115
 8a2:	f4e782e3          	beq	a5,a4,7e6 <vprintf+0x1e2>
      } else if(c0 == '%'){
 8a6:	02500713          	li	a4,37
 8aa:	f6e787e3          	beq	a5,a4,818 <vprintf+0x214>
        putc(fd, '%');
 8ae:	02500593          	li	a1,37
 8b2:	855a                	mv	a0,s6
 8b4:	c95ff0ef          	jal	548 <putc>
        putc(fd, c0);
 8b8:	85a6                	mv	a1,s1
 8ba:	855a                	mv	a0,s6
 8bc:	c8dff0ef          	jal	548 <putc>
      state = 0;
 8c0:	4981                	li	s3,0
 8c2:	b359                	j	648 <vprintf+0x44>

00000000000008c4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8c4:	715d                	addi	sp,sp,-80
 8c6:	ec06                	sd	ra,24(sp)
 8c8:	e822                	sd	s0,16(sp)
 8ca:	1000                	addi	s0,sp,32
 8cc:	e010                	sd	a2,0(s0)
 8ce:	e414                	sd	a3,8(s0)
 8d0:	e818                	sd	a4,16(s0)
 8d2:	ec1c                	sd	a5,24(s0)
 8d4:	03043023          	sd	a6,32(s0)
 8d8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8dc:	8622                	mv	a2,s0
 8de:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8e2:	d23ff0ef          	jal	604 <vprintf>
}
 8e6:	60e2                	ld	ra,24(sp)
 8e8:	6442                	ld	s0,16(sp)
 8ea:	6161                	addi	sp,sp,80
 8ec:	8082                	ret

00000000000008ee <printf>:

void
printf(const char *fmt, ...)
{
 8ee:	711d                	addi	sp,sp,-96
 8f0:	ec06                	sd	ra,24(sp)
 8f2:	e822                	sd	s0,16(sp)
 8f4:	1000                	addi	s0,sp,32
 8f6:	e40c                	sd	a1,8(s0)
 8f8:	e810                	sd	a2,16(s0)
 8fa:	ec14                	sd	a3,24(s0)
 8fc:	f018                	sd	a4,32(s0)
 8fe:	f41c                	sd	a5,40(s0)
 900:	03043823          	sd	a6,48(s0)
 904:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 908:	00840613          	addi	a2,s0,8
 90c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 910:	85aa                	mv	a1,a0
 912:	4505                	li	a0,1
 914:	cf1ff0ef          	jal	604 <vprintf>
}
 918:	60e2                	ld	ra,24(sp)
 91a:	6442                	ld	s0,16(sp)
 91c:	6125                	addi	sp,sp,96
 91e:	8082                	ret

0000000000000920 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 920:	1141                	addi	sp,sp,-16
 922:	e406                	sd	ra,8(sp)
 924:	e022                	sd	s0,0(sp)
 926:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 928:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 92c:	00000797          	auipc	a5,0x0
 930:	6d47b783          	ld	a5,1748(a5) # 1000 <freep>
 934:	a039                	j	942 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 936:	6398                	ld	a4,0(a5)
 938:	00e7e463          	bltu	a5,a4,940 <free+0x20>
 93c:	00e6ea63          	bltu	a3,a4,950 <free+0x30>
{
 940:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 942:	fed7fae3          	bgeu	a5,a3,936 <free+0x16>
 946:	6398                	ld	a4,0(a5)
 948:	00e6e463          	bltu	a3,a4,950 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 94c:	fee7eae3          	bltu	a5,a4,940 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 950:	ff852583          	lw	a1,-8(a0)
 954:	6390                	ld	a2,0(a5)
 956:	02059813          	slli	a6,a1,0x20
 95a:	01c85713          	srli	a4,a6,0x1c
 95e:	9736                	add	a4,a4,a3
 960:	02e60563          	beq	a2,a4,98a <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 964:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 968:	4790                	lw	a2,8(a5)
 96a:	02061593          	slli	a1,a2,0x20
 96e:	01c5d713          	srli	a4,a1,0x1c
 972:	973e                	add	a4,a4,a5
 974:	02e68263          	beq	a3,a4,998 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 978:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 97a:	00000717          	auipc	a4,0x0
 97e:	68f73323          	sd	a5,1670(a4) # 1000 <freep>
}
 982:	60a2                	ld	ra,8(sp)
 984:	6402                	ld	s0,0(sp)
 986:	0141                	addi	sp,sp,16
 988:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 98a:	4618                	lw	a4,8(a2)
 98c:	9f2d                	addw	a4,a4,a1
 98e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 992:	6398                	ld	a4,0(a5)
 994:	6310                	ld	a2,0(a4)
 996:	b7f9                	j	964 <free+0x44>
    p->s.size += bp->s.size;
 998:	ff852703          	lw	a4,-8(a0)
 99c:	9f31                	addw	a4,a4,a2
 99e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9a0:	ff053683          	ld	a3,-16(a0)
 9a4:	bfd1                	j	978 <free+0x58>

00000000000009a6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9a6:	7139                	addi	sp,sp,-64
 9a8:	fc06                	sd	ra,56(sp)
 9aa:	f822                	sd	s0,48(sp)
 9ac:	f04a                	sd	s2,32(sp)
 9ae:	ec4e                	sd	s3,24(sp)
 9b0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9b2:	02051993          	slli	s3,a0,0x20
 9b6:	0209d993          	srli	s3,s3,0x20
 9ba:	09bd                	addi	s3,s3,15
 9bc:	0049d993          	srli	s3,s3,0x4
 9c0:	2985                	addiw	s3,s3,1
 9c2:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 9c4:	00000517          	auipc	a0,0x0
 9c8:	63c53503          	ld	a0,1596(a0) # 1000 <freep>
 9cc:	c905                	beqz	a0,9fc <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ce:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9d0:	4798                	lw	a4,8(a5)
 9d2:	09377663          	bgeu	a4,s3,a5e <malloc+0xb8>
 9d6:	f426                	sd	s1,40(sp)
 9d8:	e852                	sd	s4,16(sp)
 9da:	e456                	sd	s5,8(sp)
 9dc:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9de:	8a4e                	mv	s4,s3
 9e0:	6705                	lui	a4,0x1
 9e2:	00e9f363          	bgeu	s3,a4,9e8 <malloc+0x42>
 9e6:	6a05                	lui	s4,0x1
 9e8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9ec:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9f0:	00000497          	auipc	s1,0x0
 9f4:	61048493          	addi	s1,s1,1552 # 1000 <freep>
  if(p == SBRK_ERROR)
 9f8:	5afd                	li	s5,-1
 9fa:	a83d                	j	a38 <malloc+0x92>
 9fc:	f426                	sd	s1,40(sp)
 9fe:	e852                	sd	s4,16(sp)
 a00:	e456                	sd	s5,8(sp)
 a02:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a04:	00001797          	auipc	a5,0x1
 a08:	80c78793          	addi	a5,a5,-2036 # 1210 <base>
 a0c:	00000717          	auipc	a4,0x0
 a10:	5ef73a23          	sd	a5,1524(a4) # 1000 <freep>
 a14:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a16:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a1a:	b7d1                	j	9de <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a1c:	6398                	ld	a4,0(a5)
 a1e:	e118                	sd	a4,0(a0)
 a20:	a899                	j	a76 <malloc+0xd0>
  hp->s.size = nu;
 a22:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a26:	0541                	addi	a0,a0,16
 a28:	ef9ff0ef          	jal	920 <free>
  return freep;
 a2c:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 a2e:	c125                	beqz	a0,a8e <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a30:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a32:	4798                	lw	a4,8(a5)
 a34:	03277163          	bgeu	a4,s2,a56 <malloc+0xb0>
    if(p == freep)
 a38:	6098                	ld	a4,0(s1)
 a3a:	853e                	mv	a0,a5
 a3c:	fef71ae3          	bne	a4,a5,a30 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 a40:	8552                	mv	a0,s4
 a42:	99dff0ef          	jal	3de <sbrk>
  if(p == SBRK_ERROR)
 a46:	fd551ee3          	bne	a0,s5,a22 <malloc+0x7c>
        return 0;
 a4a:	4501                	li	a0,0
 a4c:	74a2                	ld	s1,40(sp)
 a4e:	6a42                	ld	s4,16(sp)
 a50:	6aa2                	ld	s5,8(sp)
 a52:	6b02                	ld	s6,0(sp)
 a54:	a03d                	j	a82 <malloc+0xdc>
 a56:	74a2                	ld	s1,40(sp)
 a58:	6a42                	ld	s4,16(sp)
 a5a:	6aa2                	ld	s5,8(sp)
 a5c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a5e:	fae90fe3          	beq	s2,a4,a1c <malloc+0x76>
        p->s.size -= nunits;
 a62:	4137073b          	subw	a4,a4,s3
 a66:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a68:	02071693          	slli	a3,a4,0x20
 a6c:	01c6d713          	srli	a4,a3,0x1c
 a70:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a72:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a76:	00000717          	auipc	a4,0x0
 a7a:	58a73523          	sd	a0,1418(a4) # 1000 <freep>
      return (void*)(p + 1);
 a7e:	01078513          	addi	a0,a5,16
  }
}
 a82:	70e2                	ld	ra,56(sp)
 a84:	7442                	ld	s0,48(sp)
 a86:	7902                	ld	s2,32(sp)
 a88:	69e2                	ld	s3,24(sp)
 a8a:	6121                	addi	sp,sp,64
 a8c:	8082                	ret
 a8e:	74a2                	ld	s1,40(sp)
 a90:	6a42                	ld	s4,16(sp)
 a92:	6aa2                	ld	s5,8(sp)
 a94:	6b02                	ld	s6,0(sp)
 a96:	b7f5                	j	a82 <malloc+0xdc>
