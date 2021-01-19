module ReportHelper
  def h_funnel id=nil, size=nil, data=nil, options={}
    html  = "<div id=\"container_funnel\" style=\"min-width: 310px; height: 400px; margin: 0 auto\"></div>".html_safe
    script = javascript_tag do
      <<-END.html_safe
        Highcharts.chart('container_funnel', {
          chart: {
            type: 'funnel'
          },
          title: {
            text: 'User Success Rate'
          },
          plotOptions: {
            series: {
              dataLabels: {
                enabled: true,
                format: '<b>{point.name}</b> ({point.y:,.0f})',
                color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black',
                softConnector: true
              },
              center: ['40%', '50%'],
              neckWidth: '30%',
              neckHeight: '25%',
              width: '80%'
            }
          },
          legend: {
            enabled: false
          },
          series: [{
            name: 'Unique users',
            data: [
              ['Website visits', 15654],
              ['User General Enquiries', 4064],
              ['Requested price list', 1987],
              ['Signup', 976],
              ['Timesheets submitted', 846]
            ]
          }]
      });
      END
    end
    return html + script
  end
end