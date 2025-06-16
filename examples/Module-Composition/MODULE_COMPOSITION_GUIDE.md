# Module Composition Guide: Using Resources from Other Modules

This guide explains how to use resources created in one module as inputs to another module.

## 🎯 Scenario Overview

You want to:
1. Create network infrastructure (NICs, IPs) in **Module A**
2. Use those resources in **Module B** (VM module) 
3. Apply both modules together

## 🔧 Implementation Methods

### Method 1: Use Existing Resources by Name (Recommended)

This is the **simplest approach** using the enhanced VM module:

```hcl
# Step 1: Create network infrastructure
module "network_infrastructure" {
  source = "./child_modules/Network"
  
  # Create resources
  public_ips = {
    "shared-web-ip" = { /* config */ }
  }
  network_interfaces = {
    "shared-web-nic" = { /* config */ }
  }
}

# Step 2: Use existing resources in VM module
module "virtual_machines" {
  source = "./child_modules/Virtual-Machine"
  
  # Reference existing resources by name
  public_ip_name = {
    "shared-web-ip" = {
      use_existing                = true
      existing_resource_group_name = module.network_infrastructure.resource_group_name
      # Other fields required but ignored
      allocation_method = "Static"
      sku              = "Standard"
    }
  }
  
  network_interfaces = {
    "shared-web-nic" = {
      use_existing                = true
      existing_resource_group_name = module.network_infrastructure.resource_group_name
      # Other fields required but ignored
      subnet_name                   = "ignored"
      private_ip_address_allocation = "ignored"
    }
  }
  
  depends_on = [module.network_infrastructure]
}
```

### Method 2: Pass Resource IDs Directly

If you want to pass specific resource IDs:

```hcl
# This requires enhancing your VM module variables.tf
variable "direct_resource_ids" {
  type = object({
    public_ip_ids = optional(map(string), {})
    nic_ids       = optional(map(string), {})
  })
  default = {}
}

# Usage in root main.tf
module "vms_with_direct_ids" {
  source = "./child_modules/Virtual-Machine"
  
  direct_resource_ids = {
    public_ip_ids = {
      "my-ip" = module.network.public_ip_ids["web-ip"]
    }
    nic_ids = {
      "my-nic" = module.network.nic_ids["web-nic"]
    }
  }
}
```

## 📋 Best Practices

### 1. Resource Naming Consistency
```hcl
# Use consistent naming across modules
locals {
  resource_names = {
    web_ip   = "web-server-ip"
    web_nic  = "web-server-nic"
    db_ip    = "db-server-ip"
    db_nic   = "db-server-nic"
  }
}

module "network" {
  # Use consistent names
  public_ips = {
    (local.resource_names.web_ip) = { /* config */ }
    (local.resource_names.db_ip)  = { /* config */ }
  }
}

module "vms" {
  # Reference with same names
  public_ip_name = {
    (local.resource_names.web_ip) = {
      use_existing = true
      # ...
    }
  }
}
```

### 2. Resource Group Management
```hcl
# Option A: Shared resource group
locals {
  shared_rg_name = "shared-infrastructure-rg"
}

module "network" {
  resource_group_name = local.shared_rg_name
}

module "vms" {
  public_ip_name = {
    "my-ip" = {
      use_existing                = true
      existing_resource_group_name = local.shared_rg_name
    }
  }
}

# Option B: Reference module output
module "vms" {
  public_ip_name = {
    "my-ip" = {
      use_existing                = true
      existing_resource_group_name = module.network.resource_group_name
    }
  }
}
```

### 3. Dependency Management
```hcl
module "vms" {
  # ... configuration ...
  
  # Explicit dependency ensures network module completes first
  depends_on = [module.network]
}
```

### 4. Error Handling & Validation
```hcl
# Add validation to ensure required outputs exist
module "vms" {
  # ... configuration ...
  
  # This will fail if the network module doesn't output the required RG name
  existing_resource_group_name = module.network.resource_group_name
}

# Use try() for optional resources
module "vms" {
  public_ip_name = {
    "optional-ip" = {
      use_existing                = true
      existing_resource_group_name = try(module.network.resource_group_name, "default-rg")
    }
  }
}
```

## 🚀 Deployment Steps

### 1. Plan Both Modules
```bash
# Plan the entire composition
terraform plan

# Plan specific modules (if needed)
terraform plan -target=module.network
terraform plan -target=module.vms
```

### 2. Apply in Order (if needed)
```bash
# Apply network first (if dependencies require it)
terraform apply -target=module.network

# Then apply VMs
terraform apply -target=module.vms

# Or apply everything together (recommended)
terraform apply
```

### 3. Verify Resources
```bash
# Check that resources are properly linked
terraform show | grep -E "(public_ip|network_interface)"

# Verify outputs
terraform output
```

## 🔍 Troubleshooting

### Common Issues:

1. **"Resource not found"**
   ```
   Solution: Ensure the source module actually creates the resource
   Check: module.network.public_ip_ids output contains your resource
   ```

2. **"Dependency cycle"**
   ```
   Solution: Remove circular dependencies between modules
   Use depends_on explicitly if needed
   ```

3. **"Resource group mismatch"**
   ```
   Solution: Ensure existing_resource_group_name points to the correct RG
   Verify: module.network.resource_group_name output
   ```

### Debug Commands:
```bash
# Check module outputs
terraform output -module=network
terraform output -module=vms

# Validate configuration
terraform validate

# Check resource states
terraform state list | grep -E "(public_ip|network_interface)"
```

## 📝 Example File Structure

```
project/
├── main.tf                    # Root module composition
├── outputs.tf                # Combined outputs
├── provider.tf               # Provider configuration
├── variables.tf              # Root variables (if any)
├── child_modules/
│   ├── Network/              # Module A (creates NICs, IPs)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── Virtual-Machine/      # Module B (uses resources from A)
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── examples/
    └── Module-Composition/    # This example
        ├── main.tf
        ├── outputs.tf
        └── provider.tf
```

This approach gives you **maximum flexibility** to compose multiple modules while reusing infrastructure components efficiently! 🎯
