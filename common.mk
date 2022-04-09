LOWDOWN_PATH=../lowdown
CSS_PATH=../style.css

.PHONY: html
html: $(NOTE_NAME).md
	@rm -f $(NOTE_NAME).html
	@$(LOWDOWN_PATH) -s $< -o $(NOTE_NAME).$@ -thtml \
	-M author="$(AUTHOR)" \
	-M title="$(TITLE)" \
	-M css="$(CSS_PATH)"
	@echo -e "generated $(COLOR_BLUE)$(NOTE_NAME).html$(COLOR_NONE)"
