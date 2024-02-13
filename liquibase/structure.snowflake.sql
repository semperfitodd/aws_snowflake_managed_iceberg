-- liquibase formatted sql

-- changeset jeff.pell:structure-1 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role sysadmin;
CREATE OR REPLACE ICEBERG TABLE complaints_iceberg (
COMPANY	STRING,
FILE_NO	DOUBLE,
OPENED	DATE,
CLOSED	DATE,
COVERAGE	STRING,
SUBCOVERAGE	STRING,
REASON	STRING,
SUBREASON	STRING,
DISPOSITION	STRING,
CONCLUSION	STRING,
RECOVERY	DOUBLE,
STATUS	STRING
)  
    CATALOG='SNOWFLAKE'
    EXTERNAL_VOLUME='AWS_ICEBERG_VOL'
    BASE_LOCATION='';


-- changeset jeff.pell:structure-2 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role sysadmin;
insert into complaints_iceberg (company, file_no, opened, closed, coverage, subcoverage, reason, subreason, disposition, conclusion, recovery, status)
select company, file_no, opened, closed, coverage, subcoverage, reason, subreason, disposition, conclusion, recovery, status 
from consumer_financial_protection_bureau_analysis.insights.insurance_company_complaints_resolutions_status_and_recoveries ;


-- changeset jeff.pell:structure-3 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create view poc_02.iceberg_poc.v_coverage_count
as
select coverage, count(1) as reccount
from complaints_iceberg
group by coverage;

-- changeset jeff.pell:structure-4 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create view poc_02.iceberg_poc.v_coverage_subcoverage_count
as
select coverage, subcoverage, count(1) as reccount
from complaints_iceberg
group by coverage, subcoverage
order by 2,1 ;


-- changeset jeff.pell:structure-5 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create view poc_02.iceberg_poc.v_reason_count
as
select reason, count(1) as reccount
from complaints_iceberg
group by reason;

-- changeset jeff.pell:structure-6 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create view poc_02.iceberg_poc.v_reason_subreason_count
as
select reason, subreason, count(1) as reccount
from complaints_iceberg
group by reason, subreason
order by 2,1 ;

-- changeset jeff.pell:structure-7 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create view poc_02.iceberg_poc.v_disposition_count
as
select nvl(disposition,'Unknown') as disposition, count(1) as reccount
from complaints_iceberg
group by disposition;

-- changeset jeff.pell:structure-8 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create view poc_02.iceberg_poc.v_disposition_reason_count
as
select nvl(disposition,'Unknown') as disposition, reason, count(1) as reccount
from complaints_iceberg
group by disposition, reason
order by 2,1 ;

-- changeset jeff.pell:structure-9 endDelimiter:; runOnChange:true runAlways:false stripComments:false
use role sysadmin;
create view poc_02.iceberg_poc.v_disposition_coverage_count
as
select nvl(disposition,'Unknown') as disposition, coverage, count(1) as reccount
from complaints_iceberg
group by disposition, coverage
order by 2,1 ;

