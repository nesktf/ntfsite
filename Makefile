BUILD_DIR 	:= build
TEMPL_DIR 	:= templ
STATIC_DIR 	:= static
SRC_DIR 		:= src
DATA_DIR 		:= data

FNLC		:= fennel -c
LUAINT	:= luajit
FNL_SRC := $(wildcard $(SRC_DIR)/*.fnl)
LUA_SRC := $(patsubst $(SRC_DIR)/%.fnl, $(BUILD_DIR)/%.lua, $(FNL_SRC))
LUAPATH := ${LUA_PATH};./$(BUILD_DIR)/?.lua

SITE_MAKER	:= $(BUILD_DIR)/main.lua
OUTPUT_DIR	:= $(BUILD_DIR)/site

.PHONY: site clean lua

all: site

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.lua: $(SRC_DIR)/%.fnl | $(BUILD_DIR)/
	@echo "- Compiling fenel source " $<
	$(FNLC) $< > $@

lua: $(BUILD_DIR)/ $(LUA_SRC)

$(OUTPUT_DIR)/: $(BUILD_DIR)/
	@echo "- Copying static site data..."
	cp -r $(STATIC_DIR) $(OUTPUT_DIR)/

site: export LUA_PATH = $(LUAPATH)
site: $(OUTPUT_DIR)/ lua 
	@echo "- Compiling site templates..."
	$(LUAINT) $(SITE_MAKER) $(TEMPL_DIR) $(SRC_DIR) $(OUTPUT_DIR) $(DATA_DIR)

clean: $(BUILD_DIR)
	rm -rf $(BUILD_DIR)
