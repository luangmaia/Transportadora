DROP INDEX IF EXISTS idx_motorista_viagem_placa;
DROP INDEX IF EXISTS idx_veiculo_placa;
DROP INDEX IF EXISTS idx_entrega_codigo_viagem;
DROP INDEX IF EXISTS idx_mercadoria_nf;
DROP INDEX IF EXISTS idx_mercadoria_peso_qtd_volumes;

---------------------------------------------------------------------------

CREATE INDEX idx_motorista_viagem_placa ON motorista_viagem (placa);
CREATE INDEX idx_veiculo_placa ON veiculo (placa);
CREATE INDEX idx_entrega_codigo_viagem ON entrega (codigo_viagem);
CREATE UNIQUE INDEX idx_mercadoria_nf ON mercadoria (nf);
CREATE INDEX idx_mercadoria_peso_qtd_volumes ON mercadoria (peso, qtd_volumes);

---------------------------------------------------------------------------

-- Consulta Antiga

SELECT  mercadoria.peso AS peso,
        mercadoria.qtd_volumes AS qtd_volumes,
        mercadoria_entrega.placa AS placa,
        mercadoria_entrega.modelo AS modelo,
        mercadoria_entrega.capacidade AS capacidade
FROM mercadoria
    INNER JOIN (
    SELECT  entrega.nf AS nf,
            veiculo_viagem.placa AS placa,
            veiculo_viagem.modelo AS modelo,
            veiculo_viagem.capacidade AS capacidade
    FROM entrega
        INNER JOIN (
        SELECT  veiculo.placa AS placa,
                veiculo.modelo AS modelo,
                veiculo.capacidade AS capacidade,
                motorista_viagem.codigo_viagem AS codigo_viagem
        FROM veiculo
            INNER JOIN motorista_viagem
            ON veiculo.placa = motorista_viagem.placa
        ) AS veiculo_viagem
        ON entrega.codigo_viagem = veiculo_viagem.codigo_viagem
    ) AS mercadoria_entrega
    ON mercadoria.nf = mercadoria_entrega.nf
WHERE peso > 0 AND peso < 35 AND qtd_volumes > 0 AND qtd_volumes < 5
ORDER BY peso;

---------------------------------------------------------------------------------

-- Consulta Otimizada

SELECT mercadoria.peso AS peso,
    mercadoria.qtd_volumes AS qtd_volumes,
    mercadoria_entrega.placa AS placa,
    mercadoria_entrega.modelo AS modelo,
    mercadoria_entrega.capacidade AS capacidade
FROM (
        SELECT peso, qtd_volumes, nf
    FROM mercadoria
    WHERE peso > 0 AND peso < 35 AND qtd_volumes > 0 AND qtd_volumes < 5
    ORDER BY peso
    ) AS mercadoria
    INNER JOIN (
    SELECT entrega.nf AS nf,
        veiculo_viagem.placa AS placa,
        veiculo_viagem.modelo AS modelo,
        veiculo_viagem.capacidade AS capacidade
    FROM entrega
        INNER JOIN (
        SELECT veiculo.placa AS placa,
            veiculo.modelo AS modelo,
            veiculo.capacidade AS capacidade,
            motorista_viagem.codigo_viagem AS codigo_viagem
        FROM veiculo
            INNER JOIN motorista_viagem
            ON veiculo.placa = motorista_viagem.placa
                  ) AS veiculo_viagem
        ON entrega.codigo_viagem = veiculo_viagem.codigo_viagem
              ) AS mercadoria_entrega
    ON mercadoria.nf = mercadoria_entrega.nf;

---------------------------------------------------------------------------------

-- Aninhamentos removidos

SELECT mercadoria.peso AS peso,
    mercadoria.qtd_volumes AS qtd_volumes,
    veiculo.placa AS placa,
    veiculo.modelo AS modelo,
    veiculo.capacidade AS capacidade
FROM mercadoria
    INNER JOIN entrega
    ON mercadoria.nf = entrega.nf
    INNER JOIN motorista_viagem
    ON entrega.codigo_viagem = motorista_viagem.codigo_viagem
    INNER JOIN veiculo
    ON veiculo.placa = motorista_viagem.placa
WHERE peso >= 0 AND peso <= 35 AND qtd_volumes >= 0 AND qtd_volumes <= 5
ORDER BY peso;

---------------------------------------------------------------------------------

-- Stored Procedure

CREATE OR REPLACE FUNCTION consultar_veiculos(_peso_minimo REAL, _peso_maximo REAL, _qtd_volumes_minimo INTEGER, _qtd_volumes_maximo INTEGER, _limit INTEGER, _offset INTEGER)
RETURNS TABLE(peso real, qtd_volumes integer, placa varchar(7), modelo varchar(20), capacidade real) AS $$
BEGIN
    RETURN QUERY
    SELECT  mercadoria.peso AS peso,
            mercadoria.qtd_volumes AS qtd_volumes,
            veiculo.placa AS placa,
            veiculo.modelo AS modelo,
            veiculo.capacidade AS capacidade
    FROM mercadoria
        INNER JOIN entrega
        ON mercadoria.nf = entrega.nf
        INNER JOIN motorista_viagem
        ON entrega.codigo_viagem = motorista_viagem.codigo_viagem
        INNER JOIN veiculo
        ON veiculo.placa = motorista_viagem.placa
    WHERE mercadoria.peso >= _peso_minimo AND mercadoria.peso <= _peso_maximo AND mercadoria.qtd_volumes >= _qtd_volumes_minimo AND mercadoria.qtd_volumes <= _qtd_volumes_maximo
    ORDER BY peso
	LIMIT _limit
	OFFSET _offset;
END;
$$ LANGUAGE plpgsql;