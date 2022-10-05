locals {
  cmd_print_version = jsonencode({
    "\"version\"" = "\"$(apt-cache policy $PACKAGE | grep --color=never Installed | sed 's/Installed: //')\""
  })
}

resource "shell_script" "install_pkgs" {
  for_each = toset(var.install_pkgs)

  lifecycle_commands {
    create = format("sudo apt-get install -y --allow-downgrades --no-install-recommends $PACKAGE; echo %s", local.cmd_print_version)
    read   = format("echo %s", local.cmd_print_version)
    update = format("sudo apt-get install -y --allow-downgrades --no-install-recommends --reinstall $PACKAGE; echo %s", local.cmd_print_version)
    delete = "" 
  }

  environment = {
    PACKAGE = each.value
  }
}

resource "shell_script" "uninstall_pkgs" {
  for_each = toset(var.uninstall_pkgs)

  lifecycle_commands {
    create = format("sudo apt-get remove -y $PACKAGE; echo %s", local.cmd_print_version)
    read   = format("echo %s", local.cmd_print_version)
    update = format("sudo apt-get remove -y $PACKAGE; echo %s", local.cmd_print_version)
    delete = "" 
  }

  environment = {
    PACKAGE = each.value
  }
}
