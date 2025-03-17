variable "region_id" {
  type    = string
  default = ""
}

variable "cluster_spec" {
  type        = string
  description = "The cluster specifications of kubernetes cluster,which can be empty. Valid values:ack.standard : Standard managed clusters; ack.pro.small : Professional managed clusters."
  default     = "ack.pro.small"
}

# Specify the zones of vSwitches. 
variable "availability_zone" {
  description = "The availability zones of vswitches."
  default     = []
}

# Specify vSwitch IDs. 

variable "vswitch_ids" {
  description = "List of existing node vswitch ids for terway."
  type        = list(string)
  default     = []
}

variable "vswitch_cidrs" {
  description = "List of cidr blocks used to create several new vswitches when 'vswitch_ids' is not specified."
  type        = list(string)
  default     = []
}



# Specify the Terway configurations. If you leave this variable empty, new Terway vSwitches are created based on the value of the terway_vswitch_cidrs variable. 
variable "terway_vswitch_ids" {
  description = "List of existing pod vswitch ids for terway."
  type        = list(string)
  default     = []
}

# This variable specifies the CIDR blocks in which Terway vSwitches are created when terway_vswitch_ids is not specified. 
variable "terway_vswitch_cidrs" {
  description = "List of cidr blocks used to create several new vswitches when 'terway_vswitch_ids' is not specified."
  type        = list(string)
  default     = []
}


variable "service_cidr" {
  description = "service cidr blocks"
  type        = string
  default     = ""
}

# Specify the ECS instance types of worker nodes. 
variable "worker_instance_types" {
  description = "The ecs instance types used to launch worker nodes."
  default     = []
}

# Specify a password for the worker node.
#variable "password" {
# description = "The password of ECS instance."
#  default     = "cs"
#}

variable "key_name" {
  description = "The SSH KeyPair to use for the Node ECS."
  type        = string
  default     = ""
}

# Specify the prefix of the name of the ACK managed cluster. 
variable "k8s_name_prefix" {
  description = "The name prefix used to create managed kubernetes cluster."
  default     = "RTF"
}

variable "env" {
}

variable "kubernetes_version" { type = string }

variable vpc_id {
  description = "VPC ID from which belongs the subnets"
  type        = string
  default = ""
}

variable "max_size" {
  description = "Maximum number of worker nodes in private subnet."
  default = 4
  type = number
}

variable "min_size" {
  description = "Minimum number of worker nodes in private subnet."
  default = 2
  type = number
}


variable "enable_public_access" {
  description = "Enable public access for the API server endpoint"
  type        = bool
  default     = true
}

variable "enable_private_access" {
  description = "Enable private access for the API server"
  type        = bool
  default     = false
}

variable "resource_group_id" {
  description = ""
  type        = string
  default     = ""
}

