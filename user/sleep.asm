
user/_sleep：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h" //该头文件对kernel/types.h头文件有类型依赖，故要放在kernel/types.h之后。
int main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
	if(argc < 2)
   a:	4785                	li	a5,1
   c:	04a7dc63          	bge	a5,a0,64 <main+0x64>
  10:	84ae                	mv	s1,a1
	{
		printf("[Error]:no argument\n" );
		exit(-1);
	} 
    if(argc > 2)
  12:	4789                	li	a5,2
  14:	06a7c563          	blt	a5,a0,7e <main+0x7e>
	{	
    	printf("[Error]:Excessive arguments\n");
		exit(-1);
	}
	// 获取参数字符串的首地址
    char *p = argv[1];
  18:	6588                	ld	a0,8(a1)
    while(*p)
  1a:	00054783          	lbu	a5,0(a0)
  1e:	cf89                	beqz	a5,38 <main+0x38>
    char *p = argv[1];
  20:	872a                	mv	a4,a0
	{
    	if(*p < '0' || *p > '9')
  22:	46a5                	li	a3,9
  24:	fd07879b          	addiw	a5,a5,-48
  28:	0ff7f793          	andi	a5,a5,255
  2c:	06f6e663          	bltu	a3,a5,98 <main+0x98>
		{
        	printf("[Error]:Illegal argument\n");
			exit(-1);
        }
        p++;
  30:	0705                	addi	a4,a4,1
    while(*p)
  32:	00074783          	lbu	a5,0(a4)
  36:	f7fd                	bnez	a5,24 <main+0x24>
    }
	//参数正确执行sleep函数
    sleep(atoi(argv[1]));
  38:	00000097          	auipc	ra,0x0
  3c:	20a080e7          	jalr	522(ra) # 242 <atoi>
  40:	00000097          	auipc	ra,0x0
  44:	3a2080e7          	jalr	930(ra) # 3e2 <sleep>
	printf("(Nothing happened in %s ticks)\n",argv[1]);
  48:	648c                	ld	a1,8(s1)
  4a:	00001517          	auipc	a0,0x1
  4e:	88e50513          	addi	a0,a0,-1906 # 8d8 <malloc+0x140>
  52:	00000097          	auipc	ra,0x0
  56:	688080e7          	jalr	1672(ra) # 6da <printf>
    exit(0);
  5a:	4501                	li	a0,0
  5c:	00000097          	auipc	ra,0x0
  60:	2f6080e7          	jalr	758(ra) # 352 <exit>
		printf("[Error]:no argument\n" );
  64:	00001517          	auipc	a0,0x1
  68:	81c50513          	addi	a0,a0,-2020 # 880 <malloc+0xe8>
  6c:	00000097          	auipc	ra,0x0
  70:	66e080e7          	jalr	1646(ra) # 6da <printf>
		exit(-1);
  74:	557d                	li	a0,-1
  76:	00000097          	auipc	ra,0x0
  7a:	2dc080e7          	jalr	732(ra) # 352 <exit>
    	printf("[Error]:Excessive arguments\n");
  7e:	00001517          	auipc	a0,0x1
  82:	81a50513          	addi	a0,a0,-2022 # 898 <malloc+0x100>
  86:	00000097          	auipc	ra,0x0
  8a:	654080e7          	jalr	1620(ra) # 6da <printf>
		exit(-1);
  8e:	557d                	li	a0,-1
  90:	00000097          	auipc	ra,0x0
  94:	2c2080e7          	jalr	706(ra) # 352 <exit>
        	printf("[Error]:Illegal argument\n");
  98:	00001517          	auipc	a0,0x1
  9c:	82050513          	addi	a0,a0,-2016 # 8b8 <malloc+0x120>
  a0:	00000097          	auipc	ra,0x0
  a4:	63a080e7          	jalr	1594(ra) # 6da <printf>
			exit(-1);
  a8:	557d                	li	a0,-1
  aa:	00000097          	auipc	ra,0x0
  ae:	2a8080e7          	jalr	680(ra) # 352 <exit>

00000000000000b2 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  b2:	1141                	addi	sp,sp,-16
  b4:	e406                	sd	ra,8(sp)
  b6:	e022                	sd	s0,0(sp)
  b8:	0800                	addi	s0,sp,16
  extern int main();
  main();
  ba:	00000097          	auipc	ra,0x0
  be:	f46080e7          	jalr	-186(ra) # 0 <main>
  exit(0);
  c2:	4501                	li	a0,0
  c4:	00000097          	auipc	ra,0x0
  c8:	28e080e7          	jalr	654(ra) # 352 <exit>

00000000000000cc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e422                	sd	s0,8(sp)
  d0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  d2:	87aa                	mv	a5,a0
  d4:	0585                	addi	a1,a1,1
  d6:	0785                	addi	a5,a5,1
  d8:	fff5c703          	lbu	a4,-1(a1)
  dc:	fee78fa3          	sb	a4,-1(a5)
  e0:	fb75                	bnez	a4,d4 <strcpy+0x8>
    ;
  return os;
}
  e2:	6422                	ld	s0,8(sp)
  e4:	0141                	addi	sp,sp,16
  e6:	8082                	ret

