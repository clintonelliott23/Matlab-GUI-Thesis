

syms IRR_sym
investment_cost = 50000;
cash_flows_discounted = [12000 15000 18000 71000 20000];
IRR_eqn = 0;

for i = 1:1:5
 IRR_eqn = IRR_eqn + cash_flows_discounted(1,i) / (1 + IRR_sym)^i;
end
IRR_eqn = IRR_eqn - investment_cost == 0
IRR_sol = real(double(solve(IRR_eqn, IRR_sym)))
 
Positive = IRR_sol > 0;
IRR_sol(~Positive) = 0;
IRR_val = 0;
element =0;
for i = 1:1:5
    element = IRR_sol(i,1);
        if element > IRR_val
            IRR_val = element;
        end
end

disp(IRR_val*100)
         