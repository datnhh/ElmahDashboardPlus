using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Linq;
using System.Text;

namespace $rootnamespace$.Areas.MvcElmahDashboard.Code
{
    public class ElmahDashboardContext : IDisposable
    {
        #region Construction & Disposal

        public ElmahDashboardContext()
            : this(ConfigurationManager.AppSettings["MvcElmahDashboardConnectionName"])
        { }

        public ElmahDashboardContext(string connectionName)
            : this(ConfigurationManager.ConnectionStrings[connectionName])
        { }

        public ElmahDashboardContext(ConnectionStringSettings connectionStringSettings)
            : this(connectionStringSettings.ConnectionString, connectionStringSettings.ProviderName)
        { }

        public ElmahDashboardContext(string connectionString, string providerName)
            : this(connectionString, DbProviderFactories.GetFactory(providerName))
        { }

        public ElmahDashboardContext(string connectionString, DbProviderFactory dbProviderFactory)
            : this(CreateConnection(dbProviderFactory, connectionString), true)
        { }

        public ElmahDashboardContext(IDbConnection dbConnection)
            : this(dbConnection, false)
        { }

        public ElmahDashboardContext(IDbConnection dbConnection, bool closeOnDispose)
        {
            this.Connection = dbConnection;
            this.CloseConnectionOnDispose = closeOnDispose;

            this.Initialize();
        }

        private static IDbConnection CreateConnection(DbProviderFactory dbProviderFactory, string connectionString)
        {
            var conn = dbProviderFactory.CreateConnection();
            conn.ConnectionString = connectionString;
            conn.Open();
            return conn;
        }