00000000000000e8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e8:	1141                	addi	sp,sp,-16
  ea:	e422                	sd	s0,8(sp)
  ec:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ee:	00054783          	lbu	a5,0(a0)
  f2:	cb91                	beqz	a5,106 <strcmp+0x1e>
  f4:	0005c703          	lbu	a4,0(a1)
  f8:	00f71763          	bne	a4,a5,106 <strcmp+0x1e>
    p++, q++;
  fc:	0505                	addi	a0,a0,1
  fe:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 100:	00054783          	lbu	a5,0(a0)
 104:	fbe5                	bnez	a5,f4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 106:	0005c503          	lbu	a0,0(a1)
}
 10a:	40a7853b          	subw	a0,a5,a0
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret

0000000000000114 <strlen>:

uint
strlen(const char *s)
{
 114:	1141                	addi	sp,sp,-16
 116:	e422                	sd	s0,8(sp)
 118:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 11a:	00054783          	lbu	a5,0(a0)
 11e:	cf91                	beqz	a5,13a <strlen+0x26>
 120:	0505                	addi	a0,a0,1
 122:	87aa                	mv	a5,a0
 124:	4685                	li	a3,1
 126:	9e89                	subw	a3,a3,a0
 128:	00f6853b          	addw	a0,a3,a5
 12c:	0785                	addi	a5,a5,1
 12e:	fff7c703          	lbu	a4,-1(a5)
 132:	fb7d                	bnez	a4,128 <strlen+0x14>
    ;
  return n;
}
 134:	6422                	ld	s0,8(sp)
 136:	0141                	addi	sp,sp,16
 138:	8082                	ret
  for(n = 0; s[n]; n++)
 13a:	4501                	li	a0,0
 13c:	bfe5                	j	134 <strlen+0x20>

000000000000013e <memset>:

void*
memset(void *dst, int c, uint n)
{
 13e:	1141                	addi	sp,sp,-16
 140:	e422                	sd	s0,8(sp)
 142:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 144:	ce09                	beqz	a2,15e <memset+0x20>
 146:	87aa                	mv	a5,a0
 148:	fff6071b          	addiw	a4,a2,-1
 14c:	1702                	slli	a4,a4,0x20
 14e:	9301                	srli	a4,a4,0x20
 150:	0705                	addi	a4,a4,1
 152:	972a                	add	a4,a4,a0
    cdst[i] = c;
 154:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 158:	0785                	addi	a5,a5,1
 15a:	fee79de3          	bne	a5,a4,154 <memset+0x16>
  }
  return dst;
}
 15e:	6422                	ld	s0,8(sp)
 160:	0141                	addi	sp,sp,16
 162:	8082                	ret

0000000000000164 <strchr>:

char*
strchr(const char *s, char c)
{
 164:	1141                	addi	sp,sp,-16
 166:	e422                	sd	s0,8(sp)
 168:	0800                	addi	s0,sp,16
  for(; *s; s++)
 16a:	00054783          	lbu	a5,0(a0)
 16e:	cb99                	beqz	a5,184 <strchr+0x20>
    if(*s == c)
 170:	00f58763          	beq	a1,a5,17e <strchr+0x1a>
  for(; *s; s++)
 174:	0505                	addi	a0,a0,1
 176:	00054783          	lbu	a5,0(a0)
 17a:	fbfd                	bnez	a5,170 <strchr+0xc>
      return (char*)s;
  return 0;
 17c:	4501                	li	a0,0
}
 17e:	6422                	ld	s0,8(sp)
 180:	0141                	addi	sp,sp,16
 182:	8082                	ret
  return 0;
 184:	4501                	li	a0,0
 186:	bfe5                	j	17e <strchr+0x1a>

0000000000000188 <gets>:

