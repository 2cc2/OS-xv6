
user/_pgtbltest：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <err>:

char *testname = "???";

void
err(char *why)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
   c:	84aa                	mv	s1,a0
  printf("pgtbltest: %s failed: %s, pid=%d\n", testname, why, getpid());
   e:	00001917          	auipc	s2,0x1
  12:	ff293903          	ld	s2,-14(s2) # 1000 <testname>
  16:	00000097          	auipc	ra,0x0
  1a:	418080e7          	jalr	1048(ra) # 42e <getpid>
  1e:	86aa                	mv	a3,a0
  20:	8626                	mv	a2,s1
  22:	85ca                	mv	a1,s2
  24:	00001517          	auipc	a0,0x1
  28:	8bc50513          	addi	a0,a0,-1860 # 8e0 <malloc+0xec>
  2c:	00000097          	auipc	ra,0x0
  30:	70a080e7          	jalr	1802(ra) # 736 <printf>
  exit(1);
  34:	4505                	li	a0,1
  36:	00000097          	auipc	ra,0x0
  3a:	378080e7          	jalr	888(ra) # 3ae <exit>

000000000000003e <ugetpid_test>:
}

void
ugetpid_test()
{
  3e:	7179                	addi	sp,sp,-48
  40:	f406                	sd	ra,40(sp)
  42:	f022                	sd	s0,32(sp)
  44:	ec26                	sd	s1,24(sp)
  46:	1800                	addi	s0,sp,48
  int i;

  printf("ugetpid_test starting\n");
  48:	00001517          	auipc	a0,0x1
  4c:	8c050513          	addi	a0,a0,-1856 # 908 <malloc+0x114>
  50:	00000097          	auipc	ra,0x0
  54:	6e6080e7          	jalr	1766(ra) # 736 <printf>
  testname = "ugetpid_test";
  58:	00001797          	auipc	a5,0x1
  5c:	8c878793          	addi	a5,a5,-1848 # 920 <malloc+0x12c>
  60:	00001717          	auipc	a4,0x1
  64:	faf73023          	sd	a5,-96(a4) # 1000 <testname>
  68:	04000493          	li	s1,64

  for (i = 0; i < 64; i++) {
    int ret = fork();
  6c:	00000097          	auipc	ra,0x0
  70:	33a080e7          	jalr	826(ra) # 3a6 <fork>
  74:	fca42e23          	sw	a0,-36(s0)
    if (ret != 0) {
  78:	cd15                	beqz	a0,b4 <ugetpid_test+0x76>
      wait(&ret);
  7a:	fdc40513          	addi	a0,s0,-36
  7e:	00000097          	auipc	ra,0x0
  82:	338080e7          	jalr	824(ra) # 3b6 <wait>
      if (ret != 0)
  86:	fdc42783          	lw	a5,-36(s0)
  8a:	e385                	bnez	a5,aa <ugetpid_test+0x6c>
  for (i = 0; i < 64; i++) {
  8c:	34fd                	addiw	s1,s1,-1
  8e:	fcf9                	bnez	s1,6c <ugetpid_test+0x2e>
    }
    if (getpid() != ugetpid())
      err("missmatched PID");
    exit(0);
  }
  printf("ugetpid_test: OK\n");
  90:	00001517          	auipc	a0,0x1
  94:	8b050513          	addi	a0,a0,-1872 # 940 <malloc+0x14c>
  98:	00000097          	auipc	ra,0x0
  9c:	69e080e7          	jalr	1694(ra) # 736 <printf>
}
  a0:	70a2                	ld	ra,40(sp)
  a2:	7402                	ld	s0,32(sp)
  a4:	64e2                	ld	s1,24(sp)
  a6:	6145                	addi	sp,sp,48
  a8:	8082                	ret
        exit(1);
  aa:	4505                	li	a0,1
  ac:	00000097          	auipc	ra,0x0
  b0:	302080e7          	jalr	770(ra) # 3ae <exit>
    if (getpid() != ugetpid())
  b4:	00000097          	auipc	ra,0x0
  b8:	37a080e7          	jalr	890(ra) # 42e <getpid>
  bc:	84aa                	mv	s1,a0
  be:	00000097          	auipc	ra,0x0
  c2:	2d8080e7          	jalr	728(ra) # 396 <ugetpid>
  c6:	00a48a63          	beq	s1,a0,da <ugetpid_test+0x9c>
      err("missmatched PID");
  ca:	00001517          	auipc	a0,0x1
  ce:	86650513          	addi	a0,a0,-1946 # 930 <malloc+0x13c>
  d2:	00000097          	auipc	ra,0x0
  d6:	f2e080e7          	jalr	-210(ra) # 0 <err>
    exit(0);
  da:	4501                	li	a0,0
  dc:	00000097          	auipc	ra,0x0
  e0:	2d2080e7          	jalr	722(ra) # 3ae <exit>

00000000000000e4 <main>:
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e406                	sd	ra,8(sp)
  e8:	e022                	sd	s0,0(sp)
  ea:	0800                	addi	s0,sp,16
  ugetpid_test();
  ec:	00000097          	auipc	ra,0x0
  f0:	f52080e7          	jalr	-174(ra) # 3e <ugetpid_test>
  printf("pgtbltest: all tests succeeded\n");
  f4:	00001517          	auipc	a0,0x1
  f8:	86450513          	addi	a0,a0,-1948 # 958 <malloc+0x164>
  fc:	00000097          	auipc	ra,0x0
 100:	63a080e7          	jalr	1594(ra) # 736 <printf>
  exit(0);
 104:	4501                	li	a0,0
 106:	00000097          	auipc	ra,0x0
 10a:	2a8080e7          	jalr	680(ra) # 3ae <exit>

000000000000010e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 10e:	1141                	addi	sp,sp,-16
 110:	e406                	sd	ra,8(sp)
 112:	e022                	sd	s0,0(sp)
 114:	0800                	addi	s0,sp,16
  extern int main();
  main();
 116:	00000097          	auipc	ra,0x0
 11a:	fce080e7          	jalr	-50(ra) # e4 <main>
  exit(0);
 11e:	4501                	li	a0,0
 120:	00000097          	auipc	ra,0x0
 124:	28e080e7          	jalr	654(ra) # 3ae <exit>

0000000000000128 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 128:	1141                	addi	sp,sp,-16
 12a:	e422                	sd	s0,8(sp)
 12c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 12e:	87aa                	mv	a5,a0
 130:	0585                	addi	a1,a1,1
 132:	0785                	addi	a5,a5,1
 134:	fff5c703          	lbu	a4,-1(a1)
 138:	fee78fa3          	sb	a4,-1(a5)
 13c:	fb75                	bnez	a4,130 <strcpy+0x8>
    ;
  return os;
}
 13e:	6422                	ld	s0,8(sp)
 140:	0141                	addi	sp,sp,16
 142:	8082                	ret

