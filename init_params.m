% ===== 1) 仿真时间 =====
Tstop = 24;          % 仿真总时长(s)

% ===== 2) 气囊执行机构（一阶）=====
tau_p = 0.5;         % 气动时间常数(s)
Pmax_kPa = 40;       % 囊压上限(kPa)

% ===== 3) 接触面积与单位换算 =====
A_contact = 3e-4;    % 气囊与皮肤有效接触面积(m^2) 约 17mm×17mm
kPa2Pa = 1000;       % 1 kPa = 1000 Pa

% ===== 4) 两层组织动力学（线性 2DOF）=====
params.m1 = 0.03;    % 表层等效质量(kg)
params.m2 = 0.12;    % 深层等效质量(kg)

params.k1 = 2500;    % 表层刚度(N/m)
params.k2 = 600;     % 深层刚度(N/m)

params.c1 = 30;      % 表层阻尼(Ns/m)
params.c2 = 80;      % 深层阻尼(Ns/m)

params.kc = 3000;    % 层间耦合刚度(N/m)
params.cc = 60;      % 层间耦合阻尼(Ns/m)

% （可选）轻非线性：让F-x不那么直（先设0，跑通后再加）
params.gamma = 0;    % 表层硬化系数(N/m^3)，例如 5e6 会明显弯

% ===== 5) 血管/灌注输出（只做“单调映射”，为了出图）=====
vessel.eta = 0.6;        % 外压传递系数(0~1)
vessel.A_art = 1e-5;     % 等效受压面积(m^2)，仅做尺度
vessel.A0 = 1;           % 归一化基准截面积
vessel.Amin = 0.1;       % 最小截面积（避免变成0）
vessel.Ps = 10;          % sigmoid尺度（越小越敏感）

% ===== 6) 动脉压力波（为了PPG随脉搏抖动）=====
P_art_base = 16;     % 动脉压力基线(kPa) 只是示意
P_art_amp  = 2;      % 脉搏幅值(kPa)
heart_f = 1.2;       % 心率频率(Hz)

disp("init_params.m 已运行：参数已加载到工作区");
% ===== 给 MATLAB Function 用：把 params 拆成标量 =====
m1 = params.m1;  m2 = params.m2;
k1 = params.k1;  k2 = params.k2;
c1 = params.c1;  c2 = params.c2;
kc = params.kc;  cc = params.cc;
gamma = params.gamma;

% ===== Vessel 也拆成标量（避免后面同类错误）=====
eta  = vessel.eta;
A0   = vessel.A0;
Amin = vessel.Amin;
Ps   = vessel.Ps;
%% ===== 7) PPG/EDA/阻抗 传感与状态参数（用于Fig5） =====

% --- 心率与PPG ---
heart_f = 1.2;            % Hz，约72 bpm
ppg_noise_std = 0.003;      % PPG噪声强度（越大越抖）
ppg_drift_amp = 0.03;      % 基线漂移幅度
ppg_drift_f = 0.05;        % Hz，漂移频率

% --- 压力测量噪声/量化 ---
Pc_noise_std = 0.015;       % kPa
Pc_quant_step = 0.01;      % kPa 量化步长
tau_pc_meas = 0.05;        % s 测量低通

% --- EDA（SCL） ---
P_pain_th = 26;            % kPa 疼痛阈值（可调）
P_pain_scale = 16;         % kPa 归一化尺度
tau_eda = 3.5;             % s 慢响应
eda_base = 0.15;           % 基线
eda_gain = 0.8;            % 增益
eda_noise_std = 0.0015;

% --- 出血/阻抗（B为渗血聚集量，越大表示越“在出血/未止血”） ---
k_bleed = 0.08;            % 渗血增长速率
k_clot  = 0.04;            % 凝血消退速率
P_bleed_th = 8;            % kPa 跨壁压阈值（高于此更可能出血）
P_bleed_slope = 2;         % kPa sigmoid坡度

Z0 = 1.0;                  % 归一化阻抗基线
alphaZ = 0.35;             % B->Z映射系数（B增大 Z下降）
Z_noise_std = 0.002;

% --- 特征滤波时间常数 ---
tau_env = 0.25;            % s PPG包络
tau_scl = 3.0;             % s SCL低通
tau_dz  = 1.5;             % s dZ/dt微分低通

% --- 状态估计器权重（合理即可） ---
wZ = 3; wPPG = 2.4; wSCL = 0.75; wP = 0.45; w0 = 1.6;
Appg_low = 0.38;           % 灌注偏低阈值（越大越敏感）

% --- 自适应修正（可选） ---
trim_enable = 1;           % 1开0关
trim_lim = 6;              % kPa 修正幅度上限
k_trim_up = 0.8;           % risk促加压
k_trim_dn = 0.8;           % pain促减压
tau_trim = 1.0;            % s 修正变化时间尺度