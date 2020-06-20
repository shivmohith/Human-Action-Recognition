function bin_sum = mbhx(cuboid)
    opticFlow = opticalFlowLK;
    bin_sum = zeros(1,8);
    for t = 1:5
        bin = zeros(1,8);
        flow = estimateFlow(opticFlow,cuboid(:,:,t));
        [Vxx,Vxy] = imgradientxy(flow.Vx);
        [m,o] = imgradient(Vxx,Vxy);
        for r=1:size(m,1)
              for c=1:size(m,2)
                     v=abs(o(r,c));
                     if v>11.25 && v<=33.75
                            bin(1)=bin(1)+ m(r,c)*(33.75-v)/22.5;
                            bin(2)=bin(2)+ m(r,c)*(v-11.25)/22.5;
                     elseif v>33.75 && v<=56.25
                            bin(2)=bin(2)+ m(r,c)*(56.25-v)/22.5;                 
                            bin(3)=bin(3)+ m(r,c)*(v-33.75)/22.5;
                     elseif v>56.25 && v<=78.75
                            bin(3)=bin(3)+ m(r,c)*(78.75-v)/22.5;
                            bin(4)=bin(4)+ m(r,c)*(v-56.25)/22.5;
                     elseif v>78.75 && v<=101.25
                            bin(4)=bin(4)+ m(r,c)*(101.25-v)/22.5;
                            bin(5)=bin(5)+ m(r,c)*(v-78.75)/22.5;
                     elseif v>101.25 && v<=123.75
                            bin(5)=bin(5)+ m(r,c)*(123.75-v)/22.5;
                            bin(6)=bin(6)+ m(r,c)*(v-101.25)/22.5;
                     elseif v>123.75 && v<=146.25
                            bin(6)=bin(6)+ m(r,c)*(146.25-v)/22.5;
                            bin(7)=bin(7)+ m(r,c)*(v-123.75)/22.5;
                     elseif v>146.25 && v<=168.75
                            bin(7)=bin(7)+ m(r,c)*(168.75-v)/22.5;
                            bin(8)=bin(8)+ m(r,c)*(v-146.25)/22.5;
                     elseif v>=0 && v<=11.25
                            bin(1)=bin(1)+ m(r,c)*(v+10)/22.5;
                            bin(8)=bin(8)+ m(r,c)*(10-v)/22.5;
                     elseif v>168.75 && v<=180
                            bin(8)=bin(8)+ m(r,c)*(191.25-v)/22.5;
                            bin(1)=bin(1)+ m(r,c)*(v-168.75)/22.5;
                     end

              end
        end
        %bin_sum = bin_sum + normalize(bin,'norm',1);
        bin_sum = bin_sum + bin;
    end
end