0000000000000144 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 144:	1141                	addi	sp,sp,-16
 146:	e422                	sd	s0,8(sp)
 148:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 14a:	00054783          	lbu	a5,0(a0)
 14e:	cb91                	beqz	a5,162 <strcmp+0x1e>
 150:	0005c703          	lbu	a4,0(a1)
 154:	00f71763          	bne	a4,a5,162 <strcmp+0x1e>
    p++, q++;
 158:	0505                	addi	a0,a0,1
 15a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 15c:	00054783          	lbu	a5,0(a0)
 160:	fbe5                	bnez	a5,150 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 162:	0005c503          	lbu	a0,0(a1)
}
 166:	40a7853b          	subw	a0,a5,a0
 16a:	6422                	ld	s0,8(sp)
 16c:	0141                	addi	sp,sp,16
 16e:	8082                	ret

0000000000000170 <strlen>:

uint
strlen(const char *s)
{
 170:	1141                	addi	sp,sp,-16
 172:	e422                	sd	s0,8(sp)
 174:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 176:	00054783          	lbu	a5,0(a0)
 17a:	cf91                	beqz	a5,196 <strlen+0x26>
 17c:	0505                	addi	a0,a0,1
 17e:	87aa                	mv	a5,a0
 180:	4685                	li	a3,1
 182:	9e89                	subw	a3,a3,a0
 184:	00f6853b          	addw	a0,a3,a5
 188:	0785                	addi	a5,a5,1
 18a:	fff7c703          	lbu	a4,-1(a5)
 18e:	fb7d                	bnez	a4,184 <strlen+0x14>
    ;
  return n;
}
 190:	6422                	ld	s0,8(sp)
 192:	0141                	addi	sp,sp,16
 194:	8082                	ret
  for(n = 0; s[n]; n++)
 196:	4501                	li	a0,0
 198:	bfe5                	j	190 <strlen+0x20>

000000000000019a <memset>:

void*
memset(void *dst, int c, uint n)
{
 19a:	1141                	addi	sp,sp,-16
 19c:	e422                	sd	s0,8(sp)
 19e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1a0:	ce09                	beqz	a2,1ba <memset+0x20>
 1a2:	87aa                	mv	a5,a0
 1a4:	fff6071b          	addiw	a4,a2,-1
 1a8:	1702                	slli	a4,a4,0x20
 1aa:	9301                	srli	a4,a4,0x20
 1ac:	0705                	addi	a4,a4,1
 1ae:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1b0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1b4:	0785                	addi	a5,a5,1
 1b6:	fee79de3          	bne	a5,a4,1b0 <memset+0x16>
  }
  return dst;
}
 1ba:	6422                	ld	s0,8(sp)
 1bc:	0141                	addi	sp,sp,16
 1be:	8082                	ret

00000000000001c0 <strchr>:

char*
strchr(const char *s, char c)
{
 1c0:	1141                	addi	sp,sp,-16
 1c2:	e422                	sd	s0,8(sp)
 1c4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1c6:	00054783          	lbu	a5,0(a0)
 1ca:	cb99                	beqz	a5,1e0 <strchr+0x20>
    if(*s == c)
 1cc:	00f58763          	beq	a1,a5,1da <strchr+0x1a>
  for(; *s; s++)
 1d0:	0505                	addi	a0,a0,1
 1d2:	00054783          	lbu	a5,0(a0)
 1d6:	fbfd                	bnez	a5,1cc <strchr+0xc>
      return (char*)s;
  return 0;
 1d8:	4501                	li	a0,0
}
 1da:	6422                	ld	s0,8(sp)
 1dc:	0141                	addi	sp,sp,16
 1de:	8082                	ret
  return 0;
 1e0:	4501                	li	a0,0
 1e2:	bfe5                	j	1da <strchr+0x1a>

00000000000001e4 <gets>:

