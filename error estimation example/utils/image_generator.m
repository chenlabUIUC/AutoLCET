function out=image_generator(M,RES,sim_scale,beta)
M=M./sim_scale;%nm->px
%%
RY = [cosd(beta) 0  sind(beta);
     0 1 0;
     -sind(beta) 0  cosd(beta)];
for k = 1:size(M,3)
    M(:,:,k)=(M(:,:,k)'*RY)';
    M(1:2,:,k)=M(1:2,:,k)+RES/2;
end
package=cat(2,RES, reshape(M,size(M(:)')));  %px
canvas=ray_tracing_mex(package);      %px
out=canvas*sim_scale;  %nm
%imshow(out-min(out(:)))/(max(out(:))))
end
