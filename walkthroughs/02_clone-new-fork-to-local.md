## Clone newly forked repo locally

* go to your organization and the newly forked repo on github.com. Something like https://github.com/*your org*/Databricks360

![New cloned Repo](/imagery/new-cloned-repo.png)

* click on *Code* and copy the ssh uri (when you're working like me on WSL 2.0 (Windows Subsystem for Linux ) ubuntu). In order for the cloning to work with ssh, you'd have to have a ssh key generated an installed in github to authenticate your client as described [here.](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

![Code-Ssh Uri](/imagery/new-repo-clone-code.png)

* go to your local workstation and open a bash command prompt to your WSL subsystem

![Local Bash](/imagery/local-wsl-bash.png)

In my case this is Ubuntu 24.04 LTS and any Ubuntu from 20.x on will do.

* change into a directory into which you want to clone all repos (in my case this is /repos)
* from here issue git clone *uri from previous step* and then change into this new directory

![New Cloned Repo](/imagery/cloned-new-repo.png)

from here you could enter *code .* to start VSCode automatically opening the new repo.