char*
gets(char *buf, int max)
{
 1e4:	711d                	addi	sp,sp,-96
 1e6:	ec86                	sd	ra,88(sp)
 1e8:	e8a2                	sd	s0,80(sp)
 1ea:	e4a6                	sd	s1,72(sp)
 1ec:	e0ca                	sd	s2,64(sp)
 1ee:	fc4e                	sd	s3,56(sp)
 1f0:	f852                	sd	s4,48(sp)
 1f2:	f456                	sd	s5,40(sp)
 1f4:	f05a                	sd	s6,32(sp)
 1f6:	ec5e                	sd	s7,24(sp)
 1f8:	1080                	addi	s0,sp,96
 1fa:	8baa                	mv	s7,a0
 1fc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1fe:	892a                	mv	s2,a0
 200:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 202:	4aa9                	li	s5,10
 204:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 206:	89a6                	mv	s3,s1
 208:	2485                	addiw	s1,s1,1
 20a:	0344d863          	bge	s1,s4,23a <gets+0x56>
    cc = read(0, &c, 1);
 20e:	4605                	li	a2,1
 210:	faf40593          	addi	a1,s0,-81
 214:	4501                	li	a0,0
 216:	00000097          	auipc	ra,0x0
 21a:	1b0080e7          	jalr	432(ra) # 3c6 <read>
    if(cc < 1)
 21e:	00a05e63          	blez	a0,23a <gets+0x56>
    buf[i++] = c;
 222:	faf44783          	lbu	a5,-81(s0)
 226:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 22a:	01578763          	beq	a5,s5,238 <gets+0x54>
 22e:	0905                	addi	s2,s2,1
 230:	fd679be3          	bne	a5,s6,206 <gets+0x22>
  for(i=0; i+1 < max; ){
 234:	89a6                	mv	s3,s1
 236:	a011                	j	23a <gets+0x56>
 238:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 23a:	99de                	add	s3,s3,s7
 23c:	00098023          	sb	zero,0(s3)
  return buf;
}
 240:	855e                	mv	a0,s7
 242:	60e6                	ld	ra,88(sp)
 244:	6446                	ld	s0,80(sp)
 246:	64a6                	ld	s1,72(sp)
 248:	6906                	ld	s2,64(sp)
 24a:	79e2                	ld	s3,56(sp)
 24c:	7a42                	ld	s4,48(sp)
 24e:	7aa2                	ld	s5,40(sp)
 250:	7b02                	ld	s6,32(sp)
 252:	6be2                	ld	s7,24(sp)
 254:	6125                	addi	sp,sp,96
 256:	8082                	ret

0000000000000258 <stat>:

int
stat(const char *n, struct stat *st)
{
 258:	1101                	addi	sp,sp,-32
 25a:	ec06                	sd	ra,24(sp)
 25c:	e822                	sd	s0,16(sp)
 25e:	e426                	sd	s1,8(sp)
 260:	e04a                	sd	s2,0(sp)
 262:	1000                	addi	s0,sp,32
 264:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 266:	4581                	li	a1,0
 268:	00000097          	auipc	ra,0x0
 26c:	186080e7          	jalr	390(ra) # 3ee <open>
  if(fd < 0)
 270:	02054563          	bltz	a0,29a <stat+0x42>
 274:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 276:	85ca                	mv	a1,s2
 278:	00000097          	auipc	ra,0x0
 27c:	18e080e7          	jalr	398(ra) # 406 <fstat>
 280:	892a                	mv	s2,a0
  close(fd);
 282:	8526                	mv	a0,s1
 284:	00000097          	auipc	ra,0x0
 288:	152080e7          	jalr	338(ra) # 3d6 <close>
  return r;
}
 28c:	854a                	mv	a0,s2
 28e:	60e2                	ld	ra,24(sp)
 290:	6442                	ld	s0,16(sp)
 292:	64a2                	ld	s1,8(sp)
 294:	6902                	ld	s2,0(sp)
 296:	6105                	addi	sp,sp,32
 298:	8082                	ret
    return -1;
 29a:	597d                	li	s2,-1
 29c:	bfc5                	j	28c <stat+0x34>

000000000000029e <atoi>:

int
atoi(const char *s)
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e422                	sd	s0,8(sp)
 2a2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2a4:	00054603          	lbu	a2,0(a0)
 2a8:	fd06079b          	addiw	a5,a2,-48
 2ac:	0ff7f793          	andi	a5,a5,255
 2b0:	4725                	li	a4,9
 2b2:	02f76963          	bltu	a4,a5,2e4 <atoi+0x46>
 2b6:	86aa                	mv	a3,a0
  n = 0;
 2b8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2ba:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2bc:	0685                	addi	a3,a3,1
 2be:	0025179b          	slliw	a5,a0,0x2
 2c2:	9fa9                	addw	a5,a5,a0
 2c4:	0017979b          	slliw	a5,a5,0x1
 2c8:	9fb1                	addw	a5,a5,a2
 2ca:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2ce:	0006c603          	lbu	a2,0(a3)
 2d2:	fd06071b          	addiw	a4,a2,-48
 2d6:	0ff77713          	andi	a4,a4,255
 2da:	fee5f1e3          	bgeu	a1,a4,2bc <atoi+0x1e>
  return n;
}
 2de:	6422                	ld	s0,8(sp)
 2e0:	0141                	addi	sp,sp,16
 2e2:	8082                	ret
  n = 0;
 2e4:	4501                	li	a0,0
 2e6:	bfe5                	j	2de <atoi+0x40>

