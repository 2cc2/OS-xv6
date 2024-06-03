
kernel/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	c2013103          	ld	sp,-992(sp) # 80008c20 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	c2e70713          	addi	a4,a4,-978 # 80008c80 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	cdc78793          	addi	a5,a5,-804 # 80005d40 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc50f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	e0e78793          	addi	a5,a5,-498 # 80000ebc <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  if(cpuid()==0){
    800000f6:	00002097          	auipc	ra,0x2
    800000fa:	8e8080e7          	jalr	-1816(ra) # 800019de <cpuid>
    800000fe:	c519                	beqz	a0,8000010c <start+0x7e>
  asm volatile("mret");
    80000100:	30200073          	mret
}
    80000104:	60a2                	ld	ra,8(sp)
    80000106:	6402                	ld	s0,0(sp)
    80000108:	0141                	addi	sp,sp,16
    8000010a:	8082                	ret
    printf("%s:%d     [162120120] in start, init driver, interrupts and change mode.\n",__FILE__,__LINE__);
    8000010c:	03600613          	li	a2,54
    80000110:	00008597          	auipc	a1,0x8
    80000114:	f0058593          	addi	a1,a1,-256 # 80008010 <etext+0x10>
    80000118:	00008517          	auipc	a0,0x8
    8000011c:	f0850513          	addi	a0,a0,-248 # 80008020 <etext+0x20>
    80000120:	00000097          	auipc	ra,0x0
    80000124:	496080e7          	jalr	1174(ra) # 800005b6 <printf>
    80000128:	bfe1                	j	80000100 <start+0x72>

000000008000012a <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    8000012a:	715d                	addi	sp,sp,-80
    8000012c:	e486                	sd	ra,72(sp)
    8000012e:	e0a2                	sd	s0,64(sp)
    80000130:	fc26                	sd	s1,56(sp)
    80000132:	f84a                	sd	s2,48(sp)
    80000134:	f44e                	sd	s3,40(sp)
    80000136:	f052                	sd	s4,32(sp)
    80000138:	ec56                	sd	s5,24(sp)
    8000013a:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    8000013c:	04c05663          	blez	a2,80000188 <consolewrite+0x5e>
    80000140:	8a2a                	mv	s4,a0
    80000142:	84ae                	mv	s1,a1
    80000144:	89b2                	mv	s3,a2
    80000146:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000148:	5afd                	li	s5,-1
    8000014a:	4685                	li	a3,1
    8000014c:	8626                	mv	a2,s1
    8000014e:	85d2                	mv	a1,s4
    80000150:	fbf40513          	addi	a0,s0,-65
    80000154:	00002097          	auipc	ra,0x2
    80000158:	4a0080e7          	jalr	1184(ra) # 800025f4 <either_copyin>
    8000015c:	01550c63          	beq	a0,s5,80000174 <consolewrite+0x4a>
      break;
    uartputc(c);
    80000160:	fbf44503          	lbu	a0,-65(s0)
    80000164:	00000097          	auipc	ra,0x0
    80000168:	794080e7          	jalr	1940(ra) # 800008f8 <uartputc>
  for(i = 0; i < n; i++){
    8000016c:	2905                	addiw	s2,s2,1
    8000016e:	0485                	addi	s1,s1,1
    80000170:	fd299de3          	bne	s3,s2,8000014a <consolewrite+0x20>
  }

  return i;
}
    80000174:	854a                	mv	a0,s2
    80000176:	60a6                	ld	ra,72(sp)
    80000178:	6406                	ld	s0,64(sp)
    8000017a:	74e2                	ld	s1,56(sp)
    8000017c:	7942                	ld	s2,48(sp)
    8000017e:	79a2                	ld	s3,40(sp)
    80000180:	7a02                	ld	s4,32(sp)
    80000182:	6ae2                	ld	s5,24(sp)
    80000184:	6161                	addi	sp,sp,80
    80000186:	8082                	ret
  for(i = 0; i < n; i++){
    80000188:	4901                	li	s2,0
    8000018a:	b7ed                	j	80000174 <consolewrite+0x4a>

000000008000018c <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000018c:	7119                	addi	sp,sp,-128
    8000018e:	fc86                	sd	ra,120(sp)
    80000190:	f8a2                	sd	s0,112(sp)
    80000192:	f4a6                	sd	s1,104(sp)
    80000194:	f0ca                	sd	s2,96(sp)
    80000196:	ecce                	sd	s3,88(sp)
    80000198:	e8d2                	sd	s4,80(sp)
    8000019a:	e4d6                	sd	s5,72(sp)
    8000019c:	e0da                	sd	s6,64(sp)
    8000019e:	fc5e                	sd	s7,56(sp)
    800001a0:	f862                	sd	s8,48(sp)
    800001a2:	f466                	sd	s9,40(sp)
    800001a4:	f06a                	sd	s10,32(sp)
    800001a6:	ec6e                	sd	s11,24(sp)
    800001a8:	0100                	addi	s0,sp,128
    800001aa:	8b2a                	mv	s6,a0
    800001ac:	8aae                	mv	s5,a1
    800001ae:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    800001b0:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    800001b4:	00011517          	auipc	a0,0x11
    800001b8:	c0c50513          	addi	a0,a0,-1012 # 80010dc0 <cons>
    800001bc:	00001097          	auipc	ra,0x1
    800001c0:	a56080e7          	jalr	-1450(ra) # 80000c12 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001c4:	00011497          	auipc	s1,0x11
    800001c8:	bfc48493          	addi	s1,s1,-1028 # 80010dc0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001cc:	89a6                	mv	s3,s1
    800001ce:	00011917          	auipc	s2,0x11
    800001d2:	c8a90913          	addi	s2,s2,-886 # 80010e58 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001d6:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001d8:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001da:	4da9                	li	s11,10
  while(n > 0){
    800001dc:	07405b63          	blez	s4,80000252 <consoleread+0xc6>
    while(cons.r == cons.w){
    800001e0:	0984a783          	lw	a5,152(s1)
    800001e4:	09c4a703          	lw	a4,156(s1)
    800001e8:	02f71763          	bne	a4,a5,80000216 <consoleread+0x8a>
      if(killed(myproc())){
    800001ec:	00002097          	auipc	ra,0x2
    800001f0:	81e080e7          	jalr	-2018(ra) # 80001a0a <myproc>
    800001f4:	00002097          	auipc	ra,0x2
    800001f8:	23e080e7          	jalr	574(ra) # 80002432 <killed>
    800001fc:	e535                	bnez	a0,80000268 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001fe:	85ce                	mv	a1,s3
    80000200:	854a                	mv	a0,s2
    80000202:	00002097          	auipc	ra,0x2
    80000206:	f62080e7          	jalr	-158(ra) # 80002164 <sleep>
    while(cons.r == cons.w){
    8000020a:	0984a783          	lw	a5,152(s1)
    8000020e:	09c4a703          	lw	a4,156(s1)
    80000212:	fcf70de3          	beq	a4,a5,800001ec <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80000216:	0017871b          	addiw	a4,a5,1
    8000021a:	08e4ac23          	sw	a4,152(s1)
    8000021e:	07f7f713          	andi	a4,a5,127
    80000222:	9726                	add	a4,a4,s1
    80000224:	01874703          	lbu	a4,24(a4)
    80000228:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    8000022c:	079c0663          	beq	s8,s9,80000298 <consoleread+0x10c>
    cbuf = c;
    80000230:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000234:	4685                	li	a3,1
    80000236:	f8f40613          	addi	a2,s0,-113
    8000023a:	85d6                	mv	a1,s5
    8000023c:	855a                	mv	a0,s6
    8000023e:	00002097          	auipc	ra,0x2
    80000242:	360080e7          	jalr	864(ra) # 8000259e <either_copyout>
    80000246:	01a50663          	beq	a0,s10,80000252 <consoleread+0xc6>
    dst++;
    8000024a:	0a85                	addi	s5,s5,1
    --n;
    8000024c:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    8000024e:	f9bc17e3          	bne	s8,s11,800001dc <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000252:	00011517          	auipc	a0,0x11
    80000256:	b6e50513          	addi	a0,a0,-1170 # 80010dc0 <cons>
    8000025a:	00001097          	auipc	ra,0x1
    8000025e:	a6c080e7          	jalr	-1428(ra) # 80000cc6 <release>

  return target - n;
    80000262:	414b853b          	subw	a0,s7,s4
    80000266:	a811                	j	8000027a <consoleread+0xee>
        release(&cons.lock);
    80000268:	00011517          	auipc	a0,0x11
    8000026c:	b5850513          	addi	a0,a0,-1192 # 80010dc0 <cons>
    80000270:	00001097          	auipc	ra,0x1
    80000274:	a56080e7          	jalr	-1450(ra) # 80000cc6 <release>
        return -1;
    80000278:	557d                	li	a0,-1
}
    8000027a:	70e6                	ld	ra,120(sp)
    8000027c:	7446                	ld	s0,112(sp)
    8000027e:	74a6                	ld	s1,104(sp)
    80000280:	7906                	ld	s2,96(sp)
    80000282:	69e6                	ld	s3,88(sp)
    80000284:	6a46                	ld	s4,80(sp)
    80000286:	6aa6                	ld	s5,72(sp)
    80000288:	6b06                	ld	s6,64(sp)
    8000028a:	7be2                	ld	s7,56(sp)
    8000028c:	7c42                	ld	s8,48(sp)
    8000028e:	7ca2                	ld	s9,40(sp)
    80000290:	7d02                	ld	s10,32(sp)
    80000292:	6de2                	ld	s11,24(sp)
    80000294:	6109                	addi	sp,sp,128
    80000296:	8082                	ret
      if(n < target){
    80000298:	000a071b          	sext.w	a4,s4
    8000029c:	fb777be3          	bgeu	a4,s7,80000252 <consoleread+0xc6>
        cons.r--;
    800002a0:	00011717          	auipc	a4,0x11
    800002a4:	baf72c23          	sw	a5,-1096(a4) # 80010e58 <cons+0x98>
    800002a8:	b76d                	j	80000252 <consoleread+0xc6>

00000000800002aa <consputc>:
{
    800002aa:	1141                	addi	sp,sp,-16
    800002ac:	e406                	sd	ra,8(sp)
    800002ae:	e022                	sd	s0,0(sp)
    800002b0:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    800002b2:	10000793          	li	a5,256
    800002b6:	00f50a63          	beq	a0,a5,800002ca <consputc+0x20>
    uartputc_sync(c);
    800002ba:	00000097          	auipc	ra,0x0
    800002be:	564080e7          	jalr	1380(ra) # 8000081e <uartputc_sync>
}
    800002c2:	60a2                	ld	ra,8(sp)
    800002c4:	6402                	ld	s0,0(sp)
    800002c6:	0141                	addi	sp,sp,16
    800002c8:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002ca:	4521                	li	a0,8
    800002cc:	00000097          	auipc	ra,0x0
    800002d0:	552080e7          	jalr	1362(ra) # 8000081e <uartputc_sync>
    800002d4:	02000513          	li	a0,32
    800002d8:	00000097          	auipc	ra,0x0
    800002dc:	546080e7          	jalr	1350(ra) # 8000081e <uartputc_sync>
    800002e0:	4521                	li	a0,8
    800002e2:	00000097          	auipc	ra,0x0
    800002e6:	53c080e7          	jalr	1340(ra) # 8000081e <uartputc_sync>
    800002ea:	bfe1                	j	800002c2 <consputc+0x18>

00000000800002ec <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ec:	1101                	addi	sp,sp,-32
    800002ee:	ec06                	sd	ra,24(sp)
    800002f0:	e822                	sd	s0,16(sp)
    800002f2:	e426                	sd	s1,8(sp)
    800002f4:	e04a                	sd	s2,0(sp)
    800002f6:	1000                	addi	s0,sp,32
    800002f8:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	ac650513          	addi	a0,a0,-1338 # 80010dc0 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	910080e7          	jalr	-1776(ra) # 80000c12 <acquire>

  switch(c){
    8000030a:	47d5                	li	a5,21
    8000030c:	0af48663          	beq	s1,a5,800003b8 <consoleintr+0xcc>
    80000310:	0297ca63          	blt	a5,s1,80000344 <consoleintr+0x58>
    80000314:	47a1                	li	a5,8
    80000316:	0ef48763          	beq	s1,a5,80000404 <consoleintr+0x118>
    8000031a:	47c1                	li	a5,16
    8000031c:	10f49a63          	bne	s1,a5,80000430 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80000320:	00002097          	auipc	ra,0x2
    80000324:	32a080e7          	jalr	810(ra) # 8000264a <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000328:	00011517          	auipc	a0,0x11
    8000032c:	a9850513          	addi	a0,a0,-1384 # 80010dc0 <cons>
    80000330:	00001097          	auipc	ra,0x1
    80000334:	996080e7          	jalr	-1642(ra) # 80000cc6 <release>
}
    80000338:	60e2                	ld	ra,24(sp)
    8000033a:	6442                	ld	s0,16(sp)
    8000033c:	64a2                	ld	s1,8(sp)
    8000033e:	6902                	ld	s2,0(sp)
    80000340:	6105                	addi	sp,sp,32
    80000342:	8082                	ret
  switch(c){
    80000344:	07f00793          	li	a5,127
    80000348:	0af48e63          	beq	s1,a5,80000404 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000034c:	00011717          	auipc	a4,0x11
    80000350:	a7470713          	addi	a4,a4,-1420 # 80010dc0 <cons>
    80000354:	0a072783          	lw	a5,160(a4)
    80000358:	09872703          	lw	a4,152(a4)
    8000035c:	9f99                	subw	a5,a5,a4
    8000035e:	07f00713          	li	a4,127
    80000362:	fcf763e3          	bltu	a4,a5,80000328 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000366:	47b5                	li	a5,13
    80000368:	0cf48763          	beq	s1,a5,80000436 <consoleintr+0x14a>
      consputc(c);
    8000036c:	8526                	mv	a0,s1
    8000036e:	00000097          	auipc	ra,0x0
    80000372:	f3c080e7          	jalr	-196(ra) # 800002aa <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	a4a78793          	addi	a5,a5,-1462 # 80010dc0 <cons>
    8000037e:	0a07a683          	lw	a3,160(a5)
    80000382:	0016871b          	addiw	a4,a3,1
    80000386:	0007061b          	sext.w	a2,a4
    8000038a:	0ae7a023          	sw	a4,160(a5)
    8000038e:	07f6f693          	andi	a3,a3,127
    80000392:	97b6                	add	a5,a5,a3
    80000394:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000398:	47a9                	li	a5,10
    8000039a:	0cf48563          	beq	s1,a5,80000464 <consoleintr+0x178>
    8000039e:	4791                	li	a5,4
    800003a0:	0cf48263          	beq	s1,a5,80000464 <consoleintr+0x178>
    800003a4:	00011797          	auipc	a5,0x11
    800003a8:	ab47a783          	lw	a5,-1356(a5) # 80010e58 <cons+0x98>
    800003ac:	9f1d                	subw	a4,a4,a5
    800003ae:	08000793          	li	a5,128
    800003b2:	f6f71be3          	bne	a4,a5,80000328 <consoleintr+0x3c>
    800003b6:	a07d                	j	80000464 <consoleintr+0x178>
    while(cons.e != cons.w &&
    800003b8:	00011717          	auipc	a4,0x11
    800003bc:	a0870713          	addi	a4,a4,-1528 # 80010dc0 <cons>
    800003c0:	0a072783          	lw	a5,160(a4)
    800003c4:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003c8:	00011497          	auipc	s1,0x11
    800003cc:	9f848493          	addi	s1,s1,-1544 # 80010dc0 <cons>
    while(cons.e != cons.w &&
    800003d0:	4929                	li	s2,10
    800003d2:	f4f70be3          	beq	a4,a5,80000328 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003d6:	37fd                	addiw	a5,a5,-1
    800003d8:	07f7f713          	andi	a4,a5,127
    800003dc:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003de:	01874703          	lbu	a4,24(a4)
    800003e2:	f52703e3          	beq	a4,s2,80000328 <consoleintr+0x3c>
      cons.e--;
    800003e6:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003ea:	10000513          	li	a0,256
    800003ee:	00000097          	auipc	ra,0x0
    800003f2:	ebc080e7          	jalr	-324(ra) # 800002aa <consputc>
    while(cons.e != cons.w &&
    800003f6:	0a04a783          	lw	a5,160(s1)
    800003fa:	09c4a703          	lw	a4,156(s1)
    800003fe:	fcf71ce3          	bne	a4,a5,800003d6 <consoleintr+0xea>
    80000402:	b71d                	j	80000328 <consoleintr+0x3c>
    if(cons.e != cons.w){
    80000404:	00011717          	auipc	a4,0x11
    80000408:	9bc70713          	addi	a4,a4,-1604 # 80010dc0 <cons>
    8000040c:	0a072783          	lw	a5,160(a4)
    80000410:	09c72703          	lw	a4,156(a4)
    80000414:	f0f70ae3          	beq	a4,a5,80000328 <consoleintr+0x3c>
      cons.e--;
    80000418:	37fd                	addiw	a5,a5,-1
    8000041a:	00011717          	auipc	a4,0x11
    8000041e:	a4f72323          	sw	a5,-1466(a4) # 80010e60 <cons+0xa0>
      consputc(BACKSPACE);
    80000422:	10000513          	li	a0,256
    80000426:	00000097          	auipc	ra,0x0
    8000042a:	e84080e7          	jalr	-380(ra) # 800002aa <consputc>
    8000042e:	bded                	j	80000328 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000430:	ee048ce3          	beqz	s1,80000328 <consoleintr+0x3c>
    80000434:	bf21                	j	8000034c <consoleintr+0x60>
      consputc(c);
    80000436:	4529                	li	a0,10
    80000438:	00000097          	auipc	ra,0x0
    8000043c:	e72080e7          	jalr	-398(ra) # 800002aa <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000440:	00011797          	auipc	a5,0x11
    80000444:	98078793          	addi	a5,a5,-1664 # 80010dc0 <cons>
    80000448:	0a07a703          	lw	a4,160(a5)
    8000044c:	0017069b          	addiw	a3,a4,1
    80000450:	0006861b          	sext.w	a2,a3
    80000454:	0ad7a023          	sw	a3,160(a5)
    80000458:	07f77713          	andi	a4,a4,127
    8000045c:	97ba                	add	a5,a5,a4
    8000045e:	4729                	li	a4,10
    80000460:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000464:	00011797          	auipc	a5,0x11
    80000468:	9ec7ac23          	sw	a2,-1544(a5) # 80010e5c <cons+0x9c>
        wakeup(&cons.r);
    8000046c:	00011517          	auipc	a0,0x11
    80000470:	9ec50513          	addi	a0,a0,-1556 # 80010e58 <cons+0x98>
    80000474:	00002097          	auipc	ra,0x2
    80000478:	d5e080e7          	jalr	-674(ra) # 800021d2 <wakeup>
    8000047c:	b575                	j	80000328 <consoleintr+0x3c>

000000008000047e <consoleinit>:

void
consoleinit(void)
{
    8000047e:	1141                	addi	sp,sp,-16
    80000480:	e406                	sd	ra,8(sp)
    80000482:	e022                	sd	s0,0(sp)
    80000484:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000486:	00008597          	auipc	a1,0x8
    8000048a:	bea58593          	addi	a1,a1,-1046 # 80008070 <etext+0x70>
    8000048e:	00011517          	auipc	a0,0x11
    80000492:	93250513          	addi	a0,a0,-1742 # 80010dc0 <cons>
    80000496:	00000097          	auipc	ra,0x0
    8000049a:	6ec080e7          	jalr	1772(ra) # 80000b82 <initlock>

  uartinit();
    8000049e:	00000097          	auipc	ra,0x0
    800004a2:	330080e7          	jalr	816(ra) # 800007ce <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800004a6:	00021797          	auipc	a5,0x21
    800004aa:	cb278793          	addi	a5,a5,-846 # 80021158 <devsw>
    800004ae:	00000717          	auipc	a4,0x0
    800004b2:	cde70713          	addi	a4,a4,-802 # 8000018c <consoleread>
    800004b6:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004b8:	00000717          	auipc	a4,0x0
    800004bc:	c7270713          	addi	a4,a4,-910 # 8000012a <consolewrite>
    800004c0:	ef98                	sd	a4,24(a5)
}
    800004c2:	60a2                	ld	ra,8(sp)
    800004c4:	6402                	ld	s0,0(sp)
    800004c6:	0141                	addi	sp,sp,16
    800004c8:	8082                	ret

00000000800004ca <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004ca:	7179                	addi	sp,sp,-48
    800004cc:	f406                	sd	ra,40(sp)
    800004ce:	f022                	sd	s0,32(sp)
    800004d0:	ec26                	sd	s1,24(sp)
    800004d2:	e84a                	sd	s2,16(sp)
    800004d4:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004d6:	c219                	beqz	a2,800004dc <printint+0x12>
    800004d8:	08054663          	bltz	a0,80000564 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004dc:	2501                	sext.w	a0,a0
    800004de:	4881                	li	a7,0
    800004e0:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004e4:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004e6:	2581                	sext.w	a1,a1
    800004e8:	00008617          	auipc	a2,0x8
    800004ec:	bb860613          	addi	a2,a2,-1096 # 800080a0 <digits>
    800004f0:	883a                	mv	a6,a4
    800004f2:	2705                	addiw	a4,a4,1
    800004f4:	02b577bb          	remuw	a5,a0,a1
    800004f8:	1782                	slli	a5,a5,0x20
    800004fa:	9381                	srli	a5,a5,0x20
    800004fc:	97b2                	add	a5,a5,a2
    800004fe:	0007c783          	lbu	a5,0(a5)
    80000502:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    80000506:	0005079b          	sext.w	a5,a0
    8000050a:	02b5553b          	divuw	a0,a0,a1
    8000050e:	0685                	addi	a3,a3,1
    80000510:	feb7f0e3          	bgeu	a5,a1,800004f0 <printint+0x26>

  if(sign)
    80000514:	00088b63          	beqz	a7,8000052a <printint+0x60>
    buf[i++] = '-';
    80000518:	fe040793          	addi	a5,s0,-32
    8000051c:	973e                	add	a4,a4,a5
    8000051e:	02d00793          	li	a5,45
    80000522:	fef70823          	sb	a5,-16(a4)
    80000526:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    8000052a:	02e05763          	blez	a4,80000558 <printint+0x8e>
    8000052e:	fd040793          	addi	a5,s0,-48
    80000532:	00e784b3          	add	s1,a5,a4
    80000536:	fff78913          	addi	s2,a5,-1
    8000053a:	993a                	add	s2,s2,a4
    8000053c:	377d                	addiw	a4,a4,-1
    8000053e:	1702                	slli	a4,a4,0x20
    80000540:	9301                	srli	a4,a4,0x20
    80000542:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000546:	fff4c503          	lbu	a0,-1(s1)
    8000054a:	00000097          	auipc	ra,0x0
    8000054e:	d60080e7          	jalr	-672(ra) # 800002aa <consputc>
  while(--i >= 0)
    80000552:	14fd                	addi	s1,s1,-1
    80000554:	ff2499e3          	bne	s1,s2,80000546 <printint+0x7c>
}
    80000558:	70a2                	ld	ra,40(sp)
    8000055a:	7402                	ld	s0,32(sp)
    8000055c:	64e2                	ld	s1,24(sp)
    8000055e:	6942                	ld	s2,16(sp)
    80000560:	6145                	addi	sp,sp,48
    80000562:	8082                	ret
    x = -xx;
    80000564:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000568:	4885                	li	a7,1
    x = -xx;
    8000056a:	bf9d                	j	800004e0 <printint+0x16>

000000008000056c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000056c:	1101                	addi	sp,sp,-32
    8000056e:	ec06                	sd	ra,24(sp)
    80000570:	e822                	sd	s0,16(sp)
    80000572:	e426                	sd	s1,8(sp)
    80000574:	1000                	addi	s0,sp,32
    80000576:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000578:	00011797          	auipc	a5,0x11
    8000057c:	9007a423          	sw	zero,-1784(a5) # 80010e80 <pr+0x18>
  printf("panic: ");
    80000580:	00008517          	auipc	a0,0x8
    80000584:	af850513          	addi	a0,a0,-1288 # 80008078 <etext+0x78>
    80000588:	00000097          	auipc	ra,0x0
    8000058c:	02e080e7          	jalr	46(ra) # 800005b6 <printf>
  printf(s);
    80000590:	8526                	mv	a0,s1
    80000592:	00000097          	auipc	ra,0x0
    80000596:	024080e7          	jalr	36(ra) # 800005b6 <printf>
  printf("\n");
    8000059a:	00008517          	auipc	a0,0x8
    8000059e:	ace50513          	addi	a0,a0,-1330 # 80008068 <etext+0x68>
    800005a2:	00000097          	auipc	ra,0x0
    800005a6:	014080e7          	jalr	20(ra) # 800005b6 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800005aa:	4785                	li	a5,1
    800005ac:	00008717          	auipc	a4,0x8
    800005b0:	68f72a23          	sw	a5,1684(a4) # 80008c40 <panicked>
  for(;;)
    800005b4:	a001                	j	800005b4 <panic+0x48>

00000000800005b6 <printf>:
{
    800005b6:	7131                	addi	sp,sp,-192
    800005b8:	fc86                	sd	ra,120(sp)
    800005ba:	f8a2                	sd	s0,112(sp)
    800005bc:	f4a6                	sd	s1,104(sp)
    800005be:	f0ca                	sd	s2,96(sp)
    800005c0:	ecce                	sd	s3,88(sp)
    800005c2:	e8d2                	sd	s4,80(sp)
    800005c4:	e4d6                	sd	s5,72(sp)
    800005c6:	e0da                	sd	s6,64(sp)
    800005c8:	fc5e                	sd	s7,56(sp)
    800005ca:	f862                	sd	s8,48(sp)
    800005cc:	f466                	sd	s9,40(sp)
    800005ce:	f06a                	sd	s10,32(sp)
    800005d0:	ec6e                	sd	s11,24(sp)
    800005d2:	0100                	addi	s0,sp,128
    800005d4:	8a2a                	mv	s4,a0
    800005d6:	e40c                	sd	a1,8(s0)
    800005d8:	e810                	sd	a2,16(s0)
    800005da:	ec14                	sd	a3,24(s0)
    800005dc:	f018                	sd	a4,32(s0)
    800005de:	f41c                	sd	a5,40(s0)
    800005e0:	03043823          	sd	a6,48(s0)
    800005e4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005e8:	00011d97          	auipc	s11,0x11
    800005ec:	898dad83          	lw	s11,-1896(s11) # 80010e80 <pr+0x18>
  if(locking)
    800005f0:	020d9b63          	bnez	s11,80000626 <printf+0x70>
  if (fmt == 0)
    800005f4:	040a0263          	beqz	s4,80000638 <printf+0x82>
  va_start(ap, fmt);
    800005f8:	00840793          	addi	a5,s0,8
    800005fc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000600:	000a4503          	lbu	a0,0(s4)
    80000604:	16050263          	beqz	a0,80000768 <printf+0x1b2>
    80000608:	4481                	li	s1,0
    if(c != '%'){
    8000060a:	02500a93          	li	s5,37
    switch(c){
    8000060e:	07000b13          	li	s6,112
  consputc('x');
    80000612:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000614:	00008b97          	auipc	s7,0x8
    80000618:	a8cb8b93          	addi	s7,s7,-1396 # 800080a0 <digits>
    switch(c){
    8000061c:	07300c93          	li	s9,115
    80000620:	06400c13          	li	s8,100
    80000624:	a82d                	j	8000065e <printf+0xa8>
    acquire(&pr.lock);
    80000626:	00011517          	auipc	a0,0x11
    8000062a:	84250513          	addi	a0,a0,-1982 # 80010e68 <pr>
    8000062e:	00000097          	auipc	ra,0x0
    80000632:	5e4080e7          	jalr	1508(ra) # 80000c12 <acquire>
    80000636:	bf7d                	j	800005f4 <printf+0x3e>
    panic("null fmt");
    80000638:	00008517          	auipc	a0,0x8
    8000063c:	a5050513          	addi	a0,a0,-1456 # 80008088 <etext+0x88>
    80000640:	00000097          	auipc	ra,0x0
    80000644:	f2c080e7          	jalr	-212(ra) # 8000056c <panic>
      consputc(c);
    80000648:	00000097          	auipc	ra,0x0
    8000064c:	c62080e7          	jalr	-926(ra) # 800002aa <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000650:	2485                	addiw	s1,s1,1
    80000652:	009a07b3          	add	a5,s4,s1
    80000656:	0007c503          	lbu	a0,0(a5)
    8000065a:	10050763          	beqz	a0,80000768 <printf+0x1b2>
    if(c != '%'){
    8000065e:	ff5515e3          	bne	a0,s5,80000648 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000662:	2485                	addiw	s1,s1,1
    80000664:	009a07b3          	add	a5,s4,s1
    80000668:	0007c783          	lbu	a5,0(a5)
    8000066c:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000670:	cfe5                	beqz	a5,80000768 <printf+0x1b2>
    switch(c){
    80000672:	05678a63          	beq	a5,s6,800006c6 <printf+0x110>
    80000676:	02fb7663          	bgeu	s6,a5,800006a2 <printf+0xec>
    8000067a:	09978963          	beq	a5,s9,8000070c <printf+0x156>
    8000067e:	07800713          	li	a4,120
    80000682:	0ce79863          	bne	a5,a4,80000752 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000686:	f8843783          	ld	a5,-120(s0)
    8000068a:	00878713          	addi	a4,a5,8
    8000068e:	f8e43423          	sd	a4,-120(s0)
    80000692:	4605                	li	a2,1
    80000694:	85ea                	mv	a1,s10
    80000696:	4388                	lw	a0,0(a5)
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	e32080e7          	jalr	-462(ra) # 800004ca <printint>
      break;
    800006a0:	bf45                	j	80000650 <printf+0x9a>
    switch(c){
    800006a2:	0b578263          	beq	a5,s5,80000746 <printf+0x190>
    800006a6:	0b879663          	bne	a5,s8,80000752 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    800006aa:	f8843783          	ld	a5,-120(s0)
    800006ae:	00878713          	addi	a4,a5,8
    800006b2:	f8e43423          	sd	a4,-120(s0)
    800006b6:	4605                	li	a2,1
    800006b8:	45a9                	li	a1,10
    800006ba:	4388                	lw	a0,0(a5)
    800006bc:	00000097          	auipc	ra,0x0
    800006c0:	e0e080e7          	jalr	-498(ra) # 800004ca <printint>
      break;
    800006c4:	b771                	j	80000650 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006c6:	f8843783          	ld	a5,-120(s0)
    800006ca:	00878713          	addi	a4,a5,8
    800006ce:	f8e43423          	sd	a4,-120(s0)
    800006d2:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006d6:	03000513          	li	a0,48
    800006da:	00000097          	auipc	ra,0x0
    800006de:	bd0080e7          	jalr	-1072(ra) # 800002aa <consputc>
  consputc('x');
    800006e2:	07800513          	li	a0,120
    800006e6:	00000097          	auipc	ra,0x0
    800006ea:	bc4080e7          	jalr	-1084(ra) # 800002aa <consputc>
    800006ee:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f0:	03c9d793          	srli	a5,s3,0x3c
    800006f4:	97de                	add	a5,a5,s7
    800006f6:	0007c503          	lbu	a0,0(a5)
    800006fa:	00000097          	auipc	ra,0x0
    800006fe:	bb0080e7          	jalr	-1104(ra) # 800002aa <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0992                	slli	s3,s3,0x4
    80000704:	397d                	addiw	s2,s2,-1
    80000706:	fe0915e3          	bnez	s2,800006f0 <printf+0x13a>
    8000070a:	b799                	j	80000650 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    8000070c:	f8843783          	ld	a5,-120(s0)
    80000710:	00878713          	addi	a4,a5,8
    80000714:	f8e43423          	sd	a4,-120(s0)
    80000718:	0007b903          	ld	s2,0(a5)
    8000071c:	00090e63          	beqz	s2,80000738 <printf+0x182>
      for(; *s; s++)
    80000720:	00094503          	lbu	a0,0(s2)
    80000724:	d515                	beqz	a0,80000650 <printf+0x9a>
        consputc(*s);
    80000726:	00000097          	auipc	ra,0x0
    8000072a:	b84080e7          	jalr	-1148(ra) # 800002aa <consputc>
      for(; *s; s++)
    8000072e:	0905                	addi	s2,s2,1
    80000730:	00094503          	lbu	a0,0(s2)
    80000734:	f96d                	bnez	a0,80000726 <printf+0x170>
    80000736:	bf29                	j	80000650 <printf+0x9a>
        s = "(null)";
    80000738:	00008917          	auipc	s2,0x8
    8000073c:	94890913          	addi	s2,s2,-1720 # 80008080 <etext+0x80>
      for(; *s; s++)
    80000740:	02800513          	li	a0,40
    80000744:	b7cd                	j	80000726 <printf+0x170>
      consputc('%');
    80000746:	8556                	mv	a0,s5
    80000748:	00000097          	auipc	ra,0x0
    8000074c:	b62080e7          	jalr	-1182(ra) # 800002aa <consputc>
      break;
    80000750:	b701                	j	80000650 <printf+0x9a>
      consputc('%');
    80000752:	8556                	mv	a0,s5
    80000754:	00000097          	auipc	ra,0x0
    80000758:	b56080e7          	jalr	-1194(ra) # 800002aa <consputc>
      consputc(c);
    8000075c:	854a                	mv	a0,s2
    8000075e:	00000097          	auipc	ra,0x0
    80000762:	b4c080e7          	jalr	-1204(ra) # 800002aa <consputc>
      break;
    80000766:	b5ed                	j	80000650 <printf+0x9a>
  if(locking)
    80000768:	020d9163          	bnez	s11,8000078a <printf+0x1d4>
}
    8000076c:	70e6                	ld	ra,120(sp)
    8000076e:	7446                	ld	s0,112(sp)
    80000770:	74a6                	ld	s1,104(sp)
    80000772:	7906                	ld	s2,96(sp)
    80000774:	69e6                	ld	s3,88(sp)
    80000776:	6a46                	ld	s4,80(sp)
    80000778:	6aa6                	ld	s5,72(sp)
    8000077a:	6b06                	ld	s6,64(sp)
    8000077c:	7be2                	ld	s7,56(sp)
    8000077e:	7c42                	ld	s8,48(sp)
    80000780:	7ca2                	ld	s9,40(sp)
    80000782:	7d02                	ld	s10,32(sp)
    80000784:	6de2                	ld	s11,24(sp)
    80000786:	6129                	addi	sp,sp,192
    80000788:	8082                	ret
    release(&pr.lock);
    8000078a:	00010517          	auipc	a0,0x10
    8000078e:	6de50513          	addi	a0,a0,1758 # 80010e68 <pr>
    80000792:	00000097          	auipc	ra,0x0
    80000796:	534080e7          	jalr	1332(ra) # 80000cc6 <release>
}
    8000079a:	bfc9                	j	8000076c <printf+0x1b6>

000000008000079c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000079c:	1101                	addi	sp,sp,-32
    8000079e:	ec06                	sd	ra,24(sp)
    800007a0:	e822                	sd	s0,16(sp)
    800007a2:	e426                	sd	s1,8(sp)
    800007a4:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007a6:	00010497          	auipc	s1,0x10
    800007aa:	6c248493          	addi	s1,s1,1730 # 80010e68 <pr>
    800007ae:	00008597          	auipc	a1,0x8
    800007b2:	8ea58593          	addi	a1,a1,-1814 # 80008098 <etext+0x98>
    800007b6:	8526                	mv	a0,s1
    800007b8:	00000097          	auipc	ra,0x0
    800007bc:	3ca080e7          	jalr	970(ra) # 80000b82 <initlock>
  pr.locking = 1;
    800007c0:	4785                	li	a5,1
    800007c2:	cc9c                	sw	a5,24(s1)
}
    800007c4:	60e2                	ld	ra,24(sp)
    800007c6:	6442                	ld	s0,16(sp)
    800007c8:	64a2                	ld	s1,8(sp)
    800007ca:	6105                	addi	sp,sp,32
    800007cc:	8082                	ret

00000000800007ce <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007ce:	1141                	addi	sp,sp,-16
    800007d0:	e406                	sd	ra,8(sp)
    800007d2:	e022                	sd	s0,0(sp)
    800007d4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007d6:	100007b7          	lui	a5,0x10000
    800007da:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007de:	f8000713          	li	a4,-128
    800007e2:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007e6:	470d                	li	a4,3
    800007e8:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ec:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007f0:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007f4:	469d                	li	a3,7
    800007f6:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007fa:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007fe:	00008597          	auipc	a1,0x8
    80000802:	8ba58593          	addi	a1,a1,-1862 # 800080b8 <digits+0x18>
    80000806:	00010517          	auipc	a0,0x10
    8000080a:	68250513          	addi	a0,a0,1666 # 80010e88 <uart_tx_lock>
    8000080e:	00000097          	auipc	ra,0x0
    80000812:	374080e7          	jalr	884(ra) # 80000b82 <initlock>
}
    80000816:	60a2                	ld	ra,8(sp)
    80000818:	6402                	ld	s0,0(sp)
    8000081a:	0141                	addi	sp,sp,16
    8000081c:	8082                	ret

000000008000081e <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000081e:	1101                	addi	sp,sp,-32
    80000820:	ec06                	sd	ra,24(sp)
    80000822:	e822                	sd	s0,16(sp)
    80000824:	e426                	sd	s1,8(sp)
    80000826:	1000                	addi	s0,sp,32
    80000828:	84aa                	mv	s1,a0
  push_off();
    8000082a:	00000097          	auipc	ra,0x0
    8000082e:	39c080e7          	jalr	924(ra) # 80000bc6 <push_off>

  if(panicked){
    80000832:	00008797          	auipc	a5,0x8
    80000836:	40e7a783          	lw	a5,1038(a5) # 80008c40 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000083a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000083e:	c391                	beqz	a5,80000842 <uartputc_sync+0x24>
    for(;;)
    80000840:	a001                	j	80000840 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000842:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000846:	0ff7f793          	andi	a5,a5,255
    8000084a:	0207f793          	andi	a5,a5,32
    8000084e:	dbf5                	beqz	a5,80000842 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000850:	0ff4f793          	andi	a5,s1,255
    80000854:	10000737          	lui	a4,0x10000
    80000858:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    8000085c:	00000097          	auipc	ra,0x0
    80000860:	40a080e7          	jalr	1034(ra) # 80000c66 <pop_off>
}
    80000864:	60e2                	ld	ra,24(sp)
    80000866:	6442                	ld	s0,16(sp)
    80000868:	64a2                	ld	s1,8(sp)
    8000086a:	6105                	addi	sp,sp,32
    8000086c:	8082                	ret

000000008000086e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008717          	auipc	a4,0x8
    80000872:	3da73703          	ld	a4,986(a4) # 80008c48 <uart_tx_r>
    80000876:	00008797          	auipc	a5,0x8
    8000087a:	3da7b783          	ld	a5,986(a5) # 80008c50 <uart_tx_w>
    8000087e:	06e78c63          	beq	a5,a4,800008f6 <uartstart+0x88>
{
    80000882:	7139                	addi	sp,sp,-64
    80000884:	fc06                	sd	ra,56(sp)
    80000886:	f822                	sd	s0,48(sp)
    80000888:	f426                	sd	s1,40(sp)
    8000088a:	f04a                	sd	s2,32(sp)
    8000088c:	ec4e                	sd	s3,24(sp)
    8000088e:	e852                	sd	s4,16(sp)
    80000890:	e456                	sd	s5,8(sp)
    80000892:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000894:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000898:	00010a17          	auipc	s4,0x10
    8000089c:	5f0a0a13          	addi	s4,s4,1520 # 80010e88 <uart_tx_lock>
    uart_tx_r += 1;
    800008a0:	00008497          	auipc	s1,0x8
    800008a4:	3a848493          	addi	s1,s1,936 # 80008c48 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    800008a8:	00008997          	auipc	s3,0x8
    800008ac:	3a898993          	addi	s3,s3,936 # 80008c50 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008b0:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    800008b4:	0ff7f793          	andi	a5,a5,255
    800008b8:	0207f793          	andi	a5,a5,32
    800008bc:	c785                	beqz	a5,800008e4 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008be:	01f77793          	andi	a5,a4,31
    800008c2:	97d2                	add	a5,a5,s4
    800008c4:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    800008c8:	0705                	addi	a4,a4,1
    800008ca:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008cc:	8526                	mv	a0,s1
    800008ce:	00002097          	auipc	ra,0x2
    800008d2:	904080e7          	jalr	-1788(ra) # 800021d2 <wakeup>
    
    WriteReg(THR, c);
    800008d6:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008da:	6098                	ld	a4,0(s1)
    800008dc:	0009b783          	ld	a5,0(s3)
    800008e0:	fce798e3          	bne	a5,a4,800008b0 <uartstart+0x42>
  }
}
    800008e4:	70e2                	ld	ra,56(sp)
    800008e6:	7442                	ld	s0,48(sp)
    800008e8:	74a2                	ld	s1,40(sp)
    800008ea:	7902                	ld	s2,32(sp)
    800008ec:	69e2                	ld	s3,24(sp)
    800008ee:	6a42                	ld	s4,16(sp)
    800008f0:	6aa2                	ld	s5,8(sp)
    800008f2:	6121                	addi	sp,sp,64
    800008f4:	8082                	ret
    800008f6:	8082                	ret

00000000800008f8 <uartputc>:
{
    800008f8:	7179                	addi	sp,sp,-48
    800008fa:	f406                	sd	ra,40(sp)
    800008fc:	f022                	sd	s0,32(sp)
    800008fe:	ec26                	sd	s1,24(sp)
    80000900:	e84a                	sd	s2,16(sp)
    80000902:	e44e                	sd	s3,8(sp)
    80000904:	e052                	sd	s4,0(sp)
    80000906:	1800                	addi	s0,sp,48
    80000908:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    8000090a:	00010517          	auipc	a0,0x10
    8000090e:	57e50513          	addi	a0,a0,1406 # 80010e88 <uart_tx_lock>
    80000912:	00000097          	auipc	ra,0x0
    80000916:	300080e7          	jalr	768(ra) # 80000c12 <acquire>
  if(panicked){
    8000091a:	00008797          	auipc	a5,0x8
    8000091e:	3267a783          	lw	a5,806(a5) # 80008c40 <panicked>
    80000922:	e7c9                	bnez	a5,800009ac <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00008797          	auipc	a5,0x8
    80000928:	32c7b783          	ld	a5,812(a5) # 80008c50 <uart_tx_w>
    8000092c:	00008717          	auipc	a4,0x8
    80000930:	31c73703          	ld	a4,796(a4) # 80008c48 <uart_tx_r>
    80000934:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000938:	00010a17          	auipc	s4,0x10
    8000093c:	550a0a13          	addi	s4,s4,1360 # 80010e88 <uart_tx_lock>
    80000940:	00008497          	auipc	s1,0x8
    80000944:	30848493          	addi	s1,s1,776 # 80008c48 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000948:	00008917          	auipc	s2,0x8
    8000094c:	30890913          	addi	s2,s2,776 # 80008c50 <uart_tx_w>
    80000950:	00f71f63          	bne	a4,a5,8000096e <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000954:	85d2                	mv	a1,s4
    80000956:	8526                	mv	a0,s1
    80000958:	00002097          	auipc	ra,0x2
    8000095c:	80c080e7          	jalr	-2036(ra) # 80002164 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000960:	00093783          	ld	a5,0(s2)
    80000964:	6098                	ld	a4,0(s1)
    80000966:	02070713          	addi	a4,a4,32
    8000096a:	fef705e3          	beq	a4,a5,80000954 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000096e:	00010497          	auipc	s1,0x10
    80000972:	51a48493          	addi	s1,s1,1306 # 80010e88 <uart_tx_lock>
    80000976:	01f7f713          	andi	a4,a5,31
    8000097a:	9726                	add	a4,a4,s1
    8000097c:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80000980:	0785                	addi	a5,a5,1
    80000982:	00008717          	auipc	a4,0x8
    80000986:	2cf73723          	sd	a5,718(a4) # 80008c50 <uart_tx_w>
  uartstart();
    8000098a:	00000097          	auipc	ra,0x0
    8000098e:	ee4080e7          	jalr	-284(ra) # 8000086e <uartstart>
  release(&uart_tx_lock);
    80000992:	8526                	mv	a0,s1
    80000994:	00000097          	auipc	ra,0x0
    80000998:	332080e7          	jalr	818(ra) # 80000cc6 <release>
}
    8000099c:	70a2                	ld	ra,40(sp)
    8000099e:	7402                	ld	s0,32(sp)
    800009a0:	64e2                	ld	s1,24(sp)
    800009a2:	6942                	ld	s2,16(sp)
    800009a4:	69a2                	ld	s3,8(sp)
    800009a6:	6a02                	ld	s4,0(sp)
    800009a8:	6145                	addi	sp,sp,48
    800009aa:	8082                	ret
    for(;;)
    800009ac:	a001                	j	800009ac <uartputc+0xb4>

00000000800009ae <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009ae:	1141                	addi	sp,sp,-16
    800009b0:	e422                	sd	s0,8(sp)
    800009b2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009b4:	100007b7          	lui	a5,0x10000
    800009b8:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009bc:	8b85                	andi	a5,a5,1
    800009be:	cb91                	beqz	a5,800009d2 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009c0:	100007b7          	lui	a5,0x10000
    800009c4:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009c8:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009cc:	6422                	ld	s0,8(sp)
    800009ce:	0141                	addi	sp,sp,16
    800009d0:	8082                	ret
    return -1;
    800009d2:	557d                	li	a0,-1
    800009d4:	bfe5                	j	800009cc <uartgetc+0x1e>

00000000800009d6 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009d6:	1101                	addi	sp,sp,-32
    800009d8:	ec06                	sd	ra,24(sp)
    800009da:	e822                	sd	s0,16(sp)
    800009dc:	e426                	sd	s1,8(sp)
    800009de:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009e0:	54fd                	li	s1,-1
    int c = uartgetc();
    800009e2:	00000097          	auipc	ra,0x0
    800009e6:	fcc080e7          	jalr	-52(ra) # 800009ae <uartgetc>
    if(c == -1)
    800009ea:	00950763          	beq	a0,s1,800009f8 <uartintr+0x22>
      break;
    consoleintr(c);
    800009ee:	00000097          	auipc	ra,0x0
    800009f2:	8fe080e7          	jalr	-1794(ra) # 800002ec <consoleintr>
  while(1){
    800009f6:	b7f5                	j	800009e2 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009f8:	00010497          	auipc	s1,0x10
    800009fc:	49048493          	addi	s1,s1,1168 # 80010e88 <uart_tx_lock>
    80000a00:	8526                	mv	a0,s1
    80000a02:	00000097          	auipc	ra,0x0
    80000a06:	210080e7          	jalr	528(ra) # 80000c12 <acquire>
  uartstart();
    80000a0a:	00000097          	auipc	ra,0x0
    80000a0e:	e64080e7          	jalr	-412(ra) # 8000086e <uartstart>
  release(&uart_tx_lock);
    80000a12:	8526                	mv	a0,s1
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	2b2080e7          	jalr	690(ra) # 80000cc6 <release>
}
    80000a1c:	60e2                	ld	ra,24(sp)
    80000a1e:	6442                	ld	s0,16(sp)
    80000a20:	64a2                	ld	s1,8(sp)
    80000a22:	6105                	addi	sp,sp,32
    80000a24:	8082                	ret

0000000080000a26 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a26:	1101                	addi	sp,sp,-32
    80000a28:	ec06                	sd	ra,24(sp)
    80000a2a:	e822                	sd	s0,16(sp)
    80000a2c:	e426                	sd	s1,8(sp)
    80000a2e:	e04a                	sd	s2,0(sp)
    80000a30:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a32:	03451793          	slli	a5,a0,0x34
    80000a36:	ebb9                	bnez	a5,80000a8c <kfree+0x66>
    80000a38:	84aa                	mv	s1,a0
    80000a3a:	00022797          	auipc	a5,0x22
    80000a3e:	8b678793          	addi	a5,a5,-1866 # 800222f0 <end>
    80000a42:	04f56563          	bltu	a0,a5,80000a8c <kfree+0x66>
    80000a46:	47c5                	li	a5,17
    80000a48:	07ee                	slli	a5,a5,0x1b
    80000a4a:	04f57163          	bgeu	a0,a5,80000a8c <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a4e:	6605                	lui	a2,0x1
    80000a50:	4585                	li	a1,1
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	2bc080e7          	jalr	700(ra) # 80000d0e <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a5a:	00010917          	auipc	s2,0x10
    80000a5e:	46690913          	addi	s2,s2,1126 # 80010ec0 <kmem>
    80000a62:	854a                	mv	a0,s2
    80000a64:	00000097          	auipc	ra,0x0
    80000a68:	1ae080e7          	jalr	430(ra) # 80000c12 <acquire>
  r->next = kmem.freelist;
    80000a6c:	01893783          	ld	a5,24(s2)
    80000a70:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a72:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a76:	854a                	mv	a0,s2
    80000a78:	00000097          	auipc	ra,0x0
    80000a7c:	24e080e7          	jalr	590(ra) # 80000cc6 <release>
}
    80000a80:	60e2                	ld	ra,24(sp)
    80000a82:	6442                	ld	s0,16(sp)
    80000a84:	64a2                	ld	s1,8(sp)
    80000a86:	6902                	ld	s2,0(sp)
    80000a88:	6105                	addi	sp,sp,32
    80000a8a:	8082                	ret
    panic("kfree");
    80000a8c:	00007517          	auipc	a0,0x7
    80000a90:	63450513          	addi	a0,a0,1588 # 800080c0 <digits+0x20>
    80000a94:	00000097          	auipc	ra,0x0
    80000a98:	ad8080e7          	jalr	-1320(ra) # 8000056c <panic>

0000000080000a9c <freerange>:
{
    80000a9c:	7179                	addi	sp,sp,-48
    80000a9e:	f406                	sd	ra,40(sp)
    80000aa0:	f022                	sd	s0,32(sp)
    80000aa2:	ec26                	sd	s1,24(sp)
    80000aa4:	e84a                	sd	s2,16(sp)
    80000aa6:	e44e                	sd	s3,8(sp)
    80000aa8:	e052                	sd	s4,0(sp)
    80000aaa:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000aac:	6785                	lui	a5,0x1
    80000aae:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000ab2:	94aa                	add	s1,s1,a0
    80000ab4:	757d                	lui	a0,0xfffff
    80000ab6:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab8:	94be                	add	s1,s1,a5
    80000aba:	0095ee63          	bltu	a1,s1,80000ad6 <freerange+0x3a>
    80000abe:	892e                	mv	s2,a1
    kfree(p);
    80000ac0:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac2:	6985                	lui	s3,0x1
    kfree(p);
    80000ac4:	01448533          	add	a0,s1,s4
    80000ac8:	00000097          	auipc	ra,0x0
    80000acc:	f5e080e7          	jalr	-162(ra) # 80000a26 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad0:	94ce                	add	s1,s1,s3
    80000ad2:	fe9979e3          	bgeu	s2,s1,80000ac4 <freerange+0x28>
}
    80000ad6:	70a2                	ld	ra,40(sp)
    80000ad8:	7402                	ld	s0,32(sp)
    80000ada:	64e2                	ld	s1,24(sp)
    80000adc:	6942                	ld	s2,16(sp)
    80000ade:	69a2                	ld	s3,8(sp)
    80000ae0:	6a02                	ld	s4,0(sp)
    80000ae2:	6145                	addi	sp,sp,48
    80000ae4:	8082                	ret

0000000080000ae6 <kinit>:
{
    80000ae6:	1141                	addi	sp,sp,-16
    80000ae8:	e406                	sd	ra,8(sp)
    80000aea:	e022                	sd	s0,0(sp)
    80000aec:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aee:	00007597          	auipc	a1,0x7
    80000af2:	5da58593          	addi	a1,a1,1498 # 800080c8 <digits+0x28>
    80000af6:	00010517          	auipc	a0,0x10
    80000afa:	3ca50513          	addi	a0,a0,970 # 80010ec0 <kmem>
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	084080e7          	jalr	132(ra) # 80000b82 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b06:	45c5                	li	a1,17
    80000b08:	05ee                	slli	a1,a1,0x1b
    80000b0a:	00021517          	auipc	a0,0x21
    80000b0e:	7e650513          	addi	a0,a0,2022 # 800222f0 <end>
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	f8a080e7          	jalr	-118(ra) # 80000a9c <freerange>
}
    80000b1a:	60a2                	ld	ra,8(sp)
    80000b1c:	6402                	ld	s0,0(sp)
    80000b1e:	0141                	addi	sp,sp,16
    80000b20:	8082                	ret

0000000080000b22 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b22:	1101                	addi	sp,sp,-32
    80000b24:	ec06                	sd	ra,24(sp)
    80000b26:	e822                	sd	s0,16(sp)
    80000b28:	e426                	sd	s1,8(sp)
    80000b2a:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2c:	00010497          	auipc	s1,0x10
    80000b30:	39448493          	addi	s1,s1,916 # 80010ec0 <kmem>
    80000b34:	8526                	mv	a0,s1
    80000b36:	00000097          	auipc	ra,0x0
    80000b3a:	0dc080e7          	jalr	220(ra) # 80000c12 <acquire>
  r = kmem.freelist;
    80000b3e:	6c84                	ld	s1,24(s1)
  if(r)
    80000b40:	c885                	beqz	s1,80000b70 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b42:	609c                	ld	a5,0(s1)
    80000b44:	00010517          	auipc	a0,0x10
    80000b48:	37c50513          	addi	a0,a0,892 # 80010ec0 <kmem>
    80000b4c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4e:	00000097          	auipc	ra,0x0
    80000b52:	178080e7          	jalr	376(ra) # 80000cc6 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b56:	6605                	lui	a2,0x1
    80000b58:	4595                	li	a1,5
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	00000097          	auipc	ra,0x0
    80000b60:	1b2080e7          	jalr	434(ra) # 80000d0e <memset>
  return (void*)r;
}
    80000b64:	8526                	mv	a0,s1
    80000b66:	60e2                	ld	ra,24(sp)
    80000b68:	6442                	ld	s0,16(sp)
    80000b6a:	64a2                	ld	s1,8(sp)
    80000b6c:	6105                	addi	sp,sp,32
    80000b6e:	8082                	ret
  release(&kmem.lock);
    80000b70:	00010517          	auipc	a0,0x10
    80000b74:	35050513          	addi	a0,a0,848 # 80010ec0 <kmem>
    80000b78:	00000097          	auipc	ra,0x0
    80000b7c:	14e080e7          	jalr	334(ra) # 80000cc6 <release>
  if(r)
    80000b80:	b7d5                	j	80000b64 <kalloc+0x42>

0000000080000b82 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b82:	1141                	addi	sp,sp,-16
    80000b84:	e422                	sd	s0,8(sp)
    80000b86:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b88:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b8a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b8e:	00053823          	sd	zero,16(a0)
}
    80000b92:	6422                	ld	s0,8(sp)
    80000b94:	0141                	addi	sp,sp,16
    80000b96:	8082                	ret

0000000080000b98 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b98:	411c                	lw	a5,0(a0)
    80000b9a:	e399                	bnez	a5,80000ba0 <holding+0x8>
    80000b9c:	4501                	li	a0,0
  return r;
}
    80000b9e:	8082                	ret
{
    80000ba0:	1101                	addi	sp,sp,-32
    80000ba2:	ec06                	sd	ra,24(sp)
    80000ba4:	e822                	sd	s0,16(sp)
    80000ba6:	e426                	sd	s1,8(sp)
    80000ba8:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000baa:	6904                	ld	s1,16(a0)
    80000bac:	00001097          	auipc	ra,0x1
    80000bb0:	e42080e7          	jalr	-446(ra) # 800019ee <mycpu>
    80000bb4:	40a48533          	sub	a0,s1,a0
    80000bb8:	00153513          	seqz	a0,a0
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret

0000000080000bc6 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bc6:	1101                	addi	sp,sp,-32
    80000bc8:	ec06                	sd	ra,24(sp)
    80000bca:	e822                	sd	s0,16(sp)
    80000bcc:	e426                	sd	s1,8(sp)
    80000bce:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bd0:	100024f3          	csrr	s1,sstatus
    80000bd4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bd8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bda:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bde:	00001097          	auipc	ra,0x1
    80000be2:	e10080e7          	jalr	-496(ra) # 800019ee <mycpu>
    80000be6:	5d3c                	lw	a5,120(a0)
    80000be8:	cf89                	beqz	a5,80000c02 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bea:	00001097          	auipc	ra,0x1
    80000bee:	e04080e7          	jalr	-508(ra) # 800019ee <mycpu>
    80000bf2:	5d3c                	lw	a5,120(a0)
    80000bf4:	2785                	addiw	a5,a5,1
    80000bf6:	dd3c                	sw	a5,120(a0)
}
    80000bf8:	60e2                	ld	ra,24(sp)
    80000bfa:	6442                	ld	s0,16(sp)
    80000bfc:	64a2                	ld	s1,8(sp)
    80000bfe:	6105                	addi	sp,sp,32
    80000c00:	8082                	ret
    mycpu()->intena = old;
    80000c02:	00001097          	auipc	ra,0x1
    80000c06:	dec080e7          	jalr	-532(ra) # 800019ee <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c0a:	8085                	srli	s1,s1,0x1
    80000c0c:	8885                	andi	s1,s1,1
    80000c0e:	dd64                	sw	s1,124(a0)
    80000c10:	bfe9                	j	80000bea <push_off+0x24>

0000000080000c12 <acquire>:
{
    80000c12:	1101                	addi	sp,sp,-32
    80000c14:	ec06                	sd	ra,24(sp)
    80000c16:	e822                	sd	s0,16(sp)
    80000c18:	e426                	sd	s1,8(sp)
    80000c1a:	1000                	addi	s0,sp,32
    80000c1c:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	fa8080e7          	jalr	-88(ra) # 80000bc6 <push_off>
  if(holding(lk))
    80000c26:	8526                	mv	a0,s1
    80000c28:	00000097          	auipc	ra,0x0
    80000c2c:	f70080e7          	jalr	-144(ra) # 80000b98 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c30:	4705                	li	a4,1
  if(holding(lk))
    80000c32:	e115                	bnez	a0,80000c56 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c34:	87ba                	mv	a5,a4
    80000c36:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c3a:	2781                	sext.w	a5,a5
    80000c3c:	ffe5                	bnez	a5,80000c34 <acquire+0x22>
  __sync_synchronize();
    80000c3e:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c42:	00001097          	auipc	ra,0x1
    80000c46:	dac080e7          	jalr	-596(ra) # 800019ee <mycpu>
    80000c4a:	e888                	sd	a0,16(s1)
}
    80000c4c:	60e2                	ld	ra,24(sp)
    80000c4e:	6442                	ld	s0,16(sp)
    80000c50:	64a2                	ld	s1,8(sp)
    80000c52:	6105                	addi	sp,sp,32
    80000c54:	8082                	ret
    panic("acquire");
    80000c56:	00007517          	auipc	a0,0x7
    80000c5a:	47a50513          	addi	a0,a0,1146 # 800080d0 <digits+0x30>
    80000c5e:	00000097          	auipc	ra,0x0
    80000c62:	90e080e7          	jalr	-1778(ra) # 8000056c <panic>

0000000080000c66 <pop_off>:

void
pop_off(void)
{
    80000c66:	1141                	addi	sp,sp,-16
    80000c68:	e406                	sd	ra,8(sp)
    80000c6a:	e022                	sd	s0,0(sp)
    80000c6c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c6e:	00001097          	auipc	ra,0x1
    80000c72:	d80080e7          	jalr	-640(ra) # 800019ee <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c76:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c7a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c7c:	e78d                	bnez	a5,80000ca6 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c7e:	5d3c                	lw	a5,120(a0)
    80000c80:	02f05b63          	blez	a5,80000cb6 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c84:	37fd                	addiw	a5,a5,-1
    80000c86:	0007871b          	sext.w	a4,a5
    80000c8a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c8c:	eb09                	bnez	a4,80000c9e <pop_off+0x38>
    80000c8e:	5d7c                	lw	a5,124(a0)
    80000c90:	c799                	beqz	a5,80000c9e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c92:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c96:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c9a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c9e:	60a2                	ld	ra,8(sp)
    80000ca0:	6402                	ld	s0,0(sp)
    80000ca2:	0141                	addi	sp,sp,16
    80000ca4:	8082                	ret
    panic("pop_off - interruptible");
    80000ca6:	00007517          	auipc	a0,0x7
    80000caa:	43250513          	addi	a0,a0,1074 # 800080d8 <digits+0x38>
    80000cae:	00000097          	auipc	ra,0x0
    80000cb2:	8be080e7          	jalr	-1858(ra) # 8000056c <panic>
    panic("pop_off");
    80000cb6:	00007517          	auipc	a0,0x7
    80000cba:	43a50513          	addi	a0,a0,1082 # 800080f0 <digits+0x50>
    80000cbe:	00000097          	auipc	ra,0x0
    80000cc2:	8ae080e7          	jalr	-1874(ra) # 8000056c <panic>

0000000080000cc6 <release>:
{
    80000cc6:	1101                	addi	sp,sp,-32
    80000cc8:	ec06                	sd	ra,24(sp)
    80000cca:	e822                	sd	s0,16(sp)
    80000ccc:	e426                	sd	s1,8(sp)
    80000cce:	1000                	addi	s0,sp,32
    80000cd0:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cd2:	00000097          	auipc	ra,0x0
    80000cd6:	ec6080e7          	jalr	-314(ra) # 80000b98 <holding>
    80000cda:	c115                	beqz	a0,80000cfe <release+0x38>
  lk->cpu = 0;
    80000cdc:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ce0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ce4:	0f50000f          	fence	iorw,ow
    80000ce8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cec:	00000097          	auipc	ra,0x0
    80000cf0:	f7a080e7          	jalr	-134(ra) # 80000c66 <pop_off>
}
    80000cf4:	60e2                	ld	ra,24(sp)
    80000cf6:	6442                	ld	s0,16(sp)
    80000cf8:	64a2                	ld	s1,8(sp)
    80000cfa:	6105                	addi	sp,sp,32
    80000cfc:	8082                	ret
    panic("release");
    80000cfe:	00007517          	auipc	a0,0x7
    80000d02:	3fa50513          	addi	a0,a0,1018 # 800080f8 <digits+0x58>
    80000d06:	00000097          	auipc	ra,0x0
    80000d0a:	866080e7          	jalr	-1946(ra) # 8000056c <panic>

0000000080000d0e <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d0e:	1141                	addi	sp,sp,-16
    80000d10:	e422                	sd	s0,8(sp)
    80000d12:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d14:	ce09                	beqz	a2,80000d2e <memset+0x20>
    80000d16:	87aa                	mv	a5,a0
    80000d18:	fff6071b          	addiw	a4,a2,-1
    80000d1c:	1702                	slli	a4,a4,0x20
    80000d1e:	9301                	srli	a4,a4,0x20
    80000d20:	0705                	addi	a4,a4,1
    80000d22:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000d24:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d28:	0785                	addi	a5,a5,1
    80000d2a:	fee79de3          	bne	a5,a4,80000d24 <memset+0x16>
  }
  return dst;
}
    80000d2e:	6422                	ld	s0,8(sp)
    80000d30:	0141                	addi	sp,sp,16
    80000d32:	8082                	ret

0000000080000d34 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d34:	1141                	addi	sp,sp,-16
    80000d36:	e422                	sd	s0,8(sp)
    80000d38:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d3a:	ca05                	beqz	a2,80000d6a <memcmp+0x36>
    80000d3c:	fff6069b          	addiw	a3,a2,-1
    80000d40:	1682                	slli	a3,a3,0x20
    80000d42:	9281                	srli	a3,a3,0x20
    80000d44:	0685                	addi	a3,a3,1
    80000d46:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d48:	00054783          	lbu	a5,0(a0)
    80000d4c:	0005c703          	lbu	a4,0(a1)
    80000d50:	00e79863          	bne	a5,a4,80000d60 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d54:	0505                	addi	a0,a0,1
    80000d56:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d58:	fed518e3          	bne	a0,a3,80000d48 <memcmp+0x14>
  }

  return 0;
    80000d5c:	4501                	li	a0,0
    80000d5e:	a019                	j	80000d64 <memcmp+0x30>
      return *s1 - *s2;
    80000d60:	40e7853b          	subw	a0,a5,a4
}
    80000d64:	6422                	ld	s0,8(sp)
    80000d66:	0141                	addi	sp,sp,16
    80000d68:	8082                	ret
  return 0;
    80000d6a:	4501                	li	a0,0
    80000d6c:	bfe5                	j	80000d64 <memcmp+0x30>

0000000080000d6e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d6e:	1141                	addi	sp,sp,-16
    80000d70:	e422                	sd	s0,8(sp)
    80000d72:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d74:	ca0d                	beqz	a2,80000da6 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d76:	00a5f963          	bgeu	a1,a0,80000d88 <memmove+0x1a>
    80000d7a:	02061693          	slli	a3,a2,0x20
    80000d7e:	9281                	srli	a3,a3,0x20
    80000d80:	00d58733          	add	a4,a1,a3
    80000d84:	02e56463          	bltu	a0,a4,80000dac <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d88:	fff6079b          	addiw	a5,a2,-1
    80000d8c:	1782                	slli	a5,a5,0x20
    80000d8e:	9381                	srli	a5,a5,0x20
    80000d90:	0785                	addi	a5,a5,1
    80000d92:	97ae                	add	a5,a5,a1
    80000d94:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d96:	0585                	addi	a1,a1,1
    80000d98:	0705                	addi	a4,a4,1
    80000d9a:	fff5c683          	lbu	a3,-1(a1)
    80000d9e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000da2:	fef59ae3          	bne	a1,a5,80000d96 <memmove+0x28>

  return dst;
}
    80000da6:	6422                	ld	s0,8(sp)
    80000da8:	0141                	addi	sp,sp,16
    80000daa:	8082                	ret
    d += n;
    80000dac:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dae:	fff6079b          	addiw	a5,a2,-1
    80000db2:	1782                	slli	a5,a5,0x20
    80000db4:	9381                	srli	a5,a5,0x20
    80000db6:	fff7c793          	not	a5,a5
    80000dba:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000dbc:	177d                	addi	a4,a4,-1
    80000dbe:	16fd                	addi	a3,a3,-1
    80000dc0:	00074603          	lbu	a2,0(a4)
    80000dc4:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000dc8:	fef71ae3          	bne	a4,a5,80000dbc <memmove+0x4e>
    80000dcc:	bfe9                	j	80000da6 <memmove+0x38>

0000000080000dce <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dce:	1141                	addi	sp,sp,-16
    80000dd0:	e406                	sd	ra,8(sp)
    80000dd2:	e022                	sd	s0,0(sp)
    80000dd4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dd6:	00000097          	auipc	ra,0x0
    80000dda:	f98080e7          	jalr	-104(ra) # 80000d6e <memmove>
}
    80000dde:	60a2                	ld	ra,8(sp)
    80000de0:	6402                	ld	s0,0(sp)
    80000de2:	0141                	addi	sp,sp,16
    80000de4:	8082                	ret

0000000080000de6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000de6:	1141                	addi	sp,sp,-16
    80000de8:	e422                	sd	s0,8(sp)
    80000dea:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dec:	ce11                	beqz	a2,80000e08 <strncmp+0x22>
    80000dee:	00054783          	lbu	a5,0(a0)
    80000df2:	cf89                	beqz	a5,80000e0c <strncmp+0x26>
    80000df4:	0005c703          	lbu	a4,0(a1)
    80000df8:	00f71a63          	bne	a4,a5,80000e0c <strncmp+0x26>
    n--, p++, q++;
    80000dfc:	367d                	addiw	a2,a2,-1
    80000dfe:	0505                	addi	a0,a0,1
    80000e00:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e02:	f675                	bnez	a2,80000dee <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e04:	4501                	li	a0,0
    80000e06:	a809                	j	80000e18 <strncmp+0x32>
    80000e08:	4501                	li	a0,0
    80000e0a:	a039                	j	80000e18 <strncmp+0x32>
  if(n == 0)
    80000e0c:	ca09                	beqz	a2,80000e1e <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e0e:	00054503          	lbu	a0,0(a0)
    80000e12:	0005c783          	lbu	a5,0(a1)
    80000e16:	9d1d                	subw	a0,a0,a5
}
    80000e18:	6422                	ld	s0,8(sp)
    80000e1a:	0141                	addi	sp,sp,16
    80000e1c:	8082                	ret
    return 0;
    80000e1e:	4501                	li	a0,0
    80000e20:	bfe5                	j	80000e18 <strncmp+0x32>

0000000080000e22 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e22:	1141                	addi	sp,sp,-16
    80000e24:	e422                	sd	s0,8(sp)
    80000e26:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e28:	872a                	mv	a4,a0
    80000e2a:	8832                	mv	a6,a2
    80000e2c:	367d                	addiw	a2,a2,-1
    80000e2e:	01005963          	blez	a6,80000e40 <strncpy+0x1e>
    80000e32:	0705                	addi	a4,a4,1
    80000e34:	0005c783          	lbu	a5,0(a1)
    80000e38:	fef70fa3          	sb	a5,-1(a4)
    80000e3c:	0585                	addi	a1,a1,1
    80000e3e:	f7f5                	bnez	a5,80000e2a <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e40:	00c05d63          	blez	a2,80000e5a <strncpy+0x38>
    80000e44:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e46:	0685                	addi	a3,a3,1
    80000e48:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e4c:	fff6c793          	not	a5,a3
    80000e50:	9fb9                	addw	a5,a5,a4
    80000e52:	010787bb          	addw	a5,a5,a6
    80000e56:	fef048e3          	bgtz	a5,80000e46 <strncpy+0x24>
  return os;
}
    80000e5a:	6422                	ld	s0,8(sp)
    80000e5c:	0141                	addi	sp,sp,16
    80000e5e:	8082                	ret

0000000080000e60 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e60:	1141                	addi	sp,sp,-16
    80000e62:	e422                	sd	s0,8(sp)
    80000e64:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e66:	02c05363          	blez	a2,80000e8c <safestrcpy+0x2c>
    80000e6a:	fff6069b          	addiw	a3,a2,-1
    80000e6e:	1682                	slli	a3,a3,0x20
    80000e70:	9281                	srli	a3,a3,0x20
    80000e72:	96ae                	add	a3,a3,a1
    80000e74:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e76:	00d58963          	beq	a1,a3,80000e88 <safestrcpy+0x28>
    80000e7a:	0585                	addi	a1,a1,1
    80000e7c:	0785                	addi	a5,a5,1
    80000e7e:	fff5c703          	lbu	a4,-1(a1)
    80000e82:	fee78fa3          	sb	a4,-1(a5)
    80000e86:	fb65                	bnez	a4,80000e76 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e88:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e8c:	6422                	ld	s0,8(sp)
    80000e8e:	0141                	addi	sp,sp,16
    80000e90:	8082                	ret

0000000080000e92 <strlen>:

int
strlen(const char *s)
{
    80000e92:	1141                	addi	sp,sp,-16
    80000e94:	e422                	sd	s0,8(sp)
    80000e96:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e98:	00054783          	lbu	a5,0(a0)
    80000e9c:	cf91                	beqz	a5,80000eb8 <strlen+0x26>
    80000e9e:	0505                	addi	a0,a0,1
    80000ea0:	87aa                	mv	a5,a0
    80000ea2:	4685                	li	a3,1
    80000ea4:	9e89                	subw	a3,a3,a0
    80000ea6:	00f6853b          	addw	a0,a3,a5
    80000eaa:	0785                	addi	a5,a5,1
    80000eac:	fff7c703          	lbu	a4,-1(a5)
    80000eb0:	fb7d                	bnez	a4,80000ea6 <strlen+0x14>
    ;
  return n;
}
    80000eb2:	6422                	ld	s0,8(sp)
    80000eb4:	0141                	addi	sp,sp,16
    80000eb6:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eb8:	4501                	li	a0,0
    80000eba:	bfe5                	j	80000eb2 <strlen+0x20>

0000000080000ebc <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ebc:	1141                	addi	sp,sp,-16
    80000ebe:	e406                	sd	ra,8(sp)
    80000ec0:	e022                	sd	s0,0(sp)
    80000ec2:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ec4:	00001097          	auipc	ra,0x1
    80000ec8:	b1a080e7          	jalr	-1254(ra) # 800019de <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ecc:	00008717          	auipc	a4,0x8
    80000ed0:	d8c70713          	addi	a4,a4,-628 # 80008c58 <started>
  if(cpuid() == 0){
    80000ed4:	c139                	beqz	a0,80000f1a <main+0x5e>
    while(started == 0)
    80000ed6:	431c                	lw	a5,0(a4)
    80000ed8:	2781                	sext.w	a5,a5
    80000eda:	dff5                	beqz	a5,80000ed6 <main+0x1a>
      ;
    __sync_synchronize();
    80000edc:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000ee0:	00001097          	auipc	ra,0x1
    80000ee4:	afe080e7          	jalr	-1282(ra) # 800019de <cpuid>
    80000ee8:	85aa                	mv	a1,a0
    80000eea:	00007517          	auipc	a0,0x7
    80000eee:	27650513          	addi	a0,a0,630 # 80008160 <digits+0xc0>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	6c4080e7          	jalr	1732(ra) # 800005b6 <printf>
    kvminithart();    // turn on paging
    80000efa:	00000097          	auipc	ra,0x0
    80000efe:	0f2080e7          	jalr	242(ra) # 80000fec <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f02:	00002097          	auipc	ra,0x2
    80000f06:	888080e7          	jalr	-1912(ra) # 8000278a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f0a:	00005097          	auipc	ra,0x5
    80000f0e:	e76080e7          	jalr	-394(ra) # 80005d80 <plicinithart>
  }
  
  scheduler();        
    80000f12:	00001097          	auipc	ra,0x1
    80000f16:	07a080e7          	jalr	122(ra) # 80001f8c <scheduler>
    printf("%s:%d      [162120120] enter main, init kernel.\n",__FILE__,__LINE__);
    80000f1a:	4639                	li	a2,14
    80000f1c:	00007597          	auipc	a1,0x7
    80000f20:	1e458593          	addi	a1,a1,484 # 80008100 <digits+0x60>
    80000f24:	00007517          	auipc	a0,0x7
    80000f28:	1ec50513          	addi	a0,a0,492 # 80008110 <digits+0x70>
    80000f2c:	fffff097          	auipc	ra,0xfffff
    80000f30:	68a080e7          	jalr	1674(ra) # 800005b6 <printf>
    consoleinit();
    80000f34:	fffff097          	auipc	ra,0xfffff
    80000f38:	54a080e7          	jalr	1354(ra) # 8000047e <consoleinit>
    printfinit();
    80000f3c:	00000097          	auipc	ra,0x0
    80000f40:	860080e7          	jalr	-1952(ra) # 8000079c <printfinit>
    printf("\n");
    80000f44:	00007517          	auipc	a0,0x7
    80000f48:	12450513          	addi	a0,a0,292 # 80008068 <etext+0x68>
    80000f4c:	fffff097          	auipc	ra,0xfffff
    80000f50:	66a080e7          	jalr	1642(ra) # 800005b6 <printf>
    printf("xv6 kernel is booting\n");
    80000f54:	00007517          	auipc	a0,0x7
    80000f58:	1f450513          	addi	a0,a0,500 # 80008148 <digits+0xa8>
    80000f5c:	fffff097          	auipc	ra,0xfffff
    80000f60:	65a080e7          	jalr	1626(ra) # 800005b6 <printf>
    printf("\n");
    80000f64:	00007517          	auipc	a0,0x7
    80000f68:	10450513          	addi	a0,a0,260 # 80008068 <etext+0x68>
    80000f6c:	fffff097          	auipc	ra,0xfffff
    80000f70:	64a080e7          	jalr	1610(ra) # 800005b6 <printf>
    kinit();         // physical page allocator
    80000f74:	00000097          	auipc	ra,0x0
    80000f78:	b72080e7          	jalr	-1166(ra) # 80000ae6 <kinit>
    kvminit();       // create kernel page table
    80000f7c:	00000097          	auipc	ra,0x0
    80000f80:	326080e7          	jalr	806(ra) # 800012a2 <kvminit>
    kvminithart();   // turn on paging
    80000f84:	00000097          	auipc	ra,0x0
    80000f88:	068080e7          	jalr	104(ra) # 80000fec <kvminithart>
    procinit();      // process table
    80000f8c:	00001097          	auipc	ra,0x1
    80000f90:	99c080e7          	jalr	-1636(ra) # 80001928 <procinit>
    trapinit();      // trap vectors
    80000f94:	00001097          	auipc	ra,0x1
    80000f98:	7ce080e7          	jalr	1998(ra) # 80002762 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f9c:	00001097          	auipc	ra,0x1
    80000fa0:	7ee080e7          	jalr	2030(ra) # 8000278a <trapinithart>
    plicinit();      // set up interrupt controller
    80000fa4:	00005097          	auipc	ra,0x5
    80000fa8:	dc6080e7          	jalr	-570(ra) # 80005d6a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fac:	00005097          	auipc	ra,0x5
    80000fb0:	dd4080e7          	jalr	-556(ra) # 80005d80 <plicinithart>
    binit();         // buffer cache
    80000fb4:	00002097          	auipc	ra,0x2
    80000fb8:	f8e080e7          	jalr	-114(ra) # 80002f42 <binit>
    iinit();         // inode table
    80000fbc:	00002097          	auipc	ra,0x2
    80000fc0:	632080e7          	jalr	1586(ra) # 800035ee <iinit>
    fileinit();      // file table
    80000fc4:	00003097          	auipc	ra,0x3
    80000fc8:	5d0080e7          	jalr	1488(ra) # 80004594 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fcc:	00005097          	auipc	ra,0x5
    80000fd0:	ebc080e7          	jalr	-324(ra) # 80005e88 <virtio_disk_init>
    userinit();      // first user process
    80000fd4:	00001097          	auipc	ra,0x1
    80000fd8:	d8a080e7          	jalr	-630(ra) # 80001d5e <userinit>
    __sync_synchronize();
    80000fdc:	0ff0000f          	fence
    started = 1;
    80000fe0:	4785                	li	a5,1
    80000fe2:	00008717          	auipc	a4,0x8
    80000fe6:	c6f72b23          	sw	a5,-906(a4) # 80008c58 <started>
    80000fea:	b725                	j	80000f12 <main+0x56>

0000000080000fec <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fec:	1141                	addi	sp,sp,-16
    80000fee:	e422                	sd	s0,8(sp)
    80000ff0:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ff2:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ff6:	00008797          	auipc	a5,0x8
    80000ffa:	c6a7b783          	ld	a5,-918(a5) # 80008c60 <kernel_pagetable>
    80000ffe:	83b1                	srli	a5,a5,0xc
    80001000:	577d                	li	a4,-1
    80001002:	177e                	slli	a4,a4,0x3f
    80001004:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001006:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    8000100a:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    8000100e:	6422                	ld	s0,8(sp)
    80001010:	0141                	addi	sp,sp,16
    80001012:	8082                	ret

0000000080001014 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001014:	7139                	addi	sp,sp,-64
    80001016:	fc06                	sd	ra,56(sp)
    80001018:	f822                	sd	s0,48(sp)
    8000101a:	f426                	sd	s1,40(sp)
    8000101c:	f04a                	sd	s2,32(sp)
    8000101e:	ec4e                	sd	s3,24(sp)
    80001020:	e852                	sd	s4,16(sp)
    80001022:	e456                	sd	s5,8(sp)
    80001024:	e05a                	sd	s6,0(sp)
    80001026:	0080                	addi	s0,sp,64
    80001028:	84aa                	mv	s1,a0
    8000102a:	89ae                	mv	s3,a1
    8000102c:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000102e:	57fd                	li	a5,-1
    80001030:	83e9                	srli	a5,a5,0x1a
    80001032:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001034:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001036:	04b7f263          	bgeu	a5,a1,8000107a <walk+0x66>
    panic("walk");
    8000103a:	00007517          	auipc	a0,0x7
    8000103e:	13e50513          	addi	a0,a0,318 # 80008178 <digits+0xd8>
    80001042:	fffff097          	auipc	ra,0xfffff
    80001046:	52a080e7          	jalr	1322(ra) # 8000056c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000104a:	060a8663          	beqz	s5,800010b6 <walk+0xa2>
    8000104e:	00000097          	auipc	ra,0x0
    80001052:	ad4080e7          	jalr	-1324(ra) # 80000b22 <kalloc>
    80001056:	84aa                	mv	s1,a0
    80001058:	c529                	beqz	a0,800010a2 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000105a:	6605                	lui	a2,0x1
    8000105c:	4581                	li	a1,0
    8000105e:	00000097          	auipc	ra,0x0
    80001062:	cb0080e7          	jalr	-848(ra) # 80000d0e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001066:	00c4d793          	srli	a5,s1,0xc
    8000106a:	07aa                	slli	a5,a5,0xa
    8000106c:	0017e793          	ori	a5,a5,1
    80001070:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001074:	3a5d                	addiw	s4,s4,-9
    80001076:	036a0063          	beq	s4,s6,80001096 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000107a:	0149d933          	srl	s2,s3,s4
    8000107e:	1ff97913          	andi	s2,s2,511
    80001082:	090e                	slli	s2,s2,0x3
    80001084:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001086:	00093483          	ld	s1,0(s2)
    8000108a:	0014f793          	andi	a5,s1,1
    8000108e:	dfd5                	beqz	a5,8000104a <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001090:	80a9                	srli	s1,s1,0xa
    80001092:	04b2                	slli	s1,s1,0xc
    80001094:	b7c5                	j	80001074 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001096:	00c9d513          	srli	a0,s3,0xc
    8000109a:	1ff57513          	andi	a0,a0,511
    8000109e:	050e                	slli	a0,a0,0x3
    800010a0:	9526                	add	a0,a0,s1
}
    800010a2:	70e2                	ld	ra,56(sp)
    800010a4:	7442                	ld	s0,48(sp)
    800010a6:	74a2                	ld	s1,40(sp)
    800010a8:	7902                	ld	s2,32(sp)
    800010aa:	69e2                	ld	s3,24(sp)
    800010ac:	6a42                	ld	s4,16(sp)
    800010ae:	6aa2                	ld	s5,8(sp)
    800010b0:	6b02                	ld	s6,0(sp)
    800010b2:	6121                	addi	sp,sp,64
    800010b4:	8082                	ret
        return 0;
    800010b6:	4501                	li	a0,0
    800010b8:	b7ed                	j	800010a2 <walk+0x8e>

00000000800010ba <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010ba:	57fd                	li	a5,-1
    800010bc:	83e9                	srli	a5,a5,0x1a
    800010be:	00b7f463          	bgeu	a5,a1,800010c6 <walkaddr+0xc>
    return 0;
    800010c2:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010c4:	8082                	ret
{
    800010c6:	1141                	addi	sp,sp,-16
    800010c8:	e406                	sd	ra,8(sp)
    800010ca:	e022                	sd	s0,0(sp)
    800010cc:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010ce:	4601                	li	a2,0
    800010d0:	00000097          	auipc	ra,0x0
    800010d4:	f44080e7          	jalr	-188(ra) # 80001014 <walk>
  if(pte == 0)
    800010d8:	c105                	beqz	a0,800010f8 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010da:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010dc:	0117f693          	andi	a3,a5,17
    800010e0:	4745                	li	a4,17
    return 0;
    800010e2:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010e4:	00e68663          	beq	a3,a4,800010f0 <walkaddr+0x36>
}
    800010e8:	60a2                	ld	ra,8(sp)
    800010ea:	6402                	ld	s0,0(sp)
    800010ec:	0141                	addi	sp,sp,16
    800010ee:	8082                	ret
  pa = PTE2PA(*pte);
    800010f0:	00a7d513          	srli	a0,a5,0xa
    800010f4:	0532                	slli	a0,a0,0xc
  return pa;
    800010f6:	bfcd                	j	800010e8 <walkaddr+0x2e>
    return 0;
    800010f8:	4501                	li	a0,0
    800010fa:	b7fd                	j	800010e8 <walkaddr+0x2e>

00000000800010fc <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010fc:	715d                	addi	sp,sp,-80
    800010fe:	e486                	sd	ra,72(sp)
    80001100:	e0a2                	sd	s0,64(sp)
    80001102:	fc26                	sd	s1,56(sp)
    80001104:	f84a                	sd	s2,48(sp)
    80001106:	f44e                	sd	s3,40(sp)
    80001108:	f052                	sd	s4,32(sp)
    8000110a:	ec56                	sd	s5,24(sp)
    8000110c:	e85a                	sd	s6,16(sp)
    8000110e:	e45e                	sd	s7,8(sp)
    80001110:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    80001112:	c205                	beqz	a2,80001132 <mappages+0x36>
    80001114:	8aaa                	mv	s5,a0
    80001116:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001118:	77fd                	lui	a5,0xfffff
    8000111a:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    8000111e:	15fd                	addi	a1,a1,-1
    80001120:	00c589b3          	add	s3,a1,a2
    80001124:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    80001128:	8952                	mv	s2,s4
    8000112a:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000112e:	6b85                	lui	s7,0x1
    80001130:	a015                	j	80001154 <mappages+0x58>
    panic("mappages: size");
    80001132:	00007517          	auipc	a0,0x7
    80001136:	04e50513          	addi	a0,a0,78 # 80008180 <digits+0xe0>
    8000113a:	fffff097          	auipc	ra,0xfffff
    8000113e:	432080e7          	jalr	1074(ra) # 8000056c <panic>
      panic("mappages: remap");
    80001142:	00007517          	auipc	a0,0x7
    80001146:	04e50513          	addi	a0,a0,78 # 80008190 <digits+0xf0>
    8000114a:	fffff097          	auipc	ra,0xfffff
    8000114e:	422080e7          	jalr	1058(ra) # 8000056c <panic>
    a += PGSIZE;
    80001152:	995e                	add	s2,s2,s7
  for(;;){
    80001154:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001158:	4605                	li	a2,1
    8000115a:	85ca                	mv	a1,s2
    8000115c:	8556                	mv	a0,s5
    8000115e:	00000097          	auipc	ra,0x0
    80001162:	eb6080e7          	jalr	-330(ra) # 80001014 <walk>
    80001166:	cd19                	beqz	a0,80001184 <mappages+0x88>
    if(*pte & PTE_V)
    80001168:	611c                	ld	a5,0(a0)
    8000116a:	8b85                	andi	a5,a5,1
    8000116c:	fbf9                	bnez	a5,80001142 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000116e:	80b1                	srli	s1,s1,0xc
    80001170:	04aa                	slli	s1,s1,0xa
    80001172:	0164e4b3          	or	s1,s1,s6
    80001176:	0014e493          	ori	s1,s1,1
    8000117a:	e104                	sd	s1,0(a0)
    if(a == last)
    8000117c:	fd391be3          	bne	s2,s3,80001152 <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    80001180:	4501                	li	a0,0
    80001182:	a011                	j	80001186 <mappages+0x8a>
      return -1;
    80001184:	557d                	li	a0,-1
}
    80001186:	60a6                	ld	ra,72(sp)
    80001188:	6406                	ld	s0,64(sp)
    8000118a:	74e2                	ld	s1,56(sp)
    8000118c:	7942                	ld	s2,48(sp)
    8000118e:	79a2                	ld	s3,40(sp)
    80001190:	7a02                	ld	s4,32(sp)
    80001192:	6ae2                	ld	s5,24(sp)
    80001194:	6b42                	ld	s6,16(sp)
    80001196:	6ba2                	ld	s7,8(sp)
    80001198:	6161                	addi	sp,sp,80
    8000119a:	8082                	ret

000000008000119c <kvmmap>:
{
    8000119c:	1141                	addi	sp,sp,-16
    8000119e:	e406                	sd	ra,8(sp)
    800011a0:	e022                	sd	s0,0(sp)
    800011a2:	0800                	addi	s0,sp,16
    800011a4:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011a6:	86b2                	mv	a3,a2
    800011a8:	863e                	mv	a2,a5
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	f52080e7          	jalr	-174(ra) # 800010fc <mappages>
    800011b2:	e509                	bnez	a0,800011bc <kvmmap+0x20>
}
    800011b4:	60a2                	ld	ra,8(sp)
    800011b6:	6402                	ld	s0,0(sp)
    800011b8:	0141                	addi	sp,sp,16
    800011ba:	8082                	ret
    panic("kvmmap");
    800011bc:	00007517          	auipc	a0,0x7
    800011c0:	fe450513          	addi	a0,a0,-28 # 800081a0 <digits+0x100>
    800011c4:	fffff097          	auipc	ra,0xfffff
    800011c8:	3a8080e7          	jalr	936(ra) # 8000056c <panic>

00000000800011cc <kvmmake>:
{
    800011cc:	1101                	addi	sp,sp,-32
    800011ce:	ec06                	sd	ra,24(sp)
    800011d0:	e822                	sd	s0,16(sp)
    800011d2:	e426                	sd	s1,8(sp)
    800011d4:	e04a                	sd	s2,0(sp)
    800011d6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011d8:	00000097          	auipc	ra,0x0
    800011dc:	94a080e7          	jalr	-1718(ra) # 80000b22 <kalloc>
    800011e0:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011e2:	6605                	lui	a2,0x1
    800011e4:	4581                	li	a1,0
    800011e6:	00000097          	auipc	ra,0x0
    800011ea:	b28080e7          	jalr	-1240(ra) # 80000d0e <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011ee:	4719                	li	a4,6
    800011f0:	6685                	lui	a3,0x1
    800011f2:	10000637          	lui	a2,0x10000
    800011f6:	100005b7          	lui	a1,0x10000
    800011fa:	8526                	mv	a0,s1
    800011fc:	00000097          	auipc	ra,0x0
    80001200:	fa0080e7          	jalr	-96(ra) # 8000119c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001204:	4719                	li	a4,6
    80001206:	6685                	lui	a3,0x1
    80001208:	10001637          	lui	a2,0x10001
    8000120c:	100015b7          	lui	a1,0x10001
    80001210:	8526                	mv	a0,s1
    80001212:	00000097          	auipc	ra,0x0
    80001216:	f8a080e7          	jalr	-118(ra) # 8000119c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000121a:	4719                	li	a4,6
    8000121c:	004006b7          	lui	a3,0x400
    80001220:	0c000637          	lui	a2,0xc000
    80001224:	0c0005b7          	lui	a1,0xc000
    80001228:	8526                	mv	a0,s1
    8000122a:	00000097          	auipc	ra,0x0
    8000122e:	f72080e7          	jalr	-142(ra) # 8000119c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001232:	00007917          	auipc	s2,0x7
    80001236:	dce90913          	addi	s2,s2,-562 # 80008000 <etext>
    8000123a:	4729                	li	a4,10
    8000123c:	80007697          	auipc	a3,0x80007
    80001240:	dc468693          	addi	a3,a3,-572 # 8000 <_entry-0x7fff8000>
    80001244:	4605                	li	a2,1
    80001246:	067e                	slli	a2,a2,0x1f
    80001248:	85b2                	mv	a1,a2
    8000124a:	8526                	mv	a0,s1
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f50080e7          	jalr	-176(ra) # 8000119c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001254:	4719                	li	a4,6
    80001256:	46c5                	li	a3,17
    80001258:	06ee                	slli	a3,a3,0x1b
    8000125a:	412686b3          	sub	a3,a3,s2
    8000125e:	864a                	mv	a2,s2
    80001260:	85ca                	mv	a1,s2
    80001262:	8526                	mv	a0,s1
    80001264:	00000097          	auipc	ra,0x0
    80001268:	f38080e7          	jalr	-200(ra) # 8000119c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000126c:	4729                	li	a4,10
    8000126e:	6685                	lui	a3,0x1
    80001270:	00006617          	auipc	a2,0x6
    80001274:	d9060613          	addi	a2,a2,-624 # 80007000 <_trampoline>
    80001278:	040005b7          	lui	a1,0x4000
    8000127c:	15fd                	addi	a1,a1,-1
    8000127e:	05b2                	slli	a1,a1,0xc
    80001280:	8526                	mv	a0,s1
    80001282:	00000097          	auipc	ra,0x0
    80001286:	f1a080e7          	jalr	-230(ra) # 8000119c <kvmmap>
  proc_mapstacks(kpgtbl);
    8000128a:	8526                	mv	a0,s1
    8000128c:	00000097          	auipc	ra,0x0
    80001290:	606080e7          	jalr	1542(ra) # 80001892 <proc_mapstacks>
}
    80001294:	8526                	mv	a0,s1
    80001296:	60e2                	ld	ra,24(sp)
    80001298:	6442                	ld	s0,16(sp)
    8000129a:	64a2                	ld	s1,8(sp)
    8000129c:	6902                	ld	s2,0(sp)
    8000129e:	6105                	addi	sp,sp,32
    800012a0:	8082                	ret

00000000800012a2 <kvminit>:
{
    800012a2:	1141                	addi	sp,sp,-16
    800012a4:	e406                	sd	ra,8(sp)
    800012a6:	e022                	sd	s0,0(sp)
    800012a8:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800012aa:	00000097          	auipc	ra,0x0
    800012ae:	f22080e7          	jalr	-222(ra) # 800011cc <kvmmake>
    800012b2:	00008797          	auipc	a5,0x8
    800012b6:	9aa7b723          	sd	a0,-1618(a5) # 80008c60 <kernel_pagetable>
}
    800012ba:	60a2                	ld	ra,8(sp)
    800012bc:	6402                	ld	s0,0(sp)
    800012be:	0141                	addi	sp,sp,16
    800012c0:	8082                	ret

00000000800012c2 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012c2:	715d                	addi	sp,sp,-80
    800012c4:	e486                	sd	ra,72(sp)
    800012c6:	e0a2                	sd	s0,64(sp)
    800012c8:	fc26                	sd	s1,56(sp)
    800012ca:	f84a                	sd	s2,48(sp)
    800012cc:	f44e                	sd	s3,40(sp)
    800012ce:	f052                	sd	s4,32(sp)
    800012d0:	ec56                	sd	s5,24(sp)
    800012d2:	e85a                	sd	s6,16(sp)
    800012d4:	e45e                	sd	s7,8(sp)
    800012d6:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012d8:	03459793          	slli	a5,a1,0x34
    800012dc:	e795                	bnez	a5,80001308 <uvmunmap+0x46>
    800012de:	8a2a                	mv	s4,a0
    800012e0:	892e                	mv	s2,a1
    800012e2:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e4:	0632                	slli	a2,a2,0xc
    800012e6:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012ea:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ec:	6b05                	lui	s6,0x1
    800012ee:	0735e863          	bltu	a1,s3,8000135e <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012f2:	60a6                	ld	ra,72(sp)
    800012f4:	6406                	ld	s0,64(sp)
    800012f6:	74e2                	ld	s1,56(sp)
    800012f8:	7942                	ld	s2,48(sp)
    800012fa:	79a2                	ld	s3,40(sp)
    800012fc:	7a02                	ld	s4,32(sp)
    800012fe:	6ae2                	ld	s5,24(sp)
    80001300:	6b42                	ld	s6,16(sp)
    80001302:	6ba2                	ld	s7,8(sp)
    80001304:	6161                	addi	sp,sp,80
    80001306:	8082                	ret
    panic("uvmunmap: not aligned");
    80001308:	00007517          	auipc	a0,0x7
    8000130c:	ea050513          	addi	a0,a0,-352 # 800081a8 <digits+0x108>
    80001310:	fffff097          	auipc	ra,0xfffff
    80001314:	25c080e7          	jalr	604(ra) # 8000056c <panic>
      panic("uvmunmap: walk");
    80001318:	00007517          	auipc	a0,0x7
    8000131c:	ea850513          	addi	a0,a0,-344 # 800081c0 <digits+0x120>
    80001320:	fffff097          	auipc	ra,0xfffff
    80001324:	24c080e7          	jalr	588(ra) # 8000056c <panic>
      panic("uvmunmap: not mapped");
    80001328:	00007517          	auipc	a0,0x7
    8000132c:	ea850513          	addi	a0,a0,-344 # 800081d0 <digits+0x130>
    80001330:	fffff097          	auipc	ra,0xfffff
    80001334:	23c080e7          	jalr	572(ra) # 8000056c <panic>
      panic("uvmunmap: not a leaf");
    80001338:	00007517          	auipc	a0,0x7
    8000133c:	eb050513          	addi	a0,a0,-336 # 800081e8 <digits+0x148>
    80001340:	fffff097          	auipc	ra,0xfffff
    80001344:	22c080e7          	jalr	556(ra) # 8000056c <panic>
      uint64 pa = PTE2PA(*pte);
    80001348:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000134a:	0532                	slli	a0,a0,0xc
    8000134c:	fffff097          	auipc	ra,0xfffff
    80001350:	6da080e7          	jalr	1754(ra) # 80000a26 <kfree>
    *pte = 0;
    80001354:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001358:	995a                	add	s2,s2,s6
    8000135a:	f9397ce3          	bgeu	s2,s3,800012f2 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000135e:	4601                	li	a2,0
    80001360:	85ca                	mv	a1,s2
    80001362:	8552                	mv	a0,s4
    80001364:	00000097          	auipc	ra,0x0
    80001368:	cb0080e7          	jalr	-848(ra) # 80001014 <walk>
    8000136c:	84aa                	mv	s1,a0
    8000136e:	d54d                	beqz	a0,80001318 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001370:	6108                	ld	a0,0(a0)
    80001372:	00157793          	andi	a5,a0,1
    80001376:	dbcd                	beqz	a5,80001328 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001378:	3ff57793          	andi	a5,a0,1023
    8000137c:	fb778ee3          	beq	a5,s7,80001338 <uvmunmap+0x76>
    if(do_free){
    80001380:	fc0a8ae3          	beqz	s5,80001354 <uvmunmap+0x92>
    80001384:	b7d1                	j	80001348 <uvmunmap+0x86>

0000000080001386 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001386:	1101                	addi	sp,sp,-32
    80001388:	ec06                	sd	ra,24(sp)
    8000138a:	e822                	sd	s0,16(sp)
    8000138c:	e426                	sd	s1,8(sp)
    8000138e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001390:	fffff097          	auipc	ra,0xfffff
    80001394:	792080e7          	jalr	1938(ra) # 80000b22 <kalloc>
    80001398:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000139a:	c519                	beqz	a0,800013a8 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000139c:	6605                	lui	a2,0x1
    8000139e:	4581                	li	a1,0
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	96e080e7          	jalr	-1682(ra) # 80000d0e <memset>
  return pagetable;
}
    800013a8:	8526                	mv	a0,s1
    800013aa:	60e2                	ld	ra,24(sp)
    800013ac:	6442                	ld	s0,16(sp)
    800013ae:	64a2                	ld	s1,8(sp)
    800013b0:	6105                	addi	sp,sp,32
    800013b2:	8082                	ret

00000000800013b4 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800013b4:	7179                	addi	sp,sp,-48
    800013b6:	f406                	sd	ra,40(sp)
    800013b8:	f022                	sd	s0,32(sp)
    800013ba:	ec26                	sd	s1,24(sp)
    800013bc:	e84a                	sd	s2,16(sp)
    800013be:	e44e                	sd	s3,8(sp)
    800013c0:	e052                	sd	s4,0(sp)
    800013c2:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013c4:	6785                	lui	a5,0x1
    800013c6:	04f67863          	bgeu	a2,a5,80001416 <uvmfirst+0x62>
    800013ca:	8a2a                	mv	s4,a0
    800013cc:	89ae                	mv	s3,a1
    800013ce:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800013d0:	fffff097          	auipc	ra,0xfffff
    800013d4:	752080e7          	jalr	1874(ra) # 80000b22 <kalloc>
    800013d8:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013da:	6605                	lui	a2,0x1
    800013dc:	4581                	li	a1,0
    800013de:	00000097          	auipc	ra,0x0
    800013e2:	930080e7          	jalr	-1744(ra) # 80000d0e <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013e6:	4779                	li	a4,30
    800013e8:	86ca                	mv	a3,s2
    800013ea:	6605                	lui	a2,0x1
    800013ec:	4581                	li	a1,0
    800013ee:	8552                	mv	a0,s4
    800013f0:	00000097          	auipc	ra,0x0
    800013f4:	d0c080e7          	jalr	-756(ra) # 800010fc <mappages>
  memmove(mem, src, sz);
    800013f8:	8626                	mv	a2,s1
    800013fa:	85ce                	mv	a1,s3
    800013fc:	854a                	mv	a0,s2
    800013fe:	00000097          	auipc	ra,0x0
    80001402:	970080e7          	jalr	-1680(ra) # 80000d6e <memmove>
}
    80001406:	70a2                	ld	ra,40(sp)
    80001408:	7402                	ld	s0,32(sp)
    8000140a:	64e2                	ld	s1,24(sp)
    8000140c:	6942                	ld	s2,16(sp)
    8000140e:	69a2                	ld	s3,8(sp)
    80001410:	6a02                	ld	s4,0(sp)
    80001412:	6145                	addi	sp,sp,48
    80001414:	8082                	ret
    panic("uvmfirst: more than a page");
    80001416:	00007517          	auipc	a0,0x7
    8000141a:	dea50513          	addi	a0,a0,-534 # 80008200 <digits+0x160>
    8000141e:	fffff097          	auipc	ra,0xfffff
    80001422:	14e080e7          	jalr	334(ra) # 8000056c <panic>

0000000080001426 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001426:	1101                	addi	sp,sp,-32
    80001428:	ec06                	sd	ra,24(sp)
    8000142a:	e822                	sd	s0,16(sp)
    8000142c:	e426                	sd	s1,8(sp)
    8000142e:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001430:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001432:	00b67d63          	bgeu	a2,a1,8000144c <uvmdealloc+0x26>
    80001436:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001438:	6785                	lui	a5,0x1
    8000143a:	17fd                	addi	a5,a5,-1
    8000143c:	00f60733          	add	a4,a2,a5
    80001440:	767d                	lui	a2,0xfffff
    80001442:	8f71                	and	a4,a4,a2
    80001444:	97ae                	add	a5,a5,a1
    80001446:	8ff1                	and	a5,a5,a2
    80001448:	00f76863          	bltu	a4,a5,80001458 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000144c:	8526                	mv	a0,s1
    8000144e:	60e2                	ld	ra,24(sp)
    80001450:	6442                	ld	s0,16(sp)
    80001452:	64a2                	ld	s1,8(sp)
    80001454:	6105                	addi	sp,sp,32
    80001456:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001458:	8f99                	sub	a5,a5,a4
    8000145a:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000145c:	4685                	li	a3,1
    8000145e:	0007861b          	sext.w	a2,a5
    80001462:	85ba                	mv	a1,a4
    80001464:	00000097          	auipc	ra,0x0
    80001468:	e5e080e7          	jalr	-418(ra) # 800012c2 <uvmunmap>
    8000146c:	b7c5                	j	8000144c <uvmdealloc+0x26>

000000008000146e <uvmalloc>:
  if(newsz < oldsz)
    8000146e:	0ab66563          	bltu	a2,a1,80001518 <uvmalloc+0xaa>
{
    80001472:	7139                	addi	sp,sp,-64
    80001474:	fc06                	sd	ra,56(sp)
    80001476:	f822                	sd	s0,48(sp)
    80001478:	f426                	sd	s1,40(sp)
    8000147a:	f04a                	sd	s2,32(sp)
    8000147c:	ec4e                	sd	s3,24(sp)
    8000147e:	e852                	sd	s4,16(sp)
    80001480:	e456                	sd	s5,8(sp)
    80001482:	e05a                	sd	s6,0(sp)
    80001484:	0080                	addi	s0,sp,64
    80001486:	8aaa                	mv	s5,a0
    80001488:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000148a:	6985                	lui	s3,0x1
    8000148c:	19fd                	addi	s3,s3,-1
    8000148e:	95ce                	add	a1,a1,s3
    80001490:	79fd                	lui	s3,0xfffff
    80001492:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001496:	08c9f363          	bgeu	s3,a2,8000151c <uvmalloc+0xae>
    8000149a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000149c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	682080e7          	jalr	1666(ra) # 80000b22 <kalloc>
    800014a8:	84aa                	mv	s1,a0
    if(mem == 0){
    800014aa:	c51d                	beqz	a0,800014d8 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    800014ac:	6605                	lui	a2,0x1
    800014ae:	4581                	li	a1,0
    800014b0:	00000097          	auipc	ra,0x0
    800014b4:	85e080e7          	jalr	-1954(ra) # 80000d0e <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014b8:	875a                	mv	a4,s6
    800014ba:	86a6                	mv	a3,s1
    800014bc:	6605                	lui	a2,0x1
    800014be:	85ca                	mv	a1,s2
    800014c0:	8556                	mv	a0,s5
    800014c2:	00000097          	auipc	ra,0x0
    800014c6:	c3a080e7          	jalr	-966(ra) # 800010fc <mappages>
    800014ca:	e90d                	bnez	a0,800014fc <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014cc:	6785                	lui	a5,0x1
    800014ce:	993e                	add	s2,s2,a5
    800014d0:	fd4968e3          	bltu	s2,s4,800014a0 <uvmalloc+0x32>
  return newsz;
    800014d4:	8552                	mv	a0,s4
    800014d6:	a809                	j	800014e8 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    800014d8:	864e                	mv	a2,s3
    800014da:	85ca                	mv	a1,s2
    800014dc:	8556                	mv	a0,s5
    800014de:	00000097          	auipc	ra,0x0
    800014e2:	f48080e7          	jalr	-184(ra) # 80001426 <uvmdealloc>
      return 0;
    800014e6:	4501                	li	a0,0
}
    800014e8:	70e2                	ld	ra,56(sp)
    800014ea:	7442                	ld	s0,48(sp)
    800014ec:	74a2                	ld	s1,40(sp)
    800014ee:	7902                	ld	s2,32(sp)
    800014f0:	69e2                	ld	s3,24(sp)
    800014f2:	6a42                	ld	s4,16(sp)
    800014f4:	6aa2                	ld	s5,8(sp)
    800014f6:	6b02                	ld	s6,0(sp)
    800014f8:	6121                	addi	sp,sp,64
    800014fa:	8082                	ret
      kfree(mem);
    800014fc:	8526                	mv	a0,s1
    800014fe:	fffff097          	auipc	ra,0xfffff
    80001502:	528080e7          	jalr	1320(ra) # 80000a26 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001506:	864e                	mv	a2,s3
    80001508:	85ca                	mv	a1,s2
    8000150a:	8556                	mv	a0,s5
    8000150c:	00000097          	auipc	ra,0x0
    80001510:	f1a080e7          	jalr	-230(ra) # 80001426 <uvmdealloc>
      return 0;
    80001514:	4501                	li	a0,0
    80001516:	bfc9                	j	800014e8 <uvmalloc+0x7a>
    return oldsz;
    80001518:	852e                	mv	a0,a1
}
    8000151a:	8082                	ret
  return newsz;
    8000151c:	8532                	mv	a0,a2
    8000151e:	b7e9                	j	800014e8 <uvmalloc+0x7a>

0000000080001520 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001520:	7179                	addi	sp,sp,-48
    80001522:	f406                	sd	ra,40(sp)
    80001524:	f022                	sd	s0,32(sp)
    80001526:	ec26                	sd	s1,24(sp)
    80001528:	e84a                	sd	s2,16(sp)
    8000152a:	e44e                	sd	s3,8(sp)
    8000152c:	e052                	sd	s4,0(sp)
    8000152e:	1800                	addi	s0,sp,48
    80001530:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001532:	84aa                	mv	s1,a0
    80001534:	6905                	lui	s2,0x1
    80001536:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001538:	4985                	li	s3,1
    8000153a:	a821                	j	80001552 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000153c:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000153e:	0532                	slli	a0,a0,0xc
    80001540:	00000097          	auipc	ra,0x0
    80001544:	fe0080e7          	jalr	-32(ra) # 80001520 <freewalk>
      pagetable[i] = 0;
    80001548:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000154c:	04a1                	addi	s1,s1,8
    8000154e:	03248163          	beq	s1,s2,80001570 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001552:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001554:	00f57793          	andi	a5,a0,15
    80001558:	ff3782e3          	beq	a5,s3,8000153c <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000155c:	8905                	andi	a0,a0,1
    8000155e:	d57d                	beqz	a0,8000154c <freewalk+0x2c>
      panic("freewalk: leaf");
    80001560:	00007517          	auipc	a0,0x7
    80001564:	cc050513          	addi	a0,a0,-832 # 80008220 <digits+0x180>
    80001568:	fffff097          	auipc	ra,0xfffff
    8000156c:	004080e7          	jalr	4(ra) # 8000056c <panic>
    }
  }
  kfree((void*)pagetable);
    80001570:	8552                	mv	a0,s4
    80001572:	fffff097          	auipc	ra,0xfffff
    80001576:	4b4080e7          	jalr	1204(ra) # 80000a26 <kfree>
}
    8000157a:	70a2                	ld	ra,40(sp)
    8000157c:	7402                	ld	s0,32(sp)
    8000157e:	64e2                	ld	s1,24(sp)
    80001580:	6942                	ld	s2,16(sp)
    80001582:	69a2                	ld	s3,8(sp)
    80001584:	6a02                	ld	s4,0(sp)
    80001586:	6145                	addi	sp,sp,48
    80001588:	8082                	ret

000000008000158a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000158a:	1101                	addi	sp,sp,-32
    8000158c:	ec06                	sd	ra,24(sp)
    8000158e:	e822                	sd	s0,16(sp)
    80001590:	e426                	sd	s1,8(sp)
    80001592:	1000                	addi	s0,sp,32
    80001594:	84aa                	mv	s1,a0
  if(sz > 0)
    80001596:	e999                	bnez	a1,800015ac <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001598:	8526                	mv	a0,s1
    8000159a:	00000097          	auipc	ra,0x0
    8000159e:	f86080e7          	jalr	-122(ra) # 80001520 <freewalk>
}
    800015a2:	60e2                	ld	ra,24(sp)
    800015a4:	6442                	ld	s0,16(sp)
    800015a6:	64a2                	ld	s1,8(sp)
    800015a8:	6105                	addi	sp,sp,32
    800015aa:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015ac:	6605                	lui	a2,0x1
    800015ae:	167d                	addi	a2,a2,-1
    800015b0:	962e                	add	a2,a2,a1
    800015b2:	4685                	li	a3,1
    800015b4:	8231                	srli	a2,a2,0xc
    800015b6:	4581                	li	a1,0
    800015b8:	00000097          	auipc	ra,0x0
    800015bc:	d0a080e7          	jalr	-758(ra) # 800012c2 <uvmunmap>
    800015c0:	bfe1                	j	80001598 <uvmfree+0xe>

00000000800015c2 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015c2:	c679                	beqz	a2,80001690 <uvmcopy+0xce>
{
    800015c4:	715d                	addi	sp,sp,-80
    800015c6:	e486                	sd	ra,72(sp)
    800015c8:	e0a2                	sd	s0,64(sp)
    800015ca:	fc26                	sd	s1,56(sp)
    800015cc:	f84a                	sd	s2,48(sp)
    800015ce:	f44e                	sd	s3,40(sp)
    800015d0:	f052                	sd	s4,32(sp)
    800015d2:	ec56                	sd	s5,24(sp)
    800015d4:	e85a                	sd	s6,16(sp)
    800015d6:	e45e                	sd	s7,8(sp)
    800015d8:	0880                	addi	s0,sp,80
    800015da:	8b2a                	mv	s6,a0
    800015dc:	8aae                	mv	s5,a1
    800015de:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015e0:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015e2:	4601                	li	a2,0
    800015e4:	85ce                	mv	a1,s3
    800015e6:	855a                	mv	a0,s6
    800015e8:	00000097          	auipc	ra,0x0
    800015ec:	a2c080e7          	jalr	-1492(ra) # 80001014 <walk>
    800015f0:	c531                	beqz	a0,8000163c <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015f2:	6118                	ld	a4,0(a0)
    800015f4:	00177793          	andi	a5,a4,1
    800015f8:	cbb1                	beqz	a5,8000164c <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015fa:	00a75593          	srli	a1,a4,0xa
    800015fe:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001602:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001606:	fffff097          	auipc	ra,0xfffff
    8000160a:	51c080e7          	jalr	1308(ra) # 80000b22 <kalloc>
    8000160e:	892a                	mv	s2,a0
    80001610:	c939                	beqz	a0,80001666 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001612:	6605                	lui	a2,0x1
    80001614:	85de                	mv	a1,s7
    80001616:	fffff097          	auipc	ra,0xfffff
    8000161a:	758080e7          	jalr	1880(ra) # 80000d6e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000161e:	8726                	mv	a4,s1
    80001620:	86ca                	mv	a3,s2
    80001622:	6605                	lui	a2,0x1
    80001624:	85ce                	mv	a1,s3
    80001626:	8556                	mv	a0,s5
    80001628:	00000097          	auipc	ra,0x0
    8000162c:	ad4080e7          	jalr	-1324(ra) # 800010fc <mappages>
    80001630:	e515                	bnez	a0,8000165c <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001632:	6785                	lui	a5,0x1
    80001634:	99be                	add	s3,s3,a5
    80001636:	fb49e6e3          	bltu	s3,s4,800015e2 <uvmcopy+0x20>
    8000163a:	a081                	j	8000167a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    8000163c:	00007517          	auipc	a0,0x7
    80001640:	bf450513          	addi	a0,a0,-1036 # 80008230 <digits+0x190>
    80001644:	fffff097          	auipc	ra,0xfffff
    80001648:	f28080e7          	jalr	-216(ra) # 8000056c <panic>
      panic("uvmcopy: page not present");
    8000164c:	00007517          	auipc	a0,0x7
    80001650:	c0450513          	addi	a0,a0,-1020 # 80008250 <digits+0x1b0>
    80001654:	fffff097          	auipc	ra,0xfffff
    80001658:	f18080e7          	jalr	-232(ra) # 8000056c <panic>
      kfree(mem);
    8000165c:	854a                	mv	a0,s2
    8000165e:	fffff097          	auipc	ra,0xfffff
    80001662:	3c8080e7          	jalr	968(ra) # 80000a26 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001666:	4685                	li	a3,1
    80001668:	00c9d613          	srli	a2,s3,0xc
    8000166c:	4581                	li	a1,0
    8000166e:	8556                	mv	a0,s5
    80001670:	00000097          	auipc	ra,0x0
    80001674:	c52080e7          	jalr	-942(ra) # 800012c2 <uvmunmap>
  return -1;
    80001678:	557d                	li	a0,-1
}
    8000167a:	60a6                	ld	ra,72(sp)
    8000167c:	6406                	ld	s0,64(sp)
    8000167e:	74e2                	ld	s1,56(sp)
    80001680:	7942                	ld	s2,48(sp)
    80001682:	79a2                	ld	s3,40(sp)
    80001684:	7a02                	ld	s4,32(sp)
    80001686:	6ae2                	ld	s5,24(sp)
    80001688:	6b42                	ld	s6,16(sp)
    8000168a:	6ba2                	ld	s7,8(sp)
    8000168c:	6161                	addi	sp,sp,80
    8000168e:	8082                	ret
  return 0;
    80001690:	4501                	li	a0,0
}
    80001692:	8082                	ret

0000000080001694 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001694:	1141                	addi	sp,sp,-16
    80001696:	e406                	sd	ra,8(sp)
    80001698:	e022                	sd	s0,0(sp)
    8000169a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000169c:	4601                	li	a2,0
    8000169e:	00000097          	auipc	ra,0x0
    800016a2:	976080e7          	jalr	-1674(ra) # 80001014 <walk>
  if(pte == 0)
    800016a6:	c901                	beqz	a0,800016b6 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016a8:	611c                	ld	a5,0(a0)
    800016aa:	9bbd                	andi	a5,a5,-17
    800016ac:	e11c                	sd	a5,0(a0)
}
    800016ae:	60a2                	ld	ra,8(sp)
    800016b0:	6402                	ld	s0,0(sp)
    800016b2:	0141                	addi	sp,sp,16
    800016b4:	8082                	ret
    panic("uvmclear");
    800016b6:	00007517          	auipc	a0,0x7
    800016ba:	bba50513          	addi	a0,a0,-1094 # 80008270 <digits+0x1d0>
    800016be:	fffff097          	auipc	ra,0xfffff
    800016c2:	eae080e7          	jalr	-338(ra) # 8000056c <panic>

00000000800016c6 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016c6:	c6bd                	beqz	a3,80001734 <copyout+0x6e>
{
    800016c8:	715d                	addi	sp,sp,-80
    800016ca:	e486                	sd	ra,72(sp)
    800016cc:	e0a2                	sd	s0,64(sp)
    800016ce:	fc26                	sd	s1,56(sp)
    800016d0:	f84a                	sd	s2,48(sp)
    800016d2:	f44e                	sd	s3,40(sp)
    800016d4:	f052                	sd	s4,32(sp)
    800016d6:	ec56                	sd	s5,24(sp)
    800016d8:	e85a                	sd	s6,16(sp)
    800016da:	e45e                	sd	s7,8(sp)
    800016dc:	e062                	sd	s8,0(sp)
    800016de:	0880                	addi	s0,sp,80
    800016e0:	8b2a                	mv	s6,a0
    800016e2:	8c2e                	mv	s8,a1
    800016e4:	8a32                	mv	s4,a2
    800016e6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016e8:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016ea:	6a85                	lui	s5,0x1
    800016ec:	a015                	j	80001710 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016ee:	9562                	add	a0,a0,s8
    800016f0:	0004861b          	sext.w	a2,s1
    800016f4:	85d2                	mv	a1,s4
    800016f6:	41250533          	sub	a0,a0,s2
    800016fa:	fffff097          	auipc	ra,0xfffff
    800016fe:	674080e7          	jalr	1652(ra) # 80000d6e <memmove>

    len -= n;
    80001702:	409989b3          	sub	s3,s3,s1
    src += n;
    80001706:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001708:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000170c:	02098263          	beqz	s3,80001730 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001710:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001714:	85ca                	mv	a1,s2
    80001716:	855a                	mv	a0,s6
    80001718:	00000097          	auipc	ra,0x0
    8000171c:	9a2080e7          	jalr	-1630(ra) # 800010ba <walkaddr>
    if(pa0 == 0)
    80001720:	cd01                	beqz	a0,80001738 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001722:	418904b3          	sub	s1,s2,s8
    80001726:	94d6                	add	s1,s1,s5
    if(n > len)
    80001728:	fc99f3e3          	bgeu	s3,s1,800016ee <copyout+0x28>
    8000172c:	84ce                	mv	s1,s3
    8000172e:	b7c1                	j	800016ee <copyout+0x28>
  }
  return 0;
    80001730:	4501                	li	a0,0
    80001732:	a021                	j	8000173a <copyout+0x74>
    80001734:	4501                	li	a0,0
}
    80001736:	8082                	ret
      return -1;
    80001738:	557d                	li	a0,-1
}
    8000173a:	60a6                	ld	ra,72(sp)
    8000173c:	6406                	ld	s0,64(sp)
    8000173e:	74e2                	ld	s1,56(sp)
    80001740:	7942                	ld	s2,48(sp)
    80001742:	79a2                	ld	s3,40(sp)
    80001744:	7a02                	ld	s4,32(sp)
    80001746:	6ae2                	ld	s5,24(sp)
    80001748:	6b42                	ld	s6,16(sp)
    8000174a:	6ba2                	ld	s7,8(sp)
    8000174c:	6c02                	ld	s8,0(sp)
    8000174e:	6161                	addi	sp,sp,80
    80001750:	8082                	ret

0000000080001752 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001752:	c6bd                	beqz	a3,800017c0 <copyin+0x6e>
{
    80001754:	715d                	addi	sp,sp,-80
    80001756:	e486                	sd	ra,72(sp)
    80001758:	e0a2                	sd	s0,64(sp)
    8000175a:	fc26                	sd	s1,56(sp)
    8000175c:	f84a                	sd	s2,48(sp)
    8000175e:	f44e                	sd	s3,40(sp)
    80001760:	f052                	sd	s4,32(sp)
    80001762:	ec56                	sd	s5,24(sp)
    80001764:	e85a                	sd	s6,16(sp)
    80001766:	e45e                	sd	s7,8(sp)
    80001768:	e062                	sd	s8,0(sp)
    8000176a:	0880                	addi	s0,sp,80
    8000176c:	8b2a                	mv	s6,a0
    8000176e:	8a2e                	mv	s4,a1
    80001770:	8c32                	mv	s8,a2
    80001772:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001774:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001776:	6a85                	lui	s5,0x1
    80001778:	a015                	j	8000179c <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000177a:	9562                	add	a0,a0,s8
    8000177c:	0004861b          	sext.w	a2,s1
    80001780:	412505b3          	sub	a1,a0,s2
    80001784:	8552                	mv	a0,s4
    80001786:	fffff097          	auipc	ra,0xfffff
    8000178a:	5e8080e7          	jalr	1512(ra) # 80000d6e <memmove>

    len -= n;
    8000178e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001792:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001794:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001798:	02098263          	beqz	s3,800017bc <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    8000179c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017a0:	85ca                	mv	a1,s2
    800017a2:	855a                	mv	a0,s6
    800017a4:	00000097          	auipc	ra,0x0
    800017a8:	916080e7          	jalr	-1770(ra) # 800010ba <walkaddr>
    if(pa0 == 0)
    800017ac:	cd01                	beqz	a0,800017c4 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    800017ae:	418904b3          	sub	s1,s2,s8
    800017b2:	94d6                	add	s1,s1,s5
    if(n > len)
    800017b4:	fc99f3e3          	bgeu	s3,s1,8000177a <copyin+0x28>
    800017b8:	84ce                	mv	s1,s3
    800017ba:	b7c1                	j	8000177a <copyin+0x28>
  }
  return 0;
    800017bc:	4501                	li	a0,0
    800017be:	a021                	j	800017c6 <copyin+0x74>
    800017c0:	4501                	li	a0,0
}
    800017c2:	8082                	ret
      return -1;
    800017c4:	557d                	li	a0,-1
}
    800017c6:	60a6                	ld	ra,72(sp)
    800017c8:	6406                	ld	s0,64(sp)
    800017ca:	74e2                	ld	s1,56(sp)
    800017cc:	7942                	ld	s2,48(sp)
    800017ce:	79a2                	ld	s3,40(sp)
    800017d0:	7a02                	ld	s4,32(sp)
    800017d2:	6ae2                	ld	s5,24(sp)
    800017d4:	6b42                	ld	s6,16(sp)
    800017d6:	6ba2                	ld	s7,8(sp)
    800017d8:	6c02                	ld	s8,0(sp)
    800017da:	6161                	addi	sp,sp,80
    800017dc:	8082                	ret

00000000800017de <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017de:	c6c5                	beqz	a3,80001886 <copyinstr+0xa8>
{
    800017e0:	715d                	addi	sp,sp,-80
    800017e2:	e486                	sd	ra,72(sp)
    800017e4:	e0a2                	sd	s0,64(sp)
    800017e6:	fc26                	sd	s1,56(sp)
    800017e8:	f84a                	sd	s2,48(sp)
    800017ea:	f44e                	sd	s3,40(sp)
    800017ec:	f052                	sd	s4,32(sp)
    800017ee:	ec56                	sd	s5,24(sp)
    800017f0:	e85a                	sd	s6,16(sp)
    800017f2:	e45e                	sd	s7,8(sp)
    800017f4:	0880                	addi	s0,sp,80
    800017f6:	8a2a                	mv	s4,a0
    800017f8:	8b2e                	mv	s6,a1
    800017fa:	8bb2                	mv	s7,a2
    800017fc:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017fe:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001800:	6985                	lui	s3,0x1
    80001802:	a035                	j	8000182e <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001804:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001808:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000180a:	0017b793          	seqz	a5,a5
    8000180e:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001812:	60a6                	ld	ra,72(sp)
    80001814:	6406                	ld	s0,64(sp)
    80001816:	74e2                	ld	s1,56(sp)
    80001818:	7942                	ld	s2,48(sp)
    8000181a:	79a2                	ld	s3,40(sp)
    8000181c:	7a02                	ld	s4,32(sp)
    8000181e:	6ae2                	ld	s5,24(sp)
    80001820:	6b42                	ld	s6,16(sp)
    80001822:	6ba2                	ld	s7,8(sp)
    80001824:	6161                	addi	sp,sp,80
    80001826:	8082                	ret
    srcva = va0 + PGSIZE;
    80001828:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000182c:	c8a9                	beqz	s1,8000187e <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    8000182e:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001832:	85ca                	mv	a1,s2
    80001834:	8552                	mv	a0,s4
    80001836:	00000097          	auipc	ra,0x0
    8000183a:	884080e7          	jalr	-1916(ra) # 800010ba <walkaddr>
    if(pa0 == 0)
    8000183e:	c131                	beqz	a0,80001882 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001840:	41790833          	sub	a6,s2,s7
    80001844:	984e                	add	a6,a6,s3
    if(n > max)
    80001846:	0104f363          	bgeu	s1,a6,8000184c <copyinstr+0x6e>
    8000184a:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000184c:	955e                	add	a0,a0,s7
    8000184e:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001852:	fc080be3          	beqz	a6,80001828 <copyinstr+0x4a>
    80001856:	985a                	add	a6,a6,s6
    80001858:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000185a:	41650633          	sub	a2,a0,s6
    8000185e:	14fd                	addi	s1,s1,-1
    80001860:	9b26                	add	s6,s6,s1
    80001862:	00f60733          	add	a4,a2,a5
    80001866:	00074703          	lbu	a4,0(a4)
    8000186a:	df49                	beqz	a4,80001804 <copyinstr+0x26>
        *dst = *p;
    8000186c:	00e78023          	sb	a4,0(a5)
      --max;
    80001870:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001874:	0785                	addi	a5,a5,1
    while(n > 0){
    80001876:	ff0796e3          	bne	a5,a6,80001862 <copyinstr+0x84>
      dst++;
    8000187a:	8b42                	mv	s6,a6
    8000187c:	b775                	j	80001828 <copyinstr+0x4a>
    8000187e:	4781                	li	a5,0
    80001880:	b769                	j	8000180a <copyinstr+0x2c>
      return -1;
    80001882:	557d                	li	a0,-1
    80001884:	b779                	j	80001812 <copyinstr+0x34>
  int got_null = 0;
    80001886:	4781                	li	a5,0
  if(got_null){
    80001888:	0017b793          	seqz	a5,a5
    8000188c:	40f00533          	neg	a0,a5
}
    80001890:	8082                	ret

0000000080001892 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001892:	7139                	addi	sp,sp,-64
    80001894:	fc06                	sd	ra,56(sp)
    80001896:	f822                	sd	s0,48(sp)
    80001898:	f426                	sd	s1,40(sp)
    8000189a:	f04a                	sd	s2,32(sp)
    8000189c:	ec4e                	sd	s3,24(sp)
    8000189e:	e852                	sd	s4,16(sp)
    800018a0:	e456                	sd	s5,8(sp)
    800018a2:	e05a                	sd	s6,0(sp)
    800018a4:	0080                	addi	s0,sp,64
    800018a6:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a8:	00010497          	auipc	s1,0x10
    800018ac:	a6848493          	addi	s1,s1,-1432 # 80011310 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800018b0:	8b26                	mv	s6,s1
    800018b2:	00006a97          	auipc	s5,0x6
    800018b6:	74ea8a93          	addi	s5,s5,1870 # 80008000 <etext>
    800018ba:	04000937          	lui	s2,0x4000
    800018be:	197d                	addi	s2,s2,-1
    800018c0:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018c2:	00015a17          	auipc	s4,0x15
    800018c6:	64ea0a13          	addi	s4,s4,1614 # 80016f10 <tickslock>
    char *pa = kalloc();
    800018ca:	fffff097          	auipc	ra,0xfffff
    800018ce:	258080e7          	jalr	600(ra) # 80000b22 <kalloc>
    800018d2:	862a                	mv	a2,a0
    if(pa == 0)
    800018d4:	c131                	beqz	a0,80001918 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    800018d6:	416485b3          	sub	a1,s1,s6
    800018da:	8591                	srai	a1,a1,0x4
    800018dc:	000ab783          	ld	a5,0(s5)
    800018e0:	02f585b3          	mul	a1,a1,a5
    800018e4:	2585                	addiw	a1,a1,1
    800018e6:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018ea:	4719                	li	a4,6
    800018ec:	6685                	lui	a3,0x1
    800018ee:	40b905b3          	sub	a1,s2,a1
    800018f2:	854e                	mv	a0,s3
    800018f4:	00000097          	auipc	ra,0x0
    800018f8:	8a8080e7          	jalr	-1880(ra) # 8000119c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018fc:	17048493          	addi	s1,s1,368
    80001900:	fd4495e3          	bne	s1,s4,800018ca <proc_mapstacks+0x38>
  }
}
    80001904:	70e2                	ld	ra,56(sp)
    80001906:	7442                	ld	s0,48(sp)
    80001908:	74a2                	ld	s1,40(sp)
    8000190a:	7902                	ld	s2,32(sp)
    8000190c:	69e2                	ld	s3,24(sp)
    8000190e:	6a42                	ld	s4,16(sp)
    80001910:	6aa2                	ld	s5,8(sp)
    80001912:	6b02                	ld	s6,0(sp)
    80001914:	6121                	addi	sp,sp,64
    80001916:	8082                	ret
      panic("kalloc");
    80001918:	00007517          	auipc	a0,0x7
    8000191c:	96850513          	addi	a0,a0,-1688 # 80008280 <digits+0x1e0>
    80001920:	fffff097          	auipc	ra,0xfffff
    80001924:	c4c080e7          	jalr	-948(ra) # 8000056c <panic>

0000000080001928 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001928:	7139                	addi	sp,sp,-64
    8000192a:	fc06                	sd	ra,56(sp)
    8000192c:	f822                	sd	s0,48(sp)
    8000192e:	f426                	sd	s1,40(sp)
    80001930:	f04a                	sd	s2,32(sp)
    80001932:	ec4e                	sd	s3,24(sp)
    80001934:	e852                	sd	s4,16(sp)
    80001936:	e456                	sd	s5,8(sp)
    80001938:	e05a                	sd	s6,0(sp)
    8000193a:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000193c:	00007597          	auipc	a1,0x7
    80001940:	94c58593          	addi	a1,a1,-1716 # 80008288 <digits+0x1e8>
    80001944:	0000f517          	auipc	a0,0xf
    80001948:	59c50513          	addi	a0,a0,1436 # 80010ee0 <pid_lock>
    8000194c:	fffff097          	auipc	ra,0xfffff
    80001950:	236080e7          	jalr	566(ra) # 80000b82 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001954:	00007597          	auipc	a1,0x7
    80001958:	93c58593          	addi	a1,a1,-1732 # 80008290 <digits+0x1f0>
    8000195c:	0000f517          	auipc	a0,0xf
    80001960:	59c50513          	addi	a0,a0,1436 # 80010ef8 <wait_lock>
    80001964:	fffff097          	auipc	ra,0xfffff
    80001968:	21e080e7          	jalr	542(ra) # 80000b82 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000196c:	00010497          	auipc	s1,0x10
    80001970:	9a448493          	addi	s1,s1,-1628 # 80011310 <proc>
      initlock(&p->lock, "proc");
    80001974:	00007b17          	auipc	s6,0x7
    80001978:	92cb0b13          	addi	s6,s6,-1748 # 800082a0 <digits+0x200>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000197c:	8aa6                	mv	s5,s1
    8000197e:	00006a17          	auipc	s4,0x6
    80001982:	682a0a13          	addi	s4,s4,1666 # 80008000 <etext>
    80001986:	04000937          	lui	s2,0x4000
    8000198a:	197d                	addi	s2,s2,-1
    8000198c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000198e:	00015997          	auipc	s3,0x15
    80001992:	58298993          	addi	s3,s3,1410 # 80016f10 <tickslock>
      initlock(&p->lock, "proc");
    80001996:	85da                	mv	a1,s6
    80001998:	00848513          	addi	a0,s1,8
    8000199c:	fffff097          	auipc	ra,0xfffff
    800019a0:	1e6080e7          	jalr	486(ra) # 80000b82 <initlock>
      p->state = UNUSED;
    800019a4:	0204a023          	sw	zero,32(s1)
      p->kstack = KSTACK((int) (p - proc));
    800019a8:	415487b3          	sub	a5,s1,s5
    800019ac:	8791                	srai	a5,a5,0x4
    800019ae:	000a3703          	ld	a4,0(s4)
    800019b2:	02e787b3          	mul	a5,a5,a4
    800019b6:	2785                	addiw	a5,a5,1
    800019b8:	00d7979b          	slliw	a5,a5,0xd
    800019bc:	40f907b3          	sub	a5,s2,a5
    800019c0:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019c2:	17048493          	addi	s1,s1,368
    800019c6:	fd3498e3          	bne	s1,s3,80001996 <procinit+0x6e>
  }
}
    800019ca:	70e2                	ld	ra,56(sp)
    800019cc:	7442                	ld	s0,48(sp)
    800019ce:	74a2                	ld	s1,40(sp)
    800019d0:	7902                	ld	s2,32(sp)
    800019d2:	69e2                	ld	s3,24(sp)
    800019d4:	6a42                	ld	s4,16(sp)
    800019d6:	6aa2                	ld	s5,8(sp)
    800019d8:	6b02                	ld	s6,0(sp)
    800019da:	6121                	addi	sp,sp,64
    800019dc:	8082                	ret

00000000800019de <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019de:	1141                	addi	sp,sp,-16
    800019e0:	e422                	sd	s0,8(sp)
    800019e2:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019e4:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019e6:	2501                	sext.w	a0,a0
    800019e8:	6422                	ld	s0,8(sp)
    800019ea:	0141                	addi	sp,sp,16
    800019ec:	8082                	ret

00000000800019ee <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019ee:	1141                	addi	sp,sp,-16
    800019f0:	e422                	sd	s0,8(sp)
    800019f2:	0800                	addi	s0,sp,16
    800019f4:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019f6:	2781                	sext.w	a5,a5
    800019f8:	079e                	slli	a5,a5,0x7
  return c;
}
    800019fa:	0000f517          	auipc	a0,0xf
    800019fe:	51650513          	addi	a0,a0,1302 # 80010f10 <cpus>
    80001a02:	953e                	add	a0,a0,a5
    80001a04:	6422                	ld	s0,8(sp)
    80001a06:	0141                	addi	sp,sp,16
    80001a08:	8082                	ret

0000000080001a0a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001a0a:	1101                	addi	sp,sp,-32
    80001a0c:	ec06                	sd	ra,24(sp)
    80001a0e:	e822                	sd	s0,16(sp)
    80001a10:	e426                	sd	s1,8(sp)
    80001a12:	1000                	addi	s0,sp,32
  push_off();
    80001a14:	fffff097          	auipc	ra,0xfffff
    80001a18:	1b2080e7          	jalr	434(ra) # 80000bc6 <push_off>
    80001a1c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a1e:	2781                	sext.w	a5,a5
    80001a20:	079e                	slli	a5,a5,0x7
    80001a22:	0000f717          	auipc	a4,0xf
    80001a26:	4be70713          	addi	a4,a4,1214 # 80010ee0 <pid_lock>
    80001a2a:	97ba                	add	a5,a5,a4
    80001a2c:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a2e:	fffff097          	auipc	ra,0xfffff
    80001a32:	238080e7          	jalr	568(ra) # 80000c66 <pop_off>
  return p;
}
    80001a36:	8526                	mv	a0,s1
    80001a38:	60e2                	ld	ra,24(sp)
    80001a3a:	6442                	ld	s0,16(sp)
    80001a3c:	64a2                	ld	s1,8(sp)
    80001a3e:	6105                	addi	sp,sp,32
    80001a40:	8082                	ret

0000000080001a42 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a42:	1141                	addi	sp,sp,-16
    80001a44:	e406                	sd	ra,8(sp)
    80001a46:	e022                	sd	s0,0(sp)
    80001a48:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a4a:	00000097          	auipc	ra,0x0
    80001a4e:	fc0080e7          	jalr	-64(ra) # 80001a0a <myproc>
    80001a52:	0521                	addi	a0,a0,8
    80001a54:	fffff097          	auipc	ra,0xfffff
    80001a58:	272080e7          	jalr	626(ra) # 80000cc6 <release>

  if (first) {
    80001a5c:	00007797          	auipc	a5,0x7
    80001a60:	1747a783          	lw	a5,372(a5) # 80008bd0 <first.1684>
    80001a64:	eb89                	bnez	a5,80001a76 <forkret+0x34>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a66:	00001097          	auipc	ra,0x1
    80001a6a:	d3c080e7          	jalr	-708(ra) # 800027a2 <usertrapret>
}
    80001a6e:	60a2                	ld	ra,8(sp)
    80001a70:	6402                	ld	s0,0(sp)
    80001a72:	0141                	addi	sp,sp,16
    80001a74:	8082                	ret
    first = 0;
    80001a76:	00007797          	auipc	a5,0x7
    80001a7a:	1407ad23          	sw	zero,346(a5) # 80008bd0 <first.1684>
    fsinit(ROOTDEV);
    80001a7e:	4505                	li	a0,1
    80001a80:	00002097          	auipc	ra,0x2
    80001a84:	aee080e7          	jalr	-1298(ra) # 8000356e <fsinit>
    80001a88:	bff9                	j	80001a66 <forkret+0x24>

0000000080001a8a <allocpid>:
{
    80001a8a:	1101                	addi	sp,sp,-32
    80001a8c:	ec06                	sd	ra,24(sp)
    80001a8e:	e822                	sd	s0,16(sp)
    80001a90:	e426                	sd	s1,8(sp)
    80001a92:	e04a                	sd	s2,0(sp)
    80001a94:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a96:	0000f917          	auipc	s2,0xf
    80001a9a:	44a90913          	addi	s2,s2,1098 # 80010ee0 <pid_lock>
    80001a9e:	854a                	mv	a0,s2
    80001aa0:	fffff097          	auipc	ra,0xfffff
    80001aa4:	172080e7          	jalr	370(ra) # 80000c12 <acquire>
  pid = nextpid;
    80001aa8:	00007797          	auipc	a5,0x7
    80001aac:	12c78793          	addi	a5,a5,300 # 80008bd4 <nextpid>
    80001ab0:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ab2:	0014871b          	addiw	a4,s1,1
    80001ab6:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ab8:	854a                	mv	a0,s2
    80001aba:	fffff097          	auipc	ra,0xfffff
    80001abe:	20c080e7          	jalr	524(ra) # 80000cc6 <release>
}
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	60e2                	ld	ra,24(sp)
    80001ac6:	6442                	ld	s0,16(sp)
    80001ac8:	64a2                	ld	s1,8(sp)
    80001aca:	6902                	ld	s2,0(sp)
    80001acc:	6105                	addi	sp,sp,32
    80001ace:	8082                	ret

0000000080001ad0 <proc_pagetable>:
{
    80001ad0:	1101                	addi	sp,sp,-32
    80001ad2:	ec06                	sd	ra,24(sp)
    80001ad4:	e822                	sd	s0,16(sp)
    80001ad6:	e426                	sd	s1,8(sp)
    80001ad8:	e04a                	sd	s2,0(sp)
    80001ada:	1000                	addi	s0,sp,32
    80001adc:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ade:	00000097          	auipc	ra,0x0
    80001ae2:	8a8080e7          	jalr	-1880(ra) # 80001386 <uvmcreate>
    80001ae6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ae8:	c12d                	beqz	a0,80001b4a <proc_pagetable+0x7a>
    80001aea:	8792                	mv	a5,tp
  if(cpuid()==0 && print_flag1==0){
    80001aec:	2781                	sext.w	a5,a5
    80001aee:	e791                	bnez	a5,80001afa <proc_pagetable+0x2a>
    80001af0:	00007797          	auipc	a5,0x7
    80001af4:	17c7a783          	lw	a5,380(a5) # 80008c6c <print_flag1>
    80001af8:	c3a5                	beqz	a5,80001b58 <proc_pagetable+0x88>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001afa:	4729                	li	a4,10
    80001afc:	00005697          	auipc	a3,0x5
    80001b00:	50468693          	addi	a3,a3,1284 # 80007000 <_trampoline>
    80001b04:	6605                	lui	a2,0x1
    80001b06:	040005b7          	lui	a1,0x4000
    80001b0a:	15fd                	addi	a1,a1,-1
    80001b0c:	05b2                	slli	a1,a1,0xc
    80001b0e:	8526                	mv	a0,s1
    80001b10:	fffff097          	auipc	ra,0xfffff
    80001b14:	5ec080e7          	jalr	1516(ra) # 800010fc <mappages>
    80001b18:	06054463          	bltz	a0,80001b80 <proc_pagetable+0xb0>
    80001b1c:	8792                	mv	a5,tp
    if(cpuid()==0 && print_flag2==0){
    80001b1e:	2781                	sext.w	a5,a5
    80001b20:	e791                	bnez	a5,80001b2c <proc_pagetable+0x5c>
    80001b22:	00007797          	auipc	a5,0x7
    80001b26:	1467a783          	lw	a5,326(a5) # 80008c68 <print_flag2>
    80001b2a:	c3bd                	beqz	a5,80001b90 <proc_pagetable+0xc0>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b2c:	4719                	li	a4,6
    80001b2e:	06093683          	ld	a3,96(s2)
    80001b32:	6605                	lui	a2,0x1
    80001b34:	020005b7          	lui	a1,0x2000
    80001b38:	15fd                	addi	a1,a1,-1
    80001b3a:	05b6                	slli	a1,a1,0xd
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	fffff097          	auipc	ra,0xfffff
    80001b42:	5be080e7          	jalr	1470(ra) # 800010fc <mappages>
    80001b46:	06054963          	bltz	a0,80001bb8 <proc_pagetable+0xe8>
}
    80001b4a:	8526                	mv	a0,s1
    80001b4c:	60e2                	ld	ra,24(sp)
    80001b4e:	6442                	ld	s0,16(sp)
    80001b50:	64a2                	ld	s1,8(sp)
    80001b52:	6902                	ld	s2,0(sp)
    80001b54:	6105                	addi	sp,sp,32
    80001b56:	8082                	ret
    printf("%s:%d     [162120120] enter userinit.\n", __FILE__, __LINE__);
    80001b58:	0bb00613          	li	a2,187
    80001b5c:	00006597          	auipc	a1,0x6
    80001b60:	74c58593          	addi	a1,a1,1868 # 800082a8 <digits+0x208>
    80001b64:	00006517          	auipc	a0,0x6
    80001b68:	75450513          	addi	a0,a0,1876 # 800082b8 <digits+0x218>
    80001b6c:	fffff097          	auipc	ra,0xfffff
    80001b70:	a4a080e7          	jalr	-1462(ra) # 800005b6 <printf>
    print_flag1 = 1;
    80001b74:	4785                	li	a5,1
    80001b76:	00007717          	auipc	a4,0x7
    80001b7a:	0ef72b23          	sw	a5,246(a4) # 80008c6c <print_flag1>
    80001b7e:	bfb5                	j	80001afa <proc_pagetable+0x2a>
    uvmfree(pagetable, 0);
    80001b80:	4581                	li	a1,0
    80001b82:	8526                	mv	a0,s1
    80001b84:	00000097          	auipc	ra,0x0
    80001b88:	a06080e7          	jalr	-1530(ra) # 8000158a <uvmfree>
    return 0;
    80001b8c:	4481                	li	s1,0
    80001b8e:	bf75                	j	80001b4a <proc_pagetable+0x7a>
    printf("%s:%d     [162120120] copy initcode to first user process.\n", __FILE__, __LINE__);
    80001b90:	0c800613          	li	a2,200
    80001b94:	00006597          	auipc	a1,0x6
    80001b98:	71458593          	addi	a1,a1,1812 # 800082a8 <digits+0x208>
    80001b9c:	00006517          	auipc	a0,0x6
    80001ba0:	74450513          	addi	a0,a0,1860 # 800082e0 <digits+0x240>
    80001ba4:	fffff097          	auipc	ra,0xfffff
    80001ba8:	a12080e7          	jalr	-1518(ra) # 800005b6 <printf>
    print_flag2 = 1;
    80001bac:	4785                	li	a5,1
    80001bae:	00007717          	auipc	a4,0x7
    80001bb2:	0af72d23          	sw	a5,186(a4) # 80008c68 <print_flag2>
    80001bb6:	bf9d                	j	80001b2c <proc_pagetable+0x5c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bb8:	4681                	li	a3,0
    80001bba:	4605                	li	a2,1
    80001bbc:	040005b7          	lui	a1,0x4000
    80001bc0:	15fd                	addi	a1,a1,-1
    80001bc2:	05b2                	slli	a1,a1,0xc
    80001bc4:	8526                	mv	a0,s1
    80001bc6:	fffff097          	auipc	ra,0xfffff
    80001bca:	6fc080e7          	jalr	1788(ra) # 800012c2 <uvmunmap>
    uvmfree(pagetable, 0);
    80001bce:	4581                	li	a1,0
    80001bd0:	8526                	mv	a0,s1
    80001bd2:	00000097          	auipc	ra,0x0
    80001bd6:	9b8080e7          	jalr	-1608(ra) # 8000158a <uvmfree>
    return 0;
    80001bda:	4481                	li	s1,0
    80001bdc:	b7bd                	j	80001b4a <proc_pagetable+0x7a>

0000000080001bde <proc_freepagetable>:
{
    80001bde:	1101                	addi	sp,sp,-32
    80001be0:	ec06                	sd	ra,24(sp)
    80001be2:	e822                	sd	s0,16(sp)
    80001be4:	e426                	sd	s1,8(sp)
    80001be6:	e04a                	sd	s2,0(sp)
    80001be8:	1000                	addi	s0,sp,32
    80001bea:	84aa                	mv	s1,a0
    80001bec:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bee:	4681                	li	a3,0
    80001bf0:	4605                	li	a2,1
    80001bf2:	040005b7          	lui	a1,0x4000
    80001bf6:	15fd                	addi	a1,a1,-1
    80001bf8:	05b2                	slli	a1,a1,0xc
    80001bfa:	fffff097          	auipc	ra,0xfffff
    80001bfe:	6c8080e7          	jalr	1736(ra) # 800012c2 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c02:	4681                	li	a3,0
    80001c04:	4605                	li	a2,1
    80001c06:	020005b7          	lui	a1,0x2000
    80001c0a:	15fd                	addi	a1,a1,-1
    80001c0c:	05b6                	slli	a1,a1,0xd
    80001c0e:	8526                	mv	a0,s1
    80001c10:	fffff097          	auipc	ra,0xfffff
    80001c14:	6b2080e7          	jalr	1714(ra) # 800012c2 <uvmunmap>
  uvmfree(pagetable, sz);
    80001c18:	85ca                	mv	a1,s2
    80001c1a:	8526                	mv	a0,s1
    80001c1c:	00000097          	auipc	ra,0x0
    80001c20:	96e080e7          	jalr	-1682(ra) # 8000158a <uvmfree>
}
    80001c24:	60e2                	ld	ra,24(sp)
    80001c26:	6442                	ld	s0,16(sp)
    80001c28:	64a2                	ld	s1,8(sp)
    80001c2a:	6902                	ld	s2,0(sp)
    80001c2c:	6105                	addi	sp,sp,32
    80001c2e:	8082                	ret

0000000080001c30 <freeproc>:
{
    80001c30:	1101                	addi	sp,sp,-32
    80001c32:	ec06                	sd	ra,24(sp)
    80001c34:	e822                	sd	s0,16(sp)
    80001c36:	e426                	sd	s1,8(sp)
    80001c38:	1000                	addi	s0,sp,32
    80001c3a:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c3c:	7128                	ld	a0,96(a0)
    80001c3e:	c509                	beqz	a0,80001c48 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c40:	fffff097          	auipc	ra,0xfffff
    80001c44:	de6080e7          	jalr	-538(ra) # 80000a26 <kfree>
  p->trapframe = 0;
    80001c48:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001c4c:	6ca8                	ld	a0,88(s1)
    80001c4e:	c511                	beqz	a0,80001c5a <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c50:	68ac                	ld	a1,80(s1)
    80001c52:	00000097          	auipc	ra,0x0
    80001c56:	f8c080e7          	jalr	-116(ra) # 80001bde <proc_freepagetable>
  p->pagetable = 0;
    80001c5a:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001c5e:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001c62:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001c66:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001c6a:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001c6e:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001c72:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001c76:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001c7a:	0204a023          	sw	zero,32(s1)
}
    80001c7e:	60e2                	ld	ra,24(sp)
    80001c80:	6442                	ld	s0,16(sp)
    80001c82:	64a2                	ld	s1,8(sp)
    80001c84:	6105                	addi	sp,sp,32
    80001c86:	8082                	ret

0000000080001c88 <allocproc>:
{
    80001c88:	7179                	addi	sp,sp,-48
    80001c8a:	f406                	sd	ra,40(sp)
    80001c8c:	f022                	sd	s0,32(sp)
    80001c8e:	ec26                	sd	s1,24(sp)
    80001c90:	e84a                	sd	s2,16(sp)
    80001c92:	e44e                	sd	s3,8(sp)
    80001c94:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c96:	0000f497          	auipc	s1,0xf
    80001c9a:	67a48493          	addi	s1,s1,1658 # 80011310 <proc>
    80001c9e:	00015997          	auipc	s3,0x15
    80001ca2:	27298993          	addi	s3,s3,626 # 80016f10 <tickslock>
    acquire(&p->lock);
    80001ca6:	00848913          	addi	s2,s1,8
    80001caa:	854a                	mv	a0,s2
    80001cac:	fffff097          	auipc	ra,0xfffff
    80001cb0:	f66080e7          	jalr	-154(ra) # 80000c12 <acquire>
    if(p->state == UNUSED) {
    80001cb4:	509c                	lw	a5,32(s1)
    80001cb6:	cf81                	beqz	a5,80001cce <allocproc+0x46>
      release(&p->lock);
    80001cb8:	854a                	mv	a0,s2
    80001cba:	fffff097          	auipc	ra,0xfffff
    80001cbe:	00c080e7          	jalr	12(ra) # 80000cc6 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cc2:	17048493          	addi	s1,s1,368
    80001cc6:	ff3490e3          	bne	s1,s3,80001ca6 <allocproc+0x1e>
  return 0;
    80001cca:	4481                	li	s1,0
    80001ccc:	a889                	j	80001d1e <allocproc+0x96>
  p->pid = allocpid();
    80001cce:	00000097          	auipc	ra,0x0
    80001cd2:	dbc080e7          	jalr	-580(ra) # 80001a8a <allocpid>
    80001cd6:	dc88                	sw	a0,56(s1)
  p->state = USED;
    80001cd8:	4785                	li	a5,1
    80001cda:	d09c                	sw	a5,32(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001cdc:	fffff097          	auipc	ra,0xfffff
    80001ce0:	e46080e7          	jalr	-442(ra) # 80000b22 <kalloc>
    80001ce4:	89aa                	mv	s3,a0
    80001ce6:	f0a8                	sd	a0,96(s1)
    80001ce8:	c139                	beqz	a0,80001d2e <allocproc+0xa6>
  p->pagetable = proc_pagetable(p);
    80001cea:	8526                	mv	a0,s1
    80001cec:	00000097          	auipc	ra,0x0
    80001cf0:	de4080e7          	jalr	-540(ra) # 80001ad0 <proc_pagetable>
    80001cf4:	89aa                	mv	s3,a0
    80001cf6:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001cf8:	c539                	beqz	a0,80001d46 <allocproc+0xbe>
  memset(&p->context, 0, sizeof(p->context));
    80001cfa:	07000613          	li	a2,112
    80001cfe:	4581                	li	a1,0
    80001d00:	06848513          	addi	a0,s1,104
    80001d04:	fffff097          	auipc	ra,0xfffff
    80001d08:	00a080e7          	jalr	10(ra) # 80000d0e <memset>
  p->context.ra = (uint64)forkret;
    80001d0c:	00000797          	auipc	a5,0x0
    80001d10:	d3678793          	addi	a5,a5,-714 # 80001a42 <forkret>
    80001d14:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d16:	64bc                	ld	a5,72(s1)
    80001d18:	6705                	lui	a4,0x1
    80001d1a:	97ba                	add	a5,a5,a4
    80001d1c:	f8bc                	sd	a5,112(s1)
}
    80001d1e:	8526                	mv	a0,s1
    80001d20:	70a2                	ld	ra,40(sp)
    80001d22:	7402                	ld	s0,32(sp)
    80001d24:	64e2                	ld	s1,24(sp)
    80001d26:	6942                	ld	s2,16(sp)
    80001d28:	69a2                	ld	s3,8(sp)
    80001d2a:	6145                	addi	sp,sp,48
    80001d2c:	8082                	ret
    freeproc(p);
    80001d2e:	8526                	mv	a0,s1
    80001d30:	00000097          	auipc	ra,0x0
    80001d34:	f00080e7          	jalr	-256(ra) # 80001c30 <freeproc>
    release(&p->lock);
    80001d38:	854a                	mv	a0,s2
    80001d3a:	fffff097          	auipc	ra,0xfffff
    80001d3e:	f8c080e7          	jalr	-116(ra) # 80000cc6 <release>
    return 0;
    80001d42:	84ce                	mv	s1,s3
    80001d44:	bfe9                	j	80001d1e <allocproc+0x96>
    freeproc(p);
    80001d46:	8526                	mv	a0,s1
    80001d48:	00000097          	auipc	ra,0x0
    80001d4c:	ee8080e7          	jalr	-280(ra) # 80001c30 <freeproc>
    release(&p->lock);
    80001d50:	854a                	mv	a0,s2
    80001d52:	fffff097          	auipc	ra,0xfffff
    80001d56:	f74080e7          	jalr	-140(ra) # 80000cc6 <release>
    return 0;
    80001d5a:	84ce                	mv	s1,s3
    80001d5c:	b7c9                	j	80001d1e <allocproc+0x96>

0000000080001d5e <userinit>:
{
    80001d5e:	1101                	addi	sp,sp,-32
    80001d60:	ec06                	sd	ra,24(sp)
    80001d62:	e822                	sd	s0,16(sp)
    80001d64:	e426                	sd	s1,8(sp)
    80001d66:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d68:	00000097          	auipc	ra,0x0
    80001d6c:	f20080e7          	jalr	-224(ra) # 80001c88 <allocproc>
    80001d70:	84aa                	mv	s1,a0
  initproc = p;
    80001d72:	00007797          	auipc	a5,0x7
    80001d76:	eea7bf23          	sd	a0,-258(a5) # 80008c70 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d7a:	03400613          	li	a2,52
    80001d7e:	00007597          	auipc	a1,0x7
    80001d82:	e6258593          	addi	a1,a1,-414 # 80008be0 <initcode>
    80001d86:	6d28                	ld	a0,88(a0)
    80001d88:	fffff097          	auipc	ra,0xfffff
    80001d8c:	62c080e7          	jalr	1580(ra) # 800013b4 <uvmfirst>
  p->sz = PGSIZE;
    80001d90:	6785                	lui	a5,0x1
    80001d92:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d94:	70b8                	ld	a4,96(s1)
    80001d96:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d9a:	70b8                	ld	a4,96(s1)
    80001d9c:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d9e:	4641                	li	a2,16
    80001da0:	00006597          	auipc	a1,0x6
    80001da4:	58058593          	addi	a1,a1,1408 # 80008320 <digits+0x280>
    80001da8:	16048513          	addi	a0,s1,352
    80001dac:	fffff097          	auipc	ra,0xfffff
    80001db0:	0b4080e7          	jalr	180(ra) # 80000e60 <safestrcpy>
  p->cwd = namei("/");
    80001db4:	00006517          	auipc	a0,0x6
    80001db8:	57c50513          	addi	a0,a0,1404 # 80008330 <digits+0x290>
    80001dbc:	00002097          	auipc	ra,0x2
    80001dc0:	1d4080e7          	jalr	468(ra) # 80003f90 <namei>
    80001dc4:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001dc8:	478d                	li	a5,3
    80001dca:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    80001dcc:	00848513          	addi	a0,s1,8
    80001dd0:	fffff097          	auipc	ra,0xfffff
    80001dd4:	ef6080e7          	jalr	-266(ra) # 80000cc6 <release>
}
    80001dd8:	60e2                	ld	ra,24(sp)
    80001dda:	6442                	ld	s0,16(sp)
    80001ddc:	64a2                	ld	s1,8(sp)
    80001dde:	6105                	addi	sp,sp,32
    80001de0:	8082                	ret

0000000080001de2 <growproc>:
{
    80001de2:	1101                	addi	sp,sp,-32
    80001de4:	ec06                	sd	ra,24(sp)
    80001de6:	e822                	sd	s0,16(sp)
    80001de8:	e426                	sd	s1,8(sp)
    80001dea:	e04a                	sd	s2,0(sp)
    80001dec:	1000                	addi	s0,sp,32
    80001dee:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001df0:	00000097          	auipc	ra,0x0
    80001df4:	c1a080e7          	jalr	-998(ra) # 80001a0a <myproc>
    80001df8:	84aa                	mv	s1,a0
  sz = p->sz;
    80001dfa:	692c                	ld	a1,80(a0)
  if(n > 0){
    80001dfc:	01204c63          	bgtz	s2,80001e14 <growproc+0x32>
  } else if(n < 0){
    80001e00:	02094663          	bltz	s2,80001e2c <growproc+0x4a>
  p->sz = sz;
    80001e04:	e8ac                	sd	a1,80(s1)
  return 0;
    80001e06:	4501                	li	a0,0
}
    80001e08:	60e2                	ld	ra,24(sp)
    80001e0a:	6442                	ld	s0,16(sp)
    80001e0c:	64a2                	ld	s1,8(sp)
    80001e0e:	6902                	ld	s2,0(sp)
    80001e10:	6105                	addi	sp,sp,32
    80001e12:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001e14:	4691                	li	a3,4
    80001e16:	00b90633          	add	a2,s2,a1
    80001e1a:	6d28                	ld	a0,88(a0)
    80001e1c:	fffff097          	auipc	ra,0xfffff
    80001e20:	652080e7          	jalr	1618(ra) # 8000146e <uvmalloc>
    80001e24:	85aa                	mv	a1,a0
    80001e26:	fd79                	bnez	a0,80001e04 <growproc+0x22>
      return -1;
    80001e28:	557d                	li	a0,-1
    80001e2a:	bff9                	j	80001e08 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e2c:	00b90633          	add	a2,s2,a1
    80001e30:	6d28                	ld	a0,88(a0)
    80001e32:	fffff097          	auipc	ra,0xfffff
    80001e36:	5f4080e7          	jalr	1524(ra) # 80001426 <uvmdealloc>
    80001e3a:	85aa                	mv	a1,a0
    80001e3c:	b7e1                	j	80001e04 <growproc+0x22>

0000000080001e3e <fork>:
{
    80001e3e:	7139                	addi	sp,sp,-64
    80001e40:	fc06                	sd	ra,56(sp)
    80001e42:	f822                	sd	s0,48(sp)
    80001e44:	f426                	sd	s1,40(sp)
    80001e46:	f04a                	sd	s2,32(sp)
    80001e48:	ec4e                	sd	s3,24(sp)
    80001e4a:	e852                	sd	s4,16(sp)
    80001e4c:	e456                	sd	s5,8(sp)
    80001e4e:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e50:	00000097          	auipc	ra,0x0
    80001e54:	bba080e7          	jalr	-1094(ra) # 80001a0a <myproc>
    80001e58:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001e5a:	00000097          	auipc	ra,0x0
    80001e5e:	e2e080e7          	jalr	-466(ra) # 80001c88 <allocproc>
    80001e62:	12050363          	beqz	a0,80001f88 <fork+0x14a>
    80001e66:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e68:	05093603          	ld	a2,80(s2)
    80001e6c:	6d2c                	ld	a1,88(a0)
    80001e6e:	05893503          	ld	a0,88(s2)
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	750080e7          	jalr	1872(ra) # 800015c2 <uvmcopy>
    80001e7a:	04054a63          	bltz	a0,80001ece <fork+0x90>
  np->sz = p->sz; 
    80001e7e:	05093783          	ld	a5,80(s2)
    80001e82:	04f9b823          	sd	a5,80(s3)
  np->mask = p->mask;
    80001e86:	00093783          	ld	a5,0(s2)
    80001e8a:	00f9b023          	sd	a5,0(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e8e:	06093683          	ld	a3,96(s2)
    80001e92:	87b6                	mv	a5,a3
    80001e94:	0609b703          	ld	a4,96(s3)
    80001e98:	12068693          	addi	a3,a3,288
    80001e9c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001ea0:	6788                	ld	a0,8(a5)
    80001ea2:	6b8c                	ld	a1,16(a5)
    80001ea4:	6f90                	ld	a2,24(a5)
    80001ea6:	01073023          	sd	a6,0(a4)
    80001eaa:	e708                	sd	a0,8(a4)
    80001eac:	eb0c                	sd	a1,16(a4)
    80001eae:	ef10                	sd	a2,24(a4)
    80001eb0:	02078793          	addi	a5,a5,32
    80001eb4:	02070713          	addi	a4,a4,32
    80001eb8:	fed792e3          	bne	a5,a3,80001e9c <fork+0x5e>
  np->trapframe->a0 = 0;
    80001ebc:	0609b783          	ld	a5,96(s3)
    80001ec0:	0607b823          	sd	zero,112(a5)
    80001ec4:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    80001ec8:	15800a13          	li	s4,344
    80001ecc:	a805                	j	80001efc <fork+0xbe>
    freeproc(np);
    80001ece:	854e                	mv	a0,s3
    80001ed0:	00000097          	auipc	ra,0x0
    80001ed4:	d60080e7          	jalr	-672(ra) # 80001c30 <freeproc>
    release(&np->lock);
    80001ed8:	00898513          	addi	a0,s3,8
    80001edc:	fffff097          	auipc	ra,0xfffff
    80001ee0:	dea080e7          	jalr	-534(ra) # 80000cc6 <release>
    return -1;
    80001ee4:	5afd                	li	s5,-1
    80001ee6:	a079                	j	80001f74 <fork+0x136>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ee8:	00002097          	auipc	ra,0x2
    80001eec:	73e080e7          	jalr	1854(ra) # 80004626 <filedup>
    80001ef0:	009987b3          	add	a5,s3,s1
    80001ef4:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001ef6:	04a1                	addi	s1,s1,8
    80001ef8:	01448763          	beq	s1,s4,80001f06 <fork+0xc8>
    if(p->ofile[i])
    80001efc:	009907b3          	add	a5,s2,s1
    80001f00:	6388                	ld	a0,0(a5)
    80001f02:	f17d                	bnez	a0,80001ee8 <fork+0xaa>
    80001f04:	bfcd                	j	80001ef6 <fork+0xb8>
  np->cwd = idup(p->cwd);
    80001f06:	15893503          	ld	a0,344(s2)
    80001f0a:	00002097          	auipc	ra,0x2
    80001f0e:	8a2080e7          	jalr	-1886(ra) # 800037ac <idup>
    80001f12:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f16:	4641                	li	a2,16
    80001f18:	16090593          	addi	a1,s2,352
    80001f1c:	16098513          	addi	a0,s3,352
    80001f20:	fffff097          	auipc	ra,0xfffff
    80001f24:	f40080e7          	jalr	-192(ra) # 80000e60 <safestrcpy>
  pid = np->pid;
    80001f28:	0389aa83          	lw	s5,56(s3)
  release(&np->lock);
    80001f2c:	00898493          	addi	s1,s3,8
    80001f30:	8526                	mv	a0,s1
    80001f32:	fffff097          	auipc	ra,0xfffff
    80001f36:	d94080e7          	jalr	-620(ra) # 80000cc6 <release>
  acquire(&wait_lock);
    80001f3a:	0000fa17          	auipc	s4,0xf
    80001f3e:	fbea0a13          	addi	s4,s4,-66 # 80010ef8 <wait_lock>
    80001f42:	8552                	mv	a0,s4
    80001f44:	fffff097          	auipc	ra,0xfffff
    80001f48:	cce080e7          	jalr	-818(ra) # 80000c12 <acquire>
  np->parent = p;
    80001f4c:	0529b023          	sd	s2,64(s3)
  release(&wait_lock);
    80001f50:	8552                	mv	a0,s4
    80001f52:	fffff097          	auipc	ra,0xfffff
    80001f56:	d74080e7          	jalr	-652(ra) # 80000cc6 <release>
  acquire(&np->lock);
    80001f5a:	8526                	mv	a0,s1
    80001f5c:	fffff097          	auipc	ra,0xfffff
    80001f60:	cb6080e7          	jalr	-842(ra) # 80000c12 <acquire>
  np->state = RUNNABLE;
    80001f64:	478d                	li	a5,3
    80001f66:	02f9a023          	sw	a5,32(s3)
  release(&np->lock);
    80001f6a:	8526                	mv	a0,s1
    80001f6c:	fffff097          	auipc	ra,0xfffff
    80001f70:	d5a080e7          	jalr	-678(ra) # 80000cc6 <release>
}
    80001f74:	8556                	mv	a0,s5
    80001f76:	70e2                	ld	ra,56(sp)
    80001f78:	7442                	ld	s0,48(sp)
    80001f7a:	74a2                	ld	s1,40(sp)
    80001f7c:	7902                	ld	s2,32(sp)
    80001f7e:	69e2                	ld	s3,24(sp)
    80001f80:	6a42                	ld	s4,16(sp)
    80001f82:	6aa2                	ld	s5,8(sp)
    80001f84:	6121                	addi	sp,sp,64
    80001f86:	8082                	ret
    return -1;
    80001f88:	5afd                	li	s5,-1
    80001f8a:	b7ed                	j	80001f74 <fork+0x136>

0000000080001f8c <scheduler>:
{
    80001f8c:	715d                	addi	sp,sp,-80
    80001f8e:	e486                	sd	ra,72(sp)
    80001f90:	e0a2                	sd	s0,64(sp)
    80001f92:	fc26                	sd	s1,56(sp)
    80001f94:	f84a                	sd	s2,48(sp)
    80001f96:	f44e                	sd	s3,40(sp)
    80001f98:	f052                	sd	s4,32(sp)
    80001f9a:	ec56                	sd	s5,24(sp)
    80001f9c:	e85a                	sd	s6,16(sp)
    80001f9e:	e45e                	sd	s7,8(sp)
    80001fa0:	0880                	addi	s0,sp,80
    80001fa2:	8792                	mv	a5,tp
  int id = r_tp();
    80001fa4:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fa6:	00779b13          	slli	s6,a5,0x7
    80001faa:	0000f717          	auipc	a4,0xf
    80001fae:	f3670713          	addi	a4,a4,-202 # 80010ee0 <pid_lock>
    80001fb2:	975a                	add	a4,a4,s6
    80001fb4:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001fb8:	0000f717          	auipc	a4,0xf
    80001fbc:	f6070713          	addi	a4,a4,-160 # 80010f18 <cpus+0x8>
    80001fc0:	9b3a                	add	s6,s6,a4
      if(p->state == RUNNABLE) {
    80001fc2:	4a0d                	li	s4,3
        p->state = RUNNING;
    80001fc4:	4b91                	li	s7,4
        c->proc = p;
    80001fc6:	079e                	slli	a5,a5,0x7
    80001fc8:	0000fa97          	auipc	s5,0xf
    80001fcc:	f18a8a93          	addi	s5,s5,-232 # 80010ee0 <pid_lock>
    80001fd0:	9abe                	add	s5,s5,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fd2:	00015997          	auipc	s3,0x15
    80001fd6:	f3e98993          	addi	s3,s3,-194 # 80016f10 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fda:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fde:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fe2:	10079073          	csrw	sstatus,a5
    80001fe6:	0000f497          	auipc	s1,0xf
    80001fea:	32a48493          	addi	s1,s1,810 # 80011310 <proc>
    80001fee:	a03d                	j	8000201c <scheduler+0x90>
        p->state = RUNNING;
    80001ff0:	0374a023          	sw	s7,32(s1)
        c->proc = p;
    80001ff4:	029ab823          	sd	s1,48(s5)
        swtch(&c->context, &p->context);
    80001ff8:	06848593          	addi	a1,s1,104
    80001ffc:	855a                	mv	a0,s6
    80001ffe:	00000097          	auipc	ra,0x0
    80002002:	6fa080e7          	jalr	1786(ra) # 800026f8 <swtch>
        c->proc = 0;
    80002006:	020ab823          	sd	zero,48(s5)
      release(&p->lock);
    8000200a:	854a                	mv	a0,s2
    8000200c:	fffff097          	auipc	ra,0xfffff
    80002010:	cba080e7          	jalr	-838(ra) # 80000cc6 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002014:	17048493          	addi	s1,s1,368
    80002018:	fd3481e3          	beq	s1,s3,80001fda <scheduler+0x4e>
      acquire(&p->lock);
    8000201c:	00848913          	addi	s2,s1,8
    80002020:	854a                	mv	a0,s2
    80002022:	fffff097          	auipc	ra,0xfffff
    80002026:	bf0080e7          	jalr	-1040(ra) # 80000c12 <acquire>
      if(p->state == RUNNABLE) {
    8000202a:	509c                	lw	a5,32(s1)
    8000202c:	fd479fe3          	bne	a5,s4,8000200a <scheduler+0x7e>
    80002030:	b7c1                	j	80001ff0 <scheduler+0x64>

0000000080002032 <sched>:
{
    80002032:	7179                	addi	sp,sp,-48
    80002034:	f406                	sd	ra,40(sp)
    80002036:	f022                	sd	s0,32(sp)
    80002038:	ec26                	sd	s1,24(sp)
    8000203a:	e84a                	sd	s2,16(sp)
    8000203c:	e44e                	sd	s3,8(sp)
    8000203e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002040:	00000097          	auipc	ra,0x0
    80002044:	9ca080e7          	jalr	-1590(ra) # 80001a0a <myproc>
    80002048:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000204a:	0521                	addi	a0,a0,8
    8000204c:	fffff097          	auipc	ra,0xfffff
    80002050:	b4c080e7          	jalr	-1204(ra) # 80000b98 <holding>
    80002054:	c93d                	beqz	a0,800020ca <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002056:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002058:	2781                	sext.w	a5,a5
    8000205a:	079e                	slli	a5,a5,0x7
    8000205c:	0000f717          	auipc	a4,0xf
    80002060:	e8470713          	addi	a4,a4,-380 # 80010ee0 <pid_lock>
    80002064:	97ba                	add	a5,a5,a4
    80002066:	0a87a703          	lw	a4,168(a5)
    8000206a:	4785                	li	a5,1
    8000206c:	06f71763          	bne	a4,a5,800020da <sched+0xa8>
  if(p->state == RUNNING)
    80002070:	5098                	lw	a4,32(s1)
    80002072:	4791                	li	a5,4
    80002074:	06f70b63          	beq	a4,a5,800020ea <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002078:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000207c:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000207e:	efb5                	bnez	a5,800020fa <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002080:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002082:	0000f917          	auipc	s2,0xf
    80002086:	e5e90913          	addi	s2,s2,-418 # 80010ee0 <pid_lock>
    8000208a:	2781                	sext.w	a5,a5
    8000208c:	079e                	slli	a5,a5,0x7
    8000208e:	97ca                	add	a5,a5,s2
    80002090:	0ac7a983          	lw	s3,172(a5)
    80002094:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002096:	2781                	sext.w	a5,a5
    80002098:	079e                	slli	a5,a5,0x7
    8000209a:	0000f597          	auipc	a1,0xf
    8000209e:	e7e58593          	addi	a1,a1,-386 # 80010f18 <cpus+0x8>
    800020a2:	95be                	add	a1,a1,a5
    800020a4:	06848513          	addi	a0,s1,104
    800020a8:	00000097          	auipc	ra,0x0
    800020ac:	650080e7          	jalr	1616(ra) # 800026f8 <swtch>
    800020b0:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020b2:	2781                	sext.w	a5,a5
    800020b4:	079e                	slli	a5,a5,0x7
    800020b6:	97ca                	add	a5,a5,s2
    800020b8:	0b37a623          	sw	s3,172(a5)
}
    800020bc:	70a2                	ld	ra,40(sp)
    800020be:	7402                	ld	s0,32(sp)
    800020c0:	64e2                	ld	s1,24(sp)
    800020c2:	6942                	ld	s2,16(sp)
    800020c4:	69a2                	ld	s3,8(sp)
    800020c6:	6145                	addi	sp,sp,48
    800020c8:	8082                	ret
    panic("sched p->lock");
    800020ca:	00006517          	auipc	a0,0x6
    800020ce:	26e50513          	addi	a0,a0,622 # 80008338 <digits+0x298>
    800020d2:	ffffe097          	auipc	ra,0xffffe
    800020d6:	49a080e7          	jalr	1178(ra) # 8000056c <panic>
    panic("sched locks");
    800020da:	00006517          	auipc	a0,0x6
    800020de:	26e50513          	addi	a0,a0,622 # 80008348 <digits+0x2a8>
    800020e2:	ffffe097          	auipc	ra,0xffffe
    800020e6:	48a080e7          	jalr	1162(ra) # 8000056c <panic>
    panic("sched running");
    800020ea:	00006517          	auipc	a0,0x6
    800020ee:	26e50513          	addi	a0,a0,622 # 80008358 <digits+0x2b8>
    800020f2:	ffffe097          	auipc	ra,0xffffe
    800020f6:	47a080e7          	jalr	1146(ra) # 8000056c <panic>
    panic("sched interruptible");
    800020fa:	00006517          	auipc	a0,0x6
    800020fe:	26e50513          	addi	a0,a0,622 # 80008368 <digits+0x2c8>
    80002102:	ffffe097          	auipc	ra,0xffffe
    80002106:	46a080e7          	jalr	1130(ra) # 8000056c <panic>

000000008000210a <yield>:
{
    8000210a:	1101                	addi	sp,sp,-32
    8000210c:	ec06                	sd	ra,24(sp)
    8000210e:	e822                	sd	s0,16(sp)
    80002110:	e426                	sd	s1,8(sp)
    80002112:	e04a                	sd	s2,0(sp)
    80002114:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002116:	00000097          	auipc	ra,0x0
    8000211a:	8f4080e7          	jalr	-1804(ra) # 80001a0a <myproc>
    8000211e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002120:	00850913          	addi	s2,a0,8
    80002124:	854a                	mv	a0,s2
    80002126:	fffff097          	auipc	ra,0xfffff
    8000212a:	aec080e7          	jalr	-1300(ra) # 80000c12 <acquire>
  p->state = RUNNABLE;
    8000212e:	478d                	li	a5,3
    80002130:	d09c                	sw	a5,32(s1)
  uint64 pc = p->trapframe->epc; 
    80002132:	70bc                	ld	a5,96(s1)
  printf("start to yield, user pc %p\n", pc);
    80002134:	6f8c                	ld	a1,24(a5)
    80002136:	00006517          	auipc	a0,0x6
    8000213a:	24a50513          	addi	a0,a0,586 # 80008380 <digits+0x2e0>
    8000213e:	ffffe097          	auipc	ra,0xffffe
    80002142:	478080e7          	jalr	1144(ra) # 800005b6 <printf>
  sched();
    80002146:	00000097          	auipc	ra,0x0
    8000214a:	eec080e7          	jalr	-276(ra) # 80002032 <sched>
  release(&p->lock);
    8000214e:	854a                	mv	a0,s2
    80002150:	fffff097          	auipc	ra,0xfffff
    80002154:	b76080e7          	jalr	-1162(ra) # 80000cc6 <release>
}
    80002158:	60e2                	ld	ra,24(sp)
    8000215a:	6442                	ld	s0,16(sp)
    8000215c:	64a2                	ld	s1,8(sp)
    8000215e:	6902                	ld	s2,0(sp)
    80002160:	6105                	addi	sp,sp,32
    80002162:	8082                	ret

0000000080002164 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002164:	7179                	addi	sp,sp,-48
    80002166:	f406                	sd	ra,40(sp)
    80002168:	f022                	sd	s0,32(sp)
    8000216a:	ec26                	sd	s1,24(sp)
    8000216c:	e84a                	sd	s2,16(sp)
    8000216e:	e44e                	sd	s3,8(sp)
    80002170:	e052                	sd	s4,0(sp)
    80002172:	1800                	addi	s0,sp,48
    80002174:	89aa                	mv	s3,a0
    80002176:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002178:	00000097          	auipc	ra,0x0
    8000217c:	892080e7          	jalr	-1902(ra) # 80001a0a <myproc>
    80002180:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002182:	00850a13          	addi	s4,a0,8
    80002186:	8552                	mv	a0,s4
    80002188:	fffff097          	auipc	ra,0xfffff
    8000218c:	a8a080e7          	jalr	-1398(ra) # 80000c12 <acquire>
  release(lk);
    80002190:	854a                	mv	a0,s2
    80002192:	fffff097          	auipc	ra,0xfffff
    80002196:	b34080e7          	jalr	-1228(ra) # 80000cc6 <release>

  // Go to sleep.
  p->chan = chan;
    8000219a:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    8000219e:	4789                	li	a5,2
    800021a0:	d09c                	sw	a5,32(s1)

  sched();
    800021a2:	00000097          	auipc	ra,0x0
    800021a6:	e90080e7          	jalr	-368(ra) # 80002032 <sched>

  // Tidy up.
  p->chan = 0;
    800021aa:	0204b423          	sd	zero,40(s1)

  // Reacquire original lock.
  release(&p->lock);
    800021ae:	8552                	mv	a0,s4
    800021b0:	fffff097          	auipc	ra,0xfffff
    800021b4:	b16080e7          	jalr	-1258(ra) # 80000cc6 <release>
  acquire(lk);
    800021b8:	854a                	mv	a0,s2
    800021ba:	fffff097          	auipc	ra,0xfffff
    800021be:	a58080e7          	jalr	-1448(ra) # 80000c12 <acquire>
}
    800021c2:	70a2                	ld	ra,40(sp)
    800021c4:	7402                	ld	s0,32(sp)
    800021c6:	64e2                	ld	s1,24(sp)
    800021c8:	6942                	ld	s2,16(sp)
    800021ca:	69a2                	ld	s3,8(sp)
    800021cc:	6a02                	ld	s4,0(sp)
    800021ce:	6145                	addi	sp,sp,48
    800021d0:	8082                	ret

00000000800021d2 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800021d2:	7139                	addi	sp,sp,-64
    800021d4:	fc06                	sd	ra,56(sp)
    800021d6:	f822                	sd	s0,48(sp)
    800021d8:	f426                	sd	s1,40(sp)
    800021da:	f04a                	sd	s2,32(sp)
    800021dc:	ec4e                	sd	s3,24(sp)
    800021de:	e852                	sd	s4,16(sp)
    800021e0:	e456                	sd	s5,8(sp)
    800021e2:	e05a                	sd	s6,0(sp)
    800021e4:	0080                	addi	s0,sp,64
    800021e6:	8aaa                	mv	s5,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800021e8:	0000f497          	auipc	s1,0xf
    800021ec:	12848493          	addi	s1,s1,296 # 80011310 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800021f0:	4a09                	li	s4,2
        p->state = RUNNABLE;
    800021f2:	4b0d                	li	s6,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800021f4:	00015997          	auipc	s3,0x15
    800021f8:	d1c98993          	addi	s3,s3,-740 # 80016f10 <tickslock>
    800021fc:	a821                	j	80002214 <wakeup+0x42>
        p->state = RUNNABLE;
    800021fe:	0364a023          	sw	s6,32(s1)
      }
      release(&p->lock);
    80002202:	854a                	mv	a0,s2
    80002204:	fffff097          	auipc	ra,0xfffff
    80002208:	ac2080e7          	jalr	-1342(ra) # 80000cc6 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000220c:	17048493          	addi	s1,s1,368
    80002210:	03348663          	beq	s1,s3,8000223c <wakeup+0x6a>
    if(p != myproc()){
    80002214:	fffff097          	auipc	ra,0xfffff
    80002218:	7f6080e7          	jalr	2038(ra) # 80001a0a <myproc>
    8000221c:	fea488e3          	beq	s1,a0,8000220c <wakeup+0x3a>
      acquire(&p->lock);
    80002220:	00848913          	addi	s2,s1,8
    80002224:	854a                	mv	a0,s2
    80002226:	fffff097          	auipc	ra,0xfffff
    8000222a:	9ec080e7          	jalr	-1556(ra) # 80000c12 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000222e:	509c                	lw	a5,32(s1)
    80002230:	fd4799e3          	bne	a5,s4,80002202 <wakeup+0x30>
    80002234:	749c                	ld	a5,40(s1)
    80002236:	fd5796e3          	bne	a5,s5,80002202 <wakeup+0x30>
    8000223a:	b7d1                	j	800021fe <wakeup+0x2c>
    }
  }
}
    8000223c:	70e2                	ld	ra,56(sp)
    8000223e:	7442                	ld	s0,48(sp)
    80002240:	74a2                	ld	s1,40(sp)
    80002242:	7902                	ld	s2,32(sp)
    80002244:	69e2                	ld	s3,24(sp)
    80002246:	6a42                	ld	s4,16(sp)
    80002248:	6aa2                	ld	s5,8(sp)
    8000224a:	6b02                	ld	s6,0(sp)
    8000224c:	6121                	addi	sp,sp,64
    8000224e:	8082                	ret

0000000080002250 <reparent>:
{
    80002250:	7179                	addi	sp,sp,-48
    80002252:	f406                	sd	ra,40(sp)
    80002254:	f022                	sd	s0,32(sp)
    80002256:	ec26                	sd	s1,24(sp)
    80002258:	e84a                	sd	s2,16(sp)
    8000225a:	e44e                	sd	s3,8(sp)
    8000225c:	e052                	sd	s4,0(sp)
    8000225e:	1800                	addi	s0,sp,48
    80002260:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002262:	0000f497          	auipc	s1,0xf
    80002266:	0ae48493          	addi	s1,s1,174 # 80011310 <proc>
      pp->parent = initproc;
    8000226a:	00007a17          	auipc	s4,0x7
    8000226e:	a06a0a13          	addi	s4,s4,-1530 # 80008c70 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002272:	00015997          	auipc	s3,0x15
    80002276:	c9e98993          	addi	s3,s3,-866 # 80016f10 <tickslock>
    8000227a:	a029                	j	80002284 <reparent+0x34>
    8000227c:	17048493          	addi	s1,s1,368
    80002280:	01348d63          	beq	s1,s3,8000229a <reparent+0x4a>
    if(pp->parent == p){
    80002284:	60bc                	ld	a5,64(s1)
    80002286:	ff279be3          	bne	a5,s2,8000227c <reparent+0x2c>
      pp->parent = initproc;
    8000228a:	000a3503          	ld	a0,0(s4)
    8000228e:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    80002290:	00000097          	auipc	ra,0x0
    80002294:	f42080e7          	jalr	-190(ra) # 800021d2 <wakeup>
    80002298:	b7d5                	j	8000227c <reparent+0x2c>
}
    8000229a:	70a2                	ld	ra,40(sp)
    8000229c:	7402                	ld	s0,32(sp)
    8000229e:	64e2                	ld	s1,24(sp)
    800022a0:	6942                	ld	s2,16(sp)
    800022a2:	69a2                	ld	s3,8(sp)
    800022a4:	6a02                	ld	s4,0(sp)
    800022a6:	6145                	addi	sp,sp,48
    800022a8:	8082                	ret

00000000800022aa <exit>:
{
    800022aa:	7179                	addi	sp,sp,-48
    800022ac:	f406                	sd	ra,40(sp)
    800022ae:	f022                	sd	s0,32(sp)
    800022b0:	ec26                	sd	s1,24(sp)
    800022b2:	e84a                	sd	s2,16(sp)
    800022b4:	e44e                	sd	s3,8(sp)
    800022b6:	e052                	sd	s4,0(sp)
    800022b8:	1800                	addi	s0,sp,48
    800022ba:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022bc:	fffff097          	auipc	ra,0xfffff
    800022c0:	74e080e7          	jalr	1870(ra) # 80001a0a <myproc>
    800022c4:	89aa                	mv	s3,a0
  if(p == initproc)
    800022c6:	00007797          	auipc	a5,0x7
    800022ca:	9aa7b783          	ld	a5,-1622(a5) # 80008c70 <initproc>
    800022ce:	0d850493          	addi	s1,a0,216
    800022d2:	15850913          	addi	s2,a0,344
    800022d6:	02a79363          	bne	a5,a0,800022fc <exit+0x52>
    panic("init exiting");
    800022da:	00006517          	auipc	a0,0x6
    800022de:	0c650513          	addi	a0,a0,198 # 800083a0 <digits+0x300>
    800022e2:	ffffe097          	auipc	ra,0xffffe
    800022e6:	28a080e7          	jalr	650(ra) # 8000056c <panic>
      fileclose(f);
    800022ea:	00002097          	auipc	ra,0x2
    800022ee:	38e080e7          	jalr	910(ra) # 80004678 <fileclose>
      p->ofile[fd] = 0;
    800022f2:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800022f6:	04a1                	addi	s1,s1,8
    800022f8:	01248563          	beq	s1,s2,80002302 <exit+0x58>
    if(p->ofile[fd]){
    800022fc:	6088                	ld	a0,0(s1)
    800022fe:	f575                	bnez	a0,800022ea <exit+0x40>
    80002300:	bfdd                	j	800022f6 <exit+0x4c>
  begin_op();
    80002302:	00002097          	auipc	ra,0x2
    80002306:	eaa080e7          	jalr	-342(ra) # 800041ac <begin_op>
  iput(p->cwd);
    8000230a:	1589b503          	ld	a0,344(s3)
    8000230e:	00001097          	auipc	ra,0x1
    80002312:	696080e7          	jalr	1686(ra) # 800039a4 <iput>
  end_op();
    80002316:	00002097          	auipc	ra,0x2
    8000231a:	f16080e7          	jalr	-234(ra) # 8000422c <end_op>
  p->cwd = 0;
    8000231e:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    80002322:	0000f497          	auipc	s1,0xf
    80002326:	bd648493          	addi	s1,s1,-1066 # 80010ef8 <wait_lock>
    8000232a:	8526                	mv	a0,s1
    8000232c:	fffff097          	auipc	ra,0xfffff
    80002330:	8e6080e7          	jalr	-1818(ra) # 80000c12 <acquire>
  reparent(p);
    80002334:	854e                	mv	a0,s3
    80002336:	00000097          	auipc	ra,0x0
    8000233a:	f1a080e7          	jalr	-230(ra) # 80002250 <reparent>
  wakeup(p->parent);
    8000233e:	0409b503          	ld	a0,64(s3)
    80002342:	00000097          	auipc	ra,0x0
    80002346:	e90080e7          	jalr	-368(ra) # 800021d2 <wakeup>
  acquire(&p->lock);
    8000234a:	00898513          	addi	a0,s3,8
    8000234e:	fffff097          	auipc	ra,0xfffff
    80002352:	8c4080e7          	jalr	-1852(ra) # 80000c12 <acquire>
  p->xstate = status;
    80002356:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    8000235a:	4795                	li	a5,5
    8000235c:	02f9a023          	sw	a5,32(s3)
  release(&wait_lock);
    80002360:	8526                	mv	a0,s1
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	964080e7          	jalr	-1692(ra) # 80000cc6 <release>
  sched();
    8000236a:	00000097          	auipc	ra,0x0
    8000236e:	cc8080e7          	jalr	-824(ra) # 80002032 <sched>
  panic("zombie exit");
    80002372:	00006517          	auipc	a0,0x6
    80002376:	03e50513          	addi	a0,a0,62 # 800083b0 <digits+0x310>
    8000237a:	ffffe097          	auipc	ra,0xffffe
    8000237e:	1f2080e7          	jalr	498(ra) # 8000056c <panic>

0000000080002382 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002382:	7179                	addi	sp,sp,-48
    80002384:	f406                	sd	ra,40(sp)
    80002386:	f022                	sd	s0,32(sp)
    80002388:	ec26                	sd	s1,24(sp)
    8000238a:	e84a                	sd	s2,16(sp)
    8000238c:	e44e                	sd	s3,8(sp)
    8000238e:	e052                	sd	s4,0(sp)
    80002390:	1800                	addi	s0,sp,48
    80002392:	89aa                	mv	s3,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002394:	0000f497          	auipc	s1,0xf
    80002398:	f7c48493          	addi	s1,s1,-132 # 80011310 <proc>
    8000239c:	00015a17          	auipc	s4,0x15
    800023a0:	b74a0a13          	addi	s4,s4,-1164 # 80016f10 <tickslock>
    acquire(&p->lock);
    800023a4:	00848913          	addi	s2,s1,8
    800023a8:	854a                	mv	a0,s2
    800023aa:	fffff097          	auipc	ra,0xfffff
    800023ae:	868080e7          	jalr	-1944(ra) # 80000c12 <acquire>
    if(p->pid == pid){
    800023b2:	5c9c                	lw	a5,56(s1)
    800023b4:	01378d63          	beq	a5,s3,800023ce <kill+0x4c>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800023b8:	854a                	mv	a0,s2
    800023ba:	fffff097          	auipc	ra,0xfffff
    800023be:	90c080e7          	jalr	-1780(ra) # 80000cc6 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023c2:	17048493          	addi	s1,s1,368
    800023c6:	fd449fe3          	bne	s1,s4,800023a4 <kill+0x22>
  }
  return -1;
    800023ca:	557d                	li	a0,-1
    800023cc:	a829                	j	800023e6 <kill+0x64>
      p->killed = 1;
    800023ce:	4785                	li	a5,1
    800023d0:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    800023d2:	5098                	lw	a4,32(s1)
    800023d4:	4789                	li	a5,2
    800023d6:	02f70063          	beq	a4,a5,800023f6 <kill+0x74>
      release(&p->lock);
    800023da:	854a                	mv	a0,s2
    800023dc:	fffff097          	auipc	ra,0xfffff
    800023e0:	8ea080e7          	jalr	-1814(ra) # 80000cc6 <release>
      return 0;
    800023e4:	4501                	li	a0,0
}
    800023e6:	70a2                	ld	ra,40(sp)
    800023e8:	7402                	ld	s0,32(sp)
    800023ea:	64e2                	ld	s1,24(sp)
    800023ec:	6942                	ld	s2,16(sp)
    800023ee:	69a2                	ld	s3,8(sp)
    800023f0:	6a02                	ld	s4,0(sp)
    800023f2:	6145                	addi	sp,sp,48
    800023f4:	8082                	ret
        p->state = RUNNABLE;
    800023f6:	478d                	li	a5,3
    800023f8:	d09c                	sw	a5,32(s1)
    800023fa:	b7c5                	j	800023da <kill+0x58>

00000000800023fc <setkilled>:

void
setkilled(struct proc *p)
{
    800023fc:	1101                	addi	sp,sp,-32
    800023fe:	ec06                	sd	ra,24(sp)
    80002400:	e822                	sd	s0,16(sp)
    80002402:	e426                	sd	s1,8(sp)
    80002404:	e04a                	sd	s2,0(sp)
    80002406:	1000                	addi	s0,sp,32
    80002408:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000240a:	00850913          	addi	s2,a0,8
    8000240e:	854a                	mv	a0,s2
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	802080e7          	jalr	-2046(ra) # 80000c12 <acquire>
  p->killed = 1;
    80002418:	4785                	li	a5,1
    8000241a:	d89c                	sw	a5,48(s1)
  release(&p->lock);
    8000241c:	854a                	mv	a0,s2
    8000241e:	fffff097          	auipc	ra,0xfffff
    80002422:	8a8080e7          	jalr	-1880(ra) # 80000cc6 <release>
}
    80002426:	60e2                	ld	ra,24(sp)
    80002428:	6442                	ld	s0,16(sp)
    8000242a:	64a2                	ld	s1,8(sp)
    8000242c:	6902                	ld	s2,0(sp)
    8000242e:	6105                	addi	sp,sp,32
    80002430:	8082                	ret

0000000080002432 <killed>:

int
killed(struct proc *p)
{
    80002432:	1101                	addi	sp,sp,-32
    80002434:	ec06                	sd	ra,24(sp)
    80002436:	e822                	sd	s0,16(sp)
    80002438:	e426                	sd	s1,8(sp)
    8000243a:	e04a                	sd	s2,0(sp)
    8000243c:	1000                	addi	s0,sp,32
    8000243e:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002440:	00850913          	addi	s2,a0,8
    80002444:	854a                	mv	a0,s2
    80002446:	ffffe097          	auipc	ra,0xffffe
    8000244a:	7cc080e7          	jalr	1996(ra) # 80000c12 <acquire>
  k = p->killed;
    8000244e:	5884                	lw	s1,48(s1)
  release(&p->lock);
    80002450:	854a                	mv	a0,s2
    80002452:	fffff097          	auipc	ra,0xfffff
    80002456:	874080e7          	jalr	-1932(ra) # 80000cc6 <release>
  return k;
}
    8000245a:	8526                	mv	a0,s1
    8000245c:	60e2                	ld	ra,24(sp)
    8000245e:	6442                	ld	s0,16(sp)
    80002460:	64a2                	ld	s1,8(sp)
    80002462:	6902                	ld	s2,0(sp)
    80002464:	6105                	addi	sp,sp,32
    80002466:	8082                	ret

0000000080002468 <wait>:
{
    80002468:	711d                	addi	sp,sp,-96
    8000246a:	ec86                	sd	ra,88(sp)
    8000246c:	e8a2                	sd	s0,80(sp)
    8000246e:	e4a6                	sd	s1,72(sp)
    80002470:	e0ca                	sd	s2,64(sp)
    80002472:	fc4e                	sd	s3,56(sp)
    80002474:	f852                	sd	s4,48(sp)
    80002476:	f456                	sd	s5,40(sp)
    80002478:	f05a                	sd	s6,32(sp)
    8000247a:	ec5e                	sd	s7,24(sp)
    8000247c:	e862                	sd	s8,16(sp)
    8000247e:	e466                	sd	s9,8(sp)
    80002480:	1080                	addi	s0,sp,96
    80002482:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002484:	fffff097          	auipc	ra,0xfffff
    80002488:	586080e7          	jalr	1414(ra) # 80001a0a <myproc>
    8000248c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000248e:	0000f517          	auipc	a0,0xf
    80002492:	a6a50513          	addi	a0,a0,-1430 # 80010ef8 <wait_lock>
    80002496:	ffffe097          	auipc	ra,0xffffe
    8000249a:	77c080e7          	jalr	1916(ra) # 80000c12 <acquire>
    havekids = 0;
    8000249e:	4c01                	li	s8,0
        if(pp->state == ZOMBIE){
    800024a0:	4a95                	li	s5,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024a2:	00015997          	auipc	s3,0x15
    800024a6:	a6e98993          	addi	s3,s3,-1426 # 80016f10 <tickslock>
        havekids = 1;
    800024aa:	4b05                	li	s6,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024ac:	0000fc97          	auipc	s9,0xf
    800024b0:	a4cc8c93          	addi	s9,s9,-1460 # 80010ef8 <wait_lock>
    havekids = 0;
    800024b4:	8762                	mv	a4,s8
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024b6:	0000f497          	auipc	s1,0xf
    800024ba:	e5a48493          	addi	s1,s1,-422 # 80011310 <proc>
    800024be:	a0bd                	j	8000252c <wait+0xc4>
          pid = pp->pid;
    800024c0:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800024c4:	000b8e63          	beqz	s7,800024e0 <wait+0x78>
    800024c8:	4691                	li	a3,4
    800024ca:	03448613          	addi	a2,s1,52
    800024ce:	85de                	mv	a1,s7
    800024d0:	05893503          	ld	a0,88(s2)
    800024d4:	fffff097          	auipc	ra,0xfffff
    800024d8:	1f2080e7          	jalr	498(ra) # 800016c6 <copyout>
    800024dc:	02054563          	bltz	a0,80002506 <wait+0x9e>
          freeproc(pp);
    800024e0:	8526                	mv	a0,s1
    800024e2:	fffff097          	auipc	ra,0xfffff
    800024e6:	74e080e7          	jalr	1870(ra) # 80001c30 <freeproc>
          release(&pp->lock);
    800024ea:	8552                	mv	a0,s4
    800024ec:	ffffe097          	auipc	ra,0xffffe
    800024f0:	7da080e7          	jalr	2010(ra) # 80000cc6 <release>
          release(&wait_lock);
    800024f4:	0000f517          	auipc	a0,0xf
    800024f8:	a0450513          	addi	a0,a0,-1532 # 80010ef8 <wait_lock>
    800024fc:	ffffe097          	auipc	ra,0xffffe
    80002500:	7ca080e7          	jalr	1994(ra) # 80000cc6 <release>
          return pid;
    80002504:	a885                	j	80002574 <wait+0x10c>
            release(&pp->lock);
    80002506:	8552                	mv	a0,s4
    80002508:	ffffe097          	auipc	ra,0xffffe
    8000250c:	7be080e7          	jalr	1982(ra) # 80000cc6 <release>
            release(&wait_lock);
    80002510:	0000f517          	auipc	a0,0xf
    80002514:	9e850513          	addi	a0,a0,-1560 # 80010ef8 <wait_lock>
    80002518:	ffffe097          	auipc	ra,0xffffe
    8000251c:	7ae080e7          	jalr	1966(ra) # 80000cc6 <release>
            return -1;
    80002520:	59fd                	li	s3,-1
    80002522:	a889                	j	80002574 <wait+0x10c>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002524:	17048493          	addi	s1,s1,368
    80002528:	03348663          	beq	s1,s3,80002554 <wait+0xec>
      if(pp->parent == p){
    8000252c:	60bc                	ld	a5,64(s1)
    8000252e:	ff279be3          	bne	a5,s2,80002524 <wait+0xbc>
        acquire(&pp->lock);
    80002532:	00848a13          	addi	s4,s1,8
    80002536:	8552                	mv	a0,s4
    80002538:	ffffe097          	auipc	ra,0xffffe
    8000253c:	6da080e7          	jalr	1754(ra) # 80000c12 <acquire>
        if(pp->state == ZOMBIE){
    80002540:	509c                	lw	a5,32(s1)
    80002542:	f7578fe3          	beq	a5,s5,800024c0 <wait+0x58>
        release(&pp->lock);
    80002546:	8552                	mv	a0,s4
    80002548:	ffffe097          	auipc	ra,0xffffe
    8000254c:	77e080e7          	jalr	1918(ra) # 80000cc6 <release>
        havekids = 1;
    80002550:	875a                	mv	a4,s6
    80002552:	bfc9                	j	80002524 <wait+0xbc>
    if(!havekids || killed(p)){
    80002554:	c719                	beqz	a4,80002562 <wait+0xfa>
    80002556:	854a                	mv	a0,s2
    80002558:	00000097          	auipc	ra,0x0
    8000255c:	eda080e7          	jalr	-294(ra) # 80002432 <killed>
    80002560:	c905                	beqz	a0,80002590 <wait+0x128>
      release(&wait_lock);
    80002562:	0000f517          	auipc	a0,0xf
    80002566:	99650513          	addi	a0,a0,-1642 # 80010ef8 <wait_lock>
    8000256a:	ffffe097          	auipc	ra,0xffffe
    8000256e:	75c080e7          	jalr	1884(ra) # 80000cc6 <release>
      return -1;
    80002572:	59fd                	li	s3,-1
}
    80002574:	854e                	mv	a0,s3
    80002576:	60e6                	ld	ra,88(sp)
    80002578:	6446                	ld	s0,80(sp)
    8000257a:	64a6                	ld	s1,72(sp)
    8000257c:	6906                	ld	s2,64(sp)
    8000257e:	79e2                	ld	s3,56(sp)
    80002580:	7a42                	ld	s4,48(sp)
    80002582:	7aa2                	ld	s5,40(sp)
    80002584:	7b02                	ld	s6,32(sp)
    80002586:	6be2                	ld	s7,24(sp)
    80002588:	6c42                	ld	s8,16(sp)
    8000258a:	6ca2                	ld	s9,8(sp)
    8000258c:	6125                	addi	sp,sp,96
    8000258e:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002590:	85e6                	mv	a1,s9
    80002592:	854a                	mv	a0,s2
    80002594:	00000097          	auipc	ra,0x0
    80002598:	bd0080e7          	jalr	-1072(ra) # 80002164 <sleep>
    havekids = 0;
    8000259c:	bf21                	j	800024b4 <wait+0x4c>

000000008000259e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000259e:	7179                	addi	sp,sp,-48
    800025a0:	f406                	sd	ra,40(sp)
    800025a2:	f022                	sd	s0,32(sp)
    800025a4:	ec26                	sd	s1,24(sp)
    800025a6:	e84a                	sd	s2,16(sp)
    800025a8:	e44e                	sd	s3,8(sp)
    800025aa:	e052                	sd	s4,0(sp)
    800025ac:	1800                	addi	s0,sp,48
    800025ae:	84aa                	mv	s1,a0
    800025b0:	892e                	mv	s2,a1
    800025b2:	89b2                	mv	s3,a2
    800025b4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025b6:	fffff097          	auipc	ra,0xfffff
    800025ba:	454080e7          	jalr	1108(ra) # 80001a0a <myproc>
  if(user_dst){
    800025be:	c08d                	beqz	s1,800025e0 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800025c0:	86d2                	mv	a3,s4
    800025c2:	864e                	mv	a2,s3
    800025c4:	85ca                	mv	a1,s2
    800025c6:	6d28                	ld	a0,88(a0)
    800025c8:	fffff097          	auipc	ra,0xfffff
    800025cc:	0fe080e7          	jalr	254(ra) # 800016c6 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025d0:	70a2                	ld	ra,40(sp)
    800025d2:	7402                	ld	s0,32(sp)
    800025d4:	64e2                	ld	s1,24(sp)
    800025d6:	6942                	ld	s2,16(sp)
    800025d8:	69a2                	ld	s3,8(sp)
    800025da:	6a02                	ld	s4,0(sp)
    800025dc:	6145                	addi	sp,sp,48
    800025de:	8082                	ret
    memmove((char *)dst, src, len);
    800025e0:	000a061b          	sext.w	a2,s4
    800025e4:	85ce                	mv	a1,s3
    800025e6:	854a                	mv	a0,s2
    800025e8:	ffffe097          	auipc	ra,0xffffe
    800025ec:	786080e7          	jalr	1926(ra) # 80000d6e <memmove>
    return 0;
    800025f0:	8526                	mv	a0,s1
    800025f2:	bff9                	j	800025d0 <either_copyout+0x32>

00000000800025f4 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025f4:	7179                	addi	sp,sp,-48
    800025f6:	f406                	sd	ra,40(sp)
    800025f8:	f022                	sd	s0,32(sp)
    800025fa:	ec26                	sd	s1,24(sp)
    800025fc:	e84a                	sd	s2,16(sp)
    800025fe:	e44e                	sd	s3,8(sp)
    80002600:	e052                	sd	s4,0(sp)
    80002602:	1800                	addi	s0,sp,48
    80002604:	892a                	mv	s2,a0
    80002606:	84ae                	mv	s1,a1
    80002608:	89b2                	mv	s3,a2
    8000260a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000260c:	fffff097          	auipc	ra,0xfffff
    80002610:	3fe080e7          	jalr	1022(ra) # 80001a0a <myproc>
  if(user_src){
    80002614:	c08d                	beqz	s1,80002636 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002616:	86d2                	mv	a3,s4
    80002618:	864e                	mv	a2,s3
    8000261a:	85ca                	mv	a1,s2
    8000261c:	6d28                	ld	a0,88(a0)
    8000261e:	fffff097          	auipc	ra,0xfffff
    80002622:	134080e7          	jalr	308(ra) # 80001752 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002626:	70a2                	ld	ra,40(sp)
    80002628:	7402                	ld	s0,32(sp)
    8000262a:	64e2                	ld	s1,24(sp)
    8000262c:	6942                	ld	s2,16(sp)
    8000262e:	69a2                	ld	s3,8(sp)
    80002630:	6a02                	ld	s4,0(sp)
    80002632:	6145                	addi	sp,sp,48
    80002634:	8082                	ret
    memmove(dst, (char*)src, len);
    80002636:	000a061b          	sext.w	a2,s4
    8000263a:	85ce                	mv	a1,s3
    8000263c:	854a                	mv	a0,s2
    8000263e:	ffffe097          	auipc	ra,0xffffe
    80002642:	730080e7          	jalr	1840(ra) # 80000d6e <memmove>
    return 0;
    80002646:	8526                	mv	a0,s1
    80002648:	bff9                	j	80002626 <either_copyin+0x32>

000000008000264a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000264a:	715d                	addi	sp,sp,-80
    8000264c:	e486                	sd	ra,72(sp)
    8000264e:	e0a2                	sd	s0,64(sp)
    80002650:	fc26                	sd	s1,56(sp)
    80002652:	f84a                	sd	s2,48(sp)
    80002654:	f44e                	sd	s3,40(sp)
    80002656:	f052                	sd	s4,32(sp)
    80002658:	ec56                	sd	s5,24(sp)
    8000265a:	e85a                	sd	s6,16(sp)
    8000265c:	e45e                	sd	s7,8(sp)
    8000265e:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002660:	00006517          	auipc	a0,0x6
    80002664:	a0850513          	addi	a0,a0,-1528 # 80008068 <etext+0x68>
    80002668:	ffffe097          	auipc	ra,0xffffe
    8000266c:	f4e080e7          	jalr	-178(ra) # 800005b6 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002670:	0000f497          	auipc	s1,0xf
    80002674:	e0048493          	addi	s1,s1,-512 # 80011470 <proc+0x160>
    80002678:	00015917          	auipc	s2,0x15
    8000267c:	9f890913          	addi	s2,s2,-1544 # 80017070 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002680:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002682:	00006997          	auipc	s3,0x6
    80002686:	d3e98993          	addi	s3,s3,-706 # 800083c0 <digits+0x320>
    printf("%d %s %s", p->pid, state, p->name);
    8000268a:	00006a97          	auipc	s5,0x6
    8000268e:	d3ea8a93          	addi	s5,s5,-706 # 800083c8 <digits+0x328>
    printf("\n");
    80002692:	00006a17          	auipc	s4,0x6
    80002696:	9d6a0a13          	addi	s4,s4,-1578 # 80008068 <etext+0x68>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000269a:	00006b97          	auipc	s7,0x6
    8000269e:	d6eb8b93          	addi	s7,s7,-658 # 80008408 <states.1728>
    800026a2:	a00d                	j	800026c4 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800026a4:	ed86a583          	lw	a1,-296(a3)
    800026a8:	8556                	mv	a0,s5
    800026aa:	ffffe097          	auipc	ra,0xffffe
    800026ae:	f0c080e7          	jalr	-244(ra) # 800005b6 <printf>
    printf("\n");
    800026b2:	8552                	mv	a0,s4
    800026b4:	ffffe097          	auipc	ra,0xffffe
    800026b8:	f02080e7          	jalr	-254(ra) # 800005b6 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026bc:	17048493          	addi	s1,s1,368
    800026c0:	03248163          	beq	s1,s2,800026e2 <procdump+0x98>
    if(p->state == UNUSED)
    800026c4:	86a6                	mv	a3,s1
    800026c6:	ec04a783          	lw	a5,-320(s1)
    800026ca:	dbed                	beqz	a5,800026bc <procdump+0x72>
      state = "???";
    800026cc:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026ce:	fcfb6be3          	bltu	s6,a5,800026a4 <procdump+0x5a>
    800026d2:	1782                	slli	a5,a5,0x20
    800026d4:	9381                	srli	a5,a5,0x20
    800026d6:	078e                	slli	a5,a5,0x3
    800026d8:	97de                	add	a5,a5,s7
    800026da:	6390                	ld	a2,0(a5)
    800026dc:	f661                	bnez	a2,800026a4 <procdump+0x5a>
      state = "???";
    800026de:	864e                	mv	a2,s3
    800026e0:	b7d1                	j	800026a4 <procdump+0x5a>
  }
}
    800026e2:	60a6                	ld	ra,72(sp)
    800026e4:	6406                	ld	s0,64(sp)
    800026e6:	74e2                	ld	s1,56(sp)
    800026e8:	7942                	ld	s2,48(sp)
    800026ea:	79a2                	ld	s3,40(sp)
    800026ec:	7a02                	ld	s4,32(sp)
    800026ee:	6ae2                	ld	s5,24(sp)
    800026f0:	6b42                	ld	s6,16(sp)
    800026f2:	6ba2                	ld	s7,8(sp)
    800026f4:	6161                	addi	sp,sp,80
    800026f6:	8082                	ret

00000000800026f8 <swtch>:
    800026f8:	00153023          	sd	ra,0(a0)
    800026fc:	00253423          	sd	sp,8(a0)
    80002700:	e900                	sd	s0,16(a0)
    80002702:	ed04                	sd	s1,24(a0)
    80002704:	03253023          	sd	s2,32(a0)
    80002708:	03353423          	sd	s3,40(a0)
    8000270c:	03453823          	sd	s4,48(a0)
    80002710:	03553c23          	sd	s5,56(a0)
    80002714:	05653023          	sd	s6,64(a0)
    80002718:	05753423          	sd	s7,72(a0)
    8000271c:	05853823          	sd	s8,80(a0)
    80002720:	05953c23          	sd	s9,88(a0)
    80002724:	07a53023          	sd	s10,96(a0)
    80002728:	07b53423          	sd	s11,104(a0)
    8000272c:	0005b083          	ld	ra,0(a1)
    80002730:	0085b103          	ld	sp,8(a1)
    80002734:	6980                	ld	s0,16(a1)
    80002736:	6d84                	ld	s1,24(a1)
    80002738:	0205b903          	ld	s2,32(a1)
    8000273c:	0285b983          	ld	s3,40(a1)
    80002740:	0305ba03          	ld	s4,48(a1)
    80002744:	0385ba83          	ld	s5,56(a1)
    80002748:	0405bb03          	ld	s6,64(a1)
    8000274c:	0485bb83          	ld	s7,72(a1)
    80002750:	0505bc03          	ld	s8,80(a1)
    80002754:	0585bc83          	ld	s9,88(a1)
    80002758:	0605bd03          	ld	s10,96(a1)
    8000275c:	0685bd83          	ld	s11,104(a1)
    80002760:	8082                	ret

0000000080002762 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002762:	1141                	addi	sp,sp,-16
    80002764:	e406                	sd	ra,8(sp)
    80002766:	e022                	sd	s0,0(sp)
    80002768:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000276a:	00006597          	auipc	a1,0x6
    8000276e:	cce58593          	addi	a1,a1,-818 # 80008438 <states.1728+0x30>
    80002772:	00014517          	auipc	a0,0x14
    80002776:	79e50513          	addi	a0,a0,1950 # 80016f10 <tickslock>
    8000277a:	ffffe097          	auipc	ra,0xffffe
    8000277e:	408080e7          	jalr	1032(ra) # 80000b82 <initlock>
}
    80002782:	60a2                	ld	ra,8(sp)
    80002784:	6402                	ld	s0,0(sp)
    80002786:	0141                	addi	sp,sp,16
    80002788:	8082                	ret

000000008000278a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000278a:	1141                	addi	sp,sp,-16
    8000278c:	e422                	sd	s0,8(sp)
    8000278e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002790:	00003797          	auipc	a5,0x3
    80002794:	52078793          	addi	a5,a5,1312 # 80005cb0 <kernelvec>
    80002798:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000279c:	6422                	ld	s0,8(sp)
    8000279e:	0141                	addi	sp,sp,16
    800027a0:	8082                	ret

00000000800027a2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800027a2:	1141                	addi	sp,sp,-16
    800027a4:	e406                	sd	ra,8(sp)
    800027a6:	e022                	sd	s0,0(sp)
    800027a8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800027aa:	fffff097          	auipc	ra,0xfffff
    800027ae:	260080e7          	jalr	608(ra) # 80001a0a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027b2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800027b6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027b8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800027bc:	00005617          	auipc	a2,0x5
    800027c0:	84460613          	addi	a2,a2,-1980 # 80007000 <_trampoline>
    800027c4:	00005697          	auipc	a3,0x5
    800027c8:	83c68693          	addi	a3,a3,-1988 # 80007000 <_trampoline>
    800027cc:	8e91                	sub	a3,a3,a2
    800027ce:	040007b7          	lui	a5,0x4000
    800027d2:	17fd                	addi	a5,a5,-1
    800027d4:	07b2                	slli	a5,a5,0xc
    800027d6:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027d8:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027dc:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027de:	180026f3          	csrr	a3,satp
    800027e2:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027e4:	7138                	ld	a4,96(a0)
    800027e6:	6534                	ld	a3,72(a0)
    800027e8:	6585                	lui	a1,0x1
    800027ea:	96ae                	add	a3,a3,a1
    800027ec:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027ee:	7138                	ld	a4,96(a0)
    800027f0:	00000697          	auipc	a3,0x0
    800027f4:	13068693          	addi	a3,a3,304 # 80002920 <usertrap>
    800027f8:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027fa:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027fc:	8692                	mv	a3,tp
    800027fe:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002800:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002804:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002808:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000280c:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002810:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002812:	6f18                	ld	a4,24(a4)
    80002814:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002818:	6d28                	ld	a0,88(a0)
    8000281a:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000281c:	00005717          	auipc	a4,0x5
    80002820:	88070713          	addi	a4,a4,-1920 # 8000709c <userret>
    80002824:	8f11                	sub	a4,a4,a2
    80002826:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002828:	577d                	li	a4,-1
    8000282a:	177e                	slli	a4,a4,0x3f
    8000282c:	8d59                	or	a0,a0,a4
    8000282e:	9782                	jalr	a5
}
    80002830:	60a2                	ld	ra,8(sp)
    80002832:	6402                	ld	s0,0(sp)
    80002834:	0141                	addi	sp,sp,16
    80002836:	8082                	ret

0000000080002838 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002838:	1101                	addi	sp,sp,-32
    8000283a:	ec06                	sd	ra,24(sp)
    8000283c:	e822                	sd	s0,16(sp)
    8000283e:	e426                	sd	s1,8(sp)
    80002840:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002842:	00014497          	auipc	s1,0x14
    80002846:	6ce48493          	addi	s1,s1,1742 # 80016f10 <tickslock>
    8000284a:	8526                	mv	a0,s1
    8000284c:	ffffe097          	auipc	ra,0xffffe
    80002850:	3c6080e7          	jalr	966(ra) # 80000c12 <acquire>
  ticks++;
    80002854:	00006517          	auipc	a0,0x6
    80002858:	42450513          	addi	a0,a0,1060 # 80008c78 <ticks>
    8000285c:	411c                	lw	a5,0(a0)
    8000285e:	2785                	addiw	a5,a5,1
    80002860:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002862:	00000097          	auipc	ra,0x0
    80002866:	970080e7          	jalr	-1680(ra) # 800021d2 <wakeup>
  release(&tickslock);
    8000286a:	8526                	mv	a0,s1
    8000286c:	ffffe097          	auipc	ra,0xffffe
    80002870:	45a080e7          	jalr	1114(ra) # 80000cc6 <release>
}
    80002874:	60e2                	ld	ra,24(sp)
    80002876:	6442                	ld	s0,16(sp)
    80002878:	64a2                	ld	s1,8(sp)
    8000287a:	6105                	addi	sp,sp,32
    8000287c:	8082                	ret

000000008000287e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000287e:	1101                	addi	sp,sp,-32
    80002880:	ec06                	sd	ra,24(sp)
    80002882:	e822                	sd	s0,16(sp)
    80002884:	e426                	sd	s1,8(sp)
    80002886:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002888:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    8000288c:	00074d63          	bltz	a4,800028a6 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002890:	57fd                	li	a5,-1
    80002892:	17fe                	slli	a5,a5,0x3f
    80002894:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002896:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002898:	06f70363          	beq	a4,a5,800028fe <devintr+0x80>
  }
}
    8000289c:	60e2                	ld	ra,24(sp)
    8000289e:	6442                	ld	s0,16(sp)
    800028a0:	64a2                	ld	s1,8(sp)
    800028a2:	6105                	addi	sp,sp,32
    800028a4:	8082                	ret
     (scause & 0xff) == 9){
    800028a6:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800028aa:	46a5                	li	a3,9
    800028ac:	fed792e3          	bne	a5,a3,80002890 <devintr+0x12>
    int irq = plic_claim();
    800028b0:	00003097          	auipc	ra,0x3
    800028b4:	508080e7          	jalr	1288(ra) # 80005db8 <plic_claim>
    800028b8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800028ba:	47a9                	li	a5,10
    800028bc:	02f50763          	beq	a0,a5,800028ea <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800028c0:	4785                	li	a5,1
    800028c2:	02f50963          	beq	a0,a5,800028f4 <devintr+0x76>
    return 1;
    800028c6:	4505                	li	a0,1
    } else if(irq){
    800028c8:	d8f1                	beqz	s1,8000289c <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800028ca:	85a6                	mv	a1,s1
    800028cc:	00006517          	auipc	a0,0x6
    800028d0:	b7450513          	addi	a0,a0,-1164 # 80008440 <states.1728+0x38>
    800028d4:	ffffe097          	auipc	ra,0xffffe
    800028d8:	ce2080e7          	jalr	-798(ra) # 800005b6 <printf>
      plic_complete(irq);
    800028dc:	8526                	mv	a0,s1
    800028de:	00003097          	auipc	ra,0x3
    800028e2:	4fe080e7          	jalr	1278(ra) # 80005ddc <plic_complete>
    return 1;
    800028e6:	4505                	li	a0,1
    800028e8:	bf55                	j	8000289c <devintr+0x1e>
      uartintr();
    800028ea:	ffffe097          	auipc	ra,0xffffe
    800028ee:	0ec080e7          	jalr	236(ra) # 800009d6 <uartintr>
    800028f2:	b7ed                	j	800028dc <devintr+0x5e>
      virtio_disk_intr();
    800028f4:	00004097          	auipc	ra,0x4
    800028f8:	a12080e7          	jalr	-1518(ra) # 80006306 <virtio_disk_intr>
    800028fc:	b7c5                	j	800028dc <devintr+0x5e>
    if(cpuid() == 0){
    800028fe:	fffff097          	auipc	ra,0xfffff
    80002902:	0e0080e7          	jalr	224(ra) # 800019de <cpuid>
    80002906:	c901                	beqz	a0,80002916 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002908:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000290c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000290e:	14479073          	csrw	sip,a5
    return 2;
    80002912:	4509                	li	a0,2
    80002914:	b761                	j	8000289c <devintr+0x1e>
      clockintr();
    80002916:	00000097          	auipc	ra,0x0
    8000291a:	f22080e7          	jalr	-222(ra) # 80002838 <clockintr>
    8000291e:	b7ed                	j	80002908 <devintr+0x8a>

0000000080002920 <usertrap>:
{
    80002920:	1101                	addi	sp,sp,-32
    80002922:	ec06                	sd	ra,24(sp)
    80002924:	e822                	sd	s0,16(sp)
    80002926:	e426                	sd	s1,8(sp)
    80002928:	e04a                	sd	s2,0(sp)
    8000292a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000292c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002930:	1007f793          	andi	a5,a5,256
    80002934:	e3b1                	bnez	a5,80002978 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002936:	00003797          	auipc	a5,0x3
    8000293a:	37a78793          	addi	a5,a5,890 # 80005cb0 <kernelvec>
    8000293e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002942:	fffff097          	auipc	ra,0xfffff
    80002946:	0c8080e7          	jalr	200(ra) # 80001a0a <myproc>
    8000294a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000294c:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000294e:	14102773          	csrr	a4,sepc
    80002952:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002954:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002958:	47a1                	li	a5,8
    8000295a:	02f70763          	beq	a4,a5,80002988 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    8000295e:	00000097          	auipc	ra,0x0
    80002962:	f20080e7          	jalr	-224(ra) # 8000287e <devintr>
    80002966:	892a                	mv	s2,a0
    80002968:	c151                	beqz	a0,800029ec <usertrap+0xcc>
  if(killed(p))
    8000296a:	8526                	mv	a0,s1
    8000296c:	00000097          	auipc	ra,0x0
    80002970:	ac6080e7          	jalr	-1338(ra) # 80002432 <killed>
    80002974:	c929                	beqz	a0,800029c6 <usertrap+0xa6>
    80002976:	a099                	j	800029bc <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002978:	00006517          	auipc	a0,0x6
    8000297c:	ae850513          	addi	a0,a0,-1304 # 80008460 <states.1728+0x58>
    80002980:	ffffe097          	auipc	ra,0xffffe
    80002984:	bec080e7          	jalr	-1044(ra) # 8000056c <panic>
    if(killed(p))
    80002988:	00000097          	auipc	ra,0x0
    8000298c:	aaa080e7          	jalr	-1366(ra) # 80002432 <killed>
    80002990:	e921                	bnez	a0,800029e0 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002992:	70b8                	ld	a4,96(s1)
    80002994:	6f1c                	ld	a5,24(a4)
    80002996:	0791                	addi	a5,a5,4
    80002998:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000299a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000299e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029a2:	10079073          	csrw	sstatus,a5
    syscall();
    800029a6:	00000097          	auipc	ra,0x0
    800029aa:	2d4080e7          	jalr	724(ra) # 80002c7a <syscall>
  if(killed(p))
    800029ae:	8526                	mv	a0,s1
    800029b0:	00000097          	auipc	ra,0x0
    800029b4:	a82080e7          	jalr	-1406(ra) # 80002432 <killed>
    800029b8:	c911                	beqz	a0,800029cc <usertrap+0xac>
    800029ba:	4901                	li	s2,0
    exit(-1);
    800029bc:	557d                	li	a0,-1
    800029be:	00000097          	auipc	ra,0x0
    800029c2:	8ec080e7          	jalr	-1812(ra) # 800022aa <exit>
  if(which_dev == 2)
    800029c6:	4789                	li	a5,2
    800029c8:	04f90f63          	beq	s2,a5,80002a26 <usertrap+0x106>
  usertrapret();
    800029cc:	00000097          	auipc	ra,0x0
    800029d0:	dd6080e7          	jalr	-554(ra) # 800027a2 <usertrapret>
}
    800029d4:	60e2                	ld	ra,24(sp)
    800029d6:	6442                	ld	s0,16(sp)
    800029d8:	64a2                	ld	s1,8(sp)
    800029da:	6902                	ld	s2,0(sp)
    800029dc:	6105                	addi	sp,sp,32
    800029de:	8082                	ret
      exit(-1);
    800029e0:	557d                	li	a0,-1
    800029e2:	00000097          	auipc	ra,0x0
    800029e6:	8c8080e7          	jalr	-1848(ra) # 800022aa <exit>
    800029ea:	b765                	j	80002992 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029ec:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800029f0:	5c90                	lw	a2,56(s1)
    800029f2:	00006517          	auipc	a0,0x6
    800029f6:	a8e50513          	addi	a0,a0,-1394 # 80008480 <states.1728+0x78>
    800029fa:	ffffe097          	auipc	ra,0xffffe
    800029fe:	bbc080e7          	jalr	-1092(ra) # 800005b6 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a02:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a06:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a0a:	00006517          	auipc	a0,0x6
    80002a0e:	aa650513          	addi	a0,a0,-1370 # 800084b0 <states.1728+0xa8>
    80002a12:	ffffe097          	auipc	ra,0xffffe
    80002a16:	ba4080e7          	jalr	-1116(ra) # 800005b6 <printf>
    setkilled(p);
    80002a1a:	8526                	mv	a0,s1
    80002a1c:	00000097          	auipc	ra,0x0
    80002a20:	9e0080e7          	jalr	-1568(ra) # 800023fc <setkilled>
    80002a24:	b769                	j	800029ae <usertrap+0x8e>
    yield();
    80002a26:	fffff097          	auipc	ra,0xfffff
    80002a2a:	6e4080e7          	jalr	1764(ra) # 8000210a <yield>
    80002a2e:	bf79                	j	800029cc <usertrap+0xac>

0000000080002a30 <kerneltrap>:
{
    80002a30:	7179                	addi	sp,sp,-48
    80002a32:	f406                	sd	ra,40(sp)
    80002a34:	f022                	sd	s0,32(sp)
    80002a36:	ec26                	sd	s1,24(sp)
    80002a38:	e84a                	sd	s2,16(sp)
    80002a3a:	e44e                	sd	s3,8(sp)
    80002a3c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a3e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a42:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a46:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a4a:	1004f793          	andi	a5,s1,256
    80002a4e:	cb85                	beqz	a5,80002a7e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a50:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a54:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a56:	ef85                	bnez	a5,80002a8e <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a58:	00000097          	auipc	ra,0x0
    80002a5c:	e26080e7          	jalr	-474(ra) # 8000287e <devintr>
    80002a60:	cd1d                	beqz	a0,80002a9e <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a62:	4789                	li	a5,2
    80002a64:	06f50a63          	beq	a0,a5,80002ad8 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a68:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a6c:	10049073          	csrw	sstatus,s1
}
    80002a70:	70a2                	ld	ra,40(sp)
    80002a72:	7402                	ld	s0,32(sp)
    80002a74:	64e2                	ld	s1,24(sp)
    80002a76:	6942                	ld	s2,16(sp)
    80002a78:	69a2                	ld	s3,8(sp)
    80002a7a:	6145                	addi	sp,sp,48
    80002a7c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a7e:	00006517          	auipc	a0,0x6
    80002a82:	a5250513          	addi	a0,a0,-1454 # 800084d0 <states.1728+0xc8>
    80002a86:	ffffe097          	auipc	ra,0xffffe
    80002a8a:	ae6080e7          	jalr	-1306(ra) # 8000056c <panic>
    panic("kerneltrap: interrupts enabled");
    80002a8e:	00006517          	auipc	a0,0x6
    80002a92:	a6a50513          	addi	a0,a0,-1430 # 800084f8 <states.1728+0xf0>
    80002a96:	ffffe097          	auipc	ra,0xffffe
    80002a9a:	ad6080e7          	jalr	-1322(ra) # 8000056c <panic>
    printf("scause %p\n", scause);
    80002a9e:	85ce                	mv	a1,s3
    80002aa0:	00006517          	auipc	a0,0x6
    80002aa4:	a7850513          	addi	a0,a0,-1416 # 80008518 <states.1728+0x110>
    80002aa8:	ffffe097          	auipc	ra,0xffffe
    80002aac:	b0e080e7          	jalr	-1266(ra) # 800005b6 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ab0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ab4:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ab8:	00006517          	auipc	a0,0x6
    80002abc:	a7050513          	addi	a0,a0,-1424 # 80008528 <states.1728+0x120>
    80002ac0:	ffffe097          	auipc	ra,0xffffe
    80002ac4:	af6080e7          	jalr	-1290(ra) # 800005b6 <printf>
    panic("kerneltrap");
    80002ac8:	00006517          	auipc	a0,0x6
    80002acc:	a7850513          	addi	a0,a0,-1416 # 80008540 <states.1728+0x138>
    80002ad0:	ffffe097          	auipc	ra,0xffffe
    80002ad4:	a9c080e7          	jalr	-1380(ra) # 8000056c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ad8:	fffff097          	auipc	ra,0xfffff
    80002adc:	f32080e7          	jalr	-206(ra) # 80001a0a <myproc>
    80002ae0:	d541                	beqz	a0,80002a68 <kerneltrap+0x38>
    80002ae2:	fffff097          	auipc	ra,0xfffff
    80002ae6:	f28080e7          	jalr	-216(ra) # 80001a0a <myproc>
    80002aea:	5118                	lw	a4,32(a0)
    80002aec:	4791                	li	a5,4
    80002aee:	f6f71de3          	bne	a4,a5,80002a68 <kerneltrap+0x38>
    yield();
    80002af2:	fffff097          	auipc	ra,0xfffff
    80002af6:	618080e7          	jalr	1560(ra) # 8000210a <yield>
    80002afa:	b7bd                	j	80002a68 <kerneltrap+0x38>

0000000080002afc <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002afc:	1101                	addi	sp,sp,-32
    80002afe:	ec06                	sd	ra,24(sp)
    80002b00:	e822                	sd	s0,16(sp)
    80002b02:	e426                	sd	s1,8(sp)
    80002b04:	1000                	addi	s0,sp,32
    80002b06:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b08:	fffff097          	auipc	ra,0xfffff
    80002b0c:	f02080e7          	jalr	-254(ra) # 80001a0a <myproc>
  switch (n) {
    80002b10:	4795                	li	a5,5
    80002b12:	0497e163          	bltu	a5,s1,80002b54 <argraw+0x58>
    80002b16:	048a                	slli	s1,s1,0x2
    80002b18:	00006717          	auipc	a4,0x6
    80002b1c:	be070713          	addi	a4,a4,-1056 # 800086f8 <states.1728+0x2f0>
    80002b20:	94ba                	add	s1,s1,a4
    80002b22:	409c                	lw	a5,0(s1)
    80002b24:	97ba                	add	a5,a5,a4
    80002b26:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b28:	713c                	ld	a5,96(a0)
    80002b2a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b2c:	60e2                	ld	ra,24(sp)
    80002b2e:	6442                	ld	s0,16(sp)
    80002b30:	64a2                	ld	s1,8(sp)
    80002b32:	6105                	addi	sp,sp,32
    80002b34:	8082                	ret
    return p->trapframe->a1;
    80002b36:	713c                	ld	a5,96(a0)
    80002b38:	7fa8                	ld	a0,120(a5)
    80002b3a:	bfcd                	j	80002b2c <argraw+0x30>
    return p->trapframe->a2;
    80002b3c:	713c                	ld	a5,96(a0)
    80002b3e:	63c8                	ld	a0,128(a5)
    80002b40:	b7f5                	j	80002b2c <argraw+0x30>
    return p->trapframe->a3;
    80002b42:	713c                	ld	a5,96(a0)
    80002b44:	67c8                	ld	a0,136(a5)
    80002b46:	b7dd                	j	80002b2c <argraw+0x30>
    return p->trapframe->a4;
    80002b48:	713c                	ld	a5,96(a0)
    80002b4a:	6bc8                	ld	a0,144(a5)
    80002b4c:	b7c5                	j	80002b2c <argraw+0x30>
    return p->trapframe->a5;
    80002b4e:	713c                	ld	a5,96(a0)
    80002b50:	6fc8                	ld	a0,152(a5)
    80002b52:	bfe9                	j	80002b2c <argraw+0x30>
  panic("argraw");
    80002b54:	00006517          	auipc	a0,0x6
    80002b58:	9fc50513          	addi	a0,a0,-1540 # 80008550 <states.1728+0x148>
    80002b5c:	ffffe097          	auipc	ra,0xffffe
    80002b60:	a10080e7          	jalr	-1520(ra) # 8000056c <panic>

0000000080002b64 <fetchaddr>:
{
    80002b64:	1101                	addi	sp,sp,-32
    80002b66:	ec06                	sd	ra,24(sp)
    80002b68:	e822                	sd	s0,16(sp)
    80002b6a:	e426                	sd	s1,8(sp)
    80002b6c:	e04a                	sd	s2,0(sp)
    80002b6e:	1000                	addi	s0,sp,32
    80002b70:	84aa                	mv	s1,a0
    80002b72:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b74:	fffff097          	auipc	ra,0xfffff
    80002b78:	e96080e7          	jalr	-362(ra) # 80001a0a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002b7c:	693c                	ld	a5,80(a0)
    80002b7e:	02f4f863          	bgeu	s1,a5,80002bae <fetchaddr+0x4a>
    80002b82:	00848713          	addi	a4,s1,8
    80002b86:	02e7e663          	bltu	a5,a4,80002bb2 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b8a:	46a1                	li	a3,8
    80002b8c:	8626                	mv	a2,s1
    80002b8e:	85ca                	mv	a1,s2
    80002b90:	6d28                	ld	a0,88(a0)
    80002b92:	fffff097          	auipc	ra,0xfffff
    80002b96:	bc0080e7          	jalr	-1088(ra) # 80001752 <copyin>
    80002b9a:	00a03533          	snez	a0,a0
    80002b9e:	40a00533          	neg	a0,a0
}
    80002ba2:	60e2                	ld	ra,24(sp)
    80002ba4:	6442                	ld	s0,16(sp)
    80002ba6:	64a2                	ld	s1,8(sp)
    80002ba8:	6902                	ld	s2,0(sp)
    80002baa:	6105                	addi	sp,sp,32
    80002bac:	8082                	ret
    return -1;
    80002bae:	557d                	li	a0,-1
    80002bb0:	bfcd                	j	80002ba2 <fetchaddr+0x3e>
    80002bb2:	557d                	li	a0,-1
    80002bb4:	b7fd                	j	80002ba2 <fetchaddr+0x3e>

0000000080002bb6 <fetchstr>:
{
    80002bb6:	7179                	addi	sp,sp,-48
    80002bb8:	f406                	sd	ra,40(sp)
    80002bba:	f022                	sd	s0,32(sp)
    80002bbc:	ec26                	sd	s1,24(sp)
    80002bbe:	e84a                	sd	s2,16(sp)
    80002bc0:	e44e                	sd	s3,8(sp)
    80002bc2:	1800                	addi	s0,sp,48
    80002bc4:	892a                	mv	s2,a0
    80002bc6:	84ae                	mv	s1,a1
    80002bc8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002bca:	fffff097          	auipc	ra,0xfffff
    80002bce:	e40080e7          	jalr	-448(ra) # 80001a0a <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002bd2:	86ce                	mv	a3,s3
    80002bd4:	864a                	mv	a2,s2
    80002bd6:	85a6                	mv	a1,s1
    80002bd8:	6d28                	ld	a0,88(a0)
    80002bda:	fffff097          	auipc	ra,0xfffff
    80002bde:	c04080e7          	jalr	-1020(ra) # 800017de <copyinstr>
    80002be2:	00054e63          	bltz	a0,80002bfe <fetchstr+0x48>
  return strlen(buf);
    80002be6:	8526                	mv	a0,s1
    80002be8:	ffffe097          	auipc	ra,0xffffe
    80002bec:	2aa080e7          	jalr	682(ra) # 80000e92 <strlen>
}
    80002bf0:	70a2                	ld	ra,40(sp)
    80002bf2:	7402                	ld	s0,32(sp)
    80002bf4:	64e2                	ld	s1,24(sp)
    80002bf6:	6942                	ld	s2,16(sp)
    80002bf8:	69a2                	ld	s3,8(sp)
    80002bfa:	6145                	addi	sp,sp,48
    80002bfc:	8082                	ret
    return -1;
    80002bfe:	557d                	li	a0,-1
    80002c00:	bfc5                	j	80002bf0 <fetchstr+0x3a>

0000000080002c02 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002c02:	1101                	addi	sp,sp,-32
    80002c04:	ec06                	sd	ra,24(sp)
    80002c06:	e822                	sd	s0,16(sp)
    80002c08:	e426                	sd	s1,8(sp)
    80002c0a:	1000                	addi	s0,sp,32
    80002c0c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c0e:	00000097          	auipc	ra,0x0
    80002c12:	eee080e7          	jalr	-274(ra) # 80002afc <argraw>
    80002c16:	c088                	sw	a0,0(s1)
}
    80002c18:	60e2                	ld	ra,24(sp)
    80002c1a:	6442                	ld	s0,16(sp)
    80002c1c:	64a2                	ld	s1,8(sp)
    80002c1e:	6105                	addi	sp,sp,32
    80002c20:	8082                	ret

0000000080002c22 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002c22:	1101                	addi	sp,sp,-32
    80002c24:	ec06                	sd	ra,24(sp)
    80002c26:	e822                	sd	s0,16(sp)
    80002c28:	e426                	sd	s1,8(sp)
    80002c2a:	1000                	addi	s0,sp,32
    80002c2c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c2e:	00000097          	auipc	ra,0x0
    80002c32:	ece080e7          	jalr	-306(ra) # 80002afc <argraw>
    80002c36:	e088                	sd	a0,0(s1)
}
    80002c38:	60e2                	ld	ra,24(sp)
    80002c3a:	6442                	ld	s0,16(sp)
    80002c3c:	64a2                	ld	s1,8(sp)
    80002c3e:	6105                	addi	sp,sp,32
    80002c40:	8082                	ret

0000000080002c42 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c42:	7179                	addi	sp,sp,-48
    80002c44:	f406                	sd	ra,40(sp)
    80002c46:	f022                	sd	s0,32(sp)
    80002c48:	ec26                	sd	s1,24(sp)
    80002c4a:	e84a                	sd	s2,16(sp)
    80002c4c:	1800                	addi	s0,sp,48
    80002c4e:	84ae                	mv	s1,a1
    80002c50:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002c52:	fd840593          	addi	a1,s0,-40
    80002c56:	00000097          	auipc	ra,0x0
    80002c5a:	fcc080e7          	jalr	-52(ra) # 80002c22 <argaddr>
  return fetchstr(addr, buf, max);
    80002c5e:	864a                	mv	a2,s2
    80002c60:	85a6                	mv	a1,s1
    80002c62:	fd843503          	ld	a0,-40(s0)
    80002c66:	00000097          	auipc	ra,0x0
    80002c6a:	f50080e7          	jalr	-176(ra) # 80002bb6 <fetchstr>
}
    80002c6e:	70a2                	ld	ra,40(sp)
    80002c70:	7402                	ld	s0,32(sp)
    80002c72:	64e2                	ld	s1,24(sp)
    80002c74:	6942                	ld	s2,16(sp)
    80002c76:	6145                	addi	sp,sp,48
    80002c78:	8082                	ret

0000000080002c7a <syscall>:
[SYS_trace]   "syscall trace",
[SYS_yield]   "syscall yield",
};
void
syscall(void)
{
    80002c7a:	7179                	addi	sp,sp,-48
    80002c7c:	f406                	sd	ra,40(sp)
    80002c7e:	f022                	sd	s0,32(sp)
    80002c80:	ec26                	sd	s1,24(sp)
    80002c82:	e84a                	sd	s2,16(sp)
    80002c84:	e44e                	sd	s3,8(sp)
    80002c86:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002c88:	fffff097          	auipc	ra,0xfffff
    80002c8c:	d82080e7          	jalr	-638(ra) # 80001a0a <myproc>
    80002c90:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c92:	06053903          	ld	s2,96(a0)
    80002c96:	0a893783          	ld	a5,168(s2)
    80002c9a:	0007899b          	sext.w	s3,a5
  // num = * (int *) 0;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002c9e:	37fd                	addiw	a5,a5,-1
    80002ca0:	4759                	li	a4,22
    80002ca2:	04f76763          	bltu	a4,a5,80002cf0 <syscall+0x76>
    80002ca6:	00399713          	slli	a4,s3,0x3
    80002caa:	00006797          	auipc	a5,0x6
    80002cae:	a6678793          	addi	a5,a5,-1434 # 80008710 <syscalls>
    80002cb2:	97ba                	add	a5,a5,a4
    80002cb4:	639c                	ld	a5,0(a5)
    80002cb6:	cf8d                	beqz	a5,80002cf0 <syscall+0x76>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002cb8:	9782                	jalr	a5
    80002cba:	06a93823          	sd	a0,112(s2)
    if ((p->mask >> num) & 0b1) {
    80002cbe:	609c                	ld	a5,0(s1)
    80002cc0:	0137d7b3          	srl	a5,a5,s3
    80002cc4:	8b85                	andi	a5,a5,1
    80002cc6:	c7a1                	beqz	a5,80002d0e <syscall+0x94>
      printf("%d: %s -> %d\n", p->pid, syscalls_name[num], p->trapframe->a0 );
    80002cc8:	70b8                	ld	a4,96(s1)
    80002cca:	098e                	slli	s3,s3,0x3
    80002ccc:	00006797          	auipc	a5,0x6
    80002cd0:	a4478793          	addi	a5,a5,-1468 # 80008710 <syscalls>
    80002cd4:	99be                	add	s3,s3,a5
    80002cd6:	7b34                	ld	a3,112(a4)
    80002cd8:	0c09b603          	ld	a2,192(s3)
    80002cdc:	5c8c                	lw	a1,56(s1)
    80002cde:	00006517          	auipc	a0,0x6
    80002ce2:	87a50513          	addi	a0,a0,-1926 # 80008558 <states.1728+0x150>
    80002ce6:	ffffe097          	auipc	ra,0xffffe
    80002cea:	8d0080e7          	jalr	-1840(ra) # 800005b6 <printf>
    80002cee:	a005                	j	80002d0e <syscall+0x94>
    }
  } 
  else {
    printf("%d %s: unknown sys call %d\n",
    80002cf0:	86ce                	mv	a3,s3
    80002cf2:	16048613          	addi	a2,s1,352
    80002cf6:	5c8c                	lw	a1,56(s1)
    80002cf8:	00006517          	auipc	a0,0x6
    80002cfc:	87050513          	addi	a0,a0,-1936 # 80008568 <states.1728+0x160>
    80002d00:	ffffe097          	auipc	ra,0xffffe
    80002d04:	8b6080e7          	jalr	-1866(ra) # 800005b6 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002d08:	70bc                	ld	a5,96(s1)
    80002d0a:	577d                	li	a4,-1
    80002d0c:	fbb8                	sd	a4,112(a5)
  }
}
    80002d0e:	70a2                	ld	ra,40(sp)
    80002d10:	7402                	ld	s0,32(sp)
    80002d12:	64e2                	ld	s1,24(sp)
    80002d14:	6942                	ld	s2,16(sp)
    80002d16:	69a2                	ld	s3,8(sp)
    80002d18:	6145                	addi	sp,sp,48
    80002d1a:	8082                	ret

0000000080002d1c <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002d1c:	1101                	addi	sp,sp,-32
    80002d1e:	ec06                	sd	ra,24(sp)
    80002d20:	e822                	sd	s0,16(sp)
    80002d22:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002d24:	fec40593          	addi	a1,s0,-20
    80002d28:	4501                	li	a0,0
    80002d2a:	00000097          	auipc	ra,0x0
    80002d2e:	ed8080e7          	jalr	-296(ra) # 80002c02 <argint>
  exit(n);
    80002d32:	fec42503          	lw	a0,-20(s0)
    80002d36:	fffff097          	auipc	ra,0xfffff
    80002d3a:	574080e7          	jalr	1396(ra) # 800022aa <exit>
  return 0;  // not reached
}
    80002d3e:	4501                	li	a0,0
    80002d40:	60e2                	ld	ra,24(sp)
    80002d42:	6442                	ld	s0,16(sp)
    80002d44:	6105                	addi	sp,sp,32
    80002d46:	8082                	ret

0000000080002d48 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d48:	1141                	addi	sp,sp,-16
    80002d4a:	e406                	sd	ra,8(sp)
    80002d4c:	e022                	sd	s0,0(sp)
    80002d4e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002d50:	fffff097          	auipc	ra,0xfffff
    80002d54:	cba080e7          	jalr	-838(ra) # 80001a0a <myproc>
}
    80002d58:	5d08                	lw	a0,56(a0)
    80002d5a:	60a2                	ld	ra,8(sp)
    80002d5c:	6402                	ld	s0,0(sp)
    80002d5e:	0141                	addi	sp,sp,16
    80002d60:	8082                	ret

0000000080002d62 <sys_fork>:

uint64
sys_fork(void)
{
    80002d62:	1141                	addi	sp,sp,-16
    80002d64:	e406                	sd	ra,8(sp)
    80002d66:	e022                	sd	s0,0(sp)
    80002d68:	0800                	addi	s0,sp,16
  return fork();
    80002d6a:	fffff097          	auipc	ra,0xfffff
    80002d6e:	0d4080e7          	jalr	212(ra) # 80001e3e <fork>
}
    80002d72:	60a2                	ld	ra,8(sp)
    80002d74:	6402                	ld	s0,0(sp)
    80002d76:	0141                	addi	sp,sp,16
    80002d78:	8082                	ret

0000000080002d7a <sys_wait>:

uint64
sys_wait(void)
{
    80002d7a:	1101                	addi	sp,sp,-32
    80002d7c:	ec06                	sd	ra,24(sp)
    80002d7e:	e822                	sd	s0,16(sp)
    80002d80:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002d82:	fe840593          	addi	a1,s0,-24
    80002d86:	4501                	li	a0,0
    80002d88:	00000097          	auipc	ra,0x0
    80002d8c:	e9a080e7          	jalr	-358(ra) # 80002c22 <argaddr>
  return wait(p);
    80002d90:	fe843503          	ld	a0,-24(s0)
    80002d94:	fffff097          	auipc	ra,0xfffff
    80002d98:	6d4080e7          	jalr	1748(ra) # 80002468 <wait>
}
    80002d9c:	60e2                	ld	ra,24(sp)
    80002d9e:	6442                	ld	s0,16(sp)
    80002da0:	6105                	addi	sp,sp,32
    80002da2:	8082                	ret

0000000080002da4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002da4:	7179                	addi	sp,sp,-48
    80002da6:	f406                	sd	ra,40(sp)
    80002da8:	f022                	sd	s0,32(sp)
    80002daa:	ec26                	sd	s1,24(sp)
    80002dac:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002dae:	fdc40593          	addi	a1,s0,-36
    80002db2:	4501                	li	a0,0
    80002db4:	00000097          	auipc	ra,0x0
    80002db8:	e4e080e7          	jalr	-434(ra) # 80002c02 <argint>
  addr = myproc()->sz;
    80002dbc:	fffff097          	auipc	ra,0xfffff
    80002dc0:	c4e080e7          	jalr	-946(ra) # 80001a0a <myproc>
    80002dc4:	6924                	ld	s1,80(a0)
  if(growproc(n) < 0)
    80002dc6:	fdc42503          	lw	a0,-36(s0)
    80002dca:	fffff097          	auipc	ra,0xfffff
    80002dce:	018080e7          	jalr	24(ra) # 80001de2 <growproc>
    80002dd2:	00054863          	bltz	a0,80002de2 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002dd6:	8526                	mv	a0,s1
    80002dd8:	70a2                	ld	ra,40(sp)
    80002dda:	7402                	ld	s0,32(sp)
    80002ddc:	64e2                	ld	s1,24(sp)
    80002dde:	6145                	addi	sp,sp,48
    80002de0:	8082                	ret
    return -1;
    80002de2:	54fd                	li	s1,-1
    80002de4:	bfcd                	j	80002dd6 <sys_sbrk+0x32>

0000000080002de6 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002de6:	7139                	addi	sp,sp,-64
    80002de8:	fc06                	sd	ra,56(sp)
    80002dea:	f822                	sd	s0,48(sp)
    80002dec:	f426                	sd	s1,40(sp)
    80002dee:	f04a                	sd	s2,32(sp)
    80002df0:	ec4e                	sd	s3,24(sp)
    80002df2:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002df4:	fcc40593          	addi	a1,s0,-52
    80002df8:	4501                	li	a0,0
    80002dfa:	00000097          	auipc	ra,0x0
    80002dfe:	e08080e7          	jalr	-504(ra) # 80002c02 <argint>
  acquire(&tickslock);
    80002e02:	00014517          	auipc	a0,0x14
    80002e06:	10e50513          	addi	a0,a0,270 # 80016f10 <tickslock>
    80002e0a:	ffffe097          	auipc	ra,0xffffe
    80002e0e:	e08080e7          	jalr	-504(ra) # 80000c12 <acquire>
  ticks0 = ticks;
    80002e12:	00006917          	auipc	s2,0x6
    80002e16:	e6692903          	lw	s2,-410(s2) # 80008c78 <ticks>
  while(ticks - ticks0 < n){
    80002e1a:	fcc42783          	lw	a5,-52(s0)
    80002e1e:	cf9d                	beqz	a5,80002e5c <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e20:	00014997          	auipc	s3,0x14
    80002e24:	0f098993          	addi	s3,s3,240 # 80016f10 <tickslock>
    80002e28:	00006497          	auipc	s1,0x6
    80002e2c:	e5048493          	addi	s1,s1,-432 # 80008c78 <ticks>
    if(killed(myproc())){
    80002e30:	fffff097          	auipc	ra,0xfffff
    80002e34:	bda080e7          	jalr	-1062(ra) # 80001a0a <myproc>
    80002e38:	fffff097          	auipc	ra,0xfffff
    80002e3c:	5fa080e7          	jalr	1530(ra) # 80002432 <killed>
    80002e40:	ed15                	bnez	a0,80002e7c <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002e42:	85ce                	mv	a1,s3
    80002e44:	8526                	mv	a0,s1
    80002e46:	fffff097          	auipc	ra,0xfffff
    80002e4a:	31e080e7          	jalr	798(ra) # 80002164 <sleep>
  while(ticks - ticks0 < n){
    80002e4e:	409c                	lw	a5,0(s1)
    80002e50:	412787bb          	subw	a5,a5,s2
    80002e54:	fcc42703          	lw	a4,-52(s0)
    80002e58:	fce7ece3          	bltu	a5,a4,80002e30 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002e5c:	00014517          	auipc	a0,0x14
    80002e60:	0b450513          	addi	a0,a0,180 # 80016f10 <tickslock>
    80002e64:	ffffe097          	auipc	ra,0xffffe
    80002e68:	e62080e7          	jalr	-414(ra) # 80000cc6 <release>
  return 0;
    80002e6c:	4501                	li	a0,0
}
    80002e6e:	70e2                	ld	ra,56(sp)
    80002e70:	7442                	ld	s0,48(sp)
    80002e72:	74a2                	ld	s1,40(sp)
    80002e74:	7902                	ld	s2,32(sp)
    80002e76:	69e2                	ld	s3,24(sp)
    80002e78:	6121                	addi	sp,sp,64
    80002e7a:	8082                	ret
      release(&tickslock);
    80002e7c:	00014517          	auipc	a0,0x14
    80002e80:	09450513          	addi	a0,a0,148 # 80016f10 <tickslock>
    80002e84:	ffffe097          	auipc	ra,0xffffe
    80002e88:	e42080e7          	jalr	-446(ra) # 80000cc6 <release>
      return -1;
    80002e8c:	557d                	li	a0,-1
    80002e8e:	b7c5                	j	80002e6e <sys_sleep+0x88>

0000000080002e90 <sys_kill>:

uint64
sys_kill(void)
{
    80002e90:	1101                	addi	sp,sp,-32
    80002e92:	ec06                	sd	ra,24(sp)
    80002e94:	e822                	sd	s0,16(sp)
    80002e96:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002e98:	fec40593          	addi	a1,s0,-20
    80002e9c:	4501                	li	a0,0
    80002e9e:	00000097          	auipc	ra,0x0
    80002ea2:	d64080e7          	jalr	-668(ra) # 80002c02 <argint>
  return kill(pid);
    80002ea6:	fec42503          	lw	a0,-20(s0)
    80002eaa:	fffff097          	auipc	ra,0xfffff
    80002eae:	4d8080e7          	jalr	1240(ra) # 80002382 <kill>
}
    80002eb2:	60e2                	ld	ra,24(sp)
    80002eb4:	6442                	ld	s0,16(sp)
    80002eb6:	6105                	addi	sp,sp,32
    80002eb8:	8082                	ret

0000000080002eba <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002eba:	1101                	addi	sp,sp,-32
    80002ebc:	ec06                	sd	ra,24(sp)
    80002ebe:	e822                	sd	s0,16(sp)
    80002ec0:	e426                	sd	s1,8(sp)
    80002ec2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ec4:	00014517          	auipc	a0,0x14
    80002ec8:	04c50513          	addi	a0,a0,76 # 80016f10 <tickslock>
    80002ecc:	ffffe097          	auipc	ra,0xffffe
    80002ed0:	d46080e7          	jalr	-698(ra) # 80000c12 <acquire>
  xticks = ticks;
    80002ed4:	00006497          	auipc	s1,0x6
    80002ed8:	da44a483          	lw	s1,-604(s1) # 80008c78 <ticks>
  release(&tickslock);
    80002edc:	00014517          	auipc	a0,0x14
    80002ee0:	03450513          	addi	a0,a0,52 # 80016f10 <tickslock>
    80002ee4:	ffffe097          	auipc	ra,0xffffe
    80002ee8:	de2080e7          	jalr	-542(ra) # 80000cc6 <release>
  return xticks;
}
    80002eec:	02049513          	slli	a0,s1,0x20
    80002ef0:	9101                	srli	a0,a0,0x20
    80002ef2:	60e2                	ld	ra,24(sp)
    80002ef4:	6442                	ld	s0,16(sp)
    80002ef6:	64a2                	ld	s1,8(sp)
    80002ef8:	6105                	addi	sp,sp,32
    80002efa:	8082                	ret

0000000080002efc <sys_trace>:

uint64
sys_trace(void)
{
    80002efc:	1101                	addi	sp,sp,-32
    80002efe:	ec06                	sd	ra,24(sp)
    80002f00:	e822                	sd	s0,16(sp)
    80002f02:	1000                	addi	s0,sp,32
  int mask;

  argint(0, &mask);
    80002f04:	fec40593          	addi	a1,s0,-20
    80002f08:	4501                	li	a0,0
    80002f0a:	00000097          	auipc	ra,0x0
    80002f0e:	cf8080e7          	jalr	-776(ra) # 80002c02 <argint>
  struct proc *p = myproc();
    80002f12:	fffff097          	auipc	ra,0xfffff
    80002f16:	af8080e7          	jalr	-1288(ra) # 80001a0a <myproc>
  p->mask = mask;
    80002f1a:	fec42783          	lw	a5,-20(s0)
    80002f1e:	e11c                	sd	a5,0(a0)
  return 0;
}
    80002f20:	4501                	li	a0,0
    80002f22:	60e2                	ld	ra,24(sp)
    80002f24:	6442                	ld	s0,16(sp)
    80002f26:	6105                	addi	sp,sp,32
    80002f28:	8082                	ret

0000000080002f2a <sys_yield>:
// uint64
void
sys_yield(void)
{
    80002f2a:	1141                	addi	sp,sp,-16
    80002f2c:	e406                	sd	ra,8(sp)
    80002f2e:	e022                	sd	s0,0(sp)
    80002f30:	0800                	addi	s0,sp,16
  // struct proc *p = myproc();
  // uint64 pc = p->trapframe->epc; 
  // printf("start to yield, user pc %p\n", pc);
  return yield();
    80002f32:	fffff097          	auipc	ra,0xfffff
    80002f36:	1d8080e7          	jalr	472(ra) # 8000210a <yield>
    80002f3a:	60a2                	ld	ra,8(sp)
    80002f3c:	6402                	ld	s0,0(sp)
    80002f3e:	0141                	addi	sp,sp,16
    80002f40:	8082                	ret

0000000080002f42 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f42:	7179                	addi	sp,sp,-48
    80002f44:	f406                	sd	ra,40(sp)
    80002f46:	f022                	sd	s0,32(sp)
    80002f48:	ec26                	sd	s1,24(sp)
    80002f4a:	e84a                	sd	s2,16(sp)
    80002f4c:	e44e                	sd	s3,8(sp)
    80002f4e:	e052                	sd	s4,0(sp)
    80002f50:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f52:	00006597          	auipc	a1,0x6
    80002f56:	93e58593          	addi	a1,a1,-1730 # 80008890 <syscalls_name+0xc0>
    80002f5a:	00014517          	auipc	a0,0x14
    80002f5e:	fce50513          	addi	a0,a0,-50 # 80016f28 <bcache>
    80002f62:	ffffe097          	auipc	ra,0xffffe
    80002f66:	c20080e7          	jalr	-992(ra) # 80000b82 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f6a:	0001c797          	auipc	a5,0x1c
    80002f6e:	fbe78793          	addi	a5,a5,-66 # 8001ef28 <bcache+0x8000>
    80002f72:	0001c717          	auipc	a4,0x1c
    80002f76:	21e70713          	addi	a4,a4,542 # 8001f190 <bcache+0x8268>
    80002f7a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f7e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f82:	00014497          	auipc	s1,0x14
    80002f86:	fbe48493          	addi	s1,s1,-66 # 80016f40 <bcache+0x18>
    b->next = bcache.head.next;
    80002f8a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f8c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f8e:	00006a17          	auipc	s4,0x6
    80002f92:	90aa0a13          	addi	s4,s4,-1782 # 80008898 <syscalls_name+0xc8>
    b->next = bcache.head.next;
    80002f96:	2b893783          	ld	a5,696(s2)
    80002f9a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f9c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002fa0:	85d2                	mv	a1,s4
    80002fa2:	01048513          	addi	a0,s1,16
    80002fa6:	00001097          	auipc	ra,0x1
    80002faa:	4c4080e7          	jalr	1220(ra) # 8000446a <initsleeplock>
    bcache.head.next->prev = b;
    80002fae:	2b893783          	ld	a5,696(s2)
    80002fb2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002fb4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002fb8:	45848493          	addi	s1,s1,1112
    80002fbc:	fd349de3          	bne	s1,s3,80002f96 <binit+0x54>
  }
}
    80002fc0:	70a2                	ld	ra,40(sp)
    80002fc2:	7402                	ld	s0,32(sp)
    80002fc4:	64e2                	ld	s1,24(sp)
    80002fc6:	6942                	ld	s2,16(sp)
    80002fc8:	69a2                	ld	s3,8(sp)
    80002fca:	6a02                	ld	s4,0(sp)
    80002fcc:	6145                	addi	sp,sp,48
    80002fce:	8082                	ret

0000000080002fd0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002fd0:	7179                	addi	sp,sp,-48
    80002fd2:	f406                	sd	ra,40(sp)
    80002fd4:	f022                	sd	s0,32(sp)
    80002fd6:	ec26                	sd	s1,24(sp)
    80002fd8:	e84a                	sd	s2,16(sp)
    80002fda:	e44e                	sd	s3,8(sp)
    80002fdc:	1800                	addi	s0,sp,48
    80002fde:	89aa                	mv	s3,a0
    80002fe0:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002fe2:	00014517          	auipc	a0,0x14
    80002fe6:	f4650513          	addi	a0,a0,-186 # 80016f28 <bcache>
    80002fea:	ffffe097          	auipc	ra,0xffffe
    80002fee:	c28080e7          	jalr	-984(ra) # 80000c12 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002ff2:	0001c497          	auipc	s1,0x1c
    80002ff6:	1ee4b483          	ld	s1,494(s1) # 8001f1e0 <bcache+0x82b8>
    80002ffa:	0001c797          	auipc	a5,0x1c
    80002ffe:	19678793          	addi	a5,a5,406 # 8001f190 <bcache+0x8268>
    80003002:	02f48f63          	beq	s1,a5,80003040 <bread+0x70>
    80003006:	873e                	mv	a4,a5
    80003008:	a021                	j	80003010 <bread+0x40>
    8000300a:	68a4                	ld	s1,80(s1)
    8000300c:	02e48a63          	beq	s1,a4,80003040 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003010:	449c                	lw	a5,8(s1)
    80003012:	ff379ce3          	bne	a5,s3,8000300a <bread+0x3a>
    80003016:	44dc                	lw	a5,12(s1)
    80003018:	ff2799e3          	bne	a5,s2,8000300a <bread+0x3a>
      b->refcnt++;
    8000301c:	40bc                	lw	a5,64(s1)
    8000301e:	2785                	addiw	a5,a5,1
    80003020:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003022:	00014517          	auipc	a0,0x14
    80003026:	f0650513          	addi	a0,a0,-250 # 80016f28 <bcache>
    8000302a:	ffffe097          	auipc	ra,0xffffe
    8000302e:	c9c080e7          	jalr	-868(ra) # 80000cc6 <release>
      acquiresleep(&b->lock);
    80003032:	01048513          	addi	a0,s1,16
    80003036:	00001097          	auipc	ra,0x1
    8000303a:	46e080e7          	jalr	1134(ra) # 800044a4 <acquiresleep>
      return b;
    8000303e:	a8b9                	j	8000309c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003040:	0001c497          	auipc	s1,0x1c
    80003044:	1984b483          	ld	s1,408(s1) # 8001f1d8 <bcache+0x82b0>
    80003048:	0001c797          	auipc	a5,0x1c
    8000304c:	14878793          	addi	a5,a5,328 # 8001f190 <bcache+0x8268>
    80003050:	00f48863          	beq	s1,a5,80003060 <bread+0x90>
    80003054:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003056:	40bc                	lw	a5,64(s1)
    80003058:	cf81                	beqz	a5,80003070 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000305a:	64a4                	ld	s1,72(s1)
    8000305c:	fee49de3          	bne	s1,a4,80003056 <bread+0x86>
  panic("bget: no buffers");
    80003060:	00006517          	auipc	a0,0x6
    80003064:	84050513          	addi	a0,a0,-1984 # 800088a0 <syscalls_name+0xd0>
    80003068:	ffffd097          	auipc	ra,0xffffd
    8000306c:	504080e7          	jalr	1284(ra) # 8000056c <panic>
      b->dev = dev;
    80003070:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80003074:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003078:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000307c:	4785                	li	a5,1
    8000307e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003080:	00014517          	auipc	a0,0x14
    80003084:	ea850513          	addi	a0,a0,-344 # 80016f28 <bcache>
    80003088:	ffffe097          	auipc	ra,0xffffe
    8000308c:	c3e080e7          	jalr	-962(ra) # 80000cc6 <release>
      acquiresleep(&b->lock);
    80003090:	01048513          	addi	a0,s1,16
    80003094:	00001097          	auipc	ra,0x1
    80003098:	410080e7          	jalr	1040(ra) # 800044a4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000309c:	409c                	lw	a5,0(s1)
    8000309e:	cb89                	beqz	a5,800030b0 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800030a0:	8526                	mv	a0,s1
    800030a2:	70a2                	ld	ra,40(sp)
    800030a4:	7402                	ld	s0,32(sp)
    800030a6:	64e2                	ld	s1,24(sp)
    800030a8:	6942                	ld	s2,16(sp)
    800030aa:	69a2                	ld	s3,8(sp)
    800030ac:	6145                	addi	sp,sp,48
    800030ae:	8082                	ret
    virtio_disk_rw(b, 0);
    800030b0:	4581                	li	a1,0
    800030b2:	8526                	mv	a0,s1
    800030b4:	00003097          	auipc	ra,0x3
    800030b8:	fc4080e7          	jalr	-60(ra) # 80006078 <virtio_disk_rw>
    b->valid = 1;
    800030bc:	4785                	li	a5,1
    800030be:	c09c                	sw	a5,0(s1)
  return b;
    800030c0:	b7c5                	j	800030a0 <bread+0xd0>

00000000800030c2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800030c2:	1101                	addi	sp,sp,-32
    800030c4:	ec06                	sd	ra,24(sp)
    800030c6:	e822                	sd	s0,16(sp)
    800030c8:	e426                	sd	s1,8(sp)
    800030ca:	1000                	addi	s0,sp,32
    800030cc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030ce:	0541                	addi	a0,a0,16
    800030d0:	00001097          	auipc	ra,0x1
    800030d4:	46e080e7          	jalr	1134(ra) # 8000453e <holdingsleep>
    800030d8:	cd01                	beqz	a0,800030f0 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800030da:	4585                	li	a1,1
    800030dc:	8526                	mv	a0,s1
    800030de:	00003097          	auipc	ra,0x3
    800030e2:	f9a080e7          	jalr	-102(ra) # 80006078 <virtio_disk_rw>
}
    800030e6:	60e2                	ld	ra,24(sp)
    800030e8:	6442                	ld	s0,16(sp)
    800030ea:	64a2                	ld	s1,8(sp)
    800030ec:	6105                	addi	sp,sp,32
    800030ee:	8082                	ret
    panic("bwrite");
    800030f0:	00005517          	auipc	a0,0x5
    800030f4:	7c850513          	addi	a0,a0,1992 # 800088b8 <syscalls_name+0xe8>
    800030f8:	ffffd097          	auipc	ra,0xffffd
    800030fc:	474080e7          	jalr	1140(ra) # 8000056c <panic>

0000000080003100 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003100:	1101                	addi	sp,sp,-32
    80003102:	ec06                	sd	ra,24(sp)
    80003104:	e822                	sd	s0,16(sp)
    80003106:	e426                	sd	s1,8(sp)
    80003108:	e04a                	sd	s2,0(sp)
    8000310a:	1000                	addi	s0,sp,32
    8000310c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000310e:	01050913          	addi	s2,a0,16
    80003112:	854a                	mv	a0,s2
    80003114:	00001097          	auipc	ra,0x1
    80003118:	42a080e7          	jalr	1066(ra) # 8000453e <holdingsleep>
    8000311c:	c92d                	beqz	a0,8000318e <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000311e:	854a                	mv	a0,s2
    80003120:	00001097          	auipc	ra,0x1
    80003124:	3da080e7          	jalr	986(ra) # 800044fa <releasesleep>

  acquire(&bcache.lock);
    80003128:	00014517          	auipc	a0,0x14
    8000312c:	e0050513          	addi	a0,a0,-512 # 80016f28 <bcache>
    80003130:	ffffe097          	auipc	ra,0xffffe
    80003134:	ae2080e7          	jalr	-1310(ra) # 80000c12 <acquire>
  b->refcnt--;
    80003138:	40bc                	lw	a5,64(s1)
    8000313a:	37fd                	addiw	a5,a5,-1
    8000313c:	0007871b          	sext.w	a4,a5
    80003140:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003142:	eb05                	bnez	a4,80003172 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003144:	68bc                	ld	a5,80(s1)
    80003146:	64b8                	ld	a4,72(s1)
    80003148:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000314a:	64bc                	ld	a5,72(s1)
    8000314c:	68b8                	ld	a4,80(s1)
    8000314e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003150:	0001c797          	auipc	a5,0x1c
    80003154:	dd878793          	addi	a5,a5,-552 # 8001ef28 <bcache+0x8000>
    80003158:	2b87b703          	ld	a4,696(a5)
    8000315c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000315e:	0001c717          	auipc	a4,0x1c
    80003162:	03270713          	addi	a4,a4,50 # 8001f190 <bcache+0x8268>
    80003166:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003168:	2b87b703          	ld	a4,696(a5)
    8000316c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000316e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003172:	00014517          	auipc	a0,0x14
    80003176:	db650513          	addi	a0,a0,-586 # 80016f28 <bcache>
    8000317a:	ffffe097          	auipc	ra,0xffffe
    8000317e:	b4c080e7          	jalr	-1204(ra) # 80000cc6 <release>
}
    80003182:	60e2                	ld	ra,24(sp)
    80003184:	6442                	ld	s0,16(sp)
    80003186:	64a2                	ld	s1,8(sp)
    80003188:	6902                	ld	s2,0(sp)
    8000318a:	6105                	addi	sp,sp,32
    8000318c:	8082                	ret
    panic("brelse");
    8000318e:	00005517          	auipc	a0,0x5
    80003192:	73250513          	addi	a0,a0,1842 # 800088c0 <syscalls_name+0xf0>
    80003196:	ffffd097          	auipc	ra,0xffffd
    8000319a:	3d6080e7          	jalr	982(ra) # 8000056c <panic>

000000008000319e <bpin>:

void
bpin(struct buf *b) {
    8000319e:	1101                	addi	sp,sp,-32
    800031a0:	ec06                	sd	ra,24(sp)
    800031a2:	e822                	sd	s0,16(sp)
    800031a4:	e426                	sd	s1,8(sp)
    800031a6:	1000                	addi	s0,sp,32
    800031a8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031aa:	00014517          	auipc	a0,0x14
    800031ae:	d7e50513          	addi	a0,a0,-642 # 80016f28 <bcache>
    800031b2:	ffffe097          	auipc	ra,0xffffe
    800031b6:	a60080e7          	jalr	-1440(ra) # 80000c12 <acquire>
  b->refcnt++;
    800031ba:	40bc                	lw	a5,64(s1)
    800031bc:	2785                	addiw	a5,a5,1
    800031be:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031c0:	00014517          	auipc	a0,0x14
    800031c4:	d6850513          	addi	a0,a0,-664 # 80016f28 <bcache>
    800031c8:	ffffe097          	auipc	ra,0xffffe
    800031cc:	afe080e7          	jalr	-1282(ra) # 80000cc6 <release>
}
    800031d0:	60e2                	ld	ra,24(sp)
    800031d2:	6442                	ld	s0,16(sp)
    800031d4:	64a2                	ld	s1,8(sp)
    800031d6:	6105                	addi	sp,sp,32
    800031d8:	8082                	ret

00000000800031da <bunpin>:

void
bunpin(struct buf *b) {
    800031da:	1101                	addi	sp,sp,-32
    800031dc:	ec06                	sd	ra,24(sp)
    800031de:	e822                	sd	s0,16(sp)
    800031e0:	e426                	sd	s1,8(sp)
    800031e2:	1000                	addi	s0,sp,32
    800031e4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031e6:	00014517          	auipc	a0,0x14
    800031ea:	d4250513          	addi	a0,a0,-702 # 80016f28 <bcache>
    800031ee:	ffffe097          	auipc	ra,0xffffe
    800031f2:	a24080e7          	jalr	-1500(ra) # 80000c12 <acquire>
  b->refcnt--;
    800031f6:	40bc                	lw	a5,64(s1)
    800031f8:	37fd                	addiw	a5,a5,-1
    800031fa:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031fc:	00014517          	auipc	a0,0x14
    80003200:	d2c50513          	addi	a0,a0,-724 # 80016f28 <bcache>
    80003204:	ffffe097          	auipc	ra,0xffffe
    80003208:	ac2080e7          	jalr	-1342(ra) # 80000cc6 <release>
}
    8000320c:	60e2                	ld	ra,24(sp)
    8000320e:	6442                	ld	s0,16(sp)
    80003210:	64a2                	ld	s1,8(sp)
    80003212:	6105                	addi	sp,sp,32
    80003214:	8082                	ret

0000000080003216 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003216:	1101                	addi	sp,sp,-32
    80003218:	ec06                	sd	ra,24(sp)
    8000321a:	e822                	sd	s0,16(sp)
    8000321c:	e426                	sd	s1,8(sp)
    8000321e:	e04a                	sd	s2,0(sp)
    80003220:	1000                	addi	s0,sp,32
    80003222:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003224:	00d5d59b          	srliw	a1,a1,0xd
    80003228:	0001c797          	auipc	a5,0x1c
    8000322c:	3dc7a783          	lw	a5,988(a5) # 8001f604 <sb+0x1c>
    80003230:	9dbd                	addw	a1,a1,a5
    80003232:	00000097          	auipc	ra,0x0
    80003236:	d9e080e7          	jalr	-610(ra) # 80002fd0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000323a:	0074f713          	andi	a4,s1,7
    8000323e:	4785                	li	a5,1
    80003240:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003244:	14ce                	slli	s1,s1,0x33
    80003246:	90d9                	srli	s1,s1,0x36
    80003248:	00950733          	add	a4,a0,s1
    8000324c:	05874703          	lbu	a4,88(a4)
    80003250:	00e7f6b3          	and	a3,a5,a4
    80003254:	c69d                	beqz	a3,80003282 <bfree+0x6c>
    80003256:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003258:	94aa                	add	s1,s1,a0
    8000325a:	fff7c793          	not	a5,a5
    8000325e:	8ff9                	and	a5,a5,a4
    80003260:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003264:	00001097          	auipc	ra,0x1
    80003268:	120080e7          	jalr	288(ra) # 80004384 <log_write>
  brelse(bp);
    8000326c:	854a                	mv	a0,s2
    8000326e:	00000097          	auipc	ra,0x0
    80003272:	e92080e7          	jalr	-366(ra) # 80003100 <brelse>
}
    80003276:	60e2                	ld	ra,24(sp)
    80003278:	6442                	ld	s0,16(sp)
    8000327a:	64a2                	ld	s1,8(sp)
    8000327c:	6902                	ld	s2,0(sp)
    8000327e:	6105                	addi	sp,sp,32
    80003280:	8082                	ret
    panic("freeing free block");
    80003282:	00005517          	auipc	a0,0x5
    80003286:	64650513          	addi	a0,a0,1606 # 800088c8 <syscalls_name+0xf8>
    8000328a:	ffffd097          	auipc	ra,0xffffd
    8000328e:	2e2080e7          	jalr	738(ra) # 8000056c <panic>

0000000080003292 <balloc>:
{
    80003292:	711d                	addi	sp,sp,-96
    80003294:	ec86                	sd	ra,88(sp)
    80003296:	e8a2                	sd	s0,80(sp)
    80003298:	e4a6                	sd	s1,72(sp)
    8000329a:	e0ca                	sd	s2,64(sp)
    8000329c:	fc4e                	sd	s3,56(sp)
    8000329e:	f852                	sd	s4,48(sp)
    800032a0:	f456                	sd	s5,40(sp)
    800032a2:	f05a                	sd	s6,32(sp)
    800032a4:	ec5e                	sd	s7,24(sp)
    800032a6:	e862                	sd	s8,16(sp)
    800032a8:	e466                	sd	s9,8(sp)
    800032aa:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800032ac:	0001c797          	auipc	a5,0x1c
    800032b0:	3407a783          	lw	a5,832(a5) # 8001f5ec <sb+0x4>
    800032b4:	10078163          	beqz	a5,800033b6 <balloc+0x124>
    800032b8:	8baa                	mv	s7,a0
    800032ba:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800032bc:	0001cb17          	auipc	s6,0x1c
    800032c0:	32cb0b13          	addi	s6,s6,812 # 8001f5e8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032c4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800032c6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032c8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800032ca:	6c89                	lui	s9,0x2
    800032cc:	a061                	j	80003354 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800032ce:	974a                	add	a4,a4,s2
    800032d0:	8fd5                	or	a5,a5,a3
    800032d2:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800032d6:	854a                	mv	a0,s2
    800032d8:	00001097          	auipc	ra,0x1
    800032dc:	0ac080e7          	jalr	172(ra) # 80004384 <log_write>
        brelse(bp);
    800032e0:	854a                	mv	a0,s2
    800032e2:	00000097          	auipc	ra,0x0
    800032e6:	e1e080e7          	jalr	-482(ra) # 80003100 <brelse>
  bp = bread(dev, bno);
    800032ea:	85a6                	mv	a1,s1
    800032ec:	855e                	mv	a0,s7
    800032ee:	00000097          	auipc	ra,0x0
    800032f2:	ce2080e7          	jalr	-798(ra) # 80002fd0 <bread>
    800032f6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032f8:	40000613          	li	a2,1024
    800032fc:	4581                	li	a1,0
    800032fe:	05850513          	addi	a0,a0,88
    80003302:	ffffe097          	auipc	ra,0xffffe
    80003306:	a0c080e7          	jalr	-1524(ra) # 80000d0e <memset>
  log_write(bp);
    8000330a:	854a                	mv	a0,s2
    8000330c:	00001097          	auipc	ra,0x1
    80003310:	078080e7          	jalr	120(ra) # 80004384 <log_write>
  brelse(bp);
    80003314:	854a                	mv	a0,s2
    80003316:	00000097          	auipc	ra,0x0
    8000331a:	dea080e7          	jalr	-534(ra) # 80003100 <brelse>
}
    8000331e:	8526                	mv	a0,s1
    80003320:	60e6                	ld	ra,88(sp)
    80003322:	6446                	ld	s0,80(sp)
    80003324:	64a6                	ld	s1,72(sp)
    80003326:	6906                	ld	s2,64(sp)
    80003328:	79e2                	ld	s3,56(sp)
    8000332a:	7a42                	ld	s4,48(sp)
    8000332c:	7aa2                	ld	s5,40(sp)
    8000332e:	7b02                	ld	s6,32(sp)
    80003330:	6be2                	ld	s7,24(sp)
    80003332:	6c42                	ld	s8,16(sp)
    80003334:	6ca2                	ld	s9,8(sp)
    80003336:	6125                	addi	sp,sp,96
    80003338:	8082                	ret
    brelse(bp);
    8000333a:	854a                	mv	a0,s2
    8000333c:	00000097          	auipc	ra,0x0
    80003340:	dc4080e7          	jalr	-572(ra) # 80003100 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003344:	015c87bb          	addw	a5,s9,s5
    80003348:	00078a9b          	sext.w	s5,a5
    8000334c:	004b2703          	lw	a4,4(s6)
    80003350:	06eaf363          	bgeu	s5,a4,800033b6 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003354:	41fad79b          	sraiw	a5,s5,0x1f
    80003358:	0137d79b          	srliw	a5,a5,0x13
    8000335c:	015787bb          	addw	a5,a5,s5
    80003360:	40d7d79b          	sraiw	a5,a5,0xd
    80003364:	01cb2583          	lw	a1,28(s6)
    80003368:	9dbd                	addw	a1,a1,a5
    8000336a:	855e                	mv	a0,s7
    8000336c:	00000097          	auipc	ra,0x0
    80003370:	c64080e7          	jalr	-924(ra) # 80002fd0 <bread>
    80003374:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003376:	004b2503          	lw	a0,4(s6)
    8000337a:	000a849b          	sext.w	s1,s5
    8000337e:	8662                	mv	a2,s8
    80003380:	faa4fde3          	bgeu	s1,a0,8000333a <balloc+0xa8>
      m = 1 << (bi % 8);
    80003384:	41f6579b          	sraiw	a5,a2,0x1f
    80003388:	01d7d69b          	srliw	a3,a5,0x1d
    8000338c:	00c6873b          	addw	a4,a3,a2
    80003390:	00777793          	andi	a5,a4,7
    80003394:	9f95                	subw	a5,a5,a3
    80003396:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000339a:	4037571b          	sraiw	a4,a4,0x3
    8000339e:	00e906b3          	add	a3,s2,a4
    800033a2:	0586c683          	lbu	a3,88(a3)
    800033a6:	00d7f5b3          	and	a1,a5,a3
    800033aa:	d195                	beqz	a1,800032ce <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033ac:	2605                	addiw	a2,a2,1
    800033ae:	2485                	addiw	s1,s1,1
    800033b0:	fd4618e3          	bne	a2,s4,80003380 <balloc+0xee>
    800033b4:	b759                	j	8000333a <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800033b6:	00005517          	auipc	a0,0x5
    800033ba:	52a50513          	addi	a0,a0,1322 # 800088e0 <syscalls_name+0x110>
    800033be:	ffffd097          	auipc	ra,0xffffd
    800033c2:	1f8080e7          	jalr	504(ra) # 800005b6 <printf>
  return 0;
    800033c6:	4481                	li	s1,0
    800033c8:	bf99                	j	8000331e <balloc+0x8c>

00000000800033ca <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800033ca:	7179                	addi	sp,sp,-48
    800033cc:	f406                	sd	ra,40(sp)
    800033ce:	f022                	sd	s0,32(sp)
    800033d0:	ec26                	sd	s1,24(sp)
    800033d2:	e84a                	sd	s2,16(sp)
    800033d4:	e44e                	sd	s3,8(sp)
    800033d6:	e052                	sd	s4,0(sp)
    800033d8:	1800                	addi	s0,sp,48
    800033da:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800033dc:	47ad                	li	a5,11
    800033de:	02b7e763          	bltu	a5,a1,8000340c <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800033e2:	02059493          	slli	s1,a1,0x20
    800033e6:	9081                	srli	s1,s1,0x20
    800033e8:	048a                	slli	s1,s1,0x2
    800033ea:	94aa                	add	s1,s1,a0
    800033ec:	0504a903          	lw	s2,80(s1)
    800033f0:	06091e63          	bnez	s2,8000346c <bmap+0xa2>
      addr = balloc(ip->dev);
    800033f4:	4108                	lw	a0,0(a0)
    800033f6:	00000097          	auipc	ra,0x0
    800033fa:	e9c080e7          	jalr	-356(ra) # 80003292 <balloc>
    800033fe:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003402:	06090563          	beqz	s2,8000346c <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003406:	0524a823          	sw	s2,80(s1)
    8000340a:	a08d                	j	8000346c <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000340c:	ff45849b          	addiw	s1,a1,-12
    80003410:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003414:	0ff00793          	li	a5,255
    80003418:	08e7e563          	bltu	a5,a4,800034a2 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000341c:	08052903          	lw	s2,128(a0)
    80003420:	00091d63          	bnez	s2,8000343a <bmap+0x70>
      addr = balloc(ip->dev);
    80003424:	4108                	lw	a0,0(a0)
    80003426:	00000097          	auipc	ra,0x0
    8000342a:	e6c080e7          	jalr	-404(ra) # 80003292 <balloc>
    8000342e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003432:	02090d63          	beqz	s2,8000346c <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003436:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000343a:	85ca                	mv	a1,s2
    8000343c:	0009a503          	lw	a0,0(s3)
    80003440:	00000097          	auipc	ra,0x0
    80003444:	b90080e7          	jalr	-1136(ra) # 80002fd0 <bread>
    80003448:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000344a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000344e:	02049593          	slli	a1,s1,0x20
    80003452:	9181                	srli	a1,a1,0x20
    80003454:	058a                	slli	a1,a1,0x2
    80003456:	00b784b3          	add	s1,a5,a1
    8000345a:	0004a903          	lw	s2,0(s1)
    8000345e:	02090063          	beqz	s2,8000347e <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003462:	8552                	mv	a0,s4
    80003464:	00000097          	auipc	ra,0x0
    80003468:	c9c080e7          	jalr	-868(ra) # 80003100 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000346c:	854a                	mv	a0,s2
    8000346e:	70a2                	ld	ra,40(sp)
    80003470:	7402                	ld	s0,32(sp)
    80003472:	64e2                	ld	s1,24(sp)
    80003474:	6942                	ld	s2,16(sp)
    80003476:	69a2                	ld	s3,8(sp)
    80003478:	6a02                	ld	s4,0(sp)
    8000347a:	6145                	addi	sp,sp,48
    8000347c:	8082                	ret
      addr = balloc(ip->dev);
    8000347e:	0009a503          	lw	a0,0(s3)
    80003482:	00000097          	auipc	ra,0x0
    80003486:	e10080e7          	jalr	-496(ra) # 80003292 <balloc>
    8000348a:	0005091b          	sext.w	s2,a0
      if(addr){
    8000348e:	fc090ae3          	beqz	s2,80003462 <bmap+0x98>
        a[bn] = addr;
    80003492:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003496:	8552                	mv	a0,s4
    80003498:	00001097          	auipc	ra,0x1
    8000349c:	eec080e7          	jalr	-276(ra) # 80004384 <log_write>
    800034a0:	b7c9                	j	80003462 <bmap+0x98>
  panic("bmap: out of range");
    800034a2:	00005517          	auipc	a0,0x5
    800034a6:	45650513          	addi	a0,a0,1110 # 800088f8 <syscalls_name+0x128>
    800034aa:	ffffd097          	auipc	ra,0xffffd
    800034ae:	0c2080e7          	jalr	194(ra) # 8000056c <panic>

00000000800034b2 <iget>:
{
    800034b2:	7179                	addi	sp,sp,-48
    800034b4:	f406                	sd	ra,40(sp)
    800034b6:	f022                	sd	s0,32(sp)
    800034b8:	ec26                	sd	s1,24(sp)
    800034ba:	e84a                	sd	s2,16(sp)
    800034bc:	e44e                	sd	s3,8(sp)
    800034be:	e052                	sd	s4,0(sp)
    800034c0:	1800                	addi	s0,sp,48
    800034c2:	89aa                	mv	s3,a0
    800034c4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800034c6:	0001c517          	auipc	a0,0x1c
    800034ca:	14250513          	addi	a0,a0,322 # 8001f608 <itable>
    800034ce:	ffffd097          	auipc	ra,0xffffd
    800034d2:	744080e7          	jalr	1860(ra) # 80000c12 <acquire>
  empty = 0;
    800034d6:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034d8:	0001c497          	auipc	s1,0x1c
    800034dc:	14848493          	addi	s1,s1,328 # 8001f620 <itable+0x18>
    800034e0:	0001e697          	auipc	a3,0x1e
    800034e4:	bd068693          	addi	a3,a3,-1072 # 800210b0 <log>
    800034e8:	a039                	j	800034f6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034ea:	02090b63          	beqz	s2,80003520 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034ee:	08848493          	addi	s1,s1,136
    800034f2:	02d48a63          	beq	s1,a3,80003526 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800034f6:	449c                	lw	a5,8(s1)
    800034f8:	fef059e3          	blez	a5,800034ea <iget+0x38>
    800034fc:	4098                	lw	a4,0(s1)
    800034fe:	ff3716e3          	bne	a4,s3,800034ea <iget+0x38>
    80003502:	40d8                	lw	a4,4(s1)
    80003504:	ff4713e3          	bne	a4,s4,800034ea <iget+0x38>
      ip->ref++;
    80003508:	2785                	addiw	a5,a5,1
    8000350a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000350c:	0001c517          	auipc	a0,0x1c
    80003510:	0fc50513          	addi	a0,a0,252 # 8001f608 <itable>
    80003514:	ffffd097          	auipc	ra,0xffffd
    80003518:	7b2080e7          	jalr	1970(ra) # 80000cc6 <release>
      return ip;
    8000351c:	8926                	mv	s2,s1
    8000351e:	a03d                	j	8000354c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003520:	f7f9                	bnez	a5,800034ee <iget+0x3c>
    80003522:	8926                	mv	s2,s1
    80003524:	b7e9                	j	800034ee <iget+0x3c>
  if(empty == 0)
    80003526:	02090c63          	beqz	s2,8000355e <iget+0xac>
  ip->dev = dev;
    8000352a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000352e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003532:	4785                	li	a5,1
    80003534:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003538:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000353c:	0001c517          	auipc	a0,0x1c
    80003540:	0cc50513          	addi	a0,a0,204 # 8001f608 <itable>
    80003544:	ffffd097          	auipc	ra,0xffffd
    80003548:	782080e7          	jalr	1922(ra) # 80000cc6 <release>
}
    8000354c:	854a                	mv	a0,s2
    8000354e:	70a2                	ld	ra,40(sp)
    80003550:	7402                	ld	s0,32(sp)
    80003552:	64e2                	ld	s1,24(sp)
    80003554:	6942                	ld	s2,16(sp)
    80003556:	69a2                	ld	s3,8(sp)
    80003558:	6a02                	ld	s4,0(sp)
    8000355a:	6145                	addi	sp,sp,48
    8000355c:	8082                	ret
    panic("iget: no inodes");
    8000355e:	00005517          	auipc	a0,0x5
    80003562:	3b250513          	addi	a0,a0,946 # 80008910 <syscalls_name+0x140>
    80003566:	ffffd097          	auipc	ra,0xffffd
    8000356a:	006080e7          	jalr	6(ra) # 8000056c <panic>

000000008000356e <fsinit>:
fsinit(int dev) {
    8000356e:	7179                	addi	sp,sp,-48
    80003570:	f406                	sd	ra,40(sp)
    80003572:	f022                	sd	s0,32(sp)
    80003574:	ec26                	sd	s1,24(sp)
    80003576:	e84a                	sd	s2,16(sp)
    80003578:	e44e                	sd	s3,8(sp)
    8000357a:	1800                	addi	s0,sp,48
    8000357c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000357e:	4585                	li	a1,1
    80003580:	00000097          	auipc	ra,0x0
    80003584:	a50080e7          	jalr	-1456(ra) # 80002fd0 <bread>
    80003588:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000358a:	0001c997          	auipc	s3,0x1c
    8000358e:	05e98993          	addi	s3,s3,94 # 8001f5e8 <sb>
    80003592:	02000613          	li	a2,32
    80003596:	05850593          	addi	a1,a0,88
    8000359a:	854e                	mv	a0,s3
    8000359c:	ffffd097          	auipc	ra,0xffffd
    800035a0:	7d2080e7          	jalr	2002(ra) # 80000d6e <memmove>
  brelse(bp);
    800035a4:	8526                	mv	a0,s1
    800035a6:	00000097          	auipc	ra,0x0
    800035aa:	b5a080e7          	jalr	-1190(ra) # 80003100 <brelse>
  if(sb.magic != FSMAGIC)
    800035ae:	0009a703          	lw	a4,0(s3)
    800035b2:	102037b7          	lui	a5,0x10203
    800035b6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800035ba:	02f71263          	bne	a4,a5,800035de <fsinit+0x70>
  initlog(dev, &sb);
    800035be:	0001c597          	auipc	a1,0x1c
    800035c2:	02a58593          	addi	a1,a1,42 # 8001f5e8 <sb>
    800035c6:	854a                	mv	a0,s2
    800035c8:	00001097          	auipc	ra,0x1
    800035cc:	b40080e7          	jalr	-1216(ra) # 80004108 <initlog>
}
    800035d0:	70a2                	ld	ra,40(sp)
    800035d2:	7402                	ld	s0,32(sp)
    800035d4:	64e2                	ld	s1,24(sp)
    800035d6:	6942                	ld	s2,16(sp)
    800035d8:	69a2                	ld	s3,8(sp)
    800035da:	6145                	addi	sp,sp,48
    800035dc:	8082                	ret
    panic("invalid file system");
    800035de:	00005517          	auipc	a0,0x5
    800035e2:	34250513          	addi	a0,a0,834 # 80008920 <syscalls_name+0x150>
    800035e6:	ffffd097          	auipc	ra,0xffffd
    800035ea:	f86080e7          	jalr	-122(ra) # 8000056c <panic>

00000000800035ee <iinit>:
{
    800035ee:	7179                	addi	sp,sp,-48
    800035f0:	f406                	sd	ra,40(sp)
    800035f2:	f022                	sd	s0,32(sp)
    800035f4:	ec26                	sd	s1,24(sp)
    800035f6:	e84a                	sd	s2,16(sp)
    800035f8:	e44e                	sd	s3,8(sp)
    800035fa:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800035fc:	00005597          	auipc	a1,0x5
    80003600:	33c58593          	addi	a1,a1,828 # 80008938 <syscalls_name+0x168>
    80003604:	0001c517          	auipc	a0,0x1c
    80003608:	00450513          	addi	a0,a0,4 # 8001f608 <itable>
    8000360c:	ffffd097          	auipc	ra,0xffffd
    80003610:	576080e7          	jalr	1398(ra) # 80000b82 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003614:	0001c497          	auipc	s1,0x1c
    80003618:	01c48493          	addi	s1,s1,28 # 8001f630 <itable+0x28>
    8000361c:	0001e997          	auipc	s3,0x1e
    80003620:	aa498993          	addi	s3,s3,-1372 # 800210c0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003624:	00005917          	auipc	s2,0x5
    80003628:	31c90913          	addi	s2,s2,796 # 80008940 <syscalls_name+0x170>
    8000362c:	85ca                	mv	a1,s2
    8000362e:	8526                	mv	a0,s1
    80003630:	00001097          	auipc	ra,0x1
    80003634:	e3a080e7          	jalr	-454(ra) # 8000446a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003638:	08848493          	addi	s1,s1,136
    8000363c:	ff3498e3          	bne	s1,s3,8000362c <iinit+0x3e>
}
    80003640:	70a2                	ld	ra,40(sp)
    80003642:	7402                	ld	s0,32(sp)
    80003644:	64e2                	ld	s1,24(sp)
    80003646:	6942                	ld	s2,16(sp)
    80003648:	69a2                	ld	s3,8(sp)
    8000364a:	6145                	addi	sp,sp,48
    8000364c:	8082                	ret

000000008000364e <ialloc>:
{
    8000364e:	715d                	addi	sp,sp,-80
    80003650:	e486                	sd	ra,72(sp)
    80003652:	e0a2                	sd	s0,64(sp)
    80003654:	fc26                	sd	s1,56(sp)
    80003656:	f84a                	sd	s2,48(sp)
    80003658:	f44e                	sd	s3,40(sp)
    8000365a:	f052                	sd	s4,32(sp)
    8000365c:	ec56                	sd	s5,24(sp)
    8000365e:	e85a                	sd	s6,16(sp)
    80003660:	e45e                	sd	s7,8(sp)
    80003662:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003664:	0001c717          	auipc	a4,0x1c
    80003668:	f9072703          	lw	a4,-112(a4) # 8001f5f4 <sb+0xc>
    8000366c:	4785                	li	a5,1
    8000366e:	04e7fa63          	bgeu	a5,a4,800036c2 <ialloc+0x74>
    80003672:	8aaa                	mv	s5,a0
    80003674:	8bae                	mv	s7,a1
    80003676:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003678:	0001ca17          	auipc	s4,0x1c
    8000367c:	f70a0a13          	addi	s4,s4,-144 # 8001f5e8 <sb>
    80003680:	00048b1b          	sext.w	s6,s1
    80003684:	0044d593          	srli	a1,s1,0x4
    80003688:	018a2783          	lw	a5,24(s4)
    8000368c:	9dbd                	addw	a1,a1,a5
    8000368e:	8556                	mv	a0,s5
    80003690:	00000097          	auipc	ra,0x0
    80003694:	940080e7          	jalr	-1728(ra) # 80002fd0 <bread>
    80003698:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000369a:	05850993          	addi	s3,a0,88
    8000369e:	00f4f793          	andi	a5,s1,15
    800036a2:	079a                	slli	a5,a5,0x6
    800036a4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800036a6:	00099783          	lh	a5,0(s3)
    800036aa:	c3a1                	beqz	a5,800036ea <ialloc+0x9c>
    brelse(bp);
    800036ac:	00000097          	auipc	ra,0x0
    800036b0:	a54080e7          	jalr	-1452(ra) # 80003100 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800036b4:	0485                	addi	s1,s1,1
    800036b6:	00ca2703          	lw	a4,12(s4)
    800036ba:	0004879b          	sext.w	a5,s1
    800036be:	fce7e1e3          	bltu	a5,a4,80003680 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800036c2:	00005517          	auipc	a0,0x5
    800036c6:	28650513          	addi	a0,a0,646 # 80008948 <syscalls_name+0x178>
    800036ca:	ffffd097          	auipc	ra,0xffffd
    800036ce:	eec080e7          	jalr	-276(ra) # 800005b6 <printf>
  return 0;
    800036d2:	4501                	li	a0,0
}
    800036d4:	60a6                	ld	ra,72(sp)
    800036d6:	6406                	ld	s0,64(sp)
    800036d8:	74e2                	ld	s1,56(sp)
    800036da:	7942                	ld	s2,48(sp)
    800036dc:	79a2                	ld	s3,40(sp)
    800036de:	7a02                	ld	s4,32(sp)
    800036e0:	6ae2                	ld	s5,24(sp)
    800036e2:	6b42                	ld	s6,16(sp)
    800036e4:	6ba2                	ld	s7,8(sp)
    800036e6:	6161                	addi	sp,sp,80
    800036e8:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800036ea:	04000613          	li	a2,64
    800036ee:	4581                	li	a1,0
    800036f0:	854e                	mv	a0,s3
    800036f2:	ffffd097          	auipc	ra,0xffffd
    800036f6:	61c080e7          	jalr	1564(ra) # 80000d0e <memset>
      dip->type = type;
    800036fa:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800036fe:	854a                	mv	a0,s2
    80003700:	00001097          	auipc	ra,0x1
    80003704:	c84080e7          	jalr	-892(ra) # 80004384 <log_write>
      brelse(bp);
    80003708:	854a                	mv	a0,s2
    8000370a:	00000097          	auipc	ra,0x0
    8000370e:	9f6080e7          	jalr	-1546(ra) # 80003100 <brelse>
      return iget(dev, inum);
    80003712:	85da                	mv	a1,s6
    80003714:	8556                	mv	a0,s5
    80003716:	00000097          	auipc	ra,0x0
    8000371a:	d9c080e7          	jalr	-612(ra) # 800034b2 <iget>
    8000371e:	bf5d                	j	800036d4 <ialloc+0x86>

0000000080003720 <iupdate>:
{
    80003720:	1101                	addi	sp,sp,-32
    80003722:	ec06                	sd	ra,24(sp)
    80003724:	e822                	sd	s0,16(sp)
    80003726:	e426                	sd	s1,8(sp)
    80003728:	e04a                	sd	s2,0(sp)
    8000372a:	1000                	addi	s0,sp,32
    8000372c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000372e:	415c                	lw	a5,4(a0)
    80003730:	0047d79b          	srliw	a5,a5,0x4
    80003734:	0001c597          	auipc	a1,0x1c
    80003738:	ecc5a583          	lw	a1,-308(a1) # 8001f600 <sb+0x18>
    8000373c:	9dbd                	addw	a1,a1,a5
    8000373e:	4108                	lw	a0,0(a0)
    80003740:	00000097          	auipc	ra,0x0
    80003744:	890080e7          	jalr	-1904(ra) # 80002fd0 <bread>
    80003748:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000374a:	05850793          	addi	a5,a0,88
    8000374e:	40c8                	lw	a0,4(s1)
    80003750:	893d                	andi	a0,a0,15
    80003752:	051a                	slli	a0,a0,0x6
    80003754:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003756:	04449703          	lh	a4,68(s1)
    8000375a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000375e:	04649703          	lh	a4,70(s1)
    80003762:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003766:	04849703          	lh	a4,72(s1)
    8000376a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000376e:	04a49703          	lh	a4,74(s1)
    80003772:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003776:	44f8                	lw	a4,76(s1)
    80003778:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000377a:	03400613          	li	a2,52
    8000377e:	05048593          	addi	a1,s1,80
    80003782:	0531                	addi	a0,a0,12
    80003784:	ffffd097          	auipc	ra,0xffffd
    80003788:	5ea080e7          	jalr	1514(ra) # 80000d6e <memmove>
  log_write(bp);
    8000378c:	854a                	mv	a0,s2
    8000378e:	00001097          	auipc	ra,0x1
    80003792:	bf6080e7          	jalr	-1034(ra) # 80004384 <log_write>
  brelse(bp);
    80003796:	854a                	mv	a0,s2
    80003798:	00000097          	auipc	ra,0x0
    8000379c:	968080e7          	jalr	-1688(ra) # 80003100 <brelse>
}
    800037a0:	60e2                	ld	ra,24(sp)
    800037a2:	6442                	ld	s0,16(sp)
    800037a4:	64a2                	ld	s1,8(sp)
    800037a6:	6902                	ld	s2,0(sp)
    800037a8:	6105                	addi	sp,sp,32
    800037aa:	8082                	ret

00000000800037ac <idup>:
{
    800037ac:	1101                	addi	sp,sp,-32
    800037ae:	ec06                	sd	ra,24(sp)
    800037b0:	e822                	sd	s0,16(sp)
    800037b2:	e426                	sd	s1,8(sp)
    800037b4:	1000                	addi	s0,sp,32
    800037b6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800037b8:	0001c517          	auipc	a0,0x1c
    800037bc:	e5050513          	addi	a0,a0,-432 # 8001f608 <itable>
    800037c0:	ffffd097          	auipc	ra,0xffffd
    800037c4:	452080e7          	jalr	1106(ra) # 80000c12 <acquire>
  ip->ref++;
    800037c8:	449c                	lw	a5,8(s1)
    800037ca:	2785                	addiw	a5,a5,1
    800037cc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800037ce:	0001c517          	auipc	a0,0x1c
    800037d2:	e3a50513          	addi	a0,a0,-454 # 8001f608 <itable>
    800037d6:	ffffd097          	auipc	ra,0xffffd
    800037da:	4f0080e7          	jalr	1264(ra) # 80000cc6 <release>
}
    800037de:	8526                	mv	a0,s1
    800037e0:	60e2                	ld	ra,24(sp)
    800037e2:	6442                	ld	s0,16(sp)
    800037e4:	64a2                	ld	s1,8(sp)
    800037e6:	6105                	addi	sp,sp,32
    800037e8:	8082                	ret

00000000800037ea <ilock>:
{
    800037ea:	1101                	addi	sp,sp,-32
    800037ec:	ec06                	sd	ra,24(sp)
    800037ee:	e822                	sd	s0,16(sp)
    800037f0:	e426                	sd	s1,8(sp)
    800037f2:	e04a                	sd	s2,0(sp)
    800037f4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800037f6:	c115                	beqz	a0,8000381a <ilock+0x30>
    800037f8:	84aa                	mv	s1,a0
    800037fa:	451c                	lw	a5,8(a0)
    800037fc:	00f05f63          	blez	a5,8000381a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003800:	0541                	addi	a0,a0,16
    80003802:	00001097          	auipc	ra,0x1
    80003806:	ca2080e7          	jalr	-862(ra) # 800044a4 <acquiresleep>
  if(ip->valid == 0){
    8000380a:	40bc                	lw	a5,64(s1)
    8000380c:	cf99                	beqz	a5,8000382a <ilock+0x40>
}
    8000380e:	60e2                	ld	ra,24(sp)
    80003810:	6442                	ld	s0,16(sp)
    80003812:	64a2                	ld	s1,8(sp)
    80003814:	6902                	ld	s2,0(sp)
    80003816:	6105                	addi	sp,sp,32
    80003818:	8082                	ret
    panic("ilock");
    8000381a:	00005517          	auipc	a0,0x5
    8000381e:	14650513          	addi	a0,a0,326 # 80008960 <syscalls_name+0x190>
    80003822:	ffffd097          	auipc	ra,0xffffd
    80003826:	d4a080e7          	jalr	-694(ra) # 8000056c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000382a:	40dc                	lw	a5,4(s1)
    8000382c:	0047d79b          	srliw	a5,a5,0x4
    80003830:	0001c597          	auipc	a1,0x1c
    80003834:	dd05a583          	lw	a1,-560(a1) # 8001f600 <sb+0x18>
    80003838:	9dbd                	addw	a1,a1,a5
    8000383a:	4088                	lw	a0,0(s1)
    8000383c:	fffff097          	auipc	ra,0xfffff
    80003840:	794080e7          	jalr	1940(ra) # 80002fd0 <bread>
    80003844:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003846:	05850593          	addi	a1,a0,88
    8000384a:	40dc                	lw	a5,4(s1)
    8000384c:	8bbd                	andi	a5,a5,15
    8000384e:	079a                	slli	a5,a5,0x6
    80003850:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003852:	00059783          	lh	a5,0(a1)
    80003856:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000385a:	00259783          	lh	a5,2(a1)
    8000385e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003862:	00459783          	lh	a5,4(a1)
    80003866:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000386a:	00659783          	lh	a5,6(a1)
    8000386e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003872:	459c                	lw	a5,8(a1)
    80003874:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003876:	03400613          	li	a2,52
    8000387a:	05b1                	addi	a1,a1,12
    8000387c:	05048513          	addi	a0,s1,80
    80003880:	ffffd097          	auipc	ra,0xffffd
    80003884:	4ee080e7          	jalr	1262(ra) # 80000d6e <memmove>
    brelse(bp);
    80003888:	854a                	mv	a0,s2
    8000388a:	00000097          	auipc	ra,0x0
    8000388e:	876080e7          	jalr	-1930(ra) # 80003100 <brelse>
    ip->valid = 1;
    80003892:	4785                	li	a5,1
    80003894:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003896:	04449783          	lh	a5,68(s1)
    8000389a:	fbb5                	bnez	a5,8000380e <ilock+0x24>
      panic("ilock: no type");
    8000389c:	00005517          	auipc	a0,0x5
    800038a0:	0cc50513          	addi	a0,a0,204 # 80008968 <syscalls_name+0x198>
    800038a4:	ffffd097          	auipc	ra,0xffffd
    800038a8:	cc8080e7          	jalr	-824(ra) # 8000056c <panic>

00000000800038ac <iunlock>:
{
    800038ac:	1101                	addi	sp,sp,-32
    800038ae:	ec06                	sd	ra,24(sp)
    800038b0:	e822                	sd	s0,16(sp)
    800038b2:	e426                	sd	s1,8(sp)
    800038b4:	e04a                	sd	s2,0(sp)
    800038b6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800038b8:	c905                	beqz	a0,800038e8 <iunlock+0x3c>
    800038ba:	84aa                	mv	s1,a0
    800038bc:	01050913          	addi	s2,a0,16
    800038c0:	854a                	mv	a0,s2
    800038c2:	00001097          	auipc	ra,0x1
    800038c6:	c7c080e7          	jalr	-900(ra) # 8000453e <holdingsleep>
    800038ca:	cd19                	beqz	a0,800038e8 <iunlock+0x3c>
    800038cc:	449c                	lw	a5,8(s1)
    800038ce:	00f05d63          	blez	a5,800038e8 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800038d2:	854a                	mv	a0,s2
    800038d4:	00001097          	auipc	ra,0x1
    800038d8:	c26080e7          	jalr	-986(ra) # 800044fa <releasesleep>
}
    800038dc:	60e2                	ld	ra,24(sp)
    800038de:	6442                	ld	s0,16(sp)
    800038e0:	64a2                	ld	s1,8(sp)
    800038e2:	6902                	ld	s2,0(sp)
    800038e4:	6105                	addi	sp,sp,32
    800038e6:	8082                	ret
    panic("iunlock");
    800038e8:	00005517          	auipc	a0,0x5
    800038ec:	09050513          	addi	a0,a0,144 # 80008978 <syscalls_name+0x1a8>
    800038f0:	ffffd097          	auipc	ra,0xffffd
    800038f4:	c7c080e7          	jalr	-900(ra) # 8000056c <panic>

00000000800038f8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800038f8:	7179                	addi	sp,sp,-48
    800038fa:	f406                	sd	ra,40(sp)
    800038fc:	f022                	sd	s0,32(sp)
    800038fe:	ec26                	sd	s1,24(sp)
    80003900:	e84a                	sd	s2,16(sp)
    80003902:	e44e                	sd	s3,8(sp)
    80003904:	e052                	sd	s4,0(sp)
    80003906:	1800                	addi	s0,sp,48
    80003908:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000390a:	05050493          	addi	s1,a0,80
    8000390e:	08050913          	addi	s2,a0,128
    80003912:	a021                	j	8000391a <itrunc+0x22>
    80003914:	0491                	addi	s1,s1,4
    80003916:	01248d63          	beq	s1,s2,80003930 <itrunc+0x38>
    if(ip->addrs[i]){
    8000391a:	408c                	lw	a1,0(s1)
    8000391c:	dde5                	beqz	a1,80003914 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000391e:	0009a503          	lw	a0,0(s3)
    80003922:	00000097          	auipc	ra,0x0
    80003926:	8f4080e7          	jalr	-1804(ra) # 80003216 <bfree>
      ip->addrs[i] = 0;
    8000392a:	0004a023          	sw	zero,0(s1)
    8000392e:	b7dd                	j	80003914 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003930:	0809a583          	lw	a1,128(s3)
    80003934:	e185                	bnez	a1,80003954 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003936:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000393a:	854e                	mv	a0,s3
    8000393c:	00000097          	auipc	ra,0x0
    80003940:	de4080e7          	jalr	-540(ra) # 80003720 <iupdate>
}
    80003944:	70a2                	ld	ra,40(sp)
    80003946:	7402                	ld	s0,32(sp)
    80003948:	64e2                	ld	s1,24(sp)
    8000394a:	6942                	ld	s2,16(sp)
    8000394c:	69a2                	ld	s3,8(sp)
    8000394e:	6a02                	ld	s4,0(sp)
    80003950:	6145                	addi	sp,sp,48
    80003952:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003954:	0009a503          	lw	a0,0(s3)
    80003958:	fffff097          	auipc	ra,0xfffff
    8000395c:	678080e7          	jalr	1656(ra) # 80002fd0 <bread>
    80003960:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003962:	05850493          	addi	s1,a0,88
    80003966:	45850913          	addi	s2,a0,1112
    8000396a:	a811                	j	8000397e <itrunc+0x86>
        bfree(ip->dev, a[j]);
    8000396c:	0009a503          	lw	a0,0(s3)
    80003970:	00000097          	auipc	ra,0x0
    80003974:	8a6080e7          	jalr	-1882(ra) # 80003216 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003978:	0491                	addi	s1,s1,4
    8000397a:	01248563          	beq	s1,s2,80003984 <itrunc+0x8c>
      if(a[j])
    8000397e:	408c                	lw	a1,0(s1)
    80003980:	dde5                	beqz	a1,80003978 <itrunc+0x80>
    80003982:	b7ed                	j	8000396c <itrunc+0x74>
    brelse(bp);
    80003984:	8552                	mv	a0,s4
    80003986:	fffff097          	auipc	ra,0xfffff
    8000398a:	77a080e7          	jalr	1914(ra) # 80003100 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000398e:	0809a583          	lw	a1,128(s3)
    80003992:	0009a503          	lw	a0,0(s3)
    80003996:	00000097          	auipc	ra,0x0
    8000399a:	880080e7          	jalr	-1920(ra) # 80003216 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000399e:	0809a023          	sw	zero,128(s3)
    800039a2:	bf51                	j	80003936 <itrunc+0x3e>

00000000800039a4 <iput>:
{
    800039a4:	1101                	addi	sp,sp,-32
    800039a6:	ec06                	sd	ra,24(sp)
    800039a8:	e822                	sd	s0,16(sp)
    800039aa:	e426                	sd	s1,8(sp)
    800039ac:	e04a                	sd	s2,0(sp)
    800039ae:	1000                	addi	s0,sp,32
    800039b0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800039b2:	0001c517          	auipc	a0,0x1c
    800039b6:	c5650513          	addi	a0,a0,-938 # 8001f608 <itable>
    800039ba:	ffffd097          	auipc	ra,0xffffd
    800039be:	258080e7          	jalr	600(ra) # 80000c12 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039c2:	4498                	lw	a4,8(s1)
    800039c4:	4785                	li	a5,1
    800039c6:	02f70363          	beq	a4,a5,800039ec <iput+0x48>
  ip->ref--;
    800039ca:	449c                	lw	a5,8(s1)
    800039cc:	37fd                	addiw	a5,a5,-1
    800039ce:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039d0:	0001c517          	auipc	a0,0x1c
    800039d4:	c3850513          	addi	a0,a0,-968 # 8001f608 <itable>
    800039d8:	ffffd097          	auipc	ra,0xffffd
    800039dc:	2ee080e7          	jalr	750(ra) # 80000cc6 <release>
}
    800039e0:	60e2                	ld	ra,24(sp)
    800039e2:	6442                	ld	s0,16(sp)
    800039e4:	64a2                	ld	s1,8(sp)
    800039e6:	6902                	ld	s2,0(sp)
    800039e8:	6105                	addi	sp,sp,32
    800039ea:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039ec:	40bc                	lw	a5,64(s1)
    800039ee:	dff1                	beqz	a5,800039ca <iput+0x26>
    800039f0:	04a49783          	lh	a5,74(s1)
    800039f4:	fbf9                	bnez	a5,800039ca <iput+0x26>
    acquiresleep(&ip->lock);
    800039f6:	01048913          	addi	s2,s1,16
    800039fa:	854a                	mv	a0,s2
    800039fc:	00001097          	auipc	ra,0x1
    80003a00:	aa8080e7          	jalr	-1368(ra) # 800044a4 <acquiresleep>
    release(&itable.lock);
    80003a04:	0001c517          	auipc	a0,0x1c
    80003a08:	c0450513          	addi	a0,a0,-1020 # 8001f608 <itable>
    80003a0c:	ffffd097          	auipc	ra,0xffffd
    80003a10:	2ba080e7          	jalr	698(ra) # 80000cc6 <release>
    itrunc(ip);
    80003a14:	8526                	mv	a0,s1
    80003a16:	00000097          	auipc	ra,0x0
    80003a1a:	ee2080e7          	jalr	-286(ra) # 800038f8 <itrunc>
    ip->type = 0;
    80003a1e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003a22:	8526                	mv	a0,s1
    80003a24:	00000097          	auipc	ra,0x0
    80003a28:	cfc080e7          	jalr	-772(ra) # 80003720 <iupdate>
    ip->valid = 0;
    80003a2c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003a30:	854a                	mv	a0,s2
    80003a32:	00001097          	auipc	ra,0x1
    80003a36:	ac8080e7          	jalr	-1336(ra) # 800044fa <releasesleep>
    acquire(&itable.lock);
    80003a3a:	0001c517          	auipc	a0,0x1c
    80003a3e:	bce50513          	addi	a0,a0,-1074 # 8001f608 <itable>
    80003a42:	ffffd097          	auipc	ra,0xffffd
    80003a46:	1d0080e7          	jalr	464(ra) # 80000c12 <acquire>
    80003a4a:	b741                	j	800039ca <iput+0x26>

0000000080003a4c <iunlockput>:
{
    80003a4c:	1101                	addi	sp,sp,-32
    80003a4e:	ec06                	sd	ra,24(sp)
    80003a50:	e822                	sd	s0,16(sp)
    80003a52:	e426                	sd	s1,8(sp)
    80003a54:	1000                	addi	s0,sp,32
    80003a56:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a58:	00000097          	auipc	ra,0x0
    80003a5c:	e54080e7          	jalr	-428(ra) # 800038ac <iunlock>
  iput(ip);
    80003a60:	8526                	mv	a0,s1
    80003a62:	00000097          	auipc	ra,0x0
    80003a66:	f42080e7          	jalr	-190(ra) # 800039a4 <iput>
}
    80003a6a:	60e2                	ld	ra,24(sp)
    80003a6c:	6442                	ld	s0,16(sp)
    80003a6e:	64a2                	ld	s1,8(sp)
    80003a70:	6105                	addi	sp,sp,32
    80003a72:	8082                	ret

0000000080003a74 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a74:	1141                	addi	sp,sp,-16
    80003a76:	e422                	sd	s0,8(sp)
    80003a78:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a7a:	411c                	lw	a5,0(a0)
    80003a7c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a7e:	415c                	lw	a5,4(a0)
    80003a80:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a82:	04451783          	lh	a5,68(a0)
    80003a86:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a8a:	04a51783          	lh	a5,74(a0)
    80003a8e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a92:	04c56783          	lwu	a5,76(a0)
    80003a96:	e99c                	sd	a5,16(a1)
}
    80003a98:	6422                	ld	s0,8(sp)
    80003a9a:	0141                	addi	sp,sp,16
    80003a9c:	8082                	ret

0000000080003a9e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a9e:	457c                	lw	a5,76(a0)
    80003aa0:	0ed7e963          	bltu	a5,a3,80003b92 <readi+0xf4>
{
    80003aa4:	7159                	addi	sp,sp,-112
    80003aa6:	f486                	sd	ra,104(sp)
    80003aa8:	f0a2                	sd	s0,96(sp)
    80003aaa:	eca6                	sd	s1,88(sp)
    80003aac:	e8ca                	sd	s2,80(sp)
    80003aae:	e4ce                	sd	s3,72(sp)
    80003ab0:	e0d2                	sd	s4,64(sp)
    80003ab2:	fc56                	sd	s5,56(sp)
    80003ab4:	f85a                	sd	s6,48(sp)
    80003ab6:	f45e                	sd	s7,40(sp)
    80003ab8:	f062                	sd	s8,32(sp)
    80003aba:	ec66                	sd	s9,24(sp)
    80003abc:	e86a                	sd	s10,16(sp)
    80003abe:	e46e                	sd	s11,8(sp)
    80003ac0:	1880                	addi	s0,sp,112
    80003ac2:	8b2a                	mv	s6,a0
    80003ac4:	8bae                	mv	s7,a1
    80003ac6:	8a32                	mv	s4,a2
    80003ac8:	84b6                	mv	s1,a3
    80003aca:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003acc:	9f35                	addw	a4,a4,a3
    return 0;
    80003ace:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ad0:	0ad76063          	bltu	a4,a3,80003b70 <readi+0xd2>
  if(off + n > ip->size)
    80003ad4:	00e7f463          	bgeu	a5,a4,80003adc <readi+0x3e>
    n = ip->size - off;
    80003ad8:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003adc:	0a0a8963          	beqz	s5,80003b8e <readi+0xf0>
    80003ae0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ae2:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ae6:	5c7d                	li	s8,-1
    80003ae8:	a82d                	j	80003b22 <readi+0x84>
    80003aea:	020d1d93          	slli	s11,s10,0x20
    80003aee:	020ddd93          	srli	s11,s11,0x20
    80003af2:	05890613          	addi	a2,s2,88
    80003af6:	86ee                	mv	a3,s11
    80003af8:	963a                	add	a2,a2,a4
    80003afa:	85d2                	mv	a1,s4
    80003afc:	855e                	mv	a0,s7
    80003afe:	fffff097          	auipc	ra,0xfffff
    80003b02:	aa0080e7          	jalr	-1376(ra) # 8000259e <either_copyout>
    80003b06:	05850d63          	beq	a0,s8,80003b60 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003b0a:	854a                	mv	a0,s2
    80003b0c:	fffff097          	auipc	ra,0xfffff
    80003b10:	5f4080e7          	jalr	1524(ra) # 80003100 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b14:	013d09bb          	addw	s3,s10,s3
    80003b18:	009d04bb          	addw	s1,s10,s1
    80003b1c:	9a6e                	add	s4,s4,s11
    80003b1e:	0559f763          	bgeu	s3,s5,80003b6c <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003b22:	00a4d59b          	srliw	a1,s1,0xa
    80003b26:	855a                	mv	a0,s6
    80003b28:	00000097          	auipc	ra,0x0
    80003b2c:	8a2080e7          	jalr	-1886(ra) # 800033ca <bmap>
    80003b30:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003b34:	cd85                	beqz	a1,80003b6c <readi+0xce>
    bp = bread(ip->dev, addr);
    80003b36:	000b2503          	lw	a0,0(s6)
    80003b3a:	fffff097          	auipc	ra,0xfffff
    80003b3e:	496080e7          	jalr	1174(ra) # 80002fd0 <bread>
    80003b42:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b44:	3ff4f713          	andi	a4,s1,1023
    80003b48:	40ec87bb          	subw	a5,s9,a4
    80003b4c:	413a86bb          	subw	a3,s5,s3
    80003b50:	8d3e                	mv	s10,a5
    80003b52:	2781                	sext.w	a5,a5
    80003b54:	0006861b          	sext.w	a2,a3
    80003b58:	f8f679e3          	bgeu	a2,a5,80003aea <readi+0x4c>
    80003b5c:	8d36                	mv	s10,a3
    80003b5e:	b771                	j	80003aea <readi+0x4c>
      brelse(bp);
    80003b60:	854a                	mv	a0,s2
    80003b62:	fffff097          	auipc	ra,0xfffff
    80003b66:	59e080e7          	jalr	1438(ra) # 80003100 <brelse>
      tot = -1;
    80003b6a:	59fd                	li	s3,-1
  }
  return tot;
    80003b6c:	0009851b          	sext.w	a0,s3
}
    80003b70:	70a6                	ld	ra,104(sp)
    80003b72:	7406                	ld	s0,96(sp)
    80003b74:	64e6                	ld	s1,88(sp)
    80003b76:	6946                	ld	s2,80(sp)
    80003b78:	69a6                	ld	s3,72(sp)
    80003b7a:	6a06                	ld	s4,64(sp)
    80003b7c:	7ae2                	ld	s5,56(sp)
    80003b7e:	7b42                	ld	s6,48(sp)
    80003b80:	7ba2                	ld	s7,40(sp)
    80003b82:	7c02                	ld	s8,32(sp)
    80003b84:	6ce2                	ld	s9,24(sp)
    80003b86:	6d42                	ld	s10,16(sp)
    80003b88:	6da2                	ld	s11,8(sp)
    80003b8a:	6165                	addi	sp,sp,112
    80003b8c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b8e:	89d6                	mv	s3,s5
    80003b90:	bff1                	j	80003b6c <readi+0xce>
    return 0;
    80003b92:	4501                	li	a0,0
}
    80003b94:	8082                	ret

0000000080003b96 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b96:	457c                	lw	a5,76(a0)
    80003b98:	10d7e863          	bltu	a5,a3,80003ca8 <writei+0x112>
{
    80003b9c:	7159                	addi	sp,sp,-112
    80003b9e:	f486                	sd	ra,104(sp)
    80003ba0:	f0a2                	sd	s0,96(sp)
    80003ba2:	eca6                	sd	s1,88(sp)
    80003ba4:	e8ca                	sd	s2,80(sp)
    80003ba6:	e4ce                	sd	s3,72(sp)
    80003ba8:	e0d2                	sd	s4,64(sp)
    80003baa:	fc56                	sd	s5,56(sp)
    80003bac:	f85a                	sd	s6,48(sp)
    80003bae:	f45e                	sd	s7,40(sp)
    80003bb0:	f062                	sd	s8,32(sp)
    80003bb2:	ec66                	sd	s9,24(sp)
    80003bb4:	e86a                	sd	s10,16(sp)
    80003bb6:	e46e                	sd	s11,8(sp)
    80003bb8:	1880                	addi	s0,sp,112
    80003bba:	8aaa                	mv	s5,a0
    80003bbc:	8bae                	mv	s7,a1
    80003bbe:	8a32                	mv	s4,a2
    80003bc0:	8936                	mv	s2,a3
    80003bc2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003bc4:	00e687bb          	addw	a5,a3,a4
    80003bc8:	0ed7e263          	bltu	a5,a3,80003cac <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003bcc:	00043737          	lui	a4,0x43
    80003bd0:	0ef76063          	bltu	a4,a5,80003cb0 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bd4:	0c0b0863          	beqz	s6,80003ca4 <writei+0x10e>
    80003bd8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bda:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003bde:	5c7d                	li	s8,-1
    80003be0:	a091                	j	80003c24 <writei+0x8e>
    80003be2:	020d1d93          	slli	s11,s10,0x20
    80003be6:	020ddd93          	srli	s11,s11,0x20
    80003bea:	05848513          	addi	a0,s1,88
    80003bee:	86ee                	mv	a3,s11
    80003bf0:	8652                	mv	a2,s4
    80003bf2:	85de                	mv	a1,s7
    80003bf4:	953a                	add	a0,a0,a4
    80003bf6:	fffff097          	auipc	ra,0xfffff
    80003bfa:	9fe080e7          	jalr	-1538(ra) # 800025f4 <either_copyin>
    80003bfe:	07850263          	beq	a0,s8,80003c62 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c02:	8526                	mv	a0,s1
    80003c04:	00000097          	auipc	ra,0x0
    80003c08:	780080e7          	jalr	1920(ra) # 80004384 <log_write>
    brelse(bp);
    80003c0c:	8526                	mv	a0,s1
    80003c0e:	fffff097          	auipc	ra,0xfffff
    80003c12:	4f2080e7          	jalr	1266(ra) # 80003100 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c16:	013d09bb          	addw	s3,s10,s3
    80003c1a:	012d093b          	addw	s2,s10,s2
    80003c1e:	9a6e                	add	s4,s4,s11
    80003c20:	0569f663          	bgeu	s3,s6,80003c6c <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003c24:	00a9559b          	srliw	a1,s2,0xa
    80003c28:	8556                	mv	a0,s5
    80003c2a:	fffff097          	auipc	ra,0xfffff
    80003c2e:	7a0080e7          	jalr	1952(ra) # 800033ca <bmap>
    80003c32:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c36:	c99d                	beqz	a1,80003c6c <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003c38:	000aa503          	lw	a0,0(s5)
    80003c3c:	fffff097          	auipc	ra,0xfffff
    80003c40:	394080e7          	jalr	916(ra) # 80002fd0 <bread>
    80003c44:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c46:	3ff97713          	andi	a4,s2,1023
    80003c4a:	40ec87bb          	subw	a5,s9,a4
    80003c4e:	413b06bb          	subw	a3,s6,s3
    80003c52:	8d3e                	mv	s10,a5
    80003c54:	2781                	sext.w	a5,a5
    80003c56:	0006861b          	sext.w	a2,a3
    80003c5a:	f8f674e3          	bgeu	a2,a5,80003be2 <writei+0x4c>
    80003c5e:	8d36                	mv	s10,a3
    80003c60:	b749                	j	80003be2 <writei+0x4c>
      brelse(bp);
    80003c62:	8526                	mv	a0,s1
    80003c64:	fffff097          	auipc	ra,0xfffff
    80003c68:	49c080e7          	jalr	1180(ra) # 80003100 <brelse>
  }

  if(off > ip->size)
    80003c6c:	04caa783          	lw	a5,76(s5)
    80003c70:	0127f463          	bgeu	a5,s2,80003c78 <writei+0xe2>
    ip->size = off;
    80003c74:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003c78:	8556                	mv	a0,s5
    80003c7a:	00000097          	auipc	ra,0x0
    80003c7e:	aa6080e7          	jalr	-1370(ra) # 80003720 <iupdate>

  return tot;
    80003c82:	0009851b          	sext.w	a0,s3
}
    80003c86:	70a6                	ld	ra,104(sp)
    80003c88:	7406                	ld	s0,96(sp)
    80003c8a:	64e6                	ld	s1,88(sp)
    80003c8c:	6946                	ld	s2,80(sp)
    80003c8e:	69a6                	ld	s3,72(sp)
    80003c90:	6a06                	ld	s4,64(sp)
    80003c92:	7ae2                	ld	s5,56(sp)
    80003c94:	7b42                	ld	s6,48(sp)
    80003c96:	7ba2                	ld	s7,40(sp)
    80003c98:	7c02                	ld	s8,32(sp)
    80003c9a:	6ce2                	ld	s9,24(sp)
    80003c9c:	6d42                	ld	s10,16(sp)
    80003c9e:	6da2                	ld	s11,8(sp)
    80003ca0:	6165                	addi	sp,sp,112
    80003ca2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ca4:	89da                	mv	s3,s6
    80003ca6:	bfc9                	j	80003c78 <writei+0xe2>
    return -1;
    80003ca8:	557d                	li	a0,-1
}
    80003caa:	8082                	ret
    return -1;
    80003cac:	557d                	li	a0,-1
    80003cae:	bfe1                	j	80003c86 <writei+0xf0>
    return -1;
    80003cb0:	557d                	li	a0,-1
    80003cb2:	bfd1                	j	80003c86 <writei+0xf0>

0000000080003cb4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003cb4:	1141                	addi	sp,sp,-16
    80003cb6:	e406                	sd	ra,8(sp)
    80003cb8:	e022                	sd	s0,0(sp)
    80003cba:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003cbc:	4639                	li	a2,14
    80003cbe:	ffffd097          	auipc	ra,0xffffd
    80003cc2:	128080e7          	jalr	296(ra) # 80000de6 <strncmp>
}
    80003cc6:	60a2                	ld	ra,8(sp)
    80003cc8:	6402                	ld	s0,0(sp)
    80003cca:	0141                	addi	sp,sp,16
    80003ccc:	8082                	ret

0000000080003cce <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003cce:	7139                	addi	sp,sp,-64
    80003cd0:	fc06                	sd	ra,56(sp)
    80003cd2:	f822                	sd	s0,48(sp)
    80003cd4:	f426                	sd	s1,40(sp)
    80003cd6:	f04a                	sd	s2,32(sp)
    80003cd8:	ec4e                	sd	s3,24(sp)
    80003cda:	e852                	sd	s4,16(sp)
    80003cdc:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003cde:	04451703          	lh	a4,68(a0)
    80003ce2:	4785                	li	a5,1
    80003ce4:	00f71a63          	bne	a4,a5,80003cf8 <dirlookup+0x2a>
    80003ce8:	892a                	mv	s2,a0
    80003cea:	89ae                	mv	s3,a1
    80003cec:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cee:	457c                	lw	a5,76(a0)
    80003cf0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003cf2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cf4:	e79d                	bnez	a5,80003d22 <dirlookup+0x54>
    80003cf6:	a8a5                	j	80003d6e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003cf8:	00005517          	auipc	a0,0x5
    80003cfc:	c8850513          	addi	a0,a0,-888 # 80008980 <syscalls_name+0x1b0>
    80003d00:	ffffd097          	auipc	ra,0xffffd
    80003d04:	86c080e7          	jalr	-1940(ra) # 8000056c <panic>
      panic("dirlookup read");
    80003d08:	00005517          	auipc	a0,0x5
    80003d0c:	c9050513          	addi	a0,a0,-880 # 80008998 <syscalls_name+0x1c8>
    80003d10:	ffffd097          	auipc	ra,0xffffd
    80003d14:	85c080e7          	jalr	-1956(ra) # 8000056c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d18:	24c1                	addiw	s1,s1,16
    80003d1a:	04c92783          	lw	a5,76(s2)
    80003d1e:	04f4f763          	bgeu	s1,a5,80003d6c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d22:	4741                	li	a4,16
    80003d24:	86a6                	mv	a3,s1
    80003d26:	fc040613          	addi	a2,s0,-64
    80003d2a:	4581                	li	a1,0
    80003d2c:	854a                	mv	a0,s2
    80003d2e:	00000097          	auipc	ra,0x0
    80003d32:	d70080e7          	jalr	-656(ra) # 80003a9e <readi>
    80003d36:	47c1                	li	a5,16
    80003d38:	fcf518e3          	bne	a0,a5,80003d08 <dirlookup+0x3a>
    if(de.inum == 0)
    80003d3c:	fc045783          	lhu	a5,-64(s0)
    80003d40:	dfe1                	beqz	a5,80003d18 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003d42:	fc240593          	addi	a1,s0,-62
    80003d46:	854e                	mv	a0,s3
    80003d48:	00000097          	auipc	ra,0x0
    80003d4c:	f6c080e7          	jalr	-148(ra) # 80003cb4 <namecmp>
    80003d50:	f561                	bnez	a0,80003d18 <dirlookup+0x4a>
      if(poff)
    80003d52:	000a0463          	beqz	s4,80003d5a <dirlookup+0x8c>
        *poff = off;
    80003d56:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003d5a:	fc045583          	lhu	a1,-64(s0)
    80003d5e:	00092503          	lw	a0,0(s2)
    80003d62:	fffff097          	auipc	ra,0xfffff
    80003d66:	750080e7          	jalr	1872(ra) # 800034b2 <iget>
    80003d6a:	a011                	j	80003d6e <dirlookup+0xa0>
  return 0;
    80003d6c:	4501                	li	a0,0
}
    80003d6e:	70e2                	ld	ra,56(sp)
    80003d70:	7442                	ld	s0,48(sp)
    80003d72:	74a2                	ld	s1,40(sp)
    80003d74:	7902                	ld	s2,32(sp)
    80003d76:	69e2                	ld	s3,24(sp)
    80003d78:	6a42                	ld	s4,16(sp)
    80003d7a:	6121                	addi	sp,sp,64
    80003d7c:	8082                	ret

0000000080003d7e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d7e:	711d                	addi	sp,sp,-96
    80003d80:	ec86                	sd	ra,88(sp)
    80003d82:	e8a2                	sd	s0,80(sp)
    80003d84:	e4a6                	sd	s1,72(sp)
    80003d86:	e0ca                	sd	s2,64(sp)
    80003d88:	fc4e                	sd	s3,56(sp)
    80003d8a:	f852                	sd	s4,48(sp)
    80003d8c:	f456                	sd	s5,40(sp)
    80003d8e:	f05a                	sd	s6,32(sp)
    80003d90:	ec5e                	sd	s7,24(sp)
    80003d92:	e862                	sd	s8,16(sp)
    80003d94:	e466                	sd	s9,8(sp)
    80003d96:	1080                	addi	s0,sp,96
    80003d98:	84aa                	mv	s1,a0
    80003d9a:	8b2e                	mv	s6,a1
    80003d9c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d9e:	00054703          	lbu	a4,0(a0)
    80003da2:	02f00793          	li	a5,47
    80003da6:	02f70363          	beq	a4,a5,80003dcc <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003daa:	ffffe097          	auipc	ra,0xffffe
    80003dae:	c60080e7          	jalr	-928(ra) # 80001a0a <myproc>
    80003db2:	15853503          	ld	a0,344(a0)
    80003db6:	00000097          	auipc	ra,0x0
    80003dba:	9f6080e7          	jalr	-1546(ra) # 800037ac <idup>
    80003dbe:	89aa                	mv	s3,a0
  while(*path == '/')
    80003dc0:	02f00913          	li	s2,47
  len = path - s;
    80003dc4:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003dc6:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003dc8:	4c05                	li	s8,1
    80003dca:	a865                	j	80003e82 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003dcc:	4585                	li	a1,1
    80003dce:	4505                	li	a0,1
    80003dd0:	fffff097          	auipc	ra,0xfffff
    80003dd4:	6e2080e7          	jalr	1762(ra) # 800034b2 <iget>
    80003dd8:	89aa                	mv	s3,a0
    80003dda:	b7dd                	j	80003dc0 <namex+0x42>
      iunlockput(ip);
    80003ddc:	854e                	mv	a0,s3
    80003dde:	00000097          	auipc	ra,0x0
    80003de2:	c6e080e7          	jalr	-914(ra) # 80003a4c <iunlockput>
      return 0;
    80003de6:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003de8:	854e                	mv	a0,s3
    80003dea:	60e6                	ld	ra,88(sp)
    80003dec:	6446                	ld	s0,80(sp)
    80003dee:	64a6                	ld	s1,72(sp)
    80003df0:	6906                	ld	s2,64(sp)
    80003df2:	79e2                	ld	s3,56(sp)
    80003df4:	7a42                	ld	s4,48(sp)
    80003df6:	7aa2                	ld	s5,40(sp)
    80003df8:	7b02                	ld	s6,32(sp)
    80003dfa:	6be2                	ld	s7,24(sp)
    80003dfc:	6c42                	ld	s8,16(sp)
    80003dfe:	6ca2                	ld	s9,8(sp)
    80003e00:	6125                	addi	sp,sp,96
    80003e02:	8082                	ret
      iunlock(ip);
    80003e04:	854e                	mv	a0,s3
    80003e06:	00000097          	auipc	ra,0x0
    80003e0a:	aa6080e7          	jalr	-1370(ra) # 800038ac <iunlock>
      return ip;
    80003e0e:	bfe9                	j	80003de8 <namex+0x6a>
      iunlockput(ip);
    80003e10:	854e                	mv	a0,s3
    80003e12:	00000097          	auipc	ra,0x0
    80003e16:	c3a080e7          	jalr	-966(ra) # 80003a4c <iunlockput>
      return 0;
    80003e1a:	89d2                	mv	s3,s4
    80003e1c:	b7f1                	j	80003de8 <namex+0x6a>
  len = path - s;
    80003e1e:	40b48633          	sub	a2,s1,a1
    80003e22:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003e26:	094cd463          	bge	s9,s4,80003eae <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003e2a:	4639                	li	a2,14
    80003e2c:	8556                	mv	a0,s5
    80003e2e:	ffffd097          	auipc	ra,0xffffd
    80003e32:	f40080e7          	jalr	-192(ra) # 80000d6e <memmove>
  while(*path == '/')
    80003e36:	0004c783          	lbu	a5,0(s1)
    80003e3a:	01279763          	bne	a5,s2,80003e48 <namex+0xca>
    path++;
    80003e3e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e40:	0004c783          	lbu	a5,0(s1)
    80003e44:	ff278de3          	beq	a5,s2,80003e3e <namex+0xc0>
    ilock(ip);
    80003e48:	854e                	mv	a0,s3
    80003e4a:	00000097          	auipc	ra,0x0
    80003e4e:	9a0080e7          	jalr	-1632(ra) # 800037ea <ilock>
    if(ip->type != T_DIR){
    80003e52:	04499783          	lh	a5,68(s3)
    80003e56:	f98793e3          	bne	a5,s8,80003ddc <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003e5a:	000b0563          	beqz	s6,80003e64 <namex+0xe6>
    80003e5e:	0004c783          	lbu	a5,0(s1)
    80003e62:	d3cd                	beqz	a5,80003e04 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e64:	865e                	mv	a2,s7
    80003e66:	85d6                	mv	a1,s5
    80003e68:	854e                	mv	a0,s3
    80003e6a:	00000097          	auipc	ra,0x0
    80003e6e:	e64080e7          	jalr	-412(ra) # 80003cce <dirlookup>
    80003e72:	8a2a                	mv	s4,a0
    80003e74:	dd51                	beqz	a0,80003e10 <namex+0x92>
    iunlockput(ip);
    80003e76:	854e                	mv	a0,s3
    80003e78:	00000097          	auipc	ra,0x0
    80003e7c:	bd4080e7          	jalr	-1068(ra) # 80003a4c <iunlockput>
    ip = next;
    80003e80:	89d2                	mv	s3,s4
  while(*path == '/')
    80003e82:	0004c783          	lbu	a5,0(s1)
    80003e86:	05279763          	bne	a5,s2,80003ed4 <namex+0x156>
    path++;
    80003e8a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e8c:	0004c783          	lbu	a5,0(s1)
    80003e90:	ff278de3          	beq	a5,s2,80003e8a <namex+0x10c>
  if(*path == 0)
    80003e94:	c79d                	beqz	a5,80003ec2 <namex+0x144>
    path++;
    80003e96:	85a6                	mv	a1,s1
  len = path - s;
    80003e98:	8a5e                	mv	s4,s7
    80003e9a:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003e9c:	01278963          	beq	a5,s2,80003eae <namex+0x130>
    80003ea0:	dfbd                	beqz	a5,80003e1e <namex+0xa0>
    path++;
    80003ea2:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003ea4:	0004c783          	lbu	a5,0(s1)
    80003ea8:	ff279ce3          	bne	a5,s2,80003ea0 <namex+0x122>
    80003eac:	bf8d                	j	80003e1e <namex+0xa0>
    memmove(name, s, len);
    80003eae:	2601                	sext.w	a2,a2
    80003eb0:	8556                	mv	a0,s5
    80003eb2:	ffffd097          	auipc	ra,0xffffd
    80003eb6:	ebc080e7          	jalr	-324(ra) # 80000d6e <memmove>
    name[len] = 0;
    80003eba:	9a56                	add	s4,s4,s5
    80003ebc:	000a0023          	sb	zero,0(s4)
    80003ec0:	bf9d                	j	80003e36 <namex+0xb8>
  if(nameiparent){
    80003ec2:	f20b03e3          	beqz	s6,80003de8 <namex+0x6a>
    iput(ip);
    80003ec6:	854e                	mv	a0,s3
    80003ec8:	00000097          	auipc	ra,0x0
    80003ecc:	adc080e7          	jalr	-1316(ra) # 800039a4 <iput>
    return 0;
    80003ed0:	4981                	li	s3,0
    80003ed2:	bf19                	j	80003de8 <namex+0x6a>
  if(*path == 0)
    80003ed4:	d7fd                	beqz	a5,80003ec2 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003ed6:	0004c783          	lbu	a5,0(s1)
    80003eda:	85a6                	mv	a1,s1
    80003edc:	b7d1                	j	80003ea0 <namex+0x122>

0000000080003ede <dirlink>:
{
    80003ede:	7139                	addi	sp,sp,-64
    80003ee0:	fc06                	sd	ra,56(sp)
    80003ee2:	f822                	sd	s0,48(sp)
    80003ee4:	f426                	sd	s1,40(sp)
    80003ee6:	f04a                	sd	s2,32(sp)
    80003ee8:	ec4e                	sd	s3,24(sp)
    80003eea:	e852                	sd	s4,16(sp)
    80003eec:	0080                	addi	s0,sp,64
    80003eee:	892a                	mv	s2,a0
    80003ef0:	8a2e                	mv	s4,a1
    80003ef2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ef4:	4601                	li	a2,0
    80003ef6:	00000097          	auipc	ra,0x0
    80003efa:	dd8080e7          	jalr	-552(ra) # 80003cce <dirlookup>
    80003efe:	e93d                	bnez	a0,80003f74 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f00:	04c92483          	lw	s1,76(s2)
    80003f04:	c49d                	beqz	s1,80003f32 <dirlink+0x54>
    80003f06:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f08:	4741                	li	a4,16
    80003f0a:	86a6                	mv	a3,s1
    80003f0c:	fc040613          	addi	a2,s0,-64
    80003f10:	4581                	li	a1,0
    80003f12:	854a                	mv	a0,s2
    80003f14:	00000097          	auipc	ra,0x0
    80003f18:	b8a080e7          	jalr	-1142(ra) # 80003a9e <readi>
    80003f1c:	47c1                	li	a5,16
    80003f1e:	06f51163          	bne	a0,a5,80003f80 <dirlink+0xa2>
    if(de.inum == 0)
    80003f22:	fc045783          	lhu	a5,-64(s0)
    80003f26:	c791                	beqz	a5,80003f32 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f28:	24c1                	addiw	s1,s1,16
    80003f2a:	04c92783          	lw	a5,76(s2)
    80003f2e:	fcf4ede3          	bltu	s1,a5,80003f08 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003f32:	4639                	li	a2,14
    80003f34:	85d2                	mv	a1,s4
    80003f36:	fc240513          	addi	a0,s0,-62
    80003f3a:	ffffd097          	auipc	ra,0xffffd
    80003f3e:	ee8080e7          	jalr	-280(ra) # 80000e22 <strncpy>
  de.inum = inum;
    80003f42:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f46:	4741                	li	a4,16
    80003f48:	86a6                	mv	a3,s1
    80003f4a:	fc040613          	addi	a2,s0,-64
    80003f4e:	4581                	li	a1,0
    80003f50:	854a                	mv	a0,s2
    80003f52:	00000097          	auipc	ra,0x0
    80003f56:	c44080e7          	jalr	-956(ra) # 80003b96 <writei>
    80003f5a:	1541                	addi	a0,a0,-16
    80003f5c:	00a03533          	snez	a0,a0
    80003f60:	40a00533          	neg	a0,a0
}
    80003f64:	70e2                	ld	ra,56(sp)
    80003f66:	7442                	ld	s0,48(sp)
    80003f68:	74a2                	ld	s1,40(sp)
    80003f6a:	7902                	ld	s2,32(sp)
    80003f6c:	69e2                	ld	s3,24(sp)
    80003f6e:	6a42                	ld	s4,16(sp)
    80003f70:	6121                	addi	sp,sp,64
    80003f72:	8082                	ret
    iput(ip);
    80003f74:	00000097          	auipc	ra,0x0
    80003f78:	a30080e7          	jalr	-1488(ra) # 800039a4 <iput>
    return -1;
    80003f7c:	557d                	li	a0,-1
    80003f7e:	b7dd                	j	80003f64 <dirlink+0x86>
      panic("dirlink read");
    80003f80:	00005517          	auipc	a0,0x5
    80003f84:	a2850513          	addi	a0,a0,-1496 # 800089a8 <syscalls_name+0x1d8>
    80003f88:	ffffc097          	auipc	ra,0xffffc
    80003f8c:	5e4080e7          	jalr	1508(ra) # 8000056c <panic>

0000000080003f90 <namei>:

struct inode*
namei(char *path)
{
    80003f90:	1101                	addi	sp,sp,-32
    80003f92:	ec06                	sd	ra,24(sp)
    80003f94:	e822                	sd	s0,16(sp)
    80003f96:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f98:	fe040613          	addi	a2,s0,-32
    80003f9c:	4581                	li	a1,0
    80003f9e:	00000097          	auipc	ra,0x0
    80003fa2:	de0080e7          	jalr	-544(ra) # 80003d7e <namex>
}
    80003fa6:	60e2                	ld	ra,24(sp)
    80003fa8:	6442                	ld	s0,16(sp)
    80003faa:	6105                	addi	sp,sp,32
    80003fac:	8082                	ret

0000000080003fae <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003fae:	1141                	addi	sp,sp,-16
    80003fb0:	e406                	sd	ra,8(sp)
    80003fb2:	e022                	sd	s0,0(sp)
    80003fb4:	0800                	addi	s0,sp,16
    80003fb6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003fb8:	4585                	li	a1,1
    80003fba:	00000097          	auipc	ra,0x0
    80003fbe:	dc4080e7          	jalr	-572(ra) # 80003d7e <namex>
}
    80003fc2:	60a2                	ld	ra,8(sp)
    80003fc4:	6402                	ld	s0,0(sp)
    80003fc6:	0141                	addi	sp,sp,16
    80003fc8:	8082                	ret

0000000080003fca <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003fca:	1101                	addi	sp,sp,-32
    80003fcc:	ec06                	sd	ra,24(sp)
    80003fce:	e822                	sd	s0,16(sp)
    80003fd0:	e426                	sd	s1,8(sp)
    80003fd2:	e04a                	sd	s2,0(sp)
    80003fd4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003fd6:	0001d917          	auipc	s2,0x1d
    80003fda:	0da90913          	addi	s2,s2,218 # 800210b0 <log>
    80003fde:	01892583          	lw	a1,24(s2)
    80003fe2:	02892503          	lw	a0,40(s2)
    80003fe6:	fffff097          	auipc	ra,0xfffff
    80003fea:	fea080e7          	jalr	-22(ra) # 80002fd0 <bread>
    80003fee:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003ff0:	02c92683          	lw	a3,44(s2)
    80003ff4:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003ff6:	02d05763          	blez	a3,80004024 <write_head+0x5a>
    80003ffa:	0001d797          	auipc	a5,0x1d
    80003ffe:	0e678793          	addi	a5,a5,230 # 800210e0 <log+0x30>
    80004002:	05c50713          	addi	a4,a0,92
    80004006:	36fd                	addiw	a3,a3,-1
    80004008:	1682                	slli	a3,a3,0x20
    8000400a:	9281                	srli	a3,a3,0x20
    8000400c:	068a                	slli	a3,a3,0x2
    8000400e:	0001d617          	auipc	a2,0x1d
    80004012:	0d660613          	addi	a2,a2,214 # 800210e4 <log+0x34>
    80004016:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004018:	4390                	lw	a2,0(a5)
    8000401a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000401c:	0791                	addi	a5,a5,4
    8000401e:	0711                	addi	a4,a4,4
    80004020:	fed79ce3          	bne	a5,a3,80004018 <write_head+0x4e>
  }
  bwrite(buf);
    80004024:	8526                	mv	a0,s1
    80004026:	fffff097          	auipc	ra,0xfffff
    8000402a:	09c080e7          	jalr	156(ra) # 800030c2 <bwrite>
  brelse(buf);
    8000402e:	8526                	mv	a0,s1
    80004030:	fffff097          	auipc	ra,0xfffff
    80004034:	0d0080e7          	jalr	208(ra) # 80003100 <brelse>
}
    80004038:	60e2                	ld	ra,24(sp)
    8000403a:	6442                	ld	s0,16(sp)
    8000403c:	64a2                	ld	s1,8(sp)
    8000403e:	6902                	ld	s2,0(sp)
    80004040:	6105                	addi	sp,sp,32
    80004042:	8082                	ret

0000000080004044 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004044:	0001d797          	auipc	a5,0x1d
    80004048:	0987a783          	lw	a5,152(a5) # 800210dc <log+0x2c>
    8000404c:	0af05d63          	blez	a5,80004106 <install_trans+0xc2>
{
    80004050:	7139                	addi	sp,sp,-64
    80004052:	fc06                	sd	ra,56(sp)
    80004054:	f822                	sd	s0,48(sp)
    80004056:	f426                	sd	s1,40(sp)
    80004058:	f04a                	sd	s2,32(sp)
    8000405a:	ec4e                	sd	s3,24(sp)
    8000405c:	e852                	sd	s4,16(sp)
    8000405e:	e456                	sd	s5,8(sp)
    80004060:	e05a                	sd	s6,0(sp)
    80004062:	0080                	addi	s0,sp,64
    80004064:	8b2a                	mv	s6,a0
    80004066:	0001da97          	auipc	s5,0x1d
    8000406a:	07aa8a93          	addi	s5,s5,122 # 800210e0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000406e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004070:	0001d997          	auipc	s3,0x1d
    80004074:	04098993          	addi	s3,s3,64 # 800210b0 <log>
    80004078:	a035                	j	800040a4 <install_trans+0x60>
      bunpin(dbuf);
    8000407a:	8526                	mv	a0,s1
    8000407c:	fffff097          	auipc	ra,0xfffff
    80004080:	15e080e7          	jalr	350(ra) # 800031da <bunpin>
    brelse(lbuf);
    80004084:	854a                	mv	a0,s2
    80004086:	fffff097          	auipc	ra,0xfffff
    8000408a:	07a080e7          	jalr	122(ra) # 80003100 <brelse>
    brelse(dbuf);
    8000408e:	8526                	mv	a0,s1
    80004090:	fffff097          	auipc	ra,0xfffff
    80004094:	070080e7          	jalr	112(ra) # 80003100 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004098:	2a05                	addiw	s4,s4,1
    8000409a:	0a91                	addi	s5,s5,4
    8000409c:	02c9a783          	lw	a5,44(s3)
    800040a0:	04fa5963          	bge	s4,a5,800040f2 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800040a4:	0189a583          	lw	a1,24(s3)
    800040a8:	014585bb          	addw	a1,a1,s4
    800040ac:	2585                	addiw	a1,a1,1
    800040ae:	0289a503          	lw	a0,40(s3)
    800040b2:	fffff097          	auipc	ra,0xfffff
    800040b6:	f1e080e7          	jalr	-226(ra) # 80002fd0 <bread>
    800040ba:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800040bc:	000aa583          	lw	a1,0(s5)
    800040c0:	0289a503          	lw	a0,40(s3)
    800040c4:	fffff097          	auipc	ra,0xfffff
    800040c8:	f0c080e7          	jalr	-244(ra) # 80002fd0 <bread>
    800040cc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800040ce:	40000613          	li	a2,1024
    800040d2:	05890593          	addi	a1,s2,88
    800040d6:	05850513          	addi	a0,a0,88
    800040da:	ffffd097          	auipc	ra,0xffffd
    800040de:	c94080e7          	jalr	-876(ra) # 80000d6e <memmove>
    bwrite(dbuf);  // write dst to disk
    800040e2:	8526                	mv	a0,s1
    800040e4:	fffff097          	auipc	ra,0xfffff
    800040e8:	fde080e7          	jalr	-34(ra) # 800030c2 <bwrite>
    if(recovering == 0)
    800040ec:	f80b1ce3          	bnez	s6,80004084 <install_trans+0x40>
    800040f0:	b769                	j	8000407a <install_trans+0x36>
}
    800040f2:	70e2                	ld	ra,56(sp)
    800040f4:	7442                	ld	s0,48(sp)
    800040f6:	74a2                	ld	s1,40(sp)
    800040f8:	7902                	ld	s2,32(sp)
    800040fa:	69e2                	ld	s3,24(sp)
    800040fc:	6a42                	ld	s4,16(sp)
    800040fe:	6aa2                	ld	s5,8(sp)
    80004100:	6b02                	ld	s6,0(sp)
    80004102:	6121                	addi	sp,sp,64
    80004104:	8082                	ret
    80004106:	8082                	ret

0000000080004108 <initlog>:
{
    80004108:	7179                	addi	sp,sp,-48
    8000410a:	f406                	sd	ra,40(sp)
    8000410c:	f022                	sd	s0,32(sp)
    8000410e:	ec26                	sd	s1,24(sp)
    80004110:	e84a                	sd	s2,16(sp)
    80004112:	e44e                	sd	s3,8(sp)
    80004114:	1800                	addi	s0,sp,48
    80004116:	892a                	mv	s2,a0
    80004118:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000411a:	0001d497          	auipc	s1,0x1d
    8000411e:	f9648493          	addi	s1,s1,-106 # 800210b0 <log>
    80004122:	00005597          	auipc	a1,0x5
    80004126:	89658593          	addi	a1,a1,-1898 # 800089b8 <syscalls_name+0x1e8>
    8000412a:	8526                	mv	a0,s1
    8000412c:	ffffd097          	auipc	ra,0xffffd
    80004130:	a56080e7          	jalr	-1450(ra) # 80000b82 <initlock>
  log.start = sb->logstart;
    80004134:	0149a583          	lw	a1,20(s3)
    80004138:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000413a:	0109a783          	lw	a5,16(s3)
    8000413e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004140:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004144:	854a                	mv	a0,s2
    80004146:	fffff097          	auipc	ra,0xfffff
    8000414a:	e8a080e7          	jalr	-374(ra) # 80002fd0 <bread>
  log.lh.n = lh->n;
    8000414e:	4d3c                	lw	a5,88(a0)
    80004150:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004152:	02f05563          	blez	a5,8000417c <initlog+0x74>
    80004156:	05c50713          	addi	a4,a0,92
    8000415a:	0001d697          	auipc	a3,0x1d
    8000415e:	f8668693          	addi	a3,a3,-122 # 800210e0 <log+0x30>
    80004162:	37fd                	addiw	a5,a5,-1
    80004164:	1782                	slli	a5,a5,0x20
    80004166:	9381                	srli	a5,a5,0x20
    80004168:	078a                	slli	a5,a5,0x2
    8000416a:	06050613          	addi	a2,a0,96
    8000416e:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004170:	4310                	lw	a2,0(a4)
    80004172:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004174:	0711                	addi	a4,a4,4
    80004176:	0691                	addi	a3,a3,4
    80004178:	fef71ce3          	bne	a4,a5,80004170 <initlog+0x68>
  brelse(buf);
    8000417c:	fffff097          	auipc	ra,0xfffff
    80004180:	f84080e7          	jalr	-124(ra) # 80003100 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004184:	4505                	li	a0,1
    80004186:	00000097          	auipc	ra,0x0
    8000418a:	ebe080e7          	jalr	-322(ra) # 80004044 <install_trans>
  log.lh.n = 0;
    8000418e:	0001d797          	auipc	a5,0x1d
    80004192:	f407a723          	sw	zero,-178(a5) # 800210dc <log+0x2c>
  write_head(); // clear the log
    80004196:	00000097          	auipc	ra,0x0
    8000419a:	e34080e7          	jalr	-460(ra) # 80003fca <write_head>
}
    8000419e:	70a2                	ld	ra,40(sp)
    800041a0:	7402                	ld	s0,32(sp)
    800041a2:	64e2                	ld	s1,24(sp)
    800041a4:	6942                	ld	s2,16(sp)
    800041a6:	69a2                	ld	s3,8(sp)
    800041a8:	6145                	addi	sp,sp,48
    800041aa:	8082                	ret

00000000800041ac <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800041ac:	1101                	addi	sp,sp,-32
    800041ae:	ec06                	sd	ra,24(sp)
    800041b0:	e822                	sd	s0,16(sp)
    800041b2:	e426                	sd	s1,8(sp)
    800041b4:	e04a                	sd	s2,0(sp)
    800041b6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800041b8:	0001d517          	auipc	a0,0x1d
    800041bc:	ef850513          	addi	a0,a0,-264 # 800210b0 <log>
    800041c0:	ffffd097          	auipc	ra,0xffffd
    800041c4:	a52080e7          	jalr	-1454(ra) # 80000c12 <acquire>
  while(1){
    if(log.committing){
    800041c8:	0001d497          	auipc	s1,0x1d
    800041cc:	ee848493          	addi	s1,s1,-280 # 800210b0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800041d0:	4979                	li	s2,30
    800041d2:	a039                	j	800041e0 <begin_op+0x34>
      sleep(&log, &log.lock);
    800041d4:	85a6                	mv	a1,s1
    800041d6:	8526                	mv	a0,s1
    800041d8:	ffffe097          	auipc	ra,0xffffe
    800041dc:	f8c080e7          	jalr	-116(ra) # 80002164 <sleep>
    if(log.committing){
    800041e0:	50dc                	lw	a5,36(s1)
    800041e2:	fbed                	bnez	a5,800041d4 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800041e4:	509c                	lw	a5,32(s1)
    800041e6:	0017871b          	addiw	a4,a5,1
    800041ea:	0007069b          	sext.w	a3,a4
    800041ee:	0027179b          	slliw	a5,a4,0x2
    800041f2:	9fb9                	addw	a5,a5,a4
    800041f4:	0017979b          	slliw	a5,a5,0x1
    800041f8:	54d8                	lw	a4,44(s1)
    800041fa:	9fb9                	addw	a5,a5,a4
    800041fc:	00f95963          	bge	s2,a5,8000420e <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004200:	85a6                	mv	a1,s1
    80004202:	8526                	mv	a0,s1
    80004204:	ffffe097          	auipc	ra,0xffffe
    80004208:	f60080e7          	jalr	-160(ra) # 80002164 <sleep>
    8000420c:	bfd1                	j	800041e0 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000420e:	0001d517          	auipc	a0,0x1d
    80004212:	ea250513          	addi	a0,a0,-350 # 800210b0 <log>
    80004216:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004218:	ffffd097          	auipc	ra,0xffffd
    8000421c:	aae080e7          	jalr	-1362(ra) # 80000cc6 <release>
      break;
    }
  }
}
    80004220:	60e2                	ld	ra,24(sp)
    80004222:	6442                	ld	s0,16(sp)
    80004224:	64a2                	ld	s1,8(sp)
    80004226:	6902                	ld	s2,0(sp)
    80004228:	6105                	addi	sp,sp,32
    8000422a:	8082                	ret

000000008000422c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000422c:	7139                	addi	sp,sp,-64
    8000422e:	fc06                	sd	ra,56(sp)
    80004230:	f822                	sd	s0,48(sp)
    80004232:	f426                	sd	s1,40(sp)
    80004234:	f04a                	sd	s2,32(sp)
    80004236:	ec4e                	sd	s3,24(sp)
    80004238:	e852                	sd	s4,16(sp)
    8000423a:	e456                	sd	s5,8(sp)
    8000423c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000423e:	0001d497          	auipc	s1,0x1d
    80004242:	e7248493          	addi	s1,s1,-398 # 800210b0 <log>
    80004246:	8526                	mv	a0,s1
    80004248:	ffffd097          	auipc	ra,0xffffd
    8000424c:	9ca080e7          	jalr	-1590(ra) # 80000c12 <acquire>
  log.outstanding -= 1;
    80004250:	509c                	lw	a5,32(s1)
    80004252:	37fd                	addiw	a5,a5,-1
    80004254:	0007891b          	sext.w	s2,a5
    80004258:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000425a:	50dc                	lw	a5,36(s1)
    8000425c:	efb9                	bnez	a5,800042ba <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000425e:	06091663          	bnez	s2,800042ca <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004262:	0001d497          	auipc	s1,0x1d
    80004266:	e4e48493          	addi	s1,s1,-434 # 800210b0 <log>
    8000426a:	4785                	li	a5,1
    8000426c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000426e:	8526                	mv	a0,s1
    80004270:	ffffd097          	auipc	ra,0xffffd
    80004274:	a56080e7          	jalr	-1450(ra) # 80000cc6 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004278:	54dc                	lw	a5,44(s1)
    8000427a:	06f04763          	bgtz	a5,800042e8 <end_op+0xbc>
    acquire(&log.lock);
    8000427e:	0001d497          	auipc	s1,0x1d
    80004282:	e3248493          	addi	s1,s1,-462 # 800210b0 <log>
    80004286:	8526                	mv	a0,s1
    80004288:	ffffd097          	auipc	ra,0xffffd
    8000428c:	98a080e7          	jalr	-1654(ra) # 80000c12 <acquire>
    log.committing = 0;
    80004290:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004294:	8526                	mv	a0,s1
    80004296:	ffffe097          	auipc	ra,0xffffe
    8000429a:	f3c080e7          	jalr	-196(ra) # 800021d2 <wakeup>
    release(&log.lock);
    8000429e:	8526                	mv	a0,s1
    800042a0:	ffffd097          	auipc	ra,0xffffd
    800042a4:	a26080e7          	jalr	-1498(ra) # 80000cc6 <release>
}
    800042a8:	70e2                	ld	ra,56(sp)
    800042aa:	7442                	ld	s0,48(sp)
    800042ac:	74a2                	ld	s1,40(sp)
    800042ae:	7902                	ld	s2,32(sp)
    800042b0:	69e2                	ld	s3,24(sp)
    800042b2:	6a42                	ld	s4,16(sp)
    800042b4:	6aa2                	ld	s5,8(sp)
    800042b6:	6121                	addi	sp,sp,64
    800042b8:	8082                	ret
    panic("log.committing");
    800042ba:	00004517          	auipc	a0,0x4
    800042be:	70650513          	addi	a0,a0,1798 # 800089c0 <syscalls_name+0x1f0>
    800042c2:	ffffc097          	auipc	ra,0xffffc
    800042c6:	2aa080e7          	jalr	682(ra) # 8000056c <panic>
    wakeup(&log);
    800042ca:	0001d497          	auipc	s1,0x1d
    800042ce:	de648493          	addi	s1,s1,-538 # 800210b0 <log>
    800042d2:	8526                	mv	a0,s1
    800042d4:	ffffe097          	auipc	ra,0xffffe
    800042d8:	efe080e7          	jalr	-258(ra) # 800021d2 <wakeup>
  release(&log.lock);
    800042dc:	8526                	mv	a0,s1
    800042de:	ffffd097          	auipc	ra,0xffffd
    800042e2:	9e8080e7          	jalr	-1560(ra) # 80000cc6 <release>
  if(do_commit){
    800042e6:	b7c9                	j	800042a8 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042e8:	0001da97          	auipc	s5,0x1d
    800042ec:	df8a8a93          	addi	s5,s5,-520 # 800210e0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800042f0:	0001da17          	auipc	s4,0x1d
    800042f4:	dc0a0a13          	addi	s4,s4,-576 # 800210b0 <log>
    800042f8:	018a2583          	lw	a1,24(s4)
    800042fc:	012585bb          	addw	a1,a1,s2
    80004300:	2585                	addiw	a1,a1,1
    80004302:	028a2503          	lw	a0,40(s4)
    80004306:	fffff097          	auipc	ra,0xfffff
    8000430a:	cca080e7          	jalr	-822(ra) # 80002fd0 <bread>
    8000430e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004310:	000aa583          	lw	a1,0(s5)
    80004314:	028a2503          	lw	a0,40(s4)
    80004318:	fffff097          	auipc	ra,0xfffff
    8000431c:	cb8080e7          	jalr	-840(ra) # 80002fd0 <bread>
    80004320:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004322:	40000613          	li	a2,1024
    80004326:	05850593          	addi	a1,a0,88
    8000432a:	05848513          	addi	a0,s1,88
    8000432e:	ffffd097          	auipc	ra,0xffffd
    80004332:	a40080e7          	jalr	-1472(ra) # 80000d6e <memmove>
    bwrite(to);  // write the log
    80004336:	8526                	mv	a0,s1
    80004338:	fffff097          	auipc	ra,0xfffff
    8000433c:	d8a080e7          	jalr	-630(ra) # 800030c2 <bwrite>
    brelse(from);
    80004340:	854e                	mv	a0,s3
    80004342:	fffff097          	auipc	ra,0xfffff
    80004346:	dbe080e7          	jalr	-578(ra) # 80003100 <brelse>
    brelse(to);
    8000434a:	8526                	mv	a0,s1
    8000434c:	fffff097          	auipc	ra,0xfffff
    80004350:	db4080e7          	jalr	-588(ra) # 80003100 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004354:	2905                	addiw	s2,s2,1
    80004356:	0a91                	addi	s5,s5,4
    80004358:	02ca2783          	lw	a5,44(s4)
    8000435c:	f8f94ee3          	blt	s2,a5,800042f8 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004360:	00000097          	auipc	ra,0x0
    80004364:	c6a080e7          	jalr	-918(ra) # 80003fca <write_head>
    install_trans(0); // Now install writes to home locations
    80004368:	4501                	li	a0,0
    8000436a:	00000097          	auipc	ra,0x0
    8000436e:	cda080e7          	jalr	-806(ra) # 80004044 <install_trans>
    log.lh.n = 0;
    80004372:	0001d797          	auipc	a5,0x1d
    80004376:	d607a523          	sw	zero,-662(a5) # 800210dc <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000437a:	00000097          	auipc	ra,0x0
    8000437e:	c50080e7          	jalr	-944(ra) # 80003fca <write_head>
    80004382:	bdf5                	j	8000427e <end_op+0x52>

0000000080004384 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004384:	1101                	addi	sp,sp,-32
    80004386:	ec06                	sd	ra,24(sp)
    80004388:	e822                	sd	s0,16(sp)
    8000438a:	e426                	sd	s1,8(sp)
    8000438c:	e04a                	sd	s2,0(sp)
    8000438e:	1000                	addi	s0,sp,32
    80004390:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004392:	0001d917          	auipc	s2,0x1d
    80004396:	d1e90913          	addi	s2,s2,-738 # 800210b0 <log>
    8000439a:	854a                	mv	a0,s2
    8000439c:	ffffd097          	auipc	ra,0xffffd
    800043a0:	876080e7          	jalr	-1930(ra) # 80000c12 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800043a4:	02c92603          	lw	a2,44(s2)
    800043a8:	47f5                	li	a5,29
    800043aa:	06c7c563          	blt	a5,a2,80004414 <log_write+0x90>
    800043ae:	0001d797          	auipc	a5,0x1d
    800043b2:	d1e7a783          	lw	a5,-738(a5) # 800210cc <log+0x1c>
    800043b6:	37fd                	addiw	a5,a5,-1
    800043b8:	04f65e63          	bge	a2,a5,80004414 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800043bc:	0001d797          	auipc	a5,0x1d
    800043c0:	d147a783          	lw	a5,-748(a5) # 800210d0 <log+0x20>
    800043c4:	06f05063          	blez	a5,80004424 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800043c8:	4781                	li	a5,0
    800043ca:	06c05563          	blez	a2,80004434 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043ce:	44cc                	lw	a1,12(s1)
    800043d0:	0001d717          	auipc	a4,0x1d
    800043d4:	d1070713          	addi	a4,a4,-752 # 800210e0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800043d8:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043da:	4314                	lw	a3,0(a4)
    800043dc:	04b68c63          	beq	a3,a1,80004434 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800043e0:	2785                	addiw	a5,a5,1
    800043e2:	0711                	addi	a4,a4,4
    800043e4:	fef61be3          	bne	a2,a5,800043da <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800043e8:	0621                	addi	a2,a2,8
    800043ea:	060a                	slli	a2,a2,0x2
    800043ec:	0001d797          	auipc	a5,0x1d
    800043f0:	cc478793          	addi	a5,a5,-828 # 800210b0 <log>
    800043f4:	963e                	add	a2,a2,a5
    800043f6:	44dc                	lw	a5,12(s1)
    800043f8:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800043fa:	8526                	mv	a0,s1
    800043fc:	fffff097          	auipc	ra,0xfffff
    80004400:	da2080e7          	jalr	-606(ra) # 8000319e <bpin>
    log.lh.n++;
    80004404:	0001d717          	auipc	a4,0x1d
    80004408:	cac70713          	addi	a4,a4,-852 # 800210b0 <log>
    8000440c:	575c                	lw	a5,44(a4)
    8000440e:	2785                	addiw	a5,a5,1
    80004410:	d75c                	sw	a5,44(a4)
    80004412:	a835                	j	8000444e <log_write+0xca>
    panic("too big a transaction");
    80004414:	00004517          	auipc	a0,0x4
    80004418:	5bc50513          	addi	a0,a0,1468 # 800089d0 <syscalls_name+0x200>
    8000441c:	ffffc097          	auipc	ra,0xffffc
    80004420:	150080e7          	jalr	336(ra) # 8000056c <panic>
    panic("log_write outside of trans");
    80004424:	00004517          	auipc	a0,0x4
    80004428:	5c450513          	addi	a0,a0,1476 # 800089e8 <syscalls_name+0x218>
    8000442c:	ffffc097          	auipc	ra,0xffffc
    80004430:	140080e7          	jalr	320(ra) # 8000056c <panic>
  log.lh.block[i] = b->blockno;
    80004434:	00878713          	addi	a4,a5,8
    80004438:	00271693          	slli	a3,a4,0x2
    8000443c:	0001d717          	auipc	a4,0x1d
    80004440:	c7470713          	addi	a4,a4,-908 # 800210b0 <log>
    80004444:	9736                	add	a4,a4,a3
    80004446:	44d4                	lw	a3,12(s1)
    80004448:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000444a:	faf608e3          	beq	a2,a5,800043fa <log_write+0x76>
  }
  release(&log.lock);
    8000444e:	0001d517          	auipc	a0,0x1d
    80004452:	c6250513          	addi	a0,a0,-926 # 800210b0 <log>
    80004456:	ffffd097          	auipc	ra,0xffffd
    8000445a:	870080e7          	jalr	-1936(ra) # 80000cc6 <release>
}
    8000445e:	60e2                	ld	ra,24(sp)
    80004460:	6442                	ld	s0,16(sp)
    80004462:	64a2                	ld	s1,8(sp)
    80004464:	6902                	ld	s2,0(sp)
    80004466:	6105                	addi	sp,sp,32
    80004468:	8082                	ret

000000008000446a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000446a:	1101                	addi	sp,sp,-32
    8000446c:	ec06                	sd	ra,24(sp)
    8000446e:	e822                	sd	s0,16(sp)
    80004470:	e426                	sd	s1,8(sp)
    80004472:	e04a                	sd	s2,0(sp)
    80004474:	1000                	addi	s0,sp,32
    80004476:	84aa                	mv	s1,a0
    80004478:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000447a:	00004597          	auipc	a1,0x4
    8000447e:	58e58593          	addi	a1,a1,1422 # 80008a08 <syscalls_name+0x238>
    80004482:	0521                	addi	a0,a0,8
    80004484:	ffffc097          	auipc	ra,0xffffc
    80004488:	6fe080e7          	jalr	1790(ra) # 80000b82 <initlock>
  lk->name = name;
    8000448c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004490:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004494:	0204a423          	sw	zero,40(s1)
}
    80004498:	60e2                	ld	ra,24(sp)
    8000449a:	6442                	ld	s0,16(sp)
    8000449c:	64a2                	ld	s1,8(sp)
    8000449e:	6902                	ld	s2,0(sp)
    800044a0:	6105                	addi	sp,sp,32
    800044a2:	8082                	ret

00000000800044a4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800044a4:	1101                	addi	sp,sp,-32
    800044a6:	ec06                	sd	ra,24(sp)
    800044a8:	e822                	sd	s0,16(sp)
    800044aa:	e426                	sd	s1,8(sp)
    800044ac:	e04a                	sd	s2,0(sp)
    800044ae:	1000                	addi	s0,sp,32
    800044b0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044b2:	00850913          	addi	s2,a0,8
    800044b6:	854a                	mv	a0,s2
    800044b8:	ffffc097          	auipc	ra,0xffffc
    800044bc:	75a080e7          	jalr	1882(ra) # 80000c12 <acquire>
  while (lk->locked) {
    800044c0:	409c                	lw	a5,0(s1)
    800044c2:	cb89                	beqz	a5,800044d4 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800044c4:	85ca                	mv	a1,s2
    800044c6:	8526                	mv	a0,s1
    800044c8:	ffffe097          	auipc	ra,0xffffe
    800044cc:	c9c080e7          	jalr	-868(ra) # 80002164 <sleep>
  while (lk->locked) {
    800044d0:	409c                	lw	a5,0(s1)
    800044d2:	fbed                	bnez	a5,800044c4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800044d4:	4785                	li	a5,1
    800044d6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800044d8:	ffffd097          	auipc	ra,0xffffd
    800044dc:	532080e7          	jalr	1330(ra) # 80001a0a <myproc>
    800044e0:	5d1c                	lw	a5,56(a0)
    800044e2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800044e4:	854a                	mv	a0,s2
    800044e6:	ffffc097          	auipc	ra,0xffffc
    800044ea:	7e0080e7          	jalr	2016(ra) # 80000cc6 <release>
}
    800044ee:	60e2                	ld	ra,24(sp)
    800044f0:	6442                	ld	s0,16(sp)
    800044f2:	64a2                	ld	s1,8(sp)
    800044f4:	6902                	ld	s2,0(sp)
    800044f6:	6105                	addi	sp,sp,32
    800044f8:	8082                	ret

00000000800044fa <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800044fa:	1101                	addi	sp,sp,-32
    800044fc:	ec06                	sd	ra,24(sp)
    800044fe:	e822                	sd	s0,16(sp)
    80004500:	e426                	sd	s1,8(sp)
    80004502:	e04a                	sd	s2,0(sp)
    80004504:	1000                	addi	s0,sp,32
    80004506:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004508:	00850913          	addi	s2,a0,8
    8000450c:	854a                	mv	a0,s2
    8000450e:	ffffc097          	auipc	ra,0xffffc
    80004512:	704080e7          	jalr	1796(ra) # 80000c12 <acquire>
  lk->locked = 0;
    80004516:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000451a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000451e:	8526                	mv	a0,s1
    80004520:	ffffe097          	auipc	ra,0xffffe
    80004524:	cb2080e7          	jalr	-846(ra) # 800021d2 <wakeup>
  release(&lk->lk);
    80004528:	854a                	mv	a0,s2
    8000452a:	ffffc097          	auipc	ra,0xffffc
    8000452e:	79c080e7          	jalr	1948(ra) # 80000cc6 <release>
}
    80004532:	60e2                	ld	ra,24(sp)
    80004534:	6442                	ld	s0,16(sp)
    80004536:	64a2                	ld	s1,8(sp)
    80004538:	6902                	ld	s2,0(sp)
    8000453a:	6105                	addi	sp,sp,32
    8000453c:	8082                	ret

000000008000453e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000453e:	7179                	addi	sp,sp,-48
    80004540:	f406                	sd	ra,40(sp)
    80004542:	f022                	sd	s0,32(sp)
    80004544:	ec26                	sd	s1,24(sp)
    80004546:	e84a                	sd	s2,16(sp)
    80004548:	e44e                	sd	s3,8(sp)
    8000454a:	1800                	addi	s0,sp,48
    8000454c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000454e:	00850913          	addi	s2,a0,8
    80004552:	854a                	mv	a0,s2
    80004554:	ffffc097          	auipc	ra,0xffffc
    80004558:	6be080e7          	jalr	1726(ra) # 80000c12 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000455c:	409c                	lw	a5,0(s1)
    8000455e:	ef99                	bnez	a5,8000457c <holdingsleep+0x3e>
    80004560:	4481                	li	s1,0
  release(&lk->lk);
    80004562:	854a                	mv	a0,s2
    80004564:	ffffc097          	auipc	ra,0xffffc
    80004568:	762080e7          	jalr	1890(ra) # 80000cc6 <release>
  return r;
}
    8000456c:	8526                	mv	a0,s1
    8000456e:	70a2                	ld	ra,40(sp)
    80004570:	7402                	ld	s0,32(sp)
    80004572:	64e2                	ld	s1,24(sp)
    80004574:	6942                	ld	s2,16(sp)
    80004576:	69a2                	ld	s3,8(sp)
    80004578:	6145                	addi	sp,sp,48
    8000457a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000457c:	0284a983          	lw	s3,40(s1)
    80004580:	ffffd097          	auipc	ra,0xffffd
    80004584:	48a080e7          	jalr	1162(ra) # 80001a0a <myproc>
    80004588:	5d04                	lw	s1,56(a0)
    8000458a:	413484b3          	sub	s1,s1,s3
    8000458e:	0014b493          	seqz	s1,s1
    80004592:	bfc1                	j	80004562 <holdingsleep+0x24>

0000000080004594 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004594:	1141                	addi	sp,sp,-16
    80004596:	e406                	sd	ra,8(sp)
    80004598:	e022                	sd	s0,0(sp)
    8000459a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000459c:	00004597          	auipc	a1,0x4
    800045a0:	47c58593          	addi	a1,a1,1148 # 80008a18 <syscalls_name+0x248>
    800045a4:	0001d517          	auipc	a0,0x1d
    800045a8:	c5450513          	addi	a0,a0,-940 # 800211f8 <ftable>
    800045ac:	ffffc097          	auipc	ra,0xffffc
    800045b0:	5d6080e7          	jalr	1494(ra) # 80000b82 <initlock>
}
    800045b4:	60a2                	ld	ra,8(sp)
    800045b6:	6402                	ld	s0,0(sp)
    800045b8:	0141                	addi	sp,sp,16
    800045ba:	8082                	ret

00000000800045bc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800045bc:	1101                	addi	sp,sp,-32
    800045be:	ec06                	sd	ra,24(sp)
    800045c0:	e822                	sd	s0,16(sp)
    800045c2:	e426                	sd	s1,8(sp)
    800045c4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800045c6:	0001d517          	auipc	a0,0x1d
    800045ca:	c3250513          	addi	a0,a0,-974 # 800211f8 <ftable>
    800045ce:	ffffc097          	auipc	ra,0xffffc
    800045d2:	644080e7          	jalr	1604(ra) # 80000c12 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045d6:	0001d497          	auipc	s1,0x1d
    800045da:	c3a48493          	addi	s1,s1,-966 # 80021210 <ftable+0x18>
    800045de:	0001e717          	auipc	a4,0x1e
    800045e2:	bd270713          	addi	a4,a4,-1070 # 800221b0 <disk>
    if(f->ref == 0){
    800045e6:	40dc                	lw	a5,4(s1)
    800045e8:	cf99                	beqz	a5,80004606 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045ea:	02848493          	addi	s1,s1,40
    800045ee:	fee49ce3          	bne	s1,a4,800045e6 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800045f2:	0001d517          	auipc	a0,0x1d
    800045f6:	c0650513          	addi	a0,a0,-1018 # 800211f8 <ftable>
    800045fa:	ffffc097          	auipc	ra,0xffffc
    800045fe:	6cc080e7          	jalr	1740(ra) # 80000cc6 <release>
  return 0;
    80004602:	4481                	li	s1,0
    80004604:	a819                	j	8000461a <filealloc+0x5e>
      f->ref = 1;
    80004606:	4785                	li	a5,1
    80004608:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000460a:	0001d517          	auipc	a0,0x1d
    8000460e:	bee50513          	addi	a0,a0,-1042 # 800211f8 <ftable>
    80004612:	ffffc097          	auipc	ra,0xffffc
    80004616:	6b4080e7          	jalr	1716(ra) # 80000cc6 <release>
}
    8000461a:	8526                	mv	a0,s1
    8000461c:	60e2                	ld	ra,24(sp)
    8000461e:	6442                	ld	s0,16(sp)
    80004620:	64a2                	ld	s1,8(sp)
    80004622:	6105                	addi	sp,sp,32
    80004624:	8082                	ret

0000000080004626 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004626:	1101                	addi	sp,sp,-32
    80004628:	ec06                	sd	ra,24(sp)
    8000462a:	e822                	sd	s0,16(sp)
    8000462c:	e426                	sd	s1,8(sp)
    8000462e:	1000                	addi	s0,sp,32
    80004630:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004632:	0001d517          	auipc	a0,0x1d
    80004636:	bc650513          	addi	a0,a0,-1082 # 800211f8 <ftable>
    8000463a:	ffffc097          	auipc	ra,0xffffc
    8000463e:	5d8080e7          	jalr	1496(ra) # 80000c12 <acquire>
  if(f->ref < 1)
    80004642:	40dc                	lw	a5,4(s1)
    80004644:	02f05263          	blez	a5,80004668 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004648:	2785                	addiw	a5,a5,1
    8000464a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000464c:	0001d517          	auipc	a0,0x1d
    80004650:	bac50513          	addi	a0,a0,-1108 # 800211f8 <ftable>
    80004654:	ffffc097          	auipc	ra,0xffffc
    80004658:	672080e7          	jalr	1650(ra) # 80000cc6 <release>
  return f;
}
    8000465c:	8526                	mv	a0,s1
    8000465e:	60e2                	ld	ra,24(sp)
    80004660:	6442                	ld	s0,16(sp)
    80004662:	64a2                	ld	s1,8(sp)
    80004664:	6105                	addi	sp,sp,32
    80004666:	8082                	ret
    panic("filedup");
    80004668:	00004517          	auipc	a0,0x4
    8000466c:	3b850513          	addi	a0,a0,952 # 80008a20 <syscalls_name+0x250>
    80004670:	ffffc097          	auipc	ra,0xffffc
    80004674:	efc080e7          	jalr	-260(ra) # 8000056c <panic>

0000000080004678 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004678:	7139                	addi	sp,sp,-64
    8000467a:	fc06                	sd	ra,56(sp)
    8000467c:	f822                	sd	s0,48(sp)
    8000467e:	f426                	sd	s1,40(sp)
    80004680:	f04a                	sd	s2,32(sp)
    80004682:	ec4e                	sd	s3,24(sp)
    80004684:	e852                	sd	s4,16(sp)
    80004686:	e456                	sd	s5,8(sp)
    80004688:	0080                	addi	s0,sp,64
    8000468a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000468c:	0001d517          	auipc	a0,0x1d
    80004690:	b6c50513          	addi	a0,a0,-1172 # 800211f8 <ftable>
    80004694:	ffffc097          	auipc	ra,0xffffc
    80004698:	57e080e7          	jalr	1406(ra) # 80000c12 <acquire>
  if(f->ref < 1)
    8000469c:	40dc                	lw	a5,4(s1)
    8000469e:	06f05163          	blez	a5,80004700 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800046a2:	37fd                	addiw	a5,a5,-1
    800046a4:	0007871b          	sext.w	a4,a5
    800046a8:	c0dc                	sw	a5,4(s1)
    800046aa:	06e04363          	bgtz	a4,80004710 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800046ae:	0004a903          	lw	s2,0(s1)
    800046b2:	0094ca83          	lbu	s5,9(s1)
    800046b6:	0104ba03          	ld	s4,16(s1)
    800046ba:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800046be:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800046c2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800046c6:	0001d517          	auipc	a0,0x1d
    800046ca:	b3250513          	addi	a0,a0,-1230 # 800211f8 <ftable>
    800046ce:	ffffc097          	auipc	ra,0xffffc
    800046d2:	5f8080e7          	jalr	1528(ra) # 80000cc6 <release>

  if(ff.type == FD_PIPE){
    800046d6:	4785                	li	a5,1
    800046d8:	04f90d63          	beq	s2,a5,80004732 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800046dc:	3979                	addiw	s2,s2,-2
    800046de:	4785                	li	a5,1
    800046e0:	0527e063          	bltu	a5,s2,80004720 <fileclose+0xa8>
    begin_op();
    800046e4:	00000097          	auipc	ra,0x0
    800046e8:	ac8080e7          	jalr	-1336(ra) # 800041ac <begin_op>
    iput(ff.ip);
    800046ec:	854e                	mv	a0,s3
    800046ee:	fffff097          	auipc	ra,0xfffff
    800046f2:	2b6080e7          	jalr	694(ra) # 800039a4 <iput>
    end_op();
    800046f6:	00000097          	auipc	ra,0x0
    800046fa:	b36080e7          	jalr	-1226(ra) # 8000422c <end_op>
    800046fe:	a00d                	j	80004720 <fileclose+0xa8>
    panic("fileclose");
    80004700:	00004517          	auipc	a0,0x4
    80004704:	32850513          	addi	a0,a0,808 # 80008a28 <syscalls_name+0x258>
    80004708:	ffffc097          	auipc	ra,0xffffc
    8000470c:	e64080e7          	jalr	-412(ra) # 8000056c <panic>
    release(&ftable.lock);
    80004710:	0001d517          	auipc	a0,0x1d
    80004714:	ae850513          	addi	a0,a0,-1304 # 800211f8 <ftable>
    80004718:	ffffc097          	auipc	ra,0xffffc
    8000471c:	5ae080e7          	jalr	1454(ra) # 80000cc6 <release>
  }
}
    80004720:	70e2                	ld	ra,56(sp)
    80004722:	7442                	ld	s0,48(sp)
    80004724:	74a2                	ld	s1,40(sp)
    80004726:	7902                	ld	s2,32(sp)
    80004728:	69e2                	ld	s3,24(sp)
    8000472a:	6a42                	ld	s4,16(sp)
    8000472c:	6aa2                	ld	s5,8(sp)
    8000472e:	6121                	addi	sp,sp,64
    80004730:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004732:	85d6                	mv	a1,s5
    80004734:	8552                	mv	a0,s4
    80004736:	00000097          	auipc	ra,0x0
    8000473a:	34c080e7          	jalr	844(ra) # 80004a82 <pipeclose>
    8000473e:	b7cd                	j	80004720 <fileclose+0xa8>

0000000080004740 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004740:	715d                	addi	sp,sp,-80
    80004742:	e486                	sd	ra,72(sp)
    80004744:	e0a2                	sd	s0,64(sp)
    80004746:	fc26                	sd	s1,56(sp)
    80004748:	f84a                	sd	s2,48(sp)
    8000474a:	f44e                	sd	s3,40(sp)
    8000474c:	0880                	addi	s0,sp,80
    8000474e:	84aa                	mv	s1,a0
    80004750:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004752:	ffffd097          	auipc	ra,0xffffd
    80004756:	2b8080e7          	jalr	696(ra) # 80001a0a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000475a:	409c                	lw	a5,0(s1)
    8000475c:	37f9                	addiw	a5,a5,-2
    8000475e:	4705                	li	a4,1
    80004760:	04f76763          	bltu	a4,a5,800047ae <filestat+0x6e>
    80004764:	892a                	mv	s2,a0
    ilock(f->ip);
    80004766:	6c88                	ld	a0,24(s1)
    80004768:	fffff097          	auipc	ra,0xfffff
    8000476c:	082080e7          	jalr	130(ra) # 800037ea <ilock>
    stati(f->ip, &st);
    80004770:	fb840593          	addi	a1,s0,-72
    80004774:	6c88                	ld	a0,24(s1)
    80004776:	fffff097          	auipc	ra,0xfffff
    8000477a:	2fe080e7          	jalr	766(ra) # 80003a74 <stati>
    iunlock(f->ip);
    8000477e:	6c88                	ld	a0,24(s1)
    80004780:	fffff097          	auipc	ra,0xfffff
    80004784:	12c080e7          	jalr	300(ra) # 800038ac <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004788:	46e1                	li	a3,24
    8000478a:	fb840613          	addi	a2,s0,-72
    8000478e:	85ce                	mv	a1,s3
    80004790:	05893503          	ld	a0,88(s2)
    80004794:	ffffd097          	auipc	ra,0xffffd
    80004798:	f32080e7          	jalr	-206(ra) # 800016c6 <copyout>
    8000479c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800047a0:	60a6                	ld	ra,72(sp)
    800047a2:	6406                	ld	s0,64(sp)
    800047a4:	74e2                	ld	s1,56(sp)
    800047a6:	7942                	ld	s2,48(sp)
    800047a8:	79a2                	ld	s3,40(sp)
    800047aa:	6161                	addi	sp,sp,80
    800047ac:	8082                	ret
  return -1;
    800047ae:	557d                	li	a0,-1
    800047b0:	bfc5                	j	800047a0 <filestat+0x60>

00000000800047b2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800047b2:	7179                	addi	sp,sp,-48
    800047b4:	f406                	sd	ra,40(sp)
    800047b6:	f022                	sd	s0,32(sp)
    800047b8:	ec26                	sd	s1,24(sp)
    800047ba:	e84a                	sd	s2,16(sp)
    800047bc:	e44e                	sd	s3,8(sp)
    800047be:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800047c0:	00854783          	lbu	a5,8(a0)
    800047c4:	c3d5                	beqz	a5,80004868 <fileread+0xb6>
    800047c6:	84aa                	mv	s1,a0
    800047c8:	89ae                	mv	s3,a1
    800047ca:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800047cc:	411c                	lw	a5,0(a0)
    800047ce:	4705                	li	a4,1
    800047d0:	04e78963          	beq	a5,a4,80004822 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047d4:	470d                	li	a4,3
    800047d6:	04e78d63          	beq	a5,a4,80004830 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800047da:	4709                	li	a4,2
    800047dc:	06e79e63          	bne	a5,a4,80004858 <fileread+0xa6>
    ilock(f->ip);
    800047e0:	6d08                	ld	a0,24(a0)
    800047e2:	fffff097          	auipc	ra,0xfffff
    800047e6:	008080e7          	jalr	8(ra) # 800037ea <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800047ea:	874a                	mv	a4,s2
    800047ec:	5094                	lw	a3,32(s1)
    800047ee:	864e                	mv	a2,s3
    800047f0:	4585                	li	a1,1
    800047f2:	6c88                	ld	a0,24(s1)
    800047f4:	fffff097          	auipc	ra,0xfffff
    800047f8:	2aa080e7          	jalr	682(ra) # 80003a9e <readi>
    800047fc:	892a                	mv	s2,a0
    800047fe:	00a05563          	blez	a0,80004808 <fileread+0x56>
      f->off += r;
    80004802:	509c                	lw	a5,32(s1)
    80004804:	9fa9                	addw	a5,a5,a0
    80004806:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004808:	6c88                	ld	a0,24(s1)
    8000480a:	fffff097          	auipc	ra,0xfffff
    8000480e:	0a2080e7          	jalr	162(ra) # 800038ac <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004812:	854a                	mv	a0,s2
    80004814:	70a2                	ld	ra,40(sp)
    80004816:	7402                	ld	s0,32(sp)
    80004818:	64e2                	ld	s1,24(sp)
    8000481a:	6942                	ld	s2,16(sp)
    8000481c:	69a2                	ld	s3,8(sp)
    8000481e:	6145                	addi	sp,sp,48
    80004820:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004822:	6908                	ld	a0,16(a0)
    80004824:	00000097          	auipc	ra,0x0
    80004828:	3ce080e7          	jalr	974(ra) # 80004bf2 <piperead>
    8000482c:	892a                	mv	s2,a0
    8000482e:	b7d5                	j	80004812 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004830:	02451783          	lh	a5,36(a0)
    80004834:	03079693          	slli	a3,a5,0x30
    80004838:	92c1                	srli	a3,a3,0x30
    8000483a:	4725                	li	a4,9
    8000483c:	02d76863          	bltu	a4,a3,8000486c <fileread+0xba>
    80004840:	0792                	slli	a5,a5,0x4
    80004842:	0001d717          	auipc	a4,0x1d
    80004846:	91670713          	addi	a4,a4,-1770 # 80021158 <devsw>
    8000484a:	97ba                	add	a5,a5,a4
    8000484c:	639c                	ld	a5,0(a5)
    8000484e:	c38d                	beqz	a5,80004870 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004850:	4505                	li	a0,1
    80004852:	9782                	jalr	a5
    80004854:	892a                	mv	s2,a0
    80004856:	bf75                	j	80004812 <fileread+0x60>
    panic("fileread");
    80004858:	00004517          	auipc	a0,0x4
    8000485c:	1e050513          	addi	a0,a0,480 # 80008a38 <syscalls_name+0x268>
    80004860:	ffffc097          	auipc	ra,0xffffc
    80004864:	d0c080e7          	jalr	-756(ra) # 8000056c <panic>
    return -1;
    80004868:	597d                	li	s2,-1
    8000486a:	b765                	j	80004812 <fileread+0x60>
      return -1;
    8000486c:	597d                	li	s2,-1
    8000486e:	b755                	j	80004812 <fileread+0x60>
    80004870:	597d                	li	s2,-1
    80004872:	b745                	j	80004812 <fileread+0x60>

0000000080004874 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004874:	715d                	addi	sp,sp,-80
    80004876:	e486                	sd	ra,72(sp)
    80004878:	e0a2                	sd	s0,64(sp)
    8000487a:	fc26                	sd	s1,56(sp)
    8000487c:	f84a                	sd	s2,48(sp)
    8000487e:	f44e                	sd	s3,40(sp)
    80004880:	f052                	sd	s4,32(sp)
    80004882:	ec56                	sd	s5,24(sp)
    80004884:	e85a                	sd	s6,16(sp)
    80004886:	e45e                	sd	s7,8(sp)
    80004888:	e062                	sd	s8,0(sp)
    8000488a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000488c:	00954783          	lbu	a5,9(a0)
    80004890:	10078663          	beqz	a5,8000499c <filewrite+0x128>
    80004894:	892a                	mv	s2,a0
    80004896:	8aae                	mv	s5,a1
    80004898:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000489a:	411c                	lw	a5,0(a0)
    8000489c:	4705                	li	a4,1
    8000489e:	02e78263          	beq	a5,a4,800048c2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048a2:	470d                	li	a4,3
    800048a4:	02e78663          	beq	a5,a4,800048d0 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800048a8:	4709                	li	a4,2
    800048aa:	0ee79163          	bne	a5,a4,8000498c <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800048ae:	0ac05d63          	blez	a2,80004968 <filewrite+0xf4>
    int i = 0;
    800048b2:	4981                	li	s3,0
    800048b4:	6b05                	lui	s6,0x1
    800048b6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800048ba:	6b85                	lui	s7,0x1
    800048bc:	c00b8b9b          	addiw	s7,s7,-1024
    800048c0:	a861                	j	80004958 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800048c2:	6908                	ld	a0,16(a0)
    800048c4:	00000097          	auipc	ra,0x0
    800048c8:	22e080e7          	jalr	558(ra) # 80004af2 <pipewrite>
    800048cc:	8a2a                	mv	s4,a0
    800048ce:	a045                	j	8000496e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800048d0:	02451783          	lh	a5,36(a0)
    800048d4:	03079693          	slli	a3,a5,0x30
    800048d8:	92c1                	srli	a3,a3,0x30
    800048da:	4725                	li	a4,9
    800048dc:	0cd76263          	bltu	a4,a3,800049a0 <filewrite+0x12c>
    800048e0:	0792                	slli	a5,a5,0x4
    800048e2:	0001d717          	auipc	a4,0x1d
    800048e6:	87670713          	addi	a4,a4,-1930 # 80021158 <devsw>
    800048ea:	97ba                	add	a5,a5,a4
    800048ec:	679c                	ld	a5,8(a5)
    800048ee:	cbdd                	beqz	a5,800049a4 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800048f0:	4505                	li	a0,1
    800048f2:	9782                	jalr	a5
    800048f4:	8a2a                	mv	s4,a0
    800048f6:	a8a5                	j	8000496e <filewrite+0xfa>
    800048f8:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800048fc:	00000097          	auipc	ra,0x0
    80004900:	8b0080e7          	jalr	-1872(ra) # 800041ac <begin_op>
      ilock(f->ip);
    80004904:	01893503          	ld	a0,24(s2)
    80004908:	fffff097          	auipc	ra,0xfffff
    8000490c:	ee2080e7          	jalr	-286(ra) # 800037ea <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004910:	8762                	mv	a4,s8
    80004912:	02092683          	lw	a3,32(s2)
    80004916:	01598633          	add	a2,s3,s5
    8000491a:	4585                	li	a1,1
    8000491c:	01893503          	ld	a0,24(s2)
    80004920:	fffff097          	auipc	ra,0xfffff
    80004924:	276080e7          	jalr	630(ra) # 80003b96 <writei>
    80004928:	84aa                	mv	s1,a0
    8000492a:	00a05763          	blez	a0,80004938 <filewrite+0xc4>
        f->off += r;
    8000492e:	02092783          	lw	a5,32(s2)
    80004932:	9fa9                	addw	a5,a5,a0
    80004934:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004938:	01893503          	ld	a0,24(s2)
    8000493c:	fffff097          	auipc	ra,0xfffff
    80004940:	f70080e7          	jalr	-144(ra) # 800038ac <iunlock>
      end_op();
    80004944:	00000097          	auipc	ra,0x0
    80004948:	8e8080e7          	jalr	-1816(ra) # 8000422c <end_op>

      if(r != n1){
    8000494c:	009c1f63          	bne	s8,s1,8000496a <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004950:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004954:	0149db63          	bge	s3,s4,8000496a <filewrite+0xf6>
      int n1 = n - i;
    80004958:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000495c:	84be                	mv	s1,a5
    8000495e:	2781                	sext.w	a5,a5
    80004960:	f8fb5ce3          	bge	s6,a5,800048f8 <filewrite+0x84>
    80004964:	84de                	mv	s1,s7
    80004966:	bf49                	j	800048f8 <filewrite+0x84>
    int i = 0;
    80004968:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000496a:	013a1f63          	bne	s4,s3,80004988 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000496e:	8552                	mv	a0,s4
    80004970:	60a6                	ld	ra,72(sp)
    80004972:	6406                	ld	s0,64(sp)
    80004974:	74e2                	ld	s1,56(sp)
    80004976:	7942                	ld	s2,48(sp)
    80004978:	79a2                	ld	s3,40(sp)
    8000497a:	7a02                	ld	s4,32(sp)
    8000497c:	6ae2                	ld	s5,24(sp)
    8000497e:	6b42                	ld	s6,16(sp)
    80004980:	6ba2                	ld	s7,8(sp)
    80004982:	6c02                	ld	s8,0(sp)
    80004984:	6161                	addi	sp,sp,80
    80004986:	8082                	ret
    ret = (i == n ? n : -1);
    80004988:	5a7d                	li	s4,-1
    8000498a:	b7d5                	j	8000496e <filewrite+0xfa>
    panic("filewrite");
    8000498c:	00004517          	auipc	a0,0x4
    80004990:	0bc50513          	addi	a0,a0,188 # 80008a48 <syscalls_name+0x278>
    80004994:	ffffc097          	auipc	ra,0xffffc
    80004998:	bd8080e7          	jalr	-1064(ra) # 8000056c <panic>
    return -1;
    8000499c:	5a7d                	li	s4,-1
    8000499e:	bfc1                	j	8000496e <filewrite+0xfa>
      return -1;
    800049a0:	5a7d                	li	s4,-1
    800049a2:	b7f1                	j	8000496e <filewrite+0xfa>
    800049a4:	5a7d                	li	s4,-1
    800049a6:	b7e1                	j	8000496e <filewrite+0xfa>

00000000800049a8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800049a8:	7179                	addi	sp,sp,-48
    800049aa:	f406                	sd	ra,40(sp)
    800049ac:	f022                	sd	s0,32(sp)
    800049ae:	ec26                	sd	s1,24(sp)
    800049b0:	e84a                	sd	s2,16(sp)
    800049b2:	e44e                	sd	s3,8(sp)
    800049b4:	e052                	sd	s4,0(sp)
    800049b6:	1800                	addi	s0,sp,48
    800049b8:	84aa                	mv	s1,a0
    800049ba:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800049bc:	0005b023          	sd	zero,0(a1)
    800049c0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800049c4:	00000097          	auipc	ra,0x0
    800049c8:	bf8080e7          	jalr	-1032(ra) # 800045bc <filealloc>
    800049cc:	e088                	sd	a0,0(s1)
    800049ce:	c551                	beqz	a0,80004a5a <pipealloc+0xb2>
    800049d0:	00000097          	auipc	ra,0x0
    800049d4:	bec080e7          	jalr	-1044(ra) # 800045bc <filealloc>
    800049d8:	00aa3023          	sd	a0,0(s4)
    800049dc:	c92d                	beqz	a0,80004a4e <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800049de:	ffffc097          	auipc	ra,0xffffc
    800049e2:	144080e7          	jalr	324(ra) # 80000b22 <kalloc>
    800049e6:	892a                	mv	s2,a0
    800049e8:	c125                	beqz	a0,80004a48 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800049ea:	4985                	li	s3,1
    800049ec:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800049f0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800049f4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800049f8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800049fc:	00004597          	auipc	a1,0x4
    80004a00:	bc458593          	addi	a1,a1,-1084 # 800085c0 <states.1728+0x1b8>
    80004a04:	ffffc097          	auipc	ra,0xffffc
    80004a08:	17e080e7          	jalr	382(ra) # 80000b82 <initlock>
  (*f0)->type = FD_PIPE;
    80004a0c:	609c                	ld	a5,0(s1)
    80004a0e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004a12:	609c                	ld	a5,0(s1)
    80004a14:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004a18:	609c                	ld	a5,0(s1)
    80004a1a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004a1e:	609c                	ld	a5,0(s1)
    80004a20:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004a24:	000a3783          	ld	a5,0(s4)
    80004a28:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004a2c:	000a3783          	ld	a5,0(s4)
    80004a30:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004a34:	000a3783          	ld	a5,0(s4)
    80004a38:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004a3c:	000a3783          	ld	a5,0(s4)
    80004a40:	0127b823          	sd	s2,16(a5)
  return 0;
    80004a44:	4501                	li	a0,0
    80004a46:	a025                	j	80004a6e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004a48:	6088                	ld	a0,0(s1)
    80004a4a:	e501                	bnez	a0,80004a52 <pipealloc+0xaa>
    80004a4c:	a039                	j	80004a5a <pipealloc+0xb2>
    80004a4e:	6088                	ld	a0,0(s1)
    80004a50:	c51d                	beqz	a0,80004a7e <pipealloc+0xd6>
    fileclose(*f0);
    80004a52:	00000097          	auipc	ra,0x0
    80004a56:	c26080e7          	jalr	-986(ra) # 80004678 <fileclose>
  if(*f1)
    80004a5a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a5e:	557d                	li	a0,-1
  if(*f1)
    80004a60:	c799                	beqz	a5,80004a6e <pipealloc+0xc6>
    fileclose(*f1);
    80004a62:	853e                	mv	a0,a5
    80004a64:	00000097          	auipc	ra,0x0
    80004a68:	c14080e7          	jalr	-1004(ra) # 80004678 <fileclose>
  return -1;
    80004a6c:	557d                	li	a0,-1
}
    80004a6e:	70a2                	ld	ra,40(sp)
    80004a70:	7402                	ld	s0,32(sp)
    80004a72:	64e2                	ld	s1,24(sp)
    80004a74:	6942                	ld	s2,16(sp)
    80004a76:	69a2                	ld	s3,8(sp)
    80004a78:	6a02                	ld	s4,0(sp)
    80004a7a:	6145                	addi	sp,sp,48
    80004a7c:	8082                	ret
  return -1;
    80004a7e:	557d                	li	a0,-1
    80004a80:	b7fd                	j	80004a6e <pipealloc+0xc6>

0000000080004a82 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a82:	1101                	addi	sp,sp,-32
    80004a84:	ec06                	sd	ra,24(sp)
    80004a86:	e822                	sd	s0,16(sp)
    80004a88:	e426                	sd	s1,8(sp)
    80004a8a:	e04a                	sd	s2,0(sp)
    80004a8c:	1000                	addi	s0,sp,32
    80004a8e:	84aa                	mv	s1,a0
    80004a90:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a92:	ffffc097          	auipc	ra,0xffffc
    80004a96:	180080e7          	jalr	384(ra) # 80000c12 <acquire>
  if(writable){
    80004a9a:	02090d63          	beqz	s2,80004ad4 <pipeclose+0x52>
    pi->writeopen = 0;
    80004a9e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004aa2:	21848513          	addi	a0,s1,536
    80004aa6:	ffffd097          	auipc	ra,0xffffd
    80004aaa:	72c080e7          	jalr	1836(ra) # 800021d2 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004aae:	2204b783          	ld	a5,544(s1)
    80004ab2:	eb95                	bnez	a5,80004ae6 <pipeclose+0x64>
    release(&pi->lock);
    80004ab4:	8526                	mv	a0,s1
    80004ab6:	ffffc097          	auipc	ra,0xffffc
    80004aba:	210080e7          	jalr	528(ra) # 80000cc6 <release>
    kfree((char*)pi);
    80004abe:	8526                	mv	a0,s1
    80004ac0:	ffffc097          	auipc	ra,0xffffc
    80004ac4:	f66080e7          	jalr	-154(ra) # 80000a26 <kfree>
  } else
    release(&pi->lock);
}
    80004ac8:	60e2                	ld	ra,24(sp)
    80004aca:	6442                	ld	s0,16(sp)
    80004acc:	64a2                	ld	s1,8(sp)
    80004ace:	6902                	ld	s2,0(sp)
    80004ad0:	6105                	addi	sp,sp,32
    80004ad2:	8082                	ret
    pi->readopen = 0;
    80004ad4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ad8:	21c48513          	addi	a0,s1,540
    80004adc:	ffffd097          	auipc	ra,0xffffd
    80004ae0:	6f6080e7          	jalr	1782(ra) # 800021d2 <wakeup>
    80004ae4:	b7e9                	j	80004aae <pipeclose+0x2c>
    release(&pi->lock);
    80004ae6:	8526                	mv	a0,s1
    80004ae8:	ffffc097          	auipc	ra,0xffffc
    80004aec:	1de080e7          	jalr	478(ra) # 80000cc6 <release>
}
    80004af0:	bfe1                	j	80004ac8 <pipeclose+0x46>

0000000080004af2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004af2:	7159                	addi	sp,sp,-112
    80004af4:	f486                	sd	ra,104(sp)
    80004af6:	f0a2                	sd	s0,96(sp)
    80004af8:	eca6                	sd	s1,88(sp)
    80004afa:	e8ca                	sd	s2,80(sp)
    80004afc:	e4ce                	sd	s3,72(sp)
    80004afe:	e0d2                	sd	s4,64(sp)
    80004b00:	fc56                	sd	s5,56(sp)
    80004b02:	f85a                	sd	s6,48(sp)
    80004b04:	f45e                	sd	s7,40(sp)
    80004b06:	f062                	sd	s8,32(sp)
    80004b08:	ec66                	sd	s9,24(sp)
    80004b0a:	1880                	addi	s0,sp,112
    80004b0c:	84aa                	mv	s1,a0
    80004b0e:	8aae                	mv	s5,a1
    80004b10:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004b12:	ffffd097          	auipc	ra,0xffffd
    80004b16:	ef8080e7          	jalr	-264(ra) # 80001a0a <myproc>
    80004b1a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004b1c:	8526                	mv	a0,s1
    80004b1e:	ffffc097          	auipc	ra,0xffffc
    80004b22:	0f4080e7          	jalr	244(ra) # 80000c12 <acquire>
  while(i < n){
    80004b26:	0d405463          	blez	s4,80004bee <pipewrite+0xfc>
    80004b2a:	8ba6                	mv	s7,s1
  int i = 0;
    80004b2c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b2e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004b30:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004b34:	21c48c13          	addi	s8,s1,540
    80004b38:	a08d                	j	80004b9a <pipewrite+0xa8>
      release(&pi->lock);
    80004b3a:	8526                	mv	a0,s1
    80004b3c:	ffffc097          	auipc	ra,0xffffc
    80004b40:	18a080e7          	jalr	394(ra) # 80000cc6 <release>
      return -1;
    80004b44:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004b46:	854a                	mv	a0,s2
    80004b48:	70a6                	ld	ra,104(sp)
    80004b4a:	7406                	ld	s0,96(sp)
    80004b4c:	64e6                	ld	s1,88(sp)
    80004b4e:	6946                	ld	s2,80(sp)
    80004b50:	69a6                	ld	s3,72(sp)
    80004b52:	6a06                	ld	s4,64(sp)
    80004b54:	7ae2                	ld	s5,56(sp)
    80004b56:	7b42                	ld	s6,48(sp)
    80004b58:	7ba2                	ld	s7,40(sp)
    80004b5a:	7c02                	ld	s8,32(sp)
    80004b5c:	6ce2                	ld	s9,24(sp)
    80004b5e:	6165                	addi	sp,sp,112
    80004b60:	8082                	ret
      wakeup(&pi->nread);
    80004b62:	8566                	mv	a0,s9
    80004b64:	ffffd097          	auipc	ra,0xffffd
    80004b68:	66e080e7          	jalr	1646(ra) # 800021d2 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004b6c:	85de                	mv	a1,s7
    80004b6e:	8562                	mv	a0,s8
    80004b70:	ffffd097          	auipc	ra,0xffffd
    80004b74:	5f4080e7          	jalr	1524(ra) # 80002164 <sleep>
    80004b78:	a839                	j	80004b96 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b7a:	21c4a783          	lw	a5,540(s1)
    80004b7e:	0017871b          	addiw	a4,a5,1
    80004b82:	20e4ae23          	sw	a4,540(s1)
    80004b86:	1ff7f793          	andi	a5,a5,511
    80004b8a:	97a6                	add	a5,a5,s1
    80004b8c:	f9f44703          	lbu	a4,-97(s0)
    80004b90:	00e78c23          	sb	a4,24(a5)
      i++;
    80004b94:	2905                	addiw	s2,s2,1
  while(i < n){
    80004b96:	05495063          	bge	s2,s4,80004bd6 <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80004b9a:	2204a783          	lw	a5,544(s1)
    80004b9e:	dfd1                	beqz	a5,80004b3a <pipewrite+0x48>
    80004ba0:	854e                	mv	a0,s3
    80004ba2:	ffffe097          	auipc	ra,0xffffe
    80004ba6:	890080e7          	jalr	-1904(ra) # 80002432 <killed>
    80004baa:	f941                	bnez	a0,80004b3a <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004bac:	2184a783          	lw	a5,536(s1)
    80004bb0:	21c4a703          	lw	a4,540(s1)
    80004bb4:	2007879b          	addiw	a5,a5,512
    80004bb8:	faf705e3          	beq	a4,a5,80004b62 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004bbc:	4685                	li	a3,1
    80004bbe:	01590633          	add	a2,s2,s5
    80004bc2:	f9f40593          	addi	a1,s0,-97
    80004bc6:	0589b503          	ld	a0,88(s3)
    80004bca:	ffffd097          	auipc	ra,0xffffd
    80004bce:	b88080e7          	jalr	-1144(ra) # 80001752 <copyin>
    80004bd2:	fb6514e3          	bne	a0,s6,80004b7a <pipewrite+0x88>
  wakeup(&pi->nread);
    80004bd6:	21848513          	addi	a0,s1,536
    80004bda:	ffffd097          	auipc	ra,0xffffd
    80004bde:	5f8080e7          	jalr	1528(ra) # 800021d2 <wakeup>
  release(&pi->lock);
    80004be2:	8526                	mv	a0,s1
    80004be4:	ffffc097          	auipc	ra,0xffffc
    80004be8:	0e2080e7          	jalr	226(ra) # 80000cc6 <release>
  return i;
    80004bec:	bfa9                	j	80004b46 <pipewrite+0x54>
  int i = 0;
    80004bee:	4901                	li	s2,0
    80004bf0:	b7dd                	j	80004bd6 <pipewrite+0xe4>

0000000080004bf2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004bf2:	715d                	addi	sp,sp,-80
    80004bf4:	e486                	sd	ra,72(sp)
    80004bf6:	e0a2                	sd	s0,64(sp)
    80004bf8:	fc26                	sd	s1,56(sp)
    80004bfa:	f84a                	sd	s2,48(sp)
    80004bfc:	f44e                	sd	s3,40(sp)
    80004bfe:	f052                	sd	s4,32(sp)
    80004c00:	ec56                	sd	s5,24(sp)
    80004c02:	e85a                	sd	s6,16(sp)
    80004c04:	0880                	addi	s0,sp,80
    80004c06:	84aa                	mv	s1,a0
    80004c08:	892e                	mv	s2,a1
    80004c0a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004c0c:	ffffd097          	auipc	ra,0xffffd
    80004c10:	dfe080e7          	jalr	-514(ra) # 80001a0a <myproc>
    80004c14:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004c16:	8b26                	mv	s6,s1
    80004c18:	8526                	mv	a0,s1
    80004c1a:	ffffc097          	auipc	ra,0xffffc
    80004c1e:	ff8080e7          	jalr	-8(ra) # 80000c12 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c22:	2184a703          	lw	a4,536(s1)
    80004c26:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c2a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c2e:	02f71763          	bne	a4,a5,80004c5c <piperead+0x6a>
    80004c32:	2244a783          	lw	a5,548(s1)
    80004c36:	c39d                	beqz	a5,80004c5c <piperead+0x6a>
    if(killed(pr)){
    80004c38:	8552                	mv	a0,s4
    80004c3a:	ffffd097          	auipc	ra,0xffffd
    80004c3e:	7f8080e7          	jalr	2040(ra) # 80002432 <killed>
    80004c42:	e941                	bnez	a0,80004cd2 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c44:	85da                	mv	a1,s6
    80004c46:	854e                	mv	a0,s3
    80004c48:	ffffd097          	auipc	ra,0xffffd
    80004c4c:	51c080e7          	jalr	1308(ra) # 80002164 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c50:	2184a703          	lw	a4,536(s1)
    80004c54:	21c4a783          	lw	a5,540(s1)
    80004c58:	fcf70de3          	beq	a4,a5,80004c32 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c5c:	09505263          	blez	s5,80004ce0 <piperead+0xee>
    80004c60:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c62:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004c64:	2184a783          	lw	a5,536(s1)
    80004c68:	21c4a703          	lw	a4,540(s1)
    80004c6c:	02f70d63          	beq	a4,a5,80004ca6 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004c70:	0017871b          	addiw	a4,a5,1
    80004c74:	20e4ac23          	sw	a4,536(s1)
    80004c78:	1ff7f793          	andi	a5,a5,511
    80004c7c:	97a6                	add	a5,a5,s1
    80004c7e:	0187c783          	lbu	a5,24(a5)
    80004c82:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c86:	4685                	li	a3,1
    80004c88:	fbf40613          	addi	a2,s0,-65
    80004c8c:	85ca                	mv	a1,s2
    80004c8e:	058a3503          	ld	a0,88(s4)
    80004c92:	ffffd097          	auipc	ra,0xffffd
    80004c96:	a34080e7          	jalr	-1484(ra) # 800016c6 <copyout>
    80004c9a:	01650663          	beq	a0,s6,80004ca6 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c9e:	2985                	addiw	s3,s3,1
    80004ca0:	0905                	addi	s2,s2,1
    80004ca2:	fd3a91e3          	bne	s5,s3,80004c64 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004ca6:	21c48513          	addi	a0,s1,540
    80004caa:	ffffd097          	auipc	ra,0xffffd
    80004cae:	528080e7          	jalr	1320(ra) # 800021d2 <wakeup>
  release(&pi->lock);
    80004cb2:	8526                	mv	a0,s1
    80004cb4:	ffffc097          	auipc	ra,0xffffc
    80004cb8:	012080e7          	jalr	18(ra) # 80000cc6 <release>
  return i;
}
    80004cbc:	854e                	mv	a0,s3
    80004cbe:	60a6                	ld	ra,72(sp)
    80004cc0:	6406                	ld	s0,64(sp)
    80004cc2:	74e2                	ld	s1,56(sp)
    80004cc4:	7942                	ld	s2,48(sp)
    80004cc6:	79a2                	ld	s3,40(sp)
    80004cc8:	7a02                	ld	s4,32(sp)
    80004cca:	6ae2                	ld	s5,24(sp)
    80004ccc:	6b42                	ld	s6,16(sp)
    80004cce:	6161                	addi	sp,sp,80
    80004cd0:	8082                	ret
      release(&pi->lock);
    80004cd2:	8526                	mv	a0,s1
    80004cd4:	ffffc097          	auipc	ra,0xffffc
    80004cd8:	ff2080e7          	jalr	-14(ra) # 80000cc6 <release>
      return -1;
    80004cdc:	59fd                	li	s3,-1
    80004cde:	bff9                	j	80004cbc <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ce0:	4981                	li	s3,0
    80004ce2:	b7d1                	j	80004ca6 <piperead+0xb4>

0000000080004ce4 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004ce4:	1141                	addi	sp,sp,-16
    80004ce6:	e422                	sd	s0,8(sp)
    80004ce8:	0800                	addi	s0,sp,16
    80004cea:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004cec:	8905                	andi	a0,a0,1
    80004cee:	c111                	beqz	a0,80004cf2 <flags2perm+0xe>
      perm = PTE_X;
    80004cf0:	4521                	li	a0,8
    if(flags & 0x2)
    80004cf2:	8b89                	andi	a5,a5,2
    80004cf4:	c399                	beqz	a5,80004cfa <flags2perm+0x16>
      perm |= PTE_W;
    80004cf6:	00456513          	ori	a0,a0,4
    return perm;
}
    80004cfa:	6422                	ld	s0,8(sp)
    80004cfc:	0141                	addi	sp,sp,16
    80004cfe:	8082                	ret

0000000080004d00 <exec>:

int
exec(char *path, char **argv)
{
    80004d00:	df010113          	addi	sp,sp,-528
    80004d04:	20113423          	sd	ra,520(sp)
    80004d08:	20813023          	sd	s0,512(sp)
    80004d0c:	ffa6                	sd	s1,504(sp)
    80004d0e:	fbca                	sd	s2,496(sp)
    80004d10:	f7ce                	sd	s3,488(sp)
    80004d12:	f3d2                	sd	s4,480(sp)
    80004d14:	efd6                	sd	s5,472(sp)
    80004d16:	ebda                	sd	s6,464(sp)
    80004d18:	e7de                	sd	s7,456(sp)
    80004d1a:	e3e2                	sd	s8,448(sp)
    80004d1c:	ff66                	sd	s9,440(sp)
    80004d1e:	fb6a                	sd	s10,432(sp)
    80004d20:	f76e                	sd	s11,424(sp)
    80004d22:	0c00                	addi	s0,sp,528
    80004d24:	84aa                	mv	s1,a0
    80004d26:	dea43c23          	sd	a0,-520(s0)
    80004d2a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004d2e:	ffffd097          	auipc	ra,0xffffd
    80004d32:	cdc080e7          	jalr	-804(ra) # 80001a0a <myproc>
    80004d36:	892a                	mv	s2,a0

  begin_op();
    80004d38:	fffff097          	auipc	ra,0xfffff
    80004d3c:	474080e7          	jalr	1140(ra) # 800041ac <begin_op>

  if((ip = namei(path)) == 0){
    80004d40:	8526                	mv	a0,s1
    80004d42:	fffff097          	auipc	ra,0xfffff
    80004d46:	24e080e7          	jalr	590(ra) # 80003f90 <namei>
    80004d4a:	c92d                	beqz	a0,80004dbc <exec+0xbc>
    80004d4c:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004d4e:	fffff097          	auipc	ra,0xfffff
    80004d52:	a9c080e7          	jalr	-1380(ra) # 800037ea <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d56:	04000713          	li	a4,64
    80004d5a:	4681                	li	a3,0
    80004d5c:	e5040613          	addi	a2,s0,-432
    80004d60:	4581                	li	a1,0
    80004d62:	8526                	mv	a0,s1
    80004d64:	fffff097          	auipc	ra,0xfffff
    80004d68:	d3a080e7          	jalr	-710(ra) # 80003a9e <readi>
    80004d6c:	04000793          	li	a5,64
    80004d70:	00f51a63          	bne	a0,a5,80004d84 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004d74:	e5042703          	lw	a4,-432(s0)
    80004d78:	464c47b7          	lui	a5,0x464c4
    80004d7c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d80:	04f70463          	beq	a4,a5,80004dc8 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004d84:	8526                	mv	a0,s1
    80004d86:	fffff097          	auipc	ra,0xfffff
    80004d8a:	cc6080e7          	jalr	-826(ra) # 80003a4c <iunlockput>
    end_op();
    80004d8e:	fffff097          	auipc	ra,0xfffff
    80004d92:	49e080e7          	jalr	1182(ra) # 8000422c <end_op>
  }
  return -1;
    80004d96:	557d                	li	a0,-1
}
    80004d98:	20813083          	ld	ra,520(sp)
    80004d9c:	20013403          	ld	s0,512(sp)
    80004da0:	74fe                	ld	s1,504(sp)
    80004da2:	795e                	ld	s2,496(sp)
    80004da4:	79be                	ld	s3,488(sp)
    80004da6:	7a1e                	ld	s4,480(sp)
    80004da8:	6afe                	ld	s5,472(sp)
    80004daa:	6b5e                	ld	s6,464(sp)
    80004dac:	6bbe                	ld	s7,456(sp)
    80004dae:	6c1e                	ld	s8,448(sp)
    80004db0:	7cfa                	ld	s9,440(sp)
    80004db2:	7d5a                	ld	s10,432(sp)
    80004db4:	7dba                	ld	s11,424(sp)
    80004db6:	21010113          	addi	sp,sp,528
    80004dba:	8082                	ret
    end_op();
    80004dbc:	fffff097          	auipc	ra,0xfffff
    80004dc0:	470080e7          	jalr	1136(ra) # 8000422c <end_op>
    return -1;
    80004dc4:	557d                	li	a0,-1
    80004dc6:	bfc9                	j	80004d98 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004dc8:	854a                	mv	a0,s2
    80004dca:	ffffd097          	auipc	ra,0xffffd
    80004dce:	d06080e7          	jalr	-762(ra) # 80001ad0 <proc_pagetable>
    80004dd2:	8baa                	mv	s7,a0
    80004dd4:	d945                	beqz	a0,80004d84 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004dd6:	e7042983          	lw	s3,-400(s0)
    80004dda:	e8845783          	lhu	a5,-376(s0)
    80004dde:	c7ad                	beqz	a5,80004e48 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004de0:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004de2:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004de4:	6c85                	lui	s9,0x1
    80004de6:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004dea:	def43823          	sd	a5,-528(s0)
    80004dee:	ac0d                	j	80005020 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004df0:	00004517          	auipc	a0,0x4
    80004df4:	c6850513          	addi	a0,a0,-920 # 80008a58 <syscalls_name+0x288>
    80004df8:	ffffb097          	auipc	ra,0xffffb
    80004dfc:	774080e7          	jalr	1908(ra) # 8000056c <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004e00:	8756                	mv	a4,s5
    80004e02:	012d86bb          	addw	a3,s11,s2
    80004e06:	4581                	li	a1,0
    80004e08:	8526                	mv	a0,s1
    80004e0a:	fffff097          	auipc	ra,0xfffff
    80004e0e:	c94080e7          	jalr	-876(ra) # 80003a9e <readi>
    80004e12:	2501                	sext.w	a0,a0
    80004e14:	1aaa9a63          	bne	s5,a0,80004fc8 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    80004e18:	6785                	lui	a5,0x1
    80004e1a:	0127893b          	addw	s2,a5,s2
    80004e1e:	77fd                	lui	a5,0xfffff
    80004e20:	01478a3b          	addw	s4,a5,s4
    80004e24:	1f897563          	bgeu	s2,s8,8000500e <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80004e28:	02091593          	slli	a1,s2,0x20
    80004e2c:	9181                	srli	a1,a1,0x20
    80004e2e:	95ea                	add	a1,a1,s10
    80004e30:	855e                	mv	a0,s7
    80004e32:	ffffc097          	auipc	ra,0xffffc
    80004e36:	288080e7          	jalr	648(ra) # 800010ba <walkaddr>
    80004e3a:	862a                	mv	a2,a0
    if(pa == 0)
    80004e3c:	d955                	beqz	a0,80004df0 <exec+0xf0>
      n = PGSIZE;
    80004e3e:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004e40:	fd9a70e3          	bgeu	s4,s9,80004e00 <exec+0x100>
      n = sz - i;
    80004e44:	8ad2                	mv	s5,s4
    80004e46:	bf6d                	j	80004e00 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e48:	4a01                	li	s4,0
  iunlockput(ip);
    80004e4a:	8526                	mv	a0,s1
    80004e4c:	fffff097          	auipc	ra,0xfffff
    80004e50:	c00080e7          	jalr	-1024(ra) # 80003a4c <iunlockput>
  end_op();
    80004e54:	fffff097          	auipc	ra,0xfffff
    80004e58:	3d8080e7          	jalr	984(ra) # 8000422c <end_op>
  p = myproc();
    80004e5c:	ffffd097          	auipc	ra,0xffffd
    80004e60:	bae080e7          	jalr	-1106(ra) # 80001a0a <myproc>
    80004e64:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004e66:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80004e6a:	6785                	lui	a5,0x1
    80004e6c:	17fd                	addi	a5,a5,-1
    80004e6e:	9a3e                	add	s4,s4,a5
    80004e70:	757d                	lui	a0,0xfffff
    80004e72:	00aa77b3          	and	a5,s4,a0
    80004e76:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004e7a:	4691                	li	a3,4
    80004e7c:	6609                	lui	a2,0x2
    80004e7e:	963e                	add	a2,a2,a5
    80004e80:	85be                	mv	a1,a5
    80004e82:	855e                	mv	a0,s7
    80004e84:	ffffc097          	auipc	ra,0xffffc
    80004e88:	5ea080e7          	jalr	1514(ra) # 8000146e <uvmalloc>
    80004e8c:	8b2a                	mv	s6,a0
  ip = 0;
    80004e8e:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004e90:	12050c63          	beqz	a0,80004fc8 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004e94:	75f9                	lui	a1,0xffffe
    80004e96:	95aa                	add	a1,a1,a0
    80004e98:	855e                	mv	a0,s7
    80004e9a:	ffffc097          	auipc	ra,0xffffc
    80004e9e:	7fa080e7          	jalr	2042(ra) # 80001694 <uvmclear>
  stackbase = sp - PGSIZE;
    80004ea2:	7c7d                	lui	s8,0xfffff
    80004ea4:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004ea6:	e0043783          	ld	a5,-512(s0)
    80004eaa:	6388                	ld	a0,0(a5)
    80004eac:	c535                	beqz	a0,80004f18 <exec+0x218>
    80004eae:	e9040993          	addi	s3,s0,-368
    80004eb2:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004eb6:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004eb8:	ffffc097          	auipc	ra,0xffffc
    80004ebc:	fda080e7          	jalr	-38(ra) # 80000e92 <strlen>
    80004ec0:	2505                	addiw	a0,a0,1
    80004ec2:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ec6:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004eca:	13896663          	bltu	s2,s8,80004ff6 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ece:	e0043d83          	ld	s11,-512(s0)
    80004ed2:	000dba03          	ld	s4,0(s11)
    80004ed6:	8552                	mv	a0,s4
    80004ed8:	ffffc097          	auipc	ra,0xffffc
    80004edc:	fba080e7          	jalr	-70(ra) # 80000e92 <strlen>
    80004ee0:	0015069b          	addiw	a3,a0,1
    80004ee4:	8652                	mv	a2,s4
    80004ee6:	85ca                	mv	a1,s2
    80004ee8:	855e                	mv	a0,s7
    80004eea:	ffffc097          	auipc	ra,0xffffc
    80004eee:	7dc080e7          	jalr	2012(ra) # 800016c6 <copyout>
    80004ef2:	10054663          	bltz	a0,80004ffe <exec+0x2fe>
    ustack[argc] = sp;
    80004ef6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004efa:	0485                	addi	s1,s1,1
    80004efc:	008d8793          	addi	a5,s11,8
    80004f00:	e0f43023          	sd	a5,-512(s0)
    80004f04:	008db503          	ld	a0,8(s11)
    80004f08:	c911                	beqz	a0,80004f1c <exec+0x21c>
    if(argc >= MAXARG)
    80004f0a:	09a1                	addi	s3,s3,8
    80004f0c:	fb3c96e3          	bne	s9,s3,80004eb8 <exec+0x1b8>
  sz = sz1;
    80004f10:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004f14:	4481                	li	s1,0
    80004f16:	a84d                	j	80004fc8 <exec+0x2c8>
  sp = sz;
    80004f18:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004f1a:	4481                	li	s1,0
  ustack[argc] = 0;
    80004f1c:	00349793          	slli	a5,s1,0x3
    80004f20:	f9040713          	addi	a4,s0,-112
    80004f24:	97ba                	add	a5,a5,a4
    80004f26:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80004f2a:	00148693          	addi	a3,s1,1
    80004f2e:	068e                	slli	a3,a3,0x3
    80004f30:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f34:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004f38:	01897663          	bgeu	s2,s8,80004f44 <exec+0x244>
  sz = sz1;
    80004f3c:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004f40:	4481                	li	s1,0
    80004f42:	a059                	j	80004fc8 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f44:	e9040613          	addi	a2,s0,-368
    80004f48:	85ca                	mv	a1,s2
    80004f4a:	855e                	mv	a0,s7
    80004f4c:	ffffc097          	auipc	ra,0xffffc
    80004f50:	77a080e7          	jalr	1914(ra) # 800016c6 <copyout>
    80004f54:	0a054963          	bltz	a0,80005006 <exec+0x306>
  p->trapframe->a1 = sp;
    80004f58:	060ab783          	ld	a5,96(s5)
    80004f5c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f60:	df843783          	ld	a5,-520(s0)
    80004f64:	0007c703          	lbu	a4,0(a5)
    80004f68:	cf11                	beqz	a4,80004f84 <exec+0x284>
    80004f6a:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f6c:	02f00693          	li	a3,47
    80004f70:	a039                	j	80004f7e <exec+0x27e>
      last = s+1;
    80004f72:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004f76:	0785                	addi	a5,a5,1
    80004f78:	fff7c703          	lbu	a4,-1(a5)
    80004f7c:	c701                	beqz	a4,80004f84 <exec+0x284>
    if(*s == '/')
    80004f7e:	fed71ce3          	bne	a4,a3,80004f76 <exec+0x276>
    80004f82:	bfc5                	j	80004f72 <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f84:	4641                	li	a2,16
    80004f86:	df843583          	ld	a1,-520(s0)
    80004f8a:	160a8513          	addi	a0,s5,352
    80004f8e:	ffffc097          	auipc	ra,0xffffc
    80004f92:	ed2080e7          	jalr	-302(ra) # 80000e60 <safestrcpy>
  oldpagetable = p->pagetable;
    80004f96:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80004f9a:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    80004f9e:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004fa2:	060ab783          	ld	a5,96(s5)
    80004fa6:	e6843703          	ld	a4,-408(s0)
    80004faa:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004fac:	060ab783          	ld	a5,96(s5)
    80004fb0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004fb4:	85ea                	mv	a1,s10
    80004fb6:	ffffd097          	auipc	ra,0xffffd
    80004fba:	c28080e7          	jalr	-984(ra) # 80001bde <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004fbe:	0004851b          	sext.w	a0,s1
    80004fc2:	bbd9                	j	80004d98 <exec+0x98>
    80004fc4:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004fc8:	e0843583          	ld	a1,-504(s0)
    80004fcc:	855e                	mv	a0,s7
    80004fce:	ffffd097          	auipc	ra,0xffffd
    80004fd2:	c10080e7          	jalr	-1008(ra) # 80001bde <proc_freepagetable>
  if(ip){
    80004fd6:	da0497e3          	bnez	s1,80004d84 <exec+0x84>
  return -1;
    80004fda:	557d                	li	a0,-1
    80004fdc:	bb75                	j	80004d98 <exec+0x98>
    80004fde:	e1443423          	sd	s4,-504(s0)
    80004fe2:	b7dd                	j	80004fc8 <exec+0x2c8>
    80004fe4:	e1443423          	sd	s4,-504(s0)
    80004fe8:	b7c5                	j	80004fc8 <exec+0x2c8>
    80004fea:	e1443423          	sd	s4,-504(s0)
    80004fee:	bfe9                	j	80004fc8 <exec+0x2c8>
    80004ff0:	e1443423          	sd	s4,-504(s0)
    80004ff4:	bfd1                	j	80004fc8 <exec+0x2c8>
  sz = sz1;
    80004ff6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004ffa:	4481                	li	s1,0
    80004ffc:	b7f1                	j	80004fc8 <exec+0x2c8>
  sz = sz1;
    80004ffe:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005002:	4481                	li	s1,0
    80005004:	b7d1                	j	80004fc8 <exec+0x2c8>
  sz = sz1;
    80005006:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000500a:	4481                	li	s1,0
    8000500c:	bf75                	j	80004fc8 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000500e:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005012:	2b05                	addiw	s6,s6,1
    80005014:	0389899b          	addiw	s3,s3,56
    80005018:	e8845783          	lhu	a5,-376(s0)
    8000501c:	e2fb57e3          	bge	s6,a5,80004e4a <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005020:	2981                	sext.w	s3,s3
    80005022:	03800713          	li	a4,56
    80005026:	86ce                	mv	a3,s3
    80005028:	e1840613          	addi	a2,s0,-488
    8000502c:	4581                	li	a1,0
    8000502e:	8526                	mv	a0,s1
    80005030:	fffff097          	auipc	ra,0xfffff
    80005034:	a6e080e7          	jalr	-1426(ra) # 80003a9e <readi>
    80005038:	03800793          	li	a5,56
    8000503c:	f8f514e3          	bne	a0,a5,80004fc4 <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    80005040:	e1842783          	lw	a5,-488(s0)
    80005044:	4705                	li	a4,1
    80005046:	fce796e3          	bne	a5,a4,80005012 <exec+0x312>
    if(ph.memsz < ph.filesz)
    8000504a:	e4043903          	ld	s2,-448(s0)
    8000504e:	e3843783          	ld	a5,-456(s0)
    80005052:	f8f966e3          	bltu	s2,a5,80004fde <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005056:	e2843783          	ld	a5,-472(s0)
    8000505a:	993e                	add	s2,s2,a5
    8000505c:	f8f964e3          	bltu	s2,a5,80004fe4 <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    80005060:	df043703          	ld	a4,-528(s0)
    80005064:	8ff9                	and	a5,a5,a4
    80005066:	f3d1                	bnez	a5,80004fea <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005068:	e1c42503          	lw	a0,-484(s0)
    8000506c:	00000097          	auipc	ra,0x0
    80005070:	c78080e7          	jalr	-904(ra) # 80004ce4 <flags2perm>
    80005074:	86aa                	mv	a3,a0
    80005076:	864a                	mv	a2,s2
    80005078:	85d2                	mv	a1,s4
    8000507a:	855e                	mv	a0,s7
    8000507c:	ffffc097          	auipc	ra,0xffffc
    80005080:	3f2080e7          	jalr	1010(ra) # 8000146e <uvmalloc>
    80005084:	e0a43423          	sd	a0,-504(s0)
    80005088:	d525                	beqz	a0,80004ff0 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000508a:	e2843d03          	ld	s10,-472(s0)
    8000508e:	e2042d83          	lw	s11,-480(s0)
    80005092:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005096:	f60c0ce3          	beqz	s8,8000500e <exec+0x30e>
    8000509a:	8a62                	mv	s4,s8
    8000509c:	4901                	li	s2,0
    8000509e:	b369                	j	80004e28 <exec+0x128>

00000000800050a0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800050a0:	7179                	addi	sp,sp,-48
    800050a2:	f406                	sd	ra,40(sp)
    800050a4:	f022                	sd	s0,32(sp)
    800050a6:	ec26                	sd	s1,24(sp)
    800050a8:	e84a                	sd	s2,16(sp)
    800050aa:	1800                	addi	s0,sp,48
    800050ac:	892e                	mv	s2,a1
    800050ae:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800050b0:	fdc40593          	addi	a1,s0,-36
    800050b4:	ffffe097          	auipc	ra,0xffffe
    800050b8:	b4e080e7          	jalr	-1202(ra) # 80002c02 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800050bc:	fdc42703          	lw	a4,-36(s0)
    800050c0:	47bd                	li	a5,15
    800050c2:	02e7eb63          	bltu	a5,a4,800050f8 <argfd+0x58>
    800050c6:	ffffd097          	auipc	ra,0xffffd
    800050ca:	944080e7          	jalr	-1724(ra) # 80001a0a <myproc>
    800050ce:	fdc42703          	lw	a4,-36(s0)
    800050d2:	01a70793          	addi	a5,a4,26
    800050d6:	078e                	slli	a5,a5,0x3
    800050d8:	953e                	add	a0,a0,a5
    800050da:	651c                	ld	a5,8(a0)
    800050dc:	c385                	beqz	a5,800050fc <argfd+0x5c>
    return -1;
  if(pfd)
    800050de:	00090463          	beqz	s2,800050e6 <argfd+0x46>
    *pfd = fd;
    800050e2:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800050e6:	4501                	li	a0,0
  if(pf)
    800050e8:	c091                	beqz	s1,800050ec <argfd+0x4c>
    *pf = f;
    800050ea:	e09c                	sd	a5,0(s1)
}
    800050ec:	70a2                	ld	ra,40(sp)
    800050ee:	7402                	ld	s0,32(sp)
    800050f0:	64e2                	ld	s1,24(sp)
    800050f2:	6942                	ld	s2,16(sp)
    800050f4:	6145                	addi	sp,sp,48
    800050f6:	8082                	ret
    return -1;
    800050f8:	557d                	li	a0,-1
    800050fa:	bfcd                	j	800050ec <argfd+0x4c>
    800050fc:	557d                	li	a0,-1
    800050fe:	b7fd                	j	800050ec <argfd+0x4c>

0000000080005100 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005100:	1101                	addi	sp,sp,-32
    80005102:	ec06                	sd	ra,24(sp)
    80005104:	e822                	sd	s0,16(sp)
    80005106:	e426                	sd	s1,8(sp)
    80005108:	1000                	addi	s0,sp,32
    8000510a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000510c:	ffffd097          	auipc	ra,0xffffd
    80005110:	8fe080e7          	jalr	-1794(ra) # 80001a0a <myproc>
    80005114:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005116:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7ffdcde8>
    8000511a:	4501                	li	a0,0
    8000511c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000511e:	6398                	ld	a4,0(a5)
    80005120:	cb19                	beqz	a4,80005136 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005122:	2505                	addiw	a0,a0,1
    80005124:	07a1                	addi	a5,a5,8
    80005126:	fed51ce3          	bne	a0,a3,8000511e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000512a:	557d                	li	a0,-1
}
    8000512c:	60e2                	ld	ra,24(sp)
    8000512e:	6442                	ld	s0,16(sp)
    80005130:	64a2                	ld	s1,8(sp)
    80005132:	6105                	addi	sp,sp,32
    80005134:	8082                	ret
      p->ofile[fd] = f;
    80005136:	01a50793          	addi	a5,a0,26
    8000513a:	078e                	slli	a5,a5,0x3
    8000513c:	963e                	add	a2,a2,a5
    8000513e:	e604                	sd	s1,8(a2)
      return fd;
    80005140:	b7f5                	j	8000512c <fdalloc+0x2c>

0000000080005142 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005142:	715d                	addi	sp,sp,-80
    80005144:	e486                	sd	ra,72(sp)
    80005146:	e0a2                	sd	s0,64(sp)
    80005148:	fc26                	sd	s1,56(sp)
    8000514a:	f84a                	sd	s2,48(sp)
    8000514c:	f44e                	sd	s3,40(sp)
    8000514e:	f052                	sd	s4,32(sp)
    80005150:	ec56                	sd	s5,24(sp)
    80005152:	e85a                	sd	s6,16(sp)
    80005154:	0880                	addi	s0,sp,80
    80005156:	8b2e                	mv	s6,a1
    80005158:	89b2                	mv	s3,a2
    8000515a:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000515c:	fb040593          	addi	a1,s0,-80
    80005160:	fffff097          	auipc	ra,0xfffff
    80005164:	e4e080e7          	jalr	-434(ra) # 80003fae <nameiparent>
    80005168:	84aa                	mv	s1,a0
    8000516a:	16050063          	beqz	a0,800052ca <create+0x188>
    return 0;

  ilock(dp);
    8000516e:	ffffe097          	auipc	ra,0xffffe
    80005172:	67c080e7          	jalr	1660(ra) # 800037ea <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005176:	4601                	li	a2,0
    80005178:	fb040593          	addi	a1,s0,-80
    8000517c:	8526                	mv	a0,s1
    8000517e:	fffff097          	auipc	ra,0xfffff
    80005182:	b50080e7          	jalr	-1200(ra) # 80003cce <dirlookup>
    80005186:	8aaa                	mv	s5,a0
    80005188:	c931                	beqz	a0,800051dc <create+0x9a>
    iunlockput(dp);
    8000518a:	8526                	mv	a0,s1
    8000518c:	fffff097          	auipc	ra,0xfffff
    80005190:	8c0080e7          	jalr	-1856(ra) # 80003a4c <iunlockput>
    ilock(ip);
    80005194:	8556                	mv	a0,s5
    80005196:	ffffe097          	auipc	ra,0xffffe
    8000519a:	654080e7          	jalr	1620(ra) # 800037ea <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000519e:	000b059b          	sext.w	a1,s6
    800051a2:	4789                	li	a5,2
    800051a4:	02f59563          	bne	a1,a5,800051ce <create+0x8c>
    800051a8:	044ad783          	lhu	a5,68(s5)
    800051ac:	37f9                	addiw	a5,a5,-2
    800051ae:	17c2                	slli	a5,a5,0x30
    800051b0:	93c1                	srli	a5,a5,0x30
    800051b2:	4705                	li	a4,1
    800051b4:	00f76d63          	bltu	a4,a5,800051ce <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800051b8:	8556                	mv	a0,s5
    800051ba:	60a6                	ld	ra,72(sp)
    800051bc:	6406                	ld	s0,64(sp)
    800051be:	74e2                	ld	s1,56(sp)
    800051c0:	7942                	ld	s2,48(sp)
    800051c2:	79a2                	ld	s3,40(sp)
    800051c4:	7a02                	ld	s4,32(sp)
    800051c6:	6ae2                	ld	s5,24(sp)
    800051c8:	6b42                	ld	s6,16(sp)
    800051ca:	6161                	addi	sp,sp,80
    800051cc:	8082                	ret
    iunlockput(ip);
    800051ce:	8556                	mv	a0,s5
    800051d0:	fffff097          	auipc	ra,0xfffff
    800051d4:	87c080e7          	jalr	-1924(ra) # 80003a4c <iunlockput>
    return 0;
    800051d8:	4a81                	li	s5,0
    800051da:	bff9                	j	800051b8 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800051dc:	85da                	mv	a1,s6
    800051de:	4088                	lw	a0,0(s1)
    800051e0:	ffffe097          	auipc	ra,0xffffe
    800051e4:	46e080e7          	jalr	1134(ra) # 8000364e <ialloc>
    800051e8:	8a2a                	mv	s4,a0
    800051ea:	c921                	beqz	a0,8000523a <create+0xf8>
  ilock(ip);
    800051ec:	ffffe097          	auipc	ra,0xffffe
    800051f0:	5fe080e7          	jalr	1534(ra) # 800037ea <ilock>
  ip->major = major;
    800051f4:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800051f8:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800051fc:	4785                	li	a5,1
    800051fe:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    80005202:	8552                	mv	a0,s4
    80005204:	ffffe097          	auipc	ra,0xffffe
    80005208:	51c080e7          	jalr	1308(ra) # 80003720 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000520c:	000b059b          	sext.w	a1,s6
    80005210:	4785                	li	a5,1
    80005212:	02f58b63          	beq	a1,a5,80005248 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    80005216:	004a2603          	lw	a2,4(s4)
    8000521a:	fb040593          	addi	a1,s0,-80
    8000521e:	8526                	mv	a0,s1
    80005220:	fffff097          	auipc	ra,0xfffff
    80005224:	cbe080e7          	jalr	-834(ra) # 80003ede <dirlink>
    80005228:	06054f63          	bltz	a0,800052a6 <create+0x164>
  iunlockput(dp);
    8000522c:	8526                	mv	a0,s1
    8000522e:	fffff097          	auipc	ra,0xfffff
    80005232:	81e080e7          	jalr	-2018(ra) # 80003a4c <iunlockput>
  return ip;
    80005236:	8ad2                	mv	s5,s4
    80005238:	b741                	j	800051b8 <create+0x76>
    iunlockput(dp);
    8000523a:	8526                	mv	a0,s1
    8000523c:	fffff097          	auipc	ra,0xfffff
    80005240:	810080e7          	jalr	-2032(ra) # 80003a4c <iunlockput>
    return 0;
    80005244:	8ad2                	mv	s5,s4
    80005246:	bf8d                	j	800051b8 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005248:	004a2603          	lw	a2,4(s4)
    8000524c:	00004597          	auipc	a1,0x4
    80005250:	82c58593          	addi	a1,a1,-2004 # 80008a78 <syscalls_name+0x2a8>
    80005254:	8552                	mv	a0,s4
    80005256:	fffff097          	auipc	ra,0xfffff
    8000525a:	c88080e7          	jalr	-888(ra) # 80003ede <dirlink>
    8000525e:	04054463          	bltz	a0,800052a6 <create+0x164>
    80005262:	40d0                	lw	a2,4(s1)
    80005264:	00004597          	auipc	a1,0x4
    80005268:	81c58593          	addi	a1,a1,-2020 # 80008a80 <syscalls_name+0x2b0>
    8000526c:	8552                	mv	a0,s4
    8000526e:	fffff097          	auipc	ra,0xfffff
    80005272:	c70080e7          	jalr	-912(ra) # 80003ede <dirlink>
    80005276:	02054863          	bltz	a0,800052a6 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    8000527a:	004a2603          	lw	a2,4(s4)
    8000527e:	fb040593          	addi	a1,s0,-80
    80005282:	8526                	mv	a0,s1
    80005284:	fffff097          	auipc	ra,0xfffff
    80005288:	c5a080e7          	jalr	-934(ra) # 80003ede <dirlink>
    8000528c:	00054d63          	bltz	a0,800052a6 <create+0x164>
    dp->nlink++;  // for ".."
    80005290:	04a4d783          	lhu	a5,74(s1)
    80005294:	2785                	addiw	a5,a5,1
    80005296:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000529a:	8526                	mv	a0,s1
    8000529c:	ffffe097          	auipc	ra,0xffffe
    800052a0:	484080e7          	jalr	1156(ra) # 80003720 <iupdate>
    800052a4:	b761                	j	8000522c <create+0xea>
  ip->nlink = 0;
    800052a6:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800052aa:	8552                	mv	a0,s4
    800052ac:	ffffe097          	auipc	ra,0xffffe
    800052b0:	474080e7          	jalr	1140(ra) # 80003720 <iupdate>
  iunlockput(ip);
    800052b4:	8552                	mv	a0,s4
    800052b6:	ffffe097          	auipc	ra,0xffffe
    800052ba:	796080e7          	jalr	1942(ra) # 80003a4c <iunlockput>
  iunlockput(dp);
    800052be:	8526                	mv	a0,s1
    800052c0:	ffffe097          	auipc	ra,0xffffe
    800052c4:	78c080e7          	jalr	1932(ra) # 80003a4c <iunlockput>
  return 0;
    800052c8:	bdc5                	j	800051b8 <create+0x76>
    return 0;
    800052ca:	8aaa                	mv	s5,a0
    800052cc:	b5f5                	j	800051b8 <create+0x76>

00000000800052ce <sys_dup>:
{
    800052ce:	7179                	addi	sp,sp,-48
    800052d0:	f406                	sd	ra,40(sp)
    800052d2:	f022                	sd	s0,32(sp)
    800052d4:	ec26                	sd	s1,24(sp)
    800052d6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800052d8:	fd840613          	addi	a2,s0,-40
    800052dc:	4581                	li	a1,0
    800052de:	4501                	li	a0,0
    800052e0:	00000097          	auipc	ra,0x0
    800052e4:	dc0080e7          	jalr	-576(ra) # 800050a0 <argfd>
    return -1;
    800052e8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800052ea:	02054363          	bltz	a0,80005310 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800052ee:	fd843503          	ld	a0,-40(s0)
    800052f2:	00000097          	auipc	ra,0x0
    800052f6:	e0e080e7          	jalr	-498(ra) # 80005100 <fdalloc>
    800052fa:	84aa                	mv	s1,a0
    return -1;
    800052fc:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800052fe:	00054963          	bltz	a0,80005310 <sys_dup+0x42>
  filedup(f);
    80005302:	fd843503          	ld	a0,-40(s0)
    80005306:	fffff097          	auipc	ra,0xfffff
    8000530a:	320080e7          	jalr	800(ra) # 80004626 <filedup>
  return fd;
    8000530e:	87a6                	mv	a5,s1
}
    80005310:	853e                	mv	a0,a5
    80005312:	70a2                	ld	ra,40(sp)
    80005314:	7402                	ld	s0,32(sp)
    80005316:	64e2                	ld	s1,24(sp)
    80005318:	6145                	addi	sp,sp,48
    8000531a:	8082                	ret

000000008000531c <sys_read>:
{
    8000531c:	7179                	addi	sp,sp,-48
    8000531e:	f406                	sd	ra,40(sp)
    80005320:	f022                	sd	s0,32(sp)
    80005322:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005324:	fd840593          	addi	a1,s0,-40
    80005328:	4505                	li	a0,1
    8000532a:	ffffe097          	auipc	ra,0xffffe
    8000532e:	8f8080e7          	jalr	-1800(ra) # 80002c22 <argaddr>
  argint(2, &n);
    80005332:	fe440593          	addi	a1,s0,-28
    80005336:	4509                	li	a0,2
    80005338:	ffffe097          	auipc	ra,0xffffe
    8000533c:	8ca080e7          	jalr	-1846(ra) # 80002c02 <argint>
  if(argfd(0, 0, &f) < 0)
    80005340:	fe840613          	addi	a2,s0,-24
    80005344:	4581                	li	a1,0
    80005346:	4501                	li	a0,0
    80005348:	00000097          	auipc	ra,0x0
    8000534c:	d58080e7          	jalr	-680(ra) # 800050a0 <argfd>
    80005350:	87aa                	mv	a5,a0
    return -1;
    80005352:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005354:	0007cc63          	bltz	a5,8000536c <sys_read+0x50>
  return fileread(f, p, n);
    80005358:	fe442603          	lw	a2,-28(s0)
    8000535c:	fd843583          	ld	a1,-40(s0)
    80005360:	fe843503          	ld	a0,-24(s0)
    80005364:	fffff097          	auipc	ra,0xfffff
    80005368:	44e080e7          	jalr	1102(ra) # 800047b2 <fileread>
}
    8000536c:	70a2                	ld	ra,40(sp)
    8000536e:	7402                	ld	s0,32(sp)
    80005370:	6145                	addi	sp,sp,48
    80005372:	8082                	ret

0000000080005374 <sys_write>:
{
    80005374:	7179                	addi	sp,sp,-48
    80005376:	f406                	sd	ra,40(sp)
    80005378:	f022                	sd	s0,32(sp)
    8000537a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000537c:	fd840593          	addi	a1,s0,-40
    80005380:	4505                	li	a0,1
    80005382:	ffffe097          	auipc	ra,0xffffe
    80005386:	8a0080e7          	jalr	-1888(ra) # 80002c22 <argaddr>
  argint(2, &n);
    8000538a:	fe440593          	addi	a1,s0,-28
    8000538e:	4509                	li	a0,2
    80005390:	ffffe097          	auipc	ra,0xffffe
    80005394:	872080e7          	jalr	-1934(ra) # 80002c02 <argint>
  if(argfd(0, 0, &f) < 0)
    80005398:	fe840613          	addi	a2,s0,-24
    8000539c:	4581                	li	a1,0
    8000539e:	4501                	li	a0,0
    800053a0:	00000097          	auipc	ra,0x0
    800053a4:	d00080e7          	jalr	-768(ra) # 800050a0 <argfd>
    800053a8:	87aa                	mv	a5,a0
    return -1;
    800053aa:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800053ac:	0007cc63          	bltz	a5,800053c4 <sys_write+0x50>
  return filewrite(f, p, n);
    800053b0:	fe442603          	lw	a2,-28(s0)
    800053b4:	fd843583          	ld	a1,-40(s0)
    800053b8:	fe843503          	ld	a0,-24(s0)
    800053bc:	fffff097          	auipc	ra,0xfffff
    800053c0:	4b8080e7          	jalr	1208(ra) # 80004874 <filewrite>
}
    800053c4:	70a2                	ld	ra,40(sp)
    800053c6:	7402                	ld	s0,32(sp)
    800053c8:	6145                	addi	sp,sp,48
    800053ca:	8082                	ret

00000000800053cc <sys_close>:
{
    800053cc:	1101                	addi	sp,sp,-32
    800053ce:	ec06                	sd	ra,24(sp)
    800053d0:	e822                	sd	s0,16(sp)
    800053d2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800053d4:	fe040613          	addi	a2,s0,-32
    800053d8:	fec40593          	addi	a1,s0,-20
    800053dc:	4501                	li	a0,0
    800053de:	00000097          	auipc	ra,0x0
    800053e2:	cc2080e7          	jalr	-830(ra) # 800050a0 <argfd>
    return -1;
    800053e6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800053e8:	02054463          	bltz	a0,80005410 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800053ec:	ffffc097          	auipc	ra,0xffffc
    800053f0:	61e080e7          	jalr	1566(ra) # 80001a0a <myproc>
    800053f4:	fec42783          	lw	a5,-20(s0)
    800053f8:	07e9                	addi	a5,a5,26
    800053fa:	078e                	slli	a5,a5,0x3
    800053fc:	97aa                	add	a5,a5,a0
    800053fe:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005402:	fe043503          	ld	a0,-32(s0)
    80005406:	fffff097          	auipc	ra,0xfffff
    8000540a:	272080e7          	jalr	626(ra) # 80004678 <fileclose>
  return 0;
    8000540e:	4781                	li	a5,0
}
    80005410:	853e                	mv	a0,a5
    80005412:	60e2                	ld	ra,24(sp)
    80005414:	6442                	ld	s0,16(sp)
    80005416:	6105                	addi	sp,sp,32
    80005418:	8082                	ret

000000008000541a <sys_fstat>:
{
    8000541a:	1101                	addi	sp,sp,-32
    8000541c:	ec06                	sd	ra,24(sp)
    8000541e:	e822                	sd	s0,16(sp)
    80005420:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005422:	fe040593          	addi	a1,s0,-32
    80005426:	4505                	li	a0,1
    80005428:	ffffd097          	auipc	ra,0xffffd
    8000542c:	7fa080e7          	jalr	2042(ra) # 80002c22 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005430:	fe840613          	addi	a2,s0,-24
    80005434:	4581                	li	a1,0
    80005436:	4501                	li	a0,0
    80005438:	00000097          	auipc	ra,0x0
    8000543c:	c68080e7          	jalr	-920(ra) # 800050a0 <argfd>
    80005440:	87aa                	mv	a5,a0
    return -1;
    80005442:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005444:	0007ca63          	bltz	a5,80005458 <sys_fstat+0x3e>
  return filestat(f, st);
    80005448:	fe043583          	ld	a1,-32(s0)
    8000544c:	fe843503          	ld	a0,-24(s0)
    80005450:	fffff097          	auipc	ra,0xfffff
    80005454:	2f0080e7          	jalr	752(ra) # 80004740 <filestat>
}
    80005458:	60e2                	ld	ra,24(sp)
    8000545a:	6442                	ld	s0,16(sp)
    8000545c:	6105                	addi	sp,sp,32
    8000545e:	8082                	ret

0000000080005460 <sys_link>:
{
    80005460:	7169                	addi	sp,sp,-304
    80005462:	f606                	sd	ra,296(sp)
    80005464:	f222                	sd	s0,288(sp)
    80005466:	ee26                	sd	s1,280(sp)
    80005468:	ea4a                	sd	s2,272(sp)
    8000546a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000546c:	08000613          	li	a2,128
    80005470:	ed040593          	addi	a1,s0,-304
    80005474:	4501                	li	a0,0
    80005476:	ffffd097          	auipc	ra,0xffffd
    8000547a:	7cc080e7          	jalr	1996(ra) # 80002c42 <argstr>
    return -1;
    8000547e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005480:	10054e63          	bltz	a0,8000559c <sys_link+0x13c>
    80005484:	08000613          	li	a2,128
    80005488:	f5040593          	addi	a1,s0,-176
    8000548c:	4505                	li	a0,1
    8000548e:	ffffd097          	auipc	ra,0xffffd
    80005492:	7b4080e7          	jalr	1972(ra) # 80002c42 <argstr>
    return -1;
    80005496:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005498:	10054263          	bltz	a0,8000559c <sys_link+0x13c>
  begin_op();
    8000549c:	fffff097          	auipc	ra,0xfffff
    800054a0:	d10080e7          	jalr	-752(ra) # 800041ac <begin_op>
  if((ip = namei(old)) == 0){
    800054a4:	ed040513          	addi	a0,s0,-304
    800054a8:	fffff097          	auipc	ra,0xfffff
    800054ac:	ae8080e7          	jalr	-1304(ra) # 80003f90 <namei>
    800054b0:	84aa                	mv	s1,a0
    800054b2:	c551                	beqz	a0,8000553e <sys_link+0xde>
  ilock(ip);
    800054b4:	ffffe097          	auipc	ra,0xffffe
    800054b8:	336080e7          	jalr	822(ra) # 800037ea <ilock>
  if(ip->type == T_DIR){
    800054bc:	04449703          	lh	a4,68(s1)
    800054c0:	4785                	li	a5,1
    800054c2:	08f70463          	beq	a4,a5,8000554a <sys_link+0xea>
  ip->nlink++;
    800054c6:	04a4d783          	lhu	a5,74(s1)
    800054ca:	2785                	addiw	a5,a5,1
    800054cc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054d0:	8526                	mv	a0,s1
    800054d2:	ffffe097          	auipc	ra,0xffffe
    800054d6:	24e080e7          	jalr	590(ra) # 80003720 <iupdate>
  iunlock(ip);
    800054da:	8526                	mv	a0,s1
    800054dc:	ffffe097          	auipc	ra,0xffffe
    800054e0:	3d0080e7          	jalr	976(ra) # 800038ac <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800054e4:	fd040593          	addi	a1,s0,-48
    800054e8:	f5040513          	addi	a0,s0,-176
    800054ec:	fffff097          	auipc	ra,0xfffff
    800054f0:	ac2080e7          	jalr	-1342(ra) # 80003fae <nameiparent>
    800054f4:	892a                	mv	s2,a0
    800054f6:	c935                	beqz	a0,8000556a <sys_link+0x10a>
  ilock(dp);
    800054f8:	ffffe097          	auipc	ra,0xffffe
    800054fc:	2f2080e7          	jalr	754(ra) # 800037ea <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005500:	00092703          	lw	a4,0(s2)
    80005504:	409c                	lw	a5,0(s1)
    80005506:	04f71d63          	bne	a4,a5,80005560 <sys_link+0x100>
    8000550a:	40d0                	lw	a2,4(s1)
    8000550c:	fd040593          	addi	a1,s0,-48
    80005510:	854a                	mv	a0,s2
    80005512:	fffff097          	auipc	ra,0xfffff
    80005516:	9cc080e7          	jalr	-1588(ra) # 80003ede <dirlink>
    8000551a:	04054363          	bltz	a0,80005560 <sys_link+0x100>
  iunlockput(dp);
    8000551e:	854a                	mv	a0,s2
    80005520:	ffffe097          	auipc	ra,0xffffe
    80005524:	52c080e7          	jalr	1324(ra) # 80003a4c <iunlockput>
  iput(ip);
    80005528:	8526                	mv	a0,s1
    8000552a:	ffffe097          	auipc	ra,0xffffe
    8000552e:	47a080e7          	jalr	1146(ra) # 800039a4 <iput>
  end_op();
    80005532:	fffff097          	auipc	ra,0xfffff
    80005536:	cfa080e7          	jalr	-774(ra) # 8000422c <end_op>
  return 0;
    8000553a:	4781                	li	a5,0
    8000553c:	a085                	j	8000559c <sys_link+0x13c>
    end_op();
    8000553e:	fffff097          	auipc	ra,0xfffff
    80005542:	cee080e7          	jalr	-786(ra) # 8000422c <end_op>
    return -1;
    80005546:	57fd                	li	a5,-1
    80005548:	a891                	j	8000559c <sys_link+0x13c>
    iunlockput(ip);
    8000554a:	8526                	mv	a0,s1
    8000554c:	ffffe097          	auipc	ra,0xffffe
    80005550:	500080e7          	jalr	1280(ra) # 80003a4c <iunlockput>
    end_op();
    80005554:	fffff097          	auipc	ra,0xfffff
    80005558:	cd8080e7          	jalr	-808(ra) # 8000422c <end_op>
    return -1;
    8000555c:	57fd                	li	a5,-1
    8000555e:	a83d                	j	8000559c <sys_link+0x13c>
    iunlockput(dp);
    80005560:	854a                	mv	a0,s2
    80005562:	ffffe097          	auipc	ra,0xffffe
    80005566:	4ea080e7          	jalr	1258(ra) # 80003a4c <iunlockput>
  ilock(ip);
    8000556a:	8526                	mv	a0,s1
    8000556c:	ffffe097          	auipc	ra,0xffffe
    80005570:	27e080e7          	jalr	638(ra) # 800037ea <ilock>
  ip->nlink--;
    80005574:	04a4d783          	lhu	a5,74(s1)
    80005578:	37fd                	addiw	a5,a5,-1
    8000557a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000557e:	8526                	mv	a0,s1
    80005580:	ffffe097          	auipc	ra,0xffffe
    80005584:	1a0080e7          	jalr	416(ra) # 80003720 <iupdate>
  iunlockput(ip);
    80005588:	8526                	mv	a0,s1
    8000558a:	ffffe097          	auipc	ra,0xffffe
    8000558e:	4c2080e7          	jalr	1218(ra) # 80003a4c <iunlockput>
  end_op();
    80005592:	fffff097          	auipc	ra,0xfffff
    80005596:	c9a080e7          	jalr	-870(ra) # 8000422c <end_op>
  return -1;
    8000559a:	57fd                	li	a5,-1
}
    8000559c:	853e                	mv	a0,a5
    8000559e:	70b2                	ld	ra,296(sp)
    800055a0:	7412                	ld	s0,288(sp)
    800055a2:	64f2                	ld	s1,280(sp)
    800055a4:	6952                	ld	s2,272(sp)
    800055a6:	6155                	addi	sp,sp,304
    800055a8:	8082                	ret

00000000800055aa <sys_unlink>:
{
    800055aa:	7151                	addi	sp,sp,-240
    800055ac:	f586                	sd	ra,232(sp)
    800055ae:	f1a2                	sd	s0,224(sp)
    800055b0:	eda6                	sd	s1,216(sp)
    800055b2:	e9ca                	sd	s2,208(sp)
    800055b4:	e5ce                	sd	s3,200(sp)
    800055b6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800055b8:	08000613          	li	a2,128
    800055bc:	f3040593          	addi	a1,s0,-208
    800055c0:	4501                	li	a0,0
    800055c2:	ffffd097          	auipc	ra,0xffffd
    800055c6:	680080e7          	jalr	1664(ra) # 80002c42 <argstr>
    800055ca:	18054163          	bltz	a0,8000574c <sys_unlink+0x1a2>
  begin_op();
    800055ce:	fffff097          	auipc	ra,0xfffff
    800055d2:	bde080e7          	jalr	-1058(ra) # 800041ac <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800055d6:	fb040593          	addi	a1,s0,-80
    800055da:	f3040513          	addi	a0,s0,-208
    800055de:	fffff097          	auipc	ra,0xfffff
    800055e2:	9d0080e7          	jalr	-1584(ra) # 80003fae <nameiparent>
    800055e6:	84aa                	mv	s1,a0
    800055e8:	c979                	beqz	a0,800056be <sys_unlink+0x114>
  ilock(dp);
    800055ea:	ffffe097          	auipc	ra,0xffffe
    800055ee:	200080e7          	jalr	512(ra) # 800037ea <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800055f2:	00003597          	auipc	a1,0x3
    800055f6:	48658593          	addi	a1,a1,1158 # 80008a78 <syscalls_name+0x2a8>
    800055fa:	fb040513          	addi	a0,s0,-80
    800055fe:	ffffe097          	auipc	ra,0xffffe
    80005602:	6b6080e7          	jalr	1718(ra) # 80003cb4 <namecmp>
    80005606:	14050a63          	beqz	a0,8000575a <sys_unlink+0x1b0>
    8000560a:	00003597          	auipc	a1,0x3
    8000560e:	47658593          	addi	a1,a1,1142 # 80008a80 <syscalls_name+0x2b0>
    80005612:	fb040513          	addi	a0,s0,-80
    80005616:	ffffe097          	auipc	ra,0xffffe
    8000561a:	69e080e7          	jalr	1694(ra) # 80003cb4 <namecmp>
    8000561e:	12050e63          	beqz	a0,8000575a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005622:	f2c40613          	addi	a2,s0,-212
    80005626:	fb040593          	addi	a1,s0,-80
    8000562a:	8526                	mv	a0,s1
    8000562c:	ffffe097          	auipc	ra,0xffffe
    80005630:	6a2080e7          	jalr	1698(ra) # 80003cce <dirlookup>
    80005634:	892a                	mv	s2,a0
    80005636:	12050263          	beqz	a0,8000575a <sys_unlink+0x1b0>
  ilock(ip);
    8000563a:	ffffe097          	auipc	ra,0xffffe
    8000563e:	1b0080e7          	jalr	432(ra) # 800037ea <ilock>
  if(ip->nlink < 1)
    80005642:	04a91783          	lh	a5,74(s2)
    80005646:	08f05263          	blez	a5,800056ca <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000564a:	04491703          	lh	a4,68(s2)
    8000564e:	4785                	li	a5,1
    80005650:	08f70563          	beq	a4,a5,800056da <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005654:	4641                	li	a2,16
    80005656:	4581                	li	a1,0
    80005658:	fc040513          	addi	a0,s0,-64
    8000565c:	ffffb097          	auipc	ra,0xffffb
    80005660:	6b2080e7          	jalr	1714(ra) # 80000d0e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005664:	4741                	li	a4,16
    80005666:	f2c42683          	lw	a3,-212(s0)
    8000566a:	fc040613          	addi	a2,s0,-64
    8000566e:	4581                	li	a1,0
    80005670:	8526                	mv	a0,s1
    80005672:	ffffe097          	auipc	ra,0xffffe
    80005676:	524080e7          	jalr	1316(ra) # 80003b96 <writei>
    8000567a:	47c1                	li	a5,16
    8000567c:	0af51563          	bne	a0,a5,80005726 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005680:	04491703          	lh	a4,68(s2)
    80005684:	4785                	li	a5,1
    80005686:	0af70863          	beq	a4,a5,80005736 <sys_unlink+0x18c>
  iunlockput(dp);
    8000568a:	8526                	mv	a0,s1
    8000568c:	ffffe097          	auipc	ra,0xffffe
    80005690:	3c0080e7          	jalr	960(ra) # 80003a4c <iunlockput>
  ip->nlink--;
    80005694:	04a95783          	lhu	a5,74(s2)
    80005698:	37fd                	addiw	a5,a5,-1
    8000569a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000569e:	854a                	mv	a0,s2
    800056a0:	ffffe097          	auipc	ra,0xffffe
    800056a4:	080080e7          	jalr	128(ra) # 80003720 <iupdate>
  iunlockput(ip);
    800056a8:	854a                	mv	a0,s2
    800056aa:	ffffe097          	auipc	ra,0xffffe
    800056ae:	3a2080e7          	jalr	930(ra) # 80003a4c <iunlockput>
  end_op();
    800056b2:	fffff097          	auipc	ra,0xfffff
    800056b6:	b7a080e7          	jalr	-1158(ra) # 8000422c <end_op>
  return 0;
    800056ba:	4501                	li	a0,0
    800056bc:	a84d                	j	8000576e <sys_unlink+0x1c4>
    end_op();
    800056be:	fffff097          	auipc	ra,0xfffff
    800056c2:	b6e080e7          	jalr	-1170(ra) # 8000422c <end_op>
    return -1;
    800056c6:	557d                	li	a0,-1
    800056c8:	a05d                	j	8000576e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800056ca:	00003517          	auipc	a0,0x3
    800056ce:	3be50513          	addi	a0,a0,958 # 80008a88 <syscalls_name+0x2b8>
    800056d2:	ffffb097          	auipc	ra,0xffffb
    800056d6:	e9a080e7          	jalr	-358(ra) # 8000056c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056da:	04c92703          	lw	a4,76(s2)
    800056de:	02000793          	li	a5,32
    800056e2:	f6e7f9e3          	bgeu	a5,a4,80005654 <sys_unlink+0xaa>
    800056e6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056ea:	4741                	li	a4,16
    800056ec:	86ce                	mv	a3,s3
    800056ee:	f1840613          	addi	a2,s0,-232
    800056f2:	4581                	li	a1,0
    800056f4:	854a                	mv	a0,s2
    800056f6:	ffffe097          	auipc	ra,0xffffe
    800056fa:	3a8080e7          	jalr	936(ra) # 80003a9e <readi>
    800056fe:	47c1                	li	a5,16
    80005700:	00f51b63          	bne	a0,a5,80005716 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005704:	f1845783          	lhu	a5,-232(s0)
    80005708:	e7a1                	bnez	a5,80005750 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000570a:	29c1                	addiw	s3,s3,16
    8000570c:	04c92783          	lw	a5,76(s2)
    80005710:	fcf9ede3          	bltu	s3,a5,800056ea <sys_unlink+0x140>
    80005714:	b781                	j	80005654 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005716:	00003517          	auipc	a0,0x3
    8000571a:	38a50513          	addi	a0,a0,906 # 80008aa0 <syscalls_name+0x2d0>
    8000571e:	ffffb097          	auipc	ra,0xffffb
    80005722:	e4e080e7          	jalr	-434(ra) # 8000056c <panic>
    panic("unlink: writei");
    80005726:	00003517          	auipc	a0,0x3
    8000572a:	39250513          	addi	a0,a0,914 # 80008ab8 <syscalls_name+0x2e8>
    8000572e:	ffffb097          	auipc	ra,0xffffb
    80005732:	e3e080e7          	jalr	-450(ra) # 8000056c <panic>
    dp->nlink--;
    80005736:	04a4d783          	lhu	a5,74(s1)
    8000573a:	37fd                	addiw	a5,a5,-1
    8000573c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005740:	8526                	mv	a0,s1
    80005742:	ffffe097          	auipc	ra,0xffffe
    80005746:	fde080e7          	jalr	-34(ra) # 80003720 <iupdate>
    8000574a:	b781                	j	8000568a <sys_unlink+0xe0>
    return -1;
    8000574c:	557d                	li	a0,-1
    8000574e:	a005                	j	8000576e <sys_unlink+0x1c4>
    iunlockput(ip);
    80005750:	854a                	mv	a0,s2
    80005752:	ffffe097          	auipc	ra,0xffffe
    80005756:	2fa080e7          	jalr	762(ra) # 80003a4c <iunlockput>
  iunlockput(dp);
    8000575a:	8526                	mv	a0,s1
    8000575c:	ffffe097          	auipc	ra,0xffffe
    80005760:	2f0080e7          	jalr	752(ra) # 80003a4c <iunlockput>
  end_op();
    80005764:	fffff097          	auipc	ra,0xfffff
    80005768:	ac8080e7          	jalr	-1336(ra) # 8000422c <end_op>
  return -1;
    8000576c:	557d                	li	a0,-1
}
    8000576e:	70ae                	ld	ra,232(sp)
    80005770:	740e                	ld	s0,224(sp)
    80005772:	64ee                	ld	s1,216(sp)
    80005774:	694e                	ld	s2,208(sp)
    80005776:	69ae                	ld	s3,200(sp)
    80005778:	616d                	addi	sp,sp,240
    8000577a:	8082                	ret

000000008000577c <sys_open>:

uint64
sys_open(void)
{
    8000577c:	7131                	addi	sp,sp,-192
    8000577e:	fd06                	sd	ra,184(sp)
    80005780:	f922                	sd	s0,176(sp)
    80005782:	f526                	sd	s1,168(sp)
    80005784:	f14a                	sd	s2,160(sp)
    80005786:	ed4e                	sd	s3,152(sp)
    80005788:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000578a:	f4c40593          	addi	a1,s0,-180
    8000578e:	4505                	li	a0,1
    80005790:	ffffd097          	auipc	ra,0xffffd
    80005794:	472080e7          	jalr	1138(ra) # 80002c02 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005798:	08000613          	li	a2,128
    8000579c:	f5040593          	addi	a1,s0,-176
    800057a0:	4501                	li	a0,0
    800057a2:	ffffd097          	auipc	ra,0xffffd
    800057a6:	4a0080e7          	jalr	1184(ra) # 80002c42 <argstr>
    800057aa:	87aa                	mv	a5,a0
    return -1;
    800057ac:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800057ae:	0a07c963          	bltz	a5,80005860 <sys_open+0xe4>

  begin_op();
    800057b2:	fffff097          	auipc	ra,0xfffff
    800057b6:	9fa080e7          	jalr	-1542(ra) # 800041ac <begin_op>

  if(omode & O_CREATE){
    800057ba:	f4c42783          	lw	a5,-180(s0)
    800057be:	2007f793          	andi	a5,a5,512
    800057c2:	cfc5                	beqz	a5,8000587a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800057c4:	4681                	li	a3,0
    800057c6:	4601                	li	a2,0
    800057c8:	4589                	li	a1,2
    800057ca:	f5040513          	addi	a0,s0,-176
    800057ce:	00000097          	auipc	ra,0x0
    800057d2:	974080e7          	jalr	-1676(ra) # 80005142 <create>
    800057d6:	84aa                	mv	s1,a0
    if(ip == 0){
    800057d8:	c959                	beqz	a0,8000586e <sys_open+0xf2>
  }

  // There is no need to deal with symbolic links to directories.
  // YOUR CODE HERE

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800057da:	04449703          	lh	a4,68(s1)
    800057de:	478d                	li	a5,3
    800057e0:	00f71763          	bne	a4,a5,800057ee <sys_open+0x72>
    800057e4:	0464d703          	lhu	a4,70(s1)
    800057e8:	47a5                	li	a5,9
    800057ea:	0ce7ed63          	bltu	a5,a4,800058c4 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800057ee:	fffff097          	auipc	ra,0xfffff
    800057f2:	dce080e7          	jalr	-562(ra) # 800045bc <filealloc>
    800057f6:	89aa                	mv	s3,a0
    800057f8:	10050363          	beqz	a0,800058fe <sys_open+0x182>
    800057fc:	00000097          	auipc	ra,0x0
    80005800:	904080e7          	jalr	-1788(ra) # 80005100 <fdalloc>
    80005804:	892a                	mv	s2,a0
    80005806:	0e054763          	bltz	a0,800058f4 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000580a:	04449703          	lh	a4,68(s1)
    8000580e:	478d                	li	a5,3
    80005810:	0cf70563          	beq	a4,a5,800058da <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005814:	4789                	li	a5,2
    80005816:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000581a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000581e:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005822:	f4c42783          	lw	a5,-180(s0)
    80005826:	0017c713          	xori	a4,a5,1
    8000582a:	8b05                	andi	a4,a4,1
    8000582c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005830:	0037f713          	andi	a4,a5,3
    80005834:	00e03733          	snez	a4,a4
    80005838:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000583c:	4007f793          	andi	a5,a5,1024
    80005840:	c791                	beqz	a5,8000584c <sys_open+0xd0>
    80005842:	04449703          	lh	a4,68(s1)
    80005846:	4789                	li	a5,2
    80005848:	0af70063          	beq	a4,a5,800058e8 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000584c:	8526                	mv	a0,s1
    8000584e:	ffffe097          	auipc	ra,0xffffe
    80005852:	05e080e7          	jalr	94(ra) # 800038ac <iunlock>
  end_op();
    80005856:	fffff097          	auipc	ra,0xfffff
    8000585a:	9d6080e7          	jalr	-1578(ra) # 8000422c <end_op>

  return fd;
    8000585e:	854a                	mv	a0,s2
}
    80005860:	70ea                	ld	ra,184(sp)
    80005862:	744a                	ld	s0,176(sp)
    80005864:	74aa                	ld	s1,168(sp)
    80005866:	790a                	ld	s2,160(sp)
    80005868:	69ea                	ld	s3,152(sp)
    8000586a:	6129                	addi	sp,sp,192
    8000586c:	8082                	ret
      end_op();
    8000586e:	fffff097          	auipc	ra,0xfffff
    80005872:	9be080e7          	jalr	-1602(ra) # 8000422c <end_op>
      return -1;
    80005876:	557d                	li	a0,-1
    80005878:	b7e5                	j	80005860 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000587a:	f5040513          	addi	a0,s0,-176
    8000587e:	ffffe097          	auipc	ra,0xffffe
    80005882:	712080e7          	jalr	1810(ra) # 80003f90 <namei>
    80005886:	84aa                	mv	s1,a0
    80005888:	c905                	beqz	a0,800058b8 <sys_open+0x13c>
    ilock(ip);
    8000588a:	ffffe097          	auipc	ra,0xffffe
    8000588e:	f60080e7          	jalr	-160(ra) # 800037ea <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005892:	04449703          	lh	a4,68(s1)
    80005896:	4785                	li	a5,1
    80005898:	f4f711e3          	bne	a4,a5,800057da <sys_open+0x5e>
    8000589c:	f4c42783          	lw	a5,-180(s0)
    800058a0:	d7b9                	beqz	a5,800057ee <sys_open+0x72>
      iunlockput(ip);
    800058a2:	8526                	mv	a0,s1
    800058a4:	ffffe097          	auipc	ra,0xffffe
    800058a8:	1a8080e7          	jalr	424(ra) # 80003a4c <iunlockput>
      end_op();
    800058ac:	fffff097          	auipc	ra,0xfffff
    800058b0:	980080e7          	jalr	-1664(ra) # 8000422c <end_op>
      return -1;
    800058b4:	557d                	li	a0,-1
    800058b6:	b76d                	j	80005860 <sys_open+0xe4>
      end_op();
    800058b8:	fffff097          	auipc	ra,0xfffff
    800058bc:	974080e7          	jalr	-1676(ra) # 8000422c <end_op>
      return -1;
    800058c0:	557d                	li	a0,-1
    800058c2:	bf79                	j	80005860 <sys_open+0xe4>
    iunlockput(ip);
    800058c4:	8526                	mv	a0,s1
    800058c6:	ffffe097          	auipc	ra,0xffffe
    800058ca:	186080e7          	jalr	390(ra) # 80003a4c <iunlockput>
    end_op();
    800058ce:	fffff097          	auipc	ra,0xfffff
    800058d2:	95e080e7          	jalr	-1698(ra) # 8000422c <end_op>
    return -1;
    800058d6:	557d                	li	a0,-1
    800058d8:	b761                	j	80005860 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800058da:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800058de:	04649783          	lh	a5,70(s1)
    800058e2:	02f99223          	sh	a5,36(s3)
    800058e6:	bf25                	j	8000581e <sys_open+0xa2>
    itrunc(ip);
    800058e8:	8526                	mv	a0,s1
    800058ea:	ffffe097          	auipc	ra,0xffffe
    800058ee:	00e080e7          	jalr	14(ra) # 800038f8 <itrunc>
    800058f2:	bfa9                	j	8000584c <sys_open+0xd0>
      fileclose(f);
    800058f4:	854e                	mv	a0,s3
    800058f6:	fffff097          	auipc	ra,0xfffff
    800058fa:	d82080e7          	jalr	-638(ra) # 80004678 <fileclose>
    iunlockput(ip);
    800058fe:	8526                	mv	a0,s1
    80005900:	ffffe097          	auipc	ra,0xffffe
    80005904:	14c080e7          	jalr	332(ra) # 80003a4c <iunlockput>
    end_op();
    80005908:	fffff097          	auipc	ra,0xfffff
    8000590c:	924080e7          	jalr	-1756(ra) # 8000422c <end_op>
    return -1;
    80005910:	557d                	li	a0,-1
    80005912:	b7b9                	j	80005860 <sys_open+0xe4>

0000000080005914 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005914:	7175                	addi	sp,sp,-144
    80005916:	e506                	sd	ra,136(sp)
    80005918:	e122                	sd	s0,128(sp)
    8000591a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000591c:	fffff097          	auipc	ra,0xfffff
    80005920:	890080e7          	jalr	-1904(ra) # 800041ac <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005924:	08000613          	li	a2,128
    80005928:	f7040593          	addi	a1,s0,-144
    8000592c:	4501                	li	a0,0
    8000592e:	ffffd097          	auipc	ra,0xffffd
    80005932:	314080e7          	jalr	788(ra) # 80002c42 <argstr>
    80005936:	02054963          	bltz	a0,80005968 <sys_mkdir+0x54>
    8000593a:	4681                	li	a3,0
    8000593c:	4601                	li	a2,0
    8000593e:	4585                	li	a1,1
    80005940:	f7040513          	addi	a0,s0,-144
    80005944:	fffff097          	auipc	ra,0xfffff
    80005948:	7fe080e7          	jalr	2046(ra) # 80005142 <create>
    8000594c:	cd11                	beqz	a0,80005968 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000594e:	ffffe097          	auipc	ra,0xffffe
    80005952:	0fe080e7          	jalr	254(ra) # 80003a4c <iunlockput>
  end_op();
    80005956:	fffff097          	auipc	ra,0xfffff
    8000595a:	8d6080e7          	jalr	-1834(ra) # 8000422c <end_op>
  return 0;
    8000595e:	4501                	li	a0,0
}
    80005960:	60aa                	ld	ra,136(sp)
    80005962:	640a                	ld	s0,128(sp)
    80005964:	6149                	addi	sp,sp,144
    80005966:	8082                	ret
    end_op();
    80005968:	fffff097          	auipc	ra,0xfffff
    8000596c:	8c4080e7          	jalr	-1852(ra) # 8000422c <end_op>
    return -1;
    80005970:	557d                	li	a0,-1
    80005972:	b7fd                	j	80005960 <sys_mkdir+0x4c>

0000000080005974 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005974:	7135                	addi	sp,sp,-160
    80005976:	ed06                	sd	ra,152(sp)
    80005978:	e922                	sd	s0,144(sp)
    8000597a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000597c:	fffff097          	auipc	ra,0xfffff
    80005980:	830080e7          	jalr	-2000(ra) # 800041ac <begin_op>
  argint(1, &major);
    80005984:	f6c40593          	addi	a1,s0,-148
    80005988:	4505                	li	a0,1
    8000598a:	ffffd097          	auipc	ra,0xffffd
    8000598e:	278080e7          	jalr	632(ra) # 80002c02 <argint>
  argint(2, &minor);
    80005992:	f6840593          	addi	a1,s0,-152
    80005996:	4509                	li	a0,2
    80005998:	ffffd097          	auipc	ra,0xffffd
    8000599c:	26a080e7          	jalr	618(ra) # 80002c02 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059a0:	08000613          	li	a2,128
    800059a4:	f7040593          	addi	a1,s0,-144
    800059a8:	4501                	li	a0,0
    800059aa:	ffffd097          	auipc	ra,0xffffd
    800059ae:	298080e7          	jalr	664(ra) # 80002c42 <argstr>
    800059b2:	02054b63          	bltz	a0,800059e8 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800059b6:	f6841683          	lh	a3,-152(s0)
    800059ba:	f6c41603          	lh	a2,-148(s0)
    800059be:	458d                	li	a1,3
    800059c0:	f7040513          	addi	a0,s0,-144
    800059c4:	fffff097          	auipc	ra,0xfffff
    800059c8:	77e080e7          	jalr	1918(ra) # 80005142 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059cc:	cd11                	beqz	a0,800059e8 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059ce:	ffffe097          	auipc	ra,0xffffe
    800059d2:	07e080e7          	jalr	126(ra) # 80003a4c <iunlockput>
  end_op();
    800059d6:	fffff097          	auipc	ra,0xfffff
    800059da:	856080e7          	jalr	-1962(ra) # 8000422c <end_op>
  return 0;
    800059de:	4501                	li	a0,0
}
    800059e0:	60ea                	ld	ra,152(sp)
    800059e2:	644a                	ld	s0,144(sp)
    800059e4:	610d                	addi	sp,sp,160
    800059e6:	8082                	ret
    end_op();
    800059e8:	fffff097          	auipc	ra,0xfffff
    800059ec:	844080e7          	jalr	-1980(ra) # 8000422c <end_op>
    return -1;
    800059f0:	557d                	li	a0,-1
    800059f2:	b7fd                	j	800059e0 <sys_mknod+0x6c>

00000000800059f4 <sys_chdir>:

uint64
sys_chdir(void)
{
    800059f4:	7135                	addi	sp,sp,-160
    800059f6:	ed06                	sd	ra,152(sp)
    800059f8:	e922                	sd	s0,144(sp)
    800059fa:	e526                	sd	s1,136(sp)
    800059fc:	e14a                	sd	s2,128(sp)
    800059fe:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a00:	ffffc097          	auipc	ra,0xffffc
    80005a04:	00a080e7          	jalr	10(ra) # 80001a0a <myproc>
    80005a08:	892a                	mv	s2,a0
  
  begin_op();
    80005a0a:	ffffe097          	auipc	ra,0xffffe
    80005a0e:	7a2080e7          	jalr	1954(ra) # 800041ac <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a12:	08000613          	li	a2,128
    80005a16:	f6040593          	addi	a1,s0,-160
    80005a1a:	4501                	li	a0,0
    80005a1c:	ffffd097          	auipc	ra,0xffffd
    80005a20:	226080e7          	jalr	550(ra) # 80002c42 <argstr>
    80005a24:	04054b63          	bltz	a0,80005a7a <sys_chdir+0x86>
    80005a28:	f6040513          	addi	a0,s0,-160
    80005a2c:	ffffe097          	auipc	ra,0xffffe
    80005a30:	564080e7          	jalr	1380(ra) # 80003f90 <namei>
    80005a34:	84aa                	mv	s1,a0
    80005a36:	c131                	beqz	a0,80005a7a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005a38:	ffffe097          	auipc	ra,0xffffe
    80005a3c:	db2080e7          	jalr	-590(ra) # 800037ea <ilock>
  if(ip->type != T_DIR){
    80005a40:	04449703          	lh	a4,68(s1)
    80005a44:	4785                	li	a5,1
    80005a46:	04f71063          	bne	a4,a5,80005a86 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005a4a:	8526                	mv	a0,s1
    80005a4c:	ffffe097          	auipc	ra,0xffffe
    80005a50:	e60080e7          	jalr	-416(ra) # 800038ac <iunlock>
  iput(p->cwd);
    80005a54:	15893503          	ld	a0,344(s2)
    80005a58:	ffffe097          	auipc	ra,0xffffe
    80005a5c:	f4c080e7          	jalr	-180(ra) # 800039a4 <iput>
  end_op();
    80005a60:	ffffe097          	auipc	ra,0xffffe
    80005a64:	7cc080e7          	jalr	1996(ra) # 8000422c <end_op>
  p->cwd = ip;
    80005a68:	14993c23          	sd	s1,344(s2)
  return 0;
    80005a6c:	4501                	li	a0,0
}
    80005a6e:	60ea                	ld	ra,152(sp)
    80005a70:	644a                	ld	s0,144(sp)
    80005a72:	64aa                	ld	s1,136(sp)
    80005a74:	690a                	ld	s2,128(sp)
    80005a76:	610d                	addi	sp,sp,160
    80005a78:	8082                	ret
    end_op();
    80005a7a:	ffffe097          	auipc	ra,0xffffe
    80005a7e:	7b2080e7          	jalr	1970(ra) # 8000422c <end_op>
    return -1;
    80005a82:	557d                	li	a0,-1
    80005a84:	b7ed                	j	80005a6e <sys_chdir+0x7a>
    iunlockput(ip);
    80005a86:	8526                	mv	a0,s1
    80005a88:	ffffe097          	auipc	ra,0xffffe
    80005a8c:	fc4080e7          	jalr	-60(ra) # 80003a4c <iunlockput>
    end_op();
    80005a90:	ffffe097          	auipc	ra,0xffffe
    80005a94:	79c080e7          	jalr	1948(ra) # 8000422c <end_op>
    return -1;
    80005a98:	557d                	li	a0,-1
    80005a9a:	bfd1                	j	80005a6e <sys_chdir+0x7a>

0000000080005a9c <sys_exec>:

uint64
sys_exec(void)
{
    80005a9c:	7145                	addi	sp,sp,-464
    80005a9e:	e786                	sd	ra,456(sp)
    80005aa0:	e3a2                	sd	s0,448(sp)
    80005aa2:	ff26                	sd	s1,440(sp)
    80005aa4:	fb4a                	sd	s2,432(sp)
    80005aa6:	f74e                	sd	s3,424(sp)
    80005aa8:	f352                	sd	s4,416(sp)
    80005aaa:	ef56                	sd	s5,408(sp)
    80005aac:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005aae:	e3840593          	addi	a1,s0,-456
    80005ab2:	4505                	li	a0,1
    80005ab4:	ffffd097          	auipc	ra,0xffffd
    80005ab8:	16e080e7          	jalr	366(ra) # 80002c22 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005abc:	08000613          	li	a2,128
    80005ac0:	f4040593          	addi	a1,s0,-192
    80005ac4:	4501                	li	a0,0
    80005ac6:	ffffd097          	auipc	ra,0xffffd
    80005aca:	17c080e7          	jalr	380(ra) # 80002c42 <argstr>
    80005ace:	87aa                	mv	a5,a0
    return -1;
    80005ad0:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005ad2:	0c07c263          	bltz	a5,80005b96 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005ad6:	10000613          	li	a2,256
    80005ada:	4581                	li	a1,0
    80005adc:	e4040513          	addi	a0,s0,-448
    80005ae0:	ffffb097          	auipc	ra,0xffffb
    80005ae4:	22e080e7          	jalr	558(ra) # 80000d0e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ae8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005aec:	89a6                	mv	s3,s1
    80005aee:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005af0:	02000a13          	li	s4,32
    80005af4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005af8:	00391513          	slli	a0,s2,0x3
    80005afc:	e3040593          	addi	a1,s0,-464
    80005b00:	e3843783          	ld	a5,-456(s0)
    80005b04:	953e                	add	a0,a0,a5
    80005b06:	ffffd097          	auipc	ra,0xffffd
    80005b0a:	05e080e7          	jalr	94(ra) # 80002b64 <fetchaddr>
    80005b0e:	02054a63          	bltz	a0,80005b42 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005b12:	e3043783          	ld	a5,-464(s0)
    80005b16:	c3b9                	beqz	a5,80005b5c <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005b18:	ffffb097          	auipc	ra,0xffffb
    80005b1c:	00a080e7          	jalr	10(ra) # 80000b22 <kalloc>
    80005b20:	85aa                	mv	a1,a0
    80005b22:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005b26:	cd11                	beqz	a0,80005b42 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005b28:	6605                	lui	a2,0x1
    80005b2a:	e3043503          	ld	a0,-464(s0)
    80005b2e:	ffffd097          	auipc	ra,0xffffd
    80005b32:	088080e7          	jalr	136(ra) # 80002bb6 <fetchstr>
    80005b36:	00054663          	bltz	a0,80005b42 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005b3a:	0905                	addi	s2,s2,1
    80005b3c:	09a1                	addi	s3,s3,8
    80005b3e:	fb491be3          	bne	s2,s4,80005af4 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b42:	10048913          	addi	s2,s1,256
    80005b46:	6088                	ld	a0,0(s1)
    80005b48:	c531                	beqz	a0,80005b94 <sys_exec+0xf8>
    kfree(argv[i]);
    80005b4a:	ffffb097          	auipc	ra,0xffffb
    80005b4e:	edc080e7          	jalr	-292(ra) # 80000a26 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b52:	04a1                	addi	s1,s1,8
    80005b54:	ff2499e3          	bne	s1,s2,80005b46 <sys_exec+0xaa>
  return -1;
    80005b58:	557d                	li	a0,-1
    80005b5a:	a835                	j	80005b96 <sys_exec+0xfa>
      argv[i] = 0;
    80005b5c:	0a8e                	slli	s5,s5,0x3
    80005b5e:	fc040793          	addi	a5,s0,-64
    80005b62:	9abe                	add	s5,s5,a5
    80005b64:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005b68:	e4040593          	addi	a1,s0,-448
    80005b6c:	f4040513          	addi	a0,s0,-192
    80005b70:	fffff097          	auipc	ra,0xfffff
    80005b74:	190080e7          	jalr	400(ra) # 80004d00 <exec>
    80005b78:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b7a:	10048993          	addi	s3,s1,256
    80005b7e:	6088                	ld	a0,0(s1)
    80005b80:	c901                	beqz	a0,80005b90 <sys_exec+0xf4>
    kfree(argv[i]);
    80005b82:	ffffb097          	auipc	ra,0xffffb
    80005b86:	ea4080e7          	jalr	-348(ra) # 80000a26 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b8a:	04a1                	addi	s1,s1,8
    80005b8c:	ff3499e3          	bne	s1,s3,80005b7e <sys_exec+0xe2>
  return ret;
    80005b90:	854a                	mv	a0,s2
    80005b92:	a011                	j	80005b96 <sys_exec+0xfa>
  return -1;
    80005b94:	557d                	li	a0,-1
}
    80005b96:	60be                	ld	ra,456(sp)
    80005b98:	641e                	ld	s0,448(sp)
    80005b9a:	74fa                	ld	s1,440(sp)
    80005b9c:	795a                	ld	s2,432(sp)
    80005b9e:	79ba                	ld	s3,424(sp)
    80005ba0:	7a1a                	ld	s4,416(sp)
    80005ba2:	6afa                	ld	s5,408(sp)
    80005ba4:	6179                	addi	sp,sp,464
    80005ba6:	8082                	ret

0000000080005ba8 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ba8:	7139                	addi	sp,sp,-64
    80005baa:	fc06                	sd	ra,56(sp)
    80005bac:	f822                	sd	s0,48(sp)
    80005bae:	f426                	sd	s1,40(sp)
    80005bb0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005bb2:	ffffc097          	auipc	ra,0xffffc
    80005bb6:	e58080e7          	jalr	-424(ra) # 80001a0a <myproc>
    80005bba:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005bbc:	fd840593          	addi	a1,s0,-40
    80005bc0:	4501                	li	a0,0
    80005bc2:	ffffd097          	auipc	ra,0xffffd
    80005bc6:	060080e7          	jalr	96(ra) # 80002c22 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005bca:	fc840593          	addi	a1,s0,-56
    80005bce:	fd040513          	addi	a0,s0,-48
    80005bd2:	fffff097          	auipc	ra,0xfffff
    80005bd6:	dd6080e7          	jalr	-554(ra) # 800049a8 <pipealloc>
    return -1;
    80005bda:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005bdc:	0c054463          	bltz	a0,80005ca4 <sys_pipe+0xfc>
  fd0 = -1;
    80005be0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005be4:	fd043503          	ld	a0,-48(s0)
    80005be8:	fffff097          	auipc	ra,0xfffff
    80005bec:	518080e7          	jalr	1304(ra) # 80005100 <fdalloc>
    80005bf0:	fca42223          	sw	a0,-60(s0)
    80005bf4:	08054b63          	bltz	a0,80005c8a <sys_pipe+0xe2>
    80005bf8:	fc843503          	ld	a0,-56(s0)
    80005bfc:	fffff097          	auipc	ra,0xfffff
    80005c00:	504080e7          	jalr	1284(ra) # 80005100 <fdalloc>
    80005c04:	fca42023          	sw	a0,-64(s0)
    80005c08:	06054863          	bltz	a0,80005c78 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c0c:	4691                	li	a3,4
    80005c0e:	fc440613          	addi	a2,s0,-60
    80005c12:	fd843583          	ld	a1,-40(s0)
    80005c16:	6ca8                	ld	a0,88(s1)
    80005c18:	ffffc097          	auipc	ra,0xffffc
    80005c1c:	aae080e7          	jalr	-1362(ra) # 800016c6 <copyout>
    80005c20:	02054063          	bltz	a0,80005c40 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c24:	4691                	li	a3,4
    80005c26:	fc040613          	addi	a2,s0,-64
    80005c2a:	fd843583          	ld	a1,-40(s0)
    80005c2e:	0591                	addi	a1,a1,4
    80005c30:	6ca8                	ld	a0,88(s1)
    80005c32:	ffffc097          	auipc	ra,0xffffc
    80005c36:	a94080e7          	jalr	-1388(ra) # 800016c6 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c3a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c3c:	06055463          	bgez	a0,80005ca4 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005c40:	fc442783          	lw	a5,-60(s0)
    80005c44:	07e9                	addi	a5,a5,26
    80005c46:	078e                	slli	a5,a5,0x3
    80005c48:	97a6                	add	a5,a5,s1
    80005c4a:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005c4e:	fc042503          	lw	a0,-64(s0)
    80005c52:	0569                	addi	a0,a0,26
    80005c54:	050e                	slli	a0,a0,0x3
    80005c56:	94aa                	add	s1,s1,a0
    80005c58:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005c5c:	fd043503          	ld	a0,-48(s0)
    80005c60:	fffff097          	auipc	ra,0xfffff
    80005c64:	a18080e7          	jalr	-1512(ra) # 80004678 <fileclose>
    fileclose(wf);
    80005c68:	fc843503          	ld	a0,-56(s0)
    80005c6c:	fffff097          	auipc	ra,0xfffff
    80005c70:	a0c080e7          	jalr	-1524(ra) # 80004678 <fileclose>
    return -1;
    80005c74:	57fd                	li	a5,-1
    80005c76:	a03d                	j	80005ca4 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005c78:	fc442783          	lw	a5,-60(s0)
    80005c7c:	0007c763          	bltz	a5,80005c8a <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005c80:	07e9                	addi	a5,a5,26
    80005c82:	078e                	slli	a5,a5,0x3
    80005c84:	94be                	add	s1,s1,a5
    80005c86:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005c8a:	fd043503          	ld	a0,-48(s0)
    80005c8e:	fffff097          	auipc	ra,0xfffff
    80005c92:	9ea080e7          	jalr	-1558(ra) # 80004678 <fileclose>
    fileclose(wf);
    80005c96:	fc843503          	ld	a0,-56(s0)
    80005c9a:	fffff097          	auipc	ra,0xfffff
    80005c9e:	9de080e7          	jalr	-1570(ra) # 80004678 <fileclose>
    return -1;
    80005ca2:	57fd                	li	a5,-1
}
    80005ca4:	853e                	mv	a0,a5
    80005ca6:	70e2                	ld	ra,56(sp)
    80005ca8:	7442                	ld	s0,48(sp)
    80005caa:	74a2                	ld	s1,40(sp)
    80005cac:	6121                	addi	sp,sp,64
    80005cae:	8082                	ret

0000000080005cb0 <kernelvec>:
    80005cb0:	7111                	addi	sp,sp,-256
    80005cb2:	e006                	sd	ra,0(sp)
    80005cb4:	e40a                	sd	sp,8(sp)
    80005cb6:	e80e                	sd	gp,16(sp)
    80005cb8:	ec12                	sd	tp,24(sp)
    80005cba:	f016                	sd	t0,32(sp)
    80005cbc:	f41a                	sd	t1,40(sp)
    80005cbe:	f81e                	sd	t2,48(sp)
    80005cc0:	fc22                	sd	s0,56(sp)
    80005cc2:	e0a6                	sd	s1,64(sp)
    80005cc4:	e4aa                	sd	a0,72(sp)
    80005cc6:	e8ae                	sd	a1,80(sp)
    80005cc8:	ecb2                	sd	a2,88(sp)
    80005cca:	f0b6                	sd	a3,96(sp)
    80005ccc:	f4ba                	sd	a4,104(sp)
    80005cce:	f8be                	sd	a5,112(sp)
    80005cd0:	fcc2                	sd	a6,120(sp)
    80005cd2:	e146                	sd	a7,128(sp)
    80005cd4:	e54a                	sd	s2,136(sp)
    80005cd6:	e94e                	sd	s3,144(sp)
    80005cd8:	ed52                	sd	s4,152(sp)
    80005cda:	f156                	sd	s5,160(sp)
    80005cdc:	f55a                	sd	s6,168(sp)
    80005cde:	f95e                	sd	s7,176(sp)
    80005ce0:	fd62                	sd	s8,184(sp)
    80005ce2:	e1e6                	sd	s9,192(sp)
    80005ce4:	e5ea                	sd	s10,200(sp)
    80005ce6:	e9ee                	sd	s11,208(sp)
    80005ce8:	edf2                	sd	t3,216(sp)
    80005cea:	f1f6                	sd	t4,224(sp)
    80005cec:	f5fa                	sd	t5,232(sp)
    80005cee:	f9fe                	sd	t6,240(sp)
    80005cf0:	d41fc0ef          	jal	ra,80002a30 <kerneltrap>
    80005cf4:	6082                	ld	ra,0(sp)
    80005cf6:	6122                	ld	sp,8(sp)
    80005cf8:	61c2                	ld	gp,16(sp)
    80005cfa:	7282                	ld	t0,32(sp)
    80005cfc:	7322                	ld	t1,40(sp)
    80005cfe:	73c2                	ld	t2,48(sp)
    80005d00:	7462                	ld	s0,56(sp)
    80005d02:	6486                	ld	s1,64(sp)
    80005d04:	6526                	ld	a0,72(sp)
    80005d06:	65c6                	ld	a1,80(sp)
    80005d08:	6666                	ld	a2,88(sp)
    80005d0a:	7686                	ld	a3,96(sp)
    80005d0c:	7726                	ld	a4,104(sp)
    80005d0e:	77c6                	ld	a5,112(sp)
    80005d10:	7866                	ld	a6,120(sp)
    80005d12:	688a                	ld	a7,128(sp)
    80005d14:	692a                	ld	s2,136(sp)
    80005d16:	69ca                	ld	s3,144(sp)
    80005d18:	6a6a                	ld	s4,152(sp)
    80005d1a:	7a8a                	ld	s5,160(sp)
    80005d1c:	7b2a                	ld	s6,168(sp)
    80005d1e:	7bca                	ld	s7,176(sp)
    80005d20:	7c6a                	ld	s8,184(sp)
    80005d22:	6c8e                	ld	s9,192(sp)
    80005d24:	6d2e                	ld	s10,200(sp)
    80005d26:	6dce                	ld	s11,208(sp)
    80005d28:	6e6e                	ld	t3,216(sp)
    80005d2a:	7e8e                	ld	t4,224(sp)
    80005d2c:	7f2e                	ld	t5,232(sp)
    80005d2e:	7fce                	ld	t6,240(sp)
    80005d30:	6111                	addi	sp,sp,256
    80005d32:	10200073          	sret
    80005d36:	00000013          	nop
    80005d3a:	00000013          	nop
    80005d3e:	0001                	nop

0000000080005d40 <timervec>:
    80005d40:	34051573          	csrrw	a0,mscratch,a0
    80005d44:	e10c                	sd	a1,0(a0)
    80005d46:	e510                	sd	a2,8(a0)
    80005d48:	e914                	sd	a3,16(a0)
    80005d4a:	6d0c                	ld	a1,24(a0)
    80005d4c:	7110                	ld	a2,32(a0)
    80005d4e:	6194                	ld	a3,0(a1)
    80005d50:	96b2                	add	a3,a3,a2
    80005d52:	e194                	sd	a3,0(a1)
    80005d54:	4589                	li	a1,2
    80005d56:	14459073          	csrw	sip,a1
    80005d5a:	6914                	ld	a3,16(a0)
    80005d5c:	6510                	ld	a2,8(a0)
    80005d5e:	610c                	ld	a1,0(a0)
    80005d60:	34051573          	csrrw	a0,mscratch,a0
    80005d64:	30200073          	mret
	...

0000000080005d6a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005d6a:	1141                	addi	sp,sp,-16
    80005d6c:	e422                	sd	s0,8(sp)
    80005d6e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d70:	0c0007b7          	lui	a5,0xc000
    80005d74:	4705                	li	a4,1
    80005d76:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d78:	c3d8                	sw	a4,4(a5)
}
    80005d7a:	6422                	ld	s0,8(sp)
    80005d7c:	0141                	addi	sp,sp,16
    80005d7e:	8082                	ret

0000000080005d80 <plicinithart>:

void
plicinithart(void)
{
    80005d80:	1141                	addi	sp,sp,-16
    80005d82:	e406                	sd	ra,8(sp)
    80005d84:	e022                	sd	s0,0(sp)
    80005d86:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d88:	ffffc097          	auipc	ra,0xffffc
    80005d8c:	c56080e7          	jalr	-938(ra) # 800019de <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d90:	0085171b          	slliw	a4,a0,0x8
    80005d94:	0c0027b7          	lui	a5,0xc002
    80005d98:	97ba                	add	a5,a5,a4
    80005d9a:	40200713          	li	a4,1026
    80005d9e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005da2:	00d5151b          	slliw	a0,a0,0xd
    80005da6:	0c2017b7          	lui	a5,0xc201
    80005daa:	953e                	add	a0,a0,a5
    80005dac:	00052023          	sw	zero,0(a0)
}
    80005db0:	60a2                	ld	ra,8(sp)
    80005db2:	6402                	ld	s0,0(sp)
    80005db4:	0141                	addi	sp,sp,16
    80005db6:	8082                	ret

0000000080005db8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005db8:	1141                	addi	sp,sp,-16
    80005dba:	e406                	sd	ra,8(sp)
    80005dbc:	e022                	sd	s0,0(sp)
    80005dbe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005dc0:	ffffc097          	auipc	ra,0xffffc
    80005dc4:	c1e080e7          	jalr	-994(ra) # 800019de <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005dc8:	00d5179b          	slliw	a5,a0,0xd
    80005dcc:	0c201537          	lui	a0,0xc201
    80005dd0:	953e                	add	a0,a0,a5
  return irq;
}
    80005dd2:	4148                	lw	a0,4(a0)
    80005dd4:	60a2                	ld	ra,8(sp)
    80005dd6:	6402                	ld	s0,0(sp)
    80005dd8:	0141                	addi	sp,sp,16
    80005dda:	8082                	ret

0000000080005ddc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005ddc:	1101                	addi	sp,sp,-32
    80005dde:	ec06                	sd	ra,24(sp)
    80005de0:	e822                	sd	s0,16(sp)
    80005de2:	e426                	sd	s1,8(sp)
    80005de4:	1000                	addi	s0,sp,32
    80005de6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005de8:	ffffc097          	auipc	ra,0xffffc
    80005dec:	bf6080e7          	jalr	-1034(ra) # 800019de <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005df0:	00d5151b          	slliw	a0,a0,0xd
    80005df4:	0c2017b7          	lui	a5,0xc201
    80005df8:	97aa                	add	a5,a5,a0
    80005dfa:	c3c4                	sw	s1,4(a5)
}
    80005dfc:	60e2                	ld	ra,24(sp)
    80005dfe:	6442                	ld	s0,16(sp)
    80005e00:	64a2                	ld	s1,8(sp)
    80005e02:	6105                	addi	sp,sp,32
    80005e04:	8082                	ret

0000000080005e06 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005e06:	1141                	addi	sp,sp,-16
    80005e08:	e406                	sd	ra,8(sp)
    80005e0a:	e022                	sd	s0,0(sp)
    80005e0c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005e0e:	479d                	li	a5,7
    80005e10:	04a7cc63          	blt	a5,a0,80005e68 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005e14:	0001c797          	auipc	a5,0x1c
    80005e18:	39c78793          	addi	a5,a5,924 # 800221b0 <disk>
    80005e1c:	97aa                	add	a5,a5,a0
    80005e1e:	0187c783          	lbu	a5,24(a5)
    80005e22:	ebb9                	bnez	a5,80005e78 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005e24:	00451613          	slli	a2,a0,0x4
    80005e28:	0001c797          	auipc	a5,0x1c
    80005e2c:	38878793          	addi	a5,a5,904 # 800221b0 <disk>
    80005e30:	6394                	ld	a3,0(a5)
    80005e32:	96b2                	add	a3,a3,a2
    80005e34:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005e38:	6398                	ld	a4,0(a5)
    80005e3a:	9732                	add	a4,a4,a2
    80005e3c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005e40:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005e44:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005e48:	953e                	add	a0,a0,a5
    80005e4a:	4785                	li	a5,1
    80005e4c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005e50:	0001c517          	auipc	a0,0x1c
    80005e54:	37850513          	addi	a0,a0,888 # 800221c8 <disk+0x18>
    80005e58:	ffffc097          	auipc	ra,0xffffc
    80005e5c:	37a080e7          	jalr	890(ra) # 800021d2 <wakeup>
}
    80005e60:	60a2                	ld	ra,8(sp)
    80005e62:	6402                	ld	s0,0(sp)
    80005e64:	0141                	addi	sp,sp,16
    80005e66:	8082                	ret
    panic("free_desc 1");
    80005e68:	00003517          	auipc	a0,0x3
    80005e6c:	c6050513          	addi	a0,a0,-928 # 80008ac8 <syscalls_name+0x2f8>
    80005e70:	ffffa097          	auipc	ra,0xffffa
    80005e74:	6fc080e7          	jalr	1788(ra) # 8000056c <panic>
    panic("free_desc 2");
    80005e78:	00003517          	auipc	a0,0x3
    80005e7c:	c6050513          	addi	a0,a0,-928 # 80008ad8 <syscalls_name+0x308>
    80005e80:	ffffa097          	auipc	ra,0xffffa
    80005e84:	6ec080e7          	jalr	1772(ra) # 8000056c <panic>

0000000080005e88 <virtio_disk_init>:
{
    80005e88:	1101                	addi	sp,sp,-32
    80005e8a:	ec06                	sd	ra,24(sp)
    80005e8c:	e822                	sd	s0,16(sp)
    80005e8e:	e426                	sd	s1,8(sp)
    80005e90:	e04a                	sd	s2,0(sp)
    80005e92:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e94:	00003597          	auipc	a1,0x3
    80005e98:	c5458593          	addi	a1,a1,-940 # 80008ae8 <syscalls_name+0x318>
    80005e9c:	0001c517          	auipc	a0,0x1c
    80005ea0:	43c50513          	addi	a0,a0,1084 # 800222d8 <disk+0x128>
    80005ea4:	ffffb097          	auipc	ra,0xffffb
    80005ea8:	cde080e7          	jalr	-802(ra) # 80000b82 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005eac:	100017b7          	lui	a5,0x10001
    80005eb0:	4398                	lw	a4,0(a5)
    80005eb2:	2701                	sext.w	a4,a4
    80005eb4:	747277b7          	lui	a5,0x74727
    80005eb8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005ebc:	14f71e63          	bne	a4,a5,80006018 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005ec0:	100017b7          	lui	a5,0x10001
    80005ec4:	43dc                	lw	a5,4(a5)
    80005ec6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ec8:	4709                	li	a4,2
    80005eca:	14e79763          	bne	a5,a4,80006018 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ece:	100017b7          	lui	a5,0x10001
    80005ed2:	479c                	lw	a5,8(a5)
    80005ed4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005ed6:	14e79163          	bne	a5,a4,80006018 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005eda:	100017b7          	lui	a5,0x10001
    80005ede:	47d8                	lw	a4,12(a5)
    80005ee0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ee2:	554d47b7          	lui	a5,0x554d4
    80005ee6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005eea:	12f71763          	bne	a4,a5,80006018 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005eee:	100017b7          	lui	a5,0x10001
    80005ef2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ef6:	4705                	li	a4,1
    80005ef8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005efa:	470d                	li	a4,3
    80005efc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005efe:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005f00:	c7ffe737          	lui	a4,0xc7ffe
    80005f04:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc46f>
    80005f08:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005f0a:	2701                	sext.w	a4,a4
    80005f0c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f0e:	472d                	li	a4,11
    80005f10:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005f12:	0707a903          	lw	s2,112(a5)
    80005f16:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005f18:	00897793          	andi	a5,s2,8
    80005f1c:	10078663          	beqz	a5,80006028 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005f20:	100017b7          	lui	a5,0x10001
    80005f24:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005f28:	43fc                	lw	a5,68(a5)
    80005f2a:	2781                	sext.w	a5,a5
    80005f2c:	10079663          	bnez	a5,80006038 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005f30:	100017b7          	lui	a5,0x10001
    80005f34:	5bdc                	lw	a5,52(a5)
    80005f36:	2781                	sext.w	a5,a5
  if(max == 0)
    80005f38:	10078863          	beqz	a5,80006048 <virtio_disk_init+0x1c0>
  if(max < NUM)
    80005f3c:	471d                	li	a4,7
    80005f3e:	10f77d63          	bgeu	a4,a5,80006058 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80005f42:	ffffb097          	auipc	ra,0xffffb
    80005f46:	be0080e7          	jalr	-1056(ra) # 80000b22 <kalloc>
    80005f4a:	0001c497          	auipc	s1,0x1c
    80005f4e:	26648493          	addi	s1,s1,614 # 800221b0 <disk>
    80005f52:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005f54:	ffffb097          	auipc	ra,0xffffb
    80005f58:	bce080e7          	jalr	-1074(ra) # 80000b22 <kalloc>
    80005f5c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005f5e:	ffffb097          	auipc	ra,0xffffb
    80005f62:	bc4080e7          	jalr	-1084(ra) # 80000b22 <kalloc>
    80005f66:	87aa                	mv	a5,a0
    80005f68:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005f6a:	6088                	ld	a0,0(s1)
    80005f6c:	cd75                	beqz	a0,80006068 <virtio_disk_init+0x1e0>
    80005f6e:	0001c717          	auipc	a4,0x1c
    80005f72:	24a73703          	ld	a4,586(a4) # 800221b8 <disk+0x8>
    80005f76:	cb6d                	beqz	a4,80006068 <virtio_disk_init+0x1e0>
    80005f78:	cbe5                	beqz	a5,80006068 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    80005f7a:	6605                	lui	a2,0x1
    80005f7c:	4581                	li	a1,0
    80005f7e:	ffffb097          	auipc	ra,0xffffb
    80005f82:	d90080e7          	jalr	-624(ra) # 80000d0e <memset>
  memset(disk.avail, 0, PGSIZE);
    80005f86:	0001c497          	auipc	s1,0x1c
    80005f8a:	22a48493          	addi	s1,s1,554 # 800221b0 <disk>
    80005f8e:	6605                	lui	a2,0x1
    80005f90:	4581                	li	a1,0
    80005f92:	6488                	ld	a0,8(s1)
    80005f94:	ffffb097          	auipc	ra,0xffffb
    80005f98:	d7a080e7          	jalr	-646(ra) # 80000d0e <memset>
  memset(disk.used, 0, PGSIZE);
    80005f9c:	6605                	lui	a2,0x1
    80005f9e:	4581                	li	a1,0
    80005fa0:	6888                	ld	a0,16(s1)
    80005fa2:	ffffb097          	auipc	ra,0xffffb
    80005fa6:	d6c080e7          	jalr	-660(ra) # 80000d0e <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005faa:	100017b7          	lui	a5,0x10001
    80005fae:	4721                	li	a4,8
    80005fb0:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005fb2:	4098                	lw	a4,0(s1)
    80005fb4:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005fb8:	40d8                	lw	a4,4(s1)
    80005fba:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005fbe:	6498                	ld	a4,8(s1)
    80005fc0:	0007069b          	sext.w	a3,a4
    80005fc4:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005fc8:	9701                	srai	a4,a4,0x20
    80005fca:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005fce:	6898                	ld	a4,16(s1)
    80005fd0:	0007069b          	sext.w	a3,a4
    80005fd4:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005fd8:	9701                	srai	a4,a4,0x20
    80005fda:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005fde:	4685                	li	a3,1
    80005fe0:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80005fe2:	4705                	li	a4,1
    80005fe4:	00d48c23          	sb	a3,24(s1)
    80005fe8:	00e48ca3          	sb	a4,25(s1)
    80005fec:	00e48d23          	sb	a4,26(s1)
    80005ff0:	00e48da3          	sb	a4,27(s1)
    80005ff4:	00e48e23          	sb	a4,28(s1)
    80005ff8:	00e48ea3          	sb	a4,29(s1)
    80005ffc:	00e48f23          	sb	a4,30(s1)
    80006000:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006004:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006008:	0727a823          	sw	s2,112(a5)
}
    8000600c:	60e2                	ld	ra,24(sp)
    8000600e:	6442                	ld	s0,16(sp)
    80006010:	64a2                	ld	s1,8(sp)
    80006012:	6902                	ld	s2,0(sp)
    80006014:	6105                	addi	sp,sp,32
    80006016:	8082                	ret
    panic("could not find virtio disk");
    80006018:	00003517          	auipc	a0,0x3
    8000601c:	ae050513          	addi	a0,a0,-1312 # 80008af8 <syscalls_name+0x328>
    80006020:	ffffa097          	auipc	ra,0xffffa
    80006024:	54c080e7          	jalr	1356(ra) # 8000056c <panic>
    panic("virtio disk FEATURES_OK unset");
    80006028:	00003517          	auipc	a0,0x3
    8000602c:	af050513          	addi	a0,a0,-1296 # 80008b18 <syscalls_name+0x348>
    80006030:	ffffa097          	auipc	ra,0xffffa
    80006034:	53c080e7          	jalr	1340(ra) # 8000056c <panic>
    panic("virtio disk should not be ready");
    80006038:	00003517          	auipc	a0,0x3
    8000603c:	b0050513          	addi	a0,a0,-1280 # 80008b38 <syscalls_name+0x368>
    80006040:	ffffa097          	auipc	ra,0xffffa
    80006044:	52c080e7          	jalr	1324(ra) # 8000056c <panic>
    panic("virtio disk has no queue 0");
    80006048:	00003517          	auipc	a0,0x3
    8000604c:	b1050513          	addi	a0,a0,-1264 # 80008b58 <syscalls_name+0x388>
    80006050:	ffffa097          	auipc	ra,0xffffa
    80006054:	51c080e7          	jalr	1308(ra) # 8000056c <panic>
    panic("virtio disk max queue too short");
    80006058:	00003517          	auipc	a0,0x3
    8000605c:	b2050513          	addi	a0,a0,-1248 # 80008b78 <syscalls_name+0x3a8>
    80006060:	ffffa097          	auipc	ra,0xffffa
    80006064:	50c080e7          	jalr	1292(ra) # 8000056c <panic>
    panic("virtio disk kalloc");
    80006068:	00003517          	auipc	a0,0x3
    8000606c:	b3050513          	addi	a0,a0,-1232 # 80008b98 <syscalls_name+0x3c8>
    80006070:	ffffa097          	auipc	ra,0xffffa
    80006074:	4fc080e7          	jalr	1276(ra) # 8000056c <panic>

0000000080006078 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006078:	7159                	addi	sp,sp,-112
    8000607a:	f486                	sd	ra,104(sp)
    8000607c:	f0a2                	sd	s0,96(sp)
    8000607e:	eca6                	sd	s1,88(sp)
    80006080:	e8ca                	sd	s2,80(sp)
    80006082:	e4ce                	sd	s3,72(sp)
    80006084:	e0d2                	sd	s4,64(sp)
    80006086:	fc56                	sd	s5,56(sp)
    80006088:	f85a                	sd	s6,48(sp)
    8000608a:	f45e                	sd	s7,40(sp)
    8000608c:	f062                	sd	s8,32(sp)
    8000608e:	ec66                	sd	s9,24(sp)
    80006090:	e86a                	sd	s10,16(sp)
    80006092:	1880                	addi	s0,sp,112
    80006094:	892a                	mv	s2,a0
    80006096:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006098:	00c52c83          	lw	s9,12(a0)
    8000609c:	001c9c9b          	slliw	s9,s9,0x1
    800060a0:	1c82                	slli	s9,s9,0x20
    800060a2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800060a6:	0001c517          	auipc	a0,0x1c
    800060aa:	23250513          	addi	a0,a0,562 # 800222d8 <disk+0x128>
    800060ae:	ffffb097          	auipc	ra,0xffffb
    800060b2:	b64080e7          	jalr	-1180(ra) # 80000c12 <acquire>
  for(int i = 0; i < 3; i++){
    800060b6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800060b8:	4ba1                	li	s7,8
      disk.free[i] = 0;
    800060ba:	0001cb17          	auipc	s6,0x1c
    800060be:	0f6b0b13          	addi	s6,s6,246 # 800221b0 <disk>
  for(int i = 0; i < 3; i++){
    800060c2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800060c4:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800060c6:	0001cc17          	auipc	s8,0x1c
    800060ca:	212c0c13          	addi	s8,s8,530 # 800222d8 <disk+0x128>
    800060ce:	a8b5                	j	8000614a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    800060d0:	00fb06b3          	add	a3,s6,a5
    800060d4:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800060d8:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800060da:	0207c563          	bltz	a5,80006104 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800060de:	2485                	addiw	s1,s1,1
    800060e0:	0711                	addi	a4,a4,4
    800060e2:	1f548a63          	beq	s1,s5,800062d6 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    800060e6:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    800060e8:	0001c697          	auipc	a3,0x1c
    800060ec:	0c868693          	addi	a3,a3,200 # 800221b0 <disk>
    800060f0:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800060f2:	0186c583          	lbu	a1,24(a3)
    800060f6:	fde9                	bnez	a1,800060d0 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800060f8:	2785                	addiw	a5,a5,1
    800060fa:	0685                	addi	a3,a3,1
    800060fc:	ff779be3          	bne	a5,s7,800060f2 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006100:	57fd                	li	a5,-1
    80006102:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006104:	02905a63          	blez	s1,80006138 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80006108:	f9042503          	lw	a0,-112(s0)
    8000610c:	00000097          	auipc	ra,0x0
    80006110:	cfa080e7          	jalr	-774(ra) # 80005e06 <free_desc>
      for(int j = 0; j < i; j++)
    80006114:	4785                	li	a5,1
    80006116:	0297d163          	bge	a5,s1,80006138 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000611a:	f9442503          	lw	a0,-108(s0)
    8000611e:	00000097          	auipc	ra,0x0
    80006122:	ce8080e7          	jalr	-792(ra) # 80005e06 <free_desc>
      for(int j = 0; j < i; j++)
    80006126:	4789                	li	a5,2
    80006128:	0097d863          	bge	a5,s1,80006138 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000612c:	f9842503          	lw	a0,-104(s0)
    80006130:	00000097          	auipc	ra,0x0
    80006134:	cd6080e7          	jalr	-810(ra) # 80005e06 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006138:	85e2                	mv	a1,s8
    8000613a:	0001c517          	auipc	a0,0x1c
    8000613e:	08e50513          	addi	a0,a0,142 # 800221c8 <disk+0x18>
    80006142:	ffffc097          	auipc	ra,0xffffc
    80006146:	022080e7          	jalr	34(ra) # 80002164 <sleep>
  for(int i = 0; i < 3; i++){
    8000614a:	f9040713          	addi	a4,s0,-112
    8000614e:	84ce                	mv	s1,s3
    80006150:	bf59                	j	800060e6 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006152:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006156:	00479693          	slli	a3,a5,0x4
    8000615a:	0001c797          	auipc	a5,0x1c
    8000615e:	05678793          	addi	a5,a5,86 # 800221b0 <disk>
    80006162:	97b6                	add	a5,a5,a3
    80006164:	4685                	li	a3,1
    80006166:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006168:	0001c597          	auipc	a1,0x1c
    8000616c:	04858593          	addi	a1,a1,72 # 800221b0 <disk>
    80006170:	00a60793          	addi	a5,a2,10
    80006174:	0792                	slli	a5,a5,0x4
    80006176:	97ae                	add	a5,a5,a1
    80006178:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    8000617c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006180:	f6070693          	addi	a3,a4,-160
    80006184:	619c                	ld	a5,0(a1)
    80006186:	97b6                	add	a5,a5,a3
    80006188:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000618a:	6188                	ld	a0,0(a1)
    8000618c:	96aa                	add	a3,a3,a0
    8000618e:	47c1                	li	a5,16
    80006190:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006192:	4785                	li	a5,1
    80006194:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006198:	f9442783          	lw	a5,-108(s0)
    8000619c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800061a0:	0792                	slli	a5,a5,0x4
    800061a2:	953e                	add	a0,a0,a5
    800061a4:	05890693          	addi	a3,s2,88
    800061a8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800061aa:	6188                	ld	a0,0(a1)
    800061ac:	97aa                	add	a5,a5,a0
    800061ae:	40000693          	li	a3,1024
    800061b2:	c794                	sw	a3,8(a5)
  if(write)
    800061b4:	100d0d63          	beqz	s10,800062ce <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800061b8:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800061bc:	00c7d683          	lhu	a3,12(a5)
    800061c0:	0016e693          	ori	a3,a3,1
    800061c4:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    800061c8:	f9842583          	lw	a1,-104(s0)
    800061cc:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800061d0:	0001c697          	auipc	a3,0x1c
    800061d4:	fe068693          	addi	a3,a3,-32 # 800221b0 <disk>
    800061d8:	00260793          	addi	a5,a2,2
    800061dc:	0792                	slli	a5,a5,0x4
    800061de:	97b6                	add	a5,a5,a3
    800061e0:	587d                	li	a6,-1
    800061e2:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800061e6:	0592                	slli	a1,a1,0x4
    800061e8:	952e                	add	a0,a0,a1
    800061ea:	f9070713          	addi	a4,a4,-112
    800061ee:	9736                	add	a4,a4,a3
    800061f0:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    800061f2:	6298                	ld	a4,0(a3)
    800061f4:	972e                	add	a4,a4,a1
    800061f6:	4585                	li	a1,1
    800061f8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800061fa:	4509                	li	a0,2
    800061fc:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80006200:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006204:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006208:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000620c:	6698                	ld	a4,8(a3)
    8000620e:	00275783          	lhu	a5,2(a4)
    80006212:	8b9d                	andi	a5,a5,7
    80006214:	0786                	slli	a5,a5,0x1
    80006216:	97ba                	add	a5,a5,a4
    80006218:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    8000621c:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006220:	6698                	ld	a4,8(a3)
    80006222:	00275783          	lhu	a5,2(a4)
    80006226:	2785                	addiw	a5,a5,1
    80006228:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000622c:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006230:	100017b7          	lui	a5,0x10001
    80006234:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006238:	00492703          	lw	a4,4(s2)
    8000623c:	4785                	li	a5,1
    8000623e:	02f71163          	bne	a4,a5,80006260 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80006242:	0001c997          	auipc	s3,0x1c
    80006246:	09698993          	addi	s3,s3,150 # 800222d8 <disk+0x128>
  while(b->disk == 1) {
    8000624a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000624c:	85ce                	mv	a1,s3
    8000624e:	854a                	mv	a0,s2
    80006250:	ffffc097          	auipc	ra,0xffffc
    80006254:	f14080e7          	jalr	-236(ra) # 80002164 <sleep>
  while(b->disk == 1) {
    80006258:	00492783          	lw	a5,4(s2)
    8000625c:	fe9788e3          	beq	a5,s1,8000624c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006260:	f9042903          	lw	s2,-112(s0)
    80006264:	00290793          	addi	a5,s2,2
    80006268:	00479713          	slli	a4,a5,0x4
    8000626c:	0001c797          	auipc	a5,0x1c
    80006270:	f4478793          	addi	a5,a5,-188 # 800221b0 <disk>
    80006274:	97ba                	add	a5,a5,a4
    80006276:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000627a:	0001c997          	auipc	s3,0x1c
    8000627e:	f3698993          	addi	s3,s3,-202 # 800221b0 <disk>
    80006282:	00491713          	slli	a4,s2,0x4
    80006286:	0009b783          	ld	a5,0(s3)
    8000628a:	97ba                	add	a5,a5,a4
    8000628c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006290:	854a                	mv	a0,s2
    80006292:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006296:	00000097          	auipc	ra,0x0
    8000629a:	b70080e7          	jalr	-1168(ra) # 80005e06 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000629e:	8885                	andi	s1,s1,1
    800062a0:	f0ed                	bnez	s1,80006282 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800062a2:	0001c517          	auipc	a0,0x1c
    800062a6:	03650513          	addi	a0,a0,54 # 800222d8 <disk+0x128>
    800062aa:	ffffb097          	auipc	ra,0xffffb
    800062ae:	a1c080e7          	jalr	-1508(ra) # 80000cc6 <release>
}
    800062b2:	70a6                	ld	ra,104(sp)
    800062b4:	7406                	ld	s0,96(sp)
    800062b6:	64e6                	ld	s1,88(sp)
    800062b8:	6946                	ld	s2,80(sp)
    800062ba:	69a6                	ld	s3,72(sp)
    800062bc:	6a06                	ld	s4,64(sp)
    800062be:	7ae2                	ld	s5,56(sp)
    800062c0:	7b42                	ld	s6,48(sp)
    800062c2:	7ba2                	ld	s7,40(sp)
    800062c4:	7c02                	ld	s8,32(sp)
    800062c6:	6ce2                	ld	s9,24(sp)
    800062c8:	6d42                	ld	s10,16(sp)
    800062ca:	6165                	addi	sp,sp,112
    800062cc:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800062ce:	4689                	li	a3,2
    800062d0:	00d79623          	sh	a3,12(a5)
    800062d4:	b5e5                	j	800061bc <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062d6:	f9042603          	lw	a2,-112(s0)
    800062da:	00a60713          	addi	a4,a2,10
    800062de:	0712                	slli	a4,a4,0x4
    800062e0:	0001c517          	auipc	a0,0x1c
    800062e4:	ed850513          	addi	a0,a0,-296 # 800221b8 <disk+0x8>
    800062e8:	953a                	add	a0,a0,a4
  if(write)
    800062ea:	e60d14e3          	bnez	s10,80006152 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800062ee:	00a60793          	addi	a5,a2,10
    800062f2:	00479693          	slli	a3,a5,0x4
    800062f6:	0001c797          	auipc	a5,0x1c
    800062fa:	eba78793          	addi	a5,a5,-326 # 800221b0 <disk>
    800062fe:	97b6                	add	a5,a5,a3
    80006300:	0007a423          	sw	zero,8(a5)
    80006304:	b595                	j	80006168 <virtio_disk_rw+0xf0>

0000000080006306 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006306:	1101                	addi	sp,sp,-32
    80006308:	ec06                	sd	ra,24(sp)
    8000630a:	e822                	sd	s0,16(sp)
    8000630c:	e426                	sd	s1,8(sp)
    8000630e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006310:	0001c497          	auipc	s1,0x1c
    80006314:	ea048493          	addi	s1,s1,-352 # 800221b0 <disk>
    80006318:	0001c517          	auipc	a0,0x1c
    8000631c:	fc050513          	addi	a0,a0,-64 # 800222d8 <disk+0x128>
    80006320:	ffffb097          	auipc	ra,0xffffb
    80006324:	8f2080e7          	jalr	-1806(ra) # 80000c12 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006328:	10001737          	lui	a4,0x10001
    8000632c:	533c                	lw	a5,96(a4)
    8000632e:	8b8d                	andi	a5,a5,3
    80006330:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006332:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006336:	689c                	ld	a5,16(s1)
    80006338:	0204d703          	lhu	a4,32(s1)
    8000633c:	0027d783          	lhu	a5,2(a5)
    80006340:	04f70863          	beq	a4,a5,80006390 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006344:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006348:	6898                	ld	a4,16(s1)
    8000634a:	0204d783          	lhu	a5,32(s1)
    8000634e:	8b9d                	andi	a5,a5,7
    80006350:	078e                	slli	a5,a5,0x3
    80006352:	97ba                	add	a5,a5,a4
    80006354:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006356:	00278713          	addi	a4,a5,2
    8000635a:	0712                	slli	a4,a4,0x4
    8000635c:	9726                	add	a4,a4,s1
    8000635e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006362:	e721                	bnez	a4,800063aa <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006364:	0789                	addi	a5,a5,2
    80006366:	0792                	slli	a5,a5,0x4
    80006368:	97a6                	add	a5,a5,s1
    8000636a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000636c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006370:	ffffc097          	auipc	ra,0xffffc
    80006374:	e62080e7          	jalr	-414(ra) # 800021d2 <wakeup>

    disk.used_idx += 1;
    80006378:	0204d783          	lhu	a5,32(s1)
    8000637c:	2785                	addiw	a5,a5,1
    8000637e:	17c2                	slli	a5,a5,0x30
    80006380:	93c1                	srli	a5,a5,0x30
    80006382:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006386:	6898                	ld	a4,16(s1)
    80006388:	00275703          	lhu	a4,2(a4)
    8000638c:	faf71ce3          	bne	a4,a5,80006344 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006390:	0001c517          	auipc	a0,0x1c
    80006394:	f4850513          	addi	a0,a0,-184 # 800222d8 <disk+0x128>
    80006398:	ffffb097          	auipc	ra,0xffffb
    8000639c:	92e080e7          	jalr	-1746(ra) # 80000cc6 <release>
}
    800063a0:	60e2                	ld	ra,24(sp)
    800063a2:	6442                	ld	s0,16(sp)
    800063a4:	64a2                	ld	s1,8(sp)
    800063a6:	6105                	addi	sp,sp,32
    800063a8:	8082                	ret
      panic("virtio_disk_intr status");
    800063aa:	00003517          	auipc	a0,0x3
    800063ae:	80650513          	addi	a0,a0,-2042 # 80008bb0 <syscalls_name+0x3e0>
    800063b2:	ffffa097          	auipc	ra,0xffffa
    800063b6:	1ba080e7          	jalr	442(ra) # 8000056c <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
