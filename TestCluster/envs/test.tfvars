
region_id = "me-central-1"
env = "test"
#k8s_name_prefix = "rtf-ack"
kubernetes_version = "1.30.7-aliyun.1"
vpc_id = "vpc-l4vfx2waxwnjtulo57dje"
vswitch_ids = ["vsw-l4ve6ndiuc6kijvdq70o8", "vsw-l4v3hqe1kj2i940kjm825"]
vswitch_cidrs = ["192.168.1.0/24", "192.168.2.0/24"]
terway_vswitch_cidrs = ["192.168.5.0/24", "192.168.6.0/24"]
service_cidr = "10.11.0.0/16"
worker_instance_types = ["ecs.r6.4xlarge"]
resource_group_id = "rg-aek4hmx3bg3zgta"
availability_zone = ["me-central-1a", "me-central-1b"]
max_size = 2
min_size = 1
key_name = "CSMuleSoftAdmins_NP"
kms_alias = "CS-Dev"