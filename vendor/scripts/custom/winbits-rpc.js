(function(){
  Winbits.rpc = new easyXDM.Rpc({
    remote: Winbits.userConfig.providerUrl // the path to the provider
  },  {
    remote: {
      request:{},
      getTokens:{},
      saveApiToken:{},
      storeVirtualCart:{},
      facebookStatus:{} ,
      facebookMe:{}
    }
  });
})();