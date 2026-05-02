# This script segment is generated automatically by AutoPilot

set axilite_register_dict [dict create]
set port_control {
Q_in { 
	dir I
	width 64
	depth 1
	mode ap_none
	offset 16
	offset_end 27
}
K_in { 
	dir I
	width 64
	depth 1
	mode ap_none
	offset 28
	offset_end 39
}
V_in { 
	dir I
	width 64
	depth 1
	mode ap_none
	offset 40
	offset_end 51
}
O_out { 
	dir I
	width 64
	depth 1
	mode ap_none
	offset 52
	offset_end 63
}
q_scale { 
	dir I
	width 32
	depth 1
	mode ap_none
	offset 64
	offset_end 71
}
v_scale { 
	dir I
	width 32
	depth 1
	mode ap_none
	offset 72
	offset_end 79
}
ap_start { }
ap_done { }
ap_ready { }
ap_idle { }
interrupt {
}
}
dict set axilite_register_dict control $port_control


