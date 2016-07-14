
create_project -f project_1 ./project_1 -part xc7a100tcsg324-1

set obj [get_filesets sources_1]
set files [list \
 "[file normalize "../../src/wb2axi.sv"]"\
]
add_files -norecurse -fileset $obj $files

set obj [get_filesets sources_1]
set files [list \
 "[file normalize "blk_mem_gen_0.xci"]"\
]
add_files -norecurse -fileset $obj $files

set obj [get_filesets sim_1]
set files [list \
 "[file normalize "tb_wb2axi.sv"]"\
]
add_files -norecurse -fileset $obj $files
set_property top tb_wb2axi $obj

launch_simulation
