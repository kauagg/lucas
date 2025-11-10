    -- Criar o banco de dados se não existir
CREATE DATABASE IF NOT EXISTS NOME_DO_SEU_BANCO_AQUI_LUCAS CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE AQUI_VOCE_REPETE_O_NOME_DO_BANCO_LUCAS;

-- Tabela de usuários melhorada
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  email VARCHAR(255) UNIQUE, -- Adicionado email para autenticação alternativa
  password_hash VARCHAR(255) NOT NULL,
  display_name VARCHAR(100), -- Nome para exibição (pode ser diferente do username)
  avatar_url VARCHAR(500), -- URL para imagem de perfil
  status ENUM('online', 'offline', 'away', 'busy') DEFAULT 'offline',
  last_seen TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  is_active TINYINT(1) DEFAULT 1, -- Para soft delete de usuários
  INDEX idx_username (username),
  INDEX idx_email (email),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabela para conversas (permite grupos no futuro)
CREATE TABLE conversations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  type ENUM('direct', 'group') DEFAULT 'direct',
  name VARCHAR(255) NULL, -- Nome para conversas em grupo
  created_by INT, -- Usuário que criou a conversa
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  is_active TINYINT(1) DEFAULT 1,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabela de participantes das conversas
CREATE TABLE conversation_participants (
  id INT AUTO_INCREMENT PRIMARY KEY,
  conversation_id INT NOT NULL,
  user_id INT NOT NULL,
  role ENUM('admin', 'member') DEFAULT 'member', -- Para grupos
  joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  left_at TIMESTAMP NULL DEFAULT NULL, -- Quando saiu da conversa
  UNIQUE KEY unique_participant (conversation_id, user_id),
  FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_conversation (conversation_id),
  INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabela de mensagens melhorada
CREATE TABLE messages (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  conversation_id INT NOT NULL, -- Referência à conversa
  sender_id INT NOT NULL,
  content TEXT NOT NULL,
  message_type ENUM('text', 'image', 'file', 'system') DEFAULT 'text',
  file_url VARCHAR(500) NULL, -- Para mensagens com arquivos
  file_name VARCHAR(255) NULL, -- Nome original do arquivo
  file_size INT NULL, -- Tamanho em bytes
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  edited_at TIMESTAMP NULL DEFAULT NULL,
  is_deleted TINYINT(1) DEFAULT 0,
  deleted_at TIMESTAMP NULL DEFAULT NULL,
  parent_message_id BIGINT NULL, -- Para replies/referências
  FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
  FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (parent_message_id) REFERENCES messages(id) ON DELETE SET NULL,
  INDEX idx_conversation_created (conversation_id, created_at),
  INDEX idx_sender (sender_id),
  INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabela para mensagens lidas/recebidas
CREATE TABLE message_read_status (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  message_id BIGINT NOT NULL,
  user_id INT NOT NULL,
  conversation_id INT NOT NULL,
  read_at TIMESTAMP NULL DEFAULT NULL,
  delivered_at TIMESTAMP NULL DEFAULT NULL,
  UNIQUE KEY unique_message_user (message_id, user_id),
  FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
  INDEX idx_user_conversation (user_id, conversation_id),
  INDEX idx_message (message_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabela para bloqueios de usuários
CREATE TABLE user_blocks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  blocker_id INT NOT NULL, -- Quem bloqueou
  blocked_id INT NOT NULL, -- Quem foi bloqueado
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_block (blocker_id, blocked_id),
  FOREIGN KEY (blocker_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (blocked_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_blocker (blocker_id),
  INDEX idx_blocked (blocked_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Inserir alguns usuários de exemplo
INSERT INTO users (username, email, password_hash, display_name, status) VALUES
('usuario1', 'usuario1@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Usuário Um', 'online'),
('usuario2', 'usuario2@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Usuário Dois', 'online');

-- Criar uma conversa direta entre os usuários
INSERT INTO conversations (type, created_by) VALUES ('direct', 1);

-- Adicionar participantes à conversa
INSERT INTO conversation_participants (conversation_id, user_id) VALUES
(1, 1),
(1, 2);