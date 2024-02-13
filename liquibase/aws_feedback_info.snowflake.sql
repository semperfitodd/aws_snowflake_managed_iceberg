-- liquibase formatted sql

-- changeset jeff.pell:aws_feedback-1 endDelimiter:go runOnChange:true runAlways:true stripComments:false
use role sysadmin;
create table if not exists aws_feedback_info (name varchar(100), value varchar(1000));
truncate table aws_feedback_info;
desc external volume aws_iceberg_vol;
set parval=last_query_id();
insert into aws_feedback_info (name, value)
with data as (
select parse_json(
select  "property_value"
from table(result_scan($parval)) 
where "property" = 'STORAGE_LOCATION_1'
) j
)
select KEY as NAME , VALUE::text as VALUE
from data, table(flatten(j)) k
where NAME in ('STORAGE_AWS_IAM_USER_ARN','STORAGE_AWS_EXTERNAL_ID');
UPDATE aws_feedback_info
set    NAME= 'SNOWFLAKE_AWS_USER_ARN'
where  NAME= 'STORAGE_AWS_IAM_USER_ARN';
UPDATE aws_feedback_info
set    NAME= 'SNOWFLAKE_EXTERNAL_ID'
where  NAME= 'STORAGE_AWS_EXTERNAL_ID';
go
