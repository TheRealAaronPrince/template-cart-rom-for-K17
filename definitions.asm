;--== Consts ==--

ScrnW = 40
ScrnH = 30

;----------------------------------------------------------------

;--== Vars ==--

;reset vector
reset = $8000

;VIA
PORTB = $6FC0
PORTA = $6FC1
DDRB = $6FC2
DDRA = $6FC3

;math function variables
RngVal = $00 ;single byte
OPP1 = RngVal+4	;leeway to accept 3 byte numbers
OPP2 = OPP1+4	;leeway to accept 3 byte numbers
RSLT = OPP2+4	;leeway to accept 6 byte numbers
SCTH = RSLT+8	;leeway 8 bytes

;keyboard funvctions' variables
KeyIdx = SCTH+8 ;single byte
CharIn = KeyIdx+1 ;single byte
kbdBuffA = CharIn+1 ;8 bytes
kbdBuffB = kbdBuffA+8 ;8 bytes
kbdSnap = kbdBuffB+8 ;8 bytes
ModKeys =  kbdSnap+8

;graphics functions' variables
CHRX = ModKeys+1
CHRY = CHRX+1
CHRH = CHRY+1
CHRL = CHRH+1
COLR = CHRL+1
SYMB = COLR+1
CDAT = SYMB+1
SHX1 = CDAT+1
SHY1 = SHX1+1
SHX2 = SHY1+1
SHY2 = SHX2+1
STRL = SHY2+1
STRH = STRL+1
SRCL = STRH+1
SRCH = SRCL+1
SC2L = SRCH+1
SC2H = SC2L+1

;warmstart
warm = HWInfo-1

;hardware info bytes
HWInfo = ptr2-14
;hardware pointers
ptr2 = ptr1-2 ;for general use
ptr1 = hdrv-2 ;for general use
hdrv = cart-2 ;hard card, if detected | mnemonic SFK (stands for "storage format K17")
cart = kbd-2 ;cartrige, if detected | mnemonic K17
kbd = Video-2 ;keyboard (allow for multiple keyboards)
Video = $FE ;video card (allow for multiple video cards)

StrPage = $0200
