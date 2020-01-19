function y = abs_phase2complex(abs_val, phase_val)
y = abs_val.*cos(phase_val) + 1i.*abs_val.*sin(phase_val);