.PHONY: test test-file lint format

test:
	nvim --headless -u tests/minimal_init.lua \
		-c "PlenaryBustedDirectory tests/canary/ {minimal_init = 'tests/minimal_init.lua'}"

test-file:
	nvim --headless -u tests/minimal_init.lua \
		-c "PlenaryBustedFile $(FILE)"

lint:
	luacheck lua/ tests/ --globals vim describe it assert before_each after_each

format:
	stylua lua/ tests/ plugin/