char*
gets(char *buf, int max)
{
 188:	711d                	addi	sp,sp,-96
 18a:	ec86                	sd	ra,88(sp)
 18c:	e8a2                	sd	s0,80(sp)
 18e:	e4a6                	sd	s1,72(sp)
 190:	e0ca                	sd	s2,64(sp)
 192:	fc4e                	sd	s3,56(sp)
 194:	f852                	sd	s4,48(sp)
 196:	f456                	sd	s5,40(sp)
 198:	f05a                	sd	s6,32(sp)
 19a:	ec5e                	sd	s7,24(sp)
 19c:	1080                	addi	s0,sp,96
 19e:	8baa                	mv	s7,a0
 1a0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a2:	892a                	mv	s2,a0
 1a4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1a6:	4aa9                	li	s5,10
 1a8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1aa:	89a6                	mv	s3,s1
 1ac:	2485                	addiw	s1,s1,1
 1ae:	0344d863          	bge	s1,s4,1de <gets+0x56>
    cc = read(0, &c, 1);
 1b2:	4605                	li	a2,1
 1b4:	faf40593          	addi	a1,s0,-81
 1b8:	4501                	li	a0,0
 1ba:	00000097          	auipc	ra,0x0
 1be:	1b0080e7          	jalr	432(ra) # 36a <read>
    if(cc < 1)
 1c2:	00a05e63          	blez	a0,1de <gets+0x56>
    buf[i++] = c;
 1c6:	faf44783          	lbu	a5,-81(s0)
 1ca:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1ce:	01578763          	beq	a5,s5,1dc <gets+0x54>
 1d2:	0905                	addi	s2,s2,1
 1d4:	fd679be3          	bne	a5,s6,1aa <gets+0x22>
  for(i=0; i+1 < max; ){
 1d8:	89a6                	mv	s3,s1
 1da:	a011                	j	1de <gets+0x56>
 1dc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1de:	99de                	add	s3,s3,s7
 1e0:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e4:	855e                	mv	a0,s7
 1e6:	60e6                	ld	ra,88(sp)
 1e8:	6446                	ld	s0,80(sp)
 1ea:	64a6                	ld	s1,72(sp)
 1ec:	6906                	ld	s2,64(sp)
 1ee:	79e2                	ld	s3,56(sp)
 1f0:	7a42                	ld	s4,48(sp)
 1f2:	7aa2                	ld	s5,40(sp)
 1f4:	7b02                	ld	s6,32(sp)
 1f6:	6be2                	ld	s7,24(sp)
 1f8:	6125                	addi	sp,sp,96
 1fa:	8082                	ret

00000000000001fc <stat>:

int
stat(const char *n, struct stat *st)
{
 1fc:	1101                	addi	sp,sp,-32
 1fe:	ec06                	sd	ra,24(sp)
 200:	e822                	sd	s0,16(sp)
 202:	e426                	sd	s1,8(sp)
 204:	e04a                	sd	s2,0(sp)
 206:	1000                	addi	s0,sp,32
 208:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20a:	4581                	li	a1,0
 20c:	00000097          	auipc	ra,0x0
 210:	186080e7          	jalr	390(ra) # 392 <open>
  if(fd < 0)
 214:	02054563          	bltz	a0,23e <stat+0x42>
 218:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 21a:	85ca                	mv	a1,s2
 21c:	00000097          	auipc	ra,0x0
 220:	18e080e7          	jalr	398(ra) # 3aa <fstat>
 224:	892a                	mv	s2,a0
  close(fd);
 226:	8526                	mv	a0,s1
 228:	00000097          	auipc	ra,0x0
 22c:	152080e7          	jalr	338(ra) # 37a <close>
  return r;
}
 230:	854a                	mv	a0,s2
 232:	60e2                	ld	ra,24(sp)
 234:	6442                	ld	s0,16(sp)
 236:	64a2                	ld	s1,8(sp)
 238:	6902                	ld	s2,0(sp)
 23a:	6105                	addi	sp,sp,32
 23c:	8082                	ret
    return -1;
 23e:	597d                	li	s2,-1
 240:	bfc5                	j	230 <stat+0x34>

0000000000000242 <atoi>:

int
atoi(const char *s)
{
 242:	1141                	addi	sp,sp,-16
 244:	e422                	sd	s0,8(sp)
 246:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 248:	00054603          	lbu	a2,0(a0)
 24c:	fd06079b          	addiw	a5,a2,-48
 250:	0ff7f793          	andi	a5,a5,255
 254:	4725                	li	a4,9
 256:	02f76963          	bltu	a4,a5,288 <atoi+0x46>
 25a:	86aa                	mv	a3,a0
  n = 0;
 25c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 25e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 260:	0685                	addi	a3,a3,1
 262:	0025179b          	slliw	a5,a0,0x2
 266:	9fa9                	addw	a5,a5,a0
 268:	0017979b          	slliw	a5,a5,0x1
 26c:	9fb1                	addw	a5,a5,a2
 26e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 272:	0006c603          	lbu	a2,0(a3)
 276:	fd06071b          	addiw	a4,a2,-48
 27a:	0ff77713          	andi	a4,a4,255
 27e:	fee5f1e3          	bgeu	a1,a4,260 <atoi+0x1e>
  return n;
}
 282:	6422                	ld	s0,8(sp)
 284:	0141                	addi	sp,sp,16
 286:	8082                	ret
  n = 0;
 288:	4501                	li	a0,0
 28a:	bfe5                	j	282 <atoi+0x40>

000000000000028c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e422                	sd	s0,8(sp)
 290:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 292:	02b57663          	bgeu	a0,a1,2be <memmove+0x32>
    while(n-- > 0)
 296:	02c05163          	blez	a2,2b8 <memmove+0x2c>
 29a:	fff6079b          	addiw	a5,a2,-1
 29e:	1782                	slli	a5,a5,0x20
 2a0:	9381                	srli	a5,a5,0x20
 2a2:	0785                	addi	a5,a5,1
 2a4:	97aa                	add	a5,a5,a0
  dst = vdst;
 2a6:	872a                	mv	a4,a0
      *dst++ = *src++;
 2a8:	0585                	addi	a1,a1,1
 2aa:	0705                	addi	a4,a4,1
 2ac:	fff5c683          	lbu	a3,-1(a1)
 2b0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2b4:	fee79ae3          	bne	a5,a4,2a8 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2b8:	6422                	ld	s0,8(sp)
 2ba:	0141                	addi	sp,sp,16
 2bc:	8082                	ret
    dst += n;
 2be:	00c50733          	add	a4,a0,a2
    src += n;
 2c2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2c4:	fec05ae3          	blez	a2,2b8 <memmove+0x2c>
 2c8:	fff6079b          	addiw	a5,a2,-1
 2cc:	1782                	slli	a5,a5,0x20
 2ce:	9381                	srli	a5,a5,0x20
 2d0:	fff7c793          	not	a5,a5
 2d4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2d6:	15fd                	addi	a1,a1,-1
 2d8:	177d                	addi	a4,a4,-1
 2da:	0005c683          	lbu	a3,0(a1)
 2de:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2e2:	fee79ae3          	bne	a5,a4,2d6 <memmove+0x4a>
 2e6:	bfc9                	j	2b8 <memmove+0x2c>

00000000000002e8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e422                	sd	s0,8(sp)
 2ec:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2ee:	ca05                	beqz	a2,31e <memcmp+0x36>
 2f0:	fff6069b          	addiw	a3,a2,-1
 2f4:	1682                	slli	a3,a3,0x20
 2f6:	9281                	srli	a3,a3,0x20
 2f8:	0685                	addi	a3,a3,1
 2fa:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2fc:	00054783          	lbu	a5,0(a0)
 300:	0005c703          	lbu	a4,0(a1)
 304:	00e79863          	bne	a5,a4,314 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 308:	0505                	addi	a0,a0,1
    p2++;
 30a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 30c:	fed518e3          	bne	a0,a3,2fc <memcmp+0x14>
  }
  return 0;
 310:	4501                	li	a0,0
 312:	a019                	j	318 <memcmp+0x30>
      return *p1 - *p2;
 314:	40e7853b          	subw	a0,a5,a4
}
 318:	6422                	ld	s0,8(sp)
 31a:	0141                	addi	sp,sp,16
 31c:	8082                	ret
  return 0;
 31e:	4501                	li	a0,0
 320:	bfe5                	j	318 <memcmp+0x30>

