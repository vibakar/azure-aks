resource "azurerm_resource_group" "rg" {
  name     = var.resource_group.name
  location = var.resource_group.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "cluster-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "cluster-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "k8s-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "vaultcluster"
  kubernetes_version  = "1.22.11"

  default_node_pool {
    name                   = "system"
    vnet_subnet_id         = azurerm_subnet.subnet.id
    os_sku                 = "Ubuntu"
    os_disk_type           = "Managed"
    os_disk_size_gb        = 30
    type                   = "VirtualMachineScaleSets"
    vm_size                = "Standard_B2s"
    enable_auto_scaling    = true
    max_count              = 3
    min_count              = 1
    node_count             = null
    max_pods               = 100
    orchestrator_version   = "1.22.11"
    enable_host_encryption = false
    zones                  = ["1", "2", "3"]

    node_labels = {
      size = "small",
      type = "system"
    }

    tags = {
      name = "system_nodes"
    }
  }

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  network_profile {
    network_plugin     = "kubenet"
    dns_service_ip     = "10.2.0.8"
    docker_bridge_cidr = "172.10.0.0/16"
    pod_cidr           = "10.1.0.0/16"
    service_cidr       = "10.2.0.0/16"
    outbound_type      = "loadBalancer"
    load_balancer_sku  = "standard"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    cluster = "dev"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "np" {
  name                   = "app"
  kubernetes_cluster_id  = azurerm_kubernetes_cluster.cluster.id
  vnet_subnet_id         = azurerm_subnet.subnet.id
  os_sku                 = "Ubuntu"
  os_disk_type           = "Managed"
  os_disk_size_gb        = 30
  vm_size                = "Standard_B2s"
  enable_auto_scaling    = true
  max_count              = 3
  min_count              = 1
  node_count             = null
  max_pods               = 100
  orchestrator_version   = "1.22.11"
  enable_host_encryption = false
  zones                  = ["1", "2", "3"]

  node_labels = {
    size = "small",
    type = "apps"
  }

  tags = {
    name = "app_nodes"
  }
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.cluster.kube_config_raw
  sensitive = true
}