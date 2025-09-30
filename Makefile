BUILD_DIR 	:= build
TEMPL_DIR 	:= templ
STATIC_DIR 	:= static
SCRIPT_DIR	:= script
SRC_DIR 		:= src

FNLC		:= fennel -c
LUAINT	:= luajit
FNL_SRC := $(wildcard $(SCRIPT_DIR)/*.fnl)
LUA_SRC := $(patsubst $(SCRIPT_DIR)/%.fnl, $(BUILD_DIR)/%.lua, $(FNL_SRC))
LUAPATH := ${LUA_PATH};./$(BUILD_DIR)/?.lua

SITEC				:= $(BUILD_DIR)/compiler.lua
SITE_SRCS 	:= $(wildcard $(SRC_DIR)/*.etlua)
SITE_METAS 	:= $(patsubst $(SRC_DIR)/%.etlua, $(SRC_DIR)/%.fnl, $(SITE_SRCS))

OUTPUT_DIR	:= $(BUILD_DIR)/site

.PHONY: site clean lua

all: site

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.lua: $(SCRIPT_DIR)/%.fnl | $(BUILD_DIR)/
	@echo "- Compiling fenel source " $<
	$(FNLC) $< > $@

lua: $(BUILD_DIR)/ $(LUA_SRC)

$(OUTPUT_DIR)/: $(BUILD_DIR)/
	@echo "- Copying static site data..."
	cp -r $(STATIC_DIR) $(OUTPUT_DIR)/

site: export LUA_PATH = $(LUAPATH)
site: $(OUTPUT_DIR)/ lua 
	@echo "- Compiling site templates..."
	$(LUAINT) $(SITEC) $(TEMPL_DIR) $(SRC_DIR) $(OUTPUT_DIR)

clean: $(BUILD_DIR)
	rm -rf $(BUILD_DIR)
