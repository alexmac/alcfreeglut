?ALCHEMY:=/path/to/alchemy/SDK
$?GLS3D:=/path/to/gls3d

SRC=$(wildcard src/*.c)
OBJS=$(subst .c,.o,$(SRC))

.PHONY: demos

all:
	@mkdir -p install/usr/lib
	
	@echo "Compiling libglut.o"
	make compile

	@$(ALCHEMY)/usr/bin/ar crus install/usr/lib/libglut.a src/*.o

clean:
	rm -f src/*.o demos/*.swf

demos/AlcConsole.abc: demos/AlcConsole.as
	@echo "Compiling AlcConsole.abc"
	@java -classpath $(ALCHEMY)/usr/lib/asc.jar macromedia.asc.embedding.ScriptCompiler \
	-abcfuture -AS3 -strict -optimize \
	-import $(ALCHEMY)/usr/lib/builtin.abc \
	-import $(ALCHEMY)/usr/lib/playerglobal.abc \
	-import $(GLS3D)/install/usr/lib/libGL.abc \
	-import $(ALCHEMY)/usr/lib/CModule.abc \
	-import $(ALCHEMY)/usr/lib/C_Run.abc \
	-import $(ALCHEMY)/usr/lib/initLib.abc \
	-import $(ALCHEMY)/usr/lib/BinaryData.abc \
	-import $(ALCHEMY)/usr/lib/PlayerPosix.abc \
	demos/AlcConsole.as -outdir demos -out AlcConsole

demos: demos/AlcConsole.abc

	@echo "Compiling lesson1.swf"
	@$(ALCHEMY)/usr/bin/g++ -O4 \
		-I$(GLS3D)/install/usr/include/ \
		-Iinstall/usr/include/ \
		-Linstall/usr/lib/ \
		-L$(GLS3D)/install/usr/lib/ \
		demos/NeHeLesson01/lesson1.cpp $(GLS3D)/install/usr/lib/libGL.abc -lGL -lglut \
		-symbol-abc=demos/AlcConsole.abc -swf-size=500x500 -emit-swf -o demos/lesson1.swf

	@echo "Compiling lesson2.swf"
	@$(ALCHEMY)/usr/bin/g++ -O4 \
		-I$(GLS3D)/install/usr/include/ \
		-Iinstall/usr/include/ \
		-Linstall/usr/lib/ \
		-L$(GLS3D)/install/usr/lib/ \
		demos/NeHeLesson02/lesson2.cpp $(GLS3D)/install/usr/lib/libGL.abc -lGL -lglut \
		-symbol-abc=demos/AlcConsole.abc -swf-size=500x500 -emit-swf -o demos/lesson2.swf

	@echo "Compiling shapes.swf"
	@$(ALCHEMY)/usr/bin/gcc -O4 \
		-I$(GLS3D)/install/usr/include/ \
		-Iinstall/usr/include/ \
		-Linstall/usr/lib/ \
		-L$(GLS3D)/install/usr/lib/ \
		demos/shapes.c $(GLS3D)/install/usr/lib/libGL.abc -lGL -lglut \
		-symbol-abc=demos/AlcConsole.abc -swf-size=500x500 -emit-swf -o demos/shapes.swf

	@echo "Compiling lesson19.swf"
	@rm -f demos/NeHeLesson19/embed*
	@cd demos/NeHeLesson19 && $(ALCHEMY)/usr/bin/genfs --type=embed vfs embed
	@cd demos/NeHeLesson19/ && java -Xmx1G -classpath $(ALCHEMY)/usr/lib/asc.jar macromedia.asc.embedding.ScriptCompiler \
	-AS3 \
	-import $(ALCHEMY)/usr/lib/builtin.abc \
	-import $(ALCHEMY)/usr/lib/playerglobal.abc \
	-import $(ALCHEMY)/usr/lib/BinaryData.abc \
	-import $(ALCHEMY)/usr/lib/PlayerPosix.abc \
	embed*.as -outdir . -out embed
	@$(ALCHEMY)/usr/bin/g++ -O4 \
		-I$(GLS3D)/install/usr/include/ \
		-Iinstall/usr/include/ \
		-Linstall/usr/lib/ \
		-L$(GLS3D)/install/usr/lib/ \
		demos/NeHeLesson19/lesson19.cpp $(GLS3D)/install/usr/lib/libGL.abc -lGL -lglut \
		-symbol-abc=demos/AlcConsole.abc demos/NeHeLesson19/embed*.abc -swf-size=500x500 -emit-swf -o demos/lesson19.swf

	@echo "Compiling lesson11.swf"
	@rm -f demos/NeHeLesson11/embed*
	@cd demos/NeHeLesson11 && $(ALCHEMY)/usr/bin/genfs --type=embed vfs embed
	@cd demos/NeHeLesson11/ && java -Xmx1G -classpath $(ALCHEMY)/usr/lib/asc.jar macromedia.asc.embedding.ScriptCompiler \
	-AS3 \
	-import $(ALCHEMY)/usr/lib/builtin.abc \
	-import $(ALCHEMY)/usr/lib/playerglobal.abc \
	-import $(ALCHEMY)/usr/lib/BinaryData.abc \
	-import $(ALCHEMY)/usr/lib/PlayerPosix.abc \
	embed*.as -outdir . -out embed
	@$(ALCHEMY)/usr/bin/g++ -O4 \
		-I$(GLS3D)/install/usr/include/ \
		-Iinstall/usr/include/ \
		-Linstall/usr/lib/ \
		-L$(GLS3D)/install/usr/lib/ \
		demos/NeHeLesson11/lesson11.cpp $(GLS3D)/install/usr/lib/libGL.abc -lGL -lglut \
		-symbol-abc=demos/AlcConsole.abc demos/NeHeLesson11/embed*.abc -swf-size=500x500 -emit-swf -o demos/lesson11.swf

	@echo "Compiling lesson12.swf"
	@rm -f demos/NeHeLesson12/embed*
	@cd demos/NeHeLesson12 && $(ALCHEMY)/usr/bin/genfs --type=embed vfs embed
	@cd demos/NeHeLesson12/ && java -Xmx1G -classpath $(ALCHEMY)/usr/lib/asc.jar macromedia.asc.embedding.ScriptCompiler \
	-AS3 \
	-import $(ALCHEMY)/usr/lib/builtin.abc \
	-import $(ALCHEMY)/usr/lib/playerglobal.abc \
	-import $(ALCHEMY)/usr/lib/BinaryData.abc \
	-import $(ALCHEMY)/usr/lib/PlayerPosix.abc \
	embed*.as -outdir . -out embed
	@$(ALCHEMY)/usr/bin/g++ -O4 \
		-I$(GLS3D)/install/usr/include/ \
		-Iinstall/usr/include/ \
		-Linstall/usr/lib/ \
		-L$(GLS3D)/install/usr/lib/ \
		demos/NeHeLesson12/lesson12.cpp $(GLS3D)/install/usr/lib/libGL.abc -lGL -lglut \
		-symbol-abc=demos/AlcConsole.abc demos/NeHeLesson12/embed*.abc -swf-size=500x500 -emit-swf -o demos/lesson12.swf

	@echo "Compiling lesson8.swf"
	@rm -f demos/NeHeLesson08/embed*
	@cd demos/NeHeLesson08 && $(ALCHEMY)/usr/bin/genfs --type=embed vfs embed
	@cd demos/NeHeLesson08/ && java -Xmx1G -classpath $(ALCHEMY)/usr/lib/asc.jar macromedia.asc.embedding.ScriptCompiler \
	-AS3 \
	-import $(ALCHEMY)/usr/lib/builtin.abc \
	-import $(ALCHEMY)/usr/lib/playerglobal.abc \
	-import $(ALCHEMY)/usr/lib/BinaryData.abc \
	-import $(ALCHEMY)/usr/lib/PlayerPosix.abc \
	embed*.as -outdir . -out embed
	@$(ALCHEMY)/usr/bin/g++ -O4 \
		-I$(GLS3D)/install/usr/include/ \
		-Iinstall/usr/include/ \
		-Linstall/usr/lib/ \
		-L$(GLS3D)/install/usr/lib/ \
		-Idemos/NeHeCommon/ \
		demos/NeHeLesson08/lesson8.cpp demos/NeHeCommon/tgaload.cpp $(GLS3D)/install/usr/lib/libGL.abc -lGL -lglut \
		-symbol-abc=demos/AlcConsole.abc demos/NeHeLesson08/embed*.abc -swf-size=500x500 -emit-swf -o demos/lesson8.swf

	@echo "Compiling lesson7.swf"
	@rm -f demos/NeHeLesson07/embed*
	@cd demos/NeHeLesson07 && $(ALCHEMY)/usr/bin/genfs --type=embed vfs embed
	@cd demos/NeHeLesson07/ && java -Xmx1G -classpath $(ALCHEMY)/usr/lib/asc.jar macromedia.asc.embedding.ScriptCompiler \
	-AS3 \
	-import $(ALCHEMY)/usr/lib/builtin.abc \
	-import $(ALCHEMY)/usr/lib/playerglobal.abc \
	-import $(ALCHEMY)/usr/lib/BinaryData.abc \
	-import $(ALCHEMY)/usr/lib/PlayerPosix.abc \
	embed*.as -outdir . -out embed
	@$(ALCHEMY)/usr/bin/g++ -O4 \
		-I$(GLS3D)/install/usr/include/ \
		-Iinstall/usr/include/ \
		-Linstall/usr/lib/ \
		-L$(GLS3D)/install/usr/lib/ \
		-Idemos/NeHeCommon/ \
		demos/NeHeLesson07/lesson7.cpp demos/NeHeCommon/tgaload.cpp $(GLS3D)/install/usr/lib/libGL.abc -lGL -lglut \
		-symbol-abc=demos/AlcConsole.abc demos/NeHeLesson07/embed*.abc -swf-size=500x500 -emit-swf -o demos/lesson7.swf

	@echo "Compiling lesson6.swf"
	@rm -f demos/NeHeLesson06/embed*
	@cd demos/NeHeLesson06 && $(ALCHEMY)/usr/bin/genfs --type=embed vfs embed
	@cd demos/NeHeLesson06/ && java -Xmx1G -classpath $(ALCHEMY)/usr/lib/asc.jar macromedia.asc.embedding.ScriptCompiler \
	-AS3 \
	-import $(ALCHEMY)/usr/lib/builtin.abc \
	-import $(ALCHEMY)/usr/lib/playerglobal.abc \
	-import $(ALCHEMY)/usr/lib/BinaryData.abc \
	-import $(ALCHEMY)/usr/lib/PlayerPosix.abc \
	embed*.as -outdir . -out embed
	@$(ALCHEMY)/usr/bin/g++ -O4 \
		-I$(GLS3D)/install/usr/include/ \
		-Iinstall/usr/include/ \
		-Linstall/usr/lib/ \
		-L$(GLS3D)/install/usr/lib/ \
		-Idemos/NeHeCommon/ \
		demos/NeHeLesson06/lesson06.cpp demos/NeHeCommon/tgaload.cpp $(GLS3D)/install/usr/lib/libGL.abc -lGL -lglut \
		-symbol-abc=demos/AlcConsole.abc demos/NeHeLesson06/embed*.abc -swf-size=500x500 -emit-swf -o demos/lesson6.swf

	@echo "Compiling lesson5.swf"
	@$(ALCHEMY)/usr/bin/gcc -O4 \
		-I$(GLS3D)/install/usr/include/ \
		-Iinstall/usr/include/ \
		-Linstall/usr/lib/ \
		-L$(GLS3D)/install/usr/lib/ \
		demos/NeHeLesson05/lesson5.c $(GLS3D)/install/usr/lib/libGL.abc -lGL -lglut \
		-symbol-abc=demos/AlcConsole.abc -swf-size=500x500 -emit-swf -o demos/lesson5.swf
	
	@echo "Compiling lesson3.swf"
	@$(ALCHEMY)/usr/bin/gcc -O4 \
		-I$(GLS3D)/install/usr/include/ \
		-Iinstall/usr/include/ \
		-Linstall/usr/lib/ \
		-L$(GLS3D)/install/usr/lib/ \
		demos/NeHeLesson03/lesson3.c $(GLS3D)/install/usr/lib/libGL.abc -lGL -lglut \
		-symbol-abc=demos/AlcConsole.abc -swf-size=500x500 -emit-swf -o demos/lesson3.swf

	@echo "Compiling lesson4.swf"
	@$(ALCHEMY)/usr/bin/gcc -O4 \
		-I$(GLS3D)/install/usr/include/ \
		-Iinstall/usr/include/ \
		-Linstall/usr/lib/ \
		-L$(GLS3D)/install/usr/lib/ \
		demos/NeHeLesson04/lesson4.c $(GLS3D)/install/usr/lib/libGL.abc -lGL -lglut \
		-symbol-abc=demos/AlcConsole.abc -swf-size=500x500 -emit-swf -o demos/lesson4.swf
	@echo "Compiling shapes.swf"




compile: $(OBJS)

.c.o:
	@echo "Compiling $<"
	@$(ALCHEMY)/usr/bin/gcc -DHAVE_GETTIMEOFDAY -DHAVE_ERRNO_H -DHAVE_LIMITS_H -DHAVE_VFPRINTF -DHAVE_UNISTD_H -O4 -c \
		-I$(GLS3D)/install/usr/include/ -Iinstall/usr/include/ $< -o $@
