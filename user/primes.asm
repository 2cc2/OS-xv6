
user/_primes：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <get_prime>:
#include "kernel/types.h"
#include "user/user.h"

// 获取素数函数
void get_prime(int p1[2])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	0080                	addi	s0,sp,64
   a:	84aa                	mv	s1,a0
    // 关闭写端
    close(p1[1]);
   c:	4148                	lw	a0,4(a0)
   e:	00000097          	auipc	ra,0x0
  12:	412080e7          	jalr	1042(ra) # 420 <close>
    int n;
    // 从管道读取一个整数
    if (!read(p1[0], &n, sizeof(n)))
  16:	4611                	li	a2,4
  18:	fdc40593          	addi	a1,s0,-36
  1c:	4088                	lw	a0,0(s1)
  1e:	00000097          	auipc	ra,0x0
  22:	3f2080e7          	jalr	1010(ra) # 410 <read>
  26:	e919                	bnez	a0,3c <get_prime+0x3c>
    {   
        // 管道中无数据，退出进程
        close(p1[0]);
  28:	4088                	lw	a0,0(s1)
  2a:	00000097          	auipc	ra,0x0
  2e:	3f6080e7          	jalr	1014(ra) # 420 <close>
        exit(0);
  32:	4501                	li	a0,0
  34:	00000097          	auipc	ra,0x0
  38:	3c4080e7          	jalr	964(ra) # 3f8 <exit>
    }

    // 打印素数
    printf("prime %d\n", n);
  3c:	fdc42583          	lw	a1,-36(s0)
  40:	00001517          	auipc	a0,0x1
  44:	8f050513          	addi	a0,a0,-1808 # 930 <malloc+0xf2>
  48:	00000097          	auipc	ra,0x0
  4c:	738080e7          	jalr	1848(ra) # 780 <printf>

    // 创建新的管道
    int p2[2];
    pipe(p2);
  50:	fd040513          	addi	a0,s0,-48
  54:	00000097          	auipc	ra,0x0
  58:	3b4080e7          	jalr	948(ra) # 408 <pipe>

    // 创建子进程
    int pid = fork();
  5c:	00000097          	auipc	ra,0x0
  60:	394080e7          	jalr	916(ra) # 3f0 <fork>
    if (!pid)
  64:	cd0d                	beqz	a0,9e <get_prime+0x9e>
        get_prime(p2); // 子进程递归调用获取素数函数
    else if (pid > 0)
  66:	06a05d63          	blez	a0,e0 <get_prime+0xe0>
    {
        // 父进程
        int m;
        // 从管道读取数据，筛掉n的倍数
        while (read(p1[0], &m, sizeof(m)))
  6a:	4611                	li	a2,4
  6c:	fcc40593          	addi	a1,s0,-52
  70:	4088                	lw	a0,0(s1)
  72:	00000097          	auipc	ra,0x0
  76:	39e080e7          	jalr	926(ra) # 410 <read>
  7a:	c905                	beqz	a0,aa <get_prime+0xaa>
        {
            if (m % n)
  7c:	fcc42783          	lw	a5,-52(s0)
  80:	fdc42703          	lw	a4,-36(s0)
  84:	02e7e7bb          	remw	a5,a5,a4
  88:	d3ed                	beqz	a5,6a <get_prime+0x6a>
                write(p2[1], &m, sizeof(m));
  8a:	4611                	li	a2,4
  8c:	fcc40593          	addi	a1,s0,-52
  90:	fd442503          	lw	a0,-44(s0)
  94:	00000097          	auipc	ra,0x0
  98:	384080e7          	jalr	900(ra) # 418 <write>
  9c:	b7f9                	j	6a <get_prime+0x6a>
        get_prime(p2); // 子进程递归调用获取素数函数
  9e:	fd040513          	addi	a0,s0,-48
  a2:	00000097          	auipc	ra,0x0
  a6:	f5e080e7          	jalr	-162(ra) # 0 <get_prime>
        }
        // 关闭管道
        close(p1[0]);
  aa:	4088                	lw	a0,0(s1)
  ac:	00000097          	auipc	ra,0x0
  b0:	374080e7          	jalr	884(ra) # 420 <close>
        close(p2[1]);
  b4:	fd442503          	lw	a0,-44(s0)
  b8:	00000097          	auipc	ra,0x0
  bc:	368080e7          	jalr	872(ra) # 420 <close>
        close(p2[0]);
  c0:	fd042503          	lw	a0,-48(s0)
  c4:	00000097          	auipc	ra,0x0
  c8:	35c080e7          	jalr	860(ra) # 420 <close>
        // 回收子进程
        wait(0);
  cc:	4501                	li	a0,0
  ce:	00000097          	auipc	ra,0x0
  d2:	332080e7          	jalr	818(ra) # 400 <wait>
    {
        // fork失败
        fprintf(2, "fork error\n");
        exit(1);
    }
    exit(0);
  d6:	4501                	li	a0,0
  d8:	00000097          	auipc	ra,0x0
  dc:	320080e7          	jalr	800(ra) # 3f8 <exit>
        fprintf(2, "fork error\n");
  e0:	00001597          	auipc	a1,0x1
  e4:	86058593          	addi	a1,a1,-1952 # 940 <malloc+0x102>
  e8:	4509                	li	a0,2
  ea:	00000097          	auipc	ra,0x0
  ee:	668080e7          	jalr	1640(ra) # 752 <fprintf>
        exit(1);
  f2:	4505                	li	a0,1
  f4:	00000097          	auipc	ra,0x0
  f8:	304080e7          	jalr	772(ra) # 3f8 <exit>

00000000000000fc <main>:
}