        protected virtual void Initialize()
        {
            using (var cmd = this.Connection.CreateCommand())
            {
                // Set Isolation Level:
                cmd.CommandText = "SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED";
                cmd.ExecuteNonQuery();

                // Retrieve SQL version:
                cmd.CommandText = "SELECT SERVERPROPERTY('productversion')";
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        this.MsSqlProductVersion = reader.GetString(0).Split('.').Select(s => Int32.Parse(s)).ToArray();
                    }
                }
            }
        }

        public virtual void Dispose()
        {
            if (this.CloseConnectionOnDispose)
                this.Connection.Dispose();
        }

        protected bool CloseConnectionOnDispose { get; private set; }

        #endregion

        protected IDbConnection Connection { get; private set; }

        protected int[] MsSqlProductVersion { get; private set; }

        public ElmahError GetError(Guid id)
        {
            return this.ListErrors(0, 1, "ErrorId = '" + id.ToString() + "'", null, true)
                .SingleOrDefault();
        }

        public int CountErrors(string where = null, params object[] parameters)
        {
            var sql = new StringBuilder();
            sql.Append("SELECT COUNT([ErrorId]) FROM [{ElmahSchema}].[ELMAH_Error] WITH (NOLOCK)");
            if (!String.IsNullOrWhiteSpace(where))
                sql.Append(" WHERE " + where);

            using (var cmd = this.CreateCommand(sql.ToString(), parameters))
            using (var reader = cmd.ExecuteReader())
            {
                reader.Read();
                return reader.GetInt32(0);
            }
        }

        public IEnumerable<ElmahError> ListErrors(int offset, int count, string where = null, string orderBy = null, bool includeDetails = false, params object[] parameters)
        {
            var sql = new StringBuilder();
            sql.Append("SELECT");
            if (MsSqlProductVersion[0] < 11)
                sql.Append(" TOP " + (offset + count));
            sql.Append(" [ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence]" + ((includeDetails) ? ", [AllXml]" : ""));
            sql.Append(" FROM [{ElmahSchema}].[ELMAH_Error] WITH (NOLOCK)");
            if (!String.IsNullOrWhiteSpace(where))
                sql.Append(" WHERE " + where);
            sql.Append(" ORDER BY " + (String.IsNullOrWhiteSpace(orderBy) ? "Sequence DESC" : orderBy));
            if (MsSqlProductVersion[0] >= 11)
                sql.Append(" OFFSET " + offset + " ROWS FETCH NEXT " + count + " ROWS ONLY");

            int rowNum = offset;
            using (var cmd = this.CreateCommand(sql.ToString(), parameters))
            using (var reader = cmd.ExecuteReader())
            {
                if (MsSqlProductVersion[0] < 11)
                {
                    // Skip rows:
                    for (int i = 0; i < offset; i++)
                        reader.Read();
                }

                while (reader.Read())
                {
                    yield return MaterializeElmahError(reader, includeDetails, ++rowNum);
                }
            }
        }

        public IEnumerable<ElmahErrorItem> ListErrorItems(DateTime sinceUtc, int afterSequence)
        {
            var sql = new StringBuilder();
            sql.Append("SELECT");
            sql.Append(" [Application], [TimeUtc], [Sequence]");
            sql.Append(" FROM [{ElmahSchema}].[ELMAH_Error] WITH (NOLOCK)");
            sql.Append(" WHERE [Sequence] > @p0 AND [TimeUtc] >= @p1");

            using (var cmd = this.CreateCommand(sql.ToString(), new object[] { afterSequence, sinceUtc }))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    yield return MaterializeElmahErrorItem(reader);
                }
            }
        }

        //datnhh 
        public IEnumerable<ErrorTypeDate> CountByTypeError(int day = 14)
        {
            List<ErrorTypeDate> list = new List<ErrorTypeDate>();
            var tpyes = ListTypes(day);
            for (int i = 0; i < day; i++)
            {
                foreach (var item in tpyes)
                {
                    ErrorTypeDate d = new ErrorTypeDate();
                    d.Type = item;
                    d.Date = DateTime.Now.AddDays(0 - i).ToString("yyyy-MM-dd");
                    d.Counts = 0;
                    list.Add(d);
                }
            }
            var sql = new StringBuilder();
            sql.Append(@"SELECT ee.[Type], COUNT(ee.ErrorId) as Counts,  CAST( ee.TimeUtc AS DATE) AS Date
FROM ELMAH_Error AS ee
WHERE  ee.TimeUtc BETWEEN DATEADD(day, -" + day + @", GETDATE()) AND GETDATE()
GROUP BY ee.[Type], CAST(ee.TimeUtc AS DATE)
ORDER BY  CAST(ee.TimeUtc AS DATE)");
            List<ErrorTypeDate> fdb = new List<ErrorTypeDate>();
            using (var cmd = this.CreateCommand(sql.ToString()))
            {
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var instance = new ErrorTypeDate();
                        instance.Type = reader.GetString(0);
                        instance.Counts = reader.GetInt32(1);
                        instance.Date = reader.GetDateTime(2).ToString("yyyy-MM-dd");
                        fdb.Add(instance);
                    }
                }
            }

            //left join
            var q = from d in list
                    join c in fdb on
                        new { d.Type, d.Date }
                        equals
                        new { c.Type, c.Date } into rs
                    from f in rs.DefaultIfEmpty()
                    select new ErrorTypeDate(d.Type, f == null ? 0 : f.Counts, d.Date);

            return q.ToList();
        }

        public List<ErrorUserDate> ListUserByDay(int day = 14)
        {
            var sql = new StringBuilder();
            sql.Append(@"SELECT ee.[User], COUNT(ee.ErrorId) as Counts
FROM ELMAH_Error AS ee
WHERE  ee.TimeUtc BETWEEN DATEADD(day, -" + day + @", GETDATE()) AND GETDATE()
GROUP BY ee.[User] ORDER BY Counts DESC");
            List<ErrorUserDate> model = new List<ErrorUserDate>();
            using (var cmd = this.CreateCommand(sql.ToString()))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    string _user = string.IsNullOrWhiteSpace(reader.GetString(0)) ? "Unknown" : reader.GetString(0);
                    model.Add(new ErrorUserDate(_user, reader.GetInt32(1)));
                }
            }
            return model;
        }

        public IEnumerable<string> ListApplications()
        {
            using (var cmd = this.CreateCommand("SELECT DISTINCT [Application] FROM [{ElmahSchema}].[ELMAH_Error] WITH (NOLOCK) ORDER BY 1"))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    yield return reader.GetString(0);
                }
            }
        }

        public IEnumerable<string> ListHosts()
        {
            using (var cmd = this.CreateCommand("SELECT DISTINCT [Host] FROM [{ElmahSchema}].[ELMAH_Error] WITH (NOLOCK) ORDER BY 1"))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    yield return reader.GetString(0);
                }
            }
        }

        public IEnumerable<string> ListTypes(int day = -1)
        {
            var sql = "SELECT DISTINCT [Type] FROM [{ElmahSchema}].[ELMAH_Error] WITH (NOLOCK) ORDER BY 1";
            if (day > 0)
            {
                sql = "SELECT DISTINCT [Type] FROM [{ElmahSchema}].[ELMAH_Error] WITH (NOLOCK) where  TimeUtc BETWEEN DATEADD(day,-" + day + ",GETDATE())  AND GETDATE() ORDER BY 1";
            }
            using (var cmd = this.CreateCommand(sql))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    yield return reader.GetString(0);
                }
            }
        }

        public IEnumerable<string> ListSource()
        {
            using (var cmd = this.CreateCommand("SELECT DISTINCT [Source] FROM [{ElmahSchema}].[ELMAH_Error] WITH (NOLOCK) ORDER BY 1"))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    yield return reader.GetString(0);
                }
            }
        }

        protected IDbCommand CreateCommand(string sql, object[] parameters = null)
        {
            var cmd = this.Connection.CreateCommand();

            cmd.CommandText = sql.Replace("{ElmahSchema}", String.IsNullOrWhiteSpace(ConfigurationManager.AppSettings["MvcElmahDashboardDbSchema"]) ? "dbo" : ConfigurationManager.AppSettings["MvcElmahDashboardDbSchema"]);

            if (parameters != null)
            {
                for (int i = 0; i < parameters.Length; i++)
                {
                    var paramValue = parameters[i];
                    var param = cmd.CreateParameter();
                    param.ParameterName = "@p" + i;
                    param.Value = (paramValue ?? DBNull.Value);
                    cmd.Parameters.Add(param);
                }
            }

            return cmd;
        }

        protected virtual ElmahError MaterializeElmahError(IDataReader reader, bool includeDetails, int rowNum)
        {
            var instance = new ElmahError();
            instance.ErrorId = reader.GetGuid(0);
            instance.Application = reader.GetString(1);
            instance.Host = reader.GetString(2);
            instance.Type = reader.GetString(3);
            instance.Source = reader.GetString(4);
            instance.Message = reader.GetString(5);
            instance.User = reader.GetString(6);
            instance.StatusCode = reader.GetInt32(7);
            instance.TimeUtc = DateTime.SpecifyKind(reader.GetDateTime(8), DateTimeKind.Utc);
            instance.Sequence = reader.GetInt32(9);
            instance.RowNum = rowNum;
            if (includeDetails)
            {
                instance.AllXml = System.Xml.Linq.XDocument.Parse(reader.GetString(10));
            }
            return instance;
        }

        protected virtual ElmahErrorItem MaterializeElmahErrorItem(IDataReader reader)
        {
            var instance = new ElmahErrorItem();
            instance.Application = reader.GetString(0);
            instance.TimeUtc = DateTime.SpecifyKind(reader.GetDateTime(1), DateTimeKind.Utc);
            instance.Sequence = reader.GetInt32(2);
            return instance;
        }
    }

    public class ErrorTypeDate
    {
        public ErrorTypeDate() { Type = ""; Date = ""; Counts = 0; }
        public ErrorTypeDate(string t, int c, string d)
        {
            Type = t; Date = d; Counts = c;
        }
        public string Type { get; set; }
        public string Date { get; set; }
        public int Counts { get; set; }
    }

    public class ErrorUserDate
    {
        public ErrorUserDate(string u, int c) { User = u; Counts = c; }
        public string User { get; set; }
        public int Counts { get; set; }
    }

    public class DataModel
    {
        public string key { get; set; }
        public List<XY> values { get; set; }
    }

    public class XY
    {
        public XY(int _x, int _y, string _t) { x = _x; y = _y; text = _t; }
        public int x { get; set; }
        public int y { get; set; }
        public string text { get; set; }
    }
}