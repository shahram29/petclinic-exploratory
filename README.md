# Exploratory Testing
<H1>README</H1>
<H1>Repo Name: exploratory-testing</H1>
<P>Purpose: To demonstrate how to use a Jenkinsfile and terraform to automatically launch an EC2 instance with a configured AMI. The test deploys a simple web server and prompts a tester to determine if the exploratory testing failed or was successful. After collecting the tester's results, Jenkins finishes the job, automatically destroys the VM and records the testers' results.
</P>

<H1>Before running this repo on your own repository:</H1>

<UL>
<LI>Update the jenkinsfile to specify your own GitHub Repo URL and name (1 location)
<LI>Replace the default VPC ID vpc-442aaf21 in the infrastructure/variables.tf file with the default VPC ID of your own AWS Account (1 location)
<LI>Install Terraform in your Jenkins server
<LI>Replace the "DevOps" key in the Infrastructure/ec2_test.tf file with an existing key pair in your AWS account. For example, the Jenkins key pair. 
</UL>
  
<H1>Additional Configuration:</H1>

<UL>
<LI> (Optional) Add your Jenkins IP webhook to each repo

<H1>version 1.0.0 </H1>
