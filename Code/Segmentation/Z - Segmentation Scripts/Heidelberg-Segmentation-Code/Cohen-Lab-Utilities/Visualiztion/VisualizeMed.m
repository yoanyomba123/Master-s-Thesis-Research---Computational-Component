function VisualizeMed(Volume, argument, type);

figure;
for i = 1: size(Volume, 3)
   imshow(Volume(:,:,i)); 
   hold on;
   plot(argument(i,:), 'r');
   if(strcmp(type, 'med') == 1)
        hold off; title("Middle Line Present On OCT Image");
   end
   if(strcmp(type, 'rpe') == 1)
       hold off; title("RPE Line Present On OCT Image");
   end
   if(strcmp(type, 'infl') == 1)
       hold off; title("INFL Line Present On OCT Image");
   end
   if(strcmp(type, 'bv') == 1)
       hold off; title("Blood Vessel Lines Line Present On OCT Image");
   end
   drawnow;  
end


end

