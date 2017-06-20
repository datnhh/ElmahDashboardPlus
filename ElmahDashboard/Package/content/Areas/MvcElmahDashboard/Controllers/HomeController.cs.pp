using $rootnamespace$.Areas.MvcElmahDashboard.Code;
using $rootnamespace$.Areas.MvcElmahDashboard.Models.Home;
using System;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Web.Mvc;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace $rootnamespace$.Areas.MvcElmahDashboard.Controllers
{    
    public class HomeController : Controller
    {
        private static ElmahErrorCounters EECounters = new ElmahErrorCounters(TimeSpan.FromDays(15));
        private static HeartBeatService HeartBeatService = new HeartBeatService();

        #region Infrastructure

        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            // Apply culture:
            if (!String.IsNullOrWhiteSpace(ConfigurationManager.AppSettings["MvcElmahDashboardCulture"]))
            {
                System.Threading.Thread.CurrentThread.CurrentCulture = new System.Globalization.CultureInfo(ConfigurationManager.AppSettings["MvcElmahDashboardCulture"]);
            }

            base.OnActionExecuting(filterContext);
        }

        #endregion

        // GET: ElmahLog/Home
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult HourlyStats()
        {
            using (var context = new ElmahDashboardContext())
            {
                EECounters.UpdateCache(context);

                var now = DateTime.UtcNow;
                var model = new HourlyStatsModel();
                model.Timestamp = now;
                model.RangeEnd = now.TruncToHours().AddHours(1);
                model.RangeStart = model.RangeEnd.AddHours(-24);
                model.HourlyCounters = EECounters.GetHourlyCounters(model.RangeStart, model.RangeEnd);
                model.LastHourErrors = EECounters.GetErrors(now.AddHours(-1), now);
                model.SampleLogCount = Int32.Parse(ConfigurationManager.AppSettings["MvcElmahDashboardLogCount"].IfNullOrWhiteSpace("3"));
                foreach (var app in EECounters.GetErrors(now.AddHours(-4), now).Select(i => i.Application).Distinct())
                {
                    var appvar = app;
                    model.AppHourlyCounters[appvar] = EECounters.GetHourlyCounters(model.RangeEnd.AddHours(-4), model.RangeEnd, item => item.Application == appvar);
                }

                return View(model);
            }
        }

        public ActionResult DailyStats()
        {
            using (var context = new ElmahDashboardContext())
            {
                EECounters.UpdateCache(context);

                var now = DateTime.UtcNow;
                var model = new DailyStatsModel();
                model.Timestamp = now;
                model.RangeEnd = now.TruncToDays().AddDays(1);
                model.RangeStart = model.RangeEnd.AddDays(-14);
                model.DailyCounters = EECounters.GetDailyCounters(model.RangeStart, model.RangeEnd);
                model.LastDayErrors = EECounters.GetErrors(now.AddDays(-1), now);
                model.SampleLogCount = Int32.Parse(ConfigurationManager.AppSettings["MvcElmahDashboardLogCount"].IfNullOrWhiteSpace("3"));
                foreach (var app in EECounters.GetErrors(now.AddDays(-4), now).Select(i => i.Application).Distinct())
                {
                    var appvar = app;
                    model.AppDailyCounters[appvar] = EECounters.GetDailyCounters(model.RangeEnd.AddDays(-4), model.RangeEnd, item => item.Application == appvar);
                }

                //chart line with focus
                int day = Int32.Parse(ConfigurationManager.AppSettings["MvcElmahDashboardDayChart"].IfNullOrWhiteSpace("14"));
                var _model = context.CountByTypeError(day);
                List<DataModel> ls = new List<DataModel>();
                var types = context.ListTypes(day);
                foreach (var item in types)
                {
                    var line = _model.Where(p => p.Type == item).OrderBy(p => p.Date).Select(p => new XY(1, p.Counts, p.Date)).ToList();
                    var dt = new DataModel();
                    var i = 0;
                    foreach (var _i in line)
                    {
                        line[i].x = i;
                        i++;
                    }
                    dt.key = item;
                    dt.values = line;

                    ls.Add(dt);
                }
                var s = JsonConvert.SerializeObject(ls);
                ViewBag.chartData = s;
                ViewBag.DayChart = day;

                //chart pie
                var _pie = _model.GroupBy(p => p.Type).Select(g => new { label = g.Key, value = g.Sum(i => i.Counts) }).OrderByDescending(x => x.value).Take(5).ToList(); //from prop in _model
                if (types.Count() > 5)
                {
                    var _other = _model.GroupBy(p => p.Type).Select(g => new { label = g.Key, value = g.Sum(i => i.Counts) }).OrderByDescending(x => x.value).Skip(5).Sum(v => v.value);
                    _pie.Add(new { label = "Other", value = _other });
                }
                ViewBag.pieData = JsonConvert.SerializeObject(_pie);

                //user error
                var _userdata = context.ListUserByDay(day);
                ViewBag.UersError = _userdata;
                var _userpie = _userdata.Select(g => new { label = g.User, value = g.Counts }).OrderByDescending(x => x.value).Take(5).ToList();
                if (_userdata.Count() > 5)
                {
                    var _other = _userdata.Select(g => new { label = g.User, value = g.Counts }).OrderByDescending(x => x.value).Skip(5).Sum(v => v.value);
                    _userpie.Add(new { label = "Other", value = _other });
                }
                ViewBag.userChart = JsonConvert.SerializeObject(_userpie);

                return View(model);
            }
        }

        public ActionResult Heartbeat()
        {
            Response.CacheControl = "no-cache";
            Response.AddHeader("Pragma", "no-cache");
            Response.Expires = -1;
            if (HeartBeatService.Beat())
                return new HttpStatusCodeResult(HttpStatusCode.OK, "Heartbeat succeeded");
            else
                return new HttpStatusCodeResult(HttpStatusCode.InternalServerError, "Heartbeat failed");
        }

        public ActionResult d3()
        {
            using (var context = new ElmahDashboardContext())
            {
                var model = context.CountByTypeError();
                List<DataModel> ls = new List<DataModel>();
                var types = context.ListTypes(14);
                foreach (var item in types)
                {
                    var line = model.Where(p => p.Type == item).OrderBy(p => p.Date).Select(p => new XY(1, p.Counts, p.Date)).ToList();
                    var dt = new DataModel();
                    var i = 0;
                    foreach (var _i in line)
                    {
                        line[i].x = i;
                        i++;
                    }
                    dt.key = item;
                    dt.values = line;

                    ls.Add(dt);
                }
                var s = JsonConvert.SerializeObject(ls);
                ViewBag.chartData = s;
                return View(ls);
            }

            //return View();
        }

        /// <summary>
        /// Used to handle scripts and styles requests.
        /// </summary>
        protected override void HandleUnknownAction(string actionName)
        {
            this.View(actionName).ExecuteResult(this.ControllerContext);
        }
    }
}