0000000000000322 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 322:	1141                	addi	sp,sp,-16
 324:	e406                	sd	ra,8(sp)
 326:	e022                	sd	s0,0(sp)
 328:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 32a:	00000097          	auipc	ra,0x0
 32e:	f62080e7          	jalr	-158(ra) # 28c <memmove>
}
 332:	60a2                	ld	ra,8(sp)
 334:	6402                	ld	s0,0(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret

000000000000033a <ugetpid>:
  int pid;  // Process ID
};

int
ugetpid(void)
{
 33a:	1141                	addi	sp,sp,-16
 33c:	e422                	sd	s0,8(sp)
 33e:	0800                	addi	s0,sp,16
  struct usyscall *u = (struct usyscall *)USYSCALL;
  return u->pid;
}
 340:	00002503          	lw	a0,0(zero) # 0 <main>
 344:	6422                	ld	s0,8(sp)
 346:	0141                	addi	sp,sp,16
 348:	8082                	ret

000000000000034a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 34a:	4885                	li	a7,1
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <exit>:
.global exit
exit:
 li a7, SYS_exit
 352:	4889                	li	a7,2
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <wait>:
.global wait
wait:
 li a7, SYS_wait
 35a:	488d                	li	a7,3
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 362:	4891                	li	a7,4
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <read>:
.global read
read:
 li a7, SYS_read
 36a:	4895                	li	a7,5
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <write>:
.global write
write:
 li a7, SYS_write
 372:	48c1                	li	a7,16
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <close>:
.global close
close:
 li a7, SYS_close
 37a:	48d5                	li	a7,21
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <kill>:
.global kill
kill:
 li a7, SYS_kill
 382:	4899                	li	a7,6
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <exec>:
.global exec
exec:
 li a7, SYS_exec
 38a:	489d                	li	a7,7
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <open>:
.global open
open:
 li a7, SYS_open
 392:	48bd                	li	a7,15
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 39a:	48c5                	li	a7,17
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a2:	48c9                	li	a7,18
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3aa:	48a1                	li	a7,8
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <link>:
.global link
link:
 li a7, SYS_link
 3b2:	48cd                	li	a7,19
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ba:	48d1                	li	a7,20
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c2:	48a5                	li	a7,9
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ca:	48a9                	li	a7,10
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d2:	48ad                	li	a7,11
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3da:	48b1                	li	a7,12
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3e2:	48b5                	li	a7,13
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ea:	48b9                	li	a7,14
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <trace>:
.global trace
trace:
 li a7, SYS_trace
 3f2:	48d9                	li	a7,22
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <yield>:
.global yield
yield:
 li a7, SYS_yield
 3fa:	48dd                	li	a7,23
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 402:	1101                	addi	sp,sp,-32
 404:	ec06                	sd	ra,24(sp)
 406:	e822                	sd	s0,16(sp)
 408:	1000                	addi	s0,sp,32
 40a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 40e:	4605                	li	a2,1
 410:	fef40593          	addi	a1,s0,-17
 414:	00000097          	auipc	ra,0x0
 418:	f5e080e7          	jalr	-162(ra) # 372 <write>
}
 41c:	60e2                	ld	ra,24(sp)
 41e:	6442                	ld	s0,16(sp)
 420:	6105                	addi	sp,sp,32
 422:	8082                	ret

