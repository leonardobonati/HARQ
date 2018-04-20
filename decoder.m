function [ decoding_failures, successfully_decoded, decoded_file ] = ...
    decoder( file_to_decode, original_file )
%  Decodes received file
%   file_to_decode must be double
%   decoded_file is double
%   successful_decoding: 1 if success, 0 otherwise
%   original_file is the matrix associated with the original file
%     before encoding
%
%  Authors:
%  - Leonardo Bonati
%  - Fabio Brea
%
%  Date: Feb. 2016
%

matrix=file_to_decode;

m=8;
n=254;
k=32;

pkt_no=size(matrix,1);

decoding_failures=pkt_no;

% replace -1 with 0 in the matrix
for i=1:pkt_no
    for j=1:n
        if matrix(i,j)==-1
            matrix(i,j)=0;
        end
    end
end

% convert matrix from double to gf
matrix_gf=gf(matrix,m);

tic;

% decode
decoded_file_gf=gf(zeros(pkt_no,k),m);
for i=1:pkt_no
    decoded_pkt=rsdec(matrix_gf(i,:),n,k);
    decoded_file_gf(i,:)=decoded_pkt;
    
    display(i);
end

decoded_file=gf2double(decoded_file_gf);

% check if decoding succeeded
% load('original_file_k32.mat');

successfully_decoded=zeros(pkt_no,1);
for i=1:size(decoded_file,1)
    if isequal(original_file(i,:), decoded_file(i,:))
        successfully_decoded(i,1)=1;
        decoding_failures=decoding_failures-1;
    end
end

time=toc;

display(time);

end