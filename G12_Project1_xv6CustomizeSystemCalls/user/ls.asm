
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

char*
fmtname(char *path)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   c:	2ac000ef          	jal	2b8 <strlen>
  10:	02051793          	slli	a5,a0,0x20
  14:	9381                	srli	a5,a5,0x20
  16:	97a6                	add	a5,a5,s1
  18:	02f00693          	li	a3,47
  1c:	0097e963          	bltu	a5,s1,2e <fmtname+0x2e>
  20:	0007c703          	lbu	a4,0(a5)
  24:	00d70563          	beq	a4,a3,2e <fmtname+0x2e>
  28:	17fd                	addi	a5,a5,-1
  2a:	fe97fbe3          	bgeu	a5,s1,20 <fmtname+0x20>
    ;
  p++;
  2e:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  32:	8526                	mv	a0,s1
  34:	284000ef          	jal	2b8 <strlen>
  38:	47b5                	li	a5,13
  3a:	00a7f863          	bgeu	a5,a0,4a <fmtname+0x4a>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  buf[sizeof(buf)-1] = '\0';
  return buf;
}
  3e:	8526                	mv	a0,s1
  40:	60e2                	ld	ra,24(sp)
  42:	6442                	ld	s0,16(sp)
  44:	64a2                	ld	s1,8(sp)
  46:	6105                	addi	sp,sp,32
  48:	8082                	ret
  4a:	e04a                	sd	s2,0(sp)
  memmove(buf, p, strlen(p));
  4c:	8526                	mv	a0,s1
  4e:	26a000ef          	jal	2b8 <strlen>
  52:	862a                	mv	a2,a0
  54:	85a6                	mv	a1,s1
  56:	00002517          	auipc	a0,0x2
  5a:	fba50513          	addi	a0,a0,-70 # 2010 <buf.0>
  5e:	3d2000ef          	jal	430 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  62:	8526                	mv	a0,s1
  64:	254000ef          	jal	2b8 <strlen>
  68:	892a                	mv	s2,a0
  6a:	8526                	mv	a0,s1
  6c:	24c000ef          	jal	2b8 <strlen>
  70:	02091793          	slli	a5,s2,0x20
  74:	9381                	srli	a5,a5,0x20
  76:	4639                	li	a2,14
  78:	9e09                	subw	a2,a2,a0
  7a:	02000593          	li	a1,32
  7e:	00002717          	auipc	a4,0x2
  82:	f9270713          	addi	a4,a4,-110 # 2010 <buf.0>
  86:	84ba                	mv	s1,a4
  88:	00f70533          	add	a0,a4,a5
  8c:	258000ef          	jal	2e4 <memset>
  buf[sizeof(buf)-1] = '\0';
  90:	00048723          	sb	zero,14(s1)
  return buf;
  94:	6902                	ld	s2,0(sp)
  96:	b765                	j	3e <fmtname+0x3e>

0000000000000098 <ls>:

void
ls(char *path)
{
  98:	da010113          	addi	sp,sp,-608
  9c:	24113c23          	sd	ra,600(sp)
  a0:	24813823          	sd	s0,592(sp)
  a4:	25213023          	sd	s2,576(sp)
  a8:	1480                	addi	s0,sp,608
  aa:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, O_RDONLY)) < 0){
  ac:	4581                	li	a1,0
  ae:	52c000ef          	jal	5da <open>
  b2:	06054363          	bltz	a0,118 <ls+0x80>
  b6:	24913423          	sd	s1,584(sp)
  ba:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  bc:	da840593          	addi	a1,s0,-600
  c0:	532000ef          	jal	5f2 <fstat>
  c4:	06054363          	bltz	a0,12a <ls+0x92>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  c8:	db041783          	lh	a5,-592(s0)
  cc:	4705                	li	a4,1
  ce:	06e78c63          	beq	a5,a4,146 <ls+0xae>
  d2:	37f9                	addiw	a5,a5,-2
  d4:	17c2                	slli	a5,a5,0x30
  d6:	93c1                	srli	a5,a5,0x30
  d8:	02f76263          	bltu	a4,a5,fc <ls+0x64>
  case T_DEVICE:
  case T_FILE:
    printf("%s %d %d %d\n", fmtname(path), st.type, st.ino, (int) st.size);
  dc:	854a                	mv	a0,s2
  de:	f23ff0ef          	jal	0 <fmtname>
  e2:	85aa                	mv	a1,a0
  e4:	db842703          	lw	a4,-584(s0)
  e8:	dac42683          	lw	a3,-596(s0)
  ec:	db041603          	lh	a2,-592(s0)
  f0:	00001517          	auipc	a0,0x1
  f4:	ae050513          	addi	a0,a0,-1312 # bd0 <malloc+0x12e>
  f8:	0f3000ef          	jal	9ea <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
    }
    break;
  }
  close(fd);
  fc:	8526                	mv	a0,s1
  fe:	438000ef          	jal	536 <close>
 102:	24813483          	ld	s1,584(sp)
}
 106:	25813083          	ld	ra,600(sp)
 10a:	25013403          	ld	s0,592(sp)
 10e:	24013903          	ld	s2,576(sp)
 112:	26010113          	addi	sp,sp,608
 116:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 118:	864a                	mv	a2,s2
 11a:	00001597          	auipc	a1,0x1
 11e:	a8658593          	addi	a1,a1,-1402 # ba0 <malloc+0xfe>
 122:	4509                	li	a0,2
 124:	09d000ef          	jal	9c0 <fprintf>
    return;
 128:	bff9                	j	106 <ls+0x6e>
    fprintf(2, "ls: cannot stat %s\n", path);
 12a:	864a                	mv	a2,s2
 12c:	00001597          	auipc	a1,0x1
 130:	a8c58593          	addi	a1,a1,-1396 # bb8 <malloc+0x116>
 134:	4509                	li	a0,2
 136:	08b000ef          	jal	9c0 <fprintf>
    close(fd);
 13a:	8526                	mv	a0,s1
 13c:	3fa000ef          	jal	536 <close>
    return;
 140:	24813483          	ld	s1,584(sp)
 144:	b7c9                	j	106 <ls+0x6e>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 146:	854a                	mv	a0,s2
 148:	170000ef          	jal	2b8 <strlen>
 14c:	2541                	addiw	a0,a0,16
 14e:	20000793          	li	a5,512
 152:	00a7f963          	bgeu	a5,a0,164 <ls+0xcc>
      printf("ls: path too long\n");
 156:	00001517          	auipc	a0,0x1
 15a:	a8a50513          	addi	a0,a0,-1398 # be0 <malloc+0x13e>
 15e:	08d000ef          	jal	9ea <printf>
      break;
 162:	bf69                	j	fc <ls+0x64>
 164:	23313c23          	sd	s3,568(sp)
    strcpy(buf, path);
 168:	85ca                	mv	a1,s2
 16a:	dd040513          	addi	a0,s0,-560
 16e:	0fa000ef          	jal	268 <strcpy>
    p = buf+strlen(buf);
 172:	dd040513          	addi	a0,s0,-560
 176:	142000ef          	jal	2b8 <strlen>
 17a:	1502                	slli	a0,a0,0x20
 17c:	9101                	srli	a0,a0,0x20
 17e:	dd040793          	addi	a5,s0,-560
 182:	00a78733          	add	a4,a5,a0
 186:	893a                	mv	s2,a4
    *p++ = '/';
 188:	00170793          	addi	a5,a4,1
 18c:	89be                	mv	s3,a5
 18e:	02f00793          	li	a5,47
 192:	00f70023          	sb	a5,0(a4)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 196:	a809                	j	1a8 <ls+0x110>
        printf("ls: cannot stat %s\n", buf);
 198:	dd040593          	addi	a1,s0,-560
 19c:	00001517          	auipc	a0,0x1
 1a0:	a1c50513          	addi	a0,a0,-1508 # bb8 <malloc+0x116>
 1a4:	047000ef          	jal	9ea <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1a8:	4641                	li	a2,16
 1aa:	dc040593          	addi	a1,s0,-576
 1ae:	8526                	mv	a0,s1
 1b0:	376000ef          	jal	526 <read>
 1b4:	47c1                	li	a5,16
 1b6:	04f51763          	bne	a0,a5,204 <ls+0x16c>
      if(de.inum == 0)
 1ba:	dc045783          	lhu	a5,-576(s0)
 1be:	d7ed                	beqz	a5,1a8 <ls+0x110>
      memmove(p, de.name, DIRSIZ);
 1c0:	4639                	li	a2,14
 1c2:	dc240593          	addi	a1,s0,-574
 1c6:	854e                	mv	a0,s3
 1c8:	268000ef          	jal	430 <memmove>
      p[DIRSIZ] = 0;
 1cc:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 1d0:	da840593          	addi	a1,s0,-600
 1d4:	dd040513          	addi	a0,s0,-560
 1d8:	1d0000ef          	jal	3a8 <stat>
 1dc:	fa054ee3          	bltz	a0,198 <ls+0x100>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
 1e0:	dd040513          	addi	a0,s0,-560
 1e4:	e1dff0ef          	jal	0 <fmtname>
 1e8:	85aa                	mv	a1,a0
 1ea:	db842703          	lw	a4,-584(s0)
 1ee:	dac42683          	lw	a3,-596(s0)
 1f2:	db041603          	lh	a2,-592(s0)
 1f6:	00001517          	auipc	a0,0x1
 1fa:	9da50513          	addi	a0,a0,-1574 # bd0 <malloc+0x12e>
 1fe:	7ec000ef          	jal	9ea <printf>
 202:	b75d                	j	1a8 <ls+0x110>
 204:	23813983          	ld	s3,568(sp)
 208:	bdd5                	j	fc <ls+0x64>

