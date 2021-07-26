The goal of this project is simply to create an easy setup GitLab instance that one could simply drop in a lab and run with. I am sure there are better ways to do this but this is my way and it works for those just getting started.

**Installation:**

1. To install you first install docker on your host. Instructions on how to do that can be found on the docker website here:
   https://docs.docker.com/get-docker/

2. Next install docker compose on the system following the instructions here:
   https://docs.docker.com/compose/install/
   
3. Now simply clone the repo to your local system with this command:
   `git clone https://github.com/mon0pixel/docker-gitlab`
   
4. Apply the execute permission to the .sh file.

   `chmod +x ./install.sh`

5. And spin up the services with the installer script:
   `./install.sh`
   
   For HTTPS use the --ssl switch.
   `./install --ssl`

**Setting the root password:**

I hope to improve this in the future but for now to set the root password you need to perform the following steps.

1. Launch the ruby console on the host:
   `docker exec -it gitlab /opt/gitlab/bin/gitlab-rails console`

2. Load the user profile for root into a variable:
   `user = User.find(1)`

3. Set the password with the following two commands:

   ``user.password = '<YOUR PASSWORD>'
   user.password_comfirmation = '<YOUR PASSWORD>'``

4. Save the changes with the final command:
   `user.save!`
5. You should now be able to log in with the username of root and your password.

