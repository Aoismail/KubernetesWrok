# Create a managed node pool. 
resource "alicloud_cs_kubernetes_node_pool" "managed_node_pool" {
  cluster_id     = alicloud_cs_managed_kubernetes.default.id              # The ACK cluster name. 
  node_pool_name = "rtf-ack-managed_nodepool-${var.env}"                            # The node pool name. 
  resource_group_id = var.resource_group_id
  vswitch_ids    = var.vswitch_ids # The vSwitch to which the node pool belongs. Specify one or more vSwitch IDs. The vSwitches must reside in the zone specified by availability_zone. 
  desired_size   = 2                                                      # The expected number of nodes in the node pool. 
  security_group_id = alicloud_security_group.ack_nodes.id  # Attach worker SG
  management {
    auto_repair     = true
    auto_upgrade    = true
    max_unavailable = 1
  }
  instance_types        = var.worker_instance_types
  instance_charge_type  = "PostPaid"
  key_name              = var.key_name
  install_cloud_monitor = true
  system_disk_category  = "cloud_essd"
  system_disk_size      = 100
  image_type            = "AliyunLinux3"
  
  data_disks {
    category = "cloud_essd"
    size     = 250
  }
  
}






resource "alicloud_security_group" "ack_nodes" {
  name        = "ack-cluster-nodes-sg-${var.env}"
  description = "Security group for ACK managed nodes"
  vpc_id      = var.vpc_id # Replace with your VPC ID
  resource_group_id = var.resource_group_id
  

}

resource "alicloud_security_group_rule" "nodes" {
  security_group_id        = alicloud_security_group.ack_nodes.id
  type                     = "ingress"
  ip_protocol              = "all"         # Allow all protocols
  port_range               = "0/65535"    # All ports
  source_security_group_id = alicloud_security_group.ack_security_group.id
  description              = "Allow nodes to communicate with each other"
}

resource "alicloud_security_group_rule" "nodes_inbound" {
  security_group_id        = alicloud_security_group.ack_nodes.id
  type                     = "ingress"
  ip_protocol              = "tcp"
  port_range               = "1025/65535"  # Worker nodes and pods communication
  source_security_group_id = alicloud_security_group.ack_security_group.id
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
}

#Outbound Rule - Allow All Egress (Default Best Practice)
resource "alicloud_security_group_rule" "ack_nodes_egress" {
  security_group_id = alicloud_security_group.ack_nodes.id
  type              = "egress"
  ip_protocol          = "all"
  port_range        = "-1/-1"
  cidr_ip           = "0.0.0.0/0"
  description       = "Allow all outbound traffic"
}