00000000000002e8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e422                	sd	s0,8(sp)
 2ec:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2ee:	02b57663          	bgeu	a0,a1,31a <memmove+0x32>
    while(n-- > 0)
 2f2:	02c05163          	blez	a2,314 <memmove+0x2c>
 2f6:	fff6079b          	addiw	a5,a2,-1
 2fa:	1782                	slli	a5,a5,0x20
 2fc:	9381                	srli	a5,a5,0x20
 2fe:	0785                	addi	a5,a5,1
 300:	97aa                	add	a5,a5,a0
  dst = vdst;
 302:	872a                	mv	a4,a0
      *dst++ = *src++;
 304:	0585                	addi	a1,a1,1
 306:	0705                	addi	a4,a4,1
 308:	fff5c683          	lbu	a3,-1(a1)
 30c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 310:	fee79ae3          	bne	a5,a4,304 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 314:	6422                	ld	s0,8(sp)
 316:	0141                	addi	sp,sp,16
 318:	8082                	ret
    dst += n;
 31a:	00c50733          	add	a4,a0,a2
    src += n;
 31e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 320:	fec05ae3          	blez	a2,314 <memmove+0x2c>
 324:	fff6079b          	addiw	a5,a2,-1
 328:	1782                	slli	a5,a5,0x20
 32a:	9381                	srli	a5,a5,0x20
 32c:	fff7c793          	not	a5,a5
 330:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 332:	15fd                	addi	a1,a1,-1
 334:	177d                	addi	a4,a4,-1
 336:	0005c683          	lbu	a3,0(a1)
 33a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 33e:	fee79ae3          	bne	a5,a4,332 <memmove+0x4a>
 342:	bfc9                	j	314 <memmove+0x2c>

0000000000000344 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 344:	1141                	addi	sp,sp,-16
 346:	e422                	sd	s0,8(sp)
 348:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 34a:	ca05                	beqz	a2,37a <memcmp+0x36>
 34c:	fff6069b          	addiw	a3,a2,-1
 350:	1682                	slli	a3,a3,0x20
 352:	9281                	srli	a3,a3,0x20
 354:	0685                	addi	a3,a3,1
 356:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 358:	00054783          	lbu	a5,0(a0)
 35c:	0005c703          	lbu	a4,0(a1)
 360:	00e79863          	bne	a5,a4,370 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 364:	0505                	addi	a0,a0,1
    p2++;
 366:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 368:	fed518e3          	bne	a0,a3,358 <memcmp+0x14>
  }
  return 0;
 36c:	4501                	li	a0,0
 36e:	a019                	j	374 <memcmp+0x30>
      return *p1 - *p2;
 370:	40e7853b          	subw	a0,a5,a4
}
 374:	6422                	ld	s0,8(sp)
 376:	0141                	addi	sp,sp,16
 378:	8082                	ret
  return 0;
 37a:	4501                	li	a0,0
 37c:	bfe5                	j	374 <memcmp+0x30>

000000000000037e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 37e:	1141                	addi	sp,sp,-16
 380:	e406                	sd	ra,8(sp)
 382:	e022                	sd	s0,0(sp)
 384:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 386:	00000097          	auipc	ra,0x0
 38a:	f62080e7          	jalr	-158(ra) # 2e8 <memmove>
}
 38e:	60a2                	ld	ra,8(sp)
 390:	6402                	ld	s0,0(sp)
 392:	0141                	addi	sp,sp,16
 394:	8082                	ret

0000000000000396 <ugetpid>:
  int pid;  // Process ID
};

int
ugetpid(void)
{
 396:	1141                	addi	sp,sp,-16
 398:	e422                	sd	s0,8(sp)
 39a:	0800                	addi	s0,sp,16
  struct usyscall *u = (struct usyscall *)USYSCALL;
  return u->pid;
}
 39c:	00002503          	lw	a0,0(zero) # 0 <err>
 3a0:	6422                	ld	s0,8(sp)
 3a2:	0141                	addi	sp,sp,16
 3a4:	8082                	ret

00000000000003a6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3a6:	4885                	li	a7,1
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ae:	4889                	li	a7,2
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3b6:	488d                	li	a7,3
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3be:	4891                	li	a7,4
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <read>:
.global read
read:
 li a7, SYS_read
 3c6:	4895                	li	a7,5
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <write>:
.global write
write:
 li a7, SYS_write
 3ce:	48c1                	li	a7,16
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <close>:
.global close
close:
 li a7, SYS_close
 3d6:	48d5                	li	a7,21
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <kill>:
.global kill
kill:
 li a7, SYS_kill
 3de:	4899                	li	a7,6
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3e6:	489d                	li	a7,7
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <open>:
.global open
open:
 li a7, SYS_open
 3ee:	48bd                	li	a7,15
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3f6:	48c5                	li	a7,17
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3fe:	48c9                	li	a7,18
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 406:	48a1                	li	a7,8
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <link>:
.global link
link:
 li a7, SYS_link
 40e:	48cd                	li	a7,19
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 416:	48d1                	li	a7,20
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 41e:	48a5                	li	a7,9
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <dup>:
.global dup
dup:
 li a7, SYS_dup
 426:	48a9                	li	a7,10
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 42e:	48ad                	li	a7,11
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 436:	48b1                	li	a7,12
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 43e:	48b5                	li	a7,13
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 446:	48b9                	li	a7,14
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <trace>:
.global trace
trace:
 li a7, SYS_trace
 44e:	48d9                	li	a7,22
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <yield>:
.global yield
yield:
 li a7, SYS_yield
 456:	48dd                	li	a7,23
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 45e:	1101                	addi	sp,sp,-32
 460:	ec06                	sd	ra,24(sp)
 462:	e822                	sd	s0,16(sp)
 464:	1000                	addi	s0,sp,32
 466:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 46a:	4605                	li	a2,1
 46c:	fef40593          	addi	a1,s0,-17
 470:	00000097          	auipc	ra,0x0
 474:	f5e080e7          	jalr	-162(ra) # 3ce <write>
}
 478:	60e2                	ld	ra,24(sp)
 47a:	6442                	ld	s0,16(sp)
 47c:	6105                	addi	sp,sp,32
 47e:	8082                	ret

