(function(window){
  "use strict";

  window.PointGaming.views.user_points_index = window.PointGaming.views.base.extend({

    initialize: function(){
      this.graph_parent_selector = '#graph';
      this.graph_config = { width: 1000, height: 200 };
      this.loadGraphData();
    },
    
    bindEvents: function() {
      var self = this;
      $(window).resize(function(){
        self.reRenderGraph();
      });
    },

    reconfigureGraph: function(){
      this.graph_config.width = $(this.graph_parent_selector).width();
    },

    loadGraphData: function(){
      var self = this;

      d3.json(window.location.href + '.json', function(error, data) {
        if (!error) {
          self.graph_data = data;
          self.renderGraph();
        }
      });
    },

    reRenderGraph: function() {
      $(this.graph_parent_selector + ' svg').remove();
      this.renderGraph();
    },

    renderGraph: function() {
      var graph_data = this.graph_data;

      this.reconfigureGraph();

      if (typeof graph_data === 'undefined') return;

      // define dimensions of graph
      var m = [10, 30, 15, 60]; // margins
      var w = this.graph_config.width - m[1] - m[3]; // width
      var h = this.graph_config.height - m[0] - m[2]; // height

      var startTime = new Date(graph_data.start_datetime);
      var endTime = new Date(graph_data.end_datetime);

      // define the x and y scale based on the supplied data
      var x = d3.time.scale().domain([startTime, endTime]).range([0, w]);
      x.tickFormat(d3.time.format("%Y-%m-%d"));
      var min_points = d3.min(graph_data.data, function(d) { return d.value; });
      var max_points = d3.max(graph_data.data, function(d) { return d.value; });
      var y = d3.scale.linear().domain([min_points, max_points]).range([h, 0]);

      // create a line function that will be used to plot data onto the graph
      var line1 = d3.svg.line()
        // this function determines the x coordinate to use when plotting point d
        .x(function(d,i) { 
          return x(new Date(d.time).getTime()); 
        })
        // this function determines the y coordinate to use when plotting point d
        .y(function(d) { 
          return y(d.value);
        });

      // Add an SVG element with the desired dimensions and margin.
      var graph = d3.select(this.graph_parent_selector).append("svg:svg")
            .attr("width", w + m[1] + m[3])
            .attr("height", h + m[0] + m[2])
          .append("svg:g")
            .attr("transform", "translate(" + m[3] + "," + m[0] + ")");

      // create xAxis
      var xAxis = d3.svg.axis().scale(x).tickSize(-h).tickSubdivide(1);
      // add the xAxis to the svg graph
      graph.append("svg:g")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + h + ")")
            .call(xAxis);

      // create left yAxis
      var yAxis = d3.svg.axis().scale(y).ticks(6).orient("left");
      // add the yAxis to the svg graph
      graph.append("svg:g")
            .attr("class", "y axis")
            .attr("transform", "translate(-10,0)")
            .call(yAxis);

      // add the line to the svg graph
      graph.append("svg:path").attr("d", line1(graph_data.data)).attr("class", "data1");
    }

  });

})(window);
