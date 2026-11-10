export DESIGN_NAME = precision_lock_system_opt
export DESIGN_NICKNAME = precision_lock_alu
export PLATFORM = sky130hd

export VERILOG_FILES = $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/src/precision_detector.v \
                       $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/src/precision_lock_alu.v \
                       $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/src/precision_transition_profiler_opt.v \
                       $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/src/precision_lock_system_opt.v

export SDC_FILE = $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export CORE_UTILIZATION = 40
export PLACE_DENSITY = 0.60
export TNS_END_PERCENT = 100
