**** Sparse Logistic Regression ToolBox ver.0.311

This toolbox provides one of solutions for the classification problem.
The unique feature may be the classifier is learned in a sparse way, resulting in
automatic feature selection while learning parameters in the classifier.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1. History
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
2007-01-29 ver.0.311  minor updated. 
2006-11-16 ver.0.31  minor updated. 
2006-10-24 ver.0.30  new version updated. 
2006-09-08 ver.0.20  new version updated. 
		     multinomial logistic regression, save log, run_* function  
2005-12-12 ver.0.11  minor bug fix (incompatibility of matrix size) 
2005-12-07 ver.0.1

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
2. Release Note
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
2.1 New Feature in ver.0.311
 @ 'nohessian' option is added to slr_learning_var.m and run_smlr_bi_var.m
 @ The document in this "README.txt" is modified a lot.

2.2 Old Feature before ver.0.31
ver.0.31
 @ implement run function for nonlinear (kernel) classification.
ver.0.30 
 @ New algorithm (slr_learning_var.m) for learning parameters is implemented. This new version is much faster than previous
  version's algorithm (slr_learning.m). See the attached slides for detailed imformation about performance, computation time, and sparsity.
 @ Comments in function are largely modified.
 @ Several deemos which show how this tool-box works are introduced. 
 @ Error table is introduced as output of classification.
ver.0.20 
 @ Support true multinomial classification using multinomial distribution (sparse multinomial logistic regression)
 @ run_* functions, which is a high level function to implement common classification procedure including normalization, are added.
 @ Log information can be save.
 @ File format is not still compatible with Alex's format.    
 ver.0.11
 @ Sparse estimation based on Automatic Relevance Determination (ARD) prior and logistic regression model
 @ Binary classification (so far)
 @ Relevance Vector Machine (RVM) using Gaussian kernel is supported. 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
3. Contents (Functions)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
3.1 Demos

demo_* : These files show how the functions in this toolbox works using simulation data. 

- demo_slr_lintest.m    : Demo of sparse logistic regression (SLR) with the linear discriminant function. 
This demo shows how the binary classification problem can be solved using simulation data generated from 2 component-Gaussian mixture model. 
Firstly traing data and test data are generated from 2 component-Gaussian mixture model in 'D' dimension feature space. 
Then the parameters that determines linear boundary are learned with two different routines.
One is "run_smlr_bi" which uses the variational Bayesian method and Laplace approximation and the other is 
"run_smlr_bi_var" which uses the varitional Bayesian method and the varitional parameter approximation. 
Usually the latter algorithm is much fast and the result may not differ so much. 
Finally the test data is used to evaluate learned classifier and plot the boundary and test data on the feature space 
projected on the first two dimensions.

By modifying the data generation part, this script can be used for usual classification problem.

- demo_slr_linCV.m : Demo of sparse logistic regression and cross validations (CV).
This demo shows how the SLR based feature selection procedure works.
Motivated by the conjecture that features commonly selected by many varietey of training data set could be more 
reliable features, we rank each feature by the frequency of each feature selected in many cross validation.   

Firstly a training data set is divided into two data set, CV training data and CV test data. 
A lot of CV training and CV test data sets are generated by choosing CV training data randomly.
Then the classifier is learned using each CV traing data set and each features are counted if the resulting parameter is non-zero.
This is repeated for each CV data set and the resulting histogram can be used as the score of each feature that ranks the importance. 

- demo_smlr.m    : Demo of sparse mutinomial logistic regression (SMLR).
This demo shows how the multi-class classification problem can be solved. 

- demo_nonlin.m : Demo of sparse logistic regression with the Gaussian kernel classifier.
This demo shows how the Gaussian kernel classifier works for binary classification using simulation data.
First training and test data are generated such that the data is separated by sin function-like boundary in 2 dimensional feature space.
Then the kernel width 'R' that is most important parameter in the Gaussian kernel classifier is optimized by cross-validation and 
searching the discritized grid points 'RR'. 
Finally  the test data is used to evaluate learned classifier and plot the resulting boundary and test data.

This non-linear classifier takes computation time that depends on the number of samples not the number of features,
because it uses the kernel trick (well-known in support vector machine). Therefore this is applicable even if the 
number of features is several thousands and more. But it is observed that the test performance significantly decreases, 
if there are many umimportant features. I highly recommend this routine would be applied after selecting the important features.    

3.2 Run function

run_* : These are high level interface functions wrapping multi-labels classification using linear discriminant functions.

3.3 Low level function

slr_* : Tool functions which are used in the above scripts. See documents in each function (although not yet completed).

slr_learning      :
slr_learning_var  :

3.4 Simulation data
gen_gm_data : generate simulated data from two-class Gaussian mixtures.

3.5 Functions from other toolbox or Matlab file exchange
finputcheck : error check function of struct fields. This fucntion is taken from eeglab4.511b
xyrefline   : convinient plot function to draw the line paralell to x or y axis.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
4. Typical Analysis Procedure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Example 1. Linear discriminant function with sparse estimation ....
  
Just run "demo_slr_lintest" after setting training feature vectors and labels;  
test feature vectors and labels; in the several lines at top of the code.

Example 2. Feature extraction using Cross Validation (CV) ....
  Just run "demo_slr_linCV.m" after seting setting training feature vectors and labels;   
test feature vectors and label as well as the number of CV in the several lines at top of the code.

"CVRes" struct contains "ix_eff_all":selected features' index, "errTablete":result of test classification, "errTabletr":result of training classification,
and "g": options used in "run_smlr_bi_var". You may include other variables which you think important as variables of "CVRes" struct.


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
5. Bug Fix and Questions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This toolbox can not be distributed without any permission of Okito Yamashita. 
Please keep contact with me (oyamashi@atr.jp) if you change and redistribute the function in this toolbox.
Any feedback and bug report about this toolbox is welcome and I would like to respond as fast as possible.

Updated on 2007/01/29 written by Okito Yamashita






