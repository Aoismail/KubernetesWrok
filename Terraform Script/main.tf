provider "alicloud" {
  region = var.region_id
  access_key = "LTAI5tR4fHh9mAV6vt4ngb4a"
  secret_key = "DYGRdTrqJRQlCF142EX4wTtpSP80DC"
}


terraform {
  backend "oss" {
    encrypt        = true
  }
  required_version = ">= 1.3.0"
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = ">= 1.200.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.4"
    }
  }
}


# Specify the add-ons that you want to install in the ACK managed cluster. The add-ons include Terway (network add-on), csi-plugin (volume add-on), csi-provisioner (volume add-on), logtail-ds (logging add-on), Nginx Ingress controller, ack-arms-prometheus (monitoring add-on), and ack-node-problem-detector (node diagnostics add-on). 
variable "cluster_addons" {
  type = list(object({
    name   = string
    config = string
  }))
  default = [
    {
      "name"   = "terway-eniip",
      "config" = "",
    },
    {
      "name"   = "logtail-ds",
      "config" = "{\"IngressDashboardEnabled\":\"true\"}",
    },
    {
      "name"   = "nginx-ingress-controller",
      "config" = "{\"IngressSlbNetworkType\":\"internet\"}",
    },
    {
      "name"   = "arms-prometheus",
      "config" = "",
    },
    {
      "name"   = "ack-node-problem-detector",
      "config" = "{\"sls_project_name\":\"\"}",
    },
    {
      "name"   = "csi-plugin",
      "config" = "",
    },
    {
      "name"   = "csi-provisioner",
      "config" = "",
    }
  ]
}


# The default resource names. 
locals {
  k8s_name_terway         = substr(join("-", ["var.k8s_name_prefix", "terway"]), 0, 63)
  k8s_name_flannel        = substr(join("-", [var.k8s_name_prefix, "flannel"]), 0, 63)
  k8s_name_ask            = substr(join("-", [var.k8s_name_prefix, "ask"]), 0, 63)
  new_vpc_name            = "rtf-vpc"
  new_vsw_name_azA        = "rtf-vpc-a"
  new_vsw_name_azB        = "rtf-vpc-b"
  #nodepool_name           = "RTF-nodepool"
  #managed_nodepool_name   = "managed-RTF-node-pool"
  #autoscale_nodepool_name = "autoscale-RTF-node-pool"
  log_project_name        = "log-for-RTF-ACK-${var.env}"
}

# The ECS instance specifications of worker nodes. Terraform searches for ECS instance types that fulfill the CPU and memory requests. 
#data "alicloud_instance_types" "default" {
 # cpu_core_count       = 4
  #memory_size          = 8
 # availability_zone    = var.availability_zone[0]
 # kubernetes_node_role = "Worker"
#}




 #The node vSwitches. 
resource "alicloud_vswitch" "vswitches" {
  count      = length(var.vswitch_ids) > 0 ?  0 : length(var.vswitch_cidrs)
  vpc_id     = var.vpc_id
  cidr_block = element(var.vswitch_cidrs, count.index)
  zone_id    = element(var.availability_zone, count.index)
}

# The pod vSwitches. 
resource "alicloud_vswitch" "terway_vswitches" {
  count      = length(var.terway_vswitch_ids) > 0 ?  0 : length(var.terway_vswitch_cidrs)
  vpc_id     = var.vpc_id
  cidr_block = element(var.terway_vswitch_cidrs, count.index)
  zone_id    = element(var.availability_zone, count.index)
}




