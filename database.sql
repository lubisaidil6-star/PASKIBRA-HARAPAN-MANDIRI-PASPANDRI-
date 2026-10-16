-- Skema awal MySQL/MariaDB untuk PASPANDRI XXIII
-- Review dan sesuaikan sebelum digunakan. Password hanya menyimpan hash.
CREATE DATABASE IF NOT EXISTS paspandri_admin CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE paspandri_admin;

CREATE TABLE users (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(60) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('ketua','wakil_ketua','sekretaris','bendahara','pengurus_divisi','pelatih','anggota') NOT NULL DEFAULT 'anggota',
  member_id BIGINT UNSIGNED NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE divisions (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT NULL
);

CREATE TABLE members (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  member_number VARCHAR(30) UNIQUE NULL,
  full_name VARCHAR(150) NOT NULL,
  class_name VARCHAR(30) NULL,
  gender ENUM('L','P','Tidak disebutkan') NULL,
  division_id BIGINT UNSIGNED NULL,
  position_name VARCHAR(100) NULL,
  generation VARCHAR(40) NOT NULL DEFAULT 'XXIII',
  membership_status ENUM('aktif','alumni','nonaktif','cadangan') NOT NULL DEFAULT 'aktif',
  joined_at DATE NULL,
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (division_id) REFERENCES divisions(id) ON DELETE SET NULL
);

ALTER TABLE users ADD CONSTRAINT fk_users_member
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE SET NULL;

CREATE TABLE attendance_sessions (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  session_date DATE NOT NULL,
  title VARCHAR(150) NOT NULL,
  location VARCHAR(180) NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE attendance_records (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  session_id BIGINT UNSIGNED NOT NULL,
  member_id BIGINT UNSIGNED NOT NULL,
  status ENUM('H','I','S','A') NOT NULL,
  note VARCHAR(255) NULL,
  recorded_by BIGINT UNSIGNED NOT NULL,
  recorded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_session_member (session_id, member_id),
  FOREIGN KEY (session_id) REFERENCES attendance_sessions(id) ON DELETE CASCADE,
  FOREIGN KEY (member_id) REFERENCES members(id),
  FOREIGN KEY (recorded_by) REFERENCES users(id)
);

CREATE TABLE finance_transactions (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  transaction_date DATE NOT NULL,
  description VARCHAR(255) NOT NULL,
  transaction_type ENUM('pemasukan','pengeluaran') NOT NULL,
  amount BIGINT UNSIGNED NOT NULL,
  category VARCHAR(100) NULL,
  receipt_path VARCHAR(500) NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE documents (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(200) NOT NULL,
  document_type ENUM('surat_masuk','surat_keluar','notulen','keputusan','laporan','lainnya') NOT NULL,
  document_number VARCHAR(100) NULL,
  document_date DATE NULL,
  storage_path VARCHAR(500) NULL,
  visibility ENUM('pengurus','terbatas','anggota') NOT NULL DEFAULT 'pengurus',
  uploaded_by BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (uploaded_by) REFERENCES users(id)
);

CREATE TABLE schedules (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(180) NOT NULL,
  start_at DATETIME NOT NULL,
  end_at DATETIME NULL,
  location VARCHAR(180) NULL,
  description TEXT NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE work_programs (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  division_id BIGINT UNSIGNED NULL,
  title VARCHAR(180) NOT NULL,
  description TEXT NULL,
  responsible_member_id BIGINT UNSIGNED NULL,
  due_date DATE NULL,
  status ENUM('rencana','berjalan','selesai','ditunda') NOT NULL DEFAULT 'rencana',
  created_by BIGINT UNSIGNED NOT NULL,
  FOREIGN KEY (division_id) REFERENCES divisions(id) ON DELETE SET NULL,
  FOREIGN KEY (responsible_member_id) REFERENCES members(id) ON DELETE SET NULL,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE audit_logs (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NULL,
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(80) NOT NULL,
  entity_id BIGINT UNSIGNED NULL,
  details JSON NULL,
  ip_address VARCHAR(45) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);
