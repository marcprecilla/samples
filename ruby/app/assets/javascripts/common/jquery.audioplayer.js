(function( $ ) {

  $.fn.audioPlayer = function( options ) {

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

        $currentTime = $that.find(settings.currentTimeSelector),
        $duration = $that.find(settings.durationSelector),
        $playhead = $that.find(settings.playheadSelector),
        $timeline = $that.find(settings.timelineSelector),
        $playButton = $(settings.playSelector),
        $pauseButton = $(settings.pauseSelector),

        $buffering_container = $(settings.bufferingSelector),

        audioDurationinSeconds = parseInt($that.attr('data-audio-duration')),
        isPlaying = false;

      //$pauseButton.hide();


      var $jPlayerObj = $('<div></div>');
      $that.append($jPlayerObj);

      $jPlayerObj.jPlayer({
        ready: function () {
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

      });

      $jPlayerObj.bind($.jPlayer.event.progress, function(event) { // Add a listener to report the percent downloaded
        var p = parseInt(event.jPlayer.status.seekPercent) + "%";
        $buffering_container.html(p + " loaded");
        if(event.jPlayer.status.seekPercent >= 100) {
          $buffering_container.css("display","none");
        }
      });

      $jPlayerObj.bind($.jPlayer.event.play, function(event) { // Add a listener to report the time play began
        isPlaying = true;
        $playButton.hide();
        $pauseButton.show();
      });

      $jPlayerObj.bind($.jPlayer.event.pause, function(event) { // Add a listener to report the time pause began
        isPlaying = false;
        $pauseButton.hide();
        $playButton.show();
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

    });
  };
}(jQuery));