0000000000000480 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 480:	7139                	addi	sp,sp,-64
 482:	fc06                	sd	ra,56(sp)
 484:	f822                	sd	s0,48(sp)
 486:	f426                	sd	s1,40(sp)
 488:	f04a                	sd	s2,32(sp)
 48a:	ec4e                	sd	s3,24(sp)
 48c:	0080                	addi	s0,sp,64
 48e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 490:	c299                	beqz	a3,496 <printint+0x16>
 492:	0805c863          	bltz	a1,522 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 496:	2581                	sext.w	a1,a1
  neg = 0;
 498:	4881                	li	a7,0
 49a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 49e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4a0:	2601                	sext.w	a2,a2
 4a2:	00000517          	auipc	a0,0x0
 4a6:	4e650513          	addi	a0,a0,1254 # 988 <digits>
 4aa:	883a                	mv	a6,a4
 4ac:	2705                	addiw	a4,a4,1
 4ae:	02c5f7bb          	remuw	a5,a1,a2
 4b2:	1782                	slli	a5,a5,0x20
 4b4:	9381                	srli	a5,a5,0x20
 4b6:	97aa                	add	a5,a5,a0
 4b8:	0007c783          	lbu	a5,0(a5)
 4bc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4c0:	0005879b          	sext.w	a5,a1
 4c4:	02c5d5bb          	divuw	a1,a1,a2
 4c8:	0685                	addi	a3,a3,1
 4ca:	fec7f0e3          	bgeu	a5,a2,4aa <printint+0x2a>
  if(neg)
 4ce:	00088b63          	beqz	a7,4e4 <printint+0x64>
    buf[i++] = '-';
 4d2:	fd040793          	addi	a5,s0,-48
 4d6:	973e                	add	a4,a4,a5
 4d8:	02d00793          	li	a5,45
 4dc:	fef70823          	sb	a5,-16(a4)
 4e0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4e4:	02e05863          	blez	a4,514 <printint+0x94>
 4e8:	fc040793          	addi	a5,s0,-64
 4ec:	00e78933          	add	s2,a5,a4
 4f0:	fff78993          	addi	s3,a5,-1
 4f4:	99ba                	add	s3,s3,a4
 4f6:	377d                	addiw	a4,a4,-1
 4f8:	1702                	slli	a4,a4,0x20
 4fa:	9301                	srli	a4,a4,0x20
 4fc:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 500:	fff94583          	lbu	a1,-1(s2)
 504:	8526                	mv	a0,s1
 506:	00000097          	auipc	ra,0x0
 50a:	f58080e7          	jalr	-168(ra) # 45e <putc>
  while(--i >= 0)
 50e:	197d                	addi	s2,s2,-1
 510:	ff3918e3          	bne	s2,s3,500 <printint+0x80>
}
 514:	70e2                	ld	ra,56(sp)
 516:	7442                	ld	s0,48(sp)
 518:	74a2                	ld	s1,40(sp)
 51a:	7902                	ld	s2,32(sp)
 51c:	69e2                	ld	s3,24(sp)
 51e:	6121                	addi	sp,sp,64
 520:	8082                	ret
    x = -xx;
 522:	40b005bb          	negw	a1,a1
    neg = 1;
 526:	4885                	li	a7,1
    x = -xx;
 528:	bf8d                	j	49a <printint+0x1a>

