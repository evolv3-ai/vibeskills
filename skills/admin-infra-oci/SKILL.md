---
name: admin-infra-oci
description: |
  Deploys infrastructure on Oracle Cloud Infrastructure (OCI) with ARM64 instances (Always Free tier eligible).
  Handles compartments, VCNs, subnets, security lists, and compute instances.

  Use when: setting up Oracle Cloud infrastructure, deploying ARM64 instances, troubleshooting OUT_OF_HOST_CAPACITY errors, optimizing for Always Free tier.

  Keywords: oracle cloud, OCI, ARM64, VM.Standard.A1.Flex, Always Free tier, OUT_OF_HOST_CAPACITY, oci compartment, oci vcn
license: MIT
---

# Oracle Cloud Infrastructure (OCI)

**Status**: Production Ready | **Dependencies**: OCI CLI, SSH key pair

---

## Prerequisites

Before using this skill, verify the following:

### 1. OCI CLI Installed

```bash
oci --version
```

**If missing**, install with:
```bash
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)" -- --accept-all-defaults
source ~/.bashrc  # or restart terminal
```

### 2. OCI CLI Configured

```bash
ls ~/.oci/config
```

**If missing**, configure with:
```bash
oci setup config
```

You'll need:
- Tenancy OCID (OCI Console → Profile → Tenancy)
- User OCID (OCI Console → Profile → My Profile)
- Region (e.g., us-ashburn-1)
- API key pair (wizard generates this)

### 3. SSH Key Pair

```bash
ls ~/.ssh/id_rsa.pub
```

**If missing**, generate with:
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

### 4. SSH Key Permissions

```bash
stat -c %a ~/.ssh/id_rsa  # Should be 600
```

**If wrong**, fix with:
```bash
chmod 600 ~/.ssh/id_rsa
```

### 5. Test Authentication

```bash
oci iam availability-domain list
```

**If this fails**: API key may not be uploaded to OCI Console → Profile → API Keys

---

## Quick Start

### 1. Check Capacity First

OCI Always Free ARM instances are highly demanded. **Always check before deploying:**

```bash
./scripts/check-oci-capacity.sh
```

<details>
<summary><strong>Options and troubleshooting</strong></summary>

```bash
# Check specific region
./scripts/check-oci-capacity.sh us-ashburn-1

# Use different OCI profile
./scripts/check-oci-capacity.sh --profile PRODUCTION

# Check multiple regions
for region in us-ashburn-1 us-phoenix-1 ca-toronto-1; do
  echo "=== $region ==="
  ./scripts/check-oci-capacity.sh "$region"
done
```

**No capacity?** Use automated monitoring:

```bash
./scripts/monitor-and-deploy.sh --stack-id <STACK_OCID>
```

</details>

### 2. Deploy Infrastructure

```bash
# Configure environment
cp scripts/.env.example scripts/.env
# Edit scripts/.env with your values

# Deploy
./scripts/oci-infrastructure-setup.sh
```

---

## Scripts Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `check-oci-capacity.sh` | Check ARM instance availability | `./scripts/check-oci-capacity.sh [region]` |
| `oci-infrastructure-setup.sh` | Full infrastructure deployment | `./scripts/oci-infrastructure-setup.sh` |
| `monitor-and-deploy.sh` | Auto-deploy when capacity available | `./scripts/monitor-and-deploy.sh --stack-id <ID>` |
| `cleanup-compartment.sh` | Delete all resources | `./scripts/cleanup-compartment.sh <COMPARTMENT_OCID>` |

<details>
<summary><strong>Script details</strong></summary>

### check-oci-capacity.sh

Checks VM.Standard.A1.Flex availability across availability domains.

```bash
./scripts/check-oci-capacity.sh                    # Home region
./scripts/check-oci-capacity.sh us-ashburn-1       # Specific region
./scripts/check-oci-capacity.sh --profile DANIEL   # With profile
```

Tests 4 OCPU / 24GB RAM (full free tier), falls back to 2/12 if unavailable.

### monitor-and-deploy.sh

Continuously monitors and auto-deploys when capacity found.

```bash
./scripts/monitor-and-deploy.sh \
  --stack-id <STACK_OCID> \
  --profile DANIEL \
  --interval 300 \
  --max-attempts 100
```

### oci-infrastructure-setup.sh

Creates complete infrastructure: compartment → VCN → subnet → IGW → security list → instance.

Requires `.env` file with OCI credentials and configuration.

### cleanup-compartment.sh

Safely deletes compartment and all resources (requires confirmation).

```bash
./scripts/cleanup-compartment.sh ocid1.compartment.oc1..xxx
```

</details>

---

## Common Issues

<details>
<summary><strong>OUT_OF_HOST_CAPACITY</strong></summary>

**Error**: "Out of host capacity" when launching ARM64 instances

**Cause**: ARM64 Always Free instances are in high demand

**Solutions**:
1. Try different availability domains:
   ```bash
   ./scripts/check-oci-capacity.sh
   ```