int main()
{
  fc:	7179                	addi	sp,sp,-48
  fe:	f406                	sd	ra,40(sp)
 100:	f022                	sd	s0,32(sp)
 102:	ec26                	sd	s1,24(sp)
 104:	1800                	addi	s0,sp,48
    int p[2];
    // 创建管道
    pipe(p);
 106:	fd840513          	addi	a0,s0,-40
 10a:	00000097          	auipc	ra,0x0
 10e:	2fe080e7          	jalr	766(ra) # 408 <pipe>

    // 将数字2~35写入管道
    for (int i = 2; i <= 35; i++)
 112:	4789                	li	a5,2
 114:	fcf42a23          	sw	a5,-44(s0)
 118:	02300493          	li	s1,35
        write(p[1], &i, sizeof(i));
 11c:	4611                	li	a2,4
 11e:	fd440593          	addi	a1,s0,-44
 122:	fdc42503          	lw	a0,-36(s0)
 126:	00000097          	auipc	ra,0x0
 12a:	2f2080e7          	jalr	754(ra) # 418 <write>
    for (int i = 2; i <= 35; i++)
 12e:	fd442783          	lw	a5,-44(s0)
 132:	2785                	addiw	a5,a5,1
 134:	0007871b          	sext.w	a4,a5
 138:	fcf42a23          	sw	a5,-44(s0)
 13c:	fee4d0e3          	bge	s1,a4,11c <main+0x20>
    close(p[1]);
 140:	fdc42503          	lw	a0,-36(s0)
 144:	00000097          	auipc	ra,0x0
 148:	2dc080e7          	jalr	732(ra) # 420 <close>
    // 获取素数
    get_prime(p);
 14c:	fd840513          	addi	a0,s0,-40
 150:	00000097          	auipc	ra,0x0
 154:	eb0080e7          	jalr	-336(ra) # 0 <get_prime>

0000000000000158 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 158:	1141                	addi	sp,sp,-16
 15a:	e406                	sd	ra,8(sp)
 15c:	e022                	sd	s0,0(sp)
 15e:	0800                	addi	s0,sp,16
  extern int main();
  main();
 160:	00000097          	auipc	ra,0x0
 164:	f9c080e7          	jalr	-100(ra) # fc <main>
  exit(0);
 168:	4501                	li	a0,0
 16a:	00000097          	auipc	ra,0x0
 16e:	28e080e7          	jalr	654(ra) # 3f8 <exit>

0000000000000172 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 172:	1141                	addi	sp,sp,-16
 174:	e422                	sd	s0,8(sp)
 176:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 178:	87aa                	mv	a5,a0
 17a:	0585                	addi	a1,a1,1
 17c:	0785                	addi	a5,a5,1
 17e:	fff5c703          	lbu	a4,-1(a1)
 182:	fee78fa3          	sb	a4,-1(a5)
 186:	fb75                	bnez	a4,17a <strcpy+0x8>
    ;
  return os;
}
 188:	6422                	ld	s0,8(sp)
 18a:	0141                	addi	sp,sp,16
 18c:	8082                	ret

000000000000018e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 18e:	1141                	addi	sp,sp,-16
 190:	e422                	sd	s0,8(sp)
 192:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 194:	00054783          	lbu	a5,0(a0)
 198:	cb91                	beqz	a5,1ac <strcmp+0x1e>
 19a:	0005c703          	lbu	a4,0(a1)
 19e:	00f71763          	bne	a4,a5,1ac <strcmp+0x1e>
    p++, q++;
 1a2:	0505                	addi	a0,a0,1
 1a4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1a6:	00054783          	lbu	a5,0(a0)
 1aa:	fbe5                	bnez	a5,19a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1ac:	0005c503          	lbu	a0,0(a1)
}
 1b0:	40a7853b          	subw	a0,a5,a0
 1b4:	6422                	ld	s0,8(sp)
 1b6:	0141                	addi	sp,sp,16
 1b8:	8082                	ret

00000000000001ba <strlen>:

uint
strlen(const char *s)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1c0:	00054783          	lbu	a5,0(a0)
 1c4:	cf91                	beqz	a5,1e0 <strlen+0x26>
 1c6:	0505                	addi	a0,a0,1
 1c8:	87aa                	mv	a5,a0
 1ca:	4685                	li	a3,1
 1cc:	9e89                	subw	a3,a3,a0
 1ce:	00f6853b          	addw	a0,a3,a5
 1d2:	0785                	addi	a5,a5,1
 1d4:	fff7c703          	lbu	a4,-1(a5)
 1d8:	fb7d                	bnez	a4,1ce <strlen+0x14>
    ;
  return n;
}
 1da:	6422                	ld	s0,8(sp)
 1dc:	0141                	addi	sp,sp,16
 1de:	8082                	ret
  for(n = 0; s[n]; n++)
 1e0:	4501                	li	a0,0
 1e2:	bfe5                	j	1da <strlen+0x20>

00000000000001e4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e422                	sd	s0,8(sp)
 1e8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1ea:	ce09                	beqz	a2,204 <memset+0x20>
 1ec:	87aa                	mv	a5,a0
 1ee:	fff6071b          	addiw	a4,a2,-1
 1f2:	1702                	slli	a4,a4,0x20
 1f4:	9301                	srli	a4,a4,0x20
 1f6:	0705                	addi	a4,a4,1
 1f8:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1fa:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1fe:	0785                	addi	a5,a5,1
 200:	fee79de3          	bne	a5,a4,1fa <memset+0x16>
  }
  return dst;
}
 204:	6422                	ld	s0,8(sp)
 206:	0141                	addi	sp,sp,16
 208:	8082                	ret

