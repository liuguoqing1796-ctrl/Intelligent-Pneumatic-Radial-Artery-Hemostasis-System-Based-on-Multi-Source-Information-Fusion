% make_protocolB.m
% 脚本版：生成 From Workspace 读取的 Pcmd_ts

if ~exist('Pmax_kPa','var')
    Pmax_kPa = 25;   % 默认值
end

Tstop = 20;
t_on  = 5;
t_off = 15;

A  = 3;
f  = 1;
dt = 0.001;

t = (0:dt:Tstop)';

P = zeros(size(t));
idx = (t >= t_on) & (t <= t_off);
P(idx) = Pmax_kPa + A*sin(2*pi*f*(t(idx)-t_on));

Pcmd_ts = timeseries(P,t);
Pcmd_ts.Name = 'Pcmd_ts';

disp('Pcmd_ts 已生成');