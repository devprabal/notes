NOTE_NAME=linux_notes

include ../vars.mk

build: clean html

clean:
	@rm -f $(NOTE_NAME).html

html: $(NOTE_NAME).md
	@$(LOWDOWN_PATH) -s $< -o $(NOTE_NAME).$@ -thtml \
	-M author="$(AUTHOR)" \
	-M title="$(TITLE)" \
	-M css="$(CSS_PATH)"
	@echo -e "generated $(COLOR_BLUE)$(NOTE_NAME).html$(COLOR_NONE)"
