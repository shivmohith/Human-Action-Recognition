function bin_sum = hof(cuboid)
    opticFlow = opticalFlowLK;
    bin_sum = zeros(1,9);
    for t = 1:5
        bin = zeros(1,9);
        flow = estimateFlow(opticFlow,cuboid(:,:,t));
        for r=1:(size(flow.Orientation,1))
         for c=1:(size(flow.Orientation,2)) 
                  k=abs(rad2deg(flow.Orientation(r,c)));
                  if k>10 && k<=30
                            bin(1)=bin(1)+ flow.Magnitude(r,c)*(30-k)/20;
                            bin(2)=bin(2)+ flow.Magnitude(r,c)*(k-10)/20;
                  elseif k>30 && k<=50
                            bin(2)=bin(2)+ flow.Magnitude(r,c)*(50-k)/20;                 
                            bin(3)=bin(3)+ flow.Magnitude(r,c)*(k-30)/20;
                  elseif k>50 && k<=70
                            bin(3)=bin(3)+ flow.Magnitude(r,c)*(70-k)/20;
                            bin(4)=bin(4)+ flow.Magnitude(r,c)*(k-50)/20;
                  elseif k>70 && k<=90
                            bin(4)=bin(4)+ flow.Magnitude(r,c)*(90-k)/20;
                            bin(5)=bin(5)+ flow.Magnitude(r,c)*(k-70)/20;
                  elseif k>90 && k<=110
                            bin(5)=bin(5)+ flow.Magnitude(r,c)*(110-k)/20;
                            bin(6)=bin(6)+ flow.Magnitude(r,c)*(k-90)/20;
                  elseif k>110 && k<=130
                            bin(6)=bin(6)+ flow.Magnitude(r,c)*(130-k)/20;
                            bin(7)=bin(7)+ flow.Magnitude(r,c)*(k-110)/20;
                  elseif k>130 && k<=150
                            bin(7)=bin(7)+ flow.Magnitude(r,c)*(150-k)/20;
                            bin(8)=bin(8)+ flow.Magnitude(r,c)*(k-130)/20;
                  elseif k>150 && k<=170
                            bin(8)=bin(8)+ flow.Magnitude(r,c)*(170-k)/20;
                            bin(9)=bin(9)+ flow.Magnitude(r,c)*(k-150)/20;
                  elseif k>=0 && k<=10
                            bin(1)=bin(1)+ flow.Magnitude(r,c)*(k+10)/20;
                            bin(9)=bin(9)+ flow.Magnitude(r,c)*(10-k)/20;
                  elseif k>170 && k<=180
                            bin(9)=bin(9)+ flow.Magnitude(r,c)*(190-k)/20;
                            bin(1)=bin(1)+ flow.Magnitude(r,c)*(k-170)/20;
                  end
         end
        end
        
        %bin_sum = bin_sum + normalize(bin,'norm',1);
        bin_sum = bin_sum + bin;
    end
    
end
