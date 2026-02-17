WeBlogic Ansible Playbook — Oracle WebLogic Server 14.1.2

Overview

This repository contains Ansible playbooks and supporting files to:
- Install required OS packages and JDK
- Install Oracle WebLogic Server 14.1.2 (offline, silent) from an installer JAR
- Create a standard domain using WLST (silent)

Important notes / prerequisites

- You must provide a WebLogic installer JAR (fmw_14.1.2.0.0_wls.jar or similar) and place it on the target host(s) or on an HTTP/HTTPS location reachable by the host(s). Set weblogic_installer_source in group_vars or extra-vars.
- Oracle installer requires Java. This playbook will install OpenJDK 11 using the system package manager. You can change this in variables.
- The installer requires a response file. A template is provided (templates/install.rsp.j2).
- Domain creation uses a WLST (Jython) script template (templates/create_domain.py.j2). This will be executed with the weblogic user via the created WebLogic installation.
- Adjust paths and user/group settings in group_vars/all.yml before running.
- This repository does not include Oracle binaries (license restriction).

Directory layout

- playbook.yml — entrypoint playbook
- inventory.ini — example inventory
- roles/weblogic/ — role that performs install + domain creation
- templates/ — response file and WLST script templates
- group_vars/all.yml — default variables

Quick start

1. Edit group_vars/all.yml and set weblogic_installer_source (local path or URL), admin credentials, domain values.
2. Ensure the target host is reachable via SSH and is in inventory.ini under [weblogic]
3. Run:
   ansible-playbook -i inventory.ini playbook.yml

Security

- Do not commit installer JAR or real passwords into source control.
- Use Ansible Vault for sensitive variables (weblogic_admin_password, os_user_password, etc.).

Support

If you want I can tailor the playbook to your target OS (RHEL/CentOS/Oracle Linux/Ubuntu), or add cluster/domain templates, NodeManager config, systemd service files, and more.
