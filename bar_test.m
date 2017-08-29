
month_name = ({'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec';'Avg'});          

  for i = 1:1:13
                     bar_hold(1,i) = i^2                    
                        hold all
  end
                     bar(bar_hold,'FaceColor',[0 .8 .5],'EdgeColor','yellow','LineWidth',1.5);      
  set(gca, 'XTick', 1:13,'xticklabel',month_name)
  
  
%    x = rand(4,1);
%    bar(x);
%    Labels = {'a', 'b', 'c', 'd'};
%    set(gca, 'XTick', 1:4, 'XTickLabel', Labels);