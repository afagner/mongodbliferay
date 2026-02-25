-- Banco e usuário para Liferay (banco relacional)
CREATE DATABASE IF NOT EXISTS lportal
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'liferay'@'%' IDENTIFIED BY 'liferayProd@123';
GRANT ALL PRIVILEGES ON lportal.* TO 'liferay'@'%';
FLUSH PRIVILEGES;
