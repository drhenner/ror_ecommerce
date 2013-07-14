var Hadean = window.Hadean || {};

// If we already have the Admin namespace don't override
if (typeof Hadean.Admin == "undefined") {
    Hadean.Admin = {};
}
var dataSet = null;
if (typeof Hadean.Admin.weeklySalesChart == "undefined") {
  Hadean.Admin.weeklySalesChart = {
    initialize      : function(){
      jQuery.ajax( {
         type : "GET",
         url : "/admin/reports/weekly_charts/",
         success : function(json) {
          // amountData = [];
          // $.each( dataSet, function(i, val) {  amountData.push( [val.date, val.amount] )})
          Hadean.Admin.weeklySalesChart.createSalesGraph(json);
          Hadean.Admin.weeklySalesChart.createEarningsGraph(json);
         },
         dataType : 'json'
      });
    },
    createSalesGraph : function(dataSet){
      new Morris.Bar({
        // ID of the element in which to draw the chart.
        element: 'weekly-sales-graph',
        // Chart data records -- each entry in this array corresponds to a point on
        // the chart.
        data: dataSet,
        // The name of the data record attribute that contains x-values.
        xkey: 'date',
        // A list of names of data record attributes that contain y-values.
        ykeys: ['sales'],
        // Labels for the ykeys -- will be displayed when you hover over the
        // chart.
        labels: ['Sales']
      });
    },
    createEarningsGraph : function(dataSet) {
      new Morris.Line({
        // ID of the element in which to draw the chart.
        element: 'weekly-earnings-graph',
        // Chart data records -- each entry in this array corresponds to a point on
        // the chart.
        data: dataSet,
        // The name of the data record attribute that contains x-values.
        xkey: 'date',
        // A list of names of data record attributes that contain y-values.
        ykeys: ['amount'],
        // Labels for the ykeys -- will be displayed when you hover over the
        // chart.
        labels: ['Earnings']
      });
    }
  };
  jQuery(function() {
    Hadean.Admin.weeklySalesChart.initialize();
  });
}
