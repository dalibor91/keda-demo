
resource "helm_release" "keda" {
  name       = "keda"
  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  namespace  = "default"

  devel = "true"

  set {
    name  = "logLevel"
    value = "debug"
  }
}

resource "azurerm_storage_account" "storage" {
  name                     = "devopsfinlandstorage"
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  allow_nested_items_to_be_public  = false

  network_rules {
    default_action = "Allow"
  }
}

resource "azurerm_storage_queue" "queue" {
  name                 = "devops-finland-queue"
  storage_account_name = azurerm_storage_account.storage.name
}

resource "local_file" "test_keda_app" {
  content  = <<-EOT
apiVersion: apps/v1
kind: Deployment
metadata:
  name: keda-consumer
spec:
  selector:
    matchLabels:
      app: keda-consumer
  replicas: 1
  template:
    metadata:
      labels:
        app: keda-consumer
    spec:
      imagePullSecrets:
        - name: acr-secret
      containers:
      - name: keda-consumer
        image: dfdacr.azurecr.io/consumer:latest
        imagePullPolicy: Always
        livenessProbe:
          exec:
            command:
            - sh
            - -c
            - test -f /app/dist/consumer/index.js
        ports:
        - containerPort: 80
        env:
          - name: AZURE_STORAGE_CONNECTION_STRING
            value: "${azurerm_storage_account.storage.primary_connection_string}"
          - name: AZURE_STORAGE_ACCOUNT_NAME
            value: "${azurerm_storage_account.storage.name}"
          - name: AZURE_STORAGE_QUEUE_NAME
            value: "${azurerm_storage_queue.queue.name}"
  EOT
  filename = "${var.target}/01-keda-consumer.yaml"
}

resource "local_file" "scaled_object" {
  content = <<-EOT
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: azure-queue-scaledobject
  namespace: default
spec:
  scaleTargetRef:
    name: keda-consumer
  pollingInterval: 10
  cooldownPeriod:  30
  minReplicaCount: 0
  maxReplicaCount: 100
  triggers:
  - type: azure-queue
    metadata:
      queueName: "${azurerm_storage_queue.queue.name}"
      accountName: "${azurerm_storage_account.storage.name}"
      connectionFromEnv: "AZURE_STORAGE_CONNECTION_STRING"
      queueLength: "5"
      cloud: Private
      endpointSuffix: queue.local.azurestack.external
EOT
  filename = "${var.target}/02-scaled_object.yaml"
}