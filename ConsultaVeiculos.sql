CREATE OR REPLACE FUNCTION consultar_veiculos(_peso_minimo REAL, _peso_maximo REAL, _qtd_volumes_minimo INTEGER, _qtd_volumes_maximo INTEGER, _limit INTEGER, _offset INTEGER)
RETURNS TABLE(peso real, qtd_volumes integer, placa varchar(7), modelo varchar(20), capacidade real) AS $$
BEGIN
    SET ROLE app_role;

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