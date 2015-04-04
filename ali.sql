

create table recommend_train_user_rs as
select *,split(time,' ')[0] dt,split(time,' ')[1] hr ,
substr(user_geohash,1,6) geo6,substr(user_geohash,1,5) geo5
from recommend_train_user 

create table train as
select * from recommend_train_user_rs
where dt<>'2014-12-18'

create table test as
select * from recommend_train_user_rs
where dt='2014-12-18'


/* create table train_behavior_type as
select dt,user_id,item_id,behavior_type,count(behavior_type) as cnt
from recommend_train_user_rs
group by user_id,item_id,behavior_type,dt; */


/* create table demo_buy as
select a.user_id,a.item_id,a.dt,a._c3,a._c4,a._c5,a._c6
from
(select user_id,item_id,dt,
	sum(case behavior_type when 1 then cnt else 0 end),
	sum(case behavior_type when 2 then cnt else 0 end),
	sum(case behavior_type when 3 then cnt else 0 end),
	sum(case behavior_type when 4 then cnt else 0 end)
from train_behavior_type
group by user_id,item_id,dt)a
where a._c6>0; */


create table train_buy as
select a.user_id,a.geo5,a.item_category,a.item_id,a.click,a.collect,a.cart,a.buy
from
(select user_id,geo5,item_category,item_id,
	sum(case behavior_type when 1 then 1 else 0 end) click,
	sum(case behavior_type when 2 then 1 else 0 end) collect,
	sum(case behavior_type when 3 then 1 else 0 end) cart,
	sum(case behavior_type when 4 then 1 else 0 end) buy
from train
group by user_id,geo5,item_category,item_id)a
where a.buy>0




create table tianchi_mobile_recommendation_predict as
select demo_buy.user_id,demo_buy.item_id
from demo_buy inner join recommend_train_item
on demo_buy.item_id=recommend_train_item.item_id
