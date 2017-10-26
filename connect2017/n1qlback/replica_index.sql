create index user_id on default(userid,name,mail) where type='profile' with {'num_replica':2};
