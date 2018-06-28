CREATE OR REPLACE FUNCTION consultar_viagens(_nome_destinatario VARCHAR(50), _limit INTEGER, _offset INTEGER)
RETURNS TABLE(nome_destinatario varchar(50), cpf_cnpj_destinatario numeric(14), cpf_motorista numeric(11), cnh_motorista numeric(11), nome_motorista varchar(50)) AS $$
BEGIN
    SET ROLE app_role;

    RETURN QUERY
    SELECT  destinatario.nome_destinatario AS nome_destinatario,
            destinatario.cpf_cnpj AS cpf_cnpj_destinatario,
            motorista.cpf AS cpf_motorista,
            motorista.cnh AS cnh_motorista,
            motorista.nome AS nome_motorista
    FROM destinatario
        INNER JOIN mercadoria
        ON destinatario.cpf_cnpj = mercadoria.cpf_cnpj
        INNER JOIN entrega
        ON entrega.nf = mercadoria.nf
        INNER JOIN motorista_viagem
        ON motorista_viagem.codigo_viagem = entrega.codigo_viagem
        INNER JOIN motorista
        ON motorista.cpf = motorista_viagem.cpf
    WHERE destinatario.nome_destinatario ILIKE _nome_destinatario
    LIMIT _limit
    OFFSET _offset;
END;
$$ LANGUAGE 'plpgsql';