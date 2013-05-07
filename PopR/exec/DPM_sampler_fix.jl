function  DPM_sampler_fix(inp::Array{Any,1})

num_iters = inp[1]
thin = inp[2]
Stats = inp[3]
priors = inp[4]
consts = inp[5]
    
    require("Julia_code_support.jl")
    require("gibbs_crp_fix.jl")
    require("split-merge_fix.jl")

     alpha = 0.1

    # initialize structures

    nit=int(num_iters/thin)
    k_0s=Array(Float,nit)
    K_plus = consts.sources
    counts = zeros(Int,consts.N,1)
    allcounts = zeros(Int,consts.N,1)
    class_id = Array(Int,consts.N)
    class_ids = Array(Int,(consts.N,nit))
    K_record = Array(Int,nit)
   
    alpha_record = Array(Float,nit)
    p_under_prior_alone = Array(Float,consts.N);

    consts,Stats,allcounts = preallocate(consts,Stats,priors,allcounts)   
    Stats,allcounts,counts = preclass(consts,Stats,priors,allcounts,counts,class_id)
    tic()
    totaltime=0
    
    ## start MCMC ---- 
   for iter=1:num_iters
        
        # calculate P for each individual under prior alone
        p_under_prior_alone = p_for_1(consts,priors,consts.N,consts.datas,p_under_prior_alone)
 # run gibbs bit      
      
        (class_id,K_plus,Stats,counts,allcounts) = crp_gibbs(class_id,consts,priors,Stats,allcounts,counts,K_plus,alpha,p_under_prior_alone)

       
        # run split-merge bit
        
        #if iter>10
            (class_id,K_plus,Stats,counts,allcounts) = split_merge(class_id,consts,priors,Stats,counts,allcounts,K_plus,alpha,p_under_prior_alone)
        # end
         
       
        # assert(all(round((Stats.means)*counts/90,4) .==round( mean(datas,2),4)))

        # update alpha

        alpha = update_alpha(alpha,N,sum(counts.!=0),priors.a_0,priors.b_0)

        # update prior
        
        (priors.k_0,priors.mu_0) = update_prior(consts,K_plus,Stats,counts,priors)
        
        # save parameter values
        
        if mod(iter,thin)==0
            K_record[iter/thin] = sum(counts.!=0)
            alpha_record[iter/thin] = alpha
            k_0s[iter/thin]=priors.k_0
            class_ids[:,int(iter/thin)]=class_id
            
        end
  
        # timer

        time_1_iter = toq();
        totaltime = disptime(totaltime,time_1_iter,iter,thin,num_iters,K_record)
        tic()
        
    end


    return(class_ids,k_0s,K_record,alpha_record)

end