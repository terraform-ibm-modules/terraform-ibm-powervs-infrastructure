# Module fileshare-nlb

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.65.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_is_lb.file_share_nlb](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_lb) | resource |
| [ibm_is_lb_listener.nfs_front_end_listener](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_lb_listener) | resource |
| [ibm_is_lb_pool.nfs_backend_pool](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_lb_pool) | resource |
| [ibm_is_share.file_share_nfs](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_share) | resource |
| [ibm_is_share_mount_target.mount_target_nfs](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_share_mount_target) | resource |
| [ibm_is_vpc_routing_table.nfs_routing_table](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpc_routing_table) | resource |
| [ibm_is_vpc_routing_table_route.nfs_route](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpc_routing_table_route) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_file_share_iops"></a> [file\_share\_iops](#input\_file\_share\_iops) | The maximum input/output operation performance bandwidth per second for the file share. | `number` | n/a | yes |
| <a name="input_file_share_mount_target_name"></a> [file\_share\_mount\_target\_name](#input\_file\_share\_mount\_target\_name) | The user-defined name for this share target. Names must be unique within the share the share target resides in. | `string` | n/a | yes |
| <a name="input_file_share_name"></a> [file\_share\_name](#input\_file\_share\_name) | The user-defined name for this share target. Names must be unique within the share the share target resides in. | `string` | n/a | yes |
| <a name="input_file_share_security_group_ids"></a> [file\_share\_security\_group\_ids](#input\_file\_share\_security\_group\_ids) | List of security group ids to be attached. | `list(string)` | n/a | yes |
| <a name="input_file_share_size"></a> [file\_share\_size](#input\_file\_share\_size) | The size of the file share rounded up to the next gigabyte. | `number` | n/a | yes |
| <a name="input_file_share_subnet_id"></a> [file\_share\_subnet\_id](#input\_file\_share\_subnet\_id) | The subnet id of the virtual network interface for the share mount target. | `string` | n/a | yes |
| <a name="input_nlb_name"></a> [nlb\_name](#input\_nlb\_name) | The user-defined name for this load balancer pool. | `string` | n/a | yes |
| <a name="input_nlb_security_group_ids"></a> [nlb\_security\_group\_ids](#input\_nlb\_security\_group\_ids) | A list of security groups that are used with this load balancer. | `list(string)` | n/a | yes |
| <a name="input_nlb_subnet_ids"></a> [nlb\_subnet\_ids](#input\_nlb\_subnet\_ids) | The ID of the subnets to provision this load balancer. | `list(string)` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the resource group to use. | `string` | n/a | yes |
| <a name="input_routing_table_name"></a> [routing\_table\_name](#input\_routing\_table\_name) | Name of the routing table that contains the routes for NFS over Network Load Balancer. | `string` | n/a | yes |
| <a name="input_vpc_zone"></a> [vpc\_zone](#input\_vpc\_zone) | The globally unique name for this zone. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_file_share_nlb"></a> [file\_share\_nlb](#output\_file\_share\_nlb) | Details of network load balancer. |
| <a name="output_nfs_host_or_ip_path"></a> [nfs\_host\_or\_ip\_path](#output\_nfs\_host\_or\_ip\_path) | NFS mount path for created infrastructure. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
