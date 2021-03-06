------------------------------------------------------------------------------------------------------------------------------------------------------
--      Retrieve a lot of information about query performance, based on sql_id
--
--      Script      sqlperf_noawr.sql
--      Run as      DBA
--
--      Purpose     This script will retrieve info about a query, based on sql_id and create a HTML report
--
--      Input       sql_id, child_number
--
--      Author      M. Krijgsman
--
--      Remarks     A Diagnostics Pack license is not required for this script
--
--      Version When        Who            What?
--      ------- ----------- -------------- ----------------------------------------------------------------------------------------------
--      1.6     04 mar 2014 M. Krijgsman   Initial version based on regular sqlperf.sql. I'm keeping version numbers in line with sqlperf.sql
--                                         to avoid (my) confusion.
------------------------------------------------------------------------------------------------------------------------------------------------------

column v_datetime    new_value datetime       noprint
select to_char(sysdate, 'YYYYMMDDHH24MISS') v_datetime from dual;

store set /tmp/your_sqlplus_env_&datetime..sql REPLACE

set linesize 3000
set feedback off
set verify off
set pause off
set timing off
set echo off
set heading on
set pages 999
set trimspool on
set newpage none
set define on

column vl_dbname     new_value l_dbname       noprint

select lower(name) vl_dbname from v$database;


prompt =============================================
prompt =                                           =
prompt =            sqlperf_noawr.sql              =
prompt =  This script will retrieve all kinds of   =
prompt =  information about SQLs based on sql_id   =
prompt =                                           =
prompt =          (Version 10g or higher)          =
prompt =                                           =
prompt =============================================
prompt


accept sql_id    default '' -
  prompt 'Please provide the sql_id: '

prompt This instance.
prompt -----------------------------------

col instance_name for a16
col status for a16

select instance_name, instance_number, status 
from v$instance;


prompt
prompt

prompt Different versions of the query.
prompt -----------------------------------

prompt (This should return only a handful of rows, or no binds have been used)
prompt

column vl_inst_id     new_value l_inst_id       noprint
select instance_number vl_inst_id from v$instance;

col sql_id for a20
col last_active_time for a16
col last_load_time for a20
col instance for a16

select a.sql_id, a.child_number
, case 
   when a.inst_id = &l_inst_id then 'THIS ONE'
   else (select instance_name 
         from gv$instance 
         where instance_number=a.inst_id) 
   end instance, a.last_load_time
, to_char(a.last_active_time, 'DD-MON HH24:MI:SS') last_active_time
,      a.loaded_versions, a.open_versions, a.users_opening
from gv$sql a
where sql_id='&sql_id';

prompt
prompt

prompt When the query has been runned from a different instance, run this script there.
prompt

prompt

accept childnr    default '' -
prompt 'To what child_number is this case related?: '

prompt




spool sqlperf_&l_dbname._&sql_id._&datetime..html

/* head '-
  <title>SQL report for &sql_id on &l_dbname</title> -
  <style type="text/css"> -
    body              {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;} -
    p                 {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;} -
    tr,td             {font:9pt Courier New, Courier; color:Black; background:#EEEEEE;} -
    table             {font:9pt Courier New, Courier; color:Black; background:#EEEEEE;} -
    th                {font:bold 9pt  Arial,Helvetica,sans-serif; color:#314299; background:#befdfd;} -
    h1                {font:bold 12pt Arial,Helvetica,sans-serif; color:#003399; background-color:White;} -
    h2                {font:bold 10pt Arial,Helvetica,sans-serif; color:#FF9933; background-color:White;} -
    a                 {font:9pt Arial,Helvetica,sans-serif; color:#0F0066; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.link            {font:9pt Arial,Helvetica,sans-serif; color:#0F0066; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLink          {font:9pt Arial,Helvetica,sans-serif; color:#0F0066; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkBlue      {font:9pt Arial,Helvetica,sans-serif; color:#0000ff; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkBlue  {font:9pt Arial,Helvetica,sans-serif; color:#000099; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkRed       {font:9pt Arial,Helvetica,sans-serif; color:#ff0000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkRed   {font:9pt Arial,Helvetica,sans-serif; color:#990000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkGreen     {font:9pt Arial,Helvetica,sans-serif; color:#00ff00; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkGreen {font:9pt Arial,Helvetica,sans-serif; color:#009900; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
  </style>' */

