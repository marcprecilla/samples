(function() {

  var creative = {
    _init: function() {
      TXM.dispatcher.addEventListenerOnce('ENGAGEMENT_STARTED', creative._onStart);
      TXM.dispatcher.addEventListenerOnce('ENGAGEMENT_ENDED', creative._onEnd);

      // preload assets
      //serviceUrl = window.location.href;
      //serviceUrl = serviceUrl.substring(0,serviceUrl.lastIndexOf("/") + 1)

      $.when(
          $.getJSON( serviceUrl + 'engagement.json' ),
          $.getScript( serviceUrl + 'app-util.js' ),
          $.getScript( serviceUrl + 'app.js' ),
          $.getScript( serviceUrl + 'game.js' ),
          $.getScript( serviceUrl + 'underscore-min.js' ),
          $.getScript( serviceUrl + 'hammer.min.js' )
        ).done(function(config, app_util, helpers, game, underscore, hammer){
          window.console.log('scripts imported');
          $('<link rel="stylesheet" href="' + serviceUrl + 'css/application.css">').appendTo('head');
          MP.setConfig({
            data: config[0],
            serviceUrl : serviceUrl
          });

          MP.preloadAssets();

          // when preload complete, signal ready to start
          TXM.dispatcher.dispatchEvent('INTERACTIVE_ASSET_READY');

          TXM.dispatcher.dispatchEvent('ENGAGEMENT_STARTED');
      }).fail(function(error) {
          window.console.log(error);
        });

    },

    _onStart: function() {
      // start ad

      TXM.ui.show("<div id=\"ad\"></div>");
      $('body').append("<div id=\"ad\"></div>");
      MP.init();

    },

    _onEnd: function() {
      // end ad
    }
  };

  creative._init();
}());