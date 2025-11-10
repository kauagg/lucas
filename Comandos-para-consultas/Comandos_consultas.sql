-- Buscar conversas de um usuário

SELECT c.*, u.username 
FROM conversations c
JOIN conversation_participants cp ON c.id = cp.conversation_id
JOIN users u ON cp.user_id = u.id
WHERE cp.user_id = 1 AND cp.left_at IS NULL;

-- Buscar mensagens de uma conversa com informações do remetente

SELECT m.*, u.username, u.display_name
FROM messages m
JOIN users u ON m.sender_id = u.id
WHERE m.conversation_id = 1
ORDER BY m.created_at ASC;

-- Verificar status de leitura das mensagens

SELECT m.id, m.content, mrs.read_at, u.username as read_by
FROM messages m
LEFT JOIN message_read_status mrs ON m.id = mrs.message_id
LEFT JOIN users u ON mrs.user_id = u.id
WHERE m.conversation_id = 1;

-- Somente copiar e colar para fazer as consultas das tabelas no banco de dados criado no arquivo Banco.sql