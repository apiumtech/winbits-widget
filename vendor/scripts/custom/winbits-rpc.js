(function(){
  Winbits.rpc = new easyXDM.Rpc({
    remote: Winbits.userConfig.providerUrl, // the path to the provider
    onReady: function() {
      console.log('XDM Communication Ready!')

    }
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