000000000000020a <strchr>:

char*
strchr(const char *s, char c)
{
 20a:	1141                	addi	sp,sp,-16
 20c:	e422                	sd	s0,8(sp)
 20e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 210:	00054783          	lbu	a5,0(a0)
 214:	cb99                	beqz	a5,22a <strchr+0x20>
    if(*s == c)
 216:	00f58763          	beq	a1,a5,224 <strchr+0x1a>
  for(; *s; s++)
 21a:	0505                	addi	a0,a0,1
 21c:	00054783          	lbu	a5,0(a0)
 220:	fbfd                	bnez	a5,216 <strchr+0xc>
      return (char*)s;
  return 0;
 222:	4501                	li	a0,0
}
 224:	6422                	ld	s0,8(sp)
 226:	0141                	addi	sp,sp,16
 228:	8082                	ret
  return 0;
 22a:	4501                	li	a0,0
 22c:	bfe5                	j	224 <strchr+0x1a>

000000000000022e <gets>:

char*
gets(char *buf, int max)
{
 22e:	711d                	addi	sp,sp,-96
 230:	ec86                	sd	ra,88(sp)
 232:	e8a2                	sd	s0,80(sp)
 234:	e4a6                	sd	s1,72(sp)
 236:	e0ca                	sd	s2,64(sp)
 238:	fc4e                	sd	s3,56(sp)
 23a:	f852                	sd	s4,48(sp)
 23c:	f456                	sd	s5,40(sp)
 23e:	f05a                	sd	s6,32(sp)
 240:	ec5e                	sd	s7,24(sp)
 242:	1080                	addi	s0,sp,96
 244:	8baa                	mv	s7,a0
 246:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 248:	892a                	mv	s2,a0
 24a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 24c:	4aa9                	li	s5,10
 24e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 250:	89a6                	mv	s3,s1
 252:	2485                	addiw	s1,s1,1
 254:	0344d863          	bge	s1,s4,284 <gets+0x56>
    cc = read(0, &c, 1);
 258:	4605                	li	a2,1
 25a:	faf40593          	addi	a1,s0,-81
 25e:	4501                	li	a0,0
 260:	00000097          	auipc	ra,0x0
 264:	1b0080e7          	jalr	432(ra) # 410 <read>
    if(cc < 1)
 268:	00a05e63          	blez	a0,284 <gets+0x56>
    buf[i++] = c;
 26c:	faf44783          	lbu	a5,-81(s0)
 270:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 274:	01578763          	beq	a5,s5,282 <gets+0x54>
 278:	0905                	addi	s2,s2,1
 27a:	fd679be3          	bne	a5,s6,250 <gets+0x22>
  for(i=0; i+1 < max; ){
 27e:	89a6                	mv	s3,s1
 280:	a011                	j	284 <gets+0x56>
 282:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 284:	99de                	add	s3,s3,s7
 286:	00098023          	sb	zero,0(s3)
  return buf;
}
 28a:	855e                	mv	a0,s7
 28c:	60e6                	ld	ra,88(sp)
 28e:	6446                	ld	s0,80(sp)
 290:	64a6                	ld	s1,72(sp)
 292:	6906                	ld	s2,64(sp)
 294:	79e2                	ld	s3,56(sp)
 296:	7a42                	ld	s4,48(sp)
 298:	7aa2                	ld	s5,40(sp)
 29a:	7b02                	ld	s6,32(sp)
 29c:	6be2                	ld	s7,24(sp)
 29e:	6125                	addi	sp,sp,96
 2a0:	8082                	ret

00000000000002a2 <stat>:

int
stat(const char *n, struct stat *st)
{
 2a2:	1101                	addi	sp,sp,-32
 2a4:	ec06                	sd	ra,24(sp)
 2a6:	e822                	sd	s0,16(sp)
 2a8:	e426                	sd	s1,8(sp)
 2aa:	e04a                	sd	s2,0(sp)
 2ac:	1000                	addi	s0,sp,32
 2ae:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b0:	4581                	li	a1,0
 2b2:	00000097          	auipc	ra,0x0
 2b6:	186080e7          	jalr	390(ra) # 438 <open>
  if(fd < 0)
 2ba:	02054563          	bltz	a0,2e4 <stat+0x42>
 2be:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c0:	85ca                	mv	a1,s2
 2c2:	00000097          	auipc	ra,0x0
 2c6:	18e080e7          	jalr	398(ra) # 450 <fstat>
 2ca:	892a                	mv	s2,a0
  close(fd);
 2cc:	8526                	mv	a0,s1
 2ce:	00000097          	auipc	ra,0x0
 2d2:	152080e7          	jalr	338(ra) # 420 <close>
  return r;
}
 2d6:	854a                	mv	a0,s2
 2d8:	60e2                	ld	ra,24(sp)
 2da:	6442                	ld	s0,16(sp)
 2dc:	64a2                	ld	s1,8(sp)
 2de:	6902                	ld	s2,0(sp)
 2e0:	6105                	addi	sp,sp,32
 2e2:	8082                	ret
    return -1;
 2e4:	597d                	li	s2,-1
 2e6:	bfc5                	j	2d6 <stat+0x34>

00000000000002e8 <atoi>:

int
atoi(const char *s)
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e422                	sd	s0,8(sp)
 2ec:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ee:	00054603          	lbu	a2,0(a0)
 2f2:	fd06079b          	addiw	a5,a2,-48
 2f6:	0ff7f793          	andi	a5,a5,255
 2fa:	4725                	li	a4,9
 2fc:	02f76963          	bltu	a4,a5,32e <atoi+0x46>
 300:	86aa                	mv	a3,a0
  n = 0;
 302:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 304:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 306:	0685                	addi	a3,a3,1
 308:	0025179b          	slliw	a5,a0,0x2
 30c:	9fa9                	addw	a5,a5,a0
 30e:	0017979b          	slliw	a5,a5,0x1
 312:	9fb1                	addw	a5,a5,a2
 314:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 318:	0006c603          	lbu	a2,0(a3)
 31c:	fd06071b          	addiw	a4,a2,-48
 320:	0ff77713          	andi	a4,a4,255
 324:	fee5f1e3          	bgeu	a1,a4,306 <atoi+0x1e>
  return n;
}
 328:	6422                	ld	s0,8(sp)
 32a:	0141                	addi	sp,sp,16
 32c:	8082                	ret
  n = 0;
 32e:	4501                	li	a0,0
 330:	bfe5                	j	328 <atoi+0x40>

