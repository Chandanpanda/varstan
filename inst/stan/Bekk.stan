functions{
  //     returns the y power of an x vector
  row_vector vecpow(real y,row_vector x, int d){
   row_vector[d] y1;
   for(i in 1:d) y1[i] = pow(x[i],y);
   return y1;
 }
 //     returns a vector with the vech transform
 row_vector vech(int d,int m,matrix y){
  row_vector[m] yk;
  int pos = 1;
  for(j in 1:d){
    for(i in j:d){
      yk[pos] = y[i,j];
      pos =pos +1;
    }
  }
  return yk;
 }
real Jpv(real v){
    real y;
    y =trigamma(v/2) -trigamma((v+1)/2) - 2*(v+3)/(v*(v+1)*(v+1));
    y = (v/(v+3))*y;
    return sqrt(y);
  }
}
data {
  int<lower=0> n;         // number of data items
  int<lower=1> d;         // number of dimensions
  int<lower=0> p;         // number of predictors var
  int<lower=0> q;         // number of predictors var
  int<lower=1> m;         // number of dimensions vech
  int<lower=0> s;         // number of predictors  arch
  int<lower=0> k;         // number of predictions garch
  int<lower=0> h;         // number of predictions mgarch
  // prior data
  matrix[n,d] y;          // outcome matrix time series
  vector[4] prior_mu0;    // prior location parameter
  vector[4] prior_sigma0; // prior scale parameter
  vector[4] prior_lkj;    // prior scale parameter
  matrix[p,4] prior_ar;   // ar location hyper parameters
  matrix[q,4] prior_ma;   // ma location hyper parameters
  matrix[s,4] prior_arch;    // prior arch hyper parameters
  matrix[k,4] prior_garch;   // prior ma hyper parameters
  matrix[h,4] prior_mgarch;  // prior ma hyper parameters
}
parameters{
  //      Parameter VAR Bekk Model
  row_vector[d]mu0;                 // Var constant
  matrix <lower=-1,upper=1>[d,d] phi[p];   // *temp coefficients VAR
  matrix <lower=-1,upper=1>[d,d] theta[q]; // *temp coefficients VMA
  cholesky_factor_corr[d] Msigma0;  // *arch constant correlation
  vector<lower=0>[d] vsigma0;       // *arch constant scale
  matrix[d,d] alpha[s];             // arch coefficients
  matrix[d,d] beta[k];              // garch coefficients
  matrix[m,d] mgarch;               // MGARCH coefficients
}
transformed parameters {
  //***********************************************
  //             Model Parameters
  //***********************************************
  // Temporal mean and residuals
  matrix[n,d] mu;                   // *VAR mean
  matrix[n,d] epsilon;              // *residual mean
  matrix[d,d] sigma0;               // arch constant
  cov_matrix[d] sigma1;             // arch constant
  matrix[d,d] sigma[n];             // *covariance matrix sigma
  matrix[d,d] Lsigma[n];            // *Cholesky descomposition sigma


  //***********************************************
  //      Sigma0 transformation
  //***********************************************

  sigma0 = diag_pre_multiply(vsigma0,Msigma0);
  sigma1= multiply_lower_tri_self_transpose(sigma0);

  //***********************************************
  //         VARMA estimations
  //***********************************************

  for(i in 1:n){
    //  VAR Iteration
    mu[i] = mu0;
    sigma[i] = sigma1;
    Lsigma[i] = sigma1;

    if(p > 0) for(j in 1:p) if(i > j) mu[i] += y[i-j]*phi[j];
    // ma estimation
    if(q > 0) for(j in 1:q) if(i > j) mu[i] += epsilon[i-j]*theta[j];
    epsilon[i] = y[i] - mu[i];
    //      Bekk Iteration
    if(s >= k){
       // arch estimation
      if(s > 0) for(j in 1:s)if(i > s) sigma[i] += quad_form(epsilon[i-j]'*epsilon[i-j],alpha[j]);
       // garch estimation
      if(k > 0) for(j in 1:k)if(i > k) sigma[i] += quad_form(sigma[i-j],beta[j]);

      Lsigma[i] = cholesky_decompose(sigma[i]);
      // mgarch estimation
      if(h > 0)  mu[i] += vech(d,m,sigma[i])*mgarch;
    }
  }
}
model{
  //      Priors  definition

  //  prior for \mu0
  if(prior_mu0[4] == 1)    target += normal_lpdf(mu0|prior_mu0[1],prior_mu0[2]);
  else if(prior_mu0[4]==2) target += beta_lpdf(mu0|prior_mu0[1],prior_mu0[2]);
  else if(prior_mu0[4]==3) target += uniform_lpdf(mu0|prior_mu0[1],prior_mu0[2]);
  else if(prior_mu0[4]==4) target += student_t_lpdf(mu0|prior_mu0[3],prior_mu0[1],prior_mu0[2]);
  else if(prior_mu0[4]==5) target += cauchy_lpdf(mu0|prior_mu0[1],prior_mu0[2]);
  else if(prior_mu0[4]==6) target += inv_gamma_lpdf(mu0|prior_mu0[1],prior_mu0[2]);
  else if(prior_mu0[4]==7) target += inv_chi_square_lpdf(mu0|prior_mu0[3]);
  else if(prior_mu0[4]==8) target += -log(sigma0);
  else if(prior_mu0[4]==9) target += gamma_lpdf(mu0|prior_mu0[1],prior_mu0[2]);
  else if(prior_mu0[4]==10)target += exponential_lpdf(mu0|prior_mu0[2]);
  else if(prior_mu0[4]==11)target += chi_square_lpdf(mu0|prior_mu0[3]);
  else if(prior_mu0[4]==12)target += double_exponential_lpdf(mu0|prior_mu0[1],prior_mu0[2]);

  // Prior sigma
  if(prior_sigma0[4] == 1)    target += normal_lpdf(vsigma0|prior_sigma0[1],prior_sigma0[2]);
  else if(prior_sigma0[4]==2) target += beta_lpdf(vsigma0|prior_sigma0[1],prior_sigma0[2]);
  else if(prior_sigma0[4]==3) target += uniform_lpdf(vsigma0|prior_sigma0[1],prior_sigma0[2]);
  else if(prior_sigma0[4]==4) target += student_t_lpdf(vsigma0|prior_sigma0[3],prior_sigma0[1],prior_sigma0[2]);
  else if(prior_sigma0[4]==5) target += cauchy_lpdf(vsigma0|prior_sigma0[1],prior_sigma0[2]);
  else if(prior_sigma0[4]==6) target += inv_gamma_lpdf(vsigma0|prior_sigma0[1],prior_sigma0[2]);
  else if(prior_sigma0[4]==7) target += inv_chi_square_lpdf(vsigma0|prior_sigma0[3]);
  else if(prior_sigma0[4]==9) target += gamma_lpdf(vsigma0|prior_sigma0[1],prior_sigma0[2]);
  else if(prior_sigma0[4]==10)target += exponential_lpdf(vsigma0|prior_sigma0[2]);
  else if(prior_sigma0[4]==11)target += chi_square_lpdf(vsigma0|prior_sigma0[3]);
  else if(prior_sigma0[4]==12)target += double_exponential_lpdf(vsigma0|prior_sigma0[1],prior_sigma0[2]);

  //   sigma0 constant correlation Matrix
  target += lkj_corr_cholesky_lpdf(Msigma0|prior_lkj[1]);

  // prior ar
  if(p > 0){
    for(i in 1:p){
     if(prior_ar[i,4]==1) target += normal_lpdf(to_vector(phi[i])|prior_ar[i,1],prior_ar[i,2]);
     else  target += normal_lpdf(to_vector(phi[i])|0,1);
    }
  }
  // prior ma
  if(q > 0){
    for(i in 1:q){
     if(prior_ma[i,4]==1) target += normal_lpdf(to_vector(theta[i])|prior_ma[i,1],prior_ma[i,2]);
     else  target += normal_lpdf(to_vector(theta[i])|0,1);
    }
  }
  // prior arch
  if(s > 0){
    for(i in 1:s){
     if(prior_arch[i,4]==1) target += normal_lpdf(to_vector(alpha[i])|prior_arch[i,1],prior_arch[i,2]);
     else target += beta_lpdf(to_vector(alpha[i])|prior_arch[i,1],prior_arch[i,2]);
    }
  }
  // prior garch
  if(k > 0){
    for(i in 1:k){
     if(prior_garch[i,4]==1) target += normal_lpdf(to_vector(beta[i])|prior_garch[i,1],prior_garch[i,2]);
     else target += beta_lpdf(to_vector(beta[i])|prior_garch[i,1],prior_garch[i,2]);
    }
  }
   // prior mean_garch
  if(h > 0){
    for(i in 1:h){
      if(prior_mgarch[i,4]== 1)     target += normal_lpdf(mgarch[i]|prior_mgarch[i,1],prior_mgarch[i,2]);
      else if(prior_mgarch[i,4]==2) target += beta_lpdf(mgarch[i]|prior_mgarch[i,1],prior_mgarch[i,2]);
      else if(prior_mgarch[i,4]==3) target += uniform_lpdf(mgarch[i]|prior_mgarch[i,1],prior_mgarch[i,2]);
      else if(prior_mgarch[i,4]==4) target += student_t_lpdf(mgarch[i]|prior_mgarch[i,3],prior_mgarch[i,1],prior_mgarch[i,2]);
      else if(prior_mgarch[i,4]==5) target += cauchy_lpdf(mgarch[i]|prior_mgarch[i,1],prior_mgarch[i,2]);
      else if(prior_mgarch[i,4]==6) target += inv_gamma_lpdf(mgarch[i]|prior_mgarch[i,1],prior_mgarch[i,2]);
      else if(prior_mgarch[i,4]==7) target += inv_chi_square_lpdf(mgarch[i]|prior_mgarch[i,3]);
      else if(prior_mgarch[i,4]==9) target += gamma_lpdf(mgarch[i]|prior_mgarch[i,1],prior_mgarch[i,2]);
      else if(prior_mgarch[i,4]==10)target += exponential_lpdf(mgarch[i]|prior_mgarch[i,2]);
      else if(prior_mgarch[i,4]==11)target += chi_square_lpdf(mgarch[i]|prior_mgarch[i,3]);
      else if(prior_mgarch[i,4]==12)target += double_exponential_lpdf(mgarch[i]|prior_mgarch[i,1],prior_mgarch[i,2]);
    }
  }
  //      Likelihood
  for(i in 1:n)target += multi_normal_cholesky_lpdf(epsilon[i]| rep_vector(0,d), Lsigma[i]);
}
generated quantities{
  real loglik = 0;
  vector[n] log_lik;
  matrix[n,d] fit;
  matrix[n,d] residuals;

  for(i in 1:n){
    residuals[i] = multi_normal_cholesky_rng(epsilon[i],Lsigma[i])';
    fit[i] = y[i]-residuals[i];
    log_lik[i] = multi_normal_cholesky_lpdf(y[i]|mu[i],Lsigma[i]);
    loglik += log_lik[i];
  }
}
