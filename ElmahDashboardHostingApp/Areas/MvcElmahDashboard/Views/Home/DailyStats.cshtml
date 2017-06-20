@model $rootnamespace$.Areas.MvcElmahDashboard.Models.Home.DailyStatsModel
@{
    Layout = null;
    Response.Cache.SetExpires(DateTime.Now.AddDays(1));
    Response.Cache.SetCacheability(HttpCacheability.NoCache);
    var iv = System.Globalization.CultureInfo.InvariantCulture;
    var dateFormat = System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat.ShortDatePattern.Replace("yyyy", "yy").ToUpperInvariant();
    var dateFormatDmNet = (dateFormat.IndexOf("D") < dateFormat.IndexOf("M")) ? "dd/MM" : "MM/dd";
    var dateFormatDmJs = dateFormatDmNet.ToUpperInvariant();
    string cj = ViewBag.chartData;
    int daychart = ViewBag.DayChart;

    string pieChart = ViewBag.pieData;
    List<$rootnamespace$.Areas.MvcElmahDashboard.Code.ErrorUserDate> user_error = ViewBag.UersError as List<$rootnamespace$.Areas.MvcElmahDashboard.Code.ErrorUserDate>;
    string user_chart = ViewBag.userChart;
}

@if (!Request.Browser.IsMobileDevice)
{
    <div data-moveto="#content-timetable">
        <div class="col-md-12">
            <div class="thumbnail">
                <table class="table table-condensed">
                    <thead class="hourlabel">
                        <tr>
                            @for (DateTime dt = Model.RangeStart; dt < Model.RangeEnd; dt = dt.AddDays(1))
                            {
                                <th><span data-utctime="@(dt.Epoch())" data-format="@(dateFormatDmJs)">@(dt.ToString(dateFormatDmNet))</span>-<span data-utctime="@(dt.AddDays(1).Epoch())" data-format="@(dateFormatDmJs)">@(dt.AddDays(1).ToString(dateFormatDmNet))</span></th>
                            }
                        </tr>
                    </thead>
                    <tbody class="hourvalue">
                        <tr>
                            @foreach (var value in Model.DailyCounters)
                            {
                                <td>@(value == 0 ? "-" : value.ToString())</td>
                            }
                        </tr>
                    </tbody>
                </table>
                <div class="legend">Error count/day - Last 14 days - Most recent value on the right side</div>
            </div>
        </div>
        @if (!Request.Browser.IsMobileDevice)
        {
            <div class="col-md-12">
                <div class="thumbnail">
                    <div id='chart4'>
                        <svg style='height:400px'> </svg>
                        <div class="legend">Chart error type - Last @daychart days</div>
                    </div>
                </div>
            </div>
            <script>
        var _data = lineFocus(); // testData();
        nv.addGraph(function () {
            var chart = nv.models.lineWithFocusChart()
            .margin({ "bottom": 50 })
            //.useInteractiveGuideline(true)
            .x(function (d) { return d.x })
            .y(function (d) { return d.y })
            .showLegend(true)
            .showYAxis(true)
            .showXAxis(true);

            chart.xAxis
                //.axisLabel('Date')
                .rotateLabels(-45)
                .tickFormat(function (d) {
                    //return d3.time.format('%Y-%m-%d')(new Date(d));
                    var tx = " ";
                    if(_data[0].values[d] !== undefined)
                        tx = _data[0].values[d].text;
                    return tx;
                });

            chart.x2Axis
                .tickFormat(function (d) {
                    var tx = " ";
                    if (_data[0].values[d] !== undefined)
                        tx = _data[0].values[d].text.substr(8, 2);
                    return tx;
                });

            chart.yAxis
                .axisLabel('Error No')
                .tickFormat(d3.format(',.0f'));

            chart.y2Axis
                .tickFormat(d3.format(',.0f'));

            d3.select('#chart2 svg')
                .datum(_data)
                .transition().duration(500)
                .call(chart);

            nv.utils.windowResize(chart.update);

            return chart;
        });

        function lineFocus() {
            var tx = '@Html.Raw(cj)';
            return JSON.parse(tx);
        }

        //piechart
        nv.addGraph(function () {
            var chart = nv.models.pieChart()
                .x(function (d) { return d.label })
                .y(function (d) { return d.value })
                .showLabels(true)     //Display pie labels
                .labelThreshold(1)  //Configure the minimum slice size for labels to show up
                .labelType("percent") //Configure what type of data to show in the label. Can be "key", "value" or "percent"
                .donut(true)          //Turn on Donut mode. Makes pie chart look tasty!
                .donutRatio(0.35)     //Configure how big you want the donut hole size to be.
            ;
            chart.tooltip.valueFormatter(function (d) { return d > 0 ? d : 0; });
            var _pdata = pieData();
            //console.log(_pdata);
            d3.select("#chart3 svg")
                .datum(_pdata)
                .transition().duration(350)
                .call(chart);

            return chart;
        });
        function pieData() {
            var tx = '@Html.Raw(pieChart)';
            console.log(tx);
            return JSON.parse(tx);
        }

        //group chart
        nv.addGraph(function () {
            var chart = nv.models.multiBarChart()
              //.transitionDuration(350)
              .reduceXTicks(true)   //If 'false', every single x-axis tick label will be rendered.
              .rotateLabels(0)      //Angle to rotate x-axis labels.
              .showControls(true)   //Allow user to switch between 'Grouped' and 'Stacked' mode.
              .groupSpacing(0.1)    //Distance between each group of bars.
              .stacked(true)
            ;

            chart.xAxis
                .rotateLabels(-45)
                .tickFormat(function (d) {
                    //return d3.time.format('%Y-%m-%d')(new Date(d));
                    var tx = " ";
                    if (_data[0].values[d] !== undefined)
                        tx = _data[0].values[d].text.substr(5, 5);
                    return tx;
                });

            chart.yAxis
                .tickFormat(d3.format(',f'));

            d3.select('#chart4 svg')
                .datum(_data)
                .call(chart);

            nv.utils.windowResize(chart.update);

            return chart;
        });

        //user chart
        nv.addGraph(function () {
            var chart = nv.models.pieChart()
                .x(function (d) { return d.label })
                .y(function (d) { return d.value })
                .showLabels(true);
            chart.tooltip.valueFormatter(function (d) { return d > 0 ? d : 0; });
            var _p2data = userData();
            //_p2data.push({ lable: "x", value: 10 });
            d3.select("#chart5 svg")
                .datum(_p2data)
                .transition().duration(350)
                .call(chart);

            return chart;
        });
        function userData() {
            var tx = '@Html.Raw(user_chart)';
            //tx.push({ lable: "x", value: 0 });
            console.log(tx);
            return JSON.parse(tx);
        }
            </script>
        }

        <div class="col-md-12">
            <div class="col-md-4">
                <div class="thumbnail">
                    <div id='chart3'>
                        <svg style='height:400px'> </svg>
                        <div class="legend">Top 5 types error - Last @daychart days</div>
                    </div>
                </div>
            </div>
            <div class="col-md-8">
                <div class="thumbnail">
                    <div id='chart2'>
                        <svg style='height:450px'> </svg>
                    </div>
                    <div class="legend">Chart error type per day - Last @daychart days</div>
                </div>
            </div>
        </div>
    </div>
}