000000000000020a <main>:

int
main(int argc, char *argv[])
{
 20a:	1101                	addi	sp,sp,-32
 20c:	ec06                	sd	ra,24(sp)
 20e:	e822                	sd	s0,16(sp)
 210:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
 212:	4785                	li	a5,1
 214:	02a7d763          	bge	a5,a0,242 <main+0x38>
 218:	e426                	sd	s1,8(sp)
 21a:	e04a                	sd	s2,0(sp)
 21c:	00858493          	addi	s1,a1,8
 220:	ffe5091b          	addiw	s2,a0,-2
 224:	02091793          	slli	a5,s2,0x20
 228:	01d7d913          	srli	s2,a5,0x1d
 22c:	05c1                	addi	a1,a1,16
 22e:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 230:	6088                	ld	a0,0(s1)
 232:	e67ff0ef          	jal	98 <ls>
  for(i=1; i<argc; i++)
 236:	04a1                	addi	s1,s1,8
 238:	ff249ce3          	bne	s1,s2,230 <main+0x26>
  exit(0);
 23c:	4501                	li	a0,0
 23e:	2d0000ef          	jal	50e <exit>
 242:	e426                	sd	s1,8(sp)
 244:	e04a                	sd	s2,0(sp)
    ls(".");
 246:	00001517          	auipc	a0,0x1
 24a:	9b250513          	addi	a0,a0,-1614 # bf8 <malloc+0x156>
 24e:	e4bff0ef          	jal	98 <ls>
    exit(0);
 252:	4501                	li	a0,0
 254:	2ba000ef          	jal	50e <exit>

0000000000000258 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 258:	1141                	addi	sp,sp,-16
 25a:	e406                	sd	ra,8(sp)
 25c:	e022                	sd	s0,0(sp)
 25e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 260:	fabff0ef          	jal	20a <main>
  exit(r);
 264:	2aa000ef          	jal	50e <exit>

0000000000000268 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 268:	1141                	addi	sp,sp,-16
 26a:	e406                	sd	ra,8(sp)
 26c:	e022                	sd	s0,0(sp)
 26e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 270:	87aa                	mv	a5,a0
 272:	0585                	addi	a1,a1,1
 274:	0785                	addi	a5,a5,1
 276:	fff5c703          	lbu	a4,-1(a1)
 27a:	fee78fa3          	sb	a4,-1(a5)
 27e:	fb75                	bnez	a4,272 <strcpy+0xa>
    ;
  return os;
}
 280:	60a2                	ld	ra,8(sp)
 282:	6402                	ld	s0,0(sp)
 284:	0141                	addi	sp,sp,16
 286:	8082                	ret

0000000000000288 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 288:	1141                	addi	sp,sp,-16
 28a:	e406                	sd	ra,8(sp)
 28c:	e022                	sd	s0,0(sp)
 28e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 290:	00054783          	lbu	a5,0(a0)
 294:	cb91                	beqz	a5,2a8 <strcmp+0x20>
 296:	0005c703          	lbu	a4,0(a1)
 29a:	00f71763          	bne	a4,a5,2a8 <strcmp+0x20>
    p++, q++;
 29e:	0505                	addi	a0,a0,1
 2a0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2a2:	00054783          	lbu	a5,0(a0)
 2a6:	fbe5                	bnez	a5,296 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 2a8:	0005c503          	lbu	a0,0(a1)
}
 2ac:	40a7853b          	subw	a0,a5,a0
 2b0:	60a2                	ld	ra,8(sp)
 2b2:	6402                	ld	s0,0(sp)
 2b4:	0141                	addi	sp,sp,16
 2b6:	8082                	ret

00000000000002b8 <strlen>:

uint
strlen(const char *s)
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e406                	sd	ra,8(sp)
 2bc:	e022                	sd	s0,0(sp)
 2be:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2c0:	00054783          	lbu	a5,0(a0)
 2c4:	cf91                	beqz	a5,2e0 <strlen+0x28>
 2c6:	00150793          	addi	a5,a0,1
 2ca:	86be                	mv	a3,a5
 2cc:	0785                	addi	a5,a5,1
 2ce:	fff7c703          	lbu	a4,-1(a5)
 2d2:	ff65                	bnez	a4,2ca <strlen+0x12>
 2d4:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 2d8:	60a2                	ld	ra,8(sp)
 2da:	6402                	ld	s0,0(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret
  for(n = 0; s[n]; n++)
 2e0:	4501                	li	a0,0
 2e2:	bfdd                	j	2d8 <strlen+0x20>

00000000000002e4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2e4:	1141                	addi	sp,sp,-16
 2e6:	e406                	sd	ra,8(sp)
 2e8:	e022                	sd	s0,0(sp)
 2ea:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2ec:	ca19                	beqz	a2,302 <memset+0x1e>
 2ee:	87aa                	mv	a5,a0
 2f0:	1602                	slli	a2,a2,0x20
 2f2:	9201                	srli	a2,a2,0x20
 2f4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2f8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2fc:	0785                	addi	a5,a5,1
 2fe:	fee79de3          	bne	a5,a4,2f8 <memset+0x14>
  }
  return dst;
}
 302:	60a2                	ld	ra,8(sp)
 304:	6402                	ld	s0,0(sp)
 306:	0141                	addi	sp,sp,16
 308:	8082                	ret

