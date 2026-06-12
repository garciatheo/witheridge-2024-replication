// =====================================================================
//  Witheridge (2024) - Section 6 - Fiscal-led regime
//  Replication: Theo Garcia & Ana Victoria Pelliccione
//
//  Welfare base model (fiscal-led). Used by welfare_scan_fiscal_led.m
//  to produce Figure 9(a). Run standalone it also yields the markup and
//  productivity IRFs behind Figure 8.
// =====================================================================

var y yn ygap piH pi r a u d tau;
varexo eps_a eps_u;

parameters beta sigma_w kappa phi_pi phi_y rho_a rho_u sigma_a sigma_u;
parameters alpha nu theta epsilon omega v gamma_d gamma_y Psi_a;

// -----------------------------
// Calibration (Appendix F)
beta    = 0.99;
sigma_w = 1;
alpha   = 0.25;
nu      = 1;
theta   = 0.75;
epsilon = 6;
omega   = 0.3;
phi_pi  = 0.1;
phi_y   = 0;

kappa   = 0.08;
rho_a   = 0.66;
rho_u   = 0.66;

// Structural shock size: innovation normalised to 1 p.p. (sigma*stderr = 1).
// The level is held fixed across the whole phi_pi scan, which is exactly what
// makes the welfare values comparable. Welfare here is NOT impact-normalised,
// because the point of the exercise is precisely how piH and ygap respond
// differently to phi_pi.
sigma_a = 1;
sigma_u = 1;

// Fiscal rule parameters
gamma_d = 0.5;    // fiscal-led regime: weak response to debt
gamma_y = 0.0;

// Welfare weight (v from equation 34)
v = ((1 - theta)*(1 - beta*theta)/theta) * ((1 + nu)/(1 - alpha + alpha*epsilon)) * (1/epsilon);

// Psi_a (from F14, responsiveness of y^n to a_t)
Psi_a = -sigma_w*(1-rho_a)*(1 + nu)/(sigma_w*(1 - alpha) + nu + alpha);

// -----------------------------
// Model
model(linear);

// Natural output (y^n_t)
yn = (1 + nu)/(sigma_w*(1 - alpha) + nu + alpha) * a;

// Output gap
ygap = y - yn;

// IS curve (eq. 35)
ygap = ygap(+1) - (1/sigma_w)*(r - piH(+1) - Psi_a*a);

// NK Phillips Curve (eq. 36)
piH = kappa*ygap + beta*piH(+1) + u;

// CPI inflation (closed-economy approximation, pi = piH)
pi = piH;

// Monetary policy rule (reacts to inflation and output gap)
r = phi_pi*pi + phi_y*ygap;

// Fiscal rule: taxes respond to debt and output
tau = gamma_d*d(-1) + gamma_y*y;

// Government debt (eq. F14)
d = (1/beta)*( d(-1) - pi + ygap(-1) - ygap + r(-1) - (1 - beta)*tau - ((1 + nu)/(sigma_w*(1 - alpha) + nu + alpha))*(a - a(-1)) );

// Shock processes
a = rho_a*a(-1) + sigma_a*eps_a;
u = rho_u*u(-1) + sigma_u*eps_u;

end;

initval;
y = 0; yn = 0; ygap = 0; piH = 0; pi = 0; r = 0; a = 0; u = 0; d = 0; tau = 0;
end;

shocks;
var eps_a; stderr 1;
var eps_u; stderr 1;
end;

stoch_simul(order=1, irf=20) u a r ygap pi piH;
