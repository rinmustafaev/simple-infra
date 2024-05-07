provider "azurerm" {
  #skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }

    subscription {
      prevent_cancellation_on_destroy = true
    }

    template_deployment {
      delete_nested_items_during_deletion = true
    }
  }
  subscription_id = "00000000-0000-0000-0000-000000000000"
}