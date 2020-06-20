function bin_sum = hog(cuboid)
    k =[-1 0 1];
    bin_sum = zeros(1,8);
    for t = 1:5
        bin = zeros(1,8);
        sx=conv2(k,cuboid(:,:,t));
        sy=conv2(k',cuboid(:,:,t));
        for r=1:size(sx,1)
              for c=1:size(sx,2)-2
                  m=sqrt(sx(r,c)^2+sy(r,c)^2);
                  o=atan2(sy(r,c),sx(r,c));
                  v=rad2deg(abs(o));
                     if v>11.25 && v<=33.75
                            bin(1)=bin(1)+ m*(33.75-v)/22.5;
                            bin(2)=bin(2)+ m*(v-11.25)/22.5;
                     elseif v>33.75 && v<=56.25
                            bin(2)=bin(2)+ m*(56.25-v)/22.5;                 
                            bin(3)=bin(3)+ m*(v-33.75)/22.5;
                     elseif v>56.25 && v<=78.75
                            bin(3)=bin(3)+ m*(78.75-v)/22.5;
                            bin(4)=bin(4)+ m*(v-56.25)/22.5;
                     elseif v>78.75 && v<=101.25
                            bin(4)=bin(4)+ m*(101.25-v)/22.5;
                            bin(5)=bin(5)+ m*(v-78.75)/22.5;
                     elseif v>101.25 && v<=123.75
                            bin(5)=bin(5)+ m*(123.75-v)/22.5;
                            bin(6)=bin(6)+ m*(v-101.25)/22.5;
                     elseif v>123.75 && v<=146.25
                            bin(6)=bin(6)+ m*(146.25-v)/22.5;
                            bin(7)=bin(7)+ m*(v-123.75)/22.5;
                     elseif v>146.25 && v<=168.75
                            bin(7)=bin(7)+ m*(168.75-v)/22.5;
                            bin(8)=bin(8)+ m*(v-146.25)/22.5;
                     elseif v>=0 && v<=11.25
                            bin(1)=bin(1)+ m*(v+10)/22.5;
                            bin(8)=bin(8)+ m*(10-v)/22.5;
                     elseif v>168.75 && v<=180
                            bin(8)=bin(8)+ m*(191.25-v)/22.5;
                            bin(1)=bin(1)+ m*(v-168.75)/22.5;
                     end

              end
        end
        %bin_sum = bin_sum + normalize(bin,'norm',1);
        bin_sum = bin_sum + bin;
    end
end

        