000000000000030a <strchr>:

char*
strchr(const char *s, char c)
{
 30a:	1141                	addi	sp,sp,-16
 30c:	e406                	sd	ra,8(sp)
 30e:	e022                	sd	s0,0(sp)
 310:	0800                	addi	s0,sp,16
  for(; *s; s++)
 312:	00054783          	lbu	a5,0(a0)
 316:	cf81                	beqz	a5,32e <strchr+0x24>
    if(*s == c)
 318:	00f58763          	beq	a1,a5,326 <strchr+0x1c>
  for(; *s; s++)
 31c:	0505                	addi	a0,a0,1
 31e:	00054783          	lbu	a5,0(a0)
 322:	fbfd                	bnez	a5,318 <strchr+0xe>
      return (char*)s;
  return 0;
 324:	4501                	li	a0,0
}
 326:	60a2                	ld	ra,8(sp)
 328:	6402                	ld	s0,0(sp)
 32a:	0141                	addi	sp,sp,16
 32c:	8082                	ret
  return 0;
 32e:	4501                	li	a0,0
 330:	bfdd                	j	326 <strchr+0x1c>

0000000000000332 <gets>:

char*
gets(char *buf, int max)
{
 332:	711d                	addi	sp,sp,-96
 334:	ec86                	sd	ra,88(sp)
 336:	e8a2                	sd	s0,80(sp)
 338:	e4a6                	sd	s1,72(sp)
 33a:	e0ca                	sd	s2,64(sp)
 33c:	fc4e                	sd	s3,56(sp)
 33e:	f852                	sd	s4,48(sp)
 340:	f456                	sd	s5,40(sp)
 342:	f05a                	sd	s6,32(sp)
 344:	ec5e                	sd	s7,24(sp)
 346:	e862                	sd	s8,16(sp)
 348:	1080                	addi	s0,sp,96
 34a:	8baa                	mv	s7,a0
 34c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 34e:	892a                	mv	s2,a0
 350:	4481                	li	s1,0
    cc = read(0, &c, 1);
 352:	faf40b13          	addi	s6,s0,-81
 356:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 358:	8c26                	mv	s8,s1
 35a:	0014899b          	addiw	s3,s1,1
 35e:	84ce                	mv	s1,s3
 360:	0349d463          	bge	s3,s4,388 <gets+0x56>
    cc = read(0, &c, 1);
 364:	8656                	mv	a2,s5
 366:	85da                	mv	a1,s6
 368:	4501                	li	a0,0
 36a:	1bc000ef          	jal	526 <read>
    if(cc < 1)
 36e:	00a05d63          	blez	a0,388 <gets+0x56>
      break;
    buf[i++] = c;
 372:	faf44783          	lbu	a5,-81(s0)
 376:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 37a:	0905                	addi	s2,s2,1
 37c:	ff678713          	addi	a4,a5,-10
 380:	c319                	beqz	a4,386 <gets+0x54>
 382:	17cd                	addi	a5,a5,-13
 384:	fbf1                	bnez	a5,358 <gets+0x26>
    buf[i++] = c;
 386:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 388:	9c5e                	add	s8,s8,s7
 38a:	000c0023          	sb	zero,0(s8)
  return buf;
}
 38e:	855e                	mv	a0,s7
 390:	60e6                	ld	ra,88(sp)
 392:	6446                	ld	s0,80(sp)
 394:	64a6                	ld	s1,72(sp)
 396:	6906                	ld	s2,64(sp)
 398:	79e2                	ld	s3,56(sp)
 39a:	7a42                	ld	s4,48(sp)
 39c:	7aa2                	ld	s5,40(sp)
 39e:	7b02                	ld	s6,32(sp)
 3a0:	6be2                	ld	s7,24(sp)
 3a2:	6c42                	ld	s8,16(sp)
 3a4:	6125                	addi	sp,sp,96
 3a6:	8082                	ret

00000000000003a8 <stat>:

int
stat(const char *n, struct stat *st)
{
 3a8:	1101                	addi	sp,sp,-32
 3aa:	ec06                	sd	ra,24(sp)
 3ac:	e822                	sd	s0,16(sp)
 3ae:	e04a                	sd	s2,0(sp)
 3b0:	1000                	addi	s0,sp,32
 3b2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3b4:	4581                	li	a1,0
 3b6:	224000ef          	jal	5da <open>
  if(fd < 0)
 3ba:	02054263          	bltz	a0,3de <stat+0x36>
 3be:	e426                	sd	s1,8(sp)
 3c0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3c2:	85ca                	mv	a1,s2
 3c4:	22e000ef          	jal	5f2 <fstat>
 3c8:	892a                	mv	s2,a0
  close(fd);
 3ca:	8526                	mv	a0,s1
 3cc:	16a000ef          	jal	536 <close>
  return r;
 3d0:	64a2                	ld	s1,8(sp)
}
 3d2:	854a                	mv	a0,s2
 3d4:	60e2                	ld	ra,24(sp)
 3d6:	6442                	ld	s0,16(sp)
 3d8:	6902                	ld	s2,0(sp)
 3da:	6105                	addi	sp,sp,32
 3dc:	8082                	ret
    return -1;
 3de:	57fd                	li	a5,-1
 3e0:	893e                	mv	s2,a5
 3e2:	bfc5                	j	3d2 <stat+0x2a>

00000000000003e4 <atoi>:

int
atoi(const char *s)
{
 3e4:	1141                	addi	sp,sp,-16
 3e6:	e406                	sd	ra,8(sp)
 3e8:	e022                	sd	s0,0(sp)
 3ea:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3ec:	00054683          	lbu	a3,0(a0)
 3f0:	fd06879b          	addiw	a5,a3,-48
 3f4:	0ff7f793          	zext.b	a5,a5
 3f8:	4625                	li	a2,9
 3fa:	02f66963          	bltu	a2,a5,42c <atoi+0x48>
 3fe:	872a                	mv	a4,a0
  n = 0;
 400:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 402:	0705                	addi	a4,a4,1
 404:	0025179b          	slliw	a5,a0,0x2
 408:	9fa9                	addw	a5,a5,a0
 40a:	0017979b          	slliw	a5,a5,0x1
 40e:	9fb5                	addw	a5,a5,a3
 410:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 414:	00074683          	lbu	a3,0(a4)
 418:	fd06879b          	addiw	a5,a3,-48
 41c:	0ff7f793          	zext.b	a5,a5
 420:	fef671e3          	bgeu	a2,a5,402 <atoi+0x1e>
  return n;
}
 424:	60a2                	ld	ra,8(sp)
 426:	6402                	ld	s0,0(sp)
 428:	0141                	addi	sp,sp,16
 42a:	8082                	ret
  n = 0;
 42c:	4501                	li	a0,0
 42e:	bfdd                	j	424 <atoi+0x40>

