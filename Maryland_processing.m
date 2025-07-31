clc
clear all
close all
%电流为正表示充电，为负表示放电。
%这里自行修改需要制表的文件（使用前将Dynamic Profile Files文件设置到当前路径）
DST_US06_FUDS = xlsread('A1-007-DST-US06-FUDS-0-20120813.xlsx',3);
% DST_US06_FUDS = xlsread('A1-008-DST-US06-FUDS-20-20120817.xlsx',3);
% Step_Ind=1：电池初始状态； 
% Step_Ind=2：电池放电到截至电压2V；
% Step_Ind=3：电池静置； 
% Step_Ind=4：电池1c恒流充电；
% Step_Ind=5：电池恒压充电至截至电流；
% Step_Ind=6：电池状态切换过渡，无效；
% Step_Ind=7：电池充满电后静置；
% Step_Ind=8：电池DST工况放电；
% Step_Ind=9：电池DST工况电流为0的小循环过渡环节，建议删除9前一个数据；
% Step_Ind=10：电池状态切换过渡，无效；
% Step_Ind=11：电池静置5min；
% Step_Ind=12：电池1c恒流充电；
% Step_Ind=13：电池恒压充电至截至电流；
% Step_Ind=14：电池状态切换过渡，无效；
% Step_Ind=15：电池充满电后静置；
% Step_Ind=16：电池US06工况放电；
% Step_Ind=17：电池US06工况电流为0的小循环过渡环节，建议删除17前一个数据；
% Step_Ind=18：电池状态切换过渡，无效；
% Step_Ind=19：电池静置5min；
% Step_Ind=20：电池1c恒流充电；
% Step_Ind=21：电池恒压充电至截至电流；
% Step_Ind=22：电池状态切换过渡，无效；
% Step_Ind=23：电池充满电后静置；
% Step_Ind=24：电池FUDS工况放电；
% Step_Ind=25：电池FUDS工况电流为0的小循环过渡环节，建议删除25前一个数据；
% Step_Ind=26、27：无效；

Time = DST_US06_FUDS(:,1);
Step_Ind = DST_US06_FUDS(:,3);
Voltage = DST_US06_FUDS(:,5);
Current = DST_US06_FUDS(:,4);
Temperature = DST_US06_FUDS(:,6);
%% DST工况数据：
%(1)充电数据；
Ind = find(Step_Ind == 4);
DST_charge_start = Ind(1);
Ind = find(Step_Ind == 5);
DST_charge_end = Ind(end);
DST_charge_time = Time(DST_charge_start:DST_charge_end);
DST_charge_relativetime = DST_charge_time - DST_charge_time(1);
DST_charge_voltage = Voltage(DST_charge_start:DST_charge_end);
DST_charge_current = Current(DST_charge_start:DST_charge_end);
DST_charge_temperature = Temperature(DST_charge_start:DST_charge_end);
DST_charge_SOC = cumtrapz(DST_charge_relativetime, DST_charge_current)/3600/1.1;
%充电数据表格
DST_charge_data = struct('relativeTime',[],'voltage',[],'current',[],'temperature',[],'SOC',[]);
DST_charge_data.relativeTime = DST_charge_relativetime';
DST_charge_data.voltage = DST_charge_voltage';
DST_charge_data.current = DST_charge_current';
DST_charge_data.temperature = DST_charge_temperature';
DST_charge_data.SOC = DST_charge_SOC';

%(2)DST工况放电数据
Ind = find(Step_Ind == 8);
DST_work_start = Ind(1);
DST_work_end = Ind(end);
% Ind = find(Step_Ind == 9); %用于删除切换数据前一个点
% DST_delete = Ind-1;
DST_work_time = Time(DST_work_start:DST_work_end);
DST_work_relativetime = DST_work_time - DST_work_time(1);
DST_work_voltage = Voltage(DST_work_start:DST_work_end);
DST_work_current = Current(DST_work_start:DST_work_end);
DST_work_temperature = Temperature(DST_work_start:DST_work_end);
DST_work_SOC = 1-cumtrapz(DST_work_relativetime, DST_work_current)/3600/trapz(DST_work_relativetime, DST_work_current)*3600;
%放电数据表格
DST_discharge_data = struct('relativeTime',[],'voltage',[],'current',[],'temperature',[],'SOC',[]);
DST_discharge_data.relativeTime = DST_work_relativetime;
DST_discharge_data.voltage = DST_work_voltage;
DST_discharge_data.current = DST_work_current;
DST_discharge_data.temperature = DST_work_temperature;
DST_discharge_data.SOC = DST_work_SOC;
fieldNames = fieldnames(DST_discharge_data);
fieldData = struct2cell(DST_discharge_data);
myTable_DST = table(fieldData{:}, 'VariableNames', fieldNames);


%% US06工况数据：
%(1)充电数据；
Ind = find(Step_Ind == 12);
US06_charge_start = Ind(1);
Ind = find(Step_Ind == 13);
US06_charge_end = Ind(end);
US06_charge_time = Time(US06_charge_start:US06_charge_end);
US06_charge_relativetime = US06_charge_time - US06_charge_time(1);
US06_charge_voltage = Voltage(US06_charge_start:US06_charge_end);
US06_charge_current = Current(US06_charge_start:US06_charge_end);
US06_charge_temperature = Temperature(US06_charge_start:US06_charge_end);
US06_charge_SOC = cumtrapz(US06_charge_relativetime, US06_charge_current)/3600/1.1;
%充电数据表格
US06_charge_data = struct('relativeTime',[],'voltage',[],'current',[],'temperature',[],'SOC',[]);
US06_charge_data.relativeTime = US06_charge_relativetime';
US06_charge_data.voltage = US06_charge_voltage';
US06_charge_data.current = US06_charge_current';
US06_charge_data.temperature = US06_charge_temperature';
US06_charge_data.SOC = US06_charge_SOC';

