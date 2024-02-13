-- liquibase formatted sql

-- changeset jeff.pell:system-1 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role accountadmin;
create warehouse if not exists ${SNOWFLAKE_WAREHOUSE} 
  with 
  warehouse_size = xsmall
  auto_suspend = 5
  auto_resume = true
  initially_suspended = true
  ;

-- changeset jeff.pell:system-2 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role sysadmin;
use database ${SNOWFLAKE_DATABASE};
create schema if not exists iceberg_poc;


-- changeset jeff.pell:system-3 endDelimiter:go runOnChange:true runAlways:false stripComments:false
use role accountadmin;
CREATE EXTERNAL VOLUME IF NOT EXISTS AWS_ICEBERG_VOL
  STORAGE_LOCATIONS = 
	(
		(
			name = 'AWS_ICEBERG_LOC'
			storage_provider = 'S3'
			storage_base_url = 's3://${AWS_S3_BUCKET_NAME}/'
			storage_aws_role_arn = '${AWS_IAM_ROLE_ARN}'
			
		)
	);
GRANT ALL ON EXTERNAL VOLUME AWS_ICEBERG_VOL TO ROLE sysadmin WITH GRANT OPTION;
go

-- changeset jeff.pell:system-4 endDelimiter:go runOnChange:true runAlways:false stripComments:false
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

--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:1 select count(1) where ${CONDITIONALSTOP}=0;
-- changeset jeff.pell:system-5 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role accountadmin;
CREATE NOTIFICATION INTEGRATION if not exists sf_email_ni
  TYPE=EMAIL
  ENABLED=TRUE
  ALLOWED_RECIPIENTS = (${SNOWFLAKE_EMAILNOTIFICATIONLIST});