0000000000000424 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 424:	7139                	addi	sp,sp,-64
 426:	fc06                	sd	ra,56(sp)
 428:	f822                	sd	s0,48(sp)
 42a:	f426                	sd	s1,40(sp)
 42c:	f04a                	sd	s2,32(sp)
 42e:	ec4e                	sd	s3,24(sp)
 430:	0080                	addi	s0,sp,64
 432:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 434:	c299                	beqz	a3,43a <printint+0x16>
 436:	0805c863          	bltz	a1,4c6 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 43a:	2581                	sext.w	a1,a1
  neg = 0;
 43c:	4881                	li	a7,0
 43e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 442:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 444:	2601                	sext.w	a2,a2
 446:	00000517          	auipc	a0,0x0
 44a:	4ba50513          	addi	a0,a0,1210 # 900 <digits>
 44e:	883a                	mv	a6,a4
 450:	2705                	addiw	a4,a4,1
 452:	02c5f7bb          	remuw	a5,a1,a2
 456:	1782                	slli	a5,a5,0x20
 458:	9381                	srli	a5,a5,0x20
 45a:	97aa                	add	a5,a5,a0
 45c:	0007c783          	lbu	a5,0(a5)
 460:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 464:	0005879b          	sext.w	a5,a1
 468:	02c5d5bb          	divuw	a1,a1,a2
 46c:	0685                	addi	a3,a3,1
 46e:	fec7f0e3          	bgeu	a5,a2,44e <printint+0x2a>
  if(neg)
 472:	00088b63          	beqz	a7,488 <printint+0x64>
    buf[i++] = '-';
 476:	fd040793          	addi	a5,s0,-48
 47a:	973e                	add	a4,a4,a5
 47c:	02d00793          	li	a5,45
 480:	fef70823          	sb	a5,-16(a4)
 484:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 488:	02e05863          	blez	a4,4b8 <printint+0x94>
 48c:	fc040793          	addi	a5,s0,-64
 490:	00e78933          	add	s2,a5,a4
 494:	fff78993          	addi	s3,a5,-1
 498:	99ba                	add	s3,s3,a4
 49a:	377d                	addiw	a4,a4,-1
 49c:	1702                	slli	a4,a4,0x20
 49e:	9301                	srli	a4,a4,0x20
 4a0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4a4:	fff94583          	lbu	a1,-1(s2)
 4a8:	8526                	mv	a0,s1
 4aa:	00000097          	auipc	ra,0x0
 4ae:	f58080e7          	jalr	-168(ra) # 402 <putc>
  while(--i >= 0)
 4b2:	197d                	addi	s2,s2,-1
 4b4:	ff3918e3          	bne	s2,s3,4a4 <printint+0x80>
}
 4b8:	70e2                	ld	ra,56(sp)
 4ba:	7442                	ld	s0,48(sp)
 4bc:	74a2                	ld	s1,40(sp)
 4be:	7902                	ld	s2,32(sp)
 4c0:	69e2                	ld	s3,24(sp)
 4c2:	6121                	addi	sp,sp,64
 4c4:	8082                	ret
    x = -xx;
 4c6:	40b005bb          	negw	a1,a1
    neg = 1;
 4ca:	4885                	li	a7,1
    x = -xx;
 4cc:	bf8d                	j	43e <printint+0x1a>