0000000000000332 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 332:	1141                	addi	sp,sp,-16
 334:	e422                	sd	s0,8(sp)
 336:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 338:	02b57663          	bgeu	a0,a1,364 <memmove+0x32>
    while(n-- > 0)
 33c:	02c05163          	blez	a2,35e <memmove+0x2c>
 340:	fff6079b          	addiw	a5,a2,-1
 344:	1782                	slli	a5,a5,0x20
 346:	9381                	srli	a5,a5,0x20
 348:	0785                	addi	a5,a5,1
 34a:	97aa                	add	a5,a5,a0
  dst = vdst;
 34c:	872a                	mv	a4,a0
      *dst++ = *src++;
 34e:	0585                	addi	a1,a1,1
 350:	0705                	addi	a4,a4,1
 352:	fff5c683          	lbu	a3,-1(a1)
 356:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 35a:	fee79ae3          	bne	a5,a4,34e <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 35e:	6422                	ld	s0,8(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret
    dst += n;
 364:	00c50733          	add	a4,a0,a2
    src += n;
 368:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 36a:	fec05ae3          	blez	a2,35e <memmove+0x2c>
 36e:	fff6079b          	addiw	a5,a2,-1
 372:	1782                	slli	a5,a5,0x20
 374:	9381                	srli	a5,a5,0x20
 376:	fff7c793          	not	a5,a5
 37a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 37c:	15fd                	addi	a1,a1,-1
 37e:	177d                	addi	a4,a4,-1
 380:	0005c683          	lbu	a3,0(a1)
 384:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 388:	fee79ae3          	bne	a5,a4,37c <memmove+0x4a>
 38c:	bfc9                	j	35e <memmove+0x2c>

000000000000038e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 38e:	1141                	addi	sp,sp,-16
 390:	e422                	sd	s0,8(sp)
 392:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 394:	ca05                	beqz	a2,3c4 <memcmp+0x36>
 396:	fff6069b          	addiw	a3,a2,-1
 39a:	1682                	slli	a3,a3,0x20
 39c:	9281                	srli	a3,a3,0x20
 39e:	0685                	addi	a3,a3,1
 3a0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3a2:	00054783          	lbu	a5,0(a0)
 3a6:	0005c703          	lbu	a4,0(a1)
 3aa:	00e79863          	bne	a5,a4,3ba <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3ae:	0505                	addi	a0,a0,1
    p2++;
 3b0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3b2:	fed518e3          	bne	a0,a3,3a2 <memcmp+0x14>
  }
  return 0;
 3b6:	4501                	li	a0,0
 3b8:	a019                	j	3be <memcmp+0x30>
      return *p1 - *p2;
 3ba:	40e7853b          	subw	a0,a5,a4
}
 3be:	6422                	ld	s0,8(sp)
 3c0:	0141                	addi	sp,sp,16
 3c2:	8082                	ret
  return 0;
 3c4:	4501                	li	a0,0
 3c6:	bfe5                	j	3be <memcmp+0x30>

00000000000003c8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3c8:	1141                	addi	sp,sp,-16
 3ca:	e406                	sd	ra,8(sp)
 3cc:	e022                	sd	s0,0(sp)
 3ce:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3d0:	00000097          	auipc	ra,0x0
 3d4:	f62080e7          	jalr	-158(ra) # 332 <memmove>
}
 3d8:	60a2                	ld	ra,8(sp)
 3da:	6402                	ld	s0,0(sp)
 3dc:	0141                	addi	sp,sp,16
 3de:	8082                	ret

00000000000003e0 <ugetpid>:
  int pid;  // Process ID
};

int
ugetpid(void)
{
 3e0:	1141                	addi	sp,sp,-16
 3e2:	e422                	sd	s0,8(sp)
 3e4:	0800                	addi	s0,sp,16
  struct usyscall *u = (struct usyscall *)USYSCALL;
  return u->pid;
}
 3e6:	00002503          	lw	a0,0(zero) # 0 <get_prime>
 3ea:	6422                	ld	s0,8(sp)
 3ec:	0141                	addi	sp,sp,16
 3ee:	8082                	ret

