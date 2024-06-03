
user/_uthread：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <thread_init>:
struct thread *current_thread;
extern void thread_switch(struct multi_context* old, struct multi_context* new);
              
void 
thread_init(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  // main() is thread 0, which will make the first invocation to
  // thread_schedule(). It needs a stack so that the first thread_switch() can
  // save thread 0's state.
  current_thread = &all_thread[0];
   6:	00001797          	auipc	a5,0x1
   a:	d9278793          	addi	a5,a5,-622 # d98 <all_thread>
   e:	00001717          	auipc	a4,0x1
  12:	d6f73d23          	sd	a5,-646(a4) # d88 <current_thread>
  current_thread->state = RUNNING;
  16:	4785                	li	a5,1
  18:	00003717          	auipc	a4,0x3
  1c:	d8f72023          	sw	a5,-640(a4) # 2d98 <__global_pointer$+0x182f>
}
  20:	6422                	ld	s0,8(sp)
  22:	0141                	addi	sp,sp,16
  24:	8082                	ret

0000000000000026 <thread_schedule>:

void 
thread_schedule(void)
{
  26:	1141                	addi	sp,sp,-16
  28:	e406                	sd	ra,8(sp)
  2a:	e022                	sd	s0,0(sp)
  2c:	0800                	addi	s0,sp,16
  struct thread *t, *next_thread;

  /* Find another runnable thread. */
  next_thread = 0;
  t = current_thread + 1;
  2e:	00001317          	auipc	t1,0x1
  32:	d5a33303          	ld	t1,-678(t1) # d88 <current_thread>
  36:	6589                	lui	a1,0x2
  38:	07858593          	addi	a1,a1,120 # 2078 <__global_pointer$+0xb0f>
  3c:	959a                	add	a1,a1,t1
  3e:	4791                	li	a5,4
  //遍历查看是否有在runnable的线程
  for(int i = 0; i < MAX_THREAD; i++){
    if(t >= all_thread + MAX_THREAD)
  40:	00009817          	auipc	a6,0x9
  44:	f3880813          	addi	a6,a6,-200 # 8f78 <base>
      t = all_thread;
    // 如果状态为RUNNABLE就是next_thread
    if(t->state == RUNNABLE) {
  48:	6689                	lui	a3,0x2
  4a:	4609                	li	a2,2
      next_thread = t;
      break;
    }
    t = t + 1;
  4c:	07868893          	addi	a7,a3,120 # 2078 <__global_pointer$+0xb0f>
  50:	a809                	j	62 <thread_schedule+0x3c>
    if(t->state == RUNNABLE) {
  52:	00d58733          	add	a4,a1,a3
  56:	4318                	lw	a4,0(a4)
  58:	02c70963          	beq	a4,a2,8a <thread_schedule+0x64>
    t = t + 1;
  5c:	95c6                	add	a1,a1,a7
  for(int i = 0; i < MAX_THREAD; i++){
  5e:	37fd                	addiw	a5,a5,-1
  60:	cb81                	beqz	a5,70 <thread_schedule+0x4a>
    if(t >= all_thread + MAX_THREAD)
  62:	ff05e8e3          	bltu	a1,a6,52 <thread_schedule+0x2c>
      t = all_thread;
  66:	00001597          	auipc	a1,0x1
  6a:	d3258593          	addi	a1,a1,-718 # d98 <all_thread>
  6e:	b7d5                	j	52 <thread_schedule+0x2c>
  }

  if (next_thread == 0) {
    printf("thread_schedule: no runnable threads\n");
  70:	00001517          	auipc	a0,0x1
  74:	be050513          	addi	a0,a0,-1056 # c50 <malloc+0xea>
  78:	00001097          	auipc	ra,0x1
  7c:	a30080e7          	jalr	-1488(ra) # aa8 <printf>
    exit(-1);
  80:	557d                	li	a0,-1
  82:	00000097          	auipc	ra,0x0
  86:	69e080e7          	jalr	1694(ra) # 720 <exit>
  }
  //有可切换的线程
  if (current_thread != next_thread) {         /* switch threads?  */
  8a:	02b30263          	beq	t1,a1,ae <thread_schedule+0x88>
    next_thread->state = RUNNING;
  8e:	6509                	lui	a0,0x2
  90:	00a587b3          	add	a5,a1,a0
  94:	4705                	li	a4,1
  96:	c398                	sw	a4,0(a5)
    t = current_thread;
    current_thread = next_thread;
  98:	00001797          	auipc	a5,0x1
  9c:	ceb7b823          	sd	a1,-784(a5) # d88 <current_thread>
    thread_switch(&t->callee_saved_registers, &current_thread->callee_saved_registers);
  a0:	0521                	addi	a0,a0,8
  a2:	95aa                	add	a1,a1,a0
  a4:	951a                	add	a0,a0,t1
  a6:	00000097          	auipc	ra,0x0
  aa:	370080e7          	jalr	880(ra) # 416 <thread_switch>
    /* YOUR CODE HERE
     * Invoke thread_switch to switch from t to next_thread:  
     */
  } else
    next_thread = 0;
}
  ae:	60a2                	ld	ra,8(sp)
  b0:	6402                	ld	s0,0(sp)
  b2:	0141                	addi	sp,sp,16
  b4:	8082                	ret

00000000000000b6 <thread_create>:

void 
thread_create(void (*func)())
{
  b6:	1141                	addi	sp,sp,-16
  b8:	e422                	sd	s0,8(sp)
  ba:	0800                	addi	s0,sp,16
  struct thread *t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  bc:	00001797          	auipc	a5,0x1
  c0:	cdc78793          	addi	a5,a5,-804 # d98 <all_thread>
    if (t->state == FREE) break;
  c4:	6689                	lui	a3,0x2
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  c6:	07868593          	addi	a1,a3,120 # 2078 <__global_pointer$+0xb0f>
  ca:	00009617          	auipc	a2,0x9
  ce:	eae60613          	addi	a2,a2,-338 # 8f78 <base>
    if (t->state == FREE) break;
  d2:	00d78733          	add	a4,a5,a3
  d6:	4318                	lw	a4,0(a4)
  d8:	c701                	beqz	a4,e0 <thread_create+0x2a>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  da:	97ae                	add	a5,a5,a1
  dc:	fec79be3          	bne	a5,a2,d2 <thread_create+0x1c>
  }
  t->state = RUNNABLE;
  e0:	6709                	lui	a4,0x2
  e2:	00e786b3          	add	a3,a5,a4
  e6:	4609                	li	a2,2
  e8:	c290                	sw	a2,0(a3)
  // YOUR CODE HERE
  //要求： 首次运行给定线程时，该线程在自己的堆栈上执行
  t->callee_saved_registers.sp = (uint64)&t->stack[STACK_SIZE-1];
  ea:	177d                	addi	a4,a4,-1
  ec:	97ba                	add	a5,a5,a4
  ee:	ea9c                	sd	a5,16(a3)
  t->callee_saved_registers.ra = (uint64)(*func);
  f0:	e688                	sd	a0,8(a3)
  
}
  f2:	6422                	ld	s0,8(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret

00000000000000f8 <thread_yield>:

void 
thread_yield(void)
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e406                	sd	ra,8(sp)
  fc:	e022                	sd	s0,0(sp)
  fe:	0800                	addi	s0,sp,16
  current_thread->state = RUNNABLE;
 100:	00001797          	auipc	a5,0x1
 104:	c887b783          	ld	a5,-888(a5) # d88 <current_thread>
 108:	6709                	lui	a4,0x2
 10a:	97ba                	add	a5,a5,a4
 10c:	4709                	li	a4,2
 10e:	c398                	sw	a4,0(a5)
  thread_schedule();
 110:	00000097          	auipc	ra,0x0
 114:	f16080e7          	jalr	-234(ra) # 26 <thread_schedule>
}
 118:	60a2                	ld	ra,8(sp)
 11a:	6402                	ld	s0,0(sp)
 11c:	0141                	addi	sp,sp,16
 11e:	8082                	ret

0000000000000120 <thread_a>:
volatile int a_started, b_started, c_started;
volatile int a_n, b_n, c_n;

void 
thread_a(void)
{
 120:	7179                	addi	sp,sp,-48
 122:	f406                	sd	ra,40(sp)
 124:	f022                	sd	s0,32(sp)
 126:	ec26                	sd	s1,24(sp)
 128:	e84a                	sd	s2,16(sp)
 12a:	e44e                	sd	s3,8(sp)
 12c:	e052                	sd	s4,0(sp)
 12e:	1800                	addi	s0,sp,48
  int i;
  printf("thread_a started\n");
 130:	00001517          	auipc	a0,0x1
 134:	b4850513          	addi	a0,a0,-1208 # c78 <malloc+0x112>
 138:	00001097          	auipc	ra,0x1
 13c:	970080e7          	jalr	-1680(ra) # aa8 <printf>
  a_started = 1;
 140:	4785                	li	a5,1
 142:	00001717          	auipc	a4,0x1
 146:	c4f72123          	sw	a5,-958(a4) # d84 <a_started>
  while(b_started == 0 || c_started == 0)
 14a:	00001497          	auipc	s1,0x1
 14e:	c3648493          	addi	s1,s1,-970 # d80 <b_started>
 152:	00001917          	auipc	s2,0x1
 156:	c2a90913          	addi	s2,s2,-982 # d7c <c_started>
 15a:	a029                	j	164 <thread_a+0x44>
    thread_yield();
 15c:	00000097          	auipc	ra,0x0
 160:	f9c080e7          	jalr	-100(ra) # f8 <thread_yield>
  while(b_started == 0 || c_started == 0)
 164:	409c                	lw	a5,0(s1)
 166:	2781                	sext.w	a5,a5
 168:	dbf5                	beqz	a5,15c <thread_a+0x3c>
 16a:	00092783          	lw	a5,0(s2)
 16e:	2781                	sext.w	a5,a5
 170:	d7f5                	beqz	a5,15c <thread_a+0x3c>
  
  for (i = 0; i < 100; i++) {
 172:	4481                	li	s1,0
    printf("thread_a %d\n", i);
 174:	00001a17          	auipc	s4,0x1
 178:	b1ca0a13          	addi	s4,s4,-1252 # c90 <malloc+0x12a>
    a_n += 1;
 17c:	00001917          	auipc	s2,0x1
 180:	bfc90913          	addi	s2,s2,-1028 # d78 <a_n>
  for (i = 0; i < 100; i++) {
 184:	06400993          	li	s3,100
    printf("thread_a %d\n", i);
 188:	85a6                	mv	a1,s1
 18a:	8552                	mv	a0,s4
 18c:	00001097          	auipc	ra,0x1
 190:	91c080e7          	jalr	-1764(ra) # aa8 <printf>
    a_n += 1;
 194:	00092783          	lw	a5,0(s2)
 198:	2785                	addiw	a5,a5,1
 19a:	00f92023          	sw	a5,0(s2)
    thread_yield();
 19e:	00000097          	auipc	ra,0x0
 1a2:	f5a080e7          	jalr	-166(ra) # f8 <thread_yield>
  for (i = 0; i < 100; i++) {
 1a6:	2485                	addiw	s1,s1,1
 1a8:	ff3490e3          	bne	s1,s3,188 <thread_a+0x68>
  }
  printf("thread_a: exit after %d\n", a_n);
 1ac:	00001597          	auipc	a1,0x1
 1b0:	bcc5a583          	lw	a1,-1076(a1) # d78 <a_n>
 1b4:	00001517          	auipc	a0,0x1
 1b8:	aec50513          	addi	a0,a0,-1300 # ca0 <malloc+0x13a>
 1bc:	00001097          	auipc	ra,0x1
 1c0:	8ec080e7          	jalr	-1812(ra) # aa8 <printf>

  current_thread->state = FREE;
 1c4:	00001797          	auipc	a5,0x1
 1c8:	bc47b783          	ld	a5,-1084(a5) # d88 <current_thread>
 1cc:	6709                	lui	a4,0x2
 1ce:	97ba                	add	a5,a5,a4
 1d0:	0007a023          	sw	zero,0(a5)
  thread_schedule();
 1d4:	00000097          	auipc	ra,0x0
 1d8:	e52080e7          	jalr	-430(ra) # 26 <thread_schedule>
}
 1dc:	70a2                	ld	ra,40(sp)
 1de:	7402                	ld	s0,32(sp)
 1e0:	64e2                	ld	s1,24(sp)
 1e2:	6942                	ld	s2,16(sp)
 1e4:	69a2                	ld	s3,8(sp)
 1e6:	6a02                	ld	s4,0(sp)
 1e8:	6145                	addi	sp,sp,48
 1ea:	8082                	ret

00000000000001ec <thread_b>:

void 
thread_b(void)
{
 1ec:	7179                	addi	sp,sp,-48
 1ee:	f406                	sd	ra,40(sp)
 1f0:	f022                	sd	s0,32(sp)
 1f2:	ec26                	sd	s1,24(sp)
 1f4:	e84a                	sd	s2,16(sp)
 1f6:	e44e                	sd	s3,8(sp)
 1f8:	e052                	sd	s4,0(sp)
 1fa:	1800                	addi	s0,sp,48
  int i;
  printf("thread_b started\n");
 1fc:	00001517          	auipc	a0,0x1
 200:	ac450513          	addi	a0,a0,-1340 # cc0 <malloc+0x15a>
 204:	00001097          	auipc	ra,0x1
 208:	8a4080e7          	jalr	-1884(ra) # aa8 <printf>
  b_started = 1;
 20c:	4785                	li	a5,1
 20e:	00001717          	auipc	a4,0x1
 212:	b6f72923          	sw	a5,-1166(a4) # d80 <b_started>
  while(a_started == 0 || c_started == 0)
 216:	00001497          	auipc	s1,0x1
 21a:	b6e48493          	addi	s1,s1,-1170 # d84 <a_started>
 21e:	00001917          	auipc	s2,0x1
 222:	b5e90913          	addi	s2,s2,-1186 # d7c <c_started>
 226:	a029                	j	230 <thread_b+0x44>
    thread_yield();
 228:	00000097          	auipc	ra,0x0
 22c:	ed0080e7          	jalr	-304(ra) # f8 <thread_yield>
  while(a_started == 0 || c_started == 0)
 230:	409c                	lw	a5,0(s1)
 232:	2781                	sext.w	a5,a5
 234:	dbf5                	beqz	a5,228 <thread_b+0x3c>
 236:	00092783          	lw	a5,0(s2)
 23a:	2781                	sext.w	a5,a5
 23c:	d7f5                	beqz	a5,228 <thread_b+0x3c>
  
  for (i = 0; i < 100; i++) {
 23e:	4481                	li	s1,0
    printf("thread_b %d\n", i);
 240:	00001a17          	auipc	s4,0x1
 244:	a98a0a13          	addi	s4,s4,-1384 # cd8 <malloc+0x172>
    b_n += 1;
 248:	00001917          	auipc	s2,0x1
 24c:	b2c90913          	addi	s2,s2,-1236 # d74 <b_n>
  for (i = 0; i < 100; i++) {
 250:	06400993          	li	s3,100
    printf("thread_b %d\n", i);
 254:	85a6                	mv	a1,s1
 256:	8552                	mv	a0,s4
 258:	00001097          	auipc	ra,0x1
 25c:	850080e7          	jalr	-1968(ra) # aa8 <printf>
    b_n += 1;
 260:	00092783          	lw	a5,0(s2)
 264:	2785                	addiw	a5,a5,1
 266:	00f92023          	sw	a5,0(s2)
    thread_yield();
 26a:	00000097          	auipc	ra,0x0
 26e:	e8e080e7          	jalr	-370(ra) # f8 <thread_yield>
  for (i = 0; i < 100; i++) {
 272:	2485                	addiw	s1,s1,1
 274:	ff3490e3          	bne	s1,s3,254 <thread_b+0x68>
  }
  printf("thread_b: exit after %d\n", b_n);
 278:	00001597          	auipc	a1,0x1
 27c:	afc5a583          	lw	a1,-1284(a1) # d74 <b_n>
 280:	00001517          	auipc	a0,0x1
 284:	a6850513          	addi	a0,a0,-1432 # ce8 <malloc+0x182>
 288:	00001097          	auipc	ra,0x1
 28c:	820080e7          	jalr	-2016(ra) # aa8 <printf>

  current_thread->state = FREE;
 290:	00001797          	auipc	a5,0x1
 294:	af87b783          	ld	a5,-1288(a5) # d88 <current_thread>
 298:	6709                	lui	a4,0x2
 29a:	97ba                	add	a5,a5,a4
 29c:	0007a023          	sw	zero,0(a5)
  thread_schedule();
 2a0:	00000097          	auipc	ra,0x0
 2a4:	d86080e7          	jalr	-634(ra) # 26 <thread_schedule>
}
 2a8:	70a2                	ld	ra,40(sp)
 2aa:	7402                	ld	s0,32(sp)
 2ac:	64e2                	ld	s1,24(sp)
 2ae:	6942                	ld	s2,16(sp)
 2b0:	69a2                	ld	s3,8(sp)
 2b2:	6a02                	ld	s4,0(sp)
 2b4:	6145                	addi	sp,sp,48
 2b6:	8082                	ret

00000000000002b8 <thread_c>:

void 
thread_c(void)
{
 2b8:	7179                	addi	sp,sp,-48
 2ba:	f406                	sd	ra,40(sp)
 2bc:	f022                	sd	s0,32(sp)
 2be:	ec26                	sd	s1,24(sp)
 2c0:	e84a                	sd	s2,16(sp)
 2c2:	e44e                	sd	s3,8(sp)
 2c4:	e052                	sd	s4,0(sp)
 2c6:	1800                	addi	s0,sp,48
  int i;
  printf("thread_c started\n");
 2c8:	00001517          	auipc	a0,0x1
 2cc:	a4050513          	addi	a0,a0,-1472 # d08 <malloc+0x1a2>
 2d0:	00000097          	auipc	ra,0x0
 2d4:	7d8080e7          	jalr	2008(ra) # aa8 <printf>
  c_started = 1;
 2d8:	4785                	li	a5,1
 2da:	00001717          	auipc	a4,0x1
 2de:	aaf72123          	sw	a5,-1374(a4) # d7c <c_started>
  while(a_started == 0 || b_started == 0)
 2e2:	00001497          	auipc	s1,0x1
 2e6:	aa248493          	addi	s1,s1,-1374 # d84 <a_started>
 2ea:	00001917          	auipc	s2,0x1
 2ee:	a9690913          	addi	s2,s2,-1386 # d80 <b_started>
 2f2:	a029                	j	2fc <thread_c+0x44>
    thread_yield();
 2f4:	00000097          	auipc	ra,0x0
 2f8:	e04080e7          	jalr	-508(ra) # f8 <thread_yield>
  while(a_started == 0 || b_started == 0)
 2fc:	409c                	lw	a5,0(s1)
 2fe:	2781                	sext.w	a5,a5
 300:	dbf5                	beqz	a5,2f4 <thread_c+0x3c>
 302:	00092783          	lw	a5,0(s2)
 306:	2781                	sext.w	a5,a5
 308:	d7f5                	beqz	a5,2f4 <thread_c+0x3c>
  
  for (i = 0; i < 100; i++) {
 30a:	4481                	li	s1,0
    printf("thread_c %d\n", i);
 30c:	00001a17          	auipc	s4,0x1
 310:	a14a0a13          	addi	s4,s4,-1516 # d20 <malloc+0x1ba>
    c_n += 1;
 314:	00001917          	auipc	s2,0x1
 318:	a5c90913          	addi	s2,s2,-1444 # d70 <c_n>
  for (i = 0; i < 100; i++) {
 31c:	06400993          	li	s3,100
    printf("thread_c %d\n", i);
 320:	85a6                	mv	a1,s1
 322:	8552                	mv	a0,s4
 324:	00000097          	auipc	ra,0x0
 328:	784080e7          	jalr	1924(ra) # aa8 <printf>
    c_n += 1;
 32c:	00092783          	lw	a5,0(s2)
 330:	2785                	addiw	a5,a5,1
 332:	00f92023          	sw	a5,0(s2)
    thread_yield();
 336:	00000097          	auipc	ra,0x0
 33a:	dc2080e7          	jalr	-574(ra) # f8 <thread_yield>
  for (i = 0; i < 100; i++) {
 33e:	2485                	addiw	s1,s1,1
 340:	ff3490e3          	bne	s1,s3,320 <thread_c+0x68>
  }
  printf("thread_c: exit after %d\n", c_n);
 344:	00001597          	auipc	a1,0x1
 348:	a2c5a583          	lw	a1,-1492(a1) # d70 <c_n>
 34c:	00001517          	auipc	a0,0x1
 350:	9e450513          	addi	a0,a0,-1564 # d30 <malloc+0x1ca>
 354:	00000097          	auipc	ra,0x0
 358:	754080e7          	jalr	1876(ra) # aa8 <printf>

  current_thread->state = FREE;
 35c:	00001797          	auipc	a5,0x1
 360:	a2c7b783          	ld	a5,-1492(a5) # d88 <current_thread>
 364:	6709                	lui	a4,0x2
 366:	97ba                	add	a5,a5,a4
 368:	0007a023          	sw	zero,0(a5)
  thread_schedule();
 36c:	00000097          	auipc	ra,0x0
 370:	cba080e7          	jalr	-838(ra) # 26 <thread_schedule>
}
 374:	70a2                	ld	ra,40(sp)
 376:	7402                	ld	s0,32(sp)
 378:	64e2                	ld	s1,24(sp)
 37a:	6942                	ld	s2,16(sp)
 37c:	69a2                	ld	s3,8(sp)
 37e:	6a02                	ld	s4,0(sp)
 380:	6145                	addi	sp,sp,48
 382:	8082                	ret

0000000000000384 <main>:

int 
main(int argc, char *argv[]) 
{
 384:	1141                	addi	sp,sp,-16
 386:	e406                	sd	ra,8(sp)
 388:	e022                	sd	s0,0(sp)
 38a:	0800                	addi	s0,sp,16
  a_started = b_started = c_started = 0;
 38c:	00001797          	auipc	a5,0x1
 390:	9e07a823          	sw	zero,-1552(a5) # d7c <c_started>
 394:	00001797          	auipc	a5,0x1
 398:	9e07a623          	sw	zero,-1556(a5) # d80 <b_started>
 39c:	00001797          	auipc	a5,0x1
 3a0:	9e07a423          	sw	zero,-1560(a5) # d84 <a_started>
  a_n = b_n = c_n = 0;
 3a4:	00001797          	auipc	a5,0x1
 3a8:	9c07a623          	sw	zero,-1588(a5) # d70 <c_n>
 3ac:	00001797          	auipc	a5,0x1
 3b0:	9c07a423          	sw	zero,-1592(a5) # d74 <b_n>
 3b4:	00001797          	auipc	a5,0x1
 3b8:	9c07a223          	sw	zero,-1596(a5) # d78 <a_n>
  thread_init();
 3bc:	00000097          	auipc	ra,0x0
 3c0:	c44080e7          	jalr	-956(ra) # 0 <thread_init>
  thread_create(thread_a);
 3c4:	00000517          	auipc	a0,0x0
 3c8:	d5c50513          	addi	a0,a0,-676 # 120 <thread_a>
 3cc:	00000097          	auipc	ra,0x0
 3d0:	cea080e7          	jalr	-790(ra) # b6 <thread_create>
  thread_create(thread_b);
 3d4:	00000517          	auipc	a0,0x0
 3d8:	e1850513          	addi	a0,a0,-488 # 1ec <thread_b>
 3dc:	00000097          	auipc	ra,0x0
 3e0:	cda080e7          	jalr	-806(ra) # b6 <thread_create>
  thread_create(thread_c);
 3e4:	00000517          	auipc	a0,0x0
 3e8:	ed450513          	addi	a0,a0,-300 # 2b8 <thread_c>
 3ec:	00000097          	auipc	ra,0x0
 3f0:	cca080e7          	jalr	-822(ra) # b6 <thread_create>
  current_thread->state = FREE;
 3f4:	00001797          	auipc	a5,0x1
 3f8:	9947b783          	ld	a5,-1644(a5) # d88 <current_thread>
 3fc:	6709                	lui	a4,0x2
 3fe:	97ba                	add	a5,a5,a4
 400:	0007a023          	sw	zero,0(a5)
  thread_schedule();
 404:	00000097          	auipc	ra,0x0
 408:	c22080e7          	jalr	-990(ra) # 26 <thread_schedule>
  exit(0);
 40c:	4501                	li	a0,0
 40e:	00000097          	auipc	ra,0x0
 412:	312080e7          	jalr	786(ra) # 720 <exit>

0000000000000416 <thread_switch>:
         */

	.globl thread_switch
thread_switch:
	/* YOUR CODE HERE */
 		sd ra, 0(a0)
 416:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
 41a:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
 41e:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
 420:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
 422:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
 426:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
 42a:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
 42e:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
 432:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
 436:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
 43a:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
 43e:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
 442:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
 446:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
 44a:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
 44e:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
 452:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
 454:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
 456:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
 45a:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
 45e:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
 462:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
 466:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
 46a:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
 46e:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
 472:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
 476:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
 47a:	0685bd83          	ld	s11,104(a1)
        
	ret    /* return to ra */
 47e:	8082                	ret

0000000000000480 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 480:	1141                	addi	sp,sp,-16
 482:	e406                	sd	ra,8(sp)
 484:	e022                	sd	s0,0(sp)
 486:	0800                	addi	s0,sp,16
  extern int main();
  main();
 488:	00000097          	auipc	ra,0x0
 48c:	efc080e7          	jalr	-260(ra) # 384 <main>
  exit(0);
 490:	4501                	li	a0,0
 492:	00000097          	auipc	ra,0x0
 496:	28e080e7          	jalr	654(ra) # 720 <exit>

000000000000049a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 49a:	1141                	addi	sp,sp,-16
 49c:	e422                	sd	s0,8(sp)
 49e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 4a0:	87aa                	mv	a5,a0
 4a2:	0585                	addi	a1,a1,1
 4a4:	0785                	addi	a5,a5,1
 4a6:	fff5c703          	lbu	a4,-1(a1)
 4aa:	fee78fa3          	sb	a4,-1(a5)
 4ae:	fb75                	bnez	a4,4a2 <strcpy+0x8>
    ;
  return os;
}
 4b0:	6422                	ld	s0,8(sp)
 4b2:	0141                	addi	sp,sp,16
 4b4:	8082                	ret

00000000000004b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4b6:	1141                	addi	sp,sp,-16
 4b8:	e422                	sd	s0,8(sp)
 4ba:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 4bc:	00054783          	lbu	a5,0(a0)
 4c0:	cb91                	beqz	a5,4d4 <strcmp+0x1e>
 4c2:	0005c703          	lbu	a4,0(a1)
 4c6:	00f71763          	bne	a4,a5,4d4 <strcmp+0x1e>
    p++, q++;
 4ca:	0505                	addi	a0,a0,1
 4cc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 4ce:	00054783          	lbu	a5,0(a0)
 4d2:	fbe5                	bnez	a5,4c2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 4d4:	0005c503          	lbu	a0,0(a1)
}
 4d8:	40a7853b          	subw	a0,a5,a0
 4dc:	6422                	ld	s0,8(sp)
 4de:	0141                	addi	sp,sp,16
 4e0:	8082                	ret

00000000000004e2 <strlen>:

uint
strlen(const char *s)
{
 4e2:	1141                	addi	sp,sp,-16
 4e4:	e422                	sd	s0,8(sp)
 4e6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 4e8:	00054783          	lbu	a5,0(a0)
 4ec:	cf91                	beqz	a5,508 <strlen+0x26>
 4ee:	0505                	addi	a0,a0,1
 4f0:	87aa                	mv	a5,a0
 4f2:	4685                	li	a3,1
 4f4:	9e89                	subw	a3,a3,a0
 4f6:	00f6853b          	addw	a0,a3,a5
 4fa:	0785                	addi	a5,a5,1
 4fc:	fff7c703          	lbu	a4,-1(a5)
 500:	fb7d                	bnez	a4,4f6 <strlen+0x14>
    ;
  return n;
}
 502:	6422                	ld	s0,8(sp)
 504:	0141                	addi	sp,sp,16
 506:	8082                	ret
  for(n = 0; s[n]; n++)
 508:	4501                	li	a0,0
 50a:	bfe5                	j	502 <strlen+0x20>

000000000000050c <memset>:

void*
memset(void *dst, int c, uint n)
{
 50c:	1141                	addi	sp,sp,-16
 50e:	e422                	sd	s0,8(sp)
 510:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 512:	ce09                	beqz	a2,52c <memset+0x20>
 514:	87aa                	mv	a5,a0
 516:	fff6071b          	addiw	a4,a2,-1
 51a:	1702                	slli	a4,a4,0x20
 51c:	9301                	srli	a4,a4,0x20
 51e:	0705                	addi	a4,a4,1
 520:	972a                	add	a4,a4,a0
    cdst[i] = c;
 522:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 526:	0785                	addi	a5,a5,1
 528:	fee79de3          	bne	a5,a4,522 <memset+0x16>
  }
  return dst;
}
 52c:	6422                	ld	s0,8(sp)
 52e:	0141                	addi	sp,sp,16
 530:	8082                	ret

0000000000000532 <strchr>:

char*
strchr(const char *s, char c)
{
 532:	1141                	addi	sp,sp,-16
 534:	e422                	sd	s0,8(sp)
 536:	0800                	addi	s0,sp,16
  for(; *s; s++)
 538:	00054783          	lbu	a5,0(a0)
 53c:	cb99                	beqz	a5,552 <strchr+0x20>
    if(*s == c)
 53e:	00f58763          	beq	a1,a5,54c <strchr+0x1a>
  for(; *s; s++)
 542:	0505                	addi	a0,a0,1
 544:	00054783          	lbu	a5,0(a0)
 548:	fbfd                	bnez	a5,53e <strchr+0xc>
      return (char*)s;
  return 0;
 54a:	4501                	li	a0,0
}
 54c:	6422                	ld	s0,8(sp)
 54e:	0141                	addi	sp,sp,16
 550:	8082                	ret
  return 0;
 552:	4501                	li	a0,0
 554:	bfe5                	j	54c <strchr+0x1a>

0000000000000556 <gets>:

char*
gets(char *buf, int max)
{
 556:	711d                	addi	sp,sp,-96
 558:	ec86                	sd	ra,88(sp)
 55a:	e8a2                	sd	s0,80(sp)
 55c:	e4a6                	sd	s1,72(sp)
 55e:	e0ca                	sd	s2,64(sp)
 560:	fc4e                	sd	s3,56(sp)
 562:	f852                	sd	s4,48(sp)
 564:	f456                	sd	s5,40(sp)
 566:	f05a                	sd	s6,32(sp)
 568:	ec5e                	sd	s7,24(sp)
 56a:	1080                	addi	s0,sp,96
 56c:	8baa                	mv	s7,a0
 56e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 570:	892a                	mv	s2,a0
 572:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 574:	4aa9                	li	s5,10
 576:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 578:	89a6                	mv	s3,s1
 57a:	2485                	addiw	s1,s1,1
 57c:	0344d863          	bge	s1,s4,5ac <gets+0x56>
    cc = read(0, &c, 1);
 580:	4605                	li	a2,1
 582:	faf40593          	addi	a1,s0,-81
 586:	4501                	li	a0,0
 588:	00000097          	auipc	ra,0x0
 58c:	1b0080e7          	jalr	432(ra) # 738 <read>
    if(cc < 1)
 590:	00a05e63          	blez	a0,5ac <gets+0x56>
    buf[i++] = c;
 594:	faf44783          	lbu	a5,-81(s0)
 598:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 59c:	01578763          	beq	a5,s5,5aa <gets+0x54>
 5a0:	0905                	addi	s2,s2,1
 5a2:	fd679be3          	bne	a5,s6,578 <gets+0x22>
  for(i=0; i+1 < max; ){
 5a6:	89a6                	mv	s3,s1
 5a8:	a011                	j	5ac <gets+0x56>
 5aa:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 5ac:	99de                	add	s3,s3,s7
 5ae:	00098023          	sb	zero,0(s3)
  return buf;
}
 5b2:	855e                	mv	a0,s7
 5b4:	60e6                	ld	ra,88(sp)
 5b6:	6446                	ld	s0,80(sp)
 5b8:	64a6                	ld	s1,72(sp)
 5ba:	6906                	ld	s2,64(sp)
 5bc:	79e2                	ld	s3,56(sp)
 5be:	7a42                	ld	s4,48(sp)
 5c0:	7aa2                	ld	s5,40(sp)
 5c2:	7b02                	ld	s6,32(sp)
 5c4:	6be2                	ld	s7,24(sp)
 5c6:	6125                	addi	sp,sp,96
 5c8:	8082                	ret

00000000000005ca <stat>:

int
stat(const char *n, struct stat *st)
{
 5ca:	1101                	addi	sp,sp,-32
 5cc:	ec06                	sd	ra,24(sp)
 5ce:	e822                	sd	s0,16(sp)
 5d0:	e426                	sd	s1,8(sp)
 5d2:	e04a                	sd	s2,0(sp)
 5d4:	1000                	addi	s0,sp,32
 5d6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5d8:	4581                	li	a1,0
 5da:	00000097          	auipc	ra,0x0
 5de:	186080e7          	jalr	390(ra) # 760 <open>
  if(fd < 0)
 5e2:	02054563          	bltz	a0,60c <stat+0x42>
 5e6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 5e8:	85ca                	mv	a1,s2
 5ea:	00000097          	auipc	ra,0x0
 5ee:	18e080e7          	jalr	398(ra) # 778 <fstat>
 5f2:	892a                	mv	s2,a0
  close(fd);
 5f4:	8526                	mv	a0,s1
 5f6:	00000097          	auipc	ra,0x0
 5fa:	152080e7          	jalr	338(ra) # 748 <close>
  return r;
}
 5fe:	854a                	mv	a0,s2
 600:	60e2                	ld	ra,24(sp)
 602:	6442                	ld	s0,16(sp)
 604:	64a2                	ld	s1,8(sp)
 606:	6902                	ld	s2,0(sp)
 608:	6105                	addi	sp,sp,32
 60a:	8082                	ret
    return -1;
 60c:	597d                	li	s2,-1
 60e:	bfc5                	j	5fe <stat+0x34>

0000000000000610 <atoi>:

int
atoi(const char *s)
{
 610:	1141                	addi	sp,sp,-16
 612:	e422                	sd	s0,8(sp)
 614:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 616:	00054603          	lbu	a2,0(a0)
 61a:	fd06079b          	addiw	a5,a2,-48
 61e:	0ff7f793          	andi	a5,a5,255
 622:	4725                	li	a4,9
 624:	02f76963          	bltu	a4,a5,656 <atoi+0x46>
 628:	86aa                	mv	a3,a0
  n = 0;
 62a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 62c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 62e:	0685                	addi	a3,a3,1
 630:	0025179b          	slliw	a5,a0,0x2
 634:	9fa9                	addw	a5,a5,a0
 636:	0017979b          	slliw	a5,a5,0x1
 63a:	9fb1                	addw	a5,a5,a2
 63c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 640:	0006c603          	lbu	a2,0(a3)
 644:	fd06071b          	addiw	a4,a2,-48
 648:	0ff77713          	andi	a4,a4,255
 64c:	fee5f1e3          	bgeu	a1,a4,62e <atoi+0x1e>
  return n;
}
 650:	6422                	ld	s0,8(sp)
 652:	0141                	addi	sp,sp,16
 654:	8082                	ret
  n = 0;
 656:	4501                	li	a0,0
 658:	bfe5                	j	650 <atoi+0x40>

000000000000065a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 65a:	1141                	addi	sp,sp,-16
 65c:	e422                	sd	s0,8(sp)
 65e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 660:	02b57663          	bgeu	a0,a1,68c <memmove+0x32>
    while(n-- > 0)
 664:	02c05163          	blez	a2,686 <memmove+0x2c>
 668:	fff6079b          	addiw	a5,a2,-1
 66c:	1782                	slli	a5,a5,0x20
 66e:	9381                	srli	a5,a5,0x20
 670:	0785                	addi	a5,a5,1
 672:	97aa                	add	a5,a5,a0
  dst = vdst;
 674:	872a                	mv	a4,a0
      *dst++ = *src++;
 676:	0585                	addi	a1,a1,1
 678:	0705                	addi	a4,a4,1
 67a:	fff5c683          	lbu	a3,-1(a1)
 67e:	fed70fa3          	sb	a3,-1(a4) # 1fff <__global_pointer$+0xa96>
    while(n-- > 0)
 682:	fee79ae3          	bne	a5,a4,676 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 686:	6422                	ld	s0,8(sp)
 688:	0141                	addi	sp,sp,16
 68a:	8082                	ret
    dst += n;
 68c:	00c50733          	add	a4,a0,a2
    src += n;
 690:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 692:	fec05ae3          	blez	a2,686 <memmove+0x2c>
 696:	fff6079b          	addiw	a5,a2,-1
 69a:	1782                	slli	a5,a5,0x20
 69c:	9381                	srli	a5,a5,0x20
 69e:	fff7c793          	not	a5,a5
 6a2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 6a4:	15fd                	addi	a1,a1,-1
 6a6:	177d                	addi	a4,a4,-1
 6a8:	0005c683          	lbu	a3,0(a1)
 6ac:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 6b0:	fee79ae3          	bne	a5,a4,6a4 <memmove+0x4a>
 6b4:	bfc9                	j	686 <memmove+0x2c>

00000000000006b6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 6b6:	1141                	addi	sp,sp,-16
 6b8:	e422                	sd	s0,8(sp)
 6ba:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 6bc:	ca05                	beqz	a2,6ec <memcmp+0x36>
 6be:	fff6069b          	addiw	a3,a2,-1
 6c2:	1682                	slli	a3,a3,0x20
 6c4:	9281                	srli	a3,a3,0x20
 6c6:	0685                	addi	a3,a3,1
 6c8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 6ca:	00054783          	lbu	a5,0(a0)
 6ce:	0005c703          	lbu	a4,0(a1)
 6d2:	00e79863          	bne	a5,a4,6e2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 6d6:	0505                	addi	a0,a0,1
    p2++;
 6d8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 6da:	fed518e3          	bne	a0,a3,6ca <memcmp+0x14>
  }
  return 0;
 6de:	4501                	li	a0,0
 6e0:	a019                	j	6e6 <memcmp+0x30>
      return *p1 - *p2;
 6e2:	40e7853b          	subw	a0,a5,a4
}
 6e6:	6422                	ld	s0,8(sp)
 6e8:	0141                	addi	sp,sp,16
 6ea:	8082                	ret
  return 0;
 6ec:	4501                	li	a0,0
 6ee:	bfe5                	j	6e6 <memcmp+0x30>

00000000000006f0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 6f0:	1141                	addi	sp,sp,-16
 6f2:	e406                	sd	ra,8(sp)
 6f4:	e022                	sd	s0,0(sp)
 6f6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 6f8:	00000097          	auipc	ra,0x0
 6fc:	f62080e7          	jalr	-158(ra) # 65a <memmove>
}
 700:	60a2                	ld	ra,8(sp)
 702:	6402                	ld	s0,0(sp)
 704:	0141                	addi	sp,sp,16
 706:	8082                	ret

0000000000000708 <ugetpid>:
  int pid;  // Process ID
};

int
ugetpid(void)
{
 708:	1141                	addi	sp,sp,-16
 70a:	e422                	sd	s0,8(sp)
 70c:	0800                	addi	s0,sp,16
  struct usyscall *u = (struct usyscall *)USYSCALL;
  return u->pid;
}
 70e:	00002503          	lw	a0,0(zero) # 0 <thread_init>
 712:	6422                	ld	s0,8(sp)
 714:	0141                	addi	sp,sp,16
 716:	8082                	ret

0000000000000718 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 718:	4885                	li	a7,1
 ecall
 71a:	00000073          	ecall
 ret
 71e:	8082                	ret

0000000000000720 <exit>:
.global exit
exit:
 li a7, SYS_exit
 720:	4889                	li	a7,2
 ecall
 722:	00000073          	ecall
 ret
 726:	8082                	ret

0000000000000728 <wait>:
.global wait
wait:
 li a7, SYS_wait
 728:	488d                	li	a7,3
 ecall
 72a:	00000073          	ecall
 ret
 72e:	8082                	ret

0000000000000730 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 730:	4891                	li	a7,4
 ecall
 732:	00000073          	ecall
 ret
 736:	8082                	ret

0000000000000738 <read>:
.global read
read:
 li a7, SYS_read
 738:	4895                	li	a7,5
 ecall
 73a:	00000073          	ecall
 ret
 73e:	8082                	ret

0000000000000740 <write>:
.global write
write:
 li a7, SYS_write
 740:	48c1                	li	a7,16
 ecall
 742:	00000073          	ecall
 ret
 746:	8082                	ret

0000000000000748 <close>:
.global close
close:
 li a7, SYS_close
 748:	48d5                	li	a7,21
 ecall
 74a:	00000073          	ecall
 ret
 74e:	8082                	ret

0000000000000750 <kill>:
.global kill
kill:
 li a7, SYS_kill
 750:	4899                	li	a7,6
 ecall
 752:	00000073          	ecall
 ret
 756:	8082                	ret

0000000000000758 <exec>:
.global exec
exec:
 li a7, SYS_exec
 758:	489d                	li	a7,7
 ecall
 75a:	00000073          	ecall
 ret
 75e:	8082                	ret

0000000000000760 <open>:
.global open
open:
 li a7, SYS_open
 760:	48bd                	li	a7,15
 ecall
 762:	00000073          	ecall
 ret
 766:	8082                	ret

0000000000000768 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 768:	48c5                	li	a7,17
 ecall
 76a:	00000073          	ecall
 ret
 76e:	8082                	ret

0000000000000770 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 770:	48c9                	li	a7,18
 ecall
 772:	00000073          	ecall
 ret
 776:	8082                	ret

0000000000000778 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 778:	48a1                	li	a7,8
 ecall
 77a:	00000073          	ecall
 ret
 77e:	8082                	ret

0000000000000780 <link>:
.global link
link:
 li a7, SYS_link
 780:	48cd                	li	a7,19
 ecall
 782:	00000073          	ecall
 ret
 786:	8082                	ret

0000000000000788 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 788:	48d1                	li	a7,20
 ecall
 78a:	00000073          	ecall
 ret
 78e:	8082                	ret

0000000000000790 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 790:	48a5                	li	a7,9
 ecall
 792:	00000073          	ecall
 ret
 796:	8082                	ret

0000000000000798 <dup>:
.global dup
dup:
 li a7, SYS_dup
 798:	48a9                	li	a7,10
 ecall
 79a:	00000073          	ecall
 ret
 79e:	8082                	ret

00000000000007a0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 7a0:	48ad                	li	a7,11
 ecall
 7a2:	00000073          	ecall
 ret
 7a6:	8082                	ret

00000000000007a8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 7a8:	48b1                	li	a7,12
 ecall
 7aa:	00000073          	ecall
 ret
 7ae:	8082                	ret

00000000000007b0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 7b0:	48b5                	li	a7,13
 ecall
 7b2:	00000073          	ecall
 ret
 7b6:	8082                	ret

00000000000007b8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 7b8:	48b9                	li	a7,14
 ecall
 7ba:	00000073          	ecall
 ret
 7be:	8082                	ret

00000000000007c0 <trace>:
.global trace
trace:
 li a7, SYS_trace
 7c0:	48d9                	li	a7,22
 ecall
 7c2:	00000073          	ecall
 ret
 7c6:	8082                	ret

00000000000007c8 <yield>:
.global yield
yield:
 li a7, SYS_yield
 7c8:	48dd                	li	a7,23
 ecall
 7ca:	00000073          	ecall
 ret
 7ce:	8082                	ret

00000000000007d0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 7d0:	1101                	addi	sp,sp,-32
 7d2:	ec06                	sd	ra,24(sp)
 7d4:	e822                	sd	s0,16(sp)
 7d6:	1000                	addi	s0,sp,32
 7d8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 7dc:	4605                	li	a2,1
 7de:	fef40593          	addi	a1,s0,-17
 7e2:	00000097          	auipc	ra,0x0
 7e6:	f5e080e7          	jalr	-162(ra) # 740 <write>
}
 7ea:	60e2                	ld	ra,24(sp)
 7ec:	6442                	ld	s0,16(sp)
 7ee:	6105                	addi	sp,sp,32
 7f0:	8082                	ret

00000000000007f2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7f2:	7139                	addi	sp,sp,-64
 7f4:	fc06                	sd	ra,56(sp)
 7f6:	f822                	sd	s0,48(sp)
 7f8:	f426                	sd	s1,40(sp)
 7fa:	f04a                	sd	s2,32(sp)
 7fc:	ec4e                	sd	s3,24(sp)
 7fe:	0080                	addi	s0,sp,64
 800:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 802:	c299                	beqz	a3,808 <printint+0x16>
 804:	0805c863          	bltz	a1,894 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 808:	2581                	sext.w	a1,a1
  neg = 0;
 80a:	4881                	li	a7,0
 80c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 810:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 812:	2601                	sext.w	a2,a2
 814:	00000517          	auipc	a0,0x0
 818:	54450513          	addi	a0,a0,1348 # d58 <digits>
 81c:	883a                	mv	a6,a4
 81e:	2705                	addiw	a4,a4,1
 820:	02c5f7bb          	remuw	a5,a1,a2
 824:	1782                	slli	a5,a5,0x20
 826:	9381                	srli	a5,a5,0x20
 828:	97aa                	add	a5,a5,a0
 82a:	0007c783          	lbu	a5,0(a5)
 82e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 832:	0005879b          	sext.w	a5,a1
 836:	02c5d5bb          	divuw	a1,a1,a2
 83a:	0685                	addi	a3,a3,1
 83c:	fec7f0e3          	bgeu	a5,a2,81c <printint+0x2a>
  if(neg)
 840:	00088b63          	beqz	a7,856 <printint+0x64>
    buf[i++] = '-';
 844:	fd040793          	addi	a5,s0,-48
 848:	973e                	add	a4,a4,a5
 84a:	02d00793          	li	a5,45
 84e:	fef70823          	sb	a5,-16(a4)
 852:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 856:	02e05863          	blez	a4,886 <printint+0x94>
 85a:	fc040793          	addi	a5,s0,-64
 85e:	00e78933          	add	s2,a5,a4
 862:	fff78993          	addi	s3,a5,-1
 866:	99ba                	add	s3,s3,a4
 868:	377d                	addiw	a4,a4,-1
 86a:	1702                	slli	a4,a4,0x20
 86c:	9301                	srli	a4,a4,0x20
 86e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 872:	fff94583          	lbu	a1,-1(s2)
 876:	8526                	mv	a0,s1
 878:	00000097          	auipc	ra,0x0
 87c:	f58080e7          	jalr	-168(ra) # 7d0 <putc>
  while(--i >= 0)
 880:	197d                	addi	s2,s2,-1
 882:	ff3918e3          	bne	s2,s3,872 <printint+0x80>
}
 886:	70e2                	ld	ra,56(sp)
 888:	7442                	ld	s0,48(sp)
 88a:	74a2                	ld	s1,40(sp)
 88c:	7902                	ld	s2,32(sp)
 88e:	69e2                	ld	s3,24(sp)
 890:	6121                	addi	sp,sp,64
 892:	8082                	ret
    x = -xx;
 894:	40b005bb          	negw	a1,a1
    neg = 1;
 898:	4885                	li	a7,1
    x = -xx;
 89a:	bf8d                	j	80c <printint+0x1a>

