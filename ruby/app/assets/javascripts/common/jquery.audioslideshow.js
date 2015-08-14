(function( $ ) {

  $.fn.audioSlideshow = function( options ) {

    var settings = {
      jPlayerPath: "/lib/swf",
      suppliedFileType: "mp3",
      playSelector: ".audio-play",
      pauseSelector: ".audio-pause",
      currentTimeSelector: ".play-time",
      durationSelector: ".total-time",
      playheadSelector: ".playhead",
      timelineSelector: ".timeline",
      bufferingSelector: ".buffering",
      play: function(){},
      ended: function(){}
    };

    if(options){
      jQuery.extend(settings,options);
    }

    // Begin to iterate over the jQuery collection that the method was called on
    return this.each(function () {

      // Cache `this`
      var $that = $(this),
        $slides = $that.find('.audio-slides').children(),

        $currentTime = $that.find(settings.currentTimeSelector),
        $duration = $that.find(settings.durationSelector),
        $playhead = $that.find(settings.playheadSelector),
        $timeline = $that.find(settings.timelineSelector),
        //$playButton = $that.find(settings.playSelector),
        //$pauseButton = $that.find(settings.pauseSelector),
        $playButton = $(settings.playSelector),
        $pauseButton = $(settings.pauseSelector),

        $buffering_container = $(settings.bufferingSelector),

        slidesCount = $slides.length,
        slideTimes = new Array(),
        audioDurationinSeconds = parseInt($that.attr('data-audio-duration')),
        isPlaying = false,
        currentSlide = -1;

      //$pauseButton.hide();

      // Setup slides
      $slides.each(function(index,el){
        var $el = $(el);
        $el.hide();

        var second = parseInt($el.attr('data-slide-time')),
          thumbnail = $el.attr('data-thumbnail');

        if(index > 0){
          slideTimes.push(second);

          var img = '<span></span>',
            $marker = $('<a href="javascript:;" class="marker" data-time="' + second + '">' + img + '</a>'),
            l = (second / audioDurationinSeconds) * $that.width();
          /*
          var img = '<span><img src="' + thumbnail + '" width="100" height="75" /></span>',
            $marker = $('<a href="javascript:;" class="marker" data-time="' + second + '">' + img + '</a>'),
            l = (second / audioDurationinSeconds) * $that.width();
          */


          $marker.css('left',l).click(function(e){
            $jPlayerObj.jPlayer("play", parseInt($(this).attr('data-time')) + .5);
          });

          $timeline.append($marker);
        }
      });

      var $jPlayerObj = $('<div></div>');
      $that.append($jPlayerObj);

      $jPlayerObj.jPlayer({
        ready: function (event) {
          $.jPlayer.timeFormat.padMin = false;
          $(this).jPlayer("setMedia", {
            mp3: $that.attr('data-audio')
          });
        },
        play: function () {
          settings.play()
        },
        ended: function () {
          settings.ended()
        },
        swfPath: settings.jPlayerPath,
        supplied: settings.suppliedFileType,
        preload: 'auto',
        cssSelectorAncestor: ""
      });

      $jPlayerObj.bind($.jPlayer.event.timeupdate, function(event) { // Add a listener to report the time play began
        var curTime = event.jPlayer.status.currentTime;
        audioDurationinSeconds = event.jPlayer.status.duration;
        var p = (curTime / audioDurationinSeconds) * 100 + "%";

        $currentTime.text($.jPlayer.convertTime(curTime));
        $duration.text($.jPlayer.convertTime(audioDurationinSeconds));

        $playhead.width(p);

        if(slidesCount){
          var nxtSlide = 0;
          for(var i = 0; i < slidesCount; i++){
            if(slideTimes[i] < curTime){
              nxtSlide = i + 1;
            }
          }

          setAudioSlide(nxtSlide);
        }
      });

      if($('audio').length <= 0) { //non HTML5

        $jPlayerObj.bind($.jPlayer.event.progress, function(event) { // Add a listener to report the percent downloaded
          var p = parseInt(event.jPlayer.status.seekPercent) + "%";
          $buffering_container.html(p + " loaded");
          if(event.jPlayer.status.seekPercent >= 100) {
            $buffering_container.css("display","none");
            $duration.text($.jPlayer.convertTime(event.jPlayer.status.duration));
          }
        });

      }

      $jPlayerObj.bind($.jPlayer.event.play, function(event) { // Add a listener to report the time play began
        isPlaying = true;
        $playButton.hide();
        $pauseButton.show();

        if($('audio').length > 0) { //load progress
          audio = $('audio').get(0);
          $buffering_container.css("display","block");
          window.setInterval(function() {
            if(audio.buffered != undefined && audio.buffered.length != 0) {
              var loaded = parseInt(((audio.buffered.end(0) / audio.duration) * 100), 10);
              if (isNaN(loaded)) {
                loaded = 0;
              }
              if(loaded >= 100) {
                $buffering_container.css("display","none");
              } else {
                $buffering_container.html(loaded + "% loaded");
              }

            }

          }, 30);

        }


      });

      $jPlayerObj.bind($.jPlayer.event.pause, function(event) { // Add a listener to report the time pause began
        isPlaying = false;
        $pauseButton.hide();
        $playButton.show();
      });

      $slides.click(function(event){
        $jPlayerObj.jPlayer("play");
      });

      $playButton.click(function(event){
        $jPlayerObj.jPlayer("play");
      });

      $pauseButton.click(function(event){
        $jPlayerObj.jPlayer("pause");
      });

      $timeline.click(function(event){
        var l = event.pageX -  $(this).offset().left;
        var t = (l / $that.width()) * audioDurationinSeconds;

        $jPlayerObj.jPlayer("play", t);
      });

      setAudioSlide(0);

      function setAudioSlide(n){
        if(n != currentSlide){
          if($slides.get(currentSlide)){
            $($slides.get(currentSlide)).fadeOut();
          }

          $($slides.get(n)).fadeIn();
          currentSlide = n;
        }
      }

    });
  };
}(jQuery));