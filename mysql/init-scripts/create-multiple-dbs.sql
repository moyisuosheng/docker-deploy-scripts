-- 初始化脚本会在 MYSQL_DATABASE 指定的库创建后执行。
-- 此处创建额外的数据库
create schema if not exists `rm-system`;
create schema if not exists `rm-file`;
create schema if not exists `rm-search`;
create schema if not exists `seata`;
-- 你也可以为不同的数据库创建用户并授权（可选）
-- CREATE USER 'analytics_user'@'%' IDENTIFIED BY 'user_password';
-- GRANT ALL PRIVILEGES ON `app_analytics`.* TO 'analytics_user'@'%';

CREATE TABLE if not exists `rm-file`.`file`
(
    `id`              bigint NOT NULL COMMENT '主键ID',
    `update_time`     DATETIME     DEFAULT NULL COMMENT '更新时间戳',
    `update_user`     varchar(64)  DEFAULT NULL COMMENT '更新人',
    `create_time`     DATETIME     DEFAULT NULL COMMENT '创建时间戳',
    `create_user`     varchar(64)  DEFAULT NULL COMMENT '创建人',
    `deleted`         bigint       DEFAULT 0 COMMENT '逻辑删除标识（0=未删除，值=id时=已删除）',
    `file_name`       varchar(255) DEFAULT NULL COMMENT '文件名',
    `file_url`        varchar(512) DEFAULT NULL COMMENT '文件地址',
    `file_identifier` varchar(128) DEFAULT NULL COMMENT '文件标识符',
    `file_type`       varchar(64)  DEFAULT NULL COMMENT '文件类型',
    `status`          tinyint      DEFAULT 1 COMMENT '状态（0=禁用；1=正常）',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='文件信息表';

CREATE TABLE if not exists `rm-file`.`tag`
(
    `id`          bigint NOT NULL COMMENT '主键ID',
    `update_time` DATETIME    DEFAULT NULL COMMENT '更新时间戳',
    `update_user` varchar(64) DEFAULT NULL COMMENT '更新人',
    `create_time` DATETIME    DEFAULT NULL COMMENT '创建时间戳',
    `create_user` varchar(64) DEFAULT NULL COMMENT '创建人',
    `deleted`     bigint      DEFAULT 0 COMMENT '逻辑删除标识（0=未删除，值=id时=已删除）',
    `tag_name`    varchar(64) DEFAULT NULL COMMENT '标签名称',
    `status`      tinyint     DEFAULT 1 COMMENT '状态（0=禁用；1=正常）',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='标签信息表';

CREATE TABLE if not exists `rm-system`.`user`
(
    `id`          bigint NOT NULL COMMENT '主键ID',
    `update_time` DATETIME     DEFAULT NULL COMMENT '更新时间戳',
    `update_user` varchar(64)  DEFAULT NULL COMMENT '更新人',
    `create_time` DATETIME     DEFAULT NULL COMMENT '创建时间戳',
    `create_user` varchar(64)  DEFAULT NULL COMMENT '创建人',
    `deleted`     bigint       DEFAULT 0 COMMENT '逻辑删除标识（0=未删除，值=id时=已删除）',
    `name`        varchar(64)  DEFAULT NULL COMMENT '姓名',
    `nickname`    varchar(64)  DEFAULT NULL COMMENT '昵称',
    `phone`       varchar(20)  DEFAULT NULL COMMENT '手机号',
    `password`    varchar(128) DEFAULT NULL COMMENT '密码，加密存储',
    `gender`      varchar(10)  DEFAULT NULL COMMENT '性别',
    `id_number`   varchar(32)  DEFAULT NULL COMMENT '身份证号',
    `avatar`      varchar(512) DEFAULT NULL COMMENT '头像地址',
    `status`      tinyint      DEFAULT 1 COMMENT '状态（0=禁用；1=正常）',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='用户信息表';