create database `ccnet` character set = 'utf8';
create database `seafile` character set = 'utf8';
create database `seahub` character set = 'utf8';


SET @create_user_local = CONCAT('
        CREATE USER "',@username,'"@"localhost" IDENTIFIED BY "',@password,'" '
        );
PREPARE stmt FROM @create_user_local; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @create_user_remote = CONCAT('
        CREATE USER "',@username,'"@"%" IDENTIFIED BY "',@password,'" '
        );
PREPARE stmt FROM @create_user_remote; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @priv_ccnet = CONCAT('
        GRANT ALL PRIVILEGES ON `ccnet`.* to `',@username,'` '
        );
PREPARE stmt FROM @priv_ccnet; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @priv_seafile = CONCAT('
        GRANT ALL PRIVILEGES ON `seafile`.* to `',@username,'` '
        );
PREPARE stmt FROM @priv_seafile; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @priv_seahub = CONCAT('
        GRANT ALL PRIVILEGES ON `seahub`.* to `',@username,'` '
        );
PREPARE stmt FROM @priv_seahub; EXECUTE stmt; DEALLOCATE PREPARE stmt;