00000000000004ce <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ce:	7119                	addi	sp,sp,-128
 4d0:	fc86                	sd	ra,120(sp)
 4d2:	f8a2                	sd	s0,112(sp)
 4d4:	f4a6                	sd	s1,104(sp)
 4d6:	f0ca                	sd	s2,96(sp)
 4d8:	ecce                	sd	s3,88(sp)
 4da:	e8d2                	sd	s4,80(sp)
 4dc:	e4d6                	sd	s5,72(sp)
 4de:	e0da                	sd	s6,64(sp)
 4e0:	fc5e                	sd	s7,56(sp)
 4e2:	f862                	sd	s8,48(sp)
 4e4:	f466                	sd	s9,40(sp)
 4e6:	f06a                	sd	s10,32(sp)
 4e8:	ec6e                	sd	s11,24(sp)
 4ea:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ec:	0005c903          	lbu	s2,0(a1)
 4f0:	18090f63          	beqz	s2,68e <vprintf+0x1c0>
 4f4:	8aaa                	mv	s5,a0
 4f6:	8b32                	mv	s6,a2
 4f8:	00158493          	addi	s1,a1,1
  state = 0;
 4fc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4fe:	02500a13          	li	s4,37
      if(c == 'd'){
 502:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 506:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 50a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 50e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 512:	00000b97          	auipc	s7,0x0
 516:	3eeb8b93          	addi	s7,s7,1006 # 900 <digits>
 51a:	a839                	j	538 <vprintf+0x6a>
        putc(fd, c);
 51c:	85ca                	mv	a1,s2
 51e:	8556                	mv	a0,s5
 520:	00000097          	auipc	ra,0x0
 524:	ee2080e7          	jalr	-286(ra) # 402 <putc>
 528:	a019                	j	52e <vprintf+0x60>
    } else if(state == '%'){
 52a:	01498f63          	beq	s3,s4,548 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 52e:	0485                	addi	s1,s1,1
 530:	fff4c903          	lbu	s2,-1(s1)
 534:	14090d63          	beqz	s2,68e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 538:	0009079b          	sext.w	a5,s2
    if(state == 0){
 53c:	fe0997e3          	bnez	s3,52a <vprintf+0x5c>
      if(c == '%'){
 540:	fd479ee3          	bne	a5,s4,51c <vprintf+0x4e>
        state = '%';
 544:	89be                	mv	s3,a5
 546:	b7e5                	j	52e <vprintf+0x60>
      if(c == 'd'){
 548:	05878063          	beq	a5,s8,588 <vprintf+0xba>
      } else if(c == 'l') {
 54c:	05978c63          	beq	a5,s9,5a4 <vprintf+0xd6>
      } else if(c == 'x') {
 550:	07a78863          	beq	a5,s10,5c0 <vprintf+0xf2>
      } else if(c == 'p') {
 554:	09b78463          	beq	a5,s11,5dc <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 558:	07300713          	li	a4,115
 55c:	0ce78663          	beq	a5,a4,628 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 560:	06300713          	li	a4,99
 564:	0ee78e63          	beq	a5,a4,660 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 568:	11478863          	beq	a5,s4,678 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 56c:	85d2                	mv	a1,s4
 56e:	8556                	mv	a0,s5
 570:	00000097          	auipc	ra,0x0
 574:	e92080e7          	jalr	-366(ra) # 402 <putc>
        putc(fd, c);
 578:	85ca                	mv	a1,s2
 57a:	8556                	mv	a0,s5
 57c:	00000097          	auipc	ra,0x0
 580:	e86080e7          	jalr	-378(ra) # 402 <putc>
      }
      state = 0;
 584:	4981                	li	s3,0
 586:	b765                	j	52e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 588:	008b0913          	addi	s2,s6,8
 58c:	4685                	li	a3,1
 58e:	4629                	li	a2,10
 590:	000b2583          	lw	a1,0(s6)
 594:	8556                	mv	a0,s5
 596:	00000097          	auipc	ra,0x0
 59a:	e8e080e7          	jalr	-370(ra) # 424 <printint>
 59e:	8b4a                	mv	s6,s2
      state = 0;
 5a0:	4981                	li	s3,0
 5a2:	b771                	j	52e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5a4:	008b0913          	addi	s2,s6,8
 5a8:	4681                	li	a3,0
 5aa:	4629                	li	a2,10
 5ac:	000b2583          	lw	a1,0(s6)
 5b0:	8556                	mv	a0,s5
 5b2:	00000097          	auipc	ra,0x0
 5b6:	e72080e7          	jalr	-398(ra) # 424 <printint>
 5ba:	8b4a                	mv	s6,s2
      state = 0;
 5bc:	4981                	li	s3,0
 5be:	bf85                	j	52e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5c0:	008b0913          	addi	s2,s6,8
 5c4:	4681                	li	a3,0
 5c6:	4641                	li	a2,16
 5c8:	000b2583          	lw	a1,0(s6)
 5cc:	8556                	mv	a0,s5
 5ce:	00000097          	auipc	ra,0x0
 5d2:	e56080e7          	jalr	-426(ra) # 424 <printint>
 5d6:	8b4a                	mv	s6,s2
      state = 0;
 5d8:	4981                	li	s3,0
 5da:	bf91                	j	52e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5dc:	008b0793          	addi	a5,s6,8
 5e0:	f8f43423          	sd	a5,-120(s0)
 5e4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5e8:	03000593          	li	a1,48
 5ec:	8556                	mv	a0,s5
 5ee:	00000097          	auipc	ra,0x0
 5f2:	e14080e7          	jalr	-492(ra) # 402 <putc>
  putc(fd, 'x');
 5f6:	85ea                	mv	a1,s10
 5f8:	8556                	mv	a0,s5
 5fa:	00000097          	auipc	ra,0x0
 5fe:	e08080e7          	jalr	-504(ra) # 402 <putc>
 602:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 604:	03c9d793          	srli	a5,s3,0x3c
 608:	97de                	add	a5,a5,s7
 60a:	0007c583          	lbu	a1,0(a5)
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	df2080e7          	jalr	-526(ra) # 402 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 618:	0992                	slli	s3,s3,0x4
 61a:	397d                	addiw	s2,s2,-1
 61c:	fe0914e3          	bnez	s2,604 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 620:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 624:	4981                	li	s3,0
 626:	b721                	j	52e <vprintf+0x60>
        s = va_arg(ap, char*);
 628:	008b0993          	addi	s3,s6,8
 62c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 630:	02090163          	beqz	s2,652 <vprintf+0x184>
        while(*s != 0){
 634:	00094583          	lbu	a1,0(s2)
 638:	c9a1                	beqz	a1,688 <vprintf+0x1ba>
          putc(fd, *s);
 63a:	8556                	mv	a0,s5
 63c:	00000097          	auipc	ra,0x0
 640:	dc6080e7          	jalr	-570(ra) # 402 <putc>
          s++;
 644:	0905                	addi	s2,s2,1
        while(*s != 0){
 646:	00094583          	lbu	a1,0(s2)
 64a:	f9e5                	bnez	a1,63a <vprintf+0x16c>
        s = va_arg(ap, char*);
 64c:	8b4e                	mv	s6,s3
      state = 0;
 64e:	4981                	li	s3,0
 650:	bdf9                	j	52e <vprintf+0x60>
          s = "(null)";
 652:	00000917          	auipc	s2,0x0
 656:	2a690913          	addi	s2,s2,678 # 8f8 <malloc+0x160>
        while(*s != 0){
 65a:	02800593          	li	a1,40
 65e:	bff1                	j	63a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 660:	008b0913          	addi	s2,s6,8
 664:	000b4583          	lbu	a1,0(s6)
 668:	8556                	mv	a0,s5
 66a:	00000097          	auipc	ra,0x0
 66e:	d98080e7          	jalr	-616(ra) # 402 <putc>
 672:	8b4a                	mv	s6,s2
      state = 0;
 674:	4981                	li	s3,0
 676:	bd65                	j	52e <vprintf+0x60>
        putc(fd, c);
 678:	85d2                	mv	a1,s4
 67a:	8556                	mv	a0,s5
 67c:	00000097          	auipc	ra,0x0
 680:	d86080e7          	jalr	-634(ra) # 402 <putc>
      state = 0;
 684:	4981                	li	s3,0
 686:	b565                	j	52e <vprintf+0x60>
        s = va_arg(ap, char*);
 688:	8b4e                	mv	s6,s3
      state = 0;
 68a:	4981                	li	s3,0
 68c:	b54d                	j	52e <vprintf+0x60>
    }
  }
}
 68e:	70e6                	ld	ra,120(sp)
 690:	7446                	ld	s0,112(sp)
 692:	74a6                	ld	s1,104(sp)
 694:	7906                	ld	s2,96(sp)
 696:	69e6                	ld	s3,88(sp)
 698:	6a46                	ld	s4,80(sp)
 69a:	6aa6                	ld	s5,72(sp)
 69c:	6b06                	ld	s6,64(sp)
 69e:	7be2                	ld	s7,56(sp)
 6a0:	7c42                	ld	s8,48(sp)
 6a2:	7ca2                	ld	s9,40(sp)
 6a4:	7d02                	ld	s10,32(sp)
 6a6:	6de2                	ld	s11,24(sp)
 6a8:	6109                	addi	sp,sp,128
 6aa:	8082                	ret

00000000000006ac <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6ac:	715d                	addi	sp,sp,-80
 6ae:	ec06                	sd	ra,24(sp)
 6b0:	e822                	sd	s0,16(sp)
 6b2:	1000                	addi	s0,sp,32
 6b4:	e010                	sd	a2,0(s0)
 6b6:	e414                	sd	a3,8(s0)
 6b8:	e818                	sd	a4,16(s0)
 6ba:	ec1c                	sd	a5,24(s0)
 6bc:	03043023          	sd	a6,32(s0)
 6c0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6c4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6c8:	8622                	mv	a2,s0
 6ca:	00000097          	auipc	ra,0x0
 6ce:	e04080e7          	jalr	-508(ra) # 4ce <vprintf>
}
 6d2:	60e2                	ld	ra,24(sp)
 6d4:	6442                	ld	s0,16(sp)
 6d6:	6161                	addi	sp,sp,80
 6d8:	8082                	ret

00000000000006da <printf>:

void
printf(const char *fmt, ...)
{
 6da:	711d                	addi	sp,sp,-96
 6dc:	ec06                	sd	ra,24(sp)
 6de:	e822                	sd	s0,16(sp)
 6e0:	1000                	addi	s0,sp,32
 6e2:	e40c                	sd	a1,8(s0)
 6e4:	e810                	sd	a2,16(s0)
 6e6:	ec14                	sd	a3,24(s0)
 6e8:	f018                	sd	a4,32(s0)
 6ea:	f41c                	sd	a5,40(s0)
 6ec:	03043823          	sd	a6,48(s0)
 6f0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6f4:	00840613          	addi	a2,s0,8
 6f8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6fc:	85aa                	mv	a1,a0
 6fe:	4505                	li	a0,1
 700:	00000097          	auipc	ra,0x0
 704:	dce080e7          	jalr	-562(ra) # 4ce <vprintf>
}
 708:	60e2                	ld	ra,24(sp)
 70a:	6442                	ld	s0,16(sp)
 70c:	6125                	addi	sp,sp,96
 70e:	8082                	ret

0000000000000710 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 710:	1141                	addi	sp,sp,-16
 712:	e422                	sd	s0,8(sp)
 714:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 716:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 71a:	00001797          	auipc	a5,0x1
 71e:	8e67b783          	ld	a5,-1818(a5) # 1000 <freep>
 722:	a805                	j	752 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 724:	4618                	lw	a4,8(a2)
 726:	9db9                	addw	a1,a1,a4
 728:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 72c:	6398                	ld	a4,0(a5)
 72e:	6318                	ld	a4,0(a4)
 730:	fee53823          	sd	a4,-16(a0)
 734:	a091                	j	778 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 736:	ff852703          	lw	a4,-8(a0)
 73a:	9e39                	addw	a2,a2,a4
 73c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 73e:	ff053703          	ld	a4,-16(a0)
 742:	e398                	sd	a4,0(a5)
 744:	a099                	j	78a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 746:	6398                	ld	a4,0(a5)
 748:	00e7e463          	bltu	a5,a4,750 <free+0x40>
 74c:	00e6ea63          	bltu	a3,a4,760 <free+0x50>
{
 750:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 752:	fed7fae3          	bgeu	a5,a3,746 <free+0x36>
 756:	6398                	ld	a4,0(a5)
 758:	00e6e463          	bltu	a3,a4,760 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 75c:	fee7eae3          	bltu	a5,a4,750 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 760:	ff852583          	lw	a1,-8(a0)
 764:	6390                	ld	a2,0(a5)
 766:	02059713          	slli	a4,a1,0x20
 76a:	9301                	srli	a4,a4,0x20
 76c:	0712                	slli	a4,a4,0x4
 76e:	9736                	add	a4,a4,a3
 770:	fae60ae3          	beq	a2,a4,724 <free+0x14>
    bp->s.ptr = p->s.ptr;
 774:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 778:	4790                	lw	a2,8(a5)
 77a:	02061713          	slli	a4,a2,0x20
 77e:	9301                	srli	a4,a4,0x20
 780:	0712                	slli	a4,a4,0x4
 782:	973e                	add	a4,a4,a5
 784:	fae689e3          	beq	a3,a4,736 <free+0x26>
  } else
    p->s.ptr = bp;
 788:	e394                	sd	a3,0(a5)
  freep = p;
 78a:	00001717          	auipc	a4,0x1
 78e:	86f73b23          	sd	a5,-1930(a4) # 1000 <freep>
}
 792:	6422                	ld	s0,8(sp)
 794:	0141                	addi	sp,sp,16
 796:	8082                	ret

0000000000000798 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 798:	7139                	addi	sp,sp,-64
 79a:	fc06                	sd	ra,56(sp)
 79c:	f822                	sd	s0,48(sp)
 79e:	f426                	sd	s1,40(sp)
 7a0:	f04a                	sd	s2,32(sp)
 7a2:	ec4e                	sd	s3,24(sp)
 7a4:	e852                	sd	s4,16(sp)
 7a6:	e456                	sd	s5,8(sp)
 7a8:	e05a                	sd	s6,0(sp)
 7aa:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7ac:	02051493          	slli	s1,a0,0x20
 7b0:	9081                	srli	s1,s1,0x20
 7b2:	04bd                	addi	s1,s1,15
 7b4:	8091                	srli	s1,s1,0x4
 7b6:	0014899b          	addiw	s3,s1,1
 7ba:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7bc:	00001517          	auipc	a0,0x1
 7c0:	84453503          	ld	a0,-1980(a0) # 1000 <freep>
 7c4:	c515                	beqz	a0,7f0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7c8:	4798                	lw	a4,8(a5)
 7ca:	02977f63          	bgeu	a4,s1,808 <malloc+0x70>
 7ce:	8a4e                	mv	s4,s3
 7d0:	0009871b          	sext.w	a4,s3
 7d4:	6685                	lui	a3,0x1
 7d6:	00d77363          	bgeu	a4,a3,7dc <malloc+0x44>
 7da:	6a05                	lui	s4,0x1
 7dc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7e0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7e4:	00001917          	auipc	s2,0x1
 7e8:	81c90913          	addi	s2,s2,-2020 # 1000 <freep>
  if(p == (char*)-1)
 7ec:	5afd                	li	s5,-1
 7ee:	a88d                	j	860 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 7f0:	00001797          	auipc	a5,0x1
 7f4:	82078793          	addi	a5,a5,-2016 # 1010 <base>
 7f8:	00001717          	auipc	a4,0x1
 7fc:	80f73423          	sd	a5,-2040(a4) # 1000 <freep>
 800:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 802:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 806:	b7e1                	j	7ce <malloc+0x36>
      if(p->s.size == nunits)
 808:	02e48b63          	beq	s1,a4,83e <malloc+0xa6>
        p->s.size -= nunits;
 80c:	4137073b          	subw	a4,a4,s3
 810:	c798                	sw	a4,8(a5)
        p += p->s.size;
 812:	1702                	slli	a4,a4,0x20
 814:	9301                	srli	a4,a4,0x20
 816:	0712                	slli	a4,a4,0x4
 818:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 81a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 81e:	00000717          	auipc	a4,0x0
 822:	7ea73123          	sd	a0,2018(a4) # 1000 <freep>
      return (void*)(p + 1);
 826:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 82a:	70e2                	ld	ra,56(sp)
 82c:	7442                	ld	s0,48(sp)
 82e:	74a2                	ld	s1,40(sp)
 830:	7902                	ld	s2,32(sp)
 832:	69e2                	ld	s3,24(sp)
 834:	6a42                	ld	s4,16(sp)
 836:	6aa2                	ld	s5,8(sp)
 838:	6b02                	ld	s6,0(sp)
 83a:	6121                	addi	sp,sp,64
 83c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 83e:	6398                	ld	a4,0(a5)
 840:	e118                	sd	a4,0(a0)
 842:	bff1                	j	81e <malloc+0x86>
  hp->s.size = nu;
 844:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 848:	0541                	addi	a0,a0,16
 84a:	00000097          	auipc	ra,0x0
 84e:	ec6080e7          	jalr	-314(ra) # 710 <free>
  return freep;
 852:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 856:	d971                	beqz	a0,82a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 858:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 85a:	4798                	lw	a4,8(a5)
 85c:	fa9776e3          	bgeu	a4,s1,808 <malloc+0x70>
    if(p == freep)
 860:	00093703          	ld	a4,0(s2)
 864:	853e                	mv	a0,a5
 866:	fef719e3          	bne	a4,a5,858 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 86a:	8552                	mv	a0,s4
 86c:	00000097          	auipc	ra,0x0
 870:	b6e080e7          	jalr	-1170(ra) # 3da <sbrk>
  if(p == (char*)-1)
 874:	fd5518e3          	bne	a0,s5,844 <malloc+0xac>
        return 0;
 878:	4501                	li	a0,0
 87a:	bf45                	j	82a <malloc+0x92>
