# apt

This state sets up the required external repositories needed to install the software on the host. So far, it only installs matrix.org's APT repository on Ubuntu Xenial hosts that need to install Synapse (i.e. that have `synapse` in their declared roles).
