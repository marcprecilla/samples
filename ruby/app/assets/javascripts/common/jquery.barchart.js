(function( $ ) {

  $.fn.barChart = function( options ) {

    var settings = {
      content_container_selector: ".barchart-content",
      data_container_selector: ".barchart-data",
      bars_container_selector: ".bars-container",
      y_increment: 25,
      x_increment: 86400 * 1000, //day increment
      x_increment_width: 8,
      bar_width: 5,
      y_max_value: 200,
      week_container_width: 75,
      num_weeks_in_container: 4
    };

    if(options){
      jQuery.extend(settings,options);
    }

    // Begin to iterate over the jQuery collection that the method was called on
    return this.each(function () {

      var data = [];
      var data_max_value = 0;
      var y_max_value = settings.y_max_value;
      var num_y_increments = 0;
      var bar_container_width = $(this).find(settings.content_container_selector).width() - 20;
      var bar_container_height = $(this).find(settings.content_container_selector).height();
      var week_container_width = settings.week_container_width;
      var num_weeks_in_container = settings.num_weeks_in_container;
      var x_min_value = new Date().getTime();
      var x_max_value = 0;
      var num_x_increments = 0;
      var days_of_week = new Array('S','M','T','W','R','F','S');
      var start_timestamp = 0;
      var end_timestamp = 0;

      //alert(bar_container_width)
      var num_x_increments_viewport = Math.floor(bar_container_width / settings.x_increment_width);
      var num_x_increments_data = 0;

      retrieveData(this);
      renderYAxis(this);
      renderXAxis(this);
      renderBars(this);
      renderHeader(this);

      function compare(a,b) {
        if (a.timestamp < b.timestamp)
           return -1;
        if (a.timestamp > b.timestamp)
          return 1;
        return 0;
      }

      function reversecompare(a,b) {
        if (a.timestamp > b.timestamp)
           return -1;
        if (a.timestamp < b.timestamp)
          return 1;
        return 0;
      }

      function retrieveData(dom_object) {
        //retrieve data
        $(dom_object).find(settings.data_container_selector + ' li').each(function(index,el){
          var $el = $(el);
          var el_value = parseInt($el.text());
          var el_prev_value = parseInt($el.attr('data-previous-value'));
          var el_timestamp = $el.attr('data-timestamp');
          var el_dateobject = new Date(el_timestamp*1000);
          var el_color_class = "gray";

          /*
          if(el_value >= 200) {
            el_color_class = "green";
          } else if (el_value >= 100) {
            el_color_class = "lime";
          } else if (el_value >= 75) {
            el_color_class = "yellow";
          } else if (el_value >= 50) {
            el_color_class = "orange";
          } else if (el_value >= 25) {
            el_color_class = "red";
          }
          */
          if (el_value >= 25) {
            //el_color_class = "gradient";
            el_color_class = "blue";
          }

          data.push({
            timestamp:$el.attr('data-timestamp'),
            label:((el_dateobject.getMonth() + 1) + '/' + el_dateobject.getDate()),
            value:el_value,
            prev_value:el_prev_value,
            color_class:el_color_class
          });
          if(el_value > data_max_value) {
            data_max_value = el_value;
          }

          if(el_timestamp < x_min_value) {
            x_min_value = el_timestamp;
          }

          if(el_timestamp > x_max_value) {
            x_max_value = el_timestamp;
          }
        });
        //alert(x_max_value)

        //normalize
        if (settings.y_max_value < 100) {
          y_max_value = Math.ceil(data_max_value);
        }
        x_min_value = x_min_value * 1000; //milleseconds
        x_max_value = x_max_value * 1000; //milleseconds

        var x_min_raw_dateobject = new Date(x_min_value);
        var x_max_raw_dateobject = new Date(x_max_value);
        var x_min_dateobject = new Date(x_min_raw_dateobject.getFullYear(), x_min_raw_dateobject.getMonth(), x_min_raw_dateobject.getDate());
        var x_max_dateobject = new Date(x_max_raw_dateobject.getFullYear(), x_max_raw_dateobject.getMonth(), x_max_raw_dateobject.getDate());
        x_min_value = x_min_dateobject.getTime();
        x_max_value = x_max_dateobject.getTime();
        num_x_increments = Math.ceil((x_max_value - x_min_value)/settings.x_increment);

        num_x_increments_data = Math.ceil((x_max_value - x_min_value) / settings.x_increment);
        if (num_x_increments_viewport > num_x_increments_data || true) {
          x_min_value = (x_max_value - (num_x_increments_viewport * settings.x_increment));
        } else {
          bar_container_width = num_x_increments_data * settings.x_increment_width;
          $(dom_object).find(settings.bars_container_selector).width(bar_container_width);
          $(dom_object).find(settings.content_container_selector).width(bar_container_width);
        }

        num_y_increments = y_max_value / settings.y_increment;

        //find plot points
        for (var key in data) {
          if (data.hasOwnProperty(key)) {
            var height = Math.round(data[key]['value'] / y_max_value * bar_container_height);
            if (height == 0) {
              height = 2;
            } else if (data[key]['value'] > 200) {
              height = Math.round(200 / y_max_value * bar_container_height);
            }
            data[key]['height'] = height;
            data[key]['prev_height'] = Math.round(data[key]['prev_value'] / y_max_value * bar_container_height);
          }
        }

        data.sort(reversecompare);

        if(data.length > 0) {
          start_timestamp = data[data.length - 1]['timestamp'];
          final_timestamp = data[0]['timestamp'];
          num_increments = Math.ceil((final_timestamp - start_timestamp) / (7*24*60*60));
          end_timestamp = parseInt(start_timestamp) + (num_increments * 7*24*60*60); //calculate for full week
        }
      }

      function renderHeader(dom_object) {

        var has_more_than_one_page = 0;
        if((end_timestamp - start_timestamp) > (num_weeks_in_container*7*24*60*60)) {
          has_more_than_one_page = 1;
        }

        var header_html = "<div class=\"header-row\">";
        if (has_more_than_one_page) {
          header_html += "<a href=\"#\" class=\"arrow-left\">&lt;</a>";
        } else {
          header_html += "<a href=\"#\" class=\"arrow-left disabled\">&lt;</a>";
        }
        header_html += "<span>Last " + num_weeks_in_container + " Weeks</span>";
        header_html += "<a href=\"#\" class=\"arrow-right disabled\">&gt;</a></div>";
        $(dom_object).prepend(header_html);

        $(dom_object).find('.header-row .arrow-left').click(function(e) {
          current_index = parseInt($(dom_object).attr('data-curr-page-index'));
          next_index = current_index + 1;
          e.preventDefault();
          e.stopPropagation();
          if($(dom_object).find('.page-increment-container:eq(' + next_index + ')').length > 0) {
            $(dom_object).find('.page-increment-container').hide();
            $(dom_object).find('.page-increment-container:eq(' + next_index + ')').show();
            $(dom_object).attr('data-curr-page-index',next_index);

            $(dom_object).find('.header-row span').text($(dom_object).find('.page-increment-container:eq(' + next_index + ')').attr('data-nav-title'));

            $(dom_object).find('.header-row .arrow-right').removeClass('disabled');
            next_index += 1;
            if($(dom_object).find('.page-increment-container:eq(' + next_index + ')').length <= 0) {
              $(this).removeClass('disabled').addClass('disabled');
            }
          }
        });

        $(dom_object).find('.header-row .arrow-right').click(function(e) {
          current_index = parseInt($(dom_object).attr('data-curr-page-index'));
          previous_index = current_index - 1;
          e.preventDefault();
          e.stopPropagation();
          if(previous_index >= 0 && $(dom_object).find('.page-increment-container:eq(' + previous_index + ')').length > 0) {
            $(dom_object).find('.page-increment-container').hide();
            $(dom_object).find('.page-increment-container:eq(' + previous_index + ')').show();
            $(dom_object).attr('data-curr-page-index',previous_index);

            $(dom_object).find('.header-row span').text($(dom_object).find('.page-increment-container:eq(' + previous_index + ')').attr('data-nav-title'));

            $(dom_object).find('.header-row .arrow-left').removeClass('disabled');
            previous_index -= 1;
            if(previous_index < 0 || $(dom_object).find('.page-increment-container:eq(' + previous_index + ')').length <= 0) {
              $(this).removeClass('disabled').addClass('disabled');
            }
          }
        });
      }

      function renderBars(dom_object) {
        var container_index = Math.ceil((end_timestamp - start_timestamp) / (num_weeks_in_container * 7*24*60*60));
        var week_index = Math.ceil((end_timestamp - start_timestamp) / (7*24*60*60));
        var container_ago_index = 0;
        var bars_html = "<div class=\"page-increment-container\" data-nav-title=\"Last " + num_weeks_in_container  + " Weeks\" style=\"display:block;\"><div class=\"week-container\" data-week-num=\"" + week_index  + "\"><label>This Week</label>";
        var container_increment = num_weeks_in_container * 7*24*60*60;
        var week_increment = 7*24*60*60;
        var container_start_timestamp = end_timestamp - container_increment;
        var week_start_timestamp = end_timestamp - week_increment;
        for (var key in data) {
          if (data.hasOwnProperty(key)) {

            //console.log(data[key]['timestamp'] + ':' + container_end_timestamp);
            if(data[key]['timestamp'] < container_start_timestamp) {
              container_index--;
              week_index--;
              container_ago_index++;
              bars_html += "</div></div><div class=\"page-increment-container\" data-nav-title=\"Last " + (container_ago_index * num_weeks_in_container + 1) + " - " +  ((container_ago_index + 1) * num_weeks_in_container) + " Weeks\"><div class=\"week-container\" data-week-num=\"" + week_index  + "\"><label>Week " + week_index + "</label>";
              container_start_timestamp -= container_increment;
              week_start_timestamp -= week_increment;
            } else if(data[key]['timestamp'] < week_start_timestamp) {
              week_index--;
              bars_html += "</div><div class=\"week-container\" data-week-num=\"" + week_index  + "\"><label>Week " + week_index + "</label>";
              week_start_timestamp -= week_increment;
            }

            //current bar
            var today = new Date().getTime();
            var is_current = 0;
            if(Math.abs((data[key]['timestamp'] * 1000) - today) < 86400000) {
              is_current = 1;
            }
            var additional_classes = data[key]['color_class'];

            var bar_x_pos = Math.ceil(((((data[key]['timestamp'] * 1000) - (week_start_timestamp * 1000)) / settings.x_increment) * settings.x_increment_width));
            bar_x_pos -= Math.round((settings.x_increment_width - settings.bar_width) / 2); //center
            //bars_html += "<div class=\"bar-group\" style=\"height:" + bar_container_height + "px; position:absolute; top:0px; left:" + bar_x_pos + "px\"><div class=\"bar\" style=\"height:" + data[key]['height'] + "px\"><span>" + data[key]['value'] + "</span><span class=\"label\">" + data[key]['label'] + "</span></div></div>";
            bars_html += "<div class=\"bar-group bar-" + data[key]['timestamp'] + "\" style=\"height:" + bar_container_height + "px; position:absolute; top:0px; left:" + bar_x_pos + "px\">";

            if (is_current) {
              bars_html += "<div class=\"bar " + additional_classes + " current-bar\" style=\"height:0px\" data-target-height=" + data[key]['height'] + "><span class=\"current-bar\" style=\"height:0px\" data-target-height=" + data[key]['height'] + ">&nbsp;<div class=\"score-indicator\">" + data[key]['value'] + "</div></span></div>";
            } else {
              bars_html += "<div class=\"bar " + additional_classes + "\" style=\"height:" + data[key]['height'] + "px\"><span style=\"height:" + data[key]['height'] + "px\">&nbsp;<div class=\"score-indicator\">" + data[key]['value'] + "</div></span></div>";
            }
            /*
            if (data[key]['value'] > data[key]['prev_value']) {
              bars_html += "<div class=\"bar " + data[key]['color_class'] + "\" style=\"height:" + data[key]['height'] + "px\"><span style=\"height:" + data[key]['height'] + "px\">&nbsp;<div class=\"score-indicator\">" + data[key]['value'] + "</div></span></div>";
              bars_html += "<div class=\"bar prev flat" + data[key]['color_class'] + "\" style=\"height:" + data[key]['prev_height'] + "px\"><span>&nbsp;</span></div>";
            } else {
              bars_html += "<div class=\"bar prev" + data[key]['color_class'] + "\" style=\"height:" + data[key]['height'] + "px\"><span style=\"height:" + data[key]['height'] + "px\">&nbsp;<div class=\"score-indicator\">" + data[key]['value'] + "</div></span></div>";
            }
            */
            bars_html += "</div>";
          }
        }
        bars_html += '</div></div><br class="clearboth" />';
        settings_bars_container_selector = $(dom_object).find(settings.bars_container_selector);
        if(settings_bars_container_selector.length) {
          settings_bars_container_selector.html(bars_html);
        } else {
          bars_html = "<div class=\"" + settings.bars_container_selector.substring(1) + "\">" + bars_html + "</div>";
          $(dom_object).find(settings.content_container_selector).prepend(bars_html);
        }
      }

      function renderXAxis(dom_object) {

        return true; //disable

        var x_axis_html = "";
        var x_curr_index = 0;
        for (var i=x_max_value; i >= x_min_value; i-=settings.x_increment) {
          var curr_dateobject = new Date(i);
          //alert(i + ':' + days_of_week[curr_dateobject.getUTCDay()] + ':' + ((curr_dateobject.getUTCMonth() + 1) + '/' + curr_dateobject.getUTCDate() + '/' + curr_dateobject.getUTCFullYear() + '/' + curr_dateobject.getUTCHours() + ':' + curr_dateobject.getUTCMinutes()))
          x_axis_html += "<li style=\"width:" + settings.x_increment_width + "px; position:absolute; top:0px; left:" + Math.ceil(bar_container_width - (x_curr_index * settings.x_increment_width)) + "px;\"><span>" + days_of_week[curr_dateobject.getUTCDay()];
          if(curr_dateobject.getUTCDay() == 1) {
            x_axis_html += "<br />" + ((curr_dateobject.getUTCMonth() + 1) + '/' + curr_dateobject.getUTCDate());
          } else {
            x_axis_html += "<br />&nbsp;";
          }
          x_axis_html += "</span></li>";
          x_curr_index++;
        }
        x_axis_selector = $(dom_object).find('.x-axis');
        if(x_axis_selector.length) {
          x_axis_selector.html(x_axis_html);
        } else {
          $(dom_object).find(settings.content_container_selector).prepend("<ul class=\"x-axis\" style=\"\">" + x_axis_html + "</ul>");
        }
        //$(dom_object).find('.x-axis').width($(dom_object).find(settings.content_container_selector).outerWidth());
      }

      function renderYAxis(dom_object) {
        var increment_height = bar_container_height / num_y_increments;
        var y_axis_html = "";
        for (var i=num_y_increments; i >= 0; i--) {
          if (i == (num_y_increments / 2) || i == num_y_increments) {
            y_axis_html += "<li class=\"darkborder\" style=\"height:" + (increment_height - 1) + "px\"><span>" + (settings.y_increment * i) + "</span></li>";
          } else {
            y_axis_html += "<li style=\"height:" + (increment_height - 1) + "px\"><span>" + (settings.y_increment * i) + "</span></li>";
          }
        }

        y_axis_selector = $(dom_object).find('.y-axis');
        if(y_axis_selector.length) {
          y_axis_selector.html(y_axis_html);
        } else {
          $(dom_object).prepend("<ul class=\"y-axis\" style=\"height:" + bar_container_height + "px\">" + y_axis_html + "</ul>");
        }
        //$(dom_object).find('.y-axis').width($(dom_object).find(settings.content_container_selector).outerWidth());
      }


    });
  };
}(jQuery));