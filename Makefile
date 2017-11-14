
all:	test

test: main.asm
	lwasm -9 -b -o test.bin main.asm
	writecocofile //media/share1/COCO/drive0.dsk test.bin

run:
	mame coco3h -flop1 /media/share1/COCO/drive0.dsk -ramsize 512k -ui_active -skip_gameinfo -autoboot_delay 1 -autoboot_command 'LOADM"TEST.BIN":EXEC\n'

clean:
	rm -f *.bin

backup:
	tar -cvf backups/`date +%Y-%m-%d_%H-%M-%S`.tar Makefile *.asm

