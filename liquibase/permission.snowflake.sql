-- liquibase formatted sql

-- changeset jeff.pell:permission-1 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role accountadmin;
grant usage  on warehouse ${SNOWFLAKE_WAREHOUSE} to role sysadmin;

-- changeset jeff.pell:permission-2
use role accountadmin;
create role if not exists report_role;

-- changeset jeff.pell:permission-3
use role accountadmin;
grant usage on database poc_02 to role report_role;

-- changeset jeff.pell:permission-4
use role accountadmin;
grant usage on schema poc_02.public to role report_role;
grant usage on schema poc_02.iceberg_poc to role report_role;

-- changeset jeff.pell:permission-5
use role accountadmin;
grant usage on warehouse report_role_wh to role report_role;

-- changeset jeff.pell:permission-6
use role accountadmin;
grant select on view poc_02.iceberg_poc.v_coverage_count to role report_role;
grant select on view poc_02.iceberg_poc.v_coverage_subcoverage_count to role report_role;
grant select on view poc_02.iceberg_poc.v_reason_count to role report_role;
grant select on view poc_02.iceberg_poc.v_reason_subreason_count to role report_role;
grant select on view poc_02.iceberg_poc.v_disposition_count to role report_role;
grant select on view poc_02.iceberg_poc.v_disposition_reason_count to role report_role;
grant select on view poc_02.iceberg_poc.v_disposition_coverage_count to role report_role;

-- changeset jeff.pell:permission-7
use role accountadmin;
create user if not exists report_display
   password = '${SNOWFLAKE_REPORT_USER_PASSWORD}'
   login_name ='report_display'
   default_warehouse = report_role_wh
   default_namespace = poc_01
   default_role = report_role
   comment = 'User to access data for reporting only.';

-- changeset jeff.pell:permission-8
use role accountadmin;
grant role report_role to user report_display;

