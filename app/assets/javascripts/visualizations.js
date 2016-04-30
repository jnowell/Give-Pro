
(function(d3) {
        'use strict';
        console.log("here we are");
        drawPieChart();
        drawLineChart();
   
    })(window.d3);

    function drawLineChart() {
      if (window.time_json == null) {
    		return;
      }
      var lineData = [];
      var count = 0;
      var time = new Date();
      console.log("time of "+window.time_json);
      for (var month in window.time_json) {
      	console.log("Month of "+month+" and json month of "+window.time_json[month]);
        var d = new Date(Number(month));
        var m = d.getMonth();
        var y = d.getYear();
        console.log("Date of "+d+"Month of "+m+" and year of "+y);
        var month_obj = { x: count, y: window.time_json[month], date: d }
        count++;
        lineData.push(month_obj);
      }

      // Set the dimensions of the canvas / graph
        var margin = {top: 30, right: 20, bottom: 30, left: 50},
          width = 300 - margin.left - margin.right,
          height = 200 - margin.top - margin.bottom;
         
        // Set the ranges
        var x = d3.time.scale().range([0, width]);
        var y = d3.scale.linear().range([height, 0]);
         
        // Define the axes
        var xAxis = d3.svg.axis().scale(x).tickFormat(d3.time.format('%b'))
          .orient("bottom").tickSize(5).tickSubdivide(true).tickValues([lineData[2].date,lineData[5].date,lineData[8].date,lineData[11].date]);
         
        var yAxis = d3.svg.axis().scale(y).tickFormat(d3.format("$"))
          .orient("left").tickSize(5).tickSubdivide(true);
         
        // Define the line
        var valueline = d3.svg.line()
          .x(function(d) { return x(d.date); })
          .y(function(d) { return y(d.y); })
          .interpolate('linear');;
            
        // Adds the svg canvas
        var svg = d3.select("#line_chart")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
          .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
         console.log("SVG of "+svg);
        // Scale the range of the data
        x.domain(d3.extent(lineData, function(d) { return d.date; }));
        y.domain([0, d3.max(lineData, function(d) { return d.y; })]);
       
        // Add the valueline path.
        svg.append("path")  
          .attr("class", "line")
          .attr("d", valueline(lineData));
       
        // Add the X Axis
        svg.append("g")   
          .attr("class", "x axis")
          .attr("transform", "translate(0," + height + ")")
          .call(xAxis);
       
        // Add the Y Axis
        svg.append("g")   
          .attr("class", "y axis")
          .call(yAxis);
    }

    function drawPieChart() {

      var data = [];
      var total = 0;

      for (var prop in window.sub_json) {
          var object = { label: prop, count: sub_json[prop]}
          data.push(object);
      }

      var tots = d3.sum(data, function(d) { 
            return d.count; 
        });

      data.forEach(function(d) {
          d.percentage = d.count  / tots;
      });

      var width = 200;
      var height = 200;
      var radius = Math.min(width, height) / 2;     

      var color = d3.scale.ordinal()
      .range(['#A60F2B', '#648C85', '#B3F2C9', '#528C18', '#C3F25C']); 
      
      //var pie_width = 500;
      //var pie_height = 500;

      var vis = d3.select('#pie_chart').append("svg:svg").data([data]).attr("width", width).attr("height", height).append("svg:g").attr("transform", "translate(" + radius + "," + radius + ")");
      var pie = d3.layout.pie().value(function(d){return d.count;});

      // declare an arc generator function
      var arc = d3.svg.arc().outerRadius(radius);

      // select paths, use arc generator to draw
      var arcs = vis.selectAll("g.slice").data(pie).enter().append("svg:g").attr("class", "slice");
      arcs.append("svg:path")
          .attr("fill", function(d, i){
              return color(i);
          })
          .attr("d", function (d) {
              // log the result of the arc generator to show how cool it is :)
              return arc(d);
          });

        
      // add the text
      arcs.append("svg:text").attr("transform", function(d){
              d.outerRadius = (2*radius)/3; // Set Outer Coordinate
              d.innerRadius = radius/3; // Set Inner Coordinate
              return "translate(" + arc.centroid(d) + ")"; })
              .attr("text-anchor", "middle").text( function(d, i) {
              return (data[i].percentage * 100).toFixed(0)+"%";}
              );
        

      var legend = d3.select("#pie_chart").append("svg")
        .attr("class", "legend")
        .attr("width", radius * 1.5)
        .attr("height", radius)
        .selectAll("g")
        .data(data)
        .enter().append("g")
        .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

      legend.append("rect")
        .attr("width", 18)
        .attr("height", 18)
        .style("fill", function(d, i) { return color(i); });

      legend.append("text")
        .attr("x", 24)
        .attr("y", 9)
        .attr("dy", ".35em")
        .text(function(d) { return d.label; });
    }