000000000000089c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 89c:	7119                	addi	sp,sp,-128
 89e:	fc86                	sd	ra,120(sp)
 8a0:	f8a2                	sd	s0,112(sp)
 8a2:	f4a6                	sd	s1,104(sp)
 8a4:	f0ca                	sd	s2,96(sp)
 8a6:	ecce                	sd	s3,88(sp)
 8a8:	e8d2                	sd	s4,80(sp)
 8aa:	e4d6                	sd	s5,72(sp)
 8ac:	e0da                	sd	s6,64(sp)
 8ae:	fc5e                	sd	s7,56(sp)
 8b0:	f862                	sd	s8,48(sp)
 8b2:	f466                	sd	s9,40(sp)
 8b4:	f06a                	sd	s10,32(sp)
 8b6:	ec6e                	sd	s11,24(sp)
 8b8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 8ba:	0005c903          	lbu	s2,0(a1)
 8be:	18090f63          	beqz	s2,a5c <vprintf+0x1c0>
 8c2:	8aaa                	mv	s5,a0
 8c4:	8b32                	mv	s6,a2
 8c6:	00158493          	addi	s1,a1,1
  state = 0;
 8ca:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 8cc:	02500a13          	li	s4,37
      if(c == 'd'){
 8d0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 8d4:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 8d8:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 8dc:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8e0:	00000b97          	auipc	s7,0x0
 8e4:	478b8b93          	addi	s7,s7,1144 # d58 <digits>
 8e8:	a839                	j	906 <vprintf+0x6a>
        putc(fd, c);
 8ea:	85ca                	mv	a1,s2
 8ec:	8556                	mv	a0,s5
 8ee:	00000097          	auipc	ra,0x0
 8f2:	ee2080e7          	jalr	-286(ra) # 7d0 <putc>
 8f6:	a019                	j	8fc <vprintf+0x60>
    } else if(state == '%'){
 8f8:	01498f63          	beq	s3,s4,916 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 8fc:	0485                	addi	s1,s1,1
 8fe:	fff4c903          	lbu	s2,-1(s1)
 902:	14090d63          	beqz	s2,a5c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 906:	0009079b          	sext.w	a5,s2
    if(state == 0){
 90a:	fe0997e3          	bnez	s3,8f8 <vprintf+0x5c>
      if(c == '%'){
 90e:	fd479ee3          	bne	a5,s4,8ea <vprintf+0x4e>
        state = '%';
 912:	89be                	mv	s3,a5
 914:	b7e5                	j	8fc <vprintf+0x60>
      if(c == 'd'){
 916:	05878063          	beq	a5,s8,956 <vprintf+0xba>
      } else if(c == 'l') {
 91a:	05978c63          	beq	a5,s9,972 <vprintf+0xd6>
      } else if(c == 'x') {
 91e:	07a78863          	beq	a5,s10,98e <vprintf+0xf2>
      } else if(c == 'p') {
 922:	09b78463          	beq	a5,s11,9aa <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 926:	07300713          	li	a4,115
 92a:	0ce78663          	beq	a5,a4,9f6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 92e:	06300713          	li	a4,99
 932:	0ee78e63          	beq	a5,a4,a2e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 936:	11478863          	beq	a5,s4,a46 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 93a:	85d2                	mv	a1,s4
 93c:	8556                	mv	a0,s5
 93e:	00000097          	auipc	ra,0x0
 942:	e92080e7          	jalr	-366(ra) # 7d0 <putc>
        putc(fd, c);
 946:	85ca                	mv	a1,s2
 948:	8556                	mv	a0,s5
 94a:	00000097          	auipc	ra,0x0
 94e:	e86080e7          	jalr	-378(ra) # 7d0 <putc>
      }
      state = 0;
 952:	4981                	li	s3,0
 954:	b765                	j	8fc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 956:	008b0913          	addi	s2,s6,8
 95a:	4685                	li	a3,1
 95c:	4629                	li	a2,10
 95e:	000b2583          	lw	a1,0(s6)
 962:	8556                	mv	a0,s5
 964:	00000097          	auipc	ra,0x0
 968:	e8e080e7          	jalr	-370(ra) # 7f2 <printint>
 96c:	8b4a                	mv	s6,s2
      state = 0;
 96e:	4981                	li	s3,0
 970:	b771                	j	8fc <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 972:	008b0913          	addi	s2,s6,8
 976:	4681                	li	a3,0
 978:	4629                	li	a2,10
 97a:	000b2583          	lw	a1,0(s6)
 97e:	8556                	mv	a0,s5
 980:	00000097          	auipc	ra,0x0
 984:	e72080e7          	jalr	-398(ra) # 7f2 <printint>
 988:	8b4a                	mv	s6,s2
      state = 0;
 98a:	4981                	li	s3,0
 98c:	bf85                	j	8fc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 98e:	008b0913          	addi	s2,s6,8
 992:	4681                	li	a3,0
 994:	4641                	li	a2,16
 996:	000b2583          	lw	a1,0(s6)
 99a:	8556                	mv	a0,s5
 99c:	00000097          	auipc	ra,0x0
 9a0:	e56080e7          	jalr	-426(ra) # 7f2 <printint>
 9a4:	8b4a                	mv	s6,s2
      state = 0;
 9a6:	4981                	li	s3,0
 9a8:	bf91                	j	8fc <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 9aa:	008b0793          	addi	a5,s6,8
 9ae:	f8f43423          	sd	a5,-120(s0)
 9b2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 9b6:	03000593          	li	a1,48
 9ba:	8556                	mv	a0,s5
 9bc:	00000097          	auipc	ra,0x0
 9c0:	e14080e7          	jalr	-492(ra) # 7d0 <putc>
  putc(fd, 'x');
 9c4:	85ea                	mv	a1,s10
 9c6:	8556                	mv	a0,s5
 9c8:	00000097          	auipc	ra,0x0
 9cc:	e08080e7          	jalr	-504(ra) # 7d0 <putc>
 9d0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 9d2:	03c9d793          	srli	a5,s3,0x3c
 9d6:	97de                	add	a5,a5,s7
 9d8:	0007c583          	lbu	a1,0(a5)
 9dc:	8556                	mv	a0,s5
 9de:	00000097          	auipc	ra,0x0
 9e2:	df2080e7          	jalr	-526(ra) # 7d0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 9e6:	0992                	slli	s3,s3,0x4
 9e8:	397d                	addiw	s2,s2,-1
 9ea:	fe0914e3          	bnez	s2,9d2 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 9ee:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 9f2:	4981                	li	s3,0
 9f4:	b721                	j	8fc <vprintf+0x60>
        s = va_arg(ap, char*);
 9f6:	008b0993          	addi	s3,s6,8
 9fa:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 9fe:	02090163          	beqz	s2,a20 <vprintf+0x184>
        while(*s != 0){
 a02:	00094583          	lbu	a1,0(s2)
 a06:	c9a1                	beqz	a1,a56 <vprintf+0x1ba>
          putc(fd, *s);
 a08:	8556                	mv	a0,s5
 a0a:	00000097          	auipc	ra,0x0
 a0e:	dc6080e7          	jalr	-570(ra) # 7d0 <putc>
          s++;
 a12:	0905                	addi	s2,s2,1
        while(*s != 0){
 a14:	00094583          	lbu	a1,0(s2)
 a18:	f9e5                	bnez	a1,a08 <vprintf+0x16c>
        s = va_arg(ap, char*);
 a1a:	8b4e                	mv	s6,s3
      state = 0;
 a1c:	4981                	li	s3,0
 a1e:	bdf9                	j	8fc <vprintf+0x60>
          s = "(null)";
 a20:	00000917          	auipc	s2,0x0
 a24:	33090913          	addi	s2,s2,816 # d50 <malloc+0x1ea>
        while(*s != 0){
 a28:	02800593          	li	a1,40
 a2c:	bff1                	j	a08 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 a2e:	008b0913          	addi	s2,s6,8
 a32:	000b4583          	lbu	a1,0(s6)
 a36:	8556                	mv	a0,s5
 a38:	00000097          	auipc	ra,0x0
 a3c:	d98080e7          	jalr	-616(ra) # 7d0 <putc>
 a40:	8b4a                	mv	s6,s2
      state = 0;
 a42:	4981                	li	s3,0
 a44:	bd65                	j	8fc <vprintf+0x60>
        putc(fd, c);
 a46:	85d2                	mv	a1,s4
 a48:	8556                	mv	a0,s5
 a4a:	00000097          	auipc	ra,0x0
 a4e:	d86080e7          	jalr	-634(ra) # 7d0 <putc>
      state = 0;
 a52:	4981                	li	s3,0
 a54:	b565                	j	8fc <vprintf+0x60>
        s = va_arg(ap, char*);
 a56:	8b4e                	mv	s6,s3
      state = 0;
 a58:	4981                	li	s3,0
 a5a:	b54d                	j	8fc <vprintf+0x60>
    }
  }
}
 a5c:	70e6                	ld	ra,120(sp)
 a5e:	7446                	ld	s0,112(sp)
 a60:	74a6                	ld	s1,104(sp)
 a62:	7906                	ld	s2,96(sp)
 a64:	69e6                	ld	s3,88(sp)
 a66:	6a46                	ld	s4,80(sp)
 a68:	6aa6                	ld	s5,72(sp)
 a6a:	6b06                	ld	s6,64(sp)
 a6c:	7be2                	ld	s7,56(sp)
 a6e:	7c42                	ld	s8,48(sp)
 a70:	7ca2                	ld	s9,40(sp)
 a72:	7d02                	ld	s10,32(sp)
 a74:	6de2                	ld	s11,24(sp)
 a76:	6109                	addi	sp,sp,128
 a78:	8082                	ret

0000000000000a7a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a7a:	715d                	addi	sp,sp,-80
 a7c:	ec06                	sd	ra,24(sp)
 a7e:	e822                	sd	s0,16(sp)
 a80:	1000                	addi	s0,sp,32
 a82:	e010                	sd	a2,0(s0)
 a84:	e414                	sd	a3,8(s0)
 a86:	e818                	sd	a4,16(s0)
 a88:	ec1c                	sd	a5,24(s0)
 a8a:	03043023          	sd	a6,32(s0)
 a8e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a92:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a96:	8622                	mv	a2,s0
 a98:	00000097          	auipc	ra,0x0
 a9c:	e04080e7          	jalr	-508(ra) # 89c <vprintf>
}
 aa0:	60e2                	ld	ra,24(sp)
 aa2:	6442                	ld	s0,16(sp)
 aa4:	6161                	addi	sp,sp,80
 aa6:	8082                	ret

0000000000000aa8 <printf>:

void
printf(const char *fmt, ...)
{
 aa8:	711d                	addi	sp,sp,-96
 aaa:	ec06                	sd	ra,24(sp)
 aac:	e822                	sd	s0,16(sp)
 aae:	1000                	addi	s0,sp,32
 ab0:	e40c                	sd	a1,8(s0)
 ab2:	e810                	sd	a2,16(s0)
 ab4:	ec14                	sd	a3,24(s0)
 ab6:	f018                	sd	a4,32(s0)
 ab8:	f41c                	sd	a5,40(s0)
 aba:	03043823          	sd	a6,48(s0)
 abe:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 ac2:	00840613          	addi	a2,s0,8
 ac6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 aca:	85aa                	mv	a1,a0
 acc:	4505                	li	a0,1
 ace:	00000097          	auipc	ra,0x0
 ad2:	dce080e7          	jalr	-562(ra) # 89c <vprintf>
}
 ad6:	60e2                	ld	ra,24(sp)
 ad8:	6442                	ld	s0,16(sp)
 ada:	6125                	addi	sp,sp,96
 adc:	8082                	ret

0000000000000ade <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ade:	1141                	addi	sp,sp,-16
 ae0:	e422                	sd	s0,8(sp)
 ae2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ae4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ae8:	00000797          	auipc	a5,0x0
 aec:	2a87b783          	ld	a5,680(a5) # d90 <freep>
 af0:	a805                	j	b20 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 af2:	4618                	lw	a4,8(a2)
 af4:	9db9                	addw	a1,a1,a4
 af6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 afa:	6398                	ld	a4,0(a5)
 afc:	6318                	ld	a4,0(a4)
 afe:	fee53823          	sd	a4,-16(a0)
 b02:	a091                	j	b46 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b04:	ff852703          	lw	a4,-8(a0)
 b08:	9e39                	addw	a2,a2,a4
 b0a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 b0c:	ff053703          	ld	a4,-16(a0)
 b10:	e398                	sd	a4,0(a5)
 b12:	a099                	j	b58 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b14:	6398                	ld	a4,0(a5)
 b16:	00e7e463          	bltu	a5,a4,b1e <free+0x40>
 b1a:	00e6ea63          	bltu	a3,a4,b2e <free+0x50>
{
 b1e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b20:	fed7fae3          	bgeu	a5,a3,b14 <free+0x36>
 b24:	6398                	ld	a4,0(a5)
 b26:	00e6e463          	bltu	a3,a4,b2e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b2a:	fee7eae3          	bltu	a5,a4,b1e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 b2e:	ff852583          	lw	a1,-8(a0)
 b32:	6390                	ld	a2,0(a5)
 b34:	02059713          	slli	a4,a1,0x20
 b38:	9301                	srli	a4,a4,0x20
 b3a:	0712                	slli	a4,a4,0x4
 b3c:	9736                	add	a4,a4,a3
 b3e:	fae60ae3          	beq	a2,a4,af2 <free+0x14>
    bp->s.ptr = p->s.ptr;
 b42:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b46:	4790                	lw	a2,8(a5)
 b48:	02061713          	slli	a4,a2,0x20
 b4c:	9301                	srli	a4,a4,0x20
 b4e:	0712                	slli	a4,a4,0x4
 b50:	973e                	add	a4,a4,a5
 b52:	fae689e3          	beq	a3,a4,b04 <free+0x26>
  } else
    p->s.ptr = bp;
 b56:	e394                	sd	a3,0(a5)
  freep = p;
 b58:	00000717          	auipc	a4,0x0
 b5c:	22f73c23          	sd	a5,568(a4) # d90 <freep>
}
 b60:	6422                	ld	s0,8(sp)
 b62:	0141                	addi	sp,sp,16
 b64:	8082                	ret

0000000000000b66 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b66:	7139                	addi	sp,sp,-64
 b68:	fc06                	sd	ra,56(sp)
 b6a:	f822                	sd	s0,48(sp)
 b6c:	f426                	sd	s1,40(sp)
 b6e:	f04a                	sd	s2,32(sp)
 b70:	ec4e                	sd	s3,24(sp)
 b72:	e852                	sd	s4,16(sp)
 b74:	e456                	sd	s5,8(sp)
 b76:	e05a                	sd	s6,0(sp)
 b78:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b7a:	02051493          	slli	s1,a0,0x20
 b7e:	9081                	srli	s1,s1,0x20
 b80:	04bd                	addi	s1,s1,15
 b82:	8091                	srli	s1,s1,0x4
 b84:	0014899b          	addiw	s3,s1,1
 b88:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b8a:	00000517          	auipc	a0,0x0
 b8e:	20653503          	ld	a0,518(a0) # d90 <freep>
 b92:	c515                	beqz	a0,bbe <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b94:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b96:	4798                	lw	a4,8(a5)
 b98:	02977f63          	bgeu	a4,s1,bd6 <malloc+0x70>
 b9c:	8a4e                	mv	s4,s3
 b9e:	0009871b          	sext.w	a4,s3
 ba2:	6685                	lui	a3,0x1
 ba4:	00d77363          	bgeu	a4,a3,baa <malloc+0x44>
 ba8:	6a05                	lui	s4,0x1
 baa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 bae:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 bb2:	00000917          	auipc	s2,0x0
 bb6:	1de90913          	addi	s2,s2,478 # d90 <freep>
  if(p == (char*)-1)
 bba:	5afd                	li	s5,-1
 bbc:	a88d                	j	c2e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 bbe:	00008797          	auipc	a5,0x8
 bc2:	3ba78793          	addi	a5,a5,954 # 8f78 <base>
 bc6:	00000717          	auipc	a4,0x0
 bca:	1cf73523          	sd	a5,458(a4) # d90 <freep>
 bce:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 bd0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 bd4:	b7e1                	j	b9c <malloc+0x36>
      if(p->s.size == nunits)
 bd6:	02e48b63          	beq	s1,a4,c0c <malloc+0xa6>
        p->s.size -= nunits;
 bda:	4137073b          	subw	a4,a4,s3
 bde:	c798                	sw	a4,8(a5)
        p += p->s.size;
 be0:	1702                	slli	a4,a4,0x20
 be2:	9301                	srli	a4,a4,0x20
 be4:	0712                	slli	a4,a4,0x4
 be6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 be8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 bec:	00000717          	auipc	a4,0x0
 bf0:	1aa73223          	sd	a0,420(a4) # d90 <freep>
      return (void*)(p + 1);
 bf4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 bf8:	70e2                	ld	ra,56(sp)
 bfa:	7442                	ld	s0,48(sp)
 bfc:	74a2                	ld	s1,40(sp)
 bfe:	7902                	ld	s2,32(sp)
 c00:	69e2                	ld	s3,24(sp)
 c02:	6a42                	ld	s4,16(sp)
 c04:	6aa2                	ld	s5,8(sp)
 c06:	6b02                	ld	s6,0(sp)
 c08:	6121                	addi	sp,sp,64
 c0a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 c0c:	6398                	ld	a4,0(a5)
 c0e:	e118                	sd	a4,0(a0)
 c10:	bff1                	j	bec <malloc+0x86>
  hp->s.size = nu;
 c12:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c16:	0541                	addi	a0,a0,16
 c18:	00000097          	auipc	ra,0x0
 c1c:	ec6080e7          	jalr	-314(ra) # ade <free>
  return freep;
 c20:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c24:	d971                	beqz	a0,bf8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c26:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c28:	4798                	lw	a4,8(a5)
 c2a:	fa9776e3          	bgeu	a4,s1,bd6 <malloc+0x70>
    if(p == freep)
 c2e:	00093703          	ld	a4,0(s2)
 c32:	853e                	mv	a0,a5
 c34:	fef719e3          	bne	a4,a5,c26 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 c38:	8552                	mv	a0,s4
 c3a:	00000097          	auipc	ra,0x0
 c3e:	b6e080e7          	jalr	-1170(ra) # 7a8 <sbrk>
  if(p == (char*)-1)
 c42:	fd5518e3          	bne	a0,s5,c12 <malloc+0xac>
        return 0;
 c46:	4501                	li	a0,0
 c48:	bf45                	j	bf8 <malloc+0x92>
