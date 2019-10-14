**Task:**

    Provision a web server that prints a simple html index page that displays 
    the EC2 instance ID of the web server that is responding to the request.


**Requirements:**

    Must run on AWS.
    Share on a VCS of your choice. (e.g GitHub, BitBucket)
    Must be able to run your script in my own AWS account.
    Must be able to create with a one line command and delete with a one line command.
    
    
**Dependecies:**

    Ansible 0.12
    
**Setup**
    
    This code assumes that a key-pair for access to your AWS account has been installed at the default path:
    ~/.aws/aws_terraform.pub
    
    Once cloned from GitHub, run 'terraform apply' from the 'staging' subdirectory. Then browse to the output ELB hostname. Sometimes it is necessary to run apply twice if Nginx has yet to create the target filepath /var/www/index.html in the web servers.