<div data-moveto="#content-errorcounter">
    <div><span data-utctime="@(Model.Timestamp.AddDays(-1).Epoch())" data-format="@(dateFormat) hh:mm:ss">@(Model.Timestamp.AddHours(-1))</span> - <span data-utctime="@(Model.Timestamp.Epoch())" data-format="@(dateFormat) hh:mm:ss">@(Model.Timestamp)</span></div>
    <div class="text-center lastvalue">@(Model.LastDayErrors.Count)</div>
    <div class="legend">Error count - Last 24 hours</div>
</div>

<div data-moveto="#content-timegraph">
    <canvas id="graphLast14d" width="900" height="300" data-background="#E0FFE0" data-fill-style="#808080" data-font="28px sans-serif">
        <table class="table table-condensed">
            <tbody>
                <tr data-graph-style="bars">
                    <th></th>
                    @for (int i = 0; i < Model.DailyCounters.Count(); i++)
                    {
                        <td data-fill-style="rgb(@(210-i*7),@(210-i*14),@(210-i*14))">@(Model.DailyCounters[i])</td>
                    }
                </tr>
            </tbody>
        </table>
    </canvas>
    <div class="legend">Error count/day - Last 14 days</div>
</div>


<div data-moveto="#content-sample">
    <h4>Most recent errors</h4>
    <table class="table table-hover table-striped table-condensed">
        <thead>
            <tr style="background-color: #e0e0e0;">
                <th>Seq</th>
                <th>Time</th>
                <th>App</th>
                <th>Host</th>
                <th>Source</th>
                <th>Type</th>
                <th>Message</th>
            </tr>
        </thead>
        <tbody>
            @Html.Action("Items", new { controller = "Logs", offset = 0, length = Model.SampleLogCount, truncValueLength = 60 })
        </tbody>
    </table>
    <div class="legend">@(Model.SampleLogCount) latest errors. <a href="@Url.Action("Index", "Logs")">See logs</a> for more.</div>
</div>

<div data-moveto="#content-usererror">
    <div class="col-sm-6">
        <h4>Top user made error</h4>
        <table class="table table-striped table-condensed">
            <tr>
                <th>User</th>
                <th>Error</th>
            </tr>
            @foreach (var item in user_error)
            {
                <tr>
                    <td>@item.User</td>
                    <td>@item.Counts</td>
                </tr>
            }
        </table>
    </div>
    <div class="col-sm-6">
        <div id='chart5'>
            <svg style='height:350px'> </svg>
        </div>
    </div>
    <div class="legend">Error count/user</div>
</div>

<div data-moveto="#content-perapp">
    <h4>Per Application</h4>
    <table class="table table-striped table-condensed">
        <tbody>
            @foreach (var pair in Model.AppDailyCounters.OrderBy(p => p.Key))
            {
                <tr>
                    <th width="99%">@Html.ActionLink(pair.Key, "Index", new { controller = "Logs", application = pair.Key })</th>
                    @for (int i = 0; i < pair.Value.Length; i++)
                    {
                        <td class="hourvalue@(i)">@(pair.Value[i])</td>
                    }
                </tr>
            }
        </tbody>
    </table>
    <div class="legend">Error count/application/day - Last 4 days</div>
</div>
