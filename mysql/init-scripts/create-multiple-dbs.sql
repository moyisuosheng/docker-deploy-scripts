-- 初始化脚本会在 mysql_database 指定的库创建后执行。
-- 此处创建额外的数据库
create schema if not exists `rm-system`;
create schema if not exists `rm-file`;
create schema if not exists `rm-search`;
create schema if not exists `seata`;
-- 你也可以为不同的数据库创建用户并授权（可选）
-- create user 'analytics_user'@'%' identified by 'user_password';
-- grant all privileges on `app_analytics`.* to 'analytics_user'@'%';

create table if not exists `rm-file`.resource_file
(
    id               bigint                             not null comment '主键'
        primary key,
    record_id        bigint                             not null comment '资源文件记录 id',
    upload_id        varchar(255)                       not null comment 'minio 内文件上传标识',
    summary          varchar(255)                       not null comment '文件摘要',
    summary_type     varchar(64)                        not null comment '文件摘要类型',
    bucket           varchar(64)                        not null comment '存储桶',
    object_key       varchar(255)                       not null comment 'minio 内文件名',
    origin_file_name varchar(255)                       not null comment '原始文件名',
    size             bigint                             not null comment '文件大小（字节）',
    content_type     varchar(512)                       not null comment '文件类型',
    chunk_size       bigint                             not null comment '分片大小（字节）',
    chunk_count      int                                not null comment '分片数量',
    tenant_id        bigint                             null comment '租户',
    version          bigint                             not null default 0 comment '乐观锁版本号',
    update_time      datetime default current_timestamp not null on update current_timestamp comment '更新时间戳',
    update_user      varchar(64)                        null comment '更新人',
    create_time      datetime default current_timestamp not null comment '创建时间戳',
    create_user      varchar(64)                        null comment '创建人',
    deleted          bigint   default 0                 null comment '逻辑删除标识（0=未删除，值=id时=已删除）'
)
    comment '文件表' row_format = dynamic;

create table if not exists `rm-file`.resource_file_record
(
    id               bigint                             not null comment '主键'
        primary key,
    upload_id        varchar(255)                       not null comment 'minio 内文件上传标识',
    summary          varchar(255)                       not null comment '文件摘要',
    summary_type     varchar(64)                        not null comment '文件摘要类型',
    slice            tinyint                            not null comment '是否切片（切片上传：true，非切片上传：false）',
    bucket           varchar(64)                        not null comment '存储桶',
    object_key       varchar(255)                       not null comment 'minio 内文件名',
    origin_file_name varchar(255)                       not null comment '原始文件名',
    size             bigint                             not null comment '文件大小（字节）',
    content_type     varchar(512)                       not null comment '文件类型',
    chunk_size       bigint                             not null comment '分片大小（字节）',
    chunk_count      int                                not null comment '分片数量',
    tenant_id        bigint                             null comment '租户',
    version          bigint                             not null default 0 comment '乐观锁版本号',
    update_time      datetime default current_timestamp not null on update current_timestamp comment '更新时间戳',
    update_user      varchar(64)                        null comment '更新人',
    create_time      datetime default current_timestamp not null comment '创建时间戳',
    create_user      varchar(64)                        null comment '创建人',
    deleted          bigint   default 0                 null comment '逻辑删除标识（0=未删除，值=id时=已删除）'
)
    comment '文件记录表' row_format = dynamic;

create table if not exists `rm-file`.resource_file_slice_record
(
    id              bigint                             not null comment '主键'
        primary key,
    record_id       bigint                             not null comment '资源文件记录 id',
    part_number     int                                not null comment '切片编号',
    summary         varchar(255)                       not null comment '切片文件摘要',
    summary_type    varchar(64)                        not null comment '切片文件摘要类型',
    url             text                               not null comment '切片上传地址',
    expiration_time datetime                           not null comment '过期时间',
    tenant_id       bigint                             null comment '租户',
    version         bigint                             not null default 0 comment '乐观锁版本号',
    update_time     datetime default current_timestamp not null on update current_timestamp comment '更新时间戳',
    update_user     varchar(64)                        null comment '更新人',
    create_time     datetime default current_timestamp not null comment '创建时间戳',
    create_user     varchar(64)                        null comment '创建人',
    deleted         bigint   default 0                 null comment '逻辑删除标识（0=未删除，值=id时=已删除）'
)
    comment '文件切片记录表' row_format = dynamic;