00000000000003f0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3f0:	4885                	li	a7,1
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3f8:	4889                	li	a7,2
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <wait>:
.global wait
wait:
 li a7, SYS_wait
 400:	488d                	li	a7,3
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 408:	4891                	li	a7,4
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <read>:
.global read
read:
 li a7, SYS_read
 410:	4895                	li	a7,5
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <write>:
.global write
write:
 li a7, SYS_write
 418:	48c1                	li	a7,16
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <close>:
.global close
close:
 li a7, SYS_close
 420:	48d5                	li	a7,21
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <kill>:
.global kill
kill:
 li a7, SYS_kill
 428:	4899                	li	a7,6
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <exec>:
.global exec
exec:
 li a7, SYS_exec
 430:	489d                	li	a7,7
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <open>:
.global open
open:
 li a7, SYS_open
 438:	48bd                	li	a7,15
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 440:	48c5                	li	a7,17
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 448:	48c9                	li	a7,18
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 450:	48a1                	li	a7,8
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <link>:
.global link
link:
 li a7, SYS_link
 458:	48cd                	li	a7,19
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 460:	48d1                	li	a7,20
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 468:	48a5                	li	a7,9
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <dup>:
.global dup
dup:
 li a7, SYS_dup
 470:	48a9                	li	a7,10
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 478:	48ad                	li	a7,11
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 480:	48b1                	li	a7,12
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 488:	48b5                	li	a7,13
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 490:	48b9                	li	a7,14
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <trace>:
.global trace
trace:
 li a7, SYS_trace
 498:	48d9                	li	a7,22
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <yield>:
.global yield
yield:
 li a7, SYS_yield
 4a0:	48dd                	li	a7,23
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
 4ba:	00000097          	auipc	ra,0x0
 4be:	f5e080e7          	jalr	-162(ra) # 418 <write>
}
 4c2:	60e2                	ld	ra,24(sp)
 4c4:	6442                	ld	s0,16(sp)
 4c6:	6105                	addi	sp,sp,32
 4c8:	8082                	ret

00000000000004ca <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4ca:	7139                	addi	sp,sp,-64
 4cc:	fc06                	sd	ra,56(sp)
 4ce:	f822                	sd	s0,48(sp)
 4d0:	f426                	sd	s1,40(sp)
 4d2:	f04a                	sd	s2,32(sp)
 4d4:	ec4e                	sd	s3,24(sp)
 4d6:	0080                	addi	s0,sp,64
 4d8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4da:	c299                	beqz	a3,4e0 <printint+0x16>
 4dc:	0805c863          	bltz	a1,56c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4e0:	2581                	sext.w	a1,a1
  neg = 0;
 4e2:	4881                	li	a7,0
 4e4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4e8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4ea:	2601                	sext.w	a2,a2
 4ec:	00000517          	auipc	a0,0x0
 4f0:	46c50513          	addi	a0,a0,1132 # 958 <digits>
 4f4:	883a                	mv	a6,a4
 4f6:	2705                	addiw	a4,a4,1
 4f8:	02c5f7bb          	remuw	a5,a1,a2
 4fc:	1782                	slli	a5,a5,0x20
 4fe:	9381                	srli	a5,a5,0x20
 500:	97aa                	add	a5,a5,a0
 502:	0007c783          	lbu	a5,0(a5)
 506:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 50a:	0005879b          	sext.w	a5,a1
 50e:	02c5d5bb          	divuw	a1,a1,a2
 512:	0685                	addi	a3,a3,1
 514:	fec7f0e3          	bgeu	a5,a2,4f4 <printint+0x2a>
  if(neg)
 518:	00088b63          	beqz	a7,52e <printint+0x64>
    buf[i++] = '-';
 51c:	fd040793          	addi	a5,s0,-48
 520:	973e                	add	a4,a4,a5
 522:	02d00793          	li	a5,45
 526:	fef70823          	sb	a5,-16(a4)
 52a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 52e:	02e05863          	blez	a4,55e <printint+0x94>
 532:	fc040793          	addi	a5,s0,-64
 536:	00e78933          	add	s2,a5,a4
 53a:	fff78993          	addi	s3,a5,-1
 53e:	99ba                	add	s3,s3,a4
 540:	377d                	addiw	a4,a4,-1
 542:	1702                	slli	a4,a4,0x20
 544:	9301                	srli	a4,a4,0x20
 546:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 54a:	fff94583          	lbu	a1,-1(s2)
 54e:	8526                	mv	a0,s1
 550:	00000097          	auipc	ra,0x0
 554:	f58080e7          	jalr	-168(ra) # 4a8 <putc>
  while(--i >= 0)
 558:	197d                	addi	s2,s2,-1
 55a:	ff3918e3          	bne	s2,s3,54a <printint+0x80>
}
 55e:	70e2                	ld	ra,56(sp)
 560:	7442                	ld	s0,48(sp)
 562:	74a2                	ld	s1,40(sp)
 564:	7902                	ld	s2,32(sp)
 566:	69e2                	ld	s3,24(sp)
 568:	6121                	addi	sp,sp,64
 56a:	8082                	ret
    x = -xx;
 56c:	40b005bb          	negw	a1,a1
    neg = 1;
 570:	4885                	li	a7,1
    x = -xx;
 572:	bf8d                	j	4e4 <printint+0x1a>

