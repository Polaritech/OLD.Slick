Gloss.Target := gloss.bin

Build/Binaries/gloss.bin: $(OBJ_Gloss)
	@cat $< > $@