-- 权限相关表

create table `rm-system`.sys_role
(
    id          bigint auto_increment comment 'Id'
        primary key,
    role_code   varchar(50)                        not null comment '角色编码（如 role_admin）',
    role_name   varchar(50)                        not null comment '角色名称',
    tenant_id   bigint                             null comment '租户',
    version     bigint   default 0                 not null comment '乐观锁版本号',
    update_time datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '更新时间戳',
    update_user varchar(64)                        null comment '更新人',
    create_time datetime default CURRENT_TIMESTAMP not null comment '创建时间戳',
    create_user varchar(64)                        null comment '创建人',
    deleted     bigint   default 0                 null comment '逻辑删除标识（0=未删除，值=id时=已删除）'
);

INSERT INTO `rm-system`.sys_role (id, role_code, role_name, tenant_id, version, update_time, update_user, create_time, create_user, deleted) VALUES (1, 'role_admin', '管理员', null, 0, '2025-12-16 22:21:52', null, '2025-12-16 22:21:52', null, 0);
INSERT INTO `rm-system`.sys_role (id, role_code, role_name, tenant_id, version, update_time, update_user, create_time, create_user, deleted) VALUES (2, 'role_user', '普通用户', null, 0, '2025-12-16 22:21:52', null, '2025-12-16 22:21:52', null, 0);

create table `rm-system`.sys_user
(
    id          bigint auto_increment comment 'Id'
        primary key,
    username    varchar(50)                        not null comment '用户名',
    password    varchar(100)                       not null comment '加密密码',
    enabled     tinyint  default 1                 null comment '是否启用（1=是，0=否）',
    tenant_id   bigint                             null comment '租户',
    version     bigint   default 0                 not null comment '乐观锁版本号',
    update_time datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '更新时间戳',
    update_user varchar(64)                        null comment '更新人',
    create_time datetime default CURRENT_TIMESTAMP not null comment '创建时间戳',
    create_user varchar(64)                        null comment '创建人',
    deleted     bigint   default 0                 null comment '逻辑删除标识（0=未删除，值=id时=已删除）',
    constraint username
        unique (username, deleted)
);

INSERT INTO `rm-system`.sys_user (id, username, password, enabled, tenant_id, version, update_time, update_user, create_time, create_user, deleted) VALUES (1, 'admin', '$2a$10$BSZMjocJs96rsqPd/ABLZel3owTLVkGR04niRW1aYSrR52Kg8qvca', 1, null, 0, '2025-12-16 22:22:19', null, '2025-12-16 22:22:19', null, 0);
INSERT INTO `rm-system`.sys_user (id, username, password, enabled, tenant_id, version, update_time, update_user, create_time, create_user, deleted) VALUES (2, 'user', '$2a$10$BSZMjocJs96rsqPd/ABLZel3owTLVkGR04niRW1aYSrR52Kg8qvca', 1, null, 0, '2025-12-16 22:22:19', null, '2025-12-16 22:22:19', null, 0);

create table `rm-system`.sys_user_role
(
    id          bigint auto_increment comment 'Id'
        primary key,
    user_id     bigint                             not null comment '用户Id',
    role_id     bigint                             not null comment '角色Id',
    tenant_id   bigint                             null comment '租户',
    version     bigint   default 0                 not null comment '乐观锁版本号',
    update_time datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '更新时间戳',
    update_user varchar(64)                        null comment '更新人',
    create_time datetime default CURRENT_TIMESTAMP not null comment '创建时间戳',
    create_user varchar(64)                        null comment '创建人',
    deleted     bigint   default 0                 null comment '逻辑删除标识（0=未删除，值=id时=已删除）'
);

create index role_id
    on `rm-system`.sys_user_role (role_id, deleted);

create index user_id
    on `rm-system`.sys_user_role (user_id, deleted);

INSERT INTO `rm-system`.sys_user_role (id, user_id, role_id, tenant_id, version, update_time, update_user, create_time, create_user, deleted) VALUES (1, 1, 1, null, 0, '2025-12-16 22:22:36', null, '2025-12-16 22:22:36', null, 0);
INSERT INTO `rm-system`.sys_user_role (id, user_id, role_id, tenant_id, version, update_time, update_user, create_time, create_user, deleted) VALUES (2, 2, 2, null, 0, '2025-12-16 22:22:36', null, '2025-12-16 22:22:36', null, 0);




