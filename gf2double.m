function [ output_file_double ] = gf2double( input_file_gf )
% Converts object of type Galois Field into double
%
%  Authors:
%  - Leonardo Bonati
%  - Fabio Brea
%
%  Date: Feb. 2016
%

column_no=size(input_file_gf,1);
row_no=size(input_file_gf,2);

output_file_double=-1*ones(column_no,row_no);

for c=1:column_no
    for r=1:row_no
        e=input_file_gf(c,r);
        output_file_double(c,r)=double(e.x);
    end
end

end