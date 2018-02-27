var endpoint = 'ci/data/';
$.ajax({
  method: "GET",
  url: endpoint,
  success: function(data){
    var finalData = prepare_data_for_charts(data);
    var passed = getPassed(finalData);
    var failed = getFailed(finalData);
    var dates = getDates(finalData);
    var duration = getDuration(finalData);
    var outliersFailed = findOutliers(failed);

    createStackedBarChart(passed, failed, dates);
    createOutliersFailedChart(outliersFailed, dates);
    createDurationTimeChart(duration, dates);
  }
});

var prepare_data_for_charts = function(initialData){
  var finalData = {};
  initialData.forEach(function(element){
    var date = element.created_at.slice(0,10);
    if (!(date in finalData)) {
      finalData[date] = {
        passed: 0,
        failed: 0,
        duration: 0.0
      };
    }
    var duration = element.duration;
    finalData[date].duration += parseFloat(duration);
    var status = element.summary_status;
    if (status === 'passed') {
      finalData[date].passed++;
    } else if (status === 'failed') {
      finalData[date].failed++;
    }
  });

  var keys = [];
  for (var item in finalData) {
    keys.push(item);
  }
  keys.sort();

  var sortedFinalData = {};
  keys.forEach(function(element){
    sortedFinalData[element] = finalData[element];
  });

  return sortedFinalData;
};

var getDates = function(finalData) {
  var dates = [];
  for (var element in finalData){
    dates.push(element);
  }
  return dates;
};

var getPassed = function(finalData) {
  var passed = [];
  for (var element in finalData) {
    passed.push(finalData[element].passed);
  }
  return passed;
};

var getFailed = function(finalData) {
  var failed = [];
  for (var element in finalData) {
    failed.push(finalData[element].failed);
  }
  return failed;
};


var getDuration = function(finalData) {
  var duration = [];
  for (var element in finalData) {
    duration.push(finalData[element].duration);
  }
  return duration;
};

var findOutliers = function(failed){

  var failedBuilds = failed.concat();

  // sort array of numbers failed builds
  failedBuilds.sort(function(a, b) {
    return a - b;
  });
  // find first quartile
  var q1 = failedBuilds[Math.floor(failedBuilds.length / 4)];
  // debugger;
  // find third quartile
  var q3 = failedBuilds[Math.ceil(failedBuilds.length * (3 / 4))];
  // find inter-quartile range
  var iqr = q3 - q1;

  // we find only max value, because we are interested only in high outliers
  var maxValue = q3 + iqr*1.5;

  var outliersFailed = failed.concat();
  for(var i=0;i<outliersFailed.length;i++){
    if(outliersFailed[i] < maxValue){
      outliersFailed[i] = 0;
    }
  }

  return outliersFailed;

};

var createStackedBarChart = function(dataPack1, dataPack2, dates) {

  var bar_ctx = document.getElementById('stacked-bar-chart');
  var bar_chart = new Chart(bar_ctx, {
      type: 'bar',
      data: {
          labels: dates,
          datasets: [
          {
              label: 'passed',
              data: dataPack1,
              backgroundColor: "rgba(55, 160, 225, 0.7)",
              hoverBackgroundColor: "rgba(55, 160, 225, 0.7)",
              hoverBorderWidth: 2,
              hoverBorderColor: 'lightgrey'
          },
          {
              label: 'failed',
              data: dataPack2,
              backgroundColor: "rgba(225, 58, 55, 0.7)",
              hoverBackgroundColor: "rgba(225, 58, 55, 0.7)",
              hoverBorderWidth: 2,
              hoverBorderColor: 'lightgrey'
          },
          ]
      },
      options: {
          animation: {
            duration: 10,
          },
          tooltips: {
            mode: 'label',
            callbacks: {
            label: function(tooltipItem, data) {
              return data.datasets[tooltipItem.datasetIndex].label + ": " + tooltipItem.yLabel;
            }
            }
           },
          scales: {
            xAxes: [{
              stacked: true,
              gridLines: { display: false },
              }],
            yAxes: [{
              stacked: true,
              ticks: {
                callback: function(value) { return value; },
              },
              }],
          }, // scales
          legend: {
            display: true,
            // position: 'right',
          },
          title: {
            display: true,
            text: 'Summary statuses for builds per day',
            fontSize: 25,
          }
      } // options
     }
  );
};

var createOutliersFailedChart = function(dataPack,dates) {

  var bar_ctx = document.getElementById('outliers-failed-chart');
  var bar_chart = new Chart(bar_ctx, {
      type: 'bar',
      data: {
          labels: dates,
          datasets: [
          {
              label: 'duration',
              data: dataPack,
              backgroundColor: "rgb(0, 230, 172)",
              hoverBackgroundColor: "rgb(0, 128, 0)",
              hoverBorderWidth: 2,
              hoverBorderColor: 'lightgrey'
          }
          ]
      },
      options: {
          animation: {
            duration: 10,
          },
          tooltips: {
            mode: 'label',
            callbacks: {
            label: function(tooltipItem, data) {
              return data.datasets[tooltipItem.datasetIndex].label + ": " + tooltipItem.yLabel;
            }
            }
           },
          scales: {
            xAxes: [{
              gridLines: { display: false },
              }],
            yAxes: [{
              stacked: true,
              ticks: {
                callback: function(value) { return value; },
              },
              }],
          }, // scales
          legend: {
            display: false,
          },
          title: {
            display: true,
            text: 'Outliers in Failed Builds',
            fontSize: 25
          }
      } // options
     }
  );
};







var createDurationTimeChart = function(dataPack,dates) {

  var bar_ctx = document.getElementById('duration-time-chart');
  var bar_chart = new Chart(bar_ctx, {
      type: 'line',
      data: {
          labels: dates,
          datasets: [
          {
              label: 'duration',
              data: dataPack,
              backgroundColor: "rgb(0, 230, 172)",
          }
          ]
      },
      options: {
          animation: {
            duration: 10,
          },
          tooltips: {
            mode: 'label',
            callbacks: {
            label: function(tooltipItem, data) {
              return data.datasets[tooltipItem.datasetIndex].label + ": " + tooltipItem.yLabel;
            }
            }
           },
          scales: {
            xAxes: [{
              gridLines: { display: false },
              }],
            yAxes: [{
              stacked: true,
              ticks: {
                callback: function(value) { return value; },
              },
              }],
          }, // scales
          legend: {
            display: false,
          },
          title: {
            display: true,
            text: 'Build duration vs time',
            fontSize: 25
          }
      } // options
     }
  );
};
