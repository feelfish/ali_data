用户地理位置初步处理

① 存在多个不同的user_geohash,取重复最多的那个user_geohash，如果不存在重复的，则取最近一次购买记录的user_geohash,如果没有购买记录，依次取加购物车、收藏、浏览的最近一次user_geohash


②不存在user_geohash,则对有对应商品地理位置的item_ geohash进行与上述①一样的取值


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

  select t1.user_id,
         t1.user_geohash,
         t1.behavior_type,
         row_number()over(partition by t1.user_id order by to_date(time,'yyyy-mm-dd hh') desc) rownumber1,
         row_number()over(partition by t1.user_id order by t1.behavior_type desc,to_date(time,'yyyy-mm-dd hh') desc) rownumber2,
         count(1)over(partition by t1.user_id,t1.user_geohash) cut1,
         count(1)over(partition by t1.user_id) cut2,
  from recommend_train_user t1
  where user_geohash<>'';


  rownumbe1--根据user_id分组,按照time降序得到的序号

  rownumbe2--根据user_id分组,按照用户行为类型降序，time降序得到的序号

  cut1--根据user_id,user_geohash分组,使用窗口函数返回窗口user_id，user_geohash的计量值

  cut1--根据user_id分组,使用窗口函数返回窗口user_id的计量值

