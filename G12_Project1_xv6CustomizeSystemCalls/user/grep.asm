
user/_grep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	fd250a13          	addi	s4,a0,-46
  1a:	001a3a13          	seqz	s4,s4
    if(matchhere(re, text))
  1e:	85a6                	mv	a1,s1
  20:	854e                	mv	a0,s3
  22:	02a000ef          	jal	4c <matchhere>
  26:	e911                	bnez	a0,3a <matchstar+0x3a>
  }while(*text!='\0' && (*text++==c || c=='.'));
  28:	0004c783          	lbu	a5,0(s1)
  2c:	cb81                	beqz	a5,3c <matchstar+0x3c>
  2e:	0485                	addi	s1,s1,1
  30:	ff2787e3          	beq	a5,s2,1e <matchstar+0x1e>
  34:	fe0a15e3          	bnez	s4,1e <matchstar+0x1e>
  38:	a011                	j	3c <matchstar+0x3c>
      return 1;
  3a:	4505                	li	a0,1
  return 0;
}
  3c:	70a2                	ld	ra,40(sp)
  3e:	7402                	ld	s0,32(sp)
  40:	64e2                	ld	s1,24(sp)
  42:	6942                	ld	s2,16(sp)
  44:	69a2                	ld	s3,8(sp)
  46:	6a02                	ld	s4,0(sp)
  48:	6145                	addi	sp,sp,48
  4a:	8082                	ret

000000000000004c <matchhere>:
  if(re[0] == '\0')
  4c:	00054703          	lbu	a4,0(a0)
  50:	cf39                	beqz	a4,ae <matchhere+0x62>
{
  52:	1141                	addi	sp,sp,-16
  54:	e406                	sd	ra,8(sp)
  56:	e022                	sd	s0,0(sp)
  58:	0800                	addi	s0,sp,16
  5a:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5c:	00154683          	lbu	a3,1(a0)
  60:	02a00613          	li	a2,42
  64:	02c68363          	beq	a3,a2,8a <matchhere+0x3e>
  if(re[0] == '$' && re[1] == '\0')
  68:	e681                	bnez	a3,70 <matchhere+0x24>
  6a:	fdc70693          	addi	a3,a4,-36
  6e:	c68d                	beqz	a3,98 <matchhere+0x4c>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  70:	0005c683          	lbu	a3,0(a1)
  return 0;
  74:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  76:	c691                	beqz	a3,82 <matchhere+0x36>
  78:	02d70563          	beq	a4,a3,a2 <matchhere+0x56>
  7c:	fd270713          	addi	a4,a4,-46
  80:	c30d                	beqz	a4,a2 <matchhere+0x56>
}
  82:	60a2                	ld	ra,8(sp)
  84:	6402                	ld	s0,0(sp)
  86:	0141                	addi	sp,sp,16
  88:	8082                	ret
    return matchstar(re[0], re+2, text);
  8a:	862e                	mv	a2,a1
  8c:	00250593          	addi	a1,a0,2
  90:	853a                	mv	a0,a4
  92:	f6fff0ef          	jal	0 <matchstar>
  96:	b7f5                	j	82 <matchhere+0x36>
    return *text == '\0';
  98:	0005c503          	lbu	a0,0(a1)
  9c:	00153513          	seqz	a0,a0
  a0:	b7cd                	j	82 <matchhere+0x36>
    return matchhere(re+1, text+1);
  a2:	0585                	addi	a1,a1,1
  a4:	00178513          	addi	a0,a5,1
  a8:	fa5ff0ef          	jal	4c <matchhere>
  ac:	bfd9                	j	82 <matchhere+0x36>
    return 1;
  ae:	4505                	li	a0,1
}
  b0:	8082                	ret

00000000000000b2 <match>:
{
  b2:	1101                	addi	sp,sp,-32
  b4:	ec06                	sd	ra,24(sp)
  b6:	e822                	sd	s0,16(sp)
  b8:	e426                	sd	s1,8(sp)
  ba:	e04a                	sd	s2,0(sp)
  bc:	1000                	addi	s0,sp,32
  be:	892a                	mv	s2,a0
  c0:	84ae                	mv	s1,a1
  if(re[0] == '^')
  c2:	00054703          	lbu	a4,0(a0)
  c6:	05e00793          	li	a5,94
  ca:	00f70c63          	beq	a4,a5,e2 <match+0x30>
    if(matchhere(re, text))
  ce:	85a6                	mv	a1,s1
  d0:	854a                	mv	a0,s2
  d2:	f7bff0ef          	jal	4c <matchhere>
  d6:	e911                	bnez	a0,ea <match+0x38>
  }while(*text++ != '\0');
  d8:	0485                	addi	s1,s1,1
  da:	fff4c783          	lbu	a5,-1(s1)
  de:	fbe5                	bnez	a5,ce <match+0x1c>
  e0:	a031                	j	ec <match+0x3a>
    return matchhere(re+1, text);
  e2:	0505                	addi	a0,a0,1
  e4:	f69ff0ef          	jal	4c <matchhere>
  e8:	a011                	j	ec <match+0x3a>
      return 1;
  ea:	4505                	li	a0,1
}
  ec:	60e2                	ld	ra,24(sp)
  ee:	6442                	ld	s0,16(sp)
  f0:	64a2                	ld	s1,8(sp)
  f2:	6902                	ld	s2,0(sp)
  f4:	6105                	addi	sp,sp,32
  f6:	8082                	ret

00000000000000f8 <grep>:
{
  f8:	711d                	addi	sp,sp,-96
  fa:	ec86                	sd	ra,88(sp)
  fc:	e8a2                	sd	s0,80(sp)
  fe:	e4a6                	sd	s1,72(sp)
 100:	e0ca                	sd	s2,64(sp)
 102:	fc4e                	sd	s3,56(sp)
 104:	f852                	sd	s4,48(sp)
 106:	f456                	sd	s5,40(sp)
 108:	f05a                	sd	s6,32(sp)
 10a:	ec5e                	sd	s7,24(sp)
 10c:	e862                	sd	s8,16(sp)
 10e:	e466                	sd	s9,8(sp)
 110:	e06a                	sd	s10,0(sp)
 112:	1080                	addi	s0,sp,96
 114:	8aaa                	mv	s5,a0
 116:	8cae                	mv	s9,a1
  m = 0;
 118:	4b01                	li	s6,0
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 11a:	3ff00d13          	li	s10,1023
 11e:	00002b97          	auipc	s7,0x2
 122:	ef2b8b93          	addi	s7,s7,-270 # 2010 <buf>
    while((q = strchr(p, '\n')) != 0){
 126:	49a9                	li	s3,10
        write(1, p, q+1 - p);
 128:	4c05                	li	s8,1
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 12a:	a82d                	j	164 <grep+0x6c>
      p = q+1;
 12c:	00148913          	addi	s2,s1,1
    while((q = strchr(p, '\n')) != 0){
 130:	85ce                	mv	a1,s3
 132:	854a                	mv	a0,s2
 134:	1da000ef          	jal	30e <strchr>
 138:	84aa                	mv	s1,a0
 13a:	c11d                	beqz	a0,160 <grep+0x68>
      *q = 0;
 13c:	00048023          	sb	zero,0(s1)
      if(match(pattern, p)){
 140:	85ca                	mv	a1,s2
 142:	8556                	mv	a0,s5
 144:	f6fff0ef          	jal	b2 <match>
 148:	d175                	beqz	a0,12c <grep+0x34>
        *q = '\n';
 14a:	01348023          	sb	s3,0(s1)
        write(1, p, q+1 - p);
 14e:	00148613          	addi	a2,s1,1
 152:	4126063b          	subw	a2,a2,s2
 156:	85ca                	mv	a1,s2
 158:	8562                	mv	a0,s8
 15a:	3d8000ef          	jal	532 <write>
 15e:	b7f9                	j	12c <grep+0x34>
    if(m > 0){
 160:	03604463          	bgtz	s6,188 <grep+0x90>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 164:	416d063b          	subw	a2,s10,s6
 168:	016b85b3          	add	a1,s7,s6
 16c:	8566                	mv	a0,s9
 16e:	3bc000ef          	jal	52a <read>
 172:	02a05c63          	blez	a0,1aa <grep+0xb2>
    m += n;
 176:	00ab0a3b          	addw	s4,s6,a0
 17a:	8b52                	mv	s6,s4
    buf[m] = '\0';
 17c:	014b87b3          	add	a5,s7,s4
 180:	00078023          	sb	zero,0(a5)
    p = buf;
 184:	895e                	mv	s2,s7
    while((q = strchr(p, '\n')) != 0){
 186:	b76d                	j	130 <grep+0x38>
      m -= p - buf;
 188:	00002797          	auipc	a5,0x2
 18c:	e8878793          	addi	a5,a5,-376 # 2010 <buf>
 190:	40f907b3          	sub	a5,s2,a5
 194:	40fa063b          	subw	a2,s4,a5
 198:	8b32                	mv	s6,a2
      memmove(buf, p, m);
 19a:	85ca                	mv	a1,s2
 19c:	00002517          	auipc	a0,0x2
 1a0:	e7450513          	addi	a0,a0,-396 # 2010 <buf>
 1a4:	290000ef          	jal	434 <memmove>
 1a8:	bf75                	j	164 <grep+0x6c>
}
 1aa:	60e6                	ld	ra,88(sp)
 1ac:	6446                	ld	s0,80(sp)
 1ae:	64a6                	ld	s1,72(sp)
 1b0:	6906                	ld	s2,64(sp)
 1b2:	79e2                	ld	s3,56(sp)
 1b4:	7a42                	ld	s4,48(sp)
 1b6:	7aa2                	ld	s5,40(sp)
 1b8:	7b02                	ld	s6,32(sp)
 1ba:	6be2                	ld	s7,24(sp)
 1bc:	6c42                	ld	s8,16(sp)
 1be:	6ca2                	ld	s9,8(sp)
 1c0:	6d02                	ld	s10,0(sp)
 1c2:	6125                	addi	sp,sp,96
 1c4:	8082                	ret

00000000000001c6 <main>:
{
 1c6:	7179                	addi	sp,sp,-48
 1c8:	f406                	sd	ra,40(sp)
 1ca:	f022                	sd	s0,32(sp)
 1cc:	ec26                	sd	s1,24(sp)
 1ce:	e84a                	sd	s2,16(sp)
 1d0:	e44e                	sd	s3,8(sp)
 1d2:	e052                	sd	s4,0(sp)
 1d4:	1800                	addi	s0,sp,48
  if(argc <= 1){
 1d6:	4785                	li	a5,1
 1d8:	04a7d663          	bge	a5,a0,224 <main+0x5e>
  pattern = argv[1];
 1dc:	0085ba03          	ld	s4,8(a1)
  if(argc <= 2){
 1e0:	4789                	li	a5,2
 1e2:	04a7db63          	bge	a5,a0,238 <main+0x72>
 1e6:	01058913          	addi	s2,a1,16
 1ea:	ffd5099b          	addiw	s3,a0,-3
 1ee:	02099793          	slli	a5,s3,0x20
 1f2:	01d7d993          	srli	s3,a5,0x1d
 1f6:	05e1                	addi	a1,a1,24
 1f8:	99ae                	add	s3,s3,a1
    if((fd = open(argv[i], O_RDONLY)) < 0){
 1fa:	4581                	li	a1,0
 1fc:	00093503          	ld	a0,0(s2)
 200:	3de000ef          	jal	5de <open>
 204:	84aa                	mv	s1,a0
 206:	04054063          	bltz	a0,246 <main+0x80>
    grep(pattern, fd);
 20a:	85aa                	mv	a1,a0
 20c:	8552                	mv	a0,s4
 20e:	eebff0ef          	jal	f8 <grep>
    close(fd);
 212:	8526                	mv	a0,s1
 214:	326000ef          	jal	53a <close>
  for(i = 2; i < argc; i++){
 218:	0921                	addi	s2,s2,8
 21a:	ff3910e3          	bne	s2,s3,1fa <main+0x34>
  exit(0);
 21e:	4501                	li	a0,0
 220:	2f2000ef          	jal	512 <exit>
    fprintf(2, "usage: grep pattern [file ...]\n");
 224:	00001597          	auipc	a1,0x1
 228:	97c58593          	addi	a1,a1,-1668 # ba0 <malloc+0xfa>
 22c:	4509                	li	a0,2
 22e:	796000ef          	jal	9c4 <fprintf>
    exit(1);
 232:	4505                	li	a0,1
 234:	2de000ef          	jal	512 <exit>
    grep(pattern, 0);
 238:	4581                	li	a1,0
 23a:	8552                	mv	a0,s4
 23c:	ebdff0ef          	jal	f8 <grep>
    exit(0);
 240:	4501                	li	a0,0
 242:	2d0000ef          	jal	512 <exit>
      printf("grep: cannot open %s\n", argv[i]);
 246:	00093583          	ld	a1,0(s2)
 24a:	00001517          	auipc	a0,0x1
 24e:	97650513          	addi	a0,a0,-1674 # bc0 <malloc+0x11a>
 252:	79c000ef          	jal	9ee <printf>
      exit(1);
 256:	4505                	li	a0,1
 258:	2ba000ef          	jal	512 <exit>

000000000000025c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 25c:	1141                	addi	sp,sp,-16
 25e:	e406                	sd	ra,8(sp)
 260:	e022                	sd	s0,0(sp)
 262:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 264:	f63ff0ef          	jal	1c6 <main>
  exit(r);
 268:	2aa000ef          	jal	512 <exit>

000000000000026c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e406                	sd	ra,8(sp)
 270:	e022                	sd	s0,0(sp)
 272:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 274:	87aa                	mv	a5,a0
 276:	0585                	addi	a1,a1,1
 278:	0785                	addi	a5,a5,1
 27a:	fff5c703          	lbu	a4,-1(a1)
 27e:	fee78fa3          	sb	a4,-1(a5)
 282:	fb75                	bnez	a4,276 <strcpy+0xa>
    ;
  return os;
}
 284:	60a2                	ld	ra,8(sp)
 286:	6402                	ld	s0,0(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret

000000000000028c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e406                	sd	ra,8(sp)
 290:	e022                	sd	s0,0(sp)
 292:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 294:	00054783          	lbu	a5,0(a0)
 298:	cb91                	beqz	a5,2ac <strcmp+0x20>
 29a:	0005c703          	lbu	a4,0(a1)
 29e:	00f71763          	bne	a4,a5,2ac <strcmp+0x20>
    p++, q++;
 2a2:	0505                	addi	a0,a0,1
 2a4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2a6:	00054783          	lbu	a5,0(a0)
 2aa:	fbe5                	bnez	a5,29a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 2ac:	0005c503          	lbu	a0,0(a1)
}
 2b0:	40a7853b          	subw	a0,a5,a0
 2b4:	60a2                	ld	ra,8(sp)
 2b6:	6402                	ld	s0,0(sp)
 2b8:	0141                	addi	sp,sp,16
 2ba:	8082                	ret

00000000000002bc <strlen>:

uint
strlen(const char *s)
{
 2bc:	1141                	addi	sp,sp,-16
 2be:	e406                	sd	ra,8(sp)
 2c0:	e022                	sd	s0,0(sp)
 2c2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2c4:	00054783          	lbu	a5,0(a0)
 2c8:	cf91                	beqz	a5,2e4 <strlen+0x28>
 2ca:	00150793          	addi	a5,a0,1
 2ce:	86be                	mv	a3,a5
 2d0:	0785                	addi	a5,a5,1
 2d2:	fff7c703          	lbu	a4,-1(a5)
 2d6:	ff65                	bnez	a4,2ce <strlen+0x12>
 2d8:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 2dc:	60a2                	ld	ra,8(sp)
 2de:	6402                	ld	s0,0(sp)
 2e0:	0141                	addi	sp,sp,16
 2e2:	8082                	ret
  for(n = 0; s[n]; n++)
 2e4:	4501                	li	a0,0
 2e6:	bfdd                	j	2dc <strlen+0x20>

00000000000002e8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e406                	sd	ra,8(sp)
 2ec:	e022                	sd	s0,0(sp)
 2ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2f0:	ca19                	beqz	a2,306 <memset+0x1e>
 2f2:	87aa                	mv	a5,a0
 2f4:	1602                	slli	a2,a2,0x20
 2f6:	9201                	srli	a2,a2,0x20
 2f8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2fc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 300:	0785                	addi	a5,a5,1
 302:	fee79de3          	bne	a5,a4,2fc <memset+0x14>
  }
  return dst;
}
 306:	60a2                	ld	ra,8(sp)
 308:	6402                	ld	s0,0(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret

000000000000030e <strchr>:

char*
strchr(const char *s, char c)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e406                	sd	ra,8(sp)
 312:	e022                	sd	s0,0(sp)
 314:	0800                	addi	s0,sp,16
  for(; *s; s++)
 316:	00054783          	lbu	a5,0(a0)
 31a:	cf81                	beqz	a5,332 <strchr+0x24>
    if(*s == c)
 31c:	00f58763          	beq	a1,a5,32a <strchr+0x1c>
  for(; *s; s++)
 320:	0505                	addi	a0,a0,1
 322:	00054783          	lbu	a5,0(a0)
 326:	fbfd                	bnez	a5,31c <strchr+0xe>
      return (char*)s;
  return 0;
 328:	4501                	li	a0,0
}
 32a:	60a2                	ld	ra,8(sp)
 32c:	6402                	ld	s0,0(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret
  return 0;
 332:	4501                	li	a0,0
 334:	bfdd                	j	32a <strchr+0x1c>

0000000000000336 <gets>:

char*
gets(char *buf, int max)
{
 336:	711d                	addi	sp,sp,-96
 338:	ec86                	sd	ra,88(sp)
 33a:	e8a2                	sd	s0,80(sp)
 33c:	e4a6                	sd	s1,72(sp)
 33e:	e0ca                	sd	s2,64(sp)
 340:	fc4e                	sd	s3,56(sp)
 342:	f852                	sd	s4,48(sp)
 344:	f456                	sd	s5,40(sp)
 346:	f05a                	sd	s6,32(sp)
 348:	ec5e                	sd	s7,24(sp)
 34a:	e862                	sd	s8,16(sp)
 34c:	1080                	addi	s0,sp,96
 34e:	8baa                	mv	s7,a0
 350:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 352:	892a                	mv	s2,a0
 354:	4481                	li	s1,0
    cc = read(0, &c, 1);
 356:	faf40b13          	addi	s6,s0,-81
 35a:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 35c:	8c26                	mv	s8,s1
 35e:	0014899b          	addiw	s3,s1,1
 362:	84ce                	mv	s1,s3
 364:	0349d463          	bge	s3,s4,38c <gets+0x56>
    cc = read(0, &c, 1);
 368:	8656                	mv	a2,s5
 36a:	85da                	mv	a1,s6
 36c:	4501                	li	a0,0
 36e:	1bc000ef          	jal	52a <read>
    if(cc < 1)
 372:	00a05d63          	blez	a0,38c <gets+0x56>
      break;
    buf[i++] = c;
 376:	faf44783          	lbu	a5,-81(s0)
 37a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 37e:	0905                	addi	s2,s2,1
 380:	ff678713          	addi	a4,a5,-10
 384:	c319                	beqz	a4,38a <gets+0x54>
 386:	17cd                	addi	a5,a5,-13
 388:	fbf1                	bnez	a5,35c <gets+0x26>
    buf[i++] = c;
 38a:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 38c:	9c5e                	add	s8,s8,s7
 38e:	000c0023          	sb	zero,0(s8)
  return buf;
}
 392:	855e                	mv	a0,s7
 394:	60e6                	ld	ra,88(sp)
 396:	6446                	ld	s0,80(sp)
 398:	64a6                	ld	s1,72(sp)
 39a:	6906                	ld	s2,64(sp)
 39c:	79e2                	ld	s3,56(sp)
 39e:	7a42                	ld	s4,48(sp)
 3a0:	7aa2                	ld	s5,40(sp)
 3a2:	7b02                	ld	s6,32(sp)
 3a4:	6be2                	ld	s7,24(sp)
 3a6:	6c42                	ld	s8,16(sp)
 3a8:	6125                	addi	sp,sp,96
 3aa:	8082                	ret

00000000000003ac <stat>:

int
stat(const char *n, struct stat *st)
{
 3ac:	1101                	addi	sp,sp,-32
 3ae:	ec06                	sd	ra,24(sp)
 3b0:	e822                	sd	s0,16(sp)
 3b2:	e04a                	sd	s2,0(sp)
 3b4:	1000                	addi	s0,sp,32
 3b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3b8:	4581                	li	a1,0
 3ba:	224000ef          	jal	5de <open>
  if(fd < 0)
 3be:	02054263          	bltz	a0,3e2 <stat+0x36>
 3c2:	e426                	sd	s1,8(sp)
 3c4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3c6:	85ca                	mv	a1,s2
 3c8:	22e000ef          	jal	5f6 <fstat>
 3cc:	892a                	mv	s2,a0
  close(fd);
 3ce:	8526                	mv	a0,s1
 3d0:	16a000ef          	jal	53a <close>
  return r;
 3d4:	64a2                	ld	s1,8(sp)
}
 3d6:	854a                	mv	a0,s2
 3d8:	60e2                	ld	ra,24(sp)
 3da:	6442                	ld	s0,16(sp)
 3dc:	6902                	ld	s2,0(sp)
 3de:	6105                	addi	sp,sp,32
 3e0:	8082                	ret
    return -1;
 3e2:	57fd                	li	a5,-1
 3e4:	893e                	mv	s2,a5
 3e6:	bfc5                	j	3d6 <stat+0x2a>

00000000000003e8 <atoi>:

int
atoi(const char *s)
{
 3e8:	1141                	addi	sp,sp,-16
 3ea:	e406                	sd	ra,8(sp)
 3ec:	e022                	sd	s0,0(sp)
 3ee:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3f0:	00054683          	lbu	a3,0(a0)
 3f4:	fd06879b          	addiw	a5,a3,-48
 3f8:	0ff7f793          	zext.b	a5,a5
 3fc:	4625                	li	a2,9
 3fe:	02f66963          	bltu	a2,a5,430 <atoi+0x48>
 402:	872a                	mv	a4,a0
  n = 0;
 404:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 406:	0705                	addi	a4,a4,1
 408:	0025179b          	slliw	a5,a0,0x2
 40c:	9fa9                	addw	a5,a5,a0
 40e:	0017979b          	slliw	a5,a5,0x1
 412:	9fb5                	addw	a5,a5,a3
 414:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 418:	00074683          	lbu	a3,0(a4)
 41c:	fd06879b          	addiw	a5,a3,-48
 420:	0ff7f793          	zext.b	a5,a5
 424:	fef671e3          	bgeu	a2,a5,406 <atoi+0x1e>
  return n;
}
 428:	60a2                	ld	ra,8(sp)
 42a:	6402                	ld	s0,0(sp)
 42c:	0141                	addi	sp,sp,16
 42e:	8082                	ret
  n = 0;
 430:	4501                	li	a0,0
 432:	bfdd                	j	428 <atoi+0x40>

0000000000000434 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 434:	1141                	addi	sp,sp,-16
 436:	e406                	sd	ra,8(sp)
 438:	e022                	sd	s0,0(sp)
 43a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 43c:	02b57563          	bgeu	a0,a1,466 <memmove+0x32>
    while(n-- > 0)
 440:	00c05f63          	blez	a2,45e <memmove+0x2a>
 444:	1602                	slli	a2,a2,0x20
 446:	9201                	srli	a2,a2,0x20
 448:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 44c:	872a                	mv	a4,a0
      *dst++ = *src++;
 44e:	0585                	addi	a1,a1,1
 450:	0705                	addi	a4,a4,1
 452:	fff5c683          	lbu	a3,-1(a1)
 456:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 45a:	fee79ae3          	bne	a5,a4,44e <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 45e:	60a2                	ld	ra,8(sp)
 460:	6402                	ld	s0,0(sp)
 462:	0141                	addi	sp,sp,16
 464:	8082                	ret
    while(n-- > 0)
 466:	fec05ce3          	blez	a2,45e <memmove+0x2a>
    dst += n;
 46a:	00c50733          	add	a4,a0,a2
    src += n;
 46e:	95b2                	add	a1,a1,a2
 470:	fff6079b          	addiw	a5,a2,-1
 474:	1782                	slli	a5,a5,0x20
 476:	9381                	srli	a5,a5,0x20
 478:	fff7c793          	not	a5,a5
 47c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 47e:	15fd                	addi	a1,a1,-1
 480:	177d                	addi	a4,a4,-1
 482:	0005c683          	lbu	a3,0(a1)
 486:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 48a:	fef71ae3          	bne	a4,a5,47e <memmove+0x4a>
 48e:	bfc1                	j	45e <memmove+0x2a>

0000000000000490 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 490:	1141                	addi	sp,sp,-16
 492:	e406                	sd	ra,8(sp)
 494:	e022                	sd	s0,0(sp)
 496:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 498:	c61d                	beqz	a2,4c6 <memcmp+0x36>
 49a:	1602                	slli	a2,a2,0x20
 49c:	9201                	srli	a2,a2,0x20
 49e:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 4a2:	00054783          	lbu	a5,0(a0)
 4a6:	0005c703          	lbu	a4,0(a1)
 4aa:	00e79863          	bne	a5,a4,4ba <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 4ae:	0505                	addi	a0,a0,1
    p2++;
 4b0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4b2:	fed518e3          	bne	a0,a3,4a2 <memcmp+0x12>
  }
  return 0;
 4b6:	4501                	li	a0,0
 4b8:	a019                	j	4be <memcmp+0x2e>
      return *p1 - *p2;
 4ba:	40e7853b          	subw	a0,a5,a4
}
 4be:	60a2                	ld	ra,8(sp)
 4c0:	6402                	ld	s0,0(sp)
 4c2:	0141                	addi	sp,sp,16
 4c4:	8082                	ret
  return 0;
 4c6:	4501                	li	a0,0
 4c8:	bfdd                	j	4be <memcmp+0x2e>

00000000000004ca <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4ca:	1141                	addi	sp,sp,-16
 4cc:	e406                	sd	ra,8(sp)
 4ce:	e022                	sd	s0,0(sp)
 4d0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4d2:	f63ff0ef          	jal	434 <memmove>
}
 4d6:	60a2                	ld	ra,8(sp)
 4d8:	6402                	ld	s0,0(sp)
 4da:	0141                	addi	sp,sp,16
 4dc:	8082                	ret

00000000000004de <sbrk>:

char *
sbrk(int n) {
 4de:	1141                	addi	sp,sp,-16
 4e0:	e406                	sd	ra,8(sp)
 4e2:	e022                	sd	s0,0(sp)
 4e4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4e6:	4585                	li	a1,1
 4e8:	13e000ef          	jal	626 <sys_sbrk>
}
 4ec:	60a2                	ld	ra,8(sp)
 4ee:	6402                	ld	s0,0(sp)
 4f0:	0141                	addi	sp,sp,16
 4f2:	8082                	ret

00000000000004f4 <sbrklazy>:

char *
sbrklazy(int n) {
 4f4:	1141                	addi	sp,sp,-16
 4f6:	e406                	sd	ra,8(sp)
 4f8:	e022                	sd	s0,0(sp)
 4fa:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4fc:	4589                	li	a1,2
 4fe:	128000ef          	jal	626 <sys_sbrk>
}
 502:	60a2                	ld	ra,8(sp)
 504:	6402                	ld	s0,0(sp)
 506:	0141                	addi	sp,sp,16
 508:	8082                	ret

000000000000050a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 50a:	4885                	li	a7,1
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <exit>:
.global exit
exit:
 li a7, SYS_exit
 512:	4889                	li	a7,2
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <wait>:
.global wait
wait:
 li a7, SYS_wait
 51a:	488d                	li	a7,3
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 522:	4891                	li	a7,4
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <read>:
.global read
read:
 li a7, SYS_read
 52a:	4895                	li	a7,5
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <write>:
.global write
write:
 li a7, SYS_write
 532:	48c1                	li	a7,16
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <close>:
.global close
close:
 li a7, SYS_close
 53a:	48d5                	li	a7,21
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 542:	48d9                	li	a7,22
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <shmat>:
.global shmat
shmat:
 li a7, SYS_shmat
 54a:	48dd                	li	a7,23
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 552:	48e1                	li	a7,24
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 55a:	48e5                	li	a7,25
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <lockinit>:
.global lockinit
lockinit:
 li a7, SYS_lockinit
 562:	48e9                	li	a7,26
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <lockacquire>:
.global lockacquire
lockacquire:
 li a7, SYS_lockacquire
 56a:	48ed                	li	a7,27
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <lockrelease>:
.global lockrelease
lockrelease:
 li a7, SYS_lockrelease
 572:	48f1                	li	a7,28
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <locktry>:
.global locktry
locktry:
 li a7, SYS_locktry
 57a:	48f5                	li	a7,29
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <lockcheck>:
.global lockcheck
lockcheck:
 li a7, SYS_lockcheck
 582:	48f9                	li	a7,30
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <sendmsg>:
.global sendmsg
sendmsg:
 li a7, SYS_sendmsg
 58a:	48fd                	li	a7,31
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <recvmsg>:
.global recvmsg
recvmsg:
 li a7, SYS_recvmsg
 592:	02000893          	li	a7,32
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <broadcast>:
.global broadcast
broadcast:
 li a7, SYS_broadcast
 59c:	02100893          	li	a7,33
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <getprocsinfo>:
.global getprocsinfo
getprocsinfo:
 li a7, SYS_getprocsinfo
 5a6:	02200893          	li	a7,34
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 5b0:	02300893          	li	a7,35
 ecall
 5b4:	00000073          	ecall
 ret
 5b8:	8082                	ret

00000000000005ba <sleep2>:
.global sleep2
sleep2:
 li a7, SYS_sleep2
 5ba:	02400893          	li	a7,36
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <signal>:
.global signal
signal:
 li a7, SYS_signal
 5c4:	02500893          	li	a7,37
 ecall
 5c8:	00000073          	ecall
 ret
 5cc:	8082                	ret

00000000000005ce <kill>:
.global kill
kill:
 li a7, SYS_kill
 5ce:	4899                	li	a7,6
 ecall
 5d0:	00000073          	ecall
 ret
 5d4:	8082                	ret

00000000000005d6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5d6:	489d                	li	a7,7
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <open>:
.global open
open:
 li a7, SYS_open
 5de:	48bd                	li	a7,15
 ecall
 5e0:	00000073          	ecall
 ret
 5e4:	8082                	ret

00000000000005e6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5e6:	48c5                	li	a7,17
 ecall
 5e8:	00000073          	ecall
 ret
 5ec:	8082                	ret

00000000000005ee <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5ee:	48c9                	li	a7,18
 ecall
 5f0:	00000073          	ecall
 ret
 5f4:	8082                	ret

00000000000005f6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5f6:	48a1                	li	a7,8
 ecall
 5f8:	00000073          	ecall
 ret
 5fc:	8082                	ret

00000000000005fe <link>:
.global link
link:
 li a7, SYS_link
 5fe:	48cd                	li	a7,19
 ecall
 600:	00000073          	ecall
 ret
 604:	8082                	ret

0000000000000606 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 606:	48d1                	li	a7,20
 ecall
 608:	00000073          	ecall
 ret
 60c:	8082                	ret

000000000000060e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 60e:	48a5                	li	a7,9
 ecall
 610:	00000073          	ecall
 ret
 614:	8082                	ret

0000000000000616 <dup>:
.global dup
dup:
 li a7, SYS_dup
 616:	48a9                	li	a7,10
 ecall
 618:	00000073          	ecall
 ret
 61c:	8082                	ret

000000000000061e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 61e:	48ad                	li	a7,11
 ecall
 620:	00000073          	ecall
 ret
 624:	8082                	ret

0000000000000626 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 626:	48b1                	li	a7,12
 ecall
 628:	00000073          	ecall
 ret
 62c:	8082                	ret

000000000000062e <pause>:
.global pause
pause:
 li a7, SYS_pause
 62e:	48b5                	li	a7,13
 ecall
 630:	00000073          	ecall
 ret
 634:	8082                	ret

0000000000000636 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 636:	48b9                	li	a7,14
 ecall
 638:	00000073          	ecall
 ret
 63c:	8082                	ret

000000000000063e <setchildlimit>:
.global setchildlimit
setchildlimit:
 li a7, SYS_setchildlimit
 63e:	02600893          	li	a7,38
 ecall
 642:	00000073          	ecall
 ret
 646:	8082                	ret

0000000000000648 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 648:	1101                	addi	sp,sp,-32
 64a:	ec06                	sd	ra,24(sp)
 64c:	e822                	sd	s0,16(sp)
 64e:	1000                	addi	s0,sp,32
 650:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 654:	4605                	li	a2,1
 656:	fef40593          	addi	a1,s0,-17
 65a:	ed9ff0ef          	jal	532 <write>
}
 65e:	60e2                	ld	ra,24(sp)
 660:	6442                	ld	s0,16(sp)
 662:	6105                	addi	sp,sp,32
 664:	8082                	ret

0000000000000666 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 666:	715d                	addi	sp,sp,-80
 668:	e486                	sd	ra,72(sp)
 66a:	e0a2                	sd	s0,64(sp)
 66c:	f84a                	sd	s2,48(sp)
 66e:	f44e                	sd	s3,40(sp)
 670:	0880                	addi	s0,sp,80
 672:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 674:	c6d1                	beqz	a3,700 <printint+0x9a>
 676:	0805d563          	bgez	a1,700 <printint+0x9a>
    neg = 1;
    x = -xx;
 67a:	40b005b3          	neg	a1,a1
    neg = 1;
 67e:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 680:	fb840993          	addi	s3,s0,-72
  neg = 0;
 684:	86ce                	mv	a3,s3
  i = 0;
 686:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 688:	00000817          	auipc	a6,0x0
 68c:	55880813          	addi	a6,a6,1368 # be0 <digits>
 690:	88ba                	mv	a7,a4
 692:	0017051b          	addiw	a0,a4,1
 696:	872a                	mv	a4,a0
 698:	02c5f7b3          	remu	a5,a1,a2
 69c:	97c2                	add	a5,a5,a6
 69e:	0007c783          	lbu	a5,0(a5)
 6a2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6a6:	87ae                	mv	a5,a1
 6a8:	02c5d5b3          	divu	a1,a1,a2
 6ac:	0685                	addi	a3,a3,1
 6ae:	fec7f1e3          	bgeu	a5,a2,690 <printint+0x2a>
  if(neg)
 6b2:	00030c63          	beqz	t1,6ca <printint+0x64>
    buf[i++] = '-';
 6b6:	fd050793          	addi	a5,a0,-48
 6ba:	00878533          	add	a0,a5,s0
 6be:	02d00793          	li	a5,45
 6c2:	fef50423          	sb	a5,-24(a0)
 6c6:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 6ca:	02e05563          	blez	a4,6f4 <printint+0x8e>
 6ce:	fc26                	sd	s1,56(sp)
 6d0:	377d                	addiw	a4,a4,-1
 6d2:	00e984b3          	add	s1,s3,a4
 6d6:	19fd                	addi	s3,s3,-1
 6d8:	99ba                	add	s3,s3,a4
 6da:	1702                	slli	a4,a4,0x20
 6dc:	9301                	srli	a4,a4,0x20
 6de:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6e2:	0004c583          	lbu	a1,0(s1)
 6e6:	854a                	mv	a0,s2
 6e8:	f61ff0ef          	jal	648 <putc>
  while(--i >= 0)
 6ec:	14fd                	addi	s1,s1,-1
 6ee:	ff349ae3          	bne	s1,s3,6e2 <printint+0x7c>
 6f2:	74e2                	ld	s1,56(sp)
}
 6f4:	60a6                	ld	ra,72(sp)
 6f6:	6406                	ld	s0,64(sp)
 6f8:	7942                	ld	s2,48(sp)
 6fa:	79a2                	ld	s3,40(sp)
 6fc:	6161                	addi	sp,sp,80
 6fe:	8082                	ret
  neg = 0;
 700:	4301                	li	t1,0
 702:	bfbd                	j	680 <printint+0x1a>

0000000000000704 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 704:	711d                	addi	sp,sp,-96
 706:	ec86                	sd	ra,88(sp)
 708:	e8a2                	sd	s0,80(sp)
 70a:	e4a6                	sd	s1,72(sp)
 70c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 70e:	0005c483          	lbu	s1,0(a1)
 712:	22048363          	beqz	s1,938 <vprintf+0x234>
 716:	e0ca                	sd	s2,64(sp)
 718:	fc4e                	sd	s3,56(sp)
 71a:	f852                	sd	s4,48(sp)
 71c:	f456                	sd	s5,40(sp)
 71e:	f05a                	sd	s6,32(sp)
 720:	ec5e                	sd	s7,24(sp)
 722:	e862                	sd	s8,16(sp)
 724:	8b2a                	mv	s6,a0
 726:	8a2e                	mv	s4,a1
 728:	8bb2                	mv	s7,a2
  state = 0;
 72a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 72c:	4901                	li	s2,0
 72e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 730:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 734:	06400c13          	li	s8,100
 738:	a00d                	j	75a <vprintf+0x56>
        putc(fd, c0);
 73a:	85a6                	mv	a1,s1
 73c:	855a                	mv	a0,s6
 73e:	f0bff0ef          	jal	648 <putc>
 742:	a019                	j	748 <vprintf+0x44>
    } else if(state == '%'){
 744:	03598363          	beq	s3,s5,76a <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 748:	0019079b          	addiw	a5,s2,1
 74c:	893e                	mv	s2,a5
 74e:	873e                	mv	a4,a5
 750:	97d2                	add	a5,a5,s4
 752:	0007c483          	lbu	s1,0(a5)
 756:	1c048a63          	beqz	s1,92a <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 75a:	0004879b          	sext.w	a5,s1
    if(state == 0){
 75e:	fe0993e3          	bnez	s3,744 <vprintf+0x40>
      if(c0 == '%'){
 762:	fd579ce3          	bne	a5,s5,73a <vprintf+0x36>
        state = '%';
 766:	89be                	mv	s3,a5
 768:	b7c5                	j	748 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 76a:	00ea06b3          	add	a3,s4,a4
 76e:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 772:	1c060863          	beqz	a2,942 <vprintf+0x23e>
      if(c0 == 'd'){
 776:	03878763          	beq	a5,s8,7a4 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 77a:	f9478693          	addi	a3,a5,-108
 77e:	0016b693          	seqz	a3,a3
 782:	f9c60593          	addi	a1,a2,-100
 786:	e99d                	bnez	a1,7bc <vprintf+0xb8>
 788:	ca95                	beqz	a3,7bc <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 78a:	008b8493          	addi	s1,s7,8
 78e:	4685                	li	a3,1
 790:	4629                	li	a2,10
 792:	000bb583          	ld	a1,0(s7)
 796:	855a                	mv	a0,s6
 798:	ecfff0ef          	jal	666 <printint>
        i += 1;
 79c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 79e:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 7a0:	4981                	li	s3,0
 7a2:	b75d                	j	748 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 7a4:	008b8493          	addi	s1,s7,8
 7a8:	4685                	li	a3,1
 7aa:	4629                	li	a2,10
 7ac:	000ba583          	lw	a1,0(s7)
 7b0:	855a                	mv	a0,s6
 7b2:	eb5ff0ef          	jal	666 <printint>
 7b6:	8ba6                	mv	s7,s1
      state = 0;
 7b8:	4981                	li	s3,0
 7ba:	b779                	j	748 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 7bc:	9752                	add	a4,a4,s4
 7be:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7c2:	f9460713          	addi	a4,a2,-108
 7c6:	00173713          	seqz	a4,a4
 7ca:	8f75                	and	a4,a4,a3
 7cc:	f9c58513          	addi	a0,a1,-100
 7d0:	18051363          	bnez	a0,956 <vprintf+0x252>
 7d4:	18070163          	beqz	a4,956 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7d8:	008b8493          	addi	s1,s7,8
 7dc:	4685                	li	a3,1
 7de:	4629                	li	a2,10
 7e0:	000bb583          	ld	a1,0(s7)
 7e4:	855a                	mv	a0,s6
 7e6:	e81ff0ef          	jal	666 <printint>
        i += 2;
 7ea:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7ec:	8ba6                	mv	s7,s1
      state = 0;
 7ee:	4981                	li	s3,0
        i += 2;
 7f0:	bfa1                	j	748 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 7f2:	008b8493          	addi	s1,s7,8
 7f6:	4681                	li	a3,0
 7f8:	4629                	li	a2,10
 7fa:	000be583          	lwu	a1,0(s7)
 7fe:	855a                	mv	a0,s6
 800:	e67ff0ef          	jal	666 <printint>
 804:	8ba6                	mv	s7,s1
      state = 0;
 806:	4981                	li	s3,0
 808:	b781                	j	748 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 80a:	008b8493          	addi	s1,s7,8
 80e:	4681                	li	a3,0
 810:	4629                	li	a2,10
 812:	000bb583          	ld	a1,0(s7)
 816:	855a                	mv	a0,s6
 818:	e4fff0ef          	jal	666 <printint>
        i += 1;
 81c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 81e:	8ba6                	mv	s7,s1
      state = 0;
 820:	4981                	li	s3,0
 822:	b71d                	j	748 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 824:	008b8493          	addi	s1,s7,8
 828:	4681                	li	a3,0
 82a:	4629                	li	a2,10
 82c:	000bb583          	ld	a1,0(s7)
 830:	855a                	mv	a0,s6
 832:	e35ff0ef          	jal	666 <printint>
        i += 2;
 836:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 838:	8ba6                	mv	s7,s1
      state = 0;
 83a:	4981                	li	s3,0
        i += 2;
 83c:	b731                	j	748 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 83e:	008b8493          	addi	s1,s7,8
 842:	4681                	li	a3,0
 844:	4641                	li	a2,16
 846:	000be583          	lwu	a1,0(s7)
 84a:	855a                	mv	a0,s6
 84c:	e1bff0ef          	jal	666 <printint>
 850:	8ba6                	mv	s7,s1
      state = 0;
 852:	4981                	li	s3,0
 854:	bdd5                	j	748 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 856:	008b8493          	addi	s1,s7,8
 85a:	4681                	li	a3,0
 85c:	4641                	li	a2,16
 85e:	000bb583          	ld	a1,0(s7)
 862:	855a                	mv	a0,s6
 864:	e03ff0ef          	jal	666 <printint>
        i += 1;
 868:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 86a:	8ba6                	mv	s7,s1
      state = 0;
 86c:	4981                	li	s3,0
 86e:	bde9                	j	748 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 870:	008b8493          	addi	s1,s7,8
 874:	4681                	li	a3,0
 876:	4641                	li	a2,16
 878:	000bb583          	ld	a1,0(s7)
 87c:	855a                	mv	a0,s6
 87e:	de9ff0ef          	jal	666 <printint>
        i += 2;
 882:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 884:	8ba6                	mv	s7,s1
      state = 0;
 886:	4981                	li	s3,0
        i += 2;
 888:	b5c1                	j	748 <vprintf+0x44>
 88a:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 88c:	008b8793          	addi	a5,s7,8
 890:	8cbe                	mv	s9,a5
 892:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 896:	03000593          	li	a1,48
 89a:	855a                	mv	a0,s6
 89c:	dadff0ef          	jal	648 <putc>
  putc(fd, 'x');
 8a0:	07800593          	li	a1,120
 8a4:	855a                	mv	a0,s6
 8a6:	da3ff0ef          	jal	648 <putc>
 8aa:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8ac:	00000b97          	auipc	s7,0x0
 8b0:	334b8b93          	addi	s7,s7,820 # be0 <digits>
 8b4:	03c9d793          	srli	a5,s3,0x3c
 8b8:	97de                	add	a5,a5,s7
 8ba:	0007c583          	lbu	a1,0(a5)
 8be:	855a                	mv	a0,s6
 8c0:	d89ff0ef          	jal	648 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8c4:	0992                	slli	s3,s3,0x4
 8c6:	34fd                	addiw	s1,s1,-1
 8c8:	f4f5                	bnez	s1,8b4 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 8ca:	8be6                	mv	s7,s9
      state = 0;
 8cc:	4981                	li	s3,0
 8ce:	6ca2                	ld	s9,8(sp)
 8d0:	bda5                	j	748 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 8d2:	008b8493          	addi	s1,s7,8
 8d6:	000bc583          	lbu	a1,0(s7)
 8da:	855a                	mv	a0,s6
 8dc:	d6dff0ef          	jal	648 <putc>
 8e0:	8ba6                	mv	s7,s1
      state = 0;
 8e2:	4981                	li	s3,0
 8e4:	b595                	j	748 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 8e6:	008b8993          	addi	s3,s7,8
 8ea:	000bb483          	ld	s1,0(s7)
 8ee:	cc91                	beqz	s1,90a <vprintf+0x206>
        for(; *s; s++)
 8f0:	0004c583          	lbu	a1,0(s1)
 8f4:	c985                	beqz	a1,924 <vprintf+0x220>
          putc(fd, *s);
 8f6:	855a                	mv	a0,s6
 8f8:	d51ff0ef          	jal	648 <putc>
        for(; *s; s++)
 8fc:	0485                	addi	s1,s1,1
 8fe:	0004c583          	lbu	a1,0(s1)
 902:	f9f5                	bnez	a1,8f6 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 904:	8bce                	mv	s7,s3
      state = 0;
 906:	4981                	li	s3,0
 908:	b581                	j	748 <vprintf+0x44>
          s = "(null)";
 90a:	00000497          	auipc	s1,0x0
 90e:	2ce48493          	addi	s1,s1,718 # bd8 <malloc+0x132>
        for(; *s; s++)
 912:	02800593          	li	a1,40
 916:	b7c5                	j	8f6 <vprintf+0x1f2>
        putc(fd, '%');
 918:	85be                	mv	a1,a5
 91a:	855a                	mv	a0,s6
 91c:	d2dff0ef          	jal	648 <putc>
      state = 0;
 920:	4981                	li	s3,0
 922:	b51d                	j	748 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 924:	8bce                	mv	s7,s3
      state = 0;
 926:	4981                	li	s3,0
 928:	b505                	j	748 <vprintf+0x44>
 92a:	6906                	ld	s2,64(sp)
 92c:	79e2                	ld	s3,56(sp)
 92e:	7a42                	ld	s4,48(sp)
 930:	7aa2                	ld	s5,40(sp)
 932:	7b02                	ld	s6,32(sp)
 934:	6be2                	ld	s7,24(sp)
 936:	6c42                	ld	s8,16(sp)
    }
  }
}
 938:	60e6                	ld	ra,88(sp)
 93a:	6446                	ld	s0,80(sp)
 93c:	64a6                	ld	s1,72(sp)
 93e:	6125                	addi	sp,sp,96
 940:	8082                	ret
      if(c0 == 'd'){
 942:	06400713          	li	a4,100
 946:	e4e78fe3          	beq	a5,a4,7a4 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 94a:	f9478693          	addi	a3,a5,-108
 94e:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 952:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 954:	4701                	li	a4,0
      } else if(c0 == 'u'){
 956:	07500513          	li	a0,117
 95a:	e8a78ce3          	beq	a5,a0,7f2 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 95e:	f8b60513          	addi	a0,a2,-117
 962:	e119                	bnez	a0,968 <vprintf+0x264>
 964:	ea0693e3          	bnez	a3,80a <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 968:	f8b58513          	addi	a0,a1,-117
 96c:	e119                	bnez	a0,972 <vprintf+0x26e>
 96e:	ea071be3          	bnez	a4,824 <vprintf+0x120>
      } else if(c0 == 'x'){
 972:	07800513          	li	a0,120
 976:	eca784e3          	beq	a5,a0,83e <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 97a:	f8860613          	addi	a2,a2,-120
 97e:	e219                	bnez	a2,984 <vprintf+0x280>
 980:	ec069be3          	bnez	a3,856 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 984:	f8858593          	addi	a1,a1,-120
 988:	e199                	bnez	a1,98e <vprintf+0x28a>
 98a:	ee0713e3          	bnez	a4,870 <vprintf+0x16c>
      } else if(c0 == 'p'){
 98e:	07000713          	li	a4,112
 992:	eee78ce3          	beq	a5,a4,88a <vprintf+0x186>
      } else if(c0 == 'c'){
 996:	06300713          	li	a4,99
 99a:	f2e78ce3          	beq	a5,a4,8d2 <vprintf+0x1ce>
      } else if(c0 == 's'){
 99e:	07300713          	li	a4,115
 9a2:	f4e782e3          	beq	a5,a4,8e6 <vprintf+0x1e2>
      } else if(c0 == '%'){
 9a6:	02500713          	li	a4,37
 9aa:	f6e787e3          	beq	a5,a4,918 <vprintf+0x214>
        putc(fd, '%');
 9ae:	02500593          	li	a1,37
 9b2:	855a                	mv	a0,s6
 9b4:	c95ff0ef          	jal	648 <putc>
        putc(fd, c0);
 9b8:	85a6                	mv	a1,s1
 9ba:	855a                	mv	a0,s6
 9bc:	c8dff0ef          	jal	648 <putc>
      state = 0;
 9c0:	4981                	li	s3,0
 9c2:	b359                	j	748 <vprintf+0x44>

00000000000009c4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9c4:	715d                	addi	sp,sp,-80
 9c6:	ec06                	sd	ra,24(sp)
 9c8:	e822                	sd	s0,16(sp)
 9ca:	1000                	addi	s0,sp,32
 9cc:	e010                	sd	a2,0(s0)
 9ce:	e414                	sd	a3,8(s0)
 9d0:	e818                	sd	a4,16(s0)
 9d2:	ec1c                	sd	a5,24(s0)
 9d4:	03043023          	sd	a6,32(s0)
 9d8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9dc:	8622                	mv	a2,s0
 9de:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9e2:	d23ff0ef          	jal	704 <vprintf>
}
 9e6:	60e2                	ld	ra,24(sp)
 9e8:	6442                	ld	s0,16(sp)
 9ea:	6161                	addi	sp,sp,80
 9ec:	8082                	ret

00000000000009ee <printf>:

void
printf(const char *fmt, ...)
{
 9ee:	711d                	addi	sp,sp,-96
 9f0:	ec06                	sd	ra,24(sp)
 9f2:	e822                	sd	s0,16(sp)
 9f4:	1000                	addi	s0,sp,32
 9f6:	e40c                	sd	a1,8(s0)
 9f8:	e810                	sd	a2,16(s0)
 9fa:	ec14                	sd	a3,24(s0)
 9fc:	f018                	sd	a4,32(s0)
 9fe:	f41c                	sd	a5,40(s0)
 a00:	03043823          	sd	a6,48(s0)
 a04:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a08:	00840613          	addi	a2,s0,8
 a0c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a10:	85aa                	mv	a1,a0
 a12:	4505                	li	a0,1
 a14:	cf1ff0ef          	jal	704 <vprintf>
}
 a18:	60e2                	ld	ra,24(sp)
 a1a:	6442                	ld	s0,16(sp)
 a1c:	6125                	addi	sp,sp,96
 a1e:	8082                	ret

0000000000000a20 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a20:	1141                	addi	sp,sp,-16
 a22:	e406                	sd	ra,8(sp)
 a24:	e022                	sd	s0,0(sp)
 a26:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a28:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a2c:	00001797          	auipc	a5,0x1
 a30:	5d47b783          	ld	a5,1492(a5) # 2000 <freep>
 a34:	a039                	j	a42 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a36:	6398                	ld	a4,0(a5)
 a38:	00e7e463          	bltu	a5,a4,a40 <free+0x20>
 a3c:	00e6ea63          	bltu	a3,a4,a50 <free+0x30>
{
 a40:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a42:	fed7fae3          	bgeu	a5,a3,a36 <free+0x16>
 a46:	6398                	ld	a4,0(a5)
 a48:	00e6e463          	bltu	a3,a4,a50 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a4c:	fee7eae3          	bltu	a5,a4,a40 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 a50:	ff852583          	lw	a1,-8(a0)
 a54:	6390                	ld	a2,0(a5)
 a56:	02059813          	slli	a6,a1,0x20
 a5a:	01c85713          	srli	a4,a6,0x1c
 a5e:	9736                	add	a4,a4,a3
 a60:	02e60563          	beq	a2,a4,a8a <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 a64:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 a68:	4790                	lw	a2,8(a5)
 a6a:	02061593          	slli	a1,a2,0x20
 a6e:	01c5d713          	srli	a4,a1,0x1c
 a72:	973e                	add	a4,a4,a5
 a74:	02e68263          	beq	a3,a4,a98 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 a78:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a7a:	00001717          	auipc	a4,0x1
 a7e:	58f73323          	sd	a5,1414(a4) # 2000 <freep>
}
 a82:	60a2                	ld	ra,8(sp)
 a84:	6402                	ld	s0,0(sp)
 a86:	0141                	addi	sp,sp,16
 a88:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 a8a:	4618                	lw	a4,8(a2)
 a8c:	9f2d                	addw	a4,a4,a1
 a8e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a92:	6398                	ld	a4,0(a5)
 a94:	6310                	ld	a2,0(a4)
 a96:	b7f9                	j	a64 <free+0x44>
    p->s.size += bp->s.size;
 a98:	ff852703          	lw	a4,-8(a0)
 a9c:	9f31                	addw	a4,a4,a2
 a9e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 aa0:	ff053683          	ld	a3,-16(a0)
 aa4:	bfd1                	j	a78 <free+0x58>

0000000000000aa6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 aa6:	7139                	addi	sp,sp,-64
 aa8:	fc06                	sd	ra,56(sp)
 aaa:	f822                	sd	s0,48(sp)
 aac:	f04a                	sd	s2,32(sp)
 aae:	ec4e                	sd	s3,24(sp)
 ab0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ab2:	02051993          	slli	s3,a0,0x20
 ab6:	0209d993          	srli	s3,s3,0x20
 aba:	09bd                	addi	s3,s3,15
 abc:	0049d993          	srli	s3,s3,0x4
 ac0:	2985                	addiw	s3,s3,1
 ac2:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 ac4:	00001517          	auipc	a0,0x1
 ac8:	53c53503          	ld	a0,1340(a0) # 2000 <freep>
 acc:	c905                	beqz	a0,afc <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ace:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ad0:	4798                	lw	a4,8(a5)
 ad2:	09377663          	bgeu	a4,s3,b5e <malloc+0xb8>
 ad6:	f426                	sd	s1,40(sp)
 ad8:	e852                	sd	s4,16(sp)
 ada:	e456                	sd	s5,8(sp)
 adc:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 ade:	8a4e                	mv	s4,s3
 ae0:	6705                	lui	a4,0x1
 ae2:	00e9f363          	bgeu	s3,a4,ae8 <malloc+0x42>
 ae6:	6a05                	lui	s4,0x1
 ae8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 aec:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 af0:	00001497          	auipc	s1,0x1
 af4:	51048493          	addi	s1,s1,1296 # 2000 <freep>
  if(p == SBRK_ERROR)
 af8:	5afd                	li	s5,-1
 afa:	a83d                	j	b38 <malloc+0x92>
 afc:	f426                	sd	s1,40(sp)
 afe:	e852                	sd	s4,16(sp)
 b00:	e456                	sd	s5,8(sp)
 b02:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 b04:	00002797          	auipc	a5,0x2
 b08:	90c78793          	addi	a5,a5,-1780 # 2410 <base>
 b0c:	00001717          	auipc	a4,0x1
 b10:	4ef73a23          	sd	a5,1268(a4) # 2000 <freep>
 b14:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b16:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b1a:	b7d1                	j	ade <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 b1c:	6398                	ld	a4,0(a5)
 b1e:	e118                	sd	a4,0(a0)
 b20:	a899                	j	b76 <malloc+0xd0>
  hp->s.size = nu;
 b22:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b26:	0541                	addi	a0,a0,16
 b28:	ef9ff0ef          	jal	a20 <free>
  return freep;
 b2c:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 b2e:	c125                	beqz	a0,b8e <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b30:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b32:	4798                	lw	a4,8(a5)
 b34:	03277163          	bgeu	a4,s2,b56 <malloc+0xb0>
    if(p == freep)
 b38:	6098                	ld	a4,0(s1)
 b3a:	853e                	mv	a0,a5
 b3c:	fef71ae3          	bne	a4,a5,b30 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 b40:	8552                	mv	a0,s4
 b42:	99dff0ef          	jal	4de <sbrk>
  if(p == SBRK_ERROR)
 b46:	fd551ee3          	bne	a0,s5,b22 <malloc+0x7c>
        return 0;
 b4a:	4501                	li	a0,0
 b4c:	74a2                	ld	s1,40(sp)
 b4e:	6a42                	ld	s4,16(sp)
 b50:	6aa2                	ld	s5,8(sp)
 b52:	6b02                	ld	s6,0(sp)
 b54:	a03d                	j	b82 <malloc+0xdc>
 b56:	74a2                	ld	s1,40(sp)
 b58:	6a42                	ld	s4,16(sp)
 b5a:	6aa2                	ld	s5,8(sp)
 b5c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 b5e:	fae90fe3          	beq	s2,a4,b1c <malloc+0x76>
        p->s.size -= nunits;
 b62:	4137073b          	subw	a4,a4,s3
 b66:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b68:	02071693          	slli	a3,a4,0x20
 b6c:	01c6d713          	srli	a4,a3,0x1c
 b70:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b72:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b76:	00001717          	auipc	a4,0x1
 b7a:	48a73523          	sd	a0,1162(a4) # 2000 <freep>
      return (void*)(p + 1);
 b7e:	01078513          	addi	a0,a5,16
  }
}
 b82:	70e2                	ld	ra,56(sp)
 b84:	7442                	ld	s0,48(sp)
 b86:	7902                	ld	s2,32(sp)
 b88:	69e2                	ld	s3,24(sp)
 b8a:	6121                	addi	sp,sp,64
 b8c:	8082                	ret
 b8e:	74a2                	ld	s1,40(sp)
 b90:	6a42                	ld	s4,16(sp)
 b92:	6aa2                	ld	s5,8(sp)
 b94:	6b02                	ld	s6,0(sp)
 b96:	b7f5                	j	b82 <malloc+0xdc>