0000000000000574 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 574:	7119                	addi	sp,sp,-128
 576:	fc86                	sd	ra,120(sp)
 578:	f8a2                	sd	s0,112(sp)
 57a:	f4a6                	sd	s1,104(sp)
 57c:	f0ca                	sd	s2,96(sp)
 57e:	ecce                	sd	s3,88(sp)
 580:	e8d2                	sd	s4,80(sp)
 582:	e4d6                	sd	s5,72(sp)
 584:	e0da                	sd	s6,64(sp)
 586:	fc5e                	sd	s7,56(sp)
 588:	f862                	sd	s8,48(sp)
 58a:	f466                	sd	s9,40(sp)
 58c:	f06a                	sd	s10,32(sp)
 58e:	ec6e                	sd	s11,24(sp)
 590:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 592:	0005c903          	lbu	s2,0(a1)
 596:	18090f63          	beqz	s2,734 <vprintf+0x1c0>
 59a:	8aaa                	mv	s5,a0
 59c:	8b32                	mv	s6,a2
 59e:	00158493          	addi	s1,a1,1
  state = 0;
 5a2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5a4:	02500a13          	li	s4,37
      if(c == 'd'){
 5a8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5ac:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5b0:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5b4:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5b8:	00000b97          	auipc	s7,0x0
 5bc:	3a0b8b93          	addi	s7,s7,928 # 958 <digits>
 5c0:	a839                	j	5de <vprintf+0x6a>
        putc(fd, c);
 5c2:	85ca                	mv	a1,s2
 5c4:	8556                	mv	a0,s5
 5c6:	00000097          	auipc	ra,0x0
 5ca:	ee2080e7          	jalr	-286(ra) # 4a8 <putc>
 5ce:	a019                	j	5d4 <vprintf+0x60>
    } else if(state == '%'){
 5d0:	01498f63          	beq	s3,s4,5ee <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5d4:	0485                	addi	s1,s1,1
 5d6:	fff4c903          	lbu	s2,-1(s1)
 5da:	14090d63          	beqz	s2,734 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5de:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5e2:	fe0997e3          	bnez	s3,5d0 <vprintf+0x5c>
      if(c == '%'){
 5e6:	fd479ee3          	bne	a5,s4,5c2 <vprintf+0x4e>
        state = '%';
 5ea:	89be                	mv	s3,a5
 5ec:	b7e5                	j	5d4 <vprintf+0x60>
      if(c == 'd'){
 5ee:	05878063          	beq	a5,s8,62e <vprintf+0xba>
      } else if(c == 'l') {
 5f2:	05978c63          	beq	a5,s9,64a <vprintf+0xd6>
      } else if(c == 'x') {
 5f6:	07a78863          	beq	a5,s10,666 <vprintf+0xf2>
      } else if(c == 'p') {
 5fa:	09b78463          	beq	a5,s11,682 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5fe:	07300713          	li	a4,115
 602:	0ce78663          	beq	a5,a4,6ce <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 606:	06300713          	li	a4,99
 60a:	0ee78e63          	beq	a5,a4,706 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 60e:	11478863          	beq	a5,s4,71e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 612:	85d2                	mv	a1,s4
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	e92080e7          	jalr	-366(ra) # 4a8 <putc>
        putc(fd, c);
 61e:	85ca                	mv	a1,s2
 620:	8556                	mv	a0,s5
 622:	00000097          	auipc	ra,0x0
 626:	e86080e7          	jalr	-378(ra) # 4a8 <putc>
      }
      state = 0;
 62a:	4981                	li	s3,0
 62c:	b765                	j	5d4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 62e:	008b0913          	addi	s2,s6,8
 632:	4685                	li	a3,1
 634:	4629                	li	a2,10
 636:	000b2583          	lw	a1,0(s6)
 63a:	8556                	mv	a0,s5
 63c:	00000097          	auipc	ra,0x0
 640:	e8e080e7          	jalr	-370(ra) # 4ca <printint>
 644:	8b4a                	mv	s6,s2
      state = 0;
 646:	4981                	li	s3,0
 648:	b771                	j	5d4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 64a:	008b0913          	addi	s2,s6,8
 64e:	4681                	li	a3,0
 650:	4629                	li	a2,10
 652:	000b2583          	lw	a1,0(s6)
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	e72080e7          	jalr	-398(ra) # 4ca <printint>
 660:	8b4a                	mv	s6,s2
      state = 0;
 662:	4981                	li	s3,0
 664:	bf85                	j	5d4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 666:	008b0913          	addi	s2,s6,8
 66a:	4681                	li	a3,0
 66c:	4641                	li	a2,16
 66e:	000b2583          	lw	a1,0(s6)
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	e56080e7          	jalr	-426(ra) # 4ca <printint>
 67c:	8b4a                	mv	s6,s2
      state = 0;
 67e:	4981                	li	s3,0
 680:	bf91                	j	5d4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 682:	008b0793          	addi	a5,s6,8
 686:	f8f43423          	sd	a5,-120(s0)
 68a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 68e:	03000593          	li	a1,48
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	e14080e7          	jalr	-492(ra) # 4a8 <putc>
  putc(fd, 'x');
 69c:	85ea                	mv	a1,s10
 69e:	8556                	mv	a0,s5
 6a0:	00000097          	auipc	ra,0x0
 6a4:	e08080e7          	jalr	-504(ra) # 4a8 <putc>
 6a8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6aa:	03c9d793          	srli	a5,s3,0x3c
 6ae:	97de                	add	a5,a5,s7
 6b0:	0007c583          	lbu	a1,0(a5)
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	df2080e7          	jalr	-526(ra) # 4a8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6be:	0992                	slli	s3,s3,0x4
 6c0:	397d                	addiw	s2,s2,-1
 6c2:	fe0914e3          	bnez	s2,6aa <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6c6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	b721                	j	5d4 <vprintf+0x60>
        s = va_arg(ap, char*);
 6ce:	008b0993          	addi	s3,s6,8
 6d2:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6d6:	02090163          	beqz	s2,6f8 <vprintf+0x184>
        while(*s != 0){
 6da:	00094583          	lbu	a1,0(s2)
 6de:	c9a1                	beqz	a1,72e <vprintf+0x1ba>
          putc(fd, *s);
 6e0:	8556                	mv	a0,s5
 6e2:	00000097          	auipc	ra,0x0
 6e6:	dc6080e7          	jalr	-570(ra) # 4a8 <putc>
          s++;
 6ea:	0905                	addi	s2,s2,1
        while(*s != 0){
 6ec:	00094583          	lbu	a1,0(s2)
 6f0:	f9e5                	bnez	a1,6e0 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6f2:	8b4e                	mv	s6,s3
      state = 0;
 6f4:	4981                	li	s3,0
 6f6:	bdf9                	j	5d4 <vprintf+0x60>
          s = "(null)";
 6f8:	00000917          	auipc	s2,0x0
 6fc:	25890913          	addi	s2,s2,600 # 950 <malloc+0x112>
        while(*s != 0){
 700:	02800593          	li	a1,40
 704:	bff1                	j	6e0 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 706:	008b0913          	addi	s2,s6,8
 70a:	000b4583          	lbu	a1,0(s6)
 70e:	8556                	mv	a0,s5
 710:	00000097          	auipc	ra,0x0
 714:	d98080e7          	jalr	-616(ra) # 4a8 <putc>
 718:	8b4a                	mv	s6,s2
      state = 0;
 71a:	4981                	li	s3,0
 71c:	bd65                	j	5d4 <vprintf+0x60>
        putc(fd, c);
 71e:	85d2                	mv	a1,s4
 720:	8556                	mv	a0,s5
 722:	00000097          	auipc	ra,0x0
 726:	d86080e7          	jalr	-634(ra) # 4a8 <putc>
      state = 0;
 72a:	4981                	li	s3,0
 72c:	b565                	j	5d4 <vprintf+0x60>
        s = va_arg(ap, char*);
 72e:	8b4e                	mv	s6,s3
      state = 0;
 730:	4981                	li	s3,0
 732:	b54d                	j	5d4 <vprintf+0x60>
    }
  }
}
 734:	70e6                	ld	ra,120(sp)
 736:	7446                	ld	s0,112(sp)
 738:	74a6                	ld	s1,104(sp)
 73a:	7906                	ld	s2,96(sp)
 73c:	69e6                	ld	s3,88(sp)
 73e:	6a46                	ld	s4,80(sp)
 740:	6aa6                	ld	s5,72(sp)
 742:	6b06                	ld	s6,64(sp)
 744:	7be2                	ld	s7,56(sp)
 746:	7c42                	ld	s8,48(sp)
 748:	7ca2                	ld	s9,40(sp)
 74a:	7d02                	ld	s10,32(sp)
 74c:	6de2                	ld	s11,24(sp)
 74e:	6109                	addi	sp,sp,128
 750:	8082                	ret

0000000000000752 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 752:	715d                	addi	sp,sp,-80
 754:	ec06                	sd	ra,24(sp)
 756:	e822                	sd	s0,16(sp)
 758:	1000                	addi	s0,sp,32
 75a:	e010                	sd	a2,0(s0)
 75c:	e414                	sd	a3,8(s0)
 75e:	e818                	sd	a4,16(s0)
 760:	ec1c                	sd	a5,24(s0)
 762:	03043023          	sd	a6,32(s0)
 766:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 76a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 76e:	8622                	mv	a2,s0
 770:	00000097          	auipc	ra,0x0
 774:	e04080e7          	jalr	-508(ra) # 574 <vprintf>
}
 778:	60e2                	ld	ra,24(sp)
 77a:	6442                	ld	s0,16(sp)
 77c:	6161                	addi	sp,sp,80
 77e:	8082                	ret

0000000000000780 <printf>:

void
printf(const char *fmt, ...)
{
 780:	711d                	addi	sp,sp,-96
 782:	ec06                	sd	ra,24(sp)
 784:	e822                	sd	s0,16(sp)
 786:	1000                	addi	s0,sp,32
 788:	e40c                	sd	a1,8(s0)
 78a:	e810                	sd	a2,16(s0)
 78c:	ec14                	sd	a3,24(s0)
 78e:	f018                	sd	a4,32(s0)
 790:	f41c                	sd	a5,40(s0)
 792:	03043823          	sd	a6,48(s0)
 796:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 79a:	00840613          	addi	a2,s0,8
 79e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7a2:	85aa                	mv	a1,a0
 7a4:	4505                	li	a0,1
 7a6:	00000097          	auipc	ra,0x0
 7aa:	dce080e7          	jalr	-562(ra) # 574 <vprintf>
}
 7ae:	60e2                	ld	ra,24(sp)
 7b0:	6442                	ld	s0,16(sp)
 7b2:	6125                	addi	sp,sp,96
 7b4:	8082                	ret

00000000000007b6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b6:	1141                	addi	sp,sp,-16
 7b8:	e422                	sd	s0,8(sp)
 7ba:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7bc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c0:	00001797          	auipc	a5,0x1
 7c4:	8407b783          	ld	a5,-1984(a5) # 1000 <freep>
 7c8:	a805                	j	7f8 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ca:	4618                	lw	a4,8(a2)
 7cc:	9db9                	addw	a1,a1,a4
 7ce:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d2:	6398                	ld	a4,0(a5)
 7d4:	6318                	ld	a4,0(a4)
 7d6:	fee53823          	sd	a4,-16(a0)
 7da:	a091                	j	81e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7dc:	ff852703          	lw	a4,-8(a0)
 7e0:	9e39                	addw	a2,a2,a4
 7e2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7e4:	ff053703          	ld	a4,-16(a0)
 7e8:	e398                	sd	a4,0(a5)
 7ea:	a099                	j	830 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ec:	6398                	ld	a4,0(a5)
 7ee:	00e7e463          	bltu	a5,a4,7f6 <free+0x40>
 7f2:	00e6ea63          	bltu	a3,a4,806 <free+0x50>
{
 7f6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f8:	fed7fae3          	bgeu	a5,a3,7ec <free+0x36>
 7fc:	6398                	ld	a4,0(a5)
 7fe:	00e6e463          	bltu	a3,a4,806 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 802:	fee7eae3          	bltu	a5,a4,7f6 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 806:	ff852583          	lw	a1,-8(a0)
 80a:	6390                	ld	a2,0(a5)
 80c:	02059713          	slli	a4,a1,0x20
 810:	9301                	srli	a4,a4,0x20
 812:	0712                	slli	a4,a4,0x4
 814:	9736                	add	a4,a4,a3
 816:	fae60ae3          	beq	a2,a4,7ca <free+0x14>
    bp->s.ptr = p->s.ptr;
 81a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 81e:	4790                	lw	a2,8(a5)
 820:	02061713          	slli	a4,a2,0x20
 824:	9301                	srli	a4,a4,0x20
 826:	0712                	slli	a4,a4,0x4
 828:	973e                	add	a4,a4,a5
 82a:	fae689e3          	beq	a3,a4,7dc <free+0x26>
  } else
    p->s.ptr = bp;
 82e:	e394                	sd	a3,0(a5)
  freep = p;
 830:	00000717          	auipc	a4,0x0
 834:	7cf73823          	sd	a5,2000(a4) # 1000 <freep>
}
 838:	6422                	ld	s0,8(sp)
 83a:	0141                	addi	sp,sp,16
 83c:	8082                	ret

