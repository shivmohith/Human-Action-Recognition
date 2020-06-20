function h_sum = cslbp(cuboid)
    h_sum = zeros(1,16);
    for t=1:5
        h=zeros(1,16);
        [y,x]=size(cuboid(:,:,t));
        T = 0.1; 
        for i=2:y-1
            for j=2:x-1
                a = ((cuboid(i,j+1,t) - cuboid(i, j-1,t) > T ) * 2^0 );        
                b = ((cuboid(i+1,j+1,t) - cuboid(i-1, j-1,t) > T ) * 2^1 );
                c = ((cuboid(i+1,j,t) - cuboid(i-1, j,t) > T ) * 2^2 );
                d = ((cuboid(i+1,j-1,t) - cuboid(i - 1, j + 1,t) > T ) * 2^3 );
                e=a+b+c+d;
                h(e+1) = h(e+1) + 1;
            end
        end
     h_sum = h+h_sum;
    end
end