0000000000000430 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 430:	1141                	addi	sp,sp,-16
 432:	e406                	sd	ra,8(sp)
 434:	e022                	sd	s0,0(sp)
 436:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 438:	02b57563          	bgeu	a0,a1,462 <memmove+0x32>
    while(n-- > 0)
 43c:	00c05f63          	blez	a2,45a <memmove+0x2a>
 440:	1602                	slli	a2,a2,0x20
 442:	9201                	srli	a2,a2,0x20
 444:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 448:	872a                	mv	a4,a0
      *dst++ = *src++;
 44a:	0585                	addi	a1,a1,1
 44c:	0705                	addi	a4,a4,1
 44e:	fff5c683          	lbu	a3,-1(a1)
 452:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 456:	fee79ae3          	bne	a5,a4,44a <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 45a:	60a2                	ld	ra,8(sp)
 45c:	6402                	ld	s0,0(sp)
 45e:	0141                	addi	sp,sp,16
 460:	8082                	ret
    while(n-- > 0)
 462:	fec05ce3          	blez	a2,45a <memmove+0x2a>
    dst += n;
 466:	00c50733          	add	a4,a0,a2
    src += n;
 46a:	95b2                	add	a1,a1,a2
 46c:	fff6079b          	addiw	a5,a2,-1
 470:	1782                	slli	a5,a5,0x20
 472:	9381                	srli	a5,a5,0x20
 474:	fff7c793          	not	a5,a5
 478:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 47a:	15fd                	addi	a1,a1,-1
 47c:	177d                	addi	a4,a4,-1
 47e:	0005c683          	lbu	a3,0(a1)
 482:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 486:	fef71ae3          	bne	a4,a5,47a <memmove+0x4a>
 48a:	bfc1                	j	45a <memmove+0x2a>

000000000000048c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 48c:	1141                	addi	sp,sp,-16
 48e:	e406                	sd	ra,8(sp)
 490:	e022                	sd	s0,0(sp)
 492:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 494:	c61d                	beqz	a2,4c2 <memcmp+0x36>
 496:	1602                	slli	a2,a2,0x20
 498:	9201                	srli	a2,a2,0x20
 49a:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 49e:	00054783          	lbu	a5,0(a0)
 4a2:	0005c703          	lbu	a4,0(a1)
 4a6:	00e79863          	bne	a5,a4,4b6 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 4aa:	0505                	addi	a0,a0,1
    p2++;
 4ac:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4ae:	fed518e3          	bne	a0,a3,49e <memcmp+0x12>
  }
  return 0;
 4b2:	4501                	li	a0,0
 4b4:	a019                	j	4ba <memcmp+0x2e>
      return *p1 - *p2;
 4b6:	40e7853b          	subw	a0,a5,a4
}
 4ba:	60a2                	ld	ra,8(sp)
 4bc:	6402                	ld	s0,0(sp)
 4be:	0141                	addi	sp,sp,16
 4c0:	8082                	ret
  return 0;
 4c2:	4501                	li	a0,0
 4c4:	bfdd                	j	4ba <memcmp+0x2e>

00000000000004c6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4c6:	1141                	addi	sp,sp,-16
 4c8:	e406                	sd	ra,8(sp)
 4ca:	e022                	sd	s0,0(sp)
 4cc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4ce:	f63ff0ef          	jal	430 <memmove>
}
 4d2:	60a2                	ld	ra,8(sp)
 4d4:	6402                	ld	s0,0(sp)
 4d6:	0141                	addi	sp,sp,16
 4d8:	8082                	ret

00000000000004da <sbrk>:

char *
sbrk(int n) {
 4da:	1141                	addi	sp,sp,-16
 4dc:	e406                	sd	ra,8(sp)
 4de:	e022                	sd	s0,0(sp)
 4e0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4e2:	4585                	li	a1,1
 4e4:	13e000ef          	jal	622 <sys_sbrk>
}
 4e8:	60a2                	ld	ra,8(sp)
 4ea:	6402                	ld	s0,0(sp)
 4ec:	0141                	addi	sp,sp,16
 4ee:	8082                	ret

00000000000004f0 <sbrklazy>:

char *
sbrklazy(int n) {
 4f0:	1141                	addi	sp,sp,-16
 4f2:	e406                	sd	ra,8(sp)
 4f4:	e022                	sd	s0,0(sp)
 4f6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4f8:	4589                	li	a1,2
 4fa:	128000ef          	jal	622 <sys_sbrk>
}
 4fe:	60a2                	ld	ra,8(sp)
 500:	6402                	ld	s0,0(sp)
 502:	0141                	addi	sp,sp,16
 504:	8082                	ret

0000000000000506 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 506:	4885                	li	a7,1
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <exit>:
.global exit
exit:
 li a7, SYS_exit
 50e:	4889                	li	a7,2
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <wait>:
.global wait
wait:
 li a7, SYS_wait
 516:	488d                	li	a7,3
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 51e:	4891                	li	a7,4
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <read>:
.global read
read:
 li a7, SYS_read
 526:	4895                	li	a7,5
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <write>:
.global write
write:
 li a7, SYS_write
 52e:	48c1                	li	a7,16
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <close>:
.global close
close:
 li a7, SYS_close
 536:	48d5                	li	a7,21
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <shmget>:
.global shmget
shmget:
 li a7, SYS_shmget
 53e:	48d9                	li	a7,22
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <shmat>:
.global shmat
shmat:
 li a7, SYS_shmat
 546:	48dd                	li	a7,23
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 54e:	48e1                	li	a7,24
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 556:	48e5                	li	a7,25
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <lockinit>:
.global lockinit
lockinit:
 li a7, SYS_lockinit
 55e:	48e9                	li	a7,26
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <lockacquire>:
.global lockacquire
lockacquire:
 li a7, SYS_lockacquire
 566:	48ed                	li	a7,27
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <lockrelease>:
.global lockrelease
lockrelease:
 li a7, SYS_lockrelease
 56e:	48f1                	li	a7,28
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <locktry>:
.global locktry
locktry:
 li a7, SYS_locktry
 576:	48f5                	li	a7,29
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <lockcheck>:
.global lockcheck
lockcheck:
 li a7, SYS_lockcheck
 57e:	48f9                	li	a7,30
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <sendmsg>:
.global sendmsg
sendmsg:
 li a7, SYS_sendmsg
 586:	48fd                	li	a7,31
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <recvmsg>:
.global recvmsg
recvmsg:
 li a7, SYS_recvmsg
 58e:	02000893          	li	a7,32
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <broadcast>:
.global broadcast
broadcast:
 li a7, SYS_broadcast
 598:	02100893          	li	a7,33
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <getprocsinfo>:
.global getprocsinfo
getprocsinfo:
 li a7, SYS_getprocsinfo
 5a2:	02200893          	li	a7,34
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 5ac:	02300893          	li	a7,35
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <sleep2>:
.global sleep2
sleep2:
 li a7, SYS_sleep2
 5b6:	02400893          	li	a7,36
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <signal>:
.global signal
signal:
 li a7, SYS_signal
 5c0:	02500893          	li	a7,37
 ecall
 5c4:	00000073          	ecall
 ret
 5c8:	8082                	ret

