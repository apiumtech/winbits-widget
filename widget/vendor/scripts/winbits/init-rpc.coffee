##
 # Inicialización del proxy para RPC usando easyXDM
 # User: jluis
 # Date: 25/03/14
 ##

(->
  Winbits.rpc = new easyXDM.Rpc(Winbits.userConfig.providerUrl,
  remote:
    request: {}
    getTokens: {}
    saveApiToken: {}
    storeVirtualCart: {}
    logout: {}
    saveUtms: {}
    getUtms: {}
    facebookStatus: {}
    facebookMe: {}
    saveUtms: {}
    getUtms: {}
  )
)()
