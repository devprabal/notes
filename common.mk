LOWDOWN_PATH=../lowdown
CSS_PATH=../style.css

.PHONY: html
html: $(NOTE_NAME).md
	@rm -f $(NOTE_NAME).html
	@$(LOWDOWN_PATH) -s $< -o $(NOTE_NAME).$@ -thtml \
	-M author="$(AUTHOR)" \
	-M title="$(TITLE)" \
	-M css="$(CSS_PATH)"
	@sed -i 's|<body>|<body>\n<header>\n\t<a href="../index.html">Home</a>\n</header>|g' $(NOTE_NAME).$@
	@echo -e "generated $(COLOR_BLUE)$(NOTE_NAME).html$(COLOR_NONE)"
