@{
    ViewBag.Title = "Dashboard";
}
@section head
{
    <link href="~/Content/nv.d3.min.css" rel="stylesheet" />
    <script type="text/javascript" src="~/Scripts/d3/d3.min.js"></script>
    <script type="text/javascript" src="~/Scripts/nv.d3.min.js"></script>
    <script src="@(Url.Action("Index_scripts", new { v = Html.ScriptsVersion() }))"></script>
    @if (HeartBeatService.Default.IsMonitoring)
    {
        <script>
    $(function () {
        $("A[target='monitoredurl']").attr("href", "@(HeartBeatService.Default.CheckUrl)");
        @if (HeartBeatService.Default.DirectFromBrowser)
        {
            <text>heartBeat("@(HeartBeatService.Default.CheckUrl)", @((int)HeartBeatService.Default.CheckInterval.TotalSeconds));</text>
        }
        else
        {
            <text>heartBeat("@(Url.Action("Heartbeat"))", @((int)HeartBeatService.Default.CheckInterval.TotalSeconds));</text>
        }
    });
        </script>
    }
}

<div id="dashboard-content">

    <div class="btn-toolbar pull-right" role="toolbar">
        <div class="btn-group" role="group">
            <button type="button" data-value="h" class="btn btn-default timespan-toggle-cmd">Hourly</button>
            <button type="button" data-value="d" class="btn btn-default timespan-toggle-cmd">Daily</button>
        </div>
        <div class="btn-group">
            <button type="button" class="btn btn-default autorefresh-toggle-cmd unset"><span class="glyphicon glyphicon-ok"></span> Auto-refresh</button>
            <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                <span class="caret"></span>
            </button>
            <ul class="dropdown-menu dropdown-menu-right" role="menu">
                <li><a href="null" class="unset set-refresh-interval-cmd" data-value="30"><span class="glyphicon glyphicon-ok"></span> 30 seconds</a></li>
                <li><a href="null" class="unset set-refresh-interval-cmd" data-value="120"><span class="glyphicon glyphicon-ok"></span> 2 minutes</a></li>
                <li><a href="null" class="unset set-refresh-interval-cmd" data-value="300"><span class="glyphicon glyphicon-ok"></span> 5 minutes</a></li>
                <li><a href="null" class="unset set-refresh-interval-cmd" data-value="600"><span class="glyphicon glyphicon-ok"></span> 10 minutes</a></li>
                <li><a href="null" class="unset set-refresh-interval-cmd" data-value="1800"><span class="glyphicon glyphicon-ok"></span> 30 minutes</a></li>
                <li class="divider"></li>
                <li><a href="null" class="refresh-now-cmd"><span class="glyphicon glyphicon-play"></span> Now!</a></li>
            </ul>
        </div>
    </div>

    <h2>@(ViewBag.Title)</h2>


    <div class="content-header">
        <div class="timebar"></div>
    </div>

    <div id="content-timetable" class="row hidden-sm hidden-xs"></div>

    <div class="row">

        <div class="col-md-3 col-sm-4">
            <div class="row">
                @if (HeartBeatService.Default.IsMonitoring)
                {
                    <div class="col-md-12 heartbeat">
                        <div class="thumbnail">
                            <div class="text-center">
                                <span class="heartbeat-success hidden">
                                    <span id="heartbeat-heart" class="glyphicon glyphicon-ok-sign"></span><br />
                                    <span>Your site is up &amp; running.</span><br />
                                </span>
                                <span class="heartbeat-failure hidden">
                                    <span id="heartbeat-exclamation" class="glyphicon glyphicon-exclamation-sign"></span><br />
                                    <span>Your site demands attention!</span><br />
                                </span>
                                <div class="timebar"></div>
                            </div>
                            <div class="legend">Site monitoring - <a href="about:blank" target="monitoredurl">Url</a></div>
                        </div>
                    </div>
                }
                <div class="col-md-12">
                    <div id="content-errorcounter" class="thumbnail">
                        <i>Loading...</i>
                    </div>
                </div>
                <div class="col-md-12">
                    <div id="content-timegraph" class="thumbnail">
                        <i>Loading...</i>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-9 col-sm-8">
            <div class="row">
                <div class="col-md-12">
                    <div id="content-sample" class="thumbnail">
                        <i>Loading...</i>
                    </div>
                </div>
                <div class="col-md-12">
                    <div id="content-usererror" class="thumbnail">
                        <i>Loading...</i>
                    </div>
                </div>
                <div class="col-md-12">
                    <div id="content-perapp" class="thumbnail">
                        <i>Loading...</i>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<div id="siteDownDlg" class="modal fade">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-body">
                <p class="text-center">
                    <font size="5" color="darkred"><span class="glyphicon glyphicon-remove-sign"></span>&nbsp; This ELMAH LogViewer hosting site is down!</font>
                </p>
                <p class="text-center">
                    <small>
                        If autorefreshing, this dialog will disappear as soon as the refresh succeeds again.<br />
                        Else, close this dialog by clicking anywhere on or outside it.
                    </small>
                </p>
            </div>
        </div>
    </div>
</div>

<div id="contentholder" class="hidden"></div>