2. Use automated monitoring:
   ```bash
   ./scripts/monitor-and-deploy.sh --stack-id <STACK_OCID>
   ```
3. Try different regions
4. Try smaller configuration (2 OCPU / 12GB)

</details>

<details>
<summary><strong>Authentication failures</strong></summary>

**Error**: `ServiceError: NotAuthenticated`

**Causes & fixes**:
- API key not uploaded: Add public key in OCI Console → Profile → API Keys
- Wrong fingerprint: Verify `~/.oci/config` matches OCI Console
- Key permissions: Run `chmod 600 ~/.oci/oci_api_key.pem`
- Clock skew: Sync system time

See [Configuration Guide](docs/CONFIG.md) for details.

</details>

<details>
<summary><strong>Cannot SSH to instance</strong></summary>

**Error**: Connection refused or timeout

**Checklist**:
1. Security list has port 22 ingress rule
2. Instance has public IP assigned
3. Internet gateway exists and route table configured
4. Correct SSH key pair used
5. Wait 1-2 minutes after instance launch

```bash
# Verify instance state
oci compute instance get --instance-id <INSTANCE_OCID> --query 'data."lifecycle-state"'

# Check public IP
oci compute instance list-vnics --instance-id <INSTANCE_OCID> --query 'data[0]."public-ip"'
```

</details>

<details>
<summary><strong>Shape not available</strong></summary>

**Error**: "Shape VM.Standard.A1.Flex not available"

**Cause**: Using incompatible image/shape combination

**Fix**: Match image architecture to shape:
- ARM64 shape (A1.Flex) → ARM64 image
- x86 shape → x86 image

```bash
# Find ARM64 Ubuntu images
oci compute image list \
  --compartment-id $TENANCY_OCID \
  --operating-system "Canonical Ubuntu" \
  --shape "VM.Standard.A1.Flex" \
  --query 'data[?contains("display-name", `22.04`)].id'
```

</details>

<details>
<summary><strong>Service limit exceeded</strong></summary>

**Error**: "Service limit exceeded" for A1 instances

**Cause**: Total OCPUs/memory exceeds Always Free limit (4 OCPU / 24GB)

**Fix**: Check existing instances:
```bash
oci compute instance list \
  --compartment-id $COMPARTMENT_ID \
  --query 'data[?contains("shape", `A1`)].{name:"display-name", shape:"shape", state:"lifecycle-state"}'
```

Stay within 4 OCPU + 24GB total across all A1 instances.

</details>

---

## Best Practices

<details>
<summary><strong>Always do</strong></summary>

✅ Use `VM.Standard.A1.Flex` for Always Free tier
✅ Check capacity before deployment
✅ Create dedicated compartments (not tenancy root)
✅ Use 10.0.0.0/8 private IP ranges
✅ Enable internet gateway for outbound access
✅ Add SSH security rule (port 22)
✅ Save all OCIDs for future reference
✅ Use `--wait-for-state` flags for reliability

</details>

<details>
<summary><strong>Never do</strong></summary>

❌ Use x86 shapes for Always Free (only ARM64 qualifies)
❌ Exceed 4 OCPUs / 24GB RAM total for A1 instances
❌ Delete compartment with active resources
❌ Delete resources out of order (see "Infrastructure Cleanup" section)
❌ Use overlapping CIDR blocks between VCNs
❌ Hardcode OCIDs (use environment variables)
❌ Skip `--wait-for-state` (resources need time to provision)

</details>

---

## Configuration Reference

<details>
<summary><strong>Environment variables</strong></summary>

Required:
```bash
TENANCY_OCID=ocid1.tenancy.oc1..xxx
USER_OCID=ocid1.user.oc1..xxx
REGION=us-ashburn-1
FINGERPRINT=xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx
PRIVATE_KEY_PATH=~/.oci/oci_api_key.pem
```

Optional (with defaults):
```bash
COMPARTMENT_NAME=coolify-compartment
VCN_CIDR=10.0.0.0/16
SUBNET_CIDR=10.0.1.0/24
INSTANCE_SHAPE=VM.Standard.A1.Flex
INSTANCE_OCPUS=2        # 1-4
INSTANCE_MEMORY_GB=12   # 1-24
SERVICE_TYPE=coolify    # coolify|kasm|both
```

</details>

<details>
<summary><strong>Server type configurations</strong></summary>

**Coolify** (default):
- 2 OCPU, 12GB RAM, 100GB storage
- Ports: 22, 80, 443, 8000, 6001, 6002

**KASM**:
- 4 OCPU, 24GB RAM, 80GB storage
- Ports: 22, 8443, 3389, 3000-4000

**Both**:
- 4 OCPU, 24GB RAM, 150GB storage
- All ports from both configurations

</details>

<details>
<summary><strong>Always Free tier limits</strong></summary>

