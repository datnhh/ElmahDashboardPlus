@model $rootnamespace$.Areas.MvcElmahDashboard.Models.Home.HourlyStatsModel
@{
    Layout = null;
    Response.Cache.SetExpires(DateTime.Now.AddDays(1));
    Response.Cache.SetCacheability(HttpCacheability.NoCache);
    var iv = System.Globalization.CultureInfo.InvariantCulture;
}
@if (!Request.Browser.IsMobileDevice)
{
    <div data-moveto="#content-timetable">
        <div class="col-md-12">
            <div class="thumbnail">
                <table class="table table-condensed">
                    <thead class="hourlabel">
                        <tr>
                            @for (DateTime dt = Model.RangeStart; dt < Model.RangeEnd; dt = dt.AddHours(1))
                            {
                                <th><span data-utctime="@(dt.Epoch())" data-format="hh">@(dt.Hour.ToString("00"))</span>-<span data-utctime="@(dt.AddHours(1).Epoch())" data-format="hh">@((dt.Hour + 1).ToString("00"))</span></th>
                            }
                        </tr>
                    </thead>
                    <tbody class="hourvalue">
                        <tr>
                            @foreach (var value in Model.HourlyCounters)
                            {
                                <td>@(value == 0 ? "-" : value.ToString())</td>
                            }
                        </tr>
                    </tbody>
                </table>
                <div class="legend">Error count/hour - Last 24 hours - Most recent value on the right side</div>
            </div>
        </div>
    </div>
}

<div data-moveto="#content-errorcounter">
    <div><span data-utctime="@(Model.Timestamp.AddHours(-1).Epoch())" data-format="hh:mm:ss">@(Model.Timestamp.AddHours(-1))</span> - <span data-utctime="@(Model.Timestamp.Epoch())" data-format="hh:mm:ss">@(Model.Timestamp)</span></div>
    <div class="text-center lastvalue">@(Model.LastHourErrors.Count)</div>
    <div class="legend">Error count - Last 60 minutes</div>
</div>

<div data-moveto="#content-timegraph">
    <canvas id="graphLast24h" width="900" height="300" data-background="#E0FFE0" data-fill-style="#808080" data-font="28px sans-serif">
        <table class="table table-condensed">
            <tbody>
                <tr data-graph-style="bars">
                    <th></th>
                    @for (int i = 0; i < Model.HourlyCounters.Count(); i++)
                    {
                        <td data-fill-style="rgb(@(200-i*4),@(200-i*8),@(200-i*8))">@(Model.HourlyCounters[i])</td>
                    }
                </tr>
            </tbody>
        </table>
    </canvas>
    <div class="legend">Error count/hour - Last 24 hours</div>
</div>

<div data-moveto="#content-usererror">
    <div></div>
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

<div div data-moveto="#content-perapp">
    <h4>Per Application</h4>
    <table class="table  table-striped table-condensed">
        <tbody>
            @foreach (var pair in Model.AppHourlyCounters.OrderBy(p => p.Key))
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
    <div class="legend">Error count/application/hour - Last 4 hours</div>
</div>