%(2)US06工况放电数据
Ind = find(Step_Ind == 16);
US06_work_start = Ind(1);
US06_work_end = Ind(end);
% Ind = find(Step_Ind == 17); %用于删除切换数据前一个点
% US06_delete = Ind-1;
US06_work_time = Time(US06_work_start:US06_work_end);
US06_work_relativetime = US06_work_time - US06_work_time(1);
US06_work_voltage = Voltage(US06_work_start:US06_work_end);
US06_work_current = Current(US06_work_start:US06_work_end);
US06_work_temperature = Temperature(US06_work_start:US06_work_end);
US06_work_SOC = 1-cumtrapz(US06_work_relativetime, US06_work_current)/3600/trapz(US06_work_relativetime, US06_work_current)*3600;
%放电数据表格
US06_discharge_data = struct('relativeTime',[],'voltage',[],'current',[],'temperature',[],'SOC',[]);
US06_discharge_data.relativeTime = US06_work_relativetime;
US06_discharge_data.voltage = US06_work_voltage;
US06_discharge_data.current = US06_work_current;
US06_discharge_data.temperature = US06_work_temperature;
US06_discharge_data.SOC = US06_work_SOC;
% fieldNames = fieldnames(US06_discharge_data);
% fieldData = struct2cell(US06_discharge_data);
% myTable_US06 = table(fieldData{:}, 'VariableNames', fieldNames);

%% FUDS工况数据：
%(1)充电数据；
Ind = find(Step_Ind == 20);
FUDS_charge_start = Ind(1);
Ind = find(Step_Ind == 21);
FUDS_charge_end = Ind(end);
FUDS_charge_time = Time(FUDS_charge_start:FUDS_charge_end);
FUDS_charge_relativetime = FUDS_charge_time - FUDS_charge_time(1);
FUDS_charge_voltage = Voltage(FUDS_charge_start:FUDS_charge_end);
FUDS_charge_current = Current(FUDS_charge_start:FUDS_charge_end);
FUDS_charge_temperature = Temperature(FUDS_charge_start:FUDS_charge_end);
FUDS_charge_SOC = cumtrapz(FUDS_charge_relativetime, FUDS_charge_current)/3600/1.1;
%充电数据表格
FUDS_charge_data = struct('relativeTime',[],'voltage',[],'current',[],'temperature',[],'SOC',[]);
FUDS_charge_data.relativeTime = FUDS_charge_relativetime;
FUDS_charge_data.voltage = FUDS_charge_voltage;
FUDS_charge_data.current = FUDS_charge_current;
FUDS_charge_data.temperature = FUDS_charge_temperature;
FUDS_charge_data.SOC = FUDS_charge_SOC;

fieldNames = fieldnames(FUDS_charge_data);
fieldData = struct2cell(FUDS_charge_data);
myTable_FUDS_charge = table(fieldData{:}, 'VariableNames', fieldNames);

%(2)US06工况放电数据
Ind = find(Step_Ind == 24);
FUDS_work_start = Ind(1);
FUDS_work_end = Ind(end);
% Ind = find(Step_Ind == 25); %用于删除切换数据前一个点
% FUDS_delete = Ind-1;
FUDS_work_time = Time(FUDS_work_start:FUDS_work_end);
FUDS_work_relativetime = FUDS_work_time - FUDS_work_time(1);
FUDS_work_voltage = Voltage(FUDS_work_start:FUDS_work_end);
FUDS_work_current = Current(FUDS_work_start:FUDS_work_end);
FUDS_work_temperature = Temperature(FUDS_work_start:FUDS_work_end);
FUDS_work_SOC = 1-cumtrapz(FUDS_work_relativetime, FUDS_work_current)/3600/trapz(FUDS_work_relativetime, FUDS_work_current)*3600;

%放电数据表格
FUDS_discharge_data = struct('relativeTime',[],'voltage',[],'current',[],'temperature',[],'SOC',[]);
FUDS_discharge_data.relativeTime = FUDS_work_relativetime;
FUDS_discharge_data.voltage = FUDS_work_voltage;
FUDS_discharge_data.current = FUDS_work_current;
FUDS_discharge_data.temperature = FUDS_work_temperature;
FUDS_discharge_data.SOC = FUDS_work_SOC;
fieldNames = fieldnames(FUDS_discharge_data);
fieldData = struct2cell(FUDS_discharge_data);
myTable_FUDS_discharge = table(fieldData{:}, 'VariableNames', fieldNames);

%% 保存成表格
% save DST_20_2_charge_data DST_charge_data;
save DST_0_2_discharge_data_007 myTable_DST;
%save US06_20_2_charge_data US06_charge_data;
% save US06_N10_2_discharge_data_008 myTable_US06;
% save FUDS_20_2_charge_data myTable_FUDS_charge;
% save FUDS_N10_2_discharge_data_008 myTable_FUDS_discharge;
















