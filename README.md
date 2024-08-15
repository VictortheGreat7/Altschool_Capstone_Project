# Deploy a Microservices Application on Azure Kubernetes Service using GitHub Actions

In this project, you will deploy a microservices application on an Azure Kubernetes Cluster. You will use GitHub Actions to automate provisioning an Azure Cloud infrastructure (mainly Azure Kubernetes Service) with Terraform and configure it to host the application using Ansible (which will use kubectl to deploy the provided manifests).

In this repository, you have the Terraform, Bash and Ansible scripts you will need to bring the application to life and set up basic alerting, monitoring and logging.

## Pre-requisites

- An Azure Account (preferably with an Entra ID User Account with a Subscription Owner and Entra ID Global Administrator roles assigned to it)
- A Domain Provider (e.g. Name.com, Namecheap, etc)
- A GitHub Account
- An Ubuntu Machine (optional, as long as a bash terminal is available. Sudo privileges are also important)
- Git installed
- Azure CLI installed
- kubectl CLI installed
- kubelogin CLI installed
- jq (a commandline JSON processor) installed
- Ansible and Ansible Vault installed

## Instructions

1. **Fork the Repository**:
    If you don't want to modify too many scripts, you should leave the repository name as is.

2. **Clone the forked repository to your Ubuntu machine**

3. **Login to Azure CLI as your Azure Entra ID User**:
    Log in to Azure CLI in your Ubuntu/Bash terminal. Make sure it is a user that has all the roles and specifications listed in the pre-requisites.

4. **Run the `service_principal.sh` bash script**
    Change your working directory to the root of the cloned repository, make sure the script is executable (you can run `chmod +x service_principal.sh` to make it executable), and run it (`./service_principal.sh` is the command to run). This will create a service principal user for GitHub Actions to use during its workflow and save the needed details in the `secrets.yaml` file that we will decrypt later. It also saves the current Azure user's details, that will be used to give your own machine access to the cluster when GitHub Actions is done with the deploy job, to the `terraaform.tfvars` file.

5. **Assign the Group Administrator role to the newly created Service Principal**:
    Go to your Azure Account on the Azure Portal and type in the search bar "Entra Roles". If you see Microsoft Entra Roles and Administrators, click on it. That is where you assign the Service Principal the "Group Administrator" role. Terraform will need the Service Principal user, that GitHub Actions job runner is logged in as, to have that role to be able to create a group as specified in the `permissions.tf` file. Check out `role_assignment.md` in the `screenshots` folder for visual instructions on how to create the role.

6. **Create secrets for GitHub Actions**:
    The `secrets.yaml` file is meant for the Ansible script that GitHub Actions will run but it has some details that the workflow scripts will need to have successful workflow runs. You will need to create some secrets in the GitHub settings of your forked repository. Check out `secrets.md` in the `screenshots` folder for visual examples of how to do so.

7. **Encrypt the secrets.yaml file with Ansible Vault**:
    The details in secrets.yaml are sensitive, so you'll need to encrypt them before pushing it to the GitHub repository. Run `ansible-vault encrypt secrets.yaml` to encrypt the file. You will be prompted to enter a new password in the terminal. You will add that password to GitHub Actions secrets like you did for other details in the previous step. Also like with the previous step, `secrets.md` will show you how. `ansible-vault decrypt secrets.yaml` command decrypts the file, in case you were not done with Step 5.

8. **Run the `authorized_ips.sh` script**:
    Change your working directory to the `capstone_terraform` directory, make sure the file is executable and run it like so: `./authorized_ips.sh`. This script ensures that access to the cluster and its services except the frontend is restricted (including viewing them in the browser with their assigned subdomain names) to only your current IP address. It does that by editing the `ingress.yaml` manifest file in the `microservices_manifest` directory and the `terraform.tfvar` file in the `capstone_terraform` directory. You only need to run it once. If you run it more times than that you'll have to manually reduce the IP addresses it added to those files mentioned to just have the latest one.

