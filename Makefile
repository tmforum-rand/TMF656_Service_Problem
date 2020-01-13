API-NAME:=TMF656_Service_Problem

GEN-SWAGGER=tooling-ucayali/tools/gen_swagger.py
EXT-SWAGGER=tooling-ucayali/tools/extract_swagger.py
GEN-SPEC=tooling-ucayali/tools/gen_spec.py
DIR-DIAGRAMS=documentation/diagrams
DIR-ROOT=../..
API-ROOT=working-apis/$(API-NAME)
YAML-FILE:=$(shell ls *.rules.yaml)
#YAML-FULL=$(API-ROOT)/$(YAML-FILE)
SWAGGER-FILE:=$(shell ls swaggers-gen/*.regular.swagger.json)
PYTHON=/usr/bin/python3.6

all: env swagger spec

env:
	@echo -n "Python: "; $(PYTHON) -V
	@pip -V
	@echo "Looking for python-docx and Pillow modules:"; pip freeze | egrep -e python-docx -e Pillow -
	@echo -n "Node: "; node -v

swagger: $(YAML-FILE)
	@echo "Making the swagger file"
	cd $(DIR-ROOT) && \
	$(PYTHON) $(GEN-SWAGGER) $(API-ROOT)
	# @cd swaggers-gen && \
	# mv *.regular.swagger.json $(subst _,-,$(API-NAME))-v$(shell cat *.regular.swagger.json | $(PYTHON) -c "import sys,json;print(json.load(sys.stdin)['info']['version'])").swagger.json

spec: swagger diagrams
	@echo "Making specification"
	cd $(DIR-ROOT) && \
	$(PYTHON) $(GEN-SPEC) $(API-ROOT)

diagrams: swagger
	@echo "Making diagrams"
	@if [ ! -d $(DIR-DIAGRAMS) ]; then \
		mkdir $(DIR-DIAGRAMS); \
	 fi
	@cd $(DIR-DIAGRAMS) && \
	sh ../../../../diagram-generator/process_swagger.sh ../../$(SWAGGER-FILE)

extract:
	@echo "Extracting schemas from the swagger file"
	$(PYTHON) $(DIR-ROOT)/$(EXT-SWAGGER) swaggers-gen/Service_Problem.regular.swagger.json .
