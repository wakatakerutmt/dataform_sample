# all targets are phony ( do not make file )
.PHONY: $(shell grep -E -o ^[a-zA-Z_-]+: $(MAKEFILE_LIST) | sed 's/Makefile://' | sed 's/://')

in:
	@docker-compose exec -it dataform sh
