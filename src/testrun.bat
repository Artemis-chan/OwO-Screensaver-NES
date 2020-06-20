ca65 powong.s -o powong.o -t nes
ld65 powong.o -o out\powong.nes -t nes --dbgfile out\powong.dbg
start out\powong.nes