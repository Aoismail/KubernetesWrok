# The ACK managed cluster. 
resource "alicloud_cs_managed_kubernetes" "default" {
  name                         = "RTF-ACK-${var.env}"                                           # The ACK cluster name. 
  cluster_spec                 = var.cluster_spec                                              # Create an ACK Pro cluster. 
  resource_group_id = var.resource_group_id
  vswitch_ids           = var.vswitch_ids        # The vSwitch to which the node pool belongs. Specify one or more vSwitch IDs. The vSwitches must reside in the zone specified by availability_zone. 
  pod_vswitch_ids              = split(",", join(",", alicloud_vswitch.terway_vswitches.*.id)) # The vSwitch of the pod. 
  new_nat_gateway              = true                                                          # Specify whether to create a NAT gateway when the Kubernetes cluster is created. Default value: true. 
  service_cidr                 = var.service_cidr                                                # The pod CIDR block. If you set the cluster_network_type parameter to flannel, this parameter is required. The pod CIDR block cannot be the same as the VPC CIDR block or the CIDR blocks of other Kubernetes clusters in the VPC. You cannot change the pod CIDR block after the cluster is created. Maximum number of hosts in the cluster: 256. 
  slb_internet_enabled         = false                                                          # Specify whether to create an Internet-facing SLB instance for the API server of the cluster. Default value: false. Valid values: 
  enable_rrsa                  = true
  version                      = var.kubernetes_version
  security_group_id = alicloud_security_group.ack_security_group.id
  control_plane_log_components = ["apiserver", "kcm", "scheduler", "ccm"] # The control plane logs. 
  dynamic "addons" {                                                      # Component management. 
    for_each = var.cluster_addons
    content {
      name   = lookup(addons.value, "name", var.cluster_addons)
      config = lookup(addons.value, "config", var.cluster_addons)
    }
  }
}



resource "alicloud_security_group" "ack_security_group" {
  security_group_name        = "ack-cluster-sg-${var.env}"
  description = "Security group for ACK managed cluster"
  vpc_id      = var.vpc_id # Replace with your VPC ID
}


# SSH Access - Restricted to Specific IP (Best Practice)
resource "alicloud_security_group_rule" "ack_ssh_ingress" {
  security_group_id = alicloud_security_group.ack_security_group.id
  type              = "ingress"
  ip_protocol          = "tcp"
  port_range        = "22/22"
  cidr_ip           = "192.168.0.0/16"  # Replace with your trusted IP
  description       = "Allow SSH access from trusted IP"
}

# Kubelet Access - Recommended to restrict to internal IPs
resource "alicloud_security_group_rule" "ack_kubelet_ingress" {
  security_group_id = alicloud_security_group.ack_security_group.id
  type              = "ingress"
  ip_protocol          = "tcp"
  port_range        = "10250/10250"
  cidr_ip           = "192.168.0.0/16"  # Restrict to VPC CIDR
  description       = "Allow Kubelet access"
}

# Kubernetes API Server Access
resource "alicloud_security_group_rule" "ack_api_server_ingress" {
  security_group_id = alicloud_security_group.ack_security_group.id
  type              = "ingress"
  ip_protocol          = "tcp"
  port_range        = "6443/6443"
  cidr_ip           = "192.168.0.0/16"  # Restrict to trusted IP or VPN
  description       = "Allow Kubernetes API server access"
}

# HTTP Access
resource "alicloud_security_group_rule" "ack_http_ingress" {
  security_group_id = alicloud_security_group.ack_security_group.id
  type              = "ingress"
  ip_protocol          = "tcp"
  port_range        = "80/80"
  cidr_ip           = "0.0.0.0/0"
  description       = "Allow HTTP access"
}

# HTTPS Access
resource "alicloud_security_group_rule" "ack_https_ingress" {
  security_group_id = alicloud_security_group.ack_security_group.id
  type              = "ingress"
  ip_protocol          = "tcp"
  port_range        = "443/443"
  cidr_ip           = "0.0.0.0/0"
  description       = "Allow HTTPS access"
}

# NodePort Services (30000-32767) - Kubernetes Service Access
resource "alicloud_security_group_rule" "ack_nodeport_ingress" {
  security_group_id = alicloud_security_group.ack_security_group.id
  type              = "ingress"
  ip_protocol          = "tcp"
  port_range        = "30000/32767"
  cidr_ip           = "0.0.0.0/0"
  description       = "Allow NodePort service traffic"
}

#CoreDNS (UDP/53) - Required for DNS Resolution
resource "alicloud_security_group_rule" "ack_coredns_ingress" {
  security_group_id = alicloud_security_group.ack_security_group.id
  type              = "ingress"
  ip_protocol          = "udp"
  port_range        = "53/53"
  cidr_ip           = "192.168.0.0/16"
  description       = "Allow CoreDNS for internal DNS resolution"
}


#ICMP (Ping) for Troubleshooting
resource "alicloud_security_group_rule" "ack_icmp_ingress" {
  security_group_id = alicloud_security_group.ack_security_group.id
  type              = "ingress"
  ip_protocol          = "icmp"
  port_range        = "-1/-1"
  cidr_ip           = "0.0.0.0/0"
  description       = "Allow ICMP for troubleshooting"
}

#Outbound Rule - Allow All Egress (Default Best Practice)
resource "alicloud_security_group_rule" "ack_all_egress" {
  security_group_id = alicloud_security_group.ack_security_group.id
  type              = "egress"
  ip_protocol          = "all"
  port_range        = "-1/-1"
  cidr_ip           = "0.0.0.0/0"
  description       = "Allow all outbound traffic"
}


# Terway VXLAN Communication
resource "alicloud_security_group_rule" "terway_vxlan" {
  type              = "ingress"
  ip_protocol       = "udp"
  port_range        = "4789/4789"
  priority          = 4
  security_group_id = alicloud_security_group.ack_security_group.id
  cidr_ip           = "192.168.0.0/16"
}


