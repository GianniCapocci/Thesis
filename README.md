## Clone the project

    git clone https://github.com/GianniCapocci/Thesis.git

## Create config.json for dockerhub

First we need to login into dockerhub:

    docker login

We will be prompted to input our username and password. Afterwards the config.json file will be created under ~/.docker/config.json by default. We need to copy that file into the ansible/files folder.

## Install Ansible and Vagrant

We need to install Ansible and Vagrant following the below instructions:

**ANSIBLE:**

    sudo apt update
    sudo apt install software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt install ansible

The above is for Debian based systems.
Otherwise follow the instructions described in the following link: https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html

**VAGRANT:**

First follow the instructions in the following link to install Vagrant:
https://developer.hashicorp.com/vagrant/install

Afterwards execute to following commands to install the *vagrant-hostmanager* plugin:

    vagrant plugin install vagrant-hostmanager
    vagrant plugin list
    vagrant plugin update

## How to customize the project

Under the folder *ansible/group_vars* there are files that define variables used to setup different things for the project. Below follows an explaination for each variable:

In ansible/group_vars/all.yaml:
 - **ansible_python_interpreter** defines the python interpreter to be used
 - **appdir** defines the app directory of the cloned application
 - **branch** defines the branch that should be cloned
 - **appuser** defines the username of the user account Ansible is connected as on the remote machine
 - **appgroup** defines the group ID of the user account Ansible is connected as on the remote machine
 - **app_port** defines the port the cloned app should expose itself
 - **app.env.*** define the values to be replaced in the application.properties file of the app
 - **mysql_password** defines the password for the MySQL database
 - **mysql_root_password** defines the root password for the MySQL database
 - **spring_email** defines the email address for the email account that the app uses to send notifications.
 - **spring_mail_password** defines the email paasword for the email account that the app uses when a notification needs to be sent (follow the steps in this link to create this password: https://support.google.com/accounts/answer/185833)
 - **spring_datasource_password** defines the password for the datasource the app is using
 - **k8s_kubeconfig** defines the path of the kubeconfig file in the Control VM

In ansible/group_vars/control.yaml:
 - **grafana_email_address** defines the email address for the email account that Grafana uses when an alert is triggered
 - **grafana_email_password** defines the email password for the email account that Grafana uses when an alert is triggered (follow the steps in this link to create this password: https://support.google.com/accounts/answer/185833)
 - **grafana_admin_user** defines the admin username for Grafana
 - **grafana_admin_password** defines the admin password for Grafana
 - **minio_root_user** defines the root username for MinIO
 - **minio_root_password** defines the root password for MinIO (the password needs to be at least 8 characters long)
 - **loki_access_key_id** defines the access key for Loki in order to connect to MinIO
 - **loki_secret_access_key** defines the secret access key for Loki in order to connect to MinIO

In ansible/group_vars/native.yaml:

 - **service.workingdir** defines the working directory of the cloned app
 - **service.execstart** defines the command that executes the cloned app
 - **db.name** defines the name of the database
 - **db.user** defines the username for the MySQL user that will be created
 - **db.password** defines the password for the MySQL user that will be created

## How to run the project

First we need to be in the directory ~/vagrant. Then we can run the following command to create and start the VMs:

    vagrant up

   At any point we can check the status of the VMs with the command:

    vagrant status

To stop the VMs we use the command:

    vagrant halt

To destroy/delete the VMs we use the command:

    vagrant destroy -f

To restart the VMs we use the command:

    vagrant reload

On all the above commands we can add to the end the name of a specific VM if we want the command to be executed only for that VM.

After we have created the VMs and they are up and running we need to change directory to ~/ansible.

Then we can execute the following command in order to install Ansible on the control VM:

    ansible-playbook playbooks/ansible-install.yaml

Now that we have installed Ansible on the control VM we can connect into it using ssh with the command:

    vagrant ssh

From inside the control VM we can connect to any other of the VMs with the command:

    ssh <vm-name>

Now to deploy the project from the control VM we need to change directory into /home/vagrant/ansible and then execute the following command:

    ansible-playbook playbooks/everything.yaml

Also from our host machine we need to execute the following commands:

    echo  "192.168.56.113 spring.local"  |  sudo  tee  -a  /etc/hosts
    echo  "192.168.56.10 minio.local"  |  sudo  tee  -a  /etc/hosts
    echo  "192.168.56.10 grafana.local"  |  sudo  tee  -a  /etc/hosts
    echo  "192.168.56.10 prometheus.local"  |  sudo  tee  -a  /etc/hosts
    echo  "192.168.56.10 uptrace.local"  |  sudo  tee  -a  /etc/hosts

With this command we will be able to access:

 - The app running in our Kubernetes enviroment through spring.local
 - The MinIO UI through minio.local
 - The Grafana UI through grafana.local
 - The Prometheus UI through prometheus.local
 - The Uptrace UI through uptrace.local

We can also access:

 - The app running in our native enviroment through 192.168.56.112
 - The app running in our Docker enviroment through 192.168.56.111

## Accessing Kubernetes Clusters

The Control VM and the App03 VM are both running a kubernetes cluster. We can access them both from only the Control VM with the following commands:

    kubectl config use-context <context>

Where *context* can either be "control" or "app03" for the respective VM. Also instead of kubectl we can use the alias "k" as it is set up during the creation of the Control VM.

<!-- copy config.json from dockerhub to ansible/files

spring-secret.yaml from ansible vault contains:
    spring_mail_password:

mysql-secret.yaml from ansible vault contains:
    mysql_password:
    mysql_root_password:

grafana-secret.yaml from ansible vault contains:
    email_password:

To run playbook app-with-k8s.yaml:
    ansible-playbook app-with-k8s.yaml --ask-vault-pass or
    ansible-playbook app-with-k8s.yaml --vault-password-file absolute/path/to/vault-pass.txt -->
