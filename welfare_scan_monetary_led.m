%% === Configuration ===
clear; clc;

base_mod    = 'welfare_base_monetary_led.mod';   % base Dynare model
phi_pi_vals = 1.1:0.5:5;
outdir      = 'results_phi_scan_monetary_led';
if ~exist(outdir,'dir'), mkdir(outdir); end

% Containers to keep everything
All = struct();
All.phi_pi_vals = phi_pi_vals(:);
All.runs = cell(numel(phi_pi_vals),1);    % each cell will hold oo_, M_, options_
All.grid = table(phi_pi_vals(:), NaN(numel(phi_pi_vals),1), NaN(numel(phi_pi_vals),1), ...
                 'VariableNames', {'phi_pi','welfare_u','welfare_a'});

%% === Loop: generate .mod, run Dynare, store results ===
for i = 1:numel(phi_pi_vals)
    phi = phi_pi_vals(i);

    % 1) write a temporary .mod with phi_pi replaced
    tmpname = sprintf('tw_phi_%02d', round(10*phi));   % e.g. tw_phi_11, tw_phi_16, ...
    mod_tmp = fullfile(outdir, [tmpname '.mod']);
    txt = fileread(base_mod);
    % replace the phi_pi assignment line (adjust regex if the line has a trailing comment)
    txt = regexprep(txt, 'phi_pi\s*=\s*[\d\.]+;', sprintf('phi_pi = %.6f;', phi));
    fid = fopen(mod_tmp,'w'); fwrite(fid, txt); fclose(fid);

    % 2) run Dynare on that file (inside outdir)
    curr = pwd; cd(outdir);
    dynare([tmpname '.mod'], 'noclearall','nograph');
    cd(curr);
    % after this, oo_, M_, options_ are in the workspace

    % 3) store this run in All (no dependence on files)
    S = struct();
    S.oo_ = oo_;
    S.M_ = M_;
    S.options_ = options_;
    All.runs{i} = S;

    % 4) compute welfare for this run and store it in the grid
    T = S.options_.irf;

    piH_u  = S.oo_.irfs.piH_eps_u(1:T);  piH_u  = piH_u(:);     % column
    ygap_u = S.oo_.irfs.ygap_eps_u(1:T); ygap_u = ygap_u(:);    % column
    piH_a  = S.oo_.irfs.piH_eps_a(1:T);  piH_a  = piH_a(:);
    ygap_a = S.oo_.irfs.ygap_eps_a(1:T); ygap_a = ygap_a(:);

    beta_dyn  = get_param_by_name('beta');
    discount  = (beta_dyn.^(0:T-1))';    % column T x 1
    v_dyn     = evalin('base','v');
    omega_dyn = evalin('base','omega');

    All.grid.welfare_u(i) = - (1 - omega_dyn)/2 * sum( discount .* (piH_u.^2 + v_dyn * ygap_u.^2) );
    All.grid.welfare_a(i) = - (1 - omega_dyn)/2 * sum( discount .* (piH_a.^2 + v_dyn * ygap_a.^2) );

end

%% === Save everything in a single file ===
save(fullfile(outdir,'ALL_phi_scan.mat'), 'All');

%% === Plots in separate figures ===
% --- Figure 1: Markup shock ---
fig1 = figure('Name','Welfare - Markup shock','Color','w');
plot(All.grid.phi_pi, All.grid.welfare_u, '-o', ...
     'DisplayName','Markup shock','LineWidth',1.2,'MarkerSize',5);
xlabel('\phi_\pi'); ylabel('Welfare Loss');
title('Welfare - Markup shock (monetary-led)');
grid on; legend('Location','best');
saveas(fig1, fullfile(outdir,'welfare_markup.png'));

% --- Figure 2: Productivity shock ---
fig2 = figure('Name','Welfare - Productivity shock','Color','w');
plot(All.grid.phi_pi, All.grid.welfare_a, '-s', ...
     'DisplayName','Productivity shock','LineWidth',1.2,'MarkerSize',5);
xlabel('\phi_\pi'); ylabel('Welfare Loss');
title('Welfare - Productivity shock (monetary-led)');
grid on; legend('Location','best');
saveas(fig2, fullfile(outdir,'welfare_productivity.png'));
