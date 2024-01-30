# Create a service principal (App Registration) in Tenant

1. In the Azure Portal go to Entra ID -> App Registrations -> + add registration
![App Registrations](/imagery/entraid-appregs.png)

2. Enter the name of the service principal ('devops-sc') -> click on register
![Register](/imagery/appname-registter.png)

3. On the resulting screen take note of the App ID and Tenant ID

4. create a Secret for the newly created App Registration by clicking on Certificats and Secrets -> + new client secret
![Create Secret](/imagery/certandsecret-newclientsecret.png)

Make note of the secret too.