DROP INDEX IF EXISTS idx_motorista_cpf;
DROP INDEX IF EXISTS idx_motorista_viagem_cpf;
DROP INDEX IF EXISTS idx_entrega_codigo_viagem;
DROP INDEX IF EXISTS idx_mercadoria_nf;
DROP INDEX IF EXISTS idx_mercadoria_cpf_cnpj;
DROP INDEX IF EXISTS idx_destinatario_cpf_cnpj;
DROP INDEX IF EXISTS idx_destinatario_nome_destinatario_upper;
DROP INDEX IF EXISTS idx_destinatario_nome_destinatario_lower;
DROP INDEX IF EXISTS idx_destinatario_nome_destinatario;

---------------------------------------------------------------------------

CREATE UNIQUE INDEX idx_motorista_cpf ON motorista (cpf);
CREATE INDEX idx_motorista_viagem_cpf ON motorista_viagem (cpf);
CREATE INDEX idx_entrega_codigo_viagem ON entrega (codigo_viagem);
CREATE UNIQUE INDEX idx_mercadoria_nf ON mercadoria (nf);
CREATE INDEX idx_mercadoria_cpf_cnpj ON mercadoria (cpf_cnpj);
CREATE UNIQUE INDEX idx_destinatario_cpf_cnpj ON destinatario (cpf_cnpj);
CREATE INDEX idx_destinatario_nome_destinatario_upper ON destinatario (upper
(nome_destinatario));
CREATE INDEX idx_destinatario_nome_destinatario_lower ON destinatario (lower
(nome_destinatario));
CREATE INDEX idx_destinatario_nome_destinatario ON destinatario (nome_destinatario);

---------------------------------------------------------------------------

-- Consulta Antiga

SELECT  destinatario.cpf_cnpj AS cpf_cnpj_destinatario,
        destinatario.nome_destinatario AS nome_destinatario,
        mercadoria_motorista.cpf AS cpf_motorista,
        mercadoria_motorista.cnh AS cnh_motorista,
        mercadoria_motorista.nome_motorista AS nome_motorista
FROM destinatario
INNER JOIN (
    SELECT  mercadoria.cpf_cnpj AS destinatario_cpf_cnpj,
            mercadoria_entrega.cpf AS cpf,
            mercadoria_entrega.cnh AS cnh,
            mercadoria_entrega.nome_motorista AS nome_motorista
    FROM mercadoria
    INNER JOIN (
        SELECT  entrega.nf AS nf,
                moto_viagem.cpf AS cpf,
                moto_viagem.cnh AS cnh,
                moto_viagem.nome_motorista AS nome_motorista
        FROM entrega
        INNER JOIN (
            SELECT  motorista.cpf AS cpf,
                    motorista.cnh AS cnh,
                    motorista.nome AS nome_motorista,
                    motorista_viagem.codigo_viagem AS codigo_viagem
            FROM motorista
            INNER JOIN motorista_viagem
            ON motorista.cpf = motorista_viagem.cpf
        ) AS moto_viagem
        ON entrega.codigo_viagem = moto_viagem.codigo_viagem
    ) AS mercadoria_entrega
    ON mercadoria.nf = mercadoria_entrega.nf
    GROUP BY mercadoria.cpf_cnpj, mercadoria_entrega.cpf, mercadoria_entrega.cnh, mercadoria_entrega.nome_motorista
) AS mercadoria_motorista
ON destinatario.cpf_cnpj = mercadoria_motorista.destinatario_cpf_cnpj
WHERE nome_destinatario ILIKE 'e%';

---------------------------------------------------------------------------------

-- Consulta Otimizada

SELECT destinatario_mercadoria.destinatario_nome_destinatario AS nome_destinatario,
        destinatario_mercadoria.destinatario_cpf_cnpj AS cpf_cnpj_destinatario,
        entrega_moto_viagem.cpf AS cpf_motorista,
        entrega_moto_viagem.cnh AS cnh_motorista,
        entrega_moto_viagem.nome_motorista AS nome_motorista
FROM (
    SELECT destinatario.nome_destinatario AS destinatario_nome_destinatario,
                destinatario.cpf_cnpj AS destinatario_cpf_cnpj,
                mercadoria.nf AS mercadoria_nf
        FROM (
        SELECT nome_destinatario,
                        cpf_cnpj
                FROM destinatario
                WHERE nome_destinatario ILIKE 'e%'
    ) AS destinatario
        INNER JOIN mercadoria
        ON destinatario.cpf_cnpj = mercadoria.cpf_cnpj
) AS destinatario_mercadoria
INNER JOIN
(
    SELECT entrega.nf AS nf,
        moto_viagem.cpf AS cpf,
        moto_viagem.cnh AS cnh,
        moto_viagem.nome_motorista AS nome_motorista
FROM entrega
        INNER JOIN (
    SELECT motorista.cpf AS cpf,
                motorista.cnh AS cnh,
                motorista.nome AS nome_motorista,
                motorista_viagem.codigo_viagem AS codigo_viagem
        FROM motorista
                INNER JOIN motorista_viagem
                ON motorista.cpf = motorista_viagem.cpf
    ) AS moto_viagem
        ON entrega.codigo_viagem = moto_viagem.codigo_viagem
)
AS entrega_moto_viagem
ON entrega_moto_viagem.nf = destinatario_mercadoria.mercadoria_nf;

---------------------------------------------------------------------------------

-- Aninhamentos removidos

SELECT destinatario.nome_destinatario AS nome_destinatario,
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
WHERE nome_destinatario
ILIKE 'e%';

---------------------------------------------------------------------------------

-- Stored Procedure

CREATE OR REPLACE FUNCTION consultar_viagens(_nome_destinatario VARCHAR(50), _limit INTEGER, _offset INTEGER)
RETURNS TABLE(nome_destinatario varchar(50), cpf_cnpj_destinatario numeric(14), cpf_motorista numeric(11), cnh_motorista numeric(11), nome_motorista varchar(50)) AS $$
BEGIN
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