set heading off

prompt  <TITLE>SQL report for &sql_id on &l_dbname</TITLE>
prompt  <STYLE TYPE="text/css">
prompt    body              {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;}
prompt    p                 {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;}
prompt    tr,td             {font:9pt Courier New, Courier; color:Black; background:#EEEEEE;}
prompt    table             {font:9pt Courier New, Courier; color:Black; background:#EEEEEE;}
prompt    th                {font:bold 9pt  Arial,Helvetica,sans-serif; color:#314299; background:#befdfd;}
prompt    h1                {font:bold 12pt Arial,Helvetica,sans-serif; color:#003399; background-color:White;}
prompt    h2                {font:bold 10pt Arial,Helvetica,sans-serif; color:#FF9933; background-color:White;}
prompt    h4                {font:bold 9pt Arial,Helvetica,sans-serif; color:Grey; background-color:White;}
prompt    a                 {font:9pt Arial,Helvetica,sans-serif; color:#0F0066; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.link            {font:9pt Arial,Helvetica,sans-serif; color:#0F0066; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLink          {font:9pt Arial,Helvetica,sans-serif; color:#0F0066; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLinkBlue      {font:9pt Arial,Helvetica,sans-serif; color:#0000ff; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLinkDarkBlue  {font:9pt Arial,Helvetica,sans-serif; color:#000099; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLinkRed       {font:9pt Arial,Helvetica,sans-serif; color:#ff0000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLinkDarkRed   {font:9pt Arial,Helvetica,sans-serif; color:#990000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLinkGreen     {font:9pt Arial,Helvetica,sans-serif; color:#00ff00; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt    a.noLinkDarkGreen {font:9pt Arial,Helvetica,sans-serif; color:#009900; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
prompt  </STYLE>

prompt  </head>


prompt <body text="#000000" bgcolor="#FFFFFF" link="#0000FF"
prompt    vlink="#000080" alink="#FF0000">

set markup html on spool on preformat off entmap on

--body   'BGCOLOR="#C5CDC5"' table 'WIDTH="90%" BORDER="1"' 


set    markup html on entmap off
set    head off

set markup HTML ON ENTMAP OFF
prompt <h1>SQL report, based on sql_id.</h1>
prompt <p>This file was created with:
prompt sqlperf_noawr.sql
prompt version 1.6 (2014)
prompt 
prompt dbname: &l_dbname
prompt SQL_ID: &sql_id
prompt date:   &datetime
prompt </p>
set markup HTML OFF ENTMAP OFF


prompt <center>
prompt 	<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#314299"><b>Report Index</b></font>
prompt 	<hr align="center" width="250">
prompt
prompt
prompt <table width="90%" border="1">  
prompt 	<tr><th colspan="4">Query and execution plan</th></tr>  
prompt 	<tr>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#qversions">Different versions of the query</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#childs">Childs and hash values</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#sqltext">Full text of the query</a></td>  
prompt 		<td nowrap align="center" width="25%"></td>  
prompt 	</tr>
prompt 	<tr>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#execplan">Execution plan (memory)</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#blineallplans">Execution plans (from baselines)</a></td>
prompt 		<td nowrap align="center" width="25%"></td>
prompt 		<td nowrap align="center" width="25%"></td>
prompt 	</tr>
prompt  <tr><th colspan="4">SQL plan baselines and SQL profiles</th>
prompt  </tr>
prompt 	<tr>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#baselines">SQL and SQL plan baselines</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#blineinfo">SQL plan baseline info</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#sqlprofile">SQL profiles</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#sqlprofmeta">SQL profile metadata</a></td>  
prompt 	</tr>  
prompt 	<tr>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#profsnblines">SQL, profiles and baselines</a></td>  
prompt 		<td nowrap align="center" width="25%"></td>  
prompt 		<td nowrap align="center" width="25%"></td>  
prompt 		<td nowrap align="center" width="25%"></td>  
prompt 	</tr>
prompt  <tr><th colspan="4">Run statistics</th>
prompt  </tr>
prompt 	<tr>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#execsnrows">Executions, number of rows</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#respcpuwait">Response time, cpu time and wait time</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#memndisk">Memory and disk reads</a></td>
prompt 		<td nowrap align="center" width="25%"></td>  
prompt 	</tr>
prompt  <tr><th colspan="4">Binds</th>
prompt  </tr>
prompt 	<tr>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#bindaware">Bind awareness</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#adapcursh">Adaptive cursor sharing</a></td> 
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#bindmism">Bind mismatches</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#bindcontent">Content of bind variabeles</a></td>  
prompt 	</tr>
prompt 	<tr>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#bindsqlplus">Bind variables as SQL*Plus commands</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#bindsothers">Values of bind variables of other childs</a></td> 
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#blinedrop">Dropping associated SQL plan baselines</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#blinedrop">Purge the SQL statement from memory</a></td>  
prompt 	</tr>
prompt  <tr><th colspan="4">Object statistics</th>
prompt  </tr>
prompt 	<tr>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#tablestats">Table statistics</a></td>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#tabparts">Table partitions</a></td> 
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#indexstats">Index statistics</a></td>
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#indparts">Index partitions</a></td>
prompt 	</tr>
prompt 	<tr>  
prompt 		<td nowrap align="center" width="25%"><a class="link" href="#indcolstats">Indexed column statistics</a></td>
prompt 		<td nowrap align="center" width="25%"></td>
prompt 		<td nowrap align="center" width="25%"></td>
prompt 		<td nowrap align="center" width="25%"></td>
prompt 	</tr>
prompt </table>
prompt </center>  
prompt 


set heading on
set markup HTML ON ENTMAP OFF

prompt
prompt
prompt
prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>This instance.</h2>
set markup HTML ON ENTMAP ON

col instance_name for a20
col status for a20

select instance_name, instance_number, status 
from v$instance;


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Selected sql_id and child_number.</h2>
set markup HTML ON ENTMAP ON

select instance_name, '&sql_id' sql_id, '&childnr' childnr
from v$instance;


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="qversions"></A><h2>Different versions of the query.</h2>
prompt <p>(This should return only a handful of rows, or no binds have been used)</p>

set markup HTML ON ENTMAP ON

col sql_id for a20
col last_active_time for a16
col last_load_time for a20
col instance for a16

select a.sql_id, a.child_number
, case 
   when a.inst_id = &l_inst_id then 'THIS ONE'
   else (select instance_name 
         from gv$instance 
         where instance_number=a.inst_id) 
   end instance, a.last_load_time
, to_char(a.last_active_time, 'DD-MON HH24:MI:SS') last_active_time
,      a.loaded_versions, a.open_versions, a.users_opening
from gv$sql a
where sql_id='&sql_id';


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="childs"></A><h2>Childs and hash values.</h2>
set markup HTML ON ENTMAP ON

col last_active_time for a16
col last_load_time for a20

select a.sql_id, a.child_number
, (select instance_name 
         from gv$instance 
         where instance_number=a.inst_id) instance_name
,      a.hash_value, a.old_hash_value, a.plan_hash_value
from gv$sql a
where a.sql_id='&sql_id';

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="sqltext"></A><h2>Full text of the query (up to 50000 characters).</h2>
set markup HTML ON ENTMAP ON

set long 50000
col sql_fulltext for a4000

select sql_fulltext
from v$sql
where sql_id='&sql_id'
and child_number=&childnr;

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="baselines"></A><h2>SQL vs. SQL Plan Baselines.</h2>
set markup HTML ON ENTMAP ON

col sql_id for a20
col plan_name for a35
col created for a30
col FORCE_MATCHING_SIGNATURE for 9999999999999999999

select sql.sql_id, sql.child_number, sql.inst_id, sql.force_matching_signature, sql.plan_hash_value, bl.plan_name, bl.enabled, bl.accepted, bl.fixed, bl.optimizer_cost
from gv$sql sql
,    dba_sql_plan_baselines bl
where sql.sql_id='&sql_id'
and   sql.child_number=&childnr
and   sql.force_matching_signature=bl.SIGNATURE;

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="blineinfo"></A><h2>SQL Plan Baseline information.</h2>
set markup HTML ON ENTMAP ON

col SQL_HANDLE for a30
col origin for a16
col last_modified for a30
col last_verified for a30

select sql_handle, plan_name, origin, created, last_modified, last_verified
from dba_sql_plan_baselines
where signature in (select force_matching_signature
                    from v$sql
					where sql_id='&sql_id'
					and   child_number=&childnr);

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="sqlprofile"></A><h2>SQL Profile information.</h2>
set markup HTML ON ENTMAP ON

col name for a30
col task_exec_name for a16
col category for a10

select sql.sql_id, prof.name, prof.category, prof.created, prof.task_exec_name, prof.status
from DBA_SQL_PROFILES prof
,    gv$sql sql
where sql.sql_id='&sql_id'
and   sql.child_number=&childnr
and   sql.force_matching_signature=prof.SIGNATURE;


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="sqlprofmeta"></A><h2>SQL Profile metadata.</h2>
set markup HTML ON ENTMAP ON

set heading off
col outline_hints for a132

select extractvalue(value(d), '/hint') as outline_hints
from xmltable('/*/outline_data/hint' passing 
	(select xmltype(other_xml) as xmlval
   from v$sql_plan
	 where sql_id='&sql_id'
   and child_number=&childnr
   and other_xml is not null
  )
) d;


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="profsnblines"></A><h2>SQL, profiles and baselines.</h2>
set markup HTML ON ENTMAP ON

set heading on

col sql_profile for a30
col sql_patch for a30
col sql_plan_baseline for a35

select sql_id, child_number, inst_id, sql_profile, sql_plan_baseline, sql_patch
from gv$sql
where sql_id='&sql_id'
and   child_number=&childnr
order by sql_id, inst_id, child_number;


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="execsnrows"></A><h2>Executions, number of rows.</h2>
set markup HTML ON ENTMAP ON

select executions, parse_calls, loads, rows_processed, sorts
from v$sql
where sql_id='&sql_id'
and child_number=&childnr;

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="respcpuwait"></A><h2>Response time, cpu time and wait time (in seconds).</h2>
set markup HTML ON ENTMAP ON

select trunc(elapsed_time/1000000,1) elapsed_time, trunc(application_wait_time/1000000,1) applic_wait_time, trunc(cpu_time/1000000,1) cpu_time
, trunc(user_io_wait_time/1000000,1) user_io_wait_time, trunc(concurrency_wait_time/1000000,1) concurr_time
from v$sql
where sql_id='&sql_id'
and child_number=&childnr;

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="memndisk"></A><h2>Memory and disk reads.</h2>
set markup HTML ON ENTMAP ON

select buffer_gets, disk_reads, (sharable_mem+persistent_mem+runtime_mem) sql_area_used
from v$sql
where sql_id='&sql_id'
and child_number=&childnr;

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <h2>Who ran the query?</h2>
set markup HTML ON ENTMAP ON

col username for a30
col PARSING_SCHEMA_NAME for a30
col module for a40
col action for a30
col service for a30
select u.username, s.PARSING_SCHEMA_NAME, s.SERVICE, s.MODULE, s.ACTION
from v$sql s
,    dba_users u
where s.sql_id='&sql_id'
and s.child_number=&childnr
and u.user_id=s.PARSING_USER_ID;

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="bindaware"></A><h2>Bind aware, sharable?</h2>
set markup HTML ON ENTMAP ON

col IS_OBSOLETE for a11
col IS_BIND_SENSITIVE for a17
col IS_BIND_AWARE for a13
col IS_SHAREABLE for a12

select IS_OBSOLETE, IS_BIND_SENSITIVE, IS_BIND_AWARE, IS_SHAREABLE     
from v$sql
where sql_id='&sql_id'
and child_number=&childnr;

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="adapcursh"></A><h2>Adaptive cursor sharing.</h2>
set markup HTML ON ENTMAP ON

col PREDICATE for a30

select inst_id, sql_id, child_number, predicate,range_id, low, high
from GV$SQL_CS_SELECTIVITY 
where sql_id = '&sql_id'
order by inst_id, child_number;

prompt
prompt

select * from GV$SQL_CS_HISTOGRAM
where sql_id = '&sql_id'
order by inst_id, child_number;



prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="bindmism"></A><h2>Bind mismatches.</h2>
set markup HTML ON ENTMAP ON

select *
from
  xmltable( 'for $a at $i in /ROWSET/ROW
            ,$r in $a/*
              return element ROW{
                   element ROW_NUM{$i}
                  ,element COL_NAME{$r/name()}
                  ,element COL_VALUE{$r/text()}
              }'
            passing xmltype(cursor( select * 
                                    from   v$sql_shared_cursor 
                                    where  sql_id='&sql_id'
                                    and    child_number=&childnr
            ))
            columns
              row_num   int
             ,col_name  varchar2(30)
             ,col_value varchar2(100)
  );


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="bindcontent"></A><h2>Content of bind variabeles (use as example).</h2>
set markup HTML ON ENTMAP ON

col name for a10
col value_string for a50
col datatype_string for a50

select child_number, name, position
, case datatype
            when 180 then to_char(anydata.accesstimestamp(value_anydata),'DD-MON-YYYY HH24:MI:SS')
            when  12 then to_char(anydata.accessdate(value_anydata),'DD-MON-YYYY HH24:MI:SS')
            else value_string
       end value_string
, datatype_string
from v$sql_bind_capture
where sql_id='&sql_id'
and child_number=&childnr
order by position;

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="bindsqlplus"></A><h2>Bind variables as SQL*Plus commands.</h2>
set markup HTML ON ENTMAP ON

set heading off

select 'variable '||replace(name, ':', 'BIND_')||' '||decode(datatype_string, 'TIMESTAMP', 'VARCHAR2(128)', datatype_string) datatype_string
from v$sql_bind_capture
where sql_id='&sql_id'
and child_number=&childnr
order by position;

prompt

select 'exec '||replace(name, ':', ':BIND_')||' := '||
case datatype
            when 180 then to_char(anydata.accesstimestamp(value_anydata),'DD-MON-YYYY HH24:MI:SS')
            when  12 then to_char(anydata.accessdate(value_anydata),'DD-MON-YYYY HH24:MI:SS')
            else value_string
       end value_string
from v$sql_bind_capture
where sql_id='&sql_id'
and child_number=&childnr
and datatype_string NOT LIKE '%CHAR%'
and datatype_string NOT IN ('DATE', 'CLOB', 'TIMESTAMP')
order by position;

select 'exec '||replace(name, ':', ':BIND_')||' := '''||value_string||''''
from (
select name
, case datatype
            when 180 then to_char(anydata.accesstimestamp(value_anydata),'DD-MON-YYYY HH24:MI:SS')
            when  12 then to_char(anydata.accessdate(value_anydata),'DD-MON-YYYY HH24:MI:SS')
            else value_string
       end value_string
, position
from v$sql_bind_capture
where sql_id='&sql_id'
and child_number=&childnr
and (datatype_string LIKE '%CHAR%'
     OR datatype_string IN ('DATE', 'CLOB', 'TIMESTAMP'))
)
order by position;



prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="bindsothers"></A><h2>Values of bind variables of other childs.</h2>
set markup HTML ON ENTMAP ON

set heading on
col name for a10
col value_string for a50
col datatype_string for a50

select child_number, name, position
, case datatype
            when 180 then to_char(anydata.accesstimestamp(value_anydata),'DD-MON-YYYY HH24:MI:SS')
            when  12 then to_char(anydata.accessdate(value_anydata),'DD-MON-YYYY HH24:MI:SS')
            else value_string
       end value_string
, datatype_string
from v$sql_bind_capture
where sql_id='&sql_id'
and child_number <> &childnr
order by child_number, position;

set heading off

prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="execplan"></A><h2>Execution plan of the query.</h2>

set markup HTML OFF ENTMAP OFF

prompt <pre xml:space="preserve" class="oac_no_warn">
SELECT plan_table_output
FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'ALL'));
prompt </pre>


prompt
prompt
prompt

set markup HTML ON ENTMAP OFF

prompt
prompt <A NAME="blineallplans"></A><h2>All execution plans in sql plan baselines.</h2>
prompt <p>Run as SYS to see this.</p>
set markup HTML ON ENTMAP ON

column v_sql_handle     new_value l_sql_handle       noprint

set markup HTML OFF ENTMAP OFF

prompt <pre xml:space="preserve" class="oac_no_warn">
select distinct plan.SQL_HANDLE v_sql_handle
from dba_sql_plan_baselines plan
,    gv$sql sql
where sql.sql_id='&sql_id'
and   sql.child_number=&childnr
and   sql.force_matching_signature=plan.SIGNATURE;
prompt </pre>

prompt <pre xml:space="preserve" class="oac_no_warn">
SELECT * FROM TABLE(dbms_xplan.display_sql_plan_baseline(sql_handle=>'&l_sql_handle'));
prompt </pre>


prompt
prompt
prompt
set markup HTML ON ENTMAP OFF
prompt <A NAME="blinedrop"></A><h2>Dropping associated SQL plan baselines.</h2>
prompt <p>(Based on SQL_HANDLE gives an error, but works.</p>


select distinct 'select sys.dbms_spm.DROP_SQL_PLAN_BASELINE('''||sql_handle||''') from dual;' "Based on SQL_HANDLE"
from dba_sql_plan_baselines
where signature in (select force_matching_signature
                    from v$sql
					where sql_id='&sql_id'
					and   child_number=&childnr);

prompt

select 'declare   v_pls PLS_INTEGER; BEGIN   v_pls :=dbms_spm.drop_sql_plan_baseline(sql_handle=>'''||sql_handle||''', plan_name=>'''||plan_name||'''); END;'
from dba_sql_plan_baselines
where signature in (select force_matching_signature
                    from v$sql
					where sql_id='&sql_id'
					and   child_number=&childnr);


prompt
prompt
prompt
prompt <A NAME="planpurge"></A><h2>Generated statement to purge your SQL statement from the shared pool.</h2>

select 'exec sys.dbms_shared_pool.purge('''||address||', '||hash_value||''', ''c'')'
from v$sql
where sql_id = '&sql_id'
and child_number=&childnr;

prompt
prompt


prompt
prompt
prompt

set markup HTML ON ENTMAP OFF
prompt <A NAME="tablestats"></A><h2>Tables accessed in the execution plan.</h2>
set markup HTML ON ENTMAP ON

set heading on

SELECT owner, table_name, last_analyzed, sample_size, num_rows, avg_row_len, blocks, partitioned, global_stats
FROM dba_tables
WHERE table_name IN (
	select distinct rtrim(substr(plan_table_output, instr(plan_table_output, '|', 1, 3)+2, (instr(plan_table_output, '|', 1, 4)-instr(plan_table_output, '|', 1, 3)-2)), ' ')
	from (
		SELECT plan_table_output
		FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'BASIC'))
		   )
	where plan_table_output like '%TABLE ACCESS%'
  )
ORDER BY owner, table_name
/

prompt
prompt
prompt

set markup HTML ON ENTMAP OFF
prompt <A NAME="tabparts"></A><h2>Partitions of tables accessed in the execution plan.</h2>
set markup HTML ON ENTMAP ON

SELECT table_owner, table_name, partition_name, subpartition_count, last_analyzed, sample_size, num_rows, avg_row_len
FROM dba_tab_partitions
WHERE table_name IN (
	select distinct rtrim(substr(plan_table_output, instr(plan_table_output, '|', 1, 3)+2, (instr(plan_table_output, '|', 1, 4)-instr(plan_table_output, '|', 1, 3)-2)), ' ')
	from (
		SELECT plan_table_output
		FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'BASIC'))
		   )
	where plan_table_output like '%TABLE ACCESS%'
  )
ORDER BY table_owner, table_name, partition_name
/

prompt
prompt
prompt

set markup HTML ON ENTMAP OFF
prompt <A NAME="indexstats"></A><h2>Indexes accessed in the execution plan.</h2>
set markup HTML ON ENTMAP ON

SELECT owner, index_name, table_name, last_analyzed, sample_size, num_rows, partitioned, global_stats
FROM dba_indexes
WHERE index_name IN (
	select distinct rtrim(substr(plan_table_output, instr(plan_table_output, '|', 1, 3)+2, (instr(plan_table_output, '|', 1, 4)-instr(plan_table_output, '|', 1, 3)-2)), ' ')
	from (
		SELECT plan_table_output
		FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'BASIC'))
		   )
	where plan_table_output like '%INDEX%'
  )
ORDER BY owner, table_name, index_name
/

prompt
prompt
prompt

set markup HTML ON ENTMAP OFF
prompt <A NAME="indparts"></A><h2>Partitions of indexes accessed in the execution plan.</h2>
set markup HTML ON ENTMAP ON

SELECT index_owner, index_name, partition_name, subpartition_count, last_analyzed, sample_size, num_rows
FROM dba_ind_partitions
WHERE index_name IN (
	select distinct rtrim(substr(plan_table_output, instr(plan_table_output, '|', 1, 3)+2, (instr(plan_table_output, '|', 1, 4)-instr(plan_table_output, '|', 1, 3)-2)), ' ')
	from (
		SELECT plan_table_output
		FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'BASIC'))
		   )
	where plan_table_output like '%INDEX%'
  )
ORDER BY index_owner, index_name, partition_name
/

prompt
prompt
prompt

set markup HTML ON ENTMAP OFF
prompt <A NAME="indcolstats"></A><h2>Statistics indexed columns for indexes used in the execution plan.</h2>
set markup HTML ON ENTMAP ON

SELECT ic.index_owner, ic.index_name, ic.table_name, ic.column_name, ic.column_position col_pos, tc.last_analyzed, tc. sample_size, tc.num_distinct, tc.num_nulls, tc.density, tc.histogram, tc.num_buckets
FROM dba_ind_columns ic
,    dba_tab_columns tc
WHERE ic.index_name IN (
	select distinct rtrim(substr(plan_table_output, instr(plan_table_output, '|', 1, 3)+2, (instr(plan_table_output, '|', 1, 4)-instr(plan_table_output, '|', 1, 3)-2)), ' ')
	from (
		SELECT plan_table_output
		FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &childnr, 'BASIC'))
		   )
	where plan_table_output like '%INDEX%'
  )
AND ic.table_owner=tc.owner
AND ic.table_name=tc.table_name
AND ic.column_name=tc.column_name
ORDER BY ic.table_owner, ic.table_name, ic.index_name, ic.column_position
/

spool off

@/tmp/your_sqlplus_env_&datetime..sql
