# The production environment rule customizations belong in this file.

ipc_AMQP_EPHEMERAL : boolean
ipc_AMQP_EPHEMERAL = false


ipc_DEFAULT_REPL_RESC : string
ipc_DEFAULT_REPL_RESC = 'taccCorralRes'

ipc_DEFAULT_RESC : string
ipc_DEFAULT_RESC = 'CyVerseRes'

ipc_IES_IP : string
ipc_IES_IP = '206.207.252.32'

ipc_MAX_NUM_RE_PROCS : integer
ipc_MAX_NUM_RE_PROCS = 12

ipc_RE_HOST : string
ipc_RE_HOST = 'data.cyverse.org'

ipc_ZONE : string
ipc_ZONE = 'iplant'


acSetNumThreads {
  ON($rescName == 'cshlWildcatRes' && $clientAddr == ipc_IES_IP) {
    msiSetNumThreads('default', '0', 'default');
  }
}
