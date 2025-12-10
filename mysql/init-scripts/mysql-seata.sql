create schema if not exists `seata`;
--
-- Licensed to the Apache Software Foundation (ASF) under one or more
-- contributor license agreements.  See the NOTICE file distributed with
-- this work for additional information regarding copyright ownership.
-- The ASF licenses this file to You under the Apache License, Version 2.0
-- (the "License"); you may not use this file except in compliance with
-- the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

-- for AT mode you must to init this sql for you business database. the seata server not need it.
CREATE TABLE IF NOT EXISTS `seata`.`undo_log`
(
    `branch_id`     BIGINT       NOT NULL COMMENT 'branch transaction id',
    `xid`           VARCHAR(128) NOT NULL COMMENT 'global transaction id',
    `context`       VARCHAR(128) NOT NULL COMMENT 'undo_log context,such as serialization',
    `rollback_info` LONGBLOB     NOT NULL COMMENT 'rollback info',
    `log_status`    INT(11)      NOT NULL COMMENT '0:normal status,1:defense status',
    `log_created`   DATETIME(6)  NOT NULL COMMENT 'create datetime',
    `log_modified`  DATETIME(6)  NOT NULL COMMENT 'modify datetime',
    UNIQUE KEY `ux_undo_log` (`xid`, `branch_id`)
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 COMMENT ='AT transaction mode undo table';
ALTER TABLE `undo_log` ADD INDEX `ix_log_created` (`log_created`);

create table if not exists `seata`.`account_tbl`
(
    `id`      int                                                           not null auto_increment,
    `user_id` varchar(255) character set utf8mb4 collate utf8mb4_general_ci null default null,
    `money`   int                                                           null default 0,
    primary key (`id`) using btree
) engine = innodb
  character set = utf8mb4
  collate = utf8mb4_general_ci
  row_format = dynamic;

create table if not exists `seata`.`order_tbl`
(
    `id`             int                                                           not null auto_increment,
    `user_id`        varchar(255) character set utf8mb4 collate utf8mb4_general_ci null default null,
    `commodity_code` varchar(255) character set utf8mb4 collate utf8mb4_general_ci null default null,
    `count`          int                                                           null default 0,
    `money`          int                                                           null default 0,
    primary key (`id`) using btree
) engine = innodb
  character set = utf8mb4
  collate = utf8mb4_general_ci
  row_format = dynamic;

create table if not exists `seata`.`storage_tbl`
(
    `id`             int                                                           not null auto_increment,
    `commodity_code` varchar(255) character set utf8mb4 collate utf8mb4_general_ci null default null,
    `count`          int                                                           null default 0,
    primary key (`id`) using btree,
    unique index `commodity_code` (`commodity_code` asc) using btree
) engine = innodb
  character set = utf8mb4
  collate = utf8mb4_general_ci
  row_format = dynamic;

create table if not exists `seata`.`undo_log`
(
    `branch_id`     bigint                                                        not null comment 'branch transaction id',
    `xid`           varchar(128) character set utf8mb4 collate utf8mb4_0900_ai_ci not null comment 'global transaction id',
    `context`       varchar(128) character set utf8mb4 collate utf8mb4_0900_ai_ci not null comment 'undo_log context,such as serialization',
    `rollback_info` longblob                                                      not null comment 'rollback info',
    `log_status`    int                                                           not null comment '0:normal status,1:defense status',
    `log_created`   datetime(6)                                                   not null comment 'create datetime',
    `log_modified`  datetime(6)                                                   not null comment 'modify datetime',
    unique index `ux_undo_log` (`xid` asc, `branch_id` asc) using btree,
    index `ix_log_created` (`log_created` asc) using btree
) engine = innodb
  auto_increment = 1
  character set = utf8mb4
  collate = utf8mb4_0900_ai_ci comment = 'at transaction mode undo table'
  row_format = dynamic;



--
-- Licensed to the Apache Software Foundation (ASF) under one or more
-- contributor license agreements.  See the NOTICE file distributed with
-- this work for additional information regarding copyright ownership.
-- The ASF licenses this file to You under the Apache License, Version 2.0
-- (the "License"); you may not use this file except in compliance with
-- the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

-- -------------------------------- The script used when storeMode is 'db' --------------------------------
-- the table to store GlobalSession data
CREATE TABLE IF NOT EXISTS `global_table`
(
    `xid`                       VARCHAR(128) NOT NULL,
    `transaction_id`            BIGINT,
    `status`                    TINYINT      NOT NULL,
    `application_id`            VARCHAR(32),
    `transaction_service_group` VARCHAR(32),
    `transaction_name`          VARCHAR(128),
    `timeout`                   INT,
    `begin_time`                BIGINT,
    `application_data`          VARCHAR(2000),
    `gmt_create`                DATETIME,
    `gmt_modified`              DATETIME,
    PRIMARY KEY (`xid`),
    KEY `idx_status_gmt_modified` (`status` , `gmt_modified`),
    KEY `idx_transaction_id` (`transaction_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

-- the table to store BranchSession data
CREATE TABLE IF NOT EXISTS `branch_table`
(
    `branch_id`         BIGINT       NOT NULL,
    `xid`               VARCHAR(128) NOT NULL,
    `transaction_id`    BIGINT,
    `resource_group_id` VARCHAR(32),
    `resource_id`       VARCHAR(256),
    `branch_type`       VARCHAR(8),
    `status`            TINYINT,
    `client_id`         VARCHAR(64),
    `application_data`  VARCHAR(2000),
    `gmt_create`        DATETIME(6),
    `gmt_modified`      DATETIME(6),
    PRIMARY KEY (`branch_id`),
    KEY `idx_xid` (`xid`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

-- the table to store lock data
CREATE TABLE IF NOT EXISTS `lock_table`
(
    `row_key`        VARCHAR(128) NOT NULL,
    `xid`            VARCHAR(128),
    `transaction_id` BIGINT,
    `branch_id`      BIGINT       NOT NULL,
    `resource_id`    VARCHAR(256),
    `table_name`     VARCHAR(32),
    `pk`             VARCHAR(36),
    `status`         TINYINT      NOT NULL DEFAULT '0' COMMENT '0:locked ,1:rollbacking',
    `gmt_create`     DATETIME,
    `gmt_modified`   DATETIME,
    PRIMARY KEY (`row_key`),
    KEY `idx_status` (`status`),
    KEY `idx_branch_id` (`branch_id`),
    KEY `idx_xid` (`xid`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `distributed_lock`
(
    `lock_key`       CHAR(20) NOT NULL,
    `lock_value`     VARCHAR(32) NOT NULL,
    `expire`         BIGINT,
    primary key (`lock_key`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

INSERT INTO `distributed_lock` (lock_key, lock_value, expire) VALUES ('AsyncCommitting', ' ', 0);
INSERT INTO `distributed_lock` (lock_key, lock_value, expire) VALUES ('RetryCommitting', ' ', 0);
INSERT INTO `distributed_lock` (lock_key, lock_value, expire) VALUES ('RetryRollbacking', ' ', 0);
INSERT INTO `distributed_lock` (lock_key, lock_value, expire) VALUES ('TxTimeoutCheck', ' ', 0);


CREATE TABLE IF NOT EXISTS `vgroup_table`
(
    `vGroup`    VARCHAR(255),
    `namespace` VARCHAR(255),
    `cluster`   VARCHAR(255),
    UNIQUE KEY `idx_vgroup_namespace_cluster` (`vGroup`,`namespace`,`cluster`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;