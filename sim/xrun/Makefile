# ----------------------------------------------
# Makefile for YetAnotherUART project xcelium simulation
# Author: Kirill Lyubavin <kenezoer@gmail.com>
# ----------------------------------------------

export	PRJ_ROOT := ../..
export	TB_ROOT	 := ${PRJ_ROOT}/sim/tb
export  RTL_ROOT := ${PRJ_ROOT}/rtl

GUI				?= 0

TOOL			 = xrun

TOOL_OPTS		 = -access +rwc
TOOL_OPTS		+= -64bit
TOOL_OPTS		+= -sv
TOOL_OPTS		+= -timescale 1ns/1ns

ifneq ($GUI, 0)
	GUI_OPTS		 = -gui
endif

SIM_FILES		 = -F ${RTL_ROOT}/filelist.f
SIM_FILES		+= -F ${TB_ROOT}/tb_filelist.f

INCLUDES 	 	 = +incdir+${TB_ROOT}


.PHONY: help
help:
	@echo	"#---------------------------------------#"
	@echo	"# YetAnotherUART Project"
	@echo	"# by Kirill Lyubavin <kenezoer@gmail.com"
	@echo	"#---------------------------------------#"
	@echo	"# Usage:"
	@echo	"# make help            - prints the help"
	@echo	"# make sim  GUI=<0,1>  - run Xcelium simulation with optional GUI mode (if GUI=1)"
	@echo	"# make clean           - clean the all temp. files"
	@echo	"#---------------------------------------#"

.PHONY: sim
sim: 
	$(TOOL) $(TOOL_OPTS) $(GUI_OPTS) $(INCLUDES) $(SIM_FILES)


.PHONY: clean
clean: 
	@rm -rf *.log *.history *xcelium* *xrun*
