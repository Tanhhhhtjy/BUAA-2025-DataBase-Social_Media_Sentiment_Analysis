-- Add status column to alerts table
-- 0: Unhandled (Default)
-- 1: Handled

ALTER TABLE alerts ADD COLUMN status INT NOT NULL DEFAULT 0 COMMENT '处理状态(0:未处理, 1:已处理)';
