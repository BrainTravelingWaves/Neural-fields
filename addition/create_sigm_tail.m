clear; clc
% construction of travelling waves, Heaviside
%
% -cU'=-U+ int w(x-y) H(U-th)dy -v
% -cV=eps*U  (- beta*V ==0 here)
% Then:
% U(x)=(1/2*c) int_x^{\infty} Pexp(lambda_1(x-y)+exp(lambda_2(x-y)))inv(P)*(W(y)-W(y-a))dy
% e.g. W(y)=erf(y)
% lambda_1=(1+sqrt(1-4*eps))/(2*c);
% lambda_2=(1-sqrt(1-4*eps))/(2*c);



%%%%          Model parameters block

eps = 0.2;    %  negative feedback
th = 0.5;     %  neuronal activation threshold
b1 = 2;       %  neuronal connection strenghts 

err=5e-3;     %  truncation error/tolerance



a_init=0.5;     % initial guess for the wave super-threshold width
c_init=-0.2;    % initial guess for the wave speed (<0)


contraction=0.85;  % contraction of the pulse (to the left-hand dide), < 1 (1 means no contraction)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


th0= th/b1; err0=err/b1;

[a0,c0,t,T,exitflag] = FindingParameters_erf(eps,th0,err0,a_init,c_init);

b2=1/(T-t);
a=a0*b2; c = c0*b2;

%%
clambda_1 =(1-sqrt(1-4*eps))/(2);
clambda_2 =(1+sqrt(1-4*eps))/(2);

p11= (-1+sqrt(1-4*eps))/(2*eps); 
p21= (-1-sqrt(1-4*eps))/(2*eps);

A1=p11/(p11-p21);
A2=p21/(p11-p21);

expA10=@(t,c) A1*exp(clambda_1*t/c)-A2*exp(clambda_2*t/c);

funU10=@(x,a,c) - 1/c * integral(@(y) expA10(x-y,c).*(erf(y)-erf(y-a)),-Inf,x); % x, Inf

%%
N=500;
x=linspace(0,1,N);
if exitflag==1
     y=x/b2;
     for i=1:length(x)
         U(i)=b1*funU10(y(i)+t,a0,c0);
     end
     figure(100)
     grid on
     hold on
     
      hoh= plot(x,U);
     plot(x,x*0+th,'--')
     plot([0-t*b2 a-t*b2], [th th],'o')
     legend(hoh,['c=',num2str(c')],'Location','northeast')
     xlabel('x-ct')
     ylabel('U(x-ct)')
     title(['Travelling pulse for h=', num2str(th),'(dashed), \epsilon=', num2str(eps),' and b_1=',num2str(b1)])
 else
     disp('*********************')
     disp('No solution found!')
     disp('Suggestion: Decrease either the threshold or epsilon')
end
 
% Save output

%  save('profile.mat','x','U')

%  New profile function w2



 x_contr=x*contraction;
    x_contr(length(x_contr)+1) = 1;
    U_contr=U;
    U_contr(length(U_contr)+1) = U(1);
    WP=@(r)interp1(x_contr,U_contr,r);
    
   



 figure(101)
     grid on
     hold on
     hoh= plot(x_contr,WP(x_contr));
     plot(x,x*0+th,'--')
    % plot([0-t*b2 a-t*b2], [th th],'o')
     legend(hoh,['c=',num2str(c')],'Location','northeast')
     xlabel('x-ct')
     ylabel('U(x-ct)')
     title(['Contracted travelling pulse for h=', num2str(th),'(dashed), \epsilon=', num2str(eps),' and b_1=',num2str(b1), ' and  contraction=',num2str(contraction)  ])

%%%%%%%    Check interpolated profile plot
% figure(2)
% y=linspace(0,1,700);
% plot(y,WP(y));

%%
%%Tables%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc

disp('-----------------------------------------------------------------------------------')
disp('                            Your Input:')
disp('-----------------------------------------------------------------------------------')
fprintf('      eps       h     trunc.error   b1\n')
format short
disp([eps,th,err,b1])


fprintf('\n')
disp('                                Output:')
disp('-----------------------------------------------------------------------------------')
fprintf('      T-t       b2         a         c        x0        x0+a     U(0)     U(1)\n')
format short
disp([T-t,b2,a,c,-t*b2,-t*b2+a,U(1),U(end)])
disp('-----------------------------------------------------------------------------------')