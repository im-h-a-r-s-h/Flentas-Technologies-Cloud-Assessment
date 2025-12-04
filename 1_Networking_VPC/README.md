
# Task 1 - Networking & Subnetting (AWS VPC Setup)

## Approach and details.

I designed a highly available, multi-tier network architecture following AWS best practices:
Brief approach:
- Designed a single VPC with CIDR 10.0.0.0/16 to allow multiple /24 subnets.
- Created two public subnets (10.0.0.0/24, 10.0.1.0/24) and two private subnets (10.0.10.0/24, 10.0.11.0/24) across two AZs for HA.
- Attached an Internet Gateway for public subnets and deployed a NAT Gateway in a public subnet to allow private subnet outbound access.
- All Terraform code is in `main.tf`. Resources are prefixed with `Harsh_Gupta_` as required.

What to include in submission:
- One Terraform file: `main.tf` (already present).
- Screenshots to capture: VPC, Subnets, Route Tables, NAT Gateway + IGW (see task requirements).

CIDR ranges used:
- VPC: `10.0.0.0/16`
- Public Subnet A: `10.0.0.0/24`
- Public Subnet B: `10.0.1.0/24`
- Private Subnet A: `10.0.10.0/24`
- Private Subnet B: `10.0.11.0/24`

Rationale: /24 subnets give 254 usable IPs each, sufficient for assessment. Separate ranges for public and private make routing and NAT selection clearer.

1. **VPC Architecture**: Created a single VPC with CIDR block `10.0.0.0/16`, providing 65,536 total IP addresses with ample room for scaling.

2. **Public Subnets**: Deployed 2 public subnets across different availability zones:
   - `Harsh_Gupta_public-1`: `10.0.0.0/24` in `ap-south-1a` (256 IPs)
   - `Harsh_Gupta_public-2`: `10.0.1.0/24` in `ap-south-1b` (256 IPs)
   - These subnets have auto-assigned public IPs enabled for direct internet access

3. **Private Subnets**: Deployed 2 private subnets for internal resources:
   - `Harsh_Gupta_private-1`: `10.0.10.0/24` in `ap-south-1a` (256 IPs)
   - `Harsh_Gupta_private-2`: `10.0.11.0/24` in `ap-south-1b` (256 IPs)
   - These use RFC1918 private address space, starting at .10 and .11 to avoid overlap with public subnets

4. **Internet Gateway**: Attached IGW for public subnet internet connectivity (0.0.0.0/0 route)

5. **NAT Gateway**: Placed in public subnet `ap-south-1a` with Elastic IP for private subnet outbound internet access

## CIDR Planning Rationale

- **VPC CIDR: 10.0.0.0/16** - Standard Class A private range, allows for future expansion
- **Public Subnets: 10.0.0.0/24 & 10.0.1.0/24** - First octets (0, 1) for easy identification; /24 provides 254 usable IPs each
- **Private Subnets: 10.0.10.0/24 & 10.0.11.0/24** - Separate range (10, 11) maintains clear separation; avoids conflicts with public tier

Design ensures:
- ✅ High Availability across 2 AZs
- ✅ Security isolation (public/private separation)
- ✅ Efficient IP utilization

## Deployment Instructions

```bash
cd 1_Networking_VPC
terraform init
terraform plan -var "prefix=Harsh_Gupta_"
terraform apply -var "prefix=Harsh_Gupta_"
```

## Screenshots to Capture

1. **VPC Details** - Verify CIDR block 10.0.0.0/16
2. **Subnets** - All 4 subnets with CIDR ranges and AZ assignments
3. **Route Tables** - Public (→IGW) and Private (→NAT) routes
4. **Internet Gateway** - Attached to VPC
5. **NAT Gateway** - In public subnet with EIP

## Cleanup

```bash
terraform destroy -var "prefix=Harsh_Gupta_"
```