000000000000052a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 52a:	7119                	addi	sp,sp,-128
 52c:	fc86                	sd	ra,120(sp)
 52e:	f8a2                	sd	s0,112(sp)
 530:	f4a6                	sd	s1,104(sp)
 532:	f0ca                	sd	s2,96(sp)
 534:	ecce                	sd	s3,88(sp)
 536:	e8d2                	sd	s4,80(sp)
 538:	e4d6                	sd	s5,72(sp)
 53a:	e0da                	sd	s6,64(sp)
 53c:	fc5e                	sd	s7,56(sp)
 53e:	f862                	sd	s8,48(sp)
 540:	f466                	sd	s9,40(sp)
 542:	f06a                	sd	s10,32(sp)
 544:	ec6e                	sd	s11,24(sp)
 546:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 548:	0005c903          	lbu	s2,0(a1)
 54c:	18090f63          	beqz	s2,6ea <vprintf+0x1c0>
 550:	8aaa                	mv	s5,a0
 552:	8b32                	mv	s6,a2
 554:	00158493          	addi	s1,a1,1
  state = 0;
 558:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 55a:	02500a13          	li	s4,37
      if(c == 'd'){
 55e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 562:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 566:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 56a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 56e:	00000b97          	auipc	s7,0x0
 572:	41ab8b93          	addi	s7,s7,1050 # 988 <digits>
 576:	a839                	j	594 <vprintf+0x6a>
        putc(fd, c);
 578:	85ca                	mv	a1,s2
 57a:	8556                	mv	a0,s5
 57c:	00000097          	auipc	ra,0x0
 580:	ee2080e7          	jalr	-286(ra) # 45e <putc>
 584:	a019                	j	58a <vprintf+0x60>
    } else if(state == '%'){
 586:	01498f63          	beq	s3,s4,5a4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 58a:	0485                	addi	s1,s1,1
 58c:	fff4c903          	lbu	s2,-1(s1)
 590:	14090d63          	beqz	s2,6ea <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 594:	0009079b          	sext.w	a5,s2
    if(state == 0){
 598:	fe0997e3          	bnez	s3,586 <vprintf+0x5c>
      if(c == '%'){
 59c:	fd479ee3          	bne	a5,s4,578 <vprintf+0x4e>
        state = '%';
 5a0:	89be                	mv	s3,a5
 5a2:	b7e5                	j	58a <vprintf+0x60>
      if(c == 'd'){
 5a4:	05878063          	beq	a5,s8,5e4 <vprintf+0xba>
      } else if(c == 'l') {
 5a8:	05978c63          	beq	a5,s9,600 <vprintf+0xd6>
      } else if(c == 'x') {
 5ac:	07a78863          	beq	a5,s10,61c <vprintf+0xf2>
      } else if(c == 'p') {
 5b0:	09b78463          	beq	a5,s11,638 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5b4:	07300713          	li	a4,115
 5b8:	0ce78663          	beq	a5,a4,684 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5bc:	06300713          	li	a4,99
 5c0:	0ee78e63          	beq	a5,a4,6bc <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5c4:	11478863          	beq	a5,s4,6d4 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5c8:	85d2                	mv	a1,s4
 5ca:	8556                	mv	a0,s5
 5cc:	00000097          	auipc	ra,0x0
 5d0:	e92080e7          	jalr	-366(ra) # 45e <putc>
        putc(fd, c);
 5d4:	85ca                	mv	a1,s2
 5d6:	8556                	mv	a0,s5
 5d8:	00000097          	auipc	ra,0x0
 5dc:	e86080e7          	jalr	-378(ra) # 45e <putc>
      }
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	b765                	j	58a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5e4:	008b0913          	addi	s2,s6,8
 5e8:	4685                	li	a3,1
 5ea:	4629                	li	a2,10
 5ec:	000b2583          	lw	a1,0(s6)
 5f0:	8556                	mv	a0,s5
 5f2:	00000097          	auipc	ra,0x0
 5f6:	e8e080e7          	jalr	-370(ra) # 480 <printint>
 5fa:	8b4a                	mv	s6,s2
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	b771                	j	58a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 600:	008b0913          	addi	s2,s6,8
 604:	4681                	li	a3,0
 606:	4629                	li	a2,10
 608:	000b2583          	lw	a1,0(s6)
 60c:	8556                	mv	a0,s5
 60e:	00000097          	auipc	ra,0x0
 612:	e72080e7          	jalr	-398(ra) # 480 <printint>
 616:	8b4a                	mv	s6,s2
      state = 0;
 618:	4981                	li	s3,0
 61a:	bf85                	j	58a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 61c:	008b0913          	addi	s2,s6,8
 620:	4681                	li	a3,0
 622:	4641                	li	a2,16
 624:	000b2583          	lw	a1,0(s6)
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	e56080e7          	jalr	-426(ra) # 480 <printint>
 632:	8b4a                	mv	s6,s2
      state = 0;
 634:	4981                	li	s3,0
 636:	bf91                	j	58a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 638:	008b0793          	addi	a5,s6,8
 63c:	f8f43423          	sd	a5,-120(s0)
 640:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 644:	03000593          	li	a1,48
 648:	8556                	mv	a0,s5
 64a:	00000097          	auipc	ra,0x0
 64e:	e14080e7          	jalr	-492(ra) # 45e <putc>
  putc(fd, 'x');
 652:	85ea                	mv	a1,s10
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	e08080e7          	jalr	-504(ra) # 45e <putc>
 65e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 660:	03c9d793          	srli	a5,s3,0x3c
 664:	97de                	add	a5,a5,s7
 666:	0007c583          	lbu	a1,0(a5)
 66a:	8556                	mv	a0,s5
 66c:	00000097          	auipc	ra,0x0
 670:	df2080e7          	jalr	-526(ra) # 45e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 674:	0992                	slli	s3,s3,0x4
 676:	397d                	addiw	s2,s2,-1
 678:	fe0914e3          	bnez	s2,660 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 67c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 680:	4981                	li	s3,0
 682:	b721                	j	58a <vprintf+0x60>
        s = va_arg(ap, char*);
 684:	008b0993          	addi	s3,s6,8
 688:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 68c:	02090163          	beqz	s2,6ae <vprintf+0x184>
        while(*s != 0){
 690:	00094583          	lbu	a1,0(s2)
 694:	c9a1                	beqz	a1,6e4 <vprintf+0x1ba>
          putc(fd, *s);
 696:	8556                	mv	a0,s5
 698:	00000097          	auipc	ra,0x0
 69c:	dc6080e7          	jalr	-570(ra) # 45e <putc>
          s++;
 6a0:	0905                	addi	s2,s2,1
        while(*s != 0){
 6a2:	00094583          	lbu	a1,0(s2)
 6a6:	f9e5                	bnez	a1,696 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6a8:	8b4e                	mv	s6,s3
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	bdf9                	j	58a <vprintf+0x60>
          s = "(null)";
 6ae:	00000917          	auipc	s2,0x0
 6b2:	2d290913          	addi	s2,s2,722 # 980 <malloc+0x18c>
        while(*s != 0){
 6b6:	02800593          	li	a1,40
 6ba:	bff1                	j	696 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6bc:	008b0913          	addi	s2,s6,8
 6c0:	000b4583          	lbu	a1,0(s6)
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	d98080e7          	jalr	-616(ra) # 45e <putc>
 6ce:	8b4a                	mv	s6,s2
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	bd65                	j	58a <vprintf+0x60>
        putc(fd, c);
 6d4:	85d2                	mv	a1,s4
 6d6:	8556                	mv	a0,s5
 6d8:	00000097          	auipc	ra,0x0
 6dc:	d86080e7          	jalr	-634(ra) # 45e <putc>
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	b565                	j	58a <vprintf+0x60>
        s = va_arg(ap, char*);
 6e4:	8b4e                	mv	s6,s3
      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	b54d                	j	58a <vprintf+0x60>
    }
  }
}
 6ea:	70e6                	ld	ra,120(sp)
 6ec:	7446                	ld	s0,112(sp)
 6ee:	74a6                	ld	s1,104(sp)
 6f0:	7906                	ld	s2,96(sp)
 6f2:	69e6                	ld	s3,88(sp)
 6f4:	6a46                	ld	s4,80(sp)
 6f6:	6aa6                	ld	s5,72(sp)
 6f8:	6b06                	ld	s6,64(sp)
 6fa:	7be2                	ld	s7,56(sp)
 6fc:	7c42                	ld	s8,48(sp)
 6fe:	7ca2                	ld	s9,40(sp)
 700:	7d02                	ld	s10,32(sp)
 702:	6de2                	ld	s11,24(sp)
 704:	6109                	addi	sp,sp,128
 706:	8082                	ret

0000000000000708 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 708:	715d                	addi	sp,sp,-80
 70a:	ec06                	sd	ra,24(sp)
 70c:	e822                	sd	s0,16(sp)
 70e:	1000                	addi	s0,sp,32
 710:	e010                	sd	a2,0(s0)
 712:	e414                	sd	a3,8(s0)
 714:	e818                	sd	a4,16(s0)
 716:	ec1c                	sd	a5,24(s0)
 718:	03043023          	sd	a6,32(s0)
 71c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 720:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 724:	8622                	mv	a2,s0
 726:	00000097          	auipc	ra,0x0
 72a:	e04080e7          	jalr	-508(ra) # 52a <vprintf>
}
 72e:	60e2                	ld	ra,24(sp)
 730:	6442                	ld	s0,16(sp)
 732:	6161                	addi	sp,sp,80
 734:	8082                	ret

0000000000000736 <printf>:

void
printf(const char *fmt, ...)
{
 736:	711d                	addi	sp,sp,-96
 738:	ec06                	sd	ra,24(sp)
 73a:	e822                	sd	s0,16(sp)
 73c:	1000                	addi	s0,sp,32
 73e:	e40c                	sd	a1,8(s0)
 740:	e810                	sd	a2,16(s0)
 742:	ec14                	sd	a3,24(s0)
 744:	f018                	sd	a4,32(s0)
 746:	f41c                	sd	a5,40(s0)
 748:	03043823          	sd	a6,48(s0)
 74c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 750:	00840613          	addi	a2,s0,8
 754:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 758:	85aa                	mv	a1,a0
 75a:	4505                	li	a0,1
 75c:	00000097          	auipc	ra,0x0
 760:	dce080e7          	jalr	-562(ra) # 52a <vprintf>
}
 764:	60e2                	ld	ra,24(sp)
 766:	6442                	ld	s0,16(sp)
 768:	6125                	addi	sp,sp,96
 76a:	8082                	ret

000000000000076c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 76c:	1141                	addi	sp,sp,-16
 76e:	e422                	sd	s0,8(sp)
 770:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 772:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 776:	00001797          	auipc	a5,0x1
 77a:	89a7b783          	ld	a5,-1894(a5) # 1010 <freep>
 77e:	a805                	j	7ae <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 780:	4618                	lw	a4,8(a2)
 782:	9db9                	addw	a1,a1,a4
 784:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 788:	6398                	ld	a4,0(a5)
 78a:	6318                	ld	a4,0(a4)
 78c:	fee53823          	sd	a4,-16(a0)
 790:	a091                	j	7d4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 792:	ff852703          	lw	a4,-8(a0)
 796:	9e39                	addw	a2,a2,a4
 798:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 79a:	ff053703          	ld	a4,-16(a0)
 79e:	e398                	sd	a4,0(a5)
 7a0:	a099                	j	7e6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a2:	6398                	ld	a4,0(a5)
 7a4:	00e7e463          	bltu	a5,a4,7ac <free+0x40>
 7a8:	00e6ea63          	bltu	a3,a4,7bc <free+0x50>
{
 7ac:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ae:	fed7fae3          	bgeu	a5,a3,7a2 <free+0x36>
 7b2:	6398                	ld	a4,0(a5)
 7b4:	00e6e463          	bltu	a3,a4,7bc <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b8:	fee7eae3          	bltu	a5,a4,7ac <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7bc:	ff852583          	lw	a1,-8(a0)
 7c0:	6390                	ld	a2,0(a5)
 7c2:	02059713          	slli	a4,a1,0x20
 7c6:	9301                	srli	a4,a4,0x20
 7c8:	0712                	slli	a4,a4,0x4
 7ca:	9736                	add	a4,a4,a3
 7cc:	fae60ae3          	beq	a2,a4,780 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7d0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7d4:	4790                	lw	a2,8(a5)
 7d6:	02061713          	slli	a4,a2,0x20
 7da:	9301                	srli	a4,a4,0x20
 7dc:	0712                	slli	a4,a4,0x4
 7de:	973e                	add	a4,a4,a5
 7e0:	fae689e3          	beq	a3,a4,792 <free+0x26>
  } else
    p->s.ptr = bp;
 7e4:	e394                	sd	a3,0(a5)
  freep = p;
 7e6:	00001717          	auipc	a4,0x1
 7ea:	82f73523          	sd	a5,-2006(a4) # 1010 <freep>
}
 7ee:	6422                	ld	s0,8(sp)
 7f0:	0141                	addi	sp,sp,16
 7f2:	8082                	ret

00000000000007f4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7f4:	7139                	addi	sp,sp,-64
 7f6:	fc06                	sd	ra,56(sp)
 7f8:	f822                	sd	s0,48(sp)
 7fa:	f426                	sd	s1,40(sp)
 7fc:	f04a                	sd	s2,32(sp)
 7fe:	ec4e                	sd	s3,24(sp)
 800:	e852                	sd	s4,16(sp)
 802:	e456                	sd	s5,8(sp)
 804:	e05a                	sd	s6,0(sp)
 806:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 808:	02051493          	slli	s1,a0,0x20
 80c:	9081                	srli	s1,s1,0x20
 80e:	04bd                	addi	s1,s1,15
 810:	8091                	srli	s1,s1,0x4
 812:	0014899b          	addiw	s3,s1,1
 816:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 818:	00000517          	auipc	a0,0x0
 81c:	7f853503          	ld	a0,2040(a0) # 1010 <freep>
 820:	c515                	beqz	a0,84c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 822:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 824:	4798                	lw	a4,8(a5)
 826:	02977f63          	bgeu	a4,s1,864 <malloc+0x70>
 82a:	8a4e                	mv	s4,s3
 82c:	0009871b          	sext.w	a4,s3
 830:	6685                	lui	a3,0x1
 832:	00d77363          	bgeu	a4,a3,838 <malloc+0x44>
 836:	6a05                	lui	s4,0x1
 838:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 83c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 840:	00000917          	auipc	s2,0x0
 844:	7d090913          	addi	s2,s2,2000 # 1010 <freep>
  if(p == (char*)-1)
 848:	5afd                	li	s5,-1
 84a:	a88d                	j	8bc <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 84c:	00000797          	auipc	a5,0x0
 850:	7d478793          	addi	a5,a5,2004 # 1020 <base>
 854:	00000717          	auipc	a4,0x0
 858:	7af73e23          	sd	a5,1980(a4) # 1010 <freep>
 85c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 85e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 862:	b7e1                	j	82a <malloc+0x36>
      if(p->s.size == nunits)
 864:	02e48b63          	beq	s1,a4,89a <malloc+0xa6>
        p->s.size -= nunits;
 868:	4137073b          	subw	a4,a4,s3
 86c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 86e:	1702                	slli	a4,a4,0x20
 870:	9301                	srli	a4,a4,0x20
 872:	0712                	slli	a4,a4,0x4
 874:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 876:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 87a:	00000717          	auipc	a4,0x0
 87e:	78a73b23          	sd	a0,1942(a4) # 1010 <freep>
      return (void*)(p + 1);
 882:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 886:	70e2                	ld	ra,56(sp)
 888:	7442                	ld	s0,48(sp)
 88a:	74a2                	ld	s1,40(sp)
 88c:	7902                	ld	s2,32(sp)
 88e:	69e2                	ld	s3,24(sp)
 890:	6a42                	ld	s4,16(sp)
 892:	6aa2                	ld	s5,8(sp)
 894:	6b02                	ld	s6,0(sp)
 896:	6121                	addi	sp,sp,64
 898:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 89a:	6398                	ld	a4,0(a5)
 89c:	e118                	sd	a4,0(a0)
 89e:	bff1                	j	87a <malloc+0x86>
  hp->s.size = nu;
 8a0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8a4:	0541                	addi	a0,a0,16
 8a6:	00000097          	auipc	ra,0x0
 8aa:	ec6080e7          	jalr	-314(ra) # 76c <free>
  return freep;
 8ae:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8b2:	d971                	beqz	a0,886 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b6:	4798                	lw	a4,8(a5)
 8b8:	fa9776e3          	bgeu	a4,s1,864 <malloc+0x70>
    if(p == freep)
 8bc:	00093703          	ld	a4,0(s2)
 8c0:	853e                	mv	a0,a5
 8c2:	fef719e3          	bne	a4,a5,8b4 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8c6:	8552                	mv	a0,s4
 8c8:	00000097          	auipc	ra,0x0
 8cc:	b6e080e7          	jalr	-1170(ra) # 436 <sbrk>
  if(p == (char*)-1)
 8d0:	fd5518e3          	bne	a0,s5,8a0 <malloc+0xac>
        return 0;
 8d4:	4501                	li	a0,0
 8d6:	bf45                	j	886 <malloc+0x92>