| Resource | Limit |
|----------|-------|
| ARM Compute (A1.Flex) | 4 OCPUs + 24GB RAM total |
| Block Storage | 200GB total |
| Object Storage | 20GB |
| Outbound Data | 10TB/month |

Split across instances as needed (e.g., 2×2 OCPU or 1×4 OCPU).

</details>

---

## Infrastructure Cleanup

> **CRITICAL**: OCI resources have strict dependency ordering. Deleting in the wrong order causes "Conflict" errors. **Always follow this exact sequence.**

### Resource Dependency Chain

```
Compartment (delete last, or keep)
└── VCN
    ├── Internet Gateway ← referenced by Route Table
    ├── Route Table ← references Internet Gateway
    ├── Security List ← referenced by Subnet
    └── Subnet ← references Security List, Route Table
        └── Compute Instance (delete first)
```

### Correct Deletion Order

**Step 1: Terminate Compute Instances**
```bash
oci compute instance terminate \
  --instance-id $INSTANCE_ID \
  --preserve-boot-volume false \
  --force \
  --wait-for-state TERMINATED
```

**Step 2: Delete Subnet**
```bash
oci network subnet delete \
  --subnet-id $SUBNET_ID \
  --force \
  --wait-for-state TERMINATED
```

**Step 3: Clear Route Table Rules** (removes gateway reference)
```bash
oci network route-table update \
  --route-table-id $ROUTE_TABLE_ID \
  --route-rules '[]' \
  --force
```

**Step 4: Delete Internet Gateway**
```bash
oci network internet-gateway delete \
  --ig-id $INTERNET_GATEWAY_ID \
  --force \
  --wait-for-state TERMINATED
```

**Step 5: Delete Security List** (if custom, not default)
```bash
oci network security-list delete \
  --security-list-id $SECURITY_LIST_ID \
  --force \
  --wait-for-state TERMINATED
```

**Step 6: Delete Route Table** (if custom, not default)
```bash
oci network route-table delete \
  --rt-id $ROUTE_TABLE_ID \
  --force \
  --wait-for-state TERMINATED
```

**Step 7: Delete VCN**
```bash
oci network vcn delete \
  --vcn-id $VCN_ID \
  --force \
  --wait-for-state TERMINATED
```

**Step 8: Delete Compartment** (optional - only if explicitly requested)
```bash
# WARNING: This is permanent! Only delete if user explicitly confirms.
oci iam compartment delete \
  --compartment-id $COMPARTMENT_ID \
  --force
```

### Quick Reference Table

| Order | Resource | Delete Command | Wait State |
|-------|----------|----------------|------------|
| 1 | Instance | `oci compute instance terminate` | TERMINATED |
| 2 | Subnet | `oci network subnet delete` | TERMINATED |
| 3 | Route Table | `oci network route-table update --route-rules '[]'` | (none) |
| 4 | Internet Gateway | `oci network internet-gateway delete` | TERMINATED |
| 5 | Security List | `oci network security-list delete` | TERMINATED |
| 6 | Route Table | `oci network route-table delete` | TERMINATED |
| 7 | VCN | `oci network vcn delete` | TERMINATED |
| 8 | Compartment | `oci iam compartment delete` | (async) |

### Common Cleanup Errors

| Error | Cause | Fix |
|-------|-------|-----|
| "Subnet ... references Security List" | Deleting security list before subnet | Delete subnet first |
| "Route Table ... references Internet Gateway" | Deleting IGW before clearing routes | Clear route rules first |
| "VCN still has resources" | Resources still attached | Delete all children first |
| "Compartment not empty" | Resources in compartment | Delete all resources first |

### Using the Cleanup Script

For automated cleanup with dependency handling:

```bash
./scripts/cleanup-compartment.sh $COMPARTMENT_OCID
```

This script handles the ordering automatically but requires confirmation.

---

## Logging Integration

When performing infrastructure operations, log to the centralized system:

```bash
# After provisioning
log_admin "SUCCESS" "operation" "Provisioned OCI instance" "id=$INSTANCE_ID provider=OCI"

# After destroying
log_admin "SUCCESS" "operation" "Terminated OCI instance" "id=$INSTANCE_ID"

# On error
log_admin "ERROR" "operation" "OCI deployment failed" "error=OUT_OF_HOST_CAPACITY"
```

See `admin` skill's `references/logging.md` for full logging documentation.

---

## Additional Documentation

- [Installation Guide](docs/INSTALL.md) - Install OCI CLI on any OS
- [Configuration Guide](docs/CONFIG.md) - Set up OCI credentials
- [Capacity Guide](docs/CAPACITY.md) - Handling capacity issues
- [Networking Guide](docs/NETWORKING.md) - VCN, subnets, security lists
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md) - Common issues and solutions

---

## Official Resources

- [OCI Documentation](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [OCI CLI Reference](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/)
- [Always Free Tier](https://www.oracle.com/cloud/free/)
- [ARM Instances Guide](https://docs.oracle.com/en-us/iaas/Content/Compute/References/arm.htm)