9. **Edit Ingress Manifest to use your Domain Name**:
    In the `ingress.yaml` file in the `microservices_manifest` directory, edit every instance of `<subdomain>.mywonder.works` to use your own domain. For instance, if you see `kibana.mywonder.works` edit it to `kibana.<your-domain-name>`. If you don't edit in a domain name in that manifest file and configure DNS settings as specified in step 11, you will not be able to see your application in the browser except you use the `kubectl port-forward` command. If you try the external ip that the Azure Loadbalancer, configured by the `ingress.yaml` manifest, will give you in the browser, you will only get an error page.

10. **Push to your GitHub Repository**:
    After following the previous steps correctly, uncomment the part of the `build.yaml` script that triggers GitHub Actions to run the script on git push, comment out the manual trigger part and push the repository to your GitHub Repository. GitHub Actions, following the instructions specified by the build script, will automatically build and deploy the application.

11. **Configure Domain Name DNS Settings**:
    In your domain provider's website, there should be a way to configure DNS settings for your domain. After GitHub Actions has run the deploy job successfully, you will need to connect to the cluster on your local Ubuntu machine. Go to the Azure Portal and look for a cluster named `capstone_cluster` in a resource group called `altschool-capstone-rg`, in the Overview dashboard of that cluster look for a "Connect" option and use the `az aks get-credentials` and `kubelogin` commands listed there in that order on your local machine. If the first service_principal.sh script you ran earlier worked fine, you should be able to get access to the cluster. After you have successfully gotten access to the cluster you can run `kubectl get ingress` and get the LoadBalancer External IP you need. If the command runs successfully, copy the IP address you see under EXTERNAL IP and use it to configure A records for each subdomain. `subdomain.md` has screenshots of how I set A records for each subdomain specified in the `ingress.yaml` manifest.

12. **View you Application from any Browser on any Device**:
    The certificate issuer in the cluster usually needs a while to do its work. If you type in the urls you have set in the `ingress.yaml` manifest in the browser, you may get an error that the connection is not secure. Usually after waiting like ten minutes, the certificates would have been issued and the urls will work fine. Note: Only the application's frontend is available on any device. The urls for the User Interfaces of the alerting, monitoring and logging tools, just like access to the cluster's API Server, will only be accessible to the IP address you specified in Step 4.

13. **Test Prometheus Alerts**:
    To test Prometheus alerts, with `microservices_manifests` as your working directory, run `kubectl apply -f loadtest-dep.yaml`. Check to see if the pods in the `load-test` namespace are running with `kubectl get pods -n load-test`. After a while, if you go to the alerts section in the Prometheus UI, there is a rule already set that the deployed load test pods will have triggered after running for some minutes. Just keep refreshing the Alerts section of the Prometheus UI. The alert form being inactive will move to pending and then will start firing. Check out online on how to send those alerts to an App like Slack. Since you have Cluster API Server access, you can test other alerts and how to get them as messages on Slack.

14. **Test Grafana Dashboards**:
    Use the Grafana url in the browser. You can login using `admin` as the value for username and password. You will be given an option you can skip to create a new one. Once logged in, navigate to Data Sources in the Setting bar on the left pane and click on add data source. Choose Prometheus as the source and put in `http://prometheus.monitoring.svc.cluster.local:9090` in the space for url. In the Dashboard section, click on Import for all the dashboards you see. Then Click on save and test in the previous section where you put in the prometheus svc url. Go to the Folder's section in the Search icon on the left pane. You will see the dashboards you imported earlier. Click on them to view them.

15. **Destroy the Infrastructure**:
     When you are done testing you can destroy the infrastructure by manually running the destroy workflow in the GitHub Actions section of your GitHub repository. When you click run workflow for the destroy workflow script, Github Actions will destroy the cloud infrastructure built earlier.