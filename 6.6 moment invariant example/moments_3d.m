function [ J, I ] = moments_3d( V, CoM )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

dims = size(V);

if nargin==1
    x_mu = m(1, 0, 0)/m(0, 0, 0);
    y_mu = m(0, 1, 0)/m(0, 0, 0);
    z_mu = m(0, 0, 1)/m(0, 0, 0);
else
    x_mu = CoM(1);
    y_mu = CoM(2);
    z_mu = CoM(3);
end

%2nd order moment invariant
J1 = mu(2, 0, 0) + mu(0, 2, 0) + mu(0, 0, 2);
J2 = mu(2, 0, 0)*mu(0, 2, 0) + mu(2, 0, 0)*mu(0, 0, 2)  + mu(0, 2, 0)*mu(0, 0, 2) - mu(1, 0, 1)^2 - mu(1, 1, 0)^2 - mu(0, 1, 1)^2;
J3 = mu(2, 0, 0)*mu(0, 2, 0)*mu(0, 0, 2) - mu(0, 0, 2)*mu(1, 1, 0)^2 + 2*mu(1, 1, 0)*mu(1, 0, 1)*mu(0, 1, 1)...
    - mu(0, 2, 0)*mu(1, 0, 1)^2 - mu(2, 0, 0)*mu(0, 1, 1)^2;

J = [J1, J2, J3];

%3rd order moment invariant
%complex moments
v33 = sqrt(pi()/35)*(-mu(3,0,0)+3*mu(1,2,0)+1i*(mu(0,3,0)-3*mu(2,1,0)));
v23 = sqrt(6*pi()/35)*(mu(2,0,1)-mu(0,2,1)+1i*2*mu(1,1,1));
v13 = sqrt(3*pi())/(5*sqrt(7))*(mu(3,0,0)+mu(1,2,0)-4*mu(1,0,2)+...
    1i*(mu(0,3,0)+mu(2,1,0)-4*mu(0,1,2)));
v03 = 2/5*sqrt(pi()/7)*(2*mu(0,0,3)-3*mu(2,0,1)-3*mu(0,2,1));
v_13 = 1/5*sqrt(3*pi()/7)*(-mu(3,0,0)-mu(1,2,0)+4*mu(1,0,2)+1i*(mu(0,3,0)+mu(2,1,0)-4*mu(0,1,2)));
v_23 = sqrt(6*pi()/35)*(mu(2,0,1)-mu(0,2,1)-1i*2*mu(1,1,1));
v_33 = sqrt(pi()/35)*(mu(3,0,0)-3*mu(1,2,0)+1i*(mu(0,3,0)-3*mu(2,1,0)));
v11 = sqrt(6*pi())/5*(-mu(3,0,0)-mu(1,2,0)-mu(1,0,2)-1i*(mu(0,3,0)+mu(2,1,0)+mu(0,1,2)));
v01 = 2/5*sqrt(3*pi())*(mu(0,0,3)+mu(2,0,1)+mu(0,2,1));
v_11 = sqrt(6*pi())/5*(mu(3,0,0)+mu(1,2,0)+mu(1,0,2)-1i*(mu(0,3,0)+mu(2,1,0)+mu(0,1,2)));

I1 = 1/sqrt(7)*(2*v33*v_33-2*v23*v_23+2*v13*v_13-v03^2);
I2 = 1/sqrt(3)*(2*v11*v_11-v01^2);

I = [I1 I2];


    function [m_pqr] = m(p, q, r)

        x = 1:dims(1);
        y = 1:dims(2);
        z = 1:dims(3);
        [xx, yy, zz] = meshgrid(x, y, z);
        m_pqr = sum(xx.^p.*yy.^q.*zz.^r.*V, 'all');
        % m_pqr = 0;
        % for x = 1:dims(1)
        %     for y = 1:dims(2)
        %         for z = 1:dims(3)
        %             m_pqr = m_pqr + x^p*y^q*z^r*V(x, y, z);
        %         end
        %     end
        % end
    end

    function [mu_pqr] = mu(p, q, r)

        x = 1:dims(1);
        y = 1:dims(2);
        z = 1:dims(3);
        [xx, yy, zz] = meshgrid(x, y, z);

        mu_pqr = sum((xx - x_mu).^p.*(yy - y_mu).^q.*(zz - z_mu).^r.*V, 'all');
        %mu_pqr = 0;
        % for x = 1:dims(1)
        %     for y = 1:dims(2)
        %         for z = 1:dims(3)
        %             mu_pqr = mu_pqr + (x-x_mu)^p*(y-y_mu)^q*(z-z_mu)^r*V(x, y, z);
        %         end
        %     end
        % end
        mu_pqr = mu_pqr/sum(V(:))^((p+q+r+3)/3);
    end

end

