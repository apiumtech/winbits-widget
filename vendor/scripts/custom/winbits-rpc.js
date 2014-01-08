(function(){
  Winbits.rpc = new easyXDM.Rpc({
    remote: Winbits.userConfig.providerUrl, // the path to the provider
    onReady: function() {
      console.log('Triggering event winbitsrpcready');
      Winbits.$(window.document).trigger('winbitsrpcready');
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