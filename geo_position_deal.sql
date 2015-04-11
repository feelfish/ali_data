用户地理位置初步处理

① 存在多个不同的user_geohash,取重复最多的那个user_geohash，如果不存在重复的，则取最近一次购

买记录的user_geohash,如果没有购买记录，依次取加购物车、收藏、浏览的最近一次user_geohash


②不存在user_geohash,则对有对应商品地理位置的item_ geohash进行与上述①一样的取值 --此种方法因

item_id存在多个地理位置作废


--对地理位置字段user_geohash数据进行验证

  select distinct length(user_geohash) from recommend_train_user;

  结果为 0  
         7
  select count(*) from recommend_train_user
  where user_geohash is null;
  
  结果为0

  select count(*)
  from recommend_train_user t1
  where user_geohash='';

  结果为8402567

  select length(user_geohash),count(*) from recommend_train_user
  group by length(user_geohash);

  结果 0  8402567
       7  3909975

  select count(*) from (select user_id,count(*) from recommend_train_user
                        where user_geohash<>''
                        group by user_id
                        having count(*)>1)t;
结果：8143



--对地理位置进行处理

create table demo_feng_geohash  as 
 select h1.user_id,h1.user_geohash,h1.behavior_type,h1.cut1,h1.cut2,
        row_number()over(partition by h1.user_id,h1.cut1 order by h1.behavior_type 

desc,h1.ftime desc) rownumber,
        max(h1.cut1)over(partition by h1.user_id) max_cut1
 from(
 select t1.user_id,
         t1.user_geohash,
         t1.behavior_type,
         to_date(t1.time,'yyyy-mm-dd hh') ftime,
         count(1)over(partition by t1.user_id,t1.user_geohash) cut1,
         count(1)over(partition by t1.user_id) cut2
  from recommend_train_user t1
  where t1.user_geohash<>'')h1;


  rownumbe--根据user_id分组,按照用户行为类型降序，time降序得到的序号

  cut1--根据user_id,user_geohash分组,使用窗口函数返回窗口user_id，user_geohash的计量值

  cut2--根据user_id分组,使用窗口函数返回窗口user_id的计量值

  max_cut1  --根据user_id分组,使用窗口函数返回窗口cut1的最大值




--用户仅对某个商品做过一次行为

select t1.user_id,t1.user_geohash,t1.behavior_type,t1.cut2,1 flag
  from demo_feng_geohash t1
  where t1.cut1=1  and t1.cut2=1

union all

--用户有2次及以上行为但每个行为均在不同地理位置

select t1.user_id,t1.user_geohash,t1.behavior_type,t1.cut2,2 flag
   from demo_feng_geohash t1
  where t1.max_cut1=1 and t1.cut2>1
    and t1.rownumber=1
        

union all
--用户有2次以上行为其中有2次行为及以上在同一地理位置

select t1.user_id,t1.user_geohash,t1.behavior_type,t1.cut2,'3' flag
  from demo_feng_geohash t1
  where t1.max_cut1>1  and t1.cut2>1
    and t1.max_cut1=t1.cut1
    and t1.rownumber=1

其中behavior_type 在flag in(1,2)时表示最近一次行为的行为类型(依次按照4,3,2,1排列)
在flag=3时表示存在在同一地理位置用户行为发生2次以上按照行为类型记录时间倒序最近的行为类型



create table demo_feng_user_geohash as
select *
from(
select t1.user_id,t1.user_geohash,t1.behavior_type,t1.cut2,1 flag
  from demo_feng_geohash t1
  where t1.cut1=1  and t1.cut2=1

union all

select t1.user_id,t1.user_geohash,t1.behavior_type,t1.cut2,2 flag
   from demo_feng_geohash t1
  where t1.max_cut1=1 and t1.cut2>1
    and t1.rownumber=1
        
union all

select t1.user_id,t1.user_geohash,t1.behavior_type,t1.cut2,3 flag
  from demo_feng_geohash t1
  where t1.max_cut1>1  and t1.cut2>1
    and t1.max_cut1=t1.cut1
    and t1.rownumber=1)h;
