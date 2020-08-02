--V3【开卡环节】开卡申请=01+02+03；开卡成功率=02/01+02+03；需要分一下静默开卡，自然开卡
DROP TABLE if exists dp_data_db.gxt_wlh_v3;
CREATE TABLE if not exists dp_data_db.gxt_wlh_v3 AS

select a.anchor,a.index_1,a.index_2,a.index_3,b.index_4,b.index_5,b.index_6
from  
(
    SELECT --总开卡
        date(b.date_updated) as anchor,
        count(distinct CASE WHEN b.STATUS='01' THEN b.user_no END) as index_1, -- 开户状态01=   间状态，基本为0，如果数据量大了，行方开卡流程相当于出问题了。
        count(distinct CASE WHEN b.STATUS='02' THEN b.user_no END) as index_2, -- 开户成功02=   成功
        count(distinct CASE WHEN b.STATUS='03' THEN b.user_no END) as index_3 -- 开户失败03=    失败
    FROM ods_real.prd_ipay_c_open_card as b
    group by anchor
) a

left join --静默开卡（自然开卡=总开卡-静默开卡）
(
    select 
        LEFT(a.date_updated,10) as anchor, -- 日期,
        count(distinct case when a.status='01' then a.user_no end) as index_4, 
        count(distinct case when a.status='02' then a.user_no end) as index_5,--静默开户成功
        count(distinct case when a.status='03' then a.user_no end) as index_6 -- 静默开户失败
    FROM
    (
        select distinct user_no,date_success,date_updated,status 
        from ods_real.prd_ipay_c_open_card 
    ) a

    left join ods_real.prd_ipay_c_open_card_active b on a.user_no=b.user_no 
    and date(a.date_updated)=date(b.date_updated) where b.STATUS = '02'
    group by LEFT(a.date_updated,10) 
)b on a.anchor=b.anchor
order by a.anchor;




--
DROP TABLE if exists dp_data_db.gxt_wlh_v3;
CREATE TABLE if not exists dp_data_db.gxt_wlh_v3 AS
select anchor,index_1,index_2,index_3,index_4,index_5,index_6
FROM 
(
    SELECT --总开卡
    date(o.date_created) as anchor,
    count(distinct CASE WHEN STATUS='01' THEN user_no END) as index_1, -- 开户状态01=   间状态，基本为0，如果数据量大了，行方开卡流程相当于出问题了。
    count(distinct CASE WHEN STATUS='02' THEN user_no END) as index_2, -- 开户成功02=   成功
    count(distinct CASE WHEN STATUS='03' THEN user_no END) as index_3 -- 开户失败03=    失败
    FROM ods_real.prd_ipay_c_open_card o
   
UNION ALL
    select 
    --LEFT(a.date_created,10) as anchor, -- 日期,
    count(distinct case when status='01' then user_no end) as index_4, 
    count(distinct case when status='02' then user_no end) as index_5,
    count(distinct case when status='03' then user_no end) as index_6
    from ods_real.prd_ipay_c_open_card_active a
    
)
GROUP by anchor
ORDER by anchor;


--
select 
LEFT(a.date_created,10)as anchor, -- 日期,
count(distinct case when a.status='01' then a.user_no end) as index_4, 
count(distinct case when a.status='02' then a.user_no end) as index_5,
count(distinct case when a.status='03' then a.user_no end) as index_6
from ods_real.prd_ipay_c_open_card_active a
GROUP BY anchor
ORDER BY anchor;