# KEDA AKS demo

## Requirements 

- [direnv](https://direnv.net/)
- [Docker](https://www.docker.com/) 
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) 

Copy `envrc.example` to `.envrc`

```sh
cp .envrc.example .envrc
```

Then set required env variables inside `.envrc`
- `TENANT_ID` Azure tenant id 
- `SUBSCRIPTION_ID` Azure subscription id  
- `SSH_KEY` Your ssh key - by default it will look at your home directory for `.ssh` 

Then run 
```sh
direnv allow 
```

Everything is inside docker, so simply running following command

```sh
docker compose run devenv
```

will get you inside docker container with everything set up and ready. Data from container will be preserve in `.cache` directory, so for example, you only need to authenticate once against Azure, and this will be preserved even if you delete docker container.

## Azure athentication

**Inside docker container** we need to authenticate against Azure when we are running for the first time. 
Run following command and follow instructions there to authenticate

```sh
az login
```

Switch to correct subscription 

```sh 
az account set --subscription $TF_VAR_subscription_id
```

Test if subscription is correct by running 
```sh
az account show -o table 
```

## Terraform 

Once authenticated you can run terraform, first make sure to initialise

```sh 
terraform init
```

Then run `terraform plan` command to review plan, it should show that it will create 8 new resources 
- Azure Resource Group 
- Azure Container Registry 
- Kubernetes Cluster (AKS)
- Azure Storage Account 
- Azure Storage Queue
- Helm and KEDA
- `yaml` manifest file - `ScaledObject` for KEDA
- `yaml` manifest file - `Deployment` that we will use to test KEDA

`yaml` manifests will be stored in `src/kubernetes`.

After review we can apply 
```sh 
terraform apply
```

To see results after applying you can use `az resources list --resource-group devops-finland-demo -o table`


## Settings kubectl

Using kubectl command we can see also pods currently that are running in our cluster, but first we need to fetch credentials
```sh
az aks get-credentials -n devops-finland-demo --resource-group devops-finland-demo
```

Then simple running following command will show you all running pods
```sh
kubectl get pods
```

Once we validated we can communicate with kubernetes cluster we should deploy our consumer that should be scalable by KEDA. 
First, we need to make sure that our kubernetes cluster can pull images from our ACR, and because of my limited permissions I had to do that by creating `Secret` object that will be used to pull images from my ACR.

To do that use this command

```sh 
kubectl create secret docker-registry acr-secret \
    --namespace default \
    --docker-server=dfdacr.azurecr.io \
    --docker-username=dfdacr \
    --docker-password=`read -s pass; echo $pass`
```

That will wait for you to enter access key (which is masked like password, and you can find it in azure in ACR), and once you enter it it will create `Secret` by name `acr-secret` in kubernetes (`kubectl get secret` to test)

Now that we have this in order we can push images in next section.

## KEDA consumer docker image

**On your host machine (not in docker container)** build images for consumer and producer

```sh 
cd ./src/app

export REPO="dfdacr.azurecr.io"
```

Login to acr locally
```sh
# same as docker login
az acr login --name $REPO
```

Publish images 
```sh
docker build --target consumer -t "${REPO}/consumer" .
docker build --target producer -t "${REPO}/producer" .

docker push "${REPO}/consumer"
docker push "${REPO}/producer"
```

You can check published images via

```sh
az acr repository list --name $REPO -o table
```

## Deploying consumer and scaledobject

Once we have consumer in our ACR, we can apply manifest file that was built by `terraform` to run it in our kubernetes cluster and we can also apply manifest for KEDA that will scale our consumer.

Both of this files are located in `src/kubernetes`.
So back **in our docker container** we can run 

```sh
cd /app/kubernetes

kubectl apply -f 01-keda-consumer.yaml
# kubectl get pods - will show that we have 1 pod with consumer


kubectl apply -f 02-scaled_object.yaml
# kubectl get pods - will show that we have 0 pods with consumer
```

## Test producing 

Now that we have keda that is set up we can produce some messages and watch how keda will scale our consumer.
To do that **on our host machine**, copy secrets from `./src/kubernetes/01-keda-consumer.yaml` for azure queue storage 
- `AZURE_STORAGE_CONNECTION_STRING`
- `AZURE_STORAGE_QUEUE_NAME`

To your `.envrc` and run 

```sh
direnv allow
```

Simply running
```sh
docker compose run producer
```

will generate 99 random messages that we need to process and this will trigger KEDA to autoscalle our consumer up to 100 replicas.


## Optional: Building app localy


Test app is located in `./src/app` directory, it's NodeJS app and to use same version as one used for development of it run `nvm use` (obviously you need `nvm` tool before). 
Install all dependencies 

```sh
npm i
```

Run producer 
```sh
npm run dev:produce
```

You can run it N times if you want to see what happens if we have thousands of messages, and you should be able to see `keda-consumer` pod scaling up and down.

Run consumer
```sh
npm run dev:consume
```
