.PHONY: html
html: $(NOTE_NAME).md
	@rm -f $(NOTE_NAME).html
	lowdown -s $< -o $(NOTE_NAME).$@ -thtml \
	-M author="$(AUTHOR)" \
	-M title="$(TITLE)" \
	-M css=../style.css
	@sed -i 's|<body>|<body>\n<header>\n\t<a href="../index.html">Home</a>\n</header>|g' $(NOTE_NAME).$@
	@sed -i 's|</body>|</body>\n<footer>\n\t<a href="../index.html">Home</a>\n</footer>|g' $(NOTE_NAME).$@
	@echo "generated $(COLOR_BLUE)$(NOTE_NAME).html$(COLOR_NONE)"
