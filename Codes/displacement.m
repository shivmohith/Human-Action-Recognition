function xy_points_displacement = displacement(xy_points)
    xy_points_displacement = xy_points(:,:,2) - xy_points(:,:,1);
    j = 2;
    for i = 3:15
        xy_points_displacement(:,:,j) = xy_points(:,:,i) - xy_points(:,:,i-1);
        j = j + 1;
    end
end
