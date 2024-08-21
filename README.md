# Goals
Goals is a simple web application which helps people achieve their goals.



# How to build
## How to build the web site
1. Install the latest LTS version of node.js (https://nodejs.org/)
2. Open a terminal window
3. Go to the root of Goal's GIT repository
4. Type the following commands in PowerShell:

```
cd .\Website
npm install
npm run build
```


# How to debug
## How to debug the web site

TODO - Need to write instructions



# How to deploy the service's infrastructure

**WARNING** These instructions only work for the official development and production Azure subscriptions.  The Bicep files will have to be updated to work with other Azure subscriptions.

1. Open a PowerShell window
2. Go to the root of the Goals GIT repository
3. Type the following commands:

```
# Connect to the Azure subscription which you are deploying to.
Connect-AzAccount

cd ./Deployment

# If you are deploying to the Development environment, type the following command:
$environmentName = 'Development'

# If you are deploying to the Production environment, type the following command:
$environmentName = 'Production'

./DeployInfrastructure.ps1 -Environment $environmentName
```



# Required tools
1. Visual Studio (https://visualstudio.microsoft.com/)
2. Visual Studio Code (https://visualstudio.microsoft.com/)
3. Git (https://git-scm.com/)
4. PowerShell (https://github.com/PowerShell/PowerShell/releases)
5. Azure PowerShell Module (https://www.powershellgallery.com/packages/Az/)

# Recommended tools
1. Araxis Merge Pro (https://www.araxis.com/merge/index.en)