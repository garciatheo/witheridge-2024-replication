// =====================================================================
//  Witheridge (2024) - Monetary Policy and Fiscal-led Inflation in EM
//  Replication: Theo Garcia & Ana Victoria Pelliccione
//
//  FIGURE 6 - Fiscal-led regime: IRFs to a monetary policy shock.
//  Log-linearised NK small open economy (Appendix C2).
// =====================================================================

var y piH pi de r tau d m t bg nxt s pt;
varexo em;

parameters sigma_w kappa beta omega phi_pi gamma_d gamma_y rho_m sigma_m;

sigma_w = 1;
kappa   = 0.23;
beta    = 0.99;
omega   = 0.3;
phi_pi  = 0.3;        // fiscal-led: accommodative central-bank response to inflation
gamma_d = 0.5;        // fiscal-led: weak fiscal response to debt
gamma_y = 0;
rho_m   = 0.5;
sigma_m = 0.01;

// Net-exports parameters (slightly different from the original table to
// avoid the nxt equation collapsing numerically).
parameters sigma eta;
sigma = 0.85;
eta   = 0.9;

model(linear);

// IS curve
y = y(+1) - (1/sigma_w)*(r - piH(+1));

// NK Phillips curve
piH = kappa*y + beta*piH(+1);

// CPI inflation
pi = (1 - omega)*piH + omega*de;

// Exchange-rate dynamics
de = sigma_w*(y - y(-1)) + piH;

// Monetary policy rule
r = phi_pi*pi + m;

// Fiscal rule
tau = gamma_d*d(-1) + gamma_y*y;

// Government debt accumulation
d = (1/beta)*(y(-1) - y + d(-1) + r(-1) - pi - (1 - beta)*tau);

// AR(1) monetary policy shock
m = rho_m*m(-1) + sigma_m*em;

// Price gap (foreign - domestic)
s = pt - piH;

// Price level
pt = pi + pt(-1);

// Taxes (definition)
t = tau + pt + y;

// Government debt (definition)
bg = d + r + pt + y;

// Net exports
nxt = omega * ( ((sigma*eta + (1 - omega)*(sigma*eta - 1))/sigma) - 1 ) * s;

end;

initval;
y = 0; piH = 0; pi = 0; de = 0; r = 0; tau = 0; d = 0; m = 0;
t = 0; bg = 0; nxt = 0; s = 0; pt = 0;
end;

// NOTE on stderr: in a linear model the shock std is a pure vertical-scale
// factor - it changes the axis only, never signs/shapes/timing. The value
// below is arbitrary, chosen so the IRFs line up with the scale of the
// paper's Figure 6. It carries no economic content.
shocks;
var em; stderr 100;
end;

steady;
check;
stoch_simul(order=1, irf=20) r pi de y d tau;