00000000000005ca <kill>:
.global kill
kill:
 li a7, SYS_kill
 5ca:	4899                	li	a7,6
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5d2:	489d                	li	a7,7
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <open>:
.global open
open:
 li a7, SYS_open
 5da:	48bd                	li	a7,15
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5e2:	48c5                	li	a7,17
 ecall
 5e4:	00000073          	ecall
 ret
 5e8:	8082                	ret

00000000000005ea <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5ea:	48c9                	li	a7,18
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5f2:	48a1                	li	a7,8
 ecall
 5f4:	00000073          	ecall
 ret
 5f8:	8082                	ret

00000000000005fa <link>:
.global link
link:
 li a7, SYS_link
 5fa:	48cd                	li	a7,19
 ecall
 5fc:	00000073          	ecall
 ret
 600:	8082                	ret

0000000000000602 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 602:	48d1                	li	a7,20
 ecall
 604:	00000073          	ecall
 ret
 608:	8082                	ret

000000000000060a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 60a:	48a5                	li	a7,9
 ecall
 60c:	00000073          	ecall
 ret
 610:	8082                	ret

0000000000000612 <dup>:
.global dup
dup:
 li a7, SYS_dup
 612:	48a9                	li	a7,10
 ecall
 614:	00000073          	ecall
 ret
 618:	8082                	ret

000000000000061a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 61a:	48ad                	li	a7,11
 ecall
 61c:	00000073          	ecall
 ret
 620:	8082                	ret

0000000000000622 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 622:	48b1                	li	a7,12
 ecall
 624:	00000073          	ecall
 ret
 628:	8082                	ret

000000000000062a <pause>:
.global pause
pause:
 li a7, SYS_pause
 62a:	48b5                	li	a7,13
 ecall
 62c:	00000073          	ecall
 ret
 630:	8082                	ret

0000000000000632 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 632:	48b9                	li	a7,14
 ecall
 634:	00000073          	ecall
 ret
 638:	8082                	ret

000000000000063a <setchildlimit>:
.global setchildlimit
setchildlimit:
 li a7, SYS_setchildlimit
 63a:	02600893          	li	a7,38
 ecall
 63e:	00000073          	ecall
 ret
 642:	8082                	ret

0000000000000644 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 644:	1101                	addi	sp,sp,-32
 646:	ec06                	sd	ra,24(sp)
 648:	e822                	sd	s0,16(sp)
 64a:	1000                	addi	s0,sp,32
 64c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 650:	4605                	li	a2,1
 652:	fef40593          	addi	a1,s0,-17
 656:	ed9ff0ef          	jal	52e <write>
}
 65a:	60e2                	ld	ra,24(sp)
 65c:	6442                	ld	s0,16(sp)
 65e:	6105                	addi	sp,sp,32
 660:	8082                	ret

0000000000000662 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 662:	715d                	addi	sp,sp,-80
 664:	e486                	sd	ra,72(sp)
 666:	e0a2                	sd	s0,64(sp)
 668:	f84a                	sd	s2,48(sp)
 66a:	f44e                	sd	s3,40(sp)
 66c:	0880                	addi	s0,sp,80
 66e:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 670:	c6d1                	beqz	a3,6fc <printint+0x9a>
 672:	0805d563          	bgez	a1,6fc <printint+0x9a>
    neg = 1;
    x = -xx;
 676:	40b005b3          	neg	a1,a1
    neg = 1;
 67a:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 67c:	fb840993          	addi	s3,s0,-72
  neg = 0;
 680:	86ce                	mv	a3,s3
  i = 0;
 682:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 684:	00000817          	auipc	a6,0x0
 688:	58480813          	addi	a6,a6,1412 # c08 <digits>
 68c:	88ba                	mv	a7,a4
 68e:	0017051b          	addiw	a0,a4,1
 692:	872a                	mv	a4,a0
 694:	02c5f7b3          	remu	a5,a1,a2
 698:	97c2                	add	a5,a5,a6
 69a:	0007c783          	lbu	a5,0(a5)
 69e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6a2:	87ae                	mv	a5,a1
 6a4:	02c5d5b3          	divu	a1,a1,a2
 6a8:	0685                	addi	a3,a3,1
 6aa:	fec7f1e3          	bgeu	a5,a2,68c <printint+0x2a>
  if(neg)
 6ae:	00030c63          	beqz	t1,6c6 <printint+0x64>
    buf[i++] = '-';
 6b2:	fd050793          	addi	a5,a0,-48
 6b6:	00878533          	add	a0,a5,s0
 6ba:	02d00793          	li	a5,45
 6be:	fef50423          	sb	a5,-24(a0)
 6c2:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 6c6:	02e05563          	blez	a4,6f0 <printint+0x8e>
 6ca:	fc26                	sd	s1,56(sp)
 6cc:	377d                	addiw	a4,a4,-1
 6ce:	00e984b3          	add	s1,s3,a4
 6d2:	19fd                	addi	s3,s3,-1
 6d4:	99ba                	add	s3,s3,a4
 6d6:	1702                	slli	a4,a4,0x20
 6d8:	9301                	srli	a4,a4,0x20
 6da:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6de:	0004c583          	lbu	a1,0(s1)
 6e2:	854a                	mv	a0,s2
 6e4:	f61ff0ef          	jal	644 <putc>
  while(--i >= 0)
 6e8:	14fd                	addi	s1,s1,-1
 6ea:	ff349ae3          	bne	s1,s3,6de <printint+0x7c>
 6ee:	74e2                	ld	s1,56(sp)
}
 6f0:	60a6                	ld	ra,72(sp)
 6f2:	6406                	ld	s0,64(sp)
 6f4:	7942                	ld	s2,48(sp)
 6f6:	79a2                	ld	s3,40(sp)
 6f8:	6161                	addi	sp,sp,80
 6fa:	8082                	ret
  neg = 0;
 6fc:	4301                	li	t1,0
 6fe:	bfbd                	j	67c <printint+0x1a>

