create index user_residence on default( userid, residence ) where type="profile" and sex="M" with {"defer_build":true};
create index user_address on default( userid, address ) where type="profile" and sex="M" with {"defer_build":true};
create index user_mail on default( userid, mail ) where type="profile" and sex="M" with {"defer_build":true};
build index on default( user_residence, user_address, user_mail );
