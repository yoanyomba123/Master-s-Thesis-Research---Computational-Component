function VisualizeInnerLines(Volume, arg1, arg2, arg3)

figure;
for i = 1: size(Volume, 3)
   imshow(Volume(:,:,i)); 
   hold on;
   plot(arg1(i,:), '.r');
   hold on;
   plot(arg2(i,:), '.b');
   hold on;
   plot(arg3(i,:), '.c');
   hold off; title("Inner lines Present On OCT Image");

   drawnow;  
end


end



