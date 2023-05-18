COPYBOOKS	:= $(wildcard Copybooks/*.cpy)
SOURCES		:= $(wildcard src/*.cbl)
OBJECTS		:= $(SOURCES:src/%.cbl=obj/%.o)

all: bin/book

clean:
	@rm -rf bin obj

obj/%.o: src/%.cbl $(COPYBOOKS)
	@mkdir -p obj
	@cob -xg -c $< -C "int(obj/)" -o obj/

bin/book: $(OBJECTS)
	@mkdir -p bin
	@cob -xg -o $@ -e cli $^
