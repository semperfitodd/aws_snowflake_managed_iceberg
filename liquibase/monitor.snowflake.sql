-- liquibase formatted sql

-- changeset jeff.pell:monitor-1 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role accountadmin;
create or replace resource monitor daily_max_credit_${SNOWFLAKE_WAREHOUSE}
with credit_quota = 3
frequency = daily
start_timestamp = immediately
TRIGGERS ON 50 PERCENT DO NOTIFY
         on 75 PERCENT DO SUSPEND
         on 95 PERCENT DO SUSPEND_IMMEDIATE;

-- changeset jeff.pell:monitor-2 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role accountadmin;
alter warehouse ${SNOWFLAKE_WAREHOUSE}
  SET
  resource_monitor = daily_max_credit_${SNOWFLAKE_WAREHOUSE}
;