000000000000083e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 83e:	7139                	addi	sp,sp,-64
 840:	fc06                	sd	ra,56(sp)
 842:	f822                	sd	s0,48(sp)
 844:	f426                	sd	s1,40(sp)
 846:	f04a                	sd	s2,32(sp)
 848:	ec4e                	sd	s3,24(sp)
 84a:	e852                	sd	s4,16(sp)
 84c:	e456                	sd	s5,8(sp)
 84e:	e05a                	sd	s6,0(sp)
 850:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 852:	02051493          	slli	s1,a0,0x20
 856:	9081                	srli	s1,s1,0x20
 858:	04bd                	addi	s1,s1,15
 85a:	8091                	srli	s1,s1,0x4
 85c:	0014899b          	addiw	s3,s1,1
 860:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 862:	00000517          	auipc	a0,0x0
 866:	79e53503          	ld	a0,1950(a0) # 1000 <freep>
 86a:	c515                	beqz	a0,896 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 86c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 86e:	4798                	lw	a4,8(a5)
 870:	02977f63          	bgeu	a4,s1,8ae <malloc+0x70>
 874:	8a4e                	mv	s4,s3
 876:	0009871b          	sext.w	a4,s3
 87a:	6685                	lui	a3,0x1
 87c:	00d77363          	bgeu	a4,a3,882 <malloc+0x44>
 880:	6a05                	lui	s4,0x1
 882:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 886:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 88a:	00000917          	auipc	s2,0x0
 88e:	77690913          	addi	s2,s2,1910 # 1000 <freep>
  if(p == (char*)-1)
 892:	5afd                	li	s5,-1
 894:	a88d                	j	906 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 896:	00000797          	auipc	a5,0x0
 89a:	77a78793          	addi	a5,a5,1914 # 1010 <base>
 89e:	00000717          	auipc	a4,0x0
 8a2:	76f73123          	sd	a5,1890(a4) # 1000 <freep>
 8a6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8a8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ac:	b7e1                	j	874 <malloc+0x36>
      if(p->s.size == nunits)
 8ae:	02e48b63          	beq	s1,a4,8e4 <malloc+0xa6>
        p->s.size -= nunits;
 8b2:	4137073b          	subw	a4,a4,s3
 8b6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8b8:	1702                	slli	a4,a4,0x20
 8ba:	9301                	srli	a4,a4,0x20
 8bc:	0712                	slli	a4,a4,0x4
 8be:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8c0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8c4:	00000717          	auipc	a4,0x0
 8c8:	72a73e23          	sd	a0,1852(a4) # 1000 <freep>
      return (void*)(p + 1);
 8cc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8d0:	70e2                	ld	ra,56(sp)
 8d2:	7442                	ld	s0,48(sp)
 8d4:	74a2                	ld	s1,40(sp)
 8d6:	7902                	ld	s2,32(sp)
 8d8:	69e2                	ld	s3,24(sp)
 8da:	6a42                	ld	s4,16(sp)
 8dc:	6aa2                	ld	s5,8(sp)
 8de:	6b02                	ld	s6,0(sp)
 8e0:	6121                	addi	sp,sp,64
 8e2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8e4:	6398                	ld	a4,0(a5)
 8e6:	e118                	sd	a4,0(a0)
 8e8:	bff1                	j	8c4 <malloc+0x86>
  hp->s.size = nu;
 8ea:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ee:	0541                	addi	a0,a0,16
 8f0:	00000097          	auipc	ra,0x0
 8f4:	ec6080e7          	jalr	-314(ra) # 7b6 <free>
  return freep;
 8f8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8fc:	d971                	beqz	a0,8d0 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8fe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 900:	4798                	lw	a4,8(a5)
 902:	fa9776e3          	bgeu	a4,s1,8ae <malloc+0x70>
    if(p == freep)
 906:	00093703          	ld	a4,0(s2)
 90a:	853e                	mv	a0,a5
 90c:	fef719e3          	bne	a4,a5,8fe <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 910:	8552                	mv	a0,s4
 912:	00000097          	auipc	ra,0x0
 916:	b6e080e7          	jalr	-1170(ra) # 480 <sbrk>
  if(p == (char*)-1)
 91a:	fd5518e3          	bne	a0,s5,8ea <malloc+0xac>
        return 0;
 91e:	4501                	li	a0,0
 920:	bf45                	j	8d0 <malloc+0x92>
