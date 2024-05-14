# Module fileshare-alb

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.62.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_is_lb.file_share_alb](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_lb) | resource |
| [ibm_is_lb_listener.nfs_front_end_listner](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_lb_listener) | resource |
| [ibm_is_lb_pool.nfs_backend_pool](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_lb_pool) | resource |
| [ibm_is_lb_pool_member.nfs_backend_pool_member](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_lb_pool_member) | resource |
| [ibm_is_share.file_share_nfs](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_share) | resource |
| [ibm_is_share_mount_target.mount_target_nfs](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_share_mount_target) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | The user-defined name for this load balancer pool. | `string` | n/a | yes |
| <a name="input_alb_security_group_ids"></a> [alb\_security\_group\_ids](#input\_alb\_security\_group\_ids) | A list of security groups that are used with this load balancer. This option is supported only for application load balancers. | `list(string)` | n/a | yes |
| <a name="input_alb_subnet_ids"></a> [alb\_subnet\_ids](#input\_alb\_subnet\_ids) | The ID of the subnets to provision this load balancer. | `list(string)` | n/a | yes |
| <a name="input_file_share_iops"></a> [file\_share\_iops](#input\_file\_share\_iops) | The maximum input/output operation performance bandwidth per second for the file share. | `number` | n/a | yes |
| <a name="input_file_share_mount_target_name"></a> [file\_share\_mount\_target\_name](#input\_file\_share\_mount\_target\_name) | The user-defined name for this share target. Names must be unique within the share the share target resides in. | `string` | n/a | yes |
| <a name="input_file_share_name"></a> [file\_share\_name](#input\_file\_share\_name) | The user-defined name for this share target. Names must be unique within the share the share target resides in. | `string` | n/a | yes |
| <a name="input_file_share_security_group_ids"></a> [file\_share\_security\_group\_ids](#input\_file\_share\_security\_group\_ids) | List of securtiy group ids to be attached. | `list(string)` | n/a | yes |
| <a name="input_file_share_size"></a> [file\_share\_size](#input\_file\_share\_size) | The size of the file share rounded up to the next gigabyte. | `number` | n/a | yes |
| <a name="input_file_share_subnet_id"></a> [file\_share\_subnet\_id](#input\_file\_share\_subnet\_id) | The subnet id of the virtual network interface for the share mount target. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the resource group to use. | `string` | n/a | yes |
| <a name="input_vpc_zone"></a> [vpc\_zone](#input\_vpc\_zone) | The globally unique name for this zone. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_nfs_host_or_ip_path"></a> [nfs\_host\_or\_ip\_path](#output\_nfs\_host\_or\_ip\_path) | NFS mount path for created infrastructure. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
