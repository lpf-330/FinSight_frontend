-- ============================================================
-- FinSight 财务智能分析系统 - 建库建表脚本
-- 数据库: MySQL 8.0+ / TiDB 7.0+
-- 字符集: utf8mb4
-- 注意: 所有列名统一使用反引号包裹，避免保留字冲突
-- ============================================================

CREATE DATABASE IF NOT EXISTS finsight
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE finsight;

-- ============================================================
-- 1. 系统支撑域
-- ============================================================

DROP TABLE IF EXISTS sys_role;
CREATE TABLE sys_role (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT,
  `name`          VARCHAR(64)  NOT NULL,
  `code`          VARCHAR(64)  NOT NULL,
  `description`   VARCHAR(256) DEFAULT NULL,
  `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY uk_role_name (`name`),
  UNIQUE KEY uk_role_code (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色表';

DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user (
  `id`             BIGINT       NOT NULL AUTO_INCREMENT,
  `username`       VARCHAR(64)  NOT NULL,
  `password_hash`  VARCHAR(256) NOT NULL,
  `name`           VARCHAR(64)  NOT NULL,
  `department`     VARCHAR(128) DEFAULT NULL,
  `role_id`        BIGINT       NOT NULL,
  `status`         ENUM('active','disabled') NOT NULL DEFAULT 'active',
  `last_login`     DATETIME     DEFAULT NULL,
  `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY uk_username (`username`),
  KEY idx_role_id (`role_id`),
  CONSTRAINT fk_user_role FOREIGN KEY (`role_id`) REFERENCES sys_role (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

DROP TABLE IF EXISTS sys_role_permission;
CREATE TABLE sys_role_permission (
  `id`              BIGINT        NOT NULL AUTO_INCREMENT,
  `role_id`         BIGINT        NOT NULL,
  `permission_key`  VARCHAR(128)  NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY uk_role_permission (`role_id`, `permission_key`),
  CONSTRAINT fk_rp_role FOREIGN KEY (`role_id`) REFERENCES sys_role (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色权限关联表';

DROP TABLE IF EXISTS sys_audit_log;
CREATE TABLE sys_audit_log (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT,
  `user_id`     BIGINT       DEFAULT NULL,
  `username`    VARCHAR(64)  NOT NULL,
  `operation`   VARCHAR(64)  NOT NULL,
  `module`      VARCHAR(64)  NOT NULL,
  `detail`      TEXT         DEFAULT NULL,
  `ip`          VARCHAR(64)  DEFAULT NULL,
  `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY idx_created_at (`created_at`),
  KEY idx_user_id (`user_id`),
  CONSTRAINT fk_audit_user FOREIGN KEY (`user_id`) REFERENCES sys_user (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='审计日志表';

-- ============================================================
-- 2. 数据接入域
-- ============================================================

DROP TABLE IF EXISTS data_etl_task;
CREATE TABLE data_etl_task (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT,
  `name`          VARCHAR(128) NOT NULL,
  `source`        VARCHAR(128) NOT NULL,
  `target`        VARCHAR(128) NOT NULL,
  `cron`          VARCHAR(64)  DEFAULT NULL,
  `db_url`        VARCHAR(512) DEFAULT NULL,
  `db_username`   VARCHAR(128) DEFAULT NULL,
  `db_password`   VARCHAR(256) DEFAULT NULL,
  `db_driver`     VARCHAR(256) DEFAULT NULL,
  `status`        ENUM('success','failed','running','pending') NOT NULL DEFAULT 'pending',
  `last_run`      DATETIME     DEFAULT NULL,
  `next_run`      DATETIME     DEFAULT NULL,
  `last_records`  INT          DEFAULT 0,
  `last_duration` VARCHAR(32)  DEFAULT NULL,
  `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY uk_task_name (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ETL任务配置表';

DROP TABLE IF EXISTS data_etl_run_log;
CREATE TABLE data_etl_run_log (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT,
  `task_id`       BIGINT       NOT NULL,
  `task_name`     VARCHAR(128) NOT NULL,
  `start_time`    DATETIME     NOT NULL,
  `end_time`      DATETIME     DEFAULT NULL,
  `status`        ENUM('success','failed','running','stopped') NOT NULL,
  `records`       INT          DEFAULT 0,
  `error_count`   INT          DEFAULT 0,
  `error_message` TEXT         DEFAULT NULL,
  `duration`      VARCHAR(32)  DEFAULT NULL,
  `log_content`   TEXT         DEFAULT NULL,
  `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY idx_task_start (`task_id`, `start_time` DESC),
  CONSTRAINT fk_runlog_task FOREIGN KEY (`task_id`) REFERENCES data_etl_task (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ETL运行日志表';

DROP TABLE IF EXISTS data_subject_mapping;
CREATE TABLE data_subject_mapping (
  `id`           BIGINT       NOT NULL AUTO_INCREMENT,
  `k8_code`      VARCHAR(32)  NOT NULL,
  `k8_name`      VARCHAR(128) NOT NULL,
  `target_code`  VARCHAR(32)  NOT NULL,
  `target_name`  VARCHAR(128) NOT NULL,
  `category`     VARCHAR(32)  NOT NULL,
  `enabled`      TINYINT(1)   NOT NULL DEFAULT 1,
  `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY idx_category (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='科目映射表';

DROP TABLE IF EXISTS data_validation_rule;
CREATE TABLE data_validation_rule (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(128) NOT NULL,
  `expression`  TEXT         NOT NULL,
  `level`       ENUM('warning','error') NOT NULL DEFAULT 'error',
  `message`     VARCHAR(512) DEFAULT NULL,
  `enabled`     TINYINT(1)   NOT NULL DEFAULT 1,
  `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='数据校验规则表';

DROP TABLE IF EXISTS data_import_record;
CREATE TABLE data_import_record (
  `id`             BIGINT       NOT NULL AUTO_INCREMENT,
  `file_name`      VARCHAR(256) NOT NULL,
  `type`           ENUM('balance','income','cashflow') NOT NULL,
  `mode`           ENUM('append','overwrite') NOT NULL DEFAULT 'append',
  `records`        INT          DEFAULT 0,
  `status`         ENUM('success','failed','processing') NOT NULL,
  `operator_id`    BIGINT       DEFAULT NULL,
  `operator_name`  VARCHAR(64)  DEFAULT NULL,
  `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY idx_type_status (`type`, `status`),
  CONSTRAINT fk_import_operator FOREIGN KEY (`operator_id`) REFERENCES sys_user (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='数据导入记录表';

-- ============================================================
-- 3. 配置管理域
-- ============================================================

DROP TABLE IF EXISTS config_formula;
CREATE TABLE config_formula (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(128) NOT NULL,
  `expression`  TEXT         NOT NULL,
  `category`    VARCHAR(32)  NOT NULL,
  `enabled`     TINYINT(1)   NOT NULL DEFAULT 1,
  `version`     VARCHAR(16)  NOT NULL,
  `created_by`  VARCHAR(64)  DEFAULT NULL,
  `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY idx_category (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='公式配置表';

DROP TABLE IF EXISTS config_threshold;
CREATE TABLE config_threshold (
  `id`              BIGINT      NOT NULL AUTO_INCREMENT,
  `indicator`       VARCHAR(64) NOT NULL,
  `indicator_code`  VARCHAR(16) NOT NULL,
  `direction`       ENUM('lower','upper') NOT NULL DEFAULT 'lower',
  `yellow_value`    VARCHAR(32) NOT NULL,
  `orange_value`    VARCHAR(32) NOT NULL,
  `red_value`       VARCHAR(32) NOT NULL,
  `dynamic_base`    TINYINT(1)  NOT NULL DEFAULT 0,
  `created_at`      DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY uk_indicator_code (`indicator_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='预警阈值配置表';

DROP TABLE IF EXISTS config_knowledge;
CREATE TABLE config_knowledge (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT,
  `indicator`     VARCHAR(64)  NOT NULL,
  `level`         ENUM('yellow','orange','red') NOT NULL,
  `content`       TEXT         NOT NULL,
  `version`       VARCHAR(16)  NOT NULL,
  `useful_count`  INT          DEFAULT 0,
  `useless_count` INT          DEFAULT 0,
  `created_by`    VARCHAR(64)  DEFAULT NULL,
  `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY idx_indicator_level (`indicator`, `level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='知识库表';

DROP TABLE IF EXISTS config_model_version;
CREATE TABLE config_model_version (
  `id`           BIGINT      NOT NULL AUTO_INCREMENT,
  `model_type`   ENUM('ratio','warning') NOT NULL,
  `version`      VARCHAR(16) NOT NULL,
  `description`  TEXT        DEFAULT NULL,
  `creator`      VARCHAR(64) DEFAULT NULL,
  `is_active`    TINYINT(1)  NOT NULL DEFAULT 0,
  `created_at`   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY uk_model_version (`model_type`, `version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='模型版本表';

DROP TABLE IF EXISTS config_system_param;
CREATE TABLE config_system_param (
  `id`           BIGINT       NOT NULL AUTO_INCREMENT,
  `param_key`    VARCHAR(128) NOT NULL,
  `param_value`  TEXT         NOT NULL,
  `description`  VARCHAR(256) DEFAULT NULL,
  `editable`     TINYINT(1)   NOT NULL DEFAULT 1,
  `updated_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY uk_param_key (`param_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统参数表';

DROP TABLE IF EXISTS config_email_param;
CREATE TABLE config_email_param (
  `id`           BIGINT       NOT NULL AUTO_INCREMENT,
  `smtp_host`    VARCHAR(128) NOT NULL,
  `smtp_port`    INT          NOT NULL,
  `sender`       VARCHAR(128) NOT NULL,
  `username`     VARCHAR(128) NOT NULL,
  `password`     VARCHAR(256) NOT NULL,
  `ssl_enabled`  TINYINT(1)   NOT NULL DEFAULT 1,
  `updated_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='邮件配置表';

-- ============================================================
-- 4. 算法引擎域
-- ============================================================

DROP TABLE IF EXISTS algo_ratio_result;
CREATE TABLE algo_ratio_result (
  `id`             BIGINT        NOT NULL AUTO_INCREMENT,
  `code`           VARCHAR(16)   NOT NULL,
  `name`           VARCHAR(64)   NOT NULL,
  `formula`        VARCHAR(256)  DEFAULT NULL,
  `category`       ENUM('solvency','operating','profitability','growth') NOT NULL,
  `value`          DECIMAL(18,4) DEFAULT NULL,
  `prev_value`     DECIMAL(18,4) DEFAULT NULL,
  `change_pct`     DECIMAL(10,4) DEFAULT NULL,
  `standard`       VARCHAR(64)   DEFAULT NULL,
  `fiscal_period`  VARCHAR(16)   NOT NULL,
  `calculated_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY uk_code_period (`code`, `fiscal_period`),
  KEY idx_period_category (`fiscal_period`, `category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='比率分析结果表';

DROP TABLE IF EXISTS algo_warning_record;
CREATE TABLE algo_warning_record (
  `id`               BIGINT        NOT NULL AUTO_INCREMENT,
  `indicator`        VARCHAR(64)   NOT NULL,
  `indicator_code`   VARCHAR(16)   NOT NULL,
  `level`            ENUM('yellow','orange','red') NOT NULL,
  `current_value`    DECIMAL(18,4) DEFAULT NULL,
  `yellow_threshold` VARCHAR(32)   DEFAULT NULL,
  `orange_threshold` VARCHAR(32)   DEFAULT NULL,
  `red_threshold`    VARCHAR(32)   DEFAULT NULL,
  `trend`            VARCHAR(64)   DEFAULT NULL,
  `suggestion`       TEXT          DEFAULT NULL,
  `status`           ENUM('active','ignored') NOT NULL DEFAULT 'active',
  `fiscal_period`    VARCHAR(16)   NOT NULL,
  `triggered_at`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY idx_status_level (`status`, `level`),
  KEY idx_triggered_at (`triggered_at` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='预警记录表';

DROP TABLE IF EXISTS algo_trend_data;
CREATE TABLE algo_trend_data (
  `id`              BIGINT        NOT NULL AUTO_INCREMENT,
  `indicator_code`  VARCHAR(16)   NOT NULL,
  `month`           VARCHAR(16)   NOT NULL,
  `value`           DECIMAL(18,4) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY uk_indicator_month (`indicator_code`, `month`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='趋势数据表';

DROP TABLE IF EXISTS algo_dupont_data;
CREATE TABLE algo_dupont_data (
  `id`                BIGINT        NOT NULL AUTO_INCREMENT,
  `fiscal_period`     VARCHAR(16)   NOT NULL,
  `roe`               DECIMAL(18,4) DEFAULT NULL,
  `roe_change`        DECIMAL(10,4) DEFAULT NULL,
  `factor_name`       VARCHAR(64)   NOT NULL,
  `factor_value`      DECIMAL(18,4) DEFAULT NULL,
  `factor_prev_value` DECIMAL(18,4) DEFAULT NULL,
  `factor_change`     DECIMAL(10,4) DEFAULT NULL,
  `contribution`      DECIMAL(10,4) DEFAULT NULL,
  `calculated_at`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY idx_period (`fiscal_period`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='杜邦分析数据表';

DROP TABLE IF EXISTS algo_investment_scheme;
CREATE TABLE algo_investment_scheme (
  `id`                 BIGINT        NOT NULL AUTO_INCREMENT,
  `project_name`       VARCHAR(128)  NOT NULL,
  `initial_investment` DECIMAL(18,2) NOT NULL,
  `discount_rate`      DECIMAL(10,4) NOT NULL,
  `cash_flows`         JSON          DEFAULT NULL,
  `npv`                DECIMAL(18,2) DEFAULT NULL,
  `irr`                DECIMAL(10,4) DEFAULT NULL,
  `static_payback`     DECIMAL(10,2) DEFAULT NULL,
  `dynamic_payback`    DECIMAL(10,2) DEFAULT NULL,
  `created_by`         VARCHAR(64)   DEFAULT NULL,
  `created_at`         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='投资评估方案表';

DROP TABLE IF EXISTS algo_profit_forecast;
CREATE TABLE algo_profit_forecast (
  `id`                   BIGINT        NOT NULL AUTO_INCREMENT,
  `base_revenue`         DECIMAL(18,2) NOT NULL,
  `revenue_growth_rate`  DECIMAL(10,4) NOT NULL,
  `cost_rate`            DECIMAL(10,4) NOT NULL,
  `expense_rate`         DECIMAL(10,4) NOT NULL,
  `tax_rate`             DECIMAL(10,4) NOT NULL,
  `periods`              INT           NOT NULL,
  `results`              JSON          DEFAULT NULL,
  `created_by`           VARCHAR(64)   DEFAULT NULL,
  `created_at`           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='损益预测记录表';

-- ============================================================
-- 5. 可视化报表域
-- ============================================================

DROP TABLE IF EXISTS report_pdf_report;
CREATE TABLE report_pdf_report (
  `id`                 BIGINT       NOT NULL AUTO_INCREMENT,
  `name`               VARCHAR(256) NOT NULL,
  `type`               ENUM('comprehensive','warning','investment') NOT NULL,
  `fiscal_period`      VARCHAR(16)  DEFAULT NULL,
  `include_warning`    TINYINT(1)   DEFAULT 0,
  `include_ratio`      TINYINT(1)   DEFAULT 1,
  `include_trend`      TINYINT(1)   DEFAULT 1,
  `include_investment` TINYINT(1)   DEFAULT 0,
  `status`             ENUM('completed','generating','failed') NOT NULL DEFAULT 'generating',
  `file_path`          VARCHAR(512) DEFAULT NULL,
  `file_size`          VARCHAR(32)  DEFAULT NULL,
  `creator_id`         BIGINT       DEFAULT NULL,
  `creator_name`       VARCHAR(64)  DEFAULT NULL,
  `created_at`         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY idx_status (`status`),
  CONSTRAINT fk_report_creator FOREIGN KEY (`creator_id`) REFERENCES sys_user (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF报告表';

DROP TABLE IF EXISTS report_benchmark_data;
CREATE TABLE report_benchmark_data (
  `id`             BIGINT        NOT NULL AUTO_INCREMENT,
  `indicator`      VARCHAR(64)   NOT NULL,
  `indicator_code` VARCHAR(16)   NOT NULL,
  `enterprise`     DECIMAL(18,4) DEFAULT NULL,
  `industry_avg`   DECIMAL(18,4) DEFAULT NULL,
  `industry_best`  DECIMAL(18,4) DEFAULT NULL,
  `deviation`      DECIMAL(10,4) DEFAULT NULL,
  `fiscal_period`  VARCHAR(16)   NOT NULL,
  `industry`       VARCHAR(64)   DEFAULT NULL,
  `updated_at`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY idx_period_industry (`fiscal_period`, `industry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='行业对标数据表';

DROP TABLE IF EXISTS report_dashboard_cache;
CREATE TABLE report_dashboard_cache (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT,
  `cache_key`   VARCHAR(128) NOT NULL,
  `cache_value` JSON         NOT NULL,
  `fiscal_period` VARCHAR(16)  DEFAULT NULL,
  `updated_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY uk_cache_key (`cache_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='仪表盘缓存表';

-- ============================================================
-- 6. 初始数据
-- ============================================================

INSERT INTO sys_role (`name`, `code`, `description`) VALUES
  ('系统管理员', 'ADMIN', '拥有所有功能权限'),
  ('财务分析人员', 'ANALYST', '数据导入、算法配置、报告生成'),
  ('管理层', 'MANAGER', '查看仪表盘、报告和预警');

INSERT INTO sys_role_permission (`role_id`, `permission_key`) VALUES
  (1, 'data:etl'),
  (1, 'data:import'),
  (1, 'data:validation'),
  (1, 'data:mapping'),
  (1, 'algorithm:ratio'),
  (1, 'algorithm:warning'),
  (1, 'algorithm:investment'),
  (1, 'algorithm:forecast'),
  (1, 'algorithm:trend'),
  (1, 'config:formula'),
  (1, 'config:threshold'),
  (1, 'config:knowledge'),
  (1, 'config:version'),
  (1, 'report:chart'),
  (1, 'report:pdf'),
  (1, 'report:benchmark'),
  (1, 'system:user'),
  (1, 'system:audit'),
  (1, 'system:etl-monitor'),
  (1, 'system:params'),
  (2, 'data:etl'),
  (2, 'data:import'),
  (2, 'data:validation'),
  (2, 'data:mapping'),
  (2, 'algorithm:ratio'),
  (2, 'algorithm:warning'),
  (2, 'algorithm:investment'),
  (2, 'algorithm:forecast'),
  (2, 'algorithm:trend'),
  (2, 'config:formula'),
  (2, 'config:threshold'),
  (2, 'config:knowledge'),
  (2, 'config:version'),
  (2, 'report:chart'),
  (2, 'report:pdf'),
  (2, 'report:benchmark'),
  (3, 'report:chart'),
  (3, 'report:pdf'),
  (3, 'report:benchmark'),
  (3, 'algorithm:warning');

INSERT INTO sys_user (`username`, `password_hash`, `name`, `department`, `role_id`, `status`) VALUES
  ('admin',   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '系统管理员', '信息部',       1, 'active'),
  ('zhangsan','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '张三',       '财务部',       2, 'active'),
  ('lisi',    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '李四',       '财务部',       2, 'active'),
  ('wangwu',  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '王五',       '总经理办公室', 3, 'active');

INSERT INTO config_system_param (`param_key`, `param_value`, `description`, `editable`) VALUES
  ('system.name',         'FinSight财务智能分析系统', '系统名称',             1),
  ('system.version',      '1.0.0',                    '系统版本',             0),
  ('etl.cron',            '0 0 2 * * ?',              'ETL定时执行Cron表达式', 1),
  ('etl.timeout',         '3600',                     'ETL任务超时时间(秒)',   1),
  ('warning.auto_notify', 'true',                     '预警自动通知',          1),
  ('warning.notify_email','finance@company.com',      '预警通知邮箱',          1),
  ('report.max_history',  '100',                      '报告最大保留数量',      1),
  ('data.retention_days', '365',                      '数据保留天数',          1);

INSERT INTO config_email_param (`smtp_host`, `smtp_port`, `sender`, `username`, `password`, `ssl_enabled`) VALUES
  ('smtp.company.com', 465, 'finsight@company.com', 'finsight@company.com', 'encrypted_password', 1);

INSERT INTO config_threshold (`indicator`, `indicator_code`, `direction`, `yellow_value`, `orange_value`, `red_value`, `dynamic_base`) VALUES
  ('流动比率',   'R001', 'lower', '< 2.0',  '< 1.5',  '< 1.0',  0),
  ('速动比率',   'R002', 'lower', '< 1.2',  '< 1.0',  '< 0.8',  0),
  ('现金比率',   'R003', 'lower', '< 0.3',  '< 0.25', '< 0.2',  1),
  ('资产负债率', 'R004', 'upper', '> 50%',  '> 60%',  '> 70%',  0);

INSERT INTO config_formula (`name`, `expression`, `category`, `enabled`, `version`, `created_by`) VALUES
  ('流动比率',       '流动资产 / 流动负债',                               '偿债能力', 1, 'v1.3', 'admin'),
  ('速动比率',       '(流动资产 - 存货) / 流动负债',                      '偿债能力', 1, 'v1.2', 'admin'),
  ('资产负债率',     '负债总额 / 资产总额 * 100',                         '偿债能力', 1, 'v1.1', 'admin'),
  ('应收账款周转率', '营业收入 / (应收账款期初 + 应收账款期末) / 2',       '营运能力', 1, 'v1.0', 'admin'),
  ('销售净利率',     '净利润 / 营业收入 * 100',                           '盈利能力', 1, 'v1.0', 'admin'),
  ('营业收入增长率', '(本期营业收入 - 上期营业收入) / 上期营业收入 * 100', '发展能力', 1, 'v1.0', 'admin');

INSERT INTO config_model_version (`model_type`, `version`, `description`, `creator`, `is_active`) VALUES
  ('ratio',   'v1.0', '初始版本，包含基础比率公式',                'admin', 0),
  ('ratio',   'v1.1', '修正资产负债率公式',                        'admin', 0),
  ('ratio',   'v1.2', '优化存货周转率公式，支持平均余额计算',       'admin', 0),
  ('ratio',   'v1.3', '新增现金比率公式，修正速动比率计算逻辑',     'admin', 1),
  ('warning', 'v1.0', '初始预警阈值配置',                          'admin', 0),
  ('warning', 'v2.0', '调整流动比率阈值，新增现金比率预警',         'admin', 1);

INSERT INTO config_knowledge (`indicator`, `level`, `content`, `version`, `useful_count`, `useless_count`, `created_by`) VALUES
  ('流动比率', 'yellow', '建议优化短期偿债能力：1) 加快应收账款回收；2) 合理安排短期负债到期结构；3) 适当增加流动资产储备。',                      'v2.1', 15, 2, 'admin'),
  ('流动比率', 'orange', '流动比率偏低，需重点关注：1) 审查短期借款用途和必要性；2) 加速存货周转；3) 考虑长期融资替代短期负债。',                  'v2.0', 8,  1, 'admin'),
  ('流动比率', 'red',    '流动比率严重不足，需立即行动：1) 启动紧急融资方案；2) 出售非核心资产；3) 与银行协商展期；4) 暂停非必要支出。',            'v2.0', 5,  0, 'admin'),
  ('现金比率', 'red',    '现金比率严重不足，需立即加强现金管理：1) 加速应收款催收；2) 延长应付款账期；3) 考虑短期融资；4) 建立最低现金储备制度。', 'v1.3', 12, 1, 'admin');

INSERT INTO data_etl_task (`name`, `source`, `target`, `cron`, `status`, `last_records`) VALUES
  ('K8科目余额表抽取',   '金蝶K8', '科目余额事实表',     '0 0 2 * * ?', 'success', 12580),
  ('K8利润表抽取',       '金蝶K8', '利润表事实表',       '0 0 2 * * ?', 'success', 3250),
  ('K8现金流量表抽取',   '金蝶K8', '现金流量表事实表',   '0 0 2 * * ?', 'failed',  0);

INSERT INTO data_subject_mapping (`k8_code`, `k8_name`, `target_code`, `target_name`, `category`, `enabled`) VALUES
  ('1001', '库存现金',       'A001', '货币资金-现金',       '资产类', 1),
  ('1002', '银行存款',       'A002', '货币资金-银行存款',   '资产类', 1),
  ('1122', '应收账款',       'A010', '应收账款',           '资产类', 1),
  ('2202', '应付账款',       'L005', '应付账款',           '负债类', 1),
  ('6001', '主营业务收入',   'R001', '营业收入',           '损益类', 1);

INSERT INTO data_validation_rule (`name`, `expression`, `level`, `message`, `enabled`) VALUES
  ('资产负债平衡校验', 'ABS(asset - liability - equity) < 0.01',            'error',   '资产不等于负债+所有者权益',       1),
  ('净利润校验',       'ABS(net_profit - retained_earnings_change) < 0.01', 'warning', '净利润与未分配利润变动不一致',     1),
  ('现金流平衡校验',   'ABS(cash_inflow - cash_outflow - net_cash) < 0.01', 'error',   '现金流入减流出不等于净现金流',     0);
