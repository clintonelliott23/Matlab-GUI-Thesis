

% syms IRR_sym
% investment_cost = 800;
% cash_flows_discounted = [100 200 300 400 500];
% IRR_eqn = 0;
% 
% for i = 1:1:5
%  IRR_eqn = IRR_eqn + cash_flows_discounted(1,i) / (1 + IRR_sym)^i;
% end
% IRR_eqn = IRR_eqn - investment_cost == 0
% IRR_sol = real(double(solve(IRR_eqn, IRR_sym)))
%  
% Positive = IRR_sol > 0;
% IRR_sol(~Positive) = 0;
% IRR_val = 0;
% element =0;
% for i = 1:1:5
%     element = IRR_sol(i,1);
%         if element > IRR_val
%             IRR_val = element;
%         end
% end
% 
% disp(IRR_val*100)
     
state_codes = [4814 4825 0800 6000 3000 7000 2000 4000];
state_names = {'Townsville, QLD'; 'Mount Isa, QLD'; 'Darwin, NT'; 'Perth, WA'; 'Melbourne, VIC';...
    'Horbart, TAS'; 'Sydney, NSW'; 'Brisbane, QLD'};

f = figure('Position',[100 100 400 150]);
state_names = {'Townsville, QLD'; 'Mount Isa, QLD'; 'Darwin, NT'; 'Perth, WA'; 'Melbourne, VIC';...
    'Horbart, TAS'; 'Sydney, NSW'; 'Brisbane, QLD'};
checkbox1= num2cell([4814; 4825; 0800])
yourdata =[num2cell(state_codes') state_names]  
columnname =   {'Postcode', 'Location'};
columnformat = {'char', 'char'};
columneditable =  [true false]; 
t = uitable('Units','normalized','Position',...
          [0.1 0.1 0.9 0.9], 'Data', yourdata,... 
          'ColumnName', columnname,...
          'ColumnFormat', columnformat,...
          'ColumnEditable', columneditable,...
          'RowName',[] ,'BackgroundColor',[.7 .9 .8],...
          'ForegroundColor',[0 0 0],'ColumnWidth',{100 155});
      
      
      
      
      
      
      
      
      