# The production environment rule customizations belong in this file.

ipc_AMQP_EPHEMERAL = false
ipc_IES_IP = '206.207.252.32'
ipc_RE_HOST = 'data.cyverse.org'

acSetNumThreads {
  ON($rescName == 'cshlWildcatRes' && clientAddr == ipc_IES_IP) {
    msiSetNumThreads('default', '0', 'default');
  }
}
