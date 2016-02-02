var MILO = {
  data : {},
  serviceUrl : '',
  assets : [],
  frames : [],
  videos : [],
  _video : {},
  zoom: 1,
  x_min: -386,
  x_max: 378,
  x_offset : 0,
  x_last: 0,
  hammer_enabled: 0,
  timer: {},
  timer_counter: 0,
  handle_interaction_tracked: 0,
  handle_trigger_tracked: 0,
  isSafari: 0,
  isAndroidMobile: 0,
  interactionMade: 0,
  userChoice: 0,
  svg: {},
  inactivity: true,

  init : function() {

    var navU = navigator.userAgent;
    MILO.isSafari = Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0;
    MILO.isAndroidMobile = (navU.indexOf('Android') > -1 && navU.indexOf('Mozilla/5.0') > -1 && navU.indexOf('AppleWebKit') > -1);

    if(MILO.isAndroidMobile) {
      $('#ad').removeClass('android').addClass('android')
    }

    var layout = MILO.data.steps;

    for (var i = 0; i < layout.length; i++) {
      var new_frame = new advertFrame(layout[i],i);
      new_frame.render();
      MILO.frames.push(new_frame)
    }

    MILO.addFrameListeners();

    var video_data = MILO.data.videos;
    for (var i = 0; i < video_data.length; i++) {
      var new_video = new advertVideo(video_data[i]);
      MILO.videos.push(new_video)
    }

    /*disable
    MILO.zoom = 360 / document.documentElement.clientWidth;
    $(window).resize(function() {
      MILO.zoom = 360 / document.documentElement.clientWidth;
    })
    */

    setTimeout(function() {
      MILO.playFrame('f1')
    }, 500);

    //impression

  },
  addFrameListeners: function() {


    //frame 1 actions
    $('#ad #f1').bind('onplay',function() {

      var xmlns = "http://www.w3.org/2000/svg";
      MILO.svg.svgContainer = document.getElementById("gameZone");
      MILO.svg.svgElem = document.createElementNS (xmlns, "svg");
      MILO.svg.svgElem.setAttributeNS(null, "id", "svgRoot");

      MILO.svg.svgContainer.appendChild(MILO.svg.svgElem);
      var stops = [
        {offset:'5%', 'stop-color':'#6a6866'},
        {offset:'95%','stop-color':'#2e2b28'}
      ]
      var grad  = document.createElementNS(xmlns,'linearGradient');
      grad.setAttribute('id',"padGradient");
      grad.setAttribute('x1',"0%");
      grad.setAttribute('y1',"0%");
      grad.setAttribute('x2',"0%");
      grad.setAttribute('y2',"100%");
      for (var i=0;i<stops.length;i++){
        var attrs = stops[i];
        var stop = document.createElementNS(xmlns,'stop');
        for (var attr in attrs){
          if (attrs.hasOwnProperty(attr)) stop.setAttribute(attr,attrs[attr]);
        }
        grad.appendChild(stop);
      }

      var defs = MILO.svg.svgElem.querySelector('defs') ||
      MILO.svg.svgElem.insertBefore( document.createElementNS(xmlns,'defs'), MILO.svg.svgElem.firstChild);
      defs.appendChild(grad);

      MILO.svg.shape_circle = document.createElementNS(xmlns, "circle");
      MILO.svg.shape_rect = document.createElementNS(xmlns, "rect");

      MILO.svg.svgElem.appendChild (MILO.svg.shape_circle);
      MILO.svg.svgElem.appendChild (MILO.svg.shape_rect);

      MILO.svg.shape_circle.setAttributeNS(null, "cx", 50);
      MILO.svg.shape_circle.setAttributeNS(null, "cy", 200);
      MILO.svg.shape_circle.setAttributeNS(null, "r",  20);
      MILO.svg.shape_circle.setAttributeNS(null, "id", "ball");

      MILO.svg.shape_rect.setAttributeNS(null, "id", "pad");
      MILO.svg.shape_rect.setAttributeNS(null, "height", "25px");
      MILO.svg.shape_rect.setAttributeNS(null, "width",  "245px");
      MILO.svg.shape_rect.setAttributeNS(null, "x", 200);
      MILO.svg.shape_rect.setAttributeNS(null, "y", 200);
      MILO.svg.shape_rect.setAttributeNS(null, "rx", 0);
      MILO.svg.shape_rect.setAttributeNS(null, "ry", 0);
      MILO.svg.shape_rect.setAttributeNS(null, "fill", 'url(#padGradient)');

      GAME.initGame();

      if(!MILO.hammer_enabled) {
        MILO.hammer_enabled = 1
        $('#svgRoot rect').hammer({drag: true})

          .on('panmove', function(event) {
            var target = event.target;
            offset = MILO.x_last + event.gesture.deltaX

            //out of bounds
            if(offset > MILO.x_max || offset < MILO.x_min) {
              return
            }

            MILO.x_offset = offset
            $(target).css({'transform': 'translateX(' + MILO.x_offset + 'px)'});
            GAME.padX = MILO.x_offset + 386;
            MILO.inactivity = false;

          }).on('panend', function(event) {
            MILO.x_last = MILO.x_offset
          });

        }


      $('#ad #f1 .left').click(function(event) {
        event.preventDefault();
        event.stopPropagation();
        GAME.padSpeed -= 30;
        GAME.movePad();
        MILO.inactivity = false;
      })

      $('#ad #f1 .right').click(function(event) {
        event.preventDefault();
        event.stopPropagation();
        GAME.padSpeed += 30;
        GAME.movePad();
        MILO.inactivity = false;
      })

      $(this).find('.button-start-game').click(function(event) {
        event.preventDefault();
        event.stopPropagation();

        $('#ad #f1').removeClass("gameon").addClass("gameon")
        $('#ad #f1 #gameZone').on('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend',function() {
          $( "#pad, #ball" ).animate({
              opacity: 1.0
            }, 500, function() {
              // Animation complete.
            });
        });
        setTimeout(function() {
          GAME.startGame();

          MILO.activitymonitor = setInterval(function() {
            if(MILO.inactivity) {
              clearInterval(MILO.activitymonitor)
              clearInterval(GAME.gameIntervalID);
              GAME.turbomode = true;
              $('#ad #f1 #svgRoot rect').hide();
              GAME.gameIntervalID = setInterval(GAME.gameLoop, 1);
            } else {
              MILO.inactivity = true;
            }
          }, 10000);
        }, 3000);


      })


      $('#ad #f1 #message').on('webkitAnimationEnd oanimationend msAnimationEnd animationend',function() {
        MILO.playFrame('f2')
      });


    })

    $('#ad #f2').bind('onplay',function() {

      $('#ad #f2 .button-learn-more').click(function(event) {
        TXM.utils.popupWebsite();
      })
    })


  },

  setConfig : function(config_obj) {
    if(_.has(config_obj, 'data')) {
      this.data = config_obj.data
    }
    if(_.has(config_obj, 'serviceUrl')) {
      this.serviceUrl = config_obj.serviceUrl
    }
  },
  preloadAssets : function() {

      _.each(MILO.data.steps, function(step_obj) {
        _.each(step_obj.controls, function(control_obj) {
          var asset_url = MILO.serviceUrl + 'assets/' + control_obj.name;
          $("<img />").attr("src", asset_url);
          MILO.assets.push(asset_url);
        })
      })

      if(_.has(MILO.data, 'additional_assets')) {

        _.each(MILO.data.additional_assets, function(asset_obj) {
          var asset_url = MILO.serviceUrl + 'assets/' + asset_obj;
          $("<img />").attr("src", asset_url);
          MILO.assets.push(asset_url);
        })

      }

      //google fonts
      /*
      WebFontConfig = {
        google: { families: [ 'Lato:400,300,100,100italic,300italic,400italic,700italic,700,900,900italic:latin' ] }
      };
      (function() {
        var wf = document.createElement('script');
        wf.src = ('https:' == document.location.protocol ? 'https' : 'http') +
          '://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js';
        wf.type = 'text/javascript';
        wf.async = 'true';
        var s = document.getElementsByTagName('script')[0];
        s.parentNode.insertBefore(wf, s);
      })();
      */

  },
  playFrame: function(id) {

    selected_frame = MILO.getFrameByID(id)
    selected_frame.play()

  },
  getFrameByID: function(id) {
    var selected_frames = _.where(MILO.frames, {id: id});
    if (selected_frames.length) {
      return selected_frames[0];
    } else {
      return {} //not found
    }
  },

  renderVideo: function(video_id, container_obj,callback) {

    selected_video = MILO.getVideoByID(video_id)
    selected_video.render(container_obj,callback)

  },
  getVideoByID: function(id) {
    var selected_obj = _.where(MILO.videos, {id: id});
    if (selected_obj.length) {
      return selected_obj[0];
    } else {
      return {} //not found
    }
  },

  stopVideos: function() {
    $('video').each(function(index) {
      $(this).get(0).pause();
    })
  },

  impressionTag: function(url) {
    var random_number = Math.floor((Math.random() * 10000) + 1);
    TXM.utils.loadExternalTracking(url + random_number);
  }


}