0000000000000700 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 700:	711d                	addi	sp,sp,-96
 702:	ec86                	sd	ra,88(sp)
 704:	e8a2                	sd	s0,80(sp)
 706:	e4a6                	sd	s1,72(sp)
 708:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 70a:	0005c483          	lbu	s1,0(a1)
 70e:	22048363          	beqz	s1,934 <vprintf+0x234>
 712:	e0ca                	sd	s2,64(sp)
 714:	fc4e                	sd	s3,56(sp)
 716:	f852                	sd	s4,48(sp)
 718:	f456                	sd	s5,40(sp)
 71a:	f05a                	sd	s6,32(sp)
 71c:	ec5e                	sd	s7,24(sp)
 71e:	e862                	sd	s8,16(sp)
 720:	8b2a                	mv	s6,a0
 722:	8a2e                	mv	s4,a1
 724:	8bb2                	mv	s7,a2
  state = 0;
 726:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 728:	4901                	li	s2,0
 72a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 72c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 730:	06400c13          	li	s8,100
 734:	a00d                	j	756 <vprintf+0x56>
        putc(fd, c0);
 736:	85a6                	mv	a1,s1
 738:	855a                	mv	a0,s6
 73a:	f0bff0ef          	jal	644 <putc>
 73e:	a019                	j	744 <vprintf+0x44>
    } else if(state == '%'){
 740:	03598363          	beq	s3,s5,766 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 744:	0019079b          	addiw	a5,s2,1
 748:	893e                	mv	s2,a5
 74a:	873e                	mv	a4,a5
 74c:	97d2                	add	a5,a5,s4
 74e:	0007c483          	lbu	s1,0(a5)
 752:	1c048a63          	beqz	s1,926 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 756:	0004879b          	sext.w	a5,s1
    if(state == 0){
 75a:	fe0993e3          	bnez	s3,740 <vprintf+0x40>
      if(c0 == '%'){
 75e:	fd579ce3          	bne	a5,s5,736 <vprintf+0x36>
        state = '%';
 762:	89be                	mv	s3,a5
 764:	b7c5                	j	744 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 766:	00ea06b3          	add	a3,s4,a4
 76a:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 76e:	1c060863          	beqz	a2,93e <vprintf+0x23e>
      if(c0 == 'd'){
 772:	03878763          	beq	a5,s8,7a0 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 776:	f9478693          	addi	a3,a5,-108
 77a:	0016b693          	seqz	a3,a3
 77e:	f9c60593          	addi	a1,a2,-100
 782:	e99d                	bnez	a1,7b8 <vprintf+0xb8>
 784:	ca95                	beqz	a3,7b8 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 786:	008b8493          	addi	s1,s7,8
 78a:	4685                	li	a3,1
 78c:	4629                	li	a2,10
 78e:	000bb583          	ld	a1,0(s7)
 792:	855a                	mv	a0,s6
 794:	ecfff0ef          	jal	662 <printint>
        i += 1;
 798:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 79a:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 79c:	4981                	li	s3,0
 79e:	b75d                	j	744 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 7a0:	008b8493          	addi	s1,s7,8
 7a4:	4685                	li	a3,1
 7a6:	4629                	li	a2,10
 7a8:	000ba583          	lw	a1,0(s7)
 7ac:	855a                	mv	a0,s6
 7ae:	eb5ff0ef          	jal	662 <printint>
 7b2:	8ba6                	mv	s7,s1
      state = 0;
 7b4:	4981                	li	s3,0
 7b6:	b779                	j	744 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 7b8:	9752                	add	a4,a4,s4
 7ba:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7be:	f9460713          	addi	a4,a2,-108
 7c2:	00173713          	seqz	a4,a4
 7c6:	8f75                	and	a4,a4,a3
 7c8:	f9c58513          	addi	a0,a1,-100
 7cc:	18051363          	bnez	a0,952 <vprintf+0x252>
 7d0:	18070163          	beqz	a4,952 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7d4:	008b8493          	addi	s1,s7,8
 7d8:	4685                	li	a3,1
 7da:	4629                	li	a2,10
 7dc:	000bb583          	ld	a1,0(s7)
 7e0:	855a                	mv	a0,s6
 7e2:	e81ff0ef          	jal	662 <printint>
        i += 2;
 7e6:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7e8:	8ba6                	mv	s7,s1
      state = 0;
 7ea:	4981                	li	s3,0
        i += 2;
 7ec:	bfa1                	j	744 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 7ee:	008b8493          	addi	s1,s7,8
 7f2:	4681                	li	a3,0
 7f4:	4629                	li	a2,10
 7f6:	000be583          	lwu	a1,0(s7)
 7fa:	855a                	mv	a0,s6
 7fc:	e67ff0ef          	jal	662 <printint>
 800:	8ba6                	mv	s7,s1
      state = 0;
 802:	4981                	li	s3,0
 804:	b781                	j	744 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 806:	008b8493          	addi	s1,s7,8
 80a:	4681                	li	a3,0
 80c:	4629                	li	a2,10
 80e:	000bb583          	ld	a1,0(s7)
 812:	855a                	mv	a0,s6
 814:	e4fff0ef          	jal	662 <printint>
        i += 1;
 818:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 81a:	8ba6                	mv	s7,s1
      state = 0;
 81c:	4981                	li	s3,0
 81e:	b71d                	j	744 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 820:	008b8493          	addi	s1,s7,8
 824:	4681                	li	a3,0
 826:	4629                	li	a2,10
 828:	000bb583          	ld	a1,0(s7)
 82c:	855a                	mv	a0,s6
 82e:	e35ff0ef          	jal	662 <printint>
        i += 2;
 832:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 834:	8ba6                	mv	s7,s1
      state = 0;
 836:	4981                	li	s3,0
        i += 2;
 838:	b731                	j	744 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 83a:	008b8493          	addi	s1,s7,8
 83e:	4681                	li	a3,0
 840:	4641                	li	a2,16
 842:	000be583          	lwu	a1,0(s7)
 846:	855a                	mv	a0,s6
 848:	e1bff0ef          	jal	662 <printint>
 84c:	8ba6                	mv	s7,s1
      state = 0;
 84e:	4981                	li	s3,0
 850:	bdd5                	j	744 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 852:	008b8493          	addi	s1,s7,8
 856:	4681                	li	a3,0
 858:	4641                	li	a2,16
 85a:	000bb583          	ld	a1,0(s7)
 85e:	855a                	mv	a0,s6
 860:	e03ff0ef          	jal	662 <printint>
        i += 1;
 864:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 866:	8ba6                	mv	s7,s1
      state = 0;
 868:	4981                	li	s3,0
 86a:	bde9                	j	744 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 86c:	008b8493          	addi	s1,s7,8
 870:	4681                	li	a3,0
 872:	4641                	li	a2,16
 874:	000bb583          	ld	a1,0(s7)
 878:	855a                	mv	a0,s6
 87a:	de9ff0ef          	jal	662 <printint>
        i += 2;
 87e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 880:	8ba6                	mv	s7,s1
      state = 0;
 882:	4981                	li	s3,0
        i += 2;
 884:	b5c1                	j	744 <vprintf+0x44>
 886:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 888:	008b8793          	addi	a5,s7,8
 88c:	8cbe                	mv	s9,a5
 88e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 892:	03000593          	li	a1,48
 896:	855a                	mv	a0,s6
 898:	dadff0ef          	jal	644 <putc>
  putc(fd, 'x');
 89c:	07800593          	li	a1,120
 8a0:	855a                	mv	a0,s6
 8a2:	da3ff0ef          	jal	644 <putc>
 8a6:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8a8:	00000b97          	auipc	s7,0x0
 8ac:	360b8b93          	addi	s7,s7,864 # c08 <digits>
 8b0:	03c9d793          	srli	a5,s3,0x3c
 8b4:	97de                	add	a5,a5,s7
 8b6:	0007c583          	lbu	a1,0(a5)
 8ba:	855a                	mv	a0,s6
 8bc:	d89ff0ef          	jal	644 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8c0:	0992                	slli	s3,s3,0x4
 8c2:	34fd                	addiw	s1,s1,-1
 8c4:	f4f5                	bnez	s1,8b0 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 8c6:	8be6                	mv	s7,s9
      state = 0;
 8c8:	4981                	li	s3,0
 8ca:	6ca2                	ld	s9,8(sp)
 8cc:	bda5                	j	744 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 8ce:	008b8493          	addi	s1,s7,8
 8d2:	000bc583          	lbu	a1,0(s7)
 8d6:	855a                	mv	a0,s6
 8d8:	d6dff0ef          	jal	644 <putc>
 8dc:	8ba6                	mv	s7,s1
      state = 0;
 8de:	4981                	li	s3,0
 8e0:	b595                	j	744 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 8e2:	008b8993          	addi	s3,s7,8
 8e6:	000bb483          	ld	s1,0(s7)
 8ea:	cc91                	beqz	s1,906 <vprintf+0x206>
        for(; *s; s++)
 8ec:	0004c583          	lbu	a1,0(s1)
 8f0:	c985                	beqz	a1,920 <vprintf+0x220>
          putc(fd, *s);
 8f2:	855a                	mv	a0,s6
 8f4:	d51ff0ef          	jal	644 <putc>
        for(; *s; s++)
 8f8:	0485                	addi	s1,s1,1
 8fa:	0004c583          	lbu	a1,0(s1)
 8fe:	f9f5                	bnez	a1,8f2 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 900:	8bce                	mv	s7,s3
      state = 0;
 902:	4981                	li	s3,0
 904:	b581                	j	744 <vprintf+0x44>
          s = "(null)";
 906:	00000497          	auipc	s1,0x0
 90a:	2fa48493          	addi	s1,s1,762 # c00 <malloc+0x15e>
        for(; *s; s++)
 90e:	02800593          	li	a1,40
 912:	b7c5                	j	8f2 <vprintf+0x1f2>
        putc(fd, '%');
 914:	85be                	mv	a1,a5
 916:	855a                	mv	a0,s6
 918:	d2dff0ef          	jal	644 <putc>
      state = 0;
 91c:	4981                	li	s3,0
 91e:	b51d                	j	744 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 920:	8bce                	mv	s7,s3
      state = 0;
 922:	4981                	li	s3,0
 924:	b505                	j	744 <vprintf+0x44>
 926:	6906                	ld	s2,64(sp)
 928:	79e2                	ld	s3,56(sp)
 92a:	7a42                	ld	s4,48(sp)
 92c:	7aa2                	ld	s5,40(sp)
 92e:	7b02                	ld	s6,32(sp)
 930:	6be2                	ld	s7,24(sp)
 932:	6c42                	ld	s8,16(sp)
    }
  }
}
 934:	60e6                	ld	ra,88(sp)
 936:	6446                	ld	s0,80(sp)
 938:	64a6                	ld	s1,72(sp)
 93a:	6125                	addi	sp,sp,96
 93c:	8082                	ret
      if(c0 == 'd'){
 93e:	06400713          	li	a4,100
 942:	e4e78fe3          	beq	a5,a4,7a0 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 946:	f9478693          	addi	a3,a5,-108
 94a:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 94e:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 950:	4701                	li	a4,0
      } else if(c0 == 'u'){
 952:	07500513          	li	a0,117
 956:	e8a78ce3          	beq	a5,a0,7ee <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 95a:	f8b60513          	addi	a0,a2,-117
 95e:	e119                	bnez	a0,964 <vprintf+0x264>
 960:	ea0693e3          	bnez	a3,806 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 964:	f8b58513          	addi	a0,a1,-117
 968:	e119                	bnez	a0,96e <vprintf+0x26e>
 96a:	ea071be3          	bnez	a4,820 <vprintf+0x120>
      } else if(c0 == 'x'){
 96e:	07800513          	li	a0,120
 972:	eca784e3          	beq	a5,a0,83a <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 976:	f8860613          	addi	a2,a2,-120
 97a:	e219                	bnez	a2,980 <vprintf+0x280>
 97c:	ec069be3          	bnez	a3,852 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 980:	f8858593          	addi	a1,a1,-120
 984:	e199                	bnez	a1,98a <vprintf+0x28a>
 986:	ee0713e3          	bnez	a4,86c <vprintf+0x16c>
      } else if(c0 == 'p'){
 98a:	07000713          	li	a4,112
 98e:	eee78ce3          	beq	a5,a4,886 <vprintf+0x186>
      } else if(c0 == 'c'){
 992:	06300713          	li	a4,99
 996:	f2e78ce3          	beq	a5,a4,8ce <vprintf+0x1ce>
      } else if(c0 == 's'){
 99a:	07300713          	li	a4,115
 99e:	f4e782e3          	beq	a5,a4,8e2 <vprintf+0x1e2>
      } else if(c0 == '%'){
 9a2:	02500713          	li	a4,37
 9a6:	f6e787e3          	beq	a5,a4,914 <vprintf+0x214>
        putc(fd, '%');
 9aa:	02500593          	li	a1,37
 9ae:	855a                	mv	a0,s6
 9b0:	c95ff0ef          	jal	644 <putc>
        putc(fd, c0);
 9b4:	85a6                	mv	a1,s1
 9b6:	855a                	mv	a0,s6
 9b8:	c8dff0ef          	jal	644 <putc>
      state = 0;
 9bc:	4981                	li	s3,0
 9be:	b359                	j	744 <vprintf+0x44>

00000000000009c0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9c0:	715d                	addi	sp,sp,-80
 9c2:	ec06                	sd	ra,24(sp)
 9c4:	e822                	sd	s0,16(sp)
 9c6:	1000                	addi	s0,sp,32
 9c8:	e010                	sd	a2,0(s0)
 9ca:	e414                	sd	a3,8(s0)
 9cc:	e818                	sd	a4,16(s0)
 9ce:	ec1c                	sd	a5,24(s0)
 9d0:	03043023          	sd	a6,32(s0)
 9d4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9d8:	8622                	mv	a2,s0
 9da:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9de:	d23ff0ef          	jal	700 <vprintf>
}
 9e2:	60e2                	ld	ra,24(sp)
 9e4:	6442                	ld	s0,16(sp)
 9e6:	6161                	addi	sp,sp,80
 9e8:	8082                	ret

00000000000009ea <printf>:

void
printf(const char *fmt, ...)
{
 9ea:	711d                	addi	sp,sp,-96
 9ec:	ec06                	sd	ra,24(sp)
 9ee:	e822                	sd	s0,16(sp)
 9f0:	1000                	addi	s0,sp,32
 9f2:	e40c                	sd	a1,8(s0)
 9f4:	e810                	sd	a2,16(s0)
 9f6:	ec14                	sd	a3,24(s0)
 9f8:	f018                	sd	a4,32(s0)
 9fa:	f41c                	sd	a5,40(s0)
 9fc:	03043823          	sd	a6,48(s0)
 a00:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a04:	00840613          	addi	a2,s0,8
 a08:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a0c:	85aa                	mv	a1,a0
 a0e:	4505                	li	a0,1
 a10:	cf1ff0ef          	jal	700 <vprintf>
}
 a14:	60e2                	ld	ra,24(sp)
 a16:	6442                	ld	s0,16(sp)
 a18:	6125                	addi	sp,sp,96
 a1a:	8082                	ret

0000000000000a1c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a1c:	1141                	addi	sp,sp,-16
 a1e:	e406                	sd	ra,8(sp)
 a20:	e022                	sd	s0,0(sp)
 a22:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a24:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a28:	00001797          	auipc	a5,0x1
 a2c:	5d87b783          	ld	a5,1496(a5) # 2000 <freep>
 a30:	a039                	j	a3e <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a32:	6398                	ld	a4,0(a5)
 a34:	00e7e463          	bltu	a5,a4,a3c <free+0x20>
 a38:	00e6ea63          	bltu	a3,a4,a4c <free+0x30>
{
 a3c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a3e:	fed7fae3          	bgeu	a5,a3,a32 <free+0x16>
 a42:	6398                	ld	a4,0(a5)
 a44:	00e6e463          	bltu	a3,a4,a4c <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a48:	fee7eae3          	bltu	a5,a4,a3c <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 a4c:	ff852583          	lw	a1,-8(a0)
 a50:	6390                	ld	a2,0(a5)
 a52:	02059813          	slli	a6,a1,0x20
 a56:	01c85713          	srli	a4,a6,0x1c
 a5a:	9736                	add	a4,a4,a3
 a5c:	02e60563          	beq	a2,a4,a86 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 a60:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 a64:	4790                	lw	a2,8(a5)
 a66:	02061593          	slli	a1,a2,0x20
 a6a:	01c5d713          	srli	a4,a1,0x1c
 a6e:	973e                	add	a4,a4,a5
 a70:	02e68263          	beq	a3,a4,a94 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 a74:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a76:	00001717          	auipc	a4,0x1
 a7a:	58f73523          	sd	a5,1418(a4) # 2000 <freep>
}
 a7e:	60a2                	ld	ra,8(sp)
 a80:	6402                	ld	s0,0(sp)
 a82:	0141                	addi	sp,sp,16
 a84:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 a86:	4618                	lw	a4,8(a2)
 a88:	9f2d                	addw	a4,a4,a1
 a8a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a8e:	6398                	ld	a4,0(a5)
 a90:	6310                	ld	a2,0(a4)
 a92:	b7f9                	j	a60 <free+0x44>
    p->s.size += bp->s.size;
 a94:	ff852703          	lw	a4,-8(a0)
 a98:	9f31                	addw	a4,a4,a2
 a9a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a9c:	ff053683          	ld	a3,-16(a0)
 aa0:	bfd1                	j	a74 <free+0x58>

0000000000000aa2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 aa2:	7139                	addi	sp,sp,-64
 aa4:	fc06                	sd	ra,56(sp)
 aa6:	f822                	sd	s0,48(sp)
 aa8:	f04a                	sd	s2,32(sp)
 aaa:	ec4e                	sd	s3,24(sp)
 aac:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 aae:	02051993          	slli	s3,a0,0x20
 ab2:	0209d993          	srli	s3,s3,0x20
 ab6:	09bd                	addi	s3,s3,15
 ab8:	0049d993          	srli	s3,s3,0x4
 abc:	2985                	addiw	s3,s3,1
 abe:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 ac0:	00001517          	auipc	a0,0x1
 ac4:	54053503          	ld	a0,1344(a0) # 2000 <freep>
 ac8:	c905                	beqz	a0,af8 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aca:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 acc:	4798                	lw	a4,8(a5)
 ace:	09377663          	bgeu	a4,s3,b5a <malloc+0xb8>
 ad2:	f426                	sd	s1,40(sp)
 ad4:	e852                	sd	s4,16(sp)
 ad6:	e456                	sd	s5,8(sp)
 ad8:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 ada:	8a4e                	mv	s4,s3
 adc:	6705                	lui	a4,0x1
 ade:	00e9f363          	bgeu	s3,a4,ae4 <malloc+0x42>
 ae2:	6a05                	lui	s4,0x1
 ae4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 ae8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 aec:	00001497          	auipc	s1,0x1
 af0:	51448493          	addi	s1,s1,1300 # 2000 <freep>
  if(p == SBRK_ERROR)
 af4:	5afd                	li	s5,-1
 af6:	a83d                	j	b34 <malloc+0x92>
 af8:	f426                	sd	s1,40(sp)
 afa:	e852                	sd	s4,16(sp)
 afc:	e456                	sd	s5,8(sp)
 afe:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 b00:	00001797          	auipc	a5,0x1
 b04:	52078793          	addi	a5,a5,1312 # 2020 <base>
 b08:	00001717          	auipc	a4,0x1
 b0c:	4ef73c23          	sd	a5,1272(a4) # 2000 <freep>
 b10:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b12:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b16:	b7d1                	j	ada <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 b18:	6398                	ld	a4,0(a5)
 b1a:	e118                	sd	a4,0(a0)
 b1c:	a899                	j	b72 <malloc+0xd0>
  hp->s.size = nu;
 b1e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b22:	0541                	addi	a0,a0,16
 b24:	ef9ff0ef          	jal	a1c <free>
  return freep;
 b28:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 b2a:	c125                	beqz	a0,b8a <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b2c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b2e:	4798                	lw	a4,8(a5)
 b30:	03277163          	bgeu	a4,s2,b52 <malloc+0xb0>
    if(p == freep)
 b34:	6098                	ld	a4,0(s1)
 b36:	853e                	mv	a0,a5
 b38:	fef71ae3          	bne	a4,a5,b2c <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 b3c:	8552                	mv	a0,s4
 b3e:	99dff0ef          	jal	4da <sbrk>
  if(p == SBRK_ERROR)
 b42:	fd551ee3          	bne	a0,s5,b1e <malloc+0x7c>
        return 0;
 b46:	4501                	li	a0,0
 b48:	74a2                	ld	s1,40(sp)
 b4a:	6a42                	ld	s4,16(sp)
 b4c:	6aa2                	ld	s5,8(sp)
 b4e:	6b02                	ld	s6,0(sp)
 b50:	a03d                	j	b7e <malloc+0xdc>
 b52:	74a2                	ld	s1,40(sp)
 b54:	6a42                	ld	s4,16(sp)
 b56:	6aa2                	ld	s5,8(sp)
 b58:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 b5a:	fae90fe3          	beq	s2,a4,b18 <malloc+0x76>
        p->s.size -= nunits;
 b5e:	4137073b          	subw	a4,a4,s3
 b62:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b64:	02071693          	slli	a3,a4,0x20
 b68:	01c6d713          	srli	a4,a3,0x1c
 b6c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b6e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b72:	00001717          	auipc	a4,0x1
 b76:	48a73723          	sd	a0,1166(a4) # 2000 <freep>
      return (void*)(p + 1);
 b7a:	01078513          	addi	a0,a5,16
  }
}
 b7e:	70e2                	ld	ra,56(sp)
 b80:	7442                	ld	s0,48(sp)
 b82:	7902                	ld	s2,32(sp)
 b84:	69e2                	ld	s3,24(sp)
 b86:	6121                	addi	sp,sp,64
 b88:	8082                	ret
 b8a:	74a2                	ld	s1,40(sp)
 b8c:	6a42                	ld	s4,16(sp)
 b8e:	6aa2                	ld	s5,8(sp)
 b90:	6b02                	ld	s6,0(sp)
 b92:	b7f5                	j	b7e <malloc+0xdc>
