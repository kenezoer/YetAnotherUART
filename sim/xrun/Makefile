# ----------------------------------------------
# Makefile for YetAnotherUART project xcelium simulation
# Author: Kirill Lyubavin <kenezoer@gmail.com>
# ----------------------------------------------

export	PRJ_ROOT := ../..
export	TB_ROOT	 := ${PRJ_ROOT}/sim/tb
export  RTL_ROOT := ${PRJ_ROOT}/rtl

TOOL			 = xrun

TOOL_OPTS		 = -access +rwc
TOOL_OPTS		+= -64bit
TOOL_OPTS		+= -sv
TOOL_OPTS		+= -timescale 1ns/1ns

GUI_OPTS		 = -gui

SIM_FILES		 = -F ${RTL_ROOT}/filelist.f
SIM_FILES		+= -F ${TB_ROOT}/tb_filelist.f


.PHONY: sim
sim: 
	$(TOOL) $(TOOL_OPTS) $(GUI_OPTS) $(SIM_FILES)


.PHONY: clean
clean: 
	@rm -rf *.log *.history